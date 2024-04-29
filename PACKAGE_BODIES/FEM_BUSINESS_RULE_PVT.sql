--------------------------------------------------------
--  DDL for Package Body FEM_BUSINESS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BUSINESS_RULE_PVT" AS
/* $Header: FEMVBUSB.pls 120.12.12010000.2 2008/10/06 17:48:51 huli ship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------
G_FEM                       constant varchar2(3)    := 'FEM';
G_PKG_NAME                  constant varchar2(30)   := 'FEM_BUSINESS_RULE_PVT';
G_BLOCK                     constant varchar2(80)   := G_FEM||'.PLSQL.'||G_PKG_NAME;

-- Action Types
G_UNDEF_ACTION_TYPE         constant number         := -1;
G_DELETE_ACTION_TYPE        constant number         := 0;
G_DUPLICATE_ACTION_TYPE     constant number         := 1;
G_BACKUP_ACTION_TYPE        constant number         := 2;
G_REVERT_ACTION_TYPE        constant number         := 3;

-- Constants for default effective start and end dates if not specified
-- in profile options.
G_DEFAULT_START_DATE_NULL   constant date := FND_DATE.Canonical_To_Date('1900/01/01');
G_DEFAULT_END_DATE_NULL     constant date := FND_DATE.Canonical_To_Date('2500/01/01');

-- Log Level Constants
G_LOG_LEVEL_1               constant number := FND_LOG.Level_Statement;
G_LOG_LEVEL_2               constant number := FND_LOG.Level_Procedure;
G_LOG_LEVEL_3               constant number := FND_LOG.Level_Event;
G_LOG_LEVEL_4               constant number := FND_LOG.Level_Exception;
G_LOG_LEVEL_5               constant number := FND_LOG.Level_Error;
G_LOG_LEVEL_6               constant number := FND_LOG.Level_Unexpected;

G_PLSQL_COMPILATION_ERROR   exception;
pragma exception_init(G_PLSQL_COMPILATION_ERROR,-6550);

--------------------------------------------------------------------------------
-- VARIABLE TYPE DEFINITIONS
--------------------------------------------------------------------------------
t_object_type_code          FEM_OBJECT_TYPES.object_type_code%TYPE;
t_object_id                 FEM_OBJECT_CATALOG_B.object_id%TYPE;
t_object_name               FEM_OBJECT_CATALOG_TL.object_name%TYPE;
t_folder_id                 FEM_OBJECT_CATALOG_B.folder_id%TYPE;
t_object_definition_id      FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
t_approval_status_code      FEM_OBJECT_DEFINITION_B.approval_status_code%TYPE;

t_request_id                FEM_WF_REQUESTS.wf_request_id%TYPE;
t_id                        number;

t_code                      FND_LOOKUP_VALUES.lookup_code%TYPE;
t_meaning                   FND_LOOKUP_VALUES.meaning%TYPE;

t_plsql_pkg_name            FEM_OBJECT_TYPES.object_plsql_pkg_name%TYPE;

t_return_status             varchar2(1);
t_msg_count                 number;
t_msg_data                  varchar2(2000);


--------------------------------------------------------------------------------
-- PRIVATE CURSORS
--------------------------------------------------------------------------------

  -- Object Definitions in a Workflow Request
  cursor req_obj_defs_cur(
    p_request_id number
    ,p_request_item_code varchar2
    ,p_request_type_code varchar2
  )
  is
    select req_def.object_definition_id
    ,req_def.object_type_code
    ,req_def.prev_approval_status_code
    from fem_wf_requests req
    ,fem_wf_req_object_defs req_def
    ,fem_object_definition_b def
    where req.wf_request_id = p_request_id
    and req.wf_request_item_code = p_request_item_code
    and req.wf_request_type_code = p_request_type_code
    and req_def.wf_request_id = req.wf_request_id
    and def.object_definition_id = req_def.object_definition_id
    and def.old_approved_copy_flag = G_CURRENT_COPY;

  -- Object Definitions in a Workflow Request with Denormalized Names
  cursor info_obj_defs_cur(
    p_request_id number
    ,p_request_item_code varchar2
    ,p_request_type_code varchar2
  )
  is
    select def.object_definition_id
    ,def.display_name as object_definition_name
    ,def.old_approved_copy_obj_def_id
    ,def.object_id
    ,obj.object_name
    ,obj.object_type_code
    ,typ.object_type_name
    ,obj.folder_id
    ,fol.folder_name
    ,typ.view_only_oa_function_name
    from fem_wf_requests req
    ,fem_wf_req_object_defs req_def
    ,fem_object_definition_vl def
    ,fem_object_catalog_vl obj
    ,fem_object_types_vl typ
    ,fem_folders_vl fol
    where req.wf_request_id = p_request_id
    and req.wf_request_item_code = p_request_item_code
    and req.wf_request_type_code = p_request_type_code
    and req_def.wf_request_id = req.wf_request_id
    and def.object_definition_id = req_def.object_definition_id
    and def.old_approved_copy_flag = G_CURRENT_COPY
    and obj.object_id = def.object_id
    and typ.object_type_code = obj.object_type_code
    and fol.folder_id = obj.folder_id;


  -- Overlapping Object Definitions under the same Object.
  cursor overlapping_obj_defs_cur (
    p_obj_id                number
    ,p_exclude_obj_def_id   number
    ,p_effective_start_date date
    ,p_effective_end_date   date
  )
  is
    select def.object_definition_id
    ,def.display_name as object_definition_name
    ,def.object_id
    ,obj.object_name
    ,fol.folder_name
    ,def.effective_start_date
    ,def.effective_end_date
    from fem_object_definition_vl def
    ,fem_object_catalog_vl obj
    ,fem_folders_vl fol
    where def.object_id = obj.object_id
    and fol.folder_id = obj.folder_id
    and def.old_approved_copy_flag = G_CURRENT_COPY
    and def.object_id = p_obj_id
    and def.object_definition_id <> nvl(p_exclude_obj_def_id, -1)
    and (
      (
        (def.effective_start_date <= p_effective_start_date)
        and
        (def.effective_end_date >= p_effective_start_date)
      )
      or
      (
        (def.effective_start_date <= p_effective_end_date)
        and
        (def.effective_end_date >= p_effective_end_date)
      )
      or
      (
        (def.effective_start_date >= p_effective_start_date)
        and
        (def.effective_end_date <= p_effective_end_date)
      )
    );


--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE SetApprovalStatus (
  p_obj_def_id                    in number
  ,p_approval_status_code         in varchar2 := FND_API.G_MISS_CHAR
  ,p_approver_user_id             in number := FND_API.G_MISS_NUM
  ,p_approval_date                in date := FND_API.G_MISS_DATE
);

FUNCTION GetApprovalStatus(
  p_obj_def_id                    in number
)
RETURN varchar2;

FUNCTION GetObjectPlsqlPkgName(
  p_object_type_code              in varchar2
)
RETURN varchar2;

PROCEDURE CopyObjectDefinitionInternal (
  p_copy_type_code                in varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_def_id            in number
  ,p_target_obj_def_id            in number
  ,p_target_copy_flag             in varchar2
  ,p_is_full_copy                 in boolean
  ,p_is_new_copy                  in boolean
);

PROCEDURE DeleteObjectDefinitionInternal(
  p_object_type_code              in varchar2
  ,p_obj_def_id                   in number
);

PROCEDURE CopyObjectDetailsInternal (
  p_copy_type_code                in varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_id                in number
  ,p_target_obj_id                in number
);

PROCEDURE DeleteObjectDetailsInternal(
  p_object_type_code              in varchar2
  ,p_obj_id                       in number
);

PROCEDURE CopyObjectRec (
  p_source_obj_id                 in number
  ,p_target_obj_id                in number
  ,p_target_obj_name              in varchar2
  ,p_target_obj_desc              in varchar2 := FND_API.G_MISS_CHAR
  ,p_created_by                   in number
  ,p_creation_date                in date
);

PROCEDURE DeleteObjectRec (
  p_obj_id                        in number
);

PROCEDURE CopyObjectDefinitionRec (
  p_source_obj_def_id             in number
  ,p_target_obj_def_id            in number
  ,p_target_obj_id                in number := FND_API.G_MISS_NUM
  ,p_target_obj_def_name          in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_obj_def_desc          in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_start_date            in date := FND_API.G_MISS_DATE
  ,p_target_end_date              in date := FND_API.G_MISS_DATE
  ,p_target_copy_flag             in varchar2
  ,p_target_copy_obj_def_id       in number := FND_API.G_MISS_NUM
  ,p_created_by                   in number
  ,p_creation_date                in date
);

PROCEDURE DeleteObjectDefinitionRec(
  p_obj_def_id                    in number
);

PROCEDURE CopyObjectDependencyRecs(
  p_source_obj_def_id             in number
  ,p_target_obj_def_id            in number
  ,p_created_by                   in number
  ,p_creation_date                in date
);

PROCEDURE DeleteObjectDependencyRecs(
  p_obj_def_id                    in number
);

PROCEDURE CopyVtObjDefAttrRec(
  p_source_obj_def_id             in number
  ,p_target_obj_def_id            in number
  ,p_created_by                   in number
  ,p_creation_date                in date
);

PROCEDURE DeleteVtObjDefAttrRec(
  p_obj_def_id                    in number
);

PROCEDURE SetOldApprovedObjDefId(
  p_obj_def_id                    in number
  ,p_old_approved_obj_def_id      in number
);

FUNCTION GetOldApprovedObjDefId (
  p_obj_def_id                    in number
)
RETURN number;

FUNCTION ObjectDefinitionExists (
  p_obj_def_id                    in number
)
RETURN boolean;

FUNCTION IsObjectEmpty(
  p_obj_id                        in number
  ,p_exclude_obj_def_id           in number default null
)
RETURN boolean;

PROCEDURE CreateWfReqObjectDefRow (
  p_wf_request_id                 in number
  ,p_obj_def_id                   in number
  ,p_object_type_code             in varchar2
  ,p_prev_approval_status_code    in varchar2
);

FUNCTION GetObjectDefinitionsCount(
  p_request_id                    in number
  ,p_request_item_code            in varchar2
  ,p_request_type_code            in varchar2
)
RETURN number;

PROCEDURE CheckOverlapObjDefsInternal(
  p_obj_id                        in number
  ,p_exclude_obj_def_id           in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_action_type                  in number
);

PROCEDURE GetEffectiveDates(
  p_obj_def_id                    in number
  ,x_effective_start_date         out nocopy date
  ,x_effective_end_date           out nocopy date
);

FUNCTION GetProfileOptionDateValue (
  p_profile_option_name           in varchar2
)
RETURN date;


--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--   DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes a Business Rule Definition and all its detail records.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code     - Object Type Code
--   p_obj_def_id           - Object Definition ID
--   p_process_type         - Process Type (optional)
--                              0 = DEFAULT
--                              1 = WORKFLOW
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition (
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_obj_def_id                   in number
  ,p_process_type                 in number := G_DEFAULT
)
--------------------------------------------------------------------------------
IS

  l_delete_request_id           number;

BEGIN

  DeleteObjectDefinition (
    p_api_version        => p_api_version
    ,p_init_msg_list     => p_init_msg_list
    ,p_commit            => p_commit
    ,x_return_status     => x_return_status
    ,x_msg_count         => x_msg_count
    ,x_msg_data          => x_msg_data
    ,p_object_type_code  => p_object_type_code
    ,p_obj_def_id        => p_obj_def_id
    ,p_process_type      => p_process_type
    ,x_delete_request_id => l_delete_request_id
  );

END DeleteObjectDefinition;

--
-- PROCEDURE
--   DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes a Business Rule Definition and all its detail records.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code     - Object Type Code
--   p_obj_def_id           - Object Definition Id
--   p_process_type         - Process Type (optional)
--                              0 = DEFAULT
--                              1 = WORKFLOW
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--   x_delete_request_id    - Delete Request Id
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition (
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_obj_def_id                   in number
  ,p_process_type                 in number := G_DEFAULT
  ,x_delete_request_id            out nocopy number
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'DeleteObjectDefinition';
  l_api_version          constant number       := 1.0;

  l_obj_id                        t_object_id%TYPE;
  l_old_approved_obj_def_id       t_object_definition_id%TYPE;
  l_approval_status_code          t_approval_status_code%TYPE;

  l_can_delete                    varchar2(1);

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);


BEGIN

  -- Standard Start of API Savepoint
  savepoint DeleteObjectDefinition_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN, p_object_type_code:' || p_object_type_code
    || ' p_obj_def_id:' || p_obj_def_id
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Set Approval Request Id to null
  x_delete_request_id := null;

  -- Only perform the delete logic if the object definition exists
  if (ObjectDefinitionExists(p_obj_def_id)) then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'ObjectDefinitionExists');

    -- Get the Object Id
    l_obj_id := GetObjectId(p_obj_def_id);

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'l_obj_id:' || l_obj_id);

    -- If this is the only Object Definition for the Object, then check to see
    -- if we can delete the parent Object.  Otherwise simply check to see if we
    -- can delete the Object Definition.
    if ((l_obj_id is not null) and IsObjectEmpty(l_obj_id,p_obj_def_id)) then

      FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'IsObjectEmpty');

      -- Check to see if we can delete the Object (this will also check to see
      -- if the last Object Definition can be deleted).
      FEM_PL_PKG.can_delete_object (
        p_api_version     => 1.0
        ,p_init_msg_list  => FND_API.G_FALSE
        ,x_return_status  => l_return_status
        ,x_msg_count      => l_msg_count
        ,x_msg_data       => l_msg_data
        ,p_object_id      => l_obj_id
        ,p_process_type   => p_process_type
        ,x_can_delete_obj => l_can_delete
      );
      FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'IsObjectEmpty 1');

    else

      FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'NOT IsObjectEmpty');

      -- Check to see if we can delete the Object Definition
      FEM_PL_PKG.can_delete_object_def (
        p_api_version           => 1.0
        ,p_init_msg_list        => FND_API.G_FALSE
        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
        ,p_object_definition_id => p_obj_def_id
        ,p_process_type         => p_process_type
        ,x_can_delete_obj_def   => l_can_delete
      );

      FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'NOT IsObjectEmpty 1');
    end if;

    -- We can ignore l_can_delete as these FEM_PL_PKG API's now have the
    -- x_return_status out param.
    if (l_return_status = FND_API.G_RET_STS_ERROR) then
      raise FND_API.G_EXC_ERROR;
    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Before GetApprovalStatus');

    l_approval_status_code := GetApprovalStatus(p_obj_def_id);

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'After GetApprovalStatus');

    if (  (p_process_type = G_DEFAULT)
      and (l_approval_status_code in (G_APPROVED_STATUS,G_NOT_APPROVED_STATUS))
    ) then

      -- If business rule has ever gone through an approval process, then we
      -- must submit this business rule for deletion by raising a delete
      -- business event
       FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'Before SetApprovalStatus');


      SetApprovalStatus (
        p_obj_def_id            => p_obj_def_id
        ,p_approval_status_code => G_SUBMIT_DELETE_STATUS
      );

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After SetApprovalStatus');

      x_delete_request_id :=
        FEM_FEMAPPR_ITEM_TYPE.CreateWfRequestRow (
          p_request_item_code  => FEM_FEMAPPR_ITEM_TYPE.G_BUSINESS_RULE_ITEM
          ,p_request_type_code => FEM_FEMAPPR_ITEM_TYPE.G_DELETE_TYPE
        );

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After FEM_FEMAPPR_ITEM_TYPE.CreateWfRequestRow x_delete_request_id:' || x_delete_request_id);

      CreateWfReqObjectDefRow (
        p_wf_request_id              => x_delete_request_id
        ,p_obj_def_id                => p_obj_def_id
        ,p_object_type_code          => p_object_type_code
        ,p_prev_approval_status_code => l_approval_status_code
      );

      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'After CreateWfReqObjectDefRow, l_approval_status_code:' || l_approval_status_code);


      FEM_FEMAPPR_ITEM_TYPE.RaiseEvent (
        p_event_name         => FEM_FEMAPPR_ITEM_TYPE.G_BUSINESS_RULE_EVENT_DELETE
        ,p_request_id        => x_delete_request_id
        ,p_user_id           => FND_GLOBAL.User_Id
        ,p_user_name         => FND_GLOBAL.User_Name
        ,p_responsibility_id => FND_GLOBAL.Resp_Id
        ,p_application_id    => FND_GLOBAL.Resp_Appl_Id
        ,p_org_id            => FND_GLOBAL.Org_Id
      );

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After FEM_FEMAPPR_ITEM_TYPE.RaiseEvent');

    else

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'Before calling GetOldApprovedObjDefId ');

      -- Otherwise, go through the regular delete processing

      -- Get the Old Approved Copy before deleting the Current Copy
      l_old_approved_obj_def_id := GetOldApprovedObjDefId(p_obj_def_id);

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After calling l_old_approved_obj_def_id: ' || l_old_approved_obj_def_id);


      -- Delete the Current Copy
      DeleteObjectDefinitionInternal(
        p_object_type_code      => p_object_type_code
        ,p_obj_def_id           => p_obj_def_id
      );


      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After DeleteObjectDefinitionInternal');

      -- Delete the Old Approved Copy
      if (l_old_approved_obj_def_id is not null) then

        FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'not null l_old_approved_obj_def_id Before DeleteObjectDefinitionInternal');

        DeleteObjectDefinitionInternal(
          p_object_type_code    => p_object_type_code
          ,p_obj_def_id         => l_old_approved_obj_def_id
        );


        FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'not null l_old_approved_obj_def_id After DeleteObjectDefinitionInternal');
      end if;

      -- Delete the Object if it no longer has any Object Definitions
      if ((l_obj_id is not null) and IsObjectEmpty(l_obj_id)) then

        FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'IsObjectEmpty 1 Before DeleteObjectDefinitionInternal, l_obj_id:' || l_obj_id);

        -- Delete any detail records of an Object if they exist
        DeleteObjectDetailsInternal (
          p_object_type_code => p_object_type_code
          ,p_obj_id          => l_obj_id
        );


        FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'IsObjectEmpty 1 After DeleteObjectDefinitionInternal, l_obj_id:' || l_obj_id);
        -- Delete the Object record
        DeleteObjectRec(l_obj_id);

        FEM_ENGINES_PKG.Tech_Message (
         p_severity  => G_LOG_LEVEL_3
         ,p_module   => G_BLOCK||'.'||l_api_name
         ,p_msg_text => 'After DeleteObjectRec');

      end if;

    end if;

  end if;

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    l_callstack := DBMS_UTILITY.Format_Call_Stack;
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'G_EXC_ERROR, l_callstack:' || l_callstack
    );
    BEGIN
       ROLLBACK TO DeleteObjectDefinition_PVT;
    EXCEPTION
       WHEN OTHERS THEN rollback;
    END;

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_callstack := DBMS_UTILITY.Format_Call_Stack;
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'G_EXC_UNEXPECTED_ERROR, l_callstack:' || l_callstack
    );
    BEGIN
       ROLLBACK TO DeleteObjectDefinition_PVT;
    EXCEPTION
       WHEN OTHERS THEN rollback;
    END;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

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

    BEGIN
       ROLLBACK TO DeleteObjectDefinition_PVT;
    EXCEPTION
       WHEN OTHERS THEN rollback;
    END;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END DeleteObjectDefinition;


--
-- PROCEDURE
--   DuplicateObjectDefinition
--
-- DESCRIPTION
--   Duplicates all the detail records of a Business Rule Definition (source)
--   into another empty Business Rule Definition (target).
--   NOTE:  It does not copy the Business Rule Definition record in
--          FEM_OBJECT_DEFINITION_VL.  That record must already exist.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code     - Object Type Code
--   p_source_obj_def_id    - Source Object Definition ID
--   p_target_obj_def_id    - Target Object Definition ID
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE DuplicateObjectDefinition (
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_def_id            in number
  ,p_target_obj_def_id            in number
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'DuplicateObjectDefinition';
  l_api_version          constant number       := 1.0;

BEGIN

  -- Standard Start of API Savepoint
  savepoint DuplicateObjectDefinition_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CopyObjectDefinitionInternal (
    p_copy_type_code     => G_DUPLICATE
    ,p_object_type_code  => p_object_type_code
    ,p_source_obj_def_id => p_source_obj_def_id
    ,p_target_obj_def_id => p_target_obj_def_id
    ,p_target_copy_flag  => G_CURRENT_COPY
    ,p_is_full_copy      => false
    ,p_is_new_copy       => true
  );

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to DuplicateObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to DuplicateObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to DuplicateObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END DuplicateObjectDefinition;


--
-- PROCEDURE
--   BackupObjectDefinition
--
-- DESCRIPTION
--   Creates a backup of a Business Rule Definition and all its detail records.
--   Returns the old approved copy object definition id.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code         - Object Type Code
--   p_obj_def_id               - Object Definition ID
--
-- OUT
--   x_return_status            - Return Status of API Call
--   x_msg_count                - Total Count of Error Messages in API Call
--   x_msg_data                 - Error Message in API Call
--   x_old_approved_obj_def_id  - Old Approved Copy Object Definition ID
--
--------------------------------------------------------------------------------
PROCEDURE BackupObjectDefinition (
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_obj_def_id                   in number
  ,x_old_approved_obj_def_id      out nocopy number
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'BackupObjectDefinition';
  l_api_version          constant number       := 1.0;

  l_old_approved_obj_def_id t_object_definition_id%TYPE;

BEGIN

  -- Standard Start of API Savepoint
  savepoint BackupObjectDefinition_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_old_approved_obj_def_id := GetOldApprovedObjDefId(p_obj_def_id);

  if (l_old_approved_obj_def_id is null) then

    l_old_approved_obj_def_id := GetNewObjDefId();
    SetOldApprovedObjDefId(p_obj_def_id, l_old_approved_obj_def_id);

  else

    DeleteObjectDefinitionInternal (
      p_object_type_code    => p_object_type_code,
      p_obj_def_id          => l_old_approved_obj_def_id
    );

  end if;

  CopyObjectDefinitionInternal (
    p_copy_type_code     => G_BACKUP
    ,p_object_type_code  => p_object_type_code
    ,p_source_obj_def_id => p_obj_def_id
    ,p_target_obj_def_id => l_old_approved_obj_def_id
    ,p_target_copy_flag  => G_OLD_APPROVED_COPY
    ,p_is_full_copy      => true
    ,p_is_new_copy       => false
  );

  x_old_approved_obj_def_id := l_old_approved_obj_def_id;

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to BackupObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to BackupObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to BackupObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END BackupObjectDefinition;


--
-- PROCEDURE
--   RevertObjectDefinition
--
-- DESCRIPTION
--   Reverts a Business Rule Definition and all its detail records from its
--   backup copy.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code     - Object Type Code
--   p_obj_def_id           - Object Definition ID
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE RevertObjectDefinition (
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_obj_def_id                   in number
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'RevertObjectDefinition';
  l_api_version          constant number       := 1.0;

  l_old_approved_obj_def_id t_object_definition_id%TYPE;
  l_approval_status_code    t_approval_status_code%TYPE;
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_data_edit_lock_exists   varchar2(1);
  l_overlap_exists          boolean;

BEGIN

  -- Standard Start of API Savepoint
  savepoint RevertObjectDefinition_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check that the approval status is NOT_APPROVED
  l_approval_status_code := GetApprovalStatus(p_obj_def_id);
  if (l_approval_status_code <> G_NOT_APPROVED_STATUS) then
    FND_MESSAGE.set_name('FEM', 'FEM_BR_RVRT_NOT_APPROVED_ERR');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Check that object definitions has an old approved copy
  l_old_approved_obj_def_id := GetOldApprovedObjDefId(p_obj_def_id);
  if (l_old_approved_obj_def_id is null) then
    FND_MESSAGE.set_name('FEM', 'FEM_BR_RVRT_OLD_APPR_CPY_ERR');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Check for any Data Locks
  FEM_PL_PKG.obj_def_data_edit_lock_exists(
    p_object_definition_id    => p_obj_def_id
    ,x_data_edit_lock_exists  => l_data_edit_lock_exists
  );

  if (FND_API.To_Boolean(l_data_edit_lock_exists)) then
    FND_MESSAGE.set_name('FEM', 'FEM_BR_RVRT_DATA_EDIT_LOCK_ERR');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Get effective dates of old approved copy
  GetEffectiveDates(
    p_obj_def_id            => l_old_approved_obj_def_id
    ,x_effective_start_date => l_effective_start_date
    ,x_effective_end_date   => l_effective_end_date
  );

  -- Check if reverting from old approved copy will cause overlaps with other
  -- object definitions.
  CheckOverlapObjDefsInternal(
    p_obj_id                => GetObjectId(p_obj_def_id)
    ,p_exclude_obj_def_id   => p_obj_def_id
    ,p_effective_start_date => l_effective_start_date
    ,p_effective_end_date   => l_effective_end_date
    ,p_action_type          => G_REVERT_ACTION_TYPE
  );

  -- If everthing is OK, then allow reverting object definitinion.
  DeleteObjectDefinitionInternal(
    p_object_type_code      => p_object_type_code
    ,p_obj_def_id           => p_obj_def_id
  );

  CopyObjectDefinitionInternal (
    p_copy_type_code     => G_REVERT
    ,p_object_type_code  => p_object_type_code
    ,p_source_obj_def_id => l_old_approved_obj_def_id
    ,p_target_obj_def_id => p_obj_def_id
    ,p_target_copy_flag  => G_CURRENT_COPY
    ,p_is_full_copy      => true
    ,p_is_new_copy       => false
  );

  -- Override approval status to NOT_APPROVED after reverting.
  SetApprovalStatus (
    p_obj_def_id            => p_obj_def_id
    ,p_approval_status_code => G_NOT_APPROVED_STATUS
    ,p_approver_user_id     => null
    ,p_approval_date        => null
  );

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to RevertObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to RevertObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to RevertObjectDefinition_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END RevertObjectDefinition;


--
-- PROCEDURE
--   DeleteObject
--
-- DESCRIPTION
--   Deletes an entire Business Rule, including all its Definitions and
--   detail records.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code     - Object Type Code
--   p_obj_def_id           - Object Definition ID
--   p_process_type         - Process Type (optional)
--                              0 = DEFAULT
--                              1 = WORKFLOW
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObject (
  p_api_version                   in number
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy  varchar2
  ,x_msg_count                    out nocopy  number
  ,x_msg_data                     out nocopy  varchar2
  ,p_object_type_code             in varchar2
  ,p_obj_id                       in number
  ,p_process_type                 in number := G_DEFAULT
)
--------------------------------------------------------------------------------
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(30) := 'DeleteObject';
  l_api_version          constant number       := 1.0;

  -----------------------
  -- Declare variables --
  -----------------------
  l_can_delete_obj                varchar2(1);

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  cursor l_obj_defs_cur is
    select object_definition_id
    from fem_object_definition_b
    where object_id = p_obj_id
    and old_approved_copy_flag = G_CURRENT_COPY;

BEGIN

  -- Standard Start of API Savepoint
  savepoint DeleteObject_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN, p_object_type_code:' || p_object_type_code
     || ' p_obj_id:' || p_obj_id || ' p_process_type:' || p_process_type
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------------
  -- STEP 1: Check to see if we can delete object
  ------------------------------------------------------------------------------
  FEM_PL_PKG.can_delete_object (
    p_api_version     => 1.0
    ,p_init_msg_list  => FND_API.G_FALSE
    ,x_return_status  => l_return_status
    ,x_msg_count      => l_msg_count
    ,x_msg_data       => l_msg_data
    ,p_object_id      => p_obj_id
    ,p_process_type   => p_process_type
    ,x_can_delete_obj => l_can_delete_obj
  );

   FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'After call FEM_PL_PKG.can_delete_object'
   );
  -- We can ignore l_can_delete_obj as this FEM_PL_PKG API now has the
  -- x_return_status out param.
  if (l_return_status = FND_API.G_RET_STS_ERROR) then
    raise FND_API.G_EXC_ERROR;
  elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Loop through all object definitions and delete them
  ------------------------------------------------------------------------------
  for l_obj_defs_rec in l_obj_defs_cur loop

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'Before call DeleteObjectDefinition'
   );

    DeleteObjectDefinition (
      p_object_type_code => p_object_type_code
      ,p_obj_def_id      => l_obj_defs_rec.object_definition_id
      ,p_init_msg_list   => FND_API.G_FALSE
      ,x_return_status   => l_return_status
      ,x_msg_count       => l_msg_count
      ,x_msg_data        => l_msg_data
      ,p_process_type    => p_process_type
    );

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'After call DeleteObjectDefinition'
   );

    if (l_return_status = FND_API.G_RET_STS_ERROR) then
      raise FND_API.G_EXC_ERROR;
    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

  end loop;

  ------------------------------------------------------------------------------
  -- STEP 3: Delete the Object
  ------------------------------------------------------------------------------
  if (IsObjectEmpty(p_obj_id)) then

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'Before call DeleteObjectDetailsInternal'
   );
    -- Delete any detail records of an Object if they exist
    DeleteObjectDetailsInternal (
      p_object_type_code => p_object_type_code
      ,p_obj_id          => p_obj_id
    );

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'After call DeleteObjectDetailsInternal'
   );
    -- Delete the Object record
    DeleteObjectRec(p_obj_id);

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'After call DeleteObjectRec'
   );

  end if;

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    BEGIN
       ROLLBACK TO DeleteObject_PVT;
    EXCEPTION
       WHEN OTHERS THEN rollback;
    END;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    BEGIN
       ROLLBACK TO DeleteObject_PVT;
    EXCEPTION
       WHEN OTHERS THEN rollback;
    END;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    BEGIN
       ROLLBACK TO DeleteObject_PVT;
    EXCEPTION
       WHEN OTHERS THEN rollback;
    END;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg (
        p_pkg_name        => G_PKG_NAME
        ,p_procedure_name => l_api_name
      );
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END DeleteObject;


--
-- PROCEDURE
--   DuplicateObject
--
-- DESCRIPTION
--   Duplicates an entire Object (source), including the Object Definition,
--   Object Dependencies and all its detail records, into a new Object (target).
--
--   NOTES:
--   1) If a null value is passed for Target Object Id and/or Target Object
--   Definition Id, a new value will be obtained from their respective
--   sequences.
--   2) If any of the optional parameters are omitted when calling this API,
--   the corresponding values will be copied from the source record.
--
-- IN
--   p_api_version                  - API Version
--   p_init_msg_list                - Initialize Message List Flag (Boolean)
--   p_commit                       - Commit Work Flag (Boolean)
--   p_object_type_code             - Object Type Code
--   p_source_obj_id                - Source Object Id
--   p_source_obj_def_id            - Source Object Definition Id
--   p_target_obj_name              - Target Object Name
--   p_target_obj_desc              - Target Object Description (optional)
--   p_target_obj_def_name          - Target Object Definition Name
--   p_target_obj_def_desc          - Target Object Definition Description (optional)
--   p_target_start_date            - Target Effective Start Date (optional)
--   p_target_end_date              - Target Effective End Date (optional)
--   p_target_approval_status_code  - Target Approval Status Code (optional)
--   p_target_approved_by           - Target Approved By (optional)
--   p_target_approval_date         - Target Approval Date (optional)
--   p_created_by                   - Created By (optional)
--   p_creation_date                - Creation Date (optional)
--
-- IN OUT
--   x_target_obj_id                - Target Object Id (optional)
--   x_target_obj_def_id            - Target Object Definition Id (optional)
--
-- OUT
--   x_return_status                - Return Status of API Call
--   x_msg_count                    - Total Count of Error Messages in API Call
--   x_msg_data                     - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE DuplicateObject (
  p_api_version                   in number
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_id                in number
  ,p_source_obj_def_id            in number
  ,x_target_obj_id                in out nocopy number
  ,p_target_obj_name              in varchar2
  ,p_target_obj_desc              in varchar2 := FND_API.G_MISS_CHAR
  ,x_target_obj_def_id            in out nocopy number
  ,p_target_obj_def_name          in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_obj_def_desc          in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_start_date            in date := FND_API.G_MISS_DATE
  ,p_target_end_date              in date := FND_API.G_MISS_DATE
  ,p_target_approval_status_code  in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_approved_by           in number := FND_API.G_MISS_NUM
  ,p_target_approval_date         in date := FND_API.G_MISS_DATE
  ,p_created_by                   in number := FND_API.G_MISS_NUM
  ,p_creation_date                in date := FND_API.G_MISS_DATE
)
--------------------------------------------------------------------------------
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(30) := 'DuplicateObject';
  l_api_version          constant number       := 1.0;

  -----------------------
  -- Declare variables --
  -----------------------
  l_target_start_date             date;
  l_target_end_date               date;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

BEGIN

  -- Standard Start of API Savepoint
  savepoint DuplicateObject_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------------
  -- STEP 1: Check parameter values
  ------------------------------------------------------------------------------
  if (x_target_obj_id is null) then
    -- Get a new Target Object Id if none was specified
    x_target_obj_id := GetNewObjId();
  end if;

  if (x_target_obj_def_id is null) then
    -- Get a new Target Object Definition Id if none was specified
    x_target_obj_def_id := GetNewObjDefId();
  else

    -- Delete the existing Target Object Definition Id if one was specified
    DeleteObjectDefinition (
      p_object_type_code => p_object_type_code
      ,p_obj_def_id      => x_target_obj_def_id
      ,p_init_msg_list   => FND_API.G_FALSE
      ,x_return_status   => l_return_status
      ,x_msg_count       => l_msg_count
      ,x_msg_data        => l_msg_data
      ,p_process_type    => G_WORKFLOW
    );

    if (l_return_status = FND_API.G_RET_STS_ERROR) then
      raise FND_API.G_EXC_ERROR;
    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

  end if;

  l_target_start_date := p_target_start_date;
  if (l_target_start_date is null) then
    l_target_start_date := GetDefaultStartDate();
  end if;

  l_target_end_date := p_target_end_date;
  if (l_target_end_date is null) then
    l_target_end_date := GetDefaultEndDate();
  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Check Object Name
  ------------------------------------------------------------------------------
  CheckObjectName (
    p_api_version    => 1.0
    ,p_init_msg_list => FND_API.G_FALSE
    ,x_return_status => l_return_status
    ,x_msg_count     => l_msg_count
    ,x_msg_data      => l_msg_data
    ,p_obj_name      => p_target_obj_name
    ,p_obj_id        => x_target_obj_id
  );

  if (l_return_status = FND_API.G_RET_STS_ERROR) then
    raise FND_API.G_EXC_ERROR;
  elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 3: Copy Object Record
  ------------------------------------------------------------------------------
  CopyObjectRec (
    p_source_obj_id    => p_source_obj_id
    ,p_target_obj_id   => x_target_obj_id
    ,p_target_obj_name => p_target_obj_name
    ,p_target_obj_desc => p_target_obj_desc
    ,p_created_by      => p_created_by
    ,p_creation_date   => p_creation_date
  );

  DuplicateObjectDetails (
    p_object_type_code => p_object_type_code
    ,p_source_obj_id   => p_source_obj_id
    ,p_target_obj_id   => x_target_obj_id
    ,x_return_status   => l_return_status
    ,x_msg_count       => l_msg_count
    ,x_msg_data        => l_msg_data
  );

  if (l_return_status = FND_API.G_RET_STS_ERROR) then
    raise FND_API.G_EXC_ERROR;
  elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 4: Copy Object Definition Record
  ------------------------------------------------------------------------------
  -- No need to check object definition as we just created a new object
  CopyObjectDefinitionRec (
    p_source_obj_def_id            => p_source_obj_def_id
    ,p_target_obj_def_id           => x_target_obj_def_id
    ,p_target_obj_id               => x_target_obj_id
    ,p_target_obj_def_name         => p_target_obj_def_name
    ,p_target_obj_def_desc         => p_target_obj_def_desc
    ,p_target_start_date           => l_target_start_date
    ,p_target_end_date             => l_target_end_date
    ,p_target_copy_flag            => G_CURRENT_COPY
    ,p_target_copy_obj_def_id      => null
    ,p_created_by                  => p_created_by
    ,p_creation_date               => p_creation_date
  );

  -- Override approval status
  SetApprovalStatus (
    p_obj_def_id            => x_target_obj_def_id
    ,p_approval_status_code => p_target_approval_status_code
    ,p_approver_user_id     => p_target_approved_by
    ,p_approval_date        => p_target_approval_date
  );

  ------------------------------------------------------------------------------
  -- STEP 5: Duplicate Object Definition Details
  ------------------------------------------------------------------------------
  -- Now only copy the Detail records
  CopyObjectDefinitionInternal (
    p_copy_type_code     => G_DUPLICATE
    ,p_object_type_code  => p_object_type_code
    ,p_source_obj_def_id => p_source_obj_def_id
    ,p_target_obj_def_id => x_target_obj_def_id
    ,p_target_copy_flag  => G_CURRENT_COPY
    ,p_is_full_copy      => false
    ,p_is_new_copy       => true
  );

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to DuplicateObject_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to DuplicateObject_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to DuplicateObject_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg (
        p_pkg_name        => G_PKG_NAME
        ,p_procedure_name => l_api_name
      );
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END DuplicateObject;


--
-- PROCEDURE
--   DuplicateObjectDetails
--
-- DESCRIPTION
--   Duplicates only the detail records of a Business Rule (source) into
--   another empty Business Rule (target).  It does not duplicate any of the
--   Business Rule Definition records.
--   NOTE:  It does not copy the Business Rule record in
--          FEM_OBJECT_CATALOG_VL.  That record must already exist.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_object_type_code    - Object Type Code
--   p_source_obj_id       - Source Object ID
--   p_target_obj_id       - Target Object ID
--
-- OUT
--   x_return_status       - Return Status of API Call
--   x_msg_count           - Total Count of Error Messages in API Call
--   x_msg_data            - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE DuplicateObjectDetails (
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_id                in number
  ,p_target_obj_id                in number
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'DuplicateObjectDetails';
  l_api_version          constant number       := 1.0;

BEGIN

  -- Standard Start of API Savepoint
  savepoint DuplicateObjectDetails_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CopyObjectDetailsInternal (
    p_copy_type_code    => G_DUPLICATE
    ,p_object_type_code => p_object_type_code
    ,p_source_obj_id    => p_source_obj_id
    ,p_target_obj_id    => p_target_obj_id
  );

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to DuplicateObjectDetails_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to DuplicateObjectDetails_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to DuplicateObjectDetails_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END DuplicateObjectDetails;


--
-- PROCEDURE
--   CheckOverlapObjDefs
--
-- DESCRIPTION
--   Checks if the specified effective dates will overlap with existing
--   object definitions under the same parent object.  If this check is for
--   updating the effective dates of an existing object definition, this
--   object definition must be excluded from the overlap check.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_obj_id               - Object ID
--   p_exclude obj_def_id   - Object Definition ID to exclude from check
--   p_effective_start_date - The new effective start date
--   p_effective_end_date   - The new effective end date
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE CheckOverlapObjDefs(
  p_api_version                   in number := 1.0
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_obj_id                       in number
  ,p_exclude_obj_def_id           in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'CheckOverlapObjDefs';
  l_api_version          constant number       := 1.0;

BEGIN

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CheckOverlapObjDefsInternal(
    p_obj_id                  => p_obj_id
    ,p_exclude_obj_def_id     => p_exclude_obj_def_id
    ,p_effective_start_date   => p_effective_start_date
    ,p_effective_end_date     => p_effective_end_date
    ,p_action_type            => G_UNDEF_ACTION_TYPE
  );

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END CheckOverlapObjDefs;


--
-- FUNCTION
--   GetDefaultStartDate
--
-- DESCRIPTION
--   Returns the default start date stored in the profile options table.  If
--   none is specified, use the defaulted value.
--
-- RETURN
--   x_default_start_date   - Default Effective Start Date
--
--------------------------------------------------------------------------------
FUNCTION GetDefaultStartDate
RETURN date
--------------------------------------------------------------------------------
IS

  l_api_name            constant varchar2(30) := 'GetDefaultStartDate';
  l_default_start_date  date;

BEGIN

  l_default_start_date := nvl(
   GetProfileOptionDateValue('FEM_EFFECTIVE_START_DATE')
    ,G_DEFAULT_START_DATE_NULL
  );

  return l_default_start_date;

END GetDefaultStartDate;


--
-- FUNCTION
--   GetDefaultEndDate
--
-- DESCRIPTION
--   Returns the default end date stored in the profile options table.  If
--   none is specified, use the defaulted value.
--
-- RETURN
--   x_default_end_date     - Default Effective End Date
--
--------------------------------------------------------------------------------
FUNCTION GetDefaultEndDate
RETURN date
--------------------------------------------------------------------------------
IS

  l_api_name            constant varchar2(80) := 'GetDefaultEndDate';
  l_default_end_date    date;

BEGIN

  l_default_end_date := nvl(
    GetProfileOptionDateValue('FEM_EFFECTIVE_END_DATE')
    ,G_DEFAULT_END_DATE_NULL
  );

  return l_default_end_date;

END GetDefaultEndDate;


--
-- PROCEDURE
--   CheckObjectName
--
-- DESCRIPTION
--   Checks that a new or updated Object does not have the same name as other
--   existing Object records.
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_obj_name             - Object Name
--   p_obj_id               - Object ID (optional)
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE CheckObjectName (
  p_api_version                   in number
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ,p_obj_name                     in varchar2
  ,p_obj_id                       in number
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'CheckObjectName';
  l_api_version          constant number       := 1.0;

  cursor l_check_obj_name_cur is
    select obj.object_id
    ,typ.object_type_name
    , f.folder_name
    , obj.object_name
    from fem_object_catalog_vl obj
    ,fem_folders_vl f
    ,fem_object_types_vl typ
    where upper(obj.object_name) = upper(p_obj_name)
    and obj.object_id <> nvl(p_obj_id,-1)
    and f.folder_id = obj.folder_id
    and typ.object_type_code = obj.object_type_code;

BEGIN

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for l_check_obj_name_rec in l_check_obj_name_cur loop

    -- If a record is returned in the l_check_obj_name_cur, then another
    -- object exists with the same name.
    FND_MESSAGE.set_name('FEM', 'FEM_BR_OBJ_NAME_ERR');
    FND_MESSAGE.set_token('OBJECT_TYPE_MEANING', l_check_obj_name_rec.object_type_name);
    FND_MESSAGE.set_token('FOLDER_NAME', l_check_obj_name_rec.folder_name);
    FND_MESSAGE.set_token('OBJECT_NAME', l_check_obj_name_rec.object_name);
    FND_MSG_PUB.Add;

    raise FND_API.G_EXC_ERROR;

  end loop;

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END CheckObjectName;


--
-- PROCEDURE
--   CheckObjectDefinitionName
--
-- DESCRIPTION
--   Checks that a new or updated Object Definition does not have the same
--   name as other existing Object Definition records that all belong to the
--   same Object.
--
-- IN
--   p_api_version          - API version
--   p_init_msg_list        - Initialize Message List (boolean)
--   p_obj_def_name         - Object Definition Name
--   p_obj_id               - Object ID
--   p_obj_def_id           - Object Definition ID (optional)
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
--------------------------------------------------------------------------------
PROCEDURE CheckObjectDefinitionName (
  p_api_version                   in number
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy  number
  ,x_msg_data                     out nocopy  varchar2
  ,p_obj_def_name                 in varchar2
  ,p_obj_id                       in number
  ,p_obj_def_id                   in number
)
--------------------------------------------------------------------------------
IS

  l_api_name              constant varchar2(30) := 'CheckObjectDefinitionName';
  l_api_version          constant number       := 1.0;

  cursor l_check_obj_def_name_cur is
    select def.object_definition_id as obj_def_id
    ,def.display_name as obj_def_name
    ,def.object_id
    ,obj.object_name
    from fem_object_definition_vl def
    ,fem_object_catalog_vl obj
    where upper(def.display_name) = upper(p_obj_def_name)
    and def.object_id = p_obj_id
    and def.old_approved_copy_flag = G_CURRENT_COPY
    and def.object_definition_id <> nvl(p_obj_def_id,-1)
    and obj.object_id = def.object_id;

BEGIN

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for l_check_obj_def_name_rec in l_check_obj_def_name_cur loop

    -- If a record is returned in the l_check_obj_def_name_cur, then another
    -- object definition exists with the same name.
    FND_MESSAGE.set_name('FEM', 'FEM_BR_OBJ_DEF_NAME_ERR');
    FND_MESSAGE.set_token('OBJECT_DEFINITION_NAME', l_check_obj_def_name_rec.obj_def_name);
    FND_MSG_PUB.Add;

    raise FND_API.G_EXC_ERROR;

  end loop;

  -----------------------
  -- Finalize API Call --
  -----------------------
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END CheckObjectDefinitionName;

 --
 -- FUNCTION
 --   ObjDefDataEditLockExists
 --
 -- DESCRIPTION
 --   Check if data lock exists for the object definition
 --
 -- IN
 --   p_obj_def_id           - Object Definition ID
 --
 -- OUT
 --   l_lock_exists          - Lock Exists (T - True, F - False)
 --
 --------------------------------------------------------------------------------
 FUNCTION ObjDefDataEditLockExists (
   p_obj_def_id                   in number
 ) RETURN varchar2
 --------------------------------------------------------------------------------
 IS

  l_lock_exists                   varchar2(1);

 BEGIN

   FEM_PL_PKG.obj_def_data_edit_lock_exists (
     p_object_definition_id   => p_obj_def_id
     ,x_data_edit_lock_exists => l_lock_exists
   );

   return l_lock_exists;

 EXCEPTION

   when others then
     return null;

 END ObjDefDataEditLockExists;


--
-- FUNCTION
--   GetNewObjId
--
-- DESCRIPTION
--   Getter for the FEM_OBJECT_CATALOG_ID_SEQ database sequence.
--
-- RETURNS
--   obj_id                 - Object Definition ID
--
--------------------------------------------------------------------------------
FUNCTION GetNewObjId
RETURN number
--------------------------------------------------------------------------------
IS

  l_obj_id                        number;

BEGIN

  select fem_object_id_seq.NEXTVAL
  into l_obj_id
  from dual;

  return l_obj_id;

END GetNewObjId;


--
-- FUNCTION
--   GetNewObjDefId
--
-- DESCRIPTION
--   Getter for the FEM_OBJECT_DEFINITION_ID_SEQ database sequence.
--
-- RETURNS
--   obj_def_id             - Object Definition ID
--
--------------------------------------------------------------------------------
FUNCTION GetNewObjDefId
RETURN number
--------------------------------------------------------------------------------
IS

  l_obj_def_id                    number;

BEGIN

  select fem_object_definition_id_seq.NEXTVAL
  into l_obj_def_id
  from dual;

  return l_obj_def_id;

END GetNewObjDefId;


--
-- FUNCTION
--   GetRulesetIsetupImpExpFlag
--
-- DESCRIPTION
--   Getter for obtaining the iSetup import/export flag for the
--   specified rule set object definition.
--
-- IN
--   p_obj_def_id                 - Rule Set Object Definition ID
--
-- RETURNS
--   isetup_import_export_flag    - iSetup Import/Export Flag
--
--------------------------------------------------------------------------------
FUNCTION GetRulesetIsetupImpExpFlag (
  p_ruleset_obj_def_id           in number
)
RETURN varchar2
--------------------------------------------------------------------------------
IS

  l_isetup_import_export_flag     varchar2(1);

BEGIN

  select rs_type.isetup_import_export_flag
  into l_isetup_import_export_flag
  from fem_rule_sets rs
  ,fem_object_types_b rs_type
  where rs.rule_set_obj_def_id = p_ruleset_obj_def_id
  and rs_type.object_type_code = rs.rule_set_object_type_code;

  return l_isetup_import_export_flag;

EXCEPTION

  when others then
    return null;

END GetRulesetIsetupImpExpFlag;


--
-- FUNCTION
--   GetObjectId
--
-- DESCRIPTION
--   Getter for obtaining the object ID of the specified object definition ID.
--
-- IN
--   p_obj_def_id           - Object Defintion ID
--
-- RETURNS
--    obj_id                - Object ID
--
--------------------------------------------------------------------------------
FUNCTION GetObjectId(
  p_obj_def_id              in          number
)
RETURN number
--------------------------------------------------------------------------------
IS

  l_obj_id                  number;

BEGIN

  select object_id
  into l_obj_id
  from fem_object_definition_b
  where object_definition_id = p_obj_def_id;

  return l_obj_id;

EXCEPTION

  when others then
    return null;

END GetObjectId;


--
-- FUNCTION
--   GetOldApprovedObjDefId
--
-- DESCRIPTION
--   Getter for obtaining the old approved copy object definition id of the
--   specified object definition.
--
-- IN
--   p_obj_def_id               - Object Definition ID
--
-- RETURNS
--   old_approved_obj_def_id    - Old Approved Object Definition ID
--
--------------------------------------------------------------------------------
FUNCTION GetOldApprovedObjDefId(
  p_obj_def_id              in          number
)
RETURN number
--------------------------------------------------------------------------------
IS

  l_old_approved_obj_def_id number;
  l_api_name             constant varchar2(30) := 'GetOldApprovedObjDefId';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);

BEGIN
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN, p_obj_def_id:' || p_obj_def_id
  );

  select old_approved_copy_obj_def_id
  into l_old_approved_obj_def_id
  from fem_object_definition_b
  where old_approved_copy_flag = G_CURRENT_COPY
  and object_definition_id = p_obj_def_id;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'END'
  );

  return l_old_approved_obj_def_id;

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
    return null;

END GetOldApprovedObjDefId;



------------------------
-- Workflow Approvals --
------------------------

--
-- PROCEDURE
--   SetSubmittedState
--
-- DESCRIPTION
--   Sets all the business rule definitions in a workflow request to the
--   submitted state.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
-- USED BY
--   FEM_FEMAPPR_ITEM_TYPE  SetSubmittedState()
--
--------------------------------------------------------------------------------
PROCEDURE SetSubmittedState(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'SetSubmittedState';

  l_request_type_code       t_code%TYPE;
  l_request_item_code       t_code%TYPE;
  l_request_id              t_request_id%TYPE;

  l_approval_status_code    t_approval_status_code%TYPE;

BEGIN

  l_request_type_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_TYPE_CODE);

  if (l_request_type_code = G_APPROVAL_TYPE) then

    l_approval_status_code := G_SUBMIT_APPROVAL_STATUS;

  elsif (l_request_type_code = G_DELETE_TYPE) then

    l_approval_status_code := G_SUBMIT_DELETE_STATUS;

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approval Request Type: '||l_request_type_code);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  l_request_item_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

  for req_obj_def_rec in req_obj_defs_cur(
    l_request_id
    ,l_request_item_code
    ,l_request_type_code) loop

    SetApprovalStatus(
      p_obj_def_id              => req_obj_def_rec.object_definition_id
      ,p_approval_status_code   => l_approval_status_code
    );

  end loop;

END SetSubmittedState;


--
-- PROCEDURE
--   SetApprovedState
--
-- DESCRIPTION
--   Sets all the business rule definitions in a workflow request to the
--   approved state.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
-- USED BY
--   FEM_FEMAPPR_ITEM_TYPE  SetApprovedState()
--
--------------------------------------------------------------------------------
PROCEDURE SetApprovedState(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'SetApprovedState';

  l_request_id              t_request_id%TYPE;
  l_request_item_code       t_code%TYPE;
  l_request_type_code       t_code%TYPE;
  l_approver_user_id        t_id%TYPE;

  l_return_status           t_return_status%TYPE;
  l_msg_count               t_msg_count%TYPE;
  l_msg_data                t_msg_data%TYPE;

BEGIN

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  l_request_item_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

  l_request_type_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_TYPE_CODE);

  l_approver_user_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_APPROVER_USER_ID);

  if (l_request_type_code = G_APPROVAL_TYPE) then

    for req_obj_def_rec in req_obj_defs_cur(
      l_request_id
      ,l_request_item_code
      ,l_request_type_code) loop

      SetApprovalStatus(
        p_obj_def_id            => req_obj_def_rec.object_definition_id
        ,p_approval_status_code => G_APPROVED_STATUS
        ,p_approver_user_id     => l_approver_user_id
        ,p_approval_date        => sysdate
      );

    end loop;

  elsif (l_request_type_code = G_DELETE_TYPE) then

    for req_obj_def_rec in req_obj_defs_cur(
      l_request_id
      ,l_request_item_code
      ,l_request_type_code) loop

      DeleteObjectDefinition(
        p_object_type_code => req_obj_def_rec.object_type_code
        ,p_obj_def_id      => req_obj_def_rec.object_definition_id
        ,x_return_status   => l_return_status
        ,x_msg_count       => l_msg_count
        ,x_msg_data        => l_msg_data
        ,p_process_type    => G_WORKFLOW
      );

      if (l_return_status = FND_API.G_RET_STS_ERROR) then
        raise FND_API.G_EXC_ERROR;
      elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

    end loop;

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approval Request Type: '||l_request_type_code);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END SetApprovedState;


--
-- PROCEDURE
--   SetRejectedState
--
-- DESCRIPTION
--   Sets all the business rule definitions in a workflow request to the
--   rejected state.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
-- USED BY
--   FEM_FEMAPPR_ITEM_TYPE  SetRejectedState()
--
--------------------------------------------------------------------------------
PROCEDURE SetRejectedState(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'SetRejectedState';

  l_request_id              t_request_id%TYPE;
  l_request_item_code       t_code%TYPE;
  l_request_type_code       t_code%TYPE;

BEGIN

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  l_request_item_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

  l_request_type_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_TYPE_CODE);

  if (l_request_type_code in (G_APPROVAL_TYPE, G_DELETE_TYPE)) then

    for req_obj_def_rec in req_obj_defs_cur(
      l_request_id
      ,l_request_item_code
      ,l_request_type_code) loop

      -- Set to the previous approval status
      SetApprovalStatus(
        p_obj_def_id            => req_obj_def_rec.object_definition_id
        ,p_approval_status_code => req_obj_def_rec.prev_approval_status_code
      );

    end loop;

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approval Request Type: '||l_request_type_code);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END SetRejectedState;


--
-- FUNCTION
--   CheckApprovalItems
--
-- DESCRIPTION
--   Checks to see if a workflow request contains any business rule
--   definitions.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
-- RETURNS
--   approval_items_exist   - Approval Items Exist Flag (YES, NO)
--
-- USED BY
--   FEM_FEMAPPR_ITEM_TYPE  CheckApprovalItems()
--
--------------------------------------------------------------------------------
FUNCTION CheckApprovalItems(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
)
RETURN varchar2
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'CheckApprovalItems';

  l_request_id              t_request_id%TYPE;
  l_request_type_code       t_code%TYPE;
  l_request_item_code       t_code%TYPE;

  l_count                   number;

BEGIN

  l_request_type_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_TYPE_CODE);

  if (l_request_type_code in (G_APPROVAL_TYPE, G_DELETE_TYPE)) then

    l_request_item_code := WF_ENGINE.GetItemAttrText(
      p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

    l_request_id := WF_ENGINE.GetItemAttrNumber(
      p_item_type, p_item_key, G_REQUEST_ID);

    l_count := GetObjectDefinitionsCount(
      p_request_id          => l_request_id
      ,p_request_item_code  => l_request_item_code
      ,p_request_type_code  => l_request_type_code
    );

    if (l_count > 0) then
      return G_YES;
    else
      return G_NO;
    end if;

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approval Request Type: '||l_request_type_code);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END CheckApprovalItems;


--
-- PROCEDURE
--   InitApprovalItems
--
-- DESCRIPTION
--   Initializes the workflow item attributes with information from the
--   object definitions in a workflow request
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
-- USED BY
--   FEM_FEMAPPR_ITEM_TYPE  InitApprovalItems()
--
--------------------------------------------------------------------------------
PROCEDURE InitApprovalItems(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'InitApprovalItems';

  l_request_id              t_request_id%TYPE;
  l_request_type_code       t_code%TYPE;
  l_request_item_code       t_code%TYPE;

  l_url                             t_url%TYPE;
  l_obj_def_id                      t_object_definition_id%TYPE;
  l_old_approved_copy_obj_def_id    t_object_definition_id%TYPE;

BEGIN

  l_request_type_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_TYPE_CODE);

  l_request_item_code := WF_ENGINE.GetItemAttrText(
    p_item_type, p_item_key, G_REQUEST_ITEM_CODE);

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  if (l_request_type_code in (G_APPROVAL_TYPE, G_DELETE_TYPE)) then

    for info_obj_def_rec in info_obj_defs_cur(
      l_request_id
      ,l_request_item_code
      ,l_request_type_code) loop

      l_obj_def_id := info_obj_def_rec.object_definition_id;

      WF_ENGINE.SetItemAttrNumber(
        p_item_type
        ,p_item_key
        ,G_OBJECT_DEFINITION_ID
        ,l_obj_def_id
      );

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_OBJECT_DEFINITION_NAME
        ,info_obj_def_rec.object_definition_name
      );

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_OBJECT_NAME
        ,info_obj_def_rec.object_name
      );

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_OBJECT_TYPE_CODE
        ,info_obj_def_rec.object_type_code
      );

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_OBJECT_TYPE
        ,info_obj_def_rec.object_type_name
      );

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_FOLDER_NAME
        ,info_obj_def_rec.folder_name
      );

      l_url :=
        G_URL_FUNCTION || info_obj_def_rec.view_only_oa_function_name ||
        G_URL_PAGE_MODE_VIEW ||
        G_URL_FOLDER_ID || info_obj_def_rec.folder_id ||
        G_URL_OBJ_DEF_ID;

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_URL_SUBMITTED
        ,l_url || to_char(l_obj_def_id)
      );

      WF_ENGINE.SetItemAttrText(
        p_item_type
        ,p_item_key
        ,G_URL_REJECTED
        ,l_url || to_char(l_obj_def_id)
      );

      if (l_request_type_code = G_APPROVAL_TYPE) then

        WF_ENGINE.SetItemAttrText(
          p_item_type
          ,p_item_key
          ,G_URL_APPROVED
          ,l_url || to_char(l_obj_def_id)
        );

        if (info_obj_def_rec.old_approved_copy_obj_def_id is not null) then

          WF_ENGINE.SetItemAttrText(
            p_item_type
            ,p_item_key
            ,G_URL_ORIGINAL
            ,l_url || to_char(info_obj_def_rec.old_approved_copy_obj_def_id)
        );

        end if;

      elsif (l_request_type_code = G_DELETE_TYPE) then

        null;

      end if;

    end loop;

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Approval Request Type: '||l_request_type_code);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END InitApprovalItems;


--
-- PROCEDURE
--   PurgeApprovalRequest
--
-- DESCRIPTION
--   Deletes all the appropriate approval request records from the
--   FEM_WF_REQ_OBJECT_DEFS table.
--
-- IN
--   p_item_type            - The workflow item type (FEMAPPR)
--   p_item_key             - The workflow request id (FEM_WF_REQUEST_ID_SEQ)
--
-- USED BY
--   FEM_FEMAPPR_ITEM_TYPE  PurgeApprovalRequest()
--
--------------------------------------------------------------------------------
PROCEDURE PurgeApprovalRequest (
  p_item_type                     in varchar2
  ,p_item_key                     in varchar2
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'PurgeApprovalItems';

  l_request_id              t_request_id%TYPE;

BEGIN

  l_request_id := WF_ENGINE.GetItemAttrNumber(
    p_item_type, p_item_key, G_REQUEST_ID);

  if (l_request_id is not null) then

    delete from fem_wf_req_object_defs
    where wf_request_id = l_request_id;

  end if;

END PurgeApprovalRequest;



--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--   SetApprovalStatus
--
-- DESCRIPTION
--   Sets the approval status of an object defintion id.  Can also set the
--   approver's user id and the approval date.
--
-- IN
--   p_obj_def_id           - Object Definition ID
--   p_approval_status_code - Approval Status Code (APPROVED, NOT_APPROVED, etc)
--   p_approver_user_id     - FND User ID of the approver (Optional)
--   p_approval_date        - Approval Date (Optional)
--
--------------------------------------------------------------------------------
PROCEDURE SetApprovalStatus (
  p_obj_def_id                    in number
  ,p_approval_status_code         in varchar2 := FND_API.G_MISS_CHAR
  ,p_approver_user_id             in number := FND_API.G_MISS_NUM
  ,p_approval_date                in date := FND_API.G_MISS_DATE
)
--------------------------------------------------------------------------------
IS
  l_api_name             constant varchar2(30) := 'SetApprovalStatus';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);
BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN, p_obj_def_id:' || p_obj_def_id
    || ' p_approval_status_code:' || p_approval_status_code
    || ' p_approver_user_id:' || p_approver_user_id
    || ' p_approval_date:' || p_approval_date
  );

  update fem_object_definition_b
  set approval_status_code =
    decode(p_approval_status_code
      ,FND_API.G_MISS_CHAR,approval_status_code
      ,p_approval_status_code)
  ,approved_by =
    decode(p_approver_user_id
      ,FND_API.G_MISS_NUM,approved_by
      ,p_approver_user_id)
  ,approval_date =
    decode(p_approval_date
      ,FND_API.G_MISS_DATE,approval_date
      ,p_approval_date)
  ,last_updated_by = FND_GLOBAL.user_id
  ,last_update_date = sysdate
  ,last_update_login = FND_GLOBAL.login_id
  where object_definition_id = p_obj_def_id;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
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
    RAISE;

END SetApprovalStatus;


--
-- FUNCTION
--   GetApprovalStatus
--
-- DESCRIPTION
--   Gets the approval status of an object defintion id.
--
-- IN
--   p_obj_def_id           - Object Definition ID
--
-- RETURNS
--   approval_status_code   - Approval Status Code (APPROVED, NOT_APPROVED, etc)
--
--------------------------------------------------------------------------------
FUNCTION GetApprovalStatus(
  p_obj_def_id              in          number
)
RETURN varchar2
--------------------------------------------------------------------------------
IS

  l_approval_status_code    t_approval_status_code%TYPE;

BEGIN

  select approval_status_code
  into l_approval_status_code
  from fem_object_definition_b
  where object_definition_id = p_obj_def_id;

  return l_approval_status_code;

EXCEPTION

  when others then
    return null;

END GetApprovalStatus;


--
-- FUNCTION
--   GetObjectPlsqlPkgName
--
-- DESCRIPTION
--   Gets the PL/SQL package name for a business rule with the specified
--   object type code.
--
-- IN
--   p_object_type_code     - Object Type Code
--
-- RETURNS
--   package_name           - PL/SQL Package Name (FEM_BR_MAPPING_RULE_PVT, etc)
--
--------------------------------------------------------------------------------
FUNCTION GetObjectPlsqlPkgName(
  p_object_type_code        in          varchar2
)
RETURN varchar2
--------------------------------------------------------------------------------
IS

  l_package_name            t_plsql_pkg_name%TYPE;
  l_api_name             constant varchar2(30) := 'GetObjectPlsqlPkgName';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN, p_object_type_code:' || p_object_type_code
  );
  select object_plsql_pkg_name
  into l_package_name
  from fem_object_types
  where object_type_code = p_object_type_code;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'END'
  );

  return l_package_name;

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
    RAISE;

END GetObjectPlsqlPkgName;


--
-- PROCEDURE
--   CopyObjectDefinitionInternal
--
-- DESCRIPTION
--   Internal implementation for copying a source object definition into a
--   target object definition.  A full copy includes copying the records in
--   FEM_OBJECT_DEFINITIONS_VL.
--
-- IN
--   p_copy_type            - Copy Type
--   p_object_type_code     - Object Type Code
--   p_source_obj_def_id    - Source Object Definition ID
--   p_target_obj_def_id    - Target Object Definition ID
--   p_target_copy_flag     - Target's Old Approved Copy Flag value
--   p_is_full_copy         - Is Full Copy (include FEM_OBJECT_DEFINITION_VL)
--   p_is_new_copy          - Is New Copy (indicates new info in WHO columns)
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinitionInternal (
  p_copy_type_code                in varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_def_id            in number
  ,p_target_obj_def_id            in number
  ,p_target_copy_flag             in varchar2
  ,p_is_full_copy                 in boolean
  ,p_is_new_copy                  in boolean
)
--------------------------------------------------------------------------------
IS

  l_package_name            t_plsql_pkg_name%TYPE;
  l_dynamic_query           long;

  l_created_by              number;
  l_creation_date           date;

BEGIN

  l_created_by := null;
  l_creation_date := null;

  if (p_is_new_copy) then
    l_created_by := FND_GLOBAL.user_id;
    l_creation_date := sysdate;
  end if;

  if (p_is_full_copy) then

    CopyObjectDefinitionRec (
      p_source_obj_def_id  => p_source_obj_def_id
      ,p_target_obj_def_id => p_target_obj_def_id
      ,p_target_copy_flag  => p_target_copy_flag
      ,p_created_by        => l_created_by
      ,p_creation_date     => l_creation_date
    );

  end if;

  -- Copy the Object Dependency records (if they exist)
  CopyObjectDependencyRecs (
    p_source_obj_def_id  => p_source_obj_def_id
    ,p_target_obj_def_id => p_target_obj_def_id
    ,p_created_by        => l_created_by
    ,p_creation_date     => l_creation_date
  );

  -- Copy the Visual Tracing Object Definition Attribute record (if it exists)
  CopyVtObjDefAttrRec(
    p_source_obj_def_id  => p_source_obj_def_id
    ,p_target_obj_def_id => p_target_obj_def_id
    ,p_created_by        => l_created_by
    ,p_creation_date     => l_creation_date
  );

  l_package_name := GetObjectPlsqlPkgName(p_object_type_code);
  if (l_package_name is not null) then

    -- Bug Fix 4141575: Mapping Rules need support for copying Dependent Objects
    -- to handle Local Conditions.  This required adding the p_copy_type_code
    -- parameter to the CopyObjectDefinition() procedure that all Business Rules
    -- implement.  Until all other business rules update CopyObjectDefinition(),
    -- only allow Mapping Rules to call this new signature.
    if (p_object_type_code = 'MAPPING_RULE') then

      l_dynamic_query :=
      ' begin '||
          l_package_name||'.CopyObjectDefinition ('||
      '     p_copy_type_code     => :b_copy_type_code'||
      '     ,p_source_obj_def_id => :b_source_obj_def_id'||
      '     ,p_target_obj_def_id => :b_target_obj_def_id'||
      '     ,p_created_by        => :b_created_by'||
      '     ,p_creation_date     => :b_creation_date'||
      '   );'||
      ' end;';

      execute immediate l_dynamic_query
      using p_copy_type_code
      ,p_source_obj_def_id
      ,p_target_obj_def_id
      ,l_created_by
      ,l_creation_date;

    else

      l_dynamic_query :=
      ' begin '||
          l_package_name||'.CopyObjectDefinition ('||
      '     p_source_obj_def_id  => :b_source_obj_def_id'||
      '     ,p_target_obj_def_id => :b_target_obj_def_id'||
      '     ,p_created_by        => :b_created_by'||
      '     ,p_creation_date     => :b_creation_date'||
      '   );'||
      ' end;';

      execute immediate l_dynamic_query
      using p_source_obj_def_id
      ,p_target_obj_def_id
      ,l_created_by
      ,l_creation_date;

    end if;

  end if;

END CopyObjectDefinitionInternal;


--
-- PROCEDURE
--   DeleteObjectDefinitionInternal
--
-- DESCRIPTION
--   Internal implementation for deleting an object definition.
--
-- IN
--   p_object_type_code     - Object Type Code
--   p_obj_def_id           - Object Definition ID
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinitionInternal(
  p_object_type_code        in          varchar2
  ,p_obj_def_id             in          number
)
--------------------------------------------------------------------------------
IS

  l_package_name            t_plsql_pkg_name%TYPE;
  l_dynamic_query           varchar2(2000);

  l_api_name             constant varchar2(30) := 'DeleteObjectDefinitionInternal';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN, p_object_type_code:' || p_object_type_code || ' p_obj_def_id:' || p_obj_def_id
  );

  -- NMARTINE -- Bug Fix 4141575 -- Must delete Object Dependencies before
  -- calling delete on Detail Records, otherwise Backup/Revert will not be
  -- able to delete a Local Condition.
  DeleteObjectDependencyRecs(p_obj_def_id);

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN1'
  );

  l_package_name := GetObjectPlsqlPkgName(p_object_type_code);

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN2, l_package_name:' || l_package_name
  );


  if (l_package_name is not null) then

    l_dynamic_query :=
    ' begin '||
        l_package_name||'.DeleteObjectDefinition(:p_obj_def_id);'||
    ' end;';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'|| l_api_name
      ,p_msg_text => 'BEGIN3, l_dynamic_query:' || l_dynamic_query
    );
    execute immediate l_dynamic_query
    using p_obj_def_id;

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN4'
  );
  -- Delete the Visual Tracing Object Definition Attribute record (if it exists)
  DeleteVtObjDefAttrRec(p_obj_def_id);

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN5'
  );

  DeleteObjectDefinitionRec(p_obj_def_id);
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
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
    RAISE;

END DeleteObjectDefinitionInternal;


--
-- PROCEDURE
--   CopyObjectDetailsInternal
--
-- DESCRIPTION
--   Internal implementation for copying only the detail records of a source
--   object into a target object.
--
-- IN
--   p_copy_type            - Copy Type
--   p_object_type_code     - Object Type Code
--   p_source_obj_id        - Source Object ID
--   p_target_obj_id        - Target Object ID
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDetailsInternal (
  p_copy_type_code                in varchar2
  ,p_object_type_code             in varchar2
  ,p_source_obj_id                in number
  ,p_target_obj_id                in number
)
--------------------------------------------------------------------------------
IS

  l_package_name            t_plsql_pkg_name%TYPE;
  l_dynamic_query           long;
  l_sql_err_code            number;

  l_created_by              number;
  l_creation_date           date;

BEGIN

  l_created_by := FND_GLOBAL.user_id;
  l_creation_date := sysdate;

  l_package_name := GetObjectPlsqlPkgName(p_object_type_code);
  if (l_package_name is not null) then

      l_dynamic_query :=
      ' begin '||
          l_package_name||'.CopyObjectDetails ('||
      '     p_copy_type_code => :b_copy_type_code'||
      '     ,p_source_obj_id => :b_source_obj_id'||
      '     ,p_target_obj_id => :b_target_obj_id'||
      '     ,p_created_by    => :b_created_by'||
      '     ,p_creation_date => :b_creation_date'||
      '   );'||
      ' end;';

      begin
        execute immediate l_dynamic_query
        using p_copy_type_code
        ,p_source_obj_id
        ,p_target_obj_id
        ,l_created_by
        ,l_creation_date;
      exception
        -- If the CopyObjectDetails API has not been implemented by a
        -- Business Rule, then catch the exception and do nothing.
        when G_PLSQL_COMPILATION_ERROR then null;
      end;

  end if;

END CopyObjectDetailsInternal;


--
-- PROCEDURE
--   DeleteObjectDetailsInternal
--
-- DESCRIPTION
--   Internal implementation for deleting only the detail records of an object.
--
-- IN
--   p_object_type_code     - Object Type Code
--   p_obj_id               - Object ID
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDetailsInternal(
  p_object_type_code        in          varchar2
  ,p_obj_id                 in          number
)
--------------------------------------------------------------------------------
IS

  l_package_name            t_plsql_pkg_name%TYPE;
  l_dynamic_query           varchar2(2000);

BEGIN
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| 'DeleteObjectDetailsInternal'
    ,p_msg_text => 'BEGIN, p_object_type_code:' || p_object_type_code || ' p_obj_id:' || p_obj_id
  );

  l_package_name := GetObjectPlsqlPkgName(p_object_type_code);

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| 'DeleteObjectDetailsInternal'
    ,p_msg_text => 'l_package_name:' || l_package_name
  );
  if (l_package_name is not null) then

    l_dynamic_query :=
    ' begin '||
        l_package_name||'.DeleteObjectDetails(:p_obj_id);'||
    ' end;';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_3
      ,p_module   => G_BLOCK||'.'|| 'DeleteObjectDetailsInternal'
      ,p_msg_text => 'l_dynamic_query:' || l_dynamic_query
      );
    begin
      execute immediate l_dynamic_query
      using p_obj_id;
    exception
      -- If the DeleteObjectDetails API has not been implemented by a
      -- Business Rule, then catch the exception and do nothing.
      when G_PLSQL_COMPILATION_ERROR then null;
    end;

    -- Bug#6496686 -- Begin
    l_dynamic_query :=
    ' begin '||
        l_package_name||'.DeleteTuningOptionDetails(:p_obj_id);'||
    ' end;';

    begin
      execute immediate l_dynamic_query
      using p_obj_id;
    exception
      -- If the DeleteTuningOptionDetails API has not been implemented by a
      -- Business Rule, then catch the exception and do nothing.
      when G_PLSQL_COMPILATION_ERROR then null;
    end;
    -- Bug#6496686 -- End

  end if;

END DeleteObjectDetailsInternal;


--
-- PROCEDURE
--   CopyObjectRec
--
-- DESCRIPTION
--   Creates a new Object by copying records in the FEM_OBJECT_CATALOG_VL
--   table.
--
-- IN
--   p_source_obj_id        - Source Object ID
--   p_target_obj_id        - Target Object ID
--   p_target_obj_name      - Target Object Name
--   p_target_obj_desc      - Target Object Description
--   p_created_by           - Created By (FND User ID).
--   p_creation_date        - Creation Date.
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectRec (
  p_source_obj_id                 in number
  ,p_target_obj_id                in number
  ,p_target_obj_name              in varchar2
  ,p_target_obj_desc              in varchar2 := FND_API.G_MISS_CHAR
  ,p_created_by                   in number
  ,p_creation_date                in date
)
--------------------------------------------------------------------------------
IS

  l_api_name             constant varchar2(30) := 'CopyObjectRec';

  l_obj_vl_rec                    fem_object_catalog_vl%ROWTYPE;
  l_rowid                         rowid;

BEGIN

  select p_target_obj_id
  ,object_type_code
  ,folder_id
  ,local_vs_combo_id
  ,object_access_code
  ,object_origin_code
  ,p_target_obj_name
  ,decode(p_target_obj_desc,FND_API.G_MISS_CHAR,description,p_target_obj_desc)
  ,nvl(p_creation_date,creation_date)
  ,nvl(p_created_by,created_by)
  ,sysdate
  ,FND_GLOBAL.user_id
  ,FND_GLOBAL.login_id
  ,object_version_number
  into l_obj_vl_rec.object_id
  ,l_obj_vl_rec.object_type_code
  ,l_obj_vl_rec.folder_id
  ,l_obj_vl_rec.local_vs_combo_id
  ,l_obj_vl_rec.object_access_code
  ,l_obj_vl_rec.object_origin_code
  ,l_obj_vl_rec.object_name
  ,l_obj_vl_rec.description
  ,l_obj_vl_rec.creation_date
  ,l_obj_vl_rec.created_by
  ,l_obj_vl_rec.last_update_date
  ,l_obj_vl_rec.last_updated_by
  ,l_obj_vl_rec.last_update_login
  ,l_obj_vl_rec.object_version_number
  from fem_object_catalog_vl
  where object_id  = p_source_obj_id;

  FEM_OBJECT_CATALOG_PKG.Insert_Row (
    x_rowid                         => l_rowid
    ,x_object_id                    => l_obj_vl_rec.object_id
    ,x_object_type_code             => l_obj_vl_rec.object_type_code
    ,x_folder_id                    => l_obj_vl_rec.folder_id
    ,x_local_vs_combo_id            => l_obj_vl_rec.local_vs_combo_id
    ,x_object_access_code           => l_obj_vl_rec.object_access_code
    ,x_object_origin_code           => l_obj_vl_rec.object_origin_code
    ,x_object_name                  => l_obj_vl_rec.object_name
    ,x_description                  => l_obj_vl_rec.description
    ,x_creation_date                => l_obj_vl_rec.creation_date
    ,x_created_by                   => l_obj_vl_rec.created_by
    ,x_last_update_date             => l_obj_vl_rec.last_update_date
    ,x_last_updated_by              => l_obj_vl_rec.last_updated_by
    ,x_last_update_login            => l_obj_vl_rec.last_update_login
    ,x_object_version_number        => l_obj_vl_rec.object_version_number
  );

END CopyObjectRec;


--
-- PROCEDURE
--   CopyObjectDefinitionRec
--
-- DESCRIPTION
--   Creates a new Object Definition by copying records in the
--   FEM_OBJECT_DEFINITION_VL table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID
--   p_target_obj_def_id    - Target Object Definition ID
--   p_target_copy_flag     - Target's Old Approved Copy Flag value
--   p_created_by           - Created By (FND User ID).
--   p_creation_date        - Creation Date.
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinitionRec (
  p_source_obj_def_id             in number
  ,p_target_obj_def_id            in number
  ,p_target_obj_id                in number := FND_API.G_MISS_NUM
  ,p_target_obj_def_name          in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_obj_def_desc          in varchar2 := FND_API.G_MISS_CHAR
  ,p_target_start_date            in date := FND_API.G_MISS_DATE
  ,p_target_end_date              in date := FND_API.G_MISS_DATE
  ,p_target_copy_flag             in varchar2
  ,p_target_copy_obj_def_id       in number := FND_API.G_MISS_NUM
  ,p_created_by                   in number
  ,p_creation_date                in date
)
--------------------------------------------------------------------------------
IS

  l_api_name                constant varchar2(30) := 'CopyObjectDefinitionRec';

  l_obj_def_vl_rec          fem_object_definition_vl%ROWTYPE;
  l_rowid                   rowid;

BEGIN

  if (p_target_copy_flag in (G_CURRENT_COPY, G_OLD_APPROVED_COPY)) then


    select p_target_obj_def_id
    ,decode(p_target_obj_id,FND_API.G_MISS_NUM,object_id,p_target_obj_id)
    ,decode(p_target_start_date,FND_API.G_MISS_DATE,effective_start_date,p_target_start_date)
    ,decode(p_target_end_date,FND_API.G_MISS_DATE,effective_end_date,p_target_end_date)
    ,object_origin_code
    ,approval_status_code
    ,approved_by
    ,approval_date
    ,p_target_copy_flag
    ,decode(p_target_copy_obj_def_id,FND_API.G_MISS_NUM,old_approved_copy_obj_def_id,p_target_copy_obj_def_id)
    ,decode(p_target_obj_def_name,FND_API.G_MISS_CHAR,display_name,p_target_obj_def_name)
    ,decode(p_target_obj_def_desc,FND_API.G_MISS_CHAR,description,p_target_obj_def_desc)
    ,nvl(p_creation_date,creation_date)
    ,nvl(p_created_by,created_by)
    ,sysdate
    ,FND_GLOBAL.user_id
    ,FND_GLOBAL.login_id
    ,object_version_number
    into l_obj_def_vl_rec.object_definition_id
    ,l_obj_def_vl_rec.object_id
    ,l_obj_def_vl_rec.effective_start_date
    ,l_obj_def_vl_rec.effective_end_date
    ,l_obj_def_vl_rec.object_origin_code
    ,l_obj_def_vl_rec.approval_status_code
    ,l_obj_def_vl_rec.approved_by
    ,l_obj_def_vl_rec.approval_date
    ,l_obj_def_vl_rec.old_approved_copy_flag
    ,l_obj_def_vl_rec.old_approved_copy_obj_def_id
    ,l_obj_def_vl_rec.display_name
    ,l_obj_def_vl_rec.description
    ,l_obj_def_vl_rec.creation_date
    ,l_obj_def_vl_rec.created_by
    ,l_obj_def_vl_rec.last_update_date
    ,l_obj_def_vl_rec.last_updated_by
    ,l_obj_def_vl_rec.last_update_login
    ,l_obj_def_vl_rec.object_version_number
    from fem_object_definition_vl
    where object_definition_id  = p_source_obj_def_id;

    FEM_OBJECT_DEFINITION_PKG.Insert_Row (
      x_rowid                         => l_rowid
      ,x_object_definition_id         => l_obj_def_vl_rec.object_definition_id
      ,x_object_id                    => l_obj_def_vl_rec.object_id
      ,x_effective_start_date         => l_obj_def_vl_rec.effective_start_date
      ,x_effective_end_date           => l_obj_def_vl_rec.effective_end_date
      ,x_object_origin_code           => l_obj_def_vl_rec.object_origin_code
      ,x_approval_status_code         => l_obj_def_vl_rec.approval_status_code
      ,x_approved_by                  => l_obj_def_vl_rec.approved_by
      ,x_approval_date                => l_obj_def_vl_rec.approval_date
      ,x_old_approved_copy_flag       => l_obj_def_vl_rec.old_approved_copy_flag
      ,x_old_approved_copy_obj_def_id => l_obj_def_vl_rec.old_approved_copy_obj_def_id
      ,x_display_name                 => l_obj_def_vl_rec.display_name
      ,x_description                  => l_obj_def_vl_rec.description
      ,x_creation_date                => l_obj_def_vl_rec.creation_date
      ,x_created_by                   => l_obj_def_vl_rec.created_by
      ,x_last_update_date             => l_obj_def_vl_rec.last_update_date
      ,x_last_updated_by              => l_obj_def_vl_rec.last_updated_by
      ,x_last_update_login            => l_obj_def_vl_rec.last_update_login
      ,x_object_version_number        => l_obj_def_vl_rec.object_version_number
    );

  else

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name,
      'Invalid Old Approved Copy Flag: '||p_target_copy_flag);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;

END CopyObjectDefinitionRec;


--
-- PROCEDURE
--   CopyObjectDependencyRecs
--
-- DESCRIPTION
--   Creates new Object Dependencies by inserting records in the
--   FEM_OBJECT_DEPENDENCIES table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID
--   p_target_obj_def_id    - Target Object Definition ID
--   p_created_by           - Created By (FND User ID).
--   p_creation_date        - Creation Date.
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDependencyRecs(
  p_source_obj_def_id       in          number
  ,p_target_obj_def_id      in          number
  ,p_created_by             in          number
  ,p_creation_date          in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_object_dependencies (
    object_definition_id
    ,required_object_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,required_object_id
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from fem_object_dependencies
  where object_definition_id = p_source_obj_def_id;

END CopyObjectDependencyRecs;


--
-- PROCEDURE
--   CopyVtObjDefAttrRec
--
-- DESCRIPTION
--   Creates new Visual Tracing Object Definition Attributes by inserting a
--   record in the FEM_VT_OBJ_DEF_ATTRIBS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID
--   p_target_obj_def_id    - Target Object Definition ID
--   p_created_by           - Created By (FND User ID).
--   p_creation_date        - Creation Date.
--
--------------------------------------------------------------------------------
PROCEDURE CopyVtObjDefAttrRec(
  p_source_obj_def_id       in          number
  ,p_target_obj_def_id      in          number
  ,p_created_by             in          number
  ,p_creation_date          in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_vt_obj_def_attribs (
    object_definition_id
    ,source_enabled_flg
    ,driver_enabled_flg
    ,trace_contribution_enabled_flg
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,source_enabled_flg
    ,driver_enabled_flg
    ,trace_contribution_enabled_flg
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from fem_vt_obj_def_attribs
  where object_definition_id = p_source_obj_def_id;

END CopyVtObjDefAttrRec;


--
-- PROCEDURE
--   DeleteObjectRec
--
-- DESCRIPTION
--   Deletes an Object by performing deletes on records in the
--   FEM_OBJECT_CATALOG_VL table.
--
-- IN
--   p_obj_id               - Object ID
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectRec(
  p_obj_id                  in          number
)
--------------------------------------------------------------------------------
IS

  l_count                   number;

BEGIN

  FEM_OBJECT_CATALOG_PKG.Delete_Row (
    x_object_id => p_obj_id
  );

EXCEPTION

  when no_data_found then null;

END DeleteObjectRec;


--
-- PROCEDURE
--   DeleteObjectDefinitionRec
--
-- DESCRIPTION
--   Deletes a Business Rule Definition by performing deletes on records
--   in the FEM_OBJECT_DEFINITIONS table.
--
-- IN
--   p_obj_def_id               - Object Definition ID
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinitionRec(
  p_obj_def_id              in          number
)
--------------------------------------------------------------------------------
IS
BEGIN

  FEM_OBJECT_DEFINITION_PKG.Delete_Row (
    x_object_definition_id => p_obj_def_id
  );

EXCEPTION

  when no_data_found then null;

END DeleteObjectDefinitionRec;


--
-- PROCEDURE
--   DeleteObjectDependencyRecs
--
-- DESCRIPTION
--   Deletes Object Dependencies by performing deletes on records
--   in the FEM_OBJECT_DEPENDENCIES table.
--
-- IN
--   p_obj_def_id               - Object Definition ID
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDependencyRecs(
  p_obj_def_id              in          number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_object_dependencies
  where object_definition_id = p_obj_def_id;

END DeleteObjectDependencyRecs;


--
-- PROCEDURE
--   DeleteVtObjDefAttrRec
--
-- DESCRIPTION
--   Deletes Visual Tracing Object Definition Attributes by performing deletes
--   on records in the FEM_VT_OBJ_DEF_ATTRIBS table.
--
-- IN
--   p_obj_def_id               - Object Definition ID
--
--------------------------------------------------------------------------------
PROCEDURE DeleteVtObjDefAttrRec(
  p_obj_def_id              in          number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_vt_obj_def_attribs
  where object_definition_id = p_obj_def_id;

END DeleteVtObjDefAttrRec;


--
-- PROCEDURE
--   SetOldApprovedObjDefId
--
-- DESCRIPTION
--   Sets the old approved copy object definition id of the specified
--   object definition.
--
-- IN
--   p_obj_def_id               - Object Definition ID
--   p_old_approved_obj_def_id  - Old Approved Object Definition ID
--
--------------------------------------------------------------------------------
PROCEDURE SetOldApprovedObjDefId(
  p_obj_def_id                  in          number
  ,p_old_approved_obj_def_id    in          number
)
--------------------------------------------------------------------------------
IS
BEGIN

  update fem_object_definition_b
  set old_approved_copy_obj_def_id = p_old_approved_obj_def_id
  where old_approved_copy_flag = G_CURRENT_COPY
  and object_definition_id = p_obj_def_id;

END SetOldApprovedObjDefId;


--
-- PROCEDURE
--   ObjectDefinitionExists
--
-- DESCRIPTION
--   Checks to see if an object definition exists.
--
-- IN
--   p_obj_def_id                 - Object Definition ID
--
-- RETURNS
--   obj_def_exists               - Object Definition Exists Flag (boolean)
--
--------------------------------------------------------------------------------
FUNCTION ObjectDefinitionExists (
  p_obj_def_id                    in number
)
RETURN boolean
--------------------------------------------------------------------------------
IS

  l_count                   number;

BEGIN

  select count(object_definition_id)
  into l_count
  from fem_object_definition_b
  where object_definition_id = p_obj_def_id;

  return (l_count > 0);

END ObjectDefinitionExists;


--
-- PROCEDURE
--   IsObjectEmpty
--
-- DESCRIPTION
--   Checks to see if an object can be deleted because there are no
--   remaining object definitions.
--
-- IN
--   p_obj_id               - Object ID
--   p_exclude obj_def_id   - Object Definition ID to exclude from check
--
-- RETURNS
--   object_empty           - Object Empty Flag (boolean)
--
--------------------------------------------------------------------------------
FUNCTION IsObjectEmpty(
  p_obj_id                  in number
  ,p_exclude_obj_def_id     in number default null
)
RETURN boolean
--------------------------------------------------------------------------------
IS

  l_count                   number;

BEGIN

  select count(object_definition_id)
  into l_count
  from fem_object_definition_b
  where old_approved_copy_flag = G_CURRENT_COPY
  and object_id = p_obj_id
  and object_definition_id <> nvl(p_exclude_obj_def_id, -1);

  return (l_count = 0);

END IsObjectEmpty;


--
-- PROCEDURE
--   CreateWfReqObjectDefRow
--
-- DESCRIPTION
--   PL/SQL API for creating a row in the FEM_WF_REQ_OBJECT_DEFS table.
--   Used for raising FEM Business Rule Events.
--
-- IN
--   p_wf_request_id              - Workflow Request Id
--   p_obj_def_id                 - Object Definition Id
--   p_object_type_code           - Object Type Code
--   p_prev_approval_status_code  - Previous Approval Status Code
--
--------------------------------------------------------------------------------
PROCEDURE CreateWfReqObjectDefRow (
  p_wf_request_id                 in number
  ,p_obj_def_id                   in number
  ,p_object_type_code             in varchar2
  ,p_prev_approval_status_code    in varchar2
)
--------------------------------------------------------------------------------
IS
   l_api_name             constant varchar2(30) := 'CreateWfReqObjectDefRow';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);
BEGIN
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
    ,p_msg_text => 'BEGIN, p_wf_request_id:' || p_wf_request_id
     || ' p_obj_def_id:' || p_obj_def_id || ' p_object_type_code:'
     || p_object_type_code || ' p_prev_approval_status_code:' || p_prev_approval_status_code
  );

  insert into fem_wf_req_object_defs (
    wf_request_id
    ,object_definition_id
    ,prev_approval_status_code
    ,object_type_code
    ,creation_date
    ,created_by
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) values (
    p_wf_request_id
    ,p_obj_def_id
    ,p_prev_approval_status_code
    ,p_object_type_code
    ,sysdate
    ,FND_GLOBAL.User_Id
    ,FND_GLOBAL.User_Id
    ,sysdate
    ,FND_GLOBAL.Login_Id
    ,1
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'|| l_api_name
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
   RAISE;

END CreateWfReqObjectDefRow;


--
-- FUNCTION
--   GetObjectDefinitionsCount
--
-- DESCRIPTION
--   Returns the number of object definition records based on the
--   requires approval flag value.
--
-- IN
--   p_request_id           - Workflow Request ID
--   p_request_item_code    - Request Item Code (BUSINESS_RULE, etc)
--   p_request_type_code    - Approval Request Type (APPROVAL, DELETE, etc)
--
-- RETURNS
--   count                  - Number of object defs in a workflow request
--
--------------------------------------------------------------------------------
FUNCTION GetObjectDefinitionsCount(
  p_request_id              in          number
  ,p_request_item_code      in          varchar2
  ,p_request_type_code      in          varchar2
)
RETURN number
--------------------------------------------------------------------------------
IS

  l_count                   number;

BEGIN

  select count(*)
  into l_count
  from fem_wf_requests req
    ,fem_wf_req_object_defs req_def
    ,fem_object_definition_b def
    ,fem_object_catalog_b obj
    ,fem_object_types typ
  where req.wf_request_id = p_request_id
  and req.wf_request_item_code = p_request_item_code
  and req.wf_request_type_code = p_request_type_code
  and req_def.wf_request_id = req.wf_request_id
  and def.object_definition_id = req_def.object_definition_id
  and def.old_approved_copy_flag = G_CURRENT_COPY
  and obj.object_id = def.object_id
  and typ.object_type_code = obj.object_type_code
  and typ.workflow_enabled_flag = 'Y';

  return l_count;

END GetObjectDefinitionsCount;


--
-- PROCEDURE
--   CheckOverlapObjDefsInternal
--
-- DESCRIPTION
--   Checks if the specified effective dates will overlap with existing
--   object definitions under the same parent object.  If this check is for
--   updating the effective dates of an existing object definition, this
--   object definition must be excluded from the overlap check.
--   If an overlap exists the appropriate FND message is set and an exception
--   is raised.
--
-- IN
--   p_obj_id                   - Object ID
--   p_exclude obj_def_id       - Object Definition ID to exclude from check
--   p_effective_start_date     - The new effective start date
--   p_effective_end_date       - The new effective end date
--   p_action_type              - Action Type
--
--------------------------------------------------------------------------------
PROCEDURE CheckOverlapObjDefsInternal(
  p_obj_id                  in          number
  ,p_exclude_obj_def_id     in          number
  ,p_effective_start_date   in          date
  ,p_effective_end_date     in          date
  ,p_action_type            in          number
)
--------------------------------------------------------------------------------
IS

  overlapping_obj_def_rec       overlapping_obj_defs_cur%ROWTYPE;

BEGIN

  -- First check that the end date is not smaller than the start date.
  if (p_effective_end_date < p_effective_start_date) then

    FND_MESSAGE.set_name('FEM', 'FEM_BR_END_LT_START_DATE_ERR');
    FND_MESSAGE.set_token('START_DATE',FND_DATE.date_to_chardate(p_effective_start_date));
    FND_MESSAGE.set_token('END_DATE',FND_DATE.date_to_chardate(p_effective_end_date));
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;

  end if;

  if (p_obj_id is not null) then

    for overlapping_obj_def_rec in overlapping_obj_defs_cur(
      p_obj_id                => p_obj_id
      ,p_exclude_obj_def_id   => p_exclude_obj_def_id
      ,p_effective_start_date => p_effective_start_date
      ,p_effective_end_date   => p_effective_end_date
    ) loop

      -- If any records are returned in the overlapping_obj_defs_cur, then
      -- an overlap exists with at least one object definition.
      if (p_action_type = G_REVERT_ACTION_TYPE) then
        FND_MESSAGE.set_name('FEM', 'FEM_BR_RVRT_OVRLP_OBJ_DEF_ERR');
      else
        FND_MESSAGE.set_name('FEM', 'FEM_BR_OVRLP_OBJ_DEF_ERR');
      end if;

      FND_MESSAGE.set_token('VERSION_NAME', overlapping_obj_def_rec.object_definition_name);
      FND_MESSAGE.set_token('START_DATE',FND_DATE.date_to_chardate(overlapping_obj_def_rec.effective_start_date));
      FND_MESSAGE.set_token('END_DATE',FND_DATE.date_to_chardate(overlapping_obj_def_rec.effective_end_date));
      FND_MSG_PUB.Add;

      raise FND_API.G_EXC_ERROR;

    end loop;

  end if;

END CheckOverlapObjDefsInternal;


--
-- PROCEDURE
--   GetEffectiveDates
--
-- DESCRIPTION
--   Returns the Start and End Effective Dates of the specified Object
--   Definition.
--
-- IN
--   p_obj_def_id           - Object Definition ID
--
-- OUT
--   x_effective_start_date - Effective Start Date
--   x_effective_end_date   - Effective End Date
--
--------------------------------------------------------------------------------
PROCEDURE GetEffectiveDates(
  p_obj_def_id              in          number
  ,x_effective_start_date   out nocopy  date
  ,x_effective_end_date     out nocopy  date
)
--------------------------------------------------------------------------------
IS
BEGIN

  select effective_start_date, effective_end_date
  into x_effective_start_date, x_effective_end_date
  from fem_object_definition_b
  where object_definition_id = p_obj_def_id;

END GetEffectiveDates;


--
-- PROCEDURE
--   GetProfileOptionDateValue
--
-- DESCRIPTION
--   Returns the date value of the specified profile option.  All profile
--   option values are stored as string values, so we must convert the string
--   value into a date value by using ICX_DATE_FORMAT_MASK.
--
-- IN
--   p_profile_option_name  - Profile Option Name
--
-- RETURN
--   x_date_value           - Date Value
--
--------------------------------------------------------------------------------
FUNCTION GetProfileOptionDateValue (
  p_profile_option_name     in varchar2
)
RETURN date
--------------------------------------------------------------------------------
IS

  l_api_name          constant varchar2(80) := 'GetProfileOptionDateValue';

  l_date_value        date;
  l_date_format_mask  varchar2(240);
  l_date_string       varchar2(240);


BEGIN

  l_date_value := null;

  --l_date_string := FND_PROFILE.value(p_profile_option_name);
  --Bug#5604779
  l_date_string := FND_PROFILE.Value_Specific(p_profile_option_name);

  if (l_date_string is not null) then

    -- Bug 5508120 -- NMARTINE -- 01-SEP-2006
    -- Effective End Date profile option is now stored in Canonical format
    l_date_value := FND_DATE.Canonical_To_Date(l_date_string);

    -- Remove the time component.
    l_date_value := trunc(l_date_value);

  end if;

  return l_date_value;

END GetProfileOptionDateValue;



END FEM_BUSINESS_RULE_PVT;

/

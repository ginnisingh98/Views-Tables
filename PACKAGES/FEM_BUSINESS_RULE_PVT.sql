--------------------------------------------------------
--  DDL for Package FEM_BUSINESS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BUSINESS_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVBUSS.pls 120.4.12010000.1 2008/07/24 11:02:06 appldev ship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

-- Copy Type Code Constants
G_DUPLICATE                  constant varchar2(30) := 'DUPLICATE';
G_BACKUP                     constant varchar2(30) := 'BACKUP';
G_REVERT                     constant varchar2(30) := 'REVERT';

-- FEMAPPR Item Attributes for all approvals.  Included to remove PL/SQL
-- compilation dependencies
G_APPROVAL_TYPE              constant varchar2(30) := 'APPROVAL';
G_DELETE_TYPE                constant varchar2(30) := 'DELETE';
G_REQUEST_ID                 constant varchar2(30) := 'REQUEST_ID';
G_REQUEST_ITEM_CODE          constant varchar2(30) := 'REQUEST_ITEM_CODE';
G_REQUEST_TYPE_CODE          constant varchar2(30) := 'REQUEST_TYPE_CODE';
G_APPROVER_USER_ID           constant varchar2(30) := 'APPROVER_USER_ID';

-- FEMAPPR Item Attributes Specific for Business Rules
G_FOLDER_NAME                constant varchar2(30) := 'FOLDER_NAME';
G_OBJECT_TYPE_CODE           constant varchar2(30) := 'OBJECT_TYPE_CODE';
G_OBJECT_TYPE                constant varchar2(30) := 'OBJECT_TYPE';
G_OBJECT_NAME                constant varchar2(30) := 'OBJECT_NAME';
G_OBJECT_DEFINITION_ID       constant varchar2(30) := 'OBJECT_DEFINITION_ID';
G_OBJECT_DEFINITION_NAME     constant varchar2(30) := 'OBJECT_DEFINITION_NAME';
G_URL_SUBMITTED              constant varchar2(30) := 'URL_SUBMITTED';
G_URL_ORIGINAL               constant varchar2(30) := 'URL_ORIGINAL';
G_URL_APPROVED               constant varchar2(30) := 'URL_APPROVED';
G_URL_REJECTED               constant varchar2(30) := 'URL_REJECTED';

-- FEM_APPROVAL_STATUS_DSC
G_APPROVED_STATUS           constant varchar2(30) := 'APPROVED';
G_NOT_APPROVED_STATUS       constant varchar2(30) := 'NOT_APPROVED';
G_NEW_STATUS                constant varchar2(30) := 'NEW';
G_SUBMIT_APPROVAL_STATUS    constant varchar2(30) := 'SUBMIT_APPROVAL';
G_SUBMIT_DELETE_STATUS      constant varchar2(30) := 'SUBMIT_DELETE';
G_NOT_APPLICABLE_STATUS     constant varchar2(30) := 'NOT_APPLICABLE';

-- OLD_APPROVED_COPY_FLAG
G_CURRENT_COPY              constant varchar2(1) := 'N';
G_OLD_APPROVED_COPY         constant varchar2(1) := 'Y';

-- PROCESS TYPE (For calling FEM_PL_PKG can_delete API's)
G_DEFAULT                   constant number := 0;
G_WORKFLOW                  constant number := 1;

G_YES                       constant varchar2(1) := 'Y';
G_NO                        constant varchar2(1) := 'N';

t_url                       varchar(2000);
G_URL_FUNCTION              constant varchar2(100) := 'JSP:/OA_HTML/OA.jsp?OAFunc=';
G_URL_OBJ_DEF_ID            constant varchar2(30) := '&ObjDefId=';
G_URL_FOLDER_ID             constant varchar2(30) := '&FolderId=';
G_URL_PAGE_MODE_VIEW        constant varchar2(30) := '&PageMode=VIEW';

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
FUNCTION GetDefaultStartDate
RETURN date;

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
FUNCTION GetDefaultEndDate
RETURN date;

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
);

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
);

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
 ) RETURN varchar2;

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
FUNCTION GetObjectId (
  p_obj_def_id              in          number
)
RETURN number;

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
FUNCTION GetNewObjId
RETURN number;

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
FUNCTION GetNewObjDefId
RETURN number;

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
RETURN varchar2;

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
PROCEDURE SetSubmittedState(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
);

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
PROCEDURE SetApprovedState(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
);

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
PROCEDURE SetRejectedState(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
);

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

FUNCTION CheckApprovalItems(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
)
RETURN varchar2;

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
PROCEDURE InitApprovalItems(
  p_item_type               in          varchar2
  ,p_item_key               in          varchar2
);

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
);


END FEM_BUSINESS_RULE_PVT;

/

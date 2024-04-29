--------------------------------------------------------
--  DDL for Package Body JTF_ESCWFACTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ESCWFACTIVITY_PVT" AS
/* $Header: jtfvewab.pls 120.4.12010000.3 2008/11/05 11:26:04 rkamasam ship $ */

g_pkg_name    CONSTANT     VARCHAR2(30) := 'JTF_EscWFActivity_PVT';
g_success     CONSTANT     VARCHAR2(15) := 'NOERROR';
g_critical    CONSTANT     VARCHAR2(15) := 'CRITICAL';
g_noncritical CONSTANT     VARCHAR2(15) := 'NONCRITICAL';

----------------------------------------------------------------------------
-- Attributes set by WF before calling this package
----------------------------------------------------------------------------

-- unique object identifier
g_object_id        JTF_TASKS_VL.TASK_ID%TYPE;

-- type of object.
-- possible values are:  - 'CS_BRM_3D_SERVICE_REQUEST_V' - SR
--                       - 'CSS_BRM_3D_DEFECT_V' - Defect
--                       - 'JTF_BRM_3D_TASK_V' - Task
g_object_type      AK_OBJECTS_VL.DATABASE_OBJECT_NAME%TYPE;

-- unique rule identifier
g_rule_id          JTF_BRM_RULES_VL.RULE_ID%TYPE;

----------------------------------------------------------------------------
-- Attributes set by this package before returning to WF
----------------------------------------------------------------------------

-- WF user id of person to receive notification
g_notif_person_id  JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;

-- user-visible object name
g_object_name      AK_OBJECTS_VL.NAME%TYPE;

-- short name for the rule
g_rule_name        JTF_BRM_RULES_VL.RULE_NAME%TYPE;

-- long description of rule
g_rule_desc        JTF_BRM_RULES_VL.RULE_DESCRIPTION%TYPE;

-- business rule owner
g_rule_owner       JTF_BRM_RULES_VL.RULE_OWNER%TYPE;

-- date and time the object was detected
g_detected_date    DATE;

-- object owner
g_owner_id         JTF_TASKS_VL.OWNER_ID%TYPE;

-- SR object owner in case owner is a group
g_owner_group_id   NUMBER;

-- SR group type either Group or Team
g_owner_group_type VARCHAR2(30);

-- object owner's territory
g_territory        JTF_TASKS_VL.OWNER_TERRITORY_ID%TYPE;

-- object owner's resource type
g_res_type_code    JTF_TASKS_VL.OWNER_TYPE_CODE%TYPE;

-- derive this from the object
g_object_type_code JTF_OBJECTS_VL.OBJECT_CODE%TYPE;

-- object name as held in jtf_objects, used in Task APIs
g_jtf_object_name  JTF_OBJECTS_VL.SELECT_NAME%TYPE;

--Added by MPADHIAR for Bug#5068840

--objects's Customer ID
g_customer_id                   jtf_tasks_v.customer_id%type;

--objects's Customer Account ID
g_cust_account_id               jtf_tasks_v.cust_account_id%type;

--objects's Customer Address ID
g_address_id                    jtf_tasks_v.address_id%type;


g_debug            VARCHAR2(1):= NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

g_debug_level      NUMBER     := NVL(fnd_profile.value_specific('AFLOG_LEVEL'), fnd_log.level_event);

PROCEDURE debug(p_level NUMBER, p_module VARCHAR2, p_message VARCHAR2) IS
BEGIN
  IF g_debug = 'Y' AND p_level >= g_debug_level THEN
    fnd_log.string(p_level, 'jtf.plsql.JTF_ESCWFACTIVITY_PVT.' || p_module, p_message);
  END IF;
END debug;


FUNCTION Get_Messages_On_Stack
RETURN VARCHAR2
IS
  l_msg_count NUMBER := 0;
  l_msg       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

 l_msg_count := fnd_msg_pub.count_msg;
 IF l_msg_count > 0
 THEN
   l_msg := ' ' || substr(fnd_msg_pub.get(  fnd_msg_pub.G_FIRST
                                          , fnd_api.G_FALSE
                                          ),1, 512);
 END IF;

 FOR iIndex IN 1..(l_msg_count-1) LOOP
   l_msg := l_msg || ' ' || substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT
                                                  ,fnd_api.G_FALSE
                                                  ), 1, 512);
 END LOOP;

END Get_Messages_On_Stack;


--Added by MPADHIAR for Bug#5068840 Ends Here

----------------------------------------------------------------------------
-- Start of comments
--  Function    : Get_WorkflowAttribute
--  Description : Return the code or value for the specified Workflow
--                Attribute, depending on p_return_type.
--                This function is private to this package.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_attr_name             IN      VARCHAR2 required
--      p_return_type           IN      VARCHAR2 required
--
--      returns
--      -------
--      x_param_value           OUT     VARCHAR2
--
--  Notes :
--          p_return_type = CODE - return the code
--          p_return_type = VALUE - return the value
--
-- End of comments
----------------------------------------------------------------------------
FUNCTION Get_WorkflowAttribute
  ( p_attr_name       IN  VARCHAR2
  , p_return_type     IN  VARCHAR2
  ) RETURN VARCHAR2
IS
  -------------------------------------------------------------------------
  -- Cursor for Rule query
  -------------------------------------------------------------------------
  CURSOR c_get_rule(b_rule_id JTF_BRM_PROCESSES.RULE_ID%TYPE)
  IS SELECT workflow_item_type
     ,      workflow_process_name
     FROM jtf_brm_processes
     WHERE rule_id = b_rule_id;

  l_attr_value    JTF_BRM_WF_ATTR_VALUES_V.WF_ATTRIBUTE_VALUE%TYPE;
  l_item_type     JTF_BRM_PROCESSES.WORKFLOW_ITEM_TYPE%TYPE;
  l_process_name  JTF_BRM_PROCESSES.WORKFLOW_PROCESS_NAME%TYPE;

BEGIN

  debug( fnd_log.level_statement
       , 'Get_WorkflowAttribute'
       , 'input attr name'||p_attr_name|| 'return type'||p_return_type
       );
  OPEN c_get_rule(g_rule_id);
  FETCH c_get_rule INTO l_item_type,
                        l_process_name;
  IF (c_get_rule%NOTFOUND)
  THEN
    -----------------------------------------------------------------------
    -- Query Rule didn't find a record
    -----------------------------------------------------------------------
    debug(  fnd_log.level_error, 'Get_WorkflowAttribute', 'There is no rule for the query'||g_rule_id);
    CLOSE c_get_rule;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE C_GET_RULE;
  IF (p_return_type = 'CODE')
  THEN
    l_attr_value := JTF_BRM_UTILITY_PVT.Attribute_Code
                    ( p_rule_id           => g_rule_id
                    , p_wf_item_type      => l_item_type
                    , p_wf_process_name   => l_process_name
                    , p_wf_attribute_name => p_attr_name
                    );
  ELSE
    l_attr_value := JTF_BRM_UTILITY_PVT.Attribute_Meaning
                    ( p_rule_id           => g_rule_id
                    , p_wf_item_type      => l_item_type
                    , p_wf_process_name   => l_process_name
                    , p_wf_attribute_name => p_attr_name
                    );
  END IF;
  debug(  fnd_log.level_statement, 'Get_WorkflowAttribute', 'the attribute value is '||l_attr_value);
  RETURN(l_attr_value);

EXCEPTION
  WHEN OTHERS
  THEN
    debug(  fnd_log.level_unexpected, 'Get_WorkflowAttribute'
          , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
          );
    RAISE;

END Get_WorkflowAttribute;

----------------------------------------------------------------------------
-- Start of comments
--  Function    : Get_EmployeeID
--  Description : Return an Employee ID when given a resource_id.
--                This function is private to this package.
--  Parameters  :
--      name                 direction  type       required?
--      ----                 ---------  ----       ---------
--      p_resource_id           IN      NUMBER     required
--      x_resultout             OUT     VARCHAR2
--
--      returns
--      -------
--      x_employee_id           OUT     NUMBER
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
FUNCTION Get_EmployeeID
  (  p_resource_id     IN   NUMBER
  ,  x_resultout       OUT NOCOPY  VARCHAR2
  ) RETURN NUMBER
IS
  -------------------------------------------------------------------------
  -- Cursor for Resources query
  -------------------------------------------------------------------------
  CURSOR c_query_emp (b_resource_id JTF_RS_EMP_DTLS_VL.RESOURCE_ID%TYPE)
  IS  SELECT source_id
      FROM   JTF_RS_RESOURCE_EXTNS
      WHERE resource_id = b_resource_id;

  l_person_id  JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE;

BEGIN
  x_resultout := FND_API.G_Ret_Sts_Success;

  -- -----------------------------------------------------------------------
  -- Query Resources view to get the employee_id
  -- -----------------------------------------------------------------------
  OPEN c_query_emp(p_resource_id);
  FETCH c_query_emp INTO l_person_id;
  IF (c_query_emp%NOTFOUND)
  THEN
    -----------------------------------------------------------------------
    -- Query Resources didn't find a record
    -----------------------------------------------------------------------
    debug( fnd_log.level_error, 'Get_EmployeeID', 'Employee details not found for the resource'||p_resource_id);
    CLOSE c_query_emp;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_query_emp;
  debug( fnd_log.level_statement, 'Get_EmployeeID', 'Employee id for the resource'||p_resource_id||':'||l_person_id);
  RETURN(l_person_id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_resultout := FND_API.G_Ret_Sts_Error;
    debug(  fnd_log.level_error, 'Get_EmployeeID'
          , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
          );
    RETURN(NULL);
  WHEN OTHERS
  THEN
    x_resultout := FND_API.G_Ret_Sts_Unexp_Error;
    debug(  fnd_log.level_unexpected, 'Get_EmployeeID'
          , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
          );
    RETURN(NULL);

END Get_EmployeeID;

----------------------------------------------------------------------------
-- Start of comments
--  Function    : Get_EmployeeRole
--  Description : Return an Employee's WF role when given an employee_id.
--                This function is private to this package.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_employee_id           IN      NUMBER   required
--      x_resultout             OUT     VARCHAR2
--
--      returns
--      -------
--      x_employee_role         OUT     VARCHAR2
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
FUNCTION Get_EmployeeRole
  ( p_employee_id     IN   NUMBER
  , x_resultout       OUT NOCOPY  VARCHAR2
  ) RETURN VARCHAR2
IS
  l_wf_role            FND_USER.USER_NAME%TYPE;
  l_role_display_name  wf_local_roles.display_name%type;

BEGIN

  x_resultout := FND_API.G_RET_STS_SUCCESS;

  -------------------------------------------------------------------------
  -- Call Workflow API to get the role
  -- If there is more than one role for this employee, the API will
  -- return the first one fetched.  If no Workflow role exists for
  -- the employee, out variable will be NULL
  -------------------------------------------------------------------------
  WF_DIRECTORY.GetRoleName( p_orig_system     => 'PER'
                          , p_orig_system_id  => p_employee_id
                          , p_name            => l_wf_role
                          , p_display_name    => l_role_display_name
                          );

  IF (l_wf_role IS NULL)
  THEN
    x_resultout := FND_API.G_RET_STS_ERROR;
    debug( fnd_log.level_error, 'Get_EmployeeRole', 'No role found for the employee:'||p_employee_id);
  END IF;
  RETURN(l_wf_role);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_resultout := FND_API.G_Ret_Sts_Error;
    debug(  fnd_log.level_error, 'Get_EmployeeRole'
        , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
        );
    RETURN(NULL);
  WHEN OTHERS
  THEN
    x_resultout := FND_API.G_Ret_Sts_Unexp_Error;
    debug(  fnd_log.level_unexpected, 'Get_EmployeeRole'
        , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
        );
    RETURN(NULL);

END Get_EmployeeRole;


----------------------------------------------------------------------------
-- Start of comments
--  Function    : Get_RuleOwner
--  Description : Return an Apps resource ID or person ID for the owner of
--                the business rule.  This function is private to this
--                package.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_id_type               IN      VARCHAR2 required
--      x_resultout             OUT     VARCHAR2
--
--      returns
--      -------
--      x_owner_id             OUT      NUMBER
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
FUNCTION Get_RuleOwner
  ( p_id_type       IN   VARCHAR2
  , x_resultout     OUT NOCOPY  VARCHAR2
  ) RETURN NUMBER
IS
  -------------------------------------------------------------------------
  -- Cursor for Resources query
  -------------------------------------------------------------------------
  CURSOR c_query_resource (b_source_id JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE)
  IS  SELECT resource_id
      FROM  JTF_RS_RESOURCE_EXTNS
      WHERE source_id = b_source_id;

  l_owner_id  JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;

BEGIN
  IF (p_id_type = 'RESOURCE')
  THEN
    ---------------------------------------------------------------------
    -- Query Resources view to get BR Owner resource_id
    ---------------------------------------------------------------------
    OPEN c_query_resource(g_rule_owner);
    FETCH c_query_resource INTO l_owner_id;
    IF (c_query_resource%NOTFOUND)
    THEN
      -------------------------------------------------------------------
      -- Query Resources didn't find a record
      -------------------------------------------------------------------
      debug( fnd_log.level_error, 'Get_RuleOwner', 'No resource found for the rule owner:'||g_rule_owner);
      CLOSE c_query_resource;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_query_resource;
  ELSE
    l_owner_id := g_rule_owner;
  END IF;
  debug( fnd_log.level_statement, 'Get_RuleOwner', 'The returned rule owner is :'||l_owner_id);
  RETURN(l_owner_id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_resultout := FND_API.G_Ret_Sts_Error;
    RETURN(NULL);
  WHEN OTHERS
  THEN
    x_resultout := FND_API.G_Ret_Sts_Unexp_Error;
    RETURN(NULL);

END Get_RuleOwner;

----------------------------------------------------------------------------
-- Start of comments
--  Function    : Get_EscTerrContact
--  Description : Return an Apps resource ID for the primary contact in the
--                escalation territory of the source document, or of the
--                catch-all territory if the source document doesn't have a
--                territory, or of the Business Rule Owner if the primary
--                contact is not an employee.  This function is private to
--                this package.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_id_type               IN      VARCHAR2 required
--      x_res_type              OUT     VARCHAR2
--      x_resultout             OUT     VARCHAR2
--
--      returns
--      -------
--      x_contact_id            OUT     NUMBER
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
FUNCTION Get_EscTerrContact
  ( p_id_type      IN   VARCHAR2
  , x_res_type     OUT NOCOPY  VARCHAR2
  , x_resultout    OUT NOCOPY  VARCHAR2
  ) RETURN NUMBER
IS
  -------------------------------------------------------------------------
  -- Standard API out parameters
  -------------------------------------------------------------------------
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_api_name  CONSTANT VARCHAR2(30) := 'Get_EscTerrContact';

  -------------------------------------------------------------------------
  -- Cursor for Resources query
  -------------------------------------------------------------------------
  CURSOR c_query_resource(b_source_id JTF_RS_EMP_DTLS_VL.SOURCE_ID%TYPE)
  IS  SELECT resource_id
      FROM JTF_RS_EMP_DTLS_VL
      WHERE source_id = b_source_id;

  -------------------------------------------------------------------------
  -- Territory record and table definitions (returned from
  -- jtf_territories_get APIs)
  -------------------------------------------------------------------------
  l_terr_resource_table     jtf_territory_get_pub.QualifyingRsc_out_tbl_type;
  l_terr_record             jtf_territory_get_pub.Terr_Rec_Type;
  l_terr_type_record        jtf_territory_get_pub.Terr_Type_Rec_Type;
  l_terr_sub_terr_table     jtf_territory_get_pub.Terr_Tbl_Type;
  l_terr_usgs_table         jtf_territory_get_pub.Terr_Usgs_Tbl_Type;
  l_terr_qtype_usgs_table   jtf_territory_get_pub.Terr_QType_Usgs_Tbl_Type;
  l_terr_qual_table         jtf_territory_get_pub.Terr_Qual_Tbl_Type;
  l_terr_values_table       jtf_territory_get_pub.Terr_Values_Tbl_Type;
  l_terr_rsc_table          jtf_territory_get_pub.Terr_Rsc_Tbl_Type;
  l_index                   BINARY_INTEGER;
  l_esc_territory           NUMBER;
  l_contact_id              JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
  l_resource_id             JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
  l_resultout               VARCHAR2(80);

Begin
  x_resultout := FND_API.G_Ret_Sts_Success;

  debug( fnd_log.level_statement, l_api_name, 'Input ID type'||p_id_type);

  -------------------------------------------------------------------------
  -- Get the primary contact from the escalation territory
  -------------------------------------------------------------------------
  IF (g_territory IS NULL)
  THEN
    -----------------------------------------------------------------
    -- There is no territory attached to the Source Document.
    -- Use Business Rule owner as the escalation contact.
    -----------------------------------------------------------------
    l_resource_id := Get_RuleOwner( p_id_type   => p_id_type
                                  , x_resultout => l_resultout
                                  );
    IF (l_resultout <> FND_API.G_Ret_Sts_Success)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    debug( fnd_log.level_statement, l_api_name, 'business rule owner for'||l_resource_id);

    l_contact_id := l_resource_id;

    x_res_type := jtf_ec_pub.g_escalation_owner_type_code;
  ELSE
    -----------------------------------------------------------------------
    -- Territory exists in the source document
    -- Use primary contact in relevant escalation territory
    -----------------------------------------------------------------------
    debug( fnd_log.level_statement, l_api_name, 'escalation territory exists for source doc');

    JTF_TERRITORY_GET_PUB.Get_Escalation_Territory
    ( p_api_version        => 1.0
    , p_init_msg_list      => FND_API.G_TRUE
    , x_return_status      => l_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    , p_terr_id            => g_territory
    , x_escalation_terr_id => l_esc_territory
    );

    IF (l_return_status = FND_API.G_Ret_Sts_Success)
    THEN
      debug( fnd_log.level_statement, l_api_name, 'Getting the members for territory'||l_esc_territory);
      JTF_TERRITORY_GET_PUB.Get_Escalation_TerrMembers
      ( 1.0
      , p_terr_id               => l_esc_territory
      , p_init_msg_list         => FND_API.G_TRUE
      , x_return_status         => l_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      , x_QualifyingRsc_out_tbl => l_terr_resource_table
      );
      debug( fnd_log.level_statement, l_api_name, 'retrieving members was:'||l_return_status);
      IF (l_return_status = FND_API.G_Ret_Sts_Success)
      THEN
        l_index := l_terr_resource_table.First;
        LOOP
          EXIT WHEN (  (l_terr_resource_table(l_index).primary_contact_flag = 'Y')
                    OR (l_index = l_terr_resource_table.Last)
                    );
          l_index := l_terr_resource_table.Next(l_index);
        END LOOP;

        IF (l_terr_resource_table(l_index).primary_contact_flag = 'Y') and
           (l_terr_resource_table(l_index).resource_type = 'RS_EMPLOYEE') Then
          l_resource_id := l_terr_resource_table(l_index).resource_id;
          x_res_type    := l_terr_resource_table(l_index).resource_type;
          IF (p_id_type = 'EMPLOYEE') Then
            l_contact_id := Get_EmployeeID( p_resource_id => l_resource_id
                                          , x_resultout   => l_resultout
                                          );
            IF (l_resultout <> FND_API.G_Ret_Sts_Success) Then
              debug( fnd_log.level_error, l_api_name, 'employee id not found for'||l_resource_id);
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          ELSE
            l_contact_id := l_resource_id;
          END IF;
        ELSE
          -----------------------------------------------------------------
          -- Territory has no primary contact, or the primary contact is
          -- not an employee resource - use the Business Rule owner
          -----------------------------------------------------------------
          l_resource_id := Get_RuleOwner( p_id_type   => p_id_type
                                        , x_resultout => l_resultout
                                        );
          IF (l_resultout <> FND_API.G_Ret_Sts_Success)
          THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          debug( fnd_log.level_statement, l_api_name, 'business rule owner for'||l_resource_id);

          l_contact_id := l_resource_id;

          x_res_type := jtf_ec_pub.g_escalation_owner_type_code;
        END IF;
      ELSE
        -------------------------------------------------------------------
        -- Error from Get_Escalation_TerrMembers API
        -------------------------------------------------------------------
        debug( fnd_log.level_error, l_api_name, 'Getting the members for territory failed');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      ---------------------------------------------------------------------
      -- Error from Get_Escalation_Territory API
      ---------------------------------------------------------------------
      debug( fnd_log.level_error, l_api_name, 'Getting the escalation territory failed');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  RETURN(l_contact_id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_resultout := FND_API.G_Ret_Sts_Error;
    debug(fnd_log.LEVEL_statement, l_api_name, 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM);
    RETURN(NULL);
  WHEN OTHERS
  THEN
    x_resultout := FND_API.G_Ret_Sts_Unexp_Error;
    debug(  fnd_log.level_unexpected, l_api_name , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM);
    RETURN(NULL);

END Get_EscTerrContact;

----------------------------------------------------------------------------
-- Start of comments
--  Function    : Get_PersonID
--  Description : Return a Resource ID or Employee ID when given the role
--                this person fulfils in relation to the source document.
--                This function is private to this package.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_document_role         IN      VARCHAR2 required
--      p_id_type               IN      VARCHAR2 required
--      x_res_type              OUT     VARCHAR2
--      x_resultout             OUT     VARCHAR2
--
--      returns
--      -------
--      x_person_id             OUT     NUMBER
--
--  Notes : p_id_type is either 'RESOURCE' or 'EMPLOYEE', which determines
--          what is returned in x_person_id
--
-- End of comments
----------------------------------------------------------------------------
FUNCTION Get_PersonID
  ( p_document_role     IN   VARCHAR2
  , p_id_type           IN   VARCHAR2
  , x_res_type          OUT NOCOPY  VARCHAR2
  , x_resultout         OUT NOCOPY  VARCHAR2
  ) RETURN NUMBER IS

  -------------------------------------------------------------------------
  -- Standard API out parameters
  -------------------------------------------------------------------------
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_api_name  CONSTANT VARCHAR2(30) := 'Get_PersonID';

  -------------------------------------------------------------------------
  -- Territory record and table definitions (returned from
  -- jtf_territories_get APIs)
  -------------------------------------------------------------------------
  l_terr_resource_table     jtf_territory_get_pub.QualifyingRsc_out_tbl_type;
  l_terr_record             jtf_territory_get_pub.Terr_Rec_Type;
  l_terr_type_record        jtf_territory_get_pub.Terr_Type_Rec_Type;
  l_terr_sub_terr_table     jtf_territory_get_pub.Terr_Tbl_Type;
  l_terr_usgs_table         jtf_territory_get_pub.Terr_Usgs_Tbl_Type;
  l_terr_qtype_usgs_table   jtf_territory_get_pub.Terr_QType_Usgs_Tbl_Type;
  l_terr_qual_table         jtf_territory_get_pub.Terr_Qual_Tbl_Type;
  l_terr_values_table       jtf_territory_get_pub.Terr_Values_Tbl_Type;
  l_terr_rsc_table          jtf_territory_get_pub.Terr_Rsc_Tbl_Type;

  -------------------------------------------------------------------------
  -- Cursor for HR Manager query
  -------------------------------------------------------------------------
  CURSOR c_query_hr_manager(b_owner_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
  IS  SELECT manager_person_id
      FROM JTF_RS_EMP_DTLS_VL
      WHERE resource_id = b_owner_id;

  -------------------------------------------------------------------------
  -- Cursor for Resources query
  -------------------------------------------------------------------------
  CURSOR c_query_resource(b_source_id JTF_RS_EMP_DTLS_VL.SOURCE_ID%TYPE)
  IS  SELECT resource_id
      FROM JTF_RS_EMP_DTLS_VL
      WHERE source_id = b_source_id;

  -------------------------------------------------------------------------
  -- Cursor for Resource Group query
  -------------------------------------------------------------------------
  CURSOR c_query_group(b_group_id JTF_RS_GROUP_MBR_ROLE_VL.GROUP_ID%TYPE,
                       b_now      DATE)
  IS  SELECT role.resource_id
        FROM JTF_RS_GROUP_MBR_ROLE_VL     role,
             JTF_RS_GROUP_MEMBERS_VL      mem
       WHERE role.group_id                = b_group_id
         AND mem.group_id                 = b_group_id
         AND role.group_member_id         = mem.group_member_id
         AND role.manager_flag            = 'Y'
         AND mem.category                 = 'EMPLOYEE'
         AND start_date_active           <= b_now
         AND nvl(end_date_active, b_now) >= b_now;

  l_now            DATE := SYSDATE;
  l_index          BINARY_INTEGER;
  l_esc_territory  JTF_TASKS_VL.OWNER_TERRITORY_ID%TYPE;
  l_person_id      JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE;
  l_resultout      VARCHAR2(80);
  l_source_id      JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE;
  l_resource_id    JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;

BEGIN
  x_resultout := FND_API.G_Ret_Sts_Success;
  x_res_type := jtf_ec_pub.g_escalation_owner_type_code;

  debug(fnd_log.level_statement, l_api_name,'input doc role'||p_document_role||' input id type'||p_id_type);

  IF (p_document_role = 'UNASSIGNED')
  THEN
    -----------------------------------------------------------------------
    -- No assignee required
    -----------------------------------------------------------------------
    l_person_id := NULL;
  ELSIF (p_document_role = 'BUSINESS_OWNER')
  THEN
    -----------------------------------------------------------------------
    -- Get the Business Rule owner
    -----------------------------------------------------------------------
    l_person_id := Get_RuleOwner( p_id_type   => p_id_type
                                , x_resultout => l_resultout
                                );
    IF (l_resultout <> FND_API.G_Ret_Sts_Success)
    THEN
      debug(fnd_log.level_error, l_api_name, 'Retrieving Business Rule Owner Failed');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF (  (p_document_role = 'ESC_TERRITORY_PRIMARY')
        OR ( (g_owner_id Is Null) AND g_owner_group_id IS NULL)
        )
  THEN
    -----------------------------------------------------------------------
    -- Get the escalation primary contact
    -- Also if the document has no owner
    -----------------------------------------------------------------------
    l_person_id := Get_EscTerrContact( p_id_type   => p_id_type
                                     , x_res_type  => x_res_type
                                     , x_resultout => l_resultout
                                     );
    IF (l_resultout <> FND_API.G_Ret_Sts_Success)
    THEN
      debug(fnd_log.level_error, l_api_name, 'Retrieving Escalation Primary Contact Failed for esc_terr_primary');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF (p_document_role = 'DOCUMENT_OWNER')
  THEN
    -----------------------------------------------------------------------
    -- If the resource type isn't Employee or Group then use the Escalation
    -- Territory primary contact, as Escalation owner must be an employee
    -----------------------------------------------------------------------
    If g_res_type_code not in ('RS_EMPLOYEE', 'RS_GROUP') Then
      l_person_id := Get_EscTerrContact( p_id_type   => p_id_type
                                       , x_res_type  => x_res_type
                                       , x_resultout => l_resultout
                                       );
      IF (l_resultout <> FND_API.G_Ret_Sts_Success)
      THEN
        debug(fnd_log.level_error, l_api_name, 'Retrieving Escalation Primary Contact Failed for document_owner');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    Elsif g_res_type_code = 'RS_EMPLOYEE' Then
      ---------------------------------------------------------------------
      -- Get the document owner
      ---------------------------------------------------------------------
      l_person_id := g_owner_id;
      IF (p_id_type = 'EMPLOYEE')
      THEN
        l_source_id := Get_EmployeeID( p_resource_id => l_person_id
                                     , x_resultout   => l_resultout
                                     );
        IF (l_resultout = FND_API.G_Ret_Sts_Success)
        THEN
          l_person_id := l_source_id;
        ELSE
          debug(fnd_log.level_error, l_api_name ,'Retrieving DocumentOwner for Employee Resource failed for:'||l_person_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    Else
      ---------------------------------------------------------------------
      -- It's a Group Resource, so work out if any of the members are
      -- Managers and are of type Employee (use the first one returned)
      ---------------------------------------------------------------------
      OPEN c_query_group(g_owner_id,
			 l_now);
      FETCH c_query_group INTO l_resource_id;

      IF (c_query_group%FOUND)
      THEN
        CLOSE c_query_group;
        debug(fnd_log.level_statement, l_api_name, 'group res for:'||g_owner_id||' is:'||l_resource_id);
        If p_id_type = 'EMPLOYEE' Then
          l_source_id := Get_EmployeeID( p_resource_id => l_resource_id
                                       , x_resultout   => l_resultout
                                       );
          IF (l_resultout = FND_API.G_Ret_Sts_Success) Then
            debug(fnd_log.level_statement, l_api_name, 'employee id found:'||l_source_id);
            l_person_id := l_source_id;
          ELSE
            debug(fnd_log.level_error, l_api_name, 'Retrieving Employee ID for Manager failed');
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        Else
          l_person_id := l_resource_id;
        End If;


      ELSIF (c_query_group%NOTFOUND)
      THEN
        -------------------------------------------------------------------
        -- If there is no suitable manager then use the Escalation
        -- Territory primary contact instead
        -------------------------------------------------------------------
        CLOSE c_query_group;
        l_person_id := Get_EscTerrContact( p_id_type   => p_id_type
                                         , x_res_type  => x_res_type
                                         , x_resultout => l_resultout
                                         );
        IF (l_resultout <> FND_API.G_Ret_Sts_Success)
        THEN
          debug(fnd_log.level_error, l_api_name, 'Escaltion Primary Contact failed for group resource');
          --
          -- simply assign it to the group
          --
          x_res_type  := g_owner_group_type;
          l_person_id := g_owner_group_id;

        END IF;
      END IF;
    END IF;
  ELSIF (p_document_role = 'DOCUMENT_OWNER_MGR')
  THEN
    -----------------------------------------------------------------------
    -- If the resource type isn't Employee or Group then use the Escalation
    -- Territory primary contact, as Escalation owner must be an employee
    -----------------------------------------------------------------------
    If g_res_type_code not in ('RS_EMPLOYEE', 'RS_GROUP') Then
      l_person_id := Get_EscTerrContact( p_id_type   => p_id_type
                                       , x_res_type  => x_res_type
                                       , x_resultout => l_resultout
                                       );
      IF (l_resultout <> FND_API.G_Ret_Sts_Success)
      THEN
        debug(fnd_log.level_error, l_api_name, 'Escaltion Primary Contact failed for DOCUMENT_OWNER_MGR');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    Elsif g_res_type_code = 'RS_EMPLOYEE' Then
      ---------------------------------------------------------------------
      -- Query Resources view to get HR Manager
      ---------------------------------------------------------------------
      OPEN c_query_hr_manager(g_owner_id);
      FETCH c_query_hr_manager INTO l_person_id;
      IF (c_query_hr_manager%notfound)
      THEN
        -------------------------------------------------------------------
        -- Query HR Manager didn't find a record
        -------------------------------------------------------------------
        CLOSE c_query_hr_manager;
        debug(fnd_log.level_error, l_api_name, 'Query for HR manager failed for owner'||g_owner_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_query_hr_manager;
      IF (p_id_type = 'RESOURCE')
      THEN
        -------------------------------------------------------------------
        -- Query Resources view to get HR Manager resource_id
        -------------------------------------------------------------------
        OPEN c_query_resource(l_person_id);
        FETCH c_query_resource INTO l_resource_id;
        IF (c_query_resource%NOTFOUND)
        THEN
          CLOSE c_query_resource;
          -----------------------------------------------------------------
          -- If the manager isn't a resource then use the Escalation
          -- Territory primary contact instead
          -----------------------------------------------------------------
          l_person_id := Get_EscTerrContact( p_id_type   => p_id_type
                                           , x_res_type  => x_res_type
                                           , x_resultout => l_resultout
                                           );
          IF (l_resultout <> FND_API.G_Ret_Sts_Success)
          THEN
            debug(fnd_log.level_error, l_api_name, 'Escaltion Primary Contact failed for id type'||p_id_type);
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          l_person_id := l_resource_id;
          CLOSE c_query_resource;
        END IF;
      END IF;
    Else
      ---------------------------------------------------------------------
      -- It's a Group Resource, so work out if any of the members are
      -- Managers and are of type Employee (use the first one returned)
      ---------------------------------------------------------------------
      OPEN c_query_group(g_owner_id,
			 l_now);
      FETCH c_query_group INTO l_resource_id;
      IF (c_query_group%NOTFOUND) Then
        -------------------------------------------------------------------
        -- If there is no suitable manager then use the Escalation
        -- Territory primary contact instead
        -------------------------------------------------------------------
        CLOSE c_query_group;
        l_person_id := Get_EscTerrContact( p_id_type   => p_id_type
                                         , x_res_type  => x_res_type
                                         , x_resultout => l_resultout
                                         );
        IF (l_resultout <> FND_API.G_Ret_Sts_Success)
        THEN
          debug(fnd_log.level_error, l_api_name, 'Escaltion Primary Contact failed for group resource');
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      Else
        debug(fnd_log.level_statement, l_api_name, 'Employee ID found is:'||l_resource_id);
        l_person_id := l_resource_id;
        CLOSE c_query_group;
      End If;
    End If;
  ELSE
    debug(fnd_log.level_error, l_api_name, 'Unhandled Document Owner Role');
    -----------------------------------------------------------------------
    -- Unhandled value for p_document_role
    -----------------------------------------------------------------------

    RAISE FND_API.G_EXC_ERROR;
  END IF;
  debug(fnd_log.level_statement, l_api_name, 'Returning the person id: '||l_person_id);
  RETURN(l_person_id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_resultout := FND_API.G_Ret_Sts_Error;
    RETURN(NULL);
  WHEN OTHERS
  THEN
    debug(  fnd_log.level_unexpected, l_api_name, 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM);
    x_resultout := FND_API.G_Ret_Sts_Unexp_Error;
    RETURN(NULL);

END Get_PersonID;

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Set_Globals
--  Description : Set values for global package variables.  This procedure
--                is private to this package.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype                IN      VARCHAR2 required
--      itemkey                 IN      VARCHAR2 required
--      actid                   IN      NUMBER   required
--      funcmode                IN      VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--    Expects WF item attributes 'OBJECT_ID' and 'OBJECT_TYPE' to be available
--    to this procedure.
--    Possible values for 'OBJECT_TYPE' are:
--      'CS_BRM_3D_SERVICE_REQUEST_V' - Service Request
--      'CSS_BRM_3D_DEFECT_V' - Defect
--      'JTF_BRM_3D_TASK_V' - Task
--
-- End of comments
----------------------------------------------------------------------------
PROCEDURE Set_Globals
  ( itemtype      IN  VARCHAR2
  , itemkey       IN  VARCHAR2
  , actid         IN  NUMBER
  , funcmode      IN  VARCHAR2
  , resultout     OUT NOCOPY VARCHAR2
  )
IS
  -------------------------------------------------------------------------
  -- Standard API out parameters
  -------------------------------------------------------------------------
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  -------------------------------------------------------------------------
  -- Cursor for AK_Objects query
  -------------------------------------------------------------------------
  CURSOR c_query_ak(b_object_type AK_OBJECTS_VL.DATABASE_OBJECT_NAME%TYPE)
  IS  SELECT description
      FROM AK_OBJECTS_VL
      WHERE DATABASE_OBJECT_NAME = b_object_type;

  -------------------------------------------------------------------------
  -- Cursor for BRM_Rules query
  -------------------------------------------------------------------------
  CURSOR c_query_rule(b_rule_id JTF_BRM_RULES_VL.RULE_ID%TYPE)
  IS  SELECT rule_name
      ,      rule_description
      ,      rule_owner
      FROM JTF_BRM_RULES_VL
      WHERE rule_id = b_rule_id;

  -------------------------------------------------------------------------
  -- Cursor for JTF_Objects query
  -------------------------------------------------------------------------
  CURSOR c_obj_details(b_obj_code VARCHAR2)
  IS  SELECT select_id
      ,      select_name
      ,      from_table
      FROM JTF_OBJECTS_VL
      WHERE object_code = b_obj_code;

  -------------------------------------------------------------------------
  -- Task table definition (returned from query_task API)
  -------------------------------------------------------------------------
  l_task_table            jtf_tasks_pub.task_table_type;
  l_sort_data             jtf_tasks_pub.sort_data;
  l_start_pointer         NUMBER;
  l_rec_wanted            NUMBER;
  l_retrieved             NUMBER;
  l_returned              NUMBER;
  l_object_version_number JTF_TASKS_VL.OBJECT_VERSION_NUMBER%TYPE;

  TYPE cur_type IS REF CURSOR;
  c_object cur_type;

  l_query        VARCHAR2(1000);
  l_select_id    JTF_OBJECTS_VL.SELECT_ID%TYPE;
  l_select_name  JTF_OBJECTS_VL.SELECT_NAME%TYPE;
  l_from_table   JTF_OBJECTS_VL.FROM_TABLE%TYPE;

BEGIN
  resultout := FND_API.G_Ret_Sts_Success;
  -------------------------------------------------------------------------
  -- Get item attribute values
  -------------------------------------------------------------------------
  g_object_id := WF_ENGINE.GetItemAttrNumber( itemtype => itemtype
                                            , itemkey  => itemkey
                                            , aname    => 'OBJECT_ID'
                                            );
  g_object_type := WF_ENGINE.GetItemAttrText( itemtype => itemtype
                                            , itemkey  => itemkey
                                            , aname    => 'OBJECT_TYPE'
                                            );
  g_rule_id := WF_ENGINE.GetItemAttrNumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'RULE_ID'
                                          );

  debug(  fnd_log.level_statement
        , 'Set_Globals'
        , 'Objectid is: '||g_object_id||' Object type: '||g_object_type||' Rule Id:'||g_rule_id
        );
  -------------------------------------------------------------------------
  -- Get object owner, territory, name and number
  -------------------------------------------------------------------------

  /* This Code is commented as CSS product is scraped.
  -- Ref Bug 5025448
  --
  If (g_object_type = 'CSS_BRM_3D_DEFECT_V')
  THEN
    -----------------------------------------------------------------------
    -- It's a Defect object
    -- Select straight from the view - using dynamic SQL so there is no
    -- build dependency on Defect code
    -----------------------------------------------------------------------
    l_query := 'SELECT phase_owner_id,' ||
               '       territory_id,' ||
               '       phase_owner_resource_type' ||
               '  FROM CSS_DEF_DEFECTS_B' ||
               ' WHERE defect_id = :b_object_id';
    OPEN c_object FOR l_query using g_object_id;
    FETCH c_object INTO g_owner_id,
                        g_territory,
                        g_res_type_code;

    IF (c_object%NOTFOUND)
    THEN
      ---------------------------------------------------------------------
      -- Query of Defect details didn't find a record
      ---------------------------------------------------------------------
      debug( fnd_log.level_error,'Set_Globals', 'Defect Details Not Found Using:'||g_object_id);
      CLOSE c_object;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_object;

    g_object_type_code := 'DF';
  ELS
  */
  IF (g_object_type = 'CS_BRM_3D_SERVICE_REQUEST_V')
  THEN
    -----------------------------------------------------------------------
    -- It's a Service Request object
    -- There's no Query API, so select straight from the view - using
    -- dynamic SQL so there is no build dependency on Service Request code
    -----------------------------------------------------------------------
    l_query := 'SELECT incident_owner_id,'  ||
               '       territory_id,'       ||
               '       resource_type,'      ||
               '       owner_group_id,'     ||
               '       group_type, '         ||
	       --Added by MPADHIAR for Bug#5068840
               '       CUSTOMER_ID,'        ||
               '       ACCOUNT_ID, '        ||
               '       install_site_id '    ||
	       --Added by MPADHIAR for Bug#5068840 Ends here
               '  FROM CS_INCIDENTS_ALL_VL' ||
               ' WHERE incident_id = :b_object_id';
    OPEN c_object FOR l_query using g_object_id;
    FETCH c_object INTO g_owner_id,
                        g_territory,
                        g_res_type_code,
                        g_owner_group_id,
                        g_owner_group_type,
	  --Added by MPADHIAR for Bug#5068840
                        g_customer_id,
                        g_cust_account_id,
                        g_address_id;
	 --Added by MPADHIAR for Bug#5068840 Ends here
    IF (c_object%NOTFOUND)
    THEN
      ---------------------------------------------------------------------
      -- Query of Service Request details didn't find a record
      ---------------------------------------------------------------------
      debug( fnd_log.level_error
           , 'Set_Globals'
           , 'Service Request Details Not Found Using:'||g_object_id);

      CLOSE c_object;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_object;
    g_object_type_code := 'SR';

  ELSIF (g_object_type = 'JTF_BRM_3D_TASK_V')
  THEN
    -----------------------------------------------------------------------
    -- It's a Task object
    -----------------------------------------------------------------------
    JTF_TASKS_PUB.Query_Task( p_api_version           => 1.0
                            , p_init_msg_list         => FND_API.G_TRUE
                            , p_task_id               => g_object_id
                            , p_sort_data             => l_sort_data
                            , p_start_pointer         => l_start_pointer
                            , p_rec_wanted            => l_rec_wanted
                            , p_show_all              => 'Y'
                            , x_task_table            => l_task_table
                            , x_total_retrieved       => l_retrieved
                            , x_total_returned        => l_returned
                            , x_return_status         => l_return_status
                            , x_msg_count             => l_msg_count
                            , x_msg_data              => l_msg_data
                            , x_object_version_number => l_object_version_number
                            );
    IF (   (l_return_status = FND_API.G_Ret_Sts_Success)
       AND (l_returned > 0)
       )
    THEN
      debug( fnd_log.level_statement,'Set_Globals','Task Details Found');
      g_owner_id         := l_task_table(1).owner_id;
      g_territory        := l_task_table(1).owner_territory_id;
      g_res_type_code    := l_task_table(1).owner_type_code;
      --Added by MPADHIAR for Bug#5068840
      g_customer_id      := l_task_table(1).customer_id;
      g_cust_account_id  := l_task_table(1).cust_account_id;
      g_address_id       := l_task_table(1).address_id;
      --Added by MPADHIAR for Bug#5068840 Ends here
      g_object_type_code := 'TASK';
    ELSE
      ---------------------------------------------------------------------
      -- Query API returned an error
      ---------------------------------------------------------------------
      debug(fnd_log.level_error,'Set_Globals','Task Details Not Found Using:'||g_object_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    -----------------------------------------------------------------------
    -- It's an invalid object type
    -----------------------------------------------------------------------
    debug(fnd_log.level_statement,'Set_Globals','Invalid Object Type'||g_object_type);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -------------------------------------------------------------------------
  -- Get the object name from AK
  -------------------------------------------------------------------------
  OPEN c_query_ak(g_object_type);
  FETCH c_query_ak INTO g_object_name;
  IF (c_query_ak%NOTFOUND)
  THEN
    -----------------------------------------------------------------------
    -- Query AK_OBJECTS didn't find a record
    -----------------------------------------------------------------------
    debug(fnd_log.level_error,'Set_Globals','Object Name from AK not found for:'||g_object_type);
    CLOSE c_query_ak;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_query_ak;
  -------------------------------------------------------------------------
  -- Get the rule name, description and owner
  -------------------------------------------------------------------------
  OPEN c_query_rule(g_rule_id);
  FETCH c_query_rule INTO g_rule_name
                     ,    g_rule_desc
                     ,    g_rule_owner;
  IF (c_query_rule%NOTFOUND)
  THEN
    -----------------------------------------------------------------------
    -- Query rule didn't find a record
    -----------------------------------------------------------------------
    debug(fnd_log.level_error,'Set_Globals','Rule details not found for rule ID:'||g_rule_id);
    CLOSE c_query_rule;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_query_rule;

  -------------------------------------------------------------------------
  -- Get the detected date
  -------------------------------------------------------------------------
  g_detected_date := SYSDATE;

  -- -----------------------------------------------------------------------
  -- Get the object name according to jtf_objects, for input to Task APIs
  -- -----------------------------------------------------------------------
  OPEN c_obj_details(g_object_type_code);
  FETCH c_obj_details INTO l_select_id
                      ,    l_select_name
                      ,    l_from_table;
  IF (c_obj_details%NOTFOUND)
  THEN
    -----------------------------------------------------------------------
    -- Query jtf_objects didn't find a record
    -----------------------------------------------------------------------
    debug(fnd_log.level_error,'Set_Globals', 'Details from JTF_OBJECTS not found for:'||g_object_type_code);
    CLOSE c_obj_details;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_obj_details;

  l_query := 'SELECT ' || l_select_name ||
             '  FROM ' || l_from_table  ||
             ' WHERE ' || l_select_id   ||
             '     = :b_input_id';

  OPEN c_object FOR l_query using g_object_id;
  FETCH c_object INTO g_jtf_object_name;
  IF (c_object%NOTFOUND)
  THEN
    -----------------------------------------------------------------------
    -- Query of object details didn't find a record
    -----------------------------------------------------------------------
    debug(fnd_log.level_error,'Set_Globals','Object Details not found for object name:'||g_jtf_object_name);
    CLOSE c_object;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_object;

  debug(  fnd_log.level_statement
       , 'Set_Globals'
       , 'g_object_name: ' || g_object_name
                           || ' g_jtf_object_name: ' || g_jtf_object_name
                           || ' g_object_type_code:' || g_object_type_code
                           || ' g_rule_name:' || g_rule_name
                           || ' g_rule_desc:' || g_rule_desc
                           || ' g_detected_date' || g_detected_date
       );

  -------------------------------------------------------------------------
  -- Set item attribute values
  -------------------------------------------------------------------------
  WF_ENGINE.SetItemAttrText( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'OBJECT_NAME'
                           , avalue   => g_object_name
                           );

  WF_ENGINE.SetItemAttrText( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'OBJECT_NUMBER'
                           , avalue   => g_jtf_object_name
                           );

  WF_ENGINE.SetItemAttrText( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'RULE_NAME'
                           , avalue   => g_rule_name
                           );

  WF_ENGINE.SetItemAttrText( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'RULE_DESC'
                           , avalue   => g_rule_desc
                           );

  WF_ENGINE.SetItemAttrDate( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'DETECTED_DATE'
                           , avalue   => g_detected_date
                           );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    resultout := FND_API.G_Ret_Sts_Error;

  WHEN OTHERS
  THEN
    debug(  fnd_log.level_unexpected, 'Set_Globals'
        , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
        );

    resultout := FND_API.G_Ret_Sts_Unexp_Error;

END Set_Globals;

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Create_NotifTask
--  Description : Call Task Manager API to create task for potential
--                escalation notification purposes
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype                IN      VARCHAR2 required
--      itemkey                 IN      VARCHAR2 required
--      actid                   IN      NUMBER   required
--      funcmode                IN      VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
PROCEDURE Create_NotifTask
  ( itemtype     IN  VARCHAR2
  , itemkey      IN  VARCHAR2
  , actid        IN  NUMBER
  , funcmode     IN  VARCHAR2
  , resultout    OUT NOCOPY VARCHAR2
  )
IS
  -------------------------------------------------------------------------
  -- Standard API out parameters
  -------------------------------------------------------------------------
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_api_name  CONSTANT VARCHAR2(30) := 'Create_NotifTask';

  -------------------------------------------------------------------------
  -- Task table definition (returned from create_task_from_template API)
  -------------------------------------------------------------------------
  l_task_details_table  jtf_tasks_pub.task_details_tbl;

  -------------------------------------------------------------------------
  -- Task table definition (returned from query_task API)
  -------------------------------------------------------------------------
  l_task_table         jtf_tasks_pub.task_table_type;
  l_sort_data          jtf_tasks_pub.sort_data;
  l_start_pointer      NUMBER;
  l_rec_wanted         NUMBER;
  l_retrieved          NUMBER;
  l_returned           NUMBER;
  l_template_name      JTF_TASK_TEMPLATES_VL.TASK_NAME%TYPE;
  l_notif_task_id      JTF_TASKS_VL.TASK_ID%TYPE;
  l_task_assign_id     NUMBER;
  l_obj_version        JTF_TASKS_VL.OBJECT_VERSION_NUMBER%TYPE;
  l_object_name        JTF_OBJECTS_VL.NAME%TYPE;
  l_task_reference_id  JTF_TASK_REFERENCES_VL.TASK_REFERENCE_ID%TYPE;
  l_assign_id          NUMBER;
  l_assign_role        VARCHAR2(80);
  l_owner_id           NUMBER;
  l_owner_role         VARCHAR2(80);
  l_resource_type      JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE;
  l_status_id          VARCHAR2(80);
  l_resultout          VARCHAR2(80);

  -------------------------------------------------------------------------
  -- Cursor to pick Task_template_id from Templeate name
  -- Added for bug 3611893 by ABRAINA
  -------------------------------------------------------------------------
   cursor c_Get_Template_id (p_template_name in varchar2 ) is
   select TASK_TEMPLATE_GROUP_ID
     from JTF_TASK_TEMP_GROUPS_TL
    where TEMPLATE_GROUP_NAME = p_template_name ;

  l_template_id      JTF_TASK_TEMP_GROUPS_TL.TASK_TEMPLATE_GROUP_ID%TYPE;

BEGIN

  Set_Globals( itemtype  => itemtype
             , itemkey   => itemkey
             , actid     => actid
             , funcmode  => funcmode
             , resultout => resultout
             );
  If (resultout = FND_API.G_Ret_Sts_Success)
  THEN
    IF (funcmode = 'RUN')
    THEN
      ---------------------------------------------------------------------
      -- 'RUN' function from WF
      ---------------------------------------------------------------------

      -- -------------------------------------------------------------------
      -- Get appropriate task template name from the Workflow attribute
      -- -------------------------------------------------------------------
      IF (g_object_type_code = 'TASK')
      THEN
        l_template_name := Get_WorkflowAttribute
                           ( p_attr_name   => 'JTF_ESC_TASK_TEMPLATE_TASK'
                           , p_return_type => 'VALUE'
                           );
      ELSIF (g_object_type_code = 'DF')
      THEN
        l_template_name := Get_WorkflowAttribute
                           ( p_attr_name   => 'CSS_ESC_TASK_TEMPLATE_DF'
                           , p_return_type => 'VALUE'
                           );
      ELSIF (g_object_type_code = 'SR')
      THEN
        l_template_name := Get_WorkflowAttribute
                           ( p_attr_name   => 'CS_ESC_TASK_TEMPLATE_SR'
                           , p_return_type => 'VALUE'
                           );
      END IF;
      debug(fnd_log.level_statement,l_api_name,  'template name is: '||l_template_name);
      IF (l_template_name IS NOT NULL)
      THEN
        -------------------------------------------------------------------
        -- Get task owner's role from the Workflow attribute
        -------------------------------------------------------------------
        IF (g_object_type_code = 'TASK')
        THEN
          l_owner_role := Get_WorkflowAttribute
                          ( p_attr_name   => 'JTF_ESC_NOTIF_TASK_OWNER_ROLE'
                          , p_return_type => 'CODE'
                          );
        ELSIF (g_object_type_code = 'DF')
        THEN
          l_owner_role := Get_WorkflowAttribute
                          ( p_attr_name   => 'CSS_ESC_NOTIF_TASK_OWNER_ROLE'
                          , p_return_type => 'CODE'
                          );
        ELSIF (g_object_type_code = 'SR')
        THEN
          l_owner_role := Get_WorkflowAttribute
                          ( p_attr_name   => 'CS_ESC_NOTIF_TASK_OWNER_ROLE'
                          , p_return_type => 'CODE'
                          );
        END IF;
	debug(fnd_log.level_statement, l_api_name,'task owner role is: '||l_owner_role);
        -------------------------------------------------------------------
        -- Get ID of person who is to own the task
        -------------------------------------------------------------------
        l_owner_id := Get_PersonID( p_document_role => l_owner_role
                                  , p_id_type       => 'RESOURCE'
                                  , x_res_type      => l_resource_type
                                  , x_resultout     => l_resultout
                                  );
        IF (l_resultout = FND_API.G_Ret_Sts_Success)
        THEN

	  if c_Get_Template_id%ISOPEN
          then
	    close c_Get_Template_id;
          end if;

	  open  c_Get_Template_id (l_template_name);
	  fetch c_Get_Template_id into l_template_id;
	  close c_Get_Template_id ;

          if c_Get_Template_id%ISOPEN
          then
	    close c_Get_Template_id;
          end if;

	  debug(fnd_log.level_statement, l_api_name,'template id: '||l_template_id);

	  -----------------------------------------------------------------
          -- Create the notification task
          -----------------------------------------------------------------
          JTF_TASKS_PUB.Create_Task_From_Template
          ( p_api_version              => 1.0
          , p_init_msg_list            => FND_API.G_True
          , p_task_template_group_id   => l_template_id
          , p_task_template_group_name => l_template_name
          , p_owner_type_code          => jtf_ec_pub.g_escalation_owner_type_code
          , p_owner_id                 => l_owner_id
          , p_source_object_id         => g_object_id
          , p_source_object_name       => g_jtf_object_name
	  --Added by MPADHIAR for Bug#5068840
          , p_customer_id              => g_customer_id
          , p_cust_account_id          => g_cust_account_id
          , p_address_id               => g_address_id
          --Added by MPADHIAR for Bug#5068840 Ends here
          , x_return_status            => l_return_status
          , x_msg_count                => l_msg_count
          , x_msg_data                 => l_msg_data
          , x_task_details_tbl         => l_task_details_table
          );
          debug(fnd_log.level_statement, l_api_name,'Notification Task creation was : '||l_return_status);
          IF (l_return_status = FND_API.G_Ret_Sts_Success)
          THEN
            l_notif_task_id := l_task_details_table(1).task_id;
            ---------------------------------------------------------------
            -- Need to query back the task to get the object version number
            ---------------------------------------------------------------
            JTF_TASKS_PUB.Query_Task( p_api_version           => 1.0
                                    , p_init_msg_list         => FND_API.G_TRUE
                                    , p_task_id               => l_notif_task_id
                                    , p_sort_data             => l_sort_data
                                    , p_start_pointer         => l_start_pointer
                                    , p_rec_wanted            => l_rec_wanted
                                    , p_show_all              => 'Y'
                                    , x_task_table            => l_task_table
                                    , x_total_retrieved       => l_retrieved
                                    , x_total_returned        => l_returned
                                    , x_return_status         => l_return_status
                                    , x_msg_count             => l_msg_count
                                    , x_msg_data              => l_msg_data
                                    , x_object_version_number => l_obj_version
                                    );
            l_obj_version := l_task_table(1).object_version_number;

            IF (l_return_status = FND_API.G_Ret_Sts_Success)
            THEN
              -------------------------------------------------------------
              -- Update the notification task with name and description
              -------------------------------------------------------------
	      debug(fnd_log.level_statement, l_api_name,'Notification Task created with task id:'|| l_notif_task_id);
              JTF_TASKS_PUB.Update_Task( p_api_version           => 1.0
                                       , p_init_msg_list         => FND_API.G_True
                                       , p_object_version_number => l_obj_version
                                       , p_task_id               => l_notif_task_id
                                       , p_task_name             => g_rule_name
                                       , p_description           => g_rule_desc
                                       , x_return_status         => l_return_status
                                       , x_msg_count             => l_msg_count
                                       , x_msg_data              => l_msg_data
                                       );
              debug(fnd_log.level_statement, l_api_name,'Updation of the notification task completes with : '||l_return_status);

              IF (l_return_status = FND_API.G_Ret_Sts_Success)
              THEN
                -----------------------------------------------------------
                -- Task created successfully
                -- Create reference to source document
                -----------------------------------------------------------
                JTF_TASK_REFERENCES_PUB.Create_References
                ( p_api_version       => 1.0
                , p_init_msg_list     => FND_API.G_True
                , p_task_id           => l_notif_task_id
                , p_object_type_code  => g_object_type_code
                , p_object_name       => g_jtf_object_name
                , p_object_id         => g_object_id
                , p_reference_code    => 'FYI'
                , x_return_status     => l_return_status
                , x_msg_count         => l_msg_count
                , x_msg_data          => l_msg_data
                , x_task_reference_id => l_task_reference_id
                );
                debug(fnd_log.level_statement, l_api_name, 'Reference creation completes with : '||l_return_status);
                IF (l_return_status = FND_API.G_Ret_Sts_Success)
                THEN
                  ---------------------------------------------------------
                  -- Get task assignee's role from the Workflow attribute
                  ---------------------------------------------------------
                  IF (g_object_type_code = 'TASK')
                  THEN
                    l_assign_role := Get_WorkflowAttribute
                             ( p_attr_name   => 'JTF_ESC_NOTIF_TASK_ASSIGN_ROLE'
                             , p_return_type => 'CODE'
                             );
                  ELSIF (g_object_type_code = 'DF')
                  THEN
                    l_assign_role := Get_WorkflowAttribute
                             ( p_attr_name   => 'CSS_ESC_NOTIF_TASK_ASSIGN_ROLE'
                             , p_return_type => 'CODE'
                             );
                  ELSIF (g_object_type_code = 'SR')
                  THEN
                    l_assign_role := Get_WorkflowAttribute
                             ( p_attr_name   => 'CS_ESC_NOTIF_TASK_ASSIGN_ROLE'
                             , p_return_type => 'CODE'
                             );
                  END IF;
		  debug(fnd_log.level_statement, l_api_name, 'Assignee Role to whom task will be assigned : '||l_assign_role);
                  ---------------------------------------------------------
                  -- Get ID of person who is to be assigned the task
                  ---------------------------------------------------------
                  l_assign_id := Get_PersonID
                                 ( p_document_role => l_assign_role
                                 , p_id_type       => 'RESOURCE'
                                 , x_res_type      => l_resource_type
                                 , x_resultout     => l_resultout
                                 );
                  IF (l_resultout = FND_API.G_Ret_Sts_Success)
                  THEN
                    IF (l_assign_id IS NOT NULL)
                    THEN
                      -----------------------------------------------------
                      -- Assign the notification task
                      -----------------------------------------------------
                      l_status_id := FND_PROFILE.Value
                                     ( name => 'JTF_TASK_DEFAULT_TASK_STATUS');

                      JTF_TASK_ASSIGNMENTS_PUB.Create_Task_Assignment
                      ( p_api_version          => 1.0
                      , p_init_msg_list        => FND_API.G_True
                      , p_task_id              => l_notif_task_id
                      , p_resource_type_code   => l_resource_type
                      , p_resource_id          => l_assign_id
                      , p_assignment_status_id => l_status_id
                      , x_return_status        => l_return_status
                      , x_msg_count            => l_msg_count
                      , x_msg_data             => l_msg_data
                      , x_task_assignment_id   => l_task_assign_id
                      );
		      debug(fnd_log.level_statement, l_api_name, 'Assignment creation completes with : '||l_return_status);
                      IF (l_return_status <> FND_API.G_Ret_Sts_Success)
                      THEN
                        ---------------------------------------------------
                        -- Create_Task_Assignment API failed
                        ---------------------------------------------------
                        IF (l_return_status = FND_API.G_Ret_Sts_Error)
                        THEN
                          RAISE FND_API.G_EXC_ERROR;
                        ELSE
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                      END IF;
                    END IF;
                  ELSE
		    debug(fnd_log.level_statement, l_api_name, 'Getting Person ID failed');
                    -------------------------------------------------------
                    -- Get_PersonID (assign_id) failed
                    -------------------------------------------------------
                    IF (l_resultout = FND_API.G_Ret_Sts_Error)
                    THEN
                      RAISE FND_API.G_EXC_ERROR;
                    ELSE
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                  END IF;
                ELSE
                  ---------------------------------------------------------
                  -- Create_References API failed
                  ---------------------------------------------------------
		  debug(fnd_log.level_statement, l_api_name,'Creating Reference failed');
                  IF (l_return_status = FND_API.G_Ret_Sts_Error)
                  THEN
                    RAISE FND_API.G_EXC_ERROR;
                  ELSE
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                END IF;
              ELSE
                -----------------------------------------------------------
                -- Update_Task API failed
                -----------------------------------------------------------
		debug(fnd_log.level_statement, l_api_name,'Update Task failed');
                IF (l_return_status = FND_API.G_Ret_Sts_Error)
                THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSE
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF;
            ELSE
              -------------------------------------------------------------
              -- Query_Task API failed
              -------------------------------------------------------------
	      debug(fnd_log.level_statement, l_api_name,'Query Task failed');
              IF (l_return_status = FND_API.G_Ret_Sts_Error)
              THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;
          ELSE
            debug(fnd_log.level_error, l_api_name,'Creating Task From Template failed');
            ---------------------------------------------------------------
            -- Create_Task_From_Template API failed
            ---------------------------------------------------------------
            IF (l_return_status = FND_API.G_Ret_Sts_Error)
            THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE
          -----------------------------------------------------------------
          -- Get_PersonID (owner_id) failed
          -----------------------------------------------------------------
          debug(fnd_log.level_error, l_api_name,'Getting Person ID failed');
          IF (l_resultout = FND_API.G_Ret_Sts_Error)
          THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      ELSE
        -------------------------------------------------------------------
        -- Invalid profile value for JTF_ESC_TASK_TEMPLATE_NAME
        -------------------------------------------------------------------
        debug(fnd_log.level_error, l_api_name,'invalid profile value for JTF_ESC_TASK_TEMPLATE_NAME');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      ---------------------------------------------------------------------
      -- If we get here then it's all been successful - return 'COMPLETE'
      ---------------------------------------------------------------------
      resultout := 'COMPLETE:' || g_success;
    ELSIF (funcmode = 'CANCEL')
    THEN
      ---------------------------------------------------------------------
      -- 'CANCEL' function from WF
      ---------------------------------------------------------------------
      resultout := 'COMPLETE:' || g_success;
    ELSIF (funcmode = 'TIMEOUT')
    THEN
      ---------------------------------------------------------------------
      -- 'TIMEOUT' function from WF
      ---------------------------------------------------------------------
      resultout := '';
    ELSE
      ---------------------------------------------------------------------
      -- Unknown function from WF - raise error
      ---------------------------------------------------------------------
      debug(fnd_log.level_error, l_api_name,'unknown function from Workflow');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    -----------------------------------------------------------------------
    -- Set_Globals failed
    -----------------------------------------------------------------------
    debug(fnd_log.level_error, l_api_name,'set_globals failed with error:'||resultout);
    IF (resultout = FND_API.G_Ret_Sts_Error)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  debug(fnd_log.level_statement, l_api_name, 'Result Out is '||resultout);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    resultout := 'COMPLETE:' || g_noncritical;
    debug(fnd_log.level_error, l_api_name, ' The error:' || Get_Messages_On_Stack());
    WF_CORE.Context( pkg_name  => g_pkg_name
                   , proc_name => 'Create_NotifTask'
                   , arg1      => itemtype
                   , arg2      => itemkey
                   , arg3      => to_char(actid)
                   , arg4      => funcmode
                   );
    RAISE;
  WHEN OTHERS
  THEN
    resultout := 'COMPLETE:' || g_critical;
    debug(fnd_log.level_unexpected, l_api_name, ' The error:' || Get_Messages_On_Stack());
    WF_CORE.Context( pkg_name     => g_pkg_name
                   , proc_name     => 'Create_NotifTask'
                   , arg1          => itemtype
                   , arg2          => itemkey
                   , arg3          => to_char(actid)
                   , arg4          => funcmode
                   );
    RAISE;

END Create_NotifTask;

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Create_EscTask
--  Description : Call Task Manager API to create escalation task
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype                IN      VARCHAR2 required
--      itemkey                 IN      VARCHAR2 required
--      actid                   IN      NUMBER   required
--      funcmode                IN      VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
PROCEDURE Create_EscTask
  ( itemtype      IN   VARCHAR2
  , itemkey       IN   VARCHAR2
  , actid         IN   NUMBER
  , funcmode      IN   VARCHAR2
  , resultout     OUT NOCOPY  VARCHAR2
  )
IS
  -------------------------------------------------------------------------
  -- Standard API out parameters
  -------------------------------------------------------------------------
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_api_name CONSTANT  VARCHAR2(30) := 'Create_EscTask';

  -------------------------------------------------------------------------
  -- Record and table type descriptions for Escalation API
  -------------------------------------------------------------------------
  l_esc_rec            jtf_ec_pub.esc_rec_type;
  l_esc_ref_docs       jtf_ec_pub.esc_ref_docs_tbl_type;
  l_esc_contacts       jtf_ec_pub.esc_contacts_tbl_type;
  l_esc_cont_phones    jtf_ec_pub.esc_cont_points_tbl_type;
  l_esc_task_id        JTF_TASKS_VL.TASK_ID%TYPE;
  l_esc_task_number    JTF_TASKS_VL.TASK_NUMBER%TYPE;
  l_wf_process_id      NUMBER;
  l_owner_role         VARCHAR2(80);
  l_owner_id           JTF_TASKS_VL.OWNER_ID%TYPE;
  l_wf_role            FND_USER.USER_NAME%TYPE;
  l_resource_type      JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE;
  l_object_name        JTF_OBJECTS_VL.NAME%TYPE;
  l_task_reference_id  JTF_TASK_REFERENCES_VL.TASK_REFERENCE_ID%TYPE;
  l_requester_id       NUMBER;
  l_esc_status         VARCHAR2(80);
  l_esc_level          VARCHAR2(80);
  l_resultout          VARCHAR2(80);
  l_msg                FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  l_msg_name           FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
  l_short_name         VARCHAR2(80);
  l_user_id            number := to_number(fnd_profile.value('USER_ID'));

BEGIN

  Set_Globals( itemtype  => itemtype
             , itemkey   => itemkey
             , actid     => actid
             , funcmode  => funcmode
             , resultout => resultout
             );

  IF (resultout = FND_API.G_Ret_Sts_Success)
  THEN
    IF (funcmode = 'RUN')
    THEN
      ---------------------------------------------------------------------
      -- 'RUN' function from WF
      ---------------------------------------------------------------------
      ---------------------------------------------------------------------
      -- Get esc owner's role from the Workflow attribute.  Get esc level
      -- and default status from the profile options
      ---------------------------------------------------------------------
      debug(  fnd_log.level_statement
           ,  l_api_name
           ,  'funcmode = RUN'
            ||'itemtype '||itemtype
            ||'itemkey'||itemkey
            ||'actid'||actid
           );
      IF (g_object_type_code = 'TASK')
      THEN
        l_owner_role := Get_WorkflowAttribute
                        ( p_attr_name   => 'JTF_ESC_DOCUMENT_OWNER_ROLE'
                        , p_return_type => 'CODE'
                        );
      ELSIF (g_object_type_code = 'DF')
      THEN
        l_owner_role := Get_WorkflowAttribute
                        ( p_attr_name   => 'CSS_ESC_DOCUMENT_OWNER_ROLE'
                        , p_return_type => 'CODE'
                        );
      ELSIF (g_object_type_code = 'SR')
      THEN
        l_owner_role := Get_WorkflowAttribute
                        ( p_attr_name   => 'CS_ESC_DOCUMENT_OWNER_ROLE'
                        , p_return_type => 'CODE'
                        );
      END IF;

      debug(fnd_log.level_statement, l_api_name,'Owner role is: '||l_owner_role);

      l_esc_status := FND_PROFILE.Value
                      ( name => 'JTF_EC_DEFAULT_STATUS'
                      );
      l_esc_level := FND_PROFILE.Value
                     ( name => 'JTF_EC_DEFAULT_ESCALATION_LEVEL'
                     );

      debug(fnd_log.level_statement, l_api_name, 'Escalation status is: '||l_esc_status||' Level is: '||l_esc_level);

      ---------------------------------------------------------------------
      -- Get ID of person who is to own the task
      ---------------------------------------------------------------------
      l_owner_id := Get_PersonID( p_document_role => l_owner_role
                                , p_id_type       => 'RESOURCE'
                                , x_res_type      => l_resource_type
                                , x_resultout     => l_resultout
                                );

      debug(  fnd_log.level_statement
           , l_api_name
           , 'Result Out is:'||l_resultout
		        ||'Owner Id is: '||l_owner_id
		        ||'Res type'||l_resource_type
           );

      IF (l_resultout = FND_API.G_Ret_Sts_Success)
      THEN
        l_esc_rec.esc_owner_id := l_owner_id;
        l_esc_rec.esc_owner_type_code := NVL(l_resource_type,FND_API.G_MISS_CHAR);
        l_esc_rec.esc_name := g_rule_name;
        l_esc_rec.esc_description := g_rule_desc;
        l_esc_rec.status_id := l_esc_status;
        l_esc_rec.escalation_level := l_esc_level;
	--Added by MPADHIAR for Bug#5068840
        l_esc_rec.customer_id := g_customer_id ;
        l_esc_rec.cust_account_id := g_cust_account_id;
        l_esc_rec.cust_address_id := g_address_id;
        --Added by MPADHIAR for Bug#5068840 Ends here
        l_esc_rec.reason_code := 'AUTOMATED';
        l_esc_rec.esc_open_date := SYSDATE;
        l_esc_ref_docs(1).action_code := 'I';
        l_esc_ref_docs(1).object_type_code := g_object_type_code;
        l_esc_ref_docs(1).object_name := g_jtf_object_name;
        l_esc_ref_docs(1).object_id := g_object_id;
        l_esc_ref_docs(1).reference_code := 'ESC';
        l_esc_contacts(1).action_code := 'I';
        l_esc_contacts(1).contact_id := g_rule_owner;
        l_esc_contacts(1).contact_type_code := 'EMP';
        l_esc_contacts(1).escalation_requester_flag := 'Y';

        JTF_EC_PUB.Create_Escalation
        ( p_api_version         => 1.0
        , p_init_msg_list       => FND_API.G_True
        , x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , x_msg_data            => l_msg_data
        , p_user_id             => l_user_id
        , p_esc_record          => l_esc_rec
        , p_reference_documents => l_esc_ref_docs
        , p_esc_contacts        => l_esc_contacts
        , p_cont_points         => l_esc_cont_phones
        , x_esc_id              => l_esc_task_id
        , x_esc_number          => l_esc_task_number
        , x_workflow_process_id => l_wf_process_id
        );
        IF (l_return_status <> FND_API.G_Ret_Sts_Success)
        THEN
          l_msg_count := fnd_msg_pub.count_msg;
          IF l_msg_count > 0
          THEN
            l_msg := ' ' || substr(fnd_msg_pub.get(  fnd_msg_pub.G_FIRST
                                                       , fnd_api.G_FALSE
                                                       ),1, 512);
          END IF;

          FOR iIndex IN 1..(l_msg_count-1) LOOP
            l_msg := l_msg || ' ' || substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT
                                                               ,fnd_api.G_FALSE
                                                               ), 1, 512);

          END LOOP;

          -----------------------------------------------------------------
          -- Create_Escalation API failed
          -----------------------------------------------------------------
          IF (l_return_status = FND_API.G_Ret_Sts_Error)
          THEN
            debug(fnd_log.level_statement, l_api_name, 'Escalation API failed because:'||l_msg||l_msg_count);
            ---------------------------------------------------------------
            -- No need to report the 'document already escalated' error
            ---------------------------------------------------------------
            IF (l_msg_name <> 'JTF_TK_ESC_DOC_EXIST')
            THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          ELSE
            debug(fnd_log.level_statement, l_api_name, 'Escalation API failed with unexpected error'||l_msg||l_msg_count);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      ELSE
        -------------------------------------------------------------------
        -- Get_PersonID failed
        -------------------------------------------------------------------
        debug(fnd_log.level_statement, l_api_name, 'Get_PersonID failed');
        IF (l_resultout = FND_API.G_Ret_Sts_Error)
        THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
      ---------------------------------------------------------------------
      -- If we get here then it's all been successful - return 'COMPLETE'
      ---------------------------------------------------------------------
      resultout := 'COMPLETE:' || g_success;

    ELSIF (funcmode = 'CANCEL')
    THEN
      ---------------------------------------------------------------------
      -- 'CANCEL' function from WF
      ---------------------------------------------------------------------
      resultout := 'COMPLETE:' || g_success;

    ELSIF (funcmode = 'TIMEOUT')
    THEN
      ---------------------------------------------------------------------
      -- 'TIMEOUT' function from WF
      ---------------------------------------------------------------------
      resultout := '';

    ELSE
      ---------------------------------------------------------------------
      -- Unknown function from WF - raise error
      ---------------------------------------------------------------------
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    -----------------------------------------------------------------------
    -- Set_Globals failed
    -----------------------------------------------------------------------
    debug(fnd_log.level_statement, l_api_name,  'Set_Globals is not successful: '||resultout);
    IF (resultout = FND_API.G_Ret_Sts_Error)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  debug(fnd_log.level_statement, l_api_name,  'Return status of the API:'||resultout);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    resultout := 'COMPLETE:' || g_noncritical;

    debug(fnd_log.level_error, l_api_name, 'API returns with Expected Error');

    WF_CORE.Context( pkg_name  => g_pkg_name
                   , proc_name => 'Create_EscTask'
                   , arg1      => itemtype
                   , arg2      => itemkey
                   , arg3      => to_char(actid)
                   , arg4      => funcmode
                   );
    RAISE;
  WHEN OTHERS
  THEN
    resultout := 'COMPLETE:' || g_critical;

    debug(fnd_log.level_unexpected, l_api_name, 'API returns with unexpected error');

    WF_CORE.Context( pkg_name  => g_pkg_name
                   , proc_name => 'Create_EscTask'
                   , arg1      => itemtype
                   , arg2      => itemkey
                   , arg3      => to_char(actid)
                   , arg4      => funcmode
                   );
    RAISE;

END Create_EscTask;

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Get_NotifPerson
--  Description : Work out who is to be notified regarding the escalation
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype                IN      VARCHAR2 required
--      itemkey                 IN      VARCHAR2 required
--      actid                   IN      NUMBER   required
--      funcmode                IN      VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--    Expects WF item attribute 'NTF_PERSON' to be available to this
--    procedure.
--
-- End of comments
----------------------------------------------------------------------------
PROCEDURE Get_NotifPerson
  ( itemtype   IN     VARCHAR2
  , itemkey    IN     VARCHAR2
  , actid      IN     NUMBER
  , funcmode   IN     VARCHAR2
  , resultout     OUT NOCOPY VARCHAR2
  )
IS
  l_notif_role     VARCHAR2(80);
  l_wf_role        FND_USER.USER_NAME%TYPE;
  l_resource_type  JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE;
  l_resultout      VARCHAR2(80);
  l_api_name CONSTANT VARCHAR2(30) := 'Get_NotifPerson';

BEGIN
  Set_Globals( itemtype  => itemtype
             , itemkey   => itemkey
             , actid     => actid
             , funcmode  => funcmode
             , resultout => resultout
             );
  IF (resultout = FND_API.G_Ret_Sts_Success)
  THEN
    IF (funcmode = 'RUN')
    THEN
      ---------------------------------------------------------------------
      -- 'RUN' function from WF
      ---------------------------------------------------------------------

      ---------------------------------------------------------------------
      -- Get notification role from the Workflow attribute
      ---------------------------------------------------------------------
      IF (g_object_type_code = 'TASK')
      THEN
        l_notif_role := Get_WorkflowAttribute
                        ( p_attr_name   => 'JTF_ESC_NOTIF_ROLE'
                        , p_return_type => 'CODE'
                        );
      ELSIF (g_object_type_code = 'DF')
      THEN
        l_notif_role := Get_WorkflowAttribute
                        ( p_attr_name   => 'CSS_ESC_NOTIF_ROLE'
                        , p_return_type => 'CODE'
                        );
      ELSIF (g_object_type_code = 'SR')
      THEN
        l_notif_role := Get_WorkflowAttribute
                        ( p_attr_name   => 'CS_ESC_NOTIF_ROLE'
                        , p_return_type => 'CODE'
                        );
      END IF;
      debug( fnd_log.level_statement, l_api_name, 'Notification role is:'||l_notif_role);
      ---------------------------------------------------------------------
      -- Get ID of person who is to be notified
      ---------------------------------------------------------------------
      g_notif_person_id := Get_PersonID
                           ( p_document_role => l_notif_role
                           , p_id_type       => 'EMPLOYEE'
                           , x_res_type      => l_resource_type
                           , x_resultout     => l_resultout
                           );
      IF (l_resultout = FND_API.G_Ret_Sts_Success)
      THEN
        -------------------------------------------------------------------
        -- Work out WF internal name for the employee
        -------------------------------------------------------------------
        debug(fnd_log.level_statement, l_api_name, 'Finding workflow role of:'||g_notif_person_id);
        l_wf_role := Get_EmployeeRole
                     ( p_employee_id => g_notif_person_id
                     , x_resultout   => l_resultout
                     );
        debug(fnd_log.level_statement, l_api_name, 'Finding Workflow role completed with '||l_resultout);
        IF (l_resultout = FND_API.G_Ret_Sts_Success)
        THEN
          -----------------------------------------------------------------
          -- Set the WF attribute
          -----------------------------------------------------------------
          debug(fnd_log.level_statement, l_api_name, 'Setting the NTF_PERSON with:'||l_wf_role);
          WF_ENGINE.SetItemAttrText( itemtype => itemtype
                                   , itemkey  => itemkey
                                   , aname    => 'NTF_PERSON'
                                   , avalue   => l_wf_role
                                   );
          -----------------------------------------------------------------
          -- If we get here then it's all been successful - return 'COMPLETE'
          -----------------------------------------------------------------
          resultout := 'COMPLETE:' || g_success;
        ELSE
          -----------------------------------------------------------------
          -- Get_EmployeeRole failed
          -----------------------------------------------------------------
          IF (l_resultout = FND_API.G_Ret_Sts_Error)
          THEN
            debug(fnd_log.level_error, l_api_name, 'Getting Employee Role Failed');
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            debug(fnd_log.level_unexpected, l_api_name, 'Getting Employee Role Failed with unexpected error');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      ELSE
        -------------------------------------------------------------------
        -- Get_PersonId failed
        -------------------------------------------------------------------
        debug(fnd_log.level_statement, l_api_name, 'Getting Person ID failed with:'||l_resultout);
        IF (l_resultout = FND_API.G_Ret_Sts_Error)
        THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    ELSIF (funcmode = 'CANCEL')
    THEN
      ---------------------------------------------------------------------
      -- 'CANCEL' function from WF
      ---------------------------------------------------------------------
      resultout := 'COMPLETE:' || g_success;
    ELSIF (funcmode = 'TIMEOUT')
    THEN
      ---------------------------------------------------------------------
      -- 'TIMEOUT' function from WF
      ---------------------------------------------------------------------
      resultout := '';
    ELSE
      ---------------------------------------------------------------------
      -- Unknown function from WF - raise error
      ---------------------------------------------------------------------
      debug(fnd_log.level_unexpected, l_api_name, 'Unknown WF action requested');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    -----------------------------------------------------------------------
    -- Set_Globals failed
    -----------------------------------------------------------------------
    debug(fnd_log.level_unexpected, l_api_name, 'Setting Globals failed with:'||l_resultout);
    IF (resultout = FND_API.G_Ret_Sts_Error)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  debug(fnd_log.level_statement, l_api_name,  'Return status of the API:'||resultout);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    resultout := 'COMPLETE:' || g_noncritical;
    debug(  fnd_log.level_error
          , l_api_name
          , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
          );
    WF_CORE.Context( pkg_name  => g_pkg_name
                   , proc_name => 'Get_NotifPerson'
                   , arg1      => itemtype
                   , arg2      => itemkey
                   , arg3      => to_char(actid)
                   , arg4      => funcmode
                   );
    RAISE;
  WHEN OTHERS
  THEN
    resultout := 'COMPLETE:' || g_critical;
    debug(  fnd_log.level_unexpected
          , l_api_name
          , 'Error occured: Code:'|| SQLCODE || 'Error:'|| SQLERRM
          );
    WF_CORE.Context( pkg_name  => g_pkg_name
                   , proc_name => 'Get_NotifPerson'
                   , arg1      => itemtype
                   , arg2      => itemkey
                   , arg3      => to_char(actid)
                   , arg4      => funcmode
                   );
    RAISE;

END Get_NotifPerson;

END JTF_EscWFActivity_PVT;

/

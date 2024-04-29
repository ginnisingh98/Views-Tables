--------------------------------------------------------
--  DDL for Package Body PJM_TASK_AUTOASSIGN_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_TASK_AUTOASSIGN_COPY" AS
/* $Header: PJMTACRB.pls 115.5 2002/10/29 20:15:19 alaw noship $ */

--
-- Global Declarations
--
G_PKG_NAME     VARCHAR2(30) := 'PJM_TASK_AUTOASSIGN_COPY';

--
-- Private Functions and Procedures
--
FUNCTION Default_Task
( P_Project_ID              IN      NUMBER
, P_Org_ID                  IN      NUMBER
, P_Assignment_Type         IN      VARCHAR2
) RETURN NUMBER IS

CURSOR c IS
  SELECT task_id
  FROM   pjm_default_tasks
  WHERE  organization_id = P_Org_ID
  AND    project_id      = P_Project_ID
  AND    assignment_type = P_Assignment_Type
  AND    inventory_item_id     is null
  AND    category_id           is null
  AND    po_header_id          is null
  AND    subinventory_code     is null
  AND    procure_flag          is null
  AND    standard_operation_id is null
  AND    assembly_item_id      is null
  AND    department_id         is null
  AND    wip_entity_pattern    is null
  AND    wip_matl_txn_type     is null
  AND    to_organization_id    is null;

L_Project_ID      NUMBER       := -1;
L_Org_ID          NUMBER       := -1;
L_Assignment_Type VARCHAR2(30) := '*';
L_Task_ID         NUMBER       := NULL;

BEGIN

  IF (  L_Task_ID IS NULL
     OR ( L_Project_ID <> P_Project_ID
        OR L_Org_ID <> P_Org_ID
        OR L_Assignment_Type <> P_Assignment_Type ) ) THEN

    OPEN c;
    FETCH c INTO L_Task_ID;
    CLOSE c;

    L_Project_ID := P_Project_ID;
    L_Org_ID := P_Org_ID;
    L_Assignment_Type := P_Assignment_Type;

  END IF;

  RETURN ( L_Task_ID );

END Default_Task;


--
-- Functions and Procedures
--
PROCEDURE Copy_Rules
( P_From_Project_ID         IN             NUMBER
, P_To_Project_ID           IN             NUMBER
, P_Organization_ID         IN             NUMBER
, P_Copy_Option             IN             VARCHAR2
, P_Use_Default_Task        IN             VARCHAR2
, X_Return_Status           OUT NOCOPY     VARCHAR2
, X_Msg_Count               OUT NOCOPY     NUMBER
, X_Msg_Data                OUT NOCOPY     VARCHAR2
, X_Count1                  OUT NOCOPY     NUMBER
, X_Count2                  OUT NOCOPY     NUMBER
) IS

CURSOR DSrc IS
  SELECT assignment_type
  ,      project_id
  ,      task_id
  ,      pjm_project.all_task_idtonum( task_id ) task_number
  ,      organization_id
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      inventory_item_id
  ,      category_id
  ,      po_header_id
  ,      subinventory_code
  ,      procure_flag
  ,      standard_operation_id
  ,      assembly_item_id
  ,      department_id
  ,      wip_entity_pattern
  ,      wip_matl_txn_type
  ,      to_organization_id
  ,      comments
  ,      task_attribute_category
  ,      task_attribute1
  ,      task_attribute2
  ,      task_attribute3
  ,      task_attribute4
  ,      task_attribute5
  ,      task_attribute6
  ,      task_attribute7
  ,      task_attribute8
  ,      task_attribute9
  ,      task_attribute10
  ,      task_attribute11
  ,      task_attribute12
  ,      task_attribute13
  ,      task_attribute14
  ,      task_attribute15
  FROM   pjm_default_tasks dt
  WHERE  project_id = P_From_Project_ID
  AND    organization_id = nvl( P_Organization_ID , organization_id )
  AND EXISTS (
    --
    -- Make sure the to project is specified in the organization
    --
    SELECT null
    FROM   pjm_project_parameters
    WHERE  organization_id = dt.organization_id
    AND    project_id = P_To_Project_ID
    UNION ALL
    SELECT null
    FROM   pjm_org_parameters
    WHERE  organization_id = dt.organization_id
    AND    common_project_id = P_To_Project_ID
  )
  AND (
	inventory_item_id     is null
    AND category_id           is null
    AND po_header_id          is null
    AND subinventory_code     is null
    AND procure_flag          is null
    AND standard_operation_id is null
    AND assembly_item_id      is null
    AND department_id         is null
    AND wip_entity_pattern    is null
    AND wip_matl_txn_type     is null
    AND to_organization_id    is null
  ) ORDER BY organization_id , assignment_type;

CURSOR Src IS
  SELECT assignment_type
  ,      project_id
  ,      task_id
  ,      pjm_project.all_task_idtonum( task_id ) task_number
  ,      organization_id
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      inventory_item_id
  ,      category_id
  ,      po_header_id
  ,      subinventory_code
  ,      procure_flag
  ,      standard_operation_id
  ,      assembly_item_id
  ,      department_id
  ,      wip_entity_pattern
  ,      wip_matl_txn_type
  ,      to_organization_id
  ,      comments
  ,      task_attribute_category
  ,      task_attribute1
  ,      task_attribute2
  ,      task_attribute3
  ,      task_attribute4
  ,      task_attribute5
  ,      task_attribute6
  ,      task_attribute7
  ,      task_attribute8
  ,      task_attribute9
  ,      task_attribute10
  ,      task_attribute11
  ,      task_attribute12
  ,      task_attribute13
  ,      task_attribute14
  ,      task_attribute15
  FROM   pjm_default_tasks dt
  WHERE  project_id = P_From_Project_ID
  AND    organization_id = nvl( P_Organization_ID , organization_id )
  AND EXISTS (
    --
    -- Make sure the to project is specified in the organization
    --
    SELECT null
    FROM   pjm_project_parameters
    WHERE  organization_id = dt.organization_id
    AND    project_id = P_To_Project_ID
    UNION ALL
    SELECT null
    FROM   pjm_org_parameters
    WHERE  organization_id = dt.organization_id
    AND    common_project_id = P_To_Project_ID
  )
  AND NOT (
	inventory_item_id     is null
    AND category_id           is null
    AND po_header_id          is null
    AND subinventory_code     is null
    AND procure_flag          is null
    AND standard_operation_id is null
    AND assembly_item_id      is null
    AND department_id         is null
    AND wip_entity_pattern    is null
    AND wip_matl_txn_type     is null
    AND to_organization_id    is null
  ) ORDER BY organization_id , assignment_type;

DSrcRec    DSrc%RowType;
SrcRec     Src%RowType;

UserID     NUMBER := FND_GLOBAL.User_ID;
LoginID    NUMBER := FND_GLOBAL.Login_ID;
ProjNum    VARCHAR2(30);
TaskID     NUMBER := NULL;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT copy_rules;

  X_Count1 := 0;
  X_Count2 := 0;
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  ProjNum := PJM_PROJECT.All_Proj_IDToNum( P_To_Project_ID );

  --
  -- First copy the default assignment rules
  --
  FOR DSrcRec IN DSrc LOOP
    --
    -- Try to find a match in the To Project based on Task Number
    --
    TaskID := PJM_PROJECT.Val_Task_NumToID( ProjNum , DSrcRec.Task_Number );

    IF ( TaskID IS NOT NULL ) THEN
      --
      -- If copy option of "REPLACE" is specified, then update
      -- existing rule if found
      --
      IF ( P_Copy_Option = 'REPLACE' ) THEN

        UPDATE pjm_default_tasks
        SET    task_id           = TaskID
        ,      last_update_date  = SYSDATE
        ,      last_updated_by   = UserID
        ,      last_update_login = LoginID
        WHERE  project_id        = P_To_Project_ID
        AND    organization_id   = DSrcRec.Organization_ID
        AND    assignment_type   = DSrcRec.Assignment_Type
        AND    nvl(inventory_item_id , -1) = nvl(DSrcRec.Inventory_Item_ID , -1)
        AND    nvl(category_id , -1) = nvl(DSrcRec.Category_ID , -1)
        AND    nvl(subinventory_code , '***') = nvl(DSrcRec.Subinventory_Code , '***')
        AND    nvl(po_header_id , -1) = nvl(DSrcRec.PO_Header_ID , -1)
        AND    nvl(procure_flag , '*') = nvl(DSrcRec.Procure_Flag , '*')
        AND    nvl(standard_operation_id , -1) = nvl(DSrcRec.Standard_Operation_ID , -1)
        AND    nvl(department_id , -1) = nvl(DSrcRec.Department_ID , -1)
        AND    nvl(assembly_item_id , -1) = nvl(DSrcRec.Assembly_Item_ID , -1)
        AND    nvl(wip_entity_pattern , '*') = nvl(DSrcRec.WIP_Entity_Pattern , '*')
        AND    nvl(wip_matl_txn_type , '*') = nvl(DSrcRec.WIP_Matl_Txn_Type , '*');

        X_Count1 := X_Count1 + sql%rowcount;

      END IF;

      --
      -- Create new rule only if an identical rule is not found.
      -- This is the default behavior for the "MERGE" copy option.
      -- The UPDATE statement above already handles the copy of the
      -- rule if existing rule is found.
      --
      INSERT INTO pjm_default_tasks
      ( assignment_type
      , project_id
      , task_id
      , organization_id
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , inventory_item_id
      , category_id
      , po_header_id
      , subinventory_code
      , procure_flag
      , standard_operation_id
      , assembly_item_id
      , department_id
      , wip_entity_pattern
      , wip_matl_txn_type
      , to_organization_id
      , comments
      , task_attribute_category
      , task_attribute1
      , task_attribute2
      , task_attribute3
      , task_attribute4
      , task_attribute5
      , task_attribute6
      , task_attribute7
      , task_attribute8
      , task_attribute9
      , task_attribute10
      , task_attribute11
      , task_attribute12
      , task_attribute13
      , task_attribute14
      , task_attribute15 )
      SELECT DSrcRec.Assignment_Type
      ,      P_To_Project_ID
      ,      TaskID
      ,      DSrcRec.Organization_ID
      ,      SYSDATE
      ,      UserID
      ,      SYSDATE
      ,      UserID
      ,      LoginID
      ,      DSrcRec.Inventory_Item_ID
      ,      DSrcRec.Category_ID
      ,      DSrcRec.PO_Header_ID
      ,      DSrcRec.Subinventory_Code
      ,      DSrcRec.Procure_Flag
      ,      DSrcRec.Standard_Operation_ID
      ,      DSrcRec.Assembly_Item_ID
      ,      DSrcRec.Department_ID
      ,      DSrcRec.WIP_Entity_Pattern
      ,      DSrcRec.WIP_Matl_Txn_Type
      ,      DSrcRec.To_Organization_ID
      ,      DSrcRec.Comments
      ,      DSrcRec.Task_Attribute_Category
      ,      DSrcRec.Task_Attribute1
      ,      DSrcRec.Task_Attribute2
      ,      DSrcRec.Task_Attribute3
      ,      DSrcRec.Task_Attribute4
      ,      DSrcRec.Task_Attribute5
      ,      DSrcRec.Task_Attribute6
      ,      DSrcRec.Task_Attribute7
      ,      DSrcRec.Task_Attribute8
      ,      DSrcRec.Task_Attribute9
      ,      DSrcRec.Task_Attribute10
      ,      DSrcRec.Task_Attribute11
      ,      DSrcRec.Task_Attribute12
      ,      DSrcRec.Task_Attribute13
      ,      DSrcRec.Task_Attribute14
      ,      DSrcRec.Task_Attribute15
      FROM   dual
      WHERE NOT EXISTS (
        SELECT NULL
        FROM   pjm_default_tasks
        WHERE  project_id        = P_To_Project_ID
        AND    organization_id   = DSrcRec.Organization_ID
        AND    assignment_type   = DSrcRec.Assignment_Type
        AND    nvl(inventory_item_id , -1) = nvl(DSrcRec.Inventory_Item_ID , -1)
        AND    nvl(category_id , -1) = nvl(DSrcRec.Category_ID , -1)
        AND    nvl(subinventory_code , '***') = nvl(DSrcRec.Subinventory_Code , '***')
        AND    nvl(po_header_id , -1) = nvl(DSrcRec.PO_Header_ID , -1)
        AND    nvl(procure_flag , '*') = nvl(DSrcRec.Procure_Flag , '*')
        AND    nvl(standard_operation_id , -1) = nvl(DSrcRec.Standard_Operation_ID , -1)
        AND    nvl(department_id , -1) = nvl(DSrcRec.Department_ID , -1)
        AND    nvl(assembly_item_id , -1) = nvl(DSrcRec.Assembly_Item_ID , -1)
        AND    nvl(wip_entity_pattern , '*') = nvl(DSrcRec.WIP_Entity_Pattern , '*')
        AND    nvl(wip_matl_txn_type , '*') = nvl(DSrcRec.WIP_Matl_Txn_Type , '*')
      );

      X_Count1 := X_Count1 + sql%rowcount;

    END IF;

    X_Count2 := X_Count2 + 1;

  END LOOP;

  --
  -- Next copy the rest of the assignment rules
  --
  FOR SrcRec IN Src LOOP
    --
    -- Try to find a match in the To Project based on Task Number
    --
    TaskID := PJM_PROJECT.Val_Task_NumToID( ProjNum , SrcRec.Task_Number );

    --
    -- If no match found, and user elects to use the default task,
    -- then get the default task using the private function.
    --
    -- If user elects to skip rule, TaskID is left NULL.  The copy
    -- logic will ignore the rule if TaskID is NULL.
    --
    IF ( TaskID IS NULL AND P_Use_Default_Task = 'Y' ) THEN
      TaskID := Default_Task( P_To_Project_ID , SrcRec.Organization_ID , SrcRec.Assignment_Type );
    END IF;

    IF ( TaskID IS NOT NULL ) THEN
      --
      -- If copy option of "REPLACE" is specified, then update
      -- existing rule if found
      --
      IF ( P_Copy_Option = 'REPLACE' ) THEN

        UPDATE pjm_default_tasks
        SET    task_id           = TaskID
        ,      last_update_date  = SYSDATE
        ,      last_updated_by   = UserID
        ,      last_update_login = LoginID
        WHERE  project_id        = P_To_Project_ID
        AND    organization_id   = SrcRec.Organization_ID
        AND    assignment_type   = SrcRec.Assignment_Type
        AND    nvl(inventory_item_id , -1) = nvl(SrcRec.Inventory_Item_ID , -1)
        AND    nvl(category_id , -1) = nvl(SrcRec.Category_ID , -1)
        AND    nvl(subinventory_code , '***') = nvl(SrcRec.Subinventory_Code , '***')
        AND    nvl(po_header_id , -1) = nvl(SrcRec.PO_Header_ID , -1)
        AND    nvl(procure_flag , '*') = nvl(SrcRec.Procure_Flag , '*')
        AND    nvl(standard_operation_id , -1) = nvl(SrcRec.Standard_Operation_ID , -1)
        AND    nvl(department_id , -1) = nvl(SrcRec.Department_ID , -1)
        AND    nvl(assembly_item_id , -1) = nvl(SrcRec.Assembly_Item_ID , -1)
        AND    nvl(wip_entity_pattern , '*') = nvl(SrcRec.WIP_Entity_Pattern , '*')
        AND    nvl(wip_matl_txn_type , '*') = nvl(SrcRec.WIP_Matl_Txn_Type , '*');

        X_Count1 := X_Count1 + sql%rowcount;

      END IF;

      --
      -- Create new rule only if an identical rule is not found.
      -- This is the default behavior for the "MERGE" copy option.
      -- The UPDATE statement above already handles the copy of the
      -- rule if existing rule is found.
      --
      INSERT INTO pjm_default_tasks
      ( assignment_type
      , project_id
      , task_id
      , organization_id
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , inventory_item_id
      , category_id
      , po_header_id
      , subinventory_code
      , procure_flag
      , standard_operation_id
      , assembly_item_id
      , department_id
      , wip_entity_pattern
      , wip_matl_txn_type
      , to_organization_id
      , comments
      , task_attribute_category
      , task_attribute1
      , task_attribute2
      , task_attribute3
      , task_attribute4
      , task_attribute5
      , task_attribute6
      , task_attribute7
      , task_attribute8
      , task_attribute9
      , task_attribute10
      , task_attribute11
      , task_attribute12
      , task_attribute13
      , task_attribute14
      , task_attribute15 )
      SELECT SrcRec.Assignment_Type
      ,      P_To_Project_ID
      ,      TaskID
      ,      SrcRec.Organization_ID
      ,      SYSDATE
      ,      UserID
      ,      SYSDATE
      ,      UserID
      ,      LoginID
      ,      SrcRec.Inventory_Item_ID
      ,      SrcRec.Category_ID
      ,      SrcRec.PO_Header_ID
      ,      SrcRec.Subinventory_Code
      ,      SrcRec.Procure_Flag
      ,      SrcRec.Standard_Operation_ID
      ,      SrcRec.Assembly_Item_ID
      ,      SrcRec.Department_ID
      ,      SrcRec.WIP_Entity_Pattern
      ,      SrcRec.WIP_Matl_Txn_Type
      ,      SrcRec.To_Organization_ID
      ,      SrcRec.Comments
      ,      SrcRec.Task_Attribute_Category
      ,      SrcRec.Task_Attribute1
      ,      SrcRec.Task_Attribute2
      ,      SrcRec.Task_Attribute3
      ,      SrcRec.Task_Attribute4
      ,      SrcRec.Task_Attribute5
      ,      SrcRec.Task_Attribute6
      ,      SrcRec.Task_Attribute7
      ,      SrcRec.Task_Attribute8
      ,      SrcRec.Task_Attribute9
      ,      SrcRec.Task_Attribute10
      ,      SrcRec.Task_Attribute11
      ,      SrcRec.Task_Attribute12
      ,      SrcRec.Task_Attribute13
      ,      SrcRec.Task_Attribute14
      ,      SrcRec.Task_Attribute15
      FROM   dual
      WHERE NOT EXISTS (
        SELECT NULL
        FROM   pjm_default_tasks
        WHERE  project_id        = P_To_Project_ID
        AND    organization_id   = SrcRec.Organization_ID
        AND    assignment_type   = SrcRec.Assignment_Type
        AND    nvl(inventory_item_id , -1) = nvl(SrcRec.Inventory_Item_ID , -1)
        AND    nvl(category_id , -1) = nvl(SrcRec.Category_ID , -1)
        AND    nvl(subinventory_code , '***') = nvl(SrcRec.Subinventory_Code , '***')
        AND    nvl(po_header_id , -1) = nvl(SrcRec.PO_Header_ID , -1)
        AND    nvl(procure_flag , '*') = nvl(SrcRec.Procure_Flag , '*')
        AND    nvl(standard_operation_id , -1) = nvl(SrcRec.Standard_Operation_ID , -1)
        AND    nvl(department_id , -1) = nvl(SrcRec.Department_ID , -1)
        AND    nvl(assembly_item_id , -1) = nvl(SrcRec.Assembly_Item_ID , -1)
        AND    nvl(wip_entity_pattern , '*') = nvl(SrcRec.WIP_Entity_Pattern , '*')
        AND    nvl(wip_matl_txn_type , '*') = nvl(SrcRec.WIP_Matl_Txn_Type , '*')
      );

      X_Count1 := X_Count1 + sql%rowcount;

    END IF;

    X_Count2 := X_Count2 + 1;

  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK TO copy_rules;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'COPY_RULES');
  END IF;
  FND_MSG_PUB.Count_And_Get( p_count => X_Msg_Count
                           , p_data  => X_Msg_Data );

END Copy_Rules;


END PJM_TASK_AUTOASSIGN_COPY;

/

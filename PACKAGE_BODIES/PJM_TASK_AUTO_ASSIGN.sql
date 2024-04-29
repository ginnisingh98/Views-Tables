--------------------------------------------------------
--  DDL for Package Body PJM_TASK_AUTO_ASSIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_TASK_AUTO_ASSIGN" AS
/* $Header: PJMTKASB.pls 120.0.12010000.2 2008/09/13 08:13:49 rrajkule ship $ */

--  ---------------------------------------------------------------------
--  Private Functions and Procedures
--  ---------------------------------------------------------------------

--
--  Name          : Is_Project
--
--  Function      : This boolean function checks whether a given
--                  project_id references a PA project or a seiban
--                  number.
--
--  Returns       : TRUE if a PA project, FALSE otherwise
--
--  Parameters    :
--  IN            : X_project_id                     NUMBER
--
FUNCTION is_project (X_project_id IN NUMBER) RETURN BOOLEAN
IS
CURSOR p IS
  SELECT 1
  FROM pa_projects_all
  WHERE  project_id = X_project_id;
L_project_flag NUMBER;
BEGIN
  if (X_project_id is null) then
    return FALSE;
  end if;

  OPEN p;
  FETCH p INTO L_project_flag;
  CLOSE p;

  if (L_project_flag = 1) then
    return TRUE;
  else
    return FALSE;
  end if;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    raise;

END is_project;


--
--  Name          : Get_Item_Category
--
--  Function      : This function returns the category associated
--                  with the item in the Inventory functional
--                  area.
--
--  Returns       : Category_Id
--
--  Parameters    :
--  IN            : X_org_id                         NUMBER
--                : X_item_id                        NUMBER
--
FUNCTION Get_Item_Category ( X_org_id   IN NUMBER
                           , X_item_id  IN NUMBER )
RETURN NUMBER IS

L_category_id NUMBER;

CURSOR c ( C_org_id   NUMBER
         , C_item_id  NUMBER )
IS
  SELECT mic.category_id
  FROM   mtl_item_categories       mic
  ,      mtl_default_category_sets mdcs
  WHERE  mdcs.functional_area_id = 1
  AND    mic.category_set_id     = mdcs.category_set_id
  AND    mic.inventory_item_id   = C_item_id
  AND    mic.organization_id     = C_org_id;

BEGIN
  if ( X_item_id is not null ) then
    open c ( X_org_id, X_item_id);
    fetch c into L_category_id;
    close c;
  else
    L_Category_id := NULL;
  end if;
  return ( L_Category_id );

EXCEPTION
  WHEN OTHERS THEN
    raise;

END Get_Item_Category;


--
--  Name          : Flag_INV_Error
--
--  Function      : This procedure marks the transaction as Cost
--                  Collection failed and populates the appropriate
--                  error columns in MTL_MATERIAL_TRANSACTIONS
--
--  Parameters    :
--  IN            : X_transaction_id                 NUMBER
--
--  IN OUT        : X_error_num                      NUMBER
--                : X_error_code                     VARCHAR2
--                : X_error_msg                      VARCHAR2
--
PROCEDURE flag_inv_error
  ( X_transaction_id   IN            NUMBER
  , X_error_num        IN OUT NOCOPY NUMBER
  , X_error_code       IN            VARCHAR2
  , X_error_msg        IN OUT NOCOPY VARCHAR2)
IS
L_stmt_num NUMBER;
BEGIN

    L_stmt_num := 10;

    UPDATE mtl_material_transactions
    SET    error_code             = X_error_code
    ,      error_explanation      = X_error_msg
    ,      pm_cost_collected      = 'E'
    ,      last_update_date       = sysdate
    ,      last_updated_by        = fnd_global.user_id
    ,      request_id             = fnd_global.conc_request_id
    ,      program_application_id = fnd_global.prog_appl_id
    ,      program_id             = fnd_global.conc_program_id
    ,      program_update_date    = sysdate
    WHERE  transaction_id = X_transaction_id;

EXCEPTION
  WHEN OTHERS THEN
    X_error_num := sqlcode;
    X_error_msg := 'TKAA-INVE(' || L_stmt_num || ')->' || sqlerrm;

END flag_inv_error;

--
--  Name          : Flag_WIP_Error
--
--  Function      : This procedure marks the transaction as Cost
--                  Collection failed and creates the appropriate
--                  entry in the WIP transaction error table
--
--  Parameters    :
--  IN            : X_transaction_id                 NUMBER
--
--  IN OUT        : X_error_num                      NUMBER
--                : X_error_msg                      VARCHAR2
--
PROCEDURE flag_wip_error
  ( X_transaction_id   IN            NUMBER
  , X_error_num        IN OUT NOCOPY NUMBER
  , X_error_msg        IN OUT NOCOPY VARCHAR2)
IS
L_user_id      NUMBER;
L_request_id   NUMBER;
L_prog_appl_id NUMBER;
L_prog_id      NUMBER;
L_login_id     NUMBER;
L_stmt_num     NUMBER;
BEGIN

  L_user_id      := fnd_global.user_id;
  L_login_id     := fnd_global.conc_login_id;
  L_request_id   := fnd_global.conc_request_id;
  L_prog_appl_id := fnd_global.prog_appl_id;
  L_prog_id      := fnd_global.conc_program_id;

  L_stmt_num := 10;

  UPDATE wip_transactions
  SET    pm_cost_collected      = 'E'
  ,      last_update_date       = sysdate
  ,      last_updated_by        = L_user_id
  ,      request_id             = L_request_id
  ,      program_application_id = L_prog_appl_id
  ,      program_id             = L_prog_id
  ,      program_update_date    = sysdate
  WHERE  transaction_id = X_transaction_id;

  L_stmt_num := 20;

  UPDATE wip_txn_interface_errors
  SET    error_message          = X_error_msg
  ,      last_update_date       = sysdate
  ,      last_updated_by        = L_user_id
  ,      request_id             = L_request_id
  ,      program_application_id = L_prog_appl_id
  ,      program_id             = L_prog_id
  ,      program_update_date    = sysdate
  WHERE  transaction_id = X_transaction_id
  AND    error_column   = 'TASK_ID';

  if sql%notfound then

    L_stmt_num := 30;

    INSERT INTO wip_txn_interface_errors
    ( transaction_id
    , error_message
    , error_column
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login
    , request_id
    , program_application_id
    , program_id
    , program_update_date)
    VALUES ( X_transaction_id
    ,        X_error_msg
    ,        'TASK_ID'
    ,        sysdate
    ,        L_user_id
    ,        sysdate
    ,        L_user_id
    ,        L_login_id
    ,        L_request_id
    ,        L_prog_appl_id
    ,        L_prog_id
    ,        sysdate
    );

  end if;

EXCEPTION
  WHEN OTHERS THEN
    X_error_num := sqlcode;
    X_error_msg := 'TKAA-WIPE(' || L_stmt_num || ')->' || sqlerrm;

END flag_wip_error;

--  ---------------------------------------------------------------------
--  Public Functions and Procedures
--  ---------------------------------------------------------------------

--
--  Name          : Inv_Task_WNPS
--
--  Function      : This function returns a task based on predefined
--                  rules and is specially designed for using in
--                  views.
--
--  Parameters    :
--  IN            : X_org_id                         NUMBER
--                : X_project_id                     NUMBER
--                : X_item_id                        NUMBER
--                : X_po_header_id                   NUMBER
--                : X_category_id                    NUMBER
--                : X_subinv_code                    VARCHAR2
--
FUNCTION Inv_Task_WNPS ( X_org_id        IN NUMBER
                       , X_project_id    IN NUMBER
                       , X_item_id       IN NUMBER
                       , X_po_header_id  IN NUMBER
                       , X_category_id   IN NUMBER
                       , X_subinv_code   IN VARCHAR2 )
RETURN NUMBER IS

L_task_id     NUMBER;
L_category_id NUMBER;
L_procured    VARCHAR2(1);
i             NUMBER := 1;
TYPE t_AttributeTable IS TABLE OF pjm_task_attr_usages.attribute_code%TYPE
  INDEX BY BINARY_INTEGER;
v_Attributes  t_AttributeTable;

CURSOR c1 IS
	   SELECT attribute_code
	   FROM   pjm_task_attr_usages
	   WHERE  assignment_type = 'MATERIAL'
 	   ORDER BY sequence_number;

CURSOR c2 ( C_org_id        NUMBER
          , C_proj_id       NUMBER
          , C_item_id       NUMBER
          , C_po_header_id  NUMBER
          , C_cat_id        NUMBER
          , C_procured      VARCHAR2
          , C_subinv_code   VARCHAR2 )
IS
  SELECT task_id
  FROM   pjm_default_tasks
  WHERE  organization_id = C_org_id
  AND    project_id = C_proj_id
  AND    NVL(inventory_item_id, nvl(C_item_id,-1)) = nvl(C_item_id,-1)
  AND    NVL(po_header_id, nvl(C_po_header_id,-1)) = nvl(C_po_header_id,-1)
  AND    NVL(category_id, nvl(C_cat_id,-1)) = nvl(C_cat_id,-1)
  AND    NVL(subinventory_code, nvl(C_subinv_code,' ')) =
                                       nvl(C_subinv_code,' ')
  AND    NVL(procure_flag, nvl(C_procured,'*')) = nvl(C_procured,'*')
  AND    assignment_type = 'MATERIAL'
  ORDER BY decode(v_attributes(1), 'ITEM_NUMBER', to_char(inventory_item_id),
                                   'PO_NUMBER',   to_char(po_header_id),
                                   'CATEGORY',    to_char(category_id),
                                   'SUBINVENTORY',subinventory_code,
                                   'PROCURE_FLAG',procure_flag) ASC

  ,        decode(v_attributes(2), 'ITEM_NUMBER', to_char(inventory_item_id),
                                   'PO_NUMBER',   to_char(po_header_id),
                                   'CATEGORY',    to_char(category_id),
                                   'SUBINVENTORY',subinventory_code,
                                   'PROCURE_FLAG',procure_flag) ASC

  ,        decode(v_attributes(3), 'ITEM_NUMBER', to_char(inventory_item_id),
                                   'PO_NUMBER',   to_char(po_header_id),
                                   'CATEGORY',    to_char(category_id),
                                   'SUBINVENTORY',subinventory_code,
                                   'PROCURE_FLAG',procure_flag)      ASC

  ,        decode(v_attributes(4), 'ITEM_NUMBER', to_char(inventory_item_id),
                                   'PO_NUMBER',   to_char(po_header_id),
                                   'CATEGORY',    to_char(category_id),
                                   'SUBINVENTORY',subinventory_code,
                                   'PROCURE_FLAG',procure_flag)      ASC

  ,        decode(v_attributes(5), 'ITEM_NUMBER', to_char(inventory_item_id),
                                   'PO_NUMBER',   to_char(po_header_id),
                                   'CATEGORY',    to_char(category_id),
                                   'SUBINVENTORY',subinventory_code,
                                   'PROCURE_FLAG',procure_flag)      ASC;

BEGIN
  if ( X_category_id is not null ) then
    L_category_id := X_category_id;
  else
    L_category_id := Get_Item_Category(X_org_id, X_item_id);
  end if;

  if ( X_po_header_id > 0 ) then
    L_procured := 'Y';
  else
    L_procured := 'N';
  end if;
  /* Added the initialization code for the bug 1777435 */
  for i in 1..5
  loop
     v_attributes(i) := NULL;
  end loop;
  open c1;
  loop
    fetch c1 into v_attributes(i);
    if c1%notfound then
      exit;
    end if;
    i := i + 1;
  end loop;

  close c1;     /*Bug 6716738 (FP of 6622081): Close the cursor C1*/

  open c2 ( X_org_id
          , X_project_id
          , X_item_id
          , X_po_header_id
          , L_category_id
          , L_procured
          , X_subinv_code );
  fetch c2 into L_task_id;
  close c2;
  return L_task_id;

end Inv_Task_WNPS;


--
--  Name          : Wip_Task_WNPS
--
--  Function      : This function returns a task based on predefined
--                  rules and is specially designed for using in
--                  views.
--
--  Parameters    :
--  IN            : X_org_id                         NUMBER
--                : X_project_id                     NUMBER
--                : X_operation_id                   NUMBER
--                : X_wip_entity_id                  NUMBER
--                : X_assy_item_id                   NUMBER
--                : X_dept_id                        NUMBER
--
FUNCTION Wip_Task_WNPS ( X_org_id         IN NUMBER
                       , X_project_id     IN NUMBER
                       , X_operation_id   IN NUMBER
                       , X_wip_entity_id  IN NUMBER
                       , X_assy_item_id   IN NUMBER
                       , X_dept_id        IN NUMBER )
RETURN NUMBER IS

L_task_id     NUMBER;
L_wip_entity  VARCHAR2(240);
i             NUMBER := 1;
TYPE t_AttributeTable IS TABLE OF pjm_task_attr_usages.attribute_code%TYPE
  INDEX BY BINARY_INTEGER;
v_Attributes  t_AttributeTable;

CURSOR c1 IS
	   SELECT attribute_code
	   FROM   pjm_task_attr_usages
	   WHERE  assignment_type = 'RESOURCE'
	   ORDER BY sequence_number;

CURSOR c2 ( C_org_id        NUMBER
          , C_proj_id       NUMBER
          , C_operation_id  NUMBER
          , C_wip_entity    VARCHAR2
          , C_assy_item_id  NUMBER
          , C_dept_id       NUMBER )
IS
  SELECT task_id
  FROM pjm_default_tasks
  WHERE organization_id = C_org_id
  AND   project_id = C_proj_id
  AND   NVL(standard_operation_id,
            nvl(C_operation_id,-1)) = nvl(C_operation_id,-1)
  AND   C_wip_entity like nvl(wip_entity_pattern , '%')
  AND   NVL(assembly_item_id,
            nvl(C_assy_item_id,-1)) = nvl(C_assy_item_id,-1)
  AND   NVL(department_id, nvl(C_dept_id,-1)) = nvl(C_dept_id,-1)
  AND   assignment_type = 'RESOURCE'
  ORDER BY decode(v_attributes(1),
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern))
                  ) ASC
  ,        decode(v_attributes(2),
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern))
                  ) ASC
  ,        decode(v_attributes(3),
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern))
                  ) ASC
  ,        decode(v_attributes(4),
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern))
                  ) ASC
  ,        instr(wip_entity_pattern||'*%','%') DESC
  ;

CURSOR c_wip ( C_org_id        NUMBER
             , C_wip_entity_id NUMBER )
IS
  SELECT wip_entity_name
  FROM   wip_entities
  WHERE  organization_id = C_org_id
  AND    wip_entity_id   = C_wip_entity_id;

BEGIN
    /* Added the initialization code for the bug 1777435 */
    for i in 1..4
    loop
      v_attributes(i) := NULL;
    end loop;
    open c1;
    loop
      fetch c1 into v_attributes(i);
      if c1%notfound then
        exit;
      end if;
      i := i + 1;
    end loop;

    close c1;     /*Bug 6716738 (FP of 6622081): Close the cursor C1*/

    open c_wip ( X_org_id, X_wip_entity_id );
    fetch c_wip into L_wip_entity;
    close c_wip;
    open c2 ( X_org_id
            , X_project_id
            , X_operation_id
            , L_wip_entity
            , X_assy_item_id
            , X_dept_id );
    fetch c2 into L_task_id;
    close c2;

    return( L_task_id );
END Wip_Task_WNPS;

--  Name 	  : WipMat_Task_WNPS
--
--  Function	  : This function returns a task based on predefined
--		    rules and is specially designed for using in
--		    views.
--
--  Parameters    :
--  IN	 	  : X_org_id		NUMBER
--		  : X_project_id	NUMBER
--		  : X_item_id		NUMBER
--		  : X_category_id	NUMBER
--                : X_subinv_code       VARCHAR2
--                : X_wip_matl_txn_type VARCHAR2
--                : X_wip_entity_id     NUMBER
--                : X_assy_item_id      NUMBER
--                : X_operation_id      NUMBER
--                : X_dept_id           NUMBER
--

FUNCTION WipMat_Task_WNPS ( X_org_id            IN NUMBER
                          , X_project_id        IN NUMBER
                          , X_item_id           IN NUMBER
                          , X_category_id       IN NUMBER
                          , X_subinv_code       IN VARCHAR2
                          , X_wip_matl_txn_type IN VARCHAR2
                          , X_wip_entity_id     IN NUMBER
                          , X_assy_item_id      IN NUMBER
                          , X_operation_id      IN NUMBER
                          , X_dept_id           IN NUMBER )
RETURN NUMBER IS

L_task_id     NUMBER;
L_category_id NUMBER;
L_wip_entity  VARCHAR2(240);
i             NUMBER := 1;
TYPE t_AttributeTable IS TABLE OF pjm_task_attr_usages.attribute_code%TYPE
  INDEX BY BINARY_INTEGER;
v_Attributes  t_AttributeTable;

CURSOR c1 IS
  SELECT attribute_code
  FROM   pjm_task_attr_usages
  WHERE  assignment_type = 'WIPMAT'
  ORDER BY sequence_number;

CURSOR c2 ( C_org_id             NUMBER
          , C_proj_id            NUMBER
          , C_item_id            NUMBER
          , C_cat_id             NUMBER
          , C_subinv_code        VARCHAR2
          , C_wip_matl_txn_type  VARCHAR2
          , C_wip_entity         VARCHAR2
          , C_assy_item_id       NUMBER
          , C_operation_id       NUMBER
          , C_dept_id            NUMBER )
IS
  SELECT task_id
  FROM   pjm_default_tasks
  WHERE  organization_id = C_org_id
  AND    project_id = C_proj_id
  AND    NVL(inventory_item_id, nvl(C_item_id,-1)) = nvl(C_item_id,-1)
  AND    NVL(category_id, nvl(C_cat_id,-1)) = nvl(C_cat_id,-1)
  AND    NVL(subinventory_code, nvl(C_subinv_code,' ')) =
                                       nvl(C_subinv_code,' ')
  AND    NVL(wip_matl_txn_type, nvl(C_wip_matl_txn_type,'ANY')) =
                                    nvl(C_wip_matl_txn_type,'ANY')
  AND    C_wip_entity like nvl(wip_entity_pattern , '%')
  AND    NVL(assembly_item_id, nvl(C_assy_item_id,-1)) =
                                       nvl(C_assy_item_id,-1)
  AND    NVL(standard_operation_id,  nvl(C_operation_id,-1)) =
                                    nvl(C_operation_id,-1)
  AND    NVL(department_id, nvl(C_dept_id,-1)) = nvl(C_dept_id,-1)
  AND    assignment_type = 'WIPMAT'
  ORDER BY decode(v_attributes(1),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(2),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(3),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(4),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(5),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(6),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(7),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        decode(v_attributes(8),
                  'ITEM_NUMBER',        to_char(inventory_item_id),
                  'CATEGORY',           to_char(category_id),
                  'SUBINVENTORY',       subinventory_code,
                  'DEPARTMENT',         department_id,
                  'STANDARD_OPERATION', standard_operation_id,
                  'ASSEMBLY_ITEM',      assembly_item_id,
                  'WIP_ENTITY',         sign(length(wip_entity_pattern)),
                  'WIP_MATL_TXN_TYPE',  wip_matl_txn_type
                  ) ASC
  ,        instr(wip_entity_pattern||'*%','%') DESC
  ;

CURSOR c_wip ( C_org_id        NUMBER
             , C_wip_entity_id NUMBER )
IS
  SELECT wip_entity_name
  FROM   wip_entities
  WHERE  organization_id = C_org_id
  AND    wip_entity_id   = C_wip_entity_id;

BEGIN
  if ( X_category_id is not null ) then
    L_category_id := X_category_id;
  else
    L_category_id := Get_Item_Category(X_org_id, X_item_id);
  end if;

  for i in 1..8
  loop
     v_attributes(i) := NULL;
  end loop;

  open c1;
  loop
    fetch c1 into v_attributes(i);
    if c1%notfound then
      exit;
    end if;
    i := i + 1;
  end loop;

  --
  -- To preserve backward compatibility, if WIP material FlexSequences
  -- are not defined, use Material rules instead
  --
  if ( v_attributes(1) is NULL ) then

    L_task_id := Inv_Task_WNPS( X_org_id
                              , X_project_id
                              , X_item_id
                              , NULL
                              , L_category_id
                              , X_subinv_code );

  else

    open c_wip ( X_org_id, X_wip_entity_id );
    fetch c_wip into L_wip_entity;
    close c_wip;

    open c2 ( X_org_id
            , X_project_id
            , X_item_id
            , L_category_id
            , X_subinv_code
            , X_wip_matl_txn_type
            , L_wip_entity
            , X_assy_item_id
            , X_operation_id
            , X_dept_id );
    fetch c2 into L_task_id;
    close c2;

  end if;

  return L_task_id;

end WipMat_Task_WNPS;


--  Function 	  : This function returns a task based on predefined
--		    rules and is specially designed for using in
--		    views.
--
--  Parameters    :
--  IN		  : X_org_id		NUMBER
--  		  : X_project_id	NUMBER
--		  : X_item_id		NUMBER
--		  : X_category_id  	NUMBER
--		  : X_to_org_id		NUMBER
--

FUNCTION SCP_Task_WNPS ( X_org_id	IN NUMBER
		       , X_project_id   IN NUMBER
		       , X_item_id      IN NUMBER
		       , X_category_id  IN NUMBER
		       , X_to_org_id    IN NUMBER )
RETURN NUMBER IS

L_task_id	NUMBER;
L_category_id   NUMBER;

CURSOR c ( C_org_id	  NUMBER
	 , C_proj_id	  NUMBER
	 , C_item_id	  NUMBER
	 , C_cat_id	  NUMBER
	 , C_to_org_id    NUMBER )
IS
  SELECT task_id
  FROM   pjm_default_tasks
  WHERE  organization_id = c_org_id
  AND    project_id = c_proj_id
  AND    NVL(inventory_item_id, nvl(c_item_id, -1)) = nvl(c_item_id, -1)
  AND    NVL(category_id, nvl(c_cat_id, -1)) = nvl(c_cat_id, -1)
  AND    NVL(to_organization_id, nvl(c_to_org_id, -1)) = nvl(c_to_org_id,-1)
  AND    assignment_type = 'SUPPLY CHAIN'
  ORDER BY inventory_item_id  	ASC
  ,	   category_id		ASC
  ,	   to_organization_id	ASC;

BEGIN
  if ( X_category_id is not null ) then
    L_category_id := X_category_id;
  else
    L_category_id := Get_Item_Category(X_org_id, X_item_id);
  end if;

  open c( X_org_id
        , X_project_id
        , X_item_id
        , L_category_id
        , X_to_org_id );
  fetch c into L_task_id;
  close c;
  return L_task_id;

END SCP_Task_WNPS;



--
--  Name          : Assign_Task_Inv
--
--  Function      : This procedure assigns a task based on predefined
--                  rules if a material transaction has project
--                  references but no task references.  If assignment
--                  rule cannot be found, the transaction will be
--                  flagged as error and Cost Collection will not be
--                  performed
--
--  Parameters    :
--  IN            : X_transaction_id                 NUMBER
--
--  IN OUT        : X_error_num                      NUMBER
--                : X_error_msg                      VARCHAR2
--
PROCEDURE assign_task_inv
  ( X_transaction_id   IN            NUMBER
  , X_error_num        IN OUT NOCOPY NUMBER
  , X_error_msg        IN OUT NOCOPY VARCHAR2)
IS

L_txn_src_type  NUMBER;
L_item_id       NUMBER;
L_po_header_id  NUMBER;
L_cat_id        NUMBER;
L_org_id        NUMBER;
L_subinv_code   VARCHAR2(10);
L_proj_id       NUMBER;
L_task_id       NUMBER;
L_txfr_org_id   NUMBER;
L_txfr_txn_id   NUMBER;
L_txfr_subinv   VARCHAR2(10);
L_to_org_id     NUMBER;
L_to_subinv     VARCHAR2(10);
L_to_cat_id     NUMBER;
L_to_proj_id    NUMBER;
L_to_task_id    NUMBER;
L_src_proj_id   NUMBER;
L_src_task_id   NUMBER;
L_direction     NUMBER;
L_txn_type      VARCHAR2(30);
L_wip_entity    NUMBER;
L_assy_item_id  NUMBER;
L_dept_id       NUMBER;
L_operation_id  NUMBER;
L_stmt_num      NUMBER;
L_proj_check    BOOLEAN;
L_error_code    VARCHAR2(50);

Rule_not_found  EXCEPTION;

CURSOR c1 ( C_transaction_id NUMBER )
IS
  SELECT organization_id
  ,      inventory_item_id
  ,      subinventory_code
  ,      transaction_source_type_id
  ,      decode(transaction_source_type_id,
                1, transaction_source_id,
                   -1)
  ,      project_id
  ,      task_id
  ,      sign(primary_quantity)
  ,      transfer_organization_id
  ,      transfer_transaction_id
  ,      transfer_subinventory
  ,      to_project_id
  ,      to_task_id
  ,      source_project_id
  ,      source_task_id
  FROM   mtl_material_transactions
  WHERE  transaction_id = C_transaction_id;

CURSOR c_wip ( C_transaction_id NUMBER )
IS
  SELECT decode(t.transaction_type_id,
                35 , 'ISSUE'      , -- WIP component issue
                38 , 'ISSUE'      , -- WIP Neg Comp Issue
                43 , 'ISSUE'      , -- WIP Component Return
                48 , 'ISSUE'      , -- WIP Neg Comp Return
                17 , 'COMPLETION' , -- WIP Assembly Return
                44 , 'COMPLETION' , -- WIP Assy Completion
                NULL)
  ,      decode(t.transaction_source_type_id,
                5, t.transaction_source_id,
                   null)
  ,      e.primary_item_id
  ,      t.department_id
  ,      o.standard_operation_id
  FROM   mtl_material_transactions t
  ,      wip_entities   e
  ,      wip_operations o
  WHERE  transaction_id = C_transaction_id
  AND    e.organization_id = t.organization_id
  AND    e.wip_entity_id = t.transaction_source_id
  AND    o.organization_id (+) = t.organization_id
  AND    o.wip_entity_id (+) = t.transaction_source_id
  AND    o.operation_seq_num (+) = t.operation_seq_num;

--
-- This cursor returns the intransit owning org for a transfer
-- transaction.  The rules from the intransit owning org should
-- be used to derive the opposite task of a transfer transaction
--
CURSOR o ( C_org_id       NUMBER
         , C_txfr_org_id  NUMBER
         , C_direction    NUMBER )
IS
  SELECT decode( fob_point
               , 1 , to_organization_id
               , 2 , from_organization_id
                   , C_txfr_org_id ) intransit_org_id
  FROM   mtl_interorg_parameters
  WHERE  C_org_id <> C_txfr_org_id
  AND    from_organization_id =
          decode(C_direction , 1 , C_txfr_org_id , -1 , C_org_id)
  AND    to_organization_id =
          decode(C_direction , 1 , C_org_id , -1 , C_txfr_org_id)
  ;

BEGIN

  SAVEPOINT start_of_autoassign;

  PJM_CONC.put_line( 'Processing material transaction ' || X_transaction_id );

  X_error_num := 0;
  X_error_msg := NULL;

  --
  --  Retrieving relevant information from the transaction
  --
  L_stmt_num := 10;
  open c1 (X_transaction_id);
  fetch c1
  into   L_org_id
  ,      L_item_id
  ,      L_subinv_code
  ,      L_txn_src_type
  ,      L_po_header_id
  ,      L_proj_id
  ,      L_task_id
  ,      L_direction
  ,      L_txfr_org_id
  ,      L_txfr_txn_id
  ,      L_txfr_subinv
  ,      L_to_proj_id
  ,      L_to_task_id
  ,      L_src_proj_id
  ,      L_src_task_id;
  close c1;

  if ((L_proj_id is not null and L_task_id is null) or
      (L_to_proj_id is not null and L_to_task_id is null) or
      (L_txn_src_type = 5 and L_src_proj_id is not null and
                              L_src_task_id is null)) then
    --
    --  Getting the Inventory category for the item
    --
    L_stmt_num := 20;
    L_cat_id := Get_Item_Category(L_org_id, L_item_id);

  end if;

  --
  --  If there is project information and there is no task
  --  information, perform Task AutoAssign
  --
  L_proj_check := is_project(L_proj_id);

  if (L_proj_id is not null and
      L_proj_check and
      L_task_id is null) then

    PJM_CONC.put_line('Task ID : Input => ' || L_org_id ||
                    ' / ' || L_proj_id ||
                    ' / ' || L_item_id ||
                    ' / ' || L_po_header_id ||
                    ' / ' || L_cat_id ||
                    ' / ' || L_subinv_code);

    L_stmt_num := 30;
    L_task_id := Inv_Task_WNPS( L_org_id
                              , L_proj_id
                              , L_item_id
                              , L_po_header_id
                              , L_cat_id
                              , L_subinv_code );

    PJM_CONC.put_line('Task ID => ' || L_task_id);

    if (L_task_id is not null) then

      L_stmt_num := 40;
      UPDATE mtl_material_transactions m
      SET    task_id = L_task_id
      WHERE  transaction_id = X_transaction_id;

    else
      L_error_code := 'TASK-RULE NOT FOUND(TASK_ID)';
      raise Rule_not_found;
    end if;

  end if;

  --
  -- Now assign task for the to project.
  --
  L_proj_check := is_project(L_to_proj_id);

  if (L_to_proj_id is not null and
      L_proj_check and
      L_to_task_id is null) then

    L_stmt_num := 45;
    --
    -- Bug 2253420
    --
    -- Previously the transfer organization is used to derive TO_TASK_ID
    -- based on TO_PROJECT_ID.  It should be determined from the FOB
    -- point of the transfer transaction.  Subinv transfer are not
    -- affected as the org does not change.
    --
    if ( L_txfr_org_id <> L_org_id ) then
      OPEN o ( L_org_id , L_txfr_org_id , L_direction );
      FETCH o INTO L_to_org_id;
      CLOSE o;
      if ( L_to_org_id = L_org_id ) then
        L_to_subinv := L_subinv_code;
        L_to_cat_id := L_cat_id;
      else
        L_to_subinv := L_txfr_subinv;
        L_to_cat_id := Get_Item_Category(L_to_org_id, L_item_id);
      end if;
    else
      L_to_org_id := L_txfr_org_id;
      L_to_subinv := L_txfr_subinv;
      L_to_cat_id := L_cat_id;
    end if;

    PJM_CONC.put_line('To Task ID : Input => ' || L_to_org_id ||
                    ' / ' || L_to_proj_id ||
                    ' / ' || L_item_id ||
                    ' / ' || L_po_header_id ||
                    ' / ' || L_to_cat_id ||
                    ' / ' || L_to_subinv);

    L_stmt_num := 50;
    L_to_task_id := Inv_Task_WNPS( L_to_org_id
                                 , L_to_proj_id
                                 , L_item_id
                                 , L_po_header_id
                                 , L_to_cat_id
                                 , L_to_subinv );

    PJM_CONC.put_line('To Task ID => ' || L_to_task_id);

    if (L_to_task_id is not null) then

      L_stmt_num := 60;
      UPDATE mtl_material_transactions m
      SET    to_task_id = L_to_task_id
      WHERE  transaction_id = X_transaction_id;

    else
      L_error_code := 'TASK-RULE NOT FOUND(TO_TASK_ID)';
      raise Rule_not_found;
    end if;

  end if;

  --
  --  If the transaction_source_type_id = 5 (Job / Schedule)
  --  we need to assign task for source project (Job) also.
  --
  --  Converted to use new WIP Material assignment rules
  --
  L_proj_check := is_project(L_src_proj_id);

  if (L_txn_src_type = 5 and
      L_src_proj_id is not null and
      L_proj_check and
      L_src_task_id is null) then

    L_stmt_num := 70;

    open c_wip (X_transaction_id);
    fetch c_wip
    into   L_txn_type
    ,      L_wip_entity
    ,      L_assy_item_id
    ,      L_dept_id
    ,      L_operation_id;
    close c_wip;

    PJM_CONC.put_line('Src Task ID : Input => ' || L_org_id ||
                    ' / ' || L_src_proj_id ||
                    ' / ' || L_item_id ||
                    ' / ' || L_cat_id ||
                    ' / ' || L_subinv_code ||
                    ' / ' || L_txn_type ||
                    ' / ' || L_wip_entity ||
                    ' / ' || L_assy_item_id ||
                    ' / ' || L_operation_id ||
                    ' / ' || L_dept_id);

    L_stmt_num := 75;

    L_src_task_id := WipMat_Task_WNPS( L_org_id
                                     , L_src_proj_id
                                     , L_item_id
                                     , L_cat_id
                                     , L_subinv_code
                                     , L_txn_type
                                     , L_wip_entity
                                     , L_assy_item_id
                                     , L_operation_id
                                     , L_dept_id );

    PJM_CONC.put_line('Src Task ID => ' || L_src_task_id);

    if (L_src_task_id is not null) then

      L_stmt_num := 80;
      UPDATE mtl_material_transactions m
      SET    source_task_id = L_src_task_id
      WHERE  transaction_id = X_transaction_id;

    else
      L_error_code := 'TASK-RULE NOT FOUND(SOURCE_TASK_ID)';
      raise Rule_not_found;
    end if;

  end if;

  return;

EXCEPTION
  when Rule_not_found then
    ROLLBACK TO SAVEPOINT start_of_autoassign;
    X_error_num := 1403;
    fnd_message.set_name('PJM','TASK-RULE NOT FOUND');
    X_error_msg := fnd_message.get;
    flag_inv_error(X_transaction_id,
                   X_error_num,
                   L_error_code,
                   X_error_msg);

  when others then
    X_error_num := sqlcode;
    X_error_msg := 'TKAA-INV(' || L_stmt_num || ')->' || sqlerrm;

END assign_task_inv;


--
--  Name          : Assign_Task_WIPL
--
--  Function      : This procedure assigns a task based on predefined
--                  rules if a WIP resource/overhead transaction has
--                  project references but no task references.  If
--                  assignment rule cannot be found, the transaction
--                  will beflagged as error and Cost Collection will
--                  not be performed
--
--  Parameters    :
--  IN            : X_transaction_id                 NUMBER
--
--  IN OUT        : X_error_num                      NUMBER
--                : X_error_msg                      VARCHAR2
--
PROCEDURE assign_task_wipl
  ( X_transaction_id   IN            NUMBER
  , X_error_num        IN OUT NOCOPY NUMBER
  , X_error_msg        IN OUT NOCOPY VARCHAR2)
IS

L_operation_id      NUMBER;
L_wip_entity_id     NUMBER;
L_assy_item_id      NUMBER;
L_org_id            NUMBER;
L_proj_id           NUMBER;
L_dept_id           NUMBER;
L_task_id           NUMBER;
L_stmt_num          NUMBER;

L_transaction_type  NUMBER;     /*Added for Bug 7028109 (FP of 6820737)*/
L_cost_elm_id  NUMBER;     /*Added for Bug 7028109 (FP of 6820737)*/

/*Start : Added for bug 6785540 (FP of 6339257)*/
L_operation_seq_num NUMBER;
L_entity_type       NUMBER;
Entity_type_not_supported EXCEPTION;
/*End : Added for bug 6785540 (FP of 6339257)*/

Rule_not_found  EXCEPTION;

/*Bug 7028109 (FP of 6820737): Changed below cursor c1 to add WTA and fetch transaction type and cost element id also.*/
/*Start :  Bug 6785540 (FP of 6339257): Changed cursor c1. Added cursors d1 and f1*/
CURSOR c1 ( C_transaction_id NUMBER )
IS
  SELECT t.wip_entity_id
  ,      t.organization_id
  ,      t.operation_seq_num
  ,      t.project_id
  ,      t.task_id
  ,      t.department_id
  ,      t.transaction_type         /*Added for Bug 7028109 (FP of 6820737)*/
  ,      e.primary_item_id
  ,      e.entity_type
  ,      wta.cost_element_id        /*Added for Bug 7028109 (FP of 6820737)*/
  FROM wip_transactions t
  ,    wip_entities e
  ,    wip_transaction_accounts wta
  WHERE t.transaction_id = C_transaction_id
  AND   t.wip_entity_id = e.wip_entity_id
  AND   t.organization_id = e.organization_id
  AND   t.transaction_id = wta.transaction_id
  AND   t.organization_id = wta.organization_id
  AND   wta.accounting_line_type = 7;                /*Accounting line type 7 = WIP Valuation*/

-- for discrete job
CURSOR d1 ( C_organization_id NUMBER, C_wip_entity_id NUMBER, C_operation_seq_num NUMBER )
IS
  SELECT o.standard_operation_id
  FROM wip_entities e
  ,    wip_operations o
  WHERE e.organization_id = C_organization_id
  AND   e.wip_entity_id = C_wip_entity_id
  AND   o.organization_id = e.organization_id
  AND   o.wip_entity_id = e.wip_entity_id
  AND   o.operation_seq_num = C_operation_seq_num;

-- for flow schedule
CURSOR f1 ( C_organization_id NUMBER, C_wip_entity_id NUMBER, C_operation_seq_num NUMBER, C_primary_item_id NUMBER )
IS
  SELECT s.standard_operation_id
  FROM wip_flow_schedules f
  ,    bom_operational_routings r
  ,    bom_operation_sequences s
  WHERE f.wip_entity_id = C_wip_entity_id
  AND   f.organization_id = C_organization_id
  AND   nvl(f.alternate_routing_designator, 'a') = nvl(r.alternate_routing_designator, 'a')
  AND   r.assembly_item_id = C_primary_item_id
  AND   r.routing_sequence_id = s.routing_sequence_id
  AND   r.organization_id = f.organization_id
  AND   s.operation_seq_num = C_operation_seq_num
  AND   f.scheduled_completion_date BETWEEN s.effectivity_date AND nvl(s.disable_date, sysdate + 1)
  AND   s.operation_type = 1;
/*End :  Bug 6785540 (FP of 6339257): Changed cursor c1. Added cursors d1 and f1*/

BEGIN

  SAVEPOINT start_of_autoassign;

  X_error_num := 0;
  X_error_msg := NULL;

  PJM_CONC.put_line( 'Processing resource transaction ' || X_transaction_id );

  L_stmt_num := 10;
  DELETE FROM wip_txn_interface_errors
  WHERE  transaction_id = X_transaction_id
  AND    error_column = 'TASK_ID';

  --
  --  Retrieving relevant information from the transaction
  --
  L_stmt_num := 20;
  open c1 (X_transaction_id);
  /*Bug 6785540 (FP of 6339257): Changed fetch of cursor c1.*/
  fetch c1
  into   L_wip_entity_id
  ,      L_org_id
  ,      L_operation_seq_num
  ,      L_proj_id
  ,      L_task_id
  ,      L_dept_id
  ,      L_transaction_type     /*Added for Bug 7028109 (FP of 6820737)*/
  ,      L_assy_item_id
  ,      L_entity_type
  ,      L_cost_elm_id;     /*Added for Bug 7028109 (FP of 6820737)*/

  close c1;

  if (L_proj_id is not null and
      is_project(L_proj_id) and
      L_task_id is null) then

    PJM_CONC.put_line('Input => ' || L_org_id ||
                    ' / ' || L_proj_id ||
                    ' / ' || L_operation_id ||
                    ' / ' || L_wip_entity_id ||
                    ' / ' || L_assy_item_id ||
                    ' / ' || L_dept_id ||
                    ' / ' || L_entity_type);    /*Bug 6785540 (FP of 6339257): Print entity type also.*/


    /*Start :  Bug 6785540 (FP of 6339257): Fetch operation based on entity type.*/
    if (L_entity_type IN (1,5,6)) then
      open d1 (L_org_id, L_wip_entity_id, L_operation_seq_num);
      fetch d1
      into   L_operation_id;
      close d1;
    elsif (L_entity_type = 4) then
      open f1 (L_org_id, L_wip_entity_id, L_operation_seq_num, L_assy_item_id);
      fetch f1
      into   L_operation_id;
      close f1;
    else
      raise Entity_type_not_supported;
    end if;

    PJM_CONC.put_line('Operation ID => ' || L_operation_id);
    /*End :  Bug 6785540 (FP of 6339257): Fetch operation based on entity type.*/

    /*Bug 7028109 (FP of 6820737): Follow normal flow if txn is not for direct item. Also check for cost element id.
    If it is 1/2 then treat txn as material txn else as resource transaction.*/
    if( L_transaction_type <> 17 OR L_cost_elm_id NOT IN (1,2) )  then
        PJM_CONC.put_line('Calling Wip_Task_WNPS to get task for resource txn.');
        L_stmt_num := 30;
        L_task_id := Wip_Task_WNPS ( L_org_id
                               , L_proj_id
                               , L_operation_id
                               , L_wip_entity_id
                               , L_assy_item_id
                               , L_dept_id );
    /*Start - Bug 7028109 (FP of 6820737): For direct item, call material rule engine. */
    else
        PJM_CONC.put_line('Calling WipMat_Task_WNPS to get task for resource txn. (For direct item txn)');
        L_task_id := WipMat_Task_WNPS(X_org_id => L_org_id
                               , X_project_id => L_proj_id
                               , X_item_id =>   null
                               , X_category_id =>   null
                               , X_subinv_code =>   null
                               , X_wip_matl_txn_type => null
                               , X_wip_entity_id => L_wip_entity_id
                               , X_assy_item_id =>  L_assy_item_id
                               , X_operation_id =>  L_operation_id
                               , X_dept_id => L_dept_id );
    end if;
    /*End - Bug 7028109 (FP of 6820737): For direct item, check the cost element id and treat txn accordingly.*/

    PJM_CONC.put_line('Task ID => ' || L_task_id);

    if (L_task_id is not null) then

      L_stmt_num := 40;
      UPDATE wip_transactions w
      SET task_id = L_task_id
      WHERE transaction_id = X_transaction_id;

    else
      raise Rule_Not_Found;
    end if;
  end if;

EXCEPTION
  /*Start :  Bug 6785540 (FP of 6339257): Added exception handling.*/
  when Entity_type_not_supported then
    ROLLBACK TO SAVEPOINT start_of_autoassign;
    X_error_num := 1403;
    fnd_message.set_name('PJM','ENTITY-TYPE NOT SUPPORTED');
    X_error_msg := fnd_message.get;
    flag_wip_error(X_transaction_id,
                   X_error_num,
                   X_error_msg);
  /*End :  Bug 6785540 (FP of 6339257): Added exception handling.*/
  when Rule_not_found then
    ROLLBACK TO SAVEPOINT start_of_autoassign;
    X_error_num := 1403;
    fnd_message.set_name('PJM','TASK-RULE NOT FOUND');
    X_error_msg := fnd_message.get;
    flag_wip_error(X_transaction_id,
                   X_error_num,
                   X_error_msg);

  when others then
    X_error_num := sqlcode;
    X_error_msg := 'TKAA-WIP(' || L_stmt_num || ')->' || sqlerrm;

END assign_task_wipl;

END pjm_task_auto_assign;

/

--------------------------------------------------------
--  DDL for Package Body PJM_PROJECT_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PROJECT_LOCATOR" AS
/* $Header: PJMPLOCB.pls 120.5.12010000.4 2009/09/11 23:46:40 huiwan ship $ */

--  ---------------------------------------------------------------------
--  Global Variables
--  ---------------------------------------------------------------------
G_project_number   VARCHAR2(25);
G_task_number      VARCHAR2(25);

--  ---------------------------------------------------------------------
--  Private Functions and Procedures
--  ---------------------------------------------------------------------

--  Name          : Get_Project_References
--  Pre-reqs      : None.
--  Function      : This local function resolves the displayed project
--                  and task references for messaging purpose
--
--
--  Parameters    :
--  IN            : p_project_id              IN       NUMBER
--                : p_task_id                 IN       NUMBER
--
--  Returns       : The concatenated project_number and task_number
--
--  Version       : 1.0                 8/22/97  A Law
--  Notes         :
--
FUNCTION Get_Project_References(
          p_project_id   IN NUMBER,
          p_task_id      IN NUMBER
) RETURN VARCHAR2 IS

l_prj_ref varchar2(100);

BEGIN
   if (p_project_id is null) then
      l_prj_ref := 'NULL';
   elsif (p_task_id is null) then
      l_prj_ref := pjm_project.all_proj_idtonum( p_project_id );
   else
      l_prj_ref := pjm_project.all_proj_idtonum( p_project_id )
       || ' , ' || pjm_project.all_task_idtonum( p_task_id );
   end if;
   return (l_prj_ref);
END Get_Project_References;



--  Name          : Get_Component_ProjectSupply
--  Pre-reqs      : None.
--  Function      :
--
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_project_id              IN       NUMBER
--                : p_task_id                 IN       NUMBER
--                : p_wip_entity_id           IN       NUMBER
--                : p_supply_sub              IN       NUMBER
--                : p_supply_loc_id           IN OUT   NUMBER
--                : p_item_id                 IN       NUMBER
--                : p_org_loc_control         IN       NUMBER
--
--  Returns       : BOOLEAN
--                  The output of p_supply_loc_id will be the
--                  proper locator with project and task
--                  references based on the pegging attribute
--                  of the component.
--
--  Version       : 1.0                 8/22/97  D Soosai
--  Notes         :
--
FUNCTION Get_Component_ProjectSupply (
          p_organization_id   IN     NUMBER,
          p_project_id        IN     NUMBER,
          p_task_id           IN     NUMBER,
          p_wip_entity_id     IN     NUMBER,
          p_supply_sub        IN     VARCHAR2,
          p_supply_loc_id     IN OUT NOCOPY NUMBER,
          p_item_id           IN     NUMBER,
          p_org_loc_control   IN     NUMBER
) RETURN BOOLEAN IS

l_loc_id              NUMBER       := 0;
l_peg_flag            VARCHAR2(1)  := NULL;
subinv_mismatch       EXCEPTION;

CURSOR c1 IS
  SELECT end_assembly_pegging_flag
  FROM   mtl_system_items
  WHERE  inventory_item_id = p_item_id
  AND    organization_id = p_organization_id;

BEGIN

    --
    -- Bug 1218478
    -- A. Law  03/01/2000
    --
    -- Originally, this procedure only process those items that are
    -- hard pegged.  We assume that the supply locator associated on
    -- the BOM is always a common locator.
    --
    -- However, if a project locator is erroneously specified as the
    -- supply locator for a soft-pegged item, original logic will
    -- ignore this record and may result in an incorrect supply
    -- locator with a different project/task reference.
    --
    -- Fortunately, the procedure Get_DefaultProjectLocator already
    -- handles defaulting of project locator for "NULL" project, i.e.
    -- common.
    --
    -- This procedure has been enhanced to handle both soft-pegged and
    -- hard-pegged items
    --

    --
    -- Bug 1402388
    -- A. Law  09/17/2000
    --
    -- Split out branch logic for hard-pegged / soft-pegged from
    -- locator control logic
    --
    OPEN c1;
    FETCH c1 INTO l_peg_flag;
    CLOSE c1;

    IF ( l_peg_flag IN ( 'I' , 'X' ) ) THEN
        IF (Check_ItemLocatorControl(p_organization_id,
            p_supply_sub, p_supply_loc_id, p_item_id, 0)) THEN

            Get_DefaultProjectLocator(p_organization_id,
                                      p_supply_loc_id,
                                      p_project_id,
                                      p_task_id,
                                      l_loc_id);
        END IF;
    ELSE
        Get_DefaultProjectLocator(p_organization_id,
                                  p_supply_loc_id,
                                  NULL,
                                  NULL,
                                  l_loc_id);

    END IF;

    --
    -- Call user procedure Get_User_Project_Supply
    -- if user provides further specific business logic
    -- for defaulting.
    -- Updates Wip_Requirement_Operations with the
    -- new supply subinventory and supply locator.
    --
    PJM_UserProjectLocator_Pub.Get_UserProjectSupply(
        p_item_id,
        p_organization_id,
        p_wip_entity_id,
        l_loc_id);

    /* FP bugs 8744389/8754723/8744391 (refer to 8686512):
     * When locator mismatch happens, locator id is set to -1
     * Raise an exception to indicate mismatch
     * This will affect the callers of Get_Component_ProjectSupply,
     * Get_Job_ProjectSupply, and Get_Flow_ProjectSupply.
     * Only WIP code calls these three procedures/functions.
     * Tests are conducted from WIP, FLOW and EAM flows, which use
     * WIP UI/functionality, to make sure this change doesn't break
     * existing functionality in any other module
     */
    IF l_loc_id = -1 THEN
       raise subinv_mismatch;
    END IF;

    IF l_loc_id <> 0 THEN
        p_supply_loc_id := L_loc_id ;
    END IF;
    return(TRUE);
END Get_Component_ProjectSupply;


--  Name          : Map_Locator
--  Pre-reqs      : None.
--  Function      : This local function tries to map a locator with
--                  given physical locator segments, project and task.
--                  If match not found, this function can optionally
--                  creates one.
--
--
--  Parameters    :
--  IN            : X_organization_id         IN       NUMBER
--                : X_locator_id              IN       NUMBER
--                : X_project_id              IN       NUMBER
--                : X_task_id                 IN       NUMBER
--                : X_create_locator          IN       BOOLEAN
--
--  Returns       : Locator_ID of the matched locator
--
--  Version       : 1.0                 12/22/97  A Law
--  Notes         :
--
FUNCTION map_locator ( X_organization_id  IN NUMBER
                     , X_locator_id       IN NUMBER
                     , X_project_id       IN NUMBER
                     , X_task_id          IN NUMBER
                     , X_create_locator   IN BOOLEAN )
RETURN number
is
cursor C1 is
  select application_column_name, required_flag
  from   fnd_id_flex_segments
  where  application_id = 401
  and    id_flex_code   = 'MTLL'
  and    id_flex_num    = 101
  and    application_column_name not in ('SEGMENT19','SEGMENT20')
  and    nvl(enabled_flag, 'N') = 'Y'
  order by segment_num;
L_locator_id        NUMBER;
L_locator_ctrl      NUMBER;
L_subinv_match      NUMBER;
L_subinv            VARCHAR2(10);
L_stmt              VARCHAR2(2000);
L_user_id           NUMBER;
c                   INTEGER;
rows_processed      INTEGER;
subinv_mismatch     EXCEPTION;

begin
  L_stmt := 'SELECT l2.inventory_location_id, ' ||
            'l2.subinventory_code, ' ||
            'DECODE(l1.subinventory_code, ' ||
            'l2.subinventory_code, 1, ' ||
            'NULL, NULL, 0) ' ||
            'FROM mtl_item_locations l1 ' ||
            ', mtl_item_locations l2 ' ||
            'WHERE l1.organization_id = :org_id ' ||
            'AND l2.organization_id = l1.organization_id ' ||
            'AND l1.inventory_location_id = :locator_id ';

  for c1rec in c1 loop
    if (c1rec.application_column_name = 'SEGMENT1') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment1 = l1.segment1 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment1,'' '') = nvl(l1.segment1,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT2') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment2 = l1.segment2 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment2,'' '') = nvl(l1.segment2,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT3') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment3 = l1.segment3 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment3,'' '') = nvl(l1.segment3,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT4') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment4 = l1.segment4 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment4,'' '') = nvl(l1.segment4,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT5') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment5 = l1.segment5 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment5,'' '') = nvl(l1.segment5,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT6') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment6 = l1.segment6 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment6,'' '') = nvl(l1.segment6,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT7') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment7 = l1.segment7 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment7,'' '') = nvl(l1.segment7,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT8') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment8 = l1.segment8 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment8,'' '') = nvl(l1.segment8,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT9') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment9 = l1.segment9 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment9,'' '') = nvl(l1.segment9,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT10') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment10 = l1.segment10 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment10,'' '') = nvl(l1.segment10,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT11') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment11 = l1.segment11 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment11,'' '') = nvl(l1.segment11,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT12') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment12 = l1.segment12 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment12,'' '') = nvl(l1.segment12,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT13') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment13 = l1.segment13 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment13,'' '') = nvl(l1.segment13,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT14') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment14 = l1.segment14 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment14,'' '') = nvl(l1.segment14,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT15') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment15 = l1.segment15 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment15,'' '') = nvl(l1.segment15,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT16') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment16 = l1.segment16 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment16,'' '') = nvl(l1.segment16,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT17') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment17 = l1.segment17 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment17,'' '') = nvl(l1.segment17,'' '') ';
      end if;
    elsif (c1rec.application_column_name = 'SEGMENT18') then
      if (c1rec.required_flag = 'Y') then
        L_stmt := L_stmt || 'AND l2.segment18 = l1.segment18 ';
      else
        L_stmt := L_stmt || 'AND nvl(l2.segment18,'' '') = nvl(l1.segment18,'' '') ';
      end if;
    end if;
  end loop;
  if (X_project_id is null) then
    L_stmt := L_stmt || 'AND l2.project_id is null';
  else
    if (X_task_id is null) then
      L_stmt := L_stmt || 'AND l2.project_id = :project_id ' ||
                          'AND l2.task_id is null';
    else
      L_stmt := L_stmt || 'AND l2.project_id = :project_id ' ||
                          'AND l2.task_id = :task_id';
    end if;
  end if;
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, l_stmt, dbms_sql.native);
  dbms_sql.bind_variable(c, 'org_id', X_organization_id);
  dbms_sql.bind_variable(c, 'locator_id', X_locator_id);
  if (X_project_id is not null) then
    dbms_sql.bind_variable(c, 'project_id', X_project_id);
  end if;
  if (X_task_id is not null) then
    dbms_sql.bind_variable(c, 'task_id', X_task_id);
  end if;
  dbms_sql.define_column(c,1,L_locator_id);
  dbms_sql.define_column(c,2,L_subinv,10);
  dbms_sql.define_column(c,3,L_subinv_match);
  rows_processed := dbms_sql.execute(c);
  if dbms_sql.fetch_rows(c) > 0 then
    dbms_sql.column_value(c,1,L_locator_id);
    dbms_sql.column_value(c,2,L_subinv);
    dbms_sql.column_value(c,3,L_subinv_match);
  else
    L_locator_id := -1;
    L_subinv_match := null;
  end if;
  dbms_sql.close_cursor(c);

  if (L_locator_id > 0 and L_subinv_match = 0) then
    raise subinv_mismatch;
  end if;

  if (L_locator_id = -1 and X_create_locator) then
    select mtl_item_locations_s.nextval
    into L_locator_id
    from dual;

    L_user_id := fnd_profile.value('USER_ID');

    insert into mtl_item_locations
    (      last_update_date
    ,      last_updated_by
    ,      creation_date
    ,      created_by
    ,      inventory_location_id
    ,      organization_id
    ,      segment1
    ,      segment2
    ,      segment3
    ,      segment4
    ,      segment5
    ,      segment6
    ,      segment7
    ,      segment8
    ,      segment9
    ,      segment10
    ,      segment11
    ,      segment12
    ,      segment13
    ,      segment14
    ,      segment15
    ,      segment16
    ,      segment17
    ,      segment18
    ,      segment19
    ,      segment20
    ,      summary_flag
    ,      enabled_flag
    ,      subinventory_code
    ,      physical_location_id)
    select sysdate
    ,      L_user_id
    ,      sysdate
    ,      L_user_id
    ,      L_locator_id
    ,      X_organization_id
    ,      segment1
    ,      segment2
    ,      segment3
    ,      segment4
    ,      segment5
    ,      segment6
    ,      segment7
    ,      segment8
    ,      segment9
    ,      segment10
    ,      segment11
    ,      segment12
    ,      segment13
    ,      segment14
    ,      segment15
    ,      segment16
    ,      segment17
    ,      segment18
    ,      X_project_id
    ,      X_task_id
    ,      'N'
    ,      'Y'
    ,      subinventory_code
    ,      decode(X_project_id,
                  NULL, L_locator_id,
                        nvl(physical_location_id,inventory_location_id)
           )
    from   mtl_item_locations
    where  organization_id = X_organization_id
    and    inventory_location_id = X_locator_id;

    --
    -- 11.09.1999
    --
    -- The following conditional statement has been added to check
    -- locator control for the desired subinventory.  We would only
    -- propagate restricted locators if locator control is set at
    -- the item level.  This is to eliminate unnecessary inserts.
    --
    -- 05.16.2002
    --
    -- The following SQL has been modified slightly to account for
    -- cases when subinventory code is NULL on mtl_item_locations.
    --
    select nvl(msi.locator_type , 0)
    into   L_locator_ctrl
    from   mtl_secondary_inventories msi
    ,      mtl_item_locations mil
    where  mil.organization_id = X_organization_id
    and    mil.inventory_location_id = X_locator_id
    and    msi.organization_id (+) = mil.organization_id
    and    msi.secondary_inventory_name (+) = mil.subinventory_code;

    if ( L_locator_ctrl = 5 ) then
      --
      -- Locator control is determined at the item level, we need to
      -- propagate restricted locators for all items from the original
      -- locator to the newly created locator
      --
      insert into mtl_secondary_locators
      (      last_update_date
      ,      last_updated_by
      ,      creation_date
      ,      created_by
      ,      secondary_locator
      ,      inventory_item_id
      ,      organization_id
      ,      subinventory_code)
      select sysdate
      ,      L_user_id
      ,      sysdate
      ,      L_user_id
      ,      L_locator_id
      ,      inventory_item_id
      ,      X_organization_id
      ,      subinventory_code
      from   mtl_secondary_locators msl
      where  organization_id = X_organization_id
      and    secondary_locator = X_locator_id
      and exists (
        select 'Locator restriction is on'
        from   mtl_system_items
        where  organization_id = msl.organization_id
        and    inventory_item_id = msl.inventory_item_id
        and    restrict_locators_code = 1);

    end if; /* L_locator_ctrl = 5 */

  end if;

  return(L_locator_id);

exception
  when subinv_mismatch then
    fnd_message.set_name('PJM', 'LOC-DUPLICATE PHY LOC');
    fnd_message.set_token('SUBINV', L_subinv);
    return(-1);
  when others then
    raise;
end Map_Locator;


--  Name          : Get_Physical_Location
--  Pre-reqs      : None.
--  Function      : This local function resolves the physical locator
--                  for any given locator
--
--
--  Parameters    :
--  IN            : X_organization_id         IN       NUMBER
--                : X_locator_id              IN       NUMBER
--
--  Returns       : TRUE is successful, FALSE otherwise
--
--  Version       : 1.0                12/22/97 A Law
--  Notes         :
--
FUNCTION get_physical_location ( X_organization_id IN NUMBER
                               , X_locator_id      IN NUMBER )
RETURN BOOLEAN
IS
L_project_id  number;
L_task_id     number;
L_phy_loc_id  number;
begin
    select project_id
    ,      task_id
    ,      physical_location_id
    into   L_project_id
    ,      L_task_id
    ,      L_phy_loc_id
    from   mtl_item_locations
    where  organization_id = X_organization_id
    and    inventory_location_id = X_locator_id;

    if (L_phy_loc_id is not null) then
        return TRUE;
    end if;

    if (L_project_id is null) then
        L_phy_loc_id := X_locator_id;
    else
        L_phy_loc_id := map_locator( X_organization_id
                                   , X_locator_id
                                   , NULL
                                   , NULL
                                   , TRUE );
        if (L_phy_loc_id = -1) then
            return FALSE;
        end if;
    end if;

    update mtl_item_locations
    set    physical_location_id = L_phy_loc_id
    where  organization_id = X_organization_id
    and    inventory_location_id = X_locator_id;

    return TRUE;

exception
  when others then
    return FALSE;

end Get_Physical_Location;


--  Name          : Match_Proj_By_Plan_Grp
--  Pre-reqs      : None.
--  Function      : This local function matches any two given projects
--                  by project or costing group and planning group
--
--
--  Parameters    :
--  IN            : X_organization_id         IN       NUMBER
--                : X_proj_ctrl_level         IN       NUMBER
--                : X_txn_project             IN       NUMBER
--                : X_txn_task                IN       NUMBER
--                : X_loc_project             IN       NUMBER
--                : X_loc_task                IN       NUMBER
--
--  Returns       : TRUE if match is positive, FALSE otherwise
--
--  Version       : 1.0                 12/22/97 A Law
--  Notes         :
--
FUNCTION match_proj_by_plan_grp ( X_organization_id  IN NUMBER
                                , X_proj_ctrl_level  IN NUMBER
                                , X_txn_project      IN NUMBER
                                , X_txn_task         IN NUMBER
                                , X_loc_project      IN NUMBER
                                , X_loc_task         IN NUMBER)
RETURN BOOLEAN
IS

L_allow_xprj_issue  VARCHAR2(1);
L_cost_method       NUMBER;
L_loc_cost_grp      NUMBER;
L_loc_plan_grp      VARCHAR2(30);
L_loc_prj_ref       VARCHAR2(60);
L_txn_cost_grp      NUMBER;
L_txn_plan_grp      VARCHAR2(30);
L_txn_prj_ref       VARCHAR2(60);

CURSOR Allow_XPrj_Issue ( C_organization_id NUMBER ) IS
SELECT nvl(allow_cross_proj_issues,'N')
FROM   pjm_org_parameters
WHERE  organization_id = C_organization_id;

CURSOR C_Cost_Method ( C_organization_id  NUMBER) IS
SELECT primary_cost_method
FROM   mtl_parameters
WHERE  organization_id = C_organization_id;

CURSOR C_Proj_Param ( C_organization_id  NUMBER
                    , C_project_id       NUMBER) IS
SELECT planning_group
,      nvl(costing_group_id,0)
FROM   pjm_project_parameters
WHERE  organization_id = C_organization_id
AND    project_id = C_project_id;

BEGIN
  /*
  ** Vanilla case - match project and task directly
  */
  if ((X_loc_project <> X_txn_project) and
      (X_loc_project is not null))
                     or
     /* Bug 2502968
     ** Task is required (and must match) if transaction task is present even
     ** in Project Controlled org, unless cross project is allowed
     */
     ((nvl(X_loc_task, nvl(X_txn_task,-1)) <> nvl(X_txn_task,-1)) and
      (X_proj_ctrl_level = 1))
                     or
     ((X_loc_task <> X_txn_task) and
      (X_loc_task is not null) and
      (X_proj_ctrl_level = 2)) then
    -- do nothing
    null;
  else
    return TRUE;
  end if;

  /*
  ** Retrieve org level parameters to see if we should check planning
  ** group and cost group references
  */

  OPEN Allow_XPrj_Issue (X_organization_id);
  FETCH Allow_XPrj_Issue INTO L_allow_xprj_issue;
  if (Allow_XPrj_Issue%notfound) then
    L_allow_xprj_issue := 'N';
  end if;
  CLOSE Allow_XPrj_Issue;

  if ( L_allow_xprj_issue = 'Y' ) then

    /* Bug 2502968
    ** If cross project issue is allowed and locator and transaction project
    ** is the same, then the reference is valid (by the time it gets here,
    ** the only such scenario is a task mismatch)
    */
    if ( X_txn_project = X_loc_project ) then
      return TRUE;
    end if;

    OPEN C_Cost_Method (X_organization_id);
    FETCH C_Cost_Method INTO L_cost_method;
    if ( C_Cost_Method%notfound) then
      L_cost_method := 0;
    end if;
    CLOSE C_Cost_Method;

    OPEN C_Proj_Param (X_organization_id, X_txn_project);
    FETCH C_Proj_Param INTO L_txn_plan_grp, L_txn_cost_grp;
    if (C_Proj_Param%notfound) then
      L_txn_plan_grp := NULL;
      L_txn_cost_grp := NULL;
    end if;
    CLOSE C_Proj_Param;

    OPEN C_Proj_Param (X_organization_id, X_loc_project);
    FETCH C_Proj_Param INTO L_loc_plan_grp, L_loc_cost_grp;
    if (C_Proj_Param%notfound) then
      L_loc_plan_grp := NULL;
      L_loc_cost_grp := NULL;
    end if;
    CLOSE C_Proj_Param;

    /*
    ** If either of the Planning Group is NULL, then match is
    ** FALSE
    */
    /*Bug 8355068: If both planning group are null then this condition would fail.
                   If both planning group are null then we should not return false
                   and added one more condition to make sure that at least one of
                   of the planning group is not null.*/
    if ( (L_txn_plan_grp is null or L_loc_plan_grp is null)
        AND  (L_txn_plan_grp is not null OR L_loc_plan_grp is not null)  ) then
      l_txn_prj_ref := Get_Project_References(X_txn_project, NULL);
      l_loc_prj_ref := Get_Project_References(X_loc_project, NULL);
      FND_MESSAGE.SET_NAME('PJM', 'LOC-PLAN GROUP MISMATCH');
      FND_MESSAGE.SET_TOKEN('TXN_PRJ_REF',l_txn_prj_ref,FALSE);
      FND_MESSAGE.SET_TOKEN('LOC_PRJ_REF',l_loc_prj_ref,FALSE);
      return FALSE;
    end if;

    /*
    ** If the Planning Groups do not match, then match is FALSE
    */
    if ( L_txn_plan_grp <> L_loc_plan_grp ) then
      l_txn_prj_ref := Get_Project_References(X_txn_project, NULL);
      l_loc_prj_ref := Get_Project_References(X_loc_project, NULL);
      FND_MESSAGE.SET_NAME('PJM', 'LOC-PLAN GROUP MISMATCH');
      FND_MESSAGE.SET_TOKEN('TXN_PRJ_REF',l_txn_prj_ref,FALSE);
      FND_MESSAGE.SET_TOKEN('LOC_PRJ_REF',l_loc_prj_ref,FALSE);
      return FALSE;
    end if;

    /*
    ** If the Cost Groups do not match, then match is FALSE
    **
    ** This check is not applicable for standard costing
    **
    ** As of Family Pack H, this check has been completely removed
    ** as the Cost Processor can handle cost group transfer in
    ** WIP issues
    **
    if ( L_cost_method <> 1 ) then
      if ( L_txn_cost_grp <> L_loc_cost_grp ) then
	l_txn_prj_ref := Get_Project_References(X_txn_project, NULL);
	l_loc_prj_ref := Get_Project_References(X_loc_project, NULL);
	FND_MESSAGE.SET_NAME('PJM', 'LOC-COST GROUP MISMATCH');
	FND_MESSAGE.SET_TOKEN('TXN_PRJ_REF',l_txn_prj_ref,FALSE);
	FND_MESSAGE.SET_TOKEN('LOC_PRJ_REF',l_loc_prj_ref,FALSE);
	return FALSE;
      end if;
    end if;
    */
    return TRUE;

  else /* L_allow_xprj_issue = 'N' */

    l_txn_prj_ref := Get_Project_References(X_txn_project, X_txn_task);
    l_loc_prj_ref := Get_Project_References(X_loc_project, X_loc_task);
    FND_MESSAGE.SET_NAME('PJM', 'LOC-PRJ REF MISMATCH');
    FND_MESSAGE.SET_TOKEN('TXN_PRJ_REF',l_txn_prj_ref,FALSE);
    FND_MESSAGE.SET_TOKEN('LOC_PRJ_REF',l_loc_prj_ref,FALSE);
    return FALSE;
  end if;

END match_proj_by_plan_grp;

--  ---------------------------------------------------------------------
--  Public Functions and Procedures
--  ---------------------------------------------------------------------

--  Name          : Check_Project_References
--  Pre-reqs      : None.
--  Function      : This function checks whether a given locator has
--                  appropriate project and task references based on the
--                  current organization.  Also if the validation mode is
--                  specific, the function checks whether the parameters
--                  project_id and task_id have appropriate values.
--
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_locator_id              IN       NUMBER
--                : p_validation_mode         IN       VARCHAR2
--                : p_required_flag           IN       VARCHAR2
--                : p_project_id              IN       NUMBER
--                : p_task_id                 IN       NUMBER
--
--  Returns       : TRUE  if locator passes the validation for the
--                           specific mode
--                  FALSE if locator fails the validation for the
--                           specific mode
--
--  Version       : 1.0                 5/27/97  S Bala
--  Notes         :
--
FUNCTION Check_Project_References(
          p_organization_id  IN NUMBER,
          p_locator_id       IN NUMBER,
          p_validation_mode  IN VARCHAR2,
          p_required_flag    IN VARCHAR2,
          p_project_id       IN NUMBER,
          p_task_id          IN NUMBER
) RETURN BOOLEAN IS

CURSOR C_Org_Controls(org_id NUMBER)  IS
  SELECT project_reference_enabled,
         project_control_level,
         organization_code
  from mtl_parameters
  where organization_id = org_id;

CURSOR C_Loc_Attrib(loc_id NUMBER, org_id NUMBER) IS
 SELECT project_id,
        task_id
 FROM   mtl_item_locations
 WHERE  inventory_location_id = loc_id
 AND    organization_id = org_id;

CURSOR C_Proj (p_id NUMBER) IS
 SELECT project_id
 FROM   pjm_projects_v
 WHERE  project_id = p_id;

CURSOR C_Task (t_id NUMBER) IS
 SELECT task_id
 FROM   pjm_tasks_v
 WHERE  task_id = t_id;

l_org_code            VARCHAR2(3);
l_proj_ref_enabled    NUMBER;
l_proj_control_level  NUMBER;
l_loc_project_id      NUMBER;
l_loc_task_id         NUMBER;
l_txn_prj_ref         VARCHAR2(60);
l_loc_prj_ref         VARCHAR2(60);
l_dummy               NUMBER;

BEGIN

    /* If no locator is passed in , return TRUE */

    if (p_locator_id is NULL) then
        return TRUE;
    end if;

    /* If the locator argumnet passed is -1, it refers to a dynamically
    ** created locator. In this case return TRUE, validation will be done
    ** later for the locator
    */

    if (p_locator_id = -1) then
        return TRUE;
    end if;

    /* Retrieve project control parameters for the organization
    ** passed in
    */

    OPEN C_ORG_CONTROLS(p_organization_id);
    FETCH C_ORG_CONTROLS INTO
        l_proj_ref_enabled,
        l_proj_control_level,
        l_org_code;

    if (C_ORG_CONTROLS%NOTFOUND) then
        CLOSE C_ORG_CONTROLS;
        RAISE NO_DATA_FOUND;
        return FALSE;
    end if;

    CLOSE C_ORG_CONTROLS;

    /* Retrieve locator project and task references */

    OPEN C_LOC_ATTRIB(p_locator_id, p_organization_id);
    FETCH C_LOC_ATTRIB INTO
        l_loc_project_id,
        l_loc_task_id;

    if (C_LOC_ATTRIB%NOTFOUND) then
        CLOSE C_LOC_ATTRIB;
        RAISE NO_DATA_FOUND;
        return FALSE;
    end if;

    CLOSE C_LOC_ATTRIB;

    /* Check to see if project is chargeable; error out if not */

    if ( l_loc_project_id is not null ) then

      OPEN C_Proj ( l_loc_project_id );
      FETCH C_Proj INTO l_dummy;

      if ( C_Proj%NOTFOUND ) then
        CLOSE C_Proj;
        FND_MESSAGE.SET_NAME('PJM', 'LOC-PROJ NOT CHARGEABLE');
        FND_MESSAGE.SET_TOKEN('PROJ' , Get_Project_References( l_loc_project_id , null ));
        return(FALSE);
      end if;

      CLOSE C_Proj;

      /* Check to see if project is enabled in current org */

      if ( pjm_project.val_proj_idtonum( l_loc_project_id
                                       , p_organization_id ) is null ) then

        FND_MESSAGE.SET_NAME('PJM' , 'GEN-INVALID PROJ FOR ORG');
        FND_MESSAGE.SET_TOKEN('PROJECT' , Get_Project_References( l_loc_project_id , null ));
        FND_MESSAGE.SET_TOKEN('ORG' , l_org_code);
        return(FALSE);

      end if;

    end if;

    /* Check to see if task is chargeable; error out if not */

    if ( l_loc_task_id is not null ) then

      OPEN C_Task ( l_loc_task_id );
      FETCH C_Task INTO l_dummy;

      if ( C_Task%NOTFOUND ) then
        CLOSE C_Task;
        FND_MESSAGE.SET_NAME('PJM', 'LOC-TASK NOT CHARGEABLE');
        FND_MESSAGE.SET_TOKEN('TASK' , Get_Project_References( l_loc_project_id , l_loc_task_id ));
        return(FALSE);
      end if;

      CLOSE C_Task;

    end if;

    if (not get_physical_location(p_organization_id, p_locator_id)) then
        return (FALSE);
    end if;

    /* Validations */

    /* 1. If the organization is not project reference enabled, then
    ** the locator cannot have project references.
    */

    if (l_proj_ref_enabled <> 1) then
        if ((l_loc_project_id is not null) or
            (l_loc_task_id is not null)) then
             FND_MESSAGE.SET_NAME('PJM', 'LOC-ORG NOT PRJ ENABLED');
             return (FALSE);
        end if;
    else
        /* If the project_id argument is NULL, then the locator
        ** cannot have project reference */

        if ((p_project_id is null) and (p_validation_mode = 'SPECIFIC')) then
            if (l_loc_project_id is null) then
                return (TRUE);
            else
                FND_MESSAGE.SET_NAME('PJM', 'LOC-PRJ REF NOT ALLOWED');
                return (FALSE);
            end if;
        end if;

        /* Control Level Validations */

        /* If control level is project, and
        ** If Required Flag is set to 'Y', then
        ** verify project is set to not null */

        if (l_proj_control_level = 1) then

            if (p_required_flag = 'Y') then
                if (l_loc_project_id is null) then
                    FND_MESSAGE.SET_NAME('PJM', 'LOC-PRJ REF REQUIRED');
                    return (FALSE);
                end if;
            end if;

        elsif (l_proj_control_level = 2) then

            /* If control level is set to task, ensure both project and
            ** task are null or both are not null. if Required Flag is
            ** set to 'Y', verify both project and task are set to
            ** not null.
            */

            if (((l_loc_project_id is not null) and (l_loc_task_id is null)) or
               ((l_loc_project_id is null) and (l_loc_task_id is not null))) then

                FND_MESSAGE.SET_NAME('PJM', 'LOC-INVALID PRJ REF');
                return FALSE;
            end if;

            if (p_required_flag = 'Y') then
                if ((l_loc_project_id is NULL) or (l_loc_task_id is NULL)) then
	            FND_MESSAGE.SET_NAME('PJM', 'LOC-PRJ REF REQUIRED');
                    return (FALSE);
                end if;
            end if;
        end if; /* l_proj_control_level = 2 */


        /* Project,Task Parameter Validations */

        if (p_validation_mode =  'SPECIFIC') then

            if (p_required_flag = 'Y') then
                /* If required flag is 'Y', then project references in the
                ** parameters must exactly match the project references for the
                ** locator
                */
                if (
                    (nvl(l_loc_project_id, -1) <> nvl(p_project_id, -1))
                                            or
                    /* Bug 2502968
                    ** Task is required (and must match) if transaction task is present even
                    ** in Project Controlled org
                    */
                    ((nvl(l_loc_task_id, -1) <> nvl(p_task_id, nvl(l_loc_task_id, -1))) and
                     (l_proj_control_level = 1))
                                            or
                    ((nvl(l_loc_task_id, -1) <> nvl(p_task_id, -1)) and
                     (l_proj_control_level = 2))
                   ) then
                    l_txn_prj_ref := Get_Project_References(p_project_id, p_task_id);
                    l_loc_prj_ref := Get_Project_References(l_loc_project_id, l_loc_task_id);
                    FND_MESSAGE.SET_NAME('PJM', 'LOC-PRJ REF MISMATCH');
                    FND_MESSAGE.SET_TOKEN('TXN_PRJ_REF',l_txn_prj_ref,FALSE);
                    FND_MESSAGE.SET_TOKEN('LOC_PRJ_REF',l_loc_prj_ref,FALSE);
                    return (FALSE);
                end if;

            elsif (p_required_flag = 'N') then

                /* If required flag is 'N', then call the function
                ** match_proj_by_plan_grp to determine if the locator
                ** passes validation
                */
                if ( not match_proj_by_plan_grp( p_organization_id
                                               , l_proj_control_level
                                               , p_project_id
                                               , p_task_id
                                               , l_loc_project_id
                                               , l_loc_task_id ) ) then
                    return (FALSE);
                end if;
            end if; /* p_required_flag */
        end if; /* p_validation_mode */
    end if;
return (TRUE);

END Check_Project_References;

FUNCTION Check_Project_References(
          p_organization_id  IN NUMBER,
          p_locator_id       IN NUMBER,
          p_validation_mode  IN VARCHAR2,
          p_required_flag    IN VARCHAR2,
          p_project_id       IN NUMBER,
          p_task_id          IN NUMBER,
          p_item_id          IN NUMBER
) RETURN BOOLEAN IS
BEGIN
return Check_Project_References(
          p_organization_id  ,
          p_locator_id       ,
          p_validation_mode  ,
          p_required_flag    ,
          p_project_id       ,
          p_task_id          );
END Check_Project_References;


--  Name          : Check_ItemLocatorControl
--  Pre-reqs      : None.
--  Function      : This function checks the locator control
--                  at three different levels: Org, Sub, Item.
--                  If parameter p_hardpeg_only is 1, it also
--                  checks if it is a hard-peg item.
--                  If the item has a restricted list of subinventory
--                  or locators, this function also checks if
--                  the parameter p_sub, p_loc are within its list.
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_sub                     IN       VARCHAR2
--                : p_loc                     IN       NUMBER
--                : p_item_id                 IN       NUMBER
--                : p_hardpeg_only            IN       NUMBER
--
--  Returns       : True if all test are passed, else return False
--
--  Version       : 1.0                 10/02/97  W. Pacifia Chiang
--  Notes         :
--
FUNCTION Check_ItemLocatorControl (
          p_organization_id   IN     NUMBER,
          p_sub               IN     VARCHAR2,
          p_loc               IN     NUMBER,
          p_item_id           IN     NUMBER,
          p_hardpeg_only      IN     NUMBER
) RETURN BOOLEAN IS


CURSOR C_ITEM_SUB IS
  SELECT 1
  FROM MTL_ITEM_SUB_INVENTORIES
  WHERE inventory_item_id = p_item_id
    AND organization_id = p_organization_id
    AND secondary_inventory = p_sub;

CURSOR C_ITEM_LOC IS
  SELECT 1
  FROM MTL_SECONDARY_LOCATORS
  WHERE inventory_item_id = p_item_id
    AND organization_id = p_organization_id
    AND secondary_locator = p_loc;


dummy                 NUMBER := 0;
l_org_loc_control     NUMBER := 0;
l_sub_loc_control     NUMBER := 0;
l_item_loc_control    NUMBER := 0;
l_item_loc_restrict   NUMBER := 0;
l_item_sub_restrict   NUMBER := 0;
l_peg_flag            VARCHAR2(1)  := NULL;
l_loc_id              NUMBER       :=0;

BEGIN

    BEGIN
        SELECT mtl.end_assembly_pegging_flag,
               mtl.location_control_code,
               NVL(mtl.restrict_locators_code,2),
               NVL(mtl.restrict_subinventories_code,2),
               mp.stock_locator_control_code
          INTO l_peg_flag,
               l_item_loc_control,
               l_item_loc_restrict,
               l_item_sub_restrict,
               l_org_loc_control
          FROM mtl_system_items mtl,
               mtl_parameters mp
         WHERE mtl.inventory_item_id = p_item_id
           AND mtl.organization_id = p_organization_id
           AND mtl.organization_id = mp.organization_id;

    EXCEPTION
    WHEN OTHERS THEN
        return(FALSE);
        RAISE;
    END;

    BEGIN
        SELECT sub.locator_type
          INTO l_sub_loc_control
          FROM mtl_secondary_inventories sub
         WHERE sub.secondary_inventory_name = p_sub
           AND sub.organization_id = p_organization_id;

    EXCEPTION
    WHEN OTHERS THEN
        return(FALSE);
        RAISE;
    END;


    /* Only create project locator when
       the locator control allows dynamic insert
       without any restriction on locator or subinventory.

       Note that there are three levels of locator
       control: Org, Sub, Item
    */

    IF (l_org_loc_control = 3
                   or
       (l_org_loc_control = 4 and
        l_sub_loc_control = 3)
                   or
       (l_org_loc_control = 4 and
        l_sub_loc_control = 5 and
        l_item_loc_control = 3)) THEN


        /* If the item has a restricted list of subinventory,
           then check if the input subinventory is within the resticted list */

        IF (l_item_sub_restrict  = 1) THEN
           OPEN C_ITEM_SUB;
           FETCH C_ITEM_SUB INTO dummy;
           IF (C_ITEM_SUB%NOTFOUND) THEN
              CLOSE C_ITEM_SUB;
              return(FALSE);
           ELSE
              CLOSE C_ITEM_SUB;
           END IF;

           /* If the item has a restricted list of locators,
              then check if the input locator is within the resticted list. */

           IF (l_item_loc_restrict  = 1) THEN
              OPEN C_ITEM_LOC;
              FETCH C_ITEM_LOC INTO dummy;
              IF (C_ITEM_LOC%NOTFOUND) THEN
                 CLOSE C_ITEM_LOC;
                 return(FALSE);
              ELSE
                 CLOSE C_ITEM_LOC;
              END IF;
           END IF;
        END IF;


        IF (p_hardpeg_only = 1) THEN
            IF (l_peg_flag = 'I' or l_peg_flag = 'X') THEN
                  return(TRUE);
            ELSE
               return (FALSE);
            END IF;
        ELSE
            return (TRUE);
        END IF;
    ELSE
        return (FALSE);
    END IF;
END Check_ItemLocatorControl;


--  Name          : Get_DefaultProjectLocator
--  Pre-reqs      : None.
--  Function      : This procedure matches a project locator based on
--                  the parameters organization_id, locator_id, project_id
--                  and task_id.  If no locator is found, a new locator is
--                  created with project reference in segment19 and
--                  task reference in segment20 into mtl_item_locations
--                  using same physical attributes (from segment1 upto
--                  segment18 depending locator flexfield setup).
--
--
--                  The assumption for this procedure is that
--                  the supply subinventory/locator value of those
--                  wip_requirement_operations should be common locators.
--
--  Parameters    :
--  IN            : p_organization_id     IN       NUMBER
--                : p_locator_id          IN       NUMBER
--                : p_project_id          IN       NUMBER
--                : p_task_id             IN       NUMBER
--                : p_project_locator_id  IN OUT   NUMBER
--
--  RETURNS       : NA
--
--  Version       : 1.0                 5/27/97  W. Pacifia Chiang
--  Notes         :
--
PROCEDURE Get_DefaultProjectLocator(
          p_organization_id    IN     NUMBER,
          p_locator_id         IN     NUMBER,
          p_project_id         IN     NUMBER,
          p_task_id            IN     NUMBER,
          p_project_locator_id IN OUT NOCOPY NUMBER
) IS
CURSOR C3(v_loc_id NUMBER, v_org_id NUMBER,
                v_project_id NUMBER, v_task_id NUMBER)IS
  SELECT rowid
  from mtl_item_locations
  where inventory_location_id = v_loc_id
  and   organization_id = v_org_id
  and   nvl(project_id, -1) = nvl(v_project_id, -1)
  and   nvl(task_id, -1) = nvl(v_task_id, -1);


CURSOR C4 (v_loc_id NUMBER, v_org_id NUMBER) IS
  SELECT physical_location_id
  FROM   mtl_item_locations
  WHERE  inventory_location_id = v_loc_id
  and    organization_id = v_org_id;

l_rowid             VARCHAR2(400);
l_subinv_code       VARCHAR2(10);
l_phy_loc_id        NUMBER;

BEGIN

    /* Comment this line because some callers to this API use the same variable
     * for p_locator_id and p_project_locator_id and this line will set them
     * both to null. Please refer to bug 8848853 for more details.
     */
    --p_project_locator_id := null;

    /* If there is no input locator, there is no need to do anything
    */
    if (p_locator_id is null) then
        return;
    end if;

    /* Bug 741594
    ** June 9, 1999
    **
    ** Check whether the locator itself is a valid locator.
    ** If yes proceed to other checks, if no error out.
    */
    if (not get_physical_location(p_organization_id, p_locator_id)) then
        fnd_message.set_name('INV','INV_INT_LOCCODE');
        raise_application_error(-20001, fnd_message.get);
    end if;

    OPEN C4(p_locator_id, p_organization_id);
    FETCH C4 INTO l_phy_loc_id;
    CLOSE C4;

    /* If project_id is null, we can simply return the physical
    ** locator
    */
    if (p_project_id is null) then
        p_project_locator_id := l_phy_loc_id;
        return;
    end if;

    /* Check whether the passed arguments point to a
    ** valid existing locator. If yes return the locator
    ** id, if no proceed to other checks
    */
    OPEN C3(p_locator_id, p_organization_id, p_project_id, p_task_id);
        FETCH C3 INTO l_rowid;

    if (C3%NOTFOUND) then
        close C3;
    else
        p_project_locator_id := p_locator_id;
        close C3;
        return;
    end if;

    /* Check if another locator exist with matching flexfield segments
    ** as selected above for the organization_id, project_id and task_id
    ** passed in. Dynamic SQL is employed here for performance.
    */

    p_project_locator_id := map_locator( p_organization_id
                                       , p_locator_id
                                       , p_project_id
                                       , p_task_id
                                       , TRUE );

    return;

END Get_DefaultProjectLocator;


/*==========================================================================
--  Name          : Get_Job_ProjectSupply
--  Pre-reqs      : None.
--  Function      : This procedure gets supply locators
--                  for materials that are backflushed
--                  for project jobs.
--
--                  The assumption for this procedure is that
--                  the supply subinventory/locator value of those
--                  wip_requirement_operations should be common locators.
--
--  Parameters    :
--  IN            : p_organization_id  IN       NUMBER
--                : p_wip_entity_id    IN       NUMBER
--                : p_project_id       IN       NUMBER
--                : p_task_id          IN       NUMBER
--                : p_success          OUT      NUMBER
--
--  RETURNS       : NA
--
--  Version       : 1.0                 4/29/97   W. Pacifia Chiang
--  Notes         :
+========================================================================== */

PROCEDURE Get_Job_ProjectSupply (
          p_organization_id     IN  NUMBER,
          p_wip_entity_id       IN  NUMBER,
          p_project_id          IN  NUMBER,
          p_task_id             IN  NUMBER,
          p_success             OUT NOCOPY NUMBER
) IS

--  This procedure gets  backflush material supply
--  and supply locator for project job.

L_item_id           NUMBER := 0;
L_supply_type       NUMBER := 0;
L_supply_loc_id     NUMBER := 0;
L_proj_ref_enabled  NUMBER := 2;
l_org_loc_control   NUMBER := 0;

L_supply_sub        VARCHAR2(10) := NULL;
L_ROW_ID            ROWID;
l_success           BOOLEAN      := TRUE;
locator_exe         exception;

CURSOR proj_job_curr (V_org_id NUMBER, V_wip_entity_id NUMBER) IS
    SELECT rop.inventory_item_id,
           rop.supply_subinventory,
           rop.supply_locator_id,
           rop.wip_supply_type, rop.rowid
      FROM wip_requirement_operations rop
     WHERE rop.organization_id = V_org_id
       AND rop.wip_entity_id = V_wip_entity_id
       AND rop.supply_locator_id is not null
  ORDER BY rop.operation_seq_num
  FOR UPDATE;

begin
    p_success  := 1;

    if (p_organization_id is not null) then
        begin
            SELECT NVL(mp.project_reference_enabled, 2),
                   mp.stock_locator_control_code
              INTO L_proj_ref_enabled,
                   l_org_loc_control
              FROM mtl_parameters mp
             WHERE mp.organization_id = p_organization_id;

       exception
       when others then
           p_success := 0;
           raise;
       end;
    end if;

    if (l_proj_ref_enabled = 1) then

        -- only process if the org parameter has project reference enabled
        --
        OPEN proj_job_curr (p_organization_id, p_wip_entity_id) ;
        loop
            L_item_id := 0;
            L_supply_loc_id := 0;
            L_supply_type := 0;

            FETCH proj_job_curr INTO
                  L_item_id,
                  L_supply_sub,
                  L_supply_loc_id,
                  L_supply_type,
                  L_row_id;
            EXIT WHEN proj_job_curr%NOTFOUND;

            -- The original supply locator specified for this project jobs
            -- from users should be a common locator.  This is enforced
            -- by user procedure.

            l_success := Get_Component_ProjectSupply(
                                        p_organization_id,
                                        p_project_id,
                                        p_task_id,
                                        p_wip_entity_id,
                                        L_supply_sub,
                                        L_supply_loc_id,
                                        L_item_id,
                                        l_org_loc_control);
            if l_success = false then
                p_success := 0;
                raise locator_exe;
            else
                if L_supply_loc_id <> 0 then
                    begin
                        UPDATE  wip_requirement_operations rop
                        SET     rop.supply_locator_id = L_supply_loc_id
                        WHERE   rop.rowid = L_row_id;
                    exception
                    when others then
                        p_success := 0;
                        raise locator_exe;
                    end;
                end if;
            end if;
        end loop;
        close proj_job_curr;
    end if;
end Get_Job_ProjectSupply;


--  Name          : Get_Flow_ProjectSupply
--  Pre-reqs      : None.
--  Function      : This procedure gets supply locators
--                  for materials that are backflushed
--                  for project related flow schedules.
--
--                  The assumption for this procedure is that
--                  the supply subinventory/locator value of those
--                  in mtl_transactions_interface should be common
--                  locators.
--
--  Parameters    :
--  IN            : p_organization_id    IN       NUMBER
--                : p_wip_entity_id      IN       NUMBER
--                : p_project_id         IN       NUMBER
--                : p_task_id            IN       NUMBER
--                : p_success            OUT      NUMBER
--
--  RETURNS       : NA
--
--  Version       : 1.01                 8/11/97   Daniel Soosai
--  Notes         :
--
PROCEDURE Get_Flow_ProjectSupply (
          p_organization_id     IN  NUMBER,
          p_wip_entity_id       IN  NUMBER,
          p_project_id          IN  NUMBER,
          p_task_id             IN  NUMBER,
          p_parent_id           IN  NUMBER,
          p_success             OUT NOCOPY NUMBER
) IS

l_item_id           NUMBER       := 0;
l_supply_type       NUMBER       := 0;
l_supply_loc_id     NUMBER       := 0;
l_proj_ref_enabled  NUMBER       := 2;
l_org_loc_control   NUMBER       := 0;
l_success           BOOLEAN      := TRUE;
l_supply_sub        VARCHAR2(10) := NULL;
l_ROW_ID            ROWID;
locator_exe         EXCEPTION;

CURSOR proj_flow_curr (V_org_id        NUMBER,
                       V_wip_entity_id NUMBER,
                       V_parent_id     NUMBER) IS
  SELECT mti.inventory_item_id,
         mti.subinventory_code,
         mti.locator_id,
         mti.rowid
    FROM mtl_transactions_interface mti
   WHERE mti.organization_id = V_org_id
     AND (  V_wip_entity_id is null
         OR mti.transaction_source_id = V_wip_entity_id )
     AND mti.locator_id is not null
     AND mti.parent_id = V_parent_id
     AND mti.transaction_action_id in (1, 27, 33, 34)
     AND mti.transaction_source_type_id = 5
     AND mti.flow_schedule = 'Y'
     ORDER BY mti.operation_seq_num
   FOR UPDATE;

begin
    p_success  := 1;

    IF (p_organization_id  IS NOT NULL) THEN
       BEGIN
          SELECT NVL(mp.project_reference_enabled, 2),
                 mp.stock_locator_control_code
            INTO L_proj_ref_enabled,
                 l_org_loc_control
            FROM mtl_parameters mp
           WHERE mp.organization_id = p_organization_id;

       EXCEPTION
       WHEN OTHERS THEN
           p_success := 0;
           RAISE;
       END;
    END IF;

    IF l_proj_ref_enabled = 1 AND p_project_id IS NOT NULL THEN
        -- only process if the org parameter has project reference enabled
        -- and the project id  is not null (only project jobs are processed)

        OPEN proj_flow_curr (p_organization_id, p_wip_entity_id, p_parent_id) ;
        loop
            l_item_id := 0;
            l_supply_loc_id := 0;
            l_supply_type := 0;

            FETCH proj_flow_curr INTO
                  L_item_id,
                  L_supply_sub,
                  L_supply_loc_id,
                  L_row_id;
            EXIT WHEN proj_flow_curr%NOTFOUND;


            /* The original supply locator specified for this project jobs
               from users should be a common locator.  This is enforced
               by user procedure.
            */

            l_success :=  Get_Component_ProjectSupply(
                                        p_organization_id,
                                        p_project_id,
                                        p_task_id,
                                        p_wip_entity_id,
                                        L_supply_sub,
                                        L_supply_loc_id,
                                        L_item_id,
                                        l_org_loc_control);

            if l_success = false then
                p_success := 0;
                raise locator_exe;
            else
                if l_supply_loc_id <> 0 then
                    begin
                        update mtl_transactions_interface
                        set(locator_id, project_id, task_id) =
                           (select inventory_location_id, project_id, task_id
                            from mtl_item_locations
                            where inventory_location_id = l_supply_loc_id
                            and   organization_id = p_organization_id)
                        where  rowid = l_row_id;

                    exception
                    when others then
                        p_success := 0;
                        raise locator_exe;
                    end;
                end if;
            end if;
        end loop;
        close proj_flow_curr;
    end if;
end Get_Flow_ProjectSupply;


--  ---------------------------------------------------------------------
--  Functions and Procedures used for locator segment defaulting
--  ---------------------------------------------------------------------
PROCEDURE Set_Segment_Default (
          p_project_id        IN  NUMBER,
          p_task_id           IN  NUMBER
) IS

begin
    if (p_project_id is not null) then
        G_project_number := pjm_project.all_proj_idtonum( p_project_id );
        if (p_task_id is not null) then
            G_task_number := pjm_project.all_task_idtonum( p_task_id );
--BUG Fix 4590465
        else
           G_task_number    := NULL;

-- END BUG 4590465
        end if;
    else
        G_project_number := NULL;
	G_task_number    := NULL;
    end if;
end Set_Segment_Default;

PROCEDURE Put_OrgProfile(name in varchar2, val in varchar2) is
begin
	FND_PROFILE.put(name, val);
end Put_OrgProfile;

PROCEDURE Get_OrgProfile(name in varchar2, val out nocopy varchar2) is
begin
	FND_PROFILE.get(name, val);
end Get_OrgProfile;

FUNCTION Proj_Seg_Default
return VARCHAR2 IS
begin
    return(G_Project_Number);
end Proj_Seg_Default;

FUNCTION Task_Seg_Default
return VARCHAR2 IS
begin
    return(G_Task_Number);
end Task_Seg_Default;

END PJM_PROJECT_LOCATOR;

/

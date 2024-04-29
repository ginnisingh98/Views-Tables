--------------------------------------------------------
--  DDL for Package Body PJM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_UTILS" AS
/* $Header: PJMPUTLB.pls 120.2 2006/03/08 14:43:20 yliou noship $ */
FUNCTION Get_Demand_Quantity (
          X_line_id  IN NUMBER
) RETURN NUMBER IS

L_qty NUMBER := 0;

BEGIN

select  PRIMARY_UOM_QUANTITY
into L_qty
from MTL_DEMAND
where  DEMAND_SOURCE_LINE = X_line_id
AND    DEMAND_SOURCE_TYPE IN (2,8,12)
AND    RESERVATION_TYPE IN (2,3);

return ( L_qty );

exception
  when others then
    return ( 0 );

END Get_Demand_Quantity;


--
--  Name          : Last_Accum_Period
--  Pre-reqs      : None.
--  Function      : This function returns the last accumulated period
--                  for a given project or project / task combo.
--
--
--  Parameters    :
--  IN            : X_project_id              IN       NUMBER
--                : X_task_id                 IN       NUMBER
--
--  Returns       : Last accum period
--
FUNCTION Last_Accum_Period (
          X_project_id       IN NUMBER,
          X_task_id          IN NUMBER
) RETURN VARCHAR2 IS

L_accum_period_type    VARCHAR2(30);
L_period_name          VARCHAR2(20);

CURSOR PA_Accum_Period ( C_project_id   NUMBER
                       , C_task_id      NUMBER )
IS
  SELECT accum.accum_period
  FROM   pa_project_accum_headers accum
  ,      pa_periods per
  WHERE  accum.project_id = C_project_id
  AND    accum.task_id    = nvl(C_task_id, accum.task_id)
  AND    per.period_name  = accum.accum_period
  ORDER BY per.start_date desc;

CURSOR GL_Accum_Period ( C_project_id   NUMBER
                       , C_task_id      NUMBER )
IS
  SELECT accum.accum_period
  FROM   pa_project_accum_headers accum
  ,      pa_implementations_all imp
  ,      gl_sets_of_books sob
  ,      gl_periods per
  ,      pa_projects_all pa
  WHERE  accum.project_id    = C_project_id
  AND pa.project_id = accum.project_id
  AND    accum.task_id       = nvl(C_task_id, accum.task_id)
  AND    sob.set_of_books_id = imp.set_of_books_id
  AND    per.period_set_name = sob.period_set_name
  AND    per.period_type     = sob.accounted_period_type
  AND    per.period_name     = accum.accum_period
  AND imp.org_id = pa.org_id
  ORDER BY per.start_date desc;

BEGIN

  select accumulation_period_type
  into   L_accum_period_type
  from   pa_implementations;

  if ( L_accum_period_type = 'PA' ) then
    open PA_Accum_Period ( X_project_id
                         , X_task_id );
    fetch PA_Accum_Period into L_period_name;
    close PA_Accum_Period;
  elsif ( L_accum_period_type = 'GL' ) then
    open GL_Accum_Period ( X_project_id
                         , X_task_id );
    fetch GL_Accum_Period into L_period_name;
    close GL_Accum_Period;
  else
    L_period_name := null;
  end if;

  return ( L_period_name );

exception
  when others then
    return ( NULL );

end Last_Accum_Period;


--
--  Name          : default_wip_acct_class
--  Pre-reqs      : None.
--  Function      : This function returns the default WIP accounting
--                  class for the given organization , project and
--                  task.  The default is derived first from the
--                  task level, and if not found, the project level.
--
--
--  Parameters    :
--  IN            : X_inventory_org_id        IN       NUMBER
--                : X_project_id              IN       NUMBER
--                : X_task_id                 IN       NUMBER
--                : X_class_type              IN       NUMBER
--
--  Returns       : WIP accounting class code
--
FUNCTION default_wip_acct_class
( X_inventory_org_id    in number
, X_project_id          in number
, X_task_id             in number
, X_class_type          in number
) RETURN VARCHAR2 IS

cursor c is
  select wac.class_code
  from   wip_accounting_classes wac
  ,    ( select 2 lvl
         ,      wip_acct_class_code
         ,      eam_acct_class_code
         from   pjm_project_parameters
         where  organization_id = X_inventory_org_id
         and    project_id = X_project_id
         union all
         select 1 lvl
         ,      wip_acct_class_code
         ,      eam_acct_class_code
         from   pjm_task_wip_acct_classes
         where  organization_id = X_inventory_org_id
         and    project_id = X_project_id
         and    task_id = X_task_id ) pjm
  where  wac.organization_id = X_inventory_org_id
  and    wac.class_code in ( pjm.wip_acct_class_code , pjm.eam_acct_class_code )
  and    wac.class_type = X_class_type
  order by lvl , wac.class_code;

  crec c%rowtype;

BEGIN

  open c;
  fetch c into crec;
  close c;
  return ( crec.class_code );

END default_wip_acct_class;

end;

/

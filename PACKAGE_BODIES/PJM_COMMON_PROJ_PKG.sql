--------------------------------------------------------
--  DDL for Package Body PJM_COMMON_PROJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_COMMON_PROJ_PKG" AS
/* $Header: PJMCMPJB.pls 120.0.12010000.3 2009/07/17 21:18:44 exlin ship $ */


Function Get_Common_Project
( X_Org_Id  IN NUMBER
) RETURN NUMBER IS
  l_common_proj_id        NUMBER;

Begin

  Select Common_Project_Id
  into   l_common_proj_id
  from   pjm_org_parameters
  where  Organization_Id = X_Org_Id;

  return (l_common_proj_id);

  Exception
  When NO_DATA_FOUND then
    return(null);

End Get_Common_Project;


---------------------------------------------------------------------------
-- PUBLIC PROCEDURE
--   Set_Common_Project
--
-- DESCRIPTION
--   This procedure will set the project/task to common project/task
--   for the transactions that there is no project/task reference.
--
---------------------------------------------------------------------------

PROCEDURE Set_Common_Project
( X_Org_Id  IN NUMBER
) IS

Cursor c is
  select organization_id , common_project_id
  from   pjm_org_parameters
  where  organization_id = nvl(X_Org_Id , organization_id)
  and    common_project_id is not null
  order by organization_id,common_project_id  /*Bug 6972181 (FP of 6900015): Added order by clause*/
  FOR  UPDATE of organization_id; /*Bug  8668526 (one-off for 7198823) */


Begin

  For crec in c loop

    update mtl_material_transactions mmt
    set    mmt.project_id =
               nvl(mmt.project_id , crec.common_project_id)
    ,      mmt.source_project_id =
               nvl(mmt.source_project_id,
               decode(transaction_source_type_id,
                      5, crec.common_project_id,
                         null))
    where  mmt.pm_cost_collected = 'N'
    and  organization_id = crec.organization_id
    and  (  mmt.project_id is null or
         (MMT.SOURCE_PROJECT_ID IS NULL and transaction_source_type_id = 5)
         ); /* Modified where clause for Bug 8668526 (one-off for 7198823) */



    --
    -- This update is for subinventory transfers and direct org
    -- transfers only
    --
    update mtl_material_transactions mmt
    set    mmt.to_project_id = crec.common_project_id
    where  mmt.pm_cost_collected = 'N'
    and    transfer_organization_id = crec.organization_id
    and    transaction_action_id not in ( 12 , 21 )
    and    to_project_id is null;

    --
    -- This update is for intransit transfers only
    --
    update mtl_material_transactions mmt
    set    mmt.to_project_id = crec.common_project_id
    where  mmt.pm_cost_collected = 'N'
    and    transaction_action_id in ( 12 , 21 )
    and    to_project_id is null
    and    ( organization_id , transfer_organization_id ) in (
        select from_organization_id , to_organization_id
        from   mtl_interorg_parameters
        where  crec.organization_id =
                decode( fob_point
                      , 1 /* Shipment */ , to_organization_id
                      , 2 /* Receipt  */ , from_organization_id )
        and    mmt.transaction_action_id = 21
        union all
        select to_organization_id , from_organization_id
        from   mtl_interorg_parameters
        where  crec.organization_id =
                decode( fob_point
                      , 1 /* Shipment */ , to_organization_id
                      , 2 /* Receipt  */ , from_organization_id )
        and    mmt.transaction_action_id = 12
    );

    update wip_transactions wt
    set    wt.project_id = crec.common_project_id
    where   wt.pm_cost_collected = 'N'
    and     wt.organization_id = crec.organization_id
    and     wt.project_id is null;

  End loop;

Exception
when OTHERS then
  raise;
END Set_Common_Project;

END PJM_COMMON_PROJ_PKG;

/

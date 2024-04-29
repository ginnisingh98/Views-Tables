--------------------------------------------------------
--  DDL for Package Body FII_PA_BUDGET_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PA_BUDGET_HOOK" as
/* $Header: FIIPA14B.pls 120.0 2002/08/24 05:00:19 appldev noship $ */

-- ----------------------------
-- function PRE_FACT_COLL
-- ----------------------------
function pre_fact_coll return boolean is

  cursor task_c is
    select attribute1, attribute2, attribute3, attribute4
    from fii_system_event_log log
    where log.event_type   = 'DNRM:FII_PA_BUDGET_F'
      and log.event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
      and log.status       = 'PROCESSING';

begin

  -- Step 1. Define the scope of pre-processing. Changing status to
  -- 'PROCESSING' guarantees that subsequent steps will work on
  -- the same set of data ignoring any new records that may be
  -- concurrently created in the Log table by the Project Dimension
  -- collection process.

  update fii_system_event_log log
  set status = 'PROCESSING'
  where log.event_type   = 'DNRM:FII_PA_BUDGET_F'
    and log.event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
    and log.status       = 'READY';


  -- Step 2. remove redundant events from the event log table, i.e. leave only
  -- the latest event for each task

  delete from fii_system_event_log log
  where log.event_type   = 'DNRM:FII_PA_BUDGET_F'
    and log.event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
    and log.status       = 'PROCESSING'
    and log.event_id not in
        (
          select max( event_id )
          from fii_system_event_log log
          where log.event_type   = 'DNRM:FII_PA_BUDGET_F'
            and log.event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
            and log.status       = 'PROCESSING'
        );

  -- Step 3. update log table with task and org data

  update fii_system_event_log log
  set (attribute2, attribute3, attribute4) =
      (
        select to_char(task.task_pk_key), task.denorm_task_org_fk, to_char(org.organization_pk_key)
        from   edw_proj_task_ltc  task,
               edw_orga_org_ltc   org
        where  log.attribute1 = task.task_pk
          and  task.denorm_task_org_fk = org.organization_pk
      )
  where log.event_type   = 'DNRM:FII_PA_BUDGET_F'
    and log.event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
    and log.status       = 'PROCESSING';

  -- Step 4. update PROJECT_ORG_FK in the fact staging table
  -- with Task Owning Organization from the Task Level table

  update fii_pa_budget_fstg  fstg
  set project_org_fk =
      (
        select denorm_task_org_fk
        from edw_proj_task_ltc  task
        where fstg.project_fk = task.task_pk
      )
  where fstg.collection_status = 'READY'
    and fstg.edw_record_type   = 'ORACLE';

  -- Step 5. update PROJECT_ORG_FK in the fact staging table
  -- with Task Owning Organization from the Log table. This step is required to
  -- overrride possible changes to DENORM_TASK_ORG_FK made in Task Level
  -- table by Project Dimension collection process between Steps 3 and 4.
  -- Step 5 guarantees that FSTG and F tables are always in sync in
  -- respect to the LTC tables.

  update fii_pa_budget_fstg  fstg
  set project_org_fk =
      (
        select attribute3
        from fii_system_event_log log
        where log.event_type   = 'DNRM:FII_PA_BUDGET_F'
          and log.event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
          and log.status       = 'PROCESSING'
          and fstg.project_fk = log.attribute1
      )
  where collection_status = 'READY'
    and edw_record_type = 'ORACLE'
    and project_fk in
        (
          select attribute1
          from fii_system_event_log
          where event_type   = 'DNRM:FII_PA_BUDGET_F'
            and event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
            and status       = 'PROCESSING'
        );


  -- Step 6. update fact table

  for c in task_c loop
    if ( c.attribute2 is not null ) and ( c.attribute4 is not null ) then
      update fii_pa_budget_f fact
      set    fact.project_org_fk_key = to_number( c.attribute4 )
      where  fact.project_fk_key     = to_number( c.attribute2 );
    end if;
  end loop;

  -- Step 7. delete processed records from the Log table

  delete from  fii_system_event_log
  where event_type   = 'DNRM:FII_PA_BUDGET_F'
    and event_object = 'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK'
    and status       = 'PROCESSING';

  -- Step 8. commit changes.

  commit;

  return true;

exception
  when others then
    rollback;
    return false;
end pre_fact_coll;

end;

/

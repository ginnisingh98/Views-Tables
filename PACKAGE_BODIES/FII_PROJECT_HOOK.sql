--------------------------------------------------------
--  DDL for Package Body FII_PROJECT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PROJECT_HOOK" as
/* $Header: FIIPA17B.pls 120.0 2002/08/24 05:00:40 appldev noship $ */

-- ----------------------------
-- function PRE_FACT_COLL
-- ----------------------------

function pre_dimension_coll return boolean is

  --most recently changed tasks

  cursor the_scope is
  select
    lstg.task_pk
  from
    (
      select
        task_pk,
        denorm_task_org_fk
      from
        edw_proj_task_lstg
      where
        ( task_pk, creation_date ) in
        (
          select
            task_pk              task_pk,
            max(creation_date)   creation_date
          from
            edw_proj_task_lstg
          where
                collection_status = 'READY'
            and edw_record_type   = 'ORACLE'
          group by
            task_pk
        )
    )                   lstg,
    edw_proj_task_ltc   ltc
  where
        ltc.task_pk = lstg.task_pk
    and nvl(ltc.denorm_task_org_fk, 'NULL') <> nvl( lstg.denorm_task_org_fk, 'NULL' );

begin

  for c in the_scope loop

    -- create log record for Project Cost Fact
    insert into fii_system_event_log
    (
      EVENT_TYPE,
      EVENT_ID,
      EVENT_OBJECT,
      ATTRIBUTE1,
      STATUS
    )
    values
    (
      'DNRM:FII_PA_COST_F',
      fii_system_event_log_s.nextval,
      'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK',
      c.task_pk,
      'READY'
    );

    -- create log record for Project Revenue Fact

    insert into fii_system_event_log
    (
      EVENT_TYPE,
      EVENT_ID,
      EVENT_OBJECT,
      ATTRIBUTE1,
      STATUS
    )
    values
    (
      'DNRM:FII_PA_REVENUE_F',
      fii_system_event_log_s.nextval,
      'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK',
      c.task_pk,
      'READY'
    );

    -- create log record for Project Budget Fact

    insert into fii_system_event_log
    (
      EVENT_TYPE,
      EVENT_ID,
      EVENT_OBJECT,
      ATTRIBUTE1,
      STATUS
    )
    values
    (
      'DNRM:FII_PA_BUDGET_F',
      fii_system_event_log_s.nextval,
      'EDW_PROJ_TASK_LTC.DENORM_TASK_ORG_FK',
      c.task_pk,
      'READY'
    );

  end loop;

  commit;

  return true;

exception
  when others then
    rollback;
    return false;
end pre_dimension_coll;

end;

/

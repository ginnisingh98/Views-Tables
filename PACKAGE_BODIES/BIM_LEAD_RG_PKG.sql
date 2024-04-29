--------------------------------------------------------
--  DDL for Package Body BIM_LEAD_RG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_LEAD_RG_PKG" AS
/* $Header: bimldrgb.pls 120.3 2005/12/16 14:10:18 snallapa noship $*/

G_PKG_NAME  CONSTANT  VARCHAR2(20) :='BIM_LEAD_RG_PKG';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimldrgb.pls';

-----------------------------------------------------------------------
-- PROCEDURE
--    POPULATE
--
-----------------------------------------------------------------------

PROCEDURE POPULATE
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER
    ) IS

l_table_name                  VARCHAR2(100);
l_return					BOOLEAN;

l_status					VARCHAR2(5);
l_industry					VARCHAR2(5);
l_schema					VARCHAR2(30);

BEGIN

  ERRBUF :='SUCCESS';
  RETCODE := 0;


  --get the schema name

  l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

  l_table_name := 'BIM_R_LEAD_GRP_MGR';
  fnd_message.set_name('BIM','BIM_R_TRUNCATE_TABLE');
  fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_lead_grp_mgr';

  l_table_name := 'BIM_R_LEAD_SUM_FACTS';
  fnd_message.set_name('BIM','BIM_R_TRUNCATE_TABLE');
  fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_lead_sum_facts';

  l_table_name := 'BIM_R_LEAD_RES_DENORM';
  fnd_message.set_name('BIM','BIM_R_TRUNCATE_TABLE');
  fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_lead_res_denorm';

  l_table_name := 'BIM_R_LEAD_GRP_MGR';
  fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
  fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);


  INSERT
    INTO bim_r_lead_grp_mgr(
    creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,group_id
    ,resource_id
    )
  SELECT
     sysdate
     ,-1
     ,sysdate
     ,-1
     ,-1
     ,inner.group_id
     ,inner.resource_id
   FROM (
     SELECT
              mem.group_id
              ,res.resource_id
     FROM
              jtf_rs_resource_extns res
              ,jtf_rs_roles_b   rol
              ,jtf_rs_role_relations rlt
              ,jtf_rs_group_members mem
              ,jtf_rs_groups_b grp
              ,jtf_rs_group_usages u
     WHERE
              mem.group_member_id = rlt.role_resource_id
              AND    nvl(mem.delete_flag , 'N') <> 'Y'
              AND    rlt.role_resource_type = 'RS_GROUP_MEMBER'
              AND    rlt.end_date_active is NULL
              AND    nvl(rlt.delete_flag , 'N') <> 'Y'
              AND    rlt.role_id = rol.role_id
              AND    ((nvl(rol.manager_flag , 'N') = 'Y') OR (nvl(rol.admin_flag, 'N') = 'Y'))
              AND    mem.resource_id = res.resource_id
              AND    res.category = 'EMPLOYEE'
              AND    mem.group_id = grp.group_id
              AND    u.group_id = grp.group_id
              AND    u.usage = 'SALES'
    GROUP BY
              mem.group_id
              ,res.resource_id
   ) inner;
COMMIT;

  l_table_name := 'BIM_R_LEAD_SUM_FACTS';
  fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
  fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  INSERT
    INTO bim_r_lead_sum_facts(
    creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,transaction_create_date
    ,group_id
    ,lead_rank_id
    ,lead_source
    ,lead_status
    ,open_flag
    ,object_type
    ,object_id
    ,region
    ,country
    ,business_unit_id
    ,year
    ,qtr
    ,month
    ,leads_open
    ,leads_closed
    ,leads_new
    ,leads_dead
    ,leads_changed
    ,leads_unchanged
    ,leads_assigned
    ,opportunities
    ,opportunities_open
    ,quotes
    ,quotes_open
    ,orders
    ,sleads_open
    ,sleads_closed
    ,sleads_new
    ,sleads_dead
    ,sleads_changed
    ,sleads_unchanged
    ,sleads_assigned
    ,sopportunities
    ,sopportunities_open
    ,squotes
    ,squotes_open
    ,sorders
    )
  SELECT
     sysdate
     ,-1
     ,sysdate
     ,-1
     ,-1
     ,inner.transaction_create_date transaction_create_date
     ,inner.group_id group_id
     ,inner.lead_rank_id lead_rank_id
     ,inner.lead_source lead_source
     ,inner.lead_status lead_status
     ,inner.open_flag open_flag
     ,inner.object_type object_type
     ,inner.object_id object_id
     ,inner.region region
     ,inner.country country
     ,inner.business_unit_id business_unit_id
     ,inner.year year
     ,inner.qtr qtr
     ,inner.month month
     ,sum(inner.leads_open) leads_open
     ,sum(inner.leads_closed) leads_closed
     ,sum(inner.leads_new) leads_new
     ,sum(inner.leads_dead) leads_dead
     ,sum(inner.leads_changed) leads_changed
     ,sum(inner.leads_unchanged) leads_unchanged
     ,sum(inner.leads_assigned) leads_assigned
     ,sum(inner.opportunities) opportunities
     ,sum(inner.opportunities_open) opportunities_open
     ,sum(inner.quotes) quotes
     ,sum(inner.quotes_open) quotes_open
     ,sum(inner.orders) orders
     ,sum(inner.sleads_open) sleads_open
     ,sum(inner.sleads_closed) sleads_closed
     ,sum(inner.sleads_new) sleads_new
     ,sum(inner.sleads_dead) sleads_dead
     ,sum(inner.sleads_changed) sleads_changed
     ,sum(inner.sleads_unchanged) sleads_unchanged
     ,sum(inner.sleads_assigned) sleads_assigned
     ,sum(inner.sopportunities) sopportunities
     ,sum(inner.sopportunities_open) sopportunities_open
     ,sum(inner.squotes) squotes
     ,sum(inner.squotes_open) squotes_open
     ,sum(inner.sorders) sorders
   FROM (
     SELECT
              rgrp.group_id              group_id
              ,a.transaction_create_date transaction_create_date
              ,a.lead_rank_id            lead_rank_id
              ,a.lead_source             lead_source
              ,a.lead_status             lead_status
              ,a.open_flag               open_flag
              ,a.object_type             object_type
              ,a.object_id               object_id
              ,a.region                  region
              ,a.country                 country
              ,a.business_unit_id        business_unit_id
              ,a.year                    year
              ,a.qtr                     qtr
              ,a.month                   month
              ,sum(a.leads_open)         leads_open
              ,sum(a.leads_closed)       leads_closed
              ,sum(a.leads_new)          leads_new
              ,sum(a.leads_dead)         leads_dead
              ,sum(a.leads_changed)      leads_changed
              ,sum(a.leads_unchanged)    leads_unchanged
              ,sum(a.leads_assigned)     leads_assigned
              ,sum(a.opportunities)      opportunities
              ,sum(a.opportunities_open) opportunities_open
              ,sum(a.quotes)             quotes
              ,sum(a.quotes_open)        quotes_open
              ,sum(a.orders)             orders
              ,0                         sleads_open
              ,0                         sleads_closed
              ,0                         sleads_new
              ,0                         sleads_dead
              ,0                         sleads_changed
              ,0                         sleads_unchanged
              ,0                         sleads_assigned
              ,0                         sopportunities
              ,0                         sopportunities_open
              ,0                         squotes
              ,0                         squotes_open
              ,0                         sorders
     FROM
             (select group_id from
                     bim_r_lead_grp_mgr
                     group by group_id) RGRP
              ,bim_r_lead_daily_facts a
              ,jtf_rs_groups_denorm GDN
     WHERE
              rgrp.group_id =  gdn.parent_group_id
              AND  gdn.group_id = a.group_id
              AND  gdn.end_date_active is null
     GROUP BY
              rgrp.group_id
              ,a.transaction_create_date
              ,a.lead_rank_id
              ,a.lead_source
              ,a.lead_status
              ,a.open_flag
              ,a.object_type
              ,a.object_id
              ,a.region
              ,a.country
              ,a.business_unit_id
              ,a.year
              ,a.qtr
              ,a.month
----------------
UNION ALL
----------------
     SELECT
               rgrp.group_id              group_id
               ,a.transaction_create_date transaction_create_date
               ,a.lead_rank_id            lead_rank_id
               ,a.lead_source             lead_source
               ,a.lead_status             lead_status
               ,a.open_flag               open_flag
               ,a.object_type             object_type
               ,a.object_id               object_id
               ,a.region                  region
               ,a.country                 country
               ,a.business_unit_id        business_unit_id
               ,a.year                    year
               ,a.qtr                     qtr
               ,a.month                   month
               ,0                         leads_open
               ,0                         leads_closed
               ,0                         leads_new
               ,0                         leads_dead
               ,0                         leads_changed
               ,0                         leads_unchanged
               ,0                         leads_assigned
               ,0                         opportunities
               ,0                         opportunities_open
               ,0                         quotes
               ,0                         quotes_open
               ,0                         orders
               ,sum(a.leads_open)         sleads_open
               ,sum(a.leads_closed)       sleads_closed
               ,sum(a.leads_new)          sleads_new
               ,sum(a.leads_dead)         sleads_dead
               ,sum(a.leads_changed)      sleads_changed
               ,sum(a.leads_unchanged)    sleads_unchanged
               ,sum(a.leads_assigned)     sleads_assigned
               ,sum(a.opportunities)      sopportunities
               ,sum(a.opportunities_open) sopportunities_open
               ,sum(a.quotes)             squotes
               ,sum(a.quotes_open)        squotes_open
               ,sum(a.orders)             sorders
    FROM
             (select group_id from
                     bim_r_lead_grp_mgr
                     group by group_id) RGRP
               ,bim_r_lead_daily_facts a
    WHERE
               rgrp.group_id =  a.group_id
    GROUP BY
               rgrp.group_id
               ,a.transaction_create_date
               ,a.lead_rank_id
               ,a.lead_source
               ,a.lead_status
               ,a.open_flag
               ,a.object_type
               ,a.object_id
               ,a.region
               ,a.country
               ,a.business_unit_id
               ,a.year
               ,a.qtr
               ,a.month
   ) inner
   GROUP BY
               inner.group_id
               ,inner.transaction_create_date
               ,inner.lead_rank_id
               ,inner.lead_source
               ,inner.lead_status
               ,inner.open_flag
               ,inner.object_type
               ,inner.object_id
               ,inner.region
               ,inner.country
               ,inner.business_unit_id
               ,inner.year
               ,inner.qtr
               ,inner.month
;
COMMIT;

  l_table_name := 'BIM_R_LEAD_RES_DENORM';
  fnd_message.set_name('BIM','BIM_R_POPULATE_TABLE');
  fnd_message.set_token('TABLE_NAME',l_table_name,FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  INSERT
    INTO bim_r_lead_res_denorm(
    creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,resource_id
    ,group_id
    ,child_group_id
    ,owner_flag
    )
  SELECT
     sysdate
     ,-1
     ,sysdate
     ,-1
     ,-1
     ,inner.resource_id
     ,inner.group_id
     ,inner.child_group_id
     ,inner.owner_flag
   FROM (
      SELECT
               resource_id
               ,group_id
               ,child_group_id
               ,owner_flag
      FROM (
               SELECT
                  a.resource_id,
                  b.parent_group_id group_id,
                  b.group_id child_group_id,
                  'N' owner_flag
               FROM
                  bim_r_lead_grp_mgr  a
                  ,jtf_rs_groups_denorm b
               WHERE
                  a.group_id = b.parent_group_id
                  AND b.immediate_parent_flag = 'Y'
                  AND b.end_date_active is null
               GROUP BY
                  a.resource_id,
                  b.parent_group_id,
                  b.group_id
               ---------
               UNION ALL
               ---------
               SELECT
                  a.resource_id,
                  b.parent_group_id group_id,
                  b.group_id child_group_id,
                  'Y' owner_flag
                FROM
                  bim_r_lead_grp_mgr  a
                  ,jtf_rs_groups_denorm b
               WHERE
                  a.group_id = b.parent_group_id
                  AND b.parent_group_id = b.group_id
                  AND b.immediate_parent_flag = 'N'
                  AND b.end_date_active is null
               GROUP BY
                  a.resource_id,
                  b.parent_group_id,
                  b.group_id
      )
      GROUP BY
               resource_id,
               group_id,
               child_group_id,
               owner_flag
   ) inner;
COMMIT;



   DELETE FROM bim_rep_history
   WHERE object='LEAD_RG';
   INSERT INTO
   bim_rep_history
       (creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        object,
        object_last_updated_date)
   VALUES
       (sysdate,
        sysdate,
        FND_GLOBAL.USER_ID(),
        FND_GLOBAL.USER_ID(),
        'LEAD_RG',
        sysdate);
COMMIT;

  fnd_message.set_name('BIM','BIM_R_PROG_COMPLETION');
  fnd_message.set_token('PROGRAM_NAME','GROUP HIERARCHY SUM OF LEADS',FALSE);
  fnd_file.put_line(fnd_file.log,fnd_message.get);


 EXCEPTION

   WHEN OTHERS THEN
     ams_utility_pvt.write_conc_log('BIM_LEAD_RG_PKG--POPULATE: Error occured '||sqlerrm(sqlcode));
     ERRBUF  := sqlerrm(sqlcode);
     RETCODE := sqlcode;

--   dbms_output.put_line('END OF POPULATING BIM_LEAD_RG_PKG');
--  dbms_output.put_line('END OF POPULATE');

END POPULATE;

END BIM_LEAD_RG_PKG;

/

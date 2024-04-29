--------------------------------------------------------
--  DDL for Package Body CN_CALC_POPULATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_POPULATE_PVT" AS
-- $Header: cnvcpopb.pls 120.9.12010000.2 2009/04/10 11:10:44 sseshaiy ship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_CALC_POPULATE_PVT';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvcpopb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

  g_calc_type                 VARCHAR2(30);
  g_org_id                    NUMBER;

  -- beginning of private procedures

  PROCEDURE populate_lines
    (x_role_count       IN OUT NOCOPY NUMBER,
     p_quota_count 	NUMBER,
     p_salesrep_id	NUMBER,
     p_revenue_class_id NUMBER,
     p_processed_date 	DATE,
     p_comp_group_id  	NUMBER,
     p_role_id 		NUMBER,
     p_srp_plan_assign_id NUMBER,
     p_quota_id NUMBER,
     p_processed_period_id NUMBER,
     p_quota_rule_id NUMBER) IS
  BEGIN
    IF (p_quota_count = 1) AND (x_role_count = 1) THEN
	x_role_count := 2;

	UPDATE cn_commission_lines_all cl
	  SET cl.srp_plan_assign_id = p_srp_plan_assign_id,
	  cl.quota_id = p_quota_id,
	  cl.quota_rule_id = p_quota_rule_id,
	  cl.status = 'POP',
	  cl.role_id = p_role_id,
      cl.pay_period_id = cl.processed_period_id
	  WHERE cl.credited_salesrep_id = p_salesrep_id
	  AND cl.credited_comp_group_id = p_comp_group_id
	  AND cl.processed_period_id = p_processed_period_id
	  AND cl.processed_date = p_processed_date
	  AND cl.created_during in ('ROLL', 'TROLL')
	  AND cl.status IN ('ROLL')
	  AND cl.quota_id IS NULL
      AND cl.org_id = g_org_id
	  AND ((g_calc_type = 'COMMISSION' AND cl.trx_type NOT IN ('BONUS', 'GRP', 'FORECAST')) OR
	       (g_calc_type = 'FORECAST' AND cl.trx_type = 'FORECAST'))
	  AND cl.revenue_class_id = p_revenue_class_id
	  AND ( substr(cl.pre_processed_code, 3,1) = 'P' OR
		(substr(cl.pre_processed_code, 3,1) = 'N' AND
		 cl.direct_salesrep_id <> cl.credited_salesrep_id ) );
      ELSE

	-- create new transaction lines for plan_quota
	INSERT INTO cn_commission_lines_all
	  ( commission_line_id,
	    commission_header_id,
	    CREDITED_SALESREP_ID,
	    credited_comp_group_id,
	    role_id,
	    processed_period_id,
	    pay_period_id,
	    PENDING_STATUS,
	    SRP_PLAN_ASSIGN_ID,
	    quota_id,
	    QUOTA_RULE_ID,
	    STATUS,
	    CREATED_DURING,
	    PAYEE_LINE_ID,
	    trx_type,
	    processed_date,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    CREATION_DATE,
	    created_by,
        org_id,
		rollup_level)
	  SELECT
	  cn_commission_lines_s.NEXTVAL,
	  cl.commission_header_id,
	  cl.credited_salesrep_id,
	  cl.credited_comp_group_id,
	  p_role_id,
	  cl.processed_period_id,
	  cl.pay_period_id,
	  cl.pending_status,
	  p_srp_plan_assign_id,
	  p_quota_id,
	  p_quota_rule_id,
	  'POP',
	  'POP',
	  cl.commission_line_id,
	  cl.trx_type,
	  cl.processed_date,
	  g_last_update_date,
	  g_last_updated_by,
	  g_last_update_login,
	  g_creation_date,
	  g_created_by,
      g_org_id,
      rollup_level
	  FROM cn_commission_lines_all cl
	  WHERE cl.credited_salesrep_id = p_salesrep_id
	  AND cl.processed_date = p_processed_date
	  AND cl.processed_period_id = p_processed_period_id
	  AND cl.credited_comp_group_id = p_comp_group_id
	  AND cl.created_during in ('ROLL', 'TROLL')
      AND cl.status = 'POP'
      AND cl.org_id = g_org_id
	  AND cl.revenue_class_id = p_revenue_class_id
	  -- only source trxs can skip 'POP' phase, others need to be handled here
	  AND ( substr(cl.pre_processed_code, 3,1) = 'P'
		OR (substr(cl.pre_processed_code, 3,1) = 'N'
		    AND cl.direct_salesrep_id <> cl.credited_salesrep_id ) )
	  AND ((g_calc_type = 'COMMISSION'
		AND cl.trx_type NOT IN ('BONUS', 'GRP', 'FORECAST')) OR
	       (g_calc_type = 'FORECAST'
		AND cl.trx_type = 'FORECAST'));
     END IF;
  EXCEPTION WHEN OTHERS THEN
     if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      'cn.plsql.cn_calc_populate_pvt.populate_lines.exception',
          	          sqlerrm);
     end if;

     fnd_file.put_line(fnd_file.Log, 'In cn_calc_populate_pvt.populate_lines: '||sqlerrm);
     cn_message_pkg.debug('Exception occurs in creating commission lines in the population phase:');
     cn_message_pkg.debug('sqlerrm');
     RAISE;
  END populate_lines;

  -- API name 	: populate_batch
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --
  -- Desc 	:
  --
  --
  --
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_physical_batch_id NUMBER(15) Require
  --
  --
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE populate_batch
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_physical_batch_id     IN  NUMBER

      ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Populate_batch';
     l_api_version    CONSTANT NUMBER :=1.0;

     l_processed_date_prev         DATE;
     l_salesrep_id_prev            NUMBER(15);
     l_role_id_prev                NUMBER(15);
     l_quota_id_prev               NUMBER(15);
     l_revenue_class_id_prev       NUMBER(15);

     l_dim_hierarchy_id            NUMBER(15);
     l_quota_rule_id               NUMBER(15);
     l_srp_plan_assign_id          NUMBER(15);

     l_srp_group_rec               cn_rollup_pvt.srp_group_rec_type;
     l_role_flag_tbl               cn_rollup_pvt.role_tbl_type;
     l_rev_class_hierarchy_id      NUMBER;
     l_start_date                  date;
     l_end_date                    date;
     g_end_date                    date;
     i                             pls_integer;
     l_indirect_credit             VARCHAR2(10);
     l_manager_flag                VARCHAR2(1);

     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
     l_return_status VARCHAR2(30);

     CURSOR team_mbrs IS
	SELECT pb.salesrep_id,
	       pb.period_id,
           sct.comp_team_id,
	       scg.comp_group_id,
	       greatest(pb.start_date, sct.start_date_active, scg.start_date_active) start_date,
	       least(pb.end_date, nvl(sct.end_date_active, pb.end_date), nvl(scg.end_date_active, pb.end_date)) end_date
	  FROM cn_srp_comp_teams_v sct,
	       cn_process_batches_all pb,
	       cn_srp_comp_groups_v scg
	  WHERE pb.physical_batch_id = p_physical_batch_id
	  AND pb.salesrep_id = sct.salesrep_id
	  AND pb.start_date <= nvl(sct.end_date_active, pb.end_date)
      AND sct.org_id = g_org_id
	  AND pb.end_date >= sct.start_date_active
	  AND scg.salesrep_id = pb.salesrep_id
      AND scg.org_id = g_org_id
	  AND pb.start_date <= nvl(scg.end_date_active, pb.end_date)
	  AND pb.end_date >= scg.start_date_active;

     CURSOR other_mbrs(p_comp_team_id NUMBER, p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	SELECT sct.salesrep_id,
               greatest(p_start_date, sct.start_date_active) start_date,
               least(p_end_date, nvl(sct.end_date_active, p_end_date)) end_date
	  FROM cn_srp_comp_teams_v sct
	  WHERE sct.comp_team_id = p_comp_team_id
	  AND sct.salesrep_id <> p_salesrep_id
      AND sct.org_id = g_org_id
      AND p_start_date <= nvl(sct.end_date_active, p_end_date)
      AND p_end_date >= sct.start_date_active;

     cursor rev_class_hierarchy_id is
	select rev_class_hierarchy_id
	  from cn_repositories_all
     where org_id = g_org_id;

     cursor salesreps is
	select distinct
	  cl.credited_salesrep_id,
	  cl.credited_comp_group_id,
	  pb.period_id,
	  pb.end_period_id,
	  pb.start_date,
	  pb.end_date,
	  cl.revenue_class_id
     from cn_commission_lines_all cl,
          cn_process_batches_all pb
    where pb.physical_batch_id = p_physical_batch_id
      and cl.credited_salesrep_id = pb.salesrep_id
      and cl.processed_period_id between pb.period_id AND pb.end_period_id
      and cl.processed_date BETWEEN pb.start_date AND pb.end_date
      and cl.org_id = g_org_id
      and cl.status IN ('ROLL')
      and cl.quota_id IS NULL
      and (substr(cl.pre_processed_code, 3,1) = 'P' or
           (substr(cl.pre_processed_code,3,1) = 'N' and cl.direct_salesrep_id <> cl.credited_salesrep_id ));

     cursor plan_info(p_salesrep_id number,
		      p_comp_group_id number,
		      p_revenue_class_id number,
		      p_start_date date,
		      p_end_date date)
       is
	  select  /*+ ordered use_nl(SPA, JRS)*/
             spa.role_id,
	         spa.srp_plan_assign_id,
	         sqa.quota_id,
	         qr.quota_rule_id,
	         greatest(dh.start_date, spa.start_date, q.start_date, rr.start_date_active, p_start_date) start_date,
	         least(nvl(dh.end_date, p_end_date),
		           nvl(spa.end_date, p_end_date),
		           nvl(q.end_date, p_end_date),
		           nvl(rr.end_date_active, p_end_date), p_end_date) end_date
	    from cn_srp_plan_assigns_all spa,
             cn_srp_quota_assigns_all sqa,
             cn_quotas_all q,
             cn_quota_rules_all qr,
	         cn_dim_hierarchies_all dh,
	         jtf_rs_salesreps jrs,
	         jtf_rs_group_members mem,
	         jtf_rs_role_relations rr
       where spa.salesrep_id = p_salesrep_id
         and spa.org_id = g_org_id
         and spa.start_date <= p_end_date
         and nvl(spa.end_date, p_end_date) >= p_start_date
         and jrs.salesrep_id = p_salesrep_id
	     and jrs.org_id = spa.org_id
	     and mem.group_id = p_comp_group_id
	     and mem.resource_id = jrs.resource_id
	     and nvl(mem.delete_flag, 'N') <> 'Y'
	     and rr.role_id = spa.role_id
	     and rr.role_resource_id = mem.group_member_id
	     and rr.role_resource_type = 'RS_GROUP_MEMBER'
	     and nvl(rr.delete_flag, 'N') <> 'Y'
	     and exists (select /*+ no_unnest */ 1 from cn_comp_plans_all where status_code = 'COMPLETE' AND comp_plan_id = spa.comp_plan_id)
         and rr.start_date_active <= p_end_date
         and nvl(rr.end_date_active, p_end_date) >= p_start_date
         and rr.start_date_active <= nvl(spa.end_date, p_end_date)
         and nvl(rr.end_date_active, nvl(spa.end_date, p_end_date)) >= spa.start_date
         and sqa.srp_plan_assign_id = spa.srp_plan_assign_id
         and q.quota_id = sqa.quota_id
         and q.start_date <= p_end_date
         and nvl(q.end_date, p_end_date) >= p_start_date
         and qr.quota_id = sqa.quota_id
         and dh.header_dim_hierarchy_id = l_rev_class_hierarchy_id
         and dh.org_id = g_org_id
         and dh.start_date <= least(nvl(spa.end_date, p_end_date), nvl(q.end_date, p_end_date))
         and nvl(dh.end_date, p_end_date) >= greatest(spa.start_date, q.start_date)
         and exists (select /*+ no_unnest */ 1 from cn_dim_explosion_all de
                                 where de.dim_hierarchy_id = dh.dim_hierarchy_id
                                   and de.ancestor_external_id = qr.revenue_class_id
                                   and de.value_external_id = p_revenue_class_id)
       order by greatest(dh.start_date, spa.start_date, q.start_date, rr.start_date_active, p_start_date),
	            least(nvl(dh.end_date, p_end_date),
		        nvl(spa.end_date, p_end_date),
		        nvl(q.end_date, p_end_date),
		        nvl(rr.end_date_active, p_end_date), p_end_date);


     cursor plan_info2(p_salesrep_id number,
		       p_comp_group_id number,
		       p_revenue_class_id number,
		       p_start_date date,
		       p_end_date date)
     is
	  select spa.role_id,
	         spa.srp_plan_assign_id,
             sqa.quota_id,
             qr.quota_rule_id,
             greatest(spa.start_date, q.start_date, rr.start_date_active, p_start_date) start_date,
             least(nvl(spa.end_date, p_end_date),
                   nvl(q.end_date, p_end_date),
		           nvl(rr.end_date_active, p_end_date), p_end_date) end_date
        from cn_srp_plan_assigns_all spa,
             cn_srp_quota_assigns_all sqa,
             cn_quotas_all q,
             cn_quota_rules_all qr,
	         jtf_rs_salesreps jrs,
	         jtf_rs_group_members mem,
	         jtf_rs_role_relations rr
       where spa.salesrep_id = p_salesrep_id
         and spa.org_id = g_org_id
         and spa.start_date <= p_end_date
         and nvl(spa.end_date, p_end_date) >= p_start_date
         and jrs.salesrep_id = p_salesrep_id
         and jrs.org_id = spa.org_id
         and mem.group_id = p_comp_group_id
         and mem.resource_id = jrs.resource_id
         and nvl(mem.delete_flag, 'N') <> 'Y'
         and rr.role_id = spa.role_id
         and rr.role_resource_id = mem.group_member_id
         and rr.role_resource_type = 'RS_GROUP_MEMBER'
         and nvl(rr.delete_flag, 'N') <> 'Y'
         and rr.start_date_active <= p_end_date
         and nvl(rr.end_date_active, p_end_date) >= p_start_date
         and rr.start_date_active <= nvl(spa.end_date, p_end_date)
         and nvl(rr.end_date_active, nvl(spa.end_date, p_end_date)) >= spa.start_date
         and exists (select 1 from cn_comp_plans_all where status_code = 'COMPLETE' AND comp_plan_id = spa.comp_plan_id)
         and sqa.srp_plan_assign_id = spa.srp_plan_assign_id
         and q.quota_id = sqa.quota_id
         and q.start_date <= p_end_date
         and nvl(q.end_date, p_end_date) >= p_start_date
         and qr.quota_id = sqa.quota_id
         and qr.revenue_class_id = p_revenue_class_id
       order by greatest(spa.start_date, q.start_date, rr.start_date_active, p_start_date),
	            least(nvl(spa.end_date, p_end_date), nvl(q.end_date, p_end_date), nvl(rr.end_date_active, p_end_date), p_end_date);

     -- get salesreps who has source trxs skipping 'POP' phase
     CURSOR l_skip_salesreps_csr IS
	SELECT DISTINCT cl.credited_salesrep_id salesrep_id,
	  cl.processed_period_id,
	  cl.processed_date,
	  ch.role_id,
	  ch.quota_id,
	  ch.revenue_class_id
	  FROM cn_commission_lines_all cl,
	  cn_commission_headers_all ch,
	  cn_process_batches_all pb
	  WHERE pb.physical_batch_id = p_physical_batch_id
	  AND cl.credited_salesrep_id = pb.salesrep_id
	  AND cl.processed_period_id between pb.period_id AND pb.end_period_id
	  AND cl.processed_date BETWEEN pb.start_date AND pb.end_date
      AND cl.org_id = g_org_id
	  AND cl.status IN ('ROLL')
	  AND ((g_calc_type = 'COMMISSION'
		AND cl.trx_type NOT IN ('BONUS', 'GRP', 'FORECAST')) OR
	       (g_calc_type = 'FORECAST' AND cl.trx_type = 'FORECAST'))
	  AND ch.commission_header_id = cl.commission_header_id
	  AND ch.role_id IS NOT NULL
	  AND ch.quota_id IS NOT NULL
	  -- only source trxs are allowed to skip the normal 'POPULATION' phase
	  AND Substr(ch.pre_processed_code,3,1) = 'N'
	  AND ch.direct_salesrep_id = cl.credited_salesrep_id
	  order by cl.processed_date, cl.credited_salesrep_id, ch.role_id;

     CURSOR l_dim_hierarchy_csr (l_processed_date DATE) IS
	SELECT dim_hierarchy_id
	  FROM cn_dim_hierarchies_all dh,
	  cn_repositories_all r
	  WHERE r.org_id = g_org_id
      AND r.rev_class_hierarchy_id = dh.header_dim_hierarchy_id
      AND dh.org_id = g_org_id
	  AND l_processed_date BETWEEN dh.start_date AND dh.end_date;

     CURSOR l_spa_csr (l_processed_date     DATE,
			  l_salesrep_id        NUMBER,
			  l_role_id            NUMBER ) IS
	SELECT spa.srp_plan_assign_id
	  FROM cn_srp_plan_assigns_all spa
	  WHERE spa.role_id = l_role_id
	  AND spa.salesrep_id = l_salesrep_id
      AND spa.org_id = g_org_id
	  and exists (select comp_plan_id from cn_comp_plans_all where status_code = 'COMPLETE' AND comp_plan_id = spa.comp_plan_id)
	  AND l_processed_date >= spa.start_date
	  AND ( spa.end_date IS NULL OR spa.end_date >= l_processed_date );

     CURSOR l_quota_rule_no_hier_csr ( l_quota_id NUMBER, l_revenue_class_id NUMBER ) IS
	SELECT qr.quota_rule_id
	  FROM cn_quota_rules_all qr
	  WHERE qr.quota_id = l_quota_id
	  AND qr.revenue_class_id = l_revenue_class_id;

     CURSOR l_quota_rule_hier_csr (l_quota_id NUMBER, l_revenue_class_id NUMBER ) IS
	SELECT qr.quota_rule_id
	  FROM cn_quota_rules_all qr,
	  cn_dim_explosion_all de
	  WHERE qr.quota_id = l_quota_id
	  AND de.dim_hierarchy_id = l_dim_hierarchy_id
	  AND de.value_external_id = l_revenue_class_id
	  AND de.ancestor_external_id = qr.revenue_class_id;

     l_role_count      NUMBER := 0;
  BEGIN
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					  p_api_version ,
					  l_api_name    ,
					  G_PKG_NAME )
     THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     select org_id into g_org_id
	   from cn_process_batches_all
	  where physical_batch_id = p_physical_batch_id
	    and rownum = 1;

     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.cn_calc_populate_pvt.populate_batch.progress',
          	          'Performing team rollup.');
     end if;

     -- get credits from team members
     FOR srp IN team_mbrs LOOP
	FOR mbr IN other_mbrs(srp.comp_team_id, srp.salesrep_id, srp.start_date, srp.end_date) LOOP
	   INSERT INTO cn_commission_lines_all
	     (commission_line_id,
	      commission_header_id,
	      direct_salesrep_id,
	      pre_processed_code,
	      revenue_class_id,
	      credited_salesrep_id,
	      credited_comp_group_id,
	      pending_status,
	      pending_date,
	      created_during,
	      status,
	      processed_date,
	      processed_period_id,
	      trx_type,
	      created_by,
	      creation_date,
          org_id,
		  rollup_level)
	     (select
	      cn_commission_lines_s.nextval,
	      cl.commission_header_id,
	      cl.direct_salesrep_id,
	      cl.pre_processed_code,
	      cl.revenue_class_id,
	      srp.salesrep_id,
	      srp.comp_group_id,
	      'N',
	      null,
	      'TROLL',
	      'ROLL',
	      cl.processed_date,
	      cl.processed_period_id,
	      cl.trx_type,
	      fnd_global.user_id,
	      sysdate,
          g_org_id,
          0
	      from cn_commission_lines_all cl
	      where cl.credited_salesrep_id = mbr.salesrep_id
	      and cl.processed_date between mbr.start_date and mbr.end_date
	      and cl.created_during = 'ROLL'
	      AND cl.status <> 'OBSOLETE'
          and cl.org_id = g_org_id
	      and not exists (select 1
			      from cn_commission_lines_all
			      where commission_header_id = cl.commission_header_id
			      and credited_salesrep_id = srp.salesrep_id));
	   IF (SQL%found) THEN
	      cn_mark_events_pkg.mark_notify
		( p_salesrep_id     => srp.salesrep_id,
		  p_period_id       => srp.period_id,
		  p_start_date      => srp.start_date,
		  p_end_date        => srp.start_date,
		  p_quota_id        => NULL,
		  p_revert_to_state => 'CALC',
		  p_event_log_id    => null,
          p_org_id          => g_org_id);
	   END IF;
	END LOOP;
     END LOOP;

     commit;

     g_calc_type := cn_calc_sub_batches_pkg.get_calc_type(p_physical_batch_id);

     OPEN rev_class_hierarchy_id;
     FETCH rev_class_hierarchy_id INTO l_rev_class_hierarchy_id;
     CLOSE rev_class_hierarchy_id;

     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.cn_calc_populate_pvt.populate_batch.progress',
          	          'Populating transactions.');
     end if;

     for rep in salesreps loop
	   i := 1;

	   if (l_rev_class_hierarchy_id is not null) then
	   for plan in plan_info(rep.credited_salesrep_id,
				 rep.credited_comp_group_id,
				 rep.revenue_class_id,
				 rep.start_date,
				 rep.end_date)
       loop
         select nvl(indirect_credit, 'ALL') into l_indirect_credit
           from cn_quotas_all
          where quota_id = plan.quota_id;

         select manager_flag into l_manager_flag
           from cn_roles
          where role_id = plan.role_id;

         if (i = 1) then
		 l_start_date := plan.start_date;
		 l_end_date := plan.end_date;
		 g_end_date := l_end_date;

		 update cn_commission_lines_all cl
		    set cl.srp_plan_assign_id = plan.srp_plan_assign_id,
		        cl.quota_id = plan.quota_id,
		        cl.quota_rule_id = plan.quota_rule_id,
		        cl.status = 'POP',
		        cl.role_id = plan.role_id,
                cl.pay_period_id = cl.processed_period_id
		  where cl.credited_salesrep_id = rep.credited_salesrep_id
		    and cl.credited_comp_group_id = rep.credited_comp_group_id
            and cl.processed_period_id between rep.period_id and rep.end_period_id
            and cl.processed_date between l_start_date and l_end_date
            and cl.created_during in ('ROLL', 'TROLL')
            and cl.status IN ('ROLL')
            and cl.org_id = g_org_id
		    and cl.quota_id IS NULL
            and cl.revenue_class_id = rep.revenue_class_id
            and (substr(cl.pre_processed_code, 3,1) = 'P' or
                 (substr(cl.pre_processed_code, 3,1) = 'N' and
                  cl.direct_salesrep_id <> cl.credited_salesrep_id))
            and ((l_indirect_credit = 'ALL') or
                 (l_indirect_credit = 'MGR' and l_manager_flag = 'Y') or
                 (l_indirect_credit = 'MGR' and l_manager_flag = 'N' and cl.direct_salesrep_id = cl.credited_salesrep_id) or
                 (l_indirect_credit = 'NONE' and cl.direct_salesrep_id = cl.credited_salesrep_id));
         else
           if (g_end_date >= plan.start_date) then
		    l_start_date := plan.start_date;
		    if (g_end_date < plan.end_date) then
		       l_end_date := g_end_date;
		     else
		       l_end_date := plan.end_date;
		    end if;

            merge into cn_commission_lines_all cl
            using (select commission_line_id,
                          commission_header_id,
		                  direct_salesrep_id,
		                  pre_processed_code,
		                  revenue_class_id,
		                  credited_salesrep_id,
		                  credited_comp_group_id,
		                  role_id,
		                  processed_period_id,
		                  pay_period_id,
		                  pending_status,
		                  srp_plan_assign_id,
		                  quota_id,
		                  quota_rule_id,
		                  status,
		                  created_during,
		                  payee_line_id,
		                  trx_type,
		                  processed_date,
		                  creation_date,
		                  created_by,
                          org_id,
                          rollup_level
                     from cn_commission_lines_all cl2
                    where credited_salesrep_id = rep.credited_salesrep_id
		              and processed_date between l_start_date and l_end_date
		              and processed_period_id between rep.period_id and rep.end_period_id
		              and credited_comp_group_id = rep.credited_comp_group_id
		              and created_during in ('ROLL', 'TROLL')
		              and status <> 'OBSOLETE'
                      and org_id = g_org_id
		              and revenue_class_id = rep.revenue_class_id
		              and not exists (select 1 from cn_commission_lines_all
		                               where credited_salesrep_id = cl2.credited_salesrep_id
		                                 and commission_header_id = cl2.commission_header_id
		                                 and srp_plan_assign_id = plan.srp_plan_assign_id
		                                 and quota_id = plan.quota_id)
		              and ((substr(pre_processed_code, 3,1) = 'P') or
                           (substr(pre_processed_code, 3,1) = 'N' and
						    direct_salesrep_id <> credited_salesrep_id))
                      and ((l_indirect_credit = 'ALL') or
                           (l_indirect_credit = 'MGR' and l_manager_flag = 'Y') or
                           (l_indirect_credit = 'MGR' and l_manager_flag = 'N' and
                            direct_salesrep_id = credited_salesrep_id) or
                           (l_indirect_credit = 'NONE' and direct_salesrep_id = credited_salesrep_id))) s
            on (cl.commission_line_id = s.commission_line_id and s.status = 'ROLL')
            when not matched then
               insert(commission_line_id,
		       commission_header_id,
		       direct_salesrep_id,
		       pre_processed_code,
		       revenue_class_id,
		       credited_salesrep_id,
		       credited_comp_group_id,
		       role_id,
		       processed_period_id,
		       pay_period_id,
		       pending_status,
		       srp_plan_assign_id,
		       quota_id,
		       quota_rule_id,
		       status,
		       created_during,
		       payee_line_id,
		       trx_type,
		       processed_date,
		       creation_date,
		       created_by,
                       org_id,
		       rollup_level)
		       values(
		       cn_commission_lines_s.nextval,
		       s.commission_header_id,
		       s.direct_salesrep_id,
		       s.pre_processed_code,
		       s.revenue_class_id,
		       s.credited_salesrep_id,
		       s.credited_comp_group_id,
		       plan.role_id,
		       s.processed_period_id,
		       s.pay_period_id,
		       s.pending_status,
		       plan.srp_plan_assign_id,
		       plan.quota_id,
		       plan.quota_rule_id,
		       'POP',
		       'POP',
		       s.commission_line_id,
		       s.trx_type,
		       s.processed_date,
		       g_creation_date,
		       g_created_by,
                       g_org_id,
	               s.rollup_level);


              UPDATE cn_commission_lines_all cl2
              SET cl2.srp_plan_assign_id = plan.srp_plan_assign_id,
                cl2.quota_id             = plan.quota_id,
                cl2.quota_rule_id        = plan.quota_rule_id,
                cl2.status               = 'POP',
                cl2.role_id              = plan.role_id,
                cl2.pay_period_id        = cl2.processed_period_id
              WHERE credited_salesrep_id = rep.credited_salesrep_id
              AND processed_date BETWEEN l_start_date AND l_end_date
              AND processed_period_id BETWEEN rep.period_id AND rep.end_period_id
              AND credited_comp_group_id = rep.credited_comp_group_id
              AND created_during        IN ('ROLL', 'TROLL')
              AND status                 = 'ROLL'
              AND org_id                 = g_org_id
              AND revenue_class_id       = rep.revenue_class_id
              AND NOT EXISTS
                (SELECT 1
                FROM cn_commission_lines_all
                WHERE credited_salesrep_id = cl2.credited_salesrep_id
                AND commission_header_id   = cl2.commission_header_id
                AND srp_plan_assign_id     = plan.srp_plan_assign_id
                AND quota_id               = plan.quota_id
                )
              AND ((SUBSTR(pre_processed_code, 3,1) = 'P')
              OR (SUBSTR(pre_processed_code, 3,1)   = 'N'
              AND direct_salesrep_id               <> credited_salesrep_id))
              AND ((l_indirect_credit               = 'ALL')
              OR (l_indirect_credit                 = 'MGR'
              AND l_manager_flag                    = 'Y')
              OR (l_indirect_credit                 = 'MGR'
              AND l_manager_flag                    = 'N'
              AND direct_salesrep_id                = credited_salesrep_id)
              OR (l_indirect_credit                 = 'NONE'
              AND direct_salesrep_id                = credited_salesrep_id));

           end if;
           if (g_end_date < plan.end_date) then
             if (plan.start_date > g_end_date) then
		       l_start_date := plan.start_date;
		     else
		       l_start_date := g_end_date + 1;
		     end if;
		     l_end_date := plan.end_date;
		     g_end_date := plan.end_date;

		     update cn_commission_lines_all cl
		        set cl.srp_plan_assign_id = plan.srp_plan_assign_id,
		            cl.quota_id = plan.quota_id,
		            cl.quota_rule_id = plan.quota_rule_id,
		            cl.status = 'POP',
		            cl.role_id = plan.role_id,
		            cl.pay_period_id = cl.processed_period_id
		      where cl.credited_salesrep_id = rep.credited_salesrep_id
		      and cl.credited_comp_group_id = rep.credited_comp_group_id
		      and cl.processed_period_id between rep.period_id and rep.end_period_id
		      and cl.processed_date between l_start_date and l_end_date
		      and cl.created_during in ('ROLL', 'TROLL')
              and cl.org_id = g_org_id
		      and cl.status IN ('ROLL')
		      and cl.quota_id IS NULL
		      and cl.revenue_class_id = rep.revenue_class_id
		      and (substr(cl.pre_processed_code, 3,1) = 'P' or
			   (substr(cl.pre_processed_code, 3,1) = 'N' and
			    cl.direct_salesrep_id <> cl.credited_salesrep_id))
            and ((l_indirect_credit = 'ALL') or
                 (l_indirect_credit = 'MGR' and l_manager_flag = 'Y') or
                 (l_indirect_credit = 'MGR' and l_manager_flag = 'N' and cl.direct_salesrep_id = cl.credited_salesrep_id) or
                 (l_indirect_credit = 'NONE' and cl.direct_salesrep_id = cl.credited_salesrep_id));
           end if;
         end if;
	     i := i + 1;
       end loop;
	 else -- no revenue hierarchy
	   for plan in plan_info2(rep.credited_salesrep_id,
				  rep.credited_comp_group_id,
				  rep.revenue_class_id,
				  rep.start_date,
				  rep.end_date)
	   loop
	      if (i = 1) then
		 l_start_date := plan.start_date;
		 l_end_date := plan.end_date;
		 g_end_date := l_end_date;
		 update cn_commission_lines_all cl
		    set cl.srp_plan_assign_id = plan.srp_plan_assign_id,
                cl.quota_id = plan.quota_id,
	            cl.quota_rule_id = plan.quota_rule_id,
	            cl.status = 'POP',
	            cl.role_id = plan.role_id,
                cl.pay_period_id = cl.processed_period_id
		  where cl.credited_salesrep_id = rep.credited_salesrep_id
            and cl.credited_comp_group_id = rep.credited_comp_group_id
            and cl.processed_period_id between rep.period_id and rep.end_period_id
            and cl.processed_date between l_start_date and l_end_date
            and cl.created_during in ('ROLL', 'TROLL')
            and cl.status IN ('ROLL')
            and cl.org_id = g_org_id
		    and cl.quota_id IS NULL
            and cl.revenue_class_id = rep.revenue_class_id
            and (substr(cl.pre_processed_code, 3,1) = 'P' or
                 (substr(cl.pre_processed_code, 3,1) = 'N' and
                  cl.direct_salesrep_id <> cl.credited_salesrep_id));
	       else
		 if (g_end_date >= plan.start_date) then
		    l_start_date := plan.start_date;
		    if (g_end_date < plan.end_date) then
		       l_end_date := g_end_date;
		     else
		       l_end_date := plan.end_date;
		    end if;
            merge into cn_commission_lines_all cl
            using (select commission_line_id,
                          commission_header_id,
		                  direct_salesrep_id,
		                  pre_processed_code,
		                  revenue_class_id,
		                  credited_salesrep_id,
		                  credited_comp_group_id,
		                  role_id,
		                  processed_period_id,
		                  pay_period_id,
		                  pending_status,
		                  srp_plan_assign_id,
		                  quota_id,
		                  quota_rule_id,
		                  status,
		                  created_during,
		                  payee_line_id,
		                  trx_type,
		                  processed_date,
		                  creation_date,
		                  created_by,
                          org_id,
                          rollup_level
                     from cn_commission_lines_all cl2
                    where credited_salesrep_id = rep.credited_salesrep_id
		              and processed_date between l_start_date and l_end_date
		              and processed_period_id between rep.period_id and rep.end_period_id
		              and credited_comp_group_id = rep.credited_comp_group_id
		              and created_during in ('ROLL', 'TROLL')
		              and status <> 'OBSOLETE'
                      and org_id = g_org_id
		              and revenue_class_id = rep.revenue_class_id
		              and not exists (select 1 from cn_commission_lines_all
		                               where credited_salesrep_id = cl2.credited_salesrep_id
		                                 and commission_header_id = cl2.commission_header_id
		                                 and srp_plan_assign_id = plan.srp_plan_assign_id
		                                 and quota_id = plan.quota_id)
		              and ((substr(pre_processed_code, 3,1) = 'P') or
                           (substr(pre_processed_code, 3,1) = 'N' and
						    direct_salesrep_id <> credited_salesrep_id))
                      and ((l_indirect_credit = 'ALL') or
                           (l_indirect_credit = 'MGR' and l_manager_flag = 'Y') or
                           (l_indirect_credit = 'MGR' and l_manager_flag = 'N' and
                            direct_salesrep_id = credited_salesrep_id) or
                           (l_indirect_credit = 'NONE' and direct_salesrep_id = credited_salesrep_id))) s
            on (cl.commission_line_id = s.commission_line_id and s.status = 'ROLL')
            when not matched then
               insert(commission_line_id,
		       commission_header_id,
		       direct_salesrep_id,
		       pre_processed_code,
		       revenue_class_id,
		       credited_salesrep_id,
		       credited_comp_group_id,
		       role_id,
		       processed_period_id,
		       pay_period_id,
		       pending_status,
		       srp_plan_assign_id,
		       quota_id,
		       quota_rule_id,
		       status,
		       created_during,
		       payee_line_id,
		       trx_type,
		       processed_date,
		       creation_date,
		       created_by,
                       org_id,
		       rollup_level)
		       values(
		       cn_commission_lines_s.nextval,
		       s.commission_header_id,
		       s.direct_salesrep_id,
		       s.pre_processed_code,
		       s.revenue_class_id,
		       s.credited_salesrep_id,
		       s.credited_comp_group_id,
		       plan.role_id,
		       s.processed_period_id,
		       s.pay_period_id,
		       s.pending_status,
		       plan.srp_plan_assign_id,
		       plan.quota_id,
		       plan.quota_rule_id,
		       'POP',
		       'POP',
		       s.commission_line_id,
		       s.trx_type,
		       s.processed_date,
		       g_creation_date,
		       g_created_by,
                       g_org_id,
	               s.rollup_level);


                UPDATE cn_commission_lines_all cl2
                SET cl2.srp_plan_assign_id = plan.srp_plan_assign_id,
                  cl2.quota_id             = plan.quota_id,
                  cl2.quota_rule_id        = plan.quota_rule_id,
                  cl2.status               = 'POP',
                  cl2.role_id              = plan.role_id,
                  cl2.pay_period_id        = cl2.processed_period_id
                WHERE credited_salesrep_id = rep.credited_salesrep_id
                AND processed_date BETWEEN l_start_date AND l_end_date
                AND processed_period_id BETWEEN rep.period_id AND rep.end_period_id
                AND credited_comp_group_id = rep.credited_comp_group_id
                AND created_during        IN ('ROLL', 'TROLL')
                AND status                 = 'ROLL'
                AND org_id                 = g_org_id
                AND revenue_class_id       = rep.revenue_class_id
                AND NOT EXISTS
                  (SELECT 1
                  FROM cn_commission_lines_all
                  WHERE credited_salesrep_id = cl2.credited_salesrep_id
                  AND commission_header_id   = cl2.commission_header_id
                  AND srp_plan_assign_id     = plan.srp_plan_assign_id
                  AND quota_id               = plan.quota_id
                  )
                AND ((SUBSTR(pre_processed_code, 3,1) = 'P')
                OR (SUBSTR(pre_processed_code, 3,1)   = 'N'
                AND direct_salesrep_id               <> credited_salesrep_id))
                AND ((l_indirect_credit               = 'ALL')
                OR (l_indirect_credit                 = 'MGR'
                AND l_manager_flag                    = 'Y')
                OR (l_indirect_credit                 = 'MGR'
                AND l_manager_flag                    = 'N'
                AND direct_salesrep_id                = credited_salesrep_id)
                OR (l_indirect_credit                 = 'NONE'
                AND direct_salesrep_id                = credited_salesrep_id));


		 end if;
		 if (g_end_date < plan.end_date) then
		    if (plan.start_date > g_end_date) then
		       l_start_date := plan.start_date;
		     else
		       l_start_date := g_end_date + 1;
		    end if;
		    l_end_date := plan.end_date;
		    g_end_date := plan.end_date;
		    update cn_commission_lines_all cl
		       set cl.srp_plan_assign_id = plan.srp_plan_assign_id,
		           cl.quota_id = plan.quota_id,
		           cl.quota_rule_id = plan.quota_rule_id,
		           cl.status = 'POP',
		           cl.role_id = plan.role_id,
		           cl.pay_period_id = cl.processed_period_id
		      where cl.credited_salesrep_id = rep.credited_salesrep_id
		        and cl.credited_comp_group_id = rep.credited_comp_group_id
		        and cl.processed_period_id between rep.period_id and rep.end_period_id
		        and cl.processed_date between l_start_date and l_end_date
		        and cl.created_during in ('ROLL', 'TROLL')
                and cl.org_id = g_org_id
		        and cl.status IN ('ROLL')
		        and cl.quota_id IS NULL
			and cl.revenue_class_id = rep.revenue_class_id
			and (substr(cl.pre_processed_code, 3,1) = 'P' or
			     (substr(cl.pre_processed_code, 3,1) = 'N' and
			      cl.direct_salesrep_id <> cl.credited_salesrep_id));

		 end if;
	      end if;
	      i := i + 1;
	   end loop;
	  end if;

     end loop;

	 commit;

     --handle those trxs skipping POP phase. BUT only SOURCE trxs can skip POP phase.
     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.cn_calc_populate_pvt.populate_batch.progress',
          	          'Processing transactions that skip POP phase.');
     end if;

     l_processed_date_prev := To_date('01/01/1900', 'DD/MM/YYYY');
     l_salesrep_id_prev := -999999;
     l_role_id_prev     := -999999;
     l_quota_id_prev    := -999999;
     l_revenue_class_id_prev := -999999;

     FOR srp IN l_skip_salesreps_csr LOOP
	  IF l_processed_date_prev <> srp.processed_date THEN
	   l_dim_hierarchy_id := null;

	   OPEN l_dim_hierarchy_csr(srp.processed_date);
  	   FETCH l_dim_hierarchy_csr INTO l_dim_hierarchy_id;
           CLOSE l_dim_hierarchy_csr;
        END IF;

	-- must be able to figure out srp_plan_assign_id
	IF l_processed_date_prev <> srp.processed_date OR l_salesrep_id_prev <> srp.salesrep_id
	  OR l_role_id_prev <> srp.role_id THEN
	   l_srp_plan_assign_id := NULL;

	   OPEN l_spa_csr ( srp.processed_date, srp.salesrep_id, srp.role_id );
	   FETCH l_spa_csr INTO l_srp_plan_assign_id;
	   CLOSE l_spa_csr;

	   IF l_srp_plan_assign_id IS NULL THEN
	      GOTO end_of_skip_loop;
	   END IF;
	 ELSE
	   IF l_srp_plan_assign_id IS NULL THEN
	      GOTO end_of_skip_loop;
	   END IF;
	END IF;

	-- must be able to figure out quota_rule_id
	IF l_quota_id_prev <> srp.quota_id OR l_revenue_class_id_prev <> srp.revenue_class_id THEN
	   l_quota_rule_id := NULL;

	   IF l_dim_hierarchy_id IS NULL THEN
	      OPEN l_quota_rule_no_hier_csr ( srp.quota_id, srp.revenue_class_id );
	      FETCH l_quota_rule_no_hier_csr INTO l_quota_rule_id;
	      CLOSE l_quota_rule_no_hier_csr;
	    ELSE
	      OPEN l_quota_rule_hier_csr ( srp.quota_id, srp.revenue_class_id );
	      FETCH l_quota_rule_hier_csr INTO l_quota_rule_id;
	      CLOSE l_quota_rule_hier_csr;
	   END IF;

	   IF l_quota_rule_id IS NULL THEN
	      GOTO end_of_skip_loop;
	   END IF;
	 ELSE
	   IF l_quota_rule_id IS NULL THEN
	      GOTO end_of_skip_loop;
	   END IF;
	END IF;

	IF l_srp_plan_assign_id IS NOT NULL AND l_quota_rule_id IS NOT NULL THEN
	   UPDATE cn_commission_lines_all cl
	      SET cl.status = 'POP',
	          cl.role_id = srp.role_id,
	          cl.srp_plan_assign_id = l_srp_plan_assign_id,
	          cl.quota_id = srp.quota_id,
	          cl.quota_rule_id = l_quota_rule_id,
              cl.pay_period_id = cl.processed_period_id
	    WHERE cl.credited_salesrep_id = srp.salesrep_id
	      AND cl.processed_period_id = srp.processed_period_id
	      AND cl.processed_date = srp.processed_date
          AND cl.org_id = g_org_id
          AND cl.status IN ('ROLL')
	      AND ((g_calc_type = 'COMMISSION' AND cl.trx_type NOT IN ('BONUS', 'GRP', 'FORECAST')) OR
		       (g_calc_type = 'FORECAST' AND cl.trx_type = 'FORECAST'))
	      AND exists
	     (SELECT 1
	        FROM cn_commission_headers_all ch
	       WHERE ch.commission_header_id = cl.commission_header_id
	         AND ch.role_id = srp.role_id
	         AND ch.quota_id = srp.quota_id
	         AND substr(ch.pre_processed_code,3,1) = 'N'
	         AND ch.direct_salesrep_id = srp.salesrep_id  );
	END IF;

	<<end_of_skip_loop>>

	l_processed_date_prev := srp.processed_date;
	l_salesrep_id_prev    := srp.salesrep_id;
	l_role_id_prev        := srp.role_id;
	l_quota_id_prev := srp.quota_id;
	l_revenue_class_id_prev := srp.revenue_class_id;

     END LOOP;

     commit;

     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.cn_calc_populate_pvt.populate_batch.progress',
          	          'Updating unpopulated transactions to XPOP.');
     end if;

     UPDATE cn_commission_lines_all cl
        SET cl.status = 'XPOP',
            quota_id = NULL,
            quota_rule_id = NULL,
            role_id =NULL,
            srp_plan_assign_id = NULL
      WHERE cl.commission_line_id IN
          (SELECT line.commission_line_id
	         FROM cn_commission_lines_all line,
	              cn_process_batches_all pb
	        WHERE pb.physical_batch_id = p_physical_batch_id
	          AND line.credited_salesrep_id = pb.salesrep_id
	          AND line.processed_period_id BETWEEN pb.period_id AND pb.end_period_id
	          AND line.processed_date BETWEEN pb.start_date AND pb.end_date
	          AND line.status = 'ROLL'
              AND line.org_id = g_org_id
	          AND ((g_calc_type = 'COMMISSION' AND line.trx_type NOT IN ('BONUS', 'GRP', 'FORECAST')) OR
	               (g_calc_type = 'FORECAST' AND line.trx_type = 'FORECAST')));

     commit;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       ( p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      'cn.plsql.cn_calc_populate_pvt.populate_batch.exception',
          	          sqlerrm);
    end if;
	fnd_file.put_line(fnd_file.log, 'In populate_batch: '||sqlerrm);
	cn_message_pkg.debug('Exception occurs in cn_calc_populate_pvt.populate_batch:');
	cn_message_pkg.debug(sqlerrm);
  END populate_batch;

END cn_calc_populate_pvt;

/

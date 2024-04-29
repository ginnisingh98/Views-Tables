--------------------------------------------------------
--  DDL for Package Body CN_CALC_SUBLEDGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SUBLEDGER_PVT" AS
-- $Header: cnvcsubb.pls 120.8.12010000.2 2008/09/06 00:54:26 mguo ship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_CALC_SUBLEDGER_PVT';
  g_org_id      NUMBER;

  FUNCTION get_max_period(p_quota_id NUMBER,
			    p_period_id NUMBER,
			    p_srp_plan_assign_id NUMBER) RETURN NUMBER IS
     l_max_period_id NUMBER(15);
  BEGIN
     SELECT max(p2.cal_period_id)
       INTO l_max_period_id
       FROM cn_cal_per_int_types_all p2,
       cn_srp_period_quotas_all cspq
       WHERE p2.interval_type_id = (select interval_type_id
                                    from cn_quotas_all
                                   where quota_id = p_quota_id)
       AND p2.interval_number = (select p1.interval_number
                                   from cn_cal_per_int_types_all p1
                                  where p1.cal_period_id = p_period_id
                                    and p1.org_id = g_org_id
                                    and p1.interval_type_id = (select interval_type_id
                                                                 from cn_quotas_all
                                                                where quota_id = p_quota_id))
       AND p2.org_id = g_org_id
       AND cspq.srp_plan_assign_id = p_srp_plan_assign_id
       AND cspq.quota_id = p_quota_id
       AND cspq.period_id = p2.cal_period_id;

     RETURN l_max_period_id;

  END get_max_period;

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
  --  IN	:  p_srp_subledger     srp_subledger_rec_type Required
  --
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE update_srp_subledger
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_srp_subledger         IN srp_subledger_rec_type
      ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Update_srp_subledger';
     l_api_version    CONSTANT NUMBER :=1.0;

     G_PAYEE_ROLE     CONSTANT NUMBER := 54;

     l_earnings    NUMBER;
     l_salesrep_id NUMBER;
     l_start_date  DATE ;
     l_end_date    DATE ;

     l_role_id        NUMBER(15);
     l_quota_id       NUMBER(15);
     l_credit_type_id NUMBER(15);
     l_period_id      NUMBER(15);

     l_calc_type   VARCHAR2(30);

     l_delta_subledger cn_srp_periods_pvt.delta_srp_period_rec_type
       := CN_SRP_PERIODS_PVT.G_MISS_DELTA_SRP_PERIOD_REC;

	 CURSOR salesrep_cr IS
	    SELECT salesrep_id, start_date, end_date, period_id, end_period_id
	      FROM cn_process_batches_all
	      WHERE physical_batch_id = p_srp_subledger.physical_batch_id
		  ORDER BY process_batch_id;

	 l_salesrep salesrep_cr%ROWTYPE;

     l_dummy number;

     cursor end_calc is
           select 1
             from cn_process_batches_all
            where physical_batch_id = p_srp_subledger.physical_batch_id
              and trx_batch_id = physical_batch_id
              and rownum = 1;

     cursor payees_cr is
           select sp.srp_period_id,
                  nvl(sum(cl.commission_amount),0) comm_earned_ptd
             from cn_srp_periods_all sp,
                  cn_srp_payee_assigns_all spa,
                  (select b.payee_id,
                          min(a.start_date) start_date,
                          max(a.end_date) end_date,
                          min(a.period_id) period_id,
                          max(a.end_period_id) end_period_id
                     from cn_process_batches_all a,
                          cn_srp_payee_assigns_all b
                    where a.logical_batch_id = (select logical_batch_id
                                                from cn_process_batches_all
                                               where physical_batch_id = p_srp_subledger.physical_batch_id
                                                 and rownum = 1)
                      and a.salesrep_id = b.salesrep_id
                      and a.org_id = b.org_id
                      and a.start_date <= nvl(b.end_date, a.end_date)
                      and a.end_date >= b.start_date
                      group by b.payee_id) pb,
                  cn_commission_lines_all cl
            where pb.payee_id = spa.payee_id
              and pb.start_date <= nvl(spa.end_date, pb.end_date)
              and pb.end_date >= spa.start_date
              and spa.org_id = g_org_id
              and sp.salesrep_id = spa.payee_id
              and sp.period_id between pb.period_id and pb.end_period_id
              and sp.quota_id = spa.quota_id
              and exists (select 1 from cn_quotas_all q
                           where q.quota_id = sp.quota_id
                             and q.incentive_type_code = l_calc_type)
              and cl.credited_salesrep_id(+) = spa.salesrep_id
              and cl.srp_payee_assign_id(+) = spa.srp_payee_assign_id
              and (cl.processed_period_id is null or cl.processed_period_id = sp.period_id)
              and (cl.quota_id is null or cl.quota_id = sp.quota_id)
              and cl.status(+) = 'CALC'
              and cl.pending_status(+) = 'N'
              and (cl.trx_type is null or cl.trx_type not in ('ADV', 'REC', 'CHG', 'FORECAST', 'BONUS'))
              and (cl.credit_type_id is null or cl.credit_type_id = sp.credit_type_id)
              and sp.role_id = g_payee_role
            group by sp.srp_period_id;

        cursor sync_recs_cr is
           select sp.salesrep_id, sp.credit_type_id, min(sp.period_id) period_id
             from cn_srp_periods_all sp,
                  cn_srp_payee_assigns_all spa,
                  cn_process_batches_all pb
            where pb.logical_batch_id = (select logical_batch_id
                                           from cn_process_batches_all
                                          where physical_batch_id = p_srp_subledger.physical_batch_id
                                            and rownum = 1)
              and pb.salesrep_id = spa.salesrep_id
              and spa.org_id = g_org_id
              and pb.start_date <= nvl(spa.end_date, pb.end_date)
              and pb.end_date >= spa.start_date
              and sp.salesrep_id = spa.payee_id
              and sp.period_id between pb.period_id and pb.end_period_id
              and sp.quota_id = spa.quota_id
              and exists (select 1 from cn_quotas_all q
                           where q.quota_id = sp.quota_id
                             and q.incentive_type_code = l_calc_type)
              and sp.role_id = g_payee_role
          group by sp.salesrep_id, sp.credit_type_id;

CURSOR subledger_cr(p_start_period_id NUMBER, p_end_period_id NUMBER) IS
	   SELECT srp_period_id,
	          salesrep_id,
              role_id,
              quota_id,
              credit_type_id,
              period_id,
              end_date,
              Nvl(balance3_ctd,0) earnings_ptd,
              Nvl(balance2_dtd,0) earnings_due_ptd
	     FROM cn_srp_periods_all
	    WHERE salesrep_id = l_salesrep_id
          AND org_id = g_org_id
	      AND period_id between p_start_period_id and p_end_period_id
	      AND start_date <= l_end_date
	      AND end_date >= l_start_date
              --clku , bug 2655685
              AND role_id <> G_PAYEE_ROLE
              AND quota_id <> -9999
	      ORDER BY period_id;


	 l_subledger subledger_cr%ROWTYPE;

	 CURSOR get_distinct_roles IS
	    SELECT distinct role_id, credit_type_id
	      FROM cn_srp_periods_all
	      WHERE salesrep_id = l_salesrep_id
          AND org_id = g_org_id
	      AND (((start_date <= l_start_date)
		    AND( end_date >= l_start_date))
		   OR ((start_date <= l_end_date)
		       AND (end_date >= l_end_date))
		   OR ((start_date >= l_start_date)
		       AND (end_date <= l_end_date)))
              --clku , bug 2655685
              AND quota_id <> -9999;

	 CURSOR comm_cr IS
       SELECT SUM(Decode(cl.pending_status, 'Y', 0,
			 Decode(cl.trx_type, 'ADV', 0, 'REC', 0, 'CHG', 0,
				             'FORECAST', 0, 'BONUS', 0,
				Nvl(cl.commission_amount,0)))) comm_earned_ptd
	 FROM cn_commission_lines_all cl
        WHERE cl.credited_salesrep_id = l_salesrep_id
	  AND cl.pay_period_id = l_period_id
	  AND cl.role_id = l_role_id
	  AND cl.quota_id = l_quota_id
	  AND cl.status = 'CALC'
	  AND exists (select 1 from cn_quotas_all
		       where quota_id = cl.quota_id
		         and credit_type_id = l_credit_type_id)
	  AND cl.srp_payee_assign_id is NULL;-- only line added to the previously existing query for fixing bug#2495614


	 CURSOR bonus_cr IS
	    SELECT SUM(Decode(cl.pending_status, 'Y', 0,
			      cl.commission_amount))  bonus_earned_ptd
	      FROM cn_commission_lines_all cl,
	           cn_commission_headers_all ch,
	           cn_srp_plan_assigns_all cspa,
	           cn_role_plans_all crp,
	           cn_quotas_all cq
	      WHERE cl.credited_salesrep_id = l_salesrep_id
          AND cl.org_id = g_org_id
	      AND ch.commission_header_id = cl.commission_header_id
	      AND cl.pay_period_id = l_period_id
	      AND cl.quota_id = cq.quota_id
	      AND cq.credit_type_id = l_credit_type_id
	      AND cl.srp_plan_assign_id = cspa.srp_plan_assign_id
	      AND cspa.role_plan_id = crp.role_plan_id
	      AND crp.role_id = l_role_id
	      AND cl.quota_id = l_quota_id
	      AND ch.trx_type = 'BONUS'
	      AND cl.status = 'CALC'
              -- only line added to the previously existing query for fixing bug#2495614
	      AND cl.srp_payee_assign_id is NULL
	      --for perf 7187128
	      AND cl.trx_type = 'BONUS';


	 l_loading_status      varchar2(50);
	 l_return_status       VARCHAR2(50);
	 l_msg_count           NUMBER;
	 l_msg_data            VARCHAR2(2000);

	 --added for bug 2495614
	 l_srp_role_id	       number;
	 l_payeeassigned       boolean := TRUE;

	 -- mblum for bug 2761303
	 sync_needed           boolean := FALSE;
	 l_start_period_id     number;

         -- clku , bug 2433243
         l_int_type_code       VARCHAR2(30);
  BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT update_srp_subledger;

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

     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_subledger_pvt.update_srp_subledger.begin',
			    	'Beginning of update_srp_subledger ...');
     end if;

     cn_message_pkg.debug('Start updating payment subledgers ... ');

     -- Code starts here
     select org_id into g_org_id
       from cn_process_batches_all
      where physical_batch_id = p_srp_subledger.physical_batch_id
        and rownum = 1;

     l_calc_type := cn_calc_sub_batches_pkg.get_calc_type
       (p_srp_subledger.physical_batch_id);

     -- Loop for each salesrep in the physical batch
     FOR l_salesrep IN salesrep_cr LOOP
	 -- loop for each salesrep, period, role, credit_type combination
	 l_salesrep_id := l_salesrep.salesrep_id;
	 l_start_date  := l_salesrep.start_date;
	 l_end_date    := l_salesrep.end_date;
	 sync_needed   := false;

     cn_message_pkg.debug('Updating balances for rep (ID='||l_salesrep_id||')');
	 FOR l_subledger IN subledger_cr(l_salesrep.period_id, l_salesrep.end_period_id) LOOP
	   l_period_id := l_subledger.period_id;
	   l_role_id   := l_subledger.role_id;
	   l_quota_id  := l_subledger.quota_id;
	   l_credit_type_id := l_subledger.credit_type_id;

	   l_earnings := 0;
       IF (l_calc_type = 'COMMISSION') THEN
	      OPEN  comm_cr;
	      FETCH comm_cr INTO l_earnings;
	      CLOSE comm_cr;
	    ELSIF (l_calc_type = 'BONUS') THEN
	      OPEN  bonus_cr;
	      FETCH bonus_cr INTO l_earnings;
	      CLOSE bonus_cr;
	    ELSE
	      -- wrong calc_type, raise an error
	      RAISE FND_API.g_exc_error;
	   END IF;

	   -- clku, 2655685, change cn_quotas to cn_quotas_all
	   -- to handle the deleted PE
	   IF l_quota_id is not null THEN
	     select incentive_type_code
		   into l_int_type_code
		   from cn_quotas_all
		  where quota_id = l_quota_id;

	     If l_int_type_code = l_calc_type THEN
 	       l_delta_subledger.srp_period_id := l_subledger.srp_period_id;
		   l_delta_subledger.del_balance3_ctd := nvl(l_earnings, 0) - l_subledger.earnings_ptd;
           l_delta_subledger.del_balance2_dtd := nvl(l_earnings, 0) - l_subledger.earnings_due_ptd;

		   -- call update API
		   if (l_delta_subledger.del_balance3_ctd <> 0 OR l_delta_subledger.del_balance2_dtd <> 0) then
		     CN_SRP_PERIODS_PVT.Update_Delta_Srp_Pds_No_Sync
		        (p_api_version          => 1.0,
		         x_return_status        => l_return_status,
		         x_msg_count            => l_msg_count,
		         x_msg_data             => l_msg_data,
		         p_del_srp_prd_rec      => l_delta_subledger,
		         x_loading_status       => l_loading_status
		        );
		     if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
               cn_message_pkg.debug('Exception occurs in cn_srp_periods_pvt.update_delta_srp_periods:');
               cn_message_pkg.debug(l_msg_data);
               raise FND_API.g_exc_error;
             end if;

		     if sync_needed = false then
		       sync_needed := true;
		       l_start_period_id := l_period_id;
		     end if;
		   end if;
	     END If;
	   END IF;
	END LOOP; -- for l_srp_subledger cursor loop;

	-- sync bals
	if sync_needed then
	  -- loop through all roles and credit types to be updated
	  for r in get_distinct_roles loop
	    if r.role_id <> G_PAYEE_ROLE then
	      cn_message_pkg.debug('Synchonizing balances for salesrep (salesrep_id='||l_salesrep_id ||
				   ' role_id=' || r.role_id || ' start_period_id=' || l_start_period_id||')');

	      CN_SRP_PERIODS_PVT.Sync_Accum_Balances_Start_Pd
		   (p_salesrep_id            => l_salesrep_id,
		    p_credit_type_id         => r.credit_type_id,
		    p_role_id                => r.role_id,
		    p_start_period_id        => l_start_period_id,
            p_org_id                 => g_org_id);
	    end if;
	  end loop;
	end if;

	commit;

  END LOOP; -- for l_salesrep cursor loop

  -- at the very end of the whole calculation process, update payee subledger
  open end_calc;
  fetch end_calc into l_dummy;
  close end_calc;

  if (l_dummy = 1) then
    for payee in payees_cr loop
      update cn_srp_periods_all
         set balance2_dtd = payee.comm_earned_ptd,
             balance3_ctd = payee.comm_earned_ptd
       where srp_period_id = payee.srp_period_id;
    end loop;

    for rec in sync_recs_cr loop
      cn_srp_periods_pvt.sync_accum_balances_start_pd
		      (p_salesrep_id            => rec.salesrep_id,
		       p_credit_type_id         => rec.credit_type_id,
		       p_role_id                => g_payee_role,
		       p_start_period_id        => rec.period_id,
               p_org_id                 => g_org_id);
    end loop;

  end if;

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'cn.plsql.cn_calc_subledger_pvt.update_srp_subledger.end',
		    	'End of update_srp_subledger ...');
  end if;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
     END IF;

     cn_message_pkg.debug('Finish updating payment subledgers ');

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       ( p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_srp_subledger;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_srp_subledger;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN OTHERS THEN
	ROLLBACK TO update_srp_subledger;
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
                         'cn.plsql.cn_calc_subledger_pvt.update_srp_subledger.exception',
		       		     sqlerrm);
    end if;

    fnd_file.put_line(fnd_file.log, 'EXCEPTION in update_srp_subledger: '||sqlerrm);
    cn_message_pkg.debug('Exception occurs in cn_calc_subledger_pvt.update_srp_subledger: ');
	cn_message_pkg.debug(sqlerrm);
  END update_srp_subledger;

  -- API name 	: update_srp_pe_subledger
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
  --  IN	:  p_srp_pe_subledger     srp_pe_subledger_rec_type Require
  --		   p_mode                  IN VARCHAR2 := 'A'
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE update_srp_pe_subledger
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_srp_pe_subledger      IN srp_pe_subledger_rec_type,
      p_mode                  IN VARCHAR2 := 'A'
      ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Update_srp_pe_subledger';
     l_api_version    CONSTANT NUMBER :=1.0;

     l_max_period_id cn_period_statuses.period_id%TYPE;
     l_start_period_id cn_period_statuses.period_id%TYPE;

	 CURSOR comm_bonus_cr IS
	    SELECT SUM(Decode(cl.pending_status, 'Y', 0,
			      Decode(cl.trx_type, 'ADV', 0, 'REC', 0, 'CHG', 0, 'FORECAST', 0,
				     Nvl(cl.commission_amount,0)))) comm_earned_ptd,
	      SUM(Decode(cl.pending_status, 'Y', 0,
			 Decode(cl.trx_type, 'ADV', cl.commission_amount, 0))) adv_paid_ptd,
	      SUM(Decode(cl.pending_status, 'Y', 0,
			 Decode(cl.trx_type, 'REC', cl.commission_amount, 0))) adv_earned_ptd,
	      SUM(Decode(cl.pending_status, 'Y', 0,
			 Decode(cl.trx_type, 'CHG', cl.commission_amount, 0))) rec_amount_ptd,
  	      SUM(Decode(cl.pending_status, 'Y', cl.commission_amount, 0)) comm_pending_ptd,
            SUM(ch.transaction_amount) transaction_amount_ptd
  	      FROM cn_commission_lines cl, cn_commission_headers_all ch
	      WHERE
	      cl.credited_salesrep_id = p_srp_pe_subledger.salesrep_id
	      --for payee enh. bug#2495614 above condition is replaced by the following code
	      --(
	      --  (cl.credited_salesrep_id = p_srp_pe_subledger.salesrep_id
	      --  and
	      --  cl.srp_payee_assign_id IS NULL)
	      --  OR
	      --  (
	      --  	cl.srp_payee_assign_id IS NOT NULL
	      --  	AND EXISTS
	      --  	(
	      --  		Select 'X' from cn_srp_payee_assigns cspa
	      --  		where cspa.srp_payee_assign_id = cl.srp_payee_assign_id
	      --  		and cspa.payee_id = p_srp_pe_subledger.salesrep_id
	      --  	)
	      --  )
	      --)
	      AND cl.processed_period_id = p_srp_pe_subledger.accu_period_id
	      AND cl.quota_id = p_srp_pe_subledger.quota_id
	      AND cl.srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id
  	      AND cl.status = 'CALC'
          AND cl.commission_header_id = ch.commission_header_id;

	 CURSOR quota_type_cr IS
	    SELECT f.calc_formula_id calc_formula_id,
               q.quota_type_code quota_type_code,
               q.package_name package_name,
	           f.trx_group_code trx_group_code,
               q.org_id
	      FROM cn_calc_formulas_all f,
	           cn_quotas_all q
	      WHERE q.quota_id = p_srp_pe_subledger.quota_id
	      AND f.calc_formula_id(+) = q.calc_formula_id
          AND f.org_id(+) = q.org_id;

	 CURSOR revenue_classes is
	    SELECT revenue_class_id
	      FROM cn_srp_per_quota_rc_all
	      WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
	      AND period_id = p_srp_pe_subledger.accu_period_id
	      AND quota_id = p_srp_pe_subledger.quota_id
	      AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id;

	 CURSOR periods_cr IS
	    SELECT spq.period_id period_id,
	      spq.srp_period_quota_id,
	      Nvl(spq.transaction_amount_ptd, 0) transaction_amount_ptd,
	      Nvl(spq.commission_payed_ptd, 0) commission_payed_ptd,
	      Nvl(spq.input_achieved_ptd,0) input_achieved_ptd,
	      Nvl(spq.output_achieved_ptd,0) output_achieved_ptd,
	      Nvl(spq.perf_achieved_ptd,0) perf_achieved_ptd,
	      Nvl(spq.advance_recovered_ptd,0) advance_recovered_ptd,
	      Nvl(spq.advance_to_rec_ptd,0) advance_to_rec_ptd,
	      Nvl(spq.recovery_amount_ptd,0) recovery_amount_ptd,
	      Nvl(spq.comm_pend_ptd,0) comm_pend_ptd,
	      Nvl(spq.transaction_amount_itd, 0) transaction_amount_itd,
	      Nvl(spq.commission_payed_itd,0) commission_payed_itd,
	      Nvl(spq.input_achieved_itd,0) input_achieved_itd,
	      Nvl(spq.output_achieved_itd,0) output_achieved_itd,
	      Nvl(spq.perf_achieved_itd,0) perf_achieved_itd,
	      Nvl(spq.advance_recovered_itd,0) advance_recovered_itd ,
	      Nvl(spq.advance_to_rec_itd,0) advance_to_rec_itd,
	      Nvl(spq.recovery_amount_itd,0) recovery_amount_itd,
	      Nvl(spq.comm_pend_itd,0)comm_pend_itd
	      FROM cn_srp_period_quotas_all spq
	      WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
	      AND period_id >=  p_srp_pe_subledger.accu_period_id
	      AND quota_id = p_srp_pe_subledger.quota_id
	      AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id
	      AND period_id <= l_max_period_id
	      ORDER BY spq.period_id ASC;

	 CURSOR periods_ext(p_srp_period_quota_id NUMBER) IS
	    SELECT nvl(input_achieved_ptd, 0) input_achieved_ptd,
	      nvl(input_achieved_itd, 0) input_achieved_itd,
	      input_sequence
	      FROM cn_srp_period_quotas_ext_all
	      WHERE srp_period_quota_id = p_srp_period_quota_id
	      ORDER BY input_sequence;

	 comm_bonus comm_bonus_cr%ROWTYPE;

	 quota_type quota_type_cr%ROWTYPE;

     l_transaction_amount_itd NUMBER;
	 l_commission_payed_itd NUMBER;
	 l_input_achieved_itd NUMBER;
	 l_output_achieved_itd NUMBER;
	 l_perf_achieved_itd NUMBER;
	 l_advance_recovered_itd NUMBER;
	 l_advance_to_rec_itd NUMBER;
	 l_recovery_amount_itd NUMBER;
	 l_comm_pend_itd NUMBER;

	 l_srp_period_quota_id NUMBER(15);
	 l_input_achieved_itd_tbl cn_formula_common_pkg.num_table_type;

	 l_sql_stmt      VARCHAR2(2000);
  BEGIN

     cn_message_pkg.debug('Start updating calculation subledgers ... ');

     -- Standard Start of API savepoint
     SAVEPOINT	update_srp_pe_subledger;

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

     -- Codes start here
     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_subledger_pvt.update_srp_pe_subledger.begin',
			    	'Beginning of update_srp_pe_subledger (srp_plan_assign_id='
					 ||p_srp_pe_subledger.srp_plan_assign_id|| ' and quota_id='||p_srp_pe_subledger.quota_id);
     end if;

     select org_id into g_org_id
       from cn_srp_plan_assigns_all
      where srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id;

     -- get the max period in this interval

     l_max_period_id := get_max_period(p_quota_id  => p_srp_pe_subledger.quota_id,
				       p_period_id => p_srp_pe_subledger.accu_period_id,
				       p_srp_plan_assign_id => p_srp_pe_subledger.srp_plan_assign_id);

     l_start_period_id := cn_formula_common_pkg.get_start_period_id(p_srp_pe_subledger.quota_id, p_srp_pe_subledger.accu_period_id);

     cn_message_pkg.debug('Last period in the interval is ' || l_max_period_id);

     -- update cn_srp_period_quotas for the current period.

     OPEN comm_bonus_cr;
     FETCH comm_bonus_cr INTO comm_bonus;

     IF (comm_bonus_cr%notfound) THEN

	cn_message_pkg.debug('No commission lines');

     END IF;

     IF p_mode = 'A' THEN

	-- All Columns need to be updated
	UPDATE cn_srp_period_quotas_all
	  SET input_achieved_ptd  = p_srp_pe_subledger.input_ptd(1) ,
	  input_achieved_itd  = p_srp_pe_subledger.input_itd(1) ,

	  output_achieved_ptd  = p_srp_pe_subledger.output_ptd ,
	  output_achieved_itd  = p_srp_pe_subledger.output_itd ,

	  perf_achieved_ptd  = p_srp_pe_subledger.perf_ptd ,
	  perf_achieved_itd  = p_srp_pe_subledger.perf_itd ,

	  transaction_amount_ptd = Nvl(comm_bonus.transaction_amount_ptd,0),
	  transaction_amount_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.transaction_amount_ptd, 0),
					Nvl(transaction_amount_itd,0) -  Nvl(transaction_amount_ptd ,0)
					+ Nvl(comm_bonus.transaction_amount_ptd, 0)),

	  commission_payed_ptd = Nvl(comm_bonus.comm_earned_ptd,0),
	  commission_payed_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.comm_earned_ptd, 0),
					Nvl(commission_payed_itd,0) -  Nvl(commission_payed_ptd ,0)
					+ Nvl(comm_bonus.comm_earned_ptd, 0)),

	  advance_recovered_ptd = Nvl(comm_bonus.adv_earned_ptd,0),
	  advance_recovered_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.adv_earned_ptd, 0),
					 Nvl(advance_recovered_itd,0) -  Nvl(advance_recovered_ptd,0)
					 + Nvl(comm_bonus.adv_earned_ptd, 0)),

	  advance_to_rec_ptd = Nvl(comm_bonus.adv_paid_ptd,0),
	  advance_to_rec_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.adv_paid_ptd, 0),
				      Nvl(advance_to_rec_itd,0) -  Nvl(advance_to_rec_ptd,0)
				      + Nvl(comm_bonus.adv_paid_ptd, 0)),

	  recovery_amount_ptd = Nvl(comm_bonus.rec_amount_ptd,0),
	  recovery_amount_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.rec_amount_ptd, 0),
				       Nvl(recovery_amount_itd,0) -  Nvl(recovery_amount_ptd,0)
				       + Nvl(comm_bonus.rec_amount_ptd, 0)),

	  comm_pend_ptd = Nvl(comm_bonus.comm_pending_ptd, 0),
	  comm_pend_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.comm_pending_ptd, 0),
				 Nvl(comm_pend_itd,0) -  Nvl(comm_pend_ptd,0)
				 + Nvl(comm_bonus.comm_pending_ptd, 0)),

	  rollover = Decode(period_id, l_max_period_id, p_srp_pe_subledger.rollover, NULL),
	  LAST_UPDATE_DATE = sysdate,
	  LAST_UPDATED_BY = fnd_global.user_id,
	  LAST_UPDATE_LOGIN = fnd_global.login_id

	  WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
	  AND period_id = p_srp_pe_subledger.accu_period_id
	  AND quota_id = p_srp_pe_subledger.quota_id
	  AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id
	  returning srp_period_quota_id INTO l_srp_period_quota_id;

	FOR i IN 2 .. p_srp_pe_subledger.input_ptd.COUNT LOOP
	   UPDATE cn_srp_period_quotas_ext_all
	     SET input_achieved_ptd  = p_srp_pe_subledger.input_ptd(i) ,
	     input_achieved_itd  = p_srp_pe_subledger.input_itd(i) ,
	     last_update_date = Sysdate,
	     last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.login_id
	     WHERE srp_period_quota_id = l_srp_period_quota_id
	     AND input_sequence = i;
	END LOOP;

      ELSE

	-- Update only commission related columns

	UPDATE cn_srp_period_quotas_all
	  SET
	  transaction_amount_ptd = Nvl(comm_bonus.transaction_amount_ptd,0),
	  transaction_amount_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.transaction_amount_ptd, 0),
					Nvl(transaction_amount_itd,0) -  Nvl(transaction_amount_ptd ,0)
					+ Nvl(comm_bonus.transaction_amount_ptd, 0)),

	  commission_payed_ptd = Nvl(comm_bonus.comm_earned_ptd,0),
	  commission_payed_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.comm_earned_ptd, 0),
					Nvl(commission_payed_itd,0) -  Nvl(commission_payed_ptd ,0)
					+ Nvl(comm_bonus.comm_earned_ptd, 0)),

	  advance_recovered_ptd = Nvl(comm_bonus.adv_earned_ptd,0),
	  advance_recovered_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.adv_earned_ptd, 0),
					 Nvl(advance_recovered_itd,0) -  Nvl(advance_recovered_ptd,0)
					 + Nvl(comm_bonus.adv_earned_ptd, 0)),

	  advance_to_rec_ptd = Nvl(comm_bonus.adv_paid_ptd,0),
	  advance_to_rec_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.adv_paid_ptd, 0),
				      Nvl(advance_to_rec_itd,0) -  Nvl(advance_to_rec_ptd,0)
				      + Nvl(comm_bonus.adv_paid_ptd, 0)),

	  recovery_amount_ptd = Nvl(comm_bonus.rec_amount_ptd,0),
	  recovery_amount_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.rec_amount_ptd, 0),
				       Nvl(recovery_amount_itd,0) -  Nvl(recovery_amount_ptd,0)
				       + Nvl(comm_bonus.rec_amount_ptd, 0)),

	  comm_pend_ptd = Nvl(comm_bonus.comm_pending_ptd, 0),
	  comm_pend_itd = Decode(period_id, l_start_period_id, Nvl(comm_bonus.comm_pending_ptd, 0),
				 Nvl(comm_pend_itd,0) -  Nvl(comm_pend_ptd,0)
				 + Nvl(comm_bonus.comm_pending_ptd, 0)),

	  LAST_UPDATE_DATE = sysdate,
	  LAST_UPDATED_BY = fnd_global.user_id,
	  LAST_UPDATE_LOGIN = fnd_global.login_id

	  WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
	  AND period_id = p_srp_pe_subledger.accu_period_id
	  AND quota_id = p_srp_pe_subledger.quota_id
	  AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id;

     END IF;

     CLOSE comm_bonus_cr;

     -- update cn_srp_per_quota_rc for the current period
     OPEN quota_type_cr;
     FETCH quota_type_cr INTO quota_type;

     IF (quota_type_cr%notfound) THEN
	   -- quota_type is not FORMULA, should not call this procedure
	   NULL;
     ELSIF (quota_type.quota_type_code = 'EXTERNAL') THEN
       IF (quota_type.package_name IS NULL) THEN
         NULL;
       ELSE
         declare
           no_component EXCEPTION;
           PRAGMA EXCEPTION_INIT(no_component, -6550);
         begin
           l_sql_stmt := ' Begin ' || quota_type.package_name ||'.update_revclass_perf ( :salesrep_id, :period_id, :quota_id, :srp_plan_assign_id ); End; ';

	       execute immediate l_sql_stmt using p_srp_pe_subledger.salesrep_id,
	           p_srp_pe_subledger.accu_period_id, p_srp_pe_subledger.quota_id,
	           p_srp_pe_subledger.srp_plan_assign_id;
         exception

           when no_component then
	         FOR class IN revenue_classes LOOP
	           UPDATE cn_srp_per_quota_rc_all rc
		       SET period_to_date =
		             (SELECT nvl(sum(cl.perf_achieved), 0)
		              FROM cn_commission_lines_all cl,
		                   cn_quota_rules_all qr
		              WHERE cl.credited_Salesrep_id = p_srp_pe_subledger.salesrep_id
		              AND cl.quota_id = p_srp_pe_subledger.quota_id
		              AND cl.processed_period_id = p_srp_pe_subledger.accu_period_id
		              AND cl.status = 'CALC'
		              AND cl.trx_type NOT IN ( 'FORECAST', 'BONUS')
		              AND cl.quota_rule_id = qr.quota_rule_id
		              AND qr.revenue_class_id = class.revenue_class_id
		              AND qr.quota_id = p_srp_pe_subledger.quota_id
		              AND cl.srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id)
	           WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
		       AND period_id = p_srp_pe_subledger.accu_period_id
		       AND quota_id = p_srp_pe_subledger.quota_id
		       AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id
		       AND revenue_class_id = class.revenue_class_id;
             END LOOP;
           when others then
             NULL;
         end;
       END IF;
     ELSE
	   IF (quota_type.trx_group_code = 'GROUP') THEN
	     -- in case of group by case, there is no perf_achieved on each transaction
	     -- need to call the procedure in formula package using DSQL
	     l_sql_stmt := ' Begin cn_formula_'|| abs(quota_type.calc_formula_id) || '_' || abs(quota_type.org_id)
	             ||'_pkg.update_revclass_perf ( :salesrep_id, :period_id, :quota_id, '||
	             ':srp_plan_assign_id ); End; ';

	     execute immediate l_sql_stmt using p_srp_pe_subledger.salesrep_id,
	           p_srp_pe_subledger.accu_period_id, p_srp_pe_subledger.quota_id,
	           p_srp_pe_subledger.srp_plan_assign_id;

	   ELSE
	     -- sum transactions
	     FOR class IN revenue_classes LOOP
	       UPDATE cn_srp_per_quota_rc_all rc
		   SET period_to_date =
		         (SELECT nvl(sum(cl.perf_achieved), 0)
		          FROM cn_commission_lines_all cl,
		               cn_quota_rules_all qr
		          WHERE cl.credited_Salesrep_id = p_srp_pe_subledger.salesrep_id
		          AND cl.quota_id = p_srp_pe_subledger.quota_id
		          AND cl.processed_period_id = p_srp_pe_subledger.accu_period_id
		          AND cl.status = 'CALC'
		          AND cl.trx_type NOT IN ( 'FORECAST', 'BONUS')
		          AND cl.quota_rule_id = qr.quota_rule_id
		          AND qr.revenue_class_id = class.revenue_class_id
		          AND qr.quota_id = p_srp_pe_subledger.quota_id
		          AND cl.srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id)
	       WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
		   AND period_id = p_srp_pe_subledger.accu_period_id
		   AND quota_id = p_srp_pe_subledger.quota_id
		   AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id
		   AND revenue_class_id = class.revenue_class_id;
	     END LOOP;
	   END IF;
     END IF;

     CLOSE quota_type_cr;

     -- update cn_srp_period_quotas for the subsequence
     FOR period IN periods_cr LOOP

	IF (period.period_id = p_srp_pe_subledger.accu_period_id) THEN
	   -- in case of current period, get start ytd
	   l_transaction_amount_itd := period.transaction_amount_itd;
	   l_commission_payed_itd := period.commission_payed_itd;
	   l_input_achieved_itd := period.input_achieved_itd;
	   l_output_achieved_itd := period.output_achieved_itd;
	   l_perf_achieved_itd := period.perf_achieved_itd;
	   l_advance_recovered_itd := period.advance_recovered_itd;
	   l_advance_to_rec_itd := period.advance_to_rec_itd;
	   l_recovery_amount_itd := period.recovery_amount_itd;
	   l_comm_pend_itd := period.comm_pend_itd;

	   FOR period_ext IN periods_ext(period.srp_period_quota_id) LOOP
	      l_input_achieved_itd_tbl(period_ext.input_sequence) := period_ext.input_achieved_itd;
	   END LOOP;

	 ELSE
	   -- future period
	   l_transaction_amount_itd := l_transaction_amount_itd + period.transaction_amount_ptd;
	   l_commission_payed_itd := l_commission_payed_itd + period.commission_payed_ptd;
	   l_input_achieved_itd := l_input_achieved_itd + period.input_achieved_ptd;
	   l_output_achieved_itd := l_output_achieved_itd + period.output_achieved_ptd;
	   l_perf_achieved_itd := l_perf_achieved_itd + period.perf_achieved_ptd;
	   l_advance_recovered_itd := l_advance_recovered_itd + period.advance_recovered_ptd;
	   l_advance_to_rec_itd := l_advance_to_rec_itd + period.advance_to_rec_ptd;
	   l_recovery_amount_itd :=l_recovery_amount_itd + period.recovery_amount_ptd ;
	   l_comm_pend_itd := l_comm_pend_itd + period.comm_pend_ptd;

	   UPDATE cn_srp_period_quotas_all
	     SET
	     transaction_amount_itd = l_transaction_amount_itd,
	     commission_payed_itd = l_commission_payed_itd,
	     input_achieved_itd = l_input_achieved_itd,
	     output_achieved_itd = l_output_achieved_itd,
	     perf_achieved_itd = l_perf_achieved_itd,
	     advance_recovered_itd = l_advance_recovered_itd,
	     advance_to_rec_itd = l_advance_to_rec_itd,
	     recovery_amount_itd = l_recovery_amount_itd,
	     comm_pend_itd = l_comm_pend_itd,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATED_BY = fnd_global.user_id,
	     LAST_UPDATE_LOGIN = fnd_global.login_id
	     WHERE salesrep_id = p_srp_pe_subledger.salesrep_id
	     AND period_id = period.period_id
	     AND quota_id = p_srp_pe_subledger.quota_id
	     AND srp_plan_assign_id = p_srp_pe_subledger.srp_plan_assign_id;


	   FOR period_ext IN periods_ext(period.srp_period_quota_id) LOOP
	      l_input_achieved_itd_tbl(period_ext.input_sequence) := l_input_achieved_itd_tbl(period_ext.input_sequence) + period_ext.input_achieved_ptd;

	      UPDATE cn_srp_period_quotas_ext_all
		SET input_achieved_itd = l_input_achieved_itd_tbl(period_ext.input_sequence),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = fnd_global.user_id,
		LAST_UPDATE_LOGIN = fnd_global.login_id
		WHERE srp_period_quota_id = period.srp_period_quota_id
		AND input_sequence = period_ext.input_sequence;
	   END LOOP;
	END IF;
     END LOOP;

     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_subledger_pvt.update_srp_pe_subledger.end',
			    	'End of update_srp_pe_subledger ...');
     end if;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
     END IF;


     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       ( p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
     cn_message_pkg.debug('Finish updating calculation subledgers ');
  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_srp_pe_subledger;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	   );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_srp_pe_subledger;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN OTHERS THEN
	ROLLBACK TO update_srp_pe_subledger;
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
                         'cn.plsql.cn_calc_subledger_pvt.update_srp_pe_subledger.exception',
		       		     sqlerrm);
    end if;

    fnd_file.put_line(fnd_file.log, 'EXCEPTION in update_srp_pe_subledger: '||sqlerrm);

	cn_message_pkg.debug('Exception occurs in update_srp_pe_subledger: ');
	cn_message_pkg.debug(sqlerrm);

  END update_srp_pe_subledger;


  PROCEDURE post_je_batch
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_je_batch             IN je_batch_rec_type
      ) IS
  BEGIN
     NULL;
  END post_je_batch;

  PROCEDURE roll_quotas_forecast(p_salesrep_id NUMBER,
				 p_period_id   NUMBER,
				 p_quota_id    NUMBER,
				 p_srp_plan_assign_id NUMBER) IS

  BEGIN

     NULL;

  END roll_quotas_forecast;

END cn_calc_subledger_pvt;

/

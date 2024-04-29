--------------------------------------------------------
--  DDL for Package Body CN_CALC_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_ROLLUP_PVT" AS
-- $Header: cnvcrolb.pls 120.9.12010000.4 2009/09/15 20:54:41 rnagired ship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_CALC_ROLLUP_PVT';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvcrolb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

  G_ROWID                     VARCHAR2(30);
  G_PROGRAM_TYPE              VARCHAR2(30);
  g_system_rollup_flag        VARCHAR2(1);
  g_roll_sum_trx_flag         VARCHAR2(1);
  g_custom_aggr_trx_flag      VARCHAR2(1);
  g_srp_validation_flag       VARCHAR2(1);
  g_mark_event_flag           VARCHAR2(1);
  g_multi_rollup_profile      VARCHAR2(30);
  g_mode                      VARCHAR2(30);
  g_event_log_id              NUMBER(15);
  g_end_of_time               DATE := to_date('12-31-9999','MM-DD-YYYY');
  g_org_id                    NUMBER(15);

  user_aggregate_exception    EXCEPTION;

  type num_tbl_type is table of number index by binary_integer;
  type date_tbl_type is table of date index by binary_integer;
  type str_tbl_type is table of varchar2(30) index by binary_integer;

  CURSOR group_id(p_processed_date DATE, p_salesrep_id NUMBER) IS
     SELECT comp_group_id
       FROM cn_srp_comp_groups_v
       WHERE salesrep_id = p_salesrep_id
       AND org_id = g_org_id
       AND p_processed_date >= start_date_active
       AND (end_date_active IS NULL OR p_processed_date <= end_date_active)
	 AND ROWNUM = 1;

   CURSOR verify_group(p_processed_date DATE, p_salesrep_id NUMBER, p_comp_group_id NUMBER) is
     select comp_group_id
       from cn_srp_comp_groups_v
      where salesrep_id = p_salesrep_id
        and org_id = g_org_id
        and p_processed_date > start_date_active
        and (end_date_active is null or p_processed_date <= end_date_active)
        and comp_group_id = p_comp_group_id;

  -- 1. assume that the user wants to aggregate trxs within the date range specified in the calculation request
  -- 2. it is complete calculation
  -- 3. no trx skipping rollup phase
  PROCEDURE aggregate_trx(p_physical_batch_id IN NUMBER) IS
     g_intel_calc_flag VARCHAR2(1);
     rep_ids         num_tbl_type;
     header_ids      num_tbl_type;
     rollup_dates    date_tbl_type;
     group_ids       num_tbl_type;
     rev_class_ids   num_tbl_type;
     trx_types       str_tbl_type;
     amounts         num_tbl_type;
     units           num_tbl_type;
     processed_dates date_tbl_type;
     period_ids      num_tbl_type;

     l_start_date DATE;
     l_end_date DATE;
     l_start_period_id NUMBER;

     CURSOR intel_calc_flag IS
	SELECT nvl(intelligent_flag, 'N')
	  FROM cn_calc_submission_batches_all
	  WHERE logical_batch_id = (SELECT logical_batch_id
                                  FROM cn_process_batches_all
                                 WHERE physical_batch_id = p_physical_batch_id
                                   AND ROWNUM = 1);

     CURSOR sum_trxs IS
	SELECT ch.direct_salesrep_id,
               ch.processed_period_id,
               ch.processed_date,
               nvl(ch.rollup_date, ch.processed_date),
	       ch.comp_group_id,
	       ch.revenue_class_id,
	       ch.trx_type,
	       sum(ch.transaction_amount),
	       sum(ch.quantity)
	  FROM cn_commission_headers_all ch,
	       cn_process_batches_all pb
	 WHERE pb.physical_batch_id = p_physical_batch_id
	   AND ch.direct_salesrep_id = pb.salesrep_id
	   AND ch.processed_date BETWEEN pb.start_date AND pb.end_date
       AND ch.org_id = pb.org_id
	   AND ((g_intel_calc_flag = 'N' AND ch.status = 'CLS') OR (g_intel_calc_flag = 'Y' AND ch.status = 'CLS' AND ch.parent_header_id IS NULL))
     GROUP BY ch.direct_salesrep_id,
              ch.processed_period_id,
              ch.processed_date,
              nvl(ch.rollup_date, ch.processed_date),
	          ch.comp_group_id,
	          ch.revenue_class_id,
	          ch.trx_type;
  BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_rollup_pvt.aggregate_trx.begin',
			    	'Beginning of aggregate_trx ...');
   end if;

     OPEN intel_calc_flag;
     FETCH intel_calc_flag INTO g_intel_calc_flag;
     CLOSE intel_calc_flag;

     open sum_trxs;
     fetch sum_trxs bulk collect into rep_ids, period_ids, processed_dates,  rollup_dates, group_ids, rev_class_ids, trx_types, amounts, units;
     close sum_trxs;

     IF rep_ids.count > 0 THEN
     forall i in rep_ids.first..rep_ids.last
       insert into cn_commission_headers_all
       (commission_header_id,
	    direct_salesrep_id,
	    processed_date,
	    processed_period_id,
	    trx_type,
	    status,
	    rollup_date,
	    comp_group_id,
	    revenue_class_id,
	    transaction_amount,
	    quantity,
	    pre_processed_code,
	    parent_header_id,
	    creation_date,
	    created_by,
        org_id)
       values
       (cn_commission_headers_s.nextval,
	    rep_ids(i),
	    processed_dates(i),
	    period_ids(i),
	    trx_types(i),
	    'CLS_SUM',
	    rollup_dates(i),
	    group_ids(i),
	    rev_class_ids(i),
	    amounts(i),
	    units(i),
	    'CRPC',
	    -1,
	    sysdate,
	    g_created_by,
        g_org_id)
       returning commission_header_id bulk collect INTO header_ids;

     forall i IN rep_ids.first..rep_ids.last
       UPDATE cn_commission_headers_all
       SET parent_header_id = header_ids(i),
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
       WHERE direct_salesrep_id = rep_ids(i)
       AND processed_period_id= period_ids(i)
       AND processed_date = processed_dates(i)
       AND nvl(rollup_date, processed_date) = rollup_dates(i)
       AND nvl(comp_group_id, -999999) = nvl(group_ids(i), -999999)
       AND revenue_class_id = rev_class_ids(i)
       AND trx_type = trx_types(i)
       AND org_id = g_org_id
       AND ((g_intel_calc_flag = 'N' AND status = 'CLS') OR
            (g_intel_calc_flag = 'Y' AND status = 'CLS' AND parent_header_id IS NULL));
   END IF;

   COMMIT;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_rollup_pvt.aggregate_trx.end',
			    	'End of aggregate_trx.');
   end if;
  end aggregate_trx;

  -- beginning of private procedures
  PROCEDURE create_comm_line(p_commission_header_id    NUMBER,
			     p_salesrep_id             NUMBER,
			     p_credited_comp_group_id  NUMBER,
			     p_processed_date          DATE,
			     p_processed_period_id     NUMBER,
				 p_rollup_level            NUMBER) IS
     l_srp_trx           cn_srp_validation_pub.srp_trx_rec_type;
     l_validation_status VARCHAR2(1);
     l_pending_status    VARCHAR2(1);
     l_return_status     VARCHAR2(30);
     l_msg_count         NUMBER;
     l_msg_data          VARCHAR2(2000);
  BEGIN
     -- call marketer validation first if profile set to Yes
     IF (g_srp_validation_flag = 'Y') THEN
	   l_srp_trx.salesrep_id := p_salesrep_id;
	   l_srp_trx.commission_header_id := p_commission_header_id;

	   cn_srp_validation_pub.validate_trx
	    (p_api_version       => 1.0,
	     x_return_status     => l_return_status,
	     x_msg_count         => l_msg_count,
	     x_msg_data          => l_msg_data,
	     p_srp_trx           => l_srp_trx,
	     x_validation_status => l_validation_status);
     ELSE
	   l_return_status     := FND_API.g_ret_sts_success;
	   l_validation_status := 'Y';
     END IF;

     l_pending_status := 'Y';

     IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	   IF (l_validation_status = 'Y') THEN
	     l_pending_status := 'N';
	   END IF;
     ELSE
	   NULL;
     END IF;

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
	rollup_level,
    org_id)
       (SELECT cn_commission_lines_s.NEXTVAL,
	commission_header_id,
	direct_salesrep_id,
	pre_processed_code,
	revenue_class_id,
	p_salesrep_id,
	p_credited_comp_group_id,
	l_pending_status,
	Decode(l_pending_status, 'Y', Sysdate, NULL),
	'ROLL',
	'ROLL',
	processed_date,
	processed_period_id,
	trx_type,
	g_created_by,
	g_creation_date,
	p_rollup_level,
    org_id
	FROM cn_commission_headers_all
	WHERE commission_header_id = p_commission_header_id
	AND (NOT exists (SELECT 1
			 FROM cn_commission_lines_all
			 WHERE commission_header_id = p_commission_header_id
			 AND credited_salesrep_id = p_salesrep_id)));


     IF (SQL%found) THEN
       IF (g_mark_event_flag = 'Y') THEN
	     cn_mark_events_pkg.mark_notify
	      (p_salesrep_id     => p_salesrep_id,
	       p_period_id       => p_processed_period_id,
	       p_start_date      => p_processed_date,
	       p_end_date        => p_processed_date,
	       p_quota_id        => NULL,
	       p_revert_to_state => 'CALC',
	       p_event_log_id    => g_event_log_id,
           p_org_id          => g_org_id);
        END IF;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
  	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_calc_rollup_pvt.create_comm_line.exception',
			      	     'Failed to create commission line: '||p_commission_header_id);
      end if;

     cn_message_pkg.debug('Exception occurs in creating commission lines: ');
	 cn_message_pkg.debug(sqlerrm );
     fnd_file.put_line(fnd_file.log, sqlerrm);
     RAISE;
  END create_comm_line;

  PROCEDURE xroll (p_salesrep_id    NUMBER,
		   p_comp_group_id  NUMBER,
		   p_start_date     DATE,
		   p_end_date       DATE) IS

     l_group         cn_rollup_pvt.group_rec_type;
     l_group_member  cn_rollup_pvt.group_mem_tbl_type;

     l_return_status VARCHAR2(30);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);

  BEGIN
     IF p_salesrep_id IS NOT NULL THEN

	-- This is for event: add a group member role
	UPDATE cn_commission_headers_all
	  SET status = decode(parent_header_id, -1, 'CLS_SUM', 'CLS'),
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
	  WHERE direct_salesrep_id = p_salesrep_id
      AND org_id = g_org_id
	  AND status <> 'OBSOLETE'
	  AND (nvl(rollup_date, processed_date) BETWEEN p_start_date AND p_end_date
	       OR processed_date BETWEEN p_start_date AND p_end_date);

      ELSE

	-- This is for event: add group usage
	-- have to call API first to get all the active group member

	l_group.group_id := p_comp_group_id;
	l_group.start_date := p_start_date;
	l_group.end_date   := p_end_date;

	cn_rollup_pvt.get_active_group_member
	  (p_api_version       => 1.0,
	   x_return_status     => l_return_status,
	   x_msg_count         => l_msg_count,
	   x_msg_data          => l_msg_data,
	   p_group             => l_group,
	   x_group_mem         => l_group_member,
       p_org_id            => g_org_id);

	IF l_group_member.COUNT > 0 THEN
	   FOR eachsrp IN l_group_member.first .. l_group_member.last LOOP
	      UPDATE cn_commission_headers_all
		SET status = decode(parent_header_id, -1, 'CLS_SUM', 'CLS'),
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
		WHERE direct_salesrep_id = l_group_member(eachsrp).salesrep_id
        AND org_id = g_org_id
		AND (nvl(rollup_date, processed_date) BETWEEN l_group_member(eachsrp).start_date AND l_group_member(eachsrp).end_date OR
		     processed_date BETWEEN l_group_member(eachsrp).start_date AND l_group_member(eachsrp).end_date)
 		AND status <> 'OBSOLETE';

	   END LOOP; --end of eachsrp loop

	END IF; -- end of echecking l_group_member.count > 0

     END IF; -- end of checking salesrep_id is not null
 EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.xroll.exception',
		       		      sqlerrm);
      end if;
      cn_message_pkg.debug('Exception occurs in cn_calc_rollup_pvt.xroll:');
	  cn_message_pkg.debug(sqlerrm );
      fnd_file.put_line(fnd_file.log, 'In cn_calc_rollup_pvt.xroll: '||sqlerrm);
      RAISE;
  END xroll;

  PROCEDURE source_cls (p_salesrep_id    NUMBER,
			p_comp_group_id  NUMBER,
			p_start_date     DATE,
			p_end_date       DATE)
    IS
       CURSOR revert_lines(p_salesrep_id NUMBER, p_processed_date DATE, p_rollup_date DATE) IS
	  SELECT commission_line_id
	    FROM cn_commission_lines_all line
	    WHERE line.posting_status = 'POSTED'
          AND line.status = 'CALC'
	      AND line.commission_header_id IN (SELECT header.commission_header_id
						FROM cn_commission_headers_all header
						WHERE header.direct_salesrep_id = p_salesrep_id
						AND header.processed_date = p_processed_date
                        AND header.org_id = g_org_id
						AND Nvl(header.parent_header_id, -1) = -1
						AND Nvl(header.rollup_date, header.processed_date) = Nvl(p_rollup_date, p_processed_date));
     CURSOR l_transaction_date IS
	SELECT DISTINCT processed_date, rollup_date, processed_period_id
	  FROM cn_commission_headers_all
	  WHERE direct_salesrep_id = p_salesrep_id
      AND org_id = g_org_id
	  -- AND comp_group_id = p_comp_group_id
	  AND (nvl(rollup_date, processed_date) BETWEEN p_start_date AND p_end_date OR
           processed_date BETWEEN p_start_date AND p_end_date)
 	  AND status <> 'OBSOLETE'
	  GROUP BY processed_date, rollup_date, processed_period_id;

     l_srp             cn_rollup_pvt.srp_rec_type;
     l_active_group    cn_rollup_pvt.active_group_tbl_type;

     l_return_status VARCHAR2(30);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
     l_status VARCHAR2(30);


  BEGIN

     FOR eachdate IN l_transaction_date LOOP

	l_srp.salesrep_id := p_salesrep_id;
	l_srp.start_date  := eachdate.processed_date;
	l_srp.end_date    := eachdate.processed_date;
	l_status := null;

	cn_rollup_pvt.get_active_group
	  ( p_api_version       => 1.0,
	    x_return_status     => l_return_status,
	    x_msg_count         => l_msg_count,
	    x_msg_data          => l_msg_data,
        p_org_id            => g_org_id,
	    p_srp               => l_srp,
	    x_active_group      => l_active_group);

	IF (l_active_group.COUNT = 0 AND eachdate.rollup_date <> eachdate.processed_date) THEN
	   l_srp.start_date := eachdate.rollup_date;
	   l_srp.end_date := eachdate.rollup_date;

	   cn_rollup_pvt.get_active_group
	     ( p_api_version       => 1.0,
	       x_return_status     => l_return_status,
	       x_msg_count         => l_msg_count,
	       x_msg_data          => l_msg_data,
           p_org_id            => g_org_id,
	       p_srp               => l_srp,
	       x_active_group      => l_active_group);
	END IF;

	 -- if the current active group is not the same as the group specified in the notify log
	 	IF ((l_active_group.COUNT = 0) OR (l_active_group.COUNT > 0 and l_active_group(0).group_id <> p_comp_group_id)) THEN

	   -- no active role for this group memeber
	   -- need to remove all rolled up transaction
	  -- and set the source transactio status to 'XROLL'

      if (l_active_group.count = 0) then
        l_status := 'XROLL';
      end if;

	   UPDATE cn_commission_headers_all
	     SET status = nvl(l_status, decode(parent_header_id, -1, 'CLS_SUM', 'CLS')),
	         comp_group_id = NULL,
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
	     WHERE direct_salesrep_id = p_salesrep_id
         AND org_id = g_org_id
 	     AND status <> 'OBSOLETE'
	     AND processed_date = eachdate.processed_date
	     AND Nvl(parent_header_id, -1) = -1
	     AND Nvl(rollup_date, processed_date) = Nvl(eachdate.rollup_date, eachdate.processed_date);

	   UPDATE cn_srp_intel_periods_all
	     SET process_all_flag = 'Y'
	     WHERE period_id = eachdate.processed_period_id
         AND org_id = g_org_id
	     AND salesrep_id IN (SELECT DISTINCT line.credited_salesrep_id
				 FROM cn_commission_lines_all line,
				 cn_commission_headers_all header
				 WHERE line.commission_header_id = header.commission_header_id
				 AND header.direct_salesrep_id = p_salesrep_id
				 AND header.processed_date = eachdate.processed_date
                 AND header.org_id = g_org_id
				 AND Nvl(header.parent_header_id, -1) = -1
				 AND Nvl(header.rollup_date, header.processed_date) = Nvl(eachdate.rollup_date, eachdate.processed_date)
				 );

	   FOR line IN revert_lines(p_salesrep_id, eachdate.processed_date, eachdate.rollup_date) LOOP
	      cn_formula_common_pkg.revert_posting_line(line.commission_line_id);
	   END LOOP;

	   DELETE FROM cn_commission_lines_all line
	     WHERE line.commission_header_id IN (SELECT header.commission_header_id
						 FROM cn_commission_headers_all header
						 WHERE header.direct_salesrep_id = p_salesrep_id
                         AND header.org_id = g_org_id
						 AND header.processed_date = eachdate.processed_date
						 AND Nvl(header.parent_header_id, -1) = -1
						 AND Nvl(header.rollup_date, header.processed_date) = Nvl(eachdate.rollup_date, eachdate.processed_date)
						 );
	END IF;
     END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.source_cls.exception',
		       		      sqlerrm);
      end if;
      cn_message_pkg.debug('Exception occurs in cn_calc_rollup_pvt.source_cls:');
	  cn_message_pkg.debug(sqlerrm );
	  fnd_file.put_line(fnd_file.log, 'In cn_calc_rollup_pvt.source_cls: '||sqlerrm);
      RAISE;
  END source_cls;

 PROCEDURE pull ( p_salesrep_id     NUMBER,
		  p_comp_group_id   NUMBER,
		  p_start_date      DATE,
		  p_end_date        DATE,
		  p_action          VARCHAR2) IS

      l_group                cn_rollup_pvt.group_rec_type;
      l_group_tbl            cn_rollup_pvt.group_tbl_type;
      l_group_member         cn_rollup_pvt.group_mem_tbl_type;

      l_srp                  cn_rollup_pvt.srp_rec_type;
      l_active_group         cn_rollup_pvt.active_group_tbl_type;
      l_srp_group            cn_rollup_pvt.srp_group_rec_type;
      l_srp_group_tbl        cn_rollup_pvt.srp_group_tbl_type;

      l_return_status        VARCHAR2(1);
      l_msg_count            NUMBER(15);
      l_msg_data             VARCHAR2(1000);

      l_comp_group_id        NUMBER;
      l_temp_counter         NUMBER;

      CURSOR l_transactions_cr(p_salesrep_id   NUMBER,
 			      p_comp_group_id NUMBER,
 			      p_start_date    DATE,
 			      p_end_date      DATE) IS

 	SELECT commission_header_id, processed_date, processed_period_id
 	  FROM cn_commission_headers_all
 	  WHERE direct_salesrep_id = p_salesrep_id
      AND org_id = g_org_id
 	  -- AND comp_group_id = p_comp_group_id
 	  AND g_system_rollup_flag = 'Y'
 	  AND trx_type NOT IN ('FORECAST', 'GRP','BONUS')
 	  AND substrb(pre_processed_code, 2,1) = 'R'
 	  AND status = 'ROLL'
 	  AND Nvl(rollup_date, processed_date) BETWEEN p_start_date AND p_end_date;

  	CURSOR role_mgr_flag_c (x_salesrep_id   NUMBER,
				   x_comp_group_id NUMBER,
				   x_start_date    DATE,
				   x_end_date      DATE) IS
		select manager_flag
		from cn_srp_comp_groups_v
		where salesrep_id = x_salesrep_id
        and org_id = g_org_id
		and comp_group_id = x_comp_group_id
		and start_date_active <= x_start_date
		and nvl(end_date_active,x_end_date) >= x_end_date;

      l_mgr_role_flag cn_srp_comp_groups_v.manager_flag%TYPE;

   BEGIN
      l_group.group_id := p_comp_group_id;
      l_group.start_date    := p_start_date;
      l_group.end_date      := p_end_date;

      OPEN role_mgr_flag_c (p_salesrep_id, p_comp_group_id, p_start_date, p_end_date);
	  FETCH role_mgr_flag_c INTO l_mgr_role_flag;
	  CLOSE role_mgr_flag_c;

      IF p_action = 'PULL_WITHIN' and l_mgr_role_flag = 'Y' THEN
 	    cn_rollup_pvt.get_active_group_member
 	   (p_api_version       => 1.0,
 	    x_return_status     => l_return_status,
 	    x_msg_count         => l_msg_count,
 	    x_msg_data          => l_msg_data,
        p_org_id            => g_org_id,
 	    p_group             => l_group,
 	    x_group_mem         => l_group_member);

 	    -- added the sales rep so that new recs in lines are created, if required
	    IF l_group_member.COUNT > 0 THEN
	     l_temp_counter := l_group_member.last + 1;
	    ELSE
	     l_temp_counter := 0;
	    END IF;

	    l_group_member(l_temp_counter).salesrep_id := p_salesrep_id;
	    l_group_member(l_temp_counter).start_date := p_start_date;
	    l_group_member(l_temp_counter).end_date := p_end_date;

 	IF l_group_member.COUNT > 0 THEN
      FOR i IN l_group_member.first..l_group_member.last LOOP
        FOR eachtrx IN l_transactions_cr(l_group_member(i).salesrep_id,
 						  p_comp_group_id,
 						  l_group_member(i).start_date,
 						  l_group_member(i).end_date)
 		   LOOP
 		      l_comp_group_id := NULL;
 		      IF (eachtrx.processed_date > l_group_member(i).end_date) THEN
 			 OPEN group_id(eachtrx.processed_date, l_group_member(i).salesrep_id);
 			 FETCH group_id INTO l_comp_group_id;
 			 CLOSE group_id;
 		       ELSE
 			 l_comp_group_id := p_comp_group_id;
 		      END IF;

 		      IF (l_comp_group_id IS NOT NULL) THEN
 			 create_comm_line(eachtrx.commission_header_id,
 					  p_salesrep_id,
 					  l_comp_group_id,
 					  eachtrx.processed_date,
 					  eachtrx.processed_period_id,
					  0);
 		      END IF;
 		 END LOOP; -- end of eachtrx
 	   END LOOP; -- end of eachsrp
 	END IF; -- end of count check
    END IF; -- end of action check

      IF p_action in ('PULL', 'PULL_BELOW') THEN
 	-- get all descendants before p_end_date starting from any possible comp group
 	-- for each descendant, get his trxs with processed_date >= p_start_date and rollup_date <= end_date
 	-- if p_salesrep_id is not compensated for the trx (from the previous step), compensate him on this trx

 	l_srp.salesrep_id := p_salesrep_id;
 	l_srp.start_date := p_start_date - 3650;
 	l_srp.end_date := p_end_date;

 	cn_rollup_pvt.get_active_group
 	  ( p_api_version       => 1.0,
 	    x_return_status     => l_return_status,
 	    x_msg_count         => l_msg_count,
 	    x_msg_data          => l_msg_data,
        p_org_id            => g_org_id,
 	    p_srp               => l_srp,
 	    x_active_group      => l_active_group);

 	IF (l_active_group.COUNT > 0) THEN
 	   FOR k IN l_active_group.first..l_active_group.last LOOP
 	      l_srp_group.salesrep_id := p_salesrep_id;
 	      l_srp_group.group_id := l_active_group(k).group_id;
 	      l_srp_group.start_date := l_active_group(k).start_date;
 	      l_srp_group.end_date := l_active_group(k).end_date;

 	      cn_rollup_pvt.get_descendant_salesrep
 		(p_api_version       => 1.0,
 		 x_return_status     => l_return_status,
 		 x_msg_count         => l_msg_count,
 		 x_msg_data          => l_msg_data,
         p_org_id            => g_org_id,
 		 p_srp               => l_srp_group,
 		 x_srp               => l_srp_group_tbl);

 		 --added the sales rep so that new recs in lines are created, if required
		 IF l_srp_group_tbl.COUNT > 0 THEN
		  l_temp_counter := l_srp_group_tbl.last + 1;
		 ELSE
		  l_temp_counter := 0;
		 END IF;

		 l_srp_group_tbl(l_temp_counter).salesrep_id := p_salesrep_id;
		 l_srp_group_tbl(l_temp_counter).group_id := l_active_group(k).group_id;
		 l_srp_group_tbl(l_temp_counter).start_date := l_active_group(k).start_date;
 	     l_srp_group_tbl(l_temp_counter).end_date := l_active_group(k).end_date;
 	     l_srp_group_tbl(l_temp_counter).level := 0;

 	      IF l_srp_group_tbl.COUNT > 0 THEN
 		 FOR i IN l_srp_group_tbl.first..l_srp_group_tbl.last LOOP
 		       FOR eachtrx IN l_transactions_cr(l_srp_group_tbl(i).salesrep_id,
 							 l_srp_group_tbl(i).group_id,
 							 l_srp_group_tbl(i).start_date,
 							 l_srp_group_tbl(i).end_date)
 			 LOOP
 			    l_comp_group_id := NULL;
			    OPEN group_id(eachtrx.processed_date, p_salesrep_id);
			    FETCH group_id INTO l_comp_group_id;
			    CLOSE group_id;

 			    IF (l_comp_group_id IS NOT NULL) THEN
 			       create_comm_line(eachtrx.commission_header_id,
 						p_salesrep_id,
 						l_comp_group_id,
 						eachtrx.processed_date,
 						eachtrx.processed_period_id,
						l_srp_group_tbl(i).level);
 			    END IF;

 			 END LOOP;-- end of eachtrx
 		 END LOOP; -- end of eachsrp
 	      END IF; -- end of count check
 	   END LOOP; -- end active group loop
 	END IF; -- end check of the number of active groups
      END IF; -- end of action check
 EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.pull.exception',
		       		      sqlerrm);
      end if;
      cn_message_pkg.debug('Exception occurs in cn_calc_rollup_pvt.pull:');
	  cn_message_pkg.debug(sqlerrm);
	  fnd_file.put_line(fnd_file.log, 'In cn_calc_rollup_pvt.pull: '||sqlerrm);
      RAISE;
  END pull;

  PROCEDURE roll_pull ( p_comp_group_id        NUMBER,
			p_start_date           DATE,
			p_end_date             DATE,
			p_action               VARCHAR2,
			p_action_link_id       NUMBER) IS

         l_group                cn_rollup_pvt.group_rec_type;
         l_descendants_grp      cn_rollup_pvt.group_tbl_type;
         l_ancestors_grp        cn_rollup_pvt.group_tbl_type;
         l_ancestors_tbl        cn_rollup_pvt.srp_group_tbl_type;
         l_descendants_tbl      cn_rollup_pvt.srp_group_tbl_type;

         l_return_status        VARCHAR2(1);
         l_msg_count            NUMBER(15);
         l_msg_data             VARCHAR2(1000);

         l_start_date           DATE;
         l_end_date             DATE;

         l_date_range_tbl       cn_api.date_range_tbl_type;

         l_comp_group_id        NUMBER;

         i                      pls_integer := 0;
         l_dummy                NUMBER;

         l_rollup_level         pls_integer;

         CURSOR revert_lines(p_salesrep_id NUMBER, p_commission_header_id NUMBER) IS
    	SELECT commission_line_id
    	  FROM cn_commission_lines_all
    	  WHERE credited_salesrep_id = p_salesrep_id
          AND org_id = g_org_id
          and status = 'CALC'
    	  and posting_status = 'POSTED'
    	  AND commission_header_id = p_commission_header_id;

         CURSOR ex_ancestors IS
    	SELECT salesrep_id, comp_group_id group_id, MIN(start_date) start_date, MAX(end_date) end_date
    	  FROM cn_notify_log_all
    	  WHERE action_link_id = p_action_link_id
          AND org_id = g_org_id
    	  AND notify_log_id > p_action_link_id
    	  GROUP BY salesrep_id, comp_group_id;

         CURSOR path_check(p_rollup_date DATE, p_parent_salesrep_id NUMBER, p_child_salesrep_id NUMBER) IS
    	SELECT 1
         FROM cn_srp_comp_groups_v a1
         WHERE p_rollup_date BETWEEN start_date_active AND Nvl(end_date_active,
               p_rollup_date)
         AND salesrep_id = p_parent_salesrep_id
         AND org_id = g_org_id
         and exists (SELECT 1 FROM cn_groups_denorm_v
                      WHERE parent_group_id = a1.comp_group_id
                        and group_id in (SELECT comp_group_id FROM
                                         cn_srp_comp_groups_v
                                         WHERE p_rollup_date BETWEEN start_date_active AND
                                            Nvl(end_date_active, p_rollup_date)
                                         AND salesrep_id = p_child_salesrep_id
                                         AND org_id = g_org_id)
                                        AND p_rollup_date BETWEEN start_date_active AND
                                            Nvl(end_date_active, p_rollup_date));

       cursor rollup_level(p_parent_group_id number,
	                       p_child_group_id number,
						   p_rollup_date date) is
         select denorm_level
		   from cn_groups_denorm_v
		  where parent_group_id = p_parent_group_id
		    and group_id = p_child_group_id
			and p_rollup_date between start_date_active and nvl(end_date_active, p_rollup_date);

         CURSOR l_transactions_cr(l_salesrep_id   NUMBER,
    			      l_comp_group_id NUMBER,
    			      l_start_date    DATE,
    			      l_end_date      DATE) IS
    	SELECT commission_header_id,
		       processed_date,
			   processed_period_id,
			   Nvl(rollup_date, processed_date) rollup_date
    	  FROM cn_commission_headers_all
    	  WHERE direct_salesrep_id = l_salesrep_id
          AND org_id = g_org_id
    	  AND comp_group_id = l_comp_group_id
    	  AND g_system_rollup_flag = 'Y'
    	  AND trx_type NOT IN ('FORECAST', 'GRP','BONUS')
    	  AND substrb(pre_processed_code, 2,1) = 'R'
    	  AND status = 'ROLL'
    	  AND Nvl(rollup_date, processed_date) BETWEEN l_start_date AND l_end_date;

      BEGIN

         -- Get ancestors
         FOR ancestor IN ex_ancestors LOOP
    	l_ancestors_tbl(i).salesrep_id := ancestor.salesrep_id;
    	l_ancestors_tbl(i).group_id    := ancestor.group_id;
    	l_ancestors_tbl(i).start_date  := ancestor.start_date;
    	l_ancestors_tbl(i).end_date    := ancestor.end_date;
    	i := i+1;
         END LOOP;

         l_group.group_id := p_comp_group_id;
         l_group.start_date    := p_start_date;
         l_group.end_date      := p_end_date;
         l_group.level         := 0;

         IF (l_ancestors_tbl.COUNT = 0) THEN
    	    RETURN;
         END IF;

         -- Get descendants
         cn_rollup_pvt.get_descendant_group
           ( p_api_version     => 1.0,
    	 x_return_status   => l_return_status,
    	 x_msg_count       => l_msg_count,
    	 x_msg_data        => l_msg_data,
    	 p_group           => l_group,
    	 x_group           => l_descendants_grp);

         l_descendants_grp(l_descendants_grp.COUNT) := l_group;

         cn_rollup_pvt.get_active_group_member
           ( p_api_version     => 1.0,
    	 x_return_status   => l_return_status,
    	 x_msg_count       => l_msg_count,
    	 x_msg_data        => l_msg_data,
         p_org_id          => g_org_id,
    	 p_group           => l_descendants_grp,
    	 x_group_mem       => l_descendants_tbl);

         IF (l_descendants_tbl.COUNT > 0) THEN
    	FOR l_ancestor IN l_ancestors_tbl.first .. l_ancestors_tbl.last LOOP
    	   FOR l_descendant IN l_descendants_tbl.first .. l_descendants_tbl.last LOOP

    	      -- Get the date range which are overlapping
    	      cn_api.get_date_range_overlap
    		(a_start_date => l_ancestors_tbl(l_ancestor).start_date,
    		 a_end_date   => l_ancestors_tbl(l_ancestor).end_date,
    		 b_start_date => l_descendants_tbl(l_descendant).start_date,
    		 b_end_date   => l_descendants_tbl(l_descendant).end_date,
                 p_org_id     => g_org_id,
    		 x_date_range_tbl => l_date_range_tbl);

    	      IF (l_date_range_tbl.COUNT > 0) THEN
    		 FOR eachrange IN l_date_range_tbl.first .. l_date_range_tbl.last LOOP
    		    l_start_date := l_date_range_tbl(eachrange).start_date;
    		    l_end_date   := l_date_range_tbl(eachrange).end_date;

    		    FOR eachtrx IN l_transactions_cr(l_descendants_tbl(l_descendant).salesrep_id,
    						     l_descendants_tbl(l_descendant).group_id,
    						     l_start_date,
    						     l_end_date)
    		      LOOP
    			 IF (p_action = 'ROLL_PULL') THEN
    			    l_comp_group_id := NULL;
    			    IF (eachtrx.processed_date > l_end_date) THEN
    			       OPEN group_id(eachtrx.processed_date, l_ancestors_tbl(l_ancestor).salesrep_id);
    			       FETCH group_id INTO l_comp_group_id;
    			       CLOSE group_id;
    			     ELSE
    			       l_comp_group_id := l_ancestors_tbl(l_ancestor).group_id;
    			    END IF;

    			    IF (l_comp_group_id IS NOT NULL) THEN
    			    -- get the rollup level between direct_rep and credited_rep
    			    l_rollup_level := 0;

    			    open rollup_level(l_ancestors_tbl(l_ancestor).group_id,
    			                      l_descendants_tbl(l_descendant).group_id,
    			                      eachtrx.rollup_date);
    		        fetch rollup_level into l_rollup_level;
    		        close rollup_level;

    			       create_comm_line
    				 ( p_commission_header_id   => eachtrx.commission_header_id,
    				   p_salesrep_id            => l_ancestors_tbl(l_ancestor).salesrep_id,
    				   p_credited_comp_group_id => l_comp_group_id,
    				   p_processed_date         => eachtrx.processed_date,
    				   p_processed_period_id    => eachtrx.processed_period_id,
					   p_rollup_level           => l_rollup_level);
    			    END IF;
    			  ELSE
    			    -- check whether there is other rollup path for this trx to be rolled up
    			    l_dummy := 0;

    			    OPEN path_check(eachtrx.rollup_date, l_ancestors_tbl(l_ancestor).salesrep_id, l_descendants_tbl(l_descendant).salesrep_id);
    			    FETCH path_check INTO l_dummy;
    			    CLOSE path_check;

    			    IF (l_dummy <> 1) THEN
    			       FOR line IN revert_lines(l_ancestors_tbl(l_ancestor).salesrep_id, eachtrx.commission_header_id) LOOP
    				  cn_formula_common_pkg.revert_posting_line(line.commission_line_id);
    			       END LOOP;

    			       DELETE FROM cn_commission_lines_all
    				 WHERE credited_salesrep_id = l_ancestors_tbl(l_ancestor).salesrep_id
    				 AND commission_header_id = eachtrx.commission_header_id;

    			       IF (SQL%found) THEN
    				  UPDATE cn_srp_intel_periods_all
                         SET process_all_flag = 'Y'
    				    WHERE salesrep_id = l_ancestors_tbl(l_ancestor).salesrep_id
                        AND org_id = g_org_id
    				    AND period_id = eachtrx.processed_period_id;
    			       END IF;
    			    END IF;
    			 END IF;
    		      END LOOP; -- End of eachtrx
    		 END LOOP; -- End of eachrange
    	      END IF;
    	   END LOOP; -- End of l_descendant

    	END LOOP; -- End of l_ancestor
      END IF;
 EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.roll_pull.exception',
		       		      sqlerrm);
      end if;
      cn_message_pkg.debug('Exception occurs in cn_calc_rollup_pvt.roll_pull:');
	  cn_message_pkg.debug(sqlerrm);
	  fnd_file.put_line(fnd_file.log, 'In cn_calc_rollup_pvt.roll_pull: '||sqlerrm);
      RAISE;
  END roll_pull;

  PROCEDURE rollup_new_trx (p_salesrep_id NUMBER,
			    p_start_date  DATE,
			    p_end_date    DATE) IS

     l_role_id   NUMBER(15);

     l_current_salesrep_id    NUMBER(15) := 0;
     l_current_comp_group_id  NUMBER(15) := 0;
     l_current_rollup_date    DATE;
     l_current_processed_date DATE;
     l_prev_commission_header_id NUMBER;
     l_prev_comp_group_id     NUMBER;
     l_prev_status            VARCHAR2(30);

     l_return_status          VARCHAR2(30);
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(2000);

     l_count                  NUMBER(15);

     l_srp                    cn_rollup_pvt.srp_rec_type;
     l_active_group           cn_rollup_pvt.active_group_tbl_type;

     l_mgr_comp_group_id      NUMBER(15);

     l_srp_group              cn_rollup_pvt.srp_group_rec_type;
     l_srp_group_ancestor     cn_rollup_pvt.srp_group_tbl_type;
     l_comp_group_id          NUMBER(15);
     l_iteration_count          pls_integer;

     CURSOR l_no_rollup_transactions_cr IS
	SELECT ch.commission_header_id commission_header_id,
	  ch.direct_salesrep_id direct_salesrep_id,
	  ch.comp_group_id,
	  Nvl(ch.rollup_date, ch.processed_date) rollup_date,
	  ch.processed_date processed_date,
	  ch.processed_period_id
	  FROM cn_commission_headers_all ch
	  WHERE ch.direct_salesrep_id = p_salesrep_id
      AND ch.org_id = g_org_id
	  AND ch.processed_date BETWEEN p_start_date AND p_end_date
	  AND ch.trx_type NOT IN ('FORECAST', 'GRP','BONUS')
	  AND ((g_roll_sum_trx_flag = 'N' AND ch.status = 'CLS') OR (g_roll_sum_trx_flag = 'Y' AND ch.status = 'CLS_SUM'))
	  AND ((substrb(ch.pre_processed_code, 2,1) = 'N')
	       OR (g_system_rollup_flag = 'N'));

     CURSOR l_rollup_transactions_cr IS
	SELECT ch.commission_header_id commission_header_id,
	  ch.direct_salesrep_id direct_salesrep_id,
	  ch.comp_group_id comp_group_id,
	  Nvl(ch.rollup_date, ch.processed_date) rollup_date,
	  ch.processed_date processed_date,
	  ch.processed_period_id,
	  ch.trx_type,
	  ch.revenue_class_id,
	  ch.pre_processed_code
	  FROM cn_commission_headers_all ch
	  WHERE  ch.direct_salesrep_id = p_salesrep_id
      AND ch.org_id = g_org_id
	  AND ch.processed_date BETWEEN p_start_date AND p_end_date
	  AND ch.trx_type NOT IN ('FORECAST', 'GRP','BONUS')
	  AND ((g_roll_sum_trx_flag = 'N' AND ch.status = 'CLS') OR (g_roll_sum_trx_flag = 'Y' AND ch.status = 'CLS_SUM'))
	  AND substrb(ch.pre_processed_code, 2,1) = 'R'
	  AND g_system_rollup_flag = 'Y'
	  ORDER BY ch.direct_salesrep_id,
	           ch.comp_group_id,
	           Nvl(ch.rollup_date,ch.processed_date),
	           ch.processed_date;

      CURSOR rollup_lines(p_commission_header_id NUMBER) IS
	 SELECT distinct credited_salesrep_id, credited_comp_group_id, rollup_level
	   FROM cn_commission_lines_all
	   WHERE commission_header_id = p_commission_header_id;

  BEGIN
     -- Processing no rollup transaction
     FOR eachtrx IN l_no_rollup_transactions_cr LOOP

	 IF eachtrx.comp_group_id IS NULL THEN
	   l_srp.salesrep_id := eachtrx.direct_salesrep_id;
	   l_srp.start_date  := eachtrx.processed_date;
	   l_srp.end_date    := eachtrx.processed_date;

	   cn_rollup_pvt.get_active_group
	     (p_api_version       => 1.0,
	      x_return_status     => l_return_status,
	      x_msg_count         => l_msg_count,
	      x_msg_data          => l_msg_data,
          p_org_id            => g_org_id,
	      p_srp               => l_srp,
	      x_active_group      => l_active_group);

 	   IF (l_active_group.COUNT = 1 or (l_active_group.COUNT > 1 AND g_multi_rollup_profile = 'Y')) THEN
	      create_comm_line
		(p_commission_header_id   => eachtrx.commission_header_id,
		 p_salesrep_id            => eachtrx.direct_salesrep_id,
		 p_credited_comp_group_id => l_active_group(l_active_group.first).group_id,
		 p_processed_date         => eachtrx.processed_date,
		 p_processed_period_id    => eachtrx.processed_period_id,
		 p_rollup_level           => 0);

	      l_comp_group_id := l_active_group(l_active_group.first).group_id;
	      UPDATE cn_commission_headers_all
		SET status = 'ROLL',
		    comp_group_id = l_comp_group_id,
            last_update_date = G_LAST_UPDATE_DATE,
            last_updated_by = G_LAST_UPDATED_BY,
            last_update_login = G_LAST_UPDATE_LOGIN
	      WHERE commission_header_id = eachtrx.commission_header_id;
	   ELSE
	      -- No group information is available on transaction.
	      -- Change the status to 'XROLL'

	      UPDATE cn_commission_headers_all
		SET status = 'XROLL',
                    last_update_date = G_LAST_UPDATE_DATE,
                    last_updated_by = G_LAST_UPDATED_BY,
                    last_update_login = G_LAST_UPDATE_LOGIN
	      WHERE commission_header_id = eachtrx.commission_header_id;
	   END IF; -- end of active_group = 1
	 ELSE
	   -- comp group info is given, create
	   -- create transaction for the direct salesrep

       -- verify the given comp group
       l_comp_group_id := null;
       open verify_group(eachtrx.processed_date, eachtrx.direct_salesrep_id, eachtrx.comp_group_id);
       fetch verify_group into l_comp_group_id;
       close verify_group;

 	   l_srp.salesrep_id := eachtrx.direct_salesrep_id;
 	   l_srp.start_date  := eachtrx.processed_date;
 	   l_srp.end_date    := eachtrx.processed_date;

 	   cn_rollup_pvt.get_active_group
 	     (p_api_version       => 1.0,
 	      x_return_status     => l_return_status,
 	      x_msg_count         => l_msg_count,
 	      x_msg_data          => l_msg_data,
          p_org_id            => g_org_id,
 	      p_srp               => l_srp,
 	      x_active_group      => l_active_group);

           if (l_comp_group_id is null and l_active_group.COUNT >= 1) then
             l_comp_group_id := l_active_group(l_active_group.first).group_id;
           end if;

           if (l_comp_group_id is not null and
               (l_active_group.COUNT = 1 or (l_active_group.COUNT > 1 and g_multi_rollup_profile = 'Y'))) then
   	     create_comm_line
 	       ( p_commission_header_id   => eachtrx.commission_header_id,
 	         p_salesrep_id            => eachtrx.direct_salesrep_id,
 	         p_credited_comp_group_id => l_comp_group_id,
 	         p_processed_date         => eachtrx.processed_date,
 	         p_processed_period_id    => eachtrx.processed_period_id,
			 p_rollup_level           => 0);

             UPDATE cn_commission_headers_all
                SET status = 'ROLL',
                    comp_group_id = l_comp_group_id,
                    last_update_date = G_LAST_UPDATE_DATE,
                    last_updated_by = G_LAST_UPDATED_BY,
                    last_update_login = G_LAST_UPDATE_LOGIN
              WHERE commission_header_id = eachtrx.commission_header_id;
           else
             update cn_commission_headers_all
                set status = 'XROLL',
                    last_update_date = G_LAST_UPDATE_DATE,
                    last_updated_by = G_LAST_UPDATED_BY,
                    last_update_login = G_LAST_UPDATE_LOGIN
              where commission_header_id = eachtrx.commission_header_id;
           end if;
	END IF; -- End of eechtrx.comp_group_id
     END LOOP; -- End of eachtrx

     FOR eachtrx IN l_rollup_transactions_cr LOOP

	IF (eachtrx.direct_salesrep_id = l_current_salesrep_id AND
	    (eachtrx.comp_group_id IS NULL OR g_multi_rollup_profile = 'Y') AND
	    nvl(eachtrx.rollup_date, eachtrx.processed_date) = l_current_rollup_date AND
	    eachtrx.processed_date = l_current_processed_date) THEN

	   UPDATE cn_commission_headers_all
	     SET status = l_prev_status,
	         comp_group_id = decode(l_prev_status, 'ROLL', l_prev_comp_group_id, NULL),
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
	     WHERE commission_header_id = eachtrx.commission_header_id;

	   -- copy the records created for the previous header trx.
	   FOR roll_line IN rollup_lines(l_prev_commission_header_id) LOOP
	      create_comm_line
 		( p_commission_header_id   => eachtrx.commission_header_id,
 		  p_salesrep_id            => roll_line.credited_salesrep_id,
 		  p_credited_comp_group_id => roll_line.credited_comp_group_id,
 		  p_processed_date         => eachtrx.processed_date,
 		  p_processed_period_id    => eachtrx.processed_period_id,
		  p_rollup_level           => roll_line.rollup_level);
	   END LOOP;

	   GOTO end_of_loop;
	END IF;

	-- need to be initialized when these are declared
	l_srp.salesrep_id       := eachtrx.direct_salesrep_id;
	l_srp.start_date        := eachtrx.processed_date;
	l_srp.end_date          := eachtrx.processed_date;

	l_active_group.DELETE;

	IF (eachtrx.comp_group_id IS NULL OR g_multi_rollup_profile = 'Y') THEN
	   cn_rollup_pvt.get_active_group
	     (p_api_version       => 1.0,
	      x_return_status     => l_return_status,
	      x_msg_count         => l_msg_count,
	      x_msg_data          => l_msg_data,
          p_org_id            => g_org_id,
	      p_srp               => l_srp,
	      x_active_group      => l_active_group);

	   IF (l_active_group.COUNT = 0 AND eachtrx.processed_date <> eachtrx.rollup_date) THEN
	      l_srp.start_date := eachtrx.rollup_date;
	      l_srp.end_date := eachtrx.rollup_date;

	      cn_rollup_pvt.get_active_group
		(p_api_version       => 1.0,
		 x_return_status     => l_return_status,
		 x_msg_count         => l_msg_count,
		 x_msg_data          => l_msg_data,
         p_org_id            => g_org_id,
		 p_srp               => l_srp,
		 x_active_group      => l_active_group);
	   END IF;
	END IF;

	IF (l_active_group.COUNT = 0 AND (eachtrx.comp_group_id IS NULL OR g_multi_rollup_profile = 'Y')) THEN
	   UPDATE cn_commission_headers_all
	     SET status = 'XROLL',
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
	     WHERE commission_header_id = eachtrx.commission_header_id;

	   l_prev_status := 'XROLL';
	 ELSE
	   l_count := l_active_group.first;
	   l_iteration_count := 1;
	   LOOP
	      IF (eachtrx.comp_group_id IS NOT NULL AND g_multi_rollup_profile <> 'Y') THEN
                 l_comp_group_id := null;
                 open verify_group(eachtrx.processed_date, eachtrx.direct_salesrep_id, eachtrx.comp_group_id);
                 fetch verify_group into l_comp_group_id;
                 close verify_group;

                 if (l_comp_group_id is null) then
                   open group_id(eachtrx.processed_date, eachtrx.direct_salesrep_id);
                   fetch group_id into l_comp_group_id;
                   close group_id;
                 end if;

                 if (l_comp_group_id is null) then
                   update cn_commission_headers_all
                      set status = 'XROLL',
                          last_update_date = G_LAST_UPDATE_DATE,
                          last_updated_by = G_LAST_UPDATED_BY,
                          last_update_login = G_LAST_UPDATE_LOGIN
                    where commission_header_id = eachtrx.commission_header_id;

                   l_prev_status := 'XROLL';
                   exit;
                 end if;
	       ELSE
		 l_comp_group_id := l_active_group(l_count).group_id;
		 IF (g_multi_rollup_profile = 'Y') THEN
		    NULL;
		  ELSE
		    IF (l_active_group.COUNT > 1) THEN
		       UPDATE cn_commission_headers_all
			 SET status = 'XROLL',
                             last_update_date = G_LAST_UPDATE_DATE,
                             last_updated_by = G_LAST_UPDATED_BY,
                             last_update_login = G_LAST_UPDATE_LOGIN
			 WHERE commission_header_id = eachtrx.commission_header_id;

		       l_prev_status := 'XROLL';
		       IF (l_iteration_count = 2) THEN
			  DELETE FROM cn_commission_lines_all WHERE commission_header_id = eachtrx.commission_header_id;
		       END IF;

		       EXIT;
		    END IF;
		 END IF;
	      END IF;

	      -- refresh l_active_group if rollup_date <> processed_date and comp_group_id is not specified
	      IF (l_iteration_count = 1 AND
		  eachtrx.rollup_date <> l_srp.start_date
		  AND (eachtrx.comp_group_id IS NULL OR g_multi_rollup_profile = 'Y')) THEN
		 l_srp.salesrep_id       := eachtrx.direct_salesrep_id;
		 l_srp.start_date        := eachtrx.rollup_date;
		 l_srp.end_date          := eachtrx.rollup_date;

		 l_active_group.DELETE;
		 cn_rollup_pvt.get_active_group
		   (p_api_version       => 1.0,
		    x_return_status     => l_return_status,
		    x_msg_count         => l_msg_count,
		    x_msg_data          => l_msg_data,
            p_org_id            => g_org_id,
		    p_srp               => l_srp,
		    x_active_group      => l_active_group);

		 l_iteration_count := 0;
	      END IF;

	      IF (l_iteration_count > 0 AND ((l_current_salesrep_id   <> eachtrx.direct_salesrep_id) OR
		(l_current_comp_group_id <> l_comp_group_id) OR
		(l_current_rollup_date   <> eachtrx.rollup_date))) THEN
		 -- Need to call rollup API again
		 l_current_salesrep_id    := eachtrx.direct_salesrep_id;
		 l_current_comp_group_id  := l_comp_group_id;
		 l_current_rollup_date    := eachtrx.rollup_date;
		 l_current_processed_date := eachtrx.processed_date;
		 l_prev_commission_header_id := eachtrx.commission_header_id;

		 l_srp_group_ancestor.DELETE;

		 l_srp_group.salesrep_id := eachtrx.direct_salesrep_id;
		 l_srp_group.group_id    := l_comp_group_id;
		 l_srp_group.start_date  := eachtrx.rollup_date;
		 l_srp_group.end_date    := eachtrx.rollup_date;

		 cn_rollup_pvt.get_ancestor_salesrep
		   (p_api_version       => 1.0,
		    x_return_status     => l_return_status,
		    x_msg_count         => l_msg_count,
		    x_msg_data          => l_msg_data,
            p_org_id            => g_org_id,
		    p_srp               => l_srp_group,
		    x_srp               => l_srp_group_ancestor);

		 IF l_return_status <> FND_API.g_ret_sts_success THEN
		    UPDATE cn_commission_headers_all
		      SET status = 'XROLL',
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
		      WHERE commission_header_id = eachtrx.commission_header_id;

		    DELETE FROM cn_commission_lines_all
		      WHERE commission_header_id = eachtrx.commission_header_id;

		    l_prev_status := 'XROLL';

		    RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
		 END IF; -- end of check api return status
	      END IF; -- end of check of whether to call API again

	      IF (l_iteration_count < 2) THEN
		 UPDATE cn_commission_headers_all
		   SET status = 'ROLL',
		   comp_group_id = l_comp_group_id,
           last_update_date = G_LAST_UPDATE_DATE,
           last_updated_by = G_LAST_UPDATED_BY,
           last_update_login = G_LAST_UPDATE_LOGIN
		   WHERE commission_header_id = eachtrx.commission_header_id;

		 l_prev_comp_group_id := l_comp_group_id;
		 l_prev_status := 'ROLL';
	      END IF;

	      -- create transaction for base rep first
	      create_comm_line
		( p_commission_header_id   => eachtrx.commission_header_id,
		  p_salesrep_id            => eachtrx.direct_salesrep_id,
		  p_credited_comp_group_id => l_comp_group_id,
		  p_processed_date         => eachtrx.processed_date,
		  p_processed_period_id    => eachtrx.processed_period_id,
		  p_rollup_level           => 0);

	      -- create transactions for each manager
	      BEGIN
		 IF (l_iteration_count > 0 AND l_srp_group_ancestor.COUNT > 0 ) THEN
		    FOR eachsrp IN l_srp_group_ancestor.first .. l_srp_group_ancestor.last LOOP
		       -- get the comp group active on the processed_date for each manager
		       IF (eachtrx.processed_date <> eachtrx.rollup_date) THEN
			  l_mgr_comp_group_id := NULL;
			  OPEN group_id(eachtrx.processed_date, l_srp_group_ancestor(eachsrp).salesrep_id);
			  FETCH group_id INTO l_mgr_comp_group_id;
			  CLOSE group_id;

			  IF (l_mgr_comp_group_id IS NOT NULL) THEN
			     create_comm_line
			       ( p_commission_header_id   => eachtrx.commission_header_id,
				 p_salesrep_id            => l_srp_group_ancestor(eachsrp).salesrep_id,
				 p_credited_comp_group_id => l_mgr_comp_group_id,
				 p_processed_date         => eachtrx.processed_date,
				 p_processed_period_id    => eachtrx.processed_period_id,
				 p_rollup_level           => l_srp_group_ancestor(eachsrp).level);
			  END IF;
			ELSE
			  create_comm_line
			    ( p_commission_header_id   => eachtrx.commission_header_id,
			      p_salesrep_id            => l_srp_group_ancestor(eachsrp).salesrep_id,
			      p_credited_comp_group_id => l_srp_group_ancestor(eachsrp).group_id,
			      p_processed_date         => eachtrx.processed_date,
			      p_processed_period_id    => eachtrx.processed_period_id,
				  p_rollup_level           => l_srp_group_ancestor(eachsrp).level);
		       END IF;
		    END LOOP; -- End of eachsrp
		 END IF;

	      EXCEPTION
		 WHEN OTHERS THEN
	        if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.rollup_new_trx.exception',
		       		      sqlerrm);
            end if;
            cn_message_pkg.debug('Exception occurs in creating commission lines for managers:');
		    cn_message_pkg.debug(sqlerrm );
		    fnd_file.put_line(fnd_file.log, 'In rollup_new_trx creating transaction for managers: '||sqlerrm);
		    RAISE;
	      END ;

	      IF (l_iteration_count > 0) THEN
		 IF ((eachtrx.comp_group_id IS NOT NULL AND g_multi_rollup_profile <> 'Y') OR l_count = l_active_group.last) THEN
		    EXIT;
		  ELSE
		    l_count := l_active_group.next(l_count);
		 END IF;

		 l_iteration_count := 2;
	       ELSE
		 l_iteration_count := 2;
		 -- if there is no group active on rollup_date, then exit
		 IF (l_active_group.COUNT = 0) THEN
		    EXIT;
		 END IF;
	      END IF;
	   END LOOP;
	END IF;
	<<end_of_loop>>
	  NULL;
     END LOOP; -- End of each trx
 EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.rollup_new_trx.exception',
		       		      sqlerrm);
      end if;
	  cn_message_pkg.debug('Exception occurs in cn_calc_rollup_pvt.rollup_new_trx:');
	  cn_message_pkg.debug(sqlerrm);
      fnd_file.put_line(fnd_file.log, 'In cn_calc_rollup_pvt.rollup_new_trx: '||sqlerrm);
      RAISE;
  END rollup_new_trx;

  PROCEDURE revalidation (p_physical_batch_id NUMBER) IS

     l_srp_trx       cn_srp_validation_pub.srp_trx_rec_type;

     l_return_status VARCHAR2(30);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);

     l_validation_status VARCHAR2(1);
     l_pending_status    VARCHAR2(1);

     CURSOR l_transactions_cr IS

	SELECT cl.commission_header_id commission_header_id,
	       cl.commission_line_id commission_line_id,
	       cl.credited_salesrep_id credited_salesrep_id
	  FROM cn_commission_lines_all cl,
	  cn_process_batches_all pb
	  WHERE pb.physical_batch_id = p_physical_batch_id
	  AND pb.salesrep_id = cl.credited_salesrep_id
      AND cl.org_id = g_org_id
	  AND cl.processed_period_id between pb.period_id AND pb.end_period_id
	  AND cl.processed_date BETWEEN pb.start_date AND pb.end_date
	  AND cl.trx_type NOT IN ('FORECAST', 'GRP','BONUS')
	  AND cl.status IN ('ROLL', 'POP', 'XPOP', 'CALC', 'XCALC')
	  AND cl.pending_status = 'Y';

  BEGIN

     FOR eachtrx IN l_transactions_cr LOOP

	l_srp_trx.salesrep_id          := eachtrx.credited_salesrep_id;
	l_srp_trx.commission_header_id := eachtrx.commission_header_id;

	cn_srp_validation_pub.validate_trx
	  (p_api_version       => 1.0,
	   x_return_status     => l_return_status,
	   x_msg_count         => l_msg_count,
	   x_msg_data          => l_msg_data,
	   p_srp_trx           => l_srp_trx,
	   x_validation_status => l_validation_status);

	l_pending_status := 'Y';

	IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	   IF (l_validation_status = 'Y') THEN

	      l_pending_status := 'N';

      UPDATE cn_commission_lines_all
		SET pending_status = 'N'
		WHERE commission_line_id = eachtrx.commission_line_id;

	   END IF;

	END IF;

     END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
	  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.revaliation.exception',
		       		      sqlerrm);
      end if;

	  cn_message_pkg.debug('Exception occurs in cn_calc_rollup_pvt.revaliation: ');
	  cn_message_pkg.debug(sqlerrm );
      fnd_file.put_line(fnd_file.log, 'In cn_calc_rollup_pvt.revalidation: '||sqlerrm);
      RAISE;
  END revalidation;

--+=========================================================================+
--+ End of private procedures                                               +
--+=========================================================================+

  -- API name 	: rollup_batch
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

  PROCEDURE rollup_batch
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_physical_batch_id     IN  NUMBER,
      p_mode                  IN  VARCHAR2 := 'NORMAL',
      p_event_log_id          IN  NUMBER   := NULL

      ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Rollup_batch';
     l_api_version    CONSTANT NUMBER :=1.0;
     l_pay_period_id NUMBER(15);
     l_log_batch_id  NUMBER ;
     l_is_incremental VARCHAR2(30) ;

     CURSOR l_notify_cr IS
	  	select * from (
	  	SELECT event.salesrep_id, event.comp_group_id, event.start_date,
	      Nvl(event.end_date, g_end_of_time) end_date , event.action, event.notify_log_id
	  	FROM cn_notify_log_all event
	  	WHERE event.physical_batch_id = p_physical_batch_id
	  	AND event.action IN ('SOURCE_CLS', 'XROLL', 'ROLL_PULL', 'DELETE_ROLL_PULL')
	  	AND event.status = 'INCOMPLETE'
	  	UNION
	  	SELECT event.salesrep_id, event.comp_group_id, event.start_date,
	  	Nvl(event.end_date, g_end_of_time) end_date, event.action, event.notify_log_id
	  	FROM cn_notify_log_all event, cn_process_batches_all batch
	  	WHERE batch.physical_batch_id = p_physical_batch_id
	  	AND batch.salesrep_id = event.salesrep_id
        AND event.org_id = g_org_id
	  	AND event.period_id between batch.period_id and batch.end_period_id
	  	AND event.action IN  ('PULL', 'PULL_WITHIN', 'PULL_BELOW')
	  	AND event.status = 'INCOMPLETE' ) cur
 	ORDER BY cur.notify_log_id;

     CURSOR l_roll_new_trx_cr IS

	SELECT salesrep_id,
	  start_date,
	  end_date
	  FROM cn_process_batches_all
	  WHERE physical_batch_id = p_physical_batch_id
	  ORDER BY process_batch_id;

  BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	rollup_batch;

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
     select org_id into g_org_id
       from cn_process_batches_all
      where physical_batch_id = p_physical_batch_id
	    and rownum = 1;

     g_mark_event_flag := nvl(fnd_profile.value('CN_MARK_EVENTS'), 'N');
     g_srp_validation_flag := Nvl(fnd_profile.value('CN_SRP_VALIDATION'), 'N');
     g_roll_sum_trx_flag   := nvl(cn_system_parameters.value('CN_ROLL_SUM_TRX', g_org_id), 'N');
     g_custom_aggr_trx_flag := nvl(cn_system_parameters.value('CN_CUSTOM_AGGR_TRX', g_org_id), 'N');

     g_multi_rollup_profile := nvl(fnd_profile.value('CN_MULTI_ROLLUP_PATH'), 'N');
     if (upper(g_multi_rollup_profile) = 'YES') then
       g_multi_rollup_profile := 'Y';
     end if;

     g_mode                := p_mode;
     g_event_log_id        := p_event_log_id;

     SELECT Nvl(srp_rollup_flag, 'N')
       INTO g_system_rollup_flag
       FROM cn_repositories_all
      WHERE org_id = g_org_id;

	  IF p_mode = 'NORMAL' THEN

         SELECT cb.logical_batch_id,
                cb.intelligent_flag
          INTO l_log_batch_id,
               l_is_incremental
          FROM cn_calc_submission_batches_all cb,
               cn_process_batches_all         pb
         WHERE cb.logical_batch_id = pb.logical_batch_id
           AND pb.physical_batch_id = p_physical_batch_id
           AND pb.org_id = cb.org_id
           AND rownum = 1;

          IF l_is_incremental = 'Y' THEN

          		FOR event IN l_notify_cr LOOP
          		   -- Perform the update after completing calculation
          		   -- UPDATE cn_notify_log SET status = 'COMPLETE' WHERE notify_log_id = event.notify_log_id;

          	       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      'cn.plsql.cn_calc_rollup_pvt.rollup_batch.notify_log',
                     		            'Processing notify log record ID='||event.notify_log_id);
                     end if;

                     cn_message_pkg.debug('Processing notify log record (log ID='||event.notify_log_id||')');


          		   IF event.action = 'SOURCE_CLS' THEN
          			 source_cls(p_salesrep_id  => event.salesrep_id,
          					  p_comp_group_id  => event.comp_group_id,
          					  p_start_date     => event.start_date,
          					  p_end_date       => Nvl(event.end_date, g_end_of_time));
          		   ELSIF event.action = 'XROLL' THEN
          			xroll(p_salesrep_id      => event.salesrep_id,
          					p_comp_group_id  => event.comp_group_id,
          					p_start_date     => event.start_date,
          					p_end_date       => Nvl(event.end_date, g_end_of_time));
          		   ELSIF event.action IN ('ROLL_PULL', 'DELETE_ROLL_PULL') THEN
          			 roll_pull(p_comp_group_id           => event.comp_group_id,
          					p_start_date     => event.start_date,
          					p_end_date       => Nvl(event.end_date, g_end_of_time),
          					p_action         => event.action,
          					p_action_link_id => event.notify_log_id);
          		   ELSIF event.action IN ('PULL', 'PULL_WITHIN', 'PULL_BELOW') THEN
          			 pull(p_salesrep_id   => event.salesrep_id,
          				 p_comp_group_id  => event.comp_group_id,
          				 p_start_date     => event.start_date,
          				 p_end_date       => Nvl(event.end_date, g_end_of_time),
          				 p_action         => event.action);
          		   END IF;
          		END LOOP;

          ELSE
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_file.put_line(fnd_file.log, 'Full Calc: Skipped the notify log pull calls.');
            END IF ;
            cn_message_pkg.debug('Full Calc: Skipped the notify log pull calls.');
          END IF ;

      END IF;

     commit;

     IF (g_roll_sum_trx_flag = 'Y') THEN
      IF (g_custom_aggr_trx_flag = 'Y') THEN
       BEGIN
         cn_aggrt_trx_pkg.aggregate_trx(p_physical_batch_id);
       EXCEPTION
        WHEN OTHERS THEN
		 if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                          'cn.plsql.cn_calc_rollup_pvt.rollup_batch.exception',
		       		      'Error in Custom Code: '||sqlerrm);
         end if;

         fnd_file.put_line(fnd_file.log, sqlerrm);
         fnd_file.put_line(fnd_file.log, ' Error in Custom Code -  cn_aggrt_trx_pkg.aggregate_trx()');
         RAISE user_aggregate_exception;
       END;
      ELSE
	   aggregate_trx(p_physical_batch_id);
      END IF;
    END IF;

     commit;

     FOR eachsrp IN l_roll_new_trx_cr LOOP
	   rollup_new_trx(p_salesrep_id  => eachsrp.salesrep_id,
		       p_start_date   => eachsrp.start_date,
		       p_end_date     => eachsrp.end_date);

	   commit;
     END LOOP;

     IF (g_srp_validation_flag = 'Y') THEN
	   revalidation(p_physical_batch_id);
     END IF;


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

  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO rollup_batch;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO rollup_batch;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN OTHERS THEN
	ROLLBACK TO rollup_batch;
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
                          'cn.plsql.cn_calc_rollup_pvt.rollup_batch.exception',
		       		      sqlerrm);
      end if;

	  fnd_file.put_line(fnd_file.log, sqlerrm);
  END rollup_batch;

END cn_calc_rollup_pvt;

/

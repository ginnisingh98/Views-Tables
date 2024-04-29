--------------------------------------------------------
--  DDL for Package Body CN_AGGRT_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_AGGRT_TRX_PKG" AS
-- $Header: cnagtrxb.pls 120.1 2005/10/13 10:39:01 ymao noship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_AGGRT_TRX_PKG';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnagtrxb.pls';

  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

  G_ROWID                     VARCHAR2(30);
  G_PROGRAM_TYPE              VARCHAR2(30);
  g_system_rollup_flag        VARCHAR2(1);
  g_roll_sum_trx_flag         VARCHAR2(1);
  g_srp_validation_flag       VARCHAR2(1);
  g_mode                      VARCHAR2(30);
  g_event_log_id              NUMBER(15);

  type num_tbl_type is table of number index by binary_integer;
  type date_tbl_type is table of date index by binary_integer;
  type str_tbl_type is table of varchar2(30) index by binary_integer;


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
     l_org_id NUMBER;

     CURSOR intel_calc_flag IS
	SELECT nvl(intelligent_flag, 'N'), org_id
	  FROM cn_calc_submission_batches_all
	  WHERE logical_batch_id = (SELECT logical_batch_id
	                              FROM cn_process_batches_all
								 WHERE physical_batch_id = p_physical_batch_id AND ROWNUM = 1);

     cursor sum_trxs is
	select ch.direct_salesrep_id,
	  ch.processed_period_id,
	  ch.processed_date,
	  nvl(ch.rollup_date, ch.processed_date),
	  ch.comp_group_id,
	  ch.revenue_class_id,
	  ch.trx_type,
	  sum(ch.transaction_amount),
	  sum(ch.quantity)
	  from cn_commission_headers_all ch,
	  cn_process_batches_all pb
	  WHERE pb.physical_batch_id = p_physical_batch_id
	  AND ch.direct_salesrep_id = pb.salesrep_id
	  AND ch.org_id = pb.org_id
	  AND ch.processed_date BETWEEN pb.start_date AND pb.end_date
	  AND ((g_intel_calc_flag = 'N' AND ch.status = 'CLS') OR (g_intel_calc_flag = 'Y' AND ch.status = 'CLS' AND ch.parent_header_id IS NULL))
	  group by ch.direct_salesrep_id,
	  ch.processed_period_id,
	  ch.processed_date,
	  nvl(ch.rollup_date, ch.processed_date),
	  ch.comp_group_id,
	  ch.revenue_class_id,
	  ch.trx_type;
  BEGIN
     OPEN intel_calc_flag;
     FETCH intel_calc_flag INTO g_intel_calc_flag, l_org_id;
     CLOSE intel_calc_flag;

     g_intel_calc_flag := nvl(g_intel_calc_flag, 'Y');

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
	l_org_id)
    returning commission_header_id bulk collect INTO header_ids;

     forall i IN rep_ids.first..rep_ids.last
       UPDATE cn_commission_headers_all
       SET parent_header_id = header_ids(i),
        -- clku, update the last updated info
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
       AND ((g_intel_calc_flag = 'N' AND status = 'CLS') OR (g_intel_calc_flag = 'Y' AND status = 'CLS' AND parent_header_id IS NULL))
	   AND org_id = l_org_id;
    END IF;
  end;

END CN_AGGRT_TRX_PKG;

/

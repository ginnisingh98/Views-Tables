--------------------------------------------------------
--  DDL for Package Body CN_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PURGE_PKG" AS
-- $Header: cnpurgeb.pls 115.6 2002/11/21 21:06:50 hlchen ship $

/*

Package Body Name
   cn_purge_pkg
Purpose

History
--------  ------------- -------------------------------------------------------+
04/16/96  Xinyang Fan     Created
04/26/00  Vijay Pendyala  Updated
  Changes as 11.5.1 schema has been changed
12/03/01  ymao            bug 2129772
*/


PROCEDURE purge(errbuf OUT NOCOPY VARCHAR2,
		retcode OUT NOCOPY NUMBER,
		x_start_period  IN varchar2,
		x_end_period    IN varchar2,
		x_salesrep_id   IN number)
  IS
     l_start_period_id number(15);
     l_end_period_id number(15);
     l_start_date DATE;
     l_end_date DATE;
BEGIN
   SELECT period_id, start_date
     INTO l_start_period_id, l_start_date
     FROM cn_periods
    WHERE period_name like x_start_period;

   SELECT period_id, end_date
     INTO l_end_period_id, l_end_date
     FROM cn_periods
     WHERE period_name like x_end_period;

   -- Delete process batches from CN_PROCESS_BATCHES with status_code = 'VOID'
   DELETE FROM CN_PROCESS_BATCHES WHERE status_code = 'VOID';

   -- Delete process audit lines from CN_PROCESS_AUDIT_LINES and CN_PROCESS_AUDITS
   -- Commented out as this process is taking a very long time for deleting as
   -- there can be lot of records in these tables as part of auditing.
   --DELETE FROM CN_PROCESS_AUDITS;
   --DELETE FROM CN_PROCESS_AUDIT_LINES;

   IF (x_salesrep_id IS NOT NULL) THEN
      -- Delete transactions from CN_COMMISSION_HEADERS
      DELETE FROM CN_COMMISSION_HEADERS
	WHERE  direct_salesrep_id = x_salesrep_id
	AND    processed_date between l_start_date and l_end_date;
      COMMIT;

      -- Delete transactions from CN_COMMISSION_LINES
      DELETE FROM CN_COMMISSION_LINES
	WHERE credited_salesrep_id = x_salesrep_id
	AND processed_period_id between l_start_period_id and l_end_period_id;
      COMMIT;

      -- Update CN_SRP_PERIODS
      UPDATE  cn_srp_periods SET
	balance1_dtd = 0,
	balance1_ctd = 0,
	balance1_bbd = 0,
	balance1_bbc = 0,
	balance2_dtd = 0,
	balance2_ctd = 0,
	balance2_bbd = 0,
	balance2_bbc = 0,
	balance3_dtd = 0,
	balance3_ctd = 0,
	balance3_bbd = 0,
	balance3_bbc = 0,
	balance4_dtd = 0,
	balance4_ctd = 0,
	balance4_bbd = 0,
	balance4_bbc = 0,
	balance5_dtd = 0,
	balance5_ctd = 0,
	balance5_bbd = 0,
	balance5_bbc = 0,
	balance6_dtd = 0,
	balance6_ctd = 0,
	balance6_bbd = 0,
	balance6_bbc = 0,
	balance7_dtd = 0,
	balance7_ctd = 0,
	balance7_bbd = 0,
	balance7_bbc = 0,
	balance8_dtd = 0,
	balance8_ctd = 0,
	balance8_bbd = 0,
	balance8_bbc = 0,
	balance9_dtd = 0,
	balance9_ctd = 0,
	balance9_bbd = 0,
	balance9_bbc = 0,
	balance10_dtd = 0,
	balance10_ctd = 0,
	balance10_bbd = 0,
	balance10_bbc = 0,
	balance11_dtd = 0,
	balance11_ctd = 0,
	balance11_bbd = 0,
	balance11_bbc = 0,
	balance12_dtd = 0,
	balance12_ctd = 0,
	balance12_bbd = 0,
	balance12_bbc = 0,
	balance13_dtd = 0,
	balance13_ctd = 0,
	balance13_bbd = 0,
	balance13_bbc = 0,
	balance14_dtd = 0,
	balance14_ctd = 0,
	balance14_bbd = 0,
	balance14_bbc = 0,
	balance15_dtd = 0,
	balance15_ctd = 0,
	balance15_bbd = 0,
	balance15_bbc = 0,
	balance16_dtd = 0,
	balance16_ctd = 0,
	balance16_bbd = 0,
	balance16_bbc = 0,
	balance17_dtd = 0,
	balance17_ctd = 0,
	balance17_bbd = 0,
	balance17_bbc = 0,
	balance18_dtd = 0,
	balance18_ctd = 0,
	balance18_bbd = 0,
	balance18_bbc = 0,
	balance19_dtd = 0,
	balance19_ctd = 0,
	balance19_bbd = 0,
	balance19_bbc = 0,
	balance20_dtd = 0,
	balance20_ctd = 0,
	balance20_bbd = 0,
	balance20_bbc = 0,
	balance21_dtd = 0,
	balance21_ctd = 0,
	balance21_bbd = 0,
	balance21_bbc = 0,
	balance22_dtd = 0,
	balance22_ctd = 0,
	balance22_bbd = 0,
	balance22_bbc = 0,
	balance23_dtd = 0,
	balance23_ctd = 0,
	balance23_bbd = 0,
	balance23_bbc = 0,
	balance24_dtd = 0,
	balance24_ctd = 0,
	balance24_bbd = 0,
	balance24_bbc = 0,
	balance25_dtd = 0,
	balance25_ctd = 0,
	balance25_bbd = 0,
	balance25_bbc = 0,
	balance26_dtd = 0,
	balance26_ctd = 0,
	balance26_bbd = 0,
	balance26_bbc = 0,
	balance27_dtd = 0,
	balance27_ctd = 0,
	balance27_bbd = 0,
	balance27_bbc = 0,
	balance28_dtd = 0,
	balance28_ctd = 0,
	balance28_bbd = 0,
	balance28_bbc = 0,
	balance29_dtd = 0,
	balance29_ctd = 0,
	balance29_bbd = 0,
	balance29_bbc = 0,
	balance30_dtd = 0,
	balance30_ctd = 0,
	balance30_bbd = 0,
	balance30_bbc = 0,
	balance31_dtd = 0,
	balance31_ctd = 0,
	balance31_bbd = 0,
	balance31_bbc = 0,
	balance32_dtd = 0,
	balance32_ctd = 0,
	balance32_bbd = 0,
	balance32_bbc = 0,
	balance33_dtd = 0,
	balance33_ctd = 0,
	balance33_bbd = 0,
	balance33_bbc = 0
        WHERE  salesrep_id = x_salesrep_id
	AND period_id between l_start_period_id and l_end_period_id;
      COMMIT;

       -- Update CN_SRP_PERIOD_QUOTAS
      UPDATE cn_srp_period_quotas SET
	commission_payed_itd = (commission_payed_itd - nvl(commission_payed_ptd,0)),
	commission_payed_ptd = 0,
	perf_achieved_itd = (perf_achieved_itd - nvl(perf_achieved_ptd,0)),
	perf_achieved_ptd = 0,
	advance_recovered_itd = (advance_recovered_itd - nvl(advance_recovered_ptd,0)),
	advance_recovered_ptd = 0,
	advance_to_rec_itd = (advance_to_rec_itd - nvl(advance_to_rec_ptd,0)),
	advance_to_rec_ptd = 0,
	comm_pend_itd = (comm_pend_itd - nvl(comm_pend_ptd,0)),
	comm_pend_ptd = 0,
	recovery_amount_itd = (recovery_amount_itd - nvl(recovery_amount_ptd,0)),
	recovery_amount_ptd = 0,
	performance_goal_itd = (performance_goal_itd - nvl(performance_goal_ptd,0)),
	performance_goal_ptd = 0
	WHERE salesrep_id = x_salesrep_id
	AND period_id between l_start_period_id and l_end_period_id;

      COMMIT;

      -- CN_SRP_PER_QUOTA_RC
      UPDATE cn_srp_per_quota_rc SET
	year_to_date = 0,
	quarter_to_date = 0,
	period_to_date = 0
	WHERE salesrep_id = x_salesrep_id
	AND period_id between l_start_period_id and l_end_period_id;
      COMMIT;

      -- Delete Payment from CN_PAYMENT_WORKSHEETS, CN_PAYMENT_API
      DELETE FROM CN_PAYMENT_WORKSHEETS
	WHERE salesrep_id = x_salesrep_id
	AND payrun_id IN (SELECT payrun_id FROM CN_PAYRUNS
			  WHERE accounting_period_id between l_start_period_id and l_end_period_id);
      COMMIT;

      DELETE FROM CN_PAYMENT_API
	WHERE salesrep_id = x_salesrep_id
	AND period_id between l_start_period_id and l_end_period_id
	AND payrun_id IN (SELECT payrun_id FROM CN_PAYRUNS
			  WHERE accounting_period_id between l_start_period_id and l_end_period_id);
      COMMIT;

      -- Delete journal entries from CN_LEDGER_JOURNAL_ENTRIES
      DELETE FROM CN_LEDGER_JOURNAL_ENTRIES
	WHERE srp_period_id IN (SELECT srp_period_id FROM CN_SRP_PERIODS
				WHERE salesrep_id = x_salesrep_id
				AND period_id between l_start_period_id and l_end_period_id);
      COMMIT;

      -- Delete transactions from CN_COMM_LINES_API, CN_NOT_TRX, CN_TRX, CN_TRX_LINES, CN_TRX_SALES_LINES
      DELETE FROM CN_COMM_LINES_API
	WHERE (employee_number, type) = (SELECT employee_number, type FROM cn_salesreps WHERE salesrep_id = x_salesrep_id)
	AND processed_date between l_start_date and l_end_date;
      COMMIT;

      DELETE FROM cn_not_trx
	WHERE source_trx_id IN (SELECT source_trx_id
				FROM cn_trx
				WHERE trx_id IN (SELECT trx_id
						 FROM cn_trx_sales_lines
						 WHERE salesrep_id = x_salesrep_id
						 AND processed_period_id BETWEEN l_start_period_id AND l_end_period_id));
      COMMIT;

      DELETE FROM cn_trx
	WHERE trx_id IN (SELECT trx_id
			 FROM cn_trx_sales_lines
			 WHERE salesrep_id = x_salesrep_id
			 AND processed_period_id BETWEEN l_start_period_id AND l_end_period_id);
      COMMIT;

      DELETE FROM cn_trx_lines
	WHERE trx_line_id IN (SELECT trx_line_id
			      FROM cn_trx_sales_lines
			      WHERE salesrep_id = x_salesrep_id
			      AND processed_period_id BETWEEN l_start_period_id AND l_end_period_id);
      COMMIT;

      DELETE FROM CN_TRX_SALES_LINES
	WHERE salesrep_id = x_salesrep_id
	AND processed_period_id between l_start_period_id and l_end_period_id;
      COMMIT;
    ELSE
      -- Delete transactions from CN_COMMISSION_HEADERS
      DELETE FROM CN_COMMISSION_HEADERS
	WHERE direct_salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND processed_date between l_start_date and l_end_date;
      COMMIT;

      -- Delete transactions from CN_COMMISSION_LINES
      DELETE FROM CN_COMMISSION_LINES
	WHERE processed_period_id between l_start_period_id and l_end_period_id;
      COMMIT;

      -- Update CN_SRP_PERIODS
      UPDATE  cn_srp_periods SET
	balance1_dtd = 0,
	balance1_ctd = 0,
	balance1_bbd = 0,
	balance1_bbc = 0,
	balance2_dtd = 0,
	balance2_ctd = 0,
	balance2_bbd = 0,
	balance2_bbc = 0,
	balance3_dtd = 0,
	balance3_ctd = 0,
	balance3_bbd = 0,
	balance3_bbc = 0,
	balance4_dtd = 0,
	balance4_ctd = 0,
	balance4_bbd = 0,
	balance4_bbc = 0,
	balance5_dtd = 0,
	balance5_ctd = 0,
	balance5_bbd = 0,
	balance5_bbc = 0,
	balance6_dtd = 0,
	balance6_ctd = 0,
	balance6_bbd = 0,
	balance6_bbc = 0,
	balance7_dtd = 0,
	balance7_ctd = 0,
	balance7_bbd = 0,
	balance7_bbc = 0,
	balance8_dtd = 0,
	balance8_ctd = 0,
	balance8_bbd = 0,
	balance8_bbc = 0,
	balance9_dtd = 0,
	balance9_ctd = 0,
	balance9_bbd = 0,
	balance9_bbc = 0,
	balance10_dtd = 0,
	balance10_ctd = 0,
	balance10_bbd = 0,
	balance10_bbc = 0,
	balance11_dtd = 0,
	balance11_ctd = 0,
	balance11_bbd = 0,
	balance11_bbc = 0,
	balance12_dtd = 0,
	balance12_ctd = 0,
	balance12_bbd = 0,
	balance12_bbc = 0,
	balance13_dtd = 0,
	balance13_ctd = 0,
	balance13_bbd = 0,
	balance13_bbc = 0,
	balance14_dtd = 0,
	balance14_ctd = 0,
	balance14_bbd = 0,
	balance14_bbc = 0,
	balance15_dtd = 0,
	balance15_ctd = 0,
	balance15_bbd = 0,
	balance15_bbc = 0,
	balance16_dtd = 0,
	balance16_ctd = 0,
	balance16_bbd = 0,
	balance16_bbc = 0,
	balance17_dtd = 0,
	balance17_ctd = 0,
	balance17_bbd = 0,
	balance17_bbc = 0,
	balance18_dtd = 0,
	balance18_ctd = 0,
	balance18_bbd = 0,
	balance18_bbc = 0,
	balance19_dtd = 0,
	balance19_ctd = 0,
	balance19_bbd = 0,
	balance19_bbc = 0,
	balance20_dtd = 0,
	balance20_ctd = 0,
	balance20_bbd = 0,
	balance20_bbc = 0,
	balance21_dtd = 0,
	balance21_ctd = 0,
	balance21_bbd = 0,
	balance21_bbc = 0,
	balance22_dtd = 0,
	balance22_ctd = 0,
	balance22_bbd = 0,
	balance22_bbc = 0,
	balance23_dtd = 0,
	balance23_ctd = 0,
	balance23_bbd = 0,
	balance23_bbc = 0,
	balance24_dtd = 0,
	balance24_ctd = 0,
	balance24_bbd = 0,
	balance24_bbc = 0,
	balance25_dtd = 0,
	balance25_ctd = 0,
	balance25_bbd = 0,
	balance25_bbc = 0,
	balance26_dtd = 0,
	balance26_ctd = 0,
	balance26_bbd = 0,
	balance26_bbc = 0,
	balance27_dtd = 0,
	balance27_ctd = 0,
	balance27_bbd = 0,
	balance27_bbc = 0,
	balance28_dtd = 0,
	balance28_ctd = 0,
	balance28_bbd = 0,
	balance28_bbc = 0,
	balance29_dtd = 0,
	balance29_ctd = 0,
	balance29_bbd = 0,
	balance29_bbc = 0,
	balance30_dtd = 0,
	balance30_ctd = 0,
	balance30_bbd = 0,
	balance30_bbc = 0,
	balance31_dtd = 0,
	balance31_ctd = 0,
	balance31_bbd = 0,
	balance31_bbc = 0,
	balance32_dtd = 0,
	balance32_ctd = 0,
	balance32_bbd = 0,
	balance32_bbc = 0,
	balance33_dtd = 0,
	balance33_ctd = 0,
	balance33_bbd = 0,
	balance33_bbc = 0
        WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND period_id between l_start_period_id and l_end_period_id;
      COMMIT;

       -- Update CN_SRP_PERIOD_QUOTAS
      UPDATE cn_srp_period_quotas SET
	commission_payed_itd = (commission_payed_itd - nvl(commission_payed_ptd,0)),
	commission_payed_ptd = 0,
	perf_achieved_itd = (perf_achieved_itd - nvl(perf_achieved_ptd,0)),
	perf_achieved_ptd = 0,
	advance_recovered_itd = (advance_recovered_itd - nvl(advance_recovered_ptd,0)),
	advance_recovered_ptd = 0,
	advance_to_rec_itd = (advance_to_rec_itd - nvl(advance_to_rec_ptd,0)),
	advance_to_rec_ptd = 0,
	comm_pend_itd = (comm_pend_itd - nvl(comm_pend_ptd,0)),
	comm_pend_ptd = 0,
	recovery_amount_itd = (recovery_amount_itd - nvl(recovery_amount_ptd,0)),
	recovery_amount_ptd = 0,
	performance_goal_itd = (performance_goal_itd - nvl(performance_goal_ptd,0)),
	performance_goal_ptd = 0
	WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND period_id between l_start_period_id and l_end_period_id;

      COMMIT;

      -- CN_SRP_PER_QUOTA_RC
      UPDATE cn_srp_per_quota_rc SET
	year_to_date = 0,
	quarter_to_date = 0,
	period_to_date = 0
	WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND period_id between l_start_period_id and l_end_period_id;
      COMMIT;

      -- Delete Payment from CN_PAYMENT_WORKSHEETS, CN_PAYMENT_API
      DELETE FROM CN_PAYMENT_WORKSHEETS
	WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND payrun_id IN (SELECT payrun_id FROM CN_PAYRUNS
			  WHERE accounting_period_id between l_start_period_id and l_end_period_id);
      COMMIT;

      DELETE FROM CN_PAYMENT_API
	WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND period_id between l_start_period_id and l_end_period_id
	AND payrun_id IN (SELECT payrun_id FROM CN_PAYRUNS
			  WHERE accounting_period_id between l_start_period_id and l_end_period_id);
      COMMIT;

      -- Delete journal entries from CN_LEDGER_JOURNAL_ENTRIES
      DELETE FROM CN_LEDGER_JOURNAL_ENTRIES
	WHERE srp_period_id IN (SELECT srp_period_id FROM CN_SRP_PERIODS
				WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
				AND period_id between l_start_period_id and l_end_period_id);
      COMMIT;

      -- Delete transactions from CN_COMM_LINES_API, CN_NOT_TRX, CN_TRX, CN_TRX_LINES, CN_TRX_SALES_LINES
      DELETE FROM CN_COMM_LINES_API
	WHERE (employee_number, TYPE) IN (SELECT employee_number, TYPE FROM cn_salesreps)
	AND processed_date between l_start_date and l_end_date;
      COMMIT;

      DELETE FROM cn_not_trx
	WHERE source_trx_id IN (SELECT source_trx_id
				FROM cn_trx
				WHERE trx_id IN (SELECT trx_id
						 FROM cn_trx_sales_lines
						 WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
						 AND processed_period_id BETWEEN l_start_period_id AND l_end_period_id));
      COMMIT;

      DELETE FROM cn_trx
	WHERE trx_id IN (SELECT trx_id
			 FROM cn_trx_sales_lines
			 WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
			 AND processed_period_id BETWEEN l_start_period_id AND l_end_period_id);
      COMMIT;

      DELETE FROM cn_trx_lines
	WHERE trx_line_id IN (SELECT trx_line_id
			      FROM cn_trx_sales_lines
			      WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
			      AND processed_period_id BETWEEN l_start_period_id AND l_end_period_id);
      COMMIT;

      DELETE FROM CN_TRX_SALES_LINES
	WHERE salesrep_id IN (SELECT salesrep_id FROM cn_salesreps)
	AND processed_period_id between l_start_period_id and l_end_period_id;
      COMMIT;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      rollback;
      cn_message_pkg.debug('Invalid period name');
   WHEN OTHERS THEN
      rollback;
      cn_message_pkg.debug('Other error occurred during purge');
END purge;

END cn_purge_pkg;

/

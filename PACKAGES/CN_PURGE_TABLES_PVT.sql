--------------------------------------------------------
--  DDL for Package CN_PURGE_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PURGE_TABLES_PVT" AUTHID CURRENT_USER AS
  /* $Header: CNVTPRGS.pls 120.0.12010000.3 2010/06/17 05:01:44 sseshaiy noship $*/

  cn_payment_api_all_id          CONSTANT NUMBER := 0;
  cn_posting_details_all_id      CONSTANT NUMBER := 1;
  cn_payment_transactions_all_id CONSTANT NUMBER := 2;
  cn_commission_lines_all_id     CONSTANT NUMBER := 3;
  cn_commission_headers_all_id   CONSTANT NUMBER := 4;
  cn_trx_sales_lines_all_id      CONSTANT NUMBER := 5;
  cn_trx_lines_all_id            CONSTANT NUMBER := 6;
  cn_trx_all_id                  CONSTANT NUMBER := 7;
  cn_not_trx_all_id              CONSTANT NUMBER := 8;
  cn_invoice_changes_all_id      CONSTANT NUMBER := 9;
  cn_imp_headers_id              CONSTANT NUMBER := 10;
  cn_imp_lines_id                CONSTANT NUMBER := 11;
  cn_comm_lines_api_all_id       CONSTANT NUMBER := 12;
  cn_srp_payee_assigns_all_id    CONSTANT NUMBER := 13;
  cn_srp_quota_assigns_all_id    CONSTANT NUMBER := 14;
  cn_srp_rate_assigns_all_id     CONSTANT NUMBER := 15;
  cn_srp_rule_uplifts_all_id     CONSTANT NUMBER := 16;
  cn_srp_quota_rules_all_id      CONSTANT NUMBER := 17;
  cn_srp_plan_assigns_all_id     CONSTANT NUMBER := 18;
  cn_srp_period_quotas_ext_all_i CONSTANT NUMBER := 19;
  cn_srp_per_quota_rc_all_id     CONSTANT NUMBER := 20;
  cn_srp_period_quotas_all_id    CONSTANT NUMBER := 21;
  cn_pay_approval_flow_all_id    CONSTANT NUMBER := 22;
  cn_worksheet_qg_dtls_all_id    CONSTANT NUMBER := 23;
  cn_payment_worksheets_all_id   CONSTANT NUMBER := 24;
  cn_ledger_journal_entries_alli CONSTANT NUMBER := 25;
  cn_posting_details_sum_all_id  CONSTANT NUMBER := 26;
  cn_worksheet_bonuses_all_id    CONSTANT NUMBER := 27;
  cn_payruns_all_id              CONSTANT NUMBER := 29;
  cn_srp_periods_all_id          CONSTANT NUMBER := 30;
  cn_process_audits_all_id       CONSTANT NUMBER := 31;
  cn_process_audit_lines_all_id  CONSTANT NUMBER := 32;
  cn_process_batches_all_id      CONSTANT NUMBER := 33;
  cn_srp_intel_periods_all_id    CONSTANT NUMBER := 34;

type imp_header
IS
  record
  (
    imp_header_id cn_imp_lines.IMP_HEADER_ID%type);

type l_imp_header_id_tbl_type
IS
  TABLE OF cn_imp_lines.imp_header_id%type INDEX BY binary_integer;

-- API name  : archive_purge_cn_tables
-- Type : public.
-- Pre-reqs :
PROCEDURE archive_purge_cn_tables
  (
    errbuf OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_run_mode          IN VARCHAR2,
    p_start_period_id   IN NUMBER,
    p_end_period_id     IN NUMBER,
    p_no_of_workers     IN NUMBER,
    p_org_id            IN NUMBER,
    p_table_space       IN VARCHAR2,
    p_worker_id         IN NUMBER,
    p_batch_size        IN NUMBER,
    p_request_id        IN NUMBER
    );

PROCEDURE audit_purge_cn_tables
  (
    p_run_mode        IN VARCHAR2,
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    p_org_id          IN NUMBER,
    p_worker_id       IN NUMBER,
    p_no_of_workers   IN NUMBER,
    p_batch_size      IN NUMBER,
    x_msg_count OUT nocopy     NUMBER,
    x_msg_data OUT nocopy      VARCHAR2,
    x_return_status OUT nocopy VARCHAR2
    );

END CN_PURGE_TABLES_PVT;

/

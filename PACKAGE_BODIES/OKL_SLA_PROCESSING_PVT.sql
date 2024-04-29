--------------------------------------------------------
--  DDL for Package Body OKL_SLA_PROCESSING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SLA_PROCESSING_PVT" AS
/* $Header: OKLACHKB.pls 120.0.12010000.3 2008/10/01 23:16:34 rkuttiya ship $ */

-- No processing for pre-accounting hook..
PROCEDURE preaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
)
IS

BEGIN

  NULL;

END preaccounting;

-- Update the posted_yn flag based on the event status
-- View xla_post_acctg_events_v has events that are successfully accounted
-- process_status_code in 'D'(Draft accounting), 'P'(Final accounting).
PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
IS

 CURSOR events_info_csr IS
 SELECT event_id, source_id_int_1
   FROM xla_post_acctg_events_v
  WHERE application_id = p_application_id;

TYPE t_event_tbl IS TABLE OF xla_events.event_id%TYPE INDEX BY BINARY_INTEGER;
TYPE t_id_tbl IS TABLE OF okl_trx_contracts_all.id%TYPE INDEX BY BINARY_INTEGER;
l_event_tbl               t_event_tbl;
l_tcn_tbl                 t_id_tbl;
l_fetch_size              NUMBER := 1000;

BEGIN

  IF (p_application_id <> 540) THEN
    RETURN;
  END IF;

  IF (p_accounting_mode = 'D') THEN
    RETURN;
  END IF;

  OPEN events_info_csr;

  LOOP

  FETCH events_info_csr BULK COLLECT INTO l_event_tbl, l_tcn_tbl limit l_fetch_size;

  FORALL i IN 1..l_event_tbl.count
    UPDATE okl_trx_contracts_all
       SET tsu_code = 'CANCELED',
	       canceled_date = sysdate,
		   accounting_reversal_yn = 'N'
     WHERE id = l_tcn_tbl(i)
	   AND exists( SELECT 1
	                 FROM okl_trns_acc_dstrs_all
				    WHERE accounting_event_id = l_event_tbl(i)
					  AND gl_reversal_flag = 'Y' );

  IF l_event_tbl.count < l_fetch_size then
     EXIT;
  END IF;

  END LOOP;

  CLOSE events_info_csr;

EXCEPTION

  WHEN OTHERS THEN
    IF events_info_csr%ISOPEN THEN
       CLOSE events_info_csr;
    END IF;

    Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => SQLCODE,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => SQLERRM);

    app_exception.raise_exception();

END postprocessing;

-- Lock the distributions belonging to the events that are selected by SLA
-- to create journal entries. Update the distributions posted_yn to 'S'.
PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
IS
BEGIN

  NULL;

END extract;

-- No processing in postaccounting hook.
PROCEDURE postaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
)
IS

BEGIN

  NULL;

END postaccounting;

END okl_sla_processing_pvt;

/

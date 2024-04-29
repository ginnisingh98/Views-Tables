--------------------------------------------------------
--  DDL for Package Body PSA_BC_XLA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_BC_XLA_PVT" AS
--$Header: psavbcxb.pls 120.34.12010000.20 2010/02/16 17:28:50 sasukuma ship $
---------------------------------------------------------------------------

G_PKG_NAME CONSTANT  VARCHAR2(30) := 'PSA_BC_XLA_PVT';

---------------------------------------------------------------------------

--==========================================================================
--Logging Declarations
--==========================================================================
g_state_level NUMBER                  :=   FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER                  :=   FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER                  :=   FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER                  :=   FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER                  :=   FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER                  :=   FND_LOG.LEVEL_UNEXPECTED;
g_log_level   CONSTANT NUMBER         :=   FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_path_name   CONSTANT VARCHAR2(200)  :=   'psa.plsql.psavbcxb.psa_bc_xla_pvt';
g_log_enabled BOOLEAN                 :=   FALSE;
g_audsid      NUMBER;


--==========================================================================
-- declaring private constants
--==========================================================================

C_YES                       CONSTANT VARCHAR2(1)   := 'Y'; -- yes flag
C_NO                        CONSTANT VARCHAR2(1)   := 'N'; -- no flag
C_FUNDS_CHECK               CONSTANT VARCHAR2(1)   := 'C';
C_FUNDS_RESERVE             CONSTANT VARCHAR2(1)   := 'R';
C_FUNDS_PARTIAL             CONSTANT VARCHAR2(1)   := 'P';
C_FUNDS_FORCE_PASS          CONSTANT VARCHAR2(1)   := 'F';
C_FUNDS_ADVISORY            CONSTANT VARCHAR2(1)   := 'A';
C_FUNDS_CHK_FULL            CONSTANT VARCHAR2(1)   := 'M';

--==========================================================================
-- declaring private variables
--==========================================================================
TYPE psa_acctg_errors_table IS TABLE OF psa_bc_accounting_errors%ROWTYPE;
TYPE psa_events_table IS TABLE OF psa_bc_xla_events_gt.event_id%TYPE;

--==========================================================================
-- Forward Declaration of PA/GMS API's
--==========================================================================
PROCEDURE pa_gms_integration_api;
PROCEDURE pa_gms_tieback_api;

procedure psa_cleanup_gt;

  PROCEDURE init
  IS
    l_path_name       VARCHAR2(500);
    l_file_info       VARCHAR2(2000);
  BEGIN
    l_path_name := g_path_name || '.init';
    l_file_info :=
       '$Header: psavbcxb.pls 120.34.12010000.20 2010/02/16 17:28:50 sasukuma ship $';
    psa_utils.debug_other_string(g_state_level,l_path_name,  'PSA_BC_XLA_PVT version = '||l_file_info);
  END;

  PROCEDURE psa_xla_error_cleanup
  (
    p_xla_transaction_entities IN xla_transaction_entities%ROWTYPE
  )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_path_name VARCHAR2(500);
  BEGIN
    DELETE psa_xla_accounting_errors p
     WHERE p.entity_code = p_xla_transaction_entities.entity_code
       AND NVL(p.source_id_int_1, -1) = NVL(p_xla_transaction_entities.source_id_int_1, -1)
       AND NVL(p.source_id_int_2, -1) = NVL(p_xla_transaction_entities.source_id_int_2, -1)
       AND NVL(p.source_id_int_3, -1) = NVL(p_xla_transaction_entities.source_id_int_3, -1)
       AND NVL(p.source_id_int_4, -1) = NVL(p_xla_transaction_entities.source_id_int_4, -1)
       AND NVL(p.source_id_char_1, ' ') = NVL(p_xla_transaction_entities.source_id_char_1, ' ')
       AND NVL(p.source_id_char_2, ' ') = NVL(p_xla_transaction_entities.source_id_char_2, ' ')
       AND NVL(p.source_id_char_3, ' ') = NVL(p_xla_transaction_entities.source_id_char_3, ' ')
       AND NVL(p.source_id_char_4, ' ') = NVL(p_xla_transaction_entities.source_id_char_4, ' ');
    COMMIT;
  END;

  PROCEDURE psa_xla_error_cleanup
  IS
    l_path_name VARCHAR2(500);
    l_psa_xla_accounting_errors psa_xla_accounting_errors%ROWTYPE;
  BEGIN
    FOR entity_rec IN (SELECT t.*
                          FROM xla_events e,
                               xla_transaction_entities t,
                               psa_bc_xla_events_gt p
                         WHERE p.event_id = e.event_id
                           AND e.entity_id = t.entity_id) LOOP
      psa_xla_error_cleanup (entity_rec);
    END LOOP;
  END;

  /*
    This is the final Autonomous Transaction Procedure
    that inserts the PSA/XLA error into the table.
  */

  PROCEDURE psa_xla_error
  (
    p_psa_xla_accounting_errors IN psa_xla_accounting_errors%ROWTYPE
  )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_path_name VARCHAR2(500);
    l_psa_xla_accounting_errors psa_xla_accounting_errors%ROWTYPE;
  BEGIN
    l_psa_xla_accounting_errors := p_psa_xla_accounting_errors;
    IF (p_psa_xla_accounting_errors.accounting_error_id IS NULL) THEN
      SELECT psa_xla_accounting_errors_s.nextval
        INTO l_psa_xla_accounting_errors.accounting_error_id
        FROM DUAL;
    END IF;

   /*INSERT INTO psa_xla_accounting_errors
    VALUES l_psa_xla_accounting_errors;*/

    INSERT INTO psa_xla_accounting_errors
    (	ACCOUNTING_ERROR_ID,
	APPLICATION_ID,
	LEDGER_ID,
	ENTITY_CODE,
	ENTITY_ID,
	EVENT_DATE ,
	EVENT_ID,
	TRANSACTION_NUMBER,
	AE_HEADER_ID,
	AE_LINE_NUM,
	SOURCE_ID_INT_1,
	SOURCE_ID_INT_2,
	SOURCE_ID_INT_3,
	SOURCE_ID_INT_4,
	SOURCE_ID_CHAR_1,
	SOURCE_ID_CHAR_2,
	SOURCE_ID_CHAR_3,
	SOURCE_ID_CHAR_4,
	MESSAGE_CODE,
	MESSAGE_NUM,
	ENCODED_MSG,
	AUDSID,
	CREATION_DATE,
	CREATED_BY
	)
    VALUES (    l_psa_xla_accounting_errors.ACCOUNTING_ERROR_ID,
		l_psa_xla_accounting_errors.APPLICATION_ID ,
		l_psa_xla_accounting_errors.LEDGER_ID,
		l_psa_xla_accounting_errors.ENTITY_CODE,
		l_psa_xla_accounting_errors.ENTITY_ID ,
		l_psa_xla_accounting_errors.EVENT_DATE ,
		l_psa_xla_accounting_errors.EVENT_ID,
		l_psa_xla_accounting_errors.TRANSACTION_NUMBER,
		l_psa_xla_accounting_errors.AE_HEADER_ID,
		l_psa_xla_accounting_errors.AE_LINE_NUM ,
		l_psa_xla_accounting_errors.SOURCE_ID_INT_1,
		l_psa_xla_accounting_errors.SOURCE_ID_INT_2,
		l_psa_xla_accounting_errors.SOURCE_ID_INT_3,
		l_psa_xla_accounting_errors.SOURCE_ID_INT_4,
		l_psa_xla_accounting_errors.SOURCE_ID_CHAR_1,
		l_psa_xla_accounting_errors.SOURCE_ID_CHAR_2,
		l_psa_xla_accounting_errors.SOURCE_ID_CHAR_3,
		l_psa_xla_accounting_errors.SOURCE_ID_CHAR_4 ,
		l_psa_xla_accounting_errors.MESSAGE_CODE ,
		l_psa_xla_accounting_errors.MESSAGE_NUM,
		l_psa_xla_accounting_errors.ENCODED_MSG,
		l_psa_xla_accounting_errors.AUDSID,
		l_psa_xla_accounting_errors.CREATION_DATE ,
		l_psa_xla_accounting_errors.CREATED_BY);

    COMMIT;
  END;

  PROCEDURE psa_xla_error
  (
    p_message_code IN VARCHAR2,
    p_event_id IN NUMBER DEFAULT NULL
  )
  IS
    l_path_name VARCHAR2(500);
    l_message_text psa_xla_accounting_errors.encoded_msg%TYPE;
    l_psa_xla_accounting_errors psa_xla_accounting_errors%ROWTYPE;
    l_msg_index NUMBER;
  BEGIN
    FOR event_rec IN (SELECT e.event_id,
                             t.entity_id,
                             t.entity_code,
                             t.source_id_int_1,
                             t.source_id_int_2,
                             t.source_id_int_3,
                             t.source_id_int_4,
                             t.source_id_char_1,
                             t.source_id_char_2,
                             t.source_id_char_3,
                             t.source_id_char_4,
                             t.application_id,
                             t.transaction_number,
                             e.event_date,
                             t.ledger_id
                        FROM xla_events e,
                             xla_transaction_entities t,
                             psa_bc_xla_events_gt p
                       WHERE p.event_id = e.event_id
                         AND e.entity_id = t.entity_id
                         AND p.event_id = NVL(p_event_id, p.event_id)) LOOP

      l_psa_xla_accounting_errors.message_code := p_message_code;
      l_psa_xla_accounting_errors.encoded_msg := fnd_message.get;
      l_psa_xla_accounting_errors.audsid := g_audsid;
      l_psa_xla_accounting_errors.creation_date := SYSDATE;
      l_psa_xla_accounting_errors.created_by := g_user_id;
      l_psa_xla_accounting_errors.entity_id := event_rec.entity_id;
      l_psa_xla_accounting_errors.event_id := event_rec.event_id;
      l_psa_xla_accounting_errors.application_id := event_rec.application_id;
      l_psa_xla_accounting_errors.source_id_int_1 := event_rec.source_id_int_1;
      l_psa_xla_accounting_errors.source_id_int_2 := event_rec.source_id_int_2;
      l_psa_xla_accounting_errors.source_id_int_3 := event_rec.source_id_int_3;
      l_psa_xla_accounting_errors.source_id_int_4 := event_rec.source_id_int_4;
      l_psa_xla_accounting_errors.source_id_char_1 := event_rec.source_id_char_1;
      l_psa_xla_accounting_errors.source_id_char_2 := event_rec.source_id_char_2;
      l_psa_xla_accounting_errors.source_id_char_3 := event_rec.source_id_char_3;
      l_psa_xla_accounting_errors.source_id_char_4 := event_rec.source_id_char_4;
      l_psa_xla_accounting_errors.entity_code := event_rec.entity_code;
      l_psa_xla_accounting_errors.transaction_number := event_rec.transaction_number;
      l_psa_xla_accounting_errors.event_date := event_rec.event_date;
      l_psa_xla_accounting_errors.ledger_id := event_rec.ledger_id;
      psa_xla_error (l_psa_xla_accounting_errors);
    END LOOP;
  END;

  PROCEDURE copy_xla_error
  (
    p_error_found OUT NOCOPY VARCHAR2
  )
  IS
    l_psa_xla_accounting_errors psa_xla_accounting_errors%ROWTYPE;
    l_xla_error_found BOOLEAN := FALSE;
    l_path_name       VARCHAR2(500);
    l_count NUMBER;
  BEGIN
    l_path_name := g_path_name || '.copy_xla_error';
    p_error_found := 'N';
    psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure copy_xla_error ' );
    FOR error_rec IN (SELECT e.entity_id,
                             e.event_id,
                             e.application_id,
                             er.message_number,
                             er.encoded_msg,
                             t.source_id_int_1,
                             t.source_id_int_2,
                             t.source_id_int_3,
                             t.source_id_int_4,
                             t.source_id_char_1,
                             t.source_id_char_2,
                             t.source_id_char_3,
                             t.source_id_char_4,
                             t.entity_code,
                             t.transaction_number,
                             t.ledger_id,
                             e.event_date,
                             er.ae_header_id,
                             er.ae_line_num
                        FROM xla_accounting_errors er,
                             psa_bc_xla_events_gt p,
                             xla_events e,
                             xla_transaction_entities t
                       WHERE er.event_id = p.event_id
                         AND e.event_id = p.event_id
                         AND t.entity_id = e.entity_id) LOOP
      p_error_found := 'Y';
      l_psa_xla_accounting_errors.entity_id := error_rec.entity_id;
      l_psa_xla_accounting_errors.event_id := error_rec.event_id;
      l_psa_xla_accounting_errors.message_num := error_rec.message_number;
      l_psa_xla_accounting_errors.message_code := 'XLA_ERROR';
      l_psa_xla_accounting_errors.encoded_msg := error_rec.encoded_msg;
      l_psa_xla_accounting_errors.audsid := g_audsid;
      l_psa_xla_accounting_errors.creation_date := SYSDATE;
      l_psa_xla_accounting_errors.created_by := g_user_id;
      l_psa_xla_accounting_errors.application_id := error_rec.application_id;
      l_psa_xla_accounting_errors.source_id_int_1 := error_rec.source_id_int_1;
      l_psa_xla_accounting_errors.source_id_int_2 := error_rec.source_id_int_2;
      l_psa_xla_accounting_errors.source_id_int_3 := error_rec.source_id_int_3;
      l_psa_xla_accounting_errors.source_id_int_4 := error_rec.source_id_int_4;
      l_psa_xla_accounting_errors.source_id_char_1 := error_rec.source_id_char_1;
      l_psa_xla_accounting_errors.source_id_char_2 := error_rec.source_id_char_2;
      l_psa_xla_accounting_errors.source_id_char_3 := error_rec.source_id_char_3;
      l_psa_xla_accounting_errors.source_id_char_4 := error_rec.source_id_char_4;
      l_psa_xla_accounting_errors.entity_code := error_rec.entity_code;
      l_psa_xla_accounting_errors.transaction_number := error_rec.transaction_number;
      l_psa_xla_accounting_errors.ledger_id := error_rec.ledger_id;
      l_psa_xla_accounting_errors.event_date := error_rec.event_date;
      l_psa_xla_accounting_errors.ae_header_id := error_rec.ae_header_id;
      l_psa_xla_accounting_errors.ae_line_num := error_rec.ae_line_num;
      psa_xla_error (l_psa_xla_accounting_errors);
    END LOOP;
  END;

  PROCEDURE try_to_interpret_xla_error
  IS
    l_psa_xla_accounting_errors psa_xla_accounting_errors%ROWTYPE;
    l_xla_error_found BOOLEAN := FALSE;
    l_path_name       VARCHAR2(500);
    l_count NUMBER;
  BEGIN
    l_path_name := g_path_name || '.try_to_interpret_xla_error';
    psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure try_to_interpret_xla_error ' );

    psa_utils.debug_other_string(g_state_level,l_path_name, 'Checking for Invalid AAD' );
    FOR xla_rec IN (SELECT ru.compile_status_code,
                           e.entity_id,
                           e.event_id,
                           ru.name product_rule_name,
                           ru.product_rule_type_code product_rule_owner,
                           t.ledger_id
                      FROM xla_events e,
                           xla_transaction_entities t,
                           psa_bc_xla_events_gt p,
                           gl_ledgers g,
                           xla_acctg_methods_fvl m,
                           xla_acctg_method_rules_fvl r,
                           xla_product_rules_fvl ru
                     WHERE p.event_id = e.event_id
                       AND e.entity_id = t.entity_id
                       AND t.ledger_id = g.ledger_id
                       AND g.sla_accounting_method_code = m.accounting_method_code
                       AND g.sla_accounting_method_type = m.accounting_method_type_code
                       AND r.accounting_method_code = m.accounting_method_code
                       AND r.accounting_method_type_code = m.accounting_method_type_code
                       AND r.application_id = t.application_id
                       AND r.product_rule_code = ru.product_rule_code
                       AND r.product_rule_type_code = ru.product_rule_type_code
                       AND e.event_date BETWEEN r.start_date_active AND NVL(r.end_date_active, e.event_date+1)) LOOP
      psa_utils.debug_other_string(g_state_level,l_path_name, 'compile_status_code='||xla_rec.compile_status_code);
      IF xla_rec.compile_status_code <> 'Y' THEN
        fnd_message.set_name ('XLA','XLA_AP_PAD_INACTIVE');
        fnd_message.set_token ('PAD_NAME', xla_rec.product_rule_name);
        fnd_message.set_token ('OWNER', xla_lookups_pkg.get_meaning('XLA_OWNER_TYPE',xla_rec.product_rule_owner));
        fnd_message.set_token ('SUBLEDGER_ACCTG_METHOD', xla_accounting_cache_pkg.GetSessionValueChar
                                                          (p_source_code => 'XLA_ACCOUNTING_METHOD_NAME'
                                                          ,p_target_ledger_id => xla_rec.ledger_id));

        psa_utils.debug_other_string(g_state_level,l_path_name, 'Calling psa_xla_error');
        psa_xla_error
        (
          p_message_code => 'XLA_AP_PAD_INACTIVE',
          p_event_id     => xla_rec.event_id
        );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      psa_utils.debug_other_string(g_state_level,l_path_name, 'Error:'||SQLERRM);
      RAISE;
  END;




-------------------------------------------------------------------------------
-- PROCEDURE  psa_acctg_errors_insert
-- Autonomously insert xla accounting erros rows into psa_bc_accounting_errors
-- This will allow to see the error records in PSA view results report
-- in case a product team issues a rollback.
-------------------------------------------------------------------------------

PROCEDURE psa_acctg_errors_insert(psa_events IN psa_events_table, psa_acctg_errors IN psa_acctg_errors_table) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_path_name            VARCHAR2(500);
BEGIN
   l_path_name := g_path_name||'.psa_acctg_errors_insert';

   psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure psa_acctg_errors_insert');

   FORALL i in 1..psa_events.COUNT
       DELETE FROM psa_bc_accounting_errors
       WHERE event_id = psa_events(i);
   psa_utils.debug_other_string(g_state_level,l_path_name,'No of rows deleted from psa_bc_accounting_erros: '||SQL%ROWCOUNT);

   FORALL j in 1..psa_acctg_errors.COUNT
       INSERT INTO psa_bc_accounting_errors VALUES psa_acctg_errors(j);
   psa_utils.debug_other_string(g_state_level,l_path_name,'No of rows inserted into psa_bc_accounting_erros: '||SQL%ROWCOUNT);

   COMMIT;
   psa_utils.debug_other_string(g_state_level,l_path_name, 'END of procedure psa_acctg_errors_insert');

END psa_acctg_errors_insert;


 -- /*============================================================================
 -- API name     : Budgetary_Control
 -- Type         : private
 -- Pre-reqs     : Create events in psa_bc_xla_events_gt
 -- Description  : Call SLA engine for BCPSA
 --
 --  Parameters  :
 --  IN          :   p_api_version    IN NUMBER  Required
 --                  p_init_msg_list  IN VARCHAR2 optional Default FND_API.G_FALSE
 --                  p_commit         IN VARCHAR2 optional Default FND_API.G_FALSE
 --                  p_application_id IN NUMBER  Required
 --                  p_bc_mode        IN NUMBER optional Possible values:Check(C ) /Reserve(R )
 --                  p_bc_override_flag VARCHAR2 optional Possible values: Y/N
 --                  p_user_id        IN NUMBER optional
 --                  p_user_resp_id   IN NUMBER optional
 --
 -- OUT          :   x_return_status  OUT VARCHAR2(1)
 --                  x_msg_count      OUT NUMBER
 --                  x_msg_data       OUT VARCHAR2(2000)
--                   x_packet_id      OUT  NUMBER
 --
 -- Version      :   Current Version 1.0
 --                  Initial Version 1.0
 --
 --
 --
 --  Logic
 --        - Validate the  parameters
 --        - Get the events to be processed
 --        - Call the SLA online accounting engine with required parameters
 --        - Return the Fund status/error
 --
 --  Notes:
 --         Currently calling accounting engine in document mode
 --          After SLA API for bcpsa is available need to make neccessary changes
 --
 --  Modification History
 --  Date         Author             Description of Change
 --
 -- *===========================================================================*/

PROCEDURE Budgetary_Control
   ( p_init_msg_list             IN  VARCHAR2
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_application_id            IN INTEGER
    ,p_bc_mode                   IN VARCHAR2
    ,p_override_flag             IN VARCHAR2
    ,P_user_id                   IN NUMBER
    ,P_user_resp_id              IN NUMBER
    ,x_status_code               OUT NOCOPY VARCHAR2
    ,x_Packet_ID                 OUT NOCOPY NUMBER
   )

IS
      --
      -- To verify events exists in gt table
      --- and identify eligible events to be processed by SLA
      ---
      CURSOR C_entity_event_info ( p_application_id NUMBER) IS
      SELECT XE.entity_id entity_id
      FROM XLA_ENTITY_EVENTS_V XE,PSA_BC_XLA_EVENTS_GT BCE
      WHERE XE.event_id = BCE.event_id
      AND   XE.event_status_code <> 'P'
      AND   XE.application_id = p_application_id
      GROUP BY xe.entity_id;

      -- cursor to set the status code for API
      -- Currently only GT table is used for getting the results status
      -- after the SLA ebncahmcement for BCPSA and funds check code completion this
      -- might change

      CURSOR C_get_status_count IS
      SELECT nvl(sum(decode(upper(result_code),'FATAL',1)),0)  status_fatal_count,
      sum(decode(upper(result_code),'XLA_ERROR',1)) status_xla_err_count,
      sum(decode(upper(result_code),'FAIL',1)) status_fail_count,
      sum(decode(upper(result_code),'PARTIAL',1)) status_partial_count,
      sum(decode(upper(result_code),'ADVISORY',1)) status_advisory_count,
      nvl(sum(decode(upper(result_code),'SUCCESS',1)),0) status_success_count,
      nvl(sum(decode(upper(result_code),'XLA_NO_JOURNAL',1)),0) status_nojournal_count
      FROM PSA_BC_XLA_EVENTS_GT;

      CURSOR c_xla_errors IS
      SELECT 'Y'
      FROM  PSA_BC_XLA_EVENTS_GT a
      WHERE not exists (SELECT 'x'
                        FROM   xla_ae_headers b
                        WHERE  b.event_id = a.event_id);

      -- Cursor c_get_bc_xla_events_gt is used to print data from psa_bc_xla_Events_gt
      -- as entered by product teams. This is useful for debugging.
      CURSOR c_get_bc_xla_events_gt IS
      SELECT *
      FROM   psa_bc_xla_events_gt;

      CURSOR c_get_psa_events IS
      SELECT event_id
      FROM   psa_bc_xla_events_gt;

      CURSOR c_get_xla_acctg_err IS
      SELECT xla_evnt.EVENT_ID,
             xla_evnt.ENTITY_ID,
             xla_evnt.APPLICATION_ID,
             xla_err.AE_HEADER_ID,
             xla_err.AE_LINE_NUM,
             xla_evnt.TRANSACTION_DATE,
             fnd_mesg.MESSAGE_NUMBER,
             fnd_mesg.MESSAGE_NAME,
             xla_err.ENCODED_MSG,
             xla_err.ERROR_SOURCE_CODE,
             xla_evnt.LEDGER_ID,
             xla_evnt.LEGAL_ENTITY_ID,
             xla_evnt.transaction_number DOCUMENT_REFERENCE,
             NULL BATCH_REFERENCE,
             to_char(xla_evnt.event_id) LINE_REFERENCE,
             SYSDATE CREATION_DATE,
             'Y' XLA_ERROR_FLAG
      FROM   psa_bc_xla_events_gt psa_evnt,
             xla_events_gt xla_evnt,
             xla_accounting_errors xla_err,
             fnd_new_messages fnd_mesg
      WHERE  psa_evnt.event_id = xla_evnt.event_id
        AND  xla_evnt.event_id = xla_err.event_id
        AND  fnd_mesg.application_id = 602
        AND  DECODE(xla_err.message_number, 0, -99, xla_err.message_number) = fnd_mesg.message_number (+)
        AND  userenv('LANG') =  fnd_mesg.language_code (+);


      l_entity_event_info    c_entity_event_info%ROWTYPE;
      l_status_count         C_get_status_count%ROWTYPE;
      l_event_source_info    xla_events_pub_pkg.t_event_source_info;
      l_entity_id            NUMBER;
      l_accounting_flag      VARCHAR2(1);
      l_accounting_mode      VARCHAR2(20);
      l_transfer_flag        VARCHAR2(1);
      l_gl_posting_flag      VARCHAR2(1);
      l_offline_flag         VARCHAR2(1);
      l_accounting_batch_id  NUMBER;
      l_errbuf               VARCHAR2(2000);
      l_retcode              NUMBER;
      l_request_id           NUMBER;
      l_application_id       NUMBER;
      l_bc_mode              VARCHAR2(1);
      l_partial_reserve_flag VARCHAR2(1);
      l_override_flag        VARCHAR2(1);
      l_ledger_id            NUMBER;
      l_user_id              NUMBER;
      l_user_resp_id         NUMBER;
      l_path_name            VARCHAR2(500);
      e_event_id_null        EXCEPTION;
      l_accounting_events    BOOLEAN;
      l_run_id               NUMBER;
      l_trx_num              NUMBER;
      l_event_num            NUMBER;
      l_overall_success      BOOLEAN;
      l_count                NUMBER;
      l_index                BINARY_INTEGER := 1;
      l_status               psa_bc_xla_events_gt%ROWTYPE;
      l_xla_error            VARCHAR2(1);
      l_psa_acctg_errors     psa_acctg_errors_table;
      l_psa_events           psa_events_table;
      l_failed_evnt_array    PSA_FUNDS_CHECKER_PKG.num_rec;
      l_r12_upgrade_date     DATE;
      l_error_found          VARCHAR2(1);
      l_event_list           VARCHAR2(1024);

    BEGIN

       --
       -- Start of the budgetary control
       --
       l_path_name := g_path_name || '.Budgetary_Control';
       psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure budgetary_control ' );

       --
       -- Get the parameters values
       --
       psa_utils.debug_other_string(g_state_level,l_path_name, 'Application Id = ' ||p_application_id);
       psa_utils.debug_other_string(g_state_level,l_path_name, 'Budgetary Control Mode = ' ||p_bc_mode);
       psa_utils.debug_other_string(g_state_level,l_path_name, 'Override Flag = ' ||p_override_flag);
       psa_utils.debug_other_string(g_state_level,l_path_name, 'User Id = ' ||p_user_id);
       psa_utils.debug_other_string(g_state_level,l_path_name, 'User Responsibility Id = ' ||p_user_resp_id);

        IF (FND_API.to_boolean(p_init_msg_list)) THEN
            FND_MSG_PUB.initialize;
        END IF;


        --
        -- validate the parameters bc_mode and override flag
        --
        l_bc_mode := p_bc_mode;
        l_override_flag := p_override_flag;
        l_application_id:= p_application_id;
        l_xla_error := 'N';
        psa_utils.debug_other_string(g_state_level,l_path_name,'Start of Parameter Validation');

        --
        -- parameter validations
        --
        IF p_application_id IS NULL THEN
           fnd_message.set_name('PSA','PSA_BC_PARAMETERS_ERROR');
           fnd_message.set_token('PARAM_NAME','Application Id');
           fnd_msg_pub.ADD;
           RAISE Fnd_Api.G_Exc_Error;
        END IF;

        -- Currently the packetid is set to -1 , will change after SLA enhancement for PSA
        x_packet_id := -1;


        IF (l_bc_mode IS  NULL) THEN
            l_bc_mode :=C_FUNDS_CHECK;
        ELSE
          IF (l_bc_mode NOT IN (C_FUNDS_CHECK,C_FUNDS_CHK_FULL,C_FUNDS_RESERVE,C_FUNDS_PARTIAL,C_FUNDS_FORCE_PASS,C_FUNDS_ADVISORY)) THEN
            Fnd_message.set_name('PSA','PSA_BC_PARAMETERS_ERROR');
            Fnd_Message.Set_Token('PARAM_NAME','Funds Mode');
            Fnd_Msg_Pub.ADD;
            psa_utils.debug_other_msg(p_level => g_error_level,
                                      p_full_path => l_path_name,
                                      p_remove_from_stack => FALSE);
            Fnd_file.put_line(fnd_file.log, fnd_message.get);
            RAISE Fnd_Api.G_Exc_Error;
          END IF;
        END IF;

        IF (l_override_flag IS  NULL) THEN
             l_override_flag := C_NO ;
        ELSE
             IF (l_override_flag NOT IN (C_YES,C_NO)) THEN
                 Fnd_message.set_name('PSA','PSA_BC_PARAMETERS_ERROR');
                 Fnd_Message.Set_Token('PARAM_NAME','Override Flag');
                 Fnd_Msg_Pub.ADD;
                 psa_utils.debug_other_msg(p_level => g_error_level,
                                           p_full_path => l_path_name,
                                           p_remove_from_stack => FALSE);
                 Fnd_file.put_line(fnd_file.log, fnd_message.get);

                 RAISE Fnd_Api.G_Exc_Error;
             END IF;
        END IF;

        psa_utils.debug_other_string(g_state_level,l_path_name,'End of Parameter Validation');
        --
        -- Assign the wf parameters to global varibales.
        -- These variables are used by accounitng engine while calling the funds checker
        --
        G_BC_MODE          := l_bc_mode;
        G_OVERRIDE_FLAG    := l_override_flag;
        G_USER_ID          := p_user_id;
        G_USER_RESP_ID     := p_user_resp_id;
        G_APPLICATION_ID   := p_application_id;
        G_PACKET_ID        := Null;
        --
        -- Assign the parameters required for calling SLA Accounting engine
        --
        IF l_bc_mode IN (C_FUNDS_CHECK,C_FUNDS_CHK_FULL) THEN  -- check funds draft mode
           l_accounting_mode := 'FUNDS_CHECK';
           psa_utils.debug_other_string(g_state_level,l_path_name,'Accounting Mode is FUNDS_CHECK');
        ELSE
           l_accounting_mode := 'FUNDS_RESERVE';  -- Reserve Funds in final mode
           psa_utils.debug_other_string(g_state_level,l_path_name,'Accounting Mode is FUNDS_RESERVE');
        END IF;

        l_accounting_flag  := 'Y'; -- Accounting required
        l_transfer_flag    := 'N'; -- No transfer to GL
        l_gl_posting_flag  := 'N'; -- GL Post not required
        l_offline_flag     := 'N'; -- Calling mode for SLA online engine document mode

        --
        -- Get the events information for which funds check required
        -- Get the entity details ,
        --- For each entity id SLA Accounting engine is invoked
        --
        l_accounting_events := FALSE;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_overall_success := TRUE;


        SELECT count(*) INTO l_count
        FROM psa_bc_xla_events_gt;

        IF l_count = 0 THEN
          -- Bug 5474201
          -- There are no events to be processed, returns success as such
          -- procedure should handle such situation gracefully
          IF (l_bc_mode = C_FUNDS_CHECK) THEN
             x_status_code := 'XLA_NO_JOURNAL';
          ELSE
             x_status_code := 'SUCCESS';
          END IF;
          return;
        END IF;

        psa_utils.debug_other_string(g_state_level,l_path_name, 'Number of rows in psa_bc_xla_events_gt table Prior to PA/GMS API ' || l_count );
        psa_xla_error_cleanup;


        BEGIN
          l_r12_upgrade_date :=to_date( Fnd_Profile.Value_Wnps('PSA_R12_UPGRADE_DATE'), 'MM/DD/YYYY HH24:MI:SS');  -- fetch the profile value

          IF l_r12_upgrade_date IS NULL THEN
             x_status_code := 'FATAL';

             fnd_message.set_name('PSA','PSA_XLA_NO_R12_UPG_DATE');
             psa_xla_error('PSA_XLA_NO_R12_UPG_DATE');

             Fnd_message.set_name('PSA','PSA_BC_XLA_ERROR');
             Fnd_Message.Set_Token('PARAM_NAME','Profile PSA: R12 Upgrade Date does not have a value');
             Fnd_Msg_Pub.ADD;

             Raise FND_API.G_EXC_ERROR;
          END IF;
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          WHEN OTHERS THEN
             x_status_code := 'FATAL';

             fnd_message.set_name('PSA','PSA_XLA_INVALID_R12_UPG_DATE');
             psa_xla_error('PSA_XLA_INVALID_R12_UPG_DATE');

             Fnd_message.set_name('PSA','PSA_BC_XLA_ERROR');
             Fnd_Message.Set_Token('PARAM_NAME','Format for Value in Profile PSA: R12 Upgrade Date should be MM/DD/YYYY HH24:MI:SS');
             Fnd_Msg_Pub.ADD;

             Raise FND_API.G_EXC_ERROR;
        END;


        ---------------------------------------------------------------
        -- Calling PA/GMS INTEGRATION API PRIOR TO SLA ONLINE
        ---------------------------------------------------------------

        psa_utils.debug_other_string(g_state_level,l_path_name, 'Now invoking the PA_GMS_INTEGRATION_API' );
        pa_gms_integration_api;

        SELECT count(*) INTO l_count
        FROM psa_bc_xla_events_gt;

        psa_utils.debug_other_string(g_state_level,l_path_name, 'Number of rows in  psa_bc_xla_events_gt table after invoking PA/GMS API ' || l_count );

        IF l_count < 1 THEN

             x_status_code := 'FATAL';
             Fnd_message.set_name('PSA','PSA_BC_XLA_ERROR');
             Fnd_Message.Set_Token('PARAM_NAME','No Events to be processed');
             Fnd_Msg_Pub.ADD;
             Raise FND_API.G_EXC_ERROR;

        END IF;

        --
        -- Update the PSA_BC_XLA_EVENTS_GT event records to be in 'XLA_UNPROCESSED' status
        --
        UPDATE psa_bc_xla_events_gt
        SET result_code = 'XLA_UNPROCESSED';
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows updated of psa_bc_xla_events_gt: ' || SQL%ROWCOUNT);





        ----------------------------------------------------------------------
        -- clear the XLA_ACCT_PROG_EVENTS_GT table before inserting any rows
        ----------------------------------------------------------------------

        psa_cleanup_gt;

        /* ---- 7460759 ---------------------------------------------------------------------------
        DELETE from XLA_ACCT_PROG_EVENTS_GT;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from XLA_ACCT_PROG_EVENTS_GT table before insertion: ' || SQL%ROWCOUNT );
        DELETE from xla_ae_headers_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from xla_ae_headers_gt table before insertion: ' || SQL%ROWCOUNT);
        DELETE from xla_ae_lines_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from xla_ae_lines_gt table before insertion: ' || SQL%ROWCOUNT);
        DELETE from xla_validation_lines_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from xla_validation_lines_gt table before insertion: ' || SQL%ROWCOUNT);
        DELETE from xla_evt_class_orders_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from xla_evt_class_orders_gt; table before insertion: ' || SQL%ROWCOUNT);
*/
        DELETE from psa_option_details_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from psa_option_details_gt table before insertion: ' || SQL%ROWCOUNT);
        DELETE from psa_bc_alloc_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows deleted from psa_bc_alloc_gt table before insertion: ' || SQL%ROWCOUNT);
    ------------------------------------------------------------------------------------- *

     -- Insert rows to XLA Events GT table and Call Accounting Engine
     -----------------------------------------------------------------

        INSERT into XLA_ACCT_PROG_EVENTS_GT (Event_Id)
        SELECT event_id FROM psa_bc_xla_events_gt;
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Number of rows in inserted into XLA_ACCT_PROG_EVENTS_GT table: ' || SQL%ROWCOUNT );

        l_accounting_events   := TRUE;
        l_accounting_batch_id := NULL;
        l_errbuf              := NULL;
        l_retcode             := NULL;
        l_request_id          := NULL;

        psa_utils.debug_other_string(g_state_level,l_path_name, 'PSA_BC_XLA_EVENTS_GT');
        psa_utils.debug_other_string(g_state_level,l_path_name, '=====================');

        FOR x in c_get_bc_xla_events_gt
        LOOP
            psa_utils.debug_other_string(g_state_level,l_path_name, 'EVENT_ID = '||x.event_id);
            psa_utils.debug_other_string(g_state_level,l_path_name, 'RESULT_CODE = '||x.result_code);
        END LOOP;

        ----------------------------------------------------------------
        -- Calling SLA online accounting engine API
        ----------------------------------------------------------------
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Calling API xla_accounting_pub_pkg.accounting_program_events');
        xla_accounting_pub_pkg.accounting_program_events
                    ( p_application_id        => P_application_id
                     ,p_accounting_mode      => l_accounting_mode
                     ,p_gl_posting_flag      => l_gl_posting_flag
                     ,p_accounting_batch_id  => l_accounting_batch_id
                     ,p_errbuf               => l_errbuf
                     ,p_retcode              => l_retcode
                     );

         psa_utils.debug_other_string(g_state_level,l_path_name,  'Return Code = ' || l_retcode);
         psa_utils.debug_other_string(g_state_level,l_path_name,  'l_errbuf = '  ||l_errbuf );
         psa_utils.debug_other_string(g_state_level,l_path_name,  'Accounting Batch id = '  ||l_accounting_batch_id );

         -- Get psa_bc_xla_events_gt events
         OPEN c_get_psa_events;
         FETCH c_get_psa_events BULK COLLECT INTO l_psa_events;
         CLOSE c_get_psa_events;

         -- Fetch error records from XLA tables
         OPEN c_get_xla_acctg_err;
         FETCH c_get_xla_acctg_err BULK COLLECT INTO l_psa_acctg_errors;
         CLOSE c_get_xla_acctg_err;

         -- Delete/Save errors records from/into PSA BC accounting errors table
         psa_acctg_errors_insert(l_psa_events,l_psa_acctg_errors);

         IF  l_retcode = 2 THEN
               psa_utils.debug_other_string(g_state_level,l_path_name, 'ERROR returned in SLA Accounting Engine API');
               l_overall_success := FALSE;
               --Fnd_message.set_name('PSA','PSA_BC_XLA_ERROR');
               --Fnd_Message.Set_Token('PARAM_NAME',l_errbuf);
               --Fnd_Msg_Pub.ADD;
               -- update the psa_bc_xla_events_gt event records to
               -- XLA_ERROR status
               UPDATE psa_bc_xla_events_gt
               SET result_code = 'XLA_ERROR';
               psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows updated of psa_bc_xla_events_gt: ' || SQL%ROWCOUNT);
               -- set the status code
               x_status_code := 'XLA_ERROR';
               copy_xla_error (l_error_found);
               IF (l_error_found = 'N') THEN
                 try_to_interpret_xla_error;
               END IF;
         ELSE
               psa_utils.debug_other_string(g_state_level,l_path_name,'Events processed by SLA Accounting Engine');

               --
               -- Update the PSA_BC_XLA_EVENTS_GT event records to be in 'XLA_NO_JOURNAL' status
               -- for events that remain in XLA_UNPROCESSED status
               --

               IF l_retcode = 0 THEN
                 UPDATE psa_bc_xla_events_gt
                 SET result_code = 'XLA_NO_JOURNAL'
                 WHERE result_code = 'XLA_UNPROCESSED';
                 psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows updated of psa_bc_xla_events_gt: ' || SQL%ROWCOUNT);
               END IF;

               IF l_retcode = 1 THEN
                  copy_xla_error (l_error_found);
                  OPEN c_xla_errors;
                  FETCH c_xla_errors INTO l_xla_error;
                  CLOSE c_xla_errors;

                  IF (l_xla_error = 'Y') THEN
                      x_status_code := 'XLA_ERROR';

                      UPDATE psa_bc_xla_events_gt
                      SET result_code = 'XLA_ERROR';
                      psa_utils.debug_other_string(g_state_level,l_path_name,'Number of rows updated of psa_bc_xla_events_gt: ' || SQL%ROWCOUNT);
                  END IF;
               END IF;

               -- Intialize status code to Success
               x_status_code := 'SUCCESS';

               --dumping the psa_bc_xla_events_gt eventid/result_code
               psa_utils.debug_other_string(g_state_level,l_path_name,'Dump of psa_bc_xla_events_gt');
               FOR x IN (SELECT * FROM psa_bc_xla_events_gt) LOOP
                   psa_utils.debug_other_string(g_state_level,l_path_name,
                     'PSA gt event_id'|| x.event_id || 'PSA gt result_code' || x.result_code);
               END LOOP;

               -- set the status code of the gt table
               -- Currently only GT table is used for getting the results status
               -- after the SLA enhancement for BCPSA and funds check code completion this
               -- might change
               open C_get_status_count;
               Fetch C_get_status_count into l_status_count;
               Close C_get_status_count;

               IF (l_status_count.status_nojournal_count > 0) THEN
                   x_status_code := 'XLA_NO_JOURNAL';
                   IF (l_status_count.status_success_count > 0) THEN
                      x_status_code := 'PARTIAL';
                   END IF;

                   FOR event_list_rec IN (SELECT *
                                              FROM PSA_BC_XLA_EVENTS_GT
                                             WHERE upper(result_code) = 'XLA_NO_JOURNAL') LOOP
                     fnd_message.set_name ('PSA','PSA_XLA_NO_JOURNAL');
                     psa_utils.debug_other_string(g_state_level,l_path_name, 'Calling psa_xla_error');
                     psa_xla_error
                     (
                       p_message_code => 'PSA_XLA_NO_JOURNAL',
                       p_event_id     => event_list_rec.event_id
                     );
                   END LOOP;
               ELSIF (l_status_count.status_fatal_count > 0 ) THEN
                   x_status_code := 'FATAL';
               ELSIF (l_status_count.status_partial_count > 0 ) THEN
                   x_status_code := 'PARTIAL';
               ELSIF (l_status_count.status_xla_err_count > 0 ) THEN
                   x_status_code := 'XLA_ERROR';
                   IF (l_status_count.status_success_count > 0) THEN
                      x_status_code := 'PARTIAL';
                   END IF;
               ELSIF (l_status_count.status_fail_count > 0 ) THEN
                      x_status_code := 'FAIL';
                  IF (l_bc_mode IN (C_FUNDS_CHECK, C_FUNDS_PARTIAL)) AND (l_status_count.status_success_count > 0) THEN
                      x_status_code := 'PARTIAL';
                  END IF;
               ELSIF (l_status_count.status_advisory_count > 0 ) THEN
                      x_status_code := 'ADVISORY';
               ELSE
                      x_status_code := 'SUCCESS';
               END IF;  -- advisory


         END IF;
              psa_utils.debug_other_string(g_state_level,l_path_name,  'Status Code= '||x_status_code);
         ----------------------------------------------------
         -- packet id will returned from gl_bc_packets
         -- if more than one event per call of BC API
         -- first packet id will be returned
         ------------------------------------------------------
         x_Packet_ID:= g_packet_id;

         -----------------------------------------------------
         -- Initialize the collection variables
         -----------------------------------------------------
         l_failed_evnt_array := PSA_FUNDS_CHECKER_PKG.num_rec();

         -----------------------------------------------------
         -- Store event ids and ledger id which are used later
         -- for roll back if CBC funds check call fails
         -----------------------------------------------------
         OPEN c_get_psa_events;
         FETCH c_get_psa_events BULK COLLECT INTO l_failed_evnt_array;
         CLOSE c_get_psa_events;

         -----------------------------------------------------
         -- Check if CBC is enabled and
         -- call CBC API with reserve mode or funds check mode
         -- based on value of x_status_code. If call to CBC API
         -- fails in reserve mode, SBC funds check changes
         -- will also be rolled back.
         -----------------------------------------------------
         IF p_application_id = 201 AND IGI_GEN.is_req_installed('CBC') = TRUE THEN
            psa_utils.debug_other_string(g_state_level,l_path_name,  'CBC Installed');

            IF (x_status_code IN('SUCCESS','ADVISORY')) THEN
               x_return_status := IGC_CBC_GL_FC_PKG.glzcbc(p_mode => p_bc_mode, p_conc_proc => FND_API.G_FALSE);

               IF x_return_status <> 1 THEN
                  IF x_return_status = -1 THEN
                     x_status_code := 'XLA_ERROR';
                  ELSIF x_return_status = 0 THEN
                     x_status_code := 'FAIL';
                  END IF;
                  psa_funds_checker_pkg.sync_xla_errors(p_failed_ldgr_array => null, p_failed_evnt_array => l_failed_evnt_array);
               END IF;

            ELSIF x_status_code IN('FAIL','PARTIAL') THEN
               x_return_status := IGC_CBC_GL_FC_PKG.glzcbc(p_mode => 'M', p_conc_proc => FND_API.G_FALSE);
            END IF;

         END IF;

         ------------------------------------------------------
         -- Calling PA/GMS Tieback API's in case of Errors
         ------------------------------------------------------

         IF (x_status_code IN('FATAL','XLA_ERROR', 'XLA_NO_JOURNAL')) THEN
           psa_utils.debug_other_string(g_state_level,l_path_name,  'Calling pa_gms_tieback_api');
           pa_gms_tieback_api;
         END IF;
         psa_utils.debug_other_string(g_state_level,l_path_name, 'END of procedure budgetary_control ' );

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(p_encoded => FND_API.G_FALSE
                                ,p_count => x_msg_count
                               ,p_data  => x_msg_data);
      psa_utils.debug_other_string(g_error_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_error_level,l_path_name,'Error in budgetary_control Procedure' );
      pa_gms_tieback_api;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      psa_utils.debug_other_string(g_unexp_level,l_path_name, 'Unexpected Error'|| sqlerrm);
      FND_MSG_PUB.count_and_get(p_encoded => FND_API.G_FALSE
                                ,p_count => x_msg_count
                               ,p_data  => x_msg_data);

     psa_utils.debug_other_string(g_unexp_level,l_path_name,'ERROR: Unexpected Error in budgetary_control Procedure' );
     pa_gms_tieback_api;
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, 'PSA_BC_XLA_PVT');
      END IF;
      psa_utils.debug_unexpected_msg(G_PKG_NAME);
       FND_MSG_PUB.count_and_get(p_encoded => FND_API.G_FALSE
                                ,p_count => x_msg_count
                               ,p_data  => x_msg_data);
      psa_utils.debug_other_string(g_excep_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_excep_level,l_path_name,'Error in budgetary_control Procedure' );
      pa_gms_tieback_api;

END Budgetary_Control;


-- /*============================================================================
 -- API name     : get_sla_notupgraded_flag
 -- Type         : private
 -- Pre-reqs     : None
 -- Description  : Returns Y/N depending on whether the distribution passed is notupgraded
 --
 --  Parameters  :
 --  IN          :
 --                  p_application_id   IN NUMBER        Applied to Application ID
 --                  p_entity_code              IN VARCHAR2      Applied to Entity code
 --                  p_source_id_int_1  IN NUMBER        Applied to Header ID
 --                  p_dist_link_type   IN VARCHAR2      Applied to Dist Link Type
 --                  p_distribution_id  IN NUMBER        Applied to Distribution ID
 --
 --  Returns     :   VARCHAR2 i.e., Y/N
 --
 --  Logic
 --        - If the transaction was created in transaction tables after R12 upgrade,
 --             return N
 --        - Else
 --             If the distribution was accounted in xla
 --                 return N;
 --             Else
 --                 return Y;
 --
 --  Notes:
 --         This is called from transaction objects and the return value is
 --         populated into a column that will be mapped to Upgrade option acct attrib
 --         in SLA.
 --
 --  Modification History
 --  Date               Author             Description of Change
 --  27-Oct-2005    Venkatesh N             Created
 -- *===========================================================================
FUNCTION get_sla_notupgraded_flag (     p_application_id        IN NUMBER,
                                        p_entity_code           IN VARCHAR2,
                                        p_source_id_int_1       IN NUMBER,
                                        p_dist_link_type        IN VARCHAR2,
                                        p_distribution_id   IN NUMBER) RETURN VARCHAR2 IS
    l_dist_creation_date    DATE;
    l_r12_upgrade_date      DATE;
    l_check_variable        VARCHAR2(1) := '0';
    l_return_val            VARCHAR2(1);
    l_acctd_cr              NUMBER;
    l_acctd_dr              NUMBER;
    l_event_type_code       xla_events.event_type_code%TYPE;

    l_path_name            VARCHAR2(500);

    CURSOR c_check( cp_appl_id NUMBER,
                    cp_entity_code VARCHAR2,
                    cp_source_id_int_1  NUMBER,
                    cp_source_dist_type VARCHAR2,
                    cp_source_dist_id_num_1 NUMBER) IS
            SELECT '1'
            FROM    xla_transaction_entities xte,
                    xla_ae_headers           xah,
                    xla_distribution_links   xdl,
                    xla_events               xe
            WHERE   xte.application_id      = cp_appl_id
                AND xte.entity_code         = cp_entity_code
                AND xte.source_id_int_1     = cp_source_id_int_1
                AND xte.entity_id           = xah.entity_id
                AND xah.event_id            = xdl.event_id
                AND xdl.source_distribution_type    = cp_source_dist_type
                AND xdl.source_distribution_id_num_1 = cp_source_dist_id_num_1
                AND xah.event_id            = xe.event_id
                AND xe.budgetary_control_flag = 'Y';

    --Cursor introduced for Bug 7598349
    CURSOR c_po_upg_chk(cp_appl_id NUMBER,
                        cp_entity_code VARCHAR2,
                        cp_source_id_int_1 NUMBER,
                        cp_source_dist_type VARCHAR2,
                        cp_source_dist_id_num_1 NUMBER) IS
            SELECT NVL(xdl.unrounded_accounted_dr, 0), NVL(xdl.unrounded_accounted_cr, 0),
                   xe.event_type_code
            FROM    xla_transaction_entities xte,
                    xla_ae_headers           xah,
                    xla_events               xe,
                    xla_distribution_links   xdl
            WHERE   xte.application_id      = cp_appl_id
                AND xte.entity_code         = cp_entity_code
                AND xte.source_id_int_1     = cp_source_id_int_1
                AND xte.entity_id           = xah.entity_id
                AND xah.event_id            = xe.event_id
                AND xdl.ae_header_id        = xah.ae_header_id
                AND xah.application_id      = cp_appl_id
                AND xe.budgetary_control_flag = 'Y'
                AND xdl.source_distribution_type     = cp_source_dist_type
                AND xdl.source_distribution_id_num_1 = cp_source_dist_id_num_1
           ORDER BY xe.event_id DESC;
BEGIN

    l_path_name := g_path_name || '.get_sla_notupgraded_flag';
    psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of function get_sla_notupgraded_flag' );

    psa_utils.debug_other_string(g_state_level,l_path_name,'Fetch PSA: R12 Upgrade Date profile value');

    l_r12_upgrade_date :=to_date( Fnd_Profile.Value_Wnps('PSA_R12_UPGRADE_DATE'), 'MM/DD/YYYY HH24:MI:SS');  -- fetch the profile value

    IF l_r12_upgrade_date IS NULL THEN
        psa_utils.debug_other_string(g_state_level,l_path_name,'Profile value does not contain a value');
        psa_utils.debug_other_string(g_state_level,l_path_name,'Please check whether psar12upg.sql script was run');
        RAISE Fnd_Api.G_Exc_Error;
    END IF;

    psa_utils.debug_other_string(g_state_level,l_path_name,'Profile value = ' || to_char(l_r12_upgrade_date));

    psa_utils.debug_other_string(g_state_level,l_path_name,'Fetch CREATION_DATE of the Distribution '|| p_distribution_id);

    IF p_dist_link_type = 'PO_REQ_DISTRIBUTIONS_ALL' THEN
        SELECT min(creation_date) INTO l_dist_creation_date
        FROM po_req_distributions_all
        WHERE distribution_id = p_distribution_id;
    ELSIF p_dist_link_type = 'PO_DISTRIBUTIONS_ALL' THEN
        SELECT min(creation_date) INTO l_dist_creation_date
       FROM po_distributions_all
        WHERE po_distribution_id = p_distribution_id;
    ELSIF p_dist_link_type = 'AP_INV_DIST' THEN
        SELECT min(creation_date) INTO l_dist_creation_date
        FROM ap_invoice_distributions_all
        WHERE invoice_distribution_id = p_distribution_id;
    ELSE
        psa_utils.debug_other_string(g_state_level,l_path_name,'Invalid Distribution Link Type'|| p_dist_link_type);
        RAISE Fnd_Api.G_Exc_Error;
    END IF;

    psa_utils.debug_other_string(g_state_level,l_path_name,'Distribution CREATION_DATE = ' || to_char(l_dist_creation_date));

    IF (p_dist_link_type <>  'PO_DISTRIBUTIONS_ALL') then
	    if (l_dist_creation_date > l_r12_upgrade_date) OR (l_dist_creation_date IS NULL) THEN
           l_return_val := 'N';
		End if;
    END IF;
	--IF (p_dist_link_type ='PO_DISTRIBUTIONS_ALL' OR l_dist_creation_date <= l_r12_upgrade_date) THEN
	IF (l_dist_creation_date <= l_r12_upgrade_date) THEN
        OPEN c_check(p_application_id,
                    p_entity_code,
                    p_source_id_int_1,
                    p_dist_link_type,
                    p_distribution_id);
        FETCH c_check INTO l_check_variable;
        CLOSE c_check;

        IF l_check_variable ='1' THEN
           -- Following IF added for Bug 7598349
           IF (p_dist_link_type = 'PO_DISTRIBUTIONS_ALL' ) THEN
              OPEN c_po_upg_chk(p_application_id,
                                 p_entity_code,
                                 p_source_id_int_1,
                                 p_dist_link_type,
                                 p_distribution_id);
               FETCH c_po_upg_chk into l_acctd_dr, l_acctd_cr, l_event_type_code;
               CLOSE c_po_upg_chk;
               IF (l_acctd_dr = 0) AND (l_acctd_cr = 0) AND (l_event_type_code = 'PO_PA_FINAL_CLOSED')then
                  l_return_val := 'Y';
               ELSE
                  l_return_val := 'N';
               END IF;
           ELSE
               l_return_val := 'N';    --this means data exists in sla and is a R12 entry
           END IF; -- p_dist_link_type = 'PO_DISTRIBUTIONS_ALL' inner
        ELSE   -- if l_check_variable
            IF FV_INSTALL.ENABLED THEN
                l_return_val := 'O';    --Make use of Upgrade tab in JLD form
            ELSE
                l_return_val := 'Y';            --this means data exists in 11i only
            END IF;
        END IF; -- if l_check_variable
	END IF;  --  if P_dist_link_type outer

    psa_utils.debug_other_string(g_state_level,l_path_name,'Return Value = ' || l_return_val);
    psa_utils.debug_other_string(g_state_level,l_path_name,'END of function get_sla_notupgraded_flag' || l_path_name);
    RETURN l_return_val;
EXCEPTION
        WHEN others THEN
              psa_utils.debug_other_string(g_excep_level,l_path_name,'Error in function get_sla_notupgraded_flag' );
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_sla_notupgraded_flag;

-- PA_GMS_INTEGRATION_API
-- Created By : Tushar Pradhan
-- Description: PA/GMS teams provided us with their APIs which we should invoke prior to calling the
--              XLA accounting package. These integration API's are invoked using this API.
--              Since the requirement demands that XLA accounting should not be invoked if this API fails,
--              the same is incorporated.
--

PROCEDURE pa_gms_integration_api IS

  l_path_name         VARCHAR2(500);
  l_partial_resv_flag VARCHAR2(1);
  l_pa_status         VARCHAR2(1);
  l_pa_enabled        INTEGER;
  l_gms_status        VARCHAR2(1);
  l_gms_enabled       INTEGER;
  l_prepare_stmt      VARCHAR2(2000);
  l_ret_code          VARCHAR2(100);
  l_bc_mode           VARCHAR2(1);
  l_industry          fnd_profile_option_values.profile_option_value%TYPE;

BEGIN

  l_path_name := g_path_name||'.pa_gms_integration_api';

  psa_utils.debug_other_string(g_state_level,l_path_name, 'pa_gms_integration_api invoked');
  psa_utils.debug_other_string(g_state_level,l_path_name, 'Invoke PA Integration API if PA is enabled');

  IF g_bc_mode ='C' THEN
     l_partial_resv_flag := 'Y';
     l_bc_mode := 'C';
  ELSIF g_bc_mode = 'P' THEN
     l_partial_resv_flag := 'Y';
     l_bc_mode := 'R';
  ELSE
     l_bc_mode := g_bc_mode;
     l_partial_resv_flag := 'N';
  END IF;

  psa_utils.debug_other_string(g_state_level,l_path_name, ' l_partial_resv_flag -> '||l_partial_resv_flag);

  BEGIN
     l_industry     := NULL;
     l_prepare_stmt := NULL;
     l_pa_status    := 'N';

       IF FND_INSTALLATION.GET(275, 275, l_pa_status, l_industry) THEN

          IF l_pa_status ='I' THEN

            l_pa_enabled := 0;
            l_prepare_stmt := 'BEGIN IF PA_BUDGET_FUND_PKG.IS_PA_BC_ENABLED() THEN'||' :1 := 1; END IF; END;';

            psa_utils.debug_other_string(g_state_level,l_path_name, ' Statement prepared -> '||l_prepare_stmt);

            EXECUTE IMMEDIATE l_prepare_stmt USING OUT l_pa_enabled;

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_pa_enabled -> '||l_pa_enabled);

            IF l_pa_enabled = 1 THEN

               l_prepare_stmt := ' BEGIN '||
                                 ' PA_FUNDS_CONTROL_PKG1.CREATE_PROJ_ENCUMBRANCE_EVENTS ('||
                                 ' :application_id, :partial_resv_flag, :bc_mode, :ret_code); '||
                                 ' END; ';

               EXECUTE IMMEDIATE l_prepare_stmt USING IN g_application_id,
                                                      IN l_partial_resv_flag,
                                                      IN l_bc_mode,
                                                      OUT l_ret_code;
               IF (l_ret_code = 'F') THEN
                  psa_utils.debug_other_string(g_error_level,l_path_name, 'PA Integration API Failed');
                  FND_MESSAGE.SET_NAME('PA', 'PA_BC_FUND_CHK_FAIL');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  psa_utils.debug_other_string(g_state_level,l_path_name, 'PA Integration API Successful');
               END IF;

            END IF;
          END IF;
       END IF;

  END;

  psa_utils.debug_other_string(g_state_level,l_path_name, 'Invoke GMS Integration API if GMS is enabled');
  l_ret_code := NULL;

  BEGIN
     l_industry     := NULL;
     l_prepare_stmt := NULL;
     l_gms_status    := 'N';

       IF FND_INSTALLATION.GET(8402, 8402, l_gms_status, l_industry) THEN

          IF l_gms_status ='I' THEN

            l_gms_enabled := 0;
            l_prepare_stmt := 'BEGIN IF GMS_INSTALL.ENABLED() THEN'||' :1 := 1; END IF; END;';

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_prepare_stmt -> '||l_prepare_stmt);

            EXECUTE IMMEDIATE l_prepare_stmt USING OUT l_gms_enabled;

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_gms_enabled -> '||l_gms_enabled);

            IF l_gms_enabled = 1 THEN

            l_prepare_stmt :=    ' BEGIN '||
                                 ' GMS_FUNDS_CONTROL_PKG.COPY_GL_PKT_TO_GMS_PKT ( '||
                                 ' :application_id, :mode, :partial_resv_flag, :ret_code); '||
                                 ' END; ';
             psa_utils.debug_other_string(g_state_level,l_path_name, ' l_prepare_stmt -> '||l_prepare_stmt);
             EXECUTE IMMEDIATE l_prepare_stmt USING   IN g_application_id,
                                                      IN l_bc_mode,
                                                      IN l_partial_resv_flag,
                                                      OUT l_ret_code;
               IF (l_ret_code = 'F') THEN
                  psa_utils.debug_other_string(g_state_level,l_path_name, 'GMS Integration API Failed');
                  FND_MESSAGE.SET_NAME('GMS', 'GMS_FUNDS_CHECK_FAILED');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  psa_utils.debug_other_string(g_state_level,l_path_name, 'GMS Integration API Successful');
               END IF;

            END IF;
          END IF;
       END IF;

  END;
  EXCEPTION
            WHEN others THEN
                  psa_utils.debug_other_string(g_excep_level,l_path_name,'Error in pa_gms_integration_api' );
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END pa_gms_integration_api;

PROCEDURE pa_gms_tieback_api IS

  l_path_name         VARCHAR2(500);
  l_pa_status         VARCHAR2(1);
  l_pa_enabled        INTEGER;
  l_gms_status        VARCHAR2(1);
  l_gms_enabled       INTEGER;
  l_prepare_stmt      VARCHAR2(2000);
  l_industry          fnd_profile_option_values.profile_option_value%TYPE;
  l_bc_mode           VARCHAR2(1);

BEGIN
  l_path_name := g_path_name||'.pa_gms_tieback_api';
  psa_utils.debug_other_string(g_state_level,l_path_name, 'PA_GMS_TIEBACK_API Invoked');

  psa_utils.debug_other_string(g_state_level,l_path_name, 'Invoke PA Tieback API if PA is enabled');

  IF g_bc_mode = 'C' THEN
   l_bc_mode := 'C';
  ELSIF g_bc_mode ='P' THEN
   l_bc_mode := 'R';
  ELSE
   l_bc_mode := g_bc_mode;
   END IF;

  BEGIN
     l_industry     := NULL;
     l_prepare_stmt := NULL;
     l_pa_status    := 'N';

     IF FND_INSTALLATION.GET(275, 275, l_pa_status, l_industry) THEN

          IF l_pa_status ='I' THEN

            l_pa_enabled := 0;
            l_prepare_stmt := 'BEGIN IF PA_BUDGET_FUND_PKG.IS_PA_BC_ENABLED() THEN'||' :1 := 1; END IF; END;';

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_prepare_stmt -> '||l_prepare_stmt);

            EXECUTE IMMEDIATE l_prepare_stmt USING OUT l_pa_enabled;

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_pa_enabled -> '||l_pa_enabled);

            IF l_pa_enabled = 1 THEN

               l_prepare_stmt := ' BEGIN '||
                                 ' PA_FUNDS_CONTROL_PKG1.TIEBACK_FAILED_ACCT_STATUS( '||':bc_mode );'||
                                 ' END; ';
               psa_utils.debug_other_string(g_state_level,l_path_name, ' l_pa_enabled -> '||l_pa_enabled);
               EXECUTE IMMEDIATE l_prepare_stmt USING IN l_bc_mode;

               psa_utils.debug_other_string(g_state_level,l_path_name, 'PA Tieback API Successful');

            END IF;
          END IF;
       END IF;

  END;

  psa_utils.debug_other_string(g_state_level,l_path_name, 'Invoke GMS Tieback API if GMS is enabled');

  BEGIN
     l_industry     := NULL;
     l_prepare_stmt := NULL;
     l_gms_status    := 'N';

       IF FND_INSTALLATION.GET(8402, 8402, l_gms_status, l_industry) THEN

          IF l_gms_status ='I' THEN

            l_gms_enabled := 0;
            l_prepare_stmt := 'BEGIN IF GMS_INSTALL.ENABLED() THEN'||' :1 := 1; END IF; END;';

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_prepare_stmt -> '||l_prepare_stmt);

            EXECUTE IMMEDIATE l_prepare_stmt USING OUT l_gms_enabled;

            psa_utils.debug_other_string(g_state_level,l_path_name, ' l_gms_enabled -> '||l_gms_enabled);

            IF l_gms_enabled = 1 THEN

               l_prepare_stmt := ' BEGIN '||
                                 ' GMS_FUNDS_CONTROL_PKG.TIEBACK_FAILED_ACCT_STATUS( '||':bc_mode );'||
                                 ' END; ';
               psa_utils.debug_other_string(g_state_level,l_path_name, ' l_prepare_stmt -> '||l_prepare_stmt);
               EXECUTE IMMEDIATE l_prepare_stmt USING IN l_bc_mode;

               psa_utils.debug_other_string(g_state_level,l_path_name, 'GMS Tieback API Successful');

            END IF;
          END IF;
       END IF;

  END;
  EXCEPTION
     WHEN others THEN
     psa_utils.debug_other_string(g_excep_level,l_path_name,'Error in pa_gms_tieback_api' );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END pa_gms_tieback_api;

-----------------------------------------

procedure psa_cleanup_gt IS
l_path_name varchar2(300) ;
BEGIN
l_path_name := g_path_name || '.psa_cleanup_gt';

  psa_utils.debug_other_string(g_state_level,l_path_name,'Cleaning up xla GT Tables');
  DELETE FROM XLA_AE_HEADERS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '1 XLA_AE_HEADERS_GT : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_AE_LINES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '2 XLA_AE_LINES_GT : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_VALIDATION_HDRS_GT;
psa_utils.debug_other_string(g_state_level,l_path_name, '3 XLA_VALIDATION_HDRS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_VALIDATION_LINES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '4 XLA_VALIDATION_LINES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_CTRL_CTRBS_GT;
psa_utils.debug_other_string(g_state_level,l_path_name, '5 XLA_BAL_CTRL_CTRBS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_PERIOD_STATS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '6 XLA_BAL_PERIOD_STATS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_RECREATE_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '7 XLA_BAL_RECREATE_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_ANACRI_LINES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '8 XLA_BAL_ANACRI_LINES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_ANACRI_CTRBS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '9 XLA_BAL_ANACRI_CTRBS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_SYNCHRONIZE_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '10 XLA_BAL_SYNCHRONIZE_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_STATUSES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '11 XLA_BAL_STATUSES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_CTRL_LINES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '12 XLA_BAL_CTRL_LINES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVENTS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '13 XLA_EVENTS_GT : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVT_CLASS_SOURCES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '14 XLA_EVT_CLASS_SOURCES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVT_CLASS_ORDERS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '15 XLA_EVT_CLASS_ORDERS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TAB_ERRORS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '16 XLA_TAB_ERRORS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_SEQ_JE_HEADERS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '17 XLA_SEQ_JE_HEADERS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TAB_NEW_CCIDS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '18 XLA_TAB_NEW_CCIDS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EXTRACT_OBJECTS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '19 XLA_EXTRACT_OBJECTS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_REFERENCE_OBJECTS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '20 XLA_REFERENCE_OBJECTS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TRANSACTION_ACCTS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '21 XLA_TRANSACTION_ACCTS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_UPG_LINE_CRITERIA_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '22 XLA_UPG_LINE_CRITERIA_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TRIAL_BALANCES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '23 XLA_TRIAL_BALANCES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_ACCT_PROG_EVENTS_GT; psa_utils.debug_other_string(g_state_level,l_path_name, '24 XLA_ACCT_PROG_EVENTS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_ACCT_PROG_DOCS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '25 XLA_ACCT_PROG_DOCS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_MERGE_SEG_MAPS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '26 XLA_MERGE_SEG_MAPS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_EVENTS_INT_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '27 XLA_EVENTS_INT_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_REPORT_BALANCES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '28 XLA_REPORT_BALANCES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_TB_BALANCES_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '29 XLA_TB_BALANCES_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  DELETE FROM XLA_BAL_AC_CTRBS_GT;
    psa_utils.debug_other_string(g_state_level,l_path_name, '30 XLA_BAL_AC_CTRBS_GT    : Deleted Row count :'||SQL%ROWCOUNT);
  psa_utils.debug_other_string(g_state_level,l_path_name,'clean_xla_gt -');
END psa_cleanup_gt;


----------------------------------------------------- --------------------------------------------------
BEGIN
         g_log_enabled    := fnd_log.test
                            (log_level  => FND_LOG.G_CURRENT_RUNTIME_LEVEL
                            ,MODULE     => g_path_name);
init;
END PSA_BC_XLA_PVT;

/

--------------------------------------------------------
--  DDL for Package Body PSA_SLA_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_SLA_PROCESSING_PKG" AS
--$Header: psaxlacb.pls 120.0.12010000.3 2010/01/22 16:15:09 sasukuma ship $
---------------------------------------------------------------------------

g_path_name   CONSTANT VARCHAR2(200)  :=
'psa.plsql.psaxlacb.psa_sla_processing_pkg';
g_state_level NUMBER                  :=   FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER                  :=   FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER                  :=   FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER                  :=   FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER                  :=   FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER                  :=   FND_LOG.LEVEL_UNEXPECTED;
g_log_level   CONSTANT NUMBER         :=   FND_LOG.G_CURRENT_RUNTIME_LEVEL;


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
) IS

Begin
    Null;
End;




PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
) IS

Begin
    Null;
End;




  PROCEDURE postprocessing
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
   IS
     l_path_name VARCHAR2(1024);
   BEGIN
      l_path_name := g_path_name || '.postprocessing';
      psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure postprocessing ' );
      IF (p_application_id NOT IN (200, 707)) THEN
        RETURN;
      END IF;

      IF (p_accounting_mode <> 'F') THEN
        RETURN;
      END IF;

      UPDATE xla_ae_headers ae1
         SET funds_status_code = 'S'
       WHERE EXISTS (SELECT 'x'
                       FROM xla_events_gt e,
                            gl_ledgers l
                      WHERE e.application_id = p_application_id
                        AND e.process_status_code = 'P'
                        AND ae1.event_id = e.event_id
                        AND e.ledger_id = ae1.ledger_id
                        AND e.ledger_id = l.ledger_id
                        AND e.budgetary_control_flag = 'N'
                        AND l.enable_budgetary_control_flag = 'Y');

      psa_utils.debug_other_string(g_state_level,l_path_name, 'Updated '||SQL%ROWCOUNT||' rows.' );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      psa_utils.debug_other_string(g_excep_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
    WHEN OTHERS THEN
      psa_utils.debug_other_string(g_excep_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      RAISE;
  End;




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

 Begin
    Null;
End;


END psa_sla_processing_pkg; -- Package spec


/

--------------------------------------------------------
--  DDL for Package Body FV_SLA_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_PROCESSING_PKG" AS
--$Header: FVXLAACB.pls 120.33.12010000.35 2010/03/24 19:40:20 sasukuma ship $
  --==========================================================================
  ----Logging Declarations
  --==========================================================================
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER       :=  FND_LOG.LEVEL_PROCEDURE;
  C_EVENT_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EVENT;
  C_EXCEP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EXCEPTION;
  C_ERROR_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_ERROR;
  C_UNEXP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_UNEXPECTED;
  g_log_level   CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_path_name   CONSTANT VARCHAR2(40)  := 'fv.plsql.fvxlaacb.fv_sla_processing_pkg';
  --
  -- Linefeed character
  --
  CRLF          CONSTANT VARCHAR2(1) := FND_GLOBAL.newline;


  PROCEDURE trace
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS
  BEGIN
    IF (p_level >= g_log_level ) THEN
      FND_LOG.STRING(p_level, p_procedure_name, p_debug_info);
    END IF;

  END trace;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    trace(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    trace(C_STATE_LEVEL, l_procedure_name, '$Header: FVXLAACB.pls 120.33.12010000.35 2010/03/24 19:40:20 sasukuma ship $');
  END;


  PROCEDURE extract
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.EXTRACT';
  BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------


    IF (p_application_id = 201) THEN
      fv_sla_po_processing_pkg.extract(p_application_id, p_accounting_mode);
    ELSIF (p_application_id = 707) THEN
      fv_sla_cst_processing_pkg.extract(p_application_id, p_accounting_mode);
    ELSIF (p_application_id = 200) THEN
      fv_sla_ap_processing_pkg.extract(p_application_id, p_accounting_mode);
    ELSIF (p_application_id = 222) THEN
      fv_sla_ar_processing_pkg.extract(p_application_id, p_accounting_mode);
    ELSE
      RETURN;
    END IF;

    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

  EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'Error in Federal SLA Processing ' || SQLERRM;
      trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' ,
                            'Procedure :fv_sla_processing_pkg.extract'||
                            CRLF||
                            'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END extract;

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

  l_log_module         VARCHAR2(240);
  BEGIN
    IF (p_application_id = 201) THEN
      fv_sla_po_processing_pkg.preaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSIF (p_application_id = 707) THEN
      fv_sla_cst_processing_pkg.preaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSIF (p_application_id = 200) THEN
      fv_sla_ap_processing_pkg.preaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSIF (p_application_id = 222) THEN
      fv_sla_ar_processing_pkg.preaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSE
      RETURN;
    END IF;
  END;

  PROCEDURE postprocessing
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
    l_log_module         VARCHAR2(240);
  BEGIN
    IF (p_application_id = 201) THEN
      fv_sla_po_processing_pkg.postprocessing(p_application_id, p_accounting_mode);
    ELSIF (p_application_id = 707) THEN
      fv_sla_cst_processing_pkg.postprocessing(p_application_id, p_accounting_mode);
    ELSIF (p_application_id = 200) THEN
      fv_sla_ap_processing_pkg.postprocessing(p_application_id, p_accounting_mode);
    ELSIF (p_application_id = 222) THEN
      fv_sla_ar_processing_pkg.postprocessing(p_application_id, p_accounting_mode);
    ELSE
      RETURN;
    END IF;
  END;


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
    l_log_module         VARCHAR2(240);
  BEGIN
    IF (p_application_id = 201) THEN
      fv_sla_po_processing_pkg.postaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSIF (p_application_id = 707) THEN
      fv_sla_cst_processing_pkg.postaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSIF (p_application_id = 200) THEN
      fv_sla_ap_processing_pkg.postaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSIF (p_application_id = 222) THEN
      fv_sla_ar_processing_pkg.postaccounting
      (
        p_application_id,
        p_ledger_id,
        p_process_category,
        p_end_date,
        p_accounting_mode,
        p_valuation_method,
        p_security_id_int_1,
        p_security_id_int_2,
        p_security_id_int_3,
        p_security_id_char_1,
        p_security_id_char_2,
        p_security_id_char_3,
        p_report_request_id
      );
    ELSE
      RETURN;
    END IF;
  END;
BEGIN
  init;
END fv_sla_processing_pkg;

/

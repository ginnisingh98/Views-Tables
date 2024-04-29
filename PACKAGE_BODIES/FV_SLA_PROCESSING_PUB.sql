--------------------------------------------------------
--  DDL for Package Body FV_SLA_PROCESSING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_PROCESSING_PUB" AS
--$Header: FVPXLACB.pls 120.0 2006/01/31 01:06:45 ashkumar noship $

---------------------------------------------------------------------------
C_STATE_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
C_PROC_LEVEL  CONSTANT NUMBER      :=	FND_LOG.LEVEL_PROCEDURE;
C_EVENT_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_EVENT;
C_EXCEP_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
C_ERROR_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_ERROR;
C_UNEXP_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;

g_log_level   CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_path_name   CONSTANT VARCHAR2(200)  := 'fv.plsql.FV_SLA_PROCESSING_PUB';

---------------------------------------------------------------------------
PROCEDURE trace (
      p_level             IN NUMBER,
      p_procedure_name    IN VARCHAR2,
      p_debug_info        IN VARCHAR2
)
IS

BEGIN
  IF (p_level >= g_log_level ) THEN
    FND_LOG.STRING(p_level,
                   p_procedure_name,
                   p_debug_info);
  END IF;

END trace;

---------------------------------------------------------------
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

    IF NOT fv_install.enabled THEN
        l_debug_info := 'Federal not enabled ';
        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
        RETURN;
    END IF;

    FV_SLA_PROCESSING_PKG.extract
    (
       p_application_id => p_application_id,
       p_accounting_mode => p_accounting_mode
    );

    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

END extract;

---------------------------------------------------------------
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

    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.PREACCOUNTING';

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

    IF NOT fv_install.enabled THEN
        l_debug_info := 'Federal not enabled ';
        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
        RETURN;
    END IF;

    FV_SLA_PROCESSING_PKG.preaccounting
    (
       p_application_id       => p_application_id,
       p_ledger_id            => p_ledger_id,
       p_process_category     => p_process_category,
       p_end_date             => p_end_date,
       p_accounting_mode      => p_accounting_mode,
       p_valuation_method     => p_valuation_method,
       p_security_id_int_1    => p_security_id_int_1,
       p_security_id_int_2    => p_security_id_int_2,
       p_security_id_int_3    => p_security_id_int_3,
       p_security_id_char_1   => p_security_id_char_1,
       p_security_id_char_2   => p_security_id_char_2,
       p_security_id_char_3   => p_security_id_char_3,
       p_report_request_id    => p_report_request_id
    );
    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
END;

---------------------------------------------------------------
PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
) IS

    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.POSTPROCESSING';

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

    IF NOT fv_install.enabled THEN
        l_debug_info := 'Federal not enabled ';
        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
        RETURN;
    END IF;

    FV_SLA_PROCESSING_PKG.postprocessing
    (
       p_application_id => p_application_id,
       p_accounting_mode => p_accounting_mode
    );

    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
END;

---------------------------------------------------------------
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
) IS

    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.POSTACCOUNTING';

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

    IF NOT fv_install.enabled THEN
        l_debug_info := 'Federal not enabled ';
        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
        RETURN;
    END IF;

    FV_SLA_PROCESSING_PKG.postaccounting
    (
       p_application_id       => p_application_id,
       p_ledger_id            => p_ledger_id,
       p_process_category     => p_process_category,
       p_end_date             => p_end_date,
       p_accounting_mode      => p_accounting_mode,
       p_valuation_method     => p_valuation_method,
       p_security_id_int_1    => p_security_id_int_1,
       p_security_id_int_2    => p_security_id_int_2,
       p_security_id_int_3    => p_security_id_int_3,
       p_security_id_char_1   => p_security_id_char_1,
       p_security_id_char_2   => p_security_id_char_2,
       p_security_id_char_3   => p_security_id_char_3,
       p_report_request_id    => p_report_request_id
    );
    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
END;

END fv_sla_processing_pub;


/

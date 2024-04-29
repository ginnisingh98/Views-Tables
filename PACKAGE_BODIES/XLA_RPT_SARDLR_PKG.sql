--------------------------------------------------------
--  DDL for Package Body XLA_RPT_SARDLR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_RPT_SARDLR_PKG" AS
/* $Header: xlasardlr.pkb 120.0.12010000.3 2009/09/14 10:51:29 kapkumar noship $ */
/*======================================================================+
|             Copyright (c) 2009-2010 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_rpt_sardlr_pkg                                                     |
|                                                                       |
|                                                                       |
| DESCRIPTION                                                           |
|  Package for Subledger Accounting Rules Detail Listing Report         |
|  to retrieve line-level information for ADR details                   |
|                                                                       |
| HISTORY                                                               |
|    AUG-09  Kapil Kumar                          Created               |
|                                                                       |
+======================================================================*/


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240):= 'xla.plsql.xla_rpt_sardlr_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;



PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
BEGIN
      IF (p_msg IS NULL AND p_level >= g_log_level) THEN
         fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
      ELSIF p_level >= g_log_level THEN
         fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
      END IF;

EXCEPTION
      WHEN xla_exceptions_pkg.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         xla_exceptions_pkg.raise_message
            (p_location   => 'xla_rpt_sardlr_pkg.trace');
END trace;





FUNCTION beforeReport  RETURN BOOLEAN IS

l_log_module                    VARCHAR2(240);

BEGIN


	IF g_log_enabled THEN
		l_log_module := C_DEFAULT_MODULE||'.beforeReport';
	END IF;

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		trace('Begin of beforeReport',C_LEVEL_PROCEDURE,l_log_module);
	END IF;

	IF (C_LEVEL_STATEMENT >= g_log_level) THEN

		trace('P_APPLICATION_ID = '|| to_char(P_APPLICATION_ID),
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_SLAM_CODE = '|| P_SLAM_CODE,
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_SLAM_TYPE_CODE = '|| P_SLAM_TYPE_CODE,
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_EVENT_CLASS_CODE = '|| P_EVENT_CLASS_CODE,
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_EVENT_TYPE_CODE = '|| P_EVENT_TYPE_CODE,
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_AMB_CONTEXT_CODE = '|| P_AMB_CONTEXT_CODE,
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_EVENT_CLASS_NAME = '|| P_EVENT_CLASS_NAME,
		       C_LEVEL_STATEMENT, l_log_module);
		trace('P_EVENT_TYPE_NAME = '|| P_EVENT_TYPE_NAME,
		       C_LEVEL_STATEMENT, l_log_module);


	END IF;

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		 trace('End of beforeReport'
		       ,C_LEVEL_PROCEDURE, l_log_module);
	END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location  => 'xla_rpt_sardlr_pkg.beforeReport');
END beforeReport;







FUNCTION populate_fields
    (value_type_code                IN  VARCHAR2,
     value_source_application_id    IN  NUMBER,
     value_source_type_code         IN  VARCHAR2,
     value_source_code              IN  VARCHAR2,
     value_mapping_set_code         IN  VARCHAR2,
     value_code_combination_id      IN  NUMBER,
     amb_context_code               IN  VARCHAR2,
     value_segment_rule_appl_id     IN  NUMBER,
     value_segment_rule_type_code   IN  VARCHAR2,
     value_segment_rule_code        IN  VARCHAR2,
     flexfield_assign_mode_code     IN  VARCHAR2,
     value_constant                 IN  VARCHAR2,
     flex_value_set_id              IN  NUMBER,
     input_source_code              IN  VARCHAR2,
     input_source_application_id    IN  NUMBER,
     input_source_type_code         IN  VARCHAR2,
     value_flexfield_segment_code   IN  VARCHAR2,
     transaction_coa_id             IN  NUMBER,
     accounting_coa_id              IN  NUMBER,
     p_mode                         IN  NUMBER
    )
RETURN VARCHAR2

IS


--=============================================================================
--               *********** Function Variables **********
--=============================================================================

input_source_view_appl_id       NUMBER;
input_source_lookup_type        VARCHAR2(250);
input_source_value_set_id       NUMBER;
input_source_flex_appl_id       NUMBER;
input_source_id_flex_code       VARCHAR2(250);
input_source_segment_code       VARCHAR2(250);
input_source_id_flex_num        NUMBER;
input_source_name               VARCHAR2(250);

value_flexfield_segment_name    VARCHAR2(250);
value_dsp                       VARCHAR2(250);
value_source_flex_appl_id       NUMBER;
value_source_id_flex_code       VARCHAR2(250);
value_source_segment_code       VARCHAR2(250);
value_ms_view_application_id    NUMBER;
value_ms_lookup_type            VARCHAR2(250);
value_ms_value_set_id           NUMBER;

l_log_module                    VARCHAR2(240);
--=============================================================================
--               *********** Cursors **********
--=============================================================================


    CURSOR c_source_name
      (p_source_application_id  IN  NUMBER
      ,p_source_type_code       IN  VARCHAR2
      ,p_source_code            IN  VARCHAR2)
    IS
    SELECT name
      FROM xla_sources_vl
     WHERE application_id   = p_source_application_id
       AND source_type_code = p_source_type_code
       AND source_code      = p_source_code;

    CURSOR c_value_sources
      (p_source_application_id  IN  NUMBER
      ,p_source_type_code       IN  VARCHAR2
      ,p_source_code            IN  VARCHAR2)
    IS
    SELECT name, flexfield_application_id, id_flex_code, segment_code
      FROM xla_sources_vl
     WHERE application_id   = p_source_application_id
       AND source_type_code = p_source_type_code
       AND source_code      = p_source_code;

    CURSOR c_input_source_name
      (p_source_application_id  IN  NUMBER
      ,p_source_type_code       IN  VARCHAR2
      ,p_source_code            IN  VARCHAR2)
    IS
    SELECT name, view_application_id, lookup_type, flex_value_set_id,
           flexfield_application_id, id_flex_code, segment_code
      FROM xla_sources_vl
     WHERE application_id   = p_source_application_id
       AND source_type_code = p_source_type_code
       AND source_code      = p_source_code;


    CURSOR c_mapping_set
      (p_mapping_set_code  IN  VARCHAR2)
    IS
    SELECT name, view_application_id, lookup_type, value_set_id
      FROM xla_mapping_sets_vl
     WHERE mapping_set_code  = p_mapping_set_code;

    CURSOR c_adr
      (p_amb_context_code             IN VARCHAR2
      ,p_value_segment_rule_appl_id   IN VARCHAR2
      ,p_value_segment_rule_type_code IN VARCHAR2
      ,p_value_segment_rule_code      IN VARCHAR2)
    IS
    SELECT name
      FROM xla_seg_rules_fvl
     WHERE amb_context_code       = p_amb_context_code
       AND application_id         = p_value_segment_rule_appl_id
       AND segment_rule_type_code = p_value_segment_rule_type_code
       AND segment_rule_code      = p_value_segment_rule_code;

BEGIN




IF g_log_enabled THEN
	l_log_module := C_DEFAULT_MODULE||'.populate_fields';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
	trace('Begin of populate_fields',C_LEVEL_PROCEDURE,l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

	trace('value_source_application_id = '|| to_char(value_source_application_id),
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_segment_rule_appl_id = '|| to_char(value_segment_rule_appl_id),
		C_LEVEL_STATEMENT, l_log_module);
	trace('flex_value_set_id = '|| to_char(flex_value_set_id),
		C_LEVEL_STATEMENT, l_log_module);
	trace('input_source_application_id = '|| to_char(input_source_application_id),
		C_LEVEL_STATEMENT, l_log_module);
	trace('transaction_coa_id = '|| to_char(transaction_coa_id),
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_type_code = '|| value_type_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_source_type_code = '|| value_source_type_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_source_code = '|| value_source_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_mapping_set_code = '|| value_mapping_set_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('amb_context_code = '|| amb_context_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_segment_rule_type_code = '|| value_segment_rule_type_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_segment_rule_code = '|| value_segment_rule_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('flexfield_assign_mode_code = '|| flexfield_assign_mode_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_constant = '|| value_constant,
		C_LEVEL_STATEMENT, l_log_module);
	trace('input_source_code = '|| input_source_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('input_source_type_code = '|| input_source_type_code,
		C_LEVEL_STATEMENT, l_log_module);
	trace('value_flexfield_segment_code = '|| value_flexfield_segment_code,
		C_LEVEL_STATEMENT, l_log_module);
END IF;



IF value_type_code = 'S' THEN

	OPEN c_value_sources
	(value_source_application_id
	,value_source_type_code
	,value_source_code);
	FETCH c_value_sources
	INTO value_dsp, value_source_flex_appl_id,
	value_source_id_flex_code, value_source_segment_code;
	CLOSE c_value_sources;

ELSIF value_type_code = 'M' THEN

	OPEN c_mapping_set
	(value_mapping_set_code);
	FETCH c_mapping_set
	INTO value_dsp
	, value_ms_view_application_id
	, value_ms_lookup_type
	, value_ms_value_set_id;
	CLOSE c_mapping_set;

ELSIF  value_type_code = 'A' THEN

	OPEN c_adr
	(amb_context_code
	,value_segment_rule_appl_id
	,value_segment_rule_type_code
	,value_segment_rule_code);
	FETCH c_adr
	INTO value_dsp;
	CLOSE c_adr;


ELSIF value_type_code = 'C' THEN

	IF flexfield_assign_mode_code = 'S' THEN
		value_dsp := value_constant;
	ELSIF  flexfield_assign_mode_code = 'V' THEN
		IF  value_constant IS NOT NULL THEN
			IF flex_value_set_id IS NOT NULL    THEN
				value_dsp := xla_flex_pkg.get_flex_value_meaning
							(p_flex_value_set_id => flex_value_set_id
							,p_flex_value        => value_constant);
			END IF;
		END IF;
	ELSIF  flexfield_assign_mode_code = 'A' THEN
	    value_dsp := FND_FLEX_EXT.GET_SEGS('SQLGL', 'GL#', accounting_coa_id, value_code_combination_id);
	END IF;

ELSE value_dsp := NULL;
END IF;


IF p_mode = 1 THEN    --ADR_VALUE field

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		 trace('End of populate_fields (1) return' || value_dsp
		       ,C_LEVEL_PROCEDURE, l_log_module);
	END IF;

  RETURN value_dsp;

END IF;



input_source_name := NULL;   -- default null value for ADR_INPUT
value_flexfield_segment_name := NULL;   -- default null value for ADR_SEGMENT


IF input_source_code IS NOT NULL THEN

	OPEN c_input_source_name
	( input_source_application_id
	, input_source_type_code
	, input_source_code);
	FETCH c_input_source_name
	INTO  input_source_name
	, input_source_view_appl_id
	, input_source_lookup_type
	, input_source_value_set_id
	, input_source_flex_appl_id
	, input_source_id_flex_code
	, input_source_segment_code;
	CLOSE c_input_source_name;

	IF (input_source_flex_appl_id IS NOT NULL AND input_source_segment_code IS NULL) THEN
		IF (input_source_flex_appl_id = 101 AND input_source_id_flex_code = 'GL#') THEN
			input_source_id_flex_num := NULL;
		ELSE
			input_source_id_flex_num := xla_flex_pkg.get_flexfield_structure
								(p_application_id   => input_source_flex_appl_id
								,p_id_flex_code     => input_source_id_flex_code);
		END IF;
	END IF;
END IF;


IF P_MODE = 2 THEN   -- ADR_INPUT field

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		 trace('End of populate_fields (2) return' || input_source_name
		       ,C_LEVEL_PROCEDURE, l_log_module);
	END IF;

	RETURN input_source_name;
END IF;




IF value_flexfield_segment_code IS NOT NULL THEN
	IF (value_source_flex_appl_id IS NOT NULL OR (input_source_flex_appl_id = 101 AND input_source_id_flex_code = 'GL#')) THEN
		IF transaction_coa_id IS NOT NULL THEN

			value_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
								(p_application_id         => 101
								,p_flex_code              => 'GL#'
								,p_chart_of_accounts_id   => transaction_coa_id
								,p_flexfield_segment_code => value_flexfield_segment_code);

		ELSE
			value_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
								(p_application_id         => 101
								,p_id_flex_code              => 'GL#'
								,p_qualifier_segment      => value_flexfield_segment_code);

		END IF;
	ELSE
		value_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
								(p_application_id         => input_source_flex_appl_id
								,p_flex_code              => input_source_id_flex_code
								,p_chart_of_accounts_id   => input_source_id_flex_num
								,p_flexfield_segment_code => value_flexfield_segment_code);

	END IF;
END IF;


IF P_MODE = 3 THEN    --ADR_SEGMENT field

	IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		 trace('End of populate_fields (3) return' || value_flexfield_segment_name
		       ,C_LEVEL_PROCEDURE, l_log_module);
	END IF;


	RETURN value_flexfield_segment_name;
END IF;




EXCEPTION
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location  => 'xla_rpt_sardlr_pkg.beforeReport');

END populate_fields;



BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                       (log_level  => g_log_level
                       ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_rpt_sardlr_pkg;

/

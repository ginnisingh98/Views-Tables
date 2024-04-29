--------------------------------------------------------
--  DDL for Package Body XLA_ADR_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ADR_INTERFACE_PKG" AS
/* $Header: xlaadrin.pkb 120.3 2005/12/28 18:28:09 jlarre noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_adr_interface_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA ADR interface                                                  |
|                                                                       |
| HISTORY                                                               |
|    16-AUG-2005 Jorge Larre  Created                                   |
|    23-DEC-2005 Jorge Larre  Fix for bug 4906683                       |
|     a) Populate xla_seg_rules_b.updated_flag with 'Y'.                |
|     b) Add code to populate xla_line_defn_assgns.accounting_line_code |
|    28-DEC-2005 Jorge Larre  Fix for bug 4906683                       |
|     a) Populate side_code with 'NA'.                                  |
|     b) Populate inherit_adr_flag with 'N'.                            |
|     c) Populate adr_version_num with 0.                               |
|     d) Populate segment_rule_appl_id with application_id.             |
|                                                                       |
+======================================================================*/
    --
    -- Private types
    --
    TYPE t_array_VL4    IS TABLE OF VARCHAR2(4)     INDEX BY BINARY_INTEGER;
    --
    -- Private constants
    --
    --maximum numbers of values retrieved at a time by BULK COLLECT statements
    C_BULK_LIMIT              CONSTANT NATURAL      :=   1000;
    --
    -- Global variables
    --
    g_user_id                 INTEGER;
    g_login_id                INTEGER;
    g_date                    DATE;
    g_prog_appl_id            INTEGER;
    g_prog_id                 INTEGER;
    g_req_id                  INTEGER;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_adr_interface_pkg';
g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_adr_interface_pkg.trace');
END trace;

PROCEDURE upload_rules
IS
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
+======================================================================*/

CURSOR c_xla_rules_t IS             -- cursor for xla_rules_t
    SELECT *
    FROM   xla_rules_t
    WHERE  error_value = 0
    FOR UPDATE of error_value;

CURSOR c_xla_rule_details_t IS      -- cursor for xla_rule_details_t
    SELECT *
    FROM   xla_rule_details_t
    WHERE  error_value = 0
    FOR UPDATE of error_value;

CURSOR c_xla_conditions_t IS        -- cursor for xla_conditions_t
    SELECT *
    FROM   xla_conditions_t
    WHERE  error_value = 0
    FOR UPDATE of error_value;

CURSOR c_xla_line_assgns_t IS       -- cursor for xla_line_assgns_t
    SELECT *
    FROM   xla_line_assgns_t
    WHERE  error_value = 0
    FOR UPDATE of error_value;

CURSOR c_languages IS               -- cursor for installed languages
    SELECT language_code
    FROM   fnd_languages
    WHERE  installed_flag = 'I';

l_xla_rules		c_xla_rules_t%ROWTYPE;
l_xla_rule_details      c_xla_rule_details_t%ROWTYPE;
l_xla_conditions        c_xla_conditions_t%ROWTYPE;
l_xla_line_assgns       c_xla_line_assgns_t%ROWTYPE;
l_base_language		VARCHAR2(4);
l_installed_language    t_array_vl4;
l_user_id               INTEGER;
l_login_id              INTEGER;
l_date                  DATE;
l_prog_appl_id          INTEGER;
l_prog_id               INTEGER;
l_req_id                INTEGER;
l_log_module            VARCHAR2 (2000);
l_error_code            NUMBER;

BEGIN

    l_user_id               := xla_environment_pkg.g_usr_id;
    l_login_id              := xla_environment_pkg.g_login_id;
    l_date                  := SYSDATE;
    l_prog_appl_id          := xla_environment_pkg.g_prog_appl_id;
    l_prog_id               := xla_environment_pkg.g_prog_id;
    l_req_id                := xla_environment_pkg.g_req_id;

    IF g_log_enabled THEN
        l_log_module := C_DEFAULT_MODULE||'.upload_rules';
    END IF;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
            (p_module => l_log_module
            ,p_msg      => 'BEGIN ' || l_log_module
            ,p_level    => C_LEVEL_PROCEDURE);
    END IF;

    -- Retrieve the base language
    SELECT language_code
        INTO l_base_language
        FROM fnd_languages
        WHERE installed_flag = 'B';

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
            (p_module => l_log_module
            ,p_msg   => 'Base language       :'
                      || l_base_language
            ,p_level => C_LEVEL_STATEMENT
            );
    END IF;

    -- Retrieve the installed languages
    OPEN c_languages;
    FETCH c_languages BULK COLLECT INTO l_installed_language;
    CLOSE c_languages;

/* Missing the validation of the interface tables */

    /* Upload rules into SLA tables */
    OPEN c_xla_rules_t;
    LOOP
        FETCH c_xla_rules_t INTO l_xla_rules;
        EXIT WHEN c_xla_rules_t%NOTFOUND;
        BEGIN       -- Block begins
        -- Insert data into xla_seg_rules_b
        INSERT INTO xla_seg_rules_b
   	(application_id
	,amb_context_code
	,segment_rule_type_code
	,segment_rule_code
	,transaction_coa_id
	,accounting_coa_id
	,flexfield_assign_mode_code
	,flexfield_segment_code
	,enabled_flag
	,creation_date
	,created_by
	,last_update_date
	,last_updated_by
	,last_update_login
	,flex_value_set_id
	,version_num
	,updated_flag
	)
        VALUES
        (l_xla_rules.application_id
	,l_xla_rules.amb_context_code
	,l_xla_rules.segment_rule_type_code
	,UPPER(l_xla_rules.segment_rule_code)
	,l_xla_rules.transaction_coa_id
	,l_xla_rules.accounting_coa_id
	,l_xla_rules.flexfield_assign_mode_code
	,l_xla_rules.flexfield_segment_code
	,l_xla_rules.enabled_flag
	,l_date
	,l_user_id
	,l_date
	,l_user_id
	,l_login_id
	,NULL
	,0
	,'Y'
	);

        -- Insert data in xla_seg_rules_tl, the base language
        INSERT INTO xla_seg_rules_tl
	(last_update_login
	,amb_context_code
	,last_update_date
	,last_updated_by
	,created_by
	,application_id
	,segment_rule_type_code
	,segment_rule_code
	,name
	,description
	,creation_date
	,language
	,source_lang
	)
        VALUES
       	(l_login_id
      	,l_xla_rules.amb_context_code
      	,l_date
      	,l_user_id
      	,l_user_id
      	,l_xla_rules.application_id
      	,l_xla_rules.segment_rule_type_code
      	,l_xla_rules.segment_rule_code
      	,l_xla_rules.name
      	,l_xla_rules.description
      	,l_date
      	,l_base_language
      	,l_base_language
	);

        -- Insert data in xla_seg_rules_tl, the additional languages, if any
        IF l_installed_language.COUNT > 0 THEN
            FOR Idx IN l_installed_language.FIRST .. l_installed_language.LAST LOOP
                INSERT INTO xla_seg_rules_tl
	        (last_update_login
	        ,amb_context_code
	        ,last_update_date
	        ,last_updated_by
	        ,created_by
	        ,application_id
	        ,segment_rule_type_code
	        ,segment_rule_code
	        ,name
	        ,description
	        ,creation_date
	        ,language
	        ,source_lang
	        )
                VALUES
       	        (l_login_id
      	        ,l_xla_rules.amb_context_code
      	        ,l_date
      	        ,l_user_id
      	        ,l_user_id
      	        ,l_xla_rules.application_id
      	        ,l_xla_rules.segment_rule_type_code
      	        ,l_xla_rules.segment_rule_code
      	        ,l_xla_rules.name
      	        ,l_xla_rules.description
      	        ,l_date
      	        ,l_installed_language(Idx)
      	        ,l_base_language
	            );
            END LOOP;
        END IF;
        -- Mark the row in the interface table as been processed
        UPDATE xla_rules_t
            SET error_value = 1     -- The row has been processed with no error
            WHERE CURRENT OF c_xla_rules_t;
        EXCEPTION
        WHEN OTHERS THEN
        l_error_code := SQLCODE;
        UPDATE xla_rules_t
            SET error_value = l_error_code       -- The row has been processed with errors
            WHERE CURRENT OF c_xla_rules_t;
        END;        -- Block ends
    END LOOP;
    CLOSE c_xla_rules_t;

    OPEN c_xla_rule_details_t;
    LOOP
        FETCH c_xla_rule_details_t into l_xla_rule_details;
        EXIT WHEN c_xla_rule_details_t%NOTFOUND;

        BEGIN       -- Block begins
        -- Insert data into xla_seg_rule_details
        INSERT INTO xla_seg_rule_details
   	(segment_rule_detail_id
	,application_id
	,amb_context_code
	,segment_rule_type_code
	,segment_rule_code
	,user_sequence
	,value_type_code
	,value_source_application_id
	,value_source_type_code
	,value_source_code
	,value_constant
	,value_code_combination_id
	,value_mapping_set_code
      	,value_flexfield_segment_code
       	,input_source_application_id
       	,input_source_type_code
       	,input_source_code
       	,creation_date
       	,created_by
       	,last_update_date
       	,last_updated_by
       	,last_update_login
       	,value_segment_rule_appl_id
       	,value_segment_rule_type_code
       	,value_segment_rule_code
       	,value_adr_version_num
       	)
        VALUES
        (l_xla_rule_details.segment_rule_detail_id
       	,l_xla_rule_details.application_id
       	,l_xla_rule_details.amb_context_code
       	,l_xla_rule_details.segment_rule_type_code
       	,UPPER(l_xla_rule_details.segment_rule_code)
       	,l_xla_rule_details.user_sequence
       	,l_xla_rule_details.value_type_code
      	,l_xla_rule_details.value_source_application_id
       	,l_xla_rule_details.value_source_type_code
       	,l_xla_rule_details.value_source_code
       	,l_xla_rule_details.value_constant
       	,l_xla_rule_details.value_code_combination_id
       	,l_xla_rule_details.value_mapping_set_code
       	,l_xla_rule_details.value_flexfield_segment_code
       	,l_xla_rule_details.input_source_application_id
       	,l_xla_rule_details.input_source_type_code
       	,l_xla_rule_details.input_source_code
       	,l_date
       	,l_user_id
       	,l_date
       	,l_user_id
       	,l_login_id
       	,l_xla_rule_details.value_segment_rule_appl_id
       	,l_xla_rule_details.value_segment_rule_type_code
        ,l_xla_rule_details.value_segment_rule_code
       	,l_xla_rule_details.value_adr_version_num
        );
        -- Mark the row in the interface table as been processed
        UPDATE xla_rule_details_t
            SET error_value = 1     -- The row has been processed with no error
            WHERE CURRENT OF c_xla_rule_details_t;
        EXCEPTION
        WHEN OTHERS THEN
        l_error_code := SQLCODE;
        UPDATE xla_rule_details_t
            SET error_value = l_error_code       -- The row has been processed with errors
            WHERE CURRENT OF c_xla_rule_details_t;
        END;        -- Block ends
    END LOOP;
    CLOSE c_xla_rule_details_t;

    OPEN c_xla_conditions_t;
    LOOP
        FETCH c_xla_conditions_t INTO l_xla_conditions;
        EXIT WHEN c_xla_conditions_t%NOTFOUND;

        BEGIN       -- Block begins
        -- Insert data into xla_conditions
        INSERT INTO xla_conditions
   	(condition_id
	,user_sequence
        ,application_id
        ,amb_context_code
        ,entity_code
        ,event_class_code
        ,accounting_line_type_code
        ,accounting_line_code
        ,segment_rule_detail_id
        ,description_prio_id
        ,bracket_left_code
        ,bracket_right_code
        ,value_type_code
        ,source_application_id
        ,source_type_code
        ,source_code
        ,flexfield_segment_code
        ,value_flexfield_segment_code
        ,value_source_application_id
        ,value_source_type_code
        ,value_source_code
        ,value_constant
        ,line_operator_code
        ,logical_operator_code
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,independent_value_constant
        )
        VALUES
        (l_xla_conditions.condition_id
        ,l_xla_conditions.user_sequence
        ,l_xla_conditions.application_id
        ,l_xla_conditions.amb_context_code
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,l_xla_conditions.segment_rule_detail_id
        ,NULL
        ,l_xla_conditions.bracket_left_code
        ,l_xla_conditions.bracket_right_code
        ,l_xla_conditions.value_type_code
        ,l_xla_conditions.source_application_id
        ,l_xla_conditions.source_type_code
        ,l_xla_conditions.source_code
        ,l_xla_conditions.flexfield_segment_code
        ,l_xla_conditions.value_flexfield_segment_code
        ,l_xla_conditions.value_source_application_id
        ,l_xla_conditions.value_source_type_code
        ,l_xla_conditions.value_source_code
        ,l_xla_conditions.value_constant
        ,l_xla_conditions.line_operator_code
        ,l_xla_conditions.logical_operator_code
        ,l_date
        ,l_user_id
        ,l_date
        ,l_user_id
        ,l_login_id
        ,l_xla_conditions.independent_value_constant
        );
        -- Mark the row in the interface table as been processed
        UPDATE xla_conditions_t
            SET error_value = 1     -- The row has been processed with no error
            WHERE CURRENT OF c_xla_conditions_t;
        EXCEPTION
        WHEN OTHERS THEN
        l_error_code := SQLCODE;
        UPDATE xla_conditions_t
            SET error_value = l_error_code       -- The row has been processed with errors
            WHERE CURRENT OF c_xla_conditions_t;
        END;        -- Block ends
    END LOOP;
    CLOSE c_xla_conditions_t;

    OPEN c_xla_line_assgns_t;
    LOOP
        FETCH c_xla_line_assgns_t INTO l_xla_line_assgns;
        EXIT WHEN c_xla_line_assgns_t%NOTFOUND;

        BEGIN       -- Block begins
        -- Insert data into xla_line_defn_adr_assgns
        INSERT INTO xla_line_defn_adr_assgns
   	(amb_context_code
	,application_id
        ,event_class_code
        ,event_type_code
        ,line_definition_owner_code
        ,line_definition_code
        ,accounting_line_type_code
	,accounting_line_code
        ,flexfield_segment_code
        ,segment_rule_type_code
        ,segment_rule_code
        ,object_version_number
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,side_code
        ,inherit_adr_flag
        ,segment_rule_appl_id
        ,adr_version_num
        )
        VALUES
        (l_xla_line_assgns.amb_context_code
        ,l_xla_line_assgns.application_id
        ,l_xla_line_assgns.event_class_code
        ,l_xla_line_assgns.event_type_code
        ,l_xla_line_assgns.line_definition_owner_code
        ,l_xla_line_assgns.line_definition_code
        ,l_xla_line_assgns.accounting_line_type_code
	,l_xla_line_assgns.accounting_line_code
        ,l_xla_line_assgns.flexfield_segment_code
        ,l_xla_line_assgns.segment_rule_type_code
        ,l_xla_line_assgns.segment_rule_code
        ,1
        ,l_date
        ,l_user_id
        ,l_date
        ,l_user_id
        ,l_login_id
        ,'NA'
        ,'N'
        ,l_xla_line_assgns.application_id
        ,0
        );
        -- Mark the row in the interface table as been processed
        UPDATE xla_line_assgns_t
            SET error_value = 1     -- The row has been processed with no error
            WHERE CURRENT OF c_xla_line_assgns_t;
        EXCEPTION
        WHEN OTHERS THEN
        l_error_code := SQLCODE;
        UPDATE xla_line_assgns_t
            SET error_value = l_error_code       -- The row has been processed with errors
            WHERE CURRENT OF c_xla_line_assgns_t;
        END;        -- Block ends
    END LOOP;
    CLOSE c_xla_line_assgns_t;

    --END LOOP;
    --CLOSE c_xla_rules_t;

   /* handle_errors; */

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_adr_interface_pkg.upload_rules');
END upload_rules;

END xla_adr_interface_pkg;

/

--------------------------------------------------------
--  DDL for Package Body XLA_AAD_UPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_UPLOAD_PVT" AS
/* $Header: xlaalupl.pkb 120.28.12010000.2 2009/03/05 08:59:37 krsankar ship $ */

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
C_FILE_NAME                   CONSTANT VARCHAR2(30):='xlaalupl.pkb';
C_CHAR                        CONSTANT VARCHAR2(1) :='
';

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_upload_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
l_time varchar2(300);
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
      (p_location   => 'xla_aad_upload_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: submit_request
-- Description: This API submits the Upload Application Accounting Definitions
--              request
--
--=============================================================================
FUNCTION submit_request
(p_application_id        IN INTEGER
,p_source_pathname       IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN INTEGER
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR c_app_short_name IS
    SELECT application_short_name
      FROM fnd_application
     WHERE application_id = p_application_id;

  l_app_short_name    VARCHAR2(30);
  l_req_id            INTEGER;
  l_log_module        VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.submit_request';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function submit_request',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  DELETE FROM xla_aad_loader_defns_t
   WHERE staging_amb_context_code = p_staging_context_code;

  OPEN c_app_short_name;
  FETCH c_app_short_name INTO l_app_short_name;
  CLOSE c_app_short_name;

  l_req_id := fnd_request.submit_request
               (application => 'XLA'
               ,program     => 'XLAAADUL'
               ,description => NULL
               ,start_time  => NULL
               ,sub_request => FALSE
               ,argument1   => 'UPLOAD_PARTIAL'
               ,argument2   => '@xla:/patch/115/import/xlaaadrule.lct'
               ,argument3   => p_source_pathname
               ,argument4   => 'XLA_AAD'
               ,argument5   => 'STAGING_AMB_CONTEXT_CODE='||p_staging_context_code);

  COMMIT;

  IF (C_LEVEL_EVENT>= g_log_level) THEN
    trace(p_msg    => 'Submitted XLAAADUL request = '||l_req_id
         ,p_level  => C_LEVEL_EVENT
         ,p_module => l_log_module);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function submit_request',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_req_id;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.submit_request'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END submit_request;

--=============================================================================
--
-- Name: upload_data
-- Description: This API submits a concurrent request to upload data from the
--              data file to the AAD Loader interface table
--
--=============================================================================
FUNCTION upload_data
(p_application_id        IN INTEGER
,p_source_pathname       IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  l_retcode       VARCHAR2(30);
  l_req_id        NUMBER;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.upload_data';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function upload_data',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_req_id := submit_request
                     (p_application_id        => p_application_id
                     ,p_source_pathname       => p_source_pathname
                     ,p_staging_context_code  => p_staging_context_code);

  IF (l_req_id = 0) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_retcode := xla_aad_loader_util_pvt.wait_for_request(p_req_id => l_req_id);
  IF (l_retcode = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function upload_data : Return Code = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_FNDLOAD_FAIL'
               ,p_token_1         => 'CONC_REQUEST_ID'
               ,p_value_1         => l_req_id
               ,p_token_2         => 'DATA_FILE'
               ,p_value_2         => p_source_pathname);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function upload_data  : Return Code = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'ERROR';
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.upload_data'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END upload_data;

--=============================================================================
--
-- Name: validation
-- Description: This API validate if the uploaded data from the ldt is valid
--
--=============================================================================
FUNCTION validation
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_file_size IS
    SELECT count(*)
      FROM xla_aad_loader_defns_t  xal
     WHERE xal.staging_amb_context_code = p_staging_context_code
       AND xal.table_name = 'XLA_PRODUCT_RULES'
       AND ROWNUM = 1;

  CURSOR c_invalid_app IS
    SELECT fa.application_name  file_app_name
         , fa2.application_name resp_app_name
      FROM xla_aad_loader_defns_t  xal
         , fnd_application_vl      fa
         , fnd_application_vl      fa2
     WHERE xal.staging_amb_context_code = p_staging_context_code
       AND xal.table_name               = 'XLA_AAD'
       AND xal.application_short_name   = fa.application_short_name
       AND fa.application_id           <> p_application_id
       AND fa2.application_id           = p_application_id;

-- krsankar - Bug 6975482 - Introducing 2 new cursors for deleting duplicate data from XLA_ANALYTICAL_HDRS, XLA_ANALYTICAL_SOURCES
-- krsankar - Bug 7243326 - Modified to analytical_criterion_code instead of criterion_type_code

 CURSOR c_del_dup_name IS
    SELECT table_name
         , DECODE(table_name
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_code)
         , analytical_criterion_code
	 , analytical_criterion_type_code   -- Added for bug 8268819
         , count(*)
      FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = p_staging_context_code
       AND table_name IN ('XLA_ANALYTICAL_HDRS')
    GROUP BY
           table_name
         , DECODE(table_name
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_code)
         , analytical_criterion_code
	 , analytical_criterion_type_code   -- Added for bug 8268819
  HAVING count(*) > 1;


  CURSOR c_del_dup_name_anal_sources IS
    SELECT table_name
         , DECODE(table_name
                 ,'XLA_ANALYTICAL_SOURCES' ,analytical_criterion_type_code||C_CHAR||
                                            analytical_criterion_code||C_CHAR||
		  			    event_class_code)
	 , analytical_criterion_type_code
	 , analytical_criterion_code
	 , analytical_detail_code
	 , entity_code
	 , event_class_code
	 , source_code
	 , source_type_code
         , count(*)
      FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = p_staging_context_code
       AND table_name IN ('XLA_ANALYTICAL_SOURCES')
    GROUP BY
           table_name
         , DECODE(table_name
                 ,'XLA_ANALYTICAL_SOURCES' ,analytical_criterion_type_code||C_CHAR||
                                            analytical_criterion_code||C_CHAR||
		  			    event_class_code)
	  , analytical_criterion_type_code
	 , analytical_criterion_code
	 , analytical_detail_code
	 , entity_code
	 , event_class_code
	 , source_code
	 , source_type_code
  HAVING count(*) > 1;

-- krsankar - End of new cursor addition

  CURSOR c_dup_name IS
    SELECT table_name
         , DECODE(table_name
                 ,'XLA_PRODUCT_RULES'    ,product_rule_type_code
                 ,'XLA_LINE_DEFINITIONS' ,event_class_code||C_CHAR||
                                          event_type_code||C_CHAR||
                                          line_definition_owner_code
                 ,'XLA_ACCT_LINE_TYPES'  ,event_class_code||C_CHAR||
                                          accounting_line_type_code
                 ,'XLA_DESCRIPTIONS'     ,description_type_code
                 ,'XLA_SEG_RULES'        ,segment_rule_type_code
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_type_code
                 ,'XLA_ANALYTICAL_DTLS'  ,analytical_criterion_type_code||C_CHAR||
                                          analytical_criterion_code
                 ,'XLA_MAPPING_SETS'     ,NULL)
         , name
         , count(*)
      FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = p_staging_context_code
       AND name                     IS NOT NULL
       AND table_name IN ('XLA_PRODUCT_RULES'
                         ,'XLA_LINE_DEFINITIONS'
                         ,'XLA_ACCT_LINE_TYPES'
                         ,'XLA_DESCRIPTIONS'
                         ,'XLA_SEG_RULES'
                         ,'XLA_ANALYTICAL_HDRS'
                         ,'XLA_ANALYTICAL_DTLS'
                         ,'XLA_MAPPING_SETS')
     GROUP BY
           table_name
         , DECODE(table_name
                 ,'XLA_PRODUCT_RULES'    ,product_rule_type_code
                 ,'XLA_LINE_DEFINITIONS' ,event_class_code||C_CHAR||
                                          event_type_code||C_CHAR||
                                          line_definition_owner_code
                 ,'XLA_ACCT_LINE_TYPES'  ,event_class_code||C_CHAR||
                                          accounting_line_type_code
                 ,'XLA_DESCRIPTIONS'     ,description_type_code
                 ,'XLA_SEG_RULES'        ,segment_rule_type_code
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_type_code
                 ,'XLA_ANALYTICAL_DTLS'  ,analytical_criterion_type_code||C_CHAR||
                                          analytical_criterion_code
                 ,'XLA_MAPPING_SETS'     ,NULL)
         , name
    HAVING count(*) > 1;

  CURSOR c_dup_code IS
    SELECT table_name
         , DECODE(table_name
                 ,'XLA_PRODUCT_RULES'    ,product_rule_type_code
                 ,'XLA_LINE_DEFINITIONS' ,event_class_code||C_CHAR||
                                          event_type_code||C_CHAR||
                                          line_definition_owner_code
                 ,'XLA_ACCT_LINE_TYPES'  ,event_class_code||C_CHAR||
                                          accounting_line_type_code
                 ,'XLA_DESCRIPTIONS'     ,description_type_code
                 ,'XLA_SEG_RULES'        ,segment_rule_type_code
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_type_code
                 ,'XLA_ANALYTICAL_DTLS'  ,analytical_criterion_type_code||C_CHAR||
                                          analytical_criterion_code
                 ,'XLA_MAPPING_SETS'     ,NULL)
         , DECODE(table_name
                 ,'XLA_PRODUCT_RULES'    ,product_rule_code
                 ,'XLA_LINE_DEFINITIONS' ,line_definition_code
                 ,'XLA_ACCT_LINE_TYPES'  ,accounting_line_code
                 ,'XLA_DESCRIPTIONS'     ,description_code
                 ,'XLA_SEG_RULES'        ,segment_rule_code
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_code
                 ,'XLA_ANALYTICAL_DTLS'  ,analytical_detail_code
                 ,'XLA_MAPPING_SETS'     ,mapping_set_code) code
         , count(*)
      FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = p_staging_context_code
       AND table_name IN ('XLA_PRODUCT_RULES'
                         ,'XLA_LINE_DEFINITIONS'
                         ,'XLA_ACCT_LINE_TYPES'
                         ,'XLA_DESCRIPTIONS'
                         ,'XLA_SEG_RULES'
                         ,'XLA_ANALYTICAL_HDRS'
                         ,'XLA_ANALYTICAL_DTLS'
                         ,'XLA_MAPPING_SETS')
     GROUP BY
           table_name
         , DECODE(table_name
                 ,'XLA_PRODUCT_RULES'    ,product_rule_type_code
                 ,'XLA_LINE_DEFINITIONS' ,event_class_code||C_CHAR||
                                          event_type_code||C_CHAR||
                                          line_definition_owner_code
                 ,'XLA_ACCT_LINE_TYPES'  ,event_class_code||C_CHAR||
                                          accounting_line_type_code
                 ,'XLA_DESCRIPTIONS'     ,description_type_code
                 ,'XLA_SEG_RULES'        ,segment_rule_type_code
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_type_code
                 ,'XLA_ANALYTICAL_DTLS'  ,analytical_criterion_type_code||C_CHAR||
                                          analytical_criterion_code
                 ,'XLA_MAPPING_SETS'     ,NULL)
         , DECODE(table_name
                 ,'XLA_PRODUCT_RULES'    ,product_rule_code
                 ,'XLA_LINE_DEFINITIONS' ,line_definition_code
                 ,'XLA_ACCT_LINE_TYPES'  ,accounting_line_code
                 ,'XLA_DESCRIPTIONS'     ,description_code
                 ,'XLA_SEG_RULES'        ,segment_rule_code
                 ,'XLA_ANALYTICAL_HDRS'  ,analytical_criterion_code
                 ,'XLA_ANALYTICAL_DTLS'  ,analytical_detail_code
                 ,'XLA_MAPPING_SETS'     ,mapping_set_code)
    HAVING count(*) > 1;

  CURSOR c_invalid_coa IS
    SELECT xal.value_ccid_id_flex_struct_code id_flex_struct_code
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_id_flex_structures fif
           ON  fif.application_id         = 101
           AND fif.id_flex_code           = 'GL#'
           AND fif.id_flex_structure_code = xal.value_ccid_id_flex_struct_code
     WHERE xal.staging_amb_context_code       = p_staging_context_code
       AND xal.value_ccid_id_flex_struct_code IS NOT NULL
       AND fif.id_flex_structure_code         IS NULL
     UNION
    SELECT xal.trans_coa_id_flex_struct_code
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_id_flex_structures fif
           ON  fif.application_id         = 101
           AND fif.id_flex_code           = 'GL#'
           AND fif.id_flex_structure_code = xal.trans_coa_id_flex_struct_code
     WHERE xal.staging_amb_context_code      = p_staging_context_code
       AND xal.trans_coa_id_flex_struct_code IS NOT NULL
       AND fif.id_flex_structure_code        IS NULL
     UNION
    SELECT xal.acct_coa_id_flex_struct_code
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_id_flex_structures fif
           ON  fif.application_id         = 101
           AND fif.id_flex_code           = 'GL#'
           AND fif.id_flex_structure_code = xal.acct_coa_id_flex_struct_code
     WHERE xal.staging_amb_context_code     = p_staging_context_code
       AND xal.acct_coa_id_flex_struct_code IS NOT NULL
       AND fif.id_flex_structure_code       IS NULL;

  CURSOR c_invalid_value_set IS
    SELECT xal.flex_value_set_name
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_flex_value_sets val
           ON  val.flex_value_set_name = xal.flex_value_set_name
     WHERE xal.staging_amb_context_code = p_staging_context_code
       AND xal.flex_value_set_name      IS NOT NULL
       AND val.flex_value_set_id        IS NULL;

  CURSOR c_invalid_app_short_name IS
    SELECT xal.source_app_short_name app_short_name
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_application fap
           ON  fap.application_short_name = xal.source_app_short_name
     WHERE xal.staging_amb_context_code   = p_staging_context_code
       AND xal.source_app_short_name      IS NOT NULL
       AND fap.application_id             IS NULL
     UNION
    SELECT xal.value_source_app_short_name
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_application fap
           ON  fap.application_short_name = xal.value_source_app_short_name
     WHERE xal.staging_amb_context_code    = p_staging_context_code
       AND xal.value_source_app_short_name IS NOT NULL
       AND fap.application_id              IS NULL
     UNION
    SELECT xal.view_app_short_name
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_application fap
           ON  fap.application_short_name = xal.view_app_short_name
     WHERE xal.staging_amb_context_code   = p_staging_context_code
       AND xal.view_app_short_name        IS NOT NULL
       AND fap.application_id             IS NULL
     UNION
    SELECT xal.application_short_name
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_application fap
           ON  fap.application_short_name = xal.application_short_name
     WHERE xal.staging_amb_context_code   = p_staging_context_code
       AND xal.application_short_name     IS NOT NULL
       AND fap.application_id             IS NULL
     UNION
    SELECT xal.input_source_app_short_name
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_application fap
           ON  fap.application_short_name  = xal.input_source_app_short_name
     WHERE xal.staging_amb_context_code    = p_staging_context_code
       AND xal.input_source_app_short_name IS NOT NULL
       AND fap.application_id              IS NULL
     UNION
    SELECT xal.value_segment_rule_appl_sn
      FROM xla_aad_loader_defns_t xal
           LEFT OUTER JOIN fnd_application fap
           ON  fap.application_short_name = xal.value_segment_rule_appl_sn
     WHERE xal.staging_amb_context_code   = p_staging_context_code
       AND xal.value_segment_rule_appl_sn IS NOT NULL
       AND fap.application_id             IS NULL;

  l_size              INTEGER;
  l_retcode           VARCHAR2(30);
  l_log_module        VARCHAR2(240);
  l_exception	      VARCHAR2(250);
  l_excp_code         VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validation';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  OPEN c_file_size;
  FETCH c_file_size INTO l_size;
  CLOSE c_file_size;

  IF (C_LEVEL_ERROR >= g_log_level) THEN
    trace(p_msg    => 'LOOP: c_file_size',
          p_module => l_log_module,
          p_level  => C_LEVEL_ERROR);
  END IF;

  IF (l_size <= 0) THEN
    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_EMPTY_LDT');
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_invalid_app',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l IN c_invalid_app LOOP
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_invalid_app',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_INV_APP'
               ,p_token_1         => 'FILE_APP_NAME'
               ,p_value_1         => l.file_app_name
               ,p_token_2         => 'RESP_APP_NAME'
               ,p_value_2         => l.resp_app_name);
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_invalid_app',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;




-- krsankar - Opening 2 new cursors added as part of P1 Bug 6975482.
/* Adding all the Unique index columns in the DELETE to make sure that
   duplicate data is getting deleted only for the unique columns across
   these 2 analytical tables. - Modified this as part of bug 8268819*/

IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_del_dup_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
END IF;

FOR i IN c_del_dup_name LOOP

 DELETE FROM xla_aad_loader_defns_t
 WHERE staging_amb_context_code     = p_staging_context_code
 AND upper(table_name)              = ('XLA_ANALYTICAL_HDRS')
 AND analytical_criterion_code      = i.analytical_criterion_code
 AND analytical_criterion_type_code = i.analytical_criterion_type_code   --Added for bug 8268819
 AND rowid NOT IN (select max(rowid) from xla_aad_loader_defns_t
                   where staging_amb_context_code = p_staging_context_code
                   and upper(table_name) = ('XLA_ANALYTICAL_HDRS')
		   and analytical_criterion_code=i.analytical_criterion_code
	           and analytical_criterion_type_code = i.analytical_criterion_type_code   --Added for bug 8268819
                   group by analytical_criterion_code,analytical_criterion_type_code);


 IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'LOOP: c_del_dup_name : Rows Deleted - '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
 END IF;


 END LOOP;

 IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_del_dup_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
 END IF;



 IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_del_dup_name_anal_sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
 END IF;

 FOR i IN c_del_dup_name_anal_sources LOOP


 DELETE FROM xla_aad_loader_defns_t
 WHERE staging_amb_context_code     = p_staging_context_code
 AND upper(table_name)              = ('XLA_ANALYTICAL_SOURCES')
 AND analytical_criterion_type_code = i.analytical_criterion_type_code
 AND analytical_criterion_code      = i.analytical_criterion_code
 AND analytical_detail_code         = i.analytical_detail_code
 AND entity_code                    = i.entity_code
 AND event_class_code               = i.event_class_code
 AND source_code                    = i.source_code
 AND source_type_code               = i.source_type_code
 AND rowid NOT IN (select max(rowid) from xla_aad_loader_defns_t
                   WHERE staging_amb_context_code     = p_staging_context_code
                   AND upper(table_name)              = ('XLA_ANALYTICAL_SOURCES')
                   AND analytical_criterion_type_code = i.analytical_criterion_type_code
                   AND analytical_criterion_code      = i.analytical_criterion_code
                   AND analytical_detail_code         = i.analytical_detail_code
                   AND entity_code                    = i.entity_code
                   AND event_class_code               = i.event_class_code
                   AND source_code                    = i.source_code
                   AND source_type_code               = i.source_type_code
                   group by analytical_criterion_type_code,analytical_criterion_code,analytical_detail_code,
		            entity_code,event_class_code,source_code,source_type_code);


 IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'LOOP: c_del_dup_name_anal_sources : Rows Deleted - '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
 END IF;

 END LOOP;

 IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_del_dup_name_anal_sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
 END IF;

-- krsankar - End of opening 2 new cursors added as part of P1 Bug 6975482.


  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_dup_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;


  FOR l IN c_dup_name LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_dup_name',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_DUP_NAME'
               ,p_token_1         => 'COMPONENT_NAME'
               ,p_value_1         => l.name
               ,p_token_2         => 'COMPONENT_TYPE'
               ,p_value_2         => l.table_name);

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_dup_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_dup_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l IN c_dup_code LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_dup_code',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_DUP_CODE'
               ,p_token_1         => 'CODE'
               ,p_value_1         => l.code
               ,p_token_2         => 'COMPONENT_TYPE'
               ,p_value_2         => l.table_name);

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_dup_code',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_invalid_coa',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l IN c_invalid_coa LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_invalid_coa',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_INVALID_COA'
               ,p_token_1         => 'STRUCT_CODE'
               ,p_value_1         => l.id_flex_struct_code);

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_invalid_coa',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_invalid_value_set',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l IN c_invalid_value_set LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_invalid_value_set',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_INVALID_VALUE_SET'
               ,p_token_1         => 'VALUE_SET_NAME'
               ,p_value_1         => l.flex_value_set_name);

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_invalid_value_set',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: c_invalid_app_short_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l IN c_invalid_app_short_name LOOP

    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP: c_invalid_app_short_name',
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;

    l_retcode := 'WARNING';
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_UPL_INVALID_APP_SN'
               ,p_token_1         => 'VALUE_SET_NAME'
               ,p_value_1         => 'l.app_short_name');

  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: c_invalid_app_short_name',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END of function validation',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  RETURN l_retcode;
EXCEPTION

WHEN OTHERS THEN
  l_retcode := 'ERROR';

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.validation is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.validation'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;
END;


--=============================================================================
--
-- Name: populate_descriptions
-- Description: This API populates the description data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_descriptions
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(250);
  l_excp_code     VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_descriptions';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_descriptions_b
  (application_id
  ,amb_context_code
  ,description_type_code
  ,description_code
  ,transaction_coa_id
  ,enabled_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,description_type_code
  ,description_code
  ,flex.id_flex_num
  ,i.enabled_flag
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t i
       ,fnd_id_flex_structures   flex
  WHERE flex.application_id(+)         = 101
    AND flex.id_flex_code(+)           = 'GL#'
    AND flex.id_flex_structure_code(+) = trans_coa_id_flex_struct_code
    AND table_name                     = 'XLA_DESCRIPTIONS'
    AND staging_amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_DESCRIPTIONS_B) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_descriptions_tl
  (application_id
  ,amb_context_code
  ,description_type_code
  ,description_code
  ,language
  ,name
  ,description
  ,source_lang
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,description_type_code
  ,description_code
  ,fl.language_code
  ,name
  ,description
  ,USERENV('LANG')
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t    xal
       ,fnd_languages               fl
  WHERE xal.table_name                  = 'XLA_DESCRIPTIONS'
    AND xal.staging_amb_context_code    = p_staging_context_code
    AND fl.installed_flag               IN ('I', 'B');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_DESCRIPTIONS_TL) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_desc_priorities
  (application_id
  ,amb_context_code
  ,description_type_code
  ,description_code
  ,description_prio_id
  ,user_sequence
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,description_type_code
  ,description_code
  ,xla_desc_priorities_s.nextval
  ,priority_num
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_DESC_PRIORITIES'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_DESC_PRIORITIES) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_descript_details_b
  (amb_context_code
  ,description_detail_id
  ,description_prio_id
  ,user_sequence
  ,value_type_code
  ,source_application_id
  ,source_type_code
  ,source_code
  ,flexfield_segment_code
  ,display_description_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,xla_descript_details_s.nextval
  ,p.description_prio_id
  ,xal.user_sequence
  ,value_type_code
  ,fap.application_id
  ,source_type_code
  ,source_code
  ,flexfield_segment_code
  ,display_description_flag
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,xla_desc_priorities         p
       ,fnd_application             fap
  WHERE fap.application_short_name(+) = xal.source_app_short_name
    AND p.user_sequence               = xal.priority_num
    AND p.description_type_code       = xal.description_type_code
    AND p.description_code            = xal.description_code
    AND p.amb_context_code            = p_staging_context_code
    AND p.application_id              = p_application_id
    AND table_name                    = 'XLA_DESCRIPT_DETAILS'
    AND staging_amb_context_code      = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_DESCRIPT_DETAILS_B) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_descript_details_tl
  (amb_context_code
  ,description_detail_id
  ,language
  ,literal
  ,source_lang
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,xdd.description_detail_id
  ,fl.language_code
  ,literal
  ,USERENV('LANG')
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t    xal
       ,xla_descript_details_b      xdd
       ,xla_desc_priorities         xdp
       ,fnd_languages               fl
  WHERE xdd.description_prio_id         = xdp.description_prio_id
    AND xdd.user_sequence               = xal.user_sequence
    AND xdp.user_sequence               = xal.priority_num
    AND xdp.description_type_code       = xal.description_type_code
    AND xdp.description_code            = xal.description_code
    AND xdp.amb_context_code            = p_staging_context_code
    AND xdp.application_id              = p_application_id
    AND xal.table_name                  = 'XLA_DESCRIPT_DETAILS'
    AND xal.staging_amb_context_code    = p_staging_context_code
    AND fl.installed_flag               IN ('I', 'B');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_DESCRIPT_DETAILS_TL) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_conditions
  (amb_context_code
  ,condition_id
  ,user_sequence
  ,application_id
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
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,xla_conditions_s.nextval
  ,xal.condition_num
  ,p_application_id
  ,description_prio_id
  ,bracket_left_code
  ,bracket_right_code
  ,value_type_code
  ,fap.application_id
  ,source_type_code
  ,source_code
  ,flexfield_segment_code
  ,value_flexfield_segment_code
  ,fap2.application_id
  ,value_source_type_code
  ,value_source_code
  ,value_constant
  ,line_operator_code
  ,logical_operator_code
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t        xal
       ,xla_desc_priorities           p
       ,fnd_application               fap
       ,fnd_application               fap2
  WHERE fap.application_short_name(+) = xal.source_app_short_name
    AND fap2.application_short_name(+)= xal.value_source_app_short_name
    AND p.user_sequence               = xal.priority_num
    AND p.description_type_code       = xal.description_type_code
    AND p.description_code            = xal.description_code
    AND p.amb_context_code            = p_staging_context_code
    AND p.application_id              = p_application_id
    AND table_name                    = 'XLA_DESC_CONDITIONS'
    AND staging_amb_context_code      = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_DESC_CONDITIONS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_descriptions is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_descriptions'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_descriptions;

--=============================================================================
--
-- Name: populate_mapping_sets
-- Description: This API populates the mapping set data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
FUNCTION populate_mapping_sets
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_ccid IS
    SELECT  DISTINCT
            xal.mapping_set_code
           ,fif.id_flex_num
           ,fif.id_flex_structure_code
           ,xal.value_ccid_segment1
           ,xal.value_ccid_segment2
           ,xal.value_ccid_segment3
           ,xal.value_ccid_segment4
           ,xal.value_ccid_segment5
           ,xal.value_ccid_segment6
           ,xal.value_ccid_segment7
           ,xal.value_ccid_segment8
           ,xal.value_ccid_segment9
           ,xal.value_ccid_segment10
           ,xal.value_ccid_segment11
           ,xal.value_ccid_segment12
           ,xal.value_ccid_segment13
           ,xal.value_ccid_segment14
           ,xal.value_ccid_segment15
           ,xal.value_ccid_segment16
           ,xal.value_ccid_segment17
           ,xal.value_ccid_segment18
           ,xal.value_ccid_segment19
           ,xal.value_ccid_segment20
           ,xal.value_ccid_segment21
           ,xal.value_ccid_segment22
           ,xal.value_ccid_segment23
           ,xal.value_ccid_segment24
           ,xal.value_ccid_segment25
           ,xal.value_ccid_segment26
           ,xal.value_ccid_segment27
           ,xal.value_ccid_segment28
           ,xal.value_ccid_segment29
           ,xal.value_ccid_segment30
      FROM xla_aad_loader_defns_t xal
          ,fnd_id_flex_structures fif
     WHERE xal.table_name               = 'XLA_MAPPING_SET_VALUES'
       AND xal.staging_amb_context_code = p_staging_context_code
       AND fif.application_id           = 101
       AND fif.id_flex_code             = 'GL#'
       AND fif.id_flex_structure_code   = xal.value_ccid_id_flex_struct_code;

  CURSOR c_mapping_set(p_mapping_set_code VARCHAR2) IS
    SELECT name
      FROM xla_mapping_sets_tl
     WHERE mapping_set_code  = p_mapping_set_code
       AND language          = USERENV('LANG');

  l_seg                     FND_FLEX_EXT.SegmentArray;
  l_code_combination_id     INTEGER;
  l_mapping_set_name        VARCHAR2(80);
  l_error_found             BOOLEAN;
  l_num_rows                INTEGER;
  l_log_module              VARCHAR2(240);
  l_exception               VARCHAR2(250);
  l_excp_code               VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_mapping_sets';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_mapping_sets_b
  (amb_context_code
  ,mapping_set_code
  ,accounting_coa_id
  ,value_set_id
  ,flexfield_assign_mode_code
  ,flexfield_segment_code
  ,enabled_flag
  ,view_application_id
  ,lookup_type
  ,version_num
  ,updated_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,mapping_set_code
  ,flex.id_flex_num
  ,val.flex_value_set_id
  ,flexfield_assign_mode_code
  ,flexfield_segment_code
  ,xal.enabled_flag
  ,fap.application_id
  ,lookup_type
  ,NVL(version_num,1)
  ,'N'
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,fnd_application          fap
       ,fnd_id_flex_structures   flex
       ,fnd_flex_value_sets      val
  WHERE fap.application_short_name(+)  = xal.view_app_short_name
    AND val.flex_value_set_name(+)     = xal.flex_value_set_name
    AND flex.id_flex_code              = 'GL#'
    AND flex.application_id            = 101
    AND flex.id_flex_structure_code    = xal.acct_coa_id_flex_struct_code
    AND table_name                     = 'XLA_MAPPING_SETS'
    AND staging_amb_context_code       = p_staging_context_code;

  l_num_rows := SQL%ROWCOUNT;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_MAPPING_SETS_B) = '||l_num_rows,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_num_rows > 0) THEN

    INSERT INTO xla_mapping_sets_tl
    (amb_context_code
    ,mapping_set_code
    ,language
    ,name
    ,description
    ,source_lang
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
    SELECT
     p_staging_context_code
    ,mapping_set_code
    ,fl.language_code
    ,name
    ,description
    ,USERENV('LANG')
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,0
    FROM  xla_aad_loader_defns_t      xal
         ,fnd_languages               fl
    WHERE xal.table_name                  = 'XLA_MAPPING_SETS'
      AND xal.staging_amb_context_code    = p_staging_context_code
      AND fl.installed_flag               IN ('I', 'B');

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# insert (XLA_MAPPING_SETS_TL) = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP - Retrieve CCID for XLA_MAPPING_SET_VALUES.view_code_combination_id',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    FOR l_ccid IN c_ccid LOOP
      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'LOOP Retrieve CCID: '||l_ccid.mapping_set_code,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      l_seg(1) := l_ccid.value_ccid_segment1;
      l_seg(2) := l_ccid.value_ccid_segment2;
      l_seg(3) := l_ccid.value_ccid_segment3;
      l_seg(4) := l_ccid.value_ccid_segment4;
      l_seg(5) := l_ccid.value_ccid_segment5;
      l_seg(6) := l_ccid.value_ccid_segment6;
      l_seg(7) := l_ccid.value_ccid_segment7;
      l_seg(8) := l_ccid.value_ccid_segment8;
      l_seg(9) := l_ccid.value_ccid_segment9;
      l_seg(10) := l_ccid.value_ccid_segment10;
      l_seg(11) := l_ccid.value_ccid_segment11;
      l_seg(12) := l_ccid.value_ccid_segment12;
      l_seg(13) := l_ccid.value_ccid_segment13;
      l_seg(14) := l_ccid.value_ccid_segment14;
      l_seg(15) := l_ccid.value_ccid_segment15;
      l_seg(16) := l_ccid.value_ccid_segment16;
      l_seg(17) := l_ccid.value_ccid_segment17;
      l_seg(18) := l_ccid.value_ccid_segment18;
      l_seg(19) := l_ccid.value_ccid_segment19;
      l_seg(20) := l_ccid.value_ccid_segment20;
      l_seg(21) := l_ccid.value_ccid_segment21;
      l_seg(22) := l_ccid.value_ccid_segment22;
      l_seg(23) := l_ccid.value_ccid_segment23;
      l_seg(24) := l_ccid.value_ccid_segment24;
      l_seg(25) := l_ccid.value_ccid_segment25;
      l_seg(26) := l_ccid.value_ccid_segment26;
      l_seg(27) := l_ccid.value_ccid_segment27;
      l_seg(28) := l_ccid.value_ccid_segment28;
      l_seg(29) := l_ccid.value_ccid_segment29;
      l_seg(30) := l_ccid.value_ccid_segment30;

      IF (FND_FLEX_EXT.get_combination_id(
                  application_short_name    => 'SQLGL',
                  key_flex_code             => 'GL#',
                  structure_number          => l_ccid.id_flex_num,
                  validation_date           => null,
                  n_segments                => 30,
                  segments                  => l_seg,
                  combination_id            => l_code_combination_id) = FALSE)
      THEN

        OPEN c_mapping_set(l_ccid.mapping_set_code);
        FETCH c_mapping_set INTO l_mapping_set_name;
        CLOSE c_mapping_set;

        xla_aad_loader_util_pvt.stack_error
                 (p_appli_s_name    => 'XLA'
                 ,p_msg_name        => 'XLA_AAD_IMP_INV_CCID_MS_VALUE'
                 ,p_token_1         => 'MAPPING_SET'
                 ,p_value_1         => l_mapping_set_name);
        l_error_found := TRUE;
      ELSE
        UPDATE xla_aad_loader_defns_t
           SET value_code_combination_id        = l_code_combination_id
         WHERE staging_amb_context_code         = p_staging_context_code
           AND mapping_set_code                 = l_ccid.mapping_set_code
           AND value_ccid_id_flex_struct_code   = l_ccid.id_flex_structure_code
           AND nvl(value_ccid_segment1,C_CHAR)  = nvl(l_ccid.value_ccid_segment1,C_CHAR)
           AND nvl(value_ccid_segment2,C_CHAR)  = nvl(l_ccid.value_ccid_segment2,C_CHAR)
           AND nvl(value_ccid_segment3,C_CHAR)  = nvl(l_ccid.value_ccid_segment3,C_CHAR)
           AND nvl(value_ccid_segment4,C_CHAR)  = nvl(l_ccid.value_ccid_segment4,C_CHAR)
           AND nvl(value_ccid_segment5,C_CHAR)  = nvl(l_ccid.value_ccid_segment5,C_CHAR)
           AND nvl(value_ccid_segment6,C_CHAR)  = nvl(l_ccid.value_ccid_segment6,C_CHAR)
           AND nvl(value_ccid_segment7,C_CHAR)  = nvl(l_ccid.value_ccid_segment7,C_CHAR)
           AND nvl(value_ccid_segment8,C_CHAR)  = nvl(l_ccid.value_ccid_segment8,C_CHAR)
           AND nvl(value_ccid_segment9,C_CHAR)  = nvl(l_ccid.value_ccid_segment9,C_CHAR)
           AND nvl(value_ccid_segment10,C_CHAR) = nvl(l_ccid.value_ccid_segment10,C_CHAR)
           AND nvl(value_ccid_segment11,C_CHAR) = nvl(l_ccid.value_ccid_segment11,C_CHAR)
           AND nvl(value_ccid_segment12,C_CHAR) = nvl(l_ccid.value_ccid_segment12,C_CHAR)
           AND nvl(value_ccid_segment13,C_CHAR) = nvl(l_ccid.value_ccid_segment13,C_CHAR)
           AND nvl(value_ccid_segment14,C_CHAR) = nvl(l_ccid.value_ccid_segment14,C_CHAR)
           AND nvl(value_ccid_segment15,C_CHAR) = nvl(l_ccid.value_ccid_segment15,C_CHAR)
           AND nvl(value_ccid_segment16,C_CHAR) = nvl(l_ccid.value_ccid_segment16,C_CHAR)
           AND nvl(value_ccid_segment17,C_CHAR) = nvl(l_ccid.value_ccid_segment17,C_CHAR)
           AND nvl(value_ccid_segment18,C_CHAR) = nvl(l_ccid.value_ccid_segment18,C_CHAR)
           AND nvl(value_ccid_segment19,C_CHAR) = nvl(l_ccid.value_ccid_segment19,C_CHAR)
           AND nvl(value_ccid_segment20,C_CHAR) = nvl(l_ccid.value_ccid_segment20,C_CHAR)
           AND nvl(value_ccid_segment21,C_CHAR) = nvl(l_ccid.value_ccid_segment21,C_CHAR)
           AND nvl(value_ccid_segment22,C_CHAR) = nvl(l_ccid.value_ccid_segment22,C_CHAR)
           AND nvl(value_ccid_segment23,C_CHAR) = nvl(l_ccid.value_ccid_segment23,C_CHAR)
           AND nvl(value_ccid_segment24,C_CHAR) = nvl(l_ccid.value_ccid_segment24,C_CHAR)
           AND nvl(value_ccid_segment25,C_CHAR) = nvl(l_ccid.value_ccid_segment25,C_CHAR)
           AND nvl(value_ccid_segment26,C_CHAR) = nvl(l_ccid.value_ccid_segment26,C_CHAR)
           AND nvl(value_ccid_segment27,C_CHAR) = nvl(l_ccid.value_ccid_segment27,C_CHAR)
           AND nvl(value_ccid_segment28,C_CHAR) = nvl(l_ccid.value_ccid_segment28,C_CHAR)
           AND nvl(value_ccid_segment29,C_CHAR) = nvl(l_ccid.value_ccid_segment29,C_CHAR)
           AND nvl(value_ccid_segment30,C_CHAR) = nvl(l_ccid.value_ccid_segment30,C_CHAR);
      END IF;
    END LOOP;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'END LOOP - Retrieve CCID for XLA_MAPPING_SET_VALUES.view_code_combination_id',
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    INSERT INTO xla_mapping_set_values
    (mapping_set_value_id
    ,amb_context_code
    ,mapping_set_code
    ,value_constant
    ,value_code_combination_id
    ,effective_date_from
    ,effective_date_to
    ,enabled_flag
    ,input_value_type_code
    ,input_value_constant
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
    SELECT
     xla_mapping_set_values_s.nextval
    ,p_staging_context_code
    ,mapping_set_code
    ,value_constant
    ,value_code_combination_id
    ,effective_date_from
    ,effective_date_to
    ,enabled_flag
    ,input_value_type_code
    ,input_value_constant
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,0
    FROM  xla_aad_loader_defns_t      xal
    WHERE table_name                  = 'XLA_MAPPING_SET_VALUES'
      AND staging_amb_context_code    = p_staging_context_code;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# insert (XLA_MAPPING_SET_VALUES) = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

  END IF;

  IF (l_error_found) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_adrs: ERROR',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'WARNING';

WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_mapping_sets is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_mapping_sets'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_mapping_sets;

--=============================================================================
--
-- Name: populate_analytical_criteria
-- Description: This API populates the analytical criteria data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_analytical_criteria
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
IS
  l_num_rows      INTEGER;
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(240);
  l_excp_code     VARCHAR2(100);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_analytical_criteria';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_analytical_hdrs_b
  (amb_context_code
  ,analytical_criterion_type_code
  ,analytical_criterion_code
  ,application_id
  ,balancing_flag
  ,display_order
  ,enabled_flag
  ,year_end_carry_forward_code
  ,display_in_inquiries_flag
  ,criterion_value_code
  ,version_num
  ,updated_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,analytical_criterion_type_code
  ,analytical_criterion_code
  ,fap.application_id
  ,balancing_flag
  ,display_order
  ,enabled_flag
  ,year_end_carry_forward_code
  ,display_in_inquiries_flag
  ,criterion_value_code
  ,NVL(version_num,1)
  ,'N'
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,fnd_application          fap
  WHERE fap.application_short_name(+)  = xal.application_short_name
    AND table_name                     = 'XLA_ANALYTICAL_HDRS'
    AND staging_amb_context_code       = p_staging_context_code;

  l_num_rows := SQL%ROWCOUNT;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_ANALYTICAL_HDRS_B) = '||l_num_rows,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_num_rows > 0) THEN
    INSERT INTO xla_analytical_hdrs_tl
    (amb_context_code
    ,analytical_criterion_type_code
    ,analytical_criterion_code
    ,language
    ,name
    ,description
    ,source_lang
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
    SELECT
     p_staging_context_code
    ,analytical_criterion_type_code
    ,analytical_criterion_code
    ,fl.language_code
    ,name
    ,description
    ,USERENV('LANG')
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,0
    FROM  xla_aad_loader_defns_t      xal
         ,fnd_languages               fl
    WHERE xal.table_name                  = 'XLA_ANALYTICAL_HDRS'
      AND xal.staging_amb_context_code    = p_staging_context_code
      AND fl.installed_flag               IN ('I', 'B');

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# insert (XLA_ANALYTICAL_HDRS_TL) = '||SQL%ROWCOUNT,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;
END IF; -- krsankar - Bug 7243326 - End of IF condition for l_num_rows for analytical_hdrs_tl table


    INSERT INTO xla_analytical_dtls_b
    (amb_context_code
    ,analytical_criterion_type_code
    ,analytical_criterion_code
    ,analytical_detail_code
    ,data_type_code
    ,grouping_order
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
    SELECT
     p_staging_context_code
    ,analytical_criterion_type_code
    ,analytical_criterion_code
    ,analytical_detail_code
    ,data_type_code
    ,grouping_order
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
    ,fnd_load_util.owner_id(owner)
    ,0
    FROM  xla_aad_loader_defns_t         xal
    WHERE table_name                     = 'XLA_ANALYTICAL_DTLS'
      AND staging_amb_context_code       = p_staging_context_code;

    l_num_rows := SQL%ROWCOUNT;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => '# insert (XLA_ANALYTICAL_DTLS_B) = '||l_num_rows,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;


    IF (l_num_rows > 0) THEN
      INSERT INTO xla_analytical_dtls_tl
      (amb_context_code
      ,analytical_criterion_type_code
      ,analytical_criterion_code
      ,analytical_detail_code
      ,language
      ,name
      ,description
      ,source_lang
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login)
      SELECT
       p_staging_context_code
      ,analytical_criterion_type_code
      ,analytical_criterion_code
      ,analytical_detail_code
      ,fl.language_code
      ,name
      ,description
      ,USERENV('LANG')
      ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
      ,fnd_load_util.owner_id(owner)
      ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
      ,fnd_load_util.owner_id(owner)
      ,0
      FROM  xla_aad_loader_defns_t      xal
           ,fnd_languages               fl
      WHERE xal.table_name                  = 'XLA_ANALYTICAL_DTLS'
        AND xal.staging_amb_context_code    = p_staging_context_code
        AND fl.installed_flag               IN ('I', 'B');

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => '# insert (XLA_ANALYTICAL_DTLS_TL) = '||SQL%ROWCOUNT,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      INSERT INTO xla_analytical_sources
      (amb_context_code
      ,analytical_criterion_type_code
      ,analytical_criterion_code
      ,analytical_detail_code
      ,entity_code
      ,event_class_code
      ,application_id
      ,source_code
      ,source_type_code
      ,source_application_id
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login)
      SELECT
       p_staging_context_code
      ,analytical_criterion_type_code
      ,analytical_criterion_code
      ,analytical_detail_code
      ,entity_code
      ,event_class_code
      ,fap.application_id
      ,source_code
      ,source_type_code
      ,fap2.application_id
      ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
      ,fnd_load_util.owner_id(owner)
      ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
      ,fnd_load_util.owner_id(owner)
      ,0
      FROM  xla_aad_loader_defns_t      xal
           ,fnd_application             fap
           ,fnd_application             fap2
      WHERE fap.application_short_name  = xal.application_short_name
        AND fap2.application_short_name = xal.source_app_short_name
        AND table_name                  = 'XLA_ANALYTICAL_SOURCES'
        AND staging_amb_context_code    = p_staging_context_code;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => '# insert (XLA_ANALYTICAL_SOURCES) = '||SQL%ROWCOUNT,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;
    END IF;  -- Detail exists
--  END IF; -- Header exists -- Commented as part of Bug 7243326 as Header IF is closed immediately after analytical_hdrs_tl table

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION

WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_analytical_criteria',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_analytical_criteria is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_analytical_criteria'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_analytical_criteria;

--=============================================================================
--
-- Name: populate_adrs
-- Description: This API populates the account derivation rule data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
FUNCTION populate_adrs
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_ccid IS
    SELECT  DISTINCT
            xal.segment_rule_type_code
           ,xal.segment_rule_code
           ,xal.user_sequence
           ,fif.id_flex_num
           ,fif.id_flex_structure_code
           ,xal.value_ccid_segment1
           ,xal.value_ccid_segment2
           ,xal.value_ccid_segment3
           ,xal.value_ccid_segment4
           ,xal.value_ccid_segment5
           ,xal.value_ccid_segment6
           ,xal.value_ccid_segment7
           ,xal.value_ccid_segment8
           ,xal.value_ccid_segment9
           ,xal.value_ccid_segment10
           ,xal.value_ccid_segment11
           ,xal.value_ccid_segment12
           ,xal.value_ccid_segment13
           ,xal.value_ccid_segment14
           ,xal.value_ccid_segment15
           ,xal.value_ccid_segment16
           ,xal.value_ccid_segment17
           ,xal.value_ccid_segment18
           ,xal.value_ccid_segment19
           ,xal.value_ccid_segment20
           ,xal.value_ccid_segment21
           ,xal.value_ccid_segment22
           ,xal.value_ccid_segment23
           ,xal.value_ccid_segment24
           ,xal.value_ccid_segment25
           ,xal.value_ccid_segment26
           ,xal.value_ccid_segment27
           ,xal.value_ccid_segment28
           ,xal.value_ccid_segment29
           ,xal.value_ccid_segment30
      FROM xla_aad_loader_defns_t xal
          ,fnd_id_flex_structures fif
     WHERE xal.table_name               = 'XLA_SEG_RULE_DETAILS'
       AND xal.staging_amb_context_code = p_staging_context_code
       AND fif.application_id           = 101
       AND fif.id_flex_code             = 'GL#'
       AND fif.id_flex_structure_code   = xal.value_ccid_id_flex_struct_code;

  CURSOR c_seg_rule(p_seg_rule_type_code   VARCHAR2
                   ,p_seg_rule_code        VARCHAR2) IS
    SELECT xsrt.name
          ,xlk.meaning seg_rule_owner
      FROM xla_seg_rules_tl       xsrt
          ,xla_lookups            xlk
     WHERE xsrt.segment_rule_type_code  = p_seg_rule_type_code
       AND xsrt.segment_rule_code       = p_seg_rule_code
       AND xsrt.amb_context_code        = p_staging_context_code
       AND xsrt.application_id          = p_application_id
       AND xsrt.language                = USERENV('LANG')
       AND xlk.lookup_type              = 'XLA_OWNER_TYPE'
       AND xlk.lookup_code              = p_seg_rule_type_code;

  i                         INTEGER;
  l_seg                     FND_FLEX_EXT.SegmentArray;
  l_code_combination_id     INTEGER;
  l_error_found             BOOLEAN;
  l_seg_rule_name           VARCHAR2(80);
  l_seg_rule_owner          VARCHAR2(80);
  l_log_module              VARCHAR2(240);
  l_exception               VARCHAR2(250);
  l_excp_code               VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_adrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_error_found := FALSE;

  INSERT INTO xla_seg_rules_b
  (application_id
  ,amb_context_code
  ,segment_rule_type_code
  ,segment_rule_code
  ,transaction_coa_id
  ,accounting_coa_id
  ,flexfield_assign_mode_code
  ,flexfield_segment_code
  ,flex_value_set_id
  ,enabled_flag
  ,version_num
  ,updated_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,segment_rule_type_code
  ,segment_rule_code
  ,fift.id_flex_num
  ,fifa.id_flex_num
  ,flexfield_assign_mode_code
  ,flexfield_segment_code
  ,val.flex_value_set_id
  ,xal.enabled_flag
  ,NVL(xal.version_num,1)
  ,'N'
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,fnd_id_flex_structures   fift
       ,fnd_id_flex_structures   fifa
       ,fnd_flex_value_sets      val
  WHERE fift.application_id(+)         = 101
    AND fift.id_flex_code(+)           = 'GL#'
    AND fift.id_flex_structure_code(+) = trans_coa_id_flex_struct_code
    AND fifa.application_id(+)         = 101
    AND fifa.id_flex_code(+)           = 'GL#'
    AND fifa.id_flex_structure_code(+) = acct_coa_id_flex_struct_code
    AND val.flex_value_set_name(+)     = xal.flex_value_set_name
    AND table_name                     = 'XLA_SEG_RULES'
    AND staging_amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_SEG_RULES_B) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_seg_rules_tl
  (application_id
  ,amb_context_code
  ,segment_rule_type_code
  ,segment_rule_code
  ,language
  ,name
  ,description
  ,source_lang
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,segment_rule_type_code
  ,segment_rule_code
  ,fl.language_code
  ,name
  ,description
  ,USERENV('LANG')
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_languages               fl
  WHERE xal.table_name                  = 'XLA_SEG_RULES'
    AND xal.staging_amb_context_code    = p_staging_context_code
    AND fl.installed_flag               IN ('I', 'B');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_SEG_RULES_TL) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

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
  ,value_mapping_set_code
  ,value_flexfield_segment_code
  ,value_adr_version_num
  ,value_segment_rule_appl_id
  ,value_segment_rule_type_code
  ,value_segment_rule_code
  ,input_source_application_id
  ,input_source_type_code
  ,input_source_code
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   xla_seg_rule_details_s.nextval
  ,p_application_id
  ,p_staging_context_code
  ,segment_rule_type_code
  ,segment_rule_code
  ,user_sequence
  ,value_type_code
  ,fap.application_id
  ,value_source_type_code
  ,value_source_code
  ,value_constant
  ,value_mapping_set_code
  ,value_flexfield_segment_code
  ,NVL(value_adr_version_num,0)
  ,NVL(fap3.application_id,
       CASE WHEN value_segment_rule_type_code IS NOT NULL
            THEN p_application_id
            ELSE NULL END)
  ,value_segment_rule_type_code
  ,value_segment_rule_code
  ,fap2.application_id
  ,input_source_type_code
  ,input_source_code
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t xal
        LEFT OUTER JOIN fnd_application fap
        ON  fap.application_short_name  = xal.value_source_app_short_name
        LEFT OUTER JOIN fnd_application fap2
        ON  fap2.application_short_name = xal.input_source_app_short_name
        LEFT OUTER JOIN fnd_application fap3
        ON  fap3.application_short_name = xal.value_segment_rule_appl_sn
  WHERE table_name                     = 'XLA_SEG_RULE_DETAILS'
    AND staging_amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_SEG_RULE_DETAILS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - Retrieve CCID for XLA_SEG_RULE_DETAILS.view_code_combination_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_ccid IN c_ccid LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP Retrieve CCID: '||
                        l_ccid.segment_rule_type_code||','||
                        l_ccid.segment_rule_code||','||
                        l_ccid.user_sequence||','||
                        l_ccid.id_flex_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    l_seg(1) := l_ccid.value_ccid_segment1;
    l_seg(2) := l_ccid.value_ccid_segment2;
    l_seg(3) := l_ccid.value_ccid_segment3;
    l_seg(4) := l_ccid.value_ccid_segment4;
    l_seg(5) := l_ccid.value_ccid_segment5;
    l_seg(6) := l_ccid.value_ccid_segment6;
    l_seg(7) := l_ccid.value_ccid_segment7;
    l_seg(8) := l_ccid.value_ccid_segment8;
    l_seg(9) := l_ccid.value_ccid_segment9;
    l_seg(10) := l_ccid.value_ccid_segment10;
    l_seg(11) := l_ccid.value_ccid_segment11;
    l_seg(12) := l_ccid.value_ccid_segment12;
    l_seg(13) := l_ccid.value_ccid_segment13;
    l_seg(14) := l_ccid.value_ccid_segment14;
    l_seg(15) := l_ccid.value_ccid_segment15;
    l_seg(16) := l_ccid.value_ccid_segment16;
    l_seg(17) := l_ccid.value_ccid_segment17;
    l_seg(18) := l_ccid.value_ccid_segment18;
    l_seg(19) := l_ccid.value_ccid_segment19;
    l_seg(20) := l_ccid.value_ccid_segment20;
    l_seg(21) := l_ccid.value_ccid_segment21;
    l_seg(22) := l_ccid.value_ccid_segment22;
    l_seg(23) := l_ccid.value_ccid_segment23;
    l_seg(24) := l_ccid.value_ccid_segment24;
    l_seg(25) := l_ccid.value_ccid_segment25;
    l_seg(26) := l_ccid.value_ccid_segment26;
    l_seg(27) := l_ccid.value_ccid_segment27;
    l_seg(28) := l_ccid.value_ccid_segment28;
    l_seg(29) := l_ccid.value_ccid_segment29;
    l_seg(30) := l_ccid.value_ccid_segment30;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      FOR i IN 1..30 LOOP
        trace(p_msg    => 'l_seg('||i||') = '||l_seg(i),
              p_module => l_log_module,
              p_level  => C_LEVEL_STATEMENT);
      END LOOP;
    END IF;

    IF (FND_FLEX_EXT.get_combination_id(
                application_short_name    => 'SQLGL',
                key_flex_code             => 'GL#',
                structure_number          => l_ccid.id_flex_num,
                validation_date           => null,
                n_segments                => 30,
                segments                  => l_seg,
                combination_id            => l_code_combination_id) = FALSE) THEN

      OPEN c_seg_rule(l_ccid.segment_rule_type_code
                     ,l_ccid.segment_rule_code);
      FETCH c_seg_rule INTO l_seg_rule_name, l_seg_rule_owner;
      CLOSE c_seg_rule;

      xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_AAD_IMP_INV_CCID_ADR_DET'
               ,p_token_1         => 'SEG_RULE'
               ,p_value_1         => l_seg_rule_name
               ,p_token_2         => 'OWNER'
               ,p_value_2         => l_seg_rule_owner
               ,p_token_3         => 'USER_SEQUENCE'
               ,p_value_3         => l_ccid.user_sequence);
      l_error_found := TRUE;
    ELSE
      UPDATE xla_seg_rule_details
         SET value_code_combination_id = l_code_combination_id
       WHERE amb_context_code          = p_staging_context_code
         AND application_id            = p_application_id
         AND segment_rule_type_code    = l_ccid.segment_rule_type_code
         AND segment_rule_code         = l_ccid.segment_rule_code
         AND user_sequence             = l_ccid.user_sequence;
    END IF;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - Retrieve CCID for XLA_SEG_RULE_DETAILS.view_code_combination_id',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_conditions
  (amb_context_code
  ,condition_id
  ,user_sequence
  ,application_id
  ,segment_rule_detail_id
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
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,xla_conditions_s.nextval
  ,xal.condition_num
  ,p_application_id
  ,segment_rule_detail_id
  ,xal.bracket_left_code
  ,xal.bracket_right_code
  ,xal.value_type_code
  ,fap.application_id
  ,xal.source_type_code
  ,xal.source_code
  ,xal.flexfield_segment_code
  ,xal.value_flexfield_segment_code
  ,fap2.application_id
  ,xal.value_source_type_code
  ,xal.value_source_code
  ,xal.value_constant
  ,xal.line_operator_code
  ,xal.logical_operator_code
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,xla_seg_rule_details        d
       ,fnd_application             fap
       ,fnd_application             fap2
  WHERE fap.application_short_name(+) = xal.source_app_short_name
    AND fap2.application_short_name(+)= xal.value_source_app_short_name
    AND d.user_sequence               = xal.user_sequence
    AND d.segment_rule_type_code      = xal.segment_rule_type_code
    AND d.segment_rule_code           = xal.segment_rule_code
    AND d.amb_context_code            = p_staging_context_code
    AND d.application_id              = p_application_id
    AND table_name                    = 'XLA_ADR_CONDITIONS'
    AND staging_amb_context_code      = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_ADR_CONDITIONS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (l_error_found) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_adrs: ERROR',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'WARNING';

WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_adrs is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_adrs'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_adrs;

--=============================================================================
--
-- Name: populate_journal_line_types
-- Description: This API populates the journal line type data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_journal_line_types
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(250);
  l_excp_code     VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_journal_line_types';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_journal_line_types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_acct_line_types_b
  (application_id
  ,amb_context_code
  ,entity_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,transaction_coa_id
  ,accounting_entry_type_code
  ,natural_side_code
  ,gl_transfer_mode_code
  ,switch_side_flag
  ,gain_or_loss_flag
  ,merge_duplicate_code
  ,enabled_flag
  ,accounting_class_code
  ,business_method_code
  ,business_class_code
  ,rounding_class_code
  ,encumbrance_type_id
  ,mpa_option_code
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,xal.entity_code
  ,xal.event_class_code
  ,xal.accounting_line_type_code
  ,xal.accounting_line_code
  ,flex.id_flex_num
  ,xal.accounting_entry_type_code
  ,xal.natural_side_code
  ,xal.gl_transfer_mode_code
  ,xal.switch_side_flag
  ,xal.inherit_desc_flag
  ,xal.merge_duplicate_code
  ,xal.enabled_flag
  ,xal.accounting_class_code
  ,NVL(xal.business_method_code,'NONE')
  ,xal.business_class_code
  ,NVL(xal.rounding_class_code,xal.accounting_class_code)
  ,get.encumbrance_type_id
  ,NVL(xal.mpa_option_code,'NONE')
  ,nvl(to_date(xal.orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(xal.owner)
  ,nvl(to_date(xal.orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(xal.owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,fnd_id_flex_structures   flex
       ,gl_encumbrance_types     get
  WHERE flex.application_id(+)         = 101
    AND flex.id_flex_code(+)           = 'GL#'
    AND flex.id_flex_structure_code(+) = trans_coa_id_flex_struct_code
    AND get.encumbrance_type_key(+)    = xal.encumbrance_type
    AND table_name                     = 'XLA_ACCT_LINE_TYPES'
    AND staging_amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_ACCT_LINE_TYPES_B) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_acct_line_types_tl
  (application_id
  ,amb_context_code
  ,entity_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,language
  ,name
  ,description
  ,source_lang
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,entity_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,fl.language_code
  ,name
  ,description
  ,USERENV('LANG')
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_languages               fl
  WHERE xal.table_name                  = 'XLA_ACCT_LINE_TYPES'
    AND xal.staging_amb_context_code    = p_staging_context_code
    AND fl.installed_flag               IN ('I', 'B');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_ACCT_LINE_TYPES_TL) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_jlt_acct_attrs
  (application_id
  ,amb_context_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,accounting_attribute_code
  ,source_application_id
  ,source_type_code
  ,source_code
  ,event_class_default_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,accounting_attribute_code
  ,fap.application_id
  ,source_type_code
  ,source_code
  ,event_class_default_flag
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_application             fap
  WHERE fap.application_short_name(+) = xal.source_app_short_name
    AND table_name                  = 'XLA_JLT_ACCT_ATTRS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_JLT_ACCT_ATTRS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_conditions
  (amb_context_code
  ,condition_id
  ,user_sequence
  ,application_id
  ,entity_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
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
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,xla_conditions_s.nextval
  ,xal.condition_num
  ,p_application_id
  ,entity_code
  ,event_class_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,bracket_left_code
  ,bracket_right_code
  ,value_type_code
  ,fap.application_id
  ,source_type_code
  ,source_code
  ,flexfield_segment_code
  ,value_flexfield_segment_code
  ,fap2.application_id
  ,value_source_type_code
  ,value_source_code
  ,value_constant
  ,line_operator_code
  ,logical_operator_code
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_application             fap
       ,fnd_application             fap2
  WHERE fap.application_short_name(+) = xal.source_app_short_name
    AND fap2.application_short_name(+)= xal.value_source_app_short_name
    AND table_name                    = 'XLA_JLT_CONDITIONS'
    AND staging_amb_context_code      = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_JLT_CONDITIONS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_journal_line_types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_journal_line_types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_journal_line_types is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_journal_line_types'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_journal_line_types;

--=============================================================================
--
-- Name: populate_jlds
-- Description: This API populates the AADs data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_jlds
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(240);
  l_excp_code     VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_jlds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_line_definitions_b
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,transaction_coa_id
  ,accounting_coa_id
  ,enabled_flag
  ,validation_status_code
  ,budgetary_control_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,fift.id_flex_num
  ,fifa.id_flex_num
  ,xal.enabled_flag
  ,'N'
  ,budgetary_control_flag
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,fnd_id_flex_structures   fift
       ,fnd_id_flex_structures   fifa
  WHERE fift.application_id(+)         = 101
    AND fift.id_flex_code(+)           = 'GL#'
    AND fift.id_flex_structure_code(+) = trans_coa_id_flex_struct_code
    AND fifa.application_id(+)         = 101
    AND fifa.id_flex_code(+)           = 'GL#'
    AND fifa.id_flex_structure_code(+) = acct_coa_id_flex_struct_code
    AND table_name                     = 'XLA_LINE_DEFINITIONS'
    AND staging_amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_LINE_DEFINITIONS_B) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_line_definitions_tl
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,language
  ,name
  ,description
  ,source_lang
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,fl.language_code
  ,name
  ,description
  ,USERENV('LANG')
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_languages               fl
  WHERE xal.table_name                  = 'XLA_LINE_DEFINITIONS'
    AND xal.staging_amb_context_code    = p_staging_context_code
    AND fl.installed_flag               IN ('I', 'B');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_LINE_DEFINITIONS_TL) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_line_defn_jlt_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,description_type_code
  ,description_code
  ,active_flag
  ,inherit_desc_flag
  ,mpa_header_desc_type_code
  ,mpa_header_desc_code
  ,mpa_num_je_code
  ,mpa_gl_dates_code
  ,mpa_proration_code
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,description_type_code
  ,description_code
  ,active_flag
  ,NVL(inherit_desc_flag,'N')
  ,mpa_header_desc_type_code
  ,mpa_header_desc_code
  ,mpa_num_je_code
  ,mpa_gl_dates_code
  ,mpa_proration_code
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_LINE_DEFN_JLT_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_LINE_DEFN_JLT_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_line_defn_adr_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,flexfield_segment_code
  ,adr_version_num
  ,segment_rule_appl_id
  ,segment_rule_type_code
  ,segment_rule_code
  ,inherit_adr_flag
  ,side_code
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,flexfield_segment_code
  ,NVL(adr_version_num,0)
  ,NVL(fap.application_id,
       CASE WHEN segment_rule_type_code IS NOT NULL
            THEN p_application_id
            ELSE NULL END)
  ,segment_rule_type_code
  ,segment_rule_code
  ,NVL(inherit_adr_flag,'N')
  ,NVL(side_code,'NA')
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_application             fap
  WHERE fap.application_short_name(+)   = xal.segment_rule_appl_sn
    AND xal.table_name                  = 'XLA_LINE_DEFN_ADR_ASSGNS'
    AND xal.staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_LINE_DEFN_ADR_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_line_defn_ac_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,analytical_criterion_code
  ,analytical_criterion_type_code
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,analytical_criterion_code
  ,analytical_criterion_type_code
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_LINE_DEFN_AC_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_LINE_DEFN_AC_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_mpa_header_ac_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,analytical_criterion_code
  ,analytical_criterion_type_code
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,analytical_criterion_code
  ,analytical_criterion_type_code
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_MPA_HEADER_AC_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_MPA_HEADER_AC_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_mpa_jlt_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,mpa_accounting_line_type_code
  ,mpa_accounting_line_code
  ,description_type_code
  ,description_code
  ,inherit_desc_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,mpa_accounting_line_type_code
  ,mpa_accounting_line_code
  ,description_type_code
  ,description_code
  ,inherit_desc_flag
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_MPA_JLT_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_MPA_JLT_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_mpa_jlt_ac_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,mpa_accounting_line_type_code
  ,mpa_accounting_line_code
  ,analytical_criterion_type_code
  ,analytical_criterion_code
  ,mpa_inherit_ac_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,mpa_accounting_line_type_code
  ,mpa_accounting_line_code
  ,analytical_criterion_type_code
  ,analytical_criterion_code
  ,mpa_inherit_ac_flag
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_MPA_JLT_AC_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_MPA_JLT_AC_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_mpa_jlt_adr_assgns
  (application_id
  ,amb_context_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,accounting_line_type_code
  ,accounting_line_code
  ,mpa_accounting_line_type_code
  ,mpa_accounting_line_code
  ,flexfield_segment_code
  ,segment_rule_type_code
  ,segment_rule_code
  ,segment_rule_appl_id
  ,inherit_adr_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,xal.event_class_code
  ,xal.event_type_code
  ,xal.line_definition_owner_code
  ,xal.line_definition_code
  ,xal.accounting_line_type_code
  ,xal.accounting_line_code
  ,xal.mpa_accounting_line_type_code
  ,xal.mpa_accounting_line_code
  ,xal.flexfield_segment_code
  ,xal.segment_rule_type_code
  ,xal.segment_rule_code
  ,fap.application_id
  ,xal.inherit_adr_flag
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
     ,  fnd_application          fap
  WHERE fap.application_short_name(+) = xal.segment_rule_appl_sn
    AND table_name                  = 'XLA_MPA_JLT_ADR_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_MPA_JLT_ADR_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.procedure populate_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.procedure populate_jlds is :'||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_jlds'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_jlds;

--=============================================================================
--
-- Name: populate_aads
-- Description: This API populates the AADs data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_aads
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(250);
  l_excp_code     VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_product_rules_b
  (application_id
  ,amb_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,transaction_coa_id
  ,accounting_coa_id
  ,enabled_flag
  ,product_rule_version
  ,compile_status_code
  ,locking_status_flag
  ,product_rule_hash_id
  ,version_num
  ,updated_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,xal.product_rule_type_code
  ,xal.product_rule_code
  ,fift.id_flex_num
  ,fifa.id_flex_num
  ,xal.enabled_flag
  ,xal.product_rule_version
  ,'N'
  ,xal.locking_status_flag
  ,xpr.product_rule_hash_id
  ,NVL(xal.version_num,1)
  ,'N'
  ,nvl(to_date(xal.orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(xal.owner)
  ,nvl(to_date(xal.orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(xal.owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,xla_product_rules_b      xpr
       ,fnd_id_flex_structures   fift
       ,fnd_id_flex_structures   fifa
  WHERE fift.application_id(+)         = 101
    AND fift.id_flex_code(+)           = 'GL#'
    AND fift.id_flex_structure_code(+) = xal.trans_coa_id_flex_struct_code
    AND fifa.application_id(+)         = 101
    AND fifa.id_flex_code(+)           = 'GL#'
    AND fifa.id_flex_structure_code(+) = xal.acct_coa_id_flex_struct_code
    AND xpr.application_id(+)          = p_application_id
    AND xpr.amb_context_code(+)        = p_amb_context_code
    AND xpr.product_rule_type_code(+)  = xal.product_rule_type_code
    AND xpr.product_rule_code(+)       = xal.product_rule_code
    AND xal.table_name                 = 'XLA_PRODUCT_RULES'
    AND xal.staging_amb_context_code   = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_PRODUCT_RULES_B) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_product_rules_tl
  (application_id
  ,amb_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,language
  ,name
  ,description
  ,source_lang
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,fl.language_code
  ,name
  ,description
  ,USERENV('LANG')
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_languages               fl
  WHERE xal.table_name                  = 'XLA_PRODUCT_RULES'
    AND xal.staging_amb_context_code    = p_staging_context_code
    AND fl.installed_flag               IN ('I', 'B');

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_PRODUCT_RULES_TL) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_prod_acct_headers
  (application_id
  ,amb_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,entity_code
  ,event_class_code
  ,event_type_code
  ,description_type_code
  ,description_code
  ,accounting_required_flag
  ,locking_status_flag
  ,validation_status_code
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,entity_code
  ,event_class_code
  ,event_type_code
  ,description_type_code
  ,description_code
  ,accounting_required_flag
  ,locking_status_flag
  ,'N'
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_PROD_ACCT_HEADERS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_PROD_ACCT_HEADERS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_aad_hdr_acct_attrs
  (application_id
  ,amb_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,event_class_code
  ,event_type_code
  ,accounting_attribute_code
  ,source_application_id
  ,source_type_code
  ,source_code
  ,event_class_default_flag
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,event_class_code
  ,event_type_code
  ,accounting_attribute_code
  ,fap.application_id
  ,source_type_code
  ,source_code
  ,event_class_default_flag
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t      xal
       ,fnd_application             fap
  WHERE fap.application_short_name(+) = xal.source_app_short_name
    AND table_name                    = 'XLA_AAD_HDR_ACCT_ATTRS'
    AND staging_amb_context_code      = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_AAD_HDR_ACCT_ATTRS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_aad_line_defn_assgns
  (application_id
  ,amb_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,event_class_code
  ,event_type_code
  ,line_definition_owner_code
  ,line_definition_code
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_AAD_LINE_DEFN_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_AAD_LINE_DEFN_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_aad_header_ac_assgns
  (application_id
  ,amb_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,event_class_code
  ,event_type_code
  ,analytical_criterion_code
  ,analytical_criterion_type_code
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_application_id
  ,p_staging_context_code
  ,product_rule_type_code
  ,product_rule_code
  ,event_class_code
  ,event_type_code
  ,analytical_criterion_code
  ,analytical_criterion_type_code
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                  = 'XLA_AAD_HEADER_AC_ASSGNS'
    AND staging_amb_context_code    = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_AAD_HEADER_AC_ASSGNS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_aads is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_aads'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_aads;

--=============================================================================
--
-- Name: populate_acctg_method
-- Description: This API populates the accounting method data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_acctg_methods
(p_application_id        IN INTEGER
,p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(240);
  l_excp_code     VARCHAR2(100);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_acctg_methods';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_acctg_methods',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_stage_acctg_methods
  (staging_amb_context_code
  ,accounting_method_type_code
  ,accounting_method_code
  ,name
  ,description
  ,transaction_coa_id
  ,accounting_coa_id
  ,enabled_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,xal.accounting_method_type_code
  ,xal.accounting_method_code
  ,xal.name
  ,xal.description
  ,fift.id_flex_num
  ,fifa.id_flex_num
  ,xal.enabled_flag
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t   xal
       ,fnd_id_flex_structures   fift
       ,fnd_id_flex_structures   fifa
  WHERE fift.application_id(+)         = 101
    AND fift.id_flex_code(+)           = 'GL#'
    AND fift.id_flex_structure_code(+) = trans_coa_id_flex_struct_code
    AND fifa.application_id(+)         = 101
    AND fifa.id_flex_code(+)           = 'GL#'
    AND fifa.id_flex_structure_code(+) = acct_coa_id_flex_struct_code
    AND table_name                     = 'XLA_STAGE_ACCTG_METHODS'
    AND staging_amb_context_code       = p_staging_context_code;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => '# insert (XLA_STAGING_ACCTG_METHODS) = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  INSERT INTO xla_acctg_method_rules
  (amb_context_code
  ,accounting_method_type_code
  ,accounting_method_code
  ,acctg_method_rule_id
  ,application_id
  ,product_rule_type_code
  ,product_rule_code
  ,start_date_active
  ,end_date_active
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,accounting_method_type_code
  ,accounting_method_code
  ,xla_acctg_method_rules_s.nextval
  ,p_application_id
  ,product_rule_type_code
  ,product_rule_code
  ,start_date_active
  ,end_date_active
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t
  WHERE table_name                      = 'XLA_ACCTG_METHOD_RULES'
    AND staging_amb_context_code        = p_staging_context_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_acctg_methods',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_acctg_methods',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_acctg_methods is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_acctg_methods'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_acctg_methods;

--=============================================================================
--
-- Name: populate_history
-- Description: This API populates the history data from the AAD Loader
--              interface table to the different AMB tables
--
--=============================================================================
PROCEDURE populate_history
(p_staging_context_code  IN VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
  l_exception     VARCHAR2(250);
  l_excp_code     VARCHAR2(100);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_history';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_history',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_staging_components_h
  (staging_amb_context_code
  ,component_type_code
  ,component_owner_code
  ,component_code
  ,version_num
  ,base_version_num
  ,application_id
  ,product_rule_version
  ,version_comment
  ,leapfrog_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
  SELECT
   p_staging_context_code
  ,component_type_code
  ,component_owner_code
  ,component_code
  ,version_num
  ,base_version_num
  ,NVL(fap.application_id,-1)
  ,product_rule_version
  ,version_comment
  ,leapfrog_flag
  ,1
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,nvl(to_date(orig_last_update_date, 'YYYY/MM/DD'), sysdate)
  ,fnd_load_util.owner_id(owner)
  ,0
  FROM  xla_aad_loader_defns_t          xal
       ,fnd_application                 fap
  WHERE fap.application_short_name(+)   = xal.application_short_name
    AND table_name                      = 'XLA_STAGING_COMPONENTS_H'
    AND staging_amb_context_code        = p_staging_context_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => '# row populated in XLA_STAGING_COMPONENTS_H = '||SQL%ROWCOUNT,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_history',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_upload_pvt.populate_history',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_upload_pvt.populate_history is : '||l_excp_code||'-'||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_history'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;
END populate_history;

--=============================================================================
--
-- Name: populate_data
-- Description: This API populates the data from the AAD Loader interface
--              table to the different AMB tables
--
--=============================================================================
FUNCTION populate_data
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  l_error_found   BOOLEAN;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.populate_data';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure populate_data',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_error_found := FALSE;

  populate_descriptions
               (p_application_id       => p_application_id
               ,p_staging_context_code => p_staging_context_code);

  IF (populate_mapping_sets
               (p_application_id       => p_application_id
               ,p_staging_context_code => p_staging_context_code) = 'WARNING') THEN
    l_error_found := TRUE;
  END IF;

  populate_analytical_criteria
               (p_application_id        => p_application_id
               ,p_staging_context_code  => p_staging_context_code);

  IF (populate_adrs(p_application_id        => p_application_id
                   ,p_staging_context_code  => p_staging_context_code) = 'WARNING') THEN
    l_error_found := TRUE;
  END IF;

  populate_journal_line_types
               (p_application_id       => p_application_id
               ,p_staging_context_code => p_staging_context_code);

  populate_jlds
               (p_application_id       => p_application_id
               ,p_staging_context_code => p_staging_context_code);

  populate_aads
               (p_application_id       => p_application_id
               ,p_amb_context_code     => p_amb_context_code
               ,p_staging_context_code => p_staging_context_code);

  populate_acctg_methods
               (p_application_id       => p_application_id
               ,p_staging_context_code => p_staging_context_code);

  populate_history(p_staging_context_code => p_staging_context_code);

  IF (l_error_found) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_data',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure populate_data: ERROR',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'WARNING';

WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.populate_data'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RAISE;

END populate_data;



--=============================================================================
--
-- Name: post_upload
-- Description: This API populates the data from the AAD Loader interface
--              table to the different AMB tables
--
--=============================================================================
FUNCTION post_upload
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_staging_context_code  IN VARCHAR2)
RETURN VARCHAR2
IS
  l_upload_status VARCHAR2(30);
  l_error_found   BOOLEAN;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.post_upload';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function post_upload',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_upload_status := validation
                          (p_application_id       => p_application_id
                          ,p_staging_context_code => p_staging_context_code);

  IF (l_upload_status IN ('WARNING','ERROR')) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_upload_status := populate_data
                          (p_application_id       => p_application_id
                          ,p_amb_context_code     => p_amb_context_code
                          ,p_staging_context_code => p_staging_context_code);

  IF (l_upload_status IN ('WARNING','ERROR')) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function post_upload',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function post_upload: ERROR',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_upload_status;

WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.post_upload'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
  RETURN 'ERROR';

END post_upload;


--=============================================================================
--
--
--
--
--
--          *********** public procedures and functions **********
--
--
--
--
--
--=============================================================================


--=============================================================================
--
-- Name:
-- Description:
--
--=============================================================================
PROCEDURE upload
(p_api_version           IN NUMBER
,x_return_status         IN OUT NOCOPY VARCHAR2
,p_application_id        IN INTEGER
,p_source_pathname       IN VARCHAR2
,p_amb_context_code      IN VARCHAR2
,x_upload_status         IN OUT NOCOPY VARCHAR2)
IS
  l_api_name             CONSTANT VARCHAR2(30) := 'upload';
  l_api_version          CONSTANT NUMBER       := 1.0;
  l_staging_context_code VARCHAR2(30);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.upload';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure upload',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Standard call to check for call compatibility.
  IF (NOT xla_aad_loader_util_pvt.compatible_api_call
                 (p_current_version_number => l_api_version
                 ,p_caller_version_number  => p_api_version
                 ,p_api_name               => l_api_name
                 ,p_pkg_name               => C_DEFAULT_MODULE))
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  -- API Logic
  l_staging_context_code := xla_aad_loader_util_pvt.get_staging_context_code
                                (p_application_id   => p_application_id
                                ,p_amb_context_code => p_amb_context_code);

  x_upload_status := upload_data
                     (p_application_id       => p_application_id
                     ,p_source_pathname      => p_source_pathname
                     ,p_staging_context_code => l_staging_context_code);

  IF (x_upload_status IN ('ERROR','WARNING')) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_upload_status := post_upload
                     (p_application_id       => p_application_id
                     ,p_amb_context_code     => p_amb_context_code
                     ,p_staging_context_code => l_staging_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure upload: x_upload_status = '||x_upload_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_upload_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_upload_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_upload_pvt.upload'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
END upload;

--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN
  g_log_level          := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_log_enabled        := fnd_log.test
                         (log_level  => g_log_level
                         ,module     => C_DEFAULT_MODULE);

  IF NOT g_log_enabled THEN
    g_log_level := C_LEVEL_LOG_DISABLED;
  END IF;

END xla_aad_upload_pvt;

/

--------------------------------------------------------
--  DDL for Package Body XLA_AAD_INSTALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_INSTALL_PVT" AS
/* $Header: xlainaad.pkb 120.2.12010000.4 2010/04/16 13:10:18 krsankar ship $ */

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_install_pvt';

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
      (p_location   => 'xla_aad_install_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================


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
PROCEDURE pre_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2
)IS
  l_staging_context_code VARCHAR2(30);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_import';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure pre_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.reset_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'IMPORT');

  SELECT p_amb_context_code||'_INSTALL_'||application_short_name
    INTO l_staging_context_code
    FROM fnd_application
   WHERE application_id = p_application_id;

  x_return_status := xla_aad_import_pvt.pre_import
             (p_application_id   => p_application_id
             ,p_amb_context_code => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code);

  IF (x_return_status = 'SUCCESS') THEN
    DELETE FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = l_staging_context_code;
  ELSE
    ROLLBACK;
    xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'IMPORT');
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure pre_import: x_return_status = '||x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'ERROR';
  xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'IMPORT');
END pre_import;

--=============================================================================
--
-- Name:
-- Description:
-- Modified: 5692314 ssawhney remove code logic for OVERWRITE feature.
--=============================================================================
PROCEDURE post_import
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_import_mode           IN VARCHAR2
,p_force_overwrite       IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2
)IS
  l_staging_context_code    VARCHAR2(30);
  l_return_status           VARCHAR2(30);
  l_compilation_status_code VARCHAR2(1);
  l_validation_status_code  VARCHAR2(1);
  l_hash_id                 INTEGER;
  l_log_module              VARCHAR2(240);
  l_exception               VARCHAR2(240);
  l_excp_code               VARCHAR2(100);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.post_import';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Calling procedure reset_errors from '||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.reset_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'IMPORT');

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Returned from reset_errors to '||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  SELECT p_amb_context_code||'_INSTALL_'||application_short_name
    INTO l_staging_context_code
    FROM fnd_application
   WHERE application_id = p_application_id;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Calling procedure post_upload from '||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  x_return_status := xla_aad_upload_pvt.post_upload
             (p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Returned from post_upload to '||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Calling procedure post_import from '||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (x_return_status = 'SUCCESS') THEN
    xla_aad_import_pvt.post_import
             (p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Returned from post_import to '||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Before calling xla_aad_merge from'||C_DEFAULT_MODULE||'.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'p_import_mode for merge is : '||p_import_mode,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
     END IF;


    IF (p_import_mode = 'ANALYSIS') THEN
      xla_aad_merge_analysis_pvt.analysis
             (p_api_version          => 1.0
             ,x_return_status        => l_return_status
             ,p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code
             ,p_batch_name           => NULL
             ,x_analysis_status      => x_return_status);

    ELSE -- commented for bug 5692314 (p_import_mode = 'MERGE') THEN
      xla_aad_merge_pvt.merge
             (p_api_version          => 1.0
             ,x_return_status        => l_return_status
             ,p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code
             ,p_analyzed_flag        => 'N'
             ,p_compile_flag         => 'N'
             ,x_merge_status         => x_return_status);

    /* -- commented for bug 5692314
      ELSE
      xla_aad_overwrite_pvt.overwrite
             (p_api_version          => 1.0
             ,x_return_status        => l_return_status
             ,p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code
             ,p_force_flag           => p_force_overwrite
             ,p_compile_flag         => 'N'
             ,x_overwrite_status     => x_return_status);
    */
    END IF;

  END IF;


  IF (x_return_status = 'SUCCESS') THEN
    DELETE FROM xla_aad_loader_defns_t
     WHERE staging_amb_context_code = l_staging_context_code;

    IF (p_import_mode IN ('MERGE', 'OVERWRITE')) THEN
      /*UPDATE xla_product_rules_b
         SET compile_status_code = 'R'
       WHERE application_id = p_application_id
         AND amb_context_code = p_amb_context_code;*/


       	 UPDATE xla_product_rules_b prd
         SET compile_status_code = 'R'
         WHERE application_id = p_application_id
         AND  amb_context_code = p_amb_context_code
         AND EXISTS (select 1
                     from  xla_aads_gt a,
                           XLA_PAD_INQ_LINES_FVL b
                     where (a.product_rule_code is null         or  a.product_rule_code         = b.product_rule_code)
                     and   (a.event_class_code is null          or  a.event_class_code          = b.event_class_code)
		     and   (a.event_type_code is null           or  a.event_type_code           = b.event_type_code)
		     and   (a.line_definition_code is null      or  a.line_definition_code      = b.line_definition_code)
		     and   (a.accounting_line_code is null      or  a.accounting_line_code      = b.accounting_line_code)
		     and   (a.accounting_class_code is null     or  a.accounting_class_code     = b.accounting_class_code)
		     and   (a.segment_rule_code is null         or  a.segment_rule_code 	= b.segment_rule_code)
		     and   (a.description_code is null          or  a.description_code 	       = b.description_code)
		     and   (a.analytical_criterion_code is null or  a.analytical_criterion_code = b.analytical_criterion_code)
		     and    prd.product_rule_code = b.product_rule_code
	            )
         AND EXISTS
	      ( SELECT 1
		FROM  xla_acctg_method_rules amr,
		      gl_ledgers gl
		WHERE prd.product_rule_code      = amr.product_rule_code
		AND   prd.product_rule_type_code = amr.product_rule_type_code
		AND   prd.application_id         = amr.application_id
		AND   prd.amb_context_code       = amr.amb_context_code
	        AND   amr.accounting_method_code = gl.sla_accounting_method_code
		AND   amr.application_id         = p_application_id
		AND   amr.end_date_active IS NULL OR amr.end_date_active >= sysdate
	       );

             /********************************************************************************/
	     /*  For AADs that are not attached to SLAM, we are stamping them to N -         */
	     /*  NOT VALIDATED.This is because, if in FUTURE, customer intends to attach     */
	     /*  a different AAD onto SLAM and LEDGER, that AAD would get used in its        */
	     /*  current setup(where its validation status is Y), although higher versions   */
	     /*  with setup changes would have been shipped in ldts by product teams         */
	     /*           In that case, we would not have validated this AAD as it was not   */
	     /*  attached to SLAM/LEDGER at that time.So higher versions of ldt still pulled */
	     /*  in the latest code but has not validated the AAD with latest setup.         */
	     /*      So, now if customer uses that AAD, he would be using it with old setup  */
	     /*  and latest code change/setup change is not pulled into accounting and       */
	     /*  accounting would be incorrect.Hence we are setting it to N, so that         */
	     /*  re-validating AAD would pull up latest setup in to the AAD and accounting   */
	     /*  would be as expected.                                                       */
             /********************************************************************************/


	     UPDATE xla_product_rules_b prd
             SET compile_status_code = 'N'
             WHERE application_id = p_application_id
             AND  amb_context_code = p_amb_context_code
             AND EXISTS
	      ( select 1
                from  xla_aads_gt a,
                      XLA_PAD_INQ_LINES_FVL b
                where (a.product_rule_code is null         or  a.product_rule_code      = b.product_rule_code)
                and   (a.event_class_code is null          or  a.event_class_code       = b.event_class_code)
		and   (a.event_type_code is null           or  a.event_type_code        = b.event_type_code)
		and   (a.line_definition_code is null      or  a.line_definition_code   = b.line_definition_code)
		and   (a.accounting_line_code is null      or  a.accounting_line_code   = b.accounting_line_code)
		and   (a.accounting_class_code is null     or  a.accounting_class_code  = b.accounting_class_code)
		and   (a.segment_rule_code is null         or  a.segment_rule_code 	= b.segment_rule_code)
		and   (a.description_code is null          or  a.description_code 	= b.description_code)
		and   (a.analytical_criterion_code is null or  a.analytical_criterion_code = b.analytical_criterion_code)
		and    prd.product_rule_code = b.product_rule_code
	       )
             AND NOT EXISTS
	      ( SELECT 1
		FROM  xla_acctg_method_rules amr,
		      gl_ledgers gl
		WHERE prd.product_rule_code      = amr.product_rule_code
		AND   prd.product_rule_type_code = amr.product_rule_type_code
		AND   prd.application_id         = amr.application_id
		AND   prd.amb_context_code       = amr.amb_context_code
	        AND   amr.accounting_method_code = gl.sla_accounting_method_code
		AND   amr.application_id         = p_application_id
		AND   amr.end_date_active IS NULL OR amr.end_date_active >= sysdate
	       );

          IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Number of Rows updated to R in product_rules_b is :'||SQL%ROWCOUNT,
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
          END IF;

	  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
              trace(p_msg    => 'Calling Validate and Compile AAD procedure',
                    p_module => l_log_module,
                    p_level  => C_LEVEL_PROCEDURE);
          END IF;


      FOR l IN (SELECT * FROM xla_product_rules_b
                 WHERE application_id = p_application_id
                   AND amb_context_code = p_amb_context_code
		   AND compile_status_code = 'R') LOOP  -- Added extra condition on compile status code
        xla_amb_aad_pkg.validate_and_compile_aad
               (p_application_id            => p_application_id
               ,p_amb_context_code          => p_amb_context_code
               ,p_product_rule_type_code    => l.product_rule_type_code
               ,p_product_rule_code         => l.product_rule_code
               ,x_validation_status_code    => l_validation_status_code
               ,x_compilation_status_code   => l_compilation_status_code
               ,x_hash_id                   => l_hash_id);
      END LOOP;


    END IF;


  ELSE
    xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'IMPORT');
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure post_import: x_return_status = '||x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'ERROR';

  l_exception := substr(sqlerrm,1,240);
  l_excp_code := sqlcode;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'In exception of xla_aad_install_pvt.post_import',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Error in xla_aad_install_pvt.post_import is : '||l_excp_code||' - '||l_exception,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'IMPORT');
END post_import;

--=============================================================================
--
-- Name:
-- Description:
--
--=============================================================================
PROCEDURE pre_export
(p_application_id        IN INTEGER
,p_amb_context_code      IN VARCHAR2
,p_versioning_mode       IN VARCHAR2
,p_user_version          IN VARCHAR2
,p_version_comment       IN VARCHAR2
,x_return_status         IN OUT NOCOPY VARCHAR2
)IS
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_export';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure pre_export',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  xla_aad_loader_util_pvt.reset_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'EXPORT');

  x_return_status := xla_aad_export_pvt.pre_export
                     (p_application_id   => p_application_id
                     ,p_amb_context_code => p_amb_context_code
                     ,p_versioning_mode  => CASE p_versioning_mode
                                                 WHEN 'N' THEN 'STANDARD'
                                                 WHEN 'Y' THEN 'LEAPFROG'
                                                 ELSE p_versioning_mode
                                                 END
                     ,p_user_version     => CASE WHEN p_user_version = 'NULL'
                                                 THEN NULL
                                                 ELSE p_user_version END
                     ,p_version_comment  => CASE WHEN p_version_comment = 'NULL'
                                                 THEN NULL
                                                 ELSE p_version_comment END
                     ,p_owner_type       => 'C');

  IF (x_return_status <> 'SUCCESS') THEN
    ROLLBACK;
    xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'EXPORT');
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure pre_export: x_return_status = '||x_return_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'ERROR';
  xla_aad_loader_util_pvt.insert_errors
             (p_application_id     => p_application_id
             ,p_amb_context_code   => p_amb_context_code
             ,p_request_code       => 'EXPORT');
END pre_export;

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

END xla_aad_install_pvt;

/

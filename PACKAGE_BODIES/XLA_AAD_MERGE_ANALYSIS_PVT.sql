--------------------------------------------------------
--  DDL for Package Body XLA_AAD_MERGE_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_MERGE_ANALYSIS_PVT" AS
/* $Header: xlaalman.pkb 120.15.12010000.2 2009/05/05 06:08:06 krsankar ship $ */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_aad_merge_analysis_pvt                                             |
|                                                                            |
| DESCRIPTION                                                                |
|    AAD Loader Merge Analysis package                                       |
|                                                                            |
| HISTORY                                                                    |
|     01-MAY-2004 W. Chan     Created                                        |
|     13-APR-2005 W. Chan     Added Business Flow Changes                    |
|     05-AUG-2005 W. Chan     Added Public Sector Changes                    |
|     19-AUG-2005 W. Chan     Added MPA changes                              |
|                                                                            |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
TYPE AssgnIndex  IS TABLE OF VARCHAR2(1)    INDEX BY VARCHAR2(720);

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
C_NUM                    CONSTANT NUMBER      := 9.99E125;
C_CHAR                   CONSTANT VARCHAR2(1) := '|'; -- fnd_global.local_chr(12);
C_DATE                   CONSTANT DATE        := TO_DATE('1','j');

C_MERGE_IMPACT_UPDATED   CONSTANT VARCHAR2(30):= 'UPDATED';
C_MERGE_IMPACT_NEW       CONSTANT VARCHAR2(30):= 'NEW';
C_MERGE_IMPACT_DELETED   CONSTANT VARCHAR2(30):= 'DELETED';
C_MERGE_IMPACT_UNCHANGED CONSTANT VARCHAR2(30):= 'UNCHANGED';

C_OWNER_ORACLE           CONSTANT VARCHAR2(1) := 'S';
C_OWNER_CUSTOM           CONSTANT VARCHAR2(1) := 'C';

------------------------------------------------------------------------------
-- declaring global variables
------------------------------------------------------------------------------
g_application_id              NUMBER;
g_amb_context_code            VARCHAR2(30);
g_staging_context_code        VARCHAR2(30);
g_batch_name                  VARCHAR2(240);  --Modified from size 30 to 240 for bug 8463447 by krsankar
g_aad_groups                  xla_aad_group_tbl_type;
g_user_mode                   VARCHAR2(30);

g_assgns            AssgnIndex;
g_num_updated_props INTEGER;
g_updated_props     xla_amb_updated_prop_tbl_type := xla_amb_updated_prop_tbl_type();
g_num_updated_comps INTEGER;
g_updated_comps     xla_amb_updated_comp_tbl_type := xla_amb_updated_comp_tbl_type();

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_merge_analysis_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ----------------------------------------------------------------------------
  -- Following is for FND log.
  ----------------------------------------------------------------------------
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
      (p_location   => 'xla_aad_merge_analysis_pvt.trace');
END trace;


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================

--=============================================================================
--
-- Name: pre_analysis
-- Description: This API prepares the environment for merge
--
--=============================================================================
FUNCTION pre_analysis
RETURN VARCHAR2
IS
  CURSOR c IS
    SELECT *
      FROM xla_appli_amb_contexts
     WHERE application_id   = g_application_id
       AND amb_context_code = g_amb_context_code
    FOR UPDATE OF application_id NOWAIT;

  l_lock_error    BOOLEAN;
  l_recinfo       xla_appli_amb_contexts%ROWTYPE;
  l_retcode       VARCHAR2(30);

  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.pre_analysis';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function pre_analysis',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := 'SUCCESS';

  -- Begin API Logic

  -- Lock the staging area of the AMB context
  l_lock_error := TRUE;
  OPEN c;
  CLOSE c;
  l_lock_error := FALSE;

  IF (l_retcode = 'SUCCESS') THEN
    l_retcode := xla_aad_loader_util_pvt.lock_area
                   (p_application_id   => g_application_id
                   ,p_amb_context_code => g_amb_context_code);

    IF (l_retcode <> 'SUCCESS') THEN
      xla_aad_loader_util_pvt.stack_error
        (p_appli_s_name  => 'XLA'
        ,p_msg_name      => 'XLA_AAD_MGR_LOCK_FAILED');
      l_retcode := 'ERROR';
    END IF;
  END IF;

  DELETE FROM xla_amb_updated_comps
        WHERE application_id   = g_application_id
          AND amb_context_code = g_amb_context_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function pre_analysis - Return value = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_retcode;
EXCEPTION
WHEN OTHERS THEN
  IF (c%ISOPEN) THEN
    CLOSE c;
  END IF;

  IF (l_lock_error) THEN
    l_retcode := 'ERROR';

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of function pre_analysis - Return value = '||l_retcode,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    xla_aad_loader_util_pvt.stack_error
          (p_appli_s_name  => 'XLA'
          ,p_msg_name      => 'XLA_AAD_MAN_LOCK_FAILED');

    RETURN l_retcode;
  ELSE
    xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_analysis_pvt.pre_analysis'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');
    RAISE;
  END IF;

END pre_analysis;

--=============================================================================
--
-- Name: validation
-- Description: This API validate the AADs and components
-- Return codes:
--   SUCCESS - completed sucessfully
--   ERROR   - completed with error
--
--=============================================================================
FUNCTION validation
RETURN VARCHAR2
IS
  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
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

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function validation - Return value = '||l_retcode,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_retcode;
EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_analysis_pvt.validation'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'Unhandled exception');
  RAISE;

END validation;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_property
(p_component_type          VARCHAR2
,p_component_key           VARCHAR2
,p_property                VARCHAR2
,p_old_value               VARCHAR2
,p_new_value               VARCHAR2
,p_lookup_type             VARCHAR2)
IS
  l_prop      xla_amb_updated_prop_rec_type :=
       xla_amb_updated_prop_rec_type (null, null, null, null, null, null, null
                                     ,null, null, null, null, null, null);

  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_property';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_property',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_component_type = '||p_component_type,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_component_key = '||p_component_key,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_property = '||p_property,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_old_value = '||p_old_value,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_new_value = '||p_new_value,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_lookup_type = '||p_lookup_type,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_prop.component_type := p_component_type;
  l_prop.component_key  := p_component_key;
  l_prop.property       := p_property;

  IF (p_old_value IS NOT NULL) THEN
    l_prop.old_value      := p_old_value;
  END IF;

  l_prop.new_value      := p_new_value;
  l_prop.lookup_type    := p_lookup_type;

  g_num_updated_props := g_num_updated_props+1;
  g_updated_props.extend;
  g_updated_props(g_num_updated_props) := l_prop;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_property',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_property;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_property
(p_component_type          VARCHAR2
,p_component_key           VARCHAR2
,p_property                VARCHAR2
,p_old_value               VARCHAR2
,p_new_value               VARCHAR2)
IS
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_property';
  END IF;

  record_updated_property
          (p_component_type => p_component_type
          ,p_component_key  => p_component_key
          ,p_property       => p_property
          ,p_old_value      => p_old_value
          ,p_new_value      => p_new_value
          ,p_lookup_type    => NULL);

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_property;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_value
(p_component_type          VARCHAR2
,p_component_key           VARCHAR2
,p_property                VARCHAR2
,p_old_value               VARCHAR2
,p_old_source_app_id       INTEGER
,p_old_source_type_code    VARCHAR2
,p_old_source_code         VARCHAR2
,p_new_value               VARCHAR2
,p_new_source_app_id       INTEGER
,p_new_source_type_code    VARCHAR2
,p_new_source_code         VARCHAR2)
IS
  l_prop      xla_amb_updated_prop_rec_type :=
       xla_amb_updated_prop_rec_type (null, null, null, null, null, null, null
                                     ,null, null, null, null, null, null);

  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_value';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_value',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_component_type = '||p_component_type,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_component_key = '||p_component_key,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_property = '||p_property,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_old_value = '||p_old_value,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_old_source_app_id = '||p_old_source_app_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_old_source_type_code = '||p_old_source_type_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_old_source_code = '||p_old_source_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_new_value = '||p_new_value,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_new_source_app_id = '||p_new_source_app_id,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_new_source_type_code = '||p_new_source_type_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_new_source_code = '||p_new_source_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_prop.component_type       := p_component_type;
  l_prop.component_key        := p_component_key;
  l_prop.property             := p_property;
  l_prop.old_value            := p_old_value;
  l_prop.old_source_app_id    := p_old_source_app_id;
  l_prop.old_source_type_code := p_old_source_type_code;
  l_prop.old_source_code      := p_old_source_code;
  l_prop.new_value            := p_new_value;
  l_prop.new_source_app_id    := p_new_source_app_id;
  l_prop.new_source_type_code := p_new_source_type_code;
  l_prop.new_source_code      := p_new_source_code;

  g_num_updated_props := g_num_updated_props+1;
  g_updated_props.extend;
  g_updated_props(g_num_updated_props) := l_prop;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_value',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_value;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_source
(p_component_type          VARCHAR2
,p_component_key           VARCHAR2
,p_property                VARCHAR2
,p_old_source_app_id       INTEGER
,p_old_source_type_code    VARCHAR2
,p_old_source_code         VARCHAR2
,p_new_source_app_id       INTEGER
,p_new_source_type_code    VARCHAR2
,p_new_source_code         VARCHAR2)
IS
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_source';
  END IF;

  record_updated_value
            (p_component_type          => p_component_type
            ,p_component_key           => p_component_key
            ,p_property                => p_property
            ,p_old_value               => NULL
            ,p_old_source_app_id       => p_old_source_app_id
            ,p_old_source_type_code    => p_old_source_type_code
            ,p_old_source_code         => p_old_source_code
            ,p_new_value               => NULL
            ,p_new_source_app_id       => p_new_source_app_id
            ,p_new_source_type_code    => p_new_source_type_code
            ,p_new_source_code         => p_new_source_code);

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_source;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_component
(p_parent_component_type          VARCHAR2
,p_parent_component_key           VARCHAR2
,p_component_type                 VARCHAR2
,p_component_key                  VARCHAR2
,p_merge_impact                   VARCHAR2
,p_event_class_code               VARCHAR2 DEFAULT NULL
,p_event_type_code                VARCHAR2 DEFAULT NULL
,p_component_appl_id              NUMBER   DEFAULT NULL
,p_component_owner_code           VARCHAR2 DEFAULT NULL
,p_component_code                 VARCHAR2 DEFAULT NULL
,p_parent_component_owner_code    VARCHAR2 DEFAULT NULL
,p_parent_component_code          VARCHAR2 DEFAULT NULL
,p_property                       VARCHAR2 DEFAULT NULL
,p_old_value                      VARCHAR2 DEFAULT NULL
,p_lookup_type                    VARCHAR2 DEFAULT NULL)
IS
  l_comp      xla_amb_updated_comp_rec_type :=
              xla_amb_updated_comp_rec_type (null, null, null, null, null, null
                                           , null, null, null, null, null, null
                                           , null, null, null, null, null, null);

  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_component';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_component',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_parent_component_type = '||p_parent_component_type,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_parent_component_key = '||p_parent_component_key,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_component_type = '||p_component_type,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_component_key = '||p_component_key,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
    trace(p_msg    => 'p_merge_impact = '||p_merge_impact,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_comp.parent_component_type        := p_parent_component_type;
  l_comp.parent_component_key         := p_parent_component_key;
  l_comp.component_type               := p_component_type;
  l_comp.component_key                := p_component_key;
  l_comp.merge_impact                 := p_merge_impact;
  l_comp.event_class_code             := p_event_class_code;
  l_comp.event_type_code              := p_event_type_code;
  l_comp.component_appl_id            := p_component_appl_id;
  l_comp.component_owner_code         := p_component_owner_code;
  l_comp.component_code               := p_component_code;
  l_comp.parent_component_owner_code  := p_parent_component_owner_code;
  l_comp.parent_component_code        := p_parent_component_code;

  g_num_updated_comps := g_num_updated_comps+1;
  g_updated_comps.extend;
  g_updated_comps(g_num_updated_comps) := l_comp;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_component',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_component;

--=============================================================================
--
--
--
--=============================================================================
FUNCTION key_exists
(p_key           VARCHAR2)
RETURN BOOLEAN
IS
  l_log_module             VARCHAR2(240);
  l_retcode                BOOLEAN;
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.key_exists';
  END IF;

  BEGIN
    IF (g_assgns(p_key) = 1) THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace(p_msg    => 'Check key '||p_key||': exists',
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
      END IF;
    END IF;
    l_retcode := TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace(p_msg    => 'Check key '||p_key||': not exists',
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
      END IF;

      g_assgns(p_key) := 1;
      l_retcode := FALSE;
  END;

  RETURN l_retcode;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END key_exists;

--=============================================================================
--
-- Name: record_updated_aad
-- Description: Record that an AAD is updated
--
--=============================================================================
PROCEDURE record_updated_aad
(p_product_rule_type_code     VARCHAR2
,p_product_rule_code          VARCHAR2
,p_merge_impact               VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_aad';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_aad: '||
                      'p_product_rule_type_code = '||p_product_rule_type_code||
                      ', p_product_rule_code = '||p_product_rule_code||
                      ', p_merge_impact = '||p_merge_impact,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_product_rule_type_code||C_CHAR||
           p_product_rule_code;

  IF (NOT key_exists('AAD'||C_CHAR||l_key)) THEN
    record_updated_component
            (p_parent_component_type => 'APPLICATION'
            ,p_parent_component_key  => g_application_id
            ,p_component_type        => 'AMB_AAD'
            ,p_component_key         => l_key
            ,p_merge_impact          => p_merge_impact
            ,p_component_owner_code  => p_product_rule_type_code
            ,p_component_code        => p_product_rule_code);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_aad',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_aad;

--=============================================================================
--
-- Name: record_updated_header_assgn
-- Description: Record a header assignment is updated
--
--=============================================================================
PROCEDURE record_updated_header_assgn
(p_product_rule_type_code     VARCHAR2
,p_product_rule_code          VARCHAR2
,p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_merge_impact               VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_header_assgn';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_header_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_product_rule_type_code||C_CHAR||
           p_product_rule_code||C_CHAR||
           p_event_class_code||C_CHAR||
           p_event_type_code;

  IF (NOT key_exists('ET'||C_CHAR||l_key)) THEN
    record_updated_component
            (p_parent_component_type => 'AMB_AAD_EVENT_CLASS'
            ,p_parent_component_key  => p_product_rule_type_code||C_CHAR||
                                        p_product_rule_code||C_CHAR||
                                        p_event_class_code
            ,p_component_type        => 'AMB_AAD_EVENT_TYPE'
            ,p_component_key         => l_key
            ,p_merge_impact          => p_merge_impact
            ,p_event_class_code      => p_event_class_code
            ,p_event_type_code       => p_event_type_code
            ,p_component_code        => p_event_type_code);

    l_key := p_product_rule_type_code||C_CHAR||
             p_product_rule_code||C_CHAR||
             p_event_class_code;

    IF (NOT key_exists('EC'||C_CHAR||l_key)) THEN
      record_updated_component
            (p_parent_component_type => 'AMB_AAD'
            ,p_parent_component_key  => p_product_rule_type_code||C_CHAR||
                                        p_product_rule_code
            ,p_component_type        => 'AMB_AAD_EVENT_CLASS'
            ,p_component_key         => l_key
            ,p_merge_impact          => C_MERGE_IMPACT_UPDATED
            ,p_event_class_code      => p_event_class_code
            ,p_component_code        => p_event_class_code);

      record_updated_aad
            (p_product_rule_type_code => p_product_rule_type_code
            ,p_product_rule_code      => p_product_rule_code
            ,p_merge_impact           => C_MERGE_IMPACT_UPDATED);

    END IF;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_header_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_header_assgn;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_jld_assgn
(p_product_rule_type_code     VARCHAR2
,p_product_rule_code          VARCHAR2
,p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_line_defn_owner_code       VARCHAR2
,p_line_defn_code             VARCHAR2
,p_merge_impact               VARCHAR2)
IS
  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_jld_assgn';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_jld_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_parent_key := p_product_rule_type_code||C_CHAR||
                  p_product_rule_code||C_CHAR||
                  p_event_class_code||C_CHAR||
                  p_event_type_code;

  l_key := p_event_class_code||C_CHAR||
           p_event_type_code||C_CHAR||
           p_line_defn_owner_code||C_CHAR||
           p_line_defn_code;

  IF (NOT key_exists('ETJLD'||C_CHAR||l_parent_key||C_CHAR||l_key)) THEN
    record_updated_component
          (p_parent_component_type => 'AMB_AAD_EVENT_TYPE'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_JLD'
          ,p_component_key         => l_key
          ,p_merge_impact          => p_merge_impact
          ,p_event_class_code      => p_event_class_code
          ,p_event_type_code       => p_event_type_code
          ,p_component_owner_code  => p_line_defn_owner_code
          ,p_component_code        => p_line_defn_code);

    record_updated_header_assgn
          (p_product_rule_type_code => p_product_rule_type_code
          ,p_product_rule_code      => p_product_rule_code
          ,p_event_class_code       => p_event_class_code
          ,p_event_type_code        => p_event_type_code
          ,p_merge_impact           => C_MERGE_IMPACT_UPDATED);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_jld_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_jld_assgn;


--=============================================================================
--
-- Name: record_updated_jld
-- Description: Determine the components that has assigned the JLD that is
--              modified, and record the changes for those components.
--
--=============================================================================
PROCEDURE record_updated_jld
(p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_line_definition_owner_code VARCHAR2
,p_line_definition_code       VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT w.product_rule_type_code
         , w.product_rule_code
      FROM xla_aad_line_defn_assgns w
         , xla_aad_line_defn_assgns s
     WHERE s.application_id             = g_application_id
       AND s.amb_context_code           = g_staging_context_code
       AND s.product_rule_type_code     = w.product_rule_type_code
       AND s.product_rule_code          = w.product_rule_code
       AND s.event_class_code           = w.event_class_code
       AND s.event_type_code            = w.event_type_code
       AND s.line_definition_owner_code = w.line_definition_owner_code
       AND s.line_definition_code       = w.line_definition_code
       AND w.application_id             = g_application_id
       AND w.amb_context_code           = g_amb_context_code
       AND w.event_class_code           = p_event_class_code
       AND w.event_type_code            = p_event_type_code
       AND w.line_definition_owner_code = p_line_definition_owner_code
       AND w.line_definition_code       = p_line_definition_code;

  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_jld';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_jld: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_event_type_code = '||p_event_type_code||
                      ', p_line_definition_owner_code = '||p_line_definition_owner_code||
                      ', p_line_definition_code = '||p_line_definition_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_event_class_code||C_CHAR||
           p_event_type_code||C_CHAR||
           p_line_definition_owner_code||C_CHAR||
           p_line_definition_code;

  IF (NOT key_exists('JLD'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_jld_assgn
            (p_product_rule_type_code     => l_assgn.product_rule_type_code
            ,p_product_rule_code          => l_assgn.product_rule_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_defn_owner_code       => p_line_definition_owner_code
            ,p_line_defn_code             => p_line_definition_code
            ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

    END LOOP;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_jld',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_jld;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_line_assgn
(p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_line_definition_owner_code VARCHAR2
,p_line_definition_code       VARCHAR2
,p_accounting_line_type_code  VARCHAR2
,p_accounting_line_code       VARCHAR2
,p_merge_impact               VARCHAR2)
IS
  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_line_assgn';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_line_assgn: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_event_type_code = '||p_event_type_code||
                      ', p_line_definition_owner_code = '||p_line_definition_owner_code||
                      ', p_line_definition_code = '||p_line_definition_code||
                      ', p_accounting_line_type_code = '||p_accounting_line_type_code||
                      ', p_accounting_line_code = '||p_accounting_line_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_parent_key := p_event_class_code||C_CHAR||
                  p_event_type_code||C_CHAR||
                  p_line_definition_owner_code||C_CHAR||
                  p_line_definition_code;

  l_key := l_parent_key||C_CHAR||
           p_accounting_line_type_code||C_CHAR||
           p_accounting_line_code;

  IF (NOT key_exists('LNA'||C_CHAR||l_parent_key||C_CHAR||l_key)) THEN
    record_updated_component
              (p_parent_component_type => 'AMB_JLD'
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_LINE_ASSIGNMENT'
              ,p_component_key         => l_key
              ,p_merge_impact          => p_merge_impact
              ,p_event_class_code      => p_event_class_code
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => p_accounting_line_type_code
              ,p_component_code        => p_accounting_line_code);

    record_updated_jld
             (p_event_class_code           => p_event_class_code
             ,p_event_type_code            => p_event_type_code
             ,p_line_definition_owner_code => p_line_definition_owner_code
             ,p_line_definition_code       => p_line_definition_code);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_line_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_line_assgn;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_mpa_assgn
(p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_line_definition_owner_code VARCHAR2
,p_line_definition_code       VARCHAR2
,p_accounting_line_type_code  VARCHAR2
,p_accounting_line_code       VARCHAR2
,p_merge_impact               VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_mpa_assgn';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_mpa_assgn: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_event_type_code = '||p_event_type_code||
                      ', p_line_definition_owner_code = '||p_line_definition_owner_code||
                      ', p_line_definition_code = '||p_line_definition_code||
                      ', p_accounting_line_type_code = '||p_accounting_line_type_code||
                      ', p_accounting_line_code = '||p_accounting_line_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_event_class_code||C_CHAR||
           p_event_type_code||C_CHAR||
           p_line_definition_owner_code||C_CHAR||
           p_line_definition_code||C_CHAR||
           p_accounting_line_type_code||C_CHAR||
           p_accounting_line_code;

  IF (NOT key_exists('MPAA'||C_CHAR||l_key)) THEN
    record_updated_component
              (p_parent_component_type => 'AMB_LINE_ASSIGNMENT'
              ,p_parent_component_key  => l_key
              ,p_component_type        => 'AMB_MPA_ASSIGNMENT'
              ,p_component_key         => l_key||C_CHAR||'MPA'
              ,p_merge_impact          => p_merge_impact
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => NULL
              ,p_component_code        => NULL);

    record_updated_line_assgn
             (p_event_class_code           => p_event_class_code
             ,p_event_type_code            => p_event_type_code
             ,p_line_definition_owner_code => p_line_definition_owner_code
             ,p_line_definition_code       => p_line_definition_code
             ,p_accounting_line_type_code  => p_accounting_line_type_code
             ,p_accounting_line_code       => p_accounting_line_code
             ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_mpa_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_mpa_assgn;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_mpa_line_assgn
(p_event_class_code               VARCHAR2
,p_event_type_code                VARCHAR2
,p_line_definition_owner_code     VARCHAR2
,p_line_definition_code           VARCHAR2
,p_accounting_line_type_code      VARCHAR2
,p_accounting_line_code           VARCHAR2
,p_mpa_acct_line_type_code        VARCHAR2
,p_mpa_acct_line_code             VARCHAR2
,p_merge_impact                   VARCHAR2)
IS
  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_mpa_line_assgn';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_mpa_line_assgn: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_event_type_code = '||p_event_type_code||
                      ', p_line_definition_owner_code = '||p_line_definition_owner_code||
                      ', p_line_definition_code = '||p_line_definition_code||
                      ', p_accounting_line_type_code = '||p_accounting_line_type_code||
                      ', p_accounting_line_code = '||p_accounting_line_code||
                      ', p_mpa_acct_line_type_code = '||p_mpa_acct_line_type_code||
                      ', p_mpa_acct_line_code = '||p_mpa_acct_line_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_parent_key := p_event_class_code||C_CHAR||
                  p_event_type_code||C_CHAR||
                  p_line_definition_owner_code||C_CHAR||
                  p_line_definition_code||C_CHAR||
                  p_accounting_line_type_code||C_CHAR||
                  p_accounting_line_code||C_CHAR||
                  'MPA';

  l_key := l_parent_key||C_CHAR||
           p_mpa_acct_line_type_code||C_CHAR||
           p_mpa_acct_line_code;

  IF (NOT key_exists('MPALNA'||C_CHAR||l_key)) THEN
    record_updated_component
              (p_parent_component_type => 'AMB_MPA_ASSIGNMENT'
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_MPA_LINE_ASSIGNMENT'
              ,p_component_key         => l_key
              ,p_event_class_code      => p_event_class_code
              ,p_component_owner_code  => p_mpa_acct_line_type_code
              ,p_component_code        => p_mpa_acct_line_code
              ,p_merge_impact          => p_merge_impact);

    record_updated_mpa_assgn
             (p_event_class_code           => p_event_class_code
             ,p_event_type_code            => p_event_type_code
             ,p_line_definition_owner_code => p_line_definition_owner_code
             ,p_line_definition_code       => p_line_definition_code
             ,p_accounting_line_type_code  => p_accounting_line_type_code
             ,p_accounting_line_code       => p_accounting_line_code
             ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_mpa_line_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_mpa_line_assgn;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_assignment
(p_parent_component_type          IN VARCHAR2
,p_product_rule_type_code         IN VARCHAR2
,p_product_rule_code              IN VARCHAR2
,p_event_class_code               IN VARCHAR2
,p_event_type_code                IN VARCHAR2
,p_line_definition_owner_code     IN VARCHAR2
,p_line_definition_code           IN VARCHAR2
,p_accounting_line_type_code      IN VARCHAR2
,p_accounting_line_code           IN VARCHAR2
,p_mpa_acct_line_type_code        IN VARCHAR2
,p_mpa_acct_line_code             IN VARCHAR2
,p_merge_impact                   IN VARCHAR2
,x_parent_key                     IN OUT NOCOPY VARCHAR2)
IS
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_assignment';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_assignment',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (p_parent_component_type = 'AMB_AAD_EVENT_TYPE') THEN
    x_parent_key := p_product_rule_type_code||C_CHAR||
                    p_product_rule_code||C_CHAR||
                    p_event_class_code||C_CHAR||
                    p_event_type_code;

    record_updated_header_assgn
            (p_product_rule_type_code => p_product_rule_type_code
            ,p_product_rule_code      => p_product_rule_code
            ,p_event_class_code       => p_event_class_code
            ,p_event_type_code        => p_event_type_code
            ,p_merge_impact           => p_merge_impact);

  ELSIF (p_parent_component_type = 'AMB_LINE_ASSIGNMENT') THEN
    x_parent_key := p_event_class_code||C_CHAR||
                    p_event_type_code||C_CHAR||
                    p_line_definition_owner_code||C_CHAR||
                    p_line_definition_code||C_CHAR||
                    p_accounting_line_type_code||C_CHAR||
                    p_accounting_line_code;

    record_updated_line_assgn
             (p_event_class_code           => p_event_class_code
             ,p_event_type_code            => p_event_type_code
             ,p_line_definition_owner_code => p_line_definition_owner_code
             ,p_line_definition_code       => p_line_definition_code
             ,p_accounting_line_type_code  => p_accounting_line_type_code
             ,p_accounting_line_code       => p_accounting_line_code
             ,p_merge_impact               => p_merge_impact);

  ELSIF (p_parent_component_type = 'AMB_MPA_ASSIGNMENT') THEN

    x_parent_key := p_event_class_code||C_CHAR||
                    p_event_type_code||C_CHAR||
                    p_line_definition_owner_code||C_CHAR||
                    p_line_definition_code||C_CHAR||
                    p_accounting_line_type_code||C_CHAR||
                    p_accounting_line_code||C_CHAR||
                    'MPA';

    record_updated_mpa_assgn
             (p_event_class_code           => p_event_class_code
             ,p_event_type_code            => p_event_type_code
             ,p_line_definition_owner_code => p_line_definition_owner_code
             ,p_line_definition_code       => p_line_definition_code
             ,p_accounting_line_type_code  => p_accounting_line_type_code
             ,p_accounting_line_code       => p_accounting_line_code
             ,p_merge_impact               => p_merge_impact);

  ELSIF (p_parent_component_type = 'AMB_MPA_LINE_ASSIGNMENT') THEN

    x_parent_key := p_event_class_code||C_CHAR||
                    p_event_type_code||C_CHAR||
                    p_line_definition_owner_code||C_CHAR||
                    p_line_definition_code||C_CHAR||
                    p_accounting_line_type_code||C_CHAR||
                    p_accounting_line_code||C_CHAR||
                    'MPA'||C_CHAR||
                    p_mpa_acct_line_type_code||C_CHAR||
                    p_mpa_acct_line_code;

    record_updated_mpa_line_assgn
             (p_event_class_code              => p_event_class_code
             ,p_event_type_code               => p_event_type_code
             ,p_line_definition_owner_code    => p_line_definition_owner_code
             ,p_line_definition_code          => p_line_definition_code
             ,p_accounting_line_type_code     => p_accounting_line_type_code
             ,p_accounting_line_code          => p_accounting_line_code
             ,p_mpa_acct_line_type_code       => p_mpa_acct_line_type_code
             ,p_mpa_acct_line_code            => p_mpa_acct_line_code
             ,p_merge_impact                  => p_merge_impact);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_assignment',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_assignment;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_deleted_jld
(p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_line_definition_owner_code VARCHAR2
,p_line_definition_code       VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT w.product_rule_type_code
         , w.product_rule_code
      FROM xla_aad_line_defn_assgns w
           LEFT OUTER JOIN xla_aad_line_defn_assgns s
           ON  s.amb_context_code               = g_staging_context_code
           AND s.application_id                 = g_application_id
           AND s.product_rule_type_code         = w.product_rule_type_code
           AND s.product_rule_code              = w.product_rule_code
           AND s.event_class_code               = w.event_class_code
           AND s.event_type_code                = w.event_type_code
           AND s.line_definition_owner_code     = w.line_definition_owner_code
           AND s.line_definition_code           = w.line_definition_code
     WHERE w.amb_context_code            = g_amb_context_code
       AND w.application_id              = g_application_id
       AND w.event_class_code            = p_event_class_code
       AND w.event_type_code             = p_event_type_code
       AND w.line_definition_owner_code  = p_line_definition_owner_code
       AND w.line_definition_code        = p_line_definition_code
       AND (w.event_type_code           = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL);

  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_deleted_jld';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_deleted_jld: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_event_type_code = '||p_event_type_code||
                      ', p_line_definition_owner_code = '||p_line_definition_owner_code||
                      ', p_line_definition_code = '||p_line_definition_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_event_class_code||C_CHAR||
           p_event_type_code||C_CHAR||
           p_line_definition_owner_code||C_CHAR||
           p_line_definition_code;

  IF (NOT key_exists('JLD'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_jld_assgn
            (p_product_rule_type_code     => l_assgn.product_rule_type_code
            ,p_product_rule_code          => l_assgn.product_rule_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_defn_owner_code       => p_line_definition_owner_code
            ,p_line_defn_code             => p_line_definition_code
            ,p_merge_impact               => C_MERGE_IMPACT_DELETED);

    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_deleted_jld',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_deleted_jld;



--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_jlt
(p_event_class_code          VARCHAR2
,p_accounting_line_type_code VARCHAR2
,p_accounting_line_code      VARCHAR2)
IS
    CURSOR c_assgns IS
    SELECT 'AMB_LINE_ASSIGNMENT' parent_component_type
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
      FROM xla_line_defn_jlt_assgns w
         , xla_line_defn_jlt_assgns s
     WHERE s.application_id              = g_application_id
       AND s.amb_context_code            = g_staging_context_code
       AND s.event_class_code            = w.event_class_code
       AND s.event_type_code             = w.event_type_code
       AND s.line_definition_owner_code  = w.line_definition_owner_code
       AND s.line_definition_code        = w.line_definition_code
       AND s.accounting_line_type_code   = w.accounting_line_type_code
       AND s.accounting_line_code        = w.accounting_line_code
       AND w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.event_class_code            = p_event_class_code
       AND w.accounting_line_type_code   = p_accounting_line_type_code
       AND w.accounting_line_code        = p_accounting_line_code
     UNION
    SELECT 'AMB_MPA_LINE_ASSIGNMENT'
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
      FROM xla_mpa_jlt_assgns w
         , xla_mpa_jlt_assgns s
     WHERE s.application_id                = g_application_id
       AND s.amb_context_code              = g_staging_context_code
       AND s.event_class_code              = w.event_class_code
       AND s.event_type_code               = w.event_type_code
       AND s.line_definition_owner_code    = w.line_definition_owner_code
       AND s.line_definition_code          = w.line_definition_code
       AND s.accounting_line_type_code     = w.accounting_line_type_code
       AND s.accounting_line_code          = w.accounting_line_code
       AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
       AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
       AND w.application_id                = g_application_id
       AND w.amb_context_code              = g_amb_context_code
       AND w.event_class_code              = p_event_class_code
       AND w.mpa_accounting_line_type_code = p_accounting_line_type_code
       AND w.mpa_accounting_line_code      = p_accounting_line_code;

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_jlt';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_jlt: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_accounting_line_type_code = '||p_accounting_line_type_code||
                      ', p_accounting_line_code = '||p_accounting_line_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_event_class_code||C_CHAR||
           p_accounting_line_type_code||C_CHAR||
           p_accounting_line_code;

  IF (NOT key_exists('JLT'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_assignment
         (p_parent_component_type          => l_assgn.parent_component_type
         ,p_product_rule_type_code         => NULL
         ,p_product_rule_code              => NULL
         ,p_event_class_code               => l_assgn.event_class_code
         ,p_event_type_code                => l_assgn.event_type_code
         ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
         ,p_line_definition_code           => l_assgn.line_definition_code
         ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
         ,p_accounting_line_code           => l_assgn.accounting_line_code
         ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
         ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
         ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED
         ,x_parent_key                     => l_parent_key);

      record_updated_component
              (p_parent_component_type => l_assgn.parent_component_type
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_JLT'
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_UPDATED
              ,p_event_class_code      => p_event_class_code
              ,p_component_owner_code  => p_accounting_line_type_code
              ,p_component_code        => p_accounting_line_code);

    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_jlt',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_jlt;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_jlt_acct_attr
(p_event_class_code          VARCHAR2
,p_accounting_line_type_code VARCHAR2
,p_accounting_line_code      VARCHAR2
,p_accounting_attribute_code VARCHAR2
,p_merge_impact              VARCHAR2)
IS
  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_jlt_acct_attr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_jlt_acct_attr: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_accounting_line_type_code = '||p_accounting_line_type_code||
                      ', p_accounting_line_code = '||p_accounting_line_code||
                      ', p_accounting_attribute_code = '||p_accounting_attribute_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_parent_key := p_event_class_code||C_CHAR||
                  p_accounting_line_type_code||C_CHAR||
                  p_accounting_line_code;

  l_key := p_accounting_attribute_code;

  IF (NOT key_exists('JAA'||C_CHAR||l_parent_key||C_CHAR||l_key)) THEN
    record_updated_jlt
          (p_event_class_code          => p_event_class_code
          ,p_accounting_line_type_code => p_accounting_line_type_code
          ,p_accounting_line_code      => p_accounting_line_code);

    record_updated_component
          (p_parent_component_type => 'AMB_JLT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_JLT_ACCT_ATTR'
          ,p_component_key         => l_key
          ,p_merge_impact          => p_merge_impact
          ,p_component_code        => p_accounting_attribute_code);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_jlt_acct_attr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_jlt_acct_attr;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_deleted_jlt
(p_event_class_code          VARCHAR2
,p_accounting_line_type_code VARCHAR2
,p_accounting_line_code      VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT 'AMB_LINE_ASSIGNMENT' parent_component_type
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
      FROM xla_line_defn_jlt_assgns w
           LEFT OUTER JOIN xla_line_defn_jlt_assgns   s
           ON  s.amb_context_code            = g_staging_context_code
           AND s.application_id              = g_application_id
           AND s.event_class_code            = w.event_class_code
           AND s.event_type_code             = w.event_type_code
           AND s.line_definition_owner_code  = w.line_definition_owner_code
           AND s.line_definition_code        = w.line_definition_code
           AND s.accounting_line_type_code   = w.accounting_line_type_code
           AND s.accounting_line_code        = w.accounting_line_code
     WHERE w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.event_class_code            = p_event_class_code
       AND w.accounting_line_type_code   = p_accounting_line_type_code
       AND w.accounting_line_code        = p_accounting_line_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL)
     UNION
    SELECT 'AMB_MPA_LINE_ASSIGNMENT'
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
      FROM xla_mpa_jlt_assgns w
           LEFT OUTER JOIN xla_mpa_jlt_assgns s
           ON  s.amb_context_code              = g_staging_context_code
           AND s.application_id                = g_application_id
           AND s.event_class_code              = w.event_class_code
           AND s.event_type_code               = w.event_type_code
           AND s.line_definition_owner_code    = w.line_definition_owner_code
           AND s.line_definition_code          = w.line_definition_code
           AND s.accounting_line_type_code     = w.accounting_line_type_code
           AND s.accounting_line_code          = w.accounting_line_code
           AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
           AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
     WHERE w.application_id                = g_application_id
       AND w.amb_context_code              = g_amb_context_code
       AND w.event_class_code              = p_event_class_code
       AND w.mpa_accounting_line_type_code = p_accounting_line_type_code
       AND w.mpa_accounting_line_code      = p_accounting_line_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL);

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_deleted_jlt';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_deleted_jlt: '||
                      'p_event_class_code = '||p_event_class_code||
                      ', p_accounting_line_type_code = '||p_accounting_line_type_code||
                      ', p_accounting_line_code = '||p_accounting_line_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_event_class_code||C_CHAR||
           p_accounting_line_type_code||C_CHAR||
           p_accounting_line_code;

  IF (NOT key_exists('JLT'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_assignment
         (p_parent_component_type          => l_assgn.parent_component_type
         ,p_product_rule_type_code         => NULL
         ,p_product_rule_code              => NULL
         ,p_event_class_code               => l_assgn.event_class_code
         ,p_event_type_code                => l_assgn.event_type_code
         ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
         ,p_line_definition_code           => l_assgn.line_definition_code
         ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
         ,p_accounting_line_code           => l_assgn.accounting_line_code
         ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
         ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
         ,p_merge_impact                   => C_MERGE_IMPACT_DELETED
         ,x_parent_key                     => l_parent_key);

    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_deleted_jlt',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_deleted_jlt;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_adr_assgn
(p_parent_component_type      VARCHAR2
,p_event_class_code           VARCHAR2
,p_event_type_code            VARCHAR2
,p_line_definition_owner_code VARCHAR2
,p_line_definition_code       VARCHAR2
,p_accounting_line_type_code  VARCHAR2
,p_accounting_line_code       VARCHAR2
,p_mpa_acct_line_type_code    VARCHAR2
,p_mpa_acct_line_code         VARCHAR2
,p_flexfield_segment_code     VARCHAR2
,p_side_code                  VARCHAR2
,p_segment_rule_appl_id       INTEGER
,p_segment_rule_type_code     VARCHAR2
,p_segment_rule_code          VARCHAR2
,p_accounting_coa_id          INTEGER
,p_merge_impact               VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_adr_key                VARCHAR2(240);
  l_parent_key             VARCHAR2(240);
  l_parent_component_type2 VARCHAR2(30);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_adr_assgn';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_adr_assgn: '||
                      'p_segment_rule_type_code = '||p_segment_rule_type_code||
                      ', p_segment_rule_code = '||p_segment_rule_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_adr_key := p_segment_rule_appl_id||C_CHAR||
               p_segment_rule_type_code||C_CHAR||
               p_segment_rule_code;

  IF (p_parent_component_type = 'AMB_ADR_ASSGN') THEN
    l_parent_component_type2 := 'AMB_LINE_ASSIGNMENT';
  ELSIF (p_parent_component_type = 'AMB_MPA_ADR_ASSGN') THEN
    l_parent_component_type2 := 'AMB_MPA_LINE_ASSIGNMENT';
  END IF;

  record_updated_assignment
            (p_parent_component_type          => l_parent_component_type2
            ,p_product_rule_type_code         => NULL
            ,p_product_rule_code              => NULL
            ,p_event_class_code               => p_event_class_code
            ,p_event_type_code                => p_event_type_code
            ,p_line_definition_owner_code     => p_line_definition_owner_code
            ,p_line_definition_code           => p_line_definition_code
            ,p_accounting_line_type_code      => p_accounting_line_type_code
            ,p_accounting_line_code           => p_accounting_line_code
            ,p_mpa_acct_line_type_code        => p_mpa_acct_line_type_code
            ,p_mpa_acct_line_code             => p_mpa_acct_line_code
            ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED
            ,x_parent_key                     => l_parent_key);

  IF (p_parent_component_type = 'AMB_ADR_ASSGN') THEN

    l_key := l_parent_key||C_CHAR||
             p_flexfield_segment_code||C_CHAR||
             p_side_code;

  ELSIF (p_parent_component_type = 'AMB_MPA_ADR_ASSGN') THEN

    l_key := l_parent_key||C_CHAR||
             p_flexfield_segment_code;

  END IF;

  record_updated_component
              (p_parent_component_type => l_parent_component_type2
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => p_parent_component_type
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_UPDATED
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => TO_CHAR(p_accounting_coa_id)
              ,p_component_code        => p_flexfield_segment_code);

  record_updated_component
              (p_parent_component_type => p_parent_component_type
              ,p_parent_component_key  => l_key
              ,p_component_type        => 'AMB_ADR'
              ,p_component_key         => l_adr_key
              ,p_merge_impact          => p_merge_impact
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_appl_id     => p_segment_rule_appl_id
              ,p_component_owner_code  => p_segment_rule_type_code
              ,p_component_code        => p_segment_rule_code);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_adr_assgn',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_adr_assgn;


--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_adr
(p_segment_rule_appl_id   INTEGER
,p_segment_rule_type_code VARCHAR2
,p_segment_rule_code      VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT 'AMB_ADR_ASSGN' parent_component_type
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
         , w.flexfield_segment_code
         , w.side_code
         , l.accounting_coa_id
      FROM xla_line_defn_adr_assgns w
         , xla_line_defn_adr_assgns s
         , xla_line_definitions_b l
     WHERE s.application_id              = g_application_id
       AND s.amb_context_code            = g_staging_context_code
       AND s.event_class_code            = w.event_class_code
       AND s.event_type_code             = w.event_type_code
       AND s.line_definition_owner_code  = w.line_definition_owner_code
       AND s.line_definition_code        = w.line_definition_code
       AND s.flexfield_segment_code      = w.flexfield_segment_code
       AND s.side_code                   = w.side_code
       AND s.segment_rule_type_code      = w.segment_rule_type_code
       AND s.segment_rule_code           = w.segment_rule_code
       AND l.application_id              = g_application_id
       AND l.amb_context_code            = g_staging_context_code
       AND l.event_class_code            = w.event_class_code
       AND l.event_type_code             = w.event_type_code
       AND l.line_definition_owner_code  = w.line_definition_owner_code
       AND l.line_definition_code        = w.line_definition_code
       AND w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.segment_rule_type_code      = p_segment_rule_type_code
       AND w.segment_rule_code           = p_segment_rule_code
     UNION
    SELECT 'AMB_MPA_ADR_ASSGN' parent_component_type
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
         , w.flexfield_segment_code
         , NULL
         , l.accounting_coa_id
      FROM xla_mpa_jlt_adr_assgns w
         , xla_mpa_jlt_adr_assgns s
         , xla_mpa_jlt_assgns     j
         , xla_line_definitions_b l
     WHERE s.application_id                = g_application_id
       AND s.amb_context_code              = g_staging_context_code
       AND s.event_class_code              = w.event_class_code
       AND s.event_type_code               = w.event_type_code
       AND s.line_definition_owner_code    = w.line_definition_owner_code
       AND s.line_definition_code          = w.line_definition_code
       AND s.accounting_line_type_code     = w.accounting_line_type_code
       AND s.accounting_line_code          = w.accounting_line_code
       AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
       AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
       AND s.flexfield_segment_code        = w.flexfield_segment_code
       AND s.segment_rule_type_code        = w.segment_rule_type_code
       AND s.segment_rule_code             = w.segment_rule_code
       AND j.application_id                = g_application_id
       AND j.amb_context_code              = g_staging_context_code
       AND j.event_class_code              = w.event_class_code
       AND j.event_type_code               = w.event_type_code
       AND j.line_definition_owner_code    = w.line_definition_owner_code
       AND j.line_definition_code          = w.line_definition_code
       AND j.accounting_line_type_code     = w.accounting_line_type_code
       AND j.accounting_line_code          = w.accounting_line_code
       AND l.application_id                = g_application_id
       AND l.amb_context_code              = g_staging_context_code
       AND l.event_class_code              = w.event_class_code
       AND l.event_type_code               = w.event_type_code
       AND l.line_definition_owner_code    = w.line_definition_owner_code
       AND l.line_definition_code          = w.line_definition_code
       AND w.application_id                = g_application_id
       AND w.amb_context_code              = g_amb_context_code
       AND w.segment_rule_type_code        = p_segment_rule_type_code
       AND w.segment_rule_code             = p_segment_rule_code;

  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_adr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_adr: '||
                      'p_segment_rule_type_code = '||p_segment_rule_type_code||
                      ', p_segment_rule_code = '||p_segment_rule_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_segment_rule_appl_id||C_CHAR||
           p_segment_rule_type_code||C_CHAR||
           p_segment_rule_code;

  IF (NOT key_exists('ADR'||C_CHAR||l_key)) THEN

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'BEGIN LOOP: key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    FOR l_assgn IN c_assgns LOOP

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'LOOP: mpa_accounting_line_code = '||l_assgn.mpa_accounting_line_code,
              p_module => l_log_module,
              p_level  => C_LEVEL_PROCEDURE);
      END IF;

      record_updated_adr_assgn
            (p_parent_component_type          => l_assgn.parent_component_type
            ,p_event_class_code               => l_assgn.event_class_code
            ,p_event_type_code                => l_assgn.event_type_code
            ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
            ,p_line_definition_code           => l_assgn.line_definition_code
            ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
            ,p_accounting_line_code           => l_assgn.accounting_line_code
            ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
            ,p_flexfield_segment_code         => l_assgn.flexfield_segment_code
            ,p_side_code                      => l_assgn.side_code
            ,p_segment_rule_appl_id           => p_segment_rule_appl_id
            ,p_segment_rule_type_code         => p_segment_rule_type_code
            ,p_segment_rule_code              => p_segment_rule_code
            ,p_accounting_coa_id              => l_assgn.accounting_coa_id
            ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED);

    END LOOP;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END LOOP: key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_adr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_adr;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_deleted_adr
(p_segment_rule_appl_id   INTEGER
,p_segment_rule_type_code VARCHAR2
,p_segment_rule_code      VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT 'AMB_ADR_ASSGN' parent_component_type
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
         , w.flexfield_segment_code
         , w.side_code
         , l.accounting_coa_id
      FROM xla_line_defn_adr_assgns w
           JOIN xla_line_definitions_b l
           ON  l.amb_context_code            = g_amb_context_code
           AND l.application_id              = g_application_id
           AND l.event_class_code            = w.event_class_code
           AND l.event_type_code             = w.event_type_code
           AND l.line_definition_owner_code  = w.line_definition_owner_code
           AND l.line_definition_code        = w.line_definition_code
           LEFT OUTER JOIN xla_line_defn_adr_assgns s
           ON  s.amb_context_code            = g_staging_context_code
           AND s.application_id              = g_application_id
           AND s.event_class_code            = w.event_class_code
           AND s.event_type_code             = w.event_type_code
           AND s.line_definition_owner_code  = w.line_definition_owner_code
           AND s.line_definition_code        = w.line_definition_code
           AND s.accounting_line_type_code   = w.accounting_line_type_code
           AND s.accounting_line_code        = w.accounting_line_code
           AND s.flexfield_segment_code      = w.flexfield_segment_code
           AND s.side_code                   = w.side_code
     WHERE w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.segment_rule_type_code      = p_segment_rule_type_code
       AND w.segment_rule_code           = p_segment_rule_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL)
     UNION
    SELECT 'AMB_MPA_ADR_ASSGN'
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
         , w.flexfield_segment_code
         , NULL
         , l.accounting_coa_id
      FROM xla_mpa_jlt_adr_assgns w
           JOIN xla_line_definitions_b l
           ON  l.amb_context_code            = g_amb_context_code
           AND l.application_id              = g_application_id
           AND l.event_class_code            = w.event_class_code
           AND l.event_type_code             = w.event_type_code
           AND l.line_definition_owner_code  = w.line_definition_owner_code
           AND l.line_definition_code        = w.line_definition_code
           JOIN xla_mpa_jlt_assgns j
           ON  j.amb_context_code              = g_amb_context_code
           AND j.application_id                = g_application_id
           AND j.event_class_code              = w.event_class_code
           AND j.event_type_code               = w.event_type_code
           AND j.line_definition_owner_code    = w.line_definition_owner_code
           AND j.line_definition_code          = w.line_definition_code
           AND j.accounting_line_type_code     = w.accounting_line_type_code
           AND j.accounting_line_code          = w.accounting_line_code
           AND j.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
           AND j.mpa_accounting_line_code      = w.mpa_accounting_line_code
           LEFT OUTER JOIN xla_mpa_jlt_adr_assgns s
           ON  s.amb_context_code              = g_staging_context_code
           AND s.application_id                = g_application_id
           AND s.event_class_code              = w.event_class_code
           AND s.event_type_code               = w.event_type_code
           AND s.line_definition_owner_code    = w.line_definition_owner_code
           AND s.line_definition_code          = w.line_definition_code
           AND s.accounting_line_type_code     = w.accounting_line_type_code
           AND s.accounting_line_code          = w.accounting_line_code
           AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
           AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
           AND s.flexfield_segment_code        = w.flexfield_segment_code
     WHERE w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.segment_rule_type_code      = p_segment_rule_type_code
       AND w.segment_rule_code           = p_segment_rule_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL);

  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_deleted_adr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_deleted_adr: '||
                      'p_segment_rule_type_code = '||p_segment_rule_type_code||
                      ', p_segment_rule_code = '||p_segment_rule_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_segment_rule_appl_id||C_CHAR||
           p_segment_rule_type_code||C_CHAR||
           p_segment_rule_code;

  IF (NOT key_exists('ADR'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_adr_assgn
            (p_parent_component_type          => l_assgn.parent_component_type
            ,p_event_class_code               => l_assgn.event_class_code
            ,p_event_type_code                => l_assgn.event_type_code
            ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
            ,p_line_definition_code           => l_assgn.line_definition_code
            ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
            ,p_accounting_line_code           => l_assgn.accounting_line_code
            ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
            ,p_flexfield_segment_code         => l_assgn.flexfield_segment_code
            ,p_side_code                      => l_assgn.side_code
            ,p_segment_rule_appl_id           => p_segment_rule_appl_id
            ,p_segment_rule_type_code         => p_segment_rule_type_code
            ,p_segment_rule_code              => p_segment_rule_code
            ,p_accounting_coa_id              => l_assgn.accounting_coa_id
            ,p_merge_impact                   => C_MERGE_IMPACT_DELETED);

    END LOOP;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_deleted_adr',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_deleted_adr;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_adr_detail
(p_segment_rule_appl_id   INTEGER
,p_segment_rule_type_code VARCHAR2
,p_segment_rule_code      VARCHAR2
,p_user_sequence          INTEGER
,p_merge_impact           VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_adr_detail';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_adr_detail: '||
                      'p_segment_rule_type_code = '||p_segment_rule_type_code||
                      ', p_segment_rule_code = '||p_segment_rule_code||
                      ', p_user_sequence = '||p_user_sequence,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_segment_rule_appl_id||C_CHAR||
           p_segment_rule_type_code||C_CHAR||
           p_segment_rule_code||C_CHAR||
           p_user_sequence;

  IF (NOT key_exists('ADRD'||C_CHAR||l_key)) THEN

    record_updated_component
              (p_parent_component_type => 'AMB_ADR'
              ,p_parent_component_key  => p_segment_rule_appl_id||C_CHAR||
                                          p_segment_rule_type_code||C_CHAR||
                                          p_segment_rule_code
              ,p_component_type        => 'AMB_ADR_DETAIL'
              ,p_component_key         => l_key
              ,p_merge_impact          => p_merge_impact
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => NULL
              ,p_component_code        => p_user_sequence);

    record_updated_adr
            (p_segment_rule_appl_id   => p_segment_rule_appl_id
            ,p_segment_rule_type_code => p_segment_rule_type_code
            ,p_segment_rule_code      => p_segment_rule_code);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_adr_detail',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_adr_detail;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_ms
(p_mapping_set_code       VARCHAR2
,p_merge_impact           VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT application_id segment_rule_appl_id
         , segment_rule_type_code
         , segment_rule_code
         , user_sequence
      FROM xla_seg_rule_details s
     WHERE application_id         = g_application_id
       AND amb_context_code       = g_amb_context_code
       AND value_mapping_set_code = p_mapping_set_code;

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_ms';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_ms: '||
                      ', p_mapping_set_code = '||p_mapping_set_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_mapping_set_code;

  IF (NOT key_exists('MS'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      l_parent_key := l_assgn.segment_rule_type_code||C_CHAR||
                      l_assgn.segment_rule_code||C_CHAR||
                      l_assgn.user_sequence;

      IF (NOT key_exists('ADRMS'||C_CHAR||l_key)) THEN
        record_updated_component
              (p_parent_component_type => 'AMB_ADR_DETAIL'
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_MS'
              ,p_component_key         => l_key
              ,p_merge_impact          => p_merge_impact
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => NULL
              ,p_component_code        => p_mapping_set_code);

        record_updated_adr_detail
            (p_segment_rule_appl_id   => l_assgn.segment_rule_appl_id
            ,p_segment_rule_type_code => l_assgn.segment_rule_type_code
            ,p_segment_rule_code      => l_assgn.segment_rule_code
            ,p_user_sequence          => l_assgn.user_sequence
            ,p_merge_impact           => C_MERGE_IMPACT_UPDATED);

      END IF;
    END LOOP;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_ms',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_ms;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_ms_value
(p_mapping_set_code           VARCHAR2
,p_flexfield_assign_mode_code VARCHAR2
,p_value_set_id               INTEGER
,p_view_application_id        INTEGER
,p_lookup_type                VARCHAR2
,p_value_constant             VARCHAR2
,p_effective_date_from        DATE
,p_effective_date_to          DATE
,p_enabled_flag               VARCHAR2
,p_input_value_type_code      VARCHAR2
,p_input_value_constant       VARCHAR2
,p_merge_impact               VARCHAR2)
IS
  l_key                    VARCHAR2(720);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_ms_value';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_ms_value: '||
                      'p_mapping_set_code = '||p_mapping_set_code||
                      ', p_input_value_type_code = '||p_input_value_type_code||
                      ', p_input_value_constant = '||p_input_value_constant||
                      ', p_value_constant = '||p_value_constant||
                      ', p_effective_date_from = '||p_effective_date_from||
                      ', p_effective_date_to = '||p_effective_date_to||
                      ', p_enabled_flag = '||p_enabled_flag,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_mapping_set_code||C_CHAR||
           p_input_value_type_code||C_CHAR||
           p_input_value_constant||C_CHAR||
           p_value_constant||C_CHAR||
           TO_CHAR(p_effective_date_from,'J')||C_CHAR||
           TO_CHAR(p_effective_date_to,'J')||C_CHAR||
           p_enabled_flag;

  record_updated_property
          (p_component_type => 'AMB_MS_VALUE'
          ,p_component_key  => l_key
          ,p_property       => 'INPUT_VALUE_TYPE'
          ,p_old_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                    THEN p_input_value_type_code ELSE NULL END
          ,p_new_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                    THEN p_input_value_type_code ELSE NULL END);

  IF (p_input_value_constant IS NOT NULL) THEN
    record_updated_value
            (p_component_type          => 'AMB_MS_VALUE'
            ,p_component_key           => l_key
            ,p_property                => 'INPUT_VALUE'
            ,p_old_value               => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                          THEN p_input_value_constant ELSE NULL END
            ,p_old_source_app_id       => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                          THEN p_value_set_id ELSE NULL END
            ,p_old_source_type_code    => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                          THEN p_view_application_id ELSE NULL END
            ,p_old_source_code         => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                          THEN p_lookup_type ELSE NULL END
            ,p_new_value               => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                          THEN p_input_value_constant ELSE NULL END
            ,p_new_source_app_id       => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                          THEN p_value_set_id ELSE NULL END
            ,p_new_source_type_code    => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                          THEN p_view_application_id ELSE NULL END
            ,p_new_source_code         => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                          THEN p_lookup_type ELSE NULL END);
  END IF;

  IF (p_flexfield_assign_mode_code = 'S') THEN
    record_updated_property
          (p_component_type => 'AMB_MS_VALUE'
          ,p_component_key  => l_key
          ,p_property       => 'OUTPUT_VALUE'
          ,p_old_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                    THEN p_value_constant ELSE NULL END
          ,p_new_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                    THEN p_value_constant ELSE NULL END);
  END IF;

  record_updated_property
          (p_component_type => 'AMB_MS_VALUE'
          ,p_component_key  => l_key
          ,p_property       => 'EFFECTIVE_DATE_FROM'
          ,p_old_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                    THEN p_effective_date_from ELSE NULL END
          ,p_new_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                    THEN p_effective_date_from ELSE NULL END);

  record_updated_property
          (p_component_type => 'AMB_MS_VALUE'
          ,p_component_key  => l_key
          ,p_property       => 'EFFECTIVE_DATE_TO'
          ,p_old_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                    THEN p_effective_date_to ELSE NULL END
          ,p_new_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                    THEN p_effective_date_to ELSE NULL END);

  record_updated_property
          (p_component_type => 'AMB_MS_VALUE'
          ,p_component_key  => l_key
          ,p_property       => 'ENABLED'
          ,p_old_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_DELETED
                                    THEN p_enabled_flag ELSE NULL END
          ,p_new_value      => CASE WHEN p_merge_impact = C_MERGE_IMPACT_NEW
                                    THEN p_enabled_flag ELSE NULL END
          ,p_lookup_type    => 'XLA_YES_NO');

  IF (NOT key_exists('MSV'||C_CHAR||l_key)) THEN
    record_updated_component
          (p_parent_component_type => 'AMB_MS'
          ,p_parent_component_key  => p_mapping_set_code
          ,p_component_type        => 'AMB_MS_VALUE'
          ,p_component_key         => l_key
          ,p_merge_impact          => p_merge_impact
          ,p_event_class_code      => NULL
          ,p_event_type_code       => NULL
          ,p_component_owner_code  => NULL
          ,p_component_code        => NULL);
  END IF;

  record_updated_ms
            (p_mapping_set_code => p_mapping_set_code
            ,p_merge_impact     => C_MERGE_IMPACT_UPDATED);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_ms_value',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_ms_value;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_desc
(p_description_type_code       VARCHAR2
,p_description_code            VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT 'AMB_AAD_EVENT_TYPE' parent_component_type
         , w.product_rule_type_code
         , w.product_rule_code
         , w.event_class_code
         , w.event_type_code
         , NULL line_definition_owner_code
         , NULL line_definition_code
         , NULL accounting_line_type_code
         , NULL accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
      FROM xla_prod_acct_headers w
         , xla_prod_acct_headers s
     WHERE s.application_id         = g_application_id
       AND s.amb_context_code       = g_staging_context_code
       AND s.product_rule_type_code = w.product_rule_type_code
       AND s.product_rule_code      = w.product_rule_code
       AND s.event_class_code       = w.event_class_code
       AND s.event_type_code        = w.event_type_code
       AND s.description_type_code  = w.description_type_code
       AND s.description_code       = w.description_code
       AND w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.description_type_code  = p_description_type_code
       AND w.description_code       = p_description_code
   UNION
    SELECT 'AMB_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_line_defn_jlt_assgns w
         , xla_line_defn_jlt_assgns s
     WHERE s.application_id              = g_application_id
       AND s.amb_context_code            = g_staging_context_code
       AND s.event_class_code            = w.event_class_code
       AND s.event_type_code             = w.event_type_code
       AND s.line_definition_owner_code  = w.line_definition_owner_code
       AND s.line_definition_code        = w.line_definition_code
       AND s.accounting_line_type_code   = w.accounting_line_type_code
       AND s.accounting_line_code        = w.accounting_line_code
       AND s.description_type_code       = w.description_type_code
       AND s.description_code            = w.description_code
       AND w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.description_type_code       = p_description_type_code
       AND w.description_code            = p_description_code
   UNION
    SELECT 'AMB_MPA_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_line_defn_jlt_assgns w
         , xla_line_defn_jlt_assgns s
     WHERE s.application_id              = g_application_id
       AND s.amb_context_code            = g_staging_context_code
       AND s.event_class_code            = w.event_class_code
       AND s.event_type_code             = w.event_type_code
       AND s.line_definition_owner_code  = w.line_definition_owner_code
       AND s.line_definition_code        = w.line_definition_code
       AND s.accounting_line_type_code   = w.accounting_line_type_code
       AND s.accounting_line_code        = w.accounting_line_code
       AND s.mpa_header_desc_type_code   = w.mpa_header_desc_type_code
       AND s.mpa_header_desc_code        = w.mpa_header_desc_code
       AND w.application_id              = g_application_id
       AND w.amb_context_code            = g_amb_context_code
       AND w.mpa_header_desc_type_code   = p_description_type_code
       AND w.mpa_header_desc_code        = p_description_code
   UNION
    SELECT 'AMB_MPA_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
      FROM xla_mpa_jlt_assgns w
         , xla_mpa_jlt_assgns s
     WHERE s.application_id                = g_application_id
       AND s.amb_context_code              = g_staging_context_code
       AND s.event_class_code              = w.event_class_code
       AND s.event_type_code               = w.event_type_code
       AND s.line_definition_owner_code    = w.line_definition_owner_code
       AND s.line_definition_code          = w.line_definition_code
       AND s.accounting_line_type_code     = w.accounting_line_type_code
       AND s.accounting_line_code          = w.accounting_line_code
       AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
       AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
       AND s.description_type_code         = w.description_type_code
       AND s.description_code              = w.description_code
       AND w.application_id                = g_application_id
       AND w.amb_context_code              = g_amb_context_code
       AND w.description_type_code         = p_description_type_code
       AND w.description_code              = p_description_code;

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_desc';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_desc: '||
                      ', p_description_type_code = '||p_description_type_code||
                      ', p_description_code = '||p_description_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_description_type_code||C_CHAR||
           p_description_code;

  IF (NOT key_exists('DESC'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_assignment
         (p_parent_component_type          => l_assgn.parent_component_type
         ,p_product_rule_type_code         => l_assgn.product_rule_type_code
         ,p_product_rule_code              => l_assgn.product_rule_code
         ,p_event_class_code               => l_assgn.event_class_code
         ,p_event_type_code                => l_assgn.event_type_code
         ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
         ,p_line_definition_code           => l_assgn.line_definition_code
         ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
         ,p_accounting_line_code           => l_assgn.accounting_line_code
         ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
         ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
         ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED
         ,x_parent_key                     => l_parent_key);

      record_updated_component
              (p_parent_component_type => l_assgn.parent_component_type
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_DESCRIPTION'
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_UPDATED
              ,p_component_owner_code  => p_description_type_code
              ,p_component_code        => p_description_code);

    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_desc',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_desc;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_deleted_desc
(p_description_type_code       VARCHAR2
,p_description_code            VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT 'AMB_AAD_EVENT_TYPE' parent_component_type
         , w.product_rule_type_code
         , w.product_rule_code
         , w.event_class_code
         , w.event_type_code
         , NULL line_definition_owner_code
         , NULL line_definition_code
         , NULL accounting_line_type_code
         , NULL accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
      FROM xla_prod_acct_headers w
           LEFT OUTER JOIN xla_prod_acct_headers s
           ON  s.amb_context_code               = g_staging_context_code
           AND s.application_id                 = g_application_id
           AND s.product_rule_type_code         = w.product_rule_type_code
           AND s.product_rule_code              = w.product_rule_code
           AND s.event_class_code               = w.event_class_code
           AND s.event_type_code                = w.event_type_code
     WHERE w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.description_type_code  = p_description_type_code
       AND w.description_code       = p_description_code
       AND (w.product_rule_type_code = C_OWNER_CUSTOM OR
            s.product_rule_type_code IS NOT NULL)
    UNION
    SELECT 'AMB_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_line_defn_jlt_assgns w
           LEFT OUTER JOIN xla_line_defn_jlt_assgns   s
           ON  s.amb_context_code            = g_staging_context_code
           AND s.application_id              = g_application_id
           AND s.event_class_code            = w.event_class_code
           AND s.event_type_code             = w.event_type_code
           AND s.line_definition_owner_code  = w.line_definition_owner_code
           AND s.line_definition_code        = w.line_definition_code
           AND s.accounting_line_type_code   = w.accounting_line_type_code
           AND s.accounting_line_code        = w.accounting_line_code
     WHERE w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.description_type_code  = p_description_type_code
       AND w.description_code       = p_description_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL)
     UNION
    SELECT 'AMB_MPA_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_line_defn_jlt_assgns w
           LEFT OUTER JOIN xla_line_defn_jlt_assgns   s
           ON  s.amb_context_code            = g_staging_context_code
           AND s.application_id              = g_application_id
           AND s.event_class_code            = w.event_class_code
           AND s.event_type_code             = w.event_type_code
           AND s.line_definition_owner_code  = w.line_definition_owner_code
           AND s.line_definition_code        = w.line_definition_code
           AND s.accounting_line_type_code   = w.accounting_line_type_code
           AND s.accounting_line_code        = w.accounting_line_code
     WHERE w.application_id             = g_application_id
       AND w.amb_context_code           = g_amb_context_code
       AND w.mpa_header_desc_type_code  = p_description_type_code
       AND w.mpa_header_desc_code       = p_description_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL)
     UNION
    SELECT 'AMB_MPA_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
      FROM xla_mpa_jlt_assgns w
           LEFT OUTER JOIN xla_mpa_jlt_assgns s
           ON  s.amb_context_code              = g_staging_context_code
           AND s.application_id                = g_application_id
           AND s.event_class_code              = w.event_class_code
           AND s.event_type_code               = w.event_type_code
           AND s.line_definition_owner_code    = w.line_definition_owner_code
           AND s.line_definition_code          = w.line_definition_code
           AND s.accounting_line_type_code     = w.accounting_line_type_code
           AND s.accounting_line_code          = w.accounting_line_code
           AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
           AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
     WHERE w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.description_type_code  = p_description_type_code
       AND w.description_code       = p_description_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL);

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_deleted_desc';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_deleted_desc: '||
                      ', p_description_type_code = '||p_description_type_code||
                      ', p_description_code = '||p_description_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_description_type_code||C_CHAR||
           p_description_code;

  IF (NOT key_exists('DESC'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_assignment
         (p_parent_component_type          => l_assgn.parent_component_type
         ,p_product_rule_type_code         => l_assgn.product_rule_type_code
         ,p_product_rule_code              => l_assgn.product_rule_code
         ,p_event_class_code               => l_assgn.event_class_code
         ,p_event_type_code                => l_assgn.event_type_code
         ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
         ,p_line_definition_code           => l_assgn.line_definition_code
         ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
         ,p_accounting_line_code           => l_assgn.accounting_line_code
         ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
         ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
         ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED
         ,x_parent_key                     => l_parent_key);

      record_updated_component
              (p_parent_component_type => l_assgn.parent_component_type
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_DESCRIPTION'
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_DELETED
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => p_description_type_code
              ,p_component_code        => p_description_code);

    END LOOP;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_deleted_desc',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_deleted_desc;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_desc_priority
(p_description_type_code       VARCHAR2
,p_description_code            VARCHAR2
,p_user_sequence               VARCHAR2
,p_merge_impact                VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_desc_priority';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_desc_priority: '||
                      ', p_description_type_code = '||p_description_type_code||
                      ', p_description_code = '||p_description_code||
                      ', p_user_sequence = '||p_user_sequence,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_description_type_code||C_CHAR||
           p_description_code||C_CHAR||
           p_user_sequence;

  IF (NOT key_exists('DESCP'||C_CHAR||l_key)) THEN
    record_updated_component
              (p_parent_component_type        => 'AMB_DESCRIPTION'
              ,p_parent_component_key         => p_description_type_code||C_CHAR||
                                                 p_description_code
              ,p_component_type               => 'AMB_DESC_PRIO'
              ,p_component_key                => l_key
              ,p_merge_impact                 => p_merge_impact
              ,p_event_class_code             => NULL
              ,p_event_type_code              => NULL
              ,p_component_code               => p_user_sequence
              ,p_parent_component_owner_code  => p_description_type_code
              ,p_parent_component_code        => p_description_code);

    record_updated_desc
              (p_description_type_code => p_description_type_code
              ,p_description_code      => p_description_code);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_desc_priority',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_desc_priority;

--=============================================================================
--
-- Name: record_updated_ac
-- Description: Determine all the components that references the AC that is
--              modified, and record that the component is updated.
--
--=============================================================================
PROCEDURE record_updated_ac
(p_ac_type_code       VARCHAR2
,p_ac_code            VARCHAR2
,p_merge_impact       VARCHAR2)
IS
  CURSOR c_assgns IS
    SELECT 'AMB_AAD_EVENT_TYPE' parent_component_type
         , w.product_rule_type_code
         , w.product_rule_code
         , w.event_class_code
         , w.event_type_code
         , NULL line_definition_owner_code
         , NULL line_definition_code
         , NULL accounting_line_type_code
         , NULL accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
      FROM xla_aad_header_ac_assgns w
         , xla_prod_acct_headers b
     WHERE b.amb_context_code               = g_staging_context_code
       AND b.application_id                 = g_application_id
       AND b.product_rule_type_code         = w.product_rule_type_code
       AND b.product_rule_code              = w.product_rule_code
       AND b.event_class_code               = w.event_class_code
       AND b.event_type_code                = w.event_type_code
       AND w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
     UNION
    SELECT 'AMB_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_line_defn_ac_assgns w
         , xla_line_defn_jlt_assgns b
     WHERE b.amb_context_code               = g_staging_context_code
       AND b.application_id                 = g_application_id
       AND b.event_class_code               = w.event_class_code
       AND b.event_type_code                = w.event_type_code
       AND b.line_definition_owner_code     = w.line_definition_owner_code
       AND b.line_definition_code           = w.line_definition_code
       AND b.accounting_line_type_code      = w.accounting_line_type_code
       AND b.accounting_line_code           = w.accounting_line_code
       AND w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
     UNION
    SELECT 'AMB_MPA_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_mpa_header_ac_assgns w
         , xla_line_defn_jlt_assgns b
     WHERE b.amb_context_code               = g_staging_context_code
       AND b.application_id                 = g_application_id
       AND b.event_class_code               = w.event_class_code
       AND b.event_type_code                = w.event_type_code
       AND b.line_definition_owner_code     = w.line_definition_owner_code
       AND b.line_definition_code           = w.line_definition_code
       AND b.accounting_line_type_code      = w.accounting_line_type_code
       AND b.accounting_line_code           = w.accounting_line_code
       AND w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
     UNION
    SELECT 'AMB_MPA_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
      FROM xla_mpa_jlt_ac_assgns w
         , xla_mpa_jlt_assgns    b
     WHERE b.amb_context_code               = g_staging_context_code
       AND b.application_id                 = g_application_id
       AND b.event_class_code               = w.event_class_code
       AND b.event_type_code                = w.event_type_code
       AND b.line_definition_owner_code     = w.line_definition_owner_code
       AND b.line_definition_code           = w.line_definition_code
       AND b.accounting_line_type_code      = w.accounting_line_type_code
       AND b.accounting_line_code           = w.accounting_line_code
       AND b.mpa_accounting_line_type_code  = w.mpa_accounting_line_type_code
       AND b.mpa_accounting_line_code       = w.mpa_accounting_line_code
       AND w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code;

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_ac';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_ac: '||
                      ', p_ac_type_code = '||p_ac_type_code||
                      ', p_ac_code = '||p_ac_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_ac_type_code||C_CHAR||
           p_ac_code;

  IF (NOT key_exists('AC'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_assignment
         (p_parent_component_type          => l_assgn.parent_component_type
         ,p_product_rule_type_code         => l_assgn.product_rule_type_code
         ,p_product_rule_code              => l_assgn.product_rule_code
         ,p_event_class_code               => l_assgn.event_class_code
         ,p_event_type_code                => l_assgn.event_type_code
         ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
         ,p_line_definition_code           => l_assgn.line_definition_code
         ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
         ,p_accounting_line_code           => l_assgn.accounting_line_code
         ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
         ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
         ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED
         ,x_parent_key                     => l_parent_key);

      record_updated_component
              (p_parent_component_type => l_assgn.parent_component_type
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_AC'
              ,p_component_key         => l_key
              ,p_merge_impact          => p_merge_impact
              ,p_event_class_code      => NULL
              ,p_event_type_code       => NULL
              ,p_component_owner_code  => p_ac_type_code
              ,p_component_code        => p_ac_code);

    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_ac',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_ac;

--=============================================================================
--
-- Name: record_deleted_ac
-- Description: For the deleted ORACLE AC, determine if it is referenced by any
--              CUSTOM component.  If so, report the component updated.
--
--=============================================================================
PROCEDURE record_deleted_ac
(p_ac_type_code       VARCHAR2
,p_ac_code            VARCHAR2)
IS
  --
  -- Marked the AC is deleted from the assignment if
  -- 1. The AC is assigned to any CUSTOM component in the working context OR
  -- 2. The AC assignment exists in the staging context
  --
  CURSOR c_assgns IS
    SELECT 'AMB_AAD_EVENT_TYPE' parent_component_type
         , w.product_rule_type_code
         , w.product_rule_code
         , w.event_class_code
         , w.event_type_code
         , NULL line_definition_owner_code
         , NULL line_definition_code
         , NULL accounting_line_type_code
         , NULL accounting_line_code
         , NULL mpa_accounting_line_type_code
         , NULL mpa_accounting_line_code
      FROM xla_aad_header_ac_assgns w
           LEFT OUTER JOIN xla_prod_acct_headers s
           ON  s.amb_context_code               = g_staging_context_code
           AND s.application_id                 = g_application_id
           AND s.product_rule_type_code         = w.product_rule_type_code
           AND s.product_rule_code              = w.product_rule_code
           AND s.event_class_code               = w.event_class_code
           AND s.event_type_code                = w.event_type_code
     WHERE w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
       AND (w.product_rule_type_code = C_OWNER_CUSTOM OR
            s.product_rule_type_code IS NOT NULL)
     UNION
    SELECT 'AMB_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_line_defn_ac_assgns w
           LEFT OUTER JOIN xla_line_defn_jlt_assgns s
           ON  s.amb_context_code           = g_staging_context_code
           AND s.event_class_code           = w.event_class_code
           AND s.event_type_code            = w.event_type_code
           AND s.line_definition_owner_code = w.line_definition_owner_code
           AND s.line_definition_code       = w.line_definition_code
           AND s.accounting_line_type_code  = w.accounting_line_type_code
           AND s.accounting_line_code       = w.accounting_line_code
     WHERE w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
       AND (w.accounting_line_type_code = C_OWNER_CUSTOM OR
            s.accounting_line_type_code IS NOT NULL)
     UNION
    SELECT 'AMB_MPA_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , NULL
         , NULL
      FROM xla_mpa_header_ac_assgns w
           LEFT OUTER JOIN xla_line_defn_jlt_assgns s
           ON  s.amb_context_code           = g_staging_context_code
           AND s.event_class_code           = w.event_class_code
           AND s.event_type_code            = w.event_type_code
           AND s.line_definition_owner_code = w.line_definition_owner_code
           AND s.line_definition_code       = w.line_definition_code
           AND s.accounting_line_type_code  = w.accounting_line_type_code
           AND s.accounting_line_code       = w.accounting_line_code
     WHERE w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL)
     UNION
    SELECT 'AMB_MPA_LINE_ASSIGNMENT'
         , NULL
         , NULL
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
      FROM xla_mpa_jlt_ac_assgns w
           LEFT OUTER JOIN xla_mpa_jlt_assgns s
           ON  s.amb_context_code              = g_staging_context_code
           AND s.event_class_code              = w.event_class_code
           AND s.event_type_code               = w.event_type_code
           AND s.line_definition_owner_code    = w.line_definition_owner_code
           AND s.line_definition_code          = w.line_definition_code
           AND s.accounting_line_type_code     = w.accounting_line_type_code
           AND s.accounting_line_code          = w.accounting_line_code
           AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
           AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
     WHERE w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = p_ac_type_code
       AND w.analytical_criterion_code      = p_ac_code
       AND (w.line_definition_owner_code = C_OWNER_CUSTOM OR
            s.line_definition_owner_code IS NOT NULL);

  l_parent_key             VARCHAR2(240);
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_deleted_ac';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_deleted_ac: '||
                      ', p_ac_type_code = '||p_ac_type_code||
                      ', p_ac_code = '||p_ac_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_ac_type_code||C_CHAR||
           p_ac_code;

  IF (NOT key_exists('AC'||C_CHAR||l_key)) THEN
    FOR l_assgn IN c_assgns LOOP

      record_updated_assignment
         (p_parent_component_type          => l_assgn.parent_component_type
         ,p_product_rule_type_code         => l_assgn.product_rule_type_code
         ,p_product_rule_code              => l_assgn.product_rule_code
         ,p_event_class_code               => l_assgn.event_class_code
         ,p_event_type_code                => l_assgn.event_type_code
         ,p_line_definition_owner_code     => l_assgn.line_definition_owner_code
         ,p_line_definition_code           => l_assgn.line_definition_code
         ,p_accounting_line_type_code      => l_assgn.accounting_line_type_code
         ,p_accounting_line_code           => l_assgn.accounting_line_code
         ,p_mpa_acct_line_type_code        => l_assgn.mpa_accounting_line_type_code
         ,p_mpa_acct_line_code             => l_assgn.mpa_accounting_line_code
         ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED
         ,x_parent_key                     => l_parent_key);

      record_updated_component
              (p_parent_component_type => l_assgn.parent_component_type
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_AC'
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_DELETED
              ,p_component_owner_code  => p_ac_type_code
              ,p_component_code        => p_ac_code);

    END LOOP;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_deleted_ac',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_deleted_ac;

--=============================================================================
--
--
--
--=============================================================================
PROCEDURE record_updated_ac_detail
(p_ac_type_code       VARCHAR2
,p_ac_code            VARCHAR2
,p_ac_detail_code     VARCHAR2
,p_merge_impact       VARCHAR2)
IS
  l_key                    VARCHAR2(240);
  l_log_module             VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.record_updated_ac_detail';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function record_updated_ac_detail: '||
                      ', p_ac_type_code = '||p_ac_type_code||
                      ', p_ac_code = '||p_ac_code||
                      ', p_ac_detail_code = '||p_ac_detail_code,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_key := p_ac_type_code||C_CHAR||
           p_ac_code||C_CHAR||
           p_ac_detail_code;

  IF (NOT key_exists('ACD'||C_CHAR||l_key)) THEN

    record_updated_component
              (p_parent_component_type        => 'AMB_AC'
              ,p_parent_component_key         => p_ac_type_code||C_CHAR||
                                                 p_ac_code
              ,p_component_type               => 'AMB_AC_DETAIL'
              ,p_component_key                => l_key
              ,p_merge_impact                 => p_merge_impact
              ,p_event_class_code             => NULL
              ,p_event_type_code              => NULL
              ,p_component_owner_code         => NULL
              ,p_component_code               => p_ac_detail_code
              ,p_parent_component_owner_code  => p_ac_type_code
              ,p_parent_component_code        => p_ac_code);

    record_updated_ac
              (p_ac_type_code          => p_ac_type_code
              ,p_ac_code               => p_ac_code
              ,p_merge_impact          => C_MERGE_IMPACT_UPDATED);

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function record_updated_ac_detail',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END record_updated_ac_detail;

--=============================================================================
--
-- Name: update_group_number
-- Description: This API update the product rule in global aad group arry with
--              the group number
-- Return Code:
--   TRUE: group number is updated
--   FALSE: group number is not updated
--
--=============================================================================
FUNCTION update_group_number
(p_product_rule_type_code  VARCHAR2
,p_product_rule_code       VARCHAR2
,p_group_number            INTEGER)
RETURN BOOLEAN
IS
  l_retcode       BOOLEAN;
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_group_number';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function update_group_number: '||
                      p_product_rule_type_code||','||
                      p_product_rule_code||','||
                      p_group_number,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_retcode := FALSE;

  FOR i IN 1 .. g_aad_groups.COUNT LOOP
    IF (g_aad_groups(i).product_rule_type_code = p_product_rule_type_code AND
        g_aad_groups(i).product_rule_code = p_product_rule_code) THEN
      IF (g_aad_groups(i).group_num <> p_group_number) THEN
        g_aad_groups(i).group_num := p_group_number;
        l_retcode := TRUE;
      END IF;
      EXIT;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function update_group_number',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  return l_retcode;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_aad_merge_analysis_pvt.update_group_number');

END update_group_number;


--=============================================================================
--
-- Name: compare_components
-- Description:
--
--=============================================================================
PROCEDURE compare_components
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_components';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_components',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_components',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_components;


--=============================================================================
--
-- Name: analyze_deleted_oracle_aads
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_aads
IS
  CURSOR c_comp IS
    SELECT w.product_rule_type_code
         , w.product_rule_code
      FROM xla_product_rules_b w
     WHERE w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.product_rule_type_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_product_rules_b s
            WHERE s.application_id         = g_application_id
              AND s.amb_context_code       = g_staging_context_code
              AND s.product_rule_type_code = w.product_rule_type_code
              AND s.product_rule_code      = w.product_rule_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle aad '||
                        '- product_rule_type_code = '||l_comp.product_rule_type_code||
                        ', product_rule_code = '||l_comp.product_rule_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_aad
          (p_product_rule_type_code => l_comp.product_rule_type_code
          ,p_product_rule_code      => l_comp.product_rule_code
          ,p_merge_impact           => C_MERGE_IMPACT_DELETED);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_aads;

--=============================================================================
--
-- Name: analyze_deleted_oracle_ems
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_ems
IS
  CURSOR c_comp IS
    SELECT w.product_rule_type_code
         , w.product_rule_code
         , w.event_class_code
         , w.event_type_code
      FROM xla_prod_acct_headers w
         , xla_product_rules_b b
     WHERE b.application_id         = g_application_id
       AND b.amb_context_code       = g_staging_context_code
       AND b.product_rule_type_code = w.product_rule_type_code
       AND b.product_rule_code      = w.product_rule_code
       AND w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.product_rule_type_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_prod_acct_headers s
            WHERE s.application_id         = g_application_id
              AND s.amb_context_code       = g_staging_context_code
              AND s.product_rule_type_code = w.product_rule_type_code
              AND s.product_rule_code      = w.product_rule_code
              AND s.event_class_code       = w.event_class_code
              AND s.event_type_code        = w.event_type_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_ems';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_ems',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle event types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle event type '||
                        '- product_rule_type_code = '||l_comp.product_rule_type_code||
                        ', product_rule_code = '||l_comp.product_rule_code||
                        ', event_class_code = '||l_comp.event_class_code||
                        ', event_type_code = '||l_comp.event_type_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_header_assgn
          (p_product_rule_type_code => l_comp.product_rule_type_code
          ,p_product_rule_code      => l_comp.product_rule_code
          ,p_event_class_code       => l_comp.event_class_code
          ,p_event_type_code        => l_comp.event_type_code
          ,p_merge_impact           => C_MERGE_IMPACT_DELETED);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle event types',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_ems',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_ems;

--=============================================================================
--
-- Name: analyze_deleted_oracle_adrs
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_adrs
IS
  CURSOR c_comp IS
    SELECT w.application_id segment_rule_appl_id
          ,w.segment_rule_type_code
         , w.segment_rule_code
      FROM xla_seg_rules_b w
     WHERE w.application_id        = g_application_id
       AND w.amb_context_code      = g_amb_context_code
       AND w.segment_rule_type_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_seg_rules_b s
            WHERE s.application_id         = g_application_id
              AND s.amb_context_code       = g_staging_context_code
              AND s.segment_rule_type_code = w.segment_rule_type_code
              AND s.segment_rule_code      = w.segment_rule_code);

  CURSOR c_comp_dtl IS
    SELECT w.application_id segment_rule_appl_id
          ,w.segment_rule_type_code
          ,w.segment_rule_code
          ,w.user_sequence
          ,C_MERGE_IMPACT_DELETED
      FROM xla_seg_rule_details w
         , xla_seg_rules_b b
     WHERE b.application_id         = g_application_id
       AND b.amb_context_code       = g_staging_context_code
       AND b.segment_rule_type_code = w.segment_rule_type_code
       AND b.segment_rule_code      = w.segment_rule_code
       AND w.application_id         = g_application_id
       AND w.amb_context_code       = g_amb_context_code
       AND w.segment_rule_type_code = C_OWNER_ORACLE
       AND NOT EXISTS
           (SELECT 1
              FROM xla_seg_rule_details s
             WHERE s.application_id         = g_application_id
               AND s.amb_context_code       = g_staging_context_code
               AND s.segment_rule_type_code = w.segment_rule_type_code
               AND s.segment_rule_code      = w.segment_rule_code
               AND s.user_sequence          = w.user_sequence);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_adrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle adr '||
                        '- segment_rule_type_code = '||l_comp.segment_rule_type_code||
                        ', segment_rule_code = '||l_comp.segment_rule_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_deleted_adr
          (p_segment_rule_appl_id   => l_comp.segment_rule_appl_id
          ,p_segment_rule_type_code => l_comp.segment_rule_type_code
          ,p_segment_rule_code      => l_comp.segment_rule_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle adr details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp_dtl LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle adr detail '||
                        '- segment_rule_type_code = '||l_comp.segment_rule_type_code||
                        ', segment_rule_code = '||l_comp.segment_rule_code||
                        ', user_sequence = '||l_comp.user_sequence,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_adr_detail
          (p_segment_rule_appl_id   => l_comp.segment_rule_appl_id
          ,p_segment_rule_type_code => l_comp.segment_rule_type_code
          ,p_segment_rule_code      => l_comp.segment_rule_code
          ,p_user_sequence          => l_comp.user_sequence
          ,p_merge_impact           => C_MERGE_IMPACT_DELETED);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle adr details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_adrs;

--=============================================================================
--
-- Name: analyze_deleted_oracle_acs
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_acs
IS
  CURSOR c_comp IS
    SELECT w.analytical_criterion_type_code
         , w.analytical_criterion_code
      FROM xla_analytical_hdrs_b w
     WHERE w.application_id        = g_application_id
       AND w.amb_context_code      = g_amb_context_code
       AND w.analytical_criterion_type_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_analytical_hdrs_b s
            WHERE s.application_id                 = g_application_id
              AND s.amb_context_code               = g_staging_context_code
              AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
              AND s.analytical_criterion_code      = w.analytical_criterion_code);

  CURSOR c_comp_dtl IS
    SELECT w.analytical_criterion_type_code
          ,w.analytical_criterion_code
          ,w.analytical_detail_code
      FROM xla_analytical_dtls_b w
         , xla_analytical_hdrs_b b
     WHERE b.amb_context_code               = g_staging_context_code
       AND b.application_id                 = g_application_id
       AND b.analytical_criterion_type_code = w.analytical_criterion_type_code
       AND b.analytical_criterion_code      = w.analytical_criterion_code
       AND w.amb_context_code               = g_amb_context_code
       AND w.analytical_criterion_type_code = C_OWNER_ORACLE
       AND NOT EXISTS
           (SELECT 1
              FROM xla_analytical_dtls_b s
             WHERE s.amb_context_code               = g_staging_context_code
               AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
               AND s.analytical_criterion_code      = w.analytical_criterion_code
               AND s.analytical_detail_code         = w.analytical_detail_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_acs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle ac ',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle ac '||
                        '- analytical_criterion_type_code = '||l_comp.analytical_criterion_type_code||
                        ', analytical_criterion_code = '||l_comp.analytical_criterion_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_deleted_ac
          (p_ac_type_code => l_comp.analytical_criterion_type_code
          ,p_ac_code      => l_comp.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle ac ',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle ac details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp_dtl LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle ac detail '||
                        '- analytical_criterion_type_code = '||l_comp.analytical_criterion_type_code||
                        ', analytical_criterion_code = '||l_comp.analytical_criterion_code||
                        ', analytical_detail_code = '||l_comp.analytical_detail_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_ac_detail
          (p_ac_type_code   => l_comp.analytical_criterion_type_code
          ,p_ac_code        => l_comp.analytical_criterion_code
          ,p_ac_detail_code => l_comp.analytical_detail_code
          ,p_merge_impact   => C_MERGE_IMPACT_DELETED);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle ac details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_acs;

--=============================================================================
--
-- Name: analyze_deleted_oracle_descs
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_descs
IS
  CURSOR c_comp IS
    SELECT w.description_type_code
         , w.description_code
      FROM xla_descriptions_b w
     WHERE w.application_id        = g_application_id
       AND w.amb_context_code      = g_amb_context_code
       AND w.description_type_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_descriptions_b s
            WHERE s.application_id        = g_application_id
              AND s.amb_context_code      = g_staging_context_code
              AND s.description_type_code = w.description_type_code
              AND s.description_code      = w.description_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_descs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_descs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle ac '||
                        '- description_type_code = '||l_comp.description_type_code||
                        ', description_code = '||l_comp.description_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_deleted_desc
          (p_description_type_code => l_comp.description_type_code
          ,p_description_code      => l_comp.description_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle descriptions',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_descs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_descs;

--=============================================================================
--
-- Name: analyze_deleted_oracle_jlts
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_jlts
IS
  CURSOR c_comp IS
    SELECT w.event_class_code
         , w.accounting_line_type_code
         , w.accounting_line_code
      FROM xla_acct_line_types_b w
     WHERE w.application_id            = g_application_id
       AND w.amb_context_code          = g_amb_context_code
       AND w.accounting_line_type_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_acct_line_types_b s
            WHERE s.application_id            = g_application_id
              AND s.amb_context_code          = g_staging_context_code
              AND s.event_class_code          = w.event_class_code
              AND s.accounting_line_type_code = w.accounting_line_type_code
              AND s.accounting_line_code      = w.accounting_line_code);

  CURSOR c_comp_dtl IS
    SELECT w.event_class_code
         , w.accounting_line_type_code
          ,w.accounting_line_code
          ,w.accounting_attribute_code
      FROM xla_jlt_acct_attrs w
         , xla_acct_line_types_b b
     WHERE b.amb_context_code          = g_staging_context_code
       AND b.application_id            = g_application_id
       AND b.accounting_line_type_code = w.accounting_line_type_code
       AND b.accounting_line_code      = w.accounting_line_code
       AND w.amb_context_code          = g_amb_context_code
       AND w.application_id            = g_application_id
       AND w.accounting_line_type_code = C_OWNER_ORACLE
       AND NOT EXISTS
           (SELECT 1
              FROM xla_jlt_acct_attrs s
             WHERE s.amb_context_code          = g_staging_context_code
               AND s.application_id            = g_application_id
               AND s.accounting_line_type_code = w.accounting_line_type_code
               AND s.accounting_line_code      = w.accounting_line_code
               AND s.accounting_attribute_code = w.accounting_attribute_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_jlts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle jlt '||
                        '- event_class_code = '||l_comp.event_class_code||
                        ', accounting_line_type_code = '||l_comp.accounting_line_type_code||
                        ', accounting_line_code = '||l_comp.accounting_line_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_deleted_jlt
          (p_event_class_code          => l_comp.event_class_code
          ,p_accounting_line_type_code => l_comp.accounting_line_type_code
          ,p_accounting_line_code      => l_comp.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle jlt details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp_dtl LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle jlt '||
                        '- event_class_code = '||l_comp.event_class_code||
                        ', accounting_line_type_code = '||l_comp.accounting_line_type_code||
                        ', accounting_line_code = '||l_comp.accounting_line_code||
                        ', accounting_attribute_code = '||l_comp.accounting_attribute_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_jlt_acct_attr
          (p_event_class_code          => l_comp.event_class_code
          ,p_accounting_line_type_code => l_comp.accounting_line_type_code
          ,p_accounting_line_code      => l_comp.accounting_line_code
          ,p_accounting_attribute_code => l_comp.accounting_attribute_code
          ,p_merge_impact              => C_MERGE_IMPACT_DELETED);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle jlt details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_jlts;

--=============================================================================
--
-- Name: analyze_deleted_oracle_jlds
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_jlds
IS
  CURSOR c_comp IS
    SELECT w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
      FROM xla_line_definitions_b w
     WHERE w.application_id             = g_application_id
       AND w.amb_context_code           = g_amb_context_code
       AND w.line_definition_owner_code = C_OWNER_ORACLE
       AND NOT EXISTS (
           SELECT 1
             FROM xla_line_definitions_b s
            WHERE s.application_id             = g_application_id
              AND s.amb_context_code           = g_staging_context_code
              AND s.event_class_code           = w.event_class_code
              AND s.event_type_code            = w.event_type_code
              AND s.line_definition_owner_code = w.line_definition_owner_code
              AND s.line_definition_code       = w.line_definition_code);

  CURSOR c_assgn IS
    SELECT w.product_rule_type_code
         , w.product_rule_code
         , w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
      FROM xla_aad_line_defn_assgns w
         , xla_prod_acct_headers    b
     WHERE b.amb_context_code           = g_staging_context_code
       AND b.application_id             = g_application_id
       AND b.product_rule_type_code     = w.product_rule_type_code
       AND b.product_rule_code          = w.product_rule_code
       AND b.event_class_code           = w.event_class_code
       AND b.event_type_code            = w.event_type_code
       AND w.amb_context_code           = g_amb_context_code
       AND w.application_id             = g_application_id
       AND w.line_definition_owner_code = C_OWNER_ORACLE
       AND NOT EXISTS
           (SELECT 1
              FROM xla_aad_line_defn_assgns s
             WHERE s.amb_context_code           = g_staging_context_code
               AND s.application_id             = g_application_id
               AND s.product_rule_type_code     = w.product_rule_type_code
               AND s.product_rule_code          = w.product_rule_code
               AND s.event_class_code           = w.event_class_code
               AND s.event_type_code            = w.event_type_code
               AND s.line_definition_owner_code = w.line_definition_owner_code
               AND s.line_definition_code       = w.line_definition_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_jlds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle jld '||
                        '- event_class_code = '||l_comp.event_class_code||
                        ', event_type_code = '||l_comp.event_type_code||
                        ', line_definition_owner_code = '||l_comp.line_definition_owner_code||
                        ', line_definition_code = '||l_comp.line_definition_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_deleted_jld
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: deleted oracle jld assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_assgn LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: deleted oracle jld assgns '||
                        '- product_rule_type_code = '||l_comp.product_rule_type_code||
                        ', product_rule_code = '||l_comp.product_rule_code||
                        ', event_class_code = '||l_comp.event_class_code||
                        ', event_type_code = '||l_comp.event_type_code||
                        ', line_definition_owner_code = '||l_comp.line_definition_owner_code||
                        ', line_definition_code = '||l_comp.line_definition_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_jld_assgn
          (p_product_rule_type_code     => l_comp.product_rule_type_code
          ,p_product_rule_code          => l_comp.product_rule_code
          ,p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_defn_owner_code       => l_comp.line_definition_owner_code
          ,p_line_defn_code             => l_comp.line_definition_code
          ,p_merge_impact               => C_MERGE_IMPACT_DELETED);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: deleted oracle jld assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_jlds;


--=============================================================================
--
-- Name: analyze_deleted_oracle_comps
-- Description:
--
--=============================================================================
PROCEDURE analyze_deleted_oracle_comps
IS
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_deleted_oracle_comps';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_deleted_oracle_comps',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  analyze_deleted_oracle_acs;
  analyze_deleted_oracle_adrs;
  analyze_deleted_oracle_descs;
  analyze_deleted_oracle_jlts;
  analyze_deleted_oracle_jlds;
  analyze_deleted_oracle_ems;
  analyze_deleted_oracle_aads;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_deleted_oracle_comps',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END analyze_deleted_oracle_comps;


--=============================================================================
--
-- Name: compare_mapping_sets
-- Description:
--
--=============================================================================
PROCEDURE compare_mapping_sets
IS
  CURSOR c_comp IS
    SELECT ts.mapping_set_code
          ,ts.name                        s_name
          ,tw.name                        w_name
          ,ts.description                 s_description
          ,tw.description                 w_description
          ,bs.accounting_coa_id           s_accounting_coa_id
          ,bw.accounting_coa_id           w_accounting_coa_id
          ,bs.value_set_id                s_value_set_id
          ,bw.value_set_id                w_value_set_id
          ,bs.enabled_flag                s_enabled_flag
          ,bw.enabled_flag                w_enabled_flag
          ,bs.flexfield_assign_mode_code  s_flexfield_assign_mode_code
          ,bw.flexfield_assign_mode_code  w_flexfield_assign_mode_code
          ,bs.flexfield_segment_code      s_flexfield_segment_code
          ,bw.flexfield_segment_code      w_flexfield_segment_code
          ,bs.view_application_id         s_view_application_id
          ,bw.view_application_id         w_view_application_id
          ,bs.lookup_type                 s_lookup_type
          ,bw.lookup_type                 w_lookup_type
      FROM xla_mapping_sets_b bs
           JOIN xla_mapping_sets_tl ts
           ON  ts.amb_context_code      = bs.amb_context_code
           AND ts.mapping_set_code      = bs.mapping_set_code
           AND ts.language              = USERENV('LANG')
           JOIN xla_mapping_sets_b bw
           ON  bw.amb_context_code      = g_amb_context_code
           AND bw.mapping_set_code      = bs.mapping_set_code
           JOIN xla_mapping_sets_tl tw
           ON  tw.amb_context_code      = bw.amb_context_code
           AND tw.mapping_set_code      = bw.mapping_set_code
           AND tw.language              = USERENV('LANG')
     WHERE bs.amb_context_code          = g_staging_context_code
       AND (ts.name                           <> tw.name                           OR
            NVL(ts.description,C_CHAR)        <> NVL(tw.description,C_CHAR)        OR
            NVL(bs.value_set_id,C_NUM)        <> NVL(bw.value_set_id,C_NUM)        OR
            NVL(bs.accounting_coa_id,C_NUM)   <> NVL(bw.accounting_coa_id,C_NUM)   OR
            bs.flexfield_assign_mode_code     <> bw.flexfield_assign_mode_code     OR
            NVL(bs.flexfield_segment_code,C_CHAR) <> NVL(bw.flexfield_segment_code,C_CHAR)     OR
            NVL(bs.view_application_id,C_NUM) <> NVL(bw.view_application_id,C_NUM) OR
            NVL(bs.lookup_type,C_CHAR)        <> NVL(bw.lookup_type,C_CHAR)        OR
            bs.enabled_flag                   <> bw.enabled_flag);

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mapping_sets';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mapping sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated ms '||
                        '- mapping_set_code = '||l_comp.mapping_set_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    l_key := l_comp.mapping_set_code;

    IF (l_comp.s_name <> l_comp.w_name) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
    END IF;

    IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
    END IF;

    IF (NVL(l_comp.s_accounting_coa_id,C_NUM) <> NVL(l_comp.w_accounting_coa_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_COA'
          ,p_old_value               => l_comp.w_accounting_coa_id
          ,p_new_value               => l_comp.s_accounting_coa_id);
    END IF;

    IF (NVL(l_comp.s_value_set_id,C_NUM) <> NVL(l_comp.w_value_set_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'VALUE_SET'
          ,p_old_value               => l_comp.w_value_set_id
          ,p_new_value               => l_comp.s_value_set_id);
    END IF;

    IF (l_comp.s_flexfield_assign_mode_code <> l_comp.w_flexfield_assign_mode_code) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'FLEXFIELD_ASSIGN_MODE'
          ,p_old_value               => l_comp.w_flexfield_assign_mode_code
          ,p_new_value               => l_comp.s_flexfield_assign_mode_code
          ,p_lookup_type             => 'XLA_ASSIGN_FLEX_MODE');
    END IF;

    IF (NVL(l_comp.s_flexfield_segment_code,C_CHAR) <> NVL(l_comp.w_flexfield_segment_code,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'FLEXFIELD_SEGMENT'
          ,p_old_value               => l_comp.w_flexfield_segment_code
          ,p_new_value               => l_comp.s_flexfield_segment_code);
    END IF;

    IF (NVL(l_comp.s_view_application_id,C_NUM) <> NVL(l_comp.w_view_application_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'VIEW_APPLICATION'
          ,p_old_value               => l_comp.w_view_application_id
          ,p_new_value               => l_comp.s_view_application_id);
    END IF;

    IF (NVL(l_comp.s_lookup_type,C_CHAR) <> NVL(l_comp.w_lookup_type,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'LOOKUP_TYPE'
          ,p_old_value               => l_comp.w_lookup_type
          ,p_new_value               => l_comp.s_lookup_type);
    END IF;

    IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_MS'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    record_updated_ms
          (p_mapping_set_code => l_comp.mapping_set_code
          ,p_merge_impact     => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mapping sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mapping_sets',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mapping_sets;

--=============================================================================
--
-- Name: compare_mapping_set_values
-- Description:
--
--=============================================================================
PROCEDURE compare_mapping_set_values
IS
  CURSOR c_comp IS
    SELECT s.mapping_set_code
          ,bs.flexfield_assign_mode_code
          ,bs.value_set_id
          ,bs.view_application_id
          ,bs.lookup_type
          ,s.value_constant
          ,s.effective_date_from
          ,s.effective_date_to
          ,s.enabled_flag
          ,s.input_value_type_code
          ,s.input_value_constant
          ,C_MERGE_IMPACT_NEW merge_impact
      FROM xla_mapping_set_values s
           JOIN xla_mapping_sets_b bs
           ON  bs.amb_context_code      = s.amb_context_code
           AND bs.mapping_set_code      = s.mapping_set_code
     WHERE s.amb_context_code = g_staging_context_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_mapping_set_values w
             WHERE w.amb_context_code                      = g_amb_context_code
               AND w.mapping_set_code                      = s.mapping_set_code
               AND NVL(w.value_constant,C_CHAR)            = NVL(s.value_constant,C_CHAR)
               AND w.effective_date_from                   = s.effective_date_from
               AND NVL(w.effective_date_to,C_DATE)         = NVL(s.effective_date_to,C_DATE)
               AND w.enabled_flag                          = s.enabled_flag
               AND w.input_value_type_code                 = s.input_value_type_code
               AND NVL(w.input_value_constant,C_CHAR)      = NVL(s.input_value_constant,C_CHAR))
     UNION
    SELECT w.mapping_set_code
          ,bw.flexfield_assign_mode_code
          ,bw.value_set_id
          ,bw.view_application_id
          ,bw.lookup_type
          ,w.value_constant
          ,w.effective_date_from
          ,w.effective_date_to
          ,w.enabled_flag
          ,w.input_value_type_code
          ,w.input_value_constant
          ,C_MERGE_IMPACT_DELETED
      FROM xla_mapping_set_values w
           JOIN xla_mapping_sets_b bw
           ON  bw.amb_context_code      = w.amb_context_code
           AND bw.mapping_set_code      = w.mapping_set_code
     WHERE w.amb_context_code = g_staging_context_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_mapping_set_values s
             WHERE s.amb_context_code                      = g_staging_context_code
               AND s.mapping_set_code                      = w.mapping_set_code
               AND NVL(s.value_constant,C_CHAR)            = NVL(w.value_constant,C_CHAR)
               AND s.effective_date_from                   = w.effective_date_from
               AND NVL(s.effective_date_to,C_DATE)         = NVL(w.effective_date_to,C_DATE)
               AND s.enabled_flag                          = w.enabled_flag
               AND s.input_value_type_code                 = w.input_value_type_code
               AND NVL(s.input_value_constant,C_CHAR)      = NVL(w.input_value_constant,C_CHAR));

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mapping_set_values';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mapping_set_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mapping set values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated ms value '||
                        '- mapping_set_code = '||l_comp.mapping_set_code||
                        ', merge_impact = '||l_comp.merge_impact,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_ms_value
            (p_mapping_set_code          => l_comp.mapping_set_code
            ,p_flexfield_assign_mode_code=> l_comp.flexfield_assign_mode_code
            ,p_value_set_id              => l_comp.value_set_id
            ,p_view_application_id       => l_comp.view_application_id
            ,p_lookup_type               => l_comp.lookup_type
            ,p_value_constant            => l_comp.value_constant
            ,p_effective_date_from       => l_comp.effective_date_from
            ,p_effective_date_to         => l_comp.effective_date_to
            ,p_enabled_flag              => l_comp.enabled_flag
            ,p_input_value_type_code     => l_comp.input_value_type_code
            ,p_input_value_constant      => l_comp.input_value_constant
            ,p_merge_impact              => l_comp.merge_impact);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mapping set values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mapping_set_values',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mapping_set_values;

--=============================================================================
--
-- Name: compare_adrs
-- Description:
--
--=============================================================================
PROCEDURE compare_adrs
IS
  CURSOR c_comp IS
    SELECT ts.application_id segment_rule_appl_id
          ,ts.segment_rule_type_code
          ,ts.segment_rule_code
          ,ts.name                        s_name
          ,tw.name                        w_name
          ,ts.description                 s_description
          ,tw.description                 w_description
          ,bs.transaction_coa_id          s_transaction_coa_id
          ,bw.transaction_coa_id          w_transaction_coa_id
          ,bs.accounting_coa_id           s_accounting_coa_id
          ,bw.accounting_coa_id           w_accounting_coa_id
          ,bs.flexfield_assign_mode_code  s_flexfield_assign_mode_code
          ,bw.flexfield_assign_mode_code  w_flexfield_assign_mode_code
          ,bs.flexfield_segment_code      s_flexfield_segment_code
          ,bw.flexfield_segment_code      w_flexfield_segment_code
          ,bs.enabled_flag                s_enabled_flag
          ,bw.enabled_flag                w_enabled_flag
      FROM xla_seg_rules_b bs
           JOIN xla_seg_rules_tl ts
           ON  ts.application_id          = bs.application_id
           AND ts.amb_context_code        = bs.amb_context_code
           AND ts.segment_rule_type_code  = bs.segment_rule_type_code
           AND ts.segment_rule_code       = bs.segment_rule_code
           AND ts.language                = USERENV('LANG')
           JOIN xla_seg_rules_b bw
           ON  bw.application_id          = g_application_id
           AND bw.amb_context_code        = g_amb_context_code
           AND bw.segment_rule_type_code  = bs.segment_rule_type_code
           AND bw.segment_rule_code       = bs.segment_rule_code
           JOIN xla_seg_rules_tl tw
           ON  tw.application_id          = bw.application_id
           AND tw.amb_context_code        = bw.amb_context_code
           AND tw.segment_rule_type_code  = bw.segment_rule_type_code
           AND tw.segment_rule_code       = bw.segment_rule_code
           AND tw.language                = USERENV('LANG')
     WHERE bs.application_id              = g_application_id
       AND bs.amb_context_code            = g_staging_context_code
       AND (ts.name                               <> tw.name                              OR
            NVL(ts.description,C_CHAR)            <> NVL(tw.description,C_CHAR)           OR
            nvl(bs.transaction_coa_id,C_NUM)      <> NVL(bw.transaction_coa_id,C_NUM)     OR
            nvl(bs.accounting_coa_id,C_NUM)       <> NVL(bw.accounting_coa_id,C_NUM)      OR
            bs.flexfield_assign_mode_code         <> bw.flexfield_assign_mode_code        OR
            NVL(bs.flexfield_segment_code,C_CHAR) <> NVL(bw.flexfield_segment_code,C_CHAR)OR
            bs.enabled_flag                       <> bw.enabled_flag);

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_adrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    l_key := l_comp.segment_rule_appl_id||C_CHAR||
             l_comp.segment_rule_type_code||C_CHAR||
             l_comp.segment_rule_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated adr - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (l_comp.s_name <> l_comp.w_name) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
    END IF;

    IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
    END IF;

    IF (NVL(l_comp.s_transaction_coa_id,C_NUM) <> NVL(l_comp.w_transaction_coa_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'TRANSACTION_COA'
          ,p_old_value               => l_comp.w_transaction_coa_id
          ,p_new_value               => l_comp.s_transaction_coa_id);
    END IF;

    IF (NVL(l_comp.s_accounting_coa_id,C_NUM) <> NVL(l_comp.w_accounting_coa_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_COA'
          ,p_old_value               => l_comp.w_accounting_coa_id
          ,p_new_value               => l_comp.s_accounting_coa_id);
    END IF;

    IF (l_comp.s_flexfield_assign_mode_code <> l_comp.w_flexfield_assign_mode_code) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'FLEXFIELD_ASSIGN_MODE'
          ,p_old_value               => l_comp.w_flexfield_assign_mode_code
          ,p_new_value               => l_comp.s_flexfield_assign_mode_code
          ,p_lookup_type             => 'XLA_ASSIGN_FLEX_MODE');
    END IF;

    IF (NVL(l_comp.s_flexfield_segment_code,C_CHAR) <> NVL(l_comp.w_flexfield_segment_code,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'FLEXFIELD_SEGMENT'
          ,p_old_value               => l_comp.w_flexfield_segment_code
          ,p_new_value               => l_comp.s_flexfield_segment_code);
    END IF;

    IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_ADR'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    record_updated_adr
          (p_segment_rule_appl_id   => l_comp.segment_rule_appl_id
          ,p_segment_rule_type_code => l_comp.segment_rule_type_code
          ,p_segment_rule_code      => l_comp.segment_rule_code);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_adrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_adrs;

--=============================================================================
--
-- Name: compare_adr_details
-- Description:
--
--=============================================================================
PROCEDURE compare_adr_details
IS
  CURSOR c_comp IS
    SELECT s.application_id segment_rule_appl_id
          ,s.segment_rule_type_code
          ,s.segment_rule_code
          ,s.user_sequence
          ,CASE WHEN w.user_sequence IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED END merge_impact
          ,bs.accounting_coa_id           s_accounting_coa_id
          ,bw.accounting_coa_id           w_accounting_coa_id
          ,s.value_type_code              s_value_type_code
          ,w.value_type_code              w_value_type_code
          ,s.value_code_combination_id    s_value_ccid
          ,w.value_code_combination_id    w_value_ccid
          ,s.value_source_application_id  s_value_source_app_id
          ,w.value_source_application_id  w_value_source_app_id
          ,s.value_source_type_code       s_value_source_type_code
          ,w.value_source_type_code       w_value_source_type_code
          ,s.value_source_code            s_value_source_code
          ,w.value_source_code            w_value_source_code
          ,s.value_constant               s_value_constant
          ,w.value_constant               w_value_constant
          ,s.value_mapping_set_code       s_value_mapping_set_code
          ,w.value_mapping_set_code       w_value_mapping_set_code
          ,s.value_flexfield_segment_code s_value_flexfield_segment_code
          ,w.value_flexfield_segment_code w_value_flexfield_segment_code
          ,s.value_segment_rule_appl_id   s_value_segment_rule_appl_id
          ,s.value_segment_rule_appl_id   w_value_segment_rule_appl_id
          ,s.value_segment_rule_type_code s_value_segment_rule_type_code
          ,s.value_segment_rule_type_code w_value_segment_rule_type_code
          ,s.value_segment_rule_code      s_value_segment_rule_code
          ,s.value_segment_rule_code      w_value_segment_rule_code
          ,s.input_source_application_id  s_input_source_app_id
          ,w.input_source_application_id  w_input_source_app_id
          ,s.input_source_type_code       s_input_source_type_code
          ,w.input_source_type_code       w_input_source_type_code
          ,s.input_source_code            s_input_source_code
          ,w.input_source_code            w_input_source_code
      FROM xla_seg_rule_details s
           JOIN xla_seg_rules_b bs
           ON  bs.application_id           = g_application_id
           AND bs.amb_context_code         = g_staging_context_code
           AND bs.segment_rule_type_code   = s.segment_rule_type_code
           AND bs.segment_rule_code        = s.segment_rule_code
           JOIN xla_seg_rules_b bw
           ON  bw.application_id           = g_application_id
           AND bw.amb_context_code         = g_amb_context_code
           AND bw.segment_rule_type_code   = s.segment_rule_type_code
           AND bw.segment_rule_code        = s.segment_rule_code
           LEFT OUTER JOIN xla_seg_rule_details w
           ON  w.application_id           = g_application_id
           AND w.amb_context_code         = g_amb_context_code
           AND w.segment_rule_type_code   = s.segment_rule_type_code
           AND w.segment_rule_code        = s.segment_rule_code
           AND w.user_sequence            = s.user_sequence
     WHERE s.application_id               = g_application_id
       AND s.amb_context_code             = g_staging_context_code
       AND (w.value_type_code IS NULL OR
            NVL(s.value_type_code,C_CHAR)              <> NVL(w.value_type_code,C_CHAR)              OR
            NVL(s.value_code_combination_id,C_NUM)     <> NVL(w.value_code_combination_id,C_NUM)     OR
            NVL(s.value_source_application_id,C_NUM)   <> NVL(w.value_source_application_id,C_NUM)   OR
            NVL(s.value_source_type_code,C_CHAR)       <> NVL(w.value_source_type_code,C_CHAR)       OR
            NVL(s.value_source_code,C_CHAR)            <> NVL(w.value_source_code,C_CHAR)            OR
            NVL(s.value_constant,C_CHAR)               <> NVL(w.value_constant,C_CHAR)               OR
            NVL(s.value_mapping_set_code,C_CHAR)       <> NVL(w.value_mapping_set_code,C_CHAR)       OR
            NVL(s.value_segment_rule_appl_id,C_NUM)    <> NVL(w.value_segment_rule_appl_id,C_NUM)    OR
            NVL(s.value_segment_rule_type_code,C_CHAR) <> NVL(w.value_segment_rule_type_code,C_CHAR) OR
            NVL(s.value_segment_rule_code,C_CHAR)      <> NVL(w.value_segment_rule_code,C_CHAR)      OR
            NVL(s.value_flexfield_segment_code,C_CHAR) <> NVL(w.value_flexfield_segment_code,C_CHAR) OR
            NVL(s.input_source_application_id,C_NUM)   <> NVL(w.input_source_application_id,C_NUM)   OR
            NVL(s.input_source_type_code,C_CHAR)       <> NVL(w.input_source_type_code,C_CHAR)       OR
            NVL(s.input_source_code,C_CHAR)            <> NVL(w.input_source_code,C_CHAR));

  l_key                 VARCHAR2(240);
  l_s_value             VARCHAR2(2000);
  l_w_value             VARCHAR2(2000);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_adr_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_adr_details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated adr details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated adr detail '||
                        '- segment_rule_type_code = '||l_comp.segment_rule_type_code||
                        ', segment_rule_code = '||l_comp.segment_rule_code||
                        ', user_sequence = '||l_comp.user_sequence||
                        ', merge_impact = '||l_comp.merge_impact,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      l_key := l_comp.segment_rule_appl_id||C_CHAR||
               l_comp.segment_rule_type_code||C_CHAR||
               l_comp.segment_rule_code||C_CHAR||
               l_comp.user_sequence;

      IF (l_comp.s_value_type_code <> l_comp.w_value_type_code) THEN
        record_updated_property
            (p_component_type          => 'AMB_ADR_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'VALUE_TYPE'
            ,p_old_value               => l_comp.w_value_type_code
            ,p_new_value               => l_comp.s_value_type_code
            ,p_lookup_type             => 'XLA_SEG_VALUE_TYPE');
      END IF;

      IF (NVL(l_comp.s_value_source_app_id,C_NUM)           <> NVL(l_comp.w_value_source_app_id,C_NUM)           OR
          NVL(l_comp.s_value_source_type_code,C_CHAR)       <> NVL(l_comp.w_value_source_type_code,C_CHAR)       OR
          NVL(l_comp.s_value_source_code,C_CHAR)            <> NVL(l_comp.w_value_source_code,C_CHAR)            OR
          NVL(l_comp.s_value_mapping_set_code,C_CHAR)       <> NVL(l_comp.w_value_mapping_set_code,C_CHAR)       OR
          NVL(l_comp.s_value_segment_rule_appl_id,C_NUM)    <> NVL(l_comp.w_value_segment_rule_appl_id,C_NUM)    OR
          NVL(l_comp.s_value_segment_rule_type_code,C_CHAR) <> NVL(l_comp.w_value_segment_rule_type_code,C_CHAR) OR
          NVL(l_comp.s_value_segment_rule_code,C_CHAR)      <> NVL(l_comp.w_value_segment_rule_code,C_CHAR)
         )
      THEN
        record_updated_value
            (p_component_type          => 'AMB_ADR_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'VALUE'
            ,p_old_value               => '#VALUE_TYPE_CODE#='||l_comp.w_value_type_code
            ,p_old_source_app_id       => NVL(l_comp.w_value_source_app_id,
                                              l_comp.w_value_segment_rule_appl_id)
            ,p_old_source_type_code    => NVL(l_comp.w_value_source_type_code,
                                              l_comp.w_value_segment_rule_type_code)
            ,p_old_source_code         => NVL(l_comp.w_value_mapping_set_code,
                                           NVL(l_comp.w_value_segment_rule_code,
                                               l_comp.w_value_source_code))
            ,p_new_value               => '#VALUE_TYPE_CODE#='||l_comp.s_value_type_code
            ,p_new_source_app_id       => NVL(l_comp.s_value_source_app_id,
                                              l_comp.s_value_segment_rule_appl_id)
            ,p_new_source_type_code    => NVL(l_comp.s_value_source_type_code,
                                              l_comp.s_value_segment_rule_type_code)
            ,p_new_source_code         => NVL(l_comp.s_value_mapping_set_code,
                                           NVL(l_comp.s_value_segment_rule_code,
                                               l_comp.s_value_source_code)));
      END IF;

      IF (NVL(l_comp.s_input_source_app_id,C_NUM)     <> NVL(l_comp.w_input_source_app_id,C_NUM)     OR
          NVL(l_comp.s_input_source_type_code,C_CHAR) <> NVL(l_comp.w_input_source_type_code,C_CHAR) OR
          NVL(l_comp.s_input_source_code,C_CHAR)      <> NVL(l_comp.w_input_source_code,C_CHAR)) THEN
        record_updated_source
            (p_component_type          => 'AMB_ADR_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'INPUT_SOURCE'
            ,p_old_source_app_id       => l_comp.w_input_source_app_id
            ,p_old_source_type_code    => l_comp.w_input_source_type_code
            ,p_old_source_code         => l_comp.w_input_source_code
            ,p_new_source_app_id       => l_comp.s_input_source_app_id
            ,p_new_source_type_code    => l_comp.s_input_source_type_code
            ,p_new_source_code         => l_comp.s_input_source_code);
      END IF;

      IF (NVL(l_comp.s_value_flexfield_segment_code,C_CHAR) <>
          NVL(l_comp.w_value_flexfield_segment_code,C_CHAR)) THEN
        record_updated_property
            (p_component_type          => 'AMB_ADR_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'FLEXFIELD_SEGMENT'
            ,p_old_value               => l_comp.w_value_flexfield_segment_code
            ,p_new_value               => l_comp.s_value_flexfield_segment_code);
      END IF;

      IF (NVL(l_comp.s_value_constant,C_CHAR) <> NVL(l_comp.w_value_constant,C_CHAR)) THEN
        record_updated_property
            (p_component_type          => 'AMB_ADR_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'VALUE'
            ,p_old_value               => l_comp.w_value_constant
            ,p_new_value               => l_comp.s_value_constant);
      END IF;

      IF (NVL(l_comp.s_value_ccid,C_NUM) <> NVL(l_comp.w_value_ccid,C_NUM)) THEN

        IF (l_comp.s_value_ccid IS NOT NULL) THEN
          l_s_value := fnd_flex_ext.get_segs('SQLGL', 'GL#', l_comp.s_accounting_coa_id, l_comp.s_value_ccid);
        END IF;

        IF (l_comp.w_value_ccid IS NOT NULL) THEN
          l_w_value := fnd_flex_ext.get_segs('SQLGL', 'GL#', l_comp.w_accounting_coa_id, l_comp.w_value_ccid);
        END IF;

        record_updated_property
            (p_component_type          => 'AMB_ADR_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'VALUE'
            ,p_old_value               => l_w_value
            ,p_new_value               => l_s_value);
      END IF;
    END IF;

    record_updated_adr_detail
            (p_segment_rule_appl_id   => l_comp.segment_rule_appl_id
            ,p_segment_rule_type_code => l_comp.segment_rule_type_code
            ,p_segment_rule_code      => l_comp.segment_rule_code
            ,p_user_sequence          => l_comp.user_sequence
            ,p_merge_impact           => l_comp.merge_impact);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated adr details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_adr_details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_adr_details;

--=============================================================================
--
-- Name: compare_descs
-- Description: Retrieve descriptions that are updated
--
--=============================================================================
PROCEDURE compare_descs
IS
  CURSOR c_comp IS
    SELECT ts.description_type_code
          ,ts.description_code
          ,ts.name                        s_name
          ,tw.name                        w_name
          ,ts.description                 s_description
          ,tw.description                 w_description
          ,bs.transaction_coa_id          s_transaction_coa_id
          ,bw.transaction_coa_id          w_transaction_coa_id
          ,bs.enabled_flag                s_enabled_flag
          ,bw.enabled_flag                w_enabled_flag
      FROM xla_descriptions_b bs
           JOIN xla_descriptions_tl ts
           ON  ts.application_id        = bs.application_id
           AND ts.amb_context_code      = bs.amb_context_code
           AND ts.description_type_code = bs.description_type_code
           AND ts.description_code      = bs.description_code
           AND ts.language              = USERENV('LANG')
           JOIN xla_descriptions_b bw
           ON  bw.application_id        = g_application_id
           AND bw.amb_context_code      = g_amb_context_code
           AND bw.description_type_code = bs.description_type_code
           AND bw.description_code      = bs.description_code
           JOIN xla_descriptions_tl tw
           ON  tw.application_id        = bw.application_id
           AND tw.amb_context_code      = bw.amb_context_code
           AND tw.description_type_code = bw.description_type_code
           AND tw.description_code      = bw.description_code
           AND tw.language              = USERENV('LANG')
     WHERE bs.application_id                 = g_application_id
       AND bs.amb_context_code               = g_staging_context_code
       AND (ts.name                          <> tw.name                          OR
            NVL(ts.description,C_CHAR)       <> NVL(tw.description,C_CHAR)       OR
            NVL(bs.transaction_coa_id,C_NUM) <> NVL(bw.transaction_coa_id,C_NUM) OR
            bs.enabled_flag                  <> bw.enabled_flag);

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_descs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_descs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated desc',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    l_key := l_comp.description_type_code||C_CHAR||
             l_comp.description_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated desc - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (l_comp.s_name <> l_comp.w_name) THEN
      record_updated_property
          (p_component_type          => 'AMB_DESCRIPTION'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
    END IF;

    IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_DESCRIPTION'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
    END IF;

    IF (NVL(l_comp.s_transaction_coa_id,C_NUM) <> NVL(l_comp.w_transaction_coa_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_DESCRIPTION'
          ,p_component_key           => l_key
          ,p_property                => 'TRANSACTION_COA'
          ,p_old_value               => l_comp.w_transaction_coa_id
          ,p_new_value               => l_comp.s_transaction_coa_id);
    END IF;

    IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_DESCRIPTION'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    record_updated_desc
          (p_description_type_code => l_comp.description_type_code
          ,p_description_code      => l_comp.description_code);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated desc',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_descs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_descs;

--=============================================================================
--
-- Name: compare_desc_priorities
-- Description: Retrieve the description priority that are new, deleted, or
--              updated
--
--=============================================================================
PROCEDURE compare_desc_priorities
IS
  CURSOR c_comp IS
    SELECT s.description_type_code
          ,s.description_code
          ,s.user_sequence
          ,CASE WHEN w.application_id IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                       merge_impact
          ,s.description_prio_id          s_description_prio_id
          ,w.description_prio_id          w_description_prio_id
          ,bs.transaction_coa_id          s_transaction_coa_id
          ,bw.transaction_coa_id          w_transaction_coa_id
      FROM xla_desc_priorities s
           JOIN xla_descriptions_b bs
           ON  bs.application_id        = s.application_id
           AND bs.amb_context_code      = s.amb_context_code
           AND bs.description_type_code = s.description_type_code
           AND bs.description_code      = s.description_code
           JOIN xla_descriptions_b bw
           ON  bw.application_id        = g_application_id
           AND bw.amb_context_code      = g_amb_context_code
           AND bw.description_type_code = s.description_type_code
           AND bw.description_code      = s.description_code
           LEFT OUTER JOIN xla_desc_priorities w
           ON  w.application_id         = g_application_id
           AND w.amb_context_code       = g_amb_context_code
           AND w.description_type_code  = s.description_type_code
           AND w.description_code       = s.description_code
           AND w.user_sequence          = s.user_sequence
     WHERE s.amb_context_code           = g_staging_context_code
     UNION
    SELECT w.description_type_code
          ,w.description_code
          ,w.user_sequence
          ,C_MERGE_IMPACT_DELETED
          , null , null , null , null
      FROM xla_desc_priorities w
           JOIN xla_descriptions_b bs
           ON  bs.application_id        = g_application_id
           AND bs.amb_context_code      = g_staging_context_code
           AND bs.description_type_code = w.description_type_code
           AND bs.description_code      = w.description_code
     WHERE w.amb_context_code           = g_amb_context_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_desc_priorities s
             WHERE s.application_id         = g_application_id
               AND s.amb_context_code       = g_staging_context_code
               AND s.description_type_code  = w.description_type_code
               AND s.description_code       = w.description_code
               AND s.user_sequence          = w.user_sequence);

  l_staging_detail      VARCHAR2(2000);
  l_working_detail      VARCHAR2(2000);
  l_staging_condition   VARCHAR2(2000);
  l_working_condition   VARCHAR2(2000);
  l_updated             BOOLEAN;
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_desc_priorities';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_desc_priorities',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_updated := FALSE;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated desc priorities',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN
      l_key := l_comp.description_type_code||C_CHAR||
               l_comp.description_code||C_CHAR||
               l_comp.user_sequence;

      l_working_detail := xla_descript_details_pkg.display_desc_prio_details
                (p_description_prio_id       => l_comp.w_description_prio_id
                ,p_chart_of_accounts_id      => l_comp.w_transaction_coa_id);

      l_staging_detail := xla_descript_details_pkg.display_desc_prio_details
                (p_description_prio_id       => l_comp.s_description_prio_id
                ,p_chart_of_accounts_id      => l_comp.s_transaction_coa_id);

      IF (l_working_detail <> l_staging_detail) THEN
        l_updated := TRUE;
        record_updated_property
            (p_component_type          => 'AMB_DESC_PRIO'
            ,p_component_key           => l_key
            ,p_property                => 'DETAIL'
            ,p_old_value               => l_working_detail
            ,p_new_value               => l_staging_detail);
      END IF;

      l_working_condition := xla_conditions_pkg.display_condition
                (p_description_prio_id       => l_comp.w_description_prio_id
                ,p_chart_of_accounts_id      => l_comp.w_transaction_coa_id
                ,p_context                   => 'D');

      l_staging_condition := xla_conditions_pkg.display_condition
                (p_description_prio_id       => l_comp.s_description_prio_id
                ,p_chart_of_accounts_id      => l_comp.s_transaction_coa_id
                ,p_context                   => 'D');

      IF (l_working_condition <> l_staging_condition) THEN
        l_updated := TRUE;
        record_updated_property
            (p_component_type          => 'AMB_DESC_PRIO'
            ,p_component_key           => l_key
            ,p_property                => 'CONDITION'
            ,p_old_value               => l_working_condition
            ,p_new_value               => l_staging_condition);
      END IF;

      IF (l_updated) THEN
        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace(p_msg    => 'LOOP: updated desc prio '||
                            '- description_type_code = '||l_comp.description_type_code||
                            ', description_code = '||l_comp.description_code||
                            ', user_sequence = '||l_comp.user_sequence||
                            ', merge_impact = '||C_MERGE_IMPACT_UPDATED,
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
        END IF;

        l_updated := FALSE;
        record_updated_desc_priority
            (p_description_type_code   => l_comp.description_type_code
            ,p_description_code        => l_comp.description_code
            ,p_user_sequence           => l_comp.user_sequence
            ,p_merge_impact            => C_MERGE_IMPACT_UPDATED);
      END IF;
    ELSE

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'LOOP: updated desc prio '||
                          '- description_type_code = '||l_comp.description_type_code||
                          ', description_code = '||l_comp.description_code||
                          ', user_sequence = '||l_comp.user_sequence||
                          ', merge_impact = '||l_comp.merge_impact,
              p_module => l_log_module,
              p_level  => C_LEVEL_PROCEDURE);
      END IF;

      record_updated_desc_priority
            (p_description_type_code   => l_comp.description_type_code
            ,p_description_code        => l_comp.description_code
            ,p_user_sequence           => l_comp.user_sequence
            ,p_merge_impact            => l_comp.merge_impact);
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated desc priorities',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_desc_priorities',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_desc_priorities;


--=============================================================================
--
-- Name: compare_acs
-- Description:
--
--=============================================================================
PROCEDURE compare_acs
IS
  CURSOR c_comp IS
    SELECT ts.analytical_criterion_type_code
          ,ts.analytical_criterion_code
          ,ts.name                        s_name
          ,tw.name                        w_name
          ,ts.description                 s_description
          ,tw.description                 w_description
          ,bs.balancing_flag              s_balancing_flag
          ,bw.balancing_flag              w_balancing_flag
          ,bs.display_order               s_display_order
          ,bw.display_order               w_display_order
          ,bs.enabled_flag                s_enabled_flag
          ,bw.enabled_flag                w_enabled_flag
          ,bs.year_end_carry_forward_code s_year_end_carry_forward_code
          ,bw.year_end_carry_forward_code w_year_end_carry_forward_code
          ,bs.display_in_inquiries_flag   s_display_in_inquiries_flag
          ,bw.display_in_inquiries_flag   w_display_in_inquiries_flag
          ,bs.criterion_value_code        s_criterion_value_code
          ,bw.criterion_value_code        w_criterion_value_code
      FROM xla_analytical_hdrs_b bs
           JOIN xla_analytical_hdrs_tl ts
           ON  ts.amb_context_code               = bs.amb_context_code
           AND ts.analytical_criterion_type_code = bs.analytical_criterion_type_code
           AND ts.analytical_criterion_code      = bs.analytical_criterion_code
           AND ts.language                       = USERENV('LANG')
           JOIN xla_analytical_hdrs_b bw
           ON  bw.amb_context_code               = g_amb_context_code
           AND bw.analytical_criterion_type_code = bs.analytical_criterion_type_code
           AND bw.analytical_criterion_code      = bs.analytical_criterion_code
           JOIN xla_analytical_hdrs_tl tw
           ON  tw.amb_context_code               = bw.amb_context_code
           AND tw.analytical_criterion_type_code = bw.analytical_criterion_type_code
           AND tw.analytical_criterion_code      = bw.analytical_criterion_code
           AND tw.language                       = USERENV('LANG')
     WHERE bs.amb_context_code = g_staging_context_code
       AND (ts.name                        <> tw.name                        OR
            NVL(ts.description,C_CHAR)     <> NVL(tw.description,C_CHAR)     OR
            bs.balancing_flag              <> bw.balancing_flag              OR
            bs.display_order               <> bw.display_order               OR
            bs.enabled_flag                <> bw.enabled_flag                OR
            NVL(bs.year_end_carry_forward_code,C_CHAR) <>
                                              NVL(bw.year_end_carry_forward_code,C_CHAR) OR
            bs.display_in_inquiries_flag   <> bw.display_in_inquiries_flag     OR
            bs.criterion_value_code        <> bw.criterion_value_code);

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_acs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    l_key := l_comp.analytical_criterion_type_code||C_CHAR||
             l_comp.analytical_criterion_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated ac - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (l_comp.s_name <> l_comp.w_name) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
    END IF;

    IF (l_comp.s_description <> l_comp.w_description) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
    END IF;

    IF (l_comp.s_balancing_flag <> l_comp.w_balancing_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'MAINTAIN_BALANCE'
          ,p_old_value               => l_comp.w_balancing_flag
          ,p_new_value               => l_comp.s_balancing_flag);
    END IF;

    IF (l_comp.s_display_order <> l_comp.w_display_order) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'DISPLAY_ORDER'
          ,p_old_value               => l_comp.w_display_order
          ,p_new_value               => l_comp.s_display_order);
    END IF;

    IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    IF (NVL(l_comp.s_year_end_carry_forward_code,C_CHAR) <>
        NVL(l_comp.w_year_end_carry_forward_code,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'YEAR_END_CARRY_FORWARD'
          ,p_old_value               => l_comp.w_year_end_carry_forward_code
          ,p_new_value               => l_comp.s_year_end_carry_forward_code
          ,p_lookup_type             => 'XLA_YEAR_END_CARRY_FORWARD');
    END IF;

    IF (l_comp.s_display_in_inquiries_flag <> l_comp.w_display_in_inquiries_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'DISPLAY_IN_INQUIRIES_FLAG'
          ,p_old_value               => l_comp.w_display_in_inquiries_flag
          ,p_new_value               => l_comp.s_display_in_inquiries_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    IF (l_comp.s_criterion_value_code <> l_comp.w_criterion_value_code) THEN
      record_updated_property
          (p_component_type          => 'AMB_AC'
          ,p_component_key           => l_key
          ,p_property                => 'CRITERION_VALUE_CODE'
          ,p_old_value               => l_comp.w_criterion_value_code
          ,p_new_value               => l_comp.s_criterion_value_code);
    END IF;

    record_updated_ac(p_ac_type_code => l_comp.analytical_criterion_type_code
                     ,p_ac_code      => l_comp.analytical_criterion_code
                     ,p_merge_impact => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_acs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_acs;


--=============================================================================
--
-- Name: compare_ac_details
-- Description:
--
--=============================================================================
PROCEDURE compare_ac_details
IS
  CURSOR c_comp IS
    SELECT ts.analytical_criterion_type_code
          ,ts.analytical_criterion_code
          ,ts.analytical_detail_code
          ,CASE WHEN bw.analytical_detail_code IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                       merge_impact
          ,ts.name                        s_name
          ,tw.name                        w_name
          ,ts.description                 s_description
          ,tw.description                 w_description
          ,bs.grouping_order              s_grouping_order
          ,bw.grouping_order              w_grouping_order
          ,bs.data_type_code              s_data_type_code
          ,bw.data_type_code              w_data_type_code
      FROM xla_analytical_dtls_b bs
           JOIN xla_analytical_hdrs_b hw
           ON  hw.amb_context_code               = g_amb_context_code
           AND hw.analytical_criterion_type_code = bs.analytical_criterion_type_code
           AND hw.analytical_criterion_code      = bs.analytical_criterion_code
           JOIN xla_analytical_dtls_tl ts
           ON  ts.amb_context_code               = bs.amb_context_code
           AND ts.analytical_criterion_type_code = bs.analytical_criterion_type_code
           AND ts.analytical_criterion_code      = bs.analytical_criterion_code
           AND ts.analytical_detail_code         = bs.analytical_detail_code
           AND ts.language                       = USERENV('LANG')
           LEFT OUTER JOIN xla_analytical_dtls_b bw
           ON  bw.amb_context_code               = g_amb_context_code
           AND bw.analytical_criterion_type_code = bs.analytical_criterion_type_code
           AND bw.analytical_criterion_code      = bs.analytical_criterion_code
           AND bw.analytical_detail_code         = bs.analytical_detail_code
           LEFT OUTER JOIN xla_analytical_dtls_tl tw
           ON  tw.amb_context_code               = bw.amb_context_code
           AND tw.analytical_criterion_type_code = bw.analytical_criterion_type_code
           AND tw.analytical_criterion_code      = bw.analytical_criterion_code
           AND tw.analytical_detail_code         = bw.analytical_detail_code
           AND tw.language                       = USERENV('LANG')
     WHERE bs.amb_context_code     = g_staging_context_code
       AND (bw.analytical_detail_code IS NULL                                OR
            NVL(ts.name,C_CHAR)            <> NVL(tw.name,C_CHAR)            OR
            NVL(ts.description,C_CHAR)     <> NVL(tw.description,C_CHAR)     OR
            NVL(bs.grouping_order,C_NUM)   <> NVL(bw.grouping_order,C_NUM)   OR
            NVL(bs.data_type_code,C_CHAR)  <> NVL(bw.data_type_code,C_CHAR));

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_ac_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_ac_details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated ac details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated ac detail - '||
                        l_comp.analytical_criterion_type_code||C_CHAR||
                        l_comp.analytical_criterion_code||C_CHAR||
                        l_comp.analytical_detail_code||C_CHAR||
                        l_comp.merge_impact,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      l_key := l_comp.analytical_criterion_type_code||C_CHAR||
               l_comp.analytical_criterion_code||C_CHAR||
               l_comp.analytical_detail_code;

      IF (l_comp.s_name <> l_comp.w_name) THEN
        record_updated_property
            (p_component_type          => 'AMB_AC_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'NAME'
            ,p_old_value               => l_comp.w_name
            ,p_new_value               => l_comp.s_name);
      END IF;

      IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
        record_updated_property
            (p_component_type          => 'AMB_AC_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'DESCRIPTION'
            ,p_old_value               => l_comp.w_description
            ,p_new_value               => l_comp.s_description);
      END IF;

      IF (l_comp.s_grouping_order <> l_comp.w_grouping_order) THEN
        record_updated_property
            (p_component_type          => 'AMB_AC_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'GROUPING_ORDER'
            ,p_old_value               => l_comp.w_grouping_order
            ,p_new_value               => l_comp.s_grouping_order);
      END IF;

      IF (NVL(l_comp.s_data_type_code,C_CHAR) <> NVL(l_comp.w_data_type_code,C_CHAR)) THEN
        record_updated_property
            (p_component_type          => 'AMB_AC_DETAIL'
            ,p_component_key           => l_key
            ,p_property                => 'DATA_TYPE'
            ,p_old_value               => l_comp.w_data_type_code
            ,p_new_value               => l_comp.s_data_type_code
            ,p_lookup_type             => 'XLA_DATA_TYPE');
      END IF;

    END IF;

    record_updated_ac_detail
          (p_ac_type_code   => l_comp.analytical_criterion_type_code
          ,p_ac_code        => l_comp.analytical_criterion_code
          ,p_ac_detail_code => l_comp.analytical_detail_code
          ,p_merge_impact   => l_comp.merge_impact);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated ac details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_ac_details',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_ac_details;

--=============================================================================
--
-- Name: compare_ac_sources
-- Description:
--
--=============================================================================
PROCEDURE compare_ac_sources
IS
  CURSOR c_comp IS
    SELECT s.analytical_criterion_type_code
         , s.analytical_criterion_code
         , s.analytical_detail_code
         , s.entity_code
         , s.event_class_code
         , s.application_id
         , s.source_type_code        s_source_type_code
         , s.source_code             s_source_code
         , s.source_application_id   s_source_application_id
         , w.source_type_code        w_source_type_code
         , w.source_code             w_source_code
         , w.source_application_id   w_source_application_id
      FROM xla_analytical_sources s
           JOIN xla_analytical_dtls_b b
           ON  b.amb_context_code                = g_amb_context_code
           AND b.analytical_criterion_type_code  = s.analytical_criterion_type_code
           AND b.analytical_criterion_code       = s.analytical_criterion_code
           AND b.analytical_detail_code          = s.analytical_detail_code
           LEFT OUTER JOIN xla_analytical_sources w
           ON  w.amb_context_code               = g_amb_context_code
           AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
           AND w.analytical_criterion_code      = s.analytical_criterion_code
           AND w.analytical_detail_code         = s.analytical_detail_code
           AND w.entity_code                    = s.entity_code
           AND w.event_class_code               = s.event_class_code
           AND w.application_id                 = s.application_id
     WHERE s.amb_context_code                   = g_staging_context_code
       AND (w.source_application_id IS NULL OR
            NVL(w.source_type_code,C_CHAR)      <> NVL(s.source_type_code,C_CHAR) OR
            NVL(w.source_code,C_CHAR)           <> NVL(s.source_code,C_CHAR) OR
            NVL(w.source_application_id,C_NUM)  <> NVL(s.source_application_id,C_NUM))
     UNION
    SELECT w.analytical_criterion_type_code
         , w.analytical_criterion_code
         , w.analytical_detail_code
         , w.entity_code
         , w.event_class_code
         , w.application_id
         , NULL
         , NULL
         , NULL
         , w.source_type_code
         , w.source_code
         , w.source_application_id
      FROM xla_analytical_sources w
         , xla_analytical_dtls_b b
     WHERE w.amb_context_code                = g_amb_context_code
       AND b.amb_context_code                = g_staging_context_code
       AND b.analytical_criterion_type_code  = w.analytical_criterion_type_code
       AND b.analytical_criterion_code       = w.analytical_criterion_code
       AND b.analytical_detail_code          = w.analytical_detail_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_analytical_sources s
             WHERE s.amb_context_code               = g_staging_context_code
               AND s.analytical_criterion_type_code = w.analytical_criterion_type_code
               AND s.analytical_criterion_code      = w.analytical_criterion_code
               AND s.analytical_detail_code         = w.analytical_detail_code
               AND s.entity_code                    = w.entity_code
               AND s.event_class_code               = w.event_class_code
               AND s.application_id                 = w.application_id);

  l_key                 VARCHAR2(4000);
  l_parent_key          VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_ac_sources';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_ac_sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated ac sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP 1: updated ac sources - '||l_comp.analytical_criterion_type_code,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    l_key := l_comp.analytical_criterion_type_code||C_CHAR||
             l_comp.analytical_criterion_code||C_CHAR||
             l_comp.analytical_detail_code||C_CHAR||
             l_comp.entity_code||C_CHAR||
             l_comp.event_class_code||C_CHAR||
             l_comp.application_id;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated ac sources - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_source(p_component_type       => 'AMB_AC_SOURCE'
                         ,p_component_key        => l_key
                         ,p_property             => 'SOURCE_CODE'
                         ,p_old_source_app_id    => l_comp.w_source_application_id
                         ,p_old_source_type_code => l_comp.w_source_type_code
                         ,p_old_source_code      => l_comp.w_source_code
                         ,p_new_source_app_id    => l_comp.s_source_application_id
                         ,p_new_source_type_code => l_comp.s_source_type_code
                         ,p_new_source_code      => l_comp.s_source_code);

    record_updated_component
            (p_parent_component_type => 'AMB_AC_DETAIL'
            ,p_parent_component_key  => l_comp.analytical_criterion_type_code||C_CHAR||
                                        l_comp.analytical_criterion_code||C_CHAR||
                                        l_comp.analytical_detail_code
            ,p_component_type        => 'AMB_AC_SOURCE'
            ,p_component_key         => l_key
            ,p_merge_impact          => C_MERGE_IMPACT_UPDATED
            ,p_event_class_code      => l_comp.event_class_code
            ,p_event_type_code       => NULL
            ,p_component_owner_code  => NULL
            ,p_component_code        => l_comp.event_class_code);

    record_updated_ac_detail
          (p_ac_type_code   => l_comp.analytical_criterion_type_code
          ,p_ac_code        => l_comp.analytical_criterion_code
          ,p_ac_detail_code => l_comp.analytical_detail_code
          ,p_merge_impact   => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated ac sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_ac_sources',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_ac_sources;

--=============================================================================
--
-- Name: compare_jlt_acct_attrs
-- Description:
--
--=============================================================================
PROCEDURE compare_jlt_acct_attrs
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.accounting_attribute_code
         , CASE WHEN w.application_id IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                    merge_impact
         , s.source_application_id     s_source_application_id
         , w.source_application_id     w_source_application_id
         , s.source_type_code          s_source_type_code
         , w.source_type_code          w_source_type_code
         , s.source_code               s_source_code
         , w.source_code               w_source_code
         , s.event_class_default_flag  s_event_class_default_flag
         , w.event_class_default_flag  w_event_class_default_flag
      FROM xla_jlt_acct_attrs s
           JOIN xla_acct_line_types_b b
           ON  b.application_id            = g_application_id
           AND b.amb_context_code          = g_amb_context_code
           AND b.event_class_code          = s.event_class_code
           AND b.accounting_line_type_code = s.accounting_line_type_code
           AND b.accounting_line_code      = s.accounting_line_code
           LEFT OUTER JOIN xla_jlt_acct_attrs w
           ON  w.application_id            = g_application_id
           AND w.amb_context_code          = g_amb_context_code
           AND w.event_class_code          = s.event_class_code
           AND w.accounting_line_type_code = s.accounting_line_type_code
           AND w.accounting_line_code      = s.accounting_line_code
           AND w.accounting_attribute_code = s.accounting_attribute_code
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND (w.application_id                       IS NULL OR
            NVL(s.event_class_default_flag,C_CHAR) <> NVL(w.event_class_default_flag,C_CHAR) OR
            NVL(s.source_application_id,C_NUM)     <> NVL(w.source_application_id,C_NUM) OR
            NVL(s.source_type_code,C_CHAR)         <> NVL(w.source_type_code,C_CHAR) OR
            NVL(s.source_code,C_CHAR)              <> NVL(w.source_code,C_CHAR));

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_jlt_acct_attrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_jlt_acct_attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated jlt acct attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_key := l_comp.event_class_code||C_CHAR||
             l_comp.accounting_line_type_code||C_CHAR||
             l_comp.accounting_line_code||C_CHAR||
             l_comp.accounting_attribute_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated jlt acct attr - '||l_comp.merge_impact,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_jlt_acct_attr
          (p_event_class_code          => l_comp.event_class_code
          ,p_accounting_line_type_code => l_comp.accounting_line_type_code
          ,p_accounting_line_code      => l_comp.accounting_line_code
          ,p_accounting_attribute_code => l_comp.accounting_attribute_code
          ,p_merge_impact              => l_comp.merge_impact);

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      IF (l_comp.s_event_class_default_flag <> l_comp.w_event_class_default_flag) THEN
        record_updated_property
          (p_component_type          => 'AMB_JLT_ACCT_ATTR'
          ,p_component_key           => l_key
          ,p_property                => 'EVENT_CLASS_DEFAULT_FLAG'
          ,p_old_value               => l_comp.w_event_class_default_flag
          ,p_new_value               => l_comp.s_event_class_default_flag
          ,p_lookup_type             => 'XLA_YES_NO');
      END IF;

      IF (NVL(l_comp.w_source_application_id,C_NUM) <> NVL(l_comp.s_source_application_id,C_NUM) OR
          NVL(l_comp.w_source_type_code,C_CHAR) <> NVL(l_comp.s_source_type_code,C_CHAR) OR
          NVL(l_comp.w_source_code,C_CHAR)      <> NVL(l_comp.s_source_code,C_CHAR)) THEN
        record_updated_source(p_component_type       => 'AMB_JLT_ACCT_ATTR'
                           ,p_component_key        => l_key
                           ,p_property             => 'SOURCE_CODE'
                           ,p_old_source_app_id    => l_comp.w_source_application_id
                           ,p_old_source_type_code => l_comp.w_source_type_code
                           ,p_old_source_code      => l_comp.w_source_code
                           ,p_new_source_app_id    => l_comp.s_source_application_id
                           ,p_new_source_type_code => l_comp.s_source_type_code
                           ,p_new_source_code      => l_comp.s_source_code);
      END IF;
    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated jlt acct attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_jlt_acct_attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_jlt_acct_attrs;

--=============================================================================
--
-- Name: compare_jlts
-- Description:
--
--=============================================================================
PROCEDURE compare_jlts
IS
  CURSOR c_comp IS
    SELECT ts.entity_code
          ,ts.event_class_code
          ,ts.accounting_line_type_code acct_line_type_code
          ,ts.accounting_line_code      acct_line_code
          ,ts.name                      s_name
          ,tw.name                      w_name
          ,ts.description               s_description
          ,tw.description               w_description
          ,s.accounting_class_code      s_acct_class_code
          ,w.accounting_class_code      w_acct_class_code
          ,s.enabled_flag               s_enabled_flag
          ,w.enabled_flag               w_enabled_flag
          ,s.accounting_entry_type_code s_ae_type_code
          ,w.accounting_entry_type_code w_ae_type_code
          ,s.natural_side_code          s_natural_side_code
          ,w.natural_side_code          w_natural_side_code
          ,s.switch_side_flag           s_switch_side_flag
          ,w.switch_side_flag           w_switch_side_flag
          ,s.merge_duplicate_code       s_merge_duplicate_code
          ,w.merge_duplicate_code       w_merge_duplicate_code
          ,s.transaction_coa_id         s_trx_coa_id
          ,w.transaction_coa_id         w_trx_coa_id
          ,s.gl_transfer_mode_code      s_gl_transfer_mode_code
          ,w.gl_transfer_mode_code      w_gl_transfer_mode_code
          ,s.business_method_code       s_business_method_code
          ,w.business_method_code       w_business_method_code
          ,s.business_class_code        s_business_class_code
          ,w.business_class_code        w_business_class_code
          ,s.rounding_class_code        s_rounding_class_code
          ,w.rounding_class_code        w_rounding_class_code
          ,s.encumbrance_type_id        s_encumbrance_type_id
          ,w.encumbrance_type_id        w_encumbrance_type_id
          ,s.mpa_option_code            s_mpa_option_code
          ,w.mpa_option_code            w_mpa_option_code
      FROM xla_acct_line_types_b s
           JOIN xla_acct_line_types_tl ts
           ON  ts.application_id            = s.application_id
           AND ts.amb_context_code          = s.amb_context_code
           AND ts.entity_code               = s.entity_code
           AND ts.event_class_code          = s.event_class_code
           AND ts.accounting_line_type_code = s.accounting_line_type_code
           AND ts.accounting_line_code      = s.accounting_line_code
           AND ts.accounting_line_code      = s.accounting_line_code
           AND ts.language                  = USERENV('LANG')
           JOIN xla_acct_line_types_b w
           ON  w.application_id            = s.application_id
           AND w.entity_code               = s.entity_code
           AND w.event_class_code          = s.event_class_code
           AND w.accounting_line_type_code = s.accounting_line_type_code
           AND w.accounting_line_code      = s.accounting_line_code
           JOIN xla_acct_line_types_tl tw
           ON  tw.application_id            = w.application_id
           AND tw.amb_context_code          = w.amb_context_code
           AND tw.entity_code               = w.entity_code
           AND tw.event_class_code          = w.event_class_code
           AND tw.accounting_line_type_code = w.accounting_line_type_code
           AND tw.accounting_line_code      = w.accounting_line_code
           AND tw.language                  = USERENV('LANG')
     WHERE s.amb_context_code = g_staging_context_code
       AND w.amb_context_code = g_amb_context_code;

  l_key                     VARCHAR2(240);
  l_staging_condition       VARCHAR2(2000);
  l_working_condition       VARCHAR2(2000);
  l_updated                 BOOLEAN;

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_jlts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated jlt',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_updated    := FALSE;
  FOR l_comp in c_comp LOOP

    l_key := l_comp.event_class_code||C_CHAR||
             l_comp.acct_line_type_code||C_CHAR||
             l_comp.acct_line_code;

    IF (l_comp.s_name <> l_comp.w_name) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
    END IF;

    IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
    END IF;

    IF (l_comp.s_acct_class_code <> l_comp.w_acct_class_code) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_CLASS'
          ,p_old_value               => l_comp.w_acct_class_code
          ,p_new_value               => l_comp.s_acct_class_code
          ,p_lookup_type             => 'XLA_ACCOUNTING_CLASS');
    END IF;

    IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    IF (l_comp.s_ae_type_code <> l_comp.w_ae_type_code) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_ENTRY_TYPE'
          ,p_old_value               => l_comp.w_ae_type_code
          ,p_new_value               => l_comp.s_ae_type_code
          ,p_lookup_type             => 'XLA_BALANCE_TYPE');
    END IF;

    IF (l_comp.s_natural_side_code <> l_comp.w_natural_side_code) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'NATURAL_SIDE'
          ,p_old_value               => l_comp.w_natural_side_code
          ,p_new_value               => l_comp.s_natural_side_code
          ,p_lookup_type             => 'XLA_ACCT_NATURAL_SIDE');
    END IF;

    IF (NVL(l_comp.s_switch_side_flag,C_CHAR) <> NVL(l_comp.w_switch_side_flag,C_CHAR)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'SWITCH_SIDE'
          ,p_old_value               => l_comp.w_switch_side_flag
          ,p_new_value               => l_comp.s_switch_side_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    IF (l_comp.s_merge_duplicate_code <> l_comp.w_merge_duplicate_code) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'MERGE_DUPLICATE'
          ,p_old_value               => l_comp.w_merge_duplicate_code
          ,p_new_value               => l_comp.s_merge_duplicate_code
          ,p_lookup_type             => 'XLA_MERGE_MATCHING_TYPE');
    END IF;

    IF (NVL(l_comp.s_trx_coa_id,C_NUM) <> NVL(l_comp.w_trx_coa_id,C_NUM)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'TRANSACTION_COA'
          ,p_old_value               => l_comp.w_trx_coa_id
          ,p_new_value               => l_comp.s_trx_coa_id);
    END IF;

    IF (l_comp.s_gl_transfer_mode_code <> l_comp.w_gl_transfer_mode_code) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'GL_TRANSFER_MODE'
          ,p_old_value               => l_comp.w_gl_transfer_mode_code
          ,p_new_value               => l_comp.s_gl_transfer_mode_code
          ,p_lookup_type             => 'XLA_ACCT_TRANSFER_MODE');
    END IF;

    IF (l_comp.s_business_method_code <> l_comp.w_business_method_code) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'BUSINESS_METHOD'
          ,p_old_value               => l_comp.w_business_method_code
          ,p_new_value               => l_comp.s_business_method_code
          ,p_lookup_type             => 'XLA_ACCT_TRANSFER_MODE');
    END IF;

    IF (NVL(l_comp.s_business_class_code,C_CHAR) <> NVL(l_comp.w_business_class_code,C_CHAR)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'BUSINESS_CLASS'
          ,p_old_value               => l_comp.w_business_class_code
          ,p_new_value               => l_comp.s_business_class_code
          ,p_lookup_type             => 'XLA_ACCT_TRANSFER_MODE');
    END IF;

    IF (NVL(l_comp.s_encumbrance_type_id,C_NUM) <> NVL(l_comp.w_encumbrance_type_id,C_NUM)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'ENCUMBRANCE_TYPE'
          ,p_old_value               => l_comp.w_encumbrance_type_id
          ,p_new_value               => l_comp.s_encumbrance_type_id);
    END IF;

    IF (NVL(l_comp.s_mpa_option_code,C_CHAR) <> NVL(l_comp.w_mpa_option_code,C_CHAR)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'MPA_OPTION_CODE'
          ,p_old_value               => l_comp.w_mpa_option_code
          ,p_new_value               => l_comp.s_mpa_option_code
          ,p_lookup_type             => 'XLA_MPA_OPTION');
    END IF;

    IF (NVL(l_comp.s_rounding_class_code,C_CHAR) <> NVL(l_comp.w_rounding_class_code,C_CHAR)) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'ROUNDING_CLASS'
          ,p_old_value               => l_comp.w_rounding_class_code
          ,p_new_value               => l_comp.s_rounding_class_code
          ,p_lookup_type             => 'XLA_ACCOUNTING_CLASS');
    END IF;

    l_working_condition := xla_conditions_pkg.display_condition
              (p_application_id            => g_application_id
              ,p_amb_context_code          => g_amb_context_code
              ,p_entity_code               => l_comp.entity_code
              ,p_event_class_code          => l_comp.event_class_code
              ,p_accounting_line_type_code => l_comp.acct_line_type_code
              ,p_accounting_line_code      => l_comp.acct_line_code
              ,p_chart_of_accounts_id      => l_comp.w_trx_coa_id
              ,p_context                   => 'A');

    l_staging_condition := xla_conditions_pkg.display_condition
              (p_application_id            => g_application_id
              ,p_amb_context_code          => g_staging_context_code
              ,p_entity_code               => l_comp.entity_code
              ,p_event_class_code          => l_comp.event_class_code
              ,p_accounting_line_type_code => l_comp.acct_line_type_code
              ,p_accounting_line_code      => l_comp.acct_line_code
              ,p_chart_of_accounts_id      => l_comp.s_trx_coa_id
              ,p_context                   => 'A');

    IF (l_working_condition <> l_staging_condition) THEN
      l_updated := TRUE;
      record_updated_property
          (p_component_type          => 'AMB_JLT'
          ,p_component_key           => l_key
          ,p_property                => 'CONDITION'
          ,p_old_value               => l_working_condition
          ,p_new_value               => l_staging_condition);
    END IF;

    IF (l_updated) THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'LOOP: updated ac sources - '||l_key,
              p_module => l_log_module,
              p_level  => C_LEVEL_PROCEDURE);
      END IF;

      record_updated_jlt(p_event_class_code          => l_comp.event_class_code
                        ,p_accounting_line_type_code => l_comp.acct_line_type_code
                        ,p_accounting_line_code      => l_comp.acct_line_code);

      l_updated := FALSE;
    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated jlt',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_jlts',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_jlts;

--=============================================================================
--
-- Name: compare_line_adr_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_line_adr_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.flexfield_segment_code
         , s.side_code
         , l.accounting_coa_id
         , CASE WHEN w.application_id IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                merge_impact
         , s.segment_rule_appl_id   s_segment_rule_appl_id
         , w.segment_rule_appl_id   w_segment_rule_appl_id
         , s.segment_rule_type_code s_segment_rule_type_code
         , w.segment_rule_type_code w_segment_rule_type_code
         , s.segment_rule_code      s_segment_rule_code
         , w.segment_rule_code      w_segment_rule_code
         , s.inherit_adr_flag       s_inherit_adr_flag
         , w.inherit_adr_flag       w_inherit_adr_flag
      FROM xla_line_defn_adr_assgns s
           JOIN xla_line_definitions_b l
           ON  l.application_id              = g_application_id
           AND l.amb_context_code            = g_amb_context_code
           AND l.event_class_code            = s.event_class_code
           AND l.event_type_code             = s.event_type_code
           AND l.line_definition_owner_code  = s.line_definition_owner_code
           AND l.line_definition_code        = s.line_definition_code
           JOIN xla_line_defn_jlt_assgns b
           ON  b.application_id              = g_application_id
           AND b.amb_context_code            = g_amb_context_code
           AND b.event_class_code            = s.event_class_code
           AND b.event_type_code             = s.event_type_code
           AND b.line_definition_owner_code  = s.line_definition_owner_code
           AND b.line_definition_code        = s.line_definition_code
           AND b.accounting_line_type_code   = s.accounting_line_type_code
           AND b.accounting_line_code        = s.accounting_line_code
           LEFT OUTER JOIN xla_line_defn_adr_assgns w
           ON  w.application_id                 = g_application_id
           AND w.amb_context_code               = g_amb_context_code
           AND w.event_class_code               = s.event_class_code
           AND w.event_type_code                = s.event_type_code
           AND w.line_definition_owner_code     = s.line_definition_owner_code
           AND w.line_definition_code           = s.line_definition_code
           AND w.accounting_line_type_code      = s.accounting_line_type_code
           AND w.accounting_line_code           = s.accounting_line_code
           AND w.flexfield_segment_code         = s.flexfield_segment_code
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND (w.application_id                     IS NULL                                 OR
            s.inherit_adr_flag                   <> w.inherit_adr_flag                   OR
            NVL(s.segment_rule_appl_id,C_NUM)    <> NVL(w.segment_rule_appl_id,C_NUM)    OR
            NVL(s.segment_rule_type_code,C_CHAR) <> NVL(w.segment_rule_type_code,C_CHAR) OR
            NVL(s.segment_rule_code,C_CHAR)      <> NVL(w.segment_rule_code,C_CHAR));

  l_key                 VARCHAR2(240);
  l_parent_key          VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_line_adr_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_line_adr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated line adr assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code;

    l_key := l_parent_key||C_CHAR||
             l_comp.flexfield_segment_code||C_CHAR||
             l_comp.side_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated line adr assgn - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (NOT key_exists('LNADR'||C_CHAR||l_key)) THEN
      record_updated_component
          (p_parent_component_type => 'AMB_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_ADR_ASSGN'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_component_owner_code  => l_comp.accounting_coa_id
          ,p_component_code        => l_comp.flexfield_segment_code);

      record_updated_line_assgn
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code
          ,p_accounting_line_type_code  => l_comp.accounting_line_type_code
          ,p_accounting_line_code       => l_comp.accounting_line_code
          ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

    END IF;

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      IF (l_comp.w_inherit_adr_flag <> l_comp.s_inherit_adr_flag) THEN
        record_updated_property
              (p_component_type => 'AMB_ADR_ASSGN'
              ,p_component_key  => l_key
              ,p_property       => 'INHERIT_ADR_FLAG'
              ,p_old_value      => l_comp.w_inherit_adr_flag
              ,p_new_value      => l_comp.s_inherit_adr_flag
              ,p_lookup_type    => 'XLA_YES_NO');

      END IF;

      IF (NVL(l_comp.w_segment_rule_appl_id,C_NUM)    <> NVL(l_comp.s_segment_rule_appl_id,C_NUM) OR
          NVL(l_comp.w_segment_rule_type_code,C_CHAR) <> NVL(l_comp.s_segment_rule_type_code,C_CHAR) OR
          NVL(l_comp.w_segment_rule_code,C_CHAR)      <> NVL(l_comp.s_segment_rule_code,C_CHAR)) THEN

        l_parent_key := l_key;

        IF (l_comp.s_segment_rule_code IS NOT NULL) THEN

          record_updated_component
                 (p_parent_component_type => 'AMB_ADR_ASSGN'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_ADR'
                 ,p_component_key         => l_comp.s_segment_rule_type_code||C_CHAR||
                                             l_comp.s_segment_rule_code
                 ,p_merge_impact          => C_MERGE_IMPACT_NEW
                 ,p_component_appl_id     => l_comp.s_segment_rule_appl_id
                 ,p_component_owner_code  => l_comp.s_segment_rule_type_code
                 ,p_component_code        => l_comp.s_segment_rule_code);
        END IF;

        IF (l_comp.w_segment_rule_code IS NOT NULL) THEN

          record_updated_component
                 (p_parent_component_type => 'AMB_ADR_ASSGN'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_ADR'
                 ,p_component_key         => l_comp.w_segment_rule_type_code||C_CHAR||
                                             l_comp.w_segment_rule_code
                 ,p_merge_impact          => C_MERGE_IMPACT_DELETED
                 ,p_component_appl_id     => l_comp.s_segment_rule_appl_id
                 ,p_component_owner_code  => l_comp.w_segment_rule_type_code
                 ,p_component_code        => l_comp.w_segment_rule_code);
        END IF;
      END IF;
    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated line adr assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_line_adr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_line_adr_assgns;


--=============================================================================
--
-- Name: compare_line_ac_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_line_ac_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.analytical_criterion_type_code
         , s.analytical_criterion_code
         , C_MERGE_IMPACT_NEW merge_impact
      FROM xla_line_defn_ac_assgns s
         , xla_line_defn_jlt_assgns b
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND b.application_id              = g_application_id
       AND b.amb_context_code            = g_amb_context_code
       AND b.event_class_code            = s.event_class_code
       AND b.event_type_code             = s.event_type_code
       AND b.line_definition_owner_code  = s.line_definition_owner_code
       AND b.line_definition_code        = s.line_definition_code
       AND b.accounting_line_type_code   = s.accounting_line_type_code
       AND b.accounting_line_code        = s.accounting_line_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_line_defn_ac_assgns w
             WHERE w.application_id                 = g_application_id
               AND w.amb_context_code               = g_amb_context_code
               AND w.event_class_code               = s.event_class_code
               AND w.event_type_code                = s.event_type_code
               AND w.line_definition_owner_code     = s.line_definition_owner_code
               AND w.line_definition_code           = s.line_definition_code
               AND w.accounting_line_type_code      = s.accounting_line_type_code
               AND w.accounting_line_code           = s.accounting_line_code
               AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
               AND w.analytical_criterion_code      = s.analytical_criterion_code);

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_line_ac_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_line_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated line ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code;

    l_key := l_comp.analytical_criterion_type_code||C_CHAR||
             l_comp.analytical_criterion_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated line ac assgn',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_parent_key = '||l_parent_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_component
          (p_parent_component_type => 'AMB_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_AC'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_component_owner_code  => l_comp.analytical_criterion_type_code
          ,p_component_code        => l_comp.analytical_criterion_code);

    record_updated_line_assgn
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code
          ,p_accounting_line_type_code  => l_comp.accounting_line_type_code
          ,p_accounting_line_code       => l_comp.accounting_line_code
          ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated line ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_line_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_line_ac_assgns;


--=============================================================================
--
-- Name: compare_mpa_hdr_ac_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_mpa_hdr_ac_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.analytical_criterion_type_code
         , s.analytical_criterion_code
         , C_MERGE_IMPACT_NEW merge_impact
      FROM xla_mpa_header_ac_assgns s
         , xla_line_defn_jlt_assgns b
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND b.application_id              = g_application_id
       AND b.amb_context_code            = g_amb_context_code
       AND b.event_class_code            = s.event_class_code
       AND b.event_type_code             = s.event_type_code
       AND b.line_definition_owner_code  = s.line_definition_owner_code
       AND b.line_definition_code        = s.line_definition_code
       AND b.accounting_line_type_code   = s.accounting_line_type_code
       AND b.accounting_line_code        = s.accounting_line_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_mpa_header_ac_assgns w
             WHERE w.application_id                 = g_application_id
               AND w.amb_context_code               = g_amb_context_code
               AND w.event_class_code               = s.event_class_code
               AND w.event_type_code                = s.event_type_code
               AND w.line_definition_owner_code     = s.line_definition_owner_code
               AND w.line_definition_code           = s.line_definition_code
               AND w.accounting_line_type_code      = s.accounting_line_type_code
               AND w.accounting_line_code           = s.accounting_line_code
               AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
               AND w.analytical_criterion_code      = s.analytical_criterion_code);

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mpa_hdr_ac_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mpa_hdr_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mpa header ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code||C_CHAR||
                    'MPA';

    l_key := l_comp.analytical_criterion_type_code||C_CHAR||
             l_comp.analytical_criterion_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated mpa header ac assgn',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_parent_key = '||l_parent_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_component
          (p_parent_component_type => 'AMB_MPA_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_AC'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_component_owner_code  => l_comp.analytical_criterion_type_code
          ,p_component_code        => l_comp.analytical_criterion_code);

    record_updated_mpa_assgn
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code
          ,p_accounting_line_type_code  => l_comp.accounting_line_type_code
          ,p_accounting_line_code       => l_comp.accounting_line_code
          ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mpa header ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mpa_hdr_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mpa_hdr_ac_assgns;

--=============================================================================
--
-- Name: compare_mpa_hdr_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_mpa_hdr_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , CASE WHEN sl.mpa_option_code = 'NONE'
                THEN C_MERGE_IMPACT_DELETED
                WHEN wl.mpa_option_code = 'NONE'
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END merge_impact
         , s.mpa_header_desc_type_code s_mpa_header_desc_type_code
         , w.mpa_header_desc_type_code w_mpa_header_desc_type_code
         , s.mpa_header_desc_code      s_mpa_header_desc_code
         , w.mpa_header_desc_code      w_mpa_header_desc_code
         , s.mpa_num_je_code           s_mpa_num_je_code
         , w.mpa_num_je_code           w_mpa_num_je_code
         , s.mpa_gl_dates_code         s_mpa_gl_dates_code
         , w.mpa_gl_dates_code         w_mpa_gl_dates_code
         , s.mpa_proration_code        s_mpa_proration_code
         , w.mpa_proration_code        w_mpa_proration_code
      FROM xla_line_defn_jlt_assgns s
           JOIN xla_line_defn_jlt_assgns w
           ON  w.application_id              = g_application_id
           AND w.amb_context_code            = g_amb_context_code
           AND w.event_class_code            = s.event_class_code
           AND w.event_type_code             = s.event_type_code
           AND w.line_definition_owner_code  = s.line_definition_owner_code
           AND w.line_definition_code        = s.line_definition_code
           AND w.accounting_line_type_code   = s.accounting_line_type_code
           AND w.accounting_line_code        = s.accounting_line_code
           JOIN xla_acct_line_types_b sl
           ON  sl.application_id             = s.application_id
           AND sl.amb_context_code           = s.amb_context_code
           AND sl.event_class_code           = s.event_class_code
           AND sl.accounting_line_type_code  = s.accounting_line_type_code
           AND sl.accounting_line_code       = s.accounting_line_code
           JOIN xla_acct_line_types_b wl
           ON  wl.application_id             = w.application_id
           AND wl.amb_context_code           = w.amb_context_code
           AND wl.event_class_code           = w.event_class_code
           AND wl.accounting_line_type_code  = w.accounting_line_type_code
           AND wl.accounting_line_code       = w.accounting_line_code
           --AND sl.mpa_option_code           <> wl.mpa_option_code
     WHERE s.application_id                  = g_application_id
       AND s.amb_context_code                = g_staging_context_code
       AND (sl.mpa_option_code               = 'ACCRUAL' OR
            wl.mpa_option_code               = 'ACCRUAL')
       AND (NVL(s.mpa_header_desc_type_code,C_CHAR) <> NVL(w.mpa_header_desc_type_code,C_CHAR) OR
            NVL(s.mpa_header_desc_code,C_CHAR)      <> NVL(w.mpa_header_desc_code,C_CHAR)      OR
            NVL(s.mpa_num_je_code,C_CHAR)           <> NVL(w.mpa_num_je_code,C_CHAR)           OR
            NVL(s.mpa_gl_dates_code,C_CHAR)         <> NVL(w.mpa_gl_dates_code,C_CHAR)         OR
            NVL(s.mpa_proration_code,C_CHAR)        <> NVL(w.mpa_proration_code,C_CHAR));

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mpa_hdr_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mpa_hdr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mpa header assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code||C_CHAR||
                    'MPA';

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated mpa header assgn - ',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_parent_key = '||l_parent_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_mpa_assgn
                (p_event_class_code           => l_comp.event_class_code
                ,p_event_type_code            => l_comp.event_type_code
                ,p_line_definition_owner_code => l_comp.line_definition_owner_code
                ,p_line_definition_code       => l_comp.line_definition_code
                ,p_accounting_line_type_code  => l_comp.accounting_line_type_code
                ,p_accounting_line_code       => l_comp.accounting_line_code
                ,p_merge_impact               => l_comp.merge_impact);

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      IF (l_comp.s_mpa_header_desc_type_code IS NOT NULL AND
          l_comp.w_mpa_header_desc_type_code IS NULL) OR
         (NVL(l_comp.s_mpa_header_desc_type_code,C_CHAR) <> NVL(l_comp.s_mpa_header_desc_type_code,C_CHAR) OR
          NVL(l_comp.w_mpa_header_desc_code,C_CHAR)      <> NVL(l_comp.s_mpa_header_desc_code,C_CHAR)) THEN

        l_key := l_comp.s_mpa_header_desc_type_code||C_CHAR||
                 l_comp.s_mpa_header_desc_code;

        record_updated_component
                 (p_parent_component_type => 'AMB_MPA_ASSIGNMENT'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_DESCRIPTION'
                 ,p_component_key         => l_key
                 ,p_merge_impact          => C_MERGE_IMPACT_NEW
                 ,p_component_owner_code  => l_comp.s_mpa_header_desc_type_code
                 ,p_component_code        => l_comp.s_mpa_header_desc_code);

      ELSIF (l_comp.w_mpa_header_desc_type_code IS NOT NULL AND
             l_comp.s_mpa_header_desc_type_code IS NULL) OR
            (NVL(l_comp.s_mpa_header_desc_type_code,C_CHAR) <> NVL(l_comp.s_mpa_header_desc_type_code,C_CHAR) OR
             NVL(l_comp.w_mpa_header_desc_code,C_CHAR)      <> NVL(l_comp.s_mpa_header_desc_code,C_CHAR)) THEN

        l_key := l_comp.w_mpa_header_desc_type_code||C_CHAR||
                 l_comp.w_mpa_header_desc_code;

        record_updated_component
                 (p_parent_component_type => 'AMB_MPA_ASSIGNMENT'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_DESCRIPTION'
                 ,p_component_key         => l_key
                 ,p_merge_impact          => C_MERGE_IMPACT_DELETED
                 ,p_component_owner_code  => l_comp.s_mpa_header_desc_type_code
                 ,p_component_code        => l_comp.s_mpa_header_desc_code);
      END IF;

      IF (l_comp.w_mpa_num_je_code <> l_comp.s_mpa_num_je_code) THEN
        record_updated_property
              (p_component_type => 'AMB_MPA_ASSIGNMENT'
              ,p_component_key  => l_parent_key
              ,p_property       => 'MPA_NUM_JE'
              ,p_old_value      => l_comp.w_mpa_num_je_code
              ,p_new_value      => l_comp.s_mpa_num_je_code
              ,p_lookup_type    => 'XLA_MPA_NUM_OF_ENTRIES');
      END IF;

      IF (l_comp.w_mpa_gl_dates_code <> l_comp.s_mpa_gl_dates_code) THEN
        record_updated_property
              (p_component_type => 'AMB_MPA_ASSIGNMENT'
              ,p_component_key  => l_parent_key
              ,p_property       => 'MPA_GL_DATES'
              ,p_old_value      => l_comp.w_mpa_gl_dates_code
              ,p_new_value      => l_comp.s_mpa_gl_dates_code
              ,p_lookup_type    => 'XLA_MPA_GL_DATE');
      END IF;

      IF (NVL(l_comp.w_mpa_proration_code,C_CHAR) <> NVL(l_comp.s_mpa_proration_code,C_CHAR)) THEN
        record_updated_property
              (p_component_type => 'AMB_MPA_ASSIGNMENT'
              ,p_component_key  => l_parent_key
              ,p_property       => 'MPA_PRORATION'
              ,p_old_value      => l_comp.w_mpa_proration_code
              ,p_new_value      => l_comp.s_mpa_proration_code
              ,p_lookup_type    => 'XLA_MPA_PRORATION');
      END IF;

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mpa header assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mpa_hdr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mpa_hdr_assgns;

--=============================================================================
--
-- Name: compare_mpa_jlt_adr_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_mpa_jlt_adr_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.mpa_accounting_line_type_code
         , s.mpa_accounting_line_code
         , s.flexfield_segment_code
         , l.accounting_coa_id
         , CASE WHEN w.application_id IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                merge_impact
         , s.segment_rule_appl_id   s_segment_rule_appl_id
         , w.segment_rule_appl_id   w_segment_rule_appl_id
         , s.segment_rule_type_code s_segment_rule_type_code
         , w.segment_rule_type_code w_segment_rule_type_code
         , s.segment_rule_code      s_segment_rule_code
         , w.segment_rule_code      w_segment_rule_code
         , s.inherit_adr_flag       s_inherit_adr_flag
         , w.inherit_adr_flag       w_inherit_adr_flag
      FROM xla_mpa_jlt_adr_assgns s
           JOIN xla_line_definitions_b l
           ON  l.application_id              = g_application_id
           AND l.amb_context_code            = g_amb_context_code
           AND l.event_class_code            = s.event_class_code
           AND l.event_type_code             = s.event_type_code
           AND l.line_definition_owner_code  = s.line_definition_owner_code
           AND l.line_definition_code        = s.line_definition_code
           JOIN xla_mpa_jlt_assgns b
           ON  b.application_id                = g_application_id
           AND b.amb_context_code              = g_amb_context_code
           AND b.event_class_code              = s.event_class_code
           AND b.event_type_code               = s.event_type_code
           AND b.line_definition_owner_code    = s.line_definition_owner_code
           AND b.line_definition_code          = s.line_definition_code
           AND b.accounting_line_type_code     = s.accounting_line_type_code
           AND b.accounting_line_code          = s.accounting_line_code
           AND b.mpa_accounting_line_type_code = s.mpa_accounting_line_type_code
           AND b.mpa_accounting_line_code      = s.mpa_accounting_line_code
           LEFT OUTER JOIN xla_mpa_jlt_adr_assgns w
           ON  w.application_id                 = g_application_id
           AND w.amb_context_code               = g_amb_context_code
           AND w.event_class_code               = s.event_class_code
           AND w.event_type_code                = s.event_type_code
           AND w.line_definition_owner_code     = s.line_definition_owner_code
           AND w.line_definition_code           = s.line_definition_code
           AND w.accounting_line_type_code      = s.accounting_line_type_code
           AND w.accounting_line_code           = s.accounting_line_code
           AND w.mpa_accounting_line_type_code  = s.mpa_accounting_line_type_code
           AND w.mpa_accounting_line_code       = s.mpa_accounting_line_code
           AND w.flexfield_segment_code         = s.flexfield_segment_code
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND (w.application_id                     IS NULL OR
            s.inherit_adr_flag                   <> w.inherit_adr_flag OR
            NVL(s.segment_rule_appl_id,C_NUM)    <> NVL(w.segment_rule_appl_id,C_NUM) OR
            NVL(s.segment_rule_type_code,C_CHAR) <> NVL(w.segment_rule_type_code,C_CHAR) OR
            NVL(s.segment_rule_code,C_CHAR)      <> NVL(w.segment_rule_code,C_CHAR));

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mpa_jlt_adr_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mpa_jlt_adr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mpa line adr assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code||C_CHAR||
                    'MPA'||C_CHAR||
                    l_comp.mpa_accounting_line_type_code||C_CHAR||
                    l_comp.mpa_accounting_line_code;

    l_key := l_parent_key||C_CHAR||
             l_comp.flexfield_segment_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated mpa line adr assgn',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_parent_key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (NOT key_exists('LNADR'||C_CHAR||l_key)) THEN
      record_updated_component
          (p_parent_component_type => 'AMB_MPA_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_MPA_ADR_ASSGN'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_component_owner_code  => l_comp.accounting_coa_id
          ,p_component_code        => l_comp.flexfield_segment_code);

      record_updated_mpa_line_assgn
          (p_event_class_code              => l_comp.event_class_code
          ,p_event_type_code               => l_comp.event_type_code
          ,p_line_definition_owner_code    => l_comp.line_definition_owner_code
          ,p_line_definition_code          => l_comp.line_definition_code
          ,p_accounting_line_type_code     => l_comp.accounting_line_type_code
          ,p_accounting_line_code          => l_comp.accounting_line_code
          ,p_mpa_acct_line_type_code       => l_comp.mpa_accounting_line_type_code
          ,p_mpa_acct_line_code            => l_comp.mpa_accounting_line_code
          ,p_merge_impact                  => C_MERGE_IMPACT_UPDATED);

    END IF;

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      IF (l_comp.w_inherit_adr_flag <> l_comp.s_inherit_adr_flag) THEN
        record_updated_property
              (p_component_type => 'AMB_MPA_ADR_ASSGN'
              ,p_component_key  => l_key
              ,p_property       => 'INHERIT_ADR_FLAG'
              ,p_old_value      => l_comp.w_inherit_adr_flag
              ,p_new_value      => l_comp.s_inherit_adr_flag
              ,p_lookup_type    => 'XLA_YES_NO');

      END IF;

      IF (NVL(l_comp.w_segment_rule_appl_id,C_NUM)    <> NVL(l_comp.s_segment_rule_appl_id,C_NUM) OR
          NVL(l_comp.w_segment_rule_type_code,C_CHAR) <> NVL(l_comp.s_segment_rule_type_code,C_CHAR) OR
          NVL(l_comp.w_segment_rule_code,C_CHAR)      <> NVL(l_comp.s_segment_rule_code,C_CHAR)) THEN

        l_parent_key := l_key;

        IF (l_comp.s_segment_rule_code IS NOT NULL) THEN

          record_updated_component
                 (p_parent_component_type => 'AMB_MPA_ADR_ASSGN'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_ADR'
                 ,p_component_key         => l_comp.s_segment_rule_type_code||C_CHAR||
                                             l_comp.s_segment_rule_code
                 ,p_merge_impact          => C_MERGE_IMPACT_NEW
                 ,p_component_appl_id     => l_comp.s_segment_rule_appl_id
                 ,p_component_owner_code  => l_comp.s_segment_rule_type_code
                 ,p_component_code        => l_comp.s_segment_rule_code);
        END IF;

        IF (l_comp.w_segment_rule_code IS NOT NULL) THEN

          record_updated_component
                 (p_parent_component_type => 'AMB_MPA_ADR_ASSGN'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_ADR'
                 ,p_component_key         => l_comp.w_segment_rule_type_code||C_CHAR||
                                             l_comp.w_segment_rule_code
                 ,p_merge_impact          => C_MERGE_IMPACT_DELETED
                 ,p_component_appl_id     => l_comp.w_segment_rule_appl_id
                 ,p_component_owner_code  => l_comp.s_segment_rule_type_code
                 ,p_component_code        => l_comp.w_segment_rule_code);
        END IF;
      END IF;
    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mpa line adr assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mpa_jlt_adr_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mpa_jlt_adr_assgns;

--=============================================================================
--
-- Name: compare_mpa_jlt_ac_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_mpa_jlt_ac_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.mpa_accounting_line_type_code
         , s.mpa_accounting_line_code
         , s.analytical_criterion_type_code
         , s.analytical_criterion_code
         , C_MERGE_IMPACT_NEW merge_impact
      FROM xla_mpa_jlt_ac_assgns s
         , xla_mpa_jlt_assgns b
     WHERE s.application_id                = g_application_id
       AND s.amb_context_code              = g_staging_context_code
       AND b.application_id                = g_application_id
       AND b.amb_context_code              = g_amb_context_code
       AND b.event_class_code              = s.event_class_code
       AND b.event_type_code               = s.event_type_code
       AND b.line_definition_owner_code    = s.line_definition_owner_code
       AND b.line_definition_code          = s.line_definition_code
       AND b.accounting_line_type_code     = s.accounting_line_type_code
       AND b.accounting_line_code          = s.accounting_line_code
       AND b.mpa_accounting_line_type_code = s.mpa_accounting_line_type_code
       AND b.mpa_accounting_line_code      = s.mpa_accounting_line_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_mpa_jlt_ac_assgns w
             WHERE w.application_id                 = g_application_id
               AND w.amb_context_code               = g_amb_context_code
               AND w.event_class_code               = s.event_class_code
               AND w.event_type_code                = s.event_type_code
               AND w.line_definition_owner_code     = s.line_definition_owner_code
               AND w.line_definition_code           = s.line_definition_code
               AND w.accounting_line_type_code      = s.accounting_line_type_code
               AND w.accounting_line_code           = s.accounting_line_code
               AND w.mpa_accounting_line_type_code  = s.mpa_accounting_line_type_code
               AND w.mpa_accounting_line_code       = s.mpa_accounting_line_code
               AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
               AND w.analytical_criterion_code      = s.analytical_criterion_code);

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mpa_jlt_ac_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mpa_jlt_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mpa line ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code||C_CHAR||
                    'MPA'||C_CHAR||
                    l_comp.mpa_accounting_line_type_code||C_CHAR||
                    l_comp.mpa_accounting_line_code;

    l_key := l_comp.analytical_criterion_type_code||C_CHAR||
             l_comp.analytical_criterion_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated mpa line ac assgn',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_parent_key = '||l_parent_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_key = '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_component
          (p_parent_component_type => 'AMB_MPA_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_AC'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_component_owner_code  => l_comp.analytical_criterion_type_code
          ,p_component_code        => l_comp.analytical_criterion_code);

    record_updated_mpa_line_assgn
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code
          ,p_accounting_line_type_code  => l_comp.accounting_line_type_code
          ,p_accounting_line_code       => l_comp.accounting_line_code
          ,p_mpa_acct_line_type_code    => l_comp.mpa_accounting_line_type_code
          ,p_mpa_acct_line_code         => l_comp.mpa_accounting_line_code
          ,p_merge_impact               => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mpa line ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mpa_jlt_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mpa_jlt_ac_assgns;

--=============================================================================
--
-- Name: compare_mpa_jlt_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_mpa_jlt_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , s.mpa_accounting_line_type_code
         , s.mpa_accounting_line_code
         , CASE WHEN w.mpa_accounting_line_code IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                 merge_impact
         , s.description_type_code  s_description_type_code
         , w.description_type_code  w_description_type_code
         , s.description_code       s_description_code
         , w.description_code       w_description_code
      FROM xla_mpa_jlt_assgns       s
           JOIN xla_line_defn_jlt_assgns bw
           ON  bw.application_id              = g_application_id
           AND bw.amb_context_code            = g_amb_context_code
           AND bw.event_class_code            = s.event_class_code
           AND bw.event_type_code             = s.event_type_code
           AND bw.line_definition_owner_code  = s.line_definition_owner_code
           AND bw.line_definition_code        = s.line_definition_code
           AND bw.accounting_line_type_code   = s.accounting_line_type_code
           AND bw.accounting_line_code        = s.accounting_line_code
           LEFT OUTER JOIN xla_mpa_jlt_assgns w
           ON  w.application_id                = g_application_id
           AND w.amb_context_code              = g_amb_context_code
           AND w.event_class_code              = s.event_class_code
           AND w.event_type_code               = s.event_type_code
           AND w.line_definition_owner_code    = s.line_definition_owner_code
           AND w.line_definition_code          = s.line_definition_code
           AND w.accounting_line_type_code     = s.accounting_line_type_code
           AND w.accounting_line_code          = s.accounting_line_code
           AND w.mpa_accounting_line_type_code = s.mpa_accounting_line_type_code
           AND w.mpa_accounting_line_code      = s.mpa_accounting_line_code
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND (w.mpa_accounting_line_code IS NULL
        OR  s.description_type_code    <> w.description_type_code
        OR  s.description_code         <> w.description_code)
  UNION
    SELECT w.event_class_code
         , w.event_type_code
         , w.line_definition_owner_code
         , w.line_definition_code
         , w.accounting_line_type_code
         , w.accounting_line_code
         , w.mpa_accounting_line_type_code
         , w.mpa_accounting_line_code
         , C_MERGE_IMPACT_DELETED
         , NULL, NULL, NULL, NULL
      FROM xla_mpa_jlt_assgns       w
           JOIN xla_line_defn_jlt_assgns bs
           ON  bs.application_id              = g_application_id
           AND bs.amb_context_code            = g_staging_context_code
           AND bs.event_class_code            = w.event_class_code
           AND bs.event_type_code             = w.event_type_code
           AND bs.line_definition_owner_code  = w.line_definition_owner_code
           AND bs.line_definition_code        = w.line_definition_code
           AND bs.accounting_line_type_code   = w.accounting_line_type_code
           AND bs.accounting_line_code        = w.accounting_line_code
           LEFT OUTER JOIN xla_mpa_jlt_assgns s
           ON  s.application_id                = g_application_id
           AND s.amb_context_code              = g_staging_context_code
           AND s.event_class_code              = w.event_class_code
           AND s.event_type_code               = w.event_type_code
           AND s.line_definition_owner_code    = w.line_definition_owner_code
           AND s.line_definition_code          = w.line_definition_code
           AND s.accounting_line_type_code     = w.accounting_line_type_code
           AND s.accounting_line_code          = w.accounting_line_code
           AND s.mpa_accounting_line_type_code = w.mpa_accounting_line_type_code
           AND s.mpa_accounting_line_code      = w.mpa_accounting_line_code
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_amb_context_code
       AND w.mpa_accounting_line_code IS NULL;

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_mpa_jlt_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_mpa_jlt_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated mpa jlt assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code||C_CHAR||
                    l_comp.accounting_line_type_code||C_CHAR||
                    l_comp.accounting_line_code||C_CHAR||
                    'MPA'||C_CHAR||
                    l_comp.mpa_accounting_line_type_code||C_CHAR||
                    l_comp.mpa_accounting_line_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated mpa jlt assgn - merge_impact = '||l_comp.merge_impact,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
      trace(p_msg    => 'l_parent_key = '||l_parent_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (l_comp.merge_impact IN (C_MERGE_IMPACT_NEW, C_MERGE_IMPACT_DELETED)) THEN

      l_key := l_comp.mpa_accounting_line_type_code||C_CHAR||
               l_comp.mpa_accounting_line_code;

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace(p_msg    => 'l_key = '||l_key,
              p_module => l_log_module,
              p_level  => C_LEVEL_PROCEDURE);
      END IF;

      record_updated_component
          (p_parent_component_type => 'AMB_MPA_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_JLT'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_event_class_code      => l_comp.event_class_code
          ,p_event_type_code       => NULL
          ,p_component_owner_code  => l_comp.mpa_accounting_line_type_code
          ,p_component_code        => l_comp.mpa_accounting_line_code);

    ELSE

      IF (l_comp.s_description_type_code IS NOT NULL) THEN

        l_key := l_comp.s_description_type_code||C_CHAR||
                 l_comp.s_description_code;

        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace(p_msg    => 'merge_impact = '||C_MERGE_IMPACT_NEW,
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
          trace(p_msg    => 'l_key = '||l_key,
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
        END IF;

        record_updated_component
          (p_parent_component_type => 'AMB_MPA_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_DESCRIPTION'
          ,p_component_key         => l_key
          ,p_merge_impact          => C_MERGE_IMPACT_NEW
          ,p_component_owner_code  => l_comp.s_description_type_code
          ,p_component_code        => l_comp.s_description_code);

      END IF;

      IF (l_comp.w_description_type_code IS NOT NULL) THEN

        l_key := l_comp.w_description_type_code||C_CHAR||
                 l_comp.w_description_code;

        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace(p_msg    => 'merge_impact = '||C_MERGE_IMPACT_DELETED,
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
          trace(p_msg    => 'l_key = '||l_key,
                p_module => l_log_module,
                p_level  => C_LEVEL_PROCEDURE);
        END IF;

        record_updated_component
          (p_parent_component_type => 'AMB_MPA_LINE_ASSIGNMENT'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_DESCRIPTION'
          ,p_component_key         => l_key
          ,p_merge_impact          => C_MERGE_IMPACT_DELETED
          ,p_component_owner_code  => l_comp.w_description_type_code
          ,p_component_code        => l_comp.w_description_code);
      END IF;

    END IF;

    record_updated_mpa_line_assgn
          (p_event_class_code               => l_comp.event_class_code
          ,p_event_type_code                => l_comp.event_type_code
          ,p_line_definition_owner_code     => l_comp.line_definition_owner_code
          ,p_line_definition_code           => l_comp.line_definition_code
          ,p_accounting_line_type_code      => l_comp.accounting_line_type_code
          ,p_accounting_line_code           => l_comp.accounting_line_code
          ,p_mpa_acct_line_type_code        => l_comp.mpa_accounting_line_type_code
          ,p_mpa_acct_line_code             => l_comp.mpa_accounting_line_code
          ,p_merge_impact                   => C_MERGE_IMPACT_UPDATED);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated mpa jlt assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_mpa_jlt_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_mpa_jlt_assgns;


--=============================================================================
--
-- Name: compare_jld_jlt_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_jld_jlt_assgns
IS
  CURSOR c_comp IS
    SELECT s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , s.accounting_line_type_code
         , s.accounting_line_code
         , CASE WHEN w.application_id IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                    merge_impact
         , s.active_flag               s_active_flag
         , w.active_flag               w_active_flag
         , s.description_type_code     s_description_type_code
         , w.description_type_code     w_description_type_code
         , s.description_code          s_description_code
         , w.description_code          w_description_code
         , s.inherit_desc_flag         s_inherit_desc_flag
         , w.inherit_desc_flag         w_inherit_desc_flag
      FROM xla_line_defn_jlt_assgns s
           JOIN xla_line_definitions_b b
           ON  b.application_id             = g_application_id
           AND b.amb_context_code           = g_amb_context_code
           AND b.event_class_code           = s.event_class_code
           AND b.event_type_code            = s.event_type_code
           AND b.line_definition_owner_code = s.line_definition_owner_code
           AND b.line_definition_code       = s.line_definition_code
           LEFT OUTER JOIN xla_line_defn_jlt_assgns w
           ON  w.application_id             = g_application_id
           AND w.amb_context_code           = g_amb_context_code
           AND w.event_class_code           = s.event_class_code
           AND w.event_type_code            = s.event_type_code
           AND w.line_definition_owner_code = s.line_definition_owner_code
           AND w.line_definition_code       = s.line_definition_code
           AND w.accounting_line_type_code  = s.accounting_line_type_code
           AND w.accounting_line_code       = s.accounting_line_code
     WHERE s.application_id   = g_application_id
       AND s.amb_context_code = g_staging_context_code
       AND (w.application_id IS NULL
        OR  NVL(s.active_flag,C_CHAR)               <> NVL(w.active_flag,C_CHAR)
        OR  NVL(s.inherit_desc_flag,C_CHAR)         <> NVL(w.inherit_desc_flag,C_CHAR)
        OR  NVL(s.description_type_code,C_CHAR)     <> NVL(w.description_type_code,C_CHAR)
        OR  NVL(s.description_code,C_CHAR)          <> NVL(w.description_code,C_CHAR)
        );

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_merge_impact        VARCHAR2(30);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_jld_jlt_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_jld_jlt_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated jld jlt assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    record_updated_line_assgn
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code
          ,p_accounting_line_type_code  => l_comp.accounting_line_type_code
          ,p_accounting_line_code       => l_comp.accounting_line_code
          ,p_merge_impact               => l_comp.merge_impact);

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      l_parent_key := l_comp.event_class_code||C_CHAR||
               l_comp.event_type_code||C_CHAR||
               l_comp.line_definition_owner_code||C_CHAR||
               l_comp.line_definition_code||C_CHAR||
               l_comp.accounting_line_type_code||C_CHAR||
               l_comp.accounting_line_code;

      IF (l_comp.w_active_flag <> l_comp.s_active_flag) THEN
        record_updated_property
              (p_component_type => 'AMB_LINE_ASSIGNMENT'
              ,p_component_key  => l_parent_key
              ,p_property       => 'ACTIVE'
              ,p_old_value      => l_comp.w_active_flag
              ,p_new_value      => l_comp.s_active_flag
              ,p_lookup_type    => 'XLA_YES_NO');

      END IF;

      IF (l_comp.w_inherit_desc_flag <> l_comp.s_inherit_desc_flag) THEN
        record_updated_property
              (p_component_type => 'AMB_LINE_ASSIGNMENT'
              ,p_component_key  => l_parent_key
              ,p_property       => 'INHERIT_DESC'
              ,p_old_value      => l_comp.w_inherit_desc_flag
              ,p_new_value      => l_comp.s_inherit_desc_flag
              ,p_lookup_type    => 'XLA_YES_NO');

      END IF;

      IF (NVL(l_comp.w_description_type_code,C_CHAR) <> NVL(l_comp.s_description_type_code,C_CHAR) OR
          NVL(l_comp.w_description_code,C_CHAR)      <> NVL(l_comp.s_description_code,C_CHAR)) THEN

        IF (l_comp.s_description_code IS NOT NULL) THEN

          l_key := l_comp.s_description_type_code||C_CHAR||
                   l_comp.s_description_code;

          IF (NOT key_exists('LDESC'||C_CHAR||l_parent_key||C_CHAR||l_key)) THEN

            record_updated_component
                 (p_parent_component_type => 'AMB_LINE_ASSIGNMENT'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_DESCRIPTION'
                 ,p_component_key         => l_key
                 ,p_merge_impact          => C_MERGE_IMPACT_NEW
                 ,p_component_owner_code  => l_comp.s_description_type_code
                 ,p_component_code        => l_comp.s_description_code);
          END IF;
        END IF;

        IF (l_comp.w_description_code IS NOT NULL) THEN

          l_key := l_comp.w_description_type_code||C_CHAR||
                   l_comp.w_description_code;

          IF (NOT key_exists('LDESC'||C_CHAR||l_parent_key||C_CHAR||l_key)) THEN

            record_updated_component
                 (p_parent_component_type => 'AMB_LINE_ASSIGNMENT'
                 ,p_parent_component_key  => l_parent_key
                 ,p_component_type        => 'AMB_DESCRIPTION'
                 ,p_component_key         => l_key
                 ,p_merge_impact          => C_MERGE_IMPACT_DELETED
                 ,p_component_owner_code  => l_comp.w_description_type_code
                 ,p_component_code        => l_comp.w_description_code);
          END IF;
        END IF;
      END IF; -- updated description

    END IF; -- l_comp.merge_impact = C_MERGE_IMPACT_UPDATED

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated jld jlt assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_jld_jlt_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_jld_jlt_assgns;


--=============================================================================
--
-- Name: compare_jlds
-- Description:
--
--=============================================================================
PROCEDURE compare_jlds
IS
  CURSOR c_comp IS
    SELECT ts.event_class_code
          ,ts.event_type_code
          ,ts.line_definition_owner_code
          ,ts.line_definition_code
          ,ts.name                       s_name
          ,tw.name                       w_name
          ,ts.description                s_description
          ,tw.description                w_description
          ,bs.enabled_flag               s_enabled_flag
          ,bw.enabled_flag               w_enabled_flag
          ,bs.accounting_coa_id          s_acct_coa_id
          ,bw.accounting_coa_id          w_acct_coa_id
          ,bs.transaction_coa_id         s_trx_coa_id
          ,bw.transaction_coa_id         w_trx_coa_id
          ,bs.budgetary_control_flag     s_budgetary_control_flag
          ,bw.budgetary_control_flag     w_budgetary_control_flag
      FROM xla_line_definitions_b bs
           JOIN xla_line_definitions_tl ts
           ON  ts.application_id             = bs.application_id
           AND ts.amb_context_code           = bs.amb_context_code
           AND ts.event_class_code           = bs.event_class_code
           AND ts.event_type_code            = bs.event_type_code
           AND ts.line_definition_owner_code = bs.line_definition_owner_code
           AND ts.line_definition_code       = bs.line_definition_code
           AND ts.language                   = USERENV('LANG')
           JOIN xla_line_definitions_b bw
           ON  bw.application_id             = bs.application_id
           AND bw.amb_context_code           = g_amb_context_code
           AND bw.event_class_code           = bs.event_class_code
           AND bw.event_type_code            = bs.event_type_code
           AND bw.line_definition_owner_code = bs.line_definition_owner_code
           AND bw.line_definition_code       = bs.line_definition_code
           JOIN xla_line_definitions_tl tw
           ON  tw.application_id             = bw.application_id
           AND tw.amb_context_code           = bw.amb_context_code
           AND tw.event_class_code           = bw.event_class_code
           AND tw.event_type_code            = bw.event_type_code
           AND tw.line_definition_owner_code = bw.line_definition_owner_code
           AND tw.line_definition_code       = bw.line_definition_code
           AND tw.language                   = USERENV('LANG')
     WHERE bs.amb_context_code = g_staging_context_code
       AND bw.amb_context_code = g_amb_context_code
       AND (ts.name                          <> tw.name                          OR
            NVL(ts.description,C_CHAR)       <> NVL(tw.description,C_CHAR)       OR
            bs.enabled_flag                  <> bw.enabled_flag                  OR
            bs.budgetary_control_flag        <> bw.budgetary_control_flag        OR
            NVL(bs.transaction_coa_id,C_NUM) <> NVL(bw.transaction_coa_id,C_NUM) OR
            NVL(bs.accounting_coa_id,C_NUM)  <> NVL(bw.accounting_coa_id,C_NUM));

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_jlds';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp in c_comp LOOP

    l_key := l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code||C_CHAR||
                    l_comp.line_definition_owner_code||C_CHAR||
                    l_comp.line_definition_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated jld - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_jld
          (p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_definition_owner_code => l_comp.line_definition_owner_code
          ,p_line_definition_code       => l_comp.line_definition_code);

    IF (l_comp.s_name <> l_comp.w_name) THEN
      record_updated_property
          (p_component_type          => 'AMB_JLD'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
    END IF;

    IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
      record_updated_property
          (p_component_type          => 'AMB_JLD'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
    END IF;

    IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_JLD'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    IF (l_comp.s_budgetary_control_flag <> l_comp.w_budgetary_control_flag) THEN
      record_updated_property
          (p_component_type          => 'AMB_JLD'
          ,p_component_key           => l_key
          ,p_property                => 'BUDGETARY_CONTROL'
          ,p_old_value               => l_comp.w_budgetary_control_flag
          ,p_new_value               => l_comp.s_budgetary_control_flag
          ,p_lookup_type             => 'XLA_YES_NO');
    END IF;

    IF (NVL(l_comp.s_acct_coa_id,C_NUM) <> NVL(l_comp.w_acct_coa_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_JLD'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_COA'
          ,p_old_value               => l_comp.w_acct_coa_id
          ,p_new_value               => l_comp.s_acct_coa_id);
    END IF;

    IF (NVL(l_comp.s_trx_coa_id,C_NUM) <> NVL(l_comp.w_trx_coa_id,C_NUM)) THEN
      record_updated_property
          (p_component_type          => 'AMB_JLD'
          ,p_component_key           => l_key
          ,p_property                => 'TRANSACTION_COA'
          ,p_old_value               => l_comp.w_trx_coa_id
          ,p_new_value               => l_comp.s_trx_coa_id);
    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_jlds',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_jlds;


--=============================================================================
--
-- Name: compare_jld_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_jld_assgns
IS
  -- Retrieve new or deleted JLD assignment to the event class/evnet type
  CURSOR c_comp IS
    SELECT s.product_rule_type_code
         , s.product_rule_code
         , s.event_class_code
         , s.event_type_code
         , s.line_definition_owner_code
         , s.line_definition_code
         , C_MERGE_IMPACT_NEW merge_impact
      FROM xla_aad_line_defn_assgns s
         , xla_prod_acct_headers    b
     WHERE s.application_id         = g_application_id
       AND s.amb_context_code       = g_staging_context_code
       AND b.application_id         = g_application_id
       AND b.amb_context_code       = g_amb_context_code
       AND b.product_rule_type_code = s.product_rule_type_code
       AND b.product_rule_code      = s.product_rule_code
       AND b.event_class_code       = s.event_class_code
       AND b.event_type_code        = s.event_type_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_aad_line_defn_assgns w
             WHERE w.application_id             = g_application_id
               AND w.amb_context_code           = g_amb_context_code
               AND s.product_rule_type_code     = w.product_rule_type_code
               AND s.product_rule_code          = w.product_rule_code
               AND s.event_class_code           = w.event_class_code
               AND s.event_type_code            = w.event_type_code
               AND s.line_definition_owner_code = w.line_definition_owner_code
               AND s.line_definition_code       = w.line_definition_code);

  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_jld_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_jld_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated jld assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    record_updated_jld_assgn
          (p_product_rule_type_code     => l_comp.product_rule_type_code
          ,p_product_rule_code          => l_comp.product_rule_code
          ,p_event_class_code           => l_comp.event_class_code
          ,p_event_type_code            => l_comp.event_type_code
          ,p_line_defn_owner_code       => l_comp.line_definition_owner_code
          ,p_line_defn_code             => l_comp.line_definition_code
          ,p_merge_impact               => l_comp.merge_impact);

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated jld assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_jld_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_jld_assgns;

--=============================================================================
--
-- Name: compare_hdr_ac_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_hdr_ac_assgns
IS
  CURSOR c_comp IS
    SELECT s.product_rule_type_code
         , s.product_rule_code
         , s.event_class_code
         , s.event_type_code
         , s.analytical_criterion_type_code
         , s.analytical_criterion_code
         , C_MERGE_IMPACT_NEW merge_impact
      FROM xla_aad_header_ac_assgns s
         , xla_prod_acct_headers b
     WHERE s.application_id              = g_application_id
       AND s.amb_context_code            = g_staging_context_code
       AND b.application_id              = g_application_id
       AND b.amb_context_code            = g_amb_context_code
       AND b.product_rule_type_code      = s.product_rule_type_code
       AND b.product_rule_code           = s.product_rule_code
       AND b.event_class_code            = s.event_class_code
       AND b.event_type_code             = s.event_type_code
       AND NOT EXISTS
           (SELECT 1
              FROM xla_aad_header_ac_assgns w
             WHERE w.application_id                 = g_application_id
               AND w.amb_context_code               = g_amb_context_code
               AND w.product_rule_type_code         = s.product_rule_type_code
               AND w.product_rule_code              = s.product_rule_code
               AND w.event_class_code               = s.event_class_code
               AND w.event_type_code                = s.event_type_code
               AND w.analytical_criterion_type_code = s.analytical_criterion_type_code
               AND w.analytical_criterion_code      = s.analytical_criterion_code);

  l_parent_key          VARCHAR2(240);
  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_hdr_ac_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_hdr_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated header ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_parent_key := l_comp.product_rule_type_code||C_CHAR||
                    l_comp.product_rule_code||C_CHAR||
                    l_comp.event_class_code||C_CHAR||
                    l_comp.event_type_code;

    l_key := l_comp.analytical_criterion_type_code||C_CHAR||
             l_comp.analytical_criterion_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated header ac assgn - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (NOT key_exists('HAC'||C_CHAR||l_parent_key||C_CHAR||l_key)) THEN
      record_updated_component
          (p_parent_component_type => 'AMB_AAD_EVENT_TYPE'
          ,p_parent_component_key  => l_parent_key
          ,p_component_type        => 'AMB_AC'
          ,p_component_key         => l_key
          ,p_merge_impact          => l_comp.merge_impact
          ,p_component_owner_code  => l_comp.analytical_criterion_type_code
          ,p_component_code        => l_comp.analytical_criterion_code);

      record_updated_header_assgn
          (p_product_rule_type_code => l_comp.product_rule_type_code
          ,p_product_rule_code      => l_comp.product_rule_code
          ,p_event_class_code       => l_comp.event_class_code
          ,p_event_type_code        => l_comp.event_type_code
          ,p_merge_impact           => C_MERGE_IMPACT_UPDATED);
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated header ac assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_hdr_ac_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_hdr_ac_assgns;


--=============================================================================
--
-- Name: compare_hdr_acct_attrs
-- Description:
--
--=============================================================================
PROCEDURE compare_hdr_acct_attrs
IS
  CURSOR c_comp IS
    SELECT s.product_rule_type_code
         , s.product_rule_code
         , s.event_class_code
         , s.event_type_code
         , s.accounting_attribute_code
         , CASE WHEN w.accounting_attribute_code IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED END merge_impact
         ,s.event_class_default_flag s_event_class_default_flag
         ,w.event_class_default_flag w_event_class_default_flag
         ,s.source_application_id    s_source_application_id
         ,w.source_application_id    w_source_application_id
         ,s.source_type_code         s_source_type_code
         ,w.source_type_code         w_source_type_code
         ,s.source_code              s_source_code
         ,w.source_code              w_source_code
      FROM xla_aad_hdr_acct_attrs s
           JOIN xla_prod_acct_headers b
           ON  b.application_id              = g_application_id
           AND b.amb_context_code            = g_amb_context_code
           AND b.product_rule_type_code      = s.product_rule_type_code
           AND b.product_rule_code           = s.product_rule_code
           AND b.event_class_code            = s.event_class_code
           AND b.event_type_code             = s.event_type_code
           LEFT OUTER JOIN xla_aad_hdr_acct_attrs w
           ON  w.application_id                 = g_application_id
           AND w.amb_context_code               = g_amb_context_code
           AND w.product_rule_type_code         = s.product_rule_type_code
           AND w.product_rule_code              = s.product_rule_code
           AND w.event_class_code               = s.event_class_code
           AND w.event_type_code                = s.event_type_code
           AND w.accounting_attribute_code      = s.accounting_attribute_code
     WHERE s.application_id              = g_application_id
       AND s.amb_context_code            = g_staging_context_code
       AND (w.accounting_attribute_code IS NULL OR
            s.event_class_default_flag <> w.event_class_default_flag OR
            s.source_application_id    <> w.source_application_id OR
            s.source_type_code         <> w.source_type_code OR
            s.source_code              <> w.source_code);

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_hdr_acct_attrs';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_hdr_acct_attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated header acct attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    l_key := l_comp.product_rule_type_code||C_CHAR||
             l_comp.product_rule_code||C_CHAR||
             l_comp.event_class_code||C_CHAR||
             l_comp.event_type_code||C_CHAR||
             l_comp.accounting_attribute_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated header acct attr - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    IF (NOT key_exists('HAA'||C_CHAR||l_key)) THEN

      record_updated_header_assgn
          (p_product_rule_type_code => l_comp.product_rule_type_code
          ,p_product_rule_code      => l_comp.product_rule_code
          ,p_event_class_code       => l_comp.event_class_code
          ,p_event_type_code        => l_comp.event_type_code
          ,p_merge_impact           => C_MERGE_IMPACT_UPDATED);

      IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

        IF (l_comp.s_event_class_default_flag <> l_comp.w_event_class_default_flag) THEN

          record_updated_property
            (p_component_type          => 'AMB_AAD_EVENT_TYPE'
            ,p_component_key           => l_key
            ,p_property                => 'ACCOUNTING_REQUIRED_FLAG'
            ,p_old_value               => l_comp.w_event_class_default_flag
            ,p_new_value               => l_comp.s_event_class_default_flag
            ,p_lookup_type             => 'XLA_YES_NO');

        END IF;

        IF (l_comp.s_source_application_id <> l_comp.w_source_application_id OR
            l_comp.s_source_type_code      <> l_comp.s_source_type_code OR
            l_comp.s_source_code           <> l_comp.s_source_code) THEN
          record_updated_source
            (p_component_type          => 'AMB_AAD_EVENT_TYPE'
            ,p_component_key           => l_key
            ,p_property                => 'SOURCE_CODE'
            ,p_old_source_app_id       => l_comp.w_source_application_id
            ,p_old_source_type_code    => l_comp.w_source_type_code
            ,p_old_source_code         => l_comp.w_source_code
            ,p_new_source_app_id       => l_comp.s_source_application_id
            ,p_new_source_type_code    => l_comp.s_source_type_code
            ,p_new_source_code         => l_comp.s_source_code);

        END IF;
      END IF;

    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated header acct attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_hdr_acct_attrs',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_hdr_acct_attrs;




--=============================================================================
--
-- Name: compare_header_assgns
-- Description:
--
--=============================================================================
PROCEDURE compare_header_assgns
IS
  CURSOR c_comp IS
    -- Retreive new, deleted, and updated event class/event type assignment
    SELECT s.product_rule_type_code
         , s.product_rule_code
         , s.event_class_code
         , s.event_type_code
         , CASE WHEN w.event_type_code IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                    merge_impact
         , s.accounting_required_flag  s_accounting_required_flag
         , w.accounting_required_flag  w_accounting_required_flag
         , s.description_type_code     s_description_type_code
         , w.description_type_code     w_description_type_code
         , s.description_code          s_description_code
         , w.description_code          w_description_code
      FROM xla_prod_acct_headers s
           JOIN xla_product_rules_b b
           ON  b.application_id         = g_application_id
           AND b.amb_context_code       = g_amb_context_code
           AND b.product_rule_type_code = s.product_rule_type_code
           AND b.product_rule_code      = s.product_rule_code
           LEFT OUTER JOIN xla_prod_acct_headers w
           ON  w.application_id         = g_application_id
           AND w.amb_context_code       = g_amb_context_code
           AND w.product_rule_type_code = s.product_rule_type_code
           AND w.product_rule_code      = s.product_rule_code
           AND w.event_class_code       = s.event_class_code
           AND w.event_type_code        = s.event_type_code
     WHERE s.application_id             = g_application_id
       AND s.amb_context_code           = g_staging_context_code
       AND (w.event_type_code                   IS NULL OR
            NVL(s.accounting_required_flag,C_CHAR) <> NVL(w.accounting_required_flag,C_CHAR) OR
            NVL(s.description_type_code,C_CHAR)    <> NVL(w.description_type_code,C_CHAR) OR
            NVL(s.description_code,C_CHAR)         <> NVL(w.description_code,C_CHAR));

  l_key                 VARCHAR2(240);
  l_parent_key          VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_header_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_header_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated header assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comp LOOP

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated header assgn - '||
                        l_comp.product_rule_type_code||C_CHAR||
                        l_comp.product_rule_code||C_CHAR||
                        l_comp.event_class_code||C_CHAR||
                        l_comp.event_type_code||C_CHAR||
                        l_comp.merge_impact,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_header_assgn
          (p_product_rule_type_code => l_comp.product_rule_type_code
          ,p_product_rule_code      => l_comp.product_rule_code
          ,p_event_class_code       => l_comp.event_class_code
          ,p_event_type_code        => l_comp.event_type_code
          ,p_merge_impact           => l_comp.merge_impact);

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      l_key := l_comp.product_rule_type_code||C_CHAR||
               l_comp.product_rule_code||C_CHAR||
               l_comp.event_class_code||C_CHAR||
               l_comp.event_type_code;

      IF (l_comp.s_accounting_required_flag <> l_comp.w_accounting_required_flag) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD_EVENT_TYPE'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_REQUIRED_FLAG'
          ,p_old_value               => l_comp.w_accounting_required_flag
          ,p_new_value               => l_comp.s_accounting_required_flag
          ,p_lookup_type             => 'XLA_YES_NO');
      END IF;

      IF (NVL(l_comp.s_description_type_code,C_CHAR) <> NVL(l_comp.w_description_type_code,C_CHAR) OR
          NVL(l_comp.s_description_code,C_CHAR)      <> NVL(l_comp.w_description_code,C_CHAR)) THEN

        IF (l_comp.s_description_code IS NOT NULL) THEN
          l_parent_key := l_key;
          l_key := l_comp.s_description_type_code||C_CHAR||
                   l_comp.s_description_code;

          IF (NOT key_exists('HDESC'||C_CHAR||l_key)) THEN
            record_updated_component
              (p_parent_component_type => 'AMB_AAD_EVENT_TYPE'
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_DESCRIPTION'
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_NEW
              ,p_component_owner_code  => l_comp.s_description_type_code
              ,p_component_code        => l_comp.s_description_code);
          END IF;
        END IF;

        IF (l_comp.w_description_code IS NOT NULL) THEN
          l_key := l_comp.s_description_type_code||C_CHAR||
                   l_comp.s_description_code;

          IF (NOT key_exists('HDESC'||C_CHAR||l_key)) THEN
            record_updated_component
              (p_parent_component_type => 'AMB_AAD_EVENT_TYPE'
              ,p_parent_component_key  => l_parent_key
              ,p_component_type        => 'AMB_DESCRIPTION'
              ,p_component_key         => l_key
              ,p_merge_impact          => C_MERGE_IMPACT_DELETED
              ,p_component_owner_code  => l_comp.w_description_type_code
              ,p_component_code        => l_comp.w_description_code);
          END IF;
        END IF;
      END IF;

    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated header assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_header_assgns',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_header_assgns;


--=============================================================================
--
-- Name: compare_aads
-- Description:
--
--=============================================================================
PROCEDURE compare_aads
IS
  -- Retrieve new, deleted, and updated AAD
  CURSOR c_comps IS
    SELECT bs.product_rule_type_code
         , bs.product_rule_code
         , CASE WHEN bw.application_id IS NULL
                THEN C_MERGE_IMPACT_NEW
                ELSE C_MERGE_IMPACT_UPDATED
                END                merge_impact
         , ts.name                 s_name
         , tw.name                 w_name
         , ts.description          s_description
         , tw.description          w_description
         , bs.transaction_coa_id   s_transaction_coa_id
         , bw.transaction_coa_id   w_transaction_coa_id
         , bs.accounting_coa_id    s_accounting_coa_id
         , bw.accounting_coa_id    w_accounting_coa_id
         , bs.enabled_flag         s_enabled_flag
         , bw.enabled_flag         w_enabled_flag
         , bs.locking_status_flag  s_locking_status_flag
         , bw.locking_status_flag  w_locking_status_flag
         , bs.product_rule_version s_product_rule_version
         , bw.product_rule_version w_product_rule_version
         , bs.version_num          s_version_num
         , bw.version_num          w_version_num
      FROM xla_product_rules_b bs
           JOIN xla_product_rules_tl ts
           ON  ts.application_id         = bs.application_id
           AND ts.amb_context_code       = bs.amb_context_code
           AND ts.product_rule_type_code = bs.product_rule_type_code
           AND ts.product_rule_code      = bs.product_rule_code
           AND ts.language               = USERENV('LANG')
           LEFT OUTER JOIN xla_product_rules_b bw
           ON  bw.application_id         = bs.application_id
           AND bw.amb_context_code       = g_amb_context_code
           AND bw.product_rule_type_code = bs.product_rule_type_code
           AND bw.product_rule_code      = bs.product_rule_code
           LEFT OUTER JOIN xla_product_rules_tl tw
           ON  tw.application_id         = bw.application_id
           AND tw.amb_context_code       = bw.amb_context_code
           AND tw.product_rule_type_code = bw.product_rule_type_code
           AND tw.product_rule_code      = bw.product_rule_code
           AND tw.language               = USERENV('LANG')
     WHERE bs.application_id    = g_application_id
       AND bs.amb_context_code  = g_staging_context_code
       AND (bw.application_id                  IS NULL                                 OR
            NVL(ts.name,C_CHAR)                <> NVL(tw.name, C_CHAR)                 OR
            NVL(ts.description,C_CHAR)         <> NVL(tw.description, C_CHAR)          OR
            NVL(bs.transaction_coa_id,C_NUM)   <> NVL(bw.transaction_coa_id, C_NUM)    OR
            NVL(bs.accounting_coa_id,C_NUM)    <> NVL(bw.accounting_coa_id, C_NUM)     OR
            NVL(bs.enabled_flag,C_CHAR)        <> NVL(bw.enabled_flag, C_CHAR)         OR
            NVL(bs.locking_status_flag,C_CHAR) <> NVL(bw.locking_status_flag, C_CHAR)  OR
            NVL(bs.product_rule_version,C_CHAR)<> NVL(bw.product_rule_version, C_CHAR) OR
            NVL(bs.version_num,C_NUM)          <> NVL(bw.version_num, C_NUM));

  l_key                 VARCHAR2(240);
  l_log_module          VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.compare_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function compare_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP: updated aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  FOR l_comp IN c_comps LOOP

    l_key := l_comp.product_rule_type_code||C_CHAR||
             l_comp.product_rule_code;

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'LOOP: updated aad - '||l_key,
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
    END IF;

    record_updated_aad
          (p_product_rule_type_code => l_comp.product_rule_type_code
          ,p_product_rule_code      => l_comp.product_rule_code
          ,p_merge_impact           => l_comp.merge_impact);

    IF (l_comp.merge_impact = C_MERGE_IMPACT_UPDATED) THEN

      IF (l_comp.s_name <> l_comp.w_name) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'NAME'
          ,p_old_value               => l_comp.w_name
          ,p_new_value               => l_comp.s_name);
      END IF;

      IF (NVL(l_comp.s_description,C_CHAR) <> NVL(l_comp.w_description,C_CHAR)) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'DESCRIPTION'
          ,p_old_value               => l_comp.w_description
          ,p_new_value               => l_comp.s_description);
      END IF;

      IF (NVL(l_comp.s_transaction_coa_id,C_NUM) <> NVL(l_comp.w_transaction_coa_id,C_NUM)) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'TRANSACTION_COA'
          ,p_old_value               => l_comp.w_transaction_coa_id
          ,p_new_value               => l_comp.s_transaction_coa_id);
      END IF;

      IF (NVL(l_comp.s_accounting_coa_id,C_NUM) <> NVL(l_comp.w_accounting_coa_id,C_NUM)) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'ACCOUNTING_COA'
          ,p_old_value               => l_comp.w_accounting_coa_id
          ,p_new_value               => l_comp.s_accounting_coa_id);
      END IF;

      IF (l_comp.s_enabled_flag <> l_comp.w_enabled_flag) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'ENABLED'
          ,p_old_value               => l_comp.w_enabled_flag
          ,p_new_value               => l_comp.s_enabled_flag
          ,p_lookup_type             => 'XLA_YES_NO');
      END IF;

      IF (l_comp.s_locking_status_flag <> l_comp.w_locking_status_flag) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'LOCKED'
          ,p_old_value               => l_comp.w_locking_status_flag
          ,p_new_value               => l_comp.s_locking_status_flag
          ,p_lookup_type             => 'XLA_YES_NO');
      END IF;

      IF (NVL(l_comp.s_product_rule_version,C_CHAR) <> NVL(l_comp.w_product_rule_version,C_CHAR)) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'PRODUCT_RULE_VERSION'
          ,p_old_value               => l_comp.w_product_rule_version
          ,p_new_value               => l_comp.s_product_rule_version);
      END IF;

      IF (NVL(l_comp.s_version_num,C_NUM) <> NVL(l_comp.w_version_num,C_NUM)) THEN
        record_updated_property
          (p_component_type          => 'AMB_AAD'
          ,p_component_key           => l_key
          ,p_property                => 'VERSION_NUM'
          ,p_old_value               => l_comp.w_version_num
          ,p_new_value               => l_comp.s_version_num);
      END IF;

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END LOOP: updated aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function compare_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => l_log_module);
END compare_aads;

--=============================================================================
--
-- Name; analyze_aads
-- Description:
--
--=============================================================================
PROCEDURE analyze_aads
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analyze_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (g_user_mode = 'C') THEN
    analyze_deleted_oracle_comps;
    compare_mapping_set_values;
    compare_mapping_sets;
  END IF;

  -- compare journal entry setups
  compare_jlt_acct_attrs;
  compare_jlts;

  compare_ac_sources;
  compare_ac_details;
  compare_acs;

  compare_desc_priorities;
  compare_descs;

  compare_adr_details;
  compare_adrs;

  -- compare journal entry definition assignments
  compare_mpa_jlt_adr_assgns;
  compare_mpa_jlt_ac_assgns;
  compare_mpa_jlt_assgns;
  compare_mpa_hdr_ac_assgns;
  compare_mpa_hdr_assgns;
  compare_line_adr_assgns;
  compare_line_ac_assgns;
  compare_jld_jlt_assgns;
  compare_jlds;

  -- compare header assignments
  compare_jld_assgns;
  compare_hdr_ac_assgns;
  compare_hdr_acct_attrs;
  compare_header_assgns;

  -- compare aads
  compare_aads;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analyze_aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_analysis_pvt.analyze_aads'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'Unhandled exception');
  RAISE;

END analyze_aads;



--=============================================================================
--
-- Name: group_aads
-- Description: This API groups the AAD with the same group number if they
--              shares any commom components.  The group number information is
--              stored in the g_aad_groups global array.
--
--=============================================================================
/*
PROCEDURE group_aads
IS
  l_curr_group_num     INTEGER;

  -- Cursor to return all AADs to be grouped
  CURSOR c_aad IS
    SELECT product_rule_type_code
          ,product_rule_code
          ,decode(min(decode(amb_context_code,g_amb_context_code,1,2)),1,'Y','N') required_flag
      FROM xla_product_rules_b
     WHERE application_id   = g_application_id
       AND amb_context_code IN (g_amb_context_code,g_staging_context_code)
     GROUP BY product_rule_type_code, product_rule_code;

  -- Cursor to return AADs that shares any common component with the AADs that
  -- was assigned with the group l_curr_group_num
  CURSOR c_aad_group IS
  SELECT h.product_rule_type_code, h.product_rule_code
    FROM xla_prod_acct_headers h
   WHERE h.application_id      = g_application_id
     AND h.amb_context_code    IN (g_amb_context_code,g_staging_context_code)
     AND EXISTS (SELECT 1
                   FROM xla_prod_acct_headers pah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE pah.application_id         = g_application_id
                    AND pah.amb_context_code       IN (g_amb_context_code,g_staging_context_code)
                    AND pah.description_type_code  = h.description_type_code
                    AND pah.description_code       = h.description_code
                    AND pah.product_rule_type_code = grp.product_rule_type_code
                    AND pah.product_rule_code      = grp.product_rule_code
                    AND grp.group_num              = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = g_application_id
                    AND xjl.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xal.application_id             = g_application_id
                    AND xal.amb_context_code           = xjl.amb_context_code
                    AND xal.product_rule_type_code     = grp.product_rule_type_code
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num)
   UNION
  SELECT xal.product_rule_type_code, xal.product_rule_code
    FROM xla_line_defn_jlt_assgns h
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND h.application_id             = g_application_id
     AND h.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
     AND EXISTS (SELECT 1
                   FROM xla_prod_acct_headers pah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE pah.application_id         = g_application_id
                    AND pah.amb_context_code       IN (g_amb_context_code,g_staging_context_code)
                    AND pah.description_type_code  = h.description_type_code
                    AND pah.description_code       = h.description_code
                    AND pah.product_rule_type_code = grp.product_rule_type_code
                    AND pah.product_rule_code      = grp.product_rule_code
                    AND grp.group_num              = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_aad_line_defn_assgns xal
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = g_application_id
                    AND xjl.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
                    AND xjl.description_type_code      = h.description_type_code
                    AND xjl.description_code           = h.description_code
                    AND xal.application_id             = xjl.application_id
                    AND xal.amb_context_code           = xjl.amb_context_code
                    AND xal.product_rule_type_code     = grp.product_rule_type_code
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND xal.event_class_code           = xjl.event_class_code
                    AND xal.event_type_code            = xjl.event_type_code
                    AND xal.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xal.line_definition_code       = xjl.line_definition_code
                    AND grp.group_num                  = l_curr_group_num)
  UNION
  SELECT xal.product_rule_type_code, xal.product_rule_code
    FROM xla_line_defn_jlt_assgns h
        ,xla_aad_line_defn_assgns xal
   WHERE h.application_id             = xal.application_id
     AND h.amb_context_code           = xal.amb_context_code
     AND h.event_class_code           = xal.event_class_code
     AND h.event_type_code            = xal.event_type_code
     AND h.line_definition_owner_code = xal.line_definition_owner_code
     AND h.line_definition_code       = xal.line_definition_code
     AND h.application_id             = g_application_id
     AND h.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
     AND EXISTS (SELECT 1
                   FROM xla_aad_line_defn_assgns xad
                       ,xla_line_defn_jlt_assgns xjl
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xjl.application_id             = g_application_id
                    AND xjl.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
                    AND xjl.event_class_code           = h.event_class_code
                    AND xjl.accounting_line_type_code  = h.accounting_line_type_code
                    AND xjl.accounting_line_code       = h.accounting_line_code
                    AND xad.event_class_code           = xjl.event_class_code
                    AND xad.event_type_code            = xjl.event_type_code
                    AND xad.line_definition_owner_code = xjl.line_definition_owner_code
                    AND xad.line_definition_code       = xjl.line_definition_code
                    AND xad.application_id             = xjl.application_id
                    AND xad.amb_context_code           = xjl.amb_context_code
                    AND xad.product_rule_type_code     = grp.product_rule_type_code
                    AND xad.product_rule_code          = grp.product_rule_code
                    AND grp.group_num                  = l_curr_group_num)
  UNION
  SELECT h.product_rule_type_code, h.product_rule_code
    FROM xla_aad_header_ac_assgns h
   WHERE h.application_id      = g_application_id
     AND h.amb_context_code    IN (g_amb_context_code,g_staging_context_code)
     AND EXISTS (SELECT 1
                   FROM xla_aad_header_ac_assgns xah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xah.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND xah.analytical_criterion_code      = h.analytical_criterion_code
                    AND xah.application_id                 = g_application_id
                    AND xah.amb_context_code               IN (g_amb_context_code,g_staging_context_code)
                    AND xah.product_rule_type_code         = grp.product_rule_type_code
                    AND xah.product_rule_code              = grp.product_rule_code
                    AND grp.group_num                      = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_line_defn_ac_assgns  xac
                       ,xla_aad_line_defn_assgns xal
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xac.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND xac.analytical_criterion_code      = h.analytical_criterion_code
                    AND xac.amb_context_code               IN (g_amb_context_code,g_staging_context_code)
                    AND xac.application_id                 = g_application_id
                    AND xac.event_class_code               = xal.event_class_code
                    AND xac.event_type_code                = xal.event_type_code
                    AND xac.line_definition_owner_code     = xal.line_definition_owner_code
                    AND xac.line_definition_code           = xal.line_definition_code
                    AND xal.application_id                 = xac.application_id
                    AND xal.amb_context_code               = xac.amb_context_code
                    AND xal.product_rule_type_code         = grp.product_rule_type_code
                    AND xal.product_rule_code              = grp.product_rule_code
                    AND grp.group_num                      = l_curr_group_num)
   UNION
  SELECT xad.product_rule_type_code, xad.product_rule_code
    FROM xla_line_defn_ac_assgns  h
        ,xla_aad_line_defn_assgns xad
   WHERE h.application_id             = xad.application_id
     AND h.amb_context_code           = xad.amb_context_code
     AND h.event_class_code           = xad.event_class_code
     AND h.event_type_code            = xad.event_type_code
     AND h.line_definition_owner_code = xad.line_definition_owner_code
     AND h.line_definition_code       = xad.line_definition_code
     AND xad.application_id           = g_application_id
     AND xad.amb_context_code         = g_amb_context_code
     AND EXISTS (SELECT 1
                   FROM xla_aad_header_ac_assgns xah
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xah.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND xah.analytical_criterion_code      = h.analytical_criterion_code
                    AND xah.amb_context_code               IN (g_amb_context_code,g_staging_context_code)
                    AND xah.application_id                 = g_application_id
                    AND xah.product_rule_type_code         = grp.product_rule_type_code
                    AND xah.product_rule_code              = grp.product_rule_code
                    AND grp.group_num                      = l_curr_group_num
                  UNION
                 SELECT 1
                   FROM xla_line_defn_ac_assgns  xac
                       ,xla_aad_line_defn_assgns xal
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xac.analytical_criterion_type_code = h.analytical_criterion_type_code
                    AND xac.analytical_criterion_code      = h.analytical_criterion_code
                    AND xac.amb_context_code               IN (g_amb_context_code,g_staging_context_code)
                    AND xac.application_id                 = g_application_id
                    AND xac.event_class_code               = xal.event_class_code
                    AND xac.event_type_code                = xal.event_type_code
                    AND xac.line_definition_owner_code     = xal.line_definition_owner_code
                    AND xac.line_definition_code           = xal.line_definition_code
                    AND xal.application_id                 = xac.application_id
                    AND xal.amb_context_code               = xac.amb_context_code
                    AND xal.product_rule_type_code         = grp.product_rule_type_code
                    AND xal.product_rule_code              = grp.product_rule_code
                    AND grp.group_num                      = l_curr_group_num)
  UNION
  SELECT xad.product_rule_type_code, xad.product_rule_code
    FROM xla_line_defn_adr_assgns h
        ,xla_aad_line_defn_assgns xad
   WHERE h.application_id             = xad.application_id
     AND h.amb_context_code           = xad.amb_context_code
     AND h.event_class_code           = xad.event_class_code
     AND h.event_type_code            = xad.event_type_code
     AND h.line_definition_owner_code = xad.line_definition_owner_code
     AND h.line_definition_code       = xad.line_definition_code
     AND h.application_id             = g_application_id
     AND h.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
     AND EXISTS (SELECT 1
                   FROM xla_line_defn_adr_assgns xac
                       ,xla_aad_line_defn_assgns xal
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xac.application_id             = g_application_id
                    AND xac.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
                    AND xac.segment_rule_type_code     = h.segment_rule_type_code
                    AND xac.segment_rule_code          = h.segment_rule_code
                    AND xac.event_class_code           = xal.event_class_code
                    AND xac.event_type_code            = xal.event_type_code
                    AND xac.line_definition_owner_code = xal.line_definition_owner_code
                    AND xac.line_definition_code       = xal.line_definition_code
                    AND xal.application_id             = xac.application_id
                    AND xal.amb_context_code           = xac.amb_context_code
                    AND xal.product_rule_type_code     = grp.product_rule_type_code
                    AND xal.product_rule_code          = grp.product_rule_code
                    AND grp.group_num                  = l_curr_group_num)
  UNION
  SELECT xal.product_rule_type_code, xal.product_rule_code
    FROM xla_line_defn_adr_assgns adr
        ,xla_aad_line_defn_assgns xal
        ,xla_seg_rule_details     xsr
   WHERE xal.application_id             = adr.application_id
     AND xal.amb_context_code           = adr.amb_context_code
     AND xal.event_class_code           = adr.event_class_code
     AND xal.event_type_code            = adr.event_type_code
     AND xal.line_definition_owner_code = adr.line_definition_owner_code
     AND xal.line_definition_code       = adr.line_definition_code
     AND adr.application_id             = xsr.application_id
     AND adr.amb_context_code           = xsr.amb_context_code
     AND adr.segment_rule_type_code     = xsr.segment_rule_type_code
     AND adr.segment_rule_code          = xsr.segment_rule_code
     AND xsr.application_id             = g_application_id
     AND xsr.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
     AND EXISTS (SELECT 1
                   FROM xla_line_defn_adr_assgns adr2
                       ,xla_aad_line_defn_assgns xal2
                       ,xla_seg_rule_details     xsr2
                       ,TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type)) grp
                  WHERE xsr2.value_mapping_set_code     = xsr.value_mapping_set_code
                    AND xsr2.application_id             = adr2.application_id
                    AND xsr2.amb_context_code           = adr2.amb_context_code
                    AND xsr2.segment_rule_type_code     = adr2.segment_rule_type_code
                    AND xsr2.segment_rule_code          = adr2.segment_rule_code
                    AND adr2.application_id             = xal2.application_id
                    AND adr2.amb_context_code           = xal2.amb_context_code
                    AND adr2.event_class_code           = xal2.event_class_code
                    AND adr2.event_type_code            = xal2.event_type_code
                    AND adr2.line_definition_owner_code = xal2.line_definition_owner_code
                    AND adr2.line_definition_code       = xal2.line_definition_code
                    AND xal2.application_id             = g_application_id
                    AND xal2.amb_context_code           IN (g_amb_context_code,g_staging_context_code)
                    AND xal2.product_rule_type_code     = grp.product_rule_type_code
                    AND xal2.product_rule_code          = grp.product_rule_code
                    AND grp.group_num                   = l_curr_group_num);

  -- Cursor to return the next AAD that is not grouped
  CURSOR c_next_aad IS
    SELECT product_rule_type_code, product_rule_code
      FROM TABLE(CAST(g_aad_groups AS xla_aad_group_tbl_type))
     WHERE group_num = 0;

  l_aad_group        xla_aad_group_rec_type;
  l_updated          BOOLEAN;
  l_type_code        VARCHAR2(30);
  l_code             VARCHAR2(30);
  l_count            INTEGER;
  l_log_module       VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.group_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'BEGIN of procedure group_aads'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  g_aad_groups := xla_aad_group_tbl_type();

  l_count := 0;
  l_curr_group_num := 1;

  -- Initialize the AAD array
  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - retrieve AADs',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  FOR l_aad IN c_aad LOOP
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - AAD:'||
                        ' product_rule_type_code='||l_aad.product_rule_type_code||
                        ',product_rule_code='||l_aad.product_rule_code||
                        ',required_flag='||l_aad.required_flag
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_ERROR);
    END IF;

    l_aad_group := xla_aad_group_rec_type
                      (l_aad.product_rule_type_code
                      ,l_aad.product_rule_code
                      ,0
                      ,NULL
                      ,NULL
                      ,NULL
                      ,l_aad.required_flag);

    l_count := l_count + 1;
    g_aad_groups.EXTEND;
    g_aad_groups(l_count) := l_aad_group;
  END LOOP;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - retrieve AADs',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  -- Assign group #1 to the first AAD
  IF (g_aad_groups.COUNT > 0) THEN
    g_aad_groups(1).group_num := l_curr_group_num;
  END IF;

  --
  -- Loop until all application accounting definitions are assigned
  -- with a group number
  --
  LOOP
    IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace(p_msg    => 'LOOP - current group number = '||l_curr_group_num,
            p_module => l_log_module,
            p_level  => C_LEVEL_ERROR);
    END IF;
    --
    -- Loop until no more new application accounting definitions is
    -- found to be sharing any journal entry setups with the
    -- definitions in the current group.
    --
    LOOP
      OPEN c_aad_group;
      l_updated := FALSE;

      --
      -- Loop until all application accounting definitions that
      -- shares journal entry sets with the definitions in the
      -- current group are marked with the current group number.
      LOOP
        FETCH c_aad_group INTO l_type_code, l_code;
        EXIT WHEN c_aad_group%NOTFOUND;

        IF (update_group_number(l_type_code
                               ,l_code
                               ,l_curr_group_num)) THEN
          l_updated := TRUE;
        END IF;
      END LOOP;
      CLOSE c_aad_group;
      IF (NOT l_updated) THEN
        EXIT;
      END IF;
    END LOOP;

    OPEN c_next_aad;
    FETCH c_next_aad INTO l_type_code, l_code;
    EXIT WHEN c_next_aad%NOTFOUND;

    CLOSE c_next_aad;
    l_curr_group_num := l_curr_group_num + 1;
    l_updated := update_group_number(l_type_code
                                    ,l_code
                                    ,l_curr_group_num);
  END LOOP;
  CLOSE c_next_aad;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    FOR i IN 1 .. g_aad_groups.COUNT LOOP
      trace(p_msg    => 'group='||g_aad_groups(i).group_num||
                        ' '||g_aad_groups(i).product_rule_code
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_PROCEDURE);
    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure group_aads'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_aad_merge_analysis_pvt.group_aads');

END group_aads;


--=============================================================================
--
-- Name:
-- Description:
--
--=============================================================================
PROCEDURE analyze_merge_dependency
(p_application_id    INTEGER
,p_amb_context_code  VARCHAR2)
IS
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analyze_merge_dependency';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure analyze_merge_dependency',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure analyze_merge_dependency',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_aad_merge_analysis_pvt.analyze_merge_dependency');

END analyze_merge_dependency;
*/

--=============================================================================
---- Name:
-- Description:
--
--=============================================================================
PROCEDURE post_analysis
IS
  l_merge_impact  VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.post_analysis';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure post_analysis',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  INSERT INTO xla_amb_updated_comps
    (amb_updated_comp_id
    ,application_id
    ,amb_context_code
    ,component_type_code
    ,component_key
    ,parent_component_type_code
    ,parent_component_key
    ,merge_impact_code
    ,event_class_code
    ,event_type_code
    ,component_owner_code
    ,component_code
    ,parent_component_owner_code
    ,parent_component_code
    ,property_code
    ,old_value
    ,old_source_app_id
    ,old_source_type_code
    ,old_source_code
    ,new_value
    ,new_source_app_id
    ,new_source_type_code
    ,new_source_code
    ,lookup_type
    ,merge_enabled_flag
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,program_update_date
    ,program_application_id
    ,program_id
    ,request_id)
    SELECT xla_amb_updated_comps_s.nextval
          ,g_application_id
          ,g_amb_context_code
          ,component_type
          ,component_key
          ,parent_component_type
          ,parent_component_key
          ,merge_impact
          ,event_class_code
          ,event_type_code
          ,component_owner_code
          ,component_code
          ,parent_component_owner_code
          ,parent_component_code
          ,property
          ,old_value
          ,old_source_app_id
          ,old_source_type_code
          ,old_source_code
          ,new_value
          ,new_source_app_id
          ,new_source_type_code
          ,new_source_code
          ,lookup_type
          ,'N'
          ,1
          ,sysdate
          ,xla_environment_pkg.g_usr_id
          ,sysdate
          ,xla_environment_pkg.g_usr_id
          ,xla_environment_pkg.g_login_id
          ,sysdate
          ,xla_environment_pkg.g_prog_appl_id
          ,xla_environment_pkg.g_prog_id
          ,xla_environment_pkg.g_req_Id
      FROM (SELECT component_type
                  ,component_key
                  ,parent_component_type
                  ,parent_component_key
                  ,merge_impact
                  ,event_class_code
                  ,event_type_code
                  ,component_owner_code
                  ,component_code
                  ,parent_component_owner_code
                  ,parent_component_code
                  ,NULL property
                  ,NULL old_value
                  ,NULL old_source_app_id
                  ,NULL old_source_type_code
                  ,NULL old_source_code
                  ,NULL new_value
                  ,NULL new_source_app_id
                  ,NULL new_source_type_code
                  ,NULL new_source_code
                  ,NULL lookup_type
              FROM TABLE(CAST(g_updated_comps AS xla_amb_updated_comp_tbl_type))
             UNION
            SELECT NULL
                  ,NULL
                  ,component_type
                  ,component_key
                  ,C_MERGE_IMPACT_UPDATED
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,property
                  ,old_value
                  ,old_source_app_id
                  ,old_source_type_code
                  ,old_source_code
                  ,new_value
                  ,new_source_app_id
                  ,new_source_type_code
                  ,new_source_code
                  ,lookup_type
              FROM TABLE(CAST(g_updated_props AS xla_amb_updated_prop_tbl_type)));

  IF (SQL%ROWCOUNT > 0) THEN
    l_merge_impact := C_MERGE_IMPACT_UPDATED;
  ELSE
    l_merge_impact := C_MERGE_IMPACT_UNCHANGED;
  END IF;

  INSERT INTO xla_amb_updated_comps
      (amb_updated_comp_id
      ,application_id
      ,amb_context_code
      ,component_type_code
      ,component_key
      ,merge_impact_code
      ,merge_enabled_flag
      ,object_version_number
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,program_update_date
      ,program_application_id
      ,program_id
      ,request_id)
    SELECT xla_amb_updated_comps_s.nextval
          ,g_application_id
          ,g_amb_context_code
          ,'APPLICATION'
          ,TO_CHAR(g_application_id)
          ,l_merge_impact
          ,'N'
          ,1
          ,sysdate
          ,xla_environment_pkg.g_usr_id
          ,sysdate
          ,xla_environment_pkg.g_usr_id
          ,xla_environment_pkg.g_login_id
          ,sysdate
          ,xla_environment_pkg.g_prog_appl_id
          ,xla_environment_pkg.g_prog_id
          ,xla_environment_pkg.g_req_Id
      FROM DUAL;

  UPDATE xla_appli_amb_contexts
     SET updated_flag       = 'N'
       , batch_name         = g_batch_name
       , last_analyzed_date = sysdate
       , last_update_date   = sysdate
       , last_updated_by    = xla_environment_pkg.g_usr_id
       , last_update_login  = xla_environment_pkg.g_login_id
   WHERE application_id     = g_application_id
     AND amb_context_code   = g_amb_context_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure post_analysis',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_aad_merge_analysis_pvt.post_analysis');

END post_analysis;

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
PROCEDURE analysis
(p_api_version        IN NUMBER
,x_return_status      IN OUT NOCOPY VARCHAR2
,p_application_id     INTEGER
,p_amb_context_code   VARCHAR2
,p_batch_name         VARCHAR2
,x_analysis_status    IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'analysis';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_staging_context_code VARCHAR2(30);
  l_retcode              VARCHAR2(30);
  l_log_module           VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analysis';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analysis: '||
                      'p_batch_name = '||p_batch_name,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  l_staging_context_code := xla_aad_loader_util_pvt.get_staging_context_code
                                (p_application_id   => p_application_id
                                ,p_amb_context_code => p_amb_context_code);

  xla_aad_merge_analysis_pvt.analysis
             (p_api_version          => p_api_version
             ,x_return_status        => x_return_status
             ,p_application_id       => p_application_id
             ,p_amb_context_code     => p_amb_context_code
             ,p_staging_context_code => l_staging_context_code
             ,p_batch_name           => p_batch_name
             ,x_analysis_status      => x_analysis_status);

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analysis - Return value = '||x_analysis_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
RAISE;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_analysis_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
RAISE;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_analysis_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
RAISE;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_analysis_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_analysis_pvt.analysis'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');


END analysis;


--=============================================================================
--
-- Name:
-- Description:
--
--=============================================================================
PROCEDURE analysis
(p_api_version          IN NUMBER
,x_return_status        IN OUT NOCOPY VARCHAR2
,p_application_id       INTEGER
,p_amb_context_code     VARCHAR2
,p_staging_context_code VARCHAR2
,p_batch_name           VARCHAR2
,x_analysis_status      IN OUT NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'analysis';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_retcode       VARCHAR2(30);
  l_log_module    VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.analysis';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function analysis: '||
                      'p_batch_name = '||p_batch_name,
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
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --  Initialize global variables
  x_return_status        := FND_API.G_RET_STS_SUCCESS;

  g_application_id       := p_application_id;
  g_amb_context_code     := p_amb_context_code;
  g_staging_context_code := p_staging_context_code;
  g_batch_name           := p_batch_name;
  g_user_mode            := NVL(fnd_profile.value('XLA_SETUP_USER_MODE'),'C');

  g_num_updated_comps    := 0;
  g_num_updated_props    := 0;

  -- API Logic
  x_analysis_status := pre_analysis;
  IF (x_analysis_status = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_analysis_status := validation;
  IF (x_analysis_status = 'ERROR') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  analyze_aads;
  post_analysis;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function analysis - Return value = '||x_analysis_status,
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
RAISE;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  x_analysis_status := 'ERROR';

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK;
RAISE;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_analysis_status := 'ERROR';

WHEN OTHERS THEN
  ROLLBACK;
RAISE;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  x_analysis_status := 'ERROR';

  xla_aad_loader_util_pvt.stack_error
               (p_appli_s_name    => 'XLA'
               ,p_msg_name        => 'XLA_COMMON_ERROR'
               ,p_token_1         => 'LOCATION'
               ,p_value_1         => 'xla_aad_merge_analysis_pvt.analysis'
               ,p_token_2         => 'ERROR'
               ,p_value_2         => 'unhandled exception');


END analysis;

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

END xla_aad_merge_analysis_pvt;

/

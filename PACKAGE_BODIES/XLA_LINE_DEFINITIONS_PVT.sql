--------------------------------------------------------
--  DDL for Package Body XLA_LINE_DEFINITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_LINE_DEFINITIONS_PVT" AS
/* $Header: xlaamjld.pkb 120.37.12000000.3 2007/06/12 07:12:47 svellani ship $ */

-------------------------------------------------------------------------------
-- declaring global types
-------------------------------------------------------------------------------
TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_line_definitions_pvt';

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
      (p_location   => 'xla_line_definitions_pvt.trace');
END trace;


--=============================================================================
--
--
--
--
--          *********** private procedures and functions **********
--
--
--
--
--=============================================================================


--=============================================================================
--
-- Name: invalid_line_ac
-- Description: Returns true if sources for the analytical criteria invalid
--
--=============================================================================
FUNCTION invalid_line_ac
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_ac_type_code                     IN VARCHAR2
  ,p_ac_code                          IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return                  BOOLEAN;
  l_exist                   VARCHAR2(1);

  CURSOR c_event_sources IS
    SELECT 'x'
      FROM xla_analytical_sources  a
     WHERE application_id                 = p_application_id
       AND amb_context_code               = p_amb_context_code
       AND entity_code                    = p_entity_code
       AND event_class_code               = p_event_class_code
       AND analytical_criterion_code      = p_ac_code
       AND analytical_criterion_type_code = p_ac_type_code;

  CURSOR c_line_analytical IS
    SELECT 'X'
      FROM xla_analytical_sources  a
     WHERE application_id                 = p_application_id
       AND amb_context_code               = p_amb_context_code
       AND entity_code                    = p_entity_code
       AND event_class_code               = p_event_class_code
       AND analytical_criterion_code      = p_ac_code
       AND analytical_criterion_type_code = p_ac_type_code
       AND source_type_code               = 'S'
       AND not exists (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = a.source_application_id
                          AND s.source_type_code      = a.source_type_code
                          AND s.source_code           = a.source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y');

  CURSOR c_analytical_der_sources IS
    SELECT source_code, source_type_code
      FROM xla_analytical_sources  a
     WHERE application_id                = p_application_id
       AND amb_context_code              = p_amb_context_code
       AND entity_code                   = p_entity_code
       AND event_class_code              = p_event_class_code
       AND analytical_criterion_code      = p_ac_code
       AND analytical_criterion_type_code = p_ac_type_code
       AND a.source_type_code            = 'D';

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.invalid_line_ac';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure invalid_line_ac'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',analytical_criterion_type_code = '||p_ac_type_code||
                      ',analytical_criterion_code = '||p_ac_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_event_sources;
  FETCH c_event_sources INTO l_exist;
  IF c_event_sources%found then
    l_return := FALSE;
  ELSE
    l_return := TRUE;
  END IF;
  CLOSE c_event_sources;

  IF l_return = FALSE THEN
    OPEN c_line_analytical;
    FETCH c_line_analytical INTO l_exist;
    IF c_line_analytical%found then
      l_return := TRUE;
    ELSE
      l_return := FALSE;
    END IF;
    CLOSE c_line_analytical;
  END IF;

  --
  -- check analytical criteria has derived sources that do not belong to the event class
  --
  IF l_return = FALSE THEN
    FOR l_source IN c_analytical_der_sources LOOP
      EXIT WHEN l_return = TRUE;

      IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_source.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

        l_return := TRUE;
      ELSE
        l_return := FALSE;
      END IF;
    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure invalid_line_ac'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_event_sources%ISOPEN) THEN
      CLOSE c_event_sources;
    END IF;
    IF (c_line_analytical%ISOPEN) THEN
      CLOSE c_line_analytical;
    END IF;
    IF (c_analytical_der_sources%ISOPEN) THEN
      CLOSE c_analytical_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF (c_event_sources%ISOPEN) THEN
      CLOSE c_event_sources;
    END IF;
    IF (c_line_analytical%ISOPEN) THEN
      CLOSE c_line_analytical;
    END IF;
    IF (c_analytical_der_sources%ISOPEN) THEN
      CLOSE c_analytical_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.invalid_line_ac');

END invalid_line_ac;

--=============================================================================
--
-- Name: invalid_line_desc
-- Description: Returns true if sources for the line description are invalid
--
--=============================================================================
FUNCTION invalid_line_desc
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return          BOOLEAN;
  l_exist           VARCHAR2(1);

  CURSOR c_desc_detail_sources IS
    SELECT 'X'
      FROM xla_descript_details_b d, xla_desc_priorities p
     WHERE d.description_prio_id   = p.description_prio_id
       AND p.application_id        = p_application_id
       AND p.amb_context_code      = p_amb_context_code
       AND p.description_type_code = p_description_type_code
       AND p.description_code      = p_description_code
       AND d.source_code           IS NOT NULL
       AND d.source_type_code      = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = d.source_application_id
                          AND s.source_type_code      = d.source_type_code
                          AND s.source_code           = d.source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y');

  CURSOR c_desc_condition_sources IS
    SELECT 'X'
      FROM xla_conditions c, xla_desc_priorities d
     WHERE c.description_prio_id   = d.description_prio_id
       AND d.application_id        = p_application_id
       AND d.amb_context_code      = p_amb_context_code
       AND d.description_type_code = p_description_type_code
       AND d.description_code      = p_description_code
       AND c.source_code           IS NOT NULL
       AND c.source_type_code      = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = c.source_application_id
                          AND s.source_type_code      = c.source_type_code
                          AND s.source_code           = c.source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y')
    UNION
    SELECT 'X' source_code
      FROM xla_conditions c, xla_desc_priorities d
     WHERE c.description_prio_id     = d.description_prio_id
       AND d.application_id          = p_application_id
       AND d.amb_context_code        = p_amb_context_code
       AND d.description_type_code   = p_description_type_code
       AND d.description_code        = p_description_code
       AND c.value_source_code       IS NOT NULL
       AND c.value_source_type_code  = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = c.value_source_application_id
                          AND s.source_type_code      = c.value_source_type_code
                          AND s.source_code           = c.value_source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y');

  CURSOR c_desc_detail_der_sources IS
    SELECT source_type_code, source_code
      FROM xla_descript_details_b d, xla_desc_priorities p
     WHERE d.description_prio_id   = p.description_prio_id
       AND p.application_id        = p_application_id
       AND p.amb_context_code      = p_amb_context_code
       AND p.description_type_code = p_description_type_code
       AND p.description_code      = p_description_code
       AND d.source_code           IS NOT NULL
       AND d.source_type_code      = 'D';

  CURSOR c_desc_condition_der_sources IS
    SELECT source_type_code source_type_code, source_code source_code
      FROM xla_conditions c, xla_desc_priorities d
     WHERE c.description_prio_id   = d.description_prio_id
       AND d.application_id        = p_application_id
       AND d.amb_context_code      = p_amb_context_code
       AND d.description_type_code = p_description_type_code
       AND d.description_code      = p_description_code
       AND c.source_code           IS NOT NULL
       AND c.source_type_code      = 'D'
    UNION
    SELECT value_source_type_code source_type_code, value_source_code source_code
      FROM xla_conditions c, xla_desc_priorities d
     WHERE c.description_prio_id     = d.description_prio_id
       AND d.application_id          = p_application_id
       AND d.amb_context_code        = p_amb_context_code
       AND d.description_type_code   = p_description_type_code
       AND d.description_code        = p_description_code
       AND c.value_source_code       IS NOT NULL
       AND c.value_source_type_code  = 'D';

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.invalid_line_desc';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure invalid_line_desc'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',description_type_code = '||p_description_type_code||
                      ',description_code = '||p_description_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- check description has sources that do not belong to the event class
  --
  OPEN c_desc_detail_sources;
  FETCH c_desc_detail_sources INTO l_exist;
  IF c_desc_detail_sources%found then
    l_return := TRUE;
  ELSE
    l_return := FALSE;
  END IF;
  CLOSE c_desc_detail_sources;

  IF l_return = FALSE THEN
    OPEN c_desc_condition_sources;
    FETCH c_desc_condition_sources INTO l_exist;
    IF c_desc_condition_sources%found then
      l_return := TRUE;
    ELSE
      l_return := FALSE;
    END IF;
    CLOSE c_desc_condition_sources;
  END IF;

  --
  -- check description has derived sources that do not belong to the event class
  --
  IF l_return = FALSE THEN
    FOR l_source IN c_desc_detail_der_sources LOOP
      EXIT WHEN l_return = TRUE;

      IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_source.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

        l_return := TRUE;
      ELSE
        l_return := FALSE;
      END IF;
    END LOOP;
  END IF;

  IF l_return = FALSE THEN
    FOR l_source IN c_desc_condition_der_sources LOOP
      EXIT WHEN l_return = TRUE;

      IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_source.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

        l_return := TRUE;
      ELSE
        l_return := FALSE;
      END IF;
    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure invalid_line_desc'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_desc_condition_sources%ISOPEN THEN
      CLOSE c_desc_condition_sources;
    END IF;
    IF c_desc_detail_sources%ISOPEN THEN
      CLOSE c_desc_detail_sources;
    END IF;
    IF c_desc_condition_der_sources%ISOPEN THEN
      CLOSE c_desc_condition_der_sources;
    END IF;
    IF c_desc_detail_der_sources%ISOPEN THEN
      CLOSE c_desc_detail_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF c_desc_condition_sources%ISOPEN THEN
      CLOSE c_desc_condition_sources;
    END IF;
    IF c_desc_detail_sources%ISOPEN THEN
      CLOSE c_desc_detail_sources;
    END IF;
    IF c_desc_condition_der_sources%ISOPEN THEN
      CLOSE c_desc_condition_der_sources;
    END IF;
    IF c_desc_detail_der_sources%ISOPEN THEN
      CLOSE c_desc_detail_der_sources;
    END IF;

    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.invalid_line_desc');

END invalid_line_desc;

--=============================================================================
--
-- Name: invalid_seg_rule
-- Description: Returns true if sources for the segment rule are invalid
--
--=============================================================================
FUNCTION invalid_seg_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_segment_rule_appl_id             IN NUMBER   DEFAULT NULL
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return          BOOLEAN;
  l_exist           VARCHAR2(1);

  CURSOR c_seg_details IS
    SELECT 'x'
      FROM xla_seg_rule_details d
     WHERE application_id         = NVL(p_segment_rule_appl_id
                                       ,p_application_id)
       AND amb_context_code       = p_amb_context_code
       AND segment_rule_type_code = p_segment_rule_type_code
       AND segment_rule_code      = p_segment_rule_code;

  CURSOR c_seg_value_sources IS
    SELECT 'x'
      FROM xla_seg_rule_details d
     WHERE application_id         = NVL(p_segment_rule_appl_id
                                       ,p_application_id)
       AND amb_context_code       = p_amb_context_code
       AND segment_rule_type_code = p_segment_rule_type_code
       AND segment_rule_code      = p_segment_rule_code
       AND value_source_code      IS NOT NULL
       AND value_source_type_code = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = d.value_source_application_id
                          AND s.source_type_code      = d.value_source_type_code
                          AND s.source_code           = d.value_source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y')
    UNION
    SELECT 'x'
      FROM xla_seg_rule_details d
     WHERE application_id         = NVL(p_segment_rule_appl_id
                                       ,p_application_id)
       AND amb_context_code       = p_amb_context_code
       AND segment_rule_type_code = p_segment_rule_type_code
       AND segment_rule_code      = p_segment_rule_code
       AND input_source_code      IS NOT NULL
       AND input_source_type_code = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = d.input_source_application_id
                          AND s.source_type_code      = d.input_source_type_code
                          AND s.source_code           = d.input_source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y');

  CURSOR c_seg_condition_sources IS
    SELECT 'x'
      FROM xla_conditions c, xla_seg_rule_details d
     WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
       AND d.application_id         = NVL(p_segment_rule_appl_id
                                         ,p_application_id)
       AND d.amb_context_code       = p_amb_context_code
       AND d.segment_rule_type_code = p_segment_rule_type_code
       AND d.segment_rule_code      = p_segment_rule_code
       AND c.source_code            IS NOT NULL
       AND c.source_type_code       = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = c.source_application_id
                          AND s.source_type_code      = c.source_type_code
                          AND s.source_code           = c.source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y')
    UNION
    SELECT 'x'
      FROM xla_conditions c, xla_seg_rule_details d
     WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
       AND d.application_id         = NVL(p_segment_rule_appl_id
                                         ,p_application_id)
       AND d.amb_context_code       = p_amb_context_code
       AND d.segment_rule_type_code = p_segment_rule_type_code
       AND d.segment_rule_code      = p_segment_rule_code
       AND c.value_source_code      IS NOT NULL
       AND c.value_source_type_code = 'S'
       AND NOT EXISTS (SELECT 'y'
                         FROM xla_event_sources s
                        WHERE s.source_application_id = c.value_source_application_id
                          AND s.source_type_code      = c.value_source_type_code
                          AND s.source_code           = c.value_source_code
                          AND s.application_id        = p_application_id
                          AND s.entity_code           = p_entity_code
                          AND s.event_class_code      = p_event_class_code
                          AND s.active_flag          = 'Y');

  CURSOR c_seg_value_der_sources IS
    SELECT value_source_type_code source_type_code, value_source_code source_code
      FROM xla_seg_rule_details d
     WHERE application_id         = NVL(p_segment_rule_appl_id,
                                        p_application_id)
       AND amb_context_code       = p_amb_context_code
       AND segment_rule_type_code = p_segment_rule_type_code
       AND segment_rule_code      = p_segment_rule_code
       AND value_source_code      IS NOT NULL
       AND value_source_type_code = 'D'
    UNION
    SELECT input_source_type_code source_type_code, input_source_code source_code
      FROM xla_seg_rule_details d
     WHERE application_id         = NVL(p_segment_rule_appl_id,
                                        p_application_id)
       AND amb_context_code       = p_amb_context_code
       AND segment_rule_type_code = p_segment_rule_type_code
       AND segment_rule_code      = p_segment_rule_code
       AND input_source_code      IS NOT NULL
       AND input_source_type_code = 'D';

  CURSOR c_seg_condition_der_sources IS
    SELECT c.source_type_code source_type_code, c.source_code source_code
      FROM xla_conditions c, xla_seg_rule_details d
     WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
       AND d.application_id         = NVL(p_segment_rule_appl_id
                                         ,p_application_id)
       AND d.amb_context_code       = p_amb_context_code
       AND d.segment_rule_type_code = p_segment_rule_type_code
       AND d.segment_rule_code      = p_segment_rule_code
       AND c.source_code            IS NOT NULL
       AND c.source_type_code       = 'D'
    UNION
    SELECT c.value_source_type_code source_type_code, c.value_source_code source_code
      FROM xla_conditions c, xla_seg_rule_details d
     WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
       AND d.application_id         = NVL(p_segment_rule_appl_id
                                         ,p_application_id)
       AND d.amb_context_code       = p_amb_context_code
       AND d.segment_rule_type_code = p_segment_rule_type_code
       AND d.segment_rule_code      = p_segment_rule_code
       AND c.value_source_code      IS NOT NULL
       AND c.value_source_type_code = 'D';

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.invalid_seg_rule';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure invalid_seg_rule'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',segment_rule_appl_id = '||p_segment_rule_appl_id||
                      ',segment_rule_type_code = '||p_segment_rule_type_code||
                      ',segment_rule_code = '||p_segment_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- check if segment rules has details existing
  --
  OPEN c_seg_details;
  FETCH c_seg_details INTO l_exist;
  IF c_seg_details%notfound then
    l_return := TRUE;
  ELSE
    l_return := FALSE;
  END IF;
  CLOSE c_seg_details;

  IF l_return = FALSE THEN
    --
    -- check if segment rules has sources that do not belong to the event class
    --
    OPEN c_seg_value_sources;
    FETCH c_seg_value_sources INTO l_exist;
      IF c_seg_value_sources%found then
        l_return := TRUE;
      ELSE
        l_return := FALSE;
      END IF;
    CLOSE c_seg_value_sources;
  END IF;

  IF l_return = FALSE THEN
    OPEN c_seg_condition_sources;
    FETCH c_seg_condition_sources INTO l_exist;
    IF c_seg_condition_sources%found then
      l_return := TRUE;
    ELSE
      l_return := FALSE;
    END IF;
    CLOSE c_seg_condition_sources;
  END IF;

  IF l_return = FALSE THEN
    FOR l_source IN c_seg_value_der_sources LOOP
      EXIT WHEN l_return = TRUE;

      IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_source.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

         l_return := TRUE;
       ELSE
         l_return := FALSE;
       END IF;
     END LOOP;
   END IF;

   IF l_return = FALSE THEN
     FOR l_source IN c_seg_condition_der_sources LOOP
       EXIT WHEN l_return = TRUE;

       IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_source.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

          l_return := TRUE;
       ELSE
          l_return := FALSE;
       END IF;
     END LOOP;
   END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure invalid_seg_rule'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_seg_details%ISOPEN THEN
      CLOSE c_seg_details;
    END IF;
    IF c_seg_condition_sources%ISOPEN THEN
      CLOSE c_seg_condition_sources;
    END IF;
    IF c_seg_value_sources%ISOPEN THEN
      CLOSE c_seg_value_sources;
    END IF;
    IF c_seg_condition_der_sources%ISOPEN THEN
      CLOSE c_seg_condition_der_sources;
    END IF;
    IF c_seg_value_der_sources%ISOPEN THEN
      CLOSE c_seg_value_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_seg_details%ISOPEN THEN
      CLOSE c_seg_details;
    END IF;
    IF c_seg_condition_sources%ISOPEN THEN
      CLOSE c_seg_condition_sources;
    END IF;
    IF c_seg_value_sources%ISOPEN THEN
      CLOSE c_seg_value_sources;
    END IF;
    IF c_seg_condition_der_sources%ISOPEN THEN
      CLOSE c_seg_condition_der_sources;
    END IF;
    IF c_seg_value_der_sources%ISOPEN THEN
      CLOSE c_seg_value_der_sources;
    END IF;

    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.invalid_seg_rule');

END invalid_seg_rule;


--=============================================================================
--
-- Name: chk_adr_side_is_valid
-- Description: Validate if any JLT assignment that does not have a valid
--              side_code associaged
-- Return Value:
--   TRUE - if the side_codes of all ADR assignments are valid
--   FALSE - if the side_code of any ADR assignment is invalid
--
--=============================================================================
FUNCTION chk_adr_side_is_valid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get debit/credit line assignments that contains debit/credit/all
  -- side_code adr assignment and gain_loss line assignments that contains
  -- 'NA' side_code
  --
  CURSOR c_invalid_side_code IS
    SELECT distinct xlj.accounting_line_type_code, xlj.accounting_line_code
      FROM xla_line_defn_jlt_assgns xlj
           , xla_acct_line_types_b xalt
           , xla_line_defn_adr_assgns xld
     WHERE xlj.application_id             = p_application_id
       AND xlj.amb_context_code           = p_amb_context_code
       AND xlj.event_class_code           = p_event_class_code
       AND xlj.event_type_code            = p_event_type_code
       AND xlj.line_definition_owner_code = p_line_definition_owner_code
       AND xlj.line_definition_code       = p_line_definition_code
       AND xalt.accounting_line_type_code = xlj.accounting_line_type_code
       AND xalt.accounting_line_code      = xlj.accounting_line_code
       AND xalt.event_class_code          = xlj.event_class_code
       AND xalt.application_id            = xlj.application_id
       AND xalt.amb_context_code          = xlj.amb_context_code
       AND xlj.application_id             = xld.application_id
       AND xlj.amb_context_code           = xld.amb_context_code
       AND xlj.event_class_code           = xld.event_class_code
       AND xlj.event_type_code            = xld.event_type_code
       AND xlj.line_definition_owner_code = xld.line_definition_owner_code
       AND xlj.line_definition_code       = xld.line_definition_code
       AND xlj.accounting_line_type_code  = xld.accounting_line_type_code
       AND xlj.accounting_line_code       = xld.accounting_line_code
       AND ((xalt.natural_side_code       = 'G' AND xld.side_code ='NA')
            OR (xalt.natural_side_code    <>'G' AND xld.side_code <> 'NA'));

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_adr_side_is_valid';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_adr_side_is_valid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_adr_assgns IN c_invalid_side_code LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_WRONG_SIDE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_ASSIGNMENT'
              ,p_category_sequence          => 9
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_adr_assgns.accounting_line_type_code
              ,p_accounting_line_code       => l_adr_assgns.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_adr_side_is_valid'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_side_code%ISOPEN THEN
      CLOSE c_invalid_side_code;
    END IF;
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_adr_side_is_valid');
END chk_adr_side_is_valid;

--=============================================================================
--=============================================================================
--
-- Name: chk_adr_assgns_is_complete
-- Description: Validate if any JLT assignment that does not contain flexfield
--              assignment and does not have complete segment assignments
--              There are two types of ADR assignment - Regular, and ADR for
--              non-upgrade entries (for Federal only.)  For non-upgrade case,
--              the JLT must be a prior entry JLT.
--              All JLT assignment that is not for prior entry must have ADR
--              assignment. (For prior entry, ADR assignment may exist for
--              upgrade ADR for federal.)
--              If there is ADR assignment, it must be complete.
-- Return Value:
--   TRUE - if all ADR assignments are valid
--   FALSE - if any ADR assignment is invalid
--
--=============================================================================
FUNCTION chk_adr_assgns_is_complete
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_coa_id IS
    SELECT xld.accounting_coa_id
      FROM xla_line_definitions_b xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code;

  -- For JLT assignment of non-prior-entry JLT, there must be ADR assignment.
  CURSOR c_invalid_no_adr IS
    SELECT distinct xlj.accounting_line_type_code, xlj.accounting_line_code
      FROM xla_line_defn_jlt_assgns xlj
          ,xla_acct_line_types_b jlt
     WHERE xlj.application_id             = p_application_id
       AND xlj.amb_context_code           = p_amb_context_code
       AND xlj.event_class_code           = p_event_class_code
       AND xlj.event_type_code            = p_event_type_code
       AND xlj.line_definition_owner_code = p_line_definition_owner_code
       AND xlj.line_definition_code       = p_line_definition_code
       AND xlj.active_flag                = 'Y'
       AND xlj.application_id             = jlt.application_id
       AND xlj.amb_context_code           = jlt.amb_context_code
       AND xlj.event_class_code           = jlt.event_class_code
       AND xlj.accounting_line_type_code  = jlt.accounting_line_type_code
       AND xlj.accounting_line_code       = jlt.accounting_line_code
       AND jlt.business_method_code      <> 'PRIOR_ENTRY'
       AND NOT EXISTS
                 (SELECT 1 FROM xla_line_defn_adr_assgns xad1
                   WHERE xlj.application_id             = xad1.application_id
                     AND xlj.amb_context_code           = xad1.amb_context_code
                     AND xlj.event_class_code           = xad1.event_class_code
                     AND xlj.event_type_code            = xad1.event_type_code
                     AND xlj.line_definition_owner_code = xad1.line_definition_owner_code
                     AND xlj.line_definition_code       = xad1.line_definition_code
                     AND xlj.accounting_line_type_code  = xad1.accounting_line_type_code
                     AND xlj.accounting_line_code       = xad1.accounting_line_code);


  --
  -- If ADR assignment exists, the ADR assignment must be complete
  --
  CURSOR c_invalid_adrs_no_coa IS
    SELECT distinct xlj.accounting_line_type_code, xlj.accounting_line_code
      FROM xla_line_defn_jlt_assgns xlj
          --,xla_acct_line_types_b jlt
     WHERE xlj.application_id             = p_application_id
       AND xlj.amb_context_code           = p_amb_context_code
       AND xlj.event_class_code           = p_event_class_code
       AND xlj.event_type_code            = p_event_type_code
       AND xlj.line_definition_owner_code = p_line_definition_owner_code
       AND xlj.line_definition_code       = p_line_definition_code
       AND xlj.active_flag                = 'Y'
       --AND xlj.application_id             = jlt.application_id
       --AND xlj.amb_context_code           = jlt.amb_context_code
       --AND xlj.event_class_code           = jlt.event_class_code
       --AND xlj.accounting_line_type_code  = jlt.accounting_line_type_code
       --AND xlj.accounting_line_code       = jlt.accounting_line_code
       --AND jlt.business_method_code      <> 'PRIOR_ENTRY'
       AND EXISTS (SELECT 1 FROM xla_line_defn_adr_assgns xad1
                   WHERE xlj.application_id             = xad1.application_id
                     AND xlj.amb_context_code           = xad1.amb_context_code
                     AND xlj.event_class_code           = xad1.event_class_code
                     AND xlj.event_type_code            = xad1.event_type_code
                     AND xlj.line_definition_owner_code = xad1.line_definition_owner_code
                     AND xlj.line_definition_code       = xad1.line_definition_code
                     AND xlj.accounting_line_type_code  = xad1.accounting_line_type_code
                     AND xlj.accounting_line_code       = xad1.accounting_line_code )
       AND 2<>
           (SELECT nvl(sum(decode(side_code, 'ALL', 2, 'NA', 2, 1)), 0)
              FROM xla_line_defn_adr_assgns xad
             WHERE xlj.application_id             = xad.application_id
               AND xlj.amb_context_code           = xad.amb_context_code
               AND xlj.event_class_code           = xad.event_class_code
               AND xlj.event_type_code            = xad.event_type_code
               AND xlj.line_definition_owner_code = xad.line_definition_owner_code
               AND xlj.line_definition_code       = xad.line_definition_code
               AND xlj.accounting_line_type_code  = xad.accounting_line_type_code
               AND xlj.accounting_line_code       = xad.accounting_line_code
               AND xad.flexfield_segment_code     = 'ALL');

  l_coa_id      INTEGER;

  --
  -- If ADR assignment exists, it must be complete.
  --
  CURSOR c_invalid_adrs IS
    SELECT distinct xlj.accounting_line_type_code, xlj.accounting_line_code
      FROM xla_line_defn_jlt_assgns xlj
          ,fnd_id_flex_segments_vl  fif
   --       , xla_acct_line_types_b jlt
     WHERE fif.application_id             = 101
       AND fif.id_flex_code               = 'GL#'
       AND fif.id_flex_num                = l_coa_id
       AND fif.enabled_flag               = 'Y'
       AND xlj.application_id             = p_application_id
       AND xlj.amb_context_code           = p_amb_context_code
       AND xlj.event_class_code           = p_event_class_code
       AND xlj.event_type_code            = p_event_type_code
       AND xlj.line_definition_owner_code = p_line_definition_owner_code
       AND xlj.line_definition_code       = p_line_definition_code
       AND xlj.active_flag                = 'Y'
--       AND xlj.application_id             = jlt.application_id
--       AND xlj.amb_context_code           = jlt.amb_context_code
--       AND xlj.event_class_code           = jlt.event_class_code
--       AND xlj.accounting_line_type_code  = jlt.accounting_line_type_code
--       AND xlj.accounting_line_code       = jlt.accounting_line_code
--       AND jlt.business_method_code      <> 'PRIOR_ENTRY'     -- Bug 4922099
       AND EXISTS (SELECT 1 FROM xla_line_defn_adr_assgns xad1
                   WHERE xlj.application_id             = xad1.application_id
                     AND xlj.amb_context_code           = xad1.amb_context_code
                     AND xlj.event_class_code           = xad1.event_class_code
                     AND xlj.event_type_code            = xad1.event_type_code
                     AND xlj.line_definition_owner_code = xad1.line_definition_owner_code
                     AND xlj.line_definition_code       = xad1.line_definition_code
                     AND xlj.accounting_line_type_code  = xad1.accounting_line_type_code
                     AND xlj.accounting_line_code       = xad1.accounting_line_code )
       AND (
         (NOT EXISTS
           (SELECT 'Y'
              FROM xla_line_defn_adr_assgns xad
             WHERE xlj.application_id             = xad.application_id
               AND xlj.amb_context_code           = xad.amb_context_code
               AND xlj.event_class_code           = xad.event_class_code
               AND xlj.event_type_code            = xad.event_type_code
               AND xlj.line_definition_owner_code = xad.line_definition_owner_code
               AND xlj.line_definition_code       = xad.line_definition_code
               AND xlj.accounting_line_type_code  = xad.accounting_line_type_code
               AND xlj.accounting_line_code       = xad.accounting_line_code
               AND xad.flexfield_segment_code     = fif.application_column_name
               AND xad.side_code in ('NA', 'CREDIT', 'ALL'))
          AND NOT EXISTS
           (SELECT 'Y'
              FROM xla_line_defn_adr_assgns xad
             WHERE xlj.application_id             = xad.application_id
               AND xlj.amb_context_code           = xad.amb_context_code
               AND xlj.event_class_code           = xad.event_class_code
               AND xlj.event_type_code            = xad.event_type_code
               AND xlj.line_definition_owner_code = xad.line_definition_owner_code
               AND xlj.line_definition_code       = xad.line_definition_code
               AND xlj.accounting_line_type_code  = xad.accounting_line_type_code
               AND xlj.accounting_line_code       = xad.accounting_line_code
               AND xad.flexfield_segment_code     = 'ALL'
               AND xad.side_code in ('NA', 'CREDIT', 'ALL')))
         OR ( NOT EXISTS
           (SELECT 'Y'
              FROM xla_line_defn_adr_assgns xad
             WHERE xlj.application_id             = xad.application_id
               AND xlj.amb_context_code           = xad.amb_context_code
               AND xlj.event_class_code           = xad.event_class_code
               AND xlj.event_type_code            = xad.event_type_code
               AND xlj.line_definition_owner_code = xad.line_definition_owner_code
               AND xlj.line_definition_code       = xad.line_definition_code
               AND xlj.accounting_line_type_code  = xad.accounting_line_type_code
               AND xlj.accounting_line_code       = xad.accounting_line_code
               AND xad.flexfield_segment_code     = fif.application_column_name
               AND xad.side_code in ('NA', 'DEBIT', 'ALL'))
          AND NOT EXISTS
           (SELECT 'Y'
              FROM xla_line_defn_adr_assgns xad
             WHERE xlj.application_id             = xad.application_id
               AND xlj.amb_context_code           = xad.amb_context_code
               AND xlj.event_class_code           = xad.event_class_code
               AND xlj.event_type_code            = xad.event_type_code
               AND xlj.line_definition_owner_code = xad.line_definition_owner_code
               AND xlj.line_definition_code       = xad.line_definition_code
               AND xlj.accounting_line_type_code  = xad.accounting_line_type_code
               AND xlj.accounting_line_code       = xad.accounting_line_code
               AND xad.flexfield_segment_code     = 'ALL'
               AND xad.side_code in ('NA', 'DEBIT', 'ALL'))));

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_adr_assgns_is_complete';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_adr_assgns_is_complete'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_adr_assgns IN c_invalid_no_adr LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_INCOMPLETE_ACCT'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_ASSIGNMENT'
              ,p_category_sequence          => 9
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_adr_assgns.accounting_line_type_code
              ,p_accounting_line_code       => l_adr_assgns.accounting_line_code);
  END LOOP;

  OPEN c_coa_id;
  FETCH c_coa_id INTO l_coa_id;
  CLOSE c_coa_id;

  IF (l_coa_id IS NULL) THEN
    --
    -- Check if all JLT assignments contain ADR assignments
    --
    FOR l_adr_assgns IN c_invalid_adrs_no_coa LOOP
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_INCOMPLETE_ACCT'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_ASSIGNMENT'
              ,p_category_sequence          => 9
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_adr_assgns.accounting_line_type_code
              ,p_accounting_line_code       => l_adr_assgns.accounting_line_code);
    END LOOP;
  ELSE
    FOR l_adr_assgns IN c_invalid_adrs LOOP
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_INCOMPLETE_ACCT'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_ASSIGNMENT'
              ,p_category_sequence          => 9
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_adr_assgns.accounting_line_type_code
              ,p_accounting_line_code       => l_adr_assgns.accounting_line_code);
    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_adr_assgns_is_complete'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_adr_assgns_is_complete');
END chk_adr_assgns_is_complete;

--=============================================================================
--
-- Name: chk_adr_is_enabled
-- Description:
--
--=============================================================================
FUNCTION chk_adr_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_adrs IS
    SELECT distinct xsr.segment_rule_type_code, xsr.segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_line_defn_adr_assgns xad
          ,xla_seg_rules_b          xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.enabled_flag               <> 'Y'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y';

  CURSOR c_adr IS
    SELECT distinct xsr.application_id, xsr.amb_context_code,
                    xsr.segment_rule_type_code, xsr.segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_line_defn_adr_assgns xad
          ,xla_seg_rules_b          xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y';

    l_adr     c_adr%rowtype;

    CURSOR c_invalid_child_adr IS
    SELECT xsd.value_segment_rule_type_code, xsd.value_segment_rule_code
      FROM xla_seg_rule_details xsd
          ,xla_seg_rules_b      xsr
     WHERE xsd.application_id                   = l_adr.application_id
       AND xsd.amb_context_code                 = l_adr.amb_context_code
       AND xsd.segment_rule_type_code           = l_adr.segment_rule_type_code
       AND xsd.segment_rule_code                = l_adr.segment_rule_code
       AND xsd.value_type_code                  = 'A'
       AND xsd.value_segment_rule_appl_id   = xsr.application_id
       AND xsd.value_segment_rule_type_code = xsr.segment_rule_type_code
       AND xsd.value_segment_rule_code      = xsr.segment_rule_code
       AND xsd.amb_context_code             = xsr.amb_context_code
       AND xsr.enabled_flag                <> 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_adr_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_adr_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_adrs LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_DISABLD_SEG_RULE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code);

  END LOOP;

  OPEN c_adr;
  LOOP
     FETCH c_adr
      INTO l_adr;
     EXIT WHEN c_adr%notfound;

     FOR l_child_adr IN c_invalid_child_adr LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_DISABLD_SEG_RULE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.value_segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.value_segment_rule_code);

     END LOOP;
  END LOOP;
  CLOSE c_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_adr_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_adr_is_enabled');
END chk_adr_is_enabled;

--=============================================================================
--
-- Name: chk_adr_has_details
-- Description:
--
--=============================================================================
FUNCTION chk_adr_has_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_adrs IS
   SELECT distinct xad.segment_rule_code, xad.segment_rule_type_code
     FROM xla_line_defn_adr_assgns xad, xla_line_defn_jlt_assgns xjl
    WHERE xad.application_id             = xjl.application_id
      AND xad.amb_context_code           = xjl.amb_context_code
      AND xad.event_class_code           = xjl.event_class_code
      AND xad.event_type_code            = xjl.event_type_code
      AND xad.line_definition_code       = xjl.line_definition_code
      AND xad.line_definition_owner_code = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
      AND xad.accounting_line_code       = xjl.accounting_line_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xad.segment_rule_code          is not null
      AND NOT EXISTS
          (SELECT 'x'
             FROM xla_seg_rule_details xsr
            WHERE xsr.application_id         = NVL(xad.segment_rule_appl_id,xad.application_id)
              AND xsr.amb_context_code       = xad.amb_context_code
              AND xsr.segment_rule_type_code = xad.segment_rule_type_code
              AND xsr.segment_rule_code      = xad.segment_rule_code);

  CURSOR c_adr IS
    SELECT distinct xsr.application_id, xsr.amb_context_code,
                    xsr.segment_rule_type_code, xsr.segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_line_defn_adr_assgns xad
          ,xla_seg_rules_b          xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y';

    l_adr     c_adr%rowtype;

    CURSOR c_invalid_child_adr IS
    SELECT xsd.value_segment_rule_type_code, xsd.value_segment_rule_code
      FROM xla_seg_rule_details xsd
     WHERE xsd.application_id                   = l_adr.application_id
       AND xsd.amb_context_code                 = l_adr.amb_context_code
       AND xsd.segment_rule_type_code           = l_adr.segment_rule_type_code
       AND xsd.segment_rule_code                = l_adr.segment_rule_code
       AND xsd.value_type_code                  = 'A'
       AND not exists (SELECT 'x'
                         FROM xla_seg_rule_details xcd
                        WHERE xcd.application_id                   = xsd.value_segment_rule_appl_id
                          AND xcd.amb_context_code                 = xsd.amb_context_code
                          AND xcd.segment_rule_type_code           = xsd.value_segment_rule_type_code
                          AND xcd.segment_rule_code                = xsd.value_segment_rule_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_adr_has_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_adr_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_adrs LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code);
  END LOOP;

  OPEN c_adr;
  LOOP
     FETCH c_adr
      INTO l_adr;
     EXIT WHEN c_adr%notfound;

     FOR l_child_adr IN c_invalid_child_adr LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.value_segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.value_segment_rule_code);
     END LOOP;
  END LOOP;
  CLOSE c_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_adr_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_adr_has_details');
END chk_adr_has_details;


--=============================================================================
--
-- Name: chk_adr_invalid_source_in_cond
-- Description: Check if all sources used in the ADR condition is valid
--
--=============================================================================
FUNCTION chk_adr_invalid_source_in_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code, xco.source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.source_type_code            = 'S'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                 = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id        = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.value_source_type_code      = 'S'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                 = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_cond_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.source_type_code            = 'D'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                   = 'Y'
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.value_source_type_code      = 'D'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                   = 'Y';

  CURSOR c_child_adr IS
    SELECT distinct xsr.segment_rule_type_code, xsr.segment_rule_code,
                    xsr.value_segment_rule_appl_id,
                    xsr.value_segment_rule_type_code, xsr.value_segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_line_defn_adr_assgns xad
          ,xla_seg_rule_details    xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.value_type_code            = 'A'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y';

  l_child_adr     c_child_adr%rowtype;

  CURSOR c_invalid_child_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code, xco.source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.source_type_code            = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id        = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.value_source_type_code      = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_child_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.source_type_code            = 'D'
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.value_source_type_code      = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_adr_invalid_source_in_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_adr_invalid_source_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_CON_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_cond_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_CON_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
     END IF;
   END LOOP;

  OPEN c_child_adr;
  LOOP
     FETCH c_child_adr
      INTO l_child_adr;
     EXIT WHEN c_child_adr%notfound;

     FOR l_err IN c_invalid_child_sources LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_REF_RULE_COND'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.segment_rule_code);
     END LOOP;

     FOR l_err IN c_child_der_sources LOOP
       IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

         l_return := FALSE;
         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_REF_RULE_COND'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.segment_rule_code);
       END IF;
     END LOOP;
  END LOOP;
  CLOSE c_child_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_adr_invalid_source_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_cond_der_sources%ISOPEN THEN
      CLOSE c_cond_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_cond_der_sources%ISOPEN THEN
      CLOSE c_cond_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_adr_invalid_source_in_cond');
END chk_adr_invalid_source_in_cond;



--=============================================================================
--
-- Name: chk_adr_source_event_class
-- Description: Check if all JLT of the line definition has all required
--              accounting sources assigned
--
--=============================================================================
FUNCTION chk_adr_source_event_class
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT for which not all required line accounting sources are assigned
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id             = xad.application_id
      AND xsr.amb_context_code           = xad.amb_context_code
      AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
      AND xsr.segment_rule_code          = xad.segment_rule_code
      AND xsr.value_source_type_code     = 'S'
      AND xad.application_id             = xjl.application_id
      AND xad.amb_context_code           = xjl.amb_context_code
      AND xad.line_definition_code       = xjl.line_definition_code
      AND xad.event_class_code           = xjl.event_class_code
      AND xad.event_type_code            = xjl.event_type_code
      AND xad.line_definition_owner_code = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
      AND xad.accounting_line_code       = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.value_source_application_id
              AND xes.source_type_code      = xsr.value_source_type_code
              AND xes.source_code           = xsr.value_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id             = xad.application_id
      AND xsr.amb_context_code           = xad.amb_context_code
      AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
      AND xsr.segment_rule_code          = xad.segment_rule_code
      AND xsr.input_source_type_code     = 'S'
      AND xad.application_id             = xjl.application_id
      AND xad.amb_context_code           = xjl.amb_context_code
      AND xad.line_definition_code       = xjl.line_definition_code
      AND xad.event_class_code           = xjl.event_class_code
      AND xad.event_type_code            = xjl.event_type_code
      AND xad.line_definition_owner_code = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
      AND xad.accounting_line_code       = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.input_source_application_id
              AND xes.source_type_code      = xsr.input_source_type_code
              AND xes.source_code           = xsr.input_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id                = xad.application_id
      AND xsr.amb_context_code              = xad.amb_context_code
      AND xsr.segment_rule_type_code        = xad.segment_rule_type_code
      AND xsr.segment_rule_code             = xad.segment_rule_code
      AND xsr.value_source_type_code        = 'D'
      AND xad.application_id                = xjl.application_id
      AND xad.amb_context_code              = xjl.amb_context_code
      AND xad.event_class_code              = xjl.event_class_code
      AND xad.event_type_code               = xjl.event_type_code
      AND xad.line_definition_code          = xjl.line_definition_code
      AND xad.line_definition_owner_code    = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code     = xjl.accounting_line_type_code
      AND xad.accounting_line_code          = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id                = p_application_id
      AND xjl.amb_context_code              = p_amb_context_code
      AND xjl.line_definition_owner_code    = p_line_definition_owner_code
      AND xjl.line_definition_code          = p_line_definition_code
      AND xjl.active_flag                   = 'Y'
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id                = xad.application_id
      AND xsr.amb_context_code              = xad.amb_context_code
      AND xsr.segment_rule_type_code        = xad.segment_rule_type_code
      AND xsr.segment_rule_code             = xad.segment_rule_code
      AND xsr.input_source_type_code        = 'D'
      AND xad.application_id                = xjl.application_id
      AND xad.amb_context_code              = xjl.amb_context_code
      AND xad.event_class_code              = xjl.event_class_code
      AND xad.event_type_code               = xjl.event_type_code
      AND xad.line_definition_code          = xjl.line_definition_code
      AND xad.line_definition_owner_code    = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code     = xjl.accounting_line_type_code
      AND xad.accounting_line_code          = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id                = p_application_id
      AND xjl.amb_context_code              = p_amb_context_code
      AND xjl.line_definition_owner_code    = p_line_definition_owner_code
      AND xjl.line_definition_code          = p_line_definition_code
      AND xjl.active_flag                   = 'Y';


  CURSOR c_child_adr IS
    SELECT distinct xsr.segment_rule_type_code, xsr.segment_rule_code,
                    xsr.value_segment_rule_appl_id,
                    xsr.value_segment_rule_type_code, xsr.value_segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_line_defn_adr_assgns xad
          ,xla_seg_rule_details    xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.value_type_code            = 'A'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y';

  l_child_adr     c_child_adr%rowtype;

  CURSOR c_invalid_child_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.value_source_type_code     = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.value_source_application_id
              AND xes.source_type_code      = xsr.value_source_type_code
              AND xes.source_code           = xsr.value_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.input_source_type_code     = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.input_source_application_id
              AND xes.source_type_code      = xsr.input_source_type_code
              AND xes.source_code           = xsr.input_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y');

  CURSOR c_child_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.value_source_type_code        = 'D'
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.input_source_type_code        = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_adr_source_event_class';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_adr_source_event_class'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any JLT does not have all required line accounting sources
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_UNASSN_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;
      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_UNASSN_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
    END IF;
  END LOOP;


  OPEN c_child_adr;
  LOOP
     FETCH c_child_adr
      INTO l_child_adr;
     EXIT WHEN c_child_adr%notfound;

     FOR l_err IN c_invalid_child_sources LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_REF_RULE_DET'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.segment_rule_code);
     END LOOP;

     FOR l_err IN c_child_der_sources LOOP
       IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

         l_return := FALSE;
         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_SR_REF_RULE_DET'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.segment_rule_code);
       END IF;
     END LOOP;
  END LOOP;
  CLOSE c_child_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_adr_source_event_class'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_der_sources%ISOPEN THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_der_sources%ISOPEN THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_adr_source_event_class');

END chk_adr_source_event_class;


--=============================================================================
--
-- Name: validate_adr_assgns
-- Description: Validate all ADR assigned to the JLT of the line definition
--              is valid
-- Return Value:
--   TRUE - if all ADR assignments are valid
--   FALSE - if any ADR assignment is invalid
--
--=============================================================================
FUNCTION validate_adr_assgns
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_adr_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_adr_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return :=chk_adr_side_is_valid
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_adr_assgns_is_complete
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_adr_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_adr_has_details
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_adr_invalid_source_in_cond
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_adr_source_event_class
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_adr_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_adr_assgns');
END validate_adr_assgns;


--=============================================================================
--
-- Name: chk_jlt_exists
-- Description: Check if at least one active JLT is assigned to the line definition
--
--=============================================================================
FUNCTION chk_jlt_exists
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT assignment that has a disabled JLT
  --
  CURSOR c_active_line_assgns IS
  SELECT  'X'
     FROM xla_line_defn_jlt_assgns    xld
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y';

  l_return      BOOLEAN;
  l_exists      VARCHAR2(1);
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_exists';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if at least one active JLT is assigned to the line definition
  --
  OPEN c_active_line_assgns;
  FETCH c_active_line_assgns INTO l_exists;
  IF (c_active_line_assgns%NOTFOUND) THEN
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_LESS_LINE_TYPES_JLD'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_ASSIGNMENT'
            ,p_category_sequence          => 9
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code);
  END IF;
  CLOSE c_active_line_assgns;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_active_line_assgns%ISOPEN) THEN
      CLOSE c_active_line_assgns;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_active_line_assgns%ISOPEN) THEN
      CLOSE c_active_line_assgns;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_exists');
END chk_jlt_exists;

--=============================================================================
--
-- Name: chk_jlt_is_enabled
-- Description: Check if all JLT assigned to the line definition is enabled
--
--=============================================================================
FUNCTION chk_jlt_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT assignment that has a disabled JLT
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct event_class_code, event_type_code,
          accounting_line_type_code, accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_acct_line_types_b xal
            WHERE xal.application_id             = xld.application_id
              AND xal.amb_context_code           = xld.amb_context_code
              AND xal.event_class_code           = xld.event_class_code
              AND xal.accounting_line_type_code  = xld.accounting_line_type_code
              AND xal.accounting_line_code       = xld.accounting_line_code
              AND xal.enabled_flag               = 'Y');

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_DISABLD_LINE_TYPE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_is_enabled');
END chk_jlt_is_enabled;

--=============================================================================
--
-- Name: chk_jlt_encum_type_exists
-- Description: Check if all encumbrance type of the JLTs assigned to the
--              line definition contain encumrbance type id
--
--=============================================================================
FUNCTION chk_jlt_encum_type_exists
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any encumbrance JLT that doesn't have an encumbrance
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
        , xla_acct_line_types_b       xal
    WHERE xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.enabled_flag               = 'Y'
      AND xal.accounting_entry_type_code = 'E'
      AND NVL(xal.business_method_code,'NONE') <> 'PRIOR_ENTRY'
      AND xal.encumbrance_type_id        IS NULL
      AND xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_encum_type_exists';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_encum_type_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_INVALID_NO_ENCUM_TYPE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_encum_type_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_encum_type_exists');
END chk_jlt_encum_type_exists;

--=============================================================================
--
-- Name: chk_jlt_acct_class_exists
-- Description: Check if all accounting class of the JLTs assigned to the
--              line definition are enabled
--
--=============================================================================
FUNCTION chk_jlt_acct_class_exists
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT that the accounting class does not exist in the lookup
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
        , xla_acct_line_types_b       xal
    WHERE xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.enabled_flag               = 'Y'
      AND xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_lookups xlk
            WHERE xlk.lookup_type             = 'XLA_ACCOUNTING_CLASS'
              AND xlk.lookup_code             = xal.accounting_class_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_acct_class_exists';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_acct_class_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_INVALID_ACCT_CLASS'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_acct_class_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_acct_class_exists');
END chk_jlt_acct_class_exists;

--=============================================================================
--
-- Name: chk_jlt_rounding_class_exists
-- Description: Check if all rounding class of the JLTs assigned to the
--              line definition are enabled
--
--=============================================================================
FUNCTION chk_jlt_rounding_class_exists
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT where its rounding class does not exist in the lookup
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
        , xla_acct_line_types_b       xal
    WHERE xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.enabled_flag               = 'Y'
      AND xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_lookups xlk
            WHERE xlk.lookup_type             = 'XLA_ACCOUNTING_CLASS'
              AND xlk.lookup_code             = xal.rounding_class_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_rounding_class_exists';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_rounding_class_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_INVALID_ROUNDING_CLASS'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_rounding_class_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_rounding_class_exists');
END chk_jlt_rounding_class_exists;

--=============================================================================
--
-- Name: chk_jlt_bflow_class_exists
-- Description: Check if all business flow class of the JLTs assigned to the
--              line definition are enabled
--
--=============================================================================
FUNCTION chk_jlt_bflow_class_exists
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT that's business flow class does not exists in the lookup
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
        , xla_acct_line_types_b       xal
    WHERE xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.enabled_flag               = 'Y'
      AND xal.business_class_code        IS NOT NULL
      AND xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_lookups xlk
            WHERE xlk.lookup_type             = 'XLA_BUSINESS_FLOW_CLASS'
              AND xlk.lookup_code             = xal.business_class_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_bflow_class_exists';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_bflow_class_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_INVALID_BFLOW_CLASS'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_bflow_class_exists'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_bflow_class_exists');
END chk_jlt_bflow_class_exists;

--=============================================================================
--
-- Name: chk_jlt_business_class
-- Description: Check if all JLT assignments has correct business class
--
--=============================================================================
FUNCTION chk_jlt_business_class
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT assignment that has a business flow method of 'NONE'
  -- and have inherit_desc_flag set to 'Y'
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct event_class_code, event_type_code,
          accounting_line_type_code, accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.inherit_desc_flag          = 'Y'
      AND EXISTS
          (SELECT 'y'
             FROM xla_acct_line_types_b xal
            WHERE xal.application_id             = xld.application_id
              AND xal.amb_context_code           = xld.amb_context_code
              AND xal.event_class_code           = xld.event_class_code
              AND xal.accounting_line_type_code  = xld.accounting_line_type_code
              AND xal.accounting_line_code       = xld.accounting_line_code
              AND xal.business_method_code       = 'NONE');

  --
  -- Bug 4922099
  -- NOTE: ADR's can be attached to Business Flow JLTs, hence following validation needs to be removed.
  --

/*
  --
  -- Get any JLT assignment that has a business flow method of 'PRIOR_ENTRY'
  -- and has ADRs assigned to it.
  --
  CURSOR c_pe_adr_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b xal
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.business_method_code       = 'PRIOR_ENTRY'
      AND EXISTS
          (SELECT 'y'
             FROM xla_line_defn_adr_assgns adr
            WHERE adr.application_id             = xld.application_id
              AND adr.amb_context_code           = xld.amb_context_code
              AND adr.event_class_code           = xld.event_class_code
              AND adr.event_type_code            = xld.event_type_code
              AND adr.line_definition_owner_code = xld.line_definition_owner_code
              AND adr.line_definition_code       = xld.line_definition_code
              AND adr.accounting_line_type_code  = xld.accounting_line_type_code
              AND adr.accounting_line_code       = xld.accounting_line_code);
*/

  --
  -- Get any JLT assignment that has a business flow method of 'PRIOR_ENTRY'
  -- and has analytical criteria assigned to it.
  --
  CURSOR c_pe_ac_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b xal
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.business_method_code       = 'PRIOR_ENTRY'
      AND EXISTS
          (SELECT 'y'
             FROM xla_line_defn_ac_assgns adr
            WHERE adr.application_id             = xld.application_id
              AND adr.amb_context_code           = xld.amb_context_code
              AND adr.event_class_code           = xld.event_class_code
              AND adr.event_type_code            = xld.event_type_code
              AND adr.line_definition_owner_code = xld.line_definition_owner_code
              AND adr.line_definition_code       = xld.line_definition_code
              AND adr.accounting_line_type_code  = xld.accounting_line_type_code
              AND adr.accounting_line_code       = xld.accounting_line_code);

  --
  -- Get any JLT assignment that has a business flow method of 'NONE'
  -- and has inherit_adr_flag set to 'Y'
  --
  CURSOR c_se_adr_jlt IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b xal
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.business_method_code       = 'NONE'
      AND EXISTS
          (SELECT 'y'
             FROM xla_line_defn_adr_assgns adr
            WHERE adr.application_id             = xld.application_id
              AND adr.amb_context_code           = xld.amb_context_code
              AND adr.event_class_code           = xld.event_class_code
              AND adr.event_type_code            = xld.event_type_code
              AND adr.line_definition_owner_code = xld.line_definition_owner_code
              AND adr.line_definition_code       = xld.line_definition_code
              AND adr.accounting_line_type_code  = xld.accounting_line_type_code
              AND adr.accounting_line_code       = xld.accounting_line_code
              AND adr.inherit_adr_flag           = 'Y');

  --
  -- Get any JLT assignment that has an invalid business flow class
  --
  CURSOR c_invalid_class IS
  SELECT  distinct xld.event_class_code, xld.event_type_code,
          xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b xal
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.business_class_code        IS NOT NULL
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_lookups lkp
            WHERE lkp.lookup_code                = xal.business_class_code
              AND lkp.lookup_type                = 'XLA_BUSINESS_FLOW_CLASS'
              AND lkp.enabled_flag               = 'Y'
              AND lkp.end_date_active            IS NULL);


  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_business_class';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any JLT that has business flow method of 'NONE'
  -- is assigned to the line definition with inherit_desc_flag = 'Y'
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_NO_SAME_PRIOR_LINE_TYPE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  --
  -- Bug 4922099
  -- ADRs can be attached to Business flow JLTs, hence following validation needs to be removed .
  --
/*
  FOR l_err IN c_pe_adr_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_PRIOR_LINE_TYPE_ADR'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;
*/

  FOR l_err IN c_pe_ac_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_PRIOR_LINE_TYPE_AC'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  FOR l_err IN c_se_adr_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_NO_SAME_LINE_TYPE_ADR'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  FOR l_err IN c_invalid_class LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_INVALID_BUS_FLOW_CLASS'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_business_class'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_class%ISOPEN THEN
      CLOSE c_invalid_class;
    END IF;
    IF c_se_adr_jlt%ISOPEN THEN
      CLOSE c_se_adr_jlt;
    END IF;
-- Bug 4922099
/*
    IF c_pe_adr_jlt%ISOPEN THEN
      CLOSE c_pe_adr_jlt;
    END IF;
*/
    IF c_pe_ac_jlt%ISOPEN THEN
      CLOSE c_pe_ac_jlt;
    END IF;
    IF c_invalid_jlt%ISOPEN THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS   THEN
    IF c_invalid_class%ISOPEN THEN
      CLOSE c_invalid_class;
    END IF;
    IF c_se_adr_jlt%ISOPEN THEN
      CLOSE c_se_adr_jlt;
    END IF;
-- Bug 4922099
/*
    IF c_pe_adr_jlt%ISOPEN THEN
      CLOSE c_pe_adr_jlt;
    END IF;
*/
    IF c_pe_ac_jlt%ISOPEN THEN
      CLOSE c_pe_ac_jlt;
    END IF;
    IF c_invalid_jlt%ISOPEN THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_business_class');
END chk_jlt_business_class;


--=============================================================================
--
-- Name: chk_jld_same_entry
-- Description: Check if all JLT assignments has correct business class
--
--=============================================================================
FUNCTION chk_jld_same_entry
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT assignment that has a business flow method of 'NONE'
  -- and have inherit_desc_flag set to 'Y'
  --
  CURSOR c_same_entry_jlt_debit IS
  SELECT  'x'
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b xal
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.business_method_code       = 'SAME_ENTRY'
      AND xal.natural_side_code          = 'D';

  CURSOR c_same_entry_jlt_credit IS
  SELECT  'x'
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b xal
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xal.application_id             = xld.application_id
      AND xal.amb_context_code           = xld.amb_context_code
      AND xal.event_class_code           = xld.event_class_code
      AND xal.accounting_line_type_code  = xld.accounting_line_type_code
      AND xal.accounting_line_code       = xld.accounting_line_code
      AND xal.business_method_code       = 'SAME_ENTRY'
      AND xal.natural_side_code          = 'C';


  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
  l_exist       VARCHAR2(1);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jld_same_entry';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jld_same_entry'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  OPEN c_same_entry_jlt_debit;
  FETCH c_same_entry_jlt_debit
   INTO l_exist;
  IF c_same_entry_jlt_debit%found then
     OPEN c_same_entry_jlt_credit;
     FETCH c_same_entry_jlt_credit
      INTO l_exist;
     IF c_same_entry_jlt_credit%found then
        l_return := FALSE;

        xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_SE_DEBIT_CREDIT'
            ,p_message_type               => 'W'
            ,p_message_category           => 'LINE_ASSIGNMENT'
            ,p_category_sequence          => 9
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code);

     END IF;
     CLOSE c_same_entry_jlt_credit;
  END IF;
  CLOSE c_same_entry_jlt_debit;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_business_class'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_same_entry_jlt_debit%ISOPEN THEN
      CLOSE c_same_entry_jlt_debit;
    END IF;
    IF c_same_entry_jlt_credit%ISOPEN THEN
      CLOSE c_same_entry_jlt_credit;
    END IF;
    RAISE;

  WHEN OTHERS   THEN
    IF c_same_entry_jlt_debit%ISOPEN THEN
      CLOSE c_same_entry_jlt_debit;
    END IF;
    IF c_same_entry_jlt_credit%ISOPEN THEN
      CLOSE c_same_entry_jlt_credit;
    END IF;

    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jld_same_entry');
END chk_jld_same_entry;



--=============================================================================
--
-- Name: chk_jlt_invalid_source_in_cond
-- Description: Check if all sources used in the JLT condition is valid
--
--=============================================================================
FUNCTION chk_jlt_invalid_source_in_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
    SELECT distinct xld.event_class_code, xld.event_type_code,
           xld.accounting_line_type_code, xld.accounting_line_code,
           xco.source_type_code, xco.source_code
      FROM xla_conditions xco, xla_line_defn_jlt_assgns xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = xld.application_id
       AND xco.amb_context_code           = xld.amb_context_code
       AND xco.event_class_code           = xld.event_class_code
       AND xco.accounting_line_type_code  = xld.accounting_line_type_code
       AND xco.accounting_line_code       = xld.accounting_line_code
       AND xco.source_type_code           = 'S'
       AND NOT EXISTS
           (SELECT 'y'
              FROM xla_event_sources xes
             WHERE xes.source_application_id = xco.source_application_id
               AND xes.source_type_code      = xco.source_type_code
               AND xes.source_code           = xco.source_code
               AND xes.application_id        = p_application_id
               AND xes.event_class_code      = p_event_class_code
               AND xes.active_flag           = 'Y')
    UNION
    SELECT distinct xld.event_class_code, xld.event_type_code,
           xld.accounting_line_type_code, xld.accounting_line_code,
           xco.value_source_type_code source_type_code, xco.value_source_code source_code
      FROM xla_conditions xco, xla_line_defn_jlt_assgns xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = xld.application_id
       AND xco.amb_context_code           = xld.amb_context_code
       AND xco.event_class_code           = xld.event_class_code
       AND xco.accounting_line_type_code  = xld.accounting_line_type_code
       AND xco.accounting_line_code       = xld.accounting_line_code
       AND xco.value_source_type_code     = 'S'
       AND NOT EXISTS
           (SELECT 'y'
              FROM xla_event_sources xes
             WHERE xes.source_application_id = xco.value_source_application_id
               AND xes.source_type_code      = xco.value_source_type_code
               AND xes.source_code           = xco.value_source_code
               AND xes.application_id        = p_application_id
               AND xes.event_class_code      = p_event_class_code
               AND xes.active_flag           = 'Y');

  --
  -- Get all dervied sources used by the condition of the JLT
  --
  CURSOR c_jlt_cond_der_sources IS
    SELECT distinct xld.event_class_code, xld.event_type_code,
           xld.accounting_line_type_code, xld.accounting_line_code,
           xco.source_type_code, xco.source_code
      FROM xla_conditions xco, xla_line_defn_jlt_assgns xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag               = 'Y'
       AND xco.application_id            = xld.application_id
       AND xco.amb_context_code          = xld.amb_context_code
       AND xco.event_class_code          = xld.event_class_code
       AND xco.accounting_line_type_code = xld.accounting_line_type_code
       AND xco.accounting_line_code      = xld.accounting_line_code
       AND xco.source_type_code          = 'D'
   UNION
    SELECT distinct xld.event_class_code, xld.event_type_code,
           xld.accounting_line_type_code, xld.accounting_line_code,
           xco.value_source_type_code source_type_code, xco.value_source_code source_code
      FROM xla_conditions xco, xla_line_defn_jlt_assgns xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = xld.application_id
       AND xco.amb_context_code           = xld.amb_context_code
       AND xco.event_class_code           = xld.event_class_code
       AND xco.accounting_line_type_code  = xld.accounting_line_type_code
       AND xco.accounting_line_code       = xld.accounting_line_code
       AND xco.value_source_type_code     = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_invalid_source_in_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_invalid_source_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_LT_CON_UNASN_SRCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code
            ,p_source_type_code           => l_err.source_type_code
            ,p_source_code                => l_err.source_code);
  END LOOP;

  --
  -- Check if any derveried source used by the condition of the JLT is invalid
  --
  FOR l_err IN c_jlt_cond_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
            (p_application_id             => p_application_id
            ,p_derived_source_code        => l_err.source_code
            ,p_derived_source_type_code   => 'D'
            ,p_event_class_code           => p_event_class_code
            ,p_level                      => 'L') = 'TRUE' THEN
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_LT_CON_UNASN_SRCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code
            ,p_source_type_code           => l_err.source_type_code
            ,p_source_code                => l_err.source_code);

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_invalid_source_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_jlt_cond_der_sources%ISOPEN) THEN
      CLOSE c_jlt_cond_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_jlt_cond_der_sources%ISOPEN) THEN
      CLOSE c_jlt_cond_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_invalid_source_in_cond');

END chk_jlt_invalid_source_in_cond;


--=============================================================================
-- 5642205
-- Name: chk_jlt_invalid_source_in_jlt
-- Description: Check if all sources used in the JLT attribute is valid
--
--=============================================================================
FUNCTION chk_jlt_invalid_source_in_jlt
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition. Modified for bug 6124149
  --
  CURSOR c_invalid_sources IS
    SELECT distinct xld.event_class_code, xld.event_type_code,
           xld.accounting_line_type_code, xld.accounting_line_code,
           xco.source_type_code, xco.source_code
           ,xco.accounting_attribute_code
      FROM xla_jlt_acct_attrs xco, xla_line_defn_jlt_assgns xld,
           xla_acct_attributes_b xaab
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = xld.application_id
       AND xco.amb_context_code           = xld.amb_context_code
       AND xco.event_class_code           = xld.event_class_code
       AND xco.accounting_line_type_code  = xld.accounting_line_type_code
       AND xco.accounting_line_code       = xld.accounting_line_code
       AND xco.source_type_code           in ('S','D')
       AND xaab.accounting_attribute_code  = xco.accounting_attribute_code
       AND xaab.assignment_level_code <> 'JLT_ONLY'
       AND NOT EXISTS
           (SELECT 'y'
              FROM xla_evt_class_acct_attrs xes
             WHERE xes.source_application_id = xco.source_application_id
               AND xes.source_type_code      = xco.source_type_code
               AND xes.source_code           = xco.source_code
               AND xes.application_id        = p_application_id
               AND xes.event_class_code      = p_event_class_code);


  --
  -- Get all dervied sources used by the attributes of the JLT
  --
  CURSOR c_jlt_attr_der_sources IS
    SELECT distinct xld.event_class_code, xld.event_type_code,
           xld.accounting_line_type_code, xld.accounting_line_code,
           xco.source_type_code, xco.source_code
           ,xco.accounting_attribute_code
      FROM xla_jlt_acct_attrs xco, xla_line_defn_jlt_assgns xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag               = 'Y'
       AND xco.application_id            = xld.application_id
       AND xco.amb_context_code          = xld.amb_context_code
       AND xco.event_class_code          = xld.event_class_code
       AND xco.accounting_line_type_code = xld.accounting_line_type_code
       AND xco.accounting_line_code      = xld.accounting_line_code
       AND xco.source_type_code          = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_invalid_source_in_jlt';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_invalid_source_in_jlt'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the attribute of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_LT_ATTR_UNASN_SRCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code
            ,p_source_type_code           => l_err.source_type_code
            ,p_source_code                => l_err.source_code
            ,p_accounting_source_code     => l_err.accounting_attribute_code);
  END LOOP;

  --
  -- Check if any derveried source used by the attribute of the JLT is invalid
  --
  FOR l_err IN c_jlt_attr_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
            (p_application_id             => p_application_id
            ,p_derived_source_code        => l_err.source_code
            ,p_derived_source_type_code   => 'D'
            ,p_event_class_code           => p_event_class_code
            ,p_level                      => 'L') = 'TRUE' THEN
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_CS_UNASN_SRCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code
            ,p_source_type_code           => l_err.source_type_code
            ,p_source_code                => l_err.source_code
            ,p_accounting_source_code     => l_err.accounting_attribute_code);

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_invalid_source_in_jlt'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_jlt_attr_der_sources%ISOPEN) THEN
      CLOSE c_jlt_attr_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_jlt_attr_der_sources%ISOPEN) THEN
      CLOSE c_jlt_attr_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_invalid_source_in_jlt');

END chk_jlt_invalid_source_in_jlt;

--=============================================================================
--
-- Name: chk_jlt_acct_source_assigned
-- Description: Check if all JLT of the line definition has all required
--              accounting sources assigned
--
--=============================================================================
FUNCTION chk_jlt_acct_source_assigned
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT for which not all required line accounting sources are assigned
  --
  CURSOR c_non_pe_jlt IS
    SELECT xld.accounting_line_type_code
          ,xld.accounting_line_code
          ,xja.accounting_attribute_code
      FROM xla_line_defn_jlt_assgns xld, xla_acct_line_types_b jlt, xla_jlt_acct_attrs xja
     WHERE xld.application_id            = xja.application_id
       AND xld.amb_context_code          = xja.amb_context_code
       AND xld.event_class_code          = xja.event_class_code
       AND xld.accounting_line_type_code = xja.accounting_line_type_code
       AND xld.accounting_line_code      = xja.accounting_line_code
       AND xld.application_id            = jlt.application_id
       AND xld.amb_context_code          = jlt.amb_context_code
       AND xld.event_class_code          = jlt.event_class_code
       AND xld.accounting_line_type_code = jlt.accounting_line_type_code
       AND xld.accounting_line_code      = jlt.accounting_line_code
       AND jlt.business_method_code      <> 'PRIOR_ENTRY'
       AND xld.application_id            = p_application_id
       AND xld.amb_context_code          = p_amb_context_code
       AND xld.event_class_code          = p_event_class_code
       AND xld.event_type_code           = p_event_type_code
       AND xld.line_definition_owner_code= p_line_definition_owner_code
       AND xld.line_definition_code      = p_line_definition_code
       AND xja.source_code               is null
       AND EXISTS (SELECT 'x'
                     FROM xla_acct_attributes_b xaa
                    WHERE xaa.accounting_attribute_code = xja.accounting_attribute_code
                      AND xaa.assignment_required_code      = 'Y'
                      AND xaa.assignment_level_code         IN ('EVT_CLASS_JLT','JLT_ONLY'));

  CURSOR c_pe_jlt IS
    SELECT xld.accounting_line_type_code
          ,xld.accounting_line_code
          ,xja.accounting_attribute_code
      FROM xla_line_defn_jlt_assgns xld, xla_acct_line_types_b jlt, xla_jlt_acct_attrs xja
     WHERE xld.application_id            = xja.application_id
       AND xld.amb_context_code          = xja.amb_context_code
       AND xld.event_class_code          = xja.event_class_code
       AND xld.accounting_line_type_code = xja.accounting_line_type_code
       AND xld.accounting_line_code      = xja.accounting_line_code
       AND xld.application_id            = jlt.application_id
       AND xld.amb_context_code          = jlt.amb_context_code
       AND xld.event_class_code          = jlt.event_class_code
       AND xld.accounting_line_type_code = jlt.accounting_line_type_code
       AND xld.accounting_line_code      = jlt.accounting_line_code
       AND jlt.business_method_code      = 'PRIOR_ENTRY'
       AND xld.application_id            = p_application_id
       AND xld.amb_context_code          = p_amb_context_code
       AND xld.event_class_code          = p_event_class_code
       AND xld.event_type_code           = p_event_type_code
       AND xld.line_definition_owner_code= p_line_definition_owner_code
       AND xld.line_definition_code      = p_line_definition_code
       AND xja.source_code               is null
       AND EXISTS (SELECT 'x'
                     FROM xla_acct_attributes_b xaa
                    WHERE xaa.accounting_attribute_code     = xja.accounting_attribute_code
                      AND xaa.assignment_required_code      = 'Y'
                      AND xaa.assignment_level_code         IN ('EVT_CLASS_JLT','JLT_ONLY')
                      AND xaa.inherited_flag                = 'N');


  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_acct_source_assigned';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_acct_source_assigned'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any JLT does not have all required line accounting sources
  --
  FOR l_err IN c_non_pe_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_LT_ACCTING_SOURCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code
            ,p_accounting_source_code     => l_err.accounting_attribute_code);
  END LOOP;

  FOR l_err IN c_pe_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_LT_ACCTING_SOURCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'LINE_TYPE'
            ,p_category_sequence          => 10
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code
            ,p_accounting_source_code     => l_err.accounting_attribute_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_acct_source_assigned'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_non_pe_jlt%ISOPEN) THEN
      CLOSE c_non_pe_jlt;
    END IF;
    IF (c_pe_jlt%ISOPEN) THEN
      CLOSE c_pe_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_non_pe_jlt%ISOPEN) THEN
      CLOSE c_non_pe_jlt;
    END IF;
    IF (c_pe_jlt%ISOPEN) THEN
      CLOSE c_pe_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_acct_source_assigned');

END chk_jlt_acct_source_assigned;


--=============================================================================
--
-- Name: chk_jlt_inv_acct_group_src
-- Description: Check if all JLT of the line definition has all required
--              accounting sources assigned
--
--=============================================================================
FUNCTION chk_jlt_inv_acct_group_src
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_jlt_assgns IS
   SELECT accounting_line_type_code, accounting_line_code
     FROM xla_line_defn_jlt_assgns
    WHERE application_id             = p_application_id
      AND amb_context_code           = p_amb_context_code
      AND event_class_code           = p_event_class_code
      AND event_type_code            = p_event_type_code
      AND line_definition_owner_code = p_line_definition_owner_code
      AND line_definition_code       = p_line_definition_code;

  CURSOR c_business_method(l_accounting_line_type_code VARCHAR2
                          ,l_accounting_line_code      VARCHAR2)
  IS
  SELECT business_method_code, mpa_option_code
    FROM xla_acct_line_types_b
   WHERE application_id             = p_application_id
     AND amb_context_code           = p_amb_context_code
     AND event_class_code           = p_event_class_code
     AND accounting_line_type_code = l_accounting_line_type_code
     AND accounting_line_code      = l_accounting_line_code;

  CURSOR c_mapping_groups(l_accounting_line_type_code VARCHAR2
                         ,l_accounting_line_code      VARCHAR2) IS
   SELECT distinct xaa.assignment_group_code
     FROM xla_jlt_acct_attrs xja, xla_acct_attributes_b xaa
    WHERE xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.accounting_attribute_code = xaa.accounting_attribute_code
      AND xja.source_code               IS NOT NULL
   UNION
   SELECT distinct xaa.assignment_group_code
     FROM xla_evt_class_acct_attrs xec, xla_acct_attributes_b xaa
    WHERE xec.application_id            = p_application_id
      AND xec.event_class_code          = p_event_class_code
      AND xec.accounting_attribute_code = xaa.accounting_attribute_code
      AND xaa.assignment_level_code    = 'EVT_CLASS_ONLY'
      AND xec.default_flag              = 'Y';

  CURSOR c_group_acct_sources(l_accounting_line_type_code VARCHAR2
                             ,l_accounting_line_code      VARCHAR2
                             ,l_assignment_group_code     VARCHAR2) IS
   SELECT distinct xaa.accounting_attribute_code
     FROM xla_acct_attributes_b xaa
         ,xla_jlt_acct_attrs    xja
    WHERE xaa.assignment_level_code     = 'EVT_CLASS_JLT'
      AND xaa.assignment_required_code  = 'G'
      AND xaa.accounting_attribute_code = xja.accounting_attribute_code
      AND xaa.assignment_group_code     = l_assignment_group_code
      AND xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.source_code               IS NULL;

  CURSOR c_pe_mapping_groups(l_accounting_line_type_code VARCHAR2
                         ,l_accounting_line_code      VARCHAR2) IS
   SELECT distinct xaa.assignment_group_code
     FROM xla_jlt_acct_attrs xja, xla_acct_attributes_b xaa
    WHERE xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.accounting_attribute_code = xaa.accounting_attribute_code
      AND (xja.source_code               IS NOT NULL
       OR xaa.inherited_flag            = 'Y')
   UNION
   SELECT distinct xaa.assignment_group_code
     FROM xla_evt_class_acct_attrs xec, xla_acct_attributes_b xaa
    WHERE xec.application_id            = p_application_id
      AND xec.event_class_code          = p_event_class_code
      AND xec.accounting_attribute_code = xaa.accounting_attribute_code
      AND xaa.assignment_level_code    = 'EVT_CLASS_ONLY'
      AND xec.default_flag              = 'Y';

  CURSOR c_pe_group_acct_sources(l_accounting_line_type_code VARCHAR2
                             ,l_accounting_line_code      VARCHAR2
                             ,l_assignment_group_code     VARCHAR2) IS
   SELECT distinct xaa.accounting_attribute_code
     FROM xla_acct_attributes_b xaa
         ,xla_jlt_acct_attrs    xja
    WHERE xaa.assignment_level_code     = 'EVT_CLASS_JLT'
      AND xaa.assignment_required_code  = 'G'
      AND xaa.accounting_attribute_code = xja.accounting_attribute_code
      AND xaa.assignment_group_code     = l_assignment_group_code
      AND xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.source_code               IS NULL
      AND xaa.inherited_flag            = 'N';

  CURSOR c_bus_flow_acct_sources(l_accounting_line_type_code VARCHAR2
                             ,l_accounting_line_code      VARCHAR2) IS
   SELECT distinct xaa.accounting_attribute_code
     FROM xla_acct_attributes_b xaa
         ,xla_jlt_acct_attrs    xja
    WHERE xaa.assignment_level_code     = 'EVT_CLASS_JLT'
      AND xaa.assignment_required_code  = 'G'
      AND xaa.accounting_attribute_code = xja.accounting_attribute_code
      AND xaa.assignment_group_code     = 'BUSINESS_FLOW'
      AND xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      and xja.source_code is null;

  CURSOR c_mpa_acct_sources(l_accounting_line_type_code VARCHAR2
                             ,l_accounting_line_code      VARCHAR2) IS
   SELECT distinct xaa.accounting_attribute_code
     FROM xla_acct_attributes_b xaa
         ,xla_jlt_acct_attrs    xja
    WHERE xaa.assignment_level_code     = 'EVT_CLASS_JLT'
      AND xaa.assignment_required_code  = 'G'
      AND xaa.accounting_attribute_code = xja.accounting_attribute_code
      AND xaa.assignment_group_code     = 'MULTIPERIOD_CODE'
      AND xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      and xja.source_code is null;
  l_return               BOOLEAN;
  l_log_module           VARCHAR2(240);
  l_business_method_code VARCHAR2(30);
  l_mpa_option_code      VARCHAR2(30);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_jlt_inv_acct_group_src';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_jlt_inv_acct_group_src'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_jlt IN c_jlt_assgns LOOP

    OPEN c_business_method(l_jlt.accounting_line_type_code
                          ,l_jlt.accounting_line_code);
    FETCH c_business_method
     INTO l_business_method_code, l_mpa_option_code;
    CLOSE c_business_method;

    IF l_business_method_code = 'PRIOR_ENTRY' THEN
         FOR l_err IN c_bus_flow_acct_sources(l_jlt.accounting_line_type_code
                                       ,l_jlt.accounting_line_code) LOOP
           l_return := FALSE;
           xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_BUS_FLOW_ACCT_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_TYPE'
              ,p_category_sequence          => 10
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_jlt.accounting_line_type_code
              ,p_accounting_line_code       => l_jlt.accounting_line_code
              ,p_accounting_source_code     => l_err.accounting_attribute_code
              ,p_accounting_group_code      => 'BUSINESS_FLOW');
         END LOOP;
    END IF;

    IF l_mpa_option_code <> 'NONE' THEN
         FOR l_err IN c_mpa_acct_sources(l_jlt.accounting_line_type_code
                                       ,l_jlt.accounting_line_code) LOOP
           l_return := FALSE;
           xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_ACCT_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_TYPE'
              ,p_category_sequence          => 10
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_jlt.accounting_line_type_code
              ,p_accounting_line_code       => l_jlt.accounting_line_code
              ,p_accounting_source_code     => l_err.accounting_attribute_code
              ,p_accounting_group_code      => 'MULTIPERIOD_CODE');
         END LOOP;
    END IF;


    IF l_business_method_code <> 'PRIOR_ENTRY' THEN

       FOR l_mapping_group IN c_mapping_groups(l_jlt.accounting_line_type_code
                                           ,l_jlt.accounting_line_code) LOOP
         FOR l_err IN c_group_acct_sources(l_jlt.accounting_line_type_code
                                       ,l_jlt.accounting_line_code
                                       ,l_mapping_group.assignment_group_code) LOOP
           l_return := FALSE;
           xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LT_ACCT_GROUP_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_TYPE'
              ,p_category_sequence          => 10
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_jlt.accounting_line_type_code
              ,p_accounting_line_code       => l_jlt.accounting_line_code
              ,p_accounting_source_code     => l_err.accounting_attribute_code
              ,p_accounting_group_code      => l_mapping_group.assignment_group_code);
         END LOOP;
       END LOOP;
    ELSE
       FOR l_pe_mapping_group IN c_pe_mapping_groups(l_jlt.accounting_line_type_code
                                           ,l_jlt.accounting_line_code) LOOP
         FOR l_err IN c_pe_group_acct_sources(l_jlt.accounting_line_type_code
                                       ,l_jlt.accounting_line_code
                                       ,l_pe_mapping_group.assignment_group_code) LOOP
           l_return := FALSE;
           xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LT_ACCT_GROUP_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_TYPE'
              ,p_category_sequence          => 10
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_accounting_line_type_code  => l_jlt.accounting_line_type_code
              ,p_accounting_line_code       => l_jlt.accounting_line_code
              ,p_accounting_source_code     => l_err.accounting_attribute_code
              ,p_accounting_group_code      => l_pe_mapping_group.assignment_group_code);
         END LOOP;
       END LOOP;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_jlt_inv_acct_group_src'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_jlt_assgns%ISOPEN) THEN
      CLOSE c_jlt_assgns;
    END IF;
    IF (c_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    IF (c_pe_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_pe_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_jlt_assgns%ISOPEN) THEN
      CLOSE c_jlt_assgns;
    END IF;
    IF (c_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    IF (c_pe_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_pe_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_jlt_inv_acct_group_src');

END chk_jlt_inv_acct_group_src;

--=============================================================================
--
-- Name: validate_jlt_assgns
-- Description: Validate JLT assignment of the line definition
--
--=============================================================================
FUNCTION validate_jlt_assgns
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_jlt_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_jlt_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_jlt_exists
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_encum_type_exists
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_acct_class_exists
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_rounding_class_exists
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_bflow_class_exists
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_invalid_source_in_cond
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_invalid_source_in_jlt     -- 5642205
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_acct_source_assigned
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_inv_acct_group_src
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_jlt_business_class
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_jlt_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_jlt_assgns');
END validate_jlt_assgns;

--=============================================================================
--
-- Name: chk_line_desc_is_enabled
-- Description: Check if all line description of the line definition are enabled
--
--=============================================================================
FUNCTION chk_line_desc_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_line_desc IS
   SELECT distinct xdb.description_type_code, xdb.description_code
     FROM xla_line_defn_jlt_assgns xjl
         ,xla_descriptions_b       xdb
    WHERE xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xjl.description_type_code      IS NOT NULL
      AND xdb.application_id             = xjl.application_id
      AND xdb.amb_context_code           = xjl.amb_context_code
      AND xdb.description_type_code      = xjl.description_type_code
      AND xdb.description_code           = xjl.description_code
      AND xdb.enabled_flag               <> 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_line_desc_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_line_desc_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_line_desc LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_DISABLD_LINE_DESC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_DESCRIPTION'
              ,p_category_sequence          => 11
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_line_desc_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_line_desc%ISOPEN) THEN
      CLOSE c_invalid_line_desc;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_line_desc%ISOPEN) THEN
      CLOSE c_invalid_line_desc;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_line_desc_is_enabled');

END chk_line_desc_is_enabled;

--=============================================================================
--
-- Name: chk_line_desc_inv_src_in_cond
-- Description: Check if all sources used in the JLT condition is valid
--
--=============================================================================
FUNCTION chk_line_desc_inv_src_in_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.description_type_code
      AND xdp.description_code           = xjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.source_type_code           = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = xjl.application_id
              AND xes.event_class_code      = xjl.event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.description_type_code
      AND xdp.description_code           = xjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.value_source_type_code     = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = xjl.application_id
              AND xes.event_class_code      = xjl.event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.description_type_code
      AND xdp.description_code           = xjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.source_type_code           = 'D'
   UNION
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.description_type_code
      AND xdp.description_code           = xjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.value_source_type_code     = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_line_desc_inv_src_in_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_line_desc_inv_src_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_DES_CON_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_DESCRIPTION'
              ,p_category_sequence          => 11
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_DES_CON_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_DESCRIPTION'
              ,p_category_sequence          => 11
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_line_desc_inv_src_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_line_desc_inv_src_in_cond');

END chk_line_desc_inv_src_in_cond;

--=============================================================================
--
-- Name: chk_line_desc_inv_src_in_dtl
-- Description: Check if all sources used in the JLT condition is valid
--
--=============================================================================
FUNCTION chk_line_desc_inv_src_in_dtl
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xdd.source_type_code, xdd.source_code
     FROM xla_descript_details_b   xdd
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xdd.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.description_type_code
      AND xdp.description_code           = xjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xdd.source_type_code           = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xdd.source_application_id
              AND xes.source_type_code      = xdd.source_type_code
              AND xes.source_code           = xdd.source_code
              AND xes.application_id        = xjl.application_id
              AND xes.event_class_code      = xjl.event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xdd.source_type_code, xdd.source_code
     FROM xla_descript_details_b   xdd
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xdd.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.description_type_code
      AND xdp.description_code           = xjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xdd.source_type_code           = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_line_desc_inv_src_in_dtl';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_line_desc_inv_src_in_dtl'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_DES_DET_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_DESCRIPTION'
              ,p_category_sequence          => 11
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_DES_DET_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_DESCRIPTION'
              ,p_category_sequence          => 11
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_line_desc_inv_src_in_dtl'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_line_desc_inv_src_in_dtl');

END chk_line_desc_inv_src_in_dtl;



--=============================================================================
--
-- Name: validate_line_descriptions
-- Description: Validate JLT assignment of the line definition
--
--=============================================================================
FUNCTION validate_line_descriptions
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_line_descriptions';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_line_descriptions'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_line_desc_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_line_desc_inv_src_in_cond
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_line_desc_inv_src_in_dtl
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_line_descriptions'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_line_descriptions');
END validate_line_descriptions;

--=============================================================================
--
-- Name: chk_line_ac_is_enabled
-- Description: Check if all line analytical criteria of the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_line_ac_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_line_ac IS
   SELECT distinct xah.analytical_criterion_type_code, xah.analytical_criterion_code
     FROM xla_line_defn_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_analytical_hdrs_b    xah
    WHERE xah.amb_context_code               = xac.amb_context_code
      AND xah.analytical_criterion_code      = xac.analytical_criterion_code
      AND xah.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xah.enabled_flag                   <> 'Y'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_line_ac_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_line_ac_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_line_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_DISABLD_LINE_AC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_AC'
              ,p_category_sequence          => 12
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_line_ac_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_line_ac%ISOPEN) THEN
      CLOSE c_invalid_line_ac;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_line_ac%ISOPEN) THEN
      CLOSE c_invalid_line_ac;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_line_ac_is_enabled');

END chk_line_ac_is_enabled;

--=============================================================================
--
-- Name: chk_ac_has_details
-- Description:
--
--=============================================================================
FUNCTION chk_ac_has_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_ac IS
   SELECT distinct xac.analytical_criterion_type_code, xac.analytical_criterion_code
     FROM xla_line_defn_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
    WHERE xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND NOT EXISTS
          (SELECT 'x'
             FROM xla_analytical_sources  xas
            WHERE xas.application_id                 = xac.application_id
              AND xas.amb_context_code               = xac.amb_context_code
              AND xas.event_class_code               = xac.event_class_code
              AND xas.analytical_criterion_code      = xac.analytical_criterion_code
              AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_ac_has_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_ac_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_ANC_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_AC'
              ,p_category_sequence          => 12
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_ac_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_ac%ISOPEN) THEN
      CLOSE c_invalid_ac;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_ac%ISOPEN) THEN
      CLOSE c_invalid_ac;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_ac_has_details');

END chk_ac_has_details;

--=============================================================================
--
-- Name: chk_ac_invalid_sources
-- Description:
--
--=============================================================================
FUNCTION chk_ac_invalid_sources
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_sources IS
   SELECT distinct  xas.analytical_criterion_type_code, xas.analytical_criterion_code,
          xas.source_code, xas.source_type_code
     FROM xla_analytical_sources   xas
         ,xla_line_defn_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_event_sources        xes
    WHERE xas.application_id                 = xac.application_id
      AND xas.amb_context_code               = xac.amb_context_code
      AND xas.event_class_code               = xac.event_class_code
      AND xas.analytical_criterion_code      = xac.analytical_criterion_code
      AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xas.source_type_code               = 'S'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND not exists (SELECT 'y'
                        FROM xla_event_sources xes
                       WHERE xes.source_application_id = xas.source_application_id
                         AND xes.source_type_code      = xas.source_type_code
                         AND xes.source_code           = xas.source_code
                         AND xes.application_id        = xas.application_id
                         AND xes.event_class_code      = xas.event_class_code
                         AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xas.analytical_criterion_type_code, xas.analytical_criterion_code,
          xas.source_code, xas.source_type_code
     FROM xla_analytical_sources   xas
         ,xla_line_defn_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
    WHERE xas.application_id                 = xac.application_id
      AND xas.amb_context_code               = xac.amb_context_code
      AND xas.event_class_code               = xac.event_class_code
      AND xas.analytical_criterion_code      = xac.analytical_criterion_code
      AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xas.source_type_code               = 'D'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_ac_invalid_sources';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_ac_invalid_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_sources LOOP

    l_return := FALSE;
    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_ANC_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_AC'
              ,p_category_sequence          => 12
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code
              ,p_source_code                => l_err.source_code
              ,p_source_type_code           => l_err.source_type_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

      l_return := FALSE;
      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_LINE_ANC_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'LINE_AC'
              ,p_category_sequence          => 12
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code
              ,p_source_code                => l_err.source_code
              ,p_source_type_code           => l_err.source_type_code);
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_ac_invalid_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_ac_invalid_sources');
END chk_ac_invalid_sources;


--=============================================================================
--
-- Name: validate_line_ac
-- Description: Validate AC assignment of the line definition
--
--=============================================================================
FUNCTION validate_line_ac
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_line_ac';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_line_ac'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_line_ac_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_ac_has_details
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_ac_invalid_sources
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_line_ac'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_line_ac');
END validate_line_ac;


--=============================================================================
--
-- Name: chk_ms_is_enabled
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_ms_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_ms IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_mapping_set_code
     FROM xla_seg_rule_details     xsr
         ,xla_line_defn_adr_assgns xad
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mapping_sets_b       xms
    WHERE xms.mapping_set_code               = xsr.value_mapping_set_code
      AND xms.amb_context_code               = xsr.amb_context_code
      AND xms.enabled_flag                   <> 'Y'
      AND xsr.application_id                 = xad.application_id
      AND xsr.amb_context_code               = xad.amb_context_code
      AND xsr.segment_rule_type_code         = xad.segment_rule_type_code
      AND xsr.segment_rule_code              = xad.segment_rule_code
      AND xsr.value_mapping_set_code         IS NOT NULL
      AND xad.application_id                 = xjl.application_id
      AND xad.amb_context_code               = xjl.amb_context_code
      AND xad.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xad.line_definition_code           = xjl.line_definition_code
      AND xad.event_class_code               = xjl.event_class_code
      AND xad.event_type_code                = xjl.event_type_code
      AND xad.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xad.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_ms_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_ms_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_ms LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_DISABLED_MAPPING_SET'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MAPPING_SET'
              ,p_category_sequence          => 14
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_mapping_set_code           => l_err.value_mapping_set_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_ms_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_ms%ISOPEN) THEN
      CLOSE c_invalid_ms;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_ms%ISOPEN) THEN
      CLOSE c_invalid_ms;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_ms_is_enabled');
END chk_ms_is_enabled;

--=============================================================================
--
-- Name: validate_mapping_sets
-- Description: Validate AC assignment of the line definition
--
--=============================================================================
FUNCTION validate_mapping_sets
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mapping_sets';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mapping_sets'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_ms_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mapping_sets'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mapping_sets');
END validate_mapping_sets;

--=============================================================================
--
-- Name: chk_mpa_jlt_lines
-- Description: Check if all JLT assigned to the line definition is enabled
--
--=============================================================================
FUNCTION chk_mpa_jlt_lines
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT assignment that have less than 2 MPA JLT assignments
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct xld.accounting_line_type_code, xld.accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld, xla_acct_line_types_b jlt
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND xld.application_id             = jlt.application_id
      AND xld.amb_context_code           = jlt.amb_context_code
      AND xld.event_class_code           = jlt.event_class_code
      AND xld.accounting_line_type_code  = jlt.accounting_line_type_code
      AND xld.accounting_line_code       = jlt.accounting_line_code
      AND jlt.mpa_option_code            = 'ACCRUAL';

  CURSOR c_mpa_jlt(l_accounting_line_type_code IN VARCHAR2
                  ,l_accounting_line_code      IN VARCHAR2) IS
  SELECT  count(*)
     FROM xla_mpa_jlt_assgns    mpa
    WHERE mpa.application_id             = p_application_id
      AND mpa.amb_context_code           = p_amb_context_code
      AND mpa.event_class_code           = p_event_class_code
      AND mpa.event_type_code            = p_event_type_code
      AND mpa.line_definition_owner_code = p_line_definition_owner_code
      AND mpa.line_definition_code       = p_line_definition_code
      AND mpa.accounting_line_type_code  = l_accounting_line_type_code
      AND mpa.accounting_line_code       = l_accounting_line_code;


  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
  l_count       NUMBER(15);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_jlt_lines';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_jlt_lines'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any JLT has less than 2 mpa line assignments
  --

  FOR l_err IN c_invalid_jlt LOOP

    OPEN c_mpa_jlt(l_err.accounting_line_type_code
                  ,l_err.accounting_line_code);
    FETCH c_mpa_jlt
     INTO l_count;
    CLOSE c_mpa_jlt;

    IF l_count < 2 THEN
       l_return := FALSE;

       xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_LESS_LINE_TYPES'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_ASSIGNMENT'
            ,p_category_sequence          => 17
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_accounting_line_type_code  => l_err.accounting_line_type_code
            ,p_accounting_line_code       => l_err.accounting_line_code);
    END IF;

  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_jlt_lines'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_jlt_lines');
END chk_mpa_jlt_lines;


--=============================================================================
--
-- Name: chk_mpa_jlt_is_enabled
-- Description: Check if all JLT assigned to the line definition is enabled
--
--=============================================================================
FUNCTION chk_mpa_jlt_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT assignment that has a disabled JLT
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct mpa.event_class_code, mpa.event_type_code,
          mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
         ,xla_mpa_jlt_assgns          mpa
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND xld.application_id             = mpa.application_id
      AND xld.amb_context_code           = mpa.amb_context_code
      AND xld.event_class_code           = mpa.event_class_code
      AND xld.event_type_code            = mpa.event_type_code
      AND xld.line_definition_owner_code = mpa.line_definition_owner_code
      AND xld.line_definition_code       = mpa.line_definition_code
      AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
      AND xld.accounting_line_code       = mpa.accounting_line_code
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_acct_line_types_b xal
            WHERE xal.application_id             = mpa.application_id
              AND xal.amb_context_code           = mpa.amb_context_code
              AND xal.event_class_code           = mpa.event_class_code
              AND xal.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
              AND xal.accounting_line_code       = mpa.mpa_accounting_line_code
              AND xal.enabled_flag               = 'Y');

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_jlt_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_jlt_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_DISABLD_LINE_TYPE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_TYPE'
            ,p_category_sequence          => 18
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_mpa_acct_line_type_code    => l_err.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code         => l_err.mpa_accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_jlt_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_jlt_is_enabled');
END chk_mpa_jlt_is_enabled;

--=============================================================================
--
-- Name: chk_mpa_jlt_acct_class_exist
-- Description: Check if all accounting class of the JLTs assigned to the
--              line definition are enabled
--
--=============================================================================
FUNCTION chk_mpa_jlt_acct_class_exist
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get any JLT assignment that has a disabled JLT
  --
  CURSOR c_invalid_jlt IS
  SELECT  distinct mpa.event_class_code, mpa.event_type_code,
          mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code
     FROM xla_line_defn_jlt_assgns    xld
        , xla_acct_line_types_b       xal
        ,xla_mpa_jlt_assgns           mpa
    WHERE xal.application_id             = mpa.application_id
      AND xal.amb_context_code           = mpa.amb_context_code
      AND xal.event_class_code           = mpa.event_class_code
      AND xal.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
      AND xal.accounting_line_code       = mpa.mpa_accounting_line_code
      AND xal.enabled_flag               = 'Y'
      AND xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.active_flag                = 'Y'
      AND xld.application_id             = mpa.application_id
      AND xld.amb_context_code           = mpa.amb_context_code
      AND xld.event_class_code           = mpa.event_class_code
      AND xld.event_type_code            = mpa.event_type_code
      AND xld.line_definition_owner_code = mpa.line_definition_owner_code
      AND xld.line_definition_code       = mpa.line_definition_code
      AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
      AND xld.accounting_line_code       = mpa.accounting_line_code
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_lookups xlk
            WHERE xlk.lookup_type             = 'XLA_ACCOUNTING_CLASS'
              AND xlk.lookup_code             = xal.accounting_class_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_jlt_acct_class_exist';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_jlt_acct_class_exist'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any disabled JLT is assigned to the line definition
  --
  FOR l_err IN c_invalid_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_INVALID_ACCT_CLASS'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_TYPE'
            ,p_category_sequence          => 18
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_mpa_acct_line_type_code    => l_err.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code         => l_err.mpa_accounting_line_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_jlt_acct_class_exist'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_jlt%ISOPEN) THEN
      CLOSE c_invalid_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_jlt_acct_class_exist');
END chk_mpa_jlt_acct_class_exist;

--=============================================================================
--
-- Name: chk_mpa_jlt_inv_source_in_cond
-- Description: Check if all sources used in the JLT condition is valid
--
--=============================================================================
FUNCTION chk_mpa_jlt_inv_source_in_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
    SELECT distinct mpa.event_class_code, mpa.event_type_code,
          mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code,
           xco.source_type_code, xco.source_code
      FROM xla_conditions           xco
          ,xla_line_defn_jlt_assgns xld
          ,xla_mpa_jlt_assgns       mpa
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = mpa.application_id
       AND xco.amb_context_code           = mpa.amb_context_code
       AND xco.event_class_code           = mpa.event_class_code
       AND xco.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
       AND xco.accounting_line_code       = mpa.mpa_accounting_line_code
       AND xco.source_type_code           = 'S'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
       AND NOT EXISTS
           (SELECT 'y'
              FROM xla_event_sources xes
             WHERE xes.source_application_id = xco.source_application_id
               AND xes.source_type_code      = xco.source_type_code
               AND xes.source_code           = xco.source_code
               AND xes.application_id        = p_application_id
               AND xes.event_class_code      = p_event_class_code
               AND xes.active_flag           = 'Y')
    UNION
    SELECT distinct mpa.event_class_code, mpa.event_type_code,
          mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code,
           xco.value_source_type_code source_type_code, xco.value_source_code source_code
      FROM xla_conditions           xco
          ,xla_line_defn_jlt_assgns xld
          ,xla_mpa_jlt_assgns       mpa
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = mpa.application_id
       AND xco.amb_context_code           = mpa.amb_context_code
       AND xco.event_class_code           = mpa.event_class_code
       AND xco.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
       AND xco.accounting_line_code       = mpa.mpa_accounting_line_code
       AND xco.value_source_type_code     = 'S'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
       AND NOT EXISTS
           (SELECT 'y'
              FROM xla_event_sources xes
             WHERE xes.source_application_id = xco.value_source_application_id
               AND xes.source_type_code      = xco.value_source_type_code
               AND xes.source_code           = xco.value_source_code
               AND xes.application_id        = p_application_id
               AND xes.event_class_code      = p_event_class_code
               AND xes.active_flag           = 'Y');

  --
  -- Get all dervied sources used by the condition of the JLT
  --
  CURSOR c_jlt_cond_der_sources IS
    SELECT distinct mpa.event_class_code, mpa.event_type_code,
          mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code,
           xco.source_type_code, xco.source_code
      FROM xla_conditions           xco
          ,xla_line_defn_jlt_assgns xld
          ,xla_mpa_jlt_assgns       mpa
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag               = 'Y'
       AND xco.application_id             = mpa.application_id
       AND xco.amb_context_code           = mpa.amb_context_code
       AND xco.event_class_code           = mpa.event_class_code
       AND xco.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
       AND xco.accounting_line_code       = mpa.mpa_accounting_line_code
       AND xco.source_type_code          = 'D'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
   UNION
    SELECT distinct mpa.event_class_code, mpa.event_type_code,
          mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code,
           xco.value_source_type_code source_type_code, xco.value_source_code source_code
      FROM xla_conditions           xco
          ,xla_line_defn_jlt_assgns xld
          ,xla_mpa_jlt_assgns       mpa
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xco.application_id             = mpa.application_id
       AND xco.amb_context_code           = mpa.amb_context_code
       AND xco.event_class_code           = mpa.event_class_code
       AND xco.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
       AND xco.accounting_line_code       = mpa.mpa_accounting_line_code
       AND xco.value_source_type_code     = 'D'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)  ;

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_jlt_inv_source_in_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_jlt_inv_source_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_LT_CON_UNASN_SRCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_TYPE'
            ,p_category_sequence          => 18
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_mpa_acct_line_type_code    => l_err.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code         => l_err.mpa_accounting_line_code
            ,p_source_type_code           => l_err.source_type_code
            ,p_source_code                => l_err.source_code);
  END LOOP;

  --
  -- Check if any derveried source used by the condition of the JLT is invalid
  --
  FOR l_err IN c_jlt_cond_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
            (p_application_id             => p_application_id
            ,p_derived_source_code        => l_err.source_code
            ,p_derived_source_type_code   => 'D'
            ,p_event_class_code           => p_event_class_code
            ,p_level                      => 'L') = 'TRUE' THEN
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_LT_CON_UNASN_SRCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_TYPE'
            ,p_category_sequence          => 18
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_mpa_acct_line_type_code    => l_err.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code         => l_err.mpa_accounting_line_code
            ,p_source_type_code           => l_err.source_type_code
            ,p_source_code                => l_err.source_code);

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_jlt_inv_source_in_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_jlt_cond_der_sources%ISOPEN) THEN
      CLOSE c_jlt_cond_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_jlt_cond_der_sources%ISOPEN) THEN
      CLOSE c_jlt_cond_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_jlt_inv_source_in_cond');

END chk_mpa_jlt_inv_source_in_cond;

--=============================================================================
--
-- Name: chk_mpa_jlt_acct_src_assigned
-- Description: Check if all JLT of the line definition has all required
--              accounting sources assigned
--
--=============================================================================
FUNCTION chk_mpa_jlt_acct_src_assigned
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT for which not all required line accounting sources are assigned
  --
  CURSOR c_non_pe_jlt IS
    SELECT mpa.mpa_accounting_line_type_code
          ,mpa.mpa_accounting_line_code
          ,xja.accounting_attribute_code
      FROM xla_line_defn_jlt_assgns xld
          ,xla_acct_line_types_b    jlt
          ,xla_jlt_acct_attrs       xja
          ,xla_mpa_jlt_assgns       mpa
     WHERE jlt.application_id            = xja.application_id
       AND jlt.amb_context_code          = xja.amb_context_code
       AND jlt.event_class_code          = xja.event_class_code
       AND jlt.accounting_line_type_code = xja.accounting_line_type_code
       AND jlt.accounting_line_code      = xja.accounting_line_code
       AND mpa.application_id            = jlt.application_id
       AND mpa.amb_context_code          = jlt.amb_context_code
       AND mpa.event_class_code          = jlt.event_class_code
       AND mpa.mpa_accounting_line_type_code = jlt.accounting_line_type_code
       AND mpa.mpa_accounting_line_code      = jlt.accounting_line_code
       AND jlt.business_method_code      <> 'PRIOR_ENTRY'
       AND xld.application_id            = p_application_id
       AND xld.amb_context_code          = p_amb_context_code
       AND xld.event_class_code          = p_event_class_code
       AND xld.event_type_code           = p_event_type_code
       AND xld.line_definition_owner_code= p_line_definition_owner_code
       AND xld.line_definition_code      = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND xja.source_code               is null
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
       AND EXISTS (SELECT 'x'
                     FROM xla_acct_attributes_b xaa
                    WHERE xaa.accounting_attribute_code = xja.accounting_attribute_code
                      AND xaa.assignment_required_code      = 'Y'
                      AND xaa.assignment_level_code         IN ('EVT_CLASS_JLT','JLT_ONLY'));

  CURSOR c_pe_jlt IS
    SELECT mpa.mpa_accounting_line_type_code
          ,mpa.mpa_accounting_line_code
          ,xja.accounting_attribute_code
      FROM xla_line_defn_jlt_assgns xld
          ,xla_acct_line_types_b    jlt
          ,xla_jlt_acct_attrs       xja
          ,xla_mpa_jlt_assgns       mpa
     WHERE jlt.application_id            = xja.application_id
       AND jlt.amb_context_code          = xja.amb_context_code
       AND jlt.event_class_code          = xja.event_class_code
       AND jlt.accounting_line_type_code = xja.accounting_line_type_code
       AND jlt.accounting_line_code      = xja.accounting_line_code
       AND mpa.application_id            = jlt.application_id
       AND mpa.amb_context_code          = jlt.amb_context_code
       AND mpa.event_class_code          = jlt.event_class_code
       AND mpa.mpa_accounting_line_type_code = jlt.accounting_line_type_code
       AND mpa.mpa_accounting_line_code      = jlt.accounting_line_code
       AND jlt.business_method_code      = 'PRIOR_ENTRY'
       AND xld.application_id            = p_application_id
       AND xld.amb_context_code          = p_amb_context_code
       AND xld.event_class_code          = p_event_class_code
       AND xld.event_type_code           = p_event_type_code
       AND xld.line_definition_owner_code= p_line_definition_owner_code
       AND xld.line_definition_code      = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND xja.source_code               is null
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)
       AND EXISTS (SELECT 'x'
                     FROM xla_acct_attributes_b xaa
                    WHERE xaa.accounting_attribute_code     = xja.accounting_attribute_code
                      AND xaa.assignment_required_code      = 'Y'
                      AND xaa.assignment_level_code         IN ('EVT_CLASS_JLT','JLT_ONLY')
                      AND xaa.inherited_flag                = 'N');


  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_jlt_acct_src_assigned';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_jlt_acct_src_assigned'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any JLT does not have all required line accounting sources
  --
  FOR l_err IN c_non_pe_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_LT_ACCTING_SOURCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_TYPE'
            ,p_category_sequence          => 18
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_mpa_acct_line_type_code    => l_err.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code         => l_err.mpa_accounting_line_code
            ,p_accounting_source_code     => l_err.accounting_attribute_code);
  END LOOP;

  FOR l_err IN c_pe_jlt LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
            (p_message_name               => 'XLA_AB_MPA_LT_ACCTING_SOURCE'
            ,p_message_type               => 'E'
            ,p_message_category           => 'MPA_LINE_TYPE'
            ,p_category_sequence          => 18
            ,p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code
            ,p_mpa_acct_line_type_code    => l_err.mpa_accounting_line_type_code
            ,p_mpa_acct_line_code         => l_err.mpa_accounting_line_code
            ,p_accounting_source_code     => l_err.accounting_attribute_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_jlt_acct_src_assigned'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_non_pe_jlt%ISOPEN) THEN
      CLOSE c_non_pe_jlt;
    END IF;
    IF (c_pe_jlt%ISOPEN) THEN
      CLOSE c_pe_jlt;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_non_pe_jlt%ISOPEN) THEN
      CLOSE c_non_pe_jlt;
    END IF;
    IF (c_pe_jlt%ISOPEN) THEN
      CLOSE c_pe_jlt;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_jlt_acct_src_assigned');

END chk_mpa_jlt_acct_src_assigned;


--=============================================================================
--
-- Name: chk_mpa_jlt_inv_acct_group_src
-- Description: Check if all JLT of the line definition has all required
--              accounting sources assigned
--
--=============================================================================
FUNCTION chk_mpa_jlt_inv_acct_group_src
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_jlt_assgns IS
   SELECT distinct mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code
     FROM xla_line_defn_jlt_assgns  xld
         ,xla_mpa_jlt_assgns        mpa
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
       AND xld.active_flag                = 'Y'
       AND xld.application_id             = mpa.application_id
       AND xld.amb_context_code           = mpa.amb_context_code
       AND xld.event_class_code           = mpa.event_class_code
       AND xld.event_type_code            = mpa.event_type_code
       AND xld.line_definition_owner_code = mpa.line_definition_owner_code
       AND xld.line_definition_code       = mpa.line_definition_code
       AND xld.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xld.accounting_line_code       = mpa.accounting_line_code
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = mpa.application_id
                         AND xld1.amb_context_code           = mpa.amb_context_code
                         AND xld1.event_class_code           = mpa.event_class_code
                         AND xld1.event_type_code            = mpa.event_type_code
                         AND xld1.line_definition_owner_code = mpa.line_definition_owner_code
                         AND xld1.line_definition_code       = mpa.line_definition_code
                         AND xld1.accounting_line_type_code  = mpa.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = mpa.mpa_accounting_line_code)  ;

  CURSOR c_business_method(l_accounting_line_type_code VARCHAR2
                          ,l_accounting_line_code      VARCHAR2)
  IS
  SELECT business_method_code
    FROM xla_acct_line_types_b
   WHERE application_id             = p_application_id
     AND amb_context_code           = p_amb_context_code
     AND event_class_code           = p_event_class_code
     AND accounting_line_type_code = l_accounting_line_type_code
     AND accounting_line_code      = l_accounting_line_code;

  CURSOR c_mapping_groups(l_accounting_line_type_code VARCHAR2
                         ,l_accounting_line_code      VARCHAR2) IS
   SELECT distinct xaa.assignment_group_code
     FROM xla_jlt_acct_attrs xja, xla_acct_attributes_b xaa
    WHERE xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.accounting_attribute_code = xaa.accounting_attribute_code
      AND xja.source_code               IS NOT NULL
   UNION
   SELECT distinct xaa.assignment_group_code
     FROM xla_evt_class_acct_attrs xec, xla_acct_attributes_b xaa
    WHERE xec.application_id            = p_application_id
      AND xec.event_class_code          = p_event_class_code
      AND xec.accounting_attribute_code = xaa.accounting_attribute_code
      AND xaa.assignment_level_code    = 'EVT_CLASS_ONLY'
      AND xec.default_flag              = 'Y';

  CURSOR c_group_acct_sources(l_accounting_line_type_code VARCHAR2
                             ,l_accounting_line_code      VARCHAR2
                             ,l_assignment_group_code     VARCHAR2) IS
   SELECT distinct xaa.accounting_attribute_code
     FROM xla_acct_attributes_b xaa
         ,xla_jlt_acct_attrs    xja
    WHERE xaa.assignment_level_code     = 'EVT_CLASS_JLT'
      AND xaa.assignment_required_code  = 'G'
      AND xaa.accounting_attribute_code = xja.accounting_attribute_code
      AND xaa.assignment_group_code     = l_assignment_group_code
      AND xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.source_code               IS NULL;

  CURSOR c_pe_mapping_groups(l_accounting_line_type_code VARCHAR2
                         ,l_accounting_line_code      VARCHAR2) IS
   SELECT distinct xaa.assignment_group_code
     FROM xla_jlt_acct_attrs xja, xla_acct_attributes_b xaa
    WHERE xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.accounting_attribute_code = xaa.accounting_attribute_code
      AND (xja.source_code               IS NOT NULL
       OR xaa.inherited_flag            = 'Y')
   UNION
   SELECT distinct xaa.assignment_group_code
     FROM xla_evt_class_acct_attrs xec, xla_acct_attributes_b xaa
    WHERE xec.application_id            = p_application_id
      AND xec.event_class_code          = p_event_class_code
      AND xec.accounting_attribute_code = xaa.accounting_attribute_code
      AND xaa.assignment_level_code    = 'EVT_CLASS_ONLY'
      AND xec.default_flag              = 'Y';

  CURSOR c_pe_group_acct_sources(l_accounting_line_type_code VARCHAR2
                             ,l_accounting_line_code      VARCHAR2
                             ,l_assignment_group_code     VARCHAR2) IS
   SELECT distinct xaa.accounting_attribute_code
     FROM xla_acct_attributes_b xaa
         ,xla_jlt_acct_attrs    xja
    WHERE xaa.assignment_level_code     = 'EVT_CLASS_JLT'
      AND xaa.assignment_required_code  = 'G'
      AND xaa.accounting_attribute_code = xja.accounting_attribute_code
      AND xaa.assignment_group_code     = l_assignment_group_code
      AND xja.application_id            = p_application_id
      AND xja.amb_context_code          = p_amb_context_code
      AND xja.event_class_code          = p_event_class_code
      AND xja.accounting_line_type_code = l_accounting_line_type_code
      AND xja.accounting_line_code      = l_accounting_line_code
      AND xja.source_code               IS NULL
      AND xaa.inherited_flag            = 'N';

  l_return               BOOLEAN;
  l_log_module           VARCHAR2(240);
  l_business_method_code VARCHAR2(30);

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_jlt_inv_acct_group_src';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_jlt_inv_acct_group_src'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_jlt IN c_jlt_assgns LOOP

    OPEN c_business_method(l_jlt.mpa_accounting_line_type_code
                          ,l_jlt.mpa_accounting_line_code);
    FETCH c_business_method
     INTO l_business_method_code;
    CLOSE c_business_method;

    IF l_business_method_code <> 'PRIOR_ENTRY' THEN

       FOR l_mapping_group IN c_mapping_groups(l_jlt.mpa_accounting_line_type_code
                                           ,l_jlt.mpa_accounting_line_code) LOOP
         FOR l_err IN c_group_acct_sources(l_jlt.mpa_accounting_line_type_code
                                       ,l_jlt.mpa_accounting_line_code
                                       ,l_mapping_group.assignment_group_code) LOOP
           l_return := FALSE;
           xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LT_ACCT_GROUP_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_TYPE'
              ,p_category_sequence          => 18
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_mpa_acct_line_type_code    => l_jlt.mpa_accounting_line_type_code
              ,p_mpa_acct_line_code         => l_jlt.mpa_accounting_line_code
              ,p_accounting_source_code     => l_err.accounting_attribute_code
              ,p_accounting_group_code      => l_mapping_group.assignment_group_code);
         END LOOP;
       END LOOP;
    ELSE
       FOR l_pe_mapping_group IN c_pe_mapping_groups(l_jlt.mpa_accounting_line_type_code
                                           ,l_jlt.mpa_accounting_line_code) LOOP
         FOR l_err IN c_pe_group_acct_sources(l_jlt.mpa_accounting_line_type_code
                                       ,l_jlt.mpa_accounting_line_code
                                       ,l_pe_mapping_group.assignment_group_code) LOOP
           l_return := FALSE;
           xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LT_ACCT_GROUP_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_TYPE'
              ,p_category_sequence          => 18
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_mpa_acct_line_type_code    => l_jlt.mpa_accounting_line_type_code
              ,p_mpa_acct_line_code         => l_jlt.mpa_accounting_line_code
              ,p_accounting_source_code     => l_err.accounting_attribute_code
              ,p_accounting_group_code      => l_pe_mapping_group.assignment_group_code);
         END LOOP;
       END LOOP;
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_jlt_inv_acct_group_src'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_jlt_assgns%ISOPEN) THEN
      CLOSE c_jlt_assgns;
    END IF;
    IF (c_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    IF (c_pe_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_pe_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_jlt_assgns%ISOPEN) THEN
      CLOSE c_jlt_assgns;
    END IF;
    IF (c_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    IF (c_pe_mapping_groups%ISOPEN) THEN
      CLOSE c_mapping_groups;
    END IF;
    IF (c_pe_group_acct_sources%ISOPEN) THEN
      CLOSE c_group_acct_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_jlt_inv_acct_group_src');

END chk_mpa_jlt_inv_acct_group_src;


--=============================================================================
--
-- Name: validate_mpa_jlt_assgns
-- Description: Validate MPA JLT assignment of the line definition
--
--=============================================================================
FUNCTION validate_mpa_jlt_assgns
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_jlt_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_jlt_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_mpa_jlt_lines
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_jlt_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_jlt_acct_class_exist
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_jlt_inv_source_in_cond
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_jlt_acct_src_assigned
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_jlt_inv_acct_group_src
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_jlt_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_jlt_assgns');
END validate_mpa_jlt_assgns;

--=============================================================================
--
-- Name: chk_mpa_line_desc_is_enabled
-- Description: Check if all line description of the line definition are enabled
--
--=============================================================================
FUNCTION chk_mpa_line_desc_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_line_desc IS
   SELECT distinct xdb.description_type_code, xdb.description_code
     FROM xla_mpa_jlt_assgns       mjl
         ,xla_line_defn_jlt_assgns xjl
         ,xla_descriptions_b       xdb
    WHERE xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_type_code      IS NOT NULL
      AND xdb.application_id             = mjl.application_id
      AND xdb.amb_context_code           = mjl.amb_context_code
      AND xdb.description_type_code      = mjl.description_type_code
      AND xdb.description_code           = mjl.description_code
      AND xdb.enabled_flag               <> 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_line_desc_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_line_desc_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_line_desc LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_LN_DESC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_DESC'
              ,p_category_sequence          => 19
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_line_desc_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_line_desc%ISOPEN) THEN
      CLOSE c_invalid_line_desc;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_line_desc%ISOPEN) THEN
      CLOSE c_invalid_line_desc;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_line_desc_is_enabled');

END chk_mpa_line_desc_is_enabled;

--=============================================================================
--
-- Name: chk_mpa_line_desc_inv_src_cond
-- Description: Check if all sources used in the JLT condition is valid
--
--=============================================================================
FUNCTION chk_mpa_line_desc_inv_src_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_mpa_jlt_assgns       mjl
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = mjl.application_id
      AND xdp.amb_context_code           = mjl.amb_context_code
      AND xdp.description_type_code      = mjl.description_type_code
      AND xdp.description_code           = mjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_code           IS NOT NULL
      AND xco.source_type_code           = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = mjl.application_id
              AND xes.event_class_code      = mjl.event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mpa_jlt_assgns       mjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = mjl.application_id
      AND xdp.amb_context_code           = mjl.amb_context_code
      AND xdp.description_type_code      = mjl.description_type_code
      AND xdp.description_code           = mjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.value_source_type_code     = 'S'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_code           IS NOT NULL
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = mjl.application_id
              AND xes.event_class_code      = mjl.event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mpa_jlt_assgns       mjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = mjl.application_id
      AND xdp.amb_context_code           = mjl.amb_context_code
      AND xdp.description_type_code      = mjl.description_type_code
      AND xdp.description_code           = mjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.source_type_code           = 'D'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_code           IS NOT NULL
   UNION
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mpa_jlt_assgns       mjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = mjl.application_id
      AND xdp.amb_context_code           = mjl.amb_context_code
      AND xdp.description_type_code      = mjl.description_type_code
      AND xdp.description_code           = mjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.value_source_type_code     = 'D'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_code           IS NOT NULL;

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_line_desc_inv_src_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_line_desc_inv_src_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LN_DES_CON_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_DESC'
              ,p_category_sequence          => 19
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LN_DES_CON_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_DESC'
              ,p_category_sequence          => 19
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_line_desc_inv_src_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_line_desc_inv_src_cond');

END chk_mpa_line_desc_inv_src_cond;

--=============================================================================
--
-- Name: chk_mpa_line_desc_inv_src_dtl
-- Description: Check if all sources used in the JLT condition is valid
--
--=============================================================================
FUNCTION chk_mpa_line_desc_inv_src_dtl
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xdd.source_type_code, xdd.source_code
     FROM xla_descript_details_b   xdd
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mpa_jlt_assgns       mjl
    WHERE xdd.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = mjl.application_id
      AND xdp.amb_context_code           = mjl.amb_context_code
      AND xdp.description_type_code      = mjl.description_type_code
      AND xdp.description_code           = mjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xdd.source_type_code           = 'S'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_code           IS NOT NULL
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xdd.source_application_id
              AND xes.source_type_code      = xdd.source_type_code
              AND xes.source_code           = xdd.source_code
              AND xes.application_id        = mjl.application_id
              AND xes.event_class_code      = mjl.event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xjl.description_type_code, xjl.description_code,
          xdd.source_type_code, xdd.source_code
     FROM xla_descript_details_b   xdd
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mpa_jlt_assgns       mjl
    WHERE xdd.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = mjl.application_id
      AND xdp.amb_context_code           = mjl.amb_context_code
      AND xdp.description_type_code      = mjl.description_type_code
      AND xdp.description_code           = mjl.description_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xdd.source_type_code           = 'D'
      AND xjl.application_id             = mjl.application_id
      AND xjl.amb_context_code           = mjl.amb_context_code
      AND xjl.event_class_code           = mjl.event_class_code
      AND xjl.event_type_code            = mjl.event_type_code
      AND xjl.line_definition_owner_code = mjl.line_definition_owner_code
      AND xjl.line_definition_code       = mjl.line_definition_code
      AND xjl.accounting_line_type_code  = mjl.accounting_line_type_code
      AND xjl.accounting_line_code       = mjl.accounting_line_code
      AND mjl.description_code           IS NOT NULL;

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_line_desc_inv_src_dtl';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_line_desc_inv_src_dtl'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LN_DES_DET_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_DESC'
              ,p_category_sequence          => 19
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LN_DES_DET_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_DESC'
              ,p_category_sequence          => 19
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.description_type_code
              ,p_description_code           => l_err.description_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_line_desc_inv_src_dtl'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_line_desc_inv_src_dtl');

END chk_mpa_line_desc_inv_src_dtl;

--=============================================================================
--
-- Name: validate_mpa_line_desc
-- Description: Validate MPA line desc assignment of the line definition
--
--=============================================================================
FUNCTION validate_mpa_line_desc
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_line_desc';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_line_desc'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_mpa_line_desc_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_line_desc_inv_src_cond
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_line_desc_inv_src_dtl
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_line_desc'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_line_desc');
END validate_mpa_line_desc;


--=============================================================================
--
-- Name: chk_mpa_line_ac_is_enabled
-- Description: Check if all line analytical criteria of the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_line_ac_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_line_ac IS
   SELECT distinct xah.analytical_criterion_type_code, xah.analytical_criterion_code
     FROM xla_mpa_jlt_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_analytical_hdrs_b    xah
    WHERE xah.amb_context_code               = xac.amb_context_code
      AND xah.analytical_criterion_code      = xac.analytical_criterion_code
      AND xah.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xah.enabled_flag                   <> 'Y'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_line_ac_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_line_ac_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_line_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_LN_AC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_AC'
              ,p_category_sequence          => 20
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_line_ac_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_line_ac%ISOPEN) THEN
      CLOSE c_invalid_line_ac;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_line_ac%ISOPEN) THEN
      CLOSE c_invalid_line_ac;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_line_ac_is_enabled');

END chk_mpa_line_ac_is_enabled;

--=============================================================================
--
-- Name: chk_mpa_ac_has_details
-- Description:
--
--=============================================================================
FUNCTION chk_mpa_ac_has_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_ac IS
   SELECT distinct xac.analytical_criterion_type_code, xac.analytical_criterion_code
     FROM xla_mpa_jlt_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
    WHERE xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND NOT EXISTS
          (SELECT 'x'
             FROM xla_analytical_sources  xas
            WHERE xas.application_id                 = xac.application_id
              AND xas.amb_context_code               = xac.amb_context_code
              AND xas.event_class_code               = xac.event_class_code
              AND xas.analytical_criterion_code      = xac.analytical_criterion_code
              AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_ac_has_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_ac_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LN_ANC_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_AC'
              ,p_category_sequence          => 20
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_ac_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_ac%ISOPEN) THEN
      CLOSE c_invalid_ac;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_ac%ISOPEN) THEN
      CLOSE c_invalid_ac;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_ac_has_details');

END chk_mpa_ac_has_details;

--=============================================================================
--
-- Name: chk_mpa_ac_invalid_sources
-- Description:
--
--=============================================================================
FUNCTION chk_mpa_ac_invalid_sources
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_sources IS
   SELECT distinct  xas.analytical_criterion_type_code, xas.analytical_criterion_code,
          xas.source_code, xas.source_type_code
     FROM xla_analytical_sources   xas
         ,xla_mpa_jlt_ac_assgns    xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_event_sources        xes
    WHERE xas.application_id                 = xac.application_id
      AND xas.amb_context_code               = xac.amb_context_code
      AND xas.event_class_code               = xac.event_class_code
      AND xas.analytical_criterion_code      = xac.analytical_criterion_code
      AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xas.source_type_code               = 'S'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND not exists (SELECT 'y'
                        FROM xla_event_sources xes
                       WHERE xes.source_application_id = xas.source_application_id
                         AND xes.source_type_code      = xas.source_type_code
                         AND xes.source_code           = xas.source_code
                         AND xes.application_id        = xas.application_id
                         AND xes.event_class_code      = xas.event_class_code
                         AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xas.analytical_criterion_type_code, xas.analytical_criterion_code,
          xas.source_code, xas.source_type_code
     FROM xla_analytical_sources   xas
         ,xla_mpa_jlt_ac_assgns    xac
         ,xla_line_defn_jlt_assgns xjl
    WHERE xas.application_id                 = xac.application_id
      AND xas.amb_context_code               = xac.amb_context_code
      AND xas.event_class_code               = xac.event_class_code
      AND xas.analytical_criterion_code      = xac.analytical_criterion_code
      AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xas.source_type_code               = 'D'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_ac_invalid_sources';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_ac_invalid_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_sources LOOP

    l_return := FALSE;
    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LINE_ANC_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_AC'
              ,p_category_sequence          => 20
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code
              ,p_source_code                => l_err.source_code
              ,p_source_type_code           => l_err.source_type_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

      l_return := FALSE;
      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_LINE_ANC_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_AC'
              ,p_category_sequence          => 20
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code
              ,p_source_code                => l_err.source_code
              ,p_source_type_code           => l_err.source_type_code);
    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_ac_invalid_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_sources%ISOPEN) THEN
      CLOSE c_invalid_sources;
    END IF;
    IF (c_der_sources%ISOPEN) THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_ac_invalid_sources');
END chk_mpa_ac_invalid_sources;



--=============================================================================
--
-- Name: validate_mpa_line_ac
-- Description: Validate MPA line AC assignment of the line definition
--
--=============================================================================
FUNCTION validate_mpa_line_ac
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_line_ac';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_line_ac'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_mpa_line_ac_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_ac_has_details
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_ac_invalid_sources
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_line_ac'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_line_ac');
END validate_mpa_line_ac;


--=============================================================================
--=============================================================================
--
-- Name: chk_mpa_adr_assgn_complete
-- Description: Validate if any JLT assignment that does not contain flexfield
--              assignment and does not have complete segment assignments
-- Return Value:
--   TRUE - if all ADR assignments are valid
--   FALSE - if any ADR assignment is invalid
--
--=============================================================================
FUNCTION chk_mpa_adr_assgn_complete
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_coa_id IS
    SELECT xld.accounting_coa_id
      FROM xla_line_definitions_b xld
     WHERE xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.event_class_code           = p_event_class_code
       AND xld.event_type_code            = p_event_type_code
       AND xld.line_definition_owner_code = p_line_definition_owner_code
       AND xld.line_definition_code       = p_line_definition_code;

  --
  -- Get line assignments that does not contain flexfield assignment
  --
  CURSOR c_invalid_adrs_no_coa IS
    SELECT distinct mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code
      FROM xla_line_defn_jlt_assgns xlj
          ,xla_acct_line_types_b    jlt
          ,xla_acct_line_types_b    jlt1
          ,xla_mpa_jlt_assgns       mpa
     WHERE xlj.application_id             = p_application_id
       AND xlj.amb_context_code           = p_amb_context_code
       AND xlj.event_class_code           = p_event_class_code
       AND xlj.event_type_code            = p_event_type_code
       AND xlj.line_definition_owner_code = p_line_definition_owner_code
       AND xlj.line_definition_code       = p_line_definition_code
       AND xlj.active_flag                = 'Y'
       AND xlj.application_id             = mpa.application_id
       AND xlj.amb_context_code           = mpa.amb_context_code
       AND xlj.event_class_code           = mpa.event_class_code
       AND xlj.event_type_code            = mpa.event_type_code
       AND xlj.line_definition_owner_code = mpa.line_definition_owner_code
       AND xlj.line_definition_code       = mpa.line_definition_code
       AND xlj.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xlj.accounting_line_code       = mpa.accounting_line_code
       AND xlj.application_id             = jlt1.application_id
       AND xlj.amb_context_code           = jlt1.amb_context_code
       AND xlj.event_class_code           = jlt1.event_class_code
       AND xlj.accounting_line_type_code  = jlt1.accounting_line_type_code
       AND xlj.accounting_line_code       = jlt1.accounting_line_code
       AND jlt1.mpa_option_code           = 'ACCRUAL'
       AND mpa.application_id             = jlt.application_id
       AND mpa.amb_context_code           = jlt.amb_context_code
       AND mpa.event_class_code           = jlt.event_class_code
       AND mpa.mpa_accounting_line_type_code  = jlt.accounting_line_type_code
       AND mpa.mpa_accounting_line_code       = jlt.accounting_line_code
       AND jlt.business_method_code      <> 'PRIOR_ENTRY'
       AND NOT EXISTS
           (SELECT 'x'
              FROM xla_mpa_jlt_adr_assgns xad
             WHERE mpa.application_id             = xad.application_id
               AND mpa.amb_context_code           = xad.amb_context_code
               AND mpa.event_class_code           = xad.event_class_code
               AND mpa.event_type_code            = xad.event_type_code
               AND mpa.line_definition_owner_code = xad.line_definition_owner_code
               AND mpa.line_definition_code       = xad.line_definition_code
               AND mpa.accounting_line_type_code  = xad.accounting_line_type_code
               AND mpa.accounting_line_code       = xad.accounting_line_code
               AND mpa.mpa_accounting_line_type_code = xad.mpa_accounting_line_type_code
               AND mpa.mpa_accounting_line_code      = xad.mpa_accounting_line_code
               AND xad.flexfield_segment_code     = 'ALL');

  l_coa_id      INTEGER;

  --
  -- Get any line assignments that does not contain flexfield
  -- assignment or does not have complete segment assignments
  --
  CURSOR c_invalid_adrs IS
    SELECT distinct mpa.mpa_accounting_line_type_code, mpa.mpa_accounting_line_code
      FROM xla_line_defn_jlt_assgns xlj
          ,fnd_id_flex_segments_vl  fif
          , xla_acct_line_types_b   jlt
          ,xla_acct_line_types_b    jlt1
          ,xla_mpa_jlt_assgns       mpa
     WHERE fif.application_id             = 101
       AND fif.id_flex_code               = 'GL#'
       AND fif.id_flex_num                = l_coa_id
       AND fif.enabled_flag               = 'Y'
       AND xlj.application_id             = p_application_id
       AND xlj.amb_context_code           = p_amb_context_code
       AND xlj.event_class_code           = p_event_class_code
       AND xlj.event_type_code            = p_event_type_code
       AND xlj.line_definition_owner_code = p_line_definition_owner_code
       AND xlj.line_definition_code       = p_line_definition_code
       AND xlj.active_flag                = 'Y'
       AND xlj.application_id             = jlt1.application_id
       AND xlj.amb_context_code           = jlt1.amb_context_code
       AND xlj.event_class_code           = jlt1.event_class_code
       AND xlj.accounting_line_type_code  = jlt1.accounting_line_type_code
       AND xlj.accounting_line_code       = jlt1.accounting_line_code
       AND jlt1.mpa_option_code           = 'ACCRUAL'
       AND xlj.application_id             = mpa.application_id
       AND xlj.amb_context_code           = mpa.amb_context_code
       AND xlj.event_class_code           = mpa.event_class_code
       AND xlj.event_type_code            = mpa.event_type_code
       AND xlj.line_definition_owner_code = mpa.line_definition_owner_code
       AND xlj.line_definition_code       = mpa.line_definition_code
       AND xlj.accounting_line_type_code  = mpa.accounting_line_type_code
       AND xlj.accounting_line_code       = mpa.accounting_line_code
       AND mpa.application_id             = jlt.application_id
       AND mpa.amb_context_code           = jlt.amb_context_code
       AND mpa.event_class_code           = jlt.event_class_code
       AND mpa.mpa_accounting_line_type_code  = jlt.accounting_line_type_code
       AND mpa.mpa_accounting_line_code       = jlt.accounting_line_code
       AND jlt.business_method_code      <> 'PRIOR_ENTRY'
       AND NOT EXISTS
           (SELECT 'Y'
              FROM xla_mpa_jlt_adr_assgns xad
             WHERE mpa.application_id             = xad.application_id
               AND mpa.amb_context_code           = xad.amb_context_code
               AND mpa.event_class_code           = xad.event_class_code
               AND mpa.event_type_code            = xad.event_type_code
               AND mpa.line_definition_owner_code = xad.line_definition_owner_code
               AND mpa.line_definition_code       = xad.line_definition_code
               AND mpa.accounting_line_type_code  = xad.accounting_line_type_code
               AND mpa.accounting_line_code       = xad.accounting_line_code
               AND mpa.mpa_accounting_line_type_code = xad.mpa_accounting_line_type_code
               AND mpa.mpa_accounting_line_code      = xad.mpa_accounting_line_code
               AND xad.flexfield_segment_code     = fif.application_column_name
            )
          AND NOT EXISTS
           (SELECT 'Y'
              FROM xla_mpa_jlt_adr_assgns xad
             WHERE mpa.application_id             = xad.application_id
               AND mpa.amb_context_code           = xad.amb_context_code
               AND mpa.event_class_code           = xad.event_class_code
               AND mpa.event_type_code            = xad.event_type_code
               AND mpa.line_definition_owner_code = xad.line_definition_owner_code
               AND mpa.line_definition_code       = xad.line_definition_code
               AND mpa.accounting_line_type_code  = xad.accounting_line_type_code
               AND mpa.accounting_line_code       = xad.accounting_line_code
               AND mpa.mpa_accounting_line_type_code = xad.mpa_accounting_line_type_code
               AND mpa.mpa_accounting_line_code      = xad.mpa_accounting_line_code
               AND xad.flexfield_segment_code     = 'ALL');

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_adr_assgn_complete';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_adr_assgn_complete'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  OPEN c_coa_id;
  FETCH c_coa_id INTO l_coa_id;
  CLOSE c_coa_id;

  IF (l_coa_id IS NULL) THEN
    --
    -- Check if all JLT assignments contain ADR assignments
    --
    FOR l_adr_assgns IN c_invalid_adrs_no_coa LOOP
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_INCOMPLETE_ACCT'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_TYPE'
              ,p_category_sequence          => 18
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_mpa_acct_line_type_code    => l_adr_assgns.mpa_accounting_line_type_code
              ,p_mpa_acct_line_code         => l_adr_assgns.mpa_accounting_line_code);
    END LOOP;
  ELSE
    FOR l_adr_assgns IN c_invalid_adrs LOOP
      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_INCOMPLETE_ACCT'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_LINE_TYPE'
              ,p_category_sequence          => 18
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_mpa_acct_line_type_code    => l_adr_assgns.mpa_accounting_line_type_code
              ,p_mpa_acct_line_code         => l_adr_assgns.mpa_accounting_line_code);
    END LOOP;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_adr_assgn_complete'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_adr_assgn_complete');
END chk_mpa_adr_assgn_complete;

--=============================================================================
--
-- Name: chk_mpa_adr_is_enabled
-- Description:
--
--=============================================================================
FUNCTION chk_mpa_adr_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_adrs IS
    SELECT distinct xsr.segment_rule_type_code, xsr.segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_mpa_jlt_adr_assgns   xad
          ,xla_seg_rules_b          xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.enabled_flag               <> 'Y'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y'
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)  ;


  CURSOR c_adr IS
    SELECT distinct xsr.application_id, xsr.amb_context_code,
                    xsr.segment_rule_type_code, xsr.segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_mpa_jlt_adr_assgns   xad
          ,xla_seg_rules_b          xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y'
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)  ;

    l_adr     c_adr%rowtype;

    CURSOR c_invalid_child_adr IS
    SELECT xsd.value_segment_rule_type_code, xsd.value_segment_rule_code
      FROM xla_seg_rule_details xsd
          ,xla_seg_rules_b      xsr
     WHERE xsd.application_id                   = l_adr.application_id
       AND xsd.amb_context_code                 = l_adr.amb_context_code
       AND xsd.segment_rule_type_code           = l_adr.segment_rule_type_code
       AND xsd.segment_rule_code                = l_adr.segment_rule_code
       AND xsd.value_type_code                  = 'A'
       AND xsd.value_segment_rule_appl_id   = xsr.application_id
       AND xsd.value_segment_rule_type_code = xsr.segment_rule_type_code
       AND xsd.value_segment_rule_code      = xsr.segment_rule_code
       AND xsd.amb_context_code             = xsr.amb_context_code
       AND xsr.enabled_flag                <> 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_adr_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_adr_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_adrs LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_SEG_RULE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code);

  END LOOP;

  OPEN c_adr;
  LOOP
     FETCH c_adr
      INTO l_adr;
     EXIT WHEN c_adr%notfound;

     FOR l_child_adr IN c_invalid_child_adr LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_SEG_RULE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.value_segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.value_segment_rule_code);

     END LOOP;
  END LOOP;
  CLOSE c_adr;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_adr_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_adr_is_enabled');
END chk_mpa_adr_is_enabled;

--=============================================================================
--
-- Name: chk_mpa_adr_has_details
-- Description:
--
--=============================================================================
FUNCTION chk_mpa_adr_has_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_adrs IS
   SELECT distinct xad.segment_rule_code, xad.segment_rule_type_code
     FROM xla_mpa_jlt_adr_assgns xad, xla_line_defn_jlt_assgns xjl
    WHERE xad.application_id             = xjl.application_id
      AND xad.amb_context_code           = xjl.amb_context_code
      AND xad.event_class_code           = xjl.event_class_code
      AND xad.event_type_code            = xjl.event_type_code
      AND xad.line_definition_code       = xjl.line_definition_code
      AND xad.line_definition_owner_code = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
      AND xad.accounting_line_code       = xjl.accounting_line_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xad.segment_rule_code          is not null
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'x'
             FROM xla_seg_rule_details xsr
            WHERE xsr.application_id         = NVL(xad.segment_rule_appl_id,xad.application_id)
              AND xsr.amb_context_code       = xad.amb_context_code
              AND xsr.segment_rule_type_code = xad.segment_rule_type_code
              AND xsr.segment_rule_code      = xad.segment_rule_code);

  CURSOR c_adr IS
    SELECT distinct xsr.application_id, xsr.amb_context_code,
                    xsr.segment_rule_type_code, xsr.segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_mpa_jlt_adr_assgns   xad
          ,xla_seg_rules_b          xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y'
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)  ;

    l_adr     c_adr%rowtype;

    CURSOR c_invalid_child_adr IS
    SELECT xsd.value_segment_rule_type_code, xsd.value_segment_rule_code
      FROM xla_seg_rule_details xsd
     WHERE xsd.application_id                   = l_adr.application_id
       AND xsd.amb_context_code                 = l_adr.amb_context_code
       AND xsd.segment_rule_type_code           = l_adr.segment_rule_type_code
       AND xsd.segment_rule_code                = l_adr.segment_rule_code
       AND xsd.value_type_code                  = 'A'
       AND not exists (SELECT 'x'
                         FROM xla_seg_rule_details xcd
                        WHERE xcd.application_id                   = xsd.value_segment_rule_appl_id
                          AND xcd.amb_context_code                 = xsd.amb_context_code
                          AND xcd.segment_rule_type_code           = xsd.value_segment_rule_type_code
                          AND xcd.segment_rule_code                = xsd.value_segment_rule_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_adr_has_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_adr_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_adrs LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code);
  END LOOP;

  OPEN c_adr;
  LOOP
     FETCH c_adr
      INTO l_adr;
     EXIT WHEN c_adr%notfound;

     FOR l_child_adr IN c_invalid_child_adr LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.value_segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.value_segment_rule_code);
     END LOOP;
  END LOOP;
  CLOSE c_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_adr_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_adrs%ISOPEN THEN
      CLOSE c_invalid_adrs;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_adr_has_details');
END chk_mpa_adr_has_details;


--=============================================================================
--
-- Name: chk_mpa_adr_inv_source_cond
-- Description: Check if all sources used in the ADR condition is valid
--
--=============================================================================
FUNCTION chk_mpa_adr_inv_source_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT that have sources that do not belong to the event class of the
  -- line definition
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code, xco.source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.source_type_code            = 'S'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                 = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id        = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.value_source_type_code      = 'S'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                 = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_cond_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.source_type_code            = 'D'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                   = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id              = xad.application_id
      AND xsr.amb_context_code            = xad.amb_context_code
      AND xsr.segment_rule_type_code      = xad.segment_rule_type_code
      AND xsr.segment_rule_code           = xad.segment_rule_code
      AND xco.value_source_type_code      = 'D'
      AND xad.application_id              = xjl.application_id
      AND xad.amb_context_code            = xjl.amb_context_code
      AND xad.event_class_code            = xjl.event_class_code
      AND xad.event_type_code             = xjl.event_type_code
      AND xad.line_definition_code        = xjl.line_definition_code
      AND xad.line_definition_owner_code  = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code   = xjl.accounting_line_type_code
      AND xad.accounting_line_code        = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id              = p_application_id
      AND xjl.amb_context_code            = p_amb_context_code
      AND xjl.event_class_code            = p_event_class_code
      AND xjl.event_type_code             = p_event_type_code
      AND xjl.line_definition_owner_code  = p_line_definition_owner_code
      AND xjl.line_definition_code        = p_line_definition_code
      AND xjl.active_flag                   = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code);

  CURSOR c_child_adr IS
    SELECT distinct xsr.value_segment_rule_appl_id,
                    xsr.value_segment_rule_type_code, xsr.value_segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_mpa_jlt_adr_assgns   xad
          ,xla_seg_rule_details    xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.value_type_code            = 'A'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y'
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code);

  l_child_adr     c_child_adr%rowtype;

  CURSOR c_invalid_child_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code, xco.source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.source_type_code            = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id        = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.value_source_type_code      = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = p_application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_child_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.source_type_code            = 'D'
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_seg_rule_details     xsr
    WHERE xco.segment_rule_detail_id      = xsr.segment_rule_detail_id
      AND xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xco.value_source_type_code      = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_adr_inv_source_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_adr_inv_source_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if the condition of any JLT have seeded sources that are not assigned
  -- to the event class of the line definition
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_CON_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_cond_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_CON_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
     END IF;
   END LOOP;

  OPEN c_child_adr;
  LOOP
     FETCH c_child_adr
      INTO l_child_adr;
     EXIT WHEN c_child_adr%notfound;

     FOR l_err IN c_invalid_child_sources LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_CON_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
     END LOOP;

     FOR l_err IN c_child_der_sources LOOP
       IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

         l_return := FALSE;
         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_CON_UNASN_SRCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
       END IF;
     END LOOP;
  END LOOP;
  CLOSE c_child_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_adr_inv_source_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_cond_der_sources%ISOPEN THEN
      CLOSE c_cond_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_cond_der_sources%ISOPEN THEN
      CLOSE c_cond_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_adr_inv_source_cond');
END chk_mpa_adr_inv_source_cond;


--=============================================================================
--
-- Name: chk_mpa_adr_source_event_class
-- Description: Check if all JLT of the line definition has all required
--              accounting sources assigned
--
--=============================================================================
FUNCTION chk_mpa_adr_source_event_class
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  --
  -- Get all JLT for which not all required line accounting sources are assigned
  --
  CURSOR c_invalid_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id             = xad.application_id
      AND xsr.amb_context_code           = xad.amb_context_code
      AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
      AND xsr.segment_rule_code          = xad.segment_rule_code
      AND xsr.value_source_type_code     = 'S'
      AND xad.application_id             = xjl.application_id
      AND xad.amb_context_code           = xjl.amb_context_code
      AND xad.line_definition_code       = xjl.line_definition_code
      AND xad.event_class_code           = xjl.event_class_code
      AND xad.event_type_code            = xjl.event_type_code
      AND xad.line_definition_owner_code = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
      AND xad.accounting_line_code       = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.value_source_application_id
              AND xes.source_type_code      = xsr.value_source_type_code
              AND xes.source_code           = xsr.value_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id             = xad.application_id
      AND xsr.amb_context_code           = xad.amb_context_code
      AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
      AND xsr.segment_rule_code          = xad.segment_rule_code
      AND xsr.input_source_type_code     = 'S'
      AND xad.application_id             = xjl.application_id
      AND xad.amb_context_code           = xjl.amb_context_code
      AND xad.line_definition_code       = xjl.line_definition_code
      AND xad.event_class_code           = xjl.event_class_code
      AND xad.event_type_code            = xjl.event_type_code
      AND xad.line_definition_owner_code = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
      AND xad.accounting_line_code       = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.input_source_application_id
              AND xes.source_type_code      = xsr.input_source_type_code
              AND xes.source_code           = xsr.input_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id                = xad.application_id
      AND xsr.amb_context_code              = xad.amb_context_code
      AND xsr.segment_rule_type_code        = xad.segment_rule_type_code
      AND xsr.segment_rule_code             = xad.segment_rule_code
      AND xsr.value_source_type_code        = 'D'
      AND xad.application_id                = xjl.application_id
      AND xad.amb_context_code              = xjl.amb_context_code
      AND xad.event_class_code              = xjl.event_class_code
      AND xad.event_type_code               = xjl.event_type_code
      AND xad.line_definition_code          = xjl.line_definition_code
      AND xad.line_definition_owner_code    = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code     = xjl.accounting_line_type_code
      AND xad.accounting_line_code          = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id                = p_application_id
      AND xjl.amb_context_code              = p_amb_context_code
      AND xjl.line_definition_owner_code    = p_line_definition_owner_code
      AND xjl.line_definition_code          = p_line_definition_code
      AND xjl.active_flag                   = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code)
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
    WHERE xsr.application_id                = xad.application_id
      AND xsr.amb_context_code              = xad.amb_context_code
      AND xsr.segment_rule_type_code        = xad.segment_rule_type_code
      AND xsr.segment_rule_code             = xad.segment_rule_code
      AND xsr.input_source_type_code        = 'D'
      AND xad.application_id                = xjl.application_id
      AND xad.amb_context_code              = xjl.amb_context_code
      AND xad.event_class_code              = xjl.event_class_code
      AND xad.event_type_code               = xjl.event_type_code
      AND xad.line_definition_code          = xjl.line_definition_code
      AND xad.line_definition_owner_code    = xjl.line_definition_owner_code
      AND xad.accounting_line_type_code     = xjl.accounting_line_type_code
      AND xad.accounting_line_code          = xjl.accounting_line_code
      AND xad.segment_rule_code           is not null
      AND xjl.application_id                = p_application_id
      AND xjl.amb_context_code              = p_amb_context_code
      AND xjl.line_definition_owner_code    = p_line_definition_owner_code
      AND xjl.line_definition_code          = p_line_definition_code
      AND xjl.active_flag                   = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code);


  CURSOR c_child_adr IS
    SELECT distinct xsr.value_segment_rule_appl_id,
                    xsr.value_segment_rule_type_code, xsr.value_segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_mpa_jlt_adr_assgns   xad
          ,xla_seg_rule_details    xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.value_type_code            = 'A'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y'
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code);

  l_child_adr     c_child_adr%rowtype;

  CURSOR c_invalid_child_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.value_source_type_code     = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.value_source_application_id
              AND xes.source_type_code      = xsr.value_source_type_code
              AND xes.source_code           = xsr.value_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y')
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.input_source_type_code     = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xsr.input_source_application_id
              AND xes.source_type_code      = xsr.input_source_type_code
              AND xes.source_code           = xsr.input_source_code
              AND xes.application_id        = xsr.application_id
              AND xes.event_class_code      = p_event_class_code
              AND xes.active_flag          = 'Y');

  CURSOR c_child_der_sources IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_source_type_code source_type_code, xsr.value_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.value_source_type_code        = 'D'
   UNION
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.input_source_type_code source_type_code, xsr.input_source_code source_code
     FROM xla_seg_rule_details     xsr
    WHERE xsr.application_id             = l_child_adr.value_segment_rule_appl_id
      AND xsr.amb_context_code           = p_amb_context_code
      AND xsr.segment_rule_type_code     = l_child_adr.value_segment_rule_type_code
      AND xsr.segment_rule_code          = l_child_adr.value_segment_rule_code
      AND xsr.input_source_type_code        = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_adr_source_event_class';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_adr_source_event_class'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  --
  -- Check if any JLT does not have all required line accounting sources
  --
  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_UNASSN_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;
      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_UNASSN_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
    END IF;
  END LOOP;


  OPEN c_child_adr;
  LOOP
     FETCH c_child_adr
      INTO l_child_adr;
     EXIT WHEN c_child_adr%notfound;

     FOR l_err IN c_invalid_child_sources LOOP
         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_UNASSN_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
     END LOOP;

     FOR l_err IN c_child_der_sources LOOP
       IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

         l_return := FALSE;
         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_SR_UNASSN_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
       END IF;
     END LOOP;
  END LOOP;
  CLOSE c_child_adr;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_adr_source_event_class'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_der_sources%ISOPEN THEN
      CLOSE c_der_sources;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_invalid_sources%ISOPEN THEN
      CLOSE c_invalid_sources;
    END IF;
    IF c_der_sources%ISOPEN THEN
      CLOSE c_der_sources;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_adr_source_event_class');

END chk_mpa_adr_source_event_class;


--======================================================================
--
-- Name: check_mpa_adr_has_loop
-- Description: Returns true if the ADR has an attached ADR which in
-- turn has another ADR attached
--
--======================================================================
FUNCTION check_mpa_adr_has_loop
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_log_module               VARCHAR2(240);

  l_return                   BOOLEAN := TRUE;
  l_exist                    VARCHAR2(1);

  CURSOR c_child_adr IS
    SELECT distinct xad.segment_rule_appl_id, xad.segment_rule_type_code,
                    xad.segment_rule_code,
                    xsr.value_segment_rule_appl_id,
                    xsr.value_segment_rule_type_code, xsr.value_segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_mpa_jlt_adr_assgns   xad
          ,xla_seg_rule_details    xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.value_type_code            = 'A'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y'
       AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code);

  l_child_adr     c_child_adr%rowtype;

  CURSOR c_adr_loop IS
  SELECT 'x'
    FROM xla_seg_rule_details xsd
   WHERE application_id         = l_child_adr.value_segment_rule_appl_id
     AND amb_context_code       = p_amb_context_code
     AND segment_rule_type_code = l_child_adr.value_segment_rule_type_code
     AND segment_rule_code      = l_child_adr.value_segment_rule_code
     AND value_type_code        = 'A';

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.check_mpa_adr_has_loop';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure check_mpa_adr_has_loop'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_child_adr;
  LOOP
     FETCH c_child_adr
      INTO l_child_adr;
     EXIT WHEN c_child_adr%notfound;

     OPEN c_adr_loop;
     FETCH c_adr_loop
      INTO l_exist;
     IF c_adr_loop%found THEN

         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_ADR_HAS_LOOP'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_SEG_RULE'
              ,p_category_sequence          => 21
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.segment_rule_code);

     END IF;
     CLOSE c_adr_loop;
  END LOOP;
  CLOSE c_child_adr;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure check_mpa_adr_has_loop'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.check_mpa_adr_has_loop');
END check_mpa_adr_has_loop;



--=============================================================================
--
-- Name: validate_mpa_line_adr
-- Description: Validate all ADR assigned to the MPA JLT of the line definition
--              is valid
-- Return Value:
--   TRUE - if all ADR assignments are valid
--   FALSE - if any ADR assignment is invalid
--
--=============================================================================
FUNCTION validate_mpa_line_adr
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_line_adr';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_line_adr'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_mpa_adr_assgn_complete
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_adr_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_adr_has_details
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_adr_inv_source_cond
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := chk_mpa_adr_source_event_class
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := check_mpa_adr_has_loop
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_line_adr'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_line_adr');
END validate_mpa_line_adr;


--=============================================================================
--
-- Name: chk_mpa_ms_is_enabled
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_ms_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_ms IS
   SELECT distinct xsr.segment_rule_code, xsr.segment_rule_type_code,
          xsr.value_mapping_set_code
     FROM xla_seg_rule_details     xsr
         ,xla_mpa_jlt_adr_assgns   xad
         ,xla_line_defn_jlt_assgns xjl
         ,xla_mapping_sets_b       xms
    WHERE xms.mapping_set_code               = xsr.value_mapping_set_code
      AND xms.amb_context_code               = xsr.amb_context_code
      AND xms.enabled_flag                   <> 'Y'
      AND xsr.application_id                 = xad.application_id
      AND xsr.amb_context_code               = xad.amb_context_code
      AND xsr.segment_rule_type_code         = xad.segment_rule_type_code
      AND xsr.segment_rule_code              = xad.segment_rule_code
      AND xsr.value_mapping_set_code         IS NOT NULL
      AND xad.application_id                 = xjl.application_id
      AND xad.amb_context_code               = xjl.amb_context_code
      AND xad.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xad.line_definition_code           = xjl.line_definition_code
      AND xad.event_class_code               = xjl.event_class_code
      AND xad.event_type_code                = xjl.event_type_code
      AND xad.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xad.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_line_defn_jlt_assgns    xld1
                       WHERE xld1.application_id             = xad.application_id
                         AND xld1.amb_context_code           = xad.amb_context_code
                         AND xld1.event_class_code           = xad.event_class_code
                         AND xld1.event_type_code            = xad.event_type_code
                         AND xld1.line_definition_owner_code = xad.line_definition_owner_code
                         AND xld1.line_definition_code       = xad.line_definition_code
                         AND xld1.accounting_line_type_code  = xad.mpa_accounting_line_type_code
                         AND xld1.accounting_line_code       = xad.mpa_accounting_line_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_ms_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_ms_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_ms LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_MAPPING_SET'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_MAPPING_SET'
              ,p_category_sequence          => 22
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_err.segment_rule_type_code
              ,p_segment_rule_code          => l_err.segment_rule_code
              ,p_mapping_set_code           => l_err.value_mapping_set_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_ms_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF (c_invalid_ms%ISOPEN) THEN
      CLOSE c_invalid_ms;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF (c_invalid_ms%ISOPEN) THEN
      CLOSE c_invalid_ms;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_ms_is_enabled');
END chk_mpa_ms_is_enabled;

--=============================================================================
--
-- Name: validate_mpa_line_ms
-- Description: Validate MPA Mapping Set assignment of the line definition
--
--=============================================================================
FUNCTION validate_mpa_line_ms
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_line_ms';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_line_ms'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_mpa_ms_is_enabled
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_line_ms'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_line_ms');
END validate_mpa_line_ms;


--=============================================================================
--
-- Name: validate_mpa_line_assgns
-- Description: Validate MPA Line assignment of the line definition
--
--=============================================================================
FUNCTION validate_mpa_line_assgns
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_line_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_line_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := validate_mpa_jlt_assgns
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := validate_mpa_line_desc
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := validate_mpa_line_ac
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := validate_mpa_line_adr
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := validate_mpa_line_ms
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

RETURN l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_line_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_line_assgns');
END validate_mpa_line_assgns;

--=============================================================================
--
-- Name: chk_mpa_hdr_desc_is_enabled
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_desc_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_hdr_desc IS
   SELECT distinct xdb.description_type_code, xdb.description_code
     FROM xla_line_defn_jlt_assgns xjl
         ,xla_descriptions_b       xdb
    WHERE xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xjl.mpa_header_desc_type_code  IS NOT NULL
      AND xdb.application_id             = xjl.application_id
      AND xdb.amb_context_code           = xjl.amb_context_code
      AND xdb.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdb.description_code           = xjl.mpa_header_desc_code
      AND xdb.enabled_flag               <> 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_desc_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_desc_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_hdr_desc LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_HDR_DESC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_DESC'
              ,p_category_sequence          => 15
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_description_type_code     => l_err.description_type_code
              ,p_description_code          => l_err.description_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_desc_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_desc_is_enabled');
END chk_mpa_hdr_desc_is_enabled;

--=============================================================================
--
-- Name: chk_mpa_hdr_desc_inv_src_dtl
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_desc_inv_src_dtl
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_sources IS
   SELECT distinct xjl.mpa_header_desc_type_code, xjl.mpa_header_desc_code,
          xdd.source_type_code, xdd.source_code
     FROM xla_descript_details_b   xdd
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xdd.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdp.description_code           = xjl.mpa_header_desc_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xdd.source_type_code           = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xdd.source_application_id
              AND xes.source_type_code      = xdd.source_type_code
              AND xes.source_code           = xdd.source_code
              AND xes.application_id        = xjl.application_id
              AND xes.event_class_code      = xjl.event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xjl.mpa_header_desc_type_code, xjl.mpa_header_desc_code,
          xdd.source_type_code, xdd.source_code
     FROM xla_descript_details_b   xdd
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xdd.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdp.description_code           = xjl.mpa_header_desc_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xdd.source_type_code           = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_desc_inv_src_dtl';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_desc_inv_src_dtl'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_DES_DET_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_DESC'
              ,p_category_sequence          => 15
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.mpa_header_desc_type_code
              ,p_description_code           => l_err.mpa_header_desc_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_DES_DET_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_DESC'
              ,p_category_sequence          => 15
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.mpa_header_desc_type_code
              ,p_description_code           => l_err.mpa_header_desc_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);

    END IF;
  END LOOP;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_desc_inv_src_dtl'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_desc_inv_src_dtl');
END chk_mpa_hdr_desc_inv_src_dtl;

--=============================================================================
--
-- Name: chk_mpa_hdr_desc_inv_src_cond
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_desc_inv_src_cond
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_sources IS
   SELECT distinct xjl.mpa_header_desc_type_code, xjl.mpa_header_desc_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdp.description_code           = xjl.mpa_header_desc_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.source_type_code           = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.source_application_id
              AND xes.source_type_code      = xco.source_type_code
              AND xes.source_code           = xco.source_code
              AND xes.application_id        = xjl.application_id
              AND xes.event_class_code      = xjl.event_class_code
              AND xes.active_flag           = 'Y')
   UNION
   SELECT distinct xjl.mpa_header_desc_type_code, xjl.mpa_header_desc_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdp.description_code           = xjl.mpa_header_desc_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.value_source_type_code     = 'S'
      AND NOT EXISTS
          (SELECT 'y'
             FROM xla_event_sources xes
            WHERE xes.source_application_id = xco.value_source_application_id
              AND xes.source_type_code      = xco.value_source_type_code
              AND xes.source_code           = xco.value_source_code
              AND xes.application_id        = xjl.application_id
              AND xes.event_class_code      = xjl.event_class_code
              AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xjl.mpa_header_desc_type_code, xjl.mpa_header_desc_code,
          xco.source_type_code source_type_code, xco.source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdp.description_code           = xjl.mpa_header_desc_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.source_type_code           = 'D'
   UNION
   SELECT distinct xjl.mpa_header_desc_type_code, xjl.mpa_header_desc_code,
          xco.value_source_type_code source_type_code, xco.value_source_code source_code
     FROM xla_conditions           xco
         ,xla_desc_priorities      xdp
         ,xla_line_defn_jlt_assgns xjl
    WHERE xco.description_prio_id        = xdp.description_prio_id
      AND xdp.application_id             = xjl.application_id
      AND xdp.amb_context_code           = xjl.amb_context_code
      AND xdp.description_type_code      = xjl.mpa_header_desc_type_code
      AND xdp.description_code           = xjl.mpa_header_desc_code
      AND xjl.application_id             = p_application_id
      AND xjl.amb_context_code           = p_amb_context_code
      AND xjl.event_class_code           = p_event_class_code
      AND xjl.event_type_code            = p_event_type_code
      AND xjl.line_definition_owner_code = p_line_definition_owner_code
      AND xjl.line_definition_code       = p_line_definition_code
      AND xjl.active_flag                = 'Y'
      AND xco.value_source_type_code     = 'D';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_desc_inv_src_cond';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_desc_inv_src_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_sources LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_DES_CON_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_DESC'
              ,p_category_sequence          => 15
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.mpa_header_desc_type_code
              ,p_description_code           => l_err.mpa_header_desc_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L') = 'TRUE' THEN

      l_return := FALSE;

      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_DES_CON_SRC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_DESC'
              ,p_category_sequence          => 15
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_description_type_code      => l_err.mpa_header_desc_type_code
              ,p_description_code           => l_err.mpa_header_desc_code
              ,p_source_type_code           => l_err.source_type_code
              ,p_source_code                => l_err.source_code);

    END IF;
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_desc_inv_src_cond'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_desc_inv_src_cond');
END chk_mpa_hdr_desc_inv_src_cond;

--=============================================================================
--
-- Name: chk_mpa_hdr_ac_is_enabled
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_ac_is_enabled
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_line_ac IS
   SELECT distinct xah.analytical_criterion_type_code, xah.analytical_criterion_code
     FROM xla_mpa_header_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_analytical_hdrs_b    xah
    WHERE xah.amb_context_code               = xac.amb_context_code
      AND xah.analytical_criterion_code      = xac.analytical_criterion_code
      AND xah.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xah.enabled_flag                   <> 'Y'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_ac_is_enabled';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_ac_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_line_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_DISABLD_HDR_AC'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_AC'
              ,p_category_sequence          => 16
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_ac_is_enabled'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_ac_is_enabled');
END chk_mpa_hdr_ac_is_enabled;

--=============================================================================
--
-- Name: chk_mpa_hdr_ac_bal
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_ac_bal
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_line_ac IS
   SELECT distinct xah.analytical_criterion_type_code, xah.analytical_criterion_code
     FROM xla_mpa_header_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_analytical_hdrs_b    xah
    WHERE xah.amb_context_code               = xac.amb_context_code
      AND xah.analytical_criterion_code      = xac.analytical_criterion_code
      AND xah.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xah.balancing_flag                 = 'Y'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_ac_bal';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_ac_bal'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_line_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_ANC_MAINTAIN_BAL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_AC'
              ,p_category_sequence          => 16
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_ac_bal'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_ac_bal');
END chk_mpa_hdr_ac_bal;

--=============================================================================
--
-- Name: chk_mpa_hdr_ac_has_details
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_ac_has_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_ac IS
   SELECT distinct xac.analytical_criterion_type_code, xac.analytical_criterion_code
     FROM xla_mpa_header_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
    WHERE xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND NOT EXISTS
          (SELECT 'x'
             FROM xla_analytical_sources  xas
            WHERE xas.application_id                 = xac.application_id
              AND xas.amb_context_code               = xac.amb_context_code
              AND xas.event_class_code               = xac.event_class_code
              AND xas.analytical_criterion_code      = xac.analytical_criterion_code
              AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code);

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_ac_has_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_ac_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_ac LOOP
    l_return := FALSE;

    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_ANC_NO_DETAIL'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_AC'
              ,p_category_sequence          => 16
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code);
  END LOOP;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_ac_has_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_ac_has_details');
END chk_mpa_hdr_ac_has_details;

--=============================================================================
--
-- Name: chk_mpa_hdr_ac_inv_sources
-- Description: Check if all mapping sets assigned to the line definition
--              are enabled
--
--=============================================================================
FUNCTION chk_mpa_hdr_ac_inv_sources
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_invalid_sources IS
   SELECT distinct  xas.analytical_criterion_type_code, xas.analytical_criterion_code,
          xas.source_code, xas.source_type_code
     FROM xla_analytical_sources   xas
         ,xla_mpa_header_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
         ,xla_event_sources        xes
    WHERE xas.application_id                 = xac.application_id
      AND xas.amb_context_code               = xac.amb_context_code
      AND xas.event_class_code               = xac.event_class_code
      AND xas.analytical_criterion_code      = xac.analytical_criterion_code
      AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xas.source_type_code               = 'S'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y'
      AND not exists (SELECT 'y'
                        FROM xla_event_sources xes
                       WHERE xes.source_application_id = xas.source_application_id
                         AND xes.source_type_code      = xas.source_type_code
                         AND xes.source_code           = xas.source_code
                         AND xes.application_id        = xas.application_id
                         AND xes.event_class_code      = xas.event_class_code
                         AND xes.active_flag           = 'Y');

  CURSOR c_der_sources IS
   SELECT distinct xas.analytical_criterion_type_code, xas.analytical_criterion_code,
          xas.source_code, xas.source_type_code
     FROM xla_analytical_sources   xas
         ,xla_mpa_header_ac_assgns  xac
         ,xla_line_defn_jlt_assgns xjl
    WHERE xas.application_id                 = xac.application_id
      AND xas.amb_context_code               = xac.amb_context_code
      AND xas.event_class_code               = xac.event_class_code
      AND xas.analytical_criterion_code      = xac.analytical_criterion_code
      AND xas.analytical_criterion_type_code = xac.analytical_criterion_type_code
      AND xas.source_type_code               = 'D'
      AND xac.application_id                 = xjl.application_id
      AND xac.amb_context_code               = xjl.amb_context_code
      AND xac.event_class_code               = xjl.event_class_code
      AND xac.event_type_code                = xjl.event_type_code
      AND xac.line_definition_code           = xjl.line_definition_code
      AND xac.line_definition_owner_code     = xjl.line_definition_owner_code
      AND xac.accounting_line_type_code      = xjl.accounting_line_type_code
      AND xac.accounting_line_code           = xjl.accounting_line_code
      AND xjl.application_id                 = p_application_id
      AND xjl.amb_context_code               = p_amb_context_code
      AND xjl.event_class_code               = p_event_class_code
      AND xjl.event_type_code                = p_event_type_code
      AND xjl.line_definition_owner_code     = p_line_definition_owner_code
      AND xjl.line_definition_code           = p_line_definition_code
      AND xjl.active_flag                    = 'Y';

  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.chk_mpa_hdr_ac_inv_sources';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure chk_mpa_hdr_ac_inv_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  FOR l_err IN c_invalid_sources LOOP

    l_return := FALSE;
    xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_ANC_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_AC'
              ,p_category_sequence          => 16
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code
              ,p_source_code                => l_err.source_code
              ,p_source_type_code           => l_err.source_type_code);
  END LOOP;

  FOR l_err IN c_der_sources LOOP
    IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_err.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

      l_return := FALSE;
      xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_MPA_HDR_ANC_SOURCE'
              ,p_message_type               => 'E'
              ,p_message_category           => 'MPA_HDR_AC'
              ,p_category_sequence          => 16
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_anal_criterion_type_code   => l_err.analytical_criterion_type_code
              ,p_anal_criterion_code        => l_err.analytical_criterion_code
              ,p_source_code                => l_err.source_code
              ,p_source_type_code           => l_err.source_type_code);
    END IF;
  END LOOP;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure chk_mpa_hdr_ac_inv_sources'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.chk_mpa_hdr_ac_inv_sources');
END chk_mpa_hdr_ac_inv_sources;


--=============================================================================
--
-- Name: validate_mpa_header_assgns
-- Description: Validate MPA Header assignment of the line definition
--
--=============================================================================
FUNCTION validate_mpa_header_assgns
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_mpa_header_assgns';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_mpa_header_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  l_return := chk_mpa_hdr_desc_is_enabled
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := chk_mpa_hdr_desc_inv_src_cond
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := chk_mpa_hdr_desc_inv_src_dtl
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := chk_mpa_hdr_ac_is_enabled
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := chk_mpa_hdr_ac_bal
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := chk_mpa_hdr_ac_has_details
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

  l_return := chk_mpa_hdr_ac_inv_sources
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

RETURN l_return;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_mpa_header_assgns'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_mpa_header_assgns');
END validate_mpa_header_assgns;



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
-- Name: delete_line_defn_details
-- Description: Deletes all details of the line definition
--
--=============================================================================
PROCEDURE delete_line_defn_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_line_defn_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_line_defn_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE
    FROM xla_line_defn_adr_assgns
   WHERE application_id             = p_application_id
     AND amb_context_code           = p_amb_context_code
     AND event_class_code           = p_event_class_code
     AND event_type_code            = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code       = p_line_definition_code;

  DELETE
    FROM xla_line_defn_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code;

  DELETE
    FROM xla_line_defn_jlt_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code;

  DELETE
    FROM xla_mpa_header_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code;

  DELETE
    FROM xla_mpa_jlt_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code;

  DELETE
    FROM xla_mpa_jlt_adr_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code;

  DELETE
    FROM xla_mpa_jlt_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_line_defn_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.delete_line_defn_details');
END delete_line_defn_details;

--=============================================================================
--
-- Name: delete_line_defn_jlt_details
-- Description: Deletes all details of the line assignment
--
--=============================================================================
PROCEDURE delete_line_defn_jlt_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code        IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_line_defn_jlt_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_line_defn_jlt_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code||
                      ',accounting_line_type_code = '||p_accounting_line_type_code||
                      ',accounting_line_code = '||p_accounting_line_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE
    FROM xla_line_defn_adr_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code;

  DELETE
    FROM xla_line_defn_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code;

  -- Added for MPA project.  4262811.
  DELETE
    FROM xla_mpa_header_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code;

  DELETE
    FROM xla_mpa_jlt_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code;

  DELETE
    FROM xla_mpa_jlt_adr_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code;

  DELETE
    FROM xla_mpa_jlt_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_line_defn_jlt_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.delete_line_defn_jlt_details');
END delete_line_defn_jlt_details;

--=============================================================================
--
-- Name: copy_line_definition_details
-- Description: Copies the details of an existing line definition into the new
--              one
--
--=============================================================================
PROCEDURE copy_line_definition_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_old_line_defn_owner_code         IN VARCHAR2
  ,p_old_line_defn_code               IN VARCHAR2
  ,p_new_line_defn_owner_code         IN VARCHAR2
  ,p_new_line_defn_code               IN VARCHAR2
  ,p_old_accounting_coa_id            IN NUMBER
  ,p_new_accounting_coa_id            IN NUMBER)
IS
  l_creation_date                   DATE := sysdate;
  l_last_update_date                DATE := sysdate;
  l_created_by                      INTEGER := xla_environment_pkg.g_usr_id;
  l_last_update_login               INTEGER := xla_environment_pkg.g_login_id;
  l_last_updated_by                 INTEGER := xla_environment_pkg.g_usr_id;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.copy_line_definition_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure copy_line_definition_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',old_line_definition_owner_code = '||p_old_line_defn_owner_code||
                      ',old_line_definition_owner_code = '||p_old_line_defn_owner_code||
                      ',old_line_defn_code = '||p_old_line_defn_code||
                      ',new_line_defn_owner_code = '||p_new_line_defn_owner_code||
                      ',new_line_defn_code = '||p_new_line_defn_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
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
            ,object_version_number
            ,inherit_desc_flag
	    ,mpa_header_desc_code
	    ,mpa_header_desc_type_code
	    ,mpa_num_je_code
	    ,mpa_gl_dates_code
	    ,mpa_proration_code
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
    SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,description_type_code
            ,description_code
            ,active_flag
            ,1
            ,inherit_desc_flag
	    ,mpa_header_desc_code
	    ,mpa_header_desc_type_code
	    ,mpa_num_je_code
	    ,mpa_gl_dates_code
	    ,mpa_proration_code
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
      FROM xla_line_defn_jlt_assgns
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_old_line_defn_owner_code
       AND line_definition_code       = p_old_line_defn_code;

  INSERT INTO xla_mpa_header_ac_assgns
            (application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,line_definition_owner_code
            ,line_definition_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,analytical_criterion_type_code
            ,analytical_criterion_code
            ,object_version_number
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
    SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,analytical_criterion_type_code
            ,analytical_criterion_code
            ,1
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
      FROM xla_mpa_header_ac_assgns
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_old_line_defn_owner_code
       AND line_definition_code       = p_old_line_defn_code;

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
            ,object_version_number
            ,inherit_desc_flag
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
    SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
	    ,mpa_accounting_line_type_code
	    ,mpa_accounting_line_code
	    ,description_type_code
            ,description_code
            ,1
            ,inherit_desc_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
      FROM xla_mpa_jlt_assgns
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_old_line_defn_owner_code
       AND line_definition_code       = p_old_line_defn_code;


  IF p_new_accounting_coa_id is not null and p_old_accounting_coa_id is null THEN

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
            ,side_code
            ,object_version_number
            ,inherit_adr_flag
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
       SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,flexfield_segment_code
            ,adr_version_num
            ,segment_rule_appl_id
            ,segment_rule_type_code
            ,segment_rule_code
            ,side_code
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
         FROM xla_line_defn_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_old_line_defn_owner_code
          AND line_definition_code       = p_old_line_defn_code
          AND flexfield_segment_code     = 'ALL'
       UNION
       SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,xla_flex_pkg.get_qualifier_segment
               (101
               ,'GL#'
               ,p_new_accounting_coa_id
               ,flexfield_segment_code)
            ,adr_version_num
            ,segment_rule_appl_id
            ,segment_rule_type_code
            ,segment_rule_code
            ,side_code
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
         FROM xla_line_defn_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_old_line_defn_owner_code
          AND line_definition_code       = p_old_line_defn_code
          AND flexfield_segment_code     <> 'ALL';

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
            ,object_version_number
            ,inherit_adr_flag
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
       SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
	    ,mpa_accounting_line_type_code
	    ,mpa_accounting_line_code
	    ,flexfield_segment_code
            ,segment_rule_type_code
            ,segment_rule_code
	    ,segment_rule_appl_id
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
         FROM xla_mpa_jlt_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_old_line_defn_owner_code
          AND line_definition_code       = p_old_line_defn_code
          AND flexfield_segment_code     = 'ALL'
       UNION
       SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
	    ,mpa_accounting_line_type_code
	    ,mpa_accounting_line_code
            ,xla_flex_pkg.get_qualifier_segment
               (101
               ,'GL#'
               ,p_new_accounting_coa_id
               ,flexfield_segment_code)
            ,segment_rule_type_code
            ,segment_rule_code
	    ,segment_rule_appl_id
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
         FROM xla_mpa_jlt_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_old_line_defn_owner_code
          AND line_definition_code       = p_old_line_defn_code
          AND flexfield_segment_code     <> 'ALL';

  ELSE

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
            ,segment_rule_type_code
            ,segment_rule_code
            ,segment_rule_appl_id
            ,side_code
            ,object_version_number
            ,inherit_adr_flag
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
       SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,flexfield_segment_code
            ,adr_version_num
            ,segment_rule_type_code
            ,segment_rule_code
            ,segment_rule_appl_id
            ,side_code
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
         FROM xla_line_defn_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_old_line_defn_owner_code
          AND line_definition_code       = p_old_line_defn_code;

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
            ,object_version_number
            ,inherit_adr_flag
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
       SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
	    ,mpa_accounting_line_type_code
	    ,mpa_accounting_line_code
            ,flexfield_segment_code
            ,segment_rule_type_code
            ,segment_rule_code
            ,segment_rule_appl_id
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
         FROM xla_mpa_jlt_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_old_line_defn_owner_code
          AND line_definition_code       = p_old_line_defn_code;

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
            ,analytical_criterion_type_code
            ,analytical_criterion_code
            ,object_version_number
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
    SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
            ,analytical_criterion_type_code
            ,analytical_criterion_code
            ,1
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
      FROM xla_line_defn_ac_assgns
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_old_line_defn_owner_code
       AND line_definition_code       = p_old_line_defn_code;

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
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,p_new_line_defn_owner_code
            ,p_new_line_defn_code
            ,accounting_line_type_code
            ,accounting_line_code
	    ,mpa_accounting_line_type_code
	    ,mpa_accounting_line_code
            ,analytical_criterion_type_code
            ,analytical_criterion_code
	    ,mpa_inherit_ac_flag
            ,1
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
      FROM xla_mpa_jlt_ac_assgns
     WHERE application_id             = p_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND line_definition_owner_code = p_old_line_defn_owner_code
       AND line_definition_code       = p_old_line_defn_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure copy_line_definition_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;


EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.copy_line_definition_details');
END copy_line_definition_details;

--=============================================================================
--
-- Name: line_definition_in_use
-- Description: Returns true if the line definition is assigned to an
--              accounting method
--
--=============================================================================
FUNCTION line_definition_in_use
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_owner               IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_aads
  IS
  SELECT xpr.name product_rule_name
        ,xlk.meaning product_rule_owner
    FROM xla_aad_line_defn_assgns  xal
        ,xla_product_rules_tl      xpr
        ,xla_lookups               xlk
   WHERE xpr.application_id             = xal.application_id
     AND xpr.amb_context_code           = xal.amb_context_code
     AND xpr.product_rule_type_code     = xal.product_rule_type_code
     AND xpr.product_rule_code          = xal.product_rule_code
     AND xpr.language                   = USERENV('LANG')
     AND xlk.lookup_type                = 'XLA_OWNER_TYPE'
     AND xlk.lookup_code                = xal.product_rule_type_code
     AND xal.application_id             = p_application_id
     AND xal.amb_context_code           = p_amb_context_code
     AND xal.event_class_code           = p_event_class_code
     AND xal.event_type_code            = p_event_type_code
     AND xal.line_definition_owner_code = p_line_definition_owner_code
     AND xal.line_definition_code       = p_line_definition_code;

  l_aad         c_aads%ROWTYPE;
  l_return      BOOLEAN;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.line_definition_in_use';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure line_definition_in_use'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '             ||p_application_id
                    ||',amb_context_code = '          ||p_amb_context_code
                    ||',event_class_code = '          ||p_event_class_code
                    ||',event_type_code = '           ||p_event_type_code
                    ||',line_definition_owner_code = '||p_line_definition_owner_code
                    ||',line_definition_code = '      ||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   OPEN c_aads;
   FETCH c_aads INTO l_aad;
   IF c_aads%FOUND THEn
     x_product_rule_name  := l_aad.product_rule_name;
     x_product_rule_owner := l_aad.product_rule_owner;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'found aad: product_rule_name = '||x_product_rule_name
                      ||',product_rule_owner = '         ||x_product_rule_owner
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_STATEMENT);
    END IF;

     l_return := TRUE;
   ELSE
     l_return := FALSE;
   END IF;
   CLOSE c_aads;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure line_definition_in_use'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_aads%ISOPEN THEN
      CLOSE c_aads;
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF c_aads%ISOPEN THEN
      CLOSE c_aads;
    END IF;
    xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_definitions_pvt.line_definition_in_use');

END line_definition_in_use;

--=============================================================================
--
-- Name: line_definition_is_locked
-- Description: Returns true if the line definition is assigned to an
--              accounting method
--
--=============================================================================
FUNCTION line_definition_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_owner               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_aads
  IS
  SELECT xpa.entity_code, xpa.product_rule_type_code, xpa.product_rule_code
        ,xpa.locking_status_flag
    FROM xla_aad_line_defn_assgns  xal
        ,xla_prod_acct_headers     xpa
   WHERE xpa.application_id             = xal.application_id
     AND xpa.amb_context_code           = xal.amb_context_code
     AND xpa.product_rule_type_code     = xal.product_rule_type_code
     AND xpa.product_rule_code          = xal.product_rule_code
     AND xpa.event_class_code           = xal.event_class_code
     AND xpa.event_type_code            = xal.event_type_code
     AND xpa.locking_status_flag        = 'Y'
     AND xal.application_id             = p_application_id
     AND xal.amb_context_code           = p_amb_context_code
     AND xal.event_class_code           = p_event_class_code
     AND xal.event_type_code            = p_event_type_code
     AND xal.line_definition_owner_code = p_line_definition_owner_code
     AND xal.line_definition_code       = p_line_definition_code;

  l_aad              c_aads%ROWTYPE;
  l_application_name varchar2(80);
  l_return           BOOLEAN;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.line_definition_is_locked';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure line_definition_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '             ||p_application_id
                    ||',amb_context_code = '          ||p_amb_context_code
                    ||',event_class_code = '          ||p_event_class_code
                    ||',event_type_code = '           ||p_event_type_code
                    ||',line_definition_owner_code = '||p_line_definition_owner_code
                    ||',line_definition_code = '      ||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   OPEN c_aads;
   FETCH c_aads INTO l_aad;
   IF c_aads%FOUND THEN

     xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => p_amb_context_code
           ,p_product_rule_type_code  => l_aad.product_rule_type_code
           ,p_product_rule_code       => l_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => x_product_rule_name
           ,p_product_rule_type       => x_product_rule_owner);

    xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_aad.entity_code
           ,p_event_class_code        => p_event_class_code
           ,p_event_class_name        => x_event_class_name);

    xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_aad.entity_code
           ,p_event_class_code        => p_event_class_code
           ,p_event_type_code         => p_event_type_code
           ,p_event_type_name         => x_event_type_name);

    x_locking_status_flag := l_aad.locking_status_flag;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'found aad: product_rule_name = '||x_product_rule_name
                      ||',product_rule_owner = '         ||x_product_rule_owner
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_STATEMENT);
    END IF;

     l_return := TRUE;
   ELSE
     l_return := FALSE;
   END IF;
   CLOSE c_aads;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure line_definition_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_aads%ISOPEN THEN
      CLOSE c_aads;
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF c_aads%ISOPEN THEN
      CLOSE c_aads;
    END IF;
    xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_definitions_pvt.line_definition_is_locked');

END line_definition_is_locked;

--=============================================================================
--
-- Name: line_definition_is_locked
-- Description: Returns true if the line definition is assigned to an
--              accounting method
--
--=============================================================================
FUNCTION line_definition_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_aads
  IS
  SELECT xpa.entity_code, xpa.product_rule_type_code, xpa.product_rule_code
        ,xpa.locking_status_flag
    FROM xla_aad_line_defn_assgns  xal
        ,xla_prod_acct_headers     xpa
   WHERE xpa.application_id             = xal.application_id
     AND xpa.amb_context_code           = xal.amb_context_code
     AND xpa.product_rule_type_code     = xal.product_rule_type_code
     AND xpa.product_rule_code          = xal.product_rule_code
     AND xpa.event_class_code           = xal.event_class_code
     AND xpa.event_type_code            = xal.event_type_code
     AND xpa.locking_status_flag        = 'Y'
     AND xal.application_id             = p_application_id
     AND xal.amb_context_code           = p_amb_context_code
     AND xal.event_class_code           = p_event_class_code
     AND xal.event_type_code            = p_event_type_code
     AND xal.line_definition_owner_code = p_line_definition_owner_code
     AND xal.line_definition_code       = p_line_definition_code;

  l_aad              c_aads%ROWTYPE;
  l_return           BOOLEAN;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.line_definition_is_locked';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure line_definition_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '             ||p_application_id
                    ||',amb_context_code = '          ||p_amb_context_code
                    ||',event_class_code = '          ||p_event_class_code
                    ||',event_type_code = '           ||p_event_type_code
                    ||',line_definition_owner_code = '||p_line_definition_owner_code
                    ||',line_definition_code = '      ||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

   OPEN c_aads;
   FETCH c_aads INTO l_aad;
   IF c_aads%FOUND THEN

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace(p_msg    => 'found aad: '||l_aad.product_rule_code||','
                      ||l_aad.product_rule_code
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_STATEMENT);
    END IF;

     l_return := TRUE;
   ELSE
     l_return := FALSE;
   END IF;
   CLOSE c_aads;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure line_definition_is_locked'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_aads%ISOPEN THEN
      CLOSE c_aads;
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF c_aads%ISOPEN THEN
      CLOSE c_aads;
    END IF;
    xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_definitions_pvt.line_definition_is_locked');

END line_definition_is_locked;

--=============================================================================
--
-- Name: invalid_line_description
-- Description: Returns true if sources for the line description are invalid
--
--=============================================================================
FUNCTION invalid_line_description
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2)
RETURN VARCHAR2
IS
  l_return      VARCHAR2(30);
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.line_definition_in_use';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure line_definition_in_use'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',description_type_code = '||p_description_type_code||
                      ',description_code = '||p_description_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- call invalid_line_desc to see if description is invalid
  --
  IF xla_line_definitions_pvt.invalid_line_desc
           (p_application_id           => p_application_id
           ,p_amb_context_code         => p_amb_context_code
           ,p_entity_code              => p_entity_code
           ,p_event_class_code         => p_event_class_code
           ,p_description_type_code    => p_description_type_code
           ,p_description_code         => p_description_code) THEN

    l_return := 'TRUE';
  ELSE
    l_return := 'FALSE';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure line_definition_in_use'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.invalid_line_description');
END invalid_line_description;

--=============================================================================
--
-- Name: invalid_segment_rule
-- Description: Returns true if sources for the seg rule are invalid
--
--=============================================================================
FUNCTION invalid_segment_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_segment_rule_appl_id             IN NUMBER   DEFAULT NULL
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN VARCHAR2
IS
  l_return                  VARCHAR2(30);

  CURSOR c_adr
  IS
  SELECT value_segment_rule_appl_id
        ,value_segment_rule_type_code
        ,value_segment_rule_code
    FROM xla_seg_rule_details
   WHERE application_id         = p_application_id
     AND amb_context_code       = p_amb_context_code
     AND segment_rule_type_code = p_segment_rule_type_code
     AND segment_rule_code      = p_segment_rule_code
     AND value_type_code        = 'A';

  l_adr   c_adr%rowtype;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.invalid_segment_rule';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure invalid_segment_rule'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',segment_rule_type_code = '||p_segment_rule_type_code||
                      ',segment_rule_code = '||p_segment_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- call invalid_seg_rule to see if segment rule is invalid
  --
  IF xla_line_definitions_pvt.invalid_seg_rule
           (p_application_id           => p_application_id
           ,p_amb_context_code         => p_amb_context_code
           ,p_entity_code              => p_entity_code
           ,p_event_class_code         => p_event_class_code
           ,p_segment_rule_appl_id     => p_segment_rule_appl_id
           ,p_segment_rule_type_code   => p_segment_rule_type_code
           ,p_segment_rule_code        => p_segment_rule_code) THEN

    l_return := 'TRUE';
  ELSE
    l_return := 'FALSE';
  END IF;

  IF l_return = 'FALSE' THEN
     OPEN c_adr;
     LOOP
        FETCH c_adr
         INTO l_adr;
        EXIT WHEN c_adr%notfound or l_return = 'TRUE';

        IF xla_line_definitions_pvt.invalid_seg_rule
                (p_application_id           => p_application_id
                ,p_amb_context_code         => p_amb_context_code
                ,p_entity_code              => p_entity_code
                ,p_event_class_code         => p_event_class_code
                ,p_segment_rule_appl_id     => l_adr.value_segment_rule_appl_id
                ,p_segment_rule_type_code   => l_adr.value_segment_rule_type_code
                ,p_segment_rule_code        => l_adr.value_segment_rule_code) THEN

           l_return := 'TRUE';
        ELSE
           l_return := 'FALSE';
        END IF;
     END LOOP;
     CLOSE c_adr;

  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure invalid_segment_rule'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_definitions_pvt.invalid_segment_rule');

END invalid_segment_rule;

--=============================================================================
--
-- Name: uncompile_aads
-- Description: Returns true if the application accounting definition gets
--              uncompiled
--
--=============================================================================
FUNCTION uncompile_aads
  (p_amb_context_code                 IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
  l_application_name        VARCHAR2(80);

  CURSOR c_lock_aads IS
    SELECT xpa.entity_code
          ,xpa.event_class_code
          ,xpa.event_type_code
          ,xpa.product_rule_type_code
          ,xpa.product_rule_code
          ,xpa.locking_status_flag
          ,xpa.validation_status_code
      FROM xla_aad_line_defn_assgns   xal
          ,xla_prod_acct_headers      xpa
     WHERE xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.product_rule_type_code     = xal.product_rule_type_code
       AND xpa.product_rule_code          = xal.product_rule_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xal.application_id             = p_application_id
       AND xal.amb_context_code           = p_amb_context_code
       AND xal.event_class_code           = p_event_class_code
       AND xal.event_type_code            = p_event_type_code
       AND xal.line_definition_owner_code = p_line_definition_owner_code
       AND xal.line_definition_code       = p_line_definition_code
    FOR UPDATE NOWAIT;

  CURSOR c_update_aads IS
    SELECT xal.event_class_code
         , xal.product_rule_type_code
         , xal.product_rule_code
      FROM xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.product_rule_type_code     = xal.product_rule_type_code
       AND xpa.product_rule_code          = xal.product_rule_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xal.application_id             = p_application_id
       AND xal.amb_context_code           = p_amb_context_code
       AND xal.event_class_code           = p_event_class_code
       AND xal.event_type_code            = p_event_type_code
       AND xal.line_definition_owner_code = p_line_definition_owner_code
       AND xal.line_definition_code       = p_line_definition_code
    FOR UPDATE NOWAIT;

  l_event_class_codes       t_array_codes;
  l_product_rule_type_codes t_array_type_codes;
  l_product_rule_codes      t_array_codes;

  l_return                  BOOLEAN;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.uncompile_aads';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure uncompile_aads'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'BEGIN LOOP - uncompile aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  l_return := TRUE;

  FOR l_aad IN c_lock_aads LOOP
    IF (l_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
        l_aad.locking_status_flag    = 'Y') THEN

      IF (C_LEVEL_ERROR >= g_log_level) THEN
        trace(p_msg    => 'Found locked aad: '||
                           l_aad.event_class_code||','||
                           l_aad.event_type_code||','||
                           l_aad.product_rule_code||','||
                           l_aad.product_rule_type_code,
              p_module => l_log_module,
              p_level  => C_LEVEL_ERROR);
      END IF;

      xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => p_amb_context_code
           ,p_product_rule_type_code  => l_aad.product_rule_type_code
           ,p_product_rule_code       => l_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => x_product_rule_name
           ,p_product_rule_type       => x_product_rule_type);

      xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_aad.entity_code
           ,p_event_class_code        => l_aad.event_class_code
           ,p_event_class_name        => x_event_class_name);

      xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_aad.entity_code
           ,p_event_class_code        => l_aad.event_class_code
           ,p_event_type_code         => l_aad.event_type_code
           ,p_event_type_name         => x_event_type_name);

      x_locking_status_flag := l_aad.locking_status_flag;

      l_return := FALSE;
      EXIT;

    END IF;
  END LOOP;

  IF (l_return) THEN

    OPEN c_update_aads;
    FETCH c_update_aads BULK COLLECT INTO l_event_class_codes
                                         ,l_product_rule_type_codes
                                         ,l_product_rule_codes;
    CLOSE c_update_aads;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_event_class_codes.count = '||l_event_class_codes.count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (l_event_class_codes.count > 0) THEN

      FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_product_rules_b xpr
           SET compile_status_code = 'N'
             , updated_flag        = 'Y'
             , last_update_date    = sysdate
             , last_updated_by     = xla_environment_pkg.g_usr_id
             , last_update_login   = xla_environment_pkg.g_login_id
         WHERE application_id          = p_application_id
           AND amb_context_code        = p_amb_context_code
           AND product_rule_type_code  = l_product_rule_type_codes(i)
           AND product_rule_code       = l_product_rule_codes(i)
           AND (compile_status_code    <> 'N' OR
                updated_flag           <> 'Y');

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => '# row updated in xla_product_rules_b = '||SQL%ROWCOUNT,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_prod_acct_headers xpa
           SET validation_status_code = 'N'
             , last_update_date       = sysdate
             , last_updated_by        = xla_environment_pkg.g_usr_id
             , last_update_login      = xla_environment_pkg.g_login_id
         WHERE xpa.application_id          = p_application_id
           AND xpa.amb_context_code        = p_amb_context_code
           AND xpa.event_class_code        = l_event_class_codes(i)
           AND xpa.product_rule_type_code  = l_product_rule_type_codes(i)
           AND xpa.product_rule_code       = l_product_rule_codes(i)
           AND xpa.validation_status_code  <> 'N';

      IF (C_LEVEL_EVENT >= g_log_level) THEN
        trace(p_msg    => '# row updated in xla_prod_acct_headers = '||SQL%ROWCOUNT,
              p_module => l_log_module,
              p_level  => C_LEVEL_EVENT);
      END IF;

      UPDATE xla_appli_amb_contexts
         SET updated_flag      = 'Y'
           , last_update_date  = sysdate
           , last_updated_by   = xla_environment_pkg.g_usr_id
           , last_update_login = xla_environment_pkg.g_login_id
       WHERE application_id    = p_application_id
         AND amb_context_code  = p_amb_context_code
         AND updated_flag      <> 'Y';

    END IF;
  END IF;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace(p_msg    => 'END LOOP - uncompile aads',
          p_module => l_log_module,
          p_level  => C_LEVEL_EVENT);
  END IF;

  UPDATE xla_line_definitions_b
     SET validation_status_code     = 'N'
        ,last_update_date           = sysdate
        ,last_updated_by            = xla_environment_pkg.g_usr_id
        ,last_update_login          = xla_environment_pkg.g_login_id
   WHERE application_id             = p_application_id
     AND amb_context_code           = p_amb_context_code
     AND event_class_code           = p_event_class_code
     AND event_type_code            = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code       = p_line_definition_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure uncompile_aads'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    IF c_update_aads%ISOPEN THEN
      CLOSE c_update_aads;
    END IF;
    IF (c_lock_aads%ISOPEN) THEN
      CLOSE c_lock_aads;
    END IF;
    RAISE;

  WHEN OTHERS                                   THEN
    IF c_update_aads%ISOPEN THEN
      CLOSE c_update_aads;
    END IF;
    IF (c_lock_aads%ISOPEN) THEN
      CLOSE c_lock_aads;
    END IF;
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.uncompile_aads');

END uncompile_aads;


--=============================================================================
--
-- Name: invalid_line_analytical
-- Description: Returns true if sources for the analytical criteria are invalid
--
--=============================================================================
FUNCTION invalid_line_analytical
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_ac_type_code                     IN VARCHAR2
  ,p_ac_code                          IN VARCHAR2)
RETURN VARCHAR2
IS
  l_return                   VARCHAR2(30);
  l_exist                    VARCHAR2(1);

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.invalid_line_analytical';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure invalid_line_analytical'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',entity_code = '||p_entity_code||
                      ',event_class_code = '||p_event_class_code||
                      ',analytical_criterion_type_code = '||p_ac_type_code||
                      ',analytical_criterion_code = '||p_ac_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  --
  -- call invalid_line_analytical to see if header analytical criteria is invalid
  --
  IF xla_line_definitions_pvt.invalid_line_ac
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_entity_code                => p_entity_code
           ,p_event_class_code           => p_event_class_code
           ,p_ac_type_code               => p_ac_type_code
           ,p_ac_code                    => p_ac_code) THEN

    l_return := 'TRUE';
  ELSE
    l_return := 'FALSE';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure invalid_line_analytical'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS  THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.invalid_line_analytical');
END invalid_line_analytical;

--=============================================================================
--
-- Name: copy_line_assignment_details
-- Description: Copies the details of an existing line assignment to a new one
--
--=============================================================================
PROCEDURE copy_line_assignment_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,p_old_accting_line_type_code       IN VARCHAR2
  ,p_old_accounting_line_code         IN VARCHAR2
  ,p_new_accting_line_type_code       IN VARCHAR2
  ,p_new_accounting_line_code         IN VARCHAR2
  ,p_include_ac_assignments           IN VARCHAR2
  ,p_include_adr_assignments          IN VARCHAR2
  ,p_mpa_option_code                  IN VARCHAR2)

IS

  l_creation_date                   DATE := sysdate;
  l_last_update_date                DATE := sysdate;
  l_created_by                      INTEGER := xla_environment_pkg.g_usr_id;
  l_last_update_login               INTEGER := xla_environment_pkg.g_login_id;
  l_last_updated_by                 INTEGER := xla_environment_pkg.g_usr_id;

  l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.invalid_line_analytical';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure invalid_line_analytical'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',event_class_code = '||p_event_class_code||
                       ',event_type_code = '||p_event_type_code||
                       ',line_definition_owner_code = '||p_line_definition_owner_code||
                       ',line_definition_code = '||p_line_definition_code||
                       ',old_accting_line_type_code = '||p_old_accting_line_type_code||
                       ',old_accounting_line_code = '||p_old_accounting_line_code||
                       ',new_accting_line_type_code = '||p_new_accting_line_type_code||
                       ',new_accounting_line_code = '||p_new_accounting_line_code||
                       ',include_ac_assignments = '||p_include_ac_assignments||
                       ',include_adr_assignments = '||p_include_adr_assignments||
		       ',p_mpa_option_code = '||p_mpa_option_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   IF ( p_include_adr_assignments = 'Y') THEN
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
            ,segment_rule_type_code
            ,segment_rule_code
	    ,segment_rule_appl_id
            ,side_code
            ,object_version_number
            ,inherit_adr_flag
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
      SELECT
             application_id
            ,amb_context_code
            ,event_class_code
            ,event_type_code
            ,line_definition_owner_code
            ,line_definition_code
            ,p_new_accting_line_type_code
            ,p_new_accounting_line_code
            ,flexfield_segment_code
            ,adr_version_num
            ,segment_rule_type_code
            ,segment_rule_code
	    ,segment_rule_appl_id
            ,side_code
            ,1
            ,inherit_adr_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
        FROM xla_line_defn_adr_assgns
       WHERE application_id             = p_application_id
         AND amb_context_code           = p_amb_context_code
         AND event_class_code           = p_event_class_code
         AND event_type_code            = p_event_type_code
         AND line_definition_owner_code = p_line_definition_owner_code
         AND line_definition_code       = p_line_definition_code
         AND accounting_line_type_code  = p_old_accting_line_type_code
         AND accounting_line_code       = p_old_accounting_line_code;

      If (p_mpa_option_code = 'ACCRUAL') then

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
               ,object_version_number
               ,inherit_adr_flag
               ,creation_date
               ,created_by
               ,last_update_date
               ,last_updated_by
               ,last_update_login)
         SELECT
               application_id
              ,amb_context_code
              ,event_class_code
              ,event_type_code
              ,line_definition_owner_code
              ,line_definition_code
              ,p_new_accting_line_type_code
              ,p_new_accounting_line_code
              ,p_new_accting_line_type_code
              ,p_new_accounting_line_code
              ,flexfield_segment_code
              ,segment_rule_type_code
              ,segment_rule_code
              ,segment_rule_appl_id
              ,1
              ,inherit_adr_flag
              ,l_creation_date
              ,l_created_by
              ,l_last_update_date
              ,l_last_updated_by
              ,l_last_update_login
         FROM xla_mpa_jlt_adr_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_line_definition_owner_code
          AND line_definition_code       = p_line_definition_code
          AND accounting_line_type_code  = p_old_accting_line_type_code
          AND accounting_line_code       = p_old_accounting_line_code
	  AND mpa_accounting_line_type_code = p_old_accting_line_type_code
	  AND mpa_accounting_line_code   = p_old_accounting_line_code;

      End If;   -- mpa_option_code = 'ACCRUAL'
   END IF;      -- p_include_adr_assignments = 'Y'

   IF (p_include_ac_assignments = 'Y') THEN
      INSERT INTO xla_line_defn_ac_assgns
             (application_id
             ,amb_context_code
             ,event_class_code
             ,event_type_code
             ,line_definition_owner_code
             ,line_definition_code
             ,accounting_line_type_code
             ,accounting_line_code
             ,analytical_criterion_type_code
             ,analytical_criterion_code
             ,object_version_number
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by
             ,last_update_login)
        SELECT
              application_id
             ,amb_context_code
             ,event_class_code
             ,event_type_code
             ,line_definition_owner_code
             ,line_definition_code
             ,p_new_accting_line_type_code
             ,p_new_accounting_line_code
             ,analytical_criterion_type_code
             ,analytical_criterion_code
             ,1
             ,l_creation_date
             ,l_created_by
             ,l_last_update_date
             ,l_last_updated_by
             ,l_last_update_login
         FROM xla_line_defn_ac_assgns
        WHERE application_id             = p_application_id
          AND amb_context_code           = p_amb_context_code
          AND event_class_code           = p_event_class_code
          AND event_type_code            = p_event_type_code
          AND line_definition_owner_code = p_line_definition_owner_code
          AND line_definition_code       = p_line_definition_code
          AND accounting_line_type_code  = p_old_accting_line_type_code
          AND accounting_line_code       = p_old_accounting_line_code;

      If (p_mpa_option_code = 'ACCRUAL') then

         INSERT INTO xla_mpa_header_ac_assgns
                (application_id
                ,amb_context_code
                ,event_class_code
                ,event_type_code
                ,line_definition_owner_code
                ,line_definition_code
                ,accounting_line_type_code
                ,accounting_line_code
                ,analytical_criterion_type_code
                ,analytical_criterion_code
                ,object_version_number
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login)
          SELECT
                application_id
               ,amb_context_code
               ,event_class_code
               ,event_type_code
               ,line_definition_owner_code
               ,line_definition_code
               ,p_new_accting_line_type_code
               ,p_new_accounting_line_code
               ,analytical_criterion_type_code
               ,analytical_criterion_code
               ,1
               ,l_creation_date
               ,l_created_by
               ,l_last_update_date
               ,l_last_updated_by
               ,l_last_update_login
           FROM xla_mpa_header_ac_assgns
          WHERE application_id             = p_application_id
            AND amb_context_code           = p_amb_context_code
            AND event_class_code           = p_event_class_code
            AND event_type_code            = p_event_type_code
            AND line_definition_owner_code = p_line_definition_owner_code
            AND line_definition_code       = p_line_definition_code
            AND accounting_line_type_code  = p_old_accting_line_type_code
            AND accounting_line_code       = p_old_accounting_line_code;


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
                application_id
               ,amb_context_code
               ,event_class_code
               ,event_type_code
               ,line_definition_owner_code
               ,line_definition_code
               ,p_new_accting_line_type_code
               ,p_new_accounting_line_code
               ,p_new_accting_line_type_code
               ,p_new_accounting_line_code
               ,analytical_criterion_type_code
               ,analytical_criterion_code
               ,mpa_inherit_ac_flag
               ,1
               ,l_creation_date
               ,l_created_by
               ,l_last_update_date
               ,l_last_updated_by
               ,l_last_update_login
           FROM xla_mpa_jlt_ac_assgns
          WHERE application_id             = p_application_id
            AND amb_context_code           = p_amb_context_code
            AND event_class_code           = p_event_class_code
            AND event_type_code            = p_event_type_code
            AND line_definition_owner_code = p_line_definition_owner_code
            AND line_definition_code       = p_line_definition_code
            AND accounting_line_type_code  = p_old_accting_line_type_code
            AND accounting_line_code       = p_old_accounting_line_code
            AND mpa_accounting_line_type_code = p_old_accting_line_type_code
            AND mpa_accounting_line_code   = p_old_accounting_line_code;

      End If;	-- p_mpa_option_code = 'ACCRUAL'
   END IF;	-- p_include_ac_assignments = 'Y'

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of procedure copy_line_assignment_details'
           ,p_module => l_log_module
           ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.copy_line_assignment_details');

END copy_line_assignment_details;


--=============================================================================
--
-- Name: get_line_definition_info
-- Description: Validate the line definition
--
--=============================================================================
PROCEDURE get_line_definition_info
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_line_defn IS
   SELECT xld.name, xlk.meaning owner
     FROM xla_line_definitions_tl xld
         ,xla_lookups             xlk
    WHERE xld.application_id             = p_application_id
      AND xld.amb_context_code           = p_amb_context_code
      AND xld.event_class_code           = p_event_class_code
      AND xld.event_type_code            = p_event_type_code
      AND xld.line_definition_owner_code = p_line_definition_owner_code
      AND xld.line_definition_code       = p_line_definition_code
      AND xld.language                   = USERENV('LANG')
      AND xlk.lookup_type                = 'XLA_OWNER_TYPE'
      AND xlk.lookup_code                = xld.line_definition_owner_code;

  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_line_definition_info';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure get_line_definition_info'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_line_defn;
  FETCH c_line_defn INTO x_line_definition_name, x_line_definition_owner;
  CLOSE c_line_defn;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure get_line_definition_info'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.get_line_definition_info');

END get_line_definition_info;



--=============================================================================
--
-- Name: validate_line_definition
-- Description: Validate the line definition
--
--=============================================================================
FUNCTION validate_line_definition
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_line_definition';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_line_definition'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_return := TRUE;

  -- Delete the error table for the event class
  DELETE FROM xla_amb_setup_errors
   WHERE application_id              = p_application_id
     AND amb_context_code            = p_amb_context_code
     AND event_class_code            = p_event_class_code
     AND event_type_code             = p_event_type_code
     AND line_definition_owner_code  = p_line_definition_owner_code
     AND line_definition_code        = p_line_definition_code;

  l_return := chk_jld_same_entry
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := validate_line_descriptions
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := validate_jlt_assgns
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := validate_adr_assgns
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := validate_line_ac
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := validate_mapping_sets
                     (p_application_id             => p_application_id
                     ,p_amb_context_code           => p_amb_context_code
                     ,p_event_class_code           => p_event_class_code
                     ,p_event_type_code            => p_event_type_code
                     ,p_line_definition_owner_code => p_line_definition_owner_code
                     ,p_line_definition_code       => p_line_definition_code)
              AND l_return;

  l_return := validate_mpa_header_assgns
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;

   l_return := validate_mpa_line_assgns
               (p_application_id             => p_application_id
               ,p_amb_context_code           => p_amb_context_code
               ,p_event_class_code           => p_event_class_code
               ,p_event_type_code            => p_event_type_code
               ,p_line_definition_owner_code => p_line_definition_owner_code
               ,p_line_definition_code       => p_line_definition_code)
            AND l_return;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_line_definition'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_line_definition');

END validate_line_definition;

--=============================================================================
--
-- Name: validate_jld
-- Description: Validate the line definition
--
--=============================================================================
FUNCTION validate_jld
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_return      BOOLEAN;
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.validate_jld';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure validate_jld'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  -- Set environment settings
  xla_environment_pkg.refresh;

  -- Initialize the error package
  xla_amb_setup_err_pkg.initialize;

  l_return := validate_line_definition
            (p_application_id             => p_application_id
            ,p_amb_context_code           => p_amb_context_code
            ,p_event_class_code           => p_event_class_code
            ,p_event_type_code            => p_event_type_code
            ,p_line_definition_owner_code => p_line_definition_owner_code
            ,p_line_definition_code       => p_line_definition_code);

  IF (NOT l_return) THEN
    xla_amb_setup_err_pkg.insert_errors;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure validate_jld'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.validate_jld');

END validate_jld;

--======================================================================
--
-- Name: check_copy_line_definition
-- Description: Checks if the line definition can be copied into a new one
--
--======================================================================
FUNCTION check_copy_line_definition
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_old_line_defn_owner_code         IN VARCHAR2
  ,p_old_line_defn_code               IN VARCHAR2
  ,p_old_accounting_coa_id            IN NUMBER
  ,p_new_accounting_coa_id            IN NUMBER
  ,p_message                          IN OUT NOCOPY VARCHAR2
  ,p_token_1                          IN OUT NOCOPY VARCHAR2
  ,p_value_1                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
  l_log_module               VARCHAR2(240);

  l_flexfield_segment_code   VARCHAR2(30);
  l_flexfield_segment_name   VARCHAR2(80);
  l_return                   BOOLEAN := TRUE;

  CURSOR c_adr
  IS
  SELECT laa.flexfield_segment_code, seg.flex_value_set_id
   FROM xla_line_defn_adr_assgns laa, xla_seg_rules_b seg
  WHERE laa.application_id             = p_application_id
    AND laa.amb_context_code           = p_amb_context_code
    AND laa.event_class_code           = p_event_class_code
    AND laa.event_type_code            = p_event_type_code
    AND laa.line_definition_owner_code = p_old_line_defn_owner_code
    AND laa.line_definition_code       = p_old_line_defn_code
    AND laa.flexfield_segment_code     <> 'ALL'
	AND laa.segment_rule_appl_id       = seg.application_id
    AND laa.amb_context_code           = seg.amb_context_code
	AND laa.segment_rule_code          = seg.segment_rule_code
	AND laa.segment_rule_type_code     = seg.segment_rule_type_code;

  l_adr  c_adr%rowtype;

CURSOR c_valueset
IS
SELECT 'x'
FROM   fnd_id_flex_segments
WHERE  application_id          = 101
  AND  id_flex_code            = 'GL#'
  AND  id_flex_num             = p_new_accounting_coa_id
  AND  application_column_name = l_flexfield_segment_code
  AND  flex_value_set_id       = l_adr.flex_value_set_id
;

  l_valueset  c_valueset%rowtype;

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.check_copy_line_definition';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure check_copy_line_definition'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',old_line_definition_owner_code = '||p_old_line_defn_owner_code||
                      ',old_line_definition_owner_code = '||p_old_line_defn_owner_code||
                      ',old_line_defn_code = '||p_old_line_defn_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF p_new_accounting_coa_id is not null and p_old_accounting_coa_id is null THEN

     OPEN c_adr;
     LOOP
     FETCH c_adr
      INTO l_adr;
     EXIT WHEN c_adr%notfound or l_return = FALSE;

          l_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_accounting_coa_id
                                                ,p_qualifier_segment => l_adr.flexfield_segment_code);

          IF l_flexfield_segment_code is null THEN
             l_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_adr.flexfield_segment_code);

             p_message := 'XLA_AB_ACCT_COA_NO_QUAL';
             p_token_1 := 'QUALIFIER_NAME';
             p_value_1 := l_flexfield_segment_name;
             l_return := FALSE;

         ELSIF l_adr.flex_value_set_id is not null THEN
            OPEN c_valueset;
            FETCH c_valueset
             INTO l_valueset;
            IF c_valueset%notfound THEN

               l_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_adr.flexfield_segment_code);

               p_message := 'XLA_AB_VALUESET_NOT_MATCH';
               p_token_1 := 'QUALIFIER_NAME';
               p_value_1 := l_flexfield_segment_name;
               l_return := FALSE;
            END IF;
         END IF;
     END LOOP;
     CLOSE c_adr;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure check_copy_line_definition'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.check_copy_line_definition');
END check_copy_line_definition;

--======================================================================
--
-- Name: check_adr_has_loop
-- Description: Returns true if the ADR has an attached ADR which in
-- turn has another ADR attached
--
--======================================================================
FUNCTION check_adr_has_loop
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN
IS
  l_log_module               VARCHAR2(240);

  l_return                   BOOLEAN := TRUE;
  l_exist                    VARCHAR2(1);

  CURSOR c_child_adr IS
    SELECT distinct xsr.value_segment_rule_appl_id,
                    xsr.value_segment_rule_type_code, xsr.value_segment_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_line_defn_adr_assgns xad
          ,xla_seg_rule_details    xsr
     WHERE xsr.application_id             = xad.application_id
       AND xsr.amb_context_code           = xad.amb_context_code
       AND xsr.segment_rule_type_code     = xad.segment_rule_type_code
       AND xsr.segment_rule_code          = xad.segment_rule_code
       AND xsr.value_type_code            = 'A'
       AND xad.application_id             = xjl.application_id
       AND xad.amb_context_code           = xjl.amb_context_code
       AND xad.line_definition_owner_code = xjl.line_definition_owner_code
       AND xad.line_definition_code       = xjl.line_definition_code
       AND xad.event_class_code           = xjl.event_class_code
       AND xad.event_type_code            = xjl.event_type_code
       AND xad.accounting_line_type_code  = xjl.accounting_line_type_code
       AND xad.accounting_line_code       = xjl.accounting_line_code
       AND xad.segment_rule_code           is not null
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.event_type_code            = p_event_type_code
       AND xjl.line_definition_owner_code = p_line_definition_owner_code
       AND xjl.line_definition_code       = p_line_definition_code
       AND xjl.active_flag                = 'Y';

  l_child_adr     c_child_adr%rowtype;

  CURSOR c_adr_loop IS
  SELECT 'x'
    FROM xla_seg_rule_details xsd
   WHERE application_id         = l_child_adr.value_segment_rule_appl_id
     AND amb_context_code       = p_amb_context_code
     AND segment_rule_type_code = l_child_adr.value_segment_rule_type_code
     AND segment_rule_code      = l_child_adr.value_segment_rule_code
     AND value_type_code        = 'A';

BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.check_adr_has_loop';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure check_adr_has_loop'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  OPEN c_child_adr;
  LOOP
     FETCH c_child_adr
      INTO l_child_adr;
     EXIT WHEN c_child_adr%notfound;

     OPEN c_adr_loop;
     FETCH c_adr_loop
      INTO l_exist;
     IF c_adr_loop%found THEN

         l_return := FALSE;

         xla_amb_setup_err_pkg.stack_error
              (p_message_name               => 'XLA_AB_ADR_HAS_LOOP'
              ,p_message_type               => 'E'
              ,p_message_category           => 'SEG_RULE'
              ,p_category_sequence          => 13
              ,p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => p_event_type_code
              ,p_line_definition_owner_code => p_line_definition_owner_code
              ,p_line_definition_code       => p_line_definition_code
              ,p_segment_rule_type_code     => l_child_adr.value_segment_rule_type_code
              ,p_segment_rule_code          => l_child_adr.value_segment_rule_code);

     END IF;
     CLOSE c_adr_loop;
  END LOOP;
  CLOSE c_child_adr;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure check_adr_has_loop'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_return;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.check_adr_has_loop');
END check_adr_has_loop;


--=============================================================================
--
-- Name: delete_mpa_jlt_details
-- Description: Deletes all details of the mpa line assignment
--
--=============================================================================
PROCEDURE delete_mpa_jlt_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code        IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_mpa_accounting_line_type_co      IN VARCHAR2
  ,p_mpa_accounting_line_code         IN VARCHAR2)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_mpa_jlt_details';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_mpa_jlt_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',event_class_code = '||p_event_class_code||
                      ',event_type_code = '||p_event_type_code||
                      ',line_definition_owner_code = '||p_line_definition_owner_code||
                      ',line_definition_code = '||p_line_definition_code||
                      ',accounting_line_type_code = '||p_accounting_line_type_code||
                      ',accounting_line_code = '||p_accounting_line_code||
		      ',mpa_accounting_line_type_co = '||p_mpa_accounting_line_type_co||
		      ',mpa_accounting_line_code = ' ||p_mpa_accounting_line_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  DELETE
    FROM xla_mpa_jlt_adr_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code
     AND mpa_accounting_line_type_code = p_mpa_accounting_line_type_co
     AND mpa_accounting_line_code    = p_mpa_accounting_line_code;

  DELETE
    FROM xla_mpa_jlt_ac_assgns
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND event_type_code           = p_event_type_code
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code      = p_line_definition_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code
     AND mpa_accounting_line_type_code = p_mpa_accounting_line_type_co
     AND mpa_accounting_line_code    = p_mpa_accounting_line_code;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_mpa_jlt_details'
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_line_definitions_pvt.delete_mpa_jlt_details');
END delete_mpa_jlt_details;


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

END xla_line_definitions_pvt;

/

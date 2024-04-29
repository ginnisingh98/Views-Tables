--------------------------------------------------------
--  DDL for Package Body XLA_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CONDITIONS_PKG" AS
/* $Header: xlaamcon.pkb 120.21.12010000.3 2009/09/07 07:51:18 rajose ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_conditions_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Conditions Package                                             |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

-- Constants

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_conditions_pkg';


-- Global variables for debugging
g_log_level     PLS_INTEGER  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_log_enabled   BOOLEAN :=  fnd_log.test
                               (log_level  => g_log_level
                               ,module     => C_DEFAULT_MODULE);


PROCEDURE trace (p_msg          IN VARCHAR2
                ,p_level        IN NUMBER
                ,p_module       IN VARCHAR2) IS
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
         (p_location   => 'xla_acct_setup_pub_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_condition                                                      |
|                                                                       |
| Deletes all conditions attached to the parent                         |
|                                                                       |
+======================================================================*/

PROCEDURE delete_condition
  (p_context                          IN VARCHAR2
  ,p_application_id                   IN NUMBER    DEFAULT NULL
  ,p_amb_context_code                 IN VARCHAR2  DEFAULT NULL
  ,p_entity_code                      IN VARCHAR2  DEFAULT NULL
  ,p_event_class_code                 IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_type_code        IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_code             IN VARCHAR2  DEFAULT NULL
  ,p_segment_rule_detail_id           IN NUMBER    DEFAULT NULL
  ,p_description_prio_id              IN NUMBER    DEFAULT NULL)

IS
  l_log_module             VARCHAR2(240);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_condition';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('delete_condition.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   trace('context                   = '||p_context                   , C_LEVEL_STATEMENT,l_log_module);
   trace('application_id            = '||p_application_id            , C_LEVEL_STATEMENT,l_log_module);
   trace('entity_code               = '||p_entity_code               , C_LEVEL_STATEMENT,l_log_module);
   trace('event_class_code          = '||p_event_class_code          , C_LEVEL_STATEMENT,l_log_module);
   trace('accounting_line_type_code = '||p_accounting_line_type_code , C_LEVEL_STATEMENT,l_log_module);
   trace('accounting_line_code      = '||p_accounting_line_code      , C_LEVEL_STATEMENT,l_log_module);
   trace('segment_rule_detail_id    = '||p_segment_rule_detail_id    , C_LEVEL_STATEMENT,l_log_module);
   trace('description_prio_id       = '||p_description_prio_id       , C_LEVEL_STATEMENT,l_log_module);

   IF p_context = 'A' THEN

      DELETE
        FROM xla_conditions
       WHERE application_id            = p_application_id
         AND amb_context_code          = p_amb_context_code
         AND entity_code               = p_entity_code
         AND event_class_code          = p_event_class_code
         AND accounting_line_type_code = p_accounting_line_type_code
         AND accounting_line_code      = p_accounting_line_code;

   ELSIF p_context = 'S' THEN

      DELETE
        FROM xla_conditions
       WHERE segment_rule_detail_id   = p_segment_rule_detail_id;

   ELSIF p_context = 'D' THEN

      DELETE
        FROM xla_conditions
       WHERE description_prio_id   = p_description_prio_id;
   END IF;

   trace('delete_condition.End',C_LEVEL_PROCEDURE,l_log_module);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_conditions_pkg.delete_condition');

END delete_condition;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| display_condition                                                     |
|                                                                       |
| Returns condition for the parent                                      |
|                                                                       |
+======================================================================*/

FUNCTION display_condition
  (p_application_id                   IN NUMBER    DEFAULT NULL
  ,p_amb_context_code                 IN VARCHAR2  DEFAULT NULL
  ,p_entity_code                      IN VARCHAR2  DEFAULT NULL
  ,p_event_class_code                 IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_type_code        IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_code             IN VARCHAR2  DEFAULT NULL
  ,p_segment_rule_detail_id           IN NUMBER    DEFAULT NULL
  ,p_description_prio_id              IN NUMBER    DEFAULT NULL
  ,p_chart_of_accounts_id             IN NUMBER    DEFAULT NULL
  ,p_context                          IN VARCHAR2)
RETURN VARCHAR2

IS

   CURSOR c_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE segment_rule_detail_id = p_segment_rule_detail_id
      AND p_context              = 'S'
   UNION
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND entity_code               = p_entity_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code
      AND p_context              = 'A'
   UNION
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE description_prio_id = p_description_prio_id
      AND p_context              = 'D'
    ORDER BY user_sequence;

   CURSOR c_source_name
     (p_application_id    IN  NUMBER
     ,p_source_type_code  IN  VARCHAR2
     ,p_source_code       IN  VARCHAR2)
   IS
   SELECT name, flex_value_set_id, datatype_code, view_application_id, lookup_type,
          flexfield_application_id, id_flex_code, segment_code
     FROM xla_sources_vl
    WHERE application_id    = p_application_id
      AND source_type_code  = p_source_type_code
      AND source_code       = p_source_code;

   CURSOR c_value_source_name
     (p_application_id    IN  NUMBER
     ,p_source_type_code  IN  VARCHAR2
     ,p_source_code       IN  VARCHAR2)
   IS
   SELECT name, flexfield_application_id, id_flex_code
     FROM xla_sources_vl
    WHERE application_id    = p_application_id
      AND source_type_code  = p_source_type_code
      AND source_code       = p_source_code;

   CURSOR c_meaning
     (p_view_application_id    IN  NUMBER
     ,p_lookup_type            IN  VARCHAR2
     ,p_lookup_code            IN  VARCHAR2)
   IS
   SELECT meaning
     FROM fnd_lookup_values_vl
    WHERE view_application_id = p_view_application_id
      AND lookup_type         = p_lookup_type
      AND lookup_code         = p_lookup_code;

   CURSOR c_appl
     (p_application_id    IN  NUMBER)
   IS
   SELECT application_short_name
     FROM fnd_application_vl
    WHERE application_id = p_application_id;

   --
   -- Local variables
   --
   l_condition  c_conditions%rowtype;

   l_condition_dsp                 VARCHAR2(32767) := NULL; --bug#8880647 changed size from 20000 to 32767
   l_source_name                   VARCHAR2(80);
   l_source_datatype_code          VARCHAR2(1);
   l_value_dsp                     VARCHAR2(2000);
   l_flex_value_set_id             INTEGER;
   l_value_flex_value_set_id       INTEGER;
   l_flexfield_segment_name        VARCHAR2(80);
   l_value_flexfield_segment_name  VARCHAR2(80);
   l_line_operator_dsp             VARCHAR2(80);
   l_logical_operator_dsp          VARCHAR2(80);
   l_dummy_date                    DATE;
   l_view_application_id           INTEGER;
   l_lookup_type                   VARCHAR2(30);
   l_source_flex_appl_id           NUMBER(15);
   l_source_id_flex_num            NUMBER(15);
   l_source_id_flex_code           VARCHAR2(30);
   l_source_segment_code           VARCHAR2(30);
   l_value_source_flex_appl_id     NUMBER(15);
   l_value_source_id_flex_num      NUMBER(15);
   l_value_source_id_flex_code     VARCHAR2(30);
   l_appl_short_name               VARCHAR2(50);
   l_independent_value_dsp         VARCHAR2(2000);

   l_return                        BOOLEAN;
   l_log_module                    VARCHAR2(240);
BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.display_condition';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('display_condition.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   trace('application_id  = '||p_application_id  , C_LEVEL_STATEMENT,l_log_module);
   trace('entity_code  = '||p_entity_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('event_class_code  = '||p_event_class_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('accounting_line_type_code  = '||p_accounting_line_type_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('accounting_line_code  = '||p_accounting_line_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('segment_rule_detail_id  = '||p_segment_rule_detail_id  , C_LEVEL_STATEMENT,l_log_module);
   trace('description_prio_id  = '||p_description_prio_id  , C_LEVEL_STATEMENT,l_log_module);
   trace('chart_of_accounts_id  = '||p_chart_of_accounts_id  , C_LEVEL_STATEMENT,l_log_module);

      OPEN c_conditions;
      LOOP
         FETCH c_conditions
          INTO l_condition;
         EXIT WHEN c_conditions%notfound;

         BEGIN

         l_source_name                   := null;
         l_value_dsp                     := null;
         l_flex_value_set_id             := null;
         l_value_flex_value_set_id       := null;
         l_flexfield_segment_name        := null;
         l_value_flexfield_segment_name  := null;
         l_line_operator_dsp             := null;
         l_logical_operator_dsp          := null;

         IF l_condition.bracket_left_code is not null THEN
            l_condition_dsp := rtrim(l_condition_dsp)||' '||
                           l_condition.bracket_left_code;
         END IF;
         --
         -- Get source name
         --
         IF l_condition.source_code is not null THEN
            OPEN c_source_name
              (l_condition.source_application_id
              ,l_condition.source_type_code
              ,l_condition.source_code);
            FETCH c_source_name
             INTO l_source_name, l_flex_value_set_id, l_source_datatype_code,
                  l_view_application_id, l_lookup_type,
                  l_source_flex_appl_id, l_source_id_flex_code, l_source_segment_code;
            CLOSE c_source_name;

            l_condition_dsp := rtrim(l_condition_dsp)||' '||
                           l_source_name;

         END IF;

         --
         -- Get flexfield_segment_name
         --
         IF l_condition.flexfield_segment_code is not null THEN

            IF l_source_flex_appl_id = 101 and l_source_id_flex_code = 'GL#' THEN
               l_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
                                          (p_application_id         => 101
                                          ,p_flex_code              => 'GL#'
                                          ,p_chart_of_accounts_id   => p_chart_of_accounts_id
                                          ,p_flexfield_segment_code => l_condition.flexfield_segment_code);

               IF l_flexfield_segment_name is null THEN
                  l_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                                     (p_application_id     => 101
                                                     ,p_id_flex_code       => 'GL#'
                                                     ,p_qualifier_segment  => l_condition.flexfield_segment_code);


               END IF;
            ELSE

               l_source_id_flex_num := xla_flex_pkg.get_flexfield_structure
                                         (p_application_id    => l_source_flex_appl_id
                                         ,p_id_flex_code      => l_source_id_flex_code);

               l_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
                                          (p_application_id         => l_source_flex_appl_id
                                          ,p_flex_code              => l_source_id_flex_code
                                          ,p_chart_of_accounts_id   => l_source_id_flex_num
                                          ,p_flexfield_segment_code => l_condition.flexfield_segment_code);
            END IF;

            l_condition_dsp := rtrim(l_condition_dsp)||','||
                           l_flexfield_segment_name;
         END IF;

         --
         -- Get line_operator_dsp
         --
         IF l_condition.line_operator_code is not null THEN
     	    -- bugfix 6024311: since Meaning in lookup table will be translated,
            --                 do not use get_meaning() for meanings that are 'operators'.

           IF(l_condition.logical_operator_code = 'N') THEN
            l_condition_dsp := rtrim(l_condition_dsp) ||' IS NULL ';
           ELSIF(l_condition.logical_operator_code = 'X') THEN
            l_condition_dsp := rtrim(l_condition_dsp) ||' IS NOT NULL ';
           ELSE
            l_line_operator_dsp := xla_lookups_pkg.get_meaning
                                          (p_lookup_type         => 'XLA_LINE_OPERATOR_TYPE'
                                          ,p_lookup_code         => l_condition.line_operator_code);

            l_condition_dsp := rtrim(l_condition_dsp)||' '||
                           l_line_operator_dsp;
           END IF;
         END IF;

         --
         -- Get value_dsp
         --
         IF l_condition.value_type_code = 'S' THEN

            OPEN c_value_source_name
              (l_condition.value_source_application_id
              ,l_condition.value_source_type_code
              ,l_condition.value_source_code);
            FETCH c_value_source_name
             INTO l_value_dsp, l_value_source_flex_appl_id, l_value_source_id_flex_code;
            CLOSE c_value_source_name;

            l_condition_dsp := rtrim(l_condition_dsp)||' '||
                           l_value_dsp;

         ELSIF l_condition.value_type_code = 'C' THEN

            IF l_flex_value_set_id is not null THEN

               l_value_dsp := xla_flex_pkg.get_flex_value_meaning
                                (p_flex_value_set_id => l_flex_value_set_id
                                ,p_flex_value        => l_condition.value_constant);

            ELSIF l_view_application_id is not null THEN

               OPEN c_meaning
                      (p_view_application_id => l_view_application_id
                      ,p_lookup_type         => l_lookup_type
                      ,p_lookup_code         => l_condition.value_constant);
               FETCH c_meaning
                INTO l_value_dsp;
               CLOSE c_meaning;

            ELSE
               IF l_source_flex_appl_id is not null THEN
                  IF l_source_segment_code is not null or l_condition.flexfield_segment_code is not null THEN
                     l_value_dsp := l_condition.value_constant;

                  ELSIF l_source_flex_appl_id = 101 and l_source_id_flex_code = 'GL#' THEN
                     l_value_dsp := fnd_flex_ext.get_segs(application_short_name => 'SQLGL'
                                                         ,key_flex_code          => 'GL#'
                                                         ,structure_number       => p_chart_of_accounts_id
                                                         ,combination_id         => to_number(l_condition.value_constant));

                  ELSE

                     l_source_id_flex_num := xla_flex_pkg.get_flexfield_structure
                                         (p_application_id    => l_source_flex_appl_id
                                         ,p_id_flex_code      => l_source_id_flex_code);

                     OPEN c_appl(l_source_flex_appl_id);
                     FETCH c_appl
                      INTO l_appl_short_name;
                     CLOSE c_appl;

                     l_value_dsp := fnd_flex_ext.get_segs(application_short_name => l_appl_short_name
                                                         ,key_flex_code          => l_source_id_flex_code
                                                         ,structure_number       => l_source_id_flex_num
                                                         ,combination_id         => to_number(l_condition.value_constant));
                  END IF;

               ELSIF l_source_datatype_code = 'N' THEN
                  l_value_dsp := fnd_number.canonical_to_number(l_condition.value_constant);
               ELSIF l_source_datatype_code = 'D' THEN
                  l_dummy_date := fnd_date.canonical_to_date(l_condition.value_constant);
                  l_value_dsp := fnd_date.date_to_displaydate(l_dummy_date);
               ELSE
                  l_value_dsp := l_condition.value_constant;
               END IF;
            END IF;

--ksvenkat
       IF l_source_datatype_code = 'N' then
          l_condition_dsp := rtrim(l_condition_dsp)||
                         l_value_dsp;
       ELSE
          l_condition_dsp := rtrim(l_condition_dsp)||' '''||
                         l_value_dsp||'''';
       END IF;
         END IF;

         --
         -- Get value_flexfield_segment_name
         --
         IF l_condition.value_flexfield_segment_code is not null THEN

            IF l_value_source_flex_appl_id = 101 and l_value_source_id_flex_code = 'GL#' THEN
               l_value_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
                                                (p_application_id         => 101
                                                ,p_flex_code              => 'GL#'
                                                ,p_chart_of_accounts_id   => p_chart_of_accounts_id
                                                ,p_flexfield_segment_code => l_condition.value_flexfield_segment_code);

               IF l_value_flexfield_segment_name is null THEN
                  l_value_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                                     (p_application_id     => 101
                                                     ,p_id_flex_code       => 'GL#'
                                                     ,p_qualifier_segment  => l_condition.value_flexfield_segment_code);

               END IF;
            ELSE

               l_value_source_id_flex_num := xla_flex_pkg.get_flexfield_structure
                                         (p_application_id    => l_value_source_flex_appl_id
                                         ,p_id_flex_code      => l_value_source_id_flex_code);

               l_value_flexfield_segment_name := xla_flex_pkg.get_flexfield_segment_name
                                          (p_application_id         => l_value_source_flex_appl_id
                                          ,p_flex_code              => l_value_source_id_flex_code
                                          ,p_chart_of_accounts_id   => l_value_source_id_flex_num
                                          ,p_flexfield_segment_code => l_condition.value_flexfield_segment_code);
            END IF;

            l_condition_dsp := rtrim(l_condition_dsp)||','||
                           l_value_flexfield_segment_name;
         END IF;

         IF l_condition.bracket_right_code is not null THEN
            l_condition_dsp := rtrim(l_condition_dsp)||' '||
                           l_condition.bracket_right_code;
         END IF;

         --
         -- Get logical_operator_dsp
         --
         IF l_condition.logical_operator_code is not null THEN
	    -- bugfix 6024311: since Meaning in lookup table will be translated,
	    --                 do not use get_meaning() for lookup_type XLA_LOGICAL_OPERATOR_TYPE
	   /*
            l_logical_operator_dsp := xla_lookups_pkg.get_meaning
                                          (p_lookup_type         => 'XLA_LOGICAL_OPERATOR_TYPE'
                                          ,p_lookup_code         => l_condition.logical_operator_code);
            l_condition_dsp := rtrim(l_condition_dsp)||' '||
                           l_logical_operator_dsp;
	    */
  	    IF(l_condition.logical_operator_code = 'A') THEN
    		l_condition_dsp := rtrim(l_condition_dsp) ||' AND ';
            ELSIF(l_condition.logical_operator_code = 'O') THEN
    		l_condition_dsp := rtrim(l_condition_dsp) ||' OR ';
            END IF;

         END IF;

         EXCEPTION
            WHEN VALUE_ERROR THEN
               xla_exceptions_pkg.raise_message
                                   ('XLA'
                                   ,'XLA_AB_COND_TOO_LONG'
                                   ,'PROCEDURE'
                                   ,'xla_conditions_pkg.display_condition'
                                   ,'ERROR'
                                   ,sqlerrm
                                   );
         END;

      END LOOP;
      CLOSE c_conditions;

   trace('delete_condition.End',C_LEVEL_PROCEDURE,l_log_module);

   RETURN l_condition_dsp;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_conditions%ISOPEN THEN
         CLOSE c_conditions;
      END IF;
      IF c_source_name%ISOPEN THEN
         CLOSE c_source_name;
      END IF;
      IF c_value_source_name%ISOPEN THEN
         CLOSE c_value_source_name;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_conditions%ISOPEN THEN
         CLOSE c_conditions;
      END IF;
      IF c_source_name%ISOPEN THEN
         CLOSE c_source_name;
      END IF;
      IF c_value_source_name%ISOPEN THEN
         CLOSE c_value_source_name;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_conditions_pkg.display_condition');

END display_condition;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| desc_condition_is_invalid                                             |
|                                                                       |
| Returns true if condition is invalid                                  |
|                                                                       |
+======================================================================*/

FUNCTION desc_condition_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   --
   -- Variable declarations
   --
   l_exist                   varchar2(1);
   l_return                  boolean;
   l_description_prio_id     number(38);
   l_desc_user_sequence      number(38);
   l_desc_max_left_seq       number(38);
   l_desc_max_right_seq      number(38);
   l_desc_min_left_seq       number(38);
   l_desc_min_right_seq      number(38);
   l_count_1                 number(38);
   l_count_2                 number(38);
   l_log_module             VARCHAR2(240);

   CURSOR c_desc_brackets
   IS
   SELECT 'x'
     FROM xla_desc_priorities d
    WHERE d.application_id        = p_application_id
      AND d.amb_context_code      = p_amb_context_code
      AND d.description_type_code = p_description_type_code
      AND d.description_code      = p_description_code
      AND exists(SELECT count(1)
                   FROM xla_conditions c
                  WHERE c.description_prio_id = d.description_prio_id
                    AND c.bracket_left_code is not null
                  MINUS
                 SELECT count(1)
                   FROM xla_conditions c1
                  WHERE c1.description_prio_id = d.description_prio_id
                    AND c1.bracket_right_code is not null);


   CURSOR c_description_prio_id
   IS
   SELECT description_prio_id
     FROM xla_desc_priorities d
    WHERE d.application_id        = p_application_id
      AND d.amb_context_code      = p_amb_context_code
      AND d.description_type_code = p_description_type_code
      AND d.description_code      = p_description_code
      AND exists (SELECT 'y'
                   FROM xla_conditions c
                  WHERE c.description_prio_id = d.description_prio_id);

   CURSOR c_desc_max_left_seq(p_description_prio_id  NUMBER)
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_left_code is not null;

   CURSOR c_desc_max_right_seq(p_description_prio_id  NUMBER)
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_right_code is not null;

   CURSOR c_desc_min_left_seq(p_description_prio_id  NUMBER)
   IS
   SELECT min(user_sequence)
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_left_code is not null;

   CURSOR c_desc_min_right_seq(p_description_prio_id  NUMBER)
   IS
   SELECT min(user_sequence)
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_right_code is not null;

   -- Check if any empty rows exist with just the sequence number
   CURSOR c_source(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_left_code is null
      AND c.bracket_right_code is null
      AND c.source_code is null;

   -- Check if any rows exist with just left and right bracket
   CURSOR c_left_right_bracket(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_left_code is not null
      AND c.bracket_right_code is not null
      AND c.source_code is null;

   -- Get the sequence for the last row
   CURSOR c_desc_sequence(p_description_prio_id  NUMBER)
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id;

   -- Check if last row has logical operator
   CURSOR c_desc_last_operator(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.user_sequence          = l_desc_user_sequence
      AND c.logical_operator_code is not null;

   -- Check if any rows exist with just left bracket and logical operator
   CURSOR c_left_bracket_operator(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_left_code is not null
      AND c.source_code is null
      AND c.logical_operator_code is not null;

   -- Get all rows which are not the last row or rows with just left bracket
   -- and have no logical operator
   CURSOR c_no_logical_operator(p_description_prio_id  NUMBER)
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND (c.source_code is not null
       OR  c.bracket_right_code is not null)
      AND c.logical_operator_code is null
      AND c.user_sequence <> l_desc_user_sequence;

   l_no_logical_operator  c_no_logical_operator%rowtype;

   -- Check if next row has only right bracket
   -- and have no logical operator
   CURSOR c_only_right_bracket(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.source_code is null
      AND c.bracket_right_code is not null
      AND c.user_sequence = l_no_logical_operator.user_sequence + 1;

   -- Get all rows which have just left bracket and no source
   CURSOR c_no_source_bracket(p_description_prio_id  NUMBER)
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.source_code is null
      AND c.bracket_left_code is not null;

   l_no_source_bracket  c_no_source_bracket%rowtype;

   -- Check if next row has only left bracket
   CURSOR c_only_left_bracket(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.bracket_left_code is not null
      AND c.user_sequence = l_no_source_bracket.user_sequence + 1;

   -- Get all rows with logical operator not null
   CURSOR c_log_op_not_null(p_description_prio_id  NUMBER)
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.logical_operator_code is not null;

   l_log_op_not_null  c_log_op_not_null%rowtype;

   -- Check if next row has only right bracket
   CURSOR c_right_bracket(p_description_prio_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.description_prio_id = p_description_prio_id
      AND c.source_code is null
      AND c.bracket_right_code is not null
      AND c.user_sequence = l_log_op_not_null.user_sequence + 1;

BEGIN
   trace('desc_condition_is_invalid.Begin',C_LEVEL_PROCEDURE,l_log_module);

   trace('application_id         = '||p_application_id  , C_LEVEL_STATEMENT,l_log_module);
   trace('description_type_code  = '||p_description_type_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('description_code       = '||p_description_code  , C_LEVEL_STATEMENT,l_log_module);

   --
   -- Check if condition has unequal brackets
   --
      OPEN c_desc_brackets;
      FETCH c_desc_brackets
       INTO l_exist;
      IF c_desc_brackets%found then
         p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
         l_return := TRUE;
      ELSE
         p_message_name := NULL;
         l_return := FALSE;
      END IF;
      CLOSE c_desc_brackets;

   IF l_return = FALSE THEN

      OPEN c_description_prio_id;
      LOOP
         FETCH c_description_prio_id
          INTO l_description_prio_id;
         EXIT WHEN c_description_prio_id%notfound or l_return = TRUE;

         --
         -- Check if right bracket sequence is less than left bracket sequence
         --
         OPEN c_desc_max_left_seq(l_description_prio_id);
         FETCH c_desc_max_left_seq
          INTO l_desc_max_left_seq;
         CLOSE c_desc_max_left_seq;

         OPEN c_desc_max_right_seq(l_description_prio_id);
         FETCH c_desc_max_right_seq
          INTO l_desc_max_right_seq;
         CLOSE c_desc_max_right_seq;

         IF l_desc_max_right_seq < l_desc_max_left_seq then
            p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;

         IF l_return = FALSE THEN
            OPEN c_desc_min_left_seq(l_description_prio_id);
            FETCH c_desc_min_left_seq
             INTO l_desc_min_left_seq;
            CLOSE c_desc_min_left_seq;

            OPEN c_desc_min_right_seq(l_description_prio_id);
            FETCH c_desc_min_right_seq
             INTO l_desc_min_right_seq;
            CLOSE c_desc_min_right_seq;

            IF l_desc_min_right_seq < l_desc_min_left_seq then
               p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
         END IF;

         --
         -- Check if condition has a row with no brackets and no source
         --
         IF l_return = FALSE THEN

            OPEN c_source(l_description_prio_id);
            FETCH c_source
             INTO l_exist;

            IF c_source%found then
               p_message_name := 'XLA_AB_NO_BRCKT_SOURCE';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_source;
         END IF;

         --
         -- Check if any rows exist with just left and right bracket
         --
         IF l_return = FALSE THEN

            OPEN c_left_right_bracket(l_description_prio_id);
            FETCH c_left_right_bracket
             INTO l_exist;

            IF c_left_right_bracket%found then
               p_message_name := 'XLA_AB_ONLY_LEFT_RIGHT_BRCKT';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_left_right_bracket;
         END IF;

         --
         -- Check if any rows exist with just left bracket and logical operator
         --
         IF l_return = FALSE THEN

            OPEN c_left_bracket_operator(l_description_prio_id);
            FETCH c_left_bracket_operator
             INTO l_exist;

            IF c_left_bracket_operator%found then
               p_message_name := 'XLA_AB_LEFT_BRCKT_OPERATOR';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_left_bracket_operator;
         END IF;

         IF l_return = FALSE THEN
            --
            -- Get all rows with no source and only left bracket
            --
            OPEN c_no_source_bracket(l_description_prio_id);
            LOOP
            FETCH c_no_source_bracket
             INTO l_no_source_bracket;
            EXIT WHEN c_no_source_bracket%notfound or l_return = TRUE;

               -- Check if next row has only left bracket
               OPEN c_only_left_bracket(l_description_prio_id);
               FETCH c_only_left_bracket
                INTO l_exist;

               IF c_only_left_bracket%found then
                  p_message_name := null;
                  l_return := FALSE;
               ELSE
                  p_message_name := 'XLA_AB_ONLY_LEFT_RIGHT_BRCKT';
                  l_return := TRUE;
               END IF;
               CLOSE c_only_left_bracket;
            END LOOP;
            CLOSE c_no_source_bracket;
         END IF;

         IF l_return = FALSE THEN
            --
            -- Get all rows with logical operator not null
            --
            OPEN c_log_op_not_null(l_description_prio_id);
            LOOP
            FETCH c_log_op_not_null
             INTO l_log_op_not_null;
            EXIT WHEN c_log_op_not_null%notfound or l_return = TRUE;

               -- Check if next row has only right bracket
               OPEN c_right_bracket(l_description_prio_id);
               FETCH c_right_bracket
                INTO l_exist;

               IF c_right_bracket%found then
                  p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
                  l_return := TRUE;
               ELSE
                  p_message_name := null;
                  l_return := FALSE;
               END IF;
               CLOSE c_right_bracket;
            END LOOP;
            CLOSE c_log_op_not_null;
         END IF;

         --
         -- Check if condition has wrong number of logical operators
         --
         IF l_return = FALSE THEN

            -- Get last row sequence
            OPEN c_desc_sequence(l_description_prio_id);
            FETCH c_desc_sequence
             INTO l_desc_user_sequence;
            CLOSE c_desc_sequence;

            --
            -- Check if last sequence has a not null logical operator
            --
            OPEN c_desc_last_operator(l_description_prio_id);
            FETCH c_desc_last_operator
             INTO l_exist;

            IF c_desc_last_operator%found then
               p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_desc_last_operator;

            IF l_return = FALSE THEN
               --
               -- Get all rows which are not the last row or rows with just left bracket
               -- and have no logical operator
               --
               OPEN c_no_logical_operator(l_description_prio_id);
               LOOP
               FETCH c_no_logical_operator
                INTO l_no_logical_operator;
               EXIT WHEN c_no_logical_operator%notfound or l_return = TRUE;

                  -- Check if next row has only right bracket
                  OPEN c_only_right_bracket(l_description_prio_id);
                  FETCH c_only_right_bracket
                   INTO l_exist;

                  IF c_only_right_bracket%found then
                     p_message_name := null;
                     l_return := FALSE;
                  ELSE
                     p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
                     l_return := TRUE;
                  END IF;
                  CLOSE c_only_right_bracket;
               END LOOP;
               CLOSE c_no_logical_operator;
            END IF;
         END IF;
      END LOOP;
      CLOSE c_description_prio_id;
   END IF;

   trace('p_message_name = '||p_message_name , C_LEVEL_STATEMENT,l_log_module);
   trace('desc_condition_is_invalid.End',C_LEVEL_PROCEDURE,l_Log_module);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_desc_brackets%ISOPEN THEN
         CLOSE c_desc_brackets;
      END IF;
      IF c_description_prio_id%ISOPEN THEN
         CLOSE c_description_prio_id;
      END IF;
      IF c_desc_last_operator%ISOPEN THEN
         CLOSE c_desc_last_operator;
      END IF;
      IF c_desc_max_left_seq%ISOPEN THEN
         CLOSE c_desc_max_left_seq;
      END IF;
      IF c_desc_max_right_seq%ISOPEN THEN
         CLOSE c_desc_max_right_seq;
      END IF;
      IF c_desc_min_left_seq%ISOPEN THEN
         CLOSE c_desc_min_left_seq;
      END IF;
      IF c_desc_min_right_seq%ISOPEN THEN
         CLOSE c_desc_min_right_seq;
      END IF;

      RAISE;

   WHEN OTHERS                                   THEN
      IF c_desc_brackets%ISOPEN THEN
         CLOSE c_desc_brackets;
      END IF;
      IF c_description_prio_id%ISOPEN THEN
         CLOSE c_description_prio_id;
      END IF;
      IF c_desc_last_operator%ISOPEN THEN
         CLOSE c_desc_last_operator;
      END IF;
      IF c_desc_max_left_seq%ISOPEN THEN
         CLOSE c_desc_max_left_seq;
      END IF;
      IF c_desc_max_right_seq%ISOPEN THEN
         CLOSE c_desc_max_right_seq;
      END IF;
      IF c_desc_min_left_seq%ISOPEN THEN
         CLOSE c_desc_min_left_seq;
      END IF;
      IF c_desc_min_right_seq%ISOPEN THEN
         CLOSE c_desc_min_right_seq;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_conditions_pkg.desc_condition_is_invalid');

END desc_condition_is_invalid;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| seg_condition_is_invalid                                              |
|                                                                       |
| Returns true if condition is invalid                                  |
|                                                                       |
+======================================================================*/

FUNCTION seg_condition_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   --
   -- Variable declarations
   --
   l_exist                   varchar2(1);
   l_return                  boolean;
   l_segment_rule_detail_id  number(38);
   l_seg_user_sequence       number(38);
   l_seg_max_right_seq       number(38);
   l_seg_max_left_seq        number(38);
   l_seg_min_right_seq       number(38);
   l_seg_min_left_seq        number(38);
   l_count_1                 number(38);
   l_count_2                 number(38);
   l_log_module              VARCHAR2(240);
   --
   -- Cursor declarations
   --

   CURSOR c_seg_brackets
   IS
   SELECT 'x'
     FROM xla_seg_rule_details d
    WHERE d.application_id         = p_application_id
      AND d.amb_context_code       = p_amb_context_code
      AND d.segment_rule_type_code = p_segment_rule_type_code
      AND d.segment_rule_code      = p_segment_rule_code
      AND exists(SELECT count(1)
                   FROM xla_conditions c
                  WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
                    AND c.bracket_left_code is not null
                  MINUS
                 SELECT count(1)
                   FROM xla_conditions c1
                  WHERE c1.segment_rule_detail_id = d.segment_rule_detail_id
                    AND c1.bracket_right_code is not null);

   CURSOR c_segment_rule_detail_id
   IS
   SELECT segment_rule_detail_id
     FROM xla_seg_rule_details d
    WHERE d.application_id         = p_application_id
      AND d.amb_context_code       = p_amb_context_code
      AND d.segment_rule_type_code = p_segment_rule_type_code
      AND d.segment_rule_code      = p_segment_rule_code
      AND exists (SELECT 'y'
                   FROM xla_conditions c
                  WHERE c.segment_rule_detail_id = d.segment_rule_detail_id);

   CURSOR c_seg_max_left_seq(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_left_code is not null;

   CURSOR c_seg_max_right_seq(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_right_code is not null;

   CURSOR c_seg_min_left_seq(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT min(user_sequence)
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_left_code is not null;

   CURSOR c_seg_min_right_seq(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT min(user_sequence)
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_right_code is not null;

   -- Check if any empty rows exist with just the sequence number
   CURSOR c_source(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_left_code is null
      AND c.bracket_right_code is null
      AND c.source_code is null;

   -- Check if any rows exist with just left and right bracket
   CURSOR c_left_right_bracket(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_left_code is not null
      AND c.bracket_right_code is not null
      AND c.source_code is null;

   -- Get the sequence for the last row
   CURSOR c_seg_sequence(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id;

   -- Check if last row has logical operator
   CURSOR c_seg_last_operator(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.user_sequence          = l_seg_user_sequence
      AND c.logical_operator_code is not null;

   -- Check if any rows exist with just left bracket and logical operator
   CURSOR c_left_bracket_operator(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_left_code is not null
      AND c.source_code is null
      AND c.logical_operator_code is not null;

   -- Get all rows which are not the last row or rows with just left bracket
   -- and have no logical operator
   CURSOR c_no_logical_operator(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND (c.source_code is not null
       OR  c.bracket_right_code is not null)
      AND c.logical_operator_code is null
      AND c.user_sequence <> l_seg_user_sequence;

   l_no_logical_operator  c_no_logical_operator%rowtype;

   -- Check if next row has only right bracket
   -- and have no logical operator
   CURSOR c_only_right_bracket(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.source_code is null
      AND c.bracket_right_code is not null
      AND c.user_sequence = l_no_logical_operator.user_sequence + 1;

   -- Get all rows which have just left bracket and no source
   CURSOR c_no_source_bracket(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.source_code is null
      AND c.bracket_left_code is not null;

   l_no_source_bracket  c_no_source_bracket%rowtype;

   -- Check if next row has only left bracket
   CURSOR c_only_left_bracket(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.bracket_left_code is not null
      AND c.user_sequence = l_no_source_bracket.user_sequence + 1;

   -- Get all rows with logical operator not null
   CURSOR c_log_op_not_null(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.logical_operator_code is not null;

   l_log_op_not_null  c_log_op_not_null%rowtype;

   -- Check if next row has only right bracket
   CURSOR c_right_bracket(p_segment_rule_detail_id  NUMBER)
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.segment_rule_detail_id = p_segment_rule_detail_id
      AND c.source_code is null
      AND c.bracket_right_code is not null
      AND c.user_sequence = l_log_op_not_null.user_sequence + 1;

BEGIN
   trace('> xla_conditions_pkg.seg_condition_is_invalid'   , C_LEVEL_PROCEDURE,l_log_module);

   trace('application_id  = '||p_application_id  , C_LEVEL_STATEMENT,l_log_module);
   trace('segment_rule_type_code  = '||p_segment_rule_type_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('segment_rule_code  = '||p_segment_rule_code  , C_LEVEL_STATEMENT,l_log_module);


   --
   -- Check if brackets are equal
   --
   OPEN c_seg_brackets;
   FETCH c_seg_brackets
    INTO l_exist;
   IF c_seg_brackets%found then
      p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
      l_return := TRUE;
   ELSE
      p_message_name := NULL;
      l_return := FALSE;
   END IF;
   CLOSE c_seg_brackets;

   IF l_return = FALSE THEN

      OPEN c_segment_rule_detail_id;
      LOOP
         FETCH c_segment_rule_detail_id
          INTO l_segment_rule_detail_id;
         EXIT WHEN c_segment_rule_detail_id%notfound or l_return = TRUE;

         --
         -- Check if sequence for right bracket is less than sequence for left bracket
         --
         OPEN c_seg_max_left_seq(l_segment_rule_detail_id);
         FETCH c_seg_max_left_seq
          INTO l_seg_max_left_seq;
         CLOSE c_seg_max_left_seq;

         OPEN c_seg_max_right_seq(l_segment_rule_detail_id);
         FETCH c_seg_max_right_seq
          INTO l_seg_max_right_seq;
         CLOSE c_seg_max_right_seq;

         IF l_seg_max_right_seq < l_seg_max_left_seq then
            p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;

         IF l_return = FALSE THEN
            OPEN c_seg_min_left_seq(l_segment_rule_detail_id);
            FETCH c_seg_min_left_seq
             INTO l_seg_min_left_seq;
            CLOSE c_seg_min_left_seq;

            OPEN c_seg_min_right_seq(l_segment_rule_detail_id);
            FETCH c_seg_min_right_seq
             INTO l_seg_min_right_seq;
            CLOSE c_seg_min_right_seq;

            IF l_seg_min_right_seq < l_seg_min_left_seq then
               p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
         END IF;

         --
         -- Check if condition has a row with no brackets and no source
         --
         IF l_return = FALSE THEN

            OPEN c_source(l_segment_rule_detail_id);
            FETCH c_source
             INTO l_exist;

            IF c_source%found then
               p_message_name := 'XLA_AB_NO_BRCKT_SOURCE';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_source;
         END IF;

         --
         -- Check if any rows exist with just left and right bracket
         --
         IF l_return = FALSE THEN

            OPEN c_left_right_bracket(l_segment_rule_detail_id);
            FETCH c_left_right_bracket
             INTO l_exist;

            IF c_left_right_bracket%found then
               p_message_name := 'XLA_AB_ONLY_LEFT_RIGHT_BRCKT';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_left_right_bracket;
         END IF;

         --
         -- Check if any rows exist with just left bracket and logical operator
         --
         IF l_return = FALSE THEN

            OPEN c_left_bracket_operator(l_segment_rule_detail_id);
            FETCH c_left_bracket_operator
             INTO l_exist;

            IF c_left_bracket_operator%found then
               p_message_name := 'XLA_AB_LEFT_BRCKT_OPERATOR';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_left_bracket_operator;
         END IF;

         IF l_return = FALSE THEN
            --
            -- Get all rows with no source and only left bracket
            --
            OPEN c_no_source_bracket(l_segment_rule_detail_id);
            LOOP
            FETCH c_no_source_bracket
             INTO l_no_source_bracket;
            EXIT WHEN c_no_source_bracket%notfound or l_return = TRUE;

               -- Check if next row has only left bracket
               OPEN c_only_left_bracket(l_segment_rule_detail_id);
               FETCH c_only_left_bracket
                INTO l_exist;

               IF c_only_left_bracket%found then
                  p_message_name := null;
                  l_return := FALSE;
               ELSE
                  p_message_name := 'XLA_AB_ONLY_LEFT_RIGHT_BRCKT';
                  l_return := TRUE;
               END IF;
               CLOSE c_only_left_bracket;
            END LOOP;
            CLOSE c_no_source_bracket;
         END IF;

         IF l_return = FALSE THEN
            --
            -- Get all rows with logical operator not null
            --
            OPEN c_log_op_not_null(l_segment_rule_detail_id);
            LOOP
            FETCH c_log_op_not_null
             INTO l_log_op_not_null;
            EXIT WHEN c_log_op_not_null%notfound or l_return = TRUE;

               -- Check if next row has only right bracket
               OPEN c_right_bracket(l_segment_rule_detail_id);
               FETCH c_right_bracket
                INTO l_exist;

               IF c_right_bracket%found then
                  p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
                  l_return := TRUE;
               ELSE
                  p_message_name := null;
                  l_return := FALSE;
               END IF;
               CLOSE c_right_bracket;
            END LOOP;
            CLOSE c_log_op_not_null;
         END IF;

         --
         -- Check if condition has wrong number of logical operators
         --
         IF l_return = FALSE THEN

            -- Get last row sequence
            OPEN c_seg_sequence(l_segment_rule_detail_id);
            FETCH c_seg_sequence
             INTO l_seg_user_sequence;
            CLOSE c_seg_sequence;

            --
            -- Check if last sequence has a not null logical operator
            --
            OPEN c_seg_last_operator(l_segment_rule_detail_id);
            FETCH c_seg_last_operator
             INTO l_exist;

            IF c_seg_last_operator%found then
               p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
               l_return := TRUE;
            ELSE
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_seg_last_operator;

            IF l_return = FALSE THEN
               --
               -- Get all rows which are not the last row or rows with just left bracket
               -- and have no logical operator
               --
               OPEN c_no_logical_operator(l_segment_rule_detail_id);
               LOOP
               FETCH c_no_logical_operator
                INTO l_no_logical_operator;
               EXIT WHEN c_no_logical_operator%notfound or l_return = TRUE;

                  -- Check if next row has only right bracket
                  OPEN c_only_right_bracket(l_segment_rule_detail_id);
                  FETCH c_only_right_bracket
                   INTO l_exist;

                  IF c_only_right_bracket%found then
                     p_message_name := null;
                     l_return := FALSE;
                  ELSE
                     p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
                     l_return := TRUE;
                  END IF;
                  CLOSE c_only_right_bracket;
               END LOOP;
               CLOSE c_no_logical_operator;
            END IF;
         END IF;
      END LOOP;
      CLOSE c_segment_rule_detail_id;
   END IF;

   trace('p_message_name = '||p_message_name , C_LEVEL_STATEMENT,l_log_module);
   trace('< xla_conditions_pkg.seg_condition_is_invalid'    , C_LEVEL_PROCEDURE,l_log_module);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF c_seg_brackets%ISOPEN THEN
         CLOSE c_seg_brackets;
      END IF;
      IF c_segment_rule_detail_id%ISOPEN THEN
         CLOSE c_segment_rule_detail_id;
      END IF;
      IF c_seg_last_operator%ISOPEN THEN
         CLOSE c_seg_last_operator;
      END IF;
      IF c_seg_max_left_seq%ISOPEN THEN
         CLOSE c_seg_max_left_seq;
      END IF;
      IF c_seg_max_right_seq%ISOPEN THEN
         CLOSE c_seg_max_right_seq;
      END IF;
      IF c_seg_min_left_seq%ISOPEN THEN
         CLOSE c_seg_min_left_seq;
      END IF;
      IF c_seg_min_right_seq%ISOPEN THEN
         CLOSE c_seg_min_right_seq;
      END IF;

      RAISE;

   WHEN OTHERS                                   THEN

      IF c_seg_brackets%ISOPEN THEN
         CLOSE c_seg_brackets;
      END IF;
      IF c_segment_rule_detail_id%ISOPEN THEN
         CLOSE c_segment_rule_detail_id;
      END IF;
      IF c_seg_last_operator%ISOPEN THEN
         CLOSE c_seg_last_operator;
      END IF;
      IF c_seg_max_left_seq%ISOPEN THEN
         CLOSE c_seg_max_left_seq;
      END IF;
      IF c_seg_max_right_seq%ISOPEN THEN
         CLOSE c_seg_max_right_seq;
      END IF;
      IF c_seg_min_left_seq%ISOPEN THEN
         CLOSE c_seg_min_left_seq;
      END IF;
      IF c_seg_min_right_seq%ISOPEN THEN
         CLOSE c_seg_min_right_seq;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_conditions_pkg.seg_condition_is_invalid');

END seg_condition_is_invalid;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| acct_condition_is_invalid                                             |
|                                                                       |
| Returns true if condition is invalid                                  |
|                                                                       |
+======================================================================*/

FUNCTION acct_condition_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS
   --
   -- Variable declarations
   --
   l_exist                   varchar2(1);
   l_return                  boolean;
   l_acct_user_sequence      number(38);
   l_acct_max_left_seq       number(38);
   l_acct_max_right_seq      number(38);
   l_acct_min_left_seq       number(38);
   l_acct_min_right_seq      number(38);
   l_application_id          number(38);
   l_entity_code             varchar2(30);
   l_event_class_code        varchar2(30);
   l_source_code             varchar2(30);
   l_count_1                 number(38);
   l_count_2                 number(38);
   l_log_module              VARCHAR2(240);
   --
   -- Cursor declarations
   --
   CURSOR c_condition_exist
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code;

   CURSOR c_acct_brackets
   IS
   SELECT 'x'
     FROM xla_acct_line_types_b d
    WHERE d.application_id            = p_application_id
      AND d.amb_context_code          = p_amb_context_code
      AND d.entity_code               = p_entity_code
      AND d.event_class_code          = p_event_class_code
      AND d.accounting_line_type_code = p_accounting_line_type_code
      AND d.accounting_line_code      = p_accounting_line_code
      AND exists(SELECT count(1)
                   FROM xla_conditions c
                  WHERE c.application_id            = d.application_id
                    AND c.amb_context_code          = d.amb_context_code
                    AND c.entity_code               = d.entity_code
                    AND c.event_class_code          = d.event_class_code
                    AND c.accounting_line_type_code = d.accounting_line_type_code
                    AND c.accounting_line_code      = d.accounting_line_code
                    AND c.bracket_left_code is not null
                  MINUS
                 SELECT count(1)
                   FROM xla_conditions c1
                  WHERE c1.application_id            = d.application_id
                    AND c1.amb_context_code          = d.amb_context_code
                    AND c1.entity_code               = d.entity_code
                    AND c1.event_class_code          = d.event_class_code
                    AND c1.accounting_line_type_code = d.accounting_line_type_code
                    AND c1.accounting_line_code      = d.accounting_line_code
                    AND c1.bracket_right_code is not null);

   CURSOR c_acct_max_left_seq
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_left_code is not null;

   CURSOR c_acct_max_right_seq
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_right_code is not null;

   CURSOR c_acct_min_left_seq
   IS
   SELECT min(user_sequence)
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_left_code is not null;

   CURSOR c_acct_min_right_seq
   IS
   SELECT min(user_sequence)
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_right_code is not null;

   -- Check if any empty rows exist with just the sequence number
   CURSOR c_source
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_left_code is null
      AND c.bracket_right_code is null
      AND c.source_code is null;

   -- Check if any rows exist with just left and right bracket
   CURSOR c_left_right_bracket
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_left_code is not null
      AND c.bracket_right_code is not null
      AND c.source_code is null;

   -- Get the sequence for the last row
   CURSOR c_acct_sequence
   IS
   SELECT max(user_sequence)
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code;

   -- Check if last row has logical operator
   CURSOR c_acct_last_operator
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.user_sequence             = l_acct_user_sequence
      AND c.logical_operator_code is not null;

   -- Check if any rows exist with just left bracket and logical operator
   CURSOR c_left_bracket_operator
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_left_code is not null
      AND c.source_code is null
      AND c.logical_operator_code is not null;

   -- Get all rows which are not the last row or rows with just left bracket
   -- and have no logical operator
   CURSOR c_no_logical_operator
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND (c.source_code is not null
       OR  c.bracket_right_code is not null)
      AND c.logical_operator_code is null
      AND c.user_sequence <> l_acct_user_sequence;

   l_no_logical_operator  c_no_logical_operator%rowtype;

   -- Check if next row has only right bracket
   -- and have no logical operator
   CURSOR c_only_right_bracket
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.source_code is null
      AND c.bracket_right_code is not null
      AND c.user_sequence = l_no_logical_operator.user_sequence + 1;

   -- Get all rows which have just left bracket and no source
   CURSOR c_no_source_bracket
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.source_code is null
      AND c.bracket_left_code is not null;

   l_no_source_bracket  c_no_source_bracket%rowtype;

   -- Check if next row has only left bracket
   CURSOR c_only_left_bracket
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.bracket_left_code is not null
      AND c.user_sequence = l_no_source_bracket.user_sequence + 1;

   -- Get all rows with logical operator not null
   CURSOR c_log_op_not_null
   IS
   SELECT user_sequence
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.logical_operator_code is not null;

   l_log_op_not_null  c_log_op_not_null%rowtype;

   -- Check if next row has only right bracket
   CURSOR c_right_bracket
   IS
   SELECT 'x'
     FROM xla_conditions c
    WHERE c.application_id            = p_application_id
      AND c.amb_context_code          = p_amb_context_code
      AND c.entity_code               = p_entity_code
      AND c.event_class_code          = p_event_class_code
      AND c.accounting_line_type_code = p_accounting_line_type_code
      AND c.accounting_line_code      = p_accounting_line_code
      AND c.source_code is null
      AND c.bracket_right_code is not null
      AND c.user_sequence = l_log_op_not_null.user_sequence + 1;

BEGIN
   l_log_module := C_DEFAULT_MODULE||'.acct_condition_is_invalid';

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('acct_condition_is_invalid.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   trace('application_id             = '||p_application_id  , C_LEVEL_STATEMENT,l_log_module);
   trace('entity_code                = '||p_entity_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('event_class_code           = '||p_event_class_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('accounting_line_type_code  = '||p_accounting_line_type_code  , C_LEVEL_STATEMENT,l_log_module);
   trace('accounting_line_code       = '||p_accounting_line_code  , C_LEVEL_STATEMENT,l_log_module);

   l_application_id		:= p_application_id;
   l_entity_code		   := p_entity_code;
   l_event_class_code	:= p_event_class_code;
   --
   -- Check if accounting line type conditions exist
   --

   OPEN c_condition_exist;
   FETCH c_condition_exist
    INTO l_exist;
    IF c_condition_exist%found then
       trace('c_condition_exist%found ',C_LEVEL_STATEMENT,l_Log_module);
      --
      -- check if condition has unequal brackets
      --
      OPEN c_acct_brackets;
      FETCH c_acct_brackets
       INTO l_exist;
      IF c_acct_brackets%found THEN
         trace('c_acct_brackets%found ',C_LEVEL_STATEMENT,l_Log_module);
         p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
         l_return := TRUE;
      ELSE
         trace('c_acct_brackets%notfound ',C_LEVEL_STATEMENT,l_Log_module);
         p_message_name := NULL;
         l_return := FALSE;
      END IF;
      CLOSE c_acct_brackets;

      --
      -- check if sequence for right bracket is less than left bracket
      --
      IF l_return = FALSE THEN
         OPEN c_acct_max_left_seq;
         FETCH c_acct_max_left_seq
          INTO l_acct_max_left_seq;
         CLOSE c_acct_max_left_seq;

         OPEN c_acct_max_right_seq;
         FETCH c_acct_max_right_seq
          INTO l_acct_max_right_seq;
         CLOSE c_acct_max_right_seq;

         IF l_acct_max_right_seq < l_acct_max_left_seq then
            p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;
      END IF;

      IF l_return = FALSE THEN
         OPEN c_acct_min_left_seq;
         FETCH c_acct_min_left_seq
          INTO l_acct_min_left_seq;
         CLOSE c_acct_min_left_seq;

         OPEN c_acct_min_right_seq;
         FETCH c_acct_min_right_seq
          INTO l_acct_min_right_seq;
         CLOSE c_acct_min_right_seq;

         IF l_acct_min_right_seq < l_acct_min_left_seq then
            p_message_name := 'XLA_AB_CON_UNEQUAL_BRCKT';
            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;
      END IF;

         --
         -- Check if condition has a row with no brackets and no source
         --
         IF l_return = FALSE THEN

            OPEN c_source;
            FETCH c_source
             INTO l_exist;

            IF c_source%found then
               trace('c_source%found',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := 'XLA_AB_NO_BRCKT_SOURCE';
               l_return := TRUE;
            ELSE
               trace('c_source%notfound',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_source;
         END IF;

         --
         -- Check if any rows exist with just left and right bracket
         --
         IF l_return = FALSE THEN

            OPEN c_left_right_bracket;
            FETCH c_left_right_bracket
             INTO l_exist;

            IF c_left_right_bracket%found THEN
               trace('c_left_right_bracket%found',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := 'XLA_AB_ONLY_LEFT_RIGHT_BRCKT';
               l_return := TRUE;
            ELSE
               trace('c_left_right_bracket%notfound',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_left_right_bracket;
         END IF;

         --
         -- Check if any rows exist with just left bracket and logical operator
         --
         IF l_return = FALSE THEN

            OPEN c_left_bracket_operator;
            FETCH c_left_bracket_operator
             INTO l_exist;

            IF c_left_bracket_operator%found THEN
               trace('c_left_bracket_operator%found',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := 'XLA_AB_LEFT_BRCKT_OPERATOR';
               l_return := TRUE;
            ELSE
               trace('c_left_bracket_operator%notfound',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_left_bracket_operator;
         END IF;

/*
         IF l_return = FALSE THEN
            --
            -- Get all rows with no source and only left bracket
            --

            OPEN c_no_source_bracket;
            LOOP
            FETCH c_no_source_bracket
             INTO l_no_source_bracket;
            EXIT WHEN c_no_source_bracket%notfound or l_return = TRUE;

               -- Check if next row has only left bracket
               OPEN c_only_left_bracket;
               FETCH c_only_left_bracket
                INTO l_exist;

               IF c_only_left_bracket%found then
                  trace('c_only_left_bracket%found',C_LEVEL_STATEMENT,l_Log_module);

                  p_message_name := null;
                  l_return := FALSE;
               ELSE
                  trace('c_only_left_bracket%notfound',C_LEVEL_STATEMENT,l_Log_module);
                  p_message_name := 'XLA_AB_ONLY_LEFT_RIGHT_BRCKT';
                  l_return := TRUE;
               END IF;
               CLOSE c_only_left_bracket;
            END LOOP;
            CLOSE c_no_source_bracket;
         END IF;
*/
         IF l_return = FALSE THEN
            --
            -- Get all rows with logical operator not null
            --
            OPEN c_log_op_not_null;
            LOOP
            FETCH c_log_op_not_null
             INTO l_log_op_not_null;
            EXIT WHEN c_log_op_not_null%notfound or l_return = TRUE;

               -- Check if next row has only right bracket
               OPEN c_right_bracket;
               FETCH c_right_bracket
                INTO l_exist;

               IF c_right_bracket%found THEN
                  trace('c_right_bracket%found ',C_LEVEL_STATEMENT,l_Log_module);
                  p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
                  l_return := TRUE;
               ELSE
                  trace('c_right_bracket%notfound ',C_LEVEL_STATEMENT,l_Log_module);

                  p_message_name := null;
                  l_return := FALSE;
               END IF;
               CLOSE c_right_bracket;
            END LOOP;
            CLOSE c_log_op_not_null;
         END IF;

         --
         -- Check if condition has wrong number of logical operators
         --
/*
         IF l_return = FALSE THEN

            -- Get last row sequence
            OPEN c_acct_sequence;
            FETCH c_acct_sequence
             INTO l_acct_user_sequence;
            CLOSE c_acct_sequence;

            --
            -- Check if last sequence has a not null logical operator
            --
            OPEN c_acct_last_operator;
            FETCH c_acct_last_operator
             INTO l_exist;

            IF c_acct_last_operator%found then
               trace('c_acct_last_operator%found ',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
               l_return := TRUE;
            ELSE
               trace('c_acct_last_operator%notfound ',C_LEVEL_STATEMENT,l_Log_module);
               p_message_name := NULL;
               l_return := FALSE;
            END IF;
            CLOSE c_acct_last_operator;

            IF l_return = FALSE THEN
               --
               -- Get all rows which are not the last row or rows with just left bracket
               -- and have no logical operator
               --

               OPEN c_no_logical_operator;
               LOOP
               FETCH c_no_logical_operator
                INTO l_no_logical_operator;
               EXIT WHEN c_no_logical_operator%notfound or l_return = TRUE;
               trace('c_no_logical_operator%found ',C_LEVEL_STATEMENT,l_Log_module);

                  -- Check if next row has only right bracket
                  OPEN c_only_right_bracket;
                  FETCH c_only_right_bracket
                   INTO l_exist;

                  IF c_only_right_bracket%found THEN
                     trace('c_only_right_bracket%found ',C_LEVEL_STATEMENT,l_Log_module);
                     p_message_name := null;
                     l_return := FALSE;
                  ELSE
                     trace('c_only_right_bracket%notfound ',C_LEVEL_STATEMENT,l_Log_module);
                     p_message_name := 'XLA_AB_CON_UNEQUAL_OPRTR';
                     l_return := TRUE;
                  END IF;
                  CLOSE c_only_right_bracket;
               END LOOP;
               CLOSE c_no_logical_operator;
            END IF;
         END IF;
*/
   END IF;

   CLOSE c_condition_exist;

   trace('p_message_name = '||p_message_name ,C_LEVEL_STATEMENT,l_log_module);
   trace('acct_condition_is_invalid.End',C_LEVEL_PROCEDURE,l_log_module);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF c_acct_brackets%ISOPEN THEN
         CLOSE c_acct_brackets;
      END IF;
      IF c_acct_last_operator%ISOPEN THEN
         CLOSE c_acct_last_operator;
      END IF;
      IF c_condition_exist%ISOPEN THEN
         CLOSE c_condition_exist;
      END IF;
      IF c_acct_max_left_seq%ISOPEN THEN
         CLOSE c_acct_max_left_seq;
      END IF;
      IF c_acct_max_right_seq%ISOPEN THEN
         CLOSE c_acct_max_right_seq;
      END IF;
      IF c_acct_min_left_seq%ISOPEN THEN
         CLOSE c_acct_min_left_seq;
      END IF;
      IF c_acct_min_right_seq%ISOPEN THEN
         CLOSE c_acct_min_right_seq;
      END IF;

      RAISE;

   WHEN OTHERS                                   THEN

      IF c_acct_brackets%ISOPEN THEN
         CLOSE c_acct_brackets;
      END IF;
      IF c_acct_last_operator%ISOPEN THEN
         CLOSE c_acct_last_operator;
      END IF;
      IF c_condition_exist%ISOPEN THEN
         CLOSE c_condition_exist;
      END IF;
      IF c_acct_max_left_seq%ISOPEN THEN
         CLOSE c_acct_max_left_seq;
      END IF;
      IF c_acct_max_right_seq%ISOPEN THEN
         CLOSE c_acct_max_right_seq;
      END IF;
      IF c_acct_min_left_seq%ISOPEN THEN
         CLOSE c_acct_min_left_seq;
      END IF;
      IF c_acct_min_right_seq%ISOPEN THEN
         CLOSE c_acct_min_right_seq;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_conditions_pkg.acct_condition_is_invalid');

END acct_condition_is_invalid;

BEGIN
--   l_log_module     := C_DEFAULT_MODULE;
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
END xla_conditions_pkg;

/

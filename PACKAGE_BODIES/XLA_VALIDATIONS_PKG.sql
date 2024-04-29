--------------------------------------------------------
--  DDL for Package Body XLA_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_VALIDATIONS_PKG" AS
/* $Header: xlacmval.pkb 120.16 2006/04/21 18:14:54 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_validations_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Common Validations Package                                     |
|                                                                       |
| HISTORY                                                               |
|    22-May-02 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| object_name_is_valid                                                  |
|                                                                       |
| Checks whether the object name is valid                               |
|                                                                       |
+======================================================================*/
FUNCTION  object_name_is_valid
  (p_object_name                  IN  VARCHAR2)
RETURN BOOLEAN

IS

    --
    -- Variable declarations
    --
    l_length     number      := 0;
    l_char       varchar2(1) := null;
    l_return     BOOLEAN     := TRUE;

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.object_name_is_valid'          , 10);

xla_utility_pkg.trace('Object Name               = '||p_object_name     , 20);

     SELECT length(p_object_name)
       INTO l_length
       FROM dual;

     FOR i in 1..l_length
     LOOP
       SELECT substr(p_object_name,i,1)
         INTO l_char
         FROM dual;
       IF l_return = TRUE THEN
          IF (l_char = '&' OR
             l_char = '''') THEN
             l_return := FALSE;
          ELSE
             l_return := TRUE;
          END IF;
       END IF;
    END LOOP;

xla_utility_pkg.trace('< xla_validations_pkg.object_name_is_valid'           , 10);

RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.object_name_is_valid');
END object_name_is_valid;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_product_rule_info                                                 |
|                                                                       |
| Gets name and owner for the product rule code                         |
|                                                                       |
+======================================================================*/
PROCEDURE  get_product_rule_info
  (p_application_id                  IN  NUMBER
  ,p_amb_context_code                IN  VARCHAR2
  ,p_product_rule_type_code          IN  VARCHAR2
  ,p_product_rule_code               IN  VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type               IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_prod_rule
    IS
    SELECT fat.application_name, xpr.name, xlk.meaning product_rule_type_dsp
      FROM xla_product_rules_tl xpr
         , fnd_application_tl   fat
         , xla_lookups          xlk
     WHERE xlk.lookup_type             = 'XLA_OWNER_TYPE'
       AND xlk.lookup_code             = xpr.product_rule_type_code
       AND fat.application_id          = xpr.application_id
       AND fat.language                = USERENV('LANG')
       AND xpr.application_id          = p_application_id
       AND xpr.amb_context_code        = p_amb_context_code
       AND xpr.product_rule_type_code  = p_product_rule_type_code
       AND xpr.product_rule_code       = p_product_rule_code
       AND xpr.language                = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_product_rule_info'          , 10);

xla_utility_pkg.trace('Application_id                = '||p_application_id     , 20);
xla_utility_pkg.trace('product_rule_type_code        = '||p_product_rule_type_code     , 20);
xla_utility_pkg.trace('product_rule_code        = '||p_product_rule_code     , 20);

   OPEN c_prod_rule;
   FETCH c_prod_rule
    INTO p_application_name, p_product_rule_name, p_product_rule_type;
   CLOSE c_prod_rule;

xla_utility_pkg.trace('< xla_validations_pkg.get_product_rule_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_product_rule_info');

END get_product_rule_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_description_info                                                  |
|                                                                       |
| Gets name and owner for the description rule code                     |
|                                                                       |
+======================================================================*/
PROCEDURE  get_description_info
  (p_application_id                 IN  NUMBER
  ,p_amb_context_code               IN  VARCHAR2
  ,p_description_type_code          IN  VARCHAR2
  ,p_description_code               IN  VARCHAR2
  ,p_application_name               IN OUT NOCOPY VARCHAR2
  ,p_description_name               IN OUT NOCOPY VARCHAR2
  ,p_description_type               IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_desc_rule
    IS
    SELECT fat.application_name, xdt.name, xlk.meaning description_type_code_dsp
      FROM xla_descriptions_tl  xdt
         , fnd_application_tl   fat
         , xla_lookups          xlk
     WHERE xlk.lookup_type            = 'XLA_OWNER_TYPE'
       AND xlk.lookup_code            = xdt.description_type_code
       AND fat.application_id         = xdt.application_id
       AND fat.language               = USERENV('LANG')
       AND xdt.application_id         = p_application_id
       AND xdt.amb_context_code       = p_amb_context_code
       AND xdt.description_type_code  = p_description_type_code
       AND xdt.description_code       = p_description_code
       AND xdt.language               = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_description_info'          , 10);

xla_utility_pkg.trace('Application_id                = '||p_application_id     , 20);
xla_utility_pkg.trace('description_type_code        = '||p_description_type_code     , 20);
xla_utility_pkg.trace('description_code        = '||p_description_code     , 20);

   OPEN c_desc_rule;
   FETCH c_desc_rule
    INTO p_application_name, p_description_name, p_description_type;
   CLOSE c_desc_rule;

xla_utility_pkg.trace('< xla_validations_pkg.get_description_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_description_info');

END get_description_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_segment_rule_info                                                 |
|                                                                       |
| Gets name and owner for the segment rule code                         |
|                                                                       |
+======================================================================*/
PROCEDURE  get_segment_rule_info
  (p_application_id                  IN  NUMBER
  ,p_amb_context_code                IN  VARCHAR2
  ,p_segment_rule_type_code          IN  VARCHAR2
  ,p_segment_rule_code               IN  VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_segment_rule_name               IN OUT NOCOPY VARCHAR2
  ,p_segment_rule_type               IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_seg_rule
    IS
    SELECT fat.application_name, xsr.name, xlk.meaning segment_rule_type_dsp
      FROM xla_seg_rules_tl     xsr
         , fnd_application_tl   fat
         , xla_lookups          xlk
     WHERE xlk.lookup_type             = 'XLA_OWNER_TYPE'
       AND xlk.lookup_code             = xsr.segment_rule_type_code
       AND fat.application_id          = xsr.application_id
       AND fat.language                = USERENV('LANG')
       AND xsr.application_id          = p_application_id
       AND xsr.amb_context_code        = p_amb_context_code
       AND xsr.segment_rule_type_code  = p_segment_rule_type_code
       AND xsr.segment_rule_code       = p_segment_rule_code
       AND xsr.language                = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_segment_rule_info'          , 10);

xla_utility_pkg.trace('Application_id                = '||p_application_id     , 20);
xla_utility_pkg.trace('segment_rule_type_code        = '||p_segment_rule_type_code     , 20
);
xla_utility_pkg.trace('segment_rule_code        = '||p_segment_rule_code     , 20);

   OPEN c_seg_rule;
   FETCH c_seg_rule
    INTO p_application_name, p_segment_rule_name, p_segment_rule_type;
   CLOSE c_seg_rule;

xla_utility_pkg.trace('< xla_validations_pkg.get_segment_rule_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_segment_rule_info');

END get_segment_rule_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_line_type_info                                                    |
|                                                                       |
| Gets name and owner for the line type code                            |
|                                                                       |
+======================================================================*/
PROCEDURE  get_line_type_info
  (p_application_id                     IN  NUMBER
  ,p_amb_context_code                   IN  VARCHAR2
  ,p_entity_code                        IN  VARCHAR2
  ,p_event_class_code                   IN  VARCHAR2
  ,p_accounting_line_type_code          IN  VARCHAR2
  ,p_accounting_line_code               IN  VARCHAR2
  ,p_application_name                   IN OUT NOCOPY VARCHAR2
  ,p_accounting_line_type_name          IN OUT NOCOPY VARCHAR2
  ,p_accounting_line_type               IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_line_type
    IS
    SELECT fat.application_name, xal.name, xlk.meaning accounting_line_type_dsp
      FROM xla_acct_line_types_tl   xal
         , fnd_application_tl       fat
         , xla_lookups              xlk
     WHERE xlk.lookup_type                = 'XLA_OWNER_TYPE'
       AND xlk.lookup_code                = xal.accounting_line_type_code
       AND fat.application_id             = xal.application_id
       AND fat.language                   = USERENV('LANG')
       AND xal.application_id             = p_application_id
       AND xal.amb_context_code           = p_amb_context_code
       AND xal.entity_code                = p_entity_code
       AND xal.event_class_code           = p_event_class_code
       AND xal.accounting_line_type_code  = p_accounting_line_type_code
       AND xal.accounting_line_code       = p_accounting_line_code
       AND xal.language                   = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_line_type_info'          , 10);

xla_utility_pkg.trace('Application_id                = '||p_application_id     , 20);
xla_utility_pkg.trace('entity_code                     = '||p_entity_code     , 20);
xla_utility_pkg.trace('event_class_code                = '||p_event_class_code     , 20);
xla_utility_pkg.trace('accounting_line_type_code        = '||p_accounting_line_type_code     , 20
);
xla_utility_pkg.trace('accounting_line_code        = '||p_accounting_line_code     , 20);

   OPEN c_line_type;
   FETCH c_line_type
    INTO p_application_name, p_accounting_line_type_name, p_accounting_line_type;
   CLOSE c_line_type;

xla_utility_pkg.trace('< xla_validations_pkg.get_line_type_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_line_type_info');

END get_line_type_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_event_class_info                                                  |
|                                                                       |
| Gets name for the event class                                         |
|                                                                       |
+======================================================================*/
PROCEDURE  get_event_class_info
  (p_application_id                     IN  NUMBER
  ,p_entity_code                        IN  VARCHAR2
  ,p_event_class_code                   IN  VARCHAR2
  ,p_event_class_name                   IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_event_class
    IS
    SELECT name
      FROM xla_event_classes_tl
     WHERE application_id             = p_application_id
       AND entity_code                = p_entity_code
       AND event_class_code           = p_event_class_code
       AND language                   = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_event_class_info'          , 10);

xla_utility_pkg.trace('Application_id                = '||p_application_id     , 20);
xla_utility_pkg.trace('entity_code                     = '||p_entity_code     , 20);
xla_utility_pkg.trace('event_class_code                = '||p_event_class_code     , 20);

   OPEN c_event_class;
   FETCH c_event_class
    INTO p_event_class_name;
   CLOSE c_event_class;

xla_utility_pkg.trace('< xla_validations_pkg.get_event_class_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_event_class_info');

END get_event_class_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_event_type_info                                                   |
|                                                                       |
| Gets name for the event class                                         |
|                                                                       |
+======================================================================*/
PROCEDURE  get_event_type_info
  (p_application_id                     IN  NUMBER
  ,p_entity_code                        IN  VARCHAR2
  ,p_event_class_code                   IN  VARCHAR2
  ,p_event_type_code                    IN  VARCHAR2
  ,p_event_type_name                    IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_event_type
    IS
    SELECT name
      FROM xla_event_types_tl
     WHERE application_id             = p_application_id
       AND entity_code                = p_entity_code
       AND event_class_code           = p_event_class_code
       AND event_type_code            = p_event_type_code
       AND language                   = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_event_type_info'          , 10);

xla_utility_pkg.trace('Application_id                = '||p_application_id     , 20);
xla_utility_pkg.trace('entity_code                     = '||p_entity_code     , 20);
xla_utility_pkg.trace('event_class_code                = '||p_event_class_code     , 20);
xla_utility_pkg.trace('event_type_code                = '||p_event_type_code     , 20);

   OPEN c_event_type;
   FETCH c_event_type
    INTO p_event_type_name;
   CLOSE c_event_type;

xla_utility_pkg.trace('< xla_validations_pkg.get_event_type_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_event_type_info');

END get_event_type_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_source_info                                                       |
|                                                                       |
| Gets name for the source                                              |
|                                                                       |
+======================================================================*/
PROCEDURE  get_source_info
  (p_application_id                     IN  NUMBER
  ,p_source_type_code                   IN  VARCHAR2
  ,p_source_code                        IN  VARCHAR2
  ,p_source_name                        IN OUT NOCOPY VARCHAR2
  ,p_source_type                        IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_source
    IS
    SELECT s.name, l.meaning source_type
      FROM xla_sources_tl s, xla_lookups l
     WHERE s.application_id             = p_application_id
       AND s.source_type_code           = p_source_type_code
       AND s.source_code                = p_source_code
       AND s.language                   = USERENV('LANG')
       AND s.source_type_code           = l.lookup_code
       AND l.lookup_type                = 'XLA_SOURCE_TYPE';

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_source_info'          , 10);

xla_utility_pkg.trace('Application_id                  = '||p_application_id     , 20);
xla_utility_pkg.trace('source_code                     = '||p_source_code     , 20);
xla_utility_pkg.trace('source_type_code                = '||p_source_type_code     , 20);

   OPEN c_source;
   FETCH c_source
    INTO p_source_name, p_source_type;
   CLOSE c_source;

xla_utility_pkg.trace('< xla_validations_pkg.get_source_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_source_info');

END get_source_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_analytical_criteria_info                                          |
|                                                                       |
| Gets name for the analytical criteria                                 |
|                                                                       |
+======================================================================*/
PROCEDURE  get_analytical_criteria_info
  (p_amb_context_code                          IN  VARCHAR2
  ,p_anal_criterion_type_code                  IN  VARCHAR2
  ,p_analytical_criterion_code                 IN  VARCHAR2
  ,p_analytical_criteria_name                  IN OUT NOCOPY VARCHAR2
  ,p_analytical_criteria_type                  IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_anc
    IS
    SELECT s.name, l.meaning analytical_criteria_type
      FROM xla_analytical_hdrs_vl s, xla_lookups l
     WHERE s.amb_context_code                 = p_amb_context_code
       AND s.analytical_criterion_type_code    = p_anal_criterion_type_code
       AND s.analytical_criterion_code         = p_analytical_criterion_code
       AND s.analytical_criterion_type_code    = l.lookup_code
       AND l.lookup_type                      = 'XLA_OWNER_TYPE';

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_analytical_criteria_info'          , 10);

xla_utility_pkg.trace('analytical_criteria_code          = '||p_analytical_criterion_code     , 20);
xla_utility_pkg.trace('anal_criteria_type_code           = '||p_anal_criterion_type_code     , 20);

   OPEN c_anc;
   FETCH c_anc
    INTO p_analytical_criteria_name, p_analytical_criteria_type;
   CLOSE c_anc;

xla_utility_pkg.trace('< xla_validations_pkg.get_analytical_criteria_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_analytical_criteria_info');

END get_analytical_criteria_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_accounting_method_info                                            |
|                                                                       |
| Gets name for the accounting method                                   |
|                                                                       |
+======================================================================*/
PROCEDURE  get_accounting_method_info
  (p_accounting_method_type_code             IN  VARCHAR2
  ,p_accounting_method_code                  IN  VARCHAR2
  ,p_accounting_method_name                  IN OUT NOCOPY VARCHAR2
  ,p_accounting_method_type                  IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_anc
    IS
    SELECT xam.name, xlk.meaning accounting_method_type
      FROM xla_acctg_methods_tl xam
         , xla_lookups          xlk
     WHERE xlk.lookup_type                    = 'XLA_OWNER_TYPE'
       AND xlk.lookup_code                    = xam.accounting_method_type_code
       AND xam.accounting_method_type_code    = p_accounting_method_type_code
       AND xam.accounting_method_code         = p_accounting_method_code
       AND xam.language                       = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_accounting_method_info'          , 10);

xla_utility_pkg.trace('accounting_method_type_code      = '||p_accounting_method_type_code     , 20);
xla_utility_pkg.trace('accounting_method_code           = '||p_accounting_method_code     , 20);

   OPEN c_anc;
   FETCH c_anc
    INTO p_accounting_method_name, p_accounting_method_type;
   CLOSE c_anc;

xla_utility_pkg.trace('< xla_validations_pkg.get_accounting_method_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_accounting_method_info');

END get_accounting_method_info;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_application_name                                                  |
|                                                                       |
| Gets name for the application                                         |
|                                                                       |
+======================================================================*/
PROCEDURE  get_application_name
  (p_application_id             IN  NUMBER
  ,p_application_name           IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_application
    IS
    SELECT application_name
      FROM fnd_application_tl
     WHERE application_id    = p_application_id
       AND language          = USERENV('LANG');

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_application_name'          , 10);

xla_utility_pkg.trace('application_id      = '||p_application_id     , 20);

   OPEN c_application;
   FETCH c_application
    INTO p_application_name;
   CLOSE c_application;

xla_utility_pkg.trace('< xla_validations_pkg.get_application_name'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_application_name');

END get_application_name;

/*======================================================================+
|                                                                       |
| Public procedure                                                      |
|                                                                       |
| get_ledger_name                                                       |
|                                                                       |
| Gets name for the ledger                                              |
|                                                                       |
+======================================================================*/
PROCEDURE  get_ledger_name
  (p_ledger_id             IN  NUMBER
  ,p_ledger_name           IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_ledger
    IS
    SELECT name
      FROM gl_ledgers
     WHERE ledger_id    = p_ledger_id;

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_ledger_name'          , 10);

xla_utility_pkg.trace('ledger_id      = '||p_ledger_id     , 20);

   OPEN c_ledger;
   FETCH c_ledger
    INTO p_ledger_name;
   CLOSE c_ledger;

xla_utility_pkg.trace('< xla_validations_pkg.get_ledger_name'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_ledger_name');

END get_ledger_name;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_trx_acct_def_info                                                 |
|                                                                       |
| Get name and owner for the transaction account definition             |
|                                                                       |
+======================================================================*/
PROCEDURE  get_trx_acct_def_info
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_account_definition_type_code    IN VARCHAR2
  ,p_account_definition_code         IN VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def                    IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type               IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_prod_rule
    IS
    SELECT a.application_name, p.name, l.meaning trx_acct_def_type
      FROM xla_tab_acct_defs_vl p, fnd_application_vl a, xla_lookups l
     WHERE p.application_id                = p_application_id
       AND p.amb_context_code              = p_amb_context_code
       AND p.account_definition_type_code  = p_account_definition_type_code
       AND p.account_definition_code       = p_account_definition_code
       AND a.application_id                = p_application_id
       AND l.lookup_code                   = p_account_definition_type_code
       AND l.lookup_type                   = 'XLA_OWNER_TYPE';

BEGIN

xla_utility_pkg.trace('> xla_validations_pkg.get_trx_acct_def_info'          , 10);

xla_utility_pkg.trace('Application_id         = '||p_application_id     , 20);
xla_utility_pkg.trace('account_definition_type_code   = '||p_account_definition_type_code    , 20);
xla_utility_pkg.trace('account_definition_code   = '||p_account_definition_code     , 20);

   OPEN c_prod_rule;
   FETCH c_prod_rule
    INTO p_application_name, p_trx_acct_def, p_trx_acct_def_type;
   CLOSE c_prod_rule;

xla_utility_pkg.trace('< xla_validations_pkg.get_trx_acct_def_info'           , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_trx_acct_def_info');

END get_trx_acct_def_info;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_trx_acct_type_info                                                |
|                                                                       |
| Get name for the transaction account type                             |
|                                                                       |
+======================================================================*/
PROCEDURE  get_trx_acct_type_info
  (p_application_id                  IN  NUMBER
  ,p_account_type_code               IN VARCHAR2
  ,p_trx_acct_type                   IN OUT NOCOPY VARCHAR2)

IS

    --
    -- Cursor declarations
    --
    CURSOR c_type
    IS
    SELECT name
      FROM xla_tab_acct_types_vl
     WHERE application_id             = p_application_id
       AND account_type_code          = p_account_type_code;

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.get_trx_acct_type_info'          , 10);
xla_utility_pkg.trace('Application_id  =  '||p_application_id     , 20);
xla_utility_pkg.trace('account_type_code     = '||p_account_type_code     , 20);

   OPEN c_type;
   FETCH c_type
    INTO p_trx_acct_type;
   CLOSE c_type;

xla_utility_pkg.trace('< xla_validations_pkg.get_trx_acct_type_info'       , 10);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.get_trx_acct_type_info');

END get_trx_acct_type_info;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| table_name_is_valid                                                   |
|                                                                       |
| Checks whether the table name is valid                                |
|                                                                       |
+======================================================================*/
FUNCTION  table_name_is_valid
  (p_table_name                  IN  VARCHAR2)
RETURN BOOLEAN

IS

    --
    -- Variable declarations
    --

    l_exist      varchar2(1) := null;
    l_return     BOOLEAN     := TRUE;

   CURSOR c_user_objects
   IS
   SELECT 'x'
     FROM user_objects o
    WHERE o.object_name = p_table_name;

BEGIN
xla_utility_pkg.trace('> xla_validations_pkg.table_name_is_valid'          , 10);

xla_utility_pkg.trace('Table Name               = '||p_table_name     , 20);

     OPEN c_user_objects;
     FETCH c_user_objects
      INTO l_exist;
     IF c_user_objects%found THEN
        l_return := TRUE;
     ELSE
        l_return := FALSE;
     END IF;
     CLOSE c_user_objects;

xla_utility_pkg.trace('< xla_validations_pkg.table_name_is_valid'           , 10);

RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.table_name_is_valid');
END table_name_is_valid;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| reference_is_valid                                                    |
|                                                                       |
| Check if reference object is not used by other transaction            |
| objects within the same event class.                                  |
+======================================================================*/
FUNCTION reference_is_valid
  (p_table_name                     IN  VARCHAR2
  ,p_event_class_code               IN  VARCHAR2)
RETURN BOOLEAN

IS

    --
    -- variable declarations
    --

     l_exist   varchar2(1) := null;
     l_return       BOOLEAN     := TRUE;


   CURSOR c_reference_objects
   IS
   SELECT 'x'
     FROM xla_reference_objects_f_v
    WHERE event_class_code        = p_event_class_code
      AND reference_object_name   = p_table_name;

BEGIN

     OPEN c_reference_objects;
     FETCH c_reference_objects
      INTO l_exist;
     IF c_reference_objects%found THEN
        l_return := FALSE;
     ELSE
        l_return := TRUE;
     END IF;
     CLOSE c_reference_objects;

RETURN l_return;

EXCEPTION

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.reference_is_valid');
END reference_is_valid;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| join_condition_is_valid                                               |
|                                                                       |
| Check if join condition is valid                                      |
|                                                                       |
+======================================================================*/
FUNCTION  join_condition_is_valid
  (p_trx_object_name    IN  VARCHAR2
  ,p_ref_object_name    IN  VARCHAR2
  ,p_join_condition     IN  VARCHAR2
  ,p_error_message      OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

  l_sql        VARCHAR2(2000);
  l_dummy      PLS_INTEGER;
  l_return     BOOLEAN;

BEGIN

xla_utility_pkg.trace('> xla_validations_pkg.join_condition_is_valid'          , 10);

   BEGIN

      l_sql := 'SELECT 1 FROM '
            || p_trx_object_name
            || ','
            || p_ref_object_name
            || ' WHERE '
            || p_join_condition
            || ' AND 1 = 2';

      EXECUTE IMMEDIATE l_sql INTO l_dummy;

      xla_utility_pkg.trace('SQL               = '||l_sql   , 20);

   EXCEPTION
   WHEN no_data_found THEN
      l_return := TRUE;
   WHEN OTHERS THEN
      l_return        := FALSE;
      p_error_message := SQLERRM;
   END;

xla_utility_pkg.trace('< xla_validations_pkg.join_condition_is_valid'           , 10);

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_validations_pkg.join_condition_is_valid');

END join_condition_is_valid;

END xla_validations_pkg;

/

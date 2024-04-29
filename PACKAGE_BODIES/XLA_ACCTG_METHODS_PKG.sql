--------------------------------------------------------
--  DDL for Package Body XLA_ACCTG_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCTG_METHODS_PKG" AS
/* $Header: xlaamsam.pkb 120.8 2005/05/24 13:58:50 ksvenkat ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acctg_methods_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Subledger Accounting Methods                                   |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_method_details                                                 |
|                                                                       |
| Deletes all details of the accounting method                          |
|                                                                       |
+======================================================================*/

PROCEDURE delete_method_details
  (p_accounting_method_type_code           IN VARCHAR2
  ,p_accounting_method_code                IN VARCHAR2)
IS

BEGIN

   xla_utility_pkg.trace('> xla_acctg_methods_pkg.delete_method_details'   , 10);

   xla_utility_pkg.trace('accounting_method_type_code  = '||p_accounting_method_type_code     , 20);
   xla_utility_pkg.trace('accounting_method_code  = '||p_accounting_method_code     , 20);

   DELETE
     FROM xla_acctg_method_rules
    WHERE accounting_method_type_code    = p_accounting_method_type_code
      AND accounting_method_code         = p_accounting_method_code;

   xla_utility_pkg.trace('< xla_acctg_methods_pkg.delete_method_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_acctg_methods_pkg.delete_method_details');

END delete_method_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_method_details                                                   |
|                                                                       |
| Copies details of a accounting method into a new accounting method    |
|                                                                       |
+======================================================================*/

PROCEDURE copy_method_details
  (p_old_accting_meth_type_code           IN VARCHAR2
  ,p_old_accting_meth_code                IN VARCHAR2
  ,p_new_accting_meth_type_code           IN VARCHAR2
  ,p_new_accting_meth_code                IN VARCHAR2)
IS

   l_creation_date                   DATE;
   l_last_update_date                DATE;
   l_created_by                      INTEGER;
   l_last_update_login               INTEGER;
   l_last_updated_by                 INTEGER;

   l_acctg_method_rule_id            NUMBER(38) ;

   CURSOR c_meth_rules
   IS
   SELECT application_id, amb_context_code, product_rule_type_code, product_rule_code,
          start_date_active, end_date_active
     FROM xla_acctg_method_rules
    WHERE accounting_method_type_code    = p_old_accting_meth_type_code
      AND accounting_method_code         = p_old_accting_meth_code;

   l_meth_rule      c_meth_rules%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_acctg_methods_pkg.copy_method_details'   , 10);

   xla_utility_pkg.trace('old_accting_meth_type_code = '||p_old_accting_meth_type_code , 20);
   xla_utility_pkg.trace('old_accting_meth_code  = '||p_old_accting_meth_code     , 20);
   xla_utility_pkg.trace('new_accting_meth_type_code = '||p_new_accting_meth_type_code , 20);
   xla_utility_pkg.trace('new_accting_meth_code   = '||p_new_accting_meth_code     , 20);

   l_creation_date                   := sysdate;
   l_last_update_date                := sysdate;
   l_created_by                      := xla_environment_pkg.g_usr_id;
   l_last_update_login               := xla_environment_pkg.g_login_id;
   l_last_updated_by                 := xla_environment_pkg.g_usr_id;
      OPEN c_meth_rules;
      LOOP
         FETCH c_meth_rules
          INTO l_meth_rule;
         EXIT WHEN c_meth_rules%notfound;

            SELECT xla_acctg_method_rules_s.nextval
              INTO l_acctg_method_rule_id
              FROM DUAL;

            INSERT INTO xla_acctg_method_rules
              (acctg_method_rule_id
              ,accounting_method_type_code
              ,accounting_method_code
              ,application_id
              ,amb_context_code
              ,product_rule_type_code
              ,product_rule_code
              ,start_date_active
              ,end_date_active
              ,creation_date
              ,created_by
              ,last_update_date
              ,last_updated_by
              ,last_update_login)
            VALUES
              (l_acctg_method_rule_id
              ,p_new_accting_meth_type_code
              ,p_new_accting_meth_code
              ,l_meth_rule.application_id
              ,l_meth_rule.amb_context_code
              ,l_meth_rule.product_rule_type_code
              ,l_meth_rule.product_rule_code
              ,l_meth_rule.start_date_active
              ,l_meth_rule.end_date_active
              ,l_creation_date
              ,l_created_by
              ,l_last_update_date
              ,l_last_updated_by
              ,l_last_update_login);

      END LOOP;
      CLOSE c_meth_rules;

   xla_utility_pkg.trace('< xla_acctg_methods_pkg.copy_method_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_meth_rules%ISOPEN THEN
         CLOSE c_meth_rules;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_meth_rules%ISOPEN THEN
         CLOSE c_meth_rules;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_acctg_methods_pkg.copy_method_details');

END copy_method_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| method_in_use                                                         |
|                                                                       |
| Returns true if the accounting method is assigned to a ledger         |
|                                                                       |
+======================================================================*/

FUNCTION method_in_use
  (p_event                            IN VARCHAR2
  ,p_accounting_method_type_code      IN VARCHAR2
  ,p_accounting_method_code           IN VARCHAR2
  ,p_ledger_name                      IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return        BOOLEAN;
   l_exist         VARCHAR2(1);
   l_ledger_name   VARCHAR2(30) := null;

   CURSOR c_assignment_exist
   IS
   SELECT name ledger_name
     FROM xla_gl_ledgers_v
    WHERE sla_accounting_method_type         = p_accounting_method_type_code
      AND sla_accounting_method_code         = p_accounting_method_code;

BEGIN

   xla_utility_pkg.trace('> xla_acctg_methods_pkg.method_in_use'   , 10);

   xla_utility_pkg.trace('event                   = '||p_event  , 20);
   xla_utility_pkg.trace('accounting_method_type_code  = '||p_accounting_method_type_code     , 20);
   xla_utility_pkg.trace('accounting_method_code  = '||p_accounting_method_code     , 20);

   IF p_event in ('DELETE','UPDATE','DISABLE') THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_ledger_name;
      IF c_assignment_exist%found then
         p_ledger_name := l_ledger_name;
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_assignment_exist;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_acctg_methods_pkg.method_in_use');

   END IF;

   xla_utility_pkg.trace('< xla_acctg_methods_pkg.method_in_use'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_acctg_methods_pkg.method_in_use');

END method_in_use;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| method_is_invalid                                                     |
|                                                                       |
| Returns true if the accounting method is invalid                      |
|                                                                       |
+======================================================================*/

FUNCTION method_is_invalid
  (p_accounting_method_type_code           IN VARCHAR2
  ,p_accounting_method_code                IN VARCHAR2
  ,p_message_name                    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN;
   l_exist                   VARCHAR2(1);
   l_message_name            VARCHAR2(30);
   l_count                   NUMBER(10);

BEGIN

   xla_utility_pkg.trace('> xla_acctg_methods_pkg.method_is_invalid'   , 10);

   xla_utility_pkg.trace('accounting_method_type_code  = '||p_accounting_method_type_code     , 20);
   xla_utility_pkg.trace('accounting_method_code  = '||p_accounting_method_code     , 20);

   xla_utility_pkg.trace('< xla_acctg_methods_pkg.method_is_invalid'    , 10);

   l_return := FALSE;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_acctg_methods_pkg.method_is_invalid');

END method_is_invalid;

END xla_acctg_methods_pkg;

/

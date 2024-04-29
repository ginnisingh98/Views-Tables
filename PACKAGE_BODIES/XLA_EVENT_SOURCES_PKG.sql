--------------------------------------------------------
--  DDL for Package Body XLA_EVENT_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENT_SOURCES_PKG" AS
/* $Header: xlaamess.pkb 120.6 2004/06/04 18:24:54 weshen ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_sources_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Sources Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    20-May-04 W. Shen        Delete insert_accounting_source and       |
|                             delete_accounting_source since they are no|
|                             longer used. add new function             |
|                             event_source_details_exist                |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| insert_accounting_source                                              |
|                                                                       |
| Inserts accounting source into line types for the event class         |
|                                                                       |
+======================================================================*/
/*
PROCEDURE insert_accounting_source
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_source_code           IN VARCHAR2
  ,p_acctg_source_default_flag        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
IS

   --
   -- Private variables
   --
   l_exist  varchar2(1);
   l_return BOOLEAN;

   l_creation_date                   DATE := sysdate;
   l_last_update_date                DATE := sysdate;
   l_created_by                      INTEGER := xla_environment_pkg.g_usr_id;
   l_last_update_login               INTEGER := xla_environment_pkg.g_login_id;
   l_last_updated_by                 INTEGER := xla_environment_pkg.g_usr_id;

   --
   -- Cursor declarations
   --

   CURSOR c_class_line_types
   IS
   SELECT application_id, amb_context_code, entity_code, event_class_code,
          accounting_line_type_code, accounting_line_code
     FROM xla_acct_line_types_b
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

   l_class_line_type    c_class_line_types%rowtype;

BEGIN
   xla_utility_pkg.trace('> xla_event_sources_pkg.insert_accounting_source'                       , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

      IF p_acctg_source_default_flag = 'Y' THEN

         OPEN c_class_line_types;
         LOOP
         FETCH c_class_line_types
          INTO l_class_line_type;
         EXIT WHEN c_class_line_types%notfound;

         BEGIN

         INSERT INTO xla_jlt_acct_attrs
         (application_id
         ,amb_context_code
         ,event_class_code
         ,accounting_line_type_code
         ,accounting_line_code
         ,accounting_attribute_code
         ,source_application_id
         ,source_code
         ,source_type_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login)
         VALUES
         (l_class_line_type.application_id
         ,l_class_line_type.amb_context_code
         ,l_class_line_type.event_class_code
         ,l_class_line_type.accounting_line_type_code
         ,l_class_line_type.accounting_line_code
         ,p_accounting_source_code
         ,p_source_application_id
         ,p_source_code
         ,p_source_type_code
         ,l_creation_date
         ,l_created_by
         ,l_last_update_date
         ,l_last_updated_by
         ,l_last_update_login);

         EXCEPTION
            when others then null;
         END;

         END LOOP;
         CLOSE c_class_line_types;
      ELSE
         OPEN c_class_line_types;
         LOOP
         FETCH c_class_line_types
          INTO l_class_line_type;
         EXIT WHEN c_class_line_types%notfound;

         BEGIN

         INSERT INTO xla_jlt_acct_attrs
         (application_id
         ,amb_context_code
         ,event_class_code
         ,accounting_line_type_code
         ,accounting_line_code
         ,accounting_attribute_code
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login)
         VALUES
         (l_class_line_type.application_id
         ,l_class_line_type.amb_context_code
         ,l_class_line_type.event_class_code
         ,l_class_line_type.accounting_line_type_code
         ,l_class_line_type.accounting_line_code
         ,p_accounting_source_code
         ,l_creation_date
         ,l_created_by
         ,l_last_update_date
         ,l_last_updated_by
         ,l_last_update_login);

         EXCEPTION
            when others then null;

         END;

         END LOOP;
         CLOSE c_class_line_types;
      END IF;

   xla_utility_pkg.trace('< xla_event_sources_pkg.insert_accounting_source'                       , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_event_sources_pkg.insert_accounting_source');

END insert_accounting_source;

*/
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_accounting_source                                              |
|                                                                       |
| Deletes accounting source from the line types                         |
|                                                                       |
+======================================================================*/
/*

PROCEDURE delete_accounting_source
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2)
IS

   l_exist   varchar2(30):= null;

   --
   -- Cursor declarations
   --

   CURSOR c_acct_source
   IS
   SELECT accounting_source_code
     FROM xla_acctg_sources_b
    WHERE restrict_source_lov_flag = 'Y'
      OR restrict_source_lov_flag is null;

   l_acct_source  c_acct_source%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_event_sources_pkg.delete_accounting_source'                    , 10);


   OPEN c_acct_source;
   LOOP
      FETCH c_acct_source
       INTO l_acct_source;
      EXIT WHEN c_acct_source%notfound;

      DELETE
        FROM xla_jlt_acct_attrs a
       WHERE a.application_id = p_application_id
         AND a.accounting_attribute_code = l_acct_source.accounting_source_code
         AND not exists (SELECT 'x'
                           FROM xla_event_sources e
                          WHERE e.application_id = a.application_id
                            AND e.event_class_code = a.event_class_code
                           AND e.accounting_source_code = a.accounting_source_code);

   END LOOP;
   CLOSE c_acct_source;

   xla_utility_pkg.trace('< xla_event_sources_pkg.delete_accounting_source'                    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_event_sources_pkg.delete_accounting_source');

END delete_accounting_source;
*/

/*======================================================================+
   p_event: UPDATE or DELETE. If it is UPDATE, which means the form is
            calling this function for updating, no out parameter need
            to be populated since the field will be disabled. If the
            function is called in DELETE mode, then the out parameters
            are needed for the error messege
   p_assignment_level: whether the source is assigned at CLASS level or
            JLT level or AAD level. error message will be different
            for different level
   p_name: the name of the AAD(if the p_assignment_level is AAD) or JLT
            (if the p_assignment_level is JLT), used in the error msg
   p_type: the type of the AAD(if the p_assignment_level is AAD) or JLT
            (if the p_assignment_level is JLT), used in the error msg
+======================================================================*/


FUNCTION event_source_details_exist
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_event                            IN VARCHAR2
  ,p_assignment_level                 OUT NOCOPY VARCHAR2
  ,p_name                             OUT NOCOPY VARCHAR2
  ,p_type                             OUT NOCOPY VARCHAR2)

  return boolean is

   --
   -- Cursor declarations
   --

   CURSOR c_class_assignment
   IS
   SELECT 1
     FROM xla_evt_class_acct_attrs
    WHERE application_id        = p_application_id
      AND event_class_code      = p_event_class_code
      AND source_application_id = p_source_application_id
      AND source_code           = p_source_code
      AND source_type_code      = p_source_type_code;


   CURSOR c_line_assignment
   IS
   SELECT amb_context_code, accounting_line_type_code, accounting_line_code
     FROM xla_jlt_acct_attrs
    WHERE application_id        = p_application_id
      AND event_class_code      = p_event_class_code
      AND source_application_id = p_source_application_id
      AND source_code           = p_source_code
      AND source_type_code      = p_source_type_code;

   CURSOR c_aad_assignment
   IS
   SELECT 1
     FROM xla_aad_hdr_acct_attrs
    WHERE application_id        = p_application_id
      AND event_class_code      = p_event_class_code
      AND source_application_id = p_source_application_id
      AND source_code           = p_source_code
      AND source_type_code      = p_source_type_code;

   l_temp NUMBER;
   l_amb_context_code xla_jlt_acct_attrs.amb_context_code%TYPE;
   l_accounting_line_type_code xla_jlt_acct_attrs.accounting_line_type_code%TYPE;
   l_accounting_line_code xla_jlt_acct_attrs.accounting_line_code%TYPE;
   l_product_rule_type_code xla_aad_hdr_acct_attrs.product_rule_type_code%TYPE;
   l_product_rule_code xla_aad_hdr_acct_attrs.product_rule_code%TYPE;
   l_application_name varchar2(240);

begin

   OPEN c_class_assignment;
   FETCH c_class_assignment
   INTO l_temp;
   IF c_class_assignment%found then
     CLOSE c_class_assignment;
     p_assignment_level := 'CLASS';
     return true;
   ELSE
     CLOSE c_class_assignment;

     OPEN c_line_assignment;
     FETCH c_line_assignment
     INTO l_amb_context_code, l_accounting_line_type_code, l_accounting_line_code;
     IF c_line_assignment%found then
       CLOSE c_line_assignment;
       IF(p_event = 'DELETE') THEN
         p_assignment_level := 'JLT';
         xla_validations_pkg.get_line_type_info(
              p_application_id            => p_application_id
             ,p_amb_context_code          => l_amb_context_code
             ,p_entity_code               => p_entity_code
             ,p_event_class_code          => p_event_class_code
             ,p_accounting_line_type_code => l_accounting_line_type_code
             ,p_accounting_line_code      => l_accounting_line_code
             ,p_application_name          => l_application_name
             ,p_accounting_line_type_name => p_name
             ,p_accounting_line_type      => p_type);
       END IF;
       return true;
     ELSE
       CLOSE c_line_assignment;

       OPEN c_aad_assignment;
       FETCH c_aad_assignment
       INTO l_temp;
       IF c_aad_assignment%found then
         CLOSE c_aad_assignment;
         IF(p_event = 'DELETE') THEN
           p_assignment_level := 'AAD';
           xla_validations_pkg.get_product_rule_info(
                p_application_id            => p_application_id
               ,p_amb_context_code          => l_amb_context_code
               ,p_product_rule_type_code    => l_product_rule_type_code
               ,p_product_rule_code         => l_product_rule_code
               ,p_application_name          => l_application_name
               ,p_product_rule_name         => p_name
               ,p_product_rule_type         => p_type);
         END IF;
         return true;
       ELSE
         CLOSE c_aad_assignment;
         return false;
       END IF;
     END IF;
   END IF;

end;
END xla_event_sources_pkg;

/

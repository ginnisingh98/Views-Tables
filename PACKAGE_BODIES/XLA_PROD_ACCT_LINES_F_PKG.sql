--------------------------------------------------------
--  DDL for Package Body XLA_PROD_ACCT_LINES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_PROD_ACCT_LINES_F_PKG" AS
/* $Header: xlatbpal.pkb 120.8 2003/03/18 00:43:33 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_prod_acct_lines_f_pkg                                          |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_prod_acct_lines                       |
|                                                                       |
| HISTORY                                                               |
|    05/22/01     Dimple Shah    Created                                |
|                                                                       |
+======================================================================*/



/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_description_type_code            IN VARCHAR2
  ,x_description_code                 IN VARCHAR2
  ,x_active_flag                     IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)
IS

CURSOR c IS
SELECT rowid
FROM   xla_prod_acct_lines
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
;

BEGIN
xla_utility_pkg.trace('> .insert_row'                    ,20);

INSERT INTO xla_prod_acct_lines
(creation_date
,created_by
,application_id
,amb_context_code
,product_rule_type_code
,product_rule_code
,entity_code
,event_class_code
,event_type_code
,accounting_line_type_code
,accounting_line_code
,description_type_code
,description_code
,active_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_amb_context_code
,x_product_rule_type_code
,x_product_rule_code
,x_entity_code
,x_event_class_code
,x_event_type_code
,x_accounting_line_type_code
,x_accounting_line_code
,x_description_type_code
,x_description_code
,x_active_flag
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

OPEN c;
FETCH c INTO x_rowid;

IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c;

xla_utility_pkg.trace('< .insert_row'                    ,20);
END insert_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_description_type_code            IN VARCHAR2
  ,x_description_code                 IN VARCHAR2
  ,x_active_flag                     IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,amb_context_code
      ,product_rule_type_code
      ,product_rule_code
      ,entity_code
      ,event_class_code
      ,event_type_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,description_type_code
      ,description_code
      ,active_flag
FROM   xla_prod_acct_lines
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

BEGIN
xla_utility_pkg.trace('> .lock_row'                      ,20);

OPEN c;
FETCH c INTO recinfo;

IF (c%NOTFOUND) THEN
   CLOSE c;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   app_exception.raise_exception;
END IF;
CLOSE c;

IF ( (recinfo.application_id                    = x_application_id)
 AND (recinfo.amb_context_code                  = x_amb_context_code)
 AND (recinfo.product_rule_type_code            = x_product_rule_type_code)
 AND (recinfo.product_rule_code                 = x_product_rule_code)
 AND (recinfo.entity_code                       = x_entity_code)
 AND (recinfo.event_class_code                  = x_event_class_code)
 AND (recinfo.event_type_code                   = x_event_type_code)
 AND (recinfo.accounting_line_type_code         = x_accounting_line_type_code)
 AND (recinfo.accounting_line_code              = x_accounting_line_code)
 AND (recinfo.active_flag                      = x_active_flag)
 AND ((recinfo.description_type_code            = x_description_type_code)
   OR ((recinfo.description_type_code           IS NULL)
  AND (x_description_type_code              IS NULL)))
 AND ((recinfo.description_code            = x_description_code)
   OR ((recinfo.description_code           IS NULL)
  AND (x_description_code              IS NULL)))
                   ) THEN
   null;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

xla_utility_pkg.trace('< .lock_row'                      ,20);
RETURN;

END lock_row;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_description_type_code            IN VARCHAR2
  ,x_description_code                 IN VARCHAR2
  ,x_active_flag                     IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> .update_row'                    ,20);
UPDATE xla_prod_acct_lines
   SET
       last_update_date                 = x_last_update_date
      ,description_type_code            = x_description_type_code
      ,description_code                 = x_description_code
      ,active_flag                      = x_active_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< .update_row'                    ,20);
END update_row;

/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2)

IS

BEGIN
xla_utility_pkg.trace('> .delete_row'                    ,20);
DELETE FROM xla_prod_acct_lines
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< .delete_row'                    ,20);
END delete_row;

end xla_prod_acct_lines_f_pkg;

/

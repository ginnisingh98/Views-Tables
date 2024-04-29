--------------------------------------------------------
--  DDL for Package Body XLA_ACCTG_METHOD_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCTG_METHOD_RULES_F_PKG" AS
/* $Header: xlatbsap.pkb 120.6 2003/04/19 00:32:52 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acctg_method_rules_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acctg_method_rules                    |
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
  ,x_acctg_method_rule_id             IN OUT NOCOPY NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_start_date_active                IN DATE
  ,x_end_date_active                  IN DATE
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)
IS

CURSOR c IS
SELECT rowid
FROM   xla_acctg_method_rules
WHERE  acctg_method_rule_id      = x_acctg_method_rule_id;

BEGIN
xla_utility_pkg.trace('> .insert_row'                    ,20);

INSERT INTO xla_acctg_method_rules
(creation_date
,created_by
,accounting_method_type_code
,accounting_method_code
,acctg_method_rule_id
,amb_context_code
,application_id
,product_rule_type_code
,product_rule_code
,start_date_active
,end_date_active
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_accounting_method_type_code
,x_accounting_method_code
,xla_acctg_method_rules_s.nextval
,x_amb_context_code
,x_application_id
,x_product_rule_type_code
,x_product_rule_code
,x_start_date_active
,x_end_date_active
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
returning acctg_method_rule_id into x_acctg_method_rule_id
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
  ,x_acctg_method_rule_id             IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_start_date_active                IN DATE
  ,x_end_date_active                  IN DATE)

IS

CURSOR c IS
SELECT accounting_method_type_code
      ,accounting_method_code
      ,amb_context_code
      ,application_id
      ,product_rule_type_code
      ,product_rule_code
      ,start_date_active
      ,end_date_active
FROM   xla_acctg_method_rules
WHERE  acctg_method_rule_id                            = x_acctg_method_rule_id
FOR UPDATE OF accounting_method_type_code NOWAIT;

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

IF ( (recinfo.accounting_method_type_code       = x_accounting_method_type_code)
 AND (recinfo.accounting_method_code            = x_accounting_method_code)
 AND (recinfo.application_id                    = x_application_id)
 AND (recinfo.amb_context_code                  = x_amb_context_code)
 AND (recinfo.product_rule_type_code            = x_product_rule_type_code)
 AND (recinfo.product_rule_code                 = x_product_rule_code)
 AND (recinfo.start_date_active                   = x_start_date_active)
 AND ((recinfo.end_date_active            = x_end_date_active)
   OR ((recinfo.end_date_active           IS NULL)
  AND (x_end_date_active              IS NULL)))
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
  ,x_acctg_method_rule_id             IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_start_date_active                IN DATE
  ,x_end_date_active                  IN DATE
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> .update_row'                    ,20);
UPDATE xla_acctg_method_rules
   SET
       product_rule_type_code           = x_product_rule_type_code
      ,product_rule_code                = x_product_rule_code
      ,last_update_date                 = x_last_update_date
      ,start_date_active                = x_start_date_active
      ,end_date_active                  = x_end_date_active
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  acctg_method_rule_id             = x_acctg_method_rule_id;

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
  (x_acctg_method_rule_id      IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> .delete_row'                    ,20);
DELETE FROM xla_acctg_method_rules
WHERE  acctg_method_rule_id             = x_acctg_method_rule_id;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< .delete_row'                    ,20);
END delete_row;

end xla_acctg_method_rules_f_pkg;

/

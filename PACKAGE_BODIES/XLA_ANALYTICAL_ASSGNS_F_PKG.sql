--------------------------------------------------------
--  DDL for Package Body XLA_ANALYTICAL_ASSGNS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ANALYTICAL_ASSGNS_F_PKG" AS
/* $Header: xlatbanc.pkb 120.4 2003/04/03 22:06:18 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_assgns_f_pkg                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_analytical_assgns                     |
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
  ,x_analytical_assignment_id         IN OUT NOCOPY NUMBER
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_anal_criterion_type_code          IN VARCHAR2
  ,x_analytical_criterion_code         IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)
IS

l_analytical_assignment_id    number(38);

CURSOR c IS
SELECT rowid
FROM   xla_analytical_assgns
WHERE  analytical_assignment_id                    = x_analytical_assignment_id
;

BEGIN
xla_utility_pkg.trace('> .insert_row'                    ,20);

INSERT INTO xla_analytical_assgns
(creation_date
,created_by
,application_id
,amb_context_code
,analytical_assignment_id
,product_rule_type_code
,product_rule_code
,entity_code
,event_class_code
,event_type_code
,accounting_line_type_code
,accounting_line_code
,analytical_criterion_type_code
,analytical_criterion_code
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_amb_context_code
,xla_analytical_assgns_s.nextval
,x_product_rule_type_code
,x_product_rule_code
,x_entity_code
,x_event_class_code
,x_event_type_code
,x_accounting_line_type_code
,x_accounting_line_code
,x_anal_criterion_type_code
,x_analytical_criterion_code
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
returning analytical_assignment_id into x_analytical_assignment_id
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
  ,x_analytical_assignment_id         IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_anal_criterion_type_code          IN VARCHAR2
  ,x_analytical_criterion_code         IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,amb_context_code
      ,analytical_assignment_id
      ,product_rule_type_code
      ,product_rule_code
      ,entity_code
      ,event_class_code
      ,event_type_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,analytical_criterion_type_code
      ,analytical_criterion_code
FROM   xla_analytical_assgns
WHERE  analytical_assignment_id                   = x_analytical_assignment_id
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
 AND (recinfo.analytical_criterion_type_code     = x_anal_criterion_type_code)
 AND (recinfo.analytical_criterion_code          = x_analytical_criterion_code)
 AND ((recinfo.accounting_line_type_code        = x_accounting_line_type_code)
   OR ((recinfo.accounting_line_type_code       IS NULL)
  AND (x_accounting_line_type_code              IS NULL)))
 AND ((recinfo.accounting_line_code             = x_accounting_line_code)
   OR ((recinfo.accounting_line_code            IS NULL)
  AND (x_accounting_line_code                   IS NULL)))
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
  ,x_analytical_assignment_id         IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_anal_criterion_type_code          IN VARCHAR2
  ,x_analytical_criterion_code         IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> .update_row'                    ,20);
UPDATE xla_analytical_assgns
   SET
       last_update_date                 = x_last_update_date
      ,analytical_criterion_type_code    = x_anal_criterion_type_code
      ,analytical_criterion_code         = x_analytical_criterion_code
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  analytical_assignment_id         = x_analytical_assignment_id;

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
  (x_analytical_assignment_id      IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> .delete_row'                    ,20);
DELETE FROM xla_analytical_assgns
WHERE  analytical_assignment_id         = x_analytical_assignment_id;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< .delete_row'                    ,20);
END delete_row;

end xla_analytical_assgns_f_pkg;

/

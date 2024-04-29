--------------------------------------------------------
--  DDL for Package Body XLA_AAD_HDR_ACCT_ATTRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_HDR_ACCT_ATTRS_F_PKG" AS
/* $Header: xlatbhaa.pkb 120.0 2004/05/27 20:58:48 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_aad_hdr_acct_attrs_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_aad_hdr_acct_attrs                    |
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_event_class_default_flag         IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_aad_hdr_acct_attrs
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_attribute_code        = x_accounting_attribute_code
;

BEGIN
xla_utility_pkg.trace('> .insert_row'                    ,20);

INSERT INTO xla_aad_hdr_acct_attrs
(creation_date
,created_by
,application_id
,amb_context_code
,product_rule_type_code
,product_rule_code
,event_class_code
,event_type_code
,accounting_attribute_code
,source_application_id
,source_type_code
,source_code
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
,x_event_class_code
,x_event_type_code
,x_accounting_attribute_code
,x_source_application_id
,x_source_type_code
,x_source_code
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_event_class_default_flag         IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,amb_context_code
      ,product_rule_type_code
      ,product_rule_code
      ,event_class_code
      ,event_type_code
      ,accounting_attribute_code
      ,source_application_id
      ,source_type_code
      ,source_code
      ,event_class_default_flag
FROM   xla_aad_hdr_acct_attrs
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_attribute_code        = x_accounting_attribute_code
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
 AND (recinfo.event_class_code                  = x_event_class_code)
 AND (recinfo.event_type_code                   = x_event_type_code)
 AND (recinfo.accounting_attribute_code         = x_accounting_attribute_code)
 AND (recinfo.event_class_default_flag          = x_event_class_default_flag)
 AND ((recinfo.source_application_id            = X_source_application_id)
   OR ((recinfo.source_application_id           IS NULL)
  AND (x_source_application_id                  IS NULL)))
 AND ((recinfo.source_type_code                 = X_source_type_code)
   OR ((recinfo.source_type_code                IS NULL)
  AND (x_source_type_code                       IS NULL)))
 AND ((recinfo.source_code                      = X_source_code)
   OR ((recinfo.source_code                     IS NULL)
  AND (x_source_code                            IS NULL)))

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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_event_class_default_flag         IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)
IS

BEGIN
xla_utility_pkg.trace('> .update_row'                    ,20);
UPDATE xla_aad_hdr_acct_attrs
   SET
       last_update_date                 = x_last_update_date
      ,source_application_id            = x_source_application_id
      ,source_type_code                 = x_source_type_code
      ,source_code                      = x_source_code
      ,event_class_default_flag         = x_event_class_default_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  accounting_attribute_code        = x_accounting_attribute_code;

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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2)

IS

BEGIN
xla_utility_pkg.trace('> .delete_row'                    ,20);
DELETE FROM xla_aad_hdr_acct_attrs
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code          = x_product_rule_type_code
  AND  product_rule_code               = x_product_rule_code
  AND  event_class_code                = x_event_class_code
  AND  event_type_code                 = x_event_type_code
  AND accounting_attribute_code        = x_accounting_attribute_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< .delete_row'                    ,20);
END delete_row;

end xla_aad_hdr_acct_attrs_f_pkg;

/

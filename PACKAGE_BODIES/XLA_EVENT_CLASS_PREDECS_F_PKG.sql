--------------------------------------------------------
--  DDL for Package Body XLA_EVENT_CLASS_PREDECS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENT_CLASS_PREDECS_F_PKG" AS
/* $Header: xlatbecp.pkb 120.1 2005/04/20 20:19:56 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_class_predecs_f_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_event_class_predecs                        |
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_prior_event_class_code           IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_event_class_predecs
WHERE  application_id                   = x_application_id
  AND  event_class_code                 = x_event_class_code
  AND  prior_event_class_code           = x_prior_event_class_code;

BEGIN
xla_utility_pkg.trace('> .insert_row'                    ,20);

INSERT INTO xla_event_class_predecs
(creation_date
,created_by
,application_id
,event_class_code
,prior_event_class_code
,object_version_number
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_event_class_code
,x_prior_event_class_code
,1
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
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_prior_event_class_code           IN VARCHAR2)

IS

BEGIN
xla_utility_pkg.trace('> .delete_row'                    ,20);
DELETE FROM xla_event_class_predecs
WHERE application_id                   = x_application_id
  AND event_class_code                 = x_event_class_code
  AND prior_event_class_code           = x_prior_event_class_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< .delete_row'                    ,20);
END delete_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_prior_event_class_code           IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,event_class_code
      ,prior_event_class_code
FROM   xla_event_class_predecs
WHERE  application_id                   = x_application_id
  AND  event_class_code                 = x_event_class_code
  AND  prior_event_class_code           = x_prior_event_class_code
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
 AND (recinfo.event_class_code                  = x_event_class_code)
 AND (recinfo.prior_event_class_code            = x_prior_event_class_code)
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
|  Procedure load_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE load_row
  (p_application_short_name           IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_prior_event_class_code           IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2)
IS

  l_view_application_id   number(38);
  l_flex_application_id   number(38);
  l_application_id        number(38);
  l_flex_value_set_id     number(38);
  l_rowid                ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  number(38);  -- entity owner in file
  f_ludate                date;        -- entity update date in file
  db_luby                 number(38);  -- entity owner in db
  db_ludate               date;        -- entity update date in db

  CURSOR c_appl
  IS
  SELECT application_id
    FROM fnd_application
   WHERE application_short_name = p_application_short_name;

BEGIN

   OPEN c_appl;
   FETCH c_appl
    INTO l_application_id;
   CLOSE c_appl;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  BEGIN

     SELECT last_updated_by, last_update_date
       INTO db_luby, db_ludate
       FROM xla_event_class_predecs
      WHERE application_id   = l_application_id
        AND event_class_code = p_event_class_code
        AND prior_event_class_code = p_prior_event_class_code;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
       xla_event_class_predecs_f_pkg.insert_row
         (x_rowid                => l_rowid
         ,x_application_id       => l_application_id
         ,x_event_class_code     => p_event_class_code
         ,x_prior_event_class_code  => p_prior_event_class_code
         ,x_creation_date        => f_ludate
         ,x_created_by           => f_luby
         ,x_last_update_date     => f_ludate
         ,x_last_updated_by      => f_luby
         ,x_last_update_login    => 0);

  END;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_event_class_predecs_f_pkg.load_row');

END load_row;

end xla_event_class_predecs_f_pkg;

/

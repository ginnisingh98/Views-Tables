--------------------------------------------------------
--  DDL for Package Body XLA_ACCT_ATTRIBUTES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCT_ATTRIBUTES_F_PKG" AS
/* $Header: xlathess.pkb 120.6.12010000.1 2008/07/29 10:09:32 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acct_attributes                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acct_attributes                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_assignment_required_code         IN VARCHAR2
  ,x_assignment_group_code            IN VARCHAR2
  ,x_datatype_code                    IN VARCHAR2
  ,x_journal_entry_level_code         IN VARCHAR2
  ,x_assignment_extensible_flag       IN VARCHAR2
  ,x_assignment_level_code            IN VARCHAR2
  ,x_inherited_flag                   IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_acct_attributes_b
WHERE  accounting_attribute_code           = x_accounting_attribute_code
;

BEGIN
xla_utility_pkg.trace('> xla_acct_attributes_f_pkg.insert_row'                    ,20);

INSERT INTO xla_acct_attributes_b
(creation_date
,created_by
,accounting_attribute_code
,assignment_required_code
,assignment_group_code
,datatype_code
,journal_entry_level_code
,assignment_extensible_flag
,assignment_level_code
,inherited_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_accounting_attribute_code
,x_assignment_required_code
,x_assignment_group_code
,x_datatype_code
,x_journal_entry_level_code
,x_assignment_extensible_flag
,x_assignment_level_code
,x_inherited_flag
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_acct_attributes_tl
(name
,creation_date
,created_by
,last_update_date
,last_updated_by
,accounting_attribute_code
,last_update_login
,language
,source_lang)
SELECT
       x_name
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_accounting_attribute_code
      ,x_last_update_login
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_acct_attributes_tl               t
       WHERE  t.accounting_attribute_code        = x_accounting_attribute_code
         AND  t.language                         = l.language_code);

OPEN c;
FETCH c INTO x_rowid;

IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c;

xla_utility_pkg.trace('< xla_acct_attributes_f_pkg.insert_row'                    ,20);
END insert_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_accounting_attribute_code        IN VARCHAR2
  ,x_assignment_required_code         IN VARCHAR2
  ,x_assignment_group_code            IN VARCHAR2
  ,x_datatype_code                    IN VARCHAR2
  ,x_journal_entry_level_code         IN VARCHAR2
  ,x_assignment_extensible_flag       IN VARCHAR2
  ,x_assignment_level_code            IN VARCHAR2
  ,x_inherited_flag                   IN VARCHAR2
  ,x_name                             IN VARCHAR2)

IS

CURSOR c IS
SELECT accounting_attribute_code
      ,assignment_required_code
      ,assignment_group_code
      ,datatype_code
      ,journal_entry_level_code
      ,assignment_extensible_flag
      ,assignment_level_code
      ,inherited_flag
FROM   xla_acct_attributes_b
WHERE  accounting_attribute_code           = x_accounting_attribute_code
FOR UPDATE OF accounting_attribute_code NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT language
      ,name
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_acct_attributes_tl
WHERE  accounting_attribute_code        = X_accounting_attribute_code
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF accounting_attribute_code NOWAIT;

BEGIN
xla_utility_pkg.trace('> xla_acct_attributes_f_pkg.lock_row'                      ,20);

OPEN c;
FETCH c INTO recinfo;

IF (c%NOTFOUND) THEN
   CLOSE c;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   app_exception.raise_exception;
END IF;
CLOSE c;

IF ( (recinfo.assignment_required_code            = x_assignment_required_code)
 AND ((recinfo.assignment_group_code               = X_assignment_group_code)
   OR ((recinfo.assignment_group_code               IS NULL)
  AND (x_assignment_group_code               IS NULL)))
 AND (recinfo.datatype_code                    = x_datatype_code)
 AND (recinfo.journal_entry_level_code         = X_journal_entry_level_code)
 AND (recinfo.assignment_extensible_flag                   = x_assignment_extensible_flag)
 AND (recinfo.assignment_level_code         = X_assignment_level_code)
 AND (recinfo.inherited_flag                = X_inherited_flag)
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

FOR tlinfo IN c1 LOOP
   IF (tlinfo.baselang = 'Y') THEN
      IF (    (tlinfo.name = X_name)
      ) THEN
        NULL;
      ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END IF;
END LOOP;


xla_utility_pkg.trace('< xla_acct_attributes_f_pkg.lock_row'                      ,20);
RETURN;

END lock_row;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_row
 (x_accounting_attribute_code           IN VARCHAR2
 ,x_assignment_required_code            IN VARCHAR2
 ,x_assignment_group_code               IN VARCHAR2
 ,x_datatype_code                       IN VARCHAR2
 ,x_journal_entry_level_code            IN VARCHAR2
 ,x_assignment_extensible_flag          IN VARCHAR2
 ,x_assignment_level_code               IN VARCHAR2
 ,x_inherited_flag                      IN VARCHAR2
 ,x_name                                IN VARCHAR2
 ,x_last_update_date                    IN DATE
 ,x_last_updated_by                     IN NUMBER
 ,x_last_update_login                   IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> xla_acct_attributes_f_pkg.update_row'                    ,20);
UPDATE xla_acct_attributes_b
   SET
       last_update_date                 = x_last_update_date
      ,assignment_required_code         = x_assignment_required_code
      ,assignment_group_code            = x_assignment_group_code
      ,datatype_code                    = x_datatype_code
      ,journal_entry_level_code         = x_journal_entry_level_code
      ,assignment_extensible_flag       = x_assignment_extensible_flag
      ,assignment_level_code            = x_assignment_level_code
      ,inherited_flag                   = x_inherited_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  accounting_attribute_code        = X_accounting_attribute_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_acct_attributes_tl
SET
       last_update_date                 = x_last_update_date
      ,name                             = X_name
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  accounting_attribute_code        = X_accounting_attribute_code
  AND  USERENV('LANG')                 IN (language, source_lang);

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< xla_acct_attributes_f_pkg.update_row'                    ,20);
END update_row;

/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_accounting_attribute_code           IN VARCHAR2)

IS

BEGIN
xla_utility_pkg.trace('> xla_acct_attributes_f_pkg.delete_row'                    ,20);
DELETE FROM xla_acct_attributes_tl
WHERE accounting_attribute_code           = x_accounting_attribute_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_acct_attributes_b
WHERE accounting_attribute_code           = x_accounting_attribute_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;


xla_utility_pkg.trace('< xla_acct_attributes_f_pkg.delete_row'                    ,20);
END delete_row;

/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/
PROCEDURE add_language

IS

BEGIN
xla_utility_pkg.trace('> xla_acct_attributes_f_pkg.add_language'                  ,20);

DELETE FROM xla_acct_attributes_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_acct_attributes_b                b
       WHERE  b.accounting_attribute_code           = t.accounting_attribute_code);

UPDATE xla_acct_attributes_tl   t
SET   (name)
   = (SELECT b.name
      FROM   xla_acct_attributes_tl               b
      WHERE  b.accounting_attribute_code        = t.accounting_attribute_code
        AND  b.language                         = t.source_lang)
WHERE (t.accounting_attribute_code
      ,t.language)
    IN (SELECT subt.accounting_attribute_code
              ,subt.language
        FROM   xla_acct_attributes_tl                   subb
              ,xla_acct_attributes_tl                   subt
        WHERE  subb.accounting_attribute_code       = subt.accounting_attribute_code
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
      ))
;

INSERT INTO xla_acct_attributes_tl
(name
,creation_date
,created_by
,last_update_date
,last_updated_by
,accounting_attribute_code
,last_update_login
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.name
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.accounting_attribute_code
      ,b.last_update_login
      ,l.language_code
      ,b.source_lang
FROM   xla_acct_attributes_tl             b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_acct_attributes_tl               t
       WHERE  t.accounting_attribute_code        = b.accounting_attribute_code
         AND  t.language                         = l.language_code);

xla_utility_pkg.trace('< xla_acct_attributes_f_pkg.add_language'                  ,20);
END add_language;

/*======================================================================+
|                                                                       |
|  Procedure load_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE load_row
  (p_accounting_attribute_code        IN VARCHAR2
  ,p_journal_entry_level_code         IN VARCHAR2
  ,p_datatype_code                    IN VARCHAR2
  ,p_assignment_required_code         IN VARCHAR2
  ,p_assignment_group_code            IN VARCHAR2
  ,p_assignment_extensible_flag       IN VARCHAR2
  ,p_assignment_level_code            IN VARCHAR2
  ,p_inherited_flag                   IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS

  l_view_application_id   number(38);
  l_application_id        number(38);
  l_flex_value_set_id     number(38);
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  number(38);  -- entity owner in file
  f_ludate                date;        -- entity update date in file
  db_luby                 number(38);  -- entity owner in db
  db_ludate               date;        -- entity update date in db

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  BEGIN

     SELECT last_updated_by, last_update_date
       INTO db_luby, db_ludate
       FROM xla_acct_attributes_vl
      WHERE accounting_attribute_code      = p_accounting_attribute_code;

     IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, null)) then
        xla_acct_attributes_f_pkg.update_row
          (x_accounting_attribute_code     => p_accounting_attribute_code
          ,x_journal_entry_level_code      => p_journal_entry_level_code
          ,x_datatype_code                 => p_datatype_code
          ,x_assignment_required_code      => p_assignment_required_code
          ,x_assignment_group_code         => p_assignment_group_code
          ,x_assignment_extensible_flag    => p_assignment_extensible_flag
          ,x_assignment_level_code         => p_assignment_level_code
          ,x_inherited_flag                => p_inherited_flag
          ,x_name                          => p_name
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

     END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
       xla_acct_attributes_f_pkg.insert_row
         (x_rowid                             => l_rowid
         ,x_accounting_attribute_code         => p_accounting_attribute_code
         ,x_journal_entry_level_code          => p_journal_entry_level_code
         ,x_datatype_code                     => p_datatype_code
         ,x_assignment_required_code          => p_assignment_required_code
         ,x_assignment_group_code             => p_assignment_group_code
         ,x_assignment_extensible_flag        => p_assignment_extensible_flag
         ,x_assignment_level_code             => p_assignment_level_code
         ,x_inherited_flag                    => p_inherited_flag
         ,x_name                              => p_name
         ,x_creation_date                     => f_ludate
         ,x_created_by                        => f_luby
         ,x_last_update_date                  => f_ludate
         ,x_last_updated_by                   => f_luby
         ,x_last_update_login                 => 0);

  END;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_acct_attributes_f_pkg.load_row');

END load_row;

/*======================================================================+
|                                                                       |
|  Procedure translate_row                                              |
|                                                                       |
+======================================================================*/
PROCEDURE translate_row
  (p_accounting_attribute_code           IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS

  l_view_application_id   number(38);
  l_application_id        number(38);
  l_row_id                ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  number(38);  -- entity owner in file
  f_ludate                date;        -- entity update date in file
  db_luby                 number(38);  -- entity owner in db
  db_ludate               date;        -- entity update date in db

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  BEGIN
     SELECT last_updated_by, last_update_date
       INTO db_luby, db_ludate
       FROM xla_acct_attributes_tl
      WHERE accounting_attribute_code      = p_accounting_attribute_code
        AND language                       = userenv('LANG');

     IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, p_custom_mode)) then
        UPDATE xla_acct_attributes_tl
           SET name                         = p_name
              ,last_update_date             = f_ludate
              ,last_updated_by              = f_luby
              ,last_update_login            = 0
              ,source_lang                  = userenv('LANG')
         WHERE userenv('LANG')              IN (language, source_lang)
           AND accounting_attribute_code    = p_accounting_attribute_code;

     END IF;

  END;


END translate_row;

end xla_acct_attributes_f_PKG;

/

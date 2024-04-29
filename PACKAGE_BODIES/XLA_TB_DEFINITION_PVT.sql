--------------------------------------------------------
--  DDL for Package Body XLA_TB_DEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_DEFINITION_PVT" AS
/* $Header: xlathtbdfn.pkb 120.5.12010000.1 2008/07/29 10:10:42 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_tb_definition_PVT                                                  |
|                                                                            |
| Description                                                                |
|     This is a XLA package, which contains all the logic required           |
|     to maintain trial balance report definitions                           |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     17-AUG-2005 M.Asada    Created                                         |
+===========================================================================*/

C_PACKAGE_NAME      CONSTANT  VARCHAR2(30) := 'xla_tb_definition_PVT';


--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Create trial balance report definitions                                |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Load_Row
        (p_definition_code           IN VARCHAR2
        ,p_object_version_number     IN VARCHAR2
        ,p_name                      IN VARCHAR2
        ,p_description               IN VARCHAR2
        ,p_ledger_short_name         IN vARCHAR2
        ,p_enabled_flag              IN VARCHAR2
        ,p_balance_side_code         IN VARCHAR2
        ,p_defined_by_code           IN VARCHAR2
        ,p_definition_status_code    IN VARCHAR2
        ,p_defn_owner_code           IN VARCHAR2
        ,p_last_update_date          IN VARCHAR2
        ,p_owner                     IN VARCHAR2
        ,p_custom_mode               IN VARCHAR2) IS

   CURSOR c_def IS
      SELECT definition_code
            ,object_version_number
            ,last_updated_by
            ,last_update_date
        FROM xla_tb_definitions_b
       WHERE definition_code = p_definition_code;

   CURSOR c_ledger IS
     SELECT ledger_id
       FROM gl_ledgers
      WHERE short_name = p_ledger_short_name;

   l_ledger_id             INTEGER;
   l_definition_code                 VARCHAR2(30);
   l_last_updated_by                 NUMBER;  -- owner in file
   l_last_update_date                DATE;    -- last update date in file
   l_db_object_version_number        NUMBER;  -- object version number in db
   l_db_last_updated_by              NUMBER;  -- owner in db
   l_db_last_update_date             DATE;    -- last update date in db
   l_rowid                           ROWID;

BEGIN

   l_last_updated_by   := fnd_load_util.owner_id(p_owner);
   l_last_update_date  := NVL(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), SYSDATE);

   OPEN c_ledger;
     FETCH c_ledger
      INTO l_ledger_id;
   CLOSE c_ledger;

   OPEN  c_def;
     FETCH c_def
      INTO l_definition_code
          ,l_db_object_version_number
          ,l_db_last_updated_by
          ,l_db_last_update_date;

   IF (c_def%NOTFOUND) THEN

      l_db_object_version_number := TO_NUMBER(p_object_version_number);

      Insert_Row (
         p_rowid                  => l_rowid
        ,p_definition_code        => p_definition_code
        ,p_object_version_number  => l_db_object_version_number
        ,p_ledger_id              => l_ledger_id
        ,p_enabled_flag           => p_enabled_flag
        ,p_balance_side_code      => p_balance_side_code
        ,p_defined_by_code        => p_defined_by_code
        ,p_definition_status_code => p_definition_status_code
        ,p_name                   => p_name
        ,p_description            => p_description
        ,p_defn_owner_code        => p_defn_owner_code
        ,p_creation_Date          => l_last_update_date
        ,p_Created_By             => l_last_updated_by
        ,p_Last_Update_Date       => l_last_update_date
        ,p_Last_Updated_By        => l_last_updated_by
        ,p_Last_Update_Login      =>  0);

   ELSE
      --
      -- Update columns if allowed (Base)
      --
      IF (fnd_load_util.upload_test(
             p_file_id     => l_last_updated_by
            ,p_file_lud    => l_last_update_date
            ,p_db_id       => l_db_last_updated_by
            ,p_db_lud      => l_db_last_update_date
            ,p_custom_mode => p_custom_mode))
      THEN

         Update_Row (
            p_definition_code        => p_definition_code
           ,p_object_version_number  => l_db_object_version_number
           ,p_ledger_id              => l_ledger_id
           ,p_enabled_flag           => p_enabled_flag
           ,p_balance_side_code      => p_balance_side_code
           ,p_defined_by_code        => p_defined_by_code
           ,p_definition_status_code => p_definition_status_code
           ,p_name                   => p_name
           ,p_description            => p_description
           ,p_defn_owner_code        => p_defn_owner_code
           ,p_last_update_date       => l_last_update_date
           ,p_last_updated_by        => l_last_updated_by
           ,p_last_update_Login      => 0);

      END IF;

   END IF;

   CLOSE c_def;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , C_PACKAGE_NAME || '.' || 'load_row'
     ,'ERROR'       ,  sqlerrm);
END Load_Row;

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Create trial balance report definitions                                |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Insert_Row
        (p_rowid                     IN OUT NOCOPY VARCHAR2
        ,p_definition_code           IN VARCHAR2
        ,p_object_version_number     IN NUMBER
        ,p_ledger_id                 IN NUMBER
        ,p_enabled_flag              IN VARCHAR2
        ,p_balance_side_code         IN VARCHAR2
        ,p_defined_by_code           IN VARCHAR2
        ,p_definition_status_code    IN VARCHAR2
        ,p_name                      IN VARCHAR2
        ,p_description               IN VARCHAR2
        ,p_defn_owner_code           IN VARCHAR2
        ,p_creation_date             IN DATE
        ,p_created_by                IN NUMBER
        ,p_last_update_date          IN DATE
        ,p_last_updated_by           IN NUMBER
        ,p_last_update_login         IN NUMBER) IS


   CURSOR c_tb_b IS
      SELECT rowid
        FROM xla_tb_definitions_b
       WHERE definition_code = p_definition_code;

BEGIN

   IF p_definition_code IS NULL THEN
      RAISE no_data_found;
   END IF;

   INSERT INTO xla_tb_definitions_b
         (
          definition_code
         ,object_version_number
         ,ledger_id
         ,enabled_flag
         ,defined_by_code
         ,balance_side_code
         ,definition_status_code
         ,owner_code
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         )
   VALUES
         (
          p_definition_code
         ,1                               -- Ignore p_object_version_number
         ,p_ledger_id
         ,p_enabled_flag
         ,p_defined_by_code
         ,p_balance_side_code
         ,p_definition_status_code
         ,p_defn_owner_code
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
         );

   INSERT INTO xla_tb_definitions_tl
         (
          definition_code
         ,name
         ,description
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,language
         ,source_lang
         )
   SELECT
          p_definition_code
         ,p_name
         ,p_description
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
         ,l.language_code
         ,userenv('LANG')
     FROM fnd_languages l
    WHERE l.installed_flag in ('I', 'B')
      AND NOT EXISTS
             (SELECT NULL
                FROM xla_tb_definitions_tl t
               WHERE t.definition_code = p_definition_code
                 AND t.language = l.language_code);


   OPEN c_tb_b;
      FETCH c_tb_b INTO p_rowid;

      IF (c_tb_b%notfound) then
         CLOSE c_tb_b;
         RAISE no_data_found;
      END IF;
   CLOSE c_tb_b;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , C_PACKAGE_NAME || '.' || 'insert_row'
     ,'ERROR'       ,  sqlerrm);
END Insert_Row;

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Update trial balance report definitions                                |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Update_Row
        (p_definition_code           IN VARCHAR2
        ,p_object_version_number     IN OUT NOCOPY NUMBER
        ,p_ledger_id                 IN NUMBER
        ,p_enabled_flag              IN VARCHAR2
        ,p_balance_side_code         IN VARCHAR2
        ,p_defined_by_code           IN VARCHAR2
        ,p_definition_status_code    IN VARCHAR2
        ,p_name                      IN VARCHAR2
        ,p_description               IN VARCHAR2
        ,p_defn_owner_code           IN VARCHAR2
        ,p_last_update_date          IN VARCHAR2
        ,p_last_updated_by           IN VARCHAR2
        ,p_last_update_login         IN VARCHAR2) IS

   l_object_version_number           NUMBER;


BEGIN

   --
   --  If -1 is passed, this API update existing record without
   --  comparing object_version_number pased to th API
   --  (cf. Datamodel Standard)
   --
   IF p_object_version_number = -1 THEN

      --
      -- Allow update.  Increment the database's OVN by 1
      --
      SELECT object_version_number
        INTO l_object_version_number
        FROM xla_tb_definitions_b
       WHERE definition_code = p_definition_code;

       l_object_version_number := l_object_version_number + 1;

   ELSE

      --
      -- Lock the row.  Allow update only if the database's OVN equals the one
      -- passed in.
      --
      -- If update is allowed, increment the database's OVN by 1.
      -- Otherwise, raise an error.
      --

      SELECT object_version_number
        INTO l_object_version_number
        FROM xla_tb_definitions_b
       WHERE definition_code = p_definition_code
         FOR UPDATE;

      IF (l_object_version_number = p_object_version_number) THEN

         l_object_version_number := l_object_version_number + 1;

      ELSE

         --
         -- record already updated
         --
         fnd_message.set_name('XLA','XLA_COMMON_ROW_UPDATED');
         xla_exceptions_pkg.raise_exception;

      END IF;

   END IF;

   UPDATE xla_tb_definitions_b
      SET object_version_number  = l_object_version_number
         ,ledger_id              = p_ledger_id
         ,enabled_flag           = p_enabled_flag
         ,balance_side_code      = p_balance_side_code
         ,defined_by_code        = p_defined_by_code
         ,definition_status_code = p_definition_status_code
         ,owner_code             = p_defn_owner_code
         ,last_update_date       = p_last_update_date
         ,last_updated_by        = p_last_updated_by
         ,last_update_login      = p_last_update_login
    WHERE definition_code        = p_definition_code;

   IF (sql%NOTFOUND) THEN
      RAISE no_data_found;
   END IF;

   UPDATE xla_tb_definitions_tl
      SET name                   = p_name
         ,description            = p_description
         ,last_update_date       = p_last_update_date
         ,last_updated_by        = p_last_updated_by
         ,last_update_login      = p_last_update_login
         ,source_lang            = userenv('LANG')
    WHERE definition_code        = p_definition_code
      AND userenv('LANG')        IN (language, source_lang);

   IF (sql%notfound) THEN
      RAISE no_data_found;
   END IF;

   p_object_version_number := l_object_version_number;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , C_PACKAGE_NAME || '.' || 'update_row'
     ,'ERROR'       ,  sqlerrm);
END Update_Row;

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Delete trial balance report definitions                                |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
        (p_definition_code           IN VARCHAR2) IS
BEGIN

   DELETE FROM xla_tb_defn_details
    WHERE definition_code = p_definition_code;

   DELETE FROM xla_tb_definitions_tl
    WHERE definition_code = p_definition_code;

   IF SQL%NOTFOUND then
      RAISE no_data_found;
   END IF;

   DELETE FROM xla_tb_definitions_b
    WHERE definition_code = p_definition_code;

   IF (sql%notfound) then
      RAISE no_data_found;
   END IF;

   drop_partition
     (p_definition_code => p_definition_code);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , C_PACKAGE_NAME || '.' || 'delete_row'
     ,'ERROR'       ,  sqlerrm);
END Delete_Row;

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Add language rows                                                      |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Add_Language IS


BEGIN

   DELETE FROM  xla_tb_definitions_tl t
    WHERE NOT EXISTS
             (SELECT NULL
                FROM xla_tb_definitions_b b
               WHERE b.definition_code = t.definition_code
             );

   UPDATE xla_tb_definitions_tl t
      SET (
           NAME
          ,description
          ) =
          (
           SELECT b.NAME
                 ,b.description
             FROM xla_tb_definitions_tl b
            WHERE b.definition_code = t.definition_code
              AND b.language = t.source_lang)
    WHERE (
           t.definition_code
          ,t.language
           ) IN (SELECT subt.definition_code
                       ,subt.language
                   FROM xla_tb_definitions_tl subb
                       ,xla_tb_definitions_tl subt
                  WHERE subb.definition_code = subt.definition_code
                    AND subb.language = subt.source_lang
                    AND (subb.NAME <> subt.NAME
                     OR subb.description <> subt.description
                     OR (subb.description IS NULL AND subt.description IS NOT NULL)
                     OR (subb.description IS NOT NULL AND subt.description IS NULL)
                        )
                );

   INSERT INTO xla_tb_definitions_tl
         (
          definition_code
         ,name
         ,description
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,language
         ,source_lang
         )
   SELECT /*+ ORDERED */
          b.definition_code
         ,b.name
         ,b.description
         ,b.creation_date
         ,b.created_by
         ,b.last_update_date
         ,b.last_updated_by
         ,b.last_update_login
         ,l.language_code
         ,b.source_lang
     FROM xla_tb_definitions_tl b, fnd_languages l
    WHERE l.installed_flag IN ('I', 'B')
      AND b.language = userenv('LANG')
      AND NOT EXISTS
             (SELECT NULL
                FROM xla_tb_definitions_tl t
               WHERE t.definition_code = b.definition_code
                 AND t.language = l.language_code);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , C_PACKAGE_NAME || '.' || 'add_language'
     ,'ERROR'       ,  sqlerrm);
END Add_Language;


--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Update translateable attributes of trial balance report definitions    |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Translate_Row
        (p_definition_code           IN VARCHAR2
        ,p_name                      IN VARCHAR2
        ,p_description               IN VARCHAR2
        ,p_last_update_date          IN NUMBER
        ,p_owner                     IN VARCHAR2
        ,p_custom_mode               IN VARCHAR2) IS

   CURSOR c_tl IS
      SELECT last_updated_by
            ,last_update_date
        FROM xla_tb_definitions_tl
       WHERE definition_code = p_definition_code
         AND LANGUAGE  = userenv('LANG');

   l_definition_code                 VARCHAR2(30);
   l_last_updated_by                 NUMBER;  -- owner in file
   l_last_update_date                DATE;    -- last update date in file
   l_db_last_updated_by              NUMBER;  -- owner in db
   l_db_last_update_date             DATE;    -- last update date in db

BEGIN
   l_last_updated_by   := fnd_load_util.owner_id(p_owner);
   l_last_update_date  := NVL(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), SYSDATE);

   OPEN  c_tl;
     FETCH c_tl
      INTO l_db_last_updated_by
          ,l_db_last_update_date;

   IF (c_tl%NOTFOUND) THEN
      NULL;
   ELSE

      IF fnd_load_util.upload_test(
            p_file_id     => l_last_updated_by
           ,p_file_lud    => l_last_update_date
           ,p_db_id       => l_db_last_updated_by
           ,p_db_lud      => l_db_last_update_date
           ,p_custom_mode => p_custom_mode)
      THEN
         UPDATE xla_tb_definitions_tl
            SET name              = p_name
               ,description       = p_description
               ,last_updated_by   = l_last_updated_by
               ,last_update_date  = l_last_update_date
               ,last_update_login = 0
               ,source_lang       = userenv('LANG')
          WHERE definition_code   = p_definition_code
            AND userenv('LANG')   IN (language, source_lang);

      END IF;

   END IF;


END Translate_Row;

PROCEDURE Drop_Partition
        (p_definition_code           IN VARCHAR2) IS

   l_schema     VARCHAR2(30);
   l_status     VARCHAR2(30);
   l_industry   VARCHAR2(30);
BEGIN

   IF (FND_INSTALLATION.get_app_info
                       (application_short_name   => 'XLA'
                       ,status                   => l_status
                       ,industry                 => l_industry
                       ,oracle_schema            => l_schema))
   THEN

      l_schema := l_schema || '.';

   ELSE

      l_schema := '';

   END IF;

   EXECUTE IMMEDIATE 'ALTER TABLE '||l_schema ||'xla_trial_balance drop partition '
                                   ||p_definition_code;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    , C_PACKAGE_NAME || '.' || 'drop_partition'
     ,'ERROR'       ,  sqlerrm);
END Drop_Partition;


END XLA_TB_DEFINITION_PVT; -- end of package spec

/

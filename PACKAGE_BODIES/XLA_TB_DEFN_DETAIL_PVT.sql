--------------------------------------------------------
--  DDL for Package Body XLA_TB_DEFN_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_DEFN_DETAIL_PVT" AS
/* $Header: xlathtbdtl.pkb 120.0 2005/10/07 12:12:37 svjoshi noship $   */
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

C_PACKAGE_NAME      CONSTANT  VARCHAR2(30) := 'xla_tb_defn_detail_PVT';

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
        ,p_object_version_number     IN NUMBER
        ,p_code_combination_id       IN NUMBER
        ,p_flexfield_segment_code    IN VARCHAR2
        ,p_segment_value_from        IN VARCHAR2
        ,p_segment_value_to          IN VARCHAR2
        ,p_last_update_date          IN VARCHAR2
        ,p_owner                     IN VARCHAR2
        ,p_custom_mode               IN VARCHAR2) IS

   CURSOR c_def IS
      SELECT definition_code
            ,object_version_number
            ,defined_by_code
            ,last_updated_by
            ,last_update_date
        FROM xla_tb_definitions_b
       WHERE definition_code = p_definition_code;

   CURSOR c_detail_f IS
      SELECT 'Y'
        FROM xla_tb_defn_details
       WHERE definition_code     = p_definition_code
         AND code_combination_id = p_code_combination_id;

   CURSOR c_detail_s IS
      SELECT 'Y'
        FROM xla_tb_defn_details
       WHERE definition_code     = p_definition_code
         AND code_combination_id = p_segment_value_to;


   l_definition_code                 VARCHAR2(30);
   l_defined_by_code                 VARCHAR2(30);
   l_last_updated_by                 NUMBER;  -- owner in file
   l_last_update_date                DATE;    -- last update date in file
   l_db_object_version_number        NUMBER;  -- object version number in db
   l_db_last_updated_by              NUMBER;  -- owner in db
   l_db_last_update_date             DATE;    -- last update date in db
   l_rowid                           ROWID;
   l_dummy                           VARCHAR2(1);

BEGIN

   l_last_updated_by   := fnd_load_util.owner_id(p_owner);
   l_last_update_date  := NVL(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), SYSDATE);

   OPEN  c_def;
     FETCH c_def
      INTO l_definition_code
          ,l_db_object_version_number
          ,l_defined_by_code
          ,l_db_last_updated_by
          ,l_db_last_update_date;

   IF l_defined_by_code = 'FLEXFIELD' THEN

      OPEN c_detail_f;
         FETCH c_detail_f
          INTO l_dummy;

      IF (c_detail_f%NOTFOUND) THEN

         Insert_Row (
            p_rowid                  => l_rowid
           ,p_definition_code        => p_definition_code
           ,p_object_version_number  => l_db_object_version_number
           ,p_code_combination_id    => p_code_combination_id
           ,p_flexfield_segment_code => p_flexfield_segment_code
           ,p_segment_value_from     => p_segment_value_from
           ,p_segment_value_to       => p_segment_value_to
           ,p_creation_Date          => l_last_update_date
           ,p_Created_By             => l_last_updated_by
           ,p_Last_Update_Date       => l_last_update_date
           ,p_Last_Updated_By        => l_last_updated_by
           ,p_Last_Update_Login      =>  0);

       END IF;

       CLOSE c_detail_f;

   ELSIF l_defined_by_code = 'SEGMENT' THEN

      OPEN c_detail_s;
         FETCH c_detail_s
          INTO l_dummy;


      IF (c_detail_s%NOTFOUND) THEN

         Insert_Row (
            p_rowid                  => l_rowid
           ,p_definition_code        => p_definition_code
           ,p_object_version_number  => l_db_object_version_number
           ,p_code_combination_id    => p_code_combination_id
           ,p_flexfield_segment_code => p_flexfield_segment_code
           ,p_segment_value_from     => p_segment_value_from
           ,p_segment_value_to       => p_segment_value_to
           ,p_creation_Date          => l_last_update_date
           ,p_Created_By             => l_last_updated_by
           ,p_Last_Update_Date       => l_last_update_date
           ,p_Last_Updated_By        => l_last_updated_by
           ,p_Last_Update_Login      =>  0);

      ELSE

         --
         -- Recreate rows if allowed (segment_value_to might be updated by customers)
         --
         IF (fnd_load_util.upload_test(
                p_file_id     => l_last_updated_by
               ,p_file_lud    => l_last_update_date
               ,p_db_id       => l_db_last_updated_by
               ,p_db_lud      => l_db_last_update_date
               ,p_custom_mode => p_custom_mode))
         THEN

            BEGIN

               Delete_Row
                 (p_definition_code         => p_definition_code
                 ,p_flexfield_segment_code  => p_flexfield_segment_code
                 ,p_segment_value_from      => p_segment_value_from);

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            END ;

               Insert_Row (
                  p_rowid                  => l_rowid
                 ,p_definition_code        => p_definition_code
                 ,p_object_version_number  => l_db_object_version_number
                 ,p_code_combination_id    => p_code_combination_id
                 ,p_flexfield_segment_code => p_flexfield_segment_code
                 ,p_segment_value_from     => p_segment_value_from
                 ,p_segment_value_to       => p_segment_value_to
                 ,p_creation_Date          => l_last_update_date
                 ,p_Created_By             => l_last_updated_by
                 ,p_last_update_date       => l_last_update_date
                 ,p_last_updated_by        => l_last_updated_by
                 ,p_last_update_login      =>  0);

            END IF;

      END IF;

      CLOSE c_detail_s;

   END IF;

   CLOSE c_def;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    ,  C_PACKAGE_NAME || '.' || 'load_row'
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
        ,p_code_combination_id       IN NUMBER
        ,p_flexfield_segment_code    IN VARCHAR2
        ,p_segment_value_from        IN VARCHAR2
        ,p_segment_value_to          IN VARCHAR2
        ,p_creation_date             IN DATE
        ,p_created_by                IN NUMBER
        ,p_last_update_date          IN DATE
        ,p_last_updated_by           IN NUMBER
        ,p_last_update_login         IN NUMBER) IS

   CURSOR c_def IS
      SELECT defined_by_code
        FROM xla_tb_definitions_b
       WHERE definition_code = p_definition_code;

   l_defined_by_code         VARCHAR2(30);

   l_code_combination_id     NUMBER(15);
   l_flexfield_segment_code  VARCHAR2(30);
   l_segment_value_from      VARCHAR2(25);
   l_segment_value_to        VARCHAR2(25);

BEGIN

   IF p_definition_code IS NULL THEN
      RAISE no_data_found;
   END IF;


   OPEN  c_def;
      FETCH c_def
       INTO l_defined_by_code;

   IF l_defined_by_code = 'FLEXFIELD' THEN

      l_code_combination_id    := p_code_combination_id;
      l_flexfield_segment_code := NULL;
      l_segment_value_from     := NULL;
      l_segment_value_to       := NULL;

   ELSIF l_defined_by_code = 'SEGMENT' THEN

      l_code_combination_id    := NULL;
      l_flexfield_segment_code := p_flexfield_segment_code;
      l_segment_value_from     := p_segment_value_from;
      l_segment_value_to       := p_segment_value_to;

   END IF;

   INSERT INTO xla_tb_defn_details
         (
          definition_detail_id
         ,object_version_number
         ,definition_code
         ,flexfield_segment_code
         ,segment_value_from
         ,segment_value_to
         ,code_combination_id
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         )
   VALUES
         (
          xla_tb_defn_details_s.nextval
         ,1                                 -- Ignore p_object_version_number
         ,p_definition_code
         ,l_flexfield_segment_code
         ,l_segment_value_from
         ,l_segment_value_to
         ,l_code_combination_id
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
         )
  RETURNING rowid INTO p_rowid;

  CLOSE c_def;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
     ('XLA'         , 'XLA_COMMON_FAILURE'
     ,'LOCATION'    ,  C_PACKAGE_NAME || '.' || 'insert_row'
     ,'ERROR'       ,  sqlerrm);
END Insert_Row;

--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Update trial balance report definition details                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
-- No Update API for this table. Delete and recreate rows.
--

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Delete trial balance report definitions                                |
--|   (Define by Flexfield)                                                  |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
        (p_definition_code           IN VARCHAR2
        ,p_code_combination_id       IN NUMBER) IS
BEGIN

   DELETE FROM xla_tb_defn_details
    WHERE definition_code     = p_definition_code
      AND code_combination_id = p_code_combination_id;

   IF SQL%NOTFOUND then
      RAISE no_data_found;
   END IF;

END Delete_Row;

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Delete trial balance report definitions                                |
--|   (Defined by Segment)                                                   |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
         (p_definition_code           IN VARCHAR2
         ,p_flexfield_segment_code    IN VARCHAR2
         ,p_segment_value_from        IN VARCHAR2) IS
BEGIN

   DELETE FROM xla_tb_defn_details
    WHERE definition_code        = p_definition_code
      AND flexfield_segment_code = p_flexfield_segment_code
      AND segment_value_from     = p_segment_value_from;

   IF SQL%NOTFOUND then
      RAISE no_data_found;
   END IF;

END Delete_Row;

END XLA_TB_DEFN_DETAIL_PVT; -- end of package spec

/

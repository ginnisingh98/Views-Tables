--------------------------------------------------------
--  DDL for Package Body XLA_TB_DEFN_JE_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TB_DEFN_JE_SOURCES_PVT" AS
/* $Header: xlathtbsrc.pkb 120.0 2005/10/07 12:18:41 svjoshi noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|      xla_tb_defn_je_sources_PVT                                            |
|                                                                            |
| Description                                                                |
|     This is a XLA package, which contains all the logic required           |
|     to maintain trial balance report definitions                           |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     17-AUG-2005 M.Asada    Created                                         |
+===========================================================================*/

C_PACKAGE_NAME      CONSTANT  VARCHAR2(30) := 'xla_tb_defn_je_sources_PVT';


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
        ,p_je_source_name            IN VARCHAR2
        ,p_creation_date             IN DATE
        ,p_created_by                IN NUMBER
        ,p_last_update_date          IN DATE
        ,p_last_updated_by           IN NUMBER
        ,p_last_update_login         IN NUMBER) IS

BEGIN

   IF p_definition_code IS NULL THEN
      RAISE no_data_found;
   END IF;


   INSERT INTO xla_tb_defn_je_sources
         (
          definition_code
         ,object_version_number
         ,je_source_name
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         )
   VALUES
         (
          p_definition_code
         ,1                                 -- Ignore p_object_version_number
         ,p_je_source_name
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
         )
  RETURNING rowid INTO p_rowid;


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
--|   Update trial balance JE source                                         |
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
--|   Delete trial balance JE source                                         |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
        (p_definition_code           IN VARCHAR2
        ,p_je_source_name            IN VARCHAR2) IS
BEGIN

   DELETE FROM xla_tb_defn_je_sources
    WHERE definition_code     = p_definition_code
      AND je_source_name      = p_je_source_name;

   IF SQL%NOTFOUND then
      RAISE no_data_found;
   END IF;

END Delete_Row;

--
--

END XLA_TB_DEFN_JE_SOURCES_PVT ; -- end of package spec

/

--------------------------------------------------------
--  DDL for Package Body XLA_GL_LEDGERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_GL_LEDGERS_PVT" AS
/* $Header: xlathtbled.pkb 120.0 2005/10/07 12:16:28 svjoshi noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|      xla_gl_ledgers_pvt                                                    |
|                                                                            |
| Description                                                                |
|     This is a XLA package, which contains all the logic required           |
|     to maintain ledger level options.                                      |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     07-Oct-2005 M.Asada    Created                                         |
+===========================================================================*/

C_PACKAGE_NAME      CONSTANT  VARCHAR2(30) := 'xla_gl_ledgers_pvt';


--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Create trial balance ledger options                                    |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Insert_Row
        (p_rowid                     IN OUT NOCOPY VARCHAR2
        ,p_ledger_id                 IN NUMBER
        ,p_object_version_number     IN NUMBER
        ,p_work_unit                 IN NUMBER
        ,p_num_of_workers            IN NUMBER
        ,p_creation_date             IN DATE
        ,p_created_by                IN NUMBER
        ,p_last_update_date          IN DATE
        ,p_last_updated_by           IN NUMBER
        ,p_last_update_login         IN NUMBER) IS

BEGIN

   IF p_ledger_id IS NULL THEN
      RAISE no_data_found;
   END IF;


   INSERT INTO xla_gl_ledgers
         (
          ledger_id
         ,object_version_number
         ,work_unit
         ,num_of_workers
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         )
   VALUES
         (
          p_ledger_id
         ,1                                 -- Ignore p_object_version_number
         ,p_work_unit
         ,p_num_of_workers
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
--|   Update trial balance ledger options                                    |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--

PROCEDURE Update_Row
        (p_ledger_id                 IN NUMBER
        ,p_object_version_number     IN OUT NOCOPY NUMBER
        ,p_work_unit                 IN NUMBER
        ,p_num_of_workers            IN NUMBER
        ,p_last_update_date          IN VARCHAR2
        ,p_last_updated_by           IN VARCHAR2
        ,p_last_update_login         IN VARCHAR2) IS

   l_object_version_number           NUMBER;


BEGIN

   --
   --  If -1 is passed, this API update existing record without
   --  comparing object_version_number pased to THEN API
   --  (cf. Datamodel Standard)
   --
   IF p_object_version_number = -1 THEN

      --
      -- Allow update.  Increment the database's OVN by 1
      --
      SELECT object_version_number
        INTO l_object_version_number
        FROM xla_gl_ledgers
       WHERE ledger_id = p_ledger_id;

       l_object_version_number := l_object_version_number + 1;

   ELSE

      --
      -- Lock the row.  Allow update only if the database's OVN equals the on
      -- passed in.
      --
      -- If update is allowed, increment the database's OVN by 1.
      -- Otherwise, raise an error.
      --

      SELECT object_version_number
        INTO l_object_version_number
        FROM xla_gl_ledgers
       WHERE ledger_id = p_ledger_id
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

   UPDATE xla_gl_ledgers
      SET object_version_number  = l_object_version_number
         ,work_unit              = p_work_unit
         ,num_of_workers         = p_num_of_workers
         ,last_update_date       = p_last_update_date
         ,last_updated_by        = p_last_updated_by
         ,last_update_login      = p_last_update_login
    WHERE ledger_id              = p_ledger_id;

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
--|   Delete ledger level options                                            |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
        (p_ledger_id                 IN NUMBER
        ) IS
BEGIN

   DELETE FROM xla_gl_ledgers
    WHERE ledger_id = p_ledger_id;

   IF SQL%NOTFOUND then
      RAISE no_data_found;
   END IF;

END Delete_Row;

--
--

END xla_gl_ledgers_pvt; -- end of package spec

/

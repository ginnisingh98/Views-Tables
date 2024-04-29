--------------------------------------------------------
--  DDL for Package XLA_GL_LEDGERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_GL_LEDGERS_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathtbled.pkh 120.0 2005/10/07 12:17:01 svjoshi noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_gl_ledgers_pvt                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|     This is a XLA package, which contains all the logic required           |
|     to maintain ledger level options.                                      |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     07-Oct-2005 M.Asada    Created                                         |
|                                                                            |
+===========================================================================*/

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
        ,p_last_update_login         IN NUMBER);
--
--
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
--
PROCEDURE Update_Row
        (p_ledger_id                 IN NUMBER
        ,p_object_version_number     IN OUT NOCOPY NUMBER
        ,p_work_unit                 IN NUMBER
        ,p_num_of_workers            IN NUMBER
        ,p_last_update_date          IN VARCHAR2
        ,p_last_updated_by           IN VARCHAR2
        ,p_last_update_login         IN VARCHAR2);

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Delete ledger level options
--|                                                                          |
--+==========================================================================+
--
--

PROCEDURE Delete_Row
        (p_ledger_id                 IN NUMBER
        );

END xla_gl_ledgers_pvt; -- end of package spec

 

/

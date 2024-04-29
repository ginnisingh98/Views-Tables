--------------------------------------------------------
--  DDL for Package XLA_TB_DEFN_JE_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_DEFN_JE_SOURCES_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathtbsrc.pkh 120.0 2005/10/07 12:18:49 svjoshi noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_tb_defn_je_sources_PVT                                             |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA package, which contains all the logic required           |
|     to maintain trial balance JE sources                                   |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     17-AUG-2005 M.Asada    Created                                         |
+===========================================================================*/

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Create trial balance report JE Sources                                 |
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
        ,p_last_update_login         IN NUMBER);

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Update trial balance report JE sources                                 |
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
--|   Delete trial balance report definition details                         |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
         (p_definition_code           IN VARCHAR2
         ,p_je_source_name            IN VARCHAR2);


END XLA_TB_DEFN_JE_SOURCES_PVT ; -- end of package spec

 

/

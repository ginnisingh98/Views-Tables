--------------------------------------------------------
--  DDL for Package XLA_TB_DEFN_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_DEFN_DETAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathtbdtl.pkh 120.0 2005/10/07 12:12:45 svjoshi noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_tb_definition_PVT                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA package, which contains all the logic required           |
|     to maintain trial balance report definitions                           |
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
--|   Create a trial balance report definition if not exist.                 |
--|   If exists, update attributes of the definition.                        |
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
        ,p_custom_mode               IN VARCHAR2);

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Create trial balance report definition details                         |
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
        ,p_last_update_login         IN NUMBER);

--
--
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
--|   Delete trial balance report definition details                         |
--|   (Defined by Flexfield)                                                 |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
         (p_definition_code           IN VARCHAR2
         ,p_code_combination_id       IN NUMBER);

--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Delete trial balance report definition details                         |
--|   (Defined by Segment)                                                 |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Delete_Row
         (p_definition_code           IN VARCHAR2
         ,p_flexfield_segment_code    IN VARCHAR2
         ,p_segment_value_from        IN VARCHAR2);

END XLA_TB_DEFN_DETAIL_PVT; -- end of package spec

 

/

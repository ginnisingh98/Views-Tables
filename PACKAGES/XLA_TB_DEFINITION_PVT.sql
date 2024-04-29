--------------------------------------------------------
--  DDL for Package XLA_TB_DEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_DEFINITION_PVT" AUTHID CURRENT_USER AS
/* $Header: xlathtbdfn.pkh 120.4 2006/02/23 11:03:45 vkasina noship $   */
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
        ,p_object_version_number     IN VARCHAR2
        ,p_name                      IN VARCHAR2
        ,p_description               IN VARCHAR2
        ,p_ledger_short_name         IN VARCHAR2
        ,p_enabled_flag              IN VARCHAR2
        ,p_balance_side_code         IN VARCHAR2
        ,p_defined_by_code           IN VARCHAR2
        ,p_definition_status_code    IN VARCHAR2
        ,p_defn_owner_code           IN VARCHAR2
        ,p_last_update_date          IN VARCHAR2
        ,p_owner                     IN VARCHAR2
        ,p_custom_mode               IN VARCHAR2);

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
        ,p_last_update_login         IN NUMBER);

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
        ,p_last_update_login         IN VARCHAR2);

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
        (p_definition_code           IN VARCHAR2);

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
PROCEDURE Add_Language;

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
        ,p_custom_mode               IN VARCHAR2);


--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC PROCEDURE                                                         |
--|                                                                          |
--|   Drop a partition for a given report definition                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE Drop_Partition
        (p_definition_code           IN VARCHAR2);

END XLA_TB_DEFINITION_PVT; -- end of package spec

 

/

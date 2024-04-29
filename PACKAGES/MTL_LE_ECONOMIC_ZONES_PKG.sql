--------------------------------------------------------
--  DDL for Package MTL_LE_ECONOMIC_ZONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_LE_ECONOMIC_ZONES_PKG" AUTHID CURRENT_USER AS
-- $Header: INVGLEZS.pls 115.2 99/07/16 10:51:29 porting ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     <filename.pls>                                                    |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     add description here                                              |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     add list of procedures and functions here in order of             |
--|     declaration                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     MM/DD/YY <Author>        Created                                  |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Insert_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Insert_Row
( p_rowid           IN OUT  VARCHAR2
, p_legal_entity_id         NUMBER
, p_zone_code               VARCHAR2
, p_last_update_date        DATE
, p_last_updated_by         NUMBER
, p_last_update_login       NUMBER
, p_created_by              NUMBER
, p_creation_date           DATE
);


--========================================================================
-- PROCEDURE : Lock_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Lock_Row
( p_rowid           IN  VARCHAR2
, p_legal_entity_id     NUMBER
, p_zone_code           VARCHAR2
);


--========================================================================
-- PROCEDURE : Update_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Update_Row
( p_rowid           IN  VARCHAR2
, p_legal_entity_id     NUMBER
, p_zone_code           VARCHAR2
, p_last_update_date    DATE
, p_last_updated_by     NUMBER
, p_last_update_login   NUMBER
, p_created_by          NUMBER
, p_creation_date       DATE
);


--========================================================================
-- PROCEDURE : Delete_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Delete_Row
( p_rowid IN  VARCHAR2
);


END MTL_LE_ECONOMIC_ZONES_PKG;

 

/

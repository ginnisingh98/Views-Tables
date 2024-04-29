--------------------------------------------------------
--  DDL for Package MTL_ECONOMIC_ZONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ECONOMIC_ZONES_PKG" AUTHID CURRENT_USER AS
-- $Header: INVGEZNS.pls 115.5 2002/12/03 21:44:48 vma ship $
--+=======================================================================+
--|            Copyright (c) 1998,1999 Oracle Corporation                 |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGEZNS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting row, updateing |
--|     row, locking row and deleting row on tables MTL_ECONOMIC_ZONES and|
--|     MTL_ECONOMIC_ZONES_TL                                             |
--|                                                                       |
--| HISTORY                                                               |
--|     12/17/98 yawang       Created                                     |
--|     07/06/99 pjuvara      added translate_row, uplaod_row             |
--|     11/26/02 vma          added NOCOPY to x_rowid of Insert_Row to    |
--|                           comply with new PL/SQL standard for better  |
--|                           performance                                 |
--|                                                                       |
--+======================================================================*/

--==================
--PUBLIC PROCEDURE
--==================
--========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data to table mtl_economic_zones
--            _b and table mtl_economic_zones_tl
--========================================================================
PROCEDURE Insert_Row
( x_rowid 	      IN OUT NOCOPY VARCHAR2
, p_zone_code 	      IN     VARCHAR2
, p_zone_display_name IN     VARCHAR2
, p_zone_description  IN     VARCHAR2
, p_creation_date     IN     DATE
, p_created_by        IN     NUMBER
, p_last_update_date  IN     DATE
, p_last_updated_by   IN     NUMBER
, p_last_update_login IN     NUMBER
);

--========================================================================
--PRECEDURE : Lock_Row		        Public
--PARAMETERS: see below
--COMMENT   : table handler for locking table mtl_economic_zones_b and
--            table mtl_economic_zones_tl
--========================================================================
PROCEDURE Lock_Row
( p_zone_code         IN VARCHAR2
, p_zone_display_name IN VARCHAR2
, p_zone_description  IN VARCHAR2
);

--========================================================================
--PRECEDURE : Update_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for updating data to table mtl_economic_zones
--            _b and table mtl_economic_zones_tl
--========================================================================
PROCEDURE Update_Row
( p_zone_code         IN VARCHAR2
, p_zone_display_name IN VARCHAR2
, p_zone_description  IN VARCHAR2
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
);

--========================================================================
--PRECEDURE : Delete_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for deleting data from table mtl_economic_zones
--            _b and table mtl_economic_zones_tl
--========================================================================
PROCEDURE Delete_Row
( p_zone_code IN VARCHAR2
);

--========================================================================
--PRECEDURE : Add_Language		Public
--PARAMETERS: none
--COMMENT   : Called by NLADD script whenever a new language is added or
--            after any other operation
--========================================================================
PROCEDURE Add_Language;
--
--========================================================================
-- PROCEDURE : Translate_Row       PUBLIC
-- PARAMETERS: p_zone_code         economic zone code (develper's key)
--             p_zone_display_name economic zone name
--             p_zone_description  description
--             p_owner             user owning the row (SEED or other)
-- COMMENT   : used to upload seed data in NLS mode
--========================================================================
PROCEDURE Translate_Row
( p_zone_code         IN  VARCHAR2
, p_zone_display_name IN  VARCHAR2
, p_zone_description  IN  VARCHAR2
, p_owner             IN  VARCHAR2
);

--========================================================================
-- PRECEDURE : Load_Row		         PUBLIC
-- PARAMETERS: p_zone_code         economic zone code (develper's key)
--             p_owner             user owning the row (SEED or other)
--             p_zone_display_name economic zone name
--             p_zone_description  description
-- COMMENT   : used to upload seed data in MLS mode
--========================================================================
PROCEDURE Load_Row
( p_zone_code 	      IN  VARCHAR2
, p_owner             IN  VARCHAR2
, p_zone_display_name IN  VARCHAR2
, p_zone_description  IN  VARCHAR2
);

END MTL_ECONOMIC_ZONES_PKG;

 

/

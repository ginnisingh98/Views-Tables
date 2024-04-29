--------------------------------------------------------
--  DDL for Package MTL_COUNTRY_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_COUNTRY_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: INVGCTRS.pls 115.4 2002/12/03 21:36:17 vma ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGCTRS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting row, updateing |
--|     row, locking row and deleting row on tables MTL_COUNTRY_ASSIGNMENTS|
--|                                                                       |
--| HISTORY                                                               |
--|     12/18/98 yawang      Created                                      |
--|     11/22/02 vma         Added NOCOPY to IN OUT parameter of          |
--|                          to improve performance.                      |
--|                                                                       |
--+======================================================================*/

--==================
--PUBLIC PROCEDURE
--==================
--========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data to table mtl_country_
--            assignments
--========================================================================
PROCEDURE Insert_Row
( x_rowid                IN OUT NOCOPY VARCHAR2
, p_zone_code            IN     VARCHAR2
, p_territory_code       IN     VARCHAR2
, p_territory_short_name IN     VARCHAR2
, p_start_date           IN     DATE
, p_end_date             IN     DATE
, p_creation_date        IN     DATE
, p_created_by           IN     NUMBER
, p_last_update_date     IN     DATE
, p_last_updated_by      IN     NUMBER
, p_last_update_login    IN     NUMBER
);

--========================================================================
--PRECEDURE : Lock_Row		        Public
--PARAMETERS: see below
--COMMENT   : table handler for locking table mtl_country_assignments
--========================================================================
PROCEDURE Lock_Row
( p_rowid          IN VARCHAR2
, p_zone_code      IN VARCHAR2
, p_territory_code IN VARCHAR2
, p_start_date     IN DATE
, p_end_date       IN DATE
);

--========================================================================
--PRECEDURE : Update_Row		Public
--PARAMETERS: see below
--            initial version           1.0
--COMMENT   : table handler for updating data of table mtl_country_
--            assignments
--========================================================================
PROCEDURE Update_Row
( p_rowid             IN VARCHAR2
, p_zone_code         IN VARCHAR2
, p_territory_code    IN VARCHAR2
, p_start_date        IN DATE
, p_end_date          IN DATE
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
);

--========================================================================
--PRECEDURE : Delete_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for deleting data from table mtl_country_
--            assignments
--========================================================================
PROCEDURE Delete_Row
( p_rowid IN VARCHAR2
);

END MTL_COUNTRY_ASSIGNMENTS_PKG;

 

/

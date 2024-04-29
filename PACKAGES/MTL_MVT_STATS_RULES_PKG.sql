--------------------------------------------------------
--  DDL for Package MTL_MVT_STATS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_MVT_STATS_RULES_PKG" AUTHID CURRENT_USER AS
-- $Header: INVGMVRS.pls 115.2 2002/12/03 21:50:24 vma ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGMVRS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting row, updateing |
--|     row, locking row and deleting row on tables MTL_MVT_STATS_RULES   |
--|                                                                       |
--| HISTORY                                                               |
--|     07/14/00 ksaini      Created                                      |
--|     09/18/00 ksaini      Delete_Row procedure corrected               |
--|     11/22/02 vma         Added NOCOPY to x_rowid of Insert_Row to     |
--|                          comply with new PL/SQL standard for better   |
--|                          performance                                  |
--+======================================================================*/

--==================
--PUBLIC PROCEDURE
--==================
--========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data to table MTL_MVT_STATS_RULES
--========================================================================
PROCEDURE Insert_Row
( x_rowid                IN OUT NOCOPY VARCHAR2
, p_rule_set_code        IN     VARCHAR2
, p_rule_number          IN     NUMBER
, p_source_type          IN     VARCHAR2
, p_attribute_code       IN     VARCHAR2
, p_attribute_property_code IN  VARCHAR2
, p_attribute_lookup_type   IN  VARCHAR2
, p_commodity_code       IN     VARCHAR2
, p_creation_date        IN     DATE
, p_created_by           IN     NUMBER
, p_last_update_date     IN     DATE
, p_last_updated_by      IN     NUMBER
, p_last_update_login    IN     NUMBER
);

--========================================================================
--PRECEDURE : Lock_Row		        Public
--PARAMETERS: see below
--COMMENT   : table handler for locking table MTL_MVT_STATS_RULES
--========================================================================
PROCEDURE Lock_Row
( p_rowid                   IN VARCHAR2
, p_rule_set_code           IN VARCHAR2
, p_rule_number             IN NUMBER
, p_source_type             IN VARCHAR2
, p_attribute_code          IN VARCHAR2
, p_attribute_property_code IN VARCHAR2
, p_attribute_lookup_type   IN VARCHAR2
, p_commodity_code          IN VARCHAR2
);

--========================================================================
--PRECEDURE : Update_Row		Public
--PARAMETERS: see below
--            initial version           1.0
--COMMENT   : table handler for updating data of table MTL_MVT_STATS_RULES
--========================================================================
PROCEDURE Update_Row
( p_rowid                   IN VARCHAR2
, p_rule_set_code           IN VARCHAR2
, p_rule_number             IN NUMBER
, p_source_type             IN VARCHAR2
, p_attribute_code          IN VARCHAR2
, p_attribute_property_code IN VARCHAR2
, p_attribute_lookup_type   IN VARCHAR2
, p_commodity_code          IN VARCHAR2
, p_last_update_date        IN DATE
, p_last_updated_by         IN NUMBER
, p_last_update_login       IN NUMBER
);

--========================================================================
--PRECEDURE : Delete_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for deleting data from table MTL_MVT_STATS_RULES
--========================================================================
PROCEDURE Delete_Row
( p_rule_set_code IN VARCHAR2
);

END MTL_MVT_STATS_RULES_PKG;

 

/

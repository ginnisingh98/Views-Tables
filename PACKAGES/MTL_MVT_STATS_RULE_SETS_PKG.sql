--------------------------------------------------------
--  DDL for Package MTL_MVT_STATS_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_MVT_STATS_RULE_SETS_PKG" AUTHID CURRENT_USER AS
-- $Header: INVGVRSS.pls 115.1 2002/12/03 22:11:06 vma ship $
--+=======================================================================+
--|            Copyright (c) 1998,1999 Oracle Corporation                 |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGVRSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting row, updating  |
--|     row, locking row and deleting row on tables                       |
--|     MTL_MVT_STATS_RULE_SETS and MTL_MVT_STATS_RULE_SETS_TL            |
--|                                                                       |
--| HISTORY                                                               |
--|     07/13/00 ksaini       Created                                     |
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
--COMMENT   : table handler for inserting data to table
--            mtl_mvt_stats_rule_sets_b and table mtl_mvt_stats_rule_sets_tl
--========================================================================
PROCEDURE Insert_Row
( x_rowid                 IN OUT NOCOPY VARCHAR2
, p_rule_set_code 	      IN     VARCHAR2
, p_rule_set_display_name IN     VARCHAR2
, p_rule_set_description  IN     VARCHAR2
, p_rule_set_type     IN     VARCHAR2
, p_category_set_id   IN     NUMBER
, p_seeded_flag       IN     VARCHAR2
, p_creation_date     IN     DATE
, p_created_by        IN     NUMBER
, p_last_update_date  IN     DATE
, p_last_updated_by   IN     NUMBER
, p_last_update_login IN     NUMBER
);

--========================================================================
--PRECEDURE : Lock_Row		        Public
--PARAMETERS: see below
--COMMENT   : table handler for locking table mtl_mvt_stats_rule_sets_b and
--            table mtl_mvt_stats_rule_sets_tl
--========================================================================
PROCEDURE Lock_Row
( p_rule_set_code         IN VARCHAR2
, p_rule_set_display_name IN VARCHAR2
, p_rule_set_description  IN VARCHAR2
);

--========================================================================
--PRECEDURE : Update_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for updating data to table mtl_mvt_stats_rule_sets
--            _b and table mtl_mvt_stats_rule_sets_tl
--========================================================================
PROCEDURE Update_Row
( p_rule_set_code         IN VARCHAR2
, p_rule_set_display_name IN VARCHAR2
, p_rule_set_description  IN VARCHAR2
, p_rule_set_type     IN     VARCHAR2
, p_category_set_id   IN     NUMBER
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
);

--========================================================================
--PRECEDURE : Delete_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for deleting data from table
--            mtl_mvt_stats_rule_sets_b and table mtl_mvt_stats_rule_sets_tl
--========================================================================
PROCEDURE Delete_Row
( p_rule_set_code IN VARCHAR2
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
-- PARAMETERS: p_rule_set_code         rule set code (develper's key)
--             p_rule_set_display_name rule set name
--             p_rule_set_description  description
--             p_rule_set_type         rule set type
--             p_owner             user owning the row (SEED or other)
-- COMMENT   : used to upload seed data in NLS mode
--========================================================================
PROCEDURE Translate_Row
( p_rule_set_code         IN  VARCHAR2
, p_rule_set_display_name IN  VARCHAR2
, p_rule_set_description  IN  VARCHAR2
, p_owner             IN  VARCHAR2
);

--========================================================================
-- PRECEDURE : Load_Row		         PUBLIC
-- PARAMETERS: p_rule_set_code         rule set code (develper's key)
--             p_owner             user owning the row (SEED or other)
--             p_rule_set_display_name rule set name
--             p_rule_set_description  description
-- COMMENT   : used to upload seed data in MLS mode
--========================================================================
PROCEDURE Load_Row
( p_rule_set_code 	      IN  VARCHAR2
, p_owner             IN  VARCHAR2
, p_rule_set_display_name IN  VARCHAR2
, p_rule_set_description  IN  VARCHAR2
, p_rule_set_type     IN     VARCHAR2
, p_category_set_id   IN     NUMBER
, p_seeded_flag       IN     VARCHAR2
);

END MTL_MVT_STATS_RULE_SETS_PKG;

 

/

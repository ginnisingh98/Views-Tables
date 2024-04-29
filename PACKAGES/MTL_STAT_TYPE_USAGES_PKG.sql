--------------------------------------------------------
--  DDL for Package MTL_STAT_TYPE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_STAT_TYPE_USAGES_PKG" AUTHID CURRENT_USER AS
-- $Header: INVGSTUS.pls 120.2.12000000.2 2007/04/17 06:23:48 nesoni ship $
--+=======================================================================+
--|            Copyright (c) 1999, 2000 Oracle Corporation                |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGSTUS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Specification of package MTL_STAT_TYPE_USAGES_PKG, table          |
--|     handler for table MTL_STAT_TYPE_USAGES                            |
--|                                                                       |
--| HISTORY                                                               |
--|     01/27/1999 Herman Poon   Created                                  |
--|     05/31/1999 Paolo Juvara  Modified to reflect changes in           |
--|                              MTL_STAT_TYPE_USAGES                     |
--|     06/15/2000 Paolo Juvara  Added support for period_type            |
--|     07/11/2000 Komal Saini   Added 2 new columns for Rules Validation |
--|     09/19/2001 Yanping Wang  Added support for triangulation_mode     |
--|     01/11/2002 Yanping Wang  Added support for reference period rule  |
--|                              3 new columns: reference_period_rule,    |
--|                              pending_invoice_days,prior_invoice_days  |
--|     11/26/02   Vivian Ma     Added NOCOPY to IN OUT parameters to     |
--|                              comply with new PL/SQL standard for      |
--|                              better performance                       |
--|     09/16/2003 Yanping Wang  Added support for returns_processing     |
--|     03/08/2005 Yanping Wang  Added support for kit                    |
--|     16/04/2007 Neelam Soni   Bug 5920143. Added support for Include   |
--|                              Establishments.                          |
--+=======================================================================+


--========================================================================
-- PROCEDURE : Insert_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   : Bug:5920143. New column added include_establishments.
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Insert_Row
( p_rowid           IN OUT  NOCOPY VARCHAR2
, p_legal_entity_id         NUMBER
, p_zone_code               VARCHAR2
, p_usage_type              VARCHAR2
, p_stat_type               VARCHAR2
, p_period_set_name         VARCHAR2
, p_period_type             VARCHAR2
, p_start_period_name       VARCHAR2
, p_end_period_name         VARCHAR2
, p_weight_uom_code         VARCHAR2
, p_entity_branch_reference VARCHAR2
, p_conversion_type         VARCHAR2
, p_conversion_option       VARCHAR2
, p_category_set_id         NUMBER
, p_tax_office_code         VARCHAR2
, p_tax_office_name         VARCHAR2
, p_tax_office_location_id  NUMBER
, p_attribute_rule_set_code VARCHAR2
, p_alt_uom_rule_set_code   VARCHAR2
, p_triangulation_mode      VARCHAR2
, p_reference_period_rule   VARCHAR2
, p_pending_invoice_days    NUMBER
, p_prior_invoice_days      NUMBER
, p_returns_processing      VARCHAR2
, p_kit_method              VARCHAR2
, p_weight_precision        NUMBER
, p_reporting_rounding      VARCHAR2
, p_include_establishments  VARCHAR2
, p_last_update_date        DATE
, p_last_updated_by         NUMBER
, p_last_update_login       NUMBER
, p_created_by              NUMBER
, p_creation_date           DATE
);


--========================================================================
-- PROCEDURE : Lock_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   : Bug:5920143. New column added include_establishments.
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Lock_Row
( p_rowid           IN OUT NOCOPY VARCHAR2
, p_legal_entity_id         NUMBER
, p_zone_code               VARCHAR2
, p_usage_type              VARCHAR2
, p_stat_type               VARCHAR2
, p_period_set_name         VARCHAR2
, p_period_type             VARCHAR2
, p_start_period_name       VARCHAR2
, p_end_period_name         VARCHAR2
, p_weight_uom_code         VARCHAR2
, p_entity_branch_reference VARCHAR2
, p_conversion_type         VARCHAR2
, p_conversion_option       VARCHAR2
, p_category_set_id         NUMBER
, p_tax_office_code         VARCHAR2
, p_tax_office_name         VARCHAR2
, p_tax_office_location_id  NUMBER
, p_attribute_rule_set_code VARCHAR2
, p_alt_uom_rule_set_code   VARCHAR2
, p_triangulation_mode      VARCHAR2
, p_reference_period_rule   VARCHAR2
, p_pending_invoice_days    NUMBER
, p_prior_invoice_days      NUMBER
, p_returns_processing      VARCHAR2
, p_kit_method              VARCHAR2
, p_weight_precision        NUMBER
, p_reporting_rounding      VARCHAR2
, p_include_establishments  VARCHAR2
);


--========================================================================
-- PROCEDURE : Update_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   : Bug:5920143. New column added include_establishments.
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Update_Row
( p_rowid           IN OUT NOCOPY VARCHAR2
, p_legal_entity_id         NUMBER
, p_zone_code               VARCHAR2
, p_usage_type              VARCHAR2
, p_stat_type               VARCHAR2
, p_period_set_name         VARCHAR2
, p_period_type             VARCHAR2
, p_start_period_name       VARCHAR2
, p_end_period_name         VARCHAR2
, p_weight_uom_code         VARCHAR2
, p_entity_branch_reference VARCHAR2
, p_conversion_type         VARCHAR2
, p_conversion_option       VARCHAR2
, p_category_set_id         NUMBER
, p_tax_office_code         VARCHAR2
, p_tax_office_name         VARCHAR2
, p_tax_office_location_id  NUMBER
, p_attribute_rule_set_code VARCHAR2
, p_alt_uom_rule_set_code   VARCHAR2
, p_triangulation_mode      VARCHAR2
, p_reference_period_rule   VARCHAR2
, p_pending_invoice_days    NUMBER
, p_prior_invoice_days      NUMBER
, p_returns_processing      VARCHAR2
, p_kit_method              VARCHAR2
, p_weight_precision        NUMBER
, p_reporting_rounding      VARCHAR2
, p_include_establishments  VARCHAR2
, p_last_update_date        DATE
, p_last_updated_by         NUMBER
, p_last_update_login       NUMBER
, p_created_by              NUMBER
, p_creation_date           DATE
);


--========================================================================
-- PROCEDURE : Delete_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Delete_Row
( p_rowid IN OUT NOCOPY VARCHAR2
);


END MTL_STAT_TYPE_USAGES_PKG;

 

/

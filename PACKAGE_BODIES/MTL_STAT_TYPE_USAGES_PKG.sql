--------------------------------------------------------
--  DDL for Package Body MTL_STAT_TYPE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_STAT_TYPE_USAGES_PKG" AS
--$Header: INVGSTUB.pls 120.2.12000000.2 2007/04/17 06:26:13 nesoni ship $
--+=======================================================================+
--|            Copyright (c) 1999, 2000 Oracle Corporation                |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGSTUB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of package MTL_STAT_TYPE_USAGES_PKG, table                   |
--|     handler for table MTL_STAT_TYPE_USAGES                            |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Insert_Row                                                        |
--|     Lock_Row                                                          |
--|     Delete_Row                                                        |
--|     Update_Row                                                        |
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

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_STAT_TYPE_USAGES_PKG';
-- add your constants here if any

--===================
-- GLOBAL VARIABLES
--===================
-- add your private global variables here if any

--===================
-- PUBLIC PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Insert_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   :
--   backward compatibility:
--   the following columns have been added to the table after the initial
--   release (R11i)
--       - period_type
--       - attribute_rule_set_code 11/jul/00
--       - alt_uom_rule_set_code 11/jul/00
--       - include_establishments 06/mar/07  Bug:5920143.
--   to guarantee backward compatibility, this procedure has a default value
--   for the corresponding parameters
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
)
IS
l_period_type VARCHAR2(200);

CURSOR C IS
  SELECT
    rowid
  FROM
    MTL_STAT_TYPE_USAGES
  WHERE Legal_Entity_ID = p_legal_entity_id
    AND Zone_Code       = p_zone_code
    AND Usage_Type      = p_usage_type
    AND Stat_Type       = p_stat_type;

BEGIN
  IF p_period_type IS NULL
  THEN
    l_period_type := 'Month';
  ELSE
    l_period_type := p_period_type;
  END IF;

  -- Bug:5920143.
  -- New column include_establishments has been added to insert clause.
  INSERT INTO MTL_STAT_TYPE_USAGES(
    Legal_Entity_ID
  , Zone_Code
  , Usage_Type
  , Stat_Type
  , Start_Period_Name
  , Period_Type
  , End_Period_Name
  , Period_Set_Name
  , Weight_UOM_Code
  , Entity_Branch_Reference
  , Conversion_Type
  , Conversion_Option
  , Category_Set_ID
  , Tax_Office_Code
  , Tax_Office_Name
  , Tax_Office_Location_ID
  , Attribute_Rule_Set_Code
  , Alt_Uom_Rule_Set_Code
  , Triangulation_Mode
  , reference_period_rule
  , pending_invoice_days
  , prior_invoice_days
  , returns_processing
  , kit_method
  , weight_precision
  , reporting_rounding
  , include_establishments
  , Last_Update_Date
  , Last_Updated_By
  , Last_Update_Login
  , Created_By
  , Creation_Date
  )
  VALUES(
    p_legal_entity_id
  , p_zone_code
  , p_usage_type
  , p_stat_type
  , p_start_period_name
  , l_period_type
  , p_end_period_name
  , p_period_set_name
  , p_weight_uom_code
  , p_entity_branch_reference
  , p_conversion_type
  , p_conversion_option
  , p_category_set_id
  , p_tax_office_code
  , p_tax_office_name
  , p_tax_office_location_id
  , p_attribute_rule_set_code
  , p_alt_uom_rule_set_code
  , p_triangulation_mode
  , p_reference_period_rule
  , p_pending_invoice_days
  , p_prior_invoice_days
  , p_returns_processing
  , p_kit_method
  , p_weight_precision
  , p_reporting_rounding
  , p_include_establishments
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , p_created_by
  , p_creation_date
  );

  OPEN C;
  FETCH C INTO p_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END Insert_Row;


--========================================================================
-- PROCEDURE : Lock_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   :
--   backward compatibility:
--   the following columns have been added to the table after the initial
--   release (R11i)
--       - period_type
--       - attribute_rule_set_code 11/jul/00
--       - alt_uom_rule_set_code 11/jul/00
--       - include_establishments 06/mar/07  Bug:5920143.
--   to guarantee backward compatibility, this procedure has a default value
--   for the corresponding parameters
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
)
IS
l_period_type VARCHAR2(200);

CURSOR C IS
  SELECT *
    FROM MTL_STAT_TYPE_USAGES
   WHERE ROWID = p_rowid
   FOR UPDATE OF Legal_Entity_ID NOWAIT;
Recinfo C%ROWTYPE;

BEGIN
  IF p_period_type IS NULL
  THEN
    l_period_type := 'Month';
  ELSE
    l_period_type := p_period_type;
  END IF;

  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  CLOSE C;

  IF (
	 (Recinfo.Legal_Entity_ID = p_legal_entity_id)
      AND
      (Recinfo.zone_code = p_zone_code)
      AND
      (Recinfo.usage_type = p_usage_type)
      AND
      (Recinfo.stat_type = p_stat_type)
      AND
      (Recinfo.start_period_name = p_start_period_name)
      AND
      (
       (Recinfo.end_period_name = p_end_period_name)
       OR
       (
        (recinfo.end_period_name IS NULL)
        AND
        (p_end_period_name IS NULL)
       )
      )
      AND
      (Recinfo.period_set_name = p_period_set_name)
      AND
      (Recinfo.period_type = l_period_type)
      AND
      (Recinfo.weight_uom_code = p_weight_uom_code)
      AND
      ((Recinfo.entity_branch_reference = p_entity_branch_reference)
        OR ((Recinfo.entity_branch_reference IS NULL)
             AND (p_entity_branch_reference IS NULL))
       )
      AND
      ((Recinfo.conversion_type = p_conversion_type)
        OR (Recinfo.conversion_type IS NULL
            AND p_conversion_type IS NULL))
      AND
      ((Recinfo.conversion_option = p_conversion_option)
        OR (Recinfo.conversion_option IS NULL
             AND p_conversion_option IS NULL))
      AND
      (Recinfo.category_set_id = p_category_set_id)
      AND
      ((Recinfo.tax_office_code = p_tax_office_code)
        OR ((Recinfo.tax_office_code IS NULL)
             AND (p_tax_office_code IS NULL))
      )
      AND
      ((Recinfo.tax_office_name = p_tax_office_name)
        OR ((Recinfo.tax_office_name IS NULL)
             AND (p_tax_office_name IS NULL))
      )
      AND
      (Recinfo.tax_office_location_id = p_tax_office_location_id)
      AND
      (
      (Recinfo.attribute_rule_set_code = p_attribute_rule_set_code)
       OR
       (
        (recinfo.attribute_rule_set_code IS NULL)
        AND
        (p_attribute_rule_set_code IS NULL)
       )
       )
      AND
      (
      (Recinfo.alt_uom_rule_set_code = p_alt_uom_rule_set_code)
       OR
       (
        (recinfo.alt_uom_rule_set_code IS NULL)
        AND
        (p_alt_uom_rule_set_code IS NULL)
       )
       )
      AND ( (Recinfo.triangulation_mode = p_triangulation_mode)
           OR ( (recinfo.triangulation_mode IS NULL) AND (p_triangulation_mode IS NULL)))
      AND ( (Recinfo.reference_period_rule = p_reference_period_rule)
           OR ( (recinfo.reference_period_rule IS NULL) AND (p_reference_period_rule IS NULL)))
      AND ( (Recinfo.pending_invoice_days = p_pending_invoice_days)
           OR ( (recinfo.pending_invoice_days IS NULL) AND (p_pending_invoice_days IS NULL)))
      AND ( (Recinfo.prior_invoice_days = p_prior_invoice_days)
           OR ( (recinfo.prior_invoice_days IS NULL) AND (p_prior_invoice_days IS NULL)))
      AND ( (Recinfo.returns_processing = p_returns_processing)
           OR ( (recinfo.returns_processing IS NULL) AND (p_returns_processing IS NULL)))
      AND ( (Recinfo.kit_method = p_kit_method)
           OR ( (recinfo.kit_method IS NULL) AND (p_kit_method IS NULL)))
      AND ( (Recinfo.weight_precision = p_weight_precision)
           OR ( (recinfo.weight_precision IS NULL) AND (p_weight_precision IS NULL)))
      AND ( (Recinfo.reporting_rounding = p_reporting_rounding)
           OR ( (recinfo.reporting_rounding IS NULL) AND (p_reporting_rounding IS NULL)))
      AND ( (Recinfo.include_establishments = p_include_establishments)
           OR ( (recinfo.include_establishments IS NULL) AND (p_include_establishments IS NULL)))
     )
  THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;

END Lock_Row;


--========================================================================
-- PROCEDURE : Update_Row              PUBLIC
-- PARAMETERS:
--
--
-- COMMENT   :
--   backward compatibility:
--   the following columns have been added to the table after the initial
--   release (R11i)
--       - period_type
--       - attribute_rule_set_code 11/jul/00
--       - alt_uom_rule_set_code 11/jul/00
--       - include_establishments 06/mar/07  Bug:5920143.
--   to guarantee backward compatibility, this procedure has a default value
--   for the corresponding parameters
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
)
IS
l_period_type VARCHAR2(200);
BEGIN
  IF p_period_type IS NULL
  THEN
    l_period_type := 'Month';
  ELSE
    l_period_type := p_period_type;
  END IF;

  -- Bug:5920143.
  -- New column include_establishments has been added to update clause.
  UPDATE MTL_STAT_TYPE_USAGES
    SET
      Legal_Entity_ID         = p_legal_entity_id
    , zone_code               = p_zone_code
    , usage_type              = p_usage_type
    , stat_type               = p_stat_type
    , start_period_name       = p_start_period_name
    , end_period_name         = p_end_period_name
    , period_set_name         = p_period_set_name
    , period_type             = l_period_type
    , weight_uom_code         = p_weight_uom_code
    , entity_branch_reference = p_entity_branch_reference
    , conversion_type         = p_conversion_type
    , conversion_option       = p_conversion_option
    , category_set_id         = p_category_set_id
    , tax_office_code         = p_tax_office_code
    , tax_office_name         = p_tax_office_name
    , tax_office_location_id  = p_tax_office_location_id
    , attribute_rule_set_code = p_attribute_rule_set_code
    , alt_uom_rule_set_code   = p_alt_uom_rule_set_code
    , triangulation_mode      = p_triangulation_mode
    , reference_period_rule   = p_reference_period_rule
    , pending_invoice_days    = p_pending_invoice_days
    , prior_invoice_days      = p_prior_invoice_days
    , returns_processing      = p_returns_processing
    , kit_method              = p_kit_method
    , weight_precision        = p_weight_precision
    , reporting_rounding      = p_reporting_rounding
    , include_establishments  = p_include_establishments
    , last_update_date        = p_last_update_date
    , last_updated_by         = p_last_updated_by
    , last_update_login       = p_last_update_login
    , created_by              = p_created_by
    , creation_date           = p_creation_date
  WHERE ROWID = p_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;


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
)
IS
BEGIN

  DELETE FROM MTL_STAT_TYPE_USAGES
  WHERE ROWID = p_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

END MTL_STAT_TYPE_USAGES_PKG;

/

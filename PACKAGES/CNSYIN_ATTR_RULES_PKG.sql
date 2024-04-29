--------------------------------------------------------
--  DDL for Package CNSYIN_ATTR_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYIN_ATTR_RULES_PKG" AUTHID CURRENT_USER AS
-- $Header: cnsyinhs.pls 115.9 2002/02/05 00:25:32 pkm ship    $


  --
  -- Procedure Name
  --   populate_fields
  -- Purpose
  --
  -- History
  --   01/26/94         Tony Lower              Created
  --   07-18-95         Amy Erickson            Updated
  --

PROCEDURE Populate_Fields (x_column_id                 number,
                           x_dimension_id      IN OUT  number,
                           x_column_name       IN OUT  varchar2,
                           x_user_column_name  IN OUT  varchar2,
                           x_dim_hier_id               number,
                           x_hier_name         IN OUT  varchar2,
                           x_value_id                  varchar2,
                           x_hier_value        IN OUT  varchar2) ;
  --
  -- Procedure Name
  --   default_row
  -- Purpose
  --
  -- History
  --   01/26/94         Tony Lower              Created
  --
PROCEDURE Default_Row (X_rule_id        IN OUT  number);

--
-- Procedure Name
--   Insert_Row
-- Purpose
--
-- History
--   26-AUG-98          Ram Kalyanasundaram     Created
--
PROCEDURE Insert_Row(p_attribute_rule_id        NUMBER,
		     p_column_id                NUMBER,
		     p_column_value             VARCHAR2,
		     p_low_value                VARCHAR2,
		     p_high_value               VARCHAR2,
		     p_dimension_hierarchy_id   NUMBER,
		     p_not_flag                 VARCHAR2,
		     p_rule_id                  NUMBER,
		     p_ruleset_id               NUMBER,
		     p_last_update_date         DATE,
		     p_last_updated_by          NUMBER,
		     p_creation_date            DATE,
		     p_created_by               NUMBER,
		     p_last_update_login        NUMBER
		     );

--
-- Procedure Name
--   Update_Row
-- Purpose
--
-- History
--   26-AUG-98          Ram Kalyanasundaram     Created
--
PROCEDURE Update_Row(p_attribute_rule_id        NUMBER,
                     p_object_version_number    number, --added rckalyan
		     p_column_id                NUMBER,
		     p_column_value             VARCHAR2,
		     p_low_value                VARCHAR2,
		     p_high_value               VARCHAR2,
		     p_dimension_hierarchy_id   NUMBER,
		     p_not_flag                 VARCHAR2,
		     p_last_update_date         DATE,
		     p_last_updated_by          NUMBER,
		     p_last_update_login        NUMBER
		     );

--
-- Procedure Name
--   Delete_Row
-- Purpose
--
-- History
--   26-AUG-98          Ram Kalyanasundaram     Created
--
PROCEDURE Delete_Row(p_attribute_rule_id        NUMBER);


END CNSYIN_Attr_Rules_PKG;

 

/

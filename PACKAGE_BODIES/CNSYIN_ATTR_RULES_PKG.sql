--------------------------------------------------------
--  DDL for Package Body CNSYIN_ATTR_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYIN_ATTR_RULES_PKG" AS
-- $Header: cnsyinhb.pls 115.10 2002/02/05 00:25:31 pkm ship    $


  --
  -- Procedure Name
  --   populate_fields
  -- Purpose
  --
  -- History
  --   01/26/94         Tony Lower              Created
  --   07-18-95         Amy Erickson            Updated
  --
  --   SEP-19           Kumar Sivasankaran      Added Exceptions

PROCEDURE Populate_Fields (x_column_id                 number,
                           x_dimension_id      IN OUT  number,
                           x_column_name       IN OUT  varchar2,
                           x_user_column_name  IN OUT  varchar2,
                           x_dim_hier_id               number,
                           x_hier_name         IN OUT  varchar2,
                           x_value_id                  varchar2,
                           x_hier_value        IN OUT  varchar2) IS
  BEGIN

    IF x_column_id IS NOT NULL THEN

      BEGIN

       SELECT name, user_name, dimension_id
          INTO x_column_name, x_user_column_name, x_dimension_id
          FROM cn_objects
         WHERE object_id = x_column_id;

      EXCEPTION

          when no_data_found then

             x_column_name := null;
             x_user_column_name := null;
      END;

    END IF;

    IF x_dim_hier_id IS NOT NULL THEN

       BEGIN

        SELECT name
          INTO x_hier_name
          FROM cn_head_hierarchies
         WHERE head_hierarchy_id = x_dim_hier_id;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_hier_name := NULL;
       END;

       --END IF;

      IF x_value_id IS NOT NULL THEN

        SELECT max(hn.name) INTO x_hier_value
           FROM cn_hierarchy_nodes hn,
                cn_dim_hierarchies dh
          WHERE hn.value_id = to_number(x_value_id)
            AND hn.dim_hierarchy_id = dh.dim_hierarchy_id
            AND dh.header_dim_hierarchy_id = x_dim_hier_id;

      ELSE x_hier_value := NULL;

      END IF;

    ELSE x_hier_name := NULL;

    END IF;


  END Populate_Fields;

  --
  -- Procedure Name
  --   default_row
  -- Purpose
  --
  -- History
  --   01/26/94         Tony Lower              Created
  --
PROCEDURE Default_Row (X_rule_id        IN OUT  number) IS
  BEGIN

    IF X_rule_id IS NULL THEN
      SELECT cn_objects_s.nextval
        INTO X_rule_id
        FROM sys.dual;
    END IF;

  END Default_Row;

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
		     )
  IS
BEGIN
   INSERT INTO cn_attribute_rules(object_version_number,
                                  attribute_rule_id, column_id,
				  column_value, low_value, high_value,
				  dimension_hierarchy_id, not_flag,
				  rule_id, ruleset_id, last_update_date, last_updated_by,
				  creation_date,created_by,
				  last_update_login)
     VALUES(1,
            p_attribute_rule_id, p_column_id,
	    p_column_value, p_low_value, p_high_value,
	    p_dimension_hierarchy_id, p_not_flag,
	    p_rule_id,p_ruleset_id, p_last_update_date, p_last_updated_by,
	    p_creation_date, p_created_by,
	    p_last_update_login);
END Insert_Row;

--
-- Procedure Name
--   Update_Row
-- Purpose
--
-- History
--   26-AUG-98          Ram Kalyanasundaram     Created
--
PROCEDURE Update_Row(p_attribute_rule_id        NUMBER,
                     p_object_version_number    number,  --added rckalyan
		     p_column_id                NUMBER,
		     p_column_value             VARCHAR2,
		     p_low_value                VARCHAR2,
		     p_high_value               VARCHAR2,
		     p_dimension_hierarchy_id   NUMBER,
		     p_not_flag                 VARCHAR2,
		     p_last_update_date         DATE,
		     p_last_updated_by          NUMBER,
		     p_last_update_login        NUMBER
		     )
  IS
BEGIN
   UPDATE cn_attribute_rules
     SET column_id = p_column_id,
     object_version_number = p_object_version_number + 1,
     column_value = p_column_value,
     low_value = p_low_value,
     high_value = p_high_value,
     dimension_hierarchy_id = p_dimension_hierarchy_id,
     not_flag = p_not_flag,
     last_update_date = p_last_update_date,
     last_updated_by = p_last_updated_by,
     last_update_login = p_last_update_login
     WHERE attribute_rule_id = p_attribute_rule_id;
END Update_Row;

--
-- Procedure Name
--   Delete_Row
-- Purpose
--
-- History
--   26-AUG-98          Ram Kalyanasundaram     Created
--
PROCEDURE delete_row(p_attribute_rule_id        NUMBER )
  IS
BEGIN

   DELETE FROM cn_attribute_rules
     WHERE attribute_rule_id = p_attribute_rule_id;

END Delete_Row;

END CNSYIN_Attr_Rules_PKG;

/

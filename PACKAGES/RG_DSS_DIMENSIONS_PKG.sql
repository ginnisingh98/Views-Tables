--------------------------------------------------------
--  DDL for Package RG_DSS_DIMENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_DIMENSIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgiddims.pls 120.3 2002/11/14 03:34:25 djogg ship $ */
--
-- Name
--   RG_DSS_DIMENSIONS_PKG
-- Purpose
--   to include all server side procedures and packages for table
--   rg_dss_dimensions
-- Notes
--
-- History
--   06/16/95	A Chen	Created
--
--
-- Procedures


/* Name: get_cache_data
 * Desc: Gets cache data.
 *
 * History:
 *   08/30/95   S. Rahman   Created.
 */
PROCEDURE get_cache_data(COAId NUMBER,
                         AccountingSegmentColumn IN OUT NOCOPY VARCHAR2);


/* Name: get_new_id
 * Desc: Gets a new id from the sequence RG_DSS_DIMENSIONS_S
 *
 * History:
 *   10/09/95   S. Rahman   Created.
 */
FUNCTION get_new_id RETURN NUMBER;


/* Name: used_in_frozen_system
 * Desc: Return 1 if the dimension is used in a frozen system;
 *       0 otherwise. NOTE: this function returns a NUMBER instead of
 *       a BOOLEAN because it is called from a WHERE clause in
 *       RG_DSS_HIERARCHIES_PKG.used_in_frozen_system function.
 *
 * History:
 *   07/31/95   S. Rahman   Created.
 */
FUNCTION used_in_frozen_system(X_Dimension_Id NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(used_in_frozen_system, WNDS, WNPS);


-- Name
--   check_unique_name
-- Purpose
--   unique check for name
-- Arguments
--   name
--
PROCEDURE check_unique_name(X_rowid VARCHAR2,
                       X_name VARCHAR2);


-- Name
--   check_unique_object_name
-- Purpose
--   unique check for object name
-- Arguments
--   object name
--
PROCEDURE check_unique_object_name(X_rowid VARCHAR2,
                                   X_object_name VARCHAR2);


-- Name
--   check_unique_object_prefix
-- Purpose
--   unique check for object prefix
-- Arguments
--   object prefix
--
PROCEDURE check_unique_object_prefix(X_rowid VARCHAR2,
                                   X_object_prefix VARCHAR2);


-- Name
--   check_references
-- Purpose
--   Referential integrity check on rg_dss_dimensions
-- Arguments
--   dimension_id
--
PROCEDURE check_references(X_dimension_id NUMBER);


FUNCTION num_details(X_Dimension_Id NUMBER) RETURN NUMBER;


PROCEDURE set_dimension_type(
            X_Dimension_Id NUMBER,
            X_Dimension_Type IN OUT NOCOPY VARCHAR2,
            Num_Records NUMBER DEFAULT NULL);


PROCEDURE pre_insert(X_Rowid VARCHAR2,
                     X_Name  VARCHAR2,
                     X_Object_Name VARCHAR2,
                     X_Object_Prefix VARCHAR2,
                     X_Level_Code VARCHAR2,
                     X_Dimension_Id IN OUT NOCOPY NUMBER,
                     X_Dimension_Type IN OUT NOCOPY VARCHAR2);


PROCEDURE pre_update(X_Level_Code VARCHAR2,
                     X_Dimension_Id NUMBER);


PROCEDURE pre_delete(X_Dimension_Id NUMBER);


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Dimension_Id                   NUMBER,
                       X_Name                           VARCHAR2,
                       X_Object_Name                    VARCHAR2,
                       X_Object_Prefix                  VARCHAR2,
                       X_Value_Prefix                   VARCHAR2,
                       X_Row_Label                      VARCHAR2,
                       X_Column_Label                   VARCHAR2,
                       X_Selector_Label                 VARCHAR2,
                       X_Level_Code                     VARCHAR2,
                       X_Dimension_Type                 VARCHAR2,
                       X_Dimension_By_Currency          VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Description                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Dimension_Id                   NUMBER,
                       X_Name                           VARCHAR2,
                       X_Object_Name                    VARCHAR2,
                       X_Object_Prefix                  VARCHAR2,
                       X_Value_Prefix                   VARCHAR2,
                       X_Row_Label                      VARCHAR2,
                       X_Column_Label                   VARCHAR2,
                       X_Selector_Label                 VARCHAR2,
                       X_Level_Code                     VARCHAR2,
                       X_Dimension_Type                 VARCHAR2,
                       X_Dimension_By_Currency          VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Description                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );

  PROCEDURE Load_Row(  X_Dimension_Id                   NUMBER,
                       X_Name                           VARCHAR2,
                       X_Object_Name                    VARCHAR2,
                       X_Object_Prefix                  VARCHAR2,
                       X_Value_Prefix                   VARCHAR2,
                       X_Row_Label                      VARCHAR2,
                       X_Column_Label                   VARCHAR2,
                       X_Selector_Label                 VARCHAR2,
                       X_Level_Code                     VARCHAR2,
                       X_Dimension_Type                 VARCHAR2,
                       X_Dimension_By_Currency          VARCHAR2,
                       X_Id_Flex_Code                   VARCHAR2,
                       X_Id_Flex_Num                    NUMBER,
                       X_Description                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Owner                          VARCHAR2,
		       X_Force_Edits                    VARCHAR2);

  PROCEDURE Translate_Row(X_Dimension_Id                   NUMBER,
                       X_Name                           VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Owner                          VARCHAR2,
		       X_Force_Edits                    VARCHAR2);

END RG_DSS_DIMENSIONS_PKG;

 

/

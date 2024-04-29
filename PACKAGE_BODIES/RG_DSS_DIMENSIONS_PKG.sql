--------------------------------------------------------
--  DDL for Package Body RG_DSS_DIMENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_DIMENSIONS_PKG" AS
/* $Header: rgiddimb.pls 120.5 2004/09/20 06:34:53 adesu ship $ */
--
-- Name
--   RG_DSS_DIMENSIONS_PKG
-- Purpose
--   to include all server side procedures AND packages for table
--   rg_dss_dimensions
-- Notes
--
-- History
--   06/16/95	A Chen	Created
--

/* Variables */

G_Account_Column_Name VARCHAR2(30);


--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
PROCEDURE get_cache_data(COAId NUMBER,
                         AccountingSegmentColumn IN OUT NOCOPY VARCHAR2) IS
BEGIN
  IF (NOT fnd_flex_apis.get_segment_column(101,
                                           'GL#',
                                           COAId,
                                           'GL_ACCOUNT',
                                           AccountingSegmentColumn)) THEN
    FND_MESSAGE.set_name('SQLGL', 'GL_NO_ACCOUNT_SEG_DEFINED');
    APP_EXCEPTION.raise_exception;
  END IF;
  G_Account_Column_Name := AccountingSegmentColumn;
END get_cache_data;


FUNCTION used_in_frozen_system(X_Dimension_Id NUMBER) RETURN NUMBER IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_systems sys,
                        rg_dss_system_variables svr,
                        rg_dss_var_dimensions vdm,
                        rg_dss_dimensions dim
              WHERE     dim.dimension_id = X_Dimension_Id
              AND       dim.dimension_id = vdm.dimension_id
              AND       vdm.variable_id = svr.variable_id
              AND       svr.system_id = sys.system_id
              AND       sys.freeze_flag = 'Y');
  RETURN(0);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(1);
END used_in_frozen_system;


PROCEDURE check_unique_name(X_rowid VARCHAR2,
                            X_name VARCHAR2) IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_dimensions
              WHERE     name = X_name
              AND       ((X_rowid IS NULL) OR (rowid <> X_rowid))
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_FORMS_OBJECT_EXISTS');
      FND_MESSAGE.set_token('OBJECT', 'RG_DSS_DIMENSION',TRUE);
      APP_EXCEPTION.raise_exception;
END check_unique_name;


PROCEDURE check_unique_object_name(X_rowid VARCHAR2,
                                   X_object_name VARCHAR2) IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_dimensions
              WHERE     object_name = X_object_name
              AND       ((X_rowid IS NULL) OR (rowid <> X_rowid))
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_FORMS_OBJECT_EXISTS');
      FND_MESSAGE.set_token('OBJECT','RG_DSS_OBJECT_NAME',TRUE);
      APP_EXCEPTION.raise_exception;
END check_unique_object_name;


PROCEDURE check_unique_object_prefix(
            X_rowid VARCHAR2,
            X_object_prefix VARCHAR2) IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_dimensions
              WHERE     object_prefix = X_object_prefix
              AND       ((X_rowid IS NULL) OR (rowid <> X_rowid))
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_FORMS_OBJECT_EXISTS');
      FND_MESSAGE.set_token('OBJECT','RG_DSS_OBJECT_PREFIX',TRUE);
      APP_EXCEPTION.raise_exception;
END check_unique_object_prefix;


PROCEDURE check_unique(X_Rowid VARCHAR2,
                       X_Name  VARCHAR2,
                       X_Object_Name VARCHAR2,
                       X_Object_Prefix VARCHAR2) IS
BEGIN
  check_unique_name(X_Rowid, X_Name);
  check_unique_object_name(X_Rowid, X_Object_Name);
  check_unique_object_prefix(X_Rowid, X_Object_Prefix);
END check_unique;


PROCEDURE check_references(X_dimension_id NUMBER) IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_var_dimensions
              WHERE     dimension_id = X_dimension_id
              UNION ALL
              SELECT    1
              FROM      rg_dss_hierarchies
              WHERE     dimension_id = X_dimension_id
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_DSS_REF_DIMENSION');
      APP_EXCEPTION.raise_exception;
END check_references;


FUNCTION get_new_id RETURN NUMBER IS
  next_dimension_id NUMBER;
BEGIN
  SELECT    rg_dss_dimensions_s.nextval
  INTO      next_dimension_id
  FROM      dual;

  RETURN (next_dimension_id);
END get_new_id;


FUNCTION num_details(X_Dimension_Id NUMBER) RETURN NUMBER IS
  NumRecords NUMBER;
BEGIN
  SELECT COUNT(dimension_id)
  INTO   NumRecords
  FROM   rg_dss_dim_segments
  WHERE  dimension_id = X_dimension_id;

  RETURN(NumRecords);
END num_details;


PROCEDURE set_dimension_type(
            X_Dimension_Id NUMBER,
            X_Dimension_Type IN OUT NOCOPY VARCHAR2,
            Num_Records NUMBER DEFAULT NULL) IS
  NumRecords  NUMBER;
  RangeSetId  NUMBER;
  ApplicationColumnName VARCHAR2(30);
  AccountType VARCHAR2(1);
BEGIN
  NumRecords := NVL(Num_Records, num_details(X_Dimension_Id));

  IF (NumRecords = 1) THEN
    /* There is only one record; check its range_set_id */
    SELECT range_set_id, application_column_name, account_type
    INTO   RangeSetId, ApplicationColumnName, AccountType
    FROM   rg_dss_dim_segments
    WHERE  dimension_id = X_dimension_id;

    IF (RangeSetId IS NULL) THEN
      /* If account segment, then account_type = All  => type = 'P',
       *                          account_type <> All => type = 'S'
       */
      IF ((ApplicationColumnName = G_Account_Column_Name) AND
          (AccountType <> 'F')) THEN
        X_Dimension_Type := 'S';
      ELSE
        X_Dimension_Type := 'P';
      END IF;
    ELSE
      X_Dimension_Type := 'S';
    END IF;
  ELSIF (NumRecords > 1) THEN
    X_Dimension_Type := 'M';
  ELSE
    NULL;
  END IF;
END set_dimension_type;


PROCEDURE pre_insert(X_Rowid VARCHAR2,
                     X_Name  VARCHAR2,
                     X_Object_Name VARCHAR2,
                     X_Object_Prefix VARCHAR2,
                     X_Level_Code    VARCHAR2,
                     X_Dimension_Id IN OUT NOCOPY NUMBER,
                     X_Dimension_Type IN OUT NOCOPY VARCHAR2) IS
  NumRecords NUMBER;
BEGIN
  check_unique(X_Rowid, X_Name, X_Object_Name, X_Object_Prefix);

  IF (X_dimension_id IS NULL) THEN
    X_Dimension_Id := get_new_id;
  END IF;

  /* Ensure that there are detail records and set dimension_type */
  NumRecords := num_details(X_Dimension_Id);
  IF (NumRecords = 0) THEN
    /* No rows returned - Error: at least one detail must exist */
    FND_MESSAGE.set_name('RG','RG_DSS_DETAIL_REQUIRED');
    APP_EXCEPTION.raise_exception;
  ELSIF (NumRecords > 1 AND X_Level_Code = 'S') THEN
    FND_MESSAGE.set_name('RG','RG_DSS_SUM_DIM_VIOL');
    APP_EXCEPTION.raise_exception;
  ELSE
    set_dimension_type(X_Dimension_Id, X_Dimension_Type, NumRecords);
  END IF;
END pre_insert;


PROCEDURE pre_update(X_Level_Code  VARCHAR2,
                     X_Dimension_Id NUMBER) IS
  NumRecords NUMBER;
BEGIN
  IF (RG_DSS_DIMENSIONS_PKG.used_in_frozen_system(X_Dimension_Id) = 1) THEN
    -- can't modify a dimension that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_DIMENSION', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  IF (X_Level_Code = 'S') THEN
    NumRecords := num_details(X_Dimension_Id);
    IF (NumRecords > 1 ) THEN
       FND_MESSAGE.set_name('RG','RG_DSS_SUM_DIM_VIOL');
       APP_EXCEPTION.raise_exception;
    END IF;
  END IF;

END pre_update;


PROCEDURE pre_delete(X_Dimension_Id NUMBER) IS
BEGIN
  IF (RG_DSS_DIMENSIONS_PKG.used_in_frozen_system(X_Dimension_Id) = 1) THEN
    -- can't modify a dimension that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_DIMENSION', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;
END pre_delete;

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
  ) IS
    CURSOR C IS SELECT rowid FROM rg_dss_dimensions
                 WHERE dimension_id = X_Dimension_Id;
   BEGIN
       INSERT INTO rg_dss_dimensions(
              dimension_id,
              name,
              object_name,
              object_prefix,
              value_prefix,
              row_label,
              column_label,
              selector_label,
              level_code,
              dimension_type,
              dimension_by_currency,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              id_flex_code,
              id_flex_num,
              description,
              context,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             ) VALUES (
              X_Dimension_Id,
              X_Name,
              X_Object_Name,
              X_Object_Prefix,
              X_Value_Prefix,
              X_Row_Label,
              X_Column_Label,
              X_Selector_Label,
              X_Level_Code,
              X_Dimension_Type,
              X_Dimension_By_Currency,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Id_Flex_Code,
              X_Id_Flex_Num,
              X_Description,
              X_Context,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


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
  ) IS
  BEGIN
    UPDATE rg_dss_dimensions
    SET
       dimension_id                    =     X_Dimension_Id,
       name                            =     X_Name,
       object_name                     =     X_Object_Name,
       object_prefix                   =     X_Object_Prefix,
       value_prefix                    =     X_Value_Prefix,
       row_label                       =     X_Row_Label,
       column_label                    =     X_Column_Label,
       selector_label                  =     X_Selector_Label,
       level_code                      =     X_Level_Code,
       dimension_type                  =     X_Dimension_Type,
       dimension_by_currency           =     X_Dimension_By_Currency,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       id_flex_code                    =     X_Id_Flex_Code,
       id_flex_num                     =     X_Id_Flex_Num,
       description                     =     X_Description,
       context                         =     X_Context,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

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
		       X_Force_Edits                    VARCHAR2) IS
    user_id number := 0;
    v_rowid rowid := null;
  BEGIN

    -- validate input parameters
    IF ( X_Dimension_Id IS NULL OR X_Name IS NULL ) THEN
      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    END IF;

    IF (X_Owner = 'SEED') THEN
      user_id := 1;
    END IF;

    BEGIN

       /* Check if the row exists in the database. If it does, retrieves
          the creation date for update_row. */
        SELECT rowid
        into   v_rowid
        FROM   rg_dss_dimensions
        WHERE  dimension_id = X_Dimension_Id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RG_DSS_DIMENSIONS_PKG.Insert_Row(
                X_Rowid                => v_rowid,
                X_Dimension_Id         => X_Dimension_Id,
                X_Name                 => X_Name,
                X_Object_Name          => X_Object_Name,
                X_Object_Prefix        => X_Object_Prefix,
                X_Value_Prefix         => X_Value_Prefix,
                X_Row_Label            => X_Row_Label,
                X_Column_Label         => X_Column_Label,
                X_Selector_Label       => X_Selector_Label,
                X_Level_Code           => X_Level_Code,
                X_Dimension_Type       => X_Dimension_Type,
                X_Dimension_By_Currency=> X_Dimension_By_Currency,
                X_Last_Update_Date     => sysdate,
                X_Last_Updated_By      => user_id,
                X_Creation_Date        => sysdate,
                X_Created_By           => user_id,
                X_Last_Update_Login    => 0,
                X_Id_Flex_Code         => X_Id_Flex_Code,
                X_Id_Flex_Num          => X_Id_Flex_Num,
                X_Description          => X_Description,
                X_Context              => X_Context,
                X_Attribute1           => X_Attribute1,
                X_Attribute2           => X_Attribute2,
                X_Attribute3           => X_Attribute3,
                X_Attribute4           => X_Attribute4,
                X_Attribute5           => X_Attribute5,
                X_Attribute6           => X_Attribute6,
                X_Attribute7           => X_Attribute7,
                X_Attribute8           => X_Attribute8,
                X_Attribute9           => X_Attribute9,
                X_Attribute10          => X_Attribute10,
                X_Attribute11          => X_Attribute11,
                X_Attribute12          => X_Attribute12,
                X_Attribute13          => X_Attribute13,
                X_Attribute14          => X_Attribute14,
                X_Attribute15          => X_Attribute15);
            return;
    END;

    IF ( user_id = 1 or X_Force_Edits = 'Y' ) THEN
            RG_DSS_DIMENSIONS_PKG.Update_Row(
                X_Rowid                => v_rowid,
                X_Dimension_Id         => X_Dimension_Id,
                X_Name                 => X_Name,
                X_Object_Name          => X_Object_Name,
                X_Object_Prefix        => X_Object_Prefix,
                X_Value_Prefix         => X_Value_Prefix,
                X_Row_Label            => X_Row_Label,
                X_Column_Label         => X_Column_Label,
                X_Selector_Label       => X_Selector_Label,
                X_Level_Code           => X_Level_Code,
                X_Dimension_Type       => X_Dimension_Type,
                X_Dimension_By_Currency=> X_Dimension_By_Currency,
                X_Last_Update_Date     => sysdate,
                X_Last_Updated_By      => user_id,
                X_Last_Update_Login    => 0,
                X_Id_Flex_Code         => X_Id_Flex_Code,
                X_Id_Flex_Num          => X_Id_Flex_Num,
                X_Description          => X_Description,
                X_Context              => X_Context,
                X_Attribute1           => X_Attribute1,
                X_Attribute2           => X_Attribute2,
                X_Attribute3           => X_Attribute3,
                X_Attribute4           => X_Attribute4,
                X_Attribute5           => X_Attribute5,
                X_Attribute6           => X_Attribute6,
                X_Attribute7           => X_Attribute7,
                X_Attribute8           => X_Attribute8,
                X_Attribute9           => X_Attribute9,
                X_Attribute10          => X_Attribute10,
                X_Attribute11          => X_Attribute11,
                X_Attribute12          => X_Attribute12,
                X_Attribute13          => X_Attribute13,
                X_Attribute14          => X_Attribute14,
                X_Attribute15          => X_Attribute15);
    END IF;
  END Load_Row;

  PROCEDURE Translate_Row(  X_Dimension_Id                   NUMBER,
                       X_Name                           VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Owner                          VARCHAR2,
		       X_Force_Edits                    VARCHAR2) IS
    user_id number := 0;
  BEGIN

    IF (X_Owner = 'SEED') THEN
      user_id := 1;
    END IF;

    IF ( user_id = 1 or X_Force_Edits = 'Y' ) THEN
         UPDATE rg_dss_dimensions
         SET
             dimension_id  =     X_Dimension_Id,
             name          =     nvl(X_Name, name),
             description   =     nvl(X_Description, description),
	     last_update_date  = sysdate,
	     last_updated_by   = user_id,
	     last_Update_login = 0
         WHERE  dimension_id = X_Dimension_Id
         AND    userenv('LANG') =
             ( SELECT language_code
                FROM  FND_LANGUAGES
		WHERE  installed_flag = 'B' );
         /*If base language is not set to the language being uploaded, then do nothing*/
         IF SQL%NOTFOUND THEN
           NULL;
         END IF;
    END IF;

  END Translate_Row;

END RG_DSS_DIMENSIONS_PKG;

/

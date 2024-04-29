--------------------------------------------------------
--  DDL for Package Body RG_DSS_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_VARIABLES_PKG" as
/*$Header: rgidvarb.pls 120.3 2003/04/29 00:47:31 djogg ship $*/

/*** PUBLIC FUNCTIONS ***/

FUNCTION get_new_id RETURN NUMBER IS
  new_id   NUMBER;
BEGIN
  SELECT   rg_dss_variables_s.nextval
  INTO     new_id
  FROM     sys.dual;

  RETURN(new_id);
END get_new_id;


FUNCTION num_dimensions(X_Variable_Id NUMBER) RETURN NUMBER IS
  NumRecords NUMBER;
BEGIN
  SELECT COUNT(variable_id)
  INTO   NumRecords
  FROM   rg_dss_var_dimensions
  WHERE  variable_id = X_Variable_Id;

  RETURN(NumRecords);
END num_dimensions;


FUNCTION used_in_frozen_system(X_Variable_Id NUMBER) RETURN BOOLEAN IS
  dummy   NUMBER;
BEGIN
  /* The line "svr.system_id > 0" is added in the query to force the query
     to use the index on system_id and variable_id for svr. */
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_systems sys,
                        rg_dss_system_variables svr
              WHERE     svr.variable_id = X_Variable_Id
              AND       svr.system_id > 0
              AND       svr.system_id = sys.system_id
              AND       sys.freeze_flag = 'Y');
  RETURN(FALSE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(TRUE);
END used_in_frozen_system;


PROCEDURE check_for_details(X_Variable_Id NUMBER,
                            X_Level_Code  VARCHAR2) IS
  dummy   NUMBER;
BEGIN

  BEGIN
  /* Raise exception if there is no time dimension defined for this variable */
    SELECT    1
    INTO      dummy
    FROM      dual
    WHERE     NOT EXISTS
              (SELECT    1
               FROM      rg_dss_var_dimensions vdm,
                         rg_dss_dimensions dim
               WHERE     vdm.variable_id = X_Variable_Id
               AND       vdm.dimension_id = dim.dimension_id
               AND       dim.dimension_type = 'T' );
    FND_MESSAGE.set_name('RG', 'RG_DSS_DIMENSION_REQUIRED');
    APP_EXCEPTION.raise_exception;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  IF (X_Level_Code = 'S') THEN
     SELECT 1
     INTO   dummy
     FROM   dual
     WHERE  NOT EXISTS
            (SELECT    1
             FROM   rg_dss_var_dimensions vdm,
                    rg_dss_dimensions dim
             WHERE     vdm.variable_id = X_Variable_Id
             AND       vdm.dimension_id = dim.dimension_id
             AND       dim.level_code = 'S' );

     FND_MESSAGE.set_name('RG', 'RG_DSS_SUM_DIM_REQUIRED');
     APP_EXCEPTION.raise_exception;
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END check_for_details;


PROCEDURE check_unique_name(X_Rowid VARCHAR2, X_Name VARCHAR2) IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      rg_dss_variables
  WHERE     name = X_Name
  AND       ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

  -- name already exists for a different variable: ERROR
  FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS');
  FND_MESSAGE.set_token('OBJECT', 'RG_DSS_VARIABLE', TRUE);
  APP_EXCEPTION.raise_exception;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- name doesn't exist, so do nothing
    NULL;
END check_unique_name;


PROCEDURE check_unique_object_name(X_Rowid VARCHAR2, X_Object_Name VARCHAR2) IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      rg_dss_variables
  WHERE     object_name = X_Object_Name
  AND       ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

  -- name already exists for a different variable: ERROR
  FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS');
  FND_MESSAGE.set_token('OBJECT', 'RG_DSS_OBJECT_NAME', TRUE);
  APP_EXCEPTION.raise_exception;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- name doesn't exist, so do nothing
    NULL;
END check_unique_object_name;


PROCEDURE check_references(X_Variable_Id NUMBER) IS
  dummy NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      dual
  WHERE     NOT EXISTS
             (SELECT    1
              FROM      rg_dss_system_variables
              WHERE     variable_id = X_Variable_Id
             );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('RG','RG_DSS_REF_VARIABLE');
      APP_EXCEPTION.raise_exception;
END check_references;

PROCEDURE generate_matching_struc(
                       X_Variable_Id                    NUMBER,
                       X_Chart_of_Account_Id            NUMBER,
                       X_Segment1_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment2_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment3_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment4_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment5_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment6_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment7_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment8_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment9_Type          IN OUT NOCOPY     VARCHAR2,
                       X_Segment10_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment11_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment12_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment13_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment14_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment15_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment16_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment17_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment18_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment19_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment20_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment21_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment22_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment23_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment24_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment25_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment26_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment27_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment28_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment29_Type         IN OUT NOCOPY     VARCHAR2,
                       X_Segment30_Type         IN OUT NOCOPY     VARCHAR2 ) IS
    seg_name varchar2(30);
    seg_value varchar2(25);

    CURSOR coa_seg IS
      SELECT application_column_name, 'ANY'
      FROM fnd_id_flex_segments
      WHERE application_id = 101
      AND   id_flex_code   = 'GL#'
      AND   enabled_flag   = 'Y'
      AND   id_flex_num    = X_Chart_of_Account_Id;

   BEGIN

    OPEN coa_seg;

    LOOP
        FETCH coa_seg INTO seg_name,seg_value;
        EXIT WHEN coa_seg%NOTFOUND;

       BEGIN
        SELECT decode(dim.level_code,'D','D','S','R','D')
        INTO seg_value
        FROM rg_dss_dimensions dim,
             rg_dss_dim_segments ds,
             rg_dss_var_dimensions vd
        WHERE  ds.dimension_id = vd.dimension_id
        AND    vd.variable_id = X_Variable_Id
        AND    ds.application_column_name = seg_name
        AND    vd.dimension_id = dim.dimension_id;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             null;
          WHEN TOO_MANY_ROWS THEN
             FND_MESSAGE.set_name('RG', 'RG_DSS_DIM_DUP_SEG');
             APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN OTHERS THEN
             RAISE;
       END;

       BEGIN
        SELECT 'DR'
        INTO seg_value
        FROM rg_dss_var_selections vs
        WHERE
              vs.variable_id = X_Variable_Id
        AND   vs.application_column_name = seg_name;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             null;
          WHEN OTHERS THEN
             RAISE;
       END;

       IF (seg_name = 'SEGMENT1') THEN
           X_Segment1_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT2') THEN
           X_Segment2_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT3') THEN
           X_Segment3_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT4') THEN
           X_Segment4_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT5') THEN
           X_Segment5_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT6') THEN
           X_Segment6_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT7') THEN
           X_Segment7_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT8') THEN
           X_Segment8_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT9') THEN
           X_Segment9_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT10') THEN
           X_Segment10_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT11') THEN
           X_Segment11_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT12') THEN
           X_Segment12_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT13') THEN
           X_Segment13_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT14') THEN
           X_Segment14_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT15') THEN
           X_Segment15_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT16') THEN
           X_Segment16_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT17') THEN
           X_Segment17_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT18') THEN
           X_Segment18_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT19') THEN
           X_Segment19_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT20') THEN
           X_Segment20_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT21') THEN
           X_Segment21_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT22') THEN
           X_Segment22_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT23') THEN
           X_Segment23_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT24') THEN
           X_Segment24_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT25') THEN
           X_Segment25_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT26') THEN
           X_Segment26_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT27') THEN
           X_Segment27_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT28') THEN
           X_Segment28_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT29') THEN
           X_Segment29_Type := seg_value;
       ELSIF (seg_name = 'SEGMENT30') THEN
           X_Segment30_Type := seg_value;
       END IF;

    END LOOP;

    CLOSE coa_seg;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'RG_DSS_VARIABLES_PKG.generate_matching_struc');
      RAISE;
END generate_matching_struc;

PROCEDURE insert_row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Variable_Id                   IN OUT NOCOPY NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Object_Name                          VARCHAR2,
                     X_Column_Label                         VARCHAR2,
                     X_Balance_Type                         VARCHAR2,
                     X_Currency_Type                        VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Budget_Version_Id                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Level_Code                           VARCHAR2,
                     X_Status_Code                          VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Segment1_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment2_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment3_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment4_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment5_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment6_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment7_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment8_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment9_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment10_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment11_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment12_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment13_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment14_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment15_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment16_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment17_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment18_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment19_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment20_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment21_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment22_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment23_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment24_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment25_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment26_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment27_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment28_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment29_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment30_Type            IN OUT NOCOPY     VARCHAR2
) IS
  CURSOR C IS
    SELECT    rowid
    FROM      rg_dss_variables
    WHERE     variable_id = X_Variable_Id;

BEGIN
  check_unique_name(X_Rowid, X_Name);
  check_unique_object_name(X_Rowid, X_Object_Name);

  IF (X_Variable_Id IS NULL) THEN
    X_Variable_Id := get_new_id;
  END IF;

  /* Raise exception if there is no dimension defined for this variable */
  check_for_details(X_Variable_Id,X_Level_Code);

  IF (X_Level_Code = 'S') THEN
      generate_matching_struc( X_Variable_Id,
                               X_Id_Flex_Num,
                               X_Segment1_Type,
                               X_Segment2_Type,
                               X_Segment3_Type,
                               X_Segment4_Type,
                               X_Segment5_Type,
                               X_Segment6_Type,
                               X_Segment7_Type,
                               X_Segment8_Type,
                               X_Segment9_Type,
                               X_Segment10_Type,
                               X_Segment11_Type,
                               X_Segment12_Type,
                               X_Segment13_Type,
                               X_Segment14_Type,
                               X_Segment15_Type,
                               X_Segment16_Type,
                               X_Segment17_Type,
                               X_Segment18_Type,
                               X_Segment19_Type,
                               X_Segment20_Type,
                               X_Segment21_Type,
                               X_Segment22_Type,
                               X_Segment23_Type,
                               X_Segment24_Type,
                               X_Segment25_Type,
                               X_Segment26_Type,
                               X_Segment27_Type,
                               X_Segment28_Type,
                               X_Segment29_Type,
                               X_Segment30_Type);
  END IF;

  INSERT INTO rg_dss_variables(
          variable_id,
          name,
          object_name,
          column_label,
          balance_type,
          currency_type,
          currency_code,
          id_flex_code,
          id_flex_num,
          ledger_id,
          budget_version_id,
          encumbrance_type_id,
          level_code,
          status_code,
          description,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
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
          attribute15,
          segment1_type,
          segment2_type,
          segment3_type,
          segment4_type,
          segment5_type,
          segment6_type,
          segment7_type,
          segment8_type,
          segment9_type,
          segment10_type,
          segment11_type,
          segment12_type,
          segment13_type,
          segment14_type,
          segment15_type,
          segment16_type,
          segment17_type,
          segment18_type,
          segment19_type,
          segment20_type,
          segment21_type,
          segment22_type,
          segment23_type,
          segment24_type,
          segment25_type,
          segment26_type,
          segment27_type,
          segment28_type,
          segment29_type,
          segment30_type
         ) VALUES (
          X_Variable_Id,
          X_Name,
          X_Object_Name,
          X_Column_Label,
          X_Balance_Type,
          X_Currency_Type,
          X_Currency_Code,
          X_Id_Flex_Code,
          X_Id_Flex_Num,
          X_Ledger_Id,
          X_Budget_Version_Id,
          X_Encumbrance_Type_Id,
          X_Level_Code,
          X_Status_Code,
          X_Description,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Creation_Date,
          X_Created_By,
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
          X_Attribute15,
          X_Segment1_Type,
          X_Segment2_Type,
          X_Segment3_Type,
          X_Segment4_Type,
          X_Segment5_Type,
          X_Segment6_Type,
          X_Segment7_Type,
          X_Segment8_Type,
          X_Segment9_Type,
          X_Segment10_Type,
          X_Segment11_Type,
          X_Segment12_Type,
          X_Segment13_Type,
          X_Segment14_Type,
          X_Segment15_Type,
          X_Segment16_Type,
          X_Segment17_Type,
          X_Segment18_Type,
          X_Segment19_Type,
          X_Segment20_Type,
          X_Segment21_Type,
          X_Segment22_Type,
          X_Segment23_Type,
          X_Segment24_Type,
          X_Segment25_Type,
          X_Segment26_Type,
          X_Segment27_Type,
          X_Segment28_Type,
          X_Segment29_Type,
          X_Segment30_Type
  );


  OPEN C;
  FETCH C INTO X_Rowid;

  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                VARCHAR2,
                   X_Variable_Id                          NUMBER,
                   X_Name                                 VARCHAR2,
                   X_Object_Name                          VARCHAR2,
                   X_Column_Label                         VARCHAR2,
                   X_Balance_Type                         VARCHAR2,
                   X_Currency_Type                        VARCHAR2,
                   X_Currency_Code                        VARCHAR2,
                   X_Id_Flex_Code                         VARCHAR2,
                   X_Id_Flex_Num                          NUMBER,
                   X_Ledger_Id                      NUMBER,
                   X_Budget_Version_Id                    NUMBER,
                   X_Encumbrance_Type_Id                  NUMBER,
                   X_Level_Code                           VARCHAR2,
                   X_Status_Code                          VARCHAR2,
                   X_Description                          VARCHAR2,
                   X_Context                              VARCHAR2,
                   X_Attribute1                           VARCHAR2,
                   X_Attribute2                           VARCHAR2,
                   X_Attribute3                           VARCHAR2,
                   X_Attribute4                           VARCHAR2,
                   X_Attribute5                           VARCHAR2,
                   X_Attribute6                           VARCHAR2,
                   X_Attribute7                           VARCHAR2,
                   X_Attribute8                           VARCHAR2,
                   X_Attribute9                           VARCHAR2,
                   X_Attribute10                          VARCHAR2,
                   X_Attribute11                          VARCHAR2,
                   X_Attribute12                          VARCHAR2,
                   X_Attribute13                          VARCHAR2,
                   X_Attribute14                          VARCHAR2,
                   X_Attribute15                          VARCHAR2,
                   X_Segment1_Type			  VARCHAR2,
		   X_Segment2_Type			  VARCHAR2,
		   X_Segment3_Type			  VARCHAR2,
		   X_Segment4_Type			  VARCHAR2,
		   X_Segment5_Type			  VARCHAR2,
		   X_Segment6_Type			  VARCHAR2,
		   X_Segment7_Type			  VARCHAR2,
		   X_Segment8_Type			  VARCHAR2,
		   X_Segment9_Type			  VARCHAR2,
		   X_Segment10_Type			  VARCHAR2,
		   X_Segment11_Type			  VARCHAR2,
		   X_Segment12_Type			  VARCHAR2,
		   X_Segment13_Type			  VARCHAR2,
		   X_Segment14_Type			  VARCHAR2,
		   X_Segment15_Type			  VARCHAR2,
		   X_Segment16_Type			  VARCHAR2,
		   X_Segment17_Type			  VARCHAR2,
		   X_Segment18_Type			  VARCHAR2,
		   X_Segment19_Type			  VARCHAR2,
		   X_Segment20_Type			  VARCHAR2,
		   X_Segment21_Type			  VARCHAR2,
		   X_Segment22_Type			  VARCHAR2,
		   X_Segment23_Type			  VARCHAR2,
		   X_Segment24_Type			  VARCHAR2,
		   X_Segment25_Type			  VARCHAR2,
		   X_Segment26_Type			  VARCHAR2,
		   X_Segment27_Type			  VARCHAR2,
		   X_Segment28_Type			  VARCHAR2,
		   X_Segment29_Type			  VARCHAR2,
		   X_Segment30_Type			  VARCHAR2
  ) IS
  CURSOR C IS
      SELECT *
      FROM   rg_dss_variables
      WHERE  rowid = X_Rowid
      FOR UPDATE of variable_id  NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (
          (Recinfo.variable_id = X_Variable_Id)
      AND (Recinfo.name = X_Name)
      AND (   (Recinfo.object_name = X_Object_Name)
           OR (    (Recinfo.object_name IS NULL)
               AND (X_Object_Name IS NULL)))
      AND (   (Recinfo.column_label = X_Column_Label)
           OR (    (Recinfo.column_label IS NULL)
               AND (X_Column_Label IS NULL)))
      AND (   (Recinfo.balance_type = X_Balance_Type)
           OR (    (Recinfo.balance_type IS NULL)
               AND (X_Balance_Type IS NULL)))
      AND (   (Recinfo.currency_type = X_Currency_Type)
           OR (    (Recinfo.currency_type IS NULL)
               AND (X_Currency_Type IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.id_flex_code = X_Id_Flex_Code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_Id_Flex_Code IS NULL)))
      AND (   (Recinfo.id_flex_num = X_Id_Flex_Num)
           OR (    (Recinfo.id_flex_num IS NULL)
               AND (X_Id_Flex_Num IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.encumbrance_type_id = X_Encumbrance_Type_Id)
           OR (    (Recinfo.encumbrance_type_id IS NULL)
               AND (X_Encumbrance_Type_Id IS NULL)))
      AND (   (Recinfo.level_code = X_Level_Code)
           OR (    (Recinfo.level_code IS NULL)
               AND (X_Level_Code IS NULL)))
      AND (   (Recinfo.status_code = X_Status_Code)
           OR (    (Recinfo.status_code IS NULL)
               AND (X_Status_Code IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.segment1_type = X_Segment1_Type)
           OR (    (Recinfo.segment1_type IS NULL)
               AND (X_Segment1_Type IS NULL)))
      AND (   (Recinfo.segment2_type = X_Segment2_Type)
           OR (    (Recinfo.segment2_type IS NULL)
               AND (X_Segment2_Type IS NULL)))
      AND (   (Recinfo.segment3_type = X_Segment3_Type)
           OR (    (Recinfo.segment3_type IS NULL)
               AND (X_Segment3_Type IS NULL)))
      AND (   (Recinfo.segment4_type = X_Segment4_Type)
           OR (    (Recinfo.segment4_type IS NULL)
               AND (X_Segment4_Type IS NULL)))
      AND (   (Recinfo.segment5_type = X_Segment5_Type)
           OR (    (Recinfo.segment5_type IS NULL)
               AND (X_Segment5_Type IS NULL)))
      AND (   (Recinfo.segment6_type = X_Segment6_Type)
           OR (    (Recinfo.segment6_type IS NULL)
               AND (X_Segment6_Type IS NULL)))
      AND (   (Recinfo.segment7_type = X_Segment7_Type)
           OR (    (Recinfo.segment7_type IS NULL)
               AND (X_Segment7_Type IS NULL)))
      AND (   (Recinfo.segment8_type = X_Segment8_Type)
           OR (    (Recinfo.segment8_type IS NULL)
               AND (X_Segment8_Type IS NULL)))
      AND (   (Recinfo.segment9_type = X_Segment9_Type)
           OR (    (Recinfo.segment9_type IS NULL)
               AND (X_Segment9_Type IS NULL)))
      AND (   (Recinfo.segment10_type = X_Segment10_Type)
           OR (    (Recinfo.segment10_type IS NULL)
               AND (X_Segment10_Type IS NULL)))
      AND (   (Recinfo.segment11_type = X_Segment11_Type)
           OR (    (Recinfo.segment11_type IS NULL)
               AND (X_Segment11_Type IS NULL)))
      AND (   (Recinfo.segment12_type = X_Segment12_Type)
           OR (    (Recinfo.segment12_type IS NULL)
               AND (X_Segment12_Type IS NULL)))
      AND (   (Recinfo.segment13_type = X_Segment13_Type)
           OR (    (Recinfo.segment13_type IS NULL)
               AND (X_Segment13_Type IS NULL)))
      AND (   (Recinfo.segment14_type = X_Segment14_Type)
           OR (    (Recinfo.segment14_type IS NULL)
               AND (X_Segment14_Type IS NULL)))
      AND (   (Recinfo.segment15_type = X_Segment15_Type)
           OR (    (Recinfo.segment15_type IS NULL)
               AND (X_Segment15_Type IS NULL)))
      AND (   (Recinfo.segment16_type = X_Segment16_Type)
           OR (    (Recinfo.segment16_type IS NULL)
               AND (X_Segment16_Type IS NULL)))
      AND (   (Recinfo.segment17_type = X_Segment17_Type)
           OR (    (Recinfo.segment17_type IS NULL)
               AND (X_Segment17_Type IS NULL)))
      AND (   (Recinfo.segment18_type = X_Segment18_Type)
           OR (    (Recinfo.segment18_type IS NULL)
               AND (X_Segment18_Type IS NULL)))
      AND (   (Recinfo.segment19_type = X_Segment19_Type)
           OR (    (Recinfo.segment19_type IS NULL)
               AND (X_Segment19_Type IS NULL)))
      AND (   (Recinfo.segment20_type = X_Segment20_Type)
           OR (    (Recinfo.segment20_type IS NULL)
               AND (X_Segment20_Type IS NULL)))
      AND (   (Recinfo.segment21_type = X_Segment21_Type)
           OR (    (Recinfo.segment21_type IS NULL)
               AND (X_Segment21_Type IS NULL)))
      AND (   (Recinfo.segment22_type = X_Segment22_Type)
           OR (    (Recinfo.segment22_type IS NULL)
               AND (X_Segment22_Type IS NULL)))
      AND (   (Recinfo.segment23_type = X_Segment23_Type)
           OR (    (Recinfo.segment23_type IS NULL)
               AND (X_Segment23_Type IS NULL)))
      AND (   (Recinfo.segment24_type = X_Segment24_Type)
           OR (    (Recinfo.segment24_type IS NULL)
               AND (X_Segment24_Type IS NULL)))
      AND (   (Recinfo.segment25_type = X_Segment25_Type)
           OR (    (Recinfo.segment25_type IS NULL)
               AND (X_Segment25_Type IS NULL)))
      AND (   (Recinfo.segment26_type = X_Segment26_Type)
           OR (    (Recinfo.segment26_type IS NULL)
               AND (X_Segment26_Type IS NULL)))
      AND (   (Recinfo.segment27_type = X_Segment27_Type)
           OR (    (Recinfo.segment27_type IS NULL)
               AND (X_Segment27_Type IS NULL)))
      AND (   (Recinfo.segment28_type = X_Segment28_Type)
           OR (    (Recinfo.segment28_type IS NULL)
               AND (X_Segment28_Type IS NULL)))
      AND (   (Recinfo.segment29_type = X_Segment29_Type)
           OR (    (Recinfo.segment29_type IS NULL)
               AND (X_Segment29_Type IS NULL)))
      AND (   (Recinfo.segment30_type = X_Segment30_Type)
           OR (    (Recinfo.segment30_type IS NULL)
               AND (X_Segment30_Type IS NULL)))
          ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END Lock_Row;


PROCEDURE Update_Row(X_Rowid                                VARCHAR2,
                     X_Variable_Id                          NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Object_Name                          VARCHAR2,
                     X_Column_Label                         VARCHAR2,
                     X_Balance_Type                         VARCHAR2,
                     X_Currency_Type                        VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Id_Flex_Code                         VARCHAR2,
                     X_Id_Flex_Num                          NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Budget_Version_Id                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Level_Code                           VARCHAR2,
                     X_Status_Code                          VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Segment1_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment2_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment3_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment4_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment5_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment6_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment7_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment8_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment9_Type             IN OUT NOCOPY     VARCHAR2,
                     X_Segment10_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment11_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment12_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment13_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment14_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment15_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment16_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment17_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment18_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment19_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment20_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment21_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment22_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment23_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment24_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment25_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment26_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment27_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment28_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment29_Type            IN OUT NOCOPY     VARCHAR2,
                     X_Segment30_Type            IN OUT NOCOPY     VARCHAR2
) IS
BEGIN

  IF (RG_DSS_VARIABLES_PKG.used_in_frozen_system(X_Variable_Id)) THEN
    -- can't modify a variable that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_VARIABLE', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  -- primarily check for summary dimension
  check_for_details(X_Variable_Id,X_Level_Code);

  IF (X_Level_Code = 'S') THEN
      generate_matching_struc( X_Variable_Id,
                               X_Id_Flex_Num,
                               X_Segment1_Type,
                               X_Segment2_Type,
                               X_Segment3_Type,
                               X_Segment4_Type,
                               X_Segment5_Type,
                               X_Segment6_Type,
                               X_Segment7_Type,
                               X_Segment8_Type,
                               X_Segment9_Type,
                               X_Segment10_Type,
                               X_Segment11_Type,
                               X_Segment12_Type,
                               X_Segment13_Type,
                               X_Segment14_Type,
                               X_Segment15_Type,
                               X_Segment16_Type,
                               X_Segment17_Type,
                               X_Segment18_Type,
                               X_Segment19_Type,
                               X_Segment20_Type,
                               X_Segment21_Type,
                               X_Segment22_Type,
                               X_Segment23_Type,
                               X_Segment24_Type,
                               X_Segment25_Type,
                               X_Segment26_Type,
                               X_Segment27_Type,
                               X_Segment28_Type,
                               X_Segment29_Type,
                               X_Segment30_Type);
  END IF;

  UPDATE rg_dss_variables
  SET
    variable_id                               =    X_Variable_Id,
    name                                      =    X_Name,
    object_name                               =    X_Object_Name,
    column_label                              =    X_Column_Label,
    balance_type                              =    X_Balance_Type,
    currency_type                             =    X_Currency_Type,
    currency_code                             =    X_Currency_Code,
    id_flex_code                              =    X_Id_Flex_Code,
    id_flex_num                               =    X_Id_Flex_Num,
    ledger_id                                 =    X_Ledger_Id,
    budget_version_id                         =    X_Budget_Version_Id,
    encumbrance_type_id                       =    X_Encumbrance_Type_Id,
    level_code                                =    X_Level_Code,
    status_code                               =    X_Status_Code,
    description                               =    X_Description,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    context                                   =    X_Context,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    segment1_type                             =    X_Segment1_Type,
    segment2_type                             =    X_Segment2_Type,
    segment3_type                             =    X_Segment3_Type,
    segment4_type                             =    X_Segment4_Type,
    segment5_type                             =    X_Segment5_Type,
    segment6_type                             =    X_Segment6_Type,
    segment7_type                             =    X_Segment7_Type,
    segment8_type                             =    X_Segment8_Type,
    segment9_type                             =    X_Segment9_Type,
    segment10_type                            =    X_Segment10_Type,
    segment11_type                            =    X_Segment11_Type,
    segment12_type                            =    X_Segment12_Type,
    segment13_type                            =    X_Segment13_Type,
    segment14_type                            =    X_Segment14_Type,
    segment15_type                            =    X_Segment15_Type,
    segment16_type                            =    X_Segment16_Type,
    segment17_type                            =    X_Segment17_Type,
    segment18_type                            =    X_Segment18_Type,
    segment19_type                            =    X_Segment19_Type,
    segment20_type                            =    X_Segment20_Type,
    segment21_type                            =    X_Segment21_Type,
    segment22_type                            =    X_Segment22_Type,
    segment23_type                            =    X_Segment23_Type,
    segment24_type                            =    X_Segment24_Type,
    segment25_type                            =    X_Segment25_Type,
    segment26_type                            =    X_Segment26_Type,
    segment27_type                            =    X_Segment27_Type,
    segment28_type                            =    X_Segment28_Type,
    segment29_type                            =    X_Segment29_Type,
    segment30_type                            =    X_Segment30_Type
    WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Variable_Id NUMBER) IS
BEGIN
  IF (RG_DSS_VARIABLES_PKG.used_in_frozen_system(X_Variable_Id)) THEN
    -- can't modify a variable that is used in a frozen system
    FND_MESSAGE.set_name('RG', 'RG_DSS_FROZEN_SYSTEM');
    FND_MESSAGE.set_token('OBJECT', 'RG_DSS_VARIABLE', TRUE);
    APP_EXCEPTION.raise_exception;
  END IF;

  DELETE FROM rg_dss_var_dimensions
  WHERE variable_id = X_Variable_Id;

  DELETE FROM rg_dss_var_selections
  WHERE variable_id = X_Variable_Id;

  DELETE FROM rg_dss_var_templates
  WHERE variable_id = X_Variable_Id;

  DELETE FROM rg_dss_variables
  WHERE  rowid = X_Rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;


END RG_DSS_VARIABLES_PKG;

/

--------------------------------------------------------
--  DDL for Package Body RG_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORTS_PKG" AS
/* $Header: rgireptb.pls 120.7 2003/10/24 23:55:27 vtreiger ship $ */

  --
  -- PRIVATE
  --
  --
  -- NAME
  --   select_row
  -- DESCRIPTION
  --   find the record in rg_reports wiht report_id which stored in recinfo
  -- PARAMETERS
  --   1. recinfo
  --
  --
  PROCEDURE select_row (recinfo IN OUT NOCOPY rg_reports%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO   recinfo
    FROM   rg_reports
    WHERE  report_id = recinfo.report_id;
  END select_row;

  --
  -- PUBLIC FUNCTIONS
  --
  --

  FUNCTION get_report_id RETURN NUMBER IS
    new_sequence_number     NUMBER;
  BEGIN
    SELECT rg_reports_s.nextval
    INTO   new_sequence_number
    FROM   dual;

    RETURN(new_sequence_number);
  END get_report_id;

  --
  -- NAME
  --   report_is_used
  --
  -- DESCRIPTION
  --   Check whether the report is used by a report request.
  --
  -- PARAMETERS
  -- 1. Report ID
  --
  FUNCTION report_is_used(cur_report_id IN NUMBER)
    RETURN BOOLEAN
  IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM dual
      WHERE NOT EXISTS
      (SELECT 1
        FROM  rg_report_requests
        WHERE report_id = cur_report_id
      );
    RETURN(FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN(TRUE);
  END report_is_used;

  --
  -- NAME
  --   report_belongs_set
  --
  -- DESCRIPTION
  --   Check whether the report is used by a report set.
  --
  -- PARAMETERS
  -- 1. Report ID
  --
  FUNCTION report_belongs_set( cur_report_id IN NUMBER)
    RETURN BOOLEAN
  IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM dual
      WHERE NOT EXISTS
      (SELECT 1
	FROM   rg_report_requests
	WHERE  report_id = cur_report_id
        AND    report_set_id IS NOT NULL
      );
    RETURN(FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN(TRUE);
  END report_belongs_set;

  --
  -- NAME
  --   check_dup_report_name
  --
  -- DESCRIPTION
  --   Checking report name uniqueness
  --
  -- PARAMETERS
  -- 1. Current application id
  -- 2. Current Report ID
  -- 3. New report name
  --
  FUNCTION check_dup_report_name(   cur_application_id IN   NUMBER,
				    cur_report_id      IN	NUMBER,
				    new_name           IN   VARCHAR2)
                  RETURN        BOOLEAN
  IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM dual
      WHERE NOT EXISTS
      (SELECT 1
        FROM   rg_reports
        WHERE  report_id <> cur_report_id
        AND    name = new_name
        AND    application_id = cur_application_id
      );
    RETURN(FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN(TRUE);
  END check_dup_report_name;

  PROCEDURE get_adhoc_prefix(X_adhoc_prefix		IN OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   if (X_adhoc_prefix is NULL) then
  	SELECT substr(meaning, 1, 16)
   	INTO   X_adhoc_prefix
   	FROM   rg_lookups
   	WHERE  LOOKUP_TYPE='FSG_ADHOC_REPORT_NAME_PREFIX'
       	AND  LOOKUP_CODE = 'ADHOC_PREFIX';
   end if;
  END get_adhoc_prefix;

  PROCEDURE Insert_Row(X_Rowid               IN OUT NOCOPY VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Report_Id             IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Name                  IN OUT NOCOPY VARCHAR2,
                     X_Report_Title                        VARCHAR2,
                     X_Security_Flag                       VARCHAR2,
                     X_Column_Set_Id                       NUMBER,
                     X_Row_Set_Id                          NUMBER,
                     X_Rounding_Option                     VARCHAR2,
                     X_Output_Option                       VARCHAR2,
                     X_Report_Display_Set_Id               NUMBER,
                     X_Content_Set_Id                      NUMBER,
                     X_Row_Order_Id                        NUMBER,
                     X_Parameter_Set_Id                    NUMBER,
                     X_Unit_Of_Measure_Id                  VARCHAR2,
                     X_Id_Flex_Code                        VARCHAR2,
                     X_Structure_Id                        NUMBER,
                     X_Segment_Override                    VARCHAR2,
                     X_Override_Alc_Ledger_Currency        VARCHAR2,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Minimum_Display_Level               NUMBER,
                     X_Description                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2
  ) IS
  CURSOR C IS SELECT rowid
              FROM rg_reports
              WHERE report_id = X_Report_Id;
  BEGIN

    IF (X_Report_Id IS NULL) THEN
      X_Report_Id := get_report_id;
    END IF;

    --
    -- Find Ad Hoc report name
    --
    IF (X_Name is NULL) THEN
      SELECT substr(meaning, 1, 16) || X_Report_Id
      INTO   X_Name
      FROM   rg_lookups
      WHERE  LOOKUP_TYPE='FSG_ADHOC_REPORT_NAME_PREFIX'
      AND    LOOKUP_CODE = 'ADHOC_PREFIX';
    ELSE
      IF (check_dup_report_name(X_Application_Id, X_Report_Id, X_Name)) THEN
        FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS');
        FND_MESSAGE.set_token('OBJECT', 'RG_REPORT', Translate=>TRUE);
        APP_EXCEPTION.raise_exception;
      END IF;
    END IF;

    INSERT INTO rg_reports(
          application_id,
          report_id,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          name,
          report_title,
          security_flag,
          column_set_id,
          row_set_id,
          rounding_option,
          output_option,
          report_display_set_id,
          content_set_id,
          row_order_id,
          parameter_set_id,
          unit_of_measure_id,
          id_flex_code,
          structure_id,
          segment_override,
          override_alc_ledger_currency,
          period_set_name,
          minimum_display_level,
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
          X_Application_Id,
          X_Report_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Creation_Date,
          X_Created_By,
          X_Name,
          X_Report_Title,
          X_Security_Flag,
          X_Column_Set_Id,
          X_Row_Set_Id,
          X_Rounding_Option,
          X_Output_Option,
          X_Report_Display_Set_Id,
          X_Content_Set_Id,
          X_Row_Order_Id,
          X_Parameter_Set_Id,
          X_Unit_Of_Measure_Id,
          X_Id_Flex_Code,
          X_Structure_Id,
          X_Segment_Override,
          X_Override_Alc_Ledger_Currency,
          X_Period_Set_Name,
          X_Minimum_Display_Level,
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
      RAISE NO_DATA_FOUND;
    end if;

    CLOSE C;

  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Application_Id                        NUMBER,
                   X_Report_Id                             NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Report_Title                          VARCHAR2,
                   X_Security_Flag                         VARCHAR2,
                   X_Column_Set_Id                         NUMBER,
                   X_Row_Set_Id                            NUMBER,
                   X_Rounding_Option                       VARCHAR2,
                   X_Output_Option                         VARCHAR2,
                   X_Report_Display_Set_Id                 NUMBER,
                   X_Content_Set_Id                        NUMBER,
                   X_Row_Order_Id                          NUMBER,
                   X_Parameter_Set_Id                      NUMBER,
                   X_Unit_Of_Measure_Id                    VARCHAR2,
                   X_Id_Flex_Code                          VARCHAR2,
                   X_Structure_Id                          NUMBER,
                   X_Segment_Override                      VARCHAR2,
                   X_Override_Alc_Ledger_Currency          VARCHAR2,
                   X_Period_Set_Name                       VARCHAR2,
                   X_Minimum_Display_Level                 NUMBER,
                   X_Description                           VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2
  ) IS
  CURSOR C IS
      SELECT *
      FROM   rg_reports
      WHERE  rowid = X_Rowid
      FOR UPDATE of Report_Id  NOWAIT;
  Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
    CLOSE C;
    if (
          (   (Recinfo.application_id = X_Application_Id)
           OR (    (Recinfo.application_id IS NULL)
               AND (X_Application_Id IS NULL)))
      AND (   (Recinfo.report_id = X_Report_Id)
           OR (    (Recinfo.report_id IS NULL)
               AND (X_Report_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.report_title = X_Report_Title)
           OR (    (Recinfo.report_title IS NULL)
               AND (X_Report_Title IS NULL)))
      AND (   (Recinfo.security_flag = X_Security_Flag)
           OR (    (Recinfo.security_flag IS NULL)
               AND (X_Security_Flag IS NULL)))
      AND (   (Recinfo.column_set_id = X_Column_Set_Id)
           OR (    (Recinfo.column_set_id IS NULL)
               AND (X_Column_Set_Id IS NULL)))
      AND (   (Recinfo.row_set_id = X_Row_Set_Id)
           OR (    (Recinfo.row_set_id IS NULL)
               AND (X_Row_Set_Id IS NULL)))
      AND (   (Recinfo.rounding_option = X_Rounding_Option)
           OR (    (Recinfo.rounding_option IS NULL)
               AND (X_Rounding_Option IS NULL)))
      AND (   (Recinfo.output_option = X_Output_Option)
           OR (    (Recinfo.output_option IS NULL)
               AND (X_Output_Option IS NULL)))
      AND (   (Recinfo.report_display_set_id = X_Report_Display_Set_Id)
           OR (    (Recinfo.report_display_set_id IS NULL)
               AND (X_Report_Display_Set_Id IS NULL)))
      AND (   (Recinfo.content_set_id = X_Content_Set_Id)
           OR (    (Recinfo.content_set_id IS NULL)
               AND (X_Content_Set_Id IS NULL)))
      AND (   (Recinfo.row_order_id = X_Row_Order_Id)
           OR (    (Recinfo.row_order_id IS NULL)
               AND (X_Row_Order_Id IS NULL)))
      AND (   (Recinfo.parameter_set_id = X_Parameter_Set_Id)
           OR (    (Recinfo.parameter_set_id IS NULL)
               AND (X_Parameter_Set_Id IS NULL)))
      AND (   (Recinfo.unit_of_measure_id = X_Unit_Of_Measure_Id)
           OR (    (Recinfo.unit_of_measure_id IS NULL)
               AND (X_Unit_Of_Measure_Id IS NULL)))
      AND (   (Recinfo.id_flex_code = X_Id_Flex_Code)
           OR (    (Recinfo.id_flex_code IS NULL)
               AND (X_Id_Flex_Code IS NULL)))
      AND (   (Recinfo.structure_id = X_Structure_Id)
           OR (    (Recinfo.structure_id IS NULL)
               AND (X_Structure_Id IS NULL)))
      AND (   (Recinfo.segment_override = X_Segment_Override)
           OR (    (Recinfo.segment_override IS NULL)
               AND (X_Segment_Override IS NULL)))
      AND (   (Recinfo.override_alc_ledger_currency = X_Override_Alc_Ledger_Currency)
           OR (    (Recinfo.override_alc_ledger_currency IS NULL)
               AND (X_Override_Alc_Ledger_Currency IS NULL)))
      AND (   (Recinfo.period_set_name = X_Period_Set_Name)
           OR (    (Recinfo.period_set_name IS NULL)
               AND (X_Period_Set_Name IS NULL)))
      AND (   (Recinfo.minimum_display_level = X_Minimum_Display_Level)
           OR (    (Recinfo.minimum_display_level IS NULL)
               AND (X_Minimum_Display_Level IS NULL)))
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
          ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Application_Id                      NUMBER,
                     X_Report_Id                           NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Name                                VARCHAR2,
                     X_Report_Title                        VARCHAR2,
                     X_Security_Flag                       VARCHAR2,
                     X_Column_Set_Id                       NUMBER,
                     X_Row_Set_Id                          NUMBER,
                     X_Rounding_Option                     VARCHAR2,
                     X_Output_Option                       VARCHAR2,
                     X_Report_Display_Set_Id               NUMBER,
                     X_Content_Set_Id                      NUMBER,
                     X_Row_Order_Id                        NUMBER,
                     X_Parameter_Set_Id                    NUMBER,
                     X_Unit_Of_Measure_Id                  VARCHAR2,
                     X_Id_Flex_Code                        VARCHAR2,
                     X_Structure_Id                        NUMBER,
                     X_Segment_Override                    VARCHAR2,
                     X_Override_Alc_Ledger_Currency        VARCHAR2,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Minimum_Display_Level               NUMBER,
                     X_Description                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2
  ) IS
  BEGIN
    UPDATE rg_reports
    SET
    application_id                         =    X_Application_Id,
    report_id                              =    X_Report_Id,
    last_update_date                       =    X_Last_Update_Date,
    last_updated_by                        =    X_Last_Updated_By,
    last_update_login                      =    X_Last_Update_Login,
    name                                   =    X_Name,
    report_title                           =    X_Report_Title,
    security_flag                          =    X_Security_Flag,
    column_set_id                          =    X_Column_Set_Id,
    row_set_id                             =    X_Row_Set_Id,
    rounding_option                        =    X_Rounding_Option,
    output_option                          =    X_Output_Option,
    report_display_set_id                  =    X_Report_Display_Set_Id,
    content_set_id                         =    X_Content_Set_Id,
    row_order_id                           =    X_Row_Order_Id,
    parameter_set_id                       =    X_Parameter_Set_Id,
    unit_of_measure_id                     =    X_Unit_Of_Measure_Id,
    id_flex_code                           =    X_Id_Flex_Code,
    structure_id                           =    X_Structure_Id,
    segment_override                       =    X_Segment_Override,
    override_alc_ledger_currency           =    X_Override_Alc_Ledger_Currency,
    period_set_name                        =    X_Period_Set_Name,
    minimum_display_level                  =    X_Minimum_Display_Level,
    description                            =    X_Description,
    context                                =    X_Context,
    attribute1                             =    X_Attribute1,
    attribute2                             =    X_Attribute2,
    attribute3                             =    X_Attribute3,
    attribute4                             =    X_Attribute4,
    attribute5                             =    X_Attribute5,
    attribute6                             =    X_Attribute6,
    attribute7                             =    X_Attribute7,
    attribute8                             =    X_Attribute8,
    attribute9                             =    X_Attribute9,
    attribute10                            =    X_Attribute10,
    attribute11                            =    X_Attribute11,
    attribute12                            =    X_Attribute12,
    attribute13                            =    X_Attribute13,
    attribute14                            =    X_Attribute14,
    attribute15                            =    X_Attribute15
    WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
	X_parameter_set_id	NUMBER(15);
  BEGIN

    SELECT nvl(parameter_set_id,-1)
    INTO   X_parameter_set_id
    FROM   rg_reports
    WHERE  rowid = X_Rowid;

    DELETE FROM rg_reports
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

    IF (X_parameter_set_id <> -1) THEN
    	DELETE FROM rg_report_parameters
    	WHERE  parameter_set_id = X_parameter_set_id;
    END IF;

  END Delete_Row;


  --
  -- NAME
  --   select_columns
  -- DESCRIPTION
  --   find report name corresponded to a report_id (currently no
  --   form is using this procedure)
  -- PARAMETERS
  --   1. Report ID
  --   2. Report name
  --
  PROCEDURE select_columns(report_id    IN       NUMBER,
                           name         IN OUT NOCOPY   VARCHAR2) IS
    recinfo rg_reports%ROWTYPE;
  BEGIN
    recinfo.report_id := report_id;
    select_row(recinfo);
    name := recinfo.name;
  END select_columns;


  -- Name
  --   contains_budget_overrides
  -- Description
  --   This function check whether a particular axis set
  --   contains one or more budget overrides
  -- Parameters
  --   1. row_set_id
  --   2. column_set_id
  --
  FUNCTION contains_budget_overrides(row_set_id    IN NUMBER,
                                     column_set_id IN NUMBER)
    RETURN BOOLEAN
  IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM dual
      WHERE NOT EXISTS
      (SELECT 1
        FROM   rg_report_axes      R_A,
               rg_report_standard_axes_b S_A
        WHERE
            (R_A.axis_set_id = row_set_id OR
             R_A.axis_set_id = column_set_id)
        AND R_A.parameter_num IS NOT NULL
        AND R_A.standard_axis_id = S_A.standard_axis_id
        AND S_A.simple_where_name = 'BUDGET'
      );
    RETURN(FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN(TRUE);
  END contains_budget_overrides;


  -- Name
  --   contains_encum_overrides
  -- Description
  --   This function check whether a particular axis set
  --   contains one or more encumbrance runtime overrides
  -- Parameters
  --   1. row_set_id
  --   2. column_set_id
  --
  FUNCTION contains_encum_overrides(row_set_id    IN NUMBER,
                                    column_set_id IN NUMBER)
    RETURN BOOLEAN
  IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM dual
      WHERE NOT EXISTS
      (SELECT 1
        FROM   rg_report_axes R_A,
               rg_report_standard_axes_b S_A
        WHERE
        (R_A.axis_set_id = row_set_id OR
         R_A.axis_set_id = column_set_id
        )
        AND R_A.parameter_num IS NOT NULL
        AND R_A.standard_axis_id = S_A.standard_axis_id
        AND S_A.simple_where_name = 'ENCUMBRANCE'
      );
    RETURN(FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN(TRUE);
  END contains_encum_overrides;


  -- Name
  --   contains_overrides
  -- Description
  --   This function check whether a particular axis set
  --   contains one or more runtime overrides
  -- Parameters
  --   1. row set name
  --   2. column set name
  --
  FUNCTION contains_overrides(row_set_id    IN NUMBER,
                              column_set_id IN NUMBER)
    RETURN BOOLEAN
  IS
    dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM dual
      WHERE NOT EXISTS
      (SELECT  1
        FROM   rg_report_axes          R_A
        WHERE
	(R_A.axis_set_id = row_set_id OR
         R_A.axis_set_id = column_set_id)
        AND R_A.parameter_num IS NOT NULL
      );
    RETURN(FALSE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN(TRUE);
  END contains_overrides;


  PROCEDURE get_overrides(
                          row_set_id               IN  NUMBER,
                          column_set_id            IN  NUMBER,
                          budget_override       IN OUT NOCOPY BOOLEAN,
                          encumbrance_override  IN OUT NOCOPY BOOLEAN,
                          currency_override     IN OUT NOCOPY BOOLEAN) IS
  BEGIN
    currency_override := contains_overrides(row_set_id, column_set_id);
    IF NOT (currency_override) THEN
      budget_override := FALSE;
      encumbrance_override := FALSE;
    ELSE
      budget_override := contains_budget_overrides(row_set_id, column_set_id);
      encumbrance_override := contains_encum_overrides(row_set_id, column_set_id);
    END IF;

  END get_overrides;


  FUNCTION find_report_segment_override(x_report_id IN NUMBER) RETURN VARCHAR2
  IS
    CURSOR report IS
      SELECT application_id, id_flex_code, structure_id,
             segment_override, override_alc_ledger_currency
      FROM   rg_reports
      WHERE  report_id = x_report_id;

    appl_id       NUMBER;
    flex_code     VARCHAR2(4);
    flex_num      NUMBER;
    seg_override  VARCHAR2(800);
    override_alc  VARCHAR2(15);

    coa_delimiter       VARCHAR2(1);
    first_delimiter_pos NUMBER;
    override_ledger_id  NUMBER;
    override_ledger     VARCHAR2(20);
    translated_flag     VARCHAR2(1);
    conv_seg_override   VARCHAR2(800);
  BEGIN
    OPEN report;
    FETCH report INTO appl_id, flex_code, flex_num,
                      seg_override, override_alc;
    CLOSE report;

    IF (seg_override IS NULL) THEN
      RETURN NULL;
    END IF;

    SELECT max(concatenated_segment_delimiter)
    INTO   coa_delimiter
    FROM   FND_ID_FLEX_STRUCTURES
    WHERE  APPLICATION_ID = appl_id
    AND    ID_FLEX_CODE = flex_code
    AND    ID_FLEX_NUM = flex_num;

    IF (coa_delimiter IS NOT NULL) THEN
      first_delimiter_pos := INSTR(seg_override, coa_delimiter);
      override_ledger_id := to_number(SUBSTR(seg_override,
                                             1, first_delimiter_pos - 1));

      IF (override_ledger_id IS NOT NULL) THEN
        GL_LEDGER_UTILS_PKG.Find_Ledger_Short_Name(
                             override_ledger_id,
                             override_alc,
                             override_ledger,
                             translated_flag);
        conv_seg_override := override_ledger ||
                             SUBSTR(seg_override,
                                    first_delimiter_pos);
      ELSE
        conv_seg_override := SUBSTR(seg_override,
                                    first_delimiter_pos);
      END IF;
    END IF;
    RETURN conv_seg_override;

  END find_report_segment_override;

END RG_REPORTS_PKG;

/

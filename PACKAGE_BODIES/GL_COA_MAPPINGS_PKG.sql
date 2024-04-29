--------------------------------------------------------
--  DDL for Package Body GL_COA_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_COA_MAPPINGS_PKG" as
/* $Header: glicoamb.pls 120.4 2005/05/05 01:04:08 kvora ship $ */
--
-- PRIVATE FUNCTIONS
--

--
-- PUBLIC FUNCTIONS
--

--** Added Security_Flag for Definition Access Set enhancement
PROCEDURE Insert_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                     X_Coa_Mapping_Id                       IN OUT NOCOPY NUMBER,
                     X_To_Coa_Id                            NUMBER,
                     X_From_Coa_Id                          NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Description                          VARCHAR2,
                     X_Start_Date_Active                    DATE,
                     X_End_Date_Active                      DATE,
                     X_Security_Flag                        VARCHAR2
) IS
   CURSOR C IS SELECT rowid FROM gl_coa_mappings
               WHERE coa_mapping_id = X_Coa_Mapping_Id;

BEGIN

  INSERT INTO gl_coa_mappings(
          coa_mapping_id,
          to_coa_id,
          from_coa_id,
          name,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          description,
          start_date_active,
          end_date_active,
          security_flag
         ) VALUES (
          X_Coa_Mapping_Id,
          X_To_Coa_Id,
          X_From_Coa_Id,
          X_Name,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Description,
          X_Start_Date_Active,
          X_End_Date_Active,
          X_Security_Flag
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

--** Added Security_Flag for Definition Access Set enhancement
PROCEDURE Lock_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                   X_Coa_Mapping_Id                       IN OUT NOCOPY NUMBER,
                   X_To_Coa_Id                            NUMBER,
                   X_From_Coa_Id                          NUMBER,
                   X_Name                                 VARCHAR2,
                   X_Description                          VARCHAR2,
                   X_Start_Date_Active                    DATE,
                   X_End_Date_Active                      DATE,
                   X_Security_Flag                        VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_coa_mappings
      WHERE  rowid = X_Rowid
      FOR UPDATE of Coa_Mapping_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.coa_mapping_id = X_Coa_Mapping_Id)
           OR (    (Recinfo.coa_mapping_id IS NULL)
               AND (X_Coa_Mapping_Id IS NULL)))
      AND (   (Recinfo.to_coa_id = X_To_Coa_Id)
           OR (    (Recinfo.to_coa_id IS NULL)
               AND (X_To_Coa_Id IS NULL)))
      AND (   (Recinfo.from_coa_id = X_From_Coa_Id)
           OR (    (Recinfo.from_coa_id IS NULL)
               AND (X_From_Coa_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.start_date_active = X_Start_Date_Active)
           OR (    (Recinfo.start_date_active IS NULL)
               AND (X_Start_Date_Active IS NULL)))
      AND (   (Recinfo.end_date_active = X_End_Date_Active)
           OR (    (Recinfo.end_date_active IS NULL)
               AND (X_End_Date_Active IS NULL)))
      AND (   (Recinfo.security_flag = X_Security_Flag)
           OR (    (Recinfo.security_flag IS NULL)
               AND (X_Security_Flag IS NULL)))
     ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

--** Added Security_Flag for Definition Access Set enhancement
PROCEDURE Update_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                     X_Coa_Mapping_Id                       IN OUT NOCOPY NUMBER,
                     X_To_Coa_Id                            NUMBER,
                     X_From_Coa_Id                          NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Description                          VARCHAR2,
                     X_Start_Date_Active                    DATE,
                     X_End_Date_Active                      DATE,
                     X_Security_Flag                        VARCHAR2
) IS
BEGIN

  UPDATE gl_coa_mappings
  SET
    coa_mapping_id                            =    X_Coa_Mapping_Id,
    to_coa_id                                 =    X_To_Coa_Id,
    from_coa_id                               =    X_From_Coa_Id,
    name                                      =    X_Name,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    description                               =    X_Description,
    start_date_active                         =    X_Start_Date_Active,
    end_date_active                           =    X_End_Date_Active,
    security_flag			      =    X_Security_Flag
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

/* Deletion is not allowed for chart of accounts mappings */

PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Coa_Mapping_Id NUMBER) IS
BEGIN
null;
/*
  -- pulled from pre_delete
  DELETE FROM GL_CONS_FLEXFIELD_MAP
  WHERE COA_MAPPING_ID = X_Coa_Mapping_Id;

  DELETE FROM GL_CONS_SEGMENT_MAP
  WHERE COA_MAPPING_ID = X_Coa_Mapping_Id;

  DELETE FROM gl_coa_mappings
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

*/
END Delete_Row;

PROCEDURE Check_Unique_Name(X_Rowid    VARCHAR2,
                            X_Name     VARCHAR2) IS
CURSOR check_dups IS
  SELECT  1
    FROM  GL_COA_MAPPINGS map
   WHERE  map.name = X_Name
     AND  ( X_Rowid is NULL
           OR map.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN check_dups;
  FETCH check_dups INTO dummy;

  IF check_dups%FOUND THEN
    CLOSE check_dups;
    fnd_message.set_name('SQLGL','GL_DUP_COA_MAPPING_NAME');
    app_exception.raise_exception;
  END IF;

  CLOSE check_dups;
END Check_Unique_Name;

PROCEDURE Check_Unique(X_Rowid               VARCHAR2,
                       X_Coa_Mapping_Id      NUMBER) IS
CURSOR C2 IS
  SELECT  1
    FROM  GL_COA_MAPPINGS map
   WHERE  map.coa_mapping_id = X_Coa_Mapping_Id
     AND  ( X_Rowid is NULL
           OR map.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN C2;
  FETCH C2 INTO dummy;

  IF C2%FOUND THEN
    CLOSE C2;
    fnd_message.set_name('SQLGL','GL_DUP_UNIQUE_ID');
    fnd_message.set_token('TAB_S','GL_COA_MAPPINGS_S');
    app_exception.raise_exception;
  END IF;

  CLOSE C2;
END Check_Unique;

PROCEDURE Check_Unmapped_Sub_Segments(X_From_Coa_Id NUMBER,
                                      X_Coa_Mapping_Id      NUMBER,
                                      X_Unmapped_Segment_Found IN OUT NOCOPY VARCHAR2) IS
CURSOR C4 IS
       SELECT 'Y'
       FROM   DUAL
       WHERE EXISTS
             ( SELECT flex.application_column_name
               FROM   FND_ID_FLEX_SEGMENTS flex
               WHERE  flex.application_id = 101
               AND    flex.id_flex_code   = 'GL#'
               AND    flex.enabled_flag   = 'Y'
               AND    flex.id_flex_num    = X_From_Coa_Id
               MINUS
               SELECT map.from_application_column_name
               FROM   GL_CONS_SEGMENT_MAP map
               WHERE  map.coa_mapping_id = X_Coa_Mapping_Id
             );

BEGIN
  OPEN C4;
  FETCH C4 INTO X_Unmapped_Segment_Found;

  IF C4%FOUND THEN
    X_Unmapped_Segment_Found := 'Y';
  ELSE
    X_Unmapped_Segment_Found := 'N';
  END IF;

  CLOSE C4;
END Check_Unmapped_Sub_Segments;

END GL_COA_MAPPINGS_PKG;

/

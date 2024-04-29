--------------------------------------------------------
--  DDL for Package Body GL_CONS_FLEX_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_FLEX_HIER_PKG" as
/* $Header: glicocrb.pls 120.7 2005/05/05 01:04:39 kvora ship $ */

--
-- PUBLIC PROCEDURES
--

FUNCTION Overlap(X_Rowid                        VARCHAR2,
                 X_Segment_Map_Id		 NUMBER,
                 X_Coa_Mapping_Id		 NUMBER,
                 X_To_Value_Set_Id		 NUMBER,
                 X_From_Value_Set_Id		 NUMBER,
                 X_Segment_Map_Type             VARCHAR2,
                 X_To_Application_Column_Name   VARCHAR2,
                 X_From_Application_Column_Name VARCHAR2,
                 X_Parent_Flex_Value            VARCHAR2,
                 X_Child_Flex_Value_Low         VARCHAR2,
                 X_Child_Flex_Value_High        VARCHAR2
) RETURN NUMBER IS

-- The first cursor catches overlaps to the same target
CURSOR C1 IS  SELECT 'Overlaps'
    FROM gl_cons_flex_hierarchies cfh, gl_cons_segment_map csm
   WHERE csm.coa_mapping_id = X_Coa_Mapping_Id
     AND csm.single_value = X_Parent_Flex_Value
     AND csm.to_value_set_id = X_To_Value_Set_Id
     AND csm.from_value_set_id = X_From_Value_Set_Id
     AND csm.to_application_column_name = X_to_application_column_name
     AND csm.from_application_column_name = X_from_application_column_name
     AND csm.segment_map_type = 'R'
     AND csm.segment_map_id = cfh.segment_map_id
     AND ((cfh.child_flex_value_low between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (cfh.child_flex_value_high between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (X_Child_Flex_Value_Low between
            cfh.child_flex_value_low and cfh.child_flex_value_high)
          OR
           (X_Child_Flex_Value_High between
            cfh.child_flex_value_low and cfh.child_flex_value_high))
     AND ROWIDTOCHAR(cfh.rowid) <> nvl(X_Rowid,'x')
    UNION
      SELECT 'Overlaps'
      FROM fnd_flex_value_hierarchies fvh, gl_cons_segment_map csm
      WHERE csm.coa_mapping_id = X_Coa_Mapping_Id
      AND csm.single_value = X_Parent_Flex_Value
      AND csm.to_value_set_id = X_To_Value_Set_Id
      AND csm.from_value_set_id = X_From_Value_Set_Id
      AND csm.to_application_column_name = X_To_Application_Column_Name
      AND csm.from_application_column_name = X_From_Application_Column_Name
      AND csm.segment_map_type = 'P'
      AND fvh.flex_value_set_id = X_From_Value_Set_Id
      AND csm.parent_rollup_value = fvh.parent_flex_value
      AND ((fvh.child_flex_value_low between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (fvh.child_flex_value_high between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (X_Child_Flex_Value_Low between
            fvh.child_flex_value_low and fvh.child_flex_value_high)
          OR
           (X_Child_Flex_Value_High between
            fvh.child_flex_value_low and fvh.child_flex_value_high))
;

-- The second cursor catches overlaps to different targets
CURSOR C2 IS  SELECT 'Overlaps'
    FROM gl_cons_flex_hierarchies cfh, gl_cons_segment_map csm
   WHERE csm.coa_mapping_id = X_Coa_Mapping_Id
     AND csm.to_value_set_id = X_To_Value_Set_Id
     AND csm.from_value_set_id = X_From_Value_Set_Id
     AND csm.to_application_column_name = X_to_application_column_name
     AND csm.from_application_column_name = X_from_application_column_name
     AND csm.segment_map_type = 'R'
     AND csm.segment_map_id = cfh.segment_map_id
     AND ((cfh.child_flex_value_low between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (cfh.child_flex_value_high between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (X_Child_Flex_Value_Low between
            cfh.child_flex_value_low and cfh.child_flex_value_high)
          OR
           (X_Child_Flex_Value_High between
            cfh.child_flex_value_low and cfh.child_flex_value_high))
     AND ROWIDTOCHAR(cfh.rowid) <> nvl(X_Rowid,'x')
    UNION
      SELECT 'Overlaps'
      FROM fnd_flex_value_hierarchies fvh, gl_cons_segment_map csm
      WHERE csm.coa_mapping_id = X_Coa_Mapping_Id
      AND csm.to_value_set_id = X_To_Value_Set_Id
      AND csm.from_value_set_id = X_From_Value_Set_Id
      AND csm.to_application_column_name = X_To_Application_Column_Name
      AND csm.from_application_column_name = X_From_Application_Column_Name
      AND csm.segment_map_type = 'P'
      AND fvh.flex_value_set_id = X_From_Value_Set_Id
      AND csm.parent_rollup_value = fvh.parent_flex_value
      AND ((fvh.child_flex_value_low between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (fvh.child_flex_value_high between
            X_Child_Flex_Value_Low and X_Child_Flex_Value_High)
          OR
           (X_Child_Flex_Value_Low between
            fvh.child_flex_value_low and fvh.child_flex_value_high)
          OR
           (X_Child_Flex_Value_High between
            fvh.child_flex_value_low and fvh.child_flex_value_high))
;

V1   VARCHAR2(21);

BEGIN
  IF ( X_Segment_Map_Type IN ( 'R', 'P' ) ) THEN
    OPEN C1;
    FETCH C1 INTO V1;
    IF (C1%FOUND) THEN
      CLOSE C1;
      fnd_message.set_name('SQLGL', 'GL_OVERLAPPING_ROLLUP_RANGES');
      app_exception.raise_exception;
    END IF;
    CLOSE C1;

    OPEN C2;
    FETCH C2 INTO V1;
    IF (C2%FOUND) THEN
      CLOSE C2;
      return(1);
    END IF;
    CLOSE C2;
  END IF;
  return(0);
END Overlap;

PROCEDURE Count_Ranges(X_Segment_Map_Id    NUMBER) IS

CURSOR C2 IS  SELECT '1' FROM gl_cons_flex_hierarchies
       WHERE  segment_map_id = X_Segment_Map_Id;

Range_Count  VARCHAR2(2);

BEGIN
  OPEN C2;
  FETCH C2 INTO Range_Count;
  IF (Range_Count < 2) THEN
    CLOSE C2;
    fnd_message.set_name('SQLGL','GL_ENTER_SEGMENT_RANGES');
    app_exception.raise_exception;
  END IF;
END Count_Ranges;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Segment_Map_Id                      IN OUT NOCOPY NUMBER,
                     X_Parent_Flex_Value                    VARCHAR2,
                     X_Child_Flex_Value_Low                 VARCHAR2,
                     X_Child_Flex_Value_High                VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Context                              VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM gl_cons_flex_hierarchies

             WHERE segment_map_id = X_Segment_Map_Id;
    CURSOR C2 IS SELECT gl_cons_segment_map_s.nextval FROM dual;
BEGIN

    if (X_Segment_Map_Id is NULL) then
       OPEN C2;
       FETCH C2 INTO X_Segment_Map_Id;
       CLOSE C2;
     end if;

  INSERT INTO gl_cons_flex_hierarchies(
          segment_map_id,
          parent_flex_value,
          child_flex_value_low,
          child_flex_value_high,
	  last_update_date,
	  last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          context
         ) VALUES (
          X_Segment_Map_Id,
          X_Parent_Flex_Value,
          X_Child_Flex_Value_Low,
          X_Child_Flex_Value_High,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Context
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
                   X_Segment_Map_Id                         NUMBER,
                   X_Parent_Flex_Value                      VARCHAR2,
                   X_Child_Flex_Value_Low                   VARCHAR2,
                   X_Child_Flex_Value_High                  VARCHAR2,
                   X_Last_Update_Date                       DATE,
                   X_Last_Updated_By                        NUMBER,
                   X_Creation_Date                          DATE,
                   X_Created_By                             NUMBER,
                   X_Last_Update_Login                      NUMBER,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Context                                VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_cons_flex_hierarchies
      WHERE  rowid = X_Rowid
      FOR UPDATE of Segment_Map_Id NOWAIT;
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
          (   (Recinfo.segment_map_id = X_Segment_Map_Id)
           OR (    (Recinfo.segment_map_id IS NULL)
               AND (X_Segment_Map_Id IS NULL)))
      AND (   (Recinfo.parent_flex_value = X_parent_flex_value)
           OR (    (Recinfo.parent_flex_value IS NULL)
               AND (X_parent_flex_value IS NULL)))
      AND (   (Recinfo.child_flex_value_low = X_child_flex_value_low)
           OR (    (Recinfo.child_flex_value_low IS NULL)
               AND (X_child_flex_value_low IS NULL)))
      AND (   (Recinfo.child_flex_value_high = X_child_flex_value_high)
           OR (    (Recinfo.child_flex_value_high IS NULL)
               AND (X_child_flex_value_high IS NULL)))
      AND (   (Recinfo.last_update_date = X_last_update_date)
           OR (    (Recinfo.last_update_date IS NULL)
               AND (X_last_update_date IS NULL)))
      AND (   (Recinfo.last_updated_by = X_last_updated_by)
           OR (    (Recinfo.last_updated_by IS NULL)
               AND (X_last_updated_by IS NULL)))
      AND (   (Recinfo.creation_date = X_creation_date)
           OR (    (Recinfo.creation_date IS NULL)
               AND (X_creation_date IS NULL)))
      AND (   (Recinfo.created_by = X_created_by)
           OR (    (Recinfo.created_by IS NULL)
               AND (X_created_by IS NULL)))
      AND (   (Recinfo.last_update_login = X_last_update_login)
           OR (    (Recinfo.last_update_login IS NULL)
               AND (X_last_update_login IS NULL)))
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
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Segment_Map_Id                         NUMBER,
                     X_Parent_Flex_Value                      VARCHAR2,
                     X_Child_Flex_Value_Low                   VARCHAR2,
                     X_Child_Flex_Value_High                  VARCHAR2,
                     X_Last_Update_Date                       DATE,
                     X_Last_Updated_By                        NUMBER,
                     X_Creation_Date                          DATE,
                     X_Created_By                             NUMBER,
                     X_Last_Update_Login                      NUMBER,
                     X_Attribute1                             VARCHAR2,
                     X_Attribute2                             VARCHAR2,
                     X_Attribute3                             VARCHAR2,
                     X_Attribute4                             VARCHAR2,
                     X_Attribute5                             VARCHAR2,
                     X_Context                                VARCHAR2
) IS
BEGIN


-- Issue check_duplicate_rules call from server instead of in client.

-- Check_Duplicate_Rules( X_Rowid,
--			  X_Single_Value,
--			  X_Consolidation_Id,
--			  X_To_Application_Column_Name,
--			  X_To_Value_Set_Id,
--			  X_Segment_Map_Type );
--

  UPDATE gl_cons_flex_hierarchies
  SET

    segment_map_id                            =    X_Segment_Map_Id,
    parent_flex_value                         =    X_Parent_Flex_Value,
    child_flex_value_low                      =    X_Child_Flex_Value_Low,
    child_flex_value_high                     =    X_Child_Flex_Value_high,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    creation_date                             =    X_Creation_Date,
    last_update_login                         =    X_Last_Update_Login,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    context                                   =    X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Update_Parent_Values(
                     X_Segment_Map_Id                         NUMBER,
                     X_Parent_Flex_Value                      VARCHAR2,
                     X_Last_Update_Date                       DATE,
                     X_Last_Updated_By                        NUMBER,
                     X_Last_Update_Login                      NUMBER
) IS
BEGIN

  UPDATE gl_cons_flex_hierarchies
  SET
    parent_flex_value                         =    X_Parent_Flex_Value,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login
  WHERE segment_map_id = X_Segment_Map_Id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Parent_Values;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Segment_Map_Id NUMBER ) IS
BEGIN

--Previously from Pre-Delete
--DELETE FROM GL_CONS_FLEX_HIERARCHIES
--WHERE SEGMENT_MAP_ID = X_Segment_Map_Id;


  DELETE FROM gl_cons_flex_hierarchies
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END GL_CONS_FLEX_HIER_PKG;

/

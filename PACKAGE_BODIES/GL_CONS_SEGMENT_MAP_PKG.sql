--------------------------------------------------------
--  DDL for Package Body GL_CONS_SEGMENT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_SEGMENT_MAP_PKG" as
/* $Header: glicosrb.pls 120.7 2005/05/05 01:06:04 kvora ship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Segment_Map_Id                      IN OUT NOCOPY NUMBER,
                     X_Coa_Mapping_Id                      NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_To_Value_Set_Id                     NUMBER,
                     X_To_Application_Column_Name          VARCHAR2,
                     X_Segment_Map_Type                    VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_From_Value_Set_Id                   NUMBER,
                     X_From_Application_Column_Name        VARCHAR2,
                     X_Single_Value                        VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Parent_Rollup_Value                 VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM gl_cons_segment_map

             WHERE segment_map_id = X_Segment_Map_Id;

    CURSOR C2 IS SELECT gl_cons_segment_map_s.nextval FROM dual;
BEGIN

-- Issue check_duplicate_rules call from server instead of in client.

--Check_Duplicate_Rules(X_Rowid,
--                      X_Single_Value,
--                      X_Parent_Rollup_Value,
--                      X_Coa_Mapping_Id,
--                      X_To_Application_Column_Name,
--                      X_From_Application_Column_Name,
--                      X_To_Value_Set_Id,
--                      X_From_Value_Set_Id,
--                      X_Segment_Map_Type );

   if (X_Segment_Map_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Segment_Map_Id;
     CLOSE C2;
   end if;
  INSERT INTO gl_cons_segment_map(
          segment_map_id,
          coa_mapping_id,
          last_update_date,
          last_updated_by,
          to_value_set_id,
          to_application_column_name,
          segment_map_type,
          creation_date,
          created_by,
          last_update_login,
          from_value_set_id,
          from_application_column_name,
          single_value,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          context,
	  parent_rollup_value
         ) VALUES (
          X_Segment_Map_Id,
          X_Coa_Mapping_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_To_Value_Set_Id,
          X_To_Application_Column_Name,
          X_Segment_Map_Type,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_From_Value_Set_Id,
          X_From_Application_Column_Name,
          X_Single_Value,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Context,
	  X_Parent_Rollup_Value
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

                   X_Segment_Map_Id                        NUMBER,
                   X_Coa_Mapping_Id                        NUMBER,
                   X_To_Value_Set_Id                       NUMBER,
                   X_To_Application_Column_Name            VARCHAR2,
                   X_Segment_Map_Type                      VARCHAR2,
                   X_From_Value_Set_Id                     NUMBER,
                   X_From_Application_Column_Name          VARCHAR2,
                   X_Single_Value                          VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Parent_Rollup_Value                   VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_cons_segment_map
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
      AND (   (Recinfo.coa_mapping_id = X_Coa_Mapping_Id)
           OR (    (Recinfo.coa_mapping_id IS NULL)
               AND (X_Coa_Mapping_Id IS NULL)))
      AND (   (Recinfo.to_value_set_id = X_To_Value_Set_Id)
           OR (    (Recinfo.to_value_set_id IS NULL)
               AND (X_To_Value_Set_Id IS NULL)))
      AND (   (Recinfo.to_application_column_name = X_To_Application_Column_Name)
           OR (    (Recinfo.to_application_column_name IS NULL)
               AND (X_To_Application_Column_Name IS NULL)))
      AND (   (Recinfo.segment_map_type = X_Segment_Map_Type)
           OR (    (Recinfo.segment_map_type IS NULL)
               AND (X_Segment_Map_Type IS NULL)))
      AND (   (Recinfo.from_value_set_id = X_From_Value_Set_Id)
           OR (    (Recinfo.from_value_set_id IS NULL)
               AND (X_From_Value_Set_Id IS NULL)))
      AND (   (Recinfo.from_application_column_name = X_From_Application_Column_Name)
           OR (    (Recinfo.from_application_column_name IS NULL)
               AND (X_From_Application_Column_Name IS NULL)))
      AND (   (Recinfo.single_value = X_Single_Value)
           OR (    (Recinfo.single_value IS NULL)
               AND (X_Single_Value IS NULL)))
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
      AND (   (Recinfo.context = X_Parent_Rollup_Value)
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
                     X_Segment_Map_Id                      NUMBER,
                     X_Coa_Mapping_Id                      NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_To_Value_Set_Id                     NUMBER,
                     X_To_Application_Column_Name          VARCHAR2,
                     X_Segment_Map_Type                    VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_From_Value_Set_Id                   NUMBER,
                     X_From_Application_Column_Name        VARCHAR2,
                     X_Single_Value                        VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Parent_Rollup_Value                 VARCHAR2
) IS
BEGIN


-- Issue check_duplicate_rules call from server instead of in client.

--Check_Duplicate_Rules(X_Rowid,
--                      X_Single_Value,
--                      X_Parent_Rollup_Value,
--                      X_Coa_Mapping_Id,
--                      X_To_Application_Column_Name,
--                      X_From_Application_Column_Name,
--                      X_To_Value_Set_Id,
--                      X_From_Value_Set_Id,
--                      X_Segment_Map_Type );

  -- The following delete statement deletes orphaned detail rows
  -- from gl_cons_flex_hierarchies table - This is introduced here
  -- because the Consolidation program insert row into
  -- GL_CONS_FLEX_HIERARCHIES table, and if the user changes the
  -- segment rule type from Parent Rollup to Detail Rollup, the
  -- corresponding rows in gl_cons_flex_hierarchies are hanging
  -- loose. Hence the delete.
  -- IF ( X_Segment_Rule_Changed  = 'Y' ) THEN
  --  DELETE FROM GL_CONS_FLEX_HIERARCHIES
  --  WHERE segment_map_id = X_Segment_Map_Id;
  -- END IF;

  UPDATE gl_cons_segment_map
  SET

    segment_map_id                            =    X_Segment_Map_Id,
    coa_mapping_id                            =    X_Coa_Mapping_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    to_value_set_id                           =    X_To_Value_Set_Id,
    to_application_column_name                =    X_To_Application_Column_Name,
    segment_map_type                          =    X_Segment_Map_Type,
    last_update_login                         =    X_Last_Update_Login,
    from_value_set_id                         =    X_From_Value_Set_Id,
    from_application_column_name              =    X_From_Application_Column_Name,
    single_value                              =    X_Single_Value,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    context                                   =    X_Context,
    parent_rollup_value                       =    X_Parent_Rollup_Value
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, X_Segment_Map_Id NUMBER ) IS
BEGIN

--Previously from Pre-Delete
DELETE FROM GL_CONS_FLEX_HIERARCHIES
WHERE SEGMENT_MAP_ID = X_Segment_Map_Id;


  DELETE FROM gl_cons_segment_map
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

FUNCTION Check_Duplicate_Rules(X_Rowid		        	VARCHAR2,
                               X_Single_Value    	        VARCHAR2,
                               X_Parent_Rollup_Value           VARCHAR2,
                               X_Coa_Mapping_Id                NUMBER,
                               X_To_Application_Column_Name    VARCHAR2,
                               X_From_Application_Column_Name  VARCHAR2,
                               X_To_Value_Set_Id               NUMBER,
                               X_From_Value_Set_Id             NUMBER,
                               X_Segment_Map_Type              VARCHAR2)
                          RETURN NUMBER IS
CURSOR DUPS1 IS
  select 'x' from gl_cons_segment_map
  where  coa_mapping_id = X_Coa_Mapping_Id
  and    to_application_column_name = X_To_Application_Column_Name
  and    to_value_set_id = X_To_Value_Set_Id
  and    segment_map_type in ('S', 'C')
  and    (rowid <> X_Rowid OR X_Rowid is NULL);

CURSOR DUPS2 IS
   select 'x' from gl_cons_segment_map
   where  coa_mapping_id = X_Coa_Mapping_id
   and    to_application_column_name = X_To_Application_Column_Name
   and    to_value_set_id = X_To_Value_Set_Id
   and    segment_map_type NOT IN ('S', 'C')
   and    (rowid <> X_Rowid OR X_Rowid is NULL);

 -- the current detail parent rules used (fvh_curr) and the new one to be added
 -- in (fvh_new) are checked for overlaps. Also, the new detail parent rule is
 -- checked against detail ranges for overlaps in the second part of the union.
 -- This only cathes overlaps with the same target specified.
 CURSOR DUPS3 IS
  select 'x'
  from gl_cons_segment_map csm,
       fnd_flex_value_hierarchies fvh_curr,
       fnd_flex_value_hierarchies fvh_new
  where  coa_mapping_id = X_Coa_Mapping_id
  and    csm.to_application_column_name = X_To_Application_Column_Name
  and    csm.to_value_set_id = X_To_Value_Set_Id
  and    single_value = X_Single_Value
  and    csm.from_application_column_name = X_from_Application_Column_Name
  and    csm.from_value_set_id = X_From_Value_Set_Id
  and    csm.segment_map_type = 'P'
  and    fvh_curr.flex_value_set_id = X_From_Value_Set_Id
  and    fvh_new.flex_value_set_id = X_From_Value_Set_Id
  and    fvh_curr.parent_flex_value = csm.parent_rollup_value
  and    fvh_new.parent_flex_value = X_Parent_Rollup_Value
  and    ((fvh_new.child_flex_value_low between
           fvh_curr.child_flex_value_low and fvh_curr.child_flex_value_high)
          OR
          (fvh_new.child_flex_value_high between
           fvh_curr.child_flex_value_low and fvh_curr.child_flex_value_high)
          OR
          (fvh_curr.child_flex_value_low between
           fvh_new.child_flex_value_low and fvh_new.child_flex_value_high)
          OR
          (fvh_curr.child_flex_value_high between
           fvh_new.child_flex_value_low and fvh_new.child_flex_value_high))
  and    (csm.rowid <> X_Rowid OR X_Rowid is NULL)
 UNION
  select 'x'
  from   gl_cons_flex_hierarchies cfh,
         gl_cons_segment_map csm,
         fnd_flex_value_hierarchies fvh
  where  csm.segment_map_id = cfh.segment_map_id
  and    csm.coa_mapping_id = X_Coa_Mapping_id
  and    single_value = X_Single_Value
  and    csm.to_application_column_name = X_To_Application_Column_Name
  and    csm.from_application_column_name = X_From_Application_Column_Name
  and    csm.to_value_set_id = X_To_Value_Set_Id
  and    csm.from_value_set_id = X_From_Value_Set_Id
  and    csm.segment_map_type = 'R'
  and    fvh.flex_value_set_id = X_From_Value_Set_Id
  and    fvh.parent_flex_value = X_Parent_Rollup_Value
  and    ((cfh.child_flex_value_low between
           fvh.child_flex_value_low and fvh.child_flex_value_high)
          OR
          (cfh.child_flex_value_high between
           fvh.child_flex_value_low and fvh.child_flex_value_high)
          OR
          (fvh.child_flex_value_low between
           cfh.child_flex_value_low and cfh.child_flex_value_high)
          OR
          (fvh.child_flex_value_high between
           cfh.child_flex_value_low and cfh.child_flex_value_high))
;

 -- the current detail parent rules used (fvh_curr) and the new one to be added
 -- in (fvh_new) are checked for overlaps. Also, the new detail parent rule is
 -- checked against detail ranges for overlaps in the second part of the union.
 -- This will catch overlaps that go to separate targets.
 CURSOR DUPS4 IS
  select 'x'
  from gl_cons_segment_map csm,
       fnd_flex_value_hierarchies fvh_curr,
       fnd_flex_value_hierarchies fvh_new
  where  coa_mapping_id = X_Coa_Mapping_id
  and    csm.to_application_column_name = X_To_Application_Column_Name
  and    csm.to_value_set_id = X_To_Value_Set_Id
  and    csm.from_application_column_name = X_from_Application_Column_Name
  and    csm.from_value_set_id = X_From_Value_Set_Id
  and    csm.segment_map_type = 'P'
  and    fvh_curr.flex_value_set_id = X_From_Value_Set_Id
  and    fvh_new.flex_value_set_id = X_From_Value_Set_Id
  and    fvh_curr.parent_flex_value = csm.parent_rollup_value
  and    fvh_new.parent_flex_value = X_Parent_Rollup_Value
  and    ((fvh_new.child_flex_value_low between
           fvh_curr.child_flex_value_low and fvh_curr.child_flex_value_high)
          OR
          (fvh_new.child_flex_value_high between
           fvh_curr.child_flex_value_low and fvh_curr.child_flex_value_high)
          OR
          (fvh_curr.child_flex_value_low between
           fvh_new.child_flex_value_low and fvh_new.child_flex_value_high)
          OR
          (fvh_curr.child_flex_value_high between
           fvh_new.child_flex_value_low and fvh_new.child_flex_value_high))
  and    (csm.rowid <> X_Rowid OR X_Rowid is NULL)
 UNION
  select 'x'
  from   gl_cons_flex_hierarchies cfh,
         gl_cons_segment_map csm,
         fnd_flex_value_hierarchies fvh
  where  csm.segment_map_id = cfh.segment_map_id
  and    csm.coa_mapping_id = X_Coa_Mapping_id
  and    csm.to_application_column_name = X_To_Application_Column_Name
  and    csm.from_application_column_name = X_From_Application_Column_Name
  and    csm.to_value_set_id = X_To_Value_Set_Id
  and    csm.from_value_set_id = X_From_Value_Set_Id
  and    csm.segment_map_type = 'R'
  and    fvh.flex_value_set_id = X_From_Value_Set_Id
  and    fvh.parent_flex_value = X_Parent_Rollup_Value
  and    ((cfh.child_flex_value_low between
           fvh.child_flex_value_low and fvh.child_flex_value_high)
          OR
          (cfh.child_flex_value_high between
           fvh.child_flex_value_low and fvh.child_flex_value_high)
          OR
          (fvh.child_flex_value_low between
           cfh.child_flex_value_low and cfh.child_flex_value_high)
          OR
          (fvh.child_flex_value_high between
           cfh.child_flex_value_low and cfh.child_flex_value_high))
;

 ROWS1   VARCHAR2(1);
 ROWS2   VARCHAR2(1);
 ROWS3   VARCHAR2(1);
 ROWS4   VARCHAR2(1);

BEGIN
     OPEN DUPS1;
     FETCH DUPS1 into ROWS1;

      IF (DUPS1%FOUND) THEN
        CLOSE DUPS1;
        fnd_message.set_name('SQLGL','GL_ONE_RULE_FOR_PARENT_SEG');
        app_exception.raise_exception;
      END IF;

    CLOSE DUPS1;

    IF ( X_Segment_Map_Type in ( 'S', 'C' ) ) THEN
      OPEN DUPS2;
      FETCH DUPS2 into ROWS2;
      IF ( DUPS2%FOUND ) THEN
	CLOSE DUPS2;
        fnd_message.set_name('SQLGL','GL_ONE_RULE_FOR_PARENT_SEG');
        app_exception.raise_exception;
      END IF;
      CLOSE DUPS2;
    END IF;

    IF ( X_Segment_Map_Type = 'P' ) THEN
      OPEN DUPS3;
      FETCH DUPS3 into ROWS3;
      IF ( DUPS3%FOUND ) THEN
	CLOSE DUPS3;
        fnd_message.set_name('SQLGL','GL_OVERLAPPING_ROLLUP_RANGES');
        app_exception.raise_exception;
      END IF;
      CLOSE DUPS3;

      OPEN DUPS4;
      FETCH DUPS4 into ROWS4;
      IF ( DUPS4%FOUND ) THEN
        CLOSE DUPS4;
        return(1);
      END IF;
    END IF;

    return(0);
END Check_Duplicate_Rules;

PROCEDURE Get_Validation_Type(X_To_Value_Set_Id          NUMBER,
                              X_Validation_Type  IN OUT NOCOPY  VARCHAR2) IS

CURSOR V_TYPE IS
  SELECT validation_type
  FROM   fnd_flex_value_sets
  WHERE  flex_value_set_id = X_To_Value_Set_Id;

BEGIN
  OPEN V_TYPE;
  FETCH V_TYPE INTO X_Validation_Type;
  IF (V_TYPE%NOTFOUND) THEN
    CLOSE V_TYPE;
    fnd_message.set_name('SQLGL','GL_INVALID_VALUE_SET_ID');
    fnd_message.set_token('VSID',to_char(X_To_Value_Set_Id));
    app_exception.raise_exception;
  END IF;
  CLOSE V_TYPE;
END Get_Validation_Type;

PROCEDURE Check_Any_Parent_Rules(X_Coa_Mapping_Id      IN OUT NOCOPY  NUMBER,
                                 X_Parent_Rules_Present  IN OUT NOCOPY  VARCHAR2) IS

CURSOR X_TYPE IS
  SELECT 'Y'
  FROM   GL_CONS_SEGMENT_MAP
  WHERE  coa_mapping_id = X_Coa_Mapping_Id
  AND    segment_map_type IN ( 'U', 'V' );

BEGIN
  OPEN X_TYPE;
  X_Parent_Rules_Present := 'N';
  FETCH X_TYPE INTO X_Parent_Rules_Present;
  IF (X_TYPE%FOUND) THEN
    X_Parent_Rules_Present := 'Y';
    CLOSE X_TYPE;
  ELSE
    X_Parent_Rules_Present := 'N';
    CLOSE X_TYPE;
  END IF;
END Check_Any_Parent_Rules;

END GL_CONS_SEGMENT_MAP_PKG;

/

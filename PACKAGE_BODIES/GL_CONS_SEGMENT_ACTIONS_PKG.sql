--------------------------------------------------------
--  DDL for Package Body GL_CONS_SEGMENT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_SEGMENT_ACTIONS_PKG" as
/* $Header: glicosab.pls 120.5 2005/05/05 01:05:50 kvora ship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Segment_Map_Id               IN OUT NOCOPY NUMBER,
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
		   X_Segment_Map_Id			   NUMBER
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
		     X_attribute1                          VARCHAR2,
		     X_attribute2                          VARCHAR2,
		     X_attribute3                          VARCHAR2,
		     X_attribute4                          VARCHAR2,
		     X_attribute5                          VARCHAR2,
		     X_context                             VARCHAR2,
		     X_parent_rollup_value                 VARCHAR2
) IS
BEGIN

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

PROCEDURE Delete_Row(X_Coa_Mapping_Id NUMBER, X_to_application_column_name VARCHAR2 ) IS
BEGIN

  DELETE FROM GL_CONS_FLEX_HIERARCHIES
  WHERE SEGMENT_MAP_ID IN ( SELECT segment_map_id
			  FROM   GL_CONS_SEGMENT_MAP
			  WHERE  coa_mapping_id = X_Coa_Mapping_id
			  AND    to_application_column_name = X_to_application_column_name
                        );

  DELETE FROM gl_cons_segment_map
  WHERE  coa_mapping_id = X_Coa_Mapping_Id
  AND    to_application_column_name = X_to_application_column_name;

  --if (SQL%NOTFOUND) then
  --  RAISE NO_DATA_FOUND;
  --end if;
END Delete_Row;

PROCEDURE Check_Duplicate_Rules(X_Rowid		        	VARCHAR2,
                                X_Single_Value    	        VARCHAR2,
                                X_Parent_Rollup_Value           VARCHAR2,
                                X_Coa_Mapping_Id                NUMBER,
                                X_To_Application_Column_Name    VARCHAR2,
                                X_From_Application_Column_Name  VARCHAR2,
                                X_To_Value_Set_Id               NUMBER,
                                X_From_Value_Set_Id             NUMBER,
                                X_Segment_Map_Type              VARCHAR2) IS
CURSOR DUPS1 IS
  select 'x' from gl_cons_segment_map
  where  coa_mapping_id = X_Coa_Mapping_id
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

 CURSOR DUPS3 IS
  select 'x' from gl_cons_segment_map
  where  coa_mapping_id = X_Coa_Mapping_id
  and    to_application_column_name = X_To_Application_Column_Name
  and    to_value_set_id = X_To_Value_Set_Id
  and    single_value = X_Single_Value
  and    from_application_column_name = X_from_Application_Column_Name
  and    from_value_set_id = X_From_Value_Set_Id
  and    parent_rollup_value = X_Parent_Rollup_Value
  and    segment_map_type = 'P'
  and    (rowid <> X_Rowid OR X_Rowid is NULL);

 ROWS1   VARCHAR2(1);
 ROWS2   VARCHAR2(1);
 ROWS3   VARCHAR2(1);

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
        fnd_message.set_name('SQLGL','GL_NO_PARENT_ROLLUP_DUPLICATES');
        app_exception.raise_exception;
      END IF;
      CLOSE DUPS3;
    END IF;

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

PROCEDURE set_criteria (X_coa_mapping_id   	  	NUMBER,
                        X_to_chart_of_accounts_id      	NUMBER,
                        X_from_chart_of_accounts_id    	NUMBER) IS
BEGIN
  GL_CONS_SEGMENT_ACTIONS_PKG.coa_mapping_id 		:= X_coa_mapping_id;
  GL_CONS_SEGMENT_ACTIONS_PKG.to_chart_of_accounts_id 	:= X_to_chart_of_accounts_id;
  GL_CONS_SEGMENT_ACTIONS_PKG.from_chart_of_accounts_id := X_from_chart_of_accounts_id;
END set_criteria;

FUNCTION Validate_From_Segment (X_from_value_set_id   NUMBER,
				X_to_value_set_id     NUMBER) RETURN BOOLEAN IS
  from_vs_max_size  NUMBER;
  to_vs_max_size    NUMBER;
BEGIN
  SELECT maximum_size
  INTO from_vs_max_size
  FROM FND_FLEX_VALUE_SETS
  WHERE flex_value_set_id = X_from_value_set_id;

  SELECT maximum_size
  INTO to_vs_max_size
  FROM FND_FLEX_VALUE_SETS
  WHERE flex_value_set_id = X_to_value_set_id;

  if (from_vs_max_size > to_vs_max_size) then
    return (FALSE);
  end if;

  -- from_vs_max_size <= to_vs_max_size
  return (TRUE);
END Validate_From_Segment;


--
-- PUBLIC FUNCTIONS
--
FUNCTION	get_coa_mapping_id	RETURN NUMBER IS
BEGIN
  RETURN GL_CONS_SEGMENT_ACTIONS_PKG.coa_mapping_id;
END get_coa_mapping_id;

FUNCTION	get_to_coa_id	RETURN NUMBER IS
BEGIN
  RETURN GL_CONS_SEGMENT_ACTIONS_PKG.to_chart_of_accounts_id;
END get_to_coa_id;

FUNCTION	get_from_coa_id	RETURN NUMBER IS
BEGIN
  RETURN GL_CONS_SEGMENT_ACTIONS_PKG.from_chart_of_accounts_id;
END get_from_coa_id;

END GL_CONS_SEGMENT_ACTIONS_PKG;

/

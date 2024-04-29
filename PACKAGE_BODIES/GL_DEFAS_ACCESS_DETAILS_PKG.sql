--------------------------------------------------------
--  DDL for Package Body GL_DEFAS_ACCESS_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DEFAS_ACCESS_DETAILS_PKG" AS
/* $Header: glistddb.pls 120.16.12010000.2 2009/06/16 05:24:51 skotakar ship $ */

  PROCEDURE get_query_component( X_Object_Type         VARCHAR2,
                                 X_Id_Column    IN OUT NOCOPY VARCHAR2,
                                 X_Name_Column  IN OUT NOCOPY VARCHAR2,
                                 X_Desc_Column  IN OUT NOCOPY VARCHAR2,
                                 X_Where_Clause IN OUT NOCOPY VARCHAR2,
                                 X_Table_Name   IN OUT NOCOPY VARCHAR2)IS
  BEGIN
    X_Name_Column := 'NAME ';
    X_Desc_Column := 'DESCRIPTION ';
    X_Where_Clause := '';
    IF(X_Object_Type = 'GL_DAS_FSG_ROW_SET')THEN
       X_Id_Column := 'to_char(AXIS_SET_ID) ';
       X_Table_Name := 'RG_REPORT_AXIS_SETS ';
       X_Where_Clause := 'WHERE AXIS_SET_TYPE = ''R''';
    ELSIF(X_Object_Type = 'GL_DAS_FSG_COLUMN_SET')THEN
       X_Id_Column := 'to_char(AXIS_SET_ID) ';
       X_Table_Name := 'RG_REPORT_AXIS_SETS ';
       X_Where_Clause := 'WHERE AXIS_SET_TYPE = ''C''';
    ELSIF(X_Object_Type = 'GL_DAS_FSG_CONTENT_SET')THEN
       X_Id_Column := 'to_char(CONTENT_SET_ID) ';
       X_Table_Name := 'RG_REPORT_CONTENT_SETS ';
    ELSIF(X_Object_Type = 'GL_DAS_FSG_ROW_ORDER')THEN
       X_Id_Column := 'to_char(ROW_ORDER_ID)';
       X_Table_Name := 'RG_ROW_ORDERS';
    ELSIF(X_Object_Type = 'GL_DAS_FSG_REPORT')THEN
       X_Id_Column := 'to_char(REPORT_ID) ';
       X_Table_Name := 'RG_REPORTS ';
    ELSIF(X_Object_Type = 'GL_DAS_FSG_REPORT_SET')THEN
       X_Id_Column := 'to_char(REPORT_SET_ID)';
       X_Table_Name := 'RG_REPORT_SETS ';
    ELSIF(X_Object_Type = 'GL_DAS_MASSALLOCATION')THEN
       X_Id_Column := 'to_char(ALLOCATION_BATCH_ID) ';
       X_Table_Name := 'GL_ALLOC_BATCHES ';
       X_Where_Clause := 'WHERE ACTUAL_FLAG IN (''A'',''E'')';
    ELSIF(X_Object_Type = 'GL_DAS_MASSBUDGET')THEN
       X_Id_Column := 'to_char(ALLOCATION_BATCH_ID) ';
       X_Table_Name := 'GL_ALLOC_BATCHES ';
       X_Where_Clause := 'WHERE ACTUAL_FLAG = ''B''';
    ELSIF(X_Object_Type = 'GL_DAS_RECURRING_JOURNAL')THEN
       X_Id_Column := 'to_char(RECURRING_BATCH_ID) ';
       X_Table_Name := 'GL_RECURRING_BATCHES ';
       X_Where_Clause := 'WHERE BUDGET_FLAG = ''N''';
    ELSIF(X_Object_Type = 'GL_DAS_BUDGET_FORMULA')THEN
       X_Id_Column := 'to_char(RECURRING_BATCH_ID) ';
       X_Table_Name := 'GL_RECURRING_BATCHES ';
       X_Where_Clause := 'WHERE BUDGET_FLAG = ''Y''';
    ELSIF(X_Object_Type = 'GL_DAS_CALENDAR')THEN
       X_Name_Column := 'PERIOD_SET_NAME';
       X_Id_Column := 'PERIOD_SET_NAME';
       X_Table_Name := 'GL_PERIOD_SETS';
    ELSIF(X_Object_Type = 'GL_DAS_AUTOPOST_SET')THEN
       X_Name_Column := 'AUTOPOST_SET_NAME';
       X_Id_Column := 'to_char(AUTOPOST_SET_ID)';
       X_Table_Name := 'GL_AUTOMATIC_POSTING_SETS';
    ELSIF(X_Object_Type = 'GL_DAS_TRANS_CAL')THEN
       X_Id_Column := 'to_char(TRANSACTION_CALENDAR_ID)';
       X_Table_Name := 'GL_TRANSACTION_CALENDAR';
    ELSIF(X_Object_Type = 'GL_DAS_RATE_TYPES')THEN
       X_Name_Column := 'USER_CONVERSION_TYPE';
       X_Id_Column := 'CONVERSION_TYPE';
       X_Table_Name := 'GL_DAILY_CONVERSION_TYPES';
    ELSIF (X_Object_Type = 'GL_DAS_REVALUATION')THEN
       X_Id_Column := 'to_char(REVALUATION_ID)';
       X_Table_Name := 'GL_REVALUATIONS';
    ELSIF(X_Object_Type = 'GL_DAS_AUTO_ALLOC_SETS')THEN
       X_Name_Column := 'ALLOCATION_SET_NAME';
       X_Id_Column := 'to_char(ALLOCATION_SET_ID)';
       X_Table_Name := 'GL_AUTO_ALLOC_SETS';
    ELSIF(X_Object_Type = 'GL_DAS_BUDGET_ORG')THEN
       X_Id_Column := 'to_char(BUDGET_ENTITY_ID)';
       X_Table_Name := 'GL_BUDGET_ENTITIES';
    ELSIF(X_Object_Type = 'GL_DAS_COA_MAPPING')THEN
       X_Id_Column := 'to_char(COA_MAPPING_ID)';
       X_Table_Name := 'GL_COA_MAPPINGS';
    ELSIF(X_Object_Type = 'GL_DAS_AUTOREVERSE_SET')THEN
       X_Name_Column := 'CRITERIA_SET_NAME';
       X_Id_Column := 'to_char(CRITERIA_SET_ID)';
       X_Desc_Column :='CRITERIA_SET_DESC';
       X_Table_Name := 'GL_AUTOREV_CRITERIA_SETS';
    ELSIF(X_Object_Type = 'GL_DAS_ELIMINATION_SET')THEN
       X_Id_Column := 'to_char(ELIMINATION_SET_ID)';
       X_Table_Name := 'GL_ELIMINATION_SETS';
    ELSIF(X_Object_Type = 'GL_DAS_CONSOLIDATION')THEN
       X_Id_Column := 'to_char(CONSOLIDATION_ID)';
       X_Table_Name := 'GL_CONSOLIDATION';
    ELSIF(X_Object_Type = 'GL_DAS_CONSOLIDATION_SET')THEN
       X_Id_Column := 'to_char(CONSOLIDATION_SET_ID)';
       X_Table_Name := 'GL_CONSOLIDATION_SETS';
    END IF;

    IF(X_Where_Clause IS NULL)THEN
       X_Where_Clause := ' WHERE SECURITY_FLAG = ''Y''';
    ELSE
       X_Where_Clause := X_Where_Clause||' AND SECURITY_FLAG = ''Y''';
    END IF;

  END get_query_component;

  FUNCTION get_object_name( X_Obj_Type VARCHAR2,
                            X_Obj_Key  VARCHAR2) RETURN VARCHAR2 IS
    id_column    VARCHAR2(50);
    name_column  VARCHAR2(30);
    desc_column  VARCHAR2(30);
    table_name   VARCHAR2(60);
    where_clause VARCHAR2(5000);
    query_stat   VARCHAR2(5000);
    name_val     VARCHAR2(30);
    c            NUMBER;
    ignore       NUMBER;
    object_name  VARCHAR2(240);
  BEGIN
    GET_QUERY_COMPONENT(
               X_Object_Type          => X_Obj_Type,
               X_Id_Column            => id_column,
               X_Name_Column          => name_column,
               X_Desc_Column          => desc_column,
               X_Table_Name           => table_name,
               X_Where_Clause         => where_clause);
    query_stat := 'SELECT '||name_column||' FROM '||table_name||
                  ' WHERE '||id_column||'= :1';
    c := dbms_sql.open_cursor;
    dbms_sql.parse(c,query_stat,dbms_sql.native);
    dbms_sql.bind_variable(c, ':1', X_Obj_Key );
    dbms_sql.define_column(c,1,name_val,30);
    ignore := dbms_sql.execute(c);
    LOOP
      IF(dbms_sql.fetch_rows(c)>0)THEN
         dbms_sql.column_value(c,1,name_val);
         object_name := name_val;
      ELSE
         EXIT;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(c);---Added for bug 8526480
    RETURN object_name;
  END get_object_name;


  FUNCTION get_object_key(  X_Obj_Type VARCHAR2,
                            X_Obj_Name  VARCHAR2) RETURN VARCHAR2 IS
    id_column    VARCHAR2(50);
    name_column  VARCHAR2(30);
    desc_column  VARCHAR2(30);
    table_name   VARCHAR2(60);
    where_clause VARCHAR2(5000);
    query_stat   VARCHAR2(5000);
    name_val     VARCHAR2(30);
    c            NUMBER;
    ignore       NUMBER;
    object_key  VARCHAR2(100);
  BEGIN
    GET_QUERY_COMPONENT(
               X_Object_Type          => X_Obj_Type,
               X_Id_Column            => id_column,
               X_Name_Column          => name_column,
               X_Desc_Column          => desc_column,
               X_Table_Name           => table_name,
               X_Where_Clause         => where_clause);
    query_stat := 'SELECT '||id_column||' FROM '||table_name||
                  ' WHERE '||name_column||'= :1';
    c := dbms_sql.open_cursor;
    dbms_sql.parse(c,query_stat,dbms_sql.native);
    dbms_sql.bind_variable(c, ':1', X_Obj_Name);
    dbms_sql.define_column(c,1,name_val,30);
    ignore := dbms_sql.execute(c);
    LOOP
      IF(dbms_sql.fetch_rows(c)>0)THEN
         dbms_sql.column_value(c,1,name_val);
         object_key := name_val;
      ELSE
         EXIT;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(c);---Added for bug 8526480
    RETURN object_key;
  END get_object_key;

  PROCEDURE secure_object (X_Obj_Type VARCHAR2,
                           X_Obj_Key  VARCHAR2) IS
    id_column    VARCHAR2(50);
    name_column  VARCHAR2(30);
    desc_column  VARCHAR2(30);
    table_name   VARCHAR2(60);
    where_clause VARCHAR2(5000);
    query_stat   VARCHAR2(5000);
    update_stat  VARCHAR2(5000);
    securityFlag VARCHAR2(1);
    c            NUMBER;
    ignore       NUMBER;
    rowid        VARCHAR2(1000);
    defasId      NUMBER(15);
    luser_id     NUMBER;
    llogin_id    NUMBER;
    CURSOR super_defas IS
    select definition_access_set_id
    from gl_defas_access_sets
    where definition_access_set = 'SUPER_USER_DEFAS';

  BEGIN
    GET_QUERY_COMPONENT(
               X_Object_Type          => X_Obj_Type,
               X_Id_Column            => id_column,
               X_Name_Column          => name_column,
               X_Desc_Column          => desc_column,
               X_Table_Name           => table_name,
               X_Where_Clause         => where_clause);
    query_stat := 'SELECT security_flag FROM '||table_name||
		  ' WHERE to_char('||id_column||')= :1';
    c := dbms_sql.open_cursor;
    dbms_sql.parse(c,query_stat,dbms_sql.native);
    dbms_sql.bind_variable(c, ':1', X_Obj_Key);
    dbms_sql.define_column(c,1,securityFlag,1);
    ignore := dbms_sql.execute(c);
    LOOP
      IF(dbms_sql.fetch_rows(c)>0)THEN
         dbms_sql.column_value(c,1,securityFlag);
      ELSE
         EXIT;
      END IF;
    END LOOP;

    dbms_sql.close_cursor(c);---Added for bug 8526480

    luser_id := FND_GLOBAL.User_Id;
    llogin_id := FND_GLOBAL.Login_Id;
    IF(securityFlag = 'N') THEN
       update_stat := 'UPDATE '||table_name||' SET security_flag = ''Y'''||
                      ' WHERE to_char('||id_column||')= :1';
       c := dbms_sql.open_cursor;
       dbms_sql.parse(c,update_stat,dbms_sql.native);
       dbms_sql.bind_variable(c, ':1', X_Obj_Key);
       ignore := dbms_sql.execute(c);

       OPEN super_defas;
       FETCH super_defas INTO defasId;
       if (super_defas%NOTFOUND) then
          CLOSE super_defas;
          RAISE NO_DATA_FOUND;
       end if;
       CLOSE super_defas;

       Insert_Row(rowid,
	  	  defasId,
		  X_Obj_Type,
		  X_Obj_Key,
		  'Y',
		  'Y',
		  'Y',
		  luser_id,
		  llogin_id,
 		  sysdate,
		  'I',
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL);

    END IF;
    dbms_sql.close_cursor(c);---Added for bug 8526480
  END secure_object;

  PROCEDURE Insert_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id  NUMBER,
                       X_Object_Type               VARCHAR2,
                       X_Object_Key                VARCHAR2,
                       X_View_Access_Flag          VARCHAR2,
                       X_Use_Access_Flag            VARCHAR2,
                       X_Modify_Access_Flag        VARCHAR2,
                       X_User_Id                   NUMBER,
                       X_Login_Id                  NUMBER,
                       X_Date                      DATE,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL,
                       X_Request_Id                NUMBER)IS

     CURSOR C IS
       SELECT rowid
       FROM gl_defas_assignments
       WHERE definition_access_set_id = X_Definition_Access_Set_Id
       AND   object_type = X_Object_Type
       AND   object_key = X_Object_Key;
  BEGIN
     INSERT INTO gl_defas_assignments
     (definition_access_set_id,
      object_type,
      object_key,
      view_access_flag,
      use_access_flag,
      modify_access_flag,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      status_code,
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
      request_id)
     VALUES
     (X_Definition_Access_Set_Id,
      X_Object_Type,
      X_Object_Key,
      X_View_Access_Flag,
      X_Use_Access_Flag,
      X_Modify_Access_Flag,
      X_Date,
      X_User_Id,
      X_Date,
      X_User_Id,
      X_Login_Id,
      X_Status_Code,
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
      X_Request_Id);

     OPEN C;
     FETCH C INTO X_Rowid;
     if (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
     end if;
     CLOSE C;
  END Insert_Row;

  PROCEDURE Update_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_View_Access_Flag          VARCHAR2,
                       X_Use_Access_Flag            VARCHAR2,
                       X_Modify_Access_Flag        VARCHAR2,
                       X_Last_Update_Date          DATE,
                       X_Last_Updated_By           NUMBER,
                       X_Last_Update_Login         NUMBER,
                       X_Request_Id                NUMBER,
                       X_Status_Code               VARCHAR2,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL) IS
  BEGIN
  UPDATE gl_defas_assignments
  SET view_access_flag = X_View_Access_Flag,
      use_access_flag = X_Use_Access_Flag,
      modify_access_flag = X_Modify_Access_Flag,
      last_update_date = X_Last_Update_Date,
      last_updated_by = X_Last_Updated_By,
      last_update_login = X_Last_Update_Login,
      request_id = X_Request_Id,
      status_code = X_Status_Code,
      context = X_Context,
      attribute1 = X_Attribute1,
      attribute2 = X_Attribute2,
      attribute3 = X_Attribute3,
      attribute4 = X_Attribute4,
      attribute5 = X_Attribute5,
      attribute6 = X_Attribute6,
      attribute7 = X_Attribute7,
      attribute8 = X_Attribute8,
      attribute9 = X_Attribute9,
      attribute10 = X_Attribute10,
      attribute11 = X_Attribute11,
      attribute12 = X_Attribute12,
      attribute13 = X_Attribute13,
      attribute14 = X_Attribute14,
      attribute15 = X_Attribute15
  WHERE rowid = X_Rowid;

  if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
  end if;

  END Update_Row;


  PROCEDURE Lock_Row(
                       X_Rowid              IN OUT NOCOPY VARCHAR2,
                       X_Definition_Access_Set_Id  NUMBER,
                       X_Object_Type               VARCHAR2,
                       X_Object_Key                VARCHAR2,
                       X_View_Access_Flag          VARCHAR2,
                       X_Use_Access_Flag            VARCHAR2,
                       X_Modify_Access_Flag        VARCHAR2,
                       X_Last_Update_Date          DATE,
                       X_Last_Updated_By           NUMBER,
                       X_Creation_Date             DATE,
                       X_Created_By                NUMBER,
                       X_Last_Update_Login         NUMBER,
                       X_Status_Code               VARCHAR2 DEFAULT NULL,
                       X_Context                   VARCHAR2 DEFAULT NULL,
                       X_Attribute1                VARCHAR2 DEFAULT NULL,
                       X_Attribute2                VARCHAR2 DEFAULT NULL,
                       X_Attribute3                VARCHAR2 DEFAULT NULL,
                       X_Attribute4                VARCHAR2 DEFAULT NULL,
                       X_Attribute5                VARCHAR2 DEFAULT NULL,
                       X_Attribute6                VARCHAR2 DEFAULT NULL,
                       X_Attribute7                VARCHAR2 DEFAULT NULL,
                       X_Attribute8                VARCHAR2 DEFAULT NULL,
                       X_Attribute9                VARCHAR2 DEFAULT NULL,
                       X_Attribute10               VARCHAR2 DEFAULT NULL,
                       X_Attribute11               VARCHAR2 DEFAULT NULL,
                       X_Attribute12               VARCHAR2 DEFAULT NULL,
                       X_Attribute13               VARCHAR2 DEFAULT NULL,
                       X_Attribute14               VARCHAR2 DEFAULT NULL,
                       X_Attribute15               VARCHAR2 DEFAULT NULL,
                       X_Request_Id                NUMBER )IS
     CURSOR C IS
       SELECT *
       FROM gl_defas_assignments
       WHERE rowid = X_Rowid
       FOR UPDATE of Definition_Access_Set_Id NOWAIT;
     Recinfo C%ROWTYPE;
     l_request_id     NUMBER(15);
     l_call_status    BOOLEAN;
     l_rphase         VARCHAR2(80);
     l_rstatus        VARCHAR2(80);
     l_dphase         VARCHAR2(30);
     l_dstatus        VARCHAR2(30);
     l_message        VARCHAR2(240);
  BEGIN
     IF(X_Request_Id IS NOT NULL) THEN
        l_request_id := X_Request_Id;
        l_call_status :=
        FND_CONCURRENT.GET_REQUEST_STATUS(request_id     => l_request_id,
                                          appl_shortname => 'SQLGL',
                                          program        => 'GL',
                                          phase          => l_rphase,
                                          status         => l_rstatus,
                                          dev_phase      => l_dphase,
                                          dev_status     => l_dstatus,
                                          message        => l_message);

        IF (l_dphase = 'RUNNING') THEN
            FND_MESSAGE.Set_Name('GL', 'GL_LEDGER_RECORD_PROC_BY_FLAT');
            APP_EXCEPTION.Raise_Exception;
        END IF;
     END IF;

     OPEN C;
     FETCH C INTO Recinfo;
     if (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
     end if;
     CLOSE C;
     if (
           (   (Recinfo.definition_access_set_id = X_Definition_Access_Set_Id)
            OR (    (Recinfo.definition_access_set_id IS NULL)
                AND (X_Definition_Access_Set_Id IS NULL)))
       AND (   (Recinfo.object_type = X_Object_Type)
            OR (    (Recinfo.object_type IS NULL)
                AND (X_Object_Type IS NULL)))
       AND (   (Recinfo.object_key = X_Object_Key)
            OR (    (Recinfo.object_key IS NULL)
                AND (X_Object_Key IS NULL)))
       AND (   (Recinfo.view_access_flag = X_View_Access_Flag)
            OR (    (Recinfo.view_access_flag IS NULL)
                AND (X_View_Access_Flag IS NULL)))
       AND (   (Recinfo.use_access_flag = X_Use_Access_Flag)
            OR (    (Recinfo.use_access_flag IS NULL)
                AND (X_Use_Access_Flag IS NULL)))
       AND (   (Recinfo.modify_access_flag = X_Modify_Access_Flag)
            OR (    (Recinfo.modify_access_flag IS NULL)
                AND (X_Modify_Access_Flag IS NULL)))
       AND (   (Recinfo.last_update_date = X_Last_Update_Date)
            OR (    (Recinfo.last_update_date IS NULL)
                AND (X_Last_Update_Date IS NULL)))
       AND (   (Recinfo.last_updated_by = X_Last_Updated_By)
            OR (    (Recinfo.last_updated_by IS NULL)
                AND (X_Last_Updated_By IS NULL)))
       AND (   (Recinfo.creation_date = X_Creation_Date)
            OR (    (Recinfo.creation_date is NULL)
                AND (X_Creation_Date IS NULL)))
       AND (   (Recinfo.created_by = X_Created_By)
            OR (    (Recinfo.created_by IS NULL)
                AND (X_Created_By IS NULL)))
       AND (   (Recinfo.last_update_login = X_Last_Update_Login)
            OR (    (Recinfo.last_update_login IS NULL)
                AND (X_Last_Update_Login IS NULL)))
       AND (   (Recinfo.status_code = X_Status_Code)
            OR (    (Recinfo.status_code IS NULL)
                AND (X_Status_Code IS NULL)))
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
       AND (   (Recinfo.request_id =  X_Request_Id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (X_Request_Id IS NULL)))
    ) then
       return;
    else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

  PROCEDURE Delete_Row(X_Rowid       VARCHAR2,
                       X_Status_Code VARCHAR2) IS
  BEGIN
    if( X_Status_Code = 'D') then
       UPDATE GL_DEFAS_ASSIGNMENTS
       SET status_code = 'D'
       WHERE rowid = X_Rowid;
    else
       DELETE FROM gl_defas_assignments
       WHERE rowid = X_Rowid;
    end if;

    if SQL%NOTFOUND then
      RAISE NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE check_unique_name(X_Definition_Access_Set_Id  NUMBER,
                            X_Object_Type  VARCHAR2,
                            X_Object_Key   VARCHAR2 ) IS

    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   GL_DEFAS_ASSIGNMENTS a
      WHERE  a.object_type = X_Object_Type
      AND    a.object_key = X_Object_Key
      AND    a.definition_access_set_id = X_Definition_Access_Set_Id
      AND    (a.status_code <> 'D' or a.status_code is null);

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DEFAS_ASSIGN_DUPLICATE' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_DEFAS_ACCESS_DETAILS_PKG.check_unique_name');
      RAISE;
  END check_unique_name;

FUNCTION submit_conc_request RETURN NUMBER
IS
result         NUMBER :=-1;
BEGIN
    -- Submit the request to run Rate Change concurrent program
    result     := FND_REQUEST.submit_request (
                            'SQLGL','GLDASF','','',FALSE,
                  	    'OA','Y',chr(0),
                            '','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','',
                            '','','','','','','','','','');

    return(result);

END submit_conc_request;


END gl_defas_access_details_pkg;

/

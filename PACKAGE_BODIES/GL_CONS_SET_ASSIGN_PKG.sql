--------------------------------------------------------
--  DDL for Package Body GL_CONS_SET_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONS_SET_ASSIGN_PKG" as
/* $Header: glicomab.pls 120.3 2005/05/05 01:05:22 kvora ship $ */

--
-- PUBLIC PROCEDURES
--

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Consolidation_Id             IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     x_Last_Update_Login                   NUMBER,
                     X_Context                             VARCHAR2,
                     X_Child_Cons_Set_Id                   NUMBER,
                     X_attribute1                          VARCHAR2,
                     X_attribute2                          VARCHAR2,
                     X_attribute3                          VARCHAR2,
                     X_attribute4                          VARCHAR2,
                     X_attribute5                          VARCHAR2,
                     X_attribute6                          VARCHAR2,
                     X_attribute7                          VARCHAR2,
                     X_attribute8                          VARCHAR2,
                     X_attribute9                          VARCHAR2,
                     X_attribute10                         VARCHAR2,
                     X_attribute11                         VARCHAR2,
                     X_attribute12                         VARCHAR2,
                     X_attribute13                         VARCHAR2,
                     X_attribute14                         VARCHAR2,
                     X_attribute15                         VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_CONS_SET_ASSIGNMENTS
             WHERE consolidation_set_id = X_Consolidation_Set_Id;
BEGIN

  INSERT INTO GL_CONS_SET_ASSIGNMENTS(
          consolidation_set_id,
          consolidation_id,
	  last_update_date,
	  last_updated_by,
          creation_date,
          created_by,
          last_update_login,
	  child_consolidation_set_id,
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
          X_Consolidation_Set_Id,
          X_Consolidation_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
	  X_child_cons_set_id,
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

PROCEDURE Update_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Consolidation_Id             IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Context                             VARCHAR2,
		     X_Child_Cons_Set_Id                   NUMBER,
                     X_attribute1                          VARCHAR2,
                     X_attribute2                          VARCHAR2,
                     X_attribute3                          VARCHAR2,
                     X_attribute4                          VARCHAR2,
                     X_attribute5                          VARCHAR2,
                     X_attribute6                          VARCHAR2,
                     X_attribute7                          VARCHAR2,
                     X_attribute8                          VARCHAR2,
                     X_attribute9                          VARCHAR2,
                     X_attribute10                         VARCHAR2,
                     X_attribute11                         VARCHAR2,
                     X_attribute12                         VARCHAR2,
                     X_attribute13                         VARCHAR2,
                     X_attribute14                         VARCHAR2,
                     X_attribute15                         VARCHAR2
) IS

BEGIN

  UPDATE GL_CONS_SET_ASSIGNMENTS
  SET
    consolidation_set_id        =   X_Consolidation_Set_Id,
    consolidation_id            =   X_Consolidation_Id,
    last_update_date            =   X_Last_Update_Date,
    last_updated_by             =   X_Last_Updated_By,
    creation_date               =   X_Creation_Date,
    created_by                  =   X_Created_By,
    last_update_login           =   X_Last_Update_Login,
    child_consolidation_set_id  =   X_child_cons_set_id,
    context                     =   X_Context,
    attribute1                  =   X_attribute1 ,
    attribute2                  =   X_attribute2 ,
    attribute3                  =   X_attribute3 ,
    attribute4                  =   X_attribute4 ,
    attribute5                  =   X_attribute5 ,
    attribute6                  =   X_attribute6 ,
    attribute7                  =   X_attribute7 ,
    attribute8                  =   X_attribute8 ,
    attribute9                  =   X_attribute9 ,
    attribute10                 =   X_attribute10,
    attribute11                 =   X_attribute11,
    attribute12                 =   X_attribute12,
    attribute13                 =   X_attribute13,
    attribute14                 =   X_attribute14,
    attribute15                 =   X_attribute15
  WHERE rowid = X_rowid;

  IF ( SQL%NOTFOUND ) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

PROCEDURE   Lock_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Consolidation_Id             IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Context                             VARCHAR2,
                     X_attribute1                          VARCHAR2,
                     X_attribute2                          VARCHAR2,
                     X_attribute3                          VARCHAR2,
                     X_attribute4                          VARCHAR2,
                     X_attribute5                          VARCHAR2,
                     X_attribute6                          VARCHAR2,
                     X_attribute7                          VARCHAR2,
                     X_attribute8                          VARCHAR2,
                     X_attribute9                          VARCHAR2,
                     X_attribute10                         VARCHAR2,
                     X_attribute11                         VARCHAR2,
                     X_attribute12                         VARCHAR2,
                     X_attribute13                         VARCHAR2,
                     X_attribute14                         VARCHAR2,
                     X_attribute15                         VARCHAR2
 ) IS
   CURSOR C IS SELECT * FROM GL_CONS_SET_ASSIGNMENTS
             WHERE rowid = X_Rowid
             FOR UPDATE of consolidation_set_id NOWAIT;
   Recinfo C%ROWTYPE;

BEGIN

  OPEN C;

  FETCH C INTO Recinfo;

  IF ( C%NOTFOUND ) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE C;

  IF (
	   (  Recinfo.consolidation_set_id = X_Consolidation_Set_id
              OR ( ( Recinfo.consolidation_set_id IS NULL )
              AND  ( X_Consolidation_Set_Id IS NULL ) ) )
       AND (  Recinfo.consolidation_id = X_Consolidation_id
              OR ( ( Recinfo.consolidation_id IS NULL )
              AND  ( X_Consolidation_id IS NULL ) ) )
       AND (  Recinfo.creation_date = X_Creation_Date
              OR ( ( Recinfo.creation_date IS NULL )
              AND  ( X_Creation_Date IS NULL ) ) )
       AND (  Recinfo.created_by = X_Created_By
              OR ( ( Recinfo.created_by IS NULL )
              AND  ( X_Created_By IS NULL ) ) )
       AND (  Recinfo.last_update_date = X_Last_Update_Date
              OR ( ( Recinfo.last_update_date IS NULL )
              AND  ( X_Last_Update_Date IS NULL ) ) )
       AND (  Recinfo.last_updated_by = X_Last_Updated_By
              OR ( ( Recinfo.last_updated_by IS NULL )
              AND  ( X_Last_Updated_By IS NULL ) ) )
       AND (  Recinfo.last_update_login = X_Last_Update_Login
              OR ( ( Recinfo.last_update_login IS NULL )
              AND  ( X_Last_Update_Login IS NULL ) ) )
       AND (  Recinfo.context = X_Context
              OR ( ( Recinfo.context IS NULL )
              AND  ( X_Context IS NULL ) ) )
       AND (  Recinfo.attribute1 = X_Attribute1
              OR ( ( Recinfo.attribute1 IS NULL )
              AND  ( X_Attribute1 IS NULL ) ) )
       AND (  Recinfo.attribute2 = X_Attribute2
              OR ( ( Recinfo.attribute2 IS NULL )
              AND  ( X_Attribute2 IS NULL ) ) )
       AND (  Recinfo.attribute3 = X_Attribute3
              OR ( ( Recinfo.attribute3 IS NULL )
              AND  ( X_Attribute3 IS NULL ) ) )
       AND (  Recinfo.attribute4 = X_Attribute4
              OR ( ( Recinfo.attribute4 IS NULL )
              AND  ( X_Attribute4 IS NULL ) ) )
       AND (  Recinfo.attribute5 = X_Attribute5
              OR ( ( Recinfo.attribute5 IS NULL )
              AND  ( X_Attribute5 IS NULL ) ) )
       AND (  Recinfo.attribute6 = X_Attribute6
              OR ( ( Recinfo.attribute6 IS NULL )
              AND  ( X_Attribute6 IS NULL ) ) )
       AND (  Recinfo.attribute7 = X_Attribute7
              OR ( ( Recinfo.attribute7 IS NULL )
              AND  ( X_Attribute7 IS NULL ) ) )
       AND (  Recinfo.attribute8 = X_Attribute8
              OR ( ( Recinfo.attribute8 IS NULL )
              AND  ( X_Attribute8 IS NULL ) ) )
       AND (  Recinfo.attribute9 = X_Attribute9
              OR ( ( Recinfo.attribute9 IS NULL )
              AND  ( X_Attribute9 IS NULL ) ) )
       AND (  Recinfo.attribute10 = X_Attribute10
              OR ( ( Recinfo.attribute10 IS NULL )
              AND  ( X_Attribute10 IS NULL ) ) )
       AND (  Recinfo.attribute11 = X_Attribute11
              OR ( ( Recinfo.attribute11 IS NULL )
              AND  ( X_Attribute11 IS NULL ) ) )
       AND (  Recinfo.attribute12 = X_Attribute12
              OR ( ( Recinfo.attribute12 IS NULL )
              AND  ( X_Attribute12 IS NULL ) ) )
       AND (  Recinfo.attribute13 = X_Attribute13
              OR ( ( Recinfo.attribute13 IS NULL )
              AND  ( X_Attribute13 IS NULL ) ) )
       AND (  Recinfo.attribute14 = X_Attribute14
              OR ( ( Recinfo.attribute14 IS NULL )
              AND  ( X_Attribute14 IS NULL ) ) )
       AND (  Recinfo.attribute15 = X_Attribute15
              OR ( ( Recinfo.attribute15 IS NULL )
              AND  ( X_Attribute15 IS NULL ) ) )
     ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name( 'FND', 'FORM_RECORD_CHANGED' );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END Lock_Row;

PROCEDURE Delete_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER,
                     X_Consolidation_Id             IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Context                              VARCHAR2
 ) IS
BEGIN

  DELETE FROM GL_CONS_SET_ASSIGNMENTS
  WHERE  rowid = X_Rowid;

  IF ( SQL%NOTFOUND ) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

PROCEDURE Delete_All_Child_Rows( X_Consolidation_Set_Id         IN OUT NOCOPY NUMBER) IS
BEGIN

  DELETE FROM GL_CONS_SET_ASSIGNMENTS
  WHERE  consolidation_set_id = X_Consolidation_Set_Id;

END Delete_All_Child_Rows;

PROCEDURE Check_Unique_Name(X_Rowid    			IN OUT NOCOPY VARCHAR2,
                            X_Consolidation_Set_Id      IN OUT NOCOPY NUMBER,
			    X_Consolidation_Id          IN OUT NOCOPY NUMBER ) IS
CURSOR check_dups IS
  SELECT  1
    FROM  GL_CONS_SET_ASSIGNMENTS gla
   WHERE  gla.consolidation_set_id = X_Consolidation_Set_Id
     AND  gla.consolidation_id     = X_consolidation_id
     AND  ( X_Rowid is NULL
           OR gla.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN check_dups;
  FETCH check_dups INTO dummy;

  IF check_dups%FOUND THEN
    CLOSE check_dups;
    fnd_message.set_name('SQLGL','GL_DUP_CONSOLIDATION_NAME');
    app_exception.raise_exception;
  END IF;

  CLOSE check_dups;
END Check_Unique_Name;


END GL_CONS_SET_ASSIGN_PKG;

/

--------------------------------------------------------
--  DDL for Package PJI_MT_ROWSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_MT_ROWSET_PKG" AUTHID CURRENT_USER AS
/* $Header: PJIMTRSS.pls 120.1 2005/05/31 08:01:59 appldev  $ */

PROCEDURE LOCK_ROW (
  p_rowset_code           IN pji_mt_rowset_b.rowset_code%TYPE,
  p_object_version_number IN pji_mt_rowset_b.object_version_number%TYPE
);


PROCEDURE DELETE_ROW (
  p_rowset_code IN 	pji_mt_rowset_b.rowset_code%TYPE
);


PROCEDURE Insert_Row (
 X_Rowid                        IN  OUT NOCOPY  ROWID,
 X_rowset_Code                  IN      pji_mt_rowset_b.Rowset_Code%TYPE,
 X_Object_Version_Number        IN      pji_mt_rowset_b.Object_Version_Number%TYPE,
 X_Name                         IN      pji_mt_rowset_Tl.Name%TYPE,
 X_Description                  IN      pji_mt_rowset_Tl.Description%TYPE,
 X_Last_Update_Date             IN      pji_mt_rowset_b.Last_Update_Date%TYPE,
 X_Last_Updated_by              IN      pji_mt_rowset_b.Last_Updated_by%TYPE,
 X_Creation_Date                IN      pji_mt_rowset_b.Creation_Date%TYPE,
 X_Created_By                   IN      pji_mt_rowset_b.Created_By%TYPE,
 X_Last_Update_Login            IN      pji_mt_rowset_b.Last_Update_Login%TYPE,
 X_Return_Status	           OUT NOCOPY      VARCHAR2,
 X_Msg_Data                        OUT NOCOPY      VARCHAR2,
 X_Msg_Count                       OUT NOCOPY      NUMBER
);


PROCEDURE Update_Row (
     X_Rowset_Code                     IN      pji_mt_rowset_b.Rowset_Code%TYPE,
     X_Object_Version_Number           IN      pji_mt_rowset_b.Object_Version_Number%TYPE,
     X_Name                            IN      pji_mt_rowset_Tl.Name%TYPE,
     X_Description                     IN      pji_mt_rowset_Tl.Description%TYPE,
     X_Last_Update_Date                IN      pji_mt_rowset_b.Last_Update_Date%TYPE,
     X_Last_Updated_by                 IN      pji_mt_rowset_b.Last_Updated_by%TYPE,
     X_Last_Update_Login               IN      pji_mt_rowset_b.Last_Update_Login%TYPE,
     X_Lock_Flag                       IN      VARCHAR2 DEFAULT 'true',
     X_Return_Status	               OUT NOCOPY      VARCHAR2,
     X_Msg_Data                        OUT NOCOPY      VARCHAR2,
     X_Msg_Count                       OUT NOCOPY      NUMBER
);


PROCEDURE Load_Row (
    X_Rowset_Code               IN     pji_mt_rowset_b.Rowset_Code%TYPE,
    X_Object_Version_Number     IN     pji_mt_rowset_b.Object_Version_Number%TYPE,
    X_Name                      IN     pji_mt_rowset_Tl.Name%TYPE,
    X_Description               IN     pji_mt_rowset_Tl.Description%TYPE,
    X_Owner                     IN     VARCHAR2
);

PROCEDURE Add_Language;

PROCEDURE Translate_Row (
  X_rowset_code                   IN pji_mt_rowset_b.rowset_code%TYPE,
  X_OWNER                         IN VARCHAR2 ,
  X_NAME                          IN pji_mt_rowset_TL.NAME%TYPE,
  X_DESCRIPTION                   IN  pji_mt_rowset_TL.DESCRIPTION%TYPE
 );

END PJI_MT_ROWSET_PKG;

 

/

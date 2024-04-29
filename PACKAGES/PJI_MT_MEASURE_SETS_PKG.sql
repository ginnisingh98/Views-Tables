--------------------------------------------------------
--  DDL for Package PJI_MT_MEASURE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_MT_MEASURE_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: PJIMTMSS.pls 120.1 2005/05/31 08:01:30 appldev  $ */

G_RET_STS_ERROR		VARCHAR2(1):='E';

PROCEDURE LOCK_ROW (
  p_measure_set_code       IN pji_mt_measure_sets_b.measure_set_code%TYPE,
  p_object_version_number IN pji_mt_measure_sets_b.object_version_number%TYPE
);

PROCEDURE DELETE_ROW (
  p_measure_set_code IN 	pji_mt_measure_sets_b.measure_set_code%TYPE
);

PROCEDURE Insert_Row (
 X_Rowid                           IN  OUT NOCOPY  ROWID,
 X_Measure_Set_Code                IN      pji_mt_measure_sets_b.Measure_Set_Code%TYPE,
 X_Measure_Set_Type                IN      pji_mt_measure_sets_b.Measure_Set_Type%TYPE,
 X_Measure_Format                  IN      pji_mt_measure_sets_b.Measure_Format%TYPE,
 X_DB_Column_Name                  IN      pji_mt_measure_sets_b.DB_Column_Name%TYPE,
 X_Object_Version_Number           IN      pji_mt_measure_sets_b.Object_Version_Number%TYPE,
 X_Name                            IN      pji_mt_measure_sets_Tl.Name%TYPE,
 X_Description                     IN      pji_mt_measure_sets_Tl.Description%TYPE,
 X_Last_Update_Date                IN      pji_mt_measure_sets_b.Last_Update_Date%TYPE,
 X_Last_Updated_by                 IN      pji_mt_measure_sets_b.Last_Updated_by%TYPE,
 X_Creation_Date                   IN      pji_mt_measure_sets_b.Creation_Date%TYPE,
 X_Created_By                      IN      pji_mt_measure_sets_b.Created_By%TYPE,
 X_Last_Update_Login               IN      pji_mt_measure_sets_b.Last_Update_Login%TYPE,
 X_Measure_Formula				   IN	   pji_mt_measure_sets_b.Measure_Formula%TYPE,
 X_Measure_Source				   IN	   pji_mt_measure_sets_b.Measure_Source%TYPE,
 X_Return_Status	           OUT NOCOPY      VARCHAR2,
 X_Msg_Data                        OUT NOCOPY      VARCHAR2,
 X_Msg_Count                       OUT NOCOPY      NUMBER
);

 PROCEDURE Update_Row (
     X_Measure_Set_Code                IN      pji_mt_measure_sets_b.Measure_Set_Code%TYPE,
     X_Measure_Set_Type                IN      pji_mt_measure_sets_b.Measure_Set_Type%TYPE,
     X_Measure_Format                  IN      pji_mt_measure_sets_b.Measure_Format%TYPE,
     X_DB_Column_Name                  IN      pji_mt_measure_sets_b.DB_Column_Name%TYPE,
     X_Object_Version_Number           IN      pji_mt_measure_sets_b.Object_Version_Number%TYPE,
     X_Name                            IN      pji_mt_measure_sets_Tl.Name%TYPE,
     X_Description                     IN      pji_mt_measure_sets_Tl.Description%TYPE,
     X_Last_Update_Date                IN      pji_mt_measure_sets_b.Last_Update_Date%TYPE,
     X_Last_Updated_by                 IN      pji_mt_measure_sets_b.Last_Updated_by%TYPE,
     X_Last_Update_Login               IN      pji_mt_measure_sets_b.Last_Update_Login%TYPE,
	 X_Measure_Formula				   IN	   pji_mt_measure_sets_b.Measure_Formula%TYPE,
 	 X_Measure_Source				   IN	   pji_mt_measure_sets_b.Measure_Source%TYPE,
     X_Return_Status	               OUT NOCOPY     VARCHAR2,
     X_Msg_Data                        OUT NOCOPY     VARCHAR2,
     X_Msg_Count                       OUT NOCOPY     NUMBER
);

 PROCEDURE Load_Row (
     X_Measure_Set_Code                IN      pji_mt_measure_sets_b.Measure_Set_Code%TYPE,
     X_Measure_Set_Type                IN      pji_mt_measure_sets_b.Measure_Set_Type%TYPE,
     X_Measure_Format                  IN      pji_mt_measure_sets_b.Measure_Format%TYPE,
     X_DB_Column_Name                  IN      pji_mt_measure_sets_b.DB_Column_Name%TYPE,
     X_Object_Version_Number           IN      pji_mt_measure_sets_b.Object_Version_Number%TYPE,
     X_Name                            IN      pji_mt_measure_sets_Tl.Name%TYPE,
     X_Description                     IN      pji_mt_measure_sets_Tl.Description%TYPE,
     X_Owner                           IN      VARCHAR2,
	 X_Measure_Formula				   IN	   pji_mt_measure_sets_b.Measure_Formula%TYPE,
 	 X_Measure_Source				   IN	   pji_mt_measure_sets_b.Measure_Source%TYPE
);

PROCEDURE Add_Language;

PROCEDURE TRANSLATE_ROW (
  X_measure_set_code                  IN pji_mt_measure_sets_b.measure_set_code%TYPE,
  X_owner                             IN VARCHAR2 ,
  X_name                              IN pji_mt_measure_sets_TL.NAME%TYPE,
  X_description                       IN pji_mt_measure_sets_TL.DESCRIPTION%TYPE
 );

END Pji_Mt_Measure_Sets_Pkg;

 

/

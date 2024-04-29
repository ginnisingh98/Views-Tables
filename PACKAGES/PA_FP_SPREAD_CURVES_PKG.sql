--------------------------------------------------------
--  DDL for Package PA_FP_SPREAD_CURVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_SPREAD_CURVES_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPSCTS.pls 120.1 2005/08/19 16:30:08 mwasowic noship $ */

procedure  LOCK_ROW (
  p_spread_curve_id       IN Pa_spread_curves_b.spread_curve_id%TYPE,
  p_RECORD_VERSION_NUMBER IN pa_spread_curves_b.RECORD_VERSION_NUMBER%TYPE
 );

procedure DELETE_ROW (
  p_spread_curve_id in  Pa_spread_curves_b.spread_curve_id%TYPE
);


Procedure Insert_Row (
 X_Rowid                           IN  OUT NOCOPY Rowid, --File.Sql.39 bug 4440895
 X_Spread_Curve_Id                 IN      Pa_Spread_Curves_B.Spread_Curve_Id%Type,
 X_Spread_Curve_Code               IN      Pa_Spread_Curves_B.Spread_Curve_Code%Type,
 X_Record_Version_Number           IN      Pa_Spread_Curves_B.Record_Version_Number%Type,
 X_Name                            IN      Pa_Spread_Curves_Tl.Name%Type,
 X_Description                     IN      Pa_Spread_Curves_Tl.Description%Type,
 X_Effective_Start_Date            IN      Pa_Spread_Curves_B.Effective_Start_Date%Type,
 X_Effective_End_Date              IN      Pa_Spread_Curves_B.Effective_End_Date%Type,
 X_Rounding_Factor_Code            IN      Pa_Spread_Curves_B.Rounding_Factor_Code%Type,
 X_Point1                          IN      Pa_Spread_Curves_B.Point1%Type,
 X_Point2                          IN      Pa_Spread_Curves_B.Point2%Type,
 X_Point3                          IN      Pa_Spread_Curves_B.Point3%Type,
 X_Point4                          IN      Pa_Spread_Curves_B.Point4%Type,
 X_Point5                          IN      Pa_Spread_Curves_B.Point5%Type,
 X_Point6                          IN      Pa_Spread_Curves_B.Point6%Type,
 X_Point7                          IN      Pa_Spread_Curves_B.Point7%Type,
 X_Point8                          IN      Pa_Spread_Curves_B.Point8%Type,
 X_Point9                          IN      Pa_Spread_Curves_B.Point9%Type,
 X_Point10                         IN      Pa_Spread_Curves_B.Point10%Type,
 X_Last_Update_Date                IN      Pa_Spread_Curves_B.Last_Update_Date%Type,
 X_Last_Updated_By                 IN      Pa_Spread_Curves_B.Last_Updated_By%Type,
 X_Creation_Date                   IN      Pa_Spread_Curves_B.Creation_Date%Type,
 X_Created_By                      IN      Pa_Spread_Curves_B.Created_By%Type,
 X_Last_Update_Login               IN      Pa_Spread_Curves_B.Last_Update_Login%Type,
 X_Return_Status	           OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
 X_Msg_Data                        OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
 X_Msg_Count                       OUT     NOCOPY Number	 --File.Sql.39 bug 4440895
);

Procedure Update_Row (
 X_Spread_Curve_Id                 IN     Pa_Spread_Curves_B.Spread_Curve_Id%Type,
 X_Spread_Curve_Code               IN      Pa_Spread_Curves_B.Spread_Curve_Code%Type,
 X_Record_Version_Number           IN     Pa_Spread_Curves_B.Record_Version_Number%Type,
 X_Name                            IN     Pa_Spread_Curves_Tl.Name%Type,
 X_Description                     IN     Pa_Spread_Curves_Tl.Description%Type,
 X_Effective_Start_Date            IN     Pa_Spread_Curves_B.Effective_Start_Date%Type,
 X_Effective_End_Date              IN     Pa_Spread_Curves_B.Effective_End_Date%Type,
 X_Rounding_Factor_Code            IN     Pa_Spread_Curves_B.Rounding_Factor_Code%Type,
 X_Point1                          IN     Pa_Spread_Curves_B.Point1%Type,
 X_Point2                          IN     Pa_Spread_Curves_B.Point2%Type,
 X_Point3                          IN     Pa_Spread_Curves_B.Point3%Type,
 X_Point4                          IN     Pa_Spread_Curves_B.Point4%Type,
 X_Point5                          IN     Pa_Spread_Curves_B.Point5%Type,
 X_Point6                          IN     Pa_Spread_Curves_B.Point6%Type,
 X_Point7                          IN     Pa_Spread_Curves_B.Point7%Type,
 X_Point8                          IN     Pa_Spread_Curves_B.Point8%Type,
 X_Point9                          IN     Pa_Spread_Curves_B.Point9%Type,
 X_Point10                         IN     Pa_Spread_Curves_B.Point10%Type,
 X_Last_Update_Date                IN     Pa_Spread_Curves_B.Last_Update_Date%Type,
 X_Last_Updated_By                 IN     Pa_Spread_Curves_B.Last_Updated_By%Type,
 X_Last_Update_Login               IN     Pa_Spread_Curves_B.Last_Update_Login%Type,
 X_Return_Status	           OUT    NOCOPY Varchar2, --File.Sql.39 bug 4440895
 X_Msg_Data                        OUT    NOCOPY Varchar2, --File.Sql.39 bug 4440895
 X_Msg_Count                       OUT    NOCOPY Number	 --File.Sql.39 bug 4440895
);

Procedure Load_Row (
 X_Spread_Curve_Id                 IN     Pa_Spread_Curves_B.Spread_Curve_Id%Type,
 X_Spread_Curve_Code               IN     Pa_Spread_Curves_B.Spread_Curve_Code%Type,
 X_Record_Version_Number           IN     Pa_Spread_Curves_B.Record_Version_Number%Type,
 X_Name                            IN     Pa_Spread_Curves_Tl.Name%Type,
 X_Description                     IN     Pa_Spread_Curves_Tl.Description%Type,
 X_Effective_Start_Date            IN     Pa_Spread_Curves_B.Effective_Start_Date%Type,
 X_Effective_End_Date              IN     Pa_Spread_Curves_B.Effective_End_Date%Type,
 X_Rounding_Factor_Code            IN     Pa_Spread_Curves_B.Rounding_Factor_Code%Type,
 X_Point1                          IN     Pa_Spread_Curves_B.Point1%Type,
 X_Point2                          IN     Pa_Spread_Curves_B.Point2%Type,
 X_Point3                          IN     Pa_Spread_Curves_B.Point3%Type,
 X_Point4                          IN     Pa_Spread_Curves_B.Point4%Type,
 X_Point5                          IN     Pa_Spread_Curves_B.Point5%Type,
 X_Point6                          IN     Pa_Spread_Curves_B.Point6%Type,
 X_Point7                          IN     Pa_Spread_Curves_B.Point7%Type,
 X_Point8                          IN     Pa_Spread_Curves_B.Point8%Type,
 X_Point9                          IN     Pa_Spread_Curves_B.Point9%Type,
 X_Point10                         IN     Pa_Spread_Curves_B.Point10%Type,
 X_Owner                           IN     Varchar2
);

Procedure Add_Language;

Procedure Translate_Row (
  X_Spread_Curve_Id                   IN Pa_Spread_Curves_B.Spread_Curve_Id%Type,
  X_Owner                             IN Varchar2 ,
  X_Name                              IN Pa_Spread_Curves_Tl.Name%Type,
  X_Description                       IN  Pa_Spread_Curves_Tl.Description%Type
 );

end PA_FP_SPREAD_CURVES_PKG;

 

/

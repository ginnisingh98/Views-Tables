--------------------------------------------------------
--  DDL for Package Body PA_FP_SPREAD_CURVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_SPREAD_CURVES_PKG" as
/* $Header: PAFPSCTB.pls 120.1 2005/08/19 16:30:03 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_fp_spread_curves_pkg';

/*==================================================================
   This api locks the row in Pa_Spread_Curves_B before updating
 ==================================================================*/

procedure LOCK_ROW (
  p_spread_curve_id       IN Pa_spread_curves_b.spread_curve_id%TYPE,
  p_RECORD_VERSION_NUMBER IN pa_spread_curves_b.RECORD_VERSION_NUMBER%TYPE
 ) is

  cursor c is
    select RECORD_VERSION_NUMBER
    from   PA_SPREAD_CURVES_B
    where  SPREAD_CURVE_ID = p_spread_curve_id
    for update of spread_curve_id nowait;

  recinfo c%rowtype;

begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if recinfo.RECORD_VERSION_NUMBER = p_RECORD_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

end LOCK_ROW;

procedure DELETE_ROW (
  p_spread_curve_id in 	Pa_spread_curves_b.spread_curve_id%TYPE
) is
begin
  delete from PA_SPREAD_CURVES_TL
  where spread_curve_id = p_spread_curve_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PA_SPREAD_CURVES_B
  where spread_curve_id = p_spread_curve_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


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
)is

   l_spread_curve_id pa_spread_curves_b.SPREAD_CURVE_ID%type;

   cursor C is select ROWID from pa_spread_curves_b
    where SPREAD_CURVE_ID = l_spread_curve_id;

   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data               VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out   NUMBER;
   l_debug_mode   VARCHAR2(1) := Null;

  BEGIN

   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

   IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'validate',
                                      p_debug_mode => l_debug_mode );
   END IF;

   select nvl(X_SPREAD_CURVE_ID,PA_SPREAD_CURVES_S.nextval)
   into   l_spread_curve_id
   from   dual;

   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in Pa_Spread_Curves_B'||to_char(l_spread_Curve_id);
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

   INSERT INTO Pa_Spread_Curves_B
   (
     Spread_Curve_Id                 ,
     Spread_Curve_Code               ,
     Record_Version_Number           ,
     Effective_Start_Date            ,
     Effective_End_Date              ,
     Rounding_Factor_Code            ,
     Point1                          ,
     Point2                          ,
     Point3                          ,
     Point4                          ,
     Point5                          ,
     Point6                          ,
     Point7                          ,
     Point8                          ,
     Point9                          ,
     Point10                         ,
     Last_Update_Date                ,
     Last_Updated_By                 ,
     Creation_Date                   ,
     Created_By                      ,
     Last_Update_Login
   )
   VALUES
   (
     L_Spread_Curve_Id                 ,
     X_Spread_Curve_Code               ,
     1                                 ,
     X_Effective_Start_Date            ,
     X_Effective_End_Date              ,
     X_Rounding_Factor_Code            ,
     nvl(X_Point1,0)                   ,
     nvl(X_Point2,0)                   ,
     nvl(X_Point3,0)                   ,
     nvl(X_Point4,0)                   ,
     nvl(X_Point5,0)                   ,
     nvl(X_Point6,0)                   ,
     nvl(X_Point7,0)                   ,
     nvl(X_Point8,0)                   ,
     nvl(X_Point9,0)                   ,
     nvl(X_Point10,0)                  ,
     X_Last_Update_Date                ,
     X_Last_Updated_By                 ,
     X_Creation_Date                   ,
     X_Created_By                      ,
     X_Last_Update_Login
   );

   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in Pa_Spread_Curves_TL'||to_char(l_spread_Curve_id);
        pa_debug.write(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level3);
   END IF;

   INSERT INTO Pa_Spread_Curves_TL
   (
       Spread_Curve_Id,
       Name,
       Description,
       Last_Update_Date,
       Last_Updated_By,
       Creation_Date,
       Created_By,
       Last_Update_Login,
       Language,
       Source_Lang
   )
   SELECT
       L_Spread_Curve_Id,
       X_Name,
       X_Description,
       X_Last_Update_Date,
       X_Last_Updated_By,
       X_Creation_Date,
       X_Created_By,
       X_Last_Update_Login,
       L.Language_Code,
       Userenv('Lang')
   FROM  Fnd_Languages L
   WHERE L.Installed_Flag In ('I', 'B')
   AND NOT EXISTS
       (SELECT NULL FROM Pa_Spread_Curves_Tl T
        WHERE T.Spread_Curve_Id = L_Spread_Curve_Id
        AND T.Language = L.Language_Code);

   OPEN C;
   FETCH C INTO X_ROWID;
   IF (C%NOTFOUND) THEN

      CLOSE C;
      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Rowid could not be fetched after Inserting for'||to_char(l_spread_Curve_id);
           pa_debug.write(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
      END IF;
      RAISE NO_DATA_FOUND;

   END IF;
   CLOSE C;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 and x_msg_data IS NULL THEN
         PA_INTERFACE_UTILS_PUB.get_messages
             (p_encoded        => FND_API.G_TRUE
             ,p_msg_index      => 1
             ,p_msg_count      => l_msg_count
             ,p_msg_data       => l_msg_data
             ,p_data           => l_data
             ,p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
         x_msg_count := l_msg_count;
      ELSE
         x_msg_count := l_msg_count;
      END IF;

      IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
      END IF;

      RETURN;

    WHEN others THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
         ( p_pkg_name        => 'PA_FP_SPREAD_CURVES_PKG'
         ,p_procedure_name  => 'Insert Row'
         ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                               pa_fp_constants_pkg.g_debug_level5);
        pa_debug.reset_curr_function;
     END IF;

     RAISE;

 END Insert_Row;


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
     X_Return_Status	               OUT    NOCOPY Varchar2, --File.Sql.39 bug 4440895
     X_Msg_Data                        OUT    NOCOPY Varchar2, --File.Sql.39 bug 4440895
     X_Msg_Count                       OUT    NOCOPY Number	 --File.Sql.39 bug 4440895
  ) IS

     l_return_status          VARCHAR2(1) := NULL;
     l_msg_count              NUMBER      := 0;
     l_data               VARCHAR2(2000) := NULL;
     l_msg_data               VARCHAR2(2000) := NULL;
     l_msg_index_out   NUMBER;
     l_debug_mode   VARCHAR2(1) := Null;

  BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'validate',
                                        p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Updating Pa_Spread_Curves_B for'||to_char(X_spread_Curve_id);
          pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     UPDATE Pa_Spread_Curves_B
     SET    Spread_Curve_Code               = X_Spread_Curve_Code,
            Effective_Start_Date            = X_Effective_Start_Date,
            Effective_End_Date              = X_Effective_End_Date,
            Record_Version_Number           = Record_Version_Number + 1,
            Rounding_Factor_Code            = X_Rounding_Factor_Code,
            Point1                          = nvl(X_Point1,0),
            Point2                          = nvl(X_Point2,0),
            Point3                          = nvl(X_Point3,0),
            Point4                          = nvl(X_Point4,0),
            Point5                          = nvl(X_Point5,0),
            Point6                          = nvl(X_Point6,0),
            Point7                          = nvl(X_Point7,0),
            Point8                          = nvl(X_Point8,0),
            Point9                          = nvl(X_Point9,0),
            Point10                         = nvl(X_Point10,0),
            Last_Update_Date                = X_Last_Update_Date,
            Last_Updated_By                 = X_Last_Updated_By,
            Last_Update_Login               = X_Last_Update_Login
            Where Spread_Curve_Id           = X_Spread_Curve_Id;

     IF (SQL%NOTFOUND) THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating Pa_Spread_Curves_B'||to_char(X_spread_Curve_id);
             pa_debug.write(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
        END IF;
        RAISE NO_DATA_FOUND;
     END IF;

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Updating Pa_Spread_Curves_TL for'||to_char(X_spread_Curve_id);
            pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     UPDATE Pa_Spread_Curves_TL
     SET    Name = X_Name,
            Description = X_Description,
            Last_Update_Date = X_Last_Update_Date,
            Last_Updated_By = X_Last_Updated_By,
            Last_Update_Login = X_Last_Update_Login,
            Source_Lang = Userenv('Lang')
     WHERE  Spread_Curve_Id = X_Spread_Curve_Id
     AND    Userenv('Lang') In (Language, Source_Lang);

     IF (SQL%NOTFOUND) THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating Pa_Spread_Curves_T'||to_char(X_spread_Curve_id);
             pa_debug.write(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
        END IF;
        RAISE NO_DATA_FOUND;
     END IF;

  EXCEPTION
  WHEN  NO_DATA_FOUND THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count = 1 and x_msg_data IS NULL THEN
       PA_INTERFACE_UTILS_PUB.get_messages
           (p_encoded        => FND_API.G_TRUE
           ,p_msg_index      => 1
           ,p_msg_count      => l_msg_count
           ,p_msg_data       => l_msg_data
           ,p_data           => l_data
           ,p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
       x_msg_count := l_msg_count;
    ELSE
       x_msg_count := l_msg_count;
    END IF;

    IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
    END IF;

    RAISE NO_DATA_FOUND;

  WHEN others THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;

    FND_MSG_PUB.add_exc_msg
       ( p_pkg_name        => 'PA_FP_SPREAD_CURVES_PKG'
       ,p_procedure_name  => 'UPDATE_ROW'
       ,p_error_text      => x_msg_data);

   IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
      pa_debug.write(g_module_name,pa_debug.g_err_stage,
                             pa_fp_constants_pkg.g_debug_level5);
      pa_debug.reset_curr_function;
   END IF;

 RAISE;
END Update_Row;

 Procedure Load_Row (
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
    X_Owner                           IN     Varchar2
)
IS

   User_Id NUMBER := Null;
   X_ROWID VARCHAR2(64);
   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data               VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out   NUMBER;
   l_debug_mode   VARCHAR2(1) := Null;

 BEGIN

   IF (X_Owner = 'SEED')THEN
       User_Id := 1;
   ELSE
       User_Id := 0;
   END IF;
   Pa_Fp_Spread_Curves_Pkg.Update_Row (
     X_Spread_Curve_Id                  =>   X_Spread_Curve_Id               ,
     X_Spread_Curve_Code                =>   X_Spread_Curve_Code             ,
     X_Record_Version_Number            =>   X_Record_Version_Number         ,
     X_Name                             =>   X_Name                          ,
     X_Description                      =>   X_Description                   ,
     X_Effective_Start_Date             =>   X_Effective_Start_Date          ,
     X_Effective_End_Date               =>   X_Effective_End_Date            ,
     X_Rounding_Factor_Code             =>   X_Rounding_Factor_Code          ,
     X_Point1                           =>   X_Point1                        ,
     X_Point2                           =>   X_Point2                        ,
     X_Point3                           =>   X_Point3                        ,
     X_Point4                           =>   X_Point4                        ,
     X_Point5                           =>   X_Point5                        ,
     X_Point6                           =>   X_Point6                        ,
     X_Point7                           =>   X_Point7                        ,
     X_Point8                           =>   X_Point8                        ,
     X_Point9                           =>   X_Point9                        ,
     X_Point10                          =>   X_Point10                       ,
     X_Last_Update_Date                 =>   Sysdate                         ,
     X_Last_Updated_By                  =>   User_Id                         ,
     X_Last_Update_Login                =>   0				     ,
     X_Return_Status	                =>   l_Return_Status                 ,
     X_Msg_Data                         =>   l_Msg_Data                      ,
     X_Msg_Count                        =>   l_Msg_Count                     );


  EXCEPTION
    WHEN no_data_found then

      Pa_Fp_Spread_Curves_Pkg.Insert_Row (
          X_Rowid                            =>   X_Rowid                         ,
          X_Spread_Curve_Id                  =>   X_Spread_Curve_Id               ,
          X_Spread_Curve_Code                =>   X_Spread_Curve_Code             ,
          X_Record_Version_Number            =>   X_Record_Version_Number         ,
          X_Name                             =>   X_Name                          ,
          X_Description                      =>   X_Description                   ,
          X_Effective_Start_Date             =>   X_Effective_Start_Date          ,
          X_Effective_End_Date               =>   X_Effective_End_Date            ,
          X_Rounding_Factor_Code             =>   X_Rounding_Factor_Code          ,
          X_Point1                           =>   X_Point1                        ,
          X_Point2                           =>   X_Point2                        ,
          X_Point3                           =>   X_Point3                        ,
          X_Point4                           =>   X_Point4                        ,
          X_Point5                           =>   X_Point5                        ,
          X_Point6                           =>   X_Point6                        ,
          X_Point7                           =>   X_Point7                        ,
          X_Point8                           =>   X_Point8                        ,
          X_Point9                           =>   X_Point9                        ,
          X_Point10                          =>   X_Point10                       ,
	  X_Creation_Date                    =>   Sysdate                         ,
          X_Created_By                       =>   User_Id                         ,
          X_Last_Update_Date                 =>   Sysdate                         ,
          X_Last_Updated_By                  =>   User_Id                         ,
          X_Last_Update_Login                =>   0                               ,
          X_Return_Status                    =>   l_Return_Status                 ,
          X_Msg_Data                         =>   l_Msg_Data                      ,
          X_Msg_Count                        =>   l_Msg_Count                     );

     WHEN others THEN

     l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_msg_count     := 1;
     l_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => 'PA_FP_SPREAD_CURVES_PKG'
        ,p_procedure_name  => 'UPDATE_ROW'
        ,p_error_text      => l_msg_data);

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:= 'Unexpected Error'||l_msg_data;
       pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              pa_fp_constants_pkg.g_debug_level5);
       pa_debug.reset_curr_function;
    END IF;

    RAISE;
 END Load_Row;


 PROCEDURE Add_Language
 IS
 BEGIN

  delete from PA_SPREAD_CURVES_TL T
  where not exists
    (select NULL
    from PA_SPREAD_CURVES_B B
    where B.SPREAD_CURVE_ID  = T.SPREAD_CURVE_ID
    );

  update PA_SPREAD_CURVES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PA_SPREAD_CURVES_TL B
    where B.SPREAD_CURVE_ID = T.SPREAD_CURVE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
    where (
      T.SPREAD_CURVE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SPREAD_CURVE_ID,
      SUBT.LANGUAGE
    from PA_SPREAD_CURVES_TL SUBB, PA_SPREAD_CURVES_TL SUBT
    where SUBB.SPREAD_CURVE_ID = SUBT.SPREAD_CURVE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

   insert into PA_SPREAD_CURVES_TL (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    SPREAD_CURVE_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  )select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.SPREAD_CURVE_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_SPREAD_CURVES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_SPREAD_CURVES_TL T
    where T.SPREAD_CURVE_ID = B.SPREAD_CURVE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_SPREAD_CURVE_ID                   in PA_SPREAD_CURVES_B.SPREAD_CURVE_ID%TYPE,
  X_OWNER                             in VARCHAR2 ,
  X_NAME                              in PA_SPREAD_CURVES_TL.NAME%TYPE,
  X_DESCRIPTION                       in  PA_SPREAD_CURVES_TL.DESCRIPTION%TYPE
 )is
begin

  update PA_SPREAD_CURVES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where SPREAD_CURVE_ID = X_SPREAD_CURVE_ID
  and   userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;


end PA_FP_SPREAD_CURVES_PKG;

/

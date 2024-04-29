--------------------------------------------------------
--  DDL for Package Body PJI_MT_ROWSET_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_MT_ROWSET_DET_PKG" AS
/* $Header: PJIMTRDB.pls 120.1 2005/05/31 08:01:34 appldev  $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pji_mt_rowset_det_pkg';
g_debug_mode    VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

/*==================================================================
   This api locks the row in pji_mt_rowset_det before updating
 ==================================================================*/

PROCEDURE LOCK_ROW (
  p_measure_set_code       IN pji_mt_rowset_det.measure_set_code%TYPE,
  p_rowset_code            IN pji_mt_rowset_det.rowset_code%TYPE,
  p_object_version_number  IN pji_mt_rowset_det.object_version_number%TYPE
 ) IS

  CURSOR c IS
    SELECT object_version_number
    FROM   pji_mt_rowset_det
    WHERE  measure_set_code = p_measure_set_code
    AND    rowset_code = p_rowset_code
    FOR UPDATE OF measure_set_code, rowset_code NOWAIT;

  recinfo c%ROWTYPE;

BEGIN

  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;

  IF recinfo.object_version_number = p_object_version_number THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  RETURN;

END LOCK_ROW;



PROCEDURE DELETE_ROW (
  p_measure_set_code   IN pji_mt_rowset_det.measure_set_code%TYPE,
  p_rowset_code        IN pji_mt_rowset_det.rowset_code%TYPE
) IS
BEGIN
  DELETE FROM pji_mt_rowset_det
  WHERE measure_set_code = p_measure_set_code
  AND   rowset_code = p_rowset_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_ROW;


PROCEDURE Insert_Row (
 X_Rowid                        IN  OUT NOCOPY  ROWID,
 X_measure_set_code             IN      pji_mt_rowset_det.measure_set_code%TYPE,
 X_rowset_code                  IN      pji_mt_rowset_det.rowset_code%TYPE,
 X_Object_Version_Number        IN      pji_mt_rowset_det.Object_Version_Number%TYPE,
 X_display_order                IN      pji_mt_rowset_det.display_order%TYPE,				--Bug 3798976
 X_Last_Update_Date             IN      pji_mt_rowset_det.Last_Update_Date%TYPE,
 X_Last_Updated_by              IN      pji_mt_rowset_det.Last_Updated_by%TYPE,
 X_Creation_Date                IN      pji_mt_rowset_det.Creation_Date%TYPE,
 X_Created_By                   IN      pji_mt_rowset_det.Created_By%TYPE,
 X_Last_Update_Login            IN      pji_mt_rowset_det.Last_Update_Login%TYPE,
 X_Return_Status	            OUT NOCOPY      VARCHAR2,
 X_Msg_Data                     OUT NOCOPY      VARCHAR2,
 X_Msg_Count                    OUT NOCOPY      NUMBER
) IS

   CURSOR C IS SELECT ROWID FROM pji_mt_rowset_det
    WHERE measure_set_code = x_measure_set_code
    AND   rowset_code = x_rowset_code;

   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data                   VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out          NUMBER;

  BEGIN

   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF g_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'validate',
                                      p_debug_mode => g_debug_mode );
   END IF;

   IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in pji_mt_rowset_det, measure_code= '||X_measure_set_code||', rowset_code= '||x_rowset_code;
        pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

   INSERT INTO pji_mt_rowset_det
   (
    measure_set_code
    , rowset_code
    , Object_Version_Number
	, display_order											--Bug 3798976
    , Creation_Date
    , Last_Update_Date
    , Last_Updated_By
    , Created_By
    , Last_Update_Login )
   VALUES
   (
    X_measure_set_code
    , X_rowset_code
    , X_Object_Version_Number
	, X_display_order										--Bug 3798976
    , X_Creation_Date
    , X_Last_Update_Date
    , X_Last_Updated_By
    , X_Created_By
    , X_Last_Update_Login
   );

   IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in pji_mt_rowset_det '||X_measure_set_code;
        pa_debug.WRITE(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level3);
   END IF;

   OPEN C;
   FETCH C INTO X_ROWID;
   IF (C%NOTFOUND) THEN

      CLOSE C;
      IF g_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Rowid could not be fetched after Inserting for '||X_measure_set_code;
           pa_debug.WRITE(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
      END IF;
      RAISE NO_DATA_FOUND;

   END IF;
   CLOSE C;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 AND x_msg_data IS NULL THEN
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

      IF g_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
      END IF;

      RETURN;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PJI_MT_ROWSET_DET_PKG'
         ,p_procedure_name  => 'Insert Row'
         ,p_error_text      => x_msg_data);

     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
        pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,
                               pa_fp_constants_pkg.g_debug_level5);
        pa_debug.reset_curr_function;
     END IF;

     RAISE;

 END Insert_Row;


PROCEDURE Update_Row (
    X_measure_set_code                IN      pji_mt_rowset_det.measure_set_code%TYPE,
    X_rowset_code                     IN      pji_mt_rowset_det.rowset_code%TYPE,
    X_Object_Version_Number           IN      pji_mt_rowset_det.Object_Version_Number%TYPE,
	X_display_order                   IN      pji_mt_rowset_det.display_order%TYPE,					--Bug 3798976
    X_Last_Update_Date                IN      pji_mt_rowset_det.Last_Update_Date%TYPE,
    X_Last_Updated_by                 IN      pji_mt_rowset_det.Last_Updated_by%TYPE,
    X_Last_Update_Login               IN      pji_mt_rowset_det.Last_Update_Login%TYPE,
    X_Return_Status	                  OUT NOCOPY      VARCHAR2,
    X_Msg_Data                        OUT NOCOPY      VARCHAR2,
    X_Msg_Count                       OUT NOCOPY      NUMBER
)
IS

     l_return_status          VARCHAR2(1) := NULL;
     l_msg_count              NUMBER      := 0;
     l_data                   VARCHAR2(2000) := NULL;
     l_msg_data               VARCHAR2(2000) := NULL;
     l_msg_index_out          NUMBER;

  BEGIN
     NULL;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF g_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'validate',
                                        p_debug_mode => g_debug_mode );
     END IF;

     IF g_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Updating pji_mt_rowset_det for'||X_measure_set_code;
          pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     UPDATE pji_mt_rowset_det
     SET
        Object_Version_Number = X_Object_Version_Number
		, display_order = X_display_order								--Bug 3798976
        , Last_Update_Date = X_Last_Update_Date
        , Last_Updated_By = X_Last_Updated_By
        , Last_Update_Login = X_Last_Update_Login
     WHERE measure_set_code = X_measure_set_code
     AND   rowset_code = X_rowset_code;

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating pji_mt_rowset_det, measure_code= '||X_measure_set_code||', rowset_code= '||x_rowset_code;
             pa_debug.WRITE(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
        END IF;
        RAISE NO_DATA_FOUND;
     END IF;

     IF g_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Updating pji_mt_rowset_det for, measure_code= '||X_measure_set_code||', rowset_code= '||x_rowset_code;
            pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

  EXCEPTION
  WHEN  NO_DATA_FOUND THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count = 1 AND x_msg_data IS NULL THEN
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

    IF g_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
    END IF;

    RAISE NO_DATA_FOUND;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;

    FND_MSG_PUB.add_exc_msg
       ( p_pkg_name       => 'PJI_MT_ROWSET_DET_PKG'
       ,p_procedure_name  => 'UPDATE_ROW'
       ,p_error_text      => x_msg_data);

   IF g_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
      pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,
                             pa_fp_constants_pkg.g_debug_level5);
      pa_debug.reset_curr_function;
   END IF;

 RAISE;
END Update_Row;



PROCEDURE Load_Row (
    X_measure_set_code          IN     pji_mt_rowset_det.measure_set_code%TYPE,
    X_rowset_code               IN     pji_mt_rowset_det.rowset_code%TYPE,
    X_Object_Version_Number     IN     pji_mt_rowset_det.Object_Version_Number%TYPE,
	X_display_order             IN     pji_mt_rowset_det.display_order%TYPE,					--Bug 3798976
    X_Owner                     IN     VARCHAR2
)
IS
   User_Id NUMBER := NULL;
   X_ROWID VARCHAR2(64);
   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data                   VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out          NUMBER;

 BEGIN

   g_debug_mode := 'N';

   IF (X_Owner = 'SEED')THEN
       User_Id := 1;
   ELSE
       User_Id := 0;
   END IF;
   PJI_MT_ROWSET_DET_PKG.Update_Row (
     X_measure_set_code           =>   X_measure_set_code       ,
     X_rowset_code                =>   X_rowset_code            ,
     X_Object_Version_Number      =>   X_Object_Version_Number  ,
	 X_display_order              =>   X_display_order          ,				--Bug 3798976
     X_Last_Update_Date           =>   SYSDATE                  ,
     X_Last_Updated_By            =>   User_Id                  ,
     X_Last_Update_Login          =>   0		                ,
     X_Return_Status              =>   l_Return_Status          ,
     X_Msg_Data                   =>   l_Msg_Data               ,
     X_Msg_Count                  =>   l_Msg_Count              );


  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      PJI_MT_ROWSET_DET_PKG.Insert_Row (
          X_Rowid                            =>   X_Rowid                         ,
          X_measure_set_code                 =>   X_measure_set_code              ,
          X_rowset_code                      =>   X_rowset_code                   ,
          X_Object_Version_Number            =>   X_Object_Version_Number         ,
		  X_display_order                    =>   X_display_order                 ,				--Bug 3798976
	      X_Creation_Date                    =>   SYSDATE                         ,
          X_Created_By                       =>   User_Id                         ,
          X_Last_Update_Date                 =>   SYSDATE                         ,
          X_Last_Updated_By                  =>   User_Id                         ,
          X_Last_Update_Login                =>   0                               ,
          X_Return_Status                    =>   l_Return_Status                 ,
          X_Msg_Data                         =>   l_Msg_Data                      ,
          X_Msg_Count                        =>   l_Msg_Count                     );

     WHEN OTHERS THEN

     l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_msg_count     := 1;
     l_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => 'PJI_MT_ROWSET_DET_PKG'
        ,p_procedure_name  => 'UPDATE_ROW'
        ,p_error_text      => l_msg_data);

    IF g_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:= 'Unexpected Error'||l_msg_data;
       pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,
                              pa_fp_constants_pkg.g_debug_level5);
       pa_debug.reset_curr_function;
    END IF;

    RAISE;
 END Load_Row;



END PJI_MT_ROWSET_DET_PKG;

/

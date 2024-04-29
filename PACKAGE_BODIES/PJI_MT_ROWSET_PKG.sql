--------------------------------------------------------
--  DDL for Package Body PJI_MT_ROWSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_MT_ROWSET_PKG" AS
/* $Header: PJIMTRSB.pls 120.1 2005/05/31 08:01:44 appldev  $ */

g_module_name  VARCHAR2(100) := 'pa.plsql.pji_mt_rowset_pkg';
g_debug_mode   VARCHAR2(1)   := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

/*==================================================================
   This api locks the row in pji_mt_rowset_b before updating
 ==================================================================*/

PROCEDURE LOCK_ROW (
  p_rowset_code       IN pji_mt_rowset_b.rowset_code%TYPE,
  p_object_version_number IN pji_mt_rowset_b.object_version_number%TYPE
 ) IS

  CURSOR c IS
    SELECT object_version_number
    FROM   pji_mt_rowset_b
    WHERE  rowset_code = p_rowset_code
    FOR UPDATE OF rowset_code NOWAIT;

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
  p_rowset_code IN 	pji_mt_rowset_b.rowset_code%TYPE
) IS
BEGIN
  DELETE FROM pji_mt_rowset_TL
  WHERE rowset_code = p_rowset_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM pji_mt_rowset_B
  WHERE rowset_code = p_rowset_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;


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
) IS

   CURSOR C IS SELECT ROWID FROM pji_mt_rowset_b
    WHERE rowset_code = x_rowset_code;

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
        pa_debug.g_err_stage:= 'Inserting record in pji_mt_rowset_B '||X_Rowset_Code;
        pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

   INSERT INTO pji_mt_rowset_B
   (
    Rowset_Code
    , Object_Version_Number
    , Creation_Date
    , Last_Update_Date
    , Last_Updated_By
    , Created_By
    , Last_Update_Login )
   VALUES
   (
    X_Rowset_Code
    , X_Object_Version_Number
    , X_Creation_Date
    , X_Last_Update_Date
    , X_Last_Updated_By
    , X_Created_By
    , X_Last_Update_Login
   );

   IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in pji_mt_rowset_tl '||X_Rowset_Code;
        pa_debug.WRITE(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level3);
   END IF;

   INSERT INTO pji_mt_rowset_tl
   (
       Rowset_Code,
       Name,
       Description,
       Last_Update_Date,
       Last_Updated_By,
       Creation_Date,
       Created_By,
       Last_Update_Login,
       LANGUAGE,
       Source_Lang
   )
   SELECT
       X_Rowset_Code,
       X_Name,
       X_Description,
       X_Last_Update_Date,
       X_Last_Updated_By,
       X_Creation_Date,
       X_Created_By,
       X_Last_Update_Login,
       L.Language_Code,
       USERENV('Lang')
   FROM  Fnd_Languages L
   WHERE L.Installed_Flag IN ('I', 'B')
   AND NOT EXISTS
       (SELECT NULL FROM pji_mt_rowset_tl T
        WHERE T.rowset_code = X_Rowset_Code
        AND T.LANGUAGE = L.Language_Code);

   OPEN C;
   FETCH C INTO X_ROWID;
   IF (C%NOTFOUND) THEN

      CLOSE C;
      IF g_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Rowid could not be fetched after Inserting for '||X_Rowset_Code;
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
         ( p_pkg_name        => 'PJI_MT_ROWSET_PKG'
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
     X_Rowset_Code                     IN      pji_mt_rowset_b.Rowset_Code%TYPE,
     X_Object_Version_Number           IN      pji_mt_rowset_b.Object_Version_Number%TYPE,
     X_Name                            IN      pji_mt_rowset_Tl.Name%TYPE,
     X_Description                     IN      pji_mt_rowset_Tl.Description%TYPE,
     X_Last_Update_Date                IN      pji_mt_rowset_b.Last_Update_Date%TYPE,
     X_Last_Updated_by                 IN      pji_mt_rowset_b.Last_Updated_by%TYPE,
     X_Last_Update_Login               IN      pji_mt_rowset_b.Last_Update_Login%TYPE,
     X_Lock_Flag                       IN      VARCHAR2  DEFAULT 'true',
     X_Return_Status	               OUT NOCOPY      VARCHAR2,
     X_Msg_Data                        OUT NOCOPY      VARCHAR2,
     X_Msg_Count                       OUT NOCOPY      NUMBER
)
IS

     l_return_status          VARCHAR2(1) := NULL;
     l_msg_count              NUMBER      := 0;
     l_data                   VARCHAR2(2000) := NULL;
     l_msg_data               VARCHAR2(2000) := NULL;
     l_msg_index_out          NUMBER;
     l_object_version_number  NUMBER := x_object_version_number;

  BEGIN
     NULL;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF g_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'validate',
                                        p_debug_mode => g_debug_mode );
     END IF;

     IF g_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Updating pji_mt_rowset_b for'||X_Rowset_Code;
          pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     -- The lock row procedure need not be called when the update_row is called
     -- from the lct. It should be called when update row is called from the
     -- page

     IF X_Lock_Flag = 'true' then
          lock_row(X_Rowset_Code, l_object_version_number);
     END IF;

     l_object_version_number := l_object_version_number + 1;

     UPDATE pji_mt_rowset_B
     SET
            Rowset_Code = X_Rowset_Code
            , Object_Version_Number = l_object_version_number
            , Last_Update_Date = X_Last_Update_Date
            , Last_Updated_By = X_Last_Updated_By
            , Last_Update_Login = X_Last_Update_Login
            WHERE rowset_code = X_rowset_code;

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating pji_mt_rowset_B '||X_Rowset_Code;
             pa_debug.WRITE(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
        END IF;
        RAISE NO_DATA_FOUND;
     END IF;

     IF g_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Updating pji_mt_rowset_tl for '||X_Rowset_Code;
            pa_debug.WRITE(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     UPDATE pji_mt_rowset_tl
     SET    Name = X_Name,
            Description = X_Description,
            Last_Update_Date = X_Last_Update_Date,
            Last_Updated_By = X_Last_Updated_By,
            Last_Update_Login = X_Last_Update_Login,
            Source_Lang = USERENV('Lang')
     WHERE  Rowset_Code = X_Rowset_Code
     AND    USERENV('Lang') IN (LANGUAGE, Source_Lang);

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating pji_mt_rowset_T '||X_Rowset_Code;
             pa_debug.WRITE(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
        END IF;
        RAISE NO_DATA_FOUND;
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
       ( p_pkg_name        => 'PJI_MT_ROWSET_PKG'
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
    X_Rowset_Code               IN     pji_mt_rowset_b.Rowset_Code%TYPE,
    X_Object_Version_Number     IN     pji_mt_rowset_b.Object_Version_Number%TYPE,
    X_Name                      IN     pji_mt_rowset_Tl.Name%TYPE,
    X_Description               IN     pji_mt_rowset_Tl.Description%TYPE,
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
   PJI_MT_ROWSET_Pkg.Update_Row (
     X_Rowset_Code                =>   X_Rowset_Code            ,
     X_Object_Version_Number      =>   X_Object_Version_Number  ,
     X_Name                       =>   X_Name                   ,
     X_Description                =>   X_Description            ,
     X_Last_Update_Date           =>   SYSDATE                  ,
     X_Last_Updated_By            =>   User_Id                  ,
     X_Last_Update_Login          =>   0		                ,
     X_Lock_Flag                  =>   'false'                  ,
     X_Return_Status              =>   l_Return_Status          ,
     X_Msg_Data                   =>   l_Msg_Data               ,
     X_Msg_Count                  =>   l_Msg_Count              );


  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      PJI_MT_ROWSET_Pkg.Insert_Row (
          X_Rowid                            =>   X_Rowid                         ,
          X_Rowset_Code                      =>   X_Rowset_Code                   ,
          X_Object_Version_Number            =>   X_Object_Version_Number         ,
          X_Name                             =>   X_Name                          ,
          X_Description                      =>   X_Description                   ,
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
        ( p_pkg_name        => 'PJI_MT_ROWSET_PKG'
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


 PROCEDURE Add_Language
 IS
 BEGIN

  DELETE FROM pji_mt_rowset_tl T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM pji_mt_rowset_B B
    WHERE B.rowset_code  = T.rowset_code
    );

  UPDATE pji_mt_rowset_tl T SET (
      NAME,
      DESCRIPTION
    ) = (SELECT
      B.NAME,
      B.DESCRIPTION
    FROM pji_mt_rowset_tl B
    WHERE B.rowset_code = T.rowset_code
    AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (
      T.rowset_code,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.rowset_code,
      SUBT.LANGUAGE
    FROM pji_mt_rowset_tl SUBB, pji_mt_rowset_tl SUBT
    WHERE SUBB.rowset_code = SUBT.rowset_code
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.NAME <> SUBT.NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

   INSERT INTO pji_mt_rowset_tl(
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    rowset_code,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  )SELECT
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.rowset_code,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM pji_mt_rowset_tl B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM pji_mt_rowset_tl T
    WHERE T.rowset_code = B.rowset_code
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW (
  X_rowset_code                   IN pji_mt_rowset_b.rowset_code%TYPE,
  X_OWNER                         IN VARCHAR2 ,
  X_NAME                          IN pji_mt_rowset_TL.NAME%TYPE,
  X_DESCRIPTION                   IN  pji_mt_rowset_TL.DESCRIPTION%TYPE
 )IS
BEGIN

  UPDATE pji_mt_rowset_tl SET
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE  = SYSDATE,
    LAST_UPDATED_BY   = DECODE(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = USERENV('LANG')
  WHERE rowset_code = x_rowset_code
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG) ;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END TRANSLATE_ROW;


END PJI_MT_ROWSET_PKG;

/

--------------------------------------------------------
--  DDL for Package Body PJI_MT_MEASURE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_MT_MEASURE_SETS_PKG" AS
/* $Header: PJIMTMSB.pls 120.1 2005/05/31 08:01:25 appldev  $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pji_mt_measure_sets_pkg';
g_debug_mode    VARCHAR2(1) := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');


/*==================================================================
   This api locks the row in pji_mt_measure_sets_b before updating
 ==================================================================*/

PROCEDURE LOCK_ROW (
  p_measure_set_code       IN pji_mt_measure_sets_b.measure_set_code%TYPE,
  p_object_version_number IN pji_mt_measure_sets_b.object_version_number%TYPE
 ) IS

  CURSOR c IS
    SELECT object_version_number
    FROM   pji_mt_measure_sets_B
    WHERE  measure_set_code = p_measure_set_code
    FOR UPDATE OF measure_set_code NOWAIT;

  recinfo c%ROWTYPE;

BEGIN

  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    Fnd_Message.set_name('FND', 'FORM_RECORD_DELETED');
    App_Exception.raise_exception;
  END IF;
  CLOSE c;

  IF recinfo.object_version_number = p_object_version_number THEN
    NULL;
  ELSE
    Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
    App_Exception.raise_exception;
  END IF;

  RETURN;

END LOCK_ROW;

PROCEDURE DELETE_ROW (
  p_measure_set_code IN 	pji_mt_measure_sets_b.measure_set_code%TYPE
) IS
BEGIN
  DELETE FROM pji_mt_measure_sets_TL
  WHERE measure_set_code = p_measure_set_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM pji_mt_measure_sets_b
  WHERE measure_set_code = p_measure_set_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;


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
)IS

   CURSOR C IS SELECT ROWID FROM pji_mt_measure_sets_b
    WHERE measure_set_code = x_measure_set_code;

   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data               VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out   NUMBER;

  BEGIN

   x_msg_count := 0;
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF g_debug_mode = 'Y' THEN
          Pa_Debug.set_curr_function( p_function   => 'validate',
                                      p_debug_mode => g_debug_mode );
   END IF;

   IF g_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Inserting record in pji_mt_measure_sets_B '||X_Measure_Set_Code;
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     Pa_Fp_Constants_Pkg.g_debug_level3);
   END IF;

   INSERT INTO pji_mt_measure_sets_B
   (
    Measure_Set_Code
    , Measure_Set_Type
    , Measure_Format
    , Db_Column_Name
    , Object_Version_Number
    , Creation_Date
    , Last_Update_Date
    , Last_Updated_By
    , Created_By
    , Last_Update_Login
	, Measure_Formula
	, Measure_Source )
   VALUES
   (
    X_Measure_Set_Code
    , X_Measure_Set_Type
    , X_Measure_Format
    , X_Db_Column_Name
    , X_Object_Version_Number
    , X_Creation_Date
    , X_Last_Update_Date
    , X_Last_Updated_By
    , X_Created_By
    , X_Last_Update_Login
	, X_Measure_Formula
	, X_Measure_Source
   );

   IF g_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Inserting record in pji_mt_measure_sets_tl '||X_Measure_Set_Code;
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level3);
   END IF;

   INSERT INTO pji_mt_measure_sets_tl
   (
       Measure_Set_Code,
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
       X_Measure_Set_Code,
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
       (SELECT NULL FROM pji_mt_measure_sets_tl T
        WHERE T.measure_set_code = X_Measure_Set_Code
        AND T.LANGUAGE = L.Language_Code);

Hr_Utility.trace('after inserting t row');


   OPEN C;
   FETCH C INTO X_ROWID;
   IF (C%NOTFOUND) THEN

      CLOSE C;

      IF g_debug_mode = 'Y' THEN
           Pa_Debug.g_err_stage:= 'Rowid could not be fetched after Inserting for '||X_Measure_Set_Code;
           Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
      END IF;

      RAISE NO_DATA_FOUND;

   END IF;
   CLOSE C;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN

      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      l_msg_count := Fnd_Msg_Pub.count_msg;

      IF l_msg_count = 1 AND x_msg_data IS NULL THEN
         Pa_Interface_Utils_Pub.get_messages
             (p_encoded        => Fnd_Api.G_TRUE
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
              Pa_Debug.reset_curr_function;
      END IF;

      RETURN;

    WHEN OTHERS THEN

      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      Fnd_Msg_Pub.add_exc_msg
         ( p_pkg_name        => 'PJI_MT_MEASURE_SETS_PKG'
         ,p_procedure_name  => 'Insert Row'
         ,p_error_text      => x_msg_data);

     IF g_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                               Pa_Fp_Constants_Pkg.g_debug_level5);
        Pa_Debug.reset_curr_function;
     END IF;

     RAISE;

 END Insert_Row;


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
  ) IS

     l_return_status          VARCHAR2(1) := NULL;
     l_msg_count              NUMBER      := 0;
     l_data               VARCHAR2(2000) := NULL;
     l_msg_data               VARCHAR2(2000) := NULL;
	 l_object_version_number NUMBER;
     l_msg_index_out   NUMBER;
	 l_update_conflict EXCEPTION;
  BEGIN

     x_msg_count := 0;
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

     IF g_debug_mode = 'Y' THEN
            Pa_Debug.set_curr_function( p_function   => 'validate',
                                        p_debug_mode => g_debug_mode );
     END IF;

     IF g_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Updating pji_mt_measure_sets_b for '||X_measure_set_code;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,Pa_Fp_Constants_Pkg.g_debug_level3);
     END IF;

	 BEGIN
		 SELECT object_version_number
		 INTO l_object_version_number
		 FROM pji_mt_measure_sets_B
		 WHERE measure_set_code = X_measure_set_code FOR UPDATE;
	 EXCEPTION
	 WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
        IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'select error while checking object version number in pji_mt_measure_sets_B '||X_measure_set_code;
             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
        END IF;
        RAISE;
	 END;

	 IF X_Object_Version_Number IS NOT NULL THEN
		 IF l_object_version_number <> X_Object_Version_Number THEN
		 	Fnd_Message.set_name('PJI', 'PJI_CM_UPDATE_CONFLICT');
			Fnd_Msg_Pub.add_detail(Fnd_Api.G_RET_STS_ERROR);
		 	RAISE l_update_conflict;
		 ELSE
		 	l_object_version_number := X_Object_Version_Number + 1;
		 END IF;
	 END IF;

     UPDATE pji_mt_measure_sets_B
     SET
            Measure_Set_Code = X_Measure_Set_Code
            , Measure_Set_Type = X_Measure_Set_Type
            , Measure_Format = X_Measure_Format
            , Db_Column_Name = X_Db_Column_Name
            , Object_Version_Number = l_object_version_number
            , Last_Update_Date = X_Last_Update_Date
            , Last_Updated_By = X_Last_Updated_By
            , Last_Update_Login = X_Last_Update_Login
			, Measure_Formula = X_Measure_Formula
			, Measure_Source = X_Measure_Source
            WHERE measure_set_code = X_measure_set_code;

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'NDF while updating pji_mt_measure_sets_B '||X_measure_set_code;
             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
        END IF;

        RAISE NO_DATA_FOUND;
     END IF;

     IF g_debug_mode = 'Y' THEN
            Pa_Debug.g_err_stage:= 'Updating pji_mt_measure_sets_tl for '||X_measure_set_code;
            Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,Pa_Fp_Constants_Pkg.g_debug_level3);
     END IF;

     UPDATE pji_mt_measure_sets_tl
     SET    Name = X_Name,
            Description = X_Description,
            Last_Update_Date = X_Last_Update_Date,
            Last_Updated_By = X_Last_Updated_By,
            Last_Update_Login = X_Last_Update_Login,
            Source_Lang = USERENV('Lang')
     WHERE  Measure_Set_Code = X_Measure_Set_Code
     AND    USERENV('Lang') IN (LANGUAGE, Source_Lang);

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'NDF while updating pji_mt_measure_sets_T '||X_measure_set_code;
             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
        END IF;

        RAISE NO_DATA_FOUND;
     END IF;

  EXCEPTION
  WHEN  NO_DATA_FOUND THEN

    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    l_msg_count := Fnd_Msg_Pub.count_msg;

    IF l_msg_count = 1 AND x_msg_data IS NULL THEN
       Pa_Interface_Utils_Pub.get_messages
           (p_encoded        => Fnd_Api.G_TRUE
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
            Pa_Debug.reset_curr_function;
    END IF;

    RAISE NO_DATA_FOUND;

  WHEN OTHERS THEN

    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;

    Fnd_Msg_Pub.add_exc_msg
       ( p_pkg_name        => 'PJI_MT_MEASURE_SETS_PKG'
       ,p_procedure_name  => 'UPDATE_ROW'
       ,p_error_text      => x_msg_data);

   IF g_debug_mode = 'Y' THEN
      Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                             Pa_Fp_Constants_Pkg.g_debug_level5);
      Pa_Debug.reset_curr_function;
   END IF;


 RAISE;
END Update_Row;

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
)
IS

   User_Id NUMBER := NULL;
   X_ROWID VARCHAR2(64);
   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data               VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out   NUMBER;
 BEGIN
   g_debug_mode:='N';

   IF (X_Owner = 'SEED')THEN
       User_Id := 1;
   ELSE
       User_Id := 0;
   END IF;



  Pji_Mt_Measure_Sets_Pkg.Update_Row (
     X_Measure_Set_Code                   => X_Measure_Set_Code
     , X_Measure_Set_Type                 => X_Measure_Set_Type
     , X_Measure_Format                   => X_Measure_Format
     , X_DB_Column_Name                   => X_DB_Column_Name
     , X_Object_Version_Number            => NULL
     , X_Name                             => X_Name
     , X_Description                      => X_Description
     , X_Last_Update_Date                 => SYSDATE
     , X_Last_Updated_By                  => User_Id
     , X_Last_Update_Login                => 0
	 , X_Measure_Formula				  => X_Measure_Formula
	 , X_Measure_Source					  => X_Measure_Source
     , X_Return_Status	                  => l_Return_Status
     , X_Msg_Data                         => l_Msg_Data
     , X_Msg_Count                        => l_Msg_Count);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	Hr_Utility.trace('Calling Insert row');
      Pji_Mt_Measure_Sets_Pkg.Insert_Row (
            X_Rowid                            => X_Rowid
          , X_Measure_Set_Code                 => X_Measure_Set_Code
          , X_Measure_Set_Type                 => X_Measure_Set_Type
          , X_Measure_Format                   => X_Measure_Format
          , X_DB_Column_Name                   => X_DB_Column_Name
          , X_Object_Version_Number            => 1
          , X_Name                             => X_Name
          , X_Description                      => X_Description
          , X_Last_Update_Date                 => SYSDATE
          , X_Last_Updated_By                  => User_Id
          , X_Creation_Date                    => SYSDATE
          , X_Created_By                       => User_Id
          , X_Last_Update_Login                => 0
		  , X_Measure_Formula				   => X_Measure_Formula
	 	  , X_Measure_Source				   => X_Measure_Source
          , X_Return_Status	                   => l_Return_Status
          , X_Msg_Data                         => l_Msg_Data
          , X_Msg_Count                        => l_Msg_Count);

     WHEN OTHERS THEN

     l_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     l_msg_count     := 1;
     l_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
        ( p_pkg_name        => 'PJI_MT_MEASURE_SETS_PKG'
        ,p_procedure_name  => 'UPDATE_ROW'
        ,p_error_text      => l_msg_data);

    IF g_debug_mode = 'Y' THEN
       Pa_Debug.g_err_stage:= 'Unexpected Error'||l_msg_data;
       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              Pa_Fp_Constants_Pkg.g_debug_level5);
       Pa_Debug.reset_curr_function;
    END IF;


    RAISE;
 END Load_Row;


 PROCEDURE Add_Language
 IS
 BEGIN

  DELETE FROM pji_mt_measure_sets_tl T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM pji_mt_measure_sets_b B
    WHERE B.measure_set_code  = T.measure_set_code
    );

  UPDATE pji_mt_measure_sets_tl T SET (
      NAME,
      DESCRIPTION
    ) = (SELECT
      B.NAME,
      B.DESCRIPTION
    FROM pji_mt_measure_sets_tl B
    WHERE B.measure_set_code = T.measure_set_code
    AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (
      T.measure_set_code,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.measure_set_code,
      SUBT.LANGUAGE
    FROM pji_mt_measure_sets_tl SUBB, pji_mt_measure_sets_tl SUBT
    WHERE SUBB.measure_set_code = SUBT.measure_set_code
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.NAME <> SUBT.NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

   INSERT INTO pji_mt_measure_sets_tl(
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    measure_set_code,
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
    B.measure_set_code,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM pji_mt_measure_sets_tl B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM pji_mt_measure_sets_tl T
    WHERE T.measure_set_code = B.measure_set_code
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW (
  X_measure_set_code                  IN pji_mt_measure_sets_b.measure_set_code%TYPE,
  X_owner                             IN VARCHAR2 ,
  X_name                              IN pji_mt_measure_sets_TL.NAME%TYPE,
  X_description                       IN pji_mt_measure_sets_TL.DESCRIPTION%TYPE
 )IS
BEGIN

  g_debug_mode:='N';

  UPDATE pji_mt_measure_sets_tl SET
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE  = SYSDATE,
    LAST_UPDATED_BY   = DECODE(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = USERENV('LANG')
  WHERE measure_set_code = x_measure_set_code
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG) ;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END TRANSLATE_ROW;


END Pji_Mt_Measure_Sets_Pkg;

/

--------------------------------------------------------
--  DDL for Package Body PJI_MT_MEASURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_MT_MEASURES_PKG" as
/* $Header: PJIMTMDB.pls 120.1 2005/05/31 07:58:41 appldev  $ */


-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------

g_module_name   VARCHAR2(100) 	:= 'pa.plsql.pji_mt_measures_pkg';
g_debug_mode	VARCHAR2(1)	:= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

-- -----------------------------------------------------------------------
-- This api locks the row in Pji_Mt_Measures_B before updating
-- -----------------------------------------------------------------------

procedure LOCK_ROW (
	p_measure_id		IN	pji_mt_measures_b.measure_id%TYPE,
	p_OBJECT_VERSION_NUMBER IN	pji_mt_measures_b.OBJECT_VERSION_NUMBER%TYPE
 ) is

  cursor c is
    select OBJECT_VERSION_NUMBER
    from   PJI_MT_MEASURES_B
    where  MEASURE_ID = p_measure_id
    for update of measure_id nowait;

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

  if recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

end LOCK_ROW;


-- -----------------------------------------------------------------------

procedure DELETE_ROW (
	p_measure_id		IN	pji_mt_measures_b.measure_id%TYPE
) is


begin
  delete from PJI_MT_MEASURES_TL
  where measure_id = p_measure_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PJI_MT_MEASURES_B
  where measure_id = p_measure_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


-- -----------------------------------------------------------------------

procedure INSERT_ROW(

	X_rowid		 IN OUT NOCOPY  rowid,

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,

	X_measure_set_code	IN	pji_mt_measures_b.measure_set_code%type,
	X_measure_code		IN	pji_mt_measures_b.measure_code%type,
	X_xtd_type		IN	pji_mt_measures_b.xtd_type%type,
	X_pl_sql_api		IN	pji_mt_measures_b.pl_sql_api%type,
	X_object_version_number	IN	pji_mt_measures_b.object_version_number%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_last_update_date	IN      pji_mt_measures_b.last_update_date%Type,
	X_last_updated_by	IN	pji_mt_measures_b.last_updated_by%Type,
	X_creation_date		IN 	pji_mt_measures_b.creation_date%Type,
	X_created_by		IN	pji_mt_measures_b.created_by%Type,
	X_last_update_Login	IN	pji_mt_measures_b.last_update_Login%Type,

	X_return_status	 OUT NOCOPY  VARCHAR2,
	X_msg_data	 OUT NOCOPY  VARCHAR2,
	X_msg_count	 OUT NOCOPY  NUMBER

) is

l_measure_id		pji_mt_measures_b.MEASURE_ID%type;

   cursor C is select ROWID from pji_mt_measures_b
   	where MEASURE_ID = l_measure_id;

 l_return_status	VARCHAR2(1) 	:= NULL;
 l_msg_count        	NUMBER      	:= 0;
 l_data             	VARCHAR2(2000) 	:= NULL;
 l_msg_data          	VARCHAR2(2000) 	:= NULL;
 l_msg_index_out 	NUMBER;


begin

   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF g_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'validate',
                                      p_debug_mode => g_debug_mode );
   END IF;

   select nvl(X_MEASURE_ID,PJI_MT_MEASURES_S.nextval)
   into   l_measure_id
   from   dual;

   IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in pji_mt_measures_b'||to_char(l_measure_id);
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

   INSERT INTO Pji_Mt_Measures_B
   (
	measure_id,
	measure_set_code,
	measure_code,
	xtd_type,
	pl_sql_api,
	object_version_number,

	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login
   )
   VALUES
   (
	l_measure_id,
	X_measure_set_code,
	X_measure_code,
	X_xtd_type,
	X_pl_sql_api,
	X_object_version_number,

	X_last_update_date,
	X_last_updated_by,
	X_creation_date,
	X_created_by,
	X_last_update_login
   );


   IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Inserting record in pji_mt_Measures_tl'||to_char(l_measure_id);
        pa_debug.write(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level3);

   END IF;

   INSERT INTO pji_mt_measures_tl
   (
	measure_id,

	name,
	description,

	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,

	language,
	source_lang
   )
   SELECT
	l_measure_id,

	X_name,
	X_description,

	X_last_update_date,
	X_last_updated_by,
	X_creation_date,
	X_created_by,
	X_last_update_login,

	L.Language_Code,
	Userenv('Lang')

   FROM  Fnd_Languages L
   WHERE L.Installed_Flag In ('I', 'B')
   AND NOT EXISTS
       (SELECT NULL FROM Pji_Mt_Measures_Tl T
        WHERE T.Measure_Id = L_Measure_Id
        AND T.Language = L.Language_Code);

   OPEN C;
   FETCH C INTO X_ROWID;
   IF (C%NOTFOUND) THEN

      CLOSE C;
      IF g_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Rowid could not be fetched after Inserting for'||to_char(l_measure_id);
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

      IF g_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
      END IF;

      RETURN;

    WHEN others THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
         ( p_pkg_name        => 'PJI_MT_MEASURES_PKG'
         ,p_procedure_name  => 'Insert Row'
         ,p_error_text      => x_msg_data);

     IF g_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                               pa_fp_constants_pkg.g_debug_level5);
        pa_debug.reset_curr_function;
     END IF;

     RAISE;

END INSERT_ROW;


-- -----------------------------------------------------------------------

procedure UPDATE_ROW (

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,
	X_measure_set_code	IN	pji_mt_measures_b.measure_set_code%type,
	X_measure_code		IN	pji_mt_measures_b.measure_code%type,
	X_xtd_type		IN	pji_mt_measures_b.xtd_type%type,
	X_pl_sql_api		IN	pji_mt_measures_b.pl_sql_api%type,
	X_object_version_number	IN	pji_mt_measures_b.object_version_number%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_last_update_date	IN      pji_mt_measures_b.last_update_date%Type,
	X_last_updated_by	IN	pji_mt_measures_b.last_updated_by%Type,
	X_last_update_login	IN	pji_mt_measures_b.last_update_login%Type,

	X_return_status	 OUT NOCOPY  VARCHAR2,
	X_msg_data	 OUT NOCOPY  VARCHAR2,
	X_msg_count	 OUT NOCOPY  NUMBER

) IS


l_return_status VARCHAR2(1) 	:= NULL;
l_msg_count     NUMBER      	:= 0;
l_data          VARCHAR2(2000) 	:= NULL;
l_msg_data     	VARCHAR2(2000) 	:= NULL;
l_msg_index_out	NUMBER;


begin

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF g_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'validate',
                                        p_debug_mode => g_debug_mode );
     END IF;

     IF g_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Updating Pji_Mt_Measures_B for'||to_char(X_measure_id);
          pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     UPDATE Pji_Mt_Measures_B
     SET

	measure_set_code	= X_measure_set_code,
	measure_code		= X_measure_code,
	xtd_type		= X_xtd_type,
	pl_sql_api		= X_pl_sql_api,
	object_version_number 	= X_object_version_number

      where Measure_Id           = X_Measure_Id;

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating Pji_Mt_Measures_B'||to_char(X_measure_id);
             pa_debug.write(g_module_name,pa_debug.g_err_stage, pa_fp_constants_pkg.g_debug_level5);
        END IF;
        RAISE NO_DATA_FOUND;
     END IF;

     IF g_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Updating Pji_Mt_Measures_Tl for'||to_char(X_measure_id);
            pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level3);
     END IF;

     UPDATE Pji_Mt_Measures_Tl
     SET
	Name = X_Name,
        Description = X_Description,
        Last_Update_Date = X_Last_Update_Date,
        Last_Updated_By = X_Last_Updated_By,
        Last_Update_Login = X_Last_Update_Login,
	Source_Lang = Userenv('Lang')
     WHERE  Measure_Id = X_Measure_Id
     AND    Userenv('Lang') In (Language, Source_Lang);

     IF (SQL%NOTFOUND) THEN
        IF g_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'NDF while updating Pa_Spread_Curves_T'||to_char(X_measure_id);
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

    IF g_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
    END IF;

    RAISE NO_DATA_FOUND;

  WHEN others THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;

    FND_MSG_PUB.add_exc_msg
       ( p_pkg_name        => 'PJI_MT_MEASURES_PKG'
       ,p_procedure_name  => 'UPDATE_ROW'
       ,p_error_text      => x_msg_data);

   IF g_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
      pa_debug.write(g_module_name,pa_debug.g_err_stage,
                             pa_fp_constants_pkg.g_debug_level5);
      pa_debug.reset_curr_function;
   END IF;

 RAISE;

END UPDATE_ROW;

-- -----------------------------------------------------------------------

procedure LOAD_ROW (

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,

	X_measure_set_code	IN	pji_mt_measures_b.measure_set_code%type,
	X_measure_code		IN	pji_mt_measures_b.measure_code%type,
	X_xtd_type		IN	pji_mt_measures_b.xtd_type%type,
	X_pl_sql_api		IN	pji_mt_measures_b.pl_sql_api%type,
	X_object_version_number	IN	pji_mt_measures_b.object_version_number%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_owner			IN	VARCHAR2
) IS


User_Id 	NUMBER 		:= Null;
X_ROWID 	VARCHAR2(64);
l_return_status VARCHAR2(1) 	:= NULL;
l_msg_count     NUMBER      	:= 0;
l_data          VARCHAR2(2000) 	:= NULL;
l_msg_data      VARCHAR2(2000) 	:= NULL;
l_msg_index_out NUMBER;


begin

   g_debug_mode := 'N';

   IF (X_Owner = 'SEED')THEN
       User_Id := 1;
   ELSE
       User_Id := 0;
   END IF;

   Pji_Mt_Measures_Pkg.Update_Row (

     	X_Measure_Id            =>   	X_Measure_Id,

	X_measure_set_code	=>	X_measure_set_code,
	X_measure_code		=>	X_measure_code,
	X_xtd_type		=>	X_xtd_type,
	X_pl_sql_api		=>	X_pl_sql_api,
	X_object_version_number	=>	X_object_version_number,

     	X_Name                  =>   	X_Name,
     	X_Description           =>   	X_Description,

     	X_Last_Update_Date      =>   	Sysdate,
     	X_Last_Updated_By       =>   	User_Id,
     	X_Last_Update_Login     =>   	0,

     	X_Return_Status	        =>   	l_Return_Status,
     	X_Msg_Data              =>   	l_Msg_Data,
     	X_Msg_Count             =>     	l_Msg_Count
);


  EXCEPTION
    WHEN no_data_found then

      Pji_Mt_Measures_Pkg.Insert_Row (

        X_Rowid                            =>   X_Rowid,

     	X_Measure_Id            =>   	X_Measure_Id,

	X_measure_set_code	=>	X_measure_set_code,
	X_measure_code		=>	X_measure_code,
	X_xtd_type		=>	X_xtd_type,
	X_pl_sql_api		=>	X_pl_sql_api,
	X_object_version_number	=>	X_object_version_number,

     	X_Name                  =>   	X_Name,
     	X_Description           =>   	X_Description,

	X_Creation_Date         =>   	Sysdate,
        X_Created_By            =>   	User_Id,
     	X_Last_Update_Date      =>   	Sysdate,
     	X_Last_Updated_By       =>   	User_Id,
     	X_Last_Update_Login     =>   	0,

     	X_Return_Status	        =>   	l_Return_Status,
     	X_Msg_Data              =>   	l_Msg_Data,
     	X_Msg_Count             =>     	l_Msg_Count


);

     WHEN others THEN

     l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_msg_count     := 1;
     l_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => 'PJI_MT_MEASURES_PKG'
        ,p_procedure_name  => 'UPDATE_ROW'
        ,p_error_text      => l_msg_data);

    IF g_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:= 'Unexpected Error'||l_msg_data;
       pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              pa_fp_constants_pkg.g_debug_level5);
       pa_debug.reset_curr_function;
    END IF;

    RAISE;

 END LOAD_ROW;


-- -----------------------------------------------------------------------

procedure ADD_LANGUAGE

IS

begin

  delete from PJI_MT_MEASURES_TL T
  where not exists
    (select NULL
    from PJI_MT_MEASURES_B B
    where B.MEASURE_ID  = T.MEASURE_ID
    );

  update PJI_MT_MEASURES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PJI_MT_MEASURES_TL B
    where B.MEASURE_ID = T.MEASURE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
    where (
      T.MEASURE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MEASURE_ID,
      SUBT.LANGUAGE
    from PJI_MT_MEASURES_TL SUBB, PJI_MT_MEASURES_TL SUBT
    where SUBB.MEASURE_ID = SUBT.MEASURE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

   insert into PJI_MT_MEASURES_TL (

    MEASURE_ID,

    NAME,
    DESCRIPTION,

    LANGUAGE,
    SOURCE_LANG,

    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY

  )select
    B.MEASURE_ID,

    B.NAME,
    B.DESCRIPTION,

    L.LANGUAGE_CODE,
    B.SOURCE_LANG,

    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY

  from PJI_MT_MEASURES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PJI_MT_MEASURES_TL T
    where T.MEASURE_ID = B.MEASURE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


-- -----------------------------------------------------------------------

procedure TRANSLATE_ROW (

	X_MEASURE_ID	in PJI_MT_MEASURES_B.MEASURE_ID%TYPE,

	X_NAME		in PJI_MT_MEASURES_TL.NAME%TYPE,
	X_DESCRIPTION	in  PJI_MT_MEASURES_TL.DESCRIPTION%TYPE,

	X_OWNER		in VARCHAR2

) is


begin

g_debug_mode := 'N';


  update PJI_MT_MEASURES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = USERENV('LANG')
  where MEASURE_ID = X_MEASURE_ID
  and  USERENV('LANG') IN (LANGUAGE, SOURCE_LANG) ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

-- -----------------------------------------------------------------------

end PJI_MT_MEASURES_PKG;

/

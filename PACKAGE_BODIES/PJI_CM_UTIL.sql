--------------------------------------------------------
--  DDL for Package Body PJI_CM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_CM_UTIL" AS
/* $Header: PJIRX17B.pls 120.3 2007/10/24 04:07:28 paljain ship $ */
g_debug_mode       VARCHAR2(1)   :=NVL(Fnd_Profile.value('PA_DEBUG_MODE'), 'N');
PROCEDURE Generate_CM_Procedure(
x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
) IS
l_counter NUMBER :=1;
l_declare VARCHAR2(10000);
l_stat VARCHAR2(20000);
l_char VARCHAR2(1);
BEGIN

	 IF x_return_status IS NULL THEN
	 	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
		x_msg_count :=0;
	 END IF;

	 l_stat := ' CREATE OR REPLACE PACKAGE PJI_CALC_ENGINE AS '
	 		   || 'PROCEDURE Compute_Fp_Measures('
			   || ' p_seeded_measures SYSTEM.PA_Num_Tbl_Type := SYSTEM.PA_Num_Tbl_Type() '
			   || ', x_custom_measures OUT NOCOPY SYSTEM.PA_Num_Tbl_Type'
			   || ', x_return_status IN OUT NOCOPY VARCHAR2 '
	  		   || ', x_msg_count IN OUT NOCOPY NUMBER '
			   || ', x_msg_data IN OUT NOCOPY VARCHAR2 '
			   || '); '
	 		   || ' PROCEDURE Compute_AC_Measures('
			   || ' p_seeded_measures SYSTEM.PA_Num_Tbl_Type := SYSTEM.PA_Num_Tbl_Type() '
			   || ', x_custom_measures OUT NOCOPY SYSTEM.PA_Num_Tbl_Type'
			   || ', x_return_status IN OUT NOCOPY VARCHAR2 '
	  		   || ', x_msg_count IN OUT NOCOPY NUMBER '
			   || ', x_msg_data IN OUT NOCOPY VARCHAR2 '
			   || ');'
			   || ' END PJI_CALC_ENGINE; ';

	EXECUTE IMMEDIATE l_stat;

	 l_stat := ' CREATE OR REPLACE PACKAGE BODY PJI_CALC_ENGINE AS '
	 		   || Generate_Procedure_String('FP')
	 		   || Generate_Procedure_String('AC')
			   || ' END PJI_CALC_ENGINE; ';

	COMMIT;

/*	l_counter :=1;
	WHILE l_counter <= LENGTH(l_stat) LOOP
		l_char := SUBSTR(l_stat,l_counter,1);
		IF  l_char = ';' OR l_char = ',' THEN
		  DBMS_OUTPUT.Put_line(l_char);
		ELSE
		  DBMS_OUTPUT.Put(l_char);
		END IF;
		l_counter := l_counter+1;
	END LOOP;
*/	EXECUTE IMMEDIATE l_stat;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	x_msg_count := x_msg_count + 1;
--	DBMS_OUTPUT.put_line(SQLERRM);
	RAISE;
END;

FUNCTION Generate_Procedure_String(
p_measure_source IN VARCHAR2)
RETURN VARCHAR2
IS

l_stat VARCHAR2(20000);
l_db_column_name VARCHAR2(80);
l_measure_formula VARCHAR2(2000);
l_counter NUMBER :=1;

CURSOR c_custom_measure IS
SELECT measure_formula
FROM pji_mt_measure_sets_b
WHERE measure_source = p_measure_source
AND measure_set_type = 'CUSTOM_CALC'
ORDER BY measure_set_code;

CURSOR c_seeded_measure IS
SELECT db_column_name
FROM pji_mt_measure_sets_b
WHERE measure_source = p_measure_source
AND db_column_name IS NOT NULL
AND measure_set_type = 'SEEDED'
AND measure_set_code NOT IN ('PPF_MSR_ACWP')
ORDER BY measure_set_code;

BEGIN
	 l_stat :=  ' PROCEDURE Compute_'|| p_measure_source || '_Measures('
			   || ' p_seeded_measures SYSTEM.PA_Num_Tbl_Type'
			   || ', x_custom_measures OUT NOCOPY SYSTEM.PA_Num_Tbl_Type'
			   || ', x_return_status IN OUT NOCOPY VARCHAR2 '
			   || ', x_msg_count IN OUT NOCOPY NUMBER '
			   || ', x_msg_data IN OUT NOCOPY VARCHAR2 '
			   || ') IS ';

	l_counter := 1;
	OPEN c_seeded_measure;
	LOOP
		FETCH c_seeded_measure INTO l_db_column_name;
		EXIT WHEN c_seeded_measure%NOTFOUND;
		l_stat := l_stat || l_db_column_name || ' NUMBER := p_seeded_measures('|| l_counter ||'); ';
		l_counter := l_counter + 1;
	END LOOP;
	CLOSE c_seeded_measure;

	l_stat := l_stat || ' BEGIN '
		   	  		 || ' x_custom_measures := SYSTEM.PA_Num_Tbl_Type(); '
		   	  		 || ' x_custom_measures.extend(15); '
		   	  		 ||  ' x_msg_count := 0; '
		   	  		 ||  ' x_return_status := Fnd_Api.G_RET_STS_SUCCESS; ' ;

	l_counter := 1;
	OPEN c_custom_measure;
	LOOP
		FETCH c_custom_measure INTO l_measure_formula;
		EXIT WHEN c_custom_measure%NOTFOUND;
		l_stat := l_stat || 'BEGIN x_custom_measures(' || l_counter || ') := ';
		IF (l_measure_formula IS NOT NULL) AND (LENGTH(l_measure_formula) > 0) THEN
			l_stat := l_stat || l_measure_formula || ';';--'NVL(' || l_measure_formula || ',0); ';
		ELSE
			l_stat := l_stat || ' NULL; ';
		END IF;
		l_stat := l_stat || ' EXCEPTION '
			   	  		 || ' WHEN ZERO_DIVIDE THEN '
						 || ' x_custom_measures(' || l_counter || ') := 0; '
						 || ' x_return_status := Pji_Rep_Util.G_RET_STS_WARNING; '
						 || ' x_msg_count := x_msg_count + 1; '
						 || ' END; ';
		l_counter := l_counter + 1;
	END LOOP;
	CLOSE c_custom_measure;

	l_stat := l_stat || ' END  Compute_'|| p_measure_source || '_Measures; ';
	RETURN l_stat;
END Generate_Procedure_String;



PROCEDURE Apply_Measure(p_itd_measure_id    IN pji_mt_measures_b.measure_id%TYPE
                       ,p_ptd_measure_id    IN pji_mt_measures_b.measure_id%TYPE
		       ,p_itd_name          IN pji_mt_measures_tl.name%TYPE
		       ,p_ptd_name          IN pji_mt_measures_tl.name%TYPE
		       ,p_qtd_measure_id    IN pji_mt_measures_b.measure_id%TYPE
                       ,p_ytd_measure_id    IN pji_mt_measures_b.measure_id%TYPE
		       ,p_qtd_name          IN pji_mt_measures_tl.name%TYPE
		       ,p_ytd_name          IN pji_mt_measures_tl.name%TYPE
		       ,p_measure_set_code  IN pji_mt_measures_b.measure_set_code%TYPE
		       ,p_last_update_date  IN      pji_mt_measures_b.last_update_date%TYPE
                       ,p_last_updated_by   IN	pji_mt_measures_b.last_updated_by%TYPE
			,p_creation_date    IN 	pji_mt_measures_b.creation_date%TYPE
			,p_created_by	    IN	pji_mt_measures_b.created_by%TYPE
			,p_last_update_Login IN	pji_mt_measures_b.last_update_Login%TYPE
			,X_return_status     OUT NOCOPY  VARCHAR2
			,X_msg_data	     OUT NOCOPY  VARCHAR2
			,X_msg_count	     OUT NOCOPY  NUMBER
 )  AS
l_return_status  VARCHAR2(1) :=Fnd_Api.G_RET_STS_SUCCESS;
l_msg_count NUMBER :=0;
l_msg_data VARCHAR2(200);
l_itd_measure_id NUMBER;
l_ptd_measure_id NUMBER ;
l_qtd_measure_id NUMBER;
l_ytd_measure_id NUMBER ;
l_measure_set_code VARCHAR2(300):=p_measure_set_code;
l_msg_index_out NUMBER;
l_data VARCHAR2(200);
l_rowid ROWID;
BEGIN
 X_return_status :=Fnd_Api.G_RET_STS_SUCCESS;
   IF p_itd_measure_id IS NOT NULL THEN
      IF p_itd_name IS NOT NULL THEN
         UPDATE Pji_Mt_Measures_Tl
            SET Name = p_itd_name,
		Last_Update_Date =p_last_update_date,
		Last_Updated_By = p_last_updated_by,
		Last_Update_Login = p_last_update_login,
		Source_Lang = USERENV('Lang')
	WHERE   Measure_Id = p_itd_measure_id
	  AND   USERENV('Lang') IN (LANGUAGE, Source_Lang);
        IF (SQL%NOTFOUND) THEN
           IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'while updating pji_mt_measure_tl'||TO_CHAR(p_itd_measure_id);
             Pa_Debug.WRITE('Apply_changes',Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
           END IF;
           RAISE NO_DATA_FOUND;
        END IF;

     ELSE
     NULL;
/* Commented out ,if delete functionality is added it can  be uncommented
       delete from PJI_MT_MEASURES_TL
  where measure_id = l_itd_measure_id;

  delete from PJI_MT_MEASURES_B
  where measure_id = l_itd_measure_id;
*/
      --  PJI_MT_MEASURES_PKG.DELETE_ROW (p_measure_id	=>l_itd_measure_id);
     END IF;

    ELSE
        IF p_itd_name IS NOT NULL THEN

	       Pji_Mt_Measures_Pkg.INSERT_ROW(
		X_rowid                =>l_rowid,
		X_measure_id           =>l_itd_measure_id ,
		X_measure_set_code     =>p_measure_set_code,
		X_measure_code         =>l_measure_set_code||'_ITD',
		X_xtd_type             =>'ITD',
                X_pl_sql_api	=>NULL,
		X_object_version_number =>1,
		X_name                  =>p_itd_name,
		X_description           =>p_itd_name,
		X_last_update_date      =>p_last_update_date,
		X_last_updated_by       =>p_last_updated_by,
		X_creation_date         =>p_creation_date,
		X_created_by            =>p_created_by,
		X_last_update_Login     =>p_last_update_Login,
		X_return_status         =>l_return_status,
		X_msg_data              =>l_msg_data,
		X_msg_count             =>l_msg_count);

	END IF;
    END IF;
    IF p_ptd_measure_id IS NOT NULL THEN
    IF p_ptd_name IS NOT NULL THEN

       UPDATE Pji_Mt_Measures_Tl
          SET   Name = p_ptd_name,
		Last_Update_Date =p_last_update_date,
		Last_Updated_By = p_last_updated_by,
		Last_Update_Login = p_last_update_login,
		Source_Lang = USERENV('Lang')
	WHERE   Measure_Id = p_ptd_measure_id
	  AND   USERENV('Lang') IN (LANGUAGE, Source_Lang);

        IF (SQL%NOTFOUND) THEN
           IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'while updating pji_mt_measure_tl'||TO_CHAR(p_ptd_measure_id);
             Pa_Debug.WRITE('pji_cm_util.Apply_changes',Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
            END IF;
            RAISE NO_DATA_FOUND;
        END IF;
      ELSE
NULL;
/* Commented out ,if delete functionality is added it can  be uncommented
       delete from PJI_MT_MEASURES_TL
  where measure_id = l_ptd_measure_id;

  delete from PJI_MT_MEASURES_B
  where measure_id = l_ptd_measure_id;
*/
      --   PJI_MT_MEASURES_PKG.DELETE_ROW (p_measure_id	=>l_ptd_measure_id);
      END IF;

    ELSE
        IF p_ptd_name IS NOT NULL THEN

	       Pji_Mt_Measures_Pkg.INSERT_ROW(
		X_rowid                =>l_rowid,
	        X_measure_id           =>l_ptd_measure_id ,
		X_measure_set_code     =>p_measure_set_code,
		X_measure_code         =>l_measure_set_code||'_PTD',
		X_xtd_type             =>'PTD',
                X_pl_sql_api	=>NULL,
                X_object_version_number =>1,
		X_name                  =>p_ptd_name,
		X_description           =>p_ptd_name,
		X_last_update_date      =>p_last_update_date,
		X_last_updated_by       =>p_last_updated_by,
		X_creation_date         =>p_creation_date,
		X_created_by            =>p_created_by,
		X_last_update_Login     =>p_last_update_Login,
		X_return_status         =>l_return_status,
		X_msg_data              =>l_msg_data,
		X_msg_count             =>l_msg_count);
	END IF;
    END IF;


     IF p_qtd_measure_id IS NOT NULL THEN
      IF p_qtd_name IS NOT NULL THEN
         UPDATE Pji_Mt_Measures_Tl
            SET Name = p_qtd_name,
		Last_Update_Date =p_last_update_date,
		Last_Updated_By = p_last_updated_by,
		Last_Update_Login = p_last_update_login,
		Source_Lang = USERENV('Lang')
	WHERE   Measure_Id = p_qtd_measure_id
	  AND   USERENV('Lang') IN (LANGUAGE, Source_Lang);
        IF (SQL%NOTFOUND) THEN
           IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'while updating pji_mt_measure_tl'||TO_CHAR(p_qtd_measure_id);
             Pa_Debug.WRITE('Apply_changes',Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
           END IF;
           RAISE NO_DATA_FOUND;
        END IF;

     ELSE
     NULL;
     END IF;

    ELSE
        IF p_qtd_name IS NOT NULL THEN

	       Pji_Mt_Measures_Pkg.INSERT_ROW(
		X_rowid                =>l_rowid,
		X_measure_id           =>l_qtd_measure_id ,
		X_measure_set_code     =>p_measure_set_code,
		X_measure_code         =>l_measure_set_code||'_QTD',
		X_xtd_type             =>'QTD',
                X_pl_sql_api	=>NULL,
		X_object_version_number =>1,
		X_name                  =>p_qtd_name,
		X_description           =>p_qtd_name,
		X_last_update_date      =>p_last_update_date,
		X_last_updated_by       =>p_last_updated_by,
		X_creation_date         =>p_creation_date,
		X_created_by            =>p_created_by,
		X_last_update_Login     =>p_last_update_Login,
		X_return_status         =>l_return_status,
		X_msg_data              =>l_msg_data,
		X_msg_count             =>l_msg_count);

	END IF;
    END IF;


     IF p_ytd_measure_id IS NOT NULL THEN
      IF p_ytd_name IS NOT NULL THEN
         UPDATE Pji_Mt_Measures_Tl
            SET Name = p_ytd_name,
		Last_Update_Date =p_last_update_date,
		Last_Updated_By = p_last_updated_by,
		Last_Update_Login = p_last_update_login,
		Source_Lang = USERENV('Lang')
	WHERE   Measure_Id = p_ytd_measure_id
	  AND   USERENV('Lang') IN (LANGUAGE, Source_Lang);
        IF (SQL%NOTFOUND) THEN
           IF g_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'while updating pji_mt_measure_tl'||TO_CHAR(p_ytd_measure_id);
             Pa_Debug.WRITE('Apply_changes',Pa_Debug.g_err_stage, Pa_Fp_Constants_Pkg.g_debug_level5);
           END IF;
           RAISE NO_DATA_FOUND;
        END IF;

     ELSE
     NULL;
     END IF;

    ELSE
        IF p_ytd_name IS NOT NULL THEN

	       Pji_Mt_Measures_Pkg.INSERT_ROW(
		X_rowid                =>l_rowid,
		X_measure_id           =>l_ytd_measure_id ,
		X_measure_set_code     =>p_measure_set_code,
		X_measure_code         =>l_measure_set_code||'_YTD',
		X_xtd_type             =>'YTD',
                X_pl_sql_api	=>NULL,
		X_object_version_number =>1,
		X_name                  =>p_ytd_name,
		X_description           =>p_ytd_name,
		X_last_update_date      =>p_last_update_date,
		X_last_updated_by       =>p_last_updated_by,
		X_creation_date         =>p_creation_date,
		X_created_by            =>p_created_by,
		X_last_update_Login     =>p_last_update_Login,
		X_return_status         =>l_return_status,
		X_msg_data              =>l_msg_data,
		X_msg_count             =>l_msg_count);

	END IF;
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
       ( p_pkg_name        => 'PJI_CM_UTIL'
       ,p_procedure_name  => 'Apply_Measure'
       ,p_error_text      => x_msg_data);

   IF g_debug_mode = 'Y' THEN
      Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
      Pa_Debug.WRITE('pji_cm_util.apply_changes',Pa_Debug.g_err_stage,
                             Pa_Fp_Constants_Pkg.g_debug_level5);
      Pa_Debug.reset_curr_function;
   END IF;
END Apply_Measure;





END Pji_Cm_Util;

/

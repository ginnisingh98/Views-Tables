--------------------------------------------------------
--  DDL for Package Body GMD_PROC_PARAMS_MIGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_PROC_PARAMS_MIGR" as
/* $Header: GMDPROCB.pls 120.1 2005/10/05 06:51:15 txdaniel noship $ */

  P_run_id   NUMBER;
  P_line_no  NUMBER DEFAULT 0;

  PROCEDURE check_process_parameter IS
    CURSOR Cur_check_param1 IS
      SELECT  1
      FROM    sys.dual
      WHERE EXISTS (SELECT 1
                    FROM   GMD_OPERATION_RESOURCES
                    WHERE  process_parameter_1 IS NOT NULL
                    UNION
                    SELECT 1
                    FROM   GMD_RECIPE_ORGN_RESOURCES
                    WHERE  process_parameter_1 IS NOT NULL
                    UNION
                    SELECT 1
                    FROM   GME_BATCH_STEP_RESOURCES
                    WHERE  process_parameter_1 IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                      FROM GMP_PROCESS_PARAMETERS_B
                      WHERE parameter_id = 1);

    CURSOR Cur_check_param2 IS
      SELECT  1
      FROM    sys.dual
      WHERE EXISTS (SELECT 1
                    FROM   GMD_OPERATION_RESOURCES
                    WHERE  process_parameter_2 IS NOT NULL
                    UNION
                    SELECT 1
                    FROM   GMD_RECIPE_ORGN_RESOURCES
                    WHERE  process_parameter_2 IS NOT NULL
      		    UNION
      		    SELECT 1
      		    FROM   GME_BATCH_STEP_RESOURCES
      		    WHERE  process_parameter_2 IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                      FROM GMP_PROCESS_PARAMETERS_B
                      WHERE parameter_id = 2);

    CURSOR Cur_check_param3 IS
      SELECT  1
      FROM    sys.dual
      WHERE EXISTS (SELECT 1
                    FROM   GMD_OPERATION_RESOURCES
                    WHERE  process_parameter_3 IS NOT NULL
      		    UNION
      		    SELECT 1
     		    FROM   GMD_RECIPE_ORGN_RESOURCES
      		    WHERE  process_parameter_3 IS NOT NULL
      		    UNION
      		    SELECT 1
      		    FROM   GME_BATCH_STEP_RESOURCES
      		    WHERE  process_parameter_3 IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                      FROM GMP_PROCESS_PARAMETERS_B
                      WHERE parameter_id = 3);

    CURSOR Cur_check_param4 IS
      SELECT  1
      FROM    sys.dual
      WHERE EXISTS (SELECT 1
                    FROM   GMD_OPERATION_RESOURCES
                    WHERE  process_parameter_4 IS NOT NULL
      		    UNION
      		    SELECT 1
      		    FROM   GMD_RECIPE_ORGN_RESOURCES
      		    WHERE  process_parameter_4 IS NOT NULL
      		    UNION
      		    SELECT 1
      		    FROM   GME_BATCH_STEP_RESOURCES
      		    WHERE  process_parameter_4 IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                      FROM GMP_PROCESS_PARAMETERS_B
                      WHERE parameter_id = 4);

    CURSOR Cur_check_param5 IS
      SELECT  1
      FROM    sys.dual
      WHERE EXISTS (SELECT 1
                    FROM   GMD_OPERATION_RESOURCES
                    WHERE  process_parameter_5 IS NOT NULL
      		    UNION
      		    SELECT 1
      		    FROM   GMD_RECIPE_ORGN_RESOURCES
      		    WHERE  process_parameter_5 IS NOT NULL
      		    UNION
      		    SELECT 1
      		    FROM   GME_BATCH_STEP_RESOURCES
      		    WHERE  process_parameter_5 IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                      FROM GMP_PROCESS_PARAMETERS_B
                      WHERE parameter_id = 5);

    X_temp NUMBER;
    X_row_id VARCHAR2(100) DEFAULT NULL;
  BEGIN
    /* Open the cursor to check if process parameter1 has to be migrated */
    OPEN Cur_check_param1;
    FETCH Cur_check_param1 INTO X_temp;
    IF Cur_check_param1%FOUND THEN
    GMP_PROCESS_PARAMETERS_PKG.INSERT_ROW
    (X_ROWID                  => X_row_id,
     X_PARAMETER_ID           => 1,
     X_ATTRIBUTE21            => NULL,
     X_ATTRIBUTE22 	      => NULL,
     X_ATTRIBUTE23 	      => NULL,
     X_ATTRIBUTE24 	      => NULL,
     X_ATTRIBUTE25 	      => NULL,
     X_ATTRIBUTE26	      => NULL,
     X_ATTRIBUTE27 	      => NULL,
     X_ATTRIBUTE28 	      => NULL,
     X_ATTRIBUTE29 	      => NULL,
     X_ATTRIBUTE30 	      => NULL,
     X_ATTRIBUTE_CATEGORY     => NULL,
     X_ATTRIBUTE1	      => NULL,
     X_ATTRIBUTE2 	      => NULL,
     X_ATTRIBUTE3 	      => NULL,
     X_ATTRIBUTE4 	      => NULL,
     X_ATTRIBUTE5 	      => NULL,
     X_ATTRIBUTE6 	      => NULL,
     X_ATTRIBUTE7 	      => NULL,
     X_ATTRIBUTE8 	      => NULL,
     X_ATTRIBUTE9 	      => NULL,
     X_ATTRIBUTE10	      => NULL,
     X_ATTRIBUTE11 	      => NULL,
     X_ATTRIBUTE12 	      => NULL,
     X_ATTRIBUTE13	      => NULL,
     X_ATTRIBUTE14 	      => NULL,
     X_MAXIMUM_VALUE 	      => NULL,
     X_DELETE_MARK 	      => 0,
     X_TEXT_CODE 	      => NULL,
     X_ATTRIBUTE15 	      => NULL,
     X_ATTRIBUTE16 	      => NULL,
     X_ATTRIBUTE17 	      => NULL,
     X_ATTRIBUTE18 	      => NULL,
     X_ATTRIBUTE19 	      => NULL,
     X_ATTRIBUTE20 	      => NULL,
     X_PARAMETER_TYPE         => 1,
     X_MINIMUM_VALUE          => NULL,
     X_PARAMETER_NAME         => 'PROCESS_PARAMETER_1',
     X_UNITS 	              => NULL,
     X_PARAMETER_DESCRIPTION  => 'Process Parameter 1',
     X_CREATION_DATE  	      => SYSDATE,
     X_CREATED_BY 	      => 0,
     X_LAST_UPDATE_DATE       => SYSDATE,
     X_LAST_UPDATED_BY        => 0,
     X_LAST_UPDATE_LOGIN      => NULL);
    END IF;
    CLOSE Cur_check_param1;

    OPEN Cur_check_param2;
    FETCH Cur_check_param2 INTO X_temp;
    IF Cur_check_param2%FOUND THEN
    GMP_PROCESS_PARAMETERS_PKG.INSERT_ROW
    (X_ROWID                  => X_row_id,
     X_PARAMETER_ID           => 2,
     X_ATTRIBUTE21            => NULL,
     X_ATTRIBUTE22 	      => NULL,
     X_ATTRIBUTE23 	      => NULL,
     X_ATTRIBUTE24 	      => NULL,
     X_ATTRIBUTE25 	      => NULL,
     X_ATTRIBUTE26	      => NULL,
     X_ATTRIBUTE27 	      => NULL,
     X_ATTRIBUTE28 	      => NULL,
     X_ATTRIBUTE29 	      => NULL,
     X_ATTRIBUTE30 	      => NULL,
     X_ATTRIBUTE_CATEGORY     => NULL,
     X_ATTRIBUTE1	      => NULL,
     X_ATTRIBUTE2 	      => NULL,
     X_ATTRIBUTE3 	      => NULL,
     X_ATTRIBUTE4 	      => NULL,
     X_ATTRIBUTE5 	      => NULL,
     X_ATTRIBUTE6 	      => NULL,
     X_ATTRIBUTE7 	      => NULL,
     X_ATTRIBUTE8 	      => NULL,
     X_ATTRIBUTE9 	      => NULL,
     X_ATTRIBUTE10	      => NULL,
     X_ATTRIBUTE11 	      => NULL,
     X_ATTRIBUTE12 	      => NULL,
     X_ATTRIBUTE13	      => NULL,
     X_ATTRIBUTE14 	      => NULL,
     X_MAXIMUM_VALUE 	      => NULL,
     X_DELETE_MARK 	      => 0,
     X_TEXT_CODE 	      => NULL,
     X_ATTRIBUTE15 	      => NULL,
     X_ATTRIBUTE16 	      => NULL,
     X_ATTRIBUTE17 	      => NULL,
     X_ATTRIBUTE18 	      => NULL,
     X_ATTRIBUTE19 	      => NULL,
     X_ATTRIBUTE20 	      => NULL,
     X_PARAMETER_TYPE         => 1,
     X_MINIMUM_VALUE          => NULL,
     X_PARAMETER_NAME         => 'PROCESS_PARAMETER_2',
     X_UNITS 	              => NULL,
     X_PARAMETER_DESCRIPTION  => 'Process Parameter 2',
     X_CREATION_DATE  	      => SYSDATE,
     X_CREATED_BY 	      => 0,
     X_LAST_UPDATE_DATE       => SYSDATE,
     X_LAST_UPDATED_BY        => 0,
     X_LAST_UPDATE_LOGIN      => NULL);
    END IF;
    CLOSE Cur_check_param2;

    OPEN Cur_check_param3;
    FETCH Cur_check_param3 INTO X_temp;
    IF Cur_check_param3%FOUND THEN
    GMP_PROCESS_PARAMETERS_PKG.INSERT_ROW
    (X_ROWID                  => X_row_id,
     X_PARAMETER_ID           => 3,
     X_ATTRIBUTE21            => NULL,
     X_ATTRIBUTE22 	      => NULL,
     X_ATTRIBUTE23 	      => NULL,
     X_ATTRIBUTE24 	      => NULL,
     X_ATTRIBUTE25 	      => NULL,
     X_ATTRIBUTE26	      => NULL,
     X_ATTRIBUTE27 	      => NULL,
     X_ATTRIBUTE28 	      => NULL,
     X_ATTRIBUTE29 	      => NULL,
     X_ATTRIBUTE30 	      => NULL,
     X_ATTRIBUTE_CATEGORY     => NULL,
     X_ATTRIBUTE1	      => NULL,
     X_ATTRIBUTE2 	      => NULL,
     X_ATTRIBUTE3 	      => NULL,
     X_ATTRIBUTE4 	      => NULL,
     X_ATTRIBUTE5 	      => NULL,
     X_ATTRIBUTE6 	      => NULL,
     X_ATTRIBUTE7 	      => NULL,
     X_ATTRIBUTE8 	      => NULL,
     X_ATTRIBUTE9 	      => NULL,
     X_ATTRIBUTE10	      => NULL,
     X_ATTRIBUTE11 	      => NULL,
     X_ATTRIBUTE12 	      => NULL,
     X_ATTRIBUTE13	      => NULL,
     X_ATTRIBUTE14 	      => NULL,
     X_MAXIMUM_VALUE 	      => NULL,
     X_DELETE_MARK 	      => 0,
     X_TEXT_CODE 	      => NULL,
     X_ATTRIBUTE15 	      => NULL,
     X_ATTRIBUTE16 	      => NULL,
     X_ATTRIBUTE17 	      => NULL,
     X_ATTRIBUTE18 	      => NULL,
     X_ATTRIBUTE19 	      => NULL,
     X_ATTRIBUTE20 	      => NULL,
     X_PARAMETER_TYPE         => 1,
     X_MINIMUM_VALUE          => NULL,
     X_PARAMETER_NAME         => 'PROCESS_PARAMETER_3',
     X_UNITS 	              => NULL,
     X_PARAMETER_DESCRIPTION  => 'Process Parameter 3',
     X_CREATION_DATE  	      => SYSDATE,
     X_CREATED_BY 	      => 0,
     X_LAST_UPDATE_DATE       => SYSDATE,
     X_LAST_UPDATED_BY        => 0,
     X_LAST_UPDATE_LOGIN      => NULL);
    END IF;
    CLOSE Cur_check_param3;

    OPEN Cur_check_param4;
    FETCH Cur_check_param4 INTO X_temp;
    IF Cur_check_param4%FOUND THEN
    GMP_PROCESS_PARAMETERS_PKG.INSERT_ROW
    (X_ROWID                  => X_row_id,
     X_PARAMETER_ID           => 4,
     X_ATTRIBUTE21            => NULL,
     X_ATTRIBUTE22 	      => NULL,
     X_ATTRIBUTE23 	      => NULL,
     X_ATTRIBUTE24 	      => NULL,
     X_ATTRIBUTE25 	      => NULL,
     X_ATTRIBUTE26	      => NULL,
     X_ATTRIBUTE27 	      => NULL,
     X_ATTRIBUTE28 	      => NULL,
     X_ATTRIBUTE29 	      => NULL,
     X_ATTRIBUTE30 	      => NULL,
     X_ATTRIBUTE_CATEGORY     => NULL,
     X_ATTRIBUTE1	      => NULL,
     X_ATTRIBUTE2 	      => NULL,
     X_ATTRIBUTE3 	      => NULL,
     X_ATTRIBUTE4 	      => NULL,
     X_ATTRIBUTE5 	      => NULL,
     X_ATTRIBUTE6 	      => NULL,
     X_ATTRIBUTE7 	      => NULL,
     X_ATTRIBUTE8 	      => NULL,
     X_ATTRIBUTE9 	      => NULL,
     X_ATTRIBUTE10	      => NULL,
     X_ATTRIBUTE11 	      => NULL,
     X_ATTRIBUTE12 	      => NULL,
     X_ATTRIBUTE13	      => NULL,
     X_ATTRIBUTE14 	      => NULL,
     X_MAXIMUM_VALUE 	      => NULL,
     X_DELETE_MARK 	      => 0,
     X_TEXT_CODE 	      => NULL,
     X_ATTRIBUTE15 	      => NULL,
     X_ATTRIBUTE16 	      => NULL,
     X_ATTRIBUTE17 	      => NULL,
     X_ATTRIBUTE18 	      => NULL,
     X_ATTRIBUTE19 	      => NULL,
     X_ATTRIBUTE20 	      => NULL,
     X_PARAMETER_TYPE         => 1,
     X_MINIMUM_VALUE          => NULL,
     X_PARAMETER_NAME         => 'PROCESS_PARAMETER_4',
     X_UNITS 	              => NULL,
     X_PARAMETER_DESCRIPTION  => 'Process Parameter 4',
     X_CREATION_DATE  	      => SYSDATE,
     X_CREATED_BY 	      => 0,
     X_LAST_UPDATE_DATE       => SYSDATE,
     X_LAST_UPDATED_BY        => 0,
     X_LAST_UPDATE_LOGIN      => NULL);
    END IF;
    CLOSE Cur_check_param4;

    OPEN Cur_check_param5;
    FETCH Cur_check_param5 INTO X_temp;
    IF Cur_check_param5%FOUND THEN
    GMP_PROCESS_PARAMETERS_PKG.INSERT_ROW
    (X_ROWID                  => X_row_id,
     X_PARAMETER_ID           => 5,
     X_ATTRIBUTE21            => NULL,
     X_ATTRIBUTE22 	      => NULL,
     X_ATTRIBUTE23 	      => NULL,
     X_ATTRIBUTE24 	      => NULL,
     X_ATTRIBUTE25 	      => NULL,
     X_ATTRIBUTE26	      => NULL,
     X_ATTRIBUTE27 	      => NULL,
     X_ATTRIBUTE28 	      => NULL,
     X_ATTRIBUTE29 	      => NULL,
     X_ATTRIBUTE30 	      => NULL,
     X_ATTRIBUTE_CATEGORY     => NULL,
     X_ATTRIBUTE1	      => NULL,
     X_ATTRIBUTE2 	      => NULL,
     X_ATTRIBUTE3 	      => NULL,
     X_ATTRIBUTE4 	      => NULL,
     X_ATTRIBUTE5 	      => NULL,
     X_ATTRIBUTE6 	      => NULL,
     X_ATTRIBUTE7 	      => NULL,
     X_ATTRIBUTE8 	      => NULL,
     X_ATTRIBUTE9 	      => NULL,
     X_ATTRIBUTE10	      => NULL,
     X_ATTRIBUTE11 	      => NULL,
     X_ATTRIBUTE12 	      => NULL,
     X_ATTRIBUTE13	      => NULL,
     X_ATTRIBUTE14 	      => NULL,
     X_MAXIMUM_VALUE 	      => NULL,
     X_DELETE_MARK 	      => 0,
     X_TEXT_CODE 	      => NULL,
     X_ATTRIBUTE15 	      => NULL,
     X_ATTRIBUTE16 	      => NULL,
     X_ATTRIBUTE17 	      => NULL,
     X_ATTRIBUTE18 	      => NULL,
     X_ATTRIBUTE19 	      => NULL,
     X_ATTRIBUTE20 	      => NULL,
     X_PARAMETER_TYPE         => 1,
     X_MINIMUM_VALUE          => NULL,
     X_PARAMETER_NAME         => 'PROCESS_PARAMETER_5',
     X_UNITS 	              => NULL,
     X_PARAMETER_DESCRIPTION  => 'Process Parameter 5',
     X_CREATION_DATE  	      => SYSDATE,
     X_CREATED_BY 	      => 0,
     X_LAST_UPDATE_DATE       => SYSDATE,
     X_LAST_UPDATED_BY        => 0,
     X_LAST_UPDATE_LOGIN      => NULL);
    END IF;
    CLOSE Cur_check_param5;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMP_PROCESS_PARAMETERS'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
  END check_process_parameter;

  PROCEDURE oprn_process_parameter IS
    CURSOR Cur_oprn_parameters IS
      SELECT Process_parameter_1,Process_parameter_2,Process_parameter_3,
             Process_parameter_4,Process_parameter_5,oprn_line_id,resources
      FROM   gmd_operation_resources;
  BEGIN
    FOR l_rec IN Cur_oprn_parameters LOOP
    /* Insert process parameter 1 value into GMD_OPRN_PROCESS_PARAMETERS table */
    IF l_rec.process_parameter_1 IS NOT NULL THEN
      INSERT INTO gmd_oprn_process_parameters
                 (oprn_line_id,
                  resources,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT l_rec.oprn_line_id,
                  l_rec.resources,
                  1,
		  l_rec.process_parameter_1,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_oprn_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND parameter_id = 1);
    END IF; /*IF l_rec.process_parameter_1 IS NOT NULL THEN*/

    IF l_rec.process_parameter_2 IS NOT NULL THEN
      INSERT INTO gmd_oprn_process_parameters
                 (oprn_line_id,
                  resources,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT l_rec.oprn_line_id,
                  l_rec.resources,
                  2,
		  l_rec.process_parameter_2,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_oprn_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND parameter_id = 2);
    END IF; /*IF l_rec.process_parameter_2 IS NOT NULL THEN*/

    IF l_rec.process_parameter_3 IS NOT NULL THEN
      INSERT INTO gmd_oprn_process_parameters
                 (oprn_line_id,
                  resources,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT l_rec.oprn_line_id,
                  l_rec.resources,
                  3,
		  l_rec.process_parameter_3,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_oprn_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND parameter_id = 3);
    END IF; /*IF l_rec.process_parameter_3 IS NOT NULL THEN*/

    IF l_rec.process_parameter_4 IS NOT NULL THEN
      INSERT INTO gmd_oprn_process_parameters
                 (oprn_line_id,
                  resources,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT l_rec.oprn_line_id,
                  l_rec.resources,
                  4,
		  l_rec.process_parameter_4,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_oprn_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND parameter_id = 4);
    END IF; /*IF l_rec.process_parameter_4 IS NOT NULL THEN*/

    IF l_rec.process_parameter_5 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gmd_oprn_process_parameters
                 (oprn_line_id,
                  resources,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT l_rec.oprn_line_id,
                  l_rec.resources,
                  5,
		  l_rec.process_parameter_5,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_oprn_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND parameter_id = 5);
    END IF; /*IF l_rec.process_parameter_5 IS NOT NULL THEN*/
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_OPRN_PROCESS_PARAMETERS'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
  END oprn_process_parameter;

  PROCEDURE recipe_process_parameter IS
    CURSOR Cur_recipe_parameters IS
      SELECT Process_parameter_1,Process_parameter_2,Process_parameter_3,
             Process_parameter_4,Process_parameter_5,oprn_line_id,resources,
             recipe_id,routingstep_id,orgn_code
      FROM   gmd_recipe_orgn_resources;
  BEGIN
    FOR l_rec IN Cur_recipe_parameters LOOP
    /* Insert process parameter 1 value into GMD_RECIPE_PROCESS_PARAMETERS table */
    IF l_rec.process_parameter_1 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gmd_recipe_process_parameters
                 (oprn_line_id,
                  resources,
                  recipe_id,
                  routingstep_id,
                  orgn_code,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  l_rec.oprn_line_id,
                  l_rec.resources,
                  l_rec.recipe_id,
                  l_rec.routingstep_id,
                  l_rec.orgn_code,
                  1,
		  l_rec.process_parameter_1,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_recipe_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND orgn_code = l_rec.orgn_code
		  		           AND recipe_id = l_rec.recipe_id
		  		           AND routingstep_id = l_rec.routingstep_id
		  		           AND parameter_id = 1);
    END IF; /*IF l_rec.process_parameter_1 IS NOT NULL THEN*/

    IF l_rec.process_parameter_2 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gmd_recipe_process_parameters
                 (oprn_line_id,
                  resources,
                  recipe_id,
                  routingstep_id,
                  orgn_code,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  l_rec.oprn_line_id,
                  l_rec.resources,
                  l_rec.recipe_id,
                  l_rec.routingstep_id,
                  l_rec.orgn_code,
                  2,
		  l_rec.process_parameter_2,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_recipe_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND orgn_code = l_rec.orgn_code
		  		           AND recipe_id = l_rec.recipe_id
		  		           AND routingstep_id = l_rec.routingstep_id
		  		           AND parameter_id = 2);
    END IF; /*IF l_rec.process_parameter_2 IS NOT NULL THEN*/

    IF l_rec.process_parameter_3 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gmd_recipe_process_parameters
                 (oprn_line_id,
                  resources,
                  recipe_id,
                  routingstep_id,
                  orgn_code,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  l_rec.oprn_line_id,
                  l_rec.resources,
                  l_rec.recipe_id,
                  l_rec.routingstep_id,
                  l_rec.orgn_code,
                  3,
		  l_rec.process_parameter_3,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_recipe_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND orgn_code = l_rec.orgn_code
		  		           AND recipe_id = l_rec.recipe_id
		  		           AND routingstep_id = l_rec.routingstep_id
		  		           AND parameter_id = 3);
    END IF; /*IF l_rec.process_parameter_3 IS NOT NULL THEN*/

    IF l_rec.process_parameter_4 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gmd_recipe_process_parameters
                 (oprn_line_id,
                  resources,
                  recipe_id,
                  routingstep_id,
                  orgn_code,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  l_rec.oprn_line_id,
                  l_rec.resources,
                  l_rec.recipe_id,
                  l_rec.routingstep_id,
                  l_rec.orgn_code,
                  4,
		  l_rec.process_parameter_4,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_recipe_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND orgn_code = l_rec.orgn_code
		  		           AND recipe_id = l_rec.recipe_id
		  		           AND routingstep_id = l_rec.routingstep_id
		  		           AND parameter_id = 4);
    END IF; /*IF l_rec.process_parameter_4 IS NOT NULL THEN*/

    IF l_rec.process_parameter_5 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gmd_recipe_process_parameters
                 (oprn_line_id,
                  resources,
                  recipe_id,
                  routingstep_id,
                  orgn_code,
                  parameter_id,
                  target_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  l_rec.oprn_line_id,
                  l_rec.resources,
                  l_rec.recipe_id,
                  l_rec.routingstep_id,
                  l_rec.orgn_code,
                  5,
		  l_rec.process_parameter_5,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gmd_recipe_process_parameters
		  		    WHERE  oprn_line_id = l_rec.oprn_line_id
		  		           AND resources = l_rec.resources
		  		           AND orgn_code = l_rec.orgn_code
		  		           AND recipe_id = l_rec.recipe_id
		  		           AND routingstep_id = l_rec.routingstep_id
		  		           AND parameter_id = 5);
    END IF; /*IF l_rec.process_parameter_5 IS NOT NULL THEN*/
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMD_RECIPE_PROCESS_PARAMETERS'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
  END recipe_process_parameter;

  PROCEDURE batch_process_parameter IS
    CURSOR Cur_batch_parameters IS
      SELECT Process_parameter_1,Process_parameter_2,Process_parameter_3,
             Process_parameter_4,Process_parameter_5,batch_id,batchstep_id,
             batchstep_activity_id,resources,batchstep_resource_id
      FROM   gme_batch_step_resources;
  BEGIN
    FOR l_rec IN Cur_batch_parameters LOOP
    /* Insert process parameter 1 value into GME_PROCESS_PARAMETERS table */
    IF l_rec.process_parameter_1 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gme_process_parameters
                 (process_param_id,
                  batch_id,
                  batchstep_id,
                  batchstep_activity_id,
                  resources,
                  batchstep_resource_id,
                  parameter_id,
                  actual_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  gme_process_parameters_id_s.nextval,
                  l_rec.batch_id,
                  l_rec.batchstep_id,
                  l_rec.batchstep_activity_id,
                  l_rec.resources,
                  l_rec.batchstep_resource_id,
                  1,
		  l_rec.process_parameter_1,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gme_process_parameters
		  		    WHERE  batchstep_resource_id = l_rec.batchstep_resource_id
		  		           AND parameter_id = 1);
    END IF; /*IF l_rec.process_parameter_1 IS NOT NULL THEN*/

    IF l_rec.process_parameter_2 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gme_process_parameters
                 (process_param_id,
                  batch_id,
                  batchstep_id,
                  batchstep_activity_id,
                  resources,
                  batchstep_resource_id,
                  parameter_id,
                  actual_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  gme_process_parameters_id_s.nextval,
                  l_rec.batch_id,
                  l_rec.batchstep_id,
                  l_rec.batchstep_activity_id,
                  l_rec.resources,
                  l_rec.batchstep_resource_id,
                  2,
		  l_rec.process_parameter_2,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gme_process_parameters
		  		    WHERE  batchstep_resource_id = l_rec.batchstep_resource_id
		  		           AND parameter_id = 2);
    END IF; /*IF l_rec.process_parameter_2 IS NOT NULL THEN*/

    IF l_rec.process_parameter_3 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gme_process_parameters
                 (process_param_id,
                  batch_id,
                  batchstep_id,
                  batchstep_activity_id,
                  resources,
                  batchstep_resource_id,
                  parameter_id,
                  actual_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  gme_process_parameters_id_s.nextval,
                  l_rec.batch_id,
                  l_rec.batchstep_id,
                  l_rec.batchstep_activity_id,
                  l_rec.resources,
                  l_rec.batchstep_resource_id,
                  3,
		  l_rec.process_parameter_3,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gme_process_parameters
		  		    WHERE  batchstep_resource_id = l_rec.batchstep_resource_id
		  		           AND parameter_id = 3);
    END IF; /*IF l_rec.process_parameter_3 IS NOT NULL THEN*/

    IF l_rec.process_parameter_4 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gme_process_parameters
                 (process_param_id,
                  batch_id,
                  batchstep_id,
                  batchstep_activity_id,
                  resources,
                  batchstep_resource_id,
                  parameter_id,
                  actual_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  gme_process_parameters_id_s.nextval,
                  l_rec.batch_id,
                  l_rec.batchstep_id,
                  l_rec.batchstep_activity_id,
                  l_rec.resources,
                  l_rec.batchstep_resource_id,
                  4,
		  l_rec.process_parameter_4,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gme_process_parameters
		  		    WHERE  batchstep_resource_id = l_rec.batchstep_resource_id
		  		           AND parameter_id = 4);
    END IF; /*IF l_rec.process_parameter_4 IS NOT NULL THEN*/

    IF l_rec.process_parameter_5 IS NOT NULL THEN
    /*Check if the row for the resource already exists if it does not then*/
      INSERT INTO gme_process_parameters
                 (process_param_id,
                  batch_id,
                  batchstep_id,
                  batchstep_activity_id,
                  resources,
                  batchstep_resource_id,
                  parameter_id,
                  actual_value,
      	  	  creation_date,
        	  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login)
                  SELECT
                  gme_process_parameters_id_s.nextval,
                  l_rec.batch_id,
                  l_rec.batchstep_id,
                  l_rec.batchstep_activity_id,
                  l_rec.resources,
                  l_rec.batchstep_resource_id,
                  5,
		  l_rec.process_parameter_5,
                  SYSDATE,
                  0,
                  SYSDATE,
		  0,
		  0
		  FROM DUAL
		  WHERE NOT EXISTS (SELECT 1
		  		    FROM   gme_process_parameters
		  		    WHERE  batchstep_resource_id = l_rec.batchstep_resource_id
		  		           AND parameter_id = 5);
    END IF; /*IF l_rec.process_parameter_5 IS NOT NULL THEN*/
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GME_PROCESS_PARAMETERS'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
  END batch_process_parameter;

  PROCEDURE get_override IS
    CURSOR Cur_get_override IS
      SELECT DISTINCT resources,Parameter_id
      FROM   gmd_oprn_process_parameters
      UNION
      SELECT DISTINCT resources,Parameter_id
      FROM   gmd_recipe_process_parameters
      UNION
      SELECT DISTINCT resources,Parameter_id
      FROM   gme_process_parameters
      order by 1;
    l_rec Cur_get_override%ROWTYPE;
    CURSOR Cur_get_target(V_resources VARCHAR2, V_parameter_id NUMBER) IS
      SELECT Target_Value, COUNT(1)
      FROM   gmd_oprn_process_parameters
      WHERE  resources = V_resources
      AND    parameter_id = V_parameter_id
      GROUP BY Target_Value
      UNION
      SELECT Target_Value, COUNT(1)
      FROM   gmd_recipe_process_parameters
      WHERE  resources = V_resources
      AND    parameter_id = V_parameter_id
      GROUP BY Target_Value
      UNION
      SELECT Target_Value, COUNT(1)
      FROM   gme_process_parameters
      WHERE  resources = V_resources
      AND    parameter_id = V_parameter_id
      GROUP BY Target_Value
      ORDER BY 2 DESC;
    X_target_value VARCHAR2(16);
    X_count        NUMBER;
    X_seq          NUMBER;
    X_resources    cr_rsrc_mst_b.resources%type;
  BEGIN
    X_seq := 0;
    FOR l_rec IN Cur_get_override LOOP
      IF NVL(X_resources, 'z') = l_rec.resources THEN
        X_seq := X_seq + 1;
      ELSE
        X_seq := 1;
        X_resources := l_rec.resources;
      END IF;
      OPEN Cur_get_target(l_rec.resources,l_rec.parameter_id);
      FETCH Cur_get_target INTO X_target_value, X_count;
      CLOSE Cur_get_target;
      INSERT INTO gmp_resource_parameters
                  (resources,
       		   sequence_no,
       		   parameter_id,
       		   target_value,
       		   creation_date,
       		   created_by,
       		   last_update_date,
       		   last_updated_by)
       		   SELECT
                   l_rec.resources,
                   X_seq,
                   l_rec.parameter_id,
                   X_target_value,
                   SYSDATE,
                   0,
                   SYSDATE,
                   0
      		   FROM DUAL
      		   WHERE NOT EXISTS (SELECT 1
      				     FROM GMP_RESOURCE_PARAMETERS
      				     WHERE resources = l_rec.resources
      				     AND parameter_id = l_rec.parameter_id);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      P_line_no := P_line_no + 1;
      GMA_MIGRATION.gma_insert_message (p_run_id => p_run_id
                                       ,p_table_name => 'GMP_RESOURCE_PARAMETERS'
                                       ,p_db_error => sqlerrm
                                       ,p_param1 => NULL
                                       ,p_param2 => NULL
                                       ,p_param3 => NULL
                                       ,p_param4 => NULL
                                       ,p_param5 => NULL
                                       ,p_message_token => 'GMA_MIGRATION_DB_ERROR'
                                       ,p_message_type => 'D'
                                       ,p_line_no => P_line_no
                                       ,p_position=> 1
                                       ,p_base_message=> NULL);
  END get_override;

  PROCEDURE run IS
  BEGIN
    P_run_id := GMA_MIGRATION.gma_migration_start
                (p_app_short_name => 'GMD'
                ,p_mig_name => 'PROCESS_PARAMETERS_MIGRATION');
    check_process_parameter;
    oprn_process_parameter;
    recipe_process_parameter;
    batch_process_parameter;
    get_override;
    GMA_MIGRATION.gma_migration_end (l_run_id => p_run_id);
  END run;


END GMD_PROC_PARAMS_MIGR;

/

--------------------------------------------------------
--  DDL for Package Body PJM_UPDATE_AK_REGION_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_UPDATE_AK_REGION_ITEMS_PKG" AS
/* $Header: PJMUPAKB.pls 115.1 99/07/16 01:05:10 porting s $ */

   PROCEDURE update_pa_status_regions IS

     CURSOR c_proj_status IS
	SELECT 	COLUMN_PROMPT, Column_ORDER
	FROM    PA_STATUS_COLUMN_SETUP
	WHERE   FOLDER_CODE='P'
          AND   COLUMN_PROMPT IS NOT NULL;


     CURSOR c_task_status IS
        SELECT  COLUMN_PROMPT, Column_ORDER
        FROM    PA_STATUS_COLUMN_SETUP
        WHERE   FOLDER_CODE='T'
          AND   COLUMN_PROMPT IS NOT NULL;

     CURSOR c_rsrc_status IS
        SELECT  COLUMN_PROMPT, Column_ORDER
        FROM    PA_STATUS_COLUMN_SETUP
        WHERE   FOLDER_CODE='R'
          AND   COLUMN_PROMPT IS NOT NULL;

     var_column_prompt pa_status_column_setup.column_prompt%TYPE;
     var_column_order  pa_status_column_setup.column_order%TYPE;

  BEGIN

     UPDATE ak_region_items
     SET    node_display_flag = 'N'
     WHERE  region_code in ('PJM_ALL_PROJ_STATUS',
                            'PJM_ALL_PROJ_TASK_STATUS',
                            'PJM_ALL_PROJ_RSRC_STATUS')
       AND  object_attribute_flag = 'Y';

     OPEN c_proj_status;
     LOOP
	FETCH c_proj_status INTO var_column_prompt, var_column_order;
	EXIT WHEN c_proj_status%NOTFOUND;

        update ak_region_items
        set    node_display_flag = 'Y'
        where  region_code = 'PJM_ALL_PROJ_STATUS'
          and  substr(attribute_code,7) = to_char(var_column_order);

        update ak_region_items_tl
        set    attribute_label_long = substr(var_column_prompt,1,50)
        where  region_code = 'PJM_ALL_PROJ_STATUS'
          and  substr(attribute_code,7) = to_char(var_column_order);

     END LOOP;
     CLOSE c_proj_status;

     OPEN c_task_status;
     LOOP
        FETCH c_task_status INTO var_column_prompt, var_column_order;
        EXIT WHEN c_task_status%NOTFOUND;

        update ak_region_items
        set    node_display_flag = 'Y'
        where  region_code = 'PJM_ALL_PROJ_TASK_STATUS'
          and  substr(attribute_code,7) = to_char(var_column_order);

        update ak_region_items_tl
        set    attribute_label_long = substr(var_column_prompt,1,50)
        where  region_code = 'PJM_ALL_PROJ_TASK_STATUS'
          and  substr(attribute_code,7) = to_char(var_column_order);

     END LOOP;
     CLOSE c_task_status;

     OPEN c_rsrc_status;
     LOOP
        FETCH c_rsrc_status INTO var_column_prompt, var_column_order;
        EXIT WHEN c_rsrc_status%NOTFOUND;

        update ak_region_items
        set    node_display_flag = 'Y'
        where  region_code = 'PJM_ALL_PROJ_RSRC_STATUS'
          and  substr(attribute_code,7) = to_char(var_column_order);

        update ak_region_items_tl
        set    attribute_label_long = substr(var_column_prompt,1,50)
        where  region_code = 'PJM_ALL_PROJ_RSRC_STATUS'
          and  substr(attribute_code,7) = to_char(var_column_order);

     END LOOP;
     CLOSE c_rsrc_status;
/*
    EXCEPTION
    WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
*/
  END UPDATE_PA_STATUS_REGIONS;

END PJM_UPDATE_AK_REGION_ITEMS_PKG;


/

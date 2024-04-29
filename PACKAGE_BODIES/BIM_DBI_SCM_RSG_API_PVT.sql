--------------------------------------------------------
--  DDL for Package Body BIM_DBI_SCM_RSG_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_DBI_SCM_RSG_API_PVT" AS
/*$Header: bimmvimb.pls 115.3 2004/07/29 06:44:08 arvikuma noship $*/

PROCEDURE Manage_bim_Index(p_mode VARCHAR2, p_obj_name VARCHAR2) IS

  CURSOR c_obj_indexes (p_obj_name VARCHAR2,p_ind_name VARCHAR2)IS
    SELECT index_name
    FROM   user_indexes
    WHERE  table_name = p_obj_name
    AND    index_name = nvl(p_ind_name,index_name) ;

  CURSOR c_val_indexes (p_obj_name VARCHAR2,p_ind_name VARCHAR2)IS
    SELECT index_name , column_name
    FROM   bim_all_indexes
    WHERE  table_name = p_obj_name
    AND    index_name = nvl(p_ind_name,index_name) ;

  l_ind_val VARCHAR2(30);

BEGIN -- Manage_bim_Index

  IF (p_mode = 'BEFORE') THEN

   -- Delete the entry from bim_all_indexes if the earlier entry for index was not deleted.
   FOR i in c_obj_indexes (p_obj_name,null) LOOP
     FOR j in c_val_indexes (p_obj_name,i.index_name) LOOP
       -- Delete the entry from bim_all_indexes table for the index in context
       execute immediate ('DELETE FROM bim_all_indexes where table_name = '||''''||p_obj_name||''''||' and index_name = '||''''||j.index_name||'''');
     END LOOP;
   END LOOP;


    FOR i in c_obj_indexes(p_obj_name,null) LOOP
       INSERT INTO bim_all_indexes (INDEX_NAME,TABLE_NAME,COLUMN_NAME)
         VALUES (i.index_name,p_obj_name,REPLACE(DBMS_METADATA.GET_DDL('INDEX',i.index_name),'COMPUTE STATISTICS',NULL)||' NOLOGGING PARALLEL'); -- Log the index ddl syntax
	 execute immediate ('drop index '||i.index_name); -- drop the index
         BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('MetaData Information Recorded and Index Dropped for Index :'||i.index_name);
    END LOOP;

  ELSIF (p_mode = 'AFTER') THEN
    BEGIN -- Re-create indexes
      FOR i in c_val_indexes (p_obj_name,null) LOOP

  -- Check for existance of the index
       OPEN c_obj_indexes(p_obj_name,i.index_name);
        IF c_obj_indexes%FOUND THEN
         FETCH c_obj_indexes INTO l_ind_val;
	ELSE
          l_ind_val := NULL;
	END IF;
       CLOSE c_obj_indexes;

  -- Create index if is not existing in the DB
       IF l_ind_val IS NULL THEN
         execute immediate (i.column_name);
	 execute immediate ('ALTER INDEX '||i.index_name||' LOGGING NOPARALLEL');
         BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Index '||i.index_name||' created on '||p_obj_name);
       END IF;

  -- Delete the entry from bim_all_indexes table for the index in context
       execute immediate ('DELETE FROM bim_all_indexes where table_name = '||''''||p_obj_name||''''||' and index_name = '||''''||i.index_name||'''');
         BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('MetaData Information Deleted for Index -'||i.index_name);

     END LOOP;

    END;  -- Re-create indexes

  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS
    THEN
      BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Error for Object'|| p_obj_name ||' - '||sqlcode||'-'||sqlerrm);
      RAISE;
END Manage_bim_Index;

PROCEDURE bim_Custom_Api(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL) IS

  l_api_type                VARCHAR2(300);
  l_mode                    VARCHAR2(300);
  l_obj_name                VARCHAR2(300);

 CURSOR c_chk_index
 IS
 SELECT substr(version,1,1) ver
 FROM   v$instance;

BEGIN

--  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Inside BIM Custom API ');
  /* Checking Version of the database */
For l_rec in c_chk_index
 LOOP
 /* If Version is 9i then do then index management else do nothing */
 IF l_rec.ver = 9 THEN
  /* IF mode is null it means that this is the incremental mode so do no do anything and exit else do the Manage.*/
  /* Conform to Standard 2. Retrieving Parameters API_TYPE, MODE, OBJECT_NAM, OBJECT_TYPE */
  l_mode     := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mode);
  l_api_type := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Api_Type);
  l_obj_name := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Object_Name);

  /* IF mode is null it means that this is the incremental mode so do no do anything and exit else do the Manage.*/
  IF l_mode is null THEN
     BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Materialized View '|| l_obj_name || ' is running in Incremental Mode so no index management operations conducted. ');
  ELSE
   BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Value for Parameter '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Api_Type|| ': '|| l_api_type);
   BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Value for Parameter '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mode|| ': '|| l_mode);
   BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Value for Parameter '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Object_Name|| ': '|| l_obj_name);

   BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Start Of Process');

  /** Performing Custom Actions based on the API type and calling mode**/
  IF (l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.Type_Mv_Log_Mgt) THEN
    NULL; --MANAGE_LOG(l_mode, l_obj_name);
  ELSIF (l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.Type_Mv_Index_Mgt) THEN
    Manage_bim_Index(l_mode, l_obj_name);
  ELSIF (l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.Type_Mv_Threshold) THEN
    NULL; --MANAGE_MV_THRESHOLD(L_MODE, L_OBJ_NAME);
  END IF;
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('End of Process');
  END IF;
  COMMIT;
 ELSE
 NULL;
 END IF;
END LOOP;

  /* Conform to Standard 3. Setting Complete Status and Message */
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Complete_Status, BIS_BIA_RSG_CUSTOM_API_MGMNT.Status_Success);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Message, 'Succeeded');



EXCEPTION WHEN OTHERS THEN
  /* Conform to Standard 6. Error Handling */
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Complete_Status,BIS_BIA_RSG_CUSTOM_API_MGMNT.Status_Failure);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Message, sqlerrm);

END bim_Custom_Api;

END;

/

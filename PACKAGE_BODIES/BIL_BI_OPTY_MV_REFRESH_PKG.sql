--------------------------------------------------------
--  DDL for Package Body BIL_BI_OPTY_MV_REFRESH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_OPTY_MV_REFRESH_PKG" AS
  /*$Header: bilrmvb.pls 120.2 2006/03/28 02:04:48 vchahal noship $*/

  PROCEDURE MANAGE_LOG(P_MODE IN VARCHAR2, P_OBJ_NAME IN VARCHAR2);

  PROCEDURE MANAGE_INDEX(P_MODE IN VARCHAR2, P_OBJ_NAME IN VARCHAR2, P_DB_VERSION IN VARCHAR2);

  PROCEDURE MANAGE_MV_THRESHOLD
  (
    P_MODE VARCHAR2,
    P_OBJ_NAME VARCHAR2,
    p_refresh_mode OUT NOCOPY VARCHAR2
  );

  PROCEDURE MANAGE_SESSION (P_MODE IN VARCHAR2, P_OBJ_NAME IN VARCHAR2, P_DB_VERSION IN VARCHAR2);

  PROCEDURE CUSTOM_API
  (
    p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL
  )
  IS

    L_API_TYPE varchar2(300);
    L_MODE     varchar2(300);
    L_OBJ_NAME varchar2(300);
    L_OBJ_TYPE varchar2(300);
    l_mv_refresh_method varchar2(300);

    --Variable to see the refresh mode (C for complete and F for fast!)
    l_refresh_mode VARCHAR2(1);

     db_version varchar2(100);

  BEGIN

    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Inside Custom API ');

       select version into db_version from v$instance;

           BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('DB Version: ' || db_version);

       db_version := substr(db_version,1,instr(db_version,'.',1)-1);

    /* Conform to Standard 2. Retrieving Parameters API_TYPE, MODE, OBJECT_NAM, OBJECT_TYPE */
    L_API_TYPE := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_API_TYPE);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG
    ('Got value for ' || BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_API_TYPE || ': ' || L_API_TYPE);
    L_MODE := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MODE);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG
    ('Got value for ' || BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MODE || ': ' || L_MODE);
 l_mv_refresh_method := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MV_REFRESH_METHOD);
 BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Got value for ' || BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MV_REFRESH_METHOD || ': ' || l_mv_refresh_method);

    L_OBJ_NAME := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_NAME);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG
    ('Got value for ' || BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_NAME || ': ' || L_OBJ_NAME);

    L_OBJ_TYPE := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_TYPE);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG
    ('Got value for ' || BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_TYPE || ': ' || L_OBJ_TYPE);


    /** Performing Custom Actions based on the API type and calling mode**/
    IF (L_API_TYPE = BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_LOG_MGT) THEN
      MANAGE_LOG(L_MODE, L_OBJ_NAME);
	ELSIF (L_API_TYPE = BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_OTHER_CUSTOM
	AND l_mv_refresh_method = BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_COMPLETE) THEN
	  MANAGE_SESSION(L_MODE, L_OBJ_NAME, db_version);
    ELSIF (L_API_TYPE = BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_INDEX_MGT) THEN
      MANAGE_INDEX(L_MODE, L_OBJ_NAME, db_version);
      NULL;
    ELSIF (L_API_TYPE = BIS_BIA_RSG_CUSTOM_API_MGMNT.TYPE_MV_THRESHOLD) THEN
      BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('calling MV thresh hold proc now');
      MANAGE_MV_THRESHOLD(L_MODE, L_OBJ_NAME,l_refresh_mode);
      IF(l_refresh_mode = 'C') THEN
        BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM
        (
          p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MV_REFRESH_METHOD,
          BIS_BIA_RSG_CUSTOM_API_MGMNT.METHOD_COMPLETE
        );
        BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('have set type as complete');
      END IF;
    END IF;

    /* Conform to Standard 3. Setting Complete Status and Message */
    BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_COMPLETE_STATUS,
                                            BIS_BIA_RSG_CUSTOM_API_MGMNT.STATUS_SUCCESS );
    BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MESSAGE,
                                             'Succeeded' );
  EXCEPTION WHEN OTHERS THEN
    /* Conform to Standard 6. Error Handling */
      BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_COMPLETE_STATUS,
                                            BIS_BIA_RSG_CUSTOM_API_MGMNT.STATUS_FAILURE );
      BIS_BIA_RSG_CUSTOM_API_MGMNT.SET_PARAM(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MESSAGE, sqlerrm );
  END CUSTOM_API;



  PROCEDURE MANAGE_LOG(P_MODE VARCHAR2, P_OBJ_NAME VARCHAR2) IS
  BEGIN
    NULL;
  END;



  PROCEDURE MANAGE_INDEX(P_MODE VARCHAR2, P_OBJ_NAME VARCHAR2, P_DB_VERSION VARCHAR2) IS
    L_DYNAMIC_STMNT VARCHAR2(5000);
    l_idx_present NUMBER DEFAULT 1;

  BEGIN

    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('inside the index management proc');

    -- db_versn = 10 for 10g
    -- db_versn = 9 for 9

    IF (P_MODE = BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE AND
        P_DB_VERSION <= 9) THEN

      BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('starting the before loop');

     -- Delete the entry from table for the index in context
        DELETE FROM BIL_BI_INDEX_MGMT WHERE table_name = p_obj_name;

      FOR i IN (SELECT index_name FROM user_indexes WHERE table_name=P_OBJ_NAME)
      LOOP
        INSERT INTO BIL_BI_INDEX_MGMT (table_name,index_name,ddl_stmnt)
        VALUES (P_OBJ_NAME,i.INDEX_NAME,DBMS_METADATA.GET_DDL('INDEX',i.index_name));
        EXECUTE IMMEDIATE 'DROP INDEX '||i.index_name;

        BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG(' dropped this index :'||i.index_name);

      END LOOP;
    ELSIF (P_MODE = BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_AFTER AND
           P_DB_VERSION <= 9) THEN

      BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('starting the after loop');

      FOR i in (SELECT table_name,index_name,ddl_stmnt FROM BIL_BI_INDEX_MGMT WHERE  table_name = p_obj_name)
      LOOP
        -- Check for existance of the index
        SELECT count(*) INTO l_idx_present
        FROM user_indexes WHERE table_name=p_obj_name AND index_name=i.index_name;
        -- Create index if is not existing in the DB

        IF l_idx_present <> 1 THEN
          L_DYNAMIC_STMNT := REPLACE(REPLACE(replace(replace(replace(i.ddl_stmnt,'NOPARALLEL',' '),
                                                                         'PARALLEL',' '),
                                                                         'NOLOGGING',' '),
                                                                         'LOGGING',' '),
                                                                          UPPER('COMPUTE STATISTICS'),' ');
          L_DYNAMIC_STMNT := L_DYNAMIC_STMNT || ' NOLOGGING PARALLEL ';
          BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('the DDL statement is :'||L_DYNAMIC_STMNT);
          EXECUTE IMMEDIATE (L_DYNAMIC_STMNT);
          EXECUTE IMMEDIATE ('ALTER INDEX '||i.index_name||' LOGGING NOPARALLEL');
          BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('recreated the index:'||i.index_name);
        END IF;

        -- Delete the entry from bim_all_indexes table for the index in context
        DELETE FROM BIL_BI_INDEX_MGMT WHERE table_name = p_obj_name AND index_name = i.index_name;

        COMMIT;

        l_idx_present := 1;

      END LOOP;
    END IF;
  END;


  PROCEDURE MANAGE_MV_THRESHOLD
  (
    P_MODE VARCHAR2,
    P_OBJ_NAME VARCHAR2,
    p_refresh_mode OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
  /*
    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Inside thresh hold proc');
    for Top oppty MV, always complete refresh
    IF (P_OBJ_NAME = 'BIL_BI_TOPOP_G_MV') THEN
      p_refresh_mode := 'C';
    BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG('Inside the if loop for mv thresh hold');
    END IF;
  */
  NULL;
  END;

   PROCEDURE MANAGE_SESSION
  (
    P_MODE VARCHAR2,
    P_OBJ_NAME VARCHAR2,
    P_DB_VERSION VARCHAR2
  ) IS
  BEGIN

   BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG(' inside manager_session');

  IF (P_MODE = BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_BEFORE) THEN

         IF P_DB_VERSION > 9 THEN
            EXECUTE IMMEDIATE 'alter session set "_idxrb_rowincr"=1000';
         END IF;

         FOR i IN (SELECT index_name FROM user_indexes WHERE table_name=P_OBJ_NAME)
	 LOOP
	  EXECUTE IMMEDIATE 'ALTER INDEX '||i.index_name|| ' parallel';
	   BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG(' altered index ' || i.index_name || ' parallel');
	 END LOOP;


  ELSIF (P_MODE = BIS_BIA_RSG_CUSTOM_API_MGMNT.MODE_AFTER) THEN
  	 FOR i IN (SELECT index_name FROM user_indexes WHERE table_name=P_OBJ_NAME)
	 LOOP
	  EXECUTE IMMEDIATE 'ALTER INDEX '||i.index_name|| ' noparallel';
	   BIS_BIA_RSG_CUSTOM_API_MGMNT.LOG(' altered index ' || i.index_name || ' noparallel');
	 END LOOP;


  END IF;
  END;

END BIL_BI_OPTY_MV_REFRESH_PKG;

/

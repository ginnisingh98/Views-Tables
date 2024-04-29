--------------------------------------------------------
--  DDL for Package Body MSD_PURGE_LEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PURGE_LEG" AS
/* $Header: MSDPURB.pls 120.0 2005/05/26 01:57:58 appldev noship $ */


    v_batch_size        NUMBER ;
    v_debug             BOOLEAN := TRUE;
    v_applsys_schema    VARCHAR2(32);
    v_program_status    NUMBER := G_SUCCESS;



  /*========================================================================================+
  | DESCRIPTION  : This procedure is called to delete or truncate all the tables            |
  |                under lookup type MSC_X_SETUP_ENTITY_CODE                                |
  +========================================================================================*/

  PROCEDURE delete_records ( p_instance_code IN VARCHAR2 DEFAULT NULL, p_instance_id IN NUMBER ,p_del_rej_rec IN NUMBER ,p_trunc_flag IN NUMBER )
  AS

  lv_instance_code VARCHAR2(5);
  lv_instance_id NUMBER;
  lv_p_del_rej_rec NUMBER;
  lv_truncation_flag NUMBER;

  lv_retval         BOOLEAN;
  lv_dummy1         VARCHAR2(32);
  lv_dummy2         VARCHAR2(32);


  lv_table_name FND_LOOKUP_VALUES.attribute1%Type;
  lv_errtxt VARCHAR2(300);

  lv_total number :=0; -- total number of rows deleted

  CURSOR table_names IS
  SELECT DISTINCT (LV.ATTRIBUTE1) TABLE_NAME
  FROM   FND_LOOKUP_VALUES LV
  WHERE LV.ENABLED_FLAG          = 'Y'
  AND LV.VIEW_APPLICATION_ID   = 700
  AND   SUBSTR  (LV.ATTRIBUTE1, 1, 3)  = 'MSD'
  AND LV.LOOKUP_TYPE           = 'MSC_X_SETUP_ENTITY_CODE';

  lv_sql_stmt VARCHAR2(1000);


  table_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (table_not_found,-00942);

  synonym_translation_invalid EXCEPTION;
  PRAGMA EXCEPTION_INIT (synonym_translation_invalid,-00980);

  BEGIN

  OPEN table_names;
  FETCH table_names INTO lv_table_name;
  IF ( table_names%ROWCOUNT = 0 ) THEN
          FND_MESSAGE.SET_NAME('MSC','MSC_PS_INVALID_LOOKUP');
          lv_errtxt:= FND_MESSAGE.GET;
          msc_st_util.log_message (lv_errtxt);
          v_program_status := G_ERROR;

          CLOSE table_names;
  ELSE      -- IF ( table_names%ROWCOUNT = 0 ) THEN
          CLOSE table_names;

  lv_truncation_flag :=  p_trunc_flag;


  IF (lv_truncation_flag = SYS_YES) THEN

           IF v_debug THEN
                msc_st_util.log_message ('Truncation flag is YES. Entering in truncation LOOP');
           END IF;

           UPDATE msc_apps_instances
           SET st_status= G_ST_PURGING;
           COMMIT;

           lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'MSD', lv_dummy1, lv_dummy2, v_applsys_schema);

        OPEN table_names;


             LOOP
               FETCH table_names INTO lv_table_name;
                  EXIT WHEN table_names%NOTFOUND;
                   IF v_debug THEN
                      msc_st_util.log_message (lv_table_name);
                   END IF;


                BEGIN
                lv_sql_stmt := 'TRUNCATE TABLE '||v_applsys_schema||'.'||lv_table_name|| '';

                   IF v_debug THEN
                        msc_st_util.log_message ('Sql statements to be executed-'||lv_sql_stmt);
                   END IF;



               EXECUTE IMMEDIATE lv_sql_stmt;

               EXCEPTION

               WHEN table_not_found THEN
               lv_errtxt := substr(SQLERRM,1,240) ;
               msc_st_util.log_message(lv_errtxt);


               WHEN OTHERS THEN
               lv_errtxt := substr(SQLERRM,1,240) ;
               msc_st_util.log_message(lv_errtxt);


               END;

             END LOOP;
        CLOSE table_names;

           UPDATE msc_apps_instances
           SET st_status= G_ST_EMPTY;
           COMMIT;

  ELSE  --IF (lv_truncation_flag = SYS_YES) THEN




  lv_instance_code   :=  p_instance_code;
  lv_instance_id     :=  p_instance_id;
  lv_p_del_rej_rec   :=  p_del_rej_rec;
  v_batch_size := TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE'));


        OPEN table_names;
        LOOP
          lv_total := 0;
          FETCH table_names INTO lv_table_name;
          EXIT WHEN table_names%NOTFOUND;

           loop


             IF ( lv_table_name = 'MSD_ST_CS_DATA' ) THEN

                IF ( lv_p_del_rej_rec = SYS_YES ) THEN
                    lv_sql_stmt := 'DELETE FROM '||lv_table_name||' WHERE (( SR_INSTANCE_CODE= '''||lv_instance_code||''' ) OR ( ATTRIBUTE_1 = '''||lv_instance_id||''' ))  AND ROWNUM <= '||v_batch_size
                    ||' AND PROCESS_FLAG IN ( '||G_ERROR_FLG||' ,'|| G_PROPAGATION||' )';
                ELSE
                    lv_sql_stmt := 'DELETE FROM '||lv_table_name||' WHERE (( SR_INSTANCE_CODE= '''||lv_instance_code||''' ) OR ( ATTRIBUTE_1 = '''||lv_instance_id||''' )) AND ROWNUM <= '||v_batch_size ;
                END IF;

                IF v_debug THEN
                   msc_st_util.log_message ('Sql statements executed-'||lv_sql_stmt);
                END IF;
            /* Bug 4038215 */
            ELSIF ( lv_table_name = 'MSD_ST_ITEM_RELATIONSHIPS' ) THEN

                IF ( lv_p_del_rej_rec = SYS_YES ) THEN
                   lv_sql_stmt := 'DELETE FROM '||lv_table_name||' WHERE (( SR_INSTANCE_CODE= '''||lv_instance_code||''') OR ( INSTANCE_ID= '||lv_instance_id||'))  AND ROWNUM <= '||v_batch_size
                   ||'  AND PROCESS_FLAG IN ( '||G_ERROR_FLG||','||G_PROPAGATION||')';
                ELSE
                   lv_sql_stmt := 'DELETE FROM '||lv_table_name||' WHERE (( SR_INSTANCE_CODE= '''||lv_instance_code||''') OR ( INSTANCE_ID= '||lv_instance_id||')) AND ROWNUM <= '||v_batch_size||'';
                END IF;

                IF v_debug THEN
                   msc_st_util.log_message ('Sql statements executed-'||lv_sql_stmt);
                END IF;


            ELSE

                IF ( lv_p_del_rej_rec = SYS_YES ) THEN
                   lv_sql_stmt := 'DELETE FROM '||lv_table_name||' WHERE (( SR_INSTANCE_CODE= '''||lv_instance_code||''') OR ( INSTANCE= '||lv_instance_id||'))  AND ROWNUM <= '||v_batch_size
                   ||'  AND PROCESS_FLAG IN ( '||G_ERROR_FLG||','||G_PROPAGATION||')';
                ELSE
                   lv_sql_stmt := 'DELETE FROM '||lv_table_name||' WHERE (( SR_INSTANCE_CODE= '''||lv_instance_code||''') OR ( INSTANCE= '||lv_instance_id||')) AND ROWNUM <= '||v_batch_size||'';
                END IF;

                IF v_debug THEN
                   msc_st_util.log_message ('Sql statements executed-'||lv_sql_stmt);
                END IF;


            END IF;


                BEGIN

                EXECUTE IMMEDIATE lv_sql_stmt;


                lv_total := lv_total+SQL%ROWCOUNT ;


                   EXCEPTION

                   WHEN table_not_found THEN
                   lv_errtxt := substr(SQLERRM,1,240) ;
                   MSC_ST_UTIL.LOG_MESSAGE(lv_errtxt);
                   exit;

                   WHEN synonym_translation_invalid THEN
                   lv_errtxt := substr(SQLERRM,1,240) ;
                   MSC_ST_UTIL.LOG_MESSAGE(lv_errtxt);
                   exit;

                   WHEN OTHERS THEN
                   lv_errtxt := substr(SQLERRM,1,240) ;
                   msc_st_util.log_message(lv_errtxt);
                   exit;

                   END;

                EXIT WHEN SQL%NOTFOUND;

                COMMIT;
                end loop;

              IF v_debug THEN
                       msc_st_util.log_message ('No. of rows deleted from '|| lv_table_name ||' - '||lv_total);
              END IF;



        END LOOP;
        CLOSE table_names;

  END IF;  --IF (lv_truncation_flag = SYS_YES) THEN

  END IF;   --  IF ( table_names%ROWCOUNT = 0 ) THEN

  EXCEPTION

  WHEN OTHERS THEN

  lv_errtxt := substr(SQLERRM,1,240) ;
  msc_st_util.log_message(lv_errtxt);

  END delete_records;


  /*========================================================================================+
  | DESCRIPTION  : This fuction is called to check whether the st_status for a particular   |
  |                instance is not in PULLING , LOADING and PRE-PROCESSING                  |
  +========================================================================================*/


  FUNCTION is_purge_possible ( ERRBUF  OUT NOCOPY VARCHAR2, RETCODE  OUT NOCOPY NUMBER, pINSTANCE_CODE   IN  VARCHAR2 , pINSTANCE_ID IN NUMBER )
  RETURN BOOLEAN
  AS
  lv_staging_table_status NUMBER;

  BEGIN

     SELECT ST_STATUS INTO lv_staging_table_status
     FROM msc_apps_instances
     WHERE INSTANCE_CODE= pINSTANCE_CODE
     FOR UPDATE;

            IF v_debug THEN
                 msc_st_util.log_message ('Entered to check whether purge possible for the instance-'||pINSTANCE_CODE);
            END IF;



           IF lv_staging_table_status=  G_ST_PULLING THEN
              FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PULLING');
              ERRBUF:= FND_MESSAGE.GET;

                IF v_debug THEN
                    msc_st_util.log_message (ERRBUF);
                END IF;

                IF ( pINSTANCE_ID <> -1 )
                THEN
                   v_program_status :=G_ERROR;

                ELSE
                   v_program_status :=G_WARNING;

                END IF;

                RETURN FALSE;


           ELSIF lv_staging_table_status= G_ST_COLLECTING THEN
              FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_LOADING');
              ERRBUF:= FND_MESSAGE.GET;

                IF v_debug THEN
                   msc_st_util.log_message (ERRBUF);
                END IF;

                IF ( pINSTANCE_ID <> -1 )
                THEN
                   v_program_status :=G_ERROR;

                ELSE
                   v_program_status :=G_WARNING;

                END IF;

                RETURN FALSE;

           ELSIF lv_staging_table_status= G_ST_PRE_PROCESSING THEN
              FND_MESSAGE.SET_NAME('MSC', 'MSC_ST_ERROR_PRE_PROCESSING');
              ERRBUF:= FND_MESSAGE.GET;

                IF v_debug THEN
                  msc_st_util.log_message (ERRBUF);
                END IF;

                IF ( pINSTANCE_ID <> -1 )
                THEN
                   v_program_status :=G_ERROR;

                ELSE
                   v_program_status :=G_WARNING;

                END IF;

                RETURN FALSE;


           ELSE
              UPDATE msc_apps_instances
              SET st_status=G_ST_PURGING
              WHERE INSTANCE_CODE= pINSTANCE_CODE;
              COMMIT;

              RETURN TRUE;

           END IF;


  END is_purge_possible;

  /*=============================================================================================+
  | DESCRIPTION  : This is the main program that deletes the records from the MSD staging        |
  |                tables.It takes instance_code as a parameter and deletes records for the      |
  |                instance only when st_status for this instance is not in G_ST_PULLING,        |
  |                G_ST_COLLECTING  and G_ST_PRE_PROCESSING .If the instance_code is null        |
  |                then it will delete records from all instances after checking the st_status.  |
  |                It also takes a parameter , whether to delete only errored out records or     |
  |                all legacy data (st_status check before deletion will only take place         |
  |                when 'delete only rejected records' parameter is set to NO).                  |
  +=============================================================================================*/


  PROCEDURE LAUNCH_PROCEDURE (  ERRBUF  OUT NOCOPY VARCHAR2,
                          RETCODE  OUT  NOCOPY NUMBER,
                          p_instance_id IN NUMBER,
                          p_del_rej_rec IN NUMBER)



  AS


  CURSOR instance_codes ( cp_instance_id NUMBER ) IS
  SELECT instance_code,instance_type,instance_id,st_status
  FROM msc_apps_instances
  WHERE ( cp_instance_id = -1 or instance_id=cp_instance_id );


  -- Cursor P is  for update to lock the records before checking for the st_status.

  CURSOR p (cp_instance_id NUMBER ) IS
  SELECT instance_code
  FROM msc_apps_instances
  WHERE st_status NOT IN (G_ST_PULLING,G_ST_COLLECTING,G_ST_PRE_PROCESSING)
  AND ( cp_instance_id= -1 or instance_id=cp_instance_id )
  FOR UPDATE;

  CURSOR total_instances IS
  SELECT count(*)
  FROM msc_apps_instances;

  CURSOR staging_status (cp_instance_id NUMBER ) IS
  SELECT count(*)
  FROM msc_apps_instances
  WHERE st_status IN ( G_ST_PULLING,G_ST_COLLECTING,G_ST_PRE_PROCESSING )
  AND ((instance_id=cp_instance_id) OR (cp_instance_id=-1));


  -- input variables of procedure
  lv_p_del_rej_rec  NUMBER;
  lv_p_instance_id  NUMBER ;


  -- variable for cursor instance_codes
  lv_instance_code    MSC_APPS_INSTANCES.INSTANCE_CODE%TYPE;
  lv_st_status        MSC_APPS_INSTANCES.ST_STATUS%TYPE;
  lv_instance_type    MSC_APPS_INSTANCES.INSTANCE_TYPE%TYPE;
  lv_instance_id      MSC_APPS_INSTANCES.INSTANCE_ID%TYPE;

  lv_inst_flag       NUMBER := 0 ;
  lv_st_status_flag  NUMBER:= 0;
  lv_trunc_profile   BOOLEAN:=FALSE;

  lv_trunc_flag       NUMBER := SYS_NO;

  lv_sql_stmt       VARCHAR2(500);
  lv_errtxt         VARCHAR2(300);



  table_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (table_not_found,-00942);


  BEGIN


  lv_p_instance_id := nvl( p_instance_id ,-1);
  lv_p_del_rej_rec :=p_del_rej_rec;




    v_debug := nvl(FND_PROFILE.VALUE('MRP_DEBUG'),'N') = 'Y';
    lv_trunc_profile := nvl(FND_PROFILE.VALUE('MSC_PURGE_ST_CONTROL'),'N') = 'Y';


    IF ( lv_trunc_profile AND lv_p_del_rej_rec=SYS_NO ) THEN
       OPEN total_instances;
        FETCH total_instances into lv_inst_flag;
       CLOSE total_instances;

        -- locking the records in msc_apps_instances before checking the st_status

                      open p(lv_p_instance_id);
                      close p;

       -- Counting number of instances for which st_status is G_ST_PULLING , G_ST_COLLECTING and G_ST_PRE_PROCESSING
       OPEN staging_status(lv_p_instance_id);
        FETCH staging_status into lv_st_status_flag;
       CLOSE staging_status;

             IF v_debug THEN
                 msc_st_util.log_message ('Value of lv_st_status_flag-'||lv_st_status_flag);
             END IF;
    END IF;

    -- Setting the truncation flag

    IF ( (lv_p_del_rej_rec  = SYS_NO ) AND ( lv_trunc_profile ) AND ((lv_p_instance_id  = -1) OR (lv_inst_flag = 1)) AND (lv_st_status_flag = 0) )
    THEN
         lv_trunc_flag :=SYS_YES;
    ELSE
         lv_trunc_flag :=SYS_NO;
    END IF;


  IF ( lv_trunc_flag = SYS_YES )  THEN

         delete_records (    p_instance_id   =>    lv_p_instance_id,
                             p_del_rej_rec   =>    lv_p_del_rej_rec,
                             p_trunc_flag    =>    lv_trunc_flag );

  ELSE



           commit;  -- To break the lock on the records, acquired while opening the cursor p or q

            IF v_debug THEN
              msc_st_util.log_message ('Truncation flag is NO. Entered in DELETION LOOP');
            END IF;

     OPEN instance_codes(lv_p_instance_id);
         LOOP
         FETCH instance_codes INTO lv_instance_code,lv_instance_type,lv_instance_id,lv_st_status;
            EXIT WHEN instance_codes%NOTFOUND;

            IF v_debug THEN
             msc_st_util.log_message(lv_instance_code);
            END IF;

             IF (lv_p_del_rej_rec=SYS_YES) THEN

              IF v_debug THEN
                           msc_st_util.log_message ('Deleting without checking the ST_STATUS');
              END IF;



               delete_records( lv_instance_code,lv_instance_id,lv_p_del_rej_rec,lv_trunc_flag);

             ELSE     --IF (lv_p_del_rej_rec=SYS_YES) THEN


                 IF ( is_purge_possible( ERRBUF,RETCODE,lv_instance_code,lv_p_instance_id) ) THEN


                      IF v_debug THEN
                           msc_st_util.log_message ('Deleting after checking the ST_STATUS');
                      END IF;

                      delete_records(lv_instance_code,lv_instance_id,lv_p_del_rej_rec,lv_trunc_flag);


                         IF v_debug THEN
                            msc_st_util.log_message ('Setting the st_status to empty');
                         END IF;

                         UPDATE msc_apps_instances
                         SET st_status=G_ST_EMPTY
                         WHERE instance_code=lv_instance_code;
                         COMMIT;




                 END IF;
             END IF;

         END LOOP;
     CLOSE instance_codes;


   END IF;



  IF v_program_status=G_WARNING THEN
     RETCODE := G_WARNING;
  ELSIF v_program_status=G_ERROR THEN
     RETCODE := G_ERROR;
  END IF;


EXCEPTION

  WHEN OTHERS THEN
  ERRBUF  := SQLERRM;
  RETCODE := G_ERROR;

  lv_errtxt := substr(SQLERRM,1,240) ;
  msc_st_util.log_message (lv_errtxt);

END LAUNCH_PROCEDURE;

END MSD_PURGE_LEG ;

/

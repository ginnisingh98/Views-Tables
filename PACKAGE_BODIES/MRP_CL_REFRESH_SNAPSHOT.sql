--------------------------------------------------------
--  DDL for Package Body MRP_CL_REFRESH_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CL_REFRESH_SNAPSHOT" AS
/* $Header: MRPCLEAB.pls 120.26.12010000.12 2010/05/06 00:26:18 schaudha ship $ */

   V_STMT_NO     NUMBER:= 0;
   V_REMOTE_CALL BOOLEAN :=FALSE; -- for 2351297
   TRUNCATE_LOG_ERROR        EXCEPTION;
   TYPE NumTblTyp IS TABLE OF NUMBER;

   --- PREPLACE CHANGE START ---

   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
   v_a2m_dblink                 VARCHAR2(128);

   lv_snapshot_str         VARCHAR2(4000):= ''; -- list of snapshots to be refreshed
   lv_refresh_param        VARCHAR2(80):= '';
                            -- combinations of 'C', 'F', ... for refreshment
   lv_num_of_snap           NUMBER := 0;

    v_database_version  number;
    lv_db_version       varchar2(100);
    lv_db_cmpt_version  varchar2(100);

      g_REFRESH_TYPE        VARCHAR2(30);
      g_CALLING_MODULE      NUMBER;
      g_INSTANCE_ID         NUMBER;
      g_INSTANCE_CODE       VARCHAR2(150);
      g_A2M_DBLINK          VARCHAR2(150);

   ---  PREPLACE CHANGE END  ---
      /* this procedure create index for SRP project */
      PROCEDURE CREATE_INDEX (lv_status IN OUT NOCOPY NUMBER) IS
      lv_sql_stmt varchar2(2000);
      lv_csd_schema                VARCHAR2(32);
      lv_csp_schema                VARCHAR2(32);
      lv_tablespace        VARCHAR2(30);
   lv_index_tablespace  VARCHAR2(30);
   lv_storage_clause    VARCHAR2(200);
   BEGIN

          lv_csd_schema  := MSC_UTIL.GET_SCHEMA_NAME(512);
          MSC_UTIL.GET_STORAGE_PARAMETERS('CSD_REPAIRS',
                                      lv_csd_schema,
                                      lv_tablespace,
                                      lv_index_tablespace,
                                      lv_storage_clause);

          lv_sql_stmt:= 'CREATE INDEX CSD_REPAIRS_N11 ON CSD_REPAIRS (inventory_org_id ,'
                         || 'last_update_date ,REPAIR_MODE ) TABLESPACE '
                         ||lv_index_tablespace;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_sql_stmt);
          BEGIN
            Csd_Repairs_Util.create_csd_index(lv_sql_stmt,'CSD_REPAIRS_N11');
            lv_status :=1 ;
           EXCEPTION
               WHEN OTHERS THEN
                IF SQLCODE IN (-01408) THEN
                      /*Index on same column already exists*/
                  lv_status :=1 ;
                ELSIF   SQLCODE IN (-00955) THEN
                      /*Index already exists*/
                 lv_status :=1 ;
                ELSE
                  lv_status := 2 ;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
                  raise_application_error(-20001, 'Index Creation failed: ' || sqlerrm);
                END IF;
          END ;
          lv_csp_schema  := MSC_UTIL.GET_SCHEMA_NAME(523);
          MSC_UTIL.GET_STORAGE_PARAMETERS('CSP_REPAIR_PO_HEADERS',
                                      lv_csp_schema,
                                      lv_tablespace,
                                      lv_index_tablespace,
                                      lv_storage_clause);

          lv_sql_stmt:= 'CREATE INDEX  CSP_REPAIR_PO_HEADERS_N1 ON CSP_REPAIR_PO_HEADERS'
                         || '(WIP_id, REPAIR_PO_HEADER_ID, '
                         || 'INVENTORY_ITEM_ID) TABLESPACE '
                         ||lv_index_tablespace;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_sql_stmt);
          BEGIN
            CSP_REPAIR_PO_GRP.create_csp_index(lv_sql_stmt,'CSP_REPAIR_PO_HEADERS_N1');
            lv_status :=1 ;
           EXCEPTION
               WHEN OTHERS THEN
                IF SQLCODE IN (-01408) THEN
                      /*Index on same column already exists*/
                  lv_status :=1 ;
                ELSIF   SQLCODE IN (-00955) THEN
                      /*Index already exists*/
                 lv_status :=1 ;
                ELSE
                  lv_status := 2 ;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
                  raise_application_error(-20001, 'Index Creation failed: ' || sqlerrm);
                END IF;
          END ;

          lv_sql_stmt:= 'CREATE INDEX  CSP_REPAIR_PO_HEADERS_N2 ON CSP_REPAIR_PO_HEADERS'
                         || '( purchase_order_header_id) TABLESPACE '
                         ||lv_index_tablespace;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_sql_stmt);
          BEGIN
            CSP_REPAIR_PO_GRP.create_csp_index(lv_sql_stmt,'CSP_REPAIR_PO_HEADERS_N2');
            lv_status :=1 ;
           EXCEPTION
               WHEN OTHERS THEN
                IF SQLCODE IN (-01408) THEN
                      /*Index on same column already exists*/
                  lv_status :=1 ;
                ELSIF   SQLCODE IN (-00955) THEN
                      /*Index already exists*/
                 lv_status :=1 ;
                ELSE
                  lv_status := 2 ;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
                  raise_application_error(-20001, 'Index Creation failed: ' || sqlerrm);
                END IF;
          END ;

           lv_sql_stmt:= 'CREATE INDEX  CSP_REPAIR_PO_HEADERS_N3 ON CSP_REPAIR_PO_HEADERS'
                         || '( requisition_line_id ) TABLESPACE '
                         ||lv_index_tablespace;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_sql_stmt);
          BEGIN
            CSP_REPAIR_PO_GRP.create_csp_index(lv_sql_stmt,'CSP_REPAIR_PO_HEADERS_N3');
            lv_status :=1 ;
           EXCEPTION
               WHEN OTHERS THEN
                IF SQLCODE IN (-01408) THEN
                      /*Index on same column already exists*/
                  lv_status :=1 ;
                ELSIF   SQLCODE IN (-00955) THEN
                      /*Index already exists*/
                 lv_status :=1 ;
                ELSE
                  lv_status := 2 ;
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
                  raise_application_error(-20001, 'Index Creation failed: ' || sqlerrm);
                END IF;
          END ;
         lv_status :=1 ;
      END CREATE_INDEX;


    /* NEW Patching Strategy */
   /* This procedure will be called based on the profile option MSC_SOURCE_SETUP*/
   FUNCTION SETUP_SOURCE_OBJECTS  RETURN BOOLEAN
   IS
    l_user_id         NUMBER;
    l_application_id  NUMBER;
    l_resp_id         NUMBER;
    lv_request_id_drop NUMBER;
    lv_request_id_wip NUMBER;
    lv_request_id_wsm NUMBER;
    lv_request_id_wsh NUMBER;
    lv_request_id_bom NUMBER;
    lv_request_id_inv NUMBER;
    lv_request_id_csp NUMBER;
    lv_request_id_mrp NUMBER;
    lv_request_id_ont NUMBER;
    lv_request_id_pox NUMBER;
    lv_request_id_ahl NUMBER;
    lv_request_id_view NUMBER;
    lv_request_id_syn NUMBER;
    lv_request_id_trig NUMBER;
    lv_success boolean:= TRUE;
    lv_out number;
    lv_request_id_eam  NUMBER;   /* ds change: change */
    lv_sql_stmt varchar2(2000);
    lv_srp_enabled_flag           VARCHAR2(1);

    BEGIN
    /* Submit the request to  look for changed snapshots and drop these snapshots */
    lv_request_id_drop := FND_REQUEST.SUBMIT_REQUEST(
                          'MSC',
                          'MSCDROPS',
                          NULL,
                          NULL,
                          FALSE);  -- sub request

    commit;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '
               ||lv_request_id_drop||' :Checks for Snapshots which have changed and Drops them');
    wait_for_request(lv_request_id_drop, 10, lv_out);

    if lv_success THEN
        if lv_out = 2 THEN lv_success := FALSE ; end if;
    end if;

    if lv_success THEN
      lv_sql_stmt:= 'select NVL(FND_PROFILE.VALUE'||v_a2m_dblink||'(''MSC_SRP_ENABLED''),''N'')'
                     || ' from dual ';
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_sql_stmt);
      execute immediate lv_sql_stmt into  lv_srp_enabled_flag ;
      IF lv_srp_enabled_flag='Y' THEN
        CREATE_INDEX(lv_out);
        if lv_out = 2 THEN
          lv_success := FALSE ;
        end if;
      END IF ;

    END IF ;

   /* Only if the Drop Snapshot Process is successfull then call the create snapshots */

    if lv_success THEN --drop snapshots success
          lv_request_id_wsm := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCWSMSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_wsm||' :Creates WSM Snapshot Logs and Snapshots');

          lv_request_id_bom := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCBOMSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_bom||' :Creates BOM Snapshot Logs and Snapshots');

          lv_request_id_inv := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCINVSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_inv||' :Creates INV Snapshot Logs and Snapshots');

          lv_request_id_csp := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCCSPSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_csp||' :Creates CSP Snapshot Logs and Snapshots');

          lv_request_id_mrp := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCMRPSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_mrp||' :Creates MRP Snapshot Logs and Snapshots');

          lv_request_id_pox := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCPOXSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_pox||' :Creates PO Snapshot Logs and Snapshots');

          lv_request_id_ont := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCONTSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_ont||' :Creates OE Snapshot Logs and Snapshots');

          lv_request_id_wsh := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCWSHSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_wsh||' :Creates WSH Snapshot Logs and Snapshots');

          IF MRP_CL_FUNCTION.CHECK_AHL_VER = 1 THEN

          lv_request_id_ahl := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCAHLSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_ahl||' :Creates AHL Snapshot Logs and Snapshots');

          /* ds change: change start */
          lv_request_id_eam := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCEAMSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_eam||' :Creates EAM Snapshot Logs and Snapshots');

          /* ds change: change end */


          END IF;


               /* BUG 3019053
      * Create WIP snapshot only when the MRP snapshots are created
      * successfully.
      * This is done since the WIP snapshots need the snapshot log and Grants
      * on the new MRP table - mrp_ap_open_wip_status.
      */

          wait_for_request(lv_request_id_mrp, 10, lv_out);
          if lv_success THEN

          lv_request_id_wip := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCWIPSN',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_wip||' :Creates WIP Snapshot Logs and Snapshots');

              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;

          wait_for_request(lv_request_id_wsm, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_bom, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_inv, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_csp, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_pox, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_ont, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_wip, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_wsh, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          if MRP_CL_FUNCTION.CHECK_AHL_VER = 1 THEN
          wait_for_request(lv_request_id_ahl, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
         /* ds change: change start */
          wait_for_request(lv_request_id_eam, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
         /* ds change: change end */
         end if;
   /* Only if the Snapshot creation Process is successfull then create trigs, views,synms */

      if lv_success THEN --create snapshots success
          lv_request_id_syn := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCSYNMS',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_syn||' :Creates Synonyms used by Collections Process');

          wait_for_request(lv_request_id_syn, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;

       IF lv_success THEN     -- Only when Synonyms creation succcess
          lv_request_id_view := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCVIEWS',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_view||' :Creates Views used by Collections Process');

          lv_request_id_trig := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',
                                'MSCTRIGS',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trig||' :Creates Triggers used by Collections Process');
          wait_for_request(lv_request_id_view, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;
          wait_for_request(lv_request_id_trig, 10, lv_out);
          if lv_success THEN
              if lv_out = 2 THEN lv_success := FALSE ; end if;
          end if;


        END IF;  -- Synonyms creation succcess
       end if; -- create snapshots success
    end if; --drop snapshots success


   COMMIT;
   /* CALLING MAP_REGION_TO_SITE FOR MAPPING VENDOR SITES TO REGIONS */

   /* UPDATE THE PROFILE OPTION MSC_SOURCE_SETUP TO NO */

   IF lv_success THEN
 -- AND ( MRP_CL_FUNCTION.MAP_REGION_TO_SITE(null) = 1) THEN --9396359

   begin
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Updating Profile Option MSC_SOURCE_SETUP to No ');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Region Site Mapping not being called here ');

      UPDATE FND_PROFILE_OPTION_VALUES
      SET    PROFILE_OPTION_VALUE = 'N'
      WHERE  PROFILE_OPTION_ID = (SELECT PROFILE_OPTION_ID
                                  FROM FND_PROFILE_OPTIONS
                                  WHERE PROFILE_OPTION_NAME = 'MSC_SOURCE_SETUP');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Profile Option MSC_SOURCE_SETUP has been updated No ');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The Value No indicates that the Collection Setup Objects have been applied');
     COMMIT;
     return TRUE;

   EXCEPTION

      WHEN OTHERS THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error Updating Profile MSC_SOURCE_SETUP: '||SQLERRM);
   end;
   ELSE
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source Setup Objects Creation Requests did not complete Successfully');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Please check the Log files for the appropriate message:');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_drop);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_wip);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_eam);  /* ds change: change */
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_wsm);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_bom);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_inv);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_mrp);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_csp);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_pox);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_ont);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_wsh);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_ahl);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_view);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_syn);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_request_id_trig);


      return false;

   END IF;
      return true;

   EXCEPTION

      WHEN OTHERS THEN

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
         return FALSE;
   END SETUP_SOURCE_OBJECTS;
    /* NEW Patching Strategy */
--3967634 added function CHECK_INSTALL
   FUNCTION CHECK_INSTALL (app_name IN VARCHAR2)RETURN BOOLEAN
   IS
    l_status            varchar2(1);
    l_industry          varchar2(1);
    l_ora_schema        varchar2(30);
    l_return_code       boolean;
   BEGIN
    --
    -- Call FND routine to figure out installation status
    --
    -- If the license status is not 'I', Project Manufacturing is
    -- not installed.
    --
    l_return_code := fnd_installation.get_app_info(app_name,
                                                   l_status,
                                                   l_industry,
                                                   l_ora_schema);

    IF (l_return_code = FALSE) THEN
        return FALSE;
    END IF;
    IF (l_status <> 'I') THEN
        return FALSE;
    END IF;
        return TRUE;
   END CHECK_INSTALL;
--3967634

/* -- Removed logic from below function, and moved it to the overloaded function */

   PROCEDURE REFRESH_SNAPSHOT(
                      ERRBUF             OUT NOCOPY VARCHAR2,
                      RETCODE            OUT NOCOPY NUMBER,
                      p_user_name        IN  VARCHAR2,
                      p_resp_name        IN  VARCHAR2,
                      p_application_name IN  VARCHAR2,
                      p_refresh_type     IN  VARCHAR2,
                      o_request_id       OUT NOCOPY NUMBER,
                      pInstance_ID               IN  NUMBER,
                      pInstance_Code     IN  VARCHAR2,
                      pa2m_dblink        IN  VARCHAR2)
   IS

    l_application_id  NUMBER;
    lv_application_name  VARCHAR2(240);

   BEGIN

       lv_application_name := p_application_name;

       BEGIN

          SELECT APPLICATION_ID
            INTO l_application_id
            FROM FND_APPLICATION_VL
           WHERE APPLICATION_NAME = lv_application_name;

        EXCEPTION

           WHEN NO_DATA_FOUND THEN
              RETCODE:= G_ERROR;
              ERRBUF := 'NO_USER_DEFINED';
              RETURN;
           WHEN OTHERS THEN RAISE;
        END;

        REFRESH_SNAPSHOT(
                      ERRBUF,
                      RETCODE,
                      p_user_name,
                      p_resp_name,
                      p_application_name,
                      p_refresh_type,
                      o_request_id,
                      pInstance_ID,
                      pInstance_Code,
                      pa2m_dblink,
                      l_application_id
                      );

   END REFRESH_SNAPSHOT;

   /* -- Added this procedure to accept application_id instead of application_name */

   PROCEDURE REFRESH_SNAPSHOT(
                      ERRBUF             OUT NOCOPY VARCHAR2,
                      RETCODE            OUT NOCOPY NUMBER,
                      p_user_name        IN  VARCHAR2,
                      p_resp_name        IN  VARCHAR2,
                      p_application_name IN  VARCHAR2,
                      p_refresh_type      IN  VARCHAR2,
                      o_request_id       OUT NOCOPY NUMBER,
                      pInstance_ID               IN  NUMBER,
                      pInstance_Code     IN  VARCHAR2,
                      pa2m_dblink        IN  VARCHAR2,
                      p_application_id   IN  NUMBER)
   IS

    l_user_id         NUMBER;
    l_application_id  NUMBER;
    l_resp_id         NUMBER;

    lv_user_name         VARCHAR2(100);
    lv_resp_name         VARCHAR2(100);
    lv_ref_type          VARCHAR2(1);

    result            BOOLEAN;

    lv_log_msg           varchar2(500);

   BEGIN

   lv_ref_type := p_refresh_type;

    /* if user_id = -1, it means this procedure is called from a
       remote database */
    IF FND_GLOBAL.USER_ID = -1 THEN
       V_REMOTE_CALL := TRUE; -- for 2351297
       lv_user_name := p_user_name;
       lv_resp_name := p_resp_name;

        BEGIN
            SELECT USER_ID
               INTO l_user_id
               FROM FND_USER
             WHERE USER_NAME = lv_user_name;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
              RETCODE:= G_ERROR;
              ERRBUF := 'NO_USER_DEFINED';
              RETURN;
        END;

        IF MRP_CL_FUNCTION.validateUser(l_user_id,MSC_UTIL.TASK_COLL,lv_log_msg) THEN
            MRP_CL_FUNCTION.MSC_Initialize(MSC_UTIL.TASK_COLL,
                                           l_user_id,
                                           -1, --l_resp_id,
                                           -1 --l_application_id
                                           );
        ELSE
            RETCODE:= MSC_UTIL.G_ERROR;
            ERRBUF := lv_log_msg;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_log_msg);
            RETURN;
        END IF;

    END IF;

    IF V_REMOTE_CALL THEN
      result := FND_REQUEST.SET_MODE(TRUE);
      v_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'MRP',
                          'MSRFWOR',
                          NULL,
                          NULL,
                          FALSE,  -- not a sub request,code fix for 2351297
                          1,    -- Fast refresh
                          'COLL SNAPSHOTS',   --
                          0,       -- threshold not used
                          0,        -- degree of parallel
                 SYS_YES,      -- Conc. progr enabled
                 lv_ref_type,
                 G_COLLECTIONS,
                 pInstance_ID,
                 pInstance_Code,
                 pa2m_dblink);
    ELSE
     v_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'MRP',
                          'MSRFWOR',
                          NULL,
                          NULL,
                          TRUE,  -- sub request,code fix for 2351297
                          1,    -- Fast refresh
                          'COLL SNAPSHOTS',     --     IN  VARCHAR2,
                          0,       -- threshold not used
                          0,        -- degree of parallel
                          SYS_YES,    -- Conc. progr enabled
                          lv_ref_type,
                          G_COLLECTIONS,
                 pInstance_ID,
                 pInstance_Code,
                 pa2m_dblink);
     COMMIT;
    END IF;

    o_request_id := v_request_id;
    IF v_request_id = 0 THEN
       ERRBUF:= FND_MESSAGE.GET;
    END IF;

    RETCODE:= G_SUCCESS;

   EXCEPTION

       WHEN OTHERS THEN

         RETCODE:= G_ERROR;

         ERRBUF:= SQLERRM;

   END REFRESH_SNAPSHOT;


   PROCEDURE LOG_ERROR(  pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

     IF v_cp_enabled= SYS_YES THEN

         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
       null;

     ELSE

           null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);

     END IF;

   END LOG_ERROR;


PROCEDURE LOG_DEBUG( pBUFF                     IN  VARCHAR2)
 IS
BEGIN
  IF (G_MSC_DEBUG <> 'Y') THEN
    return;
  END IF;
  -- add a line of text to the log file and

  FND_FILE.PUT_LINE(FND_FILE.LOG,pBUFF);
    --DBMS_OUTPUT.PUT_LINE( pBUFF);
    null;
  return;

EXCEPTION
  WHEN OTHERS THEN
    return;
END LOG_DEBUG;

   PROCEDURE PURGE_OBSOLETE_DATA
     IS
       lv_mrp_schema VARCHAR2(30);
       lv_sql_stmt   VARCHAR2(100);
       lv_retval        boolean;
       lv_dummy1        varchar2(32);
       lv_dummy2        varchar2(32);

      CURSOR c_query_tables(lv_owner VARCHAR2) is
             SELECT table_name
                FROM ALL_TABLES
               WHERE TABLE_NAME like 'MRP_AD%'
            AND owner = lv_owner;

      BEGIN

          lv_mrp_schema := MSC_UTIL.G_MRP_SCHEMA;

         FOR c1 in c_query_tables(lv_mrp_schema)
             LOOP
             BEGIN

                lv_sql_stmt := 'TRUNCATE TABLE '||lv_mrp_schema||'.'||c1.table_name;
                   EXECUTE IMMEDIATE lv_sql_stmt;

             EXCEPTION
                  WHEN OTHERS THEN
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
             END;
          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

   END PURGE_OBSOLETE_DATA;

/*NEW PATCHING STRATEGY */
 PROCEDURE WAIT_FOR_REQUEST(
                      p_request_id in number,
                      p_timeout      IN  NUMBER,
                      o_retcode      OUT NOCOPY NUMBER)
   IS

   l_refreshed_flag           NUMBER;
   l_pending_timeout_flag     NUMBER;
   l_start_time               DATE;

   ---------------- used for fnd_concurrent ---------
   l_call_status      boolean;
   l_phase            varchar2(80);
   l_status           varchar2(80);
  l_dev_phase        varchar2(80);
   l_dev_status       varchar2(80);
   l_message          varchar2(240);
   l_request_id number;

   BEGIN
    l_request_id := p_request_id;
     l_start_time := SYSDATE;

     LOOP
     << begin_loop >>

       l_pending_timeout_flag := SIGN( SYSDATE - l_start_time - p_timeout/1440.0);

       l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                              ( l_request_id,
                                60,
                                10,
                                l_phase,
                               l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

       EXIT WHEN l_call_status=FALSE;

       IF l_dev_phase='PENDING' THEN
             EXIT WHEN l_pending_timeout_flag= 1;

       ELSIF l_dev_phase='RUNNING' THEN
             GOTO begin_loop;

       ELSIF l_dev_phase='COMPLETE' THEN
             IF l_dev_status = 'NORMAL' THEN
            o_retcode:= SYS_YES;
                RETURN;
             END IF;
             EXIT;

       ELSIF l_dev_phase='INACTIVE' THEN
             EXIT WHEN l_pending_timeout_flag= 1;
       END IF;

       DBMS_LOCK.SLEEP( 10);

     END LOOP;

     o_retcode:= SYS_NO;
     RETURN;
 END WAIT_FOR_REQUEST;
/*NEW PATCHING STRATEGY */


   PROCEDURE WAIT_FOR_REQUEST(
                      p_timeout      IN  NUMBER,
                      o_retcode      OUT NOCOPY NUMBER)
   IS

   l_refreshed_flag           NUMBER;
   l_pending_timeout_flag     NUMBER;
   l_start_time               DATE;

   ---------------- used for fnd_concurrent ---------
   l_call_status      boolean;
   l_phase            varchar2(80);
   l_status           varchar2(80);
   l_dev_phase        varchar2(80);
   l_dev_status       varchar2(80);
   l_message          varchar2(240);

   BEGIN

     l_start_time := SYSDATE;

     LOOP

       l_pending_timeout_flag := SIGN( SYSDATE - l_start_time - p_timeout/1440.0);

       l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                              ( v_request_id,
                                10,
                                10,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

       EXIT WHEN l_call_status=FALSE;

       IF l_dev_phase='PENDING' OR l_dev_phase='INACTIVE' THEN
           IF l_pending_timeout_flag= 1 THEN
               o_retcode:= G_PENDING_INACTIVE;
               RETURN;
           END IF;
       ELSIF l_dev_phase='COMPLETE' THEN
           IF l_dev_status = 'NORMAL' OR l_dev_status = 'WARNING' THEN
               o_retcode:= G_NORMAL_COMPLETION;
               RETURN;
           END IF;
           EXIT;
       END IF;

       DBMS_LOCK.SLEEP( 10);

     END LOOP;

     o_retcode:= G_OTHERS;
     RETURN;

   END WAIT_FOR_REQUEST;


/* added this private function to check the number of rows in snapshot log and whether to truncate it
   for bug: 2507837 The snapshot having 0 rows will also be completely refreshed*/
FUNCTION TRUNC_SNAP_LOG( pNUM_OF_ROWS   IN NUMBER,
                         pSCHEMA_NAME   IN VARCHAR2,
                         pTABLE_NAME    IN VARCHAR2,
                         pSNAP_NAME     IN VARCHAR2,
                         pDEGREE        IN NUMBER)
RETURN boolean
IS

lv_num_of_log_rows     NUMBER := 0;
lv_num_snp_rows        NUMBER := 0;
lv_sel_sql_stmt        VARCHAR2(200);
lv_sel_snp_stmt        VARCHAR2(200);
lv_trnc_sql_stmt       VARCHAR2(200);
lv_mlog_tab_name       VARCHAR2(30);
lv_prod_id             NUMBER;
lv_base_schema         VARCHAR2(48) := pSCHEMA_NAME;
lv_status              BOOLEAN := TRUE;
BEGIN
  v_cp_enabled := SYS_YES;

   begin

     SELECT  LOG_TABLE
       INTO  lv_mlog_tab_name
       FROM  ALL_SNAPSHOT_LOGS
      WHERE  MASTER    = upper(pTABLE_NAME)
        AND  LOG_OWNER = upper(lv_base_schema)
        AND  ROWNUM    = 1;

       IF pNUM_OF_ROWS > 0 THEN

         lv_sel_snp_stmt := ' select count(*) from '||MSC_UTIL.G_APPS_SCHEMA|| '.' ||pSNAP_NAME
                            || ' where rownum < 2 ';
         EXECUTE IMMEDIATE lv_sel_snp_stmt INTO lv_num_snp_rows;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' The number of rows in Snapshot: '|| pSNAP_NAME ||' more than .. '||lv_num_snp_rows);

         IF lv_num_snp_rows > 0 THEN
             lv_sel_sql_stmt := ' select count(*) from '||lv_base_schema|| '.'||lv_mlog_tab_name
                            || ' where rownum <= :p1 ';
             EXECUTE IMMEDIATE lv_sel_sql_stmt
                          INTO lv_num_of_log_rows
                         USING pNUM_OF_ROWS;

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows in Snapshot log: '||lv_mlog_tab_name
                                                   ||'  more than .. '||lv_num_of_log_rows);
         END IF;
       END IF;

   exception
     when others then
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, sqlerrm);
        raise;
   end;

   IF (pNUM_OF_ROWS <= lv_num_of_log_rows) OR (lv_num_snp_rows = 0) THEN

     begin
         lv_trnc_sql_stmt := 'TRUNCATE TABLE '||lv_base_schema|| '.' ||lv_mlog_tab_name;
         EXECUTE IMMEDIATE lv_trnc_sql_stmt;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Successfully Truncated the Snapshot Log         : '||lv_mlog_tab_name);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Successfully Truncated the Snapshot Log on Table: '||pTABLE_NAME);
     exception
         when others then
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_trnc_sql_stmt);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error while truncating Snapshot Log : '||lv_mlog_tab_name);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
               RETURN TRUE; --so that the MView can do a complete refresh.
     end;

   -- refresh the snapshot
   -- this condition will return TRUE , indicating that MView log is truncated
   lv_status := TRUE;

   ELSE
   -- this condition will return FALSE , indicating no need to truncate the log and refresh the snapshot
         lv_status := FALSE;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The Snapshot : '|| pSNAP_NAME ||' was not refreshed .');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The number of rows in Snapshot log: '||lv_mlog_tab_name
                                           ||' = '||lv_num_of_log_rows);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'This number('||lv_num_of_log_rows
                                 ||') is less than the thresold entered for truncating Logs: '
                                 || pNUM_OF_ROWS);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' The number of rows in Snapshot: '|| pSNAP_NAME ||' was = '||lv_num_snp_rows);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '-------------------------------------------------------------------');

END IF; -- If the truncate condition matches

RETURN lv_status;

EXCEPTION
    WHEN OTHERS THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
         RETURN FALSE;
END TRUNC_SNAP_LOG;

/*
-- This functions checks for the appropriate refresh type for a given snapshot.

-- The function will recommend a complete refresh of the snapshot under the foll conditions:
-- i)  If the base table has one or more rows, and the snapshot has 0 rows
-- ii) If the ratio of the no. of the rows in the snapshot log to the total no. of rows in the
       snapshot is greater than the value in profile MSC_SNAPSHOT_THRESHOLD

-- For all other conditions it will recommend force refresh
*/
FUNCTION SNAPSHOT_DATA_CORRECT( p_base_schema     IN VARCHAR2,
                                p_table      IN VARCHAR2,
                                p_snapshot   IN VARCHAR2)
RETURN boolean
IS
lv_tab_count   NUMBER := 0;
lv_snap_count  NUMBER := 0;
lv_log_count   NUMBER := 0;
lv_where_clause      VARCHAR2(2000) := NULL;
lv_mlog_tab_name      VARCHAR2(48);
lv_master_tbl          VARCHAR2(48);
lv_base_schema          VARCHAR2(48);
lv_snapshot_threshold     NUMBER := NVL(FND_PROFILE.VALUE('MSC_SNAPSHOT_THRESHOLD'),40);

BEGIN
/*
  IF (p_snapshot = 'MTL_MTRX_TMP_SN') OR (p_snapshot = 'WIP_FLOW_SCHDS_SN') OR
       (p_snapshot = 'WIP_WREQ_OPRS_SN') OR (p_snapshot = 'WIP_WOPRS_SN') OR
       (p_snapshot = 'WIP_WOPR_RESS_SN') OR (p_snapshot = 'AHL_SCH_MTLS_SN') OR
       (p_snapshot = 'WIP_OPR_RES_INSTS_SN') OR (p_snapshot = 'WIP_WOPR_NETWORKS_SN') OR
       (p_snapshot = 'BOM_RES_INST_CHNGS_SN') OR (p_snapshot = 'EAM_WO_RELATIONSHIPS_SN') OR
       (p_snapshot = 'WSM_LJ_OPR_RESS_INSTS_SN')
 THEN
      RETURN TRUE;
  END IF;
 */
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'start - snapshot_data_correct');
  -- Add the where clause which are used in snapshot definition
  IF (p_snapshot = 'MTL_SUPPLY_SN')     THEN
       lv_where_clause := '  ITEM_ID IS NOT NULL ';
  ELSIF (p_snapshot = 'MTL_SYS_ITEMS_SN')     THEN
       lv_where_clause := '  (mrp_planning_code IS NOT NULL   AND mrp_planning_code <> 6   AND ( inventory_item_flag = ''Y'' OR         eng_item_flag = ''Y'') '
                      ||'  AND bom_item_type <> 3    AND planning_make_buy_code IN (1,2)   AND primary_uom_code IS NOT NULL)   OR  ATP_FLAG <> ''N''   OR  ATP_COMPONENTS_FLAG <> ''N'' ';
  ELSIF (p_snapshot = 'MRP_SCHD_DATES_SN')     THEN
       lv_where_clause := ' Schedule_Level= 2 ';
  ELSIF (p_snapshot = 'PO_ACCEPTANCES_SN')     THEN
       lv_where_clause := ' accepted_flag IN (''Y'',''N'') ';
  ELSIF (p_snapshot = 'PO_CHANGE_REQUESTS_SN')     THEN
       lv_where_clause := '  document_type IN (''PO'',''RELEASE'') ';
  ELSIF (p_snapshot = 'WIP_DSCR_JOBS_SN')     THEN
       lv_where_clause := ' status_type IN (1, 3, 4, 6) ';
  ELSIF (p_snapshot = 'WIP_WREQ_OPRS_SN')     THEN
       lv_where_clause :=   ' wip_supply_type <> 6 '     ||
                             ' AND wip_entity_id = '      ||
                          ' (select wip_entity_id '    ||
                          '  from wip_discrete_jobs '  ||
                          '  where '                   ||
                          '  status_type in (1,3,4,6) '||
                          '  and wip_entity_id = WIP_REQUIREMENT_OPERATIONS.wip_entity_id ) ' ;
  ELSIF (p_snapshot = 'WIP_WOPRS_SN')     THEN
        lv_where_clause :=   '  wip_entity_id = '         ||
                             ' (select wip_entity_id '    ||
                             '  from wip_discrete_jobs '  ||
                             '  where '                   ||
                             '  status_type in (1,3,4,6) '||
                             '  and wip_entity_id = WIP_OPERATIONS.wip_entity_id ) ' ;
  ELSIF (p_snapshot = 'WIP_WOPR_RESS_SN')     THEN
        lv_where_clause :=   ' wip_entity_id = '          ||
                             ' (select wip_entity_id '    ||
                             '  from wip_discrete_jobs '  ||
                             '  where '                   ||
                             '  status_type in (1,3,4,6) '||
                             '  and wip_entity_id = WIP_OPERATION_RESOURCES.wip_entity_id ) ' ;
  ELSIF (p_snapshot = 'WIP_REPT_SCHDS_SN')     THEN
       lv_where_clause := ' Status_Type in (1,3,4,6) ';
  ELSIF (p_snapshot = 'OE_ODR_LINES_SN') THEN
       lv_where_clause := ' visible_demand_flag=''Y'' AND ordered_quantity <>0 AND ship_from_org_id IS NOT NULL ';
  ELSIF(p_snapshot = 'WSM_LJ_OPR_RESS_SN') THEN
       lv_where_clause := ' nvl(PHANTOM_FLAG,2) <> 1 ';
  ELSIF (p_snapshot = 'MRP_FORECAST_DATES_SN') THEN
        lv_where_clause := ' ORIGINATION_TYPE <> 10 ';
  ELSIF (p_snapshot = 'MTL_TXN_REQUEST_LINES_SN') THEN
        lv_where_clause := ' TRANSACTION_SOURCE_TYPE_ID = 5 ' ||
                           ' AND LINE_STATUS = 7 ' ||
                           ' AND LPN_ID IS NOT NULL ';
  END IF;

  IF(lv_where_clause  is not null) THEN
       lv_where_clause := ' WHERE '|| lv_where_clause;
  END IF;

  lv_base_schema := p_base_schema;
  lv_master_tbl  := p_table;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_master_tbl - ' || p_base_schema || '.' || lv_master_tbl);

  EXECUTE IMMEDIATE
         ' SELECT LOG_TABLE FROM ALL_SNAPSHOT_LOGS '
      || ' WHERE MASTER = :lv_master_tbl AND '
      || '       LOG_OWNER = :p_schema AND '
      || '       ROWNUM    = 1'
           INTO  lv_mlog_tab_name
           USING upper(lv_master_tbl), upper(lv_base_schema);
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_mlog_tab_name - ' || lv_mlog_tab_name);

  EXECUTE IMMEDIATE
         ' SELECT count(*) FROM ' || lv_master_tbl || lv_where_clause
           INTO lv_tab_count;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_tab_count - ' || lv_tab_count);

  EXECUTE IMMEDIATE
         ' SELECT count(1)  FROM '||MSC_UTIL.G_APPS_SCHEMA||'.'||p_snapshot
           INTO  lv_snap_count;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_snap_count - ' || lv_snap_count);

  EXECUTE IMMEDIATE
         ' SELECT count(*) FROM ' || lv_base_schema || '.' || lv_mlog_tab_name || ' WHERE nvl(snaptime$$, sysdate+1) > sysdate '
           INTO lv_log_count;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_log_count - ' || lv_log_count);

  IF ((lv_tab_count <> 0) AND (lv_snap_count = 0))
     OR
     (lv_log_count > (lv_snapshot_threshold/100)*lv_tab_count) THEN
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'returning false');
     RETURN FALSE;            -- Error out since the snapshot is not having any rows
  ELSE
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'returning true');
     RETURN TRUE;             -- snapshot data is correct - so continue the refresh
  END IF;

EXCEPTION
    WHEN OTHERS THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
         RETURN FALSE;           -- Error out
END SNAPSHOT_DATA_CORRECT;

/*------------------------------------------------------------
Procedure name       : Log_Snap_Ref_status
Parameters           :
IN                   : pSnapshot_Name varchar2
                     : pRefresh_Mode  varchar2
                     : pStatus        varchar2
                     : pElapsed_Time  number

Description          : This procedure prints the input parameters
                       in the log file.

------------------------------------------------------------ */

PROCEDURE Log_Snap_Ref_status
(
  pSnapshot_Name   IN VARCHAR2
, pRefresh_Mode    IN VARCHAR2
, pStatus          IN VARCHAR2
, pElapsed_Time    IN NUMBER
)
IS

   lv_message VARCHAR2(200);
BEGIN
   lv_message := RPAD (pSnapshot_Name, 40 , ' ');
   lv_message := lv_message || RPAD (pRefresh_Mode, 3, ' ');
   lv_message := lv_message || RPAD (pStatus, 10, ' ');
   lv_message := lv_message || RPAD (to_char(pElapsed_Time,'99990.9'),
                                     10, ' ');

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_message);

END Log_Snap_Ref_status;

/*------------------------------------------------------------
Procedure name       : handle_ORA_12034
Parameters           :
IN                   : pSnapshot_List varchar2
                     : pRefresh_Param varchar2
                     : pDegre         number
OUT                  : ERRBUF         varchar2
                     : RETCODE        number

Description          : This procedure will be called when
                       we encounter ORA-12034 when performing
                       fast refresh of snapshot(s).
                       In this procedure we will refresh the
                       snapshots one-by-one in the mode (fast or
                       complete) they were being refreshed originally.
                       If we encounter the ORA-12034 again,  we will do a
                       complete refresh of that snapshot alone.

                       After all snapshots are refreshed, we will
                       perform refresh of all snapshots together to
                       guarantee the atomicity of transactions.

------------------------------------------------------------ */

PROCEDURE handle_ORA_12034
(
  ERRBUF            OUT NOCOPY VARCHAR2
, RETCODE           OUT NOCOPY NUMBER
, pSnapshot_List    IN VARCHAR2
, pRefresh_Param    IN VARCHAR2
, pDegree           IN NUMBER)
IS
lv_snapshot_name  VARCHAR2(60);
lv_refresh_mode   VARCHAR2(1);
lv_total_snapshots NUMBER;
lv_snap_length    NUMBER;
lv_task_start_time DATE;
lv_elapsed_mins   NUMBER;

BEGIN

   -- First Copy the input snapshot strings into local variables.

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'In Procedure: handle_ORA_12034.');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Refreshing Snapshots One By One');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'pSnapshot_List: '||
                                          pSnapshot_List);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'pRefresh_Param: '||
                                          pRefresh_Param);

-- BUG 9684665
-- Need to initialize the variables: lv_snapshot_str and lv_refresh_param

   lv_snapshot_str  := pSnapshot_List;
   lv_refresh_param := pRefresh_Param;

   lv_total_snapshots := length(lv_refresh_param);

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_total_snapshots: '||
                                          to_char(lv_total_snapshots));

   FOR i IN 1..lv_total_snapshots LOOP

      -- Locate the first ',' in the snapshot string.

      lv_snap_length := instr(lv_snapshot_str, ',');

      IF (lv_snap_length = 0) THEN
         -- Last Snapshot in the list

         lv_snapshot_name := lv_snapshot_str;
         lv_refresh_mode := lv_refresh_param;
       ELSE
         lv_snapshot_name := SUBSTR(lv_snapshot_str, 1, lv_snap_length -1);
         lv_refresh_mode  := SUBSTR(lv_refresh_param,1,1);
         lv_snapshot_str := SUBSTR(lv_snapshot_str,lv_snap_length + 1,
                                   LENGTH(lv_snapshot_str));
         lv_refresh_param := SUBSTR(lv_refresh_param, 2,
                                    LENGTH(lv_refresh_param));
      END IF;

      -- Now Refresh the single snapshot.
      BEGIN

         lv_task_start_time := SYSDATE;
         if (v_database_version >= 10) and (lv_refresh_mode = 'C') then -- bug 8997371
             DBMS_MVIEW.REFRESH(lv_snapshot_name,
                                   lv_refresh_mode,
                                   atomic_refresh => FALSE,
                                   parallelism => pDegree);
         else
             DBMS_MVIEW.REFRESH(lv_snapshot_name,
                                   lv_refresh_mode,
                                   parallelism => pDegree);
         end if;
         lv_elapsed_mins := CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;
         COMMIT;
         Log_Snap_Ref_status (lv_snapshot_name,
                              lv_refresh_mode,
                              'SUCCESS',
                              lv_elapsed_mins);
      EXCEPTION
         WHEN OTHERS THEN

            lv_elapsed_mins := CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;
            MSC_UTIL.G_ERROR_STACK:= DBMS_UTILITY.FORMAT_ERROR_STACK;

            IF instr(MSC_UTIL.G_ERROR_STACK ,'ORA-12034') > 0 THEN --bug 8420469

               Log_Snap_Ref_status (lv_snapshot_name,
                                    lv_refresh_mode,
                                    'ORA'||to_char(SQLCODE),
                                    lv_elapsed_mins);

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Doing a Complete Refresh of the snapshot.');
               BEGIN

                  lv_task_start_time := SYSDATE;
                  if (v_database_version >= 10) then
                      DBMS_MVIEW.REFRESH(lv_snapshot_name,
                                            'C',
                                            atomic_refresh => FALSE,
                                            parallelism => pDegree);
                  else
                      DBMS_MVIEW.REFRESH(lv_snapshot_name,
                                            'C',
                                            parallelism => pDegree);
                  end if;
                  COMMIT;

                  lv_elapsed_mins := CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;

                  Log_Snap_Ref_status (lv_snapshot_name,
                                       'C*',
                                       'SUCCESS',
                                       lv_elapsed_mins);

               EXCEPTION
                  WHEN OTHERS THEN

                     lv_elapsed_mins := CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;

                  Log_Snap_Ref_status (lv_snapshot_name,
                                       'C',
                                       'ORA'||to_char(SQLCODE),
                                       lv_elapsed_mins);

                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in Complete Refresh of: '||
                                    lv_snapshot_name);
                  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
                  ROLLBACK;
                  RETCODE := G_ERROR;
                  ERRBUF := SQLERRM;
                  RETURN;
               END;
            ELSE
               ROLLBACK;
               RETCODE := G_ERROR;
               ERRBUF := SQLERRM;
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error Refreshing Snapshot : '||
               lv_snapshot_name || ' , Mode : ' ||
               lv_refresh_mode);
               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ERRBUF);
               RETURN;
            END IF;
      END;
   END LOOP;

   -- Now Perform a Refresh of ALL snapshots together to
   -- guarantee the atomicity of transactions

   BEGIN

      lv_task_start_time := SYSDATE;

      DBMS_MVIEW.REFRESH (pSnapshot_List,
                             pRefresh_Param,
                             atomic_refresh => TRUE,
                             parallelism => pDegree);
      COMMIT;

      lv_elapsed_mins :=
        CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;

   EXCEPTION
      WHEN OTHERS THEN

         ROLLBACK;
         RETCODE := G_ERROR;
         ERRBUF := SQLERRM;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error Refreshing Snapshots : '||
                    pSnapshot_List || ' , Mode : ' ||
                    pRefresh_Param);
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ERRBUF);
         RETURN;
   END;

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'All Snapshots Refreshed Successfully');
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, to_char(lv_elapsed_mins)|| ' Minutes Elapsed.');

   RETCODE := G_SUCCESS;
   RETURN;


END handle_ORA_12034;


/*-----------------------------------------------------------------------------
Procedure     : cancel_submitted_requests

Parameters     : p_req_id (IN) - table type which holds the request ids of all
            concurrent requests launched

Description     : for all request ids in p_req_id, we check the status of the
            request, and cancel it, if not already completed
-----------------------------------------------------------------------------*/
PROCEDURE cancel_submitted_requests (p_req_id IN NumTblTyp)
IS
   l_call_status      boolean;
   l_phase            varchar2(80);
   l_status           varchar2(80);
   l_dev_phase        varchar2(80);
   l_dev_status       varchar2(80);
   l_message          varchar2(240);
   l_request_id       number;
   l_canc_req_retval  number;

BEGIN
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Cancelling pending/running snapshots');
   FOR j IN 1..p_req_id.COUNT LOOP
      l_request_id:=p_req_id(j);

      l_call_status := FND_CONCURRENT.GET_REQUEST_STATUS
                                     (l_request_id,
                                      '',
                                      '',
                                      l_phase,
                                      l_status,
                                      l_dev_phase,
                                      l_dev_status,
                                      l_message);

      IF l_dev_phase <> 'COMPLETE' THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Cancelling request - ' || l_request_id);
         l_canc_req_retval := FND_AMP_PRIVATE.cancel_request (l_request_id, l_message);
         COMMIT;

         IF l_canc_req_retval = 0 THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in cancelling request, ' || l_request_id);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error - ' || l_message);
         END IF;

      END IF;

   END LOOP;
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Cancelled pending/running snapshots');

EXCEPTION
   WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in cancelling requests - ' || SQLERRM);
END cancel_submitted_requests;



FUNCTION CREATE_SNAPSHOT_STRING(  pSnapshot_str      IN VARCHAR2)
 RETURN VARCHAR2
 IS

   v_dblink                VARCHAR2(128);

   lv_item_flag                NUMBER;
   lv_item_subs_falg           NUMBER;   --SRP Adddition
   lv_vendor_flag              NUMBER;
   lv_customer_flag            NUMBER;
   lv_bom_flag                 NUMBER;
   lv_reserves_flag            NUMBER;
   lv_sourcing_flag            NUMBER;
   lv_wip_flag                 NUMBER;
   lv_iro_flag                 NUMBER;
   lv_ero_flag                 NUMBER;
   lv_saf_stock_flag           NUMBER;
   lv_po_flag                  NUMBER;
   lv_oh_flag                  NUMBER;
   lv_supplier_cap_flag        NUMBER;
   lv_supplier_resp_flag       NUMBER;
   lv_uom_flag                 NUMBER;
   lv_mds_flag                 NUMBER;
   lv_forecast_flag            NUMBER;
   lv_mps_flag                 NUMBER;
   lv_sales_order_flag         NUMBER;
   lv_u_sup_dem_flag           NUMBER;
   lv_nra_flag                 NUMBER;
   lv_src_hist_flag            NUMBER;
   lv_trip_flag                NUMBER;


   lv_snapshot_grp_str             VARCHAR2(150);
   lv_sql_stmt                 VARCHAR2(2000);

BEGIN

    IF pSnapshot_str = 'ALL SNAPSHOTS' THEN

        lv_snapshot_grp_str := ' ( ''SCAP'', ''FCST'',''ITEM'',''MRP'',''MRP'',''OH'''
                         ||',''RES'',''PO'',''ONT'',''SRSP'',''BOM'',''WSH'',''USUD'''
                         ||',''ERO'',''WIP'',''ISUB'',''EAM'')' ;

    ELSIF pSnapshot_str = 'COLL SNAPSHOTS' THEN

        SELECT DECODE( A2M_DBLINK,
                                  NULL, NULL_DBLINK,
                                         '@'||A2M_DBLINK)
        INTO v_dblink
        FROM MRP_AP_APPS_INSTANCES_ALL
        WHERE INSTANCE_ID = g_INSTANCE_ID
        AND   INSTANCE_CODE= g_INSTANCE_CODE
        AND   nvl(A2M_DBLINK,NULL_DBLINK) = nvl(g_A2M_DBLINK,NULL_DBLINK) ;

         lv_sql_stmt := '  SELECT item,ITEM_SUBSTITUTES,supplier, customer, bom, '
                        ||'       reservations, sourcing, wip,internal_repair,external_repair, safety_stock, '
                        ||'       po, oh, supplier_capacity, supplier_response, uom, mds, '
                        ||'       forecast, mps, sales_order,USER_SUPPLY_DEMAND,trip '
                        ||'  FROM msc_coll_parameters'||v_dblink
                        ||'  WHERE instance_id = '||g_INSTANCE_ID;

         EXECUTE IMMEDIATE lv_sql_stmt
                    INTO lv_item_flag,
                         lv_item_subs_falg,
                         lv_vendor_flag,
                         lv_customer_flag,
                         lv_bom_flag,
                         lv_reserves_flag,
                         lv_sourcing_flag,
                         lv_wip_flag,
                         lv_iro_flag,            -- For Bug 5909379
                         lv_ero_flag,            -- For Bug 5935273
                         lv_saf_stock_flag,
                         lv_po_flag,
                         lv_oh_flag,
                         lv_supplier_cap_flag,
                         lv_supplier_resp_flag,
                         lv_uom_flag,
                         lv_mds_flag,
                         lv_forecast_flag,
                         lv_mps_flag,
                         lv_sales_order_flag,
                         lv_u_sup_dem_flag,
                         lv_trip_flag;


         lv_snapshot_grp_str := '';

         IF (lv_po_flag = MSC_UTIL.SYS_YES) THEN    /* Added lv_reserves_flag for Bug 6144734 */
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''PO'',' ;
         END IF; -- lv_po_flag

         IF (lv_u_sup_dem_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''USUD'',' ;
         END IF; -- lv_po_flag

         IF (lv_item_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''ITEM'',' ;
         END IF; -- lv_item_flag

         -- SRP Changes
         IF (lv_item_subs_falg = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''ISUB'',' ;
         END IF;


         IF (lv_oh_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''OH'',' ;
         END IF; -- lv_oh_flag

    /*     IF (lv_reserves_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''RES'',' ;
         END IF; -- lv_reserves_flag
    */
         IF (lv_bom_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''BOM'',' ;
         END IF; -- lv_bom_flag

         IF ((lv_mps_flag = MSC_UTIL.SYS_YES) or (lv_mds_flag = MSC_UTIL.SYS_YES)) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''MRP'',' ;
         END IF; -- lv_mps_flag or lv_mds_flag

         IF (lv_forecast_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''FCST'',' ;
         END IF; -- lv_forecast_flag

         IF (lv_wip_flag = MSC_UTIL.SYS_YES OR lv_iro_flag = MSC_UTIL.SYS_YES OR lv_ero_flag = MSC_UTIL.SYS_YES OR lv_reserves_flag = MSC_UTIL.SYS_YES) THEN   -- Changed For Bug 5909379 SRP Internal Repairs
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''WIP'',''EAM'',' ;

                IF (lv_ero_flag = MSC_UTIL.SYS_YES OR lv_reserves_flag = MSC_UTIL.SYS_YES) THEN   /* For Bug 5937835 */
                    lv_snapshot_grp_str := lv_snapshot_grp_str || '''ERO'',' ;
                END IF ;

         END IF; -- lv_wip_flag

         IF (lv_supplier_cap_flag = MSC_UTIL.SYS_YES or lv_supplier_cap_flag = ASL_YES_RETAIN_CP) THEN
             lv_snapshot_grp_str := lv_snapshot_grp_str || '''SCAP'',' ;
         END IF; -- lv_supplier_cap_flag

         IF (lv_supplier_resp_flag = MSC_UTIL.SYS_YES) THEN
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''SRSP'',' ;
         END IF; -- lv_supplier_resp_flag

         IF ((lv_sales_order_flag = MSC_UTIL.SYS_YES)  OR (g_REFRESH_TYPE = 'I') OR (lv_reserves_flag = MSC_UTIL.SYS_YES)) THEN /* added lv_sales_order_flag for bug 6144734 */
            lv_snapshot_grp_str := lv_snapshot_grp_str || '''ONT'',' ;
         END IF; -- lv_reserves_flag or lv_sales_order_flag -- or Incremental

         IF (lv_trip_flag = MSC_UTIL.SYS_YES) THEN
             lv_snapshot_grp_str := lv_snapshot_grp_str || '''WSH'',' ;
         END IF; -- lv_trip_flag

         IF lv_snapshot_grp_str = '' or lv_snapshot_grp_str is NULL THEN
            NULL;
         ELSE
            lv_snapshot_grp_str := '(' || substr(lv_snapshot_grp_str,1,length(lv_snapshot_grp_str) -1 ) || ' ) ' ;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_snapshot_grp_str);
         END IF;
    ELSE

        lv_snapshot_grp_str := '(''' ||pSnapshot_str || ''')';

    END IF;

    RETURN lv_snapshot_grp_str;

END CREATE_SNAPSHOT_STRING;

function eval(exp varchar2)
return boolean as
val number;
begin
    if exp = '1' then
     val := 1;
    else
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Evaluating -- ' || exp);
        begin
            execute immediate ' select ' || exp || ' from dual ' into val;
        exception when others then
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error while evaluating :' || exp);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
            val :=0;
        end;
    end if;
    if val =1 then
      return true;
    else
      return false;
    end if;
end;

/*-----------------------------------------------------------------------------
Function     : split_refresh

Parameters     : p_refresh_param (IN) - string which holds the refresh type
            of snapshots to be refreshed

            p_snapshot_str (IN) - string which consists of the list of
            snapshots which need to be refreshed

Description     : this function will launch a standalone refresh snapshot conc
            program for every snapshot in p_snapshot_str
-----------------------------------------------------------------------------*/
FUNCTION split_refresh (p_refresh_mode IN NUMBER, p_snapshot_str IN VARCHAR2)
RETURN BOOLEAN IS

   lv_total_snapshots      NUMBER;
   lv_snap_length         NUMBER;
   lv_p_refresh_mode     NUMBER := p_refresh_mode;

   lv_snapshot_groups_str VARCHAR2(500);

   lv_req_id          NumTblTyp := NumTblTyp();
   lv_out          NUMBER;
   lv_failed_req_id     NUMBER;

   lv_retval           boolean;
   lv_dummy1           varchar2(32);
   lv_dummy2           varchar2(32);
   lv_mrp_schema      varchar2(30);
   lv_prod_short_name   varchar2(30);

   lv_snapshot_name  varchar2(50);
   lv_existance_check varchar2(200);

   i NUMBER := 1;

   TYPE CurTyp is ref cursor;

   c_snap CurTyp;

   lv_cusros_str varchar2(500);

BEGIN

   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Start: split_refresh');

   lv_snapshot_groups_str := CREATE_SNAPSHOT_STRING(p_snapshot_str);

   IF lv_snapshot_groups_str = '' or lv_snapshot_groups_str is NULL THEN
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'No Snapshots selected');
   ELSE

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_snapshot_groups_str);

       lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(704);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Product short name - ' || lv_prod_short_name);

       lv_mrp_schema := MSC_UTIL.G_MRP_SCHEMA;
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'MRP schema - ' || lv_mrp_schema);

       lv_cusros_str := '   select mview_name, existance_check
                             from msc_coll_snapshots_v
                             where mview_name in ' || lv_snapshot_groups_str || '
                              or snapshot_group_string in ' || lv_snapshot_groups_str ;

       OPEN c_snap for lv_cusros_str;


       LOOP
          fetch c_snap into lv_snapshot_name,lv_existance_check;
          exit when c_snap%notfound;
          if eval(lv_existance_check) then
              lv_snapshot_str  := lv_snapshot_str || lv_snapshot_name || ',' ;
              lv_refresh_param := lv_refresh_param || '?';
              lv_num_of_snap  := lv_num_of_snap + 1;

              IF (g_REFRESH_TYPE <> 'I' ) THEN

              lv_req_id.EXTEND(1);
              v_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                  'MSC',
                                  'MSCCLRFS',
                                  NULL,
                                  NULL,
                                  FALSE,  -- sub request
                                  lv_p_refresh_mode,
                                  lv_snapshot_name,
                                  2,        -- degree of parallel
                                  v_refresh_number,
                                  0       -- threshold not used
                       );

              COMMIT;

              IF v_request_id = 0 THEN
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in launching program to refresh snapshot, ' || lv_snapshot_name);
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error message - ' || SQLERRM);
                 cancel_submitted_requests(lv_req_id);
                 close c_snap;
                 RETURN FALSE;
              ELSE
                 lv_req_id(lv_num_of_snap) := v_request_id;
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Submitted request ' || lv_req_id(i) || ', to refresh snapshot: ' || lv_snapshot_name);
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '------------------------------------------------');
              END IF;

              EXIT WHEN v_request_id = 0;
          END IF; -- g_REFRESH_TYPE
          end if; --eval (lv_existance_check)
       END LOOP;
       close c_snap;

       --removing the additional coma(,) at the end
       if lv_num_of_snap > 0 then
            lv_snapshot_str := substr(lv_snapshot_str,1,length(lv_snapshot_str) -1 ) ;
       end if;

       IF (g_REFRESH_TYPE <> 'I' ) THEN

       FOR j IN 1..lv_req_id.COUNT LOOP
          wait_for_request(lv_req_id(j), 30, lv_out);

          IF lv_out = 2 THEN
             lv_failed_req_id := lv_req_id(j);

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'ERROR : Please see the log files of request, ' || lv_failed_req_id || ', for details');
             cancel_submitted_requests(lv_req_id);

             RETURN FALSE;
          END IF;

       END LOOP;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Successfully refreshed all snapshots');
       END IF; -- g_REFRESH_TYPE
   END IF;
   RETURN TRUE;

EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error Refreshing Snapshots : ' || SQLERRM);

         IF lv_req_id.COUNT > 0 THEN
            cancel_submitted_requests(lv_req_id);
         END IF;

         RETURN FALSE;

END split_refresh;

PROCEDURE REFRESH_SNAPSHOT(
                      ERRBUF            OUT NOCOPY VARCHAR2,
                      RETCODE           OUT NOCOPY NUMBER,
                      pREFRESH_MODE      IN  NUMBER,
                      pSNAPSHOT_NAME     IN  VARCHAR2,
                      pNUMBER_OF_ROWS    IN  NUMBER,
                      pDEGREE            IN  NUMBER,
                      pCP_ENABLED        IN  NUMBER,
                      pREFRESH_TYPE      IN  VARCHAR2,
                      pCALLING_MODULE    IN  NUMBER,
                      pINSTANCE_ID       IN  NUMBER,
                      pINSTANCE_CODE     IN  VARCHAR2,
                      pA2M_DBLINK        IN  VARCHAR2)
   IS

      v_lrn                   NUMBER;
      v_old_lrn               NUMBER;
      v_apps_lrn              NUMBER;
      --lv_refresh_number       NUMBER;
      lv_complete_ref_flow  NUMBER:= 2;
      lv_initialization_flag  NUMBER:= 2;
      lv_task_start_time      DATE;
      lv_elapsed_mins         NUMBER;

      lv_standard_ret         NUMBER;
      lv_wfd_ret_code         NUMBER;
      lv_wfd_err_msg          VARCHAR2(400);
      lv_last_ref_type           VARCHAR2(8);

      lv_refresh_mode         NUMBER       := pREFRESH_MODE;
      lv_snapshot_name        VARCHAR2(30) := pSNAPSHOT_NAME;
      lv_NUMBER_OF_ROWS       NUMBER       := nvl(pNUMBER_OF_ROWS,0);
      lv_DEGREE               NUMBER       := nvl(pDEGREE,0);

      lv_flm_appl_short_name   VARCHAR2(50);
      CONFIG_BOM_NOT_FOUND EXCEPTION;
      INDIVIDUAL_REFRESH_ERROR EXCEPTION;

      lv_base_table_name        VARCHAR2(30);
      lv_base_schema            VARCHAR2(30);
      lv_snap_log_schema        VARCHAR2(30);
      lv_mlog_tab_name          VARCHAR2(30);

   lv_so_sn_flag               NUMBER;
   lv_wip_sn_flag              NUMBER;


   lv_wip_flag                 NUMBER;
   lv_sales_order_flag         NUMBER;
   lv_sourcing_flag            NUMBER;



   CURSOR c_item_name_seg IS
    select APPLICATION_COLUMN_NAME
      from FND_ID_FLEX_SEGMENTS
      where ID_FLEX_CODE = 'MSTK'
      and ENABLED_FLAG = 'Y'
      and DISPLAY_FLAG = 'Y'
      and APPLICATION_ID = 401
      and ID_FLEX_NUM = 101
      order by SEGMENT_NUM;

   lv_item_name_kfv   varchar2(2000) := NULL;
   delimiter          varchar2(10);

   ----- New variables for PREPLACE ----
   v_dblink                VARCHAR2(128);

   lv_sql_stmt             VARCHAR2(15000);
   lv_sql_stmt1            VARCHAR2(1500);

   dest_cursor             INTEGER;
   ignore                  INTEGER;

lv_setup_source_objs NUMBER;
SOURCE_SETUP_ERROR EXCEPTION;
lv_cursor_stmt varchar2(1000);

-- LRD for doing an incremental refresh of region to site mapping.
max_lrd DATE;
lv_map_region_during_coll NUMBER := 1;  --9396359


BEGIN

   -- setting the global variables
      g_REFRESH_TYPE        := pREFRESH_TYPE;
      g_CALLING_MODULE      := pCALLING_MODULE;
      g_INSTANCE_ID         := pINSTANCE_ID ;
      g_INSTANCE_CODE       := pINSTANCE_CODE;
      g_A2M_DBLINK          := pA2M_DBLINK;

  BEGIN
    DBMS_UTILITY.DB_VERSION (lv_db_version,lv_db_cmpt_version);
    v_database_version := to_number(substr(lv_db_version,1,instrb(lv_db_version,'.')-1) );
  EXCEPTION
   WHEN OTHERS THEN
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error getting DataBase version : ' || SQLERRM);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Assuming 9i to continue...');
   v_database_version := 9;
   --lv_db_version := v_version_9i;
   --RAISE;
  END;

 if pA2M_DBLINK is null then
   v_a2m_dblink := pA2M_DBLINK ;
 else
  v_a2m_dblink  := '@'||pA2M_DBLINK;
  end if ;
 v_cp_enabled := SYS_YES;
 v_refresh_type := pREFRESH_TYPE;
 lv_DEGREE    := LEAST(lv_DEGREE,10);

 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'ref mode - ' || pREFRESH_MODE);
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'snp name - ' || pSNAPSHOT_NAME);
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The degree of parallelism for Refreshing snapshots is set to:  ' || lv_DEGREE); --8761596
  --dbms_output.put_line('The degree of parallelism for Refreshing snapshots is set to:  '||lv_DEGREE);

  SELECT MRP_AP_REFRESH_S.NEXTVAL
     INTO v_refresh_number
     FROM DUAL;


 IF pCALLING_MODULE = G_COLLECTIONS THEN /* Forward Port Bug 2904050 */

  BEGIN
      SELECT max(LRD)
        INTO max_lrd
        FROM MRP_AP_APPS_INSTANCES_ALL;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETCODE:= G_ERROR;
        ERRBUF := 'NO_INSTANCE_FOUND';

      WHEN OTHERS THEN
        RAISE;
  END;


  BEGIN
      SELECT LRN, DECODE( A2M_DBLINK,
                              NULL, NULL_DBLINK,
                                     '@'||A2M_DBLINK)
        INTO v_old_lrn, v_dblink
        FROM MRP_AP_APPS_INSTANCES_ALL
        WHERE INSTANCE_ID = pINSTANCE_ID
        AND   INSTANCE_CODE= pINSTANCE_CODE
        AND   nvl(A2M_DBLINK,NULL_DBLINK) = nvl(pA2M_DBLINK,NULL_DBLINK) ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETCODE:= G_ERROR;
        ERRBUF := 'NO_INSTANCE_FOUND';
      WHEN OTHERS THEN
        RAISE;
  END;

  /* Frontport Bug 2904050 - We will pass the SO_LRN from msc_coll_parameters, and if it is null, we will pass APPS_LRN from msc_apps_instances for the explosion of
   SMCs */

    lv_sql_stmt := ' SELECT apps_lrn '
                   ||'  FROM msc_apps_instances'||v_dblink
                   ||' WHERE instance_id = '||pINSTANCE_ID;


     EXECUTE IMMEDIATE lv_sql_stmt
                INTO v_apps_lrn;

    lv_sql_stmt := '  SELECT nvl(min(so_lrn),'||to_char(v_apps_lrn)||')'
                    ||'  FROM msc_instance_orgs'||v_dblink
                    ||' WHERE sr_instance_id = '||pINSTANCE_ID;

     EXECUTE IMMEDIATE lv_sql_stmt
                INTO v_lrn;

 END IF;


   /* NEW Patching Strategy */
   /* Based on the profile option setting MSC_SOURCE_SETUP Setup the Source Objects */

   SELECT  DECODE(NVL(fnd_profile.value('MSC_SOURCE_SETUP') ,'Y'), 'Y',1 ,2)
   INTO    lv_setup_source_objs
   FROM    DUAL;

   IF (lv_setup_source_objs = 1) THEN
      IF SETUP_SOURCE_OBJECTS = FALSE THEN
         RAISE SOURCE_SETUP_ERROR;
      ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Source set up completed successfully');
      END IF;
   END IF;

   BEGIN
          -- after mtl_supply_sn is created the transaction_id will be zero,
          -- we need to do a complete refresh on mtl_supply_sn.
          -- if transaction_id = 0 exists, it means mtl_supply_sn is just created.
        lv_cursor_stmt :=
                 '      select 1'
               ||'        from mrp_sn_supply'
               ||'       where transaction_id= 0'
               ||'         and rownum=1';

        EXECUTE IMMEDIATE lv_cursor_stmt INTO lv_initialization_flag;

   EXCEPTION
         WHEN OTHERS THEN NULL;

   END;

    BEGIN

      IF split_refresh (lv_refresh_mode, pSNAPSHOT_NAME) = TRUE THEN

        IF (pREFRESH_TYPE <> 'I') THEN
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Successfully refreshed these Snapshots :');
        ELSE
            -- For complete/targeted collection, we need to
            -- incement the sequence once again so that the refresh of
            -- of all snapshots together gets a higher sequence number
            -- and this will be recorded in mrp_ap_apps_instances_all.lrn

            SELECT MRP_AP_REFRESH_S.NEXTVAL
            INTO v_refresh_number
            FROM DUAL;


        END IF;
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  substr(lv_snapshot_str,1,100) );
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  substr(lv_snapshot_str,101,100) );
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  substr(lv_snapshot_str,201,100) );
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  substr(lv_snapshot_str,301,100) );
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  substr(lv_snapshot_str,401,100) );
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  substr(lv_snapshot_str,501) );

                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Type of Refresh done: '||lv_refresh_param);
         ELSE
           ROLLBACK;
           RETCODE:= G_ERROR;
           ERRBUF:= SQLERRM;
           RAISE INDIVIDUAL_REFRESH_ERROR;
         END IF;

            --IF pCALLING_MODULE = G_COLLECTIONS and lv_num_of_snap > 1 THEN
            IF ( pCALLING_MODULE = G_COLLECTIONS )   THEN

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Doing a fast refresh of all snapshots...');
                BEGIN

                   lv_refresh_param := replace(lv_refresh_param, 'C', 'F');
                   lv_refresh_param := replace(lv_refresh_param, '?', 'F');

                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_snapshot_str: '
                    || lv_snapshot_str);
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_refresh_param: '
                    || lv_refresh_param);
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'lv_DEGREE: '
                    || to_char(lv_DEGREE));
                   DBMS_MVIEW.REFRESH ( lv_snapshot_str,lv_refresh_param,parallelism =>lv_DEGREE,atomic_refresh => TRUE);
                       COMMIT;
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Doen with refresh.');

                   RETCODE := G_SUCCESS;

                EXCEPTION
                   WHEN OTHERS THEN
                 MSC_UTIL.G_ERROR_STACK:= DBMS_UTILITY.FORMAT_ERROR_STACK;
                 IF instr(MSC_UTIL.G_ERROR_STACK ,'ORA-1578') > 0
                  OR instr(MSC_UTIL.G_ERROR_STACK ,'ORA-36040') > 0 THEN
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in refresh snapshot program : ' || MSC_UTIL.G_ERROR_STACK);
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Please Launch CP "DROP Collection SnapShots" with option "ALL SNAPSHOTS"');
                   RAISE;
                 END IF;
                 IF instr(MSC_UTIL.G_ERROR_STACK ,'ORA-12034') > 0 THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in refresh snapshot program : ' || SQLERRM);
                    handle_ORA_12034 (ERRBUF,
                                        RETCODE,
                                        lv_snapshot_str,
                                        lv_refresh_param,
                                        lv_DEGREE);
                      IF (RETCODE = G_ERROR) THEN
                             RAISE;
                      END IF;
                  END If;
               END ;

            END IF; --readconsistency
   /*   ELSE
            ROLLBACK;
            RETCODE:= G_ERROR;
            ERRBUF:= SQLERRM;
            RAISE INDIVIDUAL_REFRESH_ERROR;
      END IF; */

    EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RETCODE:= G_ERROR;
        ERRBUF:= SQLERRM;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ERRBUF);
        RAISE;
    END;


      IF lv_initialization_flag = 1 THEN

        lv_sql_stmt:= 'TRUNCATE TABLE '|| MSC_UTIL.G_MRP_SCHEMA||'.MRP_AD_SUPPLY';
        EXECUTE IMMEDIATE lv_sql_stmt;

      END IF;


        IF pCALLING_MODULE = G_COLLECTIONS THEN
          BEGIN

                       IF (pREFRESH_TYPE = 'T' ) THEN

                        lv_sql_stmt:=
                            'BEGIN MSC_CL_PULL.SALES_ORDER_REFRESH_TYPE'||v_dblink||'('
                          ||'             :pINSTANCE_ID, '
                          ||'             :lv_so_sn_flag );'
                          ||'END;';

                            EXECUTE IMMEDIATE lv_sql_stmt
                                          USING IN  pINSTANCE_ID,
                                                OUT lv_so_sn_flag;

                       END IF;

                       lv_sql_stmt := '  SELECT sales_order  '
                                     ||' , wip, wip_sn_flag '
                                     ||'  FROM msc_coll_parameters'||v_dblink
                                     ||'  WHERE instance_id = '||pINSTANCE_ID ;


                      EXECUTE IMMEDIATE lv_sql_stmt
                                 INTO lv_sales_order_flag,
                                      lv_wip_flag,
                                      lv_wip_sn_flag;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RETCODE:= G_ERROR;
              ERRBUF := 'Please verify Setup DBLinks setup in Source Database';
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ERRBUF);
            WHEN OTHERS THEN
          RETCODE:= G_ERROR;
             ERRBUF:= SQLERRM;
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ERRBUF);
             RAISE;
          END;

          IF (pREFRESH_TYPE = 'T' ) THEN
              IF (lv_sales_order_flag = 1) AND (lv_so_sn_flag = 4) THEN
                /* If sales order is to be Targeted mode in Continuous collections */
                v_lrn := -1;
           END IF;
       ELSE
                        /* For all other collections except continuous collections */
                IF (lv_sales_order_flag = 1) AND (pREFRESH_TYPE <> 'I' )THEN
                v_lrn := -1;
           END IF;
       END IF;

         IF (pREFRESH_TYPE = 'T' ) THEN
            IF (lv_wip_flag = 1) AND (lv_wip_sn_flag = 4) THEN
               /* If wip is to be Targeted mode in Continuous  collections */
               lv_complete_ref_flow := 1;
            END IF;
         ELSE
            /* For all other collections except continuous collections */
            IF (lv_wip_flag = 1 ) AND (pREFRESH_TYPE <> 'I') THEN
               lv_complete_ref_flow := 1;
            END IF;
         END IF;

        SELECT application_short_name
         INTO   lv_flm_appl_short_name
         FROM   fnd_application
         WHERE  application_id=714;

         IF (CHECK_INSTALL(lv_flm_appl_short_name)) THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Populating Flow Demand, Complete Refresh Flow: ' ||
                       to_char (lv_complete_ref_flow));

             lv_task_start_time := SYSDATE;

             BEGIN
                IF lv_complete_ref_flow = 1 THEN
                   MRP_FLOW_DEMAND.Main_Flow_Demand( -1,
                                      lv_wfd_ret_code,
                                      lv_wfd_err_msg);
                ELSE
                MRP_FLOW_DEMAND.Main_Flow_Demand( v_refresh_number,
                                      lv_wfd_ret_code,
                                      lv_wfd_err_msg);
                END IF;

                lv_elapsed_mins := CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, to_char(lv_elapsed_mins)|| ' Minutes Elapsed.');

              EXCEPTION
              WHEN OTHERS THEN
                 NULL;
              END;
              COMMIT;
           END IF;

          BEGIN
           IF (pREFRESH_TYPE = 'P' or pREFRESH_TYPE = 'T')
             and (lv_sales_order_flag =2) THEN
                /* if Sales order is NO (for targeted and Continuous
              * collections) , dont explode ATO */
               NULL;
          ELSE
               IF (v_explode_ato = 'Y') THEN
                    -- explode ATO only if the profile is YES
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Exploding SMC demand, LRN: ' || to_char (v_lrn));

                   lv_task_start_time := SYSDATE;

                   lv_standard_ret :=
                   MRP_EXPL_STD_MANDATORY.Explode_ATO_SM_COMPS(v_lrn);

                   lv_elapsed_mins :=
                   CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;

                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, to_char(lv_elapsed_mins)|| ' Minutes Elapsed.');

                   IF lv_standard_ret = 2 THEN
                       RAISE CONFIG_BOM_NOT_FOUND;
                   END IF;

               END IF;
          END IF;

          EXCEPTION
            WHEN CONFIG_BOM_NOT_FOUND THEN
                 RETCODE:= G_WARNING;
                    ERRBUF := 'Please check the warning message in the logfile';
                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ERRBUF);
             WHEN OTHERS THEN
               NULL;
          END;
          COMMIT;

          BEGIN
             select '||'''||CONCATENATED_SEGMENT_DELIMITER||'''||'
               into delimiter
               from fnd_id_flex_structures
              where ID_FLEX_CODE = 'MSTK'
                and APPLICATION_ID = 401
                and ID_FLEX_NUM = 101;

             for c_rec in c_item_name_seg loop
                if (lv_item_name_kfv is null) then
                    lv_item_name_kfv := 'x.'||c_rec.APPLICATION_COLUMN_NAME;
                else
                    lv_item_name_kfv := lv_item_name_kfv || delimiter ||'x.'||c_rec.APPLICATION_COLUMN_NAME;
                end if;
             end loop;
          EXCEPTION
          WHEN OTHERS THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' An error occured in building the item name from KFV');
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
            lv_item_name_kfv := 'x.SEGMENT1';
          END;


        lv_sql_stmt := 'UPDATE MRP_AP_APPS_INSTANCES_ALL '
               ||' SET LRN= MRP_AP_REFRESH_S.CURRVAL, '
              --  Resource Start Time. This time will be updated before the snapshot refresh.
              --            LRD= SYSDATE,
            ||' LAST_UPDATE_DATE= SYSDATE,'
            ||' LAST_UPDATED_BY= FND_GLOBAL.USER_ID,'
            ||' BOM_HOUR_UOM_CODE        =FND_PROFILE.VALUE(''BOM:HOUR_UOM_CODE''),'
            ||' MRP_MPS_CONSUMPTION      =DECODE( FND_PROFILE.VALUE(''MRP_MPS_CONSUMPTION''),'
            ||'                        ''Y'', 1,'
            ||'                        ''1'', 1,'
            ||'                        2),'
            ||' MRP_SHIP_ARRIVE_FLAG     =DECODE( FND_PROFILE.VALUE(''MRP_SHIP_ARRIVE_FLAG''),'
            ||'                        ''Y'', 1,'
            ||'                        ''1'', 1,'
            ||'                        2),'
            ||' CRP_SPREAD_LOAD          =DECODE( FND_PROFILE.VALUE(''CRP_SPREAD_LOAD''),'
            ||'                        ''Y'', 1,'
            ||'                        ''1'', 1,'
            ||'                        2),'
            ||' MSO_ITEM_DMD_PENALTY     =TO_NUMBER( FND_PROFILE.VALUE(''MSO_ITEM_DMD_PENALTY'')),'
            ||' MSO_ITEM_CAP_PENALTY     =TO_NUMBER( FND_PROFILE.VALUE(''MSO_ITEM_CAP_PENALTY'')),'
            ||' MSO_ORG_DMD_PENALTY      =TO_NUMBER( FND_PROFILE.VALUE(''MSO_ORG_DMD_PENALTY'')),'
            ||' MSO_ORG_ITEM_PENALTY     =TO_NUMBER( FND_PROFILE.VALUE(''MSO_ORG_ITEM_PENALTY'')),'
            ||' MSO_ORG_RES_PENALTY      =TO_NUMBER( FND_PROFILE.VALUE(''MSO_ORG_RES_PENALTY'')),'
            ||' MSO_ORG_TRSP_PENALTY     =TO_NUMBER( FND_PROFILE.VALUE(''MSO_ORG_TRSP_PENALTY'')),'
            ||' MSC_AGGREG_RES_NAME      =TO_NUMBER( FND_PROFILE.VALUE(''MSC_AGGREG_RES_NAME'')),'
            ||' MSO_RES_PENALTY          =TO_NUMBER( FND_PROFILE.VALUE(''MSO_RES_PENALTY'')),'
            ||' MSO_SUP_CAP_PENALTY      =TO_NUMBER( FND_PROFILE.VALUE(''MSO_SUP_CAP_PENALTY'')),'
            ||' MSC_BOM_SUBST_PRIORITY   =TO_NUMBER( FND_PROFILE.VALUE(''MSC_BOM_SUBST_PRIORITY'')),'
            ||' MSO_TRSP_PENALTY         =TO_NUMBER( FND_PROFILE.VALUE(''MSO_TRSP_PENALTY'')),'
            ||' MSC_ALT_BOM_COST         =TO_NUMBER( FND_PROFILE.VALUE(''MSC_ALT_BOM_COST'')),'
            ||' MSO_FCST_PENALTY         =TO_NUMBER( FND_PROFILE.VALUE(''MSO_FCST_PENALTY'')),'
            ||' MSO_SO_PENALTY           =TO_NUMBER( FND_PROFILE.VALUE(''MSO_SO_PENALTY'')),'
           -- MSC_ALT_OP_RES           =TO_NUMBER( FND_PROFILE.VALUE('MSC_RESOURCE_TYPE')),
            ||' MSC_ALT_RES_PRIORITY     =TO_NUMBER( FND_PROFILE.VALUE(''MSC_ALT_RES_PRIORITY'')),'
            ||' MSC_SIMUL_RES_SEQ        =TO_NUMBER( FND_PROFILE.VALUE(''MSC_SIMUL_RES_SEQ'')),'
            ||' MRP_BIS_AV_DISCOUNT      =NVL(TO_NUMBER(FND_PROFILE.VALUE(''MRP_BIS_AV_DISCOUNT'')),0),'
            ||' MRP_BIS_PRICE_LIST       =TO_NUMBER( FND_PROFILE.VALUE(''MRP_BIS_PRICE_LIST'')),'
            ||' MSC_DMD_PRIORITY_FLEX_NUM=NVL(TO_NUMBER( FND_PROFILE.VALUE(''MSC_DMD_PRIORITY_FLEX_NUM'')),0),'
            ||' MSC_BATCHABLE_FLAG     =TO_NUMBER( FND_PROFILE.VALUE(''MSC_BATCHABLE_FLAG'')),'
            ||' MSC_BATCHING_WINDOW     =TO_NUMBER( FND_PROFILE.VALUE(''MSC_BATCHING_WINDOW'')),'
            ||' MSC_MIN_CAPACITY     =TO_NUMBER( FND_PROFILE.VALUE(''MSC_MIN_CAPACITY'')),'
            ||' MSC_MAX_CAPACITY     =TO_NUMBER( FND_PROFILE.VALUE(''MSC_MAX_CAPACITY'')),'
            ||' MSC_UNIT_OF_MEASURE     =TO_NUMBER( FND_PROFILE.VALUE(''MSC_UNIT_OF_MEASURE'')),'
            ||' VALIDATION_ORG_ID     =NVL(TO_NUMBER( FND_PROFILE.VALUE(''MSC_ORG_FOR_BOM_EXPLOSION'')),to_number(null)),'
            ||' MSC_SO_OFFSET_DAYS    =TO_NUMBER( NVL(FND_PROFILE.VALUE'||v_dblink||'(''MSC_SO_OFFSET_DAYS''),99999)),'
            ||' ITEM_NAME_FROM_KFV    = :lv_item_name_kfv '
            ||' WHERE INSTANCE_ID = :pINSTANCE_ID'
                  ||' AND   INSTANCE_CODE= :pINSTANCE_CODE'
                  ||' AND   nvl(A2M_DBLINK,'||''''||NULL_DBLINK ||''''||') = nvl(:pA2M_DBLINK,'||''''||NULL_DBLINK||''''||') ';

       Execute immediate lv_sql_stmt
       USING             lv_item_name_kfv,
                         pINSTANCE_ID,
                         pINSTANCE_CODE,
                         pA2M_DBLINK;
       COMMIT;

       IF lv_standard_ret = 2 AND RETCODE = G_WARNING THEN
       RETCODE := G_WARNING;
       ELSE
       RETCODE:= G_SUCCESS;
       END IF;

   END IF; --pCALLING_MODULE = G_COLLECTIONS


    /* SITE TO REGION MAPPING */

 /* Employing different strategy for  Region Site Mapping --9396359
  */
  Begin
	SELECT  Nvl(fnd_profile.value('MSC_REFRESH_REGION_SITE'),1)
	INTO lv_map_region_during_coll
	FROM dual;
  Exception
	When Others Then
		lv_map_region_during_coll := 1;
  End;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Calling Module: '|| pCALLING_MODULE);
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Map Region Site during collection : '
                                        || lv_map_region_during_coll );
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Collection refresh type: '
                                        || pREFRESH_TYPE);
  IF (pCALLING_MODULE = G_COLLECTIONS) THEN
    Begin

      SELECT DECODE( A2M_DBLINK,
                              NULL, NULL_DBLINK,
                                     '@'||A2M_DBLINK)
      INTO v_dblink
      FROM MRP_AP_APPS_INSTANCES_ALL
      WHERE INSTANCE_ID = pINSTANCE_ID
      AND   INSTANCE_CODE= pINSTANCE_CODE
      AND   nvl(A2M_DBLINK,NULL_DBLINK) = nvl(pA2M_DBLINK,NULL_DBLINK) ;

      lv_sql_stmt := '  SELECT nvl(sourcing,0)  '
                   ||'  FROM msc_coll_parameters'||v_dblink
                   ||'  WHERE instance_id = '||pINSTANCE_ID ;

      EXECUTE IMMEDIATE lv_sql_stmt
      INTO lv_sourcing_flag;

    Exception
      WHEN OTHERS THEN
        lv_sourcing_flag := 0;
    End;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'The value of lv_sourcing_flag:'
                                         ||lv_sourcing_flag);
  END IF; --- pCALLING_MODULE

/* Before calling the function, check if sourcing actually is required  */
/* bug 5172853*/
/* Also if the table MRP_REGION_SITES is empty */
  IF (( pCALLING_MODULE = G_COLLECTIONS
       AND lv_map_region_during_coll = SYS_YES
       AND ( pREFRESH_TYPE='C' OR pREFRESH_TYPE='P')
       AND lv_sourcing_flag = 1 )
     OR
      ( pCALLING_MODULE = G_MANUAL
       AND lv_map_region_during_coll = SYS_NO )) THEN
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,
                   'before calling MRP_MAP_REG_SITE.MAP_REGION_TO_SITE');

     SELECT max(last_update_date)
     INTO max_lrd
     FROM MRP_REGION_SITES;

    /* msx_lrd may have null value or a valid value */

     lv_task_start_time := SYSDATE;

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,
          'Calling function MAP_REGION_TO_SITE with  max_lrd:'
             ||max_lrd);

     IF MRP_CL_FUNCTION.MAP_REGION_TO_SITE(max_lrd)=1 THEN NULL; END IF;

     lv_elapsed_mins := CEIL((SYSDATE- lv_task_start_time)*14400.0)/10;
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,
            'Time consumed for calling map_region_to_site:'
               || lv_elapsed_mins);

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,
           'after calling MRP_MAP_REG_SITE.MAP_REGION_TO_SITE');

  END IF;


    RETCODE:= G_SUCCESS;
    ERRBUF:=  null;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Refresh Snapshot process completed successfully');
    return;

EXCEPTION
    WHEN SOURCE_SETUP_ERROR  THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error Setting Up Source Objects');
         RETCODE:= G_ERROR;

         ERRBUF:= SQLERRM;

    WHEN INDIVIDUAL_REFRESH_ERROR THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
         RETCODE:= G_ERROR;
         ERRBUF:= SQLERRM;

    WHEN TRUNCATE_LOG_ERROR THEN
         RETCODE:= G_ERROR;
         ERRBUF:= SQLERRM;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

    WHEN OTHERS THEN

         ROLLBACK;

         RETCODE:= G_ERROR;

         ERRBUF:= SQLERRM;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);

END REFRESH_SNAPSHOT;

FUNCTION GET_REFRESH_TYPE     ( p_base_schema     IN VARCHAR2,
                                p_base_table_name IN VARCHAR2,
                                p_snapshot_name   IN VARCHAR2)
RETURN varchar2
IS
lv_refresh_type  varchar2(1);
lv_initialization_flag NUMBER :=2;
BEGIN



      IF SNAPSHOT_DATA_CORRECT(p_base_schema, p_base_table_name,p_snapshot_name) THEN

              lv_refresh_type := '?';

            --override rules...

              IF    ( (p_snapshot_name = 'MTL_SUPPLY_SN') OR
                      (p_snapshot_name = 'MTL_U_SUPPLY_SN') OR
                      (p_snapshot_name = 'MTL_U_DEMAND_SN')
                    ) THEN

                    BEGIN
                        EXECUTE IMMEDIATE
                                 '      select 1'
                               ||'        from mrp_sn_supply'
                               ||'       where transaction_id= 0'
                               ||'         and rownum=1'
                         INTO lv_initialization_flag;
                   EXCEPTION
                         WHEN OTHERS THEN NULL;
                   END;
                   IF     (lv_initialization_flag = 1 ) THEN
                        lv_refresh_type := 'C';
                   END IF;
              END IF;


      ELSE       -- SNAPSHOT_DATA_CORRECT
         /* launch the snapshot in complete mode without erroring out.*/
         lv_refresh_type := 'C';
      END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Optimal refresh type found:' ||lv_refresh_type );
      return lv_refresh_type;

END GET_REFRESH_TYPE;

PROCEDURE REFRESH_SINGLE_SNAPSHOT(
                      ERRBUF            OUT NOCOPY VARCHAR2,
                      RETCODE           OUT NOCOPY NUMBER,
                      pREFRESH_MODE      IN  NUMBER,
                      pSNAPSHOT_NAME     IN  VARCHAR2,
                      pDEGREE            IN  NUMBER,
                      pCURRENT_LRN       IN  NUMBER,
                      p_NUMBER_OF_ROWS   IN  NUMBER
)  IS
lv_erp_product_code  number;
lv_last_refresh_date NUMBER;
lv_last_ref_type     VARCHAR2(8);

lv_base_table_name        VARCHAR2(30);
lv_base_schema            VARCHAR2(30);

lv_ref_num         NUMBER;
lv_refresh_param      VARCHAR2(1);
lv_snapshot_name      VARCHAR2(100) := pSNAPSHOT_NAME;
lv_snap_str       VARCHAR2(150) := MSC_UTIL.G_APPS_SCHEMA||'.'||lv_snapshot_name;
BEGIN

  BEGIN
    DBMS_UTILITY.DB_VERSION (lv_db_version,lv_db_cmpt_version);
    v_database_version := to_number(substr(lv_db_version,1,instrb(lv_db_version,'.')-1) );

MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'Database Version: ' || lv_db_version);

  EXCEPTION
   WHEN OTHERS THEN
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error getting DataBase version : ' || SQLERRM);
   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Assuming 9i to continue...');
   v_database_version := 9;
   --lv_db_version := v_version_9i;
   --RAISE;
  END;

     --Set the global variable for triggers.
     IF pCURRENT_LRN = -1 THEN
       SELECT MRP_AP_REFRESH_S.NEXTVAL
         INTO v_refresh_number
         FROM DUAL;
     ELSE
       -- BUG 8997371
       -- Do a Dummy next val as the fast refresh on DB version 11.2
       -- does not find the PL/SQL package variable.

       SELECT MRP_AP_REFRESH_S.NEXTVAL
         INTO lv_ref_num
         FROM DUAL;

         v_refresh_number := pCURRENT_LRN;
     END IF;

      IF (pREFRESH_MODE = 1) THEN -- fast
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'single refresh, fast');
          lv_refresh_param := 'F';
      ELSIF (pREFRESH_MODE = 2) THEN --complete
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'single refresh, complete');
          lv_refresh_param := 'C';
      ELSE -- automatic or force
          SELECT  master_table, erp_product_code
            INTO  lv_base_table_name,lv_erp_product_code
            FROM  MSC_COLL_SNAPSHOTS_V
           WHERE  mview_name = lv_snapshot_name;

          lv_base_schema := MSC_UTIL.GET_SCHEMA_NAME(lv_erp_product_code);

          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Master-Table   = '|| lv_base_schema || '.'|| lv_base_table_name);

          --If logs are truncated, do Complete refresh, else let system decide best refresh method
          IF pREFRESH_MODE = 3 AND TRUNC_SNAP_LOG(p_NUMBER_OF_ROWS,lv_base_schema,
                                                  lv_base_table_name,lv_snapshot_name,pDEGREE) THEN
               lv_refresh_param := 'C';
          ELSE
            lv_refresh_param :=GET_REFRESH_TYPE(lv_base_schema, lv_base_table_name,lv_snapshot_name);
          END IF;
      END IF;  --  pREFRESH_MODE

         --Refreshing the snapshot
        BEGIN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Refreshing the snapshot : ' || lv_snap_str || ' in ' || lv_refresh_param || ' mode with degree ' || pDEGREE);
         if (v_database_version >= 10) and (lv_refresh_param = 'C') then   -- bug 8997371
             DBMS_MVIEW.REFRESH(LIST           => lv_snap_str,
                                METHOD         => lv_refresh_param,
                                atomic_refresh => FALSE,
                                parallelism    => pDEGREE);
         else
             DBMS_MVIEW.REFRESH(LIST           => lv_snap_str,
                                METHOD         => lv_refresh_param,
                                parallelism    => pDEGREE);
         end if;
        EXCEPTION
        WHEN OTHERS THEN
        MSC_UTIL.G_ERROR_STACK := DBMS_UTILITY.FORMAT_ERROR_STACK;
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in refresh snapshot program : ' || MSC_UTIL.G_ERROR_STACK);
           IF instr(MSC_UTIL.G_ERROR_STACK ,'ORA-1578') > 0
           OR instr(MSC_UTIL.G_ERROR_STACK ,'ORA-36040') > 0 THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in refresh snapshot program : ' || MSC_UTIL.G_ERROR_STACK);
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Please Launch CP "DROP Collection SnapShots" with option "ALL SNAPSHOTS"');
             RAISE;
           END IF;


           IF instr(MSC_UTIL.G_ERROR_STACK ,'ORA-12034') > 0 THEN
              handle_ORA_12034 (ERRBUF,
                                  RETCODE,
                                  lv_snap_str,
                                  lv_refresh_param,
                                  pDEGREE);

              IF (RETCODE = G_ERROR) THEN
                    RAISE;
              END IF;
              lv_refresh_param := '?';
           ELSE
                 RAISE;
           END IF;
        END;

       COMMIT;

       /* updating the msc_coll_snapshots lookup with mode in which snapshot was refreshed */
       IF lv_refresh_param = '?' THEN

           EXECUTE IMMEDIATE ' SELECT DECODE(last_refresh_type,''COMPLETE'',''C'', ''F'') '
                          || ' FROM all_mviews WHERE mview_name = :lv_snapshot_name '
                          || ' AND owner = :lv_snap_schema '
              INTO           lv_refresh_param  -- overwrite existing value with the actual refresh done...
             USING           lv_snapshot_name, MSC_UTIL.G_APPS_SCHEMA;

       END IF;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Refreshed the Snapshot: ' || lv_snap_str );
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Type of Refresh done  : ' || lv_refresh_param);
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '---------------------------------------------');


       IF lv_refresh_param = 'C' THEN
            UPDATE MSC_COLL_SNAPSHOTS_V
               SET  complete_refresh_timestamp = to_char(sysdate,'YYYY-MM-DD HH:MI:SS')
             WHERE  MVIEW_NAME = lv_snapshot_name ;

            COMMIT;
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'successfully updated the complete refresh time in fnd_lookup_values');
       END IF;

    EXCEPTION
    WHEN OTHERS THEN
          ROLLBACK;
          RETCODE:= G_ERROR;
          ERRBUF:= SQLERRM;
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error refreshing individual snapshot : ' || lv_snap_str);
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error : '|| ERRBUF);
          RAISE;
END REFRESH_SINGLE_SNAPSHOT;

PROCEDURE DROP_SNAPSHOT(
                      ERRBUF             OUT  NOCOPY VARCHAR2,
                      RETCODE            OUT  NOCOPY NUMBER,
                      p_snapshot_str     IN          VARCHAR2)
IS

  lv_sql_stmt             VARCHAR2(2000);
  lv_snapshot_groups_str VARCHAR2(500);
  lv_snapshot_name  varchar2(50);
  lv_existance_check varchar2(200);
  drop_count         number :=0;

   TYPE CurTyp is ref cursor;
   c_snap CurTyp;
   lv_cusror_str varchar2(500);

BEGIN

   v_cp_enabled := SYS_YES;

   lv_snapshot_groups_str := CREATE_SNAPSHOT_STRING(p_snapshot_str);

   IF lv_snapshot_groups_str = '' or lv_snapshot_groups_str is NULL THEN
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'No Snapshots selected');
   ELSE

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_snapshot_groups_str);

       lv_cusror_str := '   select mview_name, existance_check
                             from msc_coll_snapshots_v
                             where mview_name in ' || lv_snapshot_groups_str || '
                              or snapshot_group_string in ' || lv_snapshot_groups_str ;

       OPEN c_snap for lv_cusror_str;

       LOOP
          fetch c_snap into lv_snapshot_name,lv_existance_check;
          exit when c_snap%notfound;
          if eval(lv_existance_check) then

            lv_sql_stmt := 'DROP SNAPSHOT '||MSC_UTIL.G_APPS_SCHEMA||'.'||lv_snapshot_name;

            EXECUTE IMMEDIATE lv_sql_stmt;
            --Droping the Synonym and Trigger on this snapshot
            MSC_UTIL.DROP_MVIEW_TRIGGERS(MSC_UTIL.G_APPS_SCHEMA, lv_snapshot_name);
            MSC_UTIL.DROP_MVIEW_SYNONYMS(MSC_UTIL.G_APPS_SCHEMA, lv_snapshot_name);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Successfully dropped the Snapshot : '||MSC_UTIL.G_APPS_SCHEMA||'.'||lv_snapshot_name);
            drop_count := drop_count + 1;
          else
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Skipped the Snapshot : '||MSC_UTIL.G_APPS_SCHEMA||'.'||lv_snapshot_name);
          end if;
       END LOOP;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Number of snapshots dropped :' || to_char(drop_count));
   END IF;
   if drop_count > 0 then
    begin
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Updating Profile Option MSC_SOURCE_SETUP to Yes ');

      UPDATE FND_PROFILE_OPTION_VALUES
      SET    PROFILE_OPTION_VALUE = 'Y'
      WHERE  PROFILE_OPTION_ID = (SELECT PROFILE_OPTION_ID
                                  FROM FND_PROFILE_OPTIONS
                                  WHERE PROFILE_OPTION_NAME = 'MSC_SOURCE_SETUP');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Profile Option MSC_SOURCE_SETUP has been updated Yes ');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The Value Yes indicates that the Collection Setup Objects need to be recreated');
     COMMIT;

   EXCEPTION

      WHEN OTHERS THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error Updating Profile MSC_SOURCE_SETUP: '||SQLERRM);
   end;
   end if;
    RETCODE:= G_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
         ROLLBACK;
         RETCODE:= G_ERROR;
         ERRBUF:= SQLERRM;
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  SQLERRM);
END DROP_SNAPSHOT;


PROCEDURE check_MV_cont_ref_type(p_MV_name   in  varchar2,
                                 p_entity_lrn    in  number,
                                 entity_flag     OUT NOCOPY  number,
                                 p_ad_table_name in  varchar2,
                                 p_org_str       in  varchar2,
                                 p_coll_thresh   in  number,
                                 p_last_tgt_cont_coll_time  in  date,
                                 p_ret_code      OUT NOCOPY number,
                                 p_err_buf       OUT NOCOPY varchar2)
IS
lv_MV_complete_refresh  number :=0 ;
lv_existance_check varchar2(200);

lv_Num_del   number :=0 ;
lv_Num_new   number :=0 ;
lv_Num_snap  number :=0 ;

v_sql_stmt  Varchar2(2000);

BEGIN

  IF p_last_tgt_cont_coll_time is NOT NULL THEN
    BEGIN
      select 1 , existance_check
        into lv_MV_complete_refresh, lv_existance_check
        from msc_coll_snapshots_v
       where mview_name = p_MV_name
          and nvl(to_date(complete_refresh_timestamp,'YYYY-MM-DD HH:MI:SS'),p_last_tgt_cont_coll_time) > p_last_tgt_cont_coll_time;

         if NOT eval(lv_existance_check) then
            --Snapshot doesn't exist. So no collection required!!..
            entity_flag := MSC_UTIL.SYS_NO;
            RETURN;
         end if;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_MV_complete_refresh := 0;
     END;
    IF lv_MV_complete_refresh = 1 THEN
      entity_flag := MSC_UTIL.SYS_TGT;
      RETURN;
    END IF;
  END IF;

  IF p_ad_table_name is not null THEN
    v_sql_stmt := 'select count(*)
                     from ' || p_ad_table_name || '
                      where organization_id ' || p_org_str ;
    EXECUTE IMMEDIATE   v_sql_stmt INTO lv_Num_del;
  ELSE
    lv_Num_del := 0;
  END IF;

  v_sql_stmt := 'select count(*)
                   from ' || p_MV_name || '
                    where rn > ' || p_entity_lrn || '
                    and   organization_id ' || p_org_str ;
  EXECUTE IMMEDIATE   v_sql_stmt INTO lv_Num_new;

  v_sql_stmt := 'select count(*)
                   from ' || p_MV_name || '
                    where rn <= ' || p_entity_lrn || '
                    and   organization_id ' || p_org_str || '
                    and rownum < :num_thr'   ;
  EXECUTE IMMEDIATE   v_sql_stmt INTO lv_Num_snap USING 1+((lv_Num_del + lv_Num_new)/(p_coll_thresh/100));

  IF lv_Num_new = 0 and lv_Num_del = 0 THEN
      entity_flag := MSC_UTIL.SYS_NO;
  ELSIF lv_Num_snap =0 THEN
      entity_flag := MSC_UTIL.SYS_TGT;
  ELSIF (lv_Num_del + lv_Num_new) >= (p_coll_thresh * lv_Num_snap)/100 THEN
      entity_flag := MSC_UTIL.SYS_TGT;
  ELSE
      entity_flag := MSC_UTIL.SYS_INCR;
  END IF;



EXCEPTION WHEN OTHERS THEN
         entity_flag := MSC_UTIL.SYS_INCR;
         p_ret_code := MSC_UTIL.G_ERROR;
         p_err_buf  := p_err_buf || '  ' ||p_MV_name  ;
END check_MV_cont_ref_type;


PROCEDURE check_entity_cont_ref_type(p_entity_name   in  varchar2,
                                     p_entity_lrn    in  number,
                                     entity_flag     OUT NOCOPY  number,
                                     p_org_str       in  varchar2,
                                     p_coll_thresh   in  number,
                                     p_last_tgt_cont_coll_time  in  date,
                                     p_ret_code      OUT NOCOPY number,
                                     p_err_buf       OUT NOCOPY varchar2)
IS
   lv_snapshot_name  varchar2(50);
   lv_existance_check varchar2(200);
   lv_ad_table_name  varchar2(50);

   i NUMBER := 1;

   TYPE CurTyp is ref cursor;

   c_snap CurTyp;

   lv_cusros_str varchar2(500);

   lv_MV_complete_refresh  number :=0 ;
   lv_entity_decided  number := msc_util.sys_no;
   lv_entity_incr     number := msc_util.sys_no;
BEGIN

/*Check if any MV for this entity has undergone a complete refresh after last coll*/
  IF p_last_tgt_cont_coll_time is NOT NULL THEN
      BEGIN
        Execute immediate '
        select 1
          from msc_coll_snapshots_v
         where snapshot_group_string = ''' || p_entity_name  || '''
           and existance_check = to_char(' || MSC_UTIL.SYS_YES || ')
           and check_for_cont_refresh = ' || MSC_UTIL.SYS_YES || '
           and to_date(nvl(complete_refresh_timestamp,to_char(:vDate,''YYYY-MM-DD HH:MI:SS'')),''YYYY-MM-DD HH:MI:SS'') > :vDate
           and rownum < 2'
          into lv_MV_complete_refresh
        using p_last_tgt_cont_coll_time, p_last_tgt_cont_coll_time; -- tobe enhanced
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          lv_MV_complete_refresh := 0;
      END;
      IF lv_MV_complete_refresh = 1 THEN
        entity_flag := MSC_UTIL.SYS_TGT;
        RETURN;
      END IF;
  END IF;

lv_cusros_str := '   select mview_name, ad_table_name, existance_check
                             from msc_coll_snapshots_v
                             where check_for_cont_refresh = ' || MSC_UTIL.SYS_YES || '
                               and snapshot_group_string = ''' || p_entity_name || '''' ;

       OPEN c_snap for lv_cusros_str;


       LOOP
          fetch c_snap into lv_snapshot_name, lv_ad_table_name, lv_existance_check;
          exit when c_snap%notfound;
          if eval(lv_existance_check) then
              check_MV_cont_ref_type(lv_snapshot_name,
                                     p_entity_lrn,
                                     entity_flag,
                                     lv_ad_table_name,
                                     p_org_str,
                                     p_coll_thresh,
                                     p_last_tgt_cont_coll_time,
                                     p_ret_code,
                                     p_err_buf);

              IF entity_flag =   MSC_UTIL.SYS_TGT THEN
                lv_entity_decided := msc_util.sys_yes;
              ELSIF entity_flag =   MSC_UTIL.SYS_INCR THEN
                lv_entity_incr  :=    msc_util.sys_yes;
              END IF;

              /* if the last MV suggested no collection,
                  this need to be updated with previous result. */
               IF entity_flag =   MSC_UTIL.SYS_NO AND lv_entity_incr = msc_util.sys_yes THEN
                  entity_flag :=   MSC_UTIL.SYS_INCR;
               END IF;

              EXIT WHEN lv_entity_decided = msc_util.sys_yes;
          end if; --eval (lv_existance_check)
       END LOOP;

EXCEPTION
  WHEN OTHERS THEN
         p_ret_code := MSC_UTIL.G_ERROR;
         p_err_buf  := SQLERRM;
END check_entity_cont_ref_type;



PROCEDURE CREATE_SOURCE_VIEWS(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER)
IS
lv_request_id NUMBER;
type request_id_list_type is table of NUMBER index by pls_integer;
lv_request_id_views request_id_list_type;
lv_out number;
indx number := 0;
BEGIN
  --  setup
  indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWSTP',
                        NULL,
                        NULL,
                        FALSE);
  commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Setup Views used by Collections Process');
--
-- Item
indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWITM',
                        NULL,
                        NULL,
                        FALSE);
  commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Item Views used by Collections Process');
--
-- BOM
indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWBOM',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates BOM Views used by Collections Process');
 --
--  Routing
indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWRTG',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Routing Views used by Collections Process');
 --
-- WIP
indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWWIP',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates WIP Views used by Collections Process');
 --
 -- Demand
 indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWDEM',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Demand Views used by Collections Process');
 --

  -- Supply
  indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWSUP',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Supply Views used by Collections Process');
 --
 --   Other
 indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWOTH',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Other Views used by Collections Process');
 --
 -- Repair Order
 indx := indx + 1;
  lv_request_id_views(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCVWRPO',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_views(indx)||' :Creates Repair Order Views used by Collections Process');
 --
for i in 1 .. lv_request_id_views.last
loop
         wait_for_request(lv_request_id_views(i), 10, lv_out);
              if lv_out = 2 THEN
              ERRBUF  := 'Error in creating Source Views';
              RETCODE := MSC_UTIL.G_ERROR;
              EXIT;
              end if;
             --  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'id-'||lv_request_id_views(i));
end loop;

EXCEPTION
WHEN OTHERS THEN
RETCODE := MSC_UTIL.G_ERROR;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
RAISE;

END CREATE_SOURCE_VIEWS;

PROCEDURE CREATE_SOURCE_TRIGGERS(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER)
IS
lv_request_id NUMBER;
type request_id_list_type is table of NUMBER index by pls_integer;
lv_request_id_trigs request_id_list_type;
lv_out number;
indx number := 0;
BEGIN
-- Item
indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRITM',
                        NULL,
                        NULL,
                        FALSE);
  commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates Item Triggers used by Collections Process');
--
-- BOM
indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRBOM',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates BOM Triggers used by Collections Process');
 --
--  Routing
indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRRTG',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates Routing Triggers used by Collections Process');
 --
-- WIP
indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRWIP',
                        NULL,
                        NULL,
                        FALSE);
commit;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates WIP Triggers used by Collections Process');
 --
 -- Demand
 indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRDEM',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates Demand Triggers used by Collections Process');
 --

  -- Supply
  indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRSUP',
                        NULL,
                        NULL,
                        FALSE);
commit;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates Supply Triggers used by Collections Process');
 --
 --   Other
 indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTROTH',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates Other Triggers used by Collections Process');
 --
 -- Repair Order
 indx := indx + 1;
  lv_request_id_trigs(indx) := FND_REQUEST.SUBMIT_REQUEST(
                        'MSC',
                        'MSCTRRPO',
                        NULL,
                        NULL,
                        FALSE);
commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Request : '||lv_request_id_trigs(indx)||' :Creates Repair Order Triggers used by Collections Process');
 --
for i in 1 .. lv_request_id_trigs.last
loop
         wait_for_request(lv_request_id_trigs(i), 10, lv_out);
              if lv_out = 2 THEN
              ERRBUF  := 'Error in creating Source Triggers';
              RETCODE := MSC_UTIL.G_ERROR;
              EXIT;
              end if;
end loop;

EXCEPTION
WHEN OTHERS THEN
RETCODE := MSC_UTIL.G_ERROR;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,SQLERRM);
RAISE;

END CREATE_SOURCE_TRIGGERS;

END MRP_CL_REFRESH_SNAPSHOT;

/

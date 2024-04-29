--------------------------------------------------------
--  DDL for Package Body ZPB_DC_DISTRIBUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DC_DISTRIBUTE" AS
/* $Header: ZPBDCDBB.pls 120.4 2007/12/04 14:33:04 mbhat noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_DC_DISTRIBUTE';

  /*=========================================================================+
  |                       PROCEDURE submit_distrib_requests_cp
  |
  | DESCRIPTION
  |   Procedure calls distribute_data_cp and pass in necessary
  |    parameters.
  |
 +=========================================================================*/
 PROCEDURE submit_distrib_requests_cp
 (
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2
  )
  IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'submit_distrib_requests_cp';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
  l_user_id                 NUMBER;
  l_business_area_id        NUMBER;
  l_SID                     NUMBER;
  l_serial_no               NUMBER;
  l_sess_user               VARCHAR2(200);
  l_os_user                 VARCHAR2(200);
  l_status                  VARCHAR2(200);
  l_schema_name             VARCHAR2(200);
  l_machine                 VARCHAR2(200);
  l_req_id                  NUMBER;
  l_resp_id                 NUMBER;
  l_expired_user_exists BOOLEAN;


  CURSOR dist_pending_csr IS
  SELECT distinct object_user_id,
                business_area_id
   FROM ZPB_DC_OBJECTS
   WHERE status = 'DISTRIBUTION_PENDING'
   --AND object_user_id = 1009108
   --AND business_area_id = 22
   AND object_type in ('W','C');



BEGIN

  zpb_log.WRITE(l_api_name ,'Starting execution ');

  l_expired_user_exists := FALSE;

  FOR l_dist_pending_row_rec IN dist_pending_csr
  LOOP
   l_user_id := l_dist_pending_row_rec.object_user_id;
   l_business_area_id := l_dist_pending_row_rec.business_area_id;
   --Check if the user's AW is attached read/write
   zpb_personal_aw.personal_aw_rw_scan(p_user => TO_CHAR(l_user_id),
                                       p_business_area => l_business_area_id,
                                       p_SID  => l_SID,
                                       p_serial_no  => l_serial_no,
                                       p_sess_user  => l_sess_user,
                                       p_os_user  => l_os_user,
                                       p_status  => l_status,
                                       p_schema_name  => l_schema_name,
                                       p_machine  => l_machine);


  IF (l_SID is NULL OR l_SID = 0) THEN
   --We know that user's AW is now available for distribution
   --Submit a concurrent request
    zpb_log.WRITE_STATEMENT(l_api_name ,'Submit Conc Request for user=' || l_user_id ||' Buss Area= ' || l_business_area_id );
    --
    BEGIN
      SELECT  fugp.responsibility_id
        INTO  l_resp_id
        FROM  fnd_user_resp_groups fugp, fnd_responsibility fr
        WHERE responsibility_application_id = 210
        AND  fugp.responsibility_id = fr.responsibility_id
        AND user_id = l_user_id
        AND responsibility_key IN ('ZPB_CONTROLLER_RESP', 'ZPB_SUPER_CONTROLLER_RESP', 'ZPB_ANALYST_RESP')
        AND ROWNUM = 1;


      --fnd_global.apps_initialize(1009109,l_resp_id,210);
      fnd_global.apps_initialize(l_user_id,l_resp_id,210);

      l_req_id := FND_REQUEST.SUBMIT_REQUEST ('ZPB',
      'ZPB_DC_DATA_DISTRIB_REQ', NULL, NULL, FALSE,
      l_user_id,l_business_area_id);

      zpb_log.WRITE_STATEMENT(l_api_name ,'Conc Request id for user =' || l_req_id);
      COMMIT;

    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        l_expired_user_exists := TRUE;
        zpb_log.WRITE_TO_CONCMGR_LOG_TR('ZPB_DC_EXPIRED_USER',
          'USER_NAME',
          ZPB_WF_NTF.ID_to_FNDUser(l_user_id));
    END;

  END IF;


  END LOOP;

  zpb_log.WRITE_STATEMENT(l_api_name ,'Return Status=' || l_return_status);
  zpb_log.WRITE(l_api_name ,'Execution end');

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;


  IF l_expired_user_exists
  THEN
    retcode := '1';
  ELSE
    retcode := '0';
  END IF;

  COMMIT;
  RETURN;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     retcode := '2' ;
         errbuf:=substr(sqlerrm, 1, 255);

   WHEN OTHERS THEN
     retcode := '2' ;
     errbuf:=substr(sqlerrm, 1, 255);
END submit_distrib_requests_cp ;


/*=========================================================================+
  |                       PROCEDURE distribute_data_cp
  |
  | DESCRIPTION
  |   Procedure calls distribute_data_cp and pass in necessary
  |    parameters.
  |
 +=========================================================================*/


PROCEDURE distribute_data_cp( errbuf       OUT   NOCOPY VARCHAR2,
                                 retcode   OUT NOCOPY VARCHAR2,
                                 p_user_id IN  VARCHAR2,
                                 p_business_area_id IN NUMBER
)

IS
 l_api_name       CONSTANT VARCHAR2(30)   := 'distribute_data_cp';
 l_api_version    CONSTANT NUMBER         :=  1.0 ;
 --
 l_conc_request_id         NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
 l_SID                     NUMBER;
 l_serial_no               NUMBER;
 l_sess_user               VARCHAR2(200);
 l_os_user                 VARCHAR2(200);
 l_status                  VARCHAR2(200);
 l_schema_name             VARCHAR2(200);
 l_machine                 VARCHAR2(200);
 l_return_status           VARCHAR2(1);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);
 l_currency_view           VARCHAR2(2000);
 l_currency_profile_option VARCHAR2(2000);
 l_template_id             NUMBER;
 l_distributor_user_id     NUMBER;
 l_copy_instance_data_flag VARCHAR2(1);
 l_copy_target_data_flag   VARCHAR2(1);
 l_create_inst_meas_flag   VARCHAR2(1);
 l_create_solve_prg_flag   VARCHAR2(1);
 l_command                 VARCHAR2(2000);
 l_view_type               VARCHAR2(15);
 l_object_type             VARCHAR2(1);
 l_object_id               NUMBER;
 l_currency_flag           VARCHAR2(1);

 CURSOR dist_pending_csr IS
   SELECT template_id,distributor_user_id,
          copy_instance_data_flag,
          copy_target_data_flag,
          view_type,
          create_instance_measures_flag,
          create_solve_program_flag,
          object_type,
          object_id,
          currency_flag,
          ac_instance_id,
          generate_template_task_id
    FROM zpb_dc_objects
    WHERE status = 'DISTRIBUTION_PENDING'
    AND object_type in ('W','C')
    AND object_user_id = p_user_id
    AND business_area_id = p_business_area_id;


BEGIN
  zpb_log.WRITE(l_api_name ,'Starting execution ');
  zpb_log.WRITE_STATEMENT(l_api_name ,'Processing for user=' || p_user_id ||' Buss Area= ' || p_business_area_id );

  --Check if any other user has attached the user's AW r/w
   zpb_personal_aw.personal_aw_rw_scan(p_user => TO_CHAR(p_user_id),
                                       p_business_area => p_business_area_id,
                                       p_SID  => l_SID,
                                       p_serial_no  => l_serial_no,
                                       p_sess_user  => l_sess_user,
                                       p_os_user  => l_os_user,
                                       p_status  => l_status,
                                       p_schema_name  => l_schema_name,
                                       p_machine  => l_machine);


  IF (l_SID is NULL OR l_SID = 0) THEN
   --We know that user's AW is now available for distribution
   --Do distribution
   zpb_log.WRITE_STATEMENT(l_api_name ,'User AW available');
   --Initialise User AW and attach read write
   --ZPB_AW.INITIALIZE_USER(p_api_version       => 1.0,
   --                    p_init_msg_list     => FND_API.G_FALSE,
   --                    p_validation_level  => p_validation_level,
   --                    x_return_status     => x_return_status,
   --                    x_msg_count         => x_msg_count,
   --                     x_msg_data         => x_msg_data,
   --                    p_user              => p_user_id,
   --                    p_business_area_id  => l_business_area_id,
   --                    p_attach_readwrite  => FND_API.G_TRUE,
   --                    p_sync_shared       => FND_API.G_TRUE);


   --Initialize context
   ZPB_SECURITY_CONTEXT.INITCONTEXT(p_user_id   => p_user_id,
                                    p_shadow_id => p_user_id,
                                    p_resp_id   =>  1 ,
                                    p_session_id => 1 ,
                                    p_business_area_id => p_business_area_id);
   --Start up user's AW
   ZPB_PERSONAL_AW.STARTUP(p_api_version  => 1.0,
                     p_init_msg_list      => FND_API.G_FALSE,
                     p_commit             => FND_API.G_TRUE,
                     p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status      => l_return_status,
                     x_msg_count          => l_msg_count,
                     x_msg_data           => l_msg_data,
                     p_user               => p_user_id,
                     p_read_only          => FND_API.G_FALSE);

   zpb_log.WRITE_STATEMENT(l_api_name ,'Start up return status =' || l_return_status);
   zpb_log.WRITE_STATEMENT(l_api_name ,'Executed Startup');
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
     END IF;

   --Update the ZPB_USERS table with the conc req id
   UPDATE zpb_users
     SET conc_request_id = l_conc_request_id,
      conc_request_start_time = SYSDATE,
     -- WHO columns
     last_update_date        = SYSDATE,
     last_updated_by         = fnd_global.user_id,
     last_update_login       = fnd_global.LOGIN_ID
     WHERE user_id = p_user_id
     AND business_area_id = p_business_area_id;

   COMMIT;

   --Get the currency profile option for the user
   l_currency_profile_option := FND_PROFILE.VALUE_SPECIFIC('ZPB_DEF_CURR_VIEW',p_user_id);
   zpb_log.WRITE_STATEMENT(l_api_name ,'Users currency profile =' || l_currency_profile_option);

   --For each row that has distribution pending for this user do a distribute

   FOR l_dist_pending_row_rec IN dist_pending_csr
   LOOP
     --reset variable
     l_currency_view            := l_currency_profile_option;
     l_template_id              := l_dist_pending_row_rec.template_id;
     l_distributor_user_id      := l_dist_pending_row_rec.distributor_user_id;
     l_copy_instance_data_flag  := l_dist_pending_row_rec.copy_instance_data_flag;
     l_copy_target_data_flag    := l_dist_pending_row_rec.copy_target_data_flag;
     l_view_type                := l_dist_pending_row_rec.view_type;
     l_create_inst_meas_flag    := l_dist_pending_row_rec.create_instance_measures_flag;
     l_create_solve_prg_flag    := l_dist_pending_row_rec.create_solve_program_flag;
     l_object_type              := l_dist_pending_row_rec.object_type;
     l_object_id                := l_dist_pending_row_rec.object_id;
     l_currency_flag            := l_dist_pending_row_rec.currency_flag;

     IF (l_currency_flag = 'Y') THEN
      IF (l_create_inst_meas_flag <> 'Y') THEN
         --this a redistribution so use the current currency view for the worksheet
         l_currency_view := l_view_type;
      ELSE
         --this is a new distribution
         IF(l_currency_profile_option is NULL OR l_currency_profile_option = 'SAME') THEN
            --use the distributors currency
            IF(l_object_type = 'W' AND l_distributor_user_id <> -100) THEN
               SELECT view_type
               INTO l_currency_view
               FROM zpb_dc_objects
               WHERE template_id = l_template_id
               AND object_user_id = l_distributor_user_id
               AND object_type in ('W','C');
            END IF;
         END IF;
      END IF;
     END IF;


     IF (l_currency_view is NULL OR l_currency_view ='SAME') THEN
        l_currency_view := 'BASE';
     END IF;


     -- dbms_aw.execute('cm.logfile=''KGOYAL/dis.log''');

      IF(l_create_inst_meas_flag = 'Y' or l_create_solve_prg_flag = 'Y') THEN
        --Need to create structures
        l_command := 'call dc.distribute('    || '''' || l_template_id   || '''' ||
                                              ','  || '''' || l_distributor_user_id  || '''' ||
                                              ','  || '''' || p_user_id  || '''' ||
                                              ','  || '''' || l_copy_instance_data_flag  || '''' ||
                                              ','  || '''' || l_copy_target_data_flag  || '''' ||
                                              ','  || '''' || 'S'  || '''' ||
                                              ','  || '''' || l_currency_view  || '''' ||
                                                ')';
        zpb_log.WRITE_STATEMENT(l_api_name ,'Create Structure Command =' || l_command);
        zpb_aw.EXECUTE(l_command);
        zpb_log.WRITE_STATEMENT(l_api_name ,'Structure Created');
      END IF;

      --Do data distribution
      l_command := 'call dc.distribute('    || '''' || l_template_id   || '''' ||
                                                      ','  || '''' || l_distributor_user_id  || '''' ||
                                                      ','  || '''' || p_user_id  || '''' ||
                                                      ','  || '''' || l_copy_instance_data_flag  || '''' ||
                                                      ','  || '''' || l_copy_target_data_flag  || '''' ||
                                                      ','  || '''' || 'D'  || '''' ||
                                                      ','  || '''' || l_currency_view  || '''' ||
                                                ')';
     zpb_log.WRITE_STATEMENT(l_api_name ,'Distribute Data Command =' || l_command);
     zpb_aw.EXECUTE(l_command);
     zpb_log.WRITE_STATEMENT(l_api_name ,'Distribute Distributed');

     l_command := 'call sv.exe.dcsolve('''||l_template_id||''' '''||
        l_dist_pending_row_rec.ac_instance_id||''' '''||
        l_dist_pending_row_rec.generate_template_task_id||''')';

     zpb_log.WRITE_STATEMENT(l_api_name ,'Recalc Command =' || l_command);
     zpb_aw.EXECUTE(l_command);
     zpb_log.WRITE_STATEMENT(l_api_name ,'Recalculated');

     --Commit data to AW
      l_command := 'call pa.commit()';
      zpb_aw.EXECUTE(l_command);
      zpb_log.WRITE_STATEMENT(l_api_name ,'Data Committed');

     --Update ZPB_DC_OBJECTS with the currency
     IF (l_currency_flag = 'Y') THEN
       UPDATE zpb_dc_objects
        SET view_type = l_currency_view,
        -- WHO columns
        last_update_date        = SYSDATE,
        last_updated_by         = fnd_global.user_id,
        last_update_login       = fnd_global.LOGIN_ID
      WHERE template_id = l_template_id
      AND object_user_id = p_user_id;
     END IF;
     COMMIT;

   END LOOP;

   --All distribution is done
   --DO the AW clean up
   --
    ZPB_AW.clean_workspace (
             p_api_version       => 1.0,
             p_init_msg_list     => FND_API.G_FALSE,
             p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data);




   --Update ZPB_USERS and remove the request id
   UPDATE zpb_users
     SET conc_request_id  = NULL,
     conc_request_start_time = NULL,
     -- WHO columns
     last_update_date        = SYSDATE,
     last_updated_by         = fnd_global.user_id,
     last_update_login       = fnd_global.LOGIN_ID
     WHERE user_id = p_user_id
     AND business_area_id = p_business_area_id;

  END IF;
 zpb_log.WRITE(l_api_name ,'Execution end');
  retcode := '0';
  COMMIT;
  RETURN;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     retcode := '2' ;
     errbuf:=substr(sqlerrm, 1, 255);

   WHEN OTHERS THEN
     retcode := '2' ;
     errbuf:=substr(sqlerrm, 1, 255);
END distribute_data_cp ;
END ZPB_DC_DISTRIBUTE;

/

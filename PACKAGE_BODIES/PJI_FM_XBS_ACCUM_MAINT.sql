--------------------------------------------------------
--  DDL for Package Body PJI_FM_XBS_ACCUM_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_XBS_ACCUM_MAINT" AS
/* $Header: PJIPMNTB.pls 120.54.12010000.6 2009/06/12 06:39:47 paljain ship $ */


---------------------------------------------------------------------------
------ Global vars..
---------------------------------------------------------------------------

  g_package_name VARCHAR2(100) := 'PJI_FM_XBS_ACCUM_MAINT';
  g_update_num_rows_limit    NUMBER := 1; -- 1000;
  g_smart_rows_deleted       NUMBER :=0; --maintains the number of rows deleted in delete smart slice api
  g_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  g_deffered_mode VARCHAR2(1) :='N';
  g_success CONSTANT  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  Invalid_Excep      Exception ;


---------------------------------------------------------------------------
------ Specs of internal apis..
---------------------------------------------------------------------------

PROCEDURE CHECK_BUDGET_VERSION_EXISTS (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type() ) ;

PROCEDURE PRINT_TIME(p_tag IN VARCHAR2 := NULL);

PROCEDURE CLEANUP_TEMP_TABLES;

PROCEDURE WBS_HEADERS_LOCK (
    p_fp_version_ids   IN OUT NOCOPY       SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , p_context          IN          VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 );


PROCEDURE GET_HDRS_TOLOCK_FOR_UPDATE (
    x_fp_version_ids   OUT NOCOPY  SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 );


PROCEDURE GET_EVENT_IDS (
    p_fp_version_ids   IN          SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , p_operation_type   IN          VARCHAR2 := NULL
  , x_event_ids        OUT NOCOPY  SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 );


PROCEDURE DELETE_EVENTS (
    p_event_ids        IN          SYSTEM.pa_num_tbl_type
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 );


PROCEDURE COPY_PJI_SUMMRZD_FLAG (
    p_source_fp_version_ids   IN SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type()
  , p_dest_fp_version_ids     IN SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type() );


PROCEDURE MARK_PLAN_ORIGINAL	(
    p_original_version_id IN   NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_code            OUT NOCOPY  VARCHAR2 );

PROCEDURE PLAN_EXTR_LINES_LOCK (
    x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 );


PROCEDURE COPY_INTO_BASELINE_ORIGINAL(
   p_project_id      IN         NUMBER
 , p_plan_type_id    IN         NUMBER
 , p_plan_version_id IN         NUMBER
 , x_processing_code OUT NOCOPY VARCHAR2
);

PROCEDURE proces_event_pvt (
  p_event_id      IN  NUMBER,
  p_event_type    IN  VARCHAR2,
  x_processing_code OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2 );

PROCEDURE INSERT_APPLY_PROG_VD;

function submit_request(p_project_id IN NUMBER)
 return NUMBER
 IS
 pragma autonomous_transaction;
 l_request_id NUMBER;
 l_project pa_projects_all.segment1%TYPE; /* 4604355 */
 begin
   begin
	select segment1
	into l_project
	from pa_projects_all
	where project_id = p_project_id;
	exception
	    when no_data_found then null;
   end;
             l_request_id := FND_REQUEST.SUBMIT_REQUEST(
             application => PJI_UTILS.GET_PJI_SCHEMA_NAME ,-- Application Name
             program     => 'PJI_PJP_SUMMARIZE_INCR',     -- Program Name
             sub_request => FALSE,                         -- Sub Request
             argument1 => 'I',                            -- p_run_mode varchar2
             argument2 => '',
             argument3 => '',
             argument4 => '',                             -- p_run_mode varchar2
             argument5 => l_project ,      -- to_char(p_project_id)  ,  -- p_from_project_id
             argument6 => l_project );     -- to_char(p_project_id) );  -- p_to_project_id

	      commit;
return(l_request_id);
END submit_request;
---------------------------------------------------------------------------
------ Implementation of apis declared in package spec.
---------------------------------------------------------------------------

-- added procedure for bug#3993830
PROCEDURE debug_plan_lines
IS
BEGIN

IF NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N') = 'Y' THEN

INSERT INTO pji_fm_extr_plan_lines_debug
	(
	 PROJECT_ID                            ,
	 PROJECT_ORG_ID                        ,
	 PROJECT_ELEMENT_ID                    ,
	 STRUCT_VER_ID                         ,
	 PERIOD_NAME                           ,
	 CALENDAR_TYPE                         ,
	 START_DATE                            ,
	 END_DATE                              ,
	 RBS_ELEMENT_ID                        ,
	 RBS_VERSION_ID                        ,
	 PLAN_VERSION_ID                       ,
	 PLAN_TYPE_ID                          ,
	 WP_VERSION_FLAG                       ,
	 ROLLUP_TYPE                           ,
	 TXN_CURRENCY_CODE                     ,
	 TXN_RAW_COST                          ,
	 TXN_BURDENED_COST                     ,
	 TXN_REVENUE                           ,
	 PRJ_CURRENCY_CODE                     ,
	 PRJ_RAW_COST                          ,
	 PRJ_BURDENED_COST                     ,
	 PRJ_REVENUE                           ,
	 PFC_CURRENCY_CODE                     ,
	 PFC_RAW_COST                          ,
	 PFC_BURDENED_COST                     ,
	 PFC_REVENUE                           ,
	 QUANTITY                              ,
	 RESOURCE_CLASS_CODE		       ,
	 RATE_BASED_FLAG                       ,
	 ACT_QUANTITY                          ,
	 ACT_TXN_BURDENED_COST                 ,
	 ACT_PRJ_BURDENED_COST                 ,
	 ACT_PFC_BURDENED_COST                 ,
	 ACT_TXN_RAW_COST                      ,
	 ACT_PRJ_RAW_COST                      ,
	 ACT_PFC_RAW_COST                      ,
	 ACT_TXN_REVENUE                       ,
	 ACT_PRJ_REVENUE                       ,
	 ACT_PFC_REVENUE                       ,
	 ETC_QUANTITY                          ,
	 ETC_TXN_BURDENED_COST                 ,
	 ETC_PRJ_BURDENED_COST                 ,
	 ETC_PFC_BURDENED_COST                 ,
	 ETC_TXN_RAW_COST                      ,
	 ETC_PRJ_RAW_COST                      ,
	 ETC_PFC_RAW_COST                      ,
	 CREATION_DATE
	 )
 SELECT
	 PROJECT_ID                            ,
	 PROJECT_ORG_ID                        ,
	 PROJECT_ELEMENT_ID                    ,
	 STRUCT_VER_ID                         ,
	 PERIOD_NAME                           ,
	 CALENDAR_TYPE                         ,
	 START_DATE                            ,
	 END_DATE                              ,
	 RBS_ELEMENT_ID                        ,
	 RBS_VERSION_ID                        ,
	 PLAN_VERSION_ID                       ,
	 PLAN_TYPE_ID                          ,
	 WP_VERSION_FLAG                       ,
	 ROLLUP_TYPE                           ,
	 TXN_CURRENCY_CODE                     ,
	 TXN_RAW_COST                          ,
	 TXN_BURDENED_COST                     ,
	 TXN_REVENUE                           ,
	 PRJ_CURRENCY_CODE                     ,
	 PRJ_RAW_COST                          ,
	 PRJ_BURDENED_COST                     ,
	 PRJ_REVENUE                           ,
	 PFC_CURRENCY_CODE                     ,
	 PFC_RAW_COST                          ,
	 PFC_BURDENED_COST                     ,
	 PFC_REVENUE                           ,
	 QUANTITY                              ,
	 RESOURCE_CLASS_CODE		       ,
	 RATE_BASED_FLAG                       ,
	 ACT_QUANTITY                          ,
	 ACT_TXN_BURDENED_COST                 ,
	 ACT_PRJ_BURDENED_COST                 ,
	 ACT_PFC_BURDENED_COST                 ,
	 ACT_TXN_RAW_COST                      ,
	 ACT_PRJ_RAW_COST                      ,
	 ACT_PFC_RAW_COST                      ,
	 ACT_TXN_REVENUE                       ,
	 ACT_PRJ_REVENUE                       ,
	 ACT_PFC_REVENUE                       ,
	 ETC_QUANTITY                          ,
	 ETC_TXN_BURDENED_COST                 ,
	 ETC_PRJ_BURDENED_COST                 ,
	 ETC_PFC_BURDENED_COST                 ,
	 ETC_TXN_RAW_COST                      ,
	 ETC_PRJ_RAW_COST                      ,
	 ETC_PFC_RAW_COST                      ,
	 SYSDATE
 FROM
	 pji_fm_extr_plan_lines ;

END IF;

END;


PROCEDURE PLAN_DELETE (
    p_fp_version_ids   IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_code         OUT NOCOPY  VARCHAR2 ) IS

  l_fp_version_ids  SYSTEM.pa_num_tbl_type := p_fp_version_ids;
  l_fp_version_ids1 SYSTEM.pa_num_tbl_type := p_fp_version_ids;
  l_event_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_event_id        NUMBER := NULL;
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);
  l_processing_code VARCHAR2(12000);
  l_event_rec       pa_pji_proj_events_log%ROWTYPE;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status ) ;

  print_time ( ' PLAN_DELETE api ' );

  PRINT_PLAN_VERSION_ID_LIST(p_fp_version_ids);
  CHECK_BUDGET_VERSION_EXISTS(p_fp_version_ids);

  print_time ( ' plan delete 001 ' );

  FOR i IN l_fp_version_ids.FIRST..l_fp_version_ids.LAST LOOP -- Now, process each version as follows..

    print_time ( ' plan delete 002 ' );

    --
    -- Create event.
    --
    l_event_rec.event_type     := 'PLAN_DELETE';
    l_event_rec.event_object   := l_fp_version_ids(i);
    l_event_rec.operation_type := 'D';
    l_event_rec.status         := 'X';

    CREATE_EVENT(l_event_rec);

    print_time ( ' plan delete 003 ' );


    --
    -- Plan delete pvt api.
    --
    l_fp_version_ids1 := SYSTEM.pa_num_tbl_type (l_fp_version_ids(i));

    PLAN_DELETE_PVT (
      p_event_id          => l_event_rec.event_id
    , x_return_status     => x_return_status
    , x_processing_code   => x_msg_code);

    print_time ( ' plan delete 004 ' );

  END LOOP;

  print_time ( ' plan delete 005 ' );

  -- COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_DELETE'
    , x_return_status  => x_return_status ) ;

    RAISE;

END;


PROCEDURE PLAN_DELETE_PVT (
  p_event_id           IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_processing_code    OUT NOCOPY  VARCHAR2 ) IS

  l_plan_version_id   NUMBER := NULL;
  l_fp_version_ids    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);
  l_event_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  BEGIN

    SELECT event_object
    INTO   l_plan_version_id
    FROM   PA_PJI_PROJ_EVENTS_LOG
    WHERE  event_id = p_event_id;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  print_time ( ' plan delete pvt 002 ' );

  l_fp_version_ids := SYSTEM.pa_num_tbl_type (l_plan_version_id);

  print_time ( ' plan delete pvt 003 ' );

  WBS_HEADERS_LOCK (
    p_fp_version_ids   => l_fp_version_ids
  , p_context          => 'DELETE'
  , x_return_status    => x_return_status
  , x_msg_code         => x_processing_code   );

  IF (l_fp_version_ids.COUNT <= 0) THEN
    print_time ( ' plan delete pvt 004 ' );
    x_processing_code := 'F';
    RETURN;
  END IF;

  print_time ( ' plan delete pvt 005 ' );

  PJI_FM_PLAN_MAINT.DELETE_ALL_PVT ( p_fp_version_ids => l_fp_version_ids);

  print_time ( ' plan delete pvt 006 ' );

  l_event_ids := SYSTEM.pa_num_tbl_type (p_event_id);

  print_time ( ' plan delete pvt 007 ' );

  DELETE_EVENTS (
    p_event_ids        => l_event_ids
  , x_return_status    => x_return_status
  , x_msg_code         => x_processing_code );

  print_time ( ' plan delete pvt 008 ' );

EXCEPTION

  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_DELETE_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;

END;


PROCEDURE PLAN_CREATE (
    p_fp_version_ids   IN          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_code         OUT NOCOPY  VARCHAR2,
    p_fp_src_version_ids  IN   SYSTEM.pa_num_tbl_type :=SYSTEM.pa_num_tbl_type(),
    p_copy_mode             in varchar2 :=NULL) IS
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  print_time ( ' PLAN_CREATE api ' );

  PRINT_PLAN_VERSION_ID_LIST(p_fp_version_ids);
  CHECK_BUDGET_VERSION_EXISTS(p_fp_version_ids);


  IF (p_fp_version_ids.COUNT = 0) THEN
    RETURN;
  END IF;

  CLEANUP_TEMP_TABLES;

  /*
  INSERT INTO pji_event_log_debug
  ( event_type
  , event_id
  , event_object
  , operation_type
  , status
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login)
  VALUES
  ( 'Create'
  , pa_pji_proj_events_log_s.NEXTVAL
  , 'x'
  , 'x'
  , 'x'
  , SYSDATE
  , 1
  , SYSDATE
  , 1
  , 1);
  */

  Pji_Fm_Plan_Maint.CREATE_PRIMARY_PVT(
    p_fp_version_ids    => p_fp_version_ids
  , p_is_primary_rbs    => 'T'
  , p_commit            => 'F'
  , p_fp_src_version_ids    => p_fp_src_version_ids
  , p_Copy_mode=>p_copy_mode);

  -- COMMIT;

EXCEPTION

  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_CREATE'
    , x_return_status  => x_return_status ) ;

    RAISE;

END;


PROCEDURE PLAN_UPDATE (
      p_plan_version_id      IN  NUMBER := NULL,
	x_msg_code             OUT NOCOPY VARCHAR2,
	x_return_status        OUT NOCOPY VARCHAR2 ) IS
  l_processing_code        VARCHAR2(12000);
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_msg_code := Fnd_Api.G_RET_STS_SUCCESS;

  IF NVL(Pa_Task_Pub1.G_CALL_PJI_ROLLUP, 'Y') = 'N' THEN
    RETURN;
  END IF;

  print_time ( 'PLAN_UPDATE begin');

  INSERT_APPLY_PROG_VD;

  /*
  INSERT INTO pji_event_log_debug
  ( event_type
  , event_id
  , event_object
  , operation_type
  , status
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login)
  VALUES
  ( 'Update'
  , pa_pji_proj_events_log_s.NEXTVAL
  , 'x'
  , 'x'
  , 'x'
  , SYSDATE
  , 1
  , SYSDATE
  , 1
  , 1);
  */

  PLAN_UPDATE_PVT(
      p_plan_version_id => p_plan_version_id,
      x_return_status   => x_return_status,
      x_processing_code => x_msg_code);

  print_time ( 'PLAN_UPDATE end');

EXCEPTION

  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_UPDATE'
    , x_return_status  => x_return_status ) ;

    RAISE;

END;


PROCEDURE PLAN_UPDATE_PVT
(   p_plan_version_id      IN  NUMBER := NULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_processing_code      OUT NOCOPY  VARCHAR2 ) IS

  CURSOR GET_MAINT_SMART_SLICE_PARAMS
      IS SELECT DISTINCT rbs_version_id,plan_version_id,struct_ver_id
           FROM pji_fm_extr_plan_lines
	  WHERE plan_version_id = NVL(p_plan_version_id,plan_version_id)
	    AND ROWID IN ( SELECT extr_lines_rowid FROM pji_fp_rmap_fpr_update_t)
        ORDER BY rbs_version_id,struct_ver_id;

  l_num_rows_extr_lines  NUMBER                 := NULL;
  l_fp_version_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_event_ids            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_return_status        VARCHAR2(1);
  l_msg_code             VARCHAR2(100);
  l_num_need_to_lock     NUMBER;
  l_temp                 NUMBER;

  l_update_id            NUMBER;

  p_plan_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  p_rbs_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  p_wbs_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  l_plan_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  l_new_rbs_version_id  number;
  l_new_wbs_version_id number;
  l_new_plan_version_id number;
  l_prev_rbs_version_id  number;
  l_prev_wbs_version_id number;
  l_prev_plan_version_id number;
  l_msg_data varchar2(2000);
  l_msg_count number;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_processing_code := Fnd_Api.G_RET_STS_SUCCESS;

  print_time ( 'PLAN_UPDATE_PVT begin ' );

  CLEANUP_TEMP_TABLES;

  IF (p_plan_version_id IS NULL) THEN
    INSERT INTO pji_fp_rmap_fpr_update_t (EXTR_LINES_ROWID)
    SELECT ROWID FROM pji_fm_extr_plan_lines;
  ELSE
    INSERT INTO pji_fp_rmap_fpr_update_t (EXTR_LINES_ROWID)
    SELECT ROWID FROM pji_fm_extr_plan_lines
    WHERE plan_version_id = p_plan_version_id;
  END IF;

  -------------------------------------------------------------------------
  -- Lock all records.
  -------------------------------------------------------------------------

  print_time ( 'PLAN_UPDATE_PVT 2 ');

  PLAN_EXTR_LINES_LOCK (
    x_return_status    => x_return_status
  , x_msg_code         => x_processing_code);

  IF (x_return_status IN (FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR)) THEN
    RETURN;
  END IF;


  -------------------------------------------------------------------------
  -- Get list of plan versions present in plan extr lines.
  -------------------------------------------------------------------------

  print_time ( 'PLAN_UPDATE_PVT 3 ');

  GET_HDRS_TOLOCK_FOR_UPDATE (
    x_fp_version_ids   => l_fp_version_ids
  , x_return_status    => x_return_status
  , x_msg_code         => x_processing_code   );

  /*
  IF (l_fp_version_ids.COUNT = 0) THEN
    RETURN;
  END IF;
  */

  -------------------------------------------------------------------------
  -- Try to lock these records in wbs header table.
  -- If all records cannot be locked, then return.
  -------------------------------------------------------------------------

  print_time ( 'PLAN_UPDATE_PVT 4 ');

  l_num_need_to_lock := l_fp_version_ids.COUNT;

  WBS_HEADERS_LOCK (
    p_fp_version_ids   => l_fp_version_ids
  , p_context          => 'UPDATE'
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code   );

  /*
  IF (l_fp_version_ids.COUNT <> l_num_need_to_lock) THEN
    RETURN;
  END IF;
  */

  IF (p_plan_version_id IS NOT NULL) THEN
    l_fp_version_ids := SYSTEM.pa_num_tbl_type(p_plan_version_id);
    print_time ( 'PLAN_UPDATE_PVT 4.999 ');
  END IF;

  -------------------------------------------------------------------------
  -- Call update api and delete the processed records.
  -------------------------------------------------------------------------
  print_time ( 'PLAN_UPDATE_PVT 5 ');

  Pji_Fm_Plan_Maint.UPDATE_PRIMARY_PVT (
    p_plan_version_ids => l_fp_version_ids
  , p_commit           => 'F' );

  print_time ( 'PLAN_UPDATE_PfVT 5.11 ');

 /* commenting as the incremental smart slice will be created */
 /*start
  DELETE_SMART_SLICE (
      p_online_flag          => 'Y'
    , x_return_status        => x_return_status ) ;
 end */
/* We get the list of rbs_version,wbs_version and plan_version for which smart slice needs to be created.
   The PJI_FM_EXTR_PLAN_LINES needs to be deleted before calling maintain_smart_slice as there is a commit
   in maintain_smart_slice which nulls out pji_fp_rmap_fpr_update_t */
/* commenting as the incremental smart slice will be created */
 /*start
  OPEN GET_MAINT_SMART_SLICE_PARAMS;

  FETCH GET_MAINT_SMART_SLICE_PARAMS BULK COLLECT INTO p_rbs_version_id_tbl,p_plan_version_id_tbl,p_wbs_version_id_tbl;

  CLOSE GET_MAINT_SMART_SLICE_PARAMS;
  end */
  debug_plan_lines ; /* bug#3993830 */


  DELETE FROM PJI_FM_EXTR_PLAN_LINES
  WHERE 1 = 1
    AND ROWID IN ( SELECT extr_lines_rowid FROM pji_fp_rmap_fpr_update_t)
    AND TXN_CURRENCY_CODE IS NOT NULL
    AND prj_currency_code IS NOT NULL
    AND pfc_currency_code IS NOT NULL;

 /* Smart slice was existing for this project. Recreate the same */
 /* commenting as the incremental smart slice will be created */
 /*start

  IF (g_smart_rows_deleted >0) THEN

  FOR i IN 1..p_rbs_version_id_tbl.COUNT LOOP

        l_new_rbs_version_id  := p_rbs_version_id_tbl(i);
        l_new_wbs_version_id  := p_wbs_version_id_tbl(i);
        l_new_plan_version_id := p_plan_version_id_tbl(i);


		IF (((l_new_rbs_version_id <>l_prev_rbs_version_id) OR (l_new_wbs_version_id <>l_prev_wbs_version_id)) AND i >1) THEN

			  maintain_smart_slice (
			   	  p_rbs_version_id       => l_prev_rbs_version_id,
			   	  p_plan_version_id_tbl  => l_plan_version_id_tbl,
			   	  p_wbs_element_id       => null,
			   	  p_rbs_element_id       => null,
			   	  p_prg_rollup_flag      => 'N',
			   	  p_curr_record_type_id  => null,
			   	  p_calendar_type        =>null,
			          p_wbs_version_id       =>l_prev_wbs_version_id,
                                  p_commit               => 'N',
				  x_msg_count            =>l_msg_count ,
				  x_msg_data             =>l_msg_data,
				  x_return_status        =>l_return_status  );

			   l_plan_version_id_tbl.DELETE;
		END IF;

	l_prev_rbs_version_id := l_new_rbs_version_id;
	l_prev_wbs_version_id := l_new_wbs_version_id;
	l_plan_version_id_tbl.EXTEND;
	l_plan_version_id_tbl(l_plan_version_id_tbl.COUNT) := l_new_plan_version_id;

  END LOOP;
-- The following call takes care of the last set of rbs version and wbs_version
	  maintain_smart_slice (
	   	  p_rbs_version_id       => l_prev_rbs_version_id,
	   	  p_plan_version_id_tbl  => l_plan_version_id_tbl,
	   	  p_wbs_element_id       => null,
	   	  p_rbs_element_id       => null,
	   	  p_prg_rollup_flag      => 'N',
	   	  p_curr_record_type_id  => null,
	   	  p_calendar_type        =>null,
	          p_wbs_version_id       =>l_prev_wbs_version_id,
		  p_commit               => 'N',
		  x_msg_count            =>l_msg_count ,
		  x_msg_data             =>l_msg_data,
		  x_return_status        =>l_return_status );

	  l_plan_version_id_tbl.DELETE;

--PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES;
--Pji_Fm_Plan_Maint_T_Pvt.MERGE_INTO_FP_FACT;

          CLEANUP_TEMP_TABLES;
	  --maintain_smart_slice does not clean data populated by itself

  END IF;
ends*/
/*g_smart_rows_deleted > 0)*/

  print_time ( 'PLAN_UPDATE_PVT end ' );

EXCEPTION
  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_UPDATE_PVT'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


PROCEDURE DELETE_SMART_SLICE (
      p_online_flag          IN  VARCHAR2 := 'Y'
    , x_return_status        OUT NOCOPY VARCHAR2 ) IS
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  IF (p_online_flag NOT IN ('Y', 'N')) THEN
    print_time (' Online flag value ' || p_online_flag || ' is not correct. Returning. ');
    RETURN;
  END IF;

  IF (p_online_flag = 'Y') THEN

/*    DELETE FROM pji_rollup_level_status
    WHERE plan_version_id IN (SELECT plan_version_id FROM pji_fm_extr_plnver3_t);
Bug No .4538102*/

    DELETE FROM pji_rollup_level_status
    WHERE (project_id,plan_version_id,plan_type_code) IN
(SELECT project_id,plan_version_id,plan_type_code FROM pji_fm_extr_plnver3_t);	 /*4771527 */

    IF (SQL%ROWCOUNT > 0) THEN

      pji_pjp_fp_curr_wrap.set_table_stats('PJI','PJI_FM_EXTR_PLNVER3_T', 1 , 1 , 100);

      /*
      FND_STATS.SET_TABLE_STATS(
                  ownname => 'PJI', -- IN VARCHAR2,
                  tabname => 'PJI_FM_EXTR_PLNVER3_T', -- IN VARCHAR2,
                  numrows => 1, -- IN NUMBER,
                  numblks => 1, -- IN NUMBER,
                  avgrlen => 100 --, -- IN NUMBER,
                           );
      */

    	DELETE FROM pji_fp_xbs_accum_f
  	WHERE (project_id,plan_version_id,plan_type_code) IN       /*4771527 */
  	(SELECT project_id, plan_version_id,plan_type_code  FROM pji_fm_extr_plnver3_t)
  	AND (rbs_aggr_level = 'R'
  		 OR (rbs_aggr_level = 'L'
	 	 AND wbs_rollup_flag = 'Y')) ;
         g_smart_rows_deleted := SQL%ROWCOUNT;
    END IF;

  ELSIF (p_online_flag = 'N') THEN

  /*  DELETE FROM pji_rollup_level_status
    WHERE plan_version_id IN (SELECT plan_version_id FROM pji_fm_extr_plnver4);
Bug No. 4538102*/
  DELETE FROM pji_rollup_level_status
    WHERE (project_id,plan_version_id,plan_type_code ) IN
    (SELECT project_id,plan_version_id,plan_type_code FROM pji_fm_extr_plnver4);	  /*4771527 */

    IF (SQL%ROWCOUNT > 0) THEN

      /*
      FND_STATS.SET_TABLE_STATS(
                  ownname => 'PJI', -- IN VARCHAR2,
                  tabname => 'PJI_FM_EXTR_PLNVER4', -- IN VARCHAR2,
                  numrows => 1, -- IN NUMBER,
                  numblks => 1, -- IN NUMBER,
                  avgrlen => 100 --, -- IN NUMBER,
                           );
      */

    	DELETE FROM pji_fp_xbs_accum_f
  	WHERE (project_id,plan_version_id,plan_type_code ) IN
  	(SELECT project_id, plan_version_id,plan_type_code  FROM pji_fm_extr_plnver4)   /*4771527 */
  	AND (rbs_aggr_level = 'R'
  		 OR (rbs_aggr_level = 'L'
	 	 AND wbs_rollup_flag = 'Y')) ;
         g_smart_rows_deleted := SQL%ROWCOUNT;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'DELETE_SMART_SLICE'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


PROCEDURE PLAN_UPDATE_ACT_ETC (
      p_plan_wbs_ver_id      IN  NUMBER
    , p_prev_pub_wbs_ver_id  IN  NUMBER := NULL
      -- p_plan_version_id      IN  NUMBER
    -- , p_prev_pub_version_id IN  NUMBER := NULL
    ,	x_msg_code             OUT NOCOPY VARCHAR2
    , x_return_status        OUT NOCOPY VARCHAR2 ) IS

  l_plan_version_id        NUMBER := NULL;
  l_prev_pub_version_id    NUMBER := NULL;
  l_processing_code        VARCHAR2(12000);
  l_temp    		   NUMBER;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_msg_code := Fnd_Api.G_RET_STS_SUCCESS;

  print_time ( 'PLAN_UPDATE_ACT_ETC begin ');

  print_time ( 'PLAN_UPDATE_ACT_ETC p_plan_wbs_ver_id ' || p_plan_wbs_ver_id || ' p_prev_pub_wbs_ver_id  ' || p_prev_pub_wbs_ver_id );


  IF (p_plan_wbs_ver_id IS NOT NULL) THEN
   BEGIN
    SELECT plan_version_id
    INTO   l_plan_version_id
    FROM   pji_pjp_wbs_header
    WHERE  wbs_version_id = p_plan_wbs_ver_id
      AND  wp_flag = 'Y'; --       AND  plan_version_id > 0;
   EXCEPTION
    WHEN OTHERS THEN
     print_time ( 'PLAN_UPDATE_ACT_ETC.. new plan structure version error p_plan_wbs_ver_id = ' || p_plan_wbs_ver_id || ' ' || SQLERRM );
     RAISE;
   END;
  ELSE
    print_time ( 'PLAN_UPDATE_ACT_ETC new structure version id is null, returning.');
    RETURN;
  END IF;
/* commenting out as this not required any more  for bug#4719016

  IF (p_prev_pub_wbs_ver_id IS NOT NULL) THEN
   BEGIN
    SELECT plan_version_id
    INTO   l_prev_pub_version_id
    FROM   pji_pjp_wbs_header
    WHERE  wbs_version_id = p_prev_pub_wbs_ver_id
      AND  wp_flag = 'Y'; --       AND  plan_version_id > 0;
   EXCEPTION
    WHEN OTHERS THEN
     print_time ( 'PLAN_UPDATE_ACT_ETC.. new plan structure version error p_prev_pub_wbs_ver_id = ' || p_prev_pub_wbs_ver_id || ' ' || SQLERRM );
     RAISE;
   END;
  ELSE
    l_prev_pub_version_id := -1;
    print_time ( 'PLAN_UPDATE_ACT_ETC prev published structure version id is null');
  END IF;
  */

  SELECT COUNT(1)
  INTO l_temp
  FROM pa_budget_versions
  WHERE 1=1
    AND budget_version_id IN (l_plan_version_id , l_prev_pub_version_id );


  IF (l_temp = 0) THEN
    print_time ( 'PLAN_UPDATE_PVT_ACT_ETC invalid plan version ids.. l_temp =  ' || l_temp || '. Returning..' );
    RETURN;
  END IF;

  /*
  INSERT INTO pji_event_log_debug
  ( event_type
  , event_id
  , event_object
  , operation_type
  , status
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login)
  VALUES
  ( 'Update ACT ETC'
  , pa_pji_proj_events_log_s.NEXTVAL
  , 'x'
  , 'x'
  , 'x'
  , SYSDATE
  , 1
  , SYSDATE
  , 1
  , 1);
  */

  PLAN_UPDATE_PVT_ACT_ETC(
      p_plan_version_id => l_plan_version_id,
      p_prev_pub_version_id => l_prev_pub_version_id,
      x_return_status   => x_return_status,
      x_processing_code => x_msg_code);

  print_time ( 'PLAN_UPDATE_ACT_ETC end');

EXCEPTION

  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_UPDATE_ACT_ETC'
    , x_return_status  => x_return_status ) ;

    RAISE;

END;


PROCEDURE PLAN_UPDATE_PVT_ACT_ETC (
      p_plan_version_id      IN  NUMBER
    , p_prev_pub_version_id  IN  NUMBER := NULL
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_processing_code     OUT NOCOPY VARCHAR2) IS

  l_num_rows_extr_lines  NUMBER                 := NULL;
  l_fp_version_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_event_ids            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_return_status        VARCHAR2(1);
  l_msg_code             VARCHAR2(100);
  l_num_need_to_lock     NUMBER;
  l_temp                 NUMBER;

  l_update_id            NUMBER;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_processing_code := Fnd_Api.G_RET_STS_SUCCESS;

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC begin ' );

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC p_plan_version_id ' || p_plan_version_id || ' p_prev_pub_version_id ' || p_prev_pub_version_id );

  CLEANUP_TEMP_TABLES;

  IF (p_plan_version_id IS NULL) THEN
    print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 1 plan version id is null.. returning ' );
    RETURN;
  ELSE
    INSERT INTO pji_fp_rmap_fpr_update_t (EXTR_LINES_ROWID)
    SELECT ROWID FROM pji_fm_extr_plan_lines
    WHERE plan_version_id = p_plan_version_id;
  END IF;

  SELECT COUNT(1)
  INTO l_temp
  FROM pji_fm_extr_plan_lines
 WHERE   ROWNUM=1; /*Added for bug 3928020*/
  -------------------------------------------------------------------------
  -- Process records only if # of lines in plan lines table > threshold #.
  -- They will be processed in the next call to plan update api if the above
  --   condition is met.
  -------------------------------------------------------------------------
  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 1 number of rows in plan lines is .. ' || l_temp);

  SELECT COUNT(1)
  INTO   l_num_rows_extr_lines
  FROM   pji_fp_rmap_fpr_update_t
 WHERE   ROWNUM=1; /*Added for bug 3928020*/

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 1.5 number of rows in rowid table is.. ' || l_num_rows_extr_lines );

IF (l_temp > 0) THEN

  -------------------------------------------------------------------------
  -- Lock all records.
  -------------------------------------------------------------------------

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 2 ');

  PLAN_EXTR_LINES_LOCK (
    x_return_status    => l_return_status
  , x_msg_code         => l_msg_code);

  IF (l_msg_code = 'F') THEN
    RETURN;
  END IF;


  -------------------------------------------------------------------------
  -- Get list of plan versions present in plan extr lines.
  -------------------------------------------------------------------------

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 3 ');

  GET_HDRS_TOLOCK_FOR_UPDATE (
    x_fp_version_ids   => l_fp_version_ids
  , x_return_status    => x_return_status
  , x_msg_code         => x_processing_code   );

  IF (l_fp_version_ids.COUNT = 0) THEN
    RETURN;
  END IF;


  -------------------------------------------------------------------------
  -- Try to lock these records in wbs header table.
  -- If all records cannot be locked, then return.
  -------------------------------------------------------------------------

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 4 ');

  l_num_need_to_lock := l_fp_version_ids.COUNT;

  WBS_HEADERS_LOCK (
    p_fp_version_ids   => l_fp_version_ids
  , p_context          => 'UPDATE' -- 'PUBLISH'
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code   );

  IF (l_fp_version_ids.COUNT <> l_num_need_to_lock) THEN
    print_time ( ' PLAN_UPDATE_PVT_ACT_ETC .. Could not lock all headers.. Exitting..');
    RETURN;
  END IF;

ELSE
    print_time ( ' PLAN_UPDATE_PVT_ACT_ETC .. no lines, so no lines/headers to lock.');
END IF;


  -------------------------------------------------------------------------
  -- Call update api and delete the processed records.
  -------------------------------------------------------------------------
  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC  5 ');

  Pji_Fm_Plan_Maint.UPDATE_PRIMARY_PVT_ACT_ETC (
    p_plan_version_id     => p_plan_version_id
  , p_prev_pub_version_id => p_prev_pub_version_id
  , x_return_status       => x_return_status
  , x_processing_code     => x_processing_code);

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC 5.11 ');

  debug_plan_lines ; /* bug#3993830 */

  DELETE FROM PJI_FM_EXTR_PLAN_LINES
  WHERE 1 = 1
    AND ROWID IN ( SELECT extr_lines_rowid FROM pji_fp_rmap_fpr_update_t)
    AND TXN_CURRENCY_CODE IS NOT NULL
    AND prj_currency_code IS NOT NULL
    AND pfc_currency_code IS NOT NULL;

  print_time ( 'PLAN_UPDATE_PVT_ACT_ETC end ' );

EXCEPTION
  WHEN OTHERS THEN

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_UPDATE_PVT_ACT_ETC'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


PROCEDURE FINPLAN_COPY (
    p_source_fp_version_ids   IN SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type(),
    p_dest_fp_version_ids     IN SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type(),
    p_source_fp_version_types IN SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type(),
    p_dest_fp_version_types   IN SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type(),
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_code                OUT NOCOPY  VARCHAR2 ) IS

  l_fp_version_ids        SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_s_wking_fp_version_ids  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type(); -- s == Source
  l_s_bslnd_fp_version_ids  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type(); -- d == Desination
  l_d_wking_fp_version_ids  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_d_bslnd_fp_version_ids  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_num_wking_fp_ver_ids  NUMBER := NULL;
  l_return_status         VARCHAR2(1);
  l_processing_code       VARCHAR2(100);
  l_msg_code              VARCHAR2(100);
  l_s_fp_version_ids    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_d_fp_version_ids    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_event_rec       pa_pji_proj_events_log%ROWTYPE;

  l_num_src_fp_ver_ids     NUMBER := NULL;
  l_num_dest_fp_ver_ids    NUMBER := NULL;
  l_num_src_fp_ver_types   NUMBER := NULL;
  l_num_dest_fp_ver_types  NUMBER := NULL;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  print_time ( ' plan copy api ' );
  print_time ( ' plan copy api .. source plan version ids ' );
  PRINT_PLAN_VERSION_ID_LIST(p_source_fp_version_ids);
  print_time ( ' plan copy api .. dest plan version ids ' );
  PRINT_PLAN_VERSION_ID_LIST(p_dest_fp_version_ids);
  print_time ( ' plan copy api .. source plan version types ' );
  PRINT_PLAN_VERSION_TYPE_LIST(p_source_fp_version_types);
  print_time ( ' plan copy api .. source plan version types ' );
  PRINT_PLAN_VERSION_TYPE_LIST(p_source_fp_version_types);
  print_time ( ' plan copy api .. checking source plan version ids are valid.. ' );
  CHECK_BUDGET_VERSION_EXISTS(p_source_fp_version_ids);
  print_time ( ' plan copy api .. checking dest plan version ids are valid.. ' );


  CHECK_BUDGET_VERSION_EXISTS(p_dest_fp_version_ids);

  print_time ( ' plan copy api .. 001 ' );

  --
  -- Note: As per Venkatesh's email, only cases to support are: B-W, W-W (create working).
  --       W-B will be done in PLAN_BASELINE api. B-B is not valid biz scenario.
  --

  l_num_src_fp_ver_ids     := p_source_fp_version_ids.COUNT;
  l_num_dest_fp_ver_ids    := p_dest_fp_version_ids.COUNT;
  l_num_src_fp_ver_types   := p_source_fp_version_types.COUNT;
  l_num_dest_fp_ver_types  := p_dest_fp_version_types.COUNT;

  IF (  (l_num_src_fp_ver_ids IS NULL )
     OR (l_num_src_fp_ver_ids = 0 )
     OR (l_num_src_fp_ver_ids <> l_num_dest_fp_ver_ids )
     OR (l_num_src_fp_ver_ids <> l_num_src_fp_ver_types)
     OR (l_num_src_fp_ver_ids <> l_num_dest_fp_ver_types ) ) THEN
    RETURN;
  END IF;

  print_time ( ' plan copy api .. 002 ' );

  FOR i IN p_source_fp_version_ids.FIRST..p_source_fp_version_ids.LAST LOOP

    print_time ( ' plan copy api .. 003 ' );

    IF (p_source_fp_version_types(i) = 'W') THEN

      print_time ( ' plan copy api .. 004 ' );

      --
      -- Create event.
      --
      l_event_rec.event_type     := 'PLAN_COPY';
      l_event_rec.event_object   := p_dest_fp_version_ids(i);

      l_event_rec.operation_type := '1';
      l_event_rec.status         := 'X';
      l_event_rec.attribute1     := p_source_fp_version_ids(i);
      -- l_event_rec.attribute2     := p_source_fp_version_types(i); -- W/B

      CREATE_EVENT(l_event_rec);

      print_time ( ' plan copy api .. 005 ' );

      --
      -- Call the pvt api to Copy the plan.
      --
      PLAN_COPY_PVT (
        p_event_id        => l_event_rec.event_id
      , x_processing_code => l_processing_code
      , x_return_status   => x_return_status );

      print_time ( ' plan copy api .. 006 ' );

    ELSIF (p_source_fp_version_types(i) = 'B') THEN

      print_time ( ' plan copy api .. 007 ' );

      --
      -- Copy the plan without creating events.
      --

      l_s_fp_version_ids := SYSTEM.pa_num_tbl_type (p_source_fp_version_ids(i) );
      l_d_fp_version_ids := SYSTEM.pa_num_tbl_type (p_dest_fp_version_ids(i) );

      print_time ( ' plan copy api .. 008 ' );

      Pji_Fm_Plan_Maint_T_Pvt.COPY_PRIMARY
      (
        p_source_fp_version_ids    =>   l_s_fp_version_ids
      , p_dest_fp_version_ids      =>   l_d_fp_version_ids
      , p_commit                   =>   'F'
      );

      print_time ( ' plan copy api .. 009 ' );

      COPY_PJI_SUMMRZD_FLAG (
        p_source_fp_version_ids   =>   l_s_fp_version_ids
      , p_dest_fp_version_ids     =>   l_d_fp_version_ids);

      print_time ( ' plan copy api .. 010 ' );

    END IF;

    print_time ( ' plan copy api .. 011 ' );

  END LOOP;

  print_time ( ' plan copy api .. 012 ' );

  --COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_COPY'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


PROCEDURE PLAN_COPY_PVT (
    p_event_id        IN NUMBER
  , x_return_status   OUT NOCOPY  VARCHAR2
  , x_processing_code OUT NOCOPY  VARCHAR2) IS

  l_event_ids             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_s_plan_version_id   NUMBER := NULL;
  l_d_plan_version_id   NUMBER := NULL;
  l_s_fp_version_ids    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_d_fp_version_ids    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_working_or_baselined  VARCHAR2(30) := 'N';
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_processing_code := Fnd_Api.G_RET_STS_SUCCESS;

  print_time ( ' plan copy PVT api .. 001 ' );

  SELECT attribute1, event_object, attribute2
  INTO   l_s_plan_version_id, l_d_plan_version_id, l_working_or_baselined
  FROM   PA_PJI_PROJ_EVENTS_LOG
  WHERE  event_id = p_event_id;

  l_s_fp_version_ids := SYSTEM.pa_num_tbl_type (l_s_plan_version_id);
  l_d_fp_version_ids := SYSTEM.pa_num_tbl_type (l_d_plan_version_id);

  print_time ( ' plan copy PVT api .. 002 ' );

  WBS_HEADERS_LOCK (
    p_fp_version_ids   => l_s_fp_version_ids
  , p_context          => 'COPY'
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code   );

  print_time ( ' plan copy PVT api .. 003 ' );

  IF (l_s_fp_version_ids.COUNT < 1) THEN
    x_processing_code := 'F';
    print_time ( ' plan copy PVT api .. 004 ' );
    RETURN;
  END IF;

  print_time ( ' plan copy PVT api .. 005 ' );

  Pji_Fm_Plan_Maint_T_Pvt.COPY_PRIMARY
  (
    p_source_fp_version_ids    =>   l_s_fp_version_ids
  , p_dest_fp_version_ids      =>   l_d_fp_version_ids
  , p_commit                   =>   'F'
  );

  print_time ( ' plan copy PVT api .. 006 ' );

  COPY_PJI_SUMMRZD_FLAG (
    p_source_fp_version_ids   =>   l_s_fp_version_ids
  , p_dest_fp_version_ids     =>   l_d_fp_version_ids);

  print_time ( ' plan copy PVT api .. 007 ' );

  --
  -- Delete from events table.
  --
  l_event_ids := SYSTEM.pa_num_tbl_type (p_event_id);

  DELETE_EVENTS (
    p_event_ids        => l_event_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code );

  print_time ( ' plan copy PVT api .. 008 ' );

  x_processing_code := l_return_status;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_COPY_PVT'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


PROCEDURE PLAN_BASELINE	(
    p_baseline_version_id IN   NUMBER,
    p_new_version_id      IN   NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_code            OUT NOCOPY  VARCHAR2 ) IS

  l_fp_version_ids  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_event_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);
  l_event_id        NUMBER;
  l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  l_project_id          NUMBER := NULL;
  l_curr_bl_ver_id      NUMBER := NULL;
  l_plan_type_id        NUMBER := NULL;
  l_new_project_type    pa_projects_all.project_type%TYPE;
  l_new_plan_type_code  pa_budget_versions.budget_type_code%TYPE;
  l_plan_type_code      CHAR(1);
  l_processing_code       VARCHAR2(12000);
  l_wp_version_flag      VARCHAR2(1) := NULL;

  l_s_fp_version_ids        SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_d_fp_version_ids        SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


  print_time ( ' PLAN_BASELINE api begin ' );
  print_time ( ' baseline version id is .. ' || p_baseline_version_id );
  print_time ( ' new version id is .. ' || p_new_version_id );

  -------------------------------------------------------------------------
  -- Get plan type id and project id for the newly baselined version.
  -------------------------------------------------------------------------
  BEGIN
    SELECT bv1.project_id, bv1.fin_plan_type_id, bv1.wp_version_flag,
     DECODE(bv1.version_type, 'COST' , 'C' , 'REVENUE' , 'R' , 'A')
    INTO   l_project_id, l_plan_type_id, l_wp_version_flag,l_plan_type_code
    FROM   pa_budget_versions  bv1
    WHERE  bv1.budget_version_id = p_baseline_version_id;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  print_time ( ' PLAN_BASELINE api 001 ' ||l_project_id || ' ' || l_plan_type_id || ' ' || l_wp_version_flag );

  -------------------------------------------------------------------------
  -- Only financial plans are baselined.
  -------------------------------------------------------------------------
  IF (l_wp_version_flag = 'Y') THEN
    RETURN;
  END IF;

  -------------------------------------------------------------------------
  -- Get the current baselined plan version for this project for this line type.
  -------------------------------------------------------------------------
  BEGIN
    SELECT plan_version_id
    INTO   l_curr_bl_ver_id
    FROM   PJI_PJP_WBS_HEADER wbs_hdr
    WHERE  1 = 1
	AND  project_id = l_project_id
      AND  plan_type_id = l_plan_type_id
      AND  plan_type_code = l_plan_type_code
      AND  cb_flag = 'Y'
      AND  plan_version_id > 0 ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      print_time ( ' PLAN_BASELINE api 001.11 : Currently, there are no baslined plans for this plan type.');
    WHEN OTHERS THEN
      RAISE;
  END;

  print_time ( ' PLAN_BASELINE api 001.2 ' || l_curr_bl_ver_id );

  ------------------------------------------------------------------------------
  -- Create a working plan version using the newly baselined plan.
  -- Copy pji summarized flag from source to destination plan version ids.
  ------------------------------------------------------------------------------

  print_time ( ' PLAN_BASELINE api 001.1 ' || p_baseline_version_id || ' ' || p_new_version_id );

  l_s_fp_version_ids := SYSTEM.pa_num_tbl_type (p_baseline_version_id );
  l_d_fp_version_ids := SYSTEM.pa_num_tbl_type (p_new_version_id);

  COPY_PJI_SUMMRZD_FLAG (
    p_source_fp_version_ids   =>   l_s_fp_version_ids
  , p_dest_fp_version_ids     =>   l_d_fp_version_ids);


  print_time ( ' PLAN_BASELINE api 001.22 successfully copied pji summarized flag. ' );


  -------------------------------------------------------------------------
  -- Create an event..
  -------------------------------------------------------------------------
  l_event_rec.event_type := 'PLAN_BASELINE';
  l_event_rec.event_object := p_new_version_id;
  l_event_rec.operation_type := 'U';
  l_event_rec.status := 'X';
  l_event_rec.attribute1 := l_project_id;
  l_event_rec.attribute2 := l_plan_type_id;
  l_event_rec.attribute3 := l_curr_bl_ver_id;
  l_event_rec.attribute4 := l_plan_type_code;

  CREATE_EVENT(l_event_rec);


  -------------------------------------------------------------------------
  -- Call the private api that actually handles the baseline process.
  -------------------------------------------------------------------------

  PLAN_BASELINE_PVT (
    p_event_id         => l_event_rec.event_id
  , x_processing_code  => l_processing_code
  , x_return_status   => x_return_status );


  print_time ( ' PLAN_BASELINE api 002 End ' );

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_BASELINE'
    , x_return_status => x_return_status ) ;

    RAISE;
END;



----------------------------------------------------------------------------------------
--
-- Mark plan as baselined.
-- In the reporting lines fact, baslined slice corresponds to plan version id -3.
-- There is a unique baselined plan version for a given combination of project and plan type ids.
--
----------------------------------------------------------------------------------------
PROCEDURE PLAN_BASELINE_PVT (
    p_event_id           IN  NUMBER
  , x_return_status      OUT NOCOPY  VARCHAR2
  , x_processing_code    OUT NOCOPY  VARCHAR2) IS

    l_project_id              NUMBER;
    l_count                   NUMBER;
    l_working_version_id      NUMBER;
    l_baseline_version_id     NUMBER;
    l_old_baseline_version_id NUMBER;
    l_new_version_id          NUMBER;
    l_plan_type_id            NUMBER;
    l_fp_version_ids          SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
    l_source_fp_version_ids   SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
    l_dest_fp_version_ids     SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
    l_event_ids               SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_return_status           VARCHAR2(12000);
    l_msg_code                VARCHAR2(100);
    l_baselined_exists        NUMBER;
    l_new_working_ver_id      NUMBER;
    l_processing_code         VARCHAR2(1);

    l_s_fp_version_ids        SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
    l_d_fp_version_ids        SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_plan_type_code char(1);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_processing_code := Fnd_Api.G_RET_STS_SUCCESS;

  print_time ( ' PLAN_BASELINE_PVT api 001 Begin event id is.. ' || p_event_id );

  -----------------------------------------------------------------------------------
  -- Get event info.
  -----------------------------------------------------------------------------------

  SELECT attribute1
       , event_object
       , attribute3
       , attribute2
       , attribute4
  INTO   l_project_id
       , l_new_version_id
       , l_old_baseline_version_id
       , l_plan_type_id
       , l_plan_type_code     /*4771527*/
  FROM   PA_PJI_PROJ_EVENTS_LOG
  WHERE  event_id = p_event_id;


  l_dest_fp_version_ids := SYSTEM.pa_num_tbl_type (l_new_version_id);


  ----------------------------------------------------------------------------------------
  -- Insert the missing -3, -4 header records and lock the appropriate versions.
  ----------------------------------------------------------------------------------------

  WBS_HEADERS_LOCK( -- _BASELINE (
    p_fp_version_ids   => l_dest_fp_version_ids -- l_new_version_id
  , p_context          => 'BASELINE'
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code   );

  x_processing_code := l_msg_code;

  IF (l_dest_fp_version_ids.COUNT <1) THEN
    print_time(' Baseline flow. # hdrs locked is not valid, returning. # = ' || l_dest_fp_version_ids.COUNT );
    RETURN;
  END IF;

  ----------------------------------------------------------------------------------------
  -- Update the WBS header table with the correct baselined version.
  ----------------------------------------------------------------------------------------

  UPDATE pji_pjp_wbs_header
  SET    cb_flag = DECODE( plan_version_id
                         , l_old_baseline_version_id, 'N'
                         , l_new_version_id, 'Y'
                         , -3, 'Y' )
       , LAST_UPDATE_DATE  = l_last_update_date
       , LAST_UPDATED_BY   = l_last_updated_by
       , LAST_UPDATE_LOGIN = l_last_update_login
  WHERE  plan_version_id IN (l_old_baseline_version_id
                           , l_new_version_id
                           , -3)
     AND project_id = l_project_id
     AND plan_type_id = l_plan_type_id
     AND plan_type_code = l_plan_type_code;      /*4771527 */

  print_time ( ' PLAN_BASELINE_PVT api 004: marked the latest baselined version in header table. ' );


  ----------------------------------------------------------------------------------------
  -- Set the online context.
  ----------------------------------------------------------------------------------------

  Pji_Pjp_Sum_Rollup.set_online_context (
    p_event_id              => p_event_id,
    p_project_id            => l_project_id,
    p_plan_type_id          => l_plan_type_id,
    p_old_baselined_version => l_old_baseline_version_id,
    p_new_baselined_version => l_new_version_id ,
    p_old_original_version  => NULL,
    p_new_original_version  => NULL,
    p_old_struct_version    => NULL,
    p_new_struct_version    => NULL);


  ----------------------------------------------------------------------------------------
  -- Assume primary slice exists.
  -- Create primary slice for reporting RBSes and secondary slice.
  ----------------------------------------------------------------------------------------

  Pji_Fm_Plan_Maint.CREATE_SECONDARY_T_PVT(
    p_fp_version_ids    => l_dest_fp_version_ids
  , p_commit            => 'N');


  print_time ( ' PLAN_BASELINE_PVT api 006: Created secondary slice for all RBSes.' );


  ------------------------------------------------------------------------------
  -- Delete event.
  ------------------------------------------------------------------------------

  l_event_ids := SYSTEM.pa_num_tbl_type (p_event_id);

  DELETE_EVENTS (
    p_event_ids        => l_event_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code );

  print_time ( ' PLAN_BASELINE_PVT api 008: Deleted events. ' );

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_BASELINE_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE PLAN_ORIGINAL	(
    p_original_version_id IN   NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_code            OUT NOCOPY  VARCHAR2 ) IS

  l_fp_version_ids  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_event_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_wp_flag         VARCHAR2(1);
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);
  l_event_id        NUMBER;
  l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  l_project_id          NUMBER := NULL;
  l_curr_or_ver_id      NUMBER := NULL;
  l_plan_type_id        NUMBER := NULL;
  l_plan_type_code      char(1);
  l_new_project_type    pa_projects_all.project_type%TYPE;
  l_new_plan_type_code  pa_budget_versions.budget_type_code%TYPE;
  l_processing_code     VARCHAR2(1500) := NULL;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  print_time ( ' PLAN_ORIGINAL api ' );
  print_time ( ' original version id is .. ' || p_original_version_id );


  ---------------------------------------------------------
  -- Mark as original only financial plans.
  ---------------------------------------------------------

  BEGIN
    SELECT wp_flag
    INTO   l_wp_flag
    FROM   pji_pjp_wbs_header
    WHERE  plan_version_id = p_original_version_id;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  IF ( l_wp_flag = 'Y' ) THEN
    RETURN;
  END IF;


  ---------------------------------------------------------------------------
  -- Get plan type id and project id for the version tb marked original.
  ---------------------------------------------------------------------------

  BEGIN

    SELECT bv1.project_id, bv1.fin_plan_type_id,
     DECODE(bv1.version_type, 'COST' , 'C' , 'REVENUE' , 'R' , 'A')
    INTO   l_project_id, l_plan_type_id, l_plan_type_code
    FROM   pa_budget_versions  bv1
    WHERE  bv1.budget_version_id = p_original_version_id;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --
  -- Get plan version id for the previous original version.
  --
  BEGIN
    SELECT plan_version_id
    INTO   l_curr_or_ver_id
    FROM   PJI_PJP_WBS_HEADER wbs_hdr
    WHERE  1 = 1
	AND  project_id = l_project_id
      AND  plan_type_id = l_plan_type_id
      AND  co_flag = 'Y'
      AND  plan_version_id > 0
      AND  plan_type_code = l_plan_type_code  ;  /* 4471527 */
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      print_time('Currently, there is no original baseline version so far for this plan type.');
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;


  --
  -- Create an event..
  --
  l_event_rec.event_type := 'PLAN_ORIGINAL';
  l_event_rec.event_object := p_original_version_id;
  l_event_rec.operation_type := 'U';
  l_event_rec.status := 'X';
  l_event_rec.attribute1 := l_project_id;
  l_event_rec.attribute2 := l_plan_type_id;
  l_event_rec.attribute3 := l_curr_or_ver_id;
  l_event_rec.attribute4 := l_plan_type_code;   /*  4771527 */

  CREATE_EVENT(l_event_rec);


  --
  -- Call the private api that actually handles the mark original process.
  --
  PLAN_ORIGINAL_PVT(
    p_event_id         => l_event_rec.event_id
  , x_processing_code  => l_processing_code
  , x_return_status    => x_return_status );

  --COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_ORIGINAL'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE PLAN_ORIGINAL_PVT (
    p_event_id           IN  NUMBER
  , x_return_status      OUT NOCOPY  VARCHAR2
  , x_processing_code    OUT NOCOPY  VARCHAR2) IS

  l_fp_version_ids          SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_source_fp_version_ids   SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_dest_fp_version_ids     SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_event_ids               SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_wp_flag         VARCHAR2(1);
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);
  l_event_id        NUMBER;
  l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  l_project_id          NUMBER := NULL;
  l_old_orig_ver_id     NUMBER := NULL;
  l_new_orig_ver_id     NUMBER := NULL;
  l_plan_type_id        NUMBER := NULL;
  l_new_project_type    pa_projects_all.project_type%TYPE;
  l_new_plan_type_code  pa_budget_versions.budget_type_code%TYPE;
  l_original_exists     NUMBER := NULL;
  l_processing_code     VARCHAR2(1) := NULL;

  l_last_update_date     date   := SYSDATE;
  l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
  l_plan_type_code char(1) ;    /*4771527 */

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_processing_code := Fnd_Api.G_RET_STS_SUCCESS;


  -----------------------------------------------------------------------------------
  -- Get event info.
  -----------------------------------------------------------------------------------

  SELECT attribute1, attribute3, event_object, attribute2,attribute4
  INTO   l_project_id, l_old_orig_ver_id, l_new_orig_ver_id, l_plan_type_id,l_plan_type_code     /*4771527 */
  FROM   PA_PJI_PROJ_EVENTS_LOG
  WHERE  event_id = p_event_id;


  ----------------------------------------------------------------------------------------
  -- First, need to lock all relevant plan versions, if this is not possible, return.
  ----------------------------------------------------------------------------------------

  l_fp_version_ids := SYSTEM.pa_num_tbl_type (l_new_orig_ver_id);

  /*
  CHECK_BUDGET_VERSION_EXISTS(l_fp_version_ids);

  WBS_HEADERS_LOCK (
    p_fp_version_ids   => l_fp_version_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code ) ;

  x_processing_code := l_msg_code;

  IF (l_fp_version_ids.COUNT <1) THEN
    RETURN;
  END IF;
  */

  WBS_HEADERS_LOCK( -- _BASELINE (
    p_fp_version_ids   => l_fp_version_ids
  , p_context          => 'ORIGINAL'
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code   );

  x_processing_code := l_msg_code;

  IF (l_fp_version_ids.COUNT <1) THEN
    print_time(' Original flow. # hdrs locked is not valid, returning. # = ' || l_fp_version_ids.COUNT );
    RETURN;
  END IF;


  -----------------------------------------------------------------------------------
  -- Update header table.
  -----------------------------------------------------------------------------------

  UPDATE pji_pjp_wbs_header
  SET    co_flag = DECODE(plan_version_id
                        , l_old_orig_ver_id, 'N'
                        , l_new_orig_ver_id, 'Y'
                        , -4, 'Y')
       , LAST_UPDATE_DATE  = l_last_update_date
       , LAST_UPDATED_BY   = l_last_updated_by
       , LAST_UPDATE_LOGIN = l_last_update_login
  WHERE  plan_version_id IN (l_old_orig_ver_id, l_new_orig_ver_id, -4)
    AND  project_id = l_project_id
    AND  plan_type_id = l_plan_type_id
    AND  plan_type_code = l_plan_type_code ;   /* 4771527 */

  print_time('Marked the cb and co flags in WBS header correctly.');


  -----------------------------------------------------------------------------------
  -- Set online context.
  -----------------------------------------------------------------------------------

  Pji_Pjp_Sum_Rollup.set_online_context (
    p_event_id              => p_event_id,
    p_project_id            => l_project_id,
    p_plan_type_id          => NULL, -- l_plan_type_id
    p_old_baselined_version => NULL,
    p_new_baselined_version => NULL ,
    p_old_original_version  => l_old_orig_ver_id,
    p_new_original_version  => l_new_orig_ver_id,
    p_old_struct_version    => NULL,
    p_new_struct_version    => NULL);

  Pji_Fm_Plan_Maint_T_Pvt.CLEANUP_INTERIM_TABLES; -- Clean up interim tables.
  print_time(' Mark original private: Cleaned up interim tables. ');

-- Populated ver3 just to get the level info in rollup_fpr_wbs Bug 	5528058
  PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(l_fp_version_ids, 'PRI');
--  PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(l_fp_version_ids, 'SECRBS');
  print_time(' Populated ver3. ');

  PJI_FM_PLAN_MAINT_T_PVT.CREATE_WBSRLP;
  print_time(' Mark original private: Created WBS rollups. ');

  PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES;

  PJI_FM_PLAN_MAINT_T_PVT.UPDATE_WBS_HDR;
  print_time('Updated the WBS header table with min max txn dates.');

  PJI_FM_PLAN_MAINT_T_PVT.MERGE_INTO_FP_FACT;
  print_time(' Mark original private: Merged into fact. ');


  ------------------------------------------
  -- Delete from events table.
  ------------------------------------------

  l_event_ids := SYSTEM.pa_num_tbl_type (p_event_id);

  DELETE_EVENTS (
    p_event_ids        => l_event_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code );

  Pji_Fm_Plan_Maint_T_Pvt.CLEANUP_INTERIM_TABLES;
  print_time(' Mark original private: Cleaned up interim tables. ');

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PLAN_ORIGINAL_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE PRG_CHANGE (
    p_prg_grp_id       IN   NUMBER,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_code         OUT NOCOPY  VARCHAR2 ) IS

  l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


  --
  -- Create an event..
  --
  l_event_rec.event_type := 'PRG_CHANGE';
  l_event_rec.event_object := p_prg_grp_id;
  l_event_rec.operation_type := 'I';
  l_event_rec.status := 'X';

  create_event(l_event_rec);

  --COMMIT;

  -- Summarization process will pick up this event.

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PRG_CHANGE'
    , x_return_status => x_return_status ) ;

    RAISE;
END;



PROCEDURE RBS_PUSH (
    p_old_rbs_version_id     IN NUMBER DEFAULT NULL
  , p_new_rbs_version_id     IN NUMBER
  , p_project_id             IN NUMBER DEFAULT NULL
  , p_program_flag           IN VARCHAR2 DEFAULT 'N'
  , x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_code               OUT NOCOPY  VARCHAR2 ) IS

  l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  l_fp_version_ids   SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_event_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);
  l_template_flag   VARCHAR2(1);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


  l_event_rec.event_object := p_new_rbs_version_id;
  l_event_rec.operation_type := 'I';
  l_event_rec.status := 'X';


  IF ( (p_program_flag = 'N') AND (p_old_rbs_version_id IS NOT NULL) ) THEN -- RBS version is frozen.

    l_event_rec.event_type := 'RBS_PUSH';
    l_event_rec.attribute2 := p_old_rbs_version_id;

    create_event(l_event_rec);

    --
    -- Launch conc program. Todo..!!
    --

  ELSIF (    (p_program_flag = 'N')
         AND (p_project_id IS NOT NULL)  ) THEN -- RBS is associated with a project.

    select TEMPLATE_FLAG
    into   l_template_flag
    from   PA_PROJECTS_ALL
    where  PROJECT_ID = p_project_id;
    if (l_template_flag = 'Y') then
      return;
    end if;

    l_event_rec.event_type := 'RBS_ASSOC';
    l_event_rec.attribute1 := p_project_id;

    create_event(l_event_rec);

    --
    -- Will be picked up by summarization program.
    --

  ELSIF (    (p_program_flag = 'Y')
         AND (p_project_id IS NOT NULL)  ) THEN  -- RBS is associated with a program.

    select TEMPLATE_FLAG
    into   l_template_flag
    from   PA_PROJECTS_ALL
    where  PROJECT_ID = p_project_id;
    if (l_template_flag = 'Y') then
      return;
    end if;

    l_event_rec.event_type := 'RBS_PRG';
    l_event_rec.attribute1 := p_project_id;

    create_event(l_event_rec);

    --
    -- Will be picked up by summarization program.
    --

  ELSE
    RETURN;
  END IF;


  --COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'RBS_PUSH'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE RBS_DELETE (
    p_rbs_version_id         IN NUMBER
  , p_project_id             IN NUMBER
  , x_return_status          OUT NOCOPY  VARCHAR2
  , x_msg_code               OUT NOCOPY  VARCHAR2 )  IS

  l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  l_fp_version_ids   SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_event_ids       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_return_status   VARCHAR2(1);
  l_msg_code        VARCHAR2(100);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  l_event_rec.event_type := 'RBS_DELETE';
  l_event_rec.event_object := p_rbs_version_id;
  l_event_rec.operation_type := 'D';
  l_event_rec.status := 'X';

  create_event(l_event_rec);

  /* This code goes in summarization program...
  WBS_HEADERS_LOCK (
    p_fp_version_ids   => l_fp_version_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code   );

  IF (l_fp_version_ids.COUNT = 0) THEN RETURN; END IF;

  GET_EVENT_IDS (
    p_fp_version_ids   => l_fp_version_ids
  , p_operation_type   => 'D'
  , x_event_ids        => l_event_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code );

  PJI_FM_PLAN_MAINT.FINPLAN_DELETE(
    p_fp_version_ids   => l_fp_version_ids
  , p_commit           => 'F' );

  DELETE_EVENTS (
    p_event_ids        => l_event_ids
  , x_return_status    => l_return_status
  , x_msg_code         => l_msg_code );
  */

  --COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'RBS_DELETE'
    , x_return_status => x_return_status ) ;

    RAISE;
END;



PROCEDURE CREATE_EVENT( p_event_rec IN OUT NOCOPY  pa_pji_proj_events_log%ROWTYPE) IS
  -- l_event_rec       pa_pji_proj_events_log%ROWTYPE;
  event_already_exists VARCHAR2(1) := 'N'; -- Added for Bug#6145813 by vvjoshi
  l_rbs_header_id PA_RBS_VERSIONS_B.rbs_header_id%TYPE; -- Added for Bug#6145813 by vvjoshi
  l_return_status   VARCHAR2(1);
BEGIN

  -- l_event_rec                   := p_event_rec;
  p_event_rec.creation_date     := SYSDATE;
  p_event_rec.last_update_date  := SYSDATE;
  p_event_rec.last_updated_by   := Fnd_Global.USER_ID;
  p_event_rec.created_by        := Fnd_Global.USER_ID;
  p_event_rec.last_update_login := Fnd_Global.LOGIN_ID;

  IF (p_event_rec.event_id IS NULL) THEN
    SELECT pa_pji_proj_events_log_s.NEXTVAL
    INTO p_event_rec.event_id
    FROM DUAL;
  END IF;

/* Added for Bug#6145813 by vvjoshi - START*/

IF (p_event_rec.event_type = 'RBS_PUSH') THEN

begin
select 'Y'
into event_already_exists
from (select attribute2
      from pa_pji_proj_events_log
      where event_type = 'RBS_PUSH'
)a ,
pa_rbs_versions_b b
where to_number(a.attribute2) = b.rbs_version_id
and b.rbs_header_id =
(select rbs_header_id
from pa_rbs_versions_b
where rbs_version_id = p_event_rec.attribute2)
and rownum = 1;
exception
when NO_DATA_FOUND then
event_already_exists := 'N';
end;

END IF;

IF event_already_exists = 'Y' THEN

select rbs_header_id
into l_rbs_header_id
from pa_rbs_versions_b
where rbs_version_id = to_number(p_event_rec.attribute2);

UPDATE pa_pji_proj_events_log
SET event_object = p_event_rec.event_object,
    last_update_date = p_event_rec.last_update_date,
    last_updated_by = p_event_rec.last_updated_by
WHERE event_type = 'RBS_PUSH'
AND attribute2 in (select rbs_version_id
		   from pa_rbs_versions_b
		   where rbs_header_id = l_rbs_header_id);

  ELSE
/* Added for Bug#6145813 by vvjoshi - END*/

  INSERT INTO pa_pji_proj_events_log
  ( event_type
  , event_id
  , event_object
  , operation_type
  , status
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , last_update_login
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  , attribute16
  , attribute17
  , attribute18
  , attribute19
  , attribute20
)
  VALUES (
    p_event_rec.event_type
  , p_event_rec.event_id
  , p_event_rec.event_object
  , p_event_rec.operation_type
  , p_event_rec.status
  , p_event_rec.last_update_date
  , p_event_rec.last_updated_by
  , p_event_rec.creation_date
  , p_event_rec.created_by
  , p_event_rec.last_update_login
  , p_event_rec.attribute_category
  , p_event_rec.attribute1
  , p_event_rec.attribute2
  , p_event_rec.attribute3
  , p_event_rec.attribute4
  , p_event_rec.attribute5
  , p_event_rec.attribute6
  , p_event_rec.attribute7
  , p_event_rec.attribute8
  , p_event_rec.attribute9
  , p_event_rec.attribute10
  , p_event_rec.attribute11
  , p_event_rec.attribute12
  , p_event_rec.attribute13
  , p_event_rec.attribute14
  , p_event_rec.attribute15
  , p_event_rec.attribute16
  , p_event_rec.attribute17
  , p_event_rec.attribute18
  , p_event_rec.attribute19
  , p_event_rec.attribute20
 );

END IF; -- Added for Bug#6145813 by vvjoshi

 -- p_event_rec := l_event_rec ;

  -- INSERT INTO pa_pji_proj_events_log
  -- VALUES l_event_rec;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'CREATE_EVENT'
    , x_return_status => l_return_status ) ;

    RAISE;
END;


----------
-- API to lock headers, used by online and bulk summarization apis.
----------
PROCEDURE WBS_HEADERS_LOCK (
    p_fp_version_ids   IN OUT NOCOPY  SYSTEM.pa_num_tbl_type -- := SYSTEM.pa_num_tbl_type(),
  , p_context          IN          VARCHAR2
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 ) IS

  i              NUMBER := NULL;
  l_lock_flag    VARCHAR2(1);
  l_count        NUMBER := 0;
  l_count1       NUMBER := 0;
  l_num_locked   NUMBER := 0;

  l_fp_version_ids      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); --initialized the collection bug#4001139
  l_project_ids         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); --initialized the collection bug#4001139
  l_baseline_fp_ver_id  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); --initialized the collection bug#4001139
  l_wp_flags            SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
  l_latest_pub_flags    SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
  l_baselined_flags     SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
  l_published_flags     SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
  l_vers_enabled_flags  SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();

  l_fp_version_id       NUMBER;
  l_wp_flag             VARCHAR2(1);
  l_latest_pub_flag     VARCHAR2(1);
  l_baselined_flag      VARCHAR2(1);
  l_published_flag      VARCHAR2(1);
  l_vers_enabled_flag   VARCHAR2(1);

  l_wbs_version_id      NUMBER := NULL;

  l_last_update_date     DATE   := SYSDATE;
  l_last_updated_by      NUMBER := Fnd_Global.USER_ID;
  l_creation_date        DATE   := SYSDATE;
  l_created_by           NUMBER := Fnd_Global.USER_ID;
  l_last_update_login    NUMBER := Fnd_Global.LOGIN_ID;

  excp_resource_busy EXCEPTION;
  PRAGMA EXCEPTION_INIT(excp_resource_busy, -54);

  -- Generic lock for any 1 given plan version.
  CURSOR c_wh_generic_lock_cur (p_plan_version_id IN NUMBER) IS
      SELECT  project_id
      FROM    pji_pjp_wbs_header
      WHERE   plan_version_id = p_plan_version_id
        AND   lock_flag IS NULL
      FOR UPDATE NOWAIT;

  --
  -- Lock for progress update.
  -- Locks all latest published workplans above.
  --
  cursor c_wh_lock_update_cur (p_plan_version_id IN NUMBER,
                               p_project_id      IN NUMBER) IS
  select /*+ use_nl(sup_wbs_hdr)
             index(sup_wbs_hdr PJI_PJP_WBS_HEADER_N1) */
    sup_wbs_hdr.PLAN_VERSION_ID pvi
  from
    PJI_PJP_WBS_HEADER sup_wbs_hdr
  where
    (sup_wbs_hdr.PROJECT_ID,
     sup_wbs_hdr.WBS_VERSION_ID) in
    (
    select /*+ ordered
               index(prg PJI_XBS_DENORM_N1) */
      prg.SUP_PROJECT_ID,
      prg.SUP_ID
    from
      PJI_PJP_WBS_HEADER         sub_wbs_hdr,
      PA_PROJ_ELEM_VER_STRUCTURE ppevs2,
      PJI_XBS_DENORM             prg
    where
      prg.struct_version_id            is null                       and
      sub_wbs_hdr.PLAN_VERSION_ID      =  p_plan_version_id          and
      sub_wbs_hdr.PROJECT_ID           =  p_project_id               and
      sub_wbs_hdr.WBS_VERSION_ID       =  prg.SUB_ID                 and
      prg.STRUCT_TYPE                  =  'PRG'                      and
      nvl(prg.RELATIONSHIP_TYPE, 'WF') in ('LW', 'WF')               and
      sub_wbs_hdr.WP_FLAG              =  'Y'                        and
      ppevs2.PROJECT_ID                =  sub_wbs_hdr.PROJECT_ID     and
      ppevs2.ELEMENT_VERSION_ID        =  sub_wbs_hdr.WBS_VERSION_ID and
      ppevs2.LATEST_EFF_PUBLISHED_FLAG =  'Y'
    ) and
    sup_wbs_hdr.WP_FLAG = 'Y' and
    sup_wbs_hdr.LOCK_FLAG is null and
    exists
    (
    select
      1
    from
      PA_PROJ_ELEM_VER_STRUCTURE ppevs1
    where
      ppevs1.PROJECT_ID                = sup_wbs_hdr.PROJECT_ID and
      ppevs1.ELEMENT_VERSION_ID        = sup_wbs_hdr.WBS_VERSION_ID and
      ppevs1.LATEST_EFF_PUBLISHED_FLAG = 'Y'
    )
    for update nowait;

  --
  -- Lock for plan baseline and original flows.
  -- Locks all -3/-4s above striped by plan type id.
  --
  cursor c_wh_base_orig_lock_cur (p_plan_version_id in number) is
  select /*+ use_nl(sup_wbs_hdr)
             index(sup_wbs_hdr PJI_PJP_WBS_HEADER_N1) */
    sup_wbs_hdr.PROJECT_ID,
    sup_wbs_hdr.PLAN_VERSION_ID,
    sup_wbs_hdr.PLAN_TYPE_ID
  from
    PJI_PJP_WBS_HEADER sup_wbs_hdr
  where
    (sup_wbs_hdr.PROJECT_ID,
     sup_wbs_hdr.WBS_VERSION_ID,
     sup_wbs_hdr.PLAN_VERSION_ID,
     sup_wbs_hdr.PLAN_TYPE_ID,
     sup_wbs_hdr.PLAN_TYPE_CODE) in
    (
    select /*+ ordered
               index(prg PJI_XBS_DENORM_N1) */
      prg.SUP_PROJECT_ID,
      prg.SUP_ID,
      ver.BUDGET_VERSION_ID,
      ver.FIN_PLAN_TYPE_ID,
      sub_wbs_hdr.PLAN_TYPE_CODE
    from
      PA_BUDGET_VERSIONS ver,
      PJI_PJP_WBS_HEADER sub_wbs_hdr,
      PJI_XBS_DENORM     prg
    where
      ver.BUDGET_VERSION_ID            =  p_plan_version_id          and
      ver.PROJECT_ID                   =  sub_wbs_hdr.PROJECT_ID     and
      ver.FIN_PLAN_TYPE_ID             =  sub_wbs_hdr.PLAN_TYPE_ID   and
      decode(ver.VERSION_TYPE,
             'COST',    'C',
             'REVENUE', 'R',
                        'A')           =  sub_wbs_hdr.PLAN_TYPE_CODE and
      sub_wbs_hdr.PLAN_VERSION_ID      in (-3, -4)                   and
      sub_wbs_hdr.WBS_VERSION_ID       =  prg.SUB_ID                 and
      prg.STRUCT_TYPE                  =  'PRG'                      and
      prg.STRUCT_VERSION_ID            is null                       and
      nvl(prg.RELATIONSHIP_TYPE, 'WF') in ('LF', 'WF')
    )
  for update nowait;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  print_time ( ' wbs hdrs lock 1 p_context = ' || p_context );


  -- Validation of context.
  IF (p_context NOT IN ('DELETE', 'UPDATE', 'BASELINE', 'ORIGINAL', 'COPY')) THEN -- 'PUBLISH', 'STRUCT_CHANGE',
    print_time (' WBS_HEADERS_LOCK: The following value of p_context is invalid: ' || p_context);
    RETURN;
  END IF;


  -- About to process these plans.
  FOR i IN 1..p_fp_version_ids.COUNT LOOP
    print_time(' i = ' || i || ' pl. ver id = ' || p_fp_version_ids(i));
  END LOOP;


  --
  -- Validation of input plan versions, whether or not it exists in hdr tbl.
  --

  l_count := 0;

  FOR i IN 1..p_fp_version_ids.COUNT LOOP
    BEGIN
      SELECT /*+ index_ffs(wbs_hdr PJI_PJP_WBS_HEADER_N1) */ l_count+1
      INTO   l_count
      FROM   pji_pjp_wbs_header wbs_hdr
      WHERE  plan_version_id = p_fp_version_ids(i);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
  print_time ( ' wbs hdrs lock 1.001: # rcds in whdr is '|| l_count || ' # plan vers is ' || p_fp_version_ids.COUNT );

  IF (    (l_count <> p_fp_version_ids.COUNT)
      AND (p_context NOT IN ('BASELINE'))
     ) THEN
    print_time ( ' wbs hdrs lock 1.01: Not all of these plan versions exist. Pl. pass valid plan vers in plan ver id tbl. Returning.' );
    RETURN;
  END IF;


  --
  -- Validation of input plan versions, if they are already locked in hdr tbl.
  --

  l_count := 0;

  FOR i IN 1..p_fp_version_ids.COUNT LOOP
    BEGIN
      SELECT l_count+1
      INTO   l_count
      FROM   pji_pjp_wbs_header
      WHERE  plan_version_id = p_fp_version_ids(i)
        AND  lock_flag IS NULL;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
  print_time ( ' wbs hdrs lock 1.1: l_count is '|| l_count );

  IF (    (l_count <> p_fp_version_ids.COUNT)
      AND (p_context NOT IN ('BASELINE'))
     ) THEN
    print_time ( ' wbs hdrs lock 1.11: some plans in the program are already locked, raising exception. ' );
    RAISE excp_resource_busy;
  END IF;


  --
  -- Process each plan version for this context.
  --
  FOR i IN 1..p_fp_version_ids.COUNT LOOP                          -- 1

    print_time( ' wbs hdrs lock 1.11 inside loop.' );

    l_fp_version_ids.EXTEND;
    l_project_ids.EXTEND;
    l_wp_flags.EXTEND;
    l_latest_pub_flags.EXTEND;
    l_baselined_flags.EXTEND;
    l_published_flags.EXTEND;
    l_vers_enabled_flags.EXTEND;

    l_count := l_fp_version_ids.COUNT ;

    print_time( ' wbs hdrs lock 1.2:l_count ' || l_count || ' i ' || i || ' p_fp_version_ids(i) ' || p_fp_version_ids(i));

    IF (p_context NOT IN ('BASELINE', 'DELETE')) THEN

      -- Get the plan version properties: is it wp/fp, is it versioning enabled
      --   , is the structure working or published, is it latest pub, is it the baselined version?
      SELECT DISTINCT
            wh.plan_version_id pv
          , wh.project_id pi
          , wh.wp_flag wf
          , ppwa.wp_enable_version_flag vef
	    , DECODE(ppevs.status_code, 'STRUCTURE_PUBLISHED', 'P', 'STRUCTURE_WORKING', 'W') pf
	    , ppevs.latest_eff_published_flag lpf
	    , DECODE(wh.cb_flag, 'Y', 'B', 'W') bf
      INTO
          l_fp_version_ids(l_count)
        , l_project_ids(l_count)
        , l_wp_flags(l_count)
        , l_vers_enabled_flags(l_count)
        , l_published_flags(l_count)
        , l_latest_pub_flags(l_count)
        , l_baselined_flags(l_count)
      FROM PA_PROJ_WORKPLAN_ATTR ppwa
         , PA_PROJ_ELEMENTS ppe
         , PA_PROJ_STRUCTURE_TYPES ppst
         , PA_STRUCTURE_TYPES pst
         , PA_PROJ_ELEM_VER_STRUCTURE ppevs
         , pji_pjp_wbs_header wh
         -- , pa_budget_versions bv -- can't depend on bv in plan delete flow.
     WHERE 1=1
        AND ppe.project_id = ppwa.project_id
        AND ppe.proj_element_id = ppwa.proj_element_id
        AND ppe.proj_element_id = ppst.proj_element_id
        AND ppe.object_type = 'PA_STRUCTURES'              -- Added for perf improvement bug 6430959
        AND ppst.structure_type_id = pst.structure_type_id
        AND pst.structure_type_class_code = DECODE (wh.wp_flag, 'Y', 'WORKPLAN', 'FINANCIAL')
        AND ppevs.project_id = ppe.project_id
        AND ppevs.project_id = wh.project_id
        AND ppevs.element_version_id = wh.wbs_version_id
        AND ppevs.status_code IN ('STRUCTURE_PUBLISHED', 'STRUCTURE_WORKING')
        AND wh.plan_version_id = p_fp_version_ids(i) ;

    ELSE

      l_fp_version_ids(l_count) := p_fp_version_ids(l_count);

    END IF;


    /*
    l_fp_version_ids(l_count) := l_fp_version_id;
    l_wp_flags(l_count) := l_wp_flag;
    l_vers_enabled_flags(l_count) := l_vers_enabled_flag;
    l_published_flags(l_count) := l_published_flag;
    l_latest_pub_flags(l_count) := l_latest_pub_flag;
    l_baselined_flags(l_count) := l_baselined_flag;
    */

    print_time( ' wbs hdrs lock 1.3: l_fp_version_id ' || l_fp_version_ids(l_count));
    print_time( ' wbs hdrs lock 1.3: l_project_id ' || l_project_ids(l_count));
    print_time( ' wbs hdrs lock 1.3: l_wp_flag ' || l_wp_flags(l_count));
    print_time( ' wbs hdrs lock 1.3: l_vers_enabled_flag ' || l_vers_enabled_flags(l_count));
    print_time( ' wbs hdrs lock 1.3: l_published_flag ' || l_published_flags(l_count));
    print_time( ' wbs hdrs lock 1.3: l_latest_pub_flag ' || l_latest_pub_flags(l_count));
    print_time( ' wbs hdrs lock 1.3: l_baselined_flag ' || l_baselined_flags(l_count));

    IF ( (p_context = 'UPDATE')
     AND (l_fp_version_ids(l_count) > 0)) THEN                -- 2

      IF (                                                    -- 3
           (
             ( l_wp_flags(l_count) = 'Y' )
         AND (
               ( l_published_flags(l_count) = 'N' )
            OR ( l_latest_pub_flags(l_count) = 'Y' )
            OR ( l_vers_enabled_flags(l_count) = 'N' )
             )
           )
           OR
           (
             ( l_wp_flags(l_count) = 'N' )
         AND ( l_baselined_flags(l_count) = 'N')
           )
         ) THEN

        IF (                                                   -- 4
             ( l_wp_flags(l_count) = 'Y' )
         AND (
               ( l_latest_pub_flags(l_count) = 'Y' )
            OR ( l_vers_enabled_flags(l_count) = 'N' )
             )
           ) THEN


          l_num_locked := 0;


          -- Are any of the relevant WPs locked? Refer Program Reporting Tech Arch for biz rules.
          SELECT COUNT(1)
          INTO   l_num_locked
          FROM pji_xbs_denorm den
             , pji_pjp_wbs_header hd1 -- SUP
             , pji_pjp_wbs_header hd2 -- SUB
             , PA_PROJ_ELEM_VER_STRUCTURE ppevs1
             , PA_PROJ_ELEM_VER_STRUCTURE ppevs2
          WHERE
                den.struct_version_id IS NULL
            AND hd2.plan_version_id = l_fp_version_ids(l_count)
            AND hd2.project_id = l_project_ids(l_count)
            AND hd2.plan_type_id = hd1.plan_type_id
            AND hd2.wbs_version_id = den.sub_id -- struct_version_id
            AND hd1.wbs_version_id = den.sup_id
            AND den.struct_type = 'PRG'
            AND NVL(den.relationship_type, 'WF') IN ('LW', 'WF') --  'LW',
            AND hd1.wp_flag = 'Y'
            AND ppevs1.element_version_id = hd1.wbs_version_id
			AND ppevs1.project_id = hd1.project_id
            AND ppevs1.latest_eff_published_flag = 'Y'
            AND hd2.wp_flag = 'Y'
            AND ppevs2.project_id = hd2.project_id
            AND ppevs2.element_version_id = hd2.wbs_version_id
            AND ppevs2.latest_eff_published_flag = 'Y'
            AND hd1.lock_flag IS NOT NULL;


          IF (l_num_locked = 0) THEN                              -- 5

            OPEN c_wh_lock_update_cur (
                p_plan_version_id => l_fp_version_ids(l_count)
              , p_project_id      => l_project_ids(l_count));

            l_num_locked := SQL%ROWCOUNT;

            CLOSE c_wh_lock_update_cur;

          ELSE

            print_time ( ' wbs hdrs lock 1.12: some plans in the program are already locked, raising exception. ' );
            RAISE excp_resource_busy;

          END IF;                                                -- 5

        ELSIF                                                   -- 4
         (
           (
             ( l_wp_flags(l_count) = 'Y' )
         AND ( l_published_flags(l_count) = 'N' )
         AND ( l_vers_enabled_flags(l_count) = 'Y' )
           )
           OR
           ( l_wp_flags(l_count) = 'N' )
         ) THEN

           SELECT COUNT(1)
           INTO   l_num_locked
           FROM   pji_pjp_wbs_header
           WHERE  plan_version_id = l_fp_version_ids(l_count)
             AND  lock_flag IS NOT NULL;

          IF (l_num_locked = 0) THEN                              -- 5

            OPEN c_wh_generic_lock_cur(
              p_plan_version_id => l_fp_version_ids(l_count));

            l_num_locked := SQL%ROWCOUNT;

            CLOSE c_wh_generic_lock_cur;

          ELSE

            print_time ( ' wbs hdrs lock 1.13: some plans in the program are already locked, raising exception. ' );
            RAISE excp_resource_busy;

          END IF;                                                -- 5

        END IF;                                                   -- 4

      END IF;                                                   -- 3

    ELSIF ( (p_context IN ('COPY', 'DELETE'))
        AND (l_fp_version_ids(l_count) > 0)   ) THEN                -- 2
      -- Only working FPs/WPs can be deleted.

      SELECT COUNT(1)
      INTO   l_num_locked
      FROM   pji_pjp_wbs_header
      WHERE  plan_version_id = l_fp_version_ids(l_count)
        AND  lock_flag IS NOT NULL;

      IF (l_num_locked = 0) THEN                              -- 3

        OPEN c_wh_generic_lock_cur(
          p_plan_version_id => l_fp_version_ids(l_count));

        l_num_locked := SQL%ROWCOUNT;

        CLOSE c_wh_generic_lock_cur;

      ELSE

        print_time ( ' wbs hdrs lock 1.14: some plans in the program are already locked, raising exception. ' );
        RAISE excp_resource_busy;

      END IF;                                                -- 3

    ELSIF ( (p_context = 'PUBLISH')
        AND (l_fp_version_ids(l_count) > 0)) THEN                -- 2
      -- Only working FPs/WPs can be deleted.

      SELECT COUNT(1)
      INTO   l_num_locked
      FROM   pji_pjp_wbs_header
      WHERE  plan_version_id = l_fp_version_ids(l_count)
        AND  lock_flag IS NOT NULL;

      IF (l_num_locked = 0) THEN                              -- 3

        OPEN c_wh_generic_lock_cur(
          p_plan_version_id => l_fp_version_ids(l_count));

        l_num_locked := SQL%ROWCOUNT;

        CLOSE c_wh_generic_lock_cur;

      ELSE

        print_time ( ' wbs hdrs lock 1.15: some plans in the program are already locked, raising exception. ' );
        RAISE excp_resource_busy;

      END IF;                                                 -- 3

    ELSIF ( (p_context IN ('BASELINE', 'ORIGINAL') )
        AND (l_fp_version_ids(l_count) > 0)) THEN                -- 2

      SELECT PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
      INTO   l_wbs_version_id
      FROM   pa_budget_versions bv
      WHERE  budget_version_id = l_fp_version_ids(l_count);

      print_time ( ' wbs hdrs baseline lock 1.1 wbs version id is .. ' || l_wbs_version_id );

      l_baseline_fp_ver_id.EXTEND;
      l_baseline_fp_ver_id(l_baseline_fp_ver_id.COUNT) := l_fp_version_ids(l_count);


      PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES;
      print_time(' Cleaned up ver3_t table. ');


      PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(l_baseline_fp_ver_id, 'PRI');
      PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(l_baseline_fp_ver_id, 'SECRBS');
      print_time(' Populated ver3. ');


      INSERT INTO PJI_FM_EXTR_PLNVER3_T ver3
      (
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
	      SECONDARY_RBS_FLAG       ,
            LP_FLAG
          )
		  SELECT -- DISTINCT
                 den.sup_project_id project_id
               , cbco.plan_version_id -- bv.budget_version_id -- -3 --
               , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(den.sup_project_id) wbs_struct_version_id
               , bv.rbs_struct_version_id
               , bv.plan_type_code
               , bv.plan_type_id
               , bv.time_phased_type_code
               , NULL -- time dangl flg
               , NULL -- rate dangl flg
               , NULL -- project type class
               , 'N' -- wp flag
               , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
               , DECODE(cbco.plan_version_id, -4, 'Y', 'N') original_flag
               , DECODE(cbco.plan_version_id, -4, 'Y', 'N') -- curr_original flag
               , 'Y' -- baselined flag.
               , bv.SECONDARY_RBS_FLAG
               , bv.lp_flag
          FROM pji_fm_extr_plnver3_T bv
        	 , pji_xbs_denorm den
        	 , ( SELECT -3 plan_version_id FROM DUAL
        	     UNION ALL
        	     SELECT -4 FROM DUAL ) cbco
          WHERE 1=1
            AND bv.plan_version_id = l_fp_version_ids(l_count)
        	AND bv.wp_flag = 'N'
        	AND bv.baselined_flag = 'Y'
        	AND den.struct_version_id IS NULL
            AND den.struct_type = 'PRG'
        	AND den.sub_id = bv.wbs_struct_version_id
            AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF') --  Excluding 'LW'
            ;

      DELETE FROM pji_fm_extr_plnver3_t
      WHERE plan_version_id > 0;
      print_time(' Need only -3, -4 records, deleted other plan version. ');


      PJI_FM_PLAN_MAINT_T_PVT.POPULATE_RBS_HDR;
      print_time ( ' Inserted -3, -4 RBS headers inserted. ' );

      PJI_FM_PLAN_MAINT_T_PVT.POPULATE_WBS_HDR;
      print_time ( ' Inserted -3, -4 WBS headers inserted. ' );


      PJI_FM_PLAN_MAINT_T_PVT.CLEANUP_INTERIM_TABLES;
      print_time ( ' Cleaned up ver3. ' );


      SELECT COUNT(1)
      INTO   l_count1
      FROM pji_xbs_denorm den
         , pji_pjp_wbs_header hd1 -- SUB
         , pji_pjp_wbs_header hd2 -- SUP
         , pa_budget_versions hd3 -- to get plan type id
      WHERE
	      den.struct_version_id IS NULL
        AND den.struct_type = 'PRG'
        AND hd1.wbs_version_id = den.sub_id -- struct_version_id
        AND hd2.wbs_version_id = den.sup_id
        -- AND den.sup_level <= den.sub_level
        AND hd3.budget_version_id = l_fp_version_ids(l_count)
        AND hd3.project_id = hd1.project_id
        AND hd3.fin_plan_type_id = hd2.plan_type_id
        AND hd3.fin_plan_type_id = hd1.plan_type_id
        AND DECODE(hd3.version_type,'COST','C','REVENUE','R','A') = hd1.plan_type_code
       AND  hd1.plan_type_code = hd2.plan_type_code    /*4471527*/
        AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF') --  Excluding 'LW'
        AND hd1.plan_version_id IN (-3, -4)
        AND hd2.plan_version_id IN (-3, -4)
        AND hd1.plan_version_id = hd2.plan_version_id
        AND hd2.lock_flag IS NOT NULL;

      print_time ( ' # of locked -3, -4 headers for this project is '|| l_count1 );

      IF (l_count1 > 0) THEN -- Summarization is locking the -3, -4 headers above this project.
        print_time ( ' Summarization is locking the -3, -4 headers above this project. # locks is '|| l_count1 );
        RAISE excp_resource_busy;
      END IF;

      print_time ( ' wbs hdrs baseline lock 2 ');

      OPEN  c_wh_base_orig_lock_cur (p_plan_version_id => l_fp_version_ids(l_count));
      CLOSE c_wh_base_orig_lock_cur;

      print_time ( ' wbs hdrs baseline lock 3 ');

    END IF;                                                   -- 2

  END LOOP;                                                   -- 1

  print_time(' l_num_locked finally = ' || l_num_locked );

  p_fp_version_ids := l_fp_version_ids;

  print_time ( ' wbs hdrs lock 3 ');

EXCEPTION
  WHEN excp_resource_busy THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    x_msg_code := FND_MESSAGE.GET_STRING(  APPIN => 'PJI'
                                        , NAMEIN => 'PJI_LOCK_NOT_OBTAINED');

    -- PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PJI'
    --                    , p_msg_name       => 'PJI_LOCK_NOT_OBTAINED');
    FND_MESSAGE.SET_NAME('PJI', 'PJI_LOCK_NOT_OBTAINED');
    Fnd_Msg_Pub.add_detail(p_message_type=>FND_API.G_RET_STS_ERROR);

    print_time ( ' wbs hdrs lock exception ' || SQLERRM);

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'WBS_HEADERS_LOCK'
    , x_return_status => x_return_status ) ;

    RAISE;

  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'WBS_HEADERS_LOCK'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE PLAN_EXTR_LINES_LOCK (
    x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 ) IS

  l_project_id  NUMBER;

  excp_resource_busy EXCEPTION;
  PRAGMA EXCEPTION_INIT(excp_resource_busy, -54);

  CURSOR c_lines IS
    SELECT project_id
    FROM   pji_fm_extr_plan_lines
    WHERE  ROWID IN
	        ( SELECT extr_lines_rowid
		    FROM pji_fp_rmap_fpr_update_t)
    FOR UPDATE NOWAIT;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_msg_code := Fnd_Api.G_RET_STS_SUCCESS;

  print_time ( ' PLAN_EXTR_LINES_LOCK  begin ' );


  OPEN c_lines;
  CLOSE c_lines;

  print_time ( ' PLAN_EXTR_LINES_LOCK  end ' );

EXCEPTION
  WHEN excp_resource_busy THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => G_package_name ,
                             p_procedure_name => 'PJI_EXTR_LINES_LOCK' );
    x_msg_code := FND_MESSAGE.GET_STRING(  APPIN  => 'PJI'
                                         , NAMEIN => 'PJI_LOCK_NOT_OBTAINED');
    -- PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PJI'
    --                    , p_msg_name       => 'PJI_LOCK_NOT_OBTAINED');

    FND_MESSAGE.SET_NAME('PJI', 'PJI_LOCK_NOT_OBTAINED');
    Fnd_Msg_Pub.add_detail(p_message_type=>FND_API.G_RET_STS_ERROR);

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PJI_EXTR_LINES_LOCK'
    , x_return_status => x_return_status ) ;

    RAISE;

  WHEN NO_DATA_FOUND THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PJI_EXTR_LINES_LOCK'
    , x_return_status => x_return_status ) ;

    RAISE;

  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PJI_EXTR_LINES_LOCK'
    , x_return_status => x_return_status ) ;

    RAISE;

END;


PROCEDURE GET_HDRS_TOLOCK_FOR_UPDATE (
    x_fp_version_ids   OUT NOCOPY  SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 ) IS

  l_fp_version_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  CURSOR c_plan_version_ids_cur IS
  SELECT DISTINCT plan_version_id
  FROM PJI_FM_EXTR_PLAN_LINES
  WHERE ROWID IN
	        ( SELECT extr_lines_rowid
 		    FROM pji_fp_rmap_fpr_update_t);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  FOR i IN c_plan_version_ids_cur LOOP
    l_fp_version_ids.EXTEND;
    l_fp_version_ids(l_fp_version_ids.COUNT) := i.plan_version_id;
  END LOOP;

  -- IF c_plan_version_ids_cur%ISOPEN THEN c_plan_version_ids_cur.CLOSE; END IF;

  x_fp_version_ids := l_fp_version_ids ;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'GET_HDRS_TOLOCK_FOR_UPDATE '
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE GET_EVENT_IDS (
    p_fp_version_ids   IN          SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , p_operation_type   IN          VARCHAR2 := NULL
  , x_event_ids        OUT NOCOPY  SYSTEM.pa_num_tbl_type --  := SYSTEM.pa_num_tbl_type(),
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 ) IS

  l_event_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  i             NUMBER := NULL;
  j             NUMBER := NULL;

  CURSOR c_event_id_cur (
    p_event_object   NUMBER
  , p_operation_type VARCHAR2
  ) IS
  SELECT event_id
  FROM   pa_pji_proj_events_log
  WHERE  event_object = p_event_object
    AND  operation_type = p_operation_type;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  IF (p_operation_type IS NULL) THEN RETURN; END IF;

  FOR i IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST LOOP

    -- IF c_event_id_cur%ISOPEN THEN c_event_id_cur.CLOSE; END IF;

    FOR j IN c_event_id_cur(p_fp_version_ids(i), p_operation_type ) LOOP
      l_event_ids.EXTEND;
      l_event_ids(l_event_ids.COUNT) := j.event_id;
    END LOOP;

  END LOOP;

  -- IF c_event_id_cur%ISOPEN THEN c_event_id_cur.CLOSE; END IF;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'GET_EVENT_IDS'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE DELETE_EVENTS (
    p_event_ids        IN          SYSTEM.pa_num_tbl_type
  , x_return_status    OUT NOCOPY  VARCHAR2
  , x_msg_code         OUT NOCOPY  VARCHAR2 ) IS
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  print_time ( ' delete events 001 ' );

  FORALL i IN p_event_ids.FIRST..p_event_ids.LAST
    DELETE FROM pa_pji_proj_events_log
    WHERE  event_id  = p_event_ids(i);

  print_time ( ' delete events 002 ' );

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'DELETE_EVENTS'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE COPY_PJI_SUMMRZD_FLAG (
    p_source_fp_version_ids   IN SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type()
  , p_dest_fp_version_ids     IN SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type() ) IS

  l_pji_summarized_flag   VARCHAR2(1) := NULL;
  l_return_status         VARCHAR2(1);

BEGIN

  IF (p_source_fp_version_ids.COUNT <> p_dest_fp_version_ids.COUNT) THEN
    RETURN;
  END IF;

  FOR i IN p_source_fp_version_ids.FIRST..p_source_fp_version_ids.LAST LOOP

    BEGIN
      --Introduced below if condition for bug 7187487
      if p_source_fp_version_ids(i) <> p_dest_fp_version_ids(i) then
        SELECT pji_summarized_flag
        INTO   l_pji_summarized_flag
        FROM   pa_budget_versions
        WHERE  budget_version_id = p_source_fp_version_ids(i);

        UPDATE pa_budget_versions
        SET    pji_summarized_flag = l_pji_summarized_flag
        WHERE  budget_version_id = p_dest_fp_version_ids(i);
      elsif p_source_fp_version_ids(i) = p_dest_fp_version_ids(i) then
 	UPDATE pa_budget_versions
	SET    pji_summarized_flag = 'Y'
	WHERE  budget_version_id = p_dest_fp_version_ids(i);
      end if;


    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'COPY_PJI_SUMMARIZED_FLAG'
    , x_return_status => l_return_status ) ;

    RAISE;
END;


PROCEDURE MARK_PLAN_ORIGINAL	(
    p_original_version_id IN   NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_code            OUT NOCOPY  VARCHAR2 ) IS
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  -- Todo: verifiy logic with VR.
  UPDATE pa_budget_versions
  SET    original_flag = 'Y'
       , last_update_date = SYSDATE
       , last_updated_by = Fnd_Global.USER_ID
       , last_update_login = Fnd_Global.LOGIN_ID
  WHERE  budget_version_id = p_original_version_id ;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'MARK_PLAN_ORIGINAL'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE COPY_INTO_BASELINE_ORIGINAL(
   p_project_id      IN         NUMBER
 , p_plan_type_id    IN         NUMBER
 , p_plan_version_id IN         NUMBER
 , x_processing_code OUT NOCOPY VARCHAR2
) IS
    l_last_update_date     DATE   := SYSDATE;
    l_last_updated_by      NUMBER := Fnd_Global.USER_ID;
    l_creation_date        DATE   := SYSDATE;
    l_created_by           NUMBER := Fnd_Global.USER_ID;
    l_last_update_login    NUMBER := Fnd_Global.LOGIN_ID;
    l_return_status        VARCHAR2(1);
BEGIN

    Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
    ( p_package_name   => g_package_name
    , x_return_status  => x_processing_code );

    INSERT INTO pji_fp_xbs_accum_f
    (
       PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE   /*4471527 */
    )
    (
     SELECT
       rl.PROJECT_ID
     , rl.PROJECT_ORG_ID
     , rl.PROJECT_ORGANIZATION_ID
     , rl.PROJECT_ELEMENT_ID
     , rl.TIME_ID
     , rl.PERIOD_TYPE_ID
     , rl.CALENDAR_TYPE
     , rl.RBS_AGGR_LEVEL
     , rl.WBS_ROLLUP_FLAG
     , rl.PRG_ROLLUP_FLAG
     , rl.CURR_RECORD_TYPE_ID
     , rl.CURRENCY_CODE
     , rl.RBS_ELEMENT_ID
     , rl.RBS_VERSION_ID
     , p_plan_version_id
     , rl.PLAN_TYPE_ID
     , l_last_update_date
     , l_last_updated_by
     , l_creation_date
     , l_created_by
     , l_last_update_login
     , rl.RAW_COST
     , rl.BRDN_COST
     , rl.REVENUE
     , rl.BILL_RAW_COST
     , rl.BILL_BRDN_COST
     , rl.BILL_LABOR_RAW_COST
     , rl.BILL_LABOR_BRDN_COST
     , rl.BILL_LABOR_HRS
     , rl.EQUIPMENT_RAW_COST
     , rl.EQUIPMENT_BRDN_COST
     , rl.CAPITALIZABLE_RAW_COST
     , rl.CAPITALIZABLE_BRDN_COST
     , rl.LABOR_RAW_COST
     , rl.LABOR_BRDN_COST
     , rl.LABOR_HRS
     , rl.LABOR_REVENUE
     , rl.EQUIPMENT_HOURS
     , rl.BILLABLE_EQUIPMENT_HOURS
     , rl.SUP_INV_COMMITTED_COST
     , rl.PO_COMMITTED_COST
     , rl.PR_COMMITTED_COST
     , rl.OTH_COMMITTED_COST
       , rl.ACT_LABOR_HRS
	   , rl.ACT_EQUIP_HRS
	   , rl.ACT_LABOR_BRDN_COST
	   , rl.ACT_EQUIP_BRDN_COST
	   , rl.ACT_BRDN_COST
	   , rl.ACT_RAW_COST
	   , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
	   , rl.ETC_LABOR_HRS
	   , rl.ETC_EQUIP_HRS
	   , rl.ETC_LABOR_BRDN_COST
	   , rl.ETC_EQUIP_BRDN_COST
	   , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
     , rl.CUSTOM1
     , rl.CUSTOM2
     , rl.CUSTOM3
     , rl.CUSTOM4
     , rl.CUSTOM5
     , rl.CUSTOM6
     , rl.CUSTOM7
     , rl.CUSTOM8
     , rl.CUSTOM9
     , rl.CUSTOM10
     , rl.CUSTOM11
     , rl.CUSTOM12
     , rl.CUSTOM13
     , rl.CUSTOM14
     , rl.CUSTOM15
     , rl.PLAN_TYPE_CODE   /*4471527 */
    FROM
         pji_fp_xbs_accum_f rl
       , pji_pjp_wbs_header wh
    WHERE rl.project_id = wh.project_id
        AND rl.project_id = p_project_id
        AND rl.plan_type_id = p_plan_type_id
	  AND wh.plan_version_id = rl.plan_version_id
               AND wh.plan_type_code = rl.plan_type_code   /*4471527  */
	  AND DECODE(p_plan_version_id,
                   -3, wh.cb_flag
                   -4, wh.co_flag) = 'Y'
    );

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'COPY_INTO_BASELINE_ORIGINAL'
    , x_return_status =>  x_processing_code ) ;

    RAISE;
END;


PROCEDURE WBS_LOCK_PVT (
  p_event_id      IN NUMBER DEFAULT NULL,
  p_online_flag   IN VARCHAR2,
  p_request_id    IN NUMBER DEFAULT NULL,
  x_lock_mode     OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2 )
IS

  resource_busy EXCEPTION;
  PRAGMA EXCEPTION_INIT(resource_busy,-00054);

  l_project_id        NUMBER;
  l_struct_version_id NUMBER;

  l_plan_version_id       NUMBER;
  l_wp_flag             VARCHAR2(1);
  l_latest_pub_flag     VARCHAR2(1);
  l_baselined_flag      VARCHAR2(1);
  l_published_flag      VARCHAR2(1);
  l_vers_enabled_flag   VARCHAR2(1);

  -- Todo: Structure change, version disabled case program lock.

  /* -- original code.
  CURSOR c_plan_versions_online ( l_event_id NUMBER) IS
  SELECT
      head.PLAN_VERSION_ID
  FROM
    pji_pjp_wbs_header head,
    PA_PJI_PROJ_EVENTS_LOG elog
  WHERE
    elog.EVENT_ID          = l_event_id                 AND
    head.PROJECT_ID        = TO_NUMBER(elog.ATTRIBUTE1) AND
    head.WBS_VERSION_ID    = TO_NUMBER(elog.ATTRIBUTE2) AND
    head.PLAN_VERSION_ID   = TO_NUMBER(elog.ATTRIBUTE3) AND
    head.LOCK_FLAG IS NULL
  FOR UPDATE NOWAIT;
  */

  -- Handles online locking of
  --   a. Structure Change : All WP/FP/cb/co (only working structure can change
  --           based on a very strict set of rules. Like program rollup amts shd not change
  --           tasks with planning assignments/actuals should not be deleted, etc).
  --   b. Publish: All FP.
  CURSOR c_wh_lock_online_str_chng_cur ( l_event_id NUMBER) IS
  SELECT
    head.PLAN_VERSION_ID
  FROM
    pji_pjp_wbs_header head,
    PA_PJI_PROJ_EVENTS_LOG elog
  WHERE
    elog.EVENT_ID          = l_event_id                 AND
    head.PROJECT_ID        = TO_NUMBER(elog.ATTRIBUTE1) AND
    head.WBS_VERSION_ID    = TO_NUMBER(elog.ATTRIBUTE2) AND
    head.PLAN_VERSION_ID   = TO_NUMBER(elog.ATTRIBUTE3) AND
    -- elog.EVENT_TYPE        = 'WBS_CHANGE'               AND
    -- need to process both wbs change and publish.
    -- publish needs to change wbs version id for fin plans.
    head.LOCK_FLAG         IS NULL
  FOR UPDATE NOWAIT;


  -- Handles online locking of
  --   a. Published ver and one working ver above for publish.
  cursor c_online_pub_wp_cur (l_event_id number) IS
  select /*+ use_nl(sup_wbs_hdr)
             index(sup_wbs_hdr PJI_PJP_WBS_HEADER_N1) */
    sup_wbs_hdr.PLAN_VERSION_ID
  from
    PJI_PJP_WBS_HEADER sup_wbs_hdr
  where
    (sup_wbs_hdr.PROJECT_ID,
     sup_wbs_hdr.WBS_VERSION_ID) in
    (
    select /*+ ordered
               index(prg PJI_XBS_DENORM_N1) */
      prg.SUP_PROJECT_ID,
      prg.SUP_ID
    from
      PA_PJI_PROJ_EVENTS_LOG     log,
      PJI_PJP_WBS_HEADER         sub_wbs_hdr,
      PA_PROJ_ELEM_VER_STRUCTURE ppevs2,
      PJI_XBS_DENORM             prg
    where
      prg.STRUCT_VERSION_ID            is null                       and
      sub_wbs_hdr.WBS_VERSION_ID       =  prg.SUB_ID                 and
      sup_wbs_hdr.WBS_VERSION_ID       =  prg.SUP_ID                 and
      nvl(prg.SUB_ROLLUP_ID,
          prg.SUP_EMT_ID)              <> prg.SUP_EMT_ID             and
      prg.STRUCT_TYPE                  = 'PRG'                       and
      nvl(prg.RELATIONSHIP_TYPE, 'WF') in ('LW', 'WF')               and
      sub_wbs_hdr.WP_FLAG              =  'Y'                        and
      ppevs2.PROJECT_ID                =  sub_wbs_hdr.PROJECT_ID     and
      ppevs2.ELEMENT_VERSION_ID        =  sub_wbs_hdr.WBS_VERSION_ID and
      ppevs2.STATUS_CODE               =  'STRUCTURE_PUBLISHED'      and
      sub_wbs_hdr.LOCK_FLAG            is not null                   and
      sub_wbs_hdr.PROJECT_ID           =  to_number(log.ATTRIBUTE1)  and
      sub_wbs_hdr.WBS_VERSION_ID       =  to_number(log.ATTRIBUTE2)  and
      sub_wbs_hdr.PLAN_VERSION_ID      =  to_number(log.ATTRIBUTE3)  and
      log.EVENT_TYPE                   =  'WBS_PUBLISH'              and
      log.EVENT_ID                     =  l_event_id
    ) and
    sup_wbs_hdr.WP_FLAG = 'Y' and
    sup_wbs_hdr.LOCK_FLAG is not null and
    exists
    (
    select
      1
    from
      PA_PROJ_ELEM_VER_STRUCTURE ppevs1
    where
      ppevs1.PROJECT_ID         = sup_wbs_hdr.PROJECT_ID and
      ppevs1.ELEMENT_VERSION_ID = sup_wbs_hdr.WBS_VERSION_ID and
      ppevs1.STATUS_CODE        = 'STRUCTURE_WORKING'
    )
    for update nowait;

  -- Handles online locking of
  --   a. All cb/co for publish.
  cursor c_online_pub_cbco_lock_cur (l_event_id number) is
  select /*+ use_nl(sup_wbs_hdr) index(sup_wbs_hdr PJI_PJP_WBS_HEADER_N1) */
    sup_wbs_hdr.PROJECT_ID,
    sup_wbs_hdr.PLAN_VERSION_ID,
    sup_wbs_hdr.PLAN_TYPE_ID
  from
    PJI_PJP_WBS_HEADER sup_wbs_hdr
  where
    (sup_wbs_hdr.PROJECT_ID,
     sup_wbs_hdr.WBS_VERSION_ID,
     sup_wbs_hdr.PLAN_VERSION_ID,
     sup_wbs_hdr.PLAN_TYPE_ID,
     sup_wbs_hdr.PLAN_TYPE_CODE) in
    (
    select /*+ ordered
               index(prg PJI_XBS_DENORM_N1) */
      prg.SUP_PROJECT_ID,
      prg.SUP_ID,
      sub_wbs_hdr.PLAN_VERSION_ID,
      sub_wbs_hdr.PLAN_TYPE_ID,
      sub_wbs_hdr.PLAN_TYPE_CODE
    from
      PA_PJI_PROJ_EVENTS_LOG log,
      PJI_PJP_WBS_HEADER     wbs_hdr,
      PJI_PJP_WBS_HEADER     sub_wbs_hdr,
      PJI_XBS_DENORM         prg
    where
      prg.STRUCT_VERSION_ID            is null                       and
      sub_wbs_hdr.WBS_VERSION_ID       =  prg.SUB_ID                 and
      prg.STRUCT_TYPE                  =  'PRG'                      and
      nvl(prg.RELATIONSHIP_TYPE, 'WF') in ('LF', 'WF')               and
      sub_wbs_hdr.PLAN_VERSION_ID      in (-3, -4)                   and
      wbs_hdr.PROJECT_ID               =  sub_wbs_hdr.PROJECT_ID     and
      wbs_hdr.PLAN_TYPE_ID             =  sub_wbs_hdr.PLAN_TYPE_ID   and
      wbs_hdr.PLAN_TYPE_CODE           =  sub_wbs_hdr.PLAN_TYPE_CODE and
      wbs_hdr.LOCK_FLAG                is not null                   and
      wbs_hdr.PROJECT_ID               =  to_number(log.ATTRIBUTE1)  and
      wbs_hdr.WBS_VERSION_ID           =  to_number(log.ATTRIBUTE2)  and
      wbs_hdr.PLAN_VERSION_ID          in (-3, -4)                   and
      log.EVENT_TYPE                   =  'WBS_PUBLISH'              and
      log.EVENT_ID                     =  l_event_id
  )
  for update nowait;

  -- original code.
  CURSOR c_plan_versions_deferred IS
  SELECT
    head.PLAN_VERSION_ID
  FROM
    pji_pjp_wbs_header head,
    PA_PJI_PROJ_EVENTS_LOG elog
  WHERE
    head.PROJECT_ID        = TO_NUMBER(elog.ATTRIBUTE1) AND
    head.WBS_VERSION_ID    = TO_NUMBER(elog.ATTRIBUTE2) AND
    head.PLAN_VERSION_ID   = TO_NUMBER(elog.ATTRIBUTE3) AND
    elog.EVENT_TYPE IN ('WBS_CHANGE', 'WBS_PUBLISH')    AND
    head.LOCK_FLAG IS NULL
  FOR UPDATE;


  /*
  CURSOR c_wh_lock_sumz_str_chng_cur IS
  SELECT
    head.PLAN_VERSION_ID
  FROM
    pji_pjp_wbs_header head,
    PA_PJI_PROJ_EVENTS_LOG elog
  WHERE
    head.PROJECT_ID        = TO_NUMBER(elog.ATTRIBUTE1) AND
    head.WBS_VERSION_ID    = TO_NUMBER(elog.ATTRIBUTE2) AND
    head.PLAN_VERSION_ID   = TO_NUMBER(elog.ATTRIBUTE3) AND
    elog.EVENT_TYPE        = 'WBS_CHANGE'               AND
    head.LOCK_FLAG         IS NULL
  FOR UPDATE;

  CURSOR c_wh_lock_sumz_pub_cur IS
  SELECT hd1.plan_version_id
  FROM   pji_pjp_wbs_header hd1 -- SUP
  WHERE EXISTS (
  SELECT 1
  FROM pji_xbs_denorm den
     , pji_pjp_wbs_header hd2 -- SUB
     , PA_PROJ_WORKPLAN_ATTR ppwa1
     , PA_PROJ_ELEMENTS ppe1
     , PA_PROJ_STRUCTURE_TYPES ppst1
     , PA_STRUCTURE_TYPES pst1
     , PA_PROJ_ELEM_VER_STRUCTURE ppevs1
      , PA_PROJ_WORKPLAN_ATTR ppwa2
      , PA_PROJ_ELEMENTS ppe2
      , PA_PROJ_STRUCTURE_TYPES ppst2
      , PA_STRUCTURE_TYPES pst2
      , PA_PROJ_ELEM_VER_STRUCTURE ppevs2
      , PA_PJI_PROJ_EVENTS_LOG elog
  WHERE
        den.struct_version_id IS NULL
    AND hd2.wbs_version_id = den.sub_id -- struct_version_id
    AND hd1.wbs_version_id = den.sup_id
    AND NVL(den.sub_rollup_id, den.sup_emt_id) <> den.sup_emt_id
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LW', 'WF') --  'LW',
    AND hd1.wp_flag = 'Y'
    AND ppe1.project_id = ppwa1.project_id
    AND ppe1.proj_element_id = ppwa1.proj_element_id
    AND ppe1.proj_element_id = ppst1.proj_element_id
    AND ppst1.structure_type_id = pst1.structure_type_id
    AND pst1.structure_type_class_code = 'WORKPLAN'
    AND ppevs1.project_id = ppe1.project_id
    AND ppevs1.project_id = hd1.project_id
    AND ppevs1.element_version_id = hd1.wbs_version_id
    AND ppevs1.status_code = 'STRUCTURE_WORKING'
    AND hd1.lock_flag IS NOT NULL
    AND hd2.wp_flag = 'Y'
    AND ppe2.project_id = ppwa2.project_id
    AND ppe2.proj_element_id = ppwa2.proj_element_id
    AND ppe2.proj_element_id = ppst2.proj_element_id
    AND ppst2.structure_type_id = pst2.structure_type_id
    AND pst2.structure_type_class_code = 'WORKPLAN'
    AND ppevs2.project_id = ppe2.project_id
    AND ppevs2.project_id = hd2.project_id
    AND ppevs2.element_version_id = hd2.wbs_version_id
    -- AND ppwa2.wp_enable_version_flag  = 'N' -- Todo: to consider version disabled case.
    AND ppevs2.status_code = 'STRUCTURE_PUBLISHED'
    AND hd2.lock_flag IS NOT NULL
    AND hd2.PROJECT_ID        = TO_NUMBER(elog.ATTRIBUTE1)
    AND hd2.WBS_VERSION_ID    = TO_NUMBER(elog.ATTRIBUTE2)
    AND hd2.PLAN_VERSION_ID   = TO_NUMBER(elog.ATTRIBUTE3)
    AND elog.EVENT_TYPE       = 'WBS_PUBLISH'
    )
    FOR UPDATE;
    */


BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


  IF p_online_flag = 'Y' THEN
    --Try to acquire lock for affected plan versions
    BEGIN

      -- Structure change + publish.
      --   Affected plan vers: All plan vers with this structure on this project only.
      OPEN c_wh_lock_online_str_chng_cur (p_event_id);
      print_time(' str chg + publish l_num_locked = ' || SQL%ROWCOUNT );
      CLOSE c_wh_lock_online_str_chng_cur;

      -- Publish.
      --   Affected plan vers: The new published ver and all workplans one level above.
      OPEN c_online_pub_wp_cur (p_event_id);
      print_time(' publish wps lock only l_num_locked = ' || SQL%ROWCOUNT );
      CLOSE c_online_pub_wp_cur;

      -- Publish.
      --   Affected plan vers: All cb/co fin plans in the structure.
      OPEN c_online_pub_cbco_lock_cur (p_event_id);
      print_time(' publish cb cos lock only l_num_locked = ' || SQL%ROWCOUNT );
      CLOSE c_online_pub_cbco_lock_cur;

      x_lock_mode := 'S';

      RETURN;

    EXCEPTION
      WHEN resource_busy THEN
        --IF launched from conc. request
        --end conc. request with warning status
        SELECT
          TO_NUMBER(elog.ATTRIBUTE1),
          TO_NUMBER(elog.EVENT_OBJECT)
        INTO
          l_project_id,
          l_struct_version_id
        FROM
          pa_pji_proj_events_log elog
        WHERE
          elog.EVENT_ID = p_event_id AND
          ROWNUM <= 1;

        Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER       /* 5138049 */
         ( p_package_name   => g_package_name
         , p_procedure_name => 'WBS_LOCK_PVT'
         , x_return_status => x_return_status ) ;
        x_lock_mode := 'F';
        RETURN;
    END; --end of resource_busy exception block

  ELSE --for deferred case

     OPEN c_plan_versions_deferred;
     CLOSE c_plan_versions_deferred;

    --Need to update PJI_PJP_WBS_HEADER to set LOCK flag = Y
 ------------------------------------
 --Below locking is not required
 -----------------------------------
 /*   UPDATE pji_pjp_wbs_header head
    SET LOCK_FLAG =  'P'
    WHERE
      head.PLAN_VERSION_ID IN (SELECT
	                             TO_NUMBER(elog.ATTRIBUTE3)
						       FROM
						         pa_pji_proj_events_log elog
						       WHERE
						         head.PROJECT_ID        = TO_NUMBER(elog.ATTRIBUTE1) AND
						         head.WBS_VERSION_ID    = TO_NUMBER(elog.ATTRIBUTE2) AND
						         head.PLAN_VERSION_ID   = TO_NUMBER(elog.ATTRIBUTE3) AND
						         elog.EVENT_TYPE IN ('WBS_CHANGE', 'WBS_PUBLISH'));*/
    x_lock_mode := 'S';
    RETURN;

  END IF; --end deferred case

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'WBS_LOCK_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;
END; --end WBS_LOCK_PVT

------------------------------------------------------------------
--TODO: Need to add processing for publish event. All financial plans
--have to rollup based on latest published version
--currently we only update the wbs header table
-------------------------------------------------------------------
PROCEDURE WBS_MAINT_PVT (
  p_event_id        IN  NUMBER,
  p_versioned_flag  IN  VARCHAR2,
  p_struct_type     IN  VARCHAR2,
  p_publish_flag    IN  VARCHAR2,
  p_calling_context IN VARCHAR2,
  p_deffered_mode   IN VARCHAR2,
  p_rerun_flag      IN  VARCHAR2 :=NULL,
  x_return_status   OUT NOCOPY  VARCHAR2 )
IS
  l_project_id NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_old_wbs_version_id NUMBER;
  l_new_wbs_version_id NUMBER;
  l_prg_event_id NUMBER;
  l_request_id NUMBER;
  l_chd_phase VARCHAR2(400);
  l_chd_status VARCHAR2(400);
  l_chd_dev_phase VARCHAR2(400);
  l_chd_dev_status VARCHAR2(400);
  l_chd_message VARCHAR2(2000);
  l_plan_version_id NUMBER;

  l_plan_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_struct_sharing_code  pa_projects_all.structure_sharing_code%TYPE;
  CURSOR c_pln_ver_list (p_old_struct_ver_id IN NUMBER) IS
  SELECT project_id, plan_version_id
  FROM   pji_pjp_wbs_header
  WHERE 1 = 1
    AND wbs_version_id = p_old_struct_ver_id
    AND plan_version_id > 0;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );
  IF g_debug_mode='Y' THEN
    Pji_Utils.write2log('calling WBS_MAINT_PVT :p_versioned_flag: '||p_versioned_flag||'p_struct_type:'||p_struct_type||'p_publish_flag:'||p_publish_flag||'p_rerun_flag :' || p_rerun_flag ,null,3);
    Pji_Utils.write2log('calling WBS_MAINT_PVT :p_calling_Context: '||p_calling_Context||'p_deffered_mode:'||p_deffered_mode||'Event Id:' || p_event_id,null,3);
  end if;

  cleanup_temp_tables;


  SELECT
    TO_NUMBER(elog.ATTRIBUTE1),
    TO_NUMBER(elog.EVENT_OBJECT),
    TO_NUMBER(elog.ATTRIBUTE2)
  INTO
    l_project_id,
    l_new_wbs_version_id,
    l_old_wbs_version_id
  FROM
     pa_pji_proj_events_log elog
  WHERE
     elog.EVENT_ID = p_event_id AND
     ROWNUM <= 1;
  IF g_debug_mode='Y' THEN
  Pji_Utils.write2log('WBS_Maint_Pvt: l_new_wbs_version_id: '||l_new_wbs_version_id||'l_old_wbs_version_id: '||l_old_wbs_version_id,null,3);
  end if;
  -----------------------------------------------
  --Determine the plan_version_id for the struct
  --for which we are running wbs_maint
  -----------------------------------------------
  begin
  select
    PLAN_VERSION_ID
  into
    l_plan_version_id
  from
    pji_pjp_wbs_header
  where
    PROJECT_ID      = l_project_id AND
    WBS_VERSION_ID  = l_new_wbs_version_id AND
    WP_FLAG         = 'Y';
  exception
    when no_data_found then
      null;
      IF g_debug_mode='Y' THEN
        Pji_Utils.write2log('WBS_Maint_Pvt: No data found for plan version');
      END IF;
  end;

  IF g_debug_mode='Y' THEN
    Pji_Utils.write2log('WBS_Maint_Pvt:' || 'Plan version Id:' || l_plan_version_id);
  END IF;


  ----------------------------------------------
  --Identify if any pending program links exist
  --for the program group of this project
  ----------------------------------------------
  BEGIN
   IF p_rerun_flag='Y' THEN
      select 1
     into l_prg_event_id
     from dual
     where exists (select log.event_id
                   from   pji_pa_proj_events_log log,pa_proj_element_versions ver
                   where  log.event_type='PRG_CHANGE'
                   and    log.event_object =to_char(ver.prg_group)
                   and    ver.project_id=l_project_id
                   union all
                   select log.event_id
                   from   pa_pji_proj_events_log log,pa_proj_element_versions ver
                   where  log.event_type='PRG_CHANGE'
                   and    log.event_object =to_char(ver.prg_group)
                   and    ver.project_id=l_project_id);
  else
     select 1
     into l_prg_event_id
     from dual
     where exists (select log.event_id
                   from   pa_pji_proj_events_log log,pa_proj_element_versions ver
                   where  log.event_type='PRG_CHANGE'
                   and    log.event_object =to_char(ver.prg_group)
                   and    ver.project_id=l_project_id);

  end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF g_debug_mode='Y' THEN
        Pji_Utils.write2log( 'WBS_MAINT_PVT NO DATA FOUND coming for the project _Id:'||l_project_id,null,3);
      END IF;
      l_prg_event_id:=null;
  END;

  l_struct_sharing_code := Pa_Project_Structure_Utils.get_structure_sharing_code (l_project_id);
  IF l_old_wbs_version_id IS NULL THEN
        -- Fix for bug : 4191390
    If l_struct_sharing_code LIKE '%SHARE%' then
      UPDATE pji_pjp_wbs_header SET
        wbs_version_id = l_new_wbs_version_id
      WHERE
        wp_flag        = 'N' AND
        project_id     = l_project_id;

    elsif l_struct_sharing_code LIKE '%SPLIT%' THEN

      UPDATE pji_pjp_wbs_header SET
        wbs_version_id = l_new_wbs_version_id
      WHERE
        wp_flag        = 'N' AND
        p_struct_type  = 'FINANCIAL' AND
        project_id     = l_project_id;
    end if ;

     IF g_debug_mode='Y' THEN
        Pji_Utils.write2log( 'WBS_MAINT_PVT l_prg_event_id :'||l_prg_event_id||'l_struct_sharing_code'||l_struct_sharing_code ,null,3);
      END IF;
    IF l_prg_event_id is not null then

      --Bug 4626803: Need this for preventing doubling
      --of actuals
      UPDATE pji_fm_extr_plan_lines
        SET ACT_QUANTITY = NULL,
          ACT_TXN_BURDENED_COST = NULL,
	  ACT_PRJ_BURDENED_COST = NULL,
	  ACT_PFC_BURDENED_COST = NULL,
	  ACT_TXN_RAW_COST = NULL,
	  ACT_PRJ_RAW_COST = NULL,
	  ACT_PFC_RAW_COST = NULL,
	  ACT_TXN_REVENUE = NULL,
	  ACT_PRJ_REVENUE = NULL,
	  ACT_PFC_REVENUE = NULL
      WHERE
        plan_version_id = l_plan_version_id;

      --Callingt plan_update to process data in PJI_FM_EXTR_PLAN_LINES
       pa_task_pub1.G_CALL_PJI_ROLLUP := 'Y';
       pji_fm_xbs_accum_maint.plan_update (
         p_plan_version_id => l_plan_version_id,
         x_msg_code        => l_msg_data,
         x_return_status   => l_return_status );

       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         IF g_debug_mode='Y' THEN
           Pji_Utils.write2log('WBS Maint Pvt:' || 'Failure in plan_update call');
         END IF;
         RETURN;
       END IF;
       pa_task_pub1.G_CALL_PJI_ROLLUP := 'N';

    ----------------------------------------------------------------------------------------
    --The below COMMIT is as per design. It is required for releasing locks on denorm and
    --header table that will be accessed by the summarization program launched in step below
    COMMIT;
    savepoint process_wbs_updates_conc;
    savepoint process_wbs_updates;
    savepoint process_proj_sum_conc;
    ----------------------------------------------------------------------------------------
    -- Added If condition for Bug 5999999

    IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN

       l_request_id:=submit_request(l_project_id);
        if (FND_CONCURRENT.WAIT_FOR_REQUEST    (
           l_request_id,
           20,
           0, -- wait forever
           l_chd_phase,
           l_chd_status,
           l_chd_dev_phase,
           l_chd_dev_status,
           l_chd_message
                 )) then

          Pji_Utils.write2log( '*********22Submitted status the l_dev_phase: '||l_chd_dev_phase||'l_dev_status'||l_chd_dev_status ,null,3);

        end if;

          if  l_chd_dev_status ='ERROR' THEN
            l_return_status:='E';
             FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUMM_ERR');
             FND_MESSAGE.SET_TOKEN ('REQUEST_ID', l_request_id);
             FND_MESSAGE.SET_TOKEN ('SQLERRM', l_chd_message); --bug#5524224, passed completion text

	         fnd_msg_pub.add_exc_msg(p_pkg_name =>  g_package_name,
		                  p_procedure_name => 'WBS_MAINT_PVT',
                   		  p_error_text => SUBSTRB(FND_MESSAGE.GET,1,240));

              IF g_debug_mode='Y' THEN null;
                Pji_Utils.write2log(SUBSTRB(FND_MESSAGE.GET,1,240));
              end if;
		 elsif  l_chd_dev_status in ('CANCELLED','TERMINATED','DELETED') THEN
             l_return_status:='E';
             FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUMM_ERR');
             FND_MESSAGE.SET_TOKEN ('REQUEST_ID', l_request_id);
             FND_MESSAGE.SET_TOKEN ('SQLERRM', l_chd_status);
	         fnd_msg_pub.add_exc_msg(p_pkg_name =>  g_package_name,
		                  p_procedure_name => 'WBS_MAINT_PVT',
                   		  p_error_text => SUBSTRB(FND_MESSAGE.GET,1,240));
             IF g_debug_mode='Y' THEN null;
                Pji_Utils.write2log(SUBSTRB(FND_MESSAGE.GET,1,240));
             end if;

        end if;
    END IF;  -- Bug 5999999
     END IF;

     x_return_status:=l_return_status;

    ------------------------------------------------
    --As per current implementation the first publish
    --is treated differently
    ------------------------------------------------
    RETURN;
  END IF;


  FOR i IN c_pln_ver_list(l_old_wbs_version_id) LOOP

    l_plan_version_id_tbl.EXTEND;
    l_plan_version_id_tbl(l_plan_version_id_tbl.COUNT) := i.plan_version_id;

  END LOOP;
  IF g_debug_mode='Y' THEN
        Pji_Utils.write2log( 'WBS_MAINT_PVT l_plan_version_id_tbl.COUNT :'||l_plan_version_id_tbl.COUNT ,null,3);
      END IF;
/*bug5353559*/
  IF (l_plan_version_id_tbl.COUNT <= 0) THEN
    --RETURN;
    NULL;
ELSE

  Pji_Fm_Plan_Maint_T_Pvt.EXTRACT_FIN_PLAN_VERSIONS(
    p_fp_version_ids    => l_plan_version_id_tbl
  , p_slice_type        => 'PRI'
  );

  END IF;

 IF p_publish_flag = 'N' THEN

   Pji_Pjp_Sum_Denorm.populate_xbs_denorm(
     p_worker_id      => 1,
     p_denorm_type    => 'WBS',
     p_wbs_version_id => l_old_wbs_version_id,
     p_prg_group1     => NULL,
     p_prg_group2     => NULL
    );

IF g_debug_mode='Y' THEN
  Pji_Utils.write2log('WBS Maint Pvt:' || 'New WBS Version ID:' || l_new_wbs_version_id);
  Pji_Utils.write2log('WBS Maint Pvt:' || 'Old WBS Version ID:' || l_old_wbs_version_id);
end if;


  Pji_Pjp_Sum_Rollup.set_online_context (
    p_event_id              => p_event_id,
    p_project_id            => l_project_id,
    p_plan_type_id          => NULL,
    p_old_baselined_version => NULL,
    p_new_baselined_version => NULL,
    p_old_original_version  => NULL,
    p_new_original_version  => NULL,
    p_old_struct_version    => l_old_wbs_version_id,
    p_new_struct_version    => l_new_wbs_version_id );

  Pji_Pjp_Sum_Rollup.populate_xbs_denorm_delta;

  Pji_Pjp_Sum_Rollup.rollup_fpr_wbs;
   IF g_debug_mode='Y' THEN
  Pji_Utils.write2log(' WBS_MAINT_PVT: Pji_Pjp_Sum_Rollup.rollup_fpr_wbs',null,3);
  end if;
  Pji_Pjp_Sum_Rollup.rollup_acr_wbs;

  Pji_Pjp_Sum_Rollup.update_xbs_denorm;

  Pji_Pjp_Sum_Denorm.cleanup_xbs_denorm(
    p_worker_id 		=> 1
   ,p_extraction_type 	=> 'ONLINE');

  IF g_debug_mode='Y' THEN
  Pji_Utils.write2log(' WBS_MAINT_PVT: Pji_Fm_Plan_Maint_T_Pvt.MERGE_INTO_FP_FACT',null,3);
  end if;
  Pji_Fm_Plan_Maint_T_Pvt.MERGE_INTO_FP_FACT;


  Pji_Fm_Plan_Maint_T_Pvt.MERGE_INTO_AC_FACT;



 END IF;

  IF p_publish_flag = 'Y' THEN
   -- Fix for bug : 4191390
  If l_struct_sharing_code LIKE '%SHARE%' then
    UPDATE pji_pjp_wbs_header SET
      wbs_version_id = l_new_wbs_version_id
    WHERE
      wp_flag        = 'N' AND
      project_id     = l_project_id;
  elsif l_struct_sharing_code LIKE '%SPLIT%' THEN
    UPDATE pji_pjp_wbs_header SET
      wbs_version_id = l_new_wbs_version_id
    WHERE
      wp_flag        = 'N' AND
      p_struct_type  = 'FINANCIAL' AND
      project_id     = l_project_id;
  end if ;
  END IF;
/* Bug No.4567424
  Pa_Proj_Task_Struc_Pub.set_update_wbs_flag (
    p_project_id            => l_project_id,
    p_structure_version_id  => l_new_wbs_version_id,
    p_update_wbs_flag       => 'N',
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data );
*/
/* 	5138049 as updated by MAANSARI
  Pa_Proj_Task_Struc_Pub.process_task_weightage (
    p_project_id            => l_project_id,
    p_structure_version_id  => l_new_wbs_version_id,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data );
*/
  DELETE
  FROM pa_pji_proj_events_log LOG
  WHERE LOG.EVENT_ID = p_event_id;

  cleanup_temp_tables;
/*  bug5353559*/
/* Bug 5609109
  IF (l_plan_version_id_tbl.COUNT <= 0) THEN
      IF g_debug_mode='Y' THEN
         Pji_Utils.write2log(' WBS_MAINT_PVT: RETURNING as table count is Zero',null,3);
      end if;
    RETURN;
  end if; */

   IF g_debug_mode='Y' THEN
   Pji_Utils.write2log( 'calling APPLY_LP_PROG_ON_CWV :p_calling_Context: '||p_calling_Context||'p_deffered_mode:'||p_deffered_mode||'l_new_wbs_version_id:'||l_new_wbs_version_id ,null,3);
   end if;
   IF p_calling_Context='APPLY_PROGRESS' and p_deffered_mode='Y' THEN
         PA_PROGRESS_PUB.APPLY_LP_PROG_ON_CWV(
          p_project_id              => l_project_id,
          p_working_str_version_id  => l_new_wbs_version_id,
          x_return_status           => l_return_status,
          x_msg_count               => l_msg_count ,
          x_msg_data                => l_msg_data);
IF g_debug_mode='Y' THEN
   Pji_Utils.write2log( 'after call to APPLY_LP_PROG_ON_CWV :l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data||'CONC_REQUEST_Id:'||Fnd_Global.CONC_REQUEST_ID,null,3);
end if;
  END IF;



      IF l_prg_event_id is not null then

        --Bug 4626803: Need this for preventing doubling
        --of actuals
        UPDATE pji_fm_extr_plan_lines
        SET ACT_QUANTITY = NULL,
          ACT_TXN_BURDENED_COST = NULL,
	  ACT_PRJ_BURDENED_COST = NULL,
	  ACT_PFC_BURDENED_COST = NULL,
	  ACT_TXN_RAW_COST = NULL,
	  ACT_PRJ_RAW_COST = NULL,
	  ACT_PFC_RAW_COST = NULL,
	  ACT_TXN_REVENUE = NULL,
	  ACT_PRJ_REVENUE = NULL,
	  ACT_PFC_REVENUE = NULL
        WHERE
          plan_version_id = l_plan_version_id;

       --Callingt plan_update to process data in PJI_FM_EXTR_PLAN_LINES
       pa_task_pub1.G_CALL_PJI_ROLLUP := 'Y';
       pji_fm_xbs_accum_maint.plan_update (
         p_plan_version_id => l_plan_version_id,
         x_msg_code        => l_msg_data,
         x_return_status   => l_return_status );

       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         IF g_debug_mode='Y' THEN
           Pji_Utils.write2log('WBS Maint Pvt:' || 'Failure in plan_update call');
         END IF;
         RETURN;
       END IF;
       pa_task_pub1.G_CALL_PJI_ROLLUP := 'N';


      ----------------------------------------------------------------------------------------
      --The below COMMIT is as per design. It is required for releasing locks on denorm and
      --header table that will be accessed by the summarization program launched in step below
      COMMIT;
      savepoint process_wbs_updates_conc;
      savepoint process_wbs_updates;
      savepoint process_proj_sum_conc;
      ----------------------------------------------------------------------------------------
   -- Added If condition for Bug 5999999

      IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN

         l_request_id:=submit_request(l_project_id);
          if (FND_CONCURRENT.WAIT_FOR_REQUEST    (
             l_request_id,
          20,
          0, -- wait forever
          l_chd_phase,
          l_chd_status,
          l_chd_dev_phase,
          l_chd_dev_status,
          l_chd_message
                 )) then

          Pji_Utils.write2log( '*********22Submitted status the l_dev_phase: '||l_chd_dev_phase||'l_dev_status'||l_chd_dev_status ,null,3);

          end if;
          if  l_chd_dev_status ='ERROR' THEN
            l_return_status:='E';
             FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUMM_ERR');
             FND_MESSAGE.SET_TOKEN ('REQUEST_ID', l_request_id);
             FND_MESSAGE.SET_TOKEN ('SQLERRM', l_chd_message); --bug#5524224, passed completion text

	     fnd_msg_pub.add_exc_msg(p_pkg_name =>  g_package_name,
		                  p_procedure_name => 'WBS_MAINT_PVT',
                   		  p_error_text => SUBSTRB(FND_MESSAGE.GET,1,240));

              IF g_debug_mode='Y' THEN null;
                Pji_Utils.write2log(SUBSTRB(FND_MESSAGE.GET,1,240));
              end if;
		 elsif  l_chd_dev_status in ('CANCELLED','TERMINATED','DELETED') THEN
             l_return_status:='E';
             FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUMM_ERR');
             FND_MESSAGE.SET_TOKEN ('REQUEST_ID', l_request_id);
             FND_MESSAGE.SET_TOKEN ('SQLERRM', l_chd_status);
	         fnd_msg_pub.add_exc_msg(p_pkg_name =>  g_package_name,
		                  p_procedure_name => 'WBS_MAINT_PVT',
                   		  p_error_text => SUBSTRB(FND_MESSAGE.GET,1,240));
             IF g_debug_mode='Y' THEN null;
                Pji_Utils.write2log(SUBSTRB(FND_MESSAGE.GET,1,240));
             end if;

        end if;
    END IF ;  --Bug 5999999
     END IF;


  x_return_status:=l_return_status;
IF g_debug_mode='Y' THEN
  Pji_Utils.write2log( ' wbs maint pvt .. 0002   ::l_return_status'||l_return_status ,null,3);
end if;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'WBS_MAINT_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;
END;

PROCEDURE LAUNCH_WBS_REQ_PVT (
  p_event_id IN NUMBER,
  p_calling_context IN VARCHAR2,
  p_rerun_flag      IN  VARCHAR2 :=NULL,
  x_return_status OUT NOCOPY  VARCHAR2 )
IS
  l_request_id NUMBER;
  l_project_id        NUMBER;
  l_struct_version_id NUMBER;
  l_return_status VARCHAR2(1);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  SELECT
    TO_NUMBER(elog.ATTRIBUTE1),
    TO_NUMBER(elog.EVENT_OBJECT)
  INTO
    l_project_id,
    l_struct_version_id
  FROM
    pa_pji_proj_events_log elog
  WHERE
    elog.EVENT_ID = p_event_id AND
    ROWNUM <= 1;

  l_request_id:=
    Fnd_Request.SUBMIT_REQUEST (
      Pji_Utils.GET_PJI_SCHEMA_NAME,     -- Application name
      'PJI_FM_SUM_CHANGE',               -- concurrent program name
      NULL,                              -- description (optional)
      NULL,                              -- Start Time  (optional)
      FALSE,                             -- called from another conc. request
      p_event_id,                       -- first parameter
      p_calling_context,                -- second parameter
      p_rerun_flag     );


    PA_PROJECT_STRUCTURE_UTILS.SET_PROCESS_CODE_IN_PROC(
            p_project_id            => l_project_id,
            p_structure_version_id  => l_struct_version_id,
            p_calling_context       => p_calling_context,
            p_conc_request_id       => l_request_id,
            x_return_status         => l_return_status   );

EXCEPTION
  WHEN OTHERS THEN

     /*UPDATE pa_proj_elem_ver_structure
    SET PROCESS_CODE = 'WUE',
    CONC_REQUEST_ID = l_request_id
    WHERE ELEMENT_VERSION_ID = l_struct_version_id
    AND   PROJECT_ID         = l_project_id;
    */
      PA_PROJECT_STRUCTURE_UTILS.SET_PROCESS_CODE_ERR(
            p_project_id            => l_project_id,
            p_structure_version_id  => l_struct_version_id,
            p_calling_context       => p_calling_context,
            p_conc_request_id       => l_request_id,
            x_return_status         => l_return_status   );

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'LAUNCH_WBS_REQ_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;
END;

---------------------WBS_MAINT------------------------
--There are 4 different cases when this API gets called
    -- 1. Non-Versioned structure
    -- 2. Split versioned
    -- 3. Shared versioned and publish = N
    -- 4. Shared versioned and publish = Y
--------------------------------------------------------
PROCEDURE WBS_MAINT (
  p_new_struct_ver_id    IN  NUMBER,
  p_old_struct_ver_id    IN  NUMBER,
  p_project_id           IN  NUMBER,
  p_publish_flag         IN  VARCHAR2 DEFAULT 'N',
  p_online_flag          IN  VARCHAR2,
  p_calling_Context      IN  VARCHAR2 :=NULL,
  p_rerun_flag           IN  VARCHAR2 :=NULL,
  x_request_id           OUT NOCOPY  NUMBER,
  x_processing_code      OUT NOCOPY  VARCHAR2,
  x_msg_code             OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_online_flag          OUT NOCOPY  VARCHAR2)
IS

  l_shared_flag VARCHAR2(1) := 'A'; --Default value implies value is null in source system
  l_versioned_flag VARCHAR2(1):='N';
  l_struct_type VARCHAR2(30);
  l_struct_sharing_code  pa_projects_all.structure_sharing_code%TYPE;
  l_event_id NUMBER;
  l_return_status VARCHAR2(1);
  l_lock_mode VARCHAR2(1);
  l_working_version_id number;
  l_request_id NUMBER;
BEGIN


  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );
  IF g_debug_mode='Y' THEN
    Pji_Utils.write2log('Coming IN WBS_MAINT :p_new_struct_ver_id: '||p_new_struct_ver_id||'p_old_struct_ver_id:'||p_old_struct_ver_id||'p_project_id: '||p_project_id||'p_publish_flag :' || p_publish_flag ,null,3);
    Pji_Utils.write2log('Coming IN WBS_MAINT :p_online_flag: '||p_online_flag||'p_calling_Context : '||p_calling_Context ||'p_rerun_flag: '|| p_rerun_flag,null,3);
  end if;

    --Identify if the project has shared/split
    --versioned/non-versioned structure
    --l_struct_type :=
      -- Fix for bug : 4191390
      l_struct_sharing_code :=
      Pa_Project_Structure_Utils.get_structure_sharing_code (p_project_id);


    IF l_struct_sharing_code LIKE '%SHARE%' THEN
      l_shared_flag := 'Y';
    ELSIF l_struct_sharing_code LIKE '%SPLIT%' THEN
      l_shared_flag := 'N';
      IF p_publish_flag = 'Y' THEN
	  SELECT
	    typ.STRUCTURE_TYPE
	  INTO
	    l_struct_type
        FROM
	    pa_structure_types typ,
        pa_proj_structure_types ptyp,
        pa_proj_element_versions ver
        WHERE
	    typ.STRUCTURE_TYPE_ID       = ptyp.STRUCTURE_TYPE_ID AND
        ptyp.PROJ_ELEMENT_ID        = ver.PROJ_ELEMENT_ID    AND
        ver.ELEMENT_VERSION_ID      = p_new_struct_ver_id ; --p_old_struct_ver_id; fix for bug : 4191390
      END IF;
    END IF;

   /*   bug5353559*/
    l_versioned_flag := NVL( Pa_Workplan_Attr_Utils.check_wp_versioning_enabled (p_project_id),'N');



    --------------------------------------
    --The first step is to LOG the event
    -------------------------------------
    --Initialize Event sequence
    SELECT pa_pji_proj_events_log_s.NEXTVAL
    INTO l_event_id
    FROM sys.dual;

    IF l_versioned_flag = 'N' THEN
    --CASE 1: Non-Versioned (Work plans + actuals + fin plans)

        INSERT INTO pa_pji_proj_events_log (
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3 )
        SELECT
          DECODE (p_publish_flag, 'N', 'WBS_CHANGE', 'WBS_PUBLISH'),
          l_event_id,
          p_new_struct_ver_id,
          'I',
          'X',
          SYSDATE,
          -1,
          SYSDATE,
          -1,
          -1,
          p_project_id,
          p_old_struct_ver_id,
          head.PLAN_VERSION_ID
        FROM
          pji_pjp_wbs_header head
        WHERE
          head.PROJECT_ID     = p_project_id AND
          head.WBS_VERSION_ID = p_old_struct_ver_id;

    IF SQL%rowcount = 0 THEN
       INSERT INTO pa_pji_proj_events_log (
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3 )
        SELECT
          DECODE (p_publish_flag, 'N', 'WBS_CHANGE', 'WBS_PUBLISH'),
          l_event_id,
          p_new_struct_ver_id,
          'I',
          'X',
          SYSDATE,
          -1,
          SYSDATE,
          -1,
          -1,
          p_project_id,
          p_old_struct_ver_id,
	  NULL
	FROM dual;
     END IF;

        -- Commented the logic to always process the request online
        -- this code change was done for R12 bug 5198662.
        -- If this is called in online mode then defer this processing
        -- by launching a concurrent request
        --IF p_online_flag = 'Y' THEN
	  -- g_deffered_mode:='Y';
        --
        --  LAUNCH_WBS_REQ_PVT (
        --    p_event_id        => l_event_id,
	  --  p_calling_context => p_calling_Context,
	  --  p_rerun_flag      => p_rerun_flag,
        --    x_return_status   => l_return_status );
        --
        --  x_return_status := l_return_status;
        --  x_processing_code := 'D';

        --ELSE --Already in concurrent request

          WBS_LOCK_PVT (
            p_event_id      => l_event_id,
            p_online_flag   => 'Y',
            p_request_id    => Fnd_Global.CONC_REQUEST_ID,
            x_lock_mode     => l_lock_mode,
            x_return_status => l_return_status );

          IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_msg_code      := SQLERRM;
          END IF;

          IF l_lock_mode = 'S' THEN
            WBS_MAINT_PVT (
              p_event_id       => l_event_id,
              p_versioned_flag => l_versioned_flag,
              p_struct_type    => l_struct_type , --l_shared_flag, fix for bug : 4191390
              p_publish_flag   => p_publish_flag,
	      p_Calling_Context=>p_Calling_Context,
	      p_deffered_mode   =>'N',
	      p_rerun_flag      => p_rerun_flag,
              x_return_status  => l_return_status );

            x_return_status := l_return_status;
            x_processing_code := 'S';
          END IF;

       --END IF;--End deferred processing

      ELSIF ((l_versioned_flag = 'Y' AND l_shared_flag = 'N')     OR
            (l_versioned_flag = 'Y' AND l_shared_flag = 'Y' AND
             p_publish_flag = 'N')                                OR
			 l_struct_type = 'WORKPLAN') THEN
      --CASE 2: Only Workplans
        INSERT INTO pa_pji_proj_events_log (
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3 )
        SELECT
          DECODE (p_publish_flag, 'N', 'WBS_CHANGE', 'WBS_PUBLISH'),
          l_event_id,
          p_new_struct_ver_id,
          'I',
          'X',
          SYSDATE,
          -1,
          SYSDATE,
          -1,
          -1,
          p_project_id,
          p_old_struct_ver_id,
          head.PLAN_VERSION_ID
        FROM
          pji_pjp_wbs_header head
        WHERE
          head.PROJECT_ID     = p_project_id        AND
          head.WBS_VERSION_ID = p_old_struct_ver_id AND
          head.WP_FLAG        = 'Y';

		IF SQL%rowcount = 0 THEN
		INSERT INTO pa_pji_proj_events_log (
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3 )
        SELECT
          DECODE (p_publish_flag, 'N', 'WBS_CHANGE', 'WBS_PUBLISH'),
          l_event_id,
          p_new_struct_ver_id,
          'I',
          'X',
          SYSDATE,
          -1,
          SYSDATE,
          -1,
          -1,
          p_project_id,
          p_old_struct_ver_id,
		  NULL
		FROM dual;
	END IF;

        WBS_LOCK_PVT (
          p_event_id      => l_event_id,
          p_online_flag   => 'Y',
          p_request_id    => Fnd_Global.CONC_REQUEST_ID,
          x_lock_mode     => l_lock_mode,
          x_return_status => l_return_status );

        IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_msg_code      := SQLERRM;
        END IF;

        IF l_lock_mode = 'S' THEN

          WBS_MAINT_PVT (
            p_event_id       => l_event_id,
            p_versioned_flag => l_versioned_flag,
            p_struct_type    => l_struct_type , --l_shared_flag, fix for bug : 4191390
            p_publish_flag   => p_publish_flag,
    	    p_Calling_Context=>p_Calling_Context,
            p_deffered_mode   =>'N',
	    p_rerun_flag      => p_rerun_flag,
            x_return_status  => l_return_status );

            x_return_status := l_return_status;
            x_processing_code := 'S';

        END IF;
        --Note: If lock is not acquired then no processing is done for event

      ELSIF ((l_versioned_flag = 'Y' AND l_shared_flag = 'Y' AND
            p_publish_flag = 'Y') OR
			l_struct_type = 'FINANCIAL' ) THEN
      --CASE 3: Only for Financial plans and Actuals
        INSERT INTO pa_pji_proj_events_log (
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3 )
        SELECT
          'WBS_PUBLISH',
          l_event_id,
          p_new_struct_ver_id,
          'I',
          'X',
          SYSDATE,
          -1,
          SYSDATE,
          -1,
          -1,
          p_project_id,
          p_old_struct_ver_id,
          head.PLAN_VERSION_ID
        FROM
          pji_pjp_wbs_header head
        WHERE
          head.PROJECT_ID     = p_project_id        AND
          head.WBS_VERSION_ID = p_old_struct_ver_id AND
          head.WP_FLAG        = 'N';

		IF SQL%rowcount = 0 THEN
		INSERT INTO pa_pji_proj_events_log (
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3 )
        SELECT
          DECODE (p_publish_flag, 'N', 'WBS_CHANGE', 'WBS_PUBLISH'),
          l_event_id,
          p_new_struct_ver_id,
          'I',
          'X',
          SYSDATE,
          -1,
          SYSDATE,
          -1,
          -1,
          p_project_id,
          p_old_struct_ver_id,
		  NULL
		FROM dual;
	END IF;

        -- Commented the logic to always process the request online
        -- this code change was done for R12 bug 5198662.
        -- If this is called in online mode then defer this processing
        -- by launching a concurrent request
        --IF p_online_flag = 'Y' THEN
	  -- g_deffered_mode:='Y';
        --
        --  LAUNCH_WBS_REQ_PVT (
        --    p_event_id        => l_event_id,
	  --  p_calling_context =>p_calling_Context,
	  --  p_rerun_flag      => p_rerun_flag,
        --    x_return_status   => l_return_status );
        --
        --  x_return_status := l_return_status;
        --  x_processing_code := 'D';
        --
        --ELSE

          WBS_LOCK_PVT (
            p_event_id      => l_event_id,
            p_online_flag   => 'Y',
            p_request_id    => Fnd_Global.CONC_REQUEST_ID,
            x_lock_mode     => l_lock_mode,
            x_return_status => l_return_status );

          IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_msg_code      := SQLERRM;
          END IF;

          IF l_lock_mode = 'S' THEN
            WBS_MAINT_PVT (
              p_event_id       => l_event_id,
              p_versioned_flag => l_versioned_flag,
              p_struct_type    => l_struct_type , --l_shared_flag, fix for bug : 4191390
              p_publish_flag   => p_publish_flag,
	      p_Calling_Context=>p_Calling_Context,
	      p_deffered_mode   =>'N',
	      p_rerun_flag      => p_rerun_flag,
              x_return_status  => l_return_status );

            x_return_status := l_return_status;
            x_processing_code := 'S';

          END IF;--end lock mode

        END IF;

      --END IF;

 --   IF g_deffered_mode='Y' THEN
--      x_online_flag:='N';
--    END IF;
    IF g_debug_mode='Y' THEN
      Pji_Utils.write2log('Going out WBS_MAINT :x_request_id: '||x_request_id||'x_processing_code:'||x_processing_code||'x_msg_code: '||x_msg_code ,null,3);
      Pji_Utils.write2log('Going out WBS_MAINT :x_return_status: '||x_return_status||'x_online_flag :'||x_online_flag  ,null,3);
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'WBS_MAINT'
    , x_return_status => x_return_status ) ;

    RAISE;
END;

--This API is called from the concurrent request
--PRC: Process project summary changes
PROCEDURE PROCESS_PROJ_SUM_CHANGES (
  errbuf                OUT NOCOPY VARCHAR2,
  retcode               OUT NOCOPY VARCHAR2,
  p_event_id            IN         NUMBER,
  p_calling_context     IN         VARCHAR2,
  p_rerun_flag          IN  VARCHAR2 := NULL )
IS

  l_shared_flag VARCHAR2(1);
  l_versioned_flag VARCHAR2(1);
  l_struct_type VARCHAR2(30);
  l_return_status VARCHAR2(1);
  l_project_id NUMBER;
  l_lock_mode VARCHAR2(1);
  l_publish_flag VARCHAR2(1);
  l_struct_version_id NUMBER;
  l_calling_context VARCHAR2(20);

BEGIN
IF g_debug_mode='Y' THEN
 Pji_Utils.write2log( 'PROCESS_PROJ_SUM_CHANGES :p_event_id '||p_event_id ||'p_calling_context'||p_calling_context ,null,3);
end if;
select   decode(p_calling_context, 'ONLINE_PUBLISH',  'CONC_PUBLISH'
			         , 'ONLINE_UPDATE', 'CONC_UPDATE', p_calling_context)
into l_calling_context
from dual;
 savepoint process_proj_sum_conc;
    BEGIN
        SELECT
          TO_NUMBER(elog.ATTRIBUTE1),
          DECODE(elog.EVENT_TYPE, 'WBS_PUBLISH', 'Y', 'N'),
          elog.EVENT_OBJECT
        INTO
          l_project_id,
          l_publish_flag,
          l_struct_version_id
        FROM
          pa_pji_proj_events_log elog
        WHERE
          elog.EVENT_ID = p_event_id AND
          ROWNUM       <= 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        retcode := 0;
        RETURN;
    END;

    --Identify if the project has shared/split
    --versioned/non-versioned structure
    l_struct_type :=
      Pa_Project_Structure_Utils.get_structure_sharing_code (l_project_id);
    IF l_struct_type LIKE 'SHARE%' THEN
      l_shared_flag := 'Y';
    ELSE
      l_shared_flag := 'N';
    END IF;

   l_versioned_flag := NVL( Pa_Workplan_Attr_Utils.check_wp_versioning_enabled (l_project_id),'N'); /*bug5353559*/

  WBS_LOCK_PVT (
    p_event_id      => p_event_id,
    p_online_flag   => 'N',                        --- 	5138049 because in online NOWAIT is used
    p_request_id    => Fnd_Global.CONC_REQUEST_ID,
    x_lock_mode     => l_lock_mode ,
    x_return_status => l_return_status );
     IF g_debug_mode='Y' THEN
     Pji_Utils.write2log( 'PROCESS_PROJ_SUM_CHANGES :call to WBS_LOCK_PVT: l_lock_mode '||l_lock_mode ,null,3);
     end if;
  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            UPDATE pa_proj_elem_ver_structure
            SET PROCESS_CODE =decode(l_calling_context, 'APPLY_PROGRESS', 'APE'
					   , 'CONC_PUBLISH', 'PUE'
					   , 'CONC_UPDATE', 'WUE', null),
		process_update_wbs_flag = 'Y',     /* 	5138049 */
                CONC_REQUEST_ID = Fnd_Global.CONC_REQUEST_ID
            WHERE ELEMENT_VERSION_ID = l_struct_version_id
            AND   PROJECT_ID         = l_project_id;
      retcode := 2;
      errbuf  := SQLERRM;
  ELSE
    retcode := 0;
  END IF;

  IF l_lock_mode = 'S' THEN

    WBS_MAINT_PVT (
      p_event_id       => p_event_id,
      p_versioned_flag => l_versioned_flag,
      p_struct_type    => l_shared_flag,
      p_publish_flag   => l_publish_flag,
      p_calling_context=> l_calling_context,
      p_deffered_mode  =>'Y',
      p_rerun_flag     => p_rerun_flag,
      x_return_status  => l_return_status );
    IF g_debug_mode='Y' THEN
       Pji_Utils.write2log( 'PROCESS_PROJ_SUM_CHANGES :call to WBS_MAINT_PVT: l_return_status '||l_return_status ,null,3);
       end if;
    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN

      IF Fnd_Global.CONC_REQUEST_ID IS NOT NULL THEN
            rollback to process_proj_sum_conc;
           UPDATE pa_proj_elem_ver_structure
            SET PROCESS_CODE =decode(l_calling_context, 'APPLY_PROGRESS', 'APE'
					   , 'CONC_PUBLISH', 'PUE'
					   , 'CONC_UPDATE', 'WUE', null),
		process_update_wbs_flag = 'Y',     /* 	5138049 */
                CONC_REQUEST_ID = Fnd_Global.CONC_REQUEST_ID
            WHERE ELEMENT_VERSION_ID = l_struct_version_id
            AND   PROJECT_ID         = l_project_id;
/*
           PA_PROJECT_STRUCTURE_UTILS.SET_PROCESS_CODE_ERR(
            p_project_id            => l_project_id,
            p_structure_version_id  => l_struct_version_id,
            p_calling_context       => p_calling_context,
            p_conc_request_id       => Fnd_Global.CONC_REQUEST_ID,
            x_return_status         => l_return_status   );
*/
        END IF;

      retcode := 2;
      errbuf  := SQLERRM;
    ELSE
      IF Fnd_Global.CONC_REQUEST_ID IS NOT NULL THEN
            UPDATE pa_proj_elem_ver_structure
            SET PROCESS_CODE = NULL,
	      process_update_wbs_flag='N',
                CONC_REQUEST_ID = Fnd_Global.CONC_REQUEST_ID
            WHERE ELEMENT_VERSION_ID = l_struct_version_id
            AND   PROJECT_ID         = l_project_id;
      END IF;
      retcode := 0;
    END IF;

  ELSIF l_lock_mode = 'F' THEN
    IF g_debug_mode='Y' THEN
    Pji_Utils.write2log( 'PROCESS_PROJ_SUM_CHANGES :Not able to take the lock  showing the warning' ,null,4);
    end if;
    retcode := 1; --Unable to acquire lock and hence complete request as warning

  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    rollback to process_proj_sum_conc;
    IF Fnd_Global.CONC_REQUEST_ID IS NOT NULL THEN
         PA_PROJECT_STRUCTURE_UTILS.SET_PROCESS_CODE_ERR(
            p_project_id            => l_project_id,
            p_structure_version_id  => l_struct_version_id,
            p_calling_context       => l_calling_context,                --Bug fix 6456711
            p_conc_request_id       => Fnd_Global.CONC_REQUEST_ID,
            x_return_status         => l_return_status   );
    END IF;
  IF g_debug_mode='Y' THEN
     Pji_Utils.write2log( 'PROCESS_PROJ_SUM_CHANGES : COMING to the exception' ,null,5);
  end if;
    retcode := 2;
    errbuf  := SQLERRM;
END;


--
-- Called from summarization programs.
--
PROCEDURE process_pending_events (
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2 )
IS

  CURSOR c_pending_events IS
  SELECT
    DISTINCT
    elog.EVENT_TYPE,
    elog.EVENT_ID
  FROM
    pa_pji_proj_events_log elog
  WHERE
    elog.EVENT_TYPE IN ('WBS_CHANGE',
                        'WBS_PUBLISH',
                        'PLAN_DELETE',
                        'PLAN_BASELINE',
                        'PLAN_ORIGINAL',
                        'PLAN_COPY' );

  l_processing_code VARCHAR2(1);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

/*  FOR rec IN c_pending_events LOOP

    proces_event_pvt (
      p_event_id        => rec.EVENT_ID,
      p_event_type      => rec.EVENT_TYPE,
      x_processing_code => l_processing_code,
      x_return_status   => x_return_status,
      x_msg_data        => x_msg_data);

  END LOOP;--loop for pending events */

EXCEPTION
  WHEN OTHERS THEN

    x_msg_data      := SQLERRM;

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PROCESS_PENDING_EVENTS'
    , x_return_status => x_return_status ) ;

    RAISE;

END;


PROCEDURE proces_event_pvt (
  p_event_id      IN  NUMBER,
  p_event_type    IN  VARCHAR2,
  x_processing_code OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2 )
IS

  l_processing_code VARCHAR2(1);
  l_lock_mode VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_shared_flag VARCHAR2(1);
  l_versioned_flag VARCHAR2(1);
  l_struct_type VARCHAR2(30);
  l_project_id NUMBER;
  l_publish_flag VARCHAR2(1);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


    IF p_event_type LIKE 'WBS%' THEN

      WBS_LOCK_PVT (
        p_event_id      => p_event_id,
        p_online_flag   => 'Y',
        p_request_id    => Fnd_Global.CONC_REQUEST_ID,
        x_lock_mode     => l_lock_mode,
        x_return_status => l_return_status );

      IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        x_msg_data      := SQLERRM;
      END IF;

      IF l_lock_mode = 'S' THEN

        BEGIN
          SELECT
            TO_NUMBER(elog.ATTRIBUTE1)
          INTO
            l_project_id
          FROM
            pa_pji_proj_events_log elog
          WHERE
            elog.EVENT_ID = p_event_id AND
            ROWNUM       <= 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN;
        END;

        --Identify if the project has shared/split
        --versioned/non-versioned structure
        l_struct_type :=
          Pa_Project_Structure_Utils.get_structure_sharing_code (l_project_id);

        IF l_struct_type LIKE 'SHARE%' THEN
          l_shared_flag := 'Y';
        ELSE
          l_shared_flag := 'N';
        END IF;

        l_versioned_flag :=
          Pa_Workplan_Attr_Utils.check_wp_versioning_enabled (l_project_id);

        SELECT
          DECODE (p_event_type, 'WBS_PUBLISH', 'Y', 'N')
        INTO
          l_publish_flag
        FROM dual;

         WBS_MAINT_PVT (
           p_event_id       => p_event_id,
           p_versioned_flag => l_versioned_flag,
           p_struct_type    => l_shared_flag,
           p_publish_flag   => l_publish_flag,
	   p_calling_context=>NULL,
	   p_deffered_mode  =>'N',
	   p_rerun_flag     => NULL,
           x_return_status  => l_return_status );

           x_return_status := l_return_status;
           l_processing_code := 'S';

       END IF;

    ELSIF p_event_type = 'PLAN_DELETE' THEN

      PLAN_DELETE_PVT ( p_event_id        => p_event_id,
                        x_processing_code => l_processing_code ,
                        x_return_status   => x_return_status);

    ELSIF p_event_type = 'PLAN_BASELINE' THEN

      PLAN_BASELINE_PVT ( p_event_id        => p_event_id,
                          x_processing_code => l_processing_code ,
                          x_return_status   => x_return_status);

    ELSIF p_event_type = 'PLAN_ORIGINAL' THEN

      PLAN_ORIGINAL_PVT ( p_event_id        => p_event_id,
                          x_processing_code => l_processing_code ,
                          x_return_status   => x_return_status);

    ELSIF p_event_type = 'PLAN_COPY' THEN

      PLAN_COPY_PVT ( p_event_id        => p_event_id,
                      x_processing_code => l_processing_code ,
                      x_return_status   => x_return_status);

    END IF; --end processing of event

    x_processing_code := l_processing_code;


EXCEPTION
  WHEN OTHERS THEN

    x_msg_data      := SQLERRM;

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PROCESS_EVENT_PVT'
    , x_return_status => x_return_status ) ;

    RAISE;
END;

PROCEDURE process_pending_plan_updates (
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2 )
IS

  l_processing_code VARCHAR2(1);

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  -- PLAN_UPDATE_PVT(
  --   x_processing_code => l_processing_code
  -- , x_return_status   => x_return_status );

EXCEPTION
  WHEN OTHERS THEN
    x_msg_data      := SQLERRM;
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PROCESS_PENDING_PLAN_UPDATES'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


---------------------------------------------------------------
--This API is called in the beginning of any report to ensure
--there are no pending event for the plan version
---------------------------------------------------------------
PROCEDURE process_plan_events (
  p_project_id          IN  NUMBER,
  p_plan_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
  x_processing_code     OUT NOCOPY  VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2 )
IS

  CURSOR c_pending_plan_events ( p_plan_version_id NUMBER)
  IS
  SELECT
    evt.EVENT_ID,
    evt.EVENT_TYPE
  FROM
    pa_pji_proj_events_log evt
  WHERE
    evt.EVENT_TYPE IN ( 'PLAN_DELETE',
                        'PLAN_BASELINE',
                        'PLAN_ORIGINAL',
                        'PLAN_COPY') AND
    evt.EVENT_OBJECT = to_char(p_plan_version_id)
  ORDER BY evt.EVENT_ID ASC;

  CURSOR c_pending_wbs_events ( p_plan_version_id NUMBER)
  IS
  SELECT
    evt.EVENT_ID,
    evt.EVENT_TYPE
  FROM
    pa_pji_proj_events_log evt,
    pji_pjp_wbs_header     head
  WHERE
    evt.EVENT_TYPE IN ( 'WBS_CHANGE',
                        'WBS_PUBLISH')         AND
    evt.EVENT_OBJECT     = to_char(head.WBS_VERSION_ID) AND
    head.PLAN_VERSION_ID = p_plan_version_id   AND
    to_char(head.PROJECT_ID )     = evt.ATTRIBUTE1      AND   --Bug 7591055
    to_char(head.plan_version_id) = evt.ATTRIBUTE3            --Bug 7591055
  ORDER BY evt.EVENT_ID ASC;


   l_child_task_check    NUMBER := 0;

   l_plan_version_id     NUMBER;

   l_child_exist     Boolean := TRUE; -- Added for bug 3899810
   l_wbs_version_id  NUMBER  := NULL; -- Added for bug 3899810

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );


  /* Begin :
      Bug# 3740751 - If child level task structure is not exists then raise the
                     error message   */


     /* Get the plan version which is from the table and check if any stcuture is exists */


/* Commented out for bug 3899810 skannoji
    IF  p_plan_version_id_tbl(1)  IS NOT NULL THEN

         l_plan_version_id  := p_plan_version_id_tbl(1);

    END IF;



   SELECT COUNT(*)
     INTO l_child_task_check
     FROM pa_xbs_denorm denom,
          pji_pjp_wbs_header headr
    WHERE denom.sup_project_id = p_project_id
      AND headr.project_id = denom.sup_project_id
      AND headr.plan_version_id = l_plan_version_id
      AND headr.wbs_version_id = denom.struct_version_id
      AND struct_type = 'XBS'
      AND ROWNUM =1;
*/


    -- Bug 3899810 : Added p_plan_version_id_tbl.count check
    IF  p_plan_version_id_tbl.count > 0  THEN -- Count if
     FOR i IN p_plan_version_id_tbl.first..p_plan_version_id_tbl.last LOOP
      l_plan_version_id  := NULL;

      IF  (  ( p_plan_version_id_tbl.EXISTS(i))
          ) THEN
           l_plan_version_id  := p_plan_version_id_tbl(i);

           l_child_task_check := 0;

	BEGIN
		l_wbs_version_id:=NULL;

		SELECT wbs_version_id INTO l_wbs_version_id
		FROM pji_pjp_wbs_header
		WHERE plan_version_id = l_plan_version_id
           	AND   project_id      = p_project_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		NULL;
	END;

         IF (l_wbs_version_id IS NOT NULL)
         THEN
           SELECT COUNT(*)
           INTO l_child_task_check
           FROM pa_object_relationships por
           WHERE  por.object_id_from1   = l_wbs_version_id
           AND    por.relationship_type = 'S'
           AND    rownum = 1;

            IF (l_child_task_check = 0)
            THEN
                   l_child_exist := FALSE;
            ELSE
                   l_child_exist := TRUE;
                   EXIT;
            END IF;
         END IF; -- execute only if plan version is not null

/* Commented for bug 3899810
           IF (NVL(l_child_task_check,0) <> 0 ) THEN
              EXIT;
           END IF;
*/
      END IF;

     END LOOP;
    /* till here for bug 3899810 */

     /* If structure not found for the lowest task then come out the procedure otherwies
        process further */

 --   IF (l_child_task_check = 0)  THEN
    IF (NOT l_child_exist)  THEN  -- added for bug 3899810 false

        pji_rep_util.Add_Message(p_app_short_name=> 'PJI',
                                 p_msg_name=> 'PJI_REP_NO_TASK_DEFINED',
                                 p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);


        RETURN;

    END IF;

   END IF; -- Added this Count end if for bug 3899810


      /* End Bug#3740751 */



  <<OUTER>>
  FOR i IN 1..p_plan_version_id_tbl.COUNT LOOP

    FOR rec IN c_pending_plan_events( p_plan_version_id_tbl(i)) LOOP

      proces_event_pvt (
        p_event_id        => rec.EVENT_ID,
        p_event_type      => rec.EVENT_TYPE,
        x_processing_code => x_processing_code,
        x_return_status   => x_return_status,
        x_msg_data        => x_msg_data );

      IF x_processing_code = 'F' THEN
        EXIT OUTER;
      END IF;
    END LOOP;

    --Logic for WBS events
    FOR rec IN c_pending_wbs_events( p_plan_version_id_tbl(i)) LOOP

      proces_event_pvt (
        p_event_id        => rec.EVENT_ID,
        p_event_type      => rec.EVENT_TYPE,
        x_processing_code => x_processing_code,
        x_return_status   => x_return_status,
        x_msg_data        => x_msg_data );

      IF x_processing_code = 'F' THEN
        EXIT OUTER;
      END IF;
    END LOOP;


  /*  PLAN_UPDATE_PVT
    (   p_plan_version_id      => p_plan_version_id_tbl(i),
        x_processing_code      => x_processing_code,
        x_return_status        => x_return_status  );*/

    IF x_processing_code = 'F' THEN
      EXIT;
    END IF;

  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    x_msg_data      := SQLERRM;
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PROCESS_PLAN_EVENTS'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


--
-- Create on demand slices.
--
PROCEDURE maintain_smart_slice (
		  p_rbs_version_id      IN  NUMBER :=NULL,
		  p_plan_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
		  p_wbs_element_id      IN  NUMBER,
		  p_rbs_element_id      IN  NUMBER,
		  p_prg_rollup_flag     IN  VARCHAR2,
		  p_curr_record_type_id IN  NUMBER,
		  p_calendar_type       IN  VARCHAR2,
                  p_wbs_version_id      IN  NUMBER,
                  p_commit              IN  VARCHAR2 := 'Y',
	          p_rbs_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
		  x_msg_count           OUT NOCOPY  NUMBER,
		  x_msg_data            OUT NOCOPY  VARCHAR2,
		  x_return_status       OUT NOCOPY  VARCHAR2) IS

  -- l_fact_act_rlp_exists  VARCHAR2(1) := 'N';
  -- l_rollup_status_exists VARCHAR2(1) := 'N';
  l_exists VARCHAR2(1) := 'N';
  l_struct_element_id NUMBER := -1;
  l_project_id NUMBER := 1;
  l_proj_element_ids SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_plan_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_plan_type_code_tbl SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
  l_project_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_wbs_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_count NUMBER := 1;

  l_last_update_date        date   := SYSDATE;
  l_last_updated_by         NUMBER := FND_GLOBAL.USER_ID;
  l_creation_date           date   := SYSDATE;
  l_created_by              NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login       NUMBER := FND_GLOBAL.LOGIN_ID;
  il_plan_version_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  il_plan_type_code_tbl   SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();     /*4471527 */
  il_project_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  il_wbs_version_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_prg_plan_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_prg_plan_type_code_tbl SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();     /*4471527 */
  l_prg_project_id_tbl      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_prg_wbs_version_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_prg_count NUMBER := 1;
  l_roll_wbs_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_get_wbs_version_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_get_plan_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_get_plan_type_code_tbl SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();    /*4471527 */
  l_wbs_count NUMBER:=2;
  l_wbs_exists NUMBER :=0;
  validcount NUMBER:=1;
  jl_get_plan_version_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();    /*4471527 */
  jl_get_plan_type_code_tbl   SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();     /*4471527 */
  jl_get_wbs_version_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();    /*4471527 */
    l_rbs_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
BEGIN

     Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
     ( p_package_name   => g_package_name
     , x_return_status  => x_return_status );
     /* overriding the parameter p_rbs_version_id for Public API with PLSQl table */
 IF    ( p_rbs_version_id is NOT NULL) THEN
       l_rbs_version_id_tbl.EXTEND;
       l_rbs_version_id_tbl(1) := p_rbs_version_id;
 else
      FOR i IN 1..p_rbs_version_id_tbl.COUNT LOOP
         l_rbs_version_id_tbl.EXTEND;
        l_rbs_version_id_tbl(i) := p_rbs_version_id_tbl(i);
	end loop;
 end if;

    IF g_debug_mode='Y' THEN
       -- write_log ( ' maintain smart slice .. 0001 :p_wbs_version_id'||p_wbs_version_id ||'p_rbs_version_id'||p_rbs_version_id||'p_prg_rollup_flag'||p_prg_rollup_flag);
       Pji_Utils.write2log('maintain smart slice .. 0001 :p_wbs_version_id'||p_wbs_version_id ||
       'p_rbs_version_id'||p_rbs_version_id||'p_prg_rollup_flag'||p_prg_rollup_flag,null,3);
    end if;
     IF (l_rbs_version_id_tbl.COUNT=0) THEN
        Pji_Utils.write2log('p_rbs_version_id is NULL. Nothing to rollup by. Returning.',null,3);
       RETURN;
     END IF;

     BEGIN
       SELECT
         PROJ_ELEMENT_ID, project_id
       INTO
         l_struct_element_id, l_project_id
       FROM
         pa_proj_element_versions
       WHERE
         ELEMENT_VERSION_ID = p_wbs_version_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           NULL;
     END;
/* Based on the input plan version id of the parent project getting all the corresponding wbs_version_ids */
      FOR i IN 1..p_plan_version_id_tbl.COUNT LOOP
         BEGIN
            select distinct head.wbs_version_id,head.plan_version_id,head.plan_type_code BULK COLLECT
            into  jl_get_wbs_version_id_tbl,jl_get_plan_version_id_tbl,jl_get_plan_type_code_tbl     /*4471527 */
            from pji_pjp_wbs_header head
            where head.plan_version_id = p_plan_version_id_tbl(i)
            and head.project_id in (select project_id from  pji_pjp_wbs_header head1
                                                 where head1.wbs_version_id=p_wbs_version_id );
              FOR j IN 1..jl_get_plan_version_id_tbl.COUNT LOOP
              	l_get_plan_version_id_tbl.EXTEND;
	l_get_plan_version_id_tbl(validcount) := jl_get_plan_version_id_tbl(j);
	l_get_plan_type_code_tbl.EXTEND;
 	l_get_plan_type_code_tbl(validcount) := jl_get_plan_type_code_tbl(j);
	l_get_wbs_version_id_tbl.EXTEND;
 	l_get_wbs_version_id_tbl(validcount) := jl_get_wbs_version_id_tbl(j);

              /*  l_get_plan_version_id_tbl.EXTEND;
                l_get_wbs_version_id_tbl.EXTEND;
                l_get_plan_type_code_tbl.EXTEND;
                l_get_wbs_version_id_tbl(validcount) :=l_get_wbs_version_id;
                l_get_plan_version_id_tbl(validcount):=p_plan_version_id_tbl(i);
                l_get_plan_type_code_tbl(validcount):=l_get_plan_type_code;    /*4471527 */
                             validcount:=validcount+1;
               END LOOP;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 NULL;
                 WHEN TOO_MANY_ROWS THEN
                  RAISE Invalid_excep;
              END;
           END LOOP;
          /* Converting the wbs_version_id to maxmimum allowed numbers to use in the below SQL */
	  FOR i IN 1..31 LOOP
             IF    ( l_get_wbs_version_id_tbl.EXISTS(i)) THEN
                   null;
             ELSE
               l_get_wbs_version_id_tbl.EXTEND;
               l_get_wbs_version_id_tbl(i) := 0;
            END IF;
        END LOOP;
	/* Getting all the sub-project linked plan_version ids , struct_version_ids,
	   and the project_ids for the Program Project when the the call is made in Program Mode */
        IF p_prg_rollup_flag='Y' THEN
           BEGIN
             SELECT distinct head.plan_version_id,head.project_id ,pji.sub_id wbs_version_id,head.plan_type_code  BULK COLLECT
             into  il_plan_version_id_tbl, il_project_id_tbl,il_wbs_version_id_tbl,il_plan_type_code_tbl    /*4471527 */
             FROM  pji_xbs_Denorm pji
               ,pa_proj_element_versions pa
               ,pji_pjp_wbs_header head
             WHERE pji.struct_type='PRG'
             and   pji.sup_level<>pji.sub_level
             and   pji.sup_id in (l_get_wbs_version_id_tbl(1),l_get_wbs_version_id_tbl(2),l_get_wbs_version_id_tbl(3)
                            ,l_get_wbs_version_id_tbl(4),l_get_wbs_version_id_tbl(5),l_get_wbs_version_id_tbl(6)
                            ,l_get_wbs_version_id_tbl(7),l_get_wbs_version_id_tbl(8),l_get_wbs_version_id_tbl(9)
                            ,l_get_wbs_version_id_tbl(10),l_get_wbs_version_id_tbl(11),l_get_wbs_version_id_tbl(12)
                            ,l_get_wbs_version_id_tbl(13),l_get_wbs_version_id_tbl(14),l_get_wbs_version_id_tbl(15)
                            ,l_get_wbs_version_id_tbl(16),l_get_wbs_version_id_tbl(17),l_get_wbs_version_id_tbl(18)
                            ,l_get_wbs_version_id_tbl(19),l_get_wbs_version_id_tbl(20),l_get_wbs_version_id_tbl(21)
                            ,l_get_wbs_version_id_tbl(22),l_get_wbs_version_id_tbl(23),l_get_wbs_version_id_tbl(24)
                            ,l_get_wbs_version_id_tbl(25),l_get_wbs_version_id_tbl(26),l_get_wbs_version_id_tbl(27)
                            ,l_get_wbs_version_id_tbl(28),l_get_wbs_version_id_tbl(29),l_get_wbs_version_id_tbl(30)
                            ,l_get_wbs_version_id_tbl(31))
           and   pa.ELEMENT_VERSION_ID=pji.SUB_ID
           AND   head.project_id=pa.project_id
           AND   pji.sub_id=head.wbs_version_id
           and   (head.cb_flag='Y'
                  OR head.co_flag='Y'
                  OR head.wp_flag='Y'
                  OR (head.wp_flag='N' and head.plan_version_id=-1)
                 );
         EXCEPTION
	    WHEN NO_DATA_FOUND THEN Null;
            WHEN OTHERS THEN
             RAISE Invalid_excep;
         END;
       END IF;
       /* Adding the two PLSQL table to one which will be used as the final plsql table for processing,
          l_prg_plan_version_id_tbl=l_get_plan_version_id_tbl+ il_plan_version_id_tbl*/
       FOR i IN 1..l_get_plan_version_id_tbl.COUNT LOOP
          l_prg_plan_version_id_tbl.EXTEND;
          l_prg_plan_version_id_tbl(l_prg_count) := l_get_plan_version_id_tbl(i);

          l_prg_plan_type_code_tbl.EXTEND;
          l_prg_plan_type_code_tbl(l_prg_count) := l_get_plan_type_code_tbl(i);

          l_prg_wbs_version_id_tbl.EXTEND;
          l_prg_wbs_version_id_tbl(l_prg_count) := l_get_wbs_version_id_tbl(i);

          l_prg_project_id_tbl.EXTEND;
          l_prg_project_id_tbl(l_prg_count) := l_project_id;
          IF g_debug_mode='Y' THEN
           Pji_Utils.write2log(' maintain smart slice11: '||l_prg_count||':l_prg_plan_version_id_tbl'||
           l_prg_plan_version_id_tbl(l_prg_count)||'l_prg_wbs_version_id_tbl'||l_prg_wbs_version_id_tbl(l_prg_count)||
           'l_prg_project_id_tbl'||l_prg_project_id_tbl(l_prg_count) ,null,3);
          end if;
          l_prg_count := l_prg_count + 1;
       END LOOP;

       FOR i IN 1..il_plan_version_id_tbl.COUNT LOOP
          l_prg_plan_version_id_tbl.EXTEND;
          l_prg_plan_version_id_tbl(l_prg_count) := il_plan_version_id_tbl(i);

          l_prg_plan_type_code_tbl.EXTEND;
          l_prg_plan_type_code_tbl(l_prg_count) := il_plan_type_code_tbl(i);

          l_prg_wbs_version_id_tbl.EXTEND;
          l_prg_wbs_version_id_tbl(l_prg_count) := il_wbs_version_id_tbl(i);

          l_prg_project_id_tbl.EXTEND;
          l_prg_project_id_tbl(l_prg_count) := il_project_id_tbl(i);
          IF g_debug_mode='Y' THEN
            Pji_Utils.write2log(' maintain smart slice11: '||l_prg_count||':l_prg_plan_version_id_tbl'||
         l_prg_plan_version_id_tbl(l_prg_count)||'l_prg_wbs_version_id_tbl'||l_prg_wbs_version_id_tbl(l_prg_count)||
         'l_prg_project_id_tbl'||l_prg_project_id_tbl(l_prg_count) ,null,3);
          end if;
          l_prg_count := l_prg_count + 1;
        END LOOP;
      /* For the list of Plan versions checking the rollup table to see if the smart slice is already created */
       FOR k IN 1..l_rbs_version_id_tbl.COUNT LOOP
       FOR i IN 1..l_prg_plan_version_id_tbl.COUNT LOOP

         -- Reset flag values.
         -- l_rollup_status_exists := 'N';
         l_exists               := 'N';

	   BEGIN

           SELECT 'Y' -- , 'Y'
           INTO   l_exists -- , l_rollup_status_exists
           FROM   pji_rollup_level_status rst
           WHERE  rst.RBS_VERSION_ID  = l_rbs_version_id_tbl(k) AND
     	            rst.PLAN_VERSION_ID = l_prg_plan_version_id_tbl(i) AND
                         rst.PLAN_TYPE_CODE = l_prg_plan_type_code_tbl(i) AND
                  rst.project_id = l_prg_project_id_tbl(i);

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             NULL;
         END;
         IF g_debug_mode='Y' THEN
	    Pji_Utils.write2log(' maintain smart slice ..1.2 p_plan_version_id_tbl ('||i||') : ' || l_prg_plan_version_id_tbl(i) ,null,3);
	    Pji_Utils.write2log(' maintain smart slice ..1.3 l_exists :' || l_exists ,null,3);
         end if;

	 --If smart slice does not exist create the same
         IF ( l_exists = 'N' ) THEN
           l_plan_version_id_tbl.EXTEND;
           l_plan_version_id_tbl(l_count) := l_prg_plan_version_id_tbl(i);
           l_plan_type_code_tbl.EXTEND;
           l_plan_type_code_tbl(l_count) := l_prg_plan_type_code_tbl(i);
           l_project_id_tbl.EXTEND;
           l_project_id_tbl(l_count) := l_prg_project_id_tbl(i);
           l_wbs_version_id_tbl.EXTEND;
           l_wbs_version_id_tbl(l_count) := l_prg_wbs_version_id_tbl(i);
           IF g_debug_mode='Y' THEN
             Pji_Utils.write2log(' maintain smart slice44: '||l_count||':l_plan_version_id_tbl'||l_plan_version_id_tbl(l_count)||'l_wbs_version_id_tbl'
                   ||l_wbs_version_id_tbl(l_count)||'l_project_id_tbl'||l_project_id_tbl(l_count) ,null,3);
           end if;
           l_count := l_count + 1;

           --Populate rollup level status table
           INSERT INTO pji_rollup_level_status  (
              PROJECT_ID,
              RBS_VERSION_ID,
              PLAN_VERSION_ID,
              WBS_ELEMENT_ID,
              RBS_AGGR_LEVEL,
              WBS_ROLLUP_FLAG,
              PRG_ROLLUP_FLAG,
              CURR_RECORD_TYPE_ID,
              CALENDAR_TYPE,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
             PLAN_TYPE_CODE    /*4471527 */
           )
           SELECT
              l_prg_project_id_tbl(i)        project_id,
              l_rbs_version_id_tbl(k)         RBS_VERSION_ID,
              l_prg_plan_version_id_tbl(i) PLAN_VERSION_ID,
              -1                       WBS_ELEMENT_ID,
              'R'                      RBS_AGGR_LEVEL,
              'Y'                      WBS_ROLLUP_FLAG,
              'N'                      PRG_ROLLUP_FLAG,
              31                       CURR_RECORD_TYPE_ID,
              'X'                      CALENDAR_TYPE,
              l_last_update_date       LAST_UPDATE_DATE,
              l_last_updated_by        LAST_UPDATED_BY,
              l_creation_date          CREATION_DATE,
              l_created_by             CREATED_BY,
              l_last_update_login      LAST_UPDATE_LOGIN,
              l_prg_plan_type_code_tbl(i) PLAN_TYPE_CODE   /*4471527  */
           FROM dual;

         END IF;

     END LOOP;
    END LOOP; /* En dof K loop  for RBS version_id*/
   -- This code will remove all the duplicate entries from l_wbs_version_id_tbl which will be used to do the WBS and XBS rollup
     BEGIN
       FOR j IN 1..l_wbs_version_id_tbl.COUNT LOOP
	   if j=1 then
   	      l_roll_wbs_version_id_tbl.EXTEND;
	      l_roll_wbs_version_id_tbl(j) := l_wbs_version_id_tbl(j);
	   end if;
	   FOR i IN 1..l_roll_wbs_version_id_tbl.COUNT LOOP
	       if  l_roll_wbs_version_id_tbl(i) = l_wbs_version_id_tbl(j)
	       and j>1 then
   		   l_wbs_exists:=1;
		   exit;
	       else
		  l_wbs_exists:=0;
 	       END IF;
	   END LOOP;
	   IF l_wbs_exists <>1 and j<>1 THEN
	      l_roll_wbs_version_id_tbl.EXTEND;
	      l_roll_wbs_version_id_tbl(l_wbs_count) := l_wbs_version_id_tbl(j);
	      l_wbs_count := l_wbs_count + 1;
	   END IF;
       END LOOP;
     END;

     CLEANUP_TEMP_TABLES;

     PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS(
       p_fp_version_ids    => l_plan_version_id_tbl
     , p_slice_type        => 'PRI'
     );
     IF g_debug_mode='Y' THEN
        Pji_Utils.write2log(' maintain smart slice44.02:PJI_FM_PLAN_MAINT_T_PVT.EXTRACT_FIN_PLAN_VERSIONS' ,null,3);
     end if;

    IF g_debug_mode='Y' THEN
       Pji_Utils.write2log(' maintain smart slice55:l_plan_version_id_tbl.COUNT: '||l_plan_version_id_tbl.COUNT||
                          '::l_roll_wbs_version_id_tbl.COUNT: '||l_roll_wbs_version_id_tbl.COUNT  ,null,3);
    end if;
     --Inserting 'L' 'N' 'N' / 'L' 'N' 'Y' slices
    FOR k IN 1..l_rbs_version_id_tbl.COUNT LOOP
     FORALL j IN 1..l_plan_version_id_tbl.COUNT

        INSERT INTO pji_fp_aggr_pjp1_t (
          WORKER_ID,
          PRG_LEVEL,
	  PROJECT_ID,
	  PROJECT_ORG_ID,
	  PROJECT_ORGANIZATION_ID,
	  PROJECT_ELEMENT_ID,
	  TIME_ID, PERIOD_TYPE_ID,
	  CALENDAR_TYPE,
	  RBS_AGGR_LEVEL,
	  WBS_ROLLUP_FLAG,
	  PRG_ROLLUP_FLAG,
	  CURR_RECORD_TYPE_ID,
	  CURRENCY_CODE,
	  RBS_ELEMENT_ID,
	  RBS_VERSION_ID,
	  PLAN_VERSION_ID,
	  PLAN_TYPE_ID,
	  RAW_COST,
	  BRDN_COST,
	  REVENUE,
	  BILL_RAW_COST,
	  BILL_BRDN_COST,
	  BILL_LABOR_RAW_COST,
	  BILL_LABOR_BRDN_COST,
	  BILL_LABOR_HRS,
	  EQUIPMENT_RAW_COST,
	  EQUIPMENT_BRDN_COST,
	  CAPITALIZABLE_RAW_COST,
	  CAPITALIZABLE_BRDN_COST,
	  LABOR_RAW_COST,
	  LABOR_BRDN_COST,
	  LABOR_HRS,
	  LABOR_REVENUE,
	  EQUIPMENT_HOURS,
	  BILLABLE_EQUIPMENT_HOURS,
	  SUP_INV_COMMITTED_COST,
	  PO_COMMITTED_COST,
	  PR_COMMITTED_COST,
	  OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
	  ACT_EQUIP_HRS,
	  ACT_LABOR_BRDN_COST,
	  ACT_EQUIP_BRDN_COST,
	  ACT_BRDN_COST,
	  ACT_RAW_COST,
	  ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
	  ETC_LABOR_HRS,
	  ETC_EQUIP_HRS,
	  ETC_LABOR_BRDN_COST,
	  ETC_EQUIP_BRDN_COST,
	  ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15 ,
          PLAN_TYPE_CODE)    /*4471527  */
    SELECT
          -1,
          0,
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  fact.PROJECT_ELEMENT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  fact.RBS_AGGR_LEVEL,
	  fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  fact.RBS_ELEMENT_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
	  fact.RAW_COST,
	  fact.BRDN_COST,
	  fact.REVENUE,
	  fact.BILL_RAW_COST,
	  fact.BILL_BRDN_COST,
	  fact.BILL_LABOR_RAW_COST,
	  fact.BILL_LABOR_BRDN_COST,
	  fact.BILL_LABOR_HRS,
	  fact.EQUIPMENT_RAW_COST,
	  fact.EQUIPMENT_BRDN_COST,
	  fact.CAPITALIZABLE_RAW_COST,
	  fact.CAPITALIZABLE_BRDN_COST,
	  fact.LABOR_RAW_COST,
	  fact.LABOR_BRDN_COST,
	  fact.LABOR_HRS,
	  fact.LABOR_REVENUE,
	  fact.EQUIPMENT_HOURS,
	  fact.BILLABLE_EQUIPMENT_HOURS,
	  fact.SUP_INV_COMMITTED_COST,
	  fact.PO_COMMITTED_COST,
	  fact.PR_COMMITTED_COST,
	  fact.OTH_COMMITTED_COST,
          fact.ACT_LABOR_HRS,
	  fact.ACT_EQUIP_HRS,
	  fact.ACT_LABOR_BRDN_COST,
	  fact.ACT_EQUIP_BRDN_COST,
	  fact.ACT_BRDN_COST,
	  fact.ACT_RAW_COST,
	  fact.ACT_REVENUE,
          fact.ACT_LABOR_RAW_COST,
          fact.ACT_EQUIP_RAW_COST,
	  fact.ETC_LABOR_HRS,
	  fact.ETC_EQUIP_HRS,
	  fact.ETC_LABOR_BRDN_COST,
	  fact.ETC_EQUIP_BRDN_COST,
	  fact.ETC_BRDN_COST,
          fact.ETC_RAW_COST,
          fact.ETC_LABOR_RAW_COST,
          fact.ETC_EQUIP_RAW_COST,
          fact.CUSTOM1,
          fact.CUSTOM2,
          fact.CUSTOM3,
          fact.CUSTOM4,
          fact.CUSTOM5,
          fact.CUSTOM6,
          fact.CUSTOM7,
          fact.CUSTOM8,
          fact.CUSTOM9,
          fact.CUSTOM10,
          fact.CUSTOM11,
          fact.CUSTOM12,
          fact.CUSTOM13,
          fact.CUSTOM14,
          fact.CUSTOM15,
          fact.PLAN_TYPE_CODE    /*4471527 */
        FROM
	  pji_fp_xbs_accum_f fact,
	  pji_pjp_wbs_header head
	WHERE
	  fact.RBS_AGGR_LEVEL          = 'L'               AND
          fact.WBS_ROLLUP_FLAG         = 'N'               AND
	  fact.PRG_ROLLUP_FLAG         in ('Y', 'N')       AND
	  fact.PROJECT_ID              = head.PROJECT_ID   AND
	  fact.PLAN_VERSION_ID         = head.PLAN_VERSION_ID AND
               fact.PLAN_TYPE_CODE       = head.PLAN_TYPE_CODE  AND   /*4471527  */
	  decode(fact.PLAN_VERSION_ID,
	         -3, fact.PLAN_TYPE_ID,
	         -4, fact.PLAN_TYPE_ID,
	         -1)                   = decode(fact.PLAN_VERSION_ID,
	                                        -3, head.PLAN_TYPE_ID,
	                                        -4, head.PLAN_TYPE_ID,
	                                        -1)        AND
	  head.WBS_VERSION_ID          = l_wbs_version_id_tbl(j)  AND
                                head.project_id              = l_project_id_tbl(j)       AND
                                fact.rbs_version_id          = l_rbs_version_id_tbl(k)   AND
	  head.PLAN_VERSION_ID         = l_plan_version_id_tbl(j)  AND
	  head.PLAN_TYPE_CODE         = l_plan_type_code_tbl(j)  ;
   END LOOP;/* end of RBS loop*/

        IF g_debug_mode='Y' THEN
           Pji_Utils.write2log(' Inserted L N N / L N Y slices ' || SQL%ROWCOUNT ,null,3);
         end if;

        --WBS rollup for LNN / LNY slices
	FORALL j IN 1..l_roll_wbs_version_id_tbl.COUNT
	INSERT INTO pji_fp_aggr_pjp1_t (
          WORKER_ID,
          PRG_LEVEL,
	  PROJECT_ID,
	  PROJECT_ORG_ID,
	  PROJECT_ORGANIZATION_ID,
	  PROJECT_ELEMENT_ID,
	  TIME_ID,
	  PERIOD_TYPE_ID,
	  CALENDAR_TYPE,
	  RBS_AGGR_LEVEL,
	  WBS_ROLLUP_FLAG,
	  PRG_ROLLUP_FLAG,
	  CURR_RECORD_TYPE_ID,
	  CURRENCY_CODE,
	  RBS_ELEMENT_ID,
	  RBS_VERSION_ID,
	  PLAN_VERSION_ID,
	  PLAN_TYPE_ID,
	  RAW_COST,
	  BRDN_COST,
	  REVENUE,
	  BILL_RAW_COST,
	  BILL_BRDN_COST,
	  BILL_LABOR_RAW_COST,
	  BILL_LABOR_BRDN_COST,
	  BILL_LABOR_HRS,
	  EQUIPMENT_RAW_COST,
	  EQUIPMENT_BRDN_COST,
	  CAPITALIZABLE_RAW_COST,
	  CAPITALIZABLE_BRDN_COST,
	  LABOR_RAW_COST,
	  LABOR_BRDN_COST,
	  LABOR_HRS,
	  LABOR_REVENUE,
	  EQUIPMENT_HOURS,
	  BILLABLE_EQUIPMENT_HOURS,
	  SUP_INV_COMMITTED_COST,
	  PO_COMMITTED_COST,
	  PR_COMMITTED_COST,
	  OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
	  ACT_EQUIP_HRS,
	  ACT_LABOR_BRDN_COST,
	  ACT_EQUIP_BRDN_COST,
	  ACT_BRDN_COST,
	  ACT_RAW_COST,
	  ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
	  ETC_LABOR_HRS,
	  ETC_EQUIP_HRS,
	  ETC_LABOR_BRDN_COST,
	  ETC_EQUIP_BRDN_COST,
	  ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15,
          PLAN_TYPE_CODE )   /*4471527 */
	SELECT /*+ ORDERED INDEX(XBS PJI_XBS_DENORM_N2) */
	  1,
	  0,
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  xbs.SUP_EMT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  fact.RBS_AGGR_LEVEL,
	  'Y', --fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  fact.RBS_ELEMENT_ID,--	   rbs.SUP_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
	  SUM(fact.RAW_COST),
	  SUM(fact.BRDN_COST),
	  SUM(fact.REVENUE),
	  SUM(fact.BILL_RAW_COST),
	  SUM(fact.BILL_BRDN_COST),
	  SUM(fact.BILL_LABOR_RAW_COST),
	  SUM(fact.BILL_LABOR_BRDN_COST),
	  SUM(fact.BILL_LABOR_HRS),
	  SUM(fact.EQUIPMENT_RAW_COST),
	  SUM(fact.EQUIPMENT_BRDN_COST),
	  SUM(fact.CAPITALIZABLE_RAW_COST),
	  SUM(fact.CAPITALIZABLE_BRDN_COST),
	  SUM(fact.LABOR_RAW_COST),
	  SUM(fact.LABOR_BRDN_COST),
	  SUM(fact.LABOR_HRS),
	  SUM(fact.LABOR_REVENUE),
	  SUM(fact.EQUIPMENT_HOURS),
	  SUM(fact.BILLABLE_EQUIPMENT_HOURS),
	  SUM(fact.SUP_INV_COMMITTED_COST),
	  SUM(fact.PO_COMMITTED_COST),
	  SUM(fact.PR_COMMITTED_COST),
	  SUM(fact.OTH_COMMITTED_COST),
          SUM(fact.ACT_LABOR_HRS ),
	  SUM(fact.ACT_EQUIP_HRS ),
	  SUM(fact.ACT_LABOR_BRDN_COST ),
	  SUM(fact.ACT_EQUIP_BRDN_COST ),
	  SUM(fact.ACT_BRDN_COST ),
	  SUM(fact.ACT_RAW_COST ),
	  SUM(fact.ACT_REVENUE ),
          SUM(fact.ACT_LABOR_RAW_COST),
          SUM(fact.ACT_EQUIP_RAW_COST),
	  SUM(fact.ETC_LABOR_HRS ),
	  SUM(fact.ETC_EQUIP_HRS ),
	  SUM(fact.ETC_LABOR_BRDN_COST ),
	  SUM(fact.ETC_EQUIP_BRDN_COST ),
	  SUM(fact.ETC_BRDN_COST ),
          SUM(fact.ETC_RAW_COST ),
          SUM(fact.ETC_LABOR_RAW_COST),
          SUM(fact.ETC_EQUIP_RAW_COST),
          SUM(fact.CUSTOM1),
          SUM(fact.CUSTOM2),
          SUM(fact.CUSTOM3),
          SUM(fact.CUSTOM4),
          SUM(fact.CUSTOM5),
          SUM(fact.CUSTOM6),
          SUM(fact.CUSTOM7),
          SUM(fact.CUSTOM8),
          SUM(fact.CUSTOM9),
          SUM(fact.CUSTOM10),
          SUM(fact.CUSTOM11),
          SUM(fact.CUSTOM12),
          SUM(fact.CUSTOM13),
          SUM(fact.CUSTOM14),
          SUM(fact.CUSTOM15),
          fact.PLAN_TYPE_CODE     /*4471527 */
	FROM
	  pji_fp_aggr_pjp1_t fact,
	  pji_pjp_wbs_header head,
	  pji_xbs_denorm xbs
	WHERE
	  xbs.STRUCT_VERSION_ID = head.WBS_VERSION_ID AND
	  xbs.STRUCT_TYPE       = 'WBS'            AND
	  xbs.SUP_LEVEL        <> xbs.SUB_LEVEL    AND
	  xbs.SUB_EMT_ID        = fact.PROJECT_ELEMENT_ID AND
	  fact.PROJECT_ID              = head.PROJECT_ID   AND
	  fact.PLAN_VERSION_ID         = head.PLAN_VERSION_ID AND
               fact.PLAN_TYPE_CODE        = head.PLAN_TYPE_CODE AND     /*4471527 */
	  head.WBS_VERSION_ID          = l_roll_wbs_version_id_tbl(j)  AND
	  decode(fact.PLAN_VERSION_ID,
	         -3, fact.PLAN_TYPE_ID,
	         -4, fact.PLAN_TYPE_ID,
	         -1)                   = decode(fact.PLAN_VERSION_ID,
	                                        -3, head.PLAN_TYPE_ID,
	                                        -4, head.PLAN_TYPE_ID,
                                                -1)
	GROUP BY
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  xbs.SUP_EMT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  fact.RBS_AGGR_LEVEL,
	  'Y', --fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  fact.RBS_ELEMENT_ID,--	   rbs.SUP_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
               fact.PLAN_TYPE_CODE;    /*4471527 */


	 IF g_debug_mode='Y' THEN
           Pji_Utils.write2log(' Inserted WBS rollup L N N / L N Y slices ' || SQL%ROWCOUNT ,null,3);
        end if;

        --XBS Rollup for WBS slice
	FORALL j IN 1..l_roll_wbs_version_id_tbl.COUNT
        INSERT INTO pji_fp_aggr_pjp1_t (
          WORKER_ID,
          PRG_LEVEL,
	  PROJECT_ID,
	  PROJECT_ORG_ID,
	  PROJECT_ORGANIZATION_ID,
	  PROJECT_ELEMENT_ID,
	  TIME_ID,
	  PERIOD_TYPE_ID,
	  CALENDAR_TYPE,
	  RBS_AGGR_LEVEL,
	  WBS_ROLLUP_FLAG,
	  PRG_ROLLUP_FLAG,
	  CURR_RECORD_TYPE_ID,
	  CURRENCY_CODE,
	  RBS_ELEMENT_ID,
	  RBS_VERSION_ID,
	  PLAN_VERSION_ID,
	  PLAN_TYPE_ID,
	  RAW_COST,
	  BRDN_COST,
	  REVENUE,
	  BILL_RAW_COST,
	  BILL_BRDN_COST,
	  BILL_LABOR_RAW_COST,
	  BILL_LABOR_BRDN_COST,
	  BILL_LABOR_HRS,
	  EQUIPMENT_RAW_COST,
	  EQUIPMENT_BRDN_COST,
	  CAPITALIZABLE_RAW_COST,
	  CAPITALIZABLE_BRDN_COST,
	  LABOR_RAW_COST,
	  LABOR_BRDN_COST,
	  LABOR_HRS,
	  LABOR_REVENUE,
	  EQUIPMENT_HOURS,
	  BILLABLE_EQUIPMENT_HOURS,
	  SUP_INV_COMMITTED_COST,
	  PO_COMMITTED_COST,
	  PR_COMMITTED_COST,
	  OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
	  ACT_EQUIP_HRS,
	  ACT_LABOR_BRDN_COST,
	  ACT_EQUIP_BRDN_COST,
	  ACT_BRDN_COST,
	  ACT_RAW_COST,
	  ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
	  ETC_LABOR_HRS,
	  ETC_EQUIP_HRS,
	  ETC_LABOR_BRDN_COST,
	  ETC_EQUIP_BRDN_COST,
	  ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15,
          PLAN_TYPE_CODE )   /*4471527 */
	SELECT /*+ ORDERED INDEX(XBS PJI_XBS_DENORM_N2) */
	  1,
	  0,
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  xbs.SUP_EMT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  fact.RBS_AGGR_LEVEL,
	  'Y', --fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  fact.RBS_ELEMENT_ID,--	   rbs.SUP_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
	  SUM(fact.RAW_COST),
	  SUM(fact.BRDN_COST),
	  SUM(fact.REVENUE),
	  SUM(fact.BILL_RAW_COST),
	  SUM(fact.BILL_BRDN_COST),
	  SUM(fact.BILL_LABOR_RAW_COST),
	  SUM(fact.BILL_LABOR_BRDN_COST),
	  SUM(fact.BILL_LABOR_HRS),
	  SUM(fact.EQUIPMENT_RAW_COST),
	  SUM(fact.EQUIPMENT_BRDN_COST),
	  SUM(fact.CAPITALIZABLE_RAW_COST),
	  SUM(fact.CAPITALIZABLE_BRDN_COST),
	  SUM(fact.LABOR_RAW_COST),
	  SUM(fact.LABOR_BRDN_COST),
	  SUM(fact.LABOR_HRS),
	  SUM(fact.LABOR_REVENUE),
	  SUM(fact.EQUIPMENT_HOURS),
	  SUM(fact.BILLABLE_EQUIPMENT_HOURS),
	  SUM(fact.SUP_INV_COMMITTED_COST),
	  SUM(fact.PO_COMMITTED_COST),
	  SUM(fact.PR_COMMITTED_COST),
	  SUM(fact.OTH_COMMITTED_COST),
          SUM(fact.ACT_LABOR_HRS ),
	  SUM(fact.ACT_EQUIP_HRS ),
	  SUM(fact.ACT_LABOR_BRDN_COST ),
	  SUM(fact.ACT_EQUIP_BRDN_COST ),
	  SUM(fact.ACT_BRDN_COST ),
	  SUM(fact.ACT_RAW_COST ),
	  SUM(fact.ACT_REVENUE ),
          SUM(fact.ACT_LABOR_RAW_COST),
          SUM(fact.ACT_EQUIP_RAW_COST),
	  SUM(fact.ETC_LABOR_HRS ),
	  SUM(fact.ETC_EQUIP_HRS ),
	  SUM(fact.ETC_LABOR_BRDN_COST ),
	  SUM(fact.ETC_EQUIP_BRDN_COST ),
	  SUM(fact.ETC_BRDN_COST ),
          SUM(fact.ETC_RAW_COST ),
          SUM(fact.ETC_LABOR_RAW_COST),
          SUM(fact.ETC_EQUIP_RAW_COST),
          SUM(fact.CUSTOM1),
          SUM(fact.CUSTOM2),
          SUM(fact.CUSTOM3),
          SUM(fact.CUSTOM4),
          SUM(fact.CUSTOM5),
          SUM(fact.CUSTOM6),
          SUM(fact.CUSTOM7),
          SUM(fact.CUSTOM8),
          SUM(fact.CUSTOM9),
          SUM(fact.CUSTOM10),
          SUM(fact.CUSTOM11),
          SUM(fact.CUSTOM12),
          SUM(fact.CUSTOM13),
          SUM(fact.CUSTOM14),
          SUM(fact.CUSTOM15),
          fact.PLAN_TYPE_CODE    /*4471527 */
	FROM
	  pji_fp_aggr_pjp1_t fact,
	  pji_pjp_wbs_header head,
	  pji_xbs_denorm xbs

	WHERE
	  xbs.STRUCT_VERSION_ID = head.WBS_VERSION_ID AND
	  xbs.STRUCT_TYPE       = 'XBS'            AND
	  xbs.SUP_LEVEL        <> xbs.SUB_LEVEL    AND
	  xbs.SUB_EMT_ID        = fact.PROJECT_ELEMENT_ID AND
	  fact.PROJECT_ID              = head.PROJECT_ID   AND
	  fact.PLAN_VERSION_ID         = head.PLAN_VERSION_ID AND
               fact.PLAN_TYPE_CODE         = head.PLAN_TYPE_CODE  AND   /*4471527 */
	  head.WBS_VERSION_ID          = l_roll_wbs_version_id_tbl(j)  AND
	  decode(fact.PLAN_VERSION_ID,
	         -3, fact.PLAN_TYPE_ID,
	         -4, fact.PLAN_TYPE_ID,
	         -1)                   = decode(fact.PLAN_VERSION_ID,
	                                        -3, head.PLAN_TYPE_ID,
	                                        -4, head.PLAN_TYPE_ID,
                                                -1)
	GROUP BY
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  xbs.SUP_EMT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  fact.RBS_AGGR_LEVEL,
	  'Y', --fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  fact.RBS_ELEMENT_ID,--	   rbs.SUP_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
               fact.PLAN_TYPE_CODE;      /*4471527 */



         IF g_debug_mode='Y' THEN
           Pji_Utils.write2log(' Inserted XBS rollup for WBS slices ' || SQL%ROWCOUNT ,null,3);
         end if;
	--RBS Rollup for all slices
	FORALL j IN 1..l_rbs_version_id_tbl.COUNT
	INSERT INTO pji_fp_aggr_pjp1_t (
          WORKER_ID,
          PRG_LEVEL,
	  PROJECT_ID,
	  PROJECT_ORG_ID,
	  PROJECT_ORGANIZATION_ID,
	  PROJECT_ELEMENT_ID,
	  TIME_ID,
	  PERIOD_TYPE_ID,
	  CALENDAR_TYPE,
	  RBS_AGGR_LEVEL,
	  WBS_ROLLUP_FLAG,
	  PRG_ROLLUP_FLAG,
	  CURR_RECORD_TYPE_ID,
	  CURRENCY_CODE,
	  RBS_ELEMENT_ID,
	  RBS_VERSION_ID,
	  PLAN_VERSION_ID,
	  PLAN_TYPE_ID,
	  RAW_COST,
	  BRDN_COST,
	  REVENUE,
	  BILL_RAW_COST,
	  BILL_BRDN_COST,
	  BILL_LABOR_RAW_COST,
	  BILL_LABOR_BRDN_COST,
	  BILL_LABOR_HRS,
	  EQUIPMENT_RAW_COST,
	  EQUIPMENT_BRDN_COST,
	  CAPITALIZABLE_RAW_COST,
	  CAPITALIZABLE_BRDN_COST,
	  LABOR_RAW_COST,
	  LABOR_BRDN_COST,
	  LABOR_HRS,
	  LABOR_REVENUE,
	  EQUIPMENT_HOURS,
	  BILLABLE_EQUIPMENT_HOURS,
	  SUP_INV_COMMITTED_COST,
	  PO_COMMITTED_COST,
	  PR_COMMITTED_COST,
	  OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
	  ACT_EQUIP_HRS,
	  ACT_LABOR_BRDN_COST,
	  ACT_EQUIP_BRDN_COST,
	  ACT_BRDN_COST,
	  ACT_RAW_COST,
	  ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
	  ETC_LABOR_HRS,
	  ETC_EQUIP_HRS,
	  ETC_LABOR_BRDN_COST,
	  ETC_EQUIP_BRDN_COST,
	  ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15,
          PLAN_TYPE_CODE  )    /*4471527 */
	SELECT
	  1,
	  0,
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  fact.PROJECT_ELEMENT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  'R', --fact.RBS_AGGR_LEVEL,
	  fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  rbs.SUP_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
	  SUM(fact.RAW_COST),
	  SUM(fact.BRDN_COST),
	  SUM(fact.REVENUE),
	  SUM(fact.BILL_RAW_COST),
	  SUM(fact.BILL_BRDN_COST),
	  SUM(fact.BILL_LABOR_RAW_COST),
	  SUM(fact.BILL_LABOR_BRDN_COST),
	  SUM(fact.BILL_LABOR_HRS),
	  SUM(fact.EQUIPMENT_RAW_COST),
	  SUM(fact.EQUIPMENT_BRDN_COST),
	  SUM(fact.CAPITALIZABLE_RAW_COST),
	  SUM(fact.CAPITALIZABLE_BRDN_COST),
	  SUM(fact.LABOR_RAW_COST),
	  SUM(fact.LABOR_BRDN_COST),
	  SUM(fact.LABOR_HRS),
	  SUM(fact.LABOR_REVENUE),
	  SUM(fact.EQUIPMENT_HOURS),
	  SUM(fact.BILLABLE_EQUIPMENT_HOURS),
	  SUM(fact.SUP_INV_COMMITTED_COST),
	  SUM(fact.PO_COMMITTED_COST),
	  SUM(fact.PR_COMMITTED_COST),
	  SUM(fact.OTH_COMMITTED_COST),
          SUM(fact.ACT_LABOR_HRS ),
	  SUM(fact.ACT_EQUIP_HRS ),
	  SUM(fact.ACT_LABOR_BRDN_COST ),
	  SUM(fact.ACT_EQUIP_BRDN_COST ),
	  SUM(fact.ACT_BRDN_COST ),
	  SUM(fact.ACT_RAW_COST ),
	  SUM(fact.ACT_REVENUE ),
          SUM(fact.ACT_LABOR_RAW_COST),
          SUM(fact.ACT_EQUIP_RAW_COST),
	  SUM(fact.ETC_LABOR_HRS ),
	  SUM(fact.ETC_EQUIP_HRS ),
	  SUM(fact.ETC_LABOR_BRDN_COST ),
	  SUM(fact.ETC_EQUIP_BRDN_COST ),
	  SUM(fact.ETC_BRDN_COST ),
          SUM(fact.ETC_RAW_COST ),
          SUM(fact.ETC_LABOR_RAW_COST),
          SUM(fact.ETC_EQUIP_RAW_COST),
          SUM(fact.CUSTOM1),
          SUM(fact.CUSTOM2),
          SUM(fact.CUSTOM3),
          SUM(fact.CUSTOM4),
          SUM(fact.CUSTOM5),
          SUM(fact.CUSTOM6),
          SUM(fact.CUSTOM7),
          SUM(fact.CUSTOM8),
          SUM(fact.CUSTOM9),
          SUM(fact.CUSTOM10),
          SUM(fact.CUSTOM11),
          SUM(fact.CUSTOM12),
          SUM(fact.CUSTOM13),
          SUM(fact.CUSTOM14),
          SUM(fact.CUSTOM15),
          fact.PLAN_TYPE_CODE    /*4471527 */
	FROM
	  pji_fp_aggr_pjp1_t fact,
	  pji_rbs_denorm rbs
	WHERE
	  rbs.STRUCT_VERSION_ID = l_rbs_version_id_tbl(j) AND
	  rbs.SUP_LEVEL        <> rbs.SUB_LEVEL    AND
	  rbs.SUB_ID            = fact.RBS_ELEMENT_ID
	GROUP BY
	  fact.PROJECT_ID,
	  fact.PROJECT_ORG_ID,
	  fact.PROJECT_ORGANIZATION_ID,
	  fact.PROJECT_ELEMENT_ID,--xbs.SUB_ELEMENT_ID,
	  fact.TIME_ID,
	  fact.PERIOD_TYPE_ID,
	  fact.CALENDAR_TYPE,
	  'R',
	  fact.WBS_ROLLUP_FLAG,
	  fact.PRG_ROLLUP_FLAG,
	  fact.CURR_RECORD_TYPE_ID,
	  fact.CURRENCY_CODE,
	  rbs.SUP_ID,
	  fact.RBS_VERSION_ID,
	  fact.PLAN_VERSION_ID,
	  fact.PLAN_TYPE_ID,
               fact.PLAN_TYPE_CODE;

	 IF g_debug_mode='Y' THEN
           Pji_Utils.write2log(' Inserted RBS rollup for all slices ' || SQL%ROWCOUNT ,null,3);
         end if;

    Pji_Fm_Plan_Maint_T_Pvt.MERGE_INTO_FP_FACT;

    IF p_commit = 'Y' THEN
      COMMIT;
    END IF;

    IF g_debug_mode='Y' THEN
       Pji_Utils.write2log(' maintain smart slice .. 0003 '  ,null,3);
    end if;

EXCEPTION
WHEN Invalid_Excep THEN
    x_msg_data      := 'unexcepted error';
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'MAINTAIN_SMART_SLICE'
    , x_return_status => x_return_status ) ;

  WHEN OTHERS THEN
    x_msg_data      := SQLERRM;
    ROLLBACK;

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'MAINTAIN_SMART_SLICE'
    , x_return_status => x_return_status ) ;

    RAISE;
END;


PROCEDURE CLEANUP_TEMP_TABLES IS
  l_return_status   VARCHAR2(1);
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => l_return_status );

  DELETE FROM pji_fp_aggr_pjp1_t;
  DELETE FROM PJI_FM_EXTR_PLNVER3_T;
  DELETE FROM pji_fp_rmap_fpr_update_t;
EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'CLEANUP_TEMP_TABLES'
    , x_return_status => l_return_status ) ;

    RAISE;
END;


--
-- Checks if list of plan versions exist in budget versions table.
--
PROCEDURE CHECK_BUDGET_VERSION_EXISTS (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type() ) IS
  i             NUMBER;
  l_project_id  NUMBER;
  l_return_status VARCHAR2(1);
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => l_return_status );

  print_time ( ' inside CHECK_BUDGET_VERSION_EXISTS ' ) ;
  FOR i IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST LOOP

	BEGIN

        SELECT PROJECT_ID
        INTO l_project_id
        FROM pa_budget_versions
        WHERE budget_version_id = p_fp_version_ids(i);

        print_time ( ' plan version id # ' || i || ' is ' || p_fp_version_ids(i) || ' exists in budget versions.');

	EXCEPTION
	  WHEN OTHERS THEN
          print_time ( ' plan version id # ' || i || ' is ' || p_fp_version_ids(i) || ' does not exist in budget versions.');
	END;

	BEGIN

        SELECT /*+ index_ffs(wbs_hdr PJI_PJP_WBS_HEADER_N1) */ PROJECT_ID
        INTO l_project_id
        FROM pji_pjp_wbs_header wbs_hdr
        WHERE plan_version_id = p_fp_version_ids(i);

        print_time ( ' plan version id # ' || i || ' is ' || p_fp_version_ids(i) || ' exists in budget versions.');

	EXCEPTION
	  WHEN OTHERS THEN
          print_time ( ' plan version id # ' || i || ' is ' || p_fp_version_ids(i) || ' does not exist in budget versions.');
	END;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'CHECK_BUDGET_VERSION_EXISTS'
    , x_return_status => l_return_status ) ;

    RAISE;
END;


----------
-- Prints the list of plan versions in a given table of plan versions.
----------
PROCEDURE PRINT_PLAN_VERSION_ID_LIST
( p_fp_version_ids   IN    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type() ) IS
  i NUMBER;
  l_return_status VARCHAR2(1);
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => l_return_status );

  print_time ( ' There are ' || p_fp_version_ids.COUNT || ' plan versions.');
  FOR i IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST LOOP
    print_time ( ' .... Plan version ' || i || ' is ' || p_fp_version_ids(i));
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PRINT_PLAN_VERSION_ID_LIST'
    , x_return_status => l_return_status ) ;

    RAISE;
END;


----------
-- Prints the list of plan versions in a given table of plan versions.
----------
PROCEDURE PRINT_PLAN_VERSION_TYPE_LIST
( p_fp_version_types   IN          SYSTEM.pa_varchar2_30_tbl_type ) IS
  i NUMBER;
  l_return_status  VARCHAR2(1);
BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => l_return_status );

  print_time ( ' There are ' || p_fp_version_types.COUNT || ' plan versions.');
  FOR i IN p_fp_version_types.FIRST..p_fp_version_types.LAST LOOP
    print_time ( ' .... Plan version ' || i || ' is ' || p_fp_version_types(i));
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PRINT_PLAN_VERSION_TYPE_LIST'
    , x_return_status => l_return_status ) ;

    RAISE;
END;

-----------------------------------------------------------------
--This API inserts rows for handling ETC calculations in apply
--progress flow for version disabled workplan structures
--If the global variable PA_PROGRESS_PUB.G_WBS_APPLY_PROG
--is set, it means plan_update API is being called in apply
--flow for version disabled workplan structure
-----------------------------------------------------------------
PROCEDURE INSERT_APPLY_PROG_VD IS
BEGIN

  IF PA_PROGRESS_PUB.G_WBS_APPLY_PROG IS NOT NULL THEN

    --------------------------------------------------------
    --If the ETC column is null and the PLAN column has some
    --value, we copy the plan value to the ETC columns
    --The 0 rows for ETC in this case will ensure that in the
    --incremental change in plan value is not copied to the
    --ETC columns
    --------------------------------------------------------

    INSERT INTO pji_fm_extr_plan_lines (
      PROJECT_ID, PROJECT_ORG_ID, PROJECT_ELEMENT_ID, STRUCT_VER_ID,
      PERIOD_NAME, CALENDAR_TYPE, START_DATE, END_DATE, RBS_ELEMENT_ID,
      RBS_VERSION_ID, PLAN_VERSION_ID, PLAN_TYPE_ID, WP_VERSION_FLAG,
      ROLLUP_TYPE, TXN_CURRENCY_CODE, PRJ_CURRENCY_CODE, PFC_CURRENCY_CODE,
      RESOURCE_CLASS_CODE, RATE_BASED_FLAG,
      ETC_PFC_BURDENED_COST,ETC_PFC_RAW_COST, ETC_PRJ_BURDENED_COST,
      ETC_PRJ_RAW_COST, ETC_QUANTITY, ETC_TXN_BURDENED_COST, ETC_TXN_RAW_COST )
    SELECT
      PROJECT_ID, PROJECT_ORG_ID, PROJECT_ELEMENT_ID, STRUCT_VER_ID,
      PERIOD_NAME, CALENDAR_TYPE, START_DATE, END_DATE, RBS_ELEMENT_ID,
      RBS_VERSION_ID, PLAN_VERSION_ID, PLAN_TYPE_ID, WP_VERSION_FLAG,
      ROLLUP_TYPE, TXN_CURRENCY_CODE, PRJ_CURRENCY_CODE, PFC_CURRENCY_CODE,
      RESOURCE_CLASS_CODE, RATE_BASED_FLAG,
      0, 0, 0,
      0, 0, 0, 0
    FROM
      pji_fm_extr_plan_lines
    WHERE
      STRUCT_VER_ID = PA_PROGRESS_PUB.G_WBS_APPLY_PROG
    GROUP BY
      PROJECT_ID, PROJECT_ORG_ID, PROJECT_ELEMENT_ID, STRUCT_VER_ID,
      PERIOD_NAME, CALENDAR_TYPE, START_DATE, END_DATE, RBS_ELEMENT_ID,
      RBS_VERSION_ID, PLAN_VERSION_ID, PLAN_TYPE_ID, WP_VERSION_FLAG,
      ROLLUP_TYPE, TXN_CURRENCY_CODE, PRJ_CURRENCY_CODE, PFC_CURRENCY_CODE,
      RESOURCE_CLASS_CODE, RATE_BASED_FLAG;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    null;
END;

----------
-- Print time API to measure time taken by each api. Also useful for debugging.
----------
PROCEDURE PRINT_TIME(p_tag IN VARCHAR2) IS
BEGIN
  Pji_Pjp_Fp_Curr_Wrap.print_time(p_tag);
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    -- RAISE;
END;


END Pji_Fm_Xbs_Accum_Maint;

/

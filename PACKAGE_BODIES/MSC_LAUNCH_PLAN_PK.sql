--------------------------------------------------------
--  DDL for Package Body MSC_LAUNCH_PLAN_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_LAUNCH_PLAN_PK" AS
/* $Header: MSCPLAPB.pls 120.9.12010000.4 2010/03/23 13:51:52 skakani ship $ */

FUNCTION LAUNCH_REFRESH_MV (p_plan_id in  number) RETURN boolean
	IS
	      lvs_request_id number;

	      l_call_status boolean;

	      l_phase            varchar2(80);
	      l_status           varchar2(80);
	      l_dev_phase        varchar2(80);
	      l_dev_status       varchar2(80);
	      l_message          varchar2(2048);
	BEGIN

            lvs_request_id := FND_REQUEST.SUBMIT_REQUEST(
                'MSC', -- application
                'MSCREFSN', -- program
                NULL,  -- description
                NULL, -- start time
                FALSE, -- sub_request
                p_plan_id);

		COMMIT;

		IF lvs_request_id=0 THEN
                   MSC_UTIL.msc_Debug('Launch Refresh MV MSCREFSN failed');
		   RETURN FALSE;
		ELSE
                   MSC_UTIL.msc_Debug('Launched Program MSCREFSN Request:'|| to_char(lvs_request_id));
		END IF;

	     LOOP
		      /* come out of function only when the MSCPDCP is complete - reqd for Collections incompatibility */

		  l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
				      ( lvs_request_id,
					NULL,
					NULL,
					l_phase,
					l_status,
					l_dev_phase,
					l_dev_status,
					l_message);

		   IF (l_call_status=FALSE) THEN
                      MSC_UTIL.msc_Debug('Failure in verifying request:'|| to_char(lvs_request_id));
		      RETURN FALSE;
		   END IF;

		   EXIT WHEN l_dev_phase = 'COMPLETE';

	     END LOOP;

	 RETURN TRUE;

	EXCEPTION
	  WHEN OTHERS THEN
               MSC_UTIL.msc_Debug('Failure in verifying request:'|| to_char(lvs_request_id));
	       RETURN FALSE;
END LAUNCH_REFRESH_MV;
-- Modification for bug 1863615 - removed the plan horizon date parameter
-- ************************* msc_launch_plan ******************************* --
    PROCEDURE msc_launch_plan (
				errbuf                  OUT NOCOPY VARCHAR2,
                                retcode                 OUT NOCOPY NUMBER,
                                arg_designator          IN         VARCHAR2,
                                arg_plan_id             IN         NUMBER,
                                arg_launch_snapshot     IN         NUMBER,
                                arg_launch_planner      IN         NUMBER,
                                arg_netchange_mode      IN         NUMBER,
                                arg_anchor_date         IN         VARCHAR2,
                                p_archive_flag        IN         number default 2,
				p_plan_type_dummy       IN         VARCHAR2 default null,
                                p_24x7atp               IN         NUMBER default 2,
                                p_reschedule_dummy      IN         VARCHAR2 default null,
                                arg_release_reschedules IN         NUMBER default 2,
                                p_snap_static_entities IN NUMBER default 1        ,
				p_calculate_liability_dummy IN    varchar2 default null ,
				p_calculate_liabilty   IN         number default 2,
                                p_generate_fcst        IN         number default 2,
                                p_compute_ss_eoq       IN         number default 2
				)
IS

    var_snapshot_req_id        INTEGER;
    var_planner_req_id        INTEGER;
    var_user_id             INTEGER;
    var_production1            INTEGER;
    var_production2            INTEGER;
    var_auto_release_id     INTEGER;
    months                    NUMBER;
-- Modification for bug 1863615
 --   var_new_date            DATE;

	l_org_id    NUMBER;
	l_instance_id    NUMBER;
	l_platform_type NUMBER := 0;
	l_enable_64b_snapshot NUMBER := 0;
	l_call_status      boolean;
	l_phase            varchar2(80);
	l_status           varchar2(80);
	l_dev_phase        varchar2(80);
	l_dev_status       varchar2(80);
	l_message          varchar2(2048);
	l_industry    VARCHAR2(30);
        l_schema    VARCHAR2(30);
    	var_desc			VARCHAR2(50);
    	v_plan_id			NUMBER;
    	v_new_plan_id       NUMBER;
    	v_dummy             NUMBER;
    	v_desig_id			NUMBER;
    	var_temp_plan_id		NUMBER;
    	var_temp_desig_id		NUMBER;
	v_completion_date		date;
    	v_request_id			number;
    	v_summary_flag			number;
    	v_destination_notifications	number;
    	var_plan_type			number;
    	var_overwrite_all		number;
	var_desig_id			number;
 	var_atp			number;
 	var_production		number;
 	var_inactive_on		date;
 	var_organization_id	number;
 	var_sr_instance_id	number;
	v_req_data		number;
	--V_Curr_req_id 		number:= FND_GLOBAL.CONC_REQUEST_ID;
	v_lookup_name           varchar2(100);
        v_plan_completion_date  date; --SNOP Change

    CURSOR check_plan_id(p_plan_id    IN Number,
	                     p_designator IN VARCHAR2) IS
	SELECT 1
	FROM msc_plans mp
	WHERE mp.plan_id = p_plan_Id
	AND   mp.compile_designator = p_designator;

	CURSOR get_plan_id(p_designator IN VARCHAR2) IS
	SELECT mp.plan_id
	FROM msc_plans mp
	WHERE mp.compile_designator = p_designator;

    CURSOR C1(p_plan_id in number) IS
    SELECT organization_id, sr_instance_id,
	   curr_Plan_Type, curr_Overwrite_Option,
	   request_id, plan_completion_date, summary_flag,
	   compile_designator
    FROM msc_plans
    WHERE plan_id = p_plan_id;

    v_rec_c1 c1%rowtype;

    cursor temp_plan_exist_cur(p_designator  in varchar2,
                               p_org_id      in number,
                               p_instance_id in number) is
    SELECT plan_id, plan_completion_date,request_id, summary_flag
    FROM   msc_plans
    WHERE  compile_designator = p_designator
    AND    organization_id    = p_org_id
    AND    sr_instance_id     = p_instance_id;

    cursor orig_desig_cur(p_plan_id in number) is
    select  desig.designator_id,
    	    desig.description,
            desig.inventory_atp_flag,
            desig.launch_workflow_flag,
            desig.production,
            desig.disable_date,
            desig.organization_id,
            desig.sr_instance_id,
	    plans.curr_plan_type,
	    plans.curr_overwrite_option
    from msc_designators desig, msc_plans plans
    where desig.designator = plans.compile_designator
      and   plans.plan_id= p_plan_id
      and   plans.organization_id = desig.organization_id
      and   plans.sr_instance_id  = desig.sr_instance_id;

   cursor temp_desig_exists_cur(p_designator  in varchar2,
                               p_org_id      in number,
                               p_instance_id in number) is
   SELECT designator_id
   FROM   msc_designators
   WHERE  designator       = p_designator
   AND    organization_id  = p_org_id
   AND    sr_instance_id   = p_instance_id;

   v_ex_error_plan_launch       EXCEPTION;

BEGIN

    OPEN check_plan_id(arg_plan_id, arg_designator );
    FETCH check_plan_id INTO v_dummy;
    IF check_plan_id%FOUND THEN
        v_new_plan_id := arg_plan_id;
        CLOSE check_plan_id;
    ELSE
        CLOSE check_plan_id;
        msc_util.msc_debug('Plan Id changed.');
        OPEN get_plan_id(arg_designator);
        FETCH get_plan_id INTO v_new_plan_id;
        CLOSE get_plan_id;
        msc_util.msc_debug('New Plan Id is '||v_new_plan_id);
    END IF;

--Additional code for release reschedules   bug#2881012
update msc_plans
set release_reschedules = nvl(arg_release_reschedules,2),
    calculate_liability = nvl(p_calculate_liabilty,2),
    compute_ss_eoq      = nvl(p_compute_ss_eoq,2)
--where plan_id = arg_plan_id;
where plan_id = v_new_plan_id;

-- Modified (forward port) for the bug # 3021850
if p_24x7atp in (1,3) and arg_launch_snapshot = SYS_NO then
	retcode := 5;
	raise v_ex_error_plan_launch;
end if;
	--v_plan_id := arg_plan_id;
	v_plan_id := v_new_plan_id;
	-- ---------------------------------------
	-- Check for Cheild request.
	-- ---------------------------------------
v_req_data := fnd_conc_global.request_data;
if v_req_data is null then
        open c1(v_plan_id);
        fetch c1 into v_rec_c1;
        Close c1;

	if v_rec_c1.request_id is not null then
	    -- -------------------------------------
	    -- Check if previous plan output exists.
	    -- if existing, check for the status of
	    -- of the plan output.
	    -- -------------------------------------
	    l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                                                ( v_rec_c1.request_id,
                                                  NULL,
                                                  NULL,
                                                  l_phase,
                                                  l_status,
                                                  l_dev_phase,
                                                  l_dev_status,
                                                  l_message);
	    if v_rec_c1.plan_completion_date is not null then

		if upper(l_dev_phase) not in ('COMPLETE','INACTIVE') then
	        	if v_rec_c1.summary_flag = 2 then
		 		v_lookup_name:= 'MSC_POST_PROCESS_RUNNING';
				raise v_ex_error_plan_launch;
		 	elsif v_rec_c1.summary_flag in (4,5) then
		 		v_lookup_name:= 'MSC_SYNC_RUNNING';
                                raise v_ex_error_plan_launch;
			else
                                v_lookup_name := 'MSC_PLAN_RUNNING';
                                raise v_ex_error_plan_launch;
	       		end if;
		elsif upper(l_dev_status)not in ('NORMAL','WARNING') and v_rec_c1.summary_flag = 2 then
	 		 v_lookup_name:= 'MSC_POST_PROCESS_FAIL';
                         raise v_ex_error_plan_launch;
	        end if;
	        -- ------------------------
		-- If Output Exists then...
	        -- ------------------------
                --Modified for the bug#2850632
	        open temp_plan_exist_cur(nvl(substr(to_char(v_plan_id),-10),v_plan_id),
                                         v_rec_c1.organization_id,
                                         v_rec_c1.sr_instance_id);
	        fetch temp_plan_exist_cur into var_temp_plan_id,v_completion_date, v_request_id, v_summary_flag;
	        -- ------------------------------------------------------
	        -- if Temp. plan exists, Check Plan/Sync. Process status.
	        -- ------------------------------------------------------
	        if temp_plan_exist_cur%found then
           		l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
	                	                ( v_request_id,
	                	                  NULL,
	                	                  NULL,
	                	                  l_phase,
	                	                  l_status,
	                	                  l_dev_phase,
	                	                  l_dev_status,
	                	                  l_message);
	 	    -- --------------------------------
	            -- If Completed then...
	            -- --------------------------------
	            if v_completion_date is not null then
		    	if upper(l_dev_phase) <>'COMPLETE' then
		        	if v_summary_flag = 2 then
					 v_lookup_name:= 'MSC_POST_PROCESS_RUNNING';
                               		 raise v_ex_error_plan_launch;
                		elsif v_summary_flag in (4,5 )then
                			 v_lookup_name:= 'MSC_SYNC_RUNNING';
                                 	 raise v_ex_error_plan_launch;
				else
					v_lookup_name := 'MSC_PLAN_RUNNING';
					raise v_ex_error_plan_launch;
                		end if;
                	-- elsif upper(l_dev_status)not in ('NORMAL','WARNING') and v_summary_flag = 2 then
                	-- -------------------------------------
                	-- Plan run is completed unsuccessfully.
                	-- Re-launch plan.
                	-- -------------------------------------
			end if;
		        -- ---------------------------------
		        -- if not completed then...
		        -- ---------------------------------
		     else
		       	if upper(l_dev_phase) <>'COMPLETE' then
				if v_summary_flag = 2 then
                			v_lookup_name:= 'MSC_POST_PROCESS_RUNNING';
                                 	raise v_ex_error_plan_launch;
                		elsif v_summary_flag in (4,5 )then
                			v_lookup_name:= 'MSC_SYNC_RUNNING';
                                	raise v_ex_error_plan_launch;
				else
                                        v_lookup_name := 'MSC_PLAN_RUNNING';
                                        raise v_ex_error_plan_launch;
                		end if;
                	-- elsif upper(l_dev_status)not in ('NORMAL','WARNING') and v_summary_flag = 2 then
                	-- --------------------------------------
                	-- Plan run is completed unsuccessfully.
                	-- re-launch the plan.
                	-- --------------------------------------
			end if;
		     end if;
		end if; -- End Temp. Plan exists Check .
	   else -- v_rec_c1.plan_completion_date is null then
		-- ------------------------------------
		-- if plan run is not complete then...
		-- ------------------------------------
		-- MSC_UTIL.msc_Debug('phase '||L_phase||' '||L_message);
        IF upper(l_dev_phase) <>'COMPLETE' THEN
            IF v_rec_c1.summary_flag = 2 THEN
                v_lookup_name:= 'MSC_POST_PROCESS_RUNNING';
                RAISE v_ex_error_plan_launch;
            ELSE
                v_lookup_name := 'MSC_PLAN_RUNNING';
                RAISE v_ex_error_plan_launch;
            END IF;
        ELSIF upper(l_dev_status)not in ('NORMAL','WARNING') and v_rec_c1.summary_flag = 2 then
            v_lookup_name:= 'MSC_POST_PROCESS_FAIL';
            raise v_ex_error_plan_launch;
        END IF;
  	   end if; -- v_rec_c1.plan_completion_date check
	End if; -- End Vrec_C1.request_id check
	-- ------------------------
	-- getting original desig.
	-- ------------------------
       	open orig_desig_cur(v_plan_id);
        fetch orig_desig_cur
	into
	var_desig_id,	var_desc,        var_atp,             v_destination_notifications,
	var_production,	var_inactive_on, var_organization_id, var_sr_instance_id,
	var_plan_type, var_overwrite_all;
	close orig_desig_cur;

        --Modified for the bug#2850632
        open temp_desig_exists_cur(nvl(substr(to_char(v_plan_id),-10),v_plan_id),
                                         v_rec_c1.organization_id,
                                         v_rec_c1.sr_instance_id);

       	fetch temp_desig_exists_cur into var_temp_desig_id;
       	close temp_desig_exists_cur;
	if not temp_plan_exist_cur%isopen then
        --Modified for the bug#2850632
	        open temp_plan_exist_cur(nvl(substr(to_char(v_plan_id),-10),v_plan_id),
                                         v_rec_c1.organization_id,
                                         v_rec_c1.sr_instance_id);
		fetch temp_plan_exist_cur into var_temp_plan_id,v_completion_date, v_request_id, v_summary_flag;
	end if;

      if nvl(var_temp_desig_id,0) > 0  then
      -- Modified (forward port) for the bug # 3021850
		-- ----------------------------------------------
		-- Var_Temp_plan_id <>-1, Temp. plan exists.
		-- Delete the temp. plan because, for any plan,
		-- only one temp. plan can exist at any instance.
		-- ----------------------------------------------
		MSC_UTIL.msc_Debug('deleting temp_plan '||var_temp_plan_id);
	       	msc_copy_plan_options.delete_temp_plan(errbuf, retcode, var_temp_desig_id, TRUE);
		if retcode >0 then
                       	 raise v_ex_error_plan_launch;
               	end if;
	        Commit;
		return;
	end if;
end if;  -- end checking  req_data null
	if var_desig_id is null then
		-- ------------------------------
		-- While child completes, and
		-- the parent get re-launched,
		-- var_desig_id will be null.
		-- ------------------------------
		open orig_desig_cur(v_plan_id);
	        fetch orig_desig_cur
       		Into
       		var_desig_id,   var_desc,        var_atp,             v_destination_notifications,
	        var_production, var_inactive_on, var_organization_id, var_sr_instance_id,
		var_plan_type, var_overwrite_all;
        	close orig_desig_cur;
	end if;

	-- Modified (forward port) for the bug # 3021850
	if p_24x7atp in (1,3) then

		-- ----------------------------------------------------
                --  p_24x7atp -> Yes, purge current plan - 1
                --               No - 2
                --               Yes, do not purge current plan - 3
                -- Set this flag to decide whether a 24x7 original plan
                -- has to be purged.(Ref. : bug#3002550)

		-- Copy Plan Options.
		-- If running with 24X7mode then...
		-- -----------------------------------------------------

                 update msc_designators
                 set    purge_current_plan = decode(p_24x7atp,3,2,1)
                 where  designator_id      = var_desig_id;

		msc_copy_plan_options.init_plan_id('N',NULL,NULL);
       		MSC_UTIL.msc_Debug('Copying plan options...'  );
	        msc_copy_plan_options.copy_plan_options
               		( v_plan_id 	, 			-- > p_source_plan_id
               		  nvl(substr(to_char(v_plan_id),-10),v_plan_id),	-- > p_dest_plan_name
	                  var_desc,				-- > p_dest_plan_desc
	                  var_plan_type, 			-- > p_dest_plan_type
               		  2 ,  					-- > p_dest_atp
               		  var_production,			-- > p_dest_production
               		  v_destination_notifications,		-- > p_dest_notifications
	                  var_inactive_on,			-- > p_dest_inactive_on
	                  var_organization_id ,			-- > p_organization_id
               		  var_sr_instance_id);			-- > p_sr_instance_id

     		msc_copy_plan_options.link_Plans
     				(errbuf,	--> ERRBUF
     				 retcode,	--> RETCODE
     				 v_plan_id,	--> P_Src_plan_id
     				 var_Desig_id,  --> P_Src_Desg_id
     				 var_Temp_plan_id, --> P_plan_id
     				 var_temp_desig_id ); --> P_designator_id
     		if retcode > 0 then
     			 raise v_ex_error_plan_launch;
     		end if;
	     	msc_copy_plan_options.init_plan_id('N',NULL,NULL);

		if var_overwrite_all<> 1 then
       			MSC_UTIL.msc_Debug('copying firm orders...' );
       			msc_copy_plan_options.copy_firm_orders(errbuf, retcode, v_plan_id, var_temp_plan_id);
       			if nvl(retcode,0) > 0 then
				 raise v_ex_error_plan_launch;
			end if;
      		end if;
		v_plan_id := var_temp_plan_id;
	end if;
-- End of additional code for 24X7 ATP - 30-10-2002

    /*----------------------------------------+
    | Update msc_plans with plan horizon date |
    +----------------------------------------*/
    MSC_UTIL.msc_Debug('******About to Launch Plan******');
-- Modification for bug 1863615
 --   IF arg_plan_horizon IS  NULL THEN
 --     months := fnd_profile.value('MRP_CUTOFF_DATE_OFFSET');

 --     var_new_date := MSC_CALENDAR.NEXT_WORK_DAY(l_org_id,l_instance_id,1,
 --               TO_DATE(TO_CHAR(add_months(sysdate, NVL(months, 12)),
 --                       'YYYY/MM/DD HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS')) ;
 --     UPDATE msc_plans
 --     SET       curr_cutoff_date = var_new_date ,
 --		online_replan = NULL
 --     WHERE   plan_id = arg_plan_id;
 --
 --     COMMIT;

 --   ELSE

 --     var_new_date := MSC_CALENDAR.NEXT_WORK_DAY(l_org_id,l_instance_id,1,TO_DATE(arg_plan_horizon, 'YYYY/MM/DD HH24:MI:SS')) ;
 --     UPDATE msc_plans
 --     SET    curr_cutoff_date = var_new_date,
	--	online_replan = NULL
 --     WHERE  plan_id = arg_plan_id;
 --     COMMIT;
 --   END IF;

        -- Bug 3478888 - Move this to MSCPOSTB.pls
    /*
    -- -------------------------------------
    -- Reset the ATP_SYNCHRONIZATION_FLAG
    -- to NULL for the orginal plan.
    -- -------------------------------------
        --Modified NULL to 0 for the bug#2797732
    update msc_demands
       set atp_synchronization_flag = 0
     where plan_id = arg_plan_id;
     */

        /*---------------------------------------+
        | Update msc_parameters with anchor date |
        +---------------------------------------*/
        UPDATE msc_parameters
        SET    repetitive_anchor_date = TO_DATE(arg_anchor_date, 'YYYY/MM/DD HH24:MI:SS')
        WHERE  (organization_id,sr_instance_id) IN (select organization_id, sr_instance_id
                       from msc_plan_organizations
                       Where plan_id = v_plan_id);
	COMMIT;
    /*-------------+
    | Get user id  |
    +--------------*/

    var_user_id := fnd_profile.value('USER_ID');
    /*-----------------------------------------------+
    | Insert subinventories into msc_sub_inventories |
    | that are defined after options are defined     |
    +-----------------------------------------------*/
   BEGIN

       INSERT INTO MSC_SUB_INVENTORIES
                (SUB_INVENTORY_CODE,
                 ORGANIZATION_ID,
                 SR_INSTANCE_ID,
                 PLAN_ID,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 NETTING_TYPE)
           SELECT  msi.sub_inventory_code,
            mpo.organization_id,
            mpo.sr_instance_id,
	    v_plan_id,
            SYSDATE,
            1,
            -1,
            SYSDATE,
            1,
            msi.netting_type
           FROM    msc_sub_inventories msi,
                   msc_plan_organizations mpo
             WHERE   NOT EXISTS
                (SELECT NULL
                 FROM MSC_SUB_INVENTORIES SUB
                 WHERE SUB.ORGANIZATION_ID = mpo.organization_id
                                 AND sub.sr_instance_id = mpo.sr_instance_id
                 AND SUB.plan_id = mpo.plan_id
                 AND SUB.sub_inventory_code = msi.sub_inventory_code)
        AND msi.ORGANIZATION_ID = mpo.organization_id
        AND msi.sr_instance_id = mpo.sr_instance_id
         AND msi.plan_id = -1
         AND mpo.plan_id = v_plan_id;

	-- --------------------------------------------
	-- If plan launch is in 24x7 mode, keep a copy
	-- of sub inventories in original plan as well.
	-- --------------------------------------------
	--if v_plan_id <> arg_plan_id THEN
	if v_plan_id <> v_new_plan_id THEN
		INSERT INTO MSC_SUB_INVENTORIES
					(SUB_INVENTORY_CODE,
					 ORGANIZATION_ID,
					 SR_INSTANCE_ID,
					 PLAN_ID,
					 CREATION_DATE,
					 CREATED_BY,
					 LAST_UPDATE_LOGIN,
					 LAST_UPDATE_DATE,
					 LAST_UPDATED_BY,
					 NETTING_TYPE)
		SELECT
					msi.sub_inventory_code,
					mpo.organization_id,
					mpo.sr_instance_id,
					v_new_plan_id, --arg_plan_id,
					SYSDATE,
					1,
					-1,
					SYSDATE,
					1,
					msi.netting_type
		FROM	msc_sub_inventories msi,
				msc_plan_organizations mpo
		WHERE   NOT EXISTS
					(SELECT NULL
					 FROM msc_sub_inventories sub
					 WHERE 	sub.organization_id = mpo.organization_id
					 AND 	sub.sr_instance_id = mpo.sr_instance_id
					 AND	sub.plan_id = mpo.plan_id
					 AND	sub.sub_inventory_code = msi.sub_inventory_code)
		AND msi.organization_id = mpo.organization_id
		AND msi.sr_instance_id = mpo.sr_instance_id
		AND msi.plan_id = -1
		--AND mpo.plan_id = arg_plan_id;
		AND mpo.plan_id = v_new_plan_id;
	End if;

	COMMIT;

    EXCEPTION when no_data_found then
        null;
    END;


    -- SNOP Change start

    SELECT plan_start_date
    INTO   v_plan_completion_date
    FROM   msc_plans
    WHERE  plan_id = v_plan_id;

    IF (arg_launch_snapshot = DP_SCN_ONLY_SNAPSHOT AND
        v_plan_completion_date is not null ) --Not a first time plan launch
    THEN
        UPDATE msc_plans
               SET    planning_mode = DP_SCN_ONLY_SNP_MODE
               WHERE  plan_id = v_plan_id;
        COMMIT;
    ELSE
        UPDATE msc_plans
                SET    planning_mode = NULL
                WHERE  plan_id = v_plan_id;
        COMMIT;
    END IF;

    -- SNOP Change End
    IF ( p_generate_fcst = 1 )
    THEN
       UPDATE msc_plans
              SET    GENERATE_INLINE_FORECAST= SYS_YES
              WHERE  plan_id = v_plan_id;
       COMMIT;
    ELSE
       UPDATE msc_plans
              SET    GENERATE_INLINE_FORECAST= SYS_NO
              WHERE  plan_id = v_plan_id;
       COMMIT;

     END IF;


    IF (arg_launch_snapshot = SYS_YES OR
        (arg_launch_snapshot = DP_SCN_ONLY_SNAPSHOT AND --SNOP Change for first time plan launch
         v_plan_completion_date is null ))
    THEN

	/* changes for launching 64 bit snapshot */
	l_enable_64b_snapshot := fnd_profile.value('MSC_ENABLE_64BIT_SNAPSHOT');
	IF l_enable_64b_snapshot IS NULL THEN
	  l_enable_64b_snapshot := 0;
	END IF;

	IF (l_enable_64b_snapshot > 0)
	THEN
	   l_platform_type := fnd_profile.value('MSC_PLANNER_PLATFORM');
	   IF l_platform_type IS NULL THEN
	     l_platform_type := 0;
	   END IF;
	ELSE
	     l_platform_type := 0;
	END IF;

	IF l_platform_type = 0 THEN
	MSC_UTIL.msc_Debug('Launching Snapshot for 32 bit');
            var_snapshot_req_id := NULL;
            IF (arg_netchange_mode = SYS_NO) THEN
            var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
                'MSC', -- application
                'MSCNSP', -- program
                NULL,  -- description
                NULL, -- start time
                FALSE, -- sub_request
                v_plan_id,
                2, -- Launch_CRP_planner
                0, -- snapshot_worker
                0, -- monitor_pipe
                0, -- monitor_request_id
                1, -- Netchange_mode
                p_snap_static_entities);

             ELSE
             var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
                'MSC', -- application
                'MSCNSP', -- program
                NULL,  -- description
                NULL, -- start time
                FALSE, -- sub_request
                v_plan_id, -- plan_id
                2, -- Launch_CRP_planner
                0, -- snapshot_worker
                0, -- monitor_pipe
                0, -- monitor_request_id
                4, -- Netchange_mode
                1  -- p_snap_static_entities
                );
             END IF;

	ELSIF l_platform_type = 1 THEN
	    MSC_UTIL.msc_Debug('Launching Snapshot for 64 bit Sun');
		var_snapshot_req_id := NULL;
	    IF (arg_netchange_mode = SYS_NO) THEN
	    var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
	    	'MSC', -- application
		'MSCNSPWS64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id,
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		1, -- Netchange_mode
		p_snap_static_entities);

	     ELSE
	     var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
		'MSC', -- application
		'MSCNSPWS64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id, -- plan_id
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		4, -- Netchange_mode
		1  -- p_snap_static_entities
		);
	     END IF;
	ELSIF l_platform_type = 2 THEN
	    MSC_UTIL.msc_Debug('Launching Snapshot for 64 bit HP');
	    var_snapshot_req_id := NULL;
	    IF (arg_netchange_mode = SYS_NO) THEN
  	    var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
		'MSC', -- application
		'MSCNSPWH64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id,
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		1, -- Netchange_mode
		p_snap_static_entities);

	     ELSE
	     var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
		'MSC', -- application
		'MSCNSPWH64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id, -- plan_id
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		4, -- Netchange_mode
		1  -- p_snap_static_entities
		);
	     END IF;
	 ELSIF l_platform_type = 3 THEN
	    MSC_UTIL.msc_Debug('Launching Snapshot for 64 bit AIX');
	    var_snapshot_req_id := NULL;
	    IF (arg_netchange_mode = SYS_NO) THEN
	    var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
	    	'MSC', -- application
		'MSCNSPWA64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id,
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		1, -- Netchange_mode
		p_snap_static_entities);

	     ELSE
	     var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
		'MSC', -- application
		'MSCNSPWA64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id, -- plan_id
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		4, -- Netchange_mode
		1  -- p_snap_static_entities
		);
	     END IF;

	     ELSIF l_platform_type = 4 THEN
	    MSC_UTIL.msc_Debug('Launching Snapshot for Linux 64bit');
	    var_snapshot_req_id := NULL;
	    IF (arg_netchange_mode = SYS_NO) THEN
	    var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
		'MSC', -- application
		'MSCNSPWL64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id,
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		1, -- Netchange_mode
		p_snap_static_entities);
	ELSE
	     var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
	     	'MSC', -- application
		'MSCNSPWL64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id, -- plan_id
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		4, -- Netchange_mode
		1  -- p_snap_static_entities
		);
	     END IF;

	    ELSIF l_platform_type = 5 THEN
	    MSC_UTIL.msc_Debug('Launching Snapshot for HP Itanium 64bit');
	    var_snapshot_req_id := NULL;
	    IF (arg_netchange_mode = SYS_NO) THEN
	    var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
	 	'MSC', -- application
		'MSCNSPWHPIA64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id,
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		1, -- Netchange_mode
		p_snap_static_entities);
	ELSE
	     var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
		'MSC', -- application
		'MSCNSPWHPIA64', -- program
		NULL,  -- description
		NULL, -- start time
		FALSE, -- sub_request
		v_plan_id, -- plan_id
		2, -- Launch_CRP_planner
		0, -- snapshot_worker
		0, -- monitor_pipe
		0, -- monitor_request_id
		4, -- Netchange_mode
		1  -- p_snap_static_entities
		);
	     END IF;

	ELSE
		retcode := 2;
		errbuf := 'Invalid Platform Type'||to_char(l_platform_type);
		return;
	END IF;


	 UPDATE msc_plans  /* for 24x7 ATP */
             SET     request_id =  var_snapshot_req_id
             WHERE   plan_id =     v_plan_id;

	COMMIT;

        MSC_UTIL.msc_Debug('Launched Snapshot:'||
                      to_char(var_snapshot_req_id));

    END IF; /* if arg_launch_snapshot = SYS_YES */

    IF ((arg_launch_planner = SYS_YES) AND
            (arg_launch_snapshot = SYS_NO OR
             (arg_launch_snapshot = DP_SCN_ONLY_SNAPSHOT AND
              v_plan_completion_date is not null ))) /* SNOP Change */
    THEN
        var_planner_req_id := NULL;


        /*-------------+
        | Get platform |
        +-------------*/
        l_platform_type := fnd_profile.value('MSC_PLANNER_PLATFORM');
        IF l_platform_type IS NULL THEN
          l_platform_type := 0;
        END IF;

          IF fnd_installation.get_app_info('MSO',l_status,l_industry,l_schema) <> TRUE THEN
            retcode := 2;
            errbuf := 'Error checking installation status of MSO';
          ELSE
            IF l_status = 'I' THEN
              IF l_platform_type = 0 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSO', -- application
                    'MSONEW', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
             ELSIF l_platform_type = 1 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSO', -- application
                    'MSONWS64', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
             ELSIF l_platform_type = 2 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSO', -- application
                    'MSONWH64', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
             ELSIF l_platform_type = 3 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSO', -- application
                    'MSONWA64', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
      	      ELSIF l_platform_type = 4 THEN
		 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
		    'MSO', -- application
		    'MSONWL64', -- program
		    NULL, -- description
		    NULL, -- start time
		    FALSE, -- sub_request
		    v_plan_id,
		    0);
	      ELSIF l_platform_type = 5 THEN
		var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
		   'MSO', -- application
		   'MSONWHPIA64', -- program
		   NULL, -- description
		   NULL, -- start time
		   FALSE, -- sub_request
		   v_plan_id,
		   0);

             ELSE
               retcode := 2;
               errbuf := 'Invalid Platform Type'||to_char(l_platform_type);
               return;
             END IF;
           ELSE
             IF l_platform_type = 0 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSC', -- application
                    'MSCNEW', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
             ELSIF l_platform_type = 1 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSC', -- application
                    'MSCNWS64', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
             ELSIF l_platform_type = 2 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSC', -- application
                    'MSCNWH64', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);
             ELSIF l_platform_type = 3 THEN
                 var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
                    'MSC', -- application
                    'MSCNWA64', -- program
                    NULL, -- description
                    NULL, -- start time
                    FALSE, -- sub_request
                    v_plan_id,
                    0);

	    ELSIF l_platform_type = 4 THEN
		var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
		   'MSC', -- application
		   'MSCNWL64', -- program
		   NULL, -- description
		   NULL, -- start time
		   FALSE, -- sub_request
		   v_plan_id,
		   0);
	    ELSIF l_platform_type = 5 THEN
		var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
		   'MSC', -- application
		   'MSCNWHPIA64', -- program
		   NULL, -- description
		   NULL, -- start time
		   FALSE, -- sub_request
		   v_plan_id,
		   0);


             ELSE
               retcode := 2;
               errbuf := 'Invalid Platform Type'||to_char(l_platform_type);
               return;
             END IF;
           END IF;
          END IF;
	UPDATE msc_plans  /* for 24x7 ATP */
  	  SET     request_id =  var_snapshot_req_id
   	 WHERE   plan_id =     v_plan_id;

    COMMIT;
    MSC_UTIL.msc_Debug('Launched Planner:'||
                      to_char(var_planner_req_id));
    END IF;

    begin

    SELECT NVL(production, SYS_NO)
    INTO   var_production1
    FROM   msc_designators
    where organization_id = v_rec_c1.organization_id
    AND sr_instance_id    = v_rec_c1.sr_instance_id
    AND    (designator,designator_type) in
        (select compile_designator, plan_type
        from msc_plans
	Where plan_id = v_plan_id);

    exception when no_data_found then
    null;
    end;

    --pabram..phub
    MSC_UTIL.msc_Debug('phub archive_flag :'|| to_char(p_archive_flag));
    update msc_plans
      set archive_flag = p_archive_flag
    where plan_id = v_plan_id;
    commit;
    --pabram..phub ends
	MSC_UTIL.msc_Debug('Exiting with Success');
    retcode := 0;
    errbuf := NULL;
    return;
EXCEPTION
   when v_ex_error_plan_launch then
	if temp_plan_exist_cur%isopen then
                Close temp_plan_exist_Cur;
        end if;
	retcode := 2;
	if v_lookup_name is not null then
		fnd_message.set_name('MSC',v_lookup_name);
        	fnd_message.set_token('PLAN_NAME',v_rec_c1.compile_designator);
        	errbuf := fnd_message.get;
	end if;
   when OTHERS THEN
       retcode := 2;
	errbuf := sqlerrm;

END msc_launch_plan;


/*========================================================================+
| DESCRIPTION  : This procedure is called for switching plans - original  |
|		and temporary, once synchronization is complete.	  |
+========================================================================*/

PROCEDURE msc_switch_24_7_atp_plans(
					errbuf		OUT NOCOPY VARCHAR2,
					retcode		OUT NOCOPY NUMBER,
					P_Org_plan_id	IN  	   NUMBER,
					P_temp_plan_id	IN  	   NUMBER) IS

		-- --------------------------------------------
        -- Modified for Bug#2748937.  Fetching few more
        -- columns needed to be retained from the new
        -- plan, after restoring plan options.
        -- --------------------------------------------

	Cursor Plan_Name_Cur(p_plan_id in number) Is
	Select	Compile_Designator, Curr_Plan_Type,
	      	Organization_Id, Sr_Instance_Id,Copy_Plan_Id,
		  	Last_Update_Date, Last_Updated_By, Last_Update_Login,
			Append_Planned_Orders, Assignment_Set_Id, Attribute_Category,
			Attribute1, Attribute2, Attribute3, Attribute4,
			Attribute5, Attribute6, Attribute7, Attribute8,
			Attribute9, Attribute10, Attribute11, Attribute12,
			Attribute13, Attribute14, Attribute15, Backward_Days,
			Bill_Of_Resources, Bottleneck_Res_Group, Company_Agg_Level,
			Consider_Po, Consider_Reservations, Consider_Wip,
			Created_By, Creation_Date, Curr_Included_Items, Curr_Schedule_Designator,
			Curr_Schedule_Type, Curr_Snapshot_Lock, Curr_Split_Demands,
			Cutoff_Date, Daily_Trans_Constraints, Data_Completion_Date,
			Data_Start_Date, Dem_Priority_Rule_Id, Demand_Time_Fence_Flag,
			Enable_Closest_Qty_Pegging, Enable_Priority_Pegging,
			Enforce_Cap_Constraints, Enforce_Dem_Due_Dates,
			Enforce_Sl_Constraints, Enforce_Src_Constraints,
			Forward_Days, Full_Pegging, Hard_Pegging_Level, Included_Items,
			Kpi_Refresh, Lot_For_Lot, Max_Wf_Except_Id, Min_Wf_Except_Id,
			Monthly_Cutoff_Bucket,  Objective_Weight_6,
			Objective_Weight_7, Objective_Weight_8, Objective_Weight_9,
			Objective_Weight_10, Online_Planner_Completion_Date,
			Online_Planner_Start_Date, Online_Replan, Operation_Schedule_Type,
			Organization_Selection, Overwrite_Option, Parent_Plan_Id,
			Part_Include_Type, Penalty_Cost_1, Penalty_Cost_2, Penalty_Cost_3,
			Penalty_Cost_4, Penalty_Cost_5, Penalty_Cost_6, Penalty_Cost_7,
			Penalty_Cost_8, Penalty_Cost_9, Penalty_Cost_10, Period_Trans_Constraints,
			Plan_Capacity_Flag, Plan_Completion_Date, Plan_Safety_Stock,
			Plan_Start_Date, Planned_Refreshes, Planned_Resources,
			Planning_Time_Fence_Flag, Product_Agg_Level, Production_Flag,
			Program_Application_Id, Program_Id, Program_Update_Date, Purge,
			Qtrly_Cutoff_Bucket, Refresh_Number, Request_Id, Reservation_Level,
			Revision, Schedule_Designator, Schedule_Type, Simulation_Set,
			Slack_Allowed_Flag_1, Slack_Allowed_Flag_2, Slack_Allowed_Flag_3,
			Slack_Allowed_Flag_4, Slack_Allowed_Flag_5, Slack_Allowed_Flag_6,
			Slack_Allowed_Flag_7, Slack_Allowed_Flag_8, Slack_Allowed_Flag_9,
			Slack_Allowed_Flag_10, Snapshot_Lock, Split_Demands,
			Start_Date, Status, Summary_Flag, Tp_Agg_Level,
			Weekly_Trans_Constraints,
                        curr_start_date,
                        curr_cutoff_date,
                        release_reschedules
			From Msc_Plans
	Where 	Plan_Id = p_plan_id;

	-- Modified (forward port) for the bug # 3021850
	Cursor Desig_Cur(p_plan_id in number) Is
	Select 	Designator_Id,description, Inventory_Atp_Flag, launch_workflow_flag,
			Production, Disable_Date,organization_id, sr_instance_id,
			organization_selection,last_update_date,last_updated_by,last_update_login,nvl(purge_current_plan,2) purge_current_plan
	From Msc_Designators
	Where (Designator, Organization_Id, Sr_Instance_Id) =
		(     Select Compile_Designator, Organization_Id, Sr_Instance_Id
		      From Msc_Plans
		      Where Plan_Id=p_plan_id);

        cursor c_plan_name(p_designator in varchar2) is
                        select designator
                               from   msc_designators
                               where  designator = p_designator;

	v_org_Plan_Name_Cur Plan_Name_Cur%rowtype;
	v_temp_Plan_Name_Cur Plan_Name_Cur%rowtype;
	v_org_Desig_Cur Desig_Cur%rowtype;
	v_temp_Desig_Cur Desig_Cur%rowtype;
	v_req_data	number;
	v_lookup_name   varchar2(100);
        lv_plan_name    varchar2(10);

	ERROR_DELETION EXCEPTION;
Begin

	open plan_name_cur(p_org_plan_id);
	fetch plan_name_cur into v_org_plan_name_Cur;
 	if plan_name_Cur%notfound then
                retcode := 2;
		fnd_message.set_name('MSC','MSC_X_API_INVALID_PLAN_NAME');
                errbuf := fnd_message.get;
		raise error_deletion;
	END IF;
	close plan_name_cur;

	open desig_cur(p_org_plan_id);
	fetch desig_cur into v_org_desig_cur;
	close desig_cur;


	open plan_name_cur(p_temp_plan_id);
	fetch plan_name_cur into v_temp_plan_name_Cur;
	if plan_name_Cur%notfound or v_temp_plan_name_cur.plan_completion_date is null
	  or p_org_plan_id <> v_temp_plan_name_cur.copy_plan_id then
		retcode := 2;
		fnd_message.set_name('MSC','MSC_X_API_INVALID_PLAN_NAME');
                errbuf := fnd_message.get;
		close plan_name_cur;
		raise  error_deletion;
	end if;
	close plan_name_cur;

	open desig_cur(p_temp_plan_id);
	fetch desig_cur into v_temp_desig_cur;
	if desig_cur%notfound then
		retcode:= 2;
		fnd_message.set_name('MSC','MSC_X_API_INVALID_PLAN_NAME');
                errbuf := fnd_message.get;
		close desig_cur;
		raise error_deletion;
	end if;
	close desig_cur;

	-- ------------------------------------
	-- To delete the Plan OPTIONS to enable
	-- to copy fresh plan options.
	-- ------------------------------------

	MSC_COPY_PLAN_OPTIONS.delete_plan_options
	(errbuf, retcode, p_temp_plan_id);
	if nvl(retcode,0) >0 then
		raise error_deletion;
	end if;

	-- ------------------------------------
	-- Set the name of original plan to
	-- temp name, so that the temp plan
	-- can straight a way, be created with
	-- Original Plan's name.
	-- ------------------------------------

	-- Modified (forward port) for the bug # 3021850
        if v_org_desig_cur.purge_current_plan = 2 THEN

         loop
           select '#'||nvl(substr(to_char(msc_24x7_plan_name_s.nextval),-9),msc_24x7_plan_name_s.nextval)
           into   lv_plan_name
           from   dual;

           open  c_plan_name(lv_plan_name);
           fetch c_plan_name into lv_plan_name;

            if c_plan_name%notfound then
            close c_plan_name;
              exit;
            end if;
            close c_plan_name;
          end loop;
        end if;

	-------------------------------------------------------------------------------
        --  Modified for the bug#2850632
        --  Temp plan id is stored in the designator column to maintain the
        --  link. And in case if the purge program has failed, this link
        --  will be used to purge the plan during relaunch. Purge is needed
        --  for the following reasons:
        --  1. Free the partition if the MSC: share partition is set to False
        --  2. Multiple temp plans cannot be created with the same name which
        --     will violate the unique key(designator,sr_instance_id and organization_id)
        -------------------------------------------------------------------------------

	update msc_plans
        set compile_designator = decode(v_org_desig_cur.purge_current_plan,2,lv_plan_name, nvl(substr(to_char(p_temp_plan_id),-10),p_temp_plan_id)),
	--  copy_plan_id=p_temp_plan_id,
            copy_plan_id=decode(v_org_desig_cur.purge_current_plan,2,-1,-2),
	    plan_completion_date = decode(v_org_desig_cur.purge_current_plan,2,v_org_plan_name_Cur.plan_completion_date,null),
	    request_id = decode(v_org_desig_cur.purge_current_plan,2,v_org_plan_name_Cur.request_id,null),
	    data_completion_date = decode(v_org_desig_cur.purge_current_plan,2,v_org_plan_name_Cur.data_completion_date,null),
		    summary_flag = decode(v_org_desig_cur.purge_current_plan,2,v_org_plan_name_Cur.summary_flag,null)
        where plan_id = p_org_plan_id;

        --  Modified for the bug#2850632
	update msc_designators
          set designator = decode(v_org_desig_cur.purge_current_plan,2,lv_plan_name,
                           nvl(substr(to_char(p_temp_plan_id),-10),p_temp_plan_id)),
          --  copy_designator_id = v_temp_desig_cur.designator_id
         copy_designator_id = decode(v_org_desig_cur.purge_current_plan,2,-1,-2),
         inventory_atp_flag = decode(v_org_desig_cur.purge_current_plan,2,2,inventory_atp_flag),
         description        = decode(v_org_desig_cur.purge_current_plan,2,substr(description,1,39)||'-'||v_org_plan_name_Cur.compile_designator,description)
         where designator = v_org_plan_name_Cur.compile_designator
         and organization_id = v_org_desig_cur.organization_id
         and sr_instance_id = v_org_desig_cur.sr_instance_id;


	msc_copy_plan_options.init_plan_id('Y',p_temp_plan_id,v_temp_desig_cur.designator_id);
	msc_copy_plan_options.copy_plan_options
		( p_org_plan_id, 			-- > p_source_plan_id
	          v_org_plan_name_cur.compile_designator,	-- > p_dest_plan_name
		  v_org_desig_Cur.Description,			-- > p_dest_plan_desc
		  --v_org_Desig_Cur.organization_selection, 	-- > p_dest_org_selection
    	          v_org_plan_name_Cur.curr_Plan_Type, 	-- > p_dest_plan_type
		  v_org_desig_Cur.Inventory_Atp_Flag,	-- > p_dest_atp
		  v_org_desig_Cur.production,			-- > p_dest_production
		  v_org_desig_Cur.launch_workflow_flag,	-- > p_dest_notifications
		  v_org_desig_Cur.disable_date,			-- > p_dest_inactive_on
		  v_org_desig_Cur.organization_id ,		-- > p_organization_id
		  v_org_desig_Cur.sr_instance_id);		-- > p_sr_instance_id

	msc_copy_plan_options.init_plan_id('N',NULL,NULL);
 	-- -----------------------------------------------
	-- Set the copy_plan_id to -1. Restore basic info.
	-- modified by planning engine.
	-- -----------------------------------------------
	-- --------------------------------------------
	-- Modified for Bug#2748937. Included few more
	-- columns needed to be retained from the new
	-- plan, after restoring plan options.
	-- ----------------------------------------------
	-- Bug#2761381 - restoring all the columns which
	-- will not be modified from Plan options UI.
	-- ----------------------------------------------
	Update msc_plans
	set copy_plan_id = -1,
		Last_Update_Date	= v_temp_plan_name_cur.Last_Update_Date,
		Last_Updated_By		= v_temp_plan_name_cur.Last_Updated_By,
		Last_Update_Login	= v_temp_plan_name_cur.Last_Update_Login,
		Append_Planned_Orders	= v_temp_plan_name_cur.Append_Planned_Orders,
		Assignment_Set_Id		= v_temp_plan_name_cur.Assignment_Set_Id,
		Attribute_Category		= v_temp_plan_name_cur.Attribute_Category,
		Attribute1				= v_temp_plan_name_cur.Attribute1,
		Attribute2				= v_temp_plan_name_cur.Attribute2,
		Attribute3				= v_temp_plan_name_cur.Attribute3,
		Attribute4				= v_temp_plan_name_cur.Attribute4,
		Attribute5				= v_temp_plan_name_cur.Attribute5,
		Attribute6				= v_temp_plan_name_cur.Attribute6,
		Attribute7				= v_temp_plan_name_cur.Attribute7,
		Attribute8				= v_temp_plan_name_cur.Attribute8,
		Attribute9				= v_temp_plan_name_cur.Attribute9,
		Attribute10				= v_temp_plan_name_cur.Attribute10,
		Attribute11				= v_temp_plan_name_cur.Attribute11,
		Attribute12				= v_temp_plan_name_cur.Attribute12,
		Attribute13				= v_temp_plan_name_cur.Attribute13,
		Attribute14				= v_temp_plan_name_cur.Attribute14,
		Attribute15				= v_temp_plan_name_cur.Attribute15,
		Backward_Days			= v_temp_plan_name_cur.Backward_Days,
		Bill_Of_Resources		= v_temp_plan_name_cur.Bill_Of_Resources,
		Bottleneck_Res_Group	= v_temp_plan_name_cur.Bottleneck_Res_Group,
		Company_Agg_Level		= v_temp_plan_name_cur.Company_Agg_Level,
		Consider_Po				= v_temp_plan_name_cur.Consider_Po,
		Consider_Reservations	= v_temp_plan_name_cur.Consider_Reservations,
		Consider_Wip			= v_temp_plan_name_cur.Consider_Wip,
		Created_By				= v_temp_plan_name_cur.Created_By,
		Creation_Date			= v_temp_plan_name_cur.Creation_Date,
		Curr_Included_Items		= v_temp_plan_name_cur.Curr_Included_Items,
		Curr_Schedule_Designator= v_temp_plan_name_cur.Curr_Schedule_Designator,
		Curr_Schedule_Type		= v_temp_plan_name_cur.Curr_Schedule_Type,
		Curr_Snapshot_Lock		= v_temp_plan_name_cur.Curr_Snapshot_Lock,
		Curr_Split_Demands		= v_temp_plan_name_cur.Curr_Split_Demands,
		Cutoff_Date				= v_temp_plan_name_cur.Cutoff_Date,
		Daily_Trans_Constraints	= v_temp_plan_name_cur.Daily_Trans_Constraints,
		Data_Completion_Date	= v_temp_plan_name_cur.Data_Completion_Date,
		Data_Start_Date			= v_temp_plan_name_cur.Data_Start_Date,
		Dem_Priority_Rule_Id	= v_temp_plan_name_cur.Dem_Priority_Rule_Id,
		Demand_Time_Fence_Flag	= v_temp_plan_name_cur.Demand_Time_Fence_Flag,
		Enable_Closest_Qty_Pegging	= v_temp_plan_name_cur.Enable_Closest_Qty_Pegging,
		Enable_Priority_Pegging	= v_temp_plan_name_cur.Enable_Priority_Pegging,
		Enforce_Cap_Constraints	= v_temp_plan_name_cur.Enforce_Cap_Constraints,
		Enforce_Dem_Due_Dates	= v_temp_plan_name_cur.Enforce_Dem_Due_Dates,
		Enforce_Sl_Constraints	= v_temp_plan_name_cur.Enforce_Sl_Constraints,
		Enforce_Src_Constraints	= v_temp_plan_name_cur.Enforce_Src_Constraints,
		Forward_Days			= v_temp_plan_name_cur.Forward_Days,
		Full_Pegging			= v_temp_plan_name_cur.Full_Pegging,
		Hard_Pegging_Level		= v_temp_plan_name_cur.Hard_Pegging_Level,
		Included_Items			= v_temp_plan_name_cur.Included_Items,
		Kpi_Refresh				= v_temp_plan_name_cur.Kpi_Refresh,
		Lot_For_Lot				= v_temp_plan_name_cur.Lot_For_Lot,
		Max_Wf_Except_Id		= v_temp_plan_name_cur.Max_Wf_Except_Id,
		Min_Wf_Except_Id		= v_temp_plan_name_cur.Min_Wf_Except_Id,
		Monthly_Cutoff_Bucket	= v_temp_plan_name_cur.Monthly_Cutoff_Bucket,
		Objective_Weight_6		= v_temp_plan_name_cur.Objective_Weight_6,
		Objective_Weight_7		= v_temp_plan_name_cur.Objective_Weight_7,
		Objective_Weight_8		= v_temp_plan_name_cur.Objective_Weight_8,
		Objective_Weight_9		= v_temp_plan_name_cur.Objective_Weight_9,
		Objective_Weight_10		= v_temp_plan_name_cur.Objective_Weight_10,
		Online_Planner_Completion_Date	= v_temp_plan_name_cur.Online_Planner_Completion_Date,
		Online_Planner_Start_Date	= v_temp_plan_name_cur.Online_Planner_Start_Date,
		Online_Replan			= v_temp_plan_name_cur.Online_Replan,
		Operation_Schedule_Type	= v_temp_plan_name_cur.Operation_Schedule_Type,
		Organization_Selection	= v_temp_plan_name_cur.Organization_Selection,
		Overwrite_Option		= v_temp_plan_name_cur.Overwrite_Option,
		Parent_Plan_Id			= v_temp_plan_name_cur.Parent_Plan_Id,
		Part_Include_Type		= v_temp_plan_name_cur.Part_Include_Type,
		Penalty_Cost_1			= v_temp_plan_name_cur.Penalty_Cost_1,
		Penalty_Cost_2			= v_temp_plan_name_cur.Penalty_Cost_2,
		Penalty_Cost_3			= v_temp_plan_name_cur.Penalty_Cost_3,
		Penalty_Cost_4			= v_temp_plan_name_cur.Penalty_Cost_4,
		Penalty_Cost_5			= v_temp_plan_name_cur.Penalty_Cost_5,
		Penalty_Cost_6			= v_temp_plan_name_cur.Penalty_Cost_6,
		Penalty_Cost_7			= v_temp_plan_name_cur.Penalty_Cost_7,
		Penalty_Cost_8			= v_temp_plan_name_cur.Penalty_Cost_8,
		Penalty_Cost_9			= v_temp_plan_name_cur.Penalty_Cost_9,
		Penalty_Cost_10			= v_temp_plan_name_cur.Penalty_Cost_10,
		Period_Trans_Constraints= v_temp_plan_name_cur.Period_Trans_Constraints,
		Plan_Capacity_Flag		= v_temp_plan_name_cur.Plan_Capacity_Flag,
		Plan_Completion_Date	= v_temp_plan_name_cur.Plan_Completion_Date,
		Plan_Safety_Stock		= v_temp_plan_name_cur.Plan_Safety_Stock,
		Plan_Start_Date			= v_temp_plan_name_cur.Plan_Start_Date,
		Planned_Refreshes		= v_temp_plan_name_cur.Planned_Refreshes,
		Planned_Resources		= v_temp_plan_name_cur.Planned_Resources,
		Planning_Time_Fence_Flag= v_temp_plan_name_cur.Planning_Time_Fence_Flag,
		Product_Agg_Level		= v_temp_plan_name_cur.Product_Agg_Level,
		Production_Flag			= v_temp_plan_name_cur.Production_Flag,
		Program_Application_Id	= v_temp_plan_name_cur.Program_Application_Id,
		Program_Id				= v_temp_plan_name_cur.Program_Id,
		Program_Update_Date		= v_temp_plan_name_cur.Program_Update_Date,
		Purge					= v_temp_plan_name_cur.Purge,
		Qtrly_Cutoff_Bucket		= v_temp_plan_name_cur.Qtrly_Cutoff_Bucket,
		Refresh_Number			= v_temp_plan_name_cur.Refresh_Number,
		Request_Id				= v_temp_plan_name_cur.Request_Id,
		Reservation_Level		= v_temp_plan_name_cur.Reservation_Level,
		Revision				= v_temp_plan_name_cur.Revision,
		Schedule_Designator		= v_temp_plan_name_cur.Schedule_Designator,
		Schedule_Type			= v_temp_plan_name_cur.Schedule_Type,
		Simulation_Set			= v_temp_plan_name_cur.Simulation_Set,
		Slack_Allowed_Flag_1	= v_temp_plan_name_cur.Slack_Allowed_Flag_1,
		Slack_Allowed_Flag_2	= v_temp_plan_name_cur.Slack_Allowed_Flag_2,
		Slack_Allowed_Flag_3	= v_temp_plan_name_cur.Slack_Allowed_Flag_3,
		Slack_Allowed_Flag_4	= v_temp_plan_name_cur.Slack_Allowed_Flag_4,
		Slack_Allowed_Flag_5	= v_temp_plan_name_cur.Slack_Allowed_Flag_5,
		Slack_Allowed_Flag_6	= v_temp_plan_name_cur.Slack_Allowed_Flag_6,
		Slack_Allowed_Flag_7	= v_temp_plan_name_cur.Slack_Allowed_Flag_7,
		Slack_Allowed_Flag_8	= v_temp_plan_name_cur.Slack_Allowed_Flag_8,
		Slack_Allowed_Flag_9	= v_temp_plan_name_cur.Slack_Allowed_Flag_9,
		Slack_Allowed_Flag_10	= v_temp_plan_name_cur.Slack_Allowed_Flag_10,
		Snapshot_Lock			= v_temp_plan_name_cur.Snapshot_Lock,
		Split_Demands			= v_temp_plan_name_cur.Split_Demands,
		Start_Date				= v_temp_plan_name_cur.Start_Date,
		Status					= v_temp_plan_name_cur.Status,
		Summary_Flag			= v_temp_plan_name_cur.Summary_Flag,
		Tp_Agg_Level			= v_temp_plan_name_cur.Tp_Agg_Level,
		Weekly_Trans_Constraints= v_temp_plan_name_cur.Weekly_Trans_Constraints,
                curr_start_date          = v_temp_plan_name_cur.curr_start_date,
                curr_cutoff_date         = v_temp_plan_name_cur.curr_cutoff_date,
                release_reschedules      = v_temp_plan_name_cur.release_reschedules
	where plan_id = p_temp_plan_id;

	-- --------------------------------
	-- Set Copy_designator_id to -1.
	-- --------------------------------

	update msc_designators
	set copy_designator_id = -1,
		last_update_date	= v_temp_plan_name_Cur.last_update_date,
		last_updated_by		= v_temp_plan_name_Cur.last_updated_by,
		last_update_login	= v_temp_plan_name_Cur.last_update_login,
		request_id			= v_temp_plan_name_cur.request_id,
		program_application_id = v_temp_plan_name_cur.program_application_id,
		program_id			= v_temp_plan_name_cur.program_id,
		program_update_date	= v_temp_plan_name_cur.program_update_date
	where  (designator,organization_id,sr_instance_id)
				= (		select compile_designator,organization_id,sr_instance_id
						from msc_plans
						where plan_id=p_temp_plan_id);

	Update MSC_PLAN_ORGANIZATIONS
	set	plan_completion_date = v_temp_plan_name_cur.Plan_Completion_Date,
		last_updated_by		= v_temp_plan_name_cur.last_updated_by,
		last_update_date	= v_temp_plan_name_cur.last_update_date,
		last_update_login	= v_temp_plan_name_cur.last_update_login,
		request_id			= v_temp_plan_name_cur.request_id,
		program_application_id = v_temp_plan_name_cur.program_application_id,
		program_id			= v_temp_plan_name_cur.program_id,
		program_update_date	= v_temp_plan_name_cur.program_update_date
	Where 	plan_id = p_temp_plan_id;

	Update MSC_PLAN_SCHEDULES
	set last_updated_by		= v_temp_plan_name_cur.last_updated_by,
		last_update_date	= v_temp_plan_name_cur.last_update_date,
		last_update_login	= v_temp_plan_name_cur.last_update_login,
		request_id			= v_temp_plan_name_cur.request_id,
		program_application_id	= v_temp_plan_name_cur.program_application_id,
		program_id			= v_temp_plan_name_cur.program_id,
		program_update_date	= v_temp_plan_name_cur.program_update_date
	Where 	plan_id = p_temp_plan_id;

	Update MSC_SUB_INVENTORIES
	set last_updated_by		= v_temp_plan_name_cur.last_updated_by,
		last_update_date	= v_temp_plan_name_cur.last_update_date,
		last_update_login	= v_temp_plan_name_cur.last_update_login,
		request_id			= v_temp_plan_name_cur.request_id,
		program_application_id	= v_temp_plan_name_cur.program_application_id,
		program_id			= v_temp_plan_name_cur.program_id,
		program_update_date	= v_temp_plan_name_cur.program_update_date
	Where 	plan_id = p_temp_plan_id;

    DECLARE
        TYPE tab_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

        l_rowlist tab_type;

        CURSOR c_pref(p_plan_id IN VARCHAR2) IS
        SELECT ROWID
        FROM MSC_USER_PREFERENCE_VALUES
        WHERE key IN ('ASCP_PLAN_ID','DRP_PLAN_ID')
        AND value = p_plan_id
        FOR UPDATE OF value NOWAIT;


        CURSOR c_schedules(p_designator_id   IN NUMBER,
                           p_organization_id IN NUMBER,
                           p_sr_instance_id  IN NUMBER) IS
        SELECT ROWID
        FROM MSC_PLAN_SCHEDULES
        WHERE input_schedule_id = p_designator_id
        AND organization_id     = p_organization_id
        AND sr_instance_id      = p_sr_instance_id
        FOR UPDATE OF input_schedule_id NOWAIT;

        l_Counter NUMBER;
        l_max_tries CONSTANT Number := 100000;
    BEGIN
        savepoint BF_UPD_PREF;
        MSC_UTIL.msc_Debug('Updating preferences...');
        -- update w/b preferences
        l_Counter := 0;
        LOOP
            BEGIN
                EXIT WHEN l_Counter > l_max_tries;
                l_Counter := l_Counter + 1;
                OPEN c_pref(TO_CHAR(p_org_plan_id));
                FETCH c_pref BULK COLLECT INTO l_rowlist;
                CLOSE  c_pref;

                FORALL I IN 1..l_rowlist.count
                UPDATE MSC_USER_PREFERENCE_VALUES
                SET VALUE=p_temp_plan_id
                WHERE ROWID=l_rowlist(I);
                EXIT;
            EXCEPTION
                WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
                    IF c_pref%ISOPEN THEN
                        CLOSE c_pref;
                    END IF;
                    IF l_Counter > l_max_tries THEN
                        MSC_UTIL.msc_Debug('Unable to lock preference rows.');
                        --RAISE;
                        rollback to BF_UPD_PREF;
                        EXIT;
                    END IF;
                    IF TRUNC(l_Counter/100)*100 = l_Counter THEN
                        MSC_UTIL.msc_Debug('Unable to lock preference rows: ('||l_Counter||') Tries...');
                    END IF;
                END;
        END LOOP;

        savepoint BF_UPD_SCHD;
        MSC_UTIL.msc_Debug('Updating schedules...');
        -- update supply/demand schedules
        l_Counter := 0;
        l_rowlist.delete;
        LOOP
            BEGIN

                l_Counter := l_Counter + 1;

                OPEN c_schedules(v_org_desig_cur.designator_id,
                                 v_org_desig_cur.organization_id,
                                 v_org_desig_cur.sr_instance_id);
                FETCH c_schedules BULK COLLECT INTO l_rowlist;
                CLOSE  c_schedules;

                FORALL I IN 1..l_rowlist.count
                Update MSC_PLAN_SCHEDULES
                SET input_schedule_id = v_temp_desig_cur.designator_id
                WHERE ROWID=l_rowlist(I);
                EXIT;
            EXCEPTION
                WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
                    IF c_pref%ISOPEN THEN
                        CLOSE c_pref;
                    END IF;
                    IF l_Counter > l_max_tries THEN
                        MSC_UTIL.msc_Debug('Unable to lock schedules rows.');
                        --RAISE;
                        rollback to BF_UPD_SCHD;
                        EXIT;
                    END IF;
                    IF TRUNC(l_Counter/100)*100 = l_Counter THEN
                        MSC_UTIL.msc_Debug('Unable to lock schedules rows: ('||l_Counter||') Tries...');
                    END IF;
                END;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            MSC_UTIL.msc_Debug('Error updating preferences and schedules.');
            RAISE;
    END;
    -- Bug#7449943
    Update msc_plans_other
    set ref_plan_id = p_temp_plan_id
    where ref_plan_id = p_org_plan_id;

	commit;

	-- ---------------------------------
	-- To delete the Original Plan,
	-- ---------------------------------
	-- Modified (forward port) for the bug # 3021850
        if nvl(v_org_desig_cur.purge_current_plan,1) = 1 THEN
	MSC_UTIL.msc_Debug('Purging Original plan...'  );
	MSC_COPY_PLAN_OPTIONS.delete_temp_plan
		(errbuf, retcode, v_org_desig_cur.designator_id,FALSE);

	if nvl(retcode,0) >0 then
		raise error_deletion;
	end if;
	commit;
        end if;
	errbuf := null;
	retcode := 0;
EXCEPTION
when error_deletion then
	rollback;
WHEN OTHERS THEN
	rollback;
	retcode := 2;
	errbuf := errbuf||':'|| sqlerrm;
END msc_switch_24_7_atp_plans;

-- ************************* msc_launch_schedule ******************************* --
	PROCEDURE msc_launch_schedule ( errbuf                 OUT  NOCOPY VARCHAR2
                                , retcode                  OUT  NOCOPY NUMBER
                                , arg_plan_id              IN   NUMBER
                                , arg_launch_snapshot      IN   NUMBER
                                , arg_launch_scheduler     IN   NUMBER
                                , arg_ols_horizon_days     IN   NUMBER default null
                                , arg_frozen_horizon_days  IN   NUMBER default null)
IS
  var_snapshot_req_id  INTEGER;
  var_planner_req_id   INTEGER;
  l_platform_type      NUMBER := 0;
  l_call_status        BOOLEAN;
  l_phase              VARCHAR2(80);
  l_status             VARCHAR2(80);
  l_dev_phase          VARCHAR2(80);
  l_dev_status         VARCHAR2(80);
  l_message            VARCHAR2(2048);
  l_industry           VARCHAR2(30);
  l_schema             VARCHAR2(30);
  v_plan_id            NUMBER;
  v_lookup_name        VARCHAR2(100);

  l_executable_name    VARCHAR2(30);

  CURSOR C1(p_plan_id in number)
  IS
  SELECT request_id
  , compile_designator
  FROM msc_plans
  WHERE plan_id = p_plan_id;

  v_rec_c1 c1%rowtype;

  v_ex_error_plan_launch EXCEPTION;
BEGIN

/*================================================================
   Update msc_plans.planning_mode with arg_launch_scheduler
   if arg_launch_scheduler == DS_EXP_ONLY (DS Exception only mode)
   then msc_plans.planning_mode will be set to 1.
   In all other cases msc_plans.planning_mode will be set to NULL
  ================================================================*/
   BEGIN
       update msc_plans
       set planning_mode = decode(arg_launch_scheduler, DS_EXP_ONLY, 1,
							DS_OLS_ONLY, DS_OLS_ONLY,
							NULL),
	   curr_ols_horizon_days = arg_ols_horizon_days,
	   ols_frozen_horizon_days = arg_frozen_horizon_days
       where plan_id = arg_plan_id;

       COMMIT;

   EXCEPTION WHEN OTHERS THEN
       MSC_UTIL.msc_Debug('Error while updating msc_plans.planning_mode. Plan_id = '||to_char(arg_plan_id));
       MSC_UTIL.msc_Debug(SQLERRM);
   END;

  v_plan_id := arg_plan_id;
  open C1(v_plan_id);
  fetch C1 into v_rec_c1;
  Close C1;
  If v_rec_c1.request_id is not null then
    -- -------------------------------------
    -- Check if previous plan output exists.
    -- if existing, check for the status of
    -- of the plan output.
    -- -------------------------------------
    l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS ( v_rec_c1.request_id
                                                      , NULL
                                                      , NULL
                                                      , l_phase
                                                      , l_status
                                                      , l_dev_phase
                                                      , l_dev_status
                                                      , l_message);
    if upper(l_dev_phase) <> 'COMPLETE' then
      v_lookup_name := 'MSC_PLAN_RUNNING'; -- this will be changed to MSC_SCHEDULE_RUNNING
      raise v_ex_error_plan_launch;
    end if;
  End if; -- End Vrec_C1.request_id check

  /*-----------------------------------------------+
  | Insert subinventories into msc_sub_inventories |
  | that are defined after options are defined     |
  +-----------------------------------------------*/
  if (arg_launch_scheduler <> DS_OLS_ONLY) then
      BEGIN
	INSERT INTO MSC_SUB_INVENTORIES
	( SUB_INVENTORY_CODE
	, ORGANIZATION_ID
	, SR_INSTANCE_ID
	, PLAN_ID
	, CREATION_DATE
	, CREATED_BY
	, LAST_UPDATE_LOGIN
	, LAST_UPDATE_DATE
	, LAST_UPDATED_BY
	, NETTING_TYPE
	)
	(
	SELECT msi.sub_inventory_code
	, mpo.organization_id
	, mpo.sr_instance_id
	, v_plan_id
	, SYSDATE
	, 1
	, -1
	, SYSDATE
	, 1
	, msi.netting_type
	FROM msc_sub_inventories msi
	, msc_plan_organizations mpo
	WHERE NOT EXISTS (SELECT NULL
			  FROM MSC_SUB_INVENTORIES SUB
			  WHERE SUB.ORGANIZATION_ID = mpo.organization_id
			  AND sub.sr_instance_id = mpo.sr_instance_id
			  AND SUB.plan_id = mpo.plan_id
			  AND SUB.sub_inventory_code = msi.sub_inventory_code)
	AND msi.ORGANIZATION_ID = mpo.organization_id
	AND msi.sr_instance_id = mpo.sr_instance_id
	AND msi.plan_id = -1
	AND mpo.plan_id = v_plan_id
	);

	COMMIT;

      EXCEPTION
	when no_data_found then
	  null;
      END;
  end if;

  IF (arg_launch_snapshot = SYS_YES) THEN
    var_snapshot_req_id := NULL;
    var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST( 'MSC' -- application
                                                     , 'MSCNSP' -- program
                                                     , NULL  -- description
                                                     , NULL -- start time
                                                     , FALSE -- sub_request
                                                     , v_plan_id -- plan_id
                                                     , 2 -- Launch_CRP_planner
                                                     , 0 -- snapshot_worker
                                                     , 0 -- monitor_pipe
                                                     , 0 -- monitor_request_id
                                                     , 1 -- Netchange_mode
                                                     , 1  -- p_snap_static_entities
                                                     );
    COMMIT;
    MSC_UTIL.msc_Debug('Launched Snapshot:'||to_char(var_snapshot_req_id));
  END IF; /* if arg_launch_snapshot = SYS_YES */

  IF (((arg_launch_scheduler = SYS_YES) AND (arg_launch_snapshot = SYS_NO)) or
      (arg_launch_scheduler = DS_OLS_ONLY)
      ) THEN
    var_planner_req_id := NULL;

    /*-------------+
    | Get platform |
    +-------------*/
    l_platform_type := fnd_profile.value('MSC_PLANNER_PLATFORM');
    IF l_platform_type IS NULL THEN
      l_platform_type := 0;
    END IF;

    IF fnd_installation.get_app_info('MSO',l_status,l_industry,l_schema) <> TRUE THEN
      retcode := 2;
      errbuf := 'Error checking installation status of MSO';
    ELSE
      IF l_status = 'I' THEN
        IF (arg_launch_scheduler = DS_OLS_ONLY) then
	   CASE l_platform_type
	       WHEN 0 THEN l_executable_name := 'MSOOLS';
	       WHEN 1 THEN l_executable_name := 'MSOOLSS64';
	       WHEN 2 THEN l_executable_name := 'MSOOLSH64';
	       WHEN 3 THEN l_executable_name := 'MSOOLSPA64';
	       ELSE
		  retcode := 2;
		  errbuf := 'Invalid Platform Type: '||to_char(l_platform_type);
		  return;
	   END CASE;

	    MSC_UTIL.msc_Debug('Launched Program:'||l_executable_name);

	    var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST('MSO' -- application
							  , l_executable_name
							  , NULL -- description
							  , NULL -- start time
							  , FALSE -- sub_request
							  , v_plan_id
							  , 0
							  , 3 -- batch_process
							  );
        ELSE
	   CASE l_platform_type
	       WHEN 0 THEN l_executable_name := 'MSONEW';
	       WHEN 1 THEN l_executable_name := 'MSONWS64';
	       WHEN 2 THEN l_executable_name := 'MSONWH64';
	       WHEN 3 THEN l_executable_name := 'MSONWA64';
	       ELSE
		  retcode := 2;
		  errbuf := 'Invalid Platform Type: '||to_char(l_platform_type);
		  return;
	   END CASE;

	   MSC_UTIL.msc_Debug('Launched Program:'||l_executable_name);

	   var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST('MSO' -- application
							  , l_executable_name
							  , NULL -- description
							  , NULL -- start time
							  , FALSE -- sub_request
							  , v_plan_id
							  , 0
							  );
	END IF;

      ELSE
        IF l_platform_type = 0 THEN
          var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST( 'MSC' -- application
                                                          , 'MSCNEW' -- program
                                                          , NULL -- description
                                                          , NULL -- start time
                                                          , FALSE -- sub_request
                                                          , v_plan_id
                                                          , 0
                                                          );
        ELSIF l_platform_type = 1 THEN
          var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST( 'MSC' -- application
                                                          , 'MSCNWS64' -- program
                                                          , NULL -- description
                                                          , NULL -- start time
                                                          , FALSE -- sub_request
                                                          , v_plan_id
                                                          , 0
                                                          );
        ELSIF l_platform_type = 2 THEN
          var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST( 'MSC' -- application
                                                          , 'MSCNWH64' -- program
                                                          , NULL -- description
                                                          , NULL -- start time
                                                          , FALSE -- sub_request
                                                          , v_plan_id
                                                          , 0);
        ELSIF l_platform_type = 3 THEN
          var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST( 'MSC' -- application
                                                          , 'MSCNWA64' -- program
                                                          , NULL -- description
                                                          , NULL -- start time
                                                          , FALSE -- sub_request
                                                          , v_plan_id
                                                          , 0);
        ELSE
          retcode := 2;
          errbuf := 'Invalid Platform Type'||to_char(l_platform_type);
          return;
        END IF;
      END IF;
      COMMIT;
    END IF;

    MSC_UTIL.msc_Debug('Launched Planner:'||to_char(var_planner_req_id));
  END IF;

  MSC_UTIL.msc_Debug('Exiting with Success');
  retcode := 0;
  errbuf := NULL;

EXCEPTION
  when v_ex_error_plan_launch then
    retcode := 2;
    if v_lookup_name is not null then
      fnd_message.set_name('MSC',v_lookup_name);
      fnd_message.set_token('PLAN_NAME',v_rec_c1.compile_designator);
      errbuf := fnd_message.get;
    end if;
  when OTHERS THEN
    retcode := 2;
    errbuf := sqlerrm;
END msc_launch_schedule;


-- ************************* MSC_CHECK_PLAN_COMPLETION ******************************* --
-- Procedure which checks for plan completion and returns the completion code.
-- IF the plan is launched in DP_SCN_ONLY_SNP_MODE, check for Planner's completion
-- ELSE check for teh completion of both Snapshot and planner.

PROCEDURE MSC_CHECK_PLAN_COMPLETION(
                      launch_plan_request_id IN  NUMBER,
                      plan_id                IN  NUMBER,
                      completion_code        OUT NOCOPY NUMBER)
IS
   l_snapshot_request_id  NUMBER;
   l_planner_request_id   NUMBER;
   l_request_id           NUMBER;
   l_plan_id              NUMBER;
   l_planning_mode        NUMBER;

   l_out_status           NUMBER;
   l_max_wait_time        NUMBER;

BEGIN
   l_snapshot_request_id := NULL_VALUE;
   l_planner_request_id  := NULL_VALUE;
   l_request_id          := NULL_VALUE;
   l_plan_id             := plan_id;

   ---- ***IMPORTANT -- Get the Max time verified
   l_max_wait_time       := 999999;


   SELECT nvl(request_id, NULL_VALUE)
       INTO   l_request_id
       FROM   msc_plans
       WHERE  plan_id = l_plan_id;


   -- Wait until the request_id is populated in msc_Plans.
   WHILE ( l_request_id < launch_plan_request_id)
   LOOP
      SELECT nvl(request_id, NULL_VALUE)
       INTO   l_request_id
       FROM   msc_plans
       WHERE  plan_id = l_plan_id;

      DBMS_LOCK.SLEEP(10);
   END LOOP;

   -- Request_id is populated. Get the planning Mode
   SELECT planning_mode
       INTO   l_planning_mode
       FROM   msc_plans
       WHERE  plan_id = l_plan_id;

   IF (l_planning_mode is null )  -- Both snapshot and planner would be launched
   THEN
       l_snapshot_request_id := l_request_id;

       -- Wait for Snapshot to complete
       MSC_WAIT_FOR_REQUEST(l_snapshot_request_id, l_max_wait_time, l_out_status);

       IF ( l_out_status = FAILURE_OR_TIMEOUT )
       THEN
           completion_code := SNAPSHOT_FAILURE;
           RETURN;
       END IF;
    END IF;


   --- If there was a snapshot launched then get the plan_request_id.
   IF (l_snapshot_request_id <> NULL_VALUE )
   THEN
       SELECT nvl(request_id, NULL_VALUE)
           INTO   l_request_id
           FROM   msc_plans
           WHERE  plan_id = l_plan_id;

       -- Wait until the Plan_request_id is populated in msc_Plans.
       WHILE ( l_request_id < l_snapshot_request_id)
       LOOP
          SELECT nvl(request_id, NULL_VALUE)
           INTO   l_request_id
           FROM   msc_plans
           WHERE  plan_id = l_plan_id;

          DBMS_LOCK.SLEEP(10);
       END LOOP;
   END IF;

   --- Planner Request_id is populated
   l_planner_request_id := l_request_id;

   --- Wait for planner to complete
   MSC_WAIT_FOR_REQUEST(l_planner_request_id, l_max_wait_time, l_out_status);

   IF ( l_out_status = FAILURE_OR_TIMEOUT )
   THEN
       completion_code := PLANNER_FAILURE;
       RETURN;
   END IF;

   --- Request(s) completed sucessfully
   completion_code := SUCCESS;
   RETURN;

END MSC_CHECK_PLAN_COMPLETION;

-- ************************* MSC_WAIT_FOR_REQUEST ******************************* --

PROCEDURE MSC_WAIT_FOR_REQUEST(
                      p_request_id   IN  number,
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
                                10,
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

       DBMS_LOCK.SLEEP(10);

     END LOOP;

     o_retcode:= SYS_NO;
     RETURN;
END MSC_WAIT_FOR_REQUEST;

Procedure purge_user_notes_data(p_plan_id number)
IS
BEGIN
    DELETE FROM msc_user_notes mun
    WHERE mun.plan_id = p_plan_id
    AND NOT exists (SELECT 1 -- sup.plan_id,sup.transaction_id
                    FROM msc_supplies sup
                    WHERE plan_id = mun.plan_id
                    AND   sup.sr_instance_id = mun.sr_instance_id
                    AND   sup.transaction_id = mun.transaction_id)
    AND MUN.transaction_id is not null;

 /*delete from msc_user_notes
 where plan_id = p_plan_id and
 (plan_id,transaction_id) not in (select plan_id,transaction_id
                                  from msc_supplies
                                  where plan_id = p_plan_id);   */
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END purge_user_notes_data;

END MSC_LAUNCH_PLAN_PK; -- package

/

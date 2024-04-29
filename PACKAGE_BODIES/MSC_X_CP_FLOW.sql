--------------------------------------------------------
--  DDL for Package Body MSC_X_CP_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_CP_FLOW" AS
/* $Header: MSCXCPFB.pls 120.1 2005/08/05 03:08:35 pragarwa noship $ */


  PROCEDURE Start_SCEM_Engine_WF
  IS
    l_wf_type VARCHAR2(8) := 'MSCXSCEM';
    l_wf_key VARCHAR2(240);
    l_wf_process VARCHAR2(30);
    l_sequence_id NUMBER;

  BEGIN

    SELECT 'CP_FLOW-' || TO_CHAR(msc_sup_dem_entries_s.nextval)
      INTO l_wf_key FROM DUAL;

print_user_info('Workflow Key is: ' || l_wf_key);

    l_wf_process := 'START_SCEM_ENGINE';

    -- create a Workflow process for the (item/org/supplier)
    wf_engine.CreateProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , process  => l_wf_process
    );

    -- start Workflow process
    wf_engine.StartProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    );

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Start_SCEM_Engine_WF;

  -- This procedure will lanuch the SCEM engine
  PROCEDURE Launch_SCEM_Engine
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS

      l_result         BOOLEAN;
      l_request_id     NUMBER;

  BEGIN

      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      l_result := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := NULL;
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MSC',       -- application
                      'MSCXNETG',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
			 'N',
			 'N',
			 'N',
			 'N',
			 'N',
			 'Y',
			 'Y',
			 'N',
			 'N',
			 'N',
			 'N'
            );

            commit;

       print_user_info('Supply Chain Event Manager (SCEM) engine launched with concurrent request id ' || l_request_id);
      -- MSC_SCE_LOADS_PKG.LOG_MESSAGE('SCEM engine launched with concurrent request id ' || l_request_id);
/*
  MSC_X_NETTING_PKG.LAUNCH_ENGINE (
            p_errbuf => l_errbuf,
			p_retcode => l_retcode,
			p_early_order => 'N',
			p_changed_order => 'N',
			p_forecast_accuracy => 'N',
			p_forecast_mismatch => 'N',
			p_late_order => 'N',
			p_material_excess => 'Y',
			p_material_shortage => 'Y',
			p_performance => 'N',
			p_potential_late_order => 'N',
			p_response_required => 'N',
			p_custom_exception => 'N'
            );
*/
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Launch_SCEM_Engine;

  PROCEDURE Start_DP_Receive_Forecast_WF
  ( p_customer_id             in number
  , p_horizon_start           in date
  , p_horizon_days            in number
  , p_resp_key IN varchar2
  , p_message_to_tp IN VARCHAR2
  , p_tp_name IN VARCHAR2
  ) IS
    l_wf_type VARCHAR2(8) := 'MSCXDPRF';
    l_wf_key VARCHAR2(240);
    l_wf_process VARCHAR2(30);
    l_sequence_id NUMBER;

    l_tp_role_name VARCHAR2(320);
    l_tp_role_display_name VARCHAR2(360);
    l_tp_role_existing NUMBER;

    -- get the seller(supplier) name
    CURSOR c_tp_name(
      p_resp_key varchar2
    ) IS
      SELECT fu.user_name name
	FROM fnd_responsibility resp
	, fnd_user_resp_groups furg
	, msc_company_users mcu
	, fnd_user fu
	WHERE resp.responsibility_key = p_resp_key
	AND furg.responsibility_id = resp.responsibility_id
	and furg.user_id = mcu.user_id
	and mcu.user_id = fu.user_id
	and mcu.company_id = 1
      ;

    -- check if Workflow role already exists
    CURSOR c_wf_role_existing(
      p_role_name IN VARCHAR2
    ) IS
    SELECT count(1)
    FROM wf_local_roles
    WHERE name = p_role_name
    ;

  BEGIN

    SELECT 'CP_FLOW-' || TO_CHAR(msc_sup_dem_entries_s.nextval)
      INTO l_wf_key FROM DUAL;

print_user_info('Workflow Key is: ' || l_wf_key);

    l_wf_process := 'START_DP_RECEIVE_FORECAST';

    -- create a Workflow process for the (item/org/supplier)
    wf_engine.CreateProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , process  => l_wf_process
    );

    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'CUSTOMER_ID'
    , avalue   => p_customer_id
    );
    wf_engine.SetItemAttrDate
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'START_DATE'
    , avalue   => p_horizon_start
    );
    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'HORIZON_DAYS'
    , avalue   => p_horizon_days
    );

  IF (p_resp_key IS NOT NULL) THEN
    -- start of set up the Workflow role for TP
      l_tp_role_name := 'MSCX_TP_WF_ROLE';
      l_tp_role_display_name := 'Collaborative Planning trading partner role';
      -- check if the Workflow role already exists
      OPEN c_wf_role_existing(
        l_tp_role_name
      );
      FETCH c_wf_role_existing INTO l_tp_role_existing;
      CLOSE c_wf_role_existing;
      IF (l_tp_role_existing <1) THEN -- Workflow role not exists
        BEGIN
          -- create a Ad Hoc Workflow role
          WF_DIRECTORY.CreateAdHocRole(
            role_name => l_tp_role_name
          , role_display_name => l_tp_role_display_name
        );
        EXCEPTION
          WHEN OTHERS THEN
print_user_info('Error when creating Workflow role: sqlerrm = ' || sqlerrm);
        END;
      END IF;

      BEGIN
        -- remove previous WF users from the WF role first
        WF_DIRECTORY.RemoveUsersFromAdHocRole
        ( role_name => l_tp_role_name
        );
      EXCEPTION
        WHEN OTHERS THEN
print_user_info('Error when removing user from Workflow role: sqlerrm = ' || sqlerrm);
      END;

      -- add contact person name(s) of seller to the WF role
      FOR tp_names IN c_tp_name(
        p_resp_key
      ) LOOP
      IF (tp_names.name IS NOT NULL) THEN
        WF_DIRECTORY.AddUsersToAdHocRole(
          role_name => l_tp_role_name
        , role_users => tp_names.name
        );
      END IF;
      END LOOP;
    -- end of set up the Workflow role for seller
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'RECIPIENT_ROLE'
    , avalue   => l_tp_role_name
    );
/*
  ELSIF (p_recipient_name IS NOT NULL) THEN
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'RECIPIENT_ROLE'
    , avalue   => p_recipient_name
    );
*/
  END IF;

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'MESSAGE_TO_TP'
    , avalue   => p_message_to_tp
    );
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'TP_NAME'
    , avalue   => p_tp_name
    );

    -- start Workflow process
    wf_engine.StartProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    );

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Start_DP_Receive_Forecast_WF;

  -- This procedure will lanuch the SCEM engine
  PROCEDURE DP_Receive_Forecast
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS

    l_customer_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'CUSTOMER_ID'
    );
    l_horizon_start DATE := wf_engine.GetItemAttrDate
    ( itemtype
    , itemkey
    , aname    => 'START_DATE'
    );
    l_horizon_days NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'HORIZON_DAYS'
    );

      l_result BOOLEAN;
      l_request_id NUMBER;

     l_aps_customer_id NUMBER;

     CURSOR c_aps_customer_id (p_customer_id IN NUMBER) IS
     SELECT map.tp_key
      FROM msc_trading_partner_maps map
      , msc_company_relationships cr
      WHERE map.map_type = 1 -- company level mapping
      AND cr.object_id = p_customer_id
      AND map.company_key = cr.relationship_id
      AND cr.relationship_type = 1 -- customer
      AND cr.subject_id = 1 -- OEM
      ;

    BEGIN

      OPEN c_aps_customer_id (l_customer_id);
      FETCH c_aps_customer_id INTO l_aps_customer_id;
      CLOSE c_aps_customer_id;

      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      l_result := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := NULL;
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MSD',       -- application
                      'MSDXRCF',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                        'CP_ORDER_FORECAST' -- p_designator in varchar2,
                      , 2 -- p_order_type in number,
                      , NULL -- , l_org_code                -- in varchar2 default null,
                      , NULL -- , l_planner_code            -- in varchar2 default null,
                      , NULL -- , l_item_id                 -- in number   default null,
                      , l_aps_customer_id -- p_customer_id      -- in number   default null,
                      , NULL -- , l_customer_site_id        -- in number   default null,
                      , fnd_date.date_to_canonical(sysdate)-- l_horizon_start -- p_horizon_start  -- in date     default sysdate,
                      , 365 -- l_horizon_end - l_horizon_start + 1 -- p_horizon_days -- l_horizon_days             -- in number   default 365
            );

            commit;

      print_user_info('Receive Forecast from Customer engine launched with concurrent request id ' || l_request_id);

    wf_engine.SetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'REQUEST_ID'
    , avalue   => l_request_id
    );

/*
  MSD_SCE_RECEIVE_FORECAST_PKG.receive_customer_forecast (
    p_errbuf                  => l_errbuf-- out varchar2,
  , p_retcode                 => l_retcode -- out varchar2,
  , p_designator              => 'CP_ORDER_FORECAST' -- in varchar2,
  , p_order_type              => 2 -- in number,
  -- , l_org_code                -- in varchar2 default null,
  -- , l_planner_code            -- in varchar2 default null,
  -- , l_item_id                 -- in number   default null,
  , p_customer_id             => l_customer_id -- in number   default null,
  -- , l_customer_site_id        -- in number   default null,
  , p_horizon_start           => l_horizon_start -- in date     default sysdate,
  , p_horizon_days             => l_horizon_end - l_horizon_start + 1 -- l_horizon_days             -- in number   default 365
  );
*/
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END DP_Receive_Forecast;

  PROCEDURE Receive_Supplier_Capacity_WF
  ( p_supplier_id IN Number
  , p_horizon_start_date In date
  , p_horizon_end_date In date
  , p_resp_key IN varchar2
  , p_message_to_tp IN VARCHAR2
  , p_tp_name IN VARCHAR2
  ) IS

    l_wf_type VARCHAR2(8) := 'MSCXRCSC';
    l_wf_key VARCHAR2(240);
    l_wf_process VARCHAR2(30);
    l_sequence_id NUMBER;

    l_tp_role_name VARCHAR2(320);
    l_tp_role_display_name VARCHAR2(360);
    l_tp_role_existing NUMBER;

    -- get the seller(supplier) name
    CURSOR c_tp_name(
      p_resp_key varchar2
    ) IS
      SELECT fu.user_name name
	FROM fnd_responsibility resp
	, fnd_user_resp_groups furg
	, msc_company_users mcu
	, fnd_user fu
	WHERE resp.responsibility_key = p_resp_key
	AND furg.responsibility_id = resp.responsibility_id
	and furg.user_id = mcu.user_id
	and mcu.user_id = fu.user_id
	and mcu.company_id = 1
      ;

    -- check if Workflow role already exists
    CURSOR c_wf_role_existing(
      p_role_name IN VARCHAR2
    ) IS
    SELECT count(1)
    FROM wf_local_roles
    WHERE name = p_role_name
    ;

  BEGIN

    SELECT 'CP_FLOW-' || TO_CHAR(msc_sup_dem_entries_s.nextval)
      INTO l_wf_key FROM DUAL;

print_user_info('Workflow Key is: ' || l_wf_key);

    l_wf_process := 'RECEIVE_SUPPLIER_CAPACITY';

    -- create a Workflow process for the (item/org/supplier)
    wf_engine.CreateProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , process  => l_wf_process
    );

    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'SUPPLIER_ID'
    , avalue   => p_supplier_id
    );
    wf_engine.SetItemAttrDate
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'START_DATE'
    , avalue   => p_horizon_start_date
    );
    wf_engine.SetItemAttrDate
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'END_DATE'
    , avalue   => p_horizon_end_date
    );

  IF (p_resp_key IS NOT NULL) THEN
    -- start of set up the Workflow role for TP
      l_tp_role_name := 'MSCX_TP_WF_ROLE';
      l_tp_role_display_name := 'Collaborative Planning trading partner role';
      -- check if the Workflow role already exists
      OPEN c_wf_role_existing(
        l_tp_role_name
      );
      FETCH c_wf_role_existing INTO l_tp_role_existing;
      CLOSE c_wf_role_existing;
      IF (l_tp_role_existing <1) THEN -- Workflow role not exists
        BEGIN
          -- create a Ad Hoc Workflow role
          WF_DIRECTORY.CreateAdHocRole(
            role_name => l_tp_role_name
          , role_display_name => l_tp_role_display_name
        );
        EXCEPTION
          WHEN OTHERS THEN
print_user_info('Error when creating Workflow role: sqlerrm = ' || sqlerrm);
        END;
      END IF;

      BEGIN
        -- remove previous WF users from the WF role first
        WF_DIRECTORY.RemoveUsersFromAdHocRole
        ( role_name => l_tp_role_name
        );
      EXCEPTION
        WHEN OTHERS THEN
print_user_info('Error when removing user from Workflow role: sqlerrm = ' || sqlerrm);
      END;

      -- add contact person name(s) of seller to the WF role
      FOR tp_names IN c_tp_name(
        p_resp_key
      ) LOOP
      IF (tp_names.name IS NOT NULL) THEN
        WF_DIRECTORY.AddUsersToAdHocRole(
          role_name => l_tp_role_name
        , role_users => tp_names.name
        );
      END IF;
      END LOOP;
    -- end of set up the Workflow role for seller
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'RECIPIENT_ROLE'
    , avalue   => l_tp_role_name
    );
/*
  ELSIF (p_recipient_name IS NOT NULL) THEN
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'RECIPIENT_ROLE'
    , avalue   => p_recipient_name
    );
*/
  END IF;

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'MESSAGE_TO_TP'
    , avalue   => p_message_to_tp
    );
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'TP_NAME'
    , avalue   => p_tp_name
    );

    -- start Workflow process
    wf_engine.StartProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    );

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Receive_Supplier_Capacity_WF;

  -- This procedure will lanuch the SCEM engine
  PROCEDURE Receive_Supplier_Capacity
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS

    l_supplier_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'SUPPLIER_ID'
    );
    l_horizon_start DATE := wf_engine.GetItemAttrDate
    ( itemtype
    , itemkey
    , aname    => 'START_DATE'
    );
    l_horizon_end DATE := wf_engine.GetItemAttrDate
    ( itemtype
    , itemkey
    , aname    => 'END_DATE'
    );

      l_result BOOLEAN;
      l_request_id NUMBER;

     l_aps_supplier_id NUMBER;
     l_calendar_code	msc_trading_partners.calendar_code%type;

     CURSOR c_aps_supplier_id (p_supplier_id IN NUMBER) IS
     SELECT map.tp_key
      FROM msc_trading_partner_maps map
      , msc_company_relationships cr
      WHERE map.map_type = 1 -- company level mapping
      AND cr.object_id = p_supplier_id
      AND map.company_key = cr.relationship_id
      AND cr.relationship_type = 2 -- supplier
      AND cr.subject_id = 1 -- OEM
      ;

    BEGIN
    begin
    	select distinct mtp.calendar_code
    	into l_calendar_code
    	from msc_designators des, msc_plans p, msc_trading_partners mtp
    	where des.designator = p.compile_designator and
    		des.sr_instance_id = p.sr_instance_id and
    		des.organization_id = p.organization_id and
    		des.production = 1 and
    		p.sr_instance_id = mtp.sr_instance_id and
    		p.organization_id = mtp.sr_tp_id and
    		mtp.partner_type = 3 and
    		des.sr_instance_id = mtp.sr_instance_id and
    		des.organization_id = mtp.sr_tp_id
    		and rownum = 1 order by mtp.calendar_code;
    exception
    	when others then
    		l_calendar_code := null;
    end;

      OPEN c_aps_supplier_id (l_supplier_id);
      FETCH c_aps_supplier_id INTO l_aps_supplier_id;
      CLOSE c_aps_supplier_id;

      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      l_result := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := NULL;
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MSC',       -- application
                      'MSCXRCAP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
	                  -- NULL -- , p_sr_instance_id => NULL -- IN Number,
	  	fnd_date.date_to_canonical(sysdate) -- l_horizon_start -- p_horizon_start_date -- In date,
         	,fnd_date.date_to_canonical(sysdate+ 365) -- l_horizon_end -- p_horizon_end_date  -- In date,
	                  , NULL -- , p_abc_class -- In Varchar2,
	                  , NULL -- p_item_id In Number,
	                  , NULL -- p_planner -- In Varchar2,
	                  , l_aps_supplier_id -- l_supplier_id -- p_supplir_id In number,
	                  , NULL -- p_supplier_site_id -- In Number,
	                  -- no more calendar code, l_calendar_code
	                  , NULL -- p_mps_designator_id -- In Number
	                  , 1    -- p_overwrite default 1
	            	  , 1    -- p_spread_capacity   --- default 1 -- allow spreading

            );

            commit;

      print_user_info('Receive Supplier Capacity engine launched with concurrent request id ' || l_request_id);

    wf_engine.SetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'REQUEST_ID'
    , avalue   => l_request_id
    );

/*
    MSC_X_RECEIVE_CAPACITY_PKG.receive_capacity
    ( p_errbuf => l_errbuf -- OUT VARCHAR2,
    , p_retcode => l_retcode -- OUT VARCHAR2,
	, p_sr_instance_id => NULL -- IN Number,
	, p_horizon_start_date => l_horizon_start -- In date,
	, p_horizon_end_date => l_horizon_end -- In date,
	, p_abc_class => NULL -- In Varchar2,
	, p_item_id => NULL -- In Number,
	, p_planner => NULL -- In Varchar2,
	, p_supplier_id => l_supplier_id  -- In number,
	, p_supplier_site_id => NULL -- In Number,
	, p_mps_designator_id => NULL -- In Number
    );
*/
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Receive_Supplier_Capacity;

  PROCEDURE Start_ASCP_Engine_WF
  ( p_constrained_plan_flag IN NUMBER
  ) IS
    l_wf_type VARCHAR2(8) := 'MSCXASCP';
    l_wf_key VARCHAR2(240);
    l_wf_process VARCHAR2(30);
    l_sequence_id NUMBER;

  BEGIN

    SELECT 'CP_FLOW-' || TO_CHAR(msc_sup_dem_entries_s.nextval)
      INTO l_wf_key FROM DUAL;

print_user_info('Workflow Key is: ' || l_wf_key);

    l_wf_process := 'START_ASCP_ENGINE';

    -- create a Workflow process
    wf_engine.CreateProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , process  => l_wf_process
    );

    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'CONSTRAINED_PLAN_FLAG'
    , avalue   => p_constrained_plan_flag
    );

    -- start Workflow process
    wf_engine.StartProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    );

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Start_ASCP_Engine_WF;

  -- This procedure will lanuch the ASCP engine
  PROCEDURE Launch_ASCP_Engine
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS

  l_plan_id NUMBER;
  l_default_plan_name VARCHAR2(10);

    l_constrained_plan_flag NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'CONSTRAINED_PLAN_FLAG'
    );

      l_result BOOLEAN;
      l_request_id NUMBER;

  CURSOR c_plan_id (p_default_plan_name IN VARCHAR2) IS
  SELECT plan_id
    FROM msc_plans
    WHERE compile_designator = p_default_plan_name
  ;

  BEGIN

  IF (l_constrained_plan_flag = 1) THEN
    l_default_plan_name := FND_PROFILE.VALUE('MSC_DEFAULT_CONST_PLAN');
  ELSIF (l_constrained_plan_flag = 2) THEN
    l_default_plan_name := FND_PROFILE.VALUE('MSC_DEFAULT_UNCONST_PLAN');
  END IF;

  l_plan_id := NULL;
  OPEN c_plan_id(l_default_plan_name);
  FETCH c_plan_id INTO l_plan_id;
  CLOSE c_plan_id;

  IF (l_plan_id IS NULL) THEN
      print_user_info('Default plan name is not valid, please check the profile options for default ASCP plans');
  ELSE
      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      l_result := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := NULL;
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MSC',       -- application
                      'MSCSLPPR5',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
		      l_default_plan_name, --IN VARCHAR2,
						  l_plan_id, -- IN NUMBER,
						  1, -- IN NUMBER,
						  1, -- IN NUMBER,
                          2, -- IN NUMBER,
						  fnd_date.date_to_chardate(SYSDATE) -- IN VARCHAR2
                     );

                     commit;

      print_user_info('Launch Supply Chain Planning Process (ASCP) engine launched with concurrent request id ' || l_request_id);

/*
  msc_launch_plan_pk.msc_launch_plan (
						  errbuf => l_errbuf -- OUT VARCHAR2,
						, retcode => l_retcode -- OUT NUMBER,
						, arg_plan_id => l_plan_id -- IN NUMBER,
						, arg_launch_snapshot => 1 -- IN NUMBER,
						, arg_launch_planner => 1 -- IN NUMBER,
                        , arg_netchange_mode => 2 -- IN NUMBER,
						, arg_anchor_date => TO_CHAR(SYSDATE) -- IN VARCHAR2
                        );

*/
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Launch_ASCP_Engine;


  FUNCTION auto_scem_mode
    RETURN NUMBER IS
    l_return_result NUMBER;
    l_auto_scem_mode NUMBER;
    l_configuration NUMBER;

  BEGIN
    l_auto_scem_mode := FND_PROFILE.VALUE('MSC_X_AUTO_SCEM_MODE');
    l_configuration := NVL(FND_PROFILE.VALUE('MSC_X_CONFIGURATION'), 1);

    IF ( (l_auto_scem_mode = 1) -- LOAD
         AND (l_configuration = 2 OR l_configuration = 3) -- APS+CP OR CP
       )THEN
      l_return_result := 1;
    ELSIF ( (l_auto_scem_mode = 2) -- PUBLISH
         AND (l_configuration = 2 OR l_configuration = 3) -- APS+CP OR CP
       )THEN
      l_return_result := 2;
    ELSIF ( (l_auto_scem_mode = 3) -- ALL
         AND (l_configuration = 2 OR l_configuration = 3) -- APS+CP OR CP
       )THEN
      l_return_result := 3;
    END IF;

    RETURN l_return_result;

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END auto_scem_mode;

  PROCEDURE Publish_Supply_Commits_WF
  ( p_plan_id                 in number
  ) IS
    l_wf_type VARCHAR2(8) := 'MSCXPBSC';
    l_wf_key VARCHAR2(240);
    l_wf_process VARCHAR2(30);
    l_sequence_id NUMBER;

  BEGIN

    SELECT 'CP_FLOW-' || TO_CHAR(msc_sup_dem_entries_s.nextval)
      INTO l_wf_key FROM DUAL;

print_user_info('Workflow Key is: ' || l_wf_key);

    l_wf_process := 'PUBLISH_SUPPLY_COMMIT';

    -- create a Workflow process for the (item/org/supplier)
    wf_engine.CreateProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , process  => l_wf_process
    );

    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'PLAN_ID'
    , avalue   => p_plan_id
    );

    -- start Workflow process
    wf_engine.StartProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    );

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Publish_Supply_Commits_WF;

  -- This procedure will lanuch the SCEM engine
  PROCEDURE Publish_Supply_Commits
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS

    l_plan_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'PLAN_ID'
    );

      l_result BOOLEAN;
      l_request_id NUMBER;

  BEGIN
      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      l_result := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := NULL;
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MSC',       -- application
                      'MSCXSCP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      l_plan_id, 	--p_plan_id --in number,
  		      null,		--p_org_code
		      null, 		--p_planner_code
 		      null, 		--p_abc_class
  		      null,		--p_item_id
  		      null,		--p_planning_gp
		      null,		--p_project_id
 		      null, 		--p_task_id
		      null, 		--p_source_customer_id
 		      null,		--p_source_customer_site_id
  		      fnd_date.date_to_chardate(SYSDATE) , 		--p_horizon_start
  		      fnd_date.date_to_chardate(SYSDATE + 365) ,	--p_horizon_end
  		      1,		--p_auto_version    default 1,
 		      null,		--p_version
 		      2,		--p_include_so_flag default 2
 		      1			--p_overwrite default 1
                     );

                     commit;

      print_user_info('Publish Supply Commits engine launched with concurrent request id ' || l_request_id);
/*
  msc_sce_pub_supply_commit_pkg.publish_supply_commits (
    p_errbuf                  => l_errbuf --out varchar2,
  , p_retcode                 => l_retcode --out varchar2,
  , p_plan_id                 => l_plan_id --in number,
  -- , p_org_code                => --in  varchar2 default null,
  -- , p_planner_code            => --in  varchar2 default null,
  -- , p_abc_class               => --in  varchar2 default null,
  -- , p_item_id                 => --in  number   default null,
  -- , p_planning_gp             => --in  varchar2 default null,
  -- , p_project_id              => --in  number   default null,
  -- , p_task_id                 => --in  number   default null,
  -- , p_source_customer_id      => --in  number   default null,
  -- , p_source_customer_site_id => --in  number   default null,
  -- , p_horizon_start           => --in  date     default sysdate,
  -- , p_horizon_end             => --in  date     default sysdate+365,
  -- , p_auto_version            => --in  number   default 1,
  -- , p_version                 => --in  number   default null
  );
*/
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Publish_Supply_Commits;

  PROCEDURE Publish_Order_Forecast_WF
  ( p_plan_id                 in number
  ) IS
    l_wf_type VARCHAR2(8) := 'MSCXPBOF';
    l_wf_key VARCHAR2(240);
    l_wf_process VARCHAR2(30);
    l_sequence_id NUMBER;

      l_result BOOLEAN;
      l_request_id NUMBER;

  BEGIN

    SELECT 'CP_FLOW-' || TO_CHAR(msc_sup_dem_entries_s.nextval)
      INTO l_wf_key FROM DUAL;


print_user_info('Workflow Key is: ' || l_wf_key);

    l_wf_process := 'START_PUBLISH_ORDER_FORECAST';

    -- create a Workflow process for the (item/org/supplier)
    wf_engine.CreateProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , process  => l_wf_process
    );

    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    , aname    => 'PLAN_ID'
    , avalue   => p_plan_id
    );

    -- start Workflow process
    wf_engine.StartProcess
    ( itemtype => l_wf_type
    , itemkey  => l_wf_key
    );

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Publish_Order_Forecast_WF;

  PROCEDURE Publish_Order_Forecast
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS

    l_plan_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype
    , itemkey
    , aname    => 'PLAN_ID'
    );

      l_result BOOLEAN;
      l_request_id NUMBER;
  BEGIN
      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      l_result := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := NULL;
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MSC',       -- application
                      'MSCXPO',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      l_plan_id, 	--p_plan_id --in number,
 		      null,		--p_org_code
                      null,		--p_planner_code
                      null,		--p_abc_class
                      null,		--p_item_id
                      null,		--p_item_list
                      null,		--p_planning_gp
                      null,		--p_project_id
                      null,		--p_task_id
                      null,		--p_source_supplier_id
                      null,		--p_source_supplier_site_id
                      fnd_date.date_to_chardate(SYSDATE) ,		--p_horizon_start
                      fnd_date.date_to_chardate(SYSDATE + 365) ,	--p_horizon_end
                      1,		--  p_auto_version default 1
                      null,		--p_version
                      2,		--p_purchase_order default 2
                      2,		--p_requisition default 2
                      1			--p_overwrite default 1
                     );

                     commit;

      print_user_info('Publish Order Forecast engine launched with concurrent request id ' || l_request_id);
/*
  msc_sce_publish_pkg.publish_plan_orders
(
  p_errbuf                  => l_errbuf, -- out varchar2,
  p_retcode                 => l_retcode, -- out varchar2,
  p_plan_id                 => l_plan_id -- in number,
  p_org_code                => -- in varchar2 default null,
  p_planner_code            => -- in varchar2 default null,
  p_abc_class               => -- in varchar2 default null,
  p_item_id                 => -- in number   default null,
  p_planning_gp             => -- in varchar2 default null,
  p_project_id              => -- in number   default null,
  p_task_id                 => -- in number   default null,
  p_source_supplier_id      => -- in number   default null,
  p_source_supplier_site_id => -- in number   default null,
  p_horizon_start           => -- in date     default sysdate,
  p_horizon_end             => -- in date     default sysdate+365,
  p_auto_version            => -- in number   default 1,
  p_version                 => -- in number   default null,
  p_source_order_type       => -- in number   default 5
  );
*/
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END Publish_Order_Forecast;

  -- This procesure prints out debug information
  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  )IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'DEBUG: ' || p_debug_info);
    -- dbms_output.put_line(p_debug_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
  END print_debug_info;

  -- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  )IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'USER: ' || p_user_info);
    -- dbms_output.put_line(p_user_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
  END print_user_info;

END MSC_X_CP_FLOW;

/

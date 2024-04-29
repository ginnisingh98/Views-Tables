--------------------------------------------------------
--  DDL for Package Body MSC_WF_ALLOC_ATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WF_ALLOC_ATP" AS -- package body
/* $Header: MSCWFATB.pls 120.3.12010000.2 2008/05/26 10:29:47 arrsubra ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

   --  ================= Procedures ====================

--ATP Debug Workflow
PROCEDURE DEBUG_WF(
                    p_session_id         IN  NUMBER,
                    p_login_user         IN  VARCHAR2,
                    p_session_loc_des    IN  VARCHAR2,
                    p_trace_loc_des      IN  VARCHAR2,
                    p_spid_des           IN  NUMBER
) IS
PG_DEBUG_SRC  varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');
DEBUG_LOC_SRC varchar2(100);
SPID_SRC      NUMBER;
l_process     VARCHAR2(30) := 'ATP_DEBUG_NOTIFY';
l_itemtype    VARCHAR2(30) := 'MSCDBG';
l_itemkey     VARCHAR2(30);
TRACE_LOC_SRC varchar2(4000);

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || 'Debug WF started'||' p_session_id '|| p_session_id || ' p_login_user '|| p_login_user );
    END IF;

    select ltrim(rtrim(substr(value, instr(value,',',-1,1)+1)))
    into DEBUG_LOC_SRC
    from v$parameter where name= 'utl_file_dir';

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || DEBUG_LOC_SRC );
    END IF;

    IF (PG_DEBUG_SRC = 'C') THEN
         SELECT spid
         INTO   SPID_SRC
         FROM   v$process
         WHERE  addr = (SELECT paddr FROM v$session
                        WHERE audsid=userenv('SESSIONID'));
         SELECT value
         INTO TRACE_LOC_SRC
         FROM v$parameter
         WHERE name = 'user_dump_dest';
    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || SPID_SRC );
    END IF;

    --Create work_flow process

    select p_session_id ||':'||mrp_atp_schedule_temp_s.nextval
    into l_itemkey
    from mrp_atp_details_temp
    where rownum = 1;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || l_itemkey );
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || 'CreateProcess' );
    END IF;
    wf_engine.CreateProcess(
             itemtype => l_itemtype,
             itemkey  => l_itemkey,
             process  => l_process);

    --setting parameters

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || 'Setting Param' );
    END IF;

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SESSION_ID',
            avalue   => p_session_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('debug_wf: p_session_id ' || p_session_id );
    END IF;

    wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'DEBUG_LOC_SRC',
            avalue   => DEBUG_LOC_SRC);

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: DEBUG_LOC_SRC ' || DEBUG_LOC_SRC );
    END IF;

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SPID_SRC',
            avalue   => SPID_SRC);

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: SPID_SRC ' || SPID_SRC );
    END IF;

    wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'TRACE_LOC_SRC',
            avalue   => TRACE_LOC_SRC);

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: TRACE_LOC_SRC ' || TRACE_LOC_SRC );
    END IF;

    wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'DEBUG_LOC_DES',
            avalue   => p_session_loc_des);

    IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('debug_wf: DEBUG_LOC_DES ' || p_session_loc_des );
    END IF;

    wf_engine.SetItemAttrNumber(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'SPID_DES',
            avalue   => p_spid_des);

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: SPID_DES ' || p_spid_des );
    END IF;

    wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'TRACE_LOC_DES',
            avalue   => p_trace_loc_des);

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: TRACE_LOC_DES ' || p_trace_loc_des );
    END IF;

    wf_engine.SetItemAttrText(
            itemtype => l_itemtype,
            itemkey  => l_itemkey,
            aname    => 'LOGIN_USER',
            avalue   => p_login_user);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('debug_wf: LOGIN_USER ' || p_login_user );
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('debug_wf: ' || 'starting process' );
    END IF;

    wf_engine.StartProcess(
             itemtype => l_itemtype,
             itemkey  => l_itemkey);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('debug_wf: ' || 'Debug WF done' );
    END IF;

END DEBUG_WF;
--ATP Debug Workflow

PROCEDURE start_mscalloc_wf(
		p_itemkey 		IN	VARCHAR2,
		p_inventory_item_id	IN	NUMBER,
		p_inventory_item_name	IN	VARCHAR2,
		p_plan_id		IN	NUMBER,
		p_organization_id	IN	NUMBER,
		p_organization_code	IN	VARCHAR2,
		p_instance_id		IN	NUMBER,
		p_demand_class		IN	VARCHAR2,
		p_requested_qty		IN	NUMBER,
		p_request_date		IN	DATE,
		p_request_date_qty	IN	NUMBER,
		p_available_qty		IN	NUMBER,
		p_available_date	IN	DATE,
		p_stolen_qty		IN	NUMBER,
		p_customer_id		IN	NUMBER,
		p_customer_site_id	IN	NUMBER,
		p_order_number		IN	NUMBER)
	IS
		-- wf variables
		l_itemtype 		VARCHAR2(10) := 'MSCALLOC';
		l_profile		VARCHAR2(1);
		l_username		VARCHAR2(100);
		l_plan_name		VARCHAR2(10);
		l_customer_class	VARCHAR2(100);
		l_customer		VARCHAR2(100);
		l_location		VARCHAR2(40);
		l_address		VARCHAR2(1600);

		-- Bug 1757371, username and plan name was not being picked up in case
		-- planner belongs to a different org than item.
		CURSOR PLANNER_C( p_plan_id in number, p_inventory_item_id in number,
			p_organization_id in number, p_instance_id in number)
		IS
		SELECT  distinct pl.user_name, p.compile_designator
		FROM    msc_planners pl,
			msc_system_items sys,
			msc_plans p
		WHERE   sys.plan_id = p_plan_id
		AND     sys.organization_id = p_organization_id
		AND     sys.sr_instance_id = p_instance_id
		AND     sys.sr_inventory_item_id = p_inventory_item_id
		AND	sys.plan_id = p.plan_id
		--AND     pl.organization_id = sys.organization_id
		AND     pl.sr_instance_id = sys.sr_instance_id
		AND     pl.planner_code = sys.planner_code;
	BEGIN
		-- Check if the profile has been set for workflow to be installed
		-- and activated.
		l_profile := fnd_profile.value('MSC_ALLOCATED_ATP_WORKFLOW');
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('start_mscalloc_wf: ' || 'WF Profile:' || l_profile);
		END IF;

		IF NVL(l_profile, 'N') = 'N' THEN
		    IF PG_DEBUG in ('Y', 'C') THEN
		       msc_sch_wb.atp_debug('start_mscalloc_wf: ' || '***Allocated ATP Workflow Profile = No***');
		    END IF;
			RETURN;
		END IF;

		wf_engine.CreateProcess(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			process  => 'ALLOCATEDATPNOTIFY');

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('start_mscalloc_wf: ' || 'Starting wf:' || p_itemkey);
	   msc_sch_wb.atp_debug('start_mscalloc_wf: ' || 'Starting wf:' || to_char(p_inventory_item_id));
	END IF;

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'INVENTORY_ITEM_ID',
			avalue   => p_inventory_item_id);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'INVENTORY_ITEM_NAME',
			avalue   => p_inventory_item_name);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'PLAN_ID',
			avalue   => p_plan_id);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'ORGANIZATION_ID',
			avalue   => p_organization_id);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'ORGANIZATION_CODE',
			avalue   => p_organization_code);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'INSTANCE_ID',
			avalue   => p_instance_id);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'DEMAND_CLASS',
			avalue   => p_demand_class);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'REQUESTED_QTY',
			avalue   => p_requested_qty);

		wf_engine.SetItemAttrDate(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'REQUESTED_DATE',
			avalue   => p_request_date);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'REQUEST_DATE_QTY',
			avalue   => p_request_date_qty);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'AVAILABLE_QTY',
			avalue   => p_available_qty);

		wf_engine.SetItemAttrDate(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'AVAILABLE_DATE',
			avalue   => p_available_date);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'STOLEN_QTY',
			avalue   => p_stolen_qty);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'ALLOCATED_QTY',
			avalue   => LEAST(p_requested_qty, NVL(p_request_date_qty,0)) -
                                             NVL(p_stolen_qty, 0));

                -- bug 1831563.  instead of using msc_trading_partners and
                -- msc_trading_partner_sites directly,we need to join to id_lid

		SELECT	tp.customer_class_code, tp.partner_name,
                        tps.location, tps.partner_address
		INTO	l_customer_class, l_customer, l_location, l_address
		FROM	msc_tp_id_lid tplid,
                        msc_trading_partners tp,
                        msc_tp_site_id_lid tpslid,
			msc_trading_partner_sites tps
		WHERE	tplid.sr_tp_id  =  p_customer_id
                AND     tplid.sr_instance_id = p_instance_id
                AND     tplid.partner_type = 2
                AND     tpslid.sr_tp_site_id = p_customer_site_id
                AND     tpslid.sr_instance_id =  p_instance_id
                AND     tpslid.partner_type = 2
                AND     tp.partner_id = tplid.tp_id
                AND     tps.partner_site_id = tpslid.tp_site_id ;

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUST_CLASS',
			avalue   => l_customer_class);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUSTOMER',
			avalue   => l_customer);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUST_LOCATION',
			avalue   => l_location);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUST_ADDRESS',
			avalue   => l_address);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'ORDER_NUMBER',
			avalue   => p_order_number);

	-- Get username (planner name) for forwarding the notifications.
		OPEN PLANNER_C(p_plan_id, p_inventory_item_id,
			p_organization_id, p_instance_id);
		FETCH PLANNER_C INTO l_username, l_plan_name;
		CLOSE PLANNER_C;

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'PLAN_NAME',
			avalue   => l_plan_name);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'USERNAME',
			avalue   => l_username);

		wf_engine.StartProcess(
			itemtype => l_itemtype,
			itemkey  => p_itemkey);
	END start_mscalloc_wf;


	PROCEDURE Within_Allocation(
		itemtype  in 	varchar2,
		itemkey   in 	varchar2,
		actid     in 	number,
		funcmode  in 	varchar2,
		resultout out 	NoCopy varchar2)
	IS
		l_allocated_qty		NUMBER;
		l_requested_qty		NUMBER;
	BEGIN

		l_allocated_qty := wf_engine.GetItemAttrNumber(
			itemtype => itemtype,
			itemkey  => itemkey,
			aname    => 'ALLOCATED_QTY');

		l_requested_qty := wf_engine.GetItemAttrNumber(
			itemtype => itemtype,
			itemkey  => itemkey,
			aname    => 'REQUESTED_QTY');

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Within_Allocation: ' || 'Inside Shortage:' || l_allocated_qty ||
			' : '||l_requested_qty);
	END IF;

		if (NVL(l_allocated_qty, 0) >= NVL(l_requested_qty, 0)) then
			resultout := 'COMPLETE:Y';
		else
			resultout := 'COMPLETE:N';
		end if;

		return;
	END Within_Allocation;

	PROCEDURE Qty_Stolen(
		itemtype  in 	varchar2,
		itemkey   in 	varchar2,
		actid     in 	number,
		funcmode  in 	varchar2,
		resultout out 	NoCopy varchar2)
	IS
		l_stolen_qty		NUMBER;
	BEGIN

		l_stolen_qty := wf_engine.GetItemAttrNumber(
			itemtype => itemtype,
			itemkey  => itemkey,
			aname    => 'STOLEN_QTY');

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Qty_Stolen: ' || 'Inside Stolen:' || l_stolen_qty);
	END IF;

		if NVL(l_stolen_qty, 0) > 0 then
			resultout := 'COMPLETE:Y';
		else
			resultout := 'COMPLETE:N';
		end if;

		return;
	END Qty_Stolen;

	PROCEDURE ATP_Satisfy(
		itemtype  in 	varchar2,
		itemkey   in 	varchar2,
		actid     in 	number,
		funcmode  in 	varchar2,
		resultout out 	NoCopy varchar2)
	IS
		l_request_date_qty	NUMBER;
		l_requested_qty		NUMBER;
	BEGIN

		l_request_date_qty := wf_engine.GetItemAttrNumber(
			itemtype => itemtype,
			itemkey  => itemkey,
			aname    => 'REQUEST_DATE_QTY');

		l_requested_qty := wf_engine.GetItemAttrNumber(
			itemtype => itemtype,
			itemkey  => itemkey,
			aname    => 'REQUESTED_QTY');

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('ATP_Satisfy: ' || 'Inside ATP Satisfy:' || l_request_date_qty);
	END IF;

		if (NVL(l_request_date_qty, 0) >= NVL(l_requested_qty, 0)) then
			resultout := 'COMPLETE:Y';
		else
			resultout := 'COMPLETE:N';
		end if;

		return;
	END ATP_Satisfy;


        PROCEDURE start_mscatp_wf(
                p_itemkey               IN      VARCHAR2,
                p_inventory_item_id     IN      NUMBER,
                p_inventory_item_name   IN      VARCHAR2,
                p_plan_id               IN      NUMBER,
                p_organization_id       IN      NUMBER,
                p_organization_code     IN      VARCHAR2,
                p_instance_id           IN      NUMBER,
                p_demand_class          IN      VARCHAR2,
                p_requested_qty         IN      NUMBER,
                p_request_date          IN      DATE,
                p_request_date_qty      IN      NUMBER,
                p_available_qty         IN      NUMBER,
                p_available_date        IN      DATE,
                p_customer_id           IN      NUMBER,
                p_customer_site_id      IN      NUMBER,
                p_order_number          IN      NUMBER,
		p_line_number		IN	NUMBER)
	IS
		-- wf variables
		l_itemtype 		VARCHAR2(10) := 'MSCATP';
		l_profile		VARCHAR2(1);
		l_username		VARCHAR2(100);
		l_plan_name		VARCHAR2(10);
		l_customer_class	VARCHAR2(100);
		l_customer		VARCHAR2(100);
		l_location		VARCHAR2(40);
		l_address		VARCHAR2(1600);

		-- Bug 1757371, username and plan name was not being picked up in case
		-- planner belongs to a different org than item.
		CURSOR PLANNER_C
		IS
		SELECT  distinct pl.user_name, p.compile_designator
		FROM    msc_planners pl,
			msc_system_items sys,
			msc_plans p
		WHERE   sys.plan_id = p_plan_id
		AND     sys.organization_id = p_organization_id
		AND     sys.sr_instance_id = p_instance_id
		AND     sys.sr_inventory_item_id = p_inventory_item_id
		AND	sys.plan_id = p.plan_id
		--AND     pl.organization_id = sys.organization_id
		AND     pl.sr_instance_id = sys.sr_instance_id
		AND     pl.planner_code = sys.planner_code;
	BEGIN
		-- Check if the profile has been set for workflow to be installed
		-- and activated.
		l_profile := fnd_profile.value('MSC_ALLOCATED_ATP_WORKFLOW');
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('start_mscatp_wf: ' || 'WF Profile:' || l_profile);
		END IF;

		IF NVL(l_profile, 'N') = 'N' THEN
		    IF PG_DEBUG in ('Y', 'C') THEN
		       msc_sch_wb.atp_debug('start_mscatp_wf: ' || '***Allocated ATP Workflow Profile = No***');
		    END IF;
			RETURN;
		END IF;

		wf_engine.CreateProcess(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			process  => 'ATP_OVERRIDE_NOTIFY');

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('start_mscatp_wf: ' || 'Starting wf:' || p_itemkey);
	   msc_sch_wb.atp_debug('start_mscatp_wf: ' || 'Starting wf:' || to_char(p_inventory_item_id));
	END IF;

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'INVENTORY_ITEM_NAME',
			avalue   => p_inventory_item_name);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'ORGANIZATION_CODE',
			avalue   => p_organization_code);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'DEMAND_CLASS',
			avalue   => p_demand_class);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'REQUESTED_QTY',
			avalue   => p_requested_qty);

		wf_engine.SetItemAttrDate(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'REQUESTED_DATE',
			avalue   => p_request_date);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'REQUEST_DATE_QTY',
			avalue   => p_request_date_qty);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'AVAILABLE_QTY',
			avalue   => p_available_qty);

		wf_engine.SetItemAttrDate(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'AVAILABLE_DATE',
			avalue   => p_available_date);


                -- bug 1831563.  instead of using msc_trading_partners and
                -- msc_trading_partner_sites directly,we need to join to id_lid

		SELECT	tp.customer_class_code, tp.partner_name,
                        tps.location, tps.partner_address
		INTO	l_customer_class, l_customer, l_location, l_address
		FROM	msc_tp_id_lid tplid,
                        msc_trading_partners tp,
                        msc_tp_site_id_lid tpslid,
			msc_trading_partner_sites tps
		WHERE	tplid.sr_tp_id  =  p_customer_id
                AND     tplid.sr_instance_id = p_instance_id
                AND     tplid.partner_type = 2
                AND     tpslid.sr_tp_site_id = p_customer_site_id
                AND     tpslid.sr_instance_id =  p_instance_id
                AND     tpslid.partner_type = 2
                AND     tp.partner_id = tplid.tp_id
                AND     tps.partner_site_id = tpslid.tp_site_id ;

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUST_CLASS',
			avalue   => l_customer_class);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUSTOMER',
			avalue   => l_customer);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUST_LOCATION',
			avalue   => l_location);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'CUST_ADDRESS',
			avalue   => l_address);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'ORDER_NUMBER',
			avalue   => p_order_number);

		wf_engine.SetItemAttrNumber(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'LINE_NUMBER',
			avalue   => p_line_number);

	-- Get username (planner name) for forwarding the notifications.
		OPEN PLANNER_C;
		FETCH PLANNER_C INTO l_username, l_plan_name;
		CLOSE PLANNER_C;

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'PLAN_NAME',
			avalue   => l_plan_name);

		wf_engine.SetItemAttrText(
			itemtype => l_itemtype,
			itemkey  => p_itemkey,
			aname    => 'USERNAME',
			avalue   => l_username);

		wf_engine.StartProcess(
			itemtype => l_itemtype,
			itemkey  => p_itemkey);
	END start_mscatp_wf;



END MSC_WF_ALLOC_ATP;

/

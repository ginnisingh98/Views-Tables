--------------------------------------------------------
--  DDL for Package Body MSC_ATP_24X7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_24X7" AS
/* $Header: MSCTATPB.pls 120.3.12010000.4 2009/08/04 07:45:58 sbnaik ship $  */

G_PKG_NAME 		CONSTANT 	VARCHAR2(30) := 'MSC_ATP_24x7';
G_TFS_ERROR             VARCHAR2(70);
G_TFS_ERRCODE           NUMBER;
G_FND_USER           	NUMBER;

---------------------------------------------------------------------------------
-- Function Declarations


PROCEDURE ATP_SYNCHRONIZE (
        p_old_plan_id       IN              NUMBER,
        p_new_plan_id       IN              NUMBER,
        x_return_status     OUT NOCOPY      VARCHAR2,
        ERRBUF              OUT NOCOPY      VARCHAR2
);

PROCEDURE Synchronize_Call_To_ATP (
        p_atp_table         IN              MRP_ATP_PUB.ATP_Rec_Typ,
        p_session_id        IN      		number,
        x_total_time        OUT NOCOPY      number,
        x_return_status     OUT NOCOPY      varchar2
);

-- This procedure is not used anymore as 24x7 doesn't process pre-collection records since
-- MDS is not supported for 24x7 ATP plans.

PROCEDURE Get_Records_Pre_Collections (
        p_old_plan_id       IN              number,
        p_new_plan_id       IN              number,
        x_atp_rec           OUT NOCOPY      MRP_ATP_PUB.ATP_Rec_Typ,
        x_record_count      OUT NOCOPY      number,
        x_return_status     OUT NOCOPY      varchar2
);

PROCEDURE Get_Records_Post_Collections  (
        p_old_plan_id       IN              number,
        p_new_plan_id       IN              number,
        p_session_id        IN              number,
        x_atp_rec           OUT NOCOPY      MRP_ATP_PUB.ATP_Rec_Typ,
        x_record_count      OUT NOCOPY      number,
        x_return_status     OUT NOCOPY      varchar2
);

PROCEDURE Update_Sync_flag (
        p_atp_table         IN              MRP_ATP_PUB.ATP_Rec_Typ,
        p_old_plan_id       IN              number,
        x_return_status     OUT NOCOPY      varchar2
);

PROCEDURE ATP_Downtime_Init (
        p_old_plan_id       IN              number,
        p_new_plan_id       IN              number,
        x_return_status     OUT NOCOPY      varchar2
);


PROCEDURE ATP_Downtime_Complete (
        p_old_plan_id       IN              number,
        p_new_plan_id       IN              number,
        x_return_status     OUT NOCOPY      varchar2
);


PROCEDURE ATP_Sync_Error (
        p_old_plan_id       IN              number,
        p_new_plan_id       IN              number
);

PROCEDURE Calculate_Downtime_SO_Records (
        p_number_of_records  IN             number,
        p_total_time         IN             number
);


PROCEDURE Update_Summary_Flag (
        p_plan_id           IN              number,
        p_status            IN              number,
        x_return_status     OUT NOCOPY      varchar2
);

-- CTO Re-arch changes, this procedure will not be used anymore, instead MSC_SATP_FUNC.New_Extend_Atp is used.
PROCEDURE extend_atp_rec_typ (
        p_atp_tab           IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
        p_size              IN              number
);

PROCEDURE Extended_Sync_Wait (
        l_time              IN              number,
        x_return_status     OUT NOCOPY      varchar2
);

PROCEDURE Print_Input_Rec (
        x_atp_rec           IN              MRP_ATP_PUB.ATP_Rec_Typ
);

PROCEDURE Refresh_Snapshot (
        x_return_status     OUT NOCOPY      varchar2
);

---------------------------------------------------------------------------------
-- Main Procedures

PROCEDURE Call_Synchronize (
        ERRBUF                  OUT NOCOPY    VARCHAR2,
        RETCODE                 OUT NOCOPY    NUMBER,
        p_old_plan_id           IN            NUMBER
) IS

l_return_status         varchar2(1);
l_old_plan_id           number;
l_new_plan_id           number;

BEGIN

    RETCODE := MSC_POST_PRO.G_SUCCESS;
    G_TFS_ERROR := null;
    G_TFS_ERRCODE := MSC_POST_PRO.G_SUCCESS;


    conc_log ('---------------Call_Synchronize -------------------');

    conc_log ('  Old Plan ID : ' || p_old_plan_id);
    conc_log ('  ');

    if (p_old_plan_id is NULL) then
        conc_log ('Plan ID is NULL. Please specify a plan ID');
        RETCODE := MSC_POST_PRO.G_WARNING;
        RETURN;
    end if;

    conc_debug ('Fetching New PLAN ID from the database ...');
    BEGIN
        select  plan_id
          into  l_new_plan_id
          from  msc_plans
         where  copy_plan_id = p_old_plan_id;
    EXCEPTION
        when OTHERS then
                conc_log ('Unable to retrieve the copy plan ID for the old plan');
                RETCODE := MSC_POST_PRO.G_ERROR;
                ERRBUF := sqlerrm;
                RETURN;
    END;

    conc_log ('  New plan ID ' || l_new_plan_id );

    ATP_SYNCHRONIZE (
        p_old_plan_id,
        l_new_plan_id,
        l_return_status,
        ERRBUF);

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        RETCODE := G_TFS_ERRCODE;
        ERRBUF := G_TFS_ERROR;
    end if;

    conc_log ('----------------End Call Synchronize-------------');

END Call_Synchronize;


---------------------------------------------------------------------------------
PROCEDURE ATP_SYNCHRONIZE (
        p_old_plan_id           IN      NUMBER,
        p_new_plan_id           IN      NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        ERRBUF                  OUT NOCOPY VARCHAR2
) IS

l_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_rec1            MRP_ATP_PUB.ATP_Rec_Typ;
l_session_id          number;
l_atp_period          MRP_ATP_PUB.ATP_Period_Typ;
l_atp_supply_demand   MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_details         MRP_ATP_PUB.ATP_Details_Typ;
l_msg_count           number;
l_msg_data            varchar2(3000);
l_return_status       varchar2(1);
l_record_count        number;
l_sync_done           number;
l_to_call_ATP         number;
l_total_time          number;
l_downtime_start      number;
l_downtime_end        number;
l_downtime_total      number;
l_counter             number;

l_demand_id_arr       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_demand_id_arr_nl    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

BEGIN

    conc_log ('-------ATP 24x7 Synchronization ------------');
    conc_log (' ');
    conc_log (' Old Plan ID : ' || p_old_plan_id );
    conc_log (' New Plan ID : ' || p_new_plan_id );

    -- Set the global to indicate ATP Synchronization
    conc_debug ('Setting ATP Synchronization flag');
    MSC_ATP_PVT.G_SYNC_ATP_CHECK := 'Y';

    -- Set status in MSC_PLANS - summary_flag
    conc_debug ('Updating summary flag ');
    Update_Summary_Flag (   p_new_plan_id,
                            G_SF_SYNC_RUNNING,
                            l_return_status);

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        conc_log (' Cannot update ATP Summary status flag.');
        ATP_Sync_Error(p_old_plan_id, p_new_plan_id);
        G_TFS_ERROR := 'Unable to update Plan Information';
        G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;
        commit;
        return;
    end if;

    -- Commit First to set status flags
    COMMIT;

    l_sync_done := 0;
    l_to_call_ATP := 1;

    while (l_sync_done <> 1) loop

        -- We set this to one when it's the final iteration of the loop.
        if (l_sync_done = 2) then
            l_sync_done := 1;
        end if;

        -- Null out l_atp_rec
        l_atp_rec := l_atp_rec1;
        l_demand_id_arr := l_demand_id_arr_nl;

	    l_session_id := -1;

		-- CTO Re-arch, need to get session_id and pass to Get_Records_Post_Collections
	   	-- Get Session ID
	    begin
   	     	select MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL
   	       	into   l_session_id
   	       	from   dual;
	   	exception
        	when others then
            	conc_log ('Unable to get a sequence number for ATP Call');
            	conc_log ('Error is : ' || sqlerrm);
            	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end;

        conc_log ('Getting Records based on refresh number with session_id : ' || l_session_id);

	    -- Set Session_ID
	    order_sch_wb.set_session_id (l_session_id);

		-- CTO Re-arch changes, added session_id as an IN param,  as it will now be retrieved in ATP_Synchronize
        Get_Records_Post_Collections (
                                        p_old_plan_id,
                                        p_new_plan_id,
										l_session_id,
                                        l_atp_rec,
                                        l_record_count,
                                        l_return_status
                                     );

        conc_log ('Number of records : ' || l_record_count);

        -- Copy demand IDs
        l_demand_id_arr := l_atp_rec.attribute_03;

        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
            ATP_Sync_Error (p_old_plan_id, p_new_plan_id);
            G_TFS_ERROR := 'Unable to get records for synchronization';
            G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;

            commit;
            return;
        end if;

        if (l_return_status = FND_API.G_RET_STS_ERROR) or (l_record_count <= 0) then
            l_to_call_ATP := 0;
        end if;

        if (l_record_count <=  G_TF7_SO_THRESHOLD) and l_sync_done = 0 then

            l_sync_done := 2;  -- Indicate downtime. Will use on next loop
            conc_log ('Number of records to synchronize has reached threshold');

            -- Get Downtime Start Time
            begin
                select hsecs / 100
                  into l_downtime_start
                  from v$timer;
            exception
                when others then
                    conc_log ('Unable to access timer');
                    conc_log ('Error is: ' || sqlerrm);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            end;

            -- Signal ATP Downtime
            ATP_Downtime_Init (p_old_plan_id, p_new_plan_id, l_return_status);

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                conc_log ('Something wrong in call to ATP Downtime Init');
                -- Rollback changes made by ATP downtim INIt
                rollback;
                G_TFS_ERROR := 'Unable to Initiate ATP Downtime';
                G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;

                ATP_Sync_Error (p_old_plan_id, p_new_plan_id);
                commit;
                return;
            end if;

            -- Commit chages made by downtime INIT
            commit;
        end if;

        if (l_to_call_ATP = 1 ) then

            conc_log ('Calling ATP to Synchronize first set of records');
            Synchronize_Call_To_ATP (   l_atp_rec,
                                        l_session_id,
                                        l_total_time,
                                        l_return_status
                                    );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                ROLLBACK;
                G_TFS_ERROR := 'Call to ATP API for Synchronization failed';
                G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;
                ATP_Sync_Error (p_old_plan_id, p_new_plan_id);
                commit;
                return;
            end if;

            -- Set timers
            conc_log (l_record_count||'  records synchronized in '||l_total_time|| ' seconds');
            Calculate_Downtime_SO_Records ( l_record_count,
                                            l_total_time
                                          );

            -- Copy over demand ID
            l_atp_rec.attribute_03 := l_demand_id_arr;

            Update_Sync_flag (  l_atp_rec,
                                p_old_plan_id,
                                l_return_status
                             );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                conc_log ('Unable to update sync flag ');
                ROLLBACK;
                G_TFS_ERROR := 'Unable to update Plan Information';
                G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;

                ATP_Sync_Error (p_old_plan_id, p_new_plan_id);
                commit;
                return;
            end if;

            -- Commit changes so far
            commit;

        end if;
    end loop;

    ATP_Downtime_Complete (p_old_plan_id, p_new_plan_id, l_return_status);
    commit;

    -- Get Downtime Start Time
    begin
        select hsecs / 100
          into l_downtime_end
          from v$timer;
    exception
        when others then
            conc_log ('Unable to access timer');
            conc_log ('Error is: ' || sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end;

    l_downtime_total := (l_downtime_end - l_downtime_start ) / 60;
    conc_log (' ');
    conc_log ('**********--------24x7 Synchronization Summary ---------********');
    conc_log (' ');
    conc_log ('   Total Records Synchronized     : ' || G_TF7_TOTAL_RECORDS );
    conc_log ('   Total Time Taken (minutes)     : ' || G_TF7_TOTAL_TIME / 60);
    conc_log ('   Total ATP downtime (minutes)   : ' || l_downtime_total / 60 );
    conc_log (' ');
    conc_log ('**********----------------------------------------------********');

    -- Extended Synchronization Starts here
    -- This collects all stray records in the old plan.

    -- Set time to wait
    conc_log (' ');
    if (G_TF7_DOWNTIME > G_TF7_MAX_EXTEND_SYNC) then
        conc_log (' Downtime specified is greater ');
        G_TF7_EXTEND_SYNC := G_TF7_DOWNTIME;
    else
        G_TF7_EXTEND_SYNC := G_TF7_MAX_EXTEND_SYNC;
    end if;

    conc_log (' Extended Sync process duration (seconds) : ' || G_TF7_EXTEND_SYNC);

    -- We are going to do the extended sync in two iterations. The first
    -- try is at time T/2 where T is the total extended Sync time. To
    -- do the sync twice, we loop twice.

    -- Block 1 Start
    --
    for counter in 1..2 loop

        -- Wait first for time T/2
        --Extended_Sync_Wait (G_TF7_EXTEND_SYNC/2, l_return_status);

        -- Null out l_atp_rec
        l_atp_rec := l_atp_rec1;
        l_demand_id_arr := l_demand_id_arr_nl;

        -- Initialize the to_call counter
        l_to_call_ATP := 1;

        conc_log ('Getting Records based on refresh number - first extended sync query');

        l_session_id := -1;

		-- CTO Re-arch, need to get session_id and pass to Get_Records_Post_Collections
        -- Get Session ID
        begin
            select MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL
            into   l_session_id
            from   dual;
        exception
            when others then
                conc_log ('Unable to get a sequence number for ATP Call');
                conc_log ('Error is : ' || sqlerrm);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end;

        conc_log ('Getting Records based on refresh number with session_id : ' || l_session_id);

        -- Set Session_ID
        order_sch_wb.set_session_id (l_session_id);

		-- CTO Re-arch changes, added session_id as an IN param,  as it will now be retrieved in ATP_Synchronize
        Get_Records_Post_Collections (
                                    p_old_plan_id,
                                    p_new_plan_id,
									l_session_id,
                                    l_atp_rec,
                                    l_record_count,
                                    l_return_status
                                     );

        conc_log ('Number of records : ' || l_record_count);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) or (l_record_count <= 0) then
                conc_log ('Nothing to synchronize');
                l_to_call_ATP := 0;
        end if;

        if (l_to_call_ATP = 1 ) then

            l_demand_id_arr := l_atp_rec.attribute_03;

            conc_log ('Calling ATP to Synchronize first set of extended sync records');
            Synchronize_Call_To_ATP (   l_atp_rec,
                                        l_session_id,
                                        l_total_time,
                                        l_return_status
                                    );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                ROLLBACK;
                conc_log ('Something wrong in call to ATP');
                conc_log ('Stray records do exist, and may not be synchronized');
                G_TFS_ERROR := 'Error in call to ATP API for Extended Synchronization';
                G_TFS_ERRCODE := MSC_POST_PRO.G_WARNING;
                return;
            end if;

            l_atp_rec.attribute_03 := l_demand_id_arr;
            Update_Sync_flag (  l_atp_rec,
                                p_old_plan_id,
                                l_return_status
                             );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                conc_log ('Unable to update sync flag ');
                -- Commit whatever we have done so far
            end if;

            -- Commit changes so far
            commit;
        end if;
    end loop;
    -- Block 1 End

    conc_log ('------***** All Done! *******--------------');

EXCEPTION
    when OTHERS then
        conc_log ('Exception in Atp_synchronize');
        conc_log ('Error is : ' || sqlerrm);

        G_TFS_ERROR := sqlerrm;
        G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;
        x_return_status := FND_API.G_RET_STS_ERROR;

END ATP_SYNCHRONIZE;

---------------------------------------------------------------------------------

-- CTO Re-arch changes, changed session_id to an IN param,  as it will now be retrieved in ATP_Synchronize
PROCEDURE Synchronize_Call_To_ATP (
        p_atp_table         IN  MRP_ATP_PUB.ATP_Rec_Typ,
        p_session_id        IN  number,
        x_total_time        OUT NOCOPY            number,
        x_return_status     OUT NOCOPY            varchar2
) IS
--PRAGMA AUTONOMOUS_TRANSACTION;

-- CTO Re-arch, don't need anymore as its passed as IN param.
--l_session_id            number;
l_timer_start           number;
l_timer_end             number;
l_atp_table             MRP_ATP_PUB.Atp_Rec_Typ;
l_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
l_return_status         varchar2(1);
l_msg_data              varchar2(100);
l_msg_count             number;
l_instance_id           number;
l_refresh_number        number;

BEGIN

    conc_log ('---------------Synchronize Call to ATP---------------');

    Print_Input_Rec (p_atp_table);

    -- Initialize
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- CTO Re-arch changes, changed session_id to an IN param,  as it will now be retrieved in ATP_Synchronize
/*
    x_session_id := -1;
    l_session_id := -1;

    -- Get Session ID
    begin
        select MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL
          into l_session_id
          from dual;
    exception
        when others then
            conc_log ('Unable to get a sequence number for ATP Call');
            conc_log ('Error is : ' || sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end;
    x_session_id := l_session_id;
    conc_log (' Session ID for ATP Call : ' || x_session_id);

    -- Set Session_ID
    order_sch_wb.set_session_id (x_session_id);
*/

    -- Get Start Time
    begin
        select hsecs / 100
          into l_timer_start
          from v$timer;
    exception
        when others then
            conc_log ('Unable to access timer');
            conc_log ('Error is: ' || sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end;

    l_refresh_number := p_atp_table.attribute_04(1);
    l_instance_id := NULL;

    -- Now Call ATP
    begin
        conc_log ('---------Before calling schedule---------');

		-- CTO Re-arch, modified to use p_session_id instead of x_session_id

        MSC_ATP_PVT.Call_Schedule(  p_session_id,           -- session ID
                                p_atp_table,            -- ATP REC Table
                                l_instance_id,          -- instance ID
                                NULL,                   -- assignment set ID
                                l_refresh_number,       -- refresh number
                                l_atp_table,            -- output table
                                l_return_status,        -- return status
                                l_msg_data,             -- msg data
                                l_msg_count,            -- msg count
                                l_atp_supply_demand,    -- supply demand details
                                l_atp_period,           -- period info
                                l_atp_details           -- atp details
                             );
        conc_log ('After calling schedule: l_return_status : ' || l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           conc_log ('Error in call to Call_Schedule');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    exception
        when  MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND then
            conc_log ('Invalid Objects found in call to Call_Schedule');
            conc_log ('Return Status : ' || l_return_status);
            conc_log ('Error Message : ' || sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        when others then
            conc_log ('Exception in call to Call_Schedule');
            conc_log ('Return Status : ' || l_return_status);
            conc_log ('Error Message : ' || sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end;


    -- Get End Time
    begin
        select hsecs / 100
          into l_timer_end
          from v$timer;
    exception
        when others then
            conc_log ('Unable to access timer');
            conc_log ('Error is: ' || sqlerrm);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end;

    -- Calculate Total Time
    x_total_time := l_timer_end - l_timer_start;

    if (x_total_time < 0) then
        x_total_time := G_ATP_TIMER_MAX_VALUE / 100 - l_timer_start + l_timer_end;
    end if;

    conc_debug ('Total time taken for this ATP call : ' || x_total_time);


EXCEPTION
    when FND_API.G_EXC_UNEXPECTED_ERROR then
        conc_log ('Unexpected Error. Sync Call To ATP failed');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    when FND_API.G_EXC_ERROR then
        conc_log ('Expected Error. Sync Call To ATP failed');
        x_return_status := FND_API.G_RET_STS_ERROR;

    when others then
        conc_log ('Exception Others. Sync Call To ATP failed');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Synchronize_Call_To_ATP;

---------------------------------------------------------------------------------
-- Get records that have been modified (rescheduled) between
-- the two plans with a refresh number smaller than the
-- collections refresh number

-- This procedure is not used anymore as 24x7 doesn't process pre-collection records since
-- MDS is not supported for 24x7 ATP plans.

PROCEDURE Get_Records_Pre_Collections (
                p_old_plan_id       IN      number,
                p_new_plan_id       IN      number,
                x_atp_rec           OUT NOCOPY    MRP_ATP_PUB.ATP_Rec_Typ,
                x_record_count      OUT NOCOPY    number,
                x_return_status     OUT NOCOPY    varchar2
) IS
BEGIN

    conc_debug ('------------------Get_Records_Pre_Collections------------------');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_record_count := 0;

    BEGIN
        select
               col1,
               col2,
               col3,
               col4,
               col5,
               col6,
               col7,
               col8,
               col9,
               col10,
               col11,
               col12,
               col13,
               col14,
               col15,
               col16,
               col17,
               col18,
               col19,
               col20
        bulk collect into
                x_atp_rec.calling_module,
                x_atp_rec.customer_id,
                x_atp_rec.customer_site_id,
                x_atp_rec.inventory_item_id,
                x_atp_rec.source_organization_id,
                x_atp_rec.quantity_ordered,
                x_atp_rec.quantity_UOM,
                x_atp_rec.requested_ship_date,
                x_atp_rec.demand_class,
                x_atp_rec.override_flag,
                x_atp_rec.action,
                x_atp_rec.instance_id,
                x_atp_rec.identifier,          -- SO Line ID
                x_atp_rec.substitution_typ_code,
                x_atp_rec.attribute_04,                 -- Refresh Number
                x_atp_rec.delivery_lead_time,
                x_atp_rec.attribute_08,         -- Order Number
                x_atp_rec.old_source_organization_id,
                x_atp_rec.old_demand_class,
                x_atp_rec.attribute_03  -- Temporarily store Demand_ID
        from (
        select
                660                                     col1,
                CUST_VIEW.sr_tp_id                      col2,
                CUST_SITE_VIEW.sr_tp_site_id            col3,
                msi.sr_inventory_item_id                col4,
                md.organization_id                      col5,
                md.using_requirement_quantity           col6,
                msi.uom_code                            col7,
                md.using_assembly_demand_date           col8,
                md.demand_class                         col9,
                'Y'                                     col10, -- override flag
                120                                     col11, -- rescheudle
                md.sr_instance_id                       col12,
                md.sales_order_line_id                  col13,
                4                                       col14,
                md.refresh_number                       col15,
                0                                       col16,
                SUBSTR(md.order_number,1,30)             col17,
                md.organization_id                      col18,
                md.demand_class                         col19,
                md.demand_id                            col20
         from   msc_demands md,
                -- Inline view for Customers
                (   select mtil.sr_instance_id  sr_instance_id,
                           mtil.tp_id           tp_id,
                           max(mtil.sr_tp_id)   sr_tp_id
                      from msc_tp_id_lid mtil
                     where mtil.partner_type = 2
                       and mtil.sr_company_id = -1
                       group by mtil.sr_instance_id, mtil.tp_id
                ) CUST_VIEW,
                (   select mtsil.sr_instance_id     sr_instance_id,
                           mtsil.tp_site_id         tp_site_id,
                           max(mtsil.sr_tp_site_id) sr_tp_site_id
                      from msc_tp_site_id_lid mtsil
                     where mtsil.partner_type = 2
                       and mtsil.sr_company_id = -1
                       group by mtsil.tp_site_id, mtsil.sr_instance_id
                ) CUST_SITE_VIEW,
                msc_system_items msi
        where   md.plan_id = p_old_plan_id
          and   md.origination_type in (6,30)
          and   (md.demand_id, md.sr_instance_id) in (
                (
                -- Sales orders in old plan not in New plan
                select  max (oldp.demand_id),
                        oldp.sr_instance_id
                  from  msc_demands oldp,
                        msc_plan_refreshes mpr
                 where  oldp.plan_id = p_old_plan_id
                   and  oldp.origination_type in (6,30)
                   and  NVL(oldp.atp_synchronization_flag,-1) <> 1
                   and  mpr.plan_id = p_new_plan_id
                   and  oldp.refresh_number is not NULL
                   and  oldp.refresh_number < mpr.apps_lrn
                   and  oldp.sr_instance_id = mpr.sr_instance_id
                   and  not exists (
                        select  sales_order_line_id
                          from  msc_demands md1
                         where  md1.plan_id = p_new_plan_id
                           and  md1.origination_type in (6,30)
                           and  md1.sr_instance_id = oldp.sr_instance_id
                           and  md1.sales_order_line_id = oldp.sales_order_line_id
                           and  md1.using_assembly_item_id = oldp.using_assembly_item_id
                        )
                   group by  oldp.sales_order_line_id,
                             oldp.using_assembly_item_id,
                             oldp.sr_instance_id
                )
                UNION
                (
                -- Demands in both plans but have been rescheduled
                select  max(oldp.demand_id),
                        oldp.sr_instance_id
                  from  msc_demands oldp,
                        msc_demands newp
                 where  oldp.plan_id = p_old_plan_id
                   and  newp.plan_id = p_new_plan_id
                   and  oldp.origination_type in (6,30)
                   and  newp.origination_type in (6,30)
                   and  oldp.sr_instance_id = newp.sr_instance_id
                   and  oldp.sales_order_line_id = newp.sales_order_line_id
                   and  oldp.using_assembly_item_id = newp.using_assembly_item_id
                   and  oldp.demand_id = (
                        select  max (md1.demand_id)
                          from  msc_demands md1,
                                msc_plan_refreshes mpr1
                         where  md1.origination_type in (6,30)
                           and  md1.plan_id = p_old_plan_id
                           and  md1.sr_instance_id = oldp.sr_instance_id
                           and  NVL(md1.atp_synchronization_flag,-1) <> 1
                           and  md1.refresh_number is not NULL
                           and  md1.refresh_number < mpr1.apps_lrn
                           and  md1.sr_instance_id = mpr1.sr_instance_id
                           and  mpr1.plan_id = p_new_plan_id
                           and  md1.sales_order_line_id = oldp.sales_order_line_id
                           and  md1.using_assembly_item_id = oldp.using_assembly_item_id
                        )
                   and  newp.demand_id = (
                        -- select demand id for a particular sales order line ID
                        select  max (md2.demand_id)
                          from  msc_demands md2
                         where  md2.origination_type in (6,30)
                           and  md2.plan_id = p_new_plan_id
                           and  md2.sales_order_line_id = oldp.sales_order_line_id
                           and  md2.using_assembly_item_id = oldp.using_assembly_item_id
                           and  md2.sr_instance_id = oldp.sr_instance_id
                        )
                       -- Main check to see if order rescheduled goes here.
                   and  (    oldp.demand_class <> newp.demand_class
                          or oldp.using_requirement_quantity <> newp.using_requirement_quantity
                          or oldp.organization_id <> newp.organization_id

                          or TRUNC ( NVL(oldp.old_demand_date, oldp.using_assembly_demand_date))
                             <>
                             TRUNC( NVL(newp.old_demand_date, newp.using_assembly_demand_date))
                        )
                   group by  oldp.sales_order_line_id, oldp.using_assembly_item_id,
                             oldp.sr_instance_id
                ) -- Union
                ) -- Demand_ID in
           and  md.customer_id = CUST_VIEW.tp_id (+)
           and  md.sr_instance_id = CUST_VIEW.sr_instance_id (+)
           and  md.ship_to_site_id = CUST_SITE_VIEW.tp_site_id (+)
           and  md.sr_instance_id = CUST_SITE_VIEW.sr_instance_id (+)
           and  md.using_assembly_item_id = msi.inventory_item_id
           and  md.sr_instance_id = msi.sr_instance_id
           and  msi.plan_id = -1
           and  md.organization_id = msi.organization_id
           and  not exists (
                select  demand_source_header_id
                  from  msc_sales_orders mso
                 where  mso.sr_instance_id = md.sr_instance_id
                   and  mso.demand_source_line = to_char(md.sales_order_line_id)
                   and  mso.reservation_type = 1
                   and  mso.inventory_item_id = md.using_assembly_item_id
                   and  mso.completed_quantity > 0
                )
          order by md.last_update_date
        ); --select BULK COLLECT from

        x_record_count := x_atp_rec.calling_module.COUNT;

        if (x_record_count > 0) then
                conc_debug ('Extending ATP record');

                -- CTO rearch, changed to call New_Extend_ATP to balance ATP_Rec_Typ for all
                -- new attributes added for CTO re-arch project.

                --extend_atp_rec_typ (x_atp_rec, x_record_count);
                MSC_SATP_FUNC.New_Extend_Atp(x_atp_rec, x_record_count, x_return_status);
                if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
        end if;

        conc_debug ('Records obtained in query : ' || x_record_count);
        conc_debug ('---------------------------------------------------------');

    EXCEPTION
        when NO_DATA_FOUND then
            conc_debug ('Get Records Pre Coll: No data found ');
        when OTHERS then
            conc_log ('Get_Records_Pre_Coll: Error while getting records from old plan');
            conc_log ('Error Is : ' || sqlerrm);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            G_TFS_ERROR := sqlerrm;
            G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;

    END;
END Get_Records_Pre_Collections;

---------------------------------------------------------------------------------
--  Get records that have been inserted or modified after the start of collections.
--  These records will have a refresh number > the refresh number populated by
--  collections and suitably transferred by planning to MSC_PLAN_REFRESHES.

-- CTO Re-arch changes, added session_id as an IN param,  as it will now be retrieved in ATP_Synchronize
PROCEDURE Get_Records_Post_Collections (
                p_old_plan_id       IN      number,
                p_new_plan_id       IN      number,
				p_session_id		IN		number,
                x_atp_rec           OUT NOCOPY    MRP_ATP_PUB.ATP_Rec_Typ,
                x_record_count      OUT NOCOPY    number,
                x_return_status     OUT NOCOPY    varchar2
) IS

l_sysdate		DATE;
BEGIN

    conc_debug ('-----------------Get_Records_Post_Collections -----------------');
    -- Initialize Return Variables
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_record_count := 0;

    -- Main query
    BEGIN
        select
               col1,
               col2,
               col3,
               col4,
               col5,
               col6,
               col7,
               col8,
               col9,
               col10,
               col11,
               col12,
               col13,
               col14,
               col15,
               col16,
               col17,
               col18,
               col19,
               col20,
               -- Plan by request date changes
               col21,
               col22,
			   -- CTO Re-arch changes
               col23,
               col24,
               col25,
               col26,
			   col27, -- ATP Flag passed as Y always.
               col28, --  Use session id for CTO Re-arch
               col29, --  Ship Set Name
               col30, --  Arrival Set Name
             --col31, --  Insert FLag
               col31, --  Insert FLag bug3330835
               col32  --  bug 8473835
        bulk collect into
                x_atp_rec.calling_module,
                x_atp_rec.customer_id,
                x_atp_rec.customer_site_id,
                x_atp_rec.inventory_item_id,
                x_atp_rec.source_organization_id,
                x_atp_rec.quantity_ordered,
                x_atp_rec.quantity_UOM,
                x_atp_rec.requested_ship_date,
                x_atp_rec.demand_class,
                x_atp_rec.override_flag,
                x_atp_rec.action,
                x_atp_rec.instance_id,
                x_atp_rec.identifier,          -- SO Line ID
                x_atp_rec.substitution_typ_code,
                x_atp_rec.attribute_04, -- Refresh Number
                x_atp_rec.delivery_lead_time,
                x_atp_rec.attribute_08, -- Order number
                x_atp_rec.old_source_organization_id,
                x_atp_rec.old_demand_class,
                x_atp_rec.attribute_03, -- demand ID
                -- Plan by request date changes
                x_atp_rec.original_request_date,  --original request date
                x_atp_rec.requested_arrival_date,
			    -- CTO Re-arch changes
            	x_atp_rec.ATO_Model_Line_Id,
				x_atp_rec.Top_Model_line_id,
				x_atp_rec.ATO_Parent_Model_Line_Id,
            	x_atp_rec.Parent_line_id,
                x_atp_rec.attribute_06, --  ATP Flag passed as Y always.
                x_atp_rec.attribute_11, --  Use session id for CTO Re-arch
                x_atp_rec.ship_set_name, --  Ship Set Name
                x_atp_rec.arrival_set_name, --  Arrival Set Name
                x_atp_rec.insert_flag,  --  Insert Flag
                x_atp_rec.demand_source_type  --  bug 8473835
        from (
        select
                660                                     col1,
                NVL(CUST_VIEW.sr_tp_id, -999)             col2,
                NVL(CUST_SITE_VIEW.sr_tp_site_id, -999)   col3,
                msi.sr_inventory_item_id                col4,
                md.organization_id                      col5,
                md.using_requirement_quantity           col6,
                msi.uom_code                            col7,
                -- md.using_assembly_demand_date           col8,
                decode(order_date_type_code,
                       2, NULL,
                       NVL(md.schedule_ship_date,
                       md.using_assembly_demand_date))  col8, --plan by request Date, Promise Date Scheduled Date
                md.demand_class                         col9,
                'Y'                                     col10, -- override flag
                120                                     col11, -- rescheudle
                md.sr_instance_id                       col12,
                md.sales_order_line_id                  col13,
                4                                       col14,
                md.refresh_number                       col15,
                md.intransit_lead_time                  col16,
                --0                                     col16,
                SUBSTR(md.order_number,1,30)            col17,
                md.organization_id                      col18,
                md.demand_class                         col19,
                md.demand_id                            col20,
                decode(order_date_type_code,
                       1, md.request_ship_date,
                          md.request_date)              col21, --added so that original request date is not lost
                decode(order_date_type_code,
                       2, md.SCHEDULE_ARRIVAL_DATE,
                          NULL)                         col22, --plan by request Date, Promise Date Scheduled Date
			    -- CTO Re-arch changes
                md.ato_line_id                          col23,
                md.top_model_line_id                    col24,
                md.parent_model_line_id                 col25,
                md.link_to_line_id                      col26,
                'Y'                      				col27, -- ATP Flag passed as Y always.
                md.atp_session_id 						col28, --  Use session id for CTO Re-arch
                md.ship_set_name 						col29, --  Ship Set Name
                md.arrival_set_name						col30, --  Arrival Set Name
                0										col31,  --  Insert Flag
                md.demand_source_type		col32 --  bug 8473835
         from   msc_demands md,
                -- Inline view for Customers
                (   select mtil.sr_instance_id  sr_instance_id,
                           mtil.tp_id           tp_id,
                           max(mtil.sr_tp_id)   sr_tp_id
                      from msc_tp_id_lid mtil
                     where mtil.partner_type = 2
                       and mtil.sr_company_id = -1
                       group by mtil.sr_instance_id, mtil.tp_id
                ) CUST_VIEW,
                (   select mtsil.sr_instance_id     sr_instance_id,
                           mtsil.tp_site_id         tp_site_id,
                           max(mtsil.sr_tp_site_id) sr_tp_site_id
                      from msc_tp_site_id_lid mtsil
                     where mtsil.partner_type = 2
                       and mtsil.sr_company_id = -1
                       group by mtsil.sr_instance_id, mtsil.tp_site_id
                ) CUST_SITE_VIEW,
                msc_system_items msi
        where   md.plan_id = p_old_plan_id
          and   md.origination_type in (6,30)
          and   (md.demand_id, md.sr_instance_id) in (
                select  max (md1.demand_id),
                        md1.sr_instance_id
                  from  msc_demands md1,
                        msc_plan_refreshes mpr,
						msc_plan_organizations mpo
                 where  md1.plan_id = p_old_plan_id
                   and  md1.origination_type in (6,30)
                   and  mpr.plan_id = p_new_plan_id
                   and  mpr.plan_id = mpo.plan_id
                   and  md1.sr_instance_id = mpo.sr_instance_id
                   and  md1.organization_id = mpo.organization_id
                   and  md1.refresh_number > nvl(mpo.so_lrn, mpr.apps_lrn) -- Verify if mpo.so_lrn will always be populated
                   and  md1.atp_synchronization_flag = 0
                   -- Removed inventory_item_id from group by to handle product substitution across re-scheduling of SO
                   --group by md1.sales_order_line_id, md1.inventory_item_id, md1.sr_instance_id
                   group by md1.sales_order_line_id, md1.sr_instance_id
                )
          and   md.customer_id = CUST_VIEW.tp_id (+)
          and   md.sr_instance_id = CUST_VIEW.sr_instance_id (+)
          and   md.ship_to_site_id = CUST_SITE_VIEW.tp_site_id (+)
          and   md.sr_instance_id = CUST_SITE_VIEW.sr_instance_id (+)
          and   md.using_assembly_item_id = msi.inventory_item_id
          and   md.sr_instance_id = msi.sr_instance_id
          and   msi.plan_id = -1
          and   md.organization_id = msi.organization_id
          order by md.last_update_date
        );

        x_record_count := x_atp_rec.calling_module.COUNT;

        if (x_record_count > 0) then
                conc_debug ('Extending ATP record');

                -- CTO rearch, changed to call New_Extend_ATP to balance ATP_Rec_Typ for all
                -- new attributes added for CTO re-arch project.

                --extend_atp_rec_typ (x_atp_rec, x_record_count);
                MSC_SATP_FUNC.New_Extend_Atp(x_atp_rec, x_record_count, x_return_status);
                if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
        elsif (x_record_count = 0) then
           -- No need to progress further if count = 0
           RETURN;
		end if;		-- if (x_record_count > 0) then

        conc_debug ('Records obtained in main query : ' || x_record_count);

        -- ngoel, 8/20/2003: Added new SQL for CTO Re-architecture to insert
        -- ATO model's components in msc_cto_bom table for processing.

		l_sysdate := sysdate;
		G_FND_USER := FND_GLOBAL.USER_ID;

        -- Select BOM records for ATO Models from msc_cto_bom and re-populate with new session_id
        FORALL i in 1..x_record_count
        INSERT INTO msc_cto_bom (
                    inventory_item_id,
                    line_id,
                    top_model_line_id,
                    ato_parent_model_line_id,
                    ato_model_line_id,
                    match_item_id,
                    wip_supply_type,
                    session_id,
                    bom_item_type,
                    quantity,
                    parent_line_id,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    sr_instance_id,
                    sr_inventory_item_id,
                    refresh_number,
                    plan_id)
        /*
        Changed to use msc_cto_bom instead to handle following cases:
        1. In case ATP used model's ITF to promise, demands for lower components may not exist.
        2. In "BUY" cases, demand for lower components may not exist for entire qty.
        */
         SELECT     distinct
					inventory_item_id,
                    line_id,
                    top_model_line_id,
                    ato_parent_model_line_id,
                    ato_model_line_id,
                    match_item_id,
                    wip_supply_type,
                    p_session_id,
                    bom_item_type,
                    quantity,
                    parent_line_id,
                    G_FND_USER,
                    l_sysdate,
                    G_FND_USER,
                    l_sysdate,
                    sr_instance_id,
                    sr_inventory_item_id,
                    refresh_number,
                    NULL	-- Plan ID
          FROM      msc_cto_bom
          WHERE     ato_model_line_id = x_atp_rec.ATO_Model_Line_Id(i)
          AND       session_id = x_atp_rec.attribute_11(i)
          AND       plan_id = p_old_plan_id
          AND       x_atp_rec.quantity_ordered(i) > 0
          AND       sr_instance_id = x_atp_rec.instance_id(i);

        conc_debug ('No. of ATO Component records inserted: ' || SQL%ROWCOUNT);

        -- Select OSS Sourcing records for ATO Models from msc_cto_sources and re-populate with new session_id
        FORALL i in 1..x_record_count
        INSERT INTO msc_cto_sources (
                    line_id,
                    organization_id,
                    supplier_id,
                    status_flag,
                    inventory_item_id,
                    sr_instance_id,
                    ato_line_id,
                    creation_date,
                    created_by,
                    last_updated_by,
                    last_update_date,
                    supplier_site_code,
                    make_flag,
                    refresh_number,
                    plan_id,
                    session_id)
          SELECT    line_id,
                    organization_id,
                    supplier_id,
                    status_flag,
                    inventory_item_id,
                    sr_instance_id,
                    ato_line_id,
                    l_sysdate,
                    G_FND_USER,
                    G_FND_USER,
                    l_sysdate,
                    supplier_site_code,
                    make_flag,
                    refresh_number,
                    NULL,	-- Plan ID
                    p_session_id
          FROM      msc_cto_sources
          WHERE     ato_line_id = x_atp_rec.ATO_Model_Line_Id(i)
          AND       session_id = x_atp_rec.attribute_11(i)
          AND       plan_id = p_old_plan_id
          AND       x_atp_rec.quantity_ordered(i) > 0
          AND       sr_instance_id = x_atp_rec.instance_id(i);

        conc_debug ('No. of OSS Sourcing records inserted: ' || SQL%ROWCOUNT);

        conc_debug ('---------------------------------------------------------');
    EXCEPTION
        when NO_DATA_FOUND then
            conc_debug ('Get Records Post Coll: No data found ');
            x_return_status := FND_API.G_RET_STS_ERROR;
        when OTHERS then
            conc_log ('Get_Records_Post_Coll: Error while getting records from old plan');
            conc_log ('Error Is : ' || sqlerrm);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            G_TFS_ERROR := sqlerrm;
            G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;

    END;
END Get_Records_Post_Collections;

---------------------------------------------------------------------------------

PROCEDURE Update_Sync_flag (
        p_atp_table             IN  MRP_ATP_PUB.ATP_Rec_Typ,
        p_old_plan_id           IN  number,
        x_return_status         OUT NOCOPY varchar2
) IS

l_counter      number;
l_sysdate      date := sysdate;

BEGIN
    conc_debug ('----Update Sync Flag ----');
    conc_debug ('  Total Records : ' || p_atp_table.calling_module.count);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


        conc_debug ('Updating Data at :' || l_sysdate);

        forall l_counter in 1..p_atp_table.calling_module.count
        update msc_demands
          set  atp_synchronization_flag = 1,
               last_updated_by = G_FND_USER,
               last_update_login = G_FND_USER,
			   last_update_date = l_sysdate
        where  plan_id = p_old_plan_id
          and  sr_instance_id = p_atp_table.instance_id(l_counter)
          and  origination_type = 30
          and  sales_order_line_id = p_atp_table.identifier(l_counter)
          and  refresh_number <= p_atp_table.attribute_04(l_counter)
          and  demand_id <= p_atp_table.attribute_03(l_counter)
          and  organization_id = p_atp_table.source_organization_id(l_counter)
		  and  NVL(atp_synchronization_flag, -1) <> 1;

          conc_debug ('Rows Updated : ' || sql%rowcount);

/* Not Needed as component records aren't selected from msc_demands
        -- CTO Re-arch changes, need to update demands for ATO Model's options/ OC's
        conc_debug ('Updating CTO Component Demands');

        forall l_counter in 1..p_atp_table.calling_module.count
        update msc_demands
          set  atp_synchronization_flag = 1,
               last_updated_by = G_FND_USER,
               last_update_login = G_FND_USER,
			   last_update_date = l_sysdate
        where  plan_id = p_old_plan_id
          and  sr_instance_id = p_atp_table.instance_id(l_counter)
          and  ato_line_id = p_atp_table.identifier(l_counter)
          and  refresh_number <= p_atp_table.attribute_04(l_counter)
          and  p_atp_table.identifier(l_counter) <> p_atp_table.ato_model_line_id(l_counter)
		  and  NVL(atp_synchronization_flag, -1) <> 1;

          conc_debug ('Rows Updated : ' || sql%rowcount);
*/

EXCEPTION
    when OTHERS then
        conc_log ('Error in Update Sync Flag');
        conc_log ('Error is : ' || sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;
END Update_Sync_flag;

---------------------------------------------------------------------------------

PROCEDURE ATP_Downtime_Init (
                p_old_plan_id           IN      number,
                p_new_plan_id           IN      number,
                x_return_status         OUT NOCOPY     varchar2
) IS
BEGIN
    conc_debug ('------ATP_Downtime_Init--------');
    conc_debug ('  Old Plan: ' || p_old_plan_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Update MSC Plans to null out the date.
/*    update msc_plans
       set plan_completion_date = NULL
     where plan_id = p_old_plan_id;
*/
    Update_Summary_Flag (   P_new_plan_id,
                            G_SF_SYNC_DOWNTIME,
                            x_return_status
                        );
    conc_debug ('-------------------------------');

EXCEPTION
    when others then
        conc_log ('Error in Downtime INIT');
        conc_log ('Error is : ' || sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END ATP_Downtime_Init;

---------------------------------------------------------------------------------

PROCEDURE ATP_Downtime_Complete (
                p_old_plan_id       IN      number,
                p_new_plan_id       IN      number,
                x_return_status     OUT NOCOPY     varchar2
) IS
l_request_id    number;
l_call_status   boolean;
l_phase         varchar2(80);
l_status        varchar2(80);
l_dev_phase     varchar2(80);
l_dev_status    varchar2(80);
l_message       varchar2(240);

--Bug 8301235
l_mpo_so_lrn           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_mpo_org_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_mpo_sr_instance_id   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

BEGIN

    conc_log ('ATP Downtime Complete');

    SELECT so_lrn, sr_instance_id, organization_id
    BULK COLLECT INTO l_mpo_so_lrn, l_mpo_sr_instance_id, l_mpo_org_id
    FROM msc_plan_organizations
    WHERE plan_id = p_new_plan_id;

    -- CALL UI API HERE
    BEGIN
        l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                        'MSC',
                        'MSCSWPLN',
                        NULL,
                        NULL,
                        FALSE,
                        p_old_plan_id,
                        p_new_plan_id
                    );
        commit;
    EXCEPTION
        when OTHERS then
            conc_log ('Concurrent program error. Code : ' || sqlcode);
            conc_log ('                         Error : ' || sqlerrm);
            x_return_status := FND_API.G_RET_STS_ERROR;
            G_TFS_ERROR := 'Unable to switch plans';
            G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;
            return;
    END;

    conc_log ('Switch Plans launched with request ID ' || l_request_id);
    l_call_status := FND_CONCURRENT.WAIT_FOR_REQUEST (
                        l_request_id,
                        10,
                        10000000,
                        l_phase,
                        l_status,
                        l_dev_phase,
                        l_dev_status,
                        l_message );

    conc_debug ('Returned from Wait For Request');
    conc_debug ('Phase : ' || l_dev_phase || '    Status : ' || l_dev_status );

    if (l_dev_status <> 'NORMAL') then
        conc_log ('Switch plans returned with ' || l_dev_status);
        x_return_status := FND_API.G_RET_STS_ERROR;
        G_TFS_ERROR := 'Unable to switch plans - program returned with error';
        G_TFS_ERRCODE := MSC_POST_PRO.G_ERROR;

        return;
    end if;

    --Reset the value of msc_plan_organizations.so_lrn to msc_instance_orgs.so_lrn
    --as it got changed during Plan Switch : Bug#8301235
    conc_debug ('Resetting the value of msc_plan_organizations.so_lrn...');

    FORALL j IN l_mpo_org_id.FIRST.. l_mpo_org_id.LAST
    UPDATE msc_plan_organizations
    SET so_lrn = l_mpo_so_lrn(j)
    WHERE sr_instance_id = l_mpo_sr_instance_id(j)
    AND organization_id = l_mpo_org_id(j)
    AND plan_id = p_new_plan_id;

    -- Call Refresh Snapshot

    conc_log ('Updating Summary flag');
    Update_Summary_Flag (p_new_plan_id, G_SF_SYNC_SUCCESS, x_return_status);

    conc_log ('Launching Analyze Plan Partition');

    -- Bug 2809606 : Will refresh snapshot directly, instead of launching ANAPP
/*
    BEGIN
        l_request_id := FND_REQUEST.SUBMIT_REQUEST
                        (
                                'MSC',
                                'MSCANAPP',
                                NULL,
                                NULL,
                                FALSE,
                                0
                        );
        commit;

        conc_log ('Analyze plan_partition launched with request ID ' || l_request_id);
    EXCEPTION
        when OTHERS then
            conc_log ('Concurrent program error. Code : ' || sqlcode);
            conc_log ('                         Error : ' || sqlerrm);
    END;

    -- Wait for Concurrent request to complete
    l_call_status := FND_CONCURRENT.WAIT_FOR_REQUEST (
                        l_request_id,
                        10,
                        10000000,
                        l_phase,
                        l_status,
                        l_dev_phase,
                        l_dev_status,
                        l_message );

    conc_debug ('Returned from Wait For Analyze plan partition request Request');
    conc_debug ('Phase : ' || l_dev_phase || '    Status : ' || l_dev_status );

    if (l_dev_status <> 'NORMAL') then
        conc_log ('Analyze plan partition returned with ' || l_dev_status);
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
    end if;
*/

    Refresh_Snapshot(x_return_status);


END ATP_Downtime_Complete;

---------------------------------------------------------------------------------

PROCEDURE ATP_Sync_Error (
                p_old_plan_id       IN      number,
                p_new_plan_id       IN      number
) IS
    l_return_status     varchar2(1);

BEGIN
    conc_log ('Sync Error: Unable to continue further');
    Update_Summary_Flag (   p_new_plan_id,
                            G_SF_SYNC_ERROR,
                            l_return_status
                        );
    conc_log ('ATP Status Flag Update : ' || l_return_status);

END ATP_Sync_Error;
---------------------------------------------------------------------------------

-- Synchronization Downtime Calculation
-- Values stored in Global variables defined in spec.
-- The average records per unit time is calculated, and
-- the total number of Sales orders that can be processed
-- during this time is computed. The total number of records
-- that can be processed during the synchronization downtime
-- is then computed and stored.
PROCEDURE Calculate_Downtime_SO_Records (
                p_number_of_records    IN       number,
                p_total_time           IN       number
) IS

l_time_per_record       number;

BEGIN

    conc_debug ('------Calculate_Downtime_SO_Records ------');
    conc_debug ('Time : ' || p_total_time || '  Orders : ' || p_number_of_records );
    conc_debug ('Current threshold : ' || G_TF7_SO_THRESHOLD);

    G_TF7_TOTAL_RECORDS := G_TF7_TOTAL_RECORDS + p_number_of_records;
    G_TF7_TOTAL_TIME := G_TF7_TOTAL_TIME + p_total_time;

    if (G_TF7_TOTAL_RECORDS = 0) then
        G_TF7_SO_THRESHOLD := 0;
        return;
    end if;
    l_time_per_record :=  G_TF7_TOTAL_TIME / G_TF7_TOTAL_RECORDS ;

    if (l_time_per_record = 0) then
        G_TF7_SO_THRESHOLD := 0;
        return;
    end if;
    G_TF7_SO_THRESHOLD := G_TF7_DOWNTIME / l_time_per_record;

    conc_debug ('New threshold SO records: ' || G_TF7_SO_THRESHOLD);

END Calculate_Downtime_SO_Records;

---------------------------------------------------------------------------------

-- Function to update the summary flag for a plan.
PROCEDURE Update_Summary_Flag (
        p_plan_id       IN      number,
        p_status        IN      number,
        x_return_status OUT NOCOPY    varchar2
) IS
BEGIN
    conc_debug ('------- Update_Summary_Flag -----');
    conc_debug (' Plan ID : '|| p_plan_id || '   Status : ' || p_status);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    update msc_plans
       set summary_flag = p_status
     where plan_id = p_plan_id;

EXCEPTION
    WHEN OTHERS THEN
        conc_debug ('Cannot Update. Error : ' || sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Summary_Flag;

---------------------------------------------------------------------------------

PROCEDURE conc_log (buf IN VARCHAR2)
IS
BEGIN
    msc_util.msc_log (buf);
    --msc_sch_wb.mrp_timing (buf);
    --dbms_output.put_line (buf);

END conc_log;
---------------------------------------------------------------------------------

PROCEDURE conc_debug (buf IN VARCHAR2)
IS
BEGIN
    -- Check value for profile option
    --if (atp_debug_flag in ('Y','C')) then
        conc_log (buf);
    --end if;

END conc_debug;
---------------------------------------------------------------------------------

-- CTO Re-arch changes, this procedure will not be used anymore, instead MSC_SATP_FUNC.New_Extend_Atp is used.
PROCEDURE extend_atp_rec_typ (
        p_atp_tab           IN OUT NOCOPY       MRP_ATP_PUB.ATP_Rec_Typ,
        p_size              IN                  number
) IS
BEGIN

    p_atp_tab.Row_ID.Extend(p_size);
    p_atp_tab.Inventory_Item_Name.Extend(p_size);
    p_atp_tab.Organization_Id.Extend(p_size);
    p_atp_tab.Source_Organization_Code.Extend(p_size);
    p_atp_tab.Demand_Source_Delivery.Extend(p_size);
    p_atp_tab.Demand_Source_Type.Extend(p_size);
    p_atp_tab.Demand_Source_Header_id.Extend(p_size);
    p_atp_tab.Scenario_Id.Extend(p_size);
    p_atp_tab.Order_Number.Extend(p_size);
    p_atp_tab.Destination_Time_Zone.Extend(p_size);
    p_atp_tab.Requested_Arrival_Date.Extend(p_size);
    p_atp_tab.Earliest_Acceptable_Date.Extend(p_size);
    p_atp_tab.Latest_Acceptable_Date.Extend(p_size);
    p_atp_tab.Freight_Carrier.Extend(p_size);
    p_atp_tab.Ship_Method.Extend(p_size);
    p_atp_tab.Ship_Set_Name.Extend(p_size);
    p_atp_tab.Arrival_Set_Name.Extend(p_size);
    p_atp_tab.Ship_Date.Extend(p_size);
    p_atp_tab.Arrival_Date.Extend(p_size);
    p_atp_tab.Available_Quantity.Extend(p_size);
    p_atp_tab.Requested_Date_Quantity.Extend(p_size);
    p_atp_tab.Group_Ship_Date.Extend(p_size);
    p_atp_tab.Group_Arrival_Date.Extend(p_size);
    p_atp_tab.Vendor_Id.Extend(p_size);
    p_atp_tab.Vendor_Name.Extend(p_size);
    p_atp_tab.Vendor_Site_Id.Extend(p_size);
    p_atp_tab.Vendor_Site_Name.Extend(p_size);
    p_atp_tab.Insert_Flag.Extend(p_size);
    p_atp_tab.OE_Flag.Extend(p_size);
    p_atp_tab.Error_Code.Extend(p_size);
    p_atp_tab.Atp_Lead_Time.Extend(p_size);
    p_atp_tab.Message.Extend(p_size);
    p_atp_tab.End_Pegging_Id.Extend(p_size);
    p_atp_tab.Old_Source_Organization_Id.Extend(p_size);
    p_atp_tab.Old_Demand_Class.Extend(p_size);
    p_atp_tab.ato_delete_flag.Extend(p_size);
    p_atp_tab.attribute_05.Extend(p_size);
    p_atp_tab.attribute_06.Extend(p_size);
    p_atp_tab.attribute_07.Extend(p_size);
    p_atp_tab.attribute_01.Extend(p_size);
    p_atp_tab.customer_name.Extend(p_size);
    p_atp_tab.customer_class.Extend(p_size);
    p_atp_tab.customer_location.Extend(p_size);
    p_atp_tab.customer_country.Extend(p_size);
    p_atp_tab.customer_state.Extend(p_size);
    p_atp_tab.customer_city.Extend(p_size);
    p_atp_tab.customer_postal_code.Extend(p_size);
    p_atp_tab.req_item_detail_flag.Extend(p_size);
    p_atp_tab.request_item_id.Extend(p_size);
    p_atp_tab.req_item_req_date_qty.Extend(p_size);
    p_atp_tab.req_item_available_date.Extend(p_size);
    p_atp_tab.req_item_available_date_qty.Extend(p_size);
    p_atp_tab.request_item_name.Extend(p_size);
    p_atp_tab.old_inventory_item_id.Extend(p_size);
    p_atp_tab.sales_rep.Extend(p_size);
    p_atp_tab.customer_contact.Extend(p_size);
    p_atp_tab.subst_flag.Extend(p_size);
    p_atp_tab.party_site_id.Extend(p_size); --2814895
    p_atp_tab.part_of_set.Extend(p_size);  --4500382



END extend_atp_rec_typ;
---------------------------------------------------------------------------------

PROCEDURE Get_Instance_Refresh_Number (
                p_plan_id           IN      number,
                p_instance_id       IN      number,
                x_refresh_number    OUT NOCOPY     number
) IS

BEGIN
    conc_debug ('------Get_Instance_Refresh_Number -------');
    conc_debug ('Plan ID        : ' || p_plan_id);
    conc_debug ('Instance_ID    : ' || p_instance_id );

    x_refresh_number := -1;

    select apps_lrn
      into x_refresh_number
      from msc_plan_refreshes
     where plan_id = p_plan_id
       and sr_instance_id = p_instance_id;

    conc_debug ('Refresh Number : ' || x_refresh_number);

EXCEPTION

    when NO_DATA_FOUND then
        conc_debug ('No data found for query. Returning -1');
        x_refresh_number := -1;

    when OTHERS then
        conc_debug ('Exception: Others. Returning -1 ');
        conc_debug ('Error Msg : ' || sqlerrm);
        x_refresh_number := -1;

END Get_Instance_Refresh_Number;
---------------------------------------------------------------------------------

PROCEDURE Extended_Sync_Wait (
                l_time                  IN  number,
                x_return_status         OUT NOCOPY    varchar2
) IS
BEGIN
        conc_log (' Sleeping for ' || l_time || ' seconds');
        DBMS_LOCK.SLEEP(l_time);
        conc_log (' Back from sleep ');
END Extended_Sync_Wait;
---------------------------------------------------------------------------------

PROCEDURE Print_Input_Rec (
                x_atp_rec               IN      MRP_ATP_PUB.ATP_Rec_Typ
) IS

l_counter   number;

BEGIN

    conc_log (' ----Printing Input Record  ---- ');

    for l_counter in 1..x_atp_rec.calling_module.count loop

        conc_log (l_counter || '.  ' ||
                ' Dmd ID : ' || x_atp_rec.attribute_03(l_counter) ||
                '   Inst : ' || x_atp_rec.instance_id (l_counter) ||
                '   SO Line ID : ' || x_atp_rec.identifier(l_counter)  ||
                '   Inv Item : ' || x_atp_rec.inventory_item_id(l_counter)  ||
                '   Qty : ' || x_atp_rec.quantity_ordered(l_counter)  ||
                '   Date : ' || x_atp_rec.requested_ship_date(l_counter)  ||
                '   Cust : ' || x_atp_rec.customer_id(l_counter)  ||
                '   Cst St ID: ' || x_atp_rec.customer_site_id(l_counter)  ||
                '   Refsh No : ' || x_atp_rec.attribute_04(l_counter)  ||
                '   Ordr No : ' || x_atp_rec.attribute_08(l_counter)  ||
                '   ATO Line ID : ' || x_atp_rec.ato_model_line_id(l_counter)  ||
                '   Session ID : ' || x_atp_rec.attribute_11(l_counter)  ||
                ' .');

    end loop;

    conc_log (' ----Done Printing Records  ---- ');

END Print_Input_Rec;
---------------------------------------------------------------------------------

PROCEDURE Refresh_Snapshot (
                x_return_status         OUT NOCOPY    varchar2
) IS

lv_msc_schema     VARCHAR2(30);
v_snap_exist      number;

Cursor msc_schema IS
    SELECT a.oracle_username
    FROM   FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
    WHERE  a.oracle_id = b.oracle_id
    AND    b.application_id= 724;

Cursor atp_snap IS
    SELECT 1
    FROM   all_objects
    WHERE  object_name like 'MSC_ATP_PLAN_SN'
    AND    owner = lv_msc_schema;

BEGIN

    conc_log ('------- Refresh ATP Plan SN ----------');

    OPEN msc_schema;
    FETCH msc_schema INTO lv_msc_schema;
    CLOSE msc_schema;

    OPEN atp_snap;
    FETCH atp_snap INTO v_snap_exist;
    CLOSE atp_snap;

    -- refresh the snapshot if it exists
    if v_snap_exist =1 then
        conc_log ('Complete Refresh of Snapshot Started');
        DBMS_SNAPSHOT.REFRESH( lv_msc_schema||'.MSC_ATP_PLAN_SN', 'C');
        conc_log ('Refresh Complete');
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
        conc_log ('Exception in Refresh Snapshot');
        conc_log ('SqlCode : ' || sqlcode);
        conc_log ('Sql error MSG : ' || sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;

END Refresh_Snapshot;
---------------------------------------------------------------------------------

PROCEDURE Parse_Sales_Order_Number (
        p_order_number_string   IN                varchar2,
        p_order_number          IN OUT NOCOPY      number
) IS

l_end           number;
l_counter       number;
l_max_counter   number;
l_char          varchar2(1);
l_num_char      number;

BEGIN
    msc_sch_wb.atp_debug ('------Begin Parse_Sales_Order_string-----');
    msc_sch_wb.atp_debug ('');
    msc_sch_wb.atp_debug ('String : ' || p_order_number_string);
    msc_sch_wb.atp_debug ('Number : ' || p_order_number);

    BEGIN
        p_order_number := to_number (p_order_number_string);
        msc_sch_wb.atp_debug ('Order number is : ' || p_order_number);
        return;
    EXCEPTION
        WHEN others then
                msc_sch_wb.atp_debug ('Order number has to be processed');
    END;

    l_end := 0;
    l_counter := 0;
    l_max_counter := length(p_order_number_string);

    msc_sch_wb.atp_debug ('Parse SO: Length of Order Number String : '|| l_max_counter);

    if (l_max_counter = 0) then
        msc_sch_wb.atp_debug ('String is null' );
        return;
    end if;

    while (l_end <> 1) loop

        l_counter := l_counter + 1;
        if (l_counter > l_max_counter ) then
            l_end := 1;
            msc_sch_wb.atp_debug ('Parse SO: Max Length reached');
            exit;
        end if;

        l_char := substr (p_order_number_string, l_counter, 1);
        BEGIN
            l_num_char := to_number (l_char);
        EXCEPTION
            WHEN OTHERS then
                msc_sch_wb.atp_debug ('Parse SO: String end detected');
                l_end := 1;
        END;
    end loop;

    if (l_counter > l_max_counter) then
        msc_sch_wb.atp_debug ('Order number string is a number');

        BEGIN
           p_order_number := to_number (p_order_number_string);
        EXCEPTION
            WHEN others then
                msc_sch_wb.atp_debug ('Parse SO: Something wrong. Should not be here');
                return;
        END;

    elsif (l_counter = 1) then
        msc_sch_wb.atp_debug ('Order Number not properly formatted.');
    else
        msc_sch_wb.atp_debug ('Parse SO: Counter is at ' || l_counter);
        BEGIN
            p_order_number := to_number (substr (p_order_number_string, 1,l_counter -1));
        EXCEPTION
            WHEN others then
                msc_sch_wb.atp_debug ('Parse SO: Something wrong. Should not be here');
                return;
        END;
    end if;

    msc_sch_wb.atp_debug ('Order number is : ' || p_order_number);

EXCEPTION
    WHEN others THEN
        msc_sch_wb.atp_debug ('Something wrong in Parse Sales Order');

END Parse_Sales_Order_Number;

-----------------------------------


END MSC_ATP_24x7;

/

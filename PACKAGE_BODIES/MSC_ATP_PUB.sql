--------------------------------------------------------
--  DDL for Package Body MSC_ATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_PUB" AS
/* $Header: MSCEATPB.pls 120.15 2007/12/12 10:25:46 sbnaik ship $  */
G_PKG_NAME 		CONSTANT 	VARCHAR2(30) := 'MSC_ATP_PUB';
NO_APS_INSTANCE      	CONSTANT 	INTEGER := 140;
PROF_TBL_NOT_IN_SYNC    CONSTANT        INTEGER := 170;
G_INV_CTP				NUMBER := FND_PROFILE.value('INV_CTP');
G_CTO_FLAG				NUMBER := 0;
G_CALL_ATP             			number :=2;  --4421391, the flag will track whether debug/session is set or not.
--G_ATP_CHECK                             VARCHAR2(1) := 'N'; /* Bug 2249504 */
G_ATP_BOM_REC				MRP_ATP_PUB.ATP_BOM_Rec_Typ;
--G_DB_PROFILE				VARCHAR2(128);  bug3049003 changed from G_DB_PROFILE to l_a2m_dblink

-- This package contains 2 public procedures : Call_ATP and Call_ATP_No_Commit.
-- Call_ATP and Call_ATP_No_Commit are almost the same except
-- Call ATP is a automonous transaction which will commit the data.
-- Call_ATP_No_Commit will be used by backlog scheduling and Call_ATP will be
-- used by OM and all the other caller.  In order to maintain this package
-- easier, Call_ATP actually calls the Call_ATP_No_Commit and then do a commit



PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Check_CTO(
	p_atp_rec            IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
	p_session_id         IN          NUMBER,
	--p_db_profile         IN          VARCHAR2,
	--p_atp_check          IN OUT      NoCopy VARCHAR2,
	--x_atp_bom_rec        OUT         NoCopy MRP_ATP_PUB.ATP_BOM_Rec_Typ,
	x_return_status      OUT         NoCopy VARCHAR2,
	x_msg_count          OUT         NoCopy NUMBER,
	x_msg_data           OUT         NoCopy VARCHAR2 )
IS


BEGIN
   --null out this procedure as it is not required after CTO rearchitecture project
   null;
EXCEPTION
    WHEN others THEN
         null;
         x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
         --ROLLBACK;
END Check_CTO;
Procedure Update_Custom_Information(p_atp_rec     IN MRP_ATP_PUB.ATP_Rec_Typ,
                                    p_session_id IN NUMBER
                                    )
IS
i number;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Enter Update_Custom_Information');
    END IF;

    FORALL i in 1..p_atp_rec.inventory_item_id.count
    update mrp_atp_schedule_temp
    Set
    inventory_item_name   = p_atp_rec.inventory_item_name(i),
    source_organization_id   = p_atp_rec.source_organization_id(i),
    source_organization_code   = p_atp_rec.source_organization_code(i),
    delivery_lead_time   = p_atp_rec.delivery_lead_time(i),
    freight_carrier   = p_atp_rec.freight_carrier(i),
    ship_method   = p_atp_rec.ship_method(i),
    scheduled_ship_date   = p_atp_rec.ship_date(i),  -- different
    available_quantity   = p_atp_rec.available_quantity(i),
    requested_date_quantity   = p_atp_rec.requested_date_quantity(i),
    group_ship_date   = p_atp_rec.group_ship_date(i),
    group_arrival_date   = p_atp_rec.group_arrival_date(i),
    error_code   = p_atp_rec.error_code(i),
    end_pegging_id   = p_atp_rec.end_pegging_id(i),
    scheduled_arrival_date   = p_atp_rec.arrival_date(i),
    request_item_id   = p_atp_rec.request_item_id(i),
    request_item_name   = p_atp_rec.request_item_name(i),
    req_item_req_date_qty   = p_atp_rec.req_item_req_date_qty(i),
    req_item_available_date_qty   = p_atp_rec.req_item_available_date_qty(i),
    req_item_available_date   = p_atp_rec.req_item_available_date(i),
    sales_rep   = p_atp_rec.sales_rep(i),
    customer_contact   = p_atp_rec.customer_contact(i)

    WHERE session_id = p_session_id
    and   order_line_id = p_atp_rec.identifier(i)
    --same line id may be shared by different items in case of ATO. So we add followig condition
    and   inventory_item_id =  p_atp_rec.inventory_item_id(i);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Number of rows update := ' ||SQL%ROWCOUNT);
       msc_sch_wb.atp_debug('Exit Update_Custom_Information');
    END IF;
Exception
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Error Orrured in Update_Custom_Information := ' || SQLERRM);
       END IF;

END Update_Custom_Information;


-- Added by ngoel on 6/15/2001 as post atp CTO processing needs to be part of calling module's
-- transaction and not of ATP autonomous transaction to maintain correct Demand picture.

PROCEDURE post_atp_cto(
	p_session_id		IN		NUMBER,
	p_atp_rec		IN OUT NOCOPY 	MRP_ATP_PUB.ATP_Rec_Typ,
	x_return_status		OUT		NoCopy VARCHAR2,
        x_msg_data              OUT     	NoCopy VARCHAR2,
        x_msg_count             OUT     	NoCopy NUMBER
)
IS
BEGIN
    --null out procedure as it is not required after CTO rearchitecture procedure
    null;
EXCEPTION
    WHEN others THEN
      null;
END post_atp_cto;

--4421391
PROCEDURE enable_trace(
x_return_status  OUT   NoCopy NUMBER
)
IS
C                      INTEGER;
STATEMENT              VARCHAR2(255);
ROWS_PROCESSED         INTEGER;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('enable_trace: ' || 'Database Trace being enabled');
   END IF;
   C := DBMS_SQL.OPEN_CURSOR;
   -- STATEMENT := 'ALTER SESSION SET SQL_TRACE=TRUE';
   STATEMENT := 'ALTER SESSION SET  events ' || '''' || '10046 trace name context forever, level 12' || '''' ;
   DBMS_SQL.PARSE(C, STATEMENT, DBMS_SQL.NATIVE);
   ROWS_PROCESSED := DBMS_SQL.EXECUTE(C);
   DBMS_SQL.CLOSE_CURSOR(C);
EXCEPTION
  WHEN others THEN
        x_return_status :=-1;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('something wrong in enable_trace : ' || sqlcode);
           msc_sch_wb.atp_debug('enable_trace: ' || sqlerrm);
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
END enable_trace;

PROCEDURE disable_trace(
x_return_status  OUT   NoCopy NUMBER
)
IS

C                      INTEGER;
STATEMENT              VARCHAR2(255);
ROWS_PROCESSED         INTEGER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('disable_trace: ' || 'Database Trace disabled');
  END IF;
  C := DBMS_SQL.OPEN_CURSOR;
  STATEMENT := 'ALTER SESSION SET SQL_TRACE=FALSE';
  DBMS_SQL.PARSE(C, STATEMENT, DBMS_SQL.NATIVE);
  ROWS_PROCESSED := DBMS_SQL.EXECUTE(C);
  DBMS_SQL.CLOSE_CURSOR(C);
EXCEPTION
    WHEN others THEN
        x_return_status :=-1;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('something wrong in disable_trace : ' || sqlcode);
           msc_sch_wb.atp_debug('disable_trace: ' || sqlerrm);
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
END disable_trace; --4421391

Procedure Subst_Workflow(p_atp_rec IN MRP_ATP_PUB.ATP_Rec_Typ)

IS
l_sales_rep                     VARCHAR2(250);
l_customer_contact              VARCHAR2(250);
i                               NUMBER;
/* bug 4434875: rewrite query useing base tables
CURSOR C_CUSTCNT(p_cust_id number,
                 p_cust_site_id number) IS
       select wf.name
       from ra_site_uses_all rsua,
            wf_roles wf,
            fnd_user fnd,
            ra_contacts ra
       where ra.customer_id = p_cust_id
       and   rsua.site_use_id = p_cust_site_id
       and   ra.address_id = rsua.address_id
       and   ra.contact_id = fnd.customer_id
       and   fnd.start_date <= sysdate
       and   ( fnd.end_date IS NULL OR fnd.end_date >= trunc(sysdate))
       and   wf.orig_system = 'FND_USR'
       and   wf.orig_system_id = fnd.user_id
       and   wf.STATUS = 'ACTIVE';

*/
CURSOR C_CUSTCNT(p_cust_id number,
                 p_cust_site_id number) IS
       select wf.name
       from wf_roles wf,
            fnd_user fnd,
            hz_cust_account_roles hcar
       where hcar.cust_account_id = p_cust_id
       and   hcar.cust_acct_site_id = p_cust_site_id
       and   hcar.cust_account_role_id = fnd.customer_id
       and   fnd.start_date <= trunc(sysdate)
       and   ( fnd.end_date IS NULL OR fnd.end_date >= trunc(sysdate))
       and   wf.orig_system = 'FND_USR'
       and   wf.orig_system_id = fnd.user_id
       and   wf.STATUS = 'ACTIVE';

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Subst_Workflow: ' || '************** Product Subst Workflow **********');
  END IF;

  -- initiate workflow for product substitution
  FOR i in 1..p_atp_rec.inventory_item_id.count LOOP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Subst_Workflow: ' || 'Subst flag := ' ||  NVL(p_atp_rec.subst_flag(i),2));
     END IF;
     IF NVL(p_atp_rec.subst_flag(i),2) = 1 and p_atp_rec.ACTION(i) <> 100 THEN

        l_sales_rep := p_atp_rec.sales_rep(i);
        l_customer_contact := p_atp_rec.customer_contact(i);
        IF NVL(l_sales_rep, '@@@') = '@@@' AND NVL(p_atp_rec.calling_module(i), -99) = 660 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Subst_Workflow: ' || 'Get sales rep');
            END IF;
            BEGIN

               select min(wf.name)
               into   l_sales_rep
               from wf_roles wf,
                    oe_order_lines_all oe
               where oe.line_id = p_atp_rec.identifier(i)
               and wf.orig_system= 'PER'
               and wf.orig_system_id= oe.salesrep_id
               and wf.status='ACTIVE';
            EXCEPTION
               WHEN OTHERS THEN
                  l_sales_rep := null;
            END;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Subst_Workflow: ' || 'customer id := ' || p_atp_rec.customer_id(i));
           msc_sch_wb.atp_debug('Subst_Workflow: ' || 'customer site id := ' || p_atp_rec.customer_site_id(i));
           msc_sch_wb.atp_debug('Subst_Workflow: ' || 'l_customer_contact := ' || NVL(l_customer_contact, '@@'));
           msc_sch_wb.atp_debug('Subst_Workflow: ' || 'calling_module := ' ||  NVL(p_atp_rec.calling_module(i), -99));
        END IF;

        IF NVL(l_customer_contact, '@@@') = '@@@' AND NVL(p_atp_rec.calling_module(i), -99) = 660 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Subst_Workflow: ' || 'Get Customer conatct');
            END IF;
            OPEN C_CUSTCNT(p_atp_rec.customer_id(i), p_atp_rec.customer_site_id(i));
            FETCH C_CUSTCNT INTO l_customer_contact;
            CLOSE C_CUSTCNT;
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Subst_Workflow: ' || 'l_customer_contact := ' || l_customer_contact);
           msc_sch_wb.atp_debug('Subst_Workflow: ' || 'l_sales_rep := ' || l_sales_rep);
        END IF;
        IF NVL(l_sales_rep, '-99') <> '-99' or NVL(l_customer_contact, '-99') <> '-99'  THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Subst_Workflow: ' || 'Initiate Substitute workflow');
              msc_sch_wb.atp_debug('Subst_Workflow: ' || 'request_item_name := ' || p_atp_rec.request_item_name(i));
              msc_sch_wb.atp_debug('Subst_Workflow: ' || 'inventory_item_name := ' || p_atp_rec.inventory_item_name(i));
              msc_sch_wb.atp_debug('Subst_Workflow: ' || 'order_number := '|| p_atp_rec.order_number(i));
               msc_sch_wb.atp_debug('Subst_Workflow: ' || 'identifier := ' || p_atp_rec.identifier(i));
              msc_sch_wb.atp_debug('Subst_Workflow: ' || 'Source_Organization_Code := ' || p_atp_rec.Source_Organization_Code(i));
              msc_sch_wb.atp_debug('Subst_Workflow: ' || 'quantity_ordered := ' || p_atp_rec.quantity_ordered(i));
           END IF;
           BEGIN
              mrp_msc_exp_wf.start_substitute_workflow(
                                   p_atp_rec.request_item_name(i),
                                   p_atp_rec.inventory_item_name(i),
                                   p_atp_rec.order_number(i),
                                   p_atp_rec.identifier(i),
                                   p_atp_rec.Source_Organization_Code(i),
                                   p_atp_rec.Source_Organization_Code(i),
                                   p_atp_rec.quantity_ordered(i),
                                   p_atp_rec.quantity_ordered(i),
                                   l_sales_rep,
                                   l_customer_contact);
           EXCEPTION
              WHEN OTHERS THEN
                null;
           END;
        END IF;

     END IF;
  END LOOP;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Subst_Workflow: ' || 'End Subst workflow');
  END IF;
END Subst_Workflow;


PROCEDURE Call_ATP_Commit (
	p_session_id         	IN OUT 	        NoCopy NUMBER,
	p_atp_rec            	IN    	        MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_rec            	OUT NOCOPY  	MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_supply_demand  	OUT NOCOPY  	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period         	OUT NOCOPY  	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_details        	OUT NOCOPY  	MRP_ATP_PUB.ATP_Details_Typ,
	x_return_status      	OUT   	        NoCopy VARCHAR2,
	x_msg_data           	OUT   	        NoCopy VARCHAR2,
	x_msg_count          	OUT   	        NoCopy NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
i			PLS_INTEGER;
cursor_name 		INTEGER;
rows_processed		INTEGER;
l_count                 number;
l_a2m_dblink            VARCHAR2(80); --bug3049003
l_instance_id           number;--bug3049003
l_return_status         VARCHAR2(60);--bug3049003
--l_db_profile		VARCHAR2(128);
DBLINK_NOT_OPEN         EXCEPTION;
PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Begin Call_ATP_Commit');
    END IF;

    i := p_atp_rec.Calling_Module.FIRST;
    IF i IS NOT NULL THEN
         Call_ATP_No_Commit( p_session_id,
               p_atp_rec,
               x_atp_rec,
               x_atp_supply_demand,
               x_atp_period,
               x_atp_details,
               x_return_status,
               x_msg_data,
               x_msg_count);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       -- something wrong so we want to rollback;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'expected error in Call_ATP_No_Commit');
       END IF;
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'something wrong in Call_ATP_No_Commit');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    commit;  --  AUTONOMOUS_TRANSACTION


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'Return Status : '||x_return_status);
    END IF;

      MSC_SATP_FUNC.get_dblink_profile(l_a2m_dblink,l_instance_id,l_return_status); --bug3049003 start
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'error in mrp_ap_apps_instances');
       END IF;
      END IF; --bug3049003 end
    -- Set this to be checked later in exception while closing DB Link
    -- Also, don't rollback in case this is set to -1 as this means ATP Transaction
    -- is finished. This would prevent rolling back any changes in calling module.
    i := -1;

    -- Bug 1822005, modified Call_ATP to close DB Link after ATP Transaction is
    -- finished by commit or rollback.
    --l_db_profile := FND_PROFILE.value('MRP_ATP_DATABASE_LINK');
    IF l_a2m_dblink IS NOT NULL THEN  --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'after commit, before closing DB Link');
       END IF;
       cursor_name := dbms_sql.open_cursor;
       DBMS_SQL.PARSE(cursor_name, 'alter session close database link ' ||l_a2m_dblink,  --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
                      dbms_sql.native);

       -- Added this block to handle the exception in case DB LInk wasn't open.
       -- If not handled, this causes ORA-02081.
       BEGIN
          rows_processed := dbms_sql.execute(cursor_name);
       EXCEPTION
          WHEN DBLINK_NOT_OPEN THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'inside DBLINK_NOT_OPEN');
               END IF;
       END;

       DBMS_SQL.close_cursor(cursor_name);
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'after commit, after closing DB Link');
       END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('End Call_ATP_Commit');
    END IF;
EXCEPTION
    WHEN others THEN
        -- something wrong so we want to rollback;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('something wrong in Call_ATP_Commit : ' || sqlcode);
           msc_sch_wb.atp_debug('Call_ATP_Commit: ' || sqlerrm);
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'Return Status in excpetion : '||x_return_status);
        END IF;

        -- Error Handling Changes krajan
        IF (x_atp_rec.inventory_item_id.COUNT = 0) THEN
                x_atp_rec := p_atp_rec;
        END IF;

	-- Error Handling changes. Rollback for all cases.
        IF NVL(i, -99) <> -1 THEN
              -- This means the exception is raised within ATP Transaction.
              ROLLBACK; --5195929 No need to have a save point as this is an Autonomous transaction
        END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'after rollback, before closing DB Link');
           END IF;
        -- Close the DB Link in case it is open
        -- Bug 1822005, modified Call_ATP to close DB Link after ATP Transaction is
        -- finished by commit or rollback.
        --l_db_profile := FND_PROFILE.value('MRP_ATP_DATABASE_LINK');
        IF l_a2m_dblink IS NOT NULL THEN         --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink

           cursor_name := dbms_sql.open_cursor;
           DBMS_SQL.PARSE(cursor_name, 'alter session close database link ' ||l_a2m_dblink,  --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
                          dbms_sql.native);

           -- Added this block to handle the exception in case DB LInk wasn't open.
           -- If not handled, this causes ORA-02081.
           BEGIN
              rows_processed := dbms_sql.execute(cursor_name);
           EXCEPTION
              WHEN DBLINK_NOT_OPEN THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'inside DBLINK_NOT_OPEN exception');
                   END IF;
           END;

           DBMS_SQL.close_cursor(cursor_name);
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'after rollback, after closing DB Link');
           END IF;
        END IF;

END Call_ATP_Commit;


PROCEDURE Call_ATP (
	p_session_id         	IN OUT 	        NoCopy NUMBER,
	p_atp_rec            	IN    	        MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_rec            	OUT NOCOPY      MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_supply_demand  	OUT NOCOPY      MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period         	OUT NOCOPY    	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_details        	OUT NOCOPY    	MRP_ATP_PUB.ATP_Details_Typ,
	x_return_status      	OUT   	        NoCopy VARCHAR2,
	x_msg_data           	OUT   	        NoCopy VARCHAR2,
	x_msg_count          	OUT   	        NoCopy NUMBER
) IS

i                               PLS_INTEGER;
--l_db_profile                	VARCHAR2(128);
l_atp_rec                       MRP_ATP_PUB.ATP_Rec_Typ;

-- Bug 2387242 : krajan
-- Variables for SQL trace setup
C                      INTEGER;
STATEMENT              VARCHAR2(255);
ROWS_PROCESSED         INTEGER;
l_count number;
L_RETURN_NUM        number;
cursor_name 		INTEGER;      --5195929 for exception block
DBLINK_NOT_OPEN         EXCEPTION;    --5195929 for exception block
l_a2m_dblink            VARCHAR2(80); --5195929 for db link
l_instance_id           number;       --5195929 for db link
l_return_status         VARCHAR2(60); --5195929 for db link

BEGIN
    --bug3609185 initialize API returm status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    G_CALL_ATP :=1;		--4421391
    L_RETURN_NUM := 1;  --4421391
    msc_sch_wb.set_session_id(p_session_id);
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Begin Call_ATP');
       FOR i in 1..p_atp_rec.inventory_item_id.count LOOP
           msc_sch_wb.atp_debug('Item # ' || i  || ' := ' || p_atp_rec.inventory_item_id(i));
           msc_sch_wb.atp_debug('LAD := ' || p_atp_rec.latest_acceptable_date(i));
           msc_sch_wb.atp_debug('Ship date := ' ||  p_atp_rec.requested_ship_date(i));
           msc_sch_wb.atp_debug('Qty := ' || p_atp_rec.quantity_ordered(i));
           msc_sch_wb.atp_debug('Order number := ' || p_atp_rec.order_number(i));

       END LOOP;


    END IF;
    SAVEPOINT start_of_call_atp; --5195929  added savepoint so that rollbak only
                                 --undo the transactions till here
    --bug3609185 removing second set_session_id as it is already done at line 916
    --msc_sch_wb.set_session_id(p_session_id);
    -- Bug 2387242 : krajan
    -- Set Sql Trace.
    IF order_sch_wb.mr_debug in ('T','C') THEN
      enable_trace(L_RETURN_NUM); --4421391
      IF L_RETURN_NUM = -1 then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
    END IF;


    i := p_atp_rec.Calling_Module.FIRST;
    IF i IS NOT NULL THEN

      -- Check if this is a demand modify from OM and profile option
      -- is set to allow prescheduled order import without ATP, return ATP success.
      IF NVL(p_atp_rec.Calling_Module(i), -99) = 660 AND
         NVL(FND_PROFILE.value('MSC_OM_IMPORT_PRESCHEDULED'), 'N') = 'Y' THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP: ' || 'Inside Prescheduled order import support for OM');
         END IF;

         x_atp_rec := p_atp_rec;
         FOR i in 1..p_atp_rec.Calling_Module.LAST LOOP
             x_atp_rec.Available_quantity(i) := p_atp_rec.Quantity_Ordered(i);
             x_atp_rec.Available_quantity(i) := p_atp_rec.Quantity_Ordered(i);
             x_atp_rec.Error_Code(i) := 0;

	     -- ngoel 1/23/2001, need to set group dates and ship date
	     -- based on if there was a ship/ arrival set in the request.

             --x_atp_rec.Ship_Date(i) := p_atp_rec.Requested_Ship_Date(i);
             x_atp_rec.ship_date(i) := TRUNC(NVL(p_atp_rec.requested_ship_date(i),
                                             p_atp_rec.requested_arrival_date(i) -
                                                NVL(p_atp_rec.delivery_lead_time(i),0))
                                       ) ;--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
             --bug3609185 Setting the arrival  date also.
             x_atp_rec.arrival_date(i) := TRUNC(NVL(p_atp_rec.requested_arrival_date(i),
                                             p_atp_rec.requested_ship_date(i) +
                                                NVL(p_atp_rec.delivery_lead_time(i),0))
                                       );--4460369 + MSC_ATP_PVT.G_END_OF_DAY;

             IF p_atp_rec.ship_set_name(i) IS NOT NULL THEN
                -- ship set, set the group date
                x_atp_rec.group_ship_date(i) := p_atp_rec.requested_ship_date(i);
             ELSIF p_atp_rec.arrival_set_name(i) IS NOT NULL THEN
                -- arrival set, set the group date
                x_atp_rec.group_arrival_date(i) := p_atp_rec.requested_arrival_date(i);
             END IF;

         END LOOP;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP: ' || 'After Assigning values for x_atp_rec');
         END IF;

      ELSE


	l_atp_rec := p_atp_rec;

-- Start 4279623
        IF nvl(l_atp_rec.calling_module(1), -1) not in (724,-1) THEN
          FORALL i in 1..l_atp_rec.action.COUNT
              insert into msc_oe_data_temp
                      (
                      seq_id,
                      order_line_id,
                      oe_flag,
                      internal_org_id,
                      session_id
                      )
                      values
                      (
                      msc.msc_oe_data_temp_s.NEXTVAL,
                      l_atp_rec.identifier(i),
                     decode(l_atp_rec.oe_flag(i),'Y',(Select decode(MSC_ATP_PVT.G_INV_CTP, 5, l_atp_rec.OE_FLAG(i),
                             decode( prha.interface_source_code, 'MRP', 'Y', 'MSC', 'Y','CTO', 'Y', 'CTO-LOWER LEVEL', 'Y', 'N')) --4889943
                      from   po_requisition_headers_all prha
                      where  prha.requisition_header_id = l_atp_rec.attribute_01(i))), --5008194/FP 5054154

                     decode(l_atp_rec.oe_flag(i),'Y', (Select po.destination_organization_id
                      from   po_requisition_lines_all po,
                             oe_order_lines_all oe
                      where  oe.source_document_line_id = po.requisition_line_id
                      and    oe.line_id = l_atp_rec.identifier(i)),NULL), --5008194/FP 5054154
                     p_session_id
                     );

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP: Inserted data into msc_oe_data_temp');
            msc_sch_wb.atp_debug('Records selected in  mrp_oe_data_temp : ' ||  SQL%ROWCOUNT);
         END IF;

         select oe_flag,internal_org_id,seq_id
             bulk collect into
             l_atp_rec.oe_flag,
             l_atp_rec.internal_org_id,
             l_atp_rec.attribute_11
         from msc_oe_data_temp
         where session_id = p_session_id
         order by seq_id;

         IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP: selected data back into the l_atp_rec');
              msc_sch_wb.atp_debug('Internal Org. Count :=' || l_atp_rec.internal_org_id.count);
              msc_sch_wb.atp_debug('OE_FLAG count:= ' || l_atp_rec.oe_flag.count);
              FOR l in 1..l_atp_rec.action.LAST LOOP
                 msc_sch_wb.atp_debug('call_atp: OE_FLAG : ' ||  l_atp_rec.oe_flag(l));
                 msc_sch_wb.atp_debug('call_atp: Internal Org.Id : ' ||  l_atp_rec.internal_org_id(l));
              END LOOP;
         END IF;
        END IF;
-- End 4279623

/*
Bug: 5195929 logic used
if calling module not ( 724 or null) then
   if Flag = False/Null
      Call_atp_commit()
   else
      call_atp_no_commit()
*/      --Incase calling module does not extends.
        IF l_atp_rec.attribute_14.count = 0 THEN
           l_atp_rec.attribute_14.extend;
        END IF;
        --5195929 Starts if it is OM scheduling and flag is set indicating donot commit.
        IF nvl(p_atp_rec.Action(i),100) <> 100 and  NVL(p_atp_rec.Calling_Module(i), -99) <> 724 and
           nvl(l_atp_rec.attribute_14(1),2) = 1 THEN

           MSC_SATP_FUNC.get_dblink_profile(l_a2m_dblink,l_instance_id,l_return_status);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Call_ATP_Commit: ' || 'error in mrp_ap_apps_instances');
              END IF;
           END IF;

           i := p_atp_rec.Calling_Module.FIRST;
           IF i IS NOT NULL THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('ATP Running in non autonomous mode');
              END IF;
              Call_ATP_No_Commit( p_session_id,
                                  p_atp_rec,
                                  x_atp_rec,
                                  x_atp_supply_demand,
                                  x_atp_period,
                                  x_atp_details,
                                  x_return_status,
                                  x_msg_data,
                                  x_msg_count);
              IF l_a2m_dblink IS NOT NULL THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug(' before closing DB Link');
                 END IF;
                 cursor_name := dbms_sql.open_cursor;
                 DBMS_SQL.PARSE(cursor_name, 'alter session close database link ' ||l_a2m_dblink,
                                dbms_sql.native);
                 -- Added this block to handle the exception in case DB LInk wasn't open.
                 -- If not handled, this causes ORA-02081.
                 BEGIN
                    rows_processed := dbms_sql.execute(cursor_name);
                 EXCEPTION
                    WHEN DBLINK_NOT_OPEN THEN
                       IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('inside DBLINK_NOT_OPEN');
                       END IF;
                 END;
                 DBMS_SQL.close_cursor(cursor_name);
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('after commit, after closing DB Link');
                 END IF;
              END IF;
           END IF;
        ELSE
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('ATP Running in autonomous mode'); --5195929 End
           END IF;

        Call_ATP_Commit( p_session_id,
               l_atp_rec,
               x_atp_rec,
               x_atp_supply_demand,
               x_atp_period,
               x_atp_details,
               x_return_status,
               x_msg_data,
               x_msg_count);
        END IF; --5195929
     END IF; --IF NVL(p_atp_rec.Calling_Module(i), -99) = 660 AND
    END IF; --IF i IS NOT NULL THEN


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       -- something wrong so we want to rollback;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('expected error in Call_ATP_No_Commit');
       END IF;
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('something wrong in Call_ATP_No_Commit');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Call_ATP: ' || 'Return Status : '||x_return_status);
    END IF;


    -- Bug 2387242 : krajan
    -- Set Sql Trace.
    IF order_sch_wb.mr_debug in ('T','C') THEN
        disable_trace(L_RETURN_NUM); --4421391
        IF L_RETURN_NUM =-1 then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('End Call_ATP');
    END IF;
EXCEPTION

        -- Error Handling fix : krajan
    WHEN MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        -- something wrong so we want to rollback;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('something wrong in Call_ATP : ' || sqlcode);
           msc_sch_wb.atp_debug('Call_ATP: ' || sqlerrm);
           msc_sch_wb.atp_debug('Call_ATP: Invalid Objects found.');
        END IF;

        -- Step1: Assign output record
        IF (x_atp_rec.Inventory_item_id.COUNT = 0) THEN
                IF (l_atp_rec.Inventory_item_id.COUNT = 0) THEN
                        x_atp_rec := p_atp_rec;
                ELSE
                        x_atp_rec := l_atp_rec;
                END IF;
        END IF;
        -- Step 2: Assign Error codes
        FOR  i IN 1..x_atp_rec.Calling_Module.LAST LOOP
                IF ((NVL(x_atp_rec.Error_Code(i), -1)) in (-1,0,61,150)) THEN
                        x_atp_rec.Error_Code(i) := MSC_ATP_PVT.ATP_INVALID_OBJECTS;
                END IF;
        END LOOP;
        -- Step 3 : Add error to UI display stack
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Call_ATP');
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Call_ATP: ' || 'Return Status in excpetion : '||x_return_status);
        END IF;
        -- End Error Handling Fix

        -- Bug 2387242 : krajan
        -- Set Sql Trace.
        IF order_sch_wb.mr_debug in ('T','C') THEN
           disable_trace(L_RETURN_NUM); --4421391
           IF L_RETURN_NUM =-1 THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           END IF;
        END IF;


    WHEN others THEN
        -- something wrong so we want to rollback;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('something wrong in Call_ATP : ' || sqlcode);
           msc_sch_wb.atp_debug('Call_ATP: ' || sqlerrm);
        END IF;

       -- Error Handling fix : krajan
        IF (x_atp_rec.Inventory_item_id.COUNT = 0) THEN
                IF (l_atp_rec.Inventory_item_id.COUNT = 0) THEN
                         x_atp_rec := p_atp_rec;
                ELSE
                         x_atp_rec := l_atp_rec;
                END IF;
        END IF;
        FOR  i IN 1..x_atp_rec.Calling_Module.LAST LOOP
                IF ((NVL(x_atp_rec.Error_Code(i), -1)) in (-1,0,61,150)) THEN
                        x_atp_rec.Error_Code(i) := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
                END IF;
        END LOOP;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Call_ATP');
        END IF;
        -- End Error Handling Fix

        -- Bug 2387242 : krajan
        -- Set Sql Trace.
        IF order_sch_wb.mr_debug in ('T','C') THEN
                disable_trace(L_RETURN_NUM); --4421391
                IF L_RETURN_NUM =-1 THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                END IF;
        END IF;
        --5195929 add to the exception block
        IF nvl(p_atp_rec.Action(i),100) <> 100 and
             NVL(p_atp_rec.Calling_Module(i), -99) <> 724 and
                  nvl(l_atp_rec.attribute_14(1),2) = 1 THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('before rollback, before closing DB Link');
           END IF;
              ROLLBACK TO SAVEPOINT start_of_call_atp;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('after rollback, before closing DB Link');
           END IF;
           IF l_a2m_dblink IS NOT NULL THEN
              cursor_name := dbms_sql.open_cursor;
              DBMS_SQL.PARSE(cursor_name, 'alter session close database link ' ||l_a2m_dblink,
                             dbms_sql.native);
              BEGIN
                 rows_processed := dbms_sql.execute(cursor_name);
              EXCEPTION
                 WHEN DBLINK_NOT_OPEN THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('inside DBLINK_NOT_OPEN exception');
                   END IF;
              END;
              DBMS_SQL.close_cursor(cursor_name);
              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('after rollback, after closing DB Link');
              END IF;
           END IF;
        END IF;
        --5195929 End
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Call_ATP: ' || 'Return Status in excpetion : '||x_return_status);
        END IF;

END Call_ATP;


PROCEDURE Call_ATP_No_Commit (
	p_session_id         	IN OUT 	        NoCopy NUMBER,
	p_atp_rec            	IN    	        MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_rec            	OUT NOCOPY  	MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_supply_demand  	OUT NOCOPY  	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period         	OUT NOCOPY  	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_details        	OUT NOCOPY  	MRP_ATP_PUB.ATP_Details_Typ,
	x_return_status      	OUT   	        NoCopy VARCHAR2,
	x_msg_data           	OUT   	        NoCopy VARCHAR2,
	x_msg_count          	OUT   	        NoCopy NUMBER
) IS

l_instance_id	 		NUMBER;
l_refresh_number 		NUMBER;
--l_db_profile     		VARCHAR2(128);

-- krajan : 2927155
l_end_refresh_number            NUMBER;
-- savirine, Sep 6, 2001:  declared l_dblink and l_return_status variables,
-- these variables will be used in the get_regions procedure call

l_dblink                        VARCHAR2(128);
l_return_status                 VARCHAR2(60);

l_assign_set_id                 NUMBER;
plsql_block                     VARCHAR2(10000);
i                               PLS_INTEGER;
l_atp_rec                       MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_rec_temp                  MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_bom_flag                  MRP_ATP_PUB.number_arr;
l_shipset_stat_rec              MRP_ATP_PUB.shipset_status_rec_type;

l_source_organization_id        NUMBER;
l_customer_id                   NUMBER;
l_to_organization_id            NUMBER;
l_customer_site_id              NUMBER;
l_from_location                 NUMBER;
l_to_location                   NUMBER;
l_ship_method                   VARCHAR2(30);
l_delivery_lead_time            NUMBER;
l_requested_ship_date           DATE;
l_a2m_dblink                    VARCHAR2(80);
-- Bugs 2020607, 2104018, 2031894, 1869748 New variables.
l_prev_work_ship_date           DATE;
l_sysdate                       DATE;
l_past_due_ship_date            NUMBER; --bug4291375
l_sysdate_orc_new               DATE;   --bug4291375
-- Bug 2368426
l_def_assign_set_id             NUMBER DEFAULT NULL;
l_wf_profile                    varchar2(1);
-- Bug 2413888, 2281628
l_group_ship_date               DATE;
l_group_arrival_date            DATE;
l_start                         PLS_INTEGER;
l_end                           PLS_INTEGER;
-- Bug 2413888, 2281628

l_details_flag                  NUMBER := 2;

-- dsting setproc
l_line_status                   NUMBER;
l_set_status                    NUMBER;

-- rajjain 02/03/2003 Bug 2766713 Begin
l_set_fail_flag                 VARCHAR2(1) := 'N';
j                               PLS_INTEGER;
k                               PLS_INTEGER;
-- rajjain 02/03/2003 Bug 2766713 End

-- 2833417
l_ato_ship_date                 DATE;

-- ship_rec_cal
l_offsetted_date		DATE;
l_sysdate_osc			DATE;
l_sysdate_orc                   DATE; --bug3439591
l_trunc_sysdate                 DATE := TRUNC(sysdate); --bug3439591

-- For summary enhancement
l_summary_flag                  VARCHAR2(1);
l_enforce_model_lt              VARCHAR2(1);

--bug3520746
l_node_id NUMBER;
l_rac_count NUMBER;

--bug3583705
l_encoded_text                  varchar2(4000);
l_msg_app                       varchar2(50);
l_msg_name                      varchar2(30);

--2814895
l_country                       varchar2(60);
l_state                         varchar2(150);
l_city                          varchar2(60);
l_postal_code                   varchar2(60);
l_party_site_id                 NUMBER;

l_session_loc_des               VARCHAR2(100); --ATP Debug Workflow
l_spid_des                      NUMBER; --ATP Debug Workflow
l_trace_loc_des                 VARCHAR2(100); --ATP Debug Workflow
l_login_user                    VARCHAR2(255) := FND_GLOBAL.user_name ;

-- 4421391 Variables for SQL trace setup
C                      INTEGER;
STATEMENT              VARCHAR2(255);
ROWS_PROCESSED         INTEGER;
L_RETURN_NUM        NUMBER;
L_MOVE_PAST_DUE_TO_SYSDATE varchar2(1);  -- Bug 5584634/5618929

--custom_api
l_custom_atp_rec                 MRP_ATP_PUB.ATP_Rec_Typ;
l_modify_flag                    number;
l_custom_ret_sts                 varchar2(30);
BEGIN
--Started change for bug 4421391
    L_RETURN_NUM := 1;
    IF G_CALL_ATP = 2 THEN
     msc_sch_wb.set_session_id(p_session_id);
     IF order_sch_wb.mr_debug in ('T','C') THEN
      enable_trace(L_RETURN_NUM);
      IF L_RETURN_NUM =-1 THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
     END IF;
    END IF;

 --4421391

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Begin Call_ATP_No_Commit');
    END IF;

    -- initialize API returm status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- created a savepoint
    SAVEPOINT start_of_call_atp_no_commit;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'oe_flag count : ' ||  p_atp_rec.oe_flag.count);
    END IF;

    l_atp_rec := p_atp_rec;

    i := p_atp_rec.Calling_Module.FIRST;

    IF i IS NOT NULL THEN

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'p_atp_rec.Calling_Module : '||p_atp_rec.Calling_Module(i));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'p_atp_rec.ship_set_name : '||p_atp_rec.ship_set_name(i));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'G_INV_CTP : '||G_INV_CTP);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'p_atp_rec.requested_ship_date : '
                          ||p_atp_rec.requested_ship_date(i));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'p_atp_rec.requested_arrival_date : '
                          ||p_atp_rec.requested_arrival_date(i));
        END IF;

    -- Set l_cto_flag = 1 in case call is from OM or Configurator
    -- and a ship set is specified
    -- Change l_cto_flag to G_CTO_FLAG - ngoel 1/11/2001

    -- Bug 2218892, moved this to Check_CTO as it is needed to be set while called from Call_ATP
/*
    IF NVL(p_atp_rec.Calling_Module(i), -99) IN (-1, 660, 708)  AND
       G_INV_CTP = 4 and p_atp_rec.ship_set_name(i) IS NOT NULL THEN
       G_CTO_FLAG := 1;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'G_CTO_FLAG : '||G_CTO_FLAG);
    END IF;
*/

        IF NVL(p_atp_rec.Calling_Module(i), -99) = 724 THEN

            -- this is for planning server atp inquiry.
            -- get instance id from record of tables p_atp_rec.

            l_instance_id := p_atp_rec.instance_id(i);

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_instance_id = '||l_instance_id);
            END IF;
            -- get the assignment set from profile in msc.  if it is null,
            -- the assignment get from msc_apps_instance.
            --diag_atp
            --read the assignment set from the attribute_03. If it passed
            -- then use it else use from the profile option

            IF p_atp_rec.attribute_03.count >= 1 AND
                NVL(p_atp_rec.attribute_03(i), -1) <> -1
                THEN
                l_assign_set_id := p_atp_rec.attribute_03(i);
            ELSE
                l_assign_set_id := FND_PROFILE.value('MSC_ATP_ASSIGN_SET');
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_assign_set_id = '||l_assign_set_id);
            END IF;

            IF l_assign_set_id is NULL THEN
                SELECT assignment_set_id
                INTO   l_assign_set_id
                FROM   msc_apps_instances
                WHERE  instance_id = l_instance_id;
            END IF;

        ELSE
           -- G_DB_PROFILE := FND_PROFILE.value('MRP_ATP_DATABASE_LINK');  bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
            --l_db_profile := FND_PROFILE.value('MRP_ATP_DATABASE_LINK');
            -- this request is from the sourcce instance
            -- get the assignment set from profile in mrp

            --diag_atp
            --read the assignment set from the attribute_03. If it passed
            -- then use it else use from the profile option
            IF p_atp_rec.attribute_03.count >= 1 AND
            NVL(p_atp_rec.attribute_03(i), -1) <> -1
                THEN
                l_assign_set_id := p_atp_rec.attribute_03(i);
            ELSE
                l_assign_set_id := FND_PROFILE.value('MRP_ATP_ASSIGN_SET');
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_assign_set_id = '||l_assign_set_id);
            END IF;

        END IF;

/*
  ELSE
      -- this request is from the sourcce instance
      -- get the assignment set from profile in mrp

      l_assign_set_id := FND_PROFILE.value('MRP_ATP_ASSIGN_SET');

      -- get instance id from mrp_ap_apps_instances.
      BEGIN
         SELECT instance_id
         INTO   l_instance_id
         FROM   mrp_ap_apps_instances;
      EXCEPTION
	 WHEN others THEN
            -- something wrong so we want to rollback
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'No instance Id record found in mrp_ap_apps_instances');
            END IF;
            x_atp_rec := l_atp_rec;
            RAISE FND_API.G_EXC_ERROR ;
      END;
*/
    END IF;

    --s_cto_rearch
    g_atp_check := 'N';

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Before Calling ATI for finding CTO-ATP Items');
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_instance_id := ' || NVL(l_instance_id, -1));
    END IF;

    IF l_instance_id IS NULL and NVL(p_atp_rec.Calling_Module(i), -99) <> 724 THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Query from non-APS instance, find instance_id');
        END IF;

       /* BEGIN
            SELECT instance_id, a2m_dblink
            INTO   l_instance_id, l_a2m_dblink
            FROM   mrp_ap_apps_instances;

        EXCEPTION
            WHEN others THEN
                -- something wrong so we want to rollback;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Error in mrp_ap_apps_instances : ' || sqlcode);
                END IF;
                x_atp_rec := l_atp_rec;

                FOR i in 1..x_atp_rec.Calling_Module.LAST LOOP
                    x_atp_rec.Error_Code(i) := NO_APS_INSTANCE;
                END LOOP;

                RAISE FND_API.G_EXC_ERROR ;
        END;*/ --code commented for bug3049003

        -- Uncommenting get_dblink_profile for bug 3632914
        MSC_SATP_FUNC.get_dblink_profile(l_a2m_dblink,l_instance_id,l_return_status); --bug3049003 start

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_instance_id := ' || NVL(l_instance_id, -1));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_a2m_dblink := ' || l_a2m_dblink);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_return_status of := get_dblink_profile ' || l_return_status);
        END IF;

        --bug3940999 dumping the profiles on source
        IF l_a2m_dblink is not NULL THEN
            MSC_SATP_FUNC.put_src_to_dstn_profiles(p_session_id,
                                                   l_return_status);
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit : ' || 'l_return_status of put_src_to_dstn_profiles:= ' || l_return_status);
        END IF;

        /* bug 3623018: Do not raise this error here. Raise it only when some item is found to be atpbale
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_atp_rec := l_atp_rec;

        FOR i in 1..x_atp_rec.Calling_Module.LAST LOOP
         x_atp_rec.Error_Code(i) := NO_APS_INSTANCE;
        END LOOP;

        RAISE FND_API.G_EXC_ERROR ;

        END IF; ---bug3049003 end
        */

        MSC_ATP_PVT.G_INSTANCE_ID := l_instance_id;

        --- if MRP:ATP Database link profile option and mrp_ap_apps_instances table not in sync then
        --- raise an error
        /*IF (NVL(UPPER(l_a2m_dblink), -1) <> NVL(UPPER(G_DB_PROFILE), -1)) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'MRP:ATP DATABASE LINK profile option and MRP_AP_APPS_INSTANCES table
                not in SYNC');
            END IF;
            x_atp_rec := l_atp_rec;

            FOR i in 1..x_atp_rec.Calling_Module.LAST LOOP
                x_atp_rec.Error_Code(i) := PROF_TBL_NOT_IN_SYNC;
            END LOOP;

            RAISE FND_API.G_EXC_ERROR ;
        END IF;*/  --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink

    END IF;

    MSC_ATP_PVT.G_CALLING_MODULE := NVL(l_atp_rec.Calling_Module(1), -99);
    SELECT mrp_ap_refresh_s.nextval
    INTO l_refresh_number
    FROM dual;

    --s_cto_rearch: 24x7
    MSC_ATP_PVT.G_REFRESH_NUMBER := l_refresh_number;
    --e_cto_rearch: 24x7


    MSC_ATP_CTO.Check_Lines_For_CTO_ATP (l_atp_rec,
                                         p_session_id,
                                         l_a2m_dblink,  --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
                                         --bug 3632914: If instance is not defined then
                                         --pass instance id as -1 so that error while inserting CTO
                                         -- sources doesn't occur as MSC_CTO_SOURCES has non-null instance_id column .
                                         nvl(l_instance_id, -1),
                                         l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        -- something wrong so we want to rollback;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('l_return_status := ' || l_return_status);
            msc_sch_wb.atp_debug('Call_ATP: ' || 'expected error in Call to Check_CTO');
        END IF;
        x_return_status := l_return_status;
        x_atp_rec := l_atp_rec;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --l_customer_site_id := NULL;
    -- The above line is replaced by following code to support
    --- order import where request set contains requenst
    -- from many customers with different customer site
    -- Lets say we have customers in the order of C1, C2,C1
    -- If any info (ship method, lead time etc) is missing for
    -- request C1 then ATP will go in for first customer
    -- site and get its region info and will put into temp table.
    -- When C1 is processed again then code will go in only if
    --- ship method, lead time info is missing.
    --- If this info is missing then ATP will
    -- try to insert records into regions_temp tbale but will
    -- fail as info for C1 already exists. we trap this
    -- exception in Get_regions procedure in MSCSATPB.pls

    IF l_atp_rec.inventory_item_id.count > 0 THEN
        l_customer_site_id := -1234;
        --2814895, added address parameters and party_site_id
        l_country := -1234;
        l_state := -1234;
        l_city := -1234;
        l_postal_code := -1234;
        l_party_site_id := -1234;
    ELSE
        l_customer_site_id := NULL;
        --2814895, added address parameters and party_site_id
        l_country := NULL;
        l_state := NULL;
        l_city := NULL;
        l_postal_code := NULL;
        l_party_site_id := NULL;
    END IF;

    -- Bug 2413888, 2281628, 3000016
    -- Initialize group ship/arrival date variables
    l_start := l_atp_rec.ACTION.FIRST;
    MSC_ATP_PROC.Initialize_Set_Processing(l_atp_rec, l_start);

    -- bug 2748730. Initialize the group_ship_date and group_arrival_date to the end of day
    l_group_ship_date := TRUNC(sysdate);--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
    l_group_arrival_date := TRUNC(sysdate);--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
    -- Bug 2413888, 2281628

    j := l_atp_rec.inventory_item_id.FIRST;

    WHILE j IS NOT NULL LOOP
     BEGIN --bug3583705
        --  savirine, Sep 05, 2001: call get_regions to get regions info to be used for ATP request.

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'j : ' ||j);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'requested_ship_date : ' ||l_atp_rec.requested_ship_date(j));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'requested_arrival_date : ' ||l_atp_rec.requested_arrival_date(j));
        END IF;
        l_past_due_ship_date := 2; --bug4291375 resetting variable to no past due date
        -- 3000016
        IF G_ATP_CHECK = 'N' THEN

            IF PG_DEBUG in ('Y', 'C') THEN

                msc_sch_wb.atp_debug('Call_ATP_No_Commit: Item Is non atpable');
            END IF;

            IF l_atp_rec.attribute_06(j) is null THEN

                IF PG_DEBUG in ('Y', 'C') THEN

                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || ' Invalid Item Org Combo');
                END IF;

                l_atp_rec.error_code(j) := MSC_ATP_PVT.INVALID_ITEM_ORG_COMBINATION;

                l_end := j;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('identifier := ' || l_atp_rec.identifier(l_end));
                    msc_sch_wb.atp_debug('ato_model_line_id :== ' || l_atp_rec.ato_model_line_id(l_end));
                    msc_sch_wb.atp_debug('bom_item_type := ' || l_atp_rec.bom_item_type(l_end));
                END IF;
                -- advance l_end to the end of the set
                while l_end < l_atp_rec.action.count() and
                      (nvl(l_atp_rec.ship_set_name(l_end+1), -99) = nvl(l_atp_rec.ship_set_name(l_start), -99) and
                      nvl(l_atp_rec.arrival_set_name(l_end+1), -99) = nvl(l_atp_rec.arrival_set_name(l_start), -99))
                loop
                    mrp_atp_pvt.assign_atp_input_rec(l_atp_rec,l_end,x_atp_rec,x_return_status);
                    l_end := l_atp_rec.inventory_item_id.next(l_end);

                    IF l_atp_rec.identifier(l_end) = l_atp_rec.ato_model_line_id(l_end) THEN
                        MSC_ATP_CTO.G_MODEL_IS_PRESENT := 1;
                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Model is present');
                        END IF;
                    END IF;
                end loop;
                mrp_atp_pvt.assign_atp_input_rec(l_atp_rec,l_end,x_atp_rec,x_return_status);

                IF l_atp_rec.identifier(l_end) = l_atp_rec.ato_model_line_id(l_end) THEN
                    MSC_ATP_CTO.G_MODEL_IS_PRESENT := 1;
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Model is present');
                    END IF;
                END IF;


                MSC_ATP_PROC.Process_Set_Line(x_atp_rec, j, l_line_status);
                MSC_ATP_PVT.process_time_stamp_errors(x_atp_rec, j);--4460369
                IF (x_atp_rec.ship_set_name(l_start) is not null or
                    x_atp_rec.arrival_set_name(l_start) is not null) and
                    (l_end - l_start > 0)
                THEN
                    MSC_ATP_PROC.Process_Set_Dates_Errors(x_atp_rec, 'S', l_set_status, l_start, l_end);
                END IF;

                j := l_atp_rec.inventory_item_id.next(l_end);
                if j is null then
                    exit;
                end if;

                l_start := l_end + 1 ;
                l_end := NULL;
                IF l_start <= l_atp_rec.action.count THEN
                    MSC_ATP_PROC.Initialize_Set_Processing(l_atp_rec, l_start);
                END IF;
            END IF;
        END IF; -- F G_ATP_CHECK := 'N' THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || ' Before finding region based sourcing');
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.customer_site_id(j));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.customer_country(j));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.customer_state(j));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.customer_city(j));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.customer_postal_code(j));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.party_site_id(j));
        END IF;
        IF  (NVL(l_customer_site_id, -1) <> l_atp_rec.customer_site_id(j))
             --2814895, added checks for address parameters and party_site_id
            OR (NVL(l_party_site_id, -1) <> l_atp_rec.party_site_id(j))
            OR (NVL(l_country, -1) <> l_atp_rec.customer_country(j))
            OR (NVL(l_state, -1) <> l_atp_rec.customer_state(j))
            OR (NVL(l_city, -1) <> l_atp_rec.customer_city(j))
            OR (NVL(l_postal_code, -1) <> l_atp_rec.customer_postal_code(j))
            AND (NVL(l_atp_rec.calling_module(j), -99) <> 724)                     -- Bug 2085071 Fix
            AND (l_atp_rec.Source_Organization_id(j) IS NULL or l_atp_rec.ship_method(j) IS NULL or
            --- add condition for quantity_ordered so that get_regions is not called for unscheduling
            l_atp_rec.delivery_lead_time(j) IS NULL) and l_atp_rec.quantity_ordered(j) > 0 THEN

            IF NVL(g_atp_check, '@') = 'N' THEN
                l_dblink := NULL;
            ELSE
                l_dblink := l_a2m_dblink; --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
            END IF;

            l_customer_site_id := l_atp_rec.customer_site_id(j);
            --2814895, added for address parameters and party_site_id
            l_country := l_atp_rec.customer_country(j);
            l_state := l_atp_rec.customer_state(j);
            l_city := l_atp_rec.customer_city(j);
            l_postal_code := l_atp_rec.customer_postal_code(j);
            l_party_site_id := l_atp_rec.party_site_id(j);

            MSC_SATP_FUNC.Get_Regions (
                    p_customer_site_id	=> l_atp_rec.customer_site_id(j),
                    p_calling_module	=> NVL(l_atp_rec.calling_module(j), -99),  -- Bug 2085071 Fix
                    -- i.e. Source (ERP) or Destination (724)
                    p_instance_id		=> l_instance_id,
                    p_session_id          => p_session_id,
                    p_dblink		=> l_dblink,
                    x_return_status	=> l_return_status,
                    p_location_id       => NULL, --location_id
                    p_location_source   => NULL, --location_source
                    p_supplier_site_id  => NULL , --supplier_site_id
                    -- 2814895, added address parameters, party_site_id and line_id
                    -- as parameter to Get_Regions
                    p_postal_code       => l_atp_rec.customer_postal_code(j),
                    p_city              => l_atp_rec.customer_city(j),
                    p_state             => l_atp_rec.customer_state(j),
                    p_country           => l_atp_rec.customer_country(j),
                    p_party_site_id     => l_atp_rec.party_site_id(j),
                    p_order_line_id     => l_atp_rec.identifier(j) --2814895, added identifier for address parameters
                    );

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Get_Regions, return status : ' || l_return_status);
            END IF;

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                -- something wrong so we want to rollback;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'expected error in Call to Get_Regions');
                END IF;
                x_atp_rec := l_atp_rec;
                --bug3583705 if this xcptn is raised then processing for all line will not stop
                -- as it will be handled in when others xcptn
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'something wrong in Call to Get_Regions');
                END IF;
                x_atp_rec := l_atp_rec;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'g_atp_check := ' || g_atp_check);
        END IF;

        IF NVL(g_atp_check, '@') = 'N' THEN

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'No ATPable item or CTO model in the ATP request from source');
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Set values for ship and group date and error code');
        END IF;
        -- we cannot assign this directly since the l_atp_rec may not be a
        -- complete record, that is, there are some elements that are not initialized before.
        -- x_atp_rec := l_atp_rec;

        IF l_atp_rec.identifier(j) = l_atp_rec.ato_model_line_id(j) and l_atp_rec.bom_item_type(j) = 1 THEN
            MSC_ATP_CTO.G_MODEL_IS_PRESENT := 1;
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Model is present');
        END IF;
        mrp_atp_pvt.assign_atp_input_rec(l_atp_rec,j,x_atp_rec,x_return_status);

        if x_atp_rec.action(j) = 100 then
            x_atp_rec.error_code(j) := 61;
        else
            x_atp_rec.error_code(j) := 0;
        end if;

        x_atp_rec.available_quantity(j) := x_atp_rec.quantity_ordered(j);
        x_atp_rec.requested_date_quantity(j) := x_atp_rec.quantity_ordered(j);

        --Vivek - Calcuate Delievry Lead time

        l_ship_method := x_atp_rec.ship_method(j);
        l_delivery_lead_time := x_atp_rec.delivery_lead_time(j);

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_delivery_lead_time : ' || l_delivery_lead_time);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'quantity_ordered(' || j || ') : ' || x_atp_rec.quantity_ordered(j));
        END IF;

        -- krajan : 2748041
        -- Defaulting the delivery lead time for ATO delete flag case
        -- and cancellation of non-atpable item case.
        -- By setting it to 0, we dont have to go through the whole delivery
        -- lead time calculation.
        if  (x_atp_rec.quantity_ordered(j) = 0 ) then
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'G_CTO_FLAG is 2 for non_atpable item or');
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'A non ATPable item is being cancelled');
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Setting the delivery lead time to 0');
            END IF;
            l_delivery_lead_time := 0;
            --bug 3979115:
            x_atp_rec.receiving_cal_code(j) := MSC_CALENDAR.FOC;
            x_atp_rec.shipping_cal_code(j) := MSC_CALENDAR.FOC;
            x_atp_rec.intransit_cal_code(j) := MSC_CALENDAR.FOC;
        end if;
        -- end 2748041

        /* Bug 3335268 - Moved the assignments out of the "IF" block as these variables
                         are used after "END IF" as well.*/
        l_source_organization_id := x_atp_rec.source_organization_id(j);
        l_to_organization_id := x_atp_rec.organization_id(j);
        l_customer_id := x_atp_rec.customer_id(j);
        l_customer_site_id := x_atp_rec.customer_site_id(j);

        IF (NVL(l_delivery_lead_time, -1) = -1) THEN
            -- Bug3593394 - Calculate DLT only if parameters have changed
            IF j=1
                --bug 3979115: If previous line is for unscheduling then recalculate again
                --as we do not calculate these values for line marked for unscheduling
                OR (x_atp_rec.quantity_ordered(j-1) = 0)
                OR x_atp_rec.source_organization_id(j) <> x_atp_rec.source_organization_id(j-1)
                OR NVL(x_atp_rec.internal_org_id(j),-1) <> NVL(x_atp_rec.internal_org_id(j-1),-1)
                OR NVL(x_atp_rec.organization_id(j),-1) <> NVL(x_atp_rec.organization_id(j-1),-1)
                OR NVL(x_atp_rec.customer_id(j),-1) <> NVL(x_atp_rec.customer_id(j-1),-1)
                OR NVL(x_atp_rec.customer_site_id(j),-1) <> NVL(x_atp_rec.customer_site_id(j-1),-1)
                --2814895, added for address parameters and party_site_id support
                OR NVL(x_atp_rec.party_site_id(j),-1)  <> NVL(x_atp_rec.party_site_id(j-1),-1)
                OR (     NVL(x_atp_rec.customer_postal_code(j),-1) <> NVL(x_atp_rec.customer_postal_code(j-1),-1)
                     OR NVL(x_atp_rec.customer_city(j),-1)        <> NVL(x_atp_rec.customer_city(j-1),-1)
                     OR NVL(x_atp_rec.customer_state(j),-1)       <> NVL(x_atp_rec.customer_state(j-1),-1)
                     OR NVL(x_atp_rec.customer_country(j),-1)     <> NVL(x_atp_rec.customer_country(j-1),-1))
                OR NVL(x_atp_rec.ship_method(j),'@@@') <> NVL(x_atp_rec.ship_method(j-1),'@@@') THEN
                /* Bug 3335268 - Moved the assignments out of the "IF" block as these variables
                             are used after "END IF" as well.
                l_source_organization_id := x_atp_rec.source_organization_id(j);
                l_to_organization_id := x_atp_rec.organization_id(j);
                l_customer_id := x_atp_rec.customer_id(j);
                l_customer_site_id := x_atp_rec.customer_site_id(j);
                */

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_source_organization_id : ' || l_source_organization_id);
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_to_organization_id : ' || l_to_organization_id);
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_customer_id : ' || l_customer_id);
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_customer_site_id : ' || l_customer_site_id);
                END IF;

                l_from_location := MSC_SATP_FUNC.src_location_id(l_source_organization_id, null, null);

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_from_location : ' || l_from_location);
                END IF;

                -- Bug 3449812 - Base DLT on internal_org_id if available
                -- IF NVL(x_atp_rec.internal_org_id(j),l_to_organization_id) IS NOT NULL THEN

                -- Bug 3515520, don't use org in case customer/site is populated
                IF (x_atp_rec.internal_org_id(j) IS NOT NULL) OR
                   (l_to_organization_id IS NOT NULL AND (l_customer_id IS NULL AND l_customer_site_id IS NULL)) THEN
                    l_to_location := MSC_SATP_FUNC.src_location_id(NVL(x_atp_rec.internal_org_id(j),l_to_organization_id), null, null);
                ELSIF (l_customer_id IS NOT NULL AND l_customer_site_id IS NOT NULL) THEN  --2814895
                    l_to_location := MSC_SATP_FUNC.src_location_id(null, l_customer_id, l_customer_site_id);
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'l_to_location : ' || l_to_location);
                END IF;

                -- dsting dlt
                -- IF x_atp_rec.internal_org_id(j) IS NOT NULL THEN

                -- Bug 3515520, don't use org in case customer/site is populated
                IF (x_atp_rec.internal_org_id(j) IS NOT NULL) OR
                   (l_to_organization_id IS NOT NULL
                    AND ((l_customer_id IS NULL AND l_customer_site_id IS NULL)
                          OR l_party_site_id IS NULL
                          OR l_country IS NULL )) THEN  --2814895, added conditions for address parameter and party_site_id
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Inside Org code');
                    END IF;
                    MSC_SATP_FUNC.get_src_transit_time(
                        l_source_organization_id,
                        l_from_location,
                        NVL(x_atp_rec.internal_org_id(j), l_to_organization_id), -- Bug 3515520
                        -- x_atp_rec.internal_org_id(j) -- Bug 3515520
                        l_to_location,
                        p_session_id,
                        NULL,
                        l_ship_method,
                        l_delivery_lead_time);
                ELSIF ( l_customer_site_id is not NULL) THEN --2814895
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Inside customer code');
                    END IF;
                    MSC_SATP_FUNC.get_src_transit_time(
                        l_source_organization_id,
                        l_from_location,
                        -- l_to_organization_id, -- Bug 3515520
                        NULL, -- Bug 3515520
                        l_to_location,
                        p_session_id,
                        l_customer_site_id,
                        l_ship_method,
                        l_delivery_lead_time,
                        2 --2814895, partner_type for customer
                        );
                ELSIF ( l_party_site_id is not NULL) THEN --2814895
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Inside party_site code');
                    END IF;
                     MSC_SATP_FUNC.get_src_transit_time(
                        l_source_organization_id,
                        l_from_location,
                        NULL,
                        l_to_location,
                        p_session_id,
                        l_party_site_id,
                        l_ship_method,
                        l_delivery_lead_time,
                        4 --2814895, partner_type for party_site_id
                        );
                ELSIF (l_country IS NOT NULL) THEN --2814895
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Inside address_parameter code');
                    END IF;
                     MSC_SATP_FUNC.get_src_transit_time(
                        l_source_organization_id,
                        l_from_location,
                        NULL,
                        l_to_location,
                        p_session_id,
                        x_atp_rec.identifier(j), --2814895, using identifier as partner_site_id for addres_parameters
                        l_ship_method,
                        l_delivery_lead_time,
                        5 --2814895 , partner_type for address parametrs
                        );
                END IF;

                l_delivery_lead_time := CEIL(l_delivery_lead_time);

            ELSE

                -- Bug3593394 - Use from previous line
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'DLT parameters have not changed');
                END IF;
                l_delivery_lead_time := x_atp_rec.delivery_lead_time(j-1);
                l_ship_method := x_atp_rec.ship_method(j-1);

            END IF;

        END IF; 	-- IF (NVL(l_delivery_lead_time, -1) = -1) THEN

        x_atp_rec.delivery_lead_time(j) := NVL(l_delivery_lead_time,0);

        x_atp_rec.ship_method(j) := l_ship_method; /* Bug 2111591 */

        /* ship_rec_cal changes begin
           Moved the code from here for ship_rec_cal inside else of override.
        x_atp_rec.ship_date(j) := TRUNC(NVL(x_atp_rec.requested_ship_date(j),
                                            (x_atp_rec.requested_arrival_date(j) -
                                            NVL(x_atp_rec.delivery_lead_time(j),0)))
                                        ) + MSC_ATP_PVT.G_END_OF_DAY;

        -- Bugs 2020607, 2104018, 2031894, 1869748
        -- Begin Changes

        l_sysdate := MSC_SATP_FUNC.src_next_work_day(
                                    x_atp_rec.source_organization_id(j),
                                    sysdate);
        IF l_sysdate IS NULL THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Next date not found in Calendar');
            END IF;
            x_atp_rec.error_code(j) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
            RAISE NO_DATA_FOUND;
        END IF;

        IF x_atp_rec.ship_date(j) < l_sysdate THEN
            x_atp_rec.requested_date_quantity(j) := 0;
        ELSE
            x_atp_rec.requested_date_quantity(j) := x_atp_rec.quantity_ordered(j);
        END IF;
        l_prev_work_ship_date := MSC_SATP_FUNC.src_prev_work_day(
        x_atp_rec.source_organization_id(J),
        x_atp_rec.ship_date(j));
        IF l_prev_work_ship_date IS NULL THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'prev date for ship date not found in Calendar');
            END IF;
            x_atp_rec.error_code(j) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
            RAISE NO_DATA_FOUND;
        END IF;

        -- Bug 2194850, time stamp not updating for schedule ship date for non-atpable items
        -- bug 1929645.  In case we have the following case,
        -- today D0, requested_ship_date D10 5pm is a non-working day
        -- and l_atp_rec.ship_date is D9 (previous working day) 0:00.
        -- we want to return ship date as D9 0:00 instead of D10 5pm.

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'requested_ship_date(j) : ' || to_char(x_atp_rec.requested_ship_date(j), 'dd/mm/yyyy hh:mi:ss'));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'ship_date(j) : ' || to_char(x_atp_rec.ship_date(j), 'dd/mm/yyyy hh:mi:ss'));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_prev_work_ship_date : ' || to_char(l_prev_work_ship_date, 'dd/mm/yyyy hh:mi:ss'));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'requested_arrival_date(j): ' || to_char(x_atp_rec.requested_arrival_date(j),
                'dd/mm/yyyy hh:mi:ss'));
        END IF;*/

	/* Bug 3335268 - We dont require calendar/date calculation in unschedule cases */
	IF (x_atp_rec.quantity_ordered(j) = 0) THEN

	    IF (x_atp_rec.requested_ship_date(j) is not null) THEN
	        x_atp_rec.ship_date(j) := TRUNC(x_atp_rec.requested_ship_date(j));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
	        x_atp_rec.arrival_date(j) := TRUNC(x_atp_rec.requested_ship_date(j));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
	        x_atp_rec.latest_acceptable_date(j) := GREATEST(NVL(x_atp_rec.latest_acceptable_date(j),
                                                       x_atp_rec.requested_ship_date(j)),x_atp_rec.requested_ship_date(j));  --5224773
	    ELSE
	        x_atp_rec.ship_date(j) := TRUNC(x_atp_rec.requested_arrival_date(j));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
	        x_atp_rec.arrival_date(j) := TRUNC(x_atp_rec.requested_arrival_date(j));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
	        x_atp_rec.latest_acceptable_date(j) := GREATEST(NVL(x_atp_rec.latest_acceptable_date(j),
                                                       x_atp_rec.requested_arrival_date(j)),x_atp_rec.requested_arrival_date(j)); --5224773
	    END IF;

	ELSE
            -- Bug 4000425 Checking for Null ship method.
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' and x_atp_rec.ship_method(j) is not null THEN
                -- Bug3593394 - Calculate only if parameters have changed
                IF (j=1)
                   --bug 3979115: If previous line is for unscheduling then recalculate again
                   --as we do not calculate these values for line marked for unscheduling
                   OR (x_atp_rec.quantity_ordered(j-1) = 0)
                    OR (x_atp_rec.ship_method(j)<>x_atp_rec.ship_method(j-1)) THEN
                    x_atp_rec.intransit_cal_code(j) := MSC_SATP_FUNC.src_get_calendar_code(null, null, null,
				x_atp_rec.ship_method(j), MSC_CALENDAR.VIC);
                ELSE
                    x_atp_rec.intransit_cal_code(j) := x_atp_rec.intransit_cal_code(j-1);
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'Parameters have not changed for VIC');
                    END IF;
                END IF;
            ELSE
                -- Bug 3647208
                x_atp_rec.intransit_cal_code(j) := MSC_CALENDAR.FOC;
            END IF;


            -- Bug 3449812 - base receiving calendar on internal_org_id if available
            --IF Nvl(x_atp_rec.internal_org_id(j),l_to_organization_id) IS NOT NULL THEN

            -- Bug 3515520, don't use org in case customer/site is populated
            -- Bug3593394 - Calculate only if parameters have changed
            IF (j>1)
                --bug 3979115: If previous line is for unscheduling then recalculate again
                --as we do not calculate these values for line marked for unscheduling
                AND (x_atp_rec.quantity_ordered(j-1) > 0)
                AND NVL(x_atp_rec.internal_org_id(j),-1) = NVL(x_atp_rec.internal_org_id(j-1),-1)
                AND NVL(x_atp_rec.organization_id(j),-1) = NVL(x_atp_rec.organization_id(j-1),-1)
                AND NVL(x_atp_rec.customer_id(j),-1) = NVL(x_atp_rec.customer_id(j-1),-1)
                AND NVL(x_atp_rec.customer_site_id(j),-1) = NVL(x_atp_rec.customer_site_id(j-1),-1)
                AND NVL(x_atp_rec.ship_method(j),'@@@') = NVL(x_atp_rec.ship_method(j-1),'@@@') THEN

                x_atp_rec.receiving_cal_code(j) := x_atp_rec.receiving_cal_code(j-1);
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'Parameters have not changed for ORC/CRC');
                END IF;
            ELSIF (x_atp_rec.internal_org_id(j) IS NOT NULL) OR
                (l_to_organization_id IS NOT NULL AND l_customer_id IS NULL AND l_customer_site_id IS NULL) THEN
                x_atp_rec.receiving_cal_code(j) := MSC_SATP_FUNC.src_get_calendar_code(null, null,
                                                  Nvl(x_atp_rec.internal_org_id(j),l_to_organization_id),
                                                  x_atp_rec.ship_method(j), MSC_CALENDAR.ORC);
                -- Bug 3449812 - handle case where both org and customer are null
            ELSIF l_customer_site_id IS NOT NULL AND MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- Bug 3647208 - Call CRC only if using ship/rec cal
                x_atp_rec.receiving_cal_code(j) := MSC_SATP_FUNC.src_get_calendar_code(l_customer_id, l_customer_site_id, null,
                                                  x_atp_rec.ship_method(j), MSC_CALENDAR.CRC);
            ELSE
                x_atp_rec.receiving_cal_code(j) := MSC_CALENDAR.FOC;
            END IF;

            -- Bug3593394 - Calculate only if parameters have changed
            -- Bug 4000425 Added NVL
            IF j=1
                --bug 3979115: If previous line is for unscheduling then recalculate again
                --as we do not calculate these values for line marked for unscheduling
                OR (x_atp_rec.quantity_ordered(j-1) = 0)
                OR NVL(x_atp_rec.ship_method(j),'@@@')<>NVL(x_atp_rec.ship_method(j-1),'@@@')
                OR x_atp_rec.source_organization_id(j) <> x_atp_rec.source_organization_id(j-1) THEN
                x_atp_rec.shipping_cal_code(j) := MSC_SATP_FUNC.src_get_calendar_code(null, null, l_source_organization_id,
				x_atp_rec.ship_method(j), MSC_CALENDAR.OSC);
            ELSE
                    x_atp_rec.shipping_cal_code(j) := x_atp_rec.shipping_cal_code(j-1);
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'Parameters have not changed for OSC');
                    END IF;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'receiving_cal_code : ' || x_atp_rec.receiving_cal_code(j));
                msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'intransit_cal_code : ' || x_atp_rec.intransit_cal_code(j));
                msc_sch_wb.atp_debug('Call_ATP_NO_Commit: ' || 'shipping_cal_code  : ' || x_atp_rec.shipping_cal_code(j));
            END IF;
            /* ship_rec_cal changes end */

            -- Begin Bug 2232555, 2250456

            -- bug 2649670 dsting. Handle override case for nonatpable items
            IF (NVL(x_atp_rec.override_flag(j), 'N') = 'Y') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: Override case. Do not mess with the dates');

                IF (x_atp_rec.requested_ship_date(j) is not null) THEN
                    -- ship_rec_cal project changes. Honor atleast VIC and CRC to compute right arrival date
                    -- x_atp_rec.arrival_date(j) := x_atp_rec.ship_date(j) + x_atp_rec.delivery_lead_time(j);

                    x_atp_rec.ship_date(j) := TRUNC(x_atp_rec.requested_ship_date(j));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;

                    x_atp_rec.arrival_date(j) := TRUNC(MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
                                                        x_atp_rec.ship_date(j), null, 0,
                                                        x_atp_rec.intransit_cal_code(j), x_atp_rec.delivery_lead_time(j), 1,
                                                        x_atp_rec.receiving_cal_code(j), 1
                                                        ));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
                ELSE

                    -- ship_rec_cal project changes. Honor atleast VIC and OSC to compute right ship date
                    x_atp_rec.arrival_date(j) := TRUNC(x_atp_rec.requested_arrival_date(j));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;

                    x_atp_rec.ship_date(j) := TRUNC(MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
                                                        x_atp_rec.arrival_date(j), null, 0,
                                                        x_atp_rec.intransit_cal_code(j), -1 * x_atp_rec.delivery_lead_time(j), -1,
                                                        x_atp_rec.shipping_cal_code(j), -1
                                                        ));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;

                END IF;
            ELSE
                -- ship_rec_cal project changes begin
		-- Bug3593394 - Calculate only if parameters have changed
		IF j=1
                    --bug 3979115: If previous line is for unscheduling then recalculate again
                    --as we do not calculate these values for line marked for unscheduling
                    OR (x_atp_rec.quantity_ordered(j-1) = 0)
                    OR x_atp_rec.source_organization_id(j)<>x_atp_rec.source_organization_id(j-1) THEN
		    l_sysdate := MSC_SATP_FUNC.src_next_work_day(
					  x_atp_rec.source_organization_id(j),
					   l_trunc_sysdate);
                END IF;

		-- Bug3593394 - Calculate only if parameters have changed
                --bug 3687934: Calculate this date when l_sysdate_osc is null as well.
                --l_sysdate might be null for the second or later line if first line is overridden
		IF j=1
                     --bug 3979115: If previous line is for unscheduling then recalculate again
                    --as we do not calculate these values for line marked for unscheduling
                    OR (x_atp_rec.quantity_ordered(j-1) = 0)
                    OR x_atp_rec.shipping_cal_code(j)<>x_atp_rec.shipping_cal_code(j-1) or l_sysdate_osc is null THEN
	   	    l_sysdate_osc := MSC_SATP_FUNC.src_next_work_day(
				x_atp_rec.shipping_cal_code(j),
				l_trunc_sysdate);
                END IF;

                -- Bug3593394 - Calculate only if parameters have changed
                --bug 3687934: Calculate this date when l_sysdate_orc is null
		IF j=1

                    --bug 3979115: If previous line is for unscheduling then recalculate again
                    --as we do not calculate these values for line marked for unscheduling
                    OR (x_atp_rec.quantity_ordered(j-1) = 0)
                    OR x_atp_rec.receiving_cal_code(j)<>x_atp_rec.receiving_cal_code(j-1) or l_sysdate_orc is null THEN
                    l_sysdate_orc := MSC_SATP_FUNC.src_next_work_day(
				x_atp_rec.receiving_cal_code(j),
				l_trunc_sysdate); --bug3439591
                END IF;

		--bug3583705 not required
		/*IF l_sysdate IS NULL OR l_sysdate_osc IS NULL or l_sysdate_orc IS NULL THEN
		       IF PG_DEBUG in ('Y', 'C') THEN
			  msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Next date not found in Calendar');
		       END IF;
		       x_atp_rec.error_code(j) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
		       RAISE NO_DATA_FOUND;
		END IF;*/

		-- First compute the ship date without adding end of day.
		IF x_atp_rec.requested_ship_date(j) IS NOT NULL THEN
			x_atp_rec.ship_date(j) := MSC_SATP_FUNC.SRC_PREV_WORK_DAY(
						x_atp_rec.shipping_cal_code(j),
						x_atp_rec.requested_ship_date(j));
		ELSE
		        x_atp_rec.ship_date(j) := MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
					x_atp_rec.requested_arrival_date(j), x_atp_rec.receiving_cal_code(j), -1,
					x_atp_rec.intransit_cal_code(j), -1 * x_atp_rec.delivery_lead_time(j), -1,
					x_atp_rec.shipping_cal_code(j), -1
					);

		END IF;
                --bug3439591 start
		/* --commented as a part of 3439591
		 -- Check if the ship date so computed is less than sysdate_osc.If yes we set quantity = 0.
                IF x_atp_rec.ship_date(j) < l_sysdate_osc THEN
                    x_atp_rec.requested_date_quantity(j) := 0;
                ELSE
                  x_atp_rec.requested_date_quantity(j) := x_atp_rec.quantity_ordered(j);
                END IF;
		*/
							  L_MOVE_PAST_DUE_TO_SYSDATE := NVL(FND_PROFILE.value('MSC_MOVE_PAST_DUE_TO_SYSDATE'), 'Y'); -- Bug 5584634/5618929
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Schedule: ' || 'MOVE_PAST_DUE_TO_SYS_DATE :'|| L_MOVE_PAST_DUE_TO_SYSDATE);
                END IF;
                if L_MOVE_PAST_DUE_TO_SYSDATE = 'Y' THEN  -- Bug 5584634/5618929
                IF x_atp_rec.ship_date(j) < l_sysdate_osc THEN

                  x_atp_rec.ship_date(j) := l_sysdate_osc;
                  l_past_due_ship_date := 1; --bug4291375 setting variable to point pass due request ship date.
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'New ship_date := ' || l_sysdate_osc);
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Request date is less than sysdate');
                  END IF;
                END IF;

                IF x_atp_rec.requested_ship_date(j) IS NOT NULL THEN
                     x_atp_rec.latest_acceptable_date(j) := GREATEST(NVL(x_atp_rec.latest_acceptable_date(j),
                                                                x_atp_rec.requested_ship_date(j)),x_atp_rec.requested_ship_date(j),
                                                                l_sysdate_osc);
                ELSE
                    IF l_past_due_ship_date = 2 THEN
                     x_atp_rec.latest_acceptable_date(j) := GREATEST(NVL(x_atp_rec.latest_acceptable_date(j),
                                                                x_atp_rec.requested_arrival_date(j)),x_atp_rec.requested_arrival_date(j),
                                                                l_sysdate_orc);
                    ELSE --bug4291375 If requested ship date is past due date then LAD needs to be offseted by the lead time.
                      --calculate date after offset lead time
                      l_sysdate_orc_new := MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
                                        l_trunc_sysdate, x_atp_rec.shipping_cal_code(j), 1,
                                        x_atp_rec.intransit_cal_code(j), x_atp_rec.delivery_lead_time(j), 1,
                                        x_atp_rec.receiving_cal_code(j), 1
                                        );
                      -- Calculate LAD after lead time taken in consideration
                      x_atp_rec.latest_acceptable_date(j) := GREATEST(NVL(x_atp_rec.latest_acceptable_date(j),
                                                                x_atp_rec.requested_arrival_date(j)),x_atp_rec.requested_arrival_date(j),
                                                                l_sysdate_orc_new);
                    END IF;
                END IF;
                END IF;
		--bug3439591 end

		-- Bug 2194850, time stamp not updating for schedule ship date for non-atpable items
		-- bug 1929645.  In case we have the following case,
		-- today D0, requested_ship_date D10 5pm is a non-working day
		-- and l_atp_rec.ship_date is D9 (previous working day) 0:00.
		-- we want to return ship date as D9 0:00 instead of D10 5pm.

		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'requested_ship_date(j) : ' || to_char(x_atp_rec.requested_ship_date(j), 'dd/mm/yyyy hh:mi:ss'));
		   msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'ship_date(j) : ' || to_char(x_atp_rec.ship_date(j), 'dd/mm/yyyy hh:mi:ss'));
		   msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'requested_arrival_date(j): ' || to_char(x_atp_rec.requested_arrival_date(j),
						'dd/mm/yyyy hh:mi:ss'));
                   msc_sch_wb.atp_debug('l_sysdate_orc_new := ' || l_sysdate_orc_new);       --bug4291375
                   msc_sch_wb.atp_debug('l_past_due_ship_date := ' || l_past_due_ship_date); --bug4291375
		END IF;
                -- ship_rec_cal project changes end
                --s_cto_rearch: bug 3169831 : Honor lead time only when profile option is turned on
                l_enforce_model_lt := NVL(FND_PROFILE.VALUE('MSC_ENFORCE_MODEL_LT'), 'Y');

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('l_enforce_model_lt := ' || l_enforce_model_lt);
                   msc_sch_wb.atp_debug('atp lead time := ' || x_atp_rec.atp_lead_time(j));
                END IF;

                -- 2833417 dsting add atp_lead_time if any
                if nvl(x_atp_rec.atp_lead_time(j), 0) > 0 and MSC_ATP_PVT.G_INV_CTP = 5
                                                          and l_enforce_model_lt = 'Y' then
                    -- we offset the lead time only in case of ODS ATP
                    l_ato_ship_date := MSC_SATP_FUNC.src_date_offset(
                    x_atp_rec.source_organization_id(j),
                    l_sysdate,
                    x_atp_rec.atp_lead_time(j));
                    --bug3583705 not required.
                    /*IF l_ato_ship_date IS NULL THEN
                        msc_sch_wb.atp_debug('prev date for ship date not found in Calendar');
                        x_atp_rec.error_code(j) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
                        RAISE NO_DATA_FOUND;
                    END IF;*/
                else
                    -- 2894867
                    l_ato_ship_date := x_atp_rec.ship_date(j);
                end if;
                msc_sch_wb.atp_debug('l_ato_ship_date: ' || l_ato_ship_date);

                -- dsting
                -- 2833417
                -- As part of ship_rec_cal remove the redundant if clause and compute the arrival date here.
                -- Recompute the ship date and subsequently arrive date.

                x_atp_rec.ship_date(j) := TRUNC(GREATEST(x_atp_rec.ship_date(j), l_sysdate_osc, l_ato_ship_date));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;

                x_atp_rec.arrival_date(j) := TRUNC(MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
                			x_atp_rec.ship_date(j), null, 0,
                			x_atp_rec.intransit_cal_code(j), x_atp_rec.delivery_lead_time(j), 1,
                			x_atp_rec.receiving_cal_code(j), 1
                			));--4460369 + MSC_ATP_PVT.G_END_OF_DAY;
                --bug3439591 start
                IF((x_atp_rec.requested_ship_date(j) IS NOT NULL) AND
                  (trunc(x_atp_rec.ship_date(j))
                  > trunc(x_atp_rec.latest_acceptable_date(j)))
                  OR
                  ((x_atp_rec.requested_arrival_date(j)IS NOT NULL) AND
                  (trunc(x_atp_rec.arrival_date(j))
                  > trunc(x_atp_rec.latest_acceptable_date(j))))) THEN

                  x_atp_rec.error_code(j) := MSC_ATP_PVT.ATP_ACCEPT_FAIL;
                  x_atp_rec.requested_date_quantity(j) := 0;
                ELSE
                  x_atp_rec.requested_date_quantity(j) := x_atp_rec.quantity_ordered(j);
                END IF;

		IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_sysdate_osc : ' || l_sysdate_osc);
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_sysdate_orc : ' || l_sysdate_orc);
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'x_atp_rec.latest_acceptable_date(j) : ' || x_atp_rec.latest_acceptable_date(j));
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'x_atp_rec.delivery_lead_time(j) : ' || x_atp_rec.delivery_lead_time(j));
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'x_atp_rec.ship_date(j) : ' || x_atp_rec.ship_date(j));
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'x_atp_rec.arrival_date(j) : ' || x_atp_rec.arrival_date(j));
                     msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'error_code(j) : ' || x_atp_rec.error_code(j));
                END IF;
	        --bug3439591 end
            END IF; -- override bug 2649670

        END IF; -- IF (x_atp_rec.quantity_ordered(j) = 0) THEN
        /* Bug 3335268 - changes end */


            -- End Changes Bug 2232555, 2250456
            -- Bug 2406242, 2463608
            /* Bug 3345563 - At this point arrival date has already been calculated.
               Done with Enforce Pur LT changes
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Arrival Date is always calculated ');
            END IF;
            IF x_atp_rec.requested_arrival_date(j) is not null THEN
                x_atp_rec.arrival_date(j) := GREATEST(x_atp_rec.arrival_date(j),
                                                 x_atp_rec.requested_arrival_date(j));
            END IF;
            */
            -- End Bug 2406242, 2463608

            IF (x_atp_rec.ship_set_name(j) IS NOT NULL OR
                x_atp_rec.arrival_set_name(j) IS NOT NULL) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Within Ship Set '||x_atp_rec.ship_set_name(j));
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'OR Arrival Set  '||x_atp_rec.arrival_set_name(j));
                END IF;

                x_atp_rec.error_code(j) :=MSC_ATP_PVT.ATP_NOT_APPL;
                --bug 3365376: Pass earliest acceptable date as this date is used to calculate LAD for the line
                x_atp_rec.earliest_acceptable_date(j) := l_sysdate_osc; --bug3439591
                MSC_ATP_PROC.Process_Set_Line(x_atp_rec, j, l_line_status);
                MSC_ATP_PVT.process_time_stamp_errors(x_atp_rec, j);--4460369/4500382
            ELSE -- If in shipset or arrival set
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: Not a Set');
                    msc_sch_wb.atp_debug('x_atp_rec.ship_date: '    || x_atp_rec.ship_date(j));
                    msc_sch_wb.atp_debug('x_atp_rec.arrival_date: ' || x_atp_rec.arrival_date(j));
                END IF;

                MSC_ATP_PVT.process_time_stamp_errors(x_atp_rec, j); --4967040:
            END IF;

            -- Bug 2413888, 2281628
            -- 3000016 set l_end when we reach the end of a set, not the beginning of the next set
            IF j = l_atp_rec.action.count OR
                (NVL(l_atp_rec.Ship_Set_Name(l_start),-99) <>
                NVL(l_atp_rec.Ship_Set_Name(j+1),-100) AND
                NVL(l_atp_rec.Arrival_Set_Name(l_start),-99) <>
                NVL(l_atp_rec.Arrival_Set_Name(j+1),-100))
            THEN
                l_end := j;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'setting l_end = '||l_end);
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Ship_set_name '||x_atp_rec.ship_set_name(j));
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Ship_set_name '||x_atp_rec.ship_set_name(l_start));
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || l_atp_rec.action.count);
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Arrival_set   '||x_atp_rec.Arrival_set_name(j));
                END IF;
            END IF;
            -- Bug 2413888, 2281628

            -- Bug 2413888, 2281628
            -- For ship_set or arrival_set cases the group date was not getting
            -- handled correctly before. Below is the fix.

            -- 3000016
            IF l_end IS NOT NULL THEN
                IF (x_atp_rec.ship_set_name(j) is not null or
                    x_atp_rec.arrival_set_name(j) is not null) and
                    (l_end - l_start > 0)
                THEN
                    MSC_ATP_PROC.Process_Set_Dates_Errors(x_atp_rec, 'S', l_set_status, l_start, l_end);
                END IF;
                l_start := l_end + 1 ;
                l_end := NULL;
                IF l_start <= l_atp_rec.action.count THEN
                    MSC_ATP_PROC.Initialize_Set_Processing(l_atp_rec, l_start);
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_start: '||l_start);
                END IF;
            END IF;
            -- End of changes for Bug 2413888, 2281628

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'ship_date(j) after : ' || to_char(x_atp_rec.ship_date(j), 'dd/mm/yyyy hh:mi:ss'));
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'x_atp_rec.arrival_date(j) after : ' || to_char(x_atp_rec.arrival_date(j), 'dd/mm/yyyy hh:mi:ss'));
            END IF;

        END IF; 	-- IF NVL(g_atp_check, '@') = 'N' THEN
        j := l_atp_rec.inventory_item_id.NEXT(j);
    EXCEPTION --bug3583705 start
       WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || ' NO_MATCHING_DATE_IN_CAL');
              msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_start: '||l_start);
              msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'j: '||j);
           END IF;
           l_end := l_start;

           WHILE l_end is not null and
                      (nvl(l_atp_rec.ship_set_name(l_end), -99) = nvl(l_atp_rec.ship_set_name(l_start), -99) and
                      nvl(l_atp_rec.arrival_set_name(l_end), -99) = nvl(l_atp_rec.arrival_set_name(l_start), -99))
           LOOP
                    IF l_end > j THEN
                       mrp_atp_pvt.assign_atp_input_rec(l_atp_rec,l_end,x_atp_rec,x_return_status);
                    END IF;

                    IF (x_atp_rec.error_code(l_end) IS NULL) or (x_atp_rec.error_code(l_end) IN (0,61,150)) THEN
                       x_atp_rec.error_code(l_end) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
                    END IF;

                    l_end := l_atp_rec.inventory_item_id.next(l_end);
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_end: '||l_end);
                    END IF;
           END LOOP;

           j := l_end;
           l_start := l_end;
           l_end := NULL;

           IF l_start <= l_atp_rec.action.count THEN
              MSC_ATP_PROC.Initialize_Set_Processing(l_atp_rec, l_start);
           END IF;
           IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_start: '||l_start);
           END IF;

       WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || ' NO_MATCHING_DATE_IN_CAL');
              msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_start: '||l_start);
              msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'j: '||j);
           END IF;
           /* Check if this is actually coming from a calendar routine*/
           l_encoded_text := fnd_message.GET_ENCODED;
           IF l_encoded_text IS NULL THEN
                l_msg_app := NULL;
                l_msg_name := NULL;
           ELSE
                fnd_message.parse_encoded(l_encoded_text, l_msg_app, l_msg_name);
           END IF;
           l_end := l_start;

           WHILE l_end is not null and
                      (nvl(l_atp_rec.ship_set_name(l_end), -99) = nvl(l_atp_rec.ship_set_name(l_start), -99) and
                      nvl(l_atp_rec.arrival_set_name(l_end), -99) = nvl(l_atp_rec.arrival_set_name(l_start), -99))
           LOOP

                    IF l_end > j THEN
                      mrp_atp_pvt.assign_atp_input_rec(l_atp_rec,l_end,x_atp_rec,x_return_status);
                    END IF;

                    IF (x_atp_rec.error_code(l_end) IS NULL) or (x_atp_rec.error_code(l_end) IN (0,61,150)) THEN
                      IF l_msg_app='MRP' AND l_msg_name='GEN-DATE OUT OF BOUNDS' THEN
                        x_atp_rec.error_code(l_end) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Call_ATP_No_Commit: NO_MATCHING_CAL_DATE');
                        END IF;
                      ELSE
                        x_atp_rec.error_code(l_end) := MSC_ATP_PVT.ATP_PROCESSING_ERROR; -- ATP Processing Error
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Call_ATP_No_Commit: ATP_PROCESSING_ERROR');
                        END IF;
                      END IF;
                    END IF;
                    l_end := l_atp_rec.inventory_item_id.next(l_end);
           END LOOP;

           j := l_end;
           l_start := l_end;
           l_end := NULL;

           IF l_start <= l_atp_rec.action.count THEN
              MSC_ATP_PROC.Initialize_Set_Processing(l_atp_rec, l_start);
           END IF;
           IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_start: '||l_start);
           END IF;

    END; --bug3583705 end

    END LOOP; 	-- FOR j in 1..l_atp_rec.inventory_item_id.LAST LOOP

    IF NVL(g_atp_check, '@') = 'N' THEN

        -- Delete records from MSC_REGIONS_TEMP before returning back to calling
        -- application so as to clean up the table for another request within
        -- same session for Region Level Sourcing Support

        DELETE msc_regions_temp
        WHERE session_id = p_session_id;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Rows deleted from msc_regions_temp : '||sql%rowcount);
        END IF;

        --bug3940999 Delete temp records before exiting
        DELETE msc_atp_src_profile_temp
        WHERE session_id = p_session_id;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Rows deleted from msc_atp_src_profile_temp : '||sql%rowcount);
        END IF;

        -- No ATP needed as No ATPable item or CTO model in the ATP request from source.

        -- Bug 2280196 Base Bug 2262291 Added by : krajan
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Put into temp table for MSCBALWB');
        END IF;
        MSC_ATP_UTILS.put_into_temp_table(
                        NULL,
                        p_session_id,
                        x_atp_rec,
                        x_atp_supply_demand,
                        x_atp_period,
                        x_atp_details,
                        MSC_ATP_UTILS.RESULTS_MODE,
                        x_return_status,
                        x_msg_data,
                        x_msg_count);
                        -- End of change - Bug 2280196

        ---since we update instead of insert, we need to get the updated data as well.
        --but we do it only for PDS case where model is present in the request
        IF MSC_ATP_CTO.G_MODEL_IS_PRESENT = 1 THEN
            MSC_ATP_UTILS.Get_From_Temp_Table(
                            null,
                            p_session_id,
                            x_atp_rec,
                            x_atp_supply_demand,
                            x_atp_period,
                            x_atp_details,
                            MSC_ATP_UTILS.RESULTS_MODE,
                            x_return_status,
                            x_msg_data,
                            x_msg_count,
                            l_details_flag);

        END IF;

        -- krajan : 2748041
        -- If it is an ATO delete case,then call the POST ATP CTO procedure
        if (NVL(G_CTO_FLAG, -1) = 2 ) then
            IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'ATO Delete Flag Case - setting G_CTO_FLAG to 3');
            END IF;
            G_CTO_FLAG := 3;
        end if;

        --4421391
        IF G_CALL_ATP = 2 THEN
    	-- Set Sql Trace.
    	IF order_sch_wb.mr_debug in ('T','C') THEN
         disable_trace(L_RETURN_NUM);
         IF L_RETURN_NUM =-1 THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         END IF;
        END IF;
	END IF;

        RETURN;
    END IF;

    /* SELECT mrp_ap_refresh_s.nextval
    INTO l_refresh_number
    FROM dual;

    --s_cto_rearch: 24x7
    MSC_ATP_PVT.G_REFRESH_NUMBER := l_refresh_number;
    --e_cto_rearch: 24x7
    */

    /* bug 3623018: Check if instance id is found or not. If not then raise an error */
    IF l_instance_id IS NULL and NVL(p_atp_rec.Calling_Module(i), -99) <> 724 THEN
        x_atp_rec := l_atp_rec;
        FOR i in 1..x_atp_rec.Calling_Module.LAST LOOP
                x_atp_rec.Error_Code(i) := NO_APS_INSTANCE;
        END LOOP;

        RAISE FND_API.G_EXC_ERROR ;
    END IF;

    IF l_a2m_dblink IS NULL THEN   --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink



    -- ngoel 10/15/2001, modified to call MSC_NATP_PVT.Call_Schedule_New instead of
    -- MSC_ATP_PVT.Call_Schedule as part of changes to split ATP source and destination patches.

        MSC_NATP_PVT.Call_Schedule_New(
                    p_session_id,
                    l_atp_rec,
                    l_instance_id,
                    l_assign_set_id,
                    l_refresh_number,
                    --x_atp_rec,
                    l_atp_rec_temp,
                    x_return_status,
                    x_msg_data,
                    x_msg_count,
                    x_atp_supply_demand,
                    x_atp_period,
                    x_atp_details);
    ---custom_api chnages: Call customer API for calculating arrival datea
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Before calling Custom_Post_ATP_API');
    END IF;
    MSC_ATP_CUSTOM.Custom_Post_ATP_API(l_atp_rec_temp,
                                       l_custom_atp_rec,
                                       l_modify_flag,
                                       l_custom_ret_sts);
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('After calling Custom_Post_ATP_API');
       msc_sch_wb.atp_debug('l_custom_ret_sts := ' || l_custom_ret_sts);
    END IF;

    IF l_modify_flag = 1 and l_custom_atp_rec.inventory_item_id.count > 0
                         and l_custom_ret_sts = FND_API.G_RET_STS_SUCCESS THEN

         msc_sch_wb.atp_debug('Assign Custom rec to ATP output rec');
         l_atp_rec_temp := l_custom_atp_rec;

    END IF;

        MSC_ATP_UTILS.put_into_temp_table(
                    l_a2m_dblink,           --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
                    --l_db_profile,
                    p_session_id,
                    --x_atp_rec,
                    l_atp_rec_temp,
                    x_atp_supply_demand,
                    x_atp_period,
                    x_atp_details,
                    MSC_ATP_UTILS.RESULTS_MODE,
                    x_return_status,
                    x_msg_data,
                    x_msg_count);

        ---since we update instead of insert, we need to get the updated data as well.
        --but we do it only for PDS case where model is present in the request
        IF MSC_ATP_CTO.G_MODEL_IS_PRESENT = 1 THEN
            MSC_ATP_UTILS.Get_From_Temp_Table(
                    null,
                    p_session_id,
                    --x_atp_rec,
                    l_atp_rec_temp,
                    x_atp_supply_demand,
                    x_atp_period,
                    x_atp_details,
                    MSC_ATP_UTILS.RESULTS_MODE,
                    x_return_status,
                    x_msg_data,
                    x_msg_count,
                    l_details_flag);

        END IF;

        IF p_atp_rec.attribute_04.count > 0 AND
            NVL(p_atp_rec.attribute_04(1),0) = 1
        THEN
            MSC_ATP_UTILS.Retrieve_Period_And_SD_Data(p_session_id,
                                                    x_atp_period,
                                                    x_atp_supply_demand);
        END IF;

    ELSE
      /* s_cto_rearch- ATP is called from the source.
      MSC_ATP_UTILS.put_into_temp_table(
                  NULL,
                  p_session_id,
                  l_atp_rec,
                  x_atp_supply_demand,
                  x_atp_period,
                  x_atp_details,
		  MSC_ATP_UTILS.REQUEST_MODE,
                  x_return_status,
                  x_msg_data,
                  x_msg_count);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'instance_id = '||l_instance_id);
         msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'before remote procedure call');
      END IF;
      e_cto_reach */

        --bug3520746
      BEGIN
        SELECT count(*)
        into l_rac_count
        from gv$instance;
        IF l_rac_count > 1 then
           l_node_id := userenv('INSTANCE');
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('RAC Instance id is:' || l_node_id);
           END IF;
        ELSE
           l_node_id := null;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
           l_node_id := null;
      END;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('node id is:' || l_node_id);
      END IF;

     --bug3520746 pass the node to the remote call in case of RAC
        /* added inv_ctp, default assignment set in procedure call for bug 2368426 starts */
        --bug3049003 changed from G_DB_PROFILE to l_a2m_dblink
        --Bug3593394 - Pass ship rec profile from source
        --bug3940999 removed profile parameters which are passed thru  table
        plsql_block := 'BEGIN MSC_ATP_PVT.CALL_SCHEDULE_REMOTE'
                        ||'@'||l_a2m_dblink||'(
                        :session_id,
                        :instance_id,
                        :assign_set_id,
                        :refresh_number,
                        :def_assign_set_id,
                        :atp_debug_flag,
                        :session_loc_des,
                        :spid_des,
                        :trace_loc_des,
                        :node_id
                        ); END;';

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'plsql_block' || plsql_block);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'p_session_id ' || p_session_id);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_instance_id ' || l_instance_id);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_assign_set_id ' || l_assign_set_id);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_refresh_number ' || l_refresh_number);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_def_assign_set_id ' || l_def_assign_set_id);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'MSC_ATP_DEBUG ' || FND_PROFILE.value('MSC_ATP_DEBUG'));
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'l_node_id ' || l_node_id);
        END IF;

        EXECUTE IMMEDIATE plsql_block USING
                        p_session_id,
                        l_instance_id,
                        l_assign_set_id,
                        l_refresh_number,
                        l_def_assign_set_id,
                        FND_PROFILE.value('MSC_ATP_DEBUG'),
                        OUT l_session_loc_des, --ATP Debug Workflow --added OUT, 4727103
                        OUT l_spid_des, --ATP Debug Workflow
                        OUT l_trace_loc_des, --ATP Debug Workflow
                        l_node_id; --Bug3593394
     --bug3520746 End changes.
        /* added inv_ctp, default assignment set in procedure call for bug 2368426 ends */

        IF p_atp_rec.attribute_04.count > 0 AND
            NVL(p_atp_rec.attribute_04(1),0) = 1
        THEN
            l_details_flag := 1;
        ELSE
            l_details_flag := 2;
        END IF;

        MSC_ATP_UTILS.Get_From_Temp_Table(
                        null,
                        p_session_id,
                        --x_atp_rec,
                        l_atp_rec_temp,
                        x_atp_supply_demand,
                        x_atp_period,
                        x_atp_details,
                        MSC_ATP_UTILS.RESULTS_MODE,
                        x_return_status,
                        x_msg_data,
                        x_msg_count,
                        l_details_flag);

      ---custom_api changes: Call customer API for calculating arrival datea
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Before calling Custom_Post_ATP_API');
      END IF;
      MSC_ATP_CUSTOM.Custom_Post_ATP_API(l_atp_rec_temp,
                                         l_custom_atp_rec,
                                         l_modify_flag,
                                         l_custom_ret_sts);

      IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('after calling Custom_Post_ATP_API');
           msc_sch_wb.atp_debug('l_custom_ret_sts := ' || l_custom_ret_sts);
           msc_sch_wb.atp_debug('l_modify_flag := ' || l_modify_flag);
      END IF;

      IF l_modify_flag = 1 and l_custom_atp_rec.inventory_item_id.count > 0
                         and l_custom_ret_sts = FND_API.G_RET_STS_SUCCESS THEN

         l_atp_rec_temp := l_custom_atp_rec;
         ---update information in mrp_atp_schedule_temp
         MSC_ATP_PUB.Update_Custom_Information(l_atp_rec_temp,
                                               p_session_id);
      END IF;

      -- end custom_api changes

        -- Debug message added for bug 2368426
        IF l_atp_rec_temp.error_code(1) = 230 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'INV_CTP profile not in sync with destination');
            END IF;
        END IF;

    END IF;

    x_atp_rec := l_atp_rec_temp;

    -- 2688113 : krajan : Copy ato_delete_flag
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Extending ATO_Delete Flag');
    END IF;
    x_atp_rec.ato_delete_flag := p_atp_rec.ato_delete_flag;

    IF G_INV_CTP = 4 THEN
        --call substitution workflow
        IF x_atp_rec.action(1) <> 100 and x_atp_rec.calling_module(i) = 660 THEN
            l_wf_profile := NVL(fnd_profile.value('MSC_ALLOCATED_ATP_WORKFLOW'), 'N');
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'WF Profile:' || l_wf_profile);
            END IF;
            IF l_wf_profile = 'Y' THEN
                Subst_workflow(x_atp_rec);
            END IF;
        END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'x_return_status : '||x_return_status);
    END IF;

    -- Added by ngoel 10/18/2000. This procedure  is called if there
    -- was a CTO model included in the request and either BOM was supplied
    -- by CTO previously or this is a rescheduling request. This procedure will
    -- store the demands for CTO model and its components and reconstruct
    -- the reduced ship set into original ship set. This procedure
    -- is needed to support multi-level, multi-org CTO models from
    -- OM and Configurator.

    i := x_atp_rec.Action.FIRST;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'before x_atp_rec.Action: '||x_atp_rec.Action(i));
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'before l_atp_rec_temp.Error_Code: '||i||':'||
                            l_atp_rec_temp.Error_Code(i));
    END IF;


  -- krajan : 2927155
    -- For summary enhancement - refresh number bumping up begins
    --Collection Enhancement changes start
      IF ((G_INV_CTP = 4) AND ( NVL (p_atp_rec.action(p_atp_rec.calling_module.FIRST), -99) in (110,120) ))THEN
        -- need to do this only for PDS cases
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: --Now processing refresh numbers--');
        msc_sch_wb.atp_debug('Call_ATP_No_Commit: First check if this is required because of summary');
    END IF;
    -- check if summary is enabled
    -- Bug 3762695: Use source side profile value for 'MSC: Enable ATP Summary mode'
    l_summary_flag := 'N';
    IF NVL( FND_PROFILE.VALUE('MSC_ENABLE_ATP_SUMMARY'), 'N') = 'Y' THEN
      BEGIN
         select summary_flag
         into   l_summary_flag
         from   mrp_atp_details_temp
         where  session_id = p_session_id
         and    summary_flag = 'Y'
         and    record_type = 3 --record_type check added for performance
         and    rownum = 1;
      EXCEPTION
         When Others then
          l_summary_flag := 'N';
         IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Inside exception');
         END IF;
      END;
     END IF;


      SELECT DECODE( NVL(l_summary_flag, 'N'), 'Y', mrp_ap_refresh_s.nextval, (NVL(lrn, -1) +1))
      INTO l_end_refresh_number
      FROM mrp_ap_apps_instances;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('l_end_refresh_number ' || l_end_refresh_number);
         msc_sch_wb.atp_debug('l_summary_flag ' || l_summary_flag );
      END IF;

       IF (l_a2m_dblink IS NOT NULL) THEN
        plsql_block := 'BEGIN MSC_ATP_PUB.UPDATE_TABLES'
                        ||'@'||l_a2m_dblink||'(
                        :p_summary_flag,
                        :p_end_refresh_number,
                        :p_refresh_number,
                        :p_session_id);
                        END;';
        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'plsql_block ' || plsql_block);
        END IF;
        EXECUTE IMMEDIATE plsql_block USING
                        l_summary_flag,
                        l_end_refresh_number,
                        l_refresh_number,
                        p_session_id;
       ELSE
        UPDATE_TABLES(l_summary_flag,l_end_refresh_number,l_refresh_number,p_session_id);

       END IF;
     END IF;

     --ATP Debug Workflow, atp debug changes.

    IF PG_DEBUG in ('Y', 'C') THEN
           MSC_WF_ALLOC_ATP.DEBUG_WF ( p_session_id,
                                       l_login_user,
                                       l_session_loc_des,
                                       l_trace_loc_des,
                                       l_spid_des );
    END IF;

     --Collection Enhancement changes end
     --aksaxena 1/23/2004
     --Code commented out as a part of Collection Enhancement changes
     --For collection enhancement one new private procedure is made
     --Update_table which will be called across dblink instead of
     --making multiple update statements across dblink.

    --bug3520746 Delete temp records before exiting
    delete from msc_regions_temp where session_id = p_session_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Rows deleted from msc_regions_temp:'|| sql%rowcount);
    END IF;

    --bug3940999 Delete temp records before exiting
    delete from msc_atp_src_profile_temp where session_id = p_session_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Rows deleted from msc_atp_src_profile_temp:'|| sql%rowcount);
       msc_sch_wb.atp_debug('End Call_ATP_No_Commit');
    END IF;

    IF G_CALL_ATP = 2 THEN    --4421391
     IF order_sch_wb.mr_debug in ('T','C') THEN
        disable_trace(L_RETURN_NUM);
        IF L_RETURN_NUM =-1 THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;
     END IF;
    END IF;

EXCEPTION
    WHEN MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Error in Call_ATP_No_Commit :'||sqlcode);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Invalid Objects found');
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || sqlerrm);
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'shipset count ' ||p_atp_rec.error_code.count);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Exception x_return_status : '||x_return_status);
        END IF;

        --ATP Debug Workflow, atp debug changes.

        IF PG_DEBUG in ('Y', 'C') THEN
           MSC_WF_ALLOC_ATP.DEBUG_WF ( p_session_id,
                                       l_login_user,
                                       l_session_loc_des,
                                       l_trace_loc_des,
                                       l_spid_des );
        END IF;

        BEGIN
            ROLLBACK TO SAVEPOINT start_of_call_atp_no_commit;
        EXCEPTION
            WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || sqlerrm);
                END IF;
                IF (sqlcode = -1086) THEN
                    null;
                END IF;
        END;
        IF (x_atp_rec.Inventory_item_id.COUNT = 0) THEN
            IF (l_atp_rec.Inventory_item_id.COUNT = 0) THEN
                x_atp_rec:= p_atp_rec;
            ELSE
                x_atp_rec:= l_atp_rec;
            END IF;
        END IF;
        FOR i IN 1..x_atp_rec.Action.COUNT LOOP
            IF NVL (x_atp_rec.error_code(i),-1) in (-1,0,61,150) THEN
                x_atp_rec.Error_Code(i) := MSC_ATP_PVT.ATP_INVALID_OBJECTS;
            END IF;
        END LOOP;

        --bug3520746 Delete temp records before exiting
        delete from msc_regions_temp where session_id = p_session_id;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Rows deleted from msc_regions_temp:'|| sql%rowcount);
        END IF;

        --bug3940999 Delete temp records before exiting
        delete from msc_atp_src_profile_temp where session_id = p_session_id;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Rows deleted from msc_atp_src_profile_temp:'|| sql%rowcount);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Call_ATP_No_Commit');
        END IF;

        --- now we put the record back into temp table.
        --- ATP inquiry gets data from mrp_atp_schedule_temp table.
        --- If something goes wrong in ATP inquiry then we never get to the point to
        --- put the data back in the above table
        --AS a result we dont get a clue from ATP inquiry form as to what went wrong
        MSC_ATP_UTILS.put_into_temp_table(
                        NULL, -- G_DB_PROFILE, dsting insert into source not dest
                        p_session_id,
                        x_atp_rec,
                        x_atp_supply_demand,
                        x_atp_period,
                        x_atp_details,
                        MSC_ATP_UTILS.REQUEST_MODE,
                        x_return_status,
                        x_msg_data,
                        x_msg_count);

        IF G_CALL_ATP = 2 THEN     --4421391
    	-- Set Sql Trace.
    	 IF order_sch_wb.mr_debug in ('T','C') THEN
          disable_trace(L_RETURN_NUM);
     	  IF L_RETURN_NUM =-1 THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;
         END IF;
	END IF;


    WHEN others THEN
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Error in Call_ATP_No_Commit :'||sqlcode);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || sqlerrm);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'shipset count ' ||p_atp_rec.error_code.count);
            msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || 'Exception x_return_status : '||x_return_status);
        END IF;

        --bug3520746 Delete temp records before exiting
       delete from msc_regions_temp where session_id = p_session_id;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Rows deleted from msc_regions_temp:'|| sql%rowcount);
       END IF;

       --bug3940999 Delete temp records before exiting
       delete from msc_atp_src_profile_temp where session_id = p_session_id;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Rows deleted from msc_atp_src_profile_temp:'|| sql%rowcount);
       END IF;

       --ATP Debug Workflow, atp debug changes.

       IF PG_DEBUG in ('Y', 'C') THEN
           MSC_WF_ALLOC_ATP.DEBUG_WF ( p_session_id,
                                       l_login_user,
                                       l_session_loc_des,
                                       l_trace_loc_des,
                                       l_spid_des );
        END IF;

        BEGIN
            ROLLBACK TO SAVEPOINT start_of_call_atp_no_commit;
        EXCEPTION
            WHEN OTHERS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Call_ATP_No_Commit: ' || sqlerrm);
                END IF;
                IF (sqlcode = -1086) THEN
                    null;
                END IF;
        END;

        -- Error Handling Changes : krajan
        IF (x_atp_rec.Inventory_item_id.COUNT = 0) THEN
            IF (l_atp_rec.Inventory_item_id.COUNT = 0) THEN
                x_atp_rec:= p_atp_rec;
            ELSE
                x_atp_rec:= l_atp_rec;
            END IF;
        END IF;
        FOR i IN 1..x_atp_rec.Action.COUNT LOOP
            IF NVL (x_atp_rec.error_code(i),-1) in (-1,0,61,150) THEN
                   x_atp_rec.Error_Code(i) := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
            END IF;
        END LOOP;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Call_ATP_No_Commit');
        END IF;
        -- End Error Handling Changes

        --- now we put the record back into temp table.
        --- ATP inquiry gets data from mrp_atp_schedule_temp table.
        --- If something goes wrong in ATP inquiry then we never get to the point to
        --- put the data back in the above table
        --AS a result we dont get a clue from ATP inquiry form as to what went wrong
        MSC_ATP_UTILS.put_into_temp_table(
                                NULL, -- G_DB_PROFILE, dsting insert into src not dest
                                p_session_id,
                                x_atp_rec,
                                x_atp_supply_demand,
                                x_atp_period,
                                x_atp_details,
                                MSC_ATP_UTILS.REQUEST_MODE,
                                x_return_status,
                                x_msg_data,
                                x_msg_count);

        IF G_CALL_ATP = 2 THEN     --4421391
    	-- Set Sql Trace.
    	 IF order_sch_wb.mr_debug in ('T','C') THEN
          disable_trace(L_RETURN_NUM);
          IF L_RETURN_NUM =-1 THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;
    	 END IF;
	END IF;


END Call_ATP_No_Commit;
/*******************************************************************************|
         New procedure as a part of Collection Enhancement changes
|*******************************************************************************/
PROCEDURE UPDATE_TABLES (p_summary_flag IN  VARCHAR2,
                         p_end_refresh_number IN NUMBER ,
                         p_refresh_number IN NUMBER ,
                         p_session_id IN NUMBER)

   IS

   l_end_refresh_number            NUMBER := NULL;
   l_identifier1                   MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
   l_identifier2                   MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();
   l_identifier3                   MRP_ATP_PUB.number_arr  := MRP_ATP_PUB.number_arr();

   BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Inside Procedure UPDATE_TABLES');
         msc_sch_wb.atp_debug('UPDATE_TABLES : p_end_refresh_number ' || p_end_refresh_number);
         msc_sch_wb.atp_debug('UPDATE_TABLES : p_refresh_number ' || p_refresh_number);
         msc_sch_wb.atp_debug('UPDATE_TABLES : p_summary_flag ' || p_summary_flag);
         msc_sch_wb.atp_debug('UPDATE_TABLES : p_session_id ' || p_session_id);

    END IF;
      IF p_summary_flag = 'Y' THEN
      -- Summary is enabled in destination and at least one line did not result in PDS-ODS switch
      -- Now need to check if net summary is running or if latest_refresh_number has increased
      -- Currently doing this using the brute force method of going by msc_demands. Need to investigate
      -- possibility of using ATP pegging - potential issue there may be unschedules

      select  max(decode(p.summary_flag,
                         MSC_POST_PRO.G_SF_NET_SUMMARY_RUNNING, p_refresh_number+1,
                         p.latest_refresh_number))
      into    l_end_refresh_number
      from    msc_plans p,
              msc_demands d,
              mrp_atp_details_temp madt
      where   d.plan_id = p.plan_id
      and     d.refresh_number = p_refresh_number
      and     d.plan_id = madt.identifier2
      and     d.demand_id = madt.identifier3
      and     d.sr_instance_id = madt.identifier1
      and     madt.session_id = p_session_id
      -- and     madt.supply_demand_type = 1
      -- Bug 3629191
      -- Supply_demand_type check is removed as it will filter out record in Unscheduling case.
      -- It will not fetch unwanted records (supply etc) as there is a filter on refresh number.
      -- Sql performance will be same after removing the check
      and     madt.record_type = 3
      and     NVL(madt.identifier2, -1) > 0
      and     madt.identifier3 is not NULL
      and     madt.identifier1 is not NULL;

      IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('No of rows selected ' || SQL%ROWCOUNT );
      END IF;

      IF l_end_refresh_number > p_refresh_number  THEN
        -- need to bump up all records
       IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Update 5 tables');
       END IF;

       -- Bug 3517529: anbansal
       -- Used identifier1, identifier2 and identifier3 from pegging records to have additional check on
       -- sr_instance_id, plan_id and demand_id while updating tables ( msc_demands, msc_supplies,
       -- msc_resource_requirements, msc_alloc_demands, msc-alloc_supplies) in demand priority case
       -- to improve the performance.

       SELECT identifier2,
              identifier3,
              identifier1
       BULK COLLECT INTO
              l_identifier2,
              l_identifier3,
              l_identifier1
       FROM MRP_ATP_DETAILS_TEMP
       where session_id = p_session_id
             and  record_type = 3
             and  NVL(identifier2, -1) > 0
             and  identifier3 is not NULL
             and  identifier1 is not NULL;

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows selected by BULK SELECT ' || SQL%ROWCOUNT );
       END IF;

       FORALL i in 1..l_identifier1.COUNT
       update  msc_demands
       set     refresh_number = p_end_refresh_number
       where   refresh_number = p_refresh_number
       and plan_id = l_identifier2(i)
       and demand_id = l_identifier3(i)
       and sr_instance_id = l_identifier1(i);

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows updated:msc_demands ' || SQL%ROWCOUNT );
       END IF;

       FORALL i in 1..l_identifier1.COUNT
       update  msc_supplies
       set     refresh_number = p_end_refresh_number
       where   refresh_number = p_refresh_number
       and plan_id = l_identifier2(i)
       and transaction_id = l_identifier3(i)
       and sr_instance_id = l_identifier1(i);

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows updated: msc_supplies ' || SQL%ROWCOUNT );
       END IF;

       FORALL i in 1..l_identifier1.COUNT
       update  msc_resource_requirements
       set     refresh_number = p_end_refresh_number
       where   refresh_number = p_refresh_number
       and plan_id = l_identifier2(i)
       and transaction_id = l_identifier3(i)
       and sr_instance_id = l_identifier1(i);

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows updated: msc_resource_requirements ' || SQL%ROWCOUNT );
       END IF;

       FORALL i in 1..l_identifier1.COUNT
       update  msc_alloc_demands
       set     refresh_number = p_end_refresh_number
       where   refresh_number = p_refresh_number
       and plan_id = l_identifier2(i)
       and parent_demand_id = l_identifier3(i)
       and sr_instance_id = l_identifier1(i);

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows updated: msc_alloc_demands ' || SQL%ROWCOUNT );
       END IF;

       FORALL i in 1..l_identifier1.COUNT
       update  msc_alloc_supplies
       set     refresh_number = p_end_refresh_number
       where   refresh_number = p_refresh_number
       and plan_id = l_identifier2(i)
       and parent_transaction_id = l_identifier3(i)
       and sr_instance_id = l_identifier1(i);

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows updated: msc_alloc_supplies ' || SQL%ROWCOUNT );
       END IF;

      ELSE
       l_end_refresh_number := null;
      END IF;

     END IF;

     IF (l_end_refresh_number is null) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Need to bump refresh number up for 24X7');
      END IF;

       -- Changed for the testing of Bug 3517529, But missed to remove it
       -- Changing back to the correct condition.
       -- IF p_refresh_number < (p_refresh_number + 1) THEN
       IF p_refresh_number < p_end_refresh_number THEN
       IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Update 1 Table');
       END IF;

       update msc_demands
       set refresh_number = p_end_refresh_number
       --we need to update POD for model components
       where origination_type in (6,30,1)
       --refresh number will be populated either for SO or POD ofmodel entities
       and  refresh_number is not null
       and (plan_id, demand_id, sr_instance_id) in
           ( select identifier2,
                     identifier3,
                     identifier1
             from mrp_atp_details_temp
             where session_id = p_session_id
             and  supply_demand_type = 1
             and  record_type = 3
             and  NVL(identifier2, -1) > 0
             and  identifier3 is not NULL
             and  identifier1 is not NULL
           );

       IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('No of rows updated: msc_demands ' || SQL%ROWCOUNT );
       END IF;
      END IF;
     END IF;
END UPDATE_TABLES;

END MSC_ATP_PUB;

/

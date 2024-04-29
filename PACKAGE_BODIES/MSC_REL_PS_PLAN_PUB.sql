--------------------------------------------------------
--  DDL for Package Body MSC_REL_PS_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_REL_PS_PLAN_PUB" AS
/* $Header: MSCPSRELB.pls 120.8.12010000.10 2010/04/13 23:41:02 harshsha ship $ */

--  Start of Comments
--  API name 	MSC_Release_Plan_SC
--  Type 	Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version 	Current version = 1.0
--  		Initial version = 1.0
--
--  Notes
--
--     OVERVIEW:
--     This procedure populates the WIP and purchasing interface tables with
--     rows for creating and rescheduling jobs, purchase orders, and repetitive
--     schedules
--
--     ARGUMENTS:
--     arg_plan_id:	   The plan identifier
--     arg_org_id:         The current organization id
--     arg_sr_instance     The source instance id of the org
--     arg_compile_desig:  The current plan name
--     arg_user_id:        The user
--     arg_po_group_by:    How to group attributes together for po mass load
--     arg_wip_group_id:   How to group records in wip
--     lv_launch_process: Which process to launch
--     lv_calendar_code:    Calendar code for current organization
--     lv_exception_set_id: Exception set id for current organization
--
--     RETURNS:            Nothing
--


   G_INS_DISCRETE               CONSTANT NUMBER := 1;
   G_INS_PROCESS                CONSTANT NUMBER := 2;
   G_INS_OTHER                  CONSTANT NUMBER := 3;
   G_INS_MIXED                  CONSTANT NUMBER := 4;
   G_INS_EXCHANGE               CONSTANT NUMBER := 5;

   v_curr_instance_type         NUMBER;
   v_user_id			NUMBER;

   JOB_CANCELLED          CONSTANT INTEGER := 7;

   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';

   LT_RESOURCE_INSTANCE CONSTANT NUMBER := 8;  -- dsr
   	-- SUBST_CHANGE CONSTANT NUMBER := 3; -- dsr
   LT_RESOURCE_INST_USAGE CONSTANT NUMBER := 9; -- dsr
   LT_CHARGE_TYPE CONSTANT NUMBER := 10; -- dsr



/*This prcodure is called from PS integration java code, in Publish, Release Stage */

PROCEDURE   MSC_PS_RELEASE( p_plan_id IN NUMBER, p_organization_id IN NUMBER, p_instance_id IN NUMBER,
                            p_plan_name IN VARCHAR2, p_user_id IN VARCHAR2, p_loaded_jobs IN OUT NOCOPY NUMBER,
                            p_resched_jobs IN OUT NOCOPY NUMBER, p_req_id IN OUT NOCOPY NUMBER ) IS

user_id VARCHAR2(100);



loaded_jobs		NumTblTyp := NumTblTyp(0);
loaded_reqs		NumTblTyp := NumTblTyp(0);
loaded_scheds		NumTblTyp := NumTblTyp(0);
resched_jobs		NumTblTyp := NumTblTyp(0);
resched_reqs		NumTblTyp := NumTblTyp(0);
wip_group_id    	NUMBER;
wip_req_id      	NumTblTyp := NumTblTyp(0);
po_req_load_id      	NumTblTyp := NumTblTyp(0);
po_req_resched_id 	NumTblTyp := NumTblTyp(0);
release_instance	NumTblTyp := NumTblTyp(0);
loaded_lot_jobs		NumTblTyp := NumTblTyp(0);
resched_lot_jobs	NumTblTyp := NumTblTyp(0);
osfm_req_id		NumTblTyp := NumTblTyp(0);
loaded_repair_orders NumTblTyp := NumTblTyp(0);-- bug 6038957
repair_orders_id NumTblTyp := NumTblTyp(0);-- bug 6038957


BEGIN



  MSC_REL_WF.INIT_DB(p_user_id);
  user_id:=FND_PROFILE.VALUE('USER_ID');
  /*dbms_output.put_line('USER_ID '|| p_user_id);*/



   MSC_RELEASE_PLAN_SC( p_plan_id,
		  p_organization_id,
                  p_instance_id,
		  p_organization_id,
		  p_instance_id,
                  p_plan_name,
                  user_id,
                  null,
                  null,
                  null,
                  loaded_jobs,
		  loaded_reqs,
 		  loaded_scheds,
		  resched_jobs,
		  resched_reqs,
                  wip_req_id,
                  po_req_load_id,
		  po_req_resched_id,
                  release_instance,
                  'PS',
                  null,
                  loaded_lot_jobs,
                  resched_lot_jobs,
                  osfm_req_id,
                  loaded_repair_orders,
                  repair_orders_id);

  FOR i in 1..loaded_jobs.COUNT LOOP
      p_loaded_jobs:=loaded_jobs(i) + loaded_lot_jobs(i);
      p_resched_jobs:=resched_jobs(i) + resched_lot_jobs(i);
      if( wip_req_id(i) > 0 ) then
        p_req_id:=wip_req_id(i);
      else
        p_req_id:=osfm_req_id(i);
      end if;
      /*dbms_output.put_line('Released planned orders number '|| p_loaded_jobs);
      dbms_output.put_line('request_id='||p_req_id);*/
  END LOOP;

END;



PROCEDURE MSC_RELEASE_PLAN_SC
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_log_sr_instance           IN      NUMBER
, arg_org_id 			IN 	NUMBER
, arg_sr_instance               IN      NUMBER
, arg_compile_desig 		IN 	VARCHAR2
, arg_user_id 			IN 	NUMBER
, arg_po_group_by 		IN 	NUMBER
, arg_po_batch_number 		IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_loaded_jobs 		IN OUT  NOCOPY NumTblTyp
, arg_loaded_reqs 		IN OUT  NOCOPY  NumTblTyp
, arg_loaded_scheds 		IN OUT  NOCOPY NumTblTyp
, arg_resched_jobs 		IN OUT  NOCOPY NumTblTyp
, arg_resched_reqs 		IN OUT  NOCOPY NumTblTyp
, arg_wip_req_id  		IN OUT  NOCOPY NumTblTyp
, arg_req_load_id 		IN OUT  NOCOPY  NumTblTyp
, arg_req_resched_id 		IN OUT  NOCOPY  NumTblTyp
, arg_released_instance         IN OUT  NOCOPY  NumTblTyp
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
, arg_loaded_lot_jobs           IN OUT  NOCOPY  NumTblTyp
, arg_resched_lot_jobs          IN OUT  NOCOPY  NumTblTyp
, arg_osfm_req_id               IN OUT  NOCOPY  NumTblTyp
, arg_loaded_int_repair_orders  IN OUT  NOCOPY  NumTblTyp -- Sasi
, arg_int_repair_orders_id      IN OUT  NOCOPY  NumTblTyp -- Sasi
) IS

CURSOR c_Instance IS
SELECT apps.instance_id,
       apps.instance_code,
       apps.apps_ver,
       apps.instance_type,
       DECODE(apps.m2a_dblink,NULL,' ', '@' || m2a_dblink),
       DECODE(apps.a2m_dblink,NULL,NULL_DBLINK,a2m_dblink),
       LENGTH( apps.instance_code)+2
FROM   msc_apps_instances apps,
       ( SELECT distinct
                sr_instance_id
           FROM msc_plan_organizations_v plan_org
          WHERE plan_org.plan_id = arg_plan_id
            AND plan_org.organization_id = arg_org_id
            AND plan_org.owning_sr_instance = arg_sr_instance
            AND plan_org.sr_instance_id =
                         decode(arg_log_sr_instance,
                                arg_sr_instance, plan_org.sr_instance_id,
                                arg_log_sr_instance)) ins
WHERE apps.instance_id = ins.sr_instance_id;

  l_sr_instance_id    NUMBER;
  l_instance_code     VARCHAR2(3);
  l_apps_ver          VARCHAR2(10);
  l_dblink            VARCHAR2(128);
  l_a2m_dblink        VARCHAR2(128);

  l_user_name         VARCHAR2(100):= NULL;
  l_resp_name         VARCHAR2(100):= NULL;
  l_application_name  VARCHAR2(240):= NULL;

  l_user_id           NUMBER;
  l_resp_id           NUMBER;
  l_application_id    NUMBER;

  l_sql_stmt          VARCHAR2(4000);

  l_loaded_jobs       NUMBER;
  l_loaded_reqs       NUMBER;
  l_loaded_scheds     NUMBER;
  l_resched_jobs      NUMBER;

  l_resched_reqs      NUMBER;
  l_wip_req_id        NUMBER;
  l_req_load_id       NUMBER;
  l_req_resched_id    NUMBER;

  lv_count            NUMBER:= 0;


  l_loaded_lot_jobs   NUMBER;
  l_resched_lot_jobs  NUMBER;
  l_osfm_req_id       NUMBER;

  lv_error_buf        VARCHAR2(2000);
  lv_ret_code         NUMBER;

  l_wip_group_id      NUMBER;
  l_po_batch_number   NUMBER;

  l_loaded_int_repair_orders number ;-- bug 6038957
  l_int_repair_orders_id number ;-- bug 6038957


BEGIN


   SELECT
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.USER_NAME,
       FND_GLOBAL.RESP_NAME,
       FND_GLOBAL.APPLICATION_NAME,
       FND_GLOBAL.RESP_APPL_ID
     INTO v_user_id,
          l_user_name,
           l_resp_name,
           l_application_name,
           l_application_id
     FROM  dual;

  -------- Release the planned order one instance by one instance.

  OPEN c_Instance;
  LOOP
    FETCH c_Instance
     INTO l_sr_instance_id,
          l_instance_code,
          l_apps_ver,
          v_curr_instance_type,
          l_dblink,
          l_a2m_dblink,
          v_instance_code_length;

    EXIT WHEN c_Instance%NOTFOUND;

    ---------- Initialize the remote process
    ---------- If the instance is discrete or mixed type
    ----------    AND the instance is at a remote database

   arg_loaded_jobs.extend(1);
   arg_loaded_reqs.extend(1);
   arg_loaded_scheds.extend(1);
   arg_resched_jobs.extend(1);
   arg_resched_reqs.extend(1);
   arg_wip_req_id.extend(1);
   arg_req_load_id.extend(1);
   arg_req_resched_id.extend(1);
   arg_released_instance.extend(1);
   arg_loaded_lot_jobs.extend(1);
   arg_resched_lot_jobs.extend(1);
   arg_osfm_req_id.extend(1);

   arg_loaded_int_repair_orders.extend(1); -- Sasi
   arg_int_repair_orders_id.extend(1); -- Sasi

   lv_count:= lv_count+1;

   arg_released_instance(lv_count):= l_sr_instance_id;

   -- initialize the Applications Environment --
   IF v_curr_instance_type IN ( G_INS_DISCRETE, G_INS_PROCESS, G_INS_MIXED) THEN

         l_sql_stmt:=
            'BEGIN'
          ||'  MRP_AP_REL_PLAN_PUB.INITIALIZE'||l_dblink
                              ||'( :l_user_name,'
                              ||'  :l_resp_name,'
                              ||'  :l_application_name,'
                              ||'  :l_sr_instance_id,'
                              ||'  :l_instance_code,'
                              ||'  :l_a2m_dblink,'
                              ||'  :l_wip_group_id,'
                              ||'  :l_po_batch_number,'
                              ||'  :l_application_id);'
          ||'END;';

         EXECUTE IMMEDIATE l_sql_stmt
                        USING IN l_user_name,
                              IN l_resp_name,
                              IN l_application_name,
                              IN l_sr_instance_id,
                              IN l_instance_code,
                              IN l_a2m_dblink,
                              OUT l_wip_group_id,
                              OUT l_po_batch_number,
                              IN l_application_id;

   END IF;

       l_loaded_jobs   := 0;
       l_loaded_reqs   := 0;
       l_loaded_scheds := 0;
       l_resched_jobs  := 0;
       l_loaded_lot_jobs := 0;
       l_resched_lot_jobs := 0;


    -- load the msc interface tables, submit the request --
       LOAD_MSC_INTERFACE
                (arg_dblink  => l_dblink,
                 arg_plan_id => arg_plan_id,
                 arg_log_org_id => arg_log_org_id,
                 arg_org_instance => l_sr_instance_id,
                 arg_owning_org_id => arg_org_id,
                 arg_owning_instance => arg_sr_instance,
                 arg_compile_desig => arg_compile_desig,
                 arg_user_id => arg_user_id,
                 arg_po_group_by => arg_po_group_by,
                 arg_po_batch_number => l_po_batch_number,
                 arg_wip_group_id => l_wip_group_id,
    ----------------------------------------------- Number of Loaded Orders
                 arg_loaded_jobs   => l_loaded_jobs,
                 arg_loaded_lot_jobs => l_loaded_lot_jobs,
                 arg_resched_lot_jobs => l_resched_lot_jobs,
                 arg_loaded_reqs   => l_loaded_reqs,
                 arg_loaded_scheds => l_loaded_scheds,
                 arg_resched_jobs  => l_resched_jobs,
    ----------------------------------------------- Request IDs
                 arg_resched_reqs =>   l_resched_reqs,
                 arg_wip_req_id =>     l_wip_req_id,
                 arg_osfm_req_id =>    l_osfm_req_id,
                 arg_req_load_id =>    l_req_load_id,
                 arg_req_resched_id => l_req_resched_id,
    -------------------------------------------------------------
                 arg_mode => arg_mode,
                 arg_transaction_id => arg_transaction_id,
                 l_apps_ver   =>  l_apps_ver,
                 arg_loaded_int_repair_orders=> l_loaded_int_repair_orders,   -- Sasi
                 arg_int_repair_orders_id=> l_int_repair_orders_id            -- Sasi
);



   COMMIT WORK;

   arg_loaded_jobs(lv_count)   :=  l_loaded_jobs;
   arg_loaded_reqs(lv_count)   :=  l_loaded_reqs;
   arg_loaded_scheds(lv_count) :=  l_loaded_scheds;
   arg_resched_jobs(lv_count)  :=  l_resched_jobs;

   arg_loaded_lot_jobs(lv_count) := l_loaded_lot_jobs;
   arg_resched_lot_jobs(lv_count) := l_resched_lot_jobs;

   arg_resched_reqs(lv_count)  :=  l_resched_reqs;
   arg_wip_req_id(lv_count)    :=  l_wip_req_id;

   arg_osfm_req_id(lv_count)    :=  l_osfm_req_id;
   arg_req_load_id(lv_count)   :=  l_req_load_id;
   arg_req_resched_id(lv_count):=  l_req_resched_id;

   --IRO release
   arg_loaded_int_repair_orders(lv_count):= l_loaded_int_repair_orders;  -- Sasi
   arg_int_repair_orders_id(lv_count) := l_int_repair_orders_id;         -- Sasi

   END LOOP;

   CLOSE c_Instance;

   arg_loaded_jobs.trim(1);
   arg_loaded_lot_jobs.trim(1);
   arg_loaded_reqs.trim(1);
   arg_loaded_scheds.trim(1);
   arg_resched_jobs.trim(1);
   arg_resched_lot_jobs.trim(1);
   arg_resched_reqs.trim(1);
   arg_wip_req_id.trim(1);
   arg_osfm_req_id.trim(1);
   arg_req_load_id.trim(1);
   arg_req_resched_id.trim(1);
   arg_released_instance.trim(1);
   arg_loaded_int_repair_orders.trim(1);-- Sasi
   arg_int_repair_orders_id.trim(1);    -- Sasi

EXCEPTION

   WHEN OTHERS THEN
      IF c_Instance%ISOPEN THEN CLOSE c_Instance; END IF;

      RAISE;

END MSC_Release_Plan_Sc;


PROCEDURE LOAD_MSC_INTERFACE
( arg_dblink                    IN      VARCHAR2
, arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 	        IN	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_compile_desig 		IN 	VARCHAR2
, arg_user_id 			IN 	NUMBER
, arg_po_group_by 		IN 	NUMBER
, arg_po_batch_number 		IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_loaded_jobs 		IN OUT 	NOCOPY  NUMBER
, arg_loaded_lot_jobs           IN OUT  NOCOPY  NUMBER
, arg_resched_lot_jobs          IN OUT  NOCOPY  NUMBER
, arg_loaded_reqs 		IN OUT  NOCOPY  NUMBER
, arg_loaded_scheds 		IN OUT  NOCOPY  NUMBER
, arg_resched_jobs 		IN OUT  NOCOPY  NUMBER
, arg_resched_reqs 		IN OUT  NOCOPY  NUMBER
, arg_wip_req_id 		IN OUT  NOCOPY  NUMBER
, arg_osfm_req_id               IN OUT  NOCOPY  NUMBER
, arg_req_load_id 		IN OUT  NOCOPY  NUMBER
, arg_req_resched_id 		IN OUT  NOCOPY  NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN VARCHAR2
, arg_loaded_int_repair_orders  IN OUT  NOCOPY  Number -- Sasi
, arg_int_repair_orders_id      IN OUT  NOCOPY  Number -- Sasi
) IS

    VERSION                 CONSTANT CHAR(800) :=
    '$Header: MSCPSRELB.pls 120.8.12010000.10 2010/04/13 23:41:02 harshsha ship $';

    lv_launch_process      INTEGER;
    lv_handle              VARCHAR2(200);
    lv_output              NUMBER;
    lv_error_stmt          VARCHAR2(2000) := NULL;

    lv_sql_stmt            VARCHAR2(4000);

    lv_wf                   NUMBER;
    lv_wf_load_type         NUMBER;

    lv_error_buf        VARCHAR2(2000);
    lv_ret_code	      NUMBER;
BEGIN



    -- if mode is NULL then it means that this procedure is called from PWB
    -- where we need to do batch processing
    -- If mode is WF, then we need to do this work only for the
    -- transaction_id that is passed in
    -- If the mode is WF_BATCH, this will only process the planned orders
    -- which need to be released, it won't process the supplies which needs
    -- to be rescheduled

    dbms_lock.allocate_unique(arg_compile_desig||
                                  to_char(arg_owning_org_id),lv_handle);

    lv_output := dbms_lock.request(lv_handle, 6, 32767, TRUE);

    if(lv_output <> 0) then
        FND_MESSAGE.SET_NAME('MRP', 'GEN-LOCK-WARNING');
        FND_MESSAGE.SET_TOKEN('EVENT', 'RELEASE PLANNED ORDERS');
        lv_error_stmt := FND_MESSAGE.GET;
        raise_application_error(-20000, lv_error_stmt);
    end if;

    -- Get the hour uom code
    -- Get the profile MRP_PURCHASING_BY_REVISION is set

    lv_sql_stmt:=
       'BEGIN'
     ||' :v_hour_uom := FND_PROFILE.VALUE'||arg_dblink
                                   ||'(''BOM:HOUR_UOM_CODE'');'
     ||' :v_purchasing_by_rev := FND_PROFILE.VALUE'||arg_dblink
                                   ||'(''MRP_PURCHASING_BY_REVISION'');'
     ||'END;';

    EXECUTE IMMEDIATE lv_sql_stmt
            USING OUT v_hour_uom,
                  OUT v_purchasing_by_rev;

    lv_wf:= SYS_NO;
    -- Get the Load Type if it's 'WF' mode.
    IF arg_mode = 'WF' THEN
       lv_wf:= SYS_YES;
       BEGIN
          SELECT load_type
            INTO lv_wf_load_type
            FROM MSC_SUPPLIES s
           WHERE s.plan_id = arg_plan_id
             AND s.transaction_id = arg_transaction_id
             and s.release_status = 1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
          WHEN OTHERS THEN RAISE;
       END;
    END IF;

    IF arg_mode = 'WF_BATCH' then
       lv_wf := 3;
    END IF;



    --- WIP_DIS_MASS_LOAD ---

       arg_loaded_jobs:= load_wip_discr_jobs_ps
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               l_apps_ver );


       arg_loaded_lot_jobs:= load_osfm_lot_jobs_ps
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_transaction_id,
                               l_apps_ver );



    --- WIP_DIS_MASS_RESCHEDULE ---
          arg_resched_jobs:= reschedule_wip_discr_jobs_ps
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_transaction_id,
                               l_apps_ver );


          arg_resched_lot_jobs := reschedule_osfm_lot_jobs_ps
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_transaction_id );



/*  MSC_RELEASE_HOOK.EXTEND_RELEASE
                 (lv_error_buf,
                  lv_ret_code,
                 arg_dblink  => arg_dblink,
                 arg_plan_id => arg_plan_id,
                 arg_log_org_id => arg_log_org_id,
                 arg_org_instance => arg_org_instance,
                 arg_owning_org_id => arg_owning_org_id,
                 arg_owning_instance => arg_owning_instance,
                 arg_compile_desig => arg_compile_desig,
                 arg_user_id => arg_user_id,
                 arg_po_group_by => arg_po_group_by,
                 arg_po_batch_number => arg_po_batch_number,
                 arg_wip_group_id => arg_wip_group_id,
    ----------------------------------------------- Number of Loaded Orders
                 arg_loaded_jobs   => arg_loaded_jobs,
                 arg_loaded_lot_jobs => arg_loaded_lot_jobs,
                 arg_resched_lot_jobs => arg_loaded_lot_jobs,
                 arg_loaded_reqs   => arg_loaded_reqs,
                 arg_loaded_scheds => arg_loaded_scheds,
                 arg_resched_jobs  => arg_resched_jobs,
                 arg_int_repair_orders=>arg_loaded_int_repair_orders,
    ----------------------------------------------- Request IDs
                 arg_resched_reqs =>   arg_resched_reqs,
                 arg_wip_req_id =>     arg_wip_req_id,
                 arg_osfm_req_id =>    arg_osfm_req_id,
                 arg_req_load_id =>    arg_req_load_id,
                 arg_req_resched_id => arg_req_resched_id,
                 arg_int_repair_Order_id=>arg_int_repair_orders_id,
    -------------------------------------------------------------
                 arg_mode => arg_mode,
                 arg_transaction_id => arg_transaction_id,
                 l_apps_ver   =>  l_apps_ver);



     IF lv_ret_code=-1 THEN --custom hook returned error
     	  FND_MESSAGE.SET_NAME('MSC','MSC_ERROR_REL_CUSTOM_HOOK');
      	RAISE_APPLICATION_ERROR(-20000,FND_MESSAGE.GET||lv_error_buf,TRUE);
   	END IF;
*/



 commit;

    -- call (remote) procedures to submit the concuncurrent request --

 IF v_curr_instance_type IN ( G_INS_DISCRETE, G_INS_PROCESS, G_INS_MIXED) THEN

    IF arg_loaded_jobs+arg_resched_jobs+arg_loaded_scheds > 0  THEN

        lv_sql_stmt:=
         'BEGIN'
        ||' MRP_AP_REL_PLAN_PUB.LD_WIP_JOB_SCHEDULE_INTERFACE'||arg_dblink
                  ||'( :arg_wip_req_id );'
        ||' END;';

        EXECUTE IMMEDIATE lv_sql_stmt
                USING OUT arg_wip_req_id;

      END IF;


      IF arg_loaded_lot_jobs + nvl(arg_resched_lot_jobs,0) > 0 then

        lv_sql_stmt:=
         'BEGIN'
        ||' MRP_AP_REL_PLAN_PUB.LD_LOT_JOB_SCHEDULE_INTERFACE'||arg_dblink
                  ||'( :arg_osfm_req_id );'
        ||' END;';

        EXECUTE IMMEDIATE lv_sql_stmt
                USING OUT arg_osfm_req_id;


       END IF;
   /*     DELETE msc_wip_job_schedule_interface
         WHERE sr_instance_id= arg_org_instance;

        DELETE MSC_WIP_JOB_DTLS_INTERFACE
         WHERE sr_instance_id= arg_org_instance;
  */
    IF arg_loaded_reqs > 0 THEN
      DECLARE po_group_by_name VARCHAR2(10);
      BEGIN
        IF arg_po_group_by = 1 THEN
          po_group_by_name := 'ALL';
        ELSIF arg_po_group_by = 2 THEN
          po_group_by_name := 'ITEM';
        ELSIF arg_po_group_by = 3 THEN
          po_group_by_name := 'BUYER';
        ELSIF arg_po_group_by = 4 THEN
          po_group_by_name := 'PLANNER';
        ELSIF arg_po_group_by = 5 THEN
          po_group_by_name := 'VENDOR';
        ELSIF arg_po_group_by = 6 THEN
          po_group_by_name := 'ONE-EACH';
        ELSIF arg_po_group_by = 7 THEN
          po_group_by_name := 'CATEGORY';
         ELSIF arg_po_group_by = 8 THEN
          po_group_by_name := 'LOCATION';
        END IF;

        lv_sql_stmt:=
           'BEGIN'
         ||' MRP_AP_REL_PLAN_PUB.LD_PO_REQUISITIONS_INTERFACE'||arg_dblink
                  ||'( :po_group_by_name,'
                  ||'  :arg_req_load_id );'
         ||' END;';
         EXECUTE IMMEDIATE lv_sql_stmt
                 USING  IN po_group_by_name,
                       OUT arg_req_load_id;

   /*     DELETE MSC_PO_REQUISITIONS_INTERFACE
         WHERE sr_instance_id= arg_org_instance;
*/
      END;
    END IF;

    IF arg_resched_reqs > 0 THEN

        lv_sql_stmt:=
            'BEGIN'
         ||' MRP_AP_REL_PLAN_PUB.LD_PO_RESCHEDULE_INTERFACE'||arg_dblink
                   ||'( :arg_req_resched_id);'
         ||' END;';

          EXECUTE IMMEDIATE lv_sql_stmt
                  USING OUT arg_req_resched_id;

 /*         DELETE MSC_PO_RESCHEDULE_INTERFACE
           WHERE sr_instance_id= arg_org_instance;
*/
    END IF;

 ELSIF v_curr_instance_type in (G_INS_OTHER, G_INS_EXCHANGE) THEN

      lv_sql_stmt :=
            ' BEGIN'
          ||' MSC_A2A_XML_WF.LEGACY_RELEASE (:p_arg_org_instance);'
          ||' END;';

      EXECUTE IMMEDIATE lv_sql_stmt USING  arg_org_instance;

 END IF; -- v_curr_instance_type

    --- Update the released orders.

    IF  arg_loaded_jobs > 0   OR
        arg_resched_jobs > 0  OR
        arg_loaded_lot_jobs > 0   OR
        arg_resched_lot_jobs > 0  OR
        arg_loaded_scheds > 0 OR
        arg_loaded_reqs > 0   OR
        arg_resched_reqs > 0  THEN

           UPDATE MSC_SUPPLIES
              SET implement_demand_class = NULL,
                  implement_date = NULL,
                  implement_quantity = NULL,
                  implement_firm = NULL,
                  implement_wip_class_code = NULL,
                  implement_job_name = NULL,
                  implement_status_code = NULL,
                  implement_location_id = NULL,
                  implement_source_org_id = NULL,
                  implement_supplier_id = NULL,
                  implement_supplier_site_id = NULL,
                  implement_project_id = NULL,
                  implement_task_id = NULL,
                  release_status = NULL,
                  load_type = NULL,
                  implement_as = NULL,
                  implement_unit_number = NULL,
                  implement_schedule_group_id = NULL,
                  implement_build_sequence = NULL,
                  implement_line_id = NULL,
                  implement_alternate_bom = NULL,
                  implement_dock_date = NULL,
                  implement_ship_date = NULL,
                  implement_employee_id = NULL,
                  implement_alternate_routing = NULL,
                  implemented_quantity = nvl(implemented_quantity, 0) + nvl(quantity_in_process,0),
                  quantity_in_process = 0,
                  implement_ship_method = NULL
            WHERE organization_id IN
                    (select planned_organization
                     from msc_plan_organizations_v
                     where organization_id = arg_owning_org_id
                     and  owning_sr_instance = arg_owning_instance
                     and plan_id = arg_plan_id
                     AND planned_organization = decode(arg_log_org_id,
                                       arg_owning_org_id, planned_organization,
               					arg_log_org_id)
                     AND sr_instance_id = arg_org_instance )
              AND sr_instance_id= arg_org_instance
              AND plan_id =  arg_plan_id
              AND release_status = 1
	      AND release_errors IS NULL
              AND transaction_id in
              (select header_id from msc_wip_job_schedule_interface
               where sr_instance_id = arg_org_instance
              UNION ALL
              select source_line_id from msc_po_requisitions_interface
               where sr_instance_id = arg_org_instance
              UNION ALL
              select source_line_id from msc_po_reschedule_interface
               where sr_instance_id = arg_org_instance
              )
              AND load_type BETWEEN WIP_DIS_MASS_LOAD AND PO_MASS_RESCHEDULE;

          IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
          DELETE msc_wip_job_schedule_interface
          WHERE sr_instance_id= arg_org_instance
          AND   NVL(GROUP_ID,-1) = NVL(arg_wip_group_id, -1);

          DELETE MSC_WIP_JOB_DTLS_INTERFACE
          WHERE sr_instance_id= arg_org_instance
          AND   NVL(GROUP_ID,-1) = NVL(arg_wip_group_id, -1);

          DELETE MSC_PO_REQUISITIONS_INTERFACE
          WHERE sr_instance_id= arg_org_instance
          AND   NVL(BATCH_ID, -1) = NVL(arg_po_batch_number, -1);

          DELETE MSC_PO_RESCHEDULE_INTERFACE
          WHERE sr_instance_id= arg_org_instance;
	  END IF;



    END IF;

EXCEPTION WHEN OTHERS THEN
rollback; /* Rollback whatever was released */

          DELETE msc_wip_job_schedule_interface
          WHERE sr_instance_id= arg_org_instance
          AND   NVL(GROUP_ID,-1) = NVL(arg_wip_group_id, -1);

          DELETE MSC_WIP_JOB_DTLS_INTERFACE
          WHERE sr_instance_id= arg_org_instance
          AND   NVL(GROUP_ID,-1) = NVL(arg_wip_group_id, -1);

          DELETE MSC_PO_REQUISITIONS_INTERFACE
          WHERE sr_instance_id= arg_org_instance
          AND   NVL(BATCH_ID, -1) = NVL(arg_po_batch_number, -1);


          DELETE MSC_PO_RESCHEDULE_INTERFACE
          WHERE sr_instance_id= arg_org_instance;
 commit;
 raise;

END LOAD_MSC_INTERFACE;


FUNCTION load_osfm_lot_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_transaction_id            IN      NUMBER,
  l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER
IS
   lv_loaded_jobs NUMBER := 0;

   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


   lv_transaction_id      NumTab;
   lv_instance_id         NumTab;
   lv_org_id              NumTab;
   lv_plan_id             NumTab;
   lv_agg_details         NumTab;
   lv_job_count           NUMBER;
   lv_release_details     NUMBER;
   lv_inflate_wip         NUMBER;

BEGIN

  SELECT decode(nvl(FND_PROFILE.value('MSC_RELEASE_DTLS_REVDATE'),'Y'),'N',2,1),
	DECODE(NVL(fnd_profile.value('MSC_INFLATE_WIP') ,'N'), 'N',2 ,1)
   	INTO lv_release_details,lv_inflate_wip
   	FROM dual;


  /* we release the lot based job details, only if it doesn't use aggregate resources */

 /* Details will NOT be released for
     b. if the new_wip_start_date is null
     c. if the implement quantity or date is different then the planned quantity date
     d. if the revision date is different then the new_wip_start_date
        and the profile option setting : MSC_RELEASE_DTLS_REVDATE  = 'N'

  */

   SELECT s.transaction_id,
   	  s.sr_instance_id,
          s.organization_id,
          s.plan_id
     BULK COLLECT
     INTO lv_transaction_id,
          lv_instance_id,
          lv_org_id,
          lv_plan_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs,
          msc_system_items msi,
          msc_plans mp
    WHERE  mp.plan_id = arg_plan_id
    AND   s.release_errors is NULL
    AND   nvl(s.cfm_routing_flag,0) = 3
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = arg_plan_id
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   ( orgs.planned_organization= arg_log_org_id
            OR arg_log_org_id = arg_owning_org_id )
    AND   orgs.sr_instance_id = arg_org_instance
    AND   s.load_type = 5
    AND   s.new_wip_start_date IS NOT NULL
    AND   msi.plan_id = -1
    AND   msi.organization_id = s.organization_id
    AND   msi.sr_instance_id = s.sr_instance_id
    AND   s.release_status = 1
UNION
  SELECT s.transaction_id,
          s.sr_instance_id,

          s.organization_id,
          s.plan_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs
    WHERE s.release_errors is NULL
    AND   nvl(s.cfm_routing_flag,0) = 3
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = arg_plan_id
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   ( orgs.planned_organization= arg_log_org_id
          OR arg_log_org_id = arg_owning_org_id )
    AND   orgs.sr_instance_id = arg_org_instance
    AND   s.load_type = 5
    and   s.new_wip_start_date IS NULL
    AND   s.release_status = 1;


    lv_job_count:= SQL%ROWCOUNT;



    -- -----------------------------------------------------------------------
    -- Perform the wip discrete job mass load
    -- -----------------------------------------------------------------------
       /* Due to we only give PLANNED components, BILL_RTG_EXPLOSION_FLAG
          is set to 'Y'.  */

         FOR k in 1..lv_job_count
       Loop
                Begin
                  SELECT 2
                  Into lv_agg_details(k)
                  FROM msc_department_resources deptres,
                       msc_resource_requirements resreq
                 WHERE resreq.sr_instance_id= lv_instance_id(k)
                   AND resreq.supply_id = lv_transaction_id(k)
                   AND resreq.organization_id= lv_org_id(k)
                   AND resreq.plan_id   = lv_plan_id(k)
                   AND resreq.parent_id   = 2
                   AND deptres.plan_id  = -1
                   AND deptres.sr_instance_id= resreq.sr_instance_id
                   AND deptres.resource_id= resreq.resource_id
                   AND deptres.department_id= resreq.department_id
                   AND deptres.organization_id= resreq.organization_id
                   AND deptres.aggregate_resource_flag= 1
                   AND rownum=1;
                  Exception
                  When no_data_found
                  then
                  lv_agg_details(k) := 1;
                  End;

       End Loop;



    FORALL j IN 1..lv_job_count
        INSERT INTO msc_wip_job_schedule_interface
            (last_update_date,
            cfm_routing_flag,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            source_code,
            source_line_id,
            organization_id,
            organization_type,
            load_type,
            status_type,
            first_unit_start_date,
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            primary_item_id,
            class_code,
            job_name,
            firm_planned_flag,
            start_quantity,
	    net_quantity,
            demand_class,
            project_id,
            task_id,
	    schedule_group_id,
       	    build_sequence,
	    line_id,
	    alternate_bom_designator,
	    alternate_routing_designator,
	    end_item_unit_number,
	    process_phase,
	    process_status,
            bom_reference_id,
            routing_reference_id,
            BILL_RTG_EXPLOSION_FLAG,
            HEADER_ID,
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID,
            schedule_priority,
            requested_completion_date)
       SELECT  SYSDATE,
            nvl(s.cfm_routing_flag,0),
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            s.transaction_id,
            s.organization_id,
            tp.organization_type,
            5,
            s.implement_status_code,
            new_wip_start_date,
            s.implement_date + 59/86400,
            s.new_wip_start_date,
            s.new_wip_start_date,
            item_lid.sr_inventory_item_id,
            s.implement_wip_class_code,
            s.implement_job_name,
            s.implement_firm,
            decode(s.implement_quantity,s.new_order_quantity,
                                          nvl(s.wip_start_quantity,s.implement_quantity),
                                        s.implement_quantity),
	    s.implement_quantity,
            s.implement_demand_class,
            s.implement_project_id,
            s.implement_task_id,
	    s.implement_schedule_group_id,
	    s.implement_build_sequence,
       	    s.implement_line_id,
	    s.implement_alternate_bom,
	    s.implement_alternate_routing,
 	    s.implement_unit_number,
	    2,
	    1,
            DECODE( tp.organization_type,
                    2, s.bill_sequence_id,
                    NULL),
            DECODE( tp.organization_type,
                    2, s.routing_sequence_id,
                    NULL),
            'Y',
            s.transaction_id,
            NULL, -- bugbug r12 has nvl(s.implement_uom_code,msi.uom_code).
            -- Should we get this from msi with plan_id = :refPlanId?
            -- Is it important? Will null be defaulted to the right thing?
            -- Run a test.
            s.sr_instance_id,
            s.schedule_priority,
            nvl(s.requested_completion_date, s.need_by_date)
      FROM  msc_trading_partners    tp,
            msc_parameters          param,
            msc_item_id_lid         item_lid,
            msc_supplies            s
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     item_lid.inventory_item_id = s.inventory_item_id
    AND     item_lid.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     nvl(s.cfm_routing_flag,0) = 3
    AND     s.release_status = 1;


    IF SQL%ROWCOUNT > 0
    THEN
        lv_loaded_jobs := SQL%ROWCOUNT;

    ELSE
        lv_loaded_jobs := 0;

    END IF;

        -- ------------------------------------------------------------------------
    -- Perform the lot-based job mass load for the details
    -- -----------------------------------------------------------------------

    /* lot-based job details are released only when the source profile WSM: Create Lot Based Job Routing is Yes
    and org planning parameter is primary */


    /* OPERATION NETWORKS */


    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     OPERATION_SEQ_NUM,
     NEXT_ROUTING_OP_SEQ_NUM,
     cfm_routing_flag,
     SR_INSTANCE_ID)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            5,
            1,
            1,
            nwk.from_op_seq_num,
            nwk.to_op_seq_num,
            3,
            s.sr_instance_id
   From msc_supplies s,
   msc_operation_networks nwk,
   msc_apps_instances ins,
   msc_parameters param
   Where    nwk.plan_id = -1
    AND     nwk.sr_instance_id = s.sr_instance_id
    AND     nwk.routing_sequence_id = s.routing_sequence_id
    AND     nwk.transition_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);


    /* Operations */

FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     OPERATION_SEQ_NUM,
     first_unit_start_date,
     last_unit_completion_date,
     cfm_routing_flag,
     SR_INSTANCE_ID,
     scheduled_quantity)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            3,
            1,
            1,
            res.operation_seq_num,
            min(res.START_DATE),
            max(res.END_DATE),
            3,
            s.sr_instance_id,
            max(res.CUMMULATIVE_QUANTITY)
   From msc_supplies s,
   msc_resource_requirements res,
   msc_apps_instances ins,
   msc_parameters param
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 2
    -- AND     res.resource_id <> -1 	Bug#3432607
    -- AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1
    GROUP BY
            s.last_update_login,
            s.transaction_id,
            res.OPERATION_SEQ_NUM,
            s.sr_instance_id);

    /* Resources */
FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     operation_seq_num,
     resource_id_new,
     start_date,
     completion_date,
     alternate_num,
     cfm_routing_flag,
     SR_INSTANCE_ID,
     firm_flag,
     setup_id,
     group_sequence_id,
     group_sequence_number,
     batch_id,
     maximum_assigned_units,
     parent_seq_num,
     resource_seq_num,
     schedule_seq_num,
     assigned_units,
     usage_rate_or_amount,
     scheduled_flag)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            decode(res.parent_seq_num, null,4,2),
            1,
            1,
            1,
            res.operation_seq_num,
            res.resource_id,
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            nvl(res.alternate_num,0),
            3,
            s.sr_instance_id,
            res.firm_flag,
            res.setup_id,
            res.group_sequence_id,
            res.group_sequence_number,
            res.batch_number,
            res.maximum_assigned_units,
            res.parent_seq_num,
            res.orig_resource_seq_num,
            res.resource_seq_num,
            res.assigned_units,

            -- For OSFM we re-compute the rate constant. :-(
            -- Should really be an OSFM side calculation.
            -- We populate the reverse cumulative yield in resource requirements.
            decode(res.parent_seq_num,
              null,
                decode(res.basis_type,
                  2, res.RESOURCE_HOURS,
                  res.RESOURCE_HOURS /
                    decode( msi.rounding_control_type,
                      1, ROUND( s.new_order_quantity /
                                  nvl(res.REVERSE_CUMULATIVE_YIELD,1) ,6),
                      s.new_order_quantity /
                        nvl(res.REVERSE_CUMULATIVE_YIELD,1)
                    )
                ) *
                decode(mdr.efficiency,
                  NULL,1,
                  0,1,
                  mdr.efficiency / 100
                ) *
                decode( mdr.utilization,
                  NULL,1,
                  0,1,
                  mdr.utilization / 100
                ),
              res.RESOURCE_HOURS
            ),

           decode(nvl(res.schedule_flag,1),-23453,1,1,1,res.schedule_flag)
   From msc_supplies         s,
   msc_resource_requirements res,
   msc_apps_instances        ins,
   msc_parameters            param,
   msc_department_resources  mdr,
   msc_system_items          msi
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 2
    AND     res.resource_id <> -1
    AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     -1 = mdr.plan_id
    AND     res.organization_id =mdr.organization_id
    AND     res.sr_instance_id = mdr.sr_instance_id
    AND     res.resource_id = mdr.resource_id
    AND     res.department_id=mdr.department_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = -1
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);

    /*Components*/

    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     operation_seq_num,
     inventory_item_id_new,
     primary_component_id,
     source_phantom_id,
     component_seq_id,
     mrp_net_flag,
     date_required,
     mps_date_required,
     basis_type,
     quantity_per_assembly,
     required_quantity,
     mps_required_quantity,
     cfm_routing_flag,
     SR_INSTANCE_ID)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            2,
            1,
            1,
            nvl(md.op_seq_num,1),
            icomp.sr_inventory_item_id,
            icomp1.sr_inventory_item_id,
            icomp2.sr_inventory_item_id,
            md.COMP_SEQ_ID,
            1,
            md.USING_ASSEMBLY_DEMAND_DATE,
            md.USING_ASSEMBLY_DEMAND_DATE,
-- bugbug Is this the correct way to compute basis_type?
            decode(md.component_scaling_type,1,NULL,md.component_scaling_type),
            md.quantity_per_assembly,
            md.USING_REQUIREMENT_QUANTITY,
            md.USING_REQUIREMENT_QUANTITY,
            3,
            s.sr_instance_id
   From msc_supplies s,
   msc_demands md,
   msc_system_items icomp,
   msc_system_items icomp1,
   msc_system_items icomp2,
   msc_apps_instances ins,
   msc_parameters param
   Where   /* not exists (select 'x'
                        from msc_exception_details excp
                        where excp.plan_id = s.plan_id
                        and excp.number1 = s.transaction_id
                        and excp.inventory_item_id = s.inventory_item_id
                        and excp.organization_id = s.organization_id
                        and excp.sr_instance_id = s.sr_instance_id
                        and excp.exception_type = 33
                        and excp.number2 = md.inventory_item_id)*/  /* not needed as inv_old need not be populated*/
    	    icomp.inventory_item_id= md.inventory_item_id
    AND     icomp.organization_id= md.organization_id
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     icomp.plan_id= -1
    AND     nvl(icomp.wip_supply_type,0) <> 6
    AND     icomp1.inventory_item_id= md.primary_component_id
    AND     icomp1.organization_id= md.organization_id
    AND     icomp1.sr_instance_id= md.sr_instance_id
    AND     icomp1.plan_id= -1
    AND     icomp2.inventory_item_id(+)= md.source_phantom_id
    AND     icomp2.organization_id(+)= md.organization_id
    AND     icomp2.sr_instance_id(+)= md.sr_instance_id
    AND     icomp2.plan_id(+)= -1
    AND     md.plan_id = s.plan_id
    AND     md.sr_instance_id = s.sr_instance_id
    AND     md.disposition_id= s.transaction_id
    AND     md.origination_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);


 /* Resource Usage */
 FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     operation_seq_num,
     resource_id_new,
     assigned_units,
     alternate_num,
     start_date,
     completion_date,
     cfm_routing_flag,
     SR_INSTANCE_ID,
     resource_seq_num,
     schedule_seq_num,
     parent_seq_num)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            4,
            1,
            1,
            res.operation_seq_num,
            res.resource_id,
            res.assigned_units,
            nvl(res.alternate_num,0),
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            3,
            s.sr_instance_id,
	    res.orig_resource_seq_num,
            res.resource_seq_num,
            res.parent_seq_num
   From msc_supplies s,
   msc_resource_requirements res,
   msc_apps_instances ins,
   msc_parameters param
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 1
    AND     res.resource_id <> -1
    AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);

     -- dsr begin: Operation Resource Instances
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            FIRM_FLAG,
            resource_hours,
            department_id,
	    SERIAL_NUMBER,
            group_sequence_id,
            group_sequence_number,
            batch_id
           , resource_seq_num
           , schedule_seq_num
           , parent_seq_num
           , cfm_routing_flag
           , resource_id_new
           , assigned_units
          )
    SELECT
           SYSDATE,
           arg_user_id,
           s.last_update_login,
           SYSDATE,
           arg_user_id,
           tp.organization_type,
           s.organization_id,
           arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
           res_instreq.RES_INSTANCE_ID,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD,
           LT_RESOURCE_INSTANCE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.firm_flag,
           res_instreq.resource_instance_hours,
           resreq.department_id,
           res_instreq.serial_number,
           resreq.group_sequence_id,
           resreq.group_sequence_number,
           res_instreq.batch_number,
           resreq.orig_resource_seq_num
	  , resreq.resource_seq_num
	  , resreq.parent_seq_num
	  , 3
	  , resreq.resource_id
	  , 1
    FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_resource_instance_reqs res_instreq,
           msc_supplies            s,
           msc_apps_instances ins,
           msc_parameters param
    WHERE
         tp.sr_tp_id=s.organization_id
 AND     tp.sr_instance_id= s.sr_instance_id
 AND     tp.partner_type=3
 AND     resreq.sr_instance_id= s.sr_instance_id
 AND     resreq.organization_id= s.organization_id
 AND     resreq.supply_id = s.transaction_id
 AND     resreq.plan_id   = s.plan_id
 AND     resreq.sr_instance_id = res_instreq.sr_instance_id
 AND     resreq.plan_id = res_instreq.plan_id
 AND     resreq.resource_seq_num = res_instreq.resource_seq_num
 AND     resreq.operation_seq_num = res_instreq.operation_seq_num
 AND     resreq.resource_id = res_instreq.resource_id
 AND     resreq.supply_id = res_instreq.supply_id
 AND     resreq.parent_id = res_instreq.parent_id
 AND     resreq.start_date = res_instreq.start_date
 AND     resreq.parent_id   = 2
 AND     resreq.resource_id <> -1
 AND     resreq.department_id <> -1
 AND    res_instreq.plan_id = s.plan_id
 AND    s.transaction_id= lv_transaction_id(j)
 AND    s.sr_instance_id= lv_instance_id(j)
 AND    s.plan_id= arg_plan_id
 AND    lv_agg_details(j) = 1
 AND    ins.instance_id = lv_instance_id(j)
 AND    nvl(ins.lbj_details,2) = 1
 AND    param.organization_id = s.organization_id
 AND    param.sr_instance_id = s.sr_instance_id
 AND    param.network_scheduling_method = 1
 AND    s.release_status = 1;


  -- print_debug_info( 'Operation Resource Instances: rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = '
  --						|| SQL%ROWCOUNT
  --						);

   -- dsr: RESOURCE INSTANCE USAGES

FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            FIRM_FLAG,
            resource_hours,
            department_id,
            serial_number,
            resource_seq_num,
            schedule_seq_num,
            parent_seq_num,
            cfm_routing_flag,
            resource_id_new,
            assigned_units
     )
    SELECT
            SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            res_instreq.RES_INSTANCE_ID,
            nvl(resreq.firm_start_date,res_instreq.START_DATE),
            nvl(resreq.firm_end_date,res_instreq.END_DATE),
            SUBST_ADD,
            LT_RESOURCE_INST_USAGE,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            resreq.firm_flag,
            res_instreq.resource_instance_hours,
            resreq.department_id,
            res_instreq.serial_number,
            resreq.orig_resource_seq_num
	  , resreq.resource_seq_num
	  , resreq.parent_seq_num
	  , 3
	  , resreq.resource_id
	  , 1
     FROM
            msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_resource_instance_reqs res_instreq,
            msc_supplies            s,
            msc_apps_instances ins,
  	    msc_parameters param
    WHERE
            tp.sr_tp_id=s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.sr_instance_id = res_instreq.sr_instance_id
    AND     resreq.plan_id = res_instreq.plan_id
    AND     resreq.resource_seq_num = res_instreq.resource_seq_num
    AND     resreq.operation_seq_num = res_instreq.operation_seq_num
    AND     resreq.resource_id = res_instreq.resource_id
    AND     resreq.supply_id = res_instreq.supply_id
    AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
    AND     resreq.start_date = res_instreq.start_date
    AND     resreq.parent_id   = 1
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     res_instreq.plan_id = s.plan_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1
	;

  -- print_debug_info( 'Resource Instance Usage: rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = '
  -- 						|| SQL%ROWCOUNT
  --						);

	-- dsr end

    return lv_loaded_jobs;

END load_osfm_lot_jobs_ps;



FUNCTION reschedule_osfm_lot_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER
IS

TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   lv_resched_jobs    NUMBER;
   lv_transaction_id  NumTab;
   lv_instance_id     NumTab;
   lv_org_id	      NumTab;
   lv_plan_id         NumTab;
   lv_agg_details     NumTab;

BEGIN

	/* Details will not be released
		for Non - Daily Bucketed Plans
		if the implement quantity or date is different then the planned quantity date
		if the Lot-based job uses aggregate resources
		if the job has faulty network*/

	SELECT s.transaction_id,
          s.sr_instance_id,
           s.organization_id,
           s.plan_id
     BULK COLLECT
     INTO lv_transaction_id,
          lv_instance_id,
          lv_org_id,
          lv_plan_id
     FROM msc_plans mp,
          msc_supplies s,
          msc_plan_organizations_v orgs
    WHERE mp.plan_id = arg_plan_id
    AND   s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = arg_plan_id
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   ( orgs.planned_organization= arg_log_org_id
            OR arg_log_org_id = arg_owning_org_id )
    AND   orgs.sr_instance_id = arg_org_instance
    AND   s.load_type = 6
    AND   s.release_status = 1;

    lv_resched_jobs:= SQL%ROWCOUNT;


    FOR k in 1..lv_resched_jobs
       Loop
                Begin
                  SELECT 2
                  Into lv_agg_details(k)
                  FROM msc_department_resources deptres,
                       msc_resource_requirements resreq
                 WHERE resreq.sr_instance_id= lv_instance_id(k)
                   AND resreq.supply_id = lv_transaction_id(k)
                   AND resreq.organization_id= lv_org_id(k)
                   AND resreq.plan_id   = lv_plan_id(k)
                   AND resreq.parent_id   = 2
                   AND deptres.plan_id  = -1
                   AND deptres.sr_instance_id= resreq.sr_instance_id
                   AND deptres.resource_id= resreq.resource_id
                   AND deptres.department_id= resreq.department_id
                   AND deptres.organization_id= resreq.organization_id
                   AND deptres.aggregate_resource_flag= 1
                   AND rownum=1;
                  Exception
                  When no_data_found
                  then
                  lv_agg_details(k) := 1;
                  End;

       End Loop;

    -- ------------------------------------------------------------------------
    -- Perform the lot based job reschedule
    -- ------------------------------------------------------------------------
    FORALL j in 1..lv_resched_jobs
    INSERT INTO msc_wip_job_schedule_interface
            (last_update_date,
            last_updated_by,
            cfm_routing_flag,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            source_code,
            organization_id,
            organization_type,
            status_type,
            load_type,
            first_unit_start_date,
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            job_name,
            firm_planned_flag,
            start_quantity,   /* bug 1229891: net_quantity */
            net_quantity,
            wip_entity_id,
            demand_class,
            project_id,
            task_id,
	    schedule_group_id,
	    build_sequence,
            line_id,
            alternate_bom_designator,
	    alternate_routing_designator,
	    end_item_unit_number,
            process_phase,
	    process_status,
            BILL_RTG_EXPLOSION_FLAG,
            HEADER_ID,
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID,
            PRIMARY_ITEM_ID,
            source_line_id, --Outbound Changes for XML
            schedule_priority,
            requested_completion_date)
    SELECT  SYSDATE,
            arg_user_id,
            s.cfm_routing_flag,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            s.organization_id,
            tp.organization_type,
                   NULL,
            6,
            new_wip_start_date,
            s.implement_date + 59/86400,
            NULL,
            NULL,
            s.implement_job_name,
            s.implement_firm,
            DECODE( tp.organization_type,
                    1, DECODE(s.new_order_quantity,
                              s.implement_quantity, TO_NUMBER(NULL),
                        ((s.new_order_quantity + NVL(s.qty_completed, 0) +
                          NVL(s.qty_scrapped, 0)) -
                         (s.new_order_quantity - s.implement_quantity))),
                    NULL),
            DECODE( tp.organization_type,
                    2, DECODE(s.new_order_quantity,
                              s.implement_quantity, TO_NUMBER(NULL),
                        ((s.new_order_quantity + NVL(s.qty_completed, 0) +
                          NVL(s.qty_scrapped, 0)) -
                         (s.new_order_quantity - s.implement_quantity))),
                    s.implement_quantity),
            s.disposition_id,
            s.implement_demand_class,
            s.implement_project_id,
            s.implement_task_id,
	    s.implement_schedule_group_id,
            s.implement_build_sequence,
            s.implement_line_id,
       	    s.implement_alternate_bom,
	    s.implement_alternate_routing,
	    s.implement_unit_number,
            2,
	    1,
            'Y',
            s.transaction_id,
-- bugbug Is this right for Uom. R12 looks in msc_system_items if not here.
            s.implement_uom_code,
            s.sr_instance_id,
            item_lid.sr_inventory_item_id,            -- msi.sr_inventory_item_id, -- ey, if you don't flush  msc_system_items, you need to somehow pass the   source_inventory_item_id to here   MN: use msc_iten_id_lid

            s.transaction_id, --Outbound Changes for XML
            s.schedule_priority,
            s.requested_completion_date
    FROM    msc_trading_partners tp,
            msc_parameters param,
            msc_item_id_lid item_lid,

            msc_supplies     s,
            msc_plan_organizations_v orgs
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = s.organization_id
    AND    param.sr_instance_id = s.sr_instance_id
    AND    item_lid.sr_instance_id =  s.sr_instance_id        --MN:: added
    AND    item_lid.inventory_item_id = s.inventory_item_id
    AND    item_lid.sr_instance_id  = s.sr_instance_id
    AND    s.release_errors is NULL
    AND    s.organization_id = orgs.planned_organization
    AND    s.sr_instance_id = orgs.sr_instance_id
    AND    s.plan_id = orgs.plan_id
    AND    s.new_wip_start_date > SYSDATE
    AND    orgs.organization_id = arg_owning_org_id
    AND    orgs.owning_sr_instance = arg_owning_instance
    AND    orgs.plan_id = arg_plan_id
    AND    orgs.planned_organization = decode(arg_log_org_id,
                                         arg_owning_org_id, orgs.planned_organization,
                                          arg_log_org_id)
    AND    orgs.sr_instance_id = arg_org_instance
    AND    s.load_type = 6
    AND    nvl(s.cfm_routing_flag,0) = 3
    AND    s.transaction_id = lv_transaction_id(j)
    AND    s.sr_instance_id  = lv_instance_id(j)
    AND    s.plan_id = lv_plan_id(j)
    AND    s.release_status = 1;



    -- ------------------------------------------------------------------------
    -- Perform the lot-based job mass load for the details
    -- -----------------------------------------------------------------------

    /* lot-based job details are released only when the source profile WSM: Create Lot Based Job Routing is Yes
    and org planning parameter is primary */


    /* OPERATION NETWORKS */


    FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     job_op_seq_num,
     operation_seq_num,
     next_routing_op_seq_num,
     cfm_routing_flag,
     SR_INSTANCE_ID)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            5,
            1,
            1,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(nwk.from_op_seq_num, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), nwk.from_op_seq_num, s.JOB_OP_SEQ_NUM,null),
            decode(nwk.from_op_seq_num, 50000 ,null,nwk.from_op_seq_num),
            nwk.to_op_seq_num,
            3,
            s.sr_instance_id
   From msc_supplies s,
   msc_job_operation_networks nwk,
   msc_apps_instances ins,
   msc_parameters param
   Where    nwk.plan_id = -1
    AND     nwk.sr_instance_id = s.sr_instance_id
    AND     nwk.transaction_id = s.transaction_id
    AND     nwk.recommended = 'Y'
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.new_wip_start_date > SYSDATE
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);


    /* Operations */

FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     job_op_seq_num,
     OPERATION_SEQ_NUM,
     first_unit_start_date,
     last_unit_completion_date,
     cfm_routing_flag,
     SR_INSTANCE_ID,
     scheduled_quantity)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            3,
            1,
            1,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(res.OPERATION_SEQ_NUM, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), res.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM,null),
            decode(res.operation_seq_num, 50000,null,res.operation_seq_num),
            min(res.START_DATE),
            max(res.END_DATE),
            3,
            s.sr_instance_id,
            max(res.CUMMULATIVE_QUANTITY)
   From msc_supplies s,
   msc_resource_requirements res,
   msc_apps_instances ins,
   msc_parameters param
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 2
    -- AND     res.resource_id <> -1   --Bug#3432607
    -- AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.new_wip_start_date > SYSDATE
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1
    GROUP BY
            s.last_update_login,
            s.transaction_id,
            res.OPERATION_SEQ_NUM,
            s.sr_instance_id,
            s.OPERATION_SEQ_NUM,
            s.JUMP_OP_SEQ_NUM,
            s.JOB_OP_SEQ_NUM);

    /* Resources */
FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     job_op_seq_num,
     operation_seq_num,
     resource_id_new,
     start_date,
     completion_date,
     alternate_num,
     cfm_routing_flag,
     SR_INSTANCE_ID,
     firm_flag,
     setup_id,
     group_sequence_id,
     group_sequence_number,
     batch_id,
     maximum_assigned_units,
     parent_seq_num,
     resource_seq_num,
     schedule_seq_num,
     assigned_units,
     usage_rate_or_amount,
     scheduled_flag)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            decode(res.parent_seq_num, null,4,2),
            1,
            1,
            1,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(res.OPERATION_SEQ_NUM, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), res.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM,null),
            decode(res.operation_seq_num, 50000,null,res.operation_seq_num),
            res.resource_id,
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            nvl(res.alternate_num,0),
            3,
            s.sr_instance_id,
            res.firm_flag,
            res.setup_id,
            res.group_sequence_id,
            res.group_sequence_number,
            res.batch_number,
            res.maximum_assigned_units,
            res.parent_seq_num,
        res.orig_resource_seq_num,
            res.resource_seq_num,
            res.assigned_units,


      -- For OSFM we re-compute the rate constant. :-(
      -- Should really be an OSFM side calculation.
      -- We populate the reverse cumulative yield in resource requirements.
	    decode(res.parent_seq_num,
        null,
          decode(res.basis_type,
            2,res.RESOURCE_HOURS,
            res.RESOURCE_HOURS /
              decode(msi.rounding_control_type,
                1, ROUND(s.new_order_quantity /
                           nvl(res.REVERSE_CUMULATIVE_YIELD,1) ,6),
                s.new_order_quantity /
                  nvl(res.REVERSE_CUMULATIVE_YIELD,1)
              )
          ) *
          decode( mdr.efficiency,
            NULL,1,
            0,1,
            mdr.efficiency / 100
          ) *
          decode(mdr.utilization,
            NULL,1,
            0,1,
            mdr.utilization / 100
          ),
        res.RESOURCE_HOURS
      ),
      decode(nvl(res.schedule_flag,1),-23453,1,1,1,res.schedule_flag)
   From msc_supplies s,
   msc_resource_requirements res,
   msc_apps_instances ins,
   msc_parameters param,
   msc_department_resources mdr,
   msc_system_items msi
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 2
    AND     res.resource_id <> -1
    AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.new_wip_start_date > SYSDATE
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     -1 = mdr.plan_id
    AND     res.organization_id =mdr.organization_id
    AND     res.sr_instance_id = mdr.sr_instance_id
    AND     res.resource_id = mdr.resource_id
    AND     res.department_id=mdr.department_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = -1
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);

    /*Components*/

    FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     job_op_seq_num,
     operation_seq_num,
     inventory_item_id_new,
     primary_component_id,
     source_phantom_id,
     component_seq_id,
     mrp_net_flag,
     date_required,
     mps_date_required,
     basis_type,
     quantity_per_assembly,
     required_quantity,
     mps_required_quantity,
     cfm_routing_flag,
     SR_INSTANCE_ID)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            2,
            1,
            1,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(md.op_seq_num, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), md.op_seq_num, s.JOB_OP_SEQ_NUM,null),
            decode(md.op_seq_num, 50000,null,md.op_seq_num),
            icomp.sr_inventory_item_id,
            icomp1.sr_inventory_item_id,
            icomp2.sr_inventory_item_id,
            md.COMP_SEQ_ID,
            1,
            md.USING_ASSEMBLY_DEMAND_DATE,
            md.USING_ASSEMBLY_DEMAND_DATE,
-- bugbug Is this the correct way to compute lot basis?
            decode(md.component_scaling_type,1,NULL,md.component_scaling_type),
            md.quantity_per_assembly,
            md.USING_REQUIREMENT_QUANTITY,
            md.USING_REQUIREMENT_QUANTITY,
            3,
            s.sr_instance_id
   From msc_supplies s,
   msc_demands md,
   msc_system_items icomp,
   msc_system_items icomp1,
   msc_system_items icomp2,
   msc_apps_instances ins,
   msc_parameters param
   Where   /* not exists (select 'x'
                        from msc_exception_details excp
                        where excp.plan_id = s.plan_id
                        and excp.number1 = s.transaction_id
                        and excp.inventory_item_id = s.inventory_item_id
                        and excp.organization_id = s.organization_id
                        and excp.sr_instance_id = s.sr_instance_id
                        and excp.exception_type = 33
                        and excp.number2 = md.inventory_item_id)*/  /* not needed as inv_old need not be populated*/
    	    icomp.inventory_item_id= md.inventory_item_id
    AND     icomp.organization_id= md.organization_id
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     icomp.plan_id= -1
    AND     nvl(icomp.wip_supply_type,0) <> 6
    AND     icomp1.inventory_item_id= md.primary_component_id
    AND     icomp1.organization_id= md.organization_id
    AND     icomp1.sr_instance_id= md.sr_instance_id
    AND     icomp1.plan_id= -1
    AND     icomp2.inventory_item_id(+)= md.source_phantom_id
    AND     icomp2.organization_id(+)= md.organization_id
    AND     icomp2.sr_instance_id(+)= md.sr_instance_id
    AND     icomp2.plan_id(+)= -1
    AND     md.plan_id = s.plan_id
    AND     md.sr_instance_id = s.sr_instance_id
    AND     md.disposition_id= s.transaction_id
    AND     md.origination_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.new_wip_start_date > SYSDATE
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);


 /* Resource Usage */
 FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
    (last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     group_id,
     parent_header_id,
     SUBSTITUTION_TYPE,
     LOAD_TYPE,
     process_phase,
     process_status,
     job_op_seq_num,
     operation_seq_num,
     resource_id_new,
     assigned_units,
     alternate_num,
     start_date,
     completion_date,
     cfm_routing_flag,
     SR_INSTANCE_ID,
     resource_seq_num,
     schedule_seq_num,
     parent_seq_num)
  (SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            4,
            4,
            1,
            1,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(res.operation_seq_num, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), res.operation_seq_num, s.JOB_OP_SEQ_NUM,null),
            decode(res.operation_seq_num, 50000,null,res.operation_seq_num),
            res.resource_id,
            res.assigned_units,
            nvl(res.alternate_num,0),
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            3,
            s.sr_instance_id,
	    res.orig_resource_seq_num,
            res.resource_seq_num,
	    res.parent_seq_num
   From msc_supplies s,
   msc_resource_requirements res,
   msc_apps_instances ins,
   msc_parameters param
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 1
    AND     res.resource_id <> -1
    AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.new_wip_start_date > SYSDATE
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1);
    -- dsr begin: Operation Resource Instances

    FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            job_op_seq_num,
            operation_seq_num,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            FIRM_FLAG,
            resource_hours,
            department_id,
	    SERIAL_NUMBER,
            group_sequence_id,
            group_sequence_number,
            batch_id
            , resource_seq_num -- dsr
            , schedule_seq_num
            , parent_seq_num
            , cfm_routing_flag
            , resource_id_new
            , assigned_units
         )
    SELECT
            SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(resreq.operation_seq_num, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), resreq.operation_seq_num, s.JOB_OP_SEQ_NUM,null),
            decode(resreq.operation_seq_num, 50000,null,resreq.operation_seq_num),
            res_instreq.RES_INSTANCE_ID,
            nvl(resreq.firm_start_date,res_instreq.START_DATE),
            nvl(resreq.firm_end_date,res_instreq.END_DATE),
            SUBST_ADD,
            LT_RESOURCE_INSTANCE,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            resreq.firm_flag,
            res_instreq.resource_instance_hours,
            resreq.department_id,
            res_instreq.serial_number,
            resreq.group_sequence_id,
            resreq.group_sequence_number,
            res_instreq.batch_number,
	    resreq.orig_resource_seq_num,
	    resreq.resource_seq_num,
	    resreq.parent_seq_num,
	    3,
	    resreq.resource_id,
	    1
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_resource_instance_reqs res_instreq,
            msc_supplies            s,
            msc_apps_instances ins,
            msc_parameters param
    WHERE
            tp.sr_tp_id=s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.sr_instance_id = res_instreq.sr_instance_id
    AND     resreq.plan_id = res_instreq.plan_id
    AND     resreq.resource_seq_num = res_instreq.resource_seq_num
    AND     resreq.operation_seq_num = res_instreq.operation_seq_num
    AND     resreq.resource_id = res_instreq.resource_id
    AND     resreq.supply_id = res_instreq.supply_id
    AND     resreq.parent_id = res_instreq.parent_id
    AND     resreq.start_date = res_instreq.start_date
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     res_instreq.plan_id = s.plan_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.new_wip_start_date > SYSDATE
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    AND     s.release_status = 1
	;

  -- print_debug_info('Resource Instance: rows inserted into msc_wip_job_dtls_interface = '
  --  					|| sql%rowcount);

FORALL j IN 1..lv_resched_jobs
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            job_op_seq_num,
            operation_seq_num,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            FIRM_FLAG,
            resource_hours,
            department_id,
            serial_number
            , resource_seq_num -- dsr
            , schedule_seq_num
            , parent_seq_num
            , cfm_routing_flag
            , resource_id_new
            , assigned_units
 )
    SELECT
            SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            decode(s.JUMP_OP_SEQ_NUM, null, decode(resreq.operation_seq_num, s.OPERATION_SEQ_NUM, s.JOB_OP_SEQ_NUM, null), resreq.operation_seq_num, s.JOB_OP_SEQ_NUM,null),
            decode(resreq.operation_seq_num, 50000,null,resreq.operation_seq_num),
            res_instreq.RES_INSTANCE_ID,
            nvl(resreq.firm_start_date,res_instreq.START_DATE),
            nvl(resreq.firm_end_date,res_instreq.END_DATE),
            SUBST_ADD,
            LT_RESOURCE_INST_USAGE,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            resreq.firm_flag,
            res_instreq.resource_instance_hours,
            resreq.department_id,
            res_instreq.serial_number,
            resreq.orig_resource_seq_num
	    , resreq.resource_seq_num
	    , resreq.parent_seq_num
	    , 3
	    , resreq.resource_id
	    , 1
    FROM
            msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_resource_instance_reqs res_instreq,
            msc_supplies            s,
            msc_apps_instances ins,
            msc_parameters param
    WHERE
            tp.sr_tp_id=s.organization_id
      AND   tp.sr_instance_id= s.sr_instance_id
      AND   tp.partner_type=3
      AND   resreq.sr_instance_id= s.sr_instance_id
      AND   resreq.organization_id= s.organization_id
      AND   resreq.supply_id = s.transaction_id
      AND   resreq.plan_id   = s.plan_id
      AND   resreq.sr_instance_id = res_instreq.sr_instance_id
      AND   resreq.plan_id = res_instreq.plan_id
      AND   resreq.resource_seq_num = res_instreq.resource_seq_num
      AND   resreq.operation_seq_num = res_instreq.operation_seq_num
      AND   resreq.resource_id = res_instreq.resource_id
      AND   resreq.supply_id = res_instreq.supply_id
      AND   resreq.parent_id = res_instreq.parent_id  --rawasthi
      AND   resreq.start_date = res_instreq.start_date
      AND   resreq.parent_id   = 1
      AND   resreq.resource_id <> -1
      AND   resreq.department_id <> -1
      AND   s.transaction_id= lv_transaction_id(j)
      AND   s.sr_instance_id= lv_instance_id(j)
      AND   s.plan_id= arg_plan_id
      AND   s.new_wip_start_date > SYSDATE
      AND   lv_agg_details(j) = 1
      AND   ins.instance_id = lv_instance_id(j)
      AND   nvl(ins.lbj_details,2) = 1
      AND   param.organization_id = s.organization_id
      AND   param.sr_instance_id = s.sr_instance_id
      AND   param.network_scheduling_method = 1
      AND   s.release_status = 1
	;

  -- print_debug_info('Resource Instance Usage: rows inserted into msc_wip_job_dtls_interface = '
  -- 					|| sql%rowcount);

	-- dsr end
    RETURN lv_resched_jobs;

END reschedule_osfm_lot_jobs_ps;



FUNCTION load_wip_discr_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER
IS
   lv_loaded_jobs NUMBER;

   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 --TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;

   lv_transaction_id          NumTab;
   lv_instance_id             NumTab;
   lv_Agg_details             NumTab;
   Lv_org_id                  Numtab;
   lv_plan_id                 NumTab;
   lv_job_count               NUMBER;
   lv_release_details         NUMBER;
   lv_inflate_wip             NUMBER;
   lv_round_primary_item      NumTab;

BEGIN

   SELECT decode(nvl(FND_PROFILE.value('MSC_RELEASE_DTLS_REVDATE'),'Y'),'N',2,1),
   DECODE(NVL(fnd_profile.value('MSC_INFLATE_WIP') ,'N'), 'N',2 ,1)
   INTO lv_release_details,lv_inflate_wip
   FROM dual;

  /* we release the discrete job, only if it doesn't use aggregate resources */
  /* bug 1252659 fix, replace rowid by
         (transaction_id,sr_instance_id,plan_id) */

  /* Details will NOT be released for
     a. Unconstrained Plan for 11i Source
         a.1 bug 4613532 - not only for 11i source, any source.
     b. if the new_wip_start_date is null
     c. if the implement quantity or date is different then the planned quantity date
     d. if the revision date is different then the new_wip_start_date
        and the profile option setting : MSC_RELEASE_DTLS_REVDATE  = 'N'
     e. Non - Daily Bucketed Plans
     f. BUG 4383804
        Alternate BOM/Routing is changed during release.
  */


   SELECT s.transaction_id,
          s.sr_instance_id,
          s.organization_id,
          s.plan_id,
          2
     BULK COLLECT
     INTO lv_transaction_id,
          lv_instance_id,
          lv_org_id,
          lv_plan_id,
          lv_round_primary_item
     FROM msc_supplies s,
          msc_plan_organizations_v orgs,
          msc_system_items      msi, -- REMOVE
          msc_plans mp
    WHERE mp.plan_id = arg_plan_id
    AND   s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = orgs.plan_id
    AND   msi.inventory_item_id = s.inventory_item_id
    AND   msi.plan_id = -1
    AND   msi.organization_id = s.organization_id
    AND   msi.sr_instance_id = s.sr_instance_id
    AND   orgs.plan_id = mp.plan_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   ( orgs.planned_organization= arg_log_org_id
            OR arg_log_org_id = arg_owning_org_id )
    AND   orgs.sr_instance_id = arg_org_instance
    AND   s.load_type = WIP_DIS_MASS_LOAD
    and   s.new_wip_start_date IS NOT NULL
    AND   s.release_status = 1
UNION
  SELECT s.transaction_id,
          s.sr_instance_id,
          s.organization_id,
          s.plan_id,
          2  /* setting rounding control to 2 ,since details are not released and this flag is used in details*/
     FROM msc_supplies s,
          msc_plan_organizations_v orgs
    WHERE s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = arg_plan_id
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   ( orgs.planned_organization= arg_log_org_id
          OR arg_log_org_id = arg_owning_org_id )
    AND   orgs.sr_instance_id = arg_org_instance
    AND   s.load_type = WIP_DIS_MASS_LOAD
    and   s.new_wip_start_date IS NULL
    AND   s.release_status = 1;

    lv_job_count:= SQL%ROWCOUNT;

    -- -----------------------------------------------------------------------
    -- Perform the wip discrete job mass load
    -- -----------------------------------------------------------------------
       /* Due to we only give PLANNED components, BILL_RTG_EXPLOSION_FLAG
          is set to 'Y'.  */

    --DBMS_OUTPUT.PUT_LINE('LOAD_JOB');

    FOR k in 1..lv_job_count
       Loop
                Begin
                  SELECT 2
                  Into lv_agg_details(k)
                  FROM msc_department_resources deptres,
                       msc_resource_requirements resreq
                 WHERE resreq.sr_instance_id= lv_instance_id(k)
                   AND resreq.supply_id = lv_transaction_id(k)
                   AND resreq.organization_id= lv_org_id(k)
                   AND resreq.plan_id   = lv_plan_id(k)
                   AND resreq.parent_id   = 2
                   AND deptres.plan_id  = -1
                   AND deptres.sr_instance_id= resreq.sr_instance_id
                   AND deptres.resource_id= resreq.resource_id
                   AND deptres.department_id= resreq.department_id
                   AND deptres.organization_id= resreq.organization_id
                   AND deptres.aggregate_resource_flag= 1
                   AND rownum=1;
                  Exception
                  When no_data_found
                  then
                  lv_agg_details(k) := 1;
                  End;

       End Loop;



    FORALL j IN 1..lv_job_count
    INSERT INTO msc_wip_job_schedule_interface
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            source_code,
            source_line_id,
            organization_id,
            organization_type,
            load_type,
            status_type,
            first_unit_start_date,
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            primary_item_id,
            class_code,
            job_name,
            firm_planned_flag,
            start_quantity,
	    net_quantity,
            demand_class,
            project_id,
            task_id,
	    schedule_group_id,
       	    build_sequence,
	    line_id,
	    alternate_bom_designator,
	    alternate_routing_designator,
	    end_item_unit_number,
	    process_phase,
	    process_status,
            bom_reference_id,
            routing_reference_id,
            BILL_RTG_EXPLOSION_FLAG,
            HEADER_ID,
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID,
            schedule_priority,
            requested_completion_date)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            decode(tp.organization_type,2,s.creation_date,SYSDATE),
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            s.transaction_id,
            s.organization_id,
            tp.organization_type,
            1,
            decode(tp.organization_type,2,1,s.implement_status_code),
            s.new_wip_start_date,
            s.implement_date,
 /* Added to code to release the greatest of sysdate OR the BOM/Routing revision date */
            SYSDATE + (1439/1440),
            SYSDATE + (1439/1440), --bug 5388465
            item_lid.sr_inventory_item_id,       --MN: is this correct? --ey yes
            s.implement_wip_class_code,
            s.implement_job_name,
            s.implement_firm,

/* Bug 4540170 - PLANNED ORDERS RELEASED FROM ASCP DO NOT CREATE BATCH WITH CORRECT QTYS */
            decode(tp.organization_type,2,s.implement_quantity,     -- 4540170
                     decode(s.implement_quantity,s.new_order_quantity,
                                              nvl(s.wip_start_quantity,s.implement_quantity),
                                              s.implement_quantity)
            ),
	    s.implement_quantity,
            s.implement_demand_class,
            s.implement_project_id,
            s.implement_task_id,
	    s.implement_schedule_group_id,
	    s.implement_build_sequence,
       	    s.implement_line_id,
	    s.implement_alternate_bom,
	    s.implement_alternate_routing,
 	    s.implement_unit_number,
	    2,
	    1,
            DECODE( tp.organization_type,             --RS: publish into supplies table
                    2, s.bill_sequence_id,            --RS: it was taking from msc_process_efficiency before
                    NULL),
            DECODE( tp.organization_type,             --RS: publish into supplies table
                    2, s.routing_sequence_id,         --RS: it was taking from msc_process_efficiency before
                    NULL),
            'Y',
            s.transaction_id,
-- bugbug Is null ok for uom?
            NULL,
            s.sr_instance_id,
            s.schedule_priority,
            nvl(s.requested_completion_date, s.need_by_date)
      FROM  msc_trading_partners    tp,
            msc_parameters          param,
            msc_item_id_lid        item_lid,
            msc_supplies            s
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     item_lid.inventory_item_id = s.inventory_item_id
    AND     item_lid.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.release_status = 1;

    IF SQL%ROWCOUNT > 0
    THEN
        lv_loaded_jobs := SQL%ROWCOUNT;

    ELSE
        lv_loaded_jobs := 0;

    END IF;





    -- ------------------------------------------------------------------------
    -- Perform the wip discrete job mass load for the details
    -- ------------------------------------------------------------------------

    /* the details are populated, only if the implement date and quantity
       are the same as the planned date and quantity */

    /* OPERATIONS */
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
           (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            department_id,
            description,
            standard_operation_id,
            first_unit_start_date,
            first_unit_completion_date,
            last_unit_start_date,
            last_unit_completion_date,
            minimum_transfer_quantity,
            count_point_type,
            backflush_flag,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            operation_seq_id, --Outbound changes for XML
            SR_INSTANCE_ID)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            NULL,            --department_id,
            NULL,   --description,
            NULL,   --standard_operation_id,
            min(resreq.START_DATE),   --first_unit_start_date,
            min(resreq.START_DATE),   --first_unit_completion_date,
            max(resreq.END_DATE),     --last_unit_start_date,
            max(resreq.END_DATE),     --last_unit_completion_date,
            NULL,   --minimum_transfer_quantity,
            NULL,   --count_point_type,
            NULL,   --backflush_flag,
            SUBST_CHANGE,
            LT_OPERATION,
            2,
            1,
            resreq.operation_sequence_id, --Outbound changes for XML
            s.sr_instance_id
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_supplies            s
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1
    GROUP BY
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            NULL,            --department_id,
            LT_OPERATION,    --load_type,
            NULL,            --description,
            NULL,            --standard_operation_id,
            NULL,            --minimum_transfer_quantity,
            NULL,            --count_point_type,
            NULL,            --backflush_flag,
            resreq.operation_sequence_id,
            s.sr_instance_id;


    --DBMS_OUTPUT.PUT_LINE('OPERATION_RESOURCE');
 /* for bug: 2479630, modified the expression that is passed in the column: usage_rate_or_amount,
   to divide the resource_hours by cum. qty (which is equal to new_order_qty/cum. yield) and if that is null
    than apply the CY on new_order_qty. This logic to use cummulative_qty is added to remove the calc. errors */

    /* OPERATION RESOURCES */
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            alternate_num,
            resource_id_old,
            resource_id_new,
            usage_rate_or_amount,
            scheduled_flag,
            applied_resource_units,   --
            applied_resource_value,   --
            uom_code,
            basis_type,     --
            activity_id,    --
            autocharge_type,     --
            standard_rate_flag,  --
            start_date,
            completion_date,
            assigned_units,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            SR_INSTANCE_ID,
            operation_seq_id, --Outbound changes for XML
            FIRM_FLAG,
            resource_hours,
            department_id,
            -- added the following for dsr
            setup_id,
            group_sequence_id,
            group_sequence_number,
            batch_id,
            maximum_assigned_units,
            parent_seq_num,
	   resource_seq_num,
            schedule_seq_num)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            resreq.ALTERNATE_NUM,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
             /* for OPM orgs (tp.organization_type =2) we don't consider lv_inflate_wip */
             decode(resreq.parent_seq_num, null,
            (resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,
                            nvl(resreq.cummulative_quantity,
             (s.new_order_quantity/nvl(resreq.REVERSE_CUMULATIVE_YIELD,1) )
             ) )), resreq.usage_rate),     -- RS
            decode(nvl(resreq.schedule_flag,1),-23453,1,1,1,resreq.schedule_flag),
            NULL,
            NULL,
            v_hour_uom,
            resreq.basis_type,
            NULL,
            NULL,
            NULL,
            nvl(resreq.firm_start_date,resreq.START_DATE),
            nvl(resreq.firm_end_date,resreq.END_DATE),
            resreq.ASSIGNED_UNITS,
            decode(resreq.parent_seq_num,null,SUBST_CHANGE,SUBST_ADD),
            -- SUBST_CHANGE,
            LT_RESOURCE,
            2,
            1,
            NULL,
            s.sr_instance_id,
            resreq.operation_sequence_id, --Outbound changes for XML
            NVL(resreq.firm_flag, 0), -- if null, then default to not firm (0)
            resreq.resource_hours,
            resreq.department_id,
            resreq.setup_id,
            resreq.group_sequence_id,
            resreq.group_sequence_number,
            resreq.batch_number,
            resreq.maximum_assigned_units,
            resreq.parent_seq_num,
	    resreq.orig_resource_seq_num,
            resreq.resource_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_supplies            s,
            msc_department_resources mdr            --MN: "C" type  , can we just say mdr.plan_id = -1   ??
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     mdr.plan_id = -1
    AND     resreq.organization_id =mdr.organization_id
    AND     resreq.sr_instance_id = mdr.sr_instance_id
    AND     resreq.resource_id = mdr.resource_id
    AND     resreq.department_id=mdr.department_id
    AND     s.release_status = 1;


    --DBMS_OUTPUT.PUT_LINE('LOAD COMPONENTS');

 /* for bug: 2378484, added code to consider the  cum yield in the calc of qty_per_assembly */
    /* UPDATE EXISTING COMPONENTS                      *
     |    We should set inventory_item_id_new to NULL  |
     *                                                 */
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            inventory_item_id_old,
            inventory_item_id_new,
            basis_type,
            quantity_per_assembly,
            component_yield_factor,
            department_id,
            wip_supply_type,
            date_required,
            required_quantity,
            quantity_issued,
            supply_subinventory,
            supply_locator_id,
            mrp_net_flag,
            mps_required_quantity,
            mps_date_required,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
--            operation_seq_id, --Outbound changes for XML
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            nvl(md.op_seq_num,1),
            icomp.sr_inventory_item_id,
            decode(l_apps_ver,'4', null, '3',null,icomp.sr_inventory_item_id),
-- bugbug Is this the right way to compute basis_type?
            decode(md.component_scaling_type,1,NULL,md.component_scaling_type),
            TO_NUMBER(NULL),       --Quantity_per
-- bugbug Is this the right way to compute component_yield_factor?
            md.component_yield_factor,
            TO_NUMBER(NULL),       --Department_ID
            md.wip_supply_type,
            md.USING_ASSEMBLY_DEMAND_DATE,
            md.USING_REQUIREMENT_QUANTITY,
            0,
            TO_CHAR(NULL),     -- Sub Inventory
            TO_NUMBER(NULL),   -- Locator ID
            1,                 -- MRP_NET_FLAG
            md.USING_REQUIREMENT_QUANTITY,
            md.USING_ASSEMBLY_DEMAND_DATE,
            SUBST_CHANGE,
            LT_COMPONENT,
            2,
            1,
            TO_CHAR(NULL),
-- bugbug Should we check sys_items for uom_code?
            s.implement_uom_code,
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_system_items         icomp, -- bugbug ey, should this be msc_item_id_lid or msi?
            msc_demands             md,
            msc_parameters          param,
            msc_supplies            s
    WHERE
            tp.sr_tp_id= icomp.organization_id
    AND     tp.sr_instance_id= icomp.sr_instance_id
    AND     tp.partner_type=3
    AND     icomp.inventory_item_id = md.inventory_item_id -- added by ey
    AND     icomp.sr_instance_id    = md.sr_instance_id    -- added by ey
    AND     icomp.organization_id = md.organization_id
    AND     icomp.plan_id = -1
    AND     nvl(icomp.wip_supply_type,0) <> 6 -- PHANTOM , in the future, extraction should make sure to filter it out
    AND     md.PRIMARY_COMPONENT_ID is null
    AND     md.disposition_id= s.transaction_id
    AND     md.origination_type = 1
    AND     md.plan_id = arg_plan_id
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1;

    --Loading Co-products/by-products for OPM orgs
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            inventory_item_id_old,
            inventory_item_id_new,
            quantity_per_assembly,
            department_id,
            wip_supply_type,
            date_required,
            required_quantity,
            quantity_issued,
            supply_subinventory,
            supply_locator_id,
            mrp_net_flag,
            mps_required_quantity,
            mps_date_required,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            nvl(co.operation_seq_num,1),
            icomp.sr_inventory_item_id,
            decode(l_apps_ver,'4',null,'3',null,icomp.sr_inventory_item_id),
            TO_NUMBER(NULL),       --Quantity_per
            TO_NUMBER(NULL),       --Department_ID
            co.wip_supply_type,
            co.NEW_SCHEDULE_DATE,
            co.NEW_ORDER_QUANTITY,
            0,
            TO_CHAR(NULL),     -- Sub Inventory
            TO_NUMBER(NULL),   -- Locator ID
            1,                 -- MRP_NET_FLAG
            co.NEW_ORDER_QUANTITY,
            co.NEW_SCHEDULE_DATE,
            SUBST_CHANGE,
            LT_COMPONENT,
            2,
            1,
            TO_CHAR(NULL),
            s.implement_uom_code,                 -- bugbug MN: again is this correct?
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_item_id_lid        icomp,
            msc_supplies            co,
            msc_parameters          param,
            msc_supplies            s
    WHERE   tp.sr_tp_id             = s.organization_id
    AND     tp.sr_instance_id       = s.sr_instance_id
    AND     tp.partner_type         = 3
    AND     icomp.inventory_item_id = co.inventory_item_id
    AND     icomp.sr_instance_id    = co.sr_instance_id
    AND     co.sr_instance_Id       = s.sr_instance_Id
    AND     co.disposition_id       = s.transaction_id
    AND     co.plan_id              = s.plan_id
    AND     co.order_type           = 17        --Co-product /by-product
    AND     param.organization_id   = s.organization_id
    AND     param.sr_instance_id    = s.sr_instance_id
    AND     icomp.inventory_item_id   = s.inventory_item_id
    AND     s.transaction_id        = lv_transaction_id(j)
    AND     s.sr_instance_id        = lv_instance_id(j)
    AND     s.plan_id               = arg_plan_id
    AND     tp.organization_type    = 2
    AND     s.release_status = 1;

    --DBMS_OUTPUT.PUT_LINE('LOAD SUBSTITUTE COMPONENTS');
    /* SUBSTITUTE EXISTING COMPONENTS */
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            inventory_item_id_old,
            inventory_item_id_new,
            quantity_per_assembly,
            department_id,
            wip_supply_type,
            date_required,
            required_quantity,
            quantity_issued,
            supply_subinventory,
            supply_locator_id,
            mrp_net_flag,
            mps_required_quantity,
            mps_date_required,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
--            operation_seq_id, --Outbound changes for XML
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            nvl(md.op_seq_num,1),
            icomp.sr_inventory_item_id,
            sr_item.sr_inventory_item_id,
            bsub.usage_quantity,
            TO_NUMBER(NULL),       --Department_ID
            md.wip_supply_type,   -- bugbug if null get from msi?
            md.USING_ASSEMBLY_DEMAND_DATE,
            md.USING_REQUIREMENT_QUANTITY,
            0,
            TO_CHAR(NULL),     -- Sub Inventory
            TO_NUMBER(NULL),   -- Locator ID
            1,
            md.USING_REQUIREMENT_QUANTITY,
            md.USING_ASSEMBLY_DEMAND_DATE,
            SUBST_CHANGE,
            LT_COMPONENT,
            2,
            1,
            TO_CHAR(NULL),
--            md.operation_seq_id,
            s.implement_uom_code, -- bugbug again should fall back to sys_items?
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_item_id_lid         sr_item,
            msc_bom_components      subcomp,
            msc_component_substitutes bsub,
/*            msc_bom_components      bcomp, */
            msc_item_id_lid        icomp,
            msc_demands             md,
            msc_supplies            s

    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     sr_item.inventory_item_id= md.inventory_item_id
    AND     sr_item.sr_instance_id= md.sr_instance_id
    AND     subcomp.plan_id               = -1
    AND     subcomp.bill_sequence_id      = bsub.bill_sequence_id
    AND     subcomp.COMPONENT_SEQUENCE_ID = bsub.COMPONENT_SEQUENCE_ID
    AND     bsub.substitute_item_id = md.inventory_item_id
    AND     bsub.organization_id    = md.organization_id
    AND     bsub.plan_id = -1
    AND     subcomp.inventory_item_id = md.PRIMARY_COMPONENT_ID
    AND     subcomp.using_assembly_id=md.using_assembly_item_id
    AND     subcomp.sr_instance_id=s.sr_instance_Id
    AND     subcomp.sr_instance_id=bsub.sr_instance_Id
    AND     s.organization_id= md.organization_id
    AND     md.sr_instance_Id= s.sr_instance_Id
    AND     md.disposition_id= s.transaction_id
    AND     md.plan_id= s.plan_id
    AND     md.origination_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     md.PRIMARY_COMPONENT_ID is not null
    AND     icomp.inventory_item_id= md.PRIMARY_COMPONENT_ID
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     rownum=1
    AND     s.release_status = 1;



 -- RESOURCE USAGE
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            alternate_num,
            resource_id_old,
            resource_id_new,
            usage_rate_or_amount,
            scheduled_flag,
            applied_resource_units,   --
            applied_resource_value,   --
            uom_code,
            basis_type,     --
            activity_id,    --
            autocharge_type,     --
            standard_rate_flag,  --
            start_date,
            completion_date,
            assigned_units,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            SR_INSTANCE_ID,
            operation_seq_id, --Outbound changes for XML
            resource_seq_num,
            schedule_seq_num,
            FIRM_FLAG,
            department_id,
            resource_hours,
            parent_seq_num)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            resreq.ALTERNATE_NUM,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
	    resreq.usage_rate,
            decode(nvl(resreq.schedule_flag,1),-23453,1,1,1,resreq.schedule_flag),
            NULL,
            NULL,
            v_hour_uom,
            resreq.basis_type,
            NULL,
            NULL,
            NULL,
            nvl(resreq.firm_start_date,resreq.START_DATE),
            nvl(resreq.firm_end_date,resreq.END_DATE),
            resreq.ASSIGNED_UNITS,
            SUBST_CHANGE,
            LT_RESOURCE_USAGE,
            2,
            1,
            NULL,
            s.sr_instance_id,
            resreq.operation_sequence_id, --Outbound changes for XML
            resreq.orig_resource_seq_num,
            resreq.resource_seq_num,
            decode(nvl(resreq.firm_flag,0),0,2,1),
            resreq.department_id,
            resreq.resource_hours,
            resreq.parent_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_supplies            s,
            msc_department_resources mdr
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 1
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     mdr.plan_id = -1
    AND     resreq.organization_id =mdr.organization_id
    AND     resreq.sr_instance_id = mdr.sr_instance_id
    AND     resreq.resource_id = mdr.resource_id
    AND     resreq.department_id=mdr.department_id
    AND     s.release_status = 1;
    --AND     tp.organization_type = 2;

   -- dsr starts here
   -- print_debug_info('OPERATION RESOURCE_INSTANCES');
   -- OPERATION RESOURCE_INSTANCES

    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            resource_id_old,
            resource_id_new,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            resource_hours,
            department_id,
	    SERIAL_NUMBER,
            group_sequence_id,
            group_sequence_number,
            batch_id,
            resource_seq_num,
            schedule_seq_num,
            assigned_units,
            parent_seq_num
 )
    SELECT
           SYSDATE,
           arg_user_id,
           s.last_update_login,
           SYSDATE,
           arg_user_id,
           tp.organization_type,
           s.organization_id,
           arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
           resreq.resource_id,
           resreq.resource_id,
           dep_res_inst.RES_INSTANCE_ID,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD,
           LT_RESOURCE_INSTANCE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.resource_hours,
           resreq.department_id,
           dep_res_inst.serial_number,
           resreq.group_sequence_id,
           resreq.group_sequence_number,
           res_instreq.batch_number,
           nvl(resreq.orig_resource_seq_num,resreq.resource_seq_num),
           resreq.resource_seq_num,
           1 ,
           resreq.parent_seq_num
    FROM
          msc_trading_partners   tp,
          msc_resource_requirements resreq,
          msc_resource_instance_reqs res_instreq,
          msc_dept_res_instances dep_res_inst,
          msc_supplies            s
    WHERE
         tp.sr_tp_id=s.organization_id
 AND     tp.sr_instance_id= s.sr_instance_id
 AND     tp.partner_type=3
 AND     resreq.sr_instance_id= s.sr_instance_id
 AND     resreq.organization_id= s.organization_id
 AND     resreq.supply_id = s.transaction_id
 AND     resreq.plan_id   = s.plan_id
 AND     resreq.resource_seq_num = res_instreq.resource_seq_num
 AND     resreq.operation_seq_num = res_instreq.operation_seq_num
 AND     resreq.resource_id = res_instreq.resource_id
 AND     resreq.supply_id = res_instreq.supply_id
 AND     resreq.sr_instance_id = res_instreq.sr_instance_id
 AND     resreq.plan_id = res_instreq.plan_id
 AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
 AND     resreq.start_date = res_instreq.start_date
 AND     resreq.parent_id   = 2
 AND     resreq.resource_id <> -1
 AND     resreq.department_id <> -1
 AND     dep_res_inst.plan_id = -1                                 --MN: Again, Can we do this?
 AND     res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
 AND     res_instreq.department_id = dep_res_inst.department_id
 AND     res_instreq.resource_id = dep_res_inst.resource_id
 AND     res_instreq.serial_number = dep_res_inst.serial_number
 AND     res_instreq.res_instance_id = dep_res_inst.res_instance_id
 AND     s.transaction_id= lv_transaction_id(j)
 AND     s.sr_instance_id= lv_instance_id(j)
 AND     s.plan_id= arg_plan_id
 AND     lv_agg_details(j) = 1
 AND     s.release_status = 1;



   --print_debug_info('load_wip_discrete_jobs# rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = ' || SQL%ROWCOUNT);
    -- RESOURCE INSTANCE USAGES
   --print_debug_info('RESOURCE INSTANCE USAGES ');

	FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            resource_id_old,
	    resource_id_new,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            FIRM_FLAG,
            resource_hours,
            department_id,
            serial_number,
            resource_seq_num,
            schedule_seq_num,
            assigned_units,
            parent_seq_num
 )
    SELECT
           SYSDATE,
           arg_user_id,
           s.last_update_login,
           SYSDATE,
           arg_user_id,
           tp.organization_type,
           s.organization_id,
           arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
           resreq.RESOURCE_ID,
           resreq.RESOURCE_ID,
           res_instreq.RES_INSTANCE_ID,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD,
           LT_RESOURCE_INST_USAGE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.firm_flag,
           res_instreq.resource_instance_hours,
           resreq.department_id,
           res_instreq.serial_number,
           resreq.orig_resource_seq_num,
           resreq.resource_seq_num,
           1 ,
           resreq.parent_seq_num
  FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_resource_instance_reqs res_instreq,
           msc_supplies            s
    WHERE
            tp.sr_tp_id=s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.resource_seq_num = res_instreq.resource_seq_num
    AND     resreq.operation_seq_num = res_instreq.operation_seq_num
    AND     resreq.resource_id = res_instreq.resource_id
    AND     resreq.supply_id = res_instreq.supply_id
    AND     resreq.sr_instance_id = res_instreq.sr_instance_id
    AND     resreq.plan_id = res_instreq.plan_id
    AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
    AND     resreq.start_date = res_instreq.start_date
    AND     resreq.parent_id   = 1
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     res_instreq.plan_id = s.plan_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1;
   -- AND     tp.organization_type = 2

-- bugbug Do we need to add the charges handling code?
    RETURN lv_loaded_jobs;

END load_wip_discr_jobs_ps;



FUNCTION reschedule_wip_discr_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER
IS

   lv_resched_jobs NUMBER;


   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 --TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;

   lv_transaction_id           NumTab;
   lv_instance_id              NumTab;
   lv_job_count                NUMBER;
   lv_plan_id                  NumTab;
   lv_org_id                   Numtab;
   lv_agg_details              NumTab;

BEGIN

  -- we release the discrete job, only if it doesn't use aggregate resources
  -- bug 1252659 fix, replace rowid by
  --       (transaction_id,sr_instance_id,plan_id)


   SELECT s.transaction_id,
          s.sr_instance_id,
          s.organization_id,
          s.plan_id
     BULK COLLECT
     INTO lv_transaction_id,
          lv_instance_id,
          lv_org_id,
          lv_plan_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs,
          msc_plans mp
    WHERE s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = arg_plan_id
    AND   orgs.plan_id = arg_plan_id
    AND   orgs.organization_id = arg_owning_org_id
    AND   orgs.owning_sr_instance = arg_owning_instance
    AND   ( orgs.planned_organization= arg_log_org_id
            OR arg_log_org_id = arg_owning_org_id )
--   orgs.planned_organization =
--                    decode( arg_log_org_id,
--                            arg_owning_org_id, orgs.planned_organization,
--                            arg_log_org_id)
    AND   orgs.sr_instance_id = arg_org_instance
    AND   s.load_type = WIP_DIS_MASS_RESCHEDULE
    AND   mp.plan_id = s.plan_id
    AND   s.release_status = 1;

-- ey, no need to pass 'arg_mode is null', this condition and this   parameter can be removed.   - MN: done






    lv_job_count:= SQL%ROWCOUNT;

    -- -----------------------------------------------------------------------
    -- Perform the wip discrete job mass load
    -- -----------------------------------------------------------------------
    --    Due to we only give PLANNED components, BILL_RTG_EXPLOSION_FLAG
    --    is set to 'Y'.

    --DBMS_OUTPUT.PUT_LINE('LOAD_JOB');




    FOR k in 1..lv_job_count
       Loop
                Begin
                  SELECT 2
                  Into lv_agg_details(k)
                  FROM msc_department_resources deptres,
                       msc_resource_requirements resreq
                 WHERE resreq.sr_instance_id= lv_instance_id(k)
                   AND resreq.supply_id = lv_transaction_id(k)
                   AND resreq.organization_id= lv_org_id(k)
                   AND resreq.plan_id   = lv_plan_id(k)
                   AND resreq.parent_id   = 2
                   AND deptres.plan_id  = -1            --MN:   Is this correct?????
                   AND deptres.sr_instance_id= resreq.sr_instance_id
                   AND deptres.resource_id= resreq.resource_id
                   AND deptres.department_id= resreq.department_id
                   AND deptres.organization_id= resreq.organization_id
                   AND deptres.aggregate_resource_flag= 1
                   AND rownum=1;
                  Exception
                  When no_data_found
                  then
                  lv_agg_details(k) := 1;
                  End;

       End Loop;





    FORALL j IN 1..lv_job_count
    INSERT INTO msc_wip_job_schedule_interface
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            group_id,
            source_code,
            organization_id,
            organization_type,
            status_type,
            load_type,
            last_unit_completion_date,
            first_unit_start_date,
            bom_revision_date,
            routing_revision_date,
            job_name,
            firm_planned_flag,
            start_quantity,   -- bug 1229891: net_quantity
            net_quantity,
            wip_entity_id,
            demand_class,
            project_id,
            task_id,
	    schedule_group_id,
	    build_sequence,
            line_id,
            alternate_bom_designator,
	    alternate_routing_designator,
	    end_item_unit_number,
            process_phase,
	    process_status,
            BILL_RTG_EXPLOSION_FLAG,
            HEADER_ID,
            SR_INSTANCE_ID,
            uom_code, --Outbound Changes for XML
            PRIMARY_ITEM_ID,
            source_line_id, --Outbound Changes for XML
            schedule_priority, --dsr
            requested_completion_date --dsr
            )
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            decode(tp.organization_type,2,s.creation_date,SYSDATE),
            arg_user_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id), --for cmro--arg_wip_group_id,
            'MSC',
            s.organization_id,                --MN: is this correct? what    is owning_org_id?  -- ey, I think this one should be 's.organization_id'  - done
            tp.organization_type,
            null,               --MN: Rongming's pseudo code
            3,
            s.implement_date,
            s.new_wip_Start_Date,
            NULL,
            NULL,
            s.implement_job_name,
            s.implement_firm,
            DECODE( tp.organization_type,
                    1, DECODE(s.new_order_quantity,
                              s.implement_quantity, TO_NUMBER(NULL),
                        ((s.new_order_quantity + NVL(s.qty_completed, 0) +
                          NVL(s.qty_scrapped, 0)) -
                         (s.new_order_quantity - s.implement_quantity))),
                    NULL),
            DECODE( tp.organization_type,
                    2, DECODE(s.new_order_quantity,
                              s.implement_quantity, TO_NUMBER(NULL),
                        ((s.new_order_quantity + NVL(s.qty_completed, 0) +
                          NVL(s.qty_scrapped, 0)) -
                         (s.new_order_quantity - s.implement_quantity))),
                    (s.implement_quantity + NVL(s.qty_completed, 0) + NVL(s.qty_scrapped, 0))),
            s.disposition_id,
            s.implement_demand_class,
            s.implement_project_id,
            s.implement_task_id,
	    s.implement_schedule_group_id,
            s.implement_build_sequence,
            s.implement_line_id,
       	    s.implement_alternate_bom,
	    s.implement_alternate_routing,
	    s.implement_unit_number,
            2,
	    1,
            'Y',
            s.transaction_id,
            s.sr_instance_id,
            s.implement_uom_code,       -- bugbug MN:  NOTE: this can not be null
            item_lid.sr_inventory_item_id,            -- msi.sr_inventory_item_id, -- ey, if you don't flush  msc_system_items, you need to somehow pass the   source_inventory_item_id to here   MN: use msc_iten_id_lid
            s.transaction_id, --Outbound Changes for XML
            s.schedule_priority, --dsr
            s.requested_completion_date -- dsr
    FROM    msc_trading_partners tp,
            msc_parameters param,
            msc_supplies     s,
            msc_item_id_lid item_lid,
            msc_plan_organizations_v orgs
    WHERE   tp.sr_tp_id= s.organization_id       --MN: again, is this     correct ? -- ey, should be s.organization_id  -- MN: done
    AND     item_lid.sr_instance_id =  s.sr_instance_id        --MN:: added
    AND     item_lid.inventory_item_id = s.inventory_item_id
    AND     tp.sr_instance_id= s.sr_instance_id               --MN:  again, is this correct ? -- ey, should be s.sr_instance_id   -- MN:done
    AND     tp.partner_type=3
    AND     param.organization_id = s.organization_id               --MN:     again, is this correct ? -- ey, s.organization_id   -- MN: done
    AND    param.sr_instance_id = s.sr_instance_id                --MN:     again, is this correct ? -- ey, s.sr_instance_id  --MN: done
    AND    s.organization_id = orgs.planned_organization
    AND    s.sr_instance_id = orgs.sr_instance_id
    AND    s.plan_id = orgs.plan_id
    AND    orgs.organization_id = arg_owning_org_id
    AND    orgs.owning_sr_instance = arg_owning_instance
    AND    orgs.plan_id = arg_plan_id
    AND    orgs.planned_organization = decode(arg_log_org_id,
                                         arg_owning_org_id, orgs.planned_organization,
                                          arg_log_org_id)
    AND    orgs.sr_instance_id = arg_org_instance
    AND     (s.load_type = WIP_DIS_MASS_RESCHEDULE)
-- ey, remove arg_mode is null  -- MN: done
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.release_status = 1;

    IF SQL%ROWCOUNT > 0
    THEN
        lv_resched_jobs := SQL%ROWCOUNT;

    ELSE
        lv_resched_jobs := 0;

    END IF;

    -- ------------------------------------------------------------------------
    -- Perform the wip discrete job mass resched for the details
    -- ------------------------------------------------------------------------

    -- the details are populated, only if the implement date and quantity
    -- are the same as the planned date and quantity

    -- OPERATIONS
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
           (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            department_id,
            description,
            standard_operation_id,
            first_unit_start_date,
            first_unit_completion_date,
            last_unit_start_date,
            last_unit_completion_date,
            minimum_transfer_quantity,
            count_point_type,
            backflush_flag,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            SR_INSTANCE_ID,
            operation_seq_id, --Outbound Changes for XML
            WIP_ENTITY_ID)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id) ,--for cmro --arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            NULL,            --department_id,
            DECODE(s.order_type,70,
                   (decode(s.maintenance_object_source,2,
                    resreq.operation_name,NULL)),
                    NULL),            --description,
            NULL,   --standard_operation_id,
            min(resreq.START_DATE),   --first_unit_start_date,
            min(resreq.START_DATE),   --first_unit_completion_date,
            max(resreq.END_DATE),     --last_unit_start_date,
            max(resreq.END_DATE),     --last_unit_completion_date,
            NULL,   --minimum_transfer_quantity,
            NULL,   --count_point_type,
            NULL,   --backflush_flag,
            SUBST_CHANGE,
            LT_OPERATION,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id, --Outbound Changes for XML
            s.disposition_id
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_supplies            s
    WHERE   tp.sr_tp_id= s.organization_id            --MN: again, is    this correct? -- ey, correct
    AND     tp.sr_instance_id= s.sr_instance_id            --MN:    again, is this correct? -- ey, correct
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     param.organization_id = s.organization_id            --MN:    again, is this correct? -- ey, correct
    AND     param.sr_instance_id  = s.sr_instance_id          --MN:    again, is this correct? -- ey, correct
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1
    GROUP BY
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id) ,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            NULL,            --department_id,
            LT_OPERATION,    --load_type,
            DECODE(s.order_type,70,
                   (decode(s.maintenance_object_source,2,
                    resreq.operation_name,NULL)),
                    NULL),
            NULL,            --standard_operation_id,
            NULL,            --minimum_transfer_quantity,
            NULL,            --count_point_type,
            NULL,            --backflush_flag,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            s.disposition_id;


    --DBMS_OUTPUT.PUT_LINE('OPERATION_RESOURCE');

    -- OPERATION RESOURCES
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            alternate_num,
            resource_id_old,
            resource_id_new,
            usage_rate_or_amount,
            scheduled_flag,
            applied_resource_units,   --
            applied_resource_value,   --
            uom_code,
            basis_type,     --
            activity_id,    --
            autocharge_type,     --
            standard_rate_flag,  --
            start_date,
            completion_date,
            assigned_units,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            SR_INSTANCE_ID,
            operation_seq_id, -- Outbound Changes for XML
            wip_entity_id,
            resource_hours,
            department_id,
            firm_flag,       --dsr
            setup_id,
            group_sequence_id,
            group_sequence_number,
            batch_id,
            maximum_assigned_units,
            parent_seq_num,
            resource_seq_num,
            schedule_seq_num)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            resreq.ALTERNATE_NUM,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
            decode(resreq.parent_seq_num, null, decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,decode(s.new_order_quantity,0,1,s.new_order_quantity))), resreq.usage_rate),
            decode(nvl(resreq.schedule_flag,1),-23453,1,1,1,resreq.schedule_flag),
            NULL,
            NULL,
            v_hour_uom,
            resreq.basis_type,
            NULL,
            NULL,
            NULL,
            nvl(resreq.firm_start_date,resreq.START_DATE),
            nvl(resreq.firm_end_date,resreq.END_DATE),
            resreq.ASSIGNED_UNITS,
            decode(resreq.parent_seq_num,null,SUBST_CHANGE,SUBST_ADD),
            -- SUBST_CHANGE,
            LT_RESOURCE,
            2,
            1,
            NULL,
            s.sr_instance_id,
            resreq.operation_sequence_id, -- Outbound Changes for XML
            s.disposition_id,
            resreq.resource_hours,
            resreq.department_id,
            resreq.firm_flag,
            resreq.setup_id,
            resreq.group_sequence_id,
            resreq.group_sequence_number,
            resreq.batch_number,
            resreq.maximum_assigned_units,
            resreq.parent_seq_num,
            resreq.orig_resource_seq_num,
            resreq.resource_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_supplies            s
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     param.organization_id = s.organization_id
    --MN: again, is this correct? -- ey, correct
    AND     param.sr_instance_id  = s.sr_instance_id            --MN:    again, is this correct? -- ey, correct
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1;


    --DBMS_OUTPUT.PUT_LINE('LOAD COMPONENTS');

    /* UPDATE EXISTING COMPONENTS                      *
     |    We should set inventory_item_id_new to NULL  |
     *                                                 */
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            inventory_item_id_old,
            inventory_item_id_new,
            basis_type,
            quantity_per_assembly,
            component_yield_factor,
            department_id,
            wip_supply_type,
            date_required,
            required_quantity,
            quantity_issued,
            supply_subinventory,
            supply_locator_id,
            mrp_net_flag,
            mps_required_quantity,
            mps_date_required,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            SR_INSTANCE_ID,
--            operation_seq_id, -- Outbound Changes for XML
            uom_code, --Outbound Changes for XML
            wip_entity_id)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
            s.transaction_id,
            nvl(md.op_seq_num,1),
            msi.sr_inventory_item_id,  -- bugbug MN: again, is this    correct? -- ey, no, this should be the source item id for the item  in msc_demands
            decode(l_apps_ver,'3',null,msi.sr_inventory_item_id),
    -- bugbug MN: again, is this correct? -- ey, no, this should be the source    item id for the item in msc_demands
            decode(md.component_scaling_type,1,NULL,md.component_scaling_type),
            decode(l_apps_ver,'4',TO_NUMBER(NULL),'3',TO_NUMBER(NULL),(md.USING_REQUIREMENT_QUANTITY/s.implement_quantity)),
            md.component_yield_factor, -- bugbug is this correct?
            TO_NUMBER(NULL),       --Department_ID
            NVL(MSC_REL_PLAN_PUB.GET_WIP_SUPPLY_TYPE(s.plan_id, s.sr_instance_id,s.process_seq_id,
                                    s.inventory_item_id,md.inventory_item_id,s.organization_id),
                    msi.wip_supply_type),-- ey, see comment below   for the same field
            md.USING_ASSEMBLY_DEMAND_DATE,
            decode(l_apps_ver,'4',TO_NUMBER(NULL),'3',TO_NUMBER(NULL),md.USING_REQUIREMENT_QUANTITY),
            TO_NUMBER(NULL),  --quantity_issued
            TO_CHAR(NULL),     -- Sub Inventory
            TO_NUMBER(NULL),   -- Locator ID
            1,                 -- MRP_NET_FLAG
            decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),md.USING_REQUIREMENT_QUANTITY),
            md.USING_ASSEMBLY_DEMAND_DATE,
            SUBST_CHANGE,
            LT_COMPONENT,
            2,
            1,
            TO_CHAR(NULL),
            s.sr_instance_id,
--            md.operation_seq_id,
            s.implement_uom_code,               -- bugbug MN: again, is this correct?
            s.disposition_id
      FROM  msc_trading_partners    tp,
            msc_demands             md,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
-- bugbug Is this join correct?
    WHERE   tp.sr_tp_id= msi.organization_id -- ey, should be s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id -- ey, s.sr_instance_id
    AND     tp.partner_type=3
    AND     s.inventory_item_id= md.inventory_item_id
    --MN: again, is this correct? -- /* ey, no, this link should be    removed, the original link is to find the source item_id for the item in msc_demands */
    AND     s.organization_id= md.organization_id             --MN:    again, is this correct? -- ey, no, this link should be
    AND     s.sr_instance_id= md.sr_instance_id                 --MN:    again, is this correct? -- ey, no, this link should be
    AND     nvl(md.wip_supply_type,0) <> 6 -- ey, you need to find    the wip_supply_type for the item_id in msc_demands
    AND     md.PRIMARY_COMPONENT_ID is null
    AND     md.sr_instance_id= s.sr_instance_id
    AND     md.disposition_id= s.transaction_id
    AND     md.plan_id= s.plan_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = -1
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     msi.organization_id = s.organization_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1;



    --Load Co-product/by-product component details

    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            inventory_item_id_old,
            inventory_item_id_new,
            quantity_per_assembly,
            department_id,
            wip_supply_type,
            date_required,
            required_quantity,
            quantity_issued,
            supply_subinventory,
            supply_locator_id,
            mrp_net_flag,
            mps_required_quantity,
            mps_date_required,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            SR_INSTANCE_ID,
--            operation_seq_id, -- Outbound Changes for XML
            uom_code, --Outbound Changes for XML
            wip_entity_id)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
            s.transaction_id,
            nvl(co.operation_seq_num,1),
            icomp.sr_inventory_item_id, -- ey, source_item_id for item    in co
            decode(l_apps_ver,'4',to_number(null),'3',null,icomp.sr_inventory_item_id),
            decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),(co.new_order_quantity/s.implement_quantity)),
            TO_NUMBER(NULL),       --Department_ID
            co.wip_supply_type,
            /*NVL(MSC_REL_PLAN_PUB.GET_WIP_SUPPLY_TYPE(s.plan_id, s.sr_instance_id,s.process_seq_id,
                                    s.inventory_item_id,co.inventory_item_id,s.organization_id,
                                   md.wip_supply_type), -- ey, wip_supply_type for   */
            co.new_schedule_date,
            decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),co.new_order_quantity),
            TO_NUMBER(NULL),  --quantity_issued
            TO_CHAR(NULL),     -- Sub Inventory
            TO_NUMBER(NULL),   -- Locator ID
            1,                 -- MRP_NET_FLAG
            decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),co.new_order_quantity),
            co.new_schedule_date,
            SUBST_CHANGE,
            LT_COMPONENT,
            2,
            1,
            TO_CHAR(NULL),
            s.sr_instance_id,
            s.implement_uom_code,       -- bugbug MN: again, is this correct?
    -- ey, need to default it from uom_code for the item from    msc_supplies s
            s.disposition_id
      FROM  msc_trading_partners    tp,
            msc_supplies            co,
            msc_parameters          param,
            msc_item_id_lid         icomp,
            msc_supplies            s
    WHERE   tp.sr_tp_id             = s.organization_id
    --MN: again, is this correct? -- ey, correct
    AND     tp.sr_instance_id       = s.sr_instance_id        --MN:    again, is this correct? -- ey, correct
    AND     tp.partner_type         = 3
    AND     co.sr_instance_id       = s.sr_instance_id
    AND     co.disposition_id       = s.transaction_id
    AND     co.plan_id              = s.plan_id
    AND     co.order_type           = 14              -- Discrete Job Co-products/by-products.
    AND     icomp.inventory_item_id = s.inventory_item_id
    AND     icomp.sr_instance_id =  s.sr_instance_id
    AND     param.organization_id   = s.organization_id -- ey, s.organization_id
    AND     param.sr_instance_id    = s.sr_instance_id -- ey, s.sr_instance_id
    AND     s.transaction_id        = lv_transaction_id(j)
    AND     s.sr_instance_id        = lv_instance_id(j)
    AND     s.plan_id               = arg_plan_id
    AND     lv_agg_details(j)       = 1
    AND     tp.organization_type    = 2
    AND     s.release_status = 1;



  --DBMS_OUTPUT.PUT_LINE('LOAD SUBSTITUTE COMPONENTS');
    /* SUBSTITUTE EXISTING COMPONENTS ---------AKSHYA */
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
            (last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            inventory_item_id_old,
            inventory_item_id_new,
            quantity_per_assembly,
            department_id,
            wip_supply_type,
            date_required,
            required_quantity,
            quantity_issued,
            supply_subinventory,
            supply_locator_id,
            mrp_net_flag,
            mps_required_quantity,
            mps_date_required,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
--            operation_seq_id, --Outbound changes for XML
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
            s.transaction_id,
            nvl(md.op_seq_num,1),
            icomp.sr_inventory_item_id,
            sr_item.sr_inventory_item_id,
            bsub.usage_quantity,
            TO_NUMBER(NULL),       --Department_ID
            md.wip_supply_type,   -- bugbug if null get from msi?
            md.USING_ASSEMBLY_DEMAND_DATE,
            md.USING_REQUIREMENT_QUANTITY,
            0,
            TO_CHAR(NULL),     -- Sub Inventory
            TO_NUMBER(NULL),   -- Locator ID
            1,
            md.USING_REQUIREMENT_QUANTITY,
            md.USING_ASSEMBLY_DEMAND_DATE,
            SUBST_CHANGE,
            LT_COMPONENT,
            2,
            1,
            TO_CHAR(NULL),
--            md.operation_seq_id,
            s.implement_uom_code, -- bugbug again should fall back to sys_items?
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_item_id_lid         sr_item,
            msc_bom_components      subcomp,
            msc_component_substitutes bsub,
/*            msc_bom_components      bcomp, */
            msc_item_id_lid        icomp,
            msc_demands             md,
            msc_supplies            s

    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     sr_item.inventory_item_id= md.inventory_item_id
    AND     sr_item.sr_instance_id= md.sr_instance_id
    AND     subcomp.plan_id               = -1
    AND     subcomp.bill_sequence_id      = bsub.bill_sequence_id
    AND     subcomp.COMPONENT_SEQUENCE_ID = bsub.COMPONENT_SEQUENCE_ID
    AND     bsub.substitute_item_id = md.inventory_item_id
    AND     bsub.organization_id    = md.organization_id
    AND     bsub.plan_id = -1
    AND     subcomp.inventory_item_id = md.PRIMARY_COMPONENT_ID
    AND     subcomp.using_assembly_id=md.using_assembly_item_id
    AND     subcomp.sr_instance_id=s.sr_instance_Id
    AND     subcomp.sr_instance_id=bsub.sr_instance_Id
    AND     s.organization_id= md.organization_id
    AND     md.sr_instance_Id= s.sr_instance_Id
    AND     md.disposition_id= s.transaction_id
    AND     md.plan_id= s.plan_id
    AND     md.origination_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     md.PRIMARY_COMPONENT_ID is not null
    AND     icomp.inventory_item_id= md.PRIMARY_COMPONENT_ID
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     rownum=1
    AND     s.release_status = 1;

    --DBMS_OUTPUT.PUT_LINE('RESOURCE_USAGE');

    -- RESOURCE USAGE
    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            alternate_num,
            resource_id_old,
            resource_id_new,
            usage_rate_or_amount,
            scheduled_flag,
            applied_resource_units,   --
            applied_resource_value,   --
            uom_code,
            basis_type,     --
            activity_id,    --
            autocharge_type,     --
            standard_rate_flag,  --
            start_date,
            completion_date,
            assigned_units,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
	    process_phase,
	    process_status,
            description,
            SR_INSTANCE_ID,
            operation_seq_id, -- Outbound Changes for XML
            wip_entity_id,
            department_id,
            resource_hours,
            resource_seq_num,
            schedule_seq_num,
            parent_seq_num)
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            tp.organization_type,
            s.organization_id,
            decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
            s.transaction_id,
            resreq.OPERATION_SEQ_NUM,
            resreq.ALTERNATE_NUM,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
            decode(resreq.parent_seq_num, null, decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,decode(s.new_order_quantity,0,1,s.new_order_quantity))), resreq.usage_rate),
            decode(nvl(resreq.schedule_flag,1),-23453,1,1,1,resreq.schedule_flag),
            NULL,
            NULL,
            v_hour_uom,
            resreq.basis_type,
            NULL,
            NULL,
            NULL,
            nvl(resreq.firm_start_date,resreq.START_DATE),
            nvl(resreq.firm_end_date,resreq.END_DATE),
            resreq.ASSIGNED_UNITS,
            SUBST_CHANGE,
            LT_RESOURCE_USAGE,
            2,
            1,
            NULL,
            s.sr_instance_id,
            resreq.operation_sequence_id, -- Outbound Changes for XML
            s.disposition_id,
            resreq.department_id,
            resreq.resource_hours,
            resreq.orig_resource_seq_num,
            resreq.resource_seq_num,
            resreq.parent_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_supplies            s
    WHERE   tp.sr_tp_id= s.organization_id
    AND     tp.sr_instance_id=s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id  = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     s.release_status = 1

    AND     lv_agg_details(j) = 1
    AND     tp.organization_type IN (1, 2);  -- 1 - discrete wip org; 2 - opm org


-- ey, do we need this in 11.5.10, do we have resource instance in 11.5.10?
    -- dsr starts here
    -- print_debug_info('OPERATION RESOURCE_INSTANCES');
	-- OPERATION RESOURCE_INSTANCES

    FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            resource_id_old, -- rawasthi
	    resource_id_new,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            resource_hours,
            department_id,
	    SERIAL_NUMBER,
            group_sequence_id,
            group_sequence_number,
            batch_id,
            resource_seq_num
            , schedule_seq_num
            , wip_entity_id -- for reschedule
            , parent_seq_num
 )
    SELECT
          SYSDATE,
          arg_user_id,
          s.last_update_login,
          SYSDATE,
          arg_user_id,
          tp.organization_type,
          s.organization_id,
          decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
          s.transaction_id,
          resreq.OPERATION_SEQ_NUM,
          resreq.resource_id,
          resreq.resource_id,
          res_instreq.RES_INSTANCE_ID , -- RS
          nvl(resreq.firm_start_date,res_instreq.START_DATE),
          nvl(resreq.firm_end_date,res_instreq.END_DATE),
          SUBST_ADD,
          LT_RESOURCE_INSTANCE,
          2,
          1,
          s.sr_instance_id,
          resreq.operation_sequence_id,
          resreq.resource_hours,
          resreq.department_id,
          res_instreq.serial_number, -- RS
          resreq.group_sequence_id,
          resreq.group_sequence_number,
          res_instreq.batch_number,
          resreq.orig_resource_seq_num,
          resreq.resource_seq_num
          , s.disposition_id -- for reschedule
          , resreq.parent_seq_num
   FROM
          msc_trading_partners   tp,
          msc_resource_requirements resreq,
          msc_resource_instance_reqs res_instreq,
          msc_supplies            s
    WHERE
         tp.sr_tp_id=s.organization_id
 AND     tp.sr_instance_id= s.sr_instance_id
 AND     tp.partner_type=3
 AND     resreq.sr_instance_id= s.sr_instance_id
 AND     resreq.organization_id= s.organization_id
 AND     resreq.supply_id = s.transaction_id
 AND     resreq.plan_id   = s.plan_id
 AND     resreq.resource_seq_num = res_instreq.resource_seq_num
 AND     resreq.operation_seq_num = res_instreq.operation_seq_num
 AND     resreq.resource_id = res_instreq.resource_id
 AND     resreq.supply_id = res_instreq.supply_id
 AND     resreq.sr_instance_id = res_instreq.sr_instance_id
 AND     resreq.plan_id = res_instreq.plan_id
 AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
 AND     resreq.start_date = res_instreq.start_date
 AND     resreq.parent_id   = 2
 AND     resreq.resource_id <> -1
 AND     resreq.department_id <> -1
 AND     res_instreq.plan_id = s.plan_id
 AND     s.transaction_id= lv_transaction_id(j)
 AND     s.sr_instance_id= lv_instance_id(j)
 AND     s.plan_id= arg_plan_id
 AND     lv_agg_details(j) = 1
 AND     s.release_status = 1
    ;

-- print_debug_info('reschedule_wip_discrete_jobs: 888 sql%rowcount = '|| SQL%ROWCOUNT);
    -- RESOURCE INSTANCE USAGES
-- print_debug_info('RESOURCE INSTANCE USAGES');
	FORALL j IN 1..lv_job_count
    INSERT INTO MSC_WIP_JOB_DTLS_INTERFACE
          ( last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            organization_type,
            organization_id,
            group_id,
            parent_header_id,
            operation_seq_num,
            resource_id_old, -- rawasthi
	    resource_id_new,
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            FIRM_FLAG,
            resource_hours,
            department_id,
            serial_number,
            resource_seq_num,
            schedule_seq_num
           , wip_entity_id -- for reschedule
	   , assigned_units
	  ,parent_seq_num
 )
    SELECT
           SYSDATE,
           arg_user_id,
           s.last_update_login,
           SYSDATE,
           arg_user_id,
           tp.organization_type,
           s.organization_id,
           decode(s.maintenance_object_source,2,(decode (s.order_type,70,arg_wip_group_id*-1,arg_wip_group_id)),arg_wip_group_id),--for cmro --arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
           resreq.RESOURCE_ID,
           resreq.RESOURCE_ID,
           res_instreq.RES_INSTANCE_ID ,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD,
           LT_RESOURCE_INST_USAGE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.firm_flag,
           res_instreq.resource_instance_hours,
           resreq.department_id,
           res_instreq.serial_number,
           resreq.orig_resource_seq_num,
           resreq.resource_seq_num
           , s.disposition_id -- for reschedule
          , 1 -- jguo
         ,resreq.parent_seq_num
    FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_resource_instance_reqs res_instreq,
           msc_supplies            s
    WHERE
            tp.sr_tp_id=s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.resource_seq_num = res_instreq.resource_seq_num
    AND     resreq.operation_seq_num = res_instreq.operation_seq_num
    AND     resreq.resource_id = res_instreq.resource_id
    AND     resreq.supply_id = res_instreq.supply_id
    AND     resreq.sr_instance_id = res_instreq.sr_instance_id
    AND     resreq.plan_id = res_instreq.plan_id
    AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
    AND     resreq.start_date = res_instreq.start_date
    AND     resreq.parent_id   = 1
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     res_instreq.plan_id = s.plan_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_agg_details(j) = 1
    AND     s.release_status = 1;

-- bugbug should we add resource charges handling?




    RETURN lv_resched_jobs;

END reschedule_wip_discr_jobs_ps;


END MSC_REL_PS_PLAN_PUB;

/

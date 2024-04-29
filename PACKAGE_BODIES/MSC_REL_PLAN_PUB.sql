--------------------------------------------------------
--  DDL for Package Body MSC_REL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_REL_PLAN_PUB" AS
/* $Header: MSCPRELB.pls 120.41.12010000.30 2010/03/25 06:17:41 ahoque ship $ */

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
   v_msc_released_only_by_user  NUMBER;
   v_batch_id_populated         NUMBER := 1; --1 - populated ; 2 - not populated in msc_supplies
   v_plan_type          NUMBER;      -- For RP Release
   v_rp_plan            NUMBER := 0 ;
   v_user_id			NUMBER;
   v_rp_time            NUMBER := 0; -- For RP Release

   JOB_CANCELLED          CONSTANT INTEGER := 7;

   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';

   LT_RESOURCE_INSTANCE CONSTANT NUMBER := 8;  -- dsr
 	-- SUBST_CHANGE CONSTANT NUMBER := 3; -- dsr
 	LT_RESOURCE_INST_USAGE CONSTANT NUMBER := 9; -- dsr
 	LT_CHARGE_TYPE CONSTANT NUMBER := 10; -- dsr
 	EAM_RESCHEDULE_WORK_ORDER CONSTANT NUMBER := 21; -- dsr

   l_sql_stmt          VARCHAR2(20000);

/* DWK */ -- Function added for DRP Release
FUNCTION Decode_Sales_Order_Number(p_order_number_string in VARCHAR2)
                                   return NUMBER IS

p_order_number  NUMBER := 0;
l_end           number;
l_counter       number;
l_max_counter   number;
l_char          varchar2(1);
l_num_char      number;

BEGIN

    BEGIN
        p_order_number := to_number (p_order_number_string);
        return p_order_number;
    EXCEPTION
        WHEN others then
           null;
    END;

    p_order_number:= null;
    l_end := 0;
    l_counter := 0;
    l_max_counter := length(p_order_number_string);

    if (l_max_counter = 0) then
        return null;
    end if;

    while (l_end <> 1) loop
        l_counter := l_counter + 1;
        if (l_counter > l_max_counter ) then
            l_end := 1;
            exit;
        end if;
        l_char := substr (p_order_number_string, l_counter, 1);
        BEGIN
            l_num_char := to_number (l_char);
        EXCEPTION
            WHEN OTHERS then
                l_end := 1;
        END;
    end loop;

    if (l_counter > l_max_counter) then
        BEGIN
           p_order_number := to_number (p_order_number_string);
        EXCEPTION
            WHEN others then
                return null;
        END;
    elsif (l_counter = 1) then
        return null;
    else
        BEGIN
            p_order_number := to_number (substr (p_order_number_string, 1,l_counter -1));
        EXCEPTION
            WHEN others then
                return null;
        END;
    end if;

    return p_order_number;

EXCEPTION
    WHEN others THEN

        return null;
END;

   -- This procesure prints out debug information
   --commenting out the procedure bug 8761596
  /* PROCEDURE print_debug_info(
     p_debug_info IN VARCHAR2
   )IS
   BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, p_debug_info);
       --dbms_output.put_line(p_debug_info);
   EXCEPTION
   WHEN OTHERS THEN
      RAISE;
   END print_debug_info;*/



FUNCTION GET_CAL_DATE ( lv_inst_id in number
                        ,lv_calendar_date in date
                        ,lv_calendar_code in varchar2) return date
is
lv_date date;
BEGIN
    SELECT  cal4.calendar_date
    into    lv_date
    FROM    msc_calendar_dates cal3,
            msc_calendar_dates cal4
    WHERE   cal3.sr_instance_id = lv_inst_id
    AND     cal3.exception_set_id = -1
    AND     cal3.calendar_date = lv_calendar_date
    AND     cal3.calendar_code  = lv_calendar_code
    AND     cal4.sr_instance_id = cal3.sr_instance_id
    AND     cal4.calendar_code = cal3.calendar_code
    and     cal4.exception_set_id = cal3.exception_set_id
    and     cal4.seq_num = nvl(cal3.seq_num,cal3.prior_seq_num);

    return lv_date;

    EXCEPTION
       when no_data_found then
       return null;
       when others  then
       return null;

END GET_CAL_DATE;
FUNCTION GET_COPRODUCT_QTY ( inst_id in number
                            , pln_id in number
                            ,disp_id in number
                            ,bill_seq_id in number) return number
is
lv_total number;
BEGIN

    select sum(coprod.new_order_quantity)
    into lv_total
    from  msc_supplies coprod, msc_bom_components mbc
    where coprod.sr_instance_id = inst_id
    and   coprod.plan_id  = pln_id
    and   mbc.sr_instance_id = coprod.sr_instance_id
    and   mbc.plan_id = coprod.plan_id
    and   mbc.inventory_item_id = coprod.inventory_item_id
    and   mbc.organization_id = coprod.organization_id
    and   mbc.bill_sequence_id = bill_seq_id
    and   NOT (mbc.usage_quantity < 0 and mbc.component_type <> 10)
    and   coprod.order_type = 17
    and   coprod.disposition_id = disp_id;

    select nvl(lv_total,0) into   lv_total from dual;

    return lv_total;

    EXCEPTION
       when no_data_found then lv_total := 0;
       return lv_total;
       when others then lv_total := 0;
       return lv_total;

END GET_COPRODUCT_QTY;

FUNCTION GET_REV_CUM_YIELD ( inst_id in number
                            , pln_id in number
                            ,process_seq_id in number
                            ,trans_id in number
                            ,org_id in number) return number
is
lv_yield number;
BEGIN

    select nvl(mrr.REVERSE_CUMULATIVE_YIELD,1)
    into lv_yield
    from  msc_process_effectivity mpe,
          msc_routings mr,
          msc_resource_requirements mrr
    where mpe.sr_instance_id = inst_id
    and   mpe.plan_id  = pln_id
    and   mpe.process_sequence_id = process_seq_id
    and   mr.routing_sequence_id = mpe.routing_sequence_id
    and   mr.plan_id = mpe.plan_id
    and   mr.sr_instance_id = mpe.sr_instance_id
    and   mrr.plan_id = mr.plan_id
    and   mrr.routing_sequence_id = mr.routing_sequence_id
    and   mrr.sr_instance_id = mr.sr_instance_id
    and   mrr.OPERATION_SEQ_NUM = mr.FIRST_OP_SEQ_NUM
    and   mrr.supply_id = trans_id
    and   mrr.organization_id = org_id
    and   mrr.rowid=(select min(rowid) from msc_resource_requirements
                     where routing_sequence_id = mr.routing_sequence_id
                     and   sr_instance_id = inst_id
                     and   plan_id = pln_id
                     and   supply_id = trans_id
                     and   organization_id = org_id
                     and   operation_seq_num = mr.first_op_seq_num
                     and   parent_id = 2);

    return lv_yield;

EXCEPTION
       when no_data_found then lv_yield := 1;
       return lv_yield;
       when others then lv_yield := 1;
       return lv_yield;

END GET_REV_CUM_YIELD;

FUNCTION GET_REV_CUM_YIELD_DISC( inst_id        IN NUMBER
                                 ,pln_id         IN NUMBER
                                 ,process_seq_id IN NUMBER
                                 ,trans_id       IN NUMBER
                                 ,org_id         IN NUMBER
                                 ,org_type       IN NUMBER
                                  )
RETURN number
 IS
 lv_yield_dis number;

 BEGIN

   lv_yield_dis := 0;

  /* For  bug: 2559388 - added this If cond to return RCY=1 (for OPM, there is no RCY concept ,so return 1
    and for the OPM orgs organization_type = 2 in msc_trading_partners */

   IF (org_type = 2) THEN
        lv_yield_dis := 1;
        RETURN lv_yield_dis;
   END IF;

     select nvl(mrr.REVERSE_CUMULATIVE_YIELD,1)
     into lv_yield_dis
     from  msc_process_effectivity mpe,
           msc_routings mr,
           msc_resource_requirements mrr
     where mpe.sr_instance_id = inst_id
     and   mpe.plan_id  = pln_id
     and   mpe.process_sequence_id = process_seq_id
     and   mr.routing_sequence_id = mpe.routing_sequence_id
     and   mr.plan_id = mpe.plan_id
     and   mr.sr_instance_id = mpe.sr_instance_id
     and   mrr.plan_id = mr.plan_id
     and   mrr.routing_sequence_id = mr.routing_sequence_id
     and   mrr.sr_instance_id = mr.sr_instance_id
     and   mrr.supply_id = trans_id
     and   mrr.organization_id = org_id
     and   mrr.OPERATION_SEQ_NUM = (select min(OPERATION_SEQ_NUM)
                               from msc_resource_requirements
                              where   routing_sequence_id = mr.routing_sequence_id
                                and   sr_instance_id = inst_id
                                and   plan_id = pln_id
                                and   supply_id = trans_id
                                and   organization_id = org_id
                                and   parent_id = 2)
     and mrr.parent_id = 2
     and rownum = 1;

   RETURN lv_yield_dis;

 EXCEPTION
        WHEN OTHERS THEN
            lv_yield_dis := 1;

   RETURN lv_yield_dis;

END GET_REV_CUM_YIELD_DISC;


FUNCTION GET_REV_CUM_YIELD_DISC_COMP( inst_id         IN NUMBER
                                      ,pln_id         IN NUMBER
                                      ,process_seq_id IN NUMBER
                                      ,trans_id       IN NUMBER
                                      ,org_id         IN NUMBER
                                      ,org_type       IN NUMBER
                                      ,op_seq_num     IN NUMBER
                                  )
RETURN number
 IS
 lv_yield_dis number;

 BEGIN

   lv_yield_dis := 0;

  /* For  bug: 2559388 - added this If cond to return RCY=1 (for OPM, there is no RCY concept ,so return 1
    and for the OPM orgs organization_type = 2 in msc_trading_partners */

   IF (org_type = 2) THEN
        lv_yield_dis := 1;
        RETURN lv_yield_dis;
   END IF;

     select nvl(mrr.REVERSE_CUMULATIVE_YIELD,1)
     into lv_yield_dis
     from  msc_process_effectivity mpe,
           msc_routings mr,
           msc_resource_requirements mrr
     where mpe.sr_instance_id = inst_id
     and   mpe.plan_id  = pln_id
     and   mpe.process_sequence_id = process_seq_id
     and   mr.routing_sequence_id = mpe.routing_sequence_id
     and   mr.plan_id = mpe.plan_id
     and   mr.sr_instance_id = mpe.sr_instance_id
     and   mrr.plan_id = mr.plan_id
     and   mrr.routing_sequence_id = mr.routing_sequence_id
     and   mrr.sr_instance_id = mr.sr_instance_id
     and   mrr.supply_id = trans_id
     and   mrr.organization_id = org_id
     and   mrr.OPERATION_SEQ_NUM = op_seq_num
     and mrr.parent_id = 2
     and rownum = 1;

   RETURN lv_yield_dis;

 EXCEPTION
        WHEN OTHERS THEN
            lv_yield_dis := 1;

   RETURN lv_yield_dis;

END GET_REV_CUM_YIELD_DISC_COMP;

FUNCTION GET_USAGE_QUANTITY ( p_plan_id     IN NUMBER
                              ,p_inst_id     IN NUMBER
                              ,p_org_id     IN NUMBER
                              ,p_using_assy_id     IN NUMBER
                              ,p_comp_seq_id  IN NUMBER) RETURN NUMBER
IS
lv_USAGE_QUANTITY NUMBER;
BEGIN

    SELECT mbc.USAGE_QUANTITY
    INTO   lv_USAGE_QUANTITY
    FROM   MSC_BOM_COMPONENTS mbc
    WHERE mbc.plan_id = p_plan_id
    AND  mbc.sr_instance_id = p_inst_id
    AND mbc.organization_id = p_org_id
    AND mbc.using_assembly_id = p_using_assy_id
    AND mbc.component_sequence_id  =  p_comp_seq_id;

    RETURN lv_USAGE_QUANTITY;

EXCEPTION
       WHEN OTHERS THEN  return NULL;

END GET_USAGE_QUANTITY;

FUNCTION GET_WIP_SUPPLY_TYPE ( p_plan_id     IN NUMBER
                              ,p_inst_id     IN NUMBER
                              ,p_process_seq_id IN NUMBER
                              ,p_item_id      IN NUMBER
                              ,p_comp_item_id IN NUMBER
                              ,p_org_id      IN NUMBER) RETURN NUMBER
IS
lv_wip_sup_type NUMBER;
BEGIN

    SELECT mbc.WIP_SUPPLY_TYPE
    INTO   lv_wip_sup_type
    FROM   MSC_BOM_COMPONENTS mbc,
           msc_process_effectivity mpe
   where mpe.sr_instance_id = p_inst_id
    and   mpe.plan_id  = p_plan_id
    and   mpe.process_sequence_id = p_process_seq_id
    AND mpe.organization_id = p_org_id
    AND mpe.item_id = p_item_id
    and    mbc.plan_id =  mpe.plan_id
    AND mbc.sr_instance_id = mpe.sr_instance_id
    AND mbc.bill_sequence_id = mpe.bill_sequence_id
    AND mbc.inventory_item_id =  p_comp_item_id
    AND (mpe.disable_date is NULL OR
            trunc(mpe.disable_date) >= trunc(SYSDATE) )
    AND (mbc.disable_date is NULL OR
            trunc(mbc.disable_date) >= trunc(SYSDATE) )
    and rownum = 1;
    RETURN lv_wip_sup_type;

EXCEPTION
       WHEN OTHERS THEN  return NULL;

END GET_WIP_SUPPLY_TYPE;

/* added these 2 functions for getting the sr_tp_id and tp_site_code
  for releasing across the instances */
FUNCTION GET_MODELED_SR_TP_ID (pMODELED_SUPPLIER_ID    IN NUMBER,
                               pSR_INSTANCE_ID         IN NUMBER)
    RETURN NUMBER
IS
lv_mod_sup_sr_tp_id NUMBER;
BEGIN

    SELECT SR_TP_ID
    INTO   lv_mod_sup_sr_tp_id
    FROM   MSC_TP_ID_LID
    WHERE  TP_ID = pMODELED_SUPPLIER_ID
      AND  SR_INSTANCE_ID = pSR_INSTANCE_ID
      AND  PARTNER_TYPE = 1;

    RETURN lv_mod_sup_sr_tp_id;

EXCEPTION
    WHEN OTHERS THEN
          RETURN NULL;

END GET_MODELED_SR_TP_ID;

FUNCTION GET_MODELED_TP_SITE_CODE (pMODELED_SUPPLIER_ID       IN NUMBER,
                                   pMODELED_SUPPLIER_SITE_ID  IN NUMBER,
                                   pSR_INSTANCE_ID            IN NUMBER)
   RETURN VARCHAR2
IS
lv_mod_sup_site_code VARCHAR2(30);
BEGIN

    SELECT TP_SITE_CODE
    INTO   lv_mod_sup_site_code
    FROM   MSC_TRADING_PARTNER_SITES
    WHERE  PARTNER_ID = pMODELED_SUPPLIER_ID
      AND  PARTNER_SITE_ID = pMODELED_SUPPLIER_SITE_ID
      AND  SR_INSTANCE_ID = pSR_INSTANCE_ID
      AND  PARTNER_TYPE = 1;

    RETURN lv_mod_sup_site_code;

EXCEPTION
    WHEN OTHERS THEN
          RETURN NULL;

END GET_MODELED_TP_SITE_CODE;


/***********************************************************
PROCEDURE:       MSC_RELEASE_PLAN_SC

*************************************************************/
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
 -- the following 2 parameters added for dsr
, arg_resched_eam_jobs          IN OUT  NOCOPY  NumTblTyp
, arg_eam_req_id 	        IN OUT  NOCOPY  NumTblTyp
-- the following 2 parameters added for DRP Release
, arg_loaded_int_reqs               IN OUT  NOCOPY  NumTblTyp
, arg_resched_int_reqs              IN OUT  NOCOPY NumTblTyp
, arg_int_req_load_id               IN OUT  NOCOPY  NumTblTyp
, arg_int_req_resched_id            IN OUT  NOCOPY  NumTblTyp
, arg_loaded_int_repair_orders      IN OUT  NOCOPY  NumTblTyp -- bug 6021045
, arg_int_repair_orders_id          IN OUT  NOCOPY  NumTblTyp -- bug 6021045
, arg_loaded_ext_repair_orders      IN OUT  NOCOPY  NumTblTyp -- bug 6051361
, arg_ext_repair_orders_id          IN OUT  NOCOPY  NumTblTyp -- bug 6051361
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

--  l_sql_stmt          VARCHAR2(4000);

  l_loaded_jobs       NUMBER;
  l_loaded_reqs       NUMBER;
  l_loaded_scheds     NUMBER;
  l_resched_jobs      NUMBER;

  L_RESCHED_EAM_JOBS	   NUMBER; -- dsr
  L_EAM_REQ_ID 		   NUMBER; -- dsr

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

  l_load_int_jobs          number;
  l_resched_int_jobs       number;
  l_int_req_load_id        number;
  l_int_req_resched_id     number;

  l_loaded_int_repair_orders number ;-- bug 6021045
  l_int_repair_orders_id number ;-- bug 6021045

  l_loaded_ext_repair_orders number ;-- bug 6051361
  l_ext_repair_orders_id number ;-- bug 6051361

  l_wip_group_id      NUMBER;
  l_po_batch_number   NUMBER;

BEGIN


   SELECT
     DECODE(NVL(fnd_profile.value('MSC_RELEASED_BY_USER_ONLY') ,'N'), 'Y',1 ,2)
     INTO  v_msc_released_only_by_user
     FROM  DUAL;
     v_batch_id_populated := 1;
     IF (g_batch_id = g_prev_batch_id)  OR g_batch_id = -1 THEN
           begin
               -- populating batch_id from destination side seq.
               Execute immediate 'select  mrp_workbench_query_s.nextval
                                 FROM DUAL '
                            into MSC_Rel_Plan_PUB.g_batch_id;
               v_batch_id_populated := 2;
           exception when others then
            fnd_file.put_line(FND_FILE.LOG, sqlerrm);
           end;
     END IF;
     g_prev_batch_id := g_batch_id;
   SELECT
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.USER_NAME,
       FND_GLOBAL.RESP_NAME,
       FND_GLOBAL.APPLICATION_NAME
     INTO v_user_id,
          l_user_name,
           l_resp_name,
           l_application_name
     FROM  dual;


     SELECT APPLICATION_ID
     INTO l_application_id
     FROM FND_APPLICATION_VL
     WHERE APPLICATION_NAME = l_application_name;

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

   arg_loaded_int_reqs.extend(1);
   arg_resched_int_reqs.extend(1);
   arg_int_req_load_id.extend(1);
   arg_int_req_resched_id.extend(1);

   arg_loaded_int_repair_orders.extend(1); -- bug 6021045
   arg_int_repair_orders_id.extend(1); --bug 6021045

   arg_loaded_ext_repair_orders.extend(1); -- bug 6051361
   arg_ext_repair_orders_id.extend(1); --bug 6051361

   lv_count:= lv_count+1;

   arg_released_instance(lv_count):= l_sr_instance_id;

   -- initialize the Applications Environment --
  IF v_curr_instance_type IN ( G_INS_DISCRETE, G_INS_PROCESS, G_INS_MIXED, G_INS_OTHER ) THEN /*E1-Bug 8628506  */
   IF (l_apps_ver >= 3 OR v_curr_instance_type = G_INS_OTHER )THEN /* E1-Bug 8628506 */
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
    ELSE
         l_sql_stmt:=
            'BEGIN'
          ||'  MRP_AP_REL_PLAN_PUB.INITIALIZE'||l_dblink
                              ||'( :l_user_name,'
                              ||'  :l_resp_name,'
                              ||'  :l_application_name);'
          ||'END;';

         EXECUTE IMMEDIATE l_sql_stmt
                        USING IN l_user_name,
                              IN l_resp_name,
                              IN l_application_name;

    END IF;

    END IF;

       l_loaded_jobs   := 0;
       l_loaded_reqs   := 0;
       l_loaded_scheds := 0;
       l_resched_jobs  := 0;
       l_loaded_lot_jobs := 0;
       l_resched_lot_jobs := 0;
       L_RESCHED_EAM_JOBS := 0; -- dsr
       l_load_int_jobs   :=0;
       l_resched_int_jobs :=0;

       l_loaded_int_repair_orders :=0  ;-- bug 6021045
       l_loaded_ext_repair_orders :=0  ;-- bug 6051361


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
                 -- the following 2 lines added for dsr
	        		 arg_resched_eam_jobs => l_resched_eam_jobs,
							 arg_eam_req_id =>    l_eam_req_id,
    -------------------------------------------------------------
                 arg_loaded_int_reqs  => l_load_int_jobs,
                 arg_resched_int_reqs => l_resched_int_jobs,
                 arg_int_req_load_id  => l_int_req_load_id,
                 arg_int_req_resched_id => l_int_req_resched_id,
    -------------------------------------------------------------
               arg_loaded_int_repair_orders=> l_loaded_int_repair_orders,   -- bug 6021045
               arg_int_repair_orders_id=> l_int_repair_orders_id,           -- bug 6021045
               arg_loaded_ext_repair_orders=> l_loaded_ext_repair_orders,   -- bug 6051361
               arg_ext_repair_orders_id=> l_ext_repair_orders_id            -- bug 6051361
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

    -- dsr
   arg_resched_eam_jobs(lv_count) := l_resched_eam_jobs;
   arg_eam_req_id(lv_count)    :=  l_eam_req_id;

   -- DRP Release
   arg_loaded_int_reqs(lv_count) := l_load_int_jobs;
   arg_resched_int_reqs(lv_count) := l_resched_int_jobs;
   arg_int_req_load_id(lv_count) := l_int_req_load_id;
   arg_int_req_resched_id(lv_count) :=  l_int_req_resched_id;

   --IRO release
    arg_loaded_int_repair_orders(lv_count):= l_loaded_int_repair_orders;    -- bug 6021045
    arg_int_repair_orders_id(lv_count) := l_int_repair_orders_id;-- bug 6021045

   --ERO release
    arg_loaded_ext_repair_orders(lv_count):= l_loaded_ext_repair_orders;    -- bug 6051361
    arg_ext_repair_orders_id(lv_count) := l_ext_repair_orders_id;-- bug 6051361

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
   arg_loaded_int_reqs.trim(1);
   arg_resched_int_reqs.trim(1);
   arg_int_req_load_id.trim(1);
   arg_int_req_resched_id.trim(1);
   arg_loaded_int_repair_orders.trim(1);-- bug 6021045
   arg_int_repair_orders_id.trim(1);-- bug 6021045
   arg_loaded_ext_repair_orders.trim(1);-- bug 6051361
   arg_ext_repair_orders_id.trim(1);-- bug 6051361

EXCEPTION

   WHEN OTHERS THEN
      IF c_Instance%ISOPEN THEN CLOSE c_Instance; END IF;

      RAISE;

END MSC_Release_Plan_Sc;

/* for bug: 2428319,
  OVER-LOADED the PROCEDURE MSC_RELEASE_PLAN_SC for backward compatibility, so that the old versions of UI package MSC_EXP_WF
  and the MSCFNORD does not get INVALID after the application of Collections patch
  This may also happens because ATP has some UI pre-req patch which applies MSCFNORD on the source instance
  and does not get compiled
  This is done only for Compilation purpose and this procedure will not be called by UI for the
  functionality of Releasing planned orders
*/
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
, arg_loaded_jobs 		IN OUT 	NOCOPY  NumTblTyp
, arg_loaded_reqs 		IN OUT  NOCOPY  NumTblTyp
, arg_loaded_scheds 		IN OUT  NOCOPY  NumTblTyp
, arg_resched_jobs 		IN OUT  NOCOPY  NumTblTyp
, arg_resched_reqs 		IN OUT  NOCOPY  NumTblTyp
, arg_wip_req_id  		IN OUT  NOCOPY  NumTblTyp
, arg_req_load_id 		IN OUT  NOCOPY  NumTblTyp
, arg_req_resched_id 		IN OUT  NOCOPY  NumTblTyp
, arg_released_instance         IN OUT  NOCOPY  NumTblTyp
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
, arg_loaded_int_reqs               IN OUT  NOCOPY  NumTblTyp
, arg_resched_int_reqs              IN OUT  NOCOPY  NumTblTyp
, arg_int_req_load_id               IN OUT  NOCOPY  NumTblTyp
, arg_int_req_resched_id            IN OUT  NOCOPY  NumTblTyp
, arg_loaded_int_repair_orders      IN OUT  NOCOPY  NumTblTyp -- bug 6021045
, arg_int_repair_orders_id          IN OUT  NOCOPY  NumTblTyp -- bug 6021045
, arg_loaded_ext_repair_orders      IN OUT  NOCOPY  NumTblTyp -- bug 6051361
, arg_ext_repair_orders_id          IN OUT  NOCOPY  NumTblTyp -- bug 6051361
) IS

CURSOR c_Instance IS
SELECT apps.instance_id,
       apps.apps_ver,
       apps.instance_type,
       DECODE(apps.m2a_dblink,NULL,' ', '@' || m2a_dblink),
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
  l_apps_ver          VARCHAR2(10);
  l_dblink            VARCHAR2(128);

  l_user_name         VARCHAR2(100):= NULL;
  l_resp_name         VARCHAR2(100):= NULL;
  l_application_name  VARCHAR2(240):= NULL;

  l_user_id           NUMBER;
  l_resp_id           NUMBER;
  l_application_id    NUMBER;

--  l_sql_stmt          VARCHAR2(4000);

  l_loaded_jobs       NUMBER;
  l_loaded_reqs       NUMBER;
  l_loaded_scheds     NUMBER;
  l_resched_jobs      NUMBER;

  l_resched_reqs      NUMBER;
  l_wip_req_id        NUMBER;
  l_req_load_id       NUMBER;
  l_req_resched_id    NUMBER;

  lv_count            NUMBER:= 0;

 arg_loaded_lot_jobs  NumTblTyp;
 arg_resched_lot_jobs NumTblTyp;
 arg_osfm_req_id      NumTblTyp;

  l_loaded_lot_jobs   NUMBER;
  l_resched_lot_jobs  NUMBER;
  l_osfm_req_id       NUMBER;

  l_wip_group_id      NUMBER;
  l_po_batch_number   NUMBER;

  L_RESCHED_EAM_JOBS	   NUMBER; -- dsr
  L_EAM_REQ_ID 		   NUMBER; -- dsr

  lv_error_buf        VARCHAR2(2000);
  lv_ret_code	      NUMBER;

  l_load_int_jobs          number;
  l_resched_int_jobs       number;
  l_int_req_load_id        number;
  l_int_req_resched_id     number;

  l_loaded_int_repair_orders number ;-- bug 6021045
  l_int_repair_orders_id number ;-- bug 6021045

  l_loaded_ext_repair_orders number ;-- bug 6051361
  l_ext_repair_orders_id number ;-- bug 6051361

BEGIN


   SELECT
     DECODE(NVL(fnd_profile.value('MSC_RELEASED_BY_USER_ONLY') ,'N'), 'Y',1 ,2)
     INTO  v_msc_released_only_by_user
     FROM  DUAL;
     v_batch_id_populated := 1;
     IF (g_batch_id = g_prev_batch_id)  OR g_batch_id = -1 THEN
           begin
               -- populating batch_id from destination side seq.
               Execute immediate 'select  mrp_workbench_query_s.nextval
                                 FROM DUAL '
                            into MSC_Rel_Plan_PUB.g_batch_id;
               v_batch_id_populated := 2;
           exception when others then
            fnd_file.put_line(FND_FILE.LOG, sqlerrm);
           end;
     END IF;
     g_prev_batch_id := g_batch_id;
   SELECT
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.USER_NAME,
       FND_GLOBAL.RESP_NAME,
       FND_GLOBAL.APPLICATION_NAME
     INTO v_user_id,
          l_user_name,
           l_resp_name,
           l_application_name
     FROM  dual;

  -------- Release the planned order one instance by one instance.

  OPEN c_Instance;
  LOOP
    FETCH c_Instance
     INTO l_sr_instance_id,
          l_apps_ver,
          v_curr_instance_type,
          l_dblink,
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

   arg_loaded_int_reqs.extend(1);
   arg_resched_int_reqs.extend(1);
   arg_int_req_load_id.extend(1);
   arg_int_req_resched_id.extend(1);

   arg_loaded_int_repair_orders.extend(1); -- bug 6021045
   arg_int_repair_orders_id.extend(1); --bug 6021045
   arg_loaded_ext_repair_orders.extend(1); -- bug 6051361
   arg_ext_repair_orders_id.extend(1); --bug 6051361

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
                         ||'  :l_wip_group_id,'
                         ||'  :l_po_batch_number);'
     ||'END;';

       EXECUTE IMMEDIATE l_sql_stmt
                   USING IN l_user_name,
                         IN l_resp_name,
                         IN l_application_name,
                         OUT l_wip_group_id,
                         OUT l_po_batch_number;

   END IF;

       l_loaded_jobs   := 0;
       l_loaded_reqs   := 0;
       l_loaded_scheds := 0;
       l_resched_jobs  := 0;
       l_loaded_lot_jobs := 0;
       l_resched_lot_jobs := 0;
       l_load_int_jobs   :=0;
       l_resched_int_jobs :=0;

       l_loaded_int_repair_orders:= 0 ;--bug 6021045
       l_loaded_ext_repair_orders:= 0 ;--bug 6051361

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
                 -- the following 2 lines added for dsr
		 arg_resched_eam_jobs => l_resched_eam_jobs, -- dsr: should we put NULL here?
		 arg_eam_req_id => l_eam_req_id, -- dsr ?
    -------------------------------------------------------------
                 arg_loaded_int_reqs  => l_load_int_jobs,
                 arg_resched_int_reqs => l_resched_int_jobs,
                 arg_int_req_load_id  => l_int_req_load_id,
                 arg_int_req_resched_id => l_int_req_resched_id,
    -------------------------------------------------------------
                arg_loaded_int_repair_orders=> l_loaded_int_repair_orders,   -- bug 6021045
                arg_int_repair_orders_id=> l_int_repair_orders_id,   -- bug 6021045
                arg_loaded_ext_repair_orders=> l_loaded_ext_repair_orders,   -- bug 6051361
                arg_ext_repair_orders_id=> l_ext_repair_orders_id   -- bug 6051361
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

   arg_loaded_int_reqs(lv_count) := l_load_int_jobs;
   arg_resched_int_reqs(lv_count) := l_resched_int_jobs;
   arg_int_req_load_id(lv_count) := l_int_req_load_id;
   arg_int_req_resched_id(lv_count) :=  l_int_req_resched_id;

    --IRO release
    arg_loaded_int_repair_orders(lv_count):= l_loaded_int_repair_orders;    -- bug 6021045
    arg_int_repair_orders_id(lv_count) := l_int_repair_orders_id;-- bug 6021045

    --ERO release
    arg_loaded_ext_repair_orders(lv_count):= l_loaded_ext_repair_orders;    -- bug 6051361
    arg_ext_repair_orders_id(lv_count) := l_ext_repair_orders_id;-- bug 6051361

   END LOOP;

   CLOSE c_Instance;

   arg_loaded_jobs.trim(1);
   arg_loaded_reqs.trim(1);
   arg_loaded_scheds.trim(1);
   arg_resched_jobs.trim(1);
   arg_resched_reqs.trim(1);
   arg_wip_req_id.trim(1);
   arg_req_load_id.trim(1);
   arg_req_resched_id.trim(1);
   arg_released_instance.trim(1);
   arg_loaded_int_reqs.trim(1);
   arg_resched_int_reqs.trim(1);
   arg_int_req_load_id.trim(1);
   arg_int_req_resched_id.trim(1);

    --IRO release
    arg_loaded_int_repair_orders.trim(1);    -- bug 6021045
    arg_int_repair_orders_id.trim(1);-- bug 6021045

    --ERO release
    arg_loaded_ext_repair_orders.trim(1);    -- bug 6051361
    arg_ext_repair_orders_id.trim(1);-- bug 6051361

EXCEPTION

   WHEN OTHERS THEN
      IF c_Instance%ISOPEN THEN CLOSE c_Instance; END IF;

      RAISE;

END MSC_Release_Plan_Sc;

/***********************************************************
PROCEDURE:        LOAD_MSC_INTERFACE

*************************************************************/
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
-- dsr
, arg_resched_eam_jobs          IN OUT  NOCOPY  NUMBER
, arg_eam_req_id                IN OUT  NOCOPY  NUMBER
, arg_loaded_int_reqs               IN OUT  NOCOPY  Number
, arg_resched_int_reqs              IN OUT  NOCOPY  Number
, arg_int_req_load_id               IN OUT  NOCOPY  Number
, arg_int_req_resched_id            IN OUT  NOCOPY  Number
, arg_loaded_int_repair_orders      IN OUT  NOCOPY  Number -- bug 6021045
, arg_int_repair_orders_id          IN OUT  NOCOPY  Number -- bug 6021045
, arg_loaded_ext_repair_orders      IN OUT  NOCOPY  Number -- bug 6051361
, arg_ext_repair_orders_id          IN OUT  NOCOPY  Number -- bug 6051361
) IS
   TYPE CurTyp is ref cursor;

   CURSOR c_plan_type(p_plan_id number) IS
      select plan_type
        from msc_plans a
        where
        plan_id = p_plan_id;

    VERSION                 CONSTANT CHAR(80) :=
    '$Header: MSCPRELB.pls 120.41.12010000.30 2010/03/25 06:17:41 ahoque ship $';

    lv_launch_process      INTEGER;
    lv_handle              VARCHAR2(200);
    lv_output              NUMBER;
    lv_error_stmt          VARCHAR2(2000) := NULL;

    lv_sql_stmt            VARCHAR2(4000);
    lv_temp		    NUMBER;

    lv_wf                   NUMBER;
    lv_wf_load_type         NUMBER;

    retcode                varchar2(30);

    /* DWK */
    l_new_iso_num          number;
    l_reschedule_iso_num   number;

    l_new_iro_num number ; -- bug 6021045
    l_new_ero_num number ; -- bug 6051361

    c_batch_number  CurTyp;
    l_batch_number1  NUMBER;
    l_batch_number2  NUMBER;

    l_batch_number3 NUMBER;-- bug 6021045
    l_batch_number4 NUMBER;-- bug 6051361
    l_request_id    NUMBER;

    l_plan_type     NUMBER;
    lv_error_buf        VARCHAR2(2000);
    lv_ret_code       NUMBER;

    l_user_id            NUMBER;
    l_user_name          VARCHAR2(2000);
    l_resp_name          VARCHAR2(2000);
    l_application_name   VARCHAR2(2000);
    l_application_id     NUMBER;
    lv_inst_type        NUMBER;
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

/*
    IF l_plan_type = 8 AND l_apps_ver = MSC_UTIL. G_APPS115  THEN
			 RAISE_APPLICATION_ERROR(-20000,'SRP release not supported to 11510 source',TRUE);
    END IF;
*/
    if(lv_output <> 0) then
        FND_MESSAGE.SET_NAME('MRP', 'GEN-LOCK-WARNING');
        FND_MESSAGE.SET_TOKEN('EVENT', 'RELEASE PLANNED ORDERS');
        lv_error_stmt := FND_MESSAGE.GET;
        raise_application_error(-20000, lv_error_stmt);
    end if;

    OPEN c_plan_type(arg_plan_id);
    FETCH c_plan_type INTO l_plan_type;
    CLOSE c_plan_type;


    select instance_type into lv_inst_type from msc_apps_instances where instance_id = arg_org_instance;

    v_plan_type  := l_plan_type;  -- For RP Release
    -- Get the hour uom code
    -- Get the profile MRP_PURCHASING_BY_REVISION is set

    if ( v_plan_type > 100) then
       v_rp_plan := 1;
    else
       v_rp_plan := 0;
    end if;

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
             AND s.transaction_id = arg_transaction_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
          WHEN OTHERS THEN RAISE;
       END;
    END IF;

    IF arg_mode = 'WF_BATCH' then
       lv_wf := 3;
    END IF;

   /* start bug 6021045 */
    /* For releasing IRO (internal repair order )*/
    IF ( lv_wf_load_type = IRO_LOAD   OR
         lv_wf= SYS_NO   OR
         lv_wf =3)  AND l_apps_ver > MSC_UTIL.G_APPS115 THEN

          lv_sql_stmt := ' SELECT mrp_workbench_query_s.nextval from dual'|| arg_dblink;
          OPEN c_batch_number for lv_sql_stmt;
          FETCH c_batch_number INTO l_batch_number3;
          CLOSE c_batch_number;



          OPEN c_plan_type(arg_plan_id);
          FETCH c_plan_type INTO l_plan_type;
          CLOSE c_plan_type;

           IF l_plan_type = 8 THEN

               IF(MSC_Rel_Plan_PUB.G_SPP_SPLIT_YN = 'Y') THEN
               Release_IRO_2(
                                  p_dblink  => arg_dblink,
                                  p_arg_iro_batch_number => l_batch_number3,
                                  p_arg_owning_instance => arg_owning_instance,
                                  p_arg_po_group_by     => arg_po_group_by,
                                  p_arg_plan_id         => arg_plan_id,
                                  p_arg_log_org_id      => arg_log_org_id,
                                  p_arg_owning_org_id  => arg_owning_org_id,
                                  p_arg_org_instance   => arg_org_instance,
                                  p_arg_mode           => arg_mode,
                                  p_arg_transaction_id  => arg_transaction_id,
                                  p_arg_loaded_int_repair_orders  =>l_new_iro_num,
                                  p_load_type     => IRO_LOAD);
                 ELSE
                     Release_IRO(
                                  p_dblink  => arg_dblink,
                                  p_arg_iro_batch_number => l_batch_number3,
                                  p_arg_owning_instance => arg_owning_instance,
                                  p_arg_po_group_by     => arg_po_group_by,
                                  p_arg_plan_id         => arg_plan_id,
                                  p_arg_log_org_id      => arg_log_org_id,
                                  p_arg_owning_org_id  => arg_owning_org_id,
                                  p_arg_org_instance   => arg_org_instance,
                                  p_arg_mode           => arg_mode,
                                  p_arg_transaction_id  => arg_transaction_id,
                                  p_arg_loaded_int_repair_orders  =>l_new_iro_num,
                                  p_load_type     => IRO_LOAD);
                  END IF;

                arg_loaded_int_repair_orders:= l_new_iro_num;


                     l_user_id := FND_GLOBAL.USER_ID;
                     l_user_name := FND_GLOBAL.USER_NAME;
                     l_resp_name := FND_GLOBAL.RESP_NAME;
                     l_application_name := FND_GLOBAL.APPLICATION_NAME;


                  SELECT APPLICATION_ID
                     INTO l_application_id
                     FROM FND_APPLICATION_VL
                     WHERE APPLICATION_NAME = l_application_name;

                 IF ( arg_loaded_int_repair_orders > 0) THEN
                       lv_sql_stmt:= ' BEGIN '
                          ||' MSC_SRP_RELEASE.MSC_RELEASE_IRO'||arg_dblink
                          ||'(:l_user_name,:l_resp_name,:l_application_name,:l_application_id,:l_batch_number, 256, '
                          ||' :arg_int_repair_orders_id);' ||
                        ' END;';
                    EXECUTE IMMEDIATE lv_sql_stmt
                    USING
                        IN l_user_name,
                        IN l_resp_name,
                        IN l_application_name,IN l_application_id,
                        IN l_batch_number3,
                        IN OUT arg_int_repair_orders_id;

                      COMMIT WORK;
                  END IF;


     END IF ;

    END IF ;
  /* end bug bug 6021045 */

   /* Start of Bug 6051361 */
  IF (lv_wf_load_type = ERO_LOAD   OR
         lv_wf= SYS_NO   OR
        lv_wf =3)  AND l_apps_ver > MSC_UTIL.G_APPS115 THEN

          lv_sql_stmt := ' SELECT mrp_workbench_query_s.nextval from dual'|| arg_dblink;
          OPEN c_batch_number for lv_sql_stmt;
          FETCH c_batch_number INTO l_batch_number4;
          CLOSE c_batch_number;



          OPEN c_plan_type(arg_plan_id);
          FETCH c_plan_type INTO l_plan_type;
          CLOSE c_plan_type;

       --execute immediate ' SELECT mrp_workbench_query_s@arg_dblink.nextval  INTO l_batch_number4  from dual'|| arg_dblink;

       --SELECT msc_plans.mrp_plan_type INTO l_plan_type from MSC_PLANS
       --WHERE PLAN_ID =  arg_plan_id ;

       IF l_plan_type = 8 THEN

                            IF(MSC_Rel_Plan_PUB.G_SPP_SPLIT_YN = 'Y') THEN

                                Release_ERO_2(
                                  p_dblink  => arg_dblink,
                                  p_arg_ero_batch_number => l_batch_number4,
                                  p_arg_owning_instance => arg_owning_instance,
                                  p_arg_po_group_by     => arg_po_group_by,
                                  p_arg_plan_id         => arg_plan_id,
                                  p_arg_log_org_id      => arg_log_org_id,
                                  p_arg_owning_org_id  => arg_owning_org_id,
                                  p_arg_org_instance   => arg_org_instance,
                                  p_arg_mode           => arg_mode,
                                  p_arg_transaction_id  => arg_transaction_id,
                                  p_arg_loaded_ext_repair_orders  =>l_new_ero_num,
                                  p_load_type     =>  ERO_LOAD);

                              ELSE

                                  Release_ERO(
                                  p_dblink  => arg_dblink,
                                  p_arg_ero_batch_number => l_batch_number4,
                                  p_arg_owning_instance => arg_owning_instance,
                                  p_arg_po_group_by     => arg_po_group_by,
                                  p_arg_plan_id         => arg_plan_id,
                                  p_arg_log_org_id      => arg_log_org_id,
                                  p_arg_owning_org_id  => arg_owning_org_id,
                                  p_arg_org_instance   => arg_org_instance,
                                  p_arg_mode           => arg_mode,
                                  p_arg_transaction_id  => arg_transaction_id,
                                  p_arg_loaded_ext_repair_orders  =>l_new_ero_num,
                                  p_load_type     =>  ERO_LOAD);

          END IF;
       END IF ;
    arg_loaded_ext_repair_orders:= l_new_ero_num ;

              l_user_id := FND_GLOBAL.USER_ID;
              l_user_name := FND_GLOBAL.USER_NAME;
              l_resp_name := FND_GLOBAL.RESP_NAME;
              l_application_name := FND_GLOBAL.APPLICATION_NAME;

             select nvl(application_id,724)
              into l_application_id
                 from fnd_application_vl
                 where application_name =l_application_name;

    IF (arg_loaded_ext_repair_orders > 0) THEN

                 Lv_sql_stmt :='BEGIN  '
			|| ' MRP_CL_FUNCTION.SUBMIT_CR'||arg_dblink
		  ||'(:l_user_name,:l_resp_name,:l_application_name,:l_application_id,:l_batch_id ,:l_conc_req_short_name ,:l_conc_request_desc,'
  		||':l_owning_appl_short_name,  128,'
      ||' :l_request_id );'
      ||' END; ';

	    --Execute Immediate lv_sql_stmt using  l

   	 EXECUTE IMMEDIATE lv_sql_stmt
                  USING
                  IN l_user_name,
                  IN l_resp_name,
                  IN l_application_name,IN l_application_id,
                  IN l_batch_number4,'MSCRLERO' ,'Release ERO To Source','MSC',
                  IN OUT l_request_id;
    END IF;

  END IF ;
COMMIT WORK;

   /*end of Bug 6051361 */
/* DWK */
    /* For Creating Internal Sales Orders and
           Rescheduling Internal Sales Orders */

    --- ISO/IR LOAD/Reschedule ---
    IF ( lv_wf_load_type = DRP_REQ_LOAD   OR
         lv_wf_load_type = DRP_REQ_RESCHED OR
   --      lv_wf_load_type = ASCP_IREQ_RESCHED OR		 -- IR/ISO resch Proj
         lv_wf= SYS_NO   OR
         lv_wf =3) THEN

       /* In case arg_mode is NULL then lv_wf = SYS_NO, and there will be
          no transaction id nor lv_wf_load_type.  Therefore, we need to call
          the POPULATE_ISO_IN_SOURCE twice. One for new iso, another for re-sche
          of ISO with hardcoded load_type. */

       lv_sql_stmt := ' SELECT mrp_workbench_query_s.nextval from dual'|| arg_dblink;

       OPEN c_batch_number for lv_sql_stmt;
       FETCH c_batch_number INTO l_batch_number1;
       CLOSE c_batch_number;

       OPEN c_batch_number for lv_sql_stmt;
       FETCH c_batch_number INTO l_batch_number2;
       CLOSE c_batch_number;

       OPEN c_plan_type(arg_plan_id);
       FETCH c_plan_type INTO l_plan_type;
       CLOSE c_plan_type;

     IF ((l_plan_type = 5) OR (l_plan_type = 8)) THEN
       IF  (lv_wf = SYS_NO) and (lv_wf_load_type IS NULL) THEN
         /* For releasing planned arrival as int req/iso */

              POPULATE_ISO_IN_SOURCE(
                                  l_dblink  => arg_dblink,
                                  l_arg_po_batch_number => l_batch_number1 ,
                                  l_arg_owning_instance => arg_owning_instance,
                                  l_arg_po_group_by     => arg_po_group_by,
                                  l_arg_plan_id         => arg_plan_id,
                                  l_arg_log_org_id      => arg_log_org_id,
                                  l_arg_owning_org_id   => arg_owning_org_id,
                                  l_arg_org_instance    => arg_org_instance,
                                  l_arg_mode            => arg_mode,
                                  l_arg_transaction_id  => arg_transaction_id,
                                  arg_loaded_int_reqs   => l_new_iso_num,
                                  arg_resched_int_reqs  => l_reschedule_iso_num,
                                  p_load_type           => DRP_REQ_LOAD);
                               arg_loaded_int_reqs := l_new_iso_num;

                  IF (arg_loaded_int_reqs > 0) THEN
                  COMMIT WORK;

		             if lv_inst_type <> G_INS_OTHER then
                  lv_sql_stmt:= ' BEGIN '
                          ||' MRP_CREATE_SCHEDULE_ISO.MSC_RELEASE_ISO'||arg_dblink
                          ||'(:l_batch_number, 32, '
                          ||' :arg_int_req_load_id,:arg_int_req_resched_id);' ||
                        ' END;';
                   EXECUTE IMMEDIATE lv_sql_stmt
                    USING IN l_batch_number1,
                        IN OUT arg_int_req_load_id, IN OUT lv_temp;
		   end if;
		   END IF;/* 9107066*/

              /* for rescheduling int reqs by updating iso */

              POPULATE_ISO_IN_SOURCE(
                                  l_dblink  => arg_dblink,
                                  l_arg_po_batch_number => l_batch_number2 ,
                                  l_arg_owning_instance => arg_owning_instance,
                                  l_arg_po_group_by     => arg_po_group_by,
                                  l_arg_plan_id         => arg_plan_id,
                                  l_arg_log_org_id      => arg_log_org_id,
                                  l_arg_owning_org_id   => arg_owning_org_id,
                                  l_arg_org_instance    => arg_org_instance,
                                  l_arg_mode            => arg_mode,
                                  l_arg_transaction_id  => arg_transaction_id,
                                  arg_loaded_int_reqs   => l_new_iso_num,
                                  arg_resched_int_reqs  => l_reschedule_iso_num,
                                  p_load_type           => DRP_REQ_RESCHED);
                                  arg_resched_int_reqs := l_reschedule_iso_num;

                    IF (arg_resched_int_reqs > 0) THEN
                    COMMIT WORK;
                    if lv_inst_type <> G_INS_OTHER then
                    lv_wf_load_type := DRP_REQ_RESCHED;
                    lv_sql_stmt:= ' BEGIN '
                          ||' MRP_CREATE_SCHEDULE_ISO.MSC_RELEASE_ISO'||arg_dblink
                          ||'(:l_batch_number, 64, '
                          ||' :arg_int_req_load_id,:arg_int_req_resched_id);' ||
                        ' END;';
                    EXECUTE IMMEDIATE lv_sql_stmt
                     USING IN l_batch_number2,
                        IN OUT lv_temp, IN OUT arg_int_req_resched_id;
                     end if;
                    END IF;


       ELSE

          /* for lv_wf = WF. creates ireq/iso if lv_wf_type =  DRP_REQ_LOAD
             or reschedules iso if lv_wf_type = DRP_REQ_RESCHED */

                    POPULATE_ISO_IN_SOURCE(
                                  l_dblink  => arg_dblink,
                                  l_arg_po_batch_number => l_batch_number1 ,
                                  l_arg_owning_instance => arg_owning_instance,
                                  l_arg_po_group_by     => arg_po_group_by,
                                  l_arg_plan_id         => arg_plan_id,
                                  l_arg_log_org_id      => arg_log_org_id,
                                  l_arg_owning_org_id   => arg_owning_org_id,
                                  l_arg_org_instance    => arg_org_instance,
                                  l_arg_mode            => arg_mode,
                                  l_arg_transaction_id  => arg_transaction_id,
                                  arg_loaded_int_reqs   => arg_loaded_int_reqs,
                                  arg_resched_int_reqs  => arg_resched_int_reqs,
                                  p_load_type           => lv_wf_load_type);

                 IF (arg_loaded_int_reqs > 0 OR arg_resched_int_reqs > 0) THEN
                 COMMIT WORK;

		          if lv_inst_type <> G_INS_OTHER then
                 lv_sql_stmt:= ' BEGIN '
                          ||' MRP_CREATE_SCHEDULE_ISO.MSC_RELEASE_ISO'||arg_dblink
                          ||'(:l_batch_number, :lv_wf_load_type, '
                          ||' :arg_int_req_load_id,:arg_int_req_resched_id);' ||
                        ' END;';
                  EXECUTE IMMEDIATE lv_sql_stmt
                     USING IN l_batch_number1, IN lv_wf_load_type,
                        IN OUT arg_int_req_load_id, IN OUT arg_int_req_resched_id;
                end if;
                END IF; /* 9107066*/


	   END IF;
       -- IR/ISO resch Proj Start
	  ELSIF ((l_plan_type in (1,2,3, 101, 102, 103))  -- 9072267
             AND
             (l_apps_ver >= MSC_UTIL.G_APPS121)) THEN
		-- Call Need to reschedule ISOs that have corresponding IRs in
		-- the same plan. Here we need to call the same OM routine as
		-- the DRP code for a new load_type ASCP_IREQ_RESCHED
        -- BUG 9072267. Need to check for RP plan types

		IF  (lv_wf = SYS_NO) and (lv_wf_load_type IS NULL) THEN

		   POPULATE_ISO_IN_SOURCE(
                                  l_dblink  => arg_dblink,
                                  l_arg_po_batch_number => l_batch_number2 ,
                                  l_arg_owning_instance => arg_owning_instance,
                                  l_arg_po_group_by     => arg_po_group_by,
                                  l_arg_plan_id         => arg_plan_id,
                                  l_arg_log_org_id      => arg_log_org_id,
                                  l_arg_owning_org_id   => arg_owning_org_id,
                                  l_arg_org_instance    => arg_org_instance,
                                  l_arg_mode            => arg_mode,
                                  l_arg_transaction_id  => arg_transaction_id,
                                  arg_loaded_int_reqs   => l_new_iso_num,
                                  arg_resched_int_reqs  => l_reschedule_iso_num,
                                  p_load_type           => DRP_REQ_RESCHED);

		   arg_resched_int_reqs := l_reschedule_iso_num;

		   IF (arg_resched_int_reqs > 0) THEN
			  COMMIT WORK;
			  lv_wf_load_type := DRP_REQ_RESCHED;
			  -- Here while calling the Source API, we still pass the
			  -- load_type as DRP_REQ_RESCHED (64)

			  lv_sql_stmt:= ' BEGIN '
                          ||' MRP_CREATE_SCHEDULE_ISO.MSC_RELEASE_ISO'||arg_dblink
                          ||'(:l_batch_number, 64, '
                          ||' :arg_int_req_load_id,:arg_int_req_resched_id);' ||
                        ' END;';

			  EXECUTE IMMEDIATE lv_sql_stmt
				USING IN l_batch_number2,
				IN OUT lv_temp, IN OUT arg_int_req_resched_id;

		   END IF;
		 ELSIF (lv_wf_load_type = DRP_REQ_RESCHED ) THEN

		   POPULATE_ISO_IN_SOURCE(
                                  l_dblink  => arg_dblink,
                                  l_arg_po_batch_number => l_batch_number1 ,
                                  l_arg_owning_instance => arg_owning_instance,
                                  l_arg_po_group_by     => arg_po_group_by,
                                  l_arg_plan_id         => arg_plan_id,
                                  l_arg_log_org_id      => arg_log_org_id,
                                  l_arg_owning_org_id   => arg_owning_org_id,
                                  l_arg_org_instance    => arg_org_instance,
                                  l_arg_mode            => arg_mode,
                                  l_arg_transaction_id  => arg_transaction_id,
                                  arg_loaded_int_reqs   => arg_loaded_int_reqs,
                                  arg_resched_int_reqs  => arg_resched_int_reqs,
                                  p_load_type           => lv_wf_load_type);


		   IF (arg_loaded_int_reqs > 0 OR arg_resched_int_reqs > 0) THEN

			  COMMIT WORK;
			  lv_wf_load_type := DRP_REQ_RESCHED;

			  lv_sql_stmt:= ' BEGIN '
                          ||' MRP_CREATE_SCHEDULE_ISO.MSC_RELEASE_ISO'||arg_dblink
                          ||'(:l_batch_number, :lv_wf_load_type, '
                          ||' :arg_int_req_load_id,:arg_int_req_resched_id);' ||
                        ' END;';

			  EXECUTE IMMEDIATE lv_sql_stmt
				USING IN l_batch_number1, IN lv_wf_load_type,
				IN OUT arg_int_req_load_id, IN OUT arg_int_req_resched_id;

		   END IF;

    -- IR/ISO resch Proj End
     END IF;
    END IF;
  END IF;
-- Timestamp for RP Release
   v_rp_time := 86399/86400;

    --- WIP_DIS_MASS_LOAD ---
    IF lv_wf= SYS_NO OR
       lv_wf_load_type= WIP_DIS_MASS_LOAD OR
       lv_wf =3 THEN

       arg_loaded_jobs:= load_wip_discrete_jobs
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_mode,
                               arg_transaction_id,
                               l_apps_ver );

       arg_loaded_lot_jobs:= load_osfm_lot_jobs
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_mode,
                               arg_transaction_id,
                               l_apps_ver );


    END IF;

    --- WIP_DIS_MASS_RESCHEDULE ---
    IF lv_wf= SYS_NO OR
       lv_wf_load_type= WIP_DIS_MASS_RESCHEDULE or
   --  lv_wf_load_type= EAM_RESCHEDULE_WORK_ORDER OR -- 21 bug# 4524589
       lv_wf_load_type = 6 THEN

       arg_resched_jobs:= reschedule_wip_discrete_jobs
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_mode,
                               arg_transaction_id,
                               l_apps_ver,
			       WIP_DIS_MASS_RESCHEDULE
			      );

       arg_resched_lot_jobs := reschedule_osfm_lot_jobs
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_mode,
                               arg_transaction_id );

        -- dsr: added the following new api call
    /*  arg_resched_eam_jobs:= reschedule_wip_discrete_jobs
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_mode,
                               arg_transaction_id,
                               l_apps_ver ,
			       21 -- dsr arg_load_type eam rescheduled wo
			     );    */

    END IF;

    --- WIP_REP_MASS_LOAD ---
    IF lv_wf= SYS_NO OR
       lv_wf_load_type= WIP_REP_MASS_LOAD OR
       lv_wf = 3 THEN

       arg_loaded_scheds:= load_repetitive_schedules
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_wip_group_id,
                               arg_mode,
                               arg_transaction_id );
    END IF;

    -- For RP Release , we need to set the timestamp as 23:59:59
    -- And for this if any of the WIP jobs created or rescheduled, then
    -- We call the procedure to set the timestamp
    if (( v_plan_type  = 101) OR (v_plan_type = 102) OR (v_plan_type = 103))
    then
      if (  nvl(arg_loaded_jobs,0)
          + nvl(arg_loaded_lot_jobs,0)
          + nvl(arg_resched_jobs,0)
          + nvl(arg_resched_lot_jobs,0)) > 0
      then
           SET_RP_TIMESTAMP_WIP( arg_wip_group_id);
      end if;
    end if;

    --- PO_MASS_LOAD ---


    IF lv_wf= SYS_NO OR
       lv_wf_load_type= PO_MASS_LOAD OR
       lv_wf = 3 THEN


       arg_loaded_reqs:= load_po_requisitions
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_po_group_by,
                               arg_po_batch_number,
                               arg_mode,
                               arg_transaction_id );
    END IF;

    --- PO_MASS_RESCHEDULE ---
    IF lv_wf= SYS_NO OR
	  (lv_wf_load_type= PO_MASS_RESCHEDULE OR
	   (lv_wf_load_type = DRP_REQ_RESCHED and
		l_apps_ver <= MSC_UTIL.G_APPS120)) THEN   -- IR/ISO resch Proj

       arg_resched_reqs:= reschedule_po
                             ( arg_plan_id,
                               arg_log_org_id,
                               arg_org_instance,
                               arg_owning_org_id,
                               arg_owning_instance,
                               arg_user_id,
                               arg_po_group_by,
                               arg_mode,
                               arg_transaction_id );
    END IF;
    -- For RP Release
    if (( v_plan_type  = 101) OR (v_plan_type = 102) OR (v_plan_type = 103))
    then
      if (  nvl(arg_loaded_reqs,0)
          + nvl(arg_resched_reqs,0)
         ) > 0
      then
           SET_RP_TIMESTAMP_PO (arg_po_batch_number);
      end if;
    end if;

    MSC_RELEASE_HOOK.EXTEND_RELEASE
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
                 arg_ext_repair_orders=>arg_loaded_ext_repair_orders,
    ----------------------------------------------- Request IDs
                 arg_resched_reqs =>   arg_resched_reqs,
                 arg_wip_req_id =>     arg_wip_req_id,
                 arg_osfm_req_id =>    arg_osfm_req_id,
                 arg_req_load_id =>    arg_req_load_id,
                 arg_req_resched_id => arg_req_resched_id,
                 arg_int_repair_Order_id=>arg_int_repair_orders_id,
                 arg_ext_repair_Order_id=>arg_ext_repair_orders_id,
    -------------------------------------------------------------
                 arg_mode => arg_mode,
                 arg_transaction_id => arg_transaction_id,
                 l_apps_ver   =>  l_apps_ver);


       IF lv_ret_code=-1 THEN /* custom hook returned error*/
        	 FND_MESSAGE.SET_NAME('MSC','MSC_ERROR_REL_CUSTOM_HOOK');
     			 RAISE_APPLICATION_ERROR(-20000,FND_MESSAGE.GET||lv_error_buf,TRUE);
   			END IF;


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

       -- dsr: added the following lines for eam
     /* IF nvl(arg_resched_eam_jobs,0) > 0 then

        lv_sql_stmt:=
         'BEGIN'
        ||' MRP_AP_REL_PLAN_PUB.LD_EAM_RESCHEDULE_JOBS'||arg_dblink
                  ||'(:arg_eam_req_id );'
        ||' END;';

        EXECUTE IMMEDIATE lv_sql_stmt
                USING OUT arg_eam_req_id;

       END IF; */

         IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
             DELETE msc_wip_job_schedule_interface
             WHERE sr_instance_id= arg_org_instance;

          DELETE MSC_WIP_JOB_DTLS_INTERFACE
           WHERE sr_instance_id= arg_org_instance;
        END IF;
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
          IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
            DELETE MSC_PO_REQUISITIONS_INTERFACE
            WHERE sr_instance_id= arg_org_instance;
        END IF;
      END;
    END IF;

    IF arg_resched_reqs > 0 THEN

       /*
       OPEN c_plan_type(arg_plan_id);
       FETCH c_plan_type INTO l_plan_type;
       CLOSE c_plan_type;

       IF l_plan_type = 5 THEN
          lv_sql_stmt :=
            'BEGIN ' ||
            'MRP_PO_RESCHEDULE.LAUNCH_RESCHEDULE_PO'||arg_dblink||
            '(:arg_req_resched_id); ' ||
            'END;';
         ELSE
         */
          lv_sql_stmt:=
            'BEGIN'
            ||' MRP_AP_REL_PLAN_PUB.LD_PO_RESCHEDULE_INTERFACE'||arg_dblink
            ||'( :arg_req_resched_id);'
            ||' END;';
      -- END IF;

          EXECUTE IMMEDIATE lv_sql_stmt
                  USING OUT arg_req_resched_id;

             IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
                DELETE MSC_PO_RESCHEDULE_INTERFACE
                 WHERE sr_instance_id= arg_org_instance;
            END IF;

    END IF;

 ELSIF v_curr_instance_type in (G_INS_OTHER, G_INS_EXCHANGE) THEN
   IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
      lv_sql_stmt :=
            ' BEGIN'
          ||' MSC_A2A_XML_WF.LEGACY_RELEASE (:p_arg_org_instance);'
          ||' END;';

      EXECUTE IMMEDIATE lv_sql_stmt USING  arg_org_instance;
   END IF;
 END IF; -- v_curr_instance_type

    --- Update the released orders.

    IF  arg_loaded_jobs > 0   OR
        arg_resched_jobs > 0  OR
        arg_loaded_lot_jobs > 0   OR
        arg_resched_lot_jobs > 0  OR
        arg_loaded_scheds > 0 OR
        arg_loaded_reqs > 0   OR
        arg_resched_reqs > 0  OR
        arg_loaded_int_reqs > 0 OR
        arg_resched_int_reqs > 0
        OR arg_loaded_int_repair_orders >0
        OR arg_loaded_ext_repair_orders >0 THEN


        IF lv_wf= SYS_YES THEN

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
                  release_status = decode(sign(v_plan_type-100),1,
                                   decode(release_status,11,21,
                                                         12,22,
                                                         13,23),
                                   NULL), -- For RP Release
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
            WHERE transaction_id= arg_transaction_id
              AND plan_id= arg_plan_id
	      AND release_errors IS NULL
          and  batch_id = g_batch_id ;

        ELSE

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
                  release_status = decode(sign(v_plan_type-100),1,
                                   decode(release_status,11,21,
                                                         12,22,
                                                         13,23),
                                   NULL), -- For RP Release
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
            WHERE batch_id = g_batch_id
              and sr_instance_id = arg_org_instance;
        END IF;  -- lv_wf

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
          WHERE sr_instance_id= arg_org_instance
           and batch_id = g_batch_id;
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
          WHERE sr_instance_id= arg_org_instance
          and batch_id = g_batch_id;
          /*
          IF g_batch_id <> -1 THEN
            update msc_supplies set batch_id = NULL where batch_id = g_batch_id;
          END IF;
          */
 commit;
 raise;

END LOAD_MSC_INTERFACE;

/* DWK


 PROCEDURE   :  POPULATE_ISO_IN_SOURCE

 -------------------------------------------------------------*/
PROCEDURE POPULATE_ISO_IN_SOURCE(
                                  l_dblink              IN  varchar2,
                                  l_arg_po_batch_number IN  number,
                                  l_arg_owning_instance IN  number,
                                  l_arg_po_group_by     IN  number,
                                  l_arg_plan_id         IN  number,
                                  l_arg_log_org_id      IN  number,
                                  l_arg_owning_org_id   IN  number,
                                  l_arg_org_instance    IN  number,
                                  l_arg_mode            IN  varchar2,
                                  l_arg_transaction_id  IN  number,
                                  arg_loaded_int_reqs   IN OUT NOCOPY number,
                                  arg_resched_int_reqs  IN OUT NOCOPY number,
                                  p_load_type           IN  number) IS

TYPE CurTyp is ref cursor;

c_row_count  CurTyp;

 CURSOR c_plan_type(p_plan_id number) IS
      select plan_type
        from msc_plans a
        where
        plan_id = p_plan_id;

l_sql_stmt   VARCHAR2(20000):= NULL;
l_sql_cur    varchar2(3000) := NULL;

l_before_row_count  number := 0;
l_after_row_count   number := 0;

l_plan_type NUMBER :=0;
BEGIN

   l_sql_cur := ' SELECT count(*) from MRP_ORG_TRANSFER_RELEASE'|| l_dblink ||
                ' WHERE batch_id = :l_arg_po_batch_number' ;


   OPEN c_row_count for l_sql_cur USING l_arg_po_batch_number;
   FETCH c_row_count INTO l_before_row_count;
   CLOSE c_row_count;



   OPEN c_plan_type(l_arg_plan_id);
                    FETCH c_plan_type INTO l_plan_type;
   CLOSE c_plan_type;



   IF p_load_type = DRP_REQ_LOAD THEN

      l_sql_stmt := ' INSERT INTO MRP_ORG_TRANSFER_RELEASE' || l_dblink ||
                 '  ( batch_id, '||
                 '    Item_ID, ' ||
                 '    SRC_Organization_ID, ' ||
                 '    SR_Instance_ID, ' ||
                 '    To_Organization_ID, ' ||
                 '    To_Sr_Instance_ID, ' ||
                 '    Quantity, ' ||
                 '    Need_By_Date, ' ||
                 '    Ship_date, ' ||
                 '    Deliver_to_location_id, ' ||
                 '    Deliver_to_requestor_id, ' ||
                 '    Preparer_id, ' ||
                 '    Uom_code, ' ||
                 '    Charge_account_id, ' ||
                 '    To_Operating_unit, ' ||
                 '    SRC_Operating_unit, ' ||
                 '    Load_Type, ' ||
                 '    Sales_Order_Line_ID, ' ||
                 '    Sales_Order_Number, ' ||
                 '    End_item_number, ' ||
                 '    firm_demand_flag, ' ||
                 '    transaction_id, ' ||
                 '    plan_type ,' ||
                 '    ship_method )  ' ||
                 ' (SELECT /*+ FIRST_ROWS */ ' ||
                 '    :l_arg_po_batch_number,'||      -- batch id
                 '    msi.sr_inventory_item_id, ' ||  -- item id in the source
                 '    s.implement_source_org_id,' ||  -- source organization id
                 '    s.sr_instance_id,         ' ||  -- source instance id
                 '    s.organization_id,        ' ||  -- destination org id
                 '    :l_org_instance_id,       ' ||  -- destination instance id
                 '    s.implement_quantity,     ' ||  -- quantity
	               '    s.implement_dock_date,    ' ||  -- arrival date in dst org
                 '    s.implement_ship_date,    ' ||  -- ship date
                 '    s.implement_location_id,  ' ||  -- destination location id
                 '    s.implement_employee_id,  ' ||  -- Deliver to requestor id
                 '    s.implement_employee_id,  ' ||  -- preparer id
                 '    msi.uom_code,             ' ||   -- uom
                 '    decode(mp.organization_type, ' || -- Account id
                 '           1, nvl(mpp.material_account, '||
                 '                 decode( msi1.inventory_asset_flag, ' ||
                 '                        ''Y'', mp.material_account, ' ||
                 '                 nvl(msi1.expense_account,mp.expense_account))),' ||
                 '           -1), '||
                  '    mp2.operating_unit,  ' ||        -- src_operating unit
                  '    mp.operating_unit, ' ||        -- to_operating_unit
                  '   :p_load_type, ' ||             -- load type
                  '    null, ' || -- Sales Order Line ID
                  '    s.transaction_id, ' || -- Sales Order Number
                  '    s.implement_unit_number, ' || --end item number
                  '    DECODE(s.implement_firm, 1, ''Y'',''N''), '||
                  '    s.transaction_id, ' || -- transaction_id of msc_supplies
                  l_plan_type ||',' ||
                  '    nvl(s.implement_ship_method,s.ship_method) ' ||
                  ' FROM    msc_projects mpp, '||
                  '         msc_trading_partners mp, ' ||
                  '         msc_trading_partners mp2,' ||
                  '         msc_system_items    msi, ' ||
                  '         msc_system_items    msi1,' ||
                  '         msc_supplies        s, '   ||
                  '         msc_plan_organizations_v orgs ' ||
                  ' WHERE   mpp.organization_id (+)= s.organization_id ' ||
                  '      AND mpp.project_id (+)= nvl(s.implement_project_id,-23453) ' ||
                  '      AND     mpp.plan_id (+)= s.plan_id ' ||
                  '      AND     mpp.sr_instance_id(+)= s.sr_instance_id ' ||
                  '      AND     mp.sr_tp_id  = s.source_organization_id ' ||
                  '      AND     mp.sr_instance_id = s.sr_instance_id ' ||
                  '      AND     mp.partner_type= 3 ' ||
                  '      AND     mp2.sr_tp_id  = msi.organization_id ' ||
                  '      AND     mp2.sr_instance_id = msi.sr_instance_id ' ||
                  '      AND     mp2.partner_type= 3 ' ||
                  '      AND     msi.inventory_item_id = s.inventory_item_id ' ||
                  '      AND     msi.plan_id = s.plan_id ' ||
                  '      AND     msi.organization_id = s.organization_id ' ||
                  '      AND     msi.sr_instance_id = s.sr_instance_id '   ||
                  '      AND     msi1.plan_id = -1 ' ||
                  '      AND     msi1.sr_instance_id = msi.sr_instance_id ' ||
                  '      AND     msi1.organization_id = msi.organization_id ' ||
                  '      AND     msi1.inventory_item_id = msi.inventory_item_id ' ||
                  '      AND     s.release_errors is NULL ' ||
                  '      AND     s.implement_quantity > 0 ' ||
                  '      AND     s.organization_id = orgs.planned_organization ' ||
                  '      AND     s.sr_instance_id = orgs.sr_instance_id ' ||
                  '      AND     s.plan_id = orgs.plan_id ' ||
                  '      AND     orgs.organization_id = :l_arg_owning_org_id ' ||
                  '      AND     orgs.owning_sr_instance = :l_arg_owning_instance ' ||
                  '      AND     orgs.plan_id = :l_arg_plan_id  ' ||
                  '      AND     orgs.sr_instance_id  = :l_arg_org_instance ' ||
                  '      AND    (s.releasable = ' || RELEASABLE || ' or s.releasable is null ) ';

                IF  v_batch_id_populated = 2 THEN
                    l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
                ELSE
                    l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
                END IF;

                IF l_arg_log_org_id <> l_arg_owning_org_id THEN
                        l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || l_arg_log_org_id || ' ' ;
                END IF;

                IF l_arg_mode IS NULL THEN
                    l_sql_stmt :=  l_sql_stmt ||'      AND s.load_type  in ( '|| DRP_REQ_LOAD||','|| IRO_LOAD  ||')'||  ' ';
                ELSIF l_arg_mode = 'WF' THEN
                    l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || l_arg_transaction_id  || '  ' ;
                END IF;

                IF v_msc_released_only_by_user = 1 THEN
                    l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
                END IF;

                l_sql_stmt :=  l_sql_stmt || ' ) ';



                IF l_arg_mode IS NULL OR l_arg_mode = 'WF' THEN
                   EXECUTE IMMEDIATE l_sql_stmt USING l_arg_po_batch_number,
                                                      l_arg_org_instance,
                                                      p_load_type,
                                                      l_arg_owning_org_id,
                                                      l_arg_owning_instance,
                                                      l_arg_plan_id,
                                                      l_arg_org_instance;

                END IF;



    ELSE

      l_sql_stmt := ' INSERT INTO MRP_ORG_TRANSFER_RELEASE' || l_dblink ||
                 '  ( batch_id, '||
                 '    Item_ID, ' ||
                 '    SRC_Organization_ID, ' ||
                 '    SR_Instance_ID, ' ||
                 '    To_Organization_ID, ' ||
                 '    To_Sr_Instance_ID, ' ||
                 '    Quantity, ' ||
                 '    Need_By_Date, ' ||
                 '    Ship_date, ' ||
                 '    Deliver_to_location_id, ' ||
                 '    Deliver_to_requestor_id, ' ||
                 '    Preparer_id, ' ||
                 '    Uom_code, ' ||
                 '    Charge_account_id, ' ||
                 '    To_Operating_unit, ' ||
                 '    SRC_Operating_unit, ' ||
                 '    Load_Type, ' ||
                 '    Sales_Order_Line_ID, ' ||
                 '    Sales_Order_Number, ' ||
                 '    End_item_number, '||
                 '    firm_demand_flag, ' ||
                 '    transaction_id, ' ||
                 '    plan_type ,' ||
                 '    ship_method )  ' ||
                 ' (SELECT /*+ FIRST_ROWS */ ' ||
                 '    :l_arg_po_batch_number,'||      -- batch id
                 '    msi.sr_inventory_item_id, ' ||  -- item id in the source
                 '    s.implement_source_org_id,' ||  -- source organization id
                 '    s.sr_instance_id,         ' ||  -- source instance id
                 '    s.organization_id,        ' ||  -- destination org id
                 '    :l_org_instance_id,       ' ||  -- destination instance id
                 '    s.implement_quantity,     ' ||  -- quantity
	         '    s.implement_dock_date,    ' ||  -- arrival date in dst org
                 '    s.implement_ship_date,    ' ||  -- ship date
                 '    s.implement_location_id,  ' ||  -- destination location id
                 '    s.implement_employee_id,  ' ||  -- Deliver to requestor id
                 '    s.implement_employee_id,  ' ||  -- preparer id
                 '    msi.uom_code,             ' ||   -- uom
                 '    decode(mp.organization_type, ' || -- Account id
                 '           1, nvl(mpp.material_account, '||
                 '                 decode( msi1.inventory_asset_flag, ' ||
                 '                        ''Y'', mp.material_account, ' ||
                 '                 nvl(msi1.expense_account,mp.expense_account))),' ||
                 '           -1), '||
                  '    mp2.operating_unit,  ' ||        -- to_operating unit
                  '    mp.operating_unit, ' ||        -- src_operating_unit
                  '   :p_load_type, ' ||             -- load type
                  '    d.sales_order_line_id,' ||    -- sales order line_id
                  '    to_number(substr(d.order_number,1,instr(d.order_number,ltrim(d.order_number,''0123456789''))-1)) ,' || --'    msc_rel_plan_pub.Decode_Sales_Order_Number' || l_dblink || '(d.order_number),'        || -- xxx dsting
                  '    s.implement_unit_number, ' ||  -- end item number
                  '    DECODE(s.implement_firm, 1, ''Y'', ''N''), '||
                  '    s.transaction_id, ' || -- transaction_id of msc_supplies
                  l_plan_type ||','||
                  '    nvl(s.implement_ship_method,s.ship_method) ' ||
                  ' FROM    msc_projects mpp, '||
                  '         msc_trading_partners mp, ' ||
                  '         msc_trading_partners mp2,' ||
                  '         msc_system_items    msi, ' ||
                  '         msc_system_items    msi1,' ||
                  '         msc_supplies        s,'    ||
                  '         msc_demands         d,'    ||
                  '         msc_plan_organizations_v orgs ' ||
                  ' WHERE   mpp.organization_id (+)= s.organization_id   ' ||
                  '       AND mpp.project_id (+)= nvl(s.implement_project_id,-23453) ' ||
                  '       AND     mpp.plan_id (+)= s.plan_id   ' ||
                  '       AND     mpp.sr_instance_id(+)= s.sr_instance_id  ' ||
                  '      AND     mp.sr_tp_id  = s.source_organization_id  ' ||
                  '      AND     mp.sr_instance_id = s.sr_instance_id ' ||
                  '      AND     mp.partner_type= 3 ' ||
                  '      AND     mp2.sr_tp_id  = msi.organization_id ' ||
                  '      AND     mp2.sr_instance_id = msi.sr_instance_id ' ||
                  '      AND     mp2.partner_type= 3 ' ||
                  '      AND     msi.inventory_item_id = s.inventory_item_id ' ||
                  '      AND     msi.plan_id = s.plan_id ' ||
                  '      AND     msi.organization_id = s.organization_id ' ||
                  '      AND     msi.sr_instance_id = s.sr_instance_id '   ||
                  '      AND     msi1.plan_id = -1 ' ||
                  '      AND     msi1.sr_instance_id = msi.sr_instance_id ' ||
                  '      AND     msi1.organization_id = msi.organization_id ' ||
                  '      AND     msi1.inventory_item_id = msi.inventory_item_id ' ||
                  '      AND     s.release_errors is NULL ' ||
                  '      AND     s.implement_quantity >= 0 ' ||
                  '      AND     s.organization_id = orgs.planned_organization ' ||
                  '      AND     s.sr_instance_id = orgs.sr_instance_id ' ||
                  '      AND     s.plan_id = orgs.plan_id ' ||
                  '      AND     orgs.organization_id = :l_arg_owning_org_id ' ||
                  '      AND     orgs.owning_sr_instance = :l_arg_owning_instance ' ||
                  '      AND     orgs.plan_id = :l_arg_plan_id  ' ||
                  '      AND     orgs.sr_instance_id  = :l_arg_org_instance ' ||
                  '      AND     d.plan_id = s.plan_id ' ||
                  '      AND     d.sr_instance_id  = s.sr_instance_id ' ||
                  '      AND     d.disposition_id  = s.transaction_id ' ||
                  '      AND     d.origination_type = 30 ' ||
                  '      and    (s.releasable = ' || RELEASABLE || ' or s.releasable is null ) ';

                IF  v_batch_id_populated = 2 THEN
                    l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
                ELSE
                    l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
                END IF;

                IF l_arg_log_org_id <> l_arg_owning_org_id THEN
                        l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || l_arg_log_org_id || ' ' ;
                END IF;

                IF l_arg_mode IS NULL THEN
                    l_sql_stmt :=  l_sql_stmt ||'      AND s.load_type  ='|| p_load_type ||  ' and s.load_type IS NOT NULL ';
                ELSIF l_arg_mode = 'WF' THEN
                    l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || l_arg_transaction_id  || '  ' ;
                END IF;

                IF v_msc_released_only_by_user = 1 THEN
                    l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
                END IF;

                l_sql_stmt :=  l_sql_stmt || ' ) ';

               IF l_arg_mode IS NULL OR l_arg_mode = 'WF' THEN

                   EXECUTE IMMEDIATE l_sql_stmt USING l_arg_po_batch_number,
                                                      l_arg_org_instance,
                                                      p_load_type,
                                                      l_arg_owning_org_id,
                                                      l_arg_owning_instance,
                                                      l_arg_plan_id,
                                                      l_arg_org_instance;

                END IF;

   END IF;

   update mrp_org_transfer_release motr
                 set earliest_ship_date = (select max(ms.new_schedule_date)
                                           from    msc_supplies ms, msc_single_lvl_peg mslp
                                           where   ms.plan_id=l_arg_plan_id
                                           and     ms.transaction_id = mslp.child_id
                                           and     ms.plan_id= mslp.plan_id
                                           and     mslp.parent_id = motr.transaction_id
                                           and     mslp.pegging_type=1)
                  where motr.batch_id=l_arg_po_batch_number;


   OPEN c_row_count for l_sql_cur USING l_arg_po_batch_number;
   FETCH c_row_count INTO l_after_row_count;
   CLOSE c_row_count;

   IF p_load_type = DRP_REQ_LOAD THEN

      arg_loaded_int_reqs := l_after_row_count - l_before_row_count;
      arg_resched_int_reqs := null;
   ELSE
      arg_loaded_int_reqs := null;
      arg_resched_int_reqs := l_after_row_count - l_before_row_count;

   END IF;

  IF l_arg_mode = 'WF' THEN
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = l_arg_plan_id
           and transaction_id= l_arg_transaction_id;
   ELSE
       execute immediate '  update msc_supplies
                               set releasable = ' || RELEASE_ATTEMPTED || '
                                  ,batch_id   = nvl(batch_id,' ||g_batch_id ||')
                             where plan_id = ' || l_arg_plan_id || '
                               and transaction_id in
                                    (select transaction_id from MRP_ORG_TRANSFER_RELEASE' || l_dblink || '
                                      where batch_id = ' || l_arg_po_batch_number  || ')';
   END IF;

END POPULATE_ISO_IN_SOURCE;



/*------------------------------------------------------------

 PROCEDURE   :  POPULATE_ISO_IN_SOURCE_2

 -------------------------------------------------------------*/
PROCEDURE POPULATE_ISO_IN_SOURCE_2(
                                  l_dblink              IN  varchar2,
                                  l_arg_po_batch_number IN  number,
                                  l_arg_owning_instance IN  number,
                                  l_arg_po_group_by     IN  number,
                                  l_arg_plan_id         IN  number,
                                  l_arg_log_org_id      IN  number,
                                  l_arg_owning_org_id   IN  number,
                                  l_arg_org_instance    IN  number,
                                  l_arg_mode            IN  varchar2,
                                  l_arg_transaction_id  IN  number,
                                  arg_loaded_int_reqs   IN OUT NOCOPY number,
                                  arg_resched_int_reqs  IN OUT NOCOPY number,
                                  p_load_type           IN  number) IS

TYPE CurTyp is ref cursor;

c_row_count  CurTyp;

 CURSOR c_plan_type(p_plan_id number) IS
      select plan_type
      from msc_plans a
      where
      plan_id = p_plan_id;

l_sql_stmt   VARCHAR2(20000):= NULL;
l_sql_cur    varchar2(3000) := NULL;

--l_before_row_count  number := 0;
--l_after_row_count   number := 0;

l_plan_type NUMBER :=0;

BEGIN

   OPEN c_plan_type(l_arg_plan_id);
   FETCH c_plan_type INTO l_plan_type;
   CLOSE c_plan_type;

   IF p_load_type = DRP_REQ_LOAD THEN

      l_sql_stmt := ' INSERT INTO MRP_ORG_TRANSFER_RELEASE' || l_dblink ||
                 '  ( batch_id, '||
                 '    Item_ID, ' ||
                 '    SRC_Organization_ID, ' ||
                 '    SR_Instance_ID, ' ||
                 '    To_Organization_ID, ' ||
                 '    To_Sr_Instance_ID, ' ||
                 '    Quantity, ' ||
                 '    Need_By_Date, ' ||
                 '    Ship_date, ' ||
                 '    Deliver_to_location_id, ' ||
                 '    Deliver_to_requestor_id, ' ||
                 '    Preparer_id, ' ||
                 '    Uom_code, ' ||
                 '    Charge_account_id, ' ||
                 '    To_Operating_unit, ' ||
                 '    SRC_Operating_unit, ' ||
                 '    Load_Type, ' ||
                 '    Sales_Order_Line_ID, ' ||
                 '    Sales_Order_Number, ' ||
                 '    End_item_number, ' ||
                 '    firm_demand_flag, ' ||
                 '    transaction_id, ' ||
                 '    plan_type ,' ||
                 '    ship_method )  ' ||
                 '( SELECT /*+ FIRST_ROWS */  '||
                 '    :l_arg_po_batch_number,'||      -- batch id
                 '    msi.sr_inventory_item_id, ' ||  -- item id in the source
                 '    s.implement_source_org_id,' ||  -- source organization id
                 '    s.sr_instance_id,         ' ||  -- source instance id
                 '    s.organization_id,        ' ||  -- destination org id
                 '    :l_org_instance_id,       ' ||  -- destination instance id
                 '    s.implement_quantity,     ' ||  -- quantity
	               '    s.implement_dock_date,    ' ||  -- arrival date in dst org
                 '    nvl(s.implement_ship_date,nvl(s.implement_dock_date,s.implement_date)),    ' ||  -- ship date
                 '    s.implement_location_id,  ' ||  -- destination location id
                 '    s.implement_employee_id,  ' ||  -- Deliver to requestor id
                 '    s.implement_employee_id,  ' ||  -- preparer id
                 '    msi.uom_code,             ' ||   -- uom
                 '    decode(mp.organization_type, ' || -- Account id
                 '           1, nvl(mpp.material_account, '||
                 '                 decode( msi1.inventory_asset_flag, ' ||
                 '                        ''Y'', mp.material_account, ' ||
                 '                 nvl(msi1.expense_account,mp.expense_account))),' ||
                 '           -1), '||
                  '    mp.operating_unit,  ' ||        -- src_operating unit
                  '    mp2.operating_unit, ' ||        -- to_operating_unit
                  '   :p_load_type, ' ||             -- load type
                  '    null, ' || -- Sales Order Line ID
                  '    s.transaction_id, ' || -- Sales Order Number
                  '    s.implement_unit_number, ' || --end item number
                  '    DECODE(s.implement_firm, 1, ''Y'',''N''), '||
                  '    s.transaction_id, ' || -- transaction_id of msc_supplies
                   l_plan_type ||',' ||
                  '    nvl(s.implement_ship_method,s.ship_method) ' ||
                  ' FROM    msc_projects mpp, ' ||
                      ' msc_trading_partners mp, ' ||
                      ' msc_trading_partners mp2, ' ||
                       'msc_system_items    msi, '||
                       'msc_system_items    msi1,'||
                       'msc_part_supplies        s, '||
                       'msc_plan_organizations_v orgs '||
                    'WHERE   mpp.organization_id (+)= s.organization_id '||
                        'AND mpp.project_id (+)= nvl(s.implement_project_id,-23453) ' ||
                        'AND     mpp.plan_id (+)= s.plan_id '||
                        'AND     mpp.sr_instance_id(+)= s.sr_instance_id '||
                        'AND     mp.sr_tp_id  = s.source_organization_id '||
                        'AND     mp.sr_instance_id = s.sr_instance_id '||
                        'AND     mp.partner_type= 3 '||
                        'AND     mp2.sr_tp_id  = msi.organization_id '||
                        'AND     mp2.sr_instance_id = msi.sr_instance_id '||
                        'AND     mp2.partner_type= 3 '||
                        'AND     msi.inventory_item_id = s.inventory_item_id '||
                        'AND     msi.plan_id = s.plan_id '||
                        'AND     msi.organization_id = s.organization_id '||
                        'AND     msi.sr_instance_id = s.sr_instance_id '||
                        'AND     msi1.plan_id = -1 '||
                        'AND     msi1.sr_instance_id = msi.sr_instance_id '||
                        'AND     msi1.organization_id = msi.organization_id '||
                        'AND     msi1.inventory_item_id = msi.inventory_item_id '||
                        --'AND     s.release_errors is NULL '||
                        'AND    (s.releasable = ' || RELEASABLE || 'or s.releasable is null ) '||
                        --'AND     s.implement_quantity > 0 '||
                        'AND     s.organization_id = orgs.planned_organization '||
                        'AND     s.sr_instance_id = orgs.sr_instance_id '||
                        'AND     s.plan_id = orgs.plan_id '||
                        'AND     orgs.organization_id = :l_arg_owning_org_id '||
                        'AND     orgs.owning_sr_instance = :l_arg_owning_instance '||
                        'AND     orgs.plan_id = :l_arg_plan_id  '||
                        'AND     orgs.sr_instance_id  = :l_arg_org_instance ';


                IF  v_batch_id_populated = 2 THEN
                    l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
                ELSE
                    l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
                END IF;

                IF l_arg_log_org_id <> l_arg_owning_org_id THEN
                        l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || l_arg_log_org_id || ' ' ;
                END IF;

                IF l_arg_mode IS NULL THEN
                    l_sql_stmt :=  l_sql_stmt ||'      AND s.load_type  in ( '|| DRP_REQ_LOAD||','|| IRO_LOAD  ||')'||  ' ';
                ELSIF l_arg_mode = 'WF' THEN
                    l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || l_arg_transaction_id  || '  ' ;
                END IF;

               /* IF v_msc_released_only_by_user = 1 THEN
                    l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
                END IF;*/

                l_sql_stmt :=  l_sql_stmt || ' ) ';



                IF l_arg_mode IS NULL OR l_arg_mode = 'WF' THEN
                   EXECUTE IMMEDIATE l_sql_stmt USING l_arg_po_batch_number,
                                                      l_arg_org_instance,
                                                      p_load_type,
                                                      l_arg_owning_org_id,
                                                      l_arg_owning_instance,
                                                      l_arg_plan_id,
                                                      l_arg_org_instance;
                  arg_loaded_int_reqs := SQL%ROWCOUNT;

                END IF;

   END IF;

  /* update mrp_org_transfer_release motr
                 set earliest_ship_date = (select max(ms.new_schedule_date)
                                           from    msc_part_supplies ms, msc_single_lvl_peg mslp
                                           where   ms.plan_id=l_arg_plan_id
                                           and     ms.transaction_id = mslp.child_id
                                           and     ms.plan_id= mslp.plan_id
                                           and     mslp.parent_id = motr.transaction_id
                                           and     mslp.pegging_type=1)
                  where motr.batch_id=l_arg_po_batch_number;*/

   arg_resched_int_reqs := null;


  IF l_arg_mode = 'WF' THEN
        update msc_supplies
         set releasable = RELEASE_ATTEMPTED,
               batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = l_arg_plan_id
         and transaction_id= l_arg_transaction_id;

    /*     update msc_part_supplies
         set releasable = RELEASE_ATTEMPTED,
               batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = l_arg_plan_id
         and transaction_id= l_arg_transaction_id;       */
   ELSE
       execute immediate '  update msc_supplies
                               set releasable = ' || RELEASE_ATTEMPTED || ',
                                   batch_id   = nvl(batch_id,' ||g_batch_id ||')
                             where plan_id = ' || l_arg_plan_id || '
                             and transaction_id in (select orig_transaction_id from msc_part_supplies where transaction_id in
                                    (select transaction_id from MRP_ORG_TRANSFER_RELEASE' || l_dblink || '
                                      where batch_id = ' || l_arg_po_batch_number  || '))';

        execute immediate '  update msc_part_supplies
                               set releasable = ' || RELEASE_ATTEMPTED || ',
                                   batch_id   = nvl(batch_id,' ||g_batch_id ||')
                             where plan_id = ' || l_arg_plan_id || '
                             and transaction_id in
                                    (select transaction_id from MRP_ORG_TRANSFER_RELEASE' || l_dblink || '
                                      where batch_id = ' || l_arg_po_batch_number  || ')';
   END IF;

END POPULATE_ISO_IN_SOURCE_2;


PROCEDURE RELEASE_IRO(
    p_dblink IN VARCHAR2,
    p_arg_iro_batch_number IN NUMBER,
    p_arg_owning_instance IN NUMBER,
    p_arg_po_group_by IN NUMBER,
    p_arg_plan_id IN NUMBER,
    p_arg_log_org_id IN NUMBER,
    p_arg_owning_org_id IN NUMBER,
    p_arg_org_instance IN NUMBER,
    p_arg_mode IN VARCHAR2,
    p_arg_transaction_id IN NUMBER,
    p_arg_loaded_int_repair_orders IN OUT nocopy NUMBER,
    p_load_type IN NUMBER)
IS
--l_sql_cur VARCHAR2(3000) := NULL;
l_sql_qry VARCHAR2(3000) := NULL;
l_sql_qry2 varchar2(3000) := NULL;
p_new_iso_num NUMBER;
p_where_clause varchar2(3000):= NULL;
p_total_rows  NUMBER;
p_succ_rows  NUMBER;
p_error_rows  NUMBER;
p_reschedule_iso_num NUMBER;

/* CURSOR c1(v_arg_mode VARCHAR2,
    v_arg_org_instance NUMBER,
    v_load_type NUMBER,
    v_arg_transaction_id NUMBER,
    v_arg_plan_id NUMBER) IS
*/

    type numlisttyp IS TABLE OF NUMBER;
    type datelisttyp IS TABLE OF DATE;
    type varlisttyp IS TABLE OF VARCHAR2(30);

    lv_transaction_id_lst numlisttyp;
    lv_quantity_lst numlisttyp;
    lv_in_req_quantity_lst numlisttyp;
    lv_load_type_lst  numlisttyp;
    lv_out_req_quantity_lst numlisttyp;
    lv_in_req_transaction_id_lst numlisttyp;
    lv_out_req_transaction_id_lst numlisttyp;
    lv_inventory_item_id_lst numlisttyp;
    lv_uom_code_lst varlisttyp;
    lv_organization_id_lst numlisttyp;
    lv_promise_date_lst datelisttyp;
    lv_implement_location_id  numlisttyp;
    lv_implement_source_org_id numlisttyp;



    --lv_implement_quantity number;
BEGIN
  /* 1. get the row count for the new batch  if in table MRP_IRO_RELEASE */
  /*
  l_sql_cur := 'SELECT count(*) from MRP_IRO_RELEASE' || p_dblink ||' WHERE batch_id = :p_arg_iro_batch_number';
  OPEN c_row_count FOR l_sql_cur USING p_arg_iro_batch_number;
  FETCH c_row_count
  INTO l_before_row_count;
  CLOSE c_row_count;
  */
   p_arg_loaded_int_repair_orders:=0;

   IF p_arg_mode IS NULL THEN
     p_where_clause:= ' AND s.load_type = '||p_load_type ;

   ELSIF p_arg_mode = 'WF' THEN
       p_where_clause:= ' AND s.transaction_id = '||p_arg_transaction_id;

  ELSE
      -- log_msg('no IROs to release....');
       return ;
    END IF;

  /* 3. bulk collect all the records returned by record  by above cursor into table types record */
l_sql_qry2:=
'with mfg0 AS  ( select transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id ,
                sum(allocated_quantity) allocated_quantity
                from msc_full_pegging
                where sr_instance_id = '||p_arg_org_instance||
                '  and plan_id = '|| p_arg_plan_id ||
                ' group by transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id
      )
  SELECT /*+ LEADING(s d) */ s1.transaction_id,
    s1.new_order_quantity quantity,
    s2.new_order_quantity in_req_quantity,
    s.new_order_quantity  out_req_quantity,
    Decode(s2.order_type,51,s2.transaction_id, null)  in_req_transaction_id,
    s.transaction_id out_req_transaction_id,
    --L_arg_io_batch_number Batch_id,
    msi1.sr_inventory_item_id inventory_item_id,
    msi1.uom_code,
    s1.organization_id,
    s1.new_schedule_date promise_date,
    s.implement_location_id,
    s.Load_Type,
    s.implement_source_org_id
 FROM msc_supplies s,
    msc_supplies s1,
    msc_supplies s2,
    msc_system_items msi1,
    msc_demands d,
    msc_demands d1,
    msc_demands d2,
    MFG0 mfg,
    mfg0 mfg1
  WHERE s.release_errors IS NULL
   AND s.sr_instance_id = '||p_arg_org_instance||
 ' AND s.plan_id = '|| p_arg_plan_id ||
 ' AND s.transaction_id = d.disposition_id
   AND s.sr_instance_id = d.sr_instance_id
   AND s.plan_id = d.plan_id
   AND d.origination_type = 1 --- Planned order demand
   AND d.demand_id = mfg.demand_id
   AND d.plan_id = mfg.plan_id
   AND d.sr_instance_id = mfg.sr_instance_id
   AND d.organization_id = mfg.organization_id
   AND mfg.transaction_id = s1.transaction_id
   AND mfg.plan_id = s1.plan_id
   AND s1.sr_instance_id = msi1.sr_instance_id
   AND s1.plan_id = msi1.plan_id
   AND s1.inventory_item_id = msi1.inventory_item_id
   AND s1.organization_id = msi1.organization_id
   AND s1.transaction_id = d1.disposition_id
   AND s1.sr_instance_id = d1.sr_instance_id
   AND s1.plan_id = d1.plan_id
   AND d1.origination_type = 78 -- planned defective part demand
   AND d1.demand_id = mfg1.demand_id(+)
   AND d1.plan_id = mfg1.plan_id(+)
   AND d1.sr_instance_id = mfg1.sr_instance_id(+)
   AND D1.organization_id = mfg1.organization_id (+)
   AND mfg1.transaction_id = s2.transaction_id(+)
   AND mfg1.plan_id = s2.plan_id(+)
   AND s2.transaction_id = d2.disposition_id(+)
   AND s2.sr_instance_id = d2.sr_instance_id(+)
   AND s2.plan_id = d2.plan_id(+)
   AND d2.origination_type(+) = 1
   and (s.releasable = ' || RELEASABLE  || ' or s.releasable is null )';

    IF  v_batch_id_populated = 2 THEN

        l_sql_qry2 :=  l_sql_qry2 || ' AND  s.batch_id is NULL ';
    ELSE

        l_sql_qry2 :=  l_sql_qry2 || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    l_sql_qry2:= l_sql_qry2  ||p_where_clause;



 IF ((p_arg_mode IS NULL) OR (p_arg_mode = 'WF')) THEN

  -- bulk collect l_sql_qry2 into lv_IRO_list;
  EXECUTE IMMEDIATE l_sql_qry2
          bulk collect INTO
    lv_transaction_id_lst,
    lv_quantity_lst,
    lv_in_req_quantity_lst,
    lv_out_req_quantity_lst,
    lv_in_req_transaction_id_lst,
    lv_out_req_transaction_id_lst,
    lv_inventory_item_id_lst,
    lv_uom_code_lst,
    lv_organization_id_lst,
    lv_promise_date_lst,
    lv_implement_location_id,
    lv_load_type_lst,
    lv_implement_source_org_id
 ;

 END IF;

   p_where_clause :=null ;


  /* 4.1 iterate through  the record in table type and update the load type for transaction_id corresponding to in_req_transaction_id to  32 */
     for i IN 1 .. lv_in_req_transaction_id_lst.count LOOP

          /*4.2 calling the api to update implement_* column */
        IF (lv_in_req_transaction_id_lst(i) is not NULL) THEN

          p_where_clause := ' transaction_id = ' || lv_in_req_transaction_id_lst(i);

             MSC_SELECT_ALL_FOR_RELEASE_PUB.Update_Implement_Attrib(p_where_clause ,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          p_total_rows ,
                                          p_succ_rows ,
                                          p_error_rows
                                          );
             /* debuf msg
                select --implement_quantity,
                new_order_quantity, release_errors
                into lv_implement_quantity, lv_release_errors from msc_supplies
                where plan_id =  p_arg_plan_id
                and   transaction_id =  lv_in_req_transaction_id_lst(i);
              */

              UPDATE msc_supplies
              SET load_type = 32,
                 release_status = 2,
                 implement_quantity = new_order_quantity,  --to be removed if above api works fine
                 release_errors = NULL,
                batch_id=decode(v_batch_id_populated,2,batch_id,g_batch_id)
              WHERE transaction_id = lv_in_req_transaction_id_lst(i)
                and plan_id =p_arg_plan_id ;

         END IF;
    END LOOP;

  /* 5. bulk insert the data in the table type to mrp_iro_release table in the source */
  FOR i IN 1 .. lv_transaction_id_lst.COUNT
  LOOP

    l_sql_qry := 'insert into mrp_iro_release' || p_dblink || '(Transaction_id,
                          Quantity,
                          in_req_quantity,
                          out_req_quantity,
                          In_req_transaction_id,
                          Out_req_transaction_id,
                          Batch_id,
                          Inventory_item_id,
                          Uom_code,
                          Organization_id,
                          Promise_date,
                          Load_Type,
                          deliver_to_location_id,
                          src_organization_id)
                  values (:lv_Transaction_id,
                          :lv_Quantity,
                          :lv_in_req_quantity,
                          :lv_out_req_quantity,
                          :lv_In_req_transaction_id,
                          :lv_Out_req_transaction_id,
                          :p_arg_iro_batch_number,
                          :lv_Inventory_item,
                          :lv_uom_code ,
                          :lv_organization_id,
                          :lv_Promise_date,
                          :Load_Type,
                          :implement_location_id,
                          :implement_source_org_id)';

    EXECUTE IMMEDIATE l_sql_qry USING lv_transaction_id_lst(i),
      lv_quantity_lst(i),
      lv_in_req_quantity_lst(i),
      lv_out_req_quantity_lst(i),
      lv_in_req_transaction_id_lst(i),
      lv_out_req_transaction_id_lst(i),
      p_arg_iro_batch_number,
      lv_inventory_item_id_lst(i),
      lv_uom_code_lst(i),
      lv_organization_id_lst(i),
      lv_promise_date_lst(i),
      lv_load_type_lst(i),
      lv_implement_location_id(i),
      lv_implement_source_org_id(i);

    p_arg_loaded_int_repair_orders := p_arg_loaded_int_repair_orders + 1 ;

        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id =p_arg_plan_id
           and transaction_id= lv_transaction_id_lst(i);

  END LOOP;

  /*
  OPEN c_row_count FOR l_sql_cur USING p_arg_iro_batch_number;
  FETCH c_row_count
  INTO l_after_row_count;
  CLOSE c_row_count;
  */

  --p_arg_loaded_int_repair_orders:= l_after_row_count -l_before_row_count;
  /* 6. call populate_iso_in_source to populate mrp_org_transfer_release_table in the source */

  IF p_arg_loaded_int_repair_orders > 0 THEN

      populate_iso_in_source(l_dblink => p_dblink,
       l_arg_po_batch_number => p_arg_iro_batch_number,
       l_arg_owning_instance => p_arg_owning_instance,
       l_arg_po_group_by => p_arg_po_group_by,
       l_arg_plan_id => p_arg_plan_id,
       l_arg_log_org_id => p_arg_log_org_id,
       l_arg_owning_org_id => p_arg_owning_org_id,
       l_arg_org_instance => p_arg_org_instance,
       l_arg_mode => p_arg_mode,
       l_arg_transaction_id => p_arg_transaction_id,
       arg_loaded_int_reqs => p_new_iso_num,
       arg_resched_int_reqs => p_reschedule_iso_num,
       p_load_type => drp_req_load);
  END IF;

  l_sql_qry := NULL;

  /* 7. update the load type to null which had been updated to 32   previously */
   for i IN 1 .. lv_in_req_transaction_id_lst.count LOOP

    If (lv_in_req_transaction_id_lst(i) is NULL) then

        l_sql_qry :=     'UPDATE msc_supplies '
                          ||'SET load_type = NULL
                          WHERE plan_id= :p_arg_plan_id AND transaction_id = '||lv_out_req_transaction_id_lst(i) ;

     Else

        l_sql_qry :=     'UPDATE msc_supplies '
                          ||'SET load_type = NULL WHERE plan_id= :p_arg_plan_id AND transaction_id in ('
                          || lv_in_req_transaction_id_lst(i)||','||lv_out_req_transaction_id_lst(i)||')' ;
    ENd if;

        execute immediate l_sql_qry
        USING p_arg_plan_id;



   END LOOP;
  /*
   forall i IN 1 .. lv_out_req_transaction_id_lst.count
        UPDATE msc_supplies
        SET load_type = NULL
        WHERE transaction_id = lv_out_req_transaction_id_lst(i)
        and plan_id =p_arg_plan_id ;
   */

  Exception
  When Others Then

   raise;
END release_iro;


PROCEDURE RELEASE_IRO_2(
    p_dblink IN VARCHAR2,
    p_arg_iro_batch_number IN NUMBER,
    p_arg_owning_instance IN NUMBER,
    p_arg_po_group_by IN NUMBER,
    p_arg_plan_id IN NUMBER,
    p_arg_log_org_id IN NUMBER,
    p_arg_owning_org_id IN NUMBER,
    p_arg_org_instance IN NUMBER,
    p_arg_mode IN VARCHAR2,
    p_arg_transaction_id IN NUMBER,
    p_arg_loaded_int_repair_orders IN OUT nocopy NUMBER,
    p_load_type IN NUMBER)
IS
--l_sql_cur VARCHAR2(3000) := NULL;
l_sql_qry VARCHAR2(3000) := NULL;
l_sql_qry2 varchar2(3000) := NULL;
p_new_iso_num NUMBER;
p_where_clause varchar2(3000):= NULL;
p_total_rows  NUMBER;
p_succ_rows  NUMBER;
p_error_rows  NUMBER;
p_reschedule_iso_num NUMBER;

/* CURSOR c1(v_arg_mode VARCHAR2,
    v_arg_org_instance NUMBER,
    v_load_type NUMBER,
    v_arg_transaction_id NUMBER,
    v_arg_plan_id NUMBER) IS
*/

    type numlisttyp IS TABLE OF NUMBER;
    type datelisttyp IS TABLE OF DATE;
    type varlisttyp IS TABLE OF VARCHAR2(30);

    lv_transaction_id_lst numlisttyp;
    lv_quantity_lst numlisttyp;
    lv_in_req_quantity_lst numlisttyp;
    lv_load_type_lst  numlisttyp;
    lv_out_req_quantity_lst numlisttyp;
    lv_in_req_transaction_id_lst numlisttyp;
    lv_out_req_transaction_id_lst numlisttyp;
    lv_inventory_item_id_lst numlisttyp;
    lv_uom_code_lst varlisttyp;
    lv_organization_id_lst numlisttyp;
    lv_promise_date_lst datelisttyp;
    lv_implement_location_id  numlisttyp;
    lv_implement_source_org_id numlisttyp;
    lv_orig_transaction_id_lst numlisttyp;

    --lv_implement_quantity number;
BEGIN
  /* 1. get the row count for the new batch  if in table MRP_IRO_RELEASE */

   p_arg_loaded_int_repair_orders:=0;

   IF p_arg_mode IS NULL THEN
     p_where_clause:= ' AND k.load_type = '||p_load_type ;

   ELSIF p_arg_mode = 'WF' THEN
       p_where_clause:= ' AND k.transaction_id = '||p_arg_transaction_id;

  ELSE
      -- log_msg('no IROs to release....');
       return ;
    END IF;

  /* 3. bulk collect all the records returned by record  by above cursor into table types record */
l_sql_qry2:=

'with mfg0 AS
    ( select transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id ,
                sum(allocated_quantity) allocated_quantity
             from msc_part_pegging
             where sr_instance_id = '||p_arg_org_instance|| '
             and plan_id = '|| p_arg_plan_id ||'
             group by transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id
      )
 SELECT /*+ LEADING(s d) */
    s1.transaction_id,
    s1.new_order_quantity quantity,
    s2.new_order_quantity in_req_quantity,
    s.new_order_quantity  out_req_quantity,
    Decode(s2.order_type,51,s2.transaction_id, null)  in_req_transaction_id,
    s.transaction_id out_req_transaction_id,
    --L_arg_io_batch_number Batch_id,
    msi1.sr_inventory_item_id inventory_item_id,
    msi1.uom_code,
    s1.organization_id,
    s1.new_schedule_date promise_date,
    s.implement_location_id,
    k.Load_Type,
    s.implement_source_org_id,
    k.transaction_id
FROM
msc_supplies k,
msc_part_supplies s,
msc_part_demands d,
mfg0 mfg,
msc_part_supplies s1,
msc_part_demands d1,
mfg0 mfg1,
msc_part_supplies s2,
msc_part_demands d2,
msc_system_items msi1
WHERE
   k.release_errors IS NULL
   AND (k.releasable = ' || RELEASABLE || ' or k.releasable is null )
   AND k.sr_instance_id = '||p_arg_org_instance|| '
   AND k.plan_id = '|| p_arg_plan_id ||'  --K.batchidid filter and k.transctionid/k.load_typefilter added dynamically
   AND k.TRANSACTION_ID = s.ORIG_TRANSACTION_ID
   AND s.transaction_id = d.disposition_id
   AND s.sr_instance_id = d.sr_instance_id
   AND s.plan_id = d.plan_id
   AND d.origination_type = 1 --- Planned order demand
   AND d.demand_id = mfg.demand_id
   AND d.plan_id = mfg.plan_id
   AND d.sr_instance_id = mfg.sr_instance_id
   AND d.organization_id = mfg.organization_id
   AND mfg.transaction_id = s1.transaction_id
   AND mfg.plan_id = s1.plan_id
   AND s1.plan_id = msi1.plan_id
   AND s1.sr_instance_id = msi1.sr_instance_id
   AND s1.organization_id = msi1.organization_id
   AND s1.inventory_item_id = msi1.inventory_item_id
   AND s1.transaction_id = d1.disposition_id
   AND s1.sr_instance_id = d1.sr_instance_id
   AND s1.plan_id = d1.plan_id
   AND d1.origination_type = 78 -- planned defective part demand
   AND d1.plan_id = mfg1.plan_id (+)
   AND d1.sr_instance_id = mfg1.sr_instance_id (+)
   AND d1.organization_id = mfg1.organization_id (+)
   AND d1.demand_id = mfg1.demand_id (+)
   AND mfg1.transaction_id = s2.transaction_id(+)
   AND mfg1.plan_id = s2.plan_id(+)
   AND s2.transaction_id = d2.disposition_id(+)
   AND s2.sr_instance_id = d2.sr_instance_id(+)
   AND s2.plan_id = d2.plan_id(+)
   AND d2.origination_type(+) = 1';

    IF  v_batch_id_populated = 2 THEN
        l_sql_qry2 :=  l_sql_qry2 || ' AND  k.batch_id is NULL ';
    ELSE
        l_sql_qry2 :=  l_sql_qry2 || ' AND  k.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    l_sql_qry2:= l_sql_qry2  ||p_where_clause;



 IF ((p_arg_mode IS NULL) OR (p_arg_mode = 'WF')) THEN
  -- bulk collect l_sql_qry2 into lv_IRO_list;
  EXECUTE IMMEDIATE l_sql_qry2
    bulk collect INTO
    lv_transaction_id_lst,
    lv_quantity_lst,
    lv_in_req_quantity_lst,
    lv_out_req_quantity_lst,
    lv_in_req_transaction_id_lst,
    lv_out_req_transaction_id_lst,
    lv_inventory_item_id_lst,
    lv_uom_code_lst,
    lv_organization_id_lst,
    lv_promise_date_lst,
    lv_implement_location_id,
    lv_load_type_lst,
    lv_implement_source_org_id,
    lv_orig_transaction_id_lst
 ;
 END IF;

   p_where_clause :=null ;


  /* 4.1 iterate through  the record in table type and update the load type for transaction_id corresponding to in_req_transaction_id to  32 */
     for i IN 1 .. lv_orig_transaction_id_lst.count LOOP


              UPDATE msc_supplies
              SET --load_type = 32,
                 release_status = 2,
                -- implement_quantity = new_order_quantity,  --to be removed if above api works fine
                 --release_errors = NULL,
                batch_id=decode(v_batch_id_populated,2,batch_id,g_batch_id)
              WHERE transaction_id = lv_orig_transaction_id_lst(i)
                and plan_id =p_arg_plan_id ;
      END LOOP;

     for i IN 1 .. lv_in_req_transaction_id_lst.count LOOP

         UPDATE msc_part_supplies
              SET load_type = 32,
                --release_status = 2,
                --implement_quantity = new_order_quantity,  --to be removed if above api works fine
                release_errors = NULL,
                batch_id=decode(v_batch_id_populated,2,batch_id,g_batch_id)
              WHERE transaction_id in ( lv_in_req_transaction_id_lst(i),lv_out_req_transaction_id_lst(i))
              and plan_id =p_arg_plan_id ;


    END LOOP;


  /* 5. bulk insert the data in the table type to mrp_iro_release table in the source */
  FOR i IN 1 .. lv_transaction_id_lst.COUNT
  LOOP

    l_sql_qry := 'insert into mrp_iro_release' || p_dblink || '(Transaction_id,
                          Quantity,
                          in_req_quantity,
                          out_req_quantity,
                          In_req_transaction_id,
                          Out_req_transaction_id,
                          Batch_id,
                          Inventory_item_id,
                          Uom_code,
                          Organization_id,
                          Promise_date,
                          Load_Type,
                          deliver_to_location_id,
                          src_organization_id)
                  values (:lv_Transaction_id,
                          :lv_Quantity,
                          :lv_in_req_quantity,
                          :lv_out_req_quantity,
                          :lv_In_req_transaction_id,
                          :lv_Out_req_transaction_id,
                          :p_arg_iro_batch_number,
                          :lv_Inventory_item,
                          :lv_uom_code ,
                          :lv_organization_id,
                          :lv_Promise_date,
                          :Load_Type,
                          :implement_location_id,
                          :implement_source_org_id)';

    EXECUTE IMMEDIATE l_sql_qry USING
      lv_transaction_id_lst(i),
      lv_quantity_lst(i),
      lv_in_req_quantity_lst(i),
      lv_out_req_quantity_lst(i),
      lv_in_req_transaction_id_lst(i),
      lv_out_req_transaction_id_lst(i),
      p_arg_iro_batch_number,
      lv_inventory_item_id_lst(i),
      lv_uom_code_lst(i),
      lv_organization_id_lst(i),
      lv_promise_date_lst(i),
      lv_load_type_lst(i),
      lv_implement_location_id(i),
      lv_implement_source_org_id(i);


    p_arg_loaded_int_repair_orders := p_arg_loaded_int_repair_orders + 1 ;

        update msc_supplies  -- change the variable name to lv_orig_transaction_id
           set releasable = RELEASE_ATTEMPTED,
               batch_id   = nvl(batch_id,g_batch_id)
           where plan_id = p_arg_plan_id
           and transaction_id= lv_orig_transaction_id_lst(i);

        /*    update msc_part_supplies
           set releasable = RELEASE_ATTEMPTED,
               batch_id   = nvl(batch_id,g_batch_id)
           where plan_id = p_arg_plan_id
           and transaction_id= lv_transaction_id_lst(i);*/

    END LOOP;

     /*
  OPEN c_row_count FOR l_sql_cur USING p_arg_iro_batch_number;
  FETCH c_row_count
  INTO l_after_row_count;
  CLOSE c_row_count;
  */


  --p_arg_loaded_int_repair_orders:= l_after_row_count -l_before_row_count;


  /* 6. call POPULATE_ISO_IN_SOURCE_2 to populate mrp_org_transfer_release_table in the source */

  IF p_arg_loaded_int_repair_orders > 0 THEN

      populate_iso_in_source_2(l_dblink => p_dblink,
       l_arg_po_batch_number => p_arg_iro_batch_number,
       l_arg_owning_instance => p_arg_owning_instance,
       l_arg_po_group_by => p_arg_po_group_by,
       l_arg_plan_id => p_arg_plan_id,
       l_arg_log_org_id => p_arg_log_org_id,
       l_arg_owning_org_id => p_arg_owning_org_id,
       l_arg_org_instance => p_arg_org_instance,
       l_arg_mode => p_arg_mode,
       l_arg_transaction_id => p_arg_transaction_id,
       arg_loaded_int_reqs => p_new_iso_num,
       arg_resched_int_reqs => p_reschedule_iso_num,
       p_load_type => drp_req_load);
  END IF;

  l_sql_qry := NULL;

  Exception
  When Others Then
  Raise;
END release_iro_2;

PROCEDURE Release_Ero(
    p_dblink IN VARCHAR2,
    p_arg_ero_batch_number IN number,
    p_arg_owning_instance IN NUMBER,
    p_arg_po_group_by IN NUMBER,
    p_arg_plan_id IN NUMBER,
    p_arg_log_org_id IN NUMBER,
    p_arg_owning_org_id IN NUMBER,
    p_arg_org_instance IN NUMBER,
    p_arg_mode IN VARCHAR2,
    p_arg_transaction_id IN NUMBER,
    p_arg_loaded_ext_repair_orders IN OUT nocopy NUMBER,
    p_load_type IN NUMBER)
IS

l_sql_qry VARCHAR2(8000) := NULL;
l_sql_cnt_qry VARCHAR2(500) := NULL;
p_count NUMBER;
BEGIN

  l_sql_qry := '
    Insert into MRP_ERO_RELEASE'||p_dblink||
    '  (TRANSACTION_ID,
    REPAIR_SUPPLIER_ID ,
    REPAIR_SUPPLIER_ORG_ID ,
    REPAIR_PROGRAM ,
    BATCH_ID ,
    DESTINATION_ORG_ID  ,
    SOURCE_ORG_ID ,
    INVENTORY_ITEM_ID ,
    PROMISE_DATE  ,
    QUANTITY  ,
    DEFECTIVE_ITEM_ID,
    DEFECTIVE_ITEM_QTY)
Select
    s.transaction_id ,
    mtp1.sr_tp_id   repair_supplier_id ,
    s1.organization_id  repair_supplier_org_id ,
    msi.repair_program  repair_program,
     '||p_arg_ero_batch_number||'  ,
    s.organization_id  destination_organization_id ,
    d2.organization_id source_organization_id ,
    msi.sr_inventory_item_id repair_to_item_id ,
    nvl(s.implement_dock_date , nvl(s.new_dock_date, sysdate ) ) need_by_date,
    s.implement_quantity quantity,
    msi1.sr_inventory_item_id  defective_item_id,
    s2.new_order_quantity defective_part_quantity
FROM msc_supplies s,
     Msc_supplies s1,
     Msc_supplies s2 ,
     msc_system_items msi,
     msc_system_items msi1,
     msc_trading_partners mtp,
     msc_trading_partners mtp1,
     msc_demands d  ,
     msc_demands d1,
     msc_demands d2,
    (  select distinct transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id
             from msc_full_pegging
             where sr_instance_id = '||p_arg_org_instance||'
             and plan_id ='||p_arg_plan_id||'
      ) mfg,
     (  select  transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id ,
                 sum(allocated_quantity) allocated_quantity
                from msc_full_pegging
                where sr_instance_id = '||p_arg_org_instance||'
                and plan_id ='||p_arg_plan_id||'
                group by transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id
      ) mfg1
WHERE s.release_errors is NULL
    AND (s.releasable = ' || RELEASABLE || ' or s.releasable is null )
    AND   s.implement_quantity > 0
    AND   s.sr_instance_id = '||p_arg_org_instance||
'    AND   s.plan_id = '||p_arg_plan_id||'
    AND  ((:l_arg_mode is null and s.load_type = :p_load_type  and s.load_type IS NOT NULL) OR (:l_arg_mode = ''WF'' and s.transaction_id =:l_arg_transaction_id))
    AND   msi.inventory_item_id = s.inventory_item_id
    AND   msi.plan_id = s.plan_id
    AND   msi.organization_id = s.organization_id
    AND   msi.sr_instance_id = s.sr_instance_id
    AND   s.transaction_id =d.disposition_id
    AND   s.sr_instance_id = d.sr_instance_id
    And   s.plan_id =d.plan_id
    And   d.origination_type= 1 --- Planned order demand
    And   d.demand_id  = mfg.demand_id
    And   d.plan_id  = mfg.plan_id
    And   d.sr_instance_id =mfg.sr_instance_id
    And   d.organization_id=  mfg.organization_id
    And   mfg.transaction_id =s1.transaction_id
    And   mfg.plan_id=s1.plan_id
    AND   mtp.sr_tp_id  = s1.organization_id
    AND   mtp.sr_instance_id = s1.sr_instance_id
    AND   mtp.partner_type= 3
    And   mtp.modeled_supplier_id = mtp1.partner_id
    AND   s1.transaction_id =d1.disposition_id
    AND   s1.sr_instance_id = d1.sr_instance_id
    And   s1.plan_id =d1.plan_id
    And   d1.origination_type= 78 -- planned defective part demand
    And   d1.demand_id  = mfg1.demand_id
    And   d1.plan_id  = mfg1.plan_id
    And   d1.sr_instance_id =mfg1.sr_instance_id
    And   mfg1.organization_id = mfg1.organization_id
    And   mfg1.transaction_id = s2.transaction_id
    And   mfg1.plan_id =s2.plan_id
    AND   s2.transaction_id =d2.disposition_id
    AND   s2.sr_instance_id = d2.sr_instance_id
    And   s2.plan_id =d2.plan_id
    And   d2.origination_type= 1 -- planned defective out bound shipment
    And   d2.sr_instance_id = msi1.sr_instance_id
    And   d2.plan_id = msi1.plan_id
    And   d2.inventory_item_id = msi1.inventory_item_id
    And   d2.organization_id = msi1.organization_id'  ;

    IF  v_batch_id_populated = 2 THEN
        l_sql_qry :=  l_sql_qry || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_qry :=  l_sql_qry || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

 Execute immediate l_sql_qry
  USING
      p_arg_mode,
      p_load_type,
      p_arg_mode,
      p_arg_transaction_id;

   l_sql_cnt_qry := 'select count(*)
   from mrp_ero_release'||p_dblink|| '  where batch_id = '||p_arg_ero_batch_number;

   Execute immediate l_sql_cnt_qry
   INTO p_count;

   IF p_arg_mode = 'WF' THEN
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = p_arg_plan_id
           and transaction_id= p_arg_transaction_id;
   ELSE
        execute immediate 'update msc_supplies
                               set releasable = ' || RELEASE_ATTEMPTED || '
                               ,batch_id   = nvl(batch_id,' ||g_batch_id || ')
                             where plan_id = ' || p_arg_plan_id || '
                               and transaction_id in
                                    (select transaction_id from mrp_ero_release' ||p_dblink||'
                                        where batch_id = ' || p_arg_ero_batch_number || ')';
   END IF;

  p_arg_loaded_ext_repair_orders := p_count;

  Exception
  When Others Then
  raise;

END Release_Ero;

PROCEDURE Release_Ero_2(
    p_dblink IN VARCHAR2,
    p_arg_ero_batch_number IN number,
    p_arg_owning_instance IN NUMBER,
    p_arg_po_group_by IN NUMBER,
    p_arg_plan_id IN NUMBER,
    p_arg_log_org_id IN NUMBER,
    p_arg_owning_org_id IN NUMBER,
    p_arg_org_instance IN NUMBER,
    p_arg_mode IN VARCHAR2,
    p_arg_transaction_id IN NUMBER,
    p_arg_loaded_ext_repair_orders IN OUT nocopy NUMBER,
    p_load_type IN NUMBER)
IS
l_sql_qry VARCHAR2(8000) := NULL;
l_sql_cnt_qry VARCHAR2(500) := NULL;
p_count NUMBER;
BEGIN

  l_sql_qry := '
    Insert into MRP_ERO_RELEASE'||p_dblink||
    '  (TRANSACTION_ID,
    REPAIR_SUPPLIER_ID ,
    REPAIR_SUPPLIER_ORG_ID ,
    REPAIR_PROGRAM ,
    BATCH_ID ,
    DESTINATION_ORG_ID  ,
    SOURCE_ORG_ID ,
    INVENTORY_ITEM_ID ,
    PROMISE_DATE  ,
    QUANTITY  ,
    DEFECTIVE_ITEM_ID,
    DEFECTIVE_ITEM_QTY)
Select
    s.transaction_id ,
    mtp1.sr_tp_id   repair_supplier_id ,
    s1.organization_id  repair_supplier_org_id ,
    msi.repair_program  repair_program,
     '||p_arg_ero_batch_number||'  ,
    s.organization_id  destination_organization_id ,
    d2.organization_id source_organization_id ,
    msi.sr_inventory_item_id repair_to_item_id ,
    nvl(s.implement_dock_date , nvl(s.new_dock_date, sysdate ) ) need_by_date,
    s.implement_quantity quantity,
    msi1.sr_inventory_item_id  defective_item_id,
    s2.new_order_quantity defective_part_quantity
FROM
     msc_supplies k,
     msc_system_items msi,
     msc_part_supplies s,
     msc_part_demands d,
     Msc_part_supplies s1,
     msc_trading_partners mtp,
     msc_trading_partners mtp1,
     msc_part_demands d1,
     Msc_part_supplies s2,
     msc_part_demands d2,
     msc_system_items msi1,
    (select distinct transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id
             from msc_part_pegging
             where sr_instance_id = '||p_arg_org_instance||'
             and plan_id ='||p_arg_plan_id||'
      ) mfg,
     (  select  transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id ,
                 sum(allocated_quantity) allocated_quantity
                from msc_part_pegging
                where sr_instance_id = '||p_arg_org_instance||'
                and plan_id ='||p_arg_plan_id||'
                group by transaction_id,plan_id,organization_id ,sr_instance_id ,demand_id
      ) mfg1
WHERE k.release_errors is NULL
    AND (k.releasable = ' || RELEASABLE || ' or k.releasable is null )
    AND   k.implement_quantity > 0
    AND   k.sr_instance_id = '||p_arg_org_instance||
'   AND   k.plan_id = '||p_arg_plan_id||'
    AND  ((:l_arg_mode is null and k.load_type = :p_load_type and k.load_type IS NOT NULL) OR (:l_arg_mode = ''WF'' and k.transaction_id =:l_arg_transaction_id))
    AND k.TRANSACTION_ID = s.ORIG_TRANSACTION_ID
    AND   msi.inventory_item_id = s.inventory_item_id
    AND   msi.plan_id = s.plan_id
    AND   msi.organization_id = s.organization_id
    AND   msi.sr_instance_id = s.sr_instance_id
    AND   s.transaction_id =d.disposition_id
    AND   s.sr_instance_id = d.sr_instance_id
    And   s.plan_id =d.plan_id
    And   d.origination_type= 1 --- Planned order demand
    And   d.demand_id  = mfg.demand_id
    And   d.plan_id  = mfg.plan_id
    And   d.sr_instance_id =mfg.sr_instance_id
    And   d.organization_id=  mfg.organization_id
    And   mfg.transaction_id =s1.transaction_id
    And   mfg.plan_id=s1.plan_id
    AND   mtp.sr_tp_id  = s1.organization_id
    AND   mtp.sr_instance_id = s1.sr_instance_id
    AND   mtp.partner_type= 3
    And   mtp.modeled_supplier_id = mtp1.partner_id
    AND   s1.transaction_id =d1.disposition_id
    AND   s1.sr_instance_id = d1.sr_instance_id
    And   s1.plan_id =d1.plan_id
    And   d1.origination_type= 78 -- planned defective part demand
    And   d1.demand_id  = mfg1.demand_id
    And   d1.plan_id  = mfg1.plan_id
    And   d1.sr_instance_id =mfg1.sr_instance_id
    And   mfg1.organization_id = s2.organization_id
    And   mfg1.transaction_id = s2.transaction_id
    And   mfg1.plan_id =s2.plan_id
    AND   s2.transaction_id =d2.disposition_id
    AND   s2.sr_instance_id = d2.sr_instance_id
    And   s2.plan_id =d2.plan_id
    And   d2.origination_type= 1 -- planned defective out bound shipment
    And   d2.sr_instance_id = msi1.sr_instance_id
    And   d2.plan_id = msi1.plan_id
    And   d2.inventory_item_id = msi1.inventory_item_id
    And   d2.organization_id = msi1.organization_id ' ;

    IF  v_batch_id_populated = 2 THEN
        l_sql_qry :=  l_sql_qry || ' AND  k.batch_id is NULL ';
    ELSE
        l_sql_qry :=  l_sql_qry || ' AND  k.batch_id = ' || g_batch_id || ' ' ;
    END IF;

 Execute immediate l_sql_qry
  USING
      p_arg_mode,
      p_load_type,
      p_arg_mode,
      p_arg_transaction_id;

 p_count := SQL%ROWCOUNT;

   IF p_arg_mode = 'WF' THEN
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = p_arg_plan_id
           and transaction_id= p_arg_transaction_id;

           update msc_part_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id = g_batch_id
         where plan_id = p_arg_plan_id
           and orig_transaction_id= p_arg_transaction_id;
   ELSE
        execute immediate 'update msc_supplies
                               set releasable = ' || RELEASE_ATTEMPTED || '
                               ,batch_id   = nvl(batch_id,' ||g_batch_id || ')
                             where plan_id = ' || p_arg_plan_id || '
                               and transaction_id in (select orig_transaction_id from msc_part_supplies where transaction_id in
                                    (select transaction_id from mrp_ero_release' ||p_dblink||'
                                        where batch_id = ' || p_arg_ero_batch_number || '))';

        execute immediate 'update msc_part_supplies
                               set releasable = ' || RELEASE_ATTEMPTED || '
                               ,batch_id   =' || g_batch_id || '
                             where plan_id = ' || p_arg_plan_id || '
                               and transaction_id in
                                    (select transaction_id from mrp_ero_release' ||p_dblink||'
                                        where batch_id = ' || p_arg_ero_batch_number || ')';
   END IF;

   p_arg_loaded_ext_repair_orders := p_count;


  Exception
  When Others Then
  raise;

END Release_Ero_2;


FUNCTION load_osfm_lot_jobs
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_mode                      IN      VARCHAR2
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
   lv_details_enabled     NumTab;
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
     a. Unconstrained Plan
     b. if the new_wip_start_date is null
     c. if the implement quantity or date is different then the planned quantity date
     d. if the revision date is different then the new_wip_start_date
        and the profile option setting : MSC_RELEASE_DTLS_REVDATE  = 'N'
     e. Non - Daily Bucketed Plans
      f.bug 4655420-Alternate BOM/Routing is changed during release.
  */
  /* Ignore the profile option
      MSC: Release WIP Dtls if Order Date different then BOM Revision Date.
     in case of RP plan
  */
   if (v_rp_plan = 1 ) then
     lv_release_details := 1;
   end if;
l_sql_stmt := '   SELECT s.transaction_id,
   	  s.sr_instance_id,
   	  decode( mp.daily_material_constraints+ mp.daily_resource_constraints+
                  mp.weekly_material_constraints+ mp.weekly_resource_constraints+
                  mp.period_material_constraints+ mp.period_resource_constraints,12,2,
               decode(mpb.bucket_type,1,
               DECODE( s.implement_quantity, s.new_order_quantity,
                     DECODE( s.implement_date, s.new_schedule_date,
                      DECODE(NVL(s.implement_alternate_bom, ''-23453''),
                     			 NVL(s.alternate_bom_designator, ''-23453''),
                				DECODE(NVL(s.implement_alternate_routing, ''-23453''),
                       			NVL(s.alternate_routing_designator, ''-23453''),
                        DECODE(trunc(msc_calendar.date_offset
                              (s.organization_id,
                               s.sr_instance_id,
                               1, --daily bucket
                               s.need_by_date ,
                               ceil(nvl(msi.fixed_lead_time,0) +
                 nvl(msi.variable_lead_time,0) * s.implement_quantity)*-1 )),
                     trunc(s.new_wip_start_date),1,
                                   decode(' || lv_release_details || ' ,2,2,1)),
                           2),
                         2),
                       2),
                     2),
                 2)),
         s.organization_id,
         s.plan_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs,
          msc_plan_buckets mpb,
          msc_system_items msi,
          msc_plans mp
    WHERE  mp.plan_id = :arg_plan_id
    AND   s.release_errors is NULL
    AND   nvl(s.cfm_routing_flag,0) = 3
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = :arg_plan_id
    AND   orgs.plan_id = :arg_plan_id
    AND   orgs.organization_id = :arg_owning_org_id
    AND   orgs.owning_sr_instance = :arg_owning_instance
    AND   orgs.sr_instance_id = :arg_org_instance ' ;

    IF arg_log_org_id <> arg_owning_org_id THEN
            l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;

    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = 5 ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = 5 ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

        l_sql_stmt :=  l_sql_stmt || ' AND   s.plan_id = mpb.plan_id
    AND  (nvl(s.implement_date,s.new_schedule_date) between mpb.bkt_start_date and mpb.bkt_end_date)
    AND   s.new_wip_start_date IS NOT NULL
    AND   msi.inventory_item_id = s.inventory_item_id
    AND   msi.plan_id = s.plan_id
    AND   msi.organization_id = s.organization_id
    AND   msi.sr_instance_id = s.sr_instance_id
    and (s.releasable = ' || RELEASABLE || ' or s.releasable is null ) ';

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;
    l_sql_stmt :=  l_sql_stmt || '
UNION
  SELECT s.transaction_id,
          s.sr_instance_id,
          2 /* Details not enabled for Manual Planned orders */,
          s.organization_id,
          s.plan_id
     FROM msc_supplies s,
          msc_plan_organizations_v orgs
    WHERE s.release_errors is NULL
    AND   nvl(s.cfm_routing_flag,0) = 3
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = :arg_plan_id
    AND   orgs.plan_id = :arg_plan_id
    AND   orgs.organization_id = :arg_owning_org_id
    AND   orgs.owning_sr_instance = :arg_owning_instance
    AND   orgs.sr_instance_id = :arg_org_instance
    and   s.new_wip_start_date IS NULL
    and (s.releasable = ' || RELEASABLE || ' or s.releasable is null )' ;

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    IF arg_log_org_id <> arg_owning_org_id THEN
            l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;

    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = 5 ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = 5 ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

    lv_job_count:= 0;
    IF arg_mode IS NULL OR arg_mode = 'WF_BATCH' OR arg_mode = 'WF' THEN
        EXECUTE IMMEDIATE l_sql_stmt
              BULK COLLECT     INTO   lv_transaction_id,
                                      lv_instance_id,
                                      lv_details_enabled,
                                      lv_org_id,
                                      lv_plan_id
                                    USING  arg_plan_id
                                            ,arg_plan_id
                                            ,arg_plan_id
                                            ,arg_owning_org_id
                                            ,arg_owning_instance
                                            ,arg_org_instance
                                            ,arg_plan_id
                                            ,arg_plan_id
                                            ,arg_owning_org_id
                                            ,arg_owning_instance
                                            ,arg_org_instance;
        lv_job_count:= SQL%ROWCOUNT;
    END IF;



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
                   AND deptres.plan_id  = resreq.plan_id
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
            SR_INSTANCE_ID
            -- dsr: 2 new columns
            , schedule_priority
            , requested_completion_date
            )
    SELECT  SYSDATE,
            nvl(s.cfm_routing_flag,0),
            arg_user_id,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            s.transaction_id,
            msi.organization_id,
            tp.organization_type,
            5,
            s.implement_status_code,
            decode(lv_details_enabled(j),1,new_wip_start_date,null),
            s.implement_date,
            s.new_wip_start_date,
            s.new_wip_start_date,
            msi.sr_inventory_item_id,
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
                    2, mpe.bill_sequence_id,
                    NULL),
            DECODE( tp.organization_type,
                    2, mpe.routing_sequence_id,
                    NULL),
            'Y',
            s.transaction_id,
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id
             -- dsr: 2 new columns
            , s.schedule_priority
            , nvl(s.requested_completion_date, s.need_by_date)
      FROM  msc_trading_partners    tp,
            msc_parameters          param,
            msc_system_items        msi,
            msc_process_effectivity mpe,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     mpe.plan_id(+)= s.plan_id
    AND     mpe.process_sequence_id(+)= s.process_seq_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     nvl(s.cfm_routing_flag,0) = 3;


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
   Where    nwk.plan_id = s.plan_id
    AND     nwk.sr_instance_id = s.sr_instance_id
    AND     nwk.routing_sequence_id = s.routing_sequence_id
    AND     nwk.transition_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);


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
            max(nvl(res.CUMMULATIVE_QUANTITY,0))
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
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    GROUP BY
            s.last_update_login,
            s.transaction_id,
            res.OPERATION_SEQ_NUM,
            s.sr_instance_id);
         --   res.CUMMULATIVE_QUANTITY);

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
     -- dsr resource_seq_num,
     resource_id_new,
     start_date,
     completion_date,
     alternate_num,
     cfm_routing_flag,
     SR_INSTANCE_ID
    -- dsr: add following columns
     , firm_flag
     , setup_id
     , group_sequence_id
     , group_sequence_number
     , batch_id
     , maximum_assigned_units
     , parent_seq_num
     , resource_seq_num
     , schedule_seq_num
     , assigned_units
     , usage_rate_or_amount
     , scheduled_flag
	 )
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
           -- res.resource_seq_num,
            res.resource_id,
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            nvl(res.alternate_num,0),
            3,
            s.sr_instance_id
            -- dsr: add following columns
            , res.firm_flag
	    , res.setup_id
	    , res.group_sequence_id
	   , res.group_sequence_number
           , res.batch_number
	   , res.maximum_assigned_units
	  , res.parent_seq_num
	  , res.orig_resource_seq_num
	  , res.resource_seq_num
	  , res.assigned_units
	  , decode(res.parent_seq_num, null, (res.RESOURCE_HOURS/decode(res.basis_type,2,1,
                    nvl(res.cummulative_quantity,
                             decode(msi.rounding_control_type,1,
               ROUND(s.new_order_quantity/nvl(res.REVERSE_CUMULATIVE_YIELD,1) ,6),
                    (s.new_order_quantity/nvl(res.REVERSE_CUMULATIVE_YIELD,1))
                            ) ) ))* decode(mdr.efficiency,NULL,100,0,100,mdr.efficiency)/100 * decode(mdr.utilization,NULL,100,0,100,mdr.utilization)/100, res.RESOURCE_HOURS)
           ,  decode(nvl(res.schedule_flag,1),-23453,1,1,1,res.schedule_flag)
   From msc_supplies s,
   msc_resource_requirements res,
   msc_apps_instances ins,
   msc_parameters param,
   msc_department_resources mdr,
   msc_system_items        msi
   Where    res.plan_id = s.plan_id
    AND     res.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id = res.supply_id
    AND     res.parent_id = 2
    AND     res.resource_id <> -1
    AND     res.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     res.plan_id = mdr.plan_id
    AND     res.organization_id =mdr.organization_id
    AND     res.sr_instance_id = mdr.sr_instance_id
    AND     res.resource_id = mdr.resource_id
    AND     res.department_id=mdr.department_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);

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
    AND     icomp.plan_id= md.plan_id
    AND     nvl(icomp.wip_supply_type,0) <> 6
    AND     icomp1.inventory_item_id= md.primary_component_id
    AND     icomp1.organization_id= md.organization_id
    AND     icomp1.sr_instance_id= md.sr_instance_id
    AND     icomp1.plan_id= md.plan_id
    AND     icomp2.inventory_item_id(+)= md.source_phantom_id
    AND     icomp2.organization_id(+)= md.organization_id
    AND     icomp2.sr_instance_id(+)= md.sr_instance_id
    AND     icomp2.plan_id(+)= md.plan_id
    AND     md.plan_id = s.plan_id
    AND     md.sr_instance_id = s.sr_instance_id
    AND     md.disposition_id= s.transaction_id
    AND     md.origination_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);


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
     -- dsr resource_seq_num,
     resource_id_new,
     assigned_units,
     alternate_num,
     start_date,
     completion_date,
     cfm_routing_flag,
     SR_INSTANCE_ID
     -- dsr: add folllowing columns
     , resource_seq_num
     , schedule_seq_num
     , parent_seq_num
     )
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
            -- dsr res.resource_seq_num,
            res.resource_id,
            res.assigned_units,
            nvl(res.alternate_num,0),
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            3,
            s.sr_instance_id
             -- dsr: add folllowing columns
	    , res.orig_resource_seq_num
	    , res.resource_seq_num
	    , res.parent_seq_num
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
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);

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
           -- resource_seq_num, rawasthi
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
        -- resreq.RESOURCE_SEQ_NUM,
           dep_res_inst.RES_INSTANCE_ID,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD, -- jguo SUBST_CHANGE,
           LT_RESOURCE_INSTANCE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.firm_flag,
           res_instreq.resource_instance_hours,
           resreq.department_id,
           dep_res_inst.serial_number,
           resreq.group_sequence_id,
           resreq.group_sequence_number,
           res_instreq.batch_number, ---- sbala res_instreq.res_inst_batch_id
           resreq.orig_resource_seq_num
	  , resreq.resource_seq_num
	  , resreq.parent_seq_num
	  , 3
	  , resreq.resource_id
	  , 1
    FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_resource_instance_reqs res_instreq, -- changed from design doc
           msc_dept_res_instances dep_res_inst,
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
--    AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
 AND     resreq.sr_instance_id = res_instreq.sr_instance_id
 AND     resreq.plan_id = res_instreq.plan_id
 AND     resreq.resource_seq_num = res_instreq.resource_seq_num
 AND     resreq.operation_seq_num = res_instreq.operation_seq_num
 AND     resreq.resource_id = res_instreq.resource_id
 AND     resreq.supply_id = res_instreq.supply_id
 AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
 AND     resreq.start_date = res_instreq.start_date
 AND     resreq.parent_id   = 2
 AND     resreq.resource_id <> -1
 AND     resreq.department_id <> -1
--    AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
 AND    res_instreq.plan_id = dep_res_inst.plan_id
 AND    res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
 AND    res_instreq.department_id = dep_res_inst.department_id
 AND    res_instreq.resource_id = dep_res_inst.resource_id
/* anuj: serail number and resource_instance id joins */
 AND    res_instreq.serial_number = dep_res_inst.serial_number
 AND    res_instreq.res_instance_id = dep_res_inst.res_instance_id
 AND    s.transaction_id= lv_transaction_id(j)
 AND    s.sr_instance_id= lv_instance_id(j)
 AND    s.plan_id= arg_plan_id
 AND    lv_details_enabled(j)= 1
 AND    lv_agg_details(j) = 1
 AND    ins.instance_id = lv_instance_id(j)
 AND    nvl(ins.lbj_details,2) = 1
 AND    param.organization_id = s.organization_id
 AND    param.sr_instance_id = s.sr_instance_id
 AND    param.network_scheduling_method = 1
	;


  /*print_debug_info( 'Operation Resource Instances: rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = '
  						|| SQL%ROWCOUNT
						); */

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
           -- resource_seq_num, rawasthi
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
         -- resreq.RESOURCE_SEQ_NUM,
            dep_res_inst.RES_INSTANCE_ID,
            nvl(resreq.firm_start_date,res_instreq.START_DATE),
            nvl(resreq.firm_end_date,res_instreq.END_DATE),
            SUBST_ADD, -- jguo SUBST_CHANGE,
            LT_RESOURCE_INST_USAGE,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            resreq.firm_flag,
            res_instreq.resource_instance_hours,
            resreq.department_id,
            dep_res_inst.serial_number,
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
            msc_dept_res_instances dep_res_inst,
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
--    AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
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
--    AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
    AND     res_instreq.department_id = dep_res_inst.department_id
    AND     res_instreq.resource_id = dep_res_inst.resource_id
    AND     res_instreq.plan_id = dep_res_inst.plan_id
    AND     res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
/* anuj: serail number and resource_instance id joins */
    AND     res_instreq.serial_number = dep_res_inst.serial_number
    AND     res_instreq.res_instance_id = dep_res_inst.res_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
	;

/*  print_debug_info( 'Resource Instance Usage: rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = '
  						|| SQL%ROWCOUNT
	 				); */

	-- dsr end
    FORALL j IN 1..lv_job_count
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= lv_transaction_id(j);

    return lv_loaded_jobs;

END load_osfm_lot_jobs;



FUNCTION reschedule_osfm_lot_jobs
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER
IS

TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   lv_resched_jobs    NUMBER;
   lv_transaction_id  NumTab;
   lv_instance_id     NumTab;
   lv_details_enabled NumTab;
   lv_org_id	      NumTab;
   lv_plan_id         NumTab;
   lv_agg_details     NumTab;

BEGIN

	/* Details will not be released
		for Non - Daily Bucketed Plans
		if the implement quantity or date is different then the planned quantity date
		if the Lot-based job uses aggregate resources
		if the job has faulty network*/

	l_sql_stmt :=  ' SELECT s.transaction_id,
          s.sr_instance_id,
          decode( mp.daily_material_constraints+ mp.daily_resource_constraints+
                  mp.weekly_material_constraints+ mp.weekly_resource_constraints+
                  mp.period_material_constraints+ mp.period_resource_constraints,12,
               2,
              DECODE(nvl(s.wsm_faulty_network,2),2,Decode(mpb.bucket_type,1,DECODE( s.implement_quantity,
                  s.new_order_quantity, DECODE( s.implement_date,
                                                s.new_schedule_date, 1,
                                                2),
                  2),2),2)),
           s.organization_id,
           s.plan_id
     FROM msc_plans mp,
          msc_supplies s,
          msc_plan_organizations_v orgs,
          msc_plan_buckets mpb
    WHERE mp.plan_id = :arg_plan_id
    AND   s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = :arg_plan_id
    AND   orgs.plan_id = :arg_plan_id
    AND   orgs.organization_id = :arg_owning_org_id
    AND   orgs.owning_sr_instance = :arg_owning_instance
    AND   orgs.sr_instance_id = :arg_org_instance
    and  (s.releasable = ' || RELEASABLE || ' or s.releasable is null )';

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    IF arg_log_org_id <> arg_owning_org_id THEN
            l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;

    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = 6 ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = 6 ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

    l_sql_stmt :=  l_sql_stmt || ' and   s.plan_id = mpb.plan_id
    AND ( (DECODE(s.disposition_status_type ,
                  2,DECODE(SIGN( mp.curr_start_date-s.new_schedule_date),
                           1,mp.curr_start_date,
                           DECODE(SIGN(s.new_schedule_date-mp.curr_cutoff_date),
                                 1,mp.curr_cutoff_date,
                                 s.new_schedule_date)),
                  s.new_schedule_date ) BETWEEN mpb.bkt_start_date
                                        AND mpb.bkt_end_date)) ';

    lv_resched_jobs:= 0;

    IF arg_mode IS NULL OR arg_mode = 'WF_BATCH' OR arg_mode = 'WF' THEN
        EXECUTE IMMEDIATE l_sql_stmt
               BULK COLLECT      INTO lv_transaction_id,
                                      lv_instance_id,
                                      lv_details_enabled,
                                      lv_org_id,
                                      lv_plan_id
                                     USING  arg_plan_id
                                            ,arg_plan_id
                                            ,arg_plan_id
                                            ,arg_owning_org_id
                                            ,arg_owning_instance
                                            ,arg_org_instance ;
        lv_resched_jobs:= SQL%ROWCOUNT;
    END IF;




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
                   AND deptres.plan_id  = resreq.plan_id
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
            source_line_id --Outbound Changes for XML
	   -- dsr: added 2 new columns
	   , schedule_priority
	   , requested_completion_date
	  )
    SELECT  SYSDATE,
            arg_user_id,
            s.cfm_routing_flag,
            s.last_update_login,
            SYSDATE,
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            msi.organization_id,
            tp.organization_type,
            DECODE(NVL(s.implement_status_code, s.wip_status_code),
                   JOB_CANCELLED,JOB_CANCELLED,NULL),
            6,
            decode(lv_details_enabled(j),1,new_wip_start_date,null),
            s.implement_date,
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
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id,
            msi.sr_inventory_item_id,
            s.transaction_id --Outbound Changes for XML
            -- dsr: added 2 new columns
	   , s.schedule_priority
	   , s.requested_completion_date
    FROM    msc_trading_partners tp,
            msc_parameters param,
            msc_system_items msi,
            msc_supplies     s,
            msc_plan_organizations_v orgs
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = msi.organization_id
    AND    param.sr_instance_id = msi.sr_instance_id
    AND    msi.inventory_item_id = s.inventory_item_id
    AND    msi.plan_id = s.plan_id
    AND    msi.organization_id = s.organization_id
    AND    msi.sr_instance_id  = s.sr_instance_id
    AND    s.release_errors is NULL
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
    AND     ((arg_mode is null and s.load_type = 6 AND
              s.last_updated_by = decode(v_msc_released_only_by_user,1,v_user_id,s.last_updated_by)) or
                (arg_mode = 'WF' and s.transaction_id = arg_transaction_id))
    AND    nvl(s.cfm_routing_flag,0) = 3
    AND    s.transaction_id = lv_transaction_id(j)
    AND    s.sr_instance_id  = lv_instance_id(j)
    AND    s.plan_id = lv_plan_id(j);



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
   Where    nwk.plan_id = s.plan_id
    AND     nwk.sr_instance_id = s.sr_instance_id
    AND     nwk.transaction_id = s.transaction_id
    AND     nwk.recommended = 'Y'
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);


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
            max(nvl(res.CUMMULATIVE_QUANTITY,0))
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
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
    GROUP BY
            s.last_update_login,
            s.transaction_id,
            res.OPERATION_SEQ_NUM,
            s.sr_instance_id,
           -- res.CUMMULATIVE_QUANTITY,
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
     -- dsr resource_seq_num,
     resource_id_new,
     start_date,
     completion_date,
     alternate_num,
     cfm_routing_flag,
     SR_INSTANCE_ID
    -- dsr: add following columns
    , firm_flag
    , setup_id
    , group_sequence_id
    , group_sequence_number
    , batch_id
   , maximum_assigned_units
   , parent_seq_num
   , resource_seq_num
   , schedule_seq_num
   , assigned_units
   , usage_rate_or_amount
   , scheduled_flag
)
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
            -- res.resource_seq_num,
            res.resource_id,
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            nvl(res.alternate_num,0),
            3,
            s.sr_instance_id
            -- dsr: add following columns
            , res.firm_flag
	    , res.setup_id
	    , res.group_sequence_id
	    , res.group_sequence_number
            , res.batch_number
	    , res.maximum_assigned_units
	    , res.parent_seq_num
	    , res.orig_resource_seq_num
	    , res.resource_seq_num
	    , res.assigned_units
	    , decode(res.parent_seq_num, null, (res.RESOURCE_HOURS/decode(res.basis_type,2,1,
                    nvl(res.cummulative_quantity,
                             decode(msi.rounding_control_type,1,
               ROUND(s.new_order_quantity/nvl(res.REVERSE_CUMULATIVE_YIELD,1) ,6),
                    (s.new_order_quantity/nvl(res.REVERSE_CUMULATIVE_YIELD,1))
                            ) ) ))* decode(mdr.efficiency,NULL,100,0,100,mdr.efficiency)/100 * decode(mdr.utilization,NULL,100,0,100,mdr.utilization)/100, res.RESOURCE_HOURS)
            ,  decode(nvl(res.schedule_flag,1),-23453,1,1,1,res.schedule_flag)
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
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     res.plan_id = mdr.plan_id
    AND     res.organization_id =mdr.organization_id
    AND     res.sr_instance_id = mdr.sr_instance_id
    AND     res.resource_id = mdr.resource_id
    AND     res.department_id=mdr.department_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);

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
    AND     icomp.plan_id= md.plan_id
    AND     nvl(icomp.wip_supply_type,0) <> 6
    AND     icomp1.inventory_item_id= md.primary_component_id
    AND     icomp1.organization_id= md.organization_id
    AND     icomp1.sr_instance_id= md.sr_instance_id
    AND     icomp1.plan_id= md.plan_id
    AND     icomp2.inventory_item_id(+)= md.source_phantom_id
    AND     icomp2.organization_id(+)= md.organization_id
    AND     icomp2.sr_instance_id(+)= md.sr_instance_id
    AND     icomp2.plan_id(+)= md.plan_id
    AND     md.plan_id = s.plan_id
    AND     md.sr_instance_id = s.sr_instance_id
    AND     md.disposition_id= s.transaction_id
    AND     md.origination_type = 1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);


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
     -- dsr resource_seq_num,
     resource_id_new,
     assigned_units,
     alternate_num,
     start_date,
     completion_date,
     cfm_routing_flag,
     SR_INSTANCE_ID
     , resource_seq_num -- dsr
     , schedule_seq_num
     , parent_seq_num
    )
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
           --  res.resource_seq_num,
            res.resource_id,
            res.assigned_units,
            nvl(res.alternate_num,0),
            nvl(res.firm_start_date,res.START_DATE),
            nvl(res.firm_end_date,res.END_DATE),
            3,
            s.sr_instance_id,
             -- dsr
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
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1);

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
       --   resource_seq_num, dsr rawasthi
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
         -- resreq.OPERATION_SEQ_NUM,
         -- resreq.RESOURCE_SEQ_NUM,
            dep_res_inst.RES_INSTANCE_ID,
            nvl(resreq.firm_start_date,res_instreq.START_DATE),
            nvl(resreq.firm_end_date,res_instreq.END_DATE),
            SUBST_ADD, -- jguo SUBST_CHANGE,
            LT_RESOURCE_INSTANCE,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            resreq.firm_flag,
            res_instreq.resource_instance_hours,
            resreq.department_id,
            dep_res_inst.serial_number,
            resreq.group_sequence_id,
            resreq.group_sequence_number,
            res_instreq.batch_number,
	    ---- sbala res_instreq.res_inst_batch_id
            resreq.orig_resource_seq_num,
	    resreq.resource_seq_num,
	    resreq.parent_seq_num,
	    3,
	    resreq.resource_id,
	    1
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_resource_instance_reqs res_instreq, -- changed from design doc
            msc_dept_res_instances dep_res_inst,
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
--    AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
    AND     resreq.sr_instance_id = res_instreq.sr_instance_id
    AND     resreq.plan_id = res_instreq.plan_id
    AND     resreq.resource_seq_num = res_instreq.resource_seq_num
    AND     resreq.operation_seq_num = res_instreq.operation_seq_num
    AND     resreq.resource_id = res_instreq.resource_id
    AND     resreq.supply_id = res_instreq.supply_id
    AND     resreq.parent_id = res_instreq.parent_id  --rawasthi
    AND     resreq.start_date = res_instreq.start_date
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
--    AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
    AND     res_instreq.plan_id = dep_res_inst.plan_id
    AND     res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
    AND     res_instreq.department_id = dep_res_inst.department_id
    AND     res_instreq.resource_id = dep_res_inst.resource_id
/* anuj: serail number and resource_instance id joins */
    AND     res_instreq.serial_number = dep_res_inst.serial_number
    AND     res_instreq.res_instance_id = dep_res_inst.res_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     ins.instance_id = lv_instance_id(j)
    AND     nvl(ins.lbj_details,2) = 1
    AND     param.organization_id = s.organization_id
    AND     param.sr_instance_id = s.sr_instance_id
    AND     param.network_scheduling_method = 1
	;

/*  print_debug_info('Resource Instance: rows inserted into msc_wip_job_dtls_interface = '
  					|| sql%rowcount); */

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
        --    resource_seq_num,
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
         -- resreq.OPERATION_SEQ_NUM,
         -- resreq.RESOURCE_SEQ_NUM,
            dep_res_inst.RES_INSTANCE_ID,
            nvl(resreq.firm_start_date,res_instreq.START_DATE),
            nvl(resreq.firm_end_date,res_instreq.END_DATE),
            SUBST_ADD, -- jguo SUBST_CHANGE,
            LT_RESOURCE_INST_USAGE,
            2,
            1,
            s.sr_instance_id,
            resreq.operation_sequence_id,
            resreq.firm_flag,
            res_instreq.resource_instance_hours,
            resreq.department_id,
            dep_res_inst.serial_number,
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
            msc_dept_res_instances dep_res_inst,
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
--    AND   resreq.transaction_id = res_instreq.res_inst_transaction_id
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
--    AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
      AND   res_instreq.department_id = dep_res_inst.department_id
      AND   res_instreq.resource_id = dep_res_inst.resource_id
      AND   res_instreq.plan_id = dep_res_inst.plan_id
      AND   res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
/* anuj: serail number and resource_instance id joins */
      AND   res_instreq.serial_number = dep_res_inst.serial_number
      AND   res_instreq.res_instance_id = dep_res_inst.res_instance_id
      AND   s.transaction_id= lv_transaction_id(j)
      AND   s.sr_instance_id= lv_instance_id(j)
      AND   s.plan_id= arg_plan_id
      AND   lv_details_enabled(j)= 1
      AND   lv_agg_details(j) = 1
      AND   ins.instance_id = lv_instance_id(j)
      AND   nvl(ins.lbj_details,2) = 1
      AND   param.organization_id = s.organization_id
      AND   param.sr_instance_id = s.sr_instance_id
      AND   param.network_scheduling_method = 1
	;

/*  print_debug_info('Resource Instance Usage: rows inserted into msc_wip_job_dtls_interface = '
  					|| sql%rowcount); */


    FORALL j IN 1..lv_resched_jobs
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= lv_transaction_id(j);

	-- dsr end
    RETURN lv_resched_jobs;

END reschedule_osfm_lot_jobs;


FUNCTION load_wip_discrete_jobs
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER,
  l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER
IS
   lv_loaded_jobs NUMBER;

   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 --TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;

   lv_transaction_id          NumTab;
   lv_instance_id             NumTab;
   lv_details_enabled         NumTab;
   lv_Agg_details             NumTab;
   Lv_org_id                  Numtab;
   lv_plan_id                 NumTab;
   lv_job_count               NUMBER;
   lv_release_details         NUMBER;
   lv_inflate_wip             NUMBER;
   lv_round_primary_item      NumTab;

-- BUG 9085180

   lv_wip_start_qty_in         NumTab;
   lv_wip_start_qty_out        NumTab;
   lv_new_order_qty            NumTab;
   lv_implement_qty            NumTab;
   lv_qty_scrapped             NumTab;
   lv_qty_completed            NumTab;
   lv_net_qty                  NumTab;

   orig_net_qty                NUMBER;


CURSOR c_release_dtls(p_transaction_id number,
                      p_plan_id  number) IS
SELECT COUNT(1) FROM (
SELECT count(1)
FROM msc_supplies
WHERE implement_alternate_bom is not null
  and transaction_id = p_transaction_id
  AND plan_id = p_plan_id
  and rownum < 2
UNION
SELECT count(1)
from msc_exception_details excp
where excp.plan_id = p_plan_id
      and number1 = p_transaction_id
      and excp.exception_type = 33
      and rownum < 2);


CURSOR c_plan_type(p_plan_id number) IS
select plan_type
from msc_plans a
where
plan_id = p_plan_id;

l_sub_comp_count NUMBER;
l_count   NUMBER := 0;
l_plan_type  number := 0;

BEGIN

   SELECT decode(nvl(FND_PROFILE.value('MSC_RELEASE_DTLS_REVDATE'),'Y'),'N',2,1),
   DECODE(NVL(fnd_profile.value('MSC_INFLATE_WIP') ,'N'), 'N',2 ,1)
   INTO lv_release_details,lv_inflate_wip
   FROM dual;

  /* we release the discrete job, only if it doesn't use aggregate resources */
  /* bug 1252659 fix, replace rowid by
         (transaction_id,sr_instance_id,plan_id) */

  /* Details will NOT be released for
     a. Unconstrained Plan
     b. if the new_wip_start_date is null
     c. if the implement quantity or date is different then the planned quantity date
     d. if the revision date is different then the new_wip_start_date
        and the profile option setting : MSC_RELEASE_DTLS_REVDATE  = 'N'
     e. Non - Daily Bucketed Plans
     f.bug 4655420-Alternate BOM/Routing is changed during release.
  */
  /* Ignore the profile option
      MSC: Release WIP Dtls if Order Date different then BOM Revision Date.
     in case of RP plan
  */
   if (v_rp_plan = 1 ) then
     lv_release_details := 1;
   end if;

    -- dsting get plan type
    OPEN c_plan_type(arg_plan_id);
    FETCH c_plan_type INTO l_plan_type;
    CLOSE c_plan_type;

   l_sql_stmt := ' SELECT s.transaction_id,
          s.sr_instance_id,
           Decode(' ||l_plan_type ||', 5, -- dsting for drp look at alternate bom/subst exception to determine whether or not to release dtls
                  Decode(implement_alternate_bom, NULL,
                         (SELECT Decode(COUNT(1), 1, 1, 2)
                            FROM msc_exception_details e
                           WHERE e.plan_id = :arg_plan_id
                             AND e.number1 = s.transaction_id
                             AND e.exception_type = 33), 1),
                  decode( mp.daily_material_constraints+ mp.daily_resource_constraints+
                  mp.weekly_material_constraints+ mp.weekly_resource_constraints+
                  mp.period_material_constraints+ mp.period_resource_constraints,12,2,
               decode(mpb.bucket_type,1,
                 Decode(greatest(abs(s.implement_quantity -
                                           s.new_order_quantity),
                                       0.000001),
                              0.000001,
                     DECODE( s.implement_date, s.new_schedule_date,
                     	DECODE(NVL(s.implement_alternate_bom, ''-23453''),
                     			 NVL(s.alternate_bom_designator, ''-23453''),
               					 DECODE(NVL(s.implement_alternate_routing, ''-23453''),
                      			 NVL(s.alternate_routing_designator, ''-23453''),
                        DECODE(trunc(msc_calendar.date_offset
                              (s.organization_id,
                               s.sr_instance_id,
                               1, --daily bucket
                               s.need_by_date ,
                               ceil(nvl(msi.fixed_lead_time,0) +
                 nvl(msi.variable_lead_time,0) * s.implement_quantity)*-1 )),
                     trunc(s.new_wip_start_date),1,
                                   decode(' || lv_release_details || ',2,2,1)),
                           2),
                         2),
                       2),
                     2),
                 2))),
         s.organization_id,
         s.plan_id,
         decode( ' || l_apps_ver ||' ,4,msi.rounding_control_type,3,msi.rounding_control_type,2),
         NVL(s.wip_start_quantity, 0),
         NVL(s.new_order_quantity, 0),
         NVL(s.implement_quantity, 0)
--         NVL(s.qty_scrapped, 0),
--         NVL(s.qty_completed, 0)
     FROM msc_supplies s,
          msc_plan_organizations_v orgs,
          msc_plan_buckets mpb,
          msc_system_items msi,
          msc_plans mp
    WHERE mp.plan_id = :arg_plan_id
    AND   s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = orgs.plan_id
    AND   msi.inventory_item_id = s.inventory_item_id
    AND   msi.plan_id = s.plan_id
    AND   msi.organization_id = s.organization_id
    AND   msi.sr_instance_id = s.sr_instance_id
    AND   orgs.plan_id = mp.plan_id
    AND   orgs.organization_id = :arg_owning_org_id
    AND   orgs.owning_sr_instance = :arg_owning_instance
    AND   orgs.sr_instance_id = :arg_org_instance
    and   s.plan_id = mpb.plan_id
    and  (nvl(s.implement_date,s.new_schedule_date) between mpb.bkt_start_date and mpb.bkt_end_date)
    and   s.new_wip_start_date IS NOT NULL
    and (s.releasable = ' || RELEASABLE || ' or s.releasable is null )';

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    IF arg_log_org_id <> arg_owning_org_id THEN
            l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;

    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = ' || WIP_DIS_MASS_LOAD || ' ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = ' || WIP_DIS_MASS_LOAD || ' ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

l_sql_stmt :=  l_sql_stmt ||'
UNION
  SELECT s.transaction_id,
          s.sr_instance_id,
          2 /* Details not enabled for Manual Planned orders */,
          s.organization_id,
          s.plan_id,
          2,  /* setting rounding control to 2 ,since details are not released and this flag is used in details*/
         NVL(s.wip_start_quantity, 0),
         NVL(s.new_order_quantity, 0),
         NVL(s.implement_quantity, 0)
--         NVL(s.qty_scrapped, 0),
--         NVL(s.qty_completed, 0)
     FROM msc_supplies s,
          msc_plan_organizations_v orgs
    WHERE s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = :arg_plan_id
    AND   orgs.plan_id = :arg_plan_id
    AND   orgs.organization_id = :arg_owning_org_id
    AND   orgs.owning_sr_instance = :arg_owning_instance
    AND   orgs.sr_instance_id = :arg_org_instance
    and   s.new_wip_start_date IS NULL
    and (s.releasable = ' || RELEASABLE || ' or s.releasable is null ) ';

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    IF arg_log_org_id <> arg_owning_org_id THEN
            l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;


    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = ' || WIP_DIS_MASS_LOAD || ' ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = ' || WIP_DIS_MASS_LOAD || ' ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

    lv_job_count:= 0;
    IF arg_mode IS NULL OR arg_mode = 'WF_BATCH' OR arg_mode = 'WF' THEN
        EXECUTE IMMEDIATE l_sql_stmt
        BULK COLLECT
                                             INTO lv_transaction_id,
                                                  lv_instance_id,
                                                  lv_details_enabled,
                                                  lv_org_id,
                                                  lv_plan_id,
                                                  lv_round_primary_item,
                                                  lv_wip_start_qty_in,
                                                  lv_new_order_qty,
                                                  lv_implement_qty
--                                                  lv_qty_scrapped,
--                                                  lv_qty_completed
                                    USING  arg_plan_id
                                            ,arg_plan_id
                                            ,arg_owning_org_id
                                            ,arg_owning_instance
                                            ,arg_org_instance
                                            ,arg_plan_id
                                            ,arg_plan_id
                                            ,arg_owning_org_id
                                            ,arg_owning_instance
                                            ,arg_org_instance  ;
        lv_job_count:= SQL%ROWCOUNT;
    END IF;

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
                   AND deptres.plan_id  = resreq.plan_id
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
                  -- BUG 9085180
                  -- Compute the lv_wip_start_qty_out and lv_net_qty.

                  IF ((lv_details_enabled(k) = 1) OR
                      (abs(lv_implement_qty(k) - lv_new_order_qty(k))
                                                      <= 0.000001)) THEN

                     -- There is no change in date/quantity at the time of release
                     -- and we are populating the details, so we will pass the
                     -- WIP start and net quantity.
                     -- In this case, lv_new_order_qty = lv_implement_qty

                     lv_wip_start_qty_out(k) := NVL(lv_wip_start_qty_in(k),
                                                    lv_new_order_qty (k));
                     lv_net_qty(k) := lv_new_order_qty (k) ;

                  ELSE

                     -- The user changes the implement quantity at the time of release.
                     -- We might need a factor (reverse cum yield) here to
                     -- inflate the start quantity.

                     lv_net_qty(k) := lv_implement_qty (k) ;

                     orig_net_qty := lv_new_order_qty (k) ;
                     IF (orig_net_qty <= 0.000001) THEN
                         orig_net_qty := 1;
                     END IF;

                     lv_wip_start_qty_out(k) := lv_net_qty(k) *
                                      (lv_wip_start_qty_in(k) / orig_net_qty);

                  END IF;


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
            SR_INSTANCE_ID
            -- dsr
            , schedule_priority
            , requested_completion_date
            )
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            decode(tp.organization_type,2,s.creation_date,SYSDATE),
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            s.transaction_id,
            msi.organization_id,
            tp.organization_type,
            1,
            decode(tp.organization_type,2,1,s.implement_status_code),
            DECODE( lv_details_enabled(j),
                    2,DECODE( tp.organization_type,
                              2, s.new_wip_start_date,
                              NULL),
                    s.new_wip_start_date),
            s.implement_date,
 /* Added to code to release the greatest of sysdate OR the BOM/Routing revision date */
            decode( lv_details_enabled(j),1, -- If details and daily buckets
                    GREATEST(trunc(sysdate),
                             decode(v_rp_plan,
                                    1,trunc(s.new_wip_start_date),
                                    trunc(msc_calendar.date_offset(
                                          s.organization_id,
                                          s.sr_instance_id,
                                          1, --daily bucket
                                          s.need_by_date ,
                                          ceil(nvl(msi.fixed_lead_time,0) +
                                          nvl(msi.variable_lead_time,0) * s.implement_quantity)*-1 ) ) )
                            )+(1439/1440)
                    ,NULL),
            decode( lv_details_enabled(j),1, -- If details and daily buckets
                    GREATEST(trunc(sysdate),trunc( msc_calendar.date_offset
                         (s.organization_id,
                          s.sr_instance_id,
                          1, --daily bucket
                          s.need_by_date ,
                         ceil(nvl(msi.fixed_lead_time,0) +
                          nvl(msi.variable_lead_time,0) * s.implement_quantity)*-1 ) )
                            )+(1439/1440)
                    ,NULL),
            msi.sr_inventory_item_id,
            s.implement_wip_class_code,
            s.implement_job_name,
            s.implement_firm,
/*
            decode(msi.rounding_control_type,1,
               ROUND(s.implement_quantity/GET_REV_CUM_YIELD_DISC(s.sr_instance_id, s.plan_id
                   ,s.process_seq_id,s.transaction_id,s.organization_id,tp.organization_type)),
               (s.implement_quantity/GET_REV_CUM_YIELD_DISC(s.sr_instance_id, s.plan_id
                   ,s.process_seq_id,s.transaction_id,s.organization_id,tp.organization_type))
                   ),*/
/* Bug 4540170 - PLANNED ORDERS RELEASED FROM ASCP DO NOT CREATE BATCH WITH CORRECT QTYS */
/*        Decode(greatest(abs(s.implement_quantity -
                                           s.new_order_quantity),
                        0.000001),
               0.000001, nvl(s.wip_start_quantity,s.implement_quantity),
                                              s.implement_quantity), */
        decode(tp.organization_type,
               1,lv_wip_start_qty_out(j),
               lv_net_qty(j)),
        lv_net_qty(j),
--	    s.implement_quantity,
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
                    2, mpe.bill_sequence_id,
                    NULL),
            DECODE( tp.organization_type,
                    2, mpe.routing_sequence_id,
                    NULL),
            'Y',
            s.transaction_id,
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id
            -- dsr
            , s.schedule_priority
            , nvl(s.requested_completion_date, s.need_by_date)
      FROM  msc_trading_partners    tp,
            msc_parameters          param,
            msc_system_items        msi,
            msc_process_effectivity mpe,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     mpe.plan_id(+)= s.plan_id
    AND     mpe.process_sequence_id(+)= s.process_seq_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id;

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

    /* If the current plan is DRP plan then check the following conditions
       to determin whether we need to release the details or not
       1) For planned orders that do not use
          substitute components/alternateboms, only the
          header level information is released */

    l_count := 1;

/*
    IF l_plan_type = 5 THEN   -- DRP plan
       --OPEN  c_release_dtls(arg_transaction_id, arg_plan_id);
       --FETCH c_release_dtls INTO l_count;
       --CLOSE c_release_dtls;

       -- dsting redo the details enabled flag for things with subst comp
       for i IN 1..lv_transaction_id.count loop
          SELECT count(1)
            INTO l_sub_comp_count
            from msc_exception_details excp
            where excp.plan_id = arg_plan_id
            and number1 = lv_transaction_id(i)
            and excp.exception_type = 33
            and rownum < 2;

          IF l_sub_comp_count > 0 THEN
             lv_details_enabled(i) := 1;
          END IF;
       END LOOP;
    END IF;
*/
    /* If it is not a drp plan then l_count = 1 so details will be released */
    IF l_count = 1 THEN  /* Release details as well */
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
            msc_system_items        msi,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
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
           -- resource_seq_num, rawasthi
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
            department_id
	-- added the following for dsr
	   , setup_id
	   , group_sequence_id
	   , group_sequence_number
           , batch_id
	   , maximum_assigned_units
	   , parent_seq_num
	   , resource_seq_num
           , schedule_seq_num
	 )
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
           -- resreq.RESOURCE_SEQ_NUM,
            resreq.ALTERNATE_NUM,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
             /* for OPM orgs (tp.organization_type =2) we don't consider lv_inflate_wip */
            /* decode(resreq.parent_seq_num, null, decode(decode(tp.organization_type,2,2,1),1,(resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,
                    nvl(resreq.cummulative_quantity,
                             decode(msi.rounding_control_type,1,
               ROUND(s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) ,6),
                    (s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) )
                            ) ) ))* decode(mdr.efficiency,NULL,100,0,100,mdr.efficiency)/100 * decode(mdr.utilization,NULL,100,0,100,mdr.utilization)/100,
                                    resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,
                    nvl(resreq.cummulative_quantity,
                             decode(msi.rounding_control_type,1,
               ROUND(s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) ,6),
                    (s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) )
                            ) ) )), resreq.usage_rate),  */
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
            decode(resreq.parent_seq_num,null,SUBST_CHANGE,SUBST_ADD),
            -- SUBST_CHANGE,
            LT_RESOURCE,
            2,
            1,
            NULL,
            s.sr_instance_id,
            resreq.operation_sequence_id, --Outbound changes for XML
            -- dsr decode(nvl(resreq.firm_flag,0),0,2,1),
            NVL(resreq.firm_flag, 0), -- if null, then default to not firm (0)
            resreq.resource_hours,
            resreq.department_id
            -- added the following for dsr
	    , resreq.setup_id
	    , resreq.group_sequence_id
	    , resreq.group_sequence_number
     	    , resreq.batch_number
	    , resreq.maximum_assigned_units
	    , resreq.parent_seq_num
	    , resreq.orig_resource_seq_num
            , resreq.resource_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s,
            msc_department_resources mdr
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     resreq.plan_id = mdr.plan_id
    AND     resreq.organization_id =mdr.organization_id
    AND     resreq.sr_instance_id = mdr.sr_instance_id
    AND     resreq.resource_id = mdr.resource_id
    AND     resreq.department_id=mdr.department_id;


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
            decode(md.component_scaling_type,1,NULL,md.component_scaling_type),
/*
            decode(lv_round_primary_item(j),1,
               ROUND(md.USING_REQUIREMENT_QUANTITY/ROUND(s.implement_quantity/GET_REV_CUM_YIELD_DISC_COMP(s.sr_instance_id
                        ,s.plan_id,s.process_seq_id,s.transaction_id,s.organization_id,tp.organization_type,md.op_seq_num),6),6),
               ROUND(md.USING_REQUIREMENT_QUANTITY/(s.implement_quantity/GET_REV_CUM_YIELD_DISC_COMP(s.sr_instance_id
                        ,s.plan_id,s.process_seq_id,s.transaction_id,s.organization_id,tp.organization_type,md.op_seq_num)),6)
                  ),*/
--            round(md.USING_REQUIREMENT_QUANTITY/s.wip_start_quantity,6),
            TO_NUMBER(NULL),       --Quantity_per
            md.component_yield_factor,
            TO_NUMBER(NULL),       --Department_ID
/*
            NVL(GET_WIP_SUPPLY_TYPE(s.plan_id, s.sr_instance_id,s.process_seq_id,
                                    s.inventory_item_id,md.inventory_item_id,s.organization_id),
                    icomp.wip_supply_type),*/
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
--            md.operation_seq_id,
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_system_items        icomp,
            msc_demands             md,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   /*
            ( md.SUBST_ITEM_FLAG <> 1
              OR md.SUBST_ITEM_FLAG IS NULL) */
            not exists (select 'x'
                        from msc_exception_details excp
                        where excp.plan_id = msi.plan_id
                        and excp.number1 = s.transaction_id
                        and excp.inventory_item_id = msi.inventory_item_id
                        and excp.organization_id = msi.organization_id
                        and excp.sr_instance_id = msi.sr_instance_id
                        and excp.exception_type = 33
                        and excp.number2 = md.inventory_item_id)
    AND     tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     icomp.inventory_item_id= md.inventory_item_id
    AND     icomp.organization_id= md.organization_id
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     icomp.plan_id= md.plan_id
    AND     nvl(icomp.wip_supply_type,0) <> 6
    AND     md.sr_instance_Id= s.sr_instance_Id
    AND     md.disposition_id= s.transaction_id
    AND     md.plan_id= s.plan_id
    AND     md.origination_type IN (1,47)
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1;

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
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_system_items        icomp,
            msc_supplies            co,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE  /* not exists (select 'x'
                        from msc_exception_details excp
                        where excp.plan_id = msi.plan_id
                        and excp.number1 = s.transaction_id
                        and excp.inventory_item_id = msi.inventory_item_id
                        and excp.organization_id = msi.organization_id
                        and excp.sr_instance_id = msi.sr_instance_id
                        and excp.exception_type = 33
                        and excp.number2 = co.inventory_item_id)
    AND */
            tp.sr_tp_id             = msi.organization_id
    AND     tp.sr_instance_id       = msi.sr_instance_id
    AND     tp.partner_type         = 3
    AND     icomp.inventory_item_id = co.inventory_item_id
    AND     icomp.organization_id   = co.organization_id
    AND     icomp.sr_instance_id    = co.sr_instance_id
    AND     icomp.plan_id           = co.plan_id
    AND     co.sr_instance_Id       = s.sr_instance_Id
    AND     co.disposition_id       = s.transaction_id
    AND     co.plan_id              = s.plan_id
    AND     co.order_type           = 17        --Co-product /by-product
    AND     param.organization_id   = msi.organization_id
    AND     param.sr_instance_id    = msi.sr_instance_id
    AND     msi.inventory_item_id   = s.inventory_item_id
    AND     msi.plan_id             = s.plan_id
    AND     msi.organization_id     = s.organization_id
    AND     msi.sr_instance_id      = s.sr_instance_id
    AND     s.transaction_id        = lv_transaction_id(j)
    AND     s.sr_instance_id        = lv_instance_id(j)
    AND     s.plan_id               = arg_plan_id
    AND     lv_details_enabled(j)   = 1
    AND     lv_agg_details(j)       = 1
    AND     tp.organization_type    = 2;

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
            arg_wip_group_id,
            s.transaction_id,
            nvl(md.op_seq_num,1),
            sr_item.sr_inventory_item_id,
            icomp.sr_inventory_item_id,
/*
            decode(lv_round_primary_item(j),1,
                     ROUND(md.USING_REQUIREMENT_QUANTITY/ROUND(s.implement_quantity/GET_REV_CUM_YIELD_DISC_COMP(s.sr_instance_id
                         ,s.plan_id,s.process_seq_id,s.transaction_id,s.organization_id,tp.organization_type,md.op_seq_num),6),6),
                     ROUND(md.USING_REQUIREMENT_QUANTITY/(s.implement_quantity/GET_REV_CUM_YIELD_DISC_COMP(s.sr_instance_id
                         ,s.plan_id,s.process_seq_id,s.transaction_id,s.organization_id,tp.organization_type,md.op_seq_num)),6)
                  ),*/
            bsub.usage_quantity,
            TO_NUMBER(NULL),       --Department_ID
/*
            NVL(GET_WIP_SUPPLY_TYPE(s.plan_id, s.sr_instance_id,s.process_seq_id,
                                    s.inventory_item_id,md.inventory_item_id,s.organization_id),
                    icomp.wip_supply_type),*/
            nvl(md.wip_supply_type,icomp.wip_supply_type),
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
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id
      FROM  msc_trading_partners    tp,
            msc_item_id_lid         sr_item,
            msc_bom_components      subcomp,
            msc_component_substitutes bsub,
/*            msc_bom_components      bcomp, */
            msc_boms                bom,
            msc_system_items        icomp,
            msc_demands             md,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     sr_item.inventory_item_id= subcomp.inventory_item_id
    AND     sr_item.sr_instance_id= subcomp.sr_instance_id
    AND    subcomp.plan_id               = bsub.plan_id
    AND     subcomp.bill_sequence_id      = bsub.bill_sequence_id
    AND     subcomp.COMPONENT_SEQUENCE_ID = bsub.COMPONENT_SEQUENCE_ID
    AND     bsub.substitute_item_id = md.inventory_item_id
    AND     bsub.organization_id    = md.organization_id
    AND     bsub.plan_id            = md.plan_id
    AND     bsub.COMPONENT_SEQUENCE_ID= md.comp_seq_id
   /* Bug 3636332  AND     bsub.bill_sequence_id   = bom.bill_sequence_id */
  --------------------------------------------------------------
/*    AND     md.SUBST_ITEM_FLAG=1 */
  --------------------------------------------------------------
    AND     ( bom.ALTERNATE_BOM_DESIGNATOR= s.ALTERNATE_BOM_DESIGNATOR
              OR ( bom.ALTERNATE_BOM_DESIGNATOR IS NULL
                   AND s.ALTERNATE_BOM_DESIGNATOR IS NULL))
    AND     bom.assembly_item_id=  s.inventory_item_id
    AND     bom.organization_id=   s.organization_id
    AND     bom.sr_instance_id=    s.sr_instance_id
    AND     bom.plan_id=           s.plan_id
    AND     icomp.inventory_item_id= md.inventory_item_id
    AND     icomp.organization_id= md.organization_id
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     icomp.plan_id= md.plan_id
    AND     md.sr_instance_Id= s.sr_instance_Id
    AND     md.disposition_id= s.transaction_id
    AND     md.plan_id= s.plan_id
    AND     md.origination_type in (1,47)
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1;

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
            -- resource_seq_num,
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
            -- dsr FIRM_FLAG,
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
           -- resreq.RESOURCE_SEQ_NUM,
            resreq.ALTERNATE_NUM,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
           /* for OPM orgs (tp.organization_type =2) we don't consider lv_inflate_wip */
           /* decode(resreq.parent_seq_num, null, decode(decode(tp.organization_type,2,2,lv_inflate_wip),1,(resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,
                    nvl(decode(resreq.cummulative_quantity,0,1,resreq.cummulative_quantity),
                             decode(msi.rounding_control_type,1,
               ROUND(s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) ,6),
                    (s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) )
                            ) ) ))* decode(mdr.efficiency,NULL,100,0,100,mdr.efficiency)/100 * decode(mdr.utilization,NULL,100,0,100,mdr.utilization)/100,
                                    resreq.RESOURCE_HOURS/decode(resreq.basis_type,2,1,
                    nvl(decode(resreq.cummulative_quantity,0,1,resreq.cummulative_quantity),
                             decode(msi.rounding_control_type,1,
               ROUND(s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) ,6),
                    (s.new_order_quantity/decode(tp.organization_type,2,1,nvl(resreq.REVERSE_CUMULATIVE_YIELD,1)) )
                            ) ) )), resreq.usage_rate),  */
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
            -- dsr decode(nvl(resreq.firm_flag,0),0,2,1),
            resreq.department_id,
            resreq.resource_hours,
            resreq.parent_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s,
            msc_department_resources mdr
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 1
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    AND     resreq.plan_id = mdr.plan_id
    AND     resreq.organization_id =mdr.organization_id
    AND     resreq.sr_instance_id = mdr.sr_instance_id
    AND     resreq.resource_id = mdr.resource_id
    AND     resreq.department_id=mdr.department_id ;
   -- AND     tp.organization_type = 2;

   -- dsr starts here
--    print_debug_info('OPERATION RESOURCE_INSTANCES');
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
            -- resource_seq_num,
            resource_id_old, --rawasthi
            resource_id_new, -- xx resource_id, ???
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            -- FIRM_FLAG,
            resource_hours,
            department_id,
	    -- setup_id,
	    SERIAL_NUMBER,
            group_sequence_id,
            group_sequence_number,
            batch_id,
            resource_seq_num,
            schedule_seq_num
            , assigned_units -- jguo
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
           arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
          -- resreq.RESOURCE_SEQ_NUM,
           resreq.resource_id,
           resreq.resource_id,
           dep_res_inst.RES_INSTANCE_ID,  -- jguo dep_res_inst.dept_RESOURCE_INST_ID,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD, -- jguo SUBST_CHANGE,
           LT_RESOURCE_INSTANCE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
        -- res_instreq.firm_flag,
           resreq.resource_hours,
           resreq.department_id,
          -- resreq.department_id / 2, rawasthi
        -- res_instreq.setup_id,
           dep_res_inst.serial_number,
           resreq.group_sequence_id,
           resreq.group_sequence_number,
           res_instreq.batch_number,
 ---- sbala res_instreq.res_inst_batch_id
           resreq.orig_resource_seq_num,
           resreq.resource_seq_num
        -- resreq.alternate_num,
         , 1 -- jguo
         , resreq.parent_seq_num
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
-- dsr AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
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
-- dsr   AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
 AND      res_instreq.plan_id = dep_res_inst.plan_id
 AND      res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
 AND      res_instreq.department_id = dep_res_inst.department_id
 AND      res_instreq.resource_id = dep_res_inst.resource_id
/*anuj_review: join condition for serial number and res_instance_id */
 AND      res_instreq.serial_number = dep_res_inst.serial_number
 AND      res_instreq.res_instance_id = dep_res_inst.res_instance_id
 AND      s.transaction_id= lv_transaction_id(j)
 AND      s.sr_instance_id= lv_instance_id(j)
 AND      s.plan_id= arg_plan_id
 AND      lv_details_enabled(j)= 1
 AND      lv_agg_details(j) = 1
    ;

--   print_debug_info('load_wip_discrete_jobs# rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = ' || SQL%ROWCOUNT);
    -- RESOURCE INSTANCE USAGES
  -- print_debug_info('RESOURCE INSTANCE USAGES ');

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
            -- resource_seq_num,
            resource_id_old,
	    resource_id_new, -- xx RESOURCE_ID, ???
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
         -- alternate_num
           , assigned_units -- jguo
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
           arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
          -- resreq.RESOURCE_SEQ_NUM,
           resreq.RESOURCE_ID,
           resreq.RESOURCE_ID,
           dep_res_inst.RES_INSTANCE_ID,  -- jguo dep_res_inst.dept_RESOURCE_INST_ID,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD, -- jguo SUBST_CHANGE,
           LT_RESOURCE_INST_USAGE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.firm_flag,
           res_instreq.resource_instance_hours,
           resreq.department_id,
         --  resreq.department_id / 2, rawasthi
           dep_res_inst.serial_number,
           resreq.orig_resource_seq_num,
           resreq.resource_seq_num
        -- resreq.alternate_num
          ,1 -- jguo
          , resreq.parent_seq_num
  FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_resource_instance_reqs res_instreq, -- ??? msc_res_inst_requirements res_instreq,
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
-- dsr   AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
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
-- dsr   AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
    AND     res_instreq.department_id = dep_res_inst.department_id
    AND     res_instreq.resource_id = dep_res_inst.resource_id
    AND     res_instreq.plan_id = dep_res_inst.plan_id
    AND     res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
/* anuj: serail number and resource_instance id joins */
    AND     res_instreq.serial_number = dep_res_inst.serial_number
    AND     res_instreq.res_instance_id = dep_res_inst.res_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    ;

--   print_debug_info('load_wip_discrete_jobs# rows inserted into MSC_WIP_JOB_DTLS_INTERFACE = ' || SQL%ROWCOUNT);

-- Resource Charges
--   print_debug_info('Resource Charges ');

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
            resource_seq_num,
	    alternate_num,
            start_date,
            completion_date,
	    required_quantity,
	    charge_number,
            SR_INSTANCE_ID,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            resource_id_old,
            resource_id_new,
            schedule_seq_num
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
            resreq.ORIG_RESOURCE_SEQ_NUM,
            resreq.alternate_num,
            Chg.charge_start_datetime,
            Chg.charge_end_datetime,
            chg.charge_quantity, -- Chg.Planned_Charge_Quantity,
            Chg.charge_number,
            s.sr_instance_id,
            SUBST_ADD, -- jguo SUBST_CHANGE, -- 3
            LT_CHARGE_TYPE, --8
            2,
            1,
            resreq.RESOURCE_ID,
            resreq.RESOURCE_ID,
            resreq.resource_seq_num
     FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_supplies            s,
           msc_resource_charges chg
    WHERE
            tp.sr_tp_id=s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.transaction_id = chg.res_transaction_id -- chg.transaction_id
    AND     resreq.plan_id = chg.plan_id
    AND     resreq.sr_instance_id = chg.sr_instance_id
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
	;
    END IF;  /* End of l_count = 1 */
    -- dsr ends here

    FORALL j IN 1..lv_job_count
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= lv_transaction_id(j);

    RETURN lv_loaded_jobs;

END load_wip_discrete_jobs;

FUNCTION reschedule_wip_discrete_jobs
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
, arg_load_type                 IN      NUMBER DEFAULT NULL -- dsr
)RETURN NUMBER
IS

   lv_resched_jobs NUMBER;


   TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 --TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;

   lv_transaction_id           NumTab;
   lv_instance_id              NumTab;
   lv_details_enabled          NumTab;
   lv_job_count                NUMBER;
   lv_plan_id                  NumTab;
   lv_org_id                   Numtab;
   lv_agg_details              NumTab;

-- BUG 9085180

   lv_wip_start_qty_in         NumTab;
   lv_wip_start_qty_out        NumTab;
   lv_new_order_qty            NumTab;
   lv_implement_qty            NumTab;
   lv_qty_scrapped             NumTab;
   lv_qty_completed            NumTab;
   lv_net_qty                  NumTab;

   orig_net_qty                NUMBER;

CURSOR c_release_dtls(p_transaction_id number,
                      p_plan_id  number) IS
SELECT count(1)
FROM msc_supplies
WHERE implement_alternate_bom is not null
      and transaction_id = p_transaction_id
      and rownum < 2
UNION
SELECT count(1)
from msc_exception_details excp
where excp.plan_id = p_plan_id
      and number1 = p_transaction_id
      and excp.exception_type = 33
      and rownum < 2;


CURSOR c_plan_type(p_plan_id number) IS
select plan_type
from msc_plans a
where
plan_id = p_plan_id;

l_count   NUMBER := 0;
l_plan_type  number := 0;


BEGIN

  -- we release the discrete job, only if it doesn't use aggregate resources
  -- bug 1252659 fix, replace rowid by
  --       (transaction_id,sr_instance_id,plan_id)

   l_sql_stmt := ' SELECT s.transaction_id,
          s.sr_instance_id,
          decode((mp.daily_material_constraints
                  + mp.daily_resource_constraints
                  + mp.weekly_material_constraints
                  + mp.weekly_resource_constraints
                  + mp.period_material_constraints
                  + mp.period_resource_constraints),
                  12, 2,
               DECODE(mpb.bucket_type,1,
                         Decode(greatest(abs(s.implement_quantity -
                                           s.new_order_quantity),
                                       0.000001),
                                 0.000001,
                                 DECODE( s.implement_date,
                                         s.new_schedule_date, 1,
                                         2),
                                2),
                      2)),
           s.organization_id,
           s.plan_id,
           NVL(s.wip_start_quantity, 0),
           NVL(s.new_order_quantity, 0),
           NVL(s.implement_quantity, 0),
           NVL(s.qty_scrapped, 0),
           NVL(s.qty_completed, 0)
    FROM msc_supplies s,
          msc_plans mp,
          msc_plan_organizations_v orgs,
          msc_plan_buckets mpb
    WHERE s.release_errors is NULL
    AND   s.implement_quantity > 0
    AND   s.organization_id = orgs.planned_organization
    AND   s.sr_instance_id = orgs.sr_instance_id
    AND   s.plan_id = :arg_plan_id
    AND   orgs.plan_id = :arg_plan_id
    AND   orgs.organization_id = :arg_owning_org_id
    AND   orgs.owning_sr_instance = :arg_owning_instance
    AND   orgs.sr_instance_id = :arg_org_instance
    and   s.plan_id = mpb.plan_id
    and   s.plan_id = mp.plan_id
    AND ( (DECODE(s.disposition_status_type ,
                  2,DECODE(SIGN( mp.curr_start_date-s.new_schedule_date),
                           1,mp.curr_start_date,
                           DECODE(SIGN(s.new_schedule_date-mp.curr_cutoff_date),
                                 1,mp.curr_cutoff_date,
                                 s.new_schedule_date)),
                  s.new_schedule_date ) BETWEEN mpb.bkt_start_date
                                        AND mpb.bkt_end_date))
    and (s.releasable = ' || RELEASABLE || ' or s.releasable is null )';

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    IF arg_log_org_id <> arg_owning_org_id THEN
            l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;

    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.load_type = ' || arg_load_type || ' ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.load_type = ' || arg_load_type || ' ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

    lv_job_count:= 0;
    IF arg_mode IS NULL OR arg_mode = 'WF_BATCH' OR arg_mode = 'WF' THEN
        EXECUTE IMMEDIATE l_sql_stmt
             BULK COLLECT            INTO lv_transaction_id,
                                          lv_instance_id,
                                          lv_details_enabled,
                                          lv_org_id,
                                          lv_plan_id,
                                          lv_wip_start_qty_in,
                                          lv_new_order_qty,
                                          lv_implement_qty,
                                          lv_qty_scrapped,
                                          lv_qty_completed
                                        USING  arg_plan_id
                                            ,arg_plan_id
                                            ,arg_owning_org_id
                                            ,arg_owning_instance
                                            ,arg_org_instance    ;
        lv_job_count:= SQL%ROWCOUNT;
    END IF;


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
                   AND deptres.plan_id  = resreq.plan_id
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

        -- BUG 9085180
        -- Compute the lv_wip_start_qty_out and lv_net_qty.

        IF (lv_details_enabled(k) = 1) THEN

           -- There is no change in date/quantity at the time of release
           -- and we are populating the details, so we will pass the
           -- WIP start and net quantity.
           -- In this case, lv_new_order_qty = lv_implement_qty

           lv_wip_start_qty_out(k) := lv_wip_start_qty_in(k);
           lv_net_qty(k) := lv_new_order_qty (k) +
                            lv_qty_scrapped(k) + lv_qty_completed (k);

        ELSIF (abs(lv_implement_qty(k) - lv_new_order_qty(k)) <= 0.000001) THEN

           -- There is no change in quantity at the time of release
           -- This is a proper date change, since we are not passing the
           -- details, we will not populate the start and net quantity
           -- in the WIP interface table.
           -- For unconstrained plan, should we pass qty?

           lv_wip_start_qty_out(k) :=  NULL;
           lv_net_qty(k) := NULL;

        ELSE

           -- The user changes the implement quantity at the time of release.
           -- We might need a factor (reverse cum yield) here to
           -- inflate the start quantity.

           lv_net_qty(k) := lv_implement_qty (k) +
                            lv_qty_scrapped(k) + lv_qty_completed (k);

           orig_net_qty := (lv_new_order_qty (k) +
                            lv_qty_scrapped(k) +
                            lv_qty_completed (k));
           IF (orig_net_qty <= 0.000001) THEN
               orig_net_qty := 1;
           END IF;

           lv_wip_start_qty_out(k) := lv_net_qty(k) *
                                      (lv_wip_start_qty_in(k) / orig_net_qty);

        END IF;

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
            source_line_id --Outbound Changes for XML
            , schedule_priority -- dsr
            , requested_completion_date -- dsr
            )
    SELECT  SYSDATE,
            arg_user_id,
            s.last_update_login,
            decode(tp.organization_type,2,s.creation_date,SYSDATE),
            arg_user_id,
            arg_wip_group_id,
            'MSC',
            msi.organization_id,
            tp.organization_type,
            DECODE(NVL(s.implement_status_code, s.wip_status_code),
                   JOB_CANCELLED,JOB_CANCELLED,NULL),
            decode(arg_load_type, WIP_DIS_MASS_RESCHEDULE, 3, 21), /* dsr 3 */
            s.implement_date,
            s.new_wip_Start_Date,
            NULL,
            NULL,
            s.implement_job_name,
            s.implement_firm,
            DECODE( tp.organization_type,
                    1,lv_wip_start_qty_out(j) ,
                    NULL),
            lv_net_qty(j),
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
            nvl(s.implement_uom_code,msi.uom_code),
            msi.sr_inventory_item_id,
            s.transaction_id --Outbound Changes for XML
            , s.schedule_priority -- dsr
            , s.requested_completion_date -- dsr
    FROM    msc_trading_partners tp,
            msc_parameters param,
            msc_system_items msi,
            msc_supplies     s,
            msc_plan_organizations_v orgs
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = msi.organization_id
    AND    param.sr_instance_id = msi.sr_instance_id
    AND    msi.inventory_item_id = s.inventory_item_id
    AND    msi.plan_id = s.plan_id
    AND    msi.organization_id = s.organization_id
    AND    msi.sr_instance_id  = s.sr_instance_id
    AND    s.release_errors is NULL
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
    --AND     ((arg_mode is null and s.load_type = WIP_DIS_MASS_RESCHEDULE) or
      AND     ((arg_mode is null and s.load_type = arg_load_type) or
                (arg_mode = 'WF' and s.transaction_id = arg_transaction_id))
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j);

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

    /* If the current plan is DRP plan then check the following conditions
       to determin whether we need to release the details or not
       1) For planned orders that do not use
          substitute components/alternateboms, only the
          header level information is released */

    l_count := 1;

    OPEN c_plan_type(arg_plan_id);
    FETCH c_plan_type INTO l_plan_type;
    CLOSE c_plan_type;

    IF l_plan_type = 5 THEN   -- DRP plan
       OPEN  c_release_dtls(arg_transaction_id, arg_plan_id);
       FETCH c_release_dtls INTO l_count;
       CLOSE c_release_dtls;
    END IF;

    /* If it is not a drp plan then l_count = 1 by default so details will be released */
    IF l_count = 1 THEN  /* Release details as well */
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
            WIP_ENTITY_ID
            , eam_flag -- dsr
            )
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
            s.sr_instance_id,
            resreq.operation_sequence_id, --Outbound Changes for XML
            s.disposition_id
            , decode(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
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
            -- resource_seq_num,
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
            department_id
            -- dsr: following 9 columns
            , firm_flag
            , setup_id
            , group_sequence_id
            , group_sequence_number
            , batch_id
            , maximum_assigned_units
            , parent_seq_num
            , eam_flag
            , resource_seq_num
            , schedule_seq_num
	  )
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
            -- resreq.RESOURCE_SEQ_NUM,
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
            -- decode(l_apps_ver,'3',TO_NUMBER(NULL),resreq.ASSIGNED_UNITS),
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
            resreq.department_id
             -- dsr: following 9 columns
            , resreq.firm_flag
            , resreq.setup_id
            , resreq.group_sequence_id
            , resreq.group_sequence_number
            , resreq.batch_number
            , resreq.maximum_assigned_units
            , resreq.parent_seq_num
            , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
            , resreq.orig_resource_seq_num
            , resreq.resource_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 2
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1 ;


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
            wip_entity_id,
             eam_flag -- dsr
            )
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
            decode(l_apps_ver,'4',to_number(null),'3',null,icomp.sr_inventory_item_id),
            decode(md.component_scaling_type,1,NULL,md.component_scaling_type),
            decode(l_apps_ver,'4',TO_NUMBER(NULL),'3',TO_NUMBER(NULL),(md.USING_REQUIREMENT_QUANTITY/s.implement_quantity)),
            md.component_yield_factor,
            TO_NUMBER(NULL),       --Department_ID
            NVL(GET_WIP_SUPPLY_TYPE(s.plan_id, s.sr_instance_id,s.process_seq_id,
                                    s.inventory_item_id,md.inventory_item_id,s.organization_id),
                    icomp.wip_supply_type),
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
            nvl(s.implement_uom_code, msi.uom_code),
            s.disposition_id
            , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
      FROM  msc_trading_partners    tp,
            msc_system_items        icomp,
            msc_demands             md,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   /*
            ( md.SUBST_ITEM_FLAG <> 1
              OR md.SUBST_ITEM_FLAG IS NULL) */
            not exists (select 'x'
                        from msc_exception_details excp
                        where excp.plan_id = msi.plan_id
                        and excp.number1 = s.transaction_id
                        and excp.inventory_item_id = msi.inventory_item_id
                        and excp.organization_id = msi.organization_id
                        and excp.sr_instance_id = msi.sr_instance_id
                        and excp.exception_type = 33
                        and excp.number2 = md.inventory_item_id)
    AND     tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     icomp.inventory_item_id= md.inventory_item_id
    AND     icomp.organization_id= md.organization_id
    AND     icomp.sr_instance_id= md.sr_instance_id
    AND     icomp.plan_id= md.plan_id
    AND     nvl(icomp.wip_supply_type,0) <> 6
    AND     md.sr_instance_id= s.sr_instance_id
    AND     md.disposition_id= s.transaction_id
    AND     md.plan_id= s.plan_id
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1;


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
            wip_entity_id
            , eam_flag -- dsr
            )
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
            decode(l_apps_ver,'4',to_number(null),'3',null,icomp.sr_inventory_item_id),
            decode(l_apps_ver,'4',to_number(null),'3',TO_NUMBER(NULL),(co.new_order_quantity/s.implement_quantity)),
            TO_NUMBER(NULL),       --Department_ID
            NVL(GET_WIP_SUPPLY_TYPE(s.plan_id, s.sr_instance_id,s.process_seq_id,
                                    s.inventory_item_id,co.inventory_item_id,s.organization_id),
                    icomp.wip_supply_type),
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
            nvl(s.implement_uom_code, msi.uom_code),
            s.disposition_id
             , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
      FROM  msc_trading_partners    tp,
            msc_system_items        icomp,
            msc_supplies            co,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   /*not exists (select 'x'
                        from msc_exception_details excp
                        where excp.plan_id = msi.plan_id
                        and excp.number1 = s.transaction_id
                        and excp.inventory_item_id = msi.inventory_item_id
                        and excp.organization_id = msi.organization_id
                        and excp.sr_instance_id = msi.sr_instance_id
                        and excp.exception_type = 33
                        and excp.number2 = co.inventory_item_id)
    AND     */
            tp.sr_tp_id             = msi.organization_id
    AND     tp.sr_instance_id       = msi.sr_instance_id
    AND     tp.partner_type         = 3
    AND     icomp.inventory_item_id = co.inventory_item_id
    AND     icomp.organization_id   = co.organization_id
    AND     icomp.sr_instance_id    = co.sr_instance_id
    AND     icomp.plan_id           = co.plan_id
    AND     co.sr_instance_id       = s.sr_instance_id
    AND     co.disposition_id       = s.transaction_id
    AND     co.plan_id              = s.plan_id
    AND     co.order_type           = 14 -- Discrete Job Co-products/by-products.
    AND     param.organization_id   = msi.organization_id
    AND     param.sr_instance_id    = msi.sr_instance_id
    AND     msi.inventory_item_id   = s.inventory_item_id
    AND     msi.plan_id             = s.plan_id
    AND     msi.organization_id     = s.organization_id
    AND     msi.sr_instance_id      = s.sr_instance_id
    AND     s.transaction_id        = lv_transaction_id(j)
    AND     s.sr_instance_id        = lv_instance_id(j)
    AND     s.plan_id               = arg_plan_id
    AND     lv_details_enabled(j)   = 1
    AND     lv_agg_details(j)       = 1
    AND     tp.organization_type    = 2;


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
            -- resource_seq_num,
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
            resource_hours
            , eam_flag -- dsr
            , resource_seq_num
            , schedule_seq_num
            ,parent_seq_num
            )
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
           -- resreq.RESOURCE_SEQ_NUM,
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
            -- decode(l_apps_ver,'3',TO_NUMBER(NULL),resreq.ASSIGNED_UNITS),
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
            resreq.resource_hours
            , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
            , resreq.orig_resource_seq_num
            , resreq.resource_seq_num
            ,resreq.parent_seq_num
      FROM  msc_trading_partners   tp,
            msc_resource_requirements resreq,
            msc_parameters          param,
            msc_system_items        msi,
            msc_supplies            s
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.parent_id   = 1
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id  = msi.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
     AND     tp.organization_type IN (1, 2);  -- 1 - discrete wip org; 2 - opm org

    -- dsr starts here
--    print_debug_info('OPERATION RESOURCE_INSTANCES');
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
           -- resource_seq_num,
            resource_id_old, -- rawasthi
	    resource_id_new, -- xx resource_id, ???
            RESOURCE_INSTANCE_ID,
            start_date,
            completion_date,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status,
            SR_INSTANCE_ID,
            operation_seq_id,
            -- FIRM_FLAG,
            resource_hours,
            department_id,
	    -- setup_id,
	    SERIAL_NUMBER,
            group_sequence_id,
            group_sequence_number,
            batch_id,
            resource_seq_num
            , schedule_seq_num
            , wip_entity_id -- for reschedule
            , eam_flag -- dsr
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
          arg_wip_group_id,
          s.transaction_id,
          resreq.OPERATION_SEQ_NUM,
       --   resreq.RESOURCE_SEQ_NUM,
          resreq.resource_id,
          resreq.resource_id,
  -- jguo dep_res_inst.RESOURCE_INST_ID,
          dep_res_inst.RES_INSTANCE_ID ,
          nvl(resreq.firm_start_date,res_instreq.START_DATE),
          nvl(resreq.firm_end_date,res_instreq.END_DATE),
          SUBST_ADD, -- jguo SUBST_CHANGE,
          LT_RESOURCE_INSTANCE,
          2,
          1,
          s.sr_instance_id,
          resreq.operation_sequence_id,
       -- res_instreq.firm_flag,
          resreq.resource_hours,
          resreq.department_id,
         -- resreq.department_id / 2, rawasthi
       -- res_instreq.setup_id,
          dep_res_inst.serial_number,
          resreq.group_sequence_id,
          resreq.group_sequence_number,
          res_instreq.batch_number,    --- sbala res_instreq.res_inst_batch_id,
          resreq.orig_resource_seq_num,
          resreq.resource_seq_num
      --  resreq.alternate_num,
        , s.disposition_id -- for reschedule
        , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
        , resreq.parent_seq_num
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
-- dsr AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
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
-- dsr   AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
 AND     res_instreq.plan_id = dep_res_inst.plan_id
 AND     res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
 AND     res_instreq.department_id = dep_res_inst.department_id
 AND     res_instreq.resource_id = dep_res_inst.resource_id
/* anuj: serail number and resource_instance id joins */
 AND     res_instreq.serial_number = dep_res_inst.serial_number
 AND     res_instreq.res_instance_id = dep_res_inst.res_instance_id
 AND     s.transaction_id= lv_transaction_id(j)
 AND     s.sr_instance_id= lv_instance_id(j)
 AND     s.plan_id= arg_plan_id
 AND     lv_details_enabled(j)= 1
 AND     lv_agg_details(j) = 1
    ;

--print_debug_info('reschedule_wip_discrete_jobs: 888 sql%rowcount = '|| SQL%ROWCOUNT);


    -- RESOURCE INSTANCE USAGES
--print_debug_info('RESOURCE INSTANCE USAGES');
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
           -- resource_seq_num,
            resource_id_old, -- rawasthi
	    resource_id_new, -- xx RESOURCE_ID, ???
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
         -- alternate_num
     	  , wip_entity_id -- for reschedule
	  , eam_flag -- dsr
	  , assigned_units -- jguo
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
           arg_wip_group_id,
           s.transaction_id,
           resreq.OPERATION_SEQ_NUM,
       --    resreq.RESOURCE_SEQ_NUM,
           resreq.RESOURCE_ID,
           resreq.RESOURCE_ID,
  -- jguo  dep_res_inst.RESOURCE_INST_ID,
           dep_res_inst.RES_INSTANCE_ID ,
           nvl(resreq.firm_start_date,res_instreq.START_DATE),
           nvl(resreq.firm_end_date,res_instreq.END_DATE),
           SUBST_ADD, -- jguo SUBST_CHANGE,
           LT_RESOURCE_INST_USAGE,
           2,
           1,
           s.sr_instance_id,
           resreq.operation_sequence_id,
           resreq.firm_flag,
           res_instreq.resource_instance_hours,
           resreq.department_id,
          -- resreq.department_id / 2, rawasthi
           dep_res_inst.serial_number,
           resreq.orig_resource_seq_num,
           resreq.resource_seq_num
        -- resreq.alternate_num
         , s.disposition_id -- for reschedule
         , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
         , 1 -- jguo
         ,resreq.parent_seq_num
    FROM
           msc_trading_partners   tp,
           msc_resource_requirements resreq,
           msc_resource_instance_reqs res_instreq, -- ??? msc_res_inst_requirements res_instreq,
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
-- dsr   AND     resreq.transaction_id = res_instreq.res_inst_transaction_id
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
-- dsr   AND     res_instreq.res_instance_id = dep_res_inst.dept_resource_inst_id
    AND     res_instreq.department_id = dep_res_inst.department_id
    AND     res_instreq.resource_id = dep_res_inst.resource_id
    AND     res_instreq.plan_id = dep_res_inst.plan_id
    AND     res_instreq.sr_instance_id = dep_res_inst.sr_instance_id
/* anuj: serail number and resource_instance id joins */
    AND     res_instreq.serial_number = dep_res_inst.serial_number
    AND     res_instreq.res_instance_id = dep_res_inst.res_instance_id
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
    ;

--print_debug_info('reschedule_wip_discrete_jobs: 999 sql%rowcount = '|| SQL%ROWCOUNT);


-- Resource Charges

--print_debug_info('RESOURCE CHARGES');

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
            resource_seq_num,
	    alternate_num,
            start_date,
            completion_date,
	    required_quantity,
	    charge_number,
            SR_INSTANCE_ID,
            SUBSTITUTION_TYPE,
            LOAD_TYPE,
            process_phase,
            process_status
          , wip_entity_id -- for reschedule
          , eam_flag -- dsr
          , resource_id_old
          , resource_id_new
          , schedule_seq_num
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
            resreq.ORIG_RESOURCE_SEQ_NUM,
            resreq.alternate_num,
            Chg.charge_start_datetime,
            Chg.charge_end_datetime,
            chg.charge_quantity, -- Chg.Planned_Charge_Quantity,
            Chg.charge_number,
            s.sr_instance_id,
            SUBST_CHANGE, -- 3
            LT_CHARGE_TYPE, --8
            2,
            1
          , s.disposition_id -- for reschedule
          , DECODE(arg_load_type, EAM_RESCHEDULE_WORK_ORDER, SYS_YES, SYS_NO) -- dsr: eam_flag
          , resreq.RESOURCE_ID
          ,  resreq.RESOURCE_ID
          ,  resreq.resource_seq_num
     FROM
             msc_trading_partners   tp,
             msc_resource_requirements resreq,
             msc_supplies            s,
             msc_resource_charges chg
    WHERE
            tp.sr_tp_id=s.organization_id
    AND     tp.sr_instance_id= s.sr_instance_id
    AND     tp.partner_type=3
    AND     resreq.sr_instance_id= s.sr_instance_id
    AND     resreq.organization_id= s.organization_id
    AND     resreq.supply_id = s.transaction_id
    AND     resreq.plan_id   = s.plan_id
    AND     resreq.transaction_id = chg.res_transaction_id -- chg.transaction_id
    AND     resreq.plan_id = chg.plan_id
    AND     resreq.sr_instance_id = chg.sr_instance_id
    AND     resreq.parent_id   = 2
    AND     resreq.resource_id <> -1
    AND     resreq.department_id <> -1
    AND     s.transaction_id= lv_transaction_id(j)
    AND     s.sr_instance_id= lv_instance_id(j)
    AND     s.plan_id= arg_plan_id
    AND     lv_details_enabled(j)= 1
    AND     lv_agg_details(j) = 1
	;

--print_debug_info('reschedule_wip_discrete_jobs: aaa sql%rowcount = '|| SQL%ROWCOUNT);

-- dsr ends here
   END IF; /* End of l_count = 1 */

    FORALL j IN 1..lv_job_count
       update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= lv_transaction_id(j);

    RETURN lv_resched_jobs;

END reschedule_wip_discrete_jobs;

FUNCTION load_repetitive_schedules
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER

IS
   lv_loaded_scheds    NUMBER;
BEGIN

    -- ------------------------------------------------------------------------
    -- Perform the wip repetitive schedule mass load
    -- ------------------------------------------------------------------------
    l_sql_stmt := ' INSERT INTO msc_wip_job_schedule_interface
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
            last_unit_completion_date,
            bom_revision_date,
            routing_revision_date,
            processing_work_days,
            daily_production_rate,
            line_id,
            primary_item_id,
            firm_planned_flag,
            demand_class,
	    process_phase,
	    process_status,
            bom_reference_id,
            routing_reference_id,
            BILL_RTG_EXPLOSION_FLAG,
            HEADER_ID,
            uom_code, --Outbound Changes for XML
            SR_INSTANCE_ID)
       SELECT SYSDATE,
            :arg_user_id,
            s.last_update_login,
            SYSDATE,
            :arg_user_id,
            :arg_wip_group_id,
            ''MSC'',
            s.transaction_id,
            msi.organization_id,
            tp.organization_type,
            2,
            s.implement_date,
			NULL,
			NULL,
            s.implement_processing_days,
            s.implement_daily_rate,
            s.implement_line_id,
            msi.sr_inventory_item_id,
            s.implement_firm,
            s.implement_demand_class,
            2,
            1,
            DECODE( tp.organization_type,
                    2, mpe.bill_sequence_id,
                    NULL),
            DECODE( tp.organization_type,
                    2, mpe.routing_sequence_id,
                    NULL),
            ''Y'',
            s.transaction_id,
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id
    FROM    msc_trading_partners tp,
            msc_parameters param,
            msc_system_items msi,
            msc_process_effectivity mpe,
            msc_supplies     s,
            msc_plan_organizations_v orgs
    WHERE   tp.sr_tp_id= msi.organization_id
    AND     tp.sr_instance_id= msi.sr_instance_id
    AND     tp.partner_type=3
    AND     param.organization_id = msi.organization_id
    AND     param.sr_instance_id = msi.sr_instance_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     mpe.plan_id(+)= s.plan_id
    AND     mpe.process_sequence_id(+)= s.process_seq_id
    AND	    s.release_errors is NULL
    AND     s.implement_daily_rate > 0
    AND     s.organization_id = orgs.planned_organization
    AND     s.sr_instance_id = orgs.sr_instance_id
    AND     s.plan_id = orgs.plan_id
    AND     orgs.organization_id = :arg_owning_org_id
    AND     orgs.owning_sr_instance = :arg_owning_instance
    AND     orgs.plan_id = :arg_plan_id
    AND     orgs.sr_instance_id = :arg_org_instance
    and    (s.releasable = ' || RELEASABLE || ' or s.releasable is null )' ;

    IF  v_batch_id_populated = 2 THEN
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id is NULL ';
    ELSE
        l_sql_stmt :=  l_sql_stmt || ' AND  s.batch_id = ' || g_batch_id || ' ' ;
    END IF;

    IF arg_log_org_id <> arg_owning_org_id THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND     orgs.planned_organization = ' || arg_log_org_id || ' ' ;
    END IF;

    IF arg_mode IS NULL THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type = ' || WIP_REP_MASS_LOAD || ' ';
        IF v_msc_released_only_by_user = 1 THEN
            l_sql_stmt :=  l_sql_stmt || ' AND s.last_updated_by = ' || v_user_id || ' ' ;
        END IF;
    ELSIF arg_mode = 'WF_BATCH' THEN
        l_sql_stmt :=  l_sql_stmt ||'  AND s.load_type =  ' || WIP_REP_MASS_LOAD || ' ';
    ELSIF arg_mode = 'WF' THEN
        l_sql_stmt :=  l_sql_stmt ||'      AND s.transaction_id = ' || arg_transaction_id  || '  ' ;
    END IF;

    lv_loaded_scheds:= 0;
    IF arg_mode IS NULL OR arg_mode = 'WF_BATCH' OR arg_mode = 'WF' THEN
        EXECUTE IMMEDIATE l_sql_stmt USING  arg_user_id
                                           ,arg_user_id
                                           ,arg_wip_group_id
                                           ,arg_owning_org_id
                                           ,arg_owning_instance
                                           ,arg_plan_id
                                           ,arg_org_instance;
        lv_loaded_scheds:= SQL%ROWCOUNT;
    END IF;


   IF arg_mode = 'WF' THEN
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= arg_transaction_id;
   ELSE
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id in (select source_line_id from msc_wip_job_schedule_interface
                                   where group_id = arg_wip_group_id);
   END IF;

    RETURN lv_loaded_scheds;

END load_repetitive_schedules;

FUNCTION load_po_requisitions
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_po_group_by 		IN 	NUMBER
, arg_po_batch_number 		IN 	NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER
IS
   lv_loaded_reqs    NUMBER;
   lv_errbuf         VARCHAR2(2048);
   ln_retcode        NUMBER;
   lv_custom         EXCEPTION;
BEGIN

    -- ------------------------------------------------------------------------
    -- Perform the po mass load
    -- ------------------------------------------------------------------------
    --  Check if the profile MRP_PURCHASING_BY_REVISION is set
    --  NOTE: We always pass 'VENDOR' as the group by parameter to the req
    -- import program.  PO will only look at this parameter if it has failed
    -- to find a value in the group code.



    INSERT INTO msc_po_requisitions_interface /*+ FIRST_ROWS */
            (
            /*line_type_id, Amount or Quantity based */
	    last_updated_by,
            last_update_date,
            last_update_login,
            creation_date,
            created_by,
            item_id,
            quantity,
            need_by_date,
            interface_source_code,
            deliver_to_location_id,
            deliver_to_requestor_id,
            destination_type_code,
            preparer_id,
            source_type_code,
            authorization_status,
            uom_code,
            batch_id,
            charge_account_id,
            group_code,
            item_revision,
            destination_organization_id,
            autosource_flag,
            org_id,
            source_organization_id,
            suggested_vendor_id,
            /*suggested_vendor_site_id,  -- For Outbound Changes for XML*/
            suggested_vendor_site,
            project_id,
            task_id,
	    end_item_unit_number,
            project_accounting_context,
            source_line_id, -- Outbound Changes for XML
            SR_INSTANCE_ID)
     SELECT /*+ FIRST_ROWS */
            /*1, Quantity based */
            s.last_updated_by,
            SYSDATE,
            s.last_update_login,
            SYSDATE,
            s.created_by,
            msi.sr_inventory_item_id,
            s.implement_quantity,
            /*nvl(get_cal_date(s.sr_instance_id,
                             cal2.calendar_date,
                             mis.delivery_calendar_code), cal2.calendar_date),*/

	    --implement_dock_date becomes null for manual po
	    nvl(s.implement_dock_date,
		nvl(s.new_dock_date,
			trunc(sysdate)
		)
	    ),
	    'MSC',
            s.implement_location_id,
            s.implement_employee_id,
            'INVENTORY',
            s.implement_employee_id,
            DECODE(s.implement_supplier_id,
                   NULL, DECODE(s.implement_source_org_id,
                                  NULL,to_char(NULL),
                                  decode(mp1.MODELED_SUPPLIER_ID,
                                          NULL,'INVENTORY', 'VENDOR') ),
                   'VENDOR'), -- PO wants us to pass null now -- spob
            'APPROVED',
            msi.uom_code, --mr.implement_uom_code,
            arg_po_batch_number,
            decode(mp.organization_type,1,nvl(mpp.material_account,
                      decode( msi1.inventory_asset_flag,
                              'Y', mp.material_account,
		              nvl(msi1.expense_account, mp.expense_account))),-1),
            decode(arg_po_group_by,
                REQ_GRP_ALL_ON_ONE, 'ALL-ON-ONE',
                REQ_GRP_ITEM, to_char(s.inventory_item_id),
                REQ_GRP_BUYER, nvl(to_char(msi.buyer_id),NULL),
                REQ_GRP_PLANNER, nvl(msi.planner_code,'PLANNER'),
                REQ_GRP_VENDOR,  NULL,
                REQ_GRP_ONE_EACH, to_char(-100),
                REQ_GRP_CATEGORY,nvl(to_char(msi.sr_category_id),NULL),
                REQ_GRP_LOCATION,NULL,
                NULL),
            DECODE( v_purchasing_by_rev,
                    NULL, DECODE( msi.REVISION_QTY_CONTROL_CODE,
			          NOT_UNDER_REV_CONTROL, NULL,
                                  msi.revision),
	            PURCHASING_BY_REV, msi.revision,
	            NOT_PURCHASING_BY_REV, NULL),
            s.organization_id,
            'P',
            mp.operating_unit,
    /* for single instance if the organization is modelled then the source_sr_instane_id = sr_instance_id
       in msc_supplies so we can safely use mp1 for both cases.
       For cross-instance releases get the modeled supplier infor */
            decode(s.implement_source_org_id, NULL, to_number(NULL),
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,s.implement_source_org_id, to_number(NULL) ) ),
            decode(s.implement_source_org_id, NULL ,supplier.sr_tp_id,
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,to_number(NULL),
                                     GET_MODELED_SR_TP_ID(mp1.MODELED_SUPPLIER_ID,s.sr_instance_id)
                               )),
            decode(s.implement_source_org_id, NULL ,mtps.tp_site_code,
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,to_char(NULL),
                                     GET_MODELED_TP_SITE_CODE(mp1.MODELED_SUPPLIER_ID,
                                                              mp1.MODELED_SUPPLIER_SITE_ID,s.sr_instance_id)
                               )),
            s.implement_project_id,
            s.implement_task_id,
  	    s.implement_unit_number,
	    DECODE(s.implement_project_id, NULL, 'N', 'Y'),
            s.transaction_id,-- For Outbound Changes for XML
            s.sr_instance_id
    FROM    msc_projects mpp,
            --msc_calendar_dates cal1,
            --msc_calendar_dates cal2,
            msc_tp_id_lid        supplier,
            msc_trading_partner_sites mtps,
            msc_trading_partners mp, -- mtl_parameters      mp,
            msc_trading_partners mp1,
            msc_system_items    msi,
            msc_system_items    msi1,
            msc_supplies        s,
            msc_item_suppliers mis,
            msc_plan_organizations_v orgs
    WHERE   supplier.tp_id(+)=
                nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     supplier.partner_type(+)=1
    AND     supplier.sr_instance_id(+)= s.sr_instance_id
    AND     mtps.partner_id(+) = nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     mtps.partner_type(+) = 1
    AND     mtps.partner_site_id(+) = nvl(s.implement_supplier_site_id, s.source_supplier_site_id)
    AND     mis.sr_instance_id (+) = s.sr_instance_id
    AND     mis.plan_id (+) = s.plan_id
    AND     mis.inventory_item_id (+) = s.inventory_item_id
    AND     mis.organization_id (+) = s.organization_id
    AND     mis.using_organization_id (+) = -1
    AND    mis.supplier_id (+) = nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     mis.supplier_site_id (+) =  nvl(s.implement_supplier_site_id, s.source_supplier_site_id)
    AND     mpp.organization_id (+)= s.organization_id
    AND	    mpp.project_id (+)= nvl(s.implement_project_id, -23453)
    AND     mpp.plan_id (+)= s.plan_id
    AND     mpp.sr_instance_id(+)= s.sr_instance_id
    --AND     cal1.sr_instance_id= mp.sr_instance_id
    --AND	    cal1.calendar_code = mp.calendar_code
    --AND     cal1.exception_set_id = mp.calendar_exception_set_id
    --AND     cal1.calendar_date = trunc(s.implement_date)
    --AND     cal2.sr_instance_id = cal1.sr_instance_id
    -- AND     cal2.calendar_code = cal1.calendar_code
    --AND     cal2.exception_set_id = cal1.exception_set_id
    --AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -     NVL(msi.postprocessing_lead_time, 0))
    AND     mp.sr_tp_id  = msi.organization_id
    AND     mp.sr_instance_id = msi.sr_instance_id
    AND     mp.partner_type= 3
AND mp1.sr_tp_id (+)= s.SOURCE_ORGANIZATION_ID
AND mp1.sr_instance_id (+)= s.SOURCE_SR_INSTANCE_ID
AND mp1.partner_type(+)= 3
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     msi1.plan_id = -1
    AND     msi1.sr_instance_id = msi.sr_instance_id
    AND     msi1.organization_id = msi.organization_id
    AND     msi1.inventory_item_id = msi.inventory_item_id
    AND	    s.release_errors is NULL
    AND     s.implement_quantity > 0
    AND     s.organization_id = orgs.planned_organization
    AND     s.sr_instance_id = orgs.sr_instance_id
    AND     s.plan_id = orgs.plan_id
    AND     orgs.organization_id = arg_owning_org_id
    AND     orgs.owning_sr_instance = arg_owning_instance
    AND     orgs.plan_id = arg_plan_id
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_owning_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     orgs.sr_instance_id  = arg_org_instance
    AND     (arg_mode is null and s.load_type = PO_MASS_LOAD and s.load_type IS NOT NULL)
    AND     s.last_updated_by = decode(v_msc_released_only_by_user,1,v_user_id,s.last_updated_by)
    and (s.releasable = RELEASABLE or s.releasable is null )
    and  (s.batch_id = g_batch_id or (v_batch_id_populated = 2 and s.batch_id is null) )
    UNION ALL
    SELECT /*+ FIRST_ROWS */
            /*1,  Quantity based */
            s.last_updated_by,
            SYSDATE,
            s.last_update_login,
            SYSDATE,
            s.created_by,
            msi.sr_inventory_item_id,
            s.implement_quantity,
           /* nvl(get_cal_date(s.sr_instance_id,
                             cal2.calendar_date,
                             mis.delivery_calendar_code), cal2.calendar_date),*/

	    --implement_dock_date becomes null for manual po
	    nvl(s.implement_dock_date,
		nvl(s.new_dock_date,
			trunc(sysdate)
		)
	    ),

            'MSC',
            s.implement_location_id,
            s.implement_employee_id,
            'INVENTORY',
            s.implement_employee_id,
            DECODE(s.implement_supplier_id,
                   NULL, DECODE(s.implement_source_org_id,
                                  NULL,to_char(NULL),
                                  decode(mp1.MODELED_SUPPLIER_ID,
                                          NULL,'INVENTORY', 'VENDOR') ),
                   'VENDOR'), -- PO wants us to pass null now -- spob
            'APPROVED',
            msi.uom_code, --mr.implement_uom_code,
            arg_po_batch_number,
            decode(mp.organization_type,1,nvl(mpp.material_account,
                      decode( msi1.inventory_asset_flag,
                              'Y', mp.material_account,
		              nvl(msi1.expense_account, mp.expense_account))),-1),
            decode(arg_po_group_by,
                REQ_GRP_ALL_ON_ONE, 'ALL-ON-ONE',
                REQ_GRP_ITEM, to_char(s.inventory_item_id),
                REQ_GRP_BUYER, nvl(to_char(msi.buyer_id),NULL),
                REQ_GRP_PLANNER, nvl(msi.planner_code,'PLANNER'),
                REQ_GRP_VENDOR,  NULL,
                REQ_GRP_ONE_EACH, to_char(-100),
                REQ_GRP_CATEGORY,nvl(to_char(msi.sr_category_id),NULL),
                REQ_GRP_LOCATION,NULL,
                NULL),
            DECODE( v_purchasing_by_rev,
                    NULL, DECODE( msi.REVISION_QTY_CONTROL_CODE,
			          NOT_UNDER_REV_CONTROL, NULL,
                                  msi.revision),
	            PURCHASING_BY_REV, msi.revision,
	            NOT_PURCHASING_BY_REV, NULL),
            s.organization_id,
            'P',
            mp.operating_unit,
            decode(s.implement_source_org_id, NULL, to_number(NULL),
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,s.implement_source_org_id, to_number(NULL) ) ),
            decode(s.implement_source_org_id, NULL ,supplier.sr_tp_id,
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,to_number(NULL),
                                     GET_MODELED_SR_TP_ID(mp1.MODELED_SUPPLIER_ID,s.sr_instance_id)
                               )),
            decode(s.implement_source_org_id, NULL ,mtps.tp_site_code,
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,to_char(NULL),
                                     GET_MODELED_TP_SITE_CODE(mp1.MODELED_SUPPLIER_ID,
                                                              mp1.MODELED_SUPPLIER_SITE_ID,s.sr_instance_id)
                               )),
            s.implement_project_id,
            s.implement_task_id,
  	    s.implement_unit_number,
	    DECODE(s.implement_project_id, NULL, 'N', 'Y'),
            s.transaction_id, -- Outbound Changes for XML
            s.sr_instance_id
    FROM    msc_projects mpp,
           -- msc_calendar_dates cal1,
           -- msc_calendar_dates cal2,
            msc_tp_id_lid        supplier,
            msc_trading_partner_sites mtps,
            msc_trading_partners mp, -- mtl_parameters      mp,
            msc_trading_partners mp1,
            msc_system_items    msi,
            msc_system_items    msi1,
            msc_item_suppliers mis,
            msc_supplies        s,
            msc_plan_organizations_v orgs
    WHERE   supplier.tp_id(+)=
                nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     supplier.partner_type(+)=1
    AND     supplier.sr_instance_id(+)= s.sr_instance_id
    AND     mtps.partner_id(+) = nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     mtps.partner_type(+) = 1
    AND     mtps.partner_site_id(+) = nvl(s.implement_supplier_site_id, s.source_supplier_site_id)
    AND     mis.sr_instance_id (+) = s.sr_instance_id
    AND     mis.plan_id (+) = s.plan_id
    AND     mis.inventory_item_id (+) = s.inventory_item_id
    AND     mis.organization_id (+) = s.organization_id
    AND     mis.using_organization_id (+) = -1
    AND    mis.supplier_id (+) = nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     mis.supplier_site_id (+) =  nvl(s.implement_supplier_site_id, s.source_supplier_site_id)
    AND     mpp.organization_id (+)= s.organization_id
    AND	    mpp.project_id (+)= nvl(s.implement_project_id, -23453)
    AND     mpp.plan_id (+)= s.plan_id
    AND     mpp.sr_instance_id(+)= s.sr_instance_id
   -- AND     cal1.sr_instance_id= mp.sr_instance_id
   -- AND	    cal1.calendar_code = mp.calendar_code
    --AND     cal1.exception_set_id = mp.calendar_exception_set_id
   -- AND     cal1.calendar_date = trunc(s.implement_date)
   -- AND     cal2.sr_instance_id = cal1.sr_instance_id
   -- AND     cal2.calendar_code = cal1.calendar_code
   -- AND     cal2.exception_set_id = cal1.exception_set_id
   -- AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -     NVL(msi.postprocessing_lead_time, 0))
    AND     mp.sr_tp_id  = msi.organization_id
    AND     mp.sr_instance_id = msi.sr_instance_id
    AND     mp.partner_type= 3
AND mp1.sr_tp_id (+)= s.SOURCE_ORGANIZATION_ID
AND mp1.sr_instance_id (+)= s.SOURCE_SR_INSTANCE_ID
AND mp1.partner_type(+)= 3
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     msi1.plan_id = -1
    AND     msi1.sr_instance_id = msi.sr_instance_id
    AND     msi1.organization_id = msi.organization_id
    AND     msi1.inventory_item_id = msi.inventory_item_id
    AND	    s.release_errors is NULL
    AND     s.implement_quantity > 0
    AND     s.organization_id = orgs.planned_organization
    AND     s.sr_instance_id = orgs.sr_instance_id
    AND     s.plan_id = orgs.plan_id
    AND     orgs.organization_id = arg_owning_org_id
    AND     orgs.owning_sr_instance = arg_owning_instance
    AND     orgs.plan_id = arg_plan_id
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_owning_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     orgs.sr_instance_id  = arg_org_instance
    AND     (arg_mode = 'WF_BATCH' and s.load_type = PO_MASS_LOAD and s.load_type IS NOT NULL)
    and (s.releasable = RELEASABLE or s.releasable is null )
    and  (s.batch_id = g_batch_id or (v_batch_id_populated = 2 and s.batch_id is null) )
    UNION ALL
    SELECT /*+ FIRST_ROWS */
            /*1,  Quantity based */
            s.last_updated_by,
            SYSDATE,
            s.last_update_login,
            SYSDATE,
            s.created_by,
            msi.sr_inventory_item_id,
            s.implement_quantity,
            /*nvl(get_cal_date(s.sr_instance_id,
                             cal2.calendar_date,
                             mis.delivery_calendar_code), cal2.calendar_date),*/

	    --implement_dock_date becomes null for manual po
	    nvl(s.implement_dock_date,
		nvl(s.new_dock_date,
			trunc(sysdate)
		)
	    ),

	    'MSC',
            s.implement_location_id,
            s.implement_employee_id,
            'INVENTORY',
            s.implement_employee_id,
            DECODE(s.implement_supplier_id,
                   NULL, DECODE(s.implement_source_org_id,
                                  NULL,to_char(NULL),
                                  decode(mp1.MODELED_SUPPLIER_ID,
                                          NULL,'INVENTORY', 'VENDOR') ),
                   'VENDOR'), -- PO wants us to pass null now -- spob
            'APPROVED',
            msi.uom_code, --mr.implement_uom_code,
            arg_po_batch_number,
            decode(mp.organization_type,1,nvl(mpp.material_account,
                      decode( msi1.inventory_asset_flag,
                              'Y', mp.material_account,
		              nvl(msi1.expense_account, mp.expense_account))),-1),
            decode(arg_po_group_by,
                REQ_GRP_ALL_ON_ONE, 'ALL-ON-ONE',
                REQ_GRP_ITEM, to_char(s.inventory_item_id),
                REQ_GRP_BUYER, nvl(to_char(msi.buyer_id),NULL),
                REQ_GRP_PLANNER, nvl(msi.planner_code,'PLANNER'),
                REQ_GRP_VENDOR,  NULL,
                REQ_GRP_ONE_EACH, to_char(-100),
                REQ_GRP_CATEGORY,nvl(to_char(msi.sr_category_id),NULL),
                REQ_GRP_LOCATION,NULL,
                NULL),
            DECODE( v_purchasing_by_rev,
                    NULL, DECODE( msi.REVISION_QTY_CONTROL_CODE,
			          NOT_UNDER_REV_CONTROL, NULL,
                                  msi.revision),
	            PURCHASING_BY_REV, msi.revision,
	            NOT_PURCHASING_BY_REV, NULL),
            s.organization_id,
            'P',
            mp.operating_unit,
            decode(s.implement_source_org_id, NULL, to_number(NULL),
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,s.implement_source_org_id, to_number(NULL) ) ),
            decode(s.implement_source_org_id, NULL ,supplier.sr_tp_id,
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,to_number(NULL),
                                     GET_MODELED_SR_TP_ID(mp1.MODELED_SUPPLIER_ID,s.sr_instance_id)
                               )),
            decode(s.implement_source_org_id, NULL ,mtps.tp_site_code,
                        decode(mp1.MODELED_SUPPLIER_ID, NULL,to_char(NULL),
                                     GET_MODELED_TP_SITE_CODE(mp1.MODELED_SUPPLIER_ID,
                                                              mp1.MODELED_SUPPLIER_SITE_ID,s.sr_instance_id)
                               )),
            s.implement_project_id,
            s.implement_task_id,
  	    s.implement_unit_number,
	    DECODE(s.implement_project_id, NULL, 'N', 'Y'),
            s.transaction_id, --outbound changes for XML
            s.sr_instance_id
    FROM    msc_projects mpp,
           -- msc_calendar_dates cal1,
           -- msc_calendar_dates cal2,
            msc_tp_id_lid        supplier,
            msc_trading_partner_sites mtps,
            msc_trading_partners mp, -- mtl_parameters      mp,
            msc_trading_partners mp1,
            msc_system_items    msi,
            msc_system_items    msi1,
            msc_item_suppliers mis,
            msc_supplies        s,
            msc_plan_organizations_v orgs
    WHERE   supplier.tp_id(+)=
                nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     supplier.partner_type(+)=1
    AND     supplier.sr_instance_id(+)= s.sr_instance_id
    AND     mtps.partner_id(+) = nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     mtps.partner_type(+) = 1
    AND     mtps.partner_site_id(+) = nvl(s.implement_supplier_site_id, s.source_supplier_site_id)
    AND     mis.sr_instance_id (+) = s.sr_instance_id
    AND     mis.plan_id (+) = s.plan_id
    AND     mis.inventory_item_id (+) = s.inventory_item_id
    AND     mis.organization_id (+) = s.organization_id
    AND     mis.using_organization_id (+) = -1
    AND    mis.supplier_id (+) = nvl(s.implement_supplier_id, s.source_supplier_id)
    AND     mis.supplier_site_id (+) =  nvl(s.implement_supplier_site_id, s.source_supplier_site_id)
    AND     mpp.organization_id (+)= s.organization_id
    AND	    mpp.project_id (+)= nvl(s.implement_project_id, -23453)
    AND     mpp.plan_id (+)= s.plan_id
    AND     mpp.sr_instance_id(+)= s.sr_instance_id
    --AND     cal1.sr_instance_id= mp.sr_instance_id
    --AND	    cal1.calendar_code = mp.calendar_code
    --AND     cal1.exception_set_id = mp.calendar_exception_set_id
    --AND     cal1.calendar_date = trunc(s.implement_date)
    --AND     cal2.sr_instance_id = cal1.sr_instance_id
   -- AND     cal2.calendar_code = cal1.calendar_code
    --AND     cal2.exception_set_id = cal1.exception_set_id
    --AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -                NVL(msi.postprocessing_lead_time, 0))
    AND     mp.sr_tp_id  = msi.organization_id
    AND     mp.sr_instance_id = msi.sr_instance_id
    AND     mp.partner_type= 3
AND mp1.sr_tp_id (+)= s.SOURCE_ORGANIZATION_ID
AND mp1.sr_instance_id (+)= s.SOURCE_SR_INSTANCE_ID
AND mp1.partner_type(+)= 3
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND     msi1.plan_id = -1
    AND     msi1.sr_instance_id = msi.sr_instance_id
    AND     msi1.organization_id = msi.organization_id
    AND     msi1.inventory_item_id = msi.inventory_item_id
    AND	    s.release_errors is NULL
    AND     s.implement_quantity > 0
    AND     s.organization_id = orgs.planned_organization
    AND     s.sr_instance_id = orgs.sr_instance_id
    AND     s.plan_id = orgs.plan_id
    AND     orgs.organization_id = arg_owning_org_id
    AND     orgs.owning_sr_instance = arg_owning_instance
    AND     orgs.plan_id = arg_plan_id
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_owning_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     orgs.sr_instance_id  = arg_org_instance
    AND     (arg_mode = 'WF' and s.transaction_id = arg_transaction_id)
    and (s.releasable = RELEASABLE or s.releasable is null )
    and  (s.batch_id = g_batch_id or (v_batch_id_populated = 2 and s.batch_id is null) );

    IF SQL%ROWCOUNT > 0 THEN
        lv_loaded_reqs := SQL%ROWCOUNT;
    ELSE
        lv_loaded_reqs := 0;
    END IF;

    update msc_po_requisitions_interface
    set group_code =  to_char(msc_po_requisitions_int_s.nextval)
    where group_code = '-100'
      and batch_id = arg_po_batch_number;

    msc_cl_cleanse.cleanse_release(lv_errbuf,
                                   ln_retcode,
                                   PO_MASS_LOAD,
                                   arg_org_instance,
                                   arg_po_batch_number
                                   );
    IF ln_retcode = 2 THEN --error
      raise lv_custom;
    END IF;

   IF arg_mode = 'WF' THEN
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= arg_transaction_id;
   ELSE
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id in (select source_line_id from msc_po_requisitions_interface
                                   where batch_id = arg_po_batch_number);
   END IF;

    return lv_loaded_reqs;

END load_po_requisitions;

FUNCTION reschedule_po
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_po_batch_number 		IN 	NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER
IS
   lv_resched_reqs NUMBER;
BEGIN
    -- ------------------------------------------------------------------------
    -- Perform the po mass reschedule
    -- ------------------------------------------------------------------------

    INSERT INTO msc_po_reschedule_interface
           (process_id,
            quantity,
            need_by_date,
            line_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            purchase_order_id, -- outbound Changes for XML
            po_number,         -- outbound Changes for XML
            source_line_id,    -- outbound Changes for XML
            uom,               -- outbound Changes for XML
            SR_INSTANCE_ID,
            batch_id)
    SELECT  NULL,
            s.implement_quantity,
            --cal2.calendar_date,
	    s.implement_dock_date,
            s.po_line_id,
            SYSDATE,
            arg_user_id,
            SYSDATE,
            arg_user_id,
            s.disposition_id,
            s.order_number,
            s.transaction_id,
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id,
            g_batch_id
    FROM    --msc_calendar_dates cal1,
            --msc_calendar_dates cal2,
            msc_trading_partners mp,
            msc_system_items msi,
            msc_supplies s,
            msc_apps_instances mai,  -- IR/ISO resch Proj
            msc_plan_organizations_v orgs
    WHERE   --cal1.sr_instance_id= mp.sr_instance_id
    --AND     cal1.calendar_code = mp.calendar_code
    --AND     cal1.exception_set_id = mp.calendar_exception_set_id
    --AND     cal1.calendar_date = trunc(s.implement_date)
   -- AND     cal2.sr_instance_id= cal1.sr_instance_id
    --AND     cal2.calendar_code = cal1.calendar_code
    --AND     cal2.exception_set_id = cal1.exception_set_id
    --AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -                NVL(msi.postprocessing_lead_time, 0))
         mp.sr_tp_id = msi.organization_id
    AND     mp.sr_instance_id = msi.sr_instance_id
    AND     mp.partner_type= 3
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND	    s.release_errors is NULL
    AND     s.po_line_id IS NOT NULL
    AND     s.organization_id = orgs.planned_organization
    AND     s.sr_instance_id = orgs.sr_instance_id
    AND     s.plan_id = orgs.plan_id
    AND     orgs.organization_id = arg_owning_org_id
    AND     orgs.owning_sr_instance = arg_owning_instance
    AND     orgs.plan_id = arg_plan_id
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_owning_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     orgs.sr_instance_id = arg_org_instance
    AND     s.sr_instance_id = mai.instance_id
    AND     ((arg_mode is null and s.load_type = PO_MASS_RESCHEDULE and s.load_type IS NOT NULL)
			 OR     (arg_mode is null
					 and s.load_type = DRP_REQ_RESCHED
					 and mai.APPS_VER <= MSC_UTIL.G_APPS120
					 and s.load_type IS NOT NULL))  -- IR/ISO resch Proj
    AND      s.last_updated_by = decode(v_msc_released_only_by_user,1,v_user_id,s.last_updated_by)
    and (s.releasable = RELEASABLE or s.releasable is null )
    and  (s.batch_id = g_batch_id or (v_batch_id_populated = 2 and s.batch_id is null) )
    UNION ALL
    SELECT NULL,
            s.implement_quantity,
           -- cal2.calendar_date,
	    s.implement_dock_date,
            s.po_line_id,
            SYSDATE,
            arg_user_id,
            SYSDATE,
            arg_user_id,
            s.disposition_id,
            s.order_number,
            s.transaction_id,
            nvl(s.implement_uom_code,msi.uom_code),
            s.sr_instance_id,
            g_batch_id
    FROM    --msc_calendar_dates cal1,
            --msc_calendar_dates cal2,
            msc_trading_partners mp,
            msc_system_items msi,
            msc_supplies s,
            msc_plan_organizations_v orgs
    WHERE   --cal1.sr_instance_id= mp.sr_instance_id
    --AND     cal1.calendar_code = mp.calendar_code
   -- AND     cal1.exception_set_id = mp.calendar_exception_set_id
   -- AND     cal1.calendar_date = trunc(s.implement_date)
   -- AND     cal2.sr_instance_id= cal1.sr_instance_id
    --AND     cal2.calendar_code = cal1.calendar_code
   -- AND     cal2.exception_set_id = cal1.exception_set_id
    --AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -      NVL(msi.postprocessing_lead_time, 0))
         mp.sr_tp_id = msi.organization_id
    AND     mp.sr_instance_id = msi.sr_instance_id
    AND     mp.partner_type= 3
    AND     msi.inventory_item_id = s.inventory_item_id
    AND     msi.plan_id = s.plan_id
    AND     msi.organization_id = s.organization_id
    AND     msi.sr_instance_id = s.sr_instance_id
    AND	    s.release_errors is NULL
    AND     s.po_line_id IS NOT NULL
    AND     s.organization_id = orgs.planned_organization
    AND     s.sr_instance_id = orgs.sr_instance_id
    AND     s.plan_id = orgs.plan_id
    AND     orgs.organization_id = arg_owning_org_id
    AND     orgs.owning_sr_instance = arg_owning_instance
    AND     orgs.plan_id = arg_plan_id
    AND     orgs.planned_organization = decode(arg_log_org_id,
                    arg_owning_org_id, orgs.planned_organization,
                    arg_log_org_id)
    AND     orgs.sr_instance_id = arg_org_instance
    AND     (arg_mode = 'WF' and s.transaction_id = arg_transaction_id)
    and (s.releasable = RELEASABLE or s.releasable is null )
    and  (s.batch_id = g_batch_id or (v_batch_id_populated = 2 and s.batch_id is null) );

    IF SQL%ROWCOUNT > 0  THEN
        lv_resched_reqs := SQL%ROWCOUNT;
    ELSE
        lv_resched_reqs := 0;
    END IF;

   IF arg_mode = 'WF' THEN
        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= arg_transaction_id;
   ELSE
        IF v_batch_id_populated = 1 THEN
            update msc_supplies
               set releasable = RELEASE_ATTEMPTED
             where batch_id = g_batch_id;
        ELSE
            update msc_supplies
               set releasable = RELEASE_ATTEMPTED
                   ,batch_id   = g_batch_id
             where plan_id = arg_plan_id
               and transaction_id in (select source_line_id from msc_po_reschedule_interface);
        END IF;
   END IF;

    RETURN lv_resched_reqs;

END reschedule_po;

FUNCTION reschedule_po_wf
( arg_dblink                    IN      VARCHAR2
, arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER
IS

    lv_return_code		number;
    lv_old_need_by_date		date;
    lv_new_need_by_date		date;
    lv_po_header_id		number;
    lv_po_line_id		number;
    lv_po_number			varchar2(60);

    lv_sql_stmt                 VARCHAR2(2000);
BEGIN

    -- ------------------------------------------------------------------------
    -- Perform PO reschedule : Workflow version
    -- ------------------------------------------------------------------------



      BEGIN

        SELECT  s.old_schedule_date,
                --cal2.calendar_date,
		s.implement_dock_date,
                s.disposition_id,         --purchase_order_id,
                s.po_line_id,
                s.order_number            --po_number
        INTO    lv_old_need_by_date,
                lv_new_need_by_date,
                lv_po_header_id,
                lv_po_line_id,
                lv_po_number
        FROM    --msc_calendar_dates cal1,
                --msc_calendar_dates cal2,
                msc_trading_partners mp,
                msc_system_items msi,
                msc_supplies s,
                msc_plan_organizations_v orgs
        WHERE   --cal1.sr_instance_id = mp.sr_instance_id
        --AND     cal1.calendar_code = mp.calendar_code
        --AND     cal1.exception_set_id = mp.calendar_exception_set_id
        --AND     cal1.calendar_date = trunc(NVL(s.implement_date,s.new_schedule_date))
       -- AND     cal2.sr_instance_id = cal1.sr_instance_id
        --AND     cal2.calendar_code = cal1.calendar_code
        --AND     cal2.exception_set_id = cal1.exception_set_id
       -- AND     cal2.seq_num = GREATEST(1,NVL(cal1.seq_num, cal1.prior_seq_num) -                  NVL(msi.postprocessing_lead_time, 0))
             mp.sr_tp_id = msi.organization_id
        AND     mp.sr_instance_id = msi.sr_instance_id
        AND     mp.partner_type= 3
        AND     msi.inventory_item_id = s.inventory_item_id
        AND     msi.plan_id = s.plan_id
        AND     msi.organization_id = s.organization_id
        AND     msi.sr_instance_id = s.sr_instance_id
        AND     s.release_errors is NULL
        AND     s.po_line_id IS NOT NULL
        AND     s.order_type = 1
        AND     s.organization_id = orgs.planned_organization
        AND     s.plan_id = orgs.plan_id
        AND     orgs.organization_id = arg_owning_org_id
        AND     orgs.owning_sr_instance = arg_owning_instance
        AND     orgs.plan_id = arg_plan_id
        AND     orgs.planned_organization = decode(arg_log_org_id,
                        arg_owning_org_id, orgs.planned_organization,
                        arg_log_org_id)
        AND     orgs.sr_instance_id = arg_org_instance
        AND     s.transaction_id = arg_transaction_id
        and (s.releasable = RELEASABLE or s.releasable is null )
        and  (s.batch_id = g_batch_id or (v_batch_id_populated = 2 and s.batch_id is null) );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END;


        lv_return_code:= 0;

      IF lv_po_line_id IS NOT NULL THEN

        lv_sql_stmt:=
           'BEGIN'
        ||'  IF po_reschedule_pkg.reschedule'||arg_dblink||'('
                                          ||'   :lv_old_need_by_date,'
                                          ||'   :lv_new_need_by_date,'
                                          ||'   :lv_po_header_id,'
                                          ||'   :lv_po_line_id,'
                                          ||'   :lv_po_number) THEN'
        ||'     :lv_return_code:= 1;'
        ||'  END IF;'
        ||' END;';

        EXECUTE IMMEDIATE lv_sql_stmt
                USING  IN lv_old_need_by_date,
                       IN lv_new_need_by_date,
                       IN lv_po_header_id,
                       IN lv_po_line_id,
                       IN lv_po_number,
                       OUT lv_return_code;
       END IF;

        update msc_supplies
           set releasable = RELEASE_ATTEMPTED
               ,batch_id   = nvl(batch_id,g_batch_id)
         where plan_id = arg_plan_id
           and transaction_id= arg_transaction_id;

       RETURN lv_return_code;

END reschedule_po_wf;

PROCEDURE SET_RP_TIMESTAMP_WIP ( p_group_id IN number)
IS
BEGIN
    -- First Update the header records;
  begin

     UPDATE MSC_WIP_JOB_SCHEDULE_INTERFACE
     SET
     first_unit_start_date =
                      trunc(first_unit_start_date) + v_rp_time,
     last_unit_completion_date =
                      trunc(last_unit_completion_date) + v_rp_time,
     requested_completion_date =
                      trunc(requested_completion_date) + v_rp_time
     WHERE group_id = p_group_id;
  exception
     when others
     then
       NULL;
  end;
   -- Then Update the details records
  begin
     UPDATE MSC_WIP_JOB_DTLS_INTERFACE
     SET
     start_date =
                      trunc(start_date) + v_rp_time,
     completion_date =
                      trunc(completion_date) + v_rp_time,
     first_unit_start_date =
                      trunc(first_unit_start_date) + v_rp_time,
     first_unit_completion_date =
                      trunc(first_unit_completion_date) + v_rp_time,
     last_unit_start_date =
                      trunc(last_unit_start_date) + v_rp_time,
     last_unit_completion_date =
                      trunc(last_unit_completion_date) + v_rp_time,
     date_required =
                      trunc(date_required) + v_rp_time
     WHERE group_id= p_group_id;
  exception
     when others
     then
       NULL;
  end;

END  SET_RP_TIMESTAMP_WIP;

PROCEDURE SET_RP_TIMESTAMP_PO (p_arg_batch_id IN number)
IS
BEGIN
    -- Update PO Interface tables
  begin
     UPDATE MSC_PO_REQUISITIONS_INTERFACE
     SET
     need_by_date = trunc(need_by_date) + v_rp_time
    WHERE batch_id = p_arg_batch_id;
  exception
     when others
     then
       NULL;
  end;
    -- Update PO_RESCHEDULE if there is any
  begin
     UPDATE MSC_PO_RESCHEDULE_INTERFACE
     SET
     need_by_date = trunc(need_by_date) + v_rp_time
    WHERE batch_id = g_batch_id;
  exception
     when others
     then
       NULL;
  end;
END SET_RP_TIMESTAMP_PO;

END MSC_REL_PLAN_PUB;

/

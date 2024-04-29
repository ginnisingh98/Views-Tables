--------------------------------------------------------
--  DDL for Package Body MSC_CL_CONT_COLL_FW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_CONT_COLL_FW" AS -- body
/* $Header: MSCCONTB.pls 120.1.12010000.3 2009/12/08 11:41:26 sbyerram ship $*/

        v_cont_coll_thresh           number;
        v_process_org_present       NUMBER := MSC_UTIL.SYS_NO;

        TSK_RM_ASSIGNMENT_SETS                   NUMBER := 1;
        TSK_RM_ATP_RULES                         NUMBER := 1;
        TSK_RM_BILL_OF_RESOURCES                 NUMBER := 1;
        TSK_RM_BIS_BUSINESS_PLANS                NUMBER := 1;
        TSK_RM_BIS_PERIODS                       NUMBER := 1;
        TSK_RM_BIS_PFMC_MEASURES                 NUMBER := 1;
        TSK_RM_BIS_TARGET_LEVELS                 NUMBER := 1;
        TSK_RM_BIS_TARGETS                       NUMBER := 1;
        TSK_RM_BOM_COMPONENTS                    NUMBER := 1;
        TSK_RM_BOMS                              NUMBER := 1;
        TSK_RM_BOR_REQUIREMENTS                  NUMBER := 1;
        TSK_RM_CAL_WEEK_START_DATES              NUMBER := 1;
        TSK_RM_CAL_YEAR_START_DATES              NUMBER := 1;
        TSK_RM_CALENDAR_DATES                    NUMBER := 1;
        TSK_RM_CALENDAR_SHIFTS                   NUMBER := 1;
        TSK_RM_CALENDAR_ASSIGNMENTS              NUMBER := 1;
        TSK_RM_CATEGORY_SETS                     NUMBER := 1;
        TSK_RM_CARRIER_SERVICES                  NUMBER := 1;
        TSK_RM_COMPONENT_SUBSTITUTES             NUMBER := 1;
        TSK_RM_DEMAND_CLASSES                    NUMBER := 1;
        TSK_RM_DEMANDS                           NUMBER := 3;
        TSK_RM_DEPARTMENT_RESOURCES              NUMBER := 1;
        TSK_RM_DESIGNATORS                       NUMBER := 1;
        TSK_RM_INTERORG_SHIP_METHODS             NUMBER := 1;
        TSK_RM_ITEM_CATEGORIES                   NUMBER := 1;
        TSK_RM_ITEM_SUBSTITUTES                  NUMBER := 1;
        TSK_RM_ITEM_SUPPLIERS                    NUMBER := 1;
        TSK_RM_LOCATION_ASSOCIATIONS             NUMBER := 1;
        TSK_RM_SOURCING_RULES                    NUMBER := 1;
        TSK_RM_OPERATION_COMPONENTS              NUMBER := 1;
        TSK_RM_OPERATION_RESOURCE_SEQS           NUMBER := 1;
        TSK_RM_OPERATION_RESOURCES               NUMBER := 1;
        TSK_RM_PARAMETERS                        NUMBER := 1;
        TSK_RM_PARTNER_CONTACTS                  NUMBER := 2;
        TSK_RM_PERIOD_START_DATES                NUMBER := 1;
        TSK_RM_PLANNERS                          NUMBER := 1;
        TSK_RM_PROCESS_EFFECTIVITY               NUMBER := 1;
        TSK_RM_PROJECT_TASKS                     NUMBER := 1;
        TSK_RM_PROJECTS                          NUMBER := 1;
        TSK_RM_REGIONS                           NUMBER := 1;
        TSK_RM_REGION_SITES                      NUMBER := 1;
        TSK_RM_RESERVATIONS                      NUMBER := 1;
        TSK_RM_RESOURCE_CHANGES                  NUMBER := 1;
        TSK_RM_RESOURCE_GROUPS                   NUMBER := 1;
        TSK_RM_RESOURCE_REQUIREMENTS             NUMBER := 1;
        TSK_RM_RESOURCE_SHIFTS                   NUMBER := 1;
        TSK_RM_ROUTING_OPERATIONS                NUMBER := 1;
        TSK_RM_ROUTINGS                          NUMBER := 1;
        TSK_RM_SAFETY_STOCKS                     NUMBER := 1;
        TSK_RM_SALES_ORDERS                      NUMBER := 1;
        TSK_RM_JOB_OP_NETWORKS                   NUMBER := 1;
        TSK_RM_JOB_OPERATIONS                    NUMBER := 1;
        TSK_RM_JOB_REQUIREMENT_OPS               NUMBER := 1;
        TSK_RM_JOB_OP_RESOURCES                  NUMBER := 1;
        TSK_RM_SHIFT_DATES                       NUMBER := 1;
        TSK_RM_SHIFT_EXCEPTIONS                  NUMBER := 1;
        TSK_RM_SHIFT_TIMES                       NUMBER := 1;
        TSK_RM_SIMULATION_SETS                   NUMBER := 1;
        TSK_RM_SR_ASSIGNMENTS                    NUMBER := 1;
        TSK_RM_SR_RECEIPT_ORG                    NUMBER := 1;
        TSK_RM_SR_SOURCE_ORG                     NUMBER := 1;
        TSK_RM_SUB_INVENTORIES                   NUMBER := 1;
        TSK_RM_SUPPLIER_CAPACITIES               NUMBER := 1;
        TSK_RM_SUPPLIER_FLEX_FENCES              NUMBER := 1;
        TSK_RM_SUPPLIES                          NUMBER := 7; -- 5 changed to 7 .
        TSK_RM_SYSTEM_ITEMS                      NUMBER := 3;
        TSK_RM_TRADING_PARTNER_SITES             NUMBER := 1;
        TSK_RM_TRADING_PARTNERS                  NUMBER := 1;
        TSK_RM_TRIPS                             NUMBER := 1;
        TSK_RM_TRIP_STOPS                        NUMBER := 1;
        TSK_RM_UNIT_NUMBERS                      NUMBER := 1;
        TSK_RM_UNITS_OF_MEASURE                  NUMBER := 1;
        TSK_RM_UOM_CLASS_CONVERSIONS             NUMBER := 1;
        TSK_RM_UOM_CONVERSIONS                   NUMBER := 1;
        TSK_RM_ZONE_REGIONS                      NUMBER := 1;
        /* ds change start */
        TSK_RM_RESOURCE_SETUP                    NUMBER := 1;
        TSK_RM_RESOURCE_INSTANCE                 NUMBER := 1;
        /* ds change end */
        TSK_RM_ABC_CLASSES                       NUMBER := 1;
        TSK_RM_SALES_CHANNEL                     NUMBER := 1;
        TSK_RM_FISCAL_CALENDAR                   NUMBER := 1;
        TSK_RM_INTERNAL_REPAIR                   NUMBER := 1;
        TSK_RM_EXTERNAL_REPAIR                   NUMBER := 1;

        lv_is_item_refresh_type_target           NUMBER := MSC_UTIL.SYS_NO;


PROCEDURE check_entity_cont_ref_type(p_entity_name   in  varchar2,
                                     p_entity_lrn    in  number,
                                     entity_flag     OUT NOCOPY  number,
                                     p_org_str       in  varchar2,
                                     p_coll_thresh   in  number,
                                     p_last_tgt_cont_coll_time  in  date)
IS
v_sql_stmt  Varchar2(2000);
lv_status   number := MSC_UTIL.G_SUCCESS;
lv_msg      varchar2(500);
lv_last_coll_time  date;
BEGIN

  IF ( lv_is_item_refresh_type_target = MSC_UTIL.SYS_YES AND
        p_entity_name <> 'FCST' AND p_entity_name <> 'WSH') THEN
      entity_flag := MSC_UTIL.SYS_TGT;
      RETURN;
  END IF;

  IF p_last_tgt_cont_coll_time IS NULL THEN
    lv_last_coll_time := sysdate;
  ELSE
    lv_last_coll_time := p_last_tgt_cont_coll_time;
  END IF;

   v_sql_stmt:=
     'BEGIN MRP_CL_REFRESH_SNAPSHOT.CHECK_ENTITY_CONT_REF_TYPE'||MSC_CL_PULL.v_dblink||'('
   ||'      p_entity_name =>       :p_entity_name,'
   ||'      p_entity_lrn =>        :p_entity_lrn,'
   ||'      entity_flag =>         :entity_flag,'
   ||'      p_org_str =>           :p_org_str,'
   ||'      p_coll_thresh =>       :p_coll_thresh,'
   ||'      p_last_tgt_cont_coll_time =>      :lv_last_coll_time,'
   ||'      p_ret_code =>           :p_ret_code,'
   ||'      p_err_buf =>       :p_err_buf
    );'
   ||'END;';
   /*||'      p_application_id=>       :lv_application_id );' */

   EXECUTE IMMEDIATE v_sql_stmt
           USING IN p_entity_name,
                 IN p_entity_lrn,
                 OUT  entity_flag,
                 IN  p_org_str,
                 IN  p_coll_thresh,
                 IN  lv_last_coll_time,
                 OUT lv_status,
                 OUT lv_msg;

    IF lv_status <> MSC_UTIL.G_SUCCESS THEN
      --entity_flag := MSC_UTIL.SYS_TGT;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error while deciding the collection type for Entity ' || p_entity_name);
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Assumed incremental collection for following MVs');
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, lv_msg);

    END IF;
    lv_status :=MSC_UTIL.G_SUCCESS;
    lv_msg := '';
END;

FUNCTION get_refresh_type     (p_param1      in number:=0,
                               p_param2      in number:=0,
                               p_param3      in number:=0,
                               p_coll_thresh in number)
RETURN number
IS

   lv_refresh_type number;


BEGIN

   IF ( p_param3 <> 0 ) THEN

     if ( (p_param1 + p_param2) <> 0 ) THEN

      if (( (p_param1 + p_param2) /p_param3)*100 <= p_coll_thresh) then
         lv_refresh_type := MSC_UTIL.SYS_INCR;  -- do incremental refresh
      else
         lv_refresh_type := MSC_UTIL.SYS_TGT;  -- do targeted refresh
      end if;

     else
       lv_refresh_type := MSC_UTIL.SYS_NO;
     end if;

   ELSE
      if ( p_param1 <> 0 ) THEN
     		lv_refresh_type := MSC_UTIL.SYS_TGT;
    	else
      	lv_refresh_type := MSC_UTIL.SYS_NO;
     	end if ;
   END IF;


   RETURN lv_refresh_type;

EXCEPTION
  when others then
     lv_refresh_type := MSC_UTIL.SYS_NO;
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
     RETURN lv_refresh_type;

END get_refresh_type;


-- Entry point for continuous collections


PROCEDURE init_entity_refresh_type(p_coll_thresh              in  number,
                                   p_coll_freq                in  number,
                                   p_last_tgt_cont_coll_time  in  date,
                                   p_dblink                   in  varchar2,
                                   p_instance_id              in  number,
                                   prec                       in  MSC_UTIL.CollParamREC,
				   p_org_group                in varchar2,
                                   p_bom_sn_flag              out NOCOPY number,
                                   p_bor_sn_flag              out NOCOPY number,
                                   p_item_sn_flag             out NOCOPY number,
                                   p_oh_sn_flag               out NOCOPY number,
                                   p_usup_sn_flag             out NOCOPY number,
                                   p_udmd_sn_flag             out NOCOPY number,
                                   p_so_sn_flag               out NOCOPY number,
                                   p_fcst_sn_flag             out NOCOPY number,
                                   p_wip_sn_flag              out NOCOPY number,
                                   p_supcap_sn_flag           out NOCOPY number,
                                   p_po_sn_flag               out NOCOPY number,
                                   p_mds_sn_flag              out NOCOPY number,
                                   p_mps_sn_flag              out NOCOPY number,
                                   p_nosnap_flag              out NOCOPY number,
                                   p_suprep_sn_flag           in out NOCOPY number,
                                   p_trip_sn_flag             out NOCOPY number)
is

     lv_sup_cap_lrn number;
     lv_bom_lrn number;
     lv_bor_lrn number;
     lv_forecast_lrn number;
     lv_item_lrn number;
     lv_mds_lrn number;
     lv_mps_lrn number;
     lv_oh_lrn number;
     lv_rsv_lrn number;
     lv_po_lrn number;
     lv_so_lrn number;
     lv_usd_lrn number;
     lv_wip_lrn number;
     lv_nra_lrn number;
     lv_saf_stock_lrn number;
     lv_unit_no_lrn number;
     lv_uom_lrn number;
     lv_calendar_lrn number;
     lv_apps_lrn number;
     lv_trip_lrn number;

     lv_param1 number;
     lv_param2 number;
     lv_param3 number;
     lv_param4 number;
     lv_param5 number;
     lv_param6 number;
     lv_param7 number;
     lv_param8 number;
     lv_param9 number;

     lv_bom1 number     := MSC_UTIL.SYS_NO;
     lv_bom2 number     := MSC_UTIL.SYS_NO;
     lv_bom3 number     := MSC_UTIL.SYS_NO;
     lv_bom4 number     := MSC_UTIL.SYS_NO;
     lv_bom5 number     := MSC_UTIL.SYS_NO;
     lv_bom6 number     := MSC_UTIL.SYS_NO;
     lv_bom7 number     := MSC_UTIL.SYS_NO;
     lv_bom8 number     := MSC_UTIL.SYS_NO;
     lv_bom9 number     := MSC_UTIL.SYS_NO;
     lv_bom10 number    := MSC_UTIL.SYS_NO;
     lv_bom11 number    := MSC_UTIL.SYS_NO;
     lv_bom12 number    := MSC_UTIL.SYS_NO;

     lv_bor1 number     := MSC_UTIL.SYS_NO;

     lv_item1 number    := MSC_UTIL.SYS_NO;
     lv_item2 number    := MSC_UTIL.SYS_NO;

     lv_oh1 number      := MSC_UTIL.SYS_NO;

     lv_usup1 number    := MSC_UTIL.SYS_NO;
     lv_udmd1 number    := MSC_UTIL.SYS_NO;

     lv_so1 number      := MSC_UTIL.SYS_NO;

     lv_fcst1 number    := MSC_UTIL.SYS_NO;
     lv_fcst2 number    := MSC_UTIL.SYS_NO;

     lv_wip1 number     := MSC_UTIL.SYS_NO;
     lv_wip2 number     := MSC_UTIL.SYS_NO;
     lv_wip3 number     := MSC_UTIL.SYS_NO;

     lv_supcap1 number  := MSC_UTIL.SYS_NO;

     lv_po1 number      := MSC_UTIL.SYS_NO;

     lv_mds1 number     := MSC_UTIL.SYS_NO;

     lv_mps1 number     := MSC_UTIL.SYS_NO;

     lv_trip1 number     := MSC_UTIL.SYS_NO;
     lv_trip2 number     := MSC_UTIL.SYS_NO;

     lv_in_org_str             VARCHAR2(10240):='NULL';

     lv_sql_stmt               VARCHAR2(15000);

     lv_sn_flag            number;

     lv_status_decided_bom		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_bor		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_item		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_oh		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_usup		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_udem		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_so		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_fcst		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_wip		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_app_supp_cap	NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_po		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_mds		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_mps		NUMBER := MSC_UTIL.SYS_NO;
     lv_status_decided_trip		NUMBER := MSC_UTIL.SYS_NO;

     lv_cond_str_enabled_flag  VARCHAR2(64);
     lv_cond_str_org_grp       VARCHAR2(100);
     lv_application_name       VARCHAR2(240):= NULL;
     lv_application_id	       NUMBER;


  begin

   IF (msc_cl_pull.v_is_cont_refresh = MSC_UTIL.SYS_YES) THEN

				IF (MSC_CL_PULL.v_instance_type = MSC_UTIL.G_INS_MIXED) THEN

				   SELECT FND_GLOBAL.APPLICATION_NAME
					 INTO   lv_application_name
					 FROM   dual;

				   SELECT APPLICATION_ID
				   INTO   lv_application_id
				   FROM   FND_APPLICATION_VL
				   WHERE  APPLICATION_NAME = lv_application_name;

				   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'app id - ' || lv_application_id);
				   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'app name- ' || lv_application_name);

				   IF lv_application_id = 722 THEN
							lv_cond_str_enabled_flag:=' nvl(mio.dp_enabled_flag,1) = 1 ';
				   ELSE
							lv_cond_str_enabled_flag:=' mio.enabled_flag= 1 ';
				   END IF;

				   IF p_org_group = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
							lv_cond_str_org_grp := ' ';
				   ELSE
							lv_cond_str_org_grp := ' AND mio.org_group= ''' || p_org_group ||''' ';
				   END IF;

				   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' --Discrete and Process Instance--');
				    BEGIN
						lv_sql_stmt:=' SELECT 1 '
							||' FROM mtl_parameters'||p_dblink||' mp,'
							||'      msc_instance_orgs mio'
							||' WHERE mio.sr_instance_id= :p_instance_id'
							||' AND ' || lv_cond_str_enabled_flag
							||' AND mio.organization_id=mp.organization_id'
							||' AND mp.process_enabled_flag='||'''Y'''
							||  lv_cond_str_org_grp
							||' AND ROWNUM <2 ';

				   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_sql_stmt );

					EXECUTE IMMEDIATE lv_sql_stmt
						INTO      v_process_org_present
						USING     p_instance_id;

					EXCEPTION
					         WHEN NO_DATA_FOUND THEN
					            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' No Data Found');
						    			v_process_org_present := MSC_UTIL.SYS_NO;
					         WHEN OTHERS THEN
					            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
					            RETURN;
			            END;
				END IF;
     END IF;
		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' v_process_org_present: ' || v_process_org_present);
   IF (v_process_org_present = MSC_UTIL.SYS_YES) THEN

				IF prec.bom_flag = MSC_UTIL.SYS_YES THEN
					lv_bom1 := MSC_UTIL.SYS_TGT;
					lv_bom9 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.bor_flag = MSC_UTIL.SYS_YES THEN
					lv_bor1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.item_flag = MSC_UTIL.SYS_YES THEN
					lv_item1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.oh_flag = MSC_UTIL.SYS_YES THEN
					lv_oh1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES THEN
					lv_usup1 := MSC_UTIL.SYS_TGT;
					lv_udmd1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF (prec.sales_order_flag =MSC_UTIL.SYS_YES) THEN
					lv_so1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.forecast_flag = MSC_UTIL.SYS_YES THEN
					lv_fcst1 := MSC_UTIL.SYS_TGT;
					lv_fcst2 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.wip_flag = MSC_UTIL.SYS_YES THEN
					lv_wip1 := MSC_UTIL.SYS_TGT;
					lv_bom9 := MSC_UTIL.SYS_TGT;
					lv_bom10 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.app_supp_cap_flag = MSC_UTIL.ASL_YES  or prec.app_supp_cap_flag =MSC_UTIL.ASL_YES_RETAIN_CP THEN
					lv_supcap1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.po_flag = MSC_UTIL.SYS_YES THEN
					lv_po1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF  prec.mds_flag = MSC_UTIL.SYS_YES THEN
					lv_mds1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.mps_flag = MSC_UTIL.SYS_YES THEN
					lv_mps1 := MSC_UTIL.SYS_TGT;
				END IF;

				IF prec.trip_flag = MSC_UTIL.SYS_YES THEN
					lv_trip1 := MSC_UTIL.SYS_TGT;
				END IF;
    ELSIF MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS121 THEN

      lv_in_org_str:= MSC_CL_PULL.GET_ORG_STR(p_instance_id,2);

      select apps_lrn
      into lv_apps_lrn
      from msc_apps_instances
      where instance_id = p_instance_id;

      select min(nvl(supplier_capacity_lrn,lv_apps_lrn)),
             min(nvl(bom_lrn,lv_apps_lrn)),
             min(nvl(bor_lrn,lv_apps_lrn)),
             min(nvl(forecast_lrn,lv_apps_lrn)),
             min(nvl(item_lrn,lv_apps_lrn)),
             min(nvl(mds_lrn,lv_apps_lrn)),
             min(nvl(mps_lrn,lv_apps_lrn)),
             min(nvl(oh_lrn,lv_apps_lrn)),
             min(nvl(reservations_lrn,lv_apps_lrn)),
             min(nvl(po_lrn,lv_apps_lrn)),
             min(nvl(so_lrn,lv_apps_lrn)),
             min(nvl(user_supply_demand_lrn,lv_apps_lrn)),
             min(nvl(wip_lrn,lv_apps_lrn)),
             min(nvl(nra_lrn,lv_apps_lrn)),
             min(nvl(saf_stock_lrn,lv_apps_lrn)),
             min(nvl(unit_no_lrn,lv_apps_lrn)),
             min(nvl(uom_lrn,lv_apps_lrn)),
             min(nvl(calendar_lrn,lv_apps_lrn)),
             min(nvl(trip_lrn,lv_apps_lrn))
      into
             lv_sup_cap_lrn,
             lv_bom_lrn,
             lv_bor_lrn,
             lv_forecast_lrn,
             lv_item_lrn,
             lv_mds_lrn,
             lv_mps_lrn,
             lv_oh_lrn,
             lv_rsv_lrn,
             lv_po_lrn,
             lv_so_lrn,
             lv_usd_lrn,
             lv_wip_lrn,
             lv_nra_lrn,
             lv_saf_stock_lrn,
             lv_unit_no_lrn,
             lv_uom_lrn,
             lv_calendar_lrn,
             lv_trip_lrn
       from   msc_instance_orgs
       WHERE ((p_org_group =MSC_UTIL.G_ALL_ORGANIZATIONS) or (org_group=p_org_group))
       AND   sr_instance_id = p_instance_id;



        /*Check for each entity*/

       -- p_item_sn_flag
        IF prec.item_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('ITEM', lv_item_lrn, p_item_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          IF p_item_sn_flag = MSC_UTIL.SYS_TGT THEN
            lv_is_item_refresh_type_target := MSC_UTIL.SYS_YES;
          END IF;
        END IF;

             --  p_bom_sn_flag
        IF prec.bom_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('BOM', lv_bom_lrn, p_bom_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
        END IF;

       -- p_bor_sn_flag
          IF prec.bor_flag = MSC_UTIL.SYS_YES THEN
              check_entity_cont_ref_type('ITEM', lv_bor_lrn, p_bor_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          END IF;

        --p_oh_sn_flag
        IF prec.oh_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('OH', lv_oh_lrn, p_oh_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
        END IF;


       --p_usup_sn_flag
        IF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('USUD', lv_usd_lrn, p_usup_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
        END IF;

        --p_so_sn_flag
        IF (prec.sales_order_flag =MSC_UTIL.SYS_YES) THEN
          check_entity_cont_ref_type('ONT', lv_so_lrn, p_so_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          IF p_so_sn_flag <> MSC_UTIL.SYS_TGT THEN
           check_entity_cont_ref_type('RES', lv_so_lrn, lv_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
           IF lv_sn_flag = MSC_UTIL.SYS_TGT THEN
            p_so_sn_flag := lv_sn_flag;
           END IF;
          END IF;
        END IF;

       -- p_wip_sn_flag
       IF prec.wip_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('WIP', lv_wip_lrn, p_wip_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          IF p_so_sn_flag <> MSC_UTIL.SYS_TGT THEN
           check_entity_cont_ref_type('EAM', lv_wip_lrn, lv_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
           IF lv_sn_flag = MSC_UTIL.SYS_TGT THEN
            p_wip_sn_flag := lv_sn_flag;
           END IF;
          END IF;

        END IF; -- wip_flag

        --p_supcap_sn_flag
         IF prec.app_supp_cap_flag = MSC_UTIL.SYS_YES or prec.app_supp_cap_flag =MSC_UTIL.ASL_YES_RETAIN_CP THEN
          --check_entity_cont_ref_type('SCAP', lv_sup_cap_lrn, p_supcap_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          --Using the old logic
            lv_status_decided_app_supp_cap := MSC_UTIL.SYS_NO;

           --lv_supcap1
            IF lv_status_decided_app_supp_cap = MSC_UTIL.SYS_NO THEN
               lv_sql_stmt:= 'select count(*)  from MRP_AD_SUPPLIER_CAPACITIES_V'||p_dblink
                           ||'  where RN > :lv_sup_cap_lrn '
                           ||'  and organization_id '|| lv_in_org_str;


                      EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_sup_cap_lrn;

               lv_sql_stmt:= 'select count(*)  '
                           ||' from MRP_AP_SUPPLIER_CAPACITIES_V'||p_dblink||'  x '
                           ||' where (    x.RN1 > :lv_sup_cap_lrn '
                           ||'        OR x.RN2 > :lv_sup_cap_lrn ) '
                           ||' and x.organization_id '|| lv_in_org_str;


                      EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_sup_cap_lrn,
                                                           lv_sup_cap_lrn;


               lv_sql_stmt:= 'select count(*)  from MRP_AP_SUPPLIER_CAPACITIES_V'||p_dblink
                           ||' where organization_id '|| lv_in_org_str;

                      EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

              lv_supcap1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
           ELSE
              lv_supcap1 := MSC_UTIL.SYS_TGT;
           END IF;
           p_supcap_sn_flag := lv_supcap1;
     END IF;

       --p_po_sn_flag
      IF prec.po_flag = MSC_UTIL.SYS_YES THEN
          --check_entity_cont_ref_type('PO', lv_po_lrn, p_po_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          --Using the old logic
                     lv_status_decided_po := MSC_UTIL.SYS_NO;
                 --lv_po1
              IF lv_status_decided_po = MSC_UTIL.SYS_NO THEN
                    lv_sql_stmt:= 'select count(*)  from MRP_AD_PO_SUPPLIES_V'||p_dblink
                            ||' where RN > :lv_po_lrn'
                            ||' and organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_po_lrn;


                   lv_sql_stmt:= 'select count(*)  '
                            ||' from MRP_AP_PO_PO_SUPPLY_V'||p_dblink||' x '
                            ||' where (    x.RN2 > :lv_po_lrn '
                            ||'        OR x.RN3 > :lv_po_lrn ) '
                            ||' and x.organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_po_lrn,
                                                            lv_po_lrn;

                   lv_sql_stmt:= 'select count(*)  '
                            ||' from  MRP_AP_PO_SHIP_SUPPLY_V'||p_dblink||'  x '
                            ||' where (    x.RN2 > :lv_po_lrn '
                            ||'        OR x.RN3 > :lv_po_lrn )'
                            ||' and x.organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING  lv_po_lrn,
                                                            lv_po_lrn;

                   lv_sql_stmt:= 'select count(*) '
                            ||' from  MRP_AP_PO_REQ_SUPPLY_V'||p_dblink||' x '
                            ||' where (    x.RN2 > :lv_po_lrn '
                            ||'        OR x.RN3 > :lv_po_lrn )'
                            ||' and x.organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING  lv_po_lrn,
                                                            lv_po_lrn;

                    lv_sql_stmt:= 'select count(*) '
                            ||' from  MRP_AP_PO_SHIP_RCV_SUPPLY_V'||p_dblink||'  x '
                            ||' where (    x.RN2 > :lv_po_lrn  '
                            ||'        OR x.RN3 > :lv_po_lrn ) '
                            ||' and x.organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING  lv_po_lrn,
                                                            lv_po_lrn;

                      lv_sql_stmt:= 'select count(*) '
                            ||' from   MRP_AP_PO_RCV_SUPPLY_V'||p_dblink||'  x '
                            ||' where (    x.RN2 > :lv_po_lrn  '
                            ||'        OR x.RN3 > :lv_po_lrn ) '
                            ||' and x.organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param6 USING  lv_po_lrn,
                                                            lv_po_lrn;


                       lv_sql_stmt:= 'select count(*)  '
                            ||' from  MRP_AP_INTRANSIT_SUPPLIES_V'||p_dblink||'  x '
                            ||' where   x.RN2 > :lv_po_lrn '
                            ||' and x.organization_id '|| lv_in_org_str;


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param7 USING  lv_po_lrn;

                       lv_param2:=lv_param2 + lv_param3 + lv_param4 + lv_param5 + lv_param6 + lv_param7;

                       lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_PO_SUPPLY_V'||p_dblink
                            ||' where organization_id '|| lv_in_org_str;

                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

                       lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_SHIP_SUPPLY_V'||p_dblink
                            ||' where organization_id  '|| lv_in_org_str;

                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param4;

                       lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_REQ_SUPPLY_V'||p_dblink
                            ||' where organization_id '|| lv_in_org_str;

                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param5;

                       lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_SHIP_RCV_SUPPLY_V'||p_dblink
                            ||' where organization_id '|| lv_in_org_str;

                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param6;

                       lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_RCV_SUPPLY_V'||p_dblink
                            ||' where organization_id '|| lv_in_org_str;

                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param7;

                       lv_sql_stmt:= 'select count(*)  from MRP_AP_INTRANSIT_SUPPLIES_V'||p_dblink
                            ||' where organization_id '|| lv_in_org_str;

                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param8;

                        lv_param3:=lv_param3 + lv_param4 + lv_param5 + lv_param6 + lv_param7 + lv_param8;

                        lv_po1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
               ELSE
                  lv_po1 := MSC_UTIL.SYS_TGT;
               END IF;
            p_po_sn_flag     := lv_po1;
        END IF;

       --p_mds_sn_flag
        IF  prec.mds_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('MRP', lv_mds_lrn, p_mds_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
        END IF;

        --p_fcst_sn_flag **
        IF prec.forecast_flag = MSC_UTIL.SYS_YES THEN
          check_entity_cont_ref_type('FCST', lv_forecast_lrn, p_oh_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
       END IF;

        --p_trip_sn_flag**
        IF prec.trip_flag = MSC_UTIL.SYS_YES THEN
          --check_entity_cont_ref_type('WSH', lv_trip_lrn, p_trip_sn_flag, lv_in_org_str, p_coll_thresh, p_last_tgt_cont_coll_time);
          --Using the old logic
                       lv_status_decided_trip := MSC_UTIL.SYS_NO;
                --lv_trip1
                IF lv_status_decided_trip = MSC_UTIL.SYS_NO THEN
                     lv_sql_stmt:= 'select count(*)  from MRP_AD_TRIPS_V'||p_dblink
                            ||' where RN > :lv_trip_lrn ';


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_trip_lrn;

                    lv_sql_stmt:= 'select count(*)  '
                                ||' from MRP_AP_TRIPS_V'||p_dblink||'  x '
                                ||' where     x.RN > :lv_trip_lrn  ';


                           EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_trip_lrn;


                    lv_sql_stmt:= 'select count(*)  from MRP_AP_TRIPS_V'||p_dblink;


                           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

                  lv_trip1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
                  IF lv_trip1 = MSC_UTIL.SYS_TGT THEN
                     lv_status_decided_trip := MSC_UTIL.SYS_YES;
                  END IF;

                ELSE
                   lv_trip1 := MSC_UTIL.SYS_TGT;
                END IF;

                IF lv_status_decided_trip = MSC_UTIL.SYS_NO THEN
              --lv_trip2
                     lv_sql_stmt:= 'select count(*)  from MRP_AD_TRIP_STOPS_V'||p_dblink
                            ||' where RN > :lv_trip_lrn ';


                       EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_trip_lrn;

                    lv_sql_stmt:= 'select count(*)  '
                                ||' from MRP_AP_TRIP_STOPS_V'||p_dblink||'  x '
                                ||' where     x.RN > :lv_trip_lrn  ';


                           EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_trip_lrn;


                    lv_sql_stmt:= 'select count(*)  from MRP_AP_TRIP_STOPS_V'||p_dblink;


                           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

                  lv_trip2 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
                END IF;
             if ((lv_trip1    = MSC_UTIL.SYS_TGT) or
                  (lv_trip2    = MSC_UTIL.SYS_TGT)) then
                p_trip_sn_flag := MSC_UTIL.SYS_TGT;
             elsif ((lv_trip1       = MSC_UTIL.SYS_NO) and
                    (lv_trip2       = MSC_UTIL.SYS_NO)) then
                  p_trip_sn_flag := MSC_UTIL.SYS_NO;
              else
                  p_trip_sn_flag := MSC_UTIL.SYS_INCR;
              end if;
       END IF ;
    ELSE --For backward compatbility IF version <121
  ------ set lv_in_org_str ----------
   lv_in_org_str:= MSC_CL_PULL.GET_ORG_STR(p_instance_id,2);

      select apps_lrn
      into lv_apps_lrn
      from msc_apps_instances
      where instance_id = p_instance_id;

      select min(nvl(supplier_capacity_lrn,lv_apps_lrn)),
             min(nvl(bom_lrn,lv_apps_lrn)),
             min(nvl(bor_lrn,lv_apps_lrn)),
             min(nvl(forecast_lrn,lv_apps_lrn)),
             min(nvl(item_lrn,lv_apps_lrn)),
             min(nvl(mds_lrn,lv_apps_lrn)),
             min(nvl(mps_lrn,lv_apps_lrn)),
             min(nvl(oh_lrn,lv_apps_lrn)),
             min(nvl(reservations_lrn,lv_apps_lrn)),
             min(nvl(po_lrn,lv_apps_lrn)),
             min(nvl(so_lrn,lv_apps_lrn)),
             min(nvl(user_supply_demand_lrn,lv_apps_lrn)),
             min(nvl(wip_lrn,lv_apps_lrn)),
             min(nvl(nra_lrn,lv_apps_lrn)),
             min(nvl(saf_stock_lrn,lv_apps_lrn)),
             min(nvl(unit_no_lrn,lv_apps_lrn)),
             min(nvl(uom_lrn,lv_apps_lrn)),
             min(nvl(calendar_lrn,lv_apps_lrn)),
             min(nvl(trip_lrn,lv_apps_lrn))
      into
             lv_sup_cap_lrn,
             lv_bom_lrn,
             lv_bor_lrn,
             lv_forecast_lrn,
             lv_item_lrn,
             lv_mds_lrn,
             lv_mps_lrn,
             lv_oh_lrn,
             lv_rsv_lrn,
             lv_po_lrn,
             lv_so_lrn,
             lv_usd_lrn,
             lv_wip_lrn,
             lv_nra_lrn,
             lv_saf_stock_lrn,
             lv_unit_no_lrn,
             lv_uom_lrn,
             lv_calendar_lrn,
             lv_trip_lrn
       from   msc_instance_orgs
       WHERE ((p_org_group =MSC_UTIL.G_ALL_ORGANIZATIONS) or (org_group=p_org_group))
       AND   sr_instance_id = p_instance_id;

--  p_bom_sn_flag

  IF prec.bom_flag = MSC_UTIL.SYS_YES THEN

     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_bom
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
	   	             enabled_flag = 'Y' AND
	   	             view_application_id = 700 AND
	   	             language = userenv('lang') AND
	   	             attribute2 in
	   	                  ('BOM_BOMS_SN', 'BOM_INV_COMPS_SN', 'BOM_OPR_NETWORKS_SN',
	   	                   'BOM_OPR_RESS_SN', 'BOM_OPR_RTNS_SN', 'BOM_OPR_SEQS_SN',
                                   'BOM_RES_CHNGS_SN', 'BOM_RES_INST_CHNGS_SN', 'BOM_SUB_COMPS_SN',
                                   'BOM_SUB_OPR_RESS_SN', 'MTL_SYS_ITEMS_SN') AND
                             attribute13 = 'COMPLETE' AND
                             rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_bom := MSC_UTIL.SYS_NO;
     END;

     --lv_bom1
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= '  select count(*) from MRP_AD_BOM_COMPONENTS_V'||p_dblink
                   ||'  where RN > :lv_bom_lrn '
                   ||'  and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= '  select count(*)  '
                   ||'  from MRP_AP_BOM_COMPONENTS_V'||p_dblink||'  x '
                   ||'  where (    x.RN1 > :lv_bom_lrn '
                   ||'        OR x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn '
                   ||'        OR x.RN4 > :lv_bom_lrn )'
                   ||'  and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                                  lv_bom_lrn,
                                                                  lv_bom_lrn,
                                                                  lv_bom_lrn;


       lv_sql_stmt:= ' select count(*) from MRP_AP_BOM_COMPONENTS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;

      lv_bom1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);

      IF lv_bom1 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   ELSE
      lv_bom1 := MSC_UTIL.SYS_TGT;
   END IF;


 --lv_bom2
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*) from MRP_AD_BOMS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn'
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_BOMS_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_bom_lrn '
                   ||'        OR x.RN2 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                                  lv_bom_lrn;

       lv_sql_stmt:= 'select count(*) from MRP_AP_BOMS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;


      lv_bom2 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom2 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

--lv_bom3
   IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*) from MRP_AD_SUB_COMPS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn'
                   ||' and organization_id '|| lv_in_org_str;

        EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= ' select count(*)  '
                   ||' from MRP_AP_COMPONENT_SUBSTITUTES_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_bom_lrn '
                   ||'        OR x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn '
                   ||'        OR x.RN4 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                                  lv_bom_lrn,
                                                                  lv_bom_lrn,
                                                                  lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  from MRP_AP_COMPONENT_SUBSTITUTES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;


      lv_bom3 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom3 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

 --lv_bom4
   IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*) from MRP_AD_ROUTINGS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_ROUTINGS_V'||p_dblink||' x '
                   ||' where (    x.RN1 > :lv_bom_lrn '
                   ||'        OR x.RN2 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                                  lv_bom_lrn;

       lv_sql_stmt:= 'select count(*) from MRP_AP_ROUTINGS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;

      lv_bom4 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom4 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

  --lv_bom5
/* IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
      lv_sql_stmt:= 'select count(*) from MRP_AD_OPER_NETWORKS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn ;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_OPER_NETWORKS_V'||p_dblink||' x '
                   ||' where (    x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn  '
                   ||'        OR x.RN4 > :lv_bom_lrn '
                   ||'        OR x.RN5 > :lv_bom_lrn '
                   ||'        OR x.RN6 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                   		lv_bom_lrn,
                                                   		lv_bom_lrn,
                                                   		lv_bom_lrn,
                                                   		lv_bom_lrn;

       lv_sql_stmt:= ' select count(*) from MRP_AP_BOM_COMPONENTS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;


      lv_bom5 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom5 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

 */
  --lv_bom6
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*) from MRP_AD_ROUTING_OPERATIONS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||'  from MRP_AP_ROUTING_OPERATIONS_V'||p_dblink||' x '
                   ||'  where (    x.RN1 > :lv_bom_lrn '
                   ||'        OR x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn ) '
                   ||'  and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                   		lv_bom_lrn,
                                                   		lv_bom_lrn;


       lv_sql_stmt:= 'select count(*) from MRP_AP_ROUTING_OPERATIONS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;


      lv_bom6 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom6 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

  --lv_bom7
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*)  from MRP_AD_OP_RESOURCE_SEQS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_OP_RESOURCE_SEQS_V'||p_dblink||'  x '
                   ||' where (    x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn '
                   ||'        OR x.RN4 > :lv_bom_lrn '
                   ||'        OR x.RN5 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_OP_RESOURCE_SEQS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;


      lv_bom7 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom7 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

  --lv_bom8
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*) from MRP_AD_OPERATION_RESOURCES_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING lv_bom_lrn;

         lv_sql_stmt:= 'select count(*) from MRP_AD_SUB_OPER_RESS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;

             EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param4 USING lv_bom_lrn;

              lv_param1 := lv_param1 + lv_param4;

       lv_sql_stmt:= 'select count(*) '
                   ||' from MRP_AP_OPERATION_RESOURCES_V'||p_dblink||'  x '
                   ||' where (    x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn '
                   ||'        OR x.RN4 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param2 USING  lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn;


       lv_sql_stmt:= 'select count(*) from MRP_AP_OP_RESOURCE_SEQS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param3;


      lv_bom8 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom8 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
   END IF;

   END IF ;

/* commented the below code
   this will be called in the 'IF prec.wip_flag = MSC_UTIL.SYS_YES THEN...' section which handles wip entities
    --lv_bom10 views are used only when wip_flag
    IF ( prec.wip_flag = MSC_UTIL.SYS_YES) THEN

       --lv_bom10
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*)  from MRP_AD_RESOURCE_REQUIREMENTS_V'||p_dblink
                   ||' where RN > :lv_wip_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_wip_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_RESOURCE_REQUIREMENTS_V'||p_dblink||' x '
                   ||' where (    x.RN1 > :lv_wip_lrn '
                   ||'        OR x.RN2 > :lv_wip_lrn '
                   ||'        OR x.RN3 > :lv_wip_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_wip_lrn,
                                                                  lv_wip_lrn,
                                                                  lv_wip_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_RESOURCE_REQUIREMENTS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

         lv_sql_stmt:= 'select count(*)  from MRP_AD_DJOB_SUB_OP_RESOURCES_V'||p_dblink
                   ||' where RN > :lv_wip_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING lv_wip_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_DJOB_SUB_OP_RESOURCES_V'||p_dblink||' x '
                   ||' where (    x.RN1 > :lv_wip_lrn '
                   ||' OR x.RN2 > :lv_wip_lrn '
                   ||' OR x.RN3 > :lv_wip_lrn )'
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING  lv_wip_lrn,
              						       lv_wip_lrn,
              						       lv_wip_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_DJOB_SUB_OP_RESOURCES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param6;


	      lv_sql_stmt:= 'select count(*)  from MRP_AD_RES_INSTANCE_REQS_V'||p_dblink
                   ||' where RN > :lv_wip_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param7 USING lv_wip_lrn;
  	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ad of res inst req = '||to_char(lv_param7));

              lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_RES_INSTANCE_REQS_V'||p_dblink||' x '
                   ||' where (    x.RN1 > :lv_wip_lrn '
                   ||'        OR x.RN2 > :lv_wip_lrn '
                   ||'        OR x.RN3 > :lv_wip_lrn '
                   ||'        OR x.RN4 > :lv_wip_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param8 USING  lv_wip_lrn,
                                                                  lv_wip_lrn,
                                                                  lv_wip_lrn,
                                                                  lv_wip_lrn;

  	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ap res inst req witl lrn = '||to_char(lv_param8));
               lv_sql_stmt:= 'select count(*)  from MRP_AP_RES_INSTANCE_REQS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param9 ;
  	      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ap res inst req without lrn = '||to_char(lv_param8));


       lv_param1 := lv_param1 + lv_param4 + lv_param7;
       lv_param2 := lv_param2 + lv_param5 + lv_param8;
       lv_param3 := lv_param3 + lv_param6 + lv_param9;

       lv_bom10 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
       IF lv_bom10 = MSC_UTIL.SYS_TGT THEN
          lv_status_decided_bom := MSC_UTIL.SYS_YES;
       END IF;
   END IF;

   END IF;
*/

   IF prec.bom_flag = MSC_UTIL.SYS_YES THEN
  --lv_bom11
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*)  from MRP_AD_OPERATION_COMPONENTS_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= ' select count(*)  '
                   ||' from MRP_AP_OPERATION_COMPONENTS_V'||p_dblink||' x '
                   ||' where (    x.RN1 > :lv_bom_lrn '
                   ||'        OR x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn '
                   ||'        OR x.RN4 > :lv_bom_lrn '
                   ||'        OR x.RN5 > :lv_bom_lrn '
                   ||'        OR x.RN6 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  from MRP_AP_OPERATION_COMPONENTS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;


      lv_bom11 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom11 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
    END IF;

  --lv_bom12
    IF lv_status_decided_bom = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*)  from MRP_AD_PROCESS_EFFECTIVITY_V'||p_dblink
                   ||' where RN > :lv_bom_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_PROCESS_EFFECTIVITY_V'||p_dblink||'  x '
                   ||' where (    x.RN2 > :lv_bom_lrn '
                   ||'        OR x.RN3 > :lv_bom_lrn '
                   ||'        OR x.RN4 > :lv_bom_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_bom_lrn,
                                                   lv_bom_lrn,
                                                   lv_bom_lrn;

       lv_sql_stmt:= 'select count(*)  from MRP_AP_PROCESS_EFFECTIVITY_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

      lv_bom12 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom12 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_bom := MSC_UTIL.SYS_YES;
      END IF;
    END IF;

   END IF;
 -- p_bor_sn_flag

    IF prec.bor_flag = MSC_UTIL.SYS_YES THEN

       --lv_bor1
       BEGIN
          SELECT MSC_UTIL.SYS_YES
          INTO   lv_status_decided_bor
          FROM   fnd_lookup_values
          WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                    enabled_flag = 'Y' AND
                    view_application_id = 700 AND
                    language = userenv('lang') AND
                    attribute2 = 'MTL_SYS_ITEMS_SN' AND
                    attribute13 = 'COMPLETE' AND
                    rownum = 1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             lv_status_decided_bor := MSC_UTIL.SYS_NO;
       END;

       IF lv_status_decided_bor = MSC_UTIL.SYS_NO THEN
          lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_CRP_RESOURCE_HOURS_V'||p_dblink||'  x '
                   ||' where x.RN2 > :lv_bor_lrn '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING  lv_bor_lrn;


          lv_sql_stmt:= 'select count(*)  from MRP_AP_CRP_RESOURCE_HOURS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

              lv_param2 :=0;

          lv_bor1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
       ELSE
          lv_bor1 := MSC_UTIL.SYS_TGT;
       END IF;

  END IF;

 -- p_item_sn_flag

  IF prec.item_flag = MSC_UTIL.SYS_YES THEN

     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_item
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN( 'MTL_SYS_ITEMS_SN','MTL_ITEM_CATS_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_item := MSC_UTIL.SYS_NO;
     END;

     IF lv_status_decided_item = MSC_UTIL.SYS_NO THEN

         --lv_item1
         lv_sql_stmt:= 'select count(*)  from MRP_AD_ITEM_CATEGORIES_V'||p_dblink
                   ||' where RN > :lv_item_lrn '
                   ||' and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_item_lrn;

          lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_ITEM_CATEGORIES_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_item_lrn '
                   ||'        OR x.RN2 > :lv_item_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_item_lrn,lv_item_lrn;


        lv_sql_stmt:= 'select count(*)  from MRP_AP_ITEM_CATEGORIES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;




        lv_item1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
        IF lv_item1 = MSC_UTIL.SYS_TGT THEN
           lv_status_decided_item := MSC_UTIL.SYS_YES;
        END IF;
     ELSE
        lv_item1 := MSC_UTIL.SYS_TGT;
     END IF;

  --lv_item2
     IF lv_status_decided_item = MSC_UTIL.SYS_NO THEN
        lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_SYSTEM_ITEMS_V'||p_dblink||'  x '
                   ||' where x.RN1 > :lv_item_lrn '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING  lv_item_lrn;


        lv_sql_stmt:= 'select count(*)  from MRP_AP_SYSTEM_ITEMS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

              lv_param2 :=0;

        lv_item2 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
     END IF;

  END IF;

  --p_oh_sn_flag
  IF prec.oh_flag = MSC_UTIL.SYS_YES THEN
    --lv_oh1
     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_oh
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN('MTL_OH_QTYS_SN', 'MTL_SYS_ITEMS_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_oh := MSC_UTIL.SYS_NO;
     END;

     IF lv_status_decided_oh = MSC_UTIL.SYS_NO THEN
        lv_sql_stmt:= 'select count(*)  from MRP_AD_ONHAND_SUPPLIES_V'||p_dblink
                   ||' where RN > :lv_oh_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_oh_lrn;

        lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_ONHAND_SUPPLIES_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_oh_lrn '
                   ||'        OR x.RN2 > :lv_oh_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_oh_lrn,
                                                   lv_oh_lrn;


        lv_sql_stmt:= 'select count(*)  from MRP_AP_ONHAND_SUPPLIES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;


        lv_oh1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
     ELSE
        lv_oh1 := MSC_UTIL.SYS_TGT;
     END IF;

  END IF;


 --p_usup_sn_flag
  IF prec.user_supply_demand_flag = MSC_UTIL.SYS_YES THEN

     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_usup
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN ('MTL_U_SUPPLY_SN', 'MTL_SYS_ITEMS_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_usup := MSC_UTIL.SYS_NO;
     END;

    IF lv_status_decided_usup = MSC_UTIL.SYS_NO THEN
       --lv_usup1
           lv_sql_stmt:= 'select count(*)  from MRP_AD_USER_SUPPLIES_V'||p_dblink
                   ||' where RN > :lv_usd_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_oh_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_USER_SUPPLIES_V'||p_dblink||' x '
                   ||' where (    x.RN1 > :lv_usd_lrn '
                   ||'        OR x.RN2 > :lv_usd_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_usd_lrn,
                                                   lv_usd_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_USER_SUPPLIES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

       lv_usup1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
    ELSE
       lv_usup1 := MSC_UTIL.SYS_TGT;
    END IF;

 --p_udmd_sn_flag
     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_udem
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN ('MTL_U_DEMAND_SN', 'MTL_SYS_ITEMS_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_udem := MSC_UTIL.SYS_NO;
     END;

   IF lv_status_decided_udem = MSC_UTIL.SYS_NO THEN
      --lv_udmd1
           lv_sql_stmt:= 'select count(*)  from MRP_AD_USER_DEMANDS_V'||p_dblink
                   ||' where RN > :lv_usd_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_oh_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_USER_DEMANDS_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_usd_lrn '
                   ||'        OR x.RN2 > :lv_usd_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_usd_lrn,
                                                   lv_usd_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_USER_DEMANDS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;


      lv_udmd1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
   ELSE
      lv_udmd1 := MSC_UTIL.SYS_TGT;
   END IF;

  END IF;


  --p_so_sn_flag
  IF (prec.sales_order_flag =MSC_UTIL.SYS_YES) THEN
     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_so
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN ('MTL_DEMAND_SN', 'OE_ODR_LINES_SN', 'MTL_SYS_ITEMS_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_so := MSC_UTIL.SYS_NO;
     END;
     IF lv_status_decided_so = MSC_UTIL.SYS_NO THEN
        --lv_so1
          lv_sql_stmt:= 'select count(*)  from MRP_AD_HARD_RESERVATIONS_V'||p_dblink
                   ||' where RN > :lv_rsv_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_rsv_lrn;


          lv_sql_stmt:= 'select count(*)  from MRP_AD_SALES_ORDERS_V'||p_dblink
                   ||' where RN > :lv_so_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING lv_so_lrn;

              lv_param1 :=lv_param1 + lv_param2;


          lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AN1_SALES_ORDERS_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_so_lrn '
                   ||'        OR x.RN2 > :lv_so_lrn '
                   ||'        OR x.RN3 > :lv_so_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_so_lrn,
                                                   lv_so_lrn,
                                                   lv_so_lrn;

          lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AN2_SALES_ORDERS_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_so_lrn '
                   ||'        OR x.RN2 > :lv_so_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING  lv_so_lrn,
                                                                  lv_so_lrn;

            lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AN3_SALES_ORDERS_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_so_lrn '
                   ||'        OR x.RN2 > :lv_so_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING  lv_so_lrn,
                                                                  lv_so_lrn;
   /*
             lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AN4_SALES_ORDERS_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_so_lrn '
                   ||'        OR x.RN2 > :lv_so_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING  lv_so_lrn,
                                                                  lv_so_lrn;
   */
            lv_param2 := lv_param2 + lv_param3 + lv_param4;  -- + lv_param5;


              lv_sql_stmt:= 'select count(*)  from MRP_AP1_SALES_ORDERS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

              lv_sql_stmt:= 'select count(*)  from MRP_AP2_SALES_ORDERS_V'||p_dblink
                   ||'  where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param4;

              lv_sql_stmt:= 'select count(*)  from MRP_AP3_SALES_ORDERS_V'||p_dblink
                   ||'  where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param5;
   /*
              lv_sql_stmt:= 'select count(*)  from MRP_AP4_SALES_ORDERS_V'||p_dblink
                   ||'  where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param6;
    */

           lv_param3 := lv_param3 + lv_param4 + lv_param5; -- + lv_param6;

           lv_so1 :=  get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
        ELSE
           lv_so1 := MSC_UTIL.SYS_TGT;
        END IF;

  END IF;

  --p_fcst_sn_flag
  IF prec.forecast_flag = MSC_UTIL.SYS_YES THEN
     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_fcst
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 = 'MRP_FORECAST_DSGN_SN' AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_fcst := MSC_UTIL.SYS_NO;
     END;

    IF lv_status_decided_fcst = MSC_UTIL.SYS_NO THEN
       --lv_fcst1

       lv_sql_stmt:= 'select count(*)  from MRP_AD_FORECAST_DSGN_V'||p_dblink
                   ||'  where RN > :lv_forecast_lrn '
                   ||'  and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_forecast_lrn;

       lv_sql_stmt:= 'select count(*) '
                   ||' from MRP_AP_FORECAST_DSGN_V'||p_dblink||'  x'
                   ||' where x.RN1 > :lv_forecast_lrn '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_forecast_lrn;

       lv_sql_stmt:= 'select count(*)  from MRP_AP_FORECAST_DSGN_V'||p_dblink
                   ||'  where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

       lv_fcst1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);

     --lv_fcst2

       lv_sql_stmt:= 'select count(*)  from MRP_AD_FORECAST_DEMAND_V'||p_dblink
                ||'  where RN > :lv_forecast_lrn '
                ||'  and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_forecast_lrn;

    lv_sql_stmt:= 'select count(*) '
                ||' from MRP_AP_FORECAST_DEMAND_V'||p_dblink||'  x'
                ||' where x.RN1 > :lv_forecast_lrn '
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_forecast_lrn;

    lv_sql_stmt:= 'select count(*)  from MRP_AP_FORECAST_DEMAND_V'||p_dblink
                ||'  where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

   lv_fcst2 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);

    ELSE
       lv_fcst1 := MSC_UTIL.SYS_TGT;
       lv_fcst2 := MSC_UTIL.SYS_TGT;
    END IF;

 END IF;

 -- p_wip_sn_flag
 IF prec.wip_flag = MSC_UTIL.SYS_YES THEN

    BEGIN
       SELECT MSC_UTIL.SYS_YES
       INTO   lv_status_decided_wip
       FROM   fnd_lookup_values
       WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                 enabled_flag = 'Y' AND
                 view_application_id = 700 AND
                 language = userenv('lang') AND
                 attribute2 IN
                         ('WIP_DSCR_JOBS_SN', 'WIP_FLOW_SCHDS_SN', 'WIP_OPR_RES_INSTS_SN', 'MTL_SYS_ITEMS_SN',
                         'WIP_REPT_ITEMS_SN', 'WIP_REPT_SCHDS_SN', 'WIP_WLINES_SN', 'WIP_WOPR_NETWORKS_SN',
                         'WIP_WOPR_RESS_SN', 'WIP_WOPR_SUB_RESS_SN', 'WIP_WOPRS_SN', 'WIP_WREQ_OPRS_SN') AND
                 attribute13 = 'COMPLETE' AND
                 rownum = 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          lv_status_decided_wip := MSC_UTIL.SYS_NO;
    END;

    IF lv_status_decided_wip = MSC_UTIL.SYS_NO THEN
    --lv_wip1

         lv_sql_stmt:= 'select count(*)  from MRP_AD_WIP_JOB_SUPPLIES_V'||p_dblink
                ||'  where RN > :lv_wip_lrn '
                ||'  and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_wip_lrn;

         lv_sql_stmt:= 'select count(*)  from MRP_AD_WIP_COMP_SUPPLIES_V'||p_dblink
                ||'  where RN > :lv_wip_lrn '
                ||'  and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING lv_wip_lrn;

         lv_sql_stmt:= 'select count(*)  from  MRP_AD_REPT_ITEM_SUPPLIES_V'||p_dblink
                ||' where RN > :lv_wip_lrn '
                ||' and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING lv_wip_lrn;

           lv_param1 := lv_param1 + lv_param2 + lv_param3;

         lv_sql_stmt:= 'select count(*) '
                    ||' from MRP_AP_WIP_JOB_SUPPLIES_V'||p_dblink||'  x '
                    ||' where (    x.RN1 > :lv_wip_lrn '
                    ||'        OR x.RN2 > :lv_wip_lrn )'
                    ||' and x.organization_id '|| lv_in_org_str;


               EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_wip_lrn,
                                                    lv_wip_lrn;

         lv_sql_stmt:= 'select count(*) '
                    ||' from MRP_AP_WIP_COMP_SUPPLIES_V'||p_dblink||'  x '
                    ||' where (    x.RN1 > :lv_wip_lrn '
                    ||'        OR x.RN2 > :lv_wip_lrn'
                    ||'        OR x.RN3 > :lv_wip_lrn )'
                    ||' and x.organization_id '|| lv_in_org_str;


               EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING  lv_wip_lrn,
                                                    lv_wip_lrn,
                                                    lv_wip_lrn;

        lv_sql_stmt:= 'select count(*) '
                    ||' from MRP_AP_REPT_ITEM_SUPPLIES_V'||p_dblink||' x '
                    ||' where (    x.RN1 > :lv_wip_lrn '
                    ||'        OR x.RN2 > :lv_wip_lrn '
                    ||'        OR x.RN3 > :lv_wip_lrn '
                    ||'        OR x.RN4 > :lv_wip_lrn ) '
                    ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING  lv_wip_lrn,
                                                lv_wip_lrn,
                                                lv_wip_lrn,
                                                lv_wip_lrn;

        lv_param2 := lv_param2 + lv_param3 + lv_param4;


        lv_sql_stmt:= 'select count(*)  from MRP_AP_WIP_JOB_SUPPLIES_V'||p_dblink
                ||'  where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

        lv_sql_stmt:= 'select count(*)  from MRP_AP_WIP_COMP_SUPPLIES_V'||p_dblink
                ||'  where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param4;

        lv_sql_stmt:= 'select count(*)  from MRP_AP_REPT_ITEM_SUPPLIES_V'||p_dblink
                ||'  where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param5;

           lv_param3 := lv_param3 + lv_param4 + lv_param5;

        lv_wip1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);

        IF lv_wip1 = MSC_UTIL.SYS_TGT THEN
           lv_status_decided_wip := MSC_UTIL.SYS_YES;
        END IF;
    ELSE
       lv_wip1 := MSC_UTIL.SYS_TGT;
    END IF;

    IF lv_status_decided_wip = MSC_UTIL.SYS_NO THEN
    --lv_wip2

         lv_sql_stmt:= 'select count(*)  from MRP_AD_WIP_COMP_DEMANDS_V'||p_dblink
                ||' where RN > :lv_wip_lrn '
                ||' and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_wip_lrn;

         lv_sql_stmt:= 'select count(*)  from  MRP_AD_WIP_FLOW_DEMANDS_V'||p_dblink
                ||'  where RN > :lv_wip_lrn '
                ||'  and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING lv_wip_lrn;

         lv_sql_stmt:= 'select count(*)  from  MRP_AD_REPT_ITEM_DEMANDS_V'||p_dblink
                ||' where RN > :lv_wip_lrn '
                ||' and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING lv_wip_lrn;


           lv_param1 := lv_param1 + lv_param2 + lv_param3;


           lv_sql_stmt:= ' select count(*)  '
                      ||' from MRP_AP_WIP_COMP_DEMANDS_V'||p_dblink||'  x '
                      ||' where (    x.RN1 > :lv_wip_lrn '
                      ||'        OR x.RN2 > :lv_wip_lrn '
                      ||'        OR x.RN3 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_wip_lrn,
                                                      lv_wip_lrn,
                                                      lv_wip_lrn;

          lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_REPT_ITEM_DEMANDS_V'||p_dblink||'  x '
                      ||' where (    x.RN1 > :lv_wip_lrn '
                      ||'        OR x.RN2 > :lv_wip_lrn '
                      ||'        OR x.RN3 > :lv_wip_lrn '
                      ||'        OR x.RN4 > :lv_wip_lrn '
                      ||'        OR x.RN5 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING  lv_wip_lrn,
                                                lv_wip_lrn,
                                                lv_wip_lrn,
                                                lv_wip_lrn,
                                                lv_wip_lrn;
        lv_param2 := lv_param2 + lv_param3;

        lv_sql_stmt:= 'select count(*)  from MRP_AP_WIP_COMP_DEMANDS_V'||p_dblink
                   ||'  where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

        lv_sql_stmt:= 'select count(*)  from MRP_AP_REPT_ITEM_DEMANDS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param4;

        lv_param3 := lv_param3 + lv_param4;

        lv_wip2 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);

        IF lv_wip2 = MSC_UTIL.SYS_TGT THEN
           lv_status_decided_wip := MSC_UTIL.SYS_YES;
        END IF;
     END IF;


   -- lv_wip3
  IF lv_status_decided_wip = MSC_UTIL.SYS_NO THEN
     lv_sql_stmt:= 'select LBJ_DETAILS '
                   || ' from msc_apps_instances '
                   || ' where instance_id = ' || p_instance_id ;
              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1;

     if(lv_param1 = 1) then
        lv_sql_stmt:= 'select count(*)  from MRP_AD_JOB_OP_NETWORKS_V'||p_dblink
                      ||'  where RN > :lv_wip_lrn '
                      ||'  and organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_wip_lrn;

        lv_sql_stmt:= 'select count(*)  from MRP_AD_JOB_OPERATIONS_V'||p_dblink
                      ||'  where RN > :lv_wip_lrn '
                      ||'  and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING lv_wip_lrn;

        lv_sql_stmt:= 'select count(*)  from MRP_AD_REQUIREMENT_OPS_V'||p_dblink
                      ||'  where RN > :lv_wip_lrn '
                      ||'  and organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING lv_wip_lrn;

       lv_sql_stmt:= 'select count(*)  from MRP_AD_JOB_OP_RESOURCES_V'||p_dblink
                      ||'  where RN > :lv_wip_lrn '
                      ||'  and organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING lv_wip_lrn;

       lv_sql_stmt:= 'select count(*)  from MRP_AD_LJ_SUB_OP_RESOURCES_V'||p_dblink
                      ||'  where RN > :lv_wip_lrn '
                      ||'  and organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING lv_wip_lrn;

       /* ds change */
       lv_sql_stmt:= 'select count(*)  from MRP_AD_LJ_OPR_RES_INSTS_V'||p_dblink
                      ||' where RN > :lv_wip_lrn '
                      ||' and organization_id '|| lv_in_org_str;
                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param6 USING lv_wip_lrn;
        	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ad lj opr res inst = '||to_char(lv_param6));
       /* ds change *end/

       lv_param1 := lv_param1 + lv_param2 + lv_param3 + lv_param4 + lv_param5
   	   	+ lv_param6;

       lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_JOB_OP_NETWORKS_V'||p_dblink||'  x '
                      ||' where (    x.RN > :lv_wip_lrn '
                      ||' OR x.RN1 > :lv_wip_lrn '
                      ||' OR x.RN2 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_wip_lrn,
                                                                     lv_wip_lrn,
                                                                     lv_wip_lrn;

        lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_JOB_OPERATIONS_V'||p_dblink||'  x '
                      ||' where (    x.RN > :lv_wip_lrn '
                      ||' OR x.RN1 > :lv_wip_lrn '
                      ||' OR x.RN2 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING  lv_wip_lrn,
                                                                     lv_wip_lrn,
                                                                     lv_wip_lrn;

        lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_JOB_REQUIREMENT_OPS_V'||p_dblink||'  x '
                      ||' where (    x.RN > :lv_wip_lrn '
                      ||' OR x.RN1 > :lv_wip_lrn '
                      ||' OR x.RN2 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING  lv_wip_lrn,
                                                                     lv_wip_lrn,
                                                                     lv_wip_lrn;

         lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_JOB_OP_RESOURCES_V'||p_dblink||'  x '
                      ||' where (    x.RN > :lv_wip_lrn '
                      ||' OR x.RN1 > :lv_wip_lrn '
                      ||' OR x.RN2 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING  lv_wip_lrn,
                                                                     lv_wip_lrn,
                                                                     lv_wip_lrn;

         lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_LJ_SUB_OP_RESOURCES_V'||p_dblink||'  x '
                      ||' where (    x.RN1 > :lv_wip_lrn '
                      ||' OR x.RN2 > :lv_wip_lrn '
                      ||' OR x.RN3 > :lv_wip_lrn )'
                      ||' and x.organization_id '|| lv_in_org_str;


                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param6 USING  lv_wip_lrn,
                                                                     lv_wip_lrn,
                                                                     lv_wip_lrn;
          /* ds change */
         lv_sql_stmt:= 'select count(*)  '
                      ||' from MRP_AP_JOB_RES_INSTANCES_V'||p_dblink||' x '
                      ||' where (    x.RN1 > :lv_wip_lrn '
                      ||'        OR x.RN2 > :lv_wip_lrn '
                      ||'        OR x.RN3 > :lv_wip_lrn ) '
                      ||' and x.organization_id '|| lv_in_org_str;
                      EXECUTE IMMEDIATE lv_sql_stmt into lv_param7 USING
                                      lv_wip_lrn,
                                      lv_wip_lrn,
                                      lv_wip_lrn;
        	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ap job res inst = '||to_char(lv_param7));
         /* ds change end */
         lv_param2 := lv_param2 + lv_param3 + lv_param4 + lv_param5 + lv_param6
   	   	+ lv_param7;

         lv_sql_stmt:= 'select count(*)  from MRP_AP_JOB_OP_NETWORKS_V'||p_dblink
                      ||' where organization_id '|| lv_in_org_str;

                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

         lv_sql_stmt:= 'select count(*)  from MRP_AP_JOB_OPERATIONS_V'||p_dblink
                      ||' where organization_id '|| lv_in_org_str;

                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param4;

         lv_sql_stmt:= 'select count(*)  from MRP_AP_JOB_REQUIREMENT_OPS_V'||p_dblink
                      ||' where organization_id '|| lv_in_org_str;

                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param5;

         lv_sql_stmt:= 'select count(*)  from MRP_AP_JOB_OP_RESOURCES_V'||p_dblink
                      ||' where organization_id '|| lv_in_org_str;

                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param6;

        lv_sql_stmt:= 'select count(*)  from MRP_AP_LJ_SUB_OP_RESOURCES_V'||p_dblink
                      ||' where organization_id '|| lv_in_org_str;

                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param7;

         /* ds change start */
        lv_sql_stmt:= 'select count(*)  from MRP_AP_JOB_RES_INSTANCES_V'||p_dblink
                      ||' where organization_id '|| lv_in_org_str;

                 EXECUTE IMMEDIATE lv_sql_stmt into lv_param8;
        	   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ap job res inst = '||to_char(lv_param8));
        /* ds change end */

        lv_param3 := lv_param3 + lv_param4 + lv_param5 + lv_param6 + lv_param7
   	           + lv_param8;

        lv_wip3 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
        IF lv_wip3 = MSC_UTIL.SYS_TGT THEN
           lv_status_decided_wip := MSC_UTIL.SYS_YES;
        END IF;
     end if;   -- lv_param1 = 1
  END IF;  -- lv_wip3 status

  IF lv_status_decided_wip = MSC_UTIL.SYS_NO THEN
      -- lv_bom10
      lv_sql_stmt:= 'select count(*)  from MRP_AD_RESOURCE_REQUIREMENTS_V'||p_dblink
                  ||' where RN > :lv_wip_lrn '
                  ||' and organization_id '|| lv_in_org_str;


             EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_wip_lrn;

      lv_sql_stmt:= 'select count(*)  '
                  ||' from MRP_AP_RESOURCE_REQUIREMENTS_V'||p_dblink||' x '
                  ||' where (    x.RN1 > :lv_wip_lrn '
                  ||'        OR x.RN2 > :lv_wip_lrn '
                  ||'        OR x.RN3 > :lv_wip_lrn ) '
                  ||' and x.organization_id '|| lv_in_org_str;


             EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_wip_lrn,
                                                                 lv_wip_lrn,
                                                                 lv_wip_lrn;


      lv_sql_stmt:= 'select count(*)  from MRP_AP_RESOURCE_REQUIREMENTS_V'||p_dblink
                  ||' where organization_id '|| lv_in_org_str;

             EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

        lv_sql_stmt:= 'select count(*)  from MRP_AD_DJOB_SUB_OP_RESOURCES_V'||p_dblink
                  ||' where RN > :lv_wip_lrn '
                  ||' and organization_id '|| lv_in_org_str;


             EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING lv_wip_lrn;

      lv_sql_stmt:= 'select count(*)  '
                  ||' from MRP_AP_DJOB_SUB_OP_RESOURCES_V'||p_dblink||' x '
                  ||' where (    x.RN1 > :lv_wip_lrn '
                  ||' OR x.RN2 > :lv_wip_lrn '
                  ||' OR x.RN3 > :lv_wip_lrn )'
                  ||' and x.organization_id '|| lv_in_org_str;


             EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING  lv_wip_lrn,
             						       lv_wip_lrn,
             						       lv_wip_lrn;


      lv_sql_stmt:= 'select count(*)  from MRP_AP_DJOB_SUB_OP_RESOURCES_V'||p_dblink
                  ||' where organization_id '|| lv_in_org_str;

             EXECUTE IMMEDIATE lv_sql_stmt into lv_param6;


       /* ds change start */
      lv_sql_stmt:= 'select count(*)  from MRP_AD_RES_INSTANCE_REQS_V'||p_dblink
                  ||' where RN > :lv_wip_lrn '
                  ||' and organization_id '|| lv_in_org_str;


             EXECUTE IMMEDIATE lv_sql_stmt into lv_param7 USING lv_wip_lrn;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ad of res inst req = '||to_char(lv_param7));

             lv_sql_stmt:= 'select count(*)  '
                  ||' from MRP_AP_RES_INSTANCE_REQS_V'||p_dblink||' x '
                  ||' where (    x.RN1 > :lv_wip_lrn '
                  ||'        OR x.RN2 > :lv_wip_lrn '
                  ||'        OR x.RN3 > :lv_wip_lrn '
                  ||'        OR x.RN4 > :lv_wip_lrn ) '
                  ||' and x.organization_id '|| lv_in_org_str;


             EXECUTE IMMEDIATE lv_sql_stmt into lv_param8 USING  lv_wip_lrn,
                                                                 lv_wip_lrn,
                                                                 lv_wip_lrn,
                                                                 lv_wip_lrn;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ap res inst req witl lrn = '||to_char(lv_param8));
              lv_sql_stmt:= 'select count(*)  from MRP_AP_RES_INSTANCE_REQS_V'||p_dblink
                  ||' where organization_id '|| lv_in_org_str;

             EXECUTE IMMEDIATE lv_sql_stmt into lv_param9 ;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'count for ap res inst req without lrn = '||to_char(lv_param8));

           /* ds change end */

      lv_param1 := lv_param1 + lv_param4 + lv_param7;
      lv_param2 := lv_param2 + lv_param5 + lv_param8;
      lv_param3 := lv_param3 + lv_param6 + lv_param9;

      lv_bom10 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_bom10 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_wip := MSC_UTIL.SYS_YES;
      END IF;
  END IF;

  END IF; -- wip_flag

  --lv_bom9
   IF (prec.bom_flag = MSC_UTIL.SYS_YES OR prec.wip_flag = MSC_UTIL.SYS_YES) THEN
      IF lv_status_decided_bom = MSC_UTIL.SYS_NO AND lv_status_decided_wip = MSC_UTIL.SYS_NO THEN
         lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_LINE_RESOURCES_V'||p_dblink||' x '
                   ||' where  x.RN1 > :lv_bom_lrn '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt INTO lv_param1 USING  lv_bom_lrn;

          lv_sql_stmt:= 'select count(*)  from MRP_AP_LINE_RESOURCES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

              lv_param2 :=0;

         lv_bom9 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
         IF lv_bom9 = MSC_UTIL.SYS_TGT THEN
            lv_status_decided_bom := MSC_UTIL.SYS_YES;
         END IF;
      END IF;
   END IF;

  --p_supcap_sn_flag

IF prec.app_supp_cap_flag = MSC_UTIL.SYS_YES or prec.app_supp_cap_flag =MSC_UTIL.ASL_YES_RETAIN_CP THEN
   BEGIN
      SELECT MSC_UTIL.SYS_YES
      INTO   lv_status_decided_app_supp_cap
      FROM   fnd_lookup_values
      WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                enabled_flag = 'Y' AND
                view_application_id = 700 AND
                language = userenv('lang') AND
                attribute2 IN
                        ('PO_SI_CAPA_SN', 'MTL_SYS_ITEMS_SN') AND
                attribute13 = 'COMPLETE' AND
                rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lv_status_decided_app_supp_cap := MSC_UTIL.SYS_NO;
   END;
   --lv_supcap1
    IF lv_status_decided_app_supp_cap = MSC_UTIL.SYS_NO THEN
       lv_sql_stmt:= 'select count(*)  from MRP_AD_SUPPLIER_CAPACITIES_V'||p_dblink
                   ||'  where RN > :lv_sup_cap_lrn '
                   ||'  and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_sup_cap_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_SUPPLIER_CAPACITIES_V'||p_dblink||'  x '
                   ||' where (    x.RN1 > :lv_sup_cap_lrn '
                   ||'        OR x.RN2 > :lv_sup_cap_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_sup_cap_lrn,
                                                   lv_sup_cap_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_SUPPLIER_CAPACITIES_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

      lv_supcap1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
   ELSE
      lv_supcap1 := MSC_UTIL.SYS_TGT;
   END IF;

END IF;

 --p_po_sn_flag

IF prec.po_flag = MSC_UTIL.SYS_YES THEN
   BEGIN
      SELECT MSC_UTIL.SYS_YES
      INTO   lv_status_decided_po
      FROM   fnd_lookup_values
      WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                enabled_flag = 'Y' AND
                view_application_id = 700 AND
                language = userenv('lang') AND
                attribute2 IN
                        ('MTL_SUPPLY_SN', 'MTL_SYS_ITEMS_SN') AND
                attribute13 = 'COMPLETE' AND
                rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lv_status_decided_po := MSC_UTIL.SYS_NO;
   END;
     --lv_po1
  IF lv_status_decided_po = MSC_UTIL.SYS_NO THEN
        lv_sql_stmt:= 'select count(*)  from MRP_AD_PO_SUPPLIES_V'||p_dblink
                ||' where RN > :lv_po_lrn'
                ||' and organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_po_lrn;


       lv_sql_stmt:= 'select count(*)  '
                ||' from MRP_AP_PO_PO_SUPPLY_V'||p_dblink||' x '
                ||' where (    x.RN2 > :lv_po_lrn '
                ||'        OR x.RN3 > :lv_po_lrn ) '
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_po_lrn,
                                                lv_po_lrn;

       lv_sql_stmt:= 'select count(*)  '
                ||' from  MRP_AP_PO_SHIP_SUPPLY_V'||p_dblink||'  x '
                ||' where (    x.RN2 > :lv_po_lrn '
                ||'        OR x.RN3 > :lv_po_lrn )'
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3 USING  lv_po_lrn,
                                                lv_po_lrn;

       lv_sql_stmt:= 'select count(*) '
                ||' from  MRP_AP_PO_REQ_SUPPLY_V'||p_dblink||' x '
                ||' where (    x.RN2 > :lv_po_lrn '
                ||'        OR x.RN3 > :lv_po_lrn )'
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param4 USING  lv_po_lrn,
                                                lv_po_lrn;

        lv_sql_stmt:= 'select count(*) '
                ||' from  MRP_AP_PO_SHIP_RCV_SUPPLY_V'||p_dblink||'  x '
                ||' where (    x.RN2 > :lv_po_lrn  '
                ||'        OR x.RN3 > :lv_po_lrn ) '
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param5 USING  lv_po_lrn,
                                                lv_po_lrn;

          lv_sql_stmt:= 'select count(*) '
                ||' from   MRP_AP_PO_RCV_SUPPLY_V'||p_dblink||'  x '
                ||' where (    x.RN2 > :lv_po_lrn  '
                ||'        OR x.RN3 > :lv_po_lrn ) '
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param6 USING  lv_po_lrn,
                                                lv_po_lrn;


           lv_sql_stmt:= 'select count(*)  '
                ||' from  MRP_AP_INTRANSIT_SUPPLIES_V'||p_dblink||'  x '
                ||' where   x.RN2 > :lv_po_lrn '
                ||' and x.organization_id '|| lv_in_org_str;


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param7 USING  lv_po_lrn;

           lv_param2:=lv_param2 + lv_param3 + lv_param4 + lv_param5 + lv_param6 + lv_param7;

           lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_PO_SUPPLY_V'||p_dblink
                ||' where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

           lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_SHIP_SUPPLY_V'||p_dblink
                ||' where organization_id  '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param4;

           lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_REQ_SUPPLY_V'||p_dblink
                ||' where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param5;

           lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_SHIP_RCV_SUPPLY_V'||p_dblink
                ||' where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param6;

           lv_sql_stmt:= 'select count(*)  from MRP_AP_PO_RCV_SUPPLY_V'||p_dblink
                ||' where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param7;

           lv_sql_stmt:= 'select count(*)  from MRP_AP_INTRANSIT_SUPPLIES_V'||p_dblink
                ||' where organization_id '|| lv_in_org_str;

           EXECUTE IMMEDIATE lv_sql_stmt into lv_param8;

            lv_param3:=lv_param3 + lv_param4 + lv_param5 + lv_param6 + lv_param7 + lv_param8;

            lv_po1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
   ELSE
      lv_po1 := MSC_UTIL.SYS_TGT;
   END IF;
END IF;

 --p_mds_sn_flag

  IF  prec.mds_flag = MSC_UTIL.SYS_YES THEN

     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_mds
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN
                          ('MRP_SCHD_DATES_SN', 'MTL_SYS_ITEMS_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_mds := MSC_UTIL.SYS_NO;
     END;

    IF lv_status_decided_mds = MSC_UTIL.SYS_NO THEN
       --lv_mds1
            lv_sql_stmt:= 'select count(*)  from MRP_AD_MDS_DEMANDS_V'||p_dblink
                   ||' where RN > :lv_mds_lrn '
                   ||' and organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_sup_cap_lrn;

       lv_sql_stmt:= 'select count(*)  '
                   ||' from MRP_AP_MDS_DEMANDS_V'||p_dblink||'  x '
                   ||' where (    x.RN2 > :lv_mds_lrn  '
                   ||'        OR x.RN3 > :lv_mds_lrn ) '
                   ||' and x.organization_id '|| lv_in_org_str;


              EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_mds_lrn,
                                                   lv_mds_lrn;


       lv_sql_stmt:= 'select count(*)  from MRP_AP_MDS_DEMANDS_V'||p_dblink
                   ||' where organization_id '|| lv_in_org_str;

              EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

       lv_mds1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
    ELSE
       lv_mds1 := MSC_UTIL.SYS_TGT;
    END IF;

  END IF;

     --p_mps_sn_flag

  IF prec.mps_flag = MSC_UTIL.SYS_YES THEN
      BEGIN
         SELECT MSC_UTIL.SYS_YES
         INTO   lv_status_decided_mps
         FROM   fnd_lookup_values
         WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                   enabled_flag = 'Y' AND
                   view_application_id = 700 AND
                   language = userenv('lang') AND
                   attribute2 IN
                           ('MRP_SCHD_DATES_SN', 'MTL_SYS_ITEMS_SN') AND
                   attribute13 = 'COMPLETE' AND
                   rownum = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            lv_status_decided_mps := MSC_UTIL.SYS_NO;
      END;

      IF lv_status_decided_mps = MSC_UTIL.SYS_NO THEN

         --lv_mps1
              lv_sql_stmt:= 'select count(*)  from MRP_AD_MPS_SUPPLIES_V'||p_dblink
                     ||' where RN > :lv_mps_lrn '
                     ||' and organization_id '|| lv_in_org_str;


                EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_sup_cap_lrn;

         lv_sql_stmt:= 'select count(*)  '
                     ||' from MRP_AP_MPS_SUPPLIES_V'||p_dblink||'  x '
                     ||' where (    x.RN2 > :lv_mps_lrn '
                     ||'        OR x.RN3 > :lv_mps_lrn ) '
                     ||' and x.organization_id '|| lv_in_org_str;


                EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_mps_lrn,
                                                     lv_mps_lrn;


         lv_sql_stmt:= 'select count(*)  from MRP_AP_MPS_SUPPLIES_V'||p_dblink
                     ||'  where organization_id '|| lv_in_org_str;

                EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;
         lv_mps1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      ELSE
         lv_mps1 := MSC_UTIL.SYS_TGT;
      END IF;

  END IF;

    --p_trip_sn_flag

  IF prec.trip_flag = MSC_UTIL.SYS_YES THEN
     BEGIN
        SELECT MSC_UTIL.SYS_YES
        INTO   lv_status_decided_trip
        FROM   fnd_lookup_values
        WHERE  lookup_type = 'MSC_COLL_SNAPSHOTS' AND
                  enabled_flag = 'Y' AND
                  view_application_id = 700 AND
                  language = userenv('lang') AND
                  attribute2 IN
                          ('WSH_TRIP_SN', 'WSH_TRIP_STOP_SN') AND
                  attribute13 = 'COMPLETE' AND
                  rownum = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           lv_status_decided_trip := MSC_UTIL.SYS_NO;
     END;


    --lv_trip1
    IF lv_status_decided_trip = MSC_UTIL.SYS_NO THEN
         lv_sql_stmt:= 'select count(*)  from MRP_AD_TRIPS_V'||p_dblink
                ||' where RN > :lv_trip_lrn ';


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_trip_lrn;

        lv_sql_stmt:= 'select count(*)  '
                    ||' from MRP_AP_TRIPS_V'||p_dblink||'  x '
                    ||' where     x.RN > :lv_trip_lrn  ';


               EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_trip_lrn;


        lv_sql_stmt:= 'select count(*)  from MRP_AP_TRIPS_V'||p_dblink;


               EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

      lv_trip1 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
      IF lv_trip1 = MSC_UTIL.SYS_TGT THEN
         lv_status_decided_trip := MSC_UTIL.SYS_YES;
      END IF;

    ELSE
       lv_trip1 := MSC_UTIL.SYS_TGT;
    END IF;

    IF lv_status_decided_trip = MSC_UTIL.SYS_NO THEN
  --lv_trip2
         lv_sql_stmt:= 'select count(*)  from MRP_AD_TRIP_STOPS_V'||p_dblink
                ||' where RN > :lv_trip_lrn ';


           EXECUTE IMMEDIATE lv_sql_stmt into lv_param1 USING lv_trip_lrn;

        lv_sql_stmt:= 'select count(*)  '
                    ||' from MRP_AP_TRIP_STOPS_V'||p_dblink||'  x '
                    ||' where     x.RN > :lv_trip_lrn  ';


               EXECUTE IMMEDIATE lv_sql_stmt into lv_param2 USING  lv_trip_lrn;


        lv_sql_stmt:= 'select count(*)  from MRP_AP_TRIP_STOPS_V'||p_dblink;


               EXECUTE IMMEDIATE lv_sql_stmt into lv_param3;

      lv_trip2 := get_refresh_type(lv_param1,lv_param2,lv_param3,p_coll_thresh);
    END IF;

  END IF;
 END IF ;
   /*----------------------------------------------- */


      if ((lv_bom1    = MSC_UTIL.SYS_TGT) or
          (lv_bom2    = MSC_UTIL.SYS_TGT) or
          (lv_bom3    = MSC_UTIL.SYS_TGT) or
          (lv_bom4    = MSC_UTIL.SYS_TGT) or
     --     (lv_bom5    = MSC_UTIL.SYS_TGT) or
          (lv_bom6    = MSC_UTIL.SYS_TGT) or
          (lv_bom7    = MSC_UTIL.SYS_TGT) or
          (lv_bom8    = MSC_UTIL.SYS_TGT) or
          (lv_bom9    = MSC_UTIL.SYS_TGT) or
	-- lv_bom10 should only be used when wip is enabled.Its views are used in load_wip (mscclaab) only when wip is enabled.
       --   (lv_bom10   = MSC_UTIL.SYS_TGT) or
          (lv_bom11   = MSC_UTIL.SYS_TGT) or
          (lv_bom12   = MSC_UTIL.SYS_TGT)) then
         p_bom_sn_flag := MSC_UTIL.SYS_TGT;
      elsif ((lv_bom1      = MSC_UTIL.SYS_NO) and
            (lv_bom2       = MSC_UTIL.SYS_NO) and
            (lv_bom3       = MSC_UTIL.SYS_NO) and
            (lv_bom4       = MSC_UTIL.SYS_NO) and
     --     (lv_bom5       = MSC_UTIL.SYS_NO) and
            (lv_bom6       = MSC_UTIL.SYS_NO) and
            (lv_bom7       = MSC_UTIL.SYS_NO) and
            (lv_bom8       = MSC_UTIL.SYS_NO) and
            (lv_bom9       = MSC_UTIL.SYS_NO) and
     --       (lv_bom10      = MSC_UTIL.SYS_NO) and
            (lv_bom11      = MSC_UTIL.SYS_NO) and
            (lv_bom12      = MSC_UTIL.SYS_NO)) then
         p_bom_sn_flag := MSC_UTIL.SYS_NO;
      else
         p_bom_sn_flag := MSC_UTIL.SYS_INCR;
      end if;


      p_bor_sn_flag :=lv_bor1;


      if ((lv_item1    = MSC_UTIL.SYS_TGT) or
          (lv_item2    = MSC_UTIL.SYS_TGT)) then
        p_item_sn_flag := MSC_UTIL.SYS_TGT;
     elsif ((lv_item1       = MSC_UTIL.SYS_NO) and
            (lv_item2       = MSC_UTIL.SYS_NO)) then
          p_item_sn_flag := MSC_UTIL.SYS_NO;
      else
          p_item_sn_flag := MSC_UTIL.SYS_INCR;
      end if;


      p_oh_sn_flag   := lv_oh1;

      p_usup_sn_flag := lv_usup1;

      p_udmd_sn_flag := lv_udmd1;

      p_so_sn_flag   := lv_so1;

     if ((lv_fcst1     = MSC_UTIL.SYS_TGT) or
          (lv_fcst2    = MSC_UTIL.SYS_TGT)) then
        p_fcst_sn_flag := MSC_UTIL.SYS_TGT;
     elsif ((lv_fcst1       = MSC_UTIL.SYS_NO) and
            (lv_fcst2       = MSC_UTIL.SYS_NO)) then
          p_fcst_sn_flag := MSC_UTIL.SYS_NO;
     else
          p_fcst_sn_flag := MSC_UTIL.SYS_INCR;
     end if;


      if ((lv_wip1    = MSC_UTIL.SYS_TGT) or
          (lv_wip2    = MSC_UTIL.SYS_TGT) or
          (lv_wip3    = MSC_UTIL.SYS_TGT) or
          (lv_bom9    = MSC_UTIL.SYS_TGT) or
          (lv_bom10   = MSC_UTIL.SYS_TGT)) then
         p_wip_sn_flag := MSC_UTIL.SYS_TGT;
       elsif   ((lv_wip1    = MSC_UTIL.SYS_NO) and
                (lv_wip2    = MSC_UTIL.SYS_NO) and
                (lv_wip3    = MSC_UTIL.SYS_NO) and
                (lv_bom9    = MSC_UTIL.SYS_NO) and
                (lv_bom10   = MSC_UTIL.SYS_NO)) then
         p_wip_sn_flag := MSC_UTIL.SYS_NO;
      else
         p_wip_sn_flag := MSC_UTIL.SYS_INCR;
      end if;

      p_supcap_sn_flag := lv_supcap1;

      p_po_sn_flag     := lv_po1;

      p_mds_sn_flag    := lv_mds1;

      p_mps_sn_flag    := lv_mps1;

      if ((lv_trip1    = MSC_UTIL.SYS_TGT) or
          (lv_trip2    = MSC_UTIL.SYS_TGT)) then
        p_trip_sn_flag := MSC_UTIL.SYS_TGT;
     elsif ((lv_trip1       = MSC_UTIL.SYS_NO) and
            (lv_trip2       = MSC_UTIL.SYS_NO)) then
          p_trip_sn_flag := MSC_UTIL.SYS_NO;
      else
          p_trip_sn_flag := MSC_UTIL.SYS_INCR;
      end if;

/*
   if ((p_last_tgt_cont_coll_time is null) or
       (p_last_tgt_cont_coll_time + (p_coll_freq/24) <= sysdate)) then
      p_nosnap_flag := MSC_UTIL.SYS_YES;
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' p_nosnap_flag is YES ');
   else
	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  ' p_nosnap_flag is NO ');
      p_nosnap_flag := MSC_UTIL.SYS_NO;
   end if;

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' p_nosnap_flag : '||p_nosnap_flag);
*/
      -- For Future Use only. Time Frequency for Non Snapshot Entities

       p_nosnap_flag := -1;

 /*     IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) THEN
             p_supcap_sn_flag := lv_po_supcap_snrt;

      ELSE             -- For 110/107 source , supplier capacity is associated with other setup entities -nosnap_flag
	      p_supcap_sn_flag := p_nosnap_flag;
      END IF;
 */

END init_entity_refresh_type;

   FUNCTION set_cont_refresh_type (p_instance_id in NUMBER,
                                   p_task_num    in NUMBER,
                                   prec          in MSC_UTIL.CollParamREC,
                                   p_lrnn        in number,
                                   p_cont_lrnn   out NOCOPY number)

   RETURN BOOLEAN AS

   BEGIN

         IF p_task_num = MSC_CL_PULL.TASK_SUPPLIER_CAPACITY THEN
	     IF (MSC_CL_PULL.v_apps_ver >= MSC_UTIL.G_APPS115) THEN
                 if (prec.supcap_sn_flag = MSC_UTIL.SYS_INCR) then
                    -- do net-change for this entity
                    p_cont_lrnn := p_lrnn;
                    RETURN TRUE;
                 elsif (prec.supcap_sn_flag = MSC_UTIL.SYS_TGT) then
                    -- do targeted for this entity
                    p_cont_lrnn := -1;
                    RETURN TRUE;
                 else
                    -- do nothing
                    RETURN FALSE;
                 end if;
	     ELSE         --- For 110/107 source instance, supplier capacity is associated with Other setup entities
                  IF (prec.app_supp_cap_flag = MSC_UTIL.ASL_YES OR prec.app_supp_cap_flag =MSC_UTIL.ASL_YES_RETAIN_CP) THEN
                     -- do targeted for this entity
                     p_cont_lrnn := -1;
                     RETURN TRUE;
                  else
                  -- do nothing
                     RETURN FALSE;
                  end if;
	     END IF;
         END IF;

         IF ((p_task_num = MSC_CL_PULL.TASK_BOM)                  or
             (p_task_num = MSC_CL_PULL.TASK_ROUTING)              or
             (p_task_num = MSC_CL_PULL.TASK_OPER_NETWORKS)        or
             (p_task_num = MSC_CL_PULL.TASK_ROUTING_OPERATIONS)   or
             (p_task_num = MSC_CL_PULL.TASK_OPERATION_RES_SEQS)   or
             (p_task_num = MSC_CL_PULL.TASK_OPERATION_RESOURCES)  or
             (p_task_num = MSC_CL_PULL.TASK_OPERATION_COMPONENTS) or
             (p_task_num = MSC_CL_PULL.TASK_PROCESS_EFFECTIVITY) )   THEN
              -- LOAD_BOM,
              -- LOAD_ROUTING,
              -- LOAD_OPER_NETWORKS
              -- LOAD_ROUTING_OPERATIONS
              -- LOAD_OPERATION_RES_SEQS
              -- LOAD_OPERATION_RESOURCES
              -- LOAD_OPERATION_COMPONENTS
              -- LOAD_PROCESS_EFFECTIVITY
              -- extract effectivities are performed
             if (prec.bom_sn_flag = MSC_UTIL.SYS_INCR) then
                -- do net-change for this entity
                p_cont_lrnn := p_lrnn;
                RETURN TRUE;
             elsif (prec.bom_sn_flag = MSC_UTIL.SYS_TGT) then
                -- do targeted for this entity
                p_cont_lrnn := -1;
                RETURN TRUE;
             else
                -- do nothing
                RETURN FALSE;
             end if;
         END IF;


         IF ( p_task_num = MSC_CL_PULL.TASK_BOR )  THEN
            if (prec.bor_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.bor_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;

         IF (p_task_num = MSC_CL_PULL.TASK_LOAD_FORECAST)  THEN
               -- both of the ones below will get executed
               -- LOAD_FORECASTS
               -- LOAD_ITEM_FORECASTS
            if (prec.fcst_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.fcst_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;


         IF ((p_task_num = MSC_CL_PULL.TASK_CATEGORY)  or
             (p_task_num = MSC_CL_PULL.TASK_ITEM1)     or
             (p_task_num = MSC_CL_PULL.TASK_ITEM2)     or
             (p_task_num = MSC_CL_PULL.TASK_ITEM3)     ) THEN

                 if (prec.item_sn_flag = MSC_UTIL.SYS_INCR) then
                      -- do net-change for this entity
                       p_cont_lrnn := p_lrnn;
                       RETURN TRUE;
                 elsif (prec.item_sn_flag = MSC_UTIL.SYS_TGT) then
                      -- do targeted for this entity
                       p_cont_lrnn := -1;
                       RETURN TRUE;
                 else
                      -- do nothing
                       RETURN FALSE;
                 end if;
         END IF;


         IF (p_task_num = MSC_CL_PULL.TASK_MDS_DEMAND)  THEN
            if (prec.mds_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.mds_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;


         IF (p_task_num = MSC_CL_PULL.TASK_MPS_SUPPLY) THEN
            if (prec.mps_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.mps_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;

         IF (p_task_num = MSC_CL_PULL.TASK_SCHEDULE) THEN
            if (prec.mds_sn_flag = MSC_UTIL.SYS_TGT) or (prec.mps_sn_flag = MSC_UTIL.SYS_TGT) THEN
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            elsif (prec.mds_sn_flag = MSC_UTIL.SYS_INCR) OR (prec.mps_sn_flag = MSC_UTIL.SYS_INCR) THEN
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;

         IF p_task_num = MSC_CL_PULL.TASK_OH_SUPPLY THEN
            if (prec.oh_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.oh_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;


        -- IF p_task_num = TASK_PO_SUPPLY THEN
         IF ((p_task_num = MSC_CL_PULL.TASK_PO_SUPPLY)	or
             (p_task_num = MSC_CL_PULL.TASK_PO_PO_SUPPLY)   or
             (p_task_num = MSC_CL_PULL.TASK_PO_REQ_SUPPLY))	THEN

            if (prec.po_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.po_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;


         IF p_task_num in (MSC_CL_PULL.TASK_SALES_ORDER1,MSC_CL_PULL.TASK_SALES_ORDER2,MSC_CL_PULL.TASK_SALES_ORDER3,MSC_CL_PULL.TASK_AHL) THEN
            if (prec.so_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.so_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;


         IF ((p_task_num = MSC_CL_PULL.TASK_USER_SUPPLY) OR (p_task_num = MSC_CL_PULL.TASK_USER_DEMAND))  THEN
            if (prec.usup_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.usup_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;


          -- FOR LOAD_WIP_SUPPLY
          -- FOR LOAD_WIP_DEMAND
         IF ( (p_task_num = MSC_CL_PULL.TASK_WIP_SUPPLY) OR
        	 (p_task_num = MSC_CL_PULL.TASK_WIP_DEMAND) ) THEN
            if (prec.wip_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.wip_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;

         IF (p_task_num = MSC_CL_PULL.TASK_RESOURCE) THEN
             if ( (prec.bom_sn_flag = MSC_UTIL.SYS_TGT)  or (prec.wip_sn_flag = MSC_UTIL.SYS_TGT) ) then
                -- do targeted for this entity
                p_cont_lrnn := -1;
                RETURN TRUE;
             elsif ( (prec.bom_sn_flag = MSC_UTIL.SYS_INCR)  or (prec.wip_sn_flag = MSC_UTIL.SYS_INCR) ) then
                -- do net-change for this entity
                p_cont_lrnn := p_lrnn;
                RETURN TRUE;
             else
                -- do nothing
                RETURN FALSE;
             end if;
         END IF;

	/* ds change start */
         IF (p_task_num = MSC_CL_PULL.TASK_RESOURCE_INSTANCE) THEN
             if ( (prec.bom_sn_flag = MSC_UTIL.SYS_TGT)  or (prec.wip_sn_flag = MSC_UTIL.SYS_TGT) ) then
                -- do targeted for this entity
                p_cont_lrnn := -1;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'TASK_RESOURCE_INSTANCE is targetted ');
                RETURN TRUE;
             elsif ( (prec.bom_sn_flag = MSC_UTIL.SYS_INCR)  or (prec.wip_sn_flag = MSC_UTIL.SYS_INCR) ) then
                -- do net-change for this entity
                p_cont_lrnn := p_lrnn;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'TASK_RESOURCE_INSTANCE is incremental ');
                RETURN TRUE;
             else
                -- do nothing
                RETURN FALSE;
             end if;
         END IF;

         IF (p_task_num = MSC_CL_PULL.TASK_RESOURCE_SETUP) THEN
	     IF (prec.bom_sn_flag = MSC_UTIL.SYS_TGT) THEN
                p_cont_lrnn := -1;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'TASK_RESOURCE_SETUP is targetted ');
                RETURN TRUE;
             ELSE
                RETURN FALSE;
	     END IF;
         END IF;

	/* ds change end */

         IF (p_task_num = MSC_CL_PULL.TASK_ATP_RULES) THEN
	     IF (prec.atp_rules_flag = MSC_UTIL.SYS_YES) THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
             ELSE
                RETURN FALSE;
	     END IF;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_CALENDAR_DATE )  THEN
              IF prec.calendar_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_DEMAND_CLASS )  THEN
              IF prec.demand_class_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_BIS )  THEN
              IF prec.kpi_bis_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_PARAMETER )  THEN
              IF prec.parameter_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_PLANNERS )  THEN
              IF prec.planner_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_PROJECT )  THEN
              IF prec.project_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_HARD_RESERVATION )  THEN
              IF prec.reserves_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_SAFETY_STOCK )  THEN
              IF prec.saf_stock_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_SOURCING )  THEN
              IF prec.sourcing_rule_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_SUB_INVENTORY )  THEN
              IF prec.sub_inventory_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF (p_task_num = MSC_CL_PULL.TASK_TRADING_PARTNER) OR (p_task_num = MSC_CL_PULL.TASK_BUYER_CONTACT)  THEN
              IF (prec.tp_customer_flag = MSC_UTIL.SYS_YES ) OR (prec.tp_vendor_flag = MSC_UTIL.SYS_YES) THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_UNIT_NUMBER )  THEN
              IF prec.unit_number_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_UOM )  THEN
              IF prec.uom_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_ITEM_SUBSTITUTES )  THEN
              IF prec.item_subst_flag = MSC_UTIL.SYS_YES THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_USER_COMPANY )  THEN
              IF (prec.user_company_flag = 2) OR (prec.user_company_flag = 3) THEN
                p_cont_lrnn := -1;
                RETURN TRUE;
              else
                RETURN FALSE;
             end if;
         END IF;

         /* CP-AUTO */
         IF ( p_task_num = MSC_CL_PULL.TASK_SUPPLIER_RESPONSE ) THEN

             if (prec.suprep_sn_flag = MSC_UTIL.SYS_INCR) then
                 -- do net-change for this entity
                 p_cont_lrnn := p_lrnn;

                 RETURN TRUE;
             elsif (prec.suprep_sn_flag = MSC_UTIL.SYS_TGT) then
                 -- do targeted for this entity
                 p_cont_lrnn := -1;

                 RETURN TRUE;
             else
                 -- do nothing
                 RETURN FALSE;
             end if;
         END IF;

         IF ( p_task_num = MSC_CL_PULL.TASK_TRIP ) THEN
            if (prec.trip_sn_flag = MSC_UTIL.SYS_INCR) then
               -- do net-change for this entity
               p_cont_lrnn := p_lrnn;
               RETURN TRUE;
            elsif (prec.trip_sn_flag = MSC_UTIL.SYS_TGT) then
               -- do targeted for this entity
               p_cont_lrnn := -1;
               RETURN TRUE;
            else
               -- do nothing
               RETURN FALSE;
            end if;
         END IF;

      RETURN FALSE;

   END set_cont_refresh_type;

--=========================================================================
    FUNCTION set_cont_refresh_type_ODS(p_task_num                 in NUMBER,
                                  prec                       in MSC_CL_EXCHANGE_PARTTBL.CollParamRec,
                                  p_is_incremental_refresh   out NOCOPY boolean,
                                  p_is_partial_refresh       out NOCOPY boolean,
				  p_exchange_mode            out NOCOPY number)
   RETURN BOOLEAN AS
   BEGIN

       p_is_incremental_refresh := FALSE;
       p_is_partial_refresh     := FALSE;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_SUPPLIER_CAPACITY) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.supcap_sn_flag = MSC_UTIL.SYS_INCR) then
             -- do net-change for this entity
             p_is_incremental_refresh := TRUE;
             p_is_partial_refresh     := FALSE;
	     p_exchange_mode          := MSC_UTIL.SYS_NO;
             RETURN TRUE;
          elsif (MSC_CL_COLLECTION.v_coll_prec.supcap_sn_flag = MSC_UTIL.SYS_TGT) then
             -- do targeted for this entity
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
	     p_exchange_mode          := MSC_UTIL.SYS_YES;
             RETURN TRUE;
          else
             -- do nothing
             RETURN FALSE;
          end if;

       END IF;

       if p_task_num in (MSC_CL_COLLECTION.PTASK_BOM_COMPONENTS,MSC_CL_COLLECTION.PTASK_BOM,MSC_CL_COLLECTION.PTASK_COMPONENT_SUBSTITUTE,MSC_CL_COLLECTION.PTASK_ROUTING,
                         MSC_CL_COLLECTION.PTASK_ROUTING_OPERATIONS,MSC_CL_COLLECTION.PTASK_OPERATION_RESOURCES,MSC_CL_COLLECTION.PTASK_RESOURCE,MSC_CL_COLLECTION.PTASK_OP_RESOURCE_SEQ,
			 MSC_CL_COLLECTION.PTASK_PROCESS_EFFECTIVITY,MSC_CL_COLLECTION.PTASK_OPERATION_COMPONENTS,MSC_CL_COLLECTION.PTASK_OPERATION_NETWORKS,
		  MSC_CL_COLLECTION.PTASK_RESOURCE_SETUP,MSC_CL_COLLECTION.PTASK_SETUP_TRANSITION,MSC_CL_COLLECTION.PTASK_STD_OP_RESOURCES) then   /* ds change */

          if (MSC_CL_COLLECTION.v_coll_prec.bom_sn_flag = MSC_UTIL.SYS_INCR) then
             -- do net-change for this entity
             p_is_incremental_refresh := TRUE;
             p_is_partial_refresh     := FALSE;
	     p_exchange_mode          := MSC_UTIL.SYS_NO;
	     MSC_CL_COLLECTION.v_bom_refresh_type       := 1;
             RETURN TRUE;
          elsif (MSC_CL_COLLECTION.v_coll_prec.bom_sn_flag = MSC_UTIL.SYS_TGT) then
             -- do targeted for this entity
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
	     p_exchange_mode          := MSC_UTIL.SYS_YES;
	     MSC_CL_COLLECTION.v_bom_refresh_type       := 2;
             RETURN TRUE;
          else
             -- do nothing
             MSC_CL_COLLECTION.v_bom_refresh_type       := 3;
             RETURN FALSE;
          end if;
       end if;
       -- grouping bor w/ the bom tasks
       IF (p_task_num = MSC_CL_COLLECTION.PTASK_BOR) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.bor_sn_flag = MSC_UTIL.SYS_INCR) then
             -- do net-change for this entity
             p_is_incremental_refresh := TRUE;
             p_is_partial_refresh     := FALSE;
	     p_exchange_mode          := MSC_UTIL.SYS_NO;
             RETURN TRUE;
          elsif (MSC_CL_COLLECTION.v_coll_prec.bor_sn_flag = MSC_UTIL.SYS_TGT) then
             -- do targeted for this entity
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
	     p_exchange_mode          := MSC_UTIL.SYS_YES;
             RETURN TRUE;
          else
             -- do nothing
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_FORECAST_DEMAND) THEN
--           (p_task_num = MSC_CL_COLLECTION.PTASK_FORECASTS) /*This will be done in launch_mon_partial*/
--           (p_task_num = MSC_CL_COLLECTION.PTASK_ODS_DEMAND)) /* this will be done in supply */
          if (MSC_CL_COLLECTION.v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_INCR) then
             -- do net-change for this entity
             p_is_incremental_refresh := TRUE;
             p_is_partial_refresh     := FALSE;
	     p_exchange_mode          := MSC_UTIL.SYS_NO;
             RETURN TRUE;
          elsif (MSC_CL_COLLECTION.v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_TGT) then
             -- do targeted for this entity
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
	     p_exchange_mode          := MSC_UTIL.SYS_YES;
             RETURN TRUE;
          else
             -- do nothing
             RETURN FALSE;
          end if;
       end if;
       IF ((p_task_num = MSC_CL_COLLECTION.PTASK_ITEM) or (p_task_num = MSC_CL_COLLECTION.PTASK_CATEGORY_ITEM)) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.item_sn_flag = MSC_UTIL.SYS_INCR) then
             -- do net-change for this entity
             p_is_incremental_refresh := TRUE;
             p_is_partial_refresh     := FALSE;
	     p_exchange_mode          := MSC_UTIL.SYS_NO;
             RETURN TRUE;
          elsif (MSC_CL_COLLECTION.v_coll_prec.item_sn_flag = MSC_UTIL.SYS_TGT) then
             -- do targeted for this entity
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
	     p_exchange_mode          := MSC_UTIL.SYS_YES;
             RETURN TRUE;
          else
           -- do nothing
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_MDS_DEMAND)  THEN
            ---- (p_task_num = PTASK_DESIGNATOR) or
            ---- Currently LOAD_DESIGNATOR called in the LAUNCH_MONITOR itself.
          if (MSC_CL_COLLECTION.v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_INCR) then
             -- do net-change for this entity
            p_is_incremental_refresh := TRUE;
             p_is_partial_refresh     := FALSE;
	     p_exchange_mode          := MSC_UTIL.SYS_NO;
            RETURN TRUE;
          elsif (MSC_CL_COLLECTION.v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_TGT) then
             -- do targeted for this entity
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
	     p_exchange_mode          := MSC_UTIL.SYS_YES;
             RETURN TRUE;
          else
             -- do nothing
             RETURN FALSE;
          end if;
       END IF;
/* supply is handled differently in execute_task_partial simply return true here */

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_SUPPLY) then
          RETURN TRUE;
       end if;

    /* If the Task is ODS_DEMAND, just retrun true since all the logic is in execute_part_task */
       IF ( p_task_num = MSC_CL_COLLECTION.PTASK_ODS_DEMAND ) THEN
             RETURN TRUE;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_NET_RESOURCE_AVAIL) THEN
          RETURN TRUE;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_TRADING_PARTNER)  THEN
          RETURN FALSE;  -- This will be done in Launch_mon_partial
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_UOM) THEN
          RETURN FALSE;  -- This will be done in Launch_mon_partial
       END IF;

	       IF (p_task_num = MSC_CL_COLLECTION.PTASK_SALES_ORDER) THEN
		  if (MSC_CL_COLLECTION.v_coll_prec.so_sn_flag = MSC_UTIL.SYS_TGT) then
		     -- do targeted for this entity
		     p_is_incremental_refresh := FALSE;
		     p_is_partial_refresh     := TRUE;
		     p_exchange_mode          := MSC_UTIL.SYS_YES;
		     RETURN TRUE;
		  else
		     -- do net-change for this entity
		     p_is_incremental_refresh := TRUE;
		     p_is_partial_refresh     := FALSE;
		     p_exchange_mode          := MSC_UTIL.SYS_NO;
		     RETURN TRUE;
		  end if;
	       END IF;

	       IF (p_task_num in ( MSC_CL_COLLECTION.PTASK_WIP_RES_REQ, MSC_CL_COLLECTION.PTASK_WIP_DEMAND,MSC_CL_COLLECTION.PTASK_RES_INST_REQ ) ) THEN
		  if (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_INCR) then
		     -- do net-change for this entity
		     p_is_incremental_refresh := TRUE;
		     p_is_partial_refresh     := FALSE;
		     p_exchange_mode          := MSC_UTIL.SYS_NO;
		     RETURN TRUE;
		  elsif (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) then
		     -- do targeted for this entity
		     p_is_incremental_refresh := FALSE;
		     p_is_partial_refresh     := TRUE;
		     p_exchange_mode          := MSC_UTIL.SYS_YES;
		     RETURN TRUE;
		  else
		     RETURN FALSE;
		  end if;
	       END IF;
       IF (p_task_num = MSC_CL_COLLECTION.PTASK_ATP_RULES) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.atp_rules_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_CALENDAR_DATE) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.calendar_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
            RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_DEMAND_CLASS) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.demand_class_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF ((p_task_num = MSC_CL_COLLECTION.PTASK_BIS_PFMC_MEASURES)  OR
           (p_task_num = MSC_CL_COLLECTION.PTASK_BIS_TARGET_LEVELS)  OR
           (p_task_num = MSC_CL_COLLECTION.PTASK_BIS_TARGETS      )  OR
           (p_task_num = MSC_CL_COLLECTION.PTASK_BIS_BUSINESS_PLANS) OR
           (p_task_num = MSC_CL_COLLECTION.PTASK_BIS_PERIODS      ) ) THEN
         IF MSC_CL_COLLECTION.v_coll_prec.kpi_bis_flag = MSC_UTIL.SYS_YES THEN
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_PARAMETER) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.parameter_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_PLANNERS) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.planner_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_PROJECT) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.project_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_HARD_RESERVATION) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.reserves_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_SAFETY_STOCK) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.saf_stock_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_SOURCING) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.sourcing_rule_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_SUB_INVENTORY) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.sub_inventory_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_UNIT_NUMBER) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.unit_number_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_ITEM_SUBSTITUTES) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.item_subst_flag = MSC_UTIL.SYS_YES) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

       IF (p_task_num = MSC_CL_COLLECTION.PTASK_COMPANY_USERS) THEN
          if (MSC_CL_COLLECTION.v_coll_prec.user_company_flag = MSC_UTIL.COMPANY_ONLY) OR
			(MSC_CL_COLLECTION.v_coll_prec.user_company_flag = MSC_UTIL.USER_AND_COMPANY) then
             p_is_incremental_refresh := FALSE;
             p_is_partial_refresh     := TRUE;
             RETURN TRUE;
          else
             RETURN FALSE;
          end if;
       END IF;

    RETURN FALSE;

   END set_cont_refresh_type_ODS;
--============================================================================
END MSC_CL_CONT_COLL_FW;

/

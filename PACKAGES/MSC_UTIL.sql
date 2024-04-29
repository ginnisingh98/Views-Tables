--------------------------------------------------------
--  DDL for Package MSC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCUTILS.pls 120.24.12010000.23 2015/06/17 01:47:53 zhilzhan ship $  */

   TYPE TblNmTblTyp IS TABLE OF VARCHAR2(30);


   G_MSC_DEBUG   VARCHAR2(1) := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

--   G_CMRO_EAM_INT_ENABLED VARCHAR2(1) := nvl(FND_PROFILE.Value('MSC_ASCP_IGNORE_CMRO_EAM_WO'),'N');       /* USAF */
/*   The below profile G_CMRO_EAM_INT_ENABLED is specific for USAF 12.2 code.
     G_CMRO_EAM_INT_ENABLED = 'Y', implies USAF code will take effect.
     G_CMRO_EAM_INT_ENABLED = 'N', implies USAF code will be turned OFF.
     We are reversing the value given in the profile as the profile name changed
     during the coding and the meaning now is reverse.
     Hence changing the value internally
*/

   G_CMRO_EAM_INT_ENABLED VARCHAR2(1) := CASE
                                         WHEN nvl(FND_PROFILE.Value('MSC_ASCP_IGNORE_CMRO_EAM_WO'),1) = 1 THEN 'N'
                                         ELSE 'Y'
                                         END ;

   G_EAM_CMRO_SUP_VER CONSTANT NUMBER := 5;  -- USAF Currently supports 12.1 and above

   /* Added for bug 10436070 */

   G_ITEMCAT_LEN NUMBER(3) := 250 ;

 ----- TESTING FLAG --------------------
   STATSQL                      CONSTANT BOOLEAN := FALSE;    -- static SQL

 ----- CONSTANTS --------------------------------------------------------

   TASK_COLL                      CONSTANT NUMBER := 1;
   TASK_RELEASE                   CONSTANT NUMBER := 2;
   TASK_USER_DEFINED              CONSTANT NUMBER := -1;


   DSCRETE_TYPE                 CONSTANT NUMBER := 1;
   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   ASL_SYS_NO                   CONSTANT NUMBER := 2;
   ASL_YES_RETAIN_CP            CONSTANT NUMBER := 3;
   ASL_YES                      CONSTANT NUMBER := 1;

   --MSC_DEBUG                    CONSTANT VARCHAR2(9) := 'MRP_DEBUG';

   G_NORMAL_COMPLETION		CONSTANT NUMBER := 1;
   G_PENDING_INACTIVE		CONSTANT NUMBER := 2;
   G_OTHERS			CONSTANT NUMBER := 3;

-- agmcont
   -- constants for continuous collections
   SYS_INCR                      CONSTANT NUMBER := 3; -- incr refresh
   SYS_TGT			 CONSTANT NUMBER := 4; -- targeted refresh


 ----- CONSTANTS FOR SCE -------------------------------------------------
   NO_USER_COMPANY				CONSTANT NUMBER := 1;
   COMPANY_ONLY					CONSTANT NUMBER := 2;
   USER_AND_COMPANY				CONSTANT NUMBER := 3;

   --- PREPLACE CHANGE START ---

   G_COMPLETE                   CONSTANT NUMBER := 1;
   G_INCREMENTAL                CONSTANT NUMBER := 2;
   G_PARTIAL                    CONSTANT NUMBER := 3;
   -- This constant should NEVER be used (see bug 17299275 for details):
   G_TARGETED                   CONSTANT NUMBER := 4;
-- agmcont:
   G_CONT                       CONSTANT NUMBER := 5;

  -- MRP constants --
   G_MDS                  CONSTANT NUMBER := 1;
   G_MPS                  CONSTANT NUMBER := 2;
   G_BOTH                 CONSTANT NUMBER := 3;

   ---  PREPLACE CHANGE END  ---

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   G_INS_DISCRETE               CONSTANT NUMBER := 1;
   G_INS_PROCESS                CONSTANT NUMBER := 2;
   G_INS_OTHER                  CONSTANT NUMBER := 3;
   G_INS_MIXED                  CONSTANT NUMBER := 4;

   -- STAGING TABLE STATUS --

   G_ST_EMPTY                   CONSTANT NUMBER := 0;   -- no instance data exists;
   G_ST_PULLING                 CONSTANT NUMBER := 1;
   G_ST_READY                   CONSTANT NUMBER := 2;
   G_ST_COLLECTING              CONSTANT NUMBER := 3;
   G_ST_PURGING                 CONSTANT NUMBER := 4;


   G_APPS107                    CONSTANT NUMBER := 1;
   G_APPS110                    CONSTANT NUMBER := 2;
   G_APPS115                    CONSTANT NUMBER := 3;
   G_APPS120                    CONSTANT NUMBER := 4;
   G_APPS121                    CONSTANT NUMBER := 5;
   G_APPS122                    CONSTANT NUMBER := 6;

  -- BOM ROUNDING DIRECTION --

   G_ROUND_DOWN                 CONSTANT NUMBER := 1;
   G_ROUND_UP                   CONSTANT NUMBER := 2;
   G_ROUND_NONE                 CONSTANT NUMBER := 3;

  -- SCE constants --
   G_CONF_APS             CONSTANT NUMBER := 1;
   G_CONF_APS_SCE         CONSTANT NUMBER := 2;
   G_CONF_SCE             CONSTANT NUMBER := 3;

   -- errors
   G_ERROR_STACK VARCHAR2(2000);

   G_ALL_ORGANIZATIONS          CONSTANT VARCHAR2(6):= '-999';

   v_in_org_str             VARCHAR2(32767):='NULL';
   v_in_all_org_str         VARCHAR2(32767):='NULL';

   v_depot_org_str          VARCHAR2(32767):='NULL';
   v_non_depot_org_str      VARCHAR2(32767):='NULL';

   v_ext_repair_sup_id_str          VARCHAR2(32767):='NULL';

   v_msc_tp_coll_window          NUMBER;
   v_msc_reg_zon_coll_window     NUMBER; -- BUG 15915083


   -- To collect SRP Data when this profile is set to Yes
   G_COLLECT_SRP_DATA       VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('MSC_SRP_ENABLED'),'N');

   -- To collect CMRO Data when this profile is set to Yes
   G_COLLECT_CMRO_DATA       VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('MSC_CMRO_WO_DEMAND_PS'),'N');

   /* IBUC - COLLECTION CHANGES
    To collect Install Base under Contracts when for the number of months , set in this profile  */

    G_COLLECT_IBUC_DATA NUMBER :=  NVL(FND_PROFILE.VALUE('MSC_COLL_TIME_WINDOW_IBUC_HISTORY'),12);
    G_COLLECT_SRP_PH2_ENABLE VARCHAR2(1):=  NVL(FND_PROFILE.VALUE('MSC_SRP_PH2_ENABLED'),'N');

   -- SCE Additions --
   /* SCE Change Starts */
   G_MSC_CONFIGURATION  VARCHAR2(10) := nvl(fnd_profile.value('MSC_X_CONFIGURATION'), G_CONF_APS);
   /* SCE Change Ends */
 -- Schemas
G_AHL_SCHEMA VARCHAR2(30);
G_INV_SCHEMA VARCHAR2(30);
G_BOM_SCHEMA VARCHAR2(30);
G_PO_SCHEMA  VARCHAR2(30);
G_WSH_SCHEMA VARCHAR2(30);
G_EAM_SCHEMA VARCHAR2(30);
G_ONT_SCHEMA VARCHAR2(30);
G_MRP_SCHEMA VARCHAR2(30);
G_WSM_SCHEMA VARCHAR2(30);
G_CSP_SCHEMA VARCHAR2(30);
G_WIP_SCHEMA VARCHAR2(30);
G_APPS_SCHEMA VARCHAR2(30);
G_CSD_SCHEMA VARCHAR2(30);
G_MSC_SCHEMA VARCHAR2(30);
G_FND_SCHEMA VARCHAR2(30);
--
   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';
   NULL_DATE             CONSTANT DATE:=   SYSDATE-36500;
   NULL_VALUE            CONSTANT NUMBER:= -23453;   -- null value for positive number
   NULL_CHAR             CONSTANT VARCHAR2(6):= '-23453';

   TYPE CollParamREC is RECORD (
        purge_ods_flag           NUMBER,
        app_supp_cap_flag        NUMBER,
        atp_rules_flag           NUMBER,
        bom_flag                 NUMBER,
        bor_flag                 NUMBER,
        calendar_flag            NUMBER,
        demand_class_flag        NUMBER,
        item_subst_flag          NUMBER,
        forecast_flag            NUMBER,
        item_flag                NUMBER,
        kpi_bis_flag             NUMBER,
        mds_flag                 NUMBER,
        mps_flag                 NUMBER,
        oh_flag                  NUMBER,
        parameter_flag           NUMBER,
        planner_flag             NUMBER,
        project_flag             NUMBER,
        po_flag                  NUMBER,
        reserves_flag            NUMBER,
        resource_nra_flag        NUMBER,
        saf_stock_flag           NUMBER,
        sales_order_flag         NUMBER,
        source_hist_flag         NUMBER,
        po_receipts_flag         NUMBER,
        sourcing_rule_flag       NUMBER,
        sub_inventory_flag       NUMBER,
        tp_customer_flag         NUMBER,
        tp_vendor_flag           NUMBER,
        unit_number_flag         NUMBER,
        uom_flag                 NUMBER,
        user_supply_demand_flag  NUMBER,
        wip_flag                 NUMBER,
	      user_company_flag        NUMBER,
-- agmcont
-- added for continuous collections
        bom_sn_flag              number,
        bor_sn_flag              number,
        item_sn_flag             number,
        oh_sn_flag               number,
        usup_sn_flag             number,
        udmd_sn_flag             number,
        so_sn_flag               number,
        fcst_sn_flag             number,
        wip_sn_flag              number,
        supcap_sn_flag           number,
        po_sn_flag               number,
        mds_sn_flag              number,
        mps_sn_flag              number,
        nosnap_flag              number,
		    /* CP-ACK starts */
		    supplier_response_flag   NUMBER,
		    /* CP-ACK ends */
		    /* CP-AUTO */
		    suprep_sn_flag           NUMBER,
		    org_group_flag           VARCHAR2(30),
		    threshold                NUMBER,
		    trip_flag                NUMBER,
		    trip_sn_flag             NUMBER,
		    ds_mode		               NUMBER,
		    sales_channel_flag       NUMBER,
		    fiscal_calendar_flag     NUMBER,
		    CMRO_flag                NUMBER,
		    internal_repair_flag     NUMBER,    -- Repair Orders Bug # 5909379
		    external_repair_flag     NUMBER,
        payback_demand_supply_flag NUMBER,
		    currency_conversion_flag   NUMBER, --bug # 6469722
		    delivery_details_flag	           NUMBER,
        ibuc_history_flag        NUMBER,
        notes_attach_flag        NUMBER,
        eAM_info_flag	NUMBER,                   /* USAF*/
        eAM_forecasts_flag	NUMBER,
        eam_fc_st_date	DATE,
        eam_fc_end_date	DATE,
        cmro_forecasts_flag	NUMBER,
        cmro_fc_st_date	DATE,
        cmro_fc_end_date	DATE,
        cmro_closed_wo NUMBER,
        ret_fcst_flag NUMBER, -- Returns Forecast bug 13861625
        osp_supply NUMBER
		    );



-- Global Variables for Good Bad Part  condition
G_PARTCONDN_ITEMTYPEID  NUMBER;
G_PARTCONDN_GOOD        NUMBER;
G_PARTCONDN_BAD         NUMBER;

G_CURRENT_SESSION_ID    NUMBER;
G_PERF_STAT_TRSHLD_TIME NUMBER := 5;

--Collections profile options
G_LVL_FATAL_ERR      CONSTANT NUMBER :=    1 ;
G_LVL_STATUS         CONSTANT NUMBER :=    2 ;
G_LVL_WARNING        CONSTANT NUMBER :=    4 ;
G_LVL_DEBUG_1        CONSTANT NUMBER :=    8 ;
G_LVL_DEBUG_2        CONSTANT NUMBER :=   16 ;
G_LVL_DEV            CONSTANT NUMBER :=   64 ;

G_LVL_PERFDBG_1      CONSTANT NUMBER :=  128 ;
G_LVL_PERFDBG_2      CONSTANT NUMBER :=  256 ;



--old status values are restored for backward compatibility.
 --avoid using these for any new development.
G_D_STATUS      CONSTANT NUMBER :=    2 ;
G_D_DEBUG_1     CONSTANT NUMBER :=    8 ;
G_D_DEBUG_2     CONSTANT NUMBER :=   16 ;
G_D_PERFDBG_1   CONSTANT NUMBER :=  128 ;
G_D_PERFDBG_2   CONSTANT NUMBER :=  256 ;

-- variable for MSC:Coll Err Debug and MSC:Coll Perf Debug profile options
G_CL_DEBUG  NUMBER :=   NVL(FND_PROFILE.Value('MSC_COLL_ERR_DEBUG' ), G_LVL_STATUS + G_LVL_WARNING )   --MSC:Coll Err Debug
                      + NVL(FND_PROFILE.Value('MSC_COLL_PERF_DEBUG'), 0)   --MSC:Coll Perf Debug profile
                      + G_LVL_FATAL_ERR ; --Manadtory level

-- NGOEL 11/29/2001, type defined for use in compare_index procedure for passing list of
-- columns in the specified index in the order of creation.

TYPE char30_arr IS TABLE OF varchar2(30);

--log collection messages based on the profiles set.
PROCEDURE LOG_MSG(
pType             IN         NUMBER,
buf               IN         VARCHAR2
);

FUNCTION Check_MSG_Level(pType IN  NUMBER) RETURN BOOLEAN;

PROCEDURE Print_Msg (buf IN  VARCHAR2);


PROCEDURE print_top_wait(pElaTime  NUMBER DEFAULT 0);
PROCEDURE print_cum_stat(pElaTime  NUMBER DEFAULT 0);
PROCEDURE print_bad_sqls(pElaTime  NUMBER DEFAULT 0);
PROCEDURE print_pull_params(pINSTANCE_ID IN NUMBER);
PROCEDURE print_ods_params(pRECALC_SH IN NUMBER, pPURGE_SH  IN NUMBER);
PROCEDURE print_trace_file_name(pReqID  NUMBER) ;

--add debug level to the existing debug status.
PROCEDURE MSC_SET_DEBUG_LEVEL(pType  IN   NUMBER);

-- log messaging if debug is turned on
PROCEDURE MSC_DEBUG(buf  IN  VARCHAR2);

-- log messaging irrespective of whether debug is turned on or off
PROCEDURE MSC_LOG(buf  IN  VARCHAR2);

-- out messaging
PROCEDURE MSC_OUT(buf IN VARCHAR2);


-- NGOEL 11/29/2001, used to detect changes in partitioned indexes as odf can handle them.
-- x_drop_index - If TRUE, means the existing index needs to be dropped before creation.
-- x_create_index - If TRUE, means the index needs to be created.

PROCEDURE COMPARE_INDEX(
p_table_name            IN              VARCHAR2,
p_index_name            IN              VARCHAR2,
p_column_list           IN              MSC_UTIL.char30_arr,
x_create_index          OUT             NOCOPY BOOLEAN,
x_partitioned           OUT             NOCOPY BOOLEAN
);

TYPE DbMessageRec is RECORD(
				msg_no        number ,
				msg_desc      varchar2(2000) ,
				package_name  varchar2(50) ,
				program_unit  varchar2(50)
                             );


TYPE DbMessageTabType IS TABLE OF DbMessageRec
  INDEX BY BINARY_INTEGER;

g_dbmessage  DbMessageTabType ;

PROCEDURE CREATE_SNAP_LOG( p_schema in VARCHAR2,
                           p_table  in VARCHAR2,
			   p_applsys_schema IN VARCHAR2);

PROCEDURE CREATE_SNAP_LOG( p_schema in VARCHAR2,
                           p_table  in VARCHAR2,
			                    p_applsys_schema IN VARCHAR2,
                          p_appl_id in number);

PROCEDURE GET_STORAGE_PARAMETERS( p_table_name       IN  VARCHAR2,
				  p_schema           IN  VARCHAR2,
				  v_table_space      OUT NOCOPY  VARCHAR2,
				  v_index_space      OUT NOCOPY  VARCHAR2,
				  v_storage_clause   OUT NOCOPY  VARCHAR2);

FUNCTION CREATE_SNAP (p_schema         IN VARCHAR2,
                      p_table          IN VARCHAR2,
                      p_object         IN VARCHAR2,
                      p_sql_stmt       IN VARCHAR2,
  		      p_applsys_schema IN VARCHAR2,
  		      p_logging        IN VARCHAR2 DEFAULT 'NOLOGGING',
  		      p_parallel_degree IN NUMBER DEFAULT 1,
            p_error IN VARCHAR2 DEFAULT NULL) /*6272589*/
RETURN BOOLEAN;

PROCEDURE CREATE_INDEX (p_schema         IN VARCHAR2,
                        p_sql_stmt       IN VARCHAR2,
                        p_object         IN VARCHAR2,
			p_applsys_schema IN VARCHAR2);

PROCEDURE DROP_INDEX (p_schema         IN VARCHAR2,
                      p_sql_stmt       IN VARCHAR2,
                      p_index          IN VARCHAR2,
                      p_table          IN VARCHAR2,
	              p_applsys_schema IN VARCHAR2);

FUNCTION  GET_SCHEMA_NAME( p_apps_id  IN NUMBER)
RETURN   VARCHAR2;

FUNCTION get_vmi_flag(var_plan_id IN NUMBER,
    			  var_sr_instance_id IN NUMBER,
    			  var_org_id IN NUMBER,
    			  var_inventory_item_id IN NUMBER,
    			  var_supplier_id IN NUMBER,
    			  var_supplier_site_id IN NUMBER) RETURN NUMBER;

FUNCTION Source_Instance_State(p_dblink varchar2)
return boolean;

/*
PROCEDURE debug_message( p_line_no in number ,
		         P_Line_msg in varchar2 ,
		         p_Package_name in varchar2 default null ,
		         P_Program_unit in varchar2 default null ,
			 P_Table_Name in varchar2 default 'DEBUG_DB_MESSAGES' ) ;

PROCEDURE init_message(P_Table_Name in varchar2 default 'DEBUG_DB_MESSAGES');
*/
PROCEDURE init_dbmessage ;

PROCEDURE set_dbmessage(p_msg in varchar2 ,
		        p_Package_name in varchar2 default null ,
		        P_Program_unit in varchar2 default null  ) ;

FUNCTION get_dbmessage return
		DbMessageTabType ;

FUNCTION MSC_NUMVAL(p_input varchar2)
return NUMBER;

FUNCTION GET_SERVICE_ITEMS_CATSET_ID  RETURN NUMBER  ;

FUNCTION is_app_installed(p_product IN NUMBER) RETURN BOOLEAN;

FUNCTION get_aps_config_level(p_sr_instance_id IN Number, p_dblink IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
-- Procedure to Initialize common global variables
PROCEDURE initialize_common_globals(pINSTANCE_ID  IN NUMBER);
FUNCTION mv_exists_in_schema(p_schema_name VARCHAR2, p_MV_name VARCHAR2)  RETURN BOOLEAN;
-- Procedure to execute any API given as parameter Bug 6469713
PROCEDURE EXECUTE_API(ERRBUF                   OUT NOCOPY VARCHAR2,
                      RETCODE                  OUT NOCOPY NUMBER,
                      p_package_name IN VARCHAR2,
                      p_proc_name IN VARCHAR2 ,
                      comma_sep_para_list IN VARCHAR2);
PROCEDURE DROP_WRONGSCHEMA_MVIEWS ;
PROCEDURE DROP_DEPRECATED_MVIEWS ;
PROCEDURE DROP_MVIEW_TRIGGERS(mview_owner IN VARCHAR2, mview_name IN VARCHAR2);
PROCEDURE DROP_MVIEW_SYNONYMS(mview_owner IN VARCHAR2, mview_name IN VARCHAR2);
PROCEDURE purge_dest_setup(p_instance_id IN NUMBER);

-- Omron bug 16390668
function mbs_ods_compatible return boolean;
-- Omron bug 16561317
function MSCPDX_compatible return boolean;
PROCEDURE allocate_unique(lock_name IN VARCHAR2,
                          lock_handle IN OUT NOCOPY VARCHAR2);
FUNCTION GET_LOCK(lock_handle IN OUT NOCOPY VARCHAR2) RETURN NUMBER;
FUNCTION RELEASE_LOCK(lock_handle IN OUT NOCOPY VARCHAR2) RETURN NUMBER;

END MSC_UTIL;

/

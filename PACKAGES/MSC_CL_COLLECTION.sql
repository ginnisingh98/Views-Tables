--------------------------------------------------------
--  DDL for Package MSC_CL_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_COLLECTION" AUTHID CURRENT_USER AS
/* $Header: MSCCLBAS.pls 120.14.12010000.4 2010/03/19 12:53:50 vsiyer ship $ */

  ----- ARRAY DATA TYPE --------------------------------------------------

   TYPE NumTblTyp IS TABLE OF NUMBER;
   TYPE TblLstTyp IS TABLE OF VARCHAR2(30);
 --------PROFILE OPTION VALUES ------------------------------------------
   v_inv_ctp_val NUMBER := NVL(FND_PROFILE.Value('INV_CTP'),0);
   G_MSC_DEBUG   VARCHAR2(1) := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');
   G_DEG_PARALLEL NUMBER := to_number(fnd_profile.value('MSC_INDEX_PARALLEL_THREADS') );

   --------Instance information ---------------
   v_instance_id                NUMBER;
   v_exchange_mode               NUMBER:= 2;  /* default to SYS_NO */
   v_instance_code              VARCHAR2(3);
   v_applsys_schema             VARCHAR2(32);
   v_so_exchange_mode            NUMBER:= 2;  /* default to SYS_NO */
   v_is_so_incremental_refresh   BOOLEAN;
   v_is_so_complete_refresh      BOOLEAN;
   v_last_collection_id          NUMBER;
   v_is_cont_refresh             BOOLEAN;
   v_is_incremental_refresh      BOOLEAN;
   v_is_complete_refresh         BOOLEAN;
   v_is_partial_refresh          BOOLEAN;
   v_apps_ver                   NUMBER;
   v_supply_id                  NUMBER ;
   v_source_organization_id     NUMBER ;
   v_source_sr_instance_id      NUMBER ;
     ---  PREPLACE CHANGE END  ---
   v_is_legacy_refresh           BOOLEAN:= FALSE;  -- change for legacy L Flow
    v_current_date                DATE;
    v_current_user                NUMBER;
    v_warning_flag                NUMBER:= 2;
--    v_in_org_str                  VARCHAR2(4000):='NULL';
    v_instance_type              NUMBER;

   v_chr10                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);
   v_chr13                       VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(13);
   v_sub_str                     VARCHAR2(32767):=NULL;
--   v_depot_org_str          VARCHAR2(15000):='NULL';
--   v_non_depot_org_str      VARCHAR2(15000):='NULL';
   G_COLLECT_SRP_DATA       VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('MSC_SRP_ENABLED'),'N');
   v_sourcing_flag               NUMBER;
   link_top_transaction_id_req   BOOLEAN := FALSE;
    G_MSC_CONFIGURATION 		VARCHAR2(240) := nvl(fnd_profile.value('MSC_X_CONFIGURATION'), 1);
    SUPPLIES_INDEX_FAIL           EXCEPTION;
     v_recalc_nra                  NUMBER;
    v_bom_refresh_type            NUMBER :=0;
    v_discrete_flag              NUMBER:= 2;
    v_process_flag               NUMBER:= MSC_UTIL.SYS_NO;
    v_my_company_name		  MSC_COMPANIES.COMPANY_NAME%TYPE;

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;
   v_DSMode                              NUMBER := 2;
   ASL_SYS_NO                   CONSTANT NUMBER := 2;
   ASL_YES_RETAIN_CP            CONSTANT NUMBER := 3;
   ASL_YES                      CONSTANT NUMBER := 1;
--agmcont
   SYS_INCR                     CONSTANT NUMBER := 3; -- incr refresh
   SYS_TGT                      CONSTANT NUMBER := 4; -- targeted refresh

   ------for Staging to ODS swap partition
   G_STG_ODS_SWP_PHASE_0         CONSTANT NUMBER:=0;    -- planning datapull/legacy load completed
   G_STG_ODS_SWP_PHASE_1         CONSTANT NUMBER:=1;    -- stg partn successfully swapped with temp tbl
   G_STG_ODS_SWP_PHASE_2         CONSTANT NUMBER:=2;    -- temp tbl successfully swapped with ODS partition

 ----- CONSTANTS FOR SCE -------------------------------------------------
	NO_USER_COMPANY              CONSTANT NUMBER := 1;
	COMPANY_ONLY                 CONSTANT NUMBER := 2;
	USER_AND_COMPANY             CONSTANT NUMBER := 3;


   G_JOB_DONE                     CONSTANT NUMBER := 1;
   G_JOB_NOT_DONE                 CONSTANT NUMBER := 2;
   G_JOB_ERROR                    CONSTANT NUMBER := 3;
   --- PREPLACE CHANGE START ---

   G_COMPLETE                   CONSTANT NUMBER := 1;
   G_INCREMENTAL                CONSTANT NUMBER := 2;
   G_PARTIAL                    CONSTANT NUMBER := 3;
-- agmcont
--   G_CONT                       CONSTANT NUMBER := 5;

   v_coll_prec                   MSC_CL_EXCHANGE_PARTTBL.CollParamREC;
   v_prec_defined                BOOLEAN := FALSE;

   ---  PREPLACE CHANGE END  ---

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   G_COLLECTION_PROGRAM         CONSTANT NUMBER := 1;
   G_PULL_PROGRAM               CONSTANT NUMBER := 2;

   G_APPS107             CONSTANT NUMBER := 1;
   G_APPS110             CONSTANT NUMBER := 2;
   G_APPS115             CONSTANT NUMBER := 3;
   G_APPS120             CONSTANT NUMBER := 4;

   G_INS_DISCRETE        CONSTANT NUMBER := 1;
   G_INS_PROCESS         CONSTANT NUMBER := 2;
   G_INS_OTHER           CONSTANT NUMBER := 3;
   G_INS_MIXED           CONSTANT NUMBER := 4;

   G_ST_EMPTY            CONSTANT NUMBER := 0;   -- no instance data exists;
   G_ST_PULLING          CONSTANT NUMBER := 1;
   G_ST_READY            CONSTANT NUMBER := 2;
   G_ST_COLLECTING       CONSTANT NUMBER := 3;
   G_ST_PURGING          CONSTANT NUMBER := 4;

   -- NULL VALUE USED IN THE WHERE CLAUSE

  -- NULL_DATE             CONSTANT DATE:=   SYSDATE-36500;
   --NULL_VALUE            CONSTANT NUMBER:= -23453;   -- null value for positive number
   --NULL_CHAR             CONSTANT VARCHAR2(6):= '-23453';
   --NULL_DBLINK           CONSTANT VARCHAR2(1):= ' ';

--   G_ALL_ORGANIZATIONS          CONSTANT VARCHAR2(6):= '-999';
   ALTER_TEMP_TABLE_ERROR	EXCEPTION;
   EXCHANGE_PARTN_ERROR	    EXCEPTION;


   -- ============ Task Control ================

   PIPE_TIME_OUT         CONSTANT NUMBER := 30;      -- 30 secs
   START_TIME            DATE;
   p_TIMEOUT		 NUMBER;

   -- ================== Worker Status ===================

   OK                    CONSTANT NUMBER := 1;
   FAIL                  CONSTANT NUMBER := 0;

   --  ================= Task Number ====================

   TASK_SUPPLY                    CONSTANT NUMBER :=  1; --B
   TASK_SOURCING                  CONSTANT NUMBER :=  2;
   TASK_ATP_RULES                 CONSTANT NUMBER :=  3;
   TASK_UNIT_NUMBER               CONSTANT NUMBER :=  4; --H
   TASK_BOM                       CONSTANT NUMBER :=  5; --D
   TASK_BOM_COMPONENTS            CONSTANT NUMBER :=  6;
   TASK_ROUTING                   CONSTANT NUMBER :=  7;
   TASK_OPERATION_COMPONENTS      CONSTANT NUMBER :=  8;
   TASK_OPERATION_NETWORKS        CONSTANT NUMBER :=  9;
   TASK_PROCESS_EFFECTIVITY       CONSTANT NUMBER := 10;
   TASK_OPERATION_RESOURCES       CONSTANT NUMBER := 11;
   TASK_COMPONENT_SUBSTITUTE      CONSTANT NUMBER := 12;
   TASK_OP_RESOURCE_SEQ           CONSTANT NUMBER := 13;
   TASK_ROUTING_OPERATIONS        CONSTANT NUMBER := 14;
   TASK_CALENDAR_DATE             CONSTANT NUMBER := 15; --E
   TASK_CATEGORY                  CONSTANT NUMBER := 16; --F
   TASK_ITEM                      CONSTANT NUMBER := 17; --G
   TASK_MDS_DEMAND                CONSTANT NUMBER := 18;
   TASK_ITEM_FORECASTS            CONSTANT NUMBER := 19;
   TASK_WIP_COMP_DEMAND           CONSTANT NUMBER := 20;
   TASK_RES_REQ                   CONSTANT NUMBER := 21;
   TASK_SALES_ORDER               CONSTANT NUMBER := 22; --C
   TASK_BIS_TARGETS               CONSTANT NUMBER := 23;
   TASK_PLANNERS                  CONSTANT NUMBER := 24;
   TASK_DEMAND_CLASS              CONSTANT NUMBER := 25;
   TASK_RESOURCE                  CONSTANT NUMBER := 26;
   TASK_SUB_INVENTORY             CONSTANT NUMBER := 27;
   TASK_HARD_RESERVATION          CONSTANT NUMBER := 28;
   TASK_NET_RESOURCE_AVAIL        CONSTANT NUMBER := 29;
   TASK_SUPPLIER_CAPACITY         CONSTANT NUMBER := 30;
   TASK_SAFETY_STOCK              CONSTANT NUMBER := 31;
   TASK_PROJECT                   CONSTANT NUMBER := 32;
   TASK_PARAMETER                 CONSTANT NUMBER := 33;
   TASK_BIS_PFMC_MEASURES         CONSTANT NUMBER := 34;
   TASK_ITEM_SUBSTITUTES          CONSTANT NUMBER := 35;
   /* SCE Change starts */
   TASK_ITEM_CUSTOMERS		  CONSTANT NUMBER := 36;
   TASK_COMPANY_USERS             CONSTANT NUMBER := 37;
   /* SCE Change Ends */
   TASK_BOR                       CONSTANT NUMBER := 38;
   TASK_BIS_TARGET_LEVELS         CONSTANT NUMBER := 39;
   TASK_BIS_BUSINESS_PLANS        CONSTANT NUMBER := 40;
   TASK_BIS_PERIODS               CONSTANT NUMBER := 41;
   TASK_ODS_DEMAND                CONSTANT NUMBER := 42;
   TASK_TRIP                      CONSTANT NUMBER := 43;
    --Added for the performance fix#3282638
   TASK_ABC_CLASSES               CONSTANT NUMBER := 44;

   /* ds change  start*/

   TASK_RES_INST_REQ		  CONSTANT NUMBER :=45;
   TASK_RESOURCE_SETUP		  CONSTANT NUMBER :=46;
   TASK_SETUP_TRANSITION	  CONSTANT NUMBER :=47;
   TASK_STD_OP_RESOURCES	  CONSTANT NUMBER :=48;

   TASK_SALES_CHANNEL	  CONSTANT NUMBER :=49;
   TASK_FISCAL_CALENDAR	  CONSTANT NUMBER :=50;

   TASK_IRO_DEMAND CONSTANT  NUMBER:=51;
   TASK_ERO_DEMAND CONSTANT  NUMBER:=52;

   TASK_PAYBACK_DEMAND_SUPPLY NUMBER:=53;
   TASK_CURRENCY_CONVERSION  CONSTANT  NUMBER   := 54; -- for bug # 6469722
   TASK_DELIVERY_DETAILS  CONSTANT  NUMBER   := 55; -- for bug # 6730983
   TASK_CMRO  CONSTANT  NUMBER   := 56;       --- CMRO
   TOTAL_TASK_NUMBER              CONSTANT NUMBER := 56;  -- Changed For bug 5935273 SRP Additions
  /* ds change end */

   UNRESOVLABLE_ERROR             CONSTANT NUMBER := -9999999;

   -- ================== SCE Related Data ==============
   G_MY_COMPANY_ID		  CONSTANT NUMBER := 1;
   G_SUPPLIER			  CONSTANT NUMBER := 1;
   G_CUSTOMER			  CONSTANT NUMBER := 2;
   G_ORGANIZATION		  CONSTANT NUMBER := 3;
--   G_CONF_APS			  CONSTANT NUMBER := 1;
--   G_CONF_APS_SCE		  CONSTANT NUMBER := 2;
--   G_CONF_SCE		  	  CONSTANT NUMBER := 3;

   /* CP-ACK change starts */
   G_MRP_PO_ACK           CONSTANT NUMBER := 49;
   /* CP-ACK change ends */

   /* CP-ACK change starts */
   TYPE_DAILY_BUCKET      CONSTANT NUMBER := 1;
   PROMISED_DATE_PREF     CONSTANT NUMBER := 1;
   NEED_BY_DATE_PREF      CONSTANT NUMBER := 2;
   /* CP-ACK change ends */

    -- ================== ATP Enhancement ==============

    G_TASK_ATP_RULES NUMBER :=0;
    G_TASK_SOURCING NUMBER :=0;

   --  ================= Procedures ====================
   PROCEDURE LAUNCH_WORKER(
                     ERRBUF				OUT NOCOPY VARCHAR2,
	             RETCODE				OUT NOCOPY NUMBER,
                     pMONITOR_REQUEST_ID                IN  NUMBER,
                     pINSTANCE_ID                       IN  NUMBER,
                     pLCID                              IN  NUMBER,
                     pTIMEOUT                           IN  NUMBER,
                     pRECALC_NRA                        IN  NUMBER,
                     pRECALC_SH                         IN  NUMBER,
                     pEXCHANGE_MODE                     IN  NUMBER,
                     pSO_EXCHANGE_MODE                  IN  NUMBER);

   PROCEDURE LAUNCH_MONITOR(
                      ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER,
                      pTIMEOUT                          IN  NUMBER,-- minutes
                      pTotalWorkerNum                   IN  NUMBER,
                      pRECALC_NRA                       IN  NUMBER,
                      pRECALC_SH                        IN  NUMBER,
                      pPURGE_SH                         IN  NUMBER,
                      pAPCC_refresh                     IN  NUMBER default MSC_UTIL.SYS_NO);

   PROCEDURE DELETE_PROCESS(
                      ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER);

   PROCEDURE alter_temp_table (ERRBUF		OUT NOCOPY VARCHAR2,
			                         RETCODE		OUT NOCOPY NUMBER,
                               p_part_table 	IN VARCHAR2,
                               p_instance_code 	IN VARCHAR2,
                               p_severity_level	IN NUMBER
                            )  ;

   PROCEDURE PURGE_STAGING_TABLES( ERRBUF               OUT NOCOPY VARCHAR2,
	                           RETCODE              OUT NOCOPY NUMBER,
                                   pINSTANCE_ID         IN  NUMBER,
                                   pVALIDATION          IN  NUMBER:=MSC_UTIL.SYS_YES);

   PROCEDURE PURGE_STAGING_TABLES_SUB( p_instance_id    IN  NUMBER);

   PROCEDURE GENERATE_ITEM_KEYS (ERRBUF		OUT NOCOPY VARCHAR2,
    			     RETCODE		OUT NOCOPY NUMBER,
                                 pINSTANCE_ID 	IN NUMBER);

   PROCEDURE GENERATE_TRADING_PARTNER_KEYS (ERRBUF	OUT NOCOPY VARCHAR2,
	    		     RETCODE		OUT NOCOPY NUMBER,
                              pINSTANCE_ID 	IN NUMBER);



  /* added this procedure for the conc program - Create Instance-Org Supplier Association
    This conc program updates the Msc_trading_partners table with the Modeleed Supplier info */

   PROCEDURE ENTER_MODELLED_INFO( ERRBUF               OUT NOCOPY VARCHAR2,
                                  RETCODE              OUT NOCOPY NUMBER,
                                  pINSTANCE_ID         IN  NUMBER,
                                  pDEST_PARTNER_ORG_ID IN  NUMBER,
                                  pSUPPLIER_ID         IN  NUMBER,
                                  pSUPPLIER_SITE_ID   IN  NUMBER,
                                  pACCEPT_DEMANDS_FROM_UNMET_PO IN NUMBER );


   PROCEDURE DELETE_MSC_TABLE( p_table_name            IN VARCHAR2,
                               p_instance_id           IN NUMBER,
                               p_plan_id               IN NUMBER:= NULL,
                               p_sub_str               IN VARCHAR2:= NULL) ;

  FUNCTION LAUNCH_MONITOR_CONT(
                      ERRBUF                            OUT NOCOPY VARCHAR2,
                      RETCODE                           OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER,
                      pTIMEOUT                          IN  NUMBER,-- minutes
                      pTotalWorkerNum                   IN  NUMBER,
                      pDSMode                           IN NUMBER default MSC_UTIL.SYS_NO,
                      pAPCC_refresh                     IN NUMBER default MSC_UTIL.SYS_NO)
 RETURN boolean;

   ------ NEW OBJECTS for PARTIAL REPLACEMENT ----

   /* ************************************************************
   Things that are always loaded in the current design
   for complete refershment are
   Load_Trading_Partner - Vendor and Customer info
   Load_Designator
   Load_Forecasts  - Loads into designator table
   Load_UOM
   Category_Sets   - via Transform_Keys.

   NOTE : Objects that do not take any parameter will not
          be loaded currently.
    ************************************************************ */

   PTASK_SUPPLY                    CONSTANT NUMBER :=  1;
       -- Used instead of PTASK_STAGING_SUPPLY and PTASK_ODS_SUPPLY below
   PTASK_SOURCING                  CONSTANT NUMBER :=  2;
   PTASK_ATP_RULES                 CONSTANT NUMBER :=  3;
   PTASK_WIP_SUPPLY                CONSTANT NUMBER :=  4;
   PTASK_PO_SUPPLY                 CONSTANT NUMBER :=  5;
   PTASK_OH_SUPPLY                 CONSTANT NUMBER :=  6;
   PTASK_MPS_SUPPLY                CONSTANT NUMBER :=  7;
   PTASK_STAGING_SUPPLY            CONSTANT NUMBER :=  8;
       -- Any of TASK_WIP_SUPPLY, TASK_PO_SUPPLY, TASK_OH_SUPPLY,
       -- TASK_MPS_SUPPLY should be equivalent to this
   PTASK_ODS_SUPPLY              CONSTANT NUMBER   :=  9;
       -- A separate procedure is necessary
       -- to get data from ODS to the temp table.
   PTASK_SALES_ORDER               CONSTANT NUMBER := 10; --C
   PTASK_BOM                       CONSTANT NUMBER := 11; --D
   PTASK_BOM_COMPONENTS            CONSTANT NUMBER := 12;
   PTASK_ROUTING                   CONSTANT NUMBER := 13;
   PTASK_OPERATION_COMPONENTS      CONSTANT NUMBER := 14;
   PTASK_OPERATION_NETWORKS        CONSTANT NUMBER := 15;
   PTASK_PROCESS_EFFECTIVITY       CONSTANT NUMBER := 16;
   PTASK_OPERATION_RESOURCES       CONSTANT NUMBER := 17;
   PTASK_COMPONENT_SUBSTITUTE      CONSTANT NUMBER := 18;
   PTASK_OP_RESOURCE_SEQ           CONSTANT NUMBER := 19;
   PTASK_ROUTING_OPERATIONS        CONSTANT NUMBER := 20;
   PTASK_ITEM                      CONSTANT NUMBER := 21; --G
   PTASK_CATEGORY_ITEM             CONSTANT NUMBER := 22; --F
   PTASK_WIP_RES_REQ               CONSTANT NUMBER := 23;
   PTASK_WIP_DEMAND                CONSTANT NUMBER := 24;
   PTASK_FORECASTS                 CONSTANT NUMBER := 25;
   PTASK_MDS_DEMAND                CONSTANT NUMBER := 26;
   PTASK_STAGING_DEMAND            CONSTANT NUMBER := 27;
       -- Any of TASK_WIP_DEMAND, TASK_FORECAST_DEMAND,
       -- TASK_MDS_DEMAND shoud be equivalent to this.
       -- Call LOAD_WIP_DEMAND, LOAD_ITEM_FORECASTS
       -- and LOAD_DEMAND accordingly.
   PTASK_ODS_DEMAND              CONSTANT NUMBER  :=  28;
       -- A separate procedure is necessary
       -- to get data from ODS to the temp table.
   PTASK_RESOURCE                  CONSTANT NUMBER := 29;
                 -- BOM parameter will be used here
   PTASK_HARD_RESERVATION          CONSTANT NUMBER := 30;
   PTASK_NET_RESOURCE_AVAIL        CONSTANT NUMBER := 31;
   PTASK_SUPPLIER_CAPACITY         CONSTANT NUMBER := 32;
                 -- Note that this does not depend on any snapshot to
                 -- be refreshed????  - Verify

   PTASK_SAFETY_STOCK              CONSTANT NUMBER := 33;
   PTASK_TRADING_PARTNER           CONSTANT NUMBER := 34;
   PTASK_UOM                       CONSTANT NUMBER := 35;

   PTASK_FORECAST_DEMAND           CONSTANT NUMBER := 36;
   PTASK_BOR                       CONSTANT NUMBER := 37;
   PTASK_CALENDAR_DATE             CONSTANT NUMBER := 38;
   PTASK_DEMAND_CLASS              CONSTANT NUMBER := 39;
   PTASK_DESIGNATOR                CONSTANT NUMBER := 40;
   PTASK_BIS_PFMC_MEASURES         CONSTANT NUMBER := 41;
   PTASK_BIS_TARGET_LEVELS         CONSTANT NUMBER := 42;
   PTASK_BIS_TARGETS               CONSTANT NUMBER := 43;
   PTASK_BIS_BUSINESS_PLANS        CONSTANT NUMBER := 44;
   PTASK_BIS_PERIODS               CONSTANT NUMBER := 45;
   PTASK_PARAMETER                 CONSTANT NUMBER := 46;
   PTASK_PLANNERS                  CONSTANT NUMBER := 47;
   PTASK_PROJECT                   CONSTANT NUMBER := 48;
   PTASK_SUB_INVENTORY             CONSTANT NUMBER := 49;
   PTASK_UNIT_NUMBER               CONSTANT NUMBER := 50;
     -- added this task for Prod substitution in Targeted Collections -----
   PTASK_ITEM_SUBSTITUTES          CONSTANT NUMBER := 51;

	 /* SCE Change starts */
 -- added this task for User - Company association in Targeted Collections --
   PTASK_COMPANY_USERS             CONSTANT NUMBER := 52;
   PTASK_ITEM_CUSTOMERS            CONSTANT NUMBER := 53;
   	 /* SCE Change ends */
   PTASK_TRIP                      CONSTANT NUMBER := 54;

   --Added for the performance fix#3282638
   PTASK_ABC_CLASSES               CONSTANT NUMBER := 55;
   /* ds change start */
   PTASK_RES_INST_REQ		  CONSTANT NUMBER :=56;
   PTASK_RESOURCE_SETUP		  CONSTANT NUMBER :=57;
   PTASK_SETUP_TRANSITION	  CONSTANT NUMBER :=58;
   PTASK_STD_OP_RESOURCES	  CONSTANT NUMBER :=59;
   /* ds change end */

   PTASK_SALES_CHANNEL	      CONSTANT NUMBER :=60;
   PTASK_FISCAL_CALENDAR	  CONSTANT NUMBER :=61;

   PTASK_IRO_DEMAND CONSTANT  NUMBER:=62;
   PTASK_ERO_DEMAND CONSTANT  NUMBER:=63;

   PTASK_PAYBACK_DEMAND_SUPPLY    NUMBER:=64;
   PTASK_CURRENCY_CONVERSION CONSTANT NUMBER:= 65; -- bug # 6469722
   PTASK_DELIVERY_DETAILS  CONSTANT  NUMBER   := 66; -- for bug # 6730983
   PTASK_CMRO  CONSTANT  NUMBER   := 67; -- for bug # 6730983
   TOTAL_PARTIAL_TASKS             CONSTANT NUMBER :=68;  -- CHanged for Bug 5935273 SRP Additions

   FUNCTION Q_PARTIAL_TASK (p_instance_id NUMBER,
                            p_task_num    NUMBER)
   RETURN BOOLEAN;

   PROCEDURE LOG_MESSAGE(pSOURCE                 IN  NUMBER,
				 pID                     IN  NUMBER,
				 pCREATION_DATE          IN  DATE,
				 pMTYPE                  IN  NUMBER,
				 pERRBUF                 IN  VARCHAR2);

	 PROCEDURE LOG_MESSAGE(pSOURCE                 IN  NUMBER,
				 pID                     IN  NUMBER,
				 pCREATION_DATE          IN  DATE,
				 pMTYPE                  IN  NUMBER,
				 pPROCEDURE_NAME         IN  VARCHAR2,
				 pEXCEPTION_TYPE         IN  VARCHAR2 := NULL,
				 pSEGMENT1               IN  VARCHAR2 := NULL,
				 pSEGMENT2               IN  VARCHAR2 := NULL,
				 pSEGMENT3               IN  VARCHAR2 := NULL,
				 pSEGMENT4               IN  VARCHAR2 := NULL,
				 pSEGMENT5               IN  VARCHAR2 := NULL,
				 pSEGMENT6               IN  VARCHAR2 := NULL,
				 pSEGMENT7               IN  VARCHAR2 := NULL,
				 pSEGMENT8               IN  VARCHAR2 := NULL,
				 pSEGMENT9               IN  VARCHAR2 := NULL,
				 pSEGMENT10              IN  VARCHAR2 := NULL);

   PROCEDURE LAUNCH_MON_PARTIAL(
                      ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pINSTANCE_ID                      IN  NUMBER,
                      pTIMEOUT                          IN  NUMBER,-- minutes
                      pTotalWorkerNum                   IN  NUMBER,
                      pRECALC_NRA                       IN  NUMBER,
                      pRECALC_SH                        IN  NUMBER,
                      pPURGE_SH                         IN  NUMBER,
                      pAPCC_refresh                     IN  NUMBER default MSC_UTIL.SYS_NO);


-- agmcont:

-- PROCEDURE PURGE_STAGING_TABLES_TRNC(p_instance_id    IN  NUMBER) ;
-- PROCEDURE PURGE_STAGING_TABLES_DEL( p_instance_id     IN  NUMBER);
 PROCEDURE TRUNCATE_MSC_TABLE(p_table_name  IN VARCHAR2) ;
/* ds change: */
PROCEDURE LAUNCH_MONITOR_DET_SCH( ERRBUF                     OUT NOCOPY VARCHAR2,
                              RETCODE                           OUT NOCOPY NUMBER,
                              pINSTANCE_ID                      IN  NUMBER,
                              pTIMEOUT                          IN  NUMBER,
                              pTotalWorkerNum                   IN  NUMBER,
                              pRECALC_NRA                       IN  NUMBER,
                              pAPCC_refresh                     IN NUMBER default MSC_UTIL.SYS_NO);


 FUNCTION is_msctbl_partitioned ( p_table_name  IN  VARCHAR2)  RETURN BOOLEAN ;

 --FUNCTION ITEM_NAME ( p_item_id                          IN NUMBER) RETURN VARCHAR2;
 PBS      NUMBER;   /* purge batch size */
  --PROCEDURE LOG_DEBUG(  pBUFF                     IN  VARCHAR2);
  --PROCEDURE LOG_MESSAGE(  pBUFF   IN  VARCHAR2);



--	PROCEDURE LOAD_RESOURCE;
--	PROCEDURE LOAD_RES_INST_CHANGE;

   PROCEDURE INITIALIZE( pINSTANCE_ID NUMBER);
--   PROCEDURE INITIALIZE_PULL_GLOBALS( pINSTANCE_ID       IN NUMBER);
   PROCEDURE INITIALIZE_LOAD_GLOBALS( pINSTANCE_ID       IN NUMBER);
   PROCEDURE  COMPUTE_RES_AVAIL (ERRBUF               OUT NOCOPY VARCHAR2,
                             RETCODE              OUT NOCOPY NUMBER,
                             pINSTANCE_ID         IN  NUMBER,
                             pSTART_DATE          IN  VARCHAR2);

END MSC_CL_COLLECTION;

/

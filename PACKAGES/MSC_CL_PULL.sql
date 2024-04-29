--------------------------------------------------------
--  DDL for Package MSC_CL_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PULL" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCLFAS.pls 120.14 2008/01/07 18:56:59 vpalla ship $ */

 --  SYS_YES                       NUMBER := MSC_UTIL.SYS_YES;
 --  SYS_NO                        NUMBER := MSC_UTIL.SYS_NO   ;

  -- SYS_INCR                      NUMBER := MSC_UTIL.SYS_INCR; -- incr refresh
  -- SYS_TGT                       NUMBER := MSC_UTIL.SYS_TGT; -- targeted refresh

  -- G_SUCCESS                     NUMBER := MSC_UTIL.G_SUCCESS;
   --G_WARNING                     NUMBER := MSC_UTIL.G_WARNING;
   --G_ERROR                       NUMBER := MSC_UTIL.G_ERROR  ;

   --G_COMPLETE                   CONSTANT NUMBER := MSC_UTIL.G_COMPLETE   ;
  -- G_INCREMENTAL                CONSTANT NUMBER := MSC_UTIL.G_INCREMENTAL;
  -- G_PARTIAL                    CONSTANT NUMBER := MSC_UTIL.G_PARTIAL    ;
  -- G_TARGETED                   CONSTANT NUMBER := MSC_UTIL.G_TARGETED   ;
-- agmcont:
 --  G_CONT                       CONSTANT NUMBER := MSC_UTIL.G_CONT       ;

  -- G_ST_EMPTY              CONSTANT NUMBER := MSC_UTIL.G_ST_EMPTY     ;
  -- G_ST_PULLING            CONSTANT NUMBER := MSC_UTIL.G_ST_PULLING   ;
  -- G_ST_READY              CONSTANT NUMBER := MSC_UTIL.G_ST_READY     ;
  -- G_ST_COLLECTING         CONSTANT NUMBER := MSC_UTIL.G_ST_COLLECTING;
  -- G_ST_PURGING            CONSTANT NUMBER := MSC_UTIL.G_ST_PURGING   ;

  -- G_APPS107                     NUMBER := MSC_UTIL.G_APPS107;
 --  G_APPS110                     NUMBER := MSC_UTIL.G_APPS110;
 --  G_APPS115                     NUMBER := MSC_UTIL.G_APPS115;
 --  G_APPS120                     NUMBER := MSC_UTIL.G_APPS120;

   --G_ALL_ORGANIZATIONS     CONSTANT NUMBER := MSC_UTIL.G_ALL_ORGANIZATIONS;

  -- added for process mfg: OPM
   v_delimiter                   CONSTANT VARCHAR2(1) := '/';
   v_discrete_flag               NUMBER;
   v_process_flag                NUMBER;

 ----- PROFILE OPTION --------------------------------------------------

   v_so_ship_arrive_value          NUMBER;
   v_mps_consume_profile_value     NUMBER;
   v_spread_load                   NUMBER;
   v_hour_uom                      VARCHAR2(3);
   v_lang                          VARCHAR2(4);
   v_oe_install                    VARCHAR2(170);

 ----- PARAMETERS --------------------------------------------------------


   v_lrnn                        NUMBER;   -- Last Refresh Number
   v_lrn                         VARCHAR2(38);
   v_so_lrn                     NUMBER;    -- Last Refresh Number(Sales Orders)
   v_crn                        NUMBER;    -- Current Refresh Number
   v_validation_org_id          NUMBER;
   v_refresh_id                 NUMBER;

   v_apps_ver                   NUMBER;
   v_instance_id                NUMBER;
   v_instance_type              NUMBER;

   v_instance_code              VARCHAR2(10);
   v_dest_a2m                   VARCHAR2(128);

   v_debug                      BOOLEAN := FALSE;
   v_DSMode			NUMBER;

                 -- MSC_UTIL.SYS_YES: This program is launched as a concurrent program.



   v_icode                       VARCHAR2(4);   -- INSTANCE CODE


   v_current_date                DATE;
   v_current_user                NUMBER;

   v_dblink                      VARCHAR2(128);
   v_dgmt                        NUMBER;    -- Time difference to GMT ( unit: Days);

   v_debug                       BOOLEAN := FALSE;

   v_org_group              VARCHAR2(30);

-- agmcont: add flag to indicate we are doing cont refresh
   v_is_cont_refresh            number := MSC_UTIL.SYS_NO;
   V_IS_PARTIAL_REFRESH         number := MSC_UTIL.SYS_NO;
   v_cont_coll_thresh           number;
   v_cont_coll_freq             number;


   -- Task Control --

   v_pipe_task_que              VARCHAR2(32);
   v_pipe_wm                    VARCHAR2(32);
   v_pipe_mw                    VARCHAR2(32);
   v_pipe_status                VARCHAR2(32);


   v_table_name             VARCHAR2(32);
   v_view_name              VARCHAR2(32);

   v_distributed_config_flag    NUMBER;
   v_monitor_request_id         NUMBER;

 ----- MSC PROFILE OPTION --------------------------------------------------

   G_COLLECT_ITEM_COSTS     varchar2(1) := NVL(FND_PROFILE.VALUE('MSC_COLLECT_COSTS_FOR_ITEM'),'Y');


   v_mso_item_dmd_penalty         NUMBER;
   v_mso_item_cap_penalty         NUMBER;
   v_mso_org_dmd_penalty          NUMBER;
   v_mso_org_item_penalty         NUMBER;
   v_mso_org_res_penalty          NUMBER;
   v_mso_org_trsp_penalty         NUMBER;
   v_msc_aggreg_res_name          NUMBER;
   v_mso_res_penalty              NUMBER;
   v_mso_sup_cap_penalty          NUMBER;
   v_msc_bom_subst_priority       NUMBER;
   v_mso_trsp_penalty             NUMBER;
   v_msc_alt_bom_cost             NUMBER;
   v_mso_fcst_penalty             NUMBER;
   v_mso_so_penalty               NUMBER;
   v_msc_alt_op_res               NUMBER;
   v_msc_alt_res_priority         NUMBER;
   v_msc_batchable_flag           NUMBER;
   v_msc_batching_window          NUMBER;
   v_msc_min_capacity             NUMBER;
   v_msc_max_capacity             NUMBER;
   v_msc_unit_of_measure           NUMBER;
   v_msc_simul_res_seq            NUMBER;
   v_mrp_bis_av_discount          NUMBER;
   v_mrp_bis_price_list           NUMBER;
   v_msc_dmd_priority_flex_num    NUMBER;
   v_msc_fcst_priority_flex_num   NUMBER;
--   v_msc_hub_curr_code            VARCHAR2(30); -- bug # 6469722
 --  v_msc_curr_conv_type           VARCHAR2(30);
 --  v_msc_future_days		  NUMBER;
--   v_msc_past_days		  NUMBER;

   v_collect_completed_jobs   number;
   v_schedule_flag                NUMBER;

 ----- FLAGS -----------------------------------------------------------

   ITEM_ENABLED                 NUMBER;    -- ITEM, CATEGORY
   VENDOR_ENABLED               NUMBER;
   FORECAST_ENABLED             NUMBER;
   CUSTOMER_ENABLED             NUMBER;
   BOM_ENABLED                  NUMBER;
   HARD_RESRVS_ENABLED          NUMBER;
   SOURCING_ENABLED             NUMBER;    -- SOURCING, INTER_ORG_SHIPMENT
   WIP_ENABLED                  NUMBER;
   SS_ENABLED                   NUMBER;
   PO_ENABLED                   NUMBER;    -- PO, INTRANSIT
   ITEM_SUBST_ENABLED           NUMBER;
   OH_ENABLED                   NUMBER;
   SUPPLIER_CAP_ENABLED         NUMBER;
   UOM_ENABLED                  NUMBER;
   MDS_ENABLED                  NUMBER;
   MPS_ENABLED                  NUMBER;
   NRA_ENABLED                  NUMBER;
   SH_ENABLED                   NUMBER;    -- sourcing history
   TRIP_ENABLED                 NUMBER;
   PO_RECEIPTS_ENABLED          NUMBER;
   INTERNAL_REPAIR_ENABLED      NUMBER;    -- For Bug 5909379
   EXTERNAL_REPAIR_ENABLED      NUMBER;     -- For Bug 5935273
 ----- FLAGS ADDED FOR SCE ---------------------------------------
   USER_COMPANY_ENABLED			NUMBER;
   /* CP-ACK starts */
   SUPPLIER_RESPONSE_ENABLED    NUMBER;
   /* CP-ACK ends */


 ----- WORKER STATUS ---------------------------------------------

   OK           CONSTANT NUMBER := 1;
   FAIL         CONSTANT NUMBER := 0;

 ----- TASK NUMBR -----------------------------------
 ----- Assign a lower number to the task whose load is higher.

        TOTAL_IWN              CONSTANT NUMBER :=  3;

        TASK_ITEM1             CONSTANT NUMBER :=  1;
        TASK_ITEM2             CONSTANT NUMBER :=  2;
        TASK_ITEM3             CONSTANT NUMBER :=  3;
        TASK_OPER_NETWORKS     CONSTANT NUMBER := 4;
        TASK_ROUTING_OPERATIONS CONSTANT NUMBER := 5;
        TASK_OPERATION_RES_SEQS CONSTANT NUMBER := 6;
        TASK_OPERATION_RESOURCES CONSTANT NUMBER := 7;
        TASK_OPERATION_COMPONENTS CONSTANT NUMBER := 8;
        TASK_PROCESS_EFFECTIVITY  CONSTANT NUMBER := 9;
        TASK_SALES_ORDER1      CONSTANT NUMBER := 10;
        TASK_SALES_ORDER2      CONSTANT NUMBER := 11;
        TASK_BOM               CONSTANT NUMBER := 12;
        TASK_ROUTING           CONSTANT NUMBER := 13;
        TASK_CALENDAR_DATE     CONSTANT NUMBER := 14;
        TASK_MDS_DEMAND        CONSTANT NUMBER :=  15;
        TASK_WIP_DEMAND        CONSTANT NUMBER :=  16;
        TASK_TRADING_PARTNER   CONSTANT NUMBER := 17;
        TASK_SUB_INVENTORY     CONSTANT NUMBER := 18;
        TASK_HARD_RESERVATION  CONSTANT NUMBER := 19;
        TASK_SOURCING          CONSTANT NUMBER := 20;
        TASK_SUPPLIER_CAPACITY CONSTANT NUMBER := 21;
        TASK_CATEGORY          CONSTANT NUMBER := 22;
        TASK_BOR               CONSTANT NUMBER := 23;
        TASK_UNIT_NUMBER       CONSTANT NUMBER := 24;
        TASK_SAFETY_STOCK      CONSTANT NUMBER := 25;
        TASK_PROJECT           CONSTANT NUMBER := 26;
        TASK_PARAMETER         CONSTANT NUMBER := 27;
        TASK_UOM               CONSTANT NUMBER := 28;
        TASK_ATP_RULES         CONSTANT NUMBER := 29;
        TASK_SALES_ORDER3      CONSTANT NUMBER := 30;
    --    TASK_SALES_ORDER       CONSTANT NUMBER := 31;
        TASK_PLANNERS          CONSTANT NUMBER := 31;
        TASK_DEMAND_CLASS      CONSTANT NUMBER := 32;
        TASK_BUYER_CONTACT     CONSTANT NUMBER := 33;
        TASK_LOAD_FORECAST     CONSTANT NUMBER := 34;
        TASK_PO_SUPPLY         CONSTANT NUMBER :=  35;
        TASK_WIP_SUPPLY        CONSTANT NUMBER :=  36;
        TASK_OH_SUPPLY         CONSTANT NUMBER :=  37;
        TASK_MPS_SUPPLY        CONSTANT NUMBER :=  38;
        TASK_SCHEDULE          CONSTANT NUMBER := 39;
        TASK_RESOURCE          CONSTANT NUMBER := 40;
        -- New task added for Product Substitution ---
        TASK_ITEM_SUBSTITUTES  CONSTANT NUMBER := 41;

        -- New SCE tasks --
    	  TASK_USER_COMPANY CONSTANT NUMBER := 42;

		/* CP-ACK starts */
		TASK_SUPPLIER_RESPONSE CONSTANT NUMBER := 43;
		/* CP-ACK ends */
        TASK_BIS               CONSTANT NUMBER := 44;
        TASK_USER_SUPPLY       CONSTANT NUMBER := 45;
        TASK_USER_DEMAND       CONSTANT NUMBER := 46;
        TASK_TRIP              CONSTANT NUMBER := 47;

        /* AHL Visits - Modelled as Sales Orders */
        TASK_AHL       CONSTANT NUMBER := 48;

        /*ds_plan: change start */
        TASK_RESOURCE_INSTANCE  CONSTANT  NUMBER   := 49;
        TASK_RESOURCE_SETUP  CONSTANT  NUMBER   := 50;
        /*ds_plan: change end */

        TASK_PO_PO_SUPPLY        CONSTANT NUMBER := 51;
        TASK_PO_REQ_SUPPLY	 CONSTANT NUMBER := 52;
        TASK_ABC_CLASSES     CONSTANT NUMBER :=53;

        TASK_SALES_CHANNEL  CONSTANT  NUMBER   := 54;
        TASK_FISCAL_CALENDAR  CONSTANT  NUMBER   := 55;

        /* For SRP Collection Of Repair Order Data bug# 5909379*/
        TASK_IRO  CONSTANT  NUMBER:=56 ;
        TASK_IRO_DEMAND CONSTANT  NUMBER:=57;

        TASK_ERO  CONSTANT  NUMBER:=58 ;
        TASK_ERO_DEMAND CONSTANT  NUMBER:=59;

        TASK_PAYBACK_DEMAND_SUPPLY NUMBER:=60;
       	TASK_CURRENCY_CONVERSION  CONSTANT  NUMBER := 61; -- bug # 6469722
        TASK_DELIVERY_DETAILS  CONSTANT  NUMBER := 62;

        TOTAL_TASK_NUMBER      CONSTANT NUMBER := 63;

   -- Misc --
   PIPE_TIME_OUT                CONSTANT NUMBER := 30;          -- 30 secs

  ---------------------- Task Number ----------------------------

   UNRESOLVABLE_ERROR           CONSTANT NUMBER := -9999999;
   START_ODS_LOAD               CONSTANT NUMBER := -1111111; -- const to start the ODS monitor/worker

  ----------------- Array Data Types -----------------------
   TYPE NumTblTyp IS TABLE OF NUMBER;

  ----------------- Added For Bug 6126698 and 6144734 ------------------
   g_last_succ_iro_ref_time  DATE;
   g_LAST_SUCC_RES_REF_TIME   DATE;


   --  ================= Procedures ====================
   PROCEDURE LAUNCH_WORKER(
               ERRBUF				 OUT NOCOPY VARCHAR2,
	       RETCODE				 OUT NOCOPY NUMBER,
               pMONITOR_REQUEST_ID                IN  NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pTIMEOUT                           IN  NUMBER,
               pLANG                              IN  VARCHAR2 := NULL,
               pRTYPE                             IN  NUMBER,
               pREFRESH_ID                        IN  NUMBER,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
               pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPO_RECEIPTS_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_NO,
			   pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
			   /* CP-ACK changes start */
			   pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
			   /* CP-ACK changes end */
			         pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES
               );

   PROCEDURE LAUNCH_MONITOR(
               ERRBUF				 OUT NOCOPY VARCHAR2,
	       RETCODE				 OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER, -- min
               pLANG                              IN  VARCHAR2  := NULL,
               pOdsPURGEoption                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pRTYPE                             IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPO_RECEIPTS_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_NO,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
               pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
			   /* CP-ACK starts */
			   pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
			   /* CP-ACK ends */
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
			         pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSALES_CHANNEL_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFISCAL_CALENDAR_ENABLED           IN  NUMBER    := MSC_UTIL.SYS_YES,
               pINTERNAL_REPAIR_ENABLED           IN  NUMBER    := MSC_UTIL.SYS_YES,  -- for bug 5909379
               pEXTERNAL_REPAIR_ENABLED           IN  NUMBER    := MSC_UTIL.SYS_YES,  -- for bug 5909379
               pPAYBACK_DEMAND_SUPPLY_ENABLED     IN  NUMBER    := MSC_UTIL.SYS_NO,
               pCURRENCY_CONVERSION_ENABLED	      IN  NUMBER    := MSC_UTIL.SYS_NO,    -- for bug 6469722
               pDELIVERY_DETAILS_ENABLED           IN NUMBER   := MSC_UTIL.SYS_NO      -- for bug 6730983
               );

-- agmcont
-- Entry point for continuous collections

   PROCEDURE LAUNCH_MONITOR_CONT(
               ERRBUF				 OUT NOCOPY VARCHAR2,
	       RETCODE				 OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER, -- min
               pLANG                              IN  VARCHAR2  := NULL,
--               pOdsPURGEoption                    IN  NUMBER    := SYS_NO,
--               pRTYPE                             IN  NUMBER,
               pTHRESH                            IN  NUMBER,
               pFREQ                              IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
			         pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
			         pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
	       pPO_RECEIPTS_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_NO,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
	             pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES

               );

   PROCEDURE LAUNCH_WORKER_CONT(
               ERRBUF				 OUT NOCOPY VARCHAR2,
	       RETCODE				 OUT NOCOPY NUMBER,
	       pMONITOR_REQUEST_ID                IN  NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pTIMEOUT                           IN  NUMBER,
               pLANG                              IN  VARCHAR2 := NULL,
               pRTYPE                             IN  NUMBER,
               pREFRESH_ID                        IN  NUMBER,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER,
               pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               /* CP-ACK changes start */
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_NO,
               /* CP-ACK changes end */
               pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPO_RECEIPTS_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_NO
               );

PROCEDURE LAUNCH_MONITOR_CONT_DET_SCH(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER, -- min
               pLANG                              IN  VARCHAR2  := NULL,
               pTHRESH                            IN  NUMBER,
               pFREQ                              IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pBOR_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pFORECAST_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pMDS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                  IN  NUMBER	:= MSC_UTIL.SYS_YES,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pTRIP_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_SUPPLY_DEMAND                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pATP_RULES_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pITEM_SUBST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED             IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSOURCING_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSUB_INV_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES
               --pUSER_COMPANY_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES
               );



   PROCEDURE DELETE_PROCESS
                    ( ERRBUF				 OUT NOCOPY VARCHAR2,
	              RETCODE				 OUT NOCOPY NUMBER,
                      pINSTANCE_ID                       IN  NUMBER);

PROCEDURE SALES_ORDER_REFRESH_TYPE ( p_instance_id in NUMBER,
                                     so_sn_flag out NOCOPY NUMBER );

FUNCTION GET_ORG_STR(p_instance_id IN NUMBER, p_type IN NUMBER DEFAULT 2)
 RETURN VARCHAR2;


PROCEDURE GET_DEPOT_ORG_STRINGS(p_instance_id IN NUMBER);


FUNCTION GET_ORG_STR RETURN VARCHAR2;

/* ds_plan: change start */

PROCEDURE LAUNCH_MONITOR_DET_SCH(
               ERRBUF                            OUT NOCOPY VARCHAR2,
               RETCODE                           OUT NOCOPY NUMBER,
               pINSTANCE_ID                       IN  NUMBER,
               pORG_GROUP                         IN  VARCHAR2,
               pTotalWorkerNum                    IN  NUMBER,
               pTIMEOUT                           IN  NUMBER,
               pLANG                              IN  VARCHAR2  := NULL,
               pOdsPURGEoption                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pRTYPE                             IN  NUMBER,
               pANATBL_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_NO,
               pAPPROV_SUPPLIER_CAP_ENABLED       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pATP_RULES_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pBOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pBOR_ENABLED                     IN  NUMBER    := MSC_UTIL.SYS_YES,
               pCALENDAR_ENABLED                  IN  NUMBER    := MSC_UTIL.SYS_YES,
               pDEMAND_CLASS_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pITEM_SUBST_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pFORECAST_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pITEM_ENABLED                      IN  NUMBER    := MSC_UTIL.SYS_YES,
               pKPI_BIS_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pMDS_ENABLED                     IN  NUMBER    := MSC_UTIL.SYS_YES,
               pMPS_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               pOH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPARAMETER_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPLANNER_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPROJECT_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
               pPUR_REQ_PO_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESERVES_HARD_ENABLED           IN  NUMBER    := MSC_UTIL.SYS_YES,
               pRESOURCE_NRA_ENABLED              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSafeStock_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSalesOrder_RTYPE                IN  NUMBER,
               --pSH_ENABLED                        IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSOURCING_ENABLED                IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pSUB_INV_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_CUSTOMER_ENABLED               IN  NUMBER    := MSC_UTIL.SYS_YES,
               pTP_VENDOR_ENABLED                 IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pTRIP_ENABLED                    IN  NUMBER    := MSC_UTIL.SYS_YES,
               pUNIT_NO_ENABLED                   IN  NUMBER    := MSC_UTIL.SYS_YES,
 	       pUOM_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_COMPANY_ENABLED            IN  NUMBER    := MSC_UTIL.SYS_YES,
               --pUSER_SUPPLY_DEMAND              IN  NUMBER    := MSC_UTIL.SYS_YES,
               pWIP_ENABLED                       IN  NUMBER    := MSC_UTIL.SYS_YES
               );


/* ds_plan: change end */


   --  ================= Procedures ====================

   FUNCTION SET_ST_STATUS( ERRBUF                          OUT NOCOPY VARCHAR2,
                           RETCODE                         OUT NOCOPY NUMBER,
                           pINSTANCE_ID                    IN  NUMBER,
                           pST_STATUS                      IN  NUMBER,
                           pSO_RTYPE                       IN  NUMBER:= NULL)
            RETURN BOOLEAN;

   PROCEDURE INITIALIZE( pREFRESH_ID                     OUT NOCOPY NUMBER,
                         pTOTAL_TASK_NUMBER              OUT NOCOPY NUMBER);


   PROCEDURE INITIALIZE_PULL_GLOBALS( pINSTANCE_ID       IN NUMBER);

   PROCEDURE FINAL( pINSTANCE_ID                    IN  NUMBER,
                    pORG_GROUP                      IN  VARCHAR2,
                    pRTYPE                          IN  NUMBER,
                    pSO_RTYPE                       IN  NUMBER,
                    pLRN                            IN  NUMBER,
                    pSOURCING_ENABLED               IN  NUMBER,
                    prec                            IN  MSC_UTIL.CollParamREC);

   -- EXECUTE_TASK::pLRN  if -1, then complete refresh.

   PROCEDURE EXECUTE_TASK(
                      pSTATUS                            OUT NOCOPY NUMBER,
                      pTASKNUM                           IN  NUMBER,
                      pIID                               IN  NUMBER,
                      pLRN                               IN  NUMBER,
                      pREFRESH_ID                        IN  NUMBER,
 ----- PROFILE OPTION --------------------------------------------------
                      pSO_SHIP_ARRIVE_VALUE              IN  NUMBER,
                      pMPS_CONSUME_PROFILE_VALUE         IN  NUMBER,
                      pSPREAD_LOAD                       IN  NUMBER,
                      pHOUR_UOM                          IN  VARCHAR2,
                      pLANG                              IN  VARCHAR2,
                      pOE_INSTALL                        IN  VARCHAR2,
 ----- MSC PROFILE OPTION ----------------------------------------------
                      pMSO_ITEM_DMD_PENALTY              IN  NUMBER,
                      pMSO_ITEM_CAP_PENALTY              IN  NUMBER,
                      pMSO_ORG_DMD_PENALTY               IN  NUMBER,
                      pMSO_ORG_ITEM_PENALTY              IN  NUMBER,
                      pMSO_ORG_RES_PENALTY               IN  NUMBER,
                      pMSO_ORG_TRSP_PENALTY              IN  NUMBER,
                      pMSC_AGGREG_RES_NAME               IN  NUMBER,
                      pMSO_RES_PENALTY                   IN  NUMBER,
                      pMSO_SUP_CAP_PENALTY               IN  NUMBER,
                      pMSC_BOM_SUBST_PRIORITY            IN  NUMBER,
                      pMSO_TRSP_PENALTY                  IN  NUMBER,
                      pMSC_ALT_BOM_COST                  IN  NUMBER,
                      pMSO_FCST_PENALTY                  IN  NUMBER,
                      pMSO_SO_PENALTY                    IN  NUMBER,
                      pMSC_ALT_OP_RES                    IN  NUMBER,
                      pMSC_ALT_RES_PRIORITY              IN  NUMBER,
                      pMSC_BATCHABLE_FLAG               IN  NUMBER,
                      pMSC_BATCHING_WINDOW              IN  NUMBER,
                      pMSC_MIN_CAPACITY                  IN  NUMBER,
                      pMSC_MAX_CAPACITY                  IN  NUMBER,
                      pMSC_UNIT_OF_MEASURE              IN  NUMBER,
                      pMSC_SIMUL_RES_SEQ                 IN  NUMBER,
                      pMRP_BIS_AV_DISCOUNT               IN  NUMBER,
                      pMRP_BIS_PRICE_LIST                IN  NUMBER,
                      pMSC_DMD_PRIORITY_FLEX_NUM         IN  NUMBER,
                      pMSC_FCST_PRIORITY_FLEX_NUM         IN  NUMBER,
      		    --  pMSC_HUB_CURR_CODE	          IN VARCHAR2, -- bug # 6469722
		  --    pMSC_CURR_CONV_TYPE		  IN VARCHAR2,
		   --   pMSC_FUTURE_DAYS			  IN NUMBER,
		   --   pMSC_HISTORY_DAYS			  IN NUMBER,

 ----- FLAGS -----------------------------------------------------------
                      pITEM_ENABLED                      IN  NUMBER,
                      pVENDOR_ENABLED                    IN  NUMBER,
                      pCUSTOMER_ENABLED                  IN  NUMBER,
                      pBOM_ENABLED                       IN  NUMBER,
                      pHARD_RESRVS_ENABLED               IN  NUMBER,
                      pSOURCING_ENABLED                  IN  NUMBER,
                      pWIP_ENABLED                       IN  NUMBER,
                      pPO_RECEIPTS_ENABLED               IN  NUMBER,
                      pSS_ENABLED                        IN  NUMBER,
                      pPO_ENABLED                        IN  NUMBER,
                      pITEM_SUBST_ENABLED                IN  NUMBER,
                      pOH_ENABLED                        IN  NUMBER,
                      pSUPPLIER_CAP_ENABLED              IN  NUMBER,
                      pUOM_ENABLED                       IN  NUMBER,
                      pMDS_ENABLED                       IN  NUMBER,
                      pFORECAST_ENABLED                  IN  NUMBER,
                      pMPS_ENABLED                       IN  NUMBER,
                      pNRA_ENABLED                       IN  NUMBER,
                      pSH_ENABLED                        IN  NUMBER,
                      pUSER_COMPANY_ENABLED              IN  NUMBER,
					            /* CP-ACK starts */
					            pSUPPLIER_RESPONSE_ENABLED         IN  NUMBER,
					            /* CP-ACK ends */
					            pTRIP_ENABLED                       IN  NUMBER,
                      prec                               in  MSC_UTIL.CollParamREC
);

   PROCEDURE ANALYZE_ALL_ST_TABLE;

   PROCEDURE ANALYZE_ST_TABLE( pTASK_NUMBER           IN  NUMBER);

   ------ NEW PROCEDURES for PARTIAL REPLACEMENT ----
   FUNCTION Q_PARTIAL_TASK (p_instance_id NUMBER,
                            p_task_num    NUMBER,
                            prec          MSC_UTIL.CollParamREC,
			    p_collection_type NUMBER)
   RETURN BOOLEAN;

-- agmcont




   FUNCTION get_entity_lrn        (p_instance_id in NUMBER,
                                   p_task_num    in NUMBER,
                                   prec          in MSC_UTIL.CollParamREC,
                                   p_lrnn        in number,
                                   p_rtype       in number,
                                   p_org_group   in varchar2,
                                   p_entity_lrnn   out NOCOPY number)
   RETURN BOOLEAN;



END MSC_CL_PULL;

/

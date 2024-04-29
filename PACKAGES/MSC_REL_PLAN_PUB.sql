--------------------------------------------------------
--  DDL for Package MSC_REL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_REL_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: MSCPRELS.pls 120.6.12010000.3 2009/08/12 23:29:16 ahoque ship $ */

--  Start of Comments
--  API name    MSC_Release_Plan_Sc
--  Type        Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

-- New Data Type

   TYPE NumTblTyp IS TABLE OF NUMBER;

-- CONSTANTS --
    SYS_YES                 CONSTANT INTEGER := 1;
    SYS_NO                  CONSTANT INTEGER := 2;

    RELEASE_ATTEMPTED       CONSTANT NUMBER :=  1;
    NOT_RELEASABLE          CONSTANT NUMBER := -1;
    RELEASABLE              CONSTANT NUMBER :=  0;

    REQ_GRP_ALL_ON_ONE      CONSTANT INTEGER := 1;  -- PO group by
    REQ_GRP_ITEM            CONSTANT INTEGER := 2;
    REQ_GRP_BUYER           CONSTANT INTEGER := 3;
    REQ_GRP_PLANNER         CONSTANT INTEGER := 4;
    REQ_GRP_VENDOR          CONSTANT INTEGER := 5;
    REQ_GRP_ONE_EACH        CONSTANT INTEGER := 6;
    REQ_GRP_CATEGORY        CONSTANT INTEGER := 7;
    REQ_GRP_LOCATION        CONSTANT INTEGER := 8;

    WIP_DIS_MASS_LOAD       CONSTANT INTEGER := 1;
    WIP_REP_MASS_LOAD       CONSTANT INTEGER := 2;
    WIP_DIS_MASS_RESCHEDULE CONSTANT INTEGER := 4;
    PO_MASS_LOAD            CONSTANT INTEGER := 8;
    PO_MASS_RESCHEDULE      CONSTANT INTEGER := 16;

    DRP_REQ_LOAD            constant integer := 32;  -- drp release
    DRP_REQ_RESCHED         constant integer := 64;  -- drp release

    ERO_LOAD                CONSTANT  NUMBER := 128;
    IRO_LOAD                CONSTANT  NUMBER := 256;

    PURCHASE_ORDER      CONSTANT INTEGER := 1;   -- order type lookup
    PURCH_REQ           CONSTANT INTEGER := 2;
    WORK_ORDER          CONSTANT INTEGER := 3;
    REPETITVE_SCHEDULE  CONSTANT INTEGER := 4;
    PLANNED_ORDER       CONSTANT INTEGER := 5;
    MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
    NONSTD_JOB          CONSTANT INTEGER := 7;
    RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
    REQUIREMENT         CONSTANT INTEGER := 9;
    FPO_SUPPLY          CONSTANT INTEGER := 10;

    NOT_UNDER_REV_CONTROL  CONSTANT INTEGER := 1;
    UNDER_REV_CONTROL      CONSTANT INTEGER := 2;

    PURCHASING_BY_REV      CONSTANT INTEGER := 1;
    NOT_PURCHASING_BY_REV  CONSTANT INTEGER := 2;


    LT_RESOURCE            CONSTANT INTEGER := 1;  -- wip details load type
    LT_COMPONENT           CONSTANT INTEGER := 2;
    LT_OPERATION           CONSTANT INTEGER := 3;
    LT_RESOURCE_USAGE      CONSTANT INTEGER := 4;

    SUBST_DELETE           CONSTANT INTEGER := 1;  -- wip details substitution
    SUBST_ADD              CONSTANT INTEGER := 2;  -- type
    SUBST_CHANGE           CONSTANT INTEGER := 3;

-- Variables --
    v_hour_uom                  VARCHAR2(4);
    v_purchasing_by_rev         NUMBER;
    v_instance_code_length      NUMBER;

    g_batch_id                  NUMBER := -1;
    g_prev_batch_id             NUMBER := g_batch_id;
    G_SPP_SPLIT_YN       VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('MSO_ENABLE_ROUNDING_OF_FRACTIONAL_SUPPLIES_FOR_SRP'),'N');

-- Procedures --
PROCEDURE MSC_RELEASE_PLAN_SC
(  arg_plan_id		        IN      NUMBER
,  arg_log_org_id		IN 	NUMBER
,  arg_log_sr_instance	        IN      NUMBER
,  arg_org_id 			IN 	NUMBER
,  arg_sr_instance              IN      NUMBER
,  arg_compile_desig	    	IN 	VARCHAR2
,  arg_user_id 			IN	NUMBER
,  arg_po_group_by 		IN 	NUMBER
,  arg_po_batch_number		IN 	NUMBER
,  arg_wip_group_id 		IN 	NUMBER
,  arg_loaded_jobs 		IN OUT  NOCOPY  NumTblTyp
,  arg_loaded_reqs 		IN OUT  NOCOPY  NumTblTyp
,  arg_loaded_scheds 		IN OUT  NOCOPY  NumTblTyp
,  arg_resched_jobs 		IN OUT  NOCOPY  NumTblTyp
,  arg_resched_reqs 		IN OUT  NOCOPY  NumTblTyp
,  arg_wip_req_id  		IN OUT  NOCOPY  NumTblTyp
,  arg_req_load_id 		IN OUT  NOCOPY  NumTblTyp
,  arg_req_resched_id 		IN OUT  NOCOPY  NumTblTyp
,  arg_released_instance        IN OUT  NOCOPY  NumTblTyp
,  arg_mode                     IN      VARCHAR2  DEFAULT NULL
,  arg_transaction_id           IN      NUMBER    DEFAULT NULL
,  arg_loaded_lot_jobs           IN OUT NOCOPY  NumTblTyp
,  arg_resched_lot_jobs          IN OUT NOCOPY  NumTblTyp
,  arg_osfm_req_id               IN OUT NOCOPY  NumTblTyp
-- the following 2 parameters added for dsr
, arg_resched_eam_jobs   IN OUT  NOCOPY  NumTblTyp
, arg_eam_req_id 	IN OUT  NOCOPY  NumTblTyp
-- the following 4 parameters added for drp release
, arg_loaded_int_reqs               IN OUT  NOCOPY  NumTblTyp
, arg_resched_int_reqs              IN OUT  NOCOPY NumTblTyp
, arg_int_req_load_id               IN OUT  NOCOPY  NumTblTyp
, arg_int_req_resched_id            IN OUT  NOCOPY  NumTblTyp
, arg_loaded_int_repair_orders      IN OUT  NOCOPY  NumTblTyp -- for release of IRO
, arg_int_repair_orders_id          IN OUT  NOCOPY  NumTblTyp --for release of IRO
, arg_loaded_ext_repair_orders      IN OUT  NOCOPY  NumTblTyp -- for release of ERO
, arg_ext_repair_orders_id          IN OUT  NOCOPY  NumTblTyp --for release of ERO
);


PROCEDURE MSC_RELEASE_PLAN_SC
(  arg_plan_id		        IN      NUMBER
,  arg_log_org_id		IN 	NUMBER
,  arg_log_sr_instance	        IN      NUMBER
,  arg_org_id 			IN 	NUMBER
,  arg_sr_instance              IN      NUMBER
,  arg_compile_desig	    	IN 	VARCHAR2
,  arg_user_id 			IN	NUMBER
,  arg_po_group_by 		IN 	NUMBER
,  arg_po_batch_number		IN 	NUMBER
,  arg_wip_group_id 		IN 	NUMBER
,  arg_loaded_jobs 		IN OUT 	NOCOPY  NumTblTyp
,  arg_loaded_reqs 		IN OUT  NOCOPY  NumTblTyp
,  arg_loaded_scheds 		IN OUT  NOCOPY  NumTblTyp
,  arg_resched_jobs 		IN OUT  NOCOPY  NumTblTyp
,  arg_resched_reqs 		IN OUT  NOCOPY  NumTblTyp
,  arg_wip_req_id  		IN OUT  NOCOPY  NumTblTyp
,  arg_req_load_id 		IN OUT  NOCOPY  NumTblTyp
,  arg_req_resched_id 		IN OUT  NOCOPY  NumTblTyp
,  arg_released_instance        IN OUT  NOCOPY  NumTblTyp
,  arg_mode                     IN      VARCHAR2 DEFAULT NULL
,  arg_transaction_id           IN      NUMBER DEFAULT NULL
-- the following 4 parameters added for drp release
, arg_loaded_int_reqs               IN OUT  NOCOPY  NumTblTyp
, arg_resched_int_reqs              IN OUT  NOCOPY NumTblTyp
, arg_int_req_load_id               IN OUT  NOCOPY  NumTblTyp
, arg_int_req_resched_id            IN OUT  NOCOPY  NumTblTyp
, arg_loaded_int_repair_orders      IN OUT  NOCOPY  NumTblTyp -- for release of IRO
, arg_int_repair_orders_id          IN OUT  NOCOPY  NumTblTyp --for release of IRO
, arg_loaded_ext_repair_orders      IN OUT  NOCOPY  NumTblTyp -- for release of ERO
, arg_ext_repair_orders_id          IN OUT  NOCOPY  NumTblTyp --for release of ERO
);

PROCEDURE LOAD_MSC_INTERFACE
( arg_dblink                    IN      VARCHAR2
, arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_compile_desig 		IN 	VARCHAR2
, arg_user_id 			IN 	NUMBER
, arg_po_group_by 		IN 	NUMBER
, arg_po_batch_number 		IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_loaded_jobs 		IN OUT 	NOCOPY  NUMBER
, arg_loaded_lot_jobs           IN OUT  NOCOPY  NUMBER
,arg_resched_lot_jobs           IN OUT  NOCOPY  NUMBER
, arg_loaded_reqs 		IN OUT  NOCOPY  NUMBER
, arg_loaded_scheds 		IN OUT  NOCOPY  NUMBER
, arg_resched_jobs 		IN OUT  NOCOPY  NUMBER
, arg_resched_reqs 		IN OUT  NOCOPY  NUMBER
, arg_wip_req_id 		IN OUT  NOCOPY  NUMBER
,arg_osfm_req_id                IN OUT  NOCOPY  NUMBER
, arg_req_load_id 		IN OUT  NOCOPY  NUMBER
, arg_req_resched_id 		IN OUT  NOCOPY  NUMBER
, arg_mode                      IN      VARCHAR2 DEFAULT NULL
, arg_transaction_id            IN      NUMBER   DEFAULT NULL
,  l_apps_ver                   IN      VARCHAR2
-- dsr
, arg_resched_eam_jobs          IN OUT  NOCOPY  NUMBER
, arg_eam_req_id               IN OUT  NOCOPY  NUMBER
-- the following 4 parameters added for drp release
, arg_loaded_int_reqs               IN OUT  NOCOPY  Number
, arg_resched_int_reqs              IN OUT  NOCOPY  Number
, arg_int_req_load_id               IN OUT  NOCOPY  Number
, arg_int_req_resched_id            IN OUT  NOCOPY  Number
, arg_loaded_int_repair_orders      IN OUT  NOCOPY  Number -- for release of IRO
, arg_int_repair_orders_id          IN OUT  NOCOPY  Number --for release of IRO
, arg_loaded_ext_repair_orders      IN OUT  NOCOPY  Number -- for release of ERO
, arg_ext_repair_orders_id          IN OUT  NOCOPY  Number --for release of ERO
);



FUNCTION load_wip_discrete_jobs
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER;


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
)RETURN NUMBER;


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
)RETURN NUMBER;


FUNCTION reschedule_wip_discrete_jobs
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_mode                      IN      VARCHAR2
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
, arg_load_type                 IN      NUMBER DEFAULT NULL -- dsr
)RETURN NUMBER;

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
)RETURN NUMBER;

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
)RETURN NUMBER;

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
)RETURN NUMBER;

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
)RETURN NUMBER;

FUNCTION GET_CAL_DATE ( lv_inst_id in number
                        , lv_calendar_date in date
                        ,lv_calendar_code in varchar2) return date ;
FUNCTION GET_COPRODUCT_QTY ( inst_id in number , pln_id in number ,disp_id in number, bill_seq_id in number) return number ;

FUNCTION GET_REV_CUM_YIELD (inst_id in number , pln_id in number, process_seq_id in number,trans_id in number,org_id in number) return number ;

FUNCTION GET_REV_CUM_YIELD_DISC (inst_id        IN NUMBER,
                                 pln_id         IN NUMBER,
                                 process_seq_id IN NUMBER,
                                 trans_id       IN NUMBER,
                                 org_id         IN NUMBER,
                                 org_type      IN NUMBER)
   RETURN NUMBER;

FUNCTION GET_REV_CUM_YIELD_DISC_COMP( inst_id         IN NUMBER
                                      ,pln_id         IN NUMBER
                                      ,process_seq_id IN NUMBER
                                      ,trans_id       IN NUMBER
                                      ,org_id         IN NUMBER
                                      ,org_type       IN NUMBER
                                      ,op_seq_num     IN NUMBER
                                  )
RETURN NUMBER;


FUNCTION GET_USAGE_QUANTITY ( p_plan_id     IN NUMBER
                              ,p_inst_id     IN NUMBER
                              ,p_org_id     IN NUMBER
                              ,p_using_assy_id     IN NUMBER
                              ,p_comp_seq_id      IN NUMBER) RETURN NUMBER;
FUNCTION GET_WIP_SUPPLY_TYPE ( p_plan_id     IN NUMBER
                              ,p_inst_id     IN NUMBER
                              ,p_process_seq_id IN NUMBER
                              ,p_item_id      IN NUMBER
                              ,p_comp_item_id      IN NUMBER
                              ,p_org_id      IN NUMBER) RETURN NUMBER;

  /*  Added these @ functions to get the SR_TP_ID and the TP_SITE_LOCATION
       based on the arguments */
FUNCTION GET_MODELED_SR_TP_ID (pMODELED_SUPPLIER_ID    IN NUMBER,
                               pSR_INSTANCE_ID         IN NUMBER)
    RETURN NUMBER;

FUNCTION GET_MODELED_TP_SITE_CODE (pMODELED_SUPPLIER_ID       IN NUMBER,
                                   pMODELED_SUPPLIER_SITE_ID  IN NUMBER,
                                   pSR_INSTANCE_ID            IN NUMBER)
   RETURN VARCHAR2;

FUNCTION Decode_Sales_Order_Number(p_order_number_string in VARCHAR2)
                                   return NUMBER;
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
                                  p_load_type           IN  number);

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
                                  p_load_type           IN  number);

Procedure Release_IRO(
                                  p_dblink              IN  varchar2,
                                  p_arg_iro_batch_number IN number,
                                  p_arg_owning_instance IN  number,
                                  p_arg_po_group_by     IN  number,
                                  p_arg_plan_id         IN  number,
                                  p_arg_log_org_id      IN  number,
                                  p_arg_owning_org_id   IN  number,
                                  p_arg_org_instance    IN  number,
                                  p_arg_mode            IN  varchar2,
                                  p_arg_transaction_id  IN  number,
                                  p_arg_loaded_int_repair_orders IN OUT NOCOPY number,
                                  p_load_type           IN  number);

Procedure Release_IRO_2(
                                  p_dblink              IN  varchar2,
                                  p_arg_iro_batch_number IN number,
                                  p_arg_owning_instance IN  number,
                                  p_arg_po_group_by     IN  number,
                                  p_arg_plan_id         IN  number,
                                  p_arg_log_org_id      IN  number,
                                  p_arg_owning_org_id   IN  number,
                                  p_arg_org_instance    IN  number,
                                  p_arg_mode            IN  varchar2,
                                  p_arg_transaction_id  IN  number,
                                  p_arg_loaded_int_repair_orders IN OUT NOCOPY number,
                                  p_load_type           IN  number);


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
                                  p_load_type IN NUMBER);
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
                                  p_load_type IN NUMBER);
PROCEDURE  SET_RP_TIMESTAMP_WIP(p_group_id IN NUMBER);
PROCEDURE  SET_RP_TIMESTAMP_PO(p_arg_batch_id IN NUMBER);
END MSC_Rel_Plan_PUB;

/

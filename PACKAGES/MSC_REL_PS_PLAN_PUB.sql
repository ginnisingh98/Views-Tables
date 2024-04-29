--------------------------------------------------------
--  DDL for Package MSC_REL_PS_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_REL_PS_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: MSCPSRELS.pls 120.3.12010000.1 2008/05/02 19:06:57 appldev ship $ */

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

-- Procedures --
PROCEDURE MSC_PS_RELEASE
( p_plan_id IN NUMBER
, p_organization_id IN NUMBER
, p_instance_id IN NUMBER
, p_plan_name IN VARCHAR2
, p_user_id IN VARCHAR2
, p_loaded_jobs IN OUT NOCOPY NUMBER
, p_resched_jobs IN OUT NOCOPY NUMBER
, p_req_id IN OUT NOCOPY NUMBER );

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
,  arg_loaded_lot_jobs          IN OUT  NOCOPY  NumTblTyp
,  arg_resched_lot_jobs         IN OUT  NOCOPY  NumTblTyp
,  arg_osfm_req_id              IN OUT  NOCOPY  NumTblTyp
,  arg_loaded_int_repair_orders IN OUT  NOCOPY  NumTblTyp
,  arg_int_repair_orders_id     IN OUT  NOCOPY  NumTblTyp
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
, arg_resched_lot_jobs          IN OUT  NOCOPY  NUMBER
, arg_loaded_reqs 		IN OUT  NOCOPY  NUMBER
, arg_loaded_scheds 		IN OUT  NOCOPY  NUMBER
, arg_resched_jobs 		IN OUT  NOCOPY  NUMBER
, arg_resched_reqs 		IN OUT  NOCOPY  NUMBER
, arg_wip_req_id 		IN OUT  NOCOPY  NUMBER
, arg_osfm_req_id               IN OUT  NOCOPY  NUMBER
, arg_req_load_id 		IN OUT  NOCOPY  NUMBER
, arg_req_resched_id 		IN OUT  NOCOPY  NUMBER
, arg_mode                      IN      VARCHAR2 DEFAULT NULL
, arg_transaction_id            IN      NUMBER   DEFAULT NULL
, l_apps_ver                    IN      VARCHAR2
, arg_loaded_int_repair_orders  IN OUT  NOCOPY  Number
, arg_int_repair_orders_id      IN OUT  NOCOPY  Number
);



FUNCTION load_wip_discr_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER;

FUNCTION load_osfm_lot_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER;



FUNCTION reschedule_osfm_lot_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id 		IN 	NUMBER
, arg_transaction_id            IN      NUMBER
)RETURN NUMBER;


FUNCTION reschedule_wip_discr_jobs_ps
( arg_plan_id			IN      NUMBER
, arg_log_org_id 		IN 	NUMBER
, arg_org_instance              IN      NUMBER
, arg_owning_org_id 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_user_id 			IN 	NUMBER
, arg_wip_group_id              IN      NUMBER
, arg_transaction_id            IN      NUMBER
, l_apps_ver                    IN      VARCHAR2
)RETURN NUMBER;


END MSC_Rel_PS_Plan_PUB;

/

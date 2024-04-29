--------------------------------------------------------
--  DDL for Package PJI_RM_SUM_AVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_RM_SUM_AVL" AUTHID CURRENT_USER AS
  /* $Header: PJISR04S.pls 115.7 2003/04/02 23:26:40 svermett noship $ */

--exception to raise
RAISE_USER_DEF_EXCEPTION   EXCEPTION;
PRAGMA EXCEPTION_INIT(RAISE_USER_DEF_EXCEPTION, -502);

TYPE   V_TYPE_TAB    IS   TABLE OF VARCHAR2(30)
   INDEX BY BINARY_INTEGER;
TYPE   N_TYPE_TAB    IS   TABLE OF NUMBER(15)
   INDEX BY BINARY_INTEGER;

PROCEDURE INIT_PCKG_GLOBAL_VARS;

PROCEDURE POP_ROLL_WEEK_OFFSET;

PROCEDURE CALCULATE_BUCKET_VALUE
(
	 p_res_cnt		IN         NUMBER
	,x_bckt_1 		OUT NOCOPY NUMBER
        ,x_bckt_2 		OUT NOCOPY NUMBER
        ,x_bckt_3 		OUT NOCOPY NUMBER
	,x_bckt_4 		OUT NOCOPY NUMBER
        ,x_bckt_5 		OUT NOCOPY NUMBER
);

PROCEDURE CALC_CS_RES_CNT_VALUE
(
	p_res_cnt_tbl	IN OUT NOCOPY N_TYPE_TAB
);

PROCEDURE DEL_GLOBAL_RS_AVL3_TBL;

PROCEDURE BULK_INSERT_RS_AVL3
(
	p_exp_organization_id_in_tbl	IN N_TYPE_TAB,
	p_exp_org_id_in_tbl		IN N_TYPE_TAB,
	p_period_type_id_in_tbl		IN N_TYPE_TAB,
	p_time_id_in_tbl		IN N_TYPE_TAB,
	p_person_id_in_tbl		IN N_TYPE_TAB,
	p_calendar_type_in_tbl		IN V_TYPE_TAB,
	p_threshold_in_tbl		IN N_TYPE_TAB,
	p_as_of_date_in_tbl		IN N_TYPE_TAB,
	p_bckt_1_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_2_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_3_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_4_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_5_cs_in_tbl		IN N_TYPE_TAB,
	p_bckt_1_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_2_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_3_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_4_cm_in_tbl		IN N_TYPE_TAB,
	p_bckt_5_cm_in_tbl		IN N_TYPE_TAB,
	p_total_res_cnt_in_tbl		IN N_TYPE_TAB,
	p_run_mode			IN VARCHAR2,
	p_blind_insert_flag		IN VARCHAR2
);

PROCEDURE PREPARE_TO_INS_INTO_AVL3
(
	p_exp_organization_id	IN PJI_RM_AGGR_AVL2.expenditure_organization_id%TYPE,
	p_exp_org_id		IN PJI_RM_AGGR_AVL2.expenditure_org_id%TYPE,
	p_person_id		IN PJI_RM_AGGR_AVL2.person_id%TYPE,
      	p_time_id		IN PJI_RM_AGGR_AVL2.time_id%TYPE,
      	p_curr_pd		IN NUMBER,
      	p_as_of_date		IN NUMBER,
      	p_pd_org_st_date	IN NUMBER,
	p_period_type_id	IN NUMBER,
	p_calendar_type		IN VARCHAR2,
	p_res_cnt_tbl		IN N_TYPE_TAB,
	p_run_mode		IN VARCHAR2,
	p_blind_insert_flag	IN VARCHAR2,
	x_zero_bkt_cnt_flag	OUT NOCOPY VARCHAR2
);

PROCEDURE DEL_GLOBAL_RS_AVL4_TBL;

PROCEDURE BULK_INSERT_RS_AVL4
(
	p_exp_organization_id_in_tbl	IN N_TYPE_TAB,
	p_exp_org_id_in_tbl		IN N_TYPE_TAB,
	p_period_type_id_in_tbl		IN N_TYPE_TAB,
	p_time_id_in_tbl		IN N_TYPE_TAB,
	p_person_id_in_tbl		IN N_TYPE_TAB,
	p_calendar_type_in_tbl		IN V_TYPE_TAB,
	p_threshold_in_tbl		IN N_TYPE_TAB,
	p_as_of_date_in_tbl		IN N_TYPE_TAB,
	p_availability_in_tbl		IN N_TYPE_TAB,
	p_total_res_cnt_in_tbl		IN N_TYPE_TAB,
	p_run_mode			IN VARCHAR2,
	p_blind_insert_flag		IN VARCHAR2
);

PROCEDURE PREPARE_TO_INS_INTO_AVL4
(
	p_exp_organization_id	IN PJI_RM_AGGR_AVL2.expenditure_organization_id%TYPE,
	p_exp_org_id		IN PJI_RM_AGGR_AVL2.expenditure_org_id%TYPE,
	p_person_id		IN PJI_RM_AGGR_AVL2.person_id%TYPE,
      	p_time_id		IN PJI_RM_AGGR_AVL2.time_id%TYPE,
      	p_curr_pd		IN NUMBER,
	p_as_of_date		IN NUMBER,
      	p_pd_org_st_date	IN NUMBER,
	p_period_type_id	IN NUMBER,
	p_calendar_type		IN VARCHAR2,
	p_res_cnt_tbl		IN N_TYPE_TAB,
	p_run_mode		IN VARCHAR2,
	p_blind_insert_flag	IN VARCHAR2,
	x_zero_bkt_cnt_flag	OUT NOCOPY VARCHAR2
);

PROCEDURE CALCULATE_RES_AVL
(
	p_worker_id		IN         NUMBER,
	p_person_id		IN         NUMBER,
	p_run_mode		IN         VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2
);

/**************************************************************************
THE PART BELOW IS THE DRIVER PART FOR CALCULATIONS. IT ACTS LIKE AN
OVERALL MANAGER WHO MONITORS THE RESOURCE AVAILABILITY CALCULATIONS
**************************************************************************/

PROCEDURE CALC_CURR_RES_COUNT;

PROCEDURE MERGE_ORG_AVL_DUR
(
	p_worker_id	IN NUMBER
);

PROCEDURE MERGE_CURR_ORG_AVL
(
	p_worker_id	IN NUMBER
);

PROCEDURE UPDATE_RES_STATUS;

PROCEDURE RES_CALC_CLEANUP
(
	p_worker_id	IN NUMBER
);

PROCEDURE START_RES_AVL_CALC_R1
(
	p_worker_id	IN NUMBER
);

PROCEDURE UPDATE_RES_STA_FOR_RUN2
(
	p_worker_id	IN NUMBER
);

PROCEDURE START_RES_AVL_CALC_R2
(
	p_worker_id	IN NUMBER
);

PROCEDURE INS_INTO_RES_STATUS
(
	p_worker_id	IN NUMBER
);

PROCEDURE REFRESH_AV_ORGO_F_MV
(
	p_worker_id	IN NUMBER
);

PROCEDURE REFRESH_CA_ORGO_F_MV
(
	p_worker_id	IN NUMBER
);

END PJI_RM_SUM_AVL;

 

/

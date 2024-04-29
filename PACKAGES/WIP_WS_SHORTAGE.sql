--------------------------------------------------------
--  DDL for Package WIP_WS_SHORTAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_SHORTAGE" AUTHID CURRENT_USER AS
/* $Header: wipwsshs.pls 120.4 2007/12/31 00:18:31 ksuleman noship $ */

g_logLevel NUMBER     := FND_LOG.g_current_runtime_level;
g_user_id NUMBER      := FND_GLOBAL.user_id;
g_login_id NUMBER     := FND_GLOBAL.login_id;
g_prog_appid NUMBER   := FND_PROFILE.value('RESP_APPL_ID');
g_prog_id NUMBER      := FND_PROFILE.value('PROGRAM_ID');
g_prog_run_date DATE  := sysdate;
g_request_id NUMBER   := FND_PROFILE.value('REQUEST_ID');
g_init_obj_ver NUMBER := 1;


PROCEDURE calc_shortage (errbuf      OUT NOCOPY VARCHAR2,
                         retcode     OUT NOCOPY NUMBER,
                         p_org_id    IN NUMBER,
                         p_calc_type IN NUMBER DEFAULT 1);


Type org_comp_calc_rec_type is record(
  org_id              NUMBER,
  shortage_calc_level NUMBER,
  inc_expected_rcpts  NUMBER,
  inc_released_jobs   NUMBER,
  inc_unreleased_jobs NUMBER,
  inc_onhold_jobs     NUMBER,
  supply_cutoff_hr    NUMBER,
  supply_cutoff_min   NUMBER,
  supply_cutoff_time_in_sec NUMBER,
  category_set_id     NUMBER
);
g_org_comp_calc_rec org_comp_calc_rec_type;

g_pref_id_comp_short NUMBER := 33;
g_pref_id_res_short  NUMBER := 23;
g_pref_level_id_site NUMBER := 1;
g_pref_val_mast_org_att       VARCHAR2(30) := 'masterorg';
g_pref_val_dtl_org_att        VARCHAR2(30) := 'detailorg';
g_pref_val_calclevel_att      VARCHAR2(30) := 'calclevel';
g_pref_val_inc_release_att    VARCHAR2(30) := 'released';
g_pref_val_inc_unreleased_att VARCHAR2(30) := 'unreleased';
g_pref_val_inc_onhold_att     VARCHAR2(30) := 'onhold';
g_pref_val_inc_rcpts_att      VARCHAR2(30) := 'expectedrecipt';
g_pref_val_cutoff_hr_att      VARCHAR2(30) := 'hr';
g_pref_val_cutoff_min_att     VARCHAR2(30) := 'min';
g_pref_val_comp_type_att      VARCHAR2(30) := 'type';
g_pref_val_comp_type_item_att VARCHAR2(30) := 'item';
g_pref_val_comp_type_cat_att  VARCHAR2(30) := 'category';
g_pref_val_comp_type_cset_att  VARCHAR2(30) := 'categoryset';
g_pref_val_comp_type_all  NUMBER := 3;
g_pref_val_comp_type_item NUMBER := 1;
g_pref_val_comp_type_cat  NUMBER := 2;
g_pref_val_calclevel_org  NUMBER := 1;
g_pref_val_calclevel_sub  NUMBER := 2;
g_period_end_time DATE;


TYPE wip_job_op_rec_type is record(
  ORGANIZATION_ID	      NUMBER,
  WIP_ENTITY_ID	        NUMBER,
  OPERATION_SEQ_NUM	    NUMBER,
  DEPARTMENT_ID         NUMBER,
  FIRST_UNIT_START_DATE DATE,
  START_QTY             NUMBER,
  OPEN_QTY              NUMBER,
  SCHEDULED_QTY         NUMBER
);
TYPE wip_job_op_tbl_type is table of wip_job_op_rec_type index by BINARY_INTEGER;
g_wip_job_op_tbl wip_job_op_tbl_type;


TYPE wip_job_critical_comp_rec_type is record(
  ORGANIZATION_ID	      NUMBER,
  WIP_ENTITY_ID	        NUMBER,
  OPERATION_SEQ_NUM	    NUMBER,
  INVENTORY_ITEM_ID	    NUMBER,
  DEPARTMENT_ID	        NUMBER,
  PRIMARY_UOM_CODE	    VARCHAR2(3),
  DATE_REQUIRED	        DATE,
  QTY_PER_ASSEMBLY      NUMBER,
  REQUIRED_QTY	        NUMBER,
  QUANTITY_ISSUED	      NUMBER,
	QUANTITY_OPEN	        NUMBER,
	WIP_SUPPLY_TYPE	      NUMBER,
	BASIS_TYPE            NUMBER,
	SUPPLY_SUBINVENOTRY	  VARCHAR2(10),
	SUPPLY_LOCATOR_ID	    NUMBER,
	ONHAND_QTY	          NUMBER,
	PROJ_AVAIL_QTY	      NUMBER,
	SHORTAGE_QTY	        NUMBER
);
TYPE wip_job_critical_comp_tbl_type is table of wip_job_critical_comp_rec_type index by BINARY_INTEGER;
g_wip_job_critical_comp_tbl wip_job_critical_comp_tbl_type;


TYPE wip_job_critical_res_rec_type is record(
ORGANIZATION_ID	    NUMBER,
WIP_ENTITY_ID	      NUMBER,
OPERATION_SEQ_NUM	  NUMBER,
RESOURCE_ID	        NUMBER,
DEPARTMENT_ID	      NUMBER,
DATE_REQUIRED	      DATE,
REQUIRED_QTY	      NUMBER,
QUANTITY_ISSUED	    NUMBER,
QUANTITY_OPEN	      NUMBER,
RESOURCE_AVAIL	    NUMBER,
RESOURCE_PROJ_AVAIL	NUMBER,
RESOURCE_SHORTAGE	  NUMBER,
PRIMARY_UOM_CODE	  VARCHAR2(3),
SHIFT_NUM           NUMBER,
SHIFT_SEQ           NUMBER
);
TYPE wip_job_critical_res_tbl_type is table of wip_job_critical_res_rec_type index by BINARY_INTEGER;
g_wip_job_critical_res_tbl wip_job_critical_res_tbl_type;



END WIP_WS_SHORTAGE;

/

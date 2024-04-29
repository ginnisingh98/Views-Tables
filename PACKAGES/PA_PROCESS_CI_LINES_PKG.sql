--------------------------------------------------------
--  DDL for Package PA_PROCESS_CI_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_CI_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: PAPPCILS.pls 120.0.12010000.2 2010/04/14 12:36:52 racheruv noship $*/

  TYPE info_rec IS RECORD(LINE_ID       NUMBER,
                          PROJECT_ID    NUMBER,
                          TASK_ID       NUMBER,
                          CURRENCY_CODE VARCHAR2(30),
                          RLMI_ID       NUMBER,
                          RES_ASSGN_ID  NUMBER,
                          QUANTITY      NUMBER,
                          RAW_COST      NUMBER);

  TYPE info_rec_tbl IS TABLE OF INFO_REC index by binary_integer;

  SUBTYPE g_pa_num_tbl          IS SYSTEM.pa_num_tbl_type;
  SUBTYPE g_PA_DATE_TBL         IS SYSTEM.PA_DATE_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_1_TBL   IS SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_15_TBL  IS SYSTEM.PA_VARCHAR2_15_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_30_TBL  IS SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_80_TBL  IS SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_100_TBL IS SYSTEM.PA_VARCHAR2_100_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_150_TBL IS SYSTEM.PA_VARCHAR2_150_TBL_TYPE;
  SUBTYPE g_PA_VARCHAR2_240_TBL IS SYSTEM.PA_VARCHAR2_240_TBL_TYPE;

  g_pkg_name           constant varchar2(30) := 'PA_PROCESS_CI_LINES_PKG';

  procedure process_planning_lines(p_api_version      IN NUMBER,
                                 p_init_msg_list      IN VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_calling_context    IN VARCHAR2,
				                 p_action_type        IN VARCHAR2,
				                 p_bvid               IN NUMBER,
				                 p_ci_id              IN NUMBER,
				                 p_line_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_project_id         IN NUMBER,
				                 p_task_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_currency_code_tbl  IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
				                 p_rlmi_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_res_assgn_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_quantity_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
								 DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
				                 p_raw_cost_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
								 DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
                                 );

  procedure insert_planning_transaction(p_api_version        IN NUMBER,
                                      p_init_msg_list      IN VARCHAR2,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      P_BVID               IN  NUMBER,
                                      P_PROJECT_ID         IN  NUMBER,
				                      P_TASK_ID_TBL        IN  SYSTEM.PA_NUM_TBL_TYPE,
                                      P_RLMI_ID_TBL        IN SYSTEM.PA_NUM_TBL_TYPE,
				                      P_CURRENCY_CODE_TBL  IN  SYSTEM.PA_VARCHAR2_15_TBL_TYPE,
				                      P_QUANTITY_TBL       IN  SYSTEM.PA_NUM_TBL_TYPE,
				                      P_RAW_COST_TBL       IN  SYSTEM.PA_NUM_TBL_TYPE
				                      );

  procedure delete_planning_transaction(p_api_version  IN NUMBER,
                                      p_init_msg_list  IN VARCHAR2,
                                      x_return_status  OUT NOCOPY VARCHAR2,
                                      x_msg_count      OUT NOCOPY NUMBER,
                                      x_msg_data       OUT NOCOPY VARCHAR2,
                                      p_bvid           IN number,
                                      p_project_id     IN NUMBER,
                                      p_task_tbl       IN SYSTEM.PA_NUM_TBL_TYPE,
                                      p_currency_tbl   IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE,
                                      p_rlmi_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
                                      );

  procedure update_planning_transaction(p_api_version         IN  NUMBER,
                                        p_init_msg_list       IN  VARCHAR2,
                                        x_return_status       OUT NOCOPY VARCHAR2,
                                        x_msg_count           OUT NOCOPY NUMBER,
                                        x_msg_data            OUT NOCOPY VARCHAR2,
                                        p_bvid                IN  NUMBER,
                                        p_project_id          in  NUMBER,
                                        p_task_id_tbl         in SYSTEM.PA_NUM_TBL_TYPE,
				                        p_effective_from_tbl  in  SYSTEM.PA_DATE_TBL_TYPE,
				                        p_effective_to_tbl    in  SYSTEM.PA_DATE_TBL_TYPE,
				                        p_rlmi_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE,
				                        p_quantity_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE,
				                        p_raw_cost_tbl        IN  SYSTEM.PA_NUM_TBL_TYPE,
				                        p_currency_code_tbl   IN  SYSTEM.PA_VARCHAR2_15_TBL_TYPE
					                    );

end pa_process_ci_lines_pkg;

/

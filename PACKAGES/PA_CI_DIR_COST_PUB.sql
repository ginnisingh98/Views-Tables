--------------------------------------------------------
--  DDL for Package PA_CI_DIR_COST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_DIR_COST_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPCDCDS.pls 120.0.12010000.2 2010/04/14 12:34:01 racheruv noship $*/

  subtype PaCiDirCostTblType is pa_ci_dir_cost_pvt.PaCiDirectCostDetailsTblType;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := PA_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := PA_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := PA_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := PA_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := PA_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := PA_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := PA_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := PA_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := PA_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := PA_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'PA_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'PA_CI_DIR_COST_PUB';

procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bvid                         IN NUMBER,
    p_dc_line_id_tbl               IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_ci_id                        IN NUMBER,
    p_project_id                   IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_unit_of_measure_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_planning_resource_rate_tbl   IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_quantity_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_raw_cost_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_burdened_cost_tbl            IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_raw_cost_rate_tbl            IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_burden_cost_rate_tbl         IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_resource_assignment_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_effective_from_tbl           IN SYSTEM.PA_DATE_TBL_TYPE DEFAULT SYSTEM.PA_DATE_TBL_TYPE(),
    p_effective_to_tbl             IN SYSTEM.PA_DATE_TBL_TYPE DEFAULT SYSTEM.PA_DATE_TBL_TYPE(),
    p_change_reason_code           IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
    p_change_description           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_2000_TBL_TYPE());


  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bvid                         IN NUMBER,
    p_dc_line_id_tbl               IN SYSTEM.PA_NUM_TBL_TYPE,
    p_ci_id                        IN NUMBER,
    p_project_id                   IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_unit_of_measure_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_quantity_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE,
    p_planning_resource_rate_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
    p_raw_cost_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE,
    p_burdened_cost_tbl            IN SYSTEM.PA_NUM_TBL_TYPE,
    p_raw_cost_rate_tbl            IN SYSTEM.PA_NUM_TBL_TYPE,
    p_burden_cost_rate_tbl         IN SYSTEM.PA_NUM_TBL_TYPE,
    p_resource_assignment_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
    p_effective_from_tbl           IN SYSTEM.PA_DATE_TBL_TYPE,
    p_effective_to_tbl             IN SYSTEM.PA_DATE_TBL_TYPE,
    p_change_reason_code           IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_change_description           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dc_line_id_TBL               IN SYSTEM.PA_NUM_TBL_TYPE,
    p_ci_id                        IN NUMBER,
    p_project_id                   IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE);


end pa_ci_dir_cost_pub;

/

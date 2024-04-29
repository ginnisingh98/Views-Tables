--------------------------------------------------------
--  DDL for Package PA_CI_DIR_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_DIR_COST_PVT" AUTHID CURRENT_USER AS
/* $Header: PARCDCDS.pls 120.0.12010000.1 2010/04/09 14:09:17 racheruv noship $*/
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- PA_CI_DIRECT_COST_DETAILS Record Spec
  TYPE PaCiDirectCostDetailsRecType IS RECORD (
     dc_line_id                     NUMBER := PA_API.G_MISS_NUM
    ,ci_id                          NUMBER := PA_API.G_MISS_NUM
    ,project_id                     NUMBER := PA_API.G_MISS_NUM
    ,task_id                        NUMBER := PA_API.G_MISS_NUM
    ,expenditure_type               PA_CI_DIRECT_COST_DETAILS.EXPENDITURE_TYPE%TYPE := PA_API.G_MISS_CHAR
    ,resource_list_member_id        NUMBER := PA_API.G_MISS_NUM
    ,unit_of_measure                PA_CI_DIRECT_COST_DETAILS.UNIT_OF_MEASURE%TYPE := PA_API.G_MISS_CHAR
    ,currency_code                  PA_CI_DIRECT_COST_DETAILS.CURRENCY_CODE%TYPE := PA_API.G_MISS_CHAR
    ,quantity                       NUMBER := PA_API.G_MISS_NUM
    ,planning_resource_rate         NUMBER := PA_API.G_MISS_NUM
    ,raw_cost                       NUMBER := PA_API.G_MISS_NUM
    ,burdened_cost                  NUMBER := PA_API.G_MISS_NUM
    ,raw_cost_rate                  NUMBER := PA_API.G_MISS_NUM
    ,burden_cost_rate               NUMBER := PA_API.G_MISS_NUM
    ,resource_assignment_id         NUMBER := PA_API.G_MISS_NUM
    ,effective_from                 PA_CI_DIRECT_COST_DETAILS.EFFECTIVE_FROM%TYPE := PA_API.G_MISS_DATE
    ,effective_to                   PA_CI_DIRECT_COST_DETAILS.EFFECTIVE_TO%TYPE := PA_API.G_MISS_DATE
    ,change_reason_code             PA_CI_DIRECT_COST_DETAILS.CHANGE_REASON_CODE%TYPE := PA_API.G_MISS_CHAR
    ,change_description             PA_CI_DIRECT_COST_DETAILS.CHANGE_DESCRIPTION%TYPE := PA_API.G_MISS_CHAR
    ,created_by                     NUMBER := PA_API.G_MISS_NUM
    ,creation_date                  PA_CI_DIRECT_COST_DETAILS.CREATION_DATE%TYPE := PA_API.G_MISS_DATE
    ,last_update_by                 NUMBER := PA_API.G_MISS_NUM
    ,last_update_date               PA_CI_DIRECT_COST_DETAILS.LAST_UPDATE_DATE%TYPE := PA_API.G_MISS_DATE
    ,last_update_login              NUMBER := PA_API.G_MISS_NUM);
  GMissPaCiDirectCostDetailsRec           PaCiDirectCostDetailsRecType;
  TYPE PaCiDirectCostDetailsTblType IS TABLE OF PaCiDirectCostDetailsRecType
        INDEX BY BINARY_INTEGER;
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'PA_CI_DIR_COST_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := PA_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    XPaCiDirectCostDetailsRec      OUT NOCOPY PaCiDirectCostDetailsRecType);
/*
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE);
    */
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    XPaCiDirectCostDetailsRec      OUT NOCOPY PaCiDirectCostDetailsRecType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType);
END PA_CI_DIR_COST_PVT;

/

--------------------------------------------------------
--  DDL for Package Body PA_CI_DIR_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_DIR_COST_PVT" AS
/* $Header: PARCDCDB.pls 120.0.12010000.3 2010/04/29 06:41:39 racheruv noship $*/
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY PA_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a PA_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN PA_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> PA_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> PA_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: PA_CI_DIRECT_COST_DETAILS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN PaCiDirectCostDetailsRecType IS
    CURSOR pa_ci_direct_cost_d6 (p_dc_line_id IN NUMBER) IS
    SELECT
            DC_LINE_ID,
            CI_ID,
            PROJECT_ID,
            TASK_ID,
            EXPENDITURE_TYPE,
            RESOURCE_LIST_MEMBER_ID,
            UNIT_OF_MEASURE,
            CURRENCY_CODE,
            QUANTITY,
            PLANNING_RESOURCE_RATE,
            RAW_COST,
            BURDENED_COST,
            RAW_COST_RATE,
            BURDEN_COST_RATE,
            RESOURCE_ASSIGNMENT_ID,
            EFFECTIVE_FROM,
            EFFECTIVE_TO,
            CHANGE_REASON_CODE,
            CHANGE_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATE_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Pa_Ci_Direct_Cost_Details
     WHERE pa_ci_direct_cost_details.dc_line_id = p_dc_line_id;
    l_pa_ci_direct_cost_details_pk pa_ci_direct_cost_d6%ROWTYPE;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN pa_ci_direct_cost_d6 (p_pa_ci_direct_cost1.dc_line_id);
    FETCH pa_ci_direct_cost_d6 INTO
              l_pa_ci_direct_cost8.dc_line_id,
              l_pa_ci_direct_cost8.ci_id,
              l_pa_ci_direct_cost8.project_id,
              l_pa_ci_direct_cost8.task_id,
              l_pa_ci_direct_cost8.expenditure_type,
              l_pa_ci_direct_cost8.resource_list_member_id,
              l_pa_ci_direct_cost8.unit_of_measure,
              l_pa_ci_direct_cost8.currency_code,
              l_pa_ci_direct_cost8.quantity,
              l_pa_ci_direct_cost8.planning_resource_rate,
              l_pa_ci_direct_cost8.raw_cost,
              l_pa_ci_direct_cost8.burdened_cost,
              l_pa_ci_direct_cost8.raw_cost_rate,
              l_pa_ci_direct_cost8.burden_cost_rate,
              l_pa_ci_direct_cost8.resource_assignment_id,
              l_pa_ci_direct_cost8.effective_from,
              l_pa_ci_direct_cost8.effective_to,
              l_pa_ci_direct_cost8.change_reason_code,
              l_pa_ci_direct_cost8.change_description,
              l_pa_ci_direct_cost8.created_by,
              l_pa_ci_direct_cost8.creation_date,
              l_pa_ci_direct_cost8.last_update_by,
              l_pa_ci_direct_cost8.last_update_date,
              l_pa_ci_direct_cost8.last_update_login;
    x_no_data_found := pa_ci_direct_cost_d6%NOTFOUND;

    CLOSE pa_ci_direct_cost_d6;

    RETURN(l_pa_ci_direct_cost8);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN PaCiDirectCostDetailsRecType IS
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8 := get_rec(p_pa_ci_direct_cost1, l_row_notfound);
    IF (l_row_notfound) THEN
      PA_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'DC_LINE_ID');
      x_return_status := PA_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pa_ci_direct_cost8);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType
  ) RETURN PaCiDirectCostDetailsRecType IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pa_ci_direct_cost1, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: PA_CI_DIRECT_COST_DETAILS
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pa_ci_direct_cost1   IN PaCiDirectCostDetailsRecType
  ) RETURN PaCiDirectCostDetailsRecType IS
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
  BEGIN
    IF (l_pa_ci_direct_cost8.dc_line_id = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.dc_line_id := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.ci_id = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.ci_id := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.project_id = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.project_id := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.task_id = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.task_id := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.expenditure_type = PA_API.G_MISS_CHAR ) THEN
      l_pa_ci_direct_cost8.expenditure_type := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.resource_list_member_id = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.resource_list_member_id := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.unit_of_measure = PA_API.G_MISS_CHAR ) THEN
      l_pa_ci_direct_cost8.unit_of_measure := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.currency_code = PA_API.G_MISS_CHAR ) THEN
      l_pa_ci_direct_cost8.currency_code := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.quantity = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.quantity := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.planning_resource_rate = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.planning_resource_rate := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.raw_cost = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.raw_cost := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.burdened_cost = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.burdened_cost := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.raw_cost_rate = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.raw_cost_rate := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.burden_cost_rate = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.burden_cost_rate := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.resource_assignment_id = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.resource_assignment_id := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.effective_from = PA_API.G_MISS_DATE ) THEN
      l_pa_ci_direct_cost8.effective_from := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.effective_to = PA_API.G_MISS_DATE ) THEN
      l_pa_ci_direct_cost8.effective_to := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.change_reason_code = PA_API.G_MISS_CHAR ) THEN
      l_pa_ci_direct_cost8.change_reason_code := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.change_description = PA_API.G_MISS_CHAR ) THEN
      l_pa_ci_direct_cost8.change_description := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.created_by = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.created_by := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.creation_date = PA_API.G_MISS_DATE ) THEN
      l_pa_ci_direct_cost8.creation_date := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.last_update_by = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.last_update_by := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.last_update_date = PA_API.G_MISS_DATE ) THEN
      l_pa_ci_direct_cost8.last_update_date := NULL;
    END IF;
    IF (l_pa_ci_direct_cost8.last_update_login = PA_API.G_MISS_NUM ) THEN
      l_pa_ci_direct_cost8.last_update_login := NULL;
    END IF;
    RETURN(l_pa_ci_direct_cost8);
  END null_out_defaults;
  -----------------------------------------
  -- Validate_Attributes for: DC_LINE_ID --
  -----------------------------------------
  PROCEDURE validate_dc_line_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_dc_line_id                   IN NUMBER) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_dc_line_id = PA_API.G_MISS_NUM OR
        p_dc_line_id IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'dc_line_id');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_dc_line_id;
  ------------------------------------
  -- Validate_Attributes for: CI_ID --
  ------------------------------------
  PROCEDURE validate_ci_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ci_id                        IN NUMBER) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_ci_id = PA_API.G_MISS_NUM OR
        p_ci_id IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ci_id');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_ci_id;
  -----------------------------------------
  -- Validate_Attributes for: PROJECT_ID --
  -----------------------------------------
  PROCEDURE validate_project_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_project_id                   IN NUMBER) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_project_id = PA_API.G_MISS_NUM OR
        p_project_id IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'project_id');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_project_id;
  --------------------------------------
  -- Validate_Attributes for: TASK_ID --
  --------------------------------------
  PROCEDURE validate_task_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_task_id                      IN NUMBER) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_task_id = PA_API.G_MISS_NUM OR
        p_task_id IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'task_id');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_task_id;
  -----------------------------------------------
  -- Validate_Attributes for: EXPENDITURE_TYPE --
  -----------------------------------------------
  PROCEDURE validate_expenditure_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_expenditure_type             IN VARCHAR2) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_expenditure_type = PA_API.G_MISS_CHAR OR
        p_expenditure_type IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'expenditure_type');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_expenditure_type;
  ------------------------------------------------------
  -- Validate_Attributes for: RESOURCE_LIST_MEMBER_ID --
  ------------------------------------------------------
  PROCEDURE validate_resource_l94(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_resource_list_member_id      IN NUMBER) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_resource_list_member_id = PA_API.G_MISS_NUM OR
        p_resource_list_member_id IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'resource_list_member_id');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_resource_l94;
  ---------------------------------------------
  -- Validate_Attributes for: LAST_UPDATE_BY --
  ---------------------------------------------
  PROCEDURE validate_last_update_by(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_last_update_by               IN NUMBER) IS
  BEGIN
    x_return_status := PA_API.G_RET_STS_SUCCESS;
    IF (p_last_update_by = PA_API.G_MISS_NUM OR
        p_last_update_by IS NULL)
    THEN
      PA_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'last_update_by');
      x_return_status := PA_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
  END validate_last_update_by;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:PA_CI_DIRECT_COST_DETAILS --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- dc_line_id
    -- ***
    validate_dc_line_id(x_return_status, p_pa_ci_direct_cost1.dc_line_id);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- ci_id
    -- ***
    validate_ci_id(x_return_status, p_pa_ci_direct_cost1.ci_id);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- project_id
    -- ***
    validate_project_id(x_return_status, p_pa_ci_direct_cost1.project_id);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- task_id
    -- ***
    validate_task_id(x_return_status, p_pa_ci_direct_cost1.task_id);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- expenditure_type
    -- ***
    validate_expenditure_type(x_return_status, p_pa_ci_direct_cost1.expenditure_type);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- resource_list_member_id
    -- ***
    validate_resource_l94(x_return_status, p_pa_ci_direct_cost1.resource_list_member_id);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- last_update_by
    -- ***
    validate_last_update_by(x_return_status, p_pa_ci_direct_cost1.last_update_by);
    IF (x_return_status <> PA_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      PA_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate Record for:PA_CI_DIRECT_COST_DETAILS --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType,
    p_db_pa_ci_direct_cos106 IN PaCiDirectCostDetailsRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_db_pa_ci_direct_cos106       PaCiDirectCostDetailsRecType := get_rec(p_pa_ci_direct_cost1);
  BEGIN
    l_return_status := Validate_Record(p_pa_ci_direct_cost1 => p_pa_ci_direct_cost1,
                                       p_db_pa_ci_direct_cos106 => l_db_pa_ci_direct_cos106);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN PaCiDirectCostDetailsRecType,
    p_to   IN OUT NOCOPY PaCiDirectCostDetailsRecType
  ) IS
  BEGIN
    p_to.dc_line_id := p_from.dc_line_id;
    p_to.ci_id := p_from.ci_id;
    p_to.project_id := p_from.project_id;
    p_to.task_id := p_from.task_id;
    p_to.expenditure_type := p_from.expenditure_type;
    p_to.resource_list_member_id := p_from.resource_list_member_id;
    p_to.unit_of_measure := p_from.unit_of_measure;
    p_to.currency_code := p_from.currency_code;
    p_to.quantity := p_from.quantity;
    p_to.planning_resource_rate := p_from.planning_resource_rate;
    p_to.raw_cost := p_from.raw_cost;
    p_to.burdened_cost := p_from.burdened_cost;
    p_to.raw_cost_rate := p_from.raw_cost_rate;
    p_to.burden_cost_rate := p_from.burden_cost_rate;
    p_to.resource_assignment_id := p_from.resource_assignment_id;
    p_to.effective_from := p_from.effective_from;
    p_to.effective_to := p_from.effective_to;
    p_to.change_reason_code := p_from.change_reason_code;
    p_to.change_description := p_from.change_description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_by := p_from.last_update_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- validate_row for:PA_CI_DIRECT_COST_DETAILS --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
  BEGIN
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_pa_ci_direct_cost8);
    --- If any errors happen abort API
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pa_ci_direct_cost8);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:PA_CI_DIRECT_COST_DETAILS --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      i := PPaCiDirectCostDetailsTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         PA_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => PA_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_pa_ci_direct_cost1           => PPaCiDirectCostDetailsTbl(i));
          IF (l_error_rec.error_type <> PA_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN PA_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = PPaCiDirectCostDetailsTbl.LAST);
        i := PPaCiDirectCostDetailsTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:PA_CI_DIRECT_COST_DETAILS --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_error_tbl                    PA_API.ERROR_TBL_TYPE;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => PA_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        PPaCiDirectCostDetailsTbl      => PPaCiDirectCostDetailsTbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_dup_recs
  ---------------------------------------------------------------------------
  PROCEDURE check_dup_recs(p_DirectCostDetailsTbl PaCiDirectCostDetailsTblType) IS
  dup_record_exception EXCEPTION;
  BEGIN
    FOR i IN p_DirectCostDetailsTbl.FIRST..p_DirectCostDetailsTbl.LAST LOOP
      if i = p_DirectCostDetailsTbl.last then
        exit;
      end if;
      FOR j IN p_DirectCostDetailsTbl.NEXT(i)..p_DirectCostDetailsTbl.LAST LOOP
        IF p_DirectCostDetailsTbl(i).task_id = p_DirectCostDetailsTbl(j).task_id AND
           p_DirectCostDetailsTbl(i).expenditure_type = p_DirectCostDetailsTbl(j).expenditure_type AND
           p_DirectCostDetailsTbl(i).resource_list_member_id = p_DirectCostDetailsTbl(j).resource_list_member_id AND
           p_DirectCostDetailsTbl(i).currency_code = p_DirectCostDetailsTbl(j).currency_code THEN
             RAISE dup_record_exception;
        END IF;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN dup_record_exception THEN
         RAISE DUP_VAL_ON_INDEX;

  END check_dup_recs;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- insert_row for:PA_CI_DIRECT_COST_DETAILS --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    XPaCiDirectCostDetailsRec      OUT NOCOPY PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
    LDefPaCiDirectCostDetailsRec   PaCiDirectCostDetailsRecType;
    --------------------------------------------------
    -- Set_Attributes for:PA_CI_DIRECT_COST_DETAILS --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType,
      XPaCiDirectCostDetailsRec OUT NOCOPY PaCiDirectCostDetailsRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    BEGIN
      XPaCiDirectCostDetailsRec := p_pa_ci_direct_cost1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_pa_ci_direct_cost1,              -- IN
      l_pa_ci_direct_cost8);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO PA_CI_DIRECT_COST_DETAILS(
      dc_line_id,
      ci_id,
      project_id,
      task_id,
      expenditure_type,
      resource_list_member_id,
      unit_of_measure,
      currency_code,
      quantity,
      planning_resource_rate,
      raw_cost,
      burdened_cost,
      raw_cost_rate,
      burden_cost_rate,
      resource_assignment_id,
      effective_from,
      effective_to,
      change_reason_code,
      change_description,
      created_by,
      creation_date,
      last_update_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_pa_ci_direct_cost8.dc_line_id,
      l_pa_ci_direct_cost8.ci_id,
      l_pa_ci_direct_cost8.project_id,
      l_pa_ci_direct_cost8.task_id,
      l_pa_ci_direct_cost8.expenditure_type,
      l_pa_ci_direct_cost8.resource_list_member_id,
      l_pa_ci_direct_cost8.unit_of_measure,
      l_pa_ci_direct_cost8.currency_code,
      l_pa_ci_direct_cost8.quantity,
      l_pa_ci_direct_cost8.planning_resource_rate,
      l_pa_ci_direct_cost8.raw_cost,
      l_pa_ci_direct_cost8.burdened_cost,
      l_pa_ci_direct_cost8.raw_cost_rate,
      l_pa_ci_direct_cost8.burden_cost_rate,
      l_pa_ci_direct_cost8.resource_assignment_id,
      l_pa_ci_direct_cost8.effective_from,
      l_pa_ci_direct_cost8.effective_to,
      l_pa_ci_direct_cost8.change_reason_code,
      l_pa_ci_direct_cost8.change_description,
      l_pa_ci_direct_cost8.created_by,
      l_pa_ci_direct_cost8.creation_date,
      l_pa_ci_direct_cost8.last_update_by,
      l_pa_ci_direct_cost8.last_update_date,
      l_pa_ci_direct_cost8.last_update_login);
    -- Set OUT values
    XPaCiDirectCostDetailsRec := l_pa_ci_direct_cost8;
    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- insert_row for:PA_CI_DIRECT_COST_DETAILS --
  ----------------------------------------------
    PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing

    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN

      -- check if there are duplicate records entered by the user.
      -- the check happens on the input table parameter

      check_dup_recs(PPaCiDirectCostDetailsTbl);

      i := PPaCiDirectCostDetailsTbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => PA_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pa_ci_direct_cost1           => PPaCiDirectCostDetailsTbl(i),
          XPaCiDirectCostDetailsRec      => XPaCiDirectCostDetailsTbl(i));

        EXIT WHEN (i = PPaCiDirectCostDetailsTbl.LAST);
        i := PPaCiDirectCostDetailsTbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN DUP_VAL_ON_INDEX THEN
       PA_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'PA_FIN_SAME_PLANNING_ELEMENT');

      x_return_status := PA_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      x_return_status :=PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- lock_row for:PA_CI_DIRECT_COST_DETAILS --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType) IS
    SELECT *
      FROM PA_CI_DIRECT_COST_DETAILS
     WHERE DC_LINE_ID = p_pa_ci_direct_cost1.dc_line_id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_pa_ci_direct_cost1);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        PA_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      PA_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE PA_API.G_EXCEPTION_ERROR;
    ELSE

      IF (l_lock_var.dc_line_id <> p_pa_ci_direct_cost1.dc_line_id) THEN
        PA_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_lock_var.ci_id <> p_pa_ci_direct_cost1.ci_id) THEN
        PA_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.project_id <> p_pa_ci_direct_cost1.project_id) THEN
        PA_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.task_id <> p_pa_ci_direct_cost1.task_id) THEN
        PA_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.expenditure_type <> p_pa_ci_direct_cost1.expenditure_type) THEN
        PA_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.resource_list_member_id <> p_pa_ci_direct_cost1.resource_list_member_id) THEN
        PA_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------
  -- lock_row for: PA_CI_DIRECT_COST_DETAILS --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType;
  BEGIN
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_pa_ci_direct_cost1, l_pa_ci_direct_cost8);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pa_ci_direct_cost8
    );
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------------------------------
  -- PL/SQL TBL lock_row for:PA_CI_DIRECT_COST_DETAILS_TBL --
  -----------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      i := PPaCiDirectCostDetailsTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         PA_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => PA_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_pa_ci_direct_cost1           => PPaCiDirectCostDetailsTbl(i));
          IF (l_error_rec.error_type <> PA_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN PA_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = PPaCiDirectCostDetailsTbl.LAST);
        i := PPaCiDirectCostDetailsTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------------------------------
  -- PL/SQL TBL lock_row for:PA_CI_DIRECT_COST_DETAILS_TBL --
  -----------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_error_tbl                    PA_API.ERROR_TBL_TYPE;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => PA_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        PPaCiDirectCostDetailsTbl      => PPaCiDirectCostDetailsTbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- update_row for:PA_CI_DIRECT_COST_DETAILS --
  ----------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    XPaCiDirectCostDetailsRec      OUT NOCOPY PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
    LDefPaCiDirectCostDetailsRec   PaCiDirectCostDetailsRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType,
      XPaCiDirectCostDetailsRec OUT NOCOPY PaCiDirectCostDetailsRecType
    ) RETURN VARCHAR2 IS
      l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    BEGIN
      XPaCiDirectCostDetailsRec := p_pa_ci_direct_cost1;
      -- Get current database values
      l_pa_ci_direct_cost8 := get_rec(p_pa_ci_direct_cost1, l_return_status);
      IF (l_return_status = PA_API.G_RET_STS_SUCCESS) THEN
        IF (XPaCiDirectCostDetailsRec.dc_line_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.dc_line_id := l_pa_ci_direct_cost8.dc_line_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.ci_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.ci_id := l_pa_ci_direct_cost8.ci_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.project_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.project_id := l_pa_ci_direct_cost8.project_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.task_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.task_id := l_pa_ci_direct_cost8.task_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.expenditure_type = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.expenditure_type := l_pa_ci_direct_cost8.expenditure_type;
        END IF;
        IF (XPaCiDirectCostDetailsRec.resource_list_member_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.resource_list_member_id := l_pa_ci_direct_cost8.resource_list_member_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.unit_of_measure = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.unit_of_measure := l_pa_ci_direct_cost8.unit_of_measure;
        END IF;
        IF (XPaCiDirectCostDetailsRec.currency_code = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.currency_code := l_pa_ci_direct_cost8.currency_code;
        END IF;
        IF (XPaCiDirectCostDetailsRec.quantity = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.quantity := l_pa_ci_direct_cost8.quantity;
        END IF;
        IF (XPaCiDirectCostDetailsRec.planning_resource_rate = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.planning_resource_rate := l_pa_ci_direct_cost8.planning_resource_rate;
        END IF;
        IF (XPaCiDirectCostDetailsRec.raw_cost = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.raw_cost := l_pa_ci_direct_cost8.raw_cost;
        END IF;
        IF (XPaCiDirectCostDetailsRec.burdened_cost = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.burdened_cost := l_pa_ci_direct_cost8.burdened_cost;
        END IF;
        IF (XPaCiDirectCostDetailsRec.raw_cost_rate = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.raw_cost_rate := l_pa_ci_direct_cost8.raw_cost_rate;
        END IF;
        IF (XPaCiDirectCostDetailsRec.burden_cost_rate = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.burden_cost_rate := l_pa_ci_direct_cost8.burden_cost_rate;
        END IF;
        IF (XPaCiDirectCostDetailsRec.resource_assignment_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.resource_assignment_id := l_pa_ci_direct_cost8.resource_assignment_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.effective_from = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.effective_from := l_pa_ci_direct_cost8.effective_from;
        END IF;
        IF (XPaCiDirectCostDetailsRec.effective_to = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.effective_to := l_pa_ci_direct_cost8.effective_to;
        END IF;
        IF (XPaCiDirectCostDetailsRec.change_reason_code = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.change_reason_code := l_pa_ci_direct_cost8.change_reason_code;
        END IF;
        IF (XPaCiDirectCostDetailsRec.change_description = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.change_description := l_pa_ci_direct_cost8.change_description;
        END IF;
        IF (XPaCiDirectCostDetailsRec.created_by = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.created_by := l_pa_ci_direct_cost8.created_by;
        END IF;
        IF (XPaCiDirectCostDetailsRec.creation_date = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.creation_date := l_pa_ci_direct_cost8.creation_date;
        END IF;
        IF (XPaCiDirectCostDetailsRec.last_update_by = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.last_update_by := l_pa_ci_direct_cost8.last_update_by;
        END IF;
        IF (XPaCiDirectCostDetailsRec.last_update_date = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.last_update_date := l_pa_ci_direct_cost8.last_update_date;
        END IF;
        IF (XPaCiDirectCostDetailsRec.last_update_login = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.last_update_login := l_pa_ci_direct_cost8.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:PA_CI_DIRECT_COST_DETAILS --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType,
      XPaCiDirectCostDetailsRec OUT NOCOPY PaCiDirectCostDetailsRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    BEGIN
      XPaCiDirectCostDetailsRec := p_pa_ci_direct_cost1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pa_ci_direct_cost1,              -- IN
      l_pa_ci_direct_cost8);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pa_ci_direct_cost8, LDefPaCiDirectCostDetailsRec);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE PA_CI_DIRECT_COST_DETAILS
    SET CI_ID = LDefPaCiDirectCostDetailsRec.ci_id,
        PROJECT_ID = LDefPaCiDirectCostDetailsRec.project_id,
        TASK_ID = LDefPaCiDirectCostDetailsRec.task_id,
        EXPENDITURE_TYPE = LDefPaCiDirectCostDetailsRec.expenditure_type,
        RESOURCE_LIST_MEMBER_ID = LDefPaCiDirectCostDetailsRec.resource_list_member_id,
        UNIT_OF_MEASURE = LDefPaCiDirectCostDetailsRec.unit_of_measure,
        CURRENCY_CODE = LDefPaCiDirectCostDetailsRec.currency_code,
        QUANTITY = LDefPaCiDirectCostDetailsRec.quantity,
        PLANNING_RESOURCE_RATE = LDefPaCiDirectCostDetailsRec.planning_resource_rate,
        RAW_COST = LDefPaCiDirectCostDetailsRec.raw_cost,
        BURDENED_COST = LDefPaCiDirectCostDetailsRec.burdened_cost,
        RAW_COST_RATE = LDefPaCiDirectCostDetailsRec.raw_cost_rate,
        BURDEN_COST_RATE = LDefPaCiDirectCostDetailsRec.burden_cost_rate,
        RESOURCE_ASSIGNMENT_ID = LDefPaCiDirectCostDetailsRec.resource_assignment_id,
        EFFECTIVE_FROM = LDefPaCiDirectCostDetailsRec.effective_from,
        EFFECTIVE_TO = LDefPaCiDirectCostDetailsRec.effective_to,
        CHANGE_REASON_CODE = LDefPaCiDirectCostDetailsRec.change_reason_code,
        CHANGE_DESCRIPTION = LDefPaCiDirectCostDetailsRec.change_description,
        CREATED_BY = LDefPaCiDirectCostDetailsRec.created_by,
        CREATION_DATE = LDefPaCiDirectCostDetailsRec.creation_date,
        LAST_UPDATE_BY = LDefPaCiDirectCostDetailsRec.last_update_by,
        LAST_UPDATE_DATE = LDefPaCiDirectCostDetailsRec.last_update_date,
        LAST_UPDATE_LOGIN = LDefPaCiDirectCostDetailsRec.last_update_login
    WHERE DC_LINE_ID = LDefPaCiDirectCostDetailsRec.dc_line_id;

    XPaCiDirectCostDetailsRec := l_pa_ci_direct_cost8;
    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ----------------------------------------------
  -- update_row for:PA_CI_DIRECT_COST_DETAILS --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType,
    XPaCiDirectCostDetailsRec      OUT NOCOPY PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
    LDefPaCiDirectCostDetailsRec   PaCiDirectCostDetailsRecType;
    l_db_pa_ci_direct_cos106       PaCiDirectCostDetailsRecType;
    LxPaCiDirectCostDetailsRec     PaCiDirectCostDetailsRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType
    ) RETURN PaCiDirectCostDetailsRecType IS
      l_pa_ci_direct_cost8 PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
    BEGIN
      l_pa_ci_direct_cost8.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pa_ci_direct_cost8.CREATION_DATE := SYSDATE;
      l_pa_ci_direct_cost8.LAST_UPDATE_DATE := SYSDATE;
      l_pa_ci_direct_cost8.LAST_UPDATE_BY := FND_GLOBAL.USER_ID;
      l_pa_ci_direct_cost8.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pa_ci_direct_cost8);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType,
      XPaCiDirectCostDetailsRec OUT NOCOPY PaCiDirectCostDetailsRecType
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    BEGIN
      XPaCiDirectCostDetailsRec := p_pa_ci_direct_cost1;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_pa_ci_direct_cos106 := get_rec(p_pa_ci_direct_cost1, l_return_status);
      IF (l_return_status = PA_API.G_RET_STS_SUCCESS) THEN
        IF (XPaCiDirectCostDetailsRec.dc_line_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.dc_line_id := l_db_pa_ci_direct_cos106.dc_line_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.ci_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.ci_id := l_db_pa_ci_direct_cos106.ci_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.project_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.project_id := l_db_pa_ci_direct_cos106.project_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.task_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.task_id := l_db_pa_ci_direct_cos106.task_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.expenditure_type = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.expenditure_type := l_db_pa_ci_direct_cos106.expenditure_type;
        END IF;
        IF (XPaCiDirectCostDetailsRec.resource_list_member_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.resource_list_member_id := l_db_pa_ci_direct_cos106.resource_list_member_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.unit_of_measure = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.unit_of_measure := l_db_pa_ci_direct_cos106.unit_of_measure;
        END IF;
        IF (XPaCiDirectCostDetailsRec.currency_code = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.currency_code := l_db_pa_ci_direct_cos106.currency_code;
        END IF;
        IF (XPaCiDirectCostDetailsRec.quantity = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.quantity := l_db_pa_ci_direct_cos106.quantity;
        END IF;
        IF (XPaCiDirectCostDetailsRec.planning_resource_rate = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.planning_resource_rate := l_db_pa_ci_direct_cos106.planning_resource_rate;
        END IF;
        IF (XPaCiDirectCostDetailsRec.raw_cost = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.raw_cost := l_db_pa_ci_direct_cos106.raw_cost;
        END IF;
        IF (XPaCiDirectCostDetailsRec.burdened_cost = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.burdened_cost := l_db_pa_ci_direct_cos106.burdened_cost;
        END IF;
        IF (XPaCiDirectCostDetailsRec.raw_cost_rate = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.raw_cost_rate := l_db_pa_ci_direct_cos106.raw_cost_rate;
        END IF;
        IF (XPaCiDirectCostDetailsRec.burden_cost_rate = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.burden_cost_rate := l_db_pa_ci_direct_cos106.burden_cost_rate;
        END IF;
        IF (XPaCiDirectCostDetailsRec.resource_assignment_id = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.resource_assignment_id := l_db_pa_ci_direct_cos106.resource_assignment_id;
        END IF;
        IF (XPaCiDirectCostDetailsRec.effective_from = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.effective_from := l_db_pa_ci_direct_cos106.effective_from;
        END IF;
        IF (XPaCiDirectCostDetailsRec.effective_to = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.effective_to := l_db_pa_ci_direct_cos106.effective_to;
        END IF;
        IF (XPaCiDirectCostDetailsRec.change_reason_code = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.change_reason_code := l_db_pa_ci_direct_cos106.change_reason_code;
        END IF;
        IF (XPaCiDirectCostDetailsRec.change_description = PA_API.G_MISS_CHAR)
        THEN
          XPaCiDirectCostDetailsRec.change_description := l_db_pa_ci_direct_cos106.change_description;
        END IF;
        IF (XPaCiDirectCostDetailsRec.created_by = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.created_by := l_db_pa_ci_direct_cos106.created_by;
        END IF;
        IF (XPaCiDirectCostDetailsRec.creation_date = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.creation_date := l_db_pa_ci_direct_cos106.creation_date;
        END IF;
        IF (XPaCiDirectCostDetailsRec.last_update_by = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.last_update_by := l_db_pa_ci_direct_cos106.last_update_by;
        END IF;
        IF (XPaCiDirectCostDetailsRec.last_update_date = PA_API.G_MISS_DATE)
        THEN
          XPaCiDirectCostDetailsRec.last_update_date := l_db_pa_ci_direct_cos106.last_update_date;
        END IF;
        IF (XPaCiDirectCostDetailsRec.last_update_login = PA_API.G_MISS_NUM)
        THEN
          XPaCiDirectCostDetailsRec.last_update_login := l_db_pa_ci_direct_cos106.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:PA_CI_DIRECT_COST_DETAILS --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_pa_ci_direct_cost1 IN PaCiDirectCostDetailsRecType,
      XPaCiDirectCostDetailsRec OUT NOCOPY PaCiDirectCostDetailsRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    BEGIN
      XPaCiDirectCostDetailsRec := p_pa_ci_direct_cost1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pa_ci_direct_cost1,              -- IN
      XPaCiDirectCostDetailsRec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_pa_ci_direct_cost8, LDefPaCiDirectCostDetailsRec);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    LDefPaCiDirectCostDetailsRec := fill_who_columns(LDefPaCiDirectCostDetailsRec);

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefPaCiDirectCostDetailsRec);
    --- If any errors happen abort API
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(LDefPaCiDirectCostDetailsRec, l_db_pa_ci_direct_cos106);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_pa_ci_direct_cost1           => p_pa_ci_direct_cost1);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefPaCiDirectCostDetailsRec, l_pa_ci_direct_cost8);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------

    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pa_ci_direct_cost8,
      LxPaCiDirectCostDetailsRec
    );
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxPaCiDirectCostDetailsRec, LDefPaCiDirectCostDetailsRec);
    XPaCiDirectCostDetailsRec := LDefPaCiDirectCostDetailsRec;
    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -------------------------------------------------------------
  -- PL/SQL TBL update_row for:pa_ci_direct_cost_details_tbl --
  -------------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      i := PPaCiDirectCostDetailsTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         PA_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => PA_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_pa_ci_direct_cost1           => PPaCiDirectCostDetailsTbl(i),
            XPaCiDirectCostDetailsRec      => XPaCiDirectCostDetailsTbl(i));
          IF (l_error_rec.error_type <> PA_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN PA_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = PPaCiDirectCostDetailsTbl.LAST);
        i := PPaCiDirectCostDetailsTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  -------------------------------------------------------------
  -- PL/SQL TBL update_row for:PA_CI_DIRECT_COST_DETAILS_TBL --
  -------------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    XPaCiDirectCostDetailsTbl      OUT NOCOPY PaCiDirectCostDetailsTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_error_tbl                    PA_API.ERROR_TBL_TYPE;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => PA_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        PPaCiDirectCostDetailsTbl      => PPaCiDirectCostDetailsTbl,
        XPaCiDirectCostDetailsTbl      => XPaCiDirectCostDetailsTbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- delete_row for:PA_CI_DIRECT_COST_DETAILS --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM PA_CI_DIRECT_COST_DETAILS
     WHERE DC_LINE_ID = p_pa_ci_direct_cost1.dc_line_id;

    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------------
  -- delete_row for:PA_CI_DIRECT_COST_DETAILS --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pa_ci_direct_cost1           IN PaCiDirectCostDetailsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_pa_ci_direct_cost8           PaCiDirectCostDetailsRecType := p_pa_ci_direct_cost1;
  BEGIN
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_pa_ci_direct_cost8, l_pa_ci_direct_cost8);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pa_ci_direct_cost8
    );
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:PA_CI_DIRECT_COST_DETAILS --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType,
    px_error_tbl                   IN OUT NOCOPY PA_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      i := PPaCiDirectCostDetailsTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         PA_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => PA_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_pa_ci_direct_cost1           => PPaCiDirectCostDetailsTbl(i));
          IF (l_error_rec.error_type <> PA_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN PA_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := PA_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = PPaCiDirectCostDetailsTbl.LAST);
        i := PPaCiDirectCostDetailsTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:PA_CI_DIRECT_COST_DETAILS --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT PA_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    PPaCiDirectCostDetailsTbl      IN PaCiDirectCostDetailsTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
    l_error_tbl                    PA_API.ERROR_TBL_TYPE;
  BEGIN
    PA_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (PPaCiDirectCostDetailsTbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => PA_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        PPaCiDirectCostDetailsTbl      => PPaCiDirectCostDetailsTbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END PA_CI_DIR_COST_PVT;

/

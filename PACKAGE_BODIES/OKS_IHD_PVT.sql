--------------------------------------------------------
--  DDL for Package Body OKS_IHD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IHD_PVT" AS
/* $Header: OKSSIHDB.pls 120.3 2005/10/08 00:08 upillai noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

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
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

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
  -- FUNCTION get_rec for: OKS_INST_HIST_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ihdv_rec                     IN ihdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ihdv_rec_type IS
    CURSOR oks_ihdv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            INS_ID,
            TRANSACTION_DATE,
            TRANSACTION_TYPE,
            SYSTEM_ID,
            INSTANCE_ID_NEW,
            INSTANCE_QTY_OLD,
            INSTANCE_QTY_NEW,
            INSTANCE_AMT_OLD,
            INSTANCE_AMT_NEW,
            OLD_CONTRACT_ID,
            OLD_CONTACT_START_DATE,
            OLD_CONTRACT_END_DATE,
            NEW_CONTRACT_ID,
            NEW_CONTACT_START_DATE,
            NEW_CONTRACT_END_DATE,
            OLD_SERVICE_LINE_ID,
            OLD_SERVICE_START_DATE,
            OLD_SERVICE_END_DATE,
            NEW_SERVICE_LINE_ID,
            NEW_SERVICE_START_DATE,
            NEW_SERVICE_END_DATE,
            OLD_SUBLINE_ID,
            OLD_SUBLINE_START_DATE,
            OLD_SUBLINE_END_DATE,
            NEW_SUBLINE_ID,
            NEW_SUBLINE_START_DATE,
            NEW_SUBLINE_END_DATE,
            OLD_CUSTOMER,
            NEW_CUSTOMER,
            OLD_K_STATUS,
            NEW_K_STATUS,
            SUBLINE_DATE_TERMINATED,
            TRANSFER_OPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID,
            DATE_CANCELLED
      FROM Oks_Inst_Hist_Details_V
     WHERE oks_inst_hist_details_v.id = p_id;
    l_oks_ihdv_pk                  oks_ihdv_pk_csr%ROWTYPE;
    l_ihdv_rec                     ihdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_ihdv_pk_csr (p_ihdv_rec.id);
    FETCH oks_ihdv_pk_csr INTO
              l_ihdv_rec.id,
              l_ihdv_rec.ins_id,
              l_ihdv_rec.transaction_date,
              l_ihdv_rec.transaction_type,
              l_ihdv_rec.system_id,
              l_ihdv_rec.instance_id_new,
              l_ihdv_rec.instance_qty_old,
              l_ihdv_rec.instance_qty_new,
              l_ihdv_rec.instance_amt_old,
              l_ihdv_rec.instance_amt_new,
              l_ihdv_rec.old_contract_id,
              l_ihdv_rec.old_contact_start_date,
              l_ihdv_rec.old_contract_end_date,
              l_ihdv_rec.new_contract_id,
              l_ihdv_rec.new_contact_start_date,
              l_ihdv_rec.new_contract_end_date,
              l_ihdv_rec.old_service_line_id,
              l_ihdv_rec.old_service_start_date,
              l_ihdv_rec.old_service_end_date,
              l_ihdv_rec.new_service_line_id,
              l_ihdv_rec.new_service_start_date,
              l_ihdv_rec.new_service_end_date,
              l_ihdv_rec.old_subline_id,
              l_ihdv_rec.old_subline_start_date,
              l_ihdv_rec.old_subline_end_date,
              l_ihdv_rec.new_subline_id,
              l_ihdv_rec.new_subline_start_date,
              l_ihdv_rec.new_subline_end_date,
              l_ihdv_rec.old_customer,
              l_ihdv_rec.new_customer,
              l_ihdv_rec.old_k_status,
              l_ihdv_rec.new_k_status,
              l_ihdv_rec.subline_date_terminated,
              l_ihdv_rec.transfer_option,
              l_ihdv_rec.created_by,
              l_ihdv_rec.creation_date,
              l_ihdv_rec.last_updated_by,
              l_ihdv_rec.last_update_date,
              l_ihdv_rec.last_update_login,
              l_ihdv_rec.object_version_number,
              l_ihdv_rec.security_group_id,
              l_ihdv_rec.date_cancelled;
    x_no_data_found := oks_ihdv_pk_csr%NOTFOUND;
    CLOSE oks_ihdv_pk_csr;
    RETURN(l_ihdv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ihdv_rec                     IN ihdv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ihdv_rec_type IS
    l_ihdv_rec                     ihdv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ihdv_rec := get_rec(p_ihdv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ihdv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ihdv_rec                     IN ihdv_rec_type
  ) RETURN ihdv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ihdv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_INST_HIST_DETAILS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ihd_rec                      IN ihd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ihd_rec_type IS
    CURSOR oks_inst_hist_details_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            INS_ID,
            TRANSACTION_DATE,
            TRANSACTION_TYPE,
            SYSTEM_ID,
            INSTANCE_ID_NEW,
            INSTANCE_QTY_OLD,
            INSTANCE_QTY_NEW,
            INSTANCE_AMT_OLD,
            INSTANCE_AMT_NEW,
            OLD_CONTRACT_ID,
            OLD_CONTACT_START_DATE,
            OLD_CONTRACT_END_DATE,
            NEW_CONTRACT_ID,
            NEW_CONTACT_START_DATE,
            NEW_CONTRACT_END_DATE,
            OLD_SERVICE_LINE_ID,
            OLD_SERVICE_START_DATE,
            OLD_SERVICE_END_DATE,
            NEW_SERVICE_LINE_ID,
            NEW_SERVICE_START_DATE,
            NEW_SERVICE_END_DATE,
            OLD_SUBLINE_ID,
            OLD_SUBLINE_START_DATE,
            OLD_SUBLINE_END_DATE,
            NEW_SUBLINE_ID,
            NEW_SUBLINE_START_DATE,
            NEW_SUBLINE_END_DATE,
            OLD_CUSTOMER,
            NEW_CUSTOMER,
            OLD_K_STATUS,
            NEW_K_STATUS,
            SUBLINE_DATE_TERMINATED,
            TRANSFER_OPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
            DATE_CANCELLED
      FROM Oks_Inst_Hist_Details
     WHERE oks_inst_hist_details.id = p_id;
    l_oks_inst_hist_details_pk     oks_inst_hist_details_pk_csr%ROWTYPE;
    l_ihd_rec                      ihd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_inst_hist_details_pk_csr (p_ihd_rec.id);
    FETCH oks_inst_hist_details_pk_csr INTO
              l_ihd_rec.id,
              l_ihd_rec.ins_id,
              l_ihd_rec.transaction_date,
              l_ihd_rec.transaction_type,
              l_ihd_rec.system_id,
              l_ihd_rec.instance_id_new,
              l_ihd_rec.instance_qty_old,
              l_ihd_rec.instance_qty_new,
              l_ihd_rec.instance_amt_old,
              l_ihd_rec.instance_amt_new,
              l_ihd_rec.old_contract_id,
              l_ihd_rec.old_contact_start_date,
              l_ihd_rec.old_contract_end_date,
              l_ihd_rec.new_contract_id,
              l_ihd_rec.new_contact_start_date,
              l_ihd_rec.new_contract_end_date,
              l_ihd_rec.old_service_line_id,
              l_ihd_rec.old_service_start_date,
              l_ihd_rec.old_service_end_date,
              l_ihd_rec.new_service_line_id,
              l_ihd_rec.new_service_start_date,
              l_ihd_rec.new_service_end_date,
              l_ihd_rec.old_subline_id,
              l_ihd_rec.old_subline_start_date,
              l_ihd_rec.old_subline_end_date,
              l_ihd_rec.new_subline_id,
              l_ihd_rec.new_subline_start_date,
              l_ihd_rec.new_subline_end_date,
              l_ihd_rec.old_customer,
              l_ihd_rec.new_customer,
              l_ihd_rec.old_k_status,
              l_ihd_rec.new_k_status,
              l_ihd_rec.subline_date_terminated,
              l_ihd_rec.transfer_option,
              l_ihd_rec.created_by,
              l_ihd_rec.creation_date,
              l_ihd_rec.last_updated_by,
              l_ihd_rec.last_update_date,
              l_ihd_rec.last_update_login,
              l_ihd_rec.object_version_number,
              l_ihd_rec.date_cancelled;
    x_no_data_found := oks_inst_hist_details_pk_csr%NOTFOUND;
    CLOSE oks_inst_hist_details_pk_csr;
    RETURN(l_ihd_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ihd_rec                      IN ihd_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ihd_rec_type IS
    l_ihd_rec                      ihd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ihd_rec := get_rec(p_ihd_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ihd_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ihd_rec                      IN ihd_rec_type
  ) RETURN ihd_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ihd_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_INST_HIST_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ihdv_rec   IN ihdv_rec_type
  ) RETURN ihdv_rec_type IS
    l_ihdv_rec                     ihdv_rec_type := p_ihdv_rec;
  BEGIN
    IF (l_ihdv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.id := NULL;
    END IF;
    IF (l_ihdv_rec.ins_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.ins_id := NULL;
    END IF;
    IF (l_ihdv_rec.transaction_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.transaction_date := NULL;
    END IF;
    IF (l_ihdv_rec.transaction_type = OKC_API.G_MISS_CHAR ) THEN
      l_ihdv_rec.transaction_type := NULL;
    END IF;
    IF (l_ihdv_rec.system_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.system_id := NULL;
    END IF;
    IF (l_ihdv_rec.instance_id_new = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.instance_id_new := NULL;
    END IF;
    IF (l_ihdv_rec.instance_qty_old = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.instance_qty_old := NULL;
    END IF;
    IF (l_ihdv_rec.instance_qty_new = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.instance_qty_new := NULL;
    END IF;
    IF (l_ihdv_rec.instance_amt_old = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.instance_amt_old := NULL;
    END IF;
    IF (l_ihdv_rec.instance_amt_new = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.instance_amt_new := NULL;
    END IF;
    IF (l_ihdv_rec.old_contract_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.old_contract_id := NULL;
    END IF;
    IF (l_ihdv_rec.old_contact_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.old_contact_start_date := NULL;
    END IF;
    IF (l_ihdv_rec.old_contract_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.old_contract_end_date := NULL;
    END IF;
    IF (l_ihdv_rec.new_contract_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.new_contract_id := NULL;
    END IF;
    IF (l_ihdv_rec.new_contact_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.new_contact_start_date := NULL;
    END IF;
    IF (l_ihdv_rec.new_contract_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.new_contract_end_date := NULL;
    END IF;
    IF (l_ihdv_rec.old_service_line_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.old_service_line_id := NULL;
    END IF;
    IF (l_ihdv_rec.old_service_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.old_service_start_date := NULL;
    END IF;
    IF (l_ihdv_rec.old_service_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.old_service_end_date := NULL;
    END IF;
    IF (l_ihdv_rec.new_service_line_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.new_service_line_id := NULL;
    END IF;
    IF (l_ihdv_rec.new_service_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.new_service_start_date := NULL;
    END IF;
    IF (l_ihdv_rec.new_service_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.new_service_end_date := NULL;
    END IF;
    IF (l_ihdv_rec.old_subline_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.old_subline_id := NULL;
    END IF;
    IF (l_ihdv_rec.old_subline_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.old_subline_start_date := NULL;
    END IF;
    IF (l_ihdv_rec.old_subline_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.old_subline_end_date := NULL;
    END IF;
    IF (l_ihdv_rec.new_subline_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.new_subline_id := NULL;
    END IF;
    IF (l_ihdv_rec.new_subline_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.new_subline_start_date := NULL;
    END IF;
    IF (l_ihdv_rec.new_subline_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.new_subline_end_date := NULL;
    END IF;
    IF (l_ihdv_rec.old_customer = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.old_customer := NULL;
    END IF;
    IF (l_ihdv_rec.new_customer = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.new_customer := NULL;
    END IF;
    IF (l_ihdv_rec.old_k_status = OKC_API.G_MISS_CHAR ) THEN
      l_ihdv_rec.old_k_status := NULL;
    END IF;
    IF (l_ihdv_rec.new_k_status = OKC_API.G_MISS_CHAR ) THEN
      l_ihdv_rec.new_k_status := NULL;
    END IF;
    IF (l_ihdv_rec.subline_date_terminated = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.subline_date_terminated := NULL;
    END IF;
    IF (l_ihdv_rec.transfer_option = OKC_API.G_MISS_CHAR ) THEN
      l_ihdv_rec.transfer_option := NULL;
    END IF;
    IF (l_ihdv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.created_by := NULL;
    END IF;
    IF (l_ihdv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.creation_date := NULL;
    END IF;
    IF (l_ihdv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ihdv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.last_update_date := NULL;
    END IF;
    IF (l_ihdv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.last_update_login := NULL;
    END IF;
    IF (l_ihdv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.object_version_number := NULL;
    END IF;
    IF (l_ihdv_rec.security_group_id = OKC_API.G_MISS_NUM ) THEN
      l_ihdv_rec.security_group_id := NULL;
    END IF;
    IF (l_ihdv_rec.date_cancelled = OKC_API.G_MISS_DATE ) THEN
      l_ihdv_rec.date_cancelled := NULL;
    END IF;
    RETURN(l_ihdv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKS_INST_HIST_DETAILS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ihdv_rec                     IN ihdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_ihdv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_ihdv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate Record for:OKS_INST_HIST_DETAILS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_ihdv_rec IN ihdv_rec_type,
    p_db_ihdv_rec IN ihdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_ihdv_rec IN ihdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_ihdv_rec                  ihdv_rec_type := get_rec(p_ihdv_rec);
  BEGIN
    l_return_status := Validate_Record(p_ihdv_rec => p_ihdv_rec,
                                       p_db_ihdv_rec => l_db_ihdv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN ihdv_rec_type,
    p_to   IN OUT NOCOPY ihd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ins_id := p_from.ins_id;
    p_to.transaction_date := p_from.transaction_date;
    p_to.transaction_type := p_from.transaction_type;
    p_to.system_id := p_from.system_id;
    p_to.instance_id_new := p_from.instance_id_new;
    p_to.instance_qty_old := p_from.instance_qty_old;
    p_to.instance_qty_new := p_from.instance_qty_new;
    p_to.instance_amt_old := p_from.instance_amt_old;
    p_to.instance_amt_new := p_from.instance_amt_new;
    p_to.old_contract_id := p_from.old_contract_id;
    p_to.old_contact_start_date := p_from.old_contact_start_date;
    p_to.old_contract_end_date := p_from.old_contract_end_date;
    p_to.new_contract_id := p_from.new_contract_id;
    p_to.new_contact_start_date := p_from.new_contact_start_date;
    p_to.new_contract_end_date := p_from.new_contract_end_date;
    p_to.old_service_line_id := p_from.old_service_line_id;
    p_to.old_service_start_date := p_from.old_service_start_date;
    p_to.old_service_end_date := p_from.old_service_end_date;
    p_to.new_service_line_id := p_from.new_service_line_id;
    p_to.new_service_start_date := p_from.new_service_start_date;
    p_to.new_service_end_date := p_from.new_service_end_date;
    p_to.old_subline_id := p_from.old_subline_id;
    p_to.old_subline_start_date := p_from.old_subline_start_date;
    p_to.old_subline_end_date := p_from.old_subline_end_date;
    p_to.new_subline_id := p_from.new_subline_id;
    p_to.new_subline_start_date := p_from.new_subline_start_date;
    p_to.new_subline_end_date := p_from.new_subline_end_date;
    p_to.old_customer := p_from.old_customer;
    p_to.new_customer := p_from.new_customer;
    p_to.old_k_status := p_from.old_k_status;
    p_to.new_k_status := p_from.new_k_status;
    p_to.subline_date_terminated := p_from.subline_date_terminated;
    p_to.transfer_option := p_from.transfer_option;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_cancelled := p_from.date_cancelled;
  END migrate;
  PROCEDURE migrate (
    p_from IN ihd_rec_type,
    p_to   IN OUT NOCOPY ihdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ins_id := p_from.ins_id;
    p_to.transaction_date := p_from.transaction_date;
    p_to.transaction_type := p_from.transaction_type;
    p_to.system_id := p_from.system_id;
    p_to.instance_id_new := p_from.instance_id_new;
    p_to.instance_qty_old := p_from.instance_qty_old;
    p_to.instance_qty_new := p_from.instance_qty_new;
    p_to.instance_amt_old := p_from.instance_amt_old;
    p_to.instance_amt_new := p_from.instance_amt_new;
    p_to.old_contract_id := p_from.old_contract_id;
    p_to.old_contact_start_date := p_from.old_contact_start_date;
    p_to.old_contract_end_date := p_from.old_contract_end_date;
    p_to.new_contract_id := p_from.new_contract_id;
    p_to.new_contact_start_date := p_from.new_contact_start_date;
    p_to.new_contract_end_date := p_from.new_contract_end_date;
    p_to.old_service_line_id := p_from.old_service_line_id;
    p_to.old_service_start_date := p_from.old_service_start_date;
    p_to.old_service_end_date := p_from.old_service_end_date;
    p_to.new_service_line_id := p_from.new_service_line_id;
    p_to.new_service_start_date := p_from.new_service_start_date;
    p_to.new_service_end_date := p_from.new_service_end_date;
    p_to.old_subline_id := p_from.old_subline_id;
    p_to.old_subline_start_date := p_from.old_subline_start_date;
    p_to.old_subline_end_date := p_from.old_subline_end_date;
    p_to.new_subline_id := p_from.new_subline_id;
    p_to.new_subline_start_date := p_from.new_subline_start_date;
    p_to.new_subline_end_date := p_from.new_subline_end_date;
    p_to.old_customer := p_from.old_customer;
    p_to.new_customer := p_from.new_customer;
    p_to.old_k_status := p_from.old_k_status;
    p_to.new_k_status := p_from.new_k_status;
    p_to.subline_date_terminated := p_from.subline_date_terminated;
    p_to.transfer_option := p_from.transfer_option;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_cancelled := p_from.date_cancelled;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKS_INST_HIST_DETAILS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihdv_rec                     ihdv_rec_type := p_ihdv_rec;
    l_ihd_rec                      ihd_rec_type;
    l_ihd_rec                      ihd_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ihdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ihdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_INST_HIST_DETAILS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      i := p_ihdv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ihdv_rec                     => p_ihdv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ihdv_tbl.LAST);
        i := p_ihdv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_INST_HIST_DETAILS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ihdv_tbl                     => p_ihdv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- insert_row for:OKS_INST_HIST_DETAILS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihd_rec                      IN ihd_rec_type,
    x_ihd_rec                      OUT NOCOPY ihd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihd_rec                      ihd_rec_type := p_ihd_rec;
    l_def_ihd_rec                  ihd_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKS_INST_HIST_DETAILS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ihd_rec IN ihd_rec_type,
      x_ihd_rec OUT NOCOPY ihd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ihd_rec := p_ihd_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_ihd_rec,                         -- IN
      l_ihd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_INST_HIST_DETAILS(
      id,
      ins_id,
      transaction_date,
      transaction_type,
      system_id,
      instance_id_new,
      instance_qty_old,
      instance_qty_new,
      instance_amt_old,
      instance_amt_new,
      old_contract_id,
      old_contact_start_date,
      old_contract_end_date,
      new_contract_id,
      new_contact_start_date,
      new_contract_end_date,
      old_service_line_id,
      old_service_start_date,
      old_service_end_date,
      new_service_line_id,
      new_service_start_date,
      new_service_end_date,
      old_subline_id,
      old_subline_start_date,
      old_subline_end_date,
      new_subline_id,
      new_subline_start_date,
      new_subline_end_date,
      old_customer,
      new_customer,
      old_k_status,
      new_k_status,
      subline_date_terminated,
      transfer_option,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number,
      date_cancelled)
    VALUES (
      l_ihd_rec.id,
      l_ihd_rec.ins_id,
      l_ihd_rec.transaction_date,
      l_ihd_rec.transaction_type,
      l_ihd_rec.system_id,
      l_ihd_rec.instance_id_new,
      l_ihd_rec.instance_qty_old,
      l_ihd_rec.instance_qty_new,
      l_ihd_rec.instance_amt_old,
      l_ihd_rec.instance_amt_new,
      l_ihd_rec.old_contract_id,
      l_ihd_rec.old_contact_start_date,
      l_ihd_rec.old_contract_end_date,
      l_ihd_rec.new_contract_id,
      l_ihd_rec.new_contact_start_date,
      l_ihd_rec.new_contract_end_date,
      l_ihd_rec.old_service_line_id,
      l_ihd_rec.old_service_start_date,
      l_ihd_rec.old_service_end_date,
      l_ihd_rec.new_service_line_id,
      l_ihd_rec.new_service_start_date,
      l_ihd_rec.new_service_end_date,
      l_ihd_rec.old_subline_id,
      l_ihd_rec.old_subline_start_date,
      l_ihd_rec.old_subline_end_date,
      l_ihd_rec.new_subline_id,
      l_ihd_rec.new_subline_start_date,
      l_ihd_rec.new_subline_end_date,
      l_ihd_rec.old_customer,
      l_ihd_rec.new_customer,
      l_ihd_rec.old_k_status,
      l_ihd_rec.new_k_status,
      l_ihd_rec.subline_date_terminated,
      l_ihd_rec.transfer_option,
      l_ihd_rec.created_by,
      l_ihd_rec.creation_date,
      l_ihd_rec.last_updated_by,
      l_ihd_rec.last_update_date,
      l_ihd_rec.last_update_login,
      l_ihd_rec.object_version_number,
      l_ihd_rec.date_cancelled);
    -- Set OUT values
    x_ihd_rec := l_ihd_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------------
  -- insert_row for :OKS_INST_HIST_DETAILS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type,
    x_ihdv_rec                     OUT NOCOPY ihdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihdv_rec                     ihdv_rec_type := p_ihdv_rec;
    l_def_ihdv_rec                 ihdv_rec_type;
    l_ihd_rec                      ihd_rec_type;
    lx_ihd_rec                     ihd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ihdv_rec IN ihdv_rec_type
    ) RETURN ihdv_rec_type IS
      l_ihdv_rec ihdv_rec_type := p_ihdv_rec;
    BEGIN
      l_ihdv_rec.CREATION_DATE := SYSDATE;
      l_ihdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ihdv_rec.LAST_UPDATE_DATE := l_ihdv_rec.CREATION_DATE;
      l_ihdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ihdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ihdv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKS_INST_HIST_DETAILS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_ihdv_rec IN ihdv_rec_type,
      x_ihdv_rec OUT NOCOPY ihdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ihdv_rec := p_ihdv_rec;
      x_ihdv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ihdv_rec := null_out_defaults(p_ihdv_rec);
    -- Set primary key value
    l_ihdv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_ihdv_rec,                        -- IN
      l_def_ihdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ihdv_rec := fill_who_columns(l_def_ihdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ihdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ihdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ihdv_rec, l_ihd_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ihd_rec,
      lx_ihd_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ihd_rec, l_def_ihdv_rec);
    -- Set OUT values
    x_ihdv_rec := l_def_ihdv_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:IHDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      i := p_ihdv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ihdv_rec                     => p_ihdv_tbl(i),
            x_ihdv_rec                     => x_ihdv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ihdv_tbl.LAST);
        i := p_ihdv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ----------------------------------------
  -- PL/SQL TBL insert_row for:IHDV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ihdv_tbl                     => p_ihdv_tbl,
        x_ihdv_tbl                     => x_ihdv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- lock_row for:OKS_INST_HIST_DETAILS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihd_rec                      IN ihd_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ihd_rec IN ihd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_INST_HIST_DETAILS
     WHERE ID = p_ihd_rec.id
       AND OBJECT_VERSION_NUMBER = p_ihd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_ihd_rec IN ihd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_INST_HIST_DETAILS
     WHERE ID = p_ihd_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_INST_HIST_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_INST_HIST_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ihd_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ihd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ihd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ihd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------------
  -- lock_row for: OKS_INST_HIST_DETAILS_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihd_rec                      ihd_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_ihdv_rec, l_ihd_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ihd_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:IHDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      i := p_ihdv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ihdv_rec                     => p_ihdv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ihdv_tbl.LAST);
        i := p_ihdv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:IHDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ihdv_tbl                     => p_ihdv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- update_row for:OKS_INST_HIST_DETAILS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihd_rec                      IN ihd_rec_type,
    x_ihd_rec                      OUT NOCOPY ihd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihd_rec                      ihd_rec_type := p_ihd_rec;
    l_def_ihd_rec                  ihd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ihd_rec IN ihd_rec_type,
      x_ihd_rec OUT NOCOPY ihd_rec_type
    ) RETURN VARCHAR2 IS
      l_ihd_rec                      ihd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ihd_rec := p_ihd_rec;
      -- Get current database values
      l_ihd_rec := get_rec(p_ihd_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ihd_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.id := l_ihd_rec.id;
        END IF;
        IF (x_ihd_rec.ins_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.ins_id := l_ihd_rec.ins_id;
        END IF;
        IF (x_ihd_rec.transaction_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.transaction_date := l_ihd_rec.transaction_date;
        END IF;
        IF (x_ihd_rec.transaction_type = OKC_API.G_MISS_CHAR)
        THEN
          x_ihd_rec.transaction_type := l_ihd_rec.transaction_type;
        END IF;
        IF (x_ihd_rec.system_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.system_id := l_ihd_rec.system_id;
        END IF;
        IF (x_ihd_rec.instance_id_new = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.instance_id_new := l_ihd_rec.instance_id_new;
        END IF;
        IF (x_ihd_rec.instance_qty_old = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.instance_qty_old := l_ihd_rec.instance_qty_old;
        END IF;
        IF (x_ihd_rec.instance_qty_new = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.instance_qty_new := l_ihd_rec.instance_qty_new;
        END IF;
        IF (x_ihd_rec.instance_amt_old = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.instance_amt_old := l_ihd_rec.instance_amt_old;
        END IF;
        IF (x_ihd_rec.instance_amt_new = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.instance_amt_new := l_ihd_rec.instance_amt_new;
        END IF;
        IF (x_ihd_rec.old_contract_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.old_contract_id := l_ihd_rec.old_contract_id;
        END IF;
        IF (x_ihd_rec.old_contact_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.old_contact_start_date := l_ihd_rec.old_contact_start_date;
        END IF;
        IF (x_ihd_rec.old_contract_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.old_contract_end_date := l_ihd_rec.old_contract_end_date;
        END IF;
        IF (x_ihd_rec.new_contract_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.new_contract_id := l_ihd_rec.new_contract_id;
        END IF;
        IF (x_ihd_rec.new_contact_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.new_contact_start_date := l_ihd_rec.new_contact_start_date;
        END IF;
        IF (x_ihd_rec.new_contract_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.new_contract_end_date := l_ihd_rec.new_contract_end_date;
        END IF;
        IF (x_ihd_rec.old_service_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.old_service_line_id := l_ihd_rec.old_service_line_id;
        END IF;
        IF (x_ihd_rec.old_service_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.old_service_start_date := l_ihd_rec.old_service_start_date;
        END IF;
        IF (x_ihd_rec.old_service_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.old_service_end_date := l_ihd_rec.old_service_end_date;
        END IF;
        IF (x_ihd_rec.new_service_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.new_service_line_id := l_ihd_rec.new_service_line_id;
        END IF;
        IF (x_ihd_rec.new_service_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.new_service_start_date := l_ihd_rec.new_service_start_date;
        END IF;
        IF (x_ihd_rec.new_service_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.new_service_end_date := l_ihd_rec.new_service_end_date;
        END IF;
        IF (x_ihd_rec.old_subline_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.old_subline_id := l_ihd_rec.old_subline_id;
        END IF;
        IF (x_ihd_rec.old_subline_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.old_subline_start_date := l_ihd_rec.old_subline_start_date;
        END IF;
        IF (x_ihd_rec.old_subline_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.old_subline_end_date := l_ihd_rec.old_subline_end_date;
        END IF;
        IF (x_ihd_rec.new_subline_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.new_subline_id := l_ihd_rec.new_subline_id;
        END IF;
        IF (x_ihd_rec.new_subline_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.new_subline_start_date := l_ihd_rec.new_subline_start_date;
        END IF;
        IF (x_ihd_rec.new_subline_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.new_subline_end_date := l_ihd_rec.new_subline_end_date;
        END IF;
        IF (x_ihd_rec.old_customer = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.old_customer := l_ihd_rec.old_customer;
        END IF;
        IF (x_ihd_rec.new_customer = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.new_customer := l_ihd_rec.new_customer;
        END IF;
        IF (x_ihd_rec.old_k_status = OKC_API.G_MISS_CHAR)
        THEN
          x_ihd_rec.old_k_status := l_ihd_rec.old_k_status;
        END IF;
        IF (x_ihd_rec.new_k_status = OKC_API.G_MISS_CHAR)
        THEN
          x_ihd_rec.new_k_status := l_ihd_rec.new_k_status;
        END IF;
        IF (x_ihd_rec.subline_date_terminated = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.subline_date_terminated := l_ihd_rec.subline_date_terminated;
        END IF;
        IF (x_ihd_rec.transfer_option = OKC_API.G_MISS_CHAR)
        THEN
          x_ihd_rec.transfer_option := l_ihd_rec.transfer_option;
        END IF;
        IF (x_ihd_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.created_by := l_ihd_rec.created_by;
        END IF;
        IF (x_ihd_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.creation_date := l_ihd_rec.creation_date;
        END IF;
        IF (x_ihd_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.last_updated_by := l_ihd_rec.last_updated_by;
        END IF;
        IF (x_ihd_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.last_update_date := l_ihd_rec.last_update_date;
        END IF;
        IF (x_ihd_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.last_update_login := l_ihd_rec.last_update_login;
        END IF;
        IF (x_ihd_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_ihd_rec.object_version_number := l_ihd_rec.object_version_number;
        END IF;
        IF (x_ihd_rec.date_cancelled = OKC_API.G_MISS_DATE)
        THEN
          x_ihd_rec.date_cancelled := l_ihd_rec.date_cancelled;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKS_INST_HIST_DETAILS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_ihd_rec IN ihd_rec_type,
      x_ihd_rec OUT NOCOPY ihd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ihd_rec := p_ihd_rec;
      x_ihd_rec.OBJECT_VERSION_NUMBER := p_ihd_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ihd_rec,                         -- IN
      l_ihd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ihd_rec, l_def_ihd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_INST_HIST_DETAILS
    SET INS_ID = l_def_ihd_rec.ins_id,
        TRANSACTION_DATE = l_def_ihd_rec.transaction_date,
        TRANSACTION_TYPE = l_def_ihd_rec.transaction_type,
        SYSTEM_ID = l_def_ihd_rec.system_id,
        INSTANCE_ID_NEW = l_def_ihd_rec.instance_id_new,
        INSTANCE_QTY_OLD = l_def_ihd_rec.instance_qty_old,
        INSTANCE_QTY_NEW = l_def_ihd_rec.instance_qty_new,
        INSTANCE_AMT_OLD = l_def_ihd_rec.instance_amt_old,
        INSTANCE_AMT_NEW = l_def_ihd_rec.instance_amt_new,
        OLD_CONTRACT_ID = l_def_ihd_rec.old_contract_id,
        OLD_CONTACT_START_DATE = l_def_ihd_rec.old_contact_start_date,
        OLD_CONTRACT_END_DATE = l_def_ihd_rec.old_contract_end_date,
        NEW_CONTRACT_ID = l_def_ihd_rec.new_contract_id,
        NEW_CONTACT_START_DATE = l_def_ihd_rec.new_contact_start_date,
        NEW_CONTRACT_END_DATE = l_def_ihd_rec.new_contract_end_date,
        OLD_SERVICE_LINE_ID = l_def_ihd_rec.old_service_line_id,
        OLD_SERVICE_START_DATE = l_def_ihd_rec.old_service_start_date,
        OLD_SERVICE_END_DATE = l_def_ihd_rec.old_service_end_date,
        NEW_SERVICE_LINE_ID = l_def_ihd_rec.new_service_line_id,
        NEW_SERVICE_START_DATE = l_def_ihd_rec.new_service_start_date,
        NEW_SERVICE_END_DATE = l_def_ihd_rec.new_service_end_date,
        OLD_SUBLINE_ID = l_def_ihd_rec.old_subline_id,
        OLD_SUBLINE_START_DATE = l_def_ihd_rec.old_subline_start_date,
        OLD_SUBLINE_END_DATE = l_def_ihd_rec.old_subline_end_date,
        NEW_SUBLINE_ID = l_def_ihd_rec.new_subline_id,
        NEW_SUBLINE_START_DATE = l_def_ihd_rec.new_subline_start_date,
        NEW_SUBLINE_END_DATE = l_def_ihd_rec.new_subline_end_date,
        OLD_CUSTOMER = l_def_ihd_rec.old_customer,
        NEW_CUSTOMER = l_def_ihd_rec.new_customer,
        OLD_K_STATUS = l_def_ihd_rec.old_k_status,
        NEW_K_STATUS = l_def_ihd_rec.new_k_status,
        SUBLINE_DATE_TERMINATED = l_def_ihd_rec.subline_date_terminated,
        TRANSFER_OPTION = l_def_ihd_rec.transfer_option,
        CREATED_BY = l_def_ihd_rec.created_by,
        CREATION_DATE = l_def_ihd_rec.creation_date,
        LAST_UPDATED_BY = l_def_ihd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ihd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ihd_rec.last_update_login,
        OBJECT_VERSION_NUMBER = l_def_ihd_rec.object_version_number,
        DATE_CANCELLED = l_def_ihd_rec.date_cancelled
    WHERE ID = l_def_ihd_rec.id;

    x_ihd_rec := l_ihd_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  --------------------------------------------
  -- update_row for:OKS_INST_HIST_DETAILS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type,
    x_ihdv_rec                     OUT NOCOPY ihdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihdv_rec                     ihdv_rec_type := p_ihdv_rec;
    l_def_ihdv_rec                 ihdv_rec_type;
    l_db_ihdv_rec                  ihdv_rec_type;
    l_ihd_rec                      ihd_rec_type;
    lx_ihd_rec                     ihd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ihdv_rec IN ihdv_rec_type
    ) RETURN ihdv_rec_type IS
      l_ihdv_rec ihdv_rec_type := p_ihdv_rec;
    BEGIN
      l_ihdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ihdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ihdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ihdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ihdv_rec IN ihdv_rec_type,
      x_ihdv_rec OUT NOCOPY ihdv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ihdv_rec := p_ihdv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_ihdv_rec := get_rec(p_ihdv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ihdv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.id := l_db_ihdv_rec.id;
        END IF;
        IF (x_ihdv_rec.ins_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.ins_id := l_db_ihdv_rec.ins_id;
        END IF;
        IF (x_ihdv_rec.transaction_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.transaction_date := l_db_ihdv_rec.transaction_date;
        END IF;
        IF (x_ihdv_rec.transaction_type = OKC_API.G_MISS_CHAR)
        THEN
          x_ihdv_rec.transaction_type := l_db_ihdv_rec.transaction_type;
        END IF;
        IF (x_ihdv_rec.system_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.system_id := l_db_ihdv_rec.system_id;
        END IF;
        IF (x_ihdv_rec.instance_id_new = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.instance_id_new := l_db_ihdv_rec.instance_id_new;
        END IF;
        IF (x_ihdv_rec.instance_qty_old = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.instance_qty_old := l_db_ihdv_rec.instance_qty_old;
        END IF;
        IF (x_ihdv_rec.instance_qty_new = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.instance_qty_new := l_db_ihdv_rec.instance_qty_new;
        END IF;
        IF (x_ihdv_rec.instance_amt_old = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.instance_amt_old := l_db_ihdv_rec.instance_amt_old;
        END IF;
        IF (x_ihdv_rec.instance_amt_new = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.instance_amt_new := l_db_ihdv_rec.instance_amt_new;
        END IF;
        IF (x_ihdv_rec.old_contract_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.old_contract_id := l_db_ihdv_rec.old_contract_id;
        END IF;
        IF (x_ihdv_rec.old_contact_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.old_contact_start_date := l_db_ihdv_rec.old_contact_start_date;
        END IF;
        IF (x_ihdv_rec.old_contract_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.old_contract_end_date := l_db_ihdv_rec.old_contract_end_date;
        END IF;
        IF (x_ihdv_rec.new_contract_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.new_contract_id := l_db_ihdv_rec.new_contract_id;
        END IF;
        IF (x_ihdv_rec.new_contact_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.new_contact_start_date := l_db_ihdv_rec.new_contact_start_date;
        END IF;
        IF (x_ihdv_rec.new_contract_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.new_contract_end_date := l_db_ihdv_rec.new_contract_end_date;
        END IF;
        IF (x_ihdv_rec.old_service_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.old_service_line_id := l_db_ihdv_rec.old_service_line_id;
        END IF;
        IF (x_ihdv_rec.old_service_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.old_service_start_date := l_db_ihdv_rec.old_service_start_date;
        END IF;
        IF (x_ihdv_rec.old_service_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.old_service_end_date := l_db_ihdv_rec.old_service_end_date;
        END IF;
        IF (x_ihdv_rec.new_service_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.new_service_line_id := l_db_ihdv_rec.new_service_line_id;
        END IF;
        IF (x_ihdv_rec.new_service_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.new_service_start_date := l_db_ihdv_rec.new_service_start_date;
        END IF;
        IF (x_ihdv_rec.new_service_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.new_service_end_date := l_db_ihdv_rec.new_service_end_date;
        END IF;
        IF (x_ihdv_rec.old_subline_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.old_subline_id := l_db_ihdv_rec.old_subline_id;
        END IF;
        IF (x_ihdv_rec.old_subline_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.old_subline_start_date := l_db_ihdv_rec.old_subline_start_date;
        END IF;
        IF (x_ihdv_rec.old_subline_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.old_subline_end_date := l_db_ihdv_rec.old_subline_end_date;
        END IF;
        IF (x_ihdv_rec.new_subline_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.new_subline_id := l_db_ihdv_rec.new_subline_id;
        END IF;
        IF (x_ihdv_rec.new_subline_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.new_subline_start_date := l_db_ihdv_rec.new_subline_start_date;
        END IF;
        IF (x_ihdv_rec.new_subline_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.new_subline_end_date := l_db_ihdv_rec.new_subline_end_date;
        END IF;
        IF (x_ihdv_rec.old_customer = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.old_customer := l_db_ihdv_rec.old_customer;
        END IF;
        IF (x_ihdv_rec.new_customer = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.new_customer := l_db_ihdv_rec.new_customer;
        END IF;
        IF (x_ihdv_rec.old_k_status = OKC_API.G_MISS_CHAR)
        THEN
          x_ihdv_rec.old_k_status := l_db_ihdv_rec.old_k_status;
        END IF;
        IF (x_ihdv_rec.new_k_status = OKC_API.G_MISS_CHAR)
        THEN
          x_ihdv_rec.new_k_status := l_db_ihdv_rec.new_k_status;
        END IF;
        IF (x_ihdv_rec.subline_date_terminated = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.subline_date_terminated := l_db_ihdv_rec.subline_date_terminated;
        END IF;
        IF (x_ihdv_rec.transfer_option = OKC_API.G_MISS_CHAR)
        THEN
          x_ihdv_rec.transfer_option := l_db_ihdv_rec.transfer_option;
        END IF;
        IF (x_ihdv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.created_by := l_db_ihdv_rec.created_by;
        END IF;
        IF (x_ihdv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.creation_date := l_db_ihdv_rec.creation_date;
        END IF;
        IF (x_ihdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.last_updated_by := l_db_ihdv_rec.last_updated_by;
        END IF;
        IF (x_ihdv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.last_update_date := l_db_ihdv_rec.last_update_date;
        END IF;
        IF (x_ihdv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.last_update_login := l_db_ihdv_rec.last_update_login;
        END IF;
        IF (x_ihdv_rec.security_group_id = OKC_API.G_MISS_NUM)
        THEN
          x_ihdv_rec.security_group_id := l_db_ihdv_rec.security_group_id;
        END IF;
        IF (x_ihdv_rec.date_cancelled = OKC_API.G_MISS_DATE)
        THEN
          x_ihdv_rec.date_cancelled := l_db_ihdv_rec.date_cancelled;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKS_INST_HIST_DETAILS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_ihdv_rec IN ihdv_rec_type,
      x_ihdv_rec OUT NOCOPY ihdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ihdv_rec := p_ihdv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ihdv_rec,                        -- IN
      x_ihdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ihdv_rec, l_def_ihdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ihdv_rec := fill_who_columns(l_def_ihdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ihdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ihdv_rec, l_db_ihdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_ihdv_rec                     => p_ihdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ihdv_rec, l_ihd_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ihd_rec,
      lx_ihd_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ihd_rec, l_def_ihdv_rec);
    x_ihdv_rec := l_def_ihdv_rec;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:ihdv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      i := p_ihdv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ihdv_rec                     => p_ihdv_tbl(i),
            x_ihdv_rec                     => x_ihdv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ihdv_tbl.LAST);
        i := p_ihdv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ----------------------------------------
  -- PL/SQL TBL update_row for:IHDV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    x_ihdv_tbl                     OUT NOCOPY ihdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ihdv_tbl                     => p_ihdv_tbl,
        x_ihdv_tbl                     => x_ihdv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- delete_row for:OKS_INST_HIST_DETAILS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihd_rec                      IN ihd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihd_rec                      ihd_rec_type := p_ihd_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKS_INST_HIST_DETAILS
     WHERE ID = p_ihd_rec.id;

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  --------------------------------------------
  -- delete_row for:OKS_INST_HIST_DETAILS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_rec                     IN ihdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ihdv_rec                     ihdv_rec_type := p_ihdv_rec;
    l_ihd_rec                      ihd_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_ihdv_rec, l_ihd_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ihd_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_INST_HIST_DETAILS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      i := p_ihdv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_ihdv_rec                     => p_ihdv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_ihdv_tbl.LAST);
        i := p_ihdv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_INST_HIST_DETAILS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ihdv_tbl                     IN ihdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ihdv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ihdv_tbl                     => p_ihdv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKS_IHD_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKS_BRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BRL_PVT" AS
/* $Header: OKSSBRLB.pls 120.3 2005/08/10 15:04 vigandhi noship $ */
 l_debug VARCHAr2(1) := 'N';
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
  -- FUNCTION get_rec for: OKS_BATCH_RULES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oks_batch_rules_v_rec_type IS
    CURSOR oks_brlv_pk_csr (p_batch_id IN NUMBER) IS
    SELECT
            BATCH_ID,
            BATCH_TYPE,
            BATCH_SOURCE,
            TRANSACTION_DATE,
            CREDIT_OPTION,
            TERMINATION_REASON_CODE,
            BILLING_PROFILE_ID,
            RETAIN_CONTRACT_NUMBER_FLAG,
            CONTRACT_MODIFIER,
            CONTRACT_STATUS,
            TRANSFER_NOTES_FLAG,
            TRANSFER_ATTACHMENTS_FLAG,
            BILL_LINES_FLAG,
            TRANSFER_OPTION_CODE,
            BILL_ACCOUNT_ID,
            SHIP_ACCOUNT_ID,
            BILL_ADDRESS_ID,
            SHIP_ADDRESS_ID,
            BILL_CONTACT_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID
      FROM Oks_Batch_Rules_V
     WHERE oks_batch_rules_v.batch_id = p_batch_id;
    l_oks_brlv_pk                  oks_brlv_pk_csr%ROWTYPE;
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_brlv_pk_csr (p_oks_batch_rules_v_rec.batch_id);
    FETCH oks_brlv_pk_csr INTO
              l_oks_batch_rules_v_rec.batch_id,
              l_oks_batch_rules_v_rec.batch_type,
              l_oks_batch_rules_v_rec.batch_source,
              l_oks_batch_rules_v_rec.transaction_date,
              l_oks_batch_rules_v_rec.credit_option,
              l_oks_batch_rules_v_rec.termination_reason_code,
              l_oks_batch_rules_v_rec.billing_profile_id,
              l_oks_batch_rules_v_rec.retain_contract_number_flag,
              l_oks_batch_rules_v_rec.contract_modifier,
              l_oks_batch_rules_v_rec.contract_status,
              l_oks_batch_rules_v_rec.transfer_notes_flag,
              l_oks_batch_rules_v_rec.transfer_attachments_flag,
              l_oks_batch_rules_v_rec.bill_lines_flag,
              l_oks_batch_rules_v_rec.transfer_option_code,
              l_oks_batch_rules_v_rec.bill_account_id,
              l_oks_batch_rules_v_rec.ship_account_id,
              l_oks_batch_rules_v_rec.bill_address_id,
              l_oks_batch_rules_v_rec.ship_address_id,
              l_oks_batch_rules_v_rec.bill_contact_id,
              l_oks_batch_rules_v_rec.created_by,
              l_oks_batch_rules_v_rec.creation_date,
              l_oks_batch_rules_v_rec.last_updated_by,
              l_oks_batch_rules_v_rec.last_update_date,
              l_oks_batch_rules_v_rec.last_update_login,
              l_oks_batch_rules_v_rec.security_group_id,
              l_oks_batch_rules_v_rec.object_version_number,
              l_oks_batch_rules_v_rec.request_id;
    x_no_data_found := oks_brlv_pk_csr%NOTFOUND;
    CLOSE oks_brlv_pk_csr;
    RETURN(l_oks_batch_rules_v_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oks_batch_rules_v_rec_type IS
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oks_batch_rules_v_rec := get_rec(p_oks_batch_rules_v_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'BATCH_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oks_batch_rules_v_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type
  ) RETURN oks_batch_rules_v_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oks_batch_rules_v_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BATCH_RULES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_obtr_rec                     IN obtr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN obtr_rec_type IS
    CURSOR oks_batch_pk_csr (p_batch_id IN NUMBER) IS
    SELECT
            BATCH_ID,
            BATCH_TYPE,
            BATCH_SOURCE,
            TRANSACTION_DATE,
            CREDIT_OPTION,
            TERMINATION_REASON_CODE,
            BILLING_PROFILE_ID,
            RETAIN_CONTRACT_NUMBER_FLAG,
            CONTRACT_MODIFIER,
            CONTRACT_STATUS,
            TRANSFER_NOTES_FLAG,
            TRANSFER_ATTACHMENTS_FLAG,
            BILL_LINES_FLAG,
            TRANSFER_OPTION_CODE,
            BILL_ACCOUNT_ID,
            SHIP_ACCOUNT_ID,
            BILL_ADDRESS_ID,
            SHIP_ADDRESS_ID,
            BILL_CONTACT_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID
      FROM Oks_Batch_Rules
     WHERE oks_batch_rules.batch_id = p_batch_id;
    l_oks_batch_pk                 oks_batch_pk_csr%ROWTYPE;
    l_obtr_rec                     obtr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_batch_pk_csr (p_obtr_rec.batch_id);
    FETCH oks_batch_pk_csr INTO
              l_obtr_rec.batch_id,
              l_obtr_rec.batch_type,
              l_obtr_rec.batch_source,
              l_obtr_rec.transaction_date,
              l_obtr_rec.credit_option,
              l_obtr_rec.termination_reason_code,
              l_obtr_rec.billing_profile_id,
              l_obtr_rec.retain_contract_number_flag,
              l_obtr_rec.contract_modifier,
              l_obtr_rec.contract_status,
              l_obtr_rec.transfer_notes_flag,
              l_obtr_rec.transfer_attachments_flag,
              l_obtr_rec.bill_lines_flag,
              l_obtr_rec.transfer_option_code,
              l_obtr_rec.bill_account_id,
              l_obtr_rec.ship_account_id,
              l_obtr_rec.bill_address_id,
              l_obtr_rec.ship_address_id,
              l_obtr_rec.bill_contact_id,
              l_obtr_rec.created_by,
              l_obtr_rec.creation_date,
              l_obtr_rec.last_updated_by,
              l_obtr_rec.last_update_date,
              l_obtr_rec.last_update_login,
              l_obtr_rec.object_version_number,
              l_obtr_rec.request_id;
    x_no_data_found := oks_batch_pk_csr%NOTFOUND;
    CLOSE oks_batch_pk_csr;
    RETURN(l_obtr_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_obtr_rec                     IN obtr_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN obtr_rec_type IS
    l_obtr_rec                     obtr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_obtr_rec := get_rec(p_obtr_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'BATCH_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_obtr_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_obtr_rec                     IN obtr_rec_type
  ) RETURN obtr_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_obtr_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_BATCH_RULES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oks_batch_rules_v_rec   IN oks_batch_rules_v_rec_type
  ) RETURN oks_batch_rules_v_rec_type IS
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
  BEGIN
    IF (l_oks_batch_rules_v_rec.batch_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.batch_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.batch_type = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.batch_type := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.batch_source = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.batch_source := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.transaction_date = OKC_API.G_MISS_DATE ) THEN
      l_oks_batch_rules_v_rec.transaction_date := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.credit_option = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.credit_option := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.termination_reason_code = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.termination_reason_code := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.billing_profile_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.billing_profile_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.retain_contract_number_flag = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.retain_contract_number_flag := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.contract_modifier = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.contract_modifier := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.contract_status = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.contract_status := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.transfer_notes_flag = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.transfer_notes_flag := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.transfer_attachments_flag = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.transfer_attachments_flag := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.bill_lines_flag = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.bill_lines_flag := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.transfer_option_code = OKC_API.G_MISS_CHAR ) THEN
      l_oks_batch_rules_v_rec.transfer_option_code := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.bill_account_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.bill_account_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.ship_account_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.ship_account_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.bill_address_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.bill_address_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.ship_address_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.ship_address_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.bill_contact_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.bill_contact_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.created_by := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_oks_batch_rules_v_rec.creation_date := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.last_updated_by := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oks_batch_rules_v_rec.last_update_date := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.last_update_login := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.security_group_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.security_group_id := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.object_version_number := NULL;
    END IF;
    IF (l_oks_batch_rules_v_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_batch_rules_v_rec.request_id := NULL;
    END IF;
    RETURN(l_oks_batch_rules_v_rec);
  END null_out_defaults;
  ---------------------------------------
  -- Validate_Attributes for: BATCH_ID --
  ---------------------------------------
  PROCEDURE validate_batch_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_batch_id                     IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_batch_id = OKC_API.G_MISS_NUM OR
        p_batch_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'batch_id');
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
  END validate_batch_id;
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


  -- R12 Data Model Changes 4485150 Start
  -- Start of comments
  --
  -- Procedure Name  : validate_credit_option
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  -----------------------------------------------------
  -- Validate_Attributes for: CREDIT_OPTION --
  -----------------------------------------------------

  PROCEDURE validate_credit_option(
    x_return_status        OUT NOCOPY VARCHAR2,
    p_credit_option        IN VARCHAR2) IS
    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_fndv_csr Is
  		select 'x'
		from FND_LOOKUPS
		where lookup_code = p_credit_option
                and lookup_type = 'OKS_CREDIT_AMOUNT'
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
                and enabled_flag = 'Y';


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_BRL_PVT');
       okc_debug.log('500: Entered validate_credit_option', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF  (p_credit_option = OKC_API.G_MISS_CHAR OR
         p_credit_option IS NULL)
    THEN

/*  	   OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'credit_amount');
	   raise G_EXCEPTION_HALT_VALIDATION;
*/
           NULL; -- This field is Optional

    ELSE

      ---------------------------------------------------------------------------------
      -- Validate from the LookUp FND_LOOKUPS Where lookup_type IS OKS_CREDIT_AMOUNT --
      ---------------------------------------------------------------------------------

      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'CREDIT_OPTION');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_credit_option', 2);
       okc_debug.Reset_Indentation;
    END IF;
    END IF;
  EXCEPTION
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Exiting validate_credit_option:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_credit_option:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_credit_option:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  END validate_credit_option;
  -- R12 Data Model Changes 4485150 End

  -- R12 Data Model Changes 4485150 Start
  -- Start of comments
  --
  -- Procedure Name  : validate_trmntn_rsn_cd
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------
  -- Validate_Attributes for: TERMINATION_REASON_CODE --
  ------------------------------------------------------

  PROCEDURE validate_trmntn_rsn_cd(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_termination_reason_code  IN VARCHAR2) IS
    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_fndv_csr Is
  		select 'x'
		from FND_LOOKUPS
		where lookup_code = p_termination_reason_code
                and lookup_type = 'OKC_TERMINATION_REASON'
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
                and enabled_flag = 'Y';


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_BRL_PVT');
       okc_debug.log('500: Entered validate_termination_reason_code', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF  (p_termination_reason_code = OKC_API.G_MISS_CHAR OR
         p_termination_reason_code IS NULL)
    THEN

/*  	   OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'termination_reason_code');
	   raise G_EXCEPTION_HALT_VALIDATION;
*/
           NULL; -- This field is Optional

    ELSE

      ---------------------------------------------------------------------------------------
      -- Validate from the LookUp FND_LOOKUPS Where lookup_type IS TERMINATION_REASON_CODE --
      ---------------------------------------------------------------------------------------

      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'TERMINATION_REASON_CODE');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_termination_reason_code', 2);
       okc_debug.Reset_Indentation;
    END IF;
    END IF;
  EXCEPTION
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Exiting validate_termination_reason_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_termination_reason_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_termination_reason_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  END validate_trmntn_rsn_cd;
  -- R12 Data Model Changes 4485150 End



  -- R12 Data Model Changes 4485150 Start
  -- Start of comments
  --
  -- Procedure Name  : validate_transfer_option_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------
  -- Validate_Attributes for: TRANSFER_OPTION_CODE --
  ------------------------------------------------------

  PROCEDURE validate_transfer_option_code(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_transfer_option_code     IN VARCHAR2) IS
    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_fndv_csr Is
  		select 'x'
		from FND_LOOKUPS
		where lookup_code = p_transfer_option_code
                and lookup_type = 'OKS_TRANSFER_RULES'
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
                and enabled_flag = 'Y';


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_BRL_PVT');
       okc_debug.log('500: Entered validate_transfer_option_code', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF  (p_transfer_option_code = OKC_API.G_MISS_CHAR OR
         p_transfer_option_code IS NULL)
    THEN

/*  	   OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'transfer_option_code');
	   raise G_EXCEPTION_HALT_VALIDATION;
*/
           NULL; -- This field is Optional

    ELSE

      ----------------------------------------------------------------------------------
      -- Validate from the LookUp FND_LOOKUPS Where lookup_type IS OKS_TRANSFER_RULES --
      ----------------------------------------------------------------------------------

      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'TRANSFER_OPTION_CODE');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_transfer_option_code', 2);
       okc_debug.Reset_Indentation;
    END IF;
    END IF;
  EXCEPTION
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Exiting validate_transfer_option_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_transfer_option_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_transfer_option_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  END validate_transfer_option_Code;
  -- R12 Data Model Changes 4485150 End

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKS_BATCH_RULES_V --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- batch_id
    -- ***
    validate_batch_id(x_return_status, p_oks_batch_rules_v_rec.batch_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_oks_batch_rules_v_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- R12 Data Model Changes 4485150 Start
    -- ***
    -- credit_option
    -- ***
    validate_credit_option(x_return_status, p_oks_batch_rules_v_rec.credit_option);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- termination_reason_code
    -- ***
    validate_trmntn_rsn_cd(x_return_status, p_oks_batch_rules_v_rec.termination_reason_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- credit_option
    -- ***
    validate_transfer_option_code(x_return_status, p_oks_batch_rules_v_rec.transfer_option_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- R12 Data Model Changes 4485150 End


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
  -------------------------------------------
  -- Validate Record for:OKS_BATCH_RULES_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type,
    p_db_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_oks_batch_rules_v_rec     oks_batch_rules_v_rec_type := get_rec(p_oks_batch_rules_v_rec);
  BEGIN
    l_return_status := Validate_Record(p_oks_batch_rules_v_rec => p_oks_batch_rules_v_rec,
                                       p_db_oks_batch_rules_v_rec => l_db_oks_batch_rules_v_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN oks_batch_rules_v_rec_type,
    p_to   IN OUT NOCOPY obtr_rec_type
  ) IS
  BEGIN
    p_to.batch_id := p_from.batch_id;
    p_to.batch_type := p_from.batch_type;
    p_to.batch_source := p_from.batch_source;
    p_to.transaction_date := p_from.transaction_date;
    p_to.credit_option := p_from.credit_option;
    p_to.termination_reason_code := p_from.termination_reason_code;
    p_to.billing_profile_id := p_from.billing_profile_id;
    p_to.retain_contract_number_flag := p_from.retain_contract_number_flag;
    p_to.contract_modifier := p_from.contract_modifier;
    p_to.contract_status := p_from.contract_status;
    p_to.transfer_notes_flag := p_from.transfer_notes_flag;
    p_to.transfer_attachments_flag := p_from.transfer_attachments_flag;
    p_to.bill_lines_flag := p_from.bill_lines_flag;
    p_to.transfer_option_code := p_from.transfer_option_code;
    p_to.bill_account_id := p_from.bill_account_id;
    p_to.ship_account_id := p_from.ship_account_id;
    p_to.bill_address_id := p_from.bill_address_id;
    p_to.ship_address_id := p_from.ship_address_id;
    p_to.bill_contact_id := p_from.bill_contact_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN obtr_rec_type,
    p_to   IN OUT NOCOPY oks_batch_rules_v_rec_type
  ) IS
  BEGIN
    p_to.batch_id := p_from.batch_id;
    p_to.batch_type := p_from.batch_type;
    p_to.batch_source := p_from.batch_source;
    p_to.transaction_date := p_from.transaction_date;
    p_to.credit_option := p_from.credit_option;
    p_to.termination_reason_code := p_from.termination_reason_code;
    p_to.billing_profile_id := p_from.billing_profile_id;
    p_to.contract_modifier := p_from.contract_modifier;
    p_to.contract_status := p_from.contract_status;
    p_to.transfer_notes_flag := p_from.transfer_notes_flag;
    p_to.transfer_attachments_flag := p_from.transfer_attachments_flag;
    p_to.bill_lines_flag := p_from.bill_lines_flag;
    p_to.transfer_option_code := p_from.transfer_option_code;
    p_to.bill_account_id := p_from.bill_account_id;
    p_to.ship_account_id := p_from.ship_account_id;
    p_to.bill_address_id := p_from.bill_address_id;
    p_to.ship_address_id := p_from.ship_address_id;
    p_to.bill_contact_id := p_from.bill_contact_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- validate_row for:OKS_BATCH_RULES_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
    l_obtr_rec                     obtr_rec_type;
    l_obtr_rec                     obtr_rec_type;
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
    l_return_status := Validate_Attributes(l_oks_batch_rules_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oks_batch_rules_v_rec);
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
  ---------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_BATCH_RULES_V --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      i := p_oks_batch_rules_v_tbl.FIRST;
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
            p_oks_batch_rules_v_rec        => p_oks_batch_rules_v_tbl(i));
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
        EXIT WHEN (i = p_oks_batch_rules_v_tbl.LAST);
        i := p_oks_batch_rules_v_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_BATCH_RULES_V --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_batch_rules_v_tbl        => p_oks_batch_rules_v_tbl,
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
  ------------------------------------
  -- insert_row for:OKS_BATCH_RULES --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_obtr_rec                     IN obtr_rec_type,
    x_obtr_rec                     OUT NOCOPY obtr_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_obtr_rec                     obtr_rec_type := p_obtr_rec;
    l_def_obtr_rec                 obtr_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKS_BATCH_RULES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_obtr_rec IN obtr_rec_type,
      x_obtr_rec OUT NOCOPY obtr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_obtr_rec := p_obtr_rec;
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
      p_obtr_rec,                        -- IN
      l_obtr_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_BATCH_RULES(
      batch_id,
      batch_type,
      batch_source,
      transaction_date,
      credit_option,
      termination_reason_code,
      billing_profile_id,
      retain_contract_number_flag,
      contract_modifier,
      contract_status,
      transfer_notes_flag,
      transfer_attachments_flag,
      bill_lines_flag,
      transfer_option_code,
      bill_account_id,
      ship_account_id,
      bill_address_id,
      ship_address_id,
      bill_contact_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number,
      request_id)
    VALUES (
      l_obtr_rec.batch_id,
      l_obtr_rec.batch_type,
      l_obtr_rec.batch_source,
      l_obtr_rec.transaction_date,
      l_obtr_rec.credit_option,
      l_obtr_rec.termination_reason_code,
      l_obtr_rec.billing_profile_id,
      l_obtr_rec.retain_contract_number_flag,
      l_obtr_rec.contract_modifier,
      l_obtr_rec.contract_status,
      l_obtr_rec.transfer_notes_flag,
      l_obtr_rec.transfer_attachments_flag,
      l_obtr_rec.bill_lines_flag,
      l_obtr_rec.transfer_option_code,
      l_obtr_rec.bill_account_id,
      l_obtr_rec.ship_account_id,
      l_obtr_rec.bill_address_id,
      l_obtr_rec.ship_address_id,
      l_obtr_rec.bill_contact_id,
      l_obtr_rec.created_by,
      l_obtr_rec.creation_date,
      l_obtr_rec.last_updated_by,
      l_obtr_rec.last_update_date,
      l_obtr_rec.last_update_login,
      l_obtr_rec.object_version_number,
      l_obtr_rec.request_id);
    -- Set OUT values
    x_obtr_rec := l_obtr_rec;
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
  ---------------------------------------
  -- insert_row for :OKS_BATCH_RULES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type,
    x_oks_batch_rules_v_rec        OUT NOCOPY oks_batch_rules_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
    l_def_oks_batch_rules_v_rec    oks_batch_rules_v_rec_type;
    l_obtr_rec                     obtr_rec_type;
    lx_obtr_rec                    obtr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type
    ) RETURN oks_batch_rules_v_rec_type IS
      l_oks_batch_rules_v_rec oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
    BEGIN
      l_oks_batch_rules_v_rec.CREATION_DATE := SYSDATE;
      l_oks_batch_rules_v_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oks_batch_rules_v_rec.LAST_UPDATE_DATE := l_oks_batch_rules_v_rec.CREATION_DATE;
      l_oks_batch_rules_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oks_batch_rules_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oks_batch_rules_v_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKS_BATCH_RULES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type,
      x_oks_batch_rules_v_rec OUT NOCOPY oks_batch_rules_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_batch_rules_v_rec := p_oks_batch_rules_v_rec;
      x_oks_batch_rules_v_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_oks_batch_rules_v_rec := null_out_defaults(p_oks_batch_rules_v_rec);
    -- Set primary key value
    -- l_oks_batch_rules_v_rec.BATCH_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_oks_batch_rules_v_rec,           -- IN
      l_def_oks_batch_rules_v_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oks_batch_rules_v_rec := fill_who_columns(l_def_oks_batch_rules_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oks_batch_rules_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oks_batch_rules_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oks_batch_rules_v_rec, l_obtr_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_obtr_rec,
      lx_obtr_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_obtr_rec, l_def_oks_batch_rules_v_rec);
    -- Set OUT values
    x_oks_batch_rules_v_rec := l_def_oks_batch_rules_v_rec;
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
  -----------------------------------------------------
  -- PL/SQL TBL insert_row for:OKS_BATCH_RULES_V_TBL --
  -----------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      i := p_oks_batch_rules_v_tbl.FIRST;
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
            p_oks_batch_rules_v_rec        => p_oks_batch_rules_v_tbl(i),
            x_oks_batch_rules_v_rec        => x_oks_batch_rules_v_tbl(i));
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
        EXIT WHEN (i = p_oks_batch_rules_v_tbl.LAST);
        i := p_oks_batch_rules_v_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL insert_row for:OKS_BATCH_RULES_V_TBL --
  -----------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_batch_rules_v_tbl        => p_oks_batch_rules_v_tbl,
        x_oks_batch_rules_v_tbl        => x_oks_batch_rules_v_tbl,
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
  ----------------------------------
  -- lock_row for:OKS_BATCH_RULES --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_obtr_rec                     IN obtr_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_obtr_rec IN obtr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BATCH_RULES
     WHERE BATCH_ID = p_obtr_rec.batch_id
       AND OBJECT_VERSION_NUMBER = p_obtr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_obtr_rec IN obtr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BATCH_RULES
     WHERE BATCH_ID = p_obtr_rec.batch_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_BATCH_RULES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_BATCH_RULES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_obtr_rec);
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
      OPEN lchk_csr(p_obtr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_obtr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_obtr_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for: OKS_BATCH_RULES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_obtr_rec                     obtr_rec_type;
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
    migrate(p_oks_batch_rules_v_rec, l_obtr_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_obtr_rec
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
  ---------------------------------------------------
  -- PL/SQL TBL lock_row for:OKS_BATCH_RULES_V_TBL --
  ---------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      i := p_oks_batch_rules_v_tbl.FIRST;
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
            p_oks_batch_rules_v_rec        => p_oks_batch_rules_v_tbl(i));
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
        EXIT WHEN (i = p_oks_batch_rules_v_tbl.LAST);
        i := p_oks_batch_rules_v_tbl.NEXT(i);
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
  ---------------------------------------------------
  -- PL/SQL TBL lock_row for:OKS_BATCH_RULES_V_TBL --
  ---------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_batch_rules_v_tbl        => p_oks_batch_rules_v_tbl,
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
  ------------------------------------
  -- update_row for:OKS_BATCH_RULES --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_obtr_rec                     IN obtr_rec_type,
    x_obtr_rec                     OUT NOCOPY obtr_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_obtr_rec                     obtr_rec_type := p_obtr_rec;
    l_def_obtr_rec                 obtr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_obtr_rec IN obtr_rec_type,
      x_obtr_rec OUT NOCOPY obtr_rec_type
    ) RETURN VARCHAR2 IS
      l_obtr_rec                     obtr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_obtr_rec := p_obtr_rec;
      -- Get current database values
      l_obtr_rec := get_rec(p_obtr_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_obtr_rec.batch_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.batch_id := l_obtr_rec.batch_id;
        END IF;
        IF (x_obtr_rec.batch_type = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.batch_type := l_obtr_rec.batch_type;
        END IF;
        IF (x_obtr_rec.batch_source = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.batch_source := l_obtr_rec.batch_source;
        END IF;
        IF (x_obtr_rec.transaction_date = OKC_API.G_MISS_DATE)
        THEN
          x_obtr_rec.transaction_date := l_obtr_rec.transaction_date;
        END IF;
        IF (x_obtr_rec.credit_option = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.credit_option := l_obtr_rec.credit_option;
        END IF;
        IF (x_obtr_rec.termination_reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.termination_reason_code := l_obtr_rec.termination_reason_code;
        END IF;
        IF (x_obtr_rec.billing_profile_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.billing_profile_id := l_obtr_rec.billing_profile_id;
        END IF;
        IF (x_obtr_rec.retain_contract_number_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.retain_contract_number_flag := l_obtr_rec.retain_contract_number_flag;
        END IF;
        IF (x_obtr_rec.contract_modifier = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.contract_modifier := l_obtr_rec.contract_modifier;
        END IF;
        IF (x_obtr_rec.contract_status = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.contract_status := l_obtr_rec.contract_status;
        END IF;
        IF (x_obtr_rec.transfer_notes_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.transfer_notes_flag := l_obtr_rec.transfer_notes_flag;
        END IF;
        IF (x_obtr_rec.transfer_attachments_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.transfer_attachments_flag := l_obtr_rec.transfer_attachments_flag;
        END IF;
        IF (x_obtr_rec.bill_lines_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.bill_lines_flag := l_obtr_rec.bill_lines_flag;
        END IF;
        IF (x_obtr_rec.transfer_option_code = OKC_API.G_MISS_CHAR)
        THEN
          x_obtr_rec.transfer_option_code := l_obtr_rec.transfer_option_code;
        END IF;
        IF (x_obtr_rec.bill_account_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.bill_account_id := l_obtr_rec.bill_account_id;
        END IF;
        IF (x_obtr_rec.ship_account_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.ship_account_id := l_obtr_rec.ship_account_id;
        END IF;
        IF (x_obtr_rec.bill_address_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.bill_address_id := l_obtr_rec.bill_address_id;
        END IF;
        IF (x_obtr_rec.ship_address_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.ship_address_id := l_obtr_rec.ship_address_id;
        END IF;
        IF (x_obtr_rec.bill_contact_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.bill_contact_id := l_obtr_rec.bill_contact_id;
        END IF;
        IF (x_obtr_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.created_by := l_obtr_rec.created_by;
        END IF;
        IF (x_obtr_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_obtr_rec.creation_date := l_obtr_rec.creation_date;
        END IF;
        IF (x_obtr_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.last_updated_by := l_obtr_rec.last_updated_by;
        END IF;
        IF (x_obtr_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_obtr_rec.last_update_date := l_obtr_rec.last_update_date;
        END IF;
        IF (x_obtr_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.last_update_login := l_obtr_rec.last_update_login;
        END IF;
        IF (x_obtr_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.object_version_number := l_obtr_rec.object_version_number;
        END IF;
        IF (x_obtr_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_obtr_rec.request_id := l_obtr_rec.request_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKS_BATCH_RULES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_obtr_rec IN obtr_rec_type,
      x_obtr_rec OUT NOCOPY obtr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_obtr_rec := p_obtr_rec;
      x_obtr_rec.OBJECT_VERSION_NUMBER := p_obtr_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_obtr_rec,                        -- IN
      l_obtr_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_obtr_rec, l_def_obtr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_BATCH_RULES
    SET BATCH_TYPE = l_def_obtr_rec.batch_type,
        BATCH_SOURCE = l_def_obtr_rec.batch_source,
        TRANSACTION_DATE = l_def_obtr_rec.transaction_date,
        CREDIT_OPTION = l_def_obtr_rec.credit_option,
        TERMINATION_REASON_CODE = l_def_obtr_rec.termination_reason_code,
        BILLING_PROFILE_ID = l_def_obtr_rec.billing_profile_id,
        RETAIN_CONTRACT_NUMBER_FLAG = l_def_obtr_rec.retain_contract_number_flag,
        CONTRACT_MODIFIER = l_def_obtr_rec.contract_modifier,
        CONTRACT_STATUS = l_def_obtr_rec.contract_status,
        TRANSFER_NOTES_FLAG = l_def_obtr_rec.transfer_notes_flag,
        TRANSFER_ATTACHMENTS_FLAG = l_def_obtr_rec.transfer_attachments_flag,
        BILL_LINES_FLAG = l_def_obtr_rec.bill_lines_flag,
        TRANSFER_OPTION_CODE = l_def_obtr_rec.transfer_option_code,
        BILL_ACCOUNT_ID = l_def_obtr_rec.bill_account_id,
        SHIP_ACCOUNT_ID = l_def_obtr_rec.ship_account_id,
        BILL_ADDRESS_ID = l_def_obtr_rec.bill_address_id,
        SHIP_ADDRESS_ID = l_def_obtr_rec.ship_address_id,
        BILL_CONTACT_ID = l_def_obtr_rec.bill_contact_id,
        CREATED_BY = l_def_obtr_rec.created_by,
        CREATION_DATE = l_def_obtr_rec.creation_date,
        LAST_UPDATED_BY = l_def_obtr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_obtr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_obtr_rec.last_update_login,
        OBJECT_VERSION_NUMBER = l_def_obtr_rec.object_version_number,
        REQUEST_ID = l_def_obtr_rec.request_id
    WHERE BATCH_ID = l_def_obtr_rec.batch_id;

    x_obtr_rec := l_obtr_rec;
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
  --------------------------------------
  -- update_row for:OKS_BATCH_RULES_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type,
    x_oks_batch_rules_v_rec        OUT NOCOPY oks_batch_rules_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
    l_def_oks_batch_rules_v_rec    oks_batch_rules_v_rec_type;
    l_db_oks_batch_rules_v_rec     oks_batch_rules_v_rec_type;
    l_obtr_rec                     obtr_rec_type;
    lx_obtr_rec                    obtr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type
    ) RETURN oks_batch_rules_v_rec_type IS
      l_oks_batch_rules_v_rec oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
    BEGIN
      l_oks_batch_rules_v_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oks_batch_rules_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oks_batch_rules_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oks_batch_rules_v_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type,
      x_oks_batch_rules_v_rec OUT NOCOPY oks_batch_rules_v_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_batch_rules_v_rec := p_oks_batch_rules_v_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_oks_batch_rules_v_rec := get_rec(p_oks_batch_rules_v_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oks_batch_rules_v_rec.batch_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.batch_id := l_db_oks_batch_rules_v_rec.batch_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.batch_type = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.batch_type := l_db_oks_batch_rules_v_rec.batch_type;
        END IF;
        IF (x_oks_batch_rules_v_rec.batch_source = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.batch_source := l_db_oks_batch_rules_v_rec.batch_source;
        END IF;
        IF (x_oks_batch_rules_v_rec.transaction_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_batch_rules_v_rec.transaction_date := l_db_oks_batch_rules_v_rec.transaction_date;
        END IF;
        IF (x_oks_batch_rules_v_rec.credit_option = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.credit_option := l_db_oks_batch_rules_v_rec.credit_option;
        END IF;
        IF (x_oks_batch_rules_v_rec.termination_reason_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.termination_reason_code := l_db_oks_batch_rules_v_rec.termination_reason_code;
        END IF;
        IF (x_oks_batch_rules_v_rec.billing_profile_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.billing_profile_id := l_db_oks_batch_rules_v_rec.billing_profile_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.retain_contract_number_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.retain_contract_number_flag := l_db_oks_batch_rules_v_rec.retain_contract_number_flag;
        END IF;
        IF (x_oks_batch_rules_v_rec.contract_modifier = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.contract_modifier := l_db_oks_batch_rules_v_rec.contract_modifier;
        END IF;
        IF (x_oks_batch_rules_v_rec.contract_status = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.contract_status := l_db_oks_batch_rules_v_rec.contract_status;
        END IF;
        IF (x_oks_batch_rules_v_rec.transfer_notes_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.transfer_notes_flag := l_db_oks_batch_rules_v_rec.transfer_notes_flag;
        END IF;
        IF (x_oks_batch_rules_v_rec.transfer_attachments_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.transfer_attachments_flag := l_db_oks_batch_rules_v_rec.transfer_attachments_flag;
        END IF;
        IF (x_oks_batch_rules_v_rec.bill_lines_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.bill_lines_flag := l_db_oks_batch_rules_v_rec.bill_lines_flag;
        END IF;
        IF (x_oks_batch_rules_v_rec.transfer_option_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_batch_rules_v_rec.transfer_option_code := l_db_oks_batch_rules_v_rec.transfer_option_code;
        END IF;
        IF (x_oks_batch_rules_v_rec.bill_account_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.bill_account_id := l_db_oks_batch_rules_v_rec.bill_account_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.ship_account_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.ship_account_id := l_db_oks_batch_rules_v_rec.ship_account_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.bill_address_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.bill_address_id := l_db_oks_batch_rules_v_rec.bill_address_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.ship_address_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.ship_address_id := l_db_oks_batch_rules_v_rec.ship_address_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.bill_contact_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.bill_contact_id := l_db_oks_batch_rules_v_rec.bill_contact_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.created_by := l_db_oks_batch_rules_v_rec.created_by;
        END IF;
        IF (x_oks_batch_rules_v_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_batch_rules_v_rec.creation_date := l_db_oks_batch_rules_v_rec.creation_date;
        END IF;
        IF (x_oks_batch_rules_v_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.last_updated_by := l_db_oks_batch_rules_v_rec.last_updated_by;
        END IF;
        IF (x_oks_batch_rules_v_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_batch_rules_v_rec.last_update_date := l_db_oks_batch_rules_v_rec.last_update_date;
        END IF;
        IF (x_oks_batch_rules_v_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.last_update_login := l_db_oks_batch_rules_v_rec.last_update_login;
        END IF;
        IF (x_oks_batch_rules_v_rec.security_group_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.security_group_id := l_db_oks_batch_rules_v_rec.security_group_id;
        END IF;
        IF (x_oks_batch_rules_v_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_batch_rules_v_rec.request_id := l_db_oks_batch_rules_v_rec.request_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKS_BATCH_RULES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_batch_rules_v_rec IN oks_batch_rules_v_rec_type,
      x_oks_batch_rules_v_rec OUT NOCOPY oks_batch_rules_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_batch_rules_v_rec := p_oks_batch_rules_v_rec;
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
      p_oks_batch_rules_v_rec,           -- IN
      x_oks_batch_rules_v_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oks_batch_rules_v_rec, l_def_oks_batch_rules_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oks_batch_rules_v_rec := fill_who_columns(l_def_oks_batch_rules_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oks_batch_rules_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oks_batch_rules_v_rec, l_db_oks_batch_rules_v_rec);
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
      p_oks_batch_rules_v_rec        => p_oks_batch_rules_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_oks_batch_rules_v_rec, l_obtr_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_obtr_rec,
      lx_obtr_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_obtr_rec, l_def_oks_batch_rules_v_rec);
    x_oks_batch_rules_v_rec := l_def_oks_batch_rules_v_rec;
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
  -----------------------------------------------------
  -- PL/SQL TBL update_row for:oks_batch_rules_v_tbl --
  -----------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      i := p_oks_batch_rules_v_tbl.FIRST;
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
            p_oks_batch_rules_v_rec        => p_oks_batch_rules_v_tbl(i),
            x_oks_batch_rules_v_rec        => x_oks_batch_rules_v_tbl(i));
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
        EXIT WHEN (i = p_oks_batch_rules_v_tbl.LAST);
        i := p_oks_batch_rules_v_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL update_row for:OKS_BATCH_RULES_V_TBL --
  -----------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    x_oks_batch_rules_v_tbl        OUT NOCOPY oks_batch_rules_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_batch_rules_v_tbl        => p_oks_batch_rules_v_tbl,
        x_oks_batch_rules_v_tbl        => x_oks_batch_rules_v_tbl,
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
  ------------------------------------
  -- delete_row for:OKS_BATCH_RULES --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_obtr_rec                     IN obtr_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_obtr_rec                     obtr_rec_type := p_obtr_rec;
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

    DELETE FROM OKS_BATCH_RULES
     WHERE BATCH_ID = p_obtr_rec.batch_id;

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
  --------------------------------------
  -- delete_row for:OKS_BATCH_RULES_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_rec        IN oks_batch_rules_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_batch_rules_v_rec        oks_batch_rules_v_rec_type := p_oks_batch_rules_v_rec;
    l_obtr_rec                     obtr_rec_type;
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
    migrate(l_oks_batch_rules_v_rec, l_obtr_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_obtr_rec
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
  -------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_BATCH_RULES_V --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      i := p_oks_batch_rules_v_tbl.FIRST;
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
            p_oks_batch_rules_v_rec        => p_oks_batch_rules_v_tbl(i));
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
        EXIT WHEN (i = p_oks_batch_rules_v_tbl.LAST);
        i := p_oks_batch_rules_v_tbl.NEXT(i);
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

  -------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_BATCH_RULES_V --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_batch_rules_v_tbl        IN oks_batch_rules_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_batch_rules_v_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_batch_rules_v_tbl        => p_oks_batch_rules_v_tbl,
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

END OKS_BRL_PVT;

/

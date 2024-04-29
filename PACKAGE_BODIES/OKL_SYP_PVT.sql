--------------------------------------------------------
--  DDL for Package Body OKL_SYP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYP_PVT" AS
/* $Header: OKLSSYPB.pls 120.27.12010000.3 2008/11/13 13:54:39 kkorrapo ship $ */
---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

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
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
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
  -- FUNCTION get_rec for: OKL_SYSTEM_PARAMS_ALL_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sypv_rec   IN sypv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sypv_rec_type IS
    CURSOR okl_sys_params_v_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            DELINK_YN,
            -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
            REMK_SUBINVENTORY,
			REMK_ORGANIZATION_ID,
			REMK_PRICE_LIST_ID ,
			REMK_PROCESS_CODE ,
			REMK_ITEM_TEMPLATE_ID ,
			REMK_ITEM_INVOICED_CODE ,
			-- SECHAWLA 28-SEP-04 3924244: Added new columns - end
            -- PAGARG 24-JAN-05 4044659: Added new columns - begin
            LEASE_INV_ORG_YN,
            -- PAGARG 24-JAN-05 4044659: Added new columns - end
            --SECHAWLA  28-MAR-05 4274575 : Added new columns - begin
            TAX_UPFRONT_YN,
            TAX_INVOICE_YN,
            TAX_SCHEDULE_YN,
            --SECHAWLA  28-MAR-05 4274575 : Added new columns - end
            -- SECHAWLA 26-AUG-05 : added new col begin
            TAX_UPFRONT_STY_ID,
            -- SECHAWLA 26-AUG-05 : added new col end
	        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
	        CATEGORY_SET_ID,
	        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
            -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
	        VALIDATION_SET_ID,
	        -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
            CANCEL_QUOTES_YN, --RMUNJULU 4508497
            CHK_ACCRUAL_PREVIOUS_MNTH_YN, --rmunjulu 4769094
	    -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
            TASK_TEMPLATE_GROUP_ID,
            OWNER_TYPE_CODE,
            OWNER_ID,
            -- gboomina Bug 5128517 - End
            -- dcshanmu MOAC change start
            ITEM_INV_ORG_ID,
            RPT_PROD_BOOK_TYPE_CODE,
            ASST_ADD_BOOK_TYPE_CODE,
	    CCARD_REMITTANCE_ID,
            -- dcshanmu MOAC change end
            -- DJANASWA Bug 6653304 start
            CORPORATE_BOOK,
            TAX_BOOK_1,
            TAX_BOOK_2,
            DEPRECIATE_YN,
            FA_LOCATION_ID,
            FORMULA_ID,
            ASSET_KEY_ID,
            -- DJANASWA Bug 6653304 end
						-- Bug 5568328
						PART_TRMNT_APPLY_ROUND_DIFF,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
	    --Bug 7022258-Added by kkorrapo
 	    LSEAPP_SEQ_PREFIX_TXT,
	    LSEOPP_SEQ_PREFIX_TXT,
	    QCKQTE_SEQ_PREFIX_TXT,
	    LSEQTE_SEQ_PREFIX_TXT
	    --Bug 7022258--Addition end
      FROM OKL_SYSTEM_PARAMS
     WHERE OKL_SYSTEM_PARAMS.id = p_id;
    l_okl_sys_params_v_pk          okl_sys_params_v_pk_csr%ROWTYPE;
    l_sypv_rec   sypv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_sys_params_v_pk_csr (p_sypv_rec.id);
    FETCH okl_sys_params_v_pk_csr INTO
              l_sypv_rec.id,
              l_sypv_rec.delink_yn,
              -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
              l_sypv_rec.REMK_SUBINVENTORY,
			  l_sypv_rec.REMK_ORGANIZATION_ID,
			  l_sypv_rec.REMK_PRICE_LIST_ID ,
			  l_sypv_rec.REMK_PROCESS_CODE ,
			  l_sypv_rec.REMK_ITEM_TEMPLATE_ID ,
			  l_sypv_rec.REMK_ITEM_INVOICED_CODE ,
			  -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
              -- PAGARG 24-JAN-05 4044659: Added new columns - begin
              l_sypv_rec.LEASE_INV_ORG_YN,
              -- PAGARG 24-JAN-05 4044659: Added new columns - end
              --SECHAWLA  28-MAR-05 4274575 : Added new columns - begin
              l_sypv_rec.TAX_UPFRONT_YN,
              l_sypv_rec.TAX_INVOICE_YN,
              l_sypv_rec.TAX_SCHEDULE_YN,
              --SECHAWLA  28-MAR-05 4274575 : Added new columns - end

              -- SECHAWLA 26-AUG-05 : added new col begin
              l_sypv_rec.TAX_UPFRONT_STY_ID,
              -- SECHAWLA 26-AUG-05 : added new col end

	         -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
	         l_sypv_rec.CATEGORY_SET_ID,
	         -- asawanka 24-SEP-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
             -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
	         l_sypv_rec.VALIDATION_SET_ID,
             -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
              l_sypv_rec.CANCEL_QUOTES_YN, --RMUNJULU 4508497
              l_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN, --RMUNJULU 4769094
              -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
              l_sypv_rec.TASK_TEMPLATE_GROUP_ID,
              l_sypv_rec.OWNER_TYPE_CODE,
              l_sypv_rec.OWNER_ID,
              -- gboomina Bug 5128517 - End
              -- dcshanmu MOAC change start
              l_sypv_rec.ITEM_INV_ORG_ID,
              l_sypv_rec.RPT_PROD_BOOK_TYPE_CODE,
              l_sypv_rec.ASST_ADD_BOOK_TYPE_CODE,
	      l_sypv_rec.CCARD_REMITTANCE_ID,
              -- dcshanmu MOAC change end
             -- DJANASWA Bug 6653304 start
              l_sypv_rec.CORPORATE_BOOK,
              l_sypv_rec.TAX_BOOK_1,
              l_sypv_rec.TAX_BOOK_2,
              l_sypv_rec.DEPRECIATE_YN,
              l_sypv_rec.FA_LOCATION_ID,
              l_sypv_rec.FORMULA_ID,
              l_sypv_rec.ASSET_KEY_ID,
            -- DJANASWA Bug 6653304 end
						  -- Bug 5568328
							l_sypv_rec.part_trmnt_apply_round_diff,
              l_sypv_rec.object_version_number,
              l_sypv_rec.org_id,
              l_sypv_rec.request_id,
              l_sypv_rec.program_application_id,
              l_sypv_rec.program_id,
              l_sypv_rec.program_update_date,
              l_sypv_rec.attribute_category,
              l_sypv_rec.attribute1,
              l_sypv_rec.attribute2,
              l_sypv_rec.attribute3,
              l_sypv_rec.attribute4,
              l_sypv_rec.attribute5,
              l_sypv_rec.attribute6,
              l_sypv_rec.attribute7,
              l_sypv_rec.attribute8,
              l_sypv_rec.attribute9,
              l_sypv_rec.attribute10,
              l_sypv_rec.attribute11,
              l_sypv_rec.attribute12,
              l_sypv_rec.attribute13,
              l_sypv_rec.attribute14,
              l_sypv_rec.attribute15,
              l_sypv_rec.created_by,
              l_sypv_rec.creation_date,
              l_sypv_rec.last_updated_by,
              l_sypv_rec.last_update_date,
              l_sypv_rec.last_update_login,
	      --Bug 7022258-Added by kkorrapo
	      l_sypv_rec.lseapp_seq_prefix_txt,
	      l_sypv_rec.lseopp_seq_prefix_txt,
	      l_sypv_rec.qckqte_seq_prefix_txt,
	      l_sypv_rec.lseqte_seq_prefix_txt;
	      --Bug 7022258--Addition end
    x_no_data_found := okl_sys_params_v_pk_csr%NOTFOUND;
    CLOSE okl_sys_params_v_pk_csr;
    RETURN(l_sypv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sypv_rec   IN sypv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sypv_rec_type IS
    l_sypv_rec   sypv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_sypv_rec := get_rec(p_sypv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_sypv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sypv_rec   IN sypv_rec_type
  ) RETURN sypv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sypv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SYSTEM_PARAMS_ALL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_syp_rec                      IN syp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN syp_rec_type IS
    CURSOR okl_sys_params_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            DELINK_YN,
            -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
            REMK_SUBINVENTORY,
			REMK_ORGANIZATION_ID,
			REMK_PRICE_LIST_ID ,
			REMK_PROCESS_CODE ,
			REMK_ITEM_TEMPLATE_ID ,
			REMK_ITEM_INVOICED_CODE ,
		     -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
            -- PAGARG 24-JAN-05 4044659: Added new columns - begin
            LEASE_INV_ORG_YN,
            -- PAGARG 24-JAN-05 4044659: Added new columns - end

            --SECHAWLA  28-MAR-05 4274575 : Added new columns - begin
            TAX_UPFRONT_YN,
            TAX_INVOICE_YN,
            TAX_SCHEDULE_YN,
            --SECHAWLA  28-MAR-05 4274575 : Added new columns - end

            -- SECHAWLA 26-AUG-05 : added new col begin
            TAX_UPFRONT_STY_ID,
            -- SECHAWLA 26-AUG-05 : added new col end

            -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
      	    CATEGORY_SET_ID,
	    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
            -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
	        VALIDATION_SET_ID,
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
            CANCEL_QUOTES_YN, --RMUNJULU 4508497
			CHK_ACCRUAL_PREVIOUS_MNTH_YN, --rmunjulu 4769094
            -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
            TASK_TEMPLATE_GROUP_ID,
            OWNER_TYPE_CODE,
            OWNER_ID,
            -- gboomina Bug 5128517 - End
            -- dcshanmu MOAC Change starts
            ITEM_INV_ORG_ID,
            RPT_PROD_BOOK_TYPE_CODE,
            ASST_ADD_BOOK_TYPE_CODE,
	    CCARD_REMITTANCE_ID,
            -- dcshanmu MOAC Change end
            -- DJANASWA Bug 6653304 start
            CORPORATE_BOOK,
            TAX_BOOK_1,
            TAX_BOOK_2,
            DEPRECIATE_YN,
            FA_LOCATION_ID,
            FORMULA_ID,
            ASSET_KEY_ID,
            -- DJANASWA Bug 6653304 end
						--Bug 5568328
						PART_TRMNT_APPLY_ROUND_DIFF,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
	    --Bug 7022258-Added by kkorrapo
	    LSEAPP_SEQ_PREFIX_TXT,
	    LSEOPP_SEQ_PREFIX_TXT,
	    QCKQTE_SEQ_PREFIX_TXT,
	    LSEQTE_SEQ_PREFIX_TXT
	    --Bug 7022258--Addition end
      FROM OKL_SYSTEM_PARAMS_ALL
     WHERE OKL_SYSTEM_PARAMS_ALL.id = p_id;
    l_okl_sys_params_pk            okl_sys_params_pk_csr%ROWTYPE;
    l_syp_rec                      syp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_sys_params_pk_csr (p_syp_rec.id);
    FETCH okl_sys_params_pk_csr INTO
              l_syp_rec.id,
              l_syp_rec.delink_yn,
              -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
               l_syp_rec.REMK_SUBINVENTORY,
			   l_syp_rec.REMK_ORGANIZATION_ID,
			   l_syp_rec.REMK_PRICE_LIST_ID ,
			   l_syp_rec.REMK_PROCESS_CODE ,
			   l_syp_rec.REMK_ITEM_TEMPLATE_ID ,
			   l_syp_rec.REMK_ITEM_INVOICED_CODE ,
		     -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
              -- PAGARG 24-JAN-05 4044659: Added new columns - begin
              l_syp_rec.LEASE_INV_ORG_YN,
              -- PAGARG 24-JAN-05 4044659: Added new columns - end

              --SECHAWLA  28-MAR-05 4274575 : Added new columns - begin
              l_syp_rec.TAX_UPFRONT_YN,
              l_syp_rec.TAX_INVOICE_YN,
              l_syp_rec.TAX_SCHEDULE_YN,
              --SECHAWLA  28-MAR-05 4274575 : Added new columns - end

              -- SECHAWLA 26-AUG-05 : added new col begin
              l_syp_rec.TAX_UPFRONT_STY_ID,
              -- SECHAWLA 26-AUG-05 : added new col end

              -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
	      l_syp_rec.CATEGORY_SET_ID,
	      -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
          -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
 	      l_syp_rec.VALIDATION_SET_ID,
          -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
              l_syp_rec.CANCEL_QUOTES_YN, --RMUNJULU 4508497
              l_syp_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN, --rmunjulu 4769094
              -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
              l_syp_rec.TASK_TEMPLATE_GROUP_ID,
              l_syp_rec.OWNER_TYPE_CODE,
              l_syp_rec.OWNER_ID,
              -- gboomina Bug 5128517 - End
              -- dcshanmu MOAC Change starts
              l_syp_rec.ITEM_INV_ORG_ID,
              l_syp_rec.RPT_PROD_BOOK_TYPE_CODE,
              l_syp_rec.ASST_ADD_BOOK_TYPE_CODE,
	      l_syp_rec.CCARD_REMITTANCE_ID,
              -- dcshanmu MOAC Change end
             -- DJANASWA Bug 6653304 start
              l_syp_rec.CORPORATE_BOOK,
              l_syp_rec.TAX_BOOK_1,
              l_syp_rec.TAX_BOOK_2,
              l_syp_rec.DEPRECIATE_YN,
              l_syp_rec.FA_LOCATION_ID,
              l_syp_rec.FORMULA_ID,
              l_syp_rec.ASSET_KEY_ID,
            -- DJANASWA Bug 6653304 end
						  -- Bug 5568328
							l_syp_rec.part_trmnt_apply_round_diff,
              l_syp_rec.object_version_number,
              l_syp_rec.org_id,
              l_syp_rec.request_id,
              l_syp_rec.program_application_id,
              l_syp_rec.program_id,
              l_syp_rec.program_update_date,
              l_syp_rec.attribute_category,
              l_syp_rec.attribute1,
              l_syp_rec.attribute2,
              l_syp_rec.attribute3,
              l_syp_rec.attribute4,
              l_syp_rec.attribute5,
              l_syp_rec.attribute6,
              l_syp_rec.attribute7,
              l_syp_rec.attribute8,
              l_syp_rec.attribute9,
              l_syp_rec.attribute10,
              l_syp_rec.attribute11,
              l_syp_rec.attribute12,
              l_syp_rec.attribute13,
              l_syp_rec.attribute14,
              l_syp_rec.attribute15,
              l_syp_rec.created_by,
              l_syp_rec.creation_date,
              l_syp_rec.last_updated_by,
              l_syp_rec.last_update_date,
              l_syp_rec.last_update_login,
	      --Bug 7022258-Added by kkorrapo
	      l_syp_rec.lseapp_seq_prefix_txt,
	      l_syp_rec.lseopp_seq_prefix_txt,
	      l_syp_rec.qckqte_seq_prefix_txt,
	      l_syp_rec.lseqte_seq_prefix_txt;
	      --Bug 7022258--Addition end
    x_no_data_found := okl_sys_params_pk_csr%NOTFOUND;
    CLOSE okl_sys_params_pk_csr;
    RETURN(l_syp_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_syp_rec                      IN syp_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN syp_rec_type IS
    l_syp_rec                      syp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_syp_rec := get_rec(p_syp_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_syp_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_syp_rec                      IN syp_rec_type
  ) RETURN syp_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_syp_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SYSTEM_PARAMS_ALL_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sypv_rec   IN sypv_rec_type
  ) RETURN sypv_rec_type IS
    l_sypv_rec   sypv_rec_type := p_sypv_rec;
  BEGIN
    IF (l_sypv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.id := NULL;
    END IF;
    IF (l_sypv_rec.delink_yn = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.delink_yn := NULL;
    END IF;

    -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
    IF (l_sypv_rec.REMK_SUBINVENTORY = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.REMK_SUBINVENTORY := NULL;
    END IF;
    IF (l_sypv_rec.REMK_ORGANIZATION_ID = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.REMK_ORGANIZATION_ID := NULL;
    END IF;
    IF (l_sypv_rec.REMK_PRICE_LIST_ID = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.REMK_PRICE_LIST_ID := NULL;
    END IF;
    IF (l_sypv_rec.REMK_PROCESS_CODE = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.REMK_PROCESS_CODE := NULL;
    END IF;
    IF (l_sypv_rec.REMK_ITEM_TEMPLATE_ID = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.REMK_ITEM_TEMPLATE_ID := NULL;
    END IF;
    IF (l_sypv_rec.REMK_ITEM_INVOICED_CODE = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.REMK_ITEM_INVOICED_CODE := NULL;
    END IF;
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
    -- PAGARG 24-JAN-05 4044659: Added new columns - begin
    IF (l_sypv_rec.LEASE_INV_ORG_YN = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.LEASE_INV_ORG_YN := NULL;
    END IF;
    -- PAGARG 24-JAN-05 4044659: Added new columns - end

    --SECHAWLA  28-MAR-05 4274575 : Added new columns - begin
     IF (l_sypv_rec.TAX_UPFRONT_YN = OKL_API.G_MISS_CHAR ) THEN
       l_sypv_rec.TAX_UPFRONT_YN := NULL;
     END IF;

     IF (l_sypv_rec.TAX_INVOICE_YN = OKL_API.G_MISS_CHAR ) THEN
       l_sypv_rec.TAX_INVOICE_YN := NULL;
     END IF;

     IF (l_sypv_rec.TAX_SCHEDULE_YN = OKL_API.G_MISS_CHAR ) THEN
       l_sypv_rec.TAX_SCHEDULE_YN := NULL;
     END IF;
    --SECHAWLA  28-MAR-05 4274575 : Added new columns - end

    -- SECHAWLA 26-AUG-05 : added new col begin
     IF (l_sypv_rec.TAX_UPFRONT_STY_ID = OKL_API.G_MISS_NUM ) THEN
       l_sypv_rec.TAX_UPFRONT_STY_ID := NULL;
     END IF;
    -- SECHAWLA 26-AUG-05 : added new col end


    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
    IF (l_sypv_rec.CATEGORY_SET_ID = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.CATEGORY_SET_ID := NULL;
    END IF;
    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
	   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
    IF (l_sypv_rec.VALIDATION_SET_ID = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.VALIDATION_SET_ID := NULL;
    END IF;
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :

    --RMUNJULU 4508497
    IF (l_sypv_rec.CANCEL_QUOTES_YN = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.CANCEL_QUOTES_YN := NULL;
    END IF;

    --RMUNJULU 4769094
    IF (l_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN := NULL;
    END IF;

    -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
    IF (l_sypv_rec.TASK_TEMPLATE_GROUP_ID = OKL_API.G_MISS_NUM) THEN
      l_sypv_rec.TASK_TEMPLATE_GROUP_ID := NULL;
    END IF;

    IF (l_sypv_rec.OWNER_TYPE_CODE = OKL_API.G_MISS_CHAR) THEN
      l_sypv_rec.OWNER_TYPE_CODE := NULL;
    END IF;

    IF (l_sypv_rec.OWNER_ID = OKL_API.G_MISS_NUM) THEN
      l_sypv_rec.OWNER_ID := NULL;
    END IF;
    -- gboomina Bug 5128517 - End

   -- dcshanmu MOAC Change starts
   IF (l_sypv_rec.ITEM_INV_ORG_ID = OKL_API.G_MISS_NUM) THEN
    l_sypv_rec.ITEM_INV_ORG_ID := NULL;
   END IF;

   IF (l_sypv_rec.RPT_PROD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR) THEN
    l_sypv_rec.RPT_PROD_BOOK_TYPE_CODE := NULL;
   END IF;

   IF (l_sypv_rec.ASST_ADD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR) THEN
    l_sypv_rec.ASST_ADD_BOOK_TYPE_CODE := NULL;
   END IF;

   IF (l_sypv_rec.CCARD_REMITTANCE_ID = OKL_API.G_MISS_NUM) THEN
    l_sypv_rec.CCARD_REMITTANCE_ID := NULL;
   END IF;
   -- dcshanmu MOAC Change end

   -- DJANASWA Bug 6653304 start
    IF (l_sypv_rec.CORPORATE_BOOK = OKL_API.G_MISS_CHAR) THEN
        l_sypv_rec.CORPORATE_BOOK := NULL;
    END IF;

    IF (l_sypv_rec.TAX_BOOK_1 = OKL_API.G_MISS_CHAR) THEN
        l_sypv_rec.TAX_BOOK_1 := NULL;
    END IF;

    IF (l_sypv_rec.TAX_BOOK_2 = OKL_API.G_MISS_CHAR) THEN
        l_sypv_rec.TAX_BOOK_2 := NULL;
    END IF;

    IF (l_sypv_rec.DEPRECIATE_YN = OKL_API.G_MISS_CHAR) THEN
        l_sypv_rec.DEPRECIATE_YN := NULL;
    END IF;

    IF  (l_sypv_rec.FA_LOCATION_ID  = OKL_API.G_MISS_NUM ) THEN
         l_sypv_rec.FA_LOCATION_ID := NULL;
    END IF;

    IF  (l_sypv_rec.FORMULA_ID = OKL_API.G_MISS_NUM ) THEN
         l_sypv_rec.FORMULA_ID := NULL;
    END IF;

    IF (l_sypv_rec.ASSET_KEY_ID = OKL_API.G_MISS_NUM ) THEN
        l_sypv_rec.ASSET_KEY_ID := NULL;
    END IF;
    -- DJANASWA Bug 6653304 end
		-- Bug 5568328
    IF (l_sypv_rec.part_trmnt_apply_round_diff = okl_api.g_miss_char ) THEN
        l_sypv_rec.part_trmnt_apply_round_diff := NULL;
    END IF;
    IF (l_sypv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.object_version_number := NULL;
    END IF;
    IF (l_sypv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.org_id := NULL;
    END IF;
    IF (l_sypv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.request_id := NULL;
    END IF;
    IF (l_sypv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.program_application_id := NULL;
    END IF;
    IF (l_sypv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.program_id := NULL;
    END IF;
    IF (l_sypv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_sypv_rec.program_update_date := NULL;
    END IF;
    IF (l_sypv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute_category := NULL;
    END IF;
    IF (l_sypv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute1 := NULL;
    END IF;
    IF (l_sypv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute2 := NULL;
    END IF;
    IF (l_sypv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute3 := NULL;
    END IF;
    IF (l_sypv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute4 := NULL;
    END IF;
    IF (l_sypv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute5 := NULL;
    END IF;
    IF (l_sypv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute6 := NULL;
    END IF;
    IF (l_sypv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute7 := NULL;
    END IF;
    IF (l_sypv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute8 := NULL;
    END IF;
    IF (l_sypv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute9 := NULL;
    END IF;
    IF (l_sypv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute10 := NULL;
    END IF;
    IF (l_sypv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute11 := NULL;
    END IF;
    IF (l_sypv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute12 := NULL;
    END IF;
    IF (l_sypv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute13 := NULL;
    END IF;
    IF (l_sypv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute14 := NULL;
    END IF;
    IF (l_sypv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.attribute15 := NULL;
    END IF;
    IF (l_sypv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.created_by := NULL;
    END IF;
    IF (l_sypv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_sypv_rec.creation_date := NULL;
    END IF;
    IF (l_sypv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sypv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_sypv_rec.last_update_date := NULL;
    END IF;
    IF (l_sypv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_sypv_rec.last_update_login := NULL;
    END IF;
    --Bug 7022258-Added by kkorrapo
    IF (l_sypv_rec.lseapp_seq_prefix_txt = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.lseapp_seq_prefix_txt := NULL;
    END IF;
    IF (l_sypv_rec.lseopp_seq_prefix_txt = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.lseopp_seq_prefix_txt := NULL;
    END IF;
    IF (l_sypv_rec.qckqte_seq_prefix_txt = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.qckqte_seq_prefix_txt := NULL;
    END IF;
    IF (l_sypv_rec.lseqte_seq_prefix_txt = OKL_API.G_MISS_CHAR ) THEN
      l_sypv_rec.lseqte_seq_prefix_txt := NULL;
    END IF;
    --Bug 7022258--Addition end
    RETURN(l_sypv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_id = OKL_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ----------------------------------------------------
  -- Validate_Attributes for: DELINK_YN --
  -- RMUNJULU Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_delink_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_delink_yn                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_delink_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'delink_yn');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_delink_yn;
  ---------------------------------


    ----------------------------------------------------
  -- Validate_Attributes for: TAX_UPFRONT_YN --
  --SECHAWLA  28-MAR-05 4274575
  ----------------------------------------------------
  PROCEDURE validate_TAX_UPFRONT_YN(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_TAX_UPFRONT_YN               IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_TAX_UPFRONT_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'TAX_UPFRONT_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_TAX_UPFRONT_YN;
  ---------------------------------


  -------------------------------------
  -- Validate_Attributes for: validate_TAX_UPFRONT_sty_id --
  -------------------------------------
  PROCEDURE validate_TAX_UPFRONT_sty_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_TAX_UPFRONT_sty_id           IN NUMBER) IS

    l_dummy_var         VARCHAR2(1) := '?' ;

    CURSOR okl_sypv_sty_id_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM okl_strm_type_b
       WHERE id   = p_id;
  BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_TAX_UPFRONT_sty_id <> OKL_API.G_MISS_NUM AND p_TAX_UPFRONT_sty_id IS NOT NULL)
    THEN
      --OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sty_id');
      --l_return_status := OKL_API.G_RET_STS_ERROR;
      OPEN   okl_sypv_sty_id_fk_csr(p_TAX_UPFRONT_sty_id) ;
      FETCH  okl_sypv_sty_id_fk_csr into l_dummy_var ;
      CLOSE  okl_sypv_sty_id_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'tax_upfront_sty_id',
                        g_child_table_token ,
                        'OKL_SYSTEM_PARAMS_V',
                        g_parent_table_token ,
                        'okl_strm_type_b');
           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_TAX_UPFRONT_sty_id;

      ----------------------------------------------------
  -- Validate_Attributes for: TAX_INVOICE_YN --
  --SECHAWLA  28-MAR-05 4274575
  ----------------------------------------------------
  PROCEDURE validate_TAX_INVOICE_YN(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_TAX_INVOICE_YN              IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_TAX_INVOICE_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'TAX_INVOICE_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_TAX_INVOICE_YN;
  ---------------------------------


        ----------------------------------------------------
  -- Validate_Attributes for: TAX_SCHEDULE_YN --
  --SECHAWLA  28-MAR-05 4274575
  ----------------------------------------------------
  PROCEDURE validate_TAX_SCHEDULE_YN(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_TAX_SCHEDULE_YN              IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_TAX_SCHEDULE_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'TAX_SCHEDULE_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_TAX_SCHEDULE_YN;
  ---------------------------------

  ----------------------------------------------------
  -- Validate_Attributes for: REMK_ORGANIZATION_ID --
  -- SECHAWLA 28-SEP-04 3924244: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_organization_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_remk_organization_id         IN NUMBER) IS

    CURSOR l_orgdefs_csr(cp_org_id IN NUMBER) IS
    SELECT 'x'
	FROM   ORG_ORGANIZATION_DEFINITIONS
	WHERE  ORGANIZATION_ID = cp_org_id
	AND    SYSDATE <= NVL( DISABLE_DATE, SYSDATE );

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_remk_organization_id IS NOT NULL THEN
    	OPEN  l_orgdefs_csr(p_remk_organization_id);
    	FETCH l_orgdefs_csr INTO l_dummy;
    	IF l_orgdefs_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_ORGANIZATION_ID');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_orgdefs_csr;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_orgdefs_csr%ISOPEN THEN
         CLOSE l_orgdefs_csr;
	  END IF;
    WHEN OTHERS THEN
      IF l_orgdefs_csr%ISOPEN THEN
         CLOSE l_orgdefs_csr;
	  END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_organization_id;
  ---------------------------------

  ----------------------------------------------------
  -- Validate_Attributes for: REMK_SUBINVENTORY --
  -- SECHAWLA 28-SEP-04 3924244: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_subinventory(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_remk_subinventory         IN VARCHAR2) IS

    CURSOR l_mtlsecinventories_csr(cp_SECONDARY_INVENTORY_NAME IN VARCHAR2) IS
    SELECT 'x'
	FROM   MTL_SECONDARY_INVENTORIES
	WHERE  SECONDARY_INVENTORY_NAME = cp_SECONDARY_INVENTORY_NAME
	AND    NVL(DISABLE_DATE, SYSDATE+1) > SYSDATE
	AND    LOCATOR_TYPE=1
	AND    ASSET_INVENTORY = 1
	AND    RESERVABLE_TYPE=1;


    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_remk_subinventory IS NOT NULL THEN
    	OPEN  l_mtlsecinventories_csr(p_remk_subinventory);
    	FETCH l_mtlsecinventories_csr INTO l_dummy;
    	IF l_mtlsecinventories_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_SUBINVENTORY');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_mtlsecinventories_csr;
	END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_mtlsecinventories_csr%ISOPEN THEN
        CLOSE l_mtlsecinventories_csr;
	  END IF;
    WHEN OTHERS THEN
      IF l_mtlsecinventories_csr%ISOPEN THEN
        CLOSE l_mtlsecinventories_csr;
	  END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_subinventory;
  ---------------------------------


  ----------------------------------------------------
  -- Validate_Attributes for: REMK_PRICE_LIST_ID --
  -- SECHAWLA 28-SEP-04 3924244: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_price_list_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_REMK_PRICE_LIST_ID         IN NUMBER) IS

    CURSOR l_qplistheaders_csr(cp_LIST_HEADER_ID IN NUMBER) IS
    SELECT 'x'
	FROM   QP_LIST_HEADERS_TL
	WHERE  LIST_HEADER_ID = cp_LIST_HEADER_ID;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_REMK_PRICE_LIST_ID IS NOT NULL THEN
    	OPEN  l_qplistheaders_csr(p_REMK_PRICE_LIST_ID);
    	FETCH l_qplistheaders_csr INTO l_dummy;
    	IF l_qplistheaders_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_PRICE_LIST_ID');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_qplistheaders_csr;
   	END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_qplistheaders_csr%ISOPEN THEN
        CLOSE l_qplistheaders_csr;
	  END IF;
    WHEN OTHERS THEN
      IF l_qplistheaders_csr%ISOPEN THEN
        CLOSE l_qplistheaders_csr;
	  END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_price_list_id;
  ---------------------------------

    ----------------------------------------------------
  -- Validate_Attributes for: REMK_PRICE_LIST_ID --
  -- SECHAWLA 28-SEP-04 3924244: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_item_template_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_REMK_ITEM_TEMPLATE_ID         IN NUMBER) IS

    CURSOR l_mtlitemtempl_csr(cp_TEMPLATE_ID IN NUMBER) IS
    SELECT 'x'
	FROM   MTL_ITEM_TEMPLATES
	WHERE  TEMPLATE_ID = cp_TEMPLATE_ID;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_REMK_ITEM_TEMPLATE_ID IS NOT NULL THEN

      	OPEN  l_mtlitemtempl_csr(p_REMK_ITEM_TEMPLATE_ID);
    	FETCH l_mtlitemtempl_csr INTO l_dummy;
    	IF l_mtlitemtempl_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_ITEM_TEMPLATE_ID');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_mtlitemtempl_csr;
   	END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_mtlitemtempl_csr%ISOPEN THEN
        CLOSE l_mtlitemtempl_csr;
	  END IF;
    WHEN OTHERS THEN
      IF l_mtlitemtempl_csr%ISOPEN THEN
        CLOSE l_mtlitemtempl_csr;
	  END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_item_template_id;

  ----------------------------------------------------
  -- Validate_Attributes for: REMK_PROCESS_CODE --
  -- SECHAWLA 28-SEP-04 3924244: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_process_CODE(
    x_return_status        OUT NOCOPY VARCHAR2,
    p_REMK_PROCESS_CODE    IN  VARCHAR2) IS

    CURSOR l_processlookup_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
    SELECT 'x'
    FROM   Fnd_Lookup_Values
    WHERE  fnd_lookup_values.lookup_code = p_lookup_code
    AND    fnd_lookup_values.lookup_type = p_lookup_type;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_REMK_PROCESS_CODE IS NOT NULL THEN
    	OPEN  l_processlookup_csr(p_REMK_PROCESS_CODE,'OKL_RMK_PROCESS');
    	FETCH l_processlookup_csr INTO l_dummy;
    	IF l_processlookup_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_PROCESS_CODE');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_processlookup_csr;
   	END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_processlookup_csr%ISOPEN THEN
        CLOSE l_processlookup_csr;
	  END IF;
    WHEN OTHERS THEN
      IF l_processlookup_csr%ISOPEN THEN
        CLOSE l_processlookup_csr;
	  END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_process_CODE;

    ----------------------------------------------------
  -- Validate_Attributes for: REMK_ITEM_INVOICED --
  -- SECHAWLA 28-SEP-04 3924244: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_item_invoiced_CODE(
    x_return_status        OUT NOCOPY VARCHAR2,
    p_REMK_ITEM_INVOICED_CODE   IN  VARCHAR2) IS

    CURSOR l_processlookup_csr (p_lookup_code IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
    SELECT 'x'
    FROM   Fnd_Lookup_Values
    WHERE  fnd_lookup_values.lookup_code = p_lookup_code
    AND    fnd_lookup_values.lookup_type = p_lookup_type;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_REMK_ITEM_INVOICED_CODE IS NOT NULL THEN
    	OPEN  l_processlookup_csr(p_REMK_ITEM_INVOICED_CODE,'OKL_RMK_ITEM_INVOICED');
    	FETCH l_processlookup_csr INTO l_dummy;
    	IF l_processlookup_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_ITEM_INVOICED_CODE');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_processlookup_csr;
   	END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_processlookup_csr%ISOPEN THEN
        CLOSE l_processlookup_csr;
	  END IF;
    WHEN OTHERS THEN
      IF l_processlookup_csr%ISOPEN THEN
        CLOSE l_processlookup_csr;
	  END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_item_invoiced_CODE;

  ----------------------------------------------------
  -- Validate_Attributes for: LEASE_INV_ORG_YN --
  -- PAGARG 24-JAN-05 4044659: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_lease_inv_org_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lease_inv_org_yn             IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_lease_inv_org_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'LEASE_INV_ORG_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_lease_inv_org_yn;

  ----------------------------------------------------
  -- Validate_Attributes for: CATEGORY_SET_ID --
  -- ASAWANKA 24-May-2005 : Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_category_set_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_category_Set_id         IN NUMBER) IS

    CURSOR l_cat_set_csr(cp_cat_set_id IN NUMBER) IS
    SELECT  'X'
    FROM    MTL_ITEM_CATEGORIES MTLITMCATS,
	    MTL_CATEGORY_SETS MTLCATSETS
    WHERE   MTLITMCATS.CATEGORY_SET_ID = MTLCATSETS.CATEGORY_SET_ID
    AND     MTLITMCATS.ORGANIZATION_ID = OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID)
    AND	    MTLCATSETS.MULT_ITEM_CAT_ASSIGN_FLAG = 'N'
    AND     MTLITMCATS.CATEGORY_SET_ID = cp_cat_set_id;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_category_Set_id IS NOT NULL THEN

      	OPEN  l_cat_set_csr(p_category_Set_id);
    	FETCH l_cat_set_csr INTO l_dummy;
    	IF l_cat_set_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'CATEGORY_SET_ID');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_cat_set_csr;
   	END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_cat_set_csr%ISOPEN THEN
        CLOSE l_cat_set_csr;
      END IF;
    WHEN OTHERS THEN
      IF l_cat_set_csr%ISOPEN THEN
        CLOSE l_cat_set_csr;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_category_set_id;


  ------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for: VALIDATION_SET_ID --
  -- SSDESHPA 2-SEP-2005 : Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_validation_set_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_validation_set_id         IN NUMBER) IS

    CURSOR l_vld_set_csr(cp_vld_set_id IN NUMBER) IS
    SELECT  'X'
    FROM    OKL_VALIDATION_SETS_V
    WHERE ID = cp_vld_set_id;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_validation_set_id IS NOT NULL THEN

      	OPEN  l_vld_set_csr(p_validation_set_id);
    	FETCH l_vld_set_csr INTO l_dummy;
    	IF l_vld_set_csr%NOTFOUND THEN
       		x_return_status := OKL_API.G_RET_STS_ERROR;
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'VALIDATION_SET_ID');
       		RAISE G_EXCEPTION_HALT_VALIDATION;
    	END IF;
    	CLOSE l_vld_set_csr;
   	END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_vld_set_csr%ISOPEN THEN
        CLOSE l_vld_set_csr;
      END IF;
    WHEN OTHERS THEN
      IF l_vld_set_csr%ISOPEN THEN
        CLOSE l_vld_set_csr;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_validation_set_id;
  ----------------------------------------------------
  -- Validate_Attributes for: CANCEL_QUOTES_YN --
  -- RMUNJULU 4508497: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_cancel_quotes_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cancel_quotes_yn             IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_cancel_quotes_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'CANCEL_QUOTES_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_cancel_quotes_yn;

  ----------------------------------------------------
  -- Validate_Attributes for: CHK_ACCRUAL_PREVIOUS_MNTH_YN --
  -- RMUNJULU 4769094: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_ACCRUAL_PREV_MNTH_YN(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_accrual_check_yn             IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    						p_col_value 	=> p_accrual_check_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'CHK_ACCRUAL_PREVIOUS_MNTH_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_ACCRUAL_PREV_MNTH_YN;


----------------------------------------------------
  -- Validate_Attributes for: DEPRECIATE_YN --
  -- DJANASWA 6653304 : Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_DEPRECIATE_YN (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_DEPRECIATE_YN                IN VARCHAR2) IS

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_domain_yn(
    			p_col_value 	=> p_DEPRECIATE_YN);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'DEPRECIATE_YN');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_DEPRECIATE_YN;

------------------------------------------------------------------------------
 ----------------------------------------------------
  -- Validate_Attributes for: FORMULA_ID --
  -- DJANASWA  6653304: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_FORMULA_ID(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_FORMULA_ID         IN        NUMBER) IS

    CURSOR l_FORMULA_ID_csr(cp_FORMULA_ID IN NUMBER) IS
    SELECT 'x'
        FROM   okl_formulae_b
        WHERE  ID = cp_FORMULA_ID;

    l_dummy  VARCHAR2(1);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_FORMULA_ID IS NOT NULL THEN
        OPEN  l_FORMULA_ID_csr (p_FORMULA_ID);
        FETCH l_FORMULA_ID_csr INTO l_dummy;
        IF l_FORMULA_ID_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'FORMULA_ID');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_FORMULA_ID_csr;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_FORMULA_ID_csr%ISOPEN THEN
         CLOSE l_FORMULA_ID_csr;
          END IF;
    WHEN OTHERS THEN
      IF l_FORMULA_ID_csr%ISOPEN THEN
         CLOSE l_FORMULA_ID_csr;
          END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_FORMULA_ID;
  ---------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for: FA_LOCATION_ID --
  --  DJANASWA 6653304: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_FA_LOCATION_ID(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_FA_LOCATION_ID         	    IN NUMBER) IS

    CURSOR l_FA_LOCATION_ID_csr(cp_LOCATION_ID IN NUMBER) IS
    SELECT 'x'
        FROM   fa_locations
        WHERE  LOCATION_ID = cp_LOCATION_ID;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_FA_LOCATION_ID IS NOT NULL THEN
        OPEN  l_FA_LOCATION_ID_csr(p_FA_LOCATION_ID);
        FETCH l_FA_LOCATION_ID_csr INTO l_dummy;
        IF l_FA_LOCATION_ID_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'FA_LOCATION_ID');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_FA_LOCATION_ID_csr;
        END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_FA_LOCATION_ID_csr%ISOPEN THEN
        CLOSE l_FA_LOCATION_ID_csr;
          END IF;
    WHEN OTHERS THEN
      IF l_FA_LOCATION_ID_csr%ISOPEN THEN
        CLOSE l_FA_LOCATION_ID_csr;
          END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_FA_LOCATION_ID;

  ----------------------------------------------------
  -- Validate_Attributes for: ASSET_KEY_ID --
  --  DJANASWA 6653304: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_ASSET_KEY_ID(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ASSET_KEY_ID         	    IN NUMBER) IS

    CURSOR l_ASSET_KEY_ID_csr(cp_ASSET_KEY_ID IN NUMBER) IS
    SELECT 'x'
        FROM   fa_asset_keywords
        WHERE  CODE_COMBINATION_ID = cp_ASSET_KEY_ID;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_ASSET_KEY_ID IS NOT NULL THEN
        OPEN  l_ASSET_KEY_ID_csr(p_ASSET_KEY_ID);
        FETCH l_ASSET_KEY_ID_csr INTO l_dummy;
        IF l_ASSET_KEY_ID_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'ASSET_KEY_ID');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_ASSET_KEY_ID_csr;
        END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_ASSET_KEY_ID_csr%ISOPEN THEN
        CLOSE l_ASSET_KEY_ID_csr;
          END IF;
    WHEN OTHERS THEN
      IF l_ASSET_KEY_ID_csr%ISOPEN THEN
        CLOSE l_ASSET_KEY_ID_csr;
          END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_ASSET_KEY_ID;
  ---------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for: CORPORATE_BOOK --
  --  DJANASWA 6653304: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_CORPORATE_BOOK(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_CORPORATE_BOOK                IN VARCHAR2) IS

    CURSOR l_CORPORATE_BOOK_csr(cp_CORPORATE_BOOK IN VARCHAR2) IS
    SELECT 'x'
        FROM   fa_book_controls
        WHERE  BOOK_CLASS LIKE 'CORPORATE'
        AND    BOOK_TYPE_CODE = cp_CORPORATE_BOOK;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_CORPORATE_BOOK IS NOT NULL THEN
        OPEN  l_CORPORATE_BOOK_csr(p_CORPORATE_BOOK);
        FETCH l_CORPORATE_BOOK_csr INTO l_dummy;
        IF l_CORPORATE_BOOK_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'CORPORATE_BOOK');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_CORPORATE_BOOK_csr;
        END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_CORPORATE_BOOK_csr%ISOPEN THEN
        CLOSE l_CORPORATE_BOOK_csr;
          END IF;
    WHEN OTHERS THEN
      IF l_CORPORATE_BOOK_csr%ISOPEN THEN
        CLOSE l_CORPORATE_BOOK_csr;
          END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_CORPORATE_BOOK;
  ---------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for: TAX_BOOK_1 --
  --  DJANASWA 6653304: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_TAX_BOOK_1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_TAX_BOOK_1                IN VARCHAR2) IS

    CURSOR l_TAX_BOOK_1_csr(cp_TAX_BOOK_1 IN VARCHAR2) IS
    SELECT 'x'
        FROM   fa_book_controls
        WHERE  BOOK_CLASS LIKE 'TAX'
        AND    BOOK_TYPE_CODE = cp_TAX_BOOK_1;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_TAX_BOOK_1 IS NOT NULL THEN
        OPEN  l_TAX_BOOK_1_csr(p_TAX_BOOK_1);
        FETCH l_TAX_BOOK_1_csr INTO l_dummy;
        IF l_TAX_BOOK_1_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'TAX_BOOK_1');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_TAX_BOOK_1_csr;
        END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_TAX_BOOK_1_csr%ISOPEN THEN
        CLOSE l_TAX_BOOK_1_csr;
          END IF;
    WHEN OTHERS THEN
      IF l_TAX_BOOK_1_csr%ISOPEN THEN
        CLOSE l_TAX_BOOK_1_csr;
          END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_TAX_BOOK_1;
  ---------------------------------

  ----------------------------------------------------
  -- Validate_Attributes for: TAX_BOOK_2 --
  --  DJANASWA 6653304: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_TAX_BOOK_2(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_TAX_BOOK_2                IN VARCHAR2) IS

    CURSOR l_TAX_BOOK_2_csr(cp_TAX_BOOK_2 IN VARCHAR2) IS
    SELECT 'x'
        FROM   fa_book_controls
        WHERE  BOOK_CLASS LIKE 'TAX'
        AND    BOOK_TYPE_CODE = cp_TAX_BOOK_2;

    l_dummy  VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF p_TAX_BOOK_2 IS NOT NULL THEN
        OPEN  l_TAX_BOOK_2_csr(p_TAX_BOOK_2);
        FETCH l_TAX_BOOK_2_csr INTO l_dummy;
        IF l_TAX_BOOK_2_csr%NOTFOUND THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'TAX_BOOK_2');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_TAX_BOOK_2_csr;
        END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF l_TAX_BOOK_2_csr%ISOPEN THEN
        CLOSE l_TAX_BOOK_2_csr;
          END IF;
    WHEN OTHERS THEN
      IF l_TAX_BOOK_2_csr%ISOPEN THEN
        CLOSE l_TAX_BOOK_2_csr;
          END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_TAX_BOOK_2;
  ---------------------------------

  ----------------------------------------------------
  -- Validate_Attributes for: PART_TRMNT_APPLY_ROUND_DIFF --
  --  schodava 5568328: Added this procedure
  ----------------------------------------------------
  PROCEDURE validate_part_trmnt_diff(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_part_trmnt_apply_round_diff  IN VARCHAR2) IS

    CURSOR c_part_trmnt_apply_round_diff(cp_part_trmnt_apply_round_diff IN VARCHAR2) IS
    SELECT 'x'
        FROM   fnd_lookups
        WHERE  lookup_type = 'OKL_APPLY_ROUNDING_DIFF'
        AND    lookup_code = cp_part_trmnt_apply_round_diff
				AND    lookup_code IN ('ADD_TO_HIGH','ADD_TO_LOW');

    l_dummy  VARCHAR2(1);

  BEGIN

    x_return_status := okl_api.g_ret_sts_success;
    IF p_part_trmnt_apply_round_diff IS NOT NULL THEN
        OPEN  c_part_trmnt_apply_round_diff(cp_part_trmnt_apply_round_diff => p_part_trmnt_apply_round_diff);
        FETCH c_part_trmnt_apply_round_diff INTO l_dummy;
        IF c_part_trmnt_apply_round_diff%NOTFOUND THEN
                x_return_status := okl_api.g_ret_sts_error;
                okl_api.set_message(p_app_name          => G_APP_NAME,
                                    p_msg_name          => G_INVALID_VALUE,
                                    p_token1            => G_COL_NAME_TOKEN,
                                    p_token1_value      => 'PART_TRMNT_APPLY_ROUND_DIFF');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE c_part_trmnt_apply_round_diff;
        END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      --null;
      IF c_part_trmnt_apply_round_diff%ISOPEN THEN
        CLOSE c_part_trmnt_apply_round_diff;
      END IF;
    WHEN OTHERS THEN
      IF c_part_trmnt_apply_round_diff%ISOPEN THEN
        CLOSE c_part_trmnt_apply_round_diff;
      END IF;
      okl_api.set_message( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.g_ret_sts_unexp_error;
  END validate_part_trmnt_diff;
  ---------------------------------


  -- is_unique --
  -- RMUNJULU Added this procedure to check the uniqueness of the record
  -- Idea is to restrict multiple records for org_id, ie to have only one record for one org
  ---------------------------------
  PROCEDURE is_unique(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_syp_rec                      IN syp_rec_type) IS
    -- Get DB values for org_id (query on _V means query for org_id)
    CURSOR get_db_values_csr IS
    SELECT SYP.id
    FROM   OKL_SYSTEM_PARAMS SYP;
    l_id NUMBER;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN get_db_values_csr;
    FETCH get_db_values_csr INTO l_id;
    IF get_db_values_csr%FOUND THEN
       OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'org_id');
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE get_db_values_csr;
  EXCEPTION
    WHEN OTHERS THEN
      IF get_db_values_csr%ISOPEN THEN
         CLOSE get_db_values_csr;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END is_unique;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------------
  -- Validate_Attributes for:OKL_SYSTEM_PARAMS_ALL_V --
  -- RMUNJULU Added call to Validate_Delink_yn
  -- SECHAWLA 28-MAR-05 4274575 Added call to Validate_TAX_UPFRONT_YN, Validate_TAX_INVOICE_YN, Validate_TAX_SCHEDULE_YN
  ---------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sypv_rec   IN sypv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_sypv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_sypv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- delink_yn
    -- ***
    validate_delink_yn(x_return_status, p_sypv_rec.delink_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- SECHAWLA 29-SEP-04 3924244: Added the following validate calls for the new attributes
    -- ***
    -- REMK_ORGANIZATION_ID
    -- ***
    validate_organization_id(x_return_status, p_sypv_rec.REMK_ORGANIZATION_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- REMK_SUBINVENTORY
    -- ***
    validate_subinventory(x_return_status, p_sypv_rec.REMK_SUBINVENTORY);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- REMK_PRICE_LIST_ID
    -- ***
    validate_price_list_id(x_return_status, p_sypv_rec.REMK_PRICE_LIST_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- REMK_ITEM_TEMPLATE_ID
    -- ***
    validate_item_template_id(x_return_status, p_sypv_rec.REMK_ITEM_TEMPLATE_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- REMK_PROCESS_CODE
    -- ***
    validate_process_CODE(x_return_status, p_sypv_rec.REMK_PROCESS_CODE);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- REMK_ITEM_INVOICED_CODE
    -- ***
    validate_item_invoiced_CODE(x_return_status, p_sypv_rec.REMK_ITEM_INVOICED_CODE);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- PAGARG 24-JAN-05 4044659: Added the following validate call
    -- ***
    -- LEASE_INV_ORG_YN
    -- ***
    validate_lease_inv_org_yn(x_return_status, p_sypv_rec.lease_inv_org_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --SECHAWLA  28-MAR-05 4274575 : Added the following validate calls - begin
    -- ***
    -- TAX_UPFRONT_YN
    -- ***
    validate_TAX_UPFRONT_YN(x_return_status, p_sypv_rec.TAX_UPFRONT_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	-- ***
    -- TAX_INVOICE_YN
    -- ***
    validate_TAX_INVOICE_YN(x_return_status, p_sypv_rec.TAX_INVOICE_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	-- ***
    -- TAX_SCHEDULE_YN
    -- ***
    validate_TAX_SCHEDULE_YN(x_return_status, p_sypv_rec.TAX_SCHEDULE_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    --SECHAWLA  28-MAR-05 4274575 : Added the following validate calls - end

    -- SECHAWLA 26-AUG-05 4274575 : Added the following validate call - begin
    -- ***
    -- TAX_UPFRONT_STY_ID
    -- ***
    validate_TAX_UPFRONT_STY_ID(x_return_status, p_sypv_rec.TAX_UPFRONT_STY_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- SECHAWLA 26-AUG-05 4274575 : Added the following validate call - end


    -- ASAWANKA 24-May-2005 : Added the following validate call - begin
    -- ***
    -- CATEGORY_SET_ID
    -- ***
    validate_category_set_id(x_return_status, p_sypv_rec.category_set_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ASAWANKA 24-MAY-2005 : Added the following validate call - end

    -- SSDESHPA 2-Sep-2005 : Added the following validate call - begin
    -- ***
    -- VALIDATION_SET_ID
    -- ***
    validate_validation_set_id(x_return_status, p_sypv_rec.validation_set_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
     -- SSDESHPA 2-SEP-2005 : Added the following validate call - end

    --RMUNJULU 4508497
    -- ***
    -- CANCEL_QUOTES_YN
    -- ***
    validate_cancel_quotes_yn(x_return_status, p_sypv_rec.cancel_quotes_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --RMUNJULU 4769094
    -- ***
    -- CHK_ACCRUAL_PREVIOUS_MNTH_YN
    -- ***
    validate_ACCRUAL_PREV_MNTH_YN(x_return_status, p_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- DJANASWA  bug  6653304 start
    -- ***
    -- DEPRECIATE_YN
    -- ***

    validate_DEPRECIATE_YN (x_return_status, p_sypv_rec.DEPRECIATE_YN);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- FORMULA_ID
    -- ***

    validate_FORMULA_ID (x_return_status, p_sypv_rec.FORMULA_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- FA_LOCATION_ID
    -- ***

    validate_FA_LOCATION_ID (x_return_status, p_sypv_rec.FA_LOCATION_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- ASSET_KEY_ID
    -- ***

    validate_ASSET_KEY_ID (x_return_status, p_sypv_rec.ASSET_KEY_ID);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- CORPORATE_BOOK
    -- ***

    validate_CORPORATE_BOOK (x_return_status, p_sypv_rec.CORPORATE_BOOK);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- TAX_BOOK_1
    -- ***

    validate_TAX_BOOK_1 (x_return_status, p_sypv_rec.TAX_BOOK_1);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- TAX_BOOK_2
    -- ***

    validate_TAX_BOOK_2 (x_return_status, p_sypv_rec.TAX_BOOK_2);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- DJANASWA bug 6653304 end

    -- Bug 5568328

    -- ***
    -- PART_TRMNT_APPLY_ROUND_DIFF
    -- ***

    validate_part_trmnt_diff (x_return_status, p_sypv_rec.part_trmnt_apply_round_diff);
    IF (x_return_status <> okl_api.g_ret_sts_success) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME_1
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate Record for:OKL_SYSTEM_PARAMS_ALL_V --
  -----------------------------------------------------
  FUNCTION Validate_Record (
    p_sypv_rec IN sypv_rec_type,
    p_db_OklSystemParam1 IN sypv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy   VARCHAR2(1);
    l_org_name  mtl_organizations.organization_name%TYPE;
    -- SECHAWLA 29-SEP-04 3924244: Added the following cursor to validate item template
    CURSOR l_mtlitemtempl_csr(cp_TEMPLATE_ID IN NUMBER, cp_context_organization_id IN NUMBER) IS
    SELECT 'x'
	FROM   MTL_ITEM_TEMPLATES
	WHERE  TEMPLATE_ID = cp_TEMPLATE_ID
	AND    (context_organization_id IS NULL OR context_organization_id = cp_context_organization_id);

	-- SECHAWLA 16-DEC-04 4067511 : added following cursors
	-- This cursor is used to validate Organization and subinventory
	CURSOR l_mtlsecinv_csr(cp_inv_org_id NUMBER, cp_subinv_code VARCHAR2) IS
	SELECT 'x'
	FROM   mtl_secondary_inventories
	WHERE  organization_id = cp_inv_org_id
	AND    secondary_inventory_name = cp_subinv_code;

	-- get org name
	CURSOR l_orgdefs_csr(cp_org_id IN NUMBER) IS
	SELECT organization_name
    FROM   ORG_ORGANIZATION_DEFINITIONS
    WHERE  organization_id = cp_org_id;


  BEGIN
    -- SECHAWLA 29-SEP-04 3924244: added the following validation : begin
    IF p_sypv_rec.REMK_ITEM_TEMPLATE_ID IS NOT NULL THEN
       IF p_sypv_rec.REMK_ORGANIZATION_ID IS NULL THEN
       -- Please enter Inventory Organization before entering Item Template.
          okl_api.SET_MESSAGE( 	 p_app_name     => 'OKL'
                          		,p_msg_name      => 'OKL_AM_SETUP_ORG_FOR_TEMPL');
         l_return_status := okl_api.G_RET_STS_ERROR;
         RETURN (l_return_status);
       END IF;
       -- At this point, both item template and inventory organization will have a value
       OPEN  l_mtlitemtempl_csr(p_sypv_rec.REMK_ITEM_TEMPLATE_ID, p_sypv_rec.REMK_ORGANIZATION_ID);
       FETCH l_mtlitemtempl_csr INTO l_dummy;
       IF l_mtlitemtempl_csr%NOTFOUND THEN
       		OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'REMK_ITEM_TEMPLATE_ID');
      		l_return_status := OKL_API.G_RET_STS_ERROR;
      		RETURN (l_return_status);
       END IF;
       CLOSE l_mtlitemtempl_csr;

       -- Item template can be entered only if Process is Custom
       IF p_sypv_rec.REMK_PROCESS_CODE IS NULL OR p_sypv_rec.REMK_PROCESS_CODE = OKL_API.G_MISS_CHAR
	      OR p_sypv_rec.REMK_PROCESS_CODE <> 'CUSTOM' THEN
	        -- Item Template can be entered only if the Process is "Custom".
	      	okl_api.SET_MESSAGE( 	 p_app_name     => 'OKL'
                          		    ,p_msg_name     => 'OKL_AM_REQ_CUSTOM_PROCESS');
         	l_return_status := okl_api.G_RET_STS_ERROR;
         	RETURN (l_return_status);
	   END IF;

	END IF;

	-- SECHAWLA 16-DEC-04 4067511 : added this validation
	IF p_sypv_rec.REMK_ORGANIZATION_ID IS NOT NULL AND p_sypv_rec.REMK_SUBINVENTORY IS NOT NULL THEN
	   OPEN  l_mtlsecinv_csr(p_sypv_rec.REMK_ORGANIZATION_ID, p_sypv_rec.REMK_SUBINVENTORY);
	   FETCH l_mtlsecinv_csr INTO l_dummy;
	   IF l_mtlsecinv_csr%NOTFOUND THEN

	      OPEN  l_orgdefs_csr(p_sypv_rec.REMK_ORGANIZATION_ID);
	      FETCH l_orgdefs_csr INTO l_org_name;
	      CLOSE l_orgdefs_csr;

	      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_RMK_ORG_SUBINV',
                          p_token1       => 'SUBINVENTORY',
                          p_token1_value => p_sypv_rec.REMK_SUBINVENTORY,
                          p_token2       => 'ORGANIZATION',
                          p_token2_value => l_org_name);

          l_return_status := OKL_API.G_RET_STS_ERROR;
      	  RETURN (l_return_status);
       END IF;
       CLOSE l_mtlsecinv_csr;
    END IF;
    -- SECHAWLA 16-DEC-04 4067511 : end

	-- SECHAWLA 29-SEP-04 3924244: added the following validation : end
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_sypv_rec IN sypv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_OklSystemParam2           sypv_rec_type := get_rec(p_sypv_rec);
  BEGIN
    l_return_status := Validate_Record(p_sypv_rec => p_sypv_rec,
                                       p_db_OklSystemParam1 => l_db_OklSystemParam2);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN sypv_rec_type,
    p_to   IN OUT NOCOPY syp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.delink_yn := p_from.delink_yn;
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
    p_to.REMK_SUBINVENTORY    :=   p_from.REMK_SUBINVENTORY;
	p_to.REMK_ORGANIZATION_ID := p_from.REMK_ORGANIZATION_ID;
	p_to.REMK_PRICE_LIST_ID    :=  p_from.REMK_PRICE_LIST_ID;
	p_to.REMK_PROCESS_CODE     :=     p_from.REMK_PROCESS_CODE;
	p_to.REMK_ITEM_TEMPLATE_ID  :=  p_from.REMK_ITEM_TEMPLATE_ID  ;
	p_to.REMK_ITEM_INVOICED_CODE  :=  p_from.REMK_ITEM_INVOICED_CODE ;
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
    -- PAGARG 24-JAN-05 4044659: Added new columns - begin
	p_to.LEASE_INV_ORG_YN  :=  p_from.LEASE_INV_ORG_YN ;
    -- PAGARG 24-JAN-05 4044659: Added new columns - end

    --SECHAWLA  28-MAR-05 4274575 :Added new columns - begin
    p_to.TAX_UPFRONT_YN := p_from.TAX_UPFRONT_YN;
    p_to.TAX_INVOICE_YN := p_from.TAX_INVOICE_YN;
    p_to.TAX_SCHEDULE_YN := p_from.TAX_SCHEDULE_YN;
    --SECHAWLA  28-MAR-05 4274575 :Added new columns - end

    -- SECHAWLA 26-AUG-05 4274575 : Added new column - begin
    p_to.TAX_UPFRONT_STY_ID := p_from.TAX_UPFRONT_STY_ID;
    -- SECHAWLA 26-AUG-05 4274575 : Added new column - end

    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
    p_to.category_set_id := p_from.category_set_id;
    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
      -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
    p_to.validation_set_id := p_from.validation_set_id;
    -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :

    -- rmunjulu 4508497
    p_to.CANCEL_QUOTES_YN  :=  p_from.CANCEL_QUOTES_YN ;

    -- rmunjulu 4769094
    p_to.CHK_ACCRUAL_PREVIOUS_MNTH_YN  :=  p_from.CHK_ACCRUAL_PREVIOUS_MNTH_YN ;
    -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
    p_to.TASK_TEMPLATE_GROUP_ID :=  p_from.TASK_TEMPLATE_GROUP_ID;
    p_to.OWNER_TYPE_CODE :=  p_from.OWNER_TYPE_CODE;
    p_to.OWNER_ID :=  p_from.OWNER_ID;
    -- gboomina Bug 5128517 - End
    -- dcshanmu MOAC Change starts
    p_to.ITEM_INV_ORG_ID := p_from.ITEM_INV_ORG_ID;
    p_to.RPT_PROD_BOOK_TYPE_CODE := p_from.RPT_PROD_BOOK_TYPE_CODE;
    p_to.ASST_ADD_BOOK_TYPE_CODE := p_from.ASST_ADD_BOOK_TYPE_CODE;
    p_to.CCARD_REMITTANCE_ID := p_from.CCARD_REMITTANCE_ID;
    -- dcshanmu MOAC Change end
    -- DJANASWA Bug 6653304 start
    p_to.CORPORATE_BOOK := p_from.CORPORATE_BOOK;
    p_to.TAX_BOOK_1 := p_from.TAX_BOOK_1;
    p_to.TAX_BOOK_2 := p_from.TAX_BOOK_2;
    p_to.DEPRECIATE_YN := p_from.DEPRECIATE_YN;
    p_to.FA_LOCATION_ID := p_from.FA_LOCATION_ID;
    p_to.FORMULA_ID := p_from.FORMULA_ID;
    p_to.ASSET_KEY_ID := p_from.ASSET_KEY_ID;
    -- DJANASWA Bug 6653304 end
		-- Bug 5568328
    p_to.part_trmnt_apply_round_diff := p_from.part_trmnt_apply_round_diff;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    --Bug 7022258-Added by kkorrapo
    p_to.lseapp_seq_prefix_txt := p_from.lseapp_seq_prefix_txt;
    p_to.lseopp_seq_prefix_txt := p_from.lseopp_seq_prefix_txt;
    p_to.lseqte_seq_prefix_txt := p_from.lseqte_seq_prefix_txt;
    p_to.qckqte_seq_prefix_txt := p_from.qckqte_seq_prefix_txt;
    --Bug 7022258--Addition end
  END migrate;
  PROCEDURE migrate (
    p_from IN syp_rec_type,
    p_to   IN OUT NOCOPY sypv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.delink_yn := p_from.delink_yn;
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
    p_to.REMK_SUBINVENTORY    :=   p_from.REMK_SUBINVENTORY;
	p_to.REMK_ORGANIZATION_ID :=   p_from.REMK_ORGANIZATION_ID;
	p_to.REMK_PRICE_LIST_ID   :=   p_from.REMK_PRICE_LIST_ID;
	p_to.REMK_PROCESS_CODE         :=   p_from.REMK_PROCESS_CODE;
	p_to.REMK_ITEM_TEMPLATE_ID   :=   p_from.REMK_ITEM_TEMPLATE_ID;
	p_to.REMK_ITEM_INVOICED_CODE   :=   p_from.REMK_ITEM_INVOICED_CODE;
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
    -- PAGARG 24-JAN-05 4044659: Added new columns - begin
	p_to.LEASE_INV_ORG_YN  :=  p_from.LEASE_INV_ORG_YN ;
    -- PAGARG 24-JAN-05 4044659: Added new columns - end

    --SECHAWLA  28-MAR-05 4274575 :Added new columns - begin
    p_to.TAX_UPFRONT_YN := p_from.TAX_UPFRONT_YN;
    p_to.TAX_INVOICE_YN := p_from.TAX_INVOICE_YN;
    p_to.TAX_SCHEDULE_YN := p_from.TAX_SCHEDULE_YN;
    --SECHAWLA  28-MAR-05 4274575 :Added new columns - end

    -- SECHAWLA 26-AUG-05 4274575 : Added new column - begin
    p_to.TAX_UPFRONT_STY_ID := p_from.TAX_UPFRONT_STY_ID;
    -- SECHAWLA 26-AUG-05 4274575 : Added new column - end

    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
    p_to.category_set_id := p_from.category_set_id;
    -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
    p_to.validation_set_id := p_from.validation_set_id;
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :


    -- rmunjulu 4508497
    p_to.CANCEL_QUOTES_YN  :=  p_from.CANCEL_QUOTES_YN ;
    -- rmunjulu 4769094
    p_to.CHK_ACCRUAL_PREVIOUS_MNTH_YN  :=  p_from.CHK_ACCRUAL_PREVIOUS_MNTH_YN ;
    -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
    p_to.TASK_TEMPLATE_GROUP_ID :=  p_from.TASK_TEMPLATE_GROUP_ID;
    p_to.OWNER_TYPE_CODE :=  p_from.OWNER_TYPE_CODE;
    p_to.OWNER_ID :=  p_from.OWNER_ID;
    -- gboomina Bug 5128517 - End
    -- dcshanmu MOAC Change starts
    p_to.ITEM_INV_ORG_ID := p_from.ITEM_INV_ORG_ID;
    p_to.RPT_PROD_BOOK_TYPE_CODE := p_from.RPT_PROD_BOOK_TYPE_CODE;
    p_to.ASST_ADD_BOOK_TYPE_CODE := p_from.ASST_ADD_BOOK_TYPE_CODE;
    p_to.CCARD_REMITTANCE_ID := p_from.CCARD_REMITTANCE_ID;
    -- dcshanmu MOAC change end
     -- DJANASWA Bug 6653304 start
    p_to.CORPORATE_BOOK := p_from.CORPORATE_BOOK;
    p_to.TAX_BOOK_1 := p_from.TAX_BOOK_1;
    p_to.TAX_BOOK_2 := p_from.TAX_BOOK_2;
    p_to.DEPRECIATE_YN := p_from.DEPRECIATE_YN;
    p_to.FA_LOCATION_ID := p_from.FA_LOCATION_ID;
    p_to.FORMULA_ID := p_from.FORMULA_ID;
    p_to.ASSET_KEY_ID := p_from.ASSET_KEY_ID;
    -- DJANASWA Bug 6653304 end
		-- Bug 5568328
    p_to.part_trmnt_apply_round_diff := p_from.part_trmnt_apply_round_diff;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    --Bug 7022258-Added by kkorrapo
    p_to.lseapp_seq_prefix_txt := p_from.lseapp_seq_prefix_txt;
    p_to.lseopp_seq_prefix_txt := p_from.lseopp_seq_prefix_txt;
    p_to.lseqte_seq_prefix_txt := p_from.lseqte_seq_prefix_txt;
    p_to.qckqte_seq_prefix_txt := p_from.qckqte_seq_prefix_txt;
    --Bug 7022258--Addition end
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- validate_row for:OKL_SYSTEM_PARAMS_ALL_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sypv_rec                     sypv_rec_type := p_sypv_rec;
    l_syp_rec                      syp_rec_type;
    l_syp_rec                      syp_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_sypv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sypv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SYSTEM_PARAMS_ALL_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      i := p_sypv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_sypv_rec                     => p_sypv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_sypv_tbl.LAST);
        i := p_sypv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SYSTEM_PARAMS_ALL_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sypv_tbl                     => p_sypv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- insert_row for:OKL_SYSTEM_PARAMS_ALL --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_syp_rec                      IN syp_rec_type,
    x_syp_rec                      OUT NOCOPY syp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_syp_rec                      syp_rec_type := p_syp_rec;
    l_def_syp_rec                  syp_rec_type;
    --------------------------------------------------
    -- Set_Attributes for:OKL_SYSTEM_PARAMS_ALL --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_syp_rec IN syp_rec_type,
      x_syp_rec OUT NOCOPY syp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_syp_rec := p_syp_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_syp_rec,                         -- IN
      l_syp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    is_unique(l_return_status, l_syp_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SYSTEM_PARAMS_ALL(
      id,
      delink_yn,
      -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
      REMK_SUBINVENTORY  ,
	  REMK_ORGANIZATION_ID ,
	  REMK_PRICE_LIST_ID,
	  REMK_PROCESS_CODE   ,
	  REMK_ITEM_TEMPLATE_ID ,
	  REMK_ITEM_INVOICED_CODE  ,
      -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
      -- PAGARG 24-JAN-05 4044659: Added new columns - begin
      LEASE_INV_ORG_YN,
      -- PAGARG 24-JAN-05 4044659: Added new columns - end

      --SECHAWLA  28-MAR-05 4274575 :Added new columns - begin
      TAX_UPFRONT_YN ,
      TAX_INVOICE_YN,
      TAX_SCHEDULE_YN ,
      --SECHAWLA  28-MAR-05 4274575 :Added new columns - end

      -- SECHAWLA 26-AUG-05 4274575 : Added new column - begin
      TAX_UPFRONT_STY_ID,
      -- SECHAWLA 26-AUG-05 4274575 : Added new column - end

      -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
      CATEGORY_SET_ID,
      -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
      VALIDATION_SET_ID,
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
      -- rmunjulu 4508497
      CANCEL_QUOTES_YN,
      CHK_ACCRUAL_PREVIOUS_MNTH_YN, --rmunjulu 4769094
      -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
      TASK_TEMPLATE_GROUP_ID,
      OWNER_TYPE_CODE,
      OWNER_ID,
      -- gboomina Bug 5128517 - End
      object_version_number,
      org_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      item_inv_org_id,
      rpt_prod_book_type_code,
      asst_add_book_type_code,
      ccard_remittance_id,
   -- DJANASWA Bug 6653304 start
      CORPORATE_BOOK,
      TAX_BOOK_1,
      TAX_BOOK_2,
      DEPRECIATE_YN,
      FA_LOCATION_ID,
      FORMULA_ID,
      ASSET_KEY_ID,
   -- DJANASWA Bug 6653304 end
	    -- Bug 5568328
			PART_TRMNT_APPLY_ROUND_DIFF,
      --Bug 7022258-Added by kkorrapo
       LSEAPP_SEQ_PREFIX_TXT,
       LSEOPP_SEQ_PREFIX_TXT,
       QCKQTE_SEQ_PREFIX_TXT,
       LSEQTE_SEQ_PREFIX_TXT
       --Bug 7022258--Addition end
      )
    VALUES (
      l_syp_rec.id,
      l_syp_rec.delink_yn,
      -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
      l_syp_rec.REMK_SUBINVENTORY ,
	  l_syp_rec.REMK_ORGANIZATION_ID  ,
	  l_syp_rec.REMK_PRICE_LIST_ID ,
	  l_syp_rec.REMK_PROCESS_CODE  ,
	  l_syp_rec.REMK_ITEM_TEMPLATE_ID  ,
	  l_syp_rec.REMK_ITEM_INVOICED_CODE  ,
      -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
      -- PAGARG 24-JAN-05 4044659: Added new columns - begin
	  l_syp_rec.LEASE_INV_ORG_YN,
      -- PAGARG 24-JAN-05 4044659: Added new columns - end

      --SECHAWLA  28-MAR-05 4274575 :Added new columns - begin
      l_syp_rec.TAX_UPFRONT_YN ,
      l_syp_rec.TAX_INVOICE_YN,
      l_syp_rec.TAX_SCHEDULE_YN ,
      --SECHAWLA  28-MAR-05 4274575 :Added new columns - end

      -- SECHAWLA 26-AUG-05 4274575 : Added new column - begin
      l_syp_rec.TAX_UPFRONT_STY_ID,
      -- SECHAWLA 26-AUG-05 4274575 : Added new column - end

      -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
      l_syp_rec.CATEGORY_SET_ID,
      -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
      l_syp_rec.VALIDATION_SET_ID,
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :

      -- rmunjulu 4508497
      l_syp_rec.CANCEL_QUOTES_YN,
      l_syp_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN, --rmunjulu 4769094
      -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
      l_syp_rec.TASK_TEMPLATE_GROUP_ID,
      l_syp_rec.OWNER_TYPE_CODE,
      l_syp_rec.OWNER_ID,
      -- gboomina Bug 5128517 - End
      l_syp_rec.object_version_number,
      l_syp_rec.org_id,
      l_syp_rec.request_id,
      l_syp_rec.program_application_id,
      l_syp_rec.program_id,
      l_syp_rec.program_update_date,
      l_syp_rec.attribute_category,
      l_syp_rec.attribute1,
      l_syp_rec.attribute2,
      l_syp_rec.attribute3,
      l_syp_rec.attribute4,
      l_syp_rec.attribute5,
      l_syp_rec.attribute6,
      l_syp_rec.attribute7,
      l_syp_rec.attribute8,
      l_syp_rec.attribute9,
      l_syp_rec.attribute10,
      l_syp_rec.attribute11,
      l_syp_rec.attribute12,
      l_syp_rec.attribute13,
      l_syp_rec.attribute14,
      l_syp_rec.attribute15,
      l_syp_rec.created_by,
      l_syp_rec.creation_date,
      l_syp_rec.last_updated_by,
      l_syp_rec.last_update_date,
      l_syp_rec.last_update_login,
      --added by akrangan on 28/07/2006 as a result of adding new columns to the table
      l_syp_rec.item_inv_org_id          ,
      l_syp_rec.rpt_prod_book_type_code,
      l_syp_rec.asst_add_book_type_code,
      l_syp_rec.ccard_remittance_id,
      -- DJANASWA Bug 6653304 start
      l_syp_rec.CORPORATE_BOOK,
      l_syp_rec.TAX_BOOK_1,
      l_syp_rec.TAX_BOOK_2,
      l_syp_rec.DEPRECIATE_YN,
      l_syp_rec.FA_LOCATION_ID,
      l_syp_rec.FORMULA_ID,
      l_syp_rec.ASSET_KEY_ID,
     -- DJANASWA Bug 6653304 end
		  -- Bug 5568328
      l_syp_rec.part_trmnt_apply_round_diff,
      --Bug 7022258-Added by kkorrapo
      l_syp_rec.lseapp_seq_prefix_txt,
      l_syp_rec.lseopp_seq_prefix_txt,
      l_syp_rec.qckqte_seq_prefix_txt,
      l_syp_rec.lseqte_seq_prefix_txt
      --Bug 7022258--Addition end
 );
    -- Set OUT values
    x_syp_rec := l_syp_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------------------
  -- insert_row for :OKL_SYSTEM_PARAMS_ALL_V --
  -- RMUNJULU Added code to default delink_yn
  -- RMUNJULU Added code to default org_id
  -- SECHAWLA 28-MAR-05 4274575 : added code to default tax_upfront_yn, tax_INVOICE_yn, tax_schedule_yn
  -------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sypv_rec                     sypv_rec_type := p_sypv_rec;
    lx_sypv_rec                    sypv_rec_type;
    l_syp_rec                      syp_rec_type;
    lx_syp_rec                     syp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sypv_rec IN sypv_rec_type
    ) RETURN sypv_rec_type IS
      l_sypv_rec sypv_rec_type := p_sypv_rec;
    BEGIN
      l_sypv_rec.CREATION_DATE := SYSDATE;
      l_sypv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sypv_rec.LAST_UPDATE_DATE := l_sypv_rec.CREATION_DATE;
      l_sypv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sypv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sypv_rec);
    END fill_who_columns;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_SYSTEM_PARAMS_ALL_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_sypv_rec IN sypv_rec_type,
      x_sypv_rec OUT NOCOPY sypv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sypv_rec := p_sypv_rec;
      x_sypv_rec.OBJECT_VERSION_NUMBER := 1;

      -- RMUNJULU Default delink_yn
      IF x_sypv_rec.delink_yn IS NULL
      OR x_sypv_rec.delink_yn = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.delink_yn := 'N';
      END IF;

      --SECHAWLA  28-MAR-05 4274575 :Default TAX_UPFRONT_YN
      IF x_sypv_rec.TAX_UPFRONT_YN IS NULL
      OR x_sypv_rec.TAX_UPFRONT_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.TAX_UPFRONT_YN := 'N';
      END IF;

      --SECHAWLA  28-MAR-05 4274575 :Default TAX_INVOICE_YN
      IF x_sypv_rec.TAX_INVOICE_YN IS NULL
      OR x_sypv_rec.TAX_INVOICE_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.TAX_INVOICE_YN := 'N';
      END IF;

      --SECHAWLA  28-MAR-05 4274575 :Default TAX_SCHEDULE_YN
      IF x_sypv_rec.TAX_SCHEDULE_YN IS NULL
      OR x_sypv_rec.TAX_SCHEDULE_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.TAX_SCHEDULE_YN := 'N';
      END IF;

      --ASAWANKA  24-MAY-2005  :Default LEASE_INV_ORG_YN
      --this is necessary as LEASE_INV_ORG_YN should have some value before calling validate_lease_inv_org_yn.
      --and if insert api is called from Setup> System Options > Item Category Set page, LEASE_INV_ORG_YN will have value null
      --this will lead to error from validate_lease_inv_org_yn
      IF x_sypv_rec.LEASE_INV_ORG_YN IS NULL
      OR x_sypv_rec.LEASE_INV_ORG_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.LEASE_INV_ORG_YN := 'N';
      END IF;


      -- SECHAWLA 15-SEP-05 4602797 : Default cancel_quotes_yn
      IF x_sypv_rec.cancel_quotes_yn IS NULL
      OR x_sypv_rec.cancel_quotes_yn = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.cancel_quotes_yn := 'N';
      END IF;

      -- rmunjulu 4769094
      IF x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN IS NULL
      OR x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN := 'N';
      END IF;

      -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
      IF (x_sypv_rec.TASK_TEMPLATE_GROUP_ID = OKL_API.G_MISS_NUM)
      THEN
        x_sypv_rec.TASK_TEMPLATE_GROUP_ID := l_syp_rec.TASK_TEMPLATE_GROUP_ID;
      END IF;

      IF (x_sypv_rec.OWNER_TYPE_CODE = OKL_API.G_MISS_CHAR)
      THEN
        x_sypv_rec.OWNER_TYPE_CODE := l_syp_rec.OWNER_TYPE_CODE;
      END IF;

      IF (x_sypv_rec.OWNER_ID = OKL_API.G_MISS_NUM)
      THEN
        x_sypv_rec.OWNER_ID := l_syp_rec.OWNER_ID;
      END IF;
      -- gboomina Bug 5128517 - End

      -- dcshanmu MOAC change starts
      IF (x_sypv_rec.ITEM_INV_ORG_ID = OKL_API.G_MISS_NUM)
      THEN
        x_sypv_rec.ITEM_INV_ORG_ID := l_syp_rec.ITEM_INV_ORG_ID;
      END IF;

      IF (x_sypv_rec.RPT_PROD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR)
      THEN
        x_sypv_rec.RPT_PROD_BOOK_TYPE_CODE := l_syp_rec.RPT_PROD_BOOK_TYPE_CODE;
      END IF;

      IF (x_sypv_rec.ASST_ADD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR)
      THEN
        x_sypv_rec.ASST_ADD_BOOK_TYPE_CODE := l_syp_rec.ASST_ADD_BOOK_TYPE_CODE;
      END IF;

      IF (x_sypv_rec.CCARD_REMITTANCE_ID = OKL_API.G_MISS_NUM)
      THEN
        x_sypv_rec.CCARD_REMITTANCE_ID := l_syp_rec.CCARD_REMITTANCE_ID;
      END IF;
      -- dcshanmu MOAC change end

  -- DJANASWA Bug 6653304 start
    IF (x_sypv_rec.CORPORATE_BOOK = OKL_API.G_MISS_CHAR) THEN
        x_sypv_rec.CORPORATE_BOOK := l_syp_rec.CORPORATE_BOOK;
    END IF;

    IF (x_sypv_rec.TAX_BOOK_1 = OKL_API.G_MISS_CHAR) THEN
        x_sypv_rec.TAX_BOOK_1 := l_syp_rec.TAX_BOOK_1;
    END IF;

    IF (x_sypv_rec.TAX_BOOK_2 = OKL_API.G_MISS_CHAR) THEN
        x_sypv_rec.TAX_BOOK_2 := l_syp_rec.TAX_BOOK_2;
    END IF;

    IF (x_sypv_rec.DEPRECIATE_YN IS NULL OR x_sypv_rec.DEPRECIATE_YN = OKL_API.G_MISS_CHAR) THEN
        x_sypv_rec.DEPRECIATE_YN := 'N';
    END IF;

    IF  (x_sypv_rec.FA_LOCATION_ID  = OKL_API.G_MISS_NUM ) THEN
         x_sypv_rec.FA_LOCATION_ID := l_syp_rec.FA_LOCATION_ID;
    END IF;

    IF  (x_sypv_rec.FORMULA_ID = OKL_API.G_MISS_NUM ) THEN
         x_sypv_rec.FORMULA_ID := l_syp_rec.FORMULA_ID;
    END IF;

    IF (x_sypv_rec.ASSET_KEY_ID = OKL_API.G_MISS_NUM ) THEN
        x_sypv_rec.ASSET_KEY_ID := l_syp_rec.ASSET_KEY_ID;
    END IF;
    -- DJANASWA Bug 6653304 end
		-- Bug 5568328
    IF (x_sypv_rec.part_trmnt_apply_round_diff = okl_api.g_miss_char ) THEN
        x_sypv_rec.part_trmnt_apply_round_diff := l_syp_rec.part_trmnt_apply_round_diff;
    END IF;
      -- RMUNJULU Added code to default org_id
      x_sypv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_sypv_rec := null_out_defaults(p_sypv_rec);
    -- Set primary key value
    l_sypv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_sypv_rec,      -- IN
      lx_sypv_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lx_sypv_rec := fill_who_columns(lx_sypv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(lx_sypv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(lx_sypv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(lx_sypv_rec, l_syp_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_syp_rec,
      lx_syp_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_syp_rec, lx_sypv_rec);
    -- Set OUT values
    x_sypv_rec := lx_sypv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKLSYSTEMPARAMETERSALLVTBL --
  ----------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      i := p_sypv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_sypv_rec                     => p_sypv_tbl(i),
            x_sypv_rec                     => x_sypv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_sypv_tbl.LAST);
        i := p_sypv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ----------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKLSYSTEMPARAMETERSALLVTBL --
  ----------------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sypv_tbl                     => p_sypv_tbl,
        x_sypv_tbl                     => x_sypv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_SYSTEM_PARAMS_ALL --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_syp_rec                      IN syp_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_syp_rec IN syp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SYSTEM_PARAMS_ALL
     WHERE ID = p_syp_rec.id
       AND OBJECT_VERSION_NUMBER = p_syp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_syp_rec IN syp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SYSTEM_PARAMS_ALL
     WHERE ID = p_syp_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_SYSTEM_PARAMS_ALL.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_SYSTEM_PARAMS_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_syp_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_syp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_syp_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_syp_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------------------
  -- lock_row for: OKL_SYSTEM_PARAMS_ALL_V --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_syp_rec                      syp_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_sypv_rec, l_syp_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_syp_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKLSYSTEMPARAMETERSALLVTBL --
  --------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      i := p_sypv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_sypv_rec                     => p_sypv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_sypv_tbl.LAST);
        i := p_sypv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKLSYSTEMPARAMETERSALLVTBL --
  --------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sypv_tbl                     => p_sypv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_SYSTEM_PARAMS_ALL --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_syp_rec                      IN syp_rec_type,
    x_syp_rec                      OUT NOCOPY syp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_syp_rec                      syp_rec_type := p_syp_rec;
    l_def_syp_rec                  syp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_syp_rec IN syp_rec_type,
      x_syp_rec OUT NOCOPY syp_rec_type
    ) RETURN VARCHAR2 IS
      l_syp_rec                      syp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_syp_rec := p_syp_rec;
      -- Get current database values
      l_syp_rec := get_rec(p_syp_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_syp_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.id := l_syp_rec.id;
        END IF;
        IF (x_syp_rec.delink_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.delink_yn := l_syp_rec.delink_yn;
        END IF;

        -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
        IF (x_syp_rec.REMK_SUBINVENTORY = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.REMK_SUBINVENTORY := l_syp_rec.REMK_SUBINVENTORY;
        END IF;
        IF (x_syp_rec.REMK_ORGANIZATION_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.REMK_ORGANIZATION_ID := l_syp_rec.REMK_ORGANIZATION_ID;
        END IF;
        IF (x_syp_rec.REMK_PRICE_LIST_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.REMK_PRICE_LIST_ID := l_syp_rec.REMK_PRICE_LIST_ID;
        END IF;
        IF (x_syp_rec.REMK_PROCESS_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.REMK_PROCESS_CODE := l_syp_rec.REMK_PROCESS_CODE;
        END IF;
        IF (x_syp_rec.REMK_ITEM_TEMPLATE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.REMK_ITEM_TEMPLATE_ID := l_syp_rec.REMK_ITEM_TEMPLATE_ID;
        END IF;
        IF (x_syp_rec.REMK_ITEM_INVOICED_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.REMK_ITEM_INVOICED_CODE := l_syp_rec.REMK_ITEM_INVOICED_CODE;
        END IF;
        -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
        -- PAGARG 24-JAN-05 4044659: Added new columns - begin
        IF (x_syp_rec.LEASE_INV_ORG_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.LEASE_INV_ORG_YN := l_syp_rec.LEASE_INV_ORG_YN;
        END IF;
        -- PAGARG 24-JAN-05 4044659: Added new columns - end

        -- SECHAWLA  28-MAR-05 4274575 : Added new columns - begin
        IF (x_syp_rec.TAX_UPFRONT_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.TAX_UPFRONT_YN := l_syp_rec.TAX_UPFRONT_YN;
        END IF;

        IF (x_syp_rec.TAX_INVOICE_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.TAX_INVOICE_YN := l_syp_rec.TAX_INVOICE_YN;
        END IF;

        IF (x_syp_rec.TAX_SCHEDULE_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.TAX_SCHEDULE_YN := l_syp_rec.TAX_SCHEDULE_YN;
        END IF;
        -- SECHAWLA  28-MAR-05 4274575 : Added new columns - end

        -- SECHAWLA  26-AUG-05 4274575 : Added new columns - begin
        IF (x_syp_rec.TAX_UPFRONT_STY_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.TAX_UPFRONT_STY_ID := l_syp_rec.TAX_UPFRONT_STY_ID;
        END IF;
        -- SECHAWLA  26-AUG-05 4274575 : Added new columns - end


        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
    	IF (x_syp_rec.CATEGORY_SET_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.CATEGORY_SET_ID := l_syp_rec.CATEGORY_SET_ID;
        END IF;
        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end

   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
     	IF (x_syp_rec.VALIDATION_SET_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.VALIDATION_SET_ID := l_syp_rec.VALIDATION_SET_ID;
        END IF;
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :

        -- rmunjulu 4508497
        IF (x_syp_rec.CANCEL_QUOTES_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.CANCEL_QUOTES_YN := l_syp_rec.CANCEL_QUOTES_YN;
        END IF;

        -- rmunjulu 4769094
        IF (x_syp_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN := l_syp_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN;
        END IF;

   	-- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
        IF (x_syp_rec.TASK_TEMPLATE_GROUP_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.TASK_TEMPLATE_GROUP_ID := l_syp_rec.TASK_TEMPLATE_GROUP_ID;
        END IF;

        IF (x_syp_rec.OWNER_TYPE_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.OWNER_TYPE_CODE := l_syp_rec.OWNER_TYPE_CODE;
        END IF;

        IF (x_syp_rec.OWNER_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.OWNER_ID := l_syp_rec.OWNER_ID;
        END IF;
	-- gboomina Bug 5128517 - End

	-- dcshanmu MOAC Change starts
        IF (x_syp_rec.ITEM_INV_ORG_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.ITEM_INV_ORG_ID := l_syp_rec.ITEM_INV_ORG_ID;
        END IF;

        IF (x_syp_rec.RPT_PROD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.RPT_PROD_BOOK_TYPE_CODE := l_syp_rec.RPT_PROD_BOOK_TYPE_CODE;
        END IF;

        IF (x_syp_rec.ASST_ADD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.ASST_ADD_BOOK_TYPE_CODE := l_syp_rec.ASST_ADD_BOOK_TYPE_CODE;
        END IF;

	IF (x_syp_rec.CCARD_REMITTANCE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.CCARD_REMITTANCE_ID := l_syp_rec.CCARD_REMITTANCE_ID;
        END IF;
	-- dcshanmu MOAC Change end

        -- DJANASWA Bug 6653304 start
        IF (x_syp_rec.CORPORATE_BOOK = OKL_API.G_MISS_CHAR) THEN
            x_syp_rec.CORPORATE_BOOK := l_syp_rec.CORPORATE_BOOK;
        END IF;

        IF (x_syp_rec.TAX_BOOK_1 = OKL_API.G_MISS_CHAR) THEN
            x_syp_rec.TAX_BOOK_1 := l_syp_rec.TAX_BOOK_1;
        END IF;

        IF (x_syp_rec.TAX_BOOK_2 = OKL_API.G_MISS_CHAR) THEN
            x_syp_rec.TAX_BOOK_2 := l_syp_rec.TAX_BOOK_2;
        END IF;

        IF (x_syp_rec.DEPRECIATE_YN = OKL_API.G_MISS_CHAR) THEN
            x_syp_rec.DEPRECIATE_YN := l_syp_rec.DEPRECIATE_YN;
        END IF;

        IF  (x_syp_rec.FA_LOCATION_ID  = OKL_API.G_MISS_NUM ) THEN
             x_syp_rec.FA_LOCATION_ID := l_syp_rec.FA_LOCATION_ID;
        END IF;

        IF  (x_syp_rec.FORMULA_ID = OKL_API.G_MISS_NUM ) THEN
             x_syp_rec.FORMULA_ID := l_syp_rec.FORMULA_ID;
        END IF;

        IF (x_syp_rec.ASSET_KEY_ID = OKL_API.G_MISS_NUM ) THEN
            x_syp_rec.ASSET_KEY_ID := l_syp_rec.ASSET_KEY_ID;
        END IF;
    -- djanaswa bug 6653304 end
		    -- Bug 5568328
        IF (x_syp_rec.part_trmnt_apply_round_diff = okl_api.g_miss_char ) then
            x_syp_rec.part_trmnt_apply_round_diff := l_syp_rec.part_trmnt_apply_round_diff;
        END IF;

        IF (x_syp_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.object_version_number := l_syp_rec.object_version_number;
        END IF;
        IF (x_syp_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.org_id := l_syp_rec.org_id;
        END IF;
        IF (x_syp_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.request_id := l_syp_rec.request_id;
        END IF;
        IF (x_syp_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.program_application_id := l_syp_rec.program_application_id;
        END IF;
        IF (x_syp_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.program_id := l_syp_rec.program_id;
        END IF;
        IF (x_syp_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_syp_rec.program_update_date := l_syp_rec.program_update_date;
        END IF;
        IF (x_syp_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute_category := l_syp_rec.attribute_category;
        END IF;
        IF (x_syp_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute1 := l_syp_rec.attribute1;
        END IF;
        IF (x_syp_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute2 := l_syp_rec.attribute2;
        END IF;
        IF (x_syp_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute3 := l_syp_rec.attribute3;
        END IF;
        IF (x_syp_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute4 := l_syp_rec.attribute4;
        END IF;
        IF (x_syp_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute5 := l_syp_rec.attribute5;
        END IF;
        IF (x_syp_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute6 := l_syp_rec.attribute6;
        END IF;
        IF (x_syp_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute7 := l_syp_rec.attribute7;
        END IF;
        IF (x_syp_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute8 := l_syp_rec.attribute8;
        END IF;
        IF (x_syp_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute9 := l_syp_rec.attribute9;
        END IF;
        IF (x_syp_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute10 := l_syp_rec.attribute10;
        END IF;
        IF (x_syp_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute11 := l_syp_rec.attribute11;
        END IF;
        IF (x_syp_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute12 := l_syp_rec.attribute12;
        END IF;
        IF (x_syp_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute13 := l_syp_rec.attribute13;
        END IF;
        IF (x_syp_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute14 := l_syp_rec.attribute14;
        END IF;
        IF (x_syp_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_syp_rec.attribute15 := l_syp_rec.attribute15;
        END IF;
        IF (x_syp_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.created_by := l_syp_rec.created_by;
        END IF;
        IF (x_syp_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_syp_rec.creation_date := l_syp_rec.creation_date;
        END IF;
        IF (x_syp_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.last_updated_by := l_syp_rec.last_updated_by;
        END IF;
        IF (x_syp_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_syp_rec.last_update_date := l_syp_rec.last_update_date;
        END IF;
        IF (x_syp_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_syp_rec.last_update_login := l_syp_rec.last_update_login;
        END IF;
	--Bug 7022258-Added by kkorrapo
	IF (x_syp_rec.lseapp_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_syp_rec.lseapp_seq_prefix_txt := l_syp_rec.lseapp_seq_prefix_txt;
	END IF;
	IF (x_syp_rec.lseopp_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_syp_rec.lseopp_seq_prefix_txt := l_syp_rec.lseopp_seq_prefix_txt;
	END IF;
	IF (x_syp_rec.qckqte_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_syp_rec.qckqte_seq_prefix_txt := l_syp_rec.qckqte_seq_prefix_txt;
	END IF;
	IF (x_syp_rec.lseqte_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_syp_rec.lseqte_seq_prefix_txt := l_syp_rec.lseqte_seq_prefix_txt;
	END IF;
	--Bug 7022258--Addition end
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_SYSTEM_PARAMS_ALL --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_syp_rec IN syp_rec_type,
      x_syp_rec OUT NOCOPY syp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_syp_rec := p_syp_rec;
      x_syp_rec.OBJECT_VERSION_NUMBER := p_syp_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_syp_rec,                         -- IN
      l_syp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_syp_rec, l_def_syp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_SYSTEM_PARAMS_ALL
    SET DELINK_YN = l_def_syp_rec.delink_yn,
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
        REMK_SUBINVENTORY   = l_def_syp_rec.REMK_SUBINVENTORY ,
		REMK_ORGANIZATION_ID = l_def_syp_rec.REMK_ORGANIZATION_ID,
		REMK_PRICE_LIST_ID    = l_def_syp_rec.REMK_PRICE_LIST_ID ,
		REMK_PROCESS_CODE        = l_def_syp_rec.REMK_PROCESS_CODE,
		REMK_ITEM_TEMPLATE_ID    = l_def_syp_rec.REMK_ITEM_TEMPLATE_ID ,
		REMK_ITEM_INVOICED_CODE   = l_def_syp_rec.REMK_ITEM_INVOICED_CODE ,
    -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
        -- PAGARG 24-JAN-05 4044659: Added new columns - begin
		LEASE_INV_ORG_YN = l_def_syp_rec.LEASE_INV_ORG_YN,
        -- PAGARG 24-JAN-05 4044659: Added new columns - end

        --SECHAWLA  28-MAR-05 4274575 Added new columns - begin
        TAX_UPFRONT_YN = l_def_syp_rec.TAX_UPFRONT_YN,
        TAX_INVOICE_YN = l_def_syp_rec.TAX_INVOICE_YN,
        TAX_SCHEDULE_YN = l_def_syp_rec.TAX_SCHEDULE_YN,
        --SECHAWLA  28-MAR-05 4274575 Added new columns - end

        -- SECHAWLA  26-AUG-05 4274575 : Added new columns - begin
        TAX_UPFRONT_STY_ID = l_def_syp_rec.TAX_UPFRONT_STY_ID,
        -- SECHAWLA  26-AUG-05 4274575 : Added new columns - end

        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
        CATEGORY_SET_ID = l_def_syp_rec.CATEGORY_SET_ID,
        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end

        -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
        VALIDATION_SET_ID = l_def_syp_rec.VALIDATION_SET_ID,
        -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :


        -- rmunjulu 4508497
     		CANCEL_QUOTES_YN = l_def_syp_rec.CANCEL_QUOTES_YN,
     		CHK_ACCRUAL_PREVIOUS_MNTH_YN = l_def_syp_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN, --rmunjulu 4769094

        -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
  	TASK_TEMPLATE_GROUP_ID = l_def_syp_rec.TASK_TEMPLATE_GROUP_ID,
  	OWNER_TYPE_CODE = l_def_syp_rec.OWNER_TYPE_CODE,
  	OWNER_ID = l_def_syp_rec.OWNER_ID,
	-- gboomina Bug 5128517 - End

        -- DJANASWA Bug 6653304 start
        CORPORATE_BOOK  = l_def_syp_rec.CORPORATE_BOOK,
        TAX_BOOK_1      = l_def_syp_rec.TAX_BOOK_1,
        TAX_BOOK_2      = l_def_syp_rec.TAX_BOOK_2,
        DEPRECIATE_YN   = l_def_syp_rec.DEPRECIATE_YN,
        FA_LOCATION_ID  = l_def_syp_rec.FA_LOCATION_ID,
        FORMULA_ID      = l_def_syp_rec.FORMULA_ID,
        ASSET_KEY_ID    = l_def_syp_rec.ASSET_KEY_ID,
        -- DJANASWA Bug 6653304 end
        -- Bug 5568328
        part_trmnt_apply_round_diff    = l_def_syp_rec.part_trmnt_apply_round_diff,
        OBJECT_VERSION_NUMBER = l_def_syp_rec.object_version_number,
        ORG_ID = l_def_syp_rec.org_id,
        REQUEST_ID = l_def_syp_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_syp_rec.program_application_id,
        PROGRAM_ID = l_def_syp_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_syp_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_syp_rec.attribute_category,
        ATTRIBUTE1 = l_def_syp_rec.attribute1,
        ATTRIBUTE2 = l_def_syp_rec.attribute2,
        ATTRIBUTE3 = l_def_syp_rec.attribute3,
        ATTRIBUTE4 = l_def_syp_rec.attribute4,
        ATTRIBUTE5 = l_def_syp_rec.attribute5,
        ATTRIBUTE6 = l_def_syp_rec.attribute6,
        ATTRIBUTE7 = l_def_syp_rec.attribute7,
        ATTRIBUTE8 = l_def_syp_rec.attribute8,
        ATTRIBUTE9 = l_def_syp_rec.attribute9,
        ATTRIBUTE10 = l_def_syp_rec.attribute10,
        ATTRIBUTE11 = l_def_syp_rec.attribute11,
        ATTRIBUTE12 = l_def_syp_rec.attribute12,
        ATTRIBUTE13 = l_def_syp_rec.attribute13,
        ATTRIBUTE14 = l_def_syp_rec.attribute14,
        ATTRIBUTE15 = l_def_syp_rec.attribute15,
        CREATED_BY = l_def_syp_rec.created_by,
        CREATION_DATE = l_def_syp_rec.creation_date,
        LAST_UPDATED_BY = l_def_syp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_syp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_syp_rec.last_update_login,
	ITEM_INV_ORG_ID = l_def_syp_rec.item_inv_org_id ,
        RPT_PROD_BOOK_TYPE_CODE	    = l_def_syp_rec.rpt_prod_book_type_code,
        ASST_ADD_BOOK_TYPE_CODE	    = l_def_syp_rec.ASST_ADD_BOOK_TYPE_CODE,
        CCARD_REMITTANCE_ID 	     =   l_def_syp_rec.CCARD_REMITTANCE_ID,
        --Bug 7022258-Added by kkorrapo
	LSEAPP_SEQ_PREFIX_TXT = l_def_syp_rec.lseapp_seq_prefix_txt,
	LSEOPP_SEQ_PREFIX_TXT = l_def_syp_rec.lseopp_seq_prefix_txt,
	QCKQTE_SEQ_PREFIX_TXT = l_def_syp_rec.qckqte_seq_prefix_txt,
	LSEQTE_SEQ_PREFIX_TXT = l_def_syp_rec.lseqte_seq_prefix_txt
        --Bug 7022258--Addition end
    WHERE ID = l_def_syp_rec.id;

    x_syp_rec := l_syp_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------------------
  -- update_row for:OKL_SYSTEM_PARAMS_ALL_V --
  -- RMUNJULU Changed to add code to set object _version_number and pass lx_sypv_rec to lock row
  ------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sypv_rec                     sypv_rec_type := p_sypv_rec;
    lx_sypv_rec                    sypv_rec_type;
    l_db_OklSystemParam2           sypv_rec_type;
    l_syp_rec                      syp_rec_type;
    lx_syp_rec                     syp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sypv_rec IN sypv_rec_type
    ) RETURN sypv_rec_type IS
      l_sypv_rec sypv_rec_type := p_sypv_rec;
    BEGIN
      l_sypv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sypv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sypv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sypv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sypv_rec IN sypv_rec_type,
      x_sypv_rec OUT NOCOPY sypv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sypv_rec := p_sypv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_OklSystemParam2 := get_rec(p_sypv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_sypv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.id := l_db_OklSystemParam2.id;
        END IF;
        -- RMUNJULU Added code to set object version number as locking is not implemented yet
        IF (x_sypv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.object_version_number := l_db_OklSystemParam2.object_version_number;
        END IF;
        IF (x_sypv_rec.delink_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.delink_yn := l_db_OklSystemParam2.delink_yn;
        END IF;

        -- SECHAWLA 28-SEP-04 3924244: Added new columns - begin
        IF (x_sypv_rec.REMK_SUBINVENTORY = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.REMK_SUBINVENTORY := l_db_OklSystemParam2.REMK_SUBINVENTORY;
        END IF;
        IF (x_sypv_rec.REMK_ORGANIZATION_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.REMK_ORGANIZATION_ID := l_db_OklSystemParam2.REMK_ORGANIZATION_ID;
        END IF;
        IF (x_sypv_rec.REMK_PRICE_LIST_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.REMK_PRICE_LIST_ID := l_db_OklSystemParam2.REMK_PRICE_LIST_ID;
        END IF;
        IF (x_sypv_rec.REMK_PROCESS_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.REMK_PROCESS_CODE := l_db_OklSystemParam2.REMK_PROCESS_CODE;
        END IF;
        IF (x_sypv_rec.REMK_ITEM_TEMPLATE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.REMK_ITEM_TEMPLATE_ID := l_db_OklSystemParam2.REMK_ITEM_TEMPLATE_ID;
        END IF;
        IF (x_sypv_rec.REMK_ITEM_INVOICED_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.REMK_ITEM_INVOICED_CODE := l_db_OklSystemParam2.REMK_ITEM_INVOICED_CODE;
        END IF;
        -- SECHAWLA 28-SEP-04 3924244: Added new columns - end
        -- PAGARG 24-JAN-05 4044659: Added new columns - begin
        IF (x_sypv_rec.LEASE_INV_ORG_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.LEASE_INV_ORG_YN := l_db_OklSystemParam2.LEASE_INV_ORG_YN;
        END IF;
        -- PAGARG 24-JAN-05 4044659: Added new columns - end

        --SECHAWLA  28-MAR-05 4274575 Added new columns - begin
        IF (x_sypv_rec.TAX_UPFRONT_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.TAX_UPFRONT_YN := l_db_OklSystemParam2.TAX_UPFRONT_YN;
        END IF;

        IF (x_sypv_rec.TAX_INVOICE_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.TAX_INVOICE_YN := l_db_OklSystemParam2.TAX_INVOICE_YN;
        END IF;

        IF (x_sypv_rec.TAX_SCHEDULE_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.TAX_SCHEDULE_YN := l_db_OklSystemParam2.TAX_SCHEDULE_YN;
        END IF;
        --SECHAWLA  28-MAR-05 4274575 Added new columns - end

        -- SECHAWLA  26-AUG-05 4274575 : Added new columns - begin
        IF (x_sypv_rec.TAX_UPFRONT_STY_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.TAX_UPFRONT_STY_ID := l_db_OklSystemParam2.TAX_UPFRONT_STY_ID;
        END IF;
        -- SECHAWLA  26-AUG-05 4274575 : Added new columns - end


        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
        IF (x_sypv_rec.CATEGORY_SET_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.CATEGORY_SET_ID := l_db_OklSystemParam2.CATEGORY_SET_ID;
        END IF;
        -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
       -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
        IF (x_sypv_rec.VALIDATION_SET_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.VALIDATION_SET_ID := l_db_OklSystemParam2.VALIDATION_SET_ID;
        END IF;
       -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :

        -- rmunjulu 4508497
        IF (x_sypv_rec.CANCEL_QUOTES_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.CANCEL_QUOTES_YN := l_db_OklSystemParam2.CANCEL_QUOTES_YN;
        END IF;

        -- rmunjulu 4769094
        IF (x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN := l_db_OklSystemParam2.CHK_ACCRUAL_PREVIOUS_MNTH_YN;
        END IF;

        -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
        IF (x_sypv_rec.TASK_TEMPLATE_GROUP_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.TASK_TEMPLATE_GROUP_ID := x_sypv_rec.TASK_TEMPLATE_GROUP_ID;
        END IF;

        IF (x_sypv_rec.OWNER_TYPE_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.OWNER_TYPE_CODE := x_sypv_rec.OWNER_TYPE_CODE;
        END IF;

        IF (x_sypv_rec.OWNER_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.OWNER_ID := x_sypv_rec.OWNER_ID;
        END IF;
        -- gboomina Bug 5128517 - End

	-- dcshanmu MOAC Change starts
        IF (x_sypv_rec.ITEM_INV_ORG_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.ITEM_INV_ORG_ID := x_sypv_rec.ITEM_INV_ORG_ID;
        END IF;

        IF (x_sypv_rec.RPT_PROD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.RPT_PROD_BOOK_TYPE_CODE := x_sypv_rec.RPT_PROD_BOOK_TYPE_CODE;
        END IF;

        IF (x_sypv_rec.ASST_ADD_BOOK_TYPE_CODE = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.ASST_ADD_BOOK_TYPE_CODE := x_sypv_rec.ASST_ADD_BOOK_TYPE_CODE;
        END IF;

        IF (x_sypv_rec.CCARD_REMITTANCE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.CCARD_REMITTANCE_ID := x_sypv_rec.CCARD_REMITTANCE_ID;
        END IF;

        -- dcshanmu MOAC Change end

        -- DJANASWA Bug 6653304 start
        IF (x_sypv_rec.CORPORATE_BOOK = OKL_API.G_MISS_CHAR) THEN
            x_sypv_rec.CORPORATE_BOOK := l_db_OklSystemParam2.CORPORATE_BOOK;
        END IF;

        IF (x_sypv_rec.TAX_BOOK_1 = OKL_API.G_MISS_CHAR) THEN
            x_sypv_rec.TAX_BOOK_1 := l_db_OklSystemParam2.TAX_BOOK_1;
        END IF;

        IF (x_sypv_rec.TAX_BOOK_2 = OKL_API.G_MISS_CHAR) THEN
            x_sypv_rec.TAX_BOOK_2 := l_db_OklSystemParam2.TAX_BOOK_2;
        END IF;

        IF (x_sypv_rec.DEPRECIATE_YN = OKL_API.G_MISS_CHAR) THEN
            x_sypv_rec.DEPRECIATE_YN := l_db_OklSystemParam2.DEPRECIATE_YN;
        END IF;

        IF  (x_sypv_rec.FA_LOCATION_ID  = OKL_API.G_MISS_NUM ) THEN
             x_sypv_rec.FA_LOCATION_ID := l_db_OklSystemParam2.FA_LOCATION_ID;
        END IF;

        IF  (x_sypv_rec.FORMULA_ID = OKL_API.G_MISS_NUM ) THEN
             x_sypv_rec.FORMULA_ID := l_db_OklSystemParam2.FORMULA_ID;
        END IF;

        IF (x_sypv_rec.ASSET_KEY_ID = OKL_API.G_MISS_NUM ) THEN
            x_sypv_rec.ASSET_KEY_ID := l_db_OklSystemParam2.ASSET_KEY_ID;
        END IF;
    -- DJANASWA Bug 6653304 end

        -- Bug 5568328
        IF (x_sypv_rec.part_trmnt_apply_round_diff = okl_api.g_miss_char ) THEN
            x_sypv_rec.part_trmnt_apply_round_diff := l_db_oklsystemparam2.part_trmnt_apply_round_diff;
        END IF;

        IF (x_sypv_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.org_id := l_db_OklSystemParam2.org_id;
        END IF;
        IF (x_sypv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.request_id := l_db_OklSystemParam2.request_id;
        END IF;
        IF (x_sypv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.program_application_id := l_db_OklSystemParam2.program_application_id;
        END IF;
        IF (x_sypv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.program_id := l_db_OklSystemParam2.program_id;
        END IF;
        IF (x_sypv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sypv_rec.program_update_date := l_db_OklSystemParam2.program_update_date;
        END IF;
        IF (x_sypv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute_category := l_db_OklSystemParam2.attribute_category;
        END IF;
        IF (x_sypv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute1 := l_db_OklSystemParam2.attribute1;
        END IF;
        IF (x_sypv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute2 := l_db_OklSystemParam2.attribute2;
        END IF;
        IF (x_sypv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute3 := l_db_OklSystemParam2.attribute3;
        END IF;
        IF (x_sypv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute4 := l_db_OklSystemParam2.attribute4;
        END IF;
        IF (x_sypv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute5 := l_db_OklSystemParam2.attribute5;
        END IF;
        IF (x_sypv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute6 := l_db_OklSystemParam2.attribute6;
        END IF;
        IF (x_sypv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute7 := l_db_OklSystemParam2.attribute7;
        END IF;
        IF (x_sypv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute8 := l_db_OklSystemParam2.attribute8;
        END IF;
        IF (x_sypv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute9 := l_db_OklSystemParam2.attribute9;
        END IF;
        IF (x_sypv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute10 := l_db_OklSystemParam2.attribute10;
        END IF;
        IF (x_sypv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute11 := l_db_OklSystemParam2.attribute11;
        END IF;
        IF (x_sypv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute12 := l_db_OklSystemParam2.attribute12;
        END IF;
        IF (x_sypv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute13 := l_db_OklSystemParam2.attribute13;
        END IF;
        IF (x_sypv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute14 := l_db_OklSystemParam2.attribute14;
        END IF;
        IF (x_sypv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_sypv_rec.attribute15 := l_db_OklSystemParam2.attribute15;
        END IF;
        IF (x_sypv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.created_by := l_db_OklSystemParam2.created_by;
        END IF;
        IF (x_sypv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_sypv_rec.creation_date := l_db_OklSystemParam2.creation_date;
        END IF;
        IF (x_sypv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.last_updated_by := l_db_OklSystemParam2.last_updated_by;
        END IF;
        IF (x_sypv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sypv_rec.last_update_date := l_db_OklSystemParam2.last_update_date;
        END IF;
        IF (x_sypv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_sypv_rec.last_update_login := l_db_OklSystemParam2.last_update_login;
        END IF;
        --Bug 7022258-Added by kkorrapo
	IF (x_sypv_rec.lseapp_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_sypv_rec.lseapp_seq_prefix_txt := l_db_OklSystemParam2.lseapp_seq_prefix_txt;
	END IF;
	IF (x_sypv_rec.lseopp_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_sypv_rec.lseopp_seq_prefix_txt := l_db_OklSystemParam2.lseopp_seq_prefix_txt;
	END IF;
	IF (x_sypv_rec.qckqte_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_sypv_rec.qckqte_seq_prefix_txt := l_db_OklSystemParam2.qckqte_seq_prefix_txt;
	END IF;
	IF (x_sypv_rec.lseqte_seq_prefix_txt = OKL_API.G_MISS_CHAR)
	THEN
	  x_sypv_rec.lseqte_seq_prefix_txt := l_db_OklSystemParam2.lseqte_seq_prefix_txt;
	END IF;
        --Bug 7022258--Addition end
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_SYSTEM_PARAMS_ALL_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_sypv_rec IN sypv_rec_type,
      x_sypv_rec OUT NOCOPY sypv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sypv_rec := p_sypv_rec;

      --asawanka added code to default the attributes as part of pricing
      --enhancement. begin +

      -- It is necessary to give default values to following attributes if these
      -- are Null: delink_yn , TAX_UPFRONT_YN, TAX_INVOICE_YN, TAX_SCHEDULE_YN
      -- LEASE_INV_ORG_YN.
      -- If not defaulted, the validate procedures of these attributes will throw
      -- exception, in case if this update_row gets called from a place
      -- ( say Setup > System Options > Item Category Set), before the setup of
      -- above mentioned attributes is done.

      -- Developers adding new columns to okl_system_params_all, should also
      --  default their new columns here with appropriate values, if the validate
      -- procedures for these new columns require the column values be not null.

      --  Default delink_yn
      IF x_sypv_rec.delink_yn IS NULL
      OR x_sypv_rec.delink_yn = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.delink_yn := 'N';
      END IF;

      --  Default TAX_UPFRONT_YN
      IF x_sypv_rec.TAX_UPFRONT_YN IS NULL
      OR x_sypv_rec.TAX_UPFRONT_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.TAX_UPFRONT_YN := 'N';
      END IF;

      -- Default TAX_INVOICE_YN
      IF x_sypv_rec.TAX_INVOICE_YN IS NULL
      OR x_sypv_rec.TAX_INVOICE_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.TAX_INVOICE_YN := 'N';
      END IF;

      -- Default TAX_SCHEDULE_YN
      IF x_sypv_rec.TAX_SCHEDULE_YN IS NULL
      OR x_sypv_rec.TAX_SCHEDULE_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.TAX_SCHEDULE_YN := 'N';
      END IF;

      -- Default LEASE_INV_ORG_YN
      IF x_sypv_rec.LEASE_INV_ORG_YN IS NULL
      OR x_sypv_rec.LEASE_INV_ORG_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.LEASE_INV_ORG_YN := 'N';
      END IF;

      --asawanka added code to default the attributes as part of pricing
      --enhancement. end -

      -- SECHAWLA 15-SEP-05 4602797 : Default cancel_quotes_yn
      IF x_sypv_rec.cancel_quotes_yn IS NULL
      OR x_sypv_rec.cancel_quotes_yn = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.cancel_quotes_yn := 'N';
      END IF;

      -- rmunjulu 4769094 : Default check_accrual_previous_mnth_yn
      IF x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN IS NULL
      OR x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN = OKL_API.G_MISS_CHAR THEN
         x_sypv_rec.CHK_ACCRUAL_PREVIOUS_MNTH_YN := 'N';
      END IF;

      -- djanaswa 6674730 : Default DEPRECIATE_YN
      IF (x_sypv_rec.DEPRECIATE_YN IS NULL
         OR x_sypv_rec.DEPRECIATE_YN = OKL_API.G_MISS_CHAR) THEN
         x_sypv_rec.DEPRECIATE_YN := 'N';
      END IF;

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --asawanka modified as part of pricing enhancement. begin +
    --reversing the order of the calls to set_Attributes and populate_new_records
    --This is required as we should populate the database values to the record
    --before setting the default values(if any) in set_attributes.

    l_return_status := populate_new_record(p_sypv_rec, l_sypv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sypv_rec,      -- IN
      lx_sypv_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --asawanka modified as part of pricing enhancement. end -

    lx_sypv_rec := fill_who_columns(lx_sypv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(lx_sypv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(lx_sypv_rec, l_db_OklSystemParam2);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_sypv_rec                     => lx_sypv_rec); -- RMUNJULU Changed to pass lx_sypv_rec
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(lx_sypv_rec, l_syp_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_syp_rec,
      lx_syp_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_syp_rec, lx_sypv_rec);
    x_sypv_rec := lx_sypv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------------------------
  -- PL/SQL TBL update_row for:OklSystemParametersAllVTbl --
  ----------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      i := p_sypv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_sypv_rec                     => p_sypv_tbl(i),
            x_sypv_rec                     => x_sypv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_sypv_tbl.LAST);
        i := p_sypv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ----------------------------------------------------------
  -- PL/SQL TBL update_row for:OKLSYSTEMPARAMETERSALLVTBL --
  ----------------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sypv_tbl                     => p_sypv_tbl,
        x_sypv_tbl                     => x_sypv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_SYSTEM_PARAMS_ALL --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_syp_rec                      IN syp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_syp_rec                      syp_rec_type := p_syp_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_SYSTEM_PARAMS_ALL
     WHERE ID = p_syp_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------------
  -- delete_row for:OKL_SYSTEM_PARAMS_ALL_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sypv_rec   sypv_rec_type := p_sypv_rec;
    l_syp_rec                      syp_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_sypv_rec, l_syp_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_syp_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SYSTEM_PARAMS_ALL_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      i := p_sypv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_sypv_rec                     => p_sypv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_sypv_tbl.LAST);
        i := p_sypv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SYSTEM_PARAMS_ALL_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sypv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sypv_tbl                     => p_sypv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_SYP_PVT;

/

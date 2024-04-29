--------------------------------------------------------
--  DDL for Package Body OKL_TPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TPL_PVT" AS
/* $Header: OKLSTPLB.pls 120.6 2007/08/08 12:53:58 arajagop ship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages and Variables                 = Done Msg=5; Var=3
  -- BODY:
  -- 0. Check for Not Null Columns                    = Done 3, n/a:sfwt_flag
  -- 1. Check for Not Null Primary Keys               = Done 1
  -- 2. Check for Not Null Foreign Keys               = Done 1
  -- 3. Validity of Foreign Keys                      = Done 6 + 1(notnull) + 2(FND); OKX=2
  -- 4. Validity of Unique Keys                       = N/A, No Unique Keys
  -- 5. Validity of Org_id                            = Done
  -- 6. Added domain validation                       = N/A, No Domain Values Used
  -- 7. Added the Concurrent Manager Columns (p104)   = Done 2=views:v_insert_row,v_update_row
  -- 8. Validate fnd_lookup code using OKL_UTIL pkg   = Done 2 1=not-null, 1=nullable
  -- 9. Capture most severe error in loops (p103)     = Done 5 loops (except l_lang_rec)
  --10. Reduce use of SYSDATE fill_who_columns (p104) = Done 1 (for insert)
  --11. Fix Migrate Parameter p_to IN OUT (p104)      = Done 4
  --12. Call validate procs. in Validate_Attributes   = Done 14
  --13. Validate_Record:Trx-Types, Unique Keys        = Done 2 = trx-types
  --06/01/00: Post postgen changes:
  --14. Removed all references to TRX_TYPE. This column dropped from BD
  --15. Renamed combo_id to code_combination_id
  --16. 07/09/01: Added columns+support for: FUNDING_REFERENCE_NUMBER, FUNDING_REFERENCE_TYPE_CODE (FK)
  --17. 08/21/01: 'validate_fk_ccid' has been commented out because the associated OKX_ views does not exist.
  --18. 11/29/01: Following lookup_type are changed to match with seed data in table fnd_lookups
  --    In validate_disburse_basis_code from okl_ap_disbursement_basis to okl_disbursement_basis
  --    In validate_inv_distr_line_code from okl_ap_invoice_distribution to okl_ap_distr_line_type
  --19. 2/12/02 Added columns funding_reference_type_code, funding_reference_type_code,code_combination_id
  --    Added Globle veriables  for 5 Execeptions
  --    Commented column trx_type
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id - PostGen-1
  ---------------------------------------------------------------------------
  PROCEDURE validate_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.id IS NULL) OR (p_tplv_rec.id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_taxable_yn - PostGen-6
  ---------------------------------------------------------------------------
  PROCEDURE validate_taxable_yn
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tplv_rec.taxable_yn IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_DOMAIN_YN(p_tplv_rec.taxable_yn);
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'taxable_yn'
               ) ;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;
    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;
      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error
  END validate_taxable_yn;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.object_version_number IS NULL)
       OR (p_tplv_rec.object_version_number = OKL_Api.G_MISS_NUM) THEN

          OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'object_version_number'
                ) ;

          x_return_status := OKL_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id - PostGen-5
  ---------------------------------------------------------------------------
  PROCEDURE validate_org_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.org_id IS NULL) OR (p_tplv_rec.org_id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'org_id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSE

      x_return_status := OKL_UTIL.CHECK_ORG_ID(p_tplv_rec.org_id);

      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'org_id'
               ) ;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_line_number - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_line_number
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.line_number IS NULL)
       OR (p_tplv_rec.line_number = OKL_Api.G_MISS_NUM) THEN

          OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'line_number'
                ) ;

          x_return_status := OKL_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_line_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_inv_distr_line_code - PostGen-8
  ---------------------------------------------------------------------------
  PROCEDURE validate_inv_distr_line_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
/*
    IF(p_tplv_rec.inv_distr_line_code IS NULL) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'inv_distr_line_code'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                       ( 'OKL_AP_DISTR_LINE_TYPE'
                       , p_tplv_rec.inv_distr_line_code
                       );
*/
    IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_invalid_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'inv_distr_line_code'
             ) ;

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_inv_distr_line_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_disburse_basis_code - PostGen-8
  ---------------------------------------------------------------------------
  PROCEDURE validate_disburse_basis_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.disbursement_basis_code IS NOT NULL) THEN

      x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                         ( 'OKL_DISBURSEMENT_BASIS'
                         , p_tplv_rec.disbursement_basis_code
                         );

      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'disbursement_basis_code'
               ) ;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_disburse_basis_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fund_ref_type_code - Post PostGen-16
  ---------------------------------------------------------------------------
  PROCEDURE validate_fund_ref_type_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.funding_reference_type_code IS NOT NULL) THEN

      x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                         ( 'OKL_FUNDING_REFERENCE_TYPE'
                         , p_tplv_rec.funding_reference_type_code
                         );

      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN

         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'FUNDING_REFERENCE_TYPE_CODE'
               ) ;

         RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

  END validate_fund_ref_type_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_ccid - PostGen-3
  ---------------------------------------------------------------------------

  PROCEDURE validate_fk_ccid
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

/****************** OKX View Not Available  *****************

    CURSOR l_cciv_csr IS
      SELECT 'x'
      FROM OKX_CODE_COMBINATIONS_V
      WHERE id = p_tplv_rec.code_combination_id;

***************** OKX View Not Available  ******************/

  BEGIN

       null;

/* **************** OKX View Not Available  ****************

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.code_combination_id IS NOT NULL) THEN

      IF(p_tplv_rec.code_combination_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'code_combination_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_cciv_csr;
    fetch l_cciv_csr into l_dummy_var;
    close l_cciv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'code_combination_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKX_CODE_COMBINATIONS_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_cciv_csr%ISOPEN THEN
         CLOSE l_cciv_csr;
      END IF;

***************** OKX View Not Available  ******************/

  END validate_fk_ccid;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_itc_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_itc_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_itcv_csr IS
      SELECT 'x'
      FROM OKX_TAX_CODES_V
      WHERE id1 = p_tplv_rec.itc_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.itc_id IS NOT NULL) THEN

      IF(p_tplv_rec.itc_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'itc_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_itcv_csr;
    fetch l_itcv_csr into l_dummy_var;
    close l_itcv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'itc_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKX_TAX_CODES_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_itcv_csr%ISOPEN THEN
         CLOSE l_itcv_csr;
      END IF;


  END validate_fk_itc_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_kle_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_kle_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_klev_csr IS
      SELECT 'x'
      FROM OKL_K_LINES_V
      WHERE id = p_tplv_rec.kle_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.kle_id IS NOT NULL) THEN

      IF(p_tplv_rec.kle_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'kle_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_klev_csr;
    fetch l_klev_csr into l_dummy_var;
    close l_klev_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'kle_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_K_LINES_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_klev_csr%ISOPEN THEN
         CLOSE l_klev_csr;
      END IF;


  END validate_fk_kle_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_lsm_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_lsm_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_lsmv_csr IS
      SELECT 'x'
      FROM OKL_CNSLD_AR_STRMS_V
      WHERE id = p_tplv_rec.lsm_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.lsm_id IS NOT NULL) THEN

      IF(p_tplv_rec.lsm_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'lsm_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_lsmv_csr;
    fetch l_lsmv_csr into l_dummy_var;
    close l_lsmv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'lsm_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_CNSLD_AR_STRMS_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_lsmv_csr%ISOPEN THEN
         CLOSE l_lsmv_csr;
      END IF;


  END validate_fk_lsm_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_sty_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_sty_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_styv_csr IS
      SELECT 'x'
      FROM OKL_STRM_TYPE_V
      WHERE id = p_tplv_rec.sty_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.sty_id IS NOT NULL) THEN

      IF(p_tplv_rec.sty_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'sty_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_styv_csr;
    fetch l_styv_csr into l_dummy_var;
    close l_styv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'sty_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_STRM_TYPE_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_styv_csr%ISOPEN THEN
         CLOSE l_styv_csr;
      END IF;


  END validate_fk_sty_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_tpl_id_reverses - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_tpl_id_reverses
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_tplv_csr IS
      SELECT 'x'
      FROM OKL_TXL_AP_INV_LNS_V
      WHERE id = p_tplv_rec.tpl_id_reverses;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.tpl_id_reverses IS NOT NULL) THEN

      IF(p_tplv_rec.tpl_id_reverses = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'tpl_id_reverses'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_tplv_csr;
    fetch l_tplv_csr into l_dummy_var;
    close l_tplv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'tpl_id_reverses',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_TXL_AP_INV_LNS_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_tplv_csr%ISOPEN THEN
         CLOSE l_tplv_csr;
      END IF;


  END validate_fk_tpl_id_reverses;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_tap_id - PostGen-2 PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_tap_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tplv_rec               IN        tplv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_tapv_csr IS
      SELECT 'x'
      FROM OKL_TRX_AP_INVOICES_B
      WHERE id = p_tplv_rec.tap_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_tplv_rec.tap_id IS NULL)
      OR (p_tplv_rec.tap_id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'tap_id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    open  l_tapv_csr;
    fetch l_tapv_csr into l_dummy_var;
    close l_tapv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'tap_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_TXL_AP_INV_LNS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_TRX_AP_INVOICES_V');

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      -- verfiy that cursor was closed
      IF l_tapv_csr%ISOPEN THEN
         CLOSE l_tapv_csr;
      END IF;


  END validate_fk_tap_id;
--start:|           14-May-07 cklee -- added TLD_ID column                           |
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_tld_id - PostGen-2 PostGen-3
  ---------------------------------------------------------------------------
    PROCEDURE validate_fk_tld_id(p_tplv_rec IN tplv_rec_type,
                              x_return_status OUT  NOCOPY VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      CURSOR tld_csr (p_tld_id NUMBER)
      IS
      SELECT ID
      FROM OKL_TXD_AR_LN_DTLS_B
      WHERE id = p_tld_id;

      l_tld_id NUMBER := NULL;

      BEGIN

        x_return_status := Okc_Api.G_RET_STS_SUCCESS;

        IF (p_tplv_rec.tld_id IS NOT NULL)      THEN

            OPEN tld_csr(p_tplv_rec.tld_id);
            FETCH tld_csr INTO l_tld_id;
            CLOSE tld_csr;

            IF (l_tld_id IS NULL) THEN

                   Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                                      ,p_msg_name       => g_invalid_value
                                      ,p_token1         => g_col_name_token
                                      ,p_token1_value   => 'tld_id');
                   x_return_status    := Okc_Api.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        END IF;

      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary; validation can continue
        -- with the next column
        NULL;

            WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_unexpected_error,
                                  p_token1       => g_sqlcode_token,
                                  p_token1_value => SQLCODE,
                                  p_token2       => g_sqlerrm_token,
                                  p_token2_value => SQLERRM);

          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END validate_fk_tld_id;
--end:|           14-May-07 cklee -- added TLD_ID column                           |

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_sel_id - PostGen-2 PostGen-3
  ---------------------------------------------------------------------------
    PROCEDURE validate_fk_sel_id(p_tplv_rec IN tplv_rec_type,
                              x_return_status OUT  NOCOPY VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      CURSOR sel_csr (p_sel_id NUMBER)
      IS
      SELECT ID
      FROM okl_strm_elements
      WHERE id = p_sel_id;

      l_sel_id NUMBER := NULL;

      BEGIN

        x_return_status := Okc_Api.G_RET_STS_SUCCESS;

        IF (p_tplv_rec.sel_id IS NOT NULL)      THEN

            OPEN sel_csr(p_tplv_rec.sel_id);
            FETCH sel_csr INTO l_sel_id;
            CLOSE sel_csr;

            IF (l_sel_id IS NULL) THEN

                   Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                                      ,p_msg_name       => g_invalid_value
                                      ,p_token1         => g_col_name_token
                                      ,p_token1_value   => 'sel_id');
                   x_return_status    := Okc_Api.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        END IF;

      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary; validation can continue
        -- with the next column
        NULL;

            WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_unexpected_error,
                                  p_token1       => g_sqlcode_token,
                                  p_token1_value => SQLCODE,
                                  p_token2       => g_sqlerrm_token,
                                  p_token2_value => SQLERRM);

          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END validate_fk_sel_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(OKC_p_util.raw_to_number(sys_guid()));
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_TXL_AP_INV_LNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_AP_INV_LNS_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_TXL_AP_INV_LNS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXL_AP_INV_LNS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_AP_INV_LNS_TL SUBB, OKL_TXL_AP_INV_LNS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXL_AP_INV_LNS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TXL_AP_INV_LNS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXL_AP_INV_LNS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_AP_INV_LNS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tpl_rec                      IN tpl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tpl_rec_type IS
    CURSOR tpl_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            INV_DISTR_LINE_CODE,
            TAP_ID,
            DISBURSEMENT_BASIS_CODE,
            TPL_ID_REVERSES,
            code_combination_id,
            LSM_ID,
            KLE_ID,
            ITC_ID,
            STY_ID,
            LINE_NUMBER,
            OBJECT_VERSION_NUMBER,
            DATE_ACCOUNTING,
            AMOUNT,
            FUNDING_REFERENCE_NUMBER,
            FUNDING_REFERENCE_TYPE_CODE,
            PAYABLES_INVOICE_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            error_message,
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
--start:|           14-May-07 cklee -- added TLD_ID column                           |
            TLD_ID,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
            SEL_ID
      FROM Okl_Txl_Ap_Inv_Lns_B
     WHERE okl_txl_ap_inv_lns_b.id = p_id;
    l_tpl_pk                       tpl_pk_csr%ROWTYPE;
    l_tpl_rec                      tpl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tpl_pk_csr (p_tpl_rec.id);
    FETCH tpl_pk_csr INTO
              l_tpl_rec.ID,
              l_tpl_rec.INV_DISTR_LINE_CODE,
              l_tpl_rec.TAP_ID,
              l_tpl_rec.DISBURSEMENT_BASIS_CODE,
              l_tpl_rec.TPL_ID_REVERSES,
              l_tpl_rec.code_combination_id,
              l_tpl_rec.LSM_ID,
              l_tpl_rec.KLE_ID,
              l_tpl_rec.ITC_ID,
              l_tpl_rec.STY_ID,
              l_tpl_rec.LINE_NUMBER,
              l_tpl_rec.OBJECT_VERSION_NUMBER,
              l_tpl_rec.DATE_ACCOUNTING,
              l_tpl_rec.AMOUNT,
              l_tpl_rec.FUNDING_REFERENCE_NUMBER,
              l_tpl_rec.FUNDING_REFERENCE_TYPE_CODE,
              l_tpl_rec.PAYABLES_INVOICE_ID,
              l_tpl_rec.REQUEST_ID,
              l_tpl_rec.PROGRAM_APPLICATION_ID,
              l_tpl_rec.PROGRAM_ID,
              l_tpl_rec.PROGRAM_UPDATE_DATE,
              l_tpl_rec.ORG_ID,
              l_tpl_rec.error_message,
              l_tpl_rec.ATTRIBUTE_CATEGORY,
              l_tpl_rec.ATTRIBUTE1,
              l_tpl_rec.ATTRIBUTE2,
              l_tpl_rec.ATTRIBUTE3,
              l_tpl_rec.ATTRIBUTE4,
              l_tpl_rec.ATTRIBUTE5,
              l_tpl_rec.ATTRIBUTE6,
              l_tpl_rec.ATTRIBUTE7,
              l_tpl_rec.ATTRIBUTE8,
              l_tpl_rec.ATTRIBUTE9,
              l_tpl_rec.ATTRIBUTE10,
              l_tpl_rec.ATTRIBUTE11,
              l_tpl_rec.ATTRIBUTE12,
              l_tpl_rec.ATTRIBUTE13,
              l_tpl_rec.ATTRIBUTE14,
              l_tpl_rec.ATTRIBUTE15,
              l_tpl_rec.CREATED_BY,
              l_tpl_rec.CREATION_DATE,
              l_tpl_rec.LAST_UPDATED_BY,
              l_tpl_rec.LAST_UPDATE_DATE,
              l_tpl_rec.LAST_UPDATE_LOGIN,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
              l_tpl_rec.TLD_ID,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
              l_tpl_rec.SEL_ID;
    x_no_data_found := tpl_pk_csr%NOTFOUND;
    CLOSE tpl_pk_csr;
    RETURN(l_tpl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tpl_rec                      IN tpl_rec_type
  ) RETURN tpl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tpl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_AP_INV_LNS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txl_ap_inv_lns_tl_rec    IN okl_txl_ap_inv_lns_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txl_ap_inv_lns_tl_rec_type IS
    CURSOR okl_txl_ap_inv_lns_tl_pk_csr (p_id                 IN NUMBER,
                                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Txl_Ap_Inv_Lns_Tl
     WHERE okl_txl_ap_inv_lns_tl.id = p_id
       AND okl_txl_ap_inv_lns_tl.language = p_language;
    l_okl_txl_ap_inv_lns_tl_pk     okl_txl_ap_inv_lns_tl_pk_csr%ROWTYPE;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_ap_inv_lns_tl_pk_csr (p_okl_txl_ap_inv_lns_tl_rec.id,
                                       p_okl_txl_ap_inv_lns_tl_rec.language);
    FETCH okl_txl_ap_inv_lns_tl_pk_csr INTO
              l_okl_txl_ap_inv_lns_tl_rec.ID,
              l_okl_txl_ap_inv_lns_tl_rec.LANGUAGE,
              l_okl_txl_ap_inv_lns_tl_rec.SOURCE_LANG,
              l_okl_txl_ap_inv_lns_tl_rec.SFWT_FLAG,
              l_okl_txl_ap_inv_lns_tl_rec.DESCRIPTION,
              l_okl_txl_ap_inv_lns_tl_rec.CREATED_BY,
              l_okl_txl_ap_inv_lns_tl_rec.CREATION_DATE,
              l_okl_txl_ap_inv_lns_tl_rec.LAST_UPDATED_BY,
              l_okl_txl_ap_inv_lns_tl_rec.LAST_UPDATE_DATE,
              l_okl_txl_ap_inv_lns_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txl_ap_inv_lns_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_ap_inv_lns_tl_pk_csr;
    RETURN(l_okl_txl_ap_inv_lns_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txl_ap_inv_lns_tl_rec    IN okl_txl_ap_inv_lns_tl_rec_type
  ) RETURN okl_txl_ap_inv_lns_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txl_ap_inv_lns_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_AP_INV_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tplv_rec                     IN tplv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tplv_rec_type IS
    CURSOR okl_tplv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            code_combination_id,
            ITC_ID,
            DISBURSEMENT_BASIS_CODE,
            KLE_ID,
            LSM_ID,
            TPL_ID_REVERSES,
            INV_DISTR_LINE_CODE,
            STY_ID,
            TAP_ID,
            DATE_ACCOUNTING,
            AMOUNT,
            FUNDING_REFERENCE_NUMBER,
            FUNDING_REFERENCE_TYPE_CODE,
            LINE_NUMBER,
            PAYABLES_INVOICE_ID,
            DESCRIPTION,
            error_message,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
            TLD_ID,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
            SEL_ID
      FROM Okl_Txl_Ap_Inv_Lns_V
     WHERE okl_txl_ap_inv_lns_v.id = p_id;
    l_okl_tplv_pk                  okl_tplv_pk_csr%ROWTYPE;
    l_tplv_rec                     tplv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tplv_pk_csr (p_tplv_rec.id);
    FETCH okl_tplv_pk_csr INTO
              l_tplv_rec.ID,
              l_tplv_rec.OBJECT_VERSION_NUMBER,
              l_tplv_rec.SFWT_FLAG,
              l_tplv_rec.code_combination_id,
              l_tplv_rec.ITC_ID,
              l_tplv_rec.DISBURSEMENT_BASIS_CODE,
              l_tplv_rec.KLE_ID,
              l_tplv_rec.LSM_ID,
              l_tplv_rec.TPL_ID_REVERSES,
              l_tplv_rec.INV_DISTR_LINE_CODE,
              l_tplv_rec.STY_ID,
              l_tplv_rec.TAP_ID,
              l_tplv_rec.DATE_ACCOUNTING,
              l_tplv_rec.AMOUNT,
              l_tplv_rec.FUNDING_REFERENCE_NUMBER,
              l_tplv_rec.FUNDING_REFERENCE_TYPE_CODE,
              l_tplv_rec.LINE_NUMBER,
              l_tplv_rec.PAYABLES_INVOICE_ID,
              l_tplv_rec.DESCRIPTION,
              l_tplv_rec.error_message,
              l_tplv_rec.ATTRIBUTE_CATEGORY,
              l_tplv_rec.ATTRIBUTE1,
              l_tplv_rec.ATTRIBUTE2,
              l_tplv_rec.ATTRIBUTE3,
              l_tplv_rec.ATTRIBUTE4,
              l_tplv_rec.ATTRIBUTE5,
              l_tplv_rec.ATTRIBUTE6,
              l_tplv_rec.ATTRIBUTE7,
              l_tplv_rec.ATTRIBUTE8,
              l_tplv_rec.ATTRIBUTE9,
              l_tplv_rec.ATTRIBUTE10,
              l_tplv_rec.ATTRIBUTE11,
              l_tplv_rec.ATTRIBUTE12,
              l_tplv_rec.ATTRIBUTE13,
              l_tplv_rec.ATTRIBUTE14,
              l_tplv_rec.ATTRIBUTE15,
              l_tplv_rec.REQUEST_ID,
              l_tplv_rec.PROGRAM_APPLICATION_ID,
              l_tplv_rec.PROGRAM_ID,
              l_tplv_rec.PROGRAM_UPDATE_DATE,
              l_tplv_rec.ORG_ID,
              l_tplv_rec.CREATED_BY,
              l_tplv_rec.CREATION_DATE,
              l_tplv_rec.LAST_UPDATED_BY,
              l_tplv_rec.LAST_UPDATE_DATE,
              l_tplv_rec.LAST_UPDATE_LOGIN,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
              l_tplv_rec.TLD_ID,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
              l_tplv_rec.SEL_ID;
    x_no_data_found := okl_tplv_pk_csr%NOTFOUND;
    CLOSE okl_tplv_pk_csr;
    RETURN(l_tplv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tplv_rec                     IN tplv_rec_type
  ) RETURN tplv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tplv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_AP_INV_LNS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tplv_rec	IN tplv_rec_type
  ) RETURN tplv_rec_type IS
    l_tplv_rec	tplv_rec_type := p_tplv_rec;
  BEGIN
    IF (l_tplv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.object_version_number := NULL;
    END IF;
    IF (l_tplv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_tplv_rec.code_combination_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.code_combination_id := NULL;
    END IF;
    IF (l_tplv_rec.itc_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.itc_id := NULL;
    END IF;
    IF (l_tplv_rec.disbursement_basis_code = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.disbursement_basis_code := NULL;
    END IF;
    IF (l_tplv_rec.kle_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.kle_id := NULL;
    END IF;
    IF (l_tplv_rec.khr_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.khr_id := NULL;
    END IF;
    IF (l_tplv_rec.cnsld_ap_inv_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.cnsld_ap_inv_id := NULL;
    END IF;
    IF (l_tplv_rec.taxable_yn = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.taxable_yn := NULL;
    END IF;
    IF (l_tplv_rec.lsm_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.lsm_id := NULL;
    END IF;
    IF (l_tplv_rec.tpl_id_reverses = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.tpl_id_reverses := NULL;
    END IF;
    IF (l_tplv_rec.inv_distr_line_code = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.inv_distr_line_code := NULL;
    END IF;
    IF (l_tplv_rec.sty_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.sty_id := NULL;
    END IF;
    IF (l_tplv_rec.tap_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.tap_id := NULL;
    END IF;
    IF (l_tplv_rec.date_accounting = OKL_API.G_MISS_DATE) THEN
      l_tplv_rec.date_accounting := NULL;
    END IF;
    IF (l_tplv_rec.amount = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.amount := NULL;
    END IF;
    IF (l_tplv_rec.funding_reference_number = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.funding_reference_number := NULL;
    END IF;
    IF (l_tplv_rec.funding_reference_type_code = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.funding_reference_type_code := NULL;
    END IF;
    IF (l_tplv_rec.line_number = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.line_number := NULL;
    END IF;
    IF (l_tplv_rec.ref_line_number = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.ref_line_number := NULL;
    END IF;
    IF (l_tplv_rec.cnsld_line_number = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.cnsld_line_number := NULL;
    END IF;
    IF (l_tplv_rec.payables_invoice_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.payables_invoice_id := NULL;
    END IF;
    IF (l_tplv_rec.description = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.description := NULL;
    END IF;
    IF (l_tplv_rec.error_message = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.error_message := NULL;
    END IF;
    IF (l_tplv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute_category := NULL;
    END IF;
    IF (l_tplv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute1 := NULL;
    END IF;
    IF (l_tplv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute2 := NULL;
    END IF;
    IF (l_tplv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute3 := NULL;
    END IF;
    IF (l_tplv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute4 := NULL;
    END IF;
    IF (l_tplv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute5 := NULL;
    END IF;
    IF (l_tplv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute6 := NULL;
    END IF;
    IF (l_tplv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute7 := NULL;
    END IF;
    IF (l_tplv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute8 := NULL;
    END IF;
    IF (l_tplv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute9 := NULL;
    END IF;
    IF (l_tplv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute10 := NULL;
    END IF;
    IF (l_tplv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute11 := NULL;
    END IF;
    IF (l_tplv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute12 := NULL;
    END IF;
    IF (l_tplv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute13 := NULL;
    END IF;
    IF (l_tplv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute14 := NULL;
    END IF;
    IF (l_tplv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_tplv_rec.attribute15 := NULL;
    END IF;
    IF (l_tplv_rec.request_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.request_id := NULL;
    END IF;
    IF (l_tplv_rec.program_application_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.program_application_id := NULL;
    END IF;
    IF (l_tplv_rec.program_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.program_id := NULL;
    END IF;
    IF (l_tplv_rec.program_update_date = OKL_API.G_MISS_DATE) THEN
      l_tplv_rec.program_update_date := NULL;
    END IF;
    IF (l_tplv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.org_id := NULL;
    END IF;
    IF (l_tplv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.created_by := NULL;
    END IF;
    IF (l_tplv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_tplv_rec.creation_date := NULL;
    END IF;
    IF (l_tplv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tplv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_tplv_rec.last_update_date := NULL;
    END IF;
    IF (l_tplv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.last_update_login := NULL;
    END IF;

--start:|           14-May-07 cklee -- added TLD_ID column                           |
    IF (l_tplv_rec.tld_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.tld_id := NULL;
    END IF;
--end:|           14-May-07 cklee -- added TLD_ID column                           |

    IF (l_tplv_rec.sel_id = OKL_API.G_MISS_NUM) THEN
      l_tplv_rec.sel_id := NULL;
    END IF;

    RETURN(l_tplv_rec);
  END null_out_defaults;

  -----------------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes for:OKL_TXL_AP_INV_LNS_V : Modified for PostGen-12
  -----------------------------------------------------------------------------------
  FUNCTION Validate_Attributes
         ( p_tplv_rec IN  tplv_rec_type
         ) RETURN VARCHAR2 IS

    x_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
    l_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    validate_id ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_org_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_line_number
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_inv_distr_line_code
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_disburse_basis_code
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fund_ref_type_code
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_ccid
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_itc_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_kle_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
/* 01-jun-2007 ansethur Commented for R12B Billing Architecture - Passthrough impacts
  Usage of lsm_id is being replaced by tld_id
    validate_fk_lsm_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;

    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
*/

    validate_fk_sty_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_tpl_id_reverses
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_tap_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

--start:|           14-May-07 cklee -- added TLD_ID column                           |
    validate_fk_tld_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
--end:|           14-May-07 cklee -- added TLD_ID column                           |


    validate_fk_sel_id
                ( x_return_status      => l_return_status
                , p_tplv_rec           => p_tplv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    RETURN x_return_status;  -- Return status to the caller

  /*------------------------------- TAPI Generated Code ---------------------------------------+
    IF p_tplv_rec.id = OKL_API.G_MISS_NUM OR
       p_tplv_rec.id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tplv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_tplv_rec.object_version_number IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tplv_rec.inv_distr_line_code = OKL_API.G_MISS_CHAR OR
          p_tplv_rec.inv_distr_line_code IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'inv_distr_line_code');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tplv_rec.tap_id = OKL_API.G_MISS_NUM OR
          p_tplv_rec.tap_id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tap_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tplv_rec.line_number = OKL_API.G_MISS_NUM OR
          p_tplv_rec.line_number IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tplv_rec.trx_type = OKL_API.G_MISS_CHAR OR
          p_tplv_rec.trx_type IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'trx_type');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  +------------------------------ TAPI Generated Code ----------------------------------------*/

  EXCEPTION

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      return x_return_status;                            -- Return status to the caller

  END Validate_Attributes;

  -------------------------------------------------------------------------------
  -- PROCEDURE Validate_Record for:OKL_TXL_AP_INV_LNS_V : Modified for PostGen-13
  -------------------------------------------------------------------------------
  FUNCTION Validate_Record
         ( p_tplv_rec IN tplv_rec_type
         ) RETURN VARCHAR2 IS

    x_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
    l_return_status          VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    RETURN x_return_status;  -- Return status to the caller

  EXCEPTION

    WHEN OTHERS then
      -- Store SQL Error Message on the Message Stack for caller
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => 'sqlcode',
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => 'sqlerrm'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;  -- Notify caller of this error

      return x_return_status;                            -- Return status to the caller

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tplv_rec_type,
    p_to	IN OUT NOCOPY tpl_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.inv_distr_line_code := p_from.inv_distr_line_code;
    p_to.tap_id := p_from.tap_id;
    p_to.disbursement_basis_code := p_from.disbursement_basis_code;
    p_to.tpl_id_reverses := p_from.tpl_id_reverses;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.lsm_id := p_from.lsm_id;
    p_to.kle_id := p_from.kle_id;
    p_to.khr_id := p_from.khr_id;
    p_to.cnsld_ap_inv_id := p_from.cnsld_ap_inv_id;
    p_to.taxable_yn := p_from.taxable_yn;
    p_to.itc_id := p_from.itc_id;
    p_to.sty_id := p_from.sty_id;
    p_to.line_number := p_from.line_number;
    p_to.ref_line_number := p_from.ref_line_number;
    p_to.cnsld_line_number := p_from.cnsld_line_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_accounting := p_from.date_accounting;
    p_to.amount := p_from.amount;
    p_to.funding_reference_number := p_from.funding_reference_number;
    p_to.funding_reference_type_code := p_from.funding_reference_type_code;
    p_to.payables_invoice_id := p_from.payables_invoice_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.error_message := p_from.error_message;
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
--start:|           14-May-07 cklee -- added TLD_ID column                           |
    p_to.tld_id := p_from.tld_id;
--end:|           14-May-07 cklee -- added TLD_ID column                           |
    p_to.sel_id := p_from.sel_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tpl_rec_type,
    p_to	IN OUT NOCOPY tplv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.inv_distr_line_code := p_from.inv_distr_line_code;
    p_to.tap_id := p_from.tap_id;
    p_to.disbursement_basis_code := p_from.disbursement_basis_code;
    p_to.tpl_id_reverses := p_from.tpl_id_reverses;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.lsm_id := p_from.lsm_id;
    p_to.kle_id := p_from.kle_id;
    p_to.khr_id := p_from.khr_id;
    p_to.cnsld_ap_inv_id := p_from.cnsld_ap_inv_id;
    p_to.taxable_yn := p_from.taxable_yn;
    p_to.itc_id := p_from.itc_id;
    p_to.sty_id := p_from.sty_id;
    p_to.line_number := p_from.line_number;
    p_to.ref_line_number := p_from.ref_line_number;
    p_to.cnsld_line_number := p_from.cnsld_line_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_accounting := p_from.date_accounting;
    p_to.amount := p_from.amount;
    p_to.funding_reference_number := p_from.funding_reference_number;
    p_to.funding_reference_type_code := p_from.funding_reference_type_code;
    p_to.payables_invoice_id := p_from.payables_invoice_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.error_message := p_from.error_message;
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
--start:|           14-May-07 cklee -- added TLD_ID column                           |
    p_to.tld_id := p_from.tld_id;
--end:|           14-May-07 cklee -- added TLD_ID column                           |
    p_to.sel_id := p_from.sel_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tplv_rec_type,
    p_to	IN OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_txl_ap_inv_lns_tl_rec_type,
    p_to	IN OUT NOCOPY tplv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKL_TXL_AP_INV_LNS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tplv_rec                     tplv_rec_type := p_tplv_rec;
    l_tpl_rec                      tpl_rec_type;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_tplv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tplv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:TPLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tplv_rec                     => p_tplv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_tplv_tbl.LAST);
        i := p_tplv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- insert_row for:OKL_TXL_AP_INV_LNS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tpl_rec                      IN tpl_rec_type,
    x_tpl_rec                      OUT NOCOPY tpl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tpl_rec                      tpl_rec_type := p_tpl_rec;
    l_def_tpl_rec                  tpl_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tpl_rec IN  tpl_rec_type,
      x_tpl_rec OUT NOCOPY tpl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tpl_rec := p_tpl_rec;
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
      p_tpl_rec,                         -- IN
      l_tpl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_AP_INV_LNS_B(
        id,
        inv_distr_line_code,
        tap_id,
        disbursement_basis_code,
        tpl_id_reverses,
        code_combination_id,
        lsm_id,
        kle_id,
        khr_id,
        cnsld_ap_inv_id,
        taxable_yn,
        itc_id,
        sty_id,
        line_number,
        ref_line_number,
        cnsld_line_number,
        object_version_number,
        date_accounting,
        amount,
        funding_reference_number,
        funding_reference_type_code,
        payables_invoice_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        error_message,
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
--start:|           14-May-07 cklee -- added TLD_ID column                           |
        tld_id,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
        sel_id)
      VALUES (
        l_tpl_rec.id,
        l_tpl_rec.inv_distr_line_code,
        l_tpl_rec.tap_id,
        l_tpl_rec.disbursement_basis_code,
        l_tpl_rec.tpl_id_reverses,
        l_tpl_rec.code_combination_id,
        l_tpl_rec.lsm_id,
        l_tpl_rec.kle_id,
        l_tpl_rec.khr_id,
        l_tpl_rec.cnsld_ap_inv_id,
        l_tpl_rec.taxable_yn,
        l_tpl_rec.itc_id,
        l_tpl_rec.sty_id,
        l_tpl_rec.line_number,
        l_tpl_rec.ref_line_number,
        l_tpl_rec.cnsld_line_number,
        l_tpl_rec.object_version_number,
        l_tpl_rec.date_accounting,
        l_tpl_rec.amount,
        l_tpl_rec.funding_reference_number,
        l_tpl_rec.funding_reference_type_code,
        l_tpl_rec.payables_invoice_id,
        l_tpl_rec.request_id,
        l_tpl_rec.program_application_id,
        l_tpl_rec.program_id,
        l_tpl_rec.program_update_date,
        l_tpl_rec.org_id,
        l_tpl_rec.error_message,
        l_tpl_rec.attribute_category,
        l_tpl_rec.attribute1,
        l_tpl_rec.attribute2,
        l_tpl_rec.attribute3,
        l_tpl_rec.attribute4,
        l_tpl_rec.attribute5,
        l_tpl_rec.attribute6,
        l_tpl_rec.attribute7,
        l_tpl_rec.attribute8,
        l_tpl_rec.attribute9,
        l_tpl_rec.attribute10,
        l_tpl_rec.attribute11,
        l_tpl_rec.attribute12,
        l_tpl_rec.attribute13,
        l_tpl_rec.attribute14,
        l_tpl_rec.attribute15,
        l_tpl_rec.created_by,
        l_tpl_rec.creation_date,
        l_tpl_rec.last_updated_by,
        l_tpl_rec.last_update_date,
        l_tpl_rec.last_update_login,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
        l_tpl_rec.tld_id,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
        l_tpl_rec.sel_id);
    -- Set OUT values
    x_tpl_rec := l_tpl_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_TXL_AP_INV_LNS_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ap_inv_lns_tl_rec    IN okl_txl_ap_inv_lns_tl_rec_type,
    x_okl_txl_ap_inv_lns_tl_rec    OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type := p_okl_txl_ap_inv_lns_tl_rec;
    ldefokltxlapinvlnstlrec        okl_txl_ap_inv_lns_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_ap_inv_lns_tl_rec IN  okl_txl_ap_inv_lns_tl_rec_type,
      x_okl_txl_ap_inv_lns_tl_rec OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ap_inv_lns_tl_rec := p_okl_txl_ap_inv_lns_tl_rec;
      x_okl_txl_ap_inv_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_ap_inv_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_ap_inv_lns_tl_rec,       -- IN
      l_okl_txl_ap_inv_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txl_ap_inv_lns_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TXL_AP_INV_LNS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_txl_ap_inv_lns_tl_rec.id,
          l_okl_txl_ap_inv_lns_tl_rec.language,
          l_okl_txl_ap_inv_lns_tl_rec.source_lang,
          l_okl_txl_ap_inv_lns_tl_rec.sfwt_flag,
          l_okl_txl_ap_inv_lns_tl_rec.description,
          l_okl_txl_ap_inv_lns_tl_rec.created_by,
          l_okl_txl_ap_inv_lns_tl_rec.creation_date,
          l_okl_txl_ap_inv_lns_tl_rec.last_updated_by,
          l_okl_txl_ap_inv_lns_tl_rec.last_update_date,
          l_okl_txl_ap_inv_lns_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txl_ap_inv_lns_tl_rec := l_okl_txl_ap_inv_lns_tl_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------
  -- insert_row for:OKL_TXL_AP_INV_LNS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type,
    x_tplv_rec                     OUT NOCOPY tplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tplv_rec                     tplv_rec_type;
    l_def_tplv_rec                 tplv_rec_type;
    l_tpl_rec                      tpl_rec_type;
    lx_tpl_rec                     tpl_rec_type;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
    lx_okl_txl_ap_inv_lns_tl_rec   okl_txl_ap_inv_lns_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tplv_rec	IN tplv_rec_type
    ) RETURN tplv_rec_type IS
      l_tplv_rec	tplv_rec_type := p_tplv_rec;
    BEGIN
      l_tplv_rec.CREATION_DATE := SYSDATE;
      l_tplv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tplv_rec.LAST_UPDATE_DATE := l_tplv_rec.CREATION_DATE;     -- PostGen-10
      l_tplv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tplv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tplv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tplv_rec IN  tplv_rec_type,
      x_tplv_rec OUT NOCOPY tplv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tplv_rec := p_tplv_rec;
      x_tplv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tplv_rec.SFWT_FLAG := 'N';

      -- Start PostGen-7
      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_tplv_rec.request_id,
        x_tplv_rec.program_application_id,
        x_tplv_rec.program_id,
        x_tplv_rec.program_update_date
      FROM   dual;
      -- End PostGen-7

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
    l_tplv_rec := null_out_defaults(p_tplv_rec);
    -- Set primary key value
    l_tplv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tplv_rec,                        -- IN
      l_def_tplv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tplv_rec := fill_who_columns(l_def_tplv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tplv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tplv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tplv_rec, l_tpl_rec);
    migrate(l_def_tplv_rec, l_okl_txl_ap_inv_lns_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tpl_rec,
      lx_tpl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tpl_rec, l_def_tplv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ap_inv_lns_tl_rec,
      lx_okl_txl_ap_inv_lns_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_ap_inv_lns_tl_rec, l_def_tplv_rec);
    -- Set OUT values
    x_tplv_rec := l_def_tplv_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:TPLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type,
    x_tplv_tbl                     OUT NOCOPY tplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tplv_rec                     => p_tplv_tbl(i),
          x_tplv_rec                     => x_tplv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_tplv_tbl.LAST);
        i := p_tplv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- lock_row for:OKL_TXL_AP_INV_LNS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tpl_rec                      IN tpl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tpl_rec IN tpl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_AP_INV_LNS_B
     WHERE ID = p_tpl_rec.id
       AND OBJECT_VERSION_NUMBER = p_tpl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tpl_rec IN tpl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_AP_INV_LNS_B
    WHERE ID = p_tpl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_AP_INV_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_AP_INV_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_tpl_rec);
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
      OPEN lchk_csr(p_tpl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tpl_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tpl_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------------
  -- lock_row for:OKL_TXL_AP_INV_LNS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ap_inv_lns_tl_rec    IN okl_txl_ap_inv_lns_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txl_ap_inv_lns_tl_rec IN okl_txl_ap_inv_lns_tl_rec_type) IS
    SELECT *
      FROM OKL_TXL_AP_INV_LNS_TL
     WHERE ID = p_okl_txl_ap_inv_lns_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_okl_txl_ap_inv_lns_tl_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------
  -- lock_row for:OKL_TXL_AP_INV_LNS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tpl_rec                      tpl_rec_type;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_tplv_rec, l_tpl_rec);
    migrate(p_tplv_rec, l_okl_txl_ap_inv_lns_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tpl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ap_inv_lns_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:TPLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tplv_rec                     => p_tplv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_tplv_tbl.LAST);
        i := p_tplv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- update_row for:OKL_TXL_AP_INV_LNS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tpl_rec                      IN tpl_rec_type,
    x_tpl_rec                      OUT NOCOPY tpl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tpl_rec                      tpl_rec_type := p_tpl_rec;
    l_def_tpl_rec                  tpl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tpl_rec	IN tpl_rec_type,
      x_tpl_rec	OUT NOCOPY tpl_rec_type
    ) RETURN VARCHAR2 IS
      l_tpl_rec                      tpl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tpl_rec := p_tpl_rec;
      -- Get current database values
      l_tpl_rec := get_rec(p_tpl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tpl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.id := l_tpl_rec.id;
      END IF;
      IF (x_tpl_rec.inv_distr_line_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.inv_distr_line_code := l_tpl_rec.inv_distr_line_code;
      END IF;
      IF (x_tpl_rec.tap_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.tap_id := l_tpl_rec.tap_id;
      END IF;
      IF (x_tpl_rec.disbursement_basis_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.disbursement_basis_code := l_tpl_rec.disbursement_basis_code;
      END IF;
      IF (x_tpl_rec.tpl_id_reverses = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.tpl_id_reverses := l_tpl_rec.tpl_id_reverses;
      END IF;
      IF (x_tpl_rec.code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.code_combination_id := l_tpl_rec.code_combination_id;
      END IF;
      IF (x_tpl_rec.lsm_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.lsm_id := l_tpl_rec.lsm_id;
      END IF;
      IF (x_tpl_rec.kle_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.kle_id := l_tpl_rec.kle_id;
      END IF;
      IF (x_tpl_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.khr_id := l_tpl_rec.khr_id;
      END IF;
      IF (x_tpl_rec.cnsld_ap_inv_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.cnsld_ap_inv_id := l_tpl_rec.cnsld_ap_inv_id;
      END IF;
      IF (x_tpl_rec.taxable_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.taxable_yn := l_tpl_rec.taxable_yn;
      END IF;
      IF (x_tpl_rec.itc_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.itc_id := l_tpl_rec.itc_id;
      END IF;
      IF (x_tpl_rec.sty_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.sty_id := l_tpl_rec.sty_id;
      END IF;
      IF (x_tpl_rec.line_number = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.line_number := l_tpl_rec.line_number;
      END IF;
      IF (x_tpl_rec.ref_line_number = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.ref_line_number := l_tpl_rec.ref_line_number;
      END IF;
      IF (x_tpl_rec.cnsld_line_number = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.cnsld_line_number := l_tpl_rec.cnsld_line_number;
      END IF;
      IF (x_tpl_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.object_version_number := l_tpl_rec.object_version_number;
      END IF;
      IF (x_tpl_rec.date_accounting = OKL_API.G_MISS_DATE)
      THEN
        x_tpl_rec.date_accounting := l_tpl_rec.date_accounting;
      END IF;

      IF (x_tpl_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.amount := l_tpl_rec.amount;
      END IF;
      IF (x_tpl_rec.funding_reference_number = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.funding_reference_number := l_tpl_rec.funding_reference_number;
      END IF;
      IF (x_tpl_rec.funding_reference_type_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.funding_reference_type_code := l_tpl_rec.funding_reference_type_code;
      END IF;
      IF (x_tpl_rec.payables_invoice_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.payables_invoice_id := l_tpl_rec.payables_invoice_id;
      END IF;
      IF (x_tpl_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.request_id := l_tpl_rec.request_id;
      END IF;
      IF (x_tpl_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.program_application_id := l_tpl_rec.program_application_id;
      END IF;
      IF (x_tpl_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.program_id := l_tpl_rec.program_id;
      END IF;
      IF (x_tpl_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tpl_rec.program_update_date := l_tpl_rec.program_update_date;
      END IF;
      IF (x_tpl_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.org_id := l_tpl_rec.org_id;
      END IF;
      IF (x_tpl_rec.error_message = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.error_message := l_tpl_rec.error_message;
      END IF;
      IF (x_tpl_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute_category := l_tpl_rec.attribute_category;
      END IF;
      IF (x_tpl_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute1 := l_tpl_rec.attribute1;
      END IF;
      IF (x_tpl_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute2 := l_tpl_rec.attribute2;
      END IF;
      IF (x_tpl_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute3 := l_tpl_rec.attribute3;
      END IF;
      IF (x_tpl_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute4 := l_tpl_rec.attribute4;
      END IF;
      IF (x_tpl_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute5 := l_tpl_rec.attribute5;
      END IF;
      IF (x_tpl_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute6 := l_tpl_rec.attribute6;
      END IF;
      IF (x_tpl_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute7 := l_tpl_rec.attribute7;
      END IF;
      IF (x_tpl_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute8 := l_tpl_rec.attribute8;
      END IF;
      IF (x_tpl_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute9 := l_tpl_rec.attribute9;
      END IF;
      IF (x_tpl_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute10 := l_tpl_rec.attribute10;
      END IF;
      IF (x_tpl_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute11 := l_tpl_rec.attribute11;
      END IF;
      IF (x_tpl_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute12 := l_tpl_rec.attribute12;
      END IF;
      IF (x_tpl_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute13 := l_tpl_rec.attribute13;
      END IF;
      IF (x_tpl_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute14 := l_tpl_rec.attribute14;
      END IF;
      IF (x_tpl_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_tpl_rec.attribute15 := l_tpl_rec.attribute15;
      END IF;
      IF (x_tpl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.created_by := l_tpl_rec.created_by;
      END IF;
      IF (x_tpl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_tpl_rec.creation_date := l_tpl_rec.creation_date;
      END IF;
      IF (x_tpl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.last_updated_by := l_tpl_rec.last_updated_by;
      END IF;
      IF (x_tpl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tpl_rec.last_update_date := l_tpl_rec.last_update_date;
      END IF;
      IF (x_tpl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.last_update_login := l_tpl_rec.last_update_login;
      END IF;

--start:|           14-May-07 cklee -- added TLD_ID column                           |
      IF (x_tpl_rec.tld_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.tld_id := l_tpl_rec.tld_id;
      END IF;
--end:|           14-May-07 cklee -- added TLD_ID column                           |
      IF (x_tpl_rec.sel_id = OKL_API.G_MISS_NUM)
      THEN
        x_tpl_rec.sel_id := l_tpl_rec.sel_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tpl_rec IN  tpl_rec_type,
      x_tpl_rec OUT NOCOPY tpl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tpl_rec := p_tpl_rec;
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
      p_tpl_rec,                         -- IN
      l_tpl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tpl_rec, l_def_tpl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_AP_INV_LNS_B
    SET INV_DISTR_LINE_CODE = l_def_tpl_rec.inv_distr_line_code,
        TAP_ID = l_def_tpl_rec.tap_id,
        DISBURSEMENT_BASIS_CODE = l_def_tpl_rec.disbursement_basis_code,
        TPL_ID_REVERSES = l_def_tpl_rec.tpl_id_reverses,
        code_combination_id = l_def_tpl_rec.code_combination_id,
        LSM_ID = l_def_tpl_rec.lsm_id,
        KLE_ID = l_def_tpl_rec.kle_id,
        KHR_ID = l_def_tpl_rec.khr_id,
        cnsld_ap_inv_id = l_def_tpl_rec.cnsld_ap_inv_id,
        TAXABLE_YN = l_def_tpl_rec.taxable_yn,
        ITC_ID = l_def_tpl_rec.itc_id,
        STY_ID = l_def_tpl_rec.sty_id,
        LINE_NUMBER = l_def_tpl_rec.line_number,
        REF_LINE_NUMBER = l_def_tpl_rec.ref_line_number,
        CNSLD_LINE_NUMBER = l_def_tpl_rec.cnsld_line_number,
        OBJECT_VERSION_NUMBER = l_def_tpl_rec.object_version_number,
        DATE_ACCOUNTING = l_def_tpl_rec.date_accounting,
        AMOUNT = l_def_tpl_rec.amount,
        FUNDING_REFERENCE_NUMBER = l_def_tpl_rec.funding_reference_number,
        FUNDING_REFERENCE_TYPE_CODE = l_def_tpl_rec.funding_reference_type_code,
        PAYABLES_INVOICE_ID = l_def_tpl_rec.payables_invoice_id,
        REQUEST_ID = l_def_tpl_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_tpl_rec.program_application_id,
        PROGRAM_ID = l_def_tpl_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_tpl_rec.program_update_date,
        ORG_ID = l_def_tpl_rec.org_id,
        error_message = l_def_tpl_rec.error_message,
        ATTRIBUTE_CATEGORY = l_def_tpl_rec.attribute_category,
        ATTRIBUTE1 = l_def_tpl_rec.attribute1,
        ATTRIBUTE2 = l_def_tpl_rec.attribute2,
        ATTRIBUTE3 = l_def_tpl_rec.attribute3,
        ATTRIBUTE4 = l_def_tpl_rec.attribute4,
        ATTRIBUTE5 = l_def_tpl_rec.attribute5,
        ATTRIBUTE6 = l_def_tpl_rec.attribute6,
        ATTRIBUTE7 = l_def_tpl_rec.attribute7,
        ATTRIBUTE8 = l_def_tpl_rec.attribute8,
        ATTRIBUTE9 = l_def_tpl_rec.attribute9,
        ATTRIBUTE10 = l_def_tpl_rec.attribute10,
        ATTRIBUTE11 = l_def_tpl_rec.attribute11,
        ATTRIBUTE12 = l_def_tpl_rec.attribute12,
        ATTRIBUTE13 = l_def_tpl_rec.attribute13,
        ATTRIBUTE14 = l_def_tpl_rec.attribute14,
        ATTRIBUTE15 = l_def_tpl_rec.attribute15,
        CREATED_BY = l_def_tpl_rec.created_by,
        CREATION_DATE = l_def_tpl_rec.creation_date,
        LAST_UPDATED_BY = l_def_tpl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tpl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tpl_rec.last_update_login,
--start:|           14-May-07 cklee -- added TLD_ID column                           |
        TLD_ID = l_def_tpl_rec.tld_id,
--end:|           14-May-07 cklee -- added TLD_ID column                           |
        SEL_ID = l_def_tpl_rec.sel_id
    WHERE ID = l_def_tpl_rec.id;

    x_tpl_rec := l_def_tpl_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------------
  -- update_row for:OKL_TXL_AP_INV_LNS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ap_inv_lns_tl_rec    IN okl_txl_ap_inv_lns_tl_rec_type,
    x_okl_txl_ap_inv_lns_tl_rec    OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type := p_okl_txl_ap_inv_lns_tl_rec;
    ldefokltxlapinvlnstlrec        okl_txl_ap_inv_lns_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txl_ap_inv_lns_tl_rec	IN okl_txl_ap_inv_lns_tl_rec_type,
      x_okl_txl_ap_inv_lns_tl_rec	OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ap_inv_lns_tl_rec := p_okl_txl_ap_inv_lns_tl_rec;
      -- Get current database values
      l_okl_txl_ap_inv_lns_tl_rec := get_rec(p_okl_txl_ap_inv_lns_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.id := l_okl_txl_ap_inv_lns_tl_rec.id;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.language := l_okl_txl_ap_inv_lns_tl_rec.language;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.source_lang := l_okl_txl_ap_inv_lns_tl_rec.source_lang;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.sfwt_flag := l_okl_txl_ap_inv_lns_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.description := l_okl_txl_ap_inv_lns_tl_rec.description;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.created_by := l_okl_txl_ap_inv_lns_tl_rec.created_by;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.creation_date := l_okl_txl_ap_inv_lns_tl_rec.creation_date;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.last_updated_by := l_okl_txl_ap_inv_lns_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.last_update_date := l_okl_txl_ap_inv_lns_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txl_ap_inv_lns_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_ap_inv_lns_tl_rec.last_update_login := l_okl_txl_ap_inv_lns_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_ap_inv_lns_tl_rec IN  okl_txl_ap_inv_lns_tl_rec_type,
      x_okl_txl_ap_inv_lns_tl_rec OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ap_inv_lns_tl_rec := p_okl_txl_ap_inv_lns_tl_rec;
      x_okl_txl_ap_inv_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_ap_inv_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_ap_inv_lns_tl_rec,       -- IN
      l_okl_txl_ap_inv_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txl_ap_inv_lns_tl_rec, ldefokltxlapinvlnstlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_AP_INV_LNS_TL
    SET DESCRIPTION = ldefokltxlapinvlnstlrec.description,
        SOURCE_LANG = ldefokltxlapinvlnstlrec.source_lang,
        CREATED_BY = ldefokltxlapinvlnstlrec.created_by,
        CREATION_DATE = ldefokltxlapinvlnstlrec.creation_date,
        LAST_UPDATED_BY = ldefokltxlapinvlnstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltxlapinvlnstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltxlapinvlnstlrec.last_update_login
    WHERE ID = ldefokltxlapinvlnstlrec.id
      AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TXL_AP_INV_LNS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltxlapinvlnstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txl_ap_inv_lns_tl_rec := ldefokltxlapinvlnstlrec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------
  -- update_row for:OKL_TXL_AP_INV_LNS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type,
    x_tplv_rec                     OUT NOCOPY tplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tplv_rec                     tplv_rec_type := p_tplv_rec;
    l_def_tplv_rec                 tplv_rec_type;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
    lx_okl_txl_ap_inv_lns_tl_rec   okl_txl_ap_inv_lns_tl_rec_type;
    l_tpl_rec                      tpl_rec_type;
    lx_tpl_rec                     tpl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tplv_rec	IN tplv_rec_type
    ) RETURN tplv_rec_type IS
      l_tplv_rec	tplv_rec_type := p_tplv_rec;
    BEGIN
      l_tplv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tplv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tplv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tplv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tplv_rec	IN tplv_rec_type,
      x_tplv_rec	OUT NOCOPY tplv_rec_type
    ) RETURN VARCHAR2 IS
      l_tplv_rec                     tplv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tplv_rec := p_tplv_rec;
      -- Get current database values
      l_tplv_rec := get_rec(p_tplv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tplv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.id := l_tplv_rec.id;
      END IF;
      IF (x_tplv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.object_version_number := l_tplv_rec.object_version_number;
      END IF;
      IF (x_tplv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.sfwt_flag := l_tplv_rec.sfwt_flag;
      END IF;
      IF (x_tplv_rec.code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.code_combination_id := l_tplv_rec.code_combination_id;
      END IF;
      IF (x_tplv_rec.itc_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.itc_id := l_tplv_rec.itc_id;
      END IF;
      IF (x_tplv_rec.disbursement_basis_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.disbursement_basis_code := l_tplv_rec.disbursement_basis_code;
      END IF;
      IF (x_tplv_rec.kle_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.kle_id := l_tplv_rec.kle_id;
      END IF;
      IF (x_tplv_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.khr_id := l_tplv_rec.khr_id;
      END IF;
      IF (x_tplv_rec.cnsld_ap_inv_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.cnsld_ap_inv_id := l_tplv_rec.cnsld_ap_inv_id;
      END IF;
      IF (x_tplv_rec.taxable_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.taxable_yn := l_tplv_rec.taxable_yn;
      END IF;
      IF (x_tplv_rec.lsm_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.lsm_id := l_tplv_rec.lsm_id;
      END IF;
      IF (x_tplv_rec.tpl_id_reverses = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.tpl_id_reverses := l_tplv_rec.tpl_id_reverses;
      END IF;
      IF (x_tplv_rec.inv_distr_line_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.inv_distr_line_code := l_tplv_rec.inv_distr_line_code;
      END IF;
      IF (x_tplv_rec.sty_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.sty_id := l_tplv_rec.sty_id;
      END IF;
      IF (x_tplv_rec.tap_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.tap_id := l_tplv_rec.tap_id;
      END IF;
      IF (x_tplv_rec.date_accounting = OKL_API.G_MISS_DATE)
      THEN
        x_tplv_rec.date_accounting := l_tplv_rec.date_accounting;
      END IF;
      IF (x_tplv_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.amount := l_tplv_rec.amount;
      END IF;
      IF (x_tplv_rec.funding_reference_number = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.funding_reference_number := l_tplv_rec.funding_reference_number;
      END IF;
      IF (x_tplv_rec.funding_reference_type_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.funding_reference_type_code := l_tplv_rec.funding_reference_type_code;
      END IF;
      IF (x_tplv_rec.line_number = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.line_number := l_tplv_rec.line_number;
      END IF;
      IF (x_tplv_rec.ref_line_number = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.ref_line_number := l_tplv_rec.ref_line_number;
      END IF;
      IF (x_tplv_rec.cnsld_line_number = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.cnsld_line_number := l_tplv_rec.cnsld_line_number;
      END IF;
      IF (x_tplv_rec.payables_invoice_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.payables_invoice_id := l_tplv_rec.payables_invoice_id;
      END IF;
      IF (x_tplv_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.description := l_tplv_rec.description;
      END IF;
      IF (x_tplv_rec.error_message = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.error_message := l_tplv_rec.error_message;
      END IF;
      IF (x_tplv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute_category := l_tplv_rec.attribute_category;
      END IF;
      IF (x_tplv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute1 := l_tplv_rec.attribute1;
      END IF;
      IF (x_tplv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute2 := l_tplv_rec.attribute2;
      END IF;
      IF (x_tplv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute3 := l_tplv_rec.attribute3;
      END IF;
      IF (x_tplv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute4 := l_tplv_rec.attribute4;
      END IF;
      IF (x_tplv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute5 := l_tplv_rec.attribute5;
      END IF;
      IF (x_tplv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute6 := l_tplv_rec.attribute6;
      END IF;
      IF (x_tplv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute7 := l_tplv_rec.attribute7;
      END IF;
      IF (x_tplv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute8 := l_tplv_rec.attribute8;
      END IF;
      IF (x_tplv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute9 := l_tplv_rec.attribute9;
      END IF;
      IF (x_tplv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute10 := l_tplv_rec.attribute10;
      END IF;
      IF (x_tplv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute11 := l_tplv_rec.attribute11;
      END IF;
      IF (x_tplv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute12 := l_tplv_rec.attribute12;
      END IF;
      IF (x_tplv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute13 := l_tplv_rec.attribute13;
      END IF;
      IF (x_tplv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute14 := l_tplv_rec.attribute14;
      END IF;
      IF (x_tplv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_tplv_rec.attribute15 := l_tplv_rec.attribute15;
      END IF;
      IF (x_tplv_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.request_id := l_tplv_rec.request_id;
      END IF;
      IF (x_tplv_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.program_application_id := l_tplv_rec.program_application_id;
      END IF;
      IF (x_tplv_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.program_id := l_tplv_rec.program_id;
      END IF;
      IF (x_tplv_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tplv_rec.program_update_date := l_tplv_rec.program_update_date;
      END IF;
      IF (x_tplv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.org_id := l_tplv_rec.org_id;
      END IF;
      IF (x_tplv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.created_by := l_tplv_rec.created_by;
      END IF;
      IF (x_tplv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_tplv_rec.creation_date := l_tplv_rec.creation_date;
      END IF;
      IF (x_tplv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.last_updated_by := l_tplv_rec.last_updated_by;
      END IF;
      IF (x_tplv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tplv_rec.last_update_date := l_tplv_rec.last_update_date;
      END IF;
      IF (x_tplv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.last_update_login := l_tplv_rec.last_update_login;
      END IF;
--start:|           14-May-07 cklee -- added TLD_ID column                           |
      IF (x_tplv_rec.tld_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.tld_id := l_tplv_rec.tld_id;
      END IF;
--end:|           14-May-07 cklee -- added TLD_ID column                           |

      IF (x_tplv_rec.sel_id = OKL_API.G_MISS_NUM)
      THEN
        x_tplv_rec.sel_id := l_tplv_rec.sel_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tplv_rec IN  tplv_rec_type,
      x_tplv_rec OUT NOCOPY tplv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tplv_rec := p_tplv_rec;
      x_tplv_rec.OBJECT_VERSION_NUMBER := NVL(x_tplv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

      -- Begin PostGen-7
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_tplv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_tplv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_tplv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_tplv_rec.program_update_date,SYSDATE)
      INTO
        x_tplv_rec.request_id,
        x_tplv_rec.program_application_id,
        x_tplv_rec.program_id,
        x_tplv_rec.program_update_date
      FROM   dual;
      -- End PostGen-7

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
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tplv_rec,                        -- IN
      l_tplv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tplv_rec, l_def_tplv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tplv_rec := fill_who_columns(l_def_tplv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tplv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tplv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tplv_rec, l_okl_txl_ap_inv_lns_tl_rec);
    migrate(l_def_tplv_rec, l_tpl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ap_inv_lns_tl_rec,
      lx_okl_txl_ap_inv_lns_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_ap_inv_lns_tl_rec, l_def_tplv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tpl_rec,
      lx_tpl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tpl_rec, l_def_tplv_rec);
    x_tplv_rec := l_def_tplv_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:TPLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type,
    x_tplv_tbl                     OUT NOCOPY tplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tplv_rec                     => p_tplv_tbl(i),
          x_tplv_rec                     => x_tplv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_tplv_tbl.LAST);
        i := p_tplv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- delete_row for:OKL_TXL_AP_INV_LNS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tpl_rec                      IN tpl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tpl_rec                      tpl_rec_type:= p_tpl_rec;
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
    DELETE FROM OKL_TXL_AP_INV_LNS_B
     WHERE ID = l_tpl_rec.id;

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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------
  -- delete_row for:OKL_TXL_AP_INV_LNS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_ap_inv_lns_tl_rec    IN okl_txl_ap_inv_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type:= p_okl_txl_ap_inv_lns_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_AP_INV_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_ap_inv_lns_tl_rec IN  okl_txl_ap_inv_lns_tl_rec_type,
      x_okl_txl_ap_inv_lns_tl_rec OUT NOCOPY okl_txl_ap_inv_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_ap_inv_lns_tl_rec := p_okl_txl_ap_inv_lns_tl_rec;
      x_okl_txl_ap_inv_lns_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_txl_ap_inv_lns_tl_rec,       -- IN
      l_okl_txl_ap_inv_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_AP_INV_LNS_TL
     WHERE ID = l_okl_txl_ap_inv_lns_tl_rec.id;

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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------
  -- delete_row for:OKL_TXL_AP_INV_LNS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_rec                     IN tplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tplv_rec                     tplv_rec_type := p_tplv_rec;
    l_okl_txl_ap_inv_lns_tl_rec    okl_txl_ap_inv_lns_tl_rec_type;
    l_tpl_rec                      tpl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_tplv_rec, l_okl_txl_ap_inv_lns_tl_rec);
    migrate(l_tplv_rec, l_tpl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_ap_inv_lns_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tpl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:TPLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tplv_tbl                     IN tplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tplv_rec                     => p_tplv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_tplv_tbl.LAST);
        i := p_tplv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;     -- PostGen-9 = return overall status

    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_TPL_PVT;

/

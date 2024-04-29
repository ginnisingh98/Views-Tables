--------------------------------------------------------
--  DDL for Package Body OKL_TAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAP_PVT" AS
/* $Header: OKLSTAPB.pls 120.11 2008/01/17 10:09:54 veramach noship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages and Variables                 = Done! Msg=5; Var=3
  -- BODY:
  -- 0. Check for Not Null Columns                    = Done! 4, n/a:sfwt_flag
  -- 1. Check for Not Null Primary Keys               = Done! 1
  -- 2. Check for Not Null Foreign Keys               = Done! 1=ipvs_id
  -- 3. Validity of Foreign Keys                      = Done! 15=10null+1notnull+4-FND;OKX=3
  -- 4. Validity of Unique Keys                       = N/A, No Unique Keys
  -- 5. Validity of Org_id                            = Done!
  -- 6. Added domain validation                       = Done! yn=3; allowed-values=1
  -- 7. Added the Concurrent Manager Columns (p104)   = Done! 2=views:v_insert_row,v_update_row
  -- 8. Validate fnd_lookup code using OKL_UTIL pkg   = Done! 3=nullable; 1=notnull (currency)
  -- 9. Capture most severe error in loops (p103)     = Done! 5 loops (except l_lang_rec)
  --10. Reduce use of SYSDATE fill_who_columns (p104) = Done! 1 (for insert)
  --11. Fix Migrate Parameter p_to IN OUT (p104)      = Done! 4
  --12. Call validate procs. in Validate_Attributes   = Done! 25
  --13. Validate_Record:Trx-Types, Unique Keys        = Done! 15 = trx-types
  --06/01/00: Post postgen changes:
  --14. Removed all references to TRX_TYPE. This columns dropped from BD
  --15. Added 3 new columns: TRX_STATUS_CODE,SET_OF_BOOKS_ID,TRY_ID + support,validations
  --16. Renamed Combo_ID to code_combination_id
  --17. 08/21/01: 'validate_fk_ccid', 'validate_fk_ippt_id' has been commented out because the associated OKX_ views does not exist.
  --18. 02/04/02: Added new columns vendor_invoice_number, pay_group_lookup_code,invoice_type, nettable_yn
  --19. 30-SEP-06 : Added column legal_entity_id
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id - PostGen-1
  ---------------------------------------------------------------------------
  PROCEDURE validate_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.id IS NULL) OR (p_tapv_rec.id = OKL_Api.G_MISS_NUM) THEN
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
  -- PROCEDURE validate_object_version_number - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.object_version_number IS NULL)
       OR (p_tapv_rec.object_version_number = OKL_Api.G_MISS_NUM) THEN
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
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.org_id IS NULL) OR (p_tapv_rec.org_id = OKL_Api.G_MISS_NUM) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'org_id'
            ) ;
      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      x_return_status := OKL_UTIL.CHECK_ORG_ID(p_tapv_rec.org_id);
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
  -- PROCEDURE validate_amount - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_amount
            ( x_return_status          OUT NOCOPY       VARCHAR2
            , p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.amount IS NULL) OR (p_tapv_rec.amount = OKL_Api.G_MISS_NUM) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'amount'
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
  END validate_amount;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_date_invoiced - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_date_invoiced
            ( x_return_status          OUT NOCOPY       VARCHAR2
            , p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.date_invoiced IS NULL) OR
      (p_tapv_rec.date_invoiced = OKL_Api.G_MISS_DATE) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'date_invoiced'
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
  END validate_date_invoiced;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_date_entered - PostGen-0
  ---------------------------------------------------------------------------
  PROCEDURE validate_date_entered
            ( x_return_status          OUT NOCOPY       VARCHAR2
            , p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.date_entered IS NULL) OR
      (p_tapv_rec.date_entered = OKL_Api.G_MISS_DATE) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'date_entered'
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
  END validate_date_entered;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_wait_vend_inv_yn - PostGen-6
  ---------------------------------------------------------------------------
  PROCEDURE validate_wait_vend_inv_yn
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.wait_vendor_invoice_yn IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_DOMAIN_YN(p_tapv_rec.wait_vendor_invoice_yn);
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'wait_vendor_invoice_yn'
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
  END validate_wait_vend_inv_yn;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_consolidate_yn - PostGen-6
  ---------------------------------------------------------------------------
  PROCEDURE validate_consolidate_yn
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.consolidate_yn IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_DOMAIN_YN(p_tapv_rec.consolidate_yn);
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'consolidate_yn'
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
  END validate_consolidate_yn;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_workflow_yn - PostGen-6
  ---------------------------------------------------------------------------
  PROCEDURE validate_workflow_yn
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.workflow_yn IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_DOMAIN_YN(p_tapv_rec.workflow_yn);
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'workflow_yn'
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
  END validate_workflow_yn;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_payment_method_code - PostGen-8
  ---------------------------------------------------------------------------
  PROCEDURE validate_payment_method_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.payment_method_code IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                         ( 'OKL_AP_PAYMENT_METHOD'
                         , p_tapv_rec.payment_method_code
                         );
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'payment_method_code'
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
  END validate_payment_method_code;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_invoice_category_code - PostGen-8
  ---------------------------------------------------------------------------
  PROCEDURE validate_invoice_category_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.invoice_category_code IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                         ( 'OKL_AP_INVOICE_CATEGORY'
                         , p_tapv_rec.invoice_category_code
                         );
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'invoice_category_code'
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
  END validate_invoice_category_code;

 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity --- Start changes
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_le_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_le_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type  ) IS
    l_return_status           number; -- varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

  IF (p_tapv_rec.legal_entity_id IS NULL)
     OR (p_tapv_rec.legal_entity_id  = OKL_Api.G_MISS_NUM)
     THEN
         OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_required_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'legal_entity_id'
             ) ;
         x_return_status := OKL_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE

       l_return_status := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists
                         ( p_tapv_rec.legal_entity_id);

       IF l_return_status = 1 then
          x_return_status := OKL_Api.G_RET_STS_SUCCESS;
       ELSE
           x_return_status := OKL_Api.G_RET_STS_ERROR;
       END IF;
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'legal_entity_id');
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
  END validate_le_id;
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity --- End changes
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_funding_type_code - PostGen-8
  ---------------------------------------------------------------------------
  PROCEDURE validate_funding_type_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.funding_type_code IS NOT NULL) THEN
      x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                         ( 'OKL_FUNDING_TYPE'
                         , p_tapv_rec.funding_type_code
                         );
      IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
         OKL_Api.SET_MESSAGE
               ( p_app_name     => g_app_name,
                 p_msg_name     => g_invalid_value,
                 p_token1       => g_col_name_token,
                 p_token1_value => 'funding_type_code'
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
  END validate_funding_type_code;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_currency_code - PostGen-8
  ---------------------------------------------------------------------------
  PROCEDURE validate_currency_code
          ( x_return_status       OUT NOCOPY VARCHAR2
          , p_tapv_rec            IN  tapv_rec_type
          ) IS
   l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
   l_dummy_var                VARCHAR2(1)    := '?';
   CURSOR l_fncv_csr IS
    SELECT 'x'
	FROM fnd_currencies_vl
	WHERE currency_code = p_tapv_rec.currency_code;
  BEGIN
  	   x_return_status := Okl_api.G_RET_STS_SUCCESS;
	   --Check Not Null
	   IF (p_tapv_rec.currency_code IS NULL)
       OR (p_tapv_rec.currency_code =  Okl_api.G_MISS_CHAR)
       THEN
	     x_return_status:=Okl_api.G_RET_STS_ERROR;
		 --set error message in message stack
		 Okl_api.SET_MESSAGE(p_app_name     => G_APP_NAME,
         	                 p_msg_name     => G_INVALID_VALUE,
          				     p_token1       => G_COL_NAME_TOKEN,
							 p_token1_value => 'CURRENCY_CODE');
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       --Check FK column
	   OPEN l_fncv_csr;
	   FETCH l_fncv_csr INTO l_dummy_var;
	   CLOSE l_fncv_csr;
	   IF (l_dummy_var = '?') THEN
	      x_return_status := Okl_api.G_RET_STS_ERROR;
		  Okl_api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
			 				  p_msg_name		=> G_NO_PARENT_RECORD,
							  p_token1			=> G_COL_NAME_TOKEN,
							  p_token1_value	=> 'CURRENCY_CODE',
							  p_token2			=> G_CHILD_TABLE_TOKEN,
							  p_token2_value	=> G_VIEW,
							  p_token3			=> G_PARENT_TABLE_TOKEN,
							  p_token3_value	=> 'FND_CURRENCIES_VL');
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
      IF l_fncv_csr%ISOPEN THEN
         CLOSE l_fncv_csr;
      END IF;
  END validate_currency_code;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_ipvs_id - PostGen-2 PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_ipvs_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_ipvsv_csr IS
      SELECT 'x'
      FROM OKX_VENDOR_SITES_V
      WHERE id1 = p_tapv_rec.ipvs_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.ipvs_id IS NULL)
      OR (p_tapv_rec.ipvs_id = OKL_Api.G_MISS_NUM) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'ipvs_id'
            ) ;
      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    open  l_ipvsv_csr;
    fetch l_ipvsv_csr into l_dummy_var;
    close l_ipvsv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'ipvs_id',
               p_token2           => g_child_table_token,
               p_token2_value     => G_VIEW,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKX_VENDOR_SITES_V');
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
      IF l_ipvsv_csr%ISOPEN THEN
         CLOSE l_ipvsv_csr;
      END IF;
  END validate_fk_ipvs_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_ccid - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_ccid
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
/****************** OKX View Not Available  *****************
    CURSOR l_cciv_csr IS
      SELECT 'x'
      FROM OKX_CODE_COMBINATIONS_V
      WHERE id = p_tapv_rec.code_combination_id;
***************** OKX View Not Available  ******************/
  BEGIN
       null;
/****************** OKX View Not Available  *****************
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.code_combination_id IS NOT NULL) THEN
      IF(p_tapv_rec.code_combination_id = OKL_Api.G_MISS_NUM) THEN
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
               p_token2_value     => g_view,
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
  -- PROCEDURE validate_fk_tap_id_reverses - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_tap_id_reverses
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_tapv_csr IS
      SELECT 'x'
      FROM OKL_TRX_AP_INVOICES_V
      WHERE id = p_tapv_rec.tap_id_reverses;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.tap_id_reverses IS NOT NULL) THEN
      IF(p_tapv_rec.tap_id_reverses = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'tap_id_reverses'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_tapv_csr;
    fetch l_tapv_csr into l_dummy_var;
    close l_tapv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'tap_id_reverses',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
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
  END validate_fk_tap_id_reverses;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_cplv_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_cplv_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_cplv_csr IS
      SELECT 'x'
      FROM OKC_K_PARTY_ROLES_V
      WHERE id = p_tapv_rec.cplv_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.cplv_id IS NOT NULL) THEN
      IF(p_tapv_rec.cplv_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'cplv_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_cplv_csr;
    fetch l_cplv_csr into l_dummy_var;
    close l_cplv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'cplv_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKC_K_PARTY_ROLES_V');
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
      IF l_cplv_csr%ISOPEN THEN
         CLOSE l_cplv_csr;
      END IF;
  END validate_fk_cplv_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_qte_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_qte_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_qtev_csr IS
      SELECT 'x'
      FROM OKL_TRX_QUOTES_V
      WHERE id = p_tapv_rec.qte_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.qte_id IS NOT NULL) THEN
      IF(p_tapv_rec.qte_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'qte_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_qtev_csr;
    fetch l_qtev_csr into l_dummy_var;
    close l_qtev_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'qte_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_TRX_QUOTES_V');
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
      IF l_qtev_csr%ISOPEN THEN
         CLOSE l_qtev_csr;
      END IF;
  END validate_fk_qte_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_tcn_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_tcn_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_tcnv_csr IS
      SELECT 'x'
      FROM OKL_TRX_CONTRACTS
      WHERE id = p_tapv_rec.tcn_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.tcn_id IS NOT NULL) THEN
      IF(p_tapv_rec.tcn_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'tcn_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_tcnv_csr;
    fetch l_tcnv_csr into l_dummy_var;
    close l_tcnv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'tcn_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_TRX_CONTRACTS');
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
      IF l_tcnv_csr%ISOPEN THEN
         CLOSE l_tcnv_csr;
      END IF;
  END validate_fk_tcn_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_ippt_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_ippt_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
/****************** OKX View Not Available  *****************
    CURSOR l_ipptv_csr IS
      SELECT 'x'
      FROM OKX_PAYABLES_PAYMENT_TERMS_V
      WHERE id = p_tapv_rec.ippt_id;
***************** OKX View Not Available  ******************/
  BEGIN
       null;
/****************** OKX View Not Available  *****************
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.ippt_id IS NOT NULL) THEN
      IF(p_tapv_rec.ippt_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'ippt_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_ipptv_csr;
    fetch l_ipptv_csr into l_dummy_var;
    close l_ipptv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'ippt_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKX_PAYABLES_PAYMENT_TERMS_V');
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
      IF l_ipptv_csr%ISOPEN THEN
         CLOSE l_ipptv_csr;
      END IF;
***************** OKX View Not Available  ******************/
  END validate_fk_ippt_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_art_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_art_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_artv_csr IS
      SELECT 'x'
      FROM OKL_ASSET_RETURNS_V
      WHERE id = p_tapv_rec.art_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.art_id IS NOT NULL) THEN
      IF(p_tapv_rec.art_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'art_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_artv_csr;
    fetch l_artv_csr into l_dummy_var;
    close l_artv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'art_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_ASSET_RETURNS_V');
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
      IF l_artv_csr%ISOPEN THEN
         CLOSE l_artv_csr;
      END IF;
  END validate_fk_art_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_khr_id - PostGen-3
  ---------------------------------------------------------------------------
  -- sjalasut, modified the procedure to validate incomming value of khr_id
  -- with okl_k_headers. other validations would continue to exist to check
  -- that if a khr_id is being stored, then it has valid fk referenced with
  -- okl_k_headers. changes made as part of OKLR12B disbursements project
  -- when khr_id is null, no error is reported.
  PROCEDURE validate_fk_khr_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_khrv_csr IS
      SELECT 'x'
      FROM OKL_K_HEADERS
      WHERE id = p_tapv_rec.khr_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.khr_id IS NOT NULL) THEN
      IF(p_tapv_rec.khr_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'khr_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      ELSE
        open  l_khrv_csr;
        fetch l_khrv_csr into l_dummy_var;
        close l_khrv_csr;
        IF l_dummy_var = '?' THEN
           OKL_Api.SET_MESSAGE
                 ( p_app_name         => g_app_name,
                   p_msg_name         => g_no_parent_record,
                   p_token1           => g_col_name_token,
                   p_token1_value     => 'khr_id',
                   p_token2           => g_child_table_token,
                   p_token2_value     => g_view,
                   p_token3           => g_parent_table_token,
                   p_token3_value     => 'OKL_K_HEADERS_V');
            x_return_status := OKL_Api.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
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
      -- verfiy that cursor was closed
      IF l_khrv_csr%ISOPEN THEN
         CLOSE l_khrv_csr;
      END IF;
  END validate_fk_khr_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_ccf_id - PostGen-3
  ---------------------------------------------------------------------------
/* Error View OKL_CSE_K_REFUNDS_V not exists
  PROCEDURE validate_fk_ccf_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_ccfv_csr IS
      SELECT 'x'
      FROM OKL_CSE_K_REFUNDS_V
      WHERE id = p_tapv_rec.ccf_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.ccf_id IS NOT NULL) THEN
      IF(p_tapv_rec.ccf_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'ccf_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_ccfv_csr;
    fetch l_ccfv_csr into l_dummy_var;
    close l_ccfv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'ccf_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_CSE_K_REFUNDS_V');
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
      IF l_ccfv_csr%ISOPEN THEN
         CLOSE l_ccfv_csr;
      END IF;
  END validate_fk_ccf_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_cct_id - PostGen-3
  ---------------------------------------------------------------------------
 Error view not exists
  PROCEDURE validate_fk_cct_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_cctv_csr IS
      SELECT 'x'
      FROM OKL_CSE_COSTS_V
      WHERE id = p_tapv_rec.cct_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.cct_id IS NOT NULL) THEN
      IF(p_tapv_rec.cct_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'cct_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_cctv_csr;
    fetch l_cctv_csr into l_dummy_var;
    close l_cctv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'cct_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_CSE_COSTS_V');
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
      IF l_cctv_csr%ISOPEN THEN
         CLOSE l_cctv_csr;
      END IF;
  END validate_fk_cct_id;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_try_id - Post postgen 14,15
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_try_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_tryv_csr IS
      SELECT 'x'
      FROM OKL_TRX_TYPES_V
      WHERE id = p_tapv_rec.try_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.try_id IS NULL)
      OR (p_tapv_rec.try_id = OKL_Api.G_MISS_NUM) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'try_id'
            ) ;
      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    open  l_tryv_csr;
    fetch l_tryv_csr into l_dummy_var;
    close l_tryv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'try_id',
               p_token2           => g_child_table_token,
               p_token2_value     => G_VIEW,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_TRX_TYPES_V');
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
      IF l_tryv_csr%ISOPEN THEN
         CLOSE l_tryv_csr;
      END IF;
  END validate_fk_try_id;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_sob_id  - Post postgen 14,15
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_sob_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';
    CURSOR l_sobv_csr IS
      SELECT 'x'
      FROM GL_LEDGERS_PUBLIC_V
      WHERE ledger_id = p_tapv_rec.set_of_books_id;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF(p_tapv_rec.set_of_books_id IS NOT NULL) THEN
      IF(p_tapv_rec.set_of_books_id = OKL_Api.G_MISS_NUM) THEN
        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'set_of_books_id'
              ) ;
        x_return_status := OKL_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error
      END IF;
    ELSE
      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL
    END IF;
    open  l_sobv_csr;
    fetch l_sobv_csr into l_dummy_var;
    close l_sobv_csr;
    IF l_dummy_var = '?' THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'set_of_books_id',
               p_token2           => g_child_table_token,
               p_token2_value     => g_view,
               p_token3           => g_parent_table_token,
               p_token3_value     => 'GL_LEDGERS_PUBLIC_V');
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
      IF l_sobv_csr%ISOPEN THEN
         CLOSE l_sobv_csr;
      END IF;
  END validate_fk_sob_id;

  --Start code added by pgomes on 19-NOV-2002
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_pox_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_pox_id (p_tapv_rec IN tapv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_pox_id_csr IS
    SELECT '1'
	FROM OKL_POOL_TRANSACTIONS
	WHERE id = p_tapv_rec.pox_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_tapv_rec.pox_id IS NOT NULL) THEN
      OPEN l_pox_id_csr;
      FETCH l_pox_id_csr INTO l_dummy_var;
      CLOSE l_pox_id_csr;

      IF (l_dummy_var <> '1') THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => G_NO_PARENT_RECORD,
	                    p_token1 => G_COL_NAME_TOKEN,
                            p_token1_value => 'POX_ID_FOR',
                            p_token2 => G_CHILD_TABLE_TOKEN,
                            p_token2_value => G_VIEW,
                            p_token3 => G_PARENT_TABLE_TOKEN,
                            p_token3_value => 'OKL_POOL_TRANSACTIONS');

      END IF;
    END IF;

  END validate_pox_id;

  --End code added by pgomes on 19-NOV-2002

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_trx_status_code - Post postgen 14,15
  ---------------------------------------------------------------------------
  PROCEDURE validate_trx_status_code
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_tapv_rec               IN        tapv_rec_type
            ) IS
    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKL_Api.G_RET_STS_SUCCESS;
    IF (p_tapv_rec.trx_status_code IS NULL)
    OR (p_tapv_rec.trx_status_code  = OKL_Api.G_MISS_CHAR)
    THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_required_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'trx_status_code'
             ) ;
       x_return_status := OKL_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := OKL_UTIL.CHECK_LOOKUP_CODE
                       ( 'OKL_TRANSACTION_STATUS'
                       , p_tapv_rec.trx_status_code
                       );
    IF x_return_status <> OKL_Api.G_RET_STS_SUCCESS THEN
       OKL_Api.SET_MESSAGE
             ( p_app_name     => g_app_name,
               p_msg_name     => g_invalid_value,
               p_token1       => g_col_name_token,
               p_token1_value => 'trx_status_code'
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
  END validate_trx_status_code;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_asset_tap_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_asset_tap_id (p_tapv_rec IN tapv_rec_type,
			x_return_status OUT NOCOPY VARCHAR2) IS
   l_dummy_var VARCHAR2(1) := '0';

   CURSOR l_asset_tap_id_csr IS
    SELECT '1'
	FROM OKL_TRX_AP_INVOICES_V
	WHERE id = p_tapv_rec.asset_tap_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_tapv_rec.asset_tap_id IS NOT NULL) THEN
      OPEN l_asset_tap_id_csr;
      FETCH l_asset_tap_id_csr INTO l_dummy_var;
      CLOSE l_asset_tap_id_csr;

      IF (l_dummy_var <> '1') THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => G_NO_PARENT_RECORD,
                            p_token1 => G_COL_NAME_TOKEN,
                            p_token1_value => 'ASSET_TAP_ID',
                            p_token2 => G_CHILD_TABLE_TOKEN,
                            p_token2_value => G_VIEW,
                            p_token3 => G_PARENT_TABLE_TOKEN,
                            p_token3_value => 'OKL_TRX_AP_INVOICES_V');

      END IF;
    END IF;

  END validate_asset_tap_id;

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
    DELETE FROM OKL_TRX_AP_INVOICES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TRX_AP_INVS_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );
    UPDATE OKL_TRX_AP_INVOICES_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TRX_AP_INVOICES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TRX_AP_INVOICES_TL SUBB, OKL_TRX_AP_INVOICES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));
    INSERT INTO OKL_TRX_AP_INVOICES_TL (
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
        FROM OKL_TRX_AP_INVOICES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TRX_AP_INVOICES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AP_INVOICES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tap_rec                      IN tap_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tap_rec_type IS
    CURSOR tap_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CURRENCY_CODE,
            PAYMENT_METHOD_CODE,
            FUNDING_TYPE_CODE,
            INVOICE_CATEGORY_CODE,
            IPVS_ID,
            KHR_ID,
            CCF_ID,
            CCT_ID,
            CPLV_ID,
            POX_ID,
            IPPT_ID,
            code_combination_id,
            QTE_ID,
            ART_ID,
            TCN_ID,
            TAP_ID_REVERSES,
            DATE_ENTERED,
            DATE_INVOICED,
            AMOUNT,
            TRX_STATUS_CODE,  -- Post Postgen 14,15
            SET_OF_BOOKS_ID,  -- Post Postgen 14,15
            TRY_ID,           -- Post Postgen 14,15
            OBJECT_VERSION_NUMBER,
            DATE_REQUISITION,
            DATE_FUNDING_APPROVED,
            INVOICE_NUMBER,
            DATE_GL,
            WORKFLOW_YN,
            CONSOLIDATE_YN,
            WAIT_VENDOR_INVOICE_YN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            VENDOR_ID,
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
            INVOICE_TYPE,
            PAY_GROUP_LOOKUP_CODE,
            VENDOR_INVOICE_NUMBER,
            NETTABLE_YN,
            ASSET_TAP_ID,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
            legal_entity_id
            ,transaction_date
      FROM Okl_Trx_Ap_Invoices_B
     WHERE okl_trx_ap_invoices_b.id = p_id;
    l_tap_pk                       tap_pk_csr%ROWTYPE;
    l_tap_rec                      tap_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tap_pk_csr (p_tap_rec.id);
    FETCH tap_pk_csr INTO
              l_tap_rec.ID,
              l_tap_rec.CURRENCY_CODE,
              l_tap_rec.PAYMENT_METHOD_CODE,
              l_tap_rec.FUNDING_TYPE_CODE,
              l_tap_rec.INVOICE_CATEGORY_CODE,
              l_tap_rec.IPVS_ID,
              l_tap_rec.KHR_ID,
              l_tap_rec.CCF_ID,
              l_tap_rec.CCT_ID,
              l_tap_rec.CPLV_ID,
              l_tap_rec.POX_ID,
              l_tap_rec.IPPT_ID,
              l_tap_rec.code_combination_id,
              l_tap_rec.QTE_ID,
              l_tap_rec.ART_ID,
              l_tap_rec.TCN_ID,
              l_tap_rec.TAP_ID_REVERSES,
              l_tap_rec.DATE_ENTERED,
              l_tap_rec.DATE_INVOICED,
              l_tap_rec.AMOUNT,
              l_tap_rec.TRX_STATUS_CODE,  -- Post Postgen 14,15
              l_tap_rec.SET_OF_BOOKS_ID,  -- Post Postgen 14,15
              l_tap_rec.TRY_ID,           -- Post Postgen 14,15
              l_tap_rec.OBJECT_VERSION_NUMBER,
              l_tap_rec.DATE_REQUISITION,
              l_tap_rec.DATE_FUNDING_APPROVED,
              l_tap_rec.INVOICE_NUMBER,
              l_tap_rec.DATE_GL,
              l_tap_rec.WORKFLOW_YN,
              l_tap_rec.CONSOLIDATE_YN,
              l_tap_rec.WAIT_VENDOR_INVOICE_YN,
              l_tap_rec.REQUEST_ID,
              l_tap_rec.PROGRAM_APPLICATION_ID,
              l_tap_rec.PROGRAM_ID,
              l_tap_rec.PROGRAM_UPDATE_DATE,
              l_tap_rec.ORG_ID,
              l_tap_rec.CURRENCY_CONVERSION_TYPE,
              l_tap_rec.CURRENCY_CONVERSION_RATE,
              l_tap_rec.CURRENCY_CONVERSION_DATE,
              l_tap_rec.VENDOR_ID,
              l_tap_rec.ATTRIBUTE_CATEGORY,
              l_tap_rec.ATTRIBUTE1,
              l_tap_rec.ATTRIBUTE2,
              l_tap_rec.ATTRIBUTE3,
              l_tap_rec.ATTRIBUTE4,
              l_tap_rec.ATTRIBUTE5,
              l_tap_rec.ATTRIBUTE6,
              l_tap_rec.ATTRIBUTE7,
              l_tap_rec.ATTRIBUTE8,
              l_tap_rec.ATTRIBUTE9,
              l_tap_rec.ATTRIBUTE10,
              l_tap_rec.ATTRIBUTE11,
              l_tap_rec.ATTRIBUTE12,
              l_tap_rec.ATTRIBUTE13,
              l_tap_rec.ATTRIBUTE14,
              l_tap_rec.ATTRIBUTE15,
              l_tap_rec.CREATED_BY,
              l_tap_rec.CREATION_DATE,
              l_tap_rec.LAST_UPDATED_BY,
              l_tap_rec.LAST_UPDATE_DATE,
              l_tap_rec.LAST_UPDATE_LOGIN,
              l_tap_rec.INVOICE_TYPE,
              l_tap_rec.PAY_GROUP_LOOKUP_CODE,
              l_tap_rec.VENDOR_INVOICE_NUMBER,
              l_tap_rec.NETTABLE_YN,
              l_tap_rec.asset_tap_id,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
              l_tap_rec.legal_entity_id
              ,l_tap_rec.transaction_date;
    x_no_data_found := tap_pk_csr%NOTFOUND;
    CLOSE tap_pk_csr;
    RETURN(l_tap_rec);
  END get_rec;
  FUNCTION get_rec (
    p_tap_rec                      IN tap_rec_type
  ) RETURN tap_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tap_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AP_INVOICES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_trx_ap_invoices_tl_rec   IN OklTrxApInvoicesTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklTrxApInvoicesTlRecType IS
    CURSOR okl_trx_ap_invoices_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Trx_Ap_Invoices_Tl
     WHERE okl_trx_ap_invoices_tl.id = p_id
       AND okl_trx_ap_invoices_tl.language = p_language;
    l_okl_trx_ap_invoices_tl_pk    okl_trx_ap_invoices_tl_pk_csr%ROWTYPE;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_ap_invoices_tl_pk_csr (p_okl_trx_ap_invoices_tl_rec.id,
                                        p_okl_trx_ap_invoices_tl_rec.language);
    FETCH okl_trx_ap_invoices_tl_pk_csr INTO
              l_okl_trx_ap_invoices_tl_rec.ID,
              l_okl_trx_ap_invoices_tl_rec.LANGUAGE,
              l_okl_trx_ap_invoices_tl_rec.SOURCE_LANG,
              l_okl_trx_ap_invoices_tl_rec.SFWT_FLAG,
              l_okl_trx_ap_invoices_tl_rec.DESCRIPTION,
              l_okl_trx_ap_invoices_tl_rec.CREATED_BY,
              l_okl_trx_ap_invoices_tl_rec.CREATION_DATE,
              l_okl_trx_ap_invoices_tl_rec.LAST_UPDATED_BY,
              l_okl_trx_ap_invoices_tl_rec.LAST_UPDATE_DATE,
              l_okl_trx_ap_invoices_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_trx_ap_invoices_tl_pk_csr%NOTFOUND;
    CLOSE okl_trx_ap_invoices_tl_pk_csr;
    RETURN(l_okl_trx_ap_invoices_tl_rec);
  END get_rec;
  FUNCTION get_rec (
    p_okl_trx_ap_invoices_tl_rec   IN OklTrxApInvoicesTlRecType
  ) RETURN OklTrxApInvoicesTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_trx_ap_invoices_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_AP_INVOICES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tapv_rec                     IN tapv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tapv_rec_type IS
    CURSOR okl_tapv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CCT_ID,
            CURRENCY_CODE,
            CCF_ID,
            FUNDING_TYPE_CODE,
            KHR_ID,
            ART_ID,
            TAP_ID_REVERSES,
            IPPT_ID,
            code_combination_id,
            IPVS_ID,
            TCN_ID,
            QTE_ID,
            INVOICE_CATEGORY_CODE,
            PAYMENT_METHOD_CODE,
            CPLV_ID,
            POX_ID,
            AMOUNT,
            DATE_INVOICED,
            INVOICE_NUMBER,
            DATE_FUNDING_APPROVED,
            DATE_GL,
            WORKFLOW_YN,
            CONSOLIDATE_YN,
            WAIT_VENDOR_INVOICE_YN,
            DATE_REQUISITION,
            DESCRIPTION,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            VENDOR_ID,
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
            DATE_ENTERED,
            TRX_STATUS_CODE,  -- Post Postgen 14,15
            SET_OF_BOOKS_ID,  -- Post Postgen 14,15
            TRY_ID,           -- Post Postgen 14,15
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
            INVOICE_TYPE,
            PAY_GROUP_LOOKUP_CODE,
            VENDOR_INVOICE_NUMBER,
            NETTABLE_YN,
            ASSET_TAP_ID,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
              legal_entity_id
              ,transaction_date
      FROM Okl_Trx_Ap_Invoices_V
     WHERE okl_trx_ap_invoices_v.id = p_id;
    l_okl_tapv_pk                  okl_tapv_pk_csr%ROWTYPE;
    l_tapv_rec                     tapv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tapv_pk_csr (p_tapv_rec.id);
    FETCH okl_tapv_pk_csr INTO
              l_tapv_rec.ID,
              l_tapv_rec.OBJECT_VERSION_NUMBER,
              l_tapv_rec.SFWT_FLAG,
              l_tapv_rec.CCT_ID,
              l_tapv_rec.CURRENCY_CODE,
              l_tapv_rec.CCF_ID,
              l_tapv_rec.FUNDING_TYPE_CODE,
              l_tapv_rec.KHR_ID,
              l_tapv_rec.ART_ID,
              l_tapv_rec.TAP_ID_REVERSES,
              l_tapv_rec.IPPT_ID,
              l_tapv_rec.code_combination_id,
              l_tapv_rec.IPVS_ID,
              l_tapv_rec.TCN_ID,
              l_tapv_rec.QTE_ID,
              l_tapv_rec.INVOICE_CATEGORY_CODE,
              l_tapv_rec.PAYMENT_METHOD_CODE,
              l_tapv_rec.CPLV_ID,
              l_tapv_rec.POX_ID,
              l_tapv_rec.AMOUNT,
              l_tapv_rec.DATE_INVOICED,
              l_tapv_rec.INVOICE_NUMBER,
              l_tapv_rec.DATE_FUNDING_APPROVED,
              l_tapv_rec.DATE_GL,
              l_tapv_rec.WORKFLOW_YN,
              l_tapv_rec.CONSOLIDATE_YN,
              l_tapv_rec.WAIT_VENDOR_INVOICE_YN,
              l_tapv_rec.DATE_REQUISITION,
              l_tapv_rec.DESCRIPTION,
              l_tapv_rec.CURRENCY_CONVERSION_TYPE,
              l_tapv_rec.CURRENCY_CONVERSION_RATE,
              l_tapv_rec.CURRENCY_CONVERSION_DATE,
              l_tapv_rec.VENDOR_ID,
              l_tapv_rec.ATTRIBUTE_CATEGORY,
              l_tapv_rec.ATTRIBUTE1,
              l_tapv_rec.ATTRIBUTE2,
              l_tapv_rec.ATTRIBUTE3,
              l_tapv_rec.ATTRIBUTE4,
              l_tapv_rec.ATTRIBUTE5,
              l_tapv_rec.ATTRIBUTE6,
              l_tapv_rec.ATTRIBUTE7,
              l_tapv_rec.ATTRIBUTE8,
              l_tapv_rec.ATTRIBUTE9,
              l_tapv_rec.ATTRIBUTE10,
              l_tapv_rec.ATTRIBUTE11,
              l_tapv_rec.ATTRIBUTE12,
              l_tapv_rec.ATTRIBUTE13,
              l_tapv_rec.ATTRIBUTE14,
              l_tapv_rec.ATTRIBUTE15,
              l_tapv_rec.DATE_ENTERED,
              l_tapv_rec.TRX_STATUS_CODE,  -- Post Postgen 14,15
              l_tapv_rec.SET_OF_BOOKS_ID,  -- Post Postgen 14,15
              l_tapv_rec.TRY_ID,           -- Post Postgen 14,15
              l_tapv_rec.REQUEST_ID,
              l_tapv_rec.PROGRAM_APPLICATION_ID,
              l_tapv_rec.PROGRAM_ID,
              l_tapv_rec.PROGRAM_UPDATE_DATE,
              l_tapv_rec.ORG_ID,
              l_tapv_rec.CREATED_BY,
              l_tapv_rec.CREATION_DATE,
              l_tapv_rec.LAST_UPDATED_BY,
              l_tapv_rec.LAST_UPDATE_DATE,
              l_tapv_rec.LAST_UPDATE_LOGIN,
              l_tapv_rec.INVOICE_TYPE,
              l_tapv_rec.PAY_GROUP_LOOKUP_CODE,
              l_tapv_rec.VENDOR_INVOICE_NUMBER,
              l_tapv_rec.NETTABLE_YN,
              l_tapv_rec.asset_tap_id,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
              l_tapv_rec.legal_entity_id
              ,l_tapv_rec.transaction_date;
    x_no_data_found := okl_tapv_pk_csr%NOTFOUND;
    CLOSE okl_tapv_pk_csr;
    RETURN(l_tapv_rec);
  END get_rec;
  FUNCTION get_rec (
    p_tapv_rec                     IN tapv_rec_type
  ) RETURN tapv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tapv_rec, l_row_notfound));
  END get_rec;
  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_AP_INVOICES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tapv_rec	IN tapv_rec_type
  ) RETURN tapv_rec_type IS
    l_tapv_rec	tapv_rec_type := p_tapv_rec;
  BEGIN
    IF (l_tapv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.object_version_number := NULL;
    END IF;
    IF (l_tapv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_tapv_rec.cct_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.cct_id := NULL;
    END IF;
    IF (l_tapv_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.currency_code := NULL;
    END IF;
    IF (l_tapv_rec.ccf_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.ccf_id := NULL;
    END IF;
    IF (l_tapv_rec.funding_type_code = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.funding_type_code := NULL;
    END IF;
    IF (l_tapv_rec.khr_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.khr_id := NULL;
    END IF;
    IF (l_tapv_rec.art_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.art_id := NULL;
    END IF;
    IF (l_tapv_rec.tap_id_reverses = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.tap_id_reverses := NULL;
    END IF;
    IF (l_tapv_rec.ippt_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.ippt_id := NULL;
    END IF;
    IF (l_tapv_rec.code_combination_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.code_combination_id := NULL;
    END IF;
    IF (l_tapv_rec.ipvs_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.ipvs_id := NULL;
    END IF;
    IF (l_tapv_rec.tcn_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.tcn_id := NULL;
    END IF;
    IF (l_tapv_rec.vpa_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.vpa_id := NULL;
    END IF;
    IF (l_tapv_rec.ipt_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.ipt_id := NULL;
    END IF;
    IF (l_tapv_rec.qte_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.qte_id := NULL;
    END IF;
    IF (l_tapv_rec.invoice_category_code = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.invoice_category_code := NULL;
    END IF;
    IF (l_tapv_rec.payment_method_code = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.payment_method_code := NULL;
    END IF;
    IF (l_tapv_rec.cplv_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.cplv_id := NULL;
    END IF;

    --Start code added by pgomes on 19-NOV-2002
    IF (l_tapv_rec.pox_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.pox_id := NULL;
    END IF;
    --End code added by pgomes on 19-NOV-2002

    IF (l_tapv_rec.amount = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.amount := NULL;
    END IF;
    IF (l_tapv_rec.date_invoiced = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.date_invoiced := NULL;
    END IF;
    IF (l_tapv_rec.invoice_number = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.invoice_number := NULL;
    END IF;
    IF (l_tapv_rec.date_funding_approved = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.date_funding_approved := NULL;
    END IF;
    IF (l_tapv_rec.date_gl = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.date_gl := NULL;
    END IF;
    IF (l_tapv_rec.workflow_yn = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.workflow_yn := NULL;
    END IF;
    IF (l_tapv_rec.match_required_yn = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.match_required_yn := NULL;
    END IF;
    IF (l_tapv_rec.ipt_frequency = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.ipt_frequency := NULL;
    END IF;
    IF (l_tapv_rec.consolidate_yn = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.consolidate_yn := NULL;
    END IF;
    IF (l_tapv_rec.wait_vendor_invoice_yn = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.wait_vendor_invoice_yn := NULL;
    END IF;
    IF (l_tapv_rec.date_requisition = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.date_requisition := NULL;
    END IF;
    IF (l_tapv_rec.description = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.description := NULL;
    END IF;
    IF (l_tapv_rec.CURRENCY_CONVERSION_TYPE = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.CURRENCY_CONVERSION_TYPE := NULL;
    END IF;
    IF (l_tapv_rec.CURRENCY_CONVERSION_RATE = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.CURRENCY_CONVERSION_RATE := NULL;
    END IF;
    IF (l_tapv_rec.CURRENCY_CONVERSION_DATE = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.CURRENCY_CONVERSION_DATE := NULL;
    END IF;
    IF (l_tapv_rec.VENDOR_ID = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.VENDOR_ID := NULL;
    END IF;
    IF (l_tapv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute_category := NULL;
    END IF;
    IF (l_tapv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute1 := NULL;
    END IF;
    IF (l_tapv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute2 := NULL;
    END IF;
    IF (l_tapv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute3 := NULL;
    END IF;
    IF (l_tapv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute4 := NULL;
    END IF;
    IF (l_tapv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute5 := NULL;
    END IF;
    IF (l_tapv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute6 := NULL;
    END IF;
    IF (l_tapv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute7 := NULL;
    END IF;
    IF (l_tapv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute8 := NULL;
    END IF;
    IF (l_tapv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute9 := NULL;
    END IF;
    IF (l_tapv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute10 := NULL;
    END IF;
    IF (l_tapv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute11 := NULL;
    END IF;
    IF (l_tapv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute12 := NULL;
    END IF;
    IF (l_tapv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute13 := NULL;
    END IF;
    IF (l_tapv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute14 := NULL;
    END IF;
    IF (l_tapv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.attribute15 := NULL;
    END IF;
    IF (l_tapv_rec.date_entered = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.date_entered := NULL;
    END IF;
    -- Start Post Postgen 14,15
    IF (l_tapv_rec.trx_status_code = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.trx_status_code := NULL;
    END IF;
    IF (l_tapv_rec.set_of_books_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_tapv_rec.try_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.try_id := NULL;
    END IF;
    -- End Post Postgen 14,15
    IF (l_tapv_rec.request_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.request_id := NULL;
    END IF;
    IF (l_tapv_rec.program_application_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.program_application_id := NULL;
    END IF;
    IF (l_tapv_rec.program_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.program_id := NULL;
    END IF;
    IF (l_tapv_rec.program_update_date = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.program_update_date := NULL;
    END IF;
    IF (l_tapv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.org_id := NULL;
    END IF;
    IF (l_tapv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.created_by := NULL;
    END IF;
    IF (l_tapv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.creation_date := NULL;
    END IF;
    IF (l_tapv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tapv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.last_update_date := NULL;
    END IF;
    IF (l_tapv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.last_update_login := NULL;
    END IF;
    IF (l_tapv_rec.invoice_type = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.invoice_type := NULL;
    END IF;
    IF (l_tapv_rec.pay_group_lookup_code = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.pay_group_lookup_code := NULL;
    END IF;
    IF (l_tapv_rec.vendor_invoice_number = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.vendor_invoice_number := NULL;
    END IF;
    IF (l_tapv_rec.nettable_yn = OKL_API.G_MISS_CHAR) THEN
      l_tapv_rec.nettable_yn := NULL;
    END IF;
    IF (l_tapv_rec.asset_tap_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.asset_tap_id := NULL;
    END IF;
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity

    IF (l_tapv_rec.legal_entity_id = OKL_API.G_MISS_NUM) THEN
      l_tapv_rec.legal_entity_id := NULL;
    END IF;

    IF (l_tapv_rec.transaction_date = OKL_API.G_MISS_DATE) THEN
      l_tapv_rec.transaction_date := NULL;
    END IF;

    RETURN(l_tapv_rec);
  END null_out_defaults;
  ------------------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes for:OKL_TRX_AP_INVOICES_V : Modified for PostGen-12
  ------------------------------------------------------------------------------------
  FUNCTION Validate_Attributes
         ( p_tapv_rec IN  tapv_rec_type
         ) RETURN VARCHAR2 IS
    x_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
    l_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    validate_id ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_object_version_number
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_org_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_amount
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_date_invoiced
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_date_entered
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_wait_vend_inv_yn
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_consolidate_yn
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_workflow_yn
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_payment_method_code
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_invoice_category_code
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_funding_type_code
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_currency_code
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_ipvs_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_ccid
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_tap_id_reverses
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_cplv_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_qte_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_tcn_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_ippt_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_art_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_khr_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
/*
    validate_fk_ccf_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_cct_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
*/
    validate_fk_try_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    validate_fk_sob_id
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    --Start code added by pgomes on 19-NOV-2002
    validate_pox_id( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    --End code added by pgomes on 19-NOV-2002

    validate_trx_status_code
                ( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_asset_tap_id( x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity  start changes
    validate_le_id(x_return_status      => l_return_status
                , p_tapv_rec           => p_tapv_rec) ;

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity  End changes


    RETURN x_return_status;  -- Return status to the caller
  /*------------------------------- TAPI Generated Code ---------------------------------------+
    IF p_tapv_rec.id = OKL_API.G_MISS_NUM OR
       p_tapv_rec.id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_tapv_rec.object_version_number IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.currency_code = OKL_API.G_MISS_CHAR OR
          p_tapv_rec.currency_code IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.ipvs_id = OKL_API.G_MISS_NUM OR
          p_tapv_rec.ipvs_id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ipvs_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.amount = OKL_API.G_MISS_NUM OR
          p_tapv_rec.amount IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'amount');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.date_invoiced = OKL_API.G_MISS_DATE OR
          p_tapv_rec.date_invoiced IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_invoiced');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.date_entered = OKL_API.G_MISS_DATE OR
          p_tapv_rec.date_entered IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_entered');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_tapv_rec.trx_type = OKL_API.G_MISS_CHAR OR
          p_tapv_rec.trx_type IS NULL
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
  --------------------------------------------------------------------------------
  -- PROCEDURE Validate_Record for:OKL_TRX_AP_INVOICES_V : Modified for PostGen-13
  --------------------------------------------------------------------------------
  FUNCTION Validate_Record
         ( p_tapv_rec IN tapv_rec_type
         ) RETURN VARCHAR2 IS
    x_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
    l_return_status          VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Post Postgen 14,15
    RETURN x_return_status;  -- Return status to the caller
--  l_return_status := validate_foreign_keys (p_tapv_rec);  -- TAPI Generated Code
--  RETURN (l_return_status);                               -- TAPI Generated Code
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
  ------------------------------------
  -- FUNCTION validate_foreign_keys --
  ------------------------------------
  FUNCTION validate_foreign_keys
         ( p_tapv_rec IN tapv_rec_type
         ) RETURN VARCHAR2 IS
    CURSOR OKL_cplv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,OBJECT_VERSION_NUMBER,SFWT_FLAG,CHR_ID,CPL_ID,CLE_ID,RLE_CODE,
            DNZ_CHR_ID,OBJECT1_ID1,OBJECT1_ID2,JTOT_OBJECT1_CODE,COGNOMEN,CODE,
            FACILITY,MINORITY_GROUP_LOOKUP_CODE,SMALL_BUSINESS_FLAG,WOMEN_OWNED_FLAG,
            ALIAS,ROLE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,
            ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,
            ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,CREATED_BY,
            CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN
      FROM OKC_K_PARTY_ROLES_V
     WHERE OKC_K_PARTY_ROLES_V.id = p_id;
    l_OKL_cplv_pk                  OKL_cplv_pk_csr%ROWTYPE;
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_row_notfound                 BOOLEAN := TRUE;
    item_not_found_error          EXCEPTION;
  BEGIN
    IF (p_tapv_rec.CPLV_ID IS NOT NULL)
    THEN
      OPEN OKL_cplv_pk_csr(p_tapv_rec.CPLV_ID);
      FETCH OKL_cplv_pk_csr INTO l_OKL_cplv_pk;
      l_row_notfound := OKL_cplv_pk_csr%NOTFOUND;
      CLOSE OKL_cplv_pk_csr;
      IF (l_row_notfound) THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CPLV_ID');
        RAISE item_not_found_error;
      END IF;
    END IF;
    RETURN (l_return_status);
  EXCEPTION
    WHEN item_not_found_error THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN (l_return_status);
  END validate_foreign_keys;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tapv_rec_type,
    p_to	IN OUT NOCOPY tap_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;
    p_to.payment_method_code := p_from.payment_method_code;
    p_to.funding_type_code := p_from.funding_type_code;
    p_to.invoice_category_code := p_from.invoice_category_code;
    p_to.ipvs_id := p_from.ipvs_id;
    p_to.khr_id := p_from.khr_id;
    p_to.ccf_id := p_from.ccf_id;
    p_to.cct_id := p_from.cct_id;
    p_to.cplv_id := p_from.cplv_id;
    p_to.pox_id := p_from.pox_id;
    p_to.ippt_id := p_from.ippt_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.qte_id := p_from.qte_id;
    p_to.art_id := p_from.art_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.vpa_id := p_from.vpa_id;
    p_to.ipt_id := p_from.ipt_id;
    p_to.tap_id_reverses := p_from.tap_id_reverses;
    p_to.date_entered := p_from.date_entered;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.amount := p_from.amount;
    p_to.trx_status_code := p_from.trx_status_code;  -- Post Postgen 14,15
    p_to.set_of_books_id := p_from.set_of_books_id;  -- Post Postgen 14,15
    p_to.try_id := p_from.try_id;                    -- Post Postgen 14,15
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_requisition := p_from.date_requisition;
    p_to.date_funding_approved := p_from.date_funding_approved;
    p_to.invoice_number := p_from.invoice_number;
    p_to.date_gl := p_from.date_gl;
    p_to.workflow_yn := p_from.workflow_yn;
    p_to.match_required_yn := p_from.match_required_yn;
    p_to.ipt_frequency := p_from.ipt_frequency;
    p_to.consolidate_yn := p_from.consolidate_yn;
    p_to.wait_vendor_invoice_yn := p_from.wait_vendor_invoice_yn;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.CURRENCY_CONVERSION_TYPE := p_from.CURRENCY_CONVERSION_TYPE;
    p_to.CURRENCY_CONVERSION_RATE := p_from.CURRENCY_CONVERSION_RATE;
    p_to.CURRENCY_CONVERSION_DATE := p_from.CURRENCY_CONVERSION_DATE;
    p_to.vendor_id := p_from.vendor_id;
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
    p_to.invoice_type := p_from.invoice_type;
    p_to.pay_group_lookup_code := p_from.pay_group_lookup_code;
    p_to.vendor_invoice_number := p_from.vendor_invoice_number;
    p_to.nettable_yn := p_from.nettable_yn;
    p_to.asset_tap_id := p_from.asset_tap_id;                    -- Post Postgen 14,15
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.transaction_date := p_from.transaction_date;

  END migrate;
  PROCEDURE migrate (
    p_from	IN tap_rec_type,
    p_to	IN OUT NOCOPY tapv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;
    p_to.payment_method_code := p_from.payment_method_code;
    p_to.funding_type_code := p_from.funding_type_code;
    p_to.invoice_category_code := p_from.invoice_category_code;
    p_to.ipvs_id := p_from.ipvs_id;
    p_to.khr_id := p_from.khr_id;
    p_to.ccf_id := p_from.ccf_id;
    p_to.cct_id := p_from.cct_id;
    p_to.cplv_id := p_from.cplv_id;
    p_to.pox_id := p_from.pox_id;
    p_to.ippt_id := p_from.ippt_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.qte_id := p_from.qte_id;
    p_to.art_id := p_from.art_id;
    p_to.tcn_id := p_from.tcn_id;
    p_to.vpa_id := p_from.vpa_id;
    p_to.ipt_id := p_from.ipt_id;
    p_to.tap_id_reverses := p_from.tap_id_reverses;
    p_to.date_entered := p_from.date_entered;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.amount := p_from.amount;
    p_to.trx_status_code := p_from.trx_status_code;  -- Post Postgen 14,15
    p_to.set_of_books_id := p_from.set_of_books_id;  -- Post Postgen 14,15
    p_to.try_id := p_from.try_id;                    -- Post Postgen 14,15
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_requisition := p_from.date_requisition;
    p_to.date_funding_approved := p_from.date_funding_approved;
    p_to.invoice_number := p_from.invoice_number;
    p_to.date_gl := p_from.date_gl;
    p_to.workflow_yn := p_from.workflow_yn;
    p_to.match_required_yn := p_from.match_required_yn;
    p_to.ipt_frequency := p_from.ipt_frequency;
    p_to.consolidate_yn := p_from.consolidate_yn;
    p_to.wait_vendor_invoice_yn := p_from.wait_vendor_invoice_yn;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.CURRENCY_CONVERSION_TYPE := p_from.CURRENCY_CONVERSION_TYPE;
    p_to.CURRENCY_CONVERSION_RATE := p_from.CURRENCY_CONVERSION_RATE;
    p_to.CURRENCY_CONVERSION_DATE := p_from.CURRENCY_CONVERSION_DATE;
    p_to.vendor_id := p_from.vendor_id;
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
    p_to.invoice_type := p_from.invoice_type;
    p_to.pay_group_lookup_code := p_from.pay_group_lookup_code;
    p_to.vendor_invoice_number := p_from.vendor_invoice_number;
    p_to.nettable_yn := p_from.nettable_yn;
    p_to.asset_tap_id := p_from.asset_tap_id;                    -- Post Postgen 14,15
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    p_to.legal_entity_id := p_from.legal_entity_id;
    p_to.transaction_date := p_from.transaction_date;

  END migrate;
  PROCEDURE migrate (
    p_from	IN tapv_rec_type,
    p_to	IN OUT NOCOPY OklTrxApInvoicesTlRecType     -- PostGen-11
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
    p_from	IN OklTrxApInvoicesTlRecType,
    p_to	IN OUT NOCOPY tapv_rec_type     -- PostGen-11
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
  --------------------------------------------
  -- validate_row for:OKL_TRX_AP_INVOICES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tapv_rec                     tapv_rec_type := p_tapv_rec;
    l_tap_rec                      tap_rec_type;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
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
    l_return_status := Validate_Attributes(l_tapv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tapv_rec);
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
  -- PL/SQL TBL validate_row for:TAPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tapv_tbl.COUNT > 0) THEN
      i := p_tapv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tapv_rec                     => p_tapv_tbl(i));
        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9
        EXIT WHEN (i = p_tapv_tbl.LAST);
        i := p_tapv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKL_TRX_AP_INVOICES_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tap_rec                      IN tap_rec_type,
    x_tap_rec                      OUT NOCOPY tap_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tap_rec                      tap_rec_type := p_tap_rec;
    l_def_tap_rec                  tap_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tap_rec IN  tap_rec_type,
      x_tap_rec OUT NOCOPY tap_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tap_rec := p_tap_rec;
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
      p_tap_rec,                         -- IN
      l_tap_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_AP_INVOICES_B(
        id,
        currency_code,
        payment_method_code,
        funding_type_code,
        invoice_category_code,
        ipvs_id,
        khr_id,
        ccf_id,
        cct_id,
        cplv_id,
        pox_id,
        ippt_id,
        code_combination_id,
        qte_id,
        art_id,
        tcn_id,
        vpa_id,
        ipt_id,
        tap_id_reverses,
        date_entered,
        date_invoiced,
        amount,
        trx_status_code, -- Post Postgen 14,15
        set_of_books_id, -- Post Postgen 14,15
        try_id,          -- Post Postgen 14,15
        object_version_number,
        date_requisition,
        date_funding_approved,
        invoice_number,
        date_gl,
        workflow_yn,
        match_required_yn,
        ipt_frequency,
        consolidate_yn,
        wait_vendor_invoice_yn,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        vendor_id,
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
        invoice_type,
        pay_group_lookup_code,
        vendor_invoice_number,
        nettable_yn,
        asset_tap_id,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
        legal_entity_id
        ,transaction_date
        )
      VALUES (
        l_tap_rec.id,
        l_tap_rec.currency_code,
        l_tap_rec.payment_method_code,
        l_tap_rec.funding_type_code,
        l_tap_rec.invoice_category_code,
        l_tap_rec.ipvs_id,
        l_tap_rec.khr_id,
        l_tap_rec.ccf_id,
        l_tap_rec.cct_id,
        l_tap_rec.cplv_id,
        l_tap_rec.pox_id,
        l_tap_rec.ippt_id,
        l_tap_rec.code_combination_id,
        l_tap_rec.qte_id,
        l_tap_rec.art_id,
        l_tap_rec.tcn_id,
        l_tap_rec.vpa_id,
        l_tap_rec.ipt_id,
        l_tap_rec.tap_id_reverses,
        l_tap_rec.date_entered,
        l_tap_rec.date_invoiced,
        l_tap_rec.amount,
        l_tap_rec.trx_status_code, -- Post Postgen 14,15
        l_tap_rec.set_of_books_id, -- Post Postgen 14,15
        l_tap_rec.try_id,          -- Post Postgen 14,15
        l_tap_rec.object_version_number,
        l_tap_rec.date_requisition,
        l_tap_rec.date_funding_approved,
        l_tap_rec.invoice_number,
        l_tap_rec.date_gl,
        l_tap_rec.workflow_yn,
        l_tap_rec.match_required_yn,
        l_tap_rec.ipt_frequency,
        l_tap_rec.consolidate_yn,
        l_tap_rec.wait_vendor_invoice_yn,
        l_tap_rec.request_id,
        l_tap_rec.program_application_id,
        l_tap_rec.program_id,
        l_tap_rec.program_update_date,
        l_tap_rec.org_id,
        l_tap_rec.CURRENCY_CONVERSION_TYPE,
        l_tap_rec.CURRENCY_CONVERSION_RATE,
        l_tap_rec.CURRENCY_CONVERSION_DATE,
        l_tap_rec.vendor_id,
        l_tap_rec.attribute_category,
        l_tap_rec.attribute1,
        l_tap_rec.attribute2,
        l_tap_rec.attribute3,
        l_tap_rec.attribute4,
        l_tap_rec.attribute5,
        l_tap_rec.attribute6,
        l_tap_rec.attribute7,
        l_tap_rec.attribute8,
        l_tap_rec.attribute9,
        l_tap_rec.attribute10,
        l_tap_rec.attribute11,
        l_tap_rec.attribute12,
        l_tap_rec.attribute13,
        l_tap_rec.attribute14,
        l_tap_rec.attribute15,
        l_tap_rec.created_by,
        l_tap_rec.creation_date,
        l_tap_rec.last_updated_by,
        l_tap_rec.last_update_date,
        l_tap_rec.last_update_login,
        l_tap_rec.invoice_type,
        l_tap_rec.pay_group_lookup_code,
        l_tap_rec.vendor_invoice_number,
        l_tap_rec.nettable_yn,
        l_tap_rec.asset_tap_id,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
        l_tap_rec.legal_entity_id
        ,NVL(l_tap_rec.transaction_date,SYSDATE)
        );
    -- Set OUT values
    x_tap_rec := l_tap_rec;
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
  -------------------------------------------
  -- insert_row for:OKL_TRX_AP_INVOICES_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ap_invoices_tl_rec   IN OklTrxApInvoicesTlRecType,
    x_okl_trx_ap_invoices_tl_rec   OUT NOCOPY OklTrxApInvoicesTlRecType) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType := p_okl_trx_ap_invoices_tl_rec;
    ldefokltrxapinvoicestlrec      OklTrxApInvoicesTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ap_invoices_tl_rec IN  OklTrxApInvoicesTlRecType,
      x_okl_trx_ap_invoices_tl_rec OUT NOCOPY OklTrxApInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ap_invoices_tl_rec := p_okl_trx_ap_invoices_tl_rec;
      x_okl_trx_ap_invoices_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_ap_invoices_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_ap_invoices_tl_rec,      -- IN
      l_okl_trx_ap_invoices_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_trx_ap_invoices_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TRX_AP_INVOICES_TL(
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
          l_okl_trx_ap_invoices_tl_rec.id,
          l_okl_trx_ap_invoices_tl_rec.language,
          l_okl_trx_ap_invoices_tl_rec.source_lang,
          l_okl_trx_ap_invoices_tl_rec.sfwt_flag,
          l_okl_trx_ap_invoices_tl_rec.description,
          l_okl_trx_ap_invoices_tl_rec.created_by,
          l_okl_trx_ap_invoices_tl_rec.creation_date,
          l_okl_trx_ap_invoices_tl_rec.last_updated_by,
          l_okl_trx_ap_invoices_tl_rec.last_update_date,
          l_okl_trx_ap_invoices_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_trx_ap_invoices_tl_rec := l_okl_trx_ap_invoices_tl_rec;
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
  -- insert_row for:OKL_TRX_AP_INVOICES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type,
    x_tapv_rec                     OUT NOCOPY tapv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tapv_rec                     tapv_rec_type;
    l_def_tapv_rec                 tapv_rec_type;
    l_tap_rec                      tap_rec_type;
    lx_tap_rec                     tap_rec_type;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
    lx_okl_trx_ap_invoices_tl_rec  OklTrxApInvoicesTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tapv_rec	IN tapv_rec_type
    ) RETURN tapv_rec_type IS
      l_tapv_rec	tapv_rec_type := p_tapv_rec;
    BEGIN
      l_tapv_rec.CREATION_DATE := SYSDATE;
      l_tapv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tapv_rec.LAST_UPDATE_DATE := l_tapv_rec.CREATION_DATE;
      l_tapv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tapv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tapv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tapv_rec IN  tapv_rec_type,
      x_tapv_rec OUT NOCOPY tapv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tapv_rec := p_tapv_rec;
      x_tapv_rec.OBJECT_VERSION_NUMBER := 1;
      x_tapv_rec.SFWT_FLAG := 'N';
      -- Start PostGen-7
      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_tapv_rec.request_id,
        x_tapv_rec.program_application_id,
        x_tapv_rec.program_id,
        x_tapv_rec.program_update_date
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
    l_tapv_rec := null_out_defaults(p_tapv_rec);
    -- Set primary key value
    l_tapv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tapv_rec,                        -- IN
      l_def_tapv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tapv_rec := fill_who_columns(l_def_tapv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tapv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tapv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tapv_rec, l_tap_rec);
    migrate(l_def_tapv_rec, l_okl_trx_ap_invoices_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tap_rec,
      lx_tap_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tap_rec, l_def_tapv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ap_invoices_tl_rec,
      lx_okl_trx_ap_invoices_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_ap_invoices_tl_rec, l_def_tapv_rec);
    -- Set OUT values
    x_tapv_rec := l_def_tapv_rec;
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
  -- PL/SQL TBL insert_row for:TAPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type,
    x_tapv_tbl                     OUT NOCOPY tapv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tapv_tbl.COUNT > 0) THEN
      i := p_tapv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tapv_rec                     => p_tapv_tbl(i),
          x_tapv_rec                     => x_tapv_tbl(i));
        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9
        EXIT WHEN (i = p_tapv_tbl.LAST);
        i := p_tapv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_AP_INVOICES_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tap_rec                      IN tap_rec_type) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tap_rec IN tap_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = p_tap_rec.id
       AND OBJECT_VERSION_NUMBER = p_tap_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
    CURSOR  lchk_csr (p_tap_rec IN tap_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_AP_INVOICES_B
    WHERE ID = p_tap_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_AP_INVOICES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_AP_INVOICES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tap_rec);
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
      OPEN lchk_csr(p_tap_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tap_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tap_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKL_TRX_AP_INVOICES_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ap_invoices_tl_rec   IN OklTrxApInvoicesTlRecType) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_trx_ap_invoices_tl_rec IN OklTrxApInvoicesTlRecType) IS
    SELECT *
      FROM OKL_TRX_AP_INVOICES_TL
     WHERE ID = p_okl_trx_ap_invoices_tl_rec.id
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
      OPEN lock_csr(p_okl_trx_ap_invoices_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKL_TRX_AP_INVOICES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tap_rec                      tap_rec_type;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
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
    migrate(p_tapv_rec, l_tap_rec);
    migrate(p_tapv_rec, l_okl_trx_ap_invoices_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tap_rec
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
      l_okl_trx_ap_invoices_tl_rec
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
  -- PL/SQL TBL lock_row for:TAPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tapv_tbl.COUNT > 0) THEN
      i := p_tapv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tapv_rec                     => p_tapv_tbl(i));
        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9
        EXIT WHEN (i = p_tapv_tbl.LAST);
        i := p_tapv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKL_TRX_AP_INVOICES_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tap_rec                      IN tap_rec_type,
    x_tap_rec                      OUT NOCOPY tap_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tap_rec                      tap_rec_type := p_tap_rec;
    l_def_tap_rec                  tap_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tap_rec	IN tap_rec_type,
      x_tap_rec	OUT NOCOPY tap_rec_type
    ) RETURN VARCHAR2 IS
      l_tap_rec                      tap_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tap_rec := p_tap_rec;
      -- Get current database values
      l_tap_rec := get_rec(p_tap_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tap_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.id := l_tap_rec.id;
      END IF;
      IF (x_tap_rec.currency_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.currency_code := l_tap_rec.currency_code;
      END IF;
      IF (x_tap_rec.payment_method_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.payment_method_code := l_tap_rec.payment_method_code;
      END IF;
      IF (x_tap_rec.funding_type_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.funding_type_code := l_tap_rec.funding_type_code;
      END IF;
      IF (x_tap_rec.invoice_category_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.invoice_category_code := l_tap_rec.invoice_category_code;
      END IF;
      IF (x_tap_rec.ipvs_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.ipvs_id := l_tap_rec.ipvs_id;
      END IF;
      IF (x_tap_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.khr_id := l_tap_rec.khr_id;
      END IF;
      IF (x_tap_rec.ccf_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.ccf_id := l_tap_rec.ccf_id;
      END IF;
      IF (x_tap_rec.cct_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.cct_id := l_tap_rec.cct_id;
      END IF;
      IF (x_tap_rec.cplv_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.cplv_id := l_tap_rec.cplv_id;
      END IF;

      --Start code added by pgomes on 19-NOV-2002
      IF (x_tap_rec.pox_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.pox_id := l_tap_rec.pox_id;
      END IF;
      --End code added by pgomes on 19-NOV-2002

      IF (x_tap_rec.ippt_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.ippt_id := l_tap_rec.ippt_id;
      END IF;
      IF (x_tap_rec.code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.code_combination_id := l_tap_rec.code_combination_id;
      END IF;
      IF (x_tap_rec.qte_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.qte_id := l_tap_rec.qte_id;
      END IF;
      IF (x_tap_rec.art_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.art_id := l_tap_rec.art_id;
      END IF;
      IF (x_tap_rec.tcn_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.tcn_id := l_tap_rec.tcn_id;
      END IF;
      IF (x_tap_rec.vpa_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.vpa_id := l_tap_rec.vpa_id;
      END IF;
      IF (x_tap_rec.ipt_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.ipt_id := l_tap_rec.ipt_id;
      END IF;
      IF (x_tap_rec.tap_id_reverses = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.tap_id_reverses := l_tap_rec.tap_id_reverses;
      END IF;
      IF (x_tap_rec.date_entered = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.date_entered := l_tap_rec.date_entered;
      END IF;
      IF (x_tap_rec.date_invoiced = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.date_invoiced := l_tap_rec.date_invoiced;
      END IF;
      IF (x_tap_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.amount := l_tap_rec.amount;
      END IF;
      -- Start Post Postgen 14,15
      IF (x_tap_rec.trx_status_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.trx_status_code := l_tap_rec.trx_status_code;
      END IF;
      IF (x_tap_rec.set_of_books_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.set_of_books_id := l_tap_rec.set_of_books_id;
      END IF;
      IF (x_tap_rec.try_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.try_id := l_tap_rec.try_id;
      END IF;
      -- End Post Postgen 14,15
      IF (x_tap_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.object_version_number := l_tap_rec.object_version_number;
      END IF;
      IF (x_tap_rec.date_requisition = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.date_requisition := l_tap_rec.date_requisition;
      END IF;
      IF (x_tap_rec.date_funding_approved = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.date_funding_approved := l_tap_rec.date_funding_approved;
      END IF;
      IF (x_tap_rec.invoice_number = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.invoice_number := l_tap_rec.invoice_number;
      END IF;
      IF (x_tap_rec.date_gl = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.date_gl := l_tap_rec.date_gl;
      END IF;
      IF (x_tap_rec.workflow_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.workflow_yn := l_tap_rec.workflow_yn;
      END IF;
      IF (x_tap_rec.match_required_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.match_required_yn := l_tap_rec.match_required_yn;
      END IF;
      IF (x_tap_rec.ipt_frequency = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.ipt_frequency := l_tap_rec.ipt_frequency;
      END IF;
      IF (x_tap_rec.consolidate_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.consolidate_yn := l_tap_rec.consolidate_yn;
      END IF;
      IF (x_tap_rec.wait_vendor_invoice_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.wait_vendor_invoice_yn := l_tap_rec.wait_vendor_invoice_yn;
      END IF;
      IF (x_tap_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.request_id := l_tap_rec.request_id;
      END IF;
      IF (x_tap_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.program_application_id := l_tap_rec.program_application_id;
      END IF;
      IF (x_tap_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.program_id := l_tap_rec.program_id;
      END IF;
      IF (x_tap_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.program_update_date := l_tap_rec.program_update_date;
      END IF;
      IF (x_tap_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.org_id := l_tap_rec.org_id;
      END IF;
      IF (x_tap_rec.CURRENCY_CONVERSION_TYPE = OKL_API.G_MISS_CHAR) THEN
        x_tap_rec.CURRENCY_CONVERSION_TYPE := l_tap_rec.CURRENCY_CONVERSION_TYPE;
      END IF;
      IF (x_tap_rec.CURRENCY_CONVERSION_RATE = OKL_API.G_MISS_NUM) THEN
        x_tap_rec.CURRENCY_CONVERSION_RATE := l_tap_rec.CURRENCY_CONVERSION_RATE;
      END IF;
      IF (x_tap_rec.CURRENCY_CONVERSION_DATE = OKL_API.G_MISS_DATE) THEN
        x_tap_rec.CURRENCY_CONVERSION_DATE := l_tap_rec.CURRENCY_CONVERSION_DATE;
      END IF;

      IF (x_tap_rec.VENDOR_ID = OKL_API.G_MISS_NUM) THEN
        x_tap_rec.VENDOR_ID := l_tap_rec.VENDOR_ID;
      END IF;

      IF (x_tap_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute_category := l_tap_rec.attribute_category;
      END IF;
      IF (x_tap_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute1 := l_tap_rec.attribute1;
      END IF;
      IF (x_tap_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute2 := l_tap_rec.attribute2;
      END IF;
      IF (x_tap_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute3 := l_tap_rec.attribute3;
      END IF;
      IF (x_tap_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute4 := l_tap_rec.attribute4;
      END IF;
      IF (x_tap_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute5 := l_tap_rec.attribute5;
      END IF;
      IF (x_tap_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute6 := l_tap_rec.attribute6;
      END IF;
      IF (x_tap_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute7 := l_tap_rec.attribute7;
      END IF;
      IF (x_tap_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute8 := l_tap_rec.attribute8;
      END IF;
      IF (x_tap_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute9 := l_tap_rec.attribute9;
      END IF;
      IF (x_tap_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute10 := l_tap_rec.attribute10;
      END IF;
      IF (x_tap_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute11 := l_tap_rec.attribute11;
      END IF;
      IF (x_tap_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute12 := l_tap_rec.attribute12;
      END IF;
      IF (x_tap_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute13 := l_tap_rec.attribute13;
      END IF;
      IF (x_tap_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute14 := l_tap_rec.attribute14;
      END IF;
      IF (x_tap_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.attribute15 := l_tap_rec.attribute15;
      END IF;
      IF (x_tap_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.created_by := l_tap_rec.created_by;
      END IF;
      IF (x_tap_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.creation_date := l_tap_rec.creation_date;
      END IF;
      IF (x_tap_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.last_updated_by := l_tap_rec.last_updated_by;
      END IF;
      IF (x_tap_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.last_update_date := l_tap_rec.last_update_date;
      END IF;
      IF (x_tap_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.last_update_login := l_tap_rec.last_update_login;
      END IF;
      IF (x_tap_rec.invoice_type = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.invoice_type := l_tap_rec.invoice_type;
      END IF;
      IF (x_tap_rec.pay_group_lookup_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.pay_group_lookup_code := l_tap_rec.pay_group_lookup_code;
      END IF;
      IF (x_tap_rec.vendor_invoice_number = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.vendor_invoice_number := l_tap_rec.vendor_invoice_number;
      END IF;
      IF (x_tap_rec.nettable_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tap_rec.nettable_yn := l_tap_rec.nettable_yn;
      END IF;
      IF (x_tap_rec.asset_tap_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.asset_tap_id := l_tap_rec.asset_tap_id;
      END IF;
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
      IF (x_tap_rec.legal_entity_id = OKL_API.G_MISS_NUM)
      THEN
        x_tap_rec.legal_entity_id := l_tap_rec.legal_entity_id;
      END IF;
      IF (x_tap_rec.transaction_date = OKL_API.G_MISS_DATE)
      THEN
        x_tap_rec.transaction_date := SYSDATE;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tap_rec IN  tap_rec_type,
      x_tap_rec OUT NOCOPY tap_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tap_rec := p_tap_rec;
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
      p_tap_rec,                         -- IN
      l_tap_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tap_rec, l_def_tap_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_AP_INVOICES_B
    SET CURRENCY_CODE = l_def_tap_rec.currency_code,
        PAYMENT_METHOD_CODE = l_def_tap_rec.payment_method_code,
        FUNDING_TYPE_CODE = l_def_tap_rec.funding_type_code,
        INVOICE_CATEGORY_CODE = l_def_tap_rec.invoice_category_code,
        IPVS_ID = l_def_tap_rec.ipvs_id,
        KHR_ID = l_def_tap_rec.khr_id,
        CCF_ID = l_def_tap_rec.ccf_id,
        CCT_ID = l_def_tap_rec.cct_id,
        CPLV_ID = l_def_tap_rec.cplv_id,
        POX_ID = l_def_tap_rec.pox_id,
        IPPT_ID = l_def_tap_rec.ippt_id,
        code_combination_id = l_def_tap_rec.code_combination_id,
        QTE_ID = l_def_tap_rec.qte_id,
        ART_ID = l_def_tap_rec.art_id,
        TCN_ID = l_def_tap_rec.tcn_id,
        TAP_ID_REVERSES = l_def_tap_rec.tap_id_reverses,
        DATE_ENTERED = l_def_tap_rec.date_entered,
        DATE_INVOICED = l_def_tap_rec.date_invoiced,
        AMOUNT = l_def_tap_rec.amount,
        TRX_STATUS_CODE = l_def_tap_rec.trx_status_code, -- Post Postgen 14,15
        SET_OF_BOOKS_ID = l_def_tap_rec.set_of_books_id, -- Post Postgen 14,15
        TRY_ID = l_def_tap_rec.try_id,                   -- Post Postgen 14,15
        OBJECT_VERSION_NUMBER = l_def_tap_rec.object_version_number,
        DATE_REQUISITION = l_def_tap_rec.date_requisition,
        DATE_FUNDING_APPROVED = l_def_tap_rec.date_funding_approved,
        INVOICE_NUMBER = l_def_tap_rec.invoice_number,
        DATE_GL = l_def_tap_rec.date_gl,
        WORKFLOW_YN = l_def_tap_rec.workflow_yn,
        MATCH_REQUIRED_YN = l_def_tap_rec.match_required_yn,
        IPT_FREQUENCY = l_def_tap_rec.ipt_frequency,
        CONSOLIDATE_YN = l_def_tap_rec.consolidate_yn,
        WAIT_VENDOR_INVOICE_YN = l_def_tap_rec.wait_vendor_invoice_yn,
        REQUEST_ID = l_def_tap_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_tap_rec.program_application_id,
        PROGRAM_ID = l_def_tap_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_tap_rec.program_update_date,
        ORG_ID = l_def_tap_rec.org_id,
        CURRENCY_CONVERSION_TYPE = l_def_tap_rec.CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE = l_def_tap_rec.CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE = l_def_tap_rec.CURRENCY_CONVERSION_DATE,
        VENDOR_ID          = l_def_tap_rec.vendor_id,
        ATTRIBUTE_CATEGORY = l_def_tap_rec.attribute_category,
        ATTRIBUTE1 = l_def_tap_rec.attribute1,
        ATTRIBUTE2 = l_def_tap_rec.attribute2,
        ATTRIBUTE3 = l_def_tap_rec.attribute3,
        ATTRIBUTE4 = l_def_tap_rec.attribute4,
        ATTRIBUTE5 = l_def_tap_rec.attribute5,
        ATTRIBUTE6 = l_def_tap_rec.attribute6,
        ATTRIBUTE7 = l_def_tap_rec.attribute7,
        ATTRIBUTE8 = l_def_tap_rec.attribute8,
        ATTRIBUTE9 = l_def_tap_rec.attribute9,
        ATTRIBUTE10 = l_def_tap_rec.attribute10,
        ATTRIBUTE11 = l_def_tap_rec.attribute11,
        ATTRIBUTE12 = l_def_tap_rec.attribute12,
        ATTRIBUTE13 = l_def_tap_rec.attribute13,
        ATTRIBUTE14 = l_def_tap_rec.attribute14,
        ATTRIBUTE15 = l_def_tap_rec.attribute15,
        CREATED_BY = l_def_tap_rec.created_by,
        CREATION_DATE = l_def_tap_rec.creation_date,
        LAST_UPDATED_BY = l_def_tap_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tap_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tap_rec.last_update_login,
        INVOICE_TYPE = l_def_tap_rec.invoice_type,
        PAY_GROUP_LOOKUP_CODE = l_def_tap_rec.pay_group_lookup_code,
        VENDOR_INVOICE_NUMBER = l_def_tap_rec.vendor_invoice_number,
        NETTABLE_YN = l_def_tap_rec.nettable_yn,
        ASSET_TAP_ID = l_def_tap_rec.asset_tap_id,                   -- Post Postgen 14,15
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
       legal_entity_id = l_def_tap_rec.legal_entity_id
       ,transaction_date = l_def_tap_rec.transaction_date
    WHERE ID = l_def_tap_rec.id;
    x_tap_rec := l_def_tap_rec;
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
  -------------------------------------------
  -- update_row for:OKL_TRX_AP_INVOICES_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ap_invoices_tl_rec   IN OklTrxApInvoicesTlRecType,
    x_okl_trx_ap_invoices_tl_rec   OUT NOCOPY OklTrxApInvoicesTlRecType) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType := p_okl_trx_ap_invoices_tl_rec;
    ldefokltrxapinvoicestlrec      OklTrxApInvoicesTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_trx_ap_invoices_tl_rec	IN OklTrxApInvoicesTlRecType,
      x_okl_trx_ap_invoices_tl_rec	OUT NOCOPY OklTrxApInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ap_invoices_tl_rec := p_okl_trx_ap_invoices_tl_rec;
      -- Get current database values
      l_okl_trx_ap_invoices_tl_rec := get_rec(p_okl_trx_ap_invoices_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ap_invoices_tl_rec.id := l_okl_trx_ap_invoices_tl_rec.id;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ap_invoices_tl_rec.language := l_okl_trx_ap_invoices_tl_rec.language;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ap_invoices_tl_rec.source_lang := l_okl_trx_ap_invoices_tl_rec.source_lang;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ap_invoices_tl_rec.sfwt_flag := l_okl_trx_ap_invoices_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_trx_ap_invoices_tl_rec.description := l_okl_trx_ap_invoices_tl_rec.description;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ap_invoices_tl_rec.created_by := l_okl_trx_ap_invoices_tl_rec.created_by;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_trx_ap_invoices_tl_rec.creation_date := l_okl_trx_ap_invoices_tl_rec.creation_date;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ap_invoices_tl_rec.last_updated_by := l_okl_trx_ap_invoices_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_trx_ap_invoices_tl_rec.last_update_date := l_okl_trx_ap_invoices_tl_rec.last_update_date;
      END IF;
      IF (x_okl_trx_ap_invoices_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_trx_ap_invoices_tl_rec.last_update_login := l_okl_trx_ap_invoices_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ap_invoices_tl_rec IN  OklTrxApInvoicesTlRecType,
      x_okl_trx_ap_invoices_tl_rec OUT NOCOPY OklTrxApInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ap_invoices_tl_rec := p_okl_trx_ap_invoices_tl_rec;
      x_okl_trx_ap_invoices_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_trx_ap_invoices_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_trx_ap_invoices_tl_rec,      -- IN
      l_okl_trx_ap_invoices_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_trx_ap_invoices_tl_rec, ldefokltrxapinvoicestlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_AP_INVOICES_TL
    SET DESCRIPTION = ldefokltrxapinvoicestlrec.description,
        SOURCE_LANG = ldefokltrxapinvoicestlrec.source_lang,
        CREATED_BY = ldefokltrxapinvoicestlrec.created_by,
        CREATION_DATE = ldefokltrxapinvoicestlrec.creation_date,
        LAST_UPDATED_BY = ldefokltrxapinvoicestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltrxapinvoicestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltrxapinvoicestlrec.last_update_login
    WHERE ID = ldefokltrxapinvoicestlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TRX_AP_INVOICES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltrxapinvoicestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');
    x_okl_trx_ap_invoices_tl_rec := ldefokltrxapinvoicestlrec;
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
  -- update_row for:OKL_TRX_AP_INVOICES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type,
    x_tapv_rec                     OUT NOCOPY tapv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tapv_rec                     tapv_rec_type := p_tapv_rec;
    l_def_tapv_rec                 tapv_rec_type;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
    lx_okl_trx_ap_invoices_tl_rec  OklTrxApInvoicesTlRecType;
    l_tap_rec                      tap_rec_type;
    lx_tap_rec                     tap_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tapv_rec	IN tapv_rec_type
    ) RETURN tapv_rec_type IS
      l_tapv_rec	tapv_rec_type := p_tapv_rec;
    BEGIN
      l_tapv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tapv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tapv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tapv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tapv_rec	IN tapv_rec_type,
      x_tapv_rec	OUT NOCOPY tapv_rec_type
    ) RETURN VARCHAR2 IS
      l_tapv_rec                     tapv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tapv_rec := p_tapv_rec;
      -- Get current database values
      l_tapv_rec := get_rec(p_tapv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tapv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.id := l_tapv_rec.id;
      END IF;
      IF (x_tapv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.object_version_number := l_tapv_rec.object_version_number;
      END IF;
      IF (x_tapv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.sfwt_flag := l_tapv_rec.sfwt_flag;
      END IF;
      IF (x_tapv_rec.cct_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.cct_id := l_tapv_rec.cct_id;
      END IF;
      IF (x_tapv_rec.currency_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.currency_code := l_tapv_rec.currency_code;
      END IF;
      IF (x_tapv_rec.ccf_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.ccf_id := l_tapv_rec.ccf_id;
      END IF;
      IF (x_tapv_rec.funding_type_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.funding_type_code := l_tapv_rec.funding_type_code;
      END IF;
      IF (x_tapv_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.khr_id := l_tapv_rec.khr_id;
      END IF;
      IF (x_tapv_rec.art_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.art_id := l_tapv_rec.art_id;
      END IF;
      IF (x_tapv_rec.tap_id_reverses = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.tap_id_reverses := l_tapv_rec.tap_id_reverses;
      END IF;
      IF (x_tapv_rec.ippt_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.ippt_id := l_tapv_rec.ippt_id;
      END IF;
      IF (x_tapv_rec.code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.code_combination_id := l_tapv_rec.code_combination_id;
      END IF;
      IF (x_tapv_rec.ipvs_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.ipvs_id := l_tapv_rec.ipvs_id;
      END IF;
      IF (x_tapv_rec.tcn_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.tcn_id := l_tapv_rec.tcn_id;
      END IF;
      IF (x_tapv_rec.vpa_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.vpa_id := l_tapv_rec.vpa_id;
      END IF;
      IF (x_tapv_rec.ipt_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.ipt_id := l_tapv_rec.ipt_id;
      END IF;
      IF (x_tapv_rec.qte_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.qte_id := l_tapv_rec.qte_id;
      END IF;
      IF (x_tapv_rec.invoice_category_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.invoice_category_code := l_tapv_rec.invoice_category_code;
      END IF;
      IF (x_tapv_rec.payment_method_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.payment_method_code := l_tapv_rec.payment_method_code;
      END IF;
      IF (x_tapv_rec.cplv_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.cplv_id := l_tapv_rec.cplv_id;
      END IF;

      --Start code added by pgomes on 19-NOV-2002
      IF (x_tapv_rec.pox_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.pox_id := l_tapv_rec.pox_id;
      END IF;
      --End code added by pgomes on 19-NOV-2002

      IF (x_tapv_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.amount := l_tapv_rec.amount;
      END IF;
      IF (x_tapv_rec.date_invoiced = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.date_invoiced := l_tapv_rec.date_invoiced;
      END IF;
      IF (x_tapv_rec.invoice_number = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.invoice_number := l_tapv_rec.invoice_number;
      END IF;
      IF (x_tapv_rec.date_funding_approved = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.date_funding_approved := l_tapv_rec.date_funding_approved;
      END IF;
      IF (x_tapv_rec.date_gl = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.date_gl := l_tapv_rec.date_gl;
      END IF;
      IF (x_tapv_rec.workflow_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.workflow_yn := l_tapv_rec.workflow_yn;
      END IF;
      IF (x_tapv_rec.match_required_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.match_required_yn := l_tapv_rec.match_required_yn;
      END IF;
      IF (x_tapv_rec.ipt_frequency = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.ipt_frequency := l_tapv_rec.ipt_frequency;
      END IF;
      IF (x_tapv_rec.consolidate_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.consolidate_yn := l_tapv_rec.consolidate_yn;
      END IF;
      IF (x_tapv_rec.wait_vendor_invoice_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.wait_vendor_invoice_yn := l_tapv_rec.wait_vendor_invoice_yn;
      END IF;
      IF (x_tapv_rec.date_requisition = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.date_requisition := l_tapv_rec.date_requisition;
      END IF;
      IF (x_tapv_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.description := l_tapv_rec.description;
      END IF;
      IF (x_tapv_rec.CURRENCY_CONVERSION_TYPE = OKL_API.G_MISS_CHAR) THEN
        x_tapv_rec.CURRENCY_CONVERSION_TYPE := l_tapv_rec.CURRENCY_CONVERSION_TYPE;
      END IF;
      IF (x_tapv_rec.CURRENCY_CONVERSION_RATE = OKL_API.G_MISS_NUM) THEN
        x_tapv_rec.CURRENCY_CONVERSION_RATE := l_tapv_rec.CURRENCY_CONVERSION_RATE;
      END IF;
      IF (x_tapv_rec.CURRENCY_CONVERSION_DATE = OKL_API.G_MISS_DATE) THEN
        x_tapv_rec.CURRENCY_CONVERSION_DATE := l_tapv_rec.CURRENCY_CONVERSION_DATE;
      END IF;
      IF (x_tapv_rec.VENDOR_ID = OKL_API.G_MISS_NUM) THEN
        x_tapv_rec.VENDOR_ID := l_tapv_rec.VENDOR_ID;
      END IF;
      IF (x_tapv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute_category := l_tapv_rec.attribute_category;
      END IF;
      IF (x_tapv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute1 := l_tapv_rec.attribute1;
      END IF;
      IF (x_tapv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute2 := l_tapv_rec.attribute2;
      END IF;
      IF (x_tapv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute3 := l_tapv_rec.attribute3;
      END IF;
      IF (x_tapv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute4 := l_tapv_rec.attribute4;
      END IF;
      IF (x_tapv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute5 := l_tapv_rec.attribute5;
      END IF;
      IF (x_tapv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute6 := l_tapv_rec.attribute6;
      END IF;
      IF (x_tapv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute7 := l_tapv_rec.attribute7;
      END IF;
      IF (x_tapv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute8 := l_tapv_rec.attribute8;
      END IF;
      IF (x_tapv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute9 := l_tapv_rec.attribute9;
      END IF;
      IF (x_tapv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute10 := l_tapv_rec.attribute10;
      END IF;
      IF (x_tapv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute11 := l_tapv_rec.attribute11;
      END IF;
      IF (x_tapv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute12 := l_tapv_rec.attribute12;
      END IF;
      IF (x_tapv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute13 := l_tapv_rec.attribute13;
      END IF;
      IF (x_tapv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute14 := l_tapv_rec.attribute14;
      END IF;
      IF (x_tapv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.attribute15 := l_tapv_rec.attribute15;
      END IF;
      IF (x_tapv_rec.date_entered = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.date_entered := l_tapv_rec.date_entered;
      END IF;
      -- Start Post Postgen 14,15
      IF (x_tapv_rec.trx_status_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.trx_status_code := l_tapv_rec.trx_status_code;
      END IF;
      IF (x_tapv_rec.set_of_books_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.set_of_books_id := l_tapv_rec.set_of_books_id;
      END IF;
      IF (x_tapv_rec.try_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.try_id := l_tapv_rec.try_id;
      END IF;
      -- End Post Postgen 14,15
      IF (x_tapv_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.request_id := l_tapv_rec.request_id;
      END IF;
      IF (x_tapv_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.program_application_id := l_tapv_rec.program_application_id;
      END IF;
      IF (x_tapv_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.program_id := l_tapv_rec.program_id;
      END IF;
      IF (x_tapv_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.program_update_date := l_tapv_rec.program_update_date;
      END IF;
      IF (x_tapv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.org_id := l_tapv_rec.org_id;
      END IF;
      IF (x_tapv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.created_by := l_tapv_rec.created_by;
      END IF;
      IF (x_tapv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.creation_date := l_tapv_rec.creation_date;
      END IF;
      IF (x_tapv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.last_updated_by := l_tapv_rec.last_updated_by;
      END IF;
      IF (x_tapv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.last_update_date := l_tapv_rec.last_update_date;
      END IF;
      IF (x_tapv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.last_update_login := l_tapv_rec.last_update_login;
      END IF;
      IF (x_tapv_rec.invoice_type = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.invoice_type := l_tapv_rec.invoice_type;
      END IF;
      IF (x_tapv_rec.pay_group_lookup_code = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.pay_group_lookup_code := l_tapv_rec.pay_group_lookup_code;
      END IF;
      IF (x_tapv_rec.vendor_invoice_number = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.vendor_invoice_number := l_tapv_rec.vendor_invoice_number;
      END IF;
      IF (x_tapv_rec.nettable_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_tapv_rec.nettable_yn := l_tapv_rec.nettable_yn;
      END IF;
      IF (x_tapv_rec.asset_tap_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.asset_tap_id := l_tapv_rec.asset_tap_id;
      END IF;

 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
      IF (x_tapv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
      THEN
        x_tapv_rec.legal_entity_id := l_tapv_rec.legal_entity_id;
      END IF;

      IF (x_tapv_rec.transaction_date = OKL_API.G_MISS_DATE)
      THEN
        x_tapv_rec.transaction_date := l_tapv_rec.transaction_date;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_tapv_rec IN  tapv_rec_type,
      x_tapv_rec OUT NOCOPY tapv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tapv_rec := p_tapv_rec;
      x_tapv_rec.OBJECT_VERSION_NUMBER := NVL(x_tapv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      -- Begin PostGen-7
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_tapv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_tapv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_tapv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_tapv_rec.program_update_date,SYSDATE)
      INTO
        x_tapv_rec.request_id,
        x_tapv_rec.program_application_id,
        x_tapv_rec.program_id,
        x_tapv_rec.program_update_date
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
      p_tapv_rec,                        -- IN
      l_tapv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tapv_rec, l_def_tapv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tapv_rec := fill_who_columns(l_def_tapv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tapv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tapv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tapv_rec, l_okl_trx_ap_invoices_tl_rec);
    migrate(l_def_tapv_rec, l_tap_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ap_invoices_tl_rec,
      lx_okl_trx_ap_invoices_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_trx_ap_invoices_tl_rec, l_def_tapv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tap_rec,
      lx_tap_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tap_rec, l_def_tapv_rec);
    x_tapv_rec := l_def_tapv_rec;
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
  -- PL/SQL TBL update_row for:TAPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type,
    x_tapv_tbl                     OUT NOCOPY tapv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tapv_tbl.COUNT > 0) THEN
      i := p_tapv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tapv_rec                     => p_tapv_tbl(i),
          x_tapv_rec                     => x_tapv_tbl(i));
        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9
        EXIT WHEN (i = p_tapv_tbl.LAST);
        i := p_tapv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKL_TRX_AP_INVOICES_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tap_rec                      IN tap_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tap_rec                      tap_rec_type:= p_tap_rec;
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
    DELETE FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = l_tap_rec.id;
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
  -------------------------------------------
  -- delete_row for:OKL_TRX_AP_INVOICES_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_trx_ap_invoices_tl_rec   IN OklTrxApInvoicesTlRecType) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType:= p_okl_trx_ap_invoices_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_TRX_AP_INVOICES_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_trx_ap_invoices_tl_rec IN  OklTrxApInvoicesTlRecType,
      x_okl_trx_ap_invoices_tl_rec OUT NOCOPY OklTrxApInvoicesTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_trx_ap_invoices_tl_rec := p_okl_trx_ap_invoices_tl_rec;
      x_okl_trx_ap_invoices_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_trx_ap_invoices_tl_rec,      -- IN
      l_okl_trx_ap_invoices_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_AP_INVOICES_TL
     WHERE ID = l_okl_trx_ap_invoices_tl_rec.id;
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
  -- delete_row for:OKL_TRX_AP_INVOICES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_tapv_rec                     tapv_rec_type := p_tapv_rec;
    l_okl_trx_ap_invoices_tl_rec   OklTrxApInvoicesTlRecType;
    l_tap_rec                      tap_rec_type;
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
    migrate(l_tapv_rec, l_okl_trx_ap_invoices_tl_rec);
    migrate(l_tapv_rec, l_tap_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_trx_ap_invoices_tl_rec
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
      l_tap_rec
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
  -- PL/SQL TBL delete_row for:TAPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tapv_tbl.COUNT > 0) THEN
      i := p_tapv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tapv_rec                     => p_tapv_tbl(i));
        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9
        EXIT WHEN (i = p_tapv_tbl.LAST);
        i := p_tapv_tbl.NEXT(i);
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
END OKL_TAP_PVT;

/

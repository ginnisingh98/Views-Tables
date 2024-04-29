--------------------------------------------------------
--  DDL for Package Body OKL_XLP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XLP_PVT" AS
/* $Header: OKLSXLPB.pls 120.3 2007/08/08 12:56:43 arajagop ship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages and Variables                 = Done! Msg=5; Var=3
  -- BODY:
  -- 0. Check for Not Null Columns                    = Done! 1, n/a:sfwt_flag
  -- 1. Check for Not Null Primary Keys               = Done! 1
  -- 2. Check for Not Null Foreign Keys               = Done! 1
  -- 3. Validity of Foreign Keys                      = Done! 3 + 1 (not-null); OKX=2
  -- 4. Validity of Unique Keys                       = N/A, No Unique Keys
  -- 5. Validity of Org_id                            = Done!
  -- 6. Added domain validation                       = N/A, No Domain Values Used
  -- 7. Added the Concurrent Manager Columns (p104)   = Done! 2=views:v_insert_row,v_update_row
  -- 8. Validate fnd_lookup code using OKL_UTIL pkg   = N/A, No FK to fnd_lookups
  -- 9. Capture most severe error in loops (p103)     = Done! 5 loops (except l_lang_rec)
  --10. Reduce use of SYSDATE fill_who_columns (p104) = Done! 1 (for insert)
  --11. Fix Migrate Parameter p_to IN OUT (p104)      = Done! 4
  --12. Call validate procs. in Validate_Attributes   = Done! 7
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id - PostGen-1
  ---------------------------------------------------------------------------
  PROCEDURE validate_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.id IS NULL) OR (p_xlpv_rec.id = OKL_Api.G_MISS_NUM) THEN

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
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.object_version_number IS NULL)
       OR (p_xlpv_rec.object_version_number = OKL_Api.G_MISS_NUM) THEN

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
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.org_id IS NULL) OR (p_xlpv_rec.org_id = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'org_id'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSE

      x_return_status := OKL_UTIL.CHECK_ORG_ID(p_xlpv_rec.org_id);

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
  -- PROCEDURE validate_fk_xpi_id_details - PostGen-2 PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_xpi_id_details
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_xpiv_csr IS
      SELECT 'x'
      FROM OKL_EXT_PAY_INVS_V
      WHERE id = p_xlpv_rec.xpi_id_details;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.xpi_id_details IS NULL)
      OR (p_xlpv_rec.xpi_id_details = OKL_Api.G_MISS_NUM) THEN

      OKL_Api.SET_MESSAGE
            ( p_app_name     => g_app_name,
              p_msg_name     => g_required_value,
              p_token1       => g_col_name_token,
              p_token1_value => 'xpi_id_details'
            ) ;

      x_return_status := OKL_Api.G_RET_STS_ERROR;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    open  l_xpiv_csr;
    fetch l_xpiv_csr into l_dummy_var;
    close l_xpiv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'xpi_id_details',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_XTL_PAY_INVS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKL_EXT_PAY_INVS_V');

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
      IF l_xpiv_csr%ISOPEN THEN
         CLOSE l_xpiv_csr;
      END IF;


  END validate_fk_xpi_id_details;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_tpl_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_tpl_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_tplv_csr IS
      SELECT 'x'
      FROM OKL_TXL_AP_INV_LNS_V
      WHERE id = p_xlpv_rec.tpl_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.tpl_id IS NOT NULL) THEN

      IF(p_xlpv_rec.tpl_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'tpl_id'
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
               p_token1_value     => 'tpl_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_XTL_PAY_INVS_V',
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


  END validate_fk_tpl_id;

------Validate Tap Id
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_tap_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_tap_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_tapv_csr IS
      SELECT 'x'
      FROM OKL_TRX_AP_INVOICES_V
      WHERE id = p_xlpv_rec.tap_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.tap_id IS NOT NULL) THEN

      IF(p_xlpv_rec.tap_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'tap_id'
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
               p_token1_value     => 'tap_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_XTL_PAY_INVS_V',
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
      IF l_tapv_csr%ISOPEN THEN
         CLOSE l_tapv_csr;
      END IF;


  END validate_fk_tap_id;


/*
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_pid_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_pid_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_pidv_csr IS
      SELECT 'x'
      FROM OKX_PYE_INV_DSTBTNS_V
      WHERE id = p_xlpv_rec.pid_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.pid_id IS NOT NULL) THEN

      IF(p_xlpv_rec.pid_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'pid_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_pidv_csr;
    fetch l_pidv_csr into l_dummy_var;
    close l_pidv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'pid_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_XTL_PAY_INVS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKX_PYE_INV_DSTBTNS_V'
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

      -- verfiy that cursor was closed
      IF l_pidv_csr%ISOPEN THEN
         CLOSE l_pidv_csr;
      END IF;


  END validate_fk_pid_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fk_ibi_id - PostGen-3
  ---------------------------------------------------------------------------
  PROCEDURE validate_fk_ibi_id
            ( x_return_status          OUT NOCOPY       VARCHAR2,
              p_xlpv_rec               IN        xlpv_rec_type
            ) IS

    l_return_status            varchar2(1)    := OKL_Api.G_RET_STS_SUCCESS;
    l_dummy_var                VARCHAR2(1)    := '?';

    CURSOR l_ibiv_csr IS
      SELECT 'x'
      FROM OKX_B_ORD_LN_DSTS_V
      WHERE id = p_xlpv_rec.ibi_id;

  BEGIN

    x_return_status := OKL_Api.G_RET_STS_SUCCESS;

    IF(p_xlpv_rec.ibi_id IS NOT NULL) THEN

      IF(p_xlpv_rec.ibi_id = OKL_Api.G_MISS_NUM) THEN

        OKL_Api.SET_MESSAGE
              ( p_app_name     => g_app_name,
                p_msg_name     => g_invalid_value,
                p_token1       => g_col_name_token,
                p_token1_value => 'ibi_id'
              ) ;

        x_return_status := OKL_Api.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;   -- skip further validations due to error

      END IF;

    ELSE

      RAISE G_EXCEPTION_HALT_VALIDATION;     -- no further validations required when NULL

    END IF;

    open  l_ibiv_csr;
    fetch l_ibiv_csr into l_dummy_var;
    close l_ibiv_csr;

    IF l_dummy_var = '?' THEN

       OKL_Api.SET_MESSAGE
             ( p_app_name         => g_app_name,
               p_msg_name         => g_no_parent_record,
               p_token1           => g_col_name_token,
               p_token1_value     => 'ibi_id',
               p_token2           => g_child_table_token,
               p_token2_value     => 'OKL_XTL_PAY_INVS_V',
               p_token3           => g_parent_table_token,
               p_token3_value     => 'OKX_B_ORD_LN_DSTS_V'
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

      -- verfiy that cursor was closed
      IF l_ibiv_csr%ISOPEN THEN
         CLOSE l_ibiv_csr;
      END IF;


  END validate_fk_ibi_id;
*/
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(OKc_p_util.raw_to_number(sys_guid()));
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
    DELETE FROM OKL_XTL_PAY_INVS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_XTL_PAY_INVS_ALL_B B
         WHERE B.ID = T.ID
         AND T.LANGUAGE = USERENV('LANG')
        );

    UPDATE OKL_XTL_PAY_INVS_TL T SET (
        DESCRIPTION,
        STREAM_TYPE) = (SELECT
                                  B.DESCRIPTION,
                                  B.STREAM_TYPE
                                FROM OKL_XTL_PAY_INVS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_XTL_PAY_INVS_TL SUBB, OKL_XTL_PAY_INVS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.STREAM_TYPE <> SUBT.STREAM_TYPE
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.STREAM_TYPE IS NULL AND SUBT.STREAM_TYPE IS NOT NULL)
                      OR (SUBB.STREAM_TYPE IS NOT NULL AND SUBT.STREAM_TYPE IS NULL)
              ));

    INSERT INTO OKL_XTL_PAY_INVS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        STREAM_TYPE,
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
            B.STREAM_TYPE,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_XTL_PAY_INVS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_XTL_PAY_INVS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_PAY_INVS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xlp_rec                      IN xlp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xlp_rec_type IS
    CURSOR okl_xtl_pay_invs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            XPI_ID_DETAILS,
            PID_ID,
            IBI_ID,
            TPL_ID,
            TAP_ID,
            OBJECT_VERSION_NUMBER,
            INVOICE_LINE_ID,
            LINE_NUMBER,
            LINE_TYPE,
            AMOUNT,
            ACCOUNTING_DATE,
            DIST_CODE_COMBINATION_ID,
            TAX_CODE,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Pay_Invs_B
     WHERE okl_xtl_pay_invs_b.id = p_id;
    l_okl_xtl_pay_invs_b_pk        okl_xtl_pay_invs_b_pk_csr%ROWTYPE;
    l_xlp_rec                      xlp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xtl_pay_invs_b_pk_csr (p_xlp_rec.id);
    FETCH okl_xtl_pay_invs_b_pk_csr INTO
              l_xlp_rec.ID,
              l_xlp_rec.XPI_ID_DETAILS,
              l_xlp_rec.PID_ID,
              l_xlp_rec.IBI_ID,
              l_xlp_rec.TPL_ID,
              l_xlp_rec.TAP_ID,
              l_xlp_rec.OBJECT_VERSION_NUMBER,
              l_xlp_rec.INVOICE_LINE_ID,
              l_xlp_rec.LINE_NUMBER,
              l_xlp_rec.LINE_TYPE,
              l_xlp_rec.AMOUNT,
              l_xlp_rec.ACCOUNTING_DATE,
              l_xlp_rec.DIST_CODE_COMBINATION_ID,
              l_xlp_rec.TAX_CODE,
              l_xlp_rec.REQUEST_ID,
              l_xlp_rec.PROGRAM_APPLICATION_ID,
              l_xlp_rec.PROGRAM_ID,
              l_xlp_rec.PROGRAM_UPDATE_DATE,
              l_xlp_rec.ORG_ID,
              l_xlp_rec.ATTRIBUTE_CATEGORY,
              l_xlp_rec.ATTRIBUTE1,
              l_xlp_rec.ATTRIBUTE2,
              l_xlp_rec.ATTRIBUTE3,
              l_xlp_rec.ATTRIBUTE4,
              l_xlp_rec.ATTRIBUTE5,
              l_xlp_rec.ATTRIBUTE6,
              l_xlp_rec.ATTRIBUTE7,
              l_xlp_rec.ATTRIBUTE8,
              l_xlp_rec.ATTRIBUTE9,
              l_xlp_rec.ATTRIBUTE10,
              l_xlp_rec.ATTRIBUTE11,
              l_xlp_rec.ATTRIBUTE12,
              l_xlp_rec.ATTRIBUTE13,
              l_xlp_rec.ATTRIBUTE14,
              l_xlp_rec.ATTRIBUTE15,
              l_xlp_rec.CREATED_BY,
              l_xlp_rec.CREATION_DATE,
              l_xlp_rec.LAST_UPDATED_BY,
              l_xlp_rec.LAST_UPDATE_DATE,
              l_xlp_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xtl_pay_invs_b_pk_csr%NOTFOUND;
    CLOSE okl_xtl_pay_invs_b_pk_csr;
    RETURN(l_xlp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xlp_rec                      IN xlp_rec_type
  ) RETURN xlp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xlp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_PAY_INVS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_xtl_pay_invs_tl_rec      IN okl_xtl_pay_invs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_xtl_pay_invs_tl_rec_type IS
    CURSOR okl_xtl_pay_invs_tl_pk_csr (p_id                 IN NUMBER,
                                       p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            STREAM_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Pay_Invs_Tl
     WHERE okl_xtl_pay_invs_tl.id = p_id
       AND okl_xtl_pay_invs_tl.language = p_language;
    l_okl_xtl_pay_invs_tl_pk       okl_xtl_pay_invs_tl_pk_csr%ROWTYPE;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xtl_pay_invs_tl_pk_csr (p_okl_xtl_pay_invs_tl_rec.id,
                                     p_okl_xtl_pay_invs_tl_rec.language);
    FETCH okl_xtl_pay_invs_tl_pk_csr INTO
              l_okl_xtl_pay_invs_tl_rec.ID,
              l_okl_xtl_pay_invs_tl_rec.LANGUAGE,
              l_okl_xtl_pay_invs_tl_rec.SOURCE_LANG,
              l_okl_xtl_pay_invs_tl_rec.SFWT_FLAG,
              l_okl_xtl_pay_invs_tl_rec.DESCRIPTION,
              l_okl_xtl_pay_invs_tl_rec.STREAM_TYPE,
              l_okl_xtl_pay_invs_tl_rec.CREATED_BY,
              l_okl_xtl_pay_invs_tl_rec.CREATION_DATE,
              l_okl_xtl_pay_invs_tl_rec.LAST_UPDATED_BY,
              l_okl_xtl_pay_invs_tl_rec.LAST_UPDATE_DATE,
              l_okl_xtl_pay_invs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xtl_pay_invs_tl_pk_csr%NOTFOUND;
    CLOSE okl_xtl_pay_invs_tl_pk_csr;
    RETURN(l_okl_xtl_pay_invs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_xtl_pay_invs_tl_rec      IN okl_xtl_pay_invs_tl_rec_type
  ) RETURN okl_xtl_pay_invs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_xtl_pay_invs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_PAY_INVS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xlpv_rec                     IN xlpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xlpv_rec_type IS
    CURSOR okl_xlpv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            TPL_ID,
            TAP_ID,
            PID_ID,
            IBI_ID,
            XPI_ID_DETAILS,
            INVOICE_LINE_ID,
            LINE_NUMBER,
            LINE_TYPE,
            AMOUNT,
            ACCOUNTING_DATE,
            DESCRIPTION,
            DIST_CODE_COMBINATION_ID,
            TAX_CODE,
            STREAM_TYPE,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Pay_Invs_V
     WHERE okl_xtl_pay_invs_v.id = p_id;
    l_okl_xlpv_pk                  okl_xlpv_pk_csr%ROWTYPE;
    l_xlpv_rec                     xlpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xlpv_pk_csr (p_xlpv_rec.id);
    FETCH okl_xlpv_pk_csr INTO
              l_xlpv_rec.ID,
              l_xlpv_rec.OBJECT_VERSION_NUMBER,
              l_xlpv_rec.SFWT_FLAG,
              l_xlpv_rec.TPL_ID,
              l_xlpv_rec.TAP_ID,
              l_xlpv_rec.PID_ID,
              l_xlpv_rec.IBI_ID,
              l_xlpv_rec.XPI_ID_DETAILS,
              l_xlpv_rec.INVOICE_LINE_ID,
              l_xlpv_rec.LINE_NUMBER,
              l_xlpv_rec.LINE_TYPE,
              l_xlpv_rec.AMOUNT,
              l_xlpv_rec.ACCOUNTING_DATE,
              l_xlpv_rec.DESCRIPTION,
              l_xlpv_rec.DIST_CODE_COMBINATION_ID,
              l_xlpv_rec.TAX_CODE,
              l_xlpv_rec.STREAM_TYPE,
              l_xlpv_rec.ATTRIBUTE_CATEGORY,
              l_xlpv_rec.ATTRIBUTE1,
              l_xlpv_rec.ATTRIBUTE2,
              l_xlpv_rec.ATTRIBUTE3,
              l_xlpv_rec.ATTRIBUTE4,
              l_xlpv_rec.ATTRIBUTE5,
              l_xlpv_rec.ATTRIBUTE6,
              l_xlpv_rec.ATTRIBUTE7,
              l_xlpv_rec.ATTRIBUTE8,
              l_xlpv_rec.ATTRIBUTE9,
              l_xlpv_rec.ATTRIBUTE10,
              l_xlpv_rec.ATTRIBUTE11,
              l_xlpv_rec.ATTRIBUTE12,
              l_xlpv_rec.ATTRIBUTE13,
              l_xlpv_rec.ATTRIBUTE14,
              l_xlpv_rec.ATTRIBUTE15,
              l_xlpv_rec.REQUEST_ID,
              l_xlpv_rec.PROGRAM_APPLICATION_ID,
              l_xlpv_rec.PROGRAM_ID,
              l_xlpv_rec.PROGRAM_UPDATE_DATE,
              l_xlpv_rec.ORG_ID,
              l_xlpv_rec.CREATED_BY,
              l_xlpv_rec.CREATION_DATE,
              l_xlpv_rec.LAST_UPDATED_BY,
              l_xlpv_rec.LAST_UPDATE_DATE,
              l_xlpv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xlpv_pk_csr%NOTFOUND;
    CLOSE okl_xlpv_pk_csr;
    RETURN(l_xlpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xlpv_rec                     IN xlpv_rec_type
  ) RETURN xlpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xlpv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_XTL_PAY_INVS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_xlpv_rec	IN xlpv_rec_type
  ) RETURN xlpv_rec_type IS
    l_xlpv_rec	xlpv_rec_type := p_xlpv_rec;
  BEGIN
    IF (l_xlpv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.object_version_number := NULL;
    END IF;
    IF (l_xlpv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_xlpv_rec.tpl_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.tpl_id := NULL;
    END IF;
    IF (l_xlpv_rec.tap_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.tap_id := NULL;
    END IF;
    IF (l_xlpv_rec.pid_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.pid_id := NULL;
    END IF;
    IF (l_xlpv_rec.ibi_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.ibi_id := NULL;
    END IF;
    IF (l_xlpv_rec.xpi_id_details = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.xpi_id_details := NULL;
    END IF;
    IF (l_xlpv_rec.invoice_line_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.invoice_line_id := NULL;
    END IF;
    IF (l_xlpv_rec.line_number = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.line_number := NULL;
    END IF;
    IF (l_xlpv_rec.line_type = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.line_type := NULL;
    END IF;
    IF (l_xlpv_rec.amount = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.amount := NULL;
    END IF;
    IF (l_xlpv_rec.accounting_date = OKL_API.G_MISS_DATE) THEN
      l_xlpv_rec.accounting_date := NULL;
    END IF;
    IF (l_xlpv_rec.description = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.description := NULL;
    END IF;
    IF (l_xlpv_rec.dist_code_combination_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.dist_code_combination_id := NULL;
    END IF;
    IF (l_xlpv_rec.tax_code = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.tax_code := NULL;
    END IF;
    IF (l_xlpv_rec.stream_type = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.stream_type := NULL;
    END IF;
    IF (l_xlpv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute_category := NULL;
    END IF;
    IF (l_xlpv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute1 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute2 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute3 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute4 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute5 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute6 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute7 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute8 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute9 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute10 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute11 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute12 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute13 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute14 := NULL;
    END IF;
    IF (l_xlpv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_xlpv_rec.attribute15 := NULL;
    END IF;
    IF (l_xlpv_rec.request_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.request_id := NULL;
    END IF;
    IF (l_xlpv_rec.program_application_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.program_application_id := NULL;
    END IF;
    IF (l_xlpv_rec.program_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.program_id := NULL;
    END IF;
    IF (l_xlpv_rec.program_update_date = OKL_API.G_MISS_DATE) THEN
      l_xlpv_rec.program_update_date := NULL;
    END IF;
    IF (l_xlpv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.org_id := NULL;
    END IF;
    IF (l_xlpv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.created_by := NULL;
    END IF;
    IF (l_xlpv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_xlpv_rec.creation_date := NULL;
    END IF;
    IF (l_xlpv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_xlpv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_xlpv_rec.last_update_date := NULL;
    END IF;
    IF (l_xlpv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_xlpv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_xlpv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes for:OKL_XTL_PAY_INVS_V : Modified for PostGen-12
  ---------------------------------------------------------------------------------
  FUNCTION Validate_Attributes
         ( p_xlpv_rec IN  xlpv_rec_type
         ) RETURN VARCHAR2 IS

    x_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;
    l_return_status	         VARCHAR2(1)         :=   OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    validate_id ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_org_id
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_xpi_id_details
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_tpl_id
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_tap_id
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

/*
    validate_fk_pid_id
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fk_ibi_id
                ( x_return_status      => l_return_status
                , p_xlpv_rec           => p_xlpv_rec
                ) ;
    -- Store the highest degree of error
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
 */

    RETURN x_return_status;  -- Return status to the caller

  /*------------------------------- TAPI Generated Code ---------------------------------------+
    IF p_xlpv_rec.id = OKL_API.G_MISS_NUM OR
       p_xlpv_rec.id IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_xlpv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_xlpv_rec.object_version_number IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_xlpv_rec.xpi_id_details = OKL_API.G_MISS_NUM OR
          p_xlpv_rec.xpi_id_details IS NULL
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'xpi_id_details');
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

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_XTL_PAY_INVS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_xlpv_rec IN xlpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN xlpv_rec_type,
    p_to	IN OUT NOCOPY xlp_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.xpi_id_details := p_from.xpi_id_details;
    p_to.pid_id := p_from.pid_id;
    p_to.ibi_id := p_from.ibi_id;
    p_to.tpl_id := p_from.tpl_id;
    p_to.tap_id := p_from.tap_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.invoice_line_id := p_from.invoice_line_id;
    p_to.line_number := p_from.line_number;
    p_to.line_type := p_from.line_type;
    p_to.amount := p_from.amount;
    p_to.accounting_date := p_from.accounting_date;
    p_to.dist_code_combination_id := p_from.dist_code_combination_id;
    p_to.tax_code := p_from.tax_code;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN xlp_rec_type,
    p_to	IN OUT NOCOPY xlpv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.xpi_id_details := p_from.xpi_id_details;
    p_to.pid_id := p_from.pid_id;
    p_to.ibi_id := p_from.ibi_id;
    p_to.tpl_id := p_from.tpl_id;
    p_to.tap_id := p_from.tap_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.invoice_line_id := p_from.invoice_line_id;
    p_to.line_number := p_from.line_number;
    p_to.line_type := p_from.line_type;
    p_to.amount := p_from.amount;
    p_to.accounting_date := p_from.accounting_date;
    p_to.dist_code_combination_id := p_from.dist_code_combination_id;
    p_to.tax_code := p_from.tax_code;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN xlpv_rec_type,
    p_to	IN OUT NOCOPY okl_xtl_pay_invs_tl_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.stream_type := p_from.stream_type;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_xtl_pay_invs_tl_rec_type,
    p_to	IN OUT NOCOPY xlpv_rec_type     -- PostGen-11
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.stream_type := p_from.stream_type;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_XTL_PAY_INVS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlpv_rec                     xlpv_rec_type := p_xlpv_rec;
    l_xlp_rec                      xlp_rec_type;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_xlpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_xlpv_rec);
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
  -- PL/SQL TBL validate_row for:XLPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlpv_tbl.COUNT > 0) THEN
      i := p_xlpv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlpv_rec                     => p_xlpv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xlpv_tbl.LAST);
        i := p_xlpv_tbl.NEXT(i);
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
  ---------------------------------------
  -- insert_row for:OKL_XTL_PAY_INVS_B --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlp_rec                      IN xlp_rec_type,
    x_xlp_rec                      OUT NOCOPY xlp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlp_rec                      xlp_rec_type := p_xlp_rec;
    l_def_xlp_rec                  xlp_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xlp_rec IN  xlp_rec_type,
      x_xlp_rec OUT NOCOPY xlp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlp_rec := p_xlp_rec;
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
      p_xlp_rec,                         -- IN
      l_xlp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_XTL_PAY_INVS_B(
        id,
        xpi_id_details,
        pid_id,
        ibi_id,
        tpl_id,
        tap_id,
        object_version_number,
        invoice_line_id,
        line_number,
        line_type,
        amount,
        accounting_date,
        dist_code_combination_id,
        tax_code,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
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
        last_update_login)
      VALUES (
        l_xlp_rec.id,
        l_xlp_rec.xpi_id_details,
        l_xlp_rec.pid_id,
        l_xlp_rec.ibi_id,
        l_xlp_rec.tpl_id,
        l_xlp_rec.tap_id,
        l_xlp_rec.object_version_number,
        l_xlp_rec.invoice_line_id,
        l_xlp_rec.line_number,
        l_xlp_rec.line_type,
        l_xlp_rec.amount,
        l_xlp_rec.accounting_date,
        l_xlp_rec.dist_code_combination_id,
        l_xlp_rec.tax_code,
        l_xlp_rec.request_id,
        l_xlp_rec.program_application_id,
        l_xlp_rec.program_id,
        l_xlp_rec.program_update_date,
        l_xlp_rec.org_id,
        l_xlp_rec.attribute_category,
        l_xlp_rec.attribute1,
        l_xlp_rec.attribute2,
        l_xlp_rec.attribute3,
        l_xlp_rec.attribute4,
        l_xlp_rec.attribute5,
        l_xlp_rec.attribute6,
        l_xlp_rec.attribute7,
        l_xlp_rec.attribute8,
        l_xlp_rec.attribute9,
        l_xlp_rec.attribute10,
        l_xlp_rec.attribute11,
        l_xlp_rec.attribute12,
        l_xlp_rec.attribute13,
        l_xlp_rec.attribute14,
        l_xlp_rec.attribute15,
        l_xlp_rec.created_by,
        l_xlp_rec.creation_date,
        l_xlp_rec.last_updated_by,
        l_xlp_rec.last_update_date,
        l_xlp_rec.last_update_login);
    -- Set OUT values
    x_xlp_rec := l_xlp_rec;
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
  -- insert_row for:OKL_XTL_PAY_INVS_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_pay_invs_tl_rec      IN okl_xtl_pay_invs_tl_rec_type,
    x_okl_xtl_pay_invs_tl_rec      OUT NOCOPY okl_xtl_pay_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type := p_okl_xtl_pay_invs_tl_rec;
    ldefoklxtlpayinvstlrec         okl_xtl_pay_invs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_xtl_pay_invs_tl_rec IN  okl_xtl_pay_invs_tl_rec_type,
      x_okl_xtl_pay_invs_tl_rec OUT NOCOPY okl_xtl_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_pay_invs_tl_rec := p_okl_xtl_pay_invs_tl_rec;
      x_okl_xtl_pay_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_xtl_pay_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_xtl_pay_invs_tl_rec,         -- IN
      l_okl_xtl_pay_invs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_xtl_pay_invs_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_XTL_PAY_INVS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          stream_type,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_xtl_pay_invs_tl_rec.id,
          l_okl_xtl_pay_invs_tl_rec.language,
          l_okl_xtl_pay_invs_tl_rec.source_lang,
          l_okl_xtl_pay_invs_tl_rec.sfwt_flag,
          l_okl_xtl_pay_invs_tl_rec.description,
          l_okl_xtl_pay_invs_tl_rec.stream_type,
          l_okl_xtl_pay_invs_tl_rec.created_by,
          l_okl_xtl_pay_invs_tl_rec.creation_date,
          l_okl_xtl_pay_invs_tl_rec.last_updated_by,
          l_okl_xtl_pay_invs_tl_rec.last_update_date,
          l_okl_xtl_pay_invs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_xtl_pay_invs_tl_rec := l_okl_xtl_pay_invs_tl_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_XTL_PAY_INVS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type,
    x_xlpv_rec                     OUT NOCOPY xlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlpv_rec                     xlpv_rec_type;
    l_def_xlpv_rec                 xlpv_rec_type;
    l_xlp_rec                      xlp_rec_type;
    lx_xlp_rec                     xlp_rec_type;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
    lx_okl_xtl_pay_invs_tl_rec     okl_xtl_pay_invs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xlpv_rec	IN xlpv_rec_type
    ) RETURN xlpv_rec_type IS
      l_xlpv_rec	xlpv_rec_type := p_xlpv_rec;
    BEGIN
      l_xlpv_rec.CREATION_DATE := SYSDATE;
      l_xlpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_xlpv_rec.LAST_UPDATE_DATE := l_xlpv_rec.CREATION_DATE;     -- PostGen-10
      l_xlpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xlpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xlpv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xlpv_rec IN  xlpv_rec_type,
      x_xlpv_rec OUT NOCOPY xlpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlpv_rec := p_xlpv_rec;
      x_xlpv_rec.OBJECT_VERSION_NUMBER := 1;
      x_xlpv_rec.SFWT_FLAG := 'N';

      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_xlpv_rec.request_id,
        x_xlpv_rec.program_application_id,
        x_xlpv_rec.program_id,
        x_xlpv_rec.program_update_date
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
    l_xlpv_rec := null_out_defaults(p_xlpv_rec);
    -- Set primary key value
    l_xlpv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_xlpv_rec,                        -- IN
      l_def_xlpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xlpv_rec := fill_who_columns(l_def_xlpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xlpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xlpv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xlpv_rec, l_xlp_rec);
    migrate(l_def_xlpv_rec, l_okl_xtl_pay_invs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlp_rec,
      lx_xlp_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xlp_rec, l_def_xlpv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_xtl_pay_invs_tl_rec,
      lx_okl_xtl_pay_invs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_xtl_pay_invs_tl_rec, l_def_xlpv_rec);
    -- Set OUT values
    x_xlpv_rec := l_def_xlpv_rec;
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
  -- PL/SQL TBL insert_row for:XLPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type,
    x_xlpv_tbl                     OUT NOCOPY xlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlpv_tbl.COUNT > 0) THEN
      i := p_xlpv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlpv_rec                     => p_xlpv_tbl(i),
          x_xlpv_rec                     => x_xlpv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xlpv_tbl.LAST);
        i := p_xlpv_tbl.NEXT(i);
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
  -------------------------------------
  -- lock_row for:OKL_XTL_PAY_INVS_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlp_rec                      IN xlp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xlp_rec IN xlp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XTL_PAY_INVS_B
     WHERE ID = p_xlp_rec.id
       AND OBJECT_VERSION_NUMBER = p_xlp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_xlp_rec IN xlp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XTL_PAY_INVS_B
    WHERE ID = p_xlp_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_XTL_PAY_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_XTL_PAY_INVS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_xlp_rec);
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
      OPEN lchk_csr(p_xlp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xlp_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_xlp_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for:OKL_XTL_PAY_INVS_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_pay_invs_tl_rec      IN okl_xtl_pay_invs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_xtl_pay_invs_tl_rec IN okl_xtl_pay_invs_tl_rec_type) IS
    SELECT *
      FROM OKL_XTL_PAY_INVS_TL
     WHERE ID = p_okl_xtl_pay_invs_tl_rec.id
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
      OPEN lock_csr(p_okl_xtl_pay_invs_tl_rec);
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
  -------------------------------------
  -- lock_row for:OKL_XTL_PAY_INVS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlp_rec                      xlp_rec_type;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
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
    migrate(p_xlpv_rec, l_xlp_rec);
    migrate(p_xlpv_rec, l_okl_xtl_pay_invs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlp_rec
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
      l_okl_xtl_pay_invs_tl_rec
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
  -- PL/SQL TBL lock_row for:XLPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlpv_tbl.COUNT > 0) THEN
      i := p_xlpv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlpv_rec                     => p_xlpv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xlpv_tbl.LAST);
        i := p_xlpv_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKL_XTL_PAY_INVS_B --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlp_rec                      IN xlp_rec_type,
    x_xlp_rec                      OUT NOCOPY xlp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlp_rec                      xlp_rec_type := p_xlp_rec;
    l_def_xlp_rec                  xlp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xlp_rec	IN xlp_rec_type,
      x_xlp_rec	OUT NOCOPY xlp_rec_type
    ) RETURN VARCHAR2 IS
      l_xlp_rec                      xlp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlp_rec := p_xlp_rec;
      -- Get current database values
      l_xlp_rec := get_rec(p_xlp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xlp_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.id := l_xlp_rec.id;
      END IF;
      IF (x_xlp_rec.xpi_id_details = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.xpi_id_details := l_xlp_rec.xpi_id_details;
      END IF;
      IF (x_xlp_rec.pid_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.pid_id := l_xlp_rec.pid_id;
      END IF;
      IF (x_xlp_rec.ibi_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.ibi_id := l_xlp_rec.ibi_id;
      END IF;
      IF (x_xlp_rec.tpl_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.tpl_id := l_xlp_rec.tpl_id;
      END IF;
      IF (x_xlp_rec.tap_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.tap_id := l_xlp_rec.tap_id;
      END IF;
      IF (x_xlp_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.object_version_number := l_xlp_rec.object_version_number;
      END IF;
      IF (x_xlp_rec.invoice_line_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.invoice_line_id := l_xlp_rec.invoice_line_id;
      END IF;
      IF (x_xlp_rec.line_number = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.line_number := l_xlp_rec.line_number;
      END IF;
      IF (x_xlp_rec.line_type = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.line_type := l_xlp_rec.line_type;
      END IF;
      IF (x_xlp_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.amount := l_xlp_rec.amount;
      END IF;
      IF (x_xlp_rec.accounting_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlp_rec.accounting_date := l_xlp_rec.accounting_date;
      END IF;
      IF (x_xlp_rec.dist_code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.dist_code_combination_id := l_xlp_rec.dist_code_combination_id;
      END IF;
      IF (x_xlp_rec.tax_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.tax_code := l_xlp_rec.tax_code;
      END IF;
      IF (x_xlp_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.request_id := l_xlp_rec.request_id;
      END IF;
      IF (x_xlp_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.program_application_id := l_xlp_rec.program_application_id;
      END IF;
      IF (x_xlp_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.program_id := l_xlp_rec.program_id;
      END IF;
      IF (x_xlp_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlp_rec.program_update_date := l_xlp_rec.program_update_date;
      END IF;
      IF (x_xlp_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.org_id := l_xlp_rec.org_id;
      END IF;
      IF (x_xlp_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute_category := l_xlp_rec.attribute_category;
      END IF;
      IF (x_xlp_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute1 := l_xlp_rec.attribute1;
      END IF;
      IF (x_xlp_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute2 := l_xlp_rec.attribute2;
      END IF;
      IF (x_xlp_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute3 := l_xlp_rec.attribute3;
      END IF;
      IF (x_xlp_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute4 := l_xlp_rec.attribute4;
      END IF;
      IF (x_xlp_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute5 := l_xlp_rec.attribute5;
      END IF;
      IF (x_xlp_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute6 := l_xlp_rec.attribute6;
      END IF;
      IF (x_xlp_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute7 := l_xlp_rec.attribute7;
      END IF;
      IF (x_xlp_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute8 := l_xlp_rec.attribute8;
      END IF;
      IF (x_xlp_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute9 := l_xlp_rec.attribute9;
      END IF;
      IF (x_xlp_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute10 := l_xlp_rec.attribute10;
      END IF;
      IF (x_xlp_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute11 := l_xlp_rec.attribute11;
      END IF;
      IF (x_xlp_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute12 := l_xlp_rec.attribute12;
      END IF;
      IF (x_xlp_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute13 := l_xlp_rec.attribute13;
      END IF;
      IF (x_xlp_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute14 := l_xlp_rec.attribute14;
      END IF;
      IF (x_xlp_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlp_rec.attribute15 := l_xlp_rec.attribute15;
      END IF;
      IF (x_xlp_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.created_by := l_xlp_rec.created_by;
      END IF;
      IF (x_xlp_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlp_rec.creation_date := l_xlp_rec.creation_date;
      END IF;
      IF (x_xlp_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.last_updated_by := l_xlp_rec.last_updated_by;
      END IF;
      IF (x_xlp_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlp_rec.last_update_date := l_xlp_rec.last_update_date;
      END IF;
      IF (x_xlp_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_xlp_rec.last_update_login := l_xlp_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xlp_rec IN  xlp_rec_type,
      x_xlp_rec OUT NOCOPY xlp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlp_rec := p_xlp_rec;
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
      p_xlp_rec,                         -- IN
      l_xlp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xlp_rec, l_def_xlp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_XTL_PAY_INVS_B
    SET XPI_ID_DETAILS = l_def_xlp_rec.xpi_id_details,
        PID_ID = l_def_xlp_rec.pid_id,
        IBI_ID = l_def_xlp_rec.ibi_id,
        TPL_ID = l_def_xlp_rec.tpl_id,
        TAP_ID = l_def_xlp_rec.tap_id,
        OBJECT_VERSION_NUMBER = l_def_xlp_rec.object_version_number,
        INVOICE_LINE_ID = l_def_xlp_rec.invoice_line_id,
        LINE_NUMBER = l_def_xlp_rec.line_number,
        LINE_TYPE = l_def_xlp_rec.line_type,
        AMOUNT = l_def_xlp_rec.amount,
        ACCOUNTING_DATE = l_def_xlp_rec.accounting_date,
        DIST_CODE_COMBINATION_ID = l_def_xlp_rec.dist_code_combination_id,
        TAX_CODE = l_def_xlp_rec.tax_code,
        REQUEST_ID = l_def_xlp_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_xlp_rec.program_application_id,
        PROGRAM_ID = l_def_xlp_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_xlp_rec.program_update_date,
        ORG_ID = l_def_xlp_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_xlp_rec.attribute_category,
        ATTRIBUTE1 = l_def_xlp_rec.attribute1,
        ATTRIBUTE2 = l_def_xlp_rec.attribute2,
        ATTRIBUTE3 = l_def_xlp_rec.attribute3,
        ATTRIBUTE4 = l_def_xlp_rec.attribute4,
        ATTRIBUTE5 = l_def_xlp_rec.attribute5,
        ATTRIBUTE6 = l_def_xlp_rec.attribute6,
        ATTRIBUTE7 = l_def_xlp_rec.attribute7,
        ATTRIBUTE8 = l_def_xlp_rec.attribute8,
        ATTRIBUTE9 = l_def_xlp_rec.attribute9,
        ATTRIBUTE10 = l_def_xlp_rec.attribute10,
        ATTRIBUTE11 = l_def_xlp_rec.attribute11,
        ATTRIBUTE12 = l_def_xlp_rec.attribute12,
        ATTRIBUTE13 = l_def_xlp_rec.attribute13,
        ATTRIBUTE14 = l_def_xlp_rec.attribute14,
        ATTRIBUTE15 = l_def_xlp_rec.attribute15,
        CREATED_BY = l_def_xlp_rec.created_by,
        CREATION_DATE = l_def_xlp_rec.creation_date,
        LAST_UPDATED_BY = l_def_xlp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xlp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_xlp_rec.last_update_login
    WHERE ID = l_def_xlp_rec.id;

    x_xlp_rec := l_def_xlp_rec;
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
  -- update_row for:OKL_XTL_PAY_INVS_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_pay_invs_tl_rec      IN okl_xtl_pay_invs_tl_rec_type,
    x_okl_xtl_pay_invs_tl_rec      OUT NOCOPY okl_xtl_pay_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type := p_okl_xtl_pay_invs_tl_rec;
    ldefoklxtlpayinvstlrec         okl_xtl_pay_invs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_xtl_pay_invs_tl_rec	IN okl_xtl_pay_invs_tl_rec_type,
      x_okl_xtl_pay_invs_tl_rec	OUT NOCOPY okl_xtl_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_pay_invs_tl_rec := p_okl_xtl_pay_invs_tl_rec;
      -- Get current database values
      l_okl_xtl_pay_invs_tl_rec := get_rec(p_okl_xtl_pay_invs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_xtl_pay_invs_tl_rec.id := l_okl_xtl_pay_invs_tl_rec.id;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_xtl_pay_invs_tl_rec.language := l_okl_xtl_pay_invs_tl_rec.language;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_xtl_pay_invs_tl_rec.source_lang := l_okl_xtl_pay_invs_tl_rec.source_lang;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_xtl_pay_invs_tl_rec.sfwt_flag := l_okl_xtl_pay_invs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_xtl_pay_invs_tl_rec.description := l_okl_xtl_pay_invs_tl_rec.description;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.stream_type = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_xtl_pay_invs_tl_rec.stream_type := l_okl_xtl_pay_invs_tl_rec.stream_type;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_xtl_pay_invs_tl_rec.created_by := l_okl_xtl_pay_invs_tl_rec.created_by;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_xtl_pay_invs_tl_rec.creation_date := l_okl_xtl_pay_invs_tl_rec.creation_date;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_xtl_pay_invs_tl_rec.last_updated_by := l_okl_xtl_pay_invs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_xtl_pay_invs_tl_rec.last_update_date := l_okl_xtl_pay_invs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_xtl_pay_invs_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_xtl_pay_invs_tl_rec.last_update_login := l_okl_xtl_pay_invs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_xtl_pay_invs_tl_rec IN  okl_xtl_pay_invs_tl_rec_type,
      x_okl_xtl_pay_invs_tl_rec OUT NOCOPY okl_xtl_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_pay_invs_tl_rec := p_okl_xtl_pay_invs_tl_rec;
      x_okl_xtl_pay_invs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_xtl_pay_invs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_xtl_pay_invs_tl_rec,         -- IN
      l_okl_xtl_pay_invs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_xtl_pay_invs_tl_rec, ldefoklxtlpayinvstlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_XTL_PAY_INVS_TL
    SET DESCRIPTION = ldefoklxtlpayinvstlrec.description,
        STREAM_TYPE = ldefoklxtlpayinvstlrec.stream_type,
        SOURCE_LANG = ldefoklxtlpayinvstlrec.source_lang,
        CREATED_BY = ldefoklxtlpayinvstlrec.created_by,
        CREATION_DATE = ldefoklxtlpayinvstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklxtlpayinvstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklxtlpayinvstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklxtlpayinvstlrec.last_update_login
    WHERE ID = ldefoklxtlpayinvstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_XTL_PAY_INVS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklxtlpayinvstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_xtl_pay_invs_tl_rec := ldefoklxtlpayinvstlrec;
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
  ---------------------------------------
  -- update_row for:OKL_XTL_PAY_INVS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type,
    x_xlpv_rec                     OUT NOCOPY xlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlpv_rec                     xlpv_rec_type := p_xlpv_rec;
    l_def_xlpv_rec                 xlpv_rec_type;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
    lx_okl_xtl_pay_invs_tl_rec     okl_xtl_pay_invs_tl_rec_type;
    l_xlp_rec                      xlp_rec_type;
    lx_xlp_rec                     xlp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xlpv_rec	IN xlpv_rec_type
    ) RETURN xlpv_rec_type IS
      l_xlpv_rec	xlpv_rec_type := p_xlpv_rec;
    BEGIN
      l_xlpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_xlpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xlpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xlpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xlpv_rec	IN xlpv_rec_type,
      x_xlpv_rec	OUT NOCOPY xlpv_rec_type
    ) RETURN VARCHAR2 IS
      l_xlpv_rec                     xlpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlpv_rec := p_xlpv_rec;
      -- Get current database values
      l_xlpv_rec := get_rec(p_xlpv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xlpv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.id := l_xlpv_rec.id;
      END IF;
      IF (x_xlpv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.object_version_number := l_xlpv_rec.object_version_number;
      END IF;
      IF (x_xlpv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.sfwt_flag := l_xlpv_rec.sfwt_flag;
      END IF;
      IF (x_xlpv_rec.tpl_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.tpl_id := l_xlpv_rec.tpl_id;
      END IF;
      IF (x_xlpv_rec.tap_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.tap_id := l_xlpv_rec.tap_id;
      END IF;
      IF (x_xlpv_rec.pid_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.pid_id := l_xlpv_rec.pid_id;
      END IF;
      IF (x_xlpv_rec.ibi_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.ibi_id := l_xlpv_rec.ibi_id;
      END IF;
      IF (x_xlpv_rec.xpi_id_details = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.xpi_id_details := l_xlpv_rec.xpi_id_details;
      END IF;
      IF (x_xlpv_rec.invoice_line_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.invoice_line_id := l_xlpv_rec.invoice_line_id;
      END IF;
      IF (x_xlpv_rec.line_number = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.line_number := l_xlpv_rec.line_number;
      END IF;
      IF (x_xlpv_rec.line_type = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.line_type := l_xlpv_rec.line_type;
      END IF;
      IF (x_xlpv_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.amount := l_xlpv_rec.amount;
      END IF;
      IF (x_xlpv_rec.accounting_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlpv_rec.accounting_date := l_xlpv_rec.accounting_date;
      END IF;
      IF (x_xlpv_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.description := l_xlpv_rec.description;
      END IF;
      IF (x_xlpv_rec.dist_code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.dist_code_combination_id := l_xlpv_rec.dist_code_combination_id;
      END IF;
      IF (x_xlpv_rec.tax_code = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.tax_code := l_xlpv_rec.tax_code;
      END IF;
      IF (x_xlpv_rec.stream_type = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.stream_type := l_xlpv_rec.stream_type;
      END IF;
      IF (x_xlpv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute_category := l_xlpv_rec.attribute_category;
      END IF;
      IF (x_xlpv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute1 := l_xlpv_rec.attribute1;
      END IF;
      IF (x_xlpv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute2 := l_xlpv_rec.attribute2;
      END IF;
      IF (x_xlpv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute3 := l_xlpv_rec.attribute3;
      END IF;
      IF (x_xlpv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute4 := l_xlpv_rec.attribute4;
      END IF;
      IF (x_xlpv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute5 := l_xlpv_rec.attribute5;
      END IF;
      IF (x_xlpv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute6 := l_xlpv_rec.attribute6;
      END IF;
      IF (x_xlpv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute7 := l_xlpv_rec.attribute7;
      END IF;
      IF (x_xlpv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute8 := l_xlpv_rec.attribute8;
      END IF;
      IF (x_xlpv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute9 := l_xlpv_rec.attribute9;
      END IF;
      IF (x_xlpv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute10 := l_xlpv_rec.attribute10;
      END IF;
      IF (x_xlpv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute11 := l_xlpv_rec.attribute11;
      END IF;
      IF (x_xlpv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute12 := l_xlpv_rec.attribute12;
      END IF;
      IF (x_xlpv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute13 := l_xlpv_rec.attribute13;
      END IF;
      IF (x_xlpv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute14 := l_xlpv_rec.attribute14;
      END IF;
      IF (x_xlpv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_xlpv_rec.attribute15 := l_xlpv_rec.attribute15;
      END IF;
      IF (x_xlpv_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.request_id := l_xlpv_rec.request_id;
      END IF;
      IF (x_xlpv_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.program_application_id := l_xlpv_rec.program_application_id;
      END IF;
      IF (x_xlpv_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.program_id := l_xlpv_rec.program_id;
      END IF;
      IF (x_xlpv_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlpv_rec.program_update_date := l_xlpv_rec.program_update_date;
      END IF;
      IF (x_xlpv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.org_id := l_xlpv_rec.org_id;
      END IF;
      IF (x_xlpv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.created_by := l_xlpv_rec.created_by;
      END IF;
      IF (x_xlpv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlpv_rec.creation_date := l_xlpv_rec.creation_date;
      END IF;
      IF (x_xlpv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.last_updated_by := l_xlpv_rec.last_updated_by;
      END IF;
      IF (x_xlpv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_xlpv_rec.last_update_date := l_xlpv_rec.last_update_date;
      END IF;
      IF (x_xlpv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_xlpv_rec.last_update_login := l_xlpv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_xlpv_rec IN  xlpv_rec_type,
      x_xlpv_rec OUT NOCOPY xlpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlpv_rec := p_xlpv_rec;
      x_xlpv_rec.OBJECT_VERSION_NUMBER := NVL(x_xlpv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

      -- Begin PostGen-7
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_xlpv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_xlpv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_xlpv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_xlpv_rec.program_update_date,SYSDATE)
      INTO
        x_xlpv_rec.request_id,
        x_xlpv_rec.program_application_id,
        x_xlpv_rec.program_id,
        x_xlpv_rec.program_update_date
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
      p_xlpv_rec,                        -- IN
      l_xlpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xlpv_rec, l_def_xlpv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xlpv_rec := fill_who_columns(l_def_xlpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xlpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xlpv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xlpv_rec, l_okl_xtl_pay_invs_tl_rec);
    migrate(l_def_xlpv_rec, l_xlp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_xtl_pay_invs_tl_rec,
      lx_okl_xtl_pay_invs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_xtl_pay_invs_tl_rec, l_def_xlpv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlp_rec,
      lx_xlp_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xlp_rec, l_def_xlpv_rec);
    x_xlpv_rec := l_def_xlpv_rec;
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
  -- PL/SQL TBL update_row for:XLPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type,
    x_xlpv_tbl                     OUT NOCOPY xlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlpv_tbl.COUNT > 0) THEN
      i := p_xlpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlpv_rec                     => p_xlpv_tbl(i),
          x_xlpv_rec                     => x_xlpv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xlpv_tbl.LAST);
        i := p_xlpv_tbl.NEXT(i);
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
  ---------------------------------------
  -- delete_row for:OKL_XTL_PAY_INVS_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlp_rec                      IN xlp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlp_rec                      xlp_rec_type:= p_xlp_rec;
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
    DELETE FROM OKL_XTL_PAY_INVS_B
     WHERE ID = l_xlp_rec.id;

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
  -- delete_row for:OKL_XTL_PAY_INVS_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_xtl_pay_invs_tl_rec      IN okl_xtl_pay_invs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type:= p_okl_xtl_pay_invs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_PAY_INVS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_xtl_pay_invs_tl_rec IN  okl_xtl_pay_invs_tl_rec_type,
      x_okl_xtl_pay_invs_tl_rec OUT NOCOPY okl_xtl_pay_invs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_xtl_pay_invs_tl_rec := p_okl_xtl_pay_invs_tl_rec;
      x_okl_xtl_pay_invs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_xtl_pay_invs_tl_rec,         -- IN
      l_okl_xtl_pay_invs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_XTL_PAY_INVS_TL
     WHERE ID = l_okl_xtl_pay_invs_tl_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_XTL_PAY_INVS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xlpv_rec                     xlpv_rec_type := p_xlpv_rec;
    l_okl_xtl_pay_invs_tl_rec      okl_xtl_pay_invs_tl_rec_type;
    l_xlp_rec                      xlp_rec_type;
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
    migrate(l_xlpv_rec, l_okl_xtl_pay_invs_tl_rec);
    migrate(l_xlpv_rec, l_xlp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_xtl_pay_invs_tl_rec
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
      l_xlp_rec
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
  -- PL/SQL TBL delete_row for:XLPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;     -- PostGen-9
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlpv_tbl.COUNT > 0) THEN
      i := p_xlpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlpv_rec                     => p_xlpv_tbl(i));

        -- Store the highest degree of error                             -- PostGen-9
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN             -- PostGen-9
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN     -- PostGen-9
              l_overall_status := x_return_status;                       -- PostGen-9
           END IF;                                                       -- PostGen-9
        END IF;                                                          -- PostGen-9

        EXIT WHEN (i = p_xlpv_tbl.LAST);
        i := p_xlpv_tbl.NEXT(i);
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
END OKL_XLP_PVT;

/

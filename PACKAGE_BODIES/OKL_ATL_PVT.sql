--------------------------------------------------------
--  DDL for Package Body OKL_ATL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ATL_PVT" AS
/* $Header: OKLSATLB.pls 120.5 2007/02/15 08:14:44 zrehman noship $ */

    G_EXCEPTION_HALT_VALIDATION EXCEPTION;
    G_ITEM_NOT_FOUND_ERROR EXCEPTION;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_avl_id
  ---------------------------------------------------------------------------
    PROCEDURE validate_avl_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_atlv_rec IN  atlv_rec_type
    ) IS

    CURSOR okl_atlv_tmpl_pk_csr (v_avl_id IN NUMBER) IS
    SELECT  '1'
    FROM OKL_AE_TEMPLATES
    WHERE id = v_avl_id;

    l_dummy VARCHAR2(1);
    l_row_notfound   		BOOLEAN := TRUE;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_atlv_rec.avl_id IS NULL) OR (p_atlv_rec.avl_id = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'AVL_ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;

    OPEN okl_atlv_tmpl_pk_csr(p_atlv_rec.AVL_ID);
    FETCH okl_atlv_tmpl_pk_csr INTO l_dummy;
    l_row_notfound := okl_atlv_tmpl_pk_csr%NOTFOUND;
    CLOSE okl_atlv_tmpl_pk_csr;
    IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AVL_ID');
        RAISE g_item_not_found_error;
    END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN g_item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_avl_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ae_line_type
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  -- 12/12/2002 Changed by Kanti Jinger to remove the mandatory validation. Now the
  --            line type is validated only when its values is not null
  ---------------------------------------------------------------------------
    PROCEDURE validate_ae_line_type(
      x_return_status OUT NOCOPY VARCHAR2,
      p_atlv_rec IN  atlv_rec_type
    ) IS

    l_lookup_code    		VARCHAR2(1);
    l_row_notfound   		BOOLEAN := TRUE;
    l_dummy VARCHAR2(1);

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_atlv_rec.ae_line_type IS NOT NULL)  AND
       (p_atlv_rec.ae_line_type <> OKC_API.G_MISS_CHAR) THEN
          l_dummy :=
                  OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_AE_LINE_TYPE',
                               p_lookup_code => p_atlv_rec.ae_line_type);

          IF (l_dummy = OKL_API.G_FALSE) THEN
               OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AE_LINE_TYPE');
               x_return_status := OKC_API.G_RET_STS_ERROR;
               RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

    END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ae_line_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_crd_code
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_crd_code(
      x_return_status OUT NOCOPY VARCHAR2,
      p_atlv_rec IN  atlv_rec_type
    ) IS

    l_lookup_code    		VARCHAR2(1);
    l_row_notfound   		BOOLEAN := TRUE;
    l_app_id                    NUMBER := 101;
    l_view_app_id               NUMBER := 101;
    l_dummy                     VARCHAR2(1);

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_atlv_rec.crd_code IS NULL) OR (p_atlv_rec.crd_code = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'CRD_CODE');
          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          l_dummy :=
                  OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'CR_DR',
                                                           p_lookup_code => p_atlv_rec.crd_code,
                                                           p_app_id => l_app_id,
                                                           p_view_app_id => l_view_app_id);
         IF (l_dummy = OKL_API.G_FALSE) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRD_CODE');
            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;


    END IF;


      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN g_item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_crd_code;

-- Commented by zrehman for Bug #5686162 15-Feb-2007 start
/*
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_percentage
  ---------------------------------------------------------------------------
    PROCEDURE validate_percentage(
      x_return_status OUT NOCOPY VARCHAR2,
      p_atlv_rec IN  atlv_rec_type
    ) IS
    l_dummy VARCHAR2(1);
    l_app_id NUMBER := 0;
    l_view_App_id NUMBER := 0;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_atlv_rec.percentage IS NULL) OR
       (p_atlv_rec.percentage = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'PERCENTAGE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSE

       IF (p_atlv_rec.PERCENTAGE > 100) OR (p_atlv_rec.PERCENTAGE < 0)  THEN

          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PERCENTAGE');
          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

    END IF;

      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_percentage;
    */
-- Commented by zrehman for Bug #5686162 15-Feb-2007 end


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_account_builder_yn
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_account_builder_yn(
      x_return_status OUT NOCOPY VARCHAR2,
      p_atlv_rec IN  atlv_rec_type
    ) IS
    l_dummy VARCHAR2(1);
    l_app_id NUMBER := 0;
    l_view_App_id NUMBER := 0;

    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_atlv_rec.account_builder_yn IS NULL) OR
       (p_atlv_rec.account_builder_yn = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ACCOUNT_BUILDER_YN');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
         l_dummy :=
         OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'YES_NO',
                                                  p_lookup_code => p_atlv_rec.account_builder_yn,
                                                  p_app_id => l_app_id,
                                                  p_view_app_id => l_view_app_id);
         IF (l_dummy = OKL_API.G_FALSE) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACCOUNT_BUILDER_YN');
            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

    END IF;
      EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_account_builder_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_code_combination_id
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_code_combination_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_atlv_rec IN  atlv_rec_type
    ) IS
    l_fetch_flag			      VARCHAR2(1) := okl_api.g_true;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_atlv_rec.CODE_COMBINATION_ID IS NOT NULL)  AND
       (p_atlv_rec.CODE_COMBINATION_ID <> OKC_API.G_MISS_NUM) THEN

        l_fetch_flag := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID (p_atlv_rec.code_combination_id);
        IF l_fetch_flag = okl_api.g_false THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'CODE_COMBINATION_ID');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;

    EXCEPTION
       WHEN G_EXCEPTION_HALT_VALIDATION THEN
          NULL;
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => SQLCODE,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => SQLERRM);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_code_combination_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_CCID_BUILDER
  ---------------------------------------------------------------------------
  PROCEDURE Validate_CCID_BUILDER(x_return_status OUT NOCOPY     VARCHAR2,
				  p_atlv_rec      IN      atlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_atlv_status           VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- If CCID is NULL and Account_Builder_YN is N then raise Error

    IF ((p_atlv_rec.CODE_COMBINATION_ID IS NULL) OR
        (p_atlv_rec.CODE_COMBINATION_ID = OKC_API.G_MISS_NUM))
            AND
        (p_atlv_rec.ACCOUNT_BUILDER_YN  = 'N')
        THEN
	OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                            p_msg_name     => 'OKL_CCID_OR_BUILDER_REQD');
	x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

-- Removed the validation by santonyr on 22-Sep-2004
-- to fix bug 3901209

/*

-- If CCID is given then Account Builder YN cannot be 'Y'

    IF ((p_atlv_rec.CODE_COMBINATION_ID IS NOT NULL) AND
        (p_atlv_rec.CODE_COMBINATION_ID <> OKC_API.G_MISS_NUM))
            AND
        (p_atlv_rec.ACCOUNT_BUILDER_YN  = 'Y' )
        THEN
	OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                            p_msg_name     => 'OKL_GIVE_CCID_OR_BUILDER');
	x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

*/


-- If CCID is given then percentage should also be given

    IF ((p_atlv_rec.CODE_COMBINATION_ID IS NOT NULL) AND
        (p_atlv_rec.CODE_COMBINATION_ID <> OKC_API.G_MISS_NUM))
         AND
        ((p_atlv_rec.PERCENTAGE IS NULL) OR (p_atlv_rec.PERCENTAGE = OKC_API.G_MISS_NUM)) THEN

	OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                            p_msg_name     => 'OKL_GIVE_PERCENT_FOR_CCID');
	x_return_status := OKC_API.G_RET_STS_ERROR;

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;



  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
     -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_CCID_BUILDER;

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
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AE_TMPT_LNES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_atl_rec                      IN atl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN atl_rec_type IS
    CURSOR okl_ae_tmpt_lnes_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SEQUENCE_NUMBER,
            AVL_ID,
            CODE_COMBINATION_ID,
            AE_LINE_TYPE,
            CRD_CODE,
            ACCOUNT_BUILDER_YN,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
            PERCENTAGE,
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
      FROM Okl_Ae_Tmpt_Lnes
     WHERE okl_ae_tmpt_lnes.id  = p_id;
    l_okl_ae_tmpt_lnes_pk          okl_ae_tmpt_lnes_pk_csr%ROWTYPE;
    l_atl_rec                      atl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ae_tmpt_lnes_pk_csr (p_atl_rec.id);
    FETCH okl_ae_tmpt_lnes_pk_csr INTO
              l_atl_rec.ID,
              l_atl_rec.SEQUENCE_NUMBER,
              l_atl_rec.AVL_ID,
              l_atl_rec.CODE_COMBINATION_ID,
              l_atl_rec.AE_LINE_TYPE,
              l_atl_rec.CRD_CODE,
              l_atl_rec.ACCOUNT_BUILDER_YN,
              l_atl_rec.OBJECT_VERSION_NUMBER,
              l_atl_rec.DESCRIPTION,
              l_atl_rec.PERCENTAGE,
              l_atl_rec.ORG_ID,
              l_atl_rec.ATTRIBUTE_CATEGORY,
              l_atl_rec.ATTRIBUTE1,
              l_atl_rec.ATTRIBUTE2,
              l_atl_rec.ATTRIBUTE3,
              l_atl_rec.ATTRIBUTE4,
              l_atl_rec.ATTRIBUTE5,
              l_atl_rec.ATTRIBUTE6,
              l_atl_rec.ATTRIBUTE7,
              l_atl_rec.ATTRIBUTE8,
              l_atl_rec.ATTRIBUTE9,
              l_atl_rec.ATTRIBUTE10,
              l_atl_rec.ATTRIBUTE11,
              l_atl_rec.ATTRIBUTE12,
              l_atl_rec.ATTRIBUTE13,
              l_atl_rec.ATTRIBUTE14,
              l_atl_rec.ATTRIBUTE15,
              l_atl_rec.CREATED_BY,
              l_atl_rec.CREATION_DATE,
              l_atl_rec.LAST_UPDATED_BY,
              l_atl_rec.LAST_UPDATE_DATE,
              l_atl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ae_tmpt_lnes_pk_csr%NOTFOUND;
    CLOSE okl_ae_tmpt_lnes_pk_csr;
    RETURN(l_atl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_atl_rec                      IN atl_rec_type
  ) RETURN atl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_atl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AE_TMPT_LNES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_atlv_rec                     IN atlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN atlv_rec_type IS
    CURSOR okl_atlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            AVL_ID,
            CRD_CODE,
            CODE_COMBINATION_ID,
            AE_LINE_TYPE,
            SEQUENCE_NUMBER,
            DESCRIPTION,
            PERCENTAGE,
            ACCOUNT_BUILDER_YN,
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
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_AE_TMPT_LNES
     WHERE OKL_AE_TMPT_LNES.id = p_id;
    l_okl_atlv_pk                  okl_atlv_pk_csr%ROWTYPE;
    l_atlv_rec                     atlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_atlv_pk_csr (p_atlv_rec.id);
    FETCH okl_atlv_pk_csr INTO
              l_atlv_rec.ID,
              l_atlv_rec.OBJECT_VERSION_NUMBER,
              l_atlv_rec.AVL_ID,
              l_atlv_rec.CRD_CODE,
              l_atlv_rec.CODE_COMBINATION_ID,
              l_atlv_rec.AE_LINE_TYPE,
              l_atlv_rec.SEQUENCE_NUMBER,
              l_atlv_rec.DESCRIPTION,
              l_atlv_rec.PERCENTAGE,
              l_atlv_rec.ACCOUNT_BUILDER_YN,
              l_atlv_rec.ATTRIBUTE_CATEGORY,
              l_atlv_rec.ATTRIBUTE1,
              l_atlv_rec.ATTRIBUTE2,
              l_atlv_rec.ATTRIBUTE3,
              l_atlv_rec.ATTRIBUTE4,
              l_atlv_rec.ATTRIBUTE5,
              l_atlv_rec.ATTRIBUTE6,
              l_atlv_rec.ATTRIBUTE7,
              l_atlv_rec.ATTRIBUTE8,
              l_atlv_rec.ATTRIBUTE9,
              l_atlv_rec.ATTRIBUTE10,
              l_atlv_rec.ATTRIBUTE11,
              l_atlv_rec.ATTRIBUTE12,
              l_atlv_rec.ATTRIBUTE13,
              l_atlv_rec.ATTRIBUTE14,
              l_atlv_rec.ATTRIBUTE15,
              l_atlv_rec.ORG_ID,
              l_atlv_rec.CREATED_BY,
              l_atlv_rec.CREATION_DATE,
              l_atlv_rec.LAST_UPDATED_BY,
              l_atlv_rec.LAST_UPDATE_DATE,
              l_atlv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_atlv_pk_csr%NOTFOUND;
    CLOSE okl_atlv_pk_csr;
    RETURN(l_atlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_atlv_rec                     IN atlv_rec_type
  ) RETURN atlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_atlv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AE_TMPT_LNES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_atlv_rec	IN atlv_rec_type
  ) RETURN atlv_rec_type IS
    l_atlv_rec	atlv_rec_type := p_atlv_rec;
  BEGIN
    IF (l_atlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.object_version_number := NULL;
    END IF;
    IF (l_atlv_rec.avl_id = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.avl_id := NULL;
    END IF;
    IF (l_atlv_rec.crd_code = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.crd_code := NULL;
    END IF;
    IF (l_atlv_rec.code_combination_id = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.code_combination_id := NULL;
    END IF;
    IF (l_atlv_rec.ae_line_type = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.ae_line_type := NULL;
    END IF;
    IF (l_atlv_rec.sequence_number = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.sequence_number := NULL;
    END IF;
    IF (l_atlv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.description := NULL;
    END IF;
    IF (l_atlv_rec.percentage = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.percentage := NULL;
    END IF;
    IF (l_atlv_rec.account_builder_yn = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.account_builder_yn := NULL;
    END IF;
    IF (l_atlv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute_category := NULL;
    END IF;
    IF (l_atlv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute1 := NULL;
    END IF;
    IF (l_atlv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute2 := NULL;
    END IF;
    IF (l_atlv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute3 := NULL;
    END IF;
    IF (l_atlv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute4 := NULL;
    END IF;
    IF (l_atlv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute5 := NULL;
    END IF;
    IF (l_atlv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute6 := NULL;
    END IF;
    IF (l_atlv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute7 := NULL;
    END IF;
    IF (l_atlv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute8 := NULL;
    END IF;
    IF (l_atlv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute9 := NULL;
    END IF;
    IF (l_atlv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute10 := NULL;
    END IF;
    IF (l_atlv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute11 := NULL;
    END IF;
    IF (l_atlv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute12 := NULL;
    END IF;
    IF (l_atlv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute13 := NULL;
    END IF;
    IF (l_atlv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute14 := NULL;
    END IF;
    IF (l_atlv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_atlv_rec.attribute15 := NULL;
    END IF;
    IF (l_atlv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.org_id := NULL;
    END IF;
    IF (l_atlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.created_by := NULL;
    END IF;
    IF (l_atlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_atlv_rec.creation_date := NULL;
    END IF;
    IF (l_atlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_atlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_atlv_rec.last_update_date := NULL;
    END IF;
    IF (l_atlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_atlv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_atlv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_AE_TMPT_LNES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_atlv_rec IN  atlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN


    IF (p_atlv_rec.id = OKC_API.G_MISS_NUM) OR
       (p_atlv_rec.id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
      END IF;
    END IF;

    IF (p_atlv_rec.object_version_number = OKC_API.G_MISS_NUM) OR
       (p_atlv_rec.object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
      END IF;
    END IF;

    IF (p_atlv_rec.sequence_number = OKC_API.G_MISS_NUM) OR
       (p_atlv_rec.sequence_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sequence_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
      END IF;
    END IF;

    validate_avl_id(x_return_status => l_return_status, p_atlv_rec => p_atlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_ae_line_type(x_return_status => l_return_status, p_atlv_rec => p_atlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_crd_code(x_return_status => l_return_status, p_atlv_rec => p_atlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
   -- Commented by zrehman for Bug #5686162 15-Feb-2007
   /*
    validate_percentage(x_return_status => l_return_status, p_atlv_rec => p_atlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    */
   -- Commented by zrehman for Bug #5686162 15-Feb-2007

    validate_account_builder_yn(x_return_status => l_return_status, p_atlv_rec => p_atlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_code_combination_id(x_return_status => l_return_status, p_atlv_rec => p_atlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;


    RETURN(x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name    => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => SQLCODE,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => SQLERRM);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_AE_TMPT_LNES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_atlv_rec IN atlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Validate_CCID_BUILDER
    Validate_CCID_Builder(x_return_status, p_atlv_rec);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN atlv_rec_type,
    p_to	IN OUT NOCOPY atl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.avl_id := p_from.avl_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.ae_line_type := p_from.ae_line_type;
    p_to.crd_code := p_from.crd_code;
    p_to.account_builder_yn := p_from.account_builder_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.percentage := p_from.percentage;
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
    p_from	IN atl_rec_type,
    p_to	OUT NOCOPY atlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.avl_id := p_from.avl_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.ae_line_type := p_from.ae_line_type;
    p_to.crd_code := p_from.crd_code;
    p_to.account_builder_yn := p_from.account_builder_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.percentage := p_from.percentage;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_AE_TMPT_LNES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atlv_rec                     atlv_rec_type := p_atlv_rec;
    l_atl_rec                      atl_rec_type;
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
    l_return_status := Validate_Attributes(l_atlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_atlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:ATLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i));

	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;

        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;

    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- insert_row for:OKL_AE_TMPT_LNES --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atl_rec                      IN atl_rec_type,
    x_atl_rec                      OUT NOCOPY atl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atl_rec                      atl_rec_type := p_atl_rec;
    l_def_atl_rec                  atl_rec_type;
    l_org_id 				VARCHAR2(10);

    -----------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_LNES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_atl_rec IN  atl_rec_type,
      x_atl_rec OUT NOCOPY atl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atl_rec := p_atl_rec;
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
      p_atl_rec,                         -- IN
      l_atl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Added by zrehman for Bug #5686162 15-Feb-2007 start
    -- This was as per directive from management in the SLA Uptake solution design review.
      l_atl_rec.percentage := 100;
    -- Added by zrehman for Bug #5686162 15-Feb-2007 end

    INSERT INTO OKL_AE_TMPT_LNES(
        id,
        sequence_number,
        avl_id,
        code_combination_id,
        ae_line_type,
        crd_code,
        account_builder_yn,
        object_version_number,
        description,
        percentage,
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
        l_atl_rec.id,
        l_atl_rec.sequence_number,
        l_atl_rec.avl_id,
        l_atl_rec.code_combination_id,
        l_atl_rec.ae_line_type,
        l_atl_rec.crd_code,
        l_atl_rec.account_builder_yn,
        l_atl_rec.object_version_number,
        l_atl_rec.description,
        l_atl_rec.percentage,
	  l_org_id,
        l_atl_rec.attribute_category,
        l_atl_rec.attribute1,
        l_atl_rec.attribute2,
        l_atl_rec.attribute3,
        l_atl_rec.attribute4,
        l_atl_rec.attribute5,
        l_atl_rec.attribute6,
        l_atl_rec.attribute7,
        l_atl_rec.attribute8,
        l_atl_rec.attribute9,
        l_atl_rec.attribute10,
        l_atl_rec.attribute11,
        l_atl_rec.attribute12,
        l_atl_rec.attribute13,
        l_atl_rec.attribute14,
        l_atl_rec.attribute15,
        l_atl_rec.created_by,
        l_atl_rec.creation_date,
        l_atl_rec.last_updated_by,
        l_atl_rec.last_update_date,
        l_atl_rec.last_update_login);
    -- Set OUT values
    x_atl_rec := l_atl_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_AE_TMPT_LNES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type,
    x_atlv_rec                     OUT NOCOPY atlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atlv_rec                     atlv_rec_type;
    l_def_atlv_rec                 atlv_rec_type;
    l_atl_rec                      atl_rec_type;
    lx_atl_rec                     atl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_atlv_rec	IN atlv_rec_type
    ) RETURN atlv_rec_type IS
      l_atlv_rec	atlv_rec_type := p_atlv_rec;
    BEGIN
      l_atlv_rec.CREATION_DATE := SYSDATE;
      l_atlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_atlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_atlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_atlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_atlv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_LNES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_atlv_rec IN  atlv_rec_type,
      x_atlv_rec OUT NOCOPY atlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_max_seq                      NUMBER;

      CURSOR atl_csr(v_avl_id NUMBER) IS
      SELECT nvl(MAX(sequence_number),0)
      FROM OKL_AE_TMPT_LNES
      WHERE AVL_ID = v_avl_id;


    BEGIN

      x_atlv_rec := p_atlv_rec;
      x_atlv_rec.OBJECT_VERSION_NUMBER := 1;
      x_atlv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

      OPEN atl_csr(x_atlv_rec.AVL_ID);
      FETCH atl_csr INTO l_max_seq;
      CLOSE atl_csr;

      IF (l_max_seq) = 0 THEN
         x_atlv_rec.sequence_number := 1;
      ELSE
         x_atlv_rec.sequence_number := l_max_seq + 1;
      END IF;

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
    l_atlv_rec := null_out_defaults(p_atlv_rec);
    -- Set primary key value
    l_atlv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_atlv_rec,                        -- IN
      l_def_atlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_atlv_rec := fill_who_columns(l_def_atlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_atlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_atlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_atlv_rec, l_atl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atl_rec,
      lx_atl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_atl_rec, l_def_atlv_rec);
    -- Set OUT values
    x_atlv_rec := l_def_atlv_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:ATLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type,
    x_atlv_tbl                     OUT NOCOPY atlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i),
          x_atlv_rec                     => x_atlv_tbl(i));

	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;

        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- lock_row for:OKL_AE_TMPT_LNES --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atl_rec                      IN atl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_atl_rec IN atl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_TMPT_LNES
     WHERE ID = p_atl_rec.id
       AND OBJECT_VERSION_NUMBER = p_atl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_atl_rec IN atl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_TMPT_LNES
    WHERE ID = p_atl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_AE_TMPT_LNES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_AE_TMPT_LNES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_atl_rec);
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
      OPEN lchk_csr(p_atl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_atl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_atl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_AE_TMPT_LNES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atl_rec                      atl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_atlv_rec, l_atl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:ATLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- update_row for:OKL_AE_TMPT_LNES --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atl_rec                      IN atl_rec_type,
    x_atl_rec                      OUT NOCOPY atl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atl_rec                      atl_rec_type := p_atl_rec;
    l_def_atl_rec                  atl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_atl_rec	IN atl_rec_type,
      x_atl_rec	OUT NOCOPY atl_rec_type
    ) RETURN VARCHAR2 IS
      l_atl_rec                      atl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atl_rec := p_atl_rec;
      -- Get current database values
      l_atl_rec := get_rec(p_atl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_atl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.id := l_atl_rec.id;
      END IF;
      IF (x_atl_rec.sequence_number = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.sequence_number := l_atl_rec.sequence_number;
      END IF;
      IF (x_atl_rec.avl_id = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.avl_id := l_atl_rec.avl_id;
      END IF;
      IF (x_atl_rec.code_combination_id = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.code_combination_id := l_atl_rec.code_combination_id;
      END IF;
      IF (x_atl_rec.ae_line_type = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.ae_line_type := l_atl_rec.ae_line_type;
      END IF;
      IF (x_atl_rec.crd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.crd_code := l_atl_rec.crd_code;
      END IF;
      IF (x_atl_rec.account_builder_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.account_builder_yn := l_atl_rec.account_builder_yn;
      END IF;
      IF (x_atl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.object_version_number := l_atl_rec.object_version_number;
      END IF;
      IF (x_atl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.description := l_atl_rec.description;
      END IF;
      IF (x_atl_rec.percentage = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.percentage := l_atl_rec.percentage;
      END IF;
      IF (x_atl_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.org_id := l_atl_rec.org_id;
      END IF;
      IF (x_atl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute_category := l_atl_rec.attribute_category;
      END IF;
      IF (x_atl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute1 := l_atl_rec.attribute1;
      END IF;
      IF (x_atl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute2 := l_atl_rec.attribute2;
      END IF;
      IF (x_atl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute3 := l_atl_rec.attribute3;
      END IF;
      IF (x_atl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute4 := l_atl_rec.attribute4;
      END IF;
      IF (x_atl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute5 := l_atl_rec.attribute5;
      END IF;
      IF (x_atl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute6 := l_atl_rec.attribute6;
      END IF;
      IF (x_atl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute7 := l_atl_rec.attribute7;
      END IF;
      IF (x_atl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute8 := l_atl_rec.attribute8;
      END IF;
      IF (x_atl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute9 := l_atl_rec.attribute9;
      END IF;
      IF (x_atl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute10 := l_atl_rec.attribute10;
      END IF;
      IF (x_atl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute11 := l_atl_rec.attribute11;
      END IF;
      IF (x_atl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute12 := l_atl_rec.attribute12;
      END IF;
      IF (x_atl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute13 := l_atl_rec.attribute13;
      END IF;
      IF (x_atl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute14 := l_atl_rec.attribute14;
      END IF;
      IF (x_atl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_atl_rec.attribute15 := l_atl_rec.attribute15;
      END IF;
      IF (x_atl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.created_by := l_atl_rec.created_by;
      END IF;
      IF (x_atl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_atl_rec.creation_date := l_atl_rec.creation_date;
      END IF;
      IF (x_atl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.last_updated_by := l_atl_rec.last_updated_by;
      END IF;
      IF (x_atl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_atl_rec.last_update_date := l_atl_rec.last_update_date;
      END IF;
      IF (x_atl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_atl_rec.last_update_login := l_atl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_LNES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_atl_rec IN  atl_rec_type,
      x_atl_rec OUT NOCOPY atl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atl_rec := p_atl_rec;
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
      p_atl_rec,                         -- IN
      l_atl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_atl_rec, l_def_atl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_AE_TMPT_LNES
    SET SEQUENCE_NUMBER = l_def_atl_rec.sequence_number,
        AVL_ID = l_def_atl_rec.avl_id,
        CODE_COMBINATION_ID = l_def_atl_rec.code_combination_id,
        AE_LINE_TYPE = l_def_atl_rec.ae_line_type,
        CRD_CODE = l_def_atl_rec.crd_code,
        ACCOUNT_BUILDER_YN = l_def_atl_rec.account_builder_yn,
        OBJECT_VERSION_NUMBER = l_def_atl_rec.object_version_number,
        DESCRIPTION = l_def_atl_rec.description,
        PERCENTAGE = l_def_atl_rec.percentage,
        ORG_ID = l_def_atl_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_atl_rec.attribute_category,
        ATTRIBUTE1 = l_def_atl_rec.attribute1,
        ATTRIBUTE2 = l_def_atl_rec.attribute2,
        ATTRIBUTE3 = l_def_atl_rec.attribute3,
        ATTRIBUTE4 = l_def_atl_rec.attribute4,
        ATTRIBUTE5 = l_def_atl_rec.attribute5,
        ATTRIBUTE6 = l_def_atl_rec.attribute6,
        ATTRIBUTE7 = l_def_atl_rec.attribute7,
        ATTRIBUTE8 = l_def_atl_rec.attribute8,
        ATTRIBUTE9 = l_def_atl_rec.attribute9,
        ATTRIBUTE10 = l_def_atl_rec.attribute10,
        ATTRIBUTE11 = l_def_atl_rec.attribute11,
        ATTRIBUTE12 = l_def_atl_rec.attribute12,
        ATTRIBUTE13 = l_def_atl_rec.attribute13,
        ATTRIBUTE14 = l_def_atl_rec.attribute14,
        ATTRIBUTE15 = l_def_atl_rec.attribute15,
        CREATED_BY = l_def_atl_rec.created_by,
        CREATION_DATE = l_def_atl_rec.creation_date,
        LAST_UPDATED_BY = l_def_atl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_atl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_atl_rec.last_update_login
    WHERE ID = l_def_atl_rec.id;

    x_atl_rec := l_def_atl_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_AE_TMPT_LNES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type,
    x_atlv_rec                     OUT NOCOPY atlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atlv_rec                     atlv_rec_type := p_atlv_rec;
    l_def_atlv_rec                 atlv_rec_type;
    l_atl_rec                      atl_rec_type;
    lx_atl_rec                     atl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_atlv_rec	IN atlv_rec_type
    ) RETURN atlv_rec_type IS
      l_atlv_rec	atlv_rec_type := p_atlv_rec;
    BEGIN
      l_atlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_atlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_atlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_atlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_atlv_rec	IN atlv_rec_type,
      x_atlv_rec	OUT NOCOPY atlv_rec_type
    ) RETURN VARCHAR2 IS
      l_atlv_rec                     atlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atlv_rec := p_atlv_rec;
      -- Get current database values
      l_atlv_rec := get_rec(p_atlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_atlv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.id := l_atlv_rec.id;
      END IF;
      IF (x_atlv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.object_version_number := l_atlv_rec.object_version_number;
      END IF;
      IF (x_atlv_rec.avl_id = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.avl_id := l_atlv_rec.avl_id;
      END IF;
      IF (x_atlv_rec.crd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.crd_code := l_atlv_rec.crd_code;
      END IF;
      IF (x_atlv_rec.code_combination_id = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.code_combination_id := l_atlv_rec.code_combination_id;
      END IF;
      IF (x_atlv_rec.ae_line_type = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.ae_line_type := l_atlv_rec.ae_line_type;
      END IF;
      IF (x_atlv_rec.sequence_number = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.sequence_number := l_atlv_rec.sequence_number;
      END IF;
      IF (x_atlv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.description := l_atlv_rec.description;
      END IF;
      IF (x_atlv_rec.percentage = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.percentage := l_atlv_rec.percentage;
      END IF;
      IF (x_atlv_rec.account_builder_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.account_builder_yn := l_atlv_rec.account_builder_yn;
      END IF;
      IF (x_atlv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute_category := l_atlv_rec.attribute_category;
      END IF;
      IF (x_atlv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute1 := l_atlv_rec.attribute1;
      END IF;
      IF (x_atlv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute2 := l_atlv_rec.attribute2;
      END IF;
      IF (x_atlv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute3 := l_atlv_rec.attribute3;
      END IF;
      IF (x_atlv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute4 := l_atlv_rec.attribute4;
      END IF;
      IF (x_atlv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute5 := l_atlv_rec.attribute5;
      END IF;
      IF (x_atlv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute6 := l_atlv_rec.attribute6;
      END IF;
      IF (x_atlv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute7 := l_atlv_rec.attribute7;
      END IF;
      IF (x_atlv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute8 := l_atlv_rec.attribute8;
      END IF;
      IF (x_atlv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute9 := l_atlv_rec.attribute9;
      END IF;
      IF (x_atlv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute10 := l_atlv_rec.attribute10;
      END IF;
      IF (x_atlv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute11 := l_atlv_rec.attribute11;
      END IF;
      IF (x_atlv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute12 := l_atlv_rec.attribute12;
      END IF;
      IF (x_atlv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute13 := l_atlv_rec.attribute13;
      END IF;
      IF (x_atlv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute14 := l_atlv_rec.attribute14;
      END IF;
      IF (x_atlv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_atlv_rec.attribute15 := l_atlv_rec.attribute15;
      END IF;
      IF (x_atlv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.org_id := l_atlv_rec.org_id;
      END IF;
      IF (x_atlv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.created_by := l_atlv_rec.created_by;
      END IF;
      IF (x_atlv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_atlv_rec.creation_date := l_atlv_rec.creation_date;
      END IF;
      IF (x_atlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.last_updated_by := l_atlv_rec.last_updated_by;
      END IF;
      IF (x_atlv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_atlv_rec.last_update_date := l_atlv_rec.last_update_date;
      END IF;
      IF (x_atlv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_atlv_rec.last_update_login := l_atlv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_AE_TMPT_LNES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_atlv_rec IN  atlv_rec_type,
      x_atlv_rec OUT NOCOPY atlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atlv_rec := p_atlv_rec;
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
      p_atlv_rec,                        -- IN
      l_atlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_atlv_rec, l_def_atlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_atlv_rec := fill_who_columns(l_def_atlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_atlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_atlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_atlv_rec, l_atl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atl_rec,
      lx_atl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_atl_rec, l_def_atlv_rec);
    x_atlv_rec := l_def_atlv_rec;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:ATLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type,
    x_atlv_tbl                     OUT NOCOPY atlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i),
          x_atlv_rec                     => x_atlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- delete_row for:OKL_AE_TMPT_LNES --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atl_rec                      IN atl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atl_rec                      atl_rec_type:= p_atl_rec;
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
    DELETE FROM OKL_AE_TMPT_LNES
     WHERE ID = l_atl_rec.id;

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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_AE_TMPT_LNES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atlv_rec                     atlv_rec_type := p_atlv_rec;
    l_atl_rec                      atl_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_atlv_rec, l_atl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:ATLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
    END IF;
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
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_ATL_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKL_AVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AVL_PVT" AS
/* $Header: OKLSAVLB.pls 120.4 2007/01/29 10:50:38 ssdeshpa noship $ */

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_ITEM_NOT_FOUND_ERROR	EXCEPTION;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_name
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_name(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.name IS NULL) OR (p_avlv_rec.name = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'NAME');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
    END validate_name;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_set_of_books_id
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  -- 01/17/2007 Fixed Bug # 5707866  ssdeshpa start
  --            Removed Validation Logic for set_of_books_id column
  ---------------------------------------------------------------------------
/*  PROCEDURE validate_set_of_books_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_avlv_rec.set_of_books_id IS NULL) OR (p_avlv_rec.set_of_books_id = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'SET_OF_BOOKS_ID');
          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
  END validate_set_of_books_id; */
  --Fixed Bug # 5707866  ssdeshpa end
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_sty_id
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_sty_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    CURSOR sty_csr(v_sty_id NUMBER) IS
    SELECT '1'
    FROM OKL_STRM_TYPE_V
    WHERE ID = v_sty_id;

    l_dummy   VARCHAR2(1);


    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.sty_id IS NULL) OR (p_avlv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'STY_ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE

         OPEN sty_csr(p_avlv_rec.sty_id);
         FETCH sty_csr INTO l_dummy;
         IF (sty_csr%NOTFOUND) THEN
             OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                 p_msg_name => g_invalid_value,
                                 p_token1   => g_col_name_token,
                                 p_token1_value => 'STY_ID');

             x_return_status := OKC_API.G_RET_STS_ERROR;
             CLOSE sty_csr;
             RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE sty_csr;

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
    END validate_sty_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_try_id
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_try_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    CURSOR try_csr(v_try_id NUMBER) IS
    SELECT '1'
    FROM OKL_TRX_TYPES_V
    WHERE ID = v_try_id;

    l_dummy   VARCHAR2(1);


    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.try_id IS NULL) OR (p_avlv_rec.try_id = OKC_API.G_MISS_NUM) THEN

        OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                            p_msg_name => g_required_value,
                            p_token1   => g_col_name_token,
                            p_token1_value => 'TRY_ID');

        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSE

        OPEN try_csr(p_avlv_rec.try_id);
        FETCH try_csr INTO l_dummy;

        IF (try_csr%NOTFOUND) THEN
             OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                 p_msg_name => g_invalid_value,
                                 p_token1   => g_col_name_token,
                                 p_token1_value => 'TRY_ID');
             x_return_status := OKC_API.G_RET_STS_ERROR;
             CLOSE try_csr;
             RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        CLOSE try_csr;

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
    END validate_try_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_aes_id
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_aes_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    CURSOR aes_csr(v_aes_id NUMBER) IS
    SELECT '1'
    FROM OKL_AE_TMPT_SETS_V
    WHERE ID = v_aes_id;

    l_dummy  VARCHAR2(1);

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.aes_id IS NULL) OR (p_avlv_rec.aes_id = OKC_API.G_MISS_NUM) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'AES_ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE

         OPEN aes_csr(p_avlv_rec.aes_id);
         FETCH aes_csr INTO l_dummy;
         IF (aes_csr%NOTFOUND) THEN

             OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                 p_msg_name => g_invalid_value,
                                 p_token1   => g_col_name_token,
                                 p_token1_value => 'AES_ID');

             x_return_status := OKC_API.G_RET_STS_ERROR;
             CLOSE aes_csr;
             RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

         CLOSE aes_csr;

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
    END validate_aes_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_syt_code
  ---------------------------------------------------------------------------

    PROCEDURE validate_syt_code(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS
      l_dummy VARCHAR2(1);

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.syt_code IS NOT NULL) AND  (p_avlv_rec.syt_code <> OKC_API.G_MISS_CHAR) THEN

         l_dummy :=
         OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_SYNDICATION_CODE',
	                                           p_lookup_code => p_avlv_rec.syt_code);

         IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'SYT_CODE');

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
    END validate_syt_code;



  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fac_code
  ---------------------------------------------------------------------------

    PROCEDURE validate_fac_code(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS
      l_dummy VARCHAR2(1);

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.fac_code IS NOT NULL) AND  (p_avlv_rec.fac_code <> OKC_API.G_MISS_CHAR) THEN

         l_dummy :=
         OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_FACTORING_CODE',
	                                           p_lookup_code => p_avlv_rec.fac_code);

         IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'FAC_CODE');

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
    END validate_fac_code;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_factoring_synd_flag
  ---------------------------------------------------------------------------

    PROCEDURE validate_factoring_synd_flag(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS
      l_dummy VARCHAR2(1);

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.factoring_synd_flag IS NOT NULL) AND
       (p_avlv_rec.factoring_synd_flag <> OKC_API.G_MISS_CHAR) THEN

         l_dummy :=
         OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_FACTORING_SYNDICATION',
	                                     p_lookup_code => p_avlv_rec.factoring_synd_flag);

         IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'FACTORING_SYND_FLAG');

            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

 /*       IF (p_avlv_rec.factoring_synd_flag = 'FACTORING') THEN

            IF (p_avlv_rec.FAC_CODE IS NULL) OR (p_avlv_rec.FAC_CODE = OKL_API.G_MISS_CHAR) THEN

               OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => g_required_value,
                                   p_token1       => g_col_name_token,
                                   p_token1_value => 'FAC_CODE');
               x_return_status := OKC_API.G_RET_STS_ERROR;
               RAISE G_EXCEPTION_HALT_VALIDATION;

            END IF;

        ELSIF (p_avlv_rec.factoring_synd_flag = 'SYNDICATION') THEN

            IF (p_avlv_rec.SYT_CODE IS NULL) OR (p_avlv_rec.SYT_CODE = OKL_API.G_MISS_CHAR) THEN

               OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                   p_msg_name     => g_required_value,
                                   p_token1       => g_col_name_token,
                                   p_token1_value => 'SYT_CODE');
               x_return_status := OKC_API.G_RET_STS_ERROR;
               RAISE G_EXCEPTION_HALT_VALIDATION;

            END IF;

        ELSIF (p_avlv_rec.factoring_synd_flag = 'INVESTOR') THEN

	    IF (p_avlv_rec.INV_CODE IS NULL) OR (p_avlv_rec.INV_CODE = OKL_API.G_MISS_CHAR) THEN

	               OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
	                                   p_msg_name     => g_required_value,
	                                   p_token1       => g_col_name_token,
	                                   p_token1_value => 'INV_CODE');
	               x_return_status := OKC_API.G_RET_STS_ERROR;
	               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

        END IF;
  */

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
    END validate_factoring_synd_flag;


-- Santonyr 18th Jul, 2002.
-- Removed the validation as the field is removed from the screen

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_advance_arrears
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_advance_arrears
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  ---------------------------------------------------------------------------
    PROCEDURE validate_advance_arrears(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    l_dummy varchar2(1);

    BEGIN
    x_return_status 	:= OKC_API.G_RET_STS_SUCCESS;

  IF (p_avlv_rec.advance_arrears IS NOT NULL) AND
     (p_avlv_rec.advance_arrears <> OKC_API.G_MISS_CHAR) THEN

      l_dummy :=
      OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_ADVANCE_ARREARS',
	                                        p_lookup_code => p_avlv_rec.advance_arrears);

      IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'ADVANCE_ARREARS');

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
  END validate_advance_arrears;
*/

-- Santonyr 18th Jul, 2002.
-- Removed the validation as the field is removed from the screen

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_Accrual_yn
 -- Validates the field ACCRUAL_YN to be Not NULL and to be Y or N
  ---------------------------------------------------------------------------
    PROCEDURE validate_accrual_yn(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    l_dummy VARCHAR2(1);
    l_app_id  NUMBER := 0;
    l_view_app_id NUMBER := 0;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.accrual_yn IS NULL) OR (p_avlv_rec.accrual_yn = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ACCRUAL_YN');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
         l_dummy :=
         OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'YES_NO',
	                                           p_lookup_code => p_avlv_rec.accrual_yn,
	                                           p_app_id => l_app_id,
	                                           p_view_app_id => l_view_app_id);
         IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'ACCRUAL_YN');

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

    END validate_accrual_yn;
*/


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_post_to_gl
    -- 01/17/2007 Fixed Bug # 5707866  ssdeshpa
  --            Removed Validation Logic for post_to_gl column
  ---------------------------------------------------------------------------
  /*  PROCEDURE validate_post_to_gl(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS

    l_dummy VARCHAR2(1);
    l_app_id  NUMBER := 0;
    l_view_app_id NUMBER := 0;

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.post_to_gl IS NULL) OR (p_avlv_rec.post_to_gl = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'POST_TO_GL');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
         l_dummy :=
         OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'YES_NO',
	                                           p_lookup_code => p_avlv_rec.post_to_gl,
	                                           p_app_id => l_app_id,
	                                           p_view_app_id => l_view_app_id);
         IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'POST_TO_GL');

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
    END validate_post_to_gl; */
  --Fixed Bug # 5707866  ssdeshpa end.
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_version
  -- 04/27/2001 Inserted by Robin Edwin for not null validation
  -- 01/17/2007 Fixed Bug # 5707866  ssdeshpa start
  --            Removed Validation Logic for version column
  ---------------------------------------------------------------------------
  /*  PROCEDURE validate_version(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.version IS NULL) OR (p_avlv_rec.version = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'VERSION');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
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
    END validate_version;*/
 --Fixed Bug # 5707866  ssdeshpa end
---------------------------------------------------------------------------
-- PROCEDURE Validate_Unique_Avl_Record
---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Avl_Record(x_return_status OUT NOCOPY     VARCHAR2
                                      ,p_avlv_rec      IN      avlv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_avlv_status           VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  l_dummy                 VARCHAR2(1);
  l_start_date            DATE;
  l_end_date              DATE;

  CURSOR c1 IS
  SELECT start_date,
         end_date
  FROM 	 OKL_AE_TEMPLATES
  WHERE  try_id = p_avlv_rec.try_id
  AND 	 nvl(org_id,-99) = nvl(p_avlv_rec.org_id,-99)
  AND	 sty_id = p_avlv_rec.sty_id
  AND	 aes_id = p_avlv_rec.aes_id
  AND	 nvl(advance_arrears,'AA')  = nvl(p_avlv_rec.advance_arrears ,'AA')
  AND	 memo_yn = p_avlv_rec.memo_yn
  AND    prior_year_yn = p_avlv_rec.prior_year_yn
  AND    nvl(factoring_synd_flag,'N') = nvl(p_Avlv_rec.factoring_synd_flag,'N')
  AND    id <> p_avlv_rec.ID;


  CURSOR avl_csr(v_name OKL_AE_TEMPLATES.NAME%TYPE,
                 v_version OKL_AE_TEMPLATES.version%TYPE,
                 v_aes_id OKL_AE_TEMPLATES.aes_id%TYPE ) IS
  SELECT '1'
  FROM OKL_AE_TEMPLATES
  WHERE name    = v_name
  AND   version = v_version
  AND aes_id = v_aes_id
  AND ID <> p_avlv_rec.ID;



  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- Following section commented by Kanti. This check will be enforced thru process
-- API.

/*    OPEN c1;

    FETCH c1 INTO l_start_date,
                  l_end_date;
    l_row_found := c1%FOUND;
    CLOSE c1;

-- If record with all the similar information exists then check that the new record
-- being inserted does not overlap with the existing date range

    IF (l_row_found) THEN

        IF (p_avlv_rec.start_date <= l_end_date) THEN
            OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_TMPL_DATE_OVERLAPS');
  	    x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

    END IF;

*/

    OPEN avl_csr(p_avlv_rec.name,
                 p_avlv_rec.version,
                 p_avlv_rec.aes_id );
    FETCH avl_csr INTO l_dummy;
    IF (avl_csr%FOUND) THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_NAME_VERSION_NOT_UNIQUE');
	x_return_status := OKC_API.G_RET_STS_ERROR;
        CLOSE avl_csr;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE avl_csr;

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

  END Validate_Unique_Avl_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_fma_id
  -- 05/11/2001 Inserted by Robin Edwin for fk validation
  ---------------------------------------------------------------------------

  PROCEDURE validate_fma_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_avlv_rec IN  avlv_rec_type) IS

  CURSOR okl_fma_id_csr(v_fma_id NUMBER) IS
  SELECT 	'1'
  FROM 	OKL_FORMULAE_V
  WHERE 	id = v_fma_id;

  l_fma_id 		NUMBER;
  l_row_notfound	BOOLEAN 	:= TRUE;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.fma_id IS NOT NULL) AND (p_avlv_rec.fma_id <> OKC_API.G_MISS_NUM) THEN
        OPEN okl_fma_id_csr(p_avlv_rec.fma_id);
        FETCH okl_fma_id_csr INTO l_fma_id;
        l_row_notfound := okl_fma_id_csr%NOTFOUND;
        CLOSE okl_fma_id_csr;

      IF(l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'FMA_ID');
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

  END validate_fma_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_memo_yn
  -- 05/11/2001
  ---------------------------------------------------------------------------
   PROCEDURE validate_memo_yn(x_return_status OUT NOCOPY VARCHAR2,
                              p_avlv_rec IN  avlv_rec_type) IS

    l_dummy VARCHAR2(1);
    l_app_id NUMBER := 0;
    l_view_app_id NUMBER := 0;

  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.MEMO_YN IS NULL) OR (p_avlv_rec.MEMO_YN = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'MEMO_YN');

        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        l_dummy :=
        OKL_ACCOUNTING_UTIL.validate_lookup_code(p_lookup_type => 'YES_NO',
	                                          p_lookup_code => p_avlv_rec.memo_yn,
	                                          p_app_id => l_app_id,
	                                          p_view_app_id => l_view_app_id);
        IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'MEMO_YN');

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

  END validate_memo_yn;

-- Santonyr 18th Jul, 2002.
-- Removed the validation as the field is removed from the screen

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_prior_year_yn
  -- 05/11/2001
  ---------------------------------------------------------------------------
   PROCEDURE validate_prior_year_yn(x_return_status OUT NOCOPY VARCHAR2,
                                    p_avlv_rec IN  avlv_rec_type) IS

    l_dummy VARCHAR2(1);
    l_app_id NUMBER := 0;
    l_view_app_id NUMBER := 0;

  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.PRIOR_YEAR_YN IS NULL) OR (p_avlv_rec.PRIOR_YEAR_YN = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'PRIOR_YEAR_YN');

        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        l_dummy :=
        OKL_ACCOUNTING_UTIL.validate_lookup_code(p_lookup_type => 'YES_NO',
	                                          p_lookup_code => p_avlv_rec.prior_year_yn,
	                                          p_app_id => l_app_id,
	                                          p_view_app_id => l_view_app_id);
        IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'PRIOR_YEAR_YN');

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

  END validate_prior_year_yn;
*/

-- Added by HKPATEL for securitization changes
---------------------------------------------------------------------------
  -- PROCEDURE validate_inv_code
  ---------------------------------------------------------------------------

    PROCEDURE validate_inv_code(
      x_return_status OUT NOCOPY VARCHAR2,
      p_avlv_rec IN  avlv_rec_type
    ) IS
      l_dummy VARCHAR2(1);

    BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_avlv_rec.inv_code IS NOT NULL) AND  (p_avlv_rec.inv_code <> OKC_API.G_MISS_CHAR) THEN

         l_dummy :=
         OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_INVESTOR_CODE',
	                                           p_lookup_code => p_avlv_rec.inv_code);

         IF (l_dummy = OKC_API.G_FALSE) THEN

            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_invalid_value,
                                p_token1   => g_col_name_token,
                                p_token1_value => 'INV_CODE');

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
    END validate_inv_code;

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
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
  -- FUNCTION get_rec for: OKL_AE_TEMPLATES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_avl_rec                      IN avl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN avl_rec_type IS
    CURSOR okl_ae_templates_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            SET_OF_BOOKS_ID,
            STY_ID,
            TRY_ID,
            AES_ID,
            SYT_CODE,
            FAC_CODE,
            FMA_ID,
            ADVANCE_ARREARS,
            POST_TO_GL,
            VERSION,
            START_DATE,
            OBJECT_VERSION_NUMBER,
            MEMO_YN,
            PRIOR_YEAR_YN,
            DESCRIPTION,
            FACTORING_SYND_FLAG,
            END_DATE,
            ACCRUAL_YN,
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
            LAST_UPDATE_LOGIN,
 -- Added by HKPATEL for securitization changes
  	    INV_CODE
      FROM Okl_Ae_Templates
     WHERE okl_ae_templates.id  = p_id;
    l_okl_ae_templates_pk          okl_ae_templates_pk_csr%ROWTYPE;
    l_avl_rec                      avl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ae_templates_pk_csr (p_avl_rec.id);
    FETCH okl_ae_templates_pk_csr INTO
              l_avl_rec.ID,
              l_avl_rec.NAME,
              l_avl_rec.SET_OF_BOOKS_ID,
              l_avl_rec.STY_ID,
              l_avl_rec.TRY_ID,
              l_avl_rec.AES_ID,
              l_avl_rec.SYT_CODE,
              l_avl_rec.FAC_CODE,
              l_avl_rec.FMA_ID,
              l_avl_rec.ADVANCE_ARREARS,
              l_avl_rec.POST_TO_GL,
              l_avl_rec.VERSION,
              l_avl_rec.START_DATE,
              l_avl_rec.OBJECT_VERSION_NUMBER,
              l_avl_rec.MEMO_YN,
              l_avl_rec.PRIOR_YEAR_YN,
              l_avl_rec.DESCRIPTION,
              l_avl_rec.FACTORING_SYND_FLAG,
              l_avl_rec.END_DATE,
              l_avl_rec.ACCRUAL_YN,
              l_avl_rec.ORG_ID,
              l_avl_rec.ATTRIBUTE_CATEGORY,
              l_avl_rec.ATTRIBUTE1,
              l_avl_rec.ATTRIBUTE2,
              l_avl_rec.ATTRIBUTE3,
              l_avl_rec.ATTRIBUTE4,
              l_avl_rec.ATTRIBUTE5,
              l_avl_rec.ATTRIBUTE6,
              l_avl_rec.ATTRIBUTE7,
              l_avl_rec.ATTRIBUTE8,
              l_avl_rec.ATTRIBUTE9,
              l_avl_rec.ATTRIBUTE10,
              l_avl_rec.ATTRIBUTE11,
              l_avl_rec.ATTRIBUTE12,
              l_avl_rec.ATTRIBUTE13,
              l_avl_rec.ATTRIBUTE14,
              l_avl_rec.ATTRIBUTE15,
              l_avl_rec.CREATED_BY,
              l_avl_rec.CREATION_DATE,
              l_avl_rec.LAST_UPDATED_BY,
              l_avl_rec.LAST_UPDATE_DATE,
              l_avl_rec.LAST_UPDATE_LOGIN,
  -- Added by HKPATEL for securitization changes
  	      l_avl_rec.INV_CODE;
    x_no_data_found := okl_ae_templates_pk_csr%NOTFOUND;
    CLOSE okl_ae_templates_pk_csr;
    RETURN(l_avl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_avl_rec                      IN avl_rec_type
  ) RETURN avl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_avl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AE_TEMPLATES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_avlv_rec                     IN avlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN avlv_rec_type IS
    CURSOR okl_avlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TRY_ID,
            AES_ID,
            STY_ID,
            FMA_ID,
            SET_OF_BOOKS_ID,
            FAC_CODE,
            SYT_CODE,
            POST_TO_GL,
            ADVANCE_ARREARS,
            MEMO_YN,
            PRIOR_YEAR_YN,
            NAME,
            DESCRIPTION,
            VERSION,
            FACTORING_SYND_FLAG,
            START_DATE,
            END_DATE,
            ACCRUAL_YN,
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
            LAST_UPDATE_LOGIN,
   -- Added by HKPATEL for securitization changes
   	    INV_CODE
      FROM OKL_AE_TEMPLATES
     WHERE OKL_AE_TEMPLATES.id = p_id;
    l_okl_avlv_pk                  okl_avlv_pk_csr%ROWTYPE;
    l_avlv_rec                     avlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_avlv_pk_csr (p_avlv_rec.id);
    FETCH okl_avlv_pk_csr INTO
              l_avlv_rec.ID,
              l_avlv_rec.OBJECT_VERSION_NUMBER,
              l_avlv_rec.TRY_ID,
              l_avlv_rec.AES_ID,
              l_avlv_rec.STY_ID,
              l_avlv_rec.FMA_ID,
              l_avlv_rec.SET_OF_BOOKS_ID,
              l_avlv_rec.FAC_CODE,
              l_avlv_rec.SYT_CODE,
              l_avlv_rec.POST_TO_GL,
              l_avlv_rec.ADVANCE_ARREARS,
              l_avlv_rec.MEMO_YN,
              l_avlv_rec.PRIOR_YEAR_YN,
              l_avlv_rec.NAME,
              l_avlv_rec.DESCRIPTION,
              l_avlv_rec.VERSION,
              l_avlv_rec.FACTORING_SYND_FLAG,
              l_avlv_rec.START_DATE,
              l_avlv_rec.END_DATE,
              l_avlv_rec.ACCRUAL_YN,
              l_avlv_rec.ATTRIBUTE_CATEGORY,
              l_avlv_rec.ATTRIBUTE1,
              l_avlv_rec.ATTRIBUTE2,
              l_avlv_rec.ATTRIBUTE3,
              l_avlv_rec.ATTRIBUTE4,
              l_avlv_rec.ATTRIBUTE5,
              l_avlv_rec.ATTRIBUTE6,
              l_avlv_rec.ATTRIBUTE7,
              l_avlv_rec.ATTRIBUTE8,
              l_avlv_rec.ATTRIBUTE9,
              l_avlv_rec.ATTRIBUTE10,
              l_avlv_rec.ATTRIBUTE11,
              l_avlv_rec.ATTRIBUTE12,
              l_avlv_rec.ATTRIBUTE13,
              l_avlv_rec.ATTRIBUTE14,
              l_avlv_rec.ATTRIBUTE15,
              l_avlv_rec.ORG_ID,
              l_avlv_rec.CREATED_BY,
              l_avlv_rec.CREATION_DATE,
              l_avlv_rec.LAST_UPDATED_BY,
              l_avlv_rec.LAST_UPDATE_DATE,
              l_avlv_rec.LAST_UPDATE_LOGIN,
   -- Added by HKPATEL for securitization changes
   	      l_avlv_rec.INV_CODE;
    x_no_data_found := okl_avlv_pk_csr%NOTFOUND;
    CLOSE okl_avlv_pk_csr;
    RETURN(l_avlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_avlv_rec                     IN avlv_rec_type
  ) RETURN avlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_avlv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AE_TEMPLATES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_avlv_rec	IN avlv_rec_type
  ) RETURN avlv_rec_type IS
    l_avlv_rec	avlv_rec_type := p_avlv_rec;
  BEGIN
    IF (l_avlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.object_version_number := NULL;
    END IF;
    IF (l_avlv_rec.try_id = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.try_id := NULL;
    END IF;
    IF (l_avlv_rec.aes_id = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.aes_id := NULL;
    END IF;
    IF (l_avlv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.sty_id := NULL;
    END IF;
    IF (l_avlv_rec.fma_id = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.fma_id := NULL;
    END IF;
    IF (l_avlv_rec.set_of_books_id = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_avlv_rec.fac_code = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.fac_code := NULL;
    END IF;
    IF (l_avlv_rec.syt_code = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.syt_code := NULL;
    END IF;
    IF (l_avlv_rec.post_to_gl = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.post_to_gl := NULL;
    END IF;
    IF (l_avlv_rec.advance_arrears = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.advance_arrears := NULL;
    END IF;
    IF (l_avlv_rec.memo_yn = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.memo_yn := NULL;
    END IF;
    IF (l_avlv_rec.prior_year_yn = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.prior_year_yn := NULL;
    END IF;
    IF (l_avlv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.name := NULL;
    END IF;
    IF (l_avlv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.description := NULL;
    END IF;
    IF (l_avlv_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.version := NULL;
    END IF;
    IF (l_avlv_rec.factoring_synd_flag = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.factoring_synd_flag := NULL;
    END IF;
    IF (l_avlv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_avlv_rec.start_date := NULL;
    END IF;
    IF (l_avlv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_avlv_rec.end_date := NULL;
    END IF;
    IF (l_avlv_rec.accrual_yn = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.accrual_yn := NULL;
    END IF;
    IF (l_avlv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute_category := NULL;
    END IF;
    IF (l_avlv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute1 := NULL;
    END IF;
    IF (l_avlv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute2 := NULL;
    END IF;
    IF (l_avlv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute3 := NULL;
    END IF;
    IF (l_avlv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute4 := NULL;
    END IF;
    IF (l_avlv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute5 := NULL;
    END IF;
    IF (l_avlv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute6 := NULL;
    END IF;
    IF (l_avlv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute7 := NULL;
    END IF;
    IF (l_avlv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute8 := NULL;
    END IF;
    IF (l_avlv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute9 := NULL;
    END IF;
    IF (l_avlv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute10 := NULL;
    END IF;
    IF (l_avlv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute11 := NULL;
    END IF;
    IF (l_avlv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute12 := NULL;
    END IF;
    IF (l_avlv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute13 := NULL;
    END IF;
    IF (l_avlv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute14 := NULL;
    END IF;
    IF (l_avlv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.attribute15 := NULL;
    END IF;
    IF (l_avlv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.org_id := NULL;
    END IF;
    IF (l_avlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.created_by := NULL;
    END IF;
    IF (l_avlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_avlv_rec.creation_date := NULL;
    END IF;
    IF (l_avlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_avlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_avlv_rec.last_update_date := NULL;
    END IF;
    IF (l_avlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_avlv_rec.last_update_login := NULL;
    END IF;
 -- Added by HKPATEL for securitization channges
    IF (l_avlv_rec.inv_code = OKC_API.G_MISS_CHAR) THEN
      l_avlv_rec.inv_code := NULL;
    END IF;
    RETURN(l_avlv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_AE_TEMPLATES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_avlv_rec IN  avlv_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    validate_name(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    /* Fixed Bug # 5707866  ssdeshpa start
      --Removing Validation Logic for SET_OF_BOOKS_ID
      --Since This Column are NULL */
   /* validate_set_of_books_id(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF; */
   --Fixed Bug # 5707866  ssdeshpa end

    validate_sty_id(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_try_id(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_aes_id(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_syt_code(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fac_code(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;


    validate_factoring_synd_flag(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    validate_fma_id(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

-- Santonyr 18th Jul, 2002.
-- Removed the validation as the field is removed from the screen

/*
    validate_advance_arrears(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
*/
    /* Fixed Bug # 5707866  ssdeshpa start
      --Removing Validation Logic for POST_TO_GL
      --Since This Column are NULL */
    /*validate_post_to_gl(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF; */
    -- Fixed Bug # 5707866  ssdeshpa End
-- Santonyr 18th Jul, 2002.
-- Removed the validation as the field is removed from the screen

/*
    validate_accrual_yn(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
*/
    /* Fixed Bug # 5707866  ssdeshpa start
      --Removing Validation Logic for VERSION
      --Since This Column are NULL */
  /*  validate_version(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;*/
    --Fixed Bug # 5707866  ssdeshpa End

    validate_memo_yn(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

-- Santonyr 18th Jul, 2002.
-- Removed the validation as the field is removed from the screen

/*
    validate_prior_year_yn(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
*/
-- Added by HKPATEL for securitization changes
    validate_inv_code(x_return_status => l_return_status, p_avlv_rec => p_avlv_rec);
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
           END IF;
    END IF;

    RETURN(x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => SQLCODE,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => SQLERRM);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;
END;

  --END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_AE_TEMPLATES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_avlv_rec IN avlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Tcn_Record
    Validate_Unique_Avl_Record(x_return_status, p_avlv_rec);
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
    p_from	IN avlv_rec_type,
    p_to	IN OUT NOCOPY avl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.sty_id := p_from.sty_id;
    p_to.try_id := p_from.try_id;
    p_to.aes_id := p_from.aes_id;
    p_to.syt_code := p_from.syt_code;
    p_to.fac_code := p_from.fac_code;
    p_to.fma_id := p_from.fma_id;
    p_to.advance_arrears := p_from.advance_arrears;
    p_to.post_to_gl := p_from.post_to_gl;
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.memo_yn := p_from.memo_yn;
    p_to.prior_year_yn := p_from.prior_year_yn;
    p_to.description := p_from.description;
    p_to.factoring_synd_flag := p_from.factoring_synd_flag;
    p_to.end_date := p_from.end_date;
    p_to.accrual_yn := p_from.accrual_yn;
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
 -- Added by HKPATEL for securitization changes
    p_to.inv_code := p_from.inv_code;
  END migrate;
  PROCEDURE migrate (
    p_from	IN avl_rec_type,
    p_to	OUT NOCOPY avlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.sty_id := p_from.sty_id;
    p_to.try_id := p_from.try_id;
    p_to.aes_id := p_from.aes_id;
    p_to.syt_code := p_from.syt_code;
    p_to.fac_code := p_from.fac_code;
    p_to.fma_id := p_from.fma_id;
    p_to.advance_arrears := p_from.advance_arrears;
    p_to.post_to_gl := p_from.post_to_gl;
    p_to.version := p_from.version;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.memo_yn := p_from.memo_yn;
    p_to.prior_year_yn := p_from.prior_year_yn;
    p_to.description := p_from.description;
    p_to.factoring_synd_flag := p_from.factoring_synd_flag;
    p_to.end_date := p_from.end_date;
    p_to.accrual_yn := p_from.accrual_yn;
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
 -- Added by HKPATEL for securitization changes
    p_to.inv_code := p_from.inv_code;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_AE_TEMPLATES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avlv_rec                     avlv_rec_type := p_avlv_rec;
    l_avl_rec                      avl_rec_type;
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
    l_return_status := Validate_Attributes(l_avlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_avlv_rec);
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
  -- PL/SQL TBL validate_row for:AVLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
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
  -- insert_row for:OKL_AE_TEMPLATES --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avl_rec                      IN avl_rec_type,
    x_avl_rec                      OUT NOCOPY avl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avl_rec                      avl_rec_type := p_avl_rec;
    l_def_avl_rec                  avl_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_TEMPLATES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_avl_rec IN  avl_rec_type,
      x_avl_rec OUT NOCOPY avl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_avl_rec := p_avl_rec;
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
      p_avl_rec,                         -- IN
      l_avl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
     /* Fixed Bug # 5707866  ssdeshpa start
     --Insert NULL Value for following Columns
     -- SET_OF_BOOKS_ID,POST_TO_GL,VERSION,ACCRUAL_YN
     --Since This Column are no longer Used */
     INSERT INTO OKL_AE_TEMPLATES(
         id,
         name,
         set_of_books_id,
         sty_id,
         try_id,
         aes_id,
         syt_code,
         fac_code,
         fma_id,
         advance_arrears,
         post_to_gl,
         version,
         start_date,
         object_version_number,
         memo_yn,
         prior_year_yn,
         description,
         factoring_synd_flag,
         end_date,
         accrual_yn,
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
         last_update_login,
   -- Added by HKPATEL for securitization changes
   	inv_code)
       VALUES (
         l_avl_rec.id,
         l_avl_rec.name,
         --l_avl_rec.set_of_books_id,
         null,
         l_avl_rec.sty_id,
         l_avl_rec.try_id,
         l_avl_rec.aes_id,
         l_avl_rec.syt_code,
         l_avl_rec.fac_code,
         l_avl_rec.fma_id,
         l_avl_rec.advance_arrears,
         --l_avl_rec.post_to_gl,
         null,
         --l_avl_rec.version,
         null,
         l_avl_rec.start_date,
         l_avl_rec.object_version_number,
         l_avl_rec.memo_yn,
         l_avl_rec.prior_year_yn,
         l_avl_rec.description,
         l_avl_rec.factoring_synd_flag,
         l_avl_rec.end_date,
         --l_avl_rec.accrual_yn,
         null,
         l_avl_rec.org_id,
         l_avl_rec.attribute_category,
         l_avl_rec.attribute1,
         l_avl_rec.attribute2,
         l_avl_rec.attribute3,
         l_avl_rec.attribute4,
         l_avl_rec.attribute5,
         l_avl_rec.attribute6,
         l_avl_rec.attribute7,
         l_avl_rec.attribute8,
         l_avl_rec.attribute9,
         l_avl_rec.attribute10,
         l_avl_rec.attribute11,
         l_avl_rec.attribute12,
         l_avl_rec.attribute13,
         l_avl_rec.attribute14,
         l_avl_rec.attribute15,
         l_avl_rec.created_by,
         l_avl_rec.creation_date,
         l_avl_rec.last_updated_by,
         l_avl_rec.last_update_date,
         l_avl_rec.last_update_login,
    -- Added by HKPATEL for securitization changes
    	l_avl_rec.inv_code);
    -- Fixed Bug # 5707866  ssdeshpa End
    -- Set OUT values
    x_avl_rec := l_avl_rec;
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
  -- insert_row for:OKL_AE_TEMPLATES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type,
    x_avlv_rec                     OUT NOCOPY avlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avlv_rec                     avlv_rec_type;
    l_def_avlv_rec                 avlv_rec_type;
    l_avl_rec                      avl_rec_type;
    lx_avl_rec                     avl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------

    FUNCTION fill_who_columns (
      p_avlv_rec	IN avlv_rec_type
    ) RETURN avlv_rec_type IS
      l_avlv_rec	avlv_rec_type := p_avlv_rec;
    BEGIN
      l_avlv_rec.CREATION_DATE := SYSDATE;
      l_avlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_avlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_avlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_avlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_avlv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_AE_TEMPLATES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_avlv_rec IN  avlv_rec_type,
      x_avlv_rec OUT NOCOPY avlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_avlv_rec := p_avlv_rec;
      x_avlv_rec.OBJECT_VERSION_NUMBER := 1;
      /*Fixed Bug # 5707866  ssdeshpa start
      --Removing Defaulting Logic for POST_TO_GL , SET_OF_BOOKS_ID , ACCRUAL_YN
      --;Since This Column are NULL */
      --x_avlv_rec.POST_TO_GL := 'Y'; -- this field is not used, so a default provided
      x_avlv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
      --x_avlv_rec.set_of_books_id := OKL_ACCOUNTING_UTIL.get_Set_of_books_id;

      x_avlv_rec.NAME := UPPER(x_avlv_rec.NAME);
-- Santonyr 18th Jul, 2002.
-- Added the code to set the default value for accrual_yn
    --  x_avlv_rec.accrual_yn := 'N';
 --Fixed Bug # 5707866  ssdeshpa end
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

    l_avlv_rec := null_out_defaults(p_avlv_rec);
    -- Set primary key value
    l_avlv_rec.ID := get_seq_id;
    --- Setting item attributes


    l_return_status := Set_Attributes(
      l_avlv_rec,                        -- IN
      l_def_avlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_avlv_rec := fill_who_columns(l_def_avlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_avlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_avlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_avlv_rec, l_avl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_avl_rec,
      lx_avl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_avl_rec, l_def_avlv_rec);
    -- Set OUT values
    x_avlv_rec := l_def_avlv_rec;
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
  -- PL/SQL TBL insert_row for:AVLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type,
    x_avlv_tbl                     OUT NOCOPY avlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i),
          x_avlv_rec                     => x_avlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
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
  -- lock_row for:OKL_AE_TEMPLATES --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avl_rec                      IN avl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_avl_rec IN avl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_TEMPLATES
     WHERE ID = p_avl_rec.id
       AND OBJECT_VERSION_NUMBER = p_avl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_avl_rec IN avl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AE_TEMPLATES
    WHERE ID = p_avl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_AE_TEMPLATES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_AE_TEMPLATES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_avl_rec);
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
      OPEN lchk_csr(p_avl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_avl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_avl_rec.object_version_number THEN
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
  -- lock_row for:OKL_AE_TEMPLATES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avl_rec                      avl_rec_type;
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
    migrate(p_avlv_rec, l_avl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_avl_rec
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
  -- PL/SQL TBL lock_row for:AVLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
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
  -- update_row for:OKL_AE_TEMPLATES --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avl_rec                      IN avl_rec_type,
    x_avl_rec                      OUT NOCOPY avl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avl_rec                      avl_rec_type := p_avl_rec;
    l_def_avl_rec                  avl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_avl_rec	IN avl_rec_type,
      x_avl_rec	OUT NOCOPY avl_rec_type
    ) RETURN VARCHAR2 IS
      l_avl_rec                      avl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_avl_rec := p_avl_rec;
      -- Get current database values
      l_avl_rec := get_rec(p_avl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_avl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.id := l_avl_rec.id;
      END IF;
      IF (x_avl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.name := l_avl_rec.name;
      END IF;
      IF (x_avl_rec.set_of_books_id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.set_of_books_id := l_avl_rec.set_of_books_id;
      END IF;
      IF (x_avl_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.sty_id := l_avl_rec.sty_id;
      END IF;
      IF (x_avl_rec.try_id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.try_id := l_avl_rec.try_id;
      END IF;
      IF (x_avl_rec.aes_id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.aes_id := l_avl_rec.aes_id;
      END IF;
      IF (x_avl_rec.syt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.syt_code := l_avl_rec.syt_code;
      END IF;
      IF (x_avl_rec.fac_code = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.fac_code := l_avl_rec.fac_code;
      END IF;
      IF (x_avl_rec.fma_id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.fma_id := l_avl_rec.fma_id;
      END IF;
      IF (x_avl_rec.advance_arrears = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.advance_arrears := l_avl_rec.advance_arrears;
      END IF;
      IF (x_avl_rec.post_to_gl = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.post_to_gl := l_avl_rec.post_to_gl;
      END IF;
      IF (x_avl_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.version := l_avl_rec.version;
      END IF;
      IF (x_avl_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_avl_rec.start_date := l_avl_rec.start_date;
      END IF;
      IF (x_avl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.object_version_number := l_avl_rec.object_version_number;
      END IF;
      IF (x_avl_rec.memo_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.memo_yn := l_avl_rec.memo_yn;
      END IF;
      IF (x_avl_rec.prior_year_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.prior_year_yn := l_avl_rec.prior_year_yn;
      END IF;
      IF (x_avl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.description := l_avl_rec.description;
      END IF;
      IF (x_avl_rec.factoring_synd_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.factoring_synd_flag := l_avl_rec.factoring_synd_flag;
      END IF;
      IF (x_avl_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_avl_rec.end_date := l_avl_rec.end_date;
      END IF;
      IF (x_avl_rec.accrual_yn  = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.accrual_yn := l_avl_rec.accrual_yn;
      END IF;
      IF (x_avl_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.org_id := l_avl_rec.org_id;
      END IF;
      IF (x_avl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute_category := l_avl_rec.attribute_category;
      END IF;
      IF (x_avl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute1 := l_avl_rec.attribute1;
      END IF;
      IF (x_avl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute2 := l_avl_rec.attribute2;
      END IF;
      IF (x_avl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute3 := l_avl_rec.attribute3;
      END IF;
      IF (x_avl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute4 := l_avl_rec.attribute4;
      END IF;
      IF (x_avl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute5 := l_avl_rec.attribute5;
      END IF;
      IF (x_avl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute6 := l_avl_rec.attribute6;
      END IF;
      IF (x_avl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute7 := l_avl_rec.attribute7;
      END IF;
      IF (x_avl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute8 := l_avl_rec.attribute8;
      END IF;
      IF (x_avl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute9 := l_avl_rec.attribute9;
      END IF;
      IF (x_avl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute10 := l_avl_rec.attribute10;
      END IF;
      IF (x_avl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute11 := l_avl_rec.attribute11;
      END IF;
      IF (x_avl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute12 := l_avl_rec.attribute12;
      END IF;
      IF (x_avl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute13 := l_avl_rec.attribute13;
      END IF;
      IF (x_avl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute14 := l_avl_rec.attribute14;
      END IF;
      IF (x_avl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.attribute15 := l_avl_rec.attribute15;
      END IF;
      IF (x_avl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.created_by := l_avl_rec.created_by;
      END IF;
      IF (x_avl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_avl_rec.creation_date := l_avl_rec.creation_date;
      END IF;
      IF (x_avl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.last_updated_by := l_avl_rec.last_updated_by;
      END IF;
      IF (x_avl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_avl_rec.last_update_date := l_avl_rec.last_update_date;
      END IF;
      IF (x_avl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_avl_rec.last_update_login := l_avl_rec.last_update_login;
      END IF;
  -- Added by HKPATEL for securitization changes
      IF (x_avl_rec.inv_code = OKC_API.G_MISS_CHAR)
      THEN
        x_avl_rec.inv_code := l_avl_rec.inv_code;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_AE_TEMPLATES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_avl_rec IN  avl_rec_type,
      x_avl_rec OUT NOCOPY avl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_avl_rec := p_avl_rec;
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
      p_avl_rec,                         -- IN
      l_avl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_avl_rec, l_def_avl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_AE_TEMPLATES
    SET NAME = l_def_avl_rec.name,
        SET_OF_BOOKS_ID = l_def_avl_rec.set_of_books_id,
        STY_ID = l_def_avl_rec.sty_id,
        TRY_ID = l_def_avl_rec.try_id,
        AES_ID = l_def_avl_rec.aes_id,
        SYT_CODE = l_def_avl_rec.syt_code,
        FAC_CODE = l_def_avl_rec.fac_code,
        FMA_ID = l_def_avl_rec.fma_id,
        ADVANCE_ARREARS = l_def_avl_rec.advance_arrears,
        POST_TO_GL = l_def_avl_rec.post_to_gl,
        VERSION = l_def_avl_rec.version,
        START_DATE = l_def_avl_rec.start_date,
        OBJECT_VERSION_NUMBER = l_def_avl_rec.object_version_number,
        MEMO_YN = l_def_avl_rec.memo_yn,
        PRIOR_YEAR_YN = l_def_avl_rec.prior_year_yn,
        DESCRIPTION = l_def_avl_rec.description,
        FACTORING_SYND_FLAG = l_def_avl_rec.factoring_synd_flag,
        END_DATE = l_def_avl_rec.end_date,
        ACCRUAL_YN = l_def_avl_rec.accrual_yn ,
        ORG_ID = l_def_avl_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_avl_rec.attribute_category,
        ATTRIBUTE1 = l_def_avl_rec.attribute1,
        ATTRIBUTE2 = l_def_avl_rec.attribute2,
        ATTRIBUTE3 = l_def_avl_rec.attribute3,
        ATTRIBUTE4 = l_def_avl_rec.attribute4,
        ATTRIBUTE5 = l_def_avl_rec.attribute5,
        ATTRIBUTE6 = l_def_avl_rec.attribute6,
        ATTRIBUTE7 = l_def_avl_rec.attribute7,
        ATTRIBUTE8 = l_def_avl_rec.attribute8,
        ATTRIBUTE9 = l_def_avl_rec.attribute9,
        ATTRIBUTE10 = l_def_avl_rec.attribute10,
        ATTRIBUTE11 = l_def_avl_rec.attribute11,
        ATTRIBUTE12 = l_def_avl_rec.attribute12,
        ATTRIBUTE13 = l_def_avl_rec.attribute13,
        ATTRIBUTE14 = l_def_avl_rec.attribute14,
        ATTRIBUTE15 = l_def_avl_rec.attribute15,
        CREATED_BY = l_def_avl_rec.created_by,
        CREATION_DATE = l_def_avl_rec.creation_date,
        LAST_UPDATED_BY = l_def_avl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_avl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_avl_rec.last_update_login,
  -- Added by HKPATEL for securitization changes
  	INV_CODE = l_def_avl_rec.inv_code
    WHERE ID = l_def_avl_rec.id;

    x_avl_rec := l_def_avl_rec;
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
  -- update_row for:OKL_AE_TEMPLATES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type,
    x_avlv_rec                     OUT NOCOPY avlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avlv_rec                     avlv_rec_type := p_avlv_rec;
    l_def_avlv_rec                 avlv_rec_type;
    l_avl_rec                      avl_rec_type;
    lx_avl_rec                     avl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_avlv_rec	IN avlv_rec_type
    ) RETURN avlv_rec_type IS
      l_avlv_rec	avlv_rec_type := p_avlv_rec;
    BEGIN
      l_avlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_avlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_avlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_avlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_avlv_rec	IN avlv_rec_type,
      x_avlv_rec	OUT NOCOPY avlv_rec_type
    ) RETURN VARCHAR2 IS
      l_avlv_rec                     avlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_avlv_rec := p_avlv_rec;
      -- Get current database values
      l_avlv_rec := get_rec(p_avlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_avlv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.id := l_avlv_rec.id;
      END IF;
      IF (x_avlv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.object_version_number := l_avlv_rec.object_version_number;
      END IF;
      IF (x_avlv_rec.try_id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.try_id := l_avlv_rec.try_id;
      END IF;
      IF (x_avlv_rec.aes_id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.aes_id := l_avlv_rec.aes_id;
      END IF;
      IF (x_avlv_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.sty_id := l_avlv_rec.sty_id;
      END IF;
      IF (x_avlv_rec.fma_id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.fma_id := l_avlv_rec.fma_id;
      END IF;
      IF (x_avlv_rec.set_of_books_id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.set_of_books_id := l_avlv_rec.set_of_books_id;
      END IF;
      IF (x_avlv_rec.fac_code = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.fac_code := l_avlv_rec.fac_code;
      END IF;
      IF (x_avlv_rec.syt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.syt_code := l_avlv_rec.syt_code;
      END IF;
      IF (x_avlv_rec.post_to_gl = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.post_to_gl := l_avlv_rec.post_to_gl;
      END IF;
      IF (x_avlv_rec.advance_arrears = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.advance_arrears := l_avlv_rec.advance_arrears;
      END IF;
      IF (x_avlv_rec.memo_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.memo_yn := l_avlv_rec.memo_yn;
      END IF;
      IF (x_avlv_rec.prior_year_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.prior_year_yn := l_avlv_rec.prior_year_yn;
      END IF;
      IF (x_avlv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.name := l_avlv_rec.name;
      END IF;
      IF (x_avlv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.description := l_avlv_rec.description;
      END IF;
      IF (x_avlv_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.version := l_avlv_rec.version;
      END IF;
      IF (x_avlv_rec.factoring_synd_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.factoring_synd_flag := l_avlv_rec.factoring_synd_flag;
      END IF;
      IF (x_avlv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_avlv_rec.start_date := l_avlv_rec.start_date;
      END IF;
      IF (x_avlv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_avlv_rec.end_date := l_avlv_rec.end_date;
      END IF;
      IF (x_avlv_rec.accrual_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.accrual_yn := l_avlv_rec.accrual_yn;
      END IF;
      IF (x_avlv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute_category := l_avlv_rec.attribute_category;
      END IF;
      IF (x_avlv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute1 := l_avlv_rec.attribute1;
      END IF;
      IF (x_avlv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute2 := l_avlv_rec.attribute2;
      END IF;
      IF (x_avlv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute3 := l_avlv_rec.attribute3;
      END IF;
      IF (x_avlv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute4 := l_avlv_rec.attribute4;
      END IF;
      IF (x_avlv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute5 := l_avlv_rec.attribute5;
      END IF;
      IF (x_avlv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute6 := l_avlv_rec.attribute6;
      END IF;
      IF (x_avlv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute7 := l_avlv_rec.attribute7;
      END IF;
      IF (x_avlv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute8 := l_avlv_rec.attribute8;
      END IF;
      IF (x_avlv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute9 := l_avlv_rec.attribute9;
      END IF;
      IF (x_avlv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute10 := l_avlv_rec.attribute10;
      END IF;
      IF (x_avlv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute11 := l_avlv_rec.attribute11;
      END IF;
      IF (x_avlv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute12 := l_avlv_rec.attribute12;
      END IF;
      IF (x_avlv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute13 := l_avlv_rec.attribute13;
      END IF;
      IF (x_avlv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute14 := l_avlv_rec.attribute14;
      END IF;
      IF (x_avlv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.attribute15 := l_avlv_rec.attribute15;
      END IF;
      IF (x_avlv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.org_id := l_avlv_rec.org_id;
      END IF;
      IF (x_avlv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.created_by := l_avlv_rec.created_by;
      END IF;
      IF (x_avlv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_avlv_rec.creation_date := l_avlv_rec.creation_date;
      END IF;
      IF (x_avlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.last_updated_by := l_avlv_rec.last_updated_by;
      END IF;
      IF (x_avlv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_avlv_rec.last_update_date := l_avlv_rec.last_update_date;
      END IF;
      IF (x_avlv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_avlv_rec.last_update_login := l_avlv_rec.last_update_login;
      END IF;
  -- Added by HKPATEL for securitization changes
      IF (x_avlv_rec.inv_code = OKC_API.G_MISS_CHAR)
      THEN
        x_avlv_rec.inv_code := l_avlv_rec.inv_code;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_AE_TEMPLATES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_avlv_rec IN  avlv_rec_type,
      x_avlv_rec OUT NOCOPY avlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_avlv_rec := p_avlv_rec;
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
      p_avlv_rec,                        -- IN
      l_avlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- HKPATEL added code for securitization

    IF (l_avlv_rec.factoring_synd_flag = 'FACTORING') THEN
      l_avlv_rec.INV_CODE := NULL;
      l_avlv_rec.SYT_CODE := NULL;
    ELSIF (l_avlv_rec.factoring_synd_flag = 'SYNDICATION') THEN
      l_avlv_rec.INV_CODE := NULL;
      l_avlv_rec.FAC_CODE := NULL;
    ELSIF (l_avlv_rec.factoring_synd_flag = 'INVESTOR') THEN
      l_avlv_rec.SYT_CODE := NULL;
      l_avlv_rec.FAC_CODE := NULL;
    ELSE
    	  l_avlv_rec.SYT_CODE := NULL;
    	  l_avlv_rec.FAC_CODE := NULL;
	  l_avlv_rec.INV_CODE := NULL;
    END IF;

    l_return_status := populate_new_record(l_avlv_rec, l_def_avlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_avlv_rec := fill_who_columns(l_def_avlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_avlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_avlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_avlv_rec, l_avl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_avl_rec,
      lx_avl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_avl_rec, l_def_avlv_rec);
    x_avlv_rec := l_def_avlv_rec;
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
  -- PL/SQL TBL update_row for:AVLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type,
    x_avlv_tbl                     OUT NOCOPY avlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i),
          x_avlv_rec                     => x_avlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
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
  -- delete_row for:OKL_AE_TEMPLATES --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avl_rec                      IN avl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avl_rec                      avl_rec_type:= p_avl_rec;
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
    DELETE FROM OKL_AE_TEMPLATES
     WHERE ID = l_avl_rec.id;

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
  -- delete_row for:OKL_AE_TEMPLATES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_avlv_rec                     avlv_rec_type := p_avlv_rec;
    l_avl_rec                      avl_rec_type;
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
    migrate(l_avlv_rec, l_avl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_avl_rec
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
  -- PL/SQL TBL delete_row for:AVLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i));
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
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
END OKL_AVL_PVT;

/

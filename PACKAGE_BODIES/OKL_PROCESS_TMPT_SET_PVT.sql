--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_TMPT_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_TMPT_SET_PVT" AS
/* $Header: OKLRTMSB.pls 120.7 2007/09/20 10:49:49 rajnisku noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.TEMPLATE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;

-- End of wraper code generated automatically by Debug code generator

 g_sysdate DATE := TRUNC(SYSDATE);


PROCEDURE validate_dates(p_start_date  IN DATE,
                         p_end_date     IN DATE,
                         x_valid_flag   OUT NOCOPY VARCHAR2)
IS

BEGIN

  IF (p_start_date IS NULL) THEN

      OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_START_DATE_NULL');
      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

  IF (p_end_date IS NOT NULL) THEN

      IF (p_end_date < p_start_date) THEN

          OKL_API.SET_MESSAGE(p_app_name         => G_APP_NAME,
                              p_msg_name         => 'OKL_START_DT_LESS_END_DT');
          RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

  END IF;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_valid_flag := 'E';

END validate_dates;



PROCEDURE validate_set_dates(p_avlv_rec  IN AVLV_REC_TYPE,
                             x_valid_flag   OUT NOCOPY VARCHAR2)

IS

  CURSOR aes_csr(v_aes_id NUMBER) IS
  SELECT start_date,
         end_date
  FROM OKL_AE_TMPT_SETS_V
  WHERE id = v_aes_id;

  l_aes_start_date      DATE;
  l_aes_end_date        DATE;


BEGIN

    OPEN aes_csr(p_avlv_rec.aes_id);
    FETCH aes_csr INTO l_aes_start_date,
                       l_aes_end_date;

    CLOSE aes_csr;

    IF (p_avlv_rec.start_date < l_aes_start_date) THEN

        OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                            p_msg_name          => 'OKL_TMPLDT_MISMATCH_TMPTSET');
        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    IF (p_avlv_rec.end_date IS NULL) THEN

       IF (l_aes_end_date IS NOT NULL) THEN

           OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                               p_msg_name          => 'OKL_TMPLDT_MISMATCH_TMPTSET');
           RAISE OKL_API.G_EXCEPTION_ERROR;

       END IF;

    END IF;

    IF (p_avlv_rec.end_date IS NOT NULL) THEN

       IF (l_aes_end_date IS NOT NULL) AND (l_aes_end_date < p_avlv_rec.end_date) THEN

           OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                               p_msg_name          => 'OKL_TMPLDT_MISMATCH_TMPTSET');
           RAISE OKL_API.G_EXCEPTION_ERROR;

       END IF;

    END IF;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_valid_flag := OKL_API.G_RET_STS_ERROR;

END validate_set_dates;


PROCEDURE validate_existing_tmpl(p_avlv_rec     IN AVLV_REC_TYPE,
                                 x_valid_flag   OUT NOCOPY VARCHAR2)

IS


 CURSOR avl_csr(v_name VARCHAR2, v_aes_id NUMBER) IS
 SELECT start_date,
        end_date
 FROM  OKL_AE_TEMPLATES
 WHERE NAME = v_name
 AND   aes_id = v_aes_id;

 exist_rec avl_csr%ROWTYPE;


BEGIN

 FOR exist_rec IN avl_csr(p_avlv_rec.NAME, p_avlv_rec.aes_id)
 LOOP

   IF (exist_rec.END_DATE IS NULL) THEN  -- If existing record in unbounded

      IF (p_avlv_rec.END_DATE IS NULL) THEN  -- If new record is also unbounded then error

          OKL_API.SET_MESSAGE(p_app_name           => G_APP_NAME,
                              p_msg_name           => 'OKL_TMPL_DATE_OVERLAPS');
          RAISE OKL_API.G_EXCEPTION_ERROR;

      ELSE  -- New record is bounded

         IF (p_avlv_rec.END_DATE >= exist_rec.START_DATE) THEN  -- new record should be on left
            OKL_API.SET_MESSAGE(p_app_name         => G_APP_NAME,
                                p_msg_name         => 'OKL_TMPL_DATE_OVERLAPS');
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      END IF;

   END IF;

   IF (exist_rec.END_DATE IS NOT NULL) THEN   -- Existing record in Bounded

       IF (p_avlv_rec.END_DATE IS NULL) THEN  -- if new record in unbounded, it should be on right
           IF (p_avlv_rec.START_DATE <= exist_rec.END_DATE) THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_TMPL_DATE_OVERLAPS');
              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;
       ELSE
           IF (p_avlv_rec.START_DATE BETWEEN exist_rec.START_DATE AND exist_rec.END_DATE) OR
              (p_avlv_rec.END_DATE   BETWEEN exist_rec.START_DATE AND exist_rec.END_DATE) THEN

               OKL_API.SET_MESSAGE(p_app_name      => G_APP_NAME,
                                   p_msg_name      => 'OKL_TMPL_DATE_OVERLAPS');
               RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

       END IF;

    END IF;

 END LOOP;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN

       x_valid_flag := OKL_API.G_RET_STS_ERROR;


END validate_existing_tmpl;



PROCEDURE UNIQUE_VALIDATION_CREATE(p_avlv_rec     IN AVLV_REC_TYPE,
                                   x_valid_flag   OUT NOCOPY VARCHAR2)

IS

 CURSOR avl_csr IS
 SELECT start_date,
        end_date
 FROM  OKL_AE_TEMPLATES
 WHERE nvl(sty_id,OKL_API.G_MISS_NUM)
                     = nvl(p_avlv_rec.sty_id,OKL_API.G_MISS_NUM) AND
       nvl(try_id,OKL_API.G_MISS_NUM)
                     = nvl(p_avlv_rec.try_id,OKL_API.G_MISS_NUM) AND
       nvl(aes_id,OKL_API.G_MISS_NUM)
                     = nvl(p_avlv_rec.aes_id,OKL_API.G_MISS_NUM) AND
       nvl(syt_code,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.syt_code,OKL_API.G_MISS_CHAR) AND
       -- Code Added by HKPATEL for Bug # 2943310
       nvl(inv_code,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.inv_code,OKL_API.G_MISS_CHAR) AND
       -- Added code ends here
       nvl(fac_code,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.fac_code,OKL_API.G_MISS_CHAR) AND
       nvl(memo_yn,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.memo_yn,OKL_API.G_MISS_CHAR) AND
       nvl(factoring_synd_flag,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.factoring_synd_flag,OKL_API.G_MISS_CHAR) ;


 exist_rec avl_csr%ROWTYPE;


BEGIN

 FOR exist_rec IN avl_csr
 LOOP

   IF (exist_rec.END_DATE IS NULL) THEN  -- If existing record in unbounded

      IF (p_avlv_rec.END_DATE IS NULL) THEN  -- If new record is also unbounded then error

          OKL_API.SET_MESSAGE(p_app_name           => G_APP_NAME,
                              p_msg_name           => 'OKL_TMPL_NOT_UNIQUE');
          RAISE OKL_API.G_EXCEPTION_ERROR;

      ELSE  -- New record is bounded

         IF (p_avlv_rec.END_DATE >= exist_rec.START_DATE) THEN  -- new record should be on left
            OKL_API.SET_MESSAGE(p_app_name         => G_APP_NAME,
                                p_msg_name         => 'OKL_TMPL_NOT_UNIQUE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      END IF;

   END IF;

   IF (exist_rec.END_DATE IS NOT NULL) THEN   -- Existing record in Bounded

       IF (p_avlv_rec.END_DATE IS NULL) THEN  -- if new record in unbounded, it should be on right
           IF (p_avlv_rec.START_DATE <= exist_rec.END_DATE) THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_TMPL_NOT_UNIQUE');
              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;
       ELSE
           IF (p_avlv_rec.START_DATE BETWEEN exist_rec.START_DATE AND exist_rec.END_DATE) OR
              (p_avlv_rec.END_DATE   BETWEEN exist_rec.START_DATE AND exist_rec.END_DATE) THEN

               OKL_API.SET_MESSAGE(p_app_name      => G_APP_NAME,
                                   p_msg_name      => 'OKL_TMPL_NOT_UNIQUE');
               RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

       END IF;

    END IF;

 END LOOP;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN

       x_valid_flag := OKL_API.G_RET_STS_ERROR;


END UNIQUE_VALIDATION_CREATE;


PROCEDURE UNIQUE_VALIDATION_UPDATE(p_avlv_rec     IN AVLV_REC_TYPE,
                                   x_valid_flag   OUT NOCOPY VARCHAR2)

IS

 CURSOR avl_csr IS
 SELECT start_date,
        end_date
 FROM  OKL_AE_TEMPLATES
 WHERE nvl(sty_id,OKL_API.G_MISS_NUM)
                     = nvl(p_avlv_rec.sty_id,OKL_API.G_MISS_NUM) AND
       nvl(try_id,OKL_API.G_MISS_NUM)
                     = nvl(p_avlv_rec.try_id,OKL_API.G_MISS_NUM) AND
       nvl(aes_id,OKL_API.G_MISS_NUM)
                     = nvl(p_avlv_rec.aes_id,OKL_API.G_MISS_NUM) AND
       nvl(syt_code,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.syt_code,OKL_API.G_MISS_CHAR) AND
       -- Code Added by HKPATEL for Bug # 2943310
       nvl(inv_code,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.inv_code,OKL_API.G_MISS_CHAR) AND
       -- Added code ends here
       nvl(fac_code,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.fac_code,OKL_API.G_MISS_CHAR) AND
       nvl(memo_yn,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.memo_yn,OKL_API.G_MISS_CHAR) AND
       nvl(factoring_synd_flag,OKL_API.G_MISS_CHAR)
                     = nvl(p_avlv_rec.factoring_synd_flag,OKL_API.G_MISS_CHAR) AND
       ID            <> p_avlv_rec.ID;



 exist_rec avl_csr%ROWTYPE;


BEGIN

 FOR exist_rec IN avl_csr
 LOOP

   IF (exist_rec.END_DATE IS NULL) THEN  -- If existing record in unbounded

      IF (p_avlv_rec.END_DATE IS NULL) THEN  -- If new record is also unbounded then error

          OKL_API.SET_MESSAGE(p_app_name           => G_APP_NAME,
                              p_msg_name           => 'OKL_TMPL_NOT_UNIQUE');
          RAISE OKL_API.G_EXCEPTION_ERROR;

      ELSE  -- New record is bounded

         IF (p_avlv_rec.END_DATE >= exist_rec.START_DATE) THEN  -- new record should be on left
            OKL_API.SET_MESSAGE(p_app_name         => G_APP_NAME,
                                p_msg_name         => 'OKL_TMPL_NOT_UNIQUE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      END IF;

   END IF;

   IF (exist_rec.END_DATE IS NOT NULL) THEN   -- Existing record in Bounded

       IF (p_avlv_rec.END_DATE IS NULL) THEN  -- if new record in unbounded, it should be on right
           IF (p_avlv_rec.START_DATE <= exist_rec.END_DATE) THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_TMPL_NOT_UNIQUE');
              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;
       ELSE
           IF (p_avlv_rec.START_DATE BETWEEN exist_rec.START_DATE AND exist_rec.END_DATE) OR
              (p_avlv_rec.END_DATE   BETWEEN exist_rec.START_DATE AND exist_rec.END_DATE) THEN

               OKL_API.SET_MESSAGE(p_app_name      => G_APP_NAME,
                                   p_msg_name      => 'OKL_TMPL_NOT_UNIQUE');
               RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

       END IF;

    END IF;

 END LOOP;

EXCEPTION

  WHEN OKL_API.G_EXCEPTION_ERROR THEN

       x_valid_flag := OKL_API.G_RET_STS_ERROR;


END UNIQUE_VALIDATION_UPDATE;


FUNCTION get_rec_avl (p_avlv_rec                IN avlv_rec_type,
                      x_no_data_found           OUT NOCOPY BOOLEAN
  ) RETURN avlv_rec_type IS
    CURSOR okl_avlv_pk_csr (p_id   IN NUMBER) IS
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
            -- Added by HKPATEL for Bug# 2943310
            INV_CODE,
            -- Added code ends here
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
            LAST_UPDATE_LOGIN
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
              -- Added by HKPATEL for Bug# 2943310
              l_avlv_rec.INV_CODE,
              -- Added code ends here
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
              l_avlv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_avlv_pk_csr%NOTFOUND;
    CLOSE okl_avlv_pk_csr;
    RETURN(l_avlv_rec);

END get_rec_avl;


FUNCTION populate_new_record_avl (p_avlv_rec IN  avlv_rec_type,
                                  x_avlv_rec OUT NOCOPY avlv_rec_type
    ) RETURN VARCHAR2 IS
      l_avlv_rec                     avlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 BEGIN

   x_avlv_rec := p_avlv_rec;
      -- Get current database values
   l_avlv_rec := get_rec_avl(p_avlv_rec, l_row_notfound);

   IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   END IF;

   IF (x_avlv_rec.id = OKC_API.G_MISS_NUM) THEN
      x_avlv_rec.id := l_avlv_rec.id;
   END IF;

   IF (x_avlv_rec.name = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.name := l_avlv_rec.name;
   END IF;
   IF (x_avlv_rec.set_of_books_id = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.set_of_books_id := l_avlv_rec.set_of_books_id;
   END IF;
   IF (x_avlv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.sty_id := l_avlv_rec.sty_id;
   END IF;
   IF (x_avlv_rec.try_id = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.try_id := l_avlv_rec.try_id;
   END IF;
   IF (x_avlv_rec.aes_id = OKC_API.G_MISS_NUM) THEN
          x_avlv_rec.aes_id := l_avlv_rec.aes_id;
   END IF;
   IF (x_avlv_rec.syt_code = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.syt_code := l_avlv_rec.syt_code;
   END IF;
   -- Added by HKPATEL for Bug# 2943310
   IF (x_avlv_rec.inv_code = OKC_API.G_MISS_CHAR) THEN
           x_avlv_rec.inv_code := l_avlv_rec.inv_code;
   END IF;
   -- Added code ends here
   IF (x_avlv_rec.fac_code = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.fac_code := l_avlv_rec.fac_code;
   END IF;
   IF (x_avlv_rec.fma_id = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.fma_id := l_avlv_rec.fma_id;
   END IF;
   IF (x_avlv_rec.advance_arrears = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.advance_arrears := l_avlv_rec.advance_arrears;
   END IF;
   IF (x_avlv_rec.post_to_gl = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.post_to_gl := l_avlv_rec.post_to_gl;
   END IF;
   IF (x_avlv_rec.version = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.version := l_avlv_rec.version;
   END IF;
   IF (x_avlv_rec.start_date = OKC_API.G_MISS_DATE) THEN
        x_avlv_rec.start_date := l_avlv_rec.start_date;
   END IF;
   IF (x_avlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.object_version_number := l_avlv_rec.object_version_number;
   END IF;
   IF (x_avlv_rec.memo_yn = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.memo_yn := l_avlv_rec.memo_yn;
   END IF;
   IF (x_avlv_rec.prior_year_yn = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.prior_year_yn := l_avlv_rec.prior_year_yn;
   END IF;
   IF (x_avlv_rec.description = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.description := l_avlv_rec.description;
   END IF;
   IF (x_avlv_rec.factoring_synd_flag = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.factoring_synd_flag := l_avlv_rec.factoring_synd_flag;
   END IF;
   IF (x_avlv_rec.end_date = OKC_API.G_MISS_DATE) THEN
        x_avlv_rec.end_date := l_avlv_rec.end_date;
   END IF;
   IF (x_avlv_rec.accrual_yn  = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.accrual_yn := l_avlv_rec.accrual_yn;
   END IF;
   IF (x_avlv_rec.org_id = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.org_id := l_avlv_rec.org_id;
   END IF;
   IF (x_avlv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute_category := l_avlv_rec.attribute_category;
   END IF;
   IF (x_avlv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
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
   IF (x_avlv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute4 := l_avlv_rec.attribute4;
   END IF;
   IF (x_avlv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute5 := l_avlv_rec.attribute5;
   END IF;
   IF (x_avlv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute6 := l_avlv_rec.attribute6;
   END IF;
   IF (x_avlv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute7 := l_avlv_rec.attribute7;
   END IF;
   IF (x_avlv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute8 := l_avlv_rec.attribute8;
   END IF;
   IF (x_avlv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute9 := l_avlv_rec.attribute9;
   END IF;
   IF (x_avlv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute10 := l_avlv_rec.attribute10;
   END IF;
   IF (x_avlv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute11 := l_avlv_rec.attribute11;
   END IF;
   IF (x_avlv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute12 := l_avlv_rec.attribute12;
   END IF;
   IF (x_avlv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute13 := l_avlv_rec.attribute13;
   END IF;
   IF (x_avlv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute14 := l_avlv_rec.attribute14;
   END IF;
   IF (x_avlv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
        x_avlv_rec.attribute15 := l_avlv_rec.attribute15;
   END IF;
   IF (x_avlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.created_by := l_avlv_rec.created_by;
   END IF;
   IF (x_avlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
        x_avlv_rec.creation_date := l_avlv_rec.creation_date;
   END IF;
   IF (x_avlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.last_updated_by := l_avlv_rec.last_updated_by;
   END IF;
   IF (x_avlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
        x_avlv_rec.last_update_date := l_avlv_rec.last_update_date;
   END IF;
   IF (x_avlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
        x_avlv_rec.last_update_login := l_avlv_rec.last_update_login;
   END IF;

   RETURN(l_return_status);

 END populate_new_record_avl;


 FUNCTION get_rec_atl(p_atlv_rec              IN atlv_rec_type,
                      x_no_data_found         OUT NOCOPY BOOLEAN
  ) RETURN atlv_rec_type IS
    CURSOR okl_atlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT  ID,
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
  END get_rec_atl;

 FUNCTION populate_new_record_atl (
      p_atlv_rec        IN atlv_rec_type,
      x_atlv_rec        OUT NOCOPY atlv_rec_type
    ) RETURN VARCHAR2 IS
      l_atlv_rec                     atlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atlv_rec := p_atlv_rec;
      -- Get current database values
      l_atlv_rec := get_rec_atl(p_atlv_rec, l_row_notfound);
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
    END populate_new_record_atl;



PROCEDURE CREATE_TMPL_NEW_VERSION(p_avlv_rec_new        IN      AVLV_REC_TYPE,
                                  x_return_status       OUT NOCOPY     VARCHAR2)


IS


   CURSOR avl_csr(v_name VARCHAR2) IS
   SELECT nvl(max(version),0)
   FROM OKL_AE_TEMPLATES
   WHERE name = v_name;

   CURSOR atl_csr(v_avl_id NUMBER) IS
   SELECT  SEQUENCE_NUMBER,
           CODE_COMBINATION_ID,
           AE_LINE_TYPE,
           CRD_CODE,
           OBJECT_VERSION_NUMBER,
           ACCOUNT_BUILDER_YN,
           DESCRIPTION,
           PERCENTAGE,
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
           ATTRIBUTE15
    FROM OKL_AE_TMPT_LNES
    WHERE avl_id = v_avl_id;

   l_avlv_rec  AVLV_REC_TYPE;
   l_atlv_tbl  ATLV_TBL_TYPE;
   x_atlv_tbl  ATLV_TBL_TYPE;

   i          NUMBER := 0;
   l_name     OKL_AE_TEMPLATES.NAME%TYPE;
   l_max_version NUMBER := 0;
   p_api_version NUMBER := 1.0;
   p_init_msg_list VARCHAR2(1) := OKL_API.G_FALSE;
   x_msg_count     NUMBER := 0;
   x_msg_data      VARCHAR2(2000);
   x_avlv_rec      AVLV_REC_TYPE;
   l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


BEGIN

    l_return_status := populate_new_record_avl (p_avlv_rec   => p_avlv_rec_new,
                                                x_avlv_rec   => l_avlv_rec);

    OPEN avl_csr(l_avlv_rec.NAME);
    FETCH avl_csr INTO l_max_version;
    CLOSE avl_csr;

    l_avlv_rec.VERSION    := TO_CHAR((l_max_version + 1),'99.9');
    l_avlv_rec.START_DATE := sysdate;  -- outstanding question???

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
    OKL_TMPT_SET_PUB.create_template(p_api_version     => p_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => x_return_Status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_avlv_rec        => l_avlv_rec,
                                     x_avlv_rec        => x_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template

    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        FOR atl_rec IN atl_csr(l_avlv_rec.ID)  --Get the lines for the Old Template
        LOOP
             i := i + 1;
             l_atlv_tbl(i).AVL_ID                  := x_avlv_rec.ID;
             l_atlv_tbl(i).SEQUENCE_NUMBER         := atl_rec.SEQUENCE_NUMBER;
             l_atlv_tbl(i).CODE_COMBINATION_ID     := atl_rec.CODE_COMBINATION_ID;
             l_atlv_tbl(i).AE_LINE_TYPE            := atl_rec.AE_LINE_TYPE;
             l_atlv_tbl(i).CRD_CODE                := atl_rec.CRD_CODE;
             l_atlv_tbl(i).OBJECT_VERSION_NUMBER   := atl_rec.OBJECT_VERSION_NUMBER;
             l_atlv_tbl(i).ACCOUNT_BUILDER_YN      := atl_rec.ACCOUNT_BUILDER_YN;
             l_atlv_tbl(i).DESCRIPTION             := atl_rec.DESCRIPTION;
             l_atlv_tbl(i).PERCENTAGE              := atl_rec.PERCENTAGE;
             l_atlv_tbl(i).ATTRIBUTE_CATEGORY      := atl_rec.ATTRIBUTE_CATEGORY;
             l_atlv_tbl(i).ATTRIBUTE1              := atl_rec.ATTRIBUTE1;
             l_atlv_tbl(i).ATTRIBUTE2              := atl_rec.ATTRIBUTE2;
             l_atlv_tbl(i).ATTRIBUTE3              := atl_rec.ATTRIBUTE3;
             l_atlv_tbl(i).ATTRIBUTE4              := atl_rec.ATTRIBUTE4;
             l_atlv_tbl(i).ATTRIBUTE5              := atl_rec.ATTRIBUTE5;
             l_atlv_tbl(i).ATTRIBUTE6              := atl_rec.ATTRIBUTE6;
             l_atlv_tbl(i).ATTRIBUTE7              := atl_rec.ATTRIBUTE7;
             l_atlv_tbl(i).ATTRIBUTE8              := atl_rec.ATTRIBUTE8;
             l_atlv_tbl(i).ATTRIBUTE9              := atl_rec.ATTRIBUTE9;
             l_atlv_tbl(i).ATTRIBUTE10             := atl_rec.ATTRIBUTE10;
             l_atlv_tbl(i).ATTRIBUTE11             := atl_rec.ATTRIBUTE11;
             l_atlv_tbl(i).ATTRIBUTE12             := atl_rec.ATTRIBUTE12;
             l_atlv_tbl(i).ATTRIBUTE13             := atl_rec.ATTRIBUTE13;
             l_atlv_tbl(i).ATTRIBUTE14             := atl_rec.ATTRIBUTE14;
             l_atlv_tbl(i).ATTRIBUTE15             := atl_rec.ATTRIBUTE15;

        END LOOP;

        IF (l_atlv_tbl.COUNT > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
           OKL_TMPT_SET_PUB.create_tmpt_lines(p_api_version     => p_api_version,
                                              p_init_msg_list   => p_init_msg_list,
                                              x_return_status   => x_return_Status,
                                              x_msg_count       => x_msg_count,
                                              x_msg_data        => x_msg_data,
                                              p_atlv_tbl        => l_atlv_tbl,
                                              x_atlv_tbl        => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines

        END IF;

    END IF;

END CREATE_TMPL_NEW_VERSION;



PROCEDURE CREATE_LINE_NEW_VERSION(p_atlv_tbl        IN    ATLV_TBL_TYPE,
                                  x_return_status   OUT NOCOPY   VARCHAR2)


IS


   CURSOR avl_csr(v_name VARCHAR2) IS
   SELECT nvl(max(version),0)
   FROM OKL_AE_TEMPLATES
   WHERE name = v_name;

   CURSOR atl_csr(v_id NUMBER) IS
   SELECT AVL_ID
   FROM OKL_AE_TMPT_LNES
   WHERE ID = v_id;

   l_avlv_rec      AVLV_REC_TYPE;
   l_avlv_rec_out  AVLV_REC_TYPE;
   l_atlv_rec      ATLV_REC_TYPE;

   l_atlv_tbl      ATLV_TBL_TYPE;
   l_atlv_tbl_out  ATLV_TBL_TYPE;
   x_atlv_tbl  ATLV_TBL_TYPE;

   i          NUMBER := 0;
   l_name     OKL_AE_TEMPLATES.NAME%TYPE;
   l_max_version NUMBER := 0;
   p_api_version NUMBER := 1.0;
   p_init_msg_list VARCHAR2(1) := OKL_API.G_FALSE;
   x_msg_count     NUMBER := 0;
   x_msg_data      VARCHAR2(2000);
   x_avlv_rec      AVLV_REC_TYPE;
   l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_avl_id       NUMBER;


BEGIN

    OPEN atl_csr(p_atlv_tbl(1).ID);
    FETCH atl_csr INTO l_avl_id;
    CLOSE atl_csr;

    l_avlv_rec.ID := l_avl_id;
    l_atlv_tbl    := p_atlv_tbl;

    l_return_status := populate_new_record_avl(p_avlv_rec   => l_avlv_rec,
                                               x_avlv_rec   => l_avlv_rec_out);

    OPEN avl_csr(l_avlv_rec_out.NAME);
    FETCH avl_csr INTO l_max_version;
    CLOSE avl_csr;

    l_avlv_rec_out.VERSION    := TO_CHAR((l_max_version + 1),'99.9');
    l_avlv_rec_out.START_DATE := sysdate;  -- outstanding question???

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
    OKL_TMPT_SET_PUB.create_template(p_api_version     => p_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => x_return_Status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_avlv_rec        => l_avlv_rec_out,
                                     x_avlv_rec        => x_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template


    IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

       FOR i IN 1..l_atlv_tbl.COUNT
       LOOP

             l_return_status := populate_new_record_atl(p_atlv_rec   => l_atlv_tbl(i),
                                                        x_atlv_rec   => l_atlv_tbl_out(i));
             l_atlv_tbl_out(i).AVL_ID := x_avlv_rec.ID;

       END LOOP;

       IF (l_atlv_tbl_out.COUNT > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
           OKL_TMPT_SET_PUB.create_tmpt_lines(p_api_version     => p_api_version,
                                              p_init_msg_list   => p_init_msg_list,
                                              x_return_status   => x_return_Status,
                                              x_msg_count       => x_msg_count,
                                              x_msg_data        => x_msg_data,
                                              p_atlv_tbl        => l_atlv_tbl_out,
                                              x_atlv_tbl        => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines

        END IF;

    END IF;

END CREATE_LINE_NEW_VERSION;




PROCEDURE create_tmpt_set(
         p_api_version        IN  NUMBER
        ,p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
        ,x_return_status      OUT NOCOPY VARCHAR2
        ,x_msg_count          OUT NOCOPY NUMBER
        ,x_msg_data           OUT NOCOPY VARCHAR2
        ,p_aesv_rec           IN  aesv_rec_type
        ,p_avlv_tbl           IN  avlv_tbl_type
        ,p_atlv_tbl           IN atlv_tbl_type
        ,x_aesv_rec           OUT NOCOPY aesv_rec_type
        ,x_avlv_tbl           OUT NOCOPY avlv_tbl_type
        ,x_atlv_tbl           OUT NOCOPY atlv_tbl_type  )

IS

  l_api_version         NUMBER := 1.0;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_valid       VARCHAR2(1);

  BEGIN
  l_return_status := G_RET_STS_SUCCESS;

  -- Validate the Template Set Dates , added by santonyr

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_set ');
    END;
  END IF;
     OKL_TMPT_SET_PUB.create_tmpt_set(
                                p_api_version     => l_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => x_return_Status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_aesv_rec        => p_aesv_rec,
                                p_avlv_tbl        => p_avlv_tbl,
                                p_atlv_tbl        => p_atlv_tbl,
                                x_aesv_rec        => x_aesv_rec,
                                x_avlv_tbl        => x_avlv_tbl,
                                x_atlv_tbl        => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_set
END create_tmpt_set;


PROCEDURE update_tmpt_set(p_api_version                  IN  NUMBER
                         ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status                OUT NOCOPY VARCHAR2
                         ,x_msg_count                    OUT NOCOPY NUMBER
                         ,x_msg_data                     OUT NOCOPY VARCHAR2
                         ,p_aesv_rec                     IN  aesv_rec_type
                         ,p_avlv_tbl                     IN  avlv_tbl_type
                         ,p_atlv_tbl                     IN atlv_tbl_type
                         ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
                         ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
                         ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type )

IS

l_api_version   NUMBER := 1.0;
l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
l_valid         VARCHAR2(1);

BEGIN
l_return_status := G_RET_STS_SUCCESS;

-- Validate the Template Set Dates , added by santonyr


-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_set ');
    END;
  END IF;
OKL_TMPT_SET_PUB.update_tmpt_set(
                p_api_version     => l_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_Status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_aesv_rec        => p_aesv_rec,
                p_avlv_tbl        => p_avlv_tbl,
                p_atlv_tbl        => p_atlv_tbl,
                x_aesv_rec        => x_aesv_rec,
                x_avlv_tbl        => x_avlv_tbl,
                x_atlv_tbl        => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_set

EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN
    x_return_status := G_RET_STS_ERROR;
  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

  -- store SQL error message on message stack for caller
    OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm );

END update_tmpt_set;




PROCEDURE create_tmpt_set(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_aesv_tbl                     IN  aesv_tbl_type,
                          x_aesv_tbl                     OUT NOCOPY aesv_tbl_type)

IS

  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  i             NUMBER;

  BEGIN


  IF (p_aesv_tbl.COUNT > 0) THEN

     FOR i IN 1..p_aesv_tbl.COUNT

     LOOP

        create_tmpt_set(p_api_version     => p_api_version,
                        p_init_msg_list   => p_init_msg_list,
                        x_return_status   => l_return_Status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        p_aesv_rec        => p_aesv_tbl(i),
                        x_aesv_rec        => x_aesv_tbl(i),
			p_aes_source_id	  => NULL );

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN

               l_overall_status := l_return_status;

           END IF;

        END IF;

     END LOOP;

  END IF;

  x_return_status := l_overall_status;

END create_tmpt_set;




PROCEDURE create_tmpt_set(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_aesv_rec                     IN  aesv_rec_type,
                          x_aesv_rec                     OUT NOCOPY aesv_rec_type,
			  p_aes_source_id	         IN  OKL_AE_TMPT_SETS.id%TYPE DEFAULT NULL)

 IS

  l_api_version         NUMBER := 1.0;
  l_api_name            VARCHAR2(30) := 'CREATE_TMPT_SET';
  l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_valid_flag          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_id                  NUMBER ;
  l_copy_to_id	        OKL_AE_TMPT_SETS.id%TYPE;

  CURSOR aes_csr (v_name VARCHAR2) IS
  SELECT ID
  FROM OKL_AE_TMPT_SETS_V
  WHERE name = v_name;

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

    validate_dates(p_start_date  => p_aesv_rec.start_date,
                   p_end_date    => p_aesv_rec.end_date,
                   x_valid_flag  => l_valid_flag);

    IF (l_valid_flag = 'E') THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--kmotepal added for bug 3944429
    validate_gts_id(p_gts_id => p_aesv_rec.gts_id,
                    x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OPEN aes_csr(p_aesv_rec.NAME);
    FETCH aes_csr INTO l_id;
    IF (aes_csr%FOUND) THEN
        OKL_API.SET_MESSAGE(p_app_name          => G_APP_NAME,
                            p_msg_name          => 'OKL_TMPT_NAME_EXIST');
        CLOSE aes_csr;
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE aes_csr;


-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_set ');
    END;
  END IF;
    OKL_TMPT_SET_PUB.create_tmpt_set(p_api_version     => l_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => x_return_Status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_aesv_rec        => p_aesv_rec,
                                     x_aesv_rec        => x_aesv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_set

-- Added by Santonyr

    IF  x_return_Status = OKL_API.G_RET_STS_ERROR  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF x_return_Status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

-- Added by Santonyr If the source ID is not null then copy the template sets.

    IF  (p_aes_source_id IS NOT NULL) AND
        (p_aes_source_id  <> G_MISS_NUM) THEN

         l_copy_to_id := x_aesv_rec.id;

         COPY_TMPL_SET(p_api_version    => l_api_version,
	               p_init_msg_list  => p_init_msg_list,
       		       x_return_status  => x_return_Status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
	   	       p_aes_id_from    => p_aes_source_id,
	   	       p_aes_id_to      => l_copy_to_id);
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


END create_tmpt_set;

PROCEDURE update_tmpt_set(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_aesv_tbl                     IN  aesv_tbl_type,
                          x_aesv_tbl                     OUT NOCOPY aesv_tbl_type)
IS

 l_api_version  NUMBER := 1.0;
 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 i              NUMBER;


BEGIN


    IF (p_aesv_tbl.COUNT > 0) THEN

       FOR i IN 1..p_aesv_tbl.COUNT

       LOOP

           update_tmpt_set(p_api_version     => l_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => l_return_Status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_aesv_rec        => p_aesv_tbl(i),
                           x_aesv_rec        => x_aesv_tbl(i) );

           IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

               IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN

                   l_overall_status := l_return_status;

               END IF;


           END IF;



       END LOOP;

    END IF;

END update_tmpt_set;



PROCEDURE update_tmpt_set(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_aesv_rec                     IN  aesv_rec_type,
                          x_aesv_rec                     OUT NOCOPY aesv_rec_type)

IS

  l_api_version        NUMBER := 1.0;
  l_api_name           VARCHAR2(30) := 'UPDATE_TMPT_SET';
  l_valid_flag         VARCHAR2(1) := 'S';
  l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

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

    validate_dates(p_start_date  => p_aesv_rec.start_date,
                   p_end_date    => p_aesv_rec.end_date,
                   x_valid_flag  => l_valid_flag);

    IF (l_valid_flag = 'E') THEN

        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

--kmotepal added for bug 3944429
     validate_gts_id(p_gts_id => p_aesv_rec.gts_id,
                    x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_set ');
    END;
  END IF;
    OKL_TMPT_SET_PUB.update_tmpt_set(p_api_version     => l_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => x_return_Status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_aesv_rec        => p_aesv_rec,
                                     x_aesv_rec        => x_aesv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_set

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

END update_tmpt_set;




PROCEDURE delete_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_tbl                     IN  aesv_tbl_type)

IS

l_api_version NUMBER := 1.0;

BEGIN
-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_set ');
    END;
  END IF;
  OKL_TMPT_SET_PUB.delete_tmpt_set(
        p_api_version     => l_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_Status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_aesv_tbl        => p_aesv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_set

END delete_tmpt_set;


PROCEDURE delete_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_rec                     IN aesv_rec_type)

IS

l_api_version NUMBER := 1.0;

BEGIN
-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_set ');
    END;
  END IF;
  OKL_TMPT_SET_PUB.delete_tmpt_set(
                p_api_version     => l_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_Status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_aesv_rec        => p_aesv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_set

END delete_tmpt_set;



PROCEDURE create_template(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_avlv_rec                     IN  avlv_rec_type,
                          x_avlv_rec                     OUT NOCOPY avlv_rec_type)
 IS

  l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version         NUMBER := 1.0;
  l_api_name            VARCHAR2(30) := 'CREATE_TEMPLATE';
  i                     NUMBER := 0;

  l_valid_flag          VARCHAR2(1) := 'S';

  l_max_version         NUMBER := 0;
  l_avlv_rec            AVLV_REC_TYPE;

  CURSOR avl_csr(v_name VARCHAR2, v_aes_id NUMBER) IS
  SELECT nvl(max(version),0)
  FROM OKL_AE_TEMPLATES
  WHERE NAME   = v_name AND
        AES_ID = v_aes_id ;


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

    l_avlv_rec := p_avlv_rec;

    validate_dates(p_start_date  => p_avlv_rec.start_date,
                   p_end_date    => p_avlv_rec.end_date,
                   x_valid_flag  => l_valid_flag);

    IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN

        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;


    validate_set_dates(p_avlv_rec     => p_avlv_rec,
                       x_valid_flag   => l_valid_flag);

    IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN

        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    OPEN avl_csr(p_avlv_rec.NAME, p_avlv_rec.AES_ID);
    FETCH avl_csr INTO l_max_version;
    CLOSE avl_csr;

    IF (l_max_version > 0) THEN  -- Means a record already exists with the same name

       validate_existing_tmpl(p_avlv_rec     => p_avlv_rec,
                              x_valid_flag   => l_valid_flag);

       IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN

           RAISE OKL_API.G_EXCEPTION_ERROR;

       END IF;

       l_avlv_rec.version := l_max_version + 1;

    END IF;

    UNIQUE_VALIDATION_CREATE(p_avlv_rec      => p_avlv_rec,
                             x_valid_flag    => l_valid_flag);

    IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN

        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
    OKL_TMPT_SET_PUB.create_template(p_api_version     => l_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => x_return_Status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_avlv_rec        => l_avlv_rec,
                                     x_avlv_rec        => x_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template

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

END create_template;


PROCEDURE create_template(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_avlv_tbl                     IN  avlv_tbl_type,
                          x_avlv_tbl                     OUT NOCOPY avlv_tbl_type)

IS
  l_api_version         NUMBER := 1.0;
  i                     NUMBER;
  l_overall_Status      VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_return_status       VARCHAR2(1) := G_RET_STS_SUCCESS;

BEGIN

   FOR i IN 1..p_avlv_tbl.COUNT

   LOOP

      create_template(p_api_version     => l_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      x_return_status   => l_return_Status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_avlv_rec        => p_avlv_tbl(i),
                      x_avlv_rec        => x_avlv_tbl(i));

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

         IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           l_overall_status := l_return_status;
      END IF;
	  END IF;

   END LOOP;

   x_return_status := l_overall_status;


END create_template;


PROCEDURE update_template(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_avlv_rec                     IN  avlv_rec_type,
                          x_avlv_rec                     OUT NOCOPY avlv_rec_type)

IS

 CURSOR avl_csr(v_id NUMBER) IS
   SELECT ID,
          STY_ID,
          TRY_ID,
          AES_ID ,
          FMA_ID,
          OBJECT_VERSION_NUMBER,
          NAME ,
          SYT_CODE,
          -- Added by HKPATEL for Bug# 2943310
          INV_CODE,
          -- Added code ends here
          FAC_CODE,
          ADVANCE_ARREARS,
          POST_TO_GL,
          VERSION,
          START_DATE,
          MEMO_YN ,
          PRIOR_YEAR_YN,
          DESCRIPTION,
          FACTORING_SYND_FLAG,
          END_DATE ,
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
          ATTRIBUTE15
    FROM OKL_AE_TEMPLATES
    WHERE ID = v_id;

 CURSOR dist_csr(v_avl_id NUMBER ) IS
 SELECT ID
 FROM OKL_TRNS_ACC_DSTRS
 WHERE template_id = v_avl_id;


 l_api_version          NUMBER := 1.0;
 l_api_name             VARCHAR2(30) := 'UPDATE_TEMPLATE';
 l_return_status        VARCHAR2(1) := G_RET_STS_SUCCESS;
 l_dist_id              NUMBER;
 l_atlv_tbl             ATLV_TBL_TYPE;

 l_template_status      VARCHAR2(1);
 l_avlv_rec_old         AVLV_REC_TYPE;
 l_avlv_rec_new         AVLV_REC_TYPE;
 l_valid_flag           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


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

   l_avlv_rec_new := p_avlv_rec;

   UNIQUE_VALIDATION_UPDATE(p_avlv_rec      => p_avlv_rec,
                            x_valid_flag    => l_valid_flag);

   IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OPEN avl_csr(l_avlv_rec_new.ID);
   FETCH avl_csr INTO
          l_avlv_rec_old.ID,
          l_avlv_rec_old.STY_ID,
          l_avlv_rec_old.TRY_ID,
          l_avlv_rec_old.AES_ID ,
          l_avlv_rec_old.FMA_ID,
          l_avlv_rec_old.OBJECT_VERSION_NUMBER,
          l_avlv_rec_old.NAME ,
          l_avlv_rec_old.SYT_CODE,
          -- Added by HKPATEL for Bug# 2943310
          l_avlv_rec_old.INV_CODE,
          -- Added code ends here
          l_avlv_rec_old.FAC_CODE,
          l_avlv_rec_old.ADVANCE_ARREARS,
          l_avlv_rec_old.POST_TO_GL,
          l_avlv_rec_old.VERSION,
          l_avlv_rec_old.START_DATE,
          l_avlv_rec_old.MEMO_YN ,
          l_avlv_rec_old.PRIOR_YEAR_YN,
          l_avlv_rec_old.DESCRIPTION,
          l_avlv_rec_old.FACTORING_SYND_FLAG,
          l_avlv_rec_old.END_DATE ,
          l_avlv_rec_old.ACCRUAL_YN,
          l_avlv_rec_old.ATTRIBUTE_CATEGORY,
          l_avlv_rec_old.ATTRIBUTE1,
          l_avlv_rec_old.ATTRIBUTE2,
          l_avlv_rec_old.ATTRIBUTE3,
          l_avlv_rec_old.ATTRIBUTE4,
          l_avlv_rec_old.ATTRIBUTE5,
          l_avlv_rec_old.ATTRIBUTE6,
          l_avlv_rec_old.ATTRIBUTE7,
          l_avlv_rec_old.ATTRIBUTE8,
          l_avlv_rec_old.ATTRIBUTE9,
          l_avlv_rec_old.ATTRIBUTE10,
          l_avlv_rec_old.ATTRIBUTE11,
          l_avlv_rec_old.ATTRIBUTE12,
          l_avlv_rec_old.ATTRIBUTE13,
          l_avlv_rec_old.ATTRIBUTE14,
          l_avlv_rec_old.ATTRIBUTE15;
   CLOSE avl_csr;

   IF (l_avlv_rec_old.START_DATE > G_SYSDATE) THEN
       l_template_status := 'F';  -- It is a future Record
   ELSIF (l_avlv_rec_old.END_DATE IS NOT NULL AND l_avlv_rec_old.END_DATE < G_SYSDATE) THEN
       l_template_status := 'P'; -- It is a past record
   ELSIF (l_avlv_rec_old.START_DATE <= G_SYSDATE) AND (l_avlv_rec_old.END_DATE >= G_SYSDATE
                                OR l_avlv_rec_old.END_DATE IS NULL) THEN
       l_template_status := 'C';
   END IF;

   IF (l_template_status = 'P') THEN -- Past Record, nothing can be modified

      OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_PAST_REC_NOT_MODIFIED');
      RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;

   IF (l_template_status = 'F') OR (l_template_status = 'C')  THEN

      validate_dates(p_start_date  => p_avlv_rec.start_date,
                     p_end_date    => p_avlv_rec.end_date,
                     x_valid_flag  => l_valid_flag);

      IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN

          RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;


      validate_set_dates(p_avlv_rec     => p_avlv_rec,
                         x_valid_flag   => l_valid_flag);

      IF (l_valid_flag = OKL_API.G_RET_STS_ERROR) THEN

          RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_template ');
    END;
  END IF;
      OKL_TMPT_SET_PUB.update_template(p_api_version     => l_api_version,
                                       p_init_msg_list   => p_init_msg_list,
                                       x_return_status   => x_return_Status,
                                       x_msg_count       => x_msg_count,
                                       x_msg_data        => x_msg_data,
                                       p_avlv_rec        => p_avlv_rec,
                                       x_avlv_rec        => x_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_template

   END IF;

   OKL_API.END_ACTIVITY(x_msg_count,	x_msg_data);

EXCEPTION
       WHEN	OKL_API.G_EXCEPTION_ERROR	THEN
       x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT'
       );
       WHEN	OKL_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
       x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       ( l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_UNEXP_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT'
       );
       WHEN	OTHERS	THEN
       x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       ( l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PVT'
       );


END update_template;




 PROCEDURE update_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type,
     x_avlv_tbl                     OUT NOCOPY avlv_tbl_type)

 IS

  l_api_version         NUMBER := 1.0;
  l_overall_Status      VARCHAR2(1) := G_RET_STS_SUCCESS;

BEGIN

   Okc_Api.init_msg_list(p_init_msg_list);
   FOR i IN 1..p_avlv_tbl.COUNT LOOP

     update_template(p_api_version     => l_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_Status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_avlv_rec        => p_avlv_tbl(i),
                     x_avlv_rec        => x_avlv_tbl(i));


      IF (x_return_status <> G_RET_STS_SUCCESS) THEN
        IF (l_overall_status <> G_RET_STS_UNEXP_ERROR) THEN
          l_overall_status := x_return_status;
        END IF;
      END IF;
   END LOOP;

   x_return_status := l_overall_status;

 END update_template;



 PROCEDURE delete_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type)

  IS
     l_api_version NUMBER := 1.0;

  BEGIN
-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_template ');
    END;
  END IF;
    OKL_TMPT_SET_PUB.delete_template(
                p_api_version     => l_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_Status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_avlv_tbl        => p_avlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_template

 END delete_template;


 PROCEDURE delete_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_rec                     IN  avlv_rec_type)

 IS
  l_api_version NUMBER := 1.0;

 BEGIN
-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_template ');
    END;
  END IF;
   OKL_TMPT_SET_PUB.delete_template(
                p_api_version     => l_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_Status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_avlv_rec        => p_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_template

END delete_template;


PROCEDURE create_tmpt_lines(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_atlv_tbl                     IN  atlv_tbl_type,
                            x_atlv_tbl                     OUT NOCOPY atlv_tbl_type)

 IS

  l_api_version NUMBER := 1.0;
  l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 BEGIN

  FOR i IN 1..p_atlv_tbl.COUNT

  LOOP

              create_tmpt_lines(p_api_version     => l_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => x_return_Status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_atlv_rec        => p_atlv_tbl(i),
                                x_atlv_rec        => x_atlv_tbl(i));

   IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           l_overall_Status := x_return_status;
       END IF;

   END IF;

  END LOOP;

  x_return_status := l_overall_status;

END create_tmpt_lines;



PROCEDURE create_tmpt_lines(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_atlv_rec                     IN  atlv_rec_type,
                            x_atlv_rec                     OUT NOCOPY atlv_rec_type)

IS

  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(30) := 'CREATE_TMPT_LINES';
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_dummy       VARCHAR2(1);
  l_atlv_rec    atlv_rec_type;

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

-- If CCID is NULL and Account_Builder_YN is N then raise Error

    IF ((p_atlv_rec.CODE_COMBINATION_ID IS NULL) OR
        (p_atlv_rec.CODE_COMBINATION_ID = OKC_API.G_MISS_NUM))
            AND
        (p_atlv_rec.ACCOUNT_BUILDER_YN  = 'N')
        THEN
        OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                            p_msg_name     => 'OKL_CCID_OR_BUILDER_REQD');
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;

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
        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;
*/


   IF (p_atlv_rec.account_builder_yn = 'Y') THEN

        IF (p_atlv_rec.ae_line_type IS NULL) OR
             (p_atlv_rec.ae_line_type = OKL_API.G_MISS_CHAR) OR
              (p_atlv_rec.ae_line_type = 'NONE') THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_GEN_RULE_REQUIRED');
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

   ELSE

        IF (p_atlv_rec.ae_line_type IS NOT NULL) AND
             (p_atlv_rec.ae_line_type <> OKL_API.G_MISS_CHAR)  AND
           (p_atlv_rec.ae_line_type <> 'NONE') THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_GEN_RULE_NOT_ALLOWED');
              RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;

   END IF;

   l_atlv_rec := p_atlv_rec;

   IF (l_atlv_rec.AE_LINE_TYPE = 'NONE') THEN
       l_atlv_rec.AE_LINE_TYPE := NULL;
   END IF;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
   OKL_TMPT_SET_PUB.create_tmpt_lines(p_api_version     => l_api_version,
                                      p_init_msg_list   => p_init_msg_list,
                                      x_return_status   => x_return_Status,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data,
                                      p_atlv_rec        => l_atlv_rec,
                                      x_atlv_rec        => x_atlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines

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


END create_tmpt_lines;




PROCEDURE update_tmpt_lines(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_atlv_tbl                     IN  atlv_tbl_type,
                            x_atlv_tbl                     OUT NOCOPY atlv_tbl_type)

 IS
 l_api_version          NUMBER := 1.0;
 i                      NUMBER;

 l_atlv_rec             atlv_rec_type;
 l_atlv_tbl             atlv_tbl_type;
 l_avlv_rec             avlv_rec_type;
 x_avlv_rec             avlv_rec_type;
 l_dist_id              NUMBER;

 l_overall_Status       VARCHAR2(1) := G_RET_STS_SUCCESS;
 l_return_status        VARCHAR2(1) := G_RET_STS_SUCCESS;

 CURSOR atl_csr(v_atl_id NUMBER) IS

  SELECT ID ,
         SEQUENCE_NUMBER ,
         AVL_ID ,
         CODE_COMBINATION_ID ,
         AE_LINE_TYPE ,
         CRD_CODE ,
         ACCOUNT_BUILDER_YN ,
         DESCRIPTION,
         PERCENTAGE ,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2 ,
         ATTRIBUTE3 ,
         ATTRIBUTE4 ,
         ATTRIBUTE5 ,
         ATTRIBUTE6 ,
         ATTRIBUTE7 ,
         ATTRIBUTE8 ,
         ATTRIBUTE9 ,
         ATTRIBUTE10 ,
         ATTRIBUTE11 ,
         ATTRIBUTE12 ,
         ATTRIBUTE13 ,
         ATTRIBUTE14 ,
         ATTRIBUTE15
  FROM OKL_AE_TMPT_LNES
  WHERE ID = v_atl_id;

  CURSOR avl_csr(v_atl_id NUMBER) IS
  SELECT ID,
         start_date,
         end_date
  FROM OKL_AE_TEMPLATES
  WHERE ID = (SELECT avl_id FROM OKL_AE_TMPT_LNES
              WHERE ID = v_atl_id);

  l_start_date  DATE;
  l_end_date    DATE;
  l_template_status VARCHAR2(1) ;

  CURSOR dist_csr(v_avl_id NUMBER ) IS
  SELECT ID
  FROM OKL_TRNS_ACC_DSTRS
  WHERE template_id = v_avl_id;


BEGIN

  OPEN avl_csr(p_atlv_tbl(1).ID);
  FETCH avl_csr INTO l_avlv_rec.ID,
                     l_avlv_rec.START_DATE,
                     l_avlv_rec.END_DATE;
  CLOSE avl_csr;


  IF (l_avlv_rec.start_date > SYSDATE) THEN
      l_template_status := 'F';  -- It is a future Record
  ELSIF (l_avlv_rec.end_date IS NOT NULL AND l_avlv_rec.end_date < SYSDATE) THEN
      l_template_status := 'P'; -- It is a past record
  ELSIF (l_avlv_rec.start_date < SYSDATE) AND (l_avlv_rec.end_date > SYSDATE
                                OR l_avlv_rec.end_date IS NULL) THEN
      l_template_status := 'C';

  END IF;


  IF (l_template_status = 'P') THEN -- Past Record, nothing can be modified

      OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_PAST_REC_NOT_MODIFIED');
      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;


  IF (l_template_status = 'F') THEN -- Future record, any thing can be changed in line

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_lines ');
    END;
  END IF;
     OKL_TMPT_SET_PUB.update_tmpt_lines(p_api_version     => l_api_version,
                                        p_init_msg_list   => p_init_msg_list,
                                        x_return_status   => x_return_Status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_atlv_tbl        => p_atlv_tbl,
                                        x_atlv_tbl        => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_lines


  END IF;


  IF (l_template_status = 'C') THEN -- Current Record, Need to bother about Version

     OPEN dist_csr(l_avlv_rec.ID);
     FETCH dist_csr INTO l_dist_id;
     IF dist_csr%NOTFOUND THEN    --- Template not found in Dist, no need for a new version.

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_lines
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_lines ');
    END;
  END IF;
          OKL_TMPT_SET_PUB.update_tmpt_lines(p_api_version     => l_api_version,
                                             p_init_msg_list   => p_init_msg_list,
                                             x_return_status   => x_return_Status,
                                             x_msg_count       => x_msg_count,
                                             x_msg_data        => x_msg_data,
                                             p_atlv_tbl        => p_atlv_tbl,
                                             x_atlv_tbl        => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_lines

     ELSE  -- Create a new version of template and copy the lines to new template

         CREATE_LINE_NEW_VERSION(p_atlv_tbl         => p_atlv_tbl,
                                 x_return_status    => l_return_status);


         IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

          -- Update the Current Template making its END_DATE to today's Date

              l_avlv_rec.END_DATE := SYSDATE;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_template
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_template ');
    END;
  END IF;
              OKL_TMPT_SET_PUB.update_template(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                               x_return_status   => x_return_Status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data,
                                               p_avlv_rec        => l_avlv_rec,
                                               x_avlv_rec        => x_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_template

         END IF;

     END IF;

  END IF;

  CLOSE dist_csr;


END update_tmpt_lines;



PROCEDURE update_tmpt_lines(p_api_version           IN  NUMBER,
                            p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2,
                            p_atlv_rec              IN  atlv_rec_type,
                            x_atlv_rec              OUT NOCOPY atlv_rec_type)

  IS
     l_api_version      NUMBER := 1.0;
     l_api_name    VARCHAR2(30) := 'UPDATE_TMPT_LINES';

     l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
     l_atlv_rec   ATLV_REC_TYPE;

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

-- If CCID is NULL and Account_Builder_YN is N then raise Error

    IF ((p_atlv_rec.CODE_COMBINATION_ID IS NULL) OR
        (p_atlv_rec.CODE_COMBINATION_ID = OKC_API.G_MISS_NUM))
            AND
        (p_atlv_rec.ACCOUNT_BUILDER_YN  = 'N')
        THEN
        OKL_API.SET_MESSAGE(p_app_name     =>  OKL_API.G_APP_NAME,
                            p_msg_name     => 'OKL_CCID_OR_BUILDER_REQD');
        x_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;

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
        RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

*/


   IF (p_atlv_rec.account_builder_yn = 'Y') THEN

        IF (p_atlv_rec.ae_line_type IS NULL) OR
             (p_atlv_rec.ae_line_type = OKL_API.G_MISS_CHAR) OR
              (p_atlv_rec.ae_line_type = 'NONE') THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_GEN_RULE_REQUIRED');
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

   ELSE

        IF (p_atlv_rec.ae_line_type IS NOT NULL) AND
             (p_atlv_rec.ae_line_type <> OKL_API.G_MISS_CHAR)  AND
           (p_atlv_rec.ae_line_type <> 'NONE') THEN

              OKL_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                                  p_msg_name       => 'OKL_GEN_RULE_NOT_ALLOWED');
              RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    l_atlv_rec := p_atlv_rec;

    IF (l_atlv_rec.AE_LINE_TYPE = 'NONE') THEN
        l_atlv_rec.AE_LINE_TYPE := NULL;
     END IF;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_lines ');
    END;
  END IF;
     OKL_TMPT_SET_PUB.update_tmpt_lines(p_api_version     => l_api_version,
                                        p_init_msg_list   => p_init_msg_list,
                                        x_return_status   => x_return_Status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_atlv_rec        => l_atlv_rec,
                                        x_atlv_rec        => x_atlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.update_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.update_tmpt_lines


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


END UPDATE_TMPT_LINES;



PROCEDURE delete_tmpt_lines(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_atlv_tbl                     IN  atlv_tbl_type)

IS

  l_api_version NUMBER := 1.0;


BEGIN

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_lines ');
    END;
  END IF;
   OKL_TMPT_SET_PUB.delete_tmpt_lines(p_api_version     => l_api_version,
                                      p_init_msg_list   => p_init_msg_list,
                                      x_return_status   => x_return_Status,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data,
                                      p_atlv_tbl        => p_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_lines

END delete_tmpt_lines;




PROCEDURE delete_tmpt_lines(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_atlv_rec                     IN  atlv_rec_type)

IS

l_api_version NUMBER := 1.0;

BEGIN
-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_lines ');
    END;
  END IF;
  OKL_TMPT_SET_PUB.delete_tmpt_lines(p_api_version     => l_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => x_return_Status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_atlv_rec        => p_atlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.delete_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.delete_tmpt_lines

END delete_tmpt_lines;


-- mvasudev -- 02/13/2002

/* This API Takes 'From Template Set ID'  and 'To Template Set ID'
   as parameters and copies all the templates and Template Line
   from 'From Template Set ID' to 'To Template Set ID'. The Template
   names in the copied templates is suffixed with '-COPY' so as not
   to violate the unique constraint.  */


PROCEDURE COPY_TMPL_SET(p_api_version                IN         NUMBER,
                        p_init_msg_list              IN         VARCHAR2,
                        x_return_status              OUT        NOCOPY VARCHAR2,
                        x_msg_count                  OUT        NOCOPY NUMBER,
                        x_msg_data                   OUT        NOCOPY VARCHAR2,
                        p_aes_id_from                IN         NUMBER,
                        p_aes_id_to                  IN         NUMBER)

IS


l_return_status    VARCHAR2(1);
l_api_name         VARCHAR2(30) := 'COPY_TMPL_SET';
l_init_msg_list    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_api_version      NUMBER := 1.0;

i                  NUMBER := 0;

l_overall_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_ATS              okl_sys_acct_opts.ACCOUNT_DERIVATION%TYPE ;

l_avlv_rec_in      AVLV_REC_TYPE;
l_avlv_rec_out     AVLV_REC_TYPE;

l_atlv_tbl_in      ATLV_TBL_TYPE;
l_atlv_tbl_out     ATLV_TBL_TYPE;

CURSOR amb_csr is
select ACCOUNT_DERIVATION   from
okl_sys_acct_opts ;

CURSOR avl_csr(v_aes_id NUMBER) IS
SELECT   id
        ,try_id
        ,sty_id
        ,fma_id
        ,fac_code
        ,syt_code
        -- Added by HKPATEL for bug 2943310
        ,inv_code
        -- Added code ends here
        ,post_to_gl
        ,advance_arrears
        ,memo_yn
        ,prior_year_yn
        ,name
        ,description
        ,version
        ,factoring_synd_flag
        ,start_date
        ,end_date
        ,accrual_yn
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
FROM okl_ae_templates
WHERE aes_id = v_aes_id;


CURSOR atl_csr(v_avl_id NUMBER) IS
SELECT  id
       ,sequence_number
       ,avl_id
       ,code_combination_id
       ,ae_line_type
       ,crd_code
       ,account_builder_yn
       ,description
       ,percentage
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM okl_ae_tmpt_lnes
WHERE avl_id = v_avl_id;



BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;


   FOR amb_rec IN amb_csr
   LOOP

      l_ATS := amb_rec.ACCOUNT_DERIVATION ;

   END LOOP ;


   FOR avl_rec IN avl_csr(p_aes_id_from)

   LOOP

        l_avlv_rec_in.try_id                        := avl_rec.try_id;
        l_avlv_rec_in.sty_id                        := avl_rec.sty_id;
        l_avlv_rec_in.fma_id                        := avl_rec.fma_id;
        l_avlv_rec_in.fac_code                      := avl_rec.fac_code;
        l_avlv_rec_in.syt_code                      := avl_rec.syt_code;
        -- Added by HKPATEL for Bug# 2943310
        l_avlv_rec_in.inv_code                      := avl_rec.inv_code;
        -- Added code ends here
        l_avlv_rec_in.post_to_gl                    := avl_rec.post_to_gl;
        l_avlv_rec_in.advance_arrears               := avl_rec.advance_arrears;
        l_avlv_rec_in.memo_yn                       := avl_rec.memo_yn;
        l_avlv_rec_in.prior_year_yn                 := avl_rec.prior_year_yn;
        l_avlv_rec_in.description                   := avl_rec.description;
        l_avlv_rec_in.version                       := avl_rec.version;
        l_avlv_rec_in.factoring_synd_flag           := avl_rec.factoring_synd_flag;
        l_avlv_rec_in.start_date                    := avl_rec.start_date;
        l_avlv_rec_in.end_date                      := avl_rec.end_date;
        l_avlv_rec_in.accrual_yn                    := avl_rec.accrual_yn;
        l_avlv_rec_in.attribute_category            := avl_rec.attribute_category;
        l_avlv_rec_in.attribute1                    := avl_rec.attribute1;
        l_avlv_rec_in.attribute2                    := avl_rec.attribute2;
        l_avlv_rec_in.attribute3                    := avl_rec.attribute3;
        l_avlv_rec_in.attribute4                    := avl_rec.attribute4;
        l_avlv_rec_in.attribute5                    := avl_rec.attribute5;
        l_avlv_rec_in.attribute6                    := avl_rec.attribute6;
        l_avlv_rec_in.attribute7                    := avl_rec.attribute7;
        l_avlv_rec_in.attribute8                    := avl_rec.attribute8;
        l_avlv_rec_in.attribute9                    := avl_rec.attribute9;
        l_avlv_rec_in.attribute10                   := avl_rec.attribute10;
        l_avlv_rec_in.attribute11                   := avl_rec.attribute11;
        l_avlv_rec_in.attribute12                   := avl_rec.attribute12;
        l_avlv_rec_in.attribute13                   := avl_rec.attribute13;
        l_avlv_rec_in.attribute14                   := avl_rec.attribute14;
        l_avlv_rec_in.attribute15                   := avl_rec.attribute15;

        l_avlv_rec_in.aes_id                        := p_aes_id_to;
        l_avlv_rec_in.name                          := avl_rec.name ;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
        OKL_TMPT_SET_PUB.create_template(p_api_version    => l_api_version
                                        ,p_init_msg_list  => l_init_msg_list
                                        ,x_return_status  => l_return_status
                                        ,x_msg_count      => l_msg_count
                                        ,x_msg_data       => l_msg_data
                                        ,p_avlv_rec       => l_avlv_rec_in
                                        ,x_avlv_rec       => l_avlv_rec_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_template


        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) and (l_ATS='ATS') THEN

                -- Initialize the Variables

            i := 0;
            l_atlv_tbl_in.DELETE;

            FOR atl_rec IN atl_csr(avl_rec.ID)

            LOOP

               i := i + 1;

               l_atlv_tbl_in(i).sequence_number       := atl_rec.sequence_number;
               l_atlv_tbl_in(i).avl_id                := l_avlv_rec_out.id;
               l_atlv_tbl_in(i).code_combination_id   := atl_rec.code_combination_id;
               l_atlv_tbl_in(i).ae_line_type          := atl_rec.ae_line_type;
               l_atlv_tbl_in(i).crd_code              := atl_rec.crd_code;
               l_atlv_tbl_in(i).account_builder_yn    := atl_rec.account_builder_yn;
               l_atlv_tbl_in(i).description           := atl_rec.description;
               l_atlv_tbl_in(i).percentage            := atl_rec.percentage;
               l_atlv_tbl_in(i).attribute_category    := atl_rec.attribute_category;
               l_atlv_tbl_in(i).attribute1            := atl_rec.attribute1;
               l_atlv_tbl_in(i).attribute2            := atl_rec.attribute2;
               l_atlv_tbl_in(i).attribute3            := atl_rec.attribute3;
               l_atlv_tbl_in(i).attribute4            := atl_rec.attribute4;
               l_atlv_tbl_in(i).attribute5            := atl_rec.attribute5;
               l_atlv_tbl_in(i).attribute6            := atl_rec.attribute6;
               l_atlv_tbl_in(i).attribute7            := atl_rec.attribute7;
               l_atlv_tbl_in(i).attribute8            := atl_rec.attribute8;
               l_atlv_tbl_in(i).attribute9            := atl_rec.attribute9;
               l_atlv_tbl_in(i).attribute10           := atl_rec.attribute10;
               l_atlv_tbl_in(i).attribute11           := atl_rec.attribute11;
               l_atlv_tbl_in(i).attribute12           := atl_rec.attribute12;
               l_atlv_tbl_in(i).attribute13           := atl_rec.attribute13;
               l_atlv_tbl_in(i).attribute14           := atl_rec.attribute14;
               l_atlv_tbl_in(i).attribute15           := atl_rec.attribute15;


            END LOOP;

            IF (l_atlv_tbl_in.COUNT > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
                 OKL_TMPT_SET_PUB.create_tmpt_lines(p_api_version    => l_api_version
                                                   ,p_init_msg_list  => l_init_msg_list
                                                   ,x_return_status  => l_return_status
                                                   ,x_msg_count      => l_msg_count
                                                   ,x_msg_data       => l_msg_data
                                                   ,p_atlv_tbl       => l_atlv_tbl_in
                                                   ,x_atlv_tbl       => l_atlv_tbl_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines
            END IF;


        END IF;


        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN

                   l_overall_status := l_return_status;

           END IF;

        END IF;


   END LOOP;

   x_return_status := l_overall_status;


   EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END COPY_TMPL_SET;




/* This API will be used to copy a single template and all of its lines. It takes
   source template id as input. First it creates the record for p_avlv_rec in the
   template table and then it uses the source template id to copy the lines from
   source template lines to the current template lines                          */

PROCEDURE COPY_TEMPLATE(p_api_version                IN         NUMBER,
                        p_init_msg_list              IN         VARCHAR2,
                        x_return_status              OUT        NOCOPY VARCHAR2,
                        x_msg_count                  OUT        NOCOPY NUMBER,
                        x_msg_data                   OUT        NOCOPY VARCHAR2,
                        p_avlv_rec                   IN         avlv_rec_type,
                        p_source_tmpl_id             IN         NUMBER,
                        x_avlv_rec                   OUT        NOCOPY avlv_rec_type)
IS

 CURSOR atl_csr IS

 SELECT  code_combination_id,
         ae_line_type,
         crd_code,
         account_builder_yn,
         description,
         percentage,
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
         attribute15
  FROM OKL_AE_TMPT_LNES
  WHERE avl_id = p_source_tmpl_id;

  atl_rec atl_csr%ROWTYPE;



  i                NUMBER := 0;
  l_api_version    NUMBER := 1.0;
  l_init_msg_list  VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_msg_count      NUMBER := 0;
  l_msg_data       VARCHAR2(2000);


  l_atlv_tbl_in    atlv_tbl_type;
  l_atlv_tbl_out   atlv_tbl_type;



BEGIN

-- First Create the Template Record. Use of create_template signature of current
-- API ensures that all the validations are carried out properly.

   create_template(p_api_version          => l_api_version,
                   p_init_msg_list        => l_init_msg_list,
                   x_return_status        => l_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data,
                   p_avlv_rec             => p_avlv_rec,
                   x_avlv_rec             => x_avlv_rec);


-- IF template creation is successful then create template lines

  IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

      i := 0;

      FOR atl_rec IN atl_csr

      LOOP

          i   := i + 1;

          l_atlv_tbl_in(i).avl_id               := x_avlv_rec.ID;
          l_atlv_tbl_in(i).code_combination_id  := atl_rec.code_combination_id;
          l_atlv_tbl_in(i).ae_line_type         := atl_rec.ae_line_type;
          l_atlv_tbl_in(i).crd_code             := atl_rec.crd_code;
          l_atlv_tbl_in(i).account_builder_yn   := atl_rec.account_builder_yn;
          l_atlv_tbl_in(i).description          := atl_rec.description;
          l_atlv_tbl_in(i).percentage           := atl_rec.percentage;
          l_atlv_tbl_in(i).attribute_category   := atl_rec.attribute_category;
          l_atlv_tbl_in(i).attribute1           := atl_rec.attribute1;
          l_atlv_tbl_in(i).attribute2           := atl_rec.attribute2;
          l_atlv_tbl_in(i).attribute3           := atl_rec.attribute3;
          l_atlv_tbl_in(i).attribute4           := atl_rec.attribute4;
          l_atlv_tbl_in(i).attribute5           := atl_rec.attribute5;
          l_atlv_tbl_in(i).attribute6           := atl_rec.attribute6;
          l_atlv_tbl_in(i).attribute7           := atl_rec.attribute7;
          l_atlv_tbl_in(i).attribute8           := atl_rec.attribute8;
          l_atlv_tbl_in(i).attribute9           := atl_rec.attribute9;
          l_atlv_tbl_in(i).attribute10          := atl_rec.attribute10;
          l_atlv_tbl_in(i).attribute11          := atl_rec.attribute11;
          l_atlv_tbl_in(i).attribute12          := atl_rec.attribute12;
          l_atlv_tbl_in(i).attribute13          := atl_rec.attribute13;
          l_atlv_tbl_in(i).attribute14          := atl_rec.attribute14;
          l_atlv_tbl_in(i).attribute15          := atl_rec.attribute15;


      END LOOP;

-- Start of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
      OKL_TMPT_SET_PUB.create_tmpt_lines(p_api_version    => l_api_version,
                                         p_init_msg_list  => l_init_msg_list,
                                         x_return_status  => l_return_status,
                                         x_msg_count      => l_msg_count,
                                         x_msg_data       => l_msg_data,
                                         p_atlv_tbl       => l_atlv_tbl_in,
                                         x_atlv_tbl       => l_atlv_tbl_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTMSB.pls call OKL_TMPT_SET_PUB.create_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TMPT_SET_PUB.create_tmpt_lines


  END IF;


  x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END COPY_TEMPLATE;
-- end,mvasudev -- 02/13/2002

--kmotepal added as a part of user defined streams bug 3944429
PROCEDURE validate_gts_id (p_gts_id         IN NUMBER
                           ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
  l_dummy         VARCHAR2(1)  := Okl_Api.G_FALSE;
  l_token_2        VARCHAR2(1999);

  CURSOR gts_csr(l_gts_id NUMBER) IS
  SELECT '1'
  FROM OKL_ST_GEN_TMPT_SETS
  WHERE OKL_ST_GEN_TMPT_SETS.ID  = l_gts_id;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_2 := Okl_Accounting_Util.get_message_token(p_region_code => 'OKL_LP_TEMPLATE_SETS',
                                                       p_attribute_code =>'OKL_STREAM_TEMPLATE');

     IF (p_gts_id  IS NULL) OR (p_gts_id = Okl_Api.G_MISS_NUM) THEN
           Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_required_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => l_token_2);
                x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    IF (p_gts_id  IS NOT NULL) AND (p_gts_id <> Okl_Api.G_MISS_NUM) THEN

       OPEN gts_csr(p_gts_id);
       FETCH gts_csr INTO l_dummy;
       IF (gts_csr%NOTFOUND) THEN
           Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                              ,p_msg_name       => g_invalid_value
                              ,p_token1         => g_col_name_token
                              ,p_token1_value   => l_token_2);
           x_return_status    := Okl_Api.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;
           CLOSE gts_csr;
       END IF;
       CLOSE gts_csr;
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status    := Okl_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END validate_gts_id;


END OKL_PROCESS_TMPT_SET_PVT;

/

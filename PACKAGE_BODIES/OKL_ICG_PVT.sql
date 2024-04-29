--------------------------------------------------------
--  DDL for Package Body OKL_ICG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ICG_PVT" AS
/* $Header: OKLSICGB.pls 120.2 2008/03/04 22:20:30 djanaswa ship $ */

-----------------------------------------------------------------------------
-- FUNCTION get_seq_id
-----------------------------------------------------------------------------

  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

-----------------------------------------------------------------------------
-- PROCEDURE qc
-----------------------------------------------------------------------------

  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

-----------------------------------------------------------------------------
-- PROCEDURE change_version
-----------------------------------------------------------------------------

  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

-----------------------------------------------------------------------------
-- PROCEDURE api_copy
-----------------------------------------------------------------------------

  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

-----------------------------------------------------------------------------
-- Procedure Name	: validate_icg_id
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Current Version	: 1.0
--
-- Change History
--
-- N/A (first version)
--
-- Comments:
--
-- End of Comments
-----------------------------------------------------------------------------

PROCEDURE validate_icg_id(x_return_status OUT NOCOPY VARCHAR2,p_icgv_rec IN icgv_rec_type ) IS

 BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   IF p_icgv_rec.id IS NULL THEN

          OKC_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_REQUIRED_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'ID');

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RETURN;

   END IF;

 EXCEPTION

   WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
              OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_icg_id;

-----------------------------------------------------------------------------
-- Procedure Name	: validate_icg_obj_version_num
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Current Version	: 1.0
--
-- Change History
--
-- N/A (first version)
--
-- Comments:
--
-- End of Comments
-----------------------------------------------------------------------------

PROCEDURE validate_icg_obj_version_num(x_return_status OUT NOCOPY VARCHAR2,p_icgv_rec IN icgv_rec_type ) IS

 BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   IF p_icgv_rec.object_version_number IS NULL THEN

         OKC_API.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'OBJECT_VERSION_NUMBER');

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RETURN;

   END IF;

 EXCEPTION

   WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
  OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_icg_obj_version_num;

-----------------------------------------------------------------------------
-- Procedure Name	: validate_icg_iay_id
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Current Version	: 1.1
--
-- Change History from Version 1.0 to Version 1.1:
--
-- Changed cursor definition: changed WHERE clause to id1 = ... (previously id = ...)
--
-- Comments:
--
-- End of Comments
-----------------------------------------------------------------------------

PROCEDURE validate_icg_iay_id(x_return_status OUT NOCOPY VARCHAR2,p_icgv_rec IN icgv_rec_type) IS

    l_dummy_var VARCHAR2(1) := '?';

    CURSOR l_icgv_csr IS
    SELECT 'x'
    FROM okx_asst_catgrs_v
    WHERE id1 = p_icgv_rec.iay_id
    AND
    NVL(TRUNC(END_DATE_ACTIVE), SYSDATE) >= TRUNC(SYSDATE);

 BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   IF p_icgv_rec.iay_id IS NULL THEN

         OKC_API.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'IAY_ID');

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   OPEN l_icgv_csr;
      FETCH l_icgv_csr into l_dummy_var;
   CLOSE l_icgv_csr;

   IF (l_dummy_var ='?') THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'IAY_ID',
                               p_token2             => g_child_table_token,
                               p_token2_value       => 'OKL_INS_CLASS_CATS',
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'OKX_ASST_CATGRS_V');

      x_return_status := OKC_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

 EXCEPTION

         WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
  OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_icg_iay_id;

-----------------------------------------------------------------------------
-- Procedure Name	: validate_icg_iac_code
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Current Version	: 1.1
--
-- Change History from Version 1.0 to Version 1.1:
--
-- Utilized OKL_UTIL for validation
--
--
-- Comments:
--
-- End of Comments
-----------------------------------------------------------------------------

PROCEDURE validate_icg_iac_code(x_return_status OUT NOCOPY VARCHAR2,p_icgv_rec IN icgv_rec_type) IS

 BEGIN

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

   IF p_icgv_rec.iac_code IS NULL THEN

         OKC_API.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'IAC_CODE'
                            );

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RETURN;
   END IF;


   -- FND Lookup validation

   x_return_status := OKL_UTIL.check_lookup_code('OKL_INSURANCE_ASSET_CLASS', p_icgv_rec.iac_code);

   IF NOT (x_return_status = OKC_API.G_RET_STS_SUCCESS ) THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'IAC_CODE',
                               p_token2             => g_child_table_token,
                               p_token2_value       => 'OKL_INS_CLASS_CATS',
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'FND_LOOKUPS');

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

 EXCEPTION

         WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
  OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_icg_iac_code;

-----------------------------------------------------------------------------
-- Procedure Name	: validate_icg_date_from
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Current Version	: 1.0
--
-- Change History
--
-- N/A (first version)
--
-- Comments:
--
--
--
-- End of Comments
-----------------------------------------------------------------------------

PROCEDURE validate_icg_date_from(x_return_status OUT NOCOPY VARCHAR2,p_icgv_rec IN icgv_rec_type ) IS

 BEGIN

       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_icgv_rec.date_from IS NULL THEN

         OKC_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'DATE_FROM');

         x_return_status := OKC_API.G_RET_STS_ERROR;
         RETURN;
       END IF;

 EXCEPTION

   WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
              OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_icg_date_from;

-----------------------------------------------------------------------------
/*
PROCEDURE validate_icg_date_to(x_return_status OUT NOCOPY VARCHAR2,p_icgv_rec IN icgv_rec_type ) IS

 BEGIN

       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_icgv_rec.date_to IS NOT NULL THEN

          IF TRUNC(p_icgv_rec.date_to) < TRUNC(SYSDATE) THEN

            OKC_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_END_DATE');

            x_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN;
          END IF;
       END IF;

 EXCEPTION

   WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
  OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_icg_date_to;
*/
-----------------------------------------------------------------------------
-- Function : get_rec (OKL_INS_CLASS_CATS)
-----------------------------------------------------------------------------

  FUNCTION get_rec (p_icg_rec IN icg_rec_type, x_no_data_found OUT NOCOPY BOOLEAN) RETURN icg_rec_type IS

    CURSOR okl_ins_class_cats_pk_csr (p_id IN NUMBER) IS
      SELECT
            ID,
            IAC_CODE,
            IAY_ID,
            OBJECT_VERSION_NUMBER,
            DATE_FROM,
            DATE_TO,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
        FROM Okl_Ins_Class_Cats
       WHERE okl_ins_class_cats.id = p_id;

     l_okl_ins_class_cats_pk        okl_ins_class_cats_pk_csr%ROWTYPE;
     l_icg_rec                      icg_rec_type;

    BEGIN

      x_no_data_found := TRUE;

      -- Get current database values
      OPEN okl_ins_class_cats_pk_csr (p_icg_rec.id);
      FETCH okl_ins_class_cats_pk_csr INTO
              l_icg_rec.ID,
              l_icg_rec.IAC_CODE,
              l_icg_rec.IAY_ID,
              l_icg_rec.OBJECT_VERSION_NUMBER,
              l_icg_rec.DATE_FROM,
              l_icg_rec.DATE_TO,
              l_icg_rec.CREATED_BY,
              l_icg_rec.CREATION_DATE,
              l_icg_rec.LAST_UPDATED_BY,
              l_icg_rec.LAST_UPDATE_DATE,
              l_icg_rec.LAST_UPDATE_LOGIN;

      x_no_data_found := okl_ins_class_cats_pk_csr%NOTFOUND;
      CLOSE okl_ins_class_cats_pk_csr;
      RETURN(l_icg_rec);

    END get_rec;

  FUNCTION get_rec (
    p_icg_rec                      IN icg_rec_type
  ) RETURN icg_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_icg_rec, l_row_notfound));
  END get_rec;

-----------------------------------------------------------------------------
-- Function : get_rec (OKL_INS_CLASS_CATS_V)
-----------------------------------------------------------------------------

  FUNCTION get_rec (p_icgv_rec IN icgv_rec_type, x_no_data_found OUT NOCOPY BOOLEAN) RETURN icgv_rec_type IS

    CURSOR okl_icgv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IAY_ID,
            IAC_CODE,
            DATE_FROM,
            DATE_TO,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM okl_ins_class_cats_v
      WHERE okl_ins_class_cats_v.id = p_id;

     l_okl_icgv_pk                  okl_icgv_pk_csr%ROWTYPE;
     l_icgv_rec                     icgv_rec_type;

   BEGIN

     x_no_data_found := TRUE;
     -- Get current database values
     OPEN okl_icgv_pk_csr (p_icgv_rec.id);
     FETCH okl_icgv_pk_csr INTO
              l_icgv_rec.ID,
              l_icgv_rec.OBJECT_VERSION_NUMBER,
              l_icgv_rec.IAY_ID,
              l_icgv_rec.IAC_CODE,
              l_icgv_rec.DATE_FROM,
              l_icgv_rec.DATE_TO,
              l_icgv_rec.CREATED_BY,
              l_icgv_rec.CREATION_DATE,
              l_icgv_rec.LAST_UPDATED_BY,
              l_icgv_rec.LAST_UPDATE_DATE,
              l_icgv_rec.LAST_UPDATE_LOGIN;
      x_no_data_found := okl_icgv_pk_csr%NOTFOUND;
      CLOSE okl_icgv_pk_csr;
      RETURN(l_icgv_rec);

    END get_rec;

  FUNCTION get_rec (p_icgv_rec IN icgv_rec_type) RETURN icgv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_icgv_rec, l_row_notfound));
  END get_rec;

-----------------------------------------------------------------------------
-- Function : null_out_defaults
-----------------------------------------------------------------------------

  FUNCTION null_out_defaults (p_icgv_rec IN icgv_rec_type) RETURN icgv_rec_type IS

      l_icgv_rec	icgv_rec_type := p_icgv_rec;

   BEGIN

    IF (l_icgv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_icgv_rec.object_version_number := NULL;
    END IF;
    IF (l_icgv_rec.iay_id = OKC_API.G_MISS_NUM) THEN
      l_icgv_rec.iay_id := NULL;
    END IF;
    IF (l_icgv_rec.iac_code = OKC_API.G_MISS_CHAR) THEN
      l_icgv_rec.iac_code := NULL;
    END IF;
    IF (l_icgv_rec.date_from = OKC_API.G_MISS_DATE) THEN
      l_icgv_rec.date_from := NULL;
    END IF;
    IF (l_icgv_rec.date_to = OKC_API.G_MISS_DATE) THEN
      l_icgv_rec.date_to := NULL;
    END IF;
    IF (l_icgv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_icgv_rec.created_by := NULL;
    END IF;
    IF (l_icgv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_icgv_rec.creation_date := NULL;
    END IF;
    IF (l_icgv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_icgv_rec.last_updated_by := NULL;
    END IF;
    IF (l_icgv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_icgv_rec.last_update_date := NULL;
    END IF;
    IF (l_icgv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_icgv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_icgv_rec);

  END null_out_defaults;

-----------------------------------------------------------------------------
-- Function Name	: validate_attributes (for OKL_INS_CLASS_CATS_V)
-- Description		:
-- Business Rules	:
-- Parameters		: icgv_rec_type
-- Current Version	: 1.1
--
-- Change History from Version 1.0 to Version 1.1:
--
-- Added call to Procedure 'icg_date_from' for column_level validation
--
-- Comments:
--
-- End of Comments
-----------------------------------------------------------------------------

FUNCTION validate_attributes (p_icgv_rec IN icgv_rec_type) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

   BEGIN

     -- call icg ID column-level validation

     validate_icg_id(x_return_status => l_return_status,p_icgv_rec => p_icgv_rec);

     IF NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       RETURN(l_return_status);
     END IF;

     -- call icg object version number column-level validation

     validate_icg_obj_version_num(x_return_status=>l_return_status, p_icgv_rec=>p_icgv_rec);

     IF NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       RETURN(l_return_status);
     END IF;

     -- call icg iay_id column-level validation

     validate_icg_iay_id(x_return_status=>l_return_status, p_icgv_rec=>p_icgv_rec);

     IF NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       RETURN(l_return_status);
     END IF;

     -- call icg iac_code column_level validation

     validate_icg_iac_code(x_return_status=>l_return_status, p_icgv_rec=>p_icgv_rec);

     IF NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       RETURN(l_return_status);
     END IF;

     -- call icg date_from column_level validation

     validate_icg_date_from (x_return_status=>l_return_status, p_icgv_rec=>p_icgv_rec);

     IF NOT (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       RETURN(l_return_status);
     END IF;


  RETURN(l_return_status);

 END validate_attributes;

-----------------------------------------------------------------------------
-- Function Name	: validate_record (for OKL_INS_CLASS_CATS_V)
-- Description		:
-- Business Rules	:
-- Parameters		: icgv_rec_type
-- Current Version	: 1.1
--
-- Change History from Version 1.0 to Version 1.1:
--
-- Removed date validations
--
-- Comments:
--
-- End of Comments
-----------------------------------------------------------------------------

 FUNCTION validate_record (p_icgv_rec IN icgv_rec_type) RETURN VARCHAR2 IS

     l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy VARCHAR(1) := '?';

     CURSOR c_active_rec IS
            SELECT id, iay_id, date_from, date_to
            FROM   okl_ins_class_cats
            WHERE  id <> (p_icgv_rec.id)
               AND (iay_id = p_icgv_rec.iay_id AND NVL(TRUNC(date_to) + 1, SYSDATE) >= SYSDATE);

     CURSOR c_asset_category_csr ( p_category_id NUMBER)  IS
             SELECT name
             FROM OKX_ASST_CATGRS_V
             WHERE id1 = p_category_id;

     l_asset_category  OKX_ASST_CATGRS_V.name%TYPE;


  BEGIN

      IF TRUNC(p_icgv_rec.date_to) < TRUNC(p_icgv_rec.date_from) THEN
      OKC_API.set_message(G_APP_NAME,
             p_msg_name     => 'OKL_GREATER_THAN',
			      p_token1       => 'COL_NAME1',
			      p_token1_value => 'Effective To',
			      p_token2       => 'COL_NAME2',
			      p_token2_value => 'Effective From');

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN(l_return_status);
      END IF;

      FOR v_rec IN c_active_rec LOOP

        IF
        v_rec.id <> p_icgv_rec.id AND
        TRUNC(v_rec.date_from) <= TRUNC(SYSDATE) THEN

        l_return_status := OKC_API.G_RET_STS_ERROR;
-- changes for bug 860113 start
        l_asset_category := null;
        OPEN c_asset_category_csr (p_icgv_rec.iay_id);
        FETCH c_asset_category_csr INTO l_asset_category;
        CLOSE c_asset_category_csr;

        OKC_API.set_message( p_app_name    => g_app_name,
                             p_msg_name    => 'OKL_ACTIVE_INS_ASSET_FOUND',
                             p_token1      => 'ASSET_CATEGORY' ,
                             p_token1_value => l_asset_category);

      -- G_APP_NAME, 'OKL_ACTIVE_INS_ASSET_FOUND')
      --  RETURN(l_return_status);
-- changes for bug 860113 end
      END IF;

    END LOOP;

   RETURN l_return_status;

 EXCEPTION

      WHEN OTHERS THEN
        OKC_API.set_message(p_app_name    => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => sqlcode,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => sqlerrm);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        RETURN(l_return_status);

 END validate_record;


-----------------------------------------------------------------------------
-- Function : migrate (OKL_INS_CLASS_CATS_V)
-----------------------------------------------------------------------------

 PROCEDURE migrate (p_from IN icgv_rec_type, p_to IN OUT NOCOPY icg_rec_type) IS

  BEGIN

    p_to.id := p_from.id;
    p_to.iac_code := p_from.iac_code;
    p_to.iay_id := p_from.iay_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_from := p_from.date_from;
    p_to.date_to := p_from.date_to;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

 END migrate;

-----------------------------------------------------------------------------
-- Function : migrate (OKL_INS_CLASS_CATS)
-----------------------------------------------------------------------------

  PROCEDURE migrate (p_from IN icg_rec_type, p_to IN OUT NOCOPY icgv_rec_type) IS

   BEGIN

    p_to.id := p_from.id;
    p_to.iac_code := p_from.iac_code;
    p_to.iay_id := p_from.iay_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_from := p_from.date_from;
    p_to.date_to := p_from.date_to;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

   END migrate;

-----------------------------------------------------------------------------
-- Procedure Name	: validate_row
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Current Version	: 1.0
--
-- Change History:
--
-- N/A (first version)
--
-- Comments:  This procedure is not called by either insert_row or update_row.
--            Removing this code altogether is warranted.
-- End of Comments
-----------------------------------------------------------------------------

 PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_rec                     IN icgv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icgv_rec                     icgv_rec_type := p_icgv_rec;
    l_icg_rec                      icg_rec_type;

  BEGIN

    -- Validate package name and api version number

    l_return_status := OKC_API.start_activity(l_api_name,
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


    -- Validate attributes (column level validation)

    l_return_status := validate_attributes(l_icgv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Validate record

    l_return_status := validate_record(l_icgv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.end_activity(x_msg_count, x_msg_data);


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

-----------------------------------------------------------------------------
-- Procedure : validate_row (icgv_tbl_type)
-----------------------------------------------------------------------------

 PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_tbl                     IN icgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_icgv_tbl.COUNT > 0) THEN
      i := p_icgv_tbl.FIRST;
      LOOP

        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_icgv_rec                     => p_icgv_tbl(i));

        EXIT WHEN (i = p_icgv_tbl.LAST);
        i := p_icgv_tbl.NEXT(i);

      END LOOP;

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

-----------------------------------------------------------------------------
-- PROCEDURE insert_row (OKL_INS_CLASS_CATS)
-----------------------------------------------------------------------------

  PROCEDURE insert_row(
 			p_init_msg_list		IN 		VARCHAR2 DEFAULT OKC_API.G_FALSE,
    			x_return_status 	OUT NOCOPY 	VARCHAR2,
    			x_msg_count 		OUT NOCOPY 	NUMBER,
    			x_msg_data  		OUT NOCOPY 	VARCHAR2,
    			p_icg_rec  		IN 		icg_rec_type,
    			x_icg_rec		OUT NOCOPY 	icg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CATS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icg_rec                      icg_rec_type := p_icg_rec;
    l_def_icg_rec                  icg_rec_type;

    -------------------------------------------
    -- Set_Attributes for:OKL_INS_CLASS_CATS --
    -------------------------------------------
    FUNCTION Set_Attributes (p_icg_rec IN icg_rec_type, x_icg_rec OUT NOCOPY icg_rec_type) RETURN VARCHAR2 IS
      l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_icg_rec := p_icg_rec;
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

    -- Call SET_ATTRIBUTES

    l_return_status := Set_Attributes(p_icg_rec, l_icg_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_INS_CLASS_CATS(
        id,
        iac_code,
        iay_id,
        object_version_number,
        date_from,
        date_to,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_icg_rec.id,
        l_icg_rec.iac_code,
        l_icg_rec.iay_id,
        l_icg_rec.object_version_number,
        l_icg_rec.date_from,
        l_icg_rec.date_to,
        l_icg_rec.created_by,
        l_icg_rec.creation_date,
        l_icg_rec.last_updated_by,
        l_icg_rec.last_update_date,
        l_icg_rec.last_update_login);

    -- Set OUT values
    x_icg_rec := l_icg_rec;
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

-----------------------------------------------------------------------------
-- PROCEDURE insert_row (OKL_INS_CLASS_CATS_V)
-----------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_rec                     IN icgv_rec_type,
    x_icgv_rec                     OUT NOCOPY icgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icgv_rec                     icgv_rec_type;
    l_def_icgv_rec                 icgv_rec_type;
    l_icg_rec                      icg_rec_type;
    lx_icg_rec                     icg_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (p_icgv_rec IN icgv_rec_type) RETURN icgv_rec_type IS

      l_icgv_rec	icgv_rec_type := p_icgv_rec;

    BEGIN

      l_icgv_rec.CREATION_DATE := SYSDATE;
      l_icgv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_icgv_rec.LAST_UPDATE_DATE := l_icgv_rec.CREATION_DATE;
      l_icgv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_icgv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_icgv_rec);

    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INS_CLASS_CATS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (p_icgv_rec IN icgv_rec_type,
                             x_icgv_rec OUT NOCOPY icgv_rec_type) RETURN VARCHAR2 IS

      l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

     BEGIN

       x_icgv_rec := p_icgv_rec;
       x_icgv_rec.OBJECT_VERSION_NUMBER := 1;
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

    l_icgv_rec := null_out_defaults(p_icgv_rec);

    -- Set PK value

    l_icgv_rec.ID := get_seq_id;

    l_return_status := set_attributes(l_icgv_rec, l_def_icgv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    l_def_icgv_rec := fill_who_columns(l_def_icgv_rec);

    -- Perform column-level validation

    l_return_status := validate_attributes(l_def_icgv_rec);

    --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    -- Perform record-level validation

    l_return_status := validate_record(l_def_icgv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_icgv_rec, l_icg_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_icg_rec,
      lx_icg_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_icg_rec, l_def_icgv_rec);
    -- Set OUT values
    x_icgv_rec := l_def_icgv_rec;

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

-----------------------------------------------------------------------------
-- PROCEDURE insert_row (icgv_tbl_type)
-----------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_tbl                     IN icgv_tbl_type,
    x_icgv_tbl                     OUT NOCOPY icgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_icgv_tbl.COUNT > 0) THEN
      i := p_icgv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_icgv_rec                     => p_icgv_tbl(i),
          x_icgv_rec                     => x_icgv_tbl(i));
        EXIT WHEN (i = p_icgv_tbl.LAST);
        i := p_icgv_tbl.NEXT(i);
      END LOOP;
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

-----------------------------------------------------------------------------
-- PROCEDURE lock_row (OKL_INS_CLASS_CATS)
-----------------------------------------------------------------------------

  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icg_rec                      IN icg_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_icg_rec IN icg_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_CLASS_CATS
     WHERE ID = p_icg_rec.id
       AND OBJECT_VERSION_NUMBER = p_icg_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_icg_rec IN icg_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_CLASS_CATS
    WHERE ID = p_icg_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CATS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INS_CLASS_CATS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INS_CLASS_CATS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_icg_rec);
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
      OPEN lchk_csr(p_icg_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_icg_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_icg_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_INS_CLASS_CATS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_rec                     IN icgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icg_rec                      icg_rec_type;
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
    migrate(p_icgv_rec, l_icg_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_icg_rec
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
  -- PL/SQL TBL lock_row for:ICGV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_tbl                     IN icgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_icgv_tbl.COUNT > 0) THEN
      i := p_icgv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_icgv_rec                     => p_icgv_tbl(i));
        EXIT WHEN (i = p_icgv_tbl.LAST);
        i := p_icgv_tbl.NEXT(i);
      END LOOP;
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

-----------------------------------------------------------------------------
-- PROCEDURE update_row (OKL_INS_CLASS_CATS)
-----------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icg_rec                      IN icg_rec_type,
    x_icg_rec                      OUT NOCOPY icg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CATS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icg_rec                      icg_rec_type := p_icg_rec;
    l_def_icg_rec                  icg_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_icg_rec	IN icg_rec_type,
      x_icg_rec	OUT NOCOPY icg_rec_type
    ) RETURN VARCHAR2 IS
      l_icg_rec                      icg_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_icg_rec := p_icg_rec;
      -- Get current database values
      l_icg_rec := get_rec(p_icg_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_icg_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_icg_rec.id := l_icg_rec.id;
      END IF;
      IF (x_icg_rec.iac_code = OKC_API.G_MISS_CHAR)
      THEN
        x_icg_rec.iac_code := l_icg_rec.iac_code;
      END IF;
      IF (x_icg_rec.iay_id = OKC_API.G_MISS_NUM)
      THEN
        x_icg_rec.iay_id := l_icg_rec.iay_id;
      END IF;
      IF (x_icg_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_icg_rec.object_version_number := l_icg_rec.object_version_number;
      END IF;
      IF (x_icg_rec.date_from = OKC_API.G_MISS_DATE)
      THEN
        x_icg_rec.date_from := l_icg_rec.date_from;
      END IF;
      IF (x_icg_rec.date_to = OKC_API.G_MISS_DATE)
      THEN
        x_icg_rec.date_to := l_icg_rec.date_to;
      END IF;
      IF (x_icg_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_icg_rec.created_by := l_icg_rec.created_by;
      END IF;
      IF (x_icg_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_icg_rec.creation_date := l_icg_rec.creation_date;
      END IF;
      IF (x_icg_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_icg_rec.last_updated_by := l_icg_rec.last_updated_by;
      END IF;
      IF (x_icg_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_icg_rec.last_update_date := l_icg_rec.last_update_date;
      END IF;
      IF (x_icg_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_icg_rec.last_update_login := l_icg_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_INS_CLASS_CATS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_icg_rec IN  icg_rec_type,
      x_icg_rec OUT NOCOPY icg_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_icg_rec := p_icg_rec;
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
      p_icg_rec,                         -- IN
      l_icg_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_icg_rec, l_def_icg_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INS_CLASS_CATS
    SET IAC_CODE = l_def_icg_rec.iac_code,
        IAY_ID = l_def_icg_rec.iay_id,
        OBJECT_VERSION_NUMBER = l_def_icg_rec.object_version_number,
        DATE_FROM = l_def_icg_rec.date_from,
        DATE_TO = l_def_icg_rec.date_to,
        CREATED_BY = l_def_icg_rec.created_by,
        CREATION_DATE = l_def_icg_rec.creation_date,
        LAST_UPDATED_BY = l_def_icg_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_icg_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_icg_rec.last_update_login
    WHERE ID = l_def_icg_rec.id;

    x_icg_rec := l_def_icg_rec;
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

-----------------------------------------------------------------------------
-- PROCEDURE update_row (OKL_INS_CLASS_CATS_V)
-----------------------------------------------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_rec                     IN icgv_rec_type,
    x_icgv_rec                     OUT NOCOPY icgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icgv_rec                     icgv_rec_type := p_icgv_rec;
    l_def_icgv_rec                 icgv_rec_type;
    l_icg_rec                      icg_rec_type;
    lx_icg_rec                     icg_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_icgv_rec	IN icgv_rec_type
    ) RETURN icgv_rec_type IS
      l_icgv_rec	icgv_rec_type := p_icgv_rec;
    BEGIN
      l_icgv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_icgv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_icgv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_icgv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_icgv_rec	IN icgv_rec_type,
      x_icgv_rec	OUT NOCOPY icgv_rec_type
    ) RETURN VARCHAR2 IS
      l_icgv_rec                     icgv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_icgv_rec := p_icgv_rec;
      -- Get current database values
      l_icgv_rec := get_rec(p_icgv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_icgv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_icgv_rec.id := l_icgv_rec.id;
      END IF;
      IF (x_icgv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
          x_icgv_rec.object_version_number := l_icgv_rec.object_version_number;
      END IF;
      IF (x_icgv_rec.iay_id = OKC_API.G_MISS_NUM)
      THEN
        x_icgv_rec.iay_id := l_icgv_rec.iay_id;
      END IF;
      IF (x_icgv_rec.iac_code = OKC_API.G_MISS_CHAR)
      THEN
        x_icgv_rec.iac_code := l_icgv_rec.iac_code;
      END IF;
      IF (x_icgv_rec.date_from = OKC_API.G_MISS_DATE)
      THEN
        x_icgv_rec.date_from := l_icgv_rec.date_from;
      END IF;
      IF (x_icgv_rec.date_to = OKC_API.G_MISS_DATE)
      THEN
        x_icgv_rec.date_to := l_icgv_rec.date_to;
      END IF;
      IF (x_icgv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_icgv_rec.created_by := l_icgv_rec.created_by;
      END IF;
      IF (x_icgv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_icgv_rec.creation_date := l_icgv_rec.creation_date;
      END IF;
      IF (x_icgv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_icgv_rec.last_updated_by := l_icgv_rec.last_updated_by;
      END IF;
      IF (x_icgv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_icgv_rec.last_update_date := l_icgv_rec.last_update_date;
      END IF;
      IF (x_icgv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_icgv_rec.last_update_login := l_icgv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INS_CLASS_CATS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_icgv_rec IN  icgv_rec_type,
      x_icgv_rec OUT NOCOPY icgv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

      x_icgv_rec := p_icgv_rec;

      -- WARNING! Server cannot make distinction between G_MISS_NUM and (G_MISS_NUM + 1)
      -- therefore do not send object_version_number = G_MISS_NUM to the update_record procedure from UI.
      x_icgv_rec.OBJECT_VERSION_NUMBER := NVL(x_icgv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

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

   l_return_status := Set_Attributes(p_icgv_rec,l_icgv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   l_return_status := populate_new_record(l_icgv_rec, l_def_icgv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   l_def_icgv_rec := fill_who_columns(l_def_icgv_rec);

   l_return_status := Validate_Attributes(l_def_icgv_rec);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

   l_return_status := Validate_Record(l_def_icgv_rec);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_icgv_rec, l_icg_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_icg_rec,
      lx_icg_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_icg_rec, l_def_icgv_rec);
    x_icgv_rec := l_def_icgv_rec;
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
  -- PL/SQL TBL update_row for:ICGV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_tbl                     IN icgv_tbl_type,
    x_icgv_tbl                     OUT NOCOPY icgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_icgv_tbl.COUNT > 0) THEN
      i := p_icgv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_icgv_rec                     => p_icgv_tbl(i),
          x_icgv_rec                     => x_icgv_tbl(i));
        EXIT WHEN (i = p_icgv_tbl.LAST);
        i := p_icgv_tbl.NEXT(i);
      END LOOP;
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
  ---------------------------------------
  -- delete_row for:OKL_INS_CLASS_CATS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icg_rec                      IN icg_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CATS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icg_rec                      icg_rec_type:= p_icg_rec;
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
    DELETE FROM OKL_INS_CLASS_CATS
     WHERE ID = l_icg_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKL_INS_CLASS_CATS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_rec                     IN icgv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_icgv_rec                     icgv_rec_type := p_icgv_rec;
    l_icg_rec                      icg_rec_type;
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
    migrate(l_icgv_rec, l_icg_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_icg_rec
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
  -- PL/SQL TBL delete_row for:ICGV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_icgv_tbl                     IN icgv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_icgv_tbl.COUNT > 0) THEN
      i := p_icgv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_icgv_rec                     => p_icgv_tbl(i));
        EXIT WHEN (i = p_icgv_tbl.LAST);
        i := p_icgv_tbl.NEXT(i);
      END LOOP;
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

END OKL_ICG_PVT;

/

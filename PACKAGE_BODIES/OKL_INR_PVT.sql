--------------------------------------------------------
--  DDL for Package Body OKL_INR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INR_PVT" AS
/* $Header: OKLSINRB.pls 120.6 2006/07/28 10:02:31 akrangan noship $ */



---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
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
  -- FUNCTION get_rec for: OKL_INS_RATES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_inr_rec                      IN inr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN inr_rec_type IS
    CURSOR okl_ins_rates_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            IAC_CODE,
            IPT_ID,
            IC_ID,
            COVERAGE_MAX,
            DEDUCTIBLE,
            OBJECT_VERSION_NUMBER,
            FACTOR_RANGE_START,
            INSURED_RATE,
            FACTOR_RANGE_END,
            DATE_FROM,
            DATE_TO,
            INSURER_RATE,
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
      FROM Okl_Ins_Rates
     WHERE okl_ins_rates.id     = p_id;
    l_okl_ins_rates_pk             okl_ins_rates_pk_csr%ROWTYPE;
    l_inr_rec                      inr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ins_rates_pk_csr (p_inr_rec.id);
    FETCH okl_ins_rates_pk_csr INTO
              l_inr_rec.ID,
              l_inr_rec.IAC_CODE,
              l_inr_rec.IPT_ID,
              l_inr_rec.IC_ID,
              l_inr_rec.COVERAGE_MAX,
              l_inr_rec.DEDUCTIBLE,
              l_inr_rec.OBJECT_VERSION_NUMBER,
              l_inr_rec.FACTOR_RANGE_START,
              l_inr_rec.INSURED_RATE,
              l_inr_rec.FACTOR_RANGE_END,
              l_inr_rec.DATE_FROM,
              l_inr_rec.DATE_TO,
              l_inr_rec.INSURER_RATE,
              l_inr_rec.ATTRIBUTE_CATEGORY,
              l_inr_rec.ATTRIBUTE1,
              l_inr_rec.ATTRIBUTE2,
              l_inr_rec.ATTRIBUTE3,
              l_inr_rec.ATTRIBUTE4,
              l_inr_rec.ATTRIBUTE5,
              l_inr_rec.ATTRIBUTE6,
              l_inr_rec.ATTRIBUTE7,
              l_inr_rec.ATTRIBUTE8,
              l_inr_rec.ATTRIBUTE9,
              l_inr_rec.ATTRIBUTE10,
              l_inr_rec.ATTRIBUTE11,
              l_inr_rec.ATTRIBUTE12,
              l_inr_rec.ATTRIBUTE13,
              l_inr_rec.ATTRIBUTE14,
              l_inr_rec.ATTRIBUTE15,
              l_inr_rec.CREATED_BY,
              l_inr_rec.CREATION_DATE,
              l_inr_rec.LAST_UPDATED_BY,
              l_inr_rec.LAST_UPDATE_DATE,
              l_inr_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ins_rates_pk_csr%NOTFOUND;
    CLOSE okl_ins_rates_pk_csr;
    RETURN(l_inr_rec);
  END get_rec;
  FUNCTION get_rec (
    p_inr_rec                      IN inr_rec_type
  ) RETURN inr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_inr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_RATES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_inrv_rec                     IN inrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN inrv_rec_type IS
    CURSOR okl_inrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IC_ID,
            IPT_ID,
            IAC_CODE,
            COVERAGE_MAX,
            DEDUCTIBLE,
            FACTOR_RANGE_START,
            INSURED_RATE,
            FACTOR_RANGE_END,
            DATE_FROM,
            DATE_TO,
            INSURER_RATE,
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
      FROM Okl_Ins_Rates_V
     WHERE okl_ins_rates_v.id   = p_id;
    l_okl_inrv_pk                  okl_inrv_pk_csr%ROWTYPE;
    l_inrv_rec                     inrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_inrv_pk_csr (p_inrv_rec.id);
    FETCH okl_inrv_pk_csr INTO
              l_inrv_rec.ID,
              l_inrv_rec.OBJECT_VERSION_NUMBER,
              l_inrv_rec.IC_ID,
              l_inrv_rec.IPT_ID,
              l_inrv_rec.IAC_CODE,
              l_inrv_rec.COVERAGE_MAX,
              l_inrv_rec.DEDUCTIBLE,
              l_inrv_rec.FACTOR_RANGE_START,
              l_inrv_rec.INSURED_RATE,
              l_inrv_rec.FACTOR_RANGE_END,
              l_inrv_rec.DATE_FROM,
              l_inrv_rec.DATE_TO,
              l_inrv_rec.INSURER_RATE,
              l_inrv_rec.ATTRIBUTE_CATEGORY,
              l_inrv_rec.ATTRIBUTE1,
              l_inrv_rec.ATTRIBUTE2,
              l_inrv_rec.ATTRIBUTE3,
              l_inrv_rec.ATTRIBUTE4,
              l_inrv_rec.ATTRIBUTE5,
              l_inrv_rec.ATTRIBUTE6,
              l_inrv_rec.ATTRIBUTE7,
              l_inrv_rec.ATTRIBUTE8,
              l_inrv_rec.ATTRIBUTE9,
              l_inrv_rec.ATTRIBUTE10,
              l_inrv_rec.ATTRIBUTE11,
              l_inrv_rec.ATTRIBUTE12,
              l_inrv_rec.ATTRIBUTE13,
              l_inrv_rec.ATTRIBUTE14,
              l_inrv_rec.ATTRIBUTE15,
              l_inrv_rec.CREATED_BY,
              l_inrv_rec.CREATION_DATE,
              l_inrv_rec.LAST_UPDATED_BY,
              l_inrv_rec.LAST_UPDATE_DATE,
              l_inrv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_inrv_pk_csr%NOTFOUND;
    CLOSE okl_inrv_pk_csr;
    RETURN(l_inrv_rec);
  END get_rec;
  FUNCTION get_rec (
    p_inrv_rec                     IN inrv_rec_type
  ) RETURN inrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_inrv_rec, l_row_notfound));
  END get_rec;
  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INS_RATES_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_inrv_rec	IN inrv_rec_type
  ) RETURN inrv_rec_type IS
    l_inrv_rec	inrv_rec_type := p_inrv_rec;
  BEGIN
    IF (l_inrv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.object_version_number := NULL;
    END IF;
    IF (l_inrv_rec.ic_id = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.ic_id := NULL;
    END IF;
    IF (l_inrv_rec.ipt_id = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.ipt_id := NULL;
    END IF;
    IF (l_inrv_rec.iac_code = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.iac_code := NULL;
    END IF;
    IF (l_inrv_rec.coverage_max = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.coverage_max := NULL;
    END IF;
    IF (l_inrv_rec.deductible = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.deductible := NULL;
    END IF;
    IF (l_inrv_rec.factor_range_start = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.factor_range_start := NULL;
    END IF;
    IF (l_inrv_rec.insured_rate = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.insured_rate := NULL;
    END IF;
    IF (l_inrv_rec.factor_range_end = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.factor_range_end := NULL;
    END IF;
    IF (l_inrv_rec.date_from = Okc_Api.G_MISS_DATE) THEN
      l_inrv_rec.date_from := NULL;
    END IF;
    IF (l_inrv_rec.date_to = Okc_Api.G_MISS_DATE) THEN
      l_inrv_rec.date_to := NULL;
    END IF;
    IF (l_inrv_rec.insurer_rate = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.insurer_rate := NULL;
    END IF;
    IF (l_inrv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute_category := NULL;
    END IF;
    IF (l_inrv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute1 := NULL;
    END IF;
    IF (l_inrv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute2 := NULL;
    END IF;
    IF (l_inrv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute3 := NULL;
    END IF;
    IF (l_inrv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute4 := NULL;
    END IF;
    IF (l_inrv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute5 := NULL;
    END IF;
    IF (l_inrv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute6 := NULL;
    END IF;
    IF (l_inrv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute7 := NULL;
    END IF;
    IF (l_inrv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute8 := NULL;
    END IF;
    IF (l_inrv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute9 := NULL;
    END IF;
    IF (l_inrv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute10 := NULL;
    END IF;
    IF (l_inrv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute11 := NULL;
    END IF;
    IF (l_inrv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute12 := NULL;
    END IF;
    IF (l_inrv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute13 := NULL;
    END IF;
    IF (l_inrv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute14 := NULL;
    END IF;
    IF (l_inrv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_inrv_rec.attribute15 := NULL;
    END IF;
    IF (l_inrv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.created_by := NULL;
    END IF;
    IF (l_inrv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_inrv_rec.creation_date := NULL;
    END IF;
    IF (l_inrv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_inrv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_inrv_rec.last_update_date := NULL;
    END IF;
    IF (l_inrv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_inrv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_inrv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_id
-- Description		: check for null value
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE validate_inr_id(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       -- initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       -- data is required
       IF p_inrv_rec.id = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.id IS NULL
       THEN
         Okc_Api.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'ID');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
      EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
            Okc_Api.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM
                                );
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_id;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_objt_version_num
-- Description		:check for null value
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_obj_version_num(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.object_version_number IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'OBJECT VERSION NUMBER');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_obj_version_num;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_ic_id
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_ic_id(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     l_dummy_var                    VARCHAR2(1) := '?';
   -- select the ID  of the parent  record from the parent table
    CURSOR l_inrv_csr IS
       SELECT 'x'
       FROM OKX_COUNTRIES_V
       WHERE id1 = p_inrv_rec.ic_id;
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.ic_id = Okc_Api.G_MISS_CHAR OR
          p_inrv_rec.ic_id IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Country');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
         -- enforce foreign key
           OPEN l_inrv_csr;
	   FETCH l_inrv_csr INTO l_dummy_var;
           CLOSE l_inrv_csr;
         -- if l_dummy_var is still set to default ,data was not found
         IF (l_dummy_var ='?') THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'Country',
                               p_token2             => g_child_table_token , --3745151 Fix for invalid error messages
			       p_token2_value       =>   'OKL_INS_RATES',
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'OKX_COUNTRIES_V');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
      END IF;
      EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
            -- Verify  that cursor was closed
            IF l_inrv_csr%ISOPEN THEN
              CLOSE l_inrv_csr;
            END IF;
  END validate_inr_ic_id;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_ipt_id
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_ipt_id(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
    l_dummy_var                    VARCHAR2(1) :='?';
   -- select the ID  of the parent  record from the parent table
    CURSOR l_inrv_csr IS
       SELECT 'x'
       FROM OKL_INS_PRODUCTS_V
       WHERE id = p_inrv_rec.ipt_id;
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.ipt_id = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.ipt_id IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Product');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
      ELSE
         -- enforce foreign key
         OPEN l_inrv_csr;
	   FETCH l_inrv_csr INTO l_dummy_var;
         CLOSE l_inrv_csr;
         -- if l_dummy_var is still set to default ,data was not found
         IF (l_dummy_var ='?') THEN
           Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'Product',
                               p_token2             => g_child_table_token, --3745151 fix for invalid error messages
                               p_token2_value       => 'OKL_INS_RATES',
                               p_token3             => g_parent_table_token,
                               p_token3_value       => 'OKL_INS_PRODUCTS_V');
         --notify caller of an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
         END IF;
     END IF;
     EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
            -- Verify  that cursor was closed
            IF l_inrv_csr%ISOPEN THEN
              CLOSE l_inrv_csr;
            END IF;
  END validate_inr_ipt_id;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_iac_code
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_iac_code(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
    l_dummy_var                    VARCHAR2(1) :='?';
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.iac_code = Okc_Api.G_MISS_CHAR OR
          p_inrv_rec.iac_code IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Insurance Class');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        ELSE
     	   x_return_status  := Okl_Util.check_lookup_code('OKL_INSURANCE_ASSET_CLASS',p_inrv_rec.iac_code);
    		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
	   	                                  p_msg_name           => G_NO_PARENT_RECORD,
	   	                                  p_token1             => G_COL_NAME_TOKEN,
	   	                                  p_token1_value       => 'Insurance Class',
	   	                                  p_token2             => G_CHILD_TABLE_TOKEN,--3745151 Fix for invalid error messages
	   	                                  p_token2_value       => 'OKL_INS_RATES',
	   	                                  p_token3             => g_parent_table_token,
	   	                                  p_token3_value       => 'FND_LOOKUPS');
		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	END IF;
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_iac_code;
  /*
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_coverage_max
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_coverage_max(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.coverage_max = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.coverage_max IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Coverage');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_inrv_rec.coverage_max);
    		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
	   	                                  p_msg_name           => G_POSITIVE_NUMBER,
	   	                                  p_token1             => G_COL_NAME_TOKEN,
	   	                                  p_token1_value       => 'Coverage'
	   	                                  );
		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
         WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_coverage_max;
  Coverage Max is removed from screen
  */
  /*
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_deductible
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_deductible(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.deductible = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.deductible IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Deductible');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_inrv_rec.deductible);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
	   	                                  p_msg_name           => G_POSITIVE_NUMBER,
	   	                                  p_token1             => G_COL_NAME_TOKEN,
	   	                                  p_token1_value       => 'Deductible'
	   	                                  );
		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_deductible;
Deductible is removed from screen
*/
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_factor_range_start
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_factor_start(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.factor_range_start = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.factor_range_start IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Factor Min');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_inrv_rec.factor_range_start);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	   	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                                  p_msg_name           => G_POSITIVE_NUMBER,
		   	                                  p_token1             => G_COL_NAME_TOKEN,
		   	                                  p_token1_value       => 'Factor Min'
		   	                                  );
		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_factor_start;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_factor_range_end
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_factor_range_end(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.factor_range_end = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.factor_range_end IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Factor Max');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_inrv_rec.factor_range_end);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                                  p_msg_name           => G_POSITIVE_NUMBER,
		   	                                  p_token1             => G_COL_NAME_TOKEN,
		   	                                  p_token1_value       => 'Factor Max'
		   	                                  );
			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_factor_range_end;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_insurer_rate
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_insurer_rate(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.insurer_rate = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.insurer_rate IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Insurer Rate');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_inrv_rec.insurer_rate);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                                  p_msg_name           => G_POSITIVE_NUMBER,
		   	                                  p_token1             => G_COL_NAME_TOKEN,
		   	                                  p_token1_value       => 'Insurer Rate'
		   	                                  );
			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_insurer_rate;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_insured_rate
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_insured_rate(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.insured_rate = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.insured_rate IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => G_REQUIRED_VALUE,
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Lessee Rate');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_inrv_rec.insured_rate);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                                  p_msg_name           => G_POSITIVE_NUMBER,
		   	                                  p_token1             => G_COL_NAME_TOKEN,
		   	                                  p_token1_value       => 'Lessee Rate'
		   	                                  );
			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_insured_rate;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_date_from
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_date_from(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.date_from = Okc_Api.G_MISS_DATE OR
          p_inrv_rec.date_from IS NULL
       THEN
         Okc_Api.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Effective From');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_date_from;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_created_by
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_created_by(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.created_by = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.created_by IS NULL
       THEN
         Okc_Api.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Created By');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
         END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_created_by;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_creation_date
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_creation_date(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.creation_date = Okc_Api.G_MISS_DATE OR
          p_inrv_rec.creation_date IS NULL
       THEN
         Okc_Api.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Creation Date');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_creation_date;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_last_updated_by
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_last_updated_by(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
    BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.last_updated_by = Okc_Api.G_MISS_NUM OR
          p_inrv_rec.last_updated_by IS NULL
       THEN
         Okc_Api.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Last Updated By');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
      EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_last_updated_by;
---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_inr_last_update_date
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_inr_last_update_date(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_inrv_rec.last_update_date = Okc_Api.G_MISS_DATE OR
          p_inrv_rec.last_update_date IS NULL
       THEN
         Okc_Api.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Last Update Date');
         --Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
      EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_inr_last_update_date;
  ---------------------------------------------
  -- Validate_Attributes for:OKL_INS_RATES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_inrv_rec IN  inrv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
     -- call inr ID column-level validation
    validate_inr_id(x_return_status => l_return_status,
                    p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    -- call inr object version number column-level validation
    validate_inr_obj_version_num(x_return_status => l_return_status,
                                 p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    -- call inr ic_id column-level validation
    validate_inr_ic_id(x_return_status => l_return_status,
                        p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    -- call inr ipt_id column-level validation
    validate_inr_ipt_id(x_return_status => l_return_status,
                        p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
     -- call inr iac_code column_level validation
    validate_inr_iac_code(x_return_status => l_return_status,
                          p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
/*
     -- call inr coverage_max column_level validation
    validate_inr_coverage_max(x_return_status => l_return_status,
                              p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    Removed from screen
*/
 /*
 -- call inr deductible column_level validation
    validate_inr_deductible(x_return_status => l_return_status,
                              p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    Removed from screen and to be removed from database
*/
    -- call inr factor range start column_level validation
        validate_inr_factor_start(x_return_status => l_return_status,
                                  p_inrv_rec      => p_inrv_rec);
        -- store the highest degree of error
        IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
              IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
                x_return_status := l_return_status;   -- record that there was an error
              END IF;
    END IF;
    -- call inr factor range end column_level validation
    validate_inr_factor_range_end(x_return_status => l_return_status,
			      p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	    x_return_status := l_return_status;
	    RAISE G_EXCEPTION_HALT_VALIDATION;
	  ELSE
	    x_return_status := l_return_status;   -- record that there was an error
	  END IF;
    END IF;
    -- call inr insurer rate end column_level validation
    validate_inr_insurer_rate(x_return_status => l_return_status,
			      p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	    x_return_status := l_return_status;
	    RAISE G_EXCEPTION_HALT_VALIDATION;
	  ELSE
	    x_return_status := l_return_status;   -- record that there was an error
	  END IF;
    END IF;
    -- call inr insured rate end column_level validation
    validate_inr_insured_rate(x_return_status => l_return_status,
			      p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	    x_return_status := l_return_status;
	    RAISE G_EXCEPTION_HALT_VALIDATION;
	  ELSE
	    x_return_status := l_return_status;   -- record that there was an error
	  END IF;
    END IF;
    -- call inr date from end column_level validation
    validate_inr_date_from(x_return_status => l_return_status,
			      p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	  IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	    x_return_status := l_return_status;
	    RAISE G_EXCEPTION_HALT_VALIDATION;
	  ELSE
	    x_return_status := l_return_status;   -- record that there was an error
	  END IF;
    END IF;
    -- call inr created_by column_level validation
    validate_inr_created_by(x_return_status => l_return_status,
                            p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    -- call inr creation_date column_level validation
    validate_inr_creation_date(x_return_status => l_return_status,
                               p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    -- call inr last_updated_by column_level validation
    validate_inr_last_updated_by(x_return_status => l_return_status,
                                 p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    -- call inr last_update_date column_level validation
    validate_inr_last_update_date(x_return_status => l_return_status,
                                  p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;   -- record that there was an error
          END IF;
    END IF;
    RETURN(x_return_status);
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
          RETURN(x_return_status);
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_inr_factor_range
  -- Description	: It checks for Overlapping Range , Date need to be added
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_inr_factor_range(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
      l_dummy_var                    VARCHAR2(1) :='?';
   	G_INV_ORG_ID NUMBER ;
            CURSOR l_inrv_csr(G_INV_ORG_ID NUMBER) IS
                SELECT 'x' --Bug:3825159
		FROM OKL_INS_RATES INRV,
		     OKL_INS_PRODUCTS_B IPTB,
		     MTL_SYSTEM_ITEMS_B_KFV MSI
		WHERE IPTB.ID = INRV.IPT_ID
		AND   IPTB.IPD_ID = MSI.INVENTORY_ITEM_ID
		AND   ((INRV.FACTOR_RANGE_START <= p_inrv_rec.FACTOR_RANGE_START AND
	        INRV.FACTOR_RANGE_END   >=  p_inrv_rec.FACTOR_RANGE_START) OR
	       (INRV.FACTOR_RANGE_START <= p_inrv_rec.FACTOR_RANGE_END AND
	        INRV.FACTOR_RANGE_END   >=  p_inrv_rec.FACTOR_RANGE_END))
		AND   INRV.IC_ID = p_inrv_rec.IC_ID
		AND   INRV.IPT_ID = p_inrv_rec.IPT_ID
		AND   INRV.IAC_CODE = p_inrv_rec.IAC_CODE
		AND   INRV.ID <>  p_inrv_rec.ID
		And   MSI.ORGANIZATION_ID = G_INV_ORG_ID
		AND   DECODE(NVL(INRV.DATE_TO,NULL),NULL,'ACTIVE',DECODE(SIGN(MONTHS_BETWEEN(INRV.DATE_TO,SYSDATE)),1,'ACTIVE',0,'ACTIVE','INACTIVE')) ='ACTIVE'
                AND   INRV.DATE_FROM <=  p_inrv_rec.DATE_FROM  --Added for bug 4056611
                AND   NVL(INRV.DATE_TO,to_date('31-12-9999','dd-mm-rrrr')) >= p_inrv_rec.DATE_FROM; --Added for bug 4056611

       BEGIN
       G_INV_ORG_ID := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
                    -- enforce foreign key
           OPEN l_inrv_csr(G_INV_ORG_ID);
  	   FETCH l_inrv_csr INTO l_dummy_var;
           CLOSE l_inrv_csr;
           -- if l_dummy_var is still set to default ,data was not found
           IF (l_dummy_var <> '?' ) THEN
             Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
                                 p_msg_name           => 'OKL_FACTOR_RANGE'
                                 );
           --notify caller of an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           END IF;
       EXCEPTION
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
              Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UNEXPECTED_ERROR,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'IPT_ID');
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
              -- Verify  that cursor was closed
              IF l_inrv_csr%ISOPEN THEN
                CLOSE l_inrv_csr;
            END IF;
    END validate_inr_factor_range;
  ---
  ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_inr_factor_range_product
    -- Description	: It checks for Range checking for product
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       PROCEDURE  validate_inr_factor_product(x_return_status OUT NOCOPY VARCHAR2,p_inrv_rec IN inrv_rec_type ) IS
        l_dummy_var                    VARCHAR2(1) :='?';
        l_factor_min                    NUMBER;
        l_factor_max                    NUMBER;
        G_INV_ORG_ID NUMBER ;
       -- select the ID  of the parent  record from the parent table
        CURSOR l_inrv_csr(G_INV_ORG_ID NUMBER) IS
        SELECT 'x',IPTB.FACTOR_MIN,IPTB.FACTOR_MAX	 --Bug:3825159
	FROM OKL_INS_PRODUCTS_B IPTB,
	     MTL_SYSTEM_ITEMS_B_KFV MSI
	WHERE IPTB.IPD_ID = MSI.INVENTORY_ITEM_ID
	AND   IPTB.FACTOR_MAX     < p_inrv_rec.FACTOR_RANGE_END
	AND   IPTB.FACTOR_MIN     > p_inrv_rec.FACTOR_RANGE_START --  3745151 check for products minimum range.
	AND   IPTB.ID             = p_inrv_rec.IPT_ID
	AND   MSI.ORGANIZATION_ID = G_INV_ORG_ID;


        BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;
           G_INV_ORG_ID := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);
                      -- enforce foreign key
             OPEN l_inrv_csr(G_INV_ORG_ID );
    	   FETCH l_inrv_csr INTO l_dummy_var,l_factor_min,l_factor_max;
             CLOSE l_inrv_csr;
             -- if l_dummy_var is still set to default ,data was not found
             IF (l_dummy_var ='x') THEN
               Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
                                   p_msg_name           => 'OKL_IPT_RANGE_OVERLAPPING',
                                   p_token1         =>'MIN', --3745151 fix for invalid error messages start
                                   p_token1_value         => l_factor_min,
                                   p_token2         => 'MAX',
                                   p_token2_value         => l_factor_max --3745151 fix for invalid error messages end
                                   );
             --notify caller of an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
             END IF;
         EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_UNEXPECTED_ERROR,
                                p_token1       => g_sqlcode_token, -- fix for invalid error messages 3745151
                                p_token1_value => SQLCODE,
                                p_token2       => g_sqlerrm_token,
                                p_token2_value => SQLERRM); --End fix for invalid error messages 3745151
                -- Notify the caller of an unexpected error
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
                -- Verify  that cursor was closed
                IF l_inrv_csr%ISOPEN THEN
                  CLOSE l_inrv_csr;
              END IF;
      END validate_inr_factor_product;
    ---
  FUNCTION compare_number(p_start_number IN NUMBER,p_end_number IN NUMBER  )
     RETURN VARCHAR2 IS
       x_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         IF p_start_number IS NOT NULL AND
            p_end_number IS NOT NULL THEN
             IF p_end_number < p_start_number THEN
                x_return_status :=Okc_Api.G_RET_STS_ERROR;
             END IF;
         END IF;
         RETURN (x_return_status);
        EXCEPTION
           WHEN OTHERS THEN
            Okc_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => g_unexpected_error,
                                p_token1       => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2       => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
           RETURN(x_return_status);
 END compare_number;
  -----------------------------------------
  -- Validate_Record for:OKL_INS_RATES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_inrv_rec IN inrv_rec_type
  ) RETURN VARCHAR2 IS
      x_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call inr factor Range column_level validation
    l_return_status := okl_util.check_from_to_number_range(p_from_number =>p_inrv_rec.factor_range_start ,
                                  p_to_number =>p_inrv_rec.factor_range_end );
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
      Okc_Api.set_message(
                              p_app_name     => g_app_name,
			      p_msg_name     => 'OKL_GREATER_THAN',
			      p_token1       => 'COL_NAME1',
			      p_token1_value => 'Factor Maximum',
			      p_token2       => 'COL_NAME2',
			      p_token2_value => 'Factor Minimum'
			);
      IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status :=l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
        -- call inr Factor Range overlapping column_level validation
    validate_inr_factor_range(x_return_status => l_return_status,
                                  p_inrv_rec      => p_inrv_rec);
    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
      IF(x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status :=l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    -- call inr Factor Range for product validation
    validate_inr_factor_product(x_return_status => l_return_status,
				     p_inrv_rec      => p_inrv_rec);
	-- store the highest degree of error
	IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	 IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	    x_return_status :=l_return_status;
	    RAISE G_EXCEPTION_HALT_VALIDATION;
	 ELSE
	    x_return_status := l_return_status;   -- record that there was an error
	 END IF;
	END IF;
    -- call inr lessee and insurer Range column_level validation
        l_return_status := compare_number(p_start_number =>p_inrv_rec.INSURER_RATE ,
                                      p_end_number =>p_inrv_rec.INSURED_RATE );
        -- store the highest degree of error
        IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        	Okc_Api.set_message(
	                              p_app_name     => g_app_name,
				      p_msg_name     => 'OKL_GREATER_THAN',
				      p_token1       => 'COL_NAME1',
				      p_token1_value => 'Lessee Rate',
				      p_token2       => 'COL_NAME2',
				      p_token2_value => 'Insurer Rate'
					);
          IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status :=l_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             x_return_status := l_return_status;   -- record that there was an error
          END IF;
        END IF;
   -- For Date Range
   l_return_status :=  Okl_Util.check_from_to_date_range(p_inrv_rec.date_from , p_inrv_rec.date_to);
	    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                    Okc_Api.set_message(
		    	                              p_app_name     => g_app_name,
		    				      p_msg_name     => 'OKL_GREATER_THAN',
		    				      p_token1       => 'COL_NAME1',
		    				      p_token1_value => 'Effective To',
		    				      p_token2       => 'COL_NAME2',
		    				      p_token2_value => 'Effective From'
						);
      IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status :=l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
   -- For Date Range
 IF( p_inrv_rec.date_to = NULL OR  p_inrv_rec.date_to = OKC_API.G_MISS_DATE ) THEN
    NULL;
 ELSE
   l_return_status :=  Okl_Util.check_from_to_date_range(Trunc(sysdate), p_inrv_rec.date_to );--Fix for Bug 3924176
	    -- store the highest degree of error
    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                    Okc_Api.set_message(
		    	      		  		p_app_name     =>  g_app_name,
		    	      		  		p_msg_name     => 'OKL_INVALID_DATE_RANGE',
		    	      		  		p_token1       => 'COL_NAME1',
		    	      		  		p_token1_value => 'Effective To Date');

      IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status :=l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    END IF;
    RETURN (x_return_status);
   EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       RETURN(x_return_status);
     WHEN OTHERS THEN
       Okc_Api.set_message(p_app_name     => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => SQLCODE,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => SQLERRM);
     l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    RETURN (l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN inrv_rec_type,
    p_to	IN OUT NOCOPY inr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.iac_code := p_from.iac_code;
    p_to.ipt_id := p_from.ipt_id;
    p_to.ic_id := p_from.ic_id;
    p_to.coverage_max := p_from.coverage_max;
    p_to.deductible := p_from.deductible;
    p_to.object_version_number := p_from.object_version_number;
    p_to.factor_range_start := p_from.factor_range_start;
    p_to.insured_rate := p_from.insured_rate;
    p_to.factor_range_end := p_from.factor_range_end;
    p_to.date_from := p_from.date_from;
    p_to.date_to := p_from.date_to;
    p_to.insurer_rate := p_from.insurer_rate;
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
    p_from	IN inr_rec_type,
    p_to	IN OUT NOCOPY inrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.iac_code := p_from.iac_code;
    p_to.ipt_id := p_from.ipt_id;
    p_to.ic_id := p_from.ic_id;
    p_to.coverage_max := p_from.coverage_max;
    p_to.deductible := p_from.deductible;
    p_to.object_version_number := p_from.object_version_number;
    p_to.factor_range_start := p_from.factor_range_start;
    p_to.insured_rate := p_from.insured_rate;
    p_to.factor_range_end := p_from.factor_range_end;
    p_to.date_from := p_from.date_from;
    p_to.date_to := p_from.date_to;
    p_to.insurer_rate := p_from.insurer_rate;
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
  --------------------------------------
  -- validate_row for:OKL_INS_RATES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_rec                     IN inrv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inrv_rec                     inrv_rec_type := p_inrv_rec;
    l_inr_rec                      inr_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    -- l_return_status := Validate_Attributes(l_inrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
     l_return_status := Validate_Record(l_inrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:INRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_tbl                     IN inrv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inrv_tbl.COUNT > 0) THEN
      i := p_inrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_inrv_rec                     => p_inrv_tbl(i));
        EXIT WHEN (i = p_inrv_tbl.LAST);
        i := p_inrv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ----------------------------------
  -- insert_row for:OKL_INS_RATES --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inr_rec                      IN inr_rec_type,
    x_inr_rec                      OUT NOCOPY inr_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RATES_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inr_rec                      inr_rec_type := p_inr_rec;
    l_def_inr_rec                  inr_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKL_INS_RATES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_inr_rec IN  inr_rec_type,
      x_inr_rec OUT NOCOPY inr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_inr_rec := p_inr_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_inr_rec,                         -- IN
      l_inr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INS_RATES(
        id,
        iac_code,
        ipt_id,
        ic_id,
        coverage_max,
        deductible,
        object_version_number,
        factor_range_start,
        insured_rate,
        factor_range_end,
        date_from,
        date_to,
        insurer_rate,
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
        l_inr_rec.id,
        l_inr_rec.iac_code,
        l_inr_rec.ipt_id,
        l_inr_rec.ic_id,
        l_inr_rec.coverage_max,
        l_inr_rec.deductible,
        l_inr_rec.object_version_number,
        l_inr_rec.factor_range_start,
        l_inr_rec.insured_rate,
        l_inr_rec.factor_range_end,
        l_inr_rec.date_from,
        l_inr_rec.date_to,
        l_inr_rec.insurer_rate,
        l_inr_rec.attribute_category,
        l_inr_rec.attribute1,
        l_inr_rec.attribute2,
        l_inr_rec.attribute3,
        l_inr_rec.attribute4,
        l_inr_rec.attribute5,
        l_inr_rec.attribute6,
        l_inr_rec.attribute7,
        l_inr_rec.attribute8,
        l_inr_rec.attribute9,
        l_inr_rec.attribute10,
        l_inr_rec.attribute11,
        l_inr_rec.attribute12,
        l_inr_rec.attribute13,
        l_inr_rec.attribute14,
        l_inr_rec.attribute15,
        l_inr_rec.created_by,
        l_inr_rec.creation_date,
        l_inr_rec.last_updated_by,
        l_inr_rec.last_update_date,
        l_inr_rec.last_update_login);
    -- Set OUT values
    x_inr_rec := l_inr_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------
  -- insert_row for:OKL_INS_RATES_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_rec                     IN inrv_rec_type,
    x_inrv_rec                     OUT NOCOPY inrv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inrv_rec                     inrv_rec_type;
    l_def_inrv_rec                 inrv_rec_type;
    l_inr_rec                      inr_rec_type;
    lx_inr_rec                     inr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_inrv_rec	IN inrv_rec_type
    ) RETURN inrv_rec_type IS
      l_inrv_rec	inrv_rec_type := p_inrv_rec;
    BEGIN
      l_inrv_rec.CREATION_DATE := SYSDATE;
      l_inrv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_inrv_rec.LAST_UPDATE_DATE := l_inrv_rec.CREATION_DATE;
      l_inrv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_inrv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_inrv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_INS_RATES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_inrv_rec IN  inrv_rec_type,
      x_inrv_rec OUT NOCOPY inrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_inrv_rec := p_inrv_rec;
      x_inrv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_inrv_rec := null_out_defaults(p_inrv_rec);
    -- Set primary key value
    l_inrv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_inrv_rec,                        -- IN
      l_def_inrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_inrv_rec := fill_who_columns(l_def_inrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
     l_return_status := Validate_Attributes(l_def_inrv_rec);
    -- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
     l_return_status := Validate_Record(l_def_inrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_inrv_rec, l_inr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inr_rec,
      lx_inr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_inr_rec, l_def_inrv_rec);
    -- Set OUT values
    x_inrv_rec := l_def_inrv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
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
  -- PL/SQL TBL insert_row for:INRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_tbl                     IN inrv_tbl_type,
    x_inrv_tbl                     OUT NOCOPY inrv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inrv_tbl.COUNT > 0) THEN
      i := p_inrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_inrv_rec                     => p_inrv_tbl(i),
          x_inrv_rec                     => x_inrv_tbl(i));
        EXIT WHEN (i = p_inrv_tbl.LAST);
        i := p_inrv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------
  -- lock_row for:OKL_INS_RATES --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inr_rec                      IN inr_rec_type) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_inr_rec IN inr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_RATES
     WHERE ID = p_inr_rec.id
       AND OBJECT_VERSION_NUMBER = p_inr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
    CURSOR  lchk_csr (p_inr_rec IN inr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_RATES
    WHERE ID = p_inr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RATES_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INS_RATES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INS_RATES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_inr_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;
    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_inr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_inr_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_inr_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------
  -- lock_row for:OKL_INS_RATES_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_rec                     IN inrv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inr_rec                      inr_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_inrv_rec, l_inr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:INRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_tbl                     IN inrv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inrv_tbl.COUNT > 0) THEN
      i := p_inrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_inrv_rec                     => p_inrv_tbl(i));
        EXIT WHEN (i = p_inrv_tbl.LAST);
        i := p_inrv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ----------------------------------
  -- update_row for:OKL_INS_RATES --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inr_rec                      IN inr_rec_type,
    x_inr_rec                      OUT NOCOPY inr_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RATES_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inr_rec                      inr_rec_type := p_inr_rec;
    l_def_inr_rec                  inr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_inr_rec	IN inr_rec_type,
      x_inr_rec	OUT NOCOPY inr_rec_type
    ) RETURN VARCHAR2 IS
      l_inr_rec                      inr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_inr_rec := p_inr_rec;
      -- Get current database values
      l_inr_rec := get_rec(p_inr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_inr_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.id := l_inr_rec.id;
      END IF;
      IF (x_inr_rec.iac_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.iac_code := l_inr_rec.iac_code;
      END IF;
      IF (x_inr_rec.ipt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.ipt_id := l_inr_rec.ipt_id;
      END IF;
      IF (x_inr_rec.ic_id = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.ic_id := l_inr_rec.ic_id;
      END IF;
      IF (x_inr_rec.coverage_max = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.coverage_max := l_inr_rec.coverage_max;
      END IF;
      IF (x_inr_rec.deductible = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.deductible := l_inr_rec.deductible;
      END IF;
      IF (x_inr_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.object_version_number := l_inr_rec.object_version_number;
      END IF;
      IF (x_inr_rec.factor_range_start = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.factor_range_start := l_inr_rec.factor_range_start;
      END IF;
      IF (x_inr_rec.insured_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.insured_rate := l_inr_rec.insured_rate;
      END IF;
      IF (x_inr_rec.factor_range_end = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.factor_range_end := l_inr_rec.factor_range_end;
      END IF;
      IF (x_inr_rec.date_from = Okc_Api.G_MISS_DATE)
      THEN
        x_inr_rec.date_from := l_inr_rec.date_from;
      END IF;
      IF (x_inr_rec.date_to = Okc_Api.G_MISS_DATE)
      THEN
        x_inr_rec.date_to := l_inr_rec.date_to;
      END IF;
      IF (x_inr_rec.insurer_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.insurer_rate := l_inr_rec.insurer_rate;
      END IF;
      IF (x_inr_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute_category := l_inr_rec.attribute_category;
      END IF;
      IF (x_inr_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute1 := l_inr_rec.attribute1;
      END IF;
      IF (x_inr_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute2 := l_inr_rec.attribute2;
      END IF;
      IF (x_inr_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute3 := l_inr_rec.attribute3;
      END IF;
      IF (x_inr_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute4 := l_inr_rec.attribute4;
      END IF;
      IF (x_inr_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute5 := l_inr_rec.attribute5;
      END IF;
      IF (x_inr_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute6 := l_inr_rec.attribute6;
      END IF;
      IF (x_inr_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute7 := l_inr_rec.attribute7;
      END IF;
      IF (x_inr_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute8 := l_inr_rec.attribute8;
      END IF;
      IF (x_inr_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute9 := l_inr_rec.attribute9;
      END IF;
      IF (x_inr_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute10 := l_inr_rec.attribute10;
      END IF;
      IF (x_inr_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute11 := l_inr_rec.attribute11;
      END IF;
      IF (x_inr_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute12 := l_inr_rec.attribute12;
      END IF;
      IF (x_inr_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute13 := l_inr_rec.attribute13;
      END IF;
      IF (x_inr_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute14 := l_inr_rec.attribute14;
      END IF;
      IF (x_inr_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inr_rec.attribute15 := l_inr_rec.attribute15;
      END IF;
      IF (x_inr_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.created_by := l_inr_rec.created_by;
      END IF;
      IF (x_inr_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_inr_rec.creation_date := l_inr_rec.creation_date;
      END IF;
      IF (x_inr_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.last_updated_by := l_inr_rec.last_updated_by;
      END IF;
      IF (x_inr_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_inr_rec.last_update_date := l_inr_rec.last_update_date;
      END IF;
      IF (x_inr_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_inr_rec.last_update_login := l_inr_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_INS_RATES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_inr_rec IN  inr_rec_type,
      x_inr_rec OUT NOCOPY inr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_inr_rec := p_inr_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_inr_rec,                         -- IN
      l_inr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_inr_rec, l_def_inr_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INS_RATES
    SET IAC_CODE = l_def_inr_rec.iac_code,
        IPT_ID = l_def_inr_rec.ipt_id,
        IC_ID = l_def_inr_rec.ic_id,
        COVERAGE_MAX = l_def_inr_rec.coverage_max,
        DEDUCTIBLE = l_def_inr_rec.deductible,
        OBJECT_VERSION_NUMBER = l_def_inr_rec.object_version_number,
        FACTOR_RANGE_START = l_def_inr_rec.factor_range_start,
        INSURED_RATE = l_def_inr_rec.insured_rate,
        FACTOR_RANGE_END = l_def_inr_rec.factor_range_end,
        DATE_FROM = l_def_inr_rec.date_from,
        DATE_TO = l_def_inr_rec.date_to,
        INSURER_RATE = l_def_inr_rec.insurer_rate,
        ATTRIBUTE_CATEGORY = l_def_inr_rec.attribute_category,
        ATTRIBUTE1 = l_def_inr_rec.attribute1,
        ATTRIBUTE2 = l_def_inr_rec.attribute2,
        ATTRIBUTE3 = l_def_inr_rec.attribute3,
        ATTRIBUTE4 = l_def_inr_rec.attribute4,
        ATTRIBUTE5 = l_def_inr_rec.attribute5,
        ATTRIBUTE6 = l_def_inr_rec.attribute6,
        ATTRIBUTE7 = l_def_inr_rec.attribute7,
        ATTRIBUTE8 = l_def_inr_rec.attribute8,
        ATTRIBUTE9 = l_def_inr_rec.attribute9,
        ATTRIBUTE10 = l_def_inr_rec.attribute10,
        ATTRIBUTE11 = l_def_inr_rec.attribute11,
        ATTRIBUTE12 = l_def_inr_rec.attribute12,
        ATTRIBUTE13 = l_def_inr_rec.attribute13,
        ATTRIBUTE14 = l_def_inr_rec.attribute14,
        ATTRIBUTE15 = l_def_inr_rec.attribute15,
        CREATED_BY = l_def_inr_rec.created_by,
        CREATION_DATE = l_def_inr_rec.creation_date,
        LAST_UPDATED_BY = l_def_inr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_inr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_inr_rec.last_update_login
    WHERE ID = l_def_inr_rec.id;
    x_inr_rec := l_def_inr_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------
  -- update_row for:OKL_INS_RATES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_rec                     IN inrv_rec_type,
    x_inrv_rec                     OUT NOCOPY inrv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inrv_rec                     inrv_rec_type := p_inrv_rec;
    l_def_inrv_rec                 inrv_rec_type;
    l_inr_rec                      inr_rec_type;
    lx_inr_rec                     inr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_inrv_rec	IN inrv_rec_type
    ) RETURN inrv_rec_type IS
      l_inrv_rec	inrv_rec_type := p_inrv_rec;
    BEGIN
      l_inrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_inrv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_inrv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_inrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_inrv_rec	IN inrv_rec_type,
      x_inrv_rec	OUT NOCOPY inrv_rec_type
    ) RETURN VARCHAR2 IS
      l_inrv_rec                     inrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_inrv_rec := p_inrv_rec;
      -- Get current database values
      l_inrv_rec := get_rec(p_inrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_inrv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.id := l_inrv_rec.id;
      END IF;
      IF (x_inrv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.object_version_number := l_inrv_rec.object_version_number;
      END IF;
      IF (x_inrv_rec.ic_id = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.ic_id := l_inrv_rec.ic_id;
      END IF;
      IF (x_inrv_rec.ipt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.ipt_id := l_inrv_rec.ipt_id;
      END IF;
      IF (x_inrv_rec.iac_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.iac_code := l_inrv_rec.iac_code;
      END IF;
      IF (x_inrv_rec.coverage_max = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.coverage_max := l_inrv_rec.coverage_max;
      END IF;
      IF (x_inrv_rec.deductible = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.deductible := l_inrv_rec.deductible;
      END IF;
      IF (x_inrv_rec.factor_range_start = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.factor_range_start := l_inrv_rec.factor_range_start;
      END IF;
      IF (x_inrv_rec.insured_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.insured_rate := l_inrv_rec.insured_rate;
      END IF;
      IF (x_inrv_rec.factor_range_end = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.factor_range_end := l_inrv_rec.factor_range_end;
      END IF;
      IF (x_inrv_rec.date_from = Okc_Api.G_MISS_DATE)
      THEN
        x_inrv_rec.date_from := l_inrv_rec.date_from;
      END IF;
      IF (x_inrv_rec.date_to = Okc_Api.G_MISS_DATE)
      THEN
        x_inrv_rec.date_to := l_inrv_rec.date_to;
      END IF;
      IF (x_inrv_rec.insurer_rate = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.insurer_rate := l_inrv_rec.insurer_rate;
      END IF;
      IF (x_inrv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute_category := l_inrv_rec.attribute_category;
      END IF;
      IF (x_inrv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute1 := l_inrv_rec.attribute1;
      END IF;
      IF (x_inrv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute2 := l_inrv_rec.attribute2;
      END IF;
      IF (x_inrv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute3 := l_inrv_rec.attribute3;
      END IF;
      IF (x_inrv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute4 := l_inrv_rec.attribute4;
      END IF;
      IF (x_inrv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute5 := l_inrv_rec.attribute5;
      END IF;
      IF (x_inrv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute6 := l_inrv_rec.attribute6;
      END IF;
      IF (x_inrv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute7 := l_inrv_rec.attribute7;
      END IF;
      IF (x_inrv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute8 := l_inrv_rec.attribute8;
      END IF;
      IF (x_inrv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute9 := l_inrv_rec.attribute9;
      END IF;
      IF (x_inrv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute10 := l_inrv_rec.attribute10;
      END IF;
      IF (x_inrv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute11 := l_inrv_rec.attribute11;
      END IF;
      IF (x_inrv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute12 := l_inrv_rec.attribute12;
      END IF;
      IF (x_inrv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute13 := l_inrv_rec.attribute13;
      END IF;
      IF (x_inrv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute14 := l_inrv_rec.attribute14;
      END IF;
      IF (x_inrv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_inrv_rec.attribute15 := l_inrv_rec.attribute15;
      END IF;
      IF (x_inrv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.created_by := l_inrv_rec.created_by;
      END IF;
      IF (x_inrv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_inrv_rec.creation_date := l_inrv_rec.creation_date;
      END IF;
      IF (x_inrv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.last_updated_by := l_inrv_rec.last_updated_by;
      END IF;
      IF (x_inrv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_inrv_rec.last_update_date := l_inrv_rec.last_update_date;
      END IF;
      IF (x_inrv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_inrv_rec.last_update_login := l_inrv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_INS_RATES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_inrv_rec IN  inrv_rec_type,
      x_inrv_rec OUT NOCOPY inrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_inrv_rec := p_inrv_rec;
      x_inrv_rec.OBJECT_VERSION_NUMBER := NVL(x_inrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_inrv_rec,                        -- IN
      l_inrv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_inrv_rec, l_def_inrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_inrv_rec := fill_who_columns(l_def_inrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
     l_return_status := Validate_Attributes(l_def_inrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_inrv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_inrv_rec, l_inr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inr_rec,
      lx_inr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_inr_rec, l_def_inrv_rec);
    x_inrv_rec := l_def_inrv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
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
  -- PL/SQL TBL update_row for:INRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_tbl                     IN inrv_tbl_type,
    x_inrv_tbl                     OUT NOCOPY inrv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inrv_tbl.COUNT > 0) THEN
      i := p_inrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_inrv_rec                     => p_inrv_tbl(i),
          x_inrv_rec                     => x_inrv_tbl(i));
        EXIT WHEN (i = p_inrv_tbl.LAST);
        i := p_inrv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ----------------------------------
  -- delete_row for:OKL_INS_RATES --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inr_rec                      IN inr_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RATES_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inr_rec                      inr_rec_type:= p_inr_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INS_RATES
     WHERE ID = l_inr_rec.id;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------
  -- delete_row for:OKL_INS_RATES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_rec                     IN inrv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_inrv_rec                     inrv_rec_type := p_inrv_rec;
    l_inr_rec                      inr_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_inrv_rec, l_inr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_inr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:INRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inrv_tbl                     IN inrv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inrv_tbl.COUNT > 0) THEN
      i := p_inrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_inrv_rec                     => p_inrv_tbl(i));
        EXIT WHEN (i = p_inrv_tbl.LAST);
        i := p_inrv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okc_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Inr_Pvt;

/

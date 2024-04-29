--------------------------------------------------------
--  DDL for Package Body OKL_VP_ASSOCIATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_ASSOCIATIONS_PVT" AS
/* $Header: OKLRVASB.pls 120.12 2006/07/11 10:07:18 dkagrawa noship $ */

  G_LA_ASSOC_DATE_MISMATCH CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_LA_ASSOC_DATES_MSMTCH';
  G_LC_ASSOC_DATE_MISMATCH CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_LC_ASSOC_DATES_MSMTCH';
  G_ET_ASSOC_DATE_MISMATCH CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_ET_ASSOC_DATES_MSMTCH';
  G_FP_ASSOC_DATE_MISMATCH CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_FP_ASSOC_DATES_MSMTCH';
  G_IT_ASSOC_DATE_MISMATCH CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_IT_ASSOC_DATES_MSMTCH';
  G_IC_ASSOC_DATE_MISMATCH CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_IC_ASSOC_DATES_MSMTCH';
  G_AGRMNT_MSG_TOKEN CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'AGRMNT';

  --------------------------------------------------------
  -- Validations for the associations
  --------------------------------------------------------
  PROCEDURE validate_uniqueness(
    x_return_status                OUT NOCOPY VARCHAR2
   ,p_vasv_rec                     IN vasv_rec_type
  )IS

    -- cursor to check uniqueness for lease contract templates
    CURSOR c_is_uniq_csr IS
    SELECT chr.contract_number
      FROM okl_vp_associations assoc
          ,okc_k_headers_b chr
     WHERE assoc.chr_id = p_vasv_rec.chr_id
       AND assoc.assoc_object_id = chr.id
       AND chr.scs_code = 'LEASE'
       AND assoc.assoc_object_id = p_vasv_rec.assoc_object_id
       AND assoc.assoc_object_type_code = p_vasv_rec.assoc_object_type_code
       AND (assoc.id <> p_vasv_rec.id OR p_vasv_rec.id = OKL_API.G_MISS_NUM or p_vasv_rec.id IS NULL)
       AND (
             (trunc(p_vasv_rec.start_date) BETWEEN trunc(assoc.start_date) AND trunc(nvl(assoc.end_date,okl_api.g_miss_date))) OR
             (trunc(assoc.start_date) BETWEEN trunc(p_vasv_rec.start_date) AND trunc(nvl(p_vasv_rec.end_date,okl_api.g_miss_date)))
           );
    lv_contract_number okc_k_headers_b.contract_number%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF(p_vasv_rec.assoc_object_type_code = 'LC_TEMPLATE')THEN
      OPEN c_is_uniq_csr;
      LOOP
        FETCH c_is_uniq_csr INTO lv_contract_number;
        EXIT WHEN (c_is_uniq_csr%NOTFOUND OR lv_contract_number IS NOT NULL);
      END LOOP;
      CLOSE c_is_uniq_csr;
      IF(lv_contract_number IS NOT NULL)THEN
        okl_api.set_message(p_app_name => OKL_API.G_APP_NAME
                           ,p_msg_name => 'OKL_VN_DUPLICATE_LCT'
                           ,p_token1  => 'CONTRACT_TEMPLATE'
                           ,p_token1_value => lv_contract_number
                            );
        x_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END validate_uniqueness;

  PROCEDURE validate_vp_associations_dates (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vasv_rec                     IN vasv_rec_type
    ) IS
    l_api_name        	VARCHAR2(30) := 'VALIDATE_VP_ASSOCIATIONS_DATES';
    l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

   CURSOR lc_dates_csr (p_object_id IN NUMBER) IS
   SELECT start_date, end_date
   FROM okc_k_headers_b
   WHERE id = p_object_id
   AND scs_code = 'LEASE'
   AND template_yn= 'Y';

   l_start_date DATE;
   l_end_date   DATE;
   l_pa_end_date DATE;


   -- abindal start --
   --lease application template --
   CURSOR la_dates_csr (p_object_id IN NUMBER, p_version_number IN NUMBER) IS
   SELECT valid_from,
          valid_to
   FROM okl_leaseapp_templ_versions_v
   WHERE leaseapp_template_id = p_object_id
   AND version_status = 'ACTIVE'
   AND version_number = p_version_number;
   -- abindal end --

   l_parent_object_id NUMBER;

   CURSOR get_creq_type_csr(cp_crs_id okl_vp_change_requests.id%TYPE)IS
   SELECT change_type_code
         ,chr_id
     FROM okl_vp_change_requests
    WHERE id = cp_crs_id;
   cv_get_creq_type get_creq_type_csr%ROWTYPE;

   CURSOR c_get_khr_id (cp_crs_id okl_vp_change_requests.id%TYPE)IS
   SELECT id
     FROM okl_k_headers
    WHERE crs_id = cp_crs_id;

   CURSOR c_get_parent_dt_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
   SELECT start_date
         ,end_date
         ,contract_number
     FROM okc_k_headers_b
    WHERE id = cp_chr_id;

   lv_parent_start_date okc_k_headers_b.start_date%TYPE;
   lv_parent_end_date okc_k_headers_b.end_date%TYPE;
   lv_contract_number okc_k_headers_b.contract_number%TYPE;
   lv_message_name fnd_new_messages.message_name%TYPE;

 BEGIN
   x_return_status := l_return_status;

   -- first determine the parent object id
   IF(p_vasv_rec.chr_id IS NOT NULL AND p_vasv_rec.chr_id <> OKL_API.G_MISS_NUM)THEN
     l_parent_object_id := p_vasv_rec.chr_id;
   ELSIF(p_vasv_rec.crs_id IS NOT NULL AND p_vasv_rec.crs_id <> OKL_API.G_MISS_NUM)THEN
     -- this implies that crs_id is provided, which means we are validating against an
     -- association type of change request. determine the chr_id from this crs_id
     OPEN get_creq_type_csr(p_vasv_rec.crs_id); FETCH get_creq_type_csr INTO cv_get_creq_type;
     CLOSE get_creq_type_csr;
     IF('AGREEMENT' =  cv_get_creq_type.change_type_code)THEN
        OPEN c_get_khr_id(p_vasv_rec.crs_id); FETCH c_get_khr_id INTO l_parent_object_id;
        CLOSE c_get_khr_id;
     ELSE
       -- association type of change request
       l_parent_object_id := cv_get_creq_type.chr_id;
     END IF;
   END IF;

   -- validate if the object effective dates are within the agreement effective dates
   IF(l_parent_object_id IS NOT NULL)THEN
     OPEN c_get_parent_dt_csr(l_parent_object_id);
     FETCH c_get_parent_dt_csr INTO lv_parent_start_date,lv_parent_end_date,lv_contract_number;
     CLOSE c_get_parent_dt_csr;
     IF((TRUNC(p_vasv_rec.start_date) < TRUNC(lv_parent_start_date))
        OR(TRUNC(NVL(p_vasv_rec.end_date, okl_accounting_util.g_final_date)) > TRUNC(NVL(lv_parent_end_date,okl_accounting_util.g_final_date)))
        )THEN
       IF(p_vasv_rec.assoc_object_type_code = 'LC_TEMPLATE')THEN
         lv_message_name := G_LC_ASSOC_DATE_MISMATCH;
       ELSIF(p_vasv_rec.assoc_object_type_code = 'LA_TEMPLATE')THEN
         lv_message_name := G_LA_ASSOC_DATE_MISMATCH;
       ELSIF(p_vasv_rec.assoc_object_type_code = 'LA_EOT_VALUES')THEN
         lv_message_name := G_ET_ASSOC_DATE_MISMATCH;
       ELSIF(p_vasv_rec.assoc_object_type_code = 'LA_FINANCIAL_PRODUCT')THEN
         lv_message_name := G_FP_ASSOC_DATE_MISMATCH;
       ELSIF(p_vasv_rec.assoc_object_type_code = 'LA_ITEMS')THEN
         lv_message_name := G_IT_ASSOC_DATE_MISMATCH;
       ELSIF(p_vasv_rec.assoc_object_type_code = 'LA_ITEM_CATEGORIES')THEN
         lv_message_name := G_IC_ASSOC_DATE_MISMATCH;
       END IF;
        OKL_API.SET_MESSAGE(p_app_name => OKL_API.G_APP_NAME, p_msg_name => lv_message_name);
	       x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
   END IF;

   -- Validate association dates --
   IF (p_vasv_rec.assoc_object_type_code = 'LC_TEMPLATE' ) THEN
     -- abindal Changed chr_id to assoc_object_id --
     -- OPEN lc_dates_csr (p_vasv_rec.chr_id);
 	   OPEN lc_dates_csr (p_vasv_rec.assoc_object_id);
     FETCH lc_dates_csr INTO l_start_date, l_end_date;
     CLOSE lc_dates_csr;

 	   l_pa_end_date := NVL(p_vasv_rec.end_date, l_end_date);

 	   IF (p_vasv_rec.start_date < l_start_date OR p_vasv_rec.start_date > l_end_date) OR
        (l_pa_end_date < l_start_date OR l_pa_end_date > l_end_date) THEN
        OKL_API.SET_MESSAGE(p_app_name => OKL_API.G_APP_NAME,
                            p_msg_name => 'OKL_VP_ASSOC_INV_DATES'
                           );
	       x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
   END IF;

   -- abindal start --
	  IF (p_vasv_rec.assoc_object_type_code = 'LA_TEMPLATE' ) THEN
	    OPEN la_dates_csr (p_vasv_rec.assoc_object_id, p_vasv_rec.assoc_object_version);
	    FETCH la_dates_csr INTO l_start_date, l_end_date;
	    CLOSE la_dates_csr;

 	   l_pa_end_date := NVL(p_vasv_rec.end_date, l_end_date);

	    IF (p_vasv_rec.start_date < l_start_date OR p_vasv_rec.start_date > l_end_date) OR
	       (l_pa_end_date < l_start_date OR l_pa_end_date > l_end_date) THEN
         OKL_API.SET_MESSAGE(p_app_name => OKL_API.G_APP_NAME,
                             p_msg_name => 'OKL_VP_ASSOC_INV_DATES'
                            );
		       x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
	    END IF;
	  END IF;
   -- abindal end --

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_vp_associations_dates;

  PROCEDURE validate_object_version (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vasv_rec                     IN vasv_rec_type
    ) IS
	l_api_name        	VARCHAR2(30) := 'VALIDATE_OBJECT_VERSION';
    l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
     x_return_status := l_return_status;

	 -- Validate object version for lease applicaiton--

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => OKL_API.G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version;

  PROCEDURE create_vp_associations(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vasv_rec                     IN vasv_rec_type,
    x_vasv_rec                     OUT NOCOPY vasv_rec_type
 ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_exist VARCHAR2(1);
     -- abindal start --
     l_dummy             VARCHAR2(1);
     -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
     -- l_application_type  OKL_LEASEAPP_TEMPLATES_V.APPLICATION_TYPE%TYPE;
     l_credit_class	     OKL_LEASEAPP_TMPLS.CUST_CREDIT_CLASSIFICATION%TYPE;
     l_credit_purpose    OKL_LEASEAPP_TMPLS.CREDIT_REVIEW_PURPOSE%TYPE;
     -- l_sic_code          OKL_LEASEAPP_TEMPLATES_V.APPLICATION_TYPE%TYPE;
     l_sic_code          OKL_LEASEAPP_TMPLS.INDUSTRY_CODE%TYPE;
     l_agrmnt_name       OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
     /* Manu 31-Aug-2005 Remove REFERENCE_NUMBER column */
     -- l_appl_temp_name    OKL_LEASEAPP_TEMPLATES_V.REFERENCE_NUMBER%TYPE;
     l_appl_temp_name    OKL_LEASEAPP_TMPLS.NAME%TYPE;
     lv_change_type_code okl_vp_change_requests.change_type_code%TYPE;
     -- abindal end --

     CURSOR check_duplicate_csr (p_chr_id NUMBER, p_assoc_obj_id NUMBER, p_start_date DATE, p_end_date DATE) IS
     SELECT '1'
     FROM   okl_vp_associations
     WHERE  chr_id = p_chr_id
     AND    assoc_object_id = p_assoc_obj_id
     AND    start_date <= p_start_date
     AND    nvl(end_date,sysdate) >= nvl(p_end_date,sysdate);

     CURSOR check_duplicate_csr1 (p_crs_id NUMBER, p_assoc_obj_id NUMBER, p_start_date DATE, p_end_date DATE) IS
     SELECT '1'
     FROM   okl_vp_associations
     WHERE  crs_id = p_crs_id
     AND    assoc_object_id = p_assoc_obj_id
     AND    start_date <= p_start_date
     AND    nvl(end_date,sysdate) >= nvl(p_end_date,sysdate);

     -- abindal start --
     CURSOR get_la_rec(cp_assoc_id IN NUMBER) IS
     -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
     SELECT -- application_type,
            cust_credit_classification,
            credit_review_purpose,
            -- Change sic_code to industry_code
            -- sic_code,
            industry_code,
            /* Manu 31-Aug-2005 Remove REFERENCE_NUMBER column */
            -- reference_number
            name
     FROM   OKL_LEASEAPP_TMPLS
     WHERE  id = cp_assoc_id;

     -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
     CURSOR get_la_assoc_chr_rec(cp_chr_id IN NUMBER, -- cp_appl_type IN VARCHAR2,
                                 cp_credit_class IN VARCHAR2, cp_credit_review IN VARCHAR2, cp_sic_code IN VARCHAR2)IS
     SELECT 'X'
     FROM   OKL_LEASEAPP_TMPLS lat,
            okl_vp_associations_v vpa
     WHERE  lat.id = vpa.assoc_object_id
     AND    vpa.assoc_object_type_code = 'LA_TEMPLATE'
     AND    vpa.chr_id = cp_chr_id
     AND    lat.cust_credit_classification = cp_credit_class
     AND    lat.credit_review_purpose = cp_credit_review
     AND    (lat.industry_code = cp_sic_code OR cp_sic_code IS NULL);

     -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
     CURSOR get_la_assoc_crs_rec(cp_crs_id IN NUMBER, -- cp_appl_type IN VARCHAR2,
                                 cp_credit_class IN VARCHAR2, cp_credit_review IN VARCHAR2, cp_sic_code IN VARCHAR2)IS
     SELECT 'X'
     FROM   OKL_LEASEAPP_TMPLS lat,
            okl_vp_associations_v vpa
     WHERE  lat.id = vpa.assoc_object_id
     AND    vpa.assoc_object_type_code = 'LA_TEMPLATE'
     AND    vpa.crs_id = cp_crs_id
     -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
     -- AND    lat.application_type = cp_appl_type
     AND    lat.cust_credit_classification = cp_credit_class
     AND    lat.credit_review_purpose = cp_credit_review
     -- Manu 01-Sep-2005 Change sic_code to industry_code
     -- AND    lat.sic_code = cp_sic_code;
     AND    lat.industry_code = cp_sic_code;

     CURSOR get_agrmnt_name(cp_chr_id IN NUMBER) IS
     SELECT contract_number
     FROM   OKC_K_HEADERS_B
     WHERE  id = cp_chr_id;

     CURSOR c_get_creq_info(cp_crs_id okl_vp_change_requests.id%TYPE) IS
     SELECT change_type_code
     FROM   okl_vp_change_requests
     WHERE  id = cp_crs_id;

     CURSOR c_get_agr_number(cp_crs_id okl_vp_change_requests.id%TYPE)IS
     SELECT chr.contract_number
     FROM   okc_k_headers_b chr,
            okl_k_headers khr
     WHERE  chr.id = khr.id
     AND    khr.crs_id = cp_crs_id;

     CURSOR get_agreement_name(cp_crs_id IN NUMBER) IS
     SELECT contract_number
     FROM   OKC_K_HEADERS_B okc,
            OKL_VP_CHANGE_REQUESTS chr
     WHERE  chr.id = cp_crs_id
     AND    okc.id = chr.chr_id;
    -- abindal end --

     CURSOR c_chk_lat_dates(cp_chr_id okc_k_headers_b.id%TYPE
                           ,cp_object_id okl_vp_associations.assoc_object_id%TYPE
                           ,cp_start_date okl_vp_associations.start_date%TYPE
                           ,cp_end_date okl_vp_associations.end_date%TYPE)IS
     SELECT 'X'
       FROM okl_vp_associations
      WHERE chr_id = cp_chr_id
        AND assoc_object_id = cp_object_id
        AND ((trunc(start_date) BETWEEN trunc(cp_start_date) AND trunc(NVL(cp_end_date,okl_accounting_util.g_final_date))) OR
             (trunc(cp_start_date) BETWEEN trunc(start_date) AND TRUNC(NVL(end_date,okl_accounting_util.g_final_date))));

     CURSOR c_chk_lat_dates1(cp_crs_id okl_vp_change_requests.id%TYPE
                           ,cp_object_id okl_vp_associations.assoc_object_id%TYPE
                           ,cp_start_date okl_vp_associations.start_date%TYPE
                           ,cp_end_date okl_vp_associations.end_date%TYPE)IS
     SELECT 'X'
       FROM okl_vp_associations
      WHERE crs_id = cp_crs_id
        AND assoc_object_id = cp_object_id
        AND ((trunc(start_date) BETWEEN trunc(cp_start_date) AND trunc(NVL(cp_end_date,okl_accounting_util.g_final_date))) OR
             (trunc(cp_start_date) BETWEEN trunc(start_date) AND TRUNC(NVL(end_date,okl_accounting_util.g_final_date))));

   BEGIN

     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);

     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

  -- Make sure either chr_id or crs_id is populated--
  IF(p_vasv_rec.chr_id = OKL_API.G_MISS_NUM OR p_vasv_rec.chr_id IS NULL) AND
    (p_vasv_rec.crs_id = OKL_API.G_MISS_NUM OR p_vasv_rec.crs_id IS NULL) THEN
    OKL_API.set_message(OKL_API.G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'chr_id or crs_id');
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- abindal start --
  OPEN get_la_rec(p_vasv_rec.assoc_object_id);

  -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
  FETCH get_la_rec INTO l_credit_class, l_credit_purpose, l_sic_code, l_appl_temp_name;
  CLOSE get_la_rec;

   IF (p_vasv_rec.chr_id IS NOT NULL AND p_vasv_rec.chr_id <> OKL_API.G_MISS_NUM) THEN
     IF('LA_TEMPLATE' = p_vasv_rec.assoc_object_type_code)THEN
        l_dummy := null;
        OPEN c_chk_lat_dates (p_vasv_rec.chr_id, p_vasv_rec.assoc_object_id, p_vasv_rec.start_date, p_vasv_rec.end_date);
        FETCH c_chk_lat_dates INTO l_dummy;
        CLOSE c_chk_lat_dates;

        IF (l_dummy IS NOT NULL) THEN
          OPEN get_agrmnt_name(p_vasv_rec.chr_id);
          FETCH get_agrmnt_name INTO l_agrmnt_name;
          CLOSE  get_agrmnt_name;

          OKL_API.SET_MESSAGE(OKL_API.G_APP_NAME,
                              'OKL_VP_LAT_VERSION_DATES_ERR',
                              'APP_TEMPLATE',
                              l_appl_temp_name,
                              'AGR_NUMBER',
                              l_agrmnt_name
                             );
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;
   END IF;

   IF (p_vasv_rec.crs_id IS NOT NULL AND p_vasv_rec.crs_id <> OKL_API.G_MISS_NUM) THEN
     IF('LA_TEMPLATE' = p_vasv_rec.assoc_object_type_code)THEN
       OPEN  c_get_creq_info (p_vasv_rec.crs_id);
       FETCH c_get_creq_info INTO lv_change_type_code;
       CLOSE c_get_creq_info;
       -- for AGREEMENT type of change request, the context agreement needs to be derived
       IF('AGREEMENT' = lv_change_type_code)THEN
          OPEN  c_get_agr_number(p_vasv_rec.crs_id);
          FETCH c_get_agr_number INTO l_agrmnt_name;
          CLOSE c_get_agr_number;
       ELSIF('ASSOCIATION' = lv_change_type_code)THEN
         -- for ASSOCIATION type of change request, the chr_id in the okl_vp_change_requests table is as good
         OPEN  get_agreement_name(p_vasv_rec.crs_id);
         FETCH get_agreement_name INTO l_agrmnt_name;
         CLOSE get_agreement_name;
       END IF;
        l_dummy := null;
        OPEN c_chk_lat_dates1 (p_vasv_rec.crs_id, p_vasv_rec.assoc_object_id, p_vasv_rec.start_date, p_vasv_rec.end_date);
        FETCH c_chk_lat_dates1 INTO l_dummy;
        CLOSE c_chk_lat_dates1;

       IF (l_dummy IS NOT NULL) THEN
         OKL_API.SET_MESSAGE( OKL_API.G_APP_NAME,
                              'OKL_VP_LAT_VERSION_DATES_ERR',
                              'APP_TEMPLATE',
                              l_appl_temp_name,
                              'AGR_NUMBER',
                              l_agrmnt_name
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
   END IF;
  -- abindal end --

    -- sjalasut, added uniqueness check for Lease Contract Template. A Lease Contract Template instance cannot exist on the Program Agreement
    -- more than once for given effective dates
    validate_uniqueness(x_return_status => x_return_status, p_vasv_rec => p_vasv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     OKL_VAS_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vasv_rec,
                            x_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
       raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     validate_vp_associations_dates(x_return_status, x_vasv_rec);
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     validate_object_version(x_return_status, x_vasv_rec);
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     x_return_status := l_return_status;

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => p_vasv_rec.chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_vp_associations;

   PROCEDURE create_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_tbl                     IN vasv_tbl_type,
     x_vasv_tbl                     OUT NOCOPY vasv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_vasv_tbl.COUNT > 0 Then
       i := p_vasv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         create_vp_associations(p_api_version,
                           		  p_init_msg_list,
                          		  x_return_status,
                            	  x_msg_count,
                            	  x_msg_data,
                            	  p_vasv_tbl(i),
                            	  x_vasv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_vasv_tbl.LAST);
       i := p_vasv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END create_vp_associations;

   PROCEDURE lock_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_rec                    IN vasv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_VAS_PVT.lock_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_vp_associations;

   PROCEDURE lock_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_tbl                     IN vasv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_vasv_tbl.COUNT > 0 Then
       i := p_vasv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         lock_vp_associations(p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_vasv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_vasv_tbl.LAST);
       i := p_vasv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END lock_vp_associations;

   PROCEDURE delete_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_rec                    IN vasv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_chr_id            OKL_VP_ASSOCIATIONS.CHR_ID%TYPE;


     CURSOR cur_get_chr_id IS
     SELECT chr_id
     FROM   okl_vp_associations
     WHERE  id = p_vasv_rec.id;

   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


    /* Manu 29-Jun-2005 Begin */
    OPEN  cur_get_chr_id;
    FETCH cur_get_chr_id INTO l_chr_id;
    CLOSE cur_get_chr_id;
    /* Manu 29-Jun-2005 END */


     OKL_VAS_PVT.delete_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;


    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => l_chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_vp_associations;

   PROCEDURE delete_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_tbl                     IN vasv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_vasv_tbl.COUNT > 0 Then
       i := p_vasv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         delete_vp_associations(p_api_version,
                                  p_init_msg_list,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data,
                                  p_vasv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_vasv_tbl.LAST);
       i := p_vasv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END delete_vp_associations;

   PROCEDURE update_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_rec                     IN vasv_rec_type,
     x_vasv_rec                     OUT NOCOPY vasv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
		 l_vasv_rec vasv_rec_type;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    -- sjalasut, added uniqueness check for Lease Contract Template. A Lease Contract Template instance cannot exist on the Program Agreement
    -- more than once for given effective dates
    validate_uniqueness(x_return_status => x_return_status, p_vasv_rec => p_vasv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

		 -- need to pass G_MISS_.. to the required fields with null values
		 -- to avoid errors from TAPIs--
		 l_vasv_rec := p_vasv_rec;

		 if (l_vasv_rec.chr_id is null) then
		   l_vasv_rec.chr_id := OKL_API.G_MISS_NUM;
		 end if;
		 if (l_vasv_rec.crs_id is null) then
		   l_vasv_rec.crs_id := OKL_API.G_MISS_NUM;
		 end if;
		 if (l_vasv_rec.object_version_number is null) then
		   l_vasv_rec.object_version_number := OKL_API.G_MISS_NUM;
		 end if;
		 if (l_vasv_rec.assoc_object_type_code is null) then
		   l_vasv_rec.assoc_object_type_code := OKL_API.G_MISS_CHAR;
		 end if;
		 if (l_vasv_rec.start_date is null) then
		   l_vasv_rec.start_date := OKL_API.G_MISS_DATE;
		 end if;
		 if (l_vasv_rec.assoc_object_id is null) then
		   l_vasv_rec.assoc_object_id := OKL_API.G_MISS_NUM;
		 end if;
		 if (l_vasv_rec.created_by is null) then
		   l_vasv_rec.created_by := OKL_API.G_MISS_NUM;
		 end if;
		 if (l_vasv_rec.creation_date is null) then
		   l_vasv_rec.creation_date := OKL_API.G_MISS_DATE;
		 end if;
		 if (l_vasv_rec.last_updated_by is null) then
		   l_vasv_rec.last_updated_by := OKL_API.G_MISS_NUM;
		 end if;
		 if (l_vasv_rec.last_update_date is null) then
		   l_vasv_rec.last_update_date := OKL_API.G_MISS_DATE;
		 end if;

     OKL_VAS_PVT.update_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_vasv_rec,
                            x_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     validate_vp_associations_dates(x_return_status, x_vasv_rec);

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     validate_object_version(x_return_status, x_vasv_rec);

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       l_return_status := x_return_status;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    /* Manu 29-Jun-2005 Begin */
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                         ,p_init_msg_list => p_init_msg_list
                         ,x_return_status => x_return_status
                         ,x_msg_count     => x_msg_count
                         ,x_msg_data      => x_msg_data
                         ,p_program_id    => l_vasv_rec.chr_id
                        );
  END IF;
    /* Manu 29-Jun-2005 END */

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_vp_associations;

   PROCEDURE update_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_tbl                     IN vasv_tbl_type,
     x_vasv_tbl                     OUT NOCOPY vasv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;

   BEGIN

     If p_vasv_tbl.COUNT > 0 Then
       i := p_vasv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         update_vp_associations(p_api_version,
                                  p_init_msg_list,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data,
                                  p_vasv_tbl(i),
                                  x_vasv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_vasv_tbl.LAST);
       i := p_vasv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END update_vp_associations;

   PROCEDURE validate_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_rec                     IN vasv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

	 --
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

	 -- Validate the record before column level validation
     validate_vp_associations_dates(x_return_status, p_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

	 -- Validate LA unique combination --



     OKL_VAS_PVT.validate_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_vp_associations;

   PROCEDURE validate_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_tbl                     IN vasv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_vasv_tbl.COUNT > 0 Then
       i := p_vasv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         validate_vp_associations(p_api_version,
                          		    p_init_msg_list,
                          			x_return_status,
                          			x_msg_count,
                         			x_msg_data,
                          			p_vasv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_vasv_tbl.LAST);
       i := p_vasv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END validate_vp_associations;


   PROCEDURE copy_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_rec                     IN vasv_rec_type,
     x_vasv_rec                     OUT NOCOPY vasv_rec_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'COPY_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

	 --get the vp to be copied--
	 CURSOR copy_vp_assoc_csr (p_id NUMBER) IS
	 SELECT start_date,
		  	end_date,
			description,
		 	assoc_object_type_code,
			assoc_object_id,
			assoc_object_version
	 FROM okl_vp_associations
	 WHERE id = p_id;

	 l_vasv_rec vasv_rec_type;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

	 OPEN copy_vp_assoc_csr (p_vasv_rec.id);
	 FETCH copy_vp_assoc_csr INTO l_vasv_rec.start_date,
	 	   			   		l_vasv_rec.end_date,
							l_vasv_rec.description,
							l_vasv_rec.assoc_object_type_code,
							l_vasv_rec.assoc_object_id,
							l_vasv_rec.assoc_object_version;
	 CLOSE copy_vp_assoc_csr;

	 l_vasv_rec.chr_id := p_vasv_rec.chr_id;
	 OKL_VAS_PVT.insert_row(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_vasv_rec,
                            x_vasv_rec);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END copy_vp_associations;

   -- Copy associations for normal agreement copy or crs (of type 'Agreement') copy--
   PROCEDURE copy_vp_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_vasv_tbl                     IN vasv_tbl_type,
     x_vasv_tbl                     OUT NOCOPY vasv_tbl_type
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'COPY_VP_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
     l_overall_status     VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
     i                    NUMBER;
   BEGIN

     If p_vasv_tbl.COUNT > 0 Then
       i := p_vasv_tbl.FIRST;
       LOOP
         -- call procedure in complex API for a record
         copy_vp_associations(p_api_version,
                          	  p_init_msg_list,
                          	  x_return_status,
                          	  x_msg_count,
                         	  x_msg_data,
                          	  p_vasv_tbl(i),
							  x_vasv_tbl(i));
         If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;

       EXIT WHEN (i = p_vasv_tbl.LAST);
       i := p_vasv_tbl.NEXT(i);
       END LOOP;

       -- return overall status
       x_return_status := l_overall_status;
     End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END copy_vp_associations;

   -- Copy associations from crs call --crs of type 'Associations'--
   PROCEDURE copy_crs_associations(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chr_id                       IN NUMBER,
	 p_crs_id                       IN NUMBER
     ) IS
     l_api_name          CONSTANT VARCHAR2(30) := 'COPY_CRS_ASSOCIATIONS';
     l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

	 --get the vp to be copied--
	 CURSOR copy_vp_assoc_csr (p_chr_id NUMBER) IS
	 SELECT start_date,
		  	end_date,
			description,
		 	assoc_object_type_code,
			assoc_object_id,
			assoc_object_version
	 FROM okl_vp_associations
	 WHERE chr_id = p_chr_id
	 AND crs_id IS NULL;

     l_vasv_tbl vasv_tbl_type;
     xl_vasv_tbl vasv_tbl_type;
     l_vasv_rec vasv_rec_type;
     i NUMBER;
   BEGIN
     x_return_status := l_return_status;
     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKL_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

	 OPEN copy_vp_assoc_csr (p_chr_id);
     LOOP
	   FETCH copy_vp_assoc_csr INTO l_vasv_rec.start_date,
	 	   			   		l_vasv_rec.end_date,
							l_vasv_rec.description,
							l_vasv_rec.assoc_object_type_code,
							l_vasv_rec.assoc_object_id,
							l_vasv_rec.assoc_object_version;
	   EXIT WHEN copy_vp_assoc_csr%NOTFOUND;
	   i := copy_vp_assoc_csr%RowCount;
	   l_vasv_rec.crs_id := p_crs_id;
	   l_vasv_tbl(i) := l_vasv_rec;
	 END LOOP;
	 CLOSE copy_vp_assoc_csr;

	 IF (l_vasv_tbl.count <> 0) THEN
        OKL_VAS_PVT.insert_row(
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_vasv_tbl                     => l_vasv_tbl,
          x_vasv_tbl                     => xl_vasv_tbl
        );
	 END IF;

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     OKL_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
   END copy_crs_associations;



END OKL_VP_ASSOCIATIONS_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKL_ITEM_RESIDUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ITEM_RESIDUALS_PVT" AS
  /* $Header: OKLRIRSB.pls 120.8 2006/08/09 14:18:17 pagarg noship $ */
G_WF_EVT_IRS_PENDING  CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.fe.irsapproval';
G_WF_IRS_VERSION_ID  CONSTANT  VARCHAR2(50)       := 'VERSION_ID';

  FUNCTION is_latest(p_item_residual_id NUMBER, p_ver_number VARCHAR2) RETURN BOOLEAN IS
  max_version NUMBER := 1;

  CURSOR get_max_ver(p_item_residual_id NUMBER) IS
    SELECT
          MAX(TO_NUMBER(ICPV.VERSION_NUMBER))
      FROM
           OKL_ITM_CAT_RV_PRCS_V ICPV
      WHERE
           ICPV.ITEM_RESIDUAL_ID = p_item_residual_id;
  BEGIN

    OPEN get_max_ver(p_item_residual_id);
      FETCH get_max_ver INTO max_version;
    CLOSE get_max_ver;

     IF TO_NUMBER(p_ver_number) = max_version THEN
       RETURN TRUE;
     ELSE RETURN FALSE;
     END IF;
  END is_latest;

 -- Gets the latest active version of an item residual
  FUNCTION is_latest_active (p_item_residual_id NUMBER, p_ver_number VARCHAR2) RETURN BOOLEAN IS
  max_version NUMBER := 1;

  CURSOR get_max_ver(p_item_residual_id NUMBER) IS
    SELECT
          MAX(TO_NUMBER(ICPV.VERSION_NUMBER))
      FROM
           OKL_ITM_CAT_RV_PRCS_V ICPV
      WHERE
             ICPV.STS_CODE = G_STS_ACTIVE
         AND ICPV.ITEM_RESIDUAL_ID = p_item_residual_id	   ;
  BEGIN

    OPEN get_max_ver(p_item_residual_id);
      FETCH get_max_ver INTO max_version;
    CLOSE get_max_ver;

     IF TO_NUMBER(p_ver_number) = max_version THEN
       RETURN TRUE;
     ELSE RETURN FALSE;
     END IF;
  END is_latest_active;

  -- Checks if the percent values lie in the range 0-100
  PROCEDURE validate_percent_values(p_irv_tbl IN okl_irv_tbl) IS
  BEGIN
    FOR i IN p_irv_tbl.FIRST..p_irv_tbl.LAST
    LOOP
      IF p_irv_tbl(i).residual_value > 100 THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_INVALID_VALUE',
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Term ' || p_irv_tbl(i).term_in_months );
        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;
    END LOOP;
  END;

  -- Returns false for invalid effective from date
  -- Checks if the effective from is later than the previous version effective from date
  -- Checks if the effective from date later than the previous version effective to date
  FUNCTION valid_version_effective_date(p_effective_from DATE, p_residual_id NUMBER, p_version_number VARCHAR2) RETURN BOOLEAN IS
   return_bool BOOLEAN := TRUE;
   CURSOR prev_effective_dates (p_residual_id NUMBER, p_version_number VARCHAR2) IS
      SELECT
              ICPV.START_DATE
            , ICPV.END_DATE
        FROM
            OKL_ITM_CAT_RV_PRCS_V ICPV
        WHERE
             ICPV.ITEM_RESIDUAL_ID = p_residual_id
         AND TO_NUMBER(ICPV.VERSION_NUMBER)   =  TO_NUMBER(p_version_number)-1 ;

   l_ver_rec prev_effective_dates%ROWTYPE;
  BEGIN
    OPEN prev_effective_dates(p_residual_id,p_version_number);
      FETCH prev_effective_dates INTO l_ver_rec;
    CLOSE prev_effective_dates;

      IF l_ver_rec.START_DATE >= p_effective_from  AND l_ver_rec.END_DATE IS NULL THEN
        return_bool := FALSE;
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                     	    p_msg_name     => 'OKL_ST_INVALID_EFFECTIVE_FROM',
                            p_token1       => 'EFF_DATE',
                            p_token1_value => l_ver_rec.START_DATE+1);
      ELSIF l_ver_rec.END_DATE >= p_effective_from THEN
        return_bool := FALSE;
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                     	    p_msg_name     => 'OKL_ST_INVALID_EFFECTIVE_FROM',
                            p_token1       => 'EFF_DATE',
                            p_token1_value => l_ver_rec.END_DATE+1);
      END IF;

      IF TO_NUMBER(p_version_number) = 1 THEN
        return_bool := TRUE;
      END IF;

    RETURN return_bool;
  END valid_version_effective_date;

  PROCEDURE get_effective_date(
                         p_api_version       IN  NUMBER
                       , p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status     OUT NOCOPY VARCHAR2
                       , x_msg_count         OUT NOCOPY NUMBER
                       , x_msg_data          OUT NOCOPY VARCHAR2
                       , p_item_resdl_ver_id IN  NUMBER
                       , x_calc_date         OUT NOCOPY DATE
                       ) IS
    l_api_name              CONSTANT VARCHAR2(65) := 'get_effective_date';
    l_api_version           CONSTANT NUMBER         := p_api_version;
    l_init_msg_list         VARCHAR2(1)    := p_init_msg_list;
    l_msg_count             NUMBER         := x_msg_count ;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    l_calc_date             DATE := NULL;
    l_calc_date1           DATE := NULL;
    l_calc_date2           DATE := NULL;

-- cursor to fetch the maximum start date of lease quotes referencing Lease Rate Sets - When source is Item
CURSOR lrs_lq_csr_itm(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_lease_quotes_b
WHERE rate_card_id IN(SELECT
                        LRFVERV.RATE_SET_ID        LRS_ID
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       IN ('RESIDUAL_PERCENT','RESIDUAL_AMOUNT')
                    AND IRHV.INVENTORY_ITEM_ID      = EOTL.INVENTORY_ITEM_ID
                    AND IRHV.ORGANIZATION_ID        = EOTL.ORGANIZATION_ID
                    AND IRHV.CATEGORY_SET_ID        = EOTL.CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND LRFVERV.EFFECTIVE_FROM_DATE BETWEEN ICPV.START_DATE AND NVL(ICPV.END_DATE,TO_DATE('31-12-9999','dd-mm-yyyy'))
                    AND ICPV.ID                     = p_version_id);

-- cursor to fetch the maximum start date of lease quotes referencing Lease Rate Sets - When source is Item Category
CURSOR lrs_lq_csr_itm_cat(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_lease_quotes_b
WHERE rate_card_id IN(SELECT
                        LRFVERV.RATE_SET_ID        LRS_ID
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       IN ('RESIDUAL_PERCENT','RESIDUAL_AMOUNT')
                    AND IRHV.CATEGORY_ID        = EOTL.CATEGORY_ID
                    AND IRHV.CATEGORY_SET_ID        = EOTL.CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND LRFVERV.EFFECTIVE_FROM_DATE BETWEEN ICPV.START_DATE AND NVL(ICPV.END_DATE,TO_DATE('31-12-9999','dd-mm-yyyy'))
                    AND ICPV.ID                     = p_version_id);

-- cursor to fetch the maximum start date of lease quotes referencing Lease Rate Sets - When source is Residual Category set
CURSOR lrs_lq_csr_rcs(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_lease_quotes_b
WHERE rate_card_id IN(SELECT
                        LRFVERV.RATE_SET_ID        LRS_ID
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       IN ('RESIDUAL_PERCENT','RESIDUAL_AMOUNT')
                    AND IRHV.RESI_CATEGORY_SET_ID        = EOTL.RESI_CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND LRFVERV.EFFECTIVE_FROM_DATE BETWEEN ICPV.START_DATE AND NVL(ICPV.END_DATE,TO_DATE('31-12-9999','dd-mm-yyyy'))
                    AND ICPV.ID                     = p_version_id);

-- cursor to fetch the maximum start date of quick quotes referencing Lease Rate Sets - When source is Item
CURSOR lrs_qq_csr_itm(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_quick_quotes_b
WHERE rate_card_id IN (SELECT
                        LRFVERV.RATE_SET_ID        LRS_ID
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       IN ('RESIDUAL_PERCENT','RESIDUAL_AMOUNT')
                    AND IRHV.INVENTORY_ITEM_ID      = EOTL.INVENTORY_ITEM_ID
                    AND IRHV.ORGANIZATION_ID        = EOTL.ORGANIZATION_ID
                    AND IRHV.CATEGORY_SET_ID        = EOTL.CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND LRFVERV.EFFECTIVE_FROM_DATE BETWEEN ICPV.START_DATE AND NVL(ICPV.END_DATE,TO_DATE('31-12-9999','dd-mm-yyyy'))
                    AND ICPV.ID                     = p_version_id);

-- cursor to fetch the maximum start date of quick quotes referencing Lease Rate Sets - When source is Item Category
CURSOR lrs_qq_csr_itm_cat(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_quick_quotes_b
WHERE rate_card_id IN (SELECT
                        LRFVERV.RATE_SET_ID        LRS_ID
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       IN ('RESIDUAL_PERCENT','RESIDUAL_AMOUNT')
                    AND IRHV.CATEGORY_ID      = EOTL.CATEGORY_ID
                    AND IRHV.CATEGORY_SET_ID        = EOTL.CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND LRFVERV.EFFECTIVE_FROM_DATE BETWEEN ICPV.START_DATE AND NVL(ICPV.END_DATE,TO_DATE('31-12-9999','dd-mm-yyyy'))
                    AND ICPV.ID                     = p_version_id);

-- cursor to fetch the maximum start date of quick quotes referencing Lease Rate Sets - When source is Residual Category set
CURSOR lrs_qq_csr_rcs(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_quick_quotes_b
WHERE rate_card_id IN (SELECT
                        LRFVERV.RATE_SET_ID        LRS_ID
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       IN ('RESIDUAL_PERCENT','RESIDUAL_AMOUNT')
                    AND IRHV.RESI_CATEGORY_SET_ID        = EOTL.RESI_CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND LRFVERV.EFFECTIVE_FROM_DATE BETWEEN ICPV.START_DATE AND NVL(ICPV.END_DATE,TO_DATE('31-12-9999','dd-mm-yyyy'))
                    AND ICPV.ID                     = p_version_id);

    CURSOR get_version_dtls(p_ver_id NUMBER) IS
       SELECT
             ICPV.START_DATE
           , ICPV.END_DATE
           , ICPV.VERSION_NUMBER
           , ICPV.STS_CODE
           , ICPV.ITEM_RESIDUAL_ID
           , IRHV.CATEGORY_TYPE_CODE
        FROM
             OKL_ITM_CAT_RV_PRCS_V  ICPV
           , OKL_FE_ITEM_RESIDUAL IRHV
        WHERE
             IRHV.ITEM_RESIDUAL_ID = ICPV.ITEM_RESIDUAL_ID
         AND ICPV.ID = p_ver_id;

  l_version_details get_version_dtls%ROWTYPE;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.get_effective_date';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call get_effective_date');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- Get the end date of the version.
   OPEN get_version_dtls(p_item_resdl_ver_id);
     FETCH get_version_dtls INTO l_version_details;
   CLOSE get_version_dtls;

   -- If Source is Item then call cursor for items
     -- Get the maximum date of the referenced Quotes
    CASE l_version_details.category_type_code
       WHEN G_CAT_ITEM THEN
          OPEN lrs_lq_csr_itm(p_item_resdl_ver_id);
            FETCH lrs_lq_csr_itm INTO l_calc_date1;
          CLOSE lrs_lq_csr_itm;

          OPEN lrs_qq_csr_itm(p_item_resdl_ver_id);
            FETCH lrs_qq_csr_itm INTO l_calc_date2;
          CLOSE lrs_qq_csr_itm;

   -- If Source is Item category then call cursor for item categories
     -- Get the maximum date of the referenced Quotes
       WHEN G_CAT_ITEM_CAT THEN
          OPEN lrs_lq_csr_itm_cat(p_item_resdl_ver_id);
            FETCH lrs_lq_csr_itm_cat INTO l_calc_date1;
          CLOSE lrs_lq_csr_itm_cat;

          OPEN lrs_qq_csr_itm_cat(p_item_resdl_ver_id);
            FETCH lrs_qq_csr_itm_cat INTO l_calc_date2;
          CLOSE lrs_qq_csr_itm_cat;
   -- If Source is Residual Category Set then call cursor for residual category sets
     -- Get the maximum date of the referenced Quotes
       WHEN G_CAT_RES_CAT THEN
          OPEN lrs_lq_csr_rcs(p_item_resdl_ver_id);
            FETCH lrs_lq_csr_rcs INTO l_calc_date1;
          CLOSE lrs_lq_csr_rcs;

          OPEN lrs_qq_csr_rcs(p_item_resdl_ver_id);
            FETCH lrs_qq_csr_rcs INTO l_calc_date2;
          CLOSE lrs_qq_csr_rcs;
     END CASE;

   -- If the maximum date of referenced Quotes is not null
   -- END DATE = max date + 1
   IF l_calc_date1 IS NOT NULL OR l_calc_date2 IS NOT NULL THEN
      IF l_calc_date1 > l_calc_date2 THEN
        l_calc_date := l_calc_date1;
      ELSE
        l_calc_date := l_calc_date2;
      END IF;

   -- If the maximum date of referenced Quotes is null
   ELSE
     -- If the end date is null, then return start date + 1
     -- else return end date + 1
      IF l_version_details.END_DATE IS NULL THEN
         l_calc_date := l_version_details.START_DATE + 1;
      ELSE
         l_calc_date := l_version_details.END_DATE + 1;
      END IF;
   END IF;

    x_calc_date := l_calc_date;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call get_effective_date');
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
  END get_effective_date;
  PROCEDURE create_irs (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'create_irs';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    lx_irv_tbl               okl_irv_tbl;
    lp_icpv_rec              okl_icpv_rec  := p_icpv_rec;
    lp_irv_tbl               okl_irv_tbl   := p_irv_tbl;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.create_irs';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call create_irs');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  -- Insert row into the header table
  OKL_IRH_PVT.insert_row(
	     p_api_version    => p_api_version
	   , p_init_msg_list  => p_init_msg_list
	   , x_return_status  => l_return_status
	   , x_msg_count      => x_msg_count
	   , x_msg_data       => x_msg_data
	   , p_irhv_rec       => p_irhv_rec
	   , x_irhv_rec       => x_irhv_rec);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Set the ITEM_RESIDUAL_ID in the versions table
    lp_icpv_rec.item_residual_id         := x_irhv_rec.item_residual_id;
    lp_icpv_rec.version_number := '1';
    lp_icpv_rec.object_version_number := 1;
    -- Insert row in the versions table
    OKL_ICP_PVT.insert_row(
                 p_api_version   => p_api_version
               , p_init_msg_list => p_init_msg_list
               , x_return_status => l_return_status
               , x_msg_count     => x_msg_count
               , x_msg_data      => x_msg_data
               , p_icpv_rec      => lp_icpv_rec
               , x_icpv_rec      => x_icpv_rec);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF lp_irv_tbl.COUNT > 0 THEN
    -- validate the Values of terms
    IF p_irhv_rec.residual_type_code = G_RESD_PERCENTAGE THEN
      validate_percent_values(lp_irv_tbl);
    END IF;
    -- Set the ITEM_RESDL_VERSION_ID, OBJECT_VERSION_NUMBER columns of OKL_FE_ITEM_RESDL_VALUES table.
    FOR i IN lp_irv_tbl.FIRST..lp_irv_tbl.LAST
    LOOP
      lp_irv_tbl(i).item_residual_id          := x_icpv_rec.item_residual_id;
      lp_irv_tbl(i).item_resdl_version_id     := x_icpv_rec.id;
      lp_irv_tbl(i).object_version_number     := 1;
    END LOOP;

    -- Insert the lines - term value pairs for the item residual
    OKL_IRV_PVT.insert_row(
   	            p_api_version	 => p_api_version
               , p_init_msg_list =>	p_init_msg_list
        	   , x_return_status =>	l_return_status
        	   , x_msg_count	 =>	x_msg_count
        	   , x_msg_data		 =>	x_msg_data
        	   , p_irv_tbl		 =>	lp_irv_tbl
        	   , x_irv_tbl		 =>	lx_irv_tbl );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    END IF; -- end of check for empty term- value pairs

    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call create_irs');
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
  END create_irs;

  PROCEDURE update_version_irs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                       ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'update_version_irs';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
    l_end_date               DATE           := NULL;
    l_change_sts             VARCHAR2(1) := 'n';
    l_confirm_yn             VARCHAR2(3) := 'yes';

    lp_irhv_rec     okl_irhv_rec := p_irhv_rec;
    lp_icpv_rec     okl_icpv_rec := p_icpv_rec;

    lp_crt_irv_tbl  okl_irv_tbl;
    lp_upd_irv_tbl  okl_irv_tbl;
    lx_crt_irv_tbl  okl_irv_tbl;
    lx_upd_irv_tbl  okl_irv_tbl;
    l_lrs_list        lrs_ref_tbl;
    l_calc_date       DATE   := NULL;
    l_db_ver_end_date DATE   := NULL;
    j                 NUMBER := 1;
    k                 NUMBER := 1;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.update_version_irs';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  -- Select the effective to and compare.
  CURSOR get_version_details(p_version_id NUMBER) IS
    SELECT
          ICP.END_DATE
     FROM
          OKL_ITM_CAT_RV_PRCS ICP
     WHERE
          ICP.ID = p_version_id;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call update_version_irs');
     END IF;

    -- Initialize the OUT records
    x_irhv_rec := p_irhv_rec;
    x_icpv_rec := p_icpv_rec;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* Calculate the effective date */
    get_effective_date(
                      l_api_version
                    , l_init_msg_list
                    , l_return_status
                    , x_msg_count
                    , x_msg_data
                    , lp_icpv_rec.id
                    , l_calc_date
                       );
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    OPEN get_version_details(lp_icpv_rec.id);
      FETCH get_version_details INTO l_db_ver_end_date;
    CLOSE get_version_details;

    -- Set for G_MISS_CHANGES. Set to G_MISS if null is to be updated
    IF lp_icpv_rec.end_date IS NULL THEN
      lp_icpv_rec.end_date := OKL_API.G_MISS_DATE;
    END IF;

     OKL_ICP_PVT.update_row(
                     p_api_version   => p_api_version
                   , p_init_msg_list => p_init_msg_list
                   , x_return_status => l_return_status
                   , x_msg_count     => x_msg_count
                   , x_msg_data      => x_msg_data
                   , p_icpv_rec      => lp_icpv_rec
                   , x_icpv_rec      => x_icpv_rec);
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     j := 1;
     k:=1;
     IF p_irv_tbl.COUNT >0 THEN
       -- validate the Values of terms
       IF p_irhv_rec.residual_type_code = G_RESD_PERCENTAGE THEN
         validate_percent_values(p_irv_tbl);
        END IF;
     FOR i IN p_irv_tbl.FIRST..p_irv_tbl.LAST
     LOOP
       IF p_irv_tbl(i).item_resdl_value_id IS NULL OR p_irv_tbl(i).item_resdl_value_id = OKL_API.G_MISS_NUM THEN
         lp_crt_irv_tbl(j) := p_irv_tbl(i);
         lp_crt_irv_tbl(j).item_residual_id := x_icpv_rec.item_residual_id;
         lp_crt_irv_tbl(j).item_resdl_version_id := x_icpv_rec.id;
         j := j+1;

       ELSE
         lp_upd_irv_tbl(k) := p_irv_tbl(i);
         lp_upd_irv_tbl(j).item_resdl_version_id := p_icpv_rec.id;
         k := k+1;

       END IF;
     END LOOP;

     -- Update the existing term value pairs if any
     IF lp_upd_irv_tbl.COUNT >0 THEN
      OKL_IRV_PVT.update_row(
   	             p_api_version	 => p_api_version
               , p_init_msg_list =>	p_init_msg_list
        	   , x_return_status =>	l_return_status
        	   , x_msg_count	 =>	x_msg_count
        	   , x_msg_data		 =>	x_msg_data
        	   , p_irv_tbl		 =>	lp_upd_irv_tbl
        	   , x_irv_tbl		 =>	lx_upd_irv_tbl );
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

     IF lp_crt_irv_tbl.COUNT >0 THEN
      OKL_IRV_PVT.insert_row(
   	             p_api_version	 => p_api_version
               , p_init_msg_list =>	p_init_msg_list
        	   , x_return_status =>	l_return_status
        	   , x_msg_count	 =>	x_msg_count
        	   , x_msg_data		 =>	x_msg_data
        	   , p_irv_tbl		 =>	lp_crt_irv_tbl
        	   , x_irv_tbl		 =>	lx_crt_irv_tbl );
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    END IF;

    -- If this is the latest active version
    IF is_latest_active(x_icpv_rec.item_residual_id,x_icpv_rec.version_number) THEN
      -- Check if any change in end date has been updated
      IF l_db_ver_end_date IS NULL AND x_icpv_rec.end_date IS NOT NULL THEN

        lp_irhv_rec.item_residual_id := x_icpv_rec.item_residual_id;
        lp_irhv_rec.effective_to_date := x_icpv_rec.end_date;

        -- Update the header's end date also.
        OKL_IRH_PVT.update_row(
                	  p_api_version   => p_api_version
                	, p_init_msg_list => p_init_msg_list
                	, x_return_status => l_return_status
                	, x_msg_count     => x_msg_count
                	, x_msg_data      => x_msg_data
                	, p_irhv_rec      => lp_irhv_rec
                	, x_irhv_rec      => x_irhv_rec);
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Call the API to end date or abandon any Lease Rate Set referring to this item residual
        change_LRS_sts (
                         p_api_version     => p_api_version
                       , p_init_msg_list   => p_init_msg_list
                       , x_return_status   => l_return_status
                       , x_msg_count       => x_msg_count
                       , x_msg_data        => x_msg_count
                       , p_confirm_yn      => l_confirm_yn
                       , p_icpv_rec        => x_icpv_rec
                       , x_lrs_list        => l_lrs_list
                       , x_change_sts      => l_change_sts
                        );
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
       END IF; -- end of check for version end date change
     END IF; -- end of check for latest version

    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call update_version_irs');
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
  END update_version_irs;

  procedure create_version_irs (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'create_version_irs';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    lx_irv_tbl       okl_irv_tbl;
    lp_irhv_rec      okl_irhv_rec := p_irhv_rec;
    lp_icpv_rec      okl_icpv_rec := p_icpv_rec;
    lp_irv_tbl       okl_irv_tbl  := p_irv_tbl;
    l_new_version_no NUMBER       := '1';

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.create_version_irs';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call create_version_irs');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_icpv_rec.item_residual_id := lp_irhv_rec.item_residual_id;

    -- Insert the new version in the OKL_ITM_CAT_RV_PRCS table.
    OKL_ICP_PVT.insert_row(
                 p_api_version   => p_api_version
               , p_init_msg_list => p_init_msg_list
               , x_return_status => l_return_status
               , x_msg_count     => x_msg_count
               , x_msg_data      => x_msg_data
               , p_icpv_rec      => lp_icpv_rec
               , x_icpv_rec      => x_icpv_rec);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF lp_irv_tbl.COUNT > 0 THEN
    -- validate the Values of terms
    IF p_irhv_rec.residual_type_code = G_RESD_PERCENTAGE THEN
      validate_percent_values(lp_irv_tbl);
    END IF;

      FOR i IN p_irv_tbl.FIRST..p_irv_tbl.LAST
      LOOP
        lp_irv_tbl(i).item_residual_id := x_icpv_rec.item_residual_id;
        lp_irv_tbl(i).item_resdl_version_id := x_icpv_rec.id;
      END LOOP;

    -- Insert the lines - term value pairs for the new version
    OKL_IRV_PVT.insert_row(
   	             p_api_version	 => p_api_version
               , p_init_msg_list =>	p_init_msg_list
        	   , x_return_status =>	l_return_status
        	   , x_msg_count	 =>	x_msg_count
        	   , x_msg_data		 =>	x_msg_data
        	   , p_irv_tbl		 =>	lp_irv_tbl
        	   , x_irv_tbl		 =>	lx_irv_tbl );
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Update the header record with the Under revision status
    lp_irhv_rec.sts_code            := G_STS_UNDER_REV;
   -- lp_irhv_rec.effective_to_date   := x_icpv_rec.end_date;
    OKL_IRH_PVT.update_row(
                	  p_api_version   => p_api_version
                	, p_init_msg_list => p_init_msg_list
                	, x_return_status => l_return_status
                	, x_msg_count     => x_msg_count
                	, x_msg_data      => x_msg_data
                	, p_irhv_rec      => lp_irhv_rec
                	, x_irhv_rec      => x_irhv_rec);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call create_version_irs');
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
  END create_version_irs;

  PROCEDURE change_LRS_sts (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_confirm_yn       IN         VARCHAR2
                       , p_icpv_rec         IN         okl_icpv_rec
                       , x_lrs_list         OUT NOCOPY lrs_ref_tbl
                       , x_change_sts       OUT NOCOPY VARCHAR2 -- Indicates if the lease rate set needs to be abandoned
                        ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'change_LRS_sts';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
    l_lrs_list               lrs_ref_tbl;
    lp_lrtv_tbl              okl_lrs_id_tbl;

    l_src_code VARCHAR2(30) := NULL;
      l_ver_end_date DATE := NULL;
    i NUMBER                := 1;

    -- cursor to retrieve all the Lease rate sets that reference the item
    CURSOR lrs_itm_csr(p_ver_id IN NUMBER) IS
                 SELECT
                        LRFVERV.RATE_SET_VERSION_ID    LRS_VERSION_ID
                      , LRFV.NAME              LRS_NAME
                      , LRFVERV.VERSION_NUMBER LRS_VERSION_NUMBER
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                      , OKL_LS_RT_FCTR_SETS_V      LRFV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       = 'RESIDUAL_PERCENT'
                    AND EOTVERV.CATEGORY_TYPE_CODE  = IRHV.CATEGORY_TYPE_CODE
                    AND EOTVERV.END_OF_TERM_ID      = LRFV.END_OF_TERM_ID
                    AND LRFVERV.RATE_SET_ID         = LRFV.ID
                    AND LRFVERV.STS_CODE            = 'ACTIVE'
                    AND IRHV.INVENTORY_ITEM_ID      = EOTL.INVENTORY_ITEM_ID
                    AND IRHV.ORGANIZATION_ID        = EOTL.ORGANIZATION_ID
--                    AND IRHV.CATEGORY_SET_ID        = EOTL.CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND NVL(p_icpv_rec.end_date,LRFVERV.EFFECTIVE_FROM_DATE +1) < LRFVERV.EFFECTIVE_FROM_DATE
                    AND LRFVERV.EFFECTIVE_FROM_DATE >= ICPV.START_DATE
                    AND ICPV.ID                     = p_ver_id;

    -- cursor to retrieve all the Lease rate sets that reference the item category
    CURSOR lrs_itm_cat_csr(p_ver_id IN NUMBER) IS
                 SELECT
                        LRFVERV.RATE_SET_VERSION_ID    LRS_VERSION_ID
                      , LRFV.NAME              LRS_NAME
                      , LRFVERV.VERSION_NUMBER LRS_VERSION_NUMBER
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                      , OKL_LS_RT_FCTR_SETS_V      LRFV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       = 'RESIDUAL_PERCENT'
                    AND EOTVERV.CATEGORY_TYPE_CODE  = IRHV.CATEGORY_TYPE_CODE
                    AND EOTVERV.END_OF_TERM_ID      = LRFV.END_OF_TERM_ID
                    AND LRFVERV.RATE_SET_ID         = LRFV.ID
                    AND LRFVERV.STS_CODE            = 'ACTIVE'
                    AND IRHV.CATEGORY_ID            = EOTL.CATEGORY_ID
                    AND IRHV.CATEGORY_SET_ID        = EOTL.CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND NVL(p_icpv_rec.end_date,LRFVERV.EFFECTIVE_FROM_DATE +1) < LRFVERV.EFFECTIVE_FROM_DATE
                    AND LRFVERV.EFFECTIVE_FROM_DATE >= ICPV.START_DATE
                    AND ICPV.ID                     = p_ver_id;

    -- cursor to retrieve all the Lease rate sets that reference the residual category set
    CURSOR lrs_res_cat_csr(p_ver_id IN NUMBER) IS
                 SELECT
                        LRFVERV.RATE_SET_VERSION_ID    LRS_VERSION_ID
                      , LRFV.NAME              LRS_NAME
                      , LRFVERV.VERSION_NUMBER LRS_VERSION_NUMBER
                  FROM
                        OKL_FE_ITEM_RESIDUAL     IRHV
                      , OKL_ITM_CAT_RV_PRCS_V      ICPV
                      , OKL_FE_EO_TERM_OBJECTS     EOTL
                      , OKL_FE_EO_TERM_VERS_V      EOTVERV
                      , OKL_FE_RATE_SET_VERSIONS_V LRFVERV
                      , OKL_LS_RT_FCTR_SETS_V      LRFV
                  WHERE
                        EOTL.END_OF_TERM_VER_ID     = EOTVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.END_OF_TERM_VER_ID  = LRFVERV.END_OF_TERM_VER_ID
                    AND EOTVERV.EOT_TYPE_CODE       = 'RESIDUAL_PERCENT'
                    AND EOTVERV.CATEGORY_TYPE_CODE  = IRHV.CATEGORY_TYPE_CODE
                    AND EOTVERV.END_OF_TERM_ID      = LRFV.END_OF_TERM_ID
                    AND LRFVERV.RATE_SET_ID         = LRFV.ID
                    AND LRFVERV.STS_CODE            = 'ACTIVE'
                    AND IRHV.RESI_CATEGORY_SET_ID   = EOTL.RESI_CATEGORY_SET_ID
                    AND ICPV.ITEM_RESIDUAL_ID       = IRHV.ITEM_RESIDUAL_ID
                    AND NVL(p_icpv_rec.end_date,LRFVERV.EFFECTIVE_FROM_DATE +1) < LRFVERV.EFFECTIVE_FROM_DATE
                    AND LRFVERV.EFFECTIVE_FROM_DATE >= ICPV.START_DATE
                    AND ICPV.ID                     = p_ver_id;

  -- Identifies whether this item residual is for an Item or Item category or a residual category set
  CURSOR get_category_type(p_item_residual_id NUMBER)IS
    SELECT
        CATEGORY_TYPE_CODE
    FROM
        OKL_FE_ITEM_RESIDUAL
    WHERE
         ITEM_RESIDUAL_ID = p_item_residual_id; -- Item residual ID

  -- Cursor to identify change in version effective To date
  CURSOR get_version_date (p_version_id NUMBER) IS
    SELECT
          end_date
      FROM
          OKL_ITM_CAT_RV_PRCS_V
      WHERE
          ID = p_version_id;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.change_LRS_sts';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call change_LRS_sts');
    END IF;


    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
      Select the category type of the item residual.
     */
    OPEN get_category_type(p_icpv_rec.item_residual_id);
      FETCH get_category_type INTO l_src_code;
    CLOSE get_category_type;

    OPEN get_version_date (p_icpv_rec.id);
      FETCH get_version_date INTO l_ver_end_date;
    CLOSE get_version_date;

    i :=1;
    -- Donot query for the LRS versions if the Item Residual version has not been end-dated
    -- This check is ensured by checking the p_icpv_rec.end_date to null and the prior value in db to be null
    IF (p_confirm_yn ='no' AND l_ver_end_date IS NULL AND p_icpv_rec.end_date IS NOT NULL) OR p_confirm_yn = 'yes' THEN
      CASE l_src_code
         WHEN G_CAT_ITEM THEN
           FOR lrs_record IN lrs_itm_csr(p_icpv_rec.id)
           LOOP
             l_lrs_list(i).ID   := lrs_record.LRS_VERSION_ID;
             l_lrs_list(i).NAME := lrs_record.LRS_NAME;
             l_lrs_list(i).VERSION := lrs_record.LRS_VERSION_NUMBER;
             i := i+1;
           END LOOP;
         WHEN G_CAT_ITEM_CAT THEN
           FOR lrs_record IN lrs_itm_cat_csr(p_icpv_rec.id)
           LOOP
             l_lrs_list(i).ID   := lrs_record.LRS_VERSION_ID;
             l_lrs_list(i).NAME := lrs_record.LRS_NAME;
             l_lrs_list(i).VERSION := lrs_record.LRS_VERSION_NUMBER;
             i := i+1;
           END LOOP;
         WHEN G_CAT_RES_CAT THEN
           FOR lrs_record IN lrs_res_cat_csr(p_icpv_rec.id)
           LOOP
             l_lrs_list(i).ID   := lrs_record.LRS_VERSION_ID;
             l_lrs_list(i).NAME := lrs_record.LRS_NAME;
             l_lrs_list(i).VERSION := lrs_record.LRS_VERSION_NUMBER;
             i := i+1;
           END LOOP;
       END CASE;
     END IF; --end of version end date null check

    -- Set out values
    x_lrs_list   := l_lrs_list;
    IF i > 1 THEN
    x_change_sts := 'y';
    ELSE
    x_change_sts := 'n';
    END IF;

    -- Update the status of the LRS if the flag is confirmed
    IF p_confirm_yn ='yes' THEN

     /* Call the API of LRS which in end dating or abandoning the LRS
         with lp_lrtv_tbl as the argument.
      */
     -- Check if the there are any Lease rate sets referencing this item residual
     IF x_change_sts = 'y' THEN

      FOR i IN l_lrs_list.FIRST..l_lrs_list.LAST
      LOOP
       lp_lrtv_tbl(i) := l_lrs_list(i).id;
      END LOOP;

       OKL_LEASE_RATE_SETS_PVT.enddate_lease_rate_set(
                                    p_api_version    => p_api_version
                                  , p_init_msg_list  => p_init_msg_list
                                  , x_return_status  => l_return_status
                                  , x_msg_count      => l_msg_count
                                  , x_msg_data       => l_msg_data
                                  , p_lrv_id_tbl     => lp_lrtv_tbl
                                  , p_end_date       => p_icpv_rec.end_date
                                    );

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;
    END IF; -- End of confirmation check

    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call change_LRS_sts');
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
  END change_LRS_sts;

  -- Returns the status of the header based on the statuses of the versions.
  FUNCTION get_header_status (var_item_residual_id NUMBER) RETURN VARCHAR2 IS
  var_new_sts    BOOLEAN  := TRUE;
  var_active_sts BOOLEAN  := TRUE;
  var_return_sts VARCHAR2(30);
  -- Cursor to retrieve all versions of a residual
  CURSOR all_versions (residual_id NUMBER) IS
    SELECT
          ICPV.STS_CODE STATUS_CODE
      FROM
         OKL_ITM_CAT_RV_PRCS_V ICPV
      WHERE
          ICPV.ITEM_RESIDUAL_ID = residual_id;
  BEGIN

   FOR var_sts IN all_versions(var_item_residual_id)
   LOOP
     IF var_sts.STATUS_CODE <> G_STS_NEW THEN
       var_new_sts := FALSE;
     ELSIF var_sts.STATUS_CODE <> G_STS_ACTIVE THEN
       var_active_sts := FALSE;
     END IF;
   END LOOP;

    IF var_new_sts THEN
        var_return_sts := G_STS_NEW;
     ELSIF var_active_sts THEN
        var_return_sts := G_STS_ACTIVE;
     ELSE
        var_return_sts := G_STS_UNDER_REV;
     END IF;

     RETURN var_return_sts;
  END get_header_status;

  PROCEDURE activate_item_residual(
                         p_api_version           IN         NUMBER
                       , p_init_msg_list         IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status         OUT NOCOPY VARCHAR2
                       , x_msg_count             OUT NOCOPY NUMBER
                       , x_msg_data              OUT NOCOPY VARCHAR2
                       , p_item_resdl_version_id IN         NUMBER  ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'activate_item_residual';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status             VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    l_version_no             VARCHAR2(30) ;
    l_residual_id            NUMBER;
    l_change_sts             VARCHAR2(1) := 'n';
    l_confirm_yn             VARCHAR2(3) := 'yes';

    lp_icpv_curr_rec              okl_icpv_rec;
    lp_icpv_prev_rec              okl_icpv_rec;
    lp_irhv_rec                   okl_irhv_rec;

    lx_icpv_curr_rec              okl_icpv_rec;
    lx_icpv_prev_rec              okl_icpv_rec;
    lx_irhv_rec                   okl_irhv_rec;

    l_lrs_list               lrs_ref_tbl;

    CURSOR get_version_details(var_version_id NUMBER) IS
       SELECT
              ICPV.ITEM_RESIDUAL_ID
            , ICPV.VERSION_NUMBER
            , IRHV.OBJECT_VERSION_NUMBER HDR_OBJECT_VERSION_NUMBER
         FROM
              OKL_ITM_CAT_RV_PRCS    ICPV
            , OKL_FE_ITEM_RESIDUAL IRHV
         WHERE
              IRHV.ITEM_RESIDUAL_ID = ICPV.ITEM_RESIDUAL_ID
          AND ICPV.ID = var_version_id;

    CURSOR get_version_rec(var_residual_id NUMBER, ver_no VARCHAR2) IS
        SELECT
              ICPV.ID                     ID
   	    	, ICPV.OBJECT_VERSION_NUMBER  OBJECT_VERSION_NUMBER
  		    , ICPV.ITEM_RESIDUAL_ID       ITEM_RESIDUAL_ID
      		, ICPV.STS_CODE               STS_CODE
  	     	, ICPV.VERSION_NUMBER         VERSION_NUMBER
      		, ICPV.START_DATE             EFFECTIVE_FROM_DATE
  	     	, ICPV.END_DATE               EFFECTIVE_TO_DATE
          FROM
               OKL_ITM_CAT_RV_PRCS_V ICPV
          WHERE
                ICPV.ITEM_RESIDUAL_ID = var_residual_id
            AND ICPV.VERSION_NUMBER   = ver_no;


   l_version_rec     get_version_rec%ROWTYPE;
   l_version_details get_version_details%ROWTYPE;


  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.activate_item_residual';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call activate_item_residual');
    END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get the residual id and the version number of the version to be approved
    OPEN get_version_details(p_item_resdl_version_id);
      FETCH get_version_details INTO l_version_details ;
    CLOSE get_version_details;

    l_residual_id    := l_version_details.item_residual_id;
    l_version_no     := l_version_details.version_number;

    -- Set the residual id  version number of header
    lp_irhv_rec.item_residual_id      := l_residual_id;
    lp_irhv_rec.object_version_number := l_version_details.hdr_object_version_number;

    -- Get the version details of the version to be approved
    OPEN get_version_rec(l_residual_id, l_version_no );
      FETCH get_version_rec INTO l_version_rec;
    CLOSE get_version_rec;

    lp_icpv_curr_rec.id         := l_version_rec.id;
    lp_icpv_curr_rec.object_version_number   := l_version_rec.object_version_number;
    lp_icpv_curr_rec.start_date := l_version_rec.effective_from_date;
    lp_icpv_curr_rec.end_date   := l_version_rec.effective_to_date;

  --1.Make version status active
    lp_icpv_curr_rec.sts_code := G_STS_ACTIVE;

  --2.put header eff to date as eff to of this version if this is the latest version
    IF is_latest(l_residual_id,l_version_no) THEN
      IF lp_icpv_curr_rec.end_date IS NOT NULL THEN
        lp_irhv_rec.effective_to_date := lp_icpv_curr_rec.end_date;
      ELSE
        -- If it is null, expilcitly assign G_MISS_DATE to update null in table
        lp_irhv_rec.effective_to_date := OKL_API.G_MISS_DATE;
      END IF;
    END IF;

  --3.if this is the first version then dont do the effective_from validation
    --Else Put effective to date of previous version as new ver eff from -1
     IF TO_NUMBER(l_version_no) > 1 THEN
       -- Get the previous version record details
       OPEN get_version_rec(l_residual_id, l_version_no-1 );
        FETCH get_version_rec INTO l_version_rec;
       CLOSE get_version_rec;

      -- end of check for no change in effective TO date
      IF lp_icpv_prev_rec.end_date IS NULL OR (lp_icpv_prev_rec.end_date IS NOT NULL AND lp_icpv_prev_rec.end_date <> lp_icpv_curr_rec.START_DATE -1) THEN
         lp_icpv_prev_rec.id         := l_version_rec.id;
         lp_icpv_prev_rec.object_version_number   := l_version_rec.object_version_number;
         lp_icpv_prev_rec.end_date   := lp_icpv_curr_rec.START_DATE -1;

         -- Update the previous version's effectiveTo date
         OKL_ICP_PVT.update_row(
                     p_api_version   => p_api_version
                   , p_init_msg_list => p_init_msg_list
                   , x_return_status => l_return_status
                   , x_msg_count     => x_msg_count
                   , x_msg_data      => x_msg_data
                   , p_icpv_rec      => lp_icpv_prev_rec
                   , x_icpv_rec      => lx_icpv_prev_rec);
          IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF; -- end of check for no change in effective TO date

       -- Check if the effective to date is already present for the previous version
       IF l_version_rec.effective_to_date IS NULL THEN
          --  End date or Abandon any Lease Rate Sets referencing this Item resiudal
          change_LRS_sts (
                         p_api_version     => p_api_version
                       , p_init_msg_list   => p_init_msg_list
                       , x_return_status   => l_return_status
                       , x_msg_count       => x_msg_count
                       , x_msg_data        => x_msg_count
                       , p_confirm_yn      => l_confirm_yn
                       , p_icpv_rec        => lx_icpv_prev_rec
                       , x_lrs_list        => l_lrs_list
                       , x_change_sts      => l_change_sts
                        );
       END IF; -- End of check for previous end date null

     END IF; -- end of version number check
  -- Update the current version record status
       -- Update the previous version's effectiveTo date
       OKL_ICP_PVT.update_row(
                     p_api_version   => p_api_version
                   , p_init_msg_list => p_init_msg_list
                   , x_return_status => l_return_status
                   , x_msg_count     => x_msg_count
                   , x_msg_data      => x_msg_data
                   , p_icpv_rec      => lp_icpv_curr_rec
                   , x_icpv_rec      => lx_icpv_curr_rec);
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    --4.Set the header status
    lp_irhv_rec.sts_code := get_header_status(l_residual_id);

  --update the header
      OKL_IRH_PVT.update_row(
                	  p_api_version   => p_api_version
                	, p_init_msg_list => p_init_msg_list
                	, x_return_status => l_return_status
                	, x_msg_count     => x_msg_count
                	, x_msg_data      => x_msg_data
                	, p_irhv_rec      => lp_irhv_rec
                	, x_irhv_rec      => lx_irhv_rec);
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
 x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls.pls call activate_item_residual');
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
  END activate_item_residual;

 PROCEDURE submit_item_residual(
     p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status         OUT  NOCOPY VARCHAR2,
     x_msg_count             OUT  NOCOPY NUMBER,
     x_msg_data              OUT  NOCOPY VARCHAR2,
     p_itm_rsdl_version_id   IN   OKL_ITM_CAT_RV_PRCS_V.ID%TYPE
    )IS
  l_api_name             CONSTANT VARCHAR2(65) := 'submit_item_residual';
  l_api_version   CONSTANT NUMBER         := p_api_version;
  lx_return_status                VARCHAR2(1);
  l_parameter_list WF_PARAMETER_LIST_T;
  l_event_name      wf_events.name%TYPE;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.submit_item_residual';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  -- Cusrsor to fetch the Residual ID of the version
  CURSOR get_residual_id(p_itm_rsdl_version_id NUMBER) IS
    SELECT
         ICPV.ITEM_RESIDUAL_ID
      FROM
           OKL_ITM_CAT_RV_PRCS_V ICPV
      WHERE
          ICPV.ID     = p_itm_rsdl_version_id;

  -- Cusrsor to fetch the Source type(also called Category Type)
  CURSOR get_source_type(p_itm_rsdl_id NUMBER) IS
    SELECT
         IRESDV.CATEGORY_TYPE_CODE
      FROM
           OKL_FE_ITEM_RESIDUAL IRESDV
      WHERE
          IRESDV.item_residual_id     = p_itm_rsdl_id;

  -- Cursor to check if the residual category sets are active before Activating the Item Residual
  -- Pass the Item Residual Identifier and the Status as ACTIVE to check for Inactive Residual Category Sets
  CURSOR check_active_resi_cat_sets(p_itm_rsdl_id NUMBER, p_rcs_sts_code VARCHAR2) IS
    SELECT
             RCSV.RESI_CATEGORY_SET_ID ID
           , RCSV.RESI_CAT_NAME        NAME
      FROM
            OKL_FE_RESI_CAT_V RCSV
          , OKL_FE_ITEM_RESIDUAL IRESDV
      WHERE
            IRESDV.CATEGORY_TYPE_CODE   = G_CAT_RES_CAT
        AND IRESDV.RESI_CATEGORY_SET_ID = RCSV.RESI_CATEGORY_SET_ID
        AND RCSV.STS_CODE               <> p_rcs_sts_code
        AND IRESDV.item_residual_id     = p_itm_rsdl_id;

   l_item_residual_id NUMBER;
   l_source_type OKL_FE_ITEM_RESIDUAL_ALL.CATEGORY_TYPE_CODE%TYPE;
   l_rcs_rec  check_active_resi_cat_sets%ROWTYPE;

BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call submit_item_residual');
     END IF;

    lx_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Check if all the Residual category sets of this Item Residual are Active at the time of Submission
    OPEN get_residual_id(p_itm_rsdl_version_id);
      FETCH get_residual_id INTO l_item_residual_id;
    CLOSE get_residual_id;

    OPEN get_source_type (l_item_residual_id);
     FETCH get_source_type INTO l_source_type;
    CLOSE get_source_type;

     IF l_source_type = G_CAT_RES_CAT THEN
       OPEN check_active_resi_cat_sets(l_item_residual_id,G_STS_ACTIVE);
         FETCH check_active_resi_cat_sets INTO l_rcs_rec;
         IF check_active_resi_cat_sets%FOUND THEN
         LOOP
           OKL_API.set_message(p_app_name      => G_APP_NAME,
                               p_msg_name      => 'OKL_RCS_STS_INACTIVE',
                               p_token1        => G_COL_NAME_TOKEN,
                               p_token1_value  => l_rcs_rec.name);
           FETCH check_active_resi_cat_sets INTO l_rcs_rec;
           EXIT WHEN check_active_resi_cat_sets%NOTFOUND;
         END LOOP;
         RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       CLOSE check_active_resi_cat_sets;
     END IF;
 --raise workflow submit event
  l_event_name := G_WF_EVT_IRS_PENDING;

  wf_event.AddParameterToList(G_WF_IRS_VERSION_ID, p_itm_rsdl_version_id, l_parameter_list);
  --added by akrangan
  wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

  -- Check for the AME approval process
  IF NVL(FND_PROFILE.VALUE('OKL_PE_APPROVAL_PROCESS'),'NONE') = 'NONE' THEN
       activate_item_residual(p_api_version,p_init_msg_list,lx_return_status,x_msg_count,x_msg_data,p_itm_rsdl_version_id);
    IF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
	       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ELSE
    OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => lx_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_event_name     => l_event_name,
                           p_parameters     => l_parameter_list);
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  END IF;
    x_return_status := lx_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call submit_item_residual');
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
  END submit_item_residual;

  PROCEDURE create_irs_submit (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'create_irs_submit';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    lp_icpv_rec              okl_icpv_rec  := p_icpv_rec;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.create_irs_submit';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call create_irs_submit');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   -- Set the status changes for the version record.
    lp_icpv_rec.sts_code := G_STS_SUBMITTED;

   /* Check if there is atleast one item or item category or residual category set
    * associated with this item residual.
    */
   IF p_irv_tbl.COUNT = 0 THEN
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                 	    p_msg_name     => 'OKL_ST_IRS_RESIDUALS_MISSING');
    RAISE OKL_API.G_EXCEPTION_ERROR;   END IF;


   -- Call the  create_irs procedure to create the item residual
   create_irs (
              p_api_version      => l_api_version
            , p_init_msg_list    => l_init_msg_list
            , x_return_status    => l_return_status
            , x_msg_count        => l_msg_count
            , x_msg_data         => l_msg_data
            , p_irhv_rec         => p_irhv_rec
            , p_icpv_rec         => lp_icpv_rec
            , p_irv_tbl          => p_irv_tbl
            , x_irhv_rec         => x_irhv_rec
            , x_icpv_rec         => x_icpv_rec
                );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- submit for approval
    submit_item_residual(
                       p_api_version         => l_api_version
                     , p_init_msg_list       => l_init_msg_list
                     , x_return_status       => l_return_status
                     , x_msg_count           => l_msg_count
                     , x_msg_data            => l_msg_data
                     , p_itm_rsdl_version_id => x_icpv_rec.id );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call create_irs_submit');
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
  END create_irs_submit;

  PROCEDURE update_version_irs_submit (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'update_version_irs_submit';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    lp_icpv_rec              okl_icpv_rec  := p_icpv_rec;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.update_version_irs_submit';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call update_version_irs_submit');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- Set the status changes for the version record.
    lp_icpv_rec.sts_code := G_STS_SUBMITTED;

   -- Effective From validation
   IF NOT valid_version_effective_date(lp_icpv_rec.START_DATE, p_irhv_rec.item_residual_id, lp_icpv_rec.version_number) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   /* Check if there is atleast one item or item category or residual category set
    * associated with this item residual.
    */
   IF p_irv_tbl.COUNT = 0 THEN
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                 	    p_msg_name     => 'OKL_ST_IRS_RESIDUALS_MISSING');
    RAISE OKL_API.G_EXCEPTION_ERROR;   END IF;

   -- Call the  update_version_irs procedure to create the item residual
   update_version_irs (
                         p_api_version      => l_api_version
                       , p_init_msg_list    => l_init_msg_list
                       , x_return_status    => l_return_status
                       , x_msg_count        => x_msg_count
                       , x_msg_data         => x_msg_data
                       , p_irhv_rec         => p_irhv_rec
                       , p_icpv_rec         => lp_icpv_rec
                       , p_irv_tbl          => p_irv_tbl
                       , x_irhv_rec         => x_irhv_rec
                       , x_icpv_rec         => x_icpv_rec
                       );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- submit for approval
    submit_item_residual(
                       p_api_version         => l_api_version
                     , p_init_msg_list       => l_init_msg_list
                     , x_return_status       => l_return_status
                     , x_msg_count           => l_msg_count
                     , x_msg_data            => l_msg_data
                     , p_itm_rsdl_version_id => x_icpv_rec.id );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;

	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call update_version_irs_submit');
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
  END update_version_irs_submit;

  PROCEDURE create_version_irs_submit (
                         p_api_version      IN  NUMBER
                       , p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irhv_rec         IN         okl_irhv_rec
                       , p_icpv_rec         IN         okl_icpv_rec
                       , p_irv_tbl          IN         okl_irv_tbl
                       , x_irhv_rec         OUT NOCOPY okl_irhv_rec
                       , x_icpv_rec         OUT NOCOPY okl_icpv_rec
                        ) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'create_version_irs_submit';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    lp_icpv_rec              okl_icpv_rec  := p_icpv_rec;
    l_calc_date              DATE          := NULL;
    l_prev_ver_id            NUMBER;

    CURSOR get_prev_ver(p_item_residual_id NUMBER, p_ver_no NUMBER) IS
      SELECT
           ID
       FROM
          OKL_ITM_CAT_RV_PRCS_V
       WHERE
             ITEM_RESIDUAL_ID = p_item_residual_id
         AND TO_NUMBER(VERSION_NUMBER) = p_ver_no - 1;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.create_version_irs_submit';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call create_version_irs_submit');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- Set the status changes for the version record.
    lp_icpv_rec.sts_code := G_STS_SUBMITTED;

   -- Effective From validation
   IF NOT valid_version_effective_date(lp_icpv_rec.START_DATE, p_irhv_rec.item_residual_id, lp_icpv_rec.version_number) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   IF lp_icpv_rec.version_number > 1 THEN
     OPEN get_prev_ver(p_irhv_rec.item_residual_id, TO_NUMBER(lp_icpv_rec.version_number));
       FETCH get_prev_ver INTO l_prev_ver_id;
     CLOSE get_prev_ver;

     /* Calculate the effective date */
     get_effective_date(
                      l_api_version
                    , l_init_msg_list
                    , l_return_status
                    , x_msg_count
                    , x_msg_data
                    , l_prev_ver_id
                    , l_calc_date
                       );

      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      /*
       *  Check if end dating the previous version is valid
       *  by checking the calculated date with the new version's start date.
       */
      IF l_calc_date > lp_icpv_rec.start_date THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_PRIOR_EFFECTIVE_FROM',
                          p_token1       => 'EFF_FROM',
                          p_token1_value => l_calc_date);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   END IF; -- end of version check

   /* Check if there is atleast one item or item category or residual category set
    * associated with this item residual.
    */
   IF p_irv_tbl.COUNT = 0 THEN
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                 	    p_msg_name     => 'OKL_ST_IRS_RESIDUALS_MISSING');
    RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Call the  update_version_irs procedure to create the item residual
   create_version_irs (
                         p_api_version      => l_api_version
                       , p_init_msg_list    => l_init_msg_list
                       , x_return_status    => l_return_status
                       , x_msg_count        => x_msg_count
                       , x_msg_data         => x_msg_data
                       , p_irhv_rec         => p_irhv_rec
                       , p_icpv_rec         => lp_icpv_rec
                       , p_irv_tbl          => p_irv_tbl
                       , x_irhv_rec         => x_irhv_rec
                       , x_icpv_rec         => x_icpv_rec
                       );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- submit for approval
    submit_item_residual(
                       p_api_version         => l_api_version
                     , p_init_msg_list       => l_init_msg_list
                     , x_return_status       => l_return_status
                     , x_msg_count           => l_msg_count
                     , x_msg_data            => l_msg_data
                     , p_itm_rsdl_version_id => x_icpv_rec.id );
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call create_version_irs_submit');
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
  END create_version_irs_submit;

PROCEDURE remove_terms(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_irv_tbl          IN         okl_irv_tbl) IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'remove_terms';
    l_api_version   NUMBER         := p_api_version;
    l_init_msg_list VARCHAR2(1)    := p_init_msg_list;
    l_return_status VARCHAR2(1)    := x_return_status;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_ITEM_RESIDUALS_PVT.remove_terms';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRIRSB.pls call remove_terms');
     END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_IRV_PVT.delete_row(
        	 p_api_version   => l_api_version,
        	 p_init_msg_list => l_init_msg_list,
        	 x_return_status => l_return_status,
        	 x_msg_count	 => x_msg_count,
        	 x_msg_data		 => x_msg_data,
        	 p_irv_tbl		 => p_irv_tbl);

    x_return_status := l_return_status;

	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRIRSB.pls call remove_terms');
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
END remove_terms;

END OKL_ITEM_RESIDUALS_PVT; -- End of package Body

/

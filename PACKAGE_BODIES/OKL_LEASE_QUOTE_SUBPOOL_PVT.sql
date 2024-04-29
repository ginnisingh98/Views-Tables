--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_SUBPOOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_SUBPOOL_PVT" AS
/* $Header: OKLRQUYB.pls 120.13 2006/04/25 00:39:55 rravikir noship $ */

  ----------------------------------
  -- PROCEDURE check_initial_record
  ----------------------------------
  FUNCTION check_initial_record (p_object_id               IN  NUMBER,
                                 p_source_object_code      IN  VARCHAR2,
                                 p_subsidy_pool_id         IN  NUMBER,
							     x_return_status           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS

    l_program_name         CONSTANT VARCHAR2(30) := 'check_initial_record';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_status            VARCHAR2(1);
    lv_obj_code         VARCHAR2(30);

	CURSOR c_check_record_exists(p_obj_code IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okl_quote_subpool_usage
    WHERE  source_object_id = p_object_id
    AND source_type_code = p_obj_code
    AND subsidy_pool_id = p_subsidy_pool_id;
  BEGIN
    IF (p_source_object_code = 'LEASEOPP') THEN
      lv_obj_code := 'SALES_QUOTE';
    ELSE
      lv_obj_code := 'LEASE_APPLICATION';
    END IF;
    OPEN  c_check_record_exists(p_obj_code => lv_obj_code);
    FETCH c_check_record_exists into l_status;
    CLOSE c_check_record_exists;

    IF (l_status = 'Y') THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_initial_record;

  ----------------------------------
  -- PROCEDURE check_leaseopp_quote
  ----------------------------------
  FUNCTION check_leaseopp_quote (p_lease_app_id            IN  NUMBER,
							     x_return_status           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS

    l_program_name         CONSTANT VARCHAR2(30) := 'check_leaseopp_quote';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_count             Number(1);

  BEGIN
 --Begin -Updated the Select stmt with Count for bug#4723160 - varangan-8-11-2005
    Select Count(1)
    Into L_count
    From OKL_LEASE_APPLICATIONS_B
    WHERE  LEASE_OPPORTUNITY_ID IS NOT NULL
    AND    ID = p_lease_app_id;

    IF (l_count = 0) THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
 --End - Updated the Select stmt with Count for bug#4723160 - varangan-8-11-2005

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_leaseopp_quote;
  ----------------------------------
  -- PROCEDURE check_fresh_lease_app
  ----------------------------------
  FUNCTION check_fresh_lease_app (p_lease_app_id            IN  NUMBER,
							     x_return_status           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS

    l_program_name         CONSTANT VARCHAR2(30) := 'check_fresh_lease_app';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_parent_id             Number := NULL;
    l_is_parent             VARCHAR2(3) := 'N';
    CURSOR get_parent_laps IS
     Select PARENT_LEASEAPP_ID
     From OKL_LEASE_APPLICATIONS_B
     WHERE  ID = p_lease_app_id;

    CURSOR get_child_laps IS
     SELECT 'Y'
     FROM OKL_LEASE_APPLICATIONS_B
     WHERE parent_leaseapp_id = p_lease_app_id;

  BEGIN
    --is the lap having parent ?
    OPEN get_parent_laps;
    FETCH get_parent_laps INTO l_parent_id;
    CLOSE get_parent_laps;
    --is the lap parent of other lap ?
    OPEN get_child_laps;
    FETCH get_child_laps INTO l_is_parent;
    CLOSE get_child_laps;

    IF (l_parent_id IS NOT NULL OR l_is_parent = 'Y') THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_fresh_lease_app;

  ----------------------------------------
  -- PROCEDURE create_quote_subpool_usage
  ----------------------------------------
  PROCEDURE create_quote_subpool_usage(p_api_version   IN  NUMBER,
                                       p_init_msg_list IN  VARCHAR2,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count     OUT NOCOPY NUMBER,
                                       x_msg_data      OUT NOCOPY VARCHAR2,
                                       p_sixv_tbl      IN subsidy_pool_tbl_type) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_quote_subpool_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_quote_sp_usage_tbl    quote_sp_usage_tbl_type;
    lx_quote_sp_usage_tbl   quote_sp_usage_tbl_type;
    l_subpool_tbl           subsidy_pool_tbl_type;

  BEGIN
    l_subpool_tbl := p_sixv_tbl;

    FOR i IN l_subpool_tbl.FIRST .. l_subpool_tbl.LAST LOOP
      IF l_subpool_tbl.EXISTS(i) THEN
        l_quote_sp_usage_tbl(i).subpool_trx_id := l_subpool_tbl(i).id;
        l_quote_sp_usage_tbl(i).source_type_code := l_subpool_tbl(i).source_type_code;
        l_quote_sp_usage_tbl(i).source_object_id := l_subpool_tbl(i).source_object_id;
        l_quote_sp_usage_tbl(i).asset_number := l_subpool_tbl(i).dnz_asset_number;
        l_quote_sp_usage_tbl(i).asset_start_date := l_subpool_tbl(i).source_trx_date;
        l_quote_sp_usage_tbl(i).subsidy_pool_id := l_subpool_tbl(i).subsidy_pool_id;
        l_quote_sp_usage_tbl(i).subsidy_pool_amount := l_subpool_tbl(i).subsidy_pool_amount;
        l_quote_sp_usage_tbl(i).subsidy_pool_currency_code := l_subpool_tbl(i).subsidy_pool_currency_code;
        l_quote_sp_usage_tbl(i).subsidy_id := l_subpool_tbl(i).subsidy_id;
        l_quote_sp_usage_tbl(i).subsidy_amount := l_subpool_tbl(i).trx_amount;
        l_quote_sp_usage_tbl(i).subsidy_currency_code := l_subpool_tbl(i).trx_currency_code;
        l_quote_sp_usage_tbl(i).vendor_id := l_subpool_tbl(i).vendor_id;
        l_quote_sp_usage_tbl(i).conversion_rate := l_subpool_tbl(i).conversion_rate;
      END IF;
    END LOOP;

    IF (l_quote_sp_usage_tbl.COUNT > 0) THEN
      okl_qul_pvt.insert_row (  p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_qulv_tbl      => l_quote_sp_usage_tbl
                               ,x_qulv_tbl      => lx_quote_sp_usage_tbl);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_quote_subpool_usage;

  ----------------------------------------
  -- PROCEDURE delete_quote_subpool_usage
  ----------------------------------------
  PROCEDURE delete_quote_subpool_usage(p_api_version   IN  NUMBER,
                                       p_init_msg_list IN  VARCHAR2,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count     OUT NOCOPY NUMBER,
                                       x_msg_data      OUT NOCOPY VARCHAR2,
                                       p_subsidy_pool_id  IN NUMBER,
                                       p_source_object_id IN NUMBER) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_quote_subpool_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_quote_sp_usage_tbl    quote_sp_usage_tbl_type;
    i                       BINARY_INTEGER := 0;

    CURSOR c_get_quote_subpool_usage IS
    SELECT ID
    FROM   OKL_QUOTE_SUBPOOL_USAGE
    WHERE  SUBSIDY_POOL_ID = p_subsidy_pool_id
    AND    SOURCE_OBJECT_ID = p_source_object_id;
  BEGIN
    FOR l_get_quote_subpool_usage IN c_get_quote_subpool_usage LOOP
      l_quote_sp_usage_tbl(i).id := l_get_quote_subpool_usage.id;
      i := i + 1;
    END LOOP;

    IF (l_quote_sp_usage_tbl.COUNT > 0) THEN
      okl_qul_pvt.delete_row (  p_api_version   => G_API_VERSION
                               ,p_init_msg_list => G_FALSE
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_qulv_tbl      => l_quote_sp_usage_tbl);
      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_quote_subpool_usage;

  ----------------------------------------
  -- PROCEDURE fetch_quote_subpool_usage
  ----------------------------------------
  PROCEDURE fetch_quote_subpool_usage(p_subsidy_pool_id  IN NUMBER,
                                      p_quote_id      IN NUMBER,
                                      x_subpool_tbl   OUT NOCOPY subsidy_pool_tbl_type,
                                      x_return_status OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'fetch_quote_subpool_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_subpool_tbl    subsidy_pool_tbl_type;
    i                       BINARY_INTEGER := 0;

    CURSOR c_get_quote_subpool_usage IS
    SELECT SOURCE_TYPE_CODE,
           SOURCE_OBJECT_ID,
           ASSET_NUMBER,
           ASSET_START_DATE,
           SUBSIDY_POOL_ID,
           SUBSIDY_POOL_AMOUNT,
           SUBSIDY_POOL_CURRENCY_CODE,
           SUBSIDY_ID,
           SUBSIDY_AMOUNT,
           SUBSIDY_CURRENCY_CODE,
           VENDOR_ID,
           CONVERSION_RATE
    FROM   OKL_QUOTE_SUBPOOL_USAGE
    WHERE  SUBSIDY_POOL_ID = p_subsidy_pool_id
    AND    SOURCE_OBJECT_ID = p_quote_id;

  BEGIN
    FOR l_get_quote_subpool_usage IN c_get_quote_subpool_usage LOOP
      l_subpool_tbl(i).source_type_code := l_get_quote_subpool_usage.source_type_code;
      l_subpool_tbl(i).source_object_id := l_get_quote_subpool_usage.source_object_id;
      l_subpool_tbl(i).dnz_asset_number := l_get_quote_subpool_usage.asset_number;
      l_subpool_tbl(i).source_trx_date := l_get_quote_subpool_usage.asset_start_date;
      l_subpool_tbl(i).subsidy_pool_id := l_get_quote_subpool_usage.subsidy_pool_id ;
      l_subpool_tbl(i).subsidy_pool_amount := l_get_quote_subpool_usage.subsidy_pool_amount;
      l_subpool_tbl(i).subsidy_pool_currency_code := l_get_quote_subpool_usage.subsidy_pool_currency_code;
      l_subpool_tbl(i).subsidy_id := l_get_quote_subpool_usage.subsidy_id;
      l_subpool_tbl(i).trx_amount := l_get_quote_subpool_usage.subsidy_amount;
      l_subpool_tbl(i).trx_currency_code := l_get_quote_subpool_usage.subsidy_currency_code;
      l_subpool_tbl(i).vendor_id := l_get_quote_subpool_usage.vendor_id;
      l_subpool_tbl(i).conversion_rate := l_get_quote_subpool_usage.conversion_rate;

      i := i + 1;
    END LOOP;

    x_subpool_tbl := l_subpool_tbl;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END fetch_quote_subpool_usage;
  ----------------------------------------
  -- PROCEDURE get_linked_lop_maxsp_usage
  ----------------------------------------
  PROCEDURE get_linked_lop_maxsp_usage( p_subsidy_pool_id  IN NUMBER,
                                        p_lop_id           IN NUMBER,
                                        p_quote_id         IN NUMBER,
                                        x_max_usage_qte_id OUT NOCOPY NUMBER,
                                        x_max_usage_amt    OUT NOCOPY NUMBER,
                                        x_return_status    OUT NOCOPY VARCHAR2
                                        )IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_linked_lop_maxsp_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_first                         BOOLEAN;
        l_max_amt                       NUMBER;

    CURSOR c_get_quote_subpool_usage IS
    SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS = 'PR-APPROVED'
     AND QUOTE.PARENT_OBJECT_ID = p_lop_id
     AND QUOTE.ID <> p_quote_id
     AND SUB_POOL.ID = p_subsidy_pool_id
     group by SUB.SUBSIDY_POOL_ID ,QUOTE.ID;
  BEGIN
     x_max_usage_qte_id := null;
     x_max_usage_amt  := null;
     l_first := true;
     FOR l_get_quote_subpool_usage IN c_get_quote_subpool_usage LOOP
       IF l_first THEN
         x_max_usage_qte_id := l_get_quote_subpool_usage.quote_id;
         x_max_usage_amt  := l_get_quote_subpool_usage.amount;
         l_max_amt := l_get_quote_subpool_usage.amount;
         l_first := false;
       ELSIF l_max_amt < l_get_quote_subpool_usage.amount THEN
         x_max_usage_qte_id := l_get_quote_subpool_usage.quote_id;
         x_max_usage_amt  := l_get_quote_subpool_usage.amount;
         l_max_amt := l_get_quote_subpool_usage.amount;
       END IF;
     END LOOP;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_linked_lop_maxsp_usage;

  ----------------------------------------
  -- PROCEDURE get_linked_lop_maxsp_usage
  ----------------------------------------
  PROCEDURE get_linked_lap_maxsp_usage( p_subsidy_pool_id  IN NUMBER,
                                        p_lap_id           IN NUMBER,
                                        p_current_qte_id   IN NUMBER,
                                        p_transaction      IN VARCHAR2,
                                        x_max_usage_qte_id OUT NOCOPY NUMBER,
                                        x_max_usage_amt    OUT NOCOPY NUMBER,
                                        x_return_status    OUT NOCOPY VARCHAR2
                                        )IS

    l_program_name         CONSTANT VARCHAR2(30) := 'get_linked_lap_maxsp_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_first                         BOOLEAN;
    l_max_amt                       NUMBER;

    CURSOR c_get_linked_laps
    IS
      SELECT ID
           , REFERENCE_NUMBER
           , APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B
      WHERE application_Status NOT IN ('CANCELED','WITHDRAWN')
      CONNECT BY PARENT_LEASEAPP_ID = PRIOR ID
      START WITH ID = p_lap_id
   UNION
      SELECT ID
           , REFERENCE_NUMBER
           , APPLICATION_STATUS
      FROM OKL_LEASE_APPLICATIONS_B
      WHERE ID <> p_lap_id
      AND application_Status NOT IN ('CANCELED','WITHDRAWN')
      CONNECT BY PRIOR PARENT_LEASEAPP_ID = ID
      START WITH ID = p_lap_id;

    CURSOR c_get_quotesandoffers_in_lap(p_lease_app_id IN NUMBER) IS
    SELECT  QUOTE.ID QUOTE_ID
     FROM OKL_LEASE_QUOTES_V QUOTE
     WHERE QUOTE.STATUS IN ( 'PR-APPROVED','CT-ACCEPTED','CR-RECOMMENDATION')
     AND QUOTE.ID <> p_current_qte_id
     AND QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
     AND QUOTE.PARENT_OBJECT_ID = p_lease_app_id;

    CURSOR c_get_quote_subpool_usage(p_qte_id IN NUMBER) IS
    SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_V QUOTE,
          OKL_LEASE_APPLICATIONS_B LAP
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS IN ( 'PR-APPROVED','CT-ACCEPTED','CR-RECOMMENDATION')
     AND QUOTE.ID <> p_current_qte_id
     AND QUOTE.ID = p_qte_id
     AND QUOTE.PARENT_OBJECT_ID = LAP.ID
     AND QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
     AND SUB_POOL.ID = p_subsidy_pool_id
     group by SUB.SUBSIDY_POOL_ID ,QUOTE.ID;

    CURSOR c_wd_get_quotesoffers_in_lap(p_lease_app_id IN NUMBER) IS
    SELECT  QUOTE.ID QUOTE_ID
     FROM OKL_LEASE_QUOTES_V QUOTE
     WHERE QUOTE.STATUS IN ( 'PR-APPROVED','CT-ACCEPTED','CR-RECOMMENDATION')
     AND QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
     AND QUOTE.PARENT_OBJECT_ID = p_lease_app_id;

    CURSOR c_wd_get_quote_subpool_usage(p_qte_id IN NUMBER) IS
    SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_V QUOTE,
          OKL_LEASE_APPLICATIONS_B LAP
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS IN ( 'PR-APPROVED','CT-ACCEPTED','CR-RECOMMENDATION')
     AND QUOTE.ID = p_qte_id
     AND QUOTE.PARENT_OBJECT_ID = LAP.ID
     AND QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
     AND SUB_POOL.ID = p_subsidy_pool_id
     group by SUB.SUBSIDY_POOL_ID ,QUOTE.ID;

  BEGIN
     x_max_usage_qte_id := null;
     x_max_usage_amt  := null;
     l_first := true;
     --for all linked laps

     IF (p_transaction = 'WITHDRAW_LEASE_APP') THEN
       FOR l_linked_lap IN c_get_linked_laps LOOP

        IF p_current_qte_id IS NOT NULL OR
          (p_current_qte_id IS NULL AND l_linked_lap.ID <> p_lap_id ) THEN
          -- dbms_output.put_line(' Into If Loop .. ');
            -- for all quotes and offers in lap
             FOR l_lap_qtes_offers IN c_wd_get_quotesoffers_in_lap(l_linked_lap.ID) LOOP
                 FOR l_get_quote_subpool_usage IN c_wd_get_quote_subpool_usage(l_lap_qtes_offers.quote_id) LOOP

                   IF l_first THEN
                     x_max_usage_qte_id := l_get_quote_subpool_usage.quote_id;
                     x_max_usage_amt  := l_get_quote_subpool_usage.amount;
                     l_max_amt := l_get_quote_subpool_usage.amount;
                     l_first := false;
                   ELSIF l_max_amt < l_get_quote_subpool_usage.amount THEN
                     x_max_usage_qte_id := l_get_quote_subpool_usage.quote_id;
                     x_max_usage_amt  := l_get_quote_subpool_usage.amount;
                     l_max_amt := l_get_quote_subpool_usage.amount;
                   END IF;
                 END LOOP;
              END LOOP;
         END IF;
      END LOOP;
    ELSE
      FOR l_linked_lap IN c_get_linked_laps LOOP
        IF p_current_qte_id IS NOT NULL OR
          (p_current_qte_id IS NULL AND l_linked_lap.ID <> p_lap_id ) THEN
          -- dbms_output.put_line(' Into If Loop .. ');
            -- for all quotes and offers in lap
             FOR l_lap_qtes_offers IN c_get_quotesandoffers_in_lap(l_linked_lap.ID) LOOP
                 FOR l_get_quote_subpool_usage IN c_get_quote_subpool_usage(l_lap_qtes_offers.quote_id) LOOP

                   IF l_first THEN
                     x_max_usage_qte_id := l_get_quote_subpool_usage.quote_id;
                     x_max_usage_amt  := l_get_quote_subpool_usage.amount;
                     l_max_amt := l_get_quote_subpool_usage.amount;
                     l_first := false;
                   ELSIF l_max_amt < l_get_quote_subpool_usage.amount THEN
                     x_max_usage_qte_id := l_get_quote_subpool_usage.quote_id;
                     x_max_usage_amt  := l_get_quote_subpool_usage.amount;
                     l_max_amt := l_get_quote_subpool_usage.amount;
                   END IF;
                 END LOOP;
              END LOOP;
         END IF;
      END LOOP;
    END IF;
    -- dbms_output.put_line('Max Usage Quote '||x_max_usage_qte_id);
    -- dbms_output.put_line('Max Usage Amount '||x_max_usage_amt);
    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_linked_lap_maxsp_usage;
  ----------------------------------------
  -- PROCEDURE create_subpool_trx_and_usage
  ----------------------------------------
  PROCEDURE create_subpool_trx_and_usage(p_api_version         IN  NUMBER,
                                         p_init_msg_list       IN  VARCHAR2,
                                         x_return_status       OUT NOCOPY VARCHAR2,
                                         x_msg_count           OUT NOCOPY NUMBER,
                                         x_msg_data            OUT NOCOPY VARCHAR2,
                                         p_source_object_code  IN  VARCHAR2,
                                         p_quote_id            IN  NUMBER,
                                         p_subsidy_pool_id     IN  NUMBER,
                                         p_transaction_reason  IN  VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_subpool_trx_and_usage';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_sub_pool_tbl           subsidy_pool_tbl_type;
    lx_subpool_tbl           subsidy_pool_tbl_type;

    i                        BINARY_INTEGER := 0;

    CURSOR c_get_quote_subsidy_info(p_subsidy_pool_id  IN NUMBER) IS
    SELECT ADJ.ADJUSTMENT_SOURCE_ID SUBSIDY_ID,
           DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE) VALUE,
           ADJ.SUPPLIER_ID,
           ASSET.ASSET_NUMBER,
           QUOTE.EXPECTED_START_DATE,
           SUB.CURRENCY_CODE SUB_CURRENCY_CODE,
           SUB_POOL.CURRENCY_CODE SUBPOOL_CURRENCY_CODE,
--           SUB_POOL.CURRENCY_CONVERSION_TYPE,
           SUB_POOL.TOTAL_SUBSIDY_AMOUNT
    FROM OKL_COST_ADJUSTMENTS_B ADJ,
         OKL_SUBSIDIES_B SUB,
         OKL_SUBSIDY_POOLS_B SUB_POOL,
         OKL_ASSETS_B ASSET,
         OKL_LEASE_QUOTES_B QUOTE
    WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
    AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
    AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
    AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
    AND ADJ.PARENT_OBJECT_ID = ASSET.ID
    AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
    AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
    AND QUOTE.ID = p_quote_id
    AND SUB_POOL.ID = p_subsidy_pool_id;

  BEGIN

    FOR l_get_quote_subsidy_info IN c_get_quote_subsidy_info(p_subsidy_pool_id  => p_subsidy_pool_id) LOOP
      l_sub_pool_tbl(i).subsidy_id := l_get_quote_subsidy_info.subsidy_id;
      l_sub_pool_tbl(i).trx_amount := l_get_quote_subsidy_info.value;
      l_sub_pool_tbl(i).vendor_id :=  l_get_quote_subsidy_info.supplier_id;
      l_sub_pool_tbl(i).dnz_asset_number := l_get_quote_subsidy_info.asset_number;
      l_sub_pool_tbl(i).source_trx_date := l_get_quote_subsidy_info.expected_start_date;
      l_sub_pool_tbl(i).trx_currency_code := l_get_quote_subsidy_info.sub_currency_code;
      l_sub_pool_tbl(i).subsidy_pool_currency_code := l_get_quote_subsidy_info.subpool_currency_code;
      l_sub_pool_tbl(i).subsidy_pool_amount := l_get_quote_subsidy_info.total_subsidy_amount;

      l_sub_pool_tbl(i).trx_type_code := 'REDUCTION';
      IF (p_source_object_code = 'LEASEOPP') THEN
        l_sub_pool_tbl(i).source_type_code := 'SALES_QUOTE';
      ELSE
        l_sub_pool_tbl(i).source_type_code := 'LEASE_APPLICATION';
      END IF;
      l_sub_pool_tbl(i).source_object_id := p_quote_id;
      l_sub_pool_tbl(i).subsidy_pool_id := p_subsidy_pool_id;
      l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;

      i := i + 1;
    END LOOP;

    IF (l_sub_pool_tbl.COUNT > 0) THEN
      -- Create the transaction record in the Subsidy pool
      okl_subsidy_pool_trx_pvt.create_pool_transaction
                                    (p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_sixv_tbl      => l_sub_pool_tbl,
                                     x_sixv_tbl      => lx_subpool_tbl);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Create the transaction copy record in quote subsidy pool usage table
      create_quote_subpool_usage(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_sixv_tbl      => lx_subpool_tbl);

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_subpool_trx_and_usage;

  ----------------------------------------
  -- PROCEDURE handle_quote_pools
  ----------------------------------------
  PROCEDURE handle_quote_pools (p_api_version         IN  NUMBER,
			                       p_init_msg_list       IN  VARCHAR2,
                                   p_quote_id            IN  NUMBER,
                                   p_transaction_reason  IN  VARCHAR2,
                                   p_parent_object_id    IN  NUMBER,
                                   p_parent_object_code  IN  VARCHAR2,
							       x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                          		   x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_quote_pools';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseopp_max_pool_values(p_subsidy_pool_id  IN NUMBER) IS
    SELECT QUOTE_ID,
           SUBSIDY_POOL_ID,
           MAX(AMOUNT) AMOUNT
    FROM
    (SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS = 'PR-APPROVED'
     AND QUOTE.PARENT_OBJECT_ID = p_parent_object_id
     AND QUOTE.ID <> p_quote_id
     AND SUB_POOL.ID = p_subsidy_pool_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID)
     WHERE (SUBSIDY_POOL_ID, AMOUNT)
     IN
     (SELECT SUBSIDY_POOL_ID,
             MAX(AMOUNT) AMOUNT
      FROM
      (SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
              SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
              QUOTE.ID QUOTE_ID
       FROM OKL_COST_ADJUSTMENTS_B ADJ,
            OKL_SUBSIDIES_B SUB,
            OKL_SUBSIDY_POOLS_B SUB_POOL,
            OKL_ASSETS_B ASSET,
            OKL_LEASE_QUOTES_B QUOTE
       WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
       AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
       AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
       AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
       AND ADJ.PARENT_OBJECT_ID = ASSET.ID
       AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
       AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
       AND QUOTE.STATUS = 'PR-APPROVED'
       AND QUOTE.PARENT_OBJECT_ID = p_parent_object_id
       AND QUOTE.ID <> p_quote_id
       AND SUB_POOL.ID = p_subsidy_pool_id
       GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID)
      GROUP BY SUBSIDY_POOL_ID)
     GROUP BY SUBSIDY_POOL_ID, QUOTE_ID;

	CURSOR c_get_quote_pool_values IS
    SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
           SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT
    FROM OKL_COST_ADJUSTMENTS_B ADJ,
         OKL_SUBSIDIES_B SUB,
         OKL_SUBSIDY_POOLS_B SUB_POOL,
         OKL_ASSETS_B ASSET,
         OKL_LEASE_QUOTES_B QUOTE
    WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
    AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
    AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
    AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
    AND ADJ.PARENT_OBJECT_ID = ASSET.ID
    AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
    AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
    AND QUOTE.STATUS = 'PR-APPROVED'
    AND QUOTE.ID = p_quote_id
    GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    lv_inital_record_exists             VARCHAR2(1) := 'N';
    ln_max_subsidy_amount               NUMBER;
    ln_populated_quote_id               NUMBER;
    lb_is_this_max_amount               BOOLEAN  :=  TRUE;

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

    FOR l_get_quote_pool_values IN c_get_quote_pool_values LOOP
      ln_max_subsidy_amount := l_get_quote_pool_values.amount;
      lb_is_this_max_amount := TRUE;

      FOR l_get_leaseopp_max_pool_values IN c_get_leaseopp_max_pool_values(p_subsidy_pool_id => l_get_quote_pool_values.subsidy_pool_id) LOOP
        ln_populated_quote_id := l_get_leaseopp_max_pool_values.quote_id;
        IF (l_get_leaseopp_max_pool_values.amount > ln_max_subsidy_amount) THEN
          lb_is_this_max_amount := FALSE;
          EXIT;
        END IF;
      END LOOP;

      IF (lb_is_this_max_amount) THEN

        -- Check if this quote is already populated in the quote usage table, by
        -- comparing against the new quote id
        -- "lv_inital_record_exists" checks if the quote is approved for the first
        -- time in the lease opportunity. If so, it directly goes to else loop and
        -- creates the initial record, otherwise it checks with the new quote being
        -- approved
        IF ((ln_populated_quote_id IS NOT NULL) AND (ln_populated_quote_id <> p_quote_id)) THEN
          lv_inital_record_exists  := check_initial_record(p_object_id          => ln_populated_quote_id,
                                                           p_source_object_code => p_parent_object_code,
                                                           p_subsidy_pool_id    => l_get_quote_pool_values.subsidy_pool_id,
                   				                           x_return_status      => x_return_status);
        END IF;

        IF (lv_inital_record_exists = 'Y') THEN
          -- Record already exists in the transaction record. So, add the previous
          -- balance, and reduce the new subsidy amount

          -- Fetch the data from Quote Subsidy pool usage
          l_sub_pool_tbl.delete;
          fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_quote_pool_values.subsidy_pool_id,
                                    p_quote_id         => ln_populated_quote_id,
                                    x_subpool_tbl      => l_sub_pool_tbl,
                                    x_return_status    => x_return_status);

          FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
            IF l_sub_pool_tbl.EXISTS(i) THEN
              l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
              l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
            END IF;
          END LOOP;

          -- Add the previous balance to the Subsidy pool
          IF (l_sub_pool_tbl.COUNT > 0) THEN
            okl_subsidy_pool_trx_pvt.create_pool_transaction
                                    (p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_sixv_tbl      => l_sub_pool_tbl,
                                     x_sixv_tbl      => lx_subpool_tbl);

            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          -- Delete the Quote usage data for this Subsidy pool
          delete_quote_subpool_usage(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_subsidy_pool_id  => l_get_quote_pool_values.subsidy_pool_id,
                                     p_source_object_id => ln_populated_quote_id);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- Reduce the new balance from the Subsidy pool and create the current
          -- data in Quote Subsidy pool usage
          create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                       p_init_msg_list       => p_init_msg_list,
                                       x_return_status       => x_return_status,
                                       x_msg_count           => x_msg_count,
                                       x_msg_data            => x_msg_data,
                                       p_source_object_code  => p_parent_object_code,
                                       p_quote_id            => p_quote_id,
                                       p_subsidy_pool_id     => l_get_quote_pool_values.subsidy_pool_id,
                                       p_transaction_reason  => p_transaction_reason);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSE
          -- This is the initial transaction record. So, reduce the same from the
          -- Subsidy pool and create the data in Quote Subsidy pool usage
          create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                       p_init_msg_list       => p_init_msg_list,
                                       x_return_status       => x_return_status,
                                       x_msg_count           => x_msg_count,
                                       x_msg_data            => x_msg_data,
                                       p_source_object_code  => p_parent_object_code,
                                       p_quote_id            => p_quote_id,
                                       p_subsidy_pool_id     => l_get_quote_pool_values.subsidy_pool_id,
                                       p_transaction_reason  => p_transaction_reason);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_quote_pools;

  ----------------------------------------
  -- PROCEDURE handle_cancel_leaseopp
  ----------------------------------------
  PROCEDURE handle_cancel_leaseopp (p_api_version         IN  NUMBER,
			                        p_init_msg_list       IN  VARCHAR2,
                                    p_transaction_reason  IN  VARCHAR2,
                                    p_parent_object_id    IN  NUMBER,
							        x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                          		    x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_cancel_leaseopp';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseopp_pool_values IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS = 'PR-APPROVED'
     AND QUOTE.PARENT_OBJECT_ID = p_parent_object_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    ln_count                    NUMBER;

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

    FOR l_get_leaseopp_pool_values IN c_get_leaseopp_pool_values LOOP

      SELECT COUNT(*)
      INTO ln_count
      FROM   OKL_QUOTE_SUBPOOL_USAGE
      WHERE  SUBSIDY_POOL_ID = l_get_leaseopp_pool_values.subsidy_pool_id
      AND    SOURCE_OBJECT_ID = l_get_leaseopp_pool_values.quote_id;

      IF (ln_count > 0) THEN    -- The Subsidy pool is highest for a Quote

        -- Fetch the data from Quote Subsidy pool usage
        l_sub_pool_tbl.delete;
        fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_leaseopp_pool_values.subsidy_pool_id,
                                  p_quote_id         => l_get_leaseopp_pool_values.quote_id,
                                  x_subpool_tbl      => l_sub_pool_tbl,
                                  x_return_status    => x_return_status);

        FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
          IF l_sub_pool_tbl.EXISTS(i) THEN
            l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
            l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
          END IF;
        END LOOP;

        -- Add the previous balance to the Subsidy pool
        IF (l_sub_pool_tbl.COUNT > 0) THEN
          okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- Delete the Quote usage data for this Subsidy pool
        delete_quote_subpool_usage(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_subsidy_pool_id  => l_get_leaseopp_pool_values.subsidy_pool_id,
                                   p_source_object_id => l_get_leaseopp_pool_values.quote_id);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_cancel_leaseopp;

  ----------------------------------------
  -- PROCEDURE handle_quote_contract
  ----------------------------------------
  PROCEDURE handle_quote_contract (p_api_version         IN  NUMBER,
                                   p_init_msg_list       IN  VARCHAR2,
                                   p_transaction_reason  IN  VARCHAR2,
                                   p_quote_id            IN  NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_quote_contract';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseopp_pool_values IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS = 'PR-APPROVED'
     AND QUOTE.PARENT_OBJECT_ID = (SELECT PARENT_OBJECT_ID
                                   FROM OKL_LEASE_QUOTES_B
                                   WHERE ID = p_quote_id)
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    ln_count                    NUMBER;

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

    FOR l_get_leaseopp_pool_values IN c_get_leaseopp_pool_values LOOP

      SELECT COUNT(*)
      INTO ln_count
      FROM   OKL_QUOTE_SUBPOOL_USAGE
      WHERE  SUBSIDY_POOL_ID = l_get_leaseopp_pool_values.subsidy_pool_id
      AND    SOURCE_OBJECT_ID = l_get_leaseopp_pool_values.quote_id;

      IF (ln_count > 0) THEN    -- The Subsidy pool is highest for a Quote

        -- Fetch the data from Quote Subsidy pool usage
        fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_leaseopp_pool_values.subsidy_pool_id,
                                  p_quote_id         => l_get_leaseopp_pool_values.quote_id,
                                  x_subpool_tbl      => l_sub_pool_tbl,
                                  x_return_status    => x_return_status);

        FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
          IF l_sub_pool_tbl.EXISTS(i) THEN
            l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
            l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
          END IF;
        END LOOP;

        -- Add the previous balance to the Subsidy pool
        IF (l_sub_pool_tbl.COUNT > 0) THEN
          okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- Delete the Quote usage data for this Subsidy pool
        delete_quote_subpool_usage(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_subsidy_pool_id  => l_get_leaseopp_pool_values.subsidy_pool_id,
                                   p_source_object_id => l_get_leaseopp_pool_values.quote_id);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_quote_contract;

  ----------------------------------------
  -- PROCEDURE handle_leaseapp_contract
  ----------------------------------------
  PROCEDURE handle_leaseapp_contract (p_api_version       IN  NUMBER,
			                        p_init_msg_list       IN  VARCHAR2,
                                    p_transaction_reason  IN  VARCHAR2,
                                    p_leaseapp_id         IN  NUMBER,
							        x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                          		    x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_leaseapp_contract';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseapp_pool_values IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.PARENT_OBJECT_ID = p_leaseapp_id
     AND QUOTE.PRIMARY_QUOTE = 'Y'
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    CURSOR c_get_leaseopp_quote_id(p_leaseapp_id  IN  NUMBER) IS
    SELECT QUOTE.ID
    FROM OKL_LEASE_QUOTES_B QUOTE,
         OKL_LEASE_OPPORTUNITIES_B LEASEOPP
    WHERE QUOTE.PARENT_OBJECT_ID = LEASEOPP.ID
    AND QUOTE.PARENT_OBJECT_CODE = 'LEASEOPP'
    AND QUOTE.STATUS = 'CT-ACCEPTED'
    AND LEASEOPP.ID = (SELECT LEASE_OPPORTUNITY_ID
	   			       FROM OKL_LEASE_APPLICATIONS_B
				       WHERE ID = p_leaseapp_id);

    ln_count                    NUMBER;
    ln_leaseopp_quote_id        NUMBER;
    lv_leaseopp_quote           VARCHAR2(1);

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

    lv_leaseopp_quote := check_leaseopp_quote (p_lease_app_id   => p_leaseapp_id,
						                       x_return_status  => x_return_status);

    IF (lv_leaseopp_quote = 'Y') THEN -- The Leaseapp is sourced from Lease opportunity
      OPEN c_get_leaseopp_quote_id(p_leaseapp_id  =>  p_leaseapp_id);
      FETCH c_get_leaseopp_quote_id INTO ln_leaseopp_quote_id;
      CLOSE c_get_leaseopp_quote_id;

      handle_quote_contract (p_api_version          =>  p_api_version,
         			         p_init_msg_list        =>  p_init_msg_list,
                             p_transaction_reason   =>  p_transaction_reason,
                             p_quote_id             =>  ln_leaseopp_quote_id,
						     x_return_status        =>  x_return_status,
                             x_msg_count            =>  x_msg_count,
                             x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    FOR l_get_leaseapp_pool_values IN c_get_leaseapp_pool_values LOOP

      SELECT COUNT(*)
      INTO ln_count
      FROM   OKL_QUOTE_SUBPOOL_USAGE
      WHERE  SUBSIDY_POOL_ID = l_get_leaseapp_pool_values.subsidy_pool_id
      AND    SOURCE_OBJECT_ID = p_leaseapp_id;

      IF (ln_count > 0) THEN    -- The Subsidy pool is highest for a Quote

        -- Fetch the data from Quote Subsidy pool usage
        fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                  p_quote_id         => l_get_leaseapp_pool_values.quote_id,
                                  x_subpool_tbl      => l_sub_pool_tbl,
                                  x_return_status    => x_return_status);

        FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
          IF l_sub_pool_tbl.EXISTS(i) THEN
            l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
            l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
          END IF;
        END LOOP;

        -- Add the previous balance to the Subsidy pool
        IF (l_sub_pool_tbl.COUNT > 0) THEN
          okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- Delete the Quote usage data for this Subsidy pool
        delete_quote_subpool_usage(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                   p_source_object_id => l_get_leaseapp_pool_values.quote_id);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_leaseapp_contract;

  ----------------------------------------
  -- PROCEDURE handle_active_contract
  ----------------------------------------
  PROCEDURE handle_active_contract (p_api_version         IN  NUMBER,
			                        p_init_msg_list       IN  VARCHAR2,
                                    p_transaction_reason  IN  VARCHAR2,
                                    p_contract_id         IN  NUMBER,
							        x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                          		    x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_active_contract';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    ln_source_object_id         NUMBER;
    lv_source_object_code       VARCHAR2(30);

  BEGIN

    SELECT ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_SOURCE_CODE
    INTO  ln_source_object_id, lv_source_object_code
    FROM   OKC_K_HEADERS_B
    WHERE ID = p_contract_id;

    IF (lv_source_object_code = 'OKL_QUOTE') THEN

      handle_quote_contract (p_api_version          =>  p_api_version,
         			          p_init_msg_list        =>  p_init_msg_list,
                              p_transaction_reason   =>  p_transaction_reason,
                              p_quote_id             =>  ln_source_object_id,
						      x_return_status        =>  x_return_status,
                              x_msg_count            =>  x_msg_count,
                              x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (lv_source_object_code = 'OKL_LEASE_APP') THEN
      handle_leaseapp_contract (p_api_version          =>  p_api_version,
         			            p_init_msg_list        =>  p_init_msg_list,
                                p_transaction_reason   =>  p_transaction_reason,
                                p_leaseapp_id          =>  ln_source_object_id,
						        x_return_status        =>  x_return_status,
                                x_msg_count            =>  x_msg_count,
                                x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_active_contract;

  ----------------------------------------
  -- PROCEDURE handle_leaseapp_pool
  ----------------------------------------
  PROCEDURE handle_leaseapp_pool (p_api_version         IN  NUMBER,
			                      p_init_msg_list       IN  VARCHAR2,
                                  p_transaction_reason  IN  VARCHAR2,
                                  p_parent_object_id    IN  NUMBER,
                                  p_parent_object_code  IN  VARCHAR2,
                                  p_quote_id            IN NUMBER,
							      x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                          		  x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_leaseapp_pool';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseapp_pool_values IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID,
            SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.ID = p_quote_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    ln_count                    NUMBER;
    lv_leaseopp_quote           VARCHAR2(1);

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

    lv_linked_lop_id            NUMBER;

    ln_this_quote_amount         NUMBER;
    ln_trans_quote               NUMBER;
    ln_rollback_quote            NUMBER;
    lb_this_quote_max_amount     BOOLEAN := FALSE;
    lb_initial_trans             BOOLEAN := FALSE;
    lv_inital_record_exists      VARCHAR2(1) := 'N';

    ln_lap_pool_usage_amount    NUMBER;
    ln_lap_pool_usage_quote     NUMBER;

    ln_lop_pool_usage_amount    NUMBER;
    ln_lop_pool_usage_quote     NUMBER;

  BEGIN
    -- Check if the Lease Application is created from a Quote
    lv_leaseopp_quote := check_leaseopp_quote (p_lease_app_id   => p_parent_object_id,
    				                           x_return_status  => x_return_status);

    --get the linked lease  opportunity id
    SELECT LEASE_OPPORTUNITY_ID
    INTO lv_linked_lop_id
    FROM OKL_LEASE_APPLICATIONS_B
    WHERE ID =p_parent_object_id;

    --loop over all the subsidy pools used in this quote of lease appplication
    FOR l_get_leaseapp_pool_values IN c_get_leaseapp_pool_values LOOP

      ln_this_quote_amount := l_get_leaseapp_pool_values.amount;

      --if the Lease Application is created from a Quote
      IF (lv_leaseopp_quote = 'Y') THEN
        --check  the Approved quotes under the linked lease opportunity and get the maximum subsidy
        -- pool usage
        get_linked_lop_maxsp_usage( p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id
                                      ,p_lop_id           => lv_linked_lop_id
                                      ,p_quote_id         => p_quote_id
                                      ,x_max_usage_qte_id => ln_lop_pool_usage_quote
                                      ,x_max_usage_amt    => ln_lop_pool_usage_amount
                                      ,x_return_Status    => x_return_Status );

        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        ln_lop_pool_usage_quote := null;
        ln_lop_pool_usage_amount := null;
      END IF;

      --check  the Accepted quote and the Credit Recommended counter offers under the linked lease applications
      --and get the maximum subsidy pool usage
      get_linked_lap_maxsp_usage( p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id
                                 ,p_lap_id           => p_parent_object_id
                                 ,p_current_qte_id   => p_quote_id
                                 ,p_transaction      => p_transaction_reason
                                 ,x_max_usage_qte_id => ln_lap_pool_usage_quote
                                 ,x_max_usage_amt    => ln_lap_pool_usage_amount
                                 ,x_return_Status    => x_return_Status );

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- get the maximum of the subsidy pool usage among approved quotes of linked
      --lop, accepted quote and Credit Recommendation offers of linked laps and this
      --quote/offer of the lap
      -- dbms_output.put_line(' Pool Usage Quote'||ln_lap_pool_usage_quote);
      -- dbms_output.put_line(' Pool Usage Amount'||ln_lap_pool_usage_amount);
      -- dbms_output.put_line(' This Quote Amount'||ln_this_quote_amount);

      IF (ln_lap_pool_usage_quote IS NOT NULL  AND
          ln_lop_pool_usage_quote IS NOT NULL) THEN
        IF ln_lap_pool_usage_amount > ln_lop_pool_usage_amount THEN
          IF ln_this_quote_amount > ln_lap_pool_usage_amount THEN
            lb_this_quote_max_amount := TRUE;
            ln_trans_quote := p_quote_id;
          ELSE
            lb_this_quote_max_amount := FALSE;
            ln_rollback_quote := ln_lap_pool_usage_quote;
            ln_trans_quote := ln_lap_pool_usage_quote;
          END IF;
        ELSE
          IF ln_this_quote_amount > ln_lop_pool_usage_amount THEN
            lb_this_quote_max_amount := TRUE;
            ln_trans_quote := p_quote_id;
          ELSE
            lb_this_quote_max_amount := FALSE;
            ln_rollback_quote := ln_lop_pool_usage_quote;
            ln_trans_quote := ln_lop_pool_usage_quote;
          END IF;
        END IF;
      ELSIF ln_lap_pool_usage_quote IS NOT NULL THEN
        IF ln_this_quote_amount > ln_lap_pool_usage_amount THEN
          lb_this_quote_max_amount := TRUE;
          ln_trans_quote := p_quote_id;
        ELSE
          lb_this_quote_max_amount := FALSE;
          ln_trans_quote := ln_lap_pool_usage_quote;
        END IF;
        ln_rollback_quote := ln_lap_pool_usage_quote;
      ELSIF ln_lop_pool_usage_quote  IS NOT NULL THEN
        IF ln_this_quote_amount > ln_lop_pool_usage_amount THEN
          lb_this_quote_max_amount := TRUE;
          ln_trans_quote := p_quote_id;
        ELSE
          lb_this_quote_max_amount := FALSE;
          ln_trans_quote := ln_lop_pool_usage_quote;
        END IF;
        ln_rollback_quote := ln_lop_pool_usage_quote;
      ELSE
        lb_this_quote_max_amount := TRUE;
        ln_trans_quote := p_quote_id;
        lb_initial_trans := TRUE;
      END IF;

      -- dbms_output.put_line('Transaction Quote '||ln_trans_quote);
      -- dbms_output.put_line('Rollback Quote '||ln_rollback_quote);

      IF (lb_initial_trans) THEN -- First Transaction
        -- This is the initial transaction record. So, reduce the same from the
        -- Subsidy pool and create the data in Quote Subsidy pool usage
        -- dbms_output.put_line('Initial Transaction .. ');
        create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                           p_init_msg_list       => p_init_msg_list,
                                           x_return_status       => x_return_status,
                                           x_msg_count           => x_msg_count,
                                           x_msg_data            => x_msg_data,
                                           p_source_object_code  => p_parent_object_code,
                                           p_quote_id            => ln_trans_quote,
                                           p_subsidy_pool_id     => l_get_leaseapp_pool_values.subsidy_pool_id,
                                           p_transaction_reason  => p_transaction_reason);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        IF (lb_this_quote_max_amount) THEN
          -- dbms_output.put_line('This Quote Max Amount .. ');
          -- Rollback the amount in the pool and add this to the pool
           lv_inital_record_exists  := check_initial_record(p_object_id          => ln_rollback_quote,
                                                             p_source_object_code => p_parent_object_code,
                                                             p_subsidy_pool_id    => l_get_leaseapp_pool_values.subsidy_pool_id,
                       				                         x_return_status      => x_return_status);
            IF (lv_inital_record_exists = 'Y') THEN
              -- dbms_output.put_line('Initial Record exists .. so rolling them back .. ');
              l_sub_pool_tbl.delete;
              fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                        p_quote_id         => ln_rollback_quote,
                                        x_subpool_tbl      => l_sub_pool_tbl,
                                        x_return_status    => x_return_status);

              FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
                IF l_sub_pool_tbl.EXISTS(i) THEN
                  l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
                  l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
                END IF;
              END LOOP;

              -- Add the previous balance to the Subsidy pool
              IF (l_sub_pool_tbl.COUNT > 0) THEN
                okl_subsidy_pool_trx_pvt.create_pool_transaction
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_sixv_tbl      => l_sub_pool_tbl,
                                         x_sixv_tbl      => lx_subpool_tbl);
                IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;

              -- Delete the Quote usage data for this Subsidy pool
              delete_quote_subpool_usage(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                         p_source_object_id => ln_rollback_quote);
              IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              -- Reduce this quote amount from pool balance
          	  create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                           p_init_msg_list       => p_init_msg_list,
                                           x_return_status       => x_return_status,
                                           x_msg_count           => x_msg_count,
                                           x_msg_data            => x_msg_data,
                                           p_source_object_code  => p_parent_object_code,
                                           p_quote_id            => ln_trans_quote,
                                           p_subsidy_pool_id     => l_get_leaseapp_pool_values.subsidy_pool_id,
                                           p_transaction_reason  => p_transaction_reason);
              IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            	RAISE OKL_API.G_EXCEPTION_ERROR;
          	  END IF;

            ELSE
              -- dbms_output.put_line('Initial Record doesnt exist, so creating fresh trans .. ');
          	  create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                           p_init_msg_list       => p_init_msg_list,
                                           x_return_status       => x_return_status,
                                           x_msg_count           => x_msg_count,
                                           x_msg_data            => x_msg_data,
                                           p_source_object_code  => p_parent_object_code,
                                           p_quote_id            => ln_trans_quote,
                                           p_subsidy_pool_id     => l_get_leaseapp_pool_values.subsidy_pool_id,
                                           p_transaction_reason  => p_transaction_reason);
              IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            	RAISE OKL_API.G_EXCEPTION_ERROR;
          	  END IF;
            END IF;
         END IF;
       END IF;
     END LOOP;


     x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_leaseapp_pool;

  ----------------------------------------
  -- PROCEDURE handle_leaseapp_update
  ----------------------------------------
  PROCEDURE handle_leaseapp_update (p_api_version         IN  NUMBER,
			                        p_init_msg_list       IN  VARCHAR2,
                                    p_transaction_reason  IN  VARCHAR2,
                                    p_parent_object_id    IN  NUMBER,
                                    p_parent_object_code  IN  VARCHAR2,
                                    p_quote_id            IN  NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                          		    x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_leaseapp_update';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseapp_pool_values IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.ID = p_quote_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    CURSOR c_get_quote_subpool_usage(l_subsidy_pool_id IN NUMBER, l_qte_id IN NUMBER) IS
    SELECT SOURCE_TYPE_CODE,
           SOURCE_OBJECT_ID,
           ASSET_NUMBER,
           ASSET_START_DATE,
           SUBSIDY_POOL_ID,
           SUBSIDY_POOL_AMOUNT,
           SUBSIDY_POOL_CURRENCY_CODE,
           SUBSIDY_ID,
           SUBSIDY_AMOUNT,
           SUBSIDY_CURRENCY_CODE,
           VENDOR_ID,
           CONVERSION_RATE
    FROM   OKL_QUOTE_SUBPOOL_USAGE
    WHERE  SUBSIDY_POOL_ID = l_subsidy_pool_id
    AND    SOURCE_OBJECT_ID = l_qte_id;

    ln_count                    NUMBER;
    lv_leaseopp_quote           VARCHAR2(1);
    l_quote_id                  NUMBER;
    i                           NUMBER :=0;
    l_lap_max_subsidy_amount    NUMBER;
    l_lop_max_subsidy_amount    NUMBER;
    l_lop_max_usage_qte_id      NUMBER;
    l_lap_max_usage_qte_id      NUMBER;
    lb_is_this_max_amount       BOOLEAN;
    lv_linked_lop_id            NUMBER;
    lv_fresh_leaseapp           VARCHAR2(3);
    ln_max_subsidy_amount       NUMBER;
    l_nxt_max_qte_id            NUMBER;
    lv_inital_record_exists     VARCHAR2(3);
    l_max_usage_qte_id          NUMBER;
    l_other_usage               BOOLEAN;

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

      l_quote_id := p_quote_id;

      -- Check if this quote exists in the pool, if so add it back and check for
      -- the next highest impact
      FOR l_get_leaseapp_pool_values IN c_get_leaseapp_pool_values LOOP

        lv_inital_record_exists  := check_initial_record(p_object_id          => l_get_leaseapp_pool_values.quote_id,
                                                         p_source_object_code => p_parent_object_code,
                                                         p_subsidy_pool_id    => l_get_leaseapp_pool_values.subsidy_pool_id,
                       				                     x_return_status      => x_return_status);

        -- dbms_output.put_line('This Quote Exists '|| lv_inital_record_exists);
        IF (lv_inital_record_exists = 'Y') THEN

          i := 0;
          -- Fetch the data from Quote Subsidy pool usage
          l_sub_pool_tbl.delete;
          FOR l_get_quote_subpool_usage IN c_get_quote_subpool_usage(l_get_leaseapp_pool_values.subsidy_pool_id, l_quote_id) LOOP
            l_sub_pool_tbl(i).source_type_code := l_get_quote_subpool_usage.source_type_code;
            l_sub_pool_tbl(i).source_object_id := l_get_quote_subpool_usage.source_object_id;
            l_sub_pool_tbl(i).dnz_asset_number := l_get_quote_subpool_usage.asset_number;
            l_sub_pool_tbl(i).source_trx_date := l_get_quote_subpool_usage.asset_start_date;
            l_sub_pool_tbl(i).subsidy_pool_id := l_get_quote_subpool_usage.subsidy_pool_id ;
            l_sub_pool_tbl(i).subsidy_pool_amount := l_get_quote_subpool_usage.subsidy_pool_amount;
            l_sub_pool_tbl(i).subsidy_pool_currency_code := l_get_quote_subpool_usage.subsidy_pool_currency_code;
            l_sub_pool_tbl(i).subsidy_id := l_get_quote_subpool_usage.subsidy_id;
            l_sub_pool_tbl(i).trx_amount := l_get_quote_subpool_usage.subsidy_amount;
            l_sub_pool_tbl(i).trx_currency_code := l_get_quote_subpool_usage.subsidy_currency_code;
            l_sub_pool_tbl(i).vendor_id := l_get_quote_subpool_usage.vendor_id;
            l_sub_pool_tbl(i).conversion_rate := l_get_quote_subpool_usage.conversion_rate;

            i := i + 1;
          END LOOP;

          IF l_sub_pool_tbl.COUNT > 0 THEN
            FOR j IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
              IF l_sub_pool_tbl.EXISTS(j) THEN
                l_sub_pool_tbl(j).trx_type_code := 'ADDITION';
                l_sub_pool_tbl(j).trx_reason_code := p_transaction_reason;
              END IF;
            END LOOP;
          END IF;

          -- Add the previous balance to the Subsidy pool
          IF (l_sub_pool_tbl.COUNT > 0) THEN
            okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          -- Delete the Quote usage data for this Subsidy pool
          delete_quote_subpool_usage(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                     p_source_object_id => l_quote_id);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --if the Lease Application is created from a Quote
          IF (lv_leaseopp_quote = 'Y') THEN
              --check  the Approved quotes under the linked lease opportunity and get the maximum subsidy
              -- pool usage
              get_linked_lop_maxsp_usage( p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id
                                         ,p_lop_id           => lv_linked_lop_id
                                         ,p_quote_id         => l_quote_id
                                         ,x_max_usage_qte_id => l_lop_max_usage_qte_id
                                         ,x_max_usage_amt    => l_lop_max_subsidy_amount
                                         ,x_return_Status    => x_return_Status
                                        );
              IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
          ELSE
            l_lop_max_usage_qte_id := null;
            l_lop_max_subsidy_amount := null;
          END IF;

          --check  the Accepted quote and the Credit Recommended counter offers under the linked lease applications
          --and get the maximum subsidy pool usage
          get_linked_lap_maxsp_usage( p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id
                                     ,p_lap_id           => p_parent_object_id
                                     ,p_current_qte_id   => l_quote_id
                                     ,p_transaction      => p_transaction_reason
                                     ,x_max_usage_qte_id => l_lap_max_usage_qte_id
                                     ,x_max_usage_amt    => l_lap_max_subsidy_amount
                                     ,x_return_Status    => x_return_Status );

          -- dbms_output.put_line('##l_lap_max_usage_qte_id '|| l_lap_max_usage_qte_id);
          -- dbms_output.put_line('##l_lap_max_subsidy_amount '||l_lap_max_subsidy_amount);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --debug_proc('l_lap_max_usage_qte_id = '||l_lap_max_usage_qte_id);
           --debug_proc('l_lap_max_subsidy_amount = '||l_lap_max_subsidy_amount);

          l_other_usage := true;

          -- get the maximum of the subsidy pool usage among approved quotes of linked
          --lop, accepted quote and Credit Recommendation offers of linked laps and this
          --quote/offer of the lap
          IF l_lap_max_usage_qte_id IS NOT NULL   AND l_lop_max_usage_qte_id  IS NOT NULL THEN
            IF l_lap_max_subsidy_amount > l_lop_max_subsidy_amount THEN
              ln_max_subsidy_amount := l_lap_max_subsidy_amount;
              l_max_usage_qte_id := l_lap_max_usage_qte_id;
            ELSE
              ln_max_subsidy_amount := l_lop_max_subsidy_amount;
              l_max_usage_qte_id := l_lop_max_usage_qte_id;
            END IF;
          ELSIF l_lap_max_usage_qte_id IS NOT NULL THEN
            ln_max_subsidy_amount := l_lap_max_subsidy_amount;
            l_max_usage_qte_id := l_lap_max_usage_qte_id;
          ELSIF l_lop_max_usage_qte_id  IS NOT NULL THEN
            ln_max_subsidy_amount := l_lop_max_subsidy_amount;
            l_max_usage_qte_id := l_lop_max_usage_qte_id;
          ELSE
            l_other_usage := false;
          END IF;

          IF (l_other_usage) THEN
            create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                           p_init_msg_list       => p_init_msg_list,
                                           x_return_status       => x_return_status,
                                           x_msg_count           => x_msg_count,
                                           x_msg_data            => x_msg_data,
                                           p_source_object_code  => p_parent_object_code,
                                           p_quote_id            => l_max_usage_qte_id,
                                           p_subsidy_pool_id     => l_get_leaseapp_pool_values.subsidy_pool_id,
                                           p_transaction_reason  => 'APPROVE_QUOTE'); -- Fix for bug 4997538
            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END IF;
      END LOOP;

      x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_leaseapp_update;
  ----------------------------------------
  -- PROCEDURE handle_leaseapp_price_offer
  ----------------------------------------
  PROCEDURE handle_leaseapp_price_offer (p_api_version         IN  NUMBER,
			                        p_init_msg_list       IN  VARCHAR2,
                                    p_transaction_reason  IN  VARCHAR2,
                                    p_parent_object_id    IN  NUMBER,
                                    p_parent_object_code  IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                          		    x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_leaseapp_price_offer';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseapp_pool_values IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.PARENT_OBJECT_ID = p_parent_object_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    ln_count                    NUMBER;
    lv_leaseopp_quote           VARCHAR2(1);

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN
    -- Check if the Lease Application is created from a Quote
    lv_leaseopp_quote := check_leaseopp_quote (p_lease_app_id   => p_parent_object_id,
						                       x_return_status  => x_return_status);

    IF (lv_leaseopp_quote = 'N') THEN -- Standalone Lease application

      FOR l_get_leaseapp_pool_values IN c_get_leaseapp_pool_values LOOP
        -- Fetch the data from Quote Subsidy pool usage
        fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                  p_quote_id         => l_get_leaseapp_pool_values.quote_id,
                                  x_subpool_tbl      => l_sub_pool_tbl,
                                  x_return_status    => x_return_status);

        FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
          IF l_sub_pool_tbl.EXISTS(i) THEN
            l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
            l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
          END IF;
        END LOOP;

        -- Add the previous balance to the Subsidy pool
        IF (l_sub_pool_tbl.COUNT > 0) THEN
          okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- Delete the Quote usage data for this Subsidy pool
        delete_quote_subpool_usage(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                   p_source_object_id => l_get_leaseapp_pool_values.quote_id);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_leaseapp_price_offer;

  ----------------------------------------
  -- PROCEDURE handle_withdraw_leaseapp
  ----------------------------------------
  PROCEDURE handle_withdraw_leaseapp (p_api_version         IN  NUMBER,
			                        p_init_msg_list       IN  VARCHAR2,
                                    p_transaction_reason  IN  VARCHAR2,
                                    p_parent_object_id    IN  NUMBER,
                                    p_parent_object_code  IN  VARCHAR2,
                                    p_quote_id            IN  NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                          		    x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_withdraw_leaseapp';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    CURSOR c_get_quotesandoffers_in_lap(p_lease_app_id IN NUMBER) IS
    SELECT  QUOTE.ID QUOTE_ID
     FROM OKL_LEASE_QUOTES_V QUOTE
     WHERE QUOTE.STATUS IN ( 'PR-APPROVED','CT-ACCEPTED','CR-RECOMMENDATION')
     AND QUOTE.PARENT_OBJECT_CODE = 'LEASEAPP'
     AND QUOTE.PARENT_OBJECT_ID = p_lease_app_id;

    CURSOR c_get_leaseapp_pool_values(p_lap_quote_id IN NUMBER) IS
     SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.ID = p_lap_quote_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    CURSOR c_get_quote_subpool_usage(l_subsidy_pool_id IN NUMBER, l_qte_id IN NUMBER) IS
    SELECT SOURCE_TYPE_CODE,
           SOURCE_OBJECT_ID,
           ASSET_NUMBER,
           ASSET_START_DATE,
           SUBSIDY_POOL_ID,
           SUBSIDY_POOL_AMOUNT,
           SUBSIDY_POOL_CURRENCY_CODE,
           SUBSIDY_ID,
           SUBSIDY_AMOUNT,
           SUBSIDY_CURRENCY_CODE,
           VENDOR_ID,
           CONVERSION_RATE
    FROM   OKL_QUOTE_SUBPOOL_USAGE
    WHERE  SUBSIDY_POOL_ID = l_subsidy_pool_id
    AND    SOURCE_OBJECT_ID = l_qte_id;

    ln_count                    NUMBER;
    lv_leaseopp_quote           VARCHAR2(1);
    l_quote_id                  NUMBER;
    i                           NUMBER :=0;
    l_lap_max_subsidy_amount    NUMBER;
    l_lop_max_subsidy_amount    NUMBER;
    l_lop_max_usage_qte_id      NUMBER;
    l_lap_max_usage_qte_id      NUMBER;
    lb_is_this_max_amount       BOOLEAN;
    lv_linked_lop_id            NUMBER;
    lv_fresh_leaseapp           VARCHAR2(3);
    ln_max_subsidy_amount       NUMBER;
    l_nxt_max_qte_id            NUMBER;
    lv_inital_record_exists     VARCHAR2(3);
    l_max_usage_qte_id          NUMBER;
    l_other_usage               BOOLEAN;


    ln_leaseopp_quote_id            NUMBER;
    ln_max_subpool_amount           NUMBER;
    ln_next_max_subpool_amount      NUMBER;
    ln_next_max_sp_amount_quote_id  NUMBER;

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

  -- dbms_output.put_line('Started .. '||p_parent_object_id);

    FOR l_lap_qtes_offers IN c_get_quotesandoffers_in_lap(p_parent_object_id) LOOP
-- dbms_output.put_line('First loop .. '||l_lap_qtes_offers.quote_id);
      FOR l_get_leaseapp_pool_values IN c_get_leaseapp_pool_values(p_lap_quote_id => l_lap_qtes_offers.quote_id) LOOP
-- dbms_output.put_line('Second loop .. ');
        lv_inital_record_exists  := check_initial_record(p_object_id          => l_get_leaseapp_pool_values.quote_id,
                                                         p_source_object_code => p_parent_object_code,
                                                         p_subsidy_pool_id    => l_get_leaseapp_pool_values.subsidy_pool_id,
                       				                     x_return_status      => x_return_status);

        -- dbms_output.put_line('This Quote Exists '|| lv_inital_record_exists);
        IF (lv_inital_record_exists = 'Y') THEN
          -- Fetch the data from Quote Subsidy pool usage
          l_sub_pool_tbl.delete;
          fetch_quote_subpool_usage(p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                    p_quote_id         => l_get_leaseapp_pool_values.quote_id,
                                    x_subpool_tbl      => l_sub_pool_tbl,
                                    x_return_status    => x_return_status);

          FOR i IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
            IF l_sub_pool_tbl.EXISTS(i) THEN
              l_sub_pool_tbl(i).trx_type_code := 'ADDITION';
              l_sub_pool_tbl(i).trx_reason_code := p_transaction_reason;
            END IF;
          END LOOP;

          -- Add the previous balance to the Subsidy pool
          IF (l_sub_pool_tbl.COUNT > 0) THEN
            okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          -- Delete the Quote usage data for this Subsidy pool
          delete_quote_subpool_usage(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id,
                                   p_source_object_id =>  l_get_leaseapp_pool_values.quote_id);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- Check if the Lease Application is created from a Quote
          lv_leaseopp_quote := check_leaseopp_quote (p_lease_app_id   => p_parent_object_id,
						                             x_return_status  => x_return_status);

          --if the Lease Application is created from a Quote
          IF (lv_leaseopp_quote = 'Y') THEN
              --check  the Approved quotes under the linked lease opportunity and get the maximum subsidy
              -- pool usage
              get_linked_lop_maxsp_usage( p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id
                                         ,p_lop_id           => lv_linked_lop_id
                                         ,p_quote_id         => l_quote_id
                                         ,x_max_usage_qte_id => l_lop_max_usage_qte_id
                                         ,x_max_usage_amt    => l_lop_max_subsidy_amount
                                         ,x_return_Status    => x_return_Status
                                        );
              IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
          ELSE
            l_lop_max_usage_qte_id := null;
            l_lop_max_subsidy_amount := null;
          END IF;
          --check  the Accepted quote and the Credit Recommended counter offers under the linked lease applications
          --and get the maximum subsidy pool usage
          get_linked_lap_maxsp_usage( p_subsidy_pool_id  => l_get_leaseapp_pool_values.subsidy_pool_id
                                     ,p_lap_id           => p_parent_object_id
                                     ,p_current_qte_id   => null
                                     ,p_transaction      => p_transaction_reason
                                     ,x_max_usage_qte_id => l_lap_max_usage_qte_id
                                     ,x_max_usage_amt    => l_lap_max_subsidy_amount
                                     ,x_return_Status    => x_return_Status
                                    );
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          l_other_usage := true;
          -- dbms_output.put_line('Next Highest Impact Quote '||l_lap_max_usage_qte_id);
          -- dbms_output.put_line('Next Highest Impact Amount '||l_lap_max_subsidy_amount);
          -- get the maximum of the subsidy pool usage among approved quotes of linked
          --lop, accepted quote and Credit Recommendation offers of linked laps and this
          --quote/offer of the lap
          IF l_lap_max_usage_qte_id IS NOT NULL   AND l_lop_max_usage_qte_id  IS NOT NULL THEN
            IF l_lap_max_subsidy_amount > l_lop_max_subsidy_amount THEN
                ln_max_subsidy_amount := l_lap_max_subsidy_amount;
                l_max_usage_qte_id := l_lap_max_usage_qte_id;
            ELSE
                ln_max_subsidy_amount := l_lop_max_subsidy_amount;
                l_max_usage_qte_id := l_lop_max_usage_qte_id;
            END IF;
          ELSIF l_lap_max_usage_qte_id IS NOT NULL THEN
                ln_max_subsidy_amount := l_lap_max_subsidy_amount;
                l_max_usage_qte_id := l_lap_max_usage_qte_id;
          ELSIF l_lop_max_usage_qte_id  IS NOT NULL THEN
                ln_max_subsidy_amount := l_lop_max_subsidy_amount;
                l_max_usage_qte_id := l_lop_max_usage_qte_id;
          ELSE
              l_other_usage := false;
          END IF;

          IF (l_other_usage) THEN
              -- create the transaction record
          -- dbms_output.put_line('Checked for next highest impact ');

              -- Deduct the new impact amount from the pool balance
              create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                           p_init_msg_list       => p_init_msg_list,
                                           x_return_status       => x_return_status,
                                           x_msg_count           => x_msg_count,
                                           x_msg_data            => x_msg_data,
                                           p_source_object_code  => p_parent_object_code,
                                           p_quote_id            => l_max_usage_qte_id,
                                           p_subsidy_pool_id     => l_get_leaseapp_pool_values.subsidy_pool_id,
                                           p_transaction_reason  => 'APPROVE_QUOTE'); -- Fix for bug 4997538
              IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_withdraw_leaseapp;

  ----------------------------------------
  -- PROCEDURE handle_approved_quote_update
  ----------------------------------------
  PROCEDURE handle_approved_quote_update (p_api_version         IN  NUMBER,
			                               p_init_msg_list       IN  VARCHAR2,
                                           p_quote_id            IN  NUMBER,
                                           p_transaction_reason  IN  VARCHAR2,
                                           p_parent_object_id    IN  NUMBER,
                                           p_parent_object_code  IN  VARCHAR2,
		      				               x_return_status       OUT NOCOPY VARCHAR2,
                                           x_msg_count           OUT NOCOPY NUMBER,
                                  		   x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'handle_approved_quote_update';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

	CURSOR c_get_leaseopp_max_pool_values(p_top_object_id  IN NUMBER,
                                          p_quote_id       IN NUMBER,
                                          p_subsidy_pool_id IN NUMBER ) IS
    SELECT QUOTE_ID,
           SUBSIDY_POOL_ID,
           MAX(AMOUNT) AMOUNT
    FROM
    (SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
            SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
            QUOTE.ID QUOTE_ID
     FROM OKL_COST_ADJUSTMENTS_B ADJ,
          OKL_SUBSIDIES_B SUB,
          OKL_SUBSIDY_POOLS_B SUB_POOL,
          OKL_ASSETS_B ASSET,
          OKL_LEASE_QUOTES_B QUOTE
     WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
     AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
     AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
     AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
     AND ADJ.PARENT_OBJECT_ID = ASSET.ID
     AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
     AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
     AND QUOTE.STATUS = 'PR-APPROVED'
     AND QUOTE.PARENT_OBJECT_ID = p_top_object_id
     AND QUOTE.ID <> p_quote_id
     AND SUB_POOL.ID = p_subsidy_pool_id
     GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID)
     WHERE (SUBSIDY_POOL_ID, AMOUNT)
     IN
     (SELECT SUBSIDY_POOL_ID,
             MAX(AMOUNT) AMOUNT
      FROM
      (SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
              SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT,
              QUOTE.ID QUOTE_ID
       FROM OKL_COST_ADJUSTMENTS_B ADJ,
            OKL_SUBSIDIES_B SUB,
            OKL_SUBSIDY_POOLS_B SUB_POOL,
            OKL_ASSETS_B ASSET,
            OKL_LEASE_QUOTES_B QUOTE
       WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
       AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
       AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
       AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
       AND ADJ.PARENT_OBJECT_ID = ASSET.ID
       AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
       AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
       AND QUOTE.STATUS = 'PR-APPROVED'
       AND QUOTE.PARENT_OBJECT_ID = p_top_object_id
       AND QUOTE.ID <> p_quote_id
       AND SUB_POOL.ID = p_subsidy_pool_id
       GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID)
      GROUP BY SUBSIDY_POOL_ID)
     GROUP BY SUBSIDY_POOL_ID, QUOTE_ID;

	CURSOR c_get_quote_pool_values IS
    SELECT SUB.SUBSIDY_POOL_ID SUBSIDY_POOL_ID,
           SUM(DECODE(ADJ.VALUE, NULL, ADJ.DEFAULT_SUBSIDY_AMOUNT, ADJ.VALUE)) AMOUNT
    FROM OKL_COST_ADJUSTMENTS_B ADJ,
         OKL_SUBSIDIES_B SUB,
         OKL_SUBSIDY_POOLS_B SUB_POOL,
         OKL_ASSETS_B ASSET,
         OKL_LEASE_QUOTES_B QUOTE
    WHERE ADJ.ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY'
    AND ADJ.PARENT_OBJECT_CODE = 'ASSET'
    AND ADJ.ADJUSTMENT_SOURCE_ID = SUB.ID
    AND SUB.SUBSIDY_POOL_ID = SUB_POOL.ID
    AND ADJ.PARENT_OBJECT_ID = ASSET.ID
    AND ASSET.PARENT_OBJECT_CODE = 'LEASEQUOTE'
    AND ASSET.PARENT_OBJECT_ID = QUOTE.ID
    AND QUOTE.STATUS = 'PR-INCOMPLETE'
    AND QUOTE.ID = p_quote_id
    GROUP BY SUB.SUBSIDY_POOL_ID, QUOTE.ID;

    CURSOR c_get_quote_subpool_usage(l_subsidy_pool_id IN NUMBER) IS
    SELECT SOURCE_TYPE_CODE,
           SOURCE_OBJECT_ID,
           ASSET_NUMBER,
           ASSET_START_DATE,
           SUBSIDY_POOL_ID,
           SUBSIDY_POOL_AMOUNT,
           SUBSIDY_POOL_CURRENCY_CODE,
           SUBSIDY_ID,
           SUBSIDY_AMOUNT,
           SUBSIDY_CURRENCY_CODE,
           VENDOR_ID,
           CONVERSION_RATE
    FROM   OKL_QUOTE_SUBPOOL_USAGE
    WHERE  SUBSIDY_POOL_ID = l_subsidy_pool_id
    AND    SOURCE_OBJECT_ID = p_quote_id;


    ln_next_max_subsidy_amount          NUMBER;
    ln_next_max_sp_amount_quote_id      NUMBER;
    ln_count                    NUMBER;
    lb_first_value              BOOLEAN;
    lv_status_code              VARCHAR2(30);
    lv_reference_number         VARCHAR2(150);
    i                           NUMBER := 0;

    l_sub_pool_tbl              subsidy_pool_tbl_type;
    lx_subpool_tbl              subsidy_pool_tbl_type;

  BEGIN

    SELECT REFERENCE_NUMBER, STATUS
    INTO  lv_reference_number, lv_status_code
    FROM   OKL_LEASE_QUOTES_B
    WHERE ID = p_quote_id;
    --debug_proc('Quote: '||lv_reference_number);

    IF (lv_status_code = 'PR-APPROVED') THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_INVALID_SUBPOOL_TRANS',
                           p_token1       => 'EVENT',
                           p_token1_value => p_transaction_reason,
                           p_token3       => 'OBJECT_NAME',
                           p_token3_value => lv_reference_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR l_get_quote_pool_values IN c_get_quote_pool_values LOOP
      --debug_proc(' l_get_quote_pool_values.subsidy_pool_id = '||l_get_quote_pool_values.subsidy_pool_id);
      --debug_proc(' l_get_quote_pool_values.amount = '||l_get_quote_pool_values.amount);
      SELECT COUNT(*)   -- Check if the Subsidy pool exists in the usage table
      INTO ln_count
      FROM   OKL_QUOTE_SUBPOOL_USAGE
      WHERE  SUBSIDY_POOL_ID = l_get_quote_pool_values.subsidy_pool_id
      AND    SOURCE_OBJECT_ID = p_quote_id;
      --debug_proc('ln_count = '||ln_count);
      IF (ln_count > 0) THEN    -- The Subsidy pool is highest for this Quote

        -- Fetch the data from Quote Subsidy pool usage
        i := 0;
        l_sub_pool_tbl.delete;
        FOR l_get_quote_subpool_usage IN c_get_quote_subpool_usage(l_get_quote_pool_values.subsidy_pool_id) LOOP
          l_sub_pool_tbl(i).source_type_code := l_get_quote_subpool_usage.source_type_code;
          l_sub_pool_tbl(i).source_object_id := l_get_quote_subpool_usage.source_object_id;
          l_sub_pool_tbl(i).dnz_asset_number := l_get_quote_subpool_usage.asset_number;
          l_sub_pool_tbl(i).source_trx_date := l_get_quote_subpool_usage.asset_start_date;
          l_sub_pool_tbl(i).subsidy_pool_id := l_get_quote_subpool_usage.subsidy_pool_id ;
          l_sub_pool_tbl(i).subsidy_pool_amount := l_get_quote_subpool_usage.subsidy_pool_amount;
          l_sub_pool_tbl(i).subsidy_pool_currency_code := l_get_quote_subpool_usage.subsidy_pool_currency_code;
          l_sub_pool_tbl(i).subsidy_id := l_get_quote_subpool_usage.subsidy_id;
          l_sub_pool_tbl(i).trx_amount := l_get_quote_subpool_usage.subsidy_amount;
          l_sub_pool_tbl(i).trx_currency_code := l_get_quote_subpool_usage.subsidy_currency_code;
          l_sub_pool_tbl(i).vendor_id := l_get_quote_subpool_usage.vendor_id;
          l_sub_pool_tbl(i).conversion_rate := l_get_quote_subpool_usage.conversion_rate;
          --debug_proc('l_sub_pool_tbl(i).dnz_asset_number '||l_sub_pool_tbl(i).dnz_asset_number);
          --debug_proc('l_sub_pool_tbl(i).trx_amount '||l_sub_pool_tbl(i).trx_amount);
          --debug_proc('l_sub_pool_tbl(i).subsidy_pool_id '||l_sub_pool_tbl(i).subsidy_pool_id);
          i := i + 1;
       END LOOP;
       --debug_proc('l_sub_pool_tbl.count = '||l_sub_pool_tbl.count);

        FOR j IN l_sub_pool_tbl.FIRST .. l_sub_pool_tbl.LAST LOOP
          IF l_sub_pool_tbl.EXISTS(j) THEN
            --debug_proc('j := '||j);
            l_sub_pool_tbl(j).trx_type_code := 'ADDITION';
            l_sub_pool_tbl(j).trx_reason_code := p_transaction_reason;
             --debug_proc('l_sub_pool_tbl(i).dnz_asset_number '||l_sub_pool_tbl(j).dnz_asset_number);
          --debug_proc('l_sub_pool_tbl(i).trx_amount '||l_sub_pool_tbl(j).trx_amount);
          --debug_proc('l_sub_pool_tbl(i).subsidy_pool_id '||l_sub_pool_tbl(j).subsidy_pool_id);

          END IF;
        END LOOP;

        -- Add the previous balance to the Subsidy pool
        IF (l_sub_pool_tbl.COUNT > 0) THEN
          okl_subsidy_pool_trx_pvt.create_pool_transaction
                                  (p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_sixv_tbl      => l_sub_pool_tbl,
                                   x_sixv_tbl      => lx_subpool_tbl);
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        -- Delete the Quote usage data for this Subsidy pool
        delete_quote_subpool_usage(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_subsidy_pool_id  => l_get_quote_pool_values.subsidy_pool_id,
                                   p_source_object_id => p_quote_id);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Fetch the new highest subsidy pool impact for the 'APPROVED' lease
        -- quotes other than the present quote
        lb_first_value := TRUE;
        FOR l_get_leaseopp_max_pool_values IN c_get_leaseopp_max_pool_values(p_top_object_id   => p_parent_object_id,
                                                                             p_quote_id        => p_quote_id,
                                                                             p_subsidy_pool_id => l_get_quote_pool_values.subsidy_pool_id ) LOOP
          IF (lb_first_value) THEN
            ln_next_max_subsidy_amount := l_get_leaseopp_max_pool_values.amount;
            ln_next_max_sp_amount_quote_id := l_get_leaseopp_max_pool_values.quote_id;
            lb_first_value := FALSE;
          END IF;

          IF (l_get_leaseopp_max_pool_values.amount > ln_next_max_subsidy_amount) THEN
            ln_next_max_subsidy_amount := l_get_leaseopp_max_pool_values.amount;
            ln_next_max_sp_amount_quote_id := l_get_leaseopp_max_pool_values.quote_id;
          END IF;
        END LOOP;

        IF (NOT lb_first_value) THEN
          -- New value found, so create the transaction record
          -- Deduct the new impact amount from the pool balance
          create_subpool_trx_and_usage(p_api_version         => p_api_version,
                                       p_init_msg_list       => p_init_msg_list,
                                       x_return_status       => x_return_status,
                                       x_msg_count           => x_msg_count,
                                       x_msg_data            => x_msg_data,
                                       p_source_object_code  => p_parent_object_code,
                                       p_quote_id            => ln_next_max_sp_amount_quote_id,
                                       p_subsidy_pool_id     => l_get_quote_pool_values.subsidy_pool_id,
                                       p_transaction_reason  => 'APPROVE_QUOTE'); -- Fix for bug 4997538
          IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END handle_approved_quote_update;

  ------------------------------------
  -- PROCEDURE process_quote_subsidy_pool
  ------------------------------------
  PROCEDURE process_quote_subsidy_pool(p_api_version             IN  NUMBER,
			                           p_init_msg_list           IN  VARCHAR2,
            		                   p_transaction_control     IN  VARCHAR2,
		                               p_quote_id                IN  NUMBER,
		                               p_transaction_reason      IN  VARCHAR2,
                          			   x_return_status           OUT NOCOPY VARCHAR2,
                          			   x_msg_count               OUT NOCOPY NUMBER,
                          			   x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'process_quote_subsidy_pool';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    lv_parent_object_code       VARCHAR2(30);
    ln_parent_object_id         NUMBER;

    CURSOR c_get_parent_object_info IS
    SELECT parent_object_id, parent_object_code
    FROM okl_lease_quotes_b
    WHERE id = p_quote_id;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN  c_get_parent_object_info;
    FETCH c_get_parent_object_info into ln_parent_object_id, lv_parent_object_code;
    CLOSE c_get_parent_object_info;

    IF (p_transaction_reason = 'APPROVE_QUOTE') THEN        -- Transaction --> 'APPROVE_QUOTE'
      handle_quote_pools (p_api_version          =>  p_api_version,
  			               p_init_msg_list        =>  p_init_msg_list,
                           p_quote_id             =>  p_quote_id,
                           p_transaction_reason   =>  p_transaction_reason,
                           p_parent_object_id     =>  ln_parent_object_id,
                           p_parent_object_code   =>  lv_parent_object_code,
						   x_return_status        =>  x_return_status,
                           x_msg_count            =>  x_msg_count,
                           x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (p_transaction_reason = 'UPDATE_APPROVED_QUOTE') THEN -- OR p_transaction_reason = 'EXPIRE_QUOTE')
      -- Transaction --> 'UPDATE_APPROVED_QUOTE', 'EXPIRE_QUOTE'
      --debug_proc('UPDATE_APPROVED_QUOTE p_quote_id ='||p_quote_id);
      handle_approved_quote_update (p_api_version          =>  p_api_version,
  			                         p_init_msg_list        =>  p_init_msg_list,
                                     p_quote_id             =>  p_quote_id,
                                     p_transaction_reason   =>  p_transaction_reason,
                                     p_parent_object_id     =>  ln_parent_object_id,
                                     p_parent_object_code   =>  lv_parent_object_code,
						             x_return_status        =>  x_return_status,
                                     x_msg_count            =>  x_msg_count,
                                     x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_quote_subsidy_pool;

  ------------------------------------------
  -- PROCEDURE process_leaseapp_subsidy_pool
  ------------------------------------------
  PROCEDURE process_leaseapp_subsidy_pool(p_api_version             IN  NUMBER,
			                              p_init_msg_list           IN  VARCHAR2,
            		                      p_transaction_control     IN  VARCHAR2,
		                                  p_leaseapp_id             IN  NUMBER,
		                                  p_transaction_reason      IN  VARCHAR2,
                                      p_quote_id                IN NUMBER,
                          			      x_return_status           OUT NOCOPY VARCHAR2,
                          			      x_msg_count               OUT NOCOPY NUMBER,
                          			      x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'process_leaseapp_subsidy_pool';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;


  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_transaction_reason = 'APPROVE_LEASE_APP_PRICING'
        OR p_transaction_reason = 'APPROVE_LEASE_APP_PRIC_OFFER') THEN        -- Transaction --> 'APPROVE_LEASE_APP_PRICING'
      handle_leaseapp_pool (p_api_version          =>  p_api_version,
  			                p_init_msg_list        =>  p_init_msg_list,
                            p_transaction_reason   =>  p_transaction_reason,
                            p_parent_object_id     =>  p_leaseapp_id,
                            p_quote_id             =>  p_quote_id,
                            p_parent_object_code   =>  'LEASEAPP',
						    x_return_status        =>  x_return_status,
                            x_msg_count            =>  x_msg_count,
                            x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (p_transaction_reason = 'UPDATE_LEASE_APP') THEN      -- Transaction --> 'UPDATE_LEASE_APP'
      handle_leaseapp_update (p_api_version          =>  p_api_version,
  			                  p_init_msg_list        =>  p_init_msg_list,
                              p_transaction_reason   =>  p_transaction_reason,
                              p_parent_object_id     =>  p_leaseapp_id,
                              p_parent_object_code   =>  'LEASEAPP',
                              p_quote_id             =>  p_quote_id,
  						      x_return_status        =>  x_return_status,
                              x_msg_count            =>  x_msg_count,
                              x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
 /*   ELSIF (p_transaction_reason = 'APPROVE_LEASE_APP_PRIC_OFFER') THEN      -- Transaction --> 'APPROVE_LEASE_APP_PRIC_OFFER'
      handle_leaseapp_price_offer (p_api_version          =>  p_api_version,
  			                       p_init_msg_list        =>  p_init_msg_list,
                                   p_transaction_reason   =>  p_transaction_reason,
                                   p_parent_object_id     =>  p_leaseapp_id,
                                   p_parent_object_code   =>  'LEASEAPP',
  						           x_return_status        =>  x_return_status,
                                   x_msg_count            =>  x_msg_count,
                                   x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
*/
    ELSIF (p_transaction_reason = 'WITHDRAW_LEASE_APP') THEN      -- Transaction --> 'WITHDRAW_LEASE_APP'
      handle_withdraw_leaseapp (p_api_version          =>  p_api_version,
  			                    p_init_msg_list        =>  p_init_msg_list,
                                p_transaction_reason   =>  p_transaction_reason,
                                p_parent_object_id     =>  p_leaseapp_id,
                                p_parent_object_code   =>  'LEASEAPP',
                                p_quote_id             =>  p_quote_id,
  						        x_return_status        =>  x_return_status,
                                x_msg_count            =>  x_msg_count,
                                x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (p_transaction_reason = 'CANCEL_LEASE_APP') THEN      -- Transaction --> 'CANCEL_LEASE_APP'
      handle_withdraw_leaseapp (p_api_version          =>  p_api_version,
  			                    p_init_msg_list        =>  p_init_msg_list,
                                p_transaction_reason   =>  p_transaction_reason,
                                p_parent_object_id     =>  p_leaseapp_id,
                                p_parent_object_code   =>  'LEASEAPP',
                                p_quote_id             =>  p_quote_id,
  						        x_return_status        =>  x_return_status,
                                x_msg_count            =>  x_msg_count,
                                x_msg_data             =>  x_msg_data);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_leaseapp_subsidy_pool;

  ------------------------------------
  -- PROCEDURE process_active_contract
  ------------------------------------
  PROCEDURE process_active_contract (p_api_version             IN  NUMBER,
			                         p_init_msg_list           IN  VARCHAR2,
            		                 p_transaction_control     IN  VARCHAR2,
                                     p_contract_id             IN  NUMBER,
                          			 x_return_status           OUT NOCOPY VARCHAR2,
                          			 x_msg_count               OUT NOCOPY NUMBER,
                          			 x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'process_active_contract';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    handle_active_contract (p_api_version          =>  p_api_version,
       			            p_init_msg_list        =>  p_init_msg_list,
                            p_transaction_reason   =>  'ACTIVATE_CONTRACT',
                            p_contract_id          =>  p_contract_id,
						    x_return_status        =>  x_return_status,
                            x_msg_count            =>  x_msg_count,
                            x_msg_data             =>  x_msg_data);
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_active_contract;


  ------------------------------------
  -- PROCEDURE process_cancel_leaseopp
  ------------------------------------
  PROCEDURE process_cancel_leaseopp (p_api_version             IN  NUMBER,
			                         p_init_msg_list           IN  VARCHAR2,
            		                 p_transaction_control     IN  VARCHAR2,
                                     p_parent_object_id        IN  NUMBER,
                          			 x_return_status           OUT NOCOPY VARCHAR2,
                          			 x_msg_count               OUT NOCOPY NUMBER,
                          			 x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'process_cancel_leaseopp';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN
    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    handle_cancel_leaseopp (p_api_version          =>  p_api_version,
       			            p_init_msg_list        =>  p_init_msg_list,
                            p_transaction_reason   =>  'CANCEL_LEASE_OPP',
                            p_parent_object_id     =>  p_parent_object_id,
						    x_return_status        =>  x_return_status,
                            x_msg_count            =>  x_msg_count,
                            x_msg_data             =>  x_msg_data);
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END process_cancel_leaseopp;

END OKL_LEASE_QUOTE_SUBPOOL_PVT;

/

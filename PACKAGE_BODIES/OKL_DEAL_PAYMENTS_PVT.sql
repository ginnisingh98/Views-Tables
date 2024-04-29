--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_PAYMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_PAYMENTS_PVT" as
/* $Header: OKLRDPYB.pls 120.0 2007/05/04 14:55:55 sjalasut noship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_INVALID_CRITERIA            CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_INVALID_VALUE               CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
-------------------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
-------------------------------------------------------------------------------------------------
  G_AMOUNT_FORMAT               CONSTANT  VARCHAR2(200) := 'OKL_AMOUNT_FORMAT';
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_LLA_AST_SERIAL              CONSTANT  VARCHAR2(200) := 'OKL_LLA_AST_SERIAL';
  G_MISSING_CONTRACT            CONSTANT Varchar2(200)  := 'OKL_LLA_CONTRACT_NOT_FOUND';
  G_CONTRACT_ID_TOKEN           CONSTANT Varchar2(30) := 'CONTRACT_ID';
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_DEAL_ASSET_PVT';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
-------------------------------------------------------------------------------------------------

  FUNCTION get_fee_service_name(
            p_chr_id           IN  NUMBER,
            p_cle_id           IN  NUMBER,
            p_lse_id           IN  NUMBER,
            p_parent_cle_id    IN  NUMBER)
  RETURN VARCHAR2 IS

    CURSOR l_fee_name_csr(p_chr_id IN NUMBER,
                          p_cle_id IN NUMBER) IS
    SELECT styt.name
    FROM okl_strm_type_tl styt,
         okc_k_items cim_fee
    WHERE cim_fee.cle_id = p_cle_id
    AND   cim_fee.dnz_chr_id = p_chr_id
    AND   cim_fee.jtot_object1_code = 'OKL_STRMTYP'
    AND   styt.id = cim_fee.object1_id1
    AND   styt.language = USERENV('LANG');

    CURSOR l_service_name_csr(p_chr_id IN NUMBER,
                              p_cle_id IN NUMBER) IS
    SELECT msit.description
    FROM   mtl_system_items_tl msit,
           okc_k_items cim_svc
    WHERE cim_svc.cle_id = p_cle_id
    AND   cim_svc.dnz_chr_id = p_chr_id
    AND   cim_svc.jtot_object1_code = 'OKX_SERVICE'
    AND   msit.inventory_item_id = cim_svc.object1_id1
    AND   msit.organization_id = cim_svc.object1_id2
    AND   msit.language = USERENV('LANG');

    l_fee_service_name VARCHAR2(2000);

  BEGIN

    l_fee_service_name := NULL;

    IF p_lse_id = 52 THEN   --'FEE'

      OPEN l_fee_name_csr(p_cle_id => p_cle_id,
                          p_chr_id => p_chr_id);
      FETCH l_fee_name_csr INTO l_fee_service_name;
      CLOSE l_fee_name_csr;

    ELSIF p_lse_id = 48 THEN   --'SOLD_SERVICE'

      OPEN l_service_name_csr(p_cle_id => p_cle_id,
                              p_chr_id => p_chr_id);
      FETCH l_service_name_csr INTO l_fee_service_name;
      CLOSE l_service_name_csr;

    ELSIF p_lse_id = 53 THEN --'LINK_FEE_ASSET'


      OPEN l_fee_name_csr(p_cle_id => p_parent_cle_id,
                          p_chr_id => p_chr_id);
      FETCH l_fee_name_csr INTO l_fee_service_name;
      CLOSE l_fee_name_csr;

    ELSIF p_lse_id = 49 THEN --'LINK_SERV_ASSET'


      OPEN l_service_name_csr(p_cle_id => p_parent_cle_id,
                              p_chr_id => p_chr_id);
      FETCH l_service_name_csr INTO l_fee_service_name;
      CLOSE l_service_name_csr;

    END IF;

    RETURN l_fee_service_name;
  END;

  FUNCTION get_asset_number(
            p_chr_id           IN  NUMBER,
            p_cle_id           IN  NUMBER,
            p_lse_id           IN  NUMBER)
  RETURN VARCHAR2 IS

    l_asset_number OKC_K_LINES_TL.name%TYPE;

    CURSOR l_asset_num_fin_csr(p_cle_id IN NUMBER) IS
    SELECT clet_fin.name
    FROM okc_k_lines_tl clet_fin
    WHERE clet_fin.id = p_cle_id
    AND   clet_fin.language = USERENV('LANG');

    CURSOR l_asset_num_cov_asset_csr(p_cle_id IN NUMBER,
                                     p_chr_id IN NUMBER) IS
    SELECT clet_fin.name
    FROM okc_k_lines_tl clet_fin,
         okc_k_items    cim_cov_asset
    WHERE cim_cov_asset.cle_id = p_cle_id
    AND   cim_cov_asset.dnz_chr_id = p_chr_id
    AND   cim_cov_asset.jtot_object1_code = 'OKX_COVASST'
    AND   clet_fin.id = cim_cov_asset.object1_id1
    AND   clet_fin.language = USERENV('LANG');

  BEGIN

    l_asset_number := NULL;

    IF p_lse_id = 33 THEN   --'FREE_FORM1'

      OPEN l_asset_num_fin_csr(p_cle_id => p_cle_id);
      FETCH l_asset_num_fin_csr INTO l_asset_number;
      CLOSE l_asset_num_fin_csr;

    ELSIF p_lse_id IN (49,53) THEN --'LINK_FEE_ASSET','LINK_SERV_ASSET'

      OPEN l_asset_num_cov_asset_csr(p_cle_id => p_cle_id,
                                     p_chr_id => p_chr_id);
      FETCH l_asset_num_cov_asset_csr INTO l_asset_number;
      CLOSE l_asset_num_cov_asset_csr;
    END IF;

    RETURN l_asset_number;
  END;

  PROCEDURE load_payment_header(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  NUMBER,
            p_cle_id             IN  NUMBER,
            x_service_fee_cle_id OUT NOCOPY NUMBER,
            x_service_fee_name   OUT NOCOPY VARCHAR2,
            x_asset_cle_id       OUT NOCOPY NUMBER,
            x_asset_number       OUT NOCOPY VARCHAR2,
            x_asset_description  OUT NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'LOAD_PAYMENT_HEADER';
    l_api_version  CONSTANT NUMBER := 1;

    CURSOR l_line_csr(p_cle_id IN NUMBER) IS
    SELECT lse_id,
           cle_id
    FROM okc_k_lines_b cle
    WHERE id = p_cle_id;

    l_line_rec l_line_csr%ROWTYPE;

    CURSOR l_asset_num_fin_csr(p_cle_id IN NUMBER) IS
    SELECT clet_fin.id,
           clet_fin.name,
           clet_fin.item_description
    FROM okc_k_lines_tl clet_fin
    WHERE clet_fin.id = p_cle_id
    AND   clet_fin.language = USERENV('LANG');

    CURSOR l_asset_num_cov_asset_csr(p_cle_id IN NUMBER,
                                     p_chr_id IN NUMBER) IS
    SELECT clet_fin.id,
           clet_fin.name,
           clet_fin.item_description
    FROM okc_k_lines_tl clet_fin,
         okc_k_items    cim_cov_asset
    WHERE cim_cov_asset.cle_id = p_cle_id
    AND   cim_cov_asset.dnz_chr_id = p_chr_id
    AND   cim_cov_asset.jtot_object1_code = 'OKX_COVASST'
    AND   clet_fin.id = cim_cov_asset.object1_id1
    AND   clet_fin.language = USERENV('LANG');


    l_service_fee_cle_id OKC_K_LINES_B.id%TYPE;
    l_service_fee_name   VARCHAR2(2000);
    l_asset_cle_id       OKC_K_LINES_B.id%TYPE;
    l_asset_number       OKC_K_LINES_TL.name%TYPE;
    l_asset_description  OKC_K_LINES_TL.item_description%TYPE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_service_fee_cle_id := NULL;
    l_service_fee_name   := NULL;
    l_asset_cle_id       := NULL;
    l_asset_number       := NULL;
    l_asset_description  := NULL;

    IF p_cle_id IS NOT NULL THEN

      OPEN l_line_csr(p_cle_id => p_cle_id);
      FETCH l_line_csr INTO l_line_rec;
      CLOSE l_line_csr;

      IF l_line_rec.lse_id = 33 THEN

        OPEN l_asset_num_fin_csr(p_cle_id => p_cle_id);
        FETCH l_asset_num_fin_csr INTO l_asset_cle_id,
                                       l_asset_number,
                                       l_asset_description;
        CLOSE l_asset_num_fin_csr;

      ELSIF l_line_rec.lse_id IN (49,53) THEN --'LINK_FEE_ASSET','LINK_SERV_ASSET'

        OPEN l_asset_num_cov_asset_csr(p_chr_id => p_chr_id,
                                       p_cle_id => p_cle_id);
        FETCH l_asset_num_cov_asset_csr INTO l_asset_cle_id,
                                             l_asset_number,
                                             l_asset_description;
        CLOSE l_asset_num_cov_asset_csr;
      END IF;

      IF l_line_rec.lse_id IN (48,52) THEN -- 'FEE', 'SOLD_SERVICE'

        l_service_fee_cle_id := p_cle_id;
        l_service_fee_name := get_fee_service_name(p_chr_id        => p_chr_id
                                                  ,p_cle_id        => p_cle_id
                                                  ,p_lse_id        => l_line_rec.lse_id
                                                  ,p_parent_cle_id => l_line_rec.cle_id);

      ELSIF l_line_rec.lse_id IN (49,53) THEN --'LINK_FEE_ASSET','LINK_SERV_ASSET'

        l_service_fee_cle_id := l_line_rec.cle_id;
        l_service_fee_name := get_fee_service_name(p_chr_id        => p_chr_id
                                                  ,p_cle_id        => p_cle_id
                                                  ,p_lse_id        => l_line_rec.lse_id
                                                  ,p_parent_cle_id => l_line_rec.cle_id);
      END IF;

    END IF;

    x_service_fee_cle_id := l_service_fee_cle_id;
    x_service_fee_name   := l_service_fee_name;
    x_asset_cle_id       := l_asset_cle_id;
    x_asset_number       := l_asset_number;
    x_asset_description  := l_asset_description;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END load_payment_header;

End OKL_DEAL_PAYMENTS_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKL_SERVICE_LINE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SERVICE_LINE_PROCESS_PVT" AS
 /* $Header: OKLRSLPB.pls 120.3 2006/07/28 10:00:56 akrangan noship $ */

  -------------------------------------------------------------------------------
  -- PROCEDURE create_service_line
  -------------------------------------------------------------------------------
  PROCEDURE create_service_line(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_cplv_rec       IN  cplv_rec_type,
                                x_clev_rec       OUT NOCOPY clev_rec_type,
                                x_klev_rec       OUT NOCOPY klev_rec_type,
                                x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                x_cplv_rec       OUT NOCOPY cplv_rec_type) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_service_line';

    l_api_name          CONSTANT VARCHAR2(30)  := 'create_service_line';
    lx_return_status    VARCHAR2(1);

    CURSOR c_hdr (p_chr_id NUMBER) IS
      SELECT sts_code,
             currency_code
      FROM   okc_k_headers_b
      WHERE  id = p_chr_id;

    l_hdr               c_hdr%ROWTYPE;

    l_clev_rec          clev_rec_type;
    l_klev_rec          klev_rec_type;
    l_cimv_rec          cimv_rec_type;
    l_cplv_rec          cplv_rec_type;

    l_chr_id            NUMBER;

  BEGIN

    lx_return_status := okl_api.start_activity(p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => G_API_VERSION,
                                               p_api_version   => p_api_version,
                                               p_api_type      => '_PVT',
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_clev_rec  := p_clev_rec;
    l_klev_rec  := p_klev_rec;
    l_cimv_rec  := p_cimv_rec;
    l_cplv_rec  := p_cplv_rec;

    l_chr_id    :=  l_clev_rec.dnz_chr_id;

    OPEN c_hdr (p_chr_id => l_chr_id);
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    l_clev_rec.chr_id           := l_chr_id;
    l_clev_rec.sts_code         := l_hdr.sts_code;
    l_clev_rec.currency_code    := l_hdr.currency_code;
    l_clev_rec.line_number      := '1';
    l_clev_rec.exception_yn     := 'N';
    l_clev_rec.display_sequence := 1;

    SELECT id
    INTO   l_clev_rec.lse_id
    FROM   okc_line_styles_b
    WHERE  lty_code = 'SOLD_SERVICE';

    l_cimv_rec.exception_yn       := 'N';
    l_cimv_rec.uom_code           := 'EA';
    l_cimv_rec.number_of_items    := 1;
    l_cimv_rec.jtot_object1_code  := 'OKX_SERVICE';
    l_cimv_rec.object1_id2        := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);
    l_cimv_rec.dnz_chr_id         := l_chr_id;

    l_cimv_rec.cle_id := NULL;

    l_cplv_rec.dnz_chr_id         := l_chr_id;
    l_cplv_rec.object1_id2        := '#';
    l_cplv_rec.jtot_object1_code  := 'OKX_VENDOR';
    l_cplv_rec.rle_code           := 'OKL_VENDOR';

    -- Following API call does the following:

    -- 1. create a SOLD_SERVICE top line record
    -- 2. create OKC_K_ITEMS record for the top line pointing to MTL_SYSTEM_ITEMS
    -- 3. create OKL_VENDOR party role for the top line

    okl_contract_top_line_pub.create_contract_top_line(p_api_version   => G_API_VERSION,
                                                       p_init_msg_list => G_FALSE,
                                                       p_clev_rec      => l_clev_rec,
                                                       p_klev_rec      => l_klev_rec,
                                                       p_cimv_rec      => l_cimv_rec,
                                                       p_cplv_rec      => l_cplv_rec,
                                                       x_clev_rec      => x_clev_rec,
                                                       x_klev_rec      => x_klev_rec,
                                                       x_cimv_rec      => x_cimv_rec,
                                                       x_cplv_rec      => x_cplv_rec,
                                                       x_return_status => lx_return_status,
                                                       x_msg_count     => x_msg_count,
                                                       x_msg_data      => x_msg_data);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

    x_return_status  :=  lx_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_service_line;


  -------------------------------------------------------------------------------
  -- PROCEDURE create_service_asset
  -------------------------------------------------------------------------------
  PROCEDURE create_service_asset(p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_rec       IN  clev_rec_type,
                                 p_klev_rec       IN  klev_rec_type,
                                 p_cimv_rec       IN  cimv_rec_type,
                                 p_cplv_rec       IN  cplv_rec_type,
                                 p_sub_clev_rec   IN  clev_rec_type,
                                 p_sub_klev_rec   IN  klev_rec_type,
                                 p_sub_cimv_rec   IN  cimv_rec_type,
                                 x_clev_rec       OUT NOCOPY clev_rec_type,
                                 x_klev_rec       OUT NOCOPY klev_rec_type,
                                 x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                 x_cplv_rec       OUT NOCOPY cplv_rec_type,
                                 x_sub_clev_rec   OUT NOCOPY clev_rec_type,
                                 x_sub_klev_rec   OUT NOCOPY klev_rec_type,
                                 x_sub_cimv_rec   OUT NOCOPY cimv_rec_type) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_service_asset';

    l_api_name          CONSTANT VARCHAR2(30)  := 'create_service_asset';
    lx_return_status    VARCHAR2(1);

    l_sub_clev_rec      clev_rec_type;
    l_sub_klev_rec      klev_rec_type;
    l_sub_cimv_rec      cimv_rec_type;

  BEGIN

    lx_return_status := okl_api.start_activity(p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => G_API_VERSION,
                                               p_api_version   => p_api_version,
                                               p_api_type      => '_PVT',
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    create_service_line(p_api_version   => G_API_VERSION,
                        p_init_msg_list => G_FALSE,
                        p_clev_rec      => p_clev_rec,
                        p_klev_rec      => p_klev_rec,
                        p_cimv_rec      => p_cimv_rec,
                        p_cplv_rec      => p_cplv_rec,
                        x_clev_rec      => x_clev_rec,
                        x_klev_rec      => x_klev_rec,
                        x_cimv_rec      => x_cimv_rec,
                        x_cplv_rec      => x_cplv_rec,
                        x_return_status => lx_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_sub_clev_rec  :=  p_sub_clev_rec;
    l_sub_klev_rec  :=  p_sub_klev_rec;
    l_sub_cimv_rec  :=  p_sub_cimv_rec;

    l_sub_clev_rec.line_number      := 1;
    l_sub_clev_rec.exception_yn     := 'N';
    l_sub_clev_rec.display_sequence := 1;

    l_sub_clev_rec.cle_id           := x_clev_rec.id;
    l_sub_clev_rec.dnz_chr_id       := x_clev_rec.dnz_chr_id;
    l_sub_clev_rec.sts_code         := x_clev_rec.sts_code;
    l_sub_clev_rec.currency_code    := x_clev_rec.currency_code;
    l_sub_clev_rec.start_date       := x_clev_rec.start_date;
    l_sub_clev_rec.end_date         := x_clev_rec.end_date;

    SELECT id
    INTO   l_sub_clev_rec.lse_id
    FROM   okc_line_styles_b
    WHERE  lty_code = 'LINK_SERV_ASSET';

    l_sub_klev_rec.amount             := x_klev_rec.amount;
    l_sub_klev_rec.capital_amount     := x_klev_rec.amount;  -- LLA API requirement

    l_sub_cimv_rec.exception_yn       := 'N';
    l_sub_cimv_rec.uom_code           := 'EA';
    l_sub_cimv_rec.number_of_items    := 1;
    l_sub_cimv_rec.jtot_object1_code  := 'OKX_COVASST';
    l_sub_cimv_rec.object1_id2        := '#';
    l_sub_cimv_rec.dnz_chr_id         := x_clev_rec.dnz_chr_id;

    okl_contract_line_item_pub.create_contract_line_item(p_api_version   => G_API_VERSION,
                                                         p_init_msg_list => G_FALSE,
                                                         p_clev_rec      => l_sub_clev_rec,
                                                         p_klev_rec      => l_sub_klev_rec,
                                                         p_cimv_rec      => l_sub_cimv_rec,
                                                         x_clev_rec      => x_sub_clev_rec,
                                                         x_klev_rec      => x_sub_klev_rec,
                                                         x_cimv_rec      => x_sub_cimv_rec,
                                                         x_return_status => lx_return_status,
                                                         x_msg_count     => x_msg_count,
                                                         x_msg_data      => x_msg_data);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

    x_return_status  :=  lx_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_service_asset;


  -------------------------------------------------------------------------------
  -- PROCEDURE update_service_line
  -------------------------------------------------------------------------------
  PROCEDURE update_service_line(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_cplv_rec       IN  cplv_rec_type,
                                x_clev_rec       OUT NOCOPY clev_rec_type,
                                x_klev_rec       OUT NOCOPY klev_rec_type,
                                x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                x_cplv_rec       OUT NOCOPY cplv_rec_type) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'update_service_line';

    l_api_name          CONSTANT VARCHAR2(30)  := 'update_service_line';
    lx_return_status    VARCHAR2(1);

  BEGIN

    lx_return_status := okl_api.start_activity(p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => G_API_VERSION,
                                               p_api_version   => p_api_version,
                                               p_api_type      => '_PVT',
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_contract_top_line_pub.update_contract_top_line(p_api_version   => G_API_VERSION,
                                                       p_init_msg_list => G_FALSE,
                                                       p_clev_rec      => p_clev_rec,
                                                       p_klev_rec      => p_klev_rec,
                                                       p_cimv_rec      => p_cimv_rec,
                                                       p_cplv_rec      => p_cplv_rec,
                                                       x_clev_rec      => x_clev_rec,
                                                       x_klev_rec      => x_klev_rec,
                                                       x_cimv_rec      => x_cimv_rec,
                                                       x_cplv_rec      => x_cplv_rec,
                                                       x_return_status => lx_return_status,
                                                       x_msg_count     => x_msg_count,
                                                       x_msg_data      => x_msg_data);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

    x_return_status  :=  lx_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;


  END update_service_line;


  -------------------------------------------------------------------------------
  -- PROCEDURE delete_service_line
  -------------------------------------------------------------------------------
  PROCEDURE delete_service_line(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_cplv_rec       IN  cplv_rec_type) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'delete_service_line';

    l_api_name          CONSTANT VARCHAR2(30)  := 'delete_service_line';
    lx_return_status    VARCHAR2(1);

  BEGIN

    lx_return_status := okl_api.start_activity(p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => G_API_VERSION,
                                               p_api_version   => p_api_version,
                                               p_api_type      => '_PVT',
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_contract_top_line_pub.delete_contract_top_line(p_api_version   => G_API_VERSION,
                                                       p_init_msg_list => G_FALSE,
                                                       p_clev_rec      => p_clev_rec,
                                                       p_klev_rec      => p_klev_rec,
                                                       p_cimv_rec      => p_cimv_rec,
                                                       p_cplv_rec      => p_cplv_rec,
                                                       x_return_status => lx_return_status,
                                                       x_msg_count     => x_msg_count,
                                                       x_msg_data      => x_msg_data);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

    x_return_status  :=  lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;


  END delete_service_line;

END OKL_SERVICE_LINE_PROCESS_PVT;

/

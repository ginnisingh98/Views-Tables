--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_ASSET_PVT" as
/* $Header: OKLRDASB.pls 120.10.12010000.4 2010/03/30 17:03:30 nikshah ship $ */
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

  TYPE fin_line_tab_type IS TABLE OF NUMBER;

  TYPE asset_rec_type IS RECORD (fin_asset_id   OKC_K_LINES_B.id%TYPE,
                                 amount         OKL_K_LINES.tradein_amount%TYPE,
                                 asset_number   OKC_K_LINES_TL.name%TYPE,
                                 description    OKC_K_LINES_TL.item_description%TYPE,
                                 oec            OKL_K_LINES.oec%TYPE,
                                 capitalize_yn  OKL_K_LINES.capitalize_down_payment_yn%TYPE,
                                 receiver_code  OKL_K_LINES.down_payment_receiver_code%TYPE);

  TYPE asset_tbl_type IS TABLE OF asset_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE Create_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_las_rec        IN  las_rec_type,
            x_las_rec        OUT NOCOPY las_rec_type) IS

    l_clev_fin_rec               OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_klev_fin_rec               OKL_KLE_PVT.klev_rec_type;
    l_cimv_model_rec             OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    l_clev_fa_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_cimv_fa_rec                OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    l_talv_fa_rec                OKL_TAL_PVT.talv_rec_type;
    l_itiv_ib_tbl                OKL_ITI_PVT.itiv_tbl_type;
    -- gboomina Added for Bug 5876083 - Start
    l_tal_id                     OKL_TXL_ASSETS_B.ID%TYPE;
    l_clev_fa_id                 OKC_K_LINES_B.ID%TYPE;
    l_asset_number               FA_ADDITIONS_B.ASSET_NUMBER%TYPE;
    -- gboomina Added for Bug 5876083 - End
    x_clev_fin_rec               OKL_OKC_MIGRATION_PVT.clev_rec_type;
    x_clev_model_rec             OKL_OKC_MIGRATION_PVT.clev_rec_type;
    x_clev_fa_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;
    x_clev_ib_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;

    l_residual_value             NUMBER;
    l_guranteed_amount           NUMBER;
    l_unit_cost                  NUMBER;
    l_press_yn                   VARCHAR2(1);
    l_new_yn                     VARCHAR2(1);
    l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_ALL_LINE';
    l_api_version            CONSTANT NUMBER := 1;
    l_msg_data VARCHAR2(4000);
    l_msg_index_out number;

    -- gboomina added - Cursor to get the okl_txl_assets_b rec's id
    -- Record for Corporate book details will be created in okl_txl_assets_b when asset is getting created.
    -- As per new UI design, We need to get this record and update the user inputs along with asset
    -- creation.
    CURSOR get_tal_id_csr(p_clev_fa_id NUMBER, p_asset_number VARCHAR2) IS
    SELECT  ID
    FROM OKL_TXL_ASSETS_B
    WHERE  KLE_ID = p_clev_fa_id
    AND ASSET_NUMBER = p_asset_number;

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

    l_cimv_model_rec.object1_id1 := p_las_rec.inventory_item_id;
    l_clev_fin_rec.exception_yn := 'N';
    l_clev_fin_rec.dnz_chr_id := p_las_rec.dnz_chr_id;
    l_clev_fin_rec.item_description := p_las_rec.description;
    l_cimv_model_rec.object1_id2 := p_las_rec.inventory_org_id;
    l_klev_fin_rec.residual_code := nvl(p_las_rec.residual_code,'LESSEE');

    IF (p_las_rec.residual_value IS NOT NULL) THEN
        l_residual_value := NULL;
        l_residual_value := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_las_rec.residual_value,
                                          p_currency_code => p_las_rec.currency_code
                                         );
        IF (l_residual_value IS NULL) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_AMOUNT_FORMAT,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'OKC_K_LINES.RESIDUAL_VALUE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            l_klev_fin_rec.residual_value := l_residual_value;
        END IF;
    -- gboomina added for Bug 6369401 - Start
    -- down the line OKL_CREATE_KLE_PVT expects NULL to be passed if not entered.
    ELSE
      l_klev_fin_rec.residual_value := NULL;
    -- gboomina added for Bug 6369401 - End
    END IF;

    IF (p_las_rec.guranteed_amount IS NOT NULL) THEN
        l_guranteed_amount := NULL;
        l_guranteed_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_las_rec.guranteed_amount,
                                          p_currency_code => p_las_rec.currency_code
                                         );
        IF (l_guranteed_amount IS NULL) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_AMOUNT_FORMAT,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'OKC_K_LINES.GURANTEED_AMOUNT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            l_klev_fin_rec.residual_grnty_amount := l_guranteed_amount;
        END IF;
    END IF;

    IF (p_las_rec.rvi_premium IS NOT NULL) THEN
        l_klev_fin_rec.rvi_premium := p_las_rec.rvi_premium;
    END IF;


    IF ((p_las_rec.prescribed_asset_yn IS NULL) OR (p_las_rec.prescribed_asset_yn ='N' ))THEN
       l_press_yn := 'N';
    ELSIF (p_las_rec.prescribed_asset_yn ='Y' ) THEN
       l_press_yn := 'Y';
    END IF;
    l_klev_fin_rec.prescribed_asset_yn := l_press_yn;

    l_cimv_fa_rec.object1_id1 := NULL;
    l_cimv_fa_rec.object1_id2 := NULL;

    IF (p_las_rec.release_asset_flag) THEN
        l_new_yn := 'N';
      else
        l_new_yn := 'Y';
    END IF;


    IF ((p_las_rec.release_asset_flag) AND (p_las_rec.asset_id IS NOT NULL)) THEN
         l_cimv_fa_rec.object1_id1 := p_las_rec.asset_id;
         l_cimv_fa_rec.object1_id2 := '#';
    END IF;

    l_talv_fa_rec.dnz_khr_id := p_las_rec.dnz_chr_id;
    l_talv_fa_rec.asset_number := p_las_rec.asset_number;
    l_talv_fa_rec.description := p_las_rec.description;

    IF ((p_las_rec.deal_type = 'LEASE') AND (p_las_rec.fa_location_id IS NULL)) THEN
        OKL_API.set_message(p_app_name    => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_B.FA_LOCATION_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
        l_talv_fa_rec.fa_location_id := p_las_rec.fa_location_id;
    END IF;

    l_talv_fa_rec.asset_key_id := p_las_rec.asset_key_id;

    IF (p_las_rec.unit_cost IS NOT NULL) THEN
        l_unit_cost := NULL;
        l_unit_cost := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_las_rec.unit_cost,
                                          p_currency_code => p_las_rec.currency_code
                                         );
        IF (l_unit_cost IS NULL) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_AMOUNT_FORMAT,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'OKC_K_LINES_B.PRICE_UNIT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            l_talv_fa_rec.original_cost := l_unit_cost;
        END IF;
    END IF;

    l_talv_fa_rec.current_units:= p_las_rec.units;
    l_talv_fa_rec.model_number := p_las_rec.model_number;
    l_talv_fa_rec.year_manufactured := p_las_rec.year_manufactured;
    l_talv_fa_rec.manufacturer_name := p_las_rec.manufacturer_name;

    IF (p_las_rec.residual_percentage IS NOT NULL) THEN
        l_klev_fin_rec.residual_percentage := p_las_rec.residual_percentage;
    -- gboomina added for Bug 6369401 - Start
    -- down the line OKL_CREATE_KLE_PVT expects NULL to be passed if not entered.
    ELSE
      l_klev_fin_rec.residual_percentage := NULL;
    -- gboomina added for Bug 6369401 - End
    END IF;

   IF (l_new_yn = 'Y') THEN
       l_talv_fa_rec.used_asset_yn := null;
   ELSE
       l_talv_fa_rec.used_asset_yn := 'Y';
   END IF;

   l_klev_fin_rec.date_delivery_expected := p_las_rec.date_delivery_expected;
   l_klev_fin_rec.date_funding_expected  := p_las_rec.date_funding_expected;

   l_klev_fin_rec.validate_dff_yn    := 'Y';
   l_klev_fin_rec.attribute_category := p_las_rec.attribute_category;
   l_klev_fin_rec.attribute1         := p_las_rec.attribute1;
   l_klev_fin_rec.attribute2         := p_las_rec.attribute2;
   l_klev_fin_rec.attribute3         := p_las_rec.attribute3;
   l_klev_fin_rec.attribute4         := p_las_rec.attribute4;
   l_klev_fin_rec.attribute5         := p_las_rec.attribute5;
   l_klev_fin_rec.attribute6         := p_las_rec.attribute6;
   l_klev_fin_rec.attribute7         := p_las_rec.attribute7;
   l_klev_fin_rec.attribute8         := p_las_rec.attribute8;
   l_klev_fin_rec.attribute9         := p_las_rec.attribute9;
   l_klev_fin_rec.attribute10        := p_las_rec.attribute10;
   l_klev_fin_rec.attribute11        := p_las_rec.attribute11;
   l_klev_fin_rec.attribute12        := p_las_rec.attribute12;
   l_klev_fin_rec.attribute13        := p_las_rec.attribute13;
   l_klev_fin_rec.attribute14        := p_las_rec.attribute14;
   l_klev_fin_rec.attribute15        := p_las_rec.attribute15;


   IF (p_las_rec.units > 0) THEN
      FOR i in 1..p_las_rec.units
      LOOP
        l_itiv_ib_tbl(i).mfg_serial_number_yn := 'N';
        l_itiv_ib_tbl(i).object_id1_new := p_las_rec.party_site_use_id;
        l_itiv_ib_tbl(i).object_id2_new := '#';
        l_itiv_ib_tbl(i).jtot_object_code_new := 'OKX_PARTYSITE';
      END LOOP;
   END IF;

    -- gboomina Added for Bug 5876083 - Start
    -- setting OKC context which is required by other API's down the line
    IF p_las_rec.dnz_chr_id IS NOT NULL THEN
      okl_context.set_okc_org_context(p_chr_id => p_las_rec.dnz_chr_id);
    END IF;
    -- gboomina Added for Bug 5876083 - End

    -- Business API call  section
    OKL_CREATE_KLE_PVT.Create_all_line(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       P_new_yn         => l_new_yn,
                                       p_asset_number   => p_las_rec.asset_number,
                                       p_clev_fin_rec   => l_clev_fin_rec,
                                       p_klev_fin_rec   => l_klev_fin_rec,
                                       p_cimv_model_rec => l_cimv_model_rec,
                                       p_clev_fa_rec    => l_clev_fa_rec,
                                       p_cimv_fa_rec    => l_cimv_fa_rec,
                                       p_talv_fa_rec    => l_talv_fa_rec,
                                       p_itiv_ib_tbl    => l_itiv_ib_tbl,
                                       x_clev_fin_rec   => x_clev_fin_rec,
                                       x_clev_model_rec => x_clev_model_rec,
                                       x_clev_fa_rec    => x_clev_fa_rec,
                                       x_clev_ib_rec    => x_clev_ib_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
       x_las_rec               := p_las_rec;
       x_las_rec.clev_fin_id   := x_clev_fin_rec.id;
       x_las_rec.clev_model_id := x_clev_model_rec.id;
       x_las_rec.clev_fa_id    := x_clev_fa_rec.id;
       x_las_rec.clev_ib_id    := x_clev_ib_rec.id;

       -- Get tal_id
       l_clev_fa_id :=x_las_rec.clev_fa_id ;
       -- always cast asset number to upper case because asset number is stored
       -- in upper case in tables
       l_asset_number :=UPPER(p_las_rec.asset_number);
       OPEN get_tal_id_csr(l_clev_fa_id, l_asset_number);
       FETCH get_tal_id_csr INTO l_tal_id;
       CLOSE get_tal_id_csr;
       x_las_rec.tal_id := l_tal_id;

    END IF;


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

  END Create_all_line;


  PROCEDURE update_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_las_rec        IN  las_rec_type,
            x_las_rec        OUT NOCOPY las_rec_type) IS

    l_clev_fin_rec               OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_klev_fin_rec               OKL_KLE_PVT.klev_rec_type;
    l_clev_model_rec             OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_cimv_model_rec             OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    l_clev_fa_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_clev_ib_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_cimv_fa_rec                OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    l_talv_fa_rec                OKL_TAL_PVT.talv_rec_type;
    l_itiv_rec                   OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;

    x_clev_fin_rec               OKL_OKC_MIGRATION_PVT.clev_rec_type;
    x_clev_model_rec             OKL_OKC_MIGRATION_PVT.clev_rec_type;
    x_clev_fa_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;
    x_clev_ib_rec                OKL_OKC_MIGRATION_PVT.clev_rec_type;

    l_residual_value             NUMBER;
    l_guranteed_amount           NUMBER;
    l_unit_cost                  NUMBER;
    l_press_yn                   VARCHAR2(1);
    l_new_yn                     VARCHAR2(1);
    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_ALL_LINE';
    l_api_version            CONSTANT NUMBER := 1;
l_msg_data VARCHAR2(4000);
l_msg_index_out number;

    ln_dummy number := 0;
    CURSOR c_serial_num_present(p_dnz_cle_id OKL_TXL_ITM_INSTS.DNZ_CLE_ID%TYPE) is
    SELECT 1
    FROM OKL_TXL_ITM_INSTS
    WHERE dnz_cle_id = p_dnz_cle_id;
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

    l_clev_fin_rec.id := p_las_rec.clev_fin_id;
    l_clev_model_rec.id := p_las_rec.clev_model_id;
    l_clev_fa_rec.id := p_las_rec.clev_fa_id;
    l_clev_ib_rec.id := p_las_rec.clev_ib_id;
    l_clev_fin_rec.exception_yn := 'N';
    l_clev_fin_rec.dnz_chr_id := p_las_rec.dnz_chr_id;
    l_clev_fin_rec.item_description := p_las_rec.description;
    l_cimv_model_rec.object1_id1 := p_las_rec.inventory_item_id;
    l_cimv_model_rec.object1_id2 := p_las_rec.inventory_org_id;
    l_cimv_model_rec.exception_yn := 'N';

    l_klev_fin_rec.residual_code := nvl(p_las_rec.residual_code,'NONE');

    IF (p_las_rec.residual_value IS NOT NULL) THEN
        l_residual_value := NULL;
        l_residual_value := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_las_rec.residual_value,
                                          p_currency_code => p_las_rec.currency_code
                                         );
        IF (l_residual_value IS NULL) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_AMOUNT_FORMAT,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'OKC_K_LINES.RESIDUAL_VALUE');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            l_klev_fin_rec.residual_value := l_residual_value;
        END IF;
    -- gboomina added for Bug 6369401 - Start
    -- down the line OKL_CREATE_KLE_PVT expects NULL to be passed if not entered.
    ELSE
      l_klev_fin_rec.residual_value := NULL;
    -- gboomina added for Bug 6369401 - End
    END IF;

    IF (p_las_rec.guranteed_amount IS NOT NULL) THEN
        l_guranteed_amount := NULL;
        l_guranteed_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_las_rec.guranteed_amount,
                                          p_currency_code => p_las_rec.currency_code
                                         );
        IF (l_guranteed_amount IS NULL) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_AMOUNT_FORMAT,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'OKC_K_LINES.GURANTEED_AMOUNT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            l_klev_fin_rec.residual_grnty_amount := l_guranteed_amount;
        END IF;
    END IF;

    IF (p_las_rec.rvi_premium IS NOT NULL) THEN
        l_klev_fin_rec.rvi_premium := p_las_rec.rvi_premium;
    END IF;


    IF ((p_las_rec.prescribed_asset_yn IS NULL) OR (p_las_rec.prescribed_asset_yn ='N' ))THEN
       l_press_yn := 'N';
    ELSIF (p_las_rec.prescribed_asset_yn ='Y' ) THEN
       l_press_yn := 'Y';
    END IF;
    l_klev_fin_rec.prescribed_asset_yn := l_press_yn;

    l_talv_fa_rec.dnz_khr_id := p_las_rec.dnz_chr_id;
    l_talv_fa_rec.asset_number := upper(p_las_rec.asset_number);
    l_talv_fa_rec.description := p_las_rec.description;

    IF ((p_las_rec.deal_type = 'LEASE') AND (p_las_rec.fa_location_id IS NULL)) THEN
        OKL_API.set_message(p_app_name    => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_B.FA_LOCATION_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
        l_talv_fa_rec.fa_location_id := p_las_rec.fa_location_id;
    END IF;

    l_talv_fa_rec.asset_key_id := p_las_rec.asset_key_id;

    IF (p_las_rec.unit_cost IS NOT NULL) THEN
        l_unit_cost := NULL;
        l_unit_cost := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_las_rec.unit_cost,
                                          p_currency_code => p_las_rec.currency_code
                                         );
        IF (l_unit_cost IS NULL) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_AMOUNT_FORMAT,
                          p_token1         => G_COL_NAME_TOKEN,
                          p_token1_value   => 'OKC_K_LINES_B.PRICE_UNIT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            l_talv_fa_rec.original_cost := l_unit_cost;
        END IF;
    END IF;

    IF ((p_las_rec.units IS NOT NULL) AND (p_las_rec.old_units IS NOT NULL) AND (p_las_rec.clev_ib_id IS NOT NULL)) THEN
        IF (p_las_rec.units <> p_las_rec.old_units) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name       => G_LLA_AST_SERIAL);
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    l_talv_fa_rec.current_units:= p_las_rec.units;
    l_talv_fa_rec.model_number := p_las_rec.model_number;
    l_talv_fa_rec.year_manufactured := p_las_rec.year_manufactured;
    l_talv_fa_rec.manufacturer_name := p_las_rec.manufacturer_name;

    IF (p_las_rec.residual_percentage IS NOT NULL) THEN
        l_klev_fin_rec.residual_percentage := p_las_rec.residual_percentage;
    -- gboomina added for Bug 6369401 - Start
    -- down the line OKL_CREATE_KLE_PVT expects NULL to be passed if not entered.
    ELSE
      l_klev_fin_rec.residual_percentage := NULL;
    -- gboomina added for Bug 6369401 - End
    END IF;

    IF (p_las_rec.release_asset_flag) THEN
        l_new_yn := 'N';
      else
        l_new_yn := 'Y';
    END IF;

    IF (l_new_yn = 'Y') THEN
        l_talv_fa_rec.used_asset_yn := null;
    ELSE
        l_talv_fa_rec.used_asset_yn := 'Y';
    END IF;

    l_cimv_fa_rec.object1_id1 := null;
    l_cimv_fa_rec.object1_id2 := null;

    l_itiv_rec.mfg_serial_number_yn := l_new_yn;
    l_itiv_rec.object_id1_new := p_las_rec.party_site_use_id;
    l_itiv_rec.object_id2_new := '#';

    l_klev_fin_rec.date_delivery_expected := p_las_rec.date_delivery_expected;
    l_klev_fin_rec.date_funding_expected  := p_las_rec.date_funding_expected;

    l_klev_fin_rec.validate_dff_yn    := 'Y';
    l_klev_fin_rec.attribute_category := p_las_rec.attribute_category;
    l_klev_fin_rec.attribute1         := p_las_rec.attribute1;
    l_klev_fin_rec.attribute2         := p_las_rec.attribute2;
    l_klev_fin_rec.attribute3         := p_las_rec.attribute3;
    l_klev_fin_rec.attribute4         := p_las_rec.attribute4;
    l_klev_fin_rec.attribute5         := p_las_rec.attribute5;
    l_klev_fin_rec.attribute6         := p_las_rec.attribute6;
    l_klev_fin_rec.attribute7         := p_las_rec.attribute7;
    l_klev_fin_rec.attribute8         := p_las_rec.attribute8;
    l_klev_fin_rec.attribute9         := p_las_rec.attribute9;
    l_klev_fin_rec.attribute10        := p_las_rec.attribute10;
    l_klev_fin_rec.attribute11        := p_las_rec.attribute11;
    l_klev_fin_rec.attribute12        := p_las_rec.attribute12;
    l_klev_fin_rec.attribute13        := p_las_rec.attribute13;
    l_klev_fin_rec.attribute14        := p_las_rec.attribute14;
    l_klev_fin_rec.attribute15        := p_las_rec.attribute15;

    OPEN  c_serial_num_present(l_clev_fin_rec.id);
    FETCH c_serial_num_present into ln_dummy;
    CLOSE c_serial_num_present;

   IF (ln_dummy = 1) THEN
       l_itiv_rec.dnz_cle_id := l_clev_fin_rec.id;
   END IF;

    -- gboomina Added for Bug 5876083 - Start
    -- setting OKC context which is required by other API's down the line
    IF p_las_rec.dnz_chr_id IS NOT NULL THEN
      okl_context.set_okc_org_context(p_chr_id => p_las_rec.dnz_chr_id);
    END IF;
    -- gboomina Added for Bug 5876083 - End

    -- Business API call  section
    OKL_CREATE_KLE_PVT.update_all_line(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       P_new_yn         => l_new_yn,
                                       p_asset_number   => p_las_rec.asset_number,
                                       p_clev_fin_rec   => l_clev_fin_rec,
                                       p_klev_fin_rec   => l_klev_fin_rec,
                                       p_clev_model_rec => l_clev_model_rec,
                                       p_cimv_model_rec => l_cimv_model_rec,
                                       p_clev_fa_rec    => l_clev_fa_rec,
                                       p_cimv_fa_rec    => l_cimv_fa_rec,
                                       p_talv_fa_rec    => l_talv_fa_rec,
                                       p_clev_ib_rec    => l_clev_ib_rec,
                                       p_itiv_ib_rec    => l_itiv_rec,
                                       x_clev_fin_rec   => x_clev_fin_rec,
                                       x_clev_model_rec => x_clev_model_rec,
                                       x_clev_fa_rec    => x_clev_fa_rec,
                                       x_clev_ib_rec    => x_clev_ib_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
       x_las_rec               := p_las_rec;
       x_las_rec.clev_fin_id   := x_clev_fin_rec.id;
       x_las_rec.clev_model_id := x_clev_model_rec.id;
       x_las_rec.clev_fa_id    := x_clev_fa_rec.id;
       x_las_rec.clev_ib_id    := x_clev_ib_rec.id;
    END IF;


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

  END update_all_line;

  PROCEDURE load_all_line(
            p_api_version       IN  NUMBER,
            p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            p_chr_id            IN  NUMBER,
            p_clev_fin_id       IN  NUMBER,
            x_las_rec           OUT NOCOPY las_rec_type) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'LOAD_ALL_LINE';
    l_api_version            CONSTANT NUMBER := 1;

    -- gboomina Modified this to get deal type and sts code also
    CURSOR c_khr_info(p_khr_id NUMBER) IS
    SELECT id, deal_type, sts_code
    FROM okl_k_headers_full_v
    WHERE id = p_khr_id;

    l_khr_id     OKL_K_HEADERS_FULL_V.ID%TYPE;
    l_deal_type  OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE;
    l_sts_code   OKL_K_HEADERS_FULL_V.STS_CODE%TYPE;
    l_is_contract_active BOOLEAN;

    CURSOR c_item_line(p_dnz_chr_id NUMBER, p_clev_fin_id NUMBER) IS
    SELECT cleb_mdl.id clev_model_id,
           cim_mdl.object1_id1  inventory_item_id,
           cim_mdl.object1_id2  inventory_org_id,
           cim_mdl.number_of_items,
           cleb_mdl.price_unit,
           msit.description inventory_item_name
    FROM okc_k_lines_b cleb_mdl,
         okc_line_styles_b lse_mdl,
         okc_k_items cim_mdl,
         mtl_system_items_tl msit
    WHERE  cim_mdl.cle_id = cleb_mdl.id
    AND    cim_mdl.dnz_chr_id = cleb_mdl.dnz_chr_id
    AND    cim_mdl.jtot_object1_code = 'OKX_SYSITEM'
    AND    lse_mdl.id = cleb_mdl.lse_id
    AND    lse_mdl.lty_code = 'ITEM'
    AND    msit.inventory_item_id = cim_mdl.object1_id1
    AND    msit.organization_id = cim_mdl.object1_id2
    AND    msit.language = USERENV('LANG')
    AND    cleb_mdl.dnz_chr_id = p_dnz_chr_id
    AND    cleb_mdl.cle_id = p_clev_fin_id;

    c_item_line_rec c_item_line%ROWTYPE;

    CURSOR c_fa_line(p_dnz_chr_id NUMBER, p_clev_fin_id NUMBER) IS
    SELECT cleb_fa.id  clev_fa_id,
           txl.id txl_id,
           txl.model_number,
           kle_fa.year_built,
           txl.fa_location_id,
           ast_loc.name fa_location_name,
           txl.manufacturer_name,
           txl.asset_key_id,
           ast_key.concatenated_segments asset_key_name,
           cim_fa.object1_id1 asset_id
    FROM okl_txl_assets_b txl,
         okc_line_styles_b lse_fa,
         okl_k_lines kle_fa,
         okc_k_lines_b cleb_fa,
         okl_asset_key_lov_uv ast_key,
         okx_ast_locs_v ast_loc,
         okc_k_items cim_fa
    WHERE  cleb_fa.id = kle_fa.id
    AND    lse_fa.id = cleb_fa.lse_id
    AND    lse_fa.lty_code = 'FIXED_ASSET'
    AND    cleb_fa.id = txl.kle_id
    AND    txl.asset_key_id = ast_key.code_combination_id(+)
    AND    txl.fa_location_id = ast_loc.location_id(+)
    AND    cleb_fa.cle_id = p_clev_fin_id
    AND    cleb_fa.dnz_chr_id = p_dnz_chr_id
    and    cleb_fa.id = cim_fa.cle_id
    AND    cleb_fa.dnz_chr_id = cim_fa.dnz_chr_id;

    c_fa_line_rec c_fa_line%ROWTYPE;

    CURSOR c_ib_line(p_dnz_chr_id NUMBER, p_clev_fin_id NUMBER) IS
    SELECT cleb_ib.id  clev_ib_id,
           iti.id,
           iti.object_id1_new    party_site_use_id
    FROM okc_k_lines_b cleb_inst,
         okc_k_lines_b cleb_ib,
         okc_line_styles_b lse_inst,
         okc_line_styles_b lse_ib,
         okl_txl_itm_insts iti
    WHERE cleb_inst.cle_id = p_clev_fin_id
    AND cleb_inst.dnz_chr_id = p_dnz_chr_id
    AND cleb_inst.lse_id = lse_inst.id
    AND lse_inst.lty_code = 'FREE_FORM2'
    AND cleb_ib.cle_id = cleb_inst.id
    AND cleb_ib.dnz_chr_id = cleb_inst.dnz_chr_id
    AND cleb_ib.lse_id = lse_ib.id
    AND lse_ib.lty_code = 'INST_ITEM'
    AND iti.kle_id = cleb_ib.id;

    c_ib_line_rec c_ib_line%ROWTYPE;

    CURSOR c_install_site(p_party_site_use_id NUMBER) IS
    SELECT SUBSTR(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3,
         hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,
         null, null,null,null,null,null,null,'n','n',80,1,1),1,80)      party_site_name
    FROM hz_locations       hl,
         hz_party_sites     hps,
         hz_party_site_uses hpu
    WHERE hpu.party_site_use_id = p_party_site_use_id
    AND hps.party_site_id = hpu.party_site_id
    AND hl.location_id = hps.location_id;

    l_party_site_name VARCHAR2(80);

    -- gboomina added - Start
    -- This cursor is used to get Install Site from CSI_ITEM_INSTANCES for Active Contract
    CURSOR c_install_site_active(p_chr_id NUMBER) IS
    select  cle_ib.id clev_ib_id,
            substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,
                   hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,
                   hl.postal_code,null,hl.country,null, null,null,null,null,null,
                   null,'n','n',80,1,1),1,80) party_site_name
    from hz_locations hl,
         hz_party_sites hps,
         csi_item_instances csi,
         okc_k_items cim_ib,
         okc_line_styles_b lse_ib,
         okc_k_lines_b cle_ib,
         okc_line_styles_b lse_inst,
         okc_k_lines_b cle_inst,
         okc_line_styles_b lse_fin,
         okc_k_lines_b cle_fin
   where cle_fin.cle_id is null
     and cle_fin.chr_id = cle_fin.dnz_chr_id
     and lse_fin.id = cle_fin.lse_id
     and lse_fin.lty_code = 'FREE_FORM1'
     and cle_inst.cle_id = cle_fin.id
     and cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
     and cle_inst.lse_id = lse_inst.id
     and lse_inst.lty_code = 'FREE_FORM2'
     and cle_ib.cle_id = cle_inst.id
     and cle_ib.dnz_chr_id = cle_inst.dnz_chr_id
     and cle_ib.lse_id = lse_ib.id
     and lse_ib.lty_code = 'INST_ITEM'
     and cim_ib.cle_id = cle_ib.id
     and cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
     and cim_ib.object1_id1 = csi.instance_id
     and cim_ib.object1_id2 = '#'
     and cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
     and csi.install_location_id = hps.party_site_id
     and csi.install_location_type_code = 'HZ_PARTY_SITES'
     and hps.location_id = hl.location_id
     and   cle_fin.dnz_chr_id = p_chr_id
    order by cle_fin.id asc;
  l_install_site_active_rec c_install_site_active%ROWTYPE;

  --Bug# 8652738
  -- Corrected table name to fa_additions
  -- This cursor is used to get Asset Key from FA tables for Active Contract
  CURSOR c_asset_key_active(p_asset_number IN fa_additions_b.asset_number%type)
  IS
    select faa.asset_key_ccid ccid,
           fakw.concatenated_segments segs
    from fa_additions faa,
         fa_asset_keywords_kfv fakw
    where faa.asset_key_ccid = fakw.code_combination_id
    and faa.asset_number = p_asset_number;
  l_asset_key_active_rec c_asset_key_active%ROWTYPE;

  -- This cursor is used to get Model Number, Manufacturer and FA Location
  -- from FA tables for Active Contract
  CURSOR c_fa_line_active(p_asset_number IN fa_additions_b.asset_number%type)
  IS
    select loc.name fa_location_name,
           loc.id1 fa_location_id,
           fa.manufacturer_name,
           fa.model_number
    from fa_distribution_history fa_hist,
         okx_ast_locs_v loc,
         fa_additions_b fa
    where fa.asset_id = fa_hist.asset_id
    and fa_hist.location_id = loc.location_id
    and fa.asset_number = p_asset_number
    and fa_hist.transaction_header_id_out is null
    and fa_hist.retirement_id is null;
  l_fa_line_active_rec c_fa_line_active%ROWTYPE;

  -- This cursor is used to get asset number
  CURSOR c_asset_info(p_cle_id OKC_K_LINES_B.ID%TYPE)
  IS
  select name
  from okc_k_lines_tl
  where id = p_cle_id;
  l_asset_number OKC_K_LINES_TL.NAME%TYPE;


--start NISINHA Bug 6490572

-- cursor to get Model Number and Manufacturer from OKL_K_LINES for loan contracts

  CURSOR c_fa_line_loan(p_clev_fin_id IN okc_k_lines_b.id%type,
        p_dnz_chr_id IN okc_k_headers_all_b.id%type) IS
  SELECT kle_fa.model_number,
 	            kle_fa.year_built,
 	            kle_fa.manufacturer_name
  FROM okc_line_styles_b lse_fa,
 	          okl_k_lines kle_fa,
 	          okc_k_lines_b cleb_fa
  WHERE  cleb_fa.id = kle_fa.id
         AND    lse_fa.id = cleb_fa.lse_id
 	 AND    lse_fa.lty_code = 'FIXED_ASSET'
 	 AND    cleb_fa.cle_id = p_clev_fin_id
 	 AND    cleb_fa.dnz_chr_id = p_dnz_chr_id;

 l_fa_line_loan_rec c_fa_line_loan%ROWTYPE;

--end NISINHA Bug 6490572


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

    -- gboomina Modified to get deal_type and sts_code which is used as
    -- input to okl_la_asset_pvt.isContractActive API
    OPEN c_khr_info(p_chr_id);
    FETCH c_khr_info INTO l_khr_id, l_deal_type, l_sts_code;
    IF c_khr_info%NOTFOUND THEN
       CLOSE c_khr_info;
       OKL_API.SET_MESSAGE(p_app_name      =>  g_app_name,
                           p_msg_name      =>  G_MISSING_CONTRACT,
                           p_token1        =>  G_CONTRACT_ID_TOKEN,
                           p_token1_value  =>  to_char(p_chr_id));
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE c_khr_info;

    -- gboomina added to check whether contract is active or not
    l_is_contract_active := okl_la_asset_pvt.isContractActive(l_khr_id,
                                                           l_deal_type,
                                                           l_sts_code);

    OPEN c_item_line(p_chr_id, p_clev_fin_id);
    FETCH c_item_line INTO c_item_line_rec;
    x_las_rec.clev_model_id       := c_item_line_rec.clev_model_id;
    x_las_rec.inventory_item_id   := c_item_line_rec.inventory_item_id;
    x_las_rec.inventory_org_id    := c_item_line_rec.inventory_org_id;
    x_las_rec.inventory_item_name := c_item_line_rec.inventory_item_name;
    x_las_rec.units               := c_item_line_rec.number_of_items;
    x_las_rec.unit_cost           := c_item_line_rec.price_unit;
    CLOSE c_item_line;

    -- gboomina Modified - Start
    -- For Active Contract, get transaction values from FA tables
    -- instead of transaction tables.
    OPEN c_fa_line(p_chr_id, p_clev_fin_id);
    FETCH c_fa_line INTO c_fa_line_rec;
    CLOSE c_fa_line;

    x_las_rec.clev_fa_id          := c_fa_line_rec.clev_fa_id;
    x_las_rec.year_manufactured   := c_fa_line_rec.year_built;
    x_las_rec.asset_id            := c_fa_line_rec.asset_id;

    IF (l_is_contract_active) THEN
      -- Get asset number
      OPEN c_asset_info(p_clev_fin_id);
      FETCH c_asset_info INTO l_asset_number;
      CLOSE c_asset_info;

      -- Get values from FA table if contract is active
      OPEN c_fa_line_active(l_asset_number);
      FETCH c_fa_line_active INTO l_fa_line_active_rec;
      CLOSE c_fa_line_active;
      x_las_rec.model_number        := l_fa_line_active_rec.model_number;
      x_las_rec.fa_location_id      := l_fa_line_active_rec.fa_location_id;
      x_las_rec.fa_location_name    := l_fa_line_active_rec.fa_location_name;
      x_las_rec.manufacturer_name   := l_fa_line_active_rec.manufacturer_name;

      OPEN c_asset_key_active(l_asset_number);
      FETCH c_asset_key_active INTO l_asset_key_active_rec;
      CLOSE c_asset_key_active;
      --Bug# 8652738
      x_las_rec.asset_key_id        := l_asset_key_active_rec.ccid;
      x_las_rec.asset_key_name      := l_asset_key_active_rec.segs;

      -- Get Install Site Name from CSI_ITEM_INSTANCE table
      OPEN c_install_site_active(p_chr_id);
      FETCH c_install_site_active INTO l_install_site_active_rec;
      CLOSE c_install_site_active;
      x_las_rec.clev_ib_id        := l_install_site_active_rec.clev_ib_id;
      x_las_rec.party_site_name   := l_install_site_active_rec.party_site_name;

    ELSE
      x_las_rec.model_number        := c_fa_line_rec.model_number;
      x_las_rec.fa_location_id      := c_fa_line_rec.fa_location_id;
      x_las_rec.fa_location_name    := c_fa_line_rec.fa_location_name;
      x_las_rec.manufacturer_name   := c_fa_line_rec.manufacturer_name;
      x_las_rec.asset_key_id        := c_fa_line_rec.asset_key_id;
      x_las_rec.asset_key_name      := c_fa_line_rec.asset_key_name;


      OPEN c_ib_line(p_chr_id, p_clev_fin_id);
      FETCH c_ib_line INTO c_ib_line_rec;
      x_las_rec.clev_ib_id        := c_ib_line_rec.clev_ib_id;
      x_las_rec.party_site_use_id := c_ib_line_rec.party_site_use_id;

      IF (c_ib_line_rec.party_site_use_id IS NOT NULL) THEN
          OPEN c_install_site(c_ib_line_rec.party_site_use_id);
          FETCH c_install_site INTO l_party_site_name;
          x_las_rec.party_site_name := l_party_site_name;
          CLOSE c_install_site;
      END IF;
      CLOSE c_ib_line;

    END IF;
    -- gboomina - End



-- start NISINHA Bug 6490572
    IF ( l_deal_type = 'LOAN') THEN
      OPEN c_fa_line_loan(p_clev_fin_id, p_chr_id);
      FETCH c_fa_line_loan INTO l_fa_line_loan_rec;
      CLOSE c_fa_line_loan;
      x_las_rec.model_number        := l_fa_line_loan_rec.model_number;
      x_las_rec.manufacturer_name   := l_fa_line_loan_rec.manufacturer_name;
    END IF;
--end NISINHA Bug 6490572

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
  END load_all_line;


  FUNCTION addon_ship_to_site_name(
           p_site_use_id     IN NUMBER
           )
  RETURN VARCHAR2
  IS
  CURSOR c_party_site_name(p_site_use_id NUMBER) IS
  SELECT SUBSTR(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3,
        hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,
        null, null,null,null,null,null,null,'n','n',80,1,1),1,80)      ship_to_site_name
  FROM hz_locations       hl,
       hz_party_sites     hps,
       hz_cust_acct_sites_all cas,
       hz_cust_site_uses_all csu
  WHERE csu.site_use_id = p_site_use_id
  AND cas.cust_acct_site_id = csu.cust_acct_site_id
  AND hps.party_site_id = cas.party_site_id
  AND hl.location_id = hps.location_id;

  l_party_site_name varchar2(80);

  BEGIN
     OPEN c_party_site_name(p_site_use_id);
     FETCH c_party_site_name INTO l_party_site_name;
     CLOSE c_party_site_name;

     return l_party_site_name;

  END addon_ship_to_site_name;

  PROCEDURE process_line_billing_setup(
            p_api_version   IN  NUMBER,
            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            p_rgpv_rec      IN  OKL_DEAL_TERMS_PVT.billing_setup_rec_type,
            x_rgpv_rec      OUT NOCOPY OKL_DEAL_TERMS_PVT.billing_setup_rec_type) IS

  l_api_name         VARCHAR2(30) := 'process_line_billing_setup';
  l_api_version      CONSTANT NUMBER    := 1.0;

  lp_labill_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
  lx_labill_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

  lp_lapmth_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lapmth_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_labacc_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_labacc_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_lainvd_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lainvd_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_lainpr_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lainpr_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;
  lx_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;

  lp_klev_rec OKL_KLE_PVT.klev_rec_type;
  lx_klev_rec OKL_KLE_PVT.klev_rec_type;

  BEGIN
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

    IF (p_rgpv_rec.rgp_id IS NULL) THEN
    -- Create LABILL rule group
      lp_labill_rgpv_rec.id := NULL;
      lp_labill_rgpv_rec.rgd_code := 'LABILL';
      lp_labill_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_labill_rgpv_rec.cle_id := p_rgpv_rec.cle_id;
      lp_labill_rgpv_rec.rgp_type := 'KRG';

      OKL_RULE_PUB.create_rule_group(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rgpv_rec       => lp_labill_rgpv_rec,
          x_rgpv_rec       => lx_labill_rgpv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        x_rgpv_rec.rgp_id               := lx_labill_rgpv_rec.id;
        x_rgpv_rec.rgp_labill_lapmth_id := lx_labill_rgpv_rec.id;
        x_rgpv_rec.rgp_labill_labacc_id := lx_labill_rgpv_rec.id;

    ELSE
      -- Update LABILL rule group
      lp_labill_rgpv_rec.id := p_rgpv_rec.rgp_id;
      lp_labill_rgpv_rec.rgd_code := 'LABILL';
      lp_labill_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_labill_rgpv_rec.cle_id := p_rgpv_rec.cle_id;
      lp_labill_rgpv_rec.rgp_type := 'KRG';

      OKL_RULE_PUB.update_rule_group(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rgpv_rec       => lp_labill_rgpv_rec,
          x_rgpv_rec       => lx_labill_rgpv_rec);

          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
      x_rgpv_rec.rgp_id := p_rgpv_rec.rgp_id;
   END IF;

   -- Update Contract line with Bill-To
   lp_clev_rec.id         := p_rgpv_rec.cle_id;
   lp_clev_rec.chr_id     := p_rgpv_rec.chr_id;
   lp_clev_rec.dnz_chr_id := p_rgpv_rec.chr_id;
   lp_clev_rec.bill_to_site_use_id := p_rgpv_rec.bill_to_site_use_id;
   lp_klev_rec.id         := p_rgpv_rec.cle_id;
   OKL_CONTRACT_PUB.update_contract_line(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
	    p_clev_rec       => lp_clev_rec,
	    p_klev_rec       => lp_klev_rec,
	    p_edit_mode      => 'N',
	    x_clev_rec       => lx_clev_rec,
	    x_klev_rec       => lx_klev_rec);

          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

   IF (p_rgpv_rec.rul_lapmth_id IS NULL) THEN
      -- Create LAPMTH rule
      lp_lapmth_rulv_rec.id := NULL;
      lp_lapmth_rulv_rec.rgp_id := x_rgpv_rec.rgp_id;
      lp_lapmth_rulv_rec.rule_information_category := 'LAPMTH';
      lp_lapmth_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lapmth_rulv_rec.WARN_YN := 'N';
      lp_lapmth_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lapmth_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_lapmth_object1_id2 IS NOT NULL)) THEN
          lp_lapmth_rulv_rec.object1_id1 := p_rgpv_rec.rul_lapmth_object1_id1;
          lp_lapmth_rulv_rec.object1_id2 := p_rgpv_rec.rul_lapmth_object1_id2;
          lp_lapmth_rulv_rec.jtot_object1_code := 'OKX_RCPTMTH';
      END IF;

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lapmth_rulv_rec,
        x_rulv_rec       => lx_lapmth_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lapmth_id := lx_lapmth_rulv_rec.id;
    ELSE
      -- update LAPMTH rule
      lp_lapmth_rulv_rec.id := p_rgpv_rec.rul_lapmth_id;
      lp_lapmth_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_lapmth_rulv_rec.rule_information_category := 'LAPMTH';
      lp_lapmth_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lapmth_rulv_rec.WARN_YN := 'N';
      lp_lapmth_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lapmth_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_lapmth_object1_id2 IS NOT NULL)) THEN
          lp_lapmth_rulv_rec.object1_id1 := p_rgpv_rec.rul_lapmth_object1_id1;
          lp_lapmth_rulv_rec.object1_id2 := p_rgpv_rec.rul_lapmth_object1_id2;
          lp_lapmth_rulv_rec.jtot_object1_code := 'OKX_RCPTMTH';
       ELSE
         -- Added for bug 9324646
          lp_lapmth_rulv_rec.object1_id1 := NULL;
          lp_lapmth_rulv_rec.object1_id2 := NULL;
          lp_lapmth_rulv_rec.jtot_object1_code := NULL;
      END IF;

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lapmth_rulv_rec,
        x_rulv_rec       => lx_lapmth_rulv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    IF (p_rgpv_rec.rul_labacc_id IS NULL) THEN
      -- Create LABACC rule
      lp_labacc_rulv_rec.id := NULL;
      lp_labacc_rulv_rec.rgp_id := x_rgpv_rec.rgp_id;
      lp_labacc_rulv_rec.rule_information_category := 'LABACC';
      lp_labacc_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_labacc_rulv_rec.WARN_YN := 'N';
      lp_labacc_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_labacc_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_labacc_object1_id2 IS NOT NULL)) THEN
          lp_labacc_rulv_rec.object1_id1 := p_rgpv_rec.rul_labacc_object1_id1;
          lp_labacc_rulv_rec.object1_id2 := p_rgpv_rec.rul_labacc_object1_id2;
          lp_labacc_rulv_rec.jtot_object1_code := 'OKX_CUSTBKAC';
      END IF;

      OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_labacc_rulv_rec,
        x_rulv_rec       => lx_labacc_rulv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

      x_rgpv_rec.rul_labacc_id := lx_labacc_rulv_rec.id;

    ELSE
    -- update LABACC rule
      lp_labacc_rulv_rec.id := p_rgpv_rec.rul_labacc_id;
      lp_labacc_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_labacc_rulv_rec.rule_information_category := 'LABACC';
      lp_labacc_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_labacc_rulv_rec.WARN_YN := 'N';
      lp_labacc_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_labacc_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_labacc_object1_id2 IS NOT NULL)) THEN
          lp_labacc_rulv_rec.object1_id1 := p_rgpv_rec.rul_labacc_object1_id1;
          lp_labacc_rulv_rec.object1_id2 := p_rgpv_rec.rul_labacc_object1_id2;
          lp_labacc_rulv_rec.jtot_object1_code := 'OKX_CUSTBKAC';
      ELSE
         -- Added for bug 9324646
          lp_labacc_rulv_rec.object1_id1 := NULL;
          lp_labacc_rulv_rec.object1_id2 := NULL;
          lp_labacc_rulv_rec.jtot_object1_code := NULL;
      END IF;

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_labacc_rulv_rec,
        x_rulv_rec       => lx_labacc_rulv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;


    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END process_line_billing_setup;

  PROCEDURE load_line_billing_setup(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_dnz_chr_id                 IN  NUMBER,
      p_cle_id                     IN  NUMBER,
      x_billing_setup_rec          OUT NOCOPY OKL_DEAL_TERMS_PVT.billing_setup_rec_type) IS

  l_return_status        VARCHAR2(1) default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'load_line_billing_setup';
  l_api_version          CONSTANT NUMBER := 1.0;

  CURSOR c_bill_to(p_cle_id NUMBER) IS
  SELECT clet_fin.name asset_number,
         clet_fin.item_description,
         cleb_fin.bill_to_site_use_id,
         csu.location bill_to_site_name
  FROM okc_k_lines_b cleb_fin,
       hz_cust_site_uses_all csu ,
       okc_k_lines_tl clet_fin
  WHERE cleb_fin.id = p_cle_id
  AND   csu.site_use_id = cleb_fin.bill_to_site_use_id
  AND   clet_fin.id = cleb_fin.id
  AND   clet_fin.language = userenv('LANG');

  CURSOR c_rule(p_chr_id NUMBER, p_cle_id NUMBER, p_rgd_code VARCHAR2, p_rule_info_cat VARCHAR2) IS
  SELECT rul.rgp_id,rgp.rgd_code,rul.ID,rul.object1_id1,rul.object1_id2,rul.rule_information1,rul.rule_information2,
         rul.rule_information3, rul.rule_information4
  FROM  okc_rules_b rul,
        okc_rule_groups_b rgp
  WHERE rgp.dnz_chr_id = p_chr_id
  AND   rgp.cle_id = p_cle_id
  AND   rgp.rgd_code = p_rgd_code
  AND   rgp.id = rul.rgp_id
  AND   rgp.dnz_chr_id = rul.dnz_chr_id
  AND   rul.rule_information_category = p_rule_info_cat;

  l_rule c_rule%ROWTYPE;

  CURSOR c_payment_method(p_object1_id1 NUMBER) IS
  SELECT name
  FROM okx_receipt_methods_v
  WHERE id1 = p_object1_id1;

  CURSOR c_bank_info(p_object1_id1 NUMBER) IS
  SELECT description name,bank bank_name
  FROM okx_rcpt_method_accounts_v
  WHERE id1 = p_object1_id1;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_billing_setup_rec.chr_id := p_dnz_chr_id;
    x_billing_setup_rec.cle_id := p_cle_id;

    OPEN c_bill_to(p_cle_id);
    FETCH c_bill_to INTO x_billing_setup_rec.asset_number,x_billing_setup_rec.item_description,
                         x_billing_setup_rec.bill_to_site_use_id, x_billing_setup_rec.bill_to_site_name;
    CLOSE c_bill_to;

    OPEN c_rule(p_dnz_chr_id, p_cle_id, 'LABILL', 'LAPMTH');
    FETCH c_rule INTO l_rule;
    x_billing_setup_rec.rgp_id                 := l_rule.rgp_id;
    x_billing_setup_rec.rgp_labill_lapmth_id   := l_rule.rgp_id;
    x_billing_setup_rec.rgp_labill_labacc_id   := l_rule.rgp_id;
    x_billing_setup_rec.rul_lapmth_id          := l_rule.id;
    x_billing_setup_rec.rul_lapmth_object1_id1 := l_rule.object1_id1;
    x_billing_setup_rec.rul_lapmth_object1_id2 := l_rule.object1_id2;
    CLOSE c_rule;

    IF (x_billing_setup_rec.rul_lapmth_object1_id1 IS NOT NULL) THEN
       OPEN c_payment_method(x_billing_setup_rec.rul_lapmth_object1_id1);
       FETCH c_payment_method INTO x_billing_setup_rec.rul_lapmth_name;
       CLOSE c_payment_method;
    END IF;

    OPEN c_rule(p_dnz_chr_id, p_cle_id, 'LABILL', 'LABACC');
    FETCH c_rule INTO l_rule;
    x_billing_setup_rec.rul_labacc_id          := l_rule.id;
    x_billing_setup_rec.rul_labacc_object1_id1 := l_rule.object1_id1;
    x_billing_setup_rec.rul_labacc_object1_id2 := l_rule.object1_id2;
    CLOSE c_rule;

    IF (x_billing_setup_rec.rul_labacc_object1_id1 IS NOT NULL) THEN
       OPEN c_bank_info(x_billing_setup_rec.rul_labacc_object1_id1);
       FETCH c_bank_info INTO x_billing_setup_rec.rul_labacc_name,x_billing_setup_rec.rul_labacc_bank_name;
       CLOSE c_bank_info;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END load_line_billing_setup;

  PROCEDURE create_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_rec      IN  addon_rec_type,
            x_addon_rec      OUT NOCOPY addon_rec_type) IS
  BEGIN
      null;
  END create_assetaddon_line;

  PROCEDURE create_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_tbl      IN  addon_tbl_type,
            x_addon_tbl      OUT NOCOPY addon_tbl_type) IS
  BEGIN
      null;
  END create_assetaddon_line;

  PROCEDURE update_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_rec      IN  addon_rec_type,
            x_addon_rec      OUT NOCOPY addon_rec_type) IS
  BEGIN
      null;
  END update_assetaddon_line;

  PROCEDURE update_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_tbl      IN  addon_tbl_type,
            x_addon_tbl      OUT NOCOPY addon_tbl_type) IS
  BEGIN
      null;
  END update_assetaddon_line;

  PROCEDURE allocate_amount_tradein (
            p_api_version    	       IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_tradein_amount         IN  NUMBER,
            p_mode                   IN  VARCHAR2,
            x_tradein_tbl            OUT NOCOPY tradein_tbl_type) IS


    l_api_name    CONSTANT VARCHAR2(30) := 'allocate_amount_tradein';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR c_assets IS
    SELECT cleb_fin.id fin_asset_id,
           clet_fin.name asset_number,
           clet_fin.item_description description,
           NVL(kle_fin.oec,0) oec
    FROM   okc_k_lines_b cleb_fin,
           okc_k_lines_tl clet_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin,
           okc_statuses_b sts
    WHERE cleb_fin.dnz_chr_id = p_chr_id
    AND   cleb_fin.chr_id = p_chr_id
    AND   clet_fin.id = cleb_fin.id
    AND   clet_fin.language = USERENV('LANG')
    AND   cleb_fin.id = kle_fin.id
    AND   lse_fin.id = cleb_fin.lse_id
    AND   lse_fin.lty_code = 'FREE_FORM1'
    AND   cleb_fin.sts_code = sts.code
    AND   sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED');

    CURSOR c_new_assets IS
    SELECT cleb_fin.id fin_asset_id,
           clet_fin.name asset_number,
           clet_fin.item_description description,
           NVL(kle_fin.oec,0) oec
    FROM   okc_k_lines_b cleb_fin,
           okc_k_lines_tl clet_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin,
           okc_statuses_b sts
    WHERE cleb_fin.dnz_chr_id = p_chr_id
    AND   cleb_fin.chr_id = p_chr_id
    AND   clet_fin.id = cleb_fin.id
    AND   clet_fin.language = USERENV('LANG')
    AND   cleb_fin.id = kle_fin.id
    AND   lse_fin.id = cleb_fin.lse_id
    AND   lse_fin.lty_code = 'FREE_FORM1'
    AND   cleb_fin.sts_code = sts.code
    AND   sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED')
    AND   kle_fin.tradein_amount IS NULL;

    CURSOR c_term_fin_lines(p_chr_id IN NUMBER) is
    SELECT SUM(NVL(kle_fin.tradein_amount,0)) amount
    FROM   okc_k_lines_b cleb_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin
    WHERE  cleb_fin.dnz_chr_id = p_chr_id
    AND    cleb_fin.chr_id = p_chr_id
    AND    cleb_fin.sts_code = 'TERMINATED'
    AND    kle_fin.id = cleb_fin.id
    AND    lse_fin.id = cleb_fin.id
    AND    lse_fin.lty_code = 'FREE_FORM1';

    l_term_lines_tradein_amt NUMBER;
    i                        NUMBER := 0;
    l_chr_id                 OKC_K_HEADERS_B.id%TYPE;
    l_tradein_amount         NUMBER := 0;
    l_oec_total              NUMBER := 0;
    l_assoc_amount           NUMBER;
    l_assoc_total            NUMBER := 0;
    l_diff                   NUMBER;
    l_currency_code          OKC_K_HEADERS_B.currency_code%TYPE;
    l_asset_tbl              asset_tbl_type;
    l_tradein_tbl            tradein_tbl_type;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
     	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    l_tradein_amount := p_tradein_amount;

    i := 0;
    IF p_mode = 'CREATE' THEN

      FOR l_asset IN c_new_assets LOOP
       i := i + 1;

       l_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
       l_asset_tbl(i).asset_number := l_asset.asset_number;
       l_asset_tbl(i).description  := l_asset.description;
       l_asset_tbl(i).oec := l_asset.oec;
      END LOOP;

    ELSIF p_mode = 'UPDATE' THEN

      FOR l_asset IN c_assets LOOP
       i := i + 1;

       l_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
       l_asset_tbl(i).asset_number := l_asset.asset_number;
       l_asset_tbl(i).description  := l_asset.description;
       l_asset_tbl(i).oec := l_asset.oec;
      END LOOP;

      -- Exclude Terminated line tradein amounts from
      -- total amount available for allocation
      l_term_lines_tradein_amt := 0;
      OPEN c_term_fin_lines(p_chr_id => l_chr_id);
      FETCH c_term_fin_lines INTO l_term_lines_tradein_amt;
      CLOSE c_term_fin_lines;

      l_tradein_amount := l_tradein_amount - NVL(l_term_lines_tradein_amt,0);

      IF l_tradein_amount < 0 THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                           ,p_msg_name     => 'OKL_LA_NEGATIVE_TRADEIN_AMT'
                           ,p_token1       => 'AMOUNT'
                           ,p_token1_value => TO_CHAR(NVL(l_term_lines_tradein_amt,0)));
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF (l_asset_tbl.COUNT > 0) THEN

      ------------------------------------------------------------------
      -- 1. Loop through to get OEC total of all assets being associated
      ------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN
          l_oec_total := l_oec_total + l_asset_tbl(i).oec;
        END IF;

      END LOOP;

      SELECT currency_code
      INTO   l_currency_code
      FROM   okc_k_headers_b
      WHERE  id = l_chr_id;

      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts and round off the amounts
      ----------------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN

            IF l_asset_tbl.COUNT = 1 THEN

              l_assoc_amount := l_tradein_amount;

            ELSE

              l_assoc_amount := l_tradein_amount * l_asset_tbl(i).oec / l_oec_total;

            END IF;

          l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                             p_currency_code => l_currency_code);

          l_assoc_total := l_assoc_total + l_assoc_amount;

          l_tradein_tbl(i).cleb_fin_id    := l_asset_tbl(i).fin_asset_id;
          l_tradein_tbl(i).dnz_chr_id     := l_chr_id;
          l_tradein_tbl(i).asset_number   := l_asset_tbl(i).asset_number;
          l_tradein_tbl(i).asset_cost     := l_asset_tbl(i).oec;
          l_tradein_tbl(i).description    := l_asset_tbl(i).description;
          l_tradein_tbl(i).tradein_amount := l_assoc_amount;

        END IF;

      END LOOP;

      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_tradein_amount THEN

        l_diff := l_tradein_amount - l_assoc_total;

        l_tradein_tbl(l_tradein_tbl.FIRST).tradein_amount :=  l_tradein_tbl(l_tradein_tbl.FIRST).tradein_amount + l_diff;

      END IF;

    END IF;

    x_tradein_tbl := l_tradein_tbl;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END allocate_amount_tradein;

  PROCEDURE allocate_amount_down_payment (
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  NUMBER,
            p_down_payment         IN  NUMBER,
            p_basis                IN  VARCHAR2,
            p_mode                 IN  VARCHAR2,
            x_down_payment_tbl     OUT NOCOPY down_payment_tbl_type) IS

    l_api_name    CONSTANT VARCHAR2(30) := 'allocate_amount_down_pymt';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR c_assets IS
    SELECT cleb_fin.id fin_asset_id,
           clet_fin.name asset_number,
           clet_fin.item_description description,
           NVL(kle_fin.oec,0) oec,
           NVL(kle_fin.capitalize_down_payment_yn,'Y') capitalize_yn,
           NVL(kle_fin.down_payment_receiver_code,'LESSOR') receiver_code
    FROM   okc_k_lines_b cleb_fin,
           okc_k_lines_tl clet_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin,
           okc_statuses_b sts
    WHERE cleb_fin.dnz_chr_id = p_chr_id
    AND   cleb_fin.chr_id = p_chr_id
    AND   clet_fin.id = cleb_fin.id
    AND   clet_fin.language = USERENV('LANG')
    AND   cleb_fin.id = kle_fin.id
    AND   lse_fin.id = cleb_fin.lse_id
    AND   lse_fin.lty_code = 'FREE_FORM1'
    AND   cleb_fin.sts_code = sts.code
    AND   sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED');

    CURSOR c_new_assets IS
    SELECT cleb_fin.id fin_asset_id,
           clet_fin.name asset_number,
           clet_fin.item_description description,
           NVL(kle_fin.oec,0) oec,
           NVL(kle_fin.capitalize_down_payment_yn,'Y') capitalize_yn,
           NVL(kle_fin.down_payment_receiver_code,'LESSOR') receiver_code
    FROM   okc_k_lines_b cleb_fin,
           okc_k_lines_tl clet_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin,
           okc_statuses_b sts
    WHERE cleb_fin.dnz_chr_id = p_chr_id
    AND   cleb_fin.chr_id = p_chr_id
    AND   clet_fin.id = cleb_fin.id
    AND   clet_fin.language = USERENV('LANG')
    AND   cleb_fin.id = kle_fin.id
    AND   lse_fin.id = cleb_fin.lse_id
    AND   lse_fin.lty_code = 'FREE_FORM1'
    AND   cleb_fin.sts_code = sts.code
    AND   sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED')
    AND   (kle_fin.capital_reduction IS NULL AND
           kle_fin.capital_reduction_percent IS NULL);

    CURSOR c_term_fin_lines(p_chr_id IN NUMBER) is
    SELECT SUM( NVL(kle_fin.capital_reduction,0) +
              (NVL(kle_fin.capital_reduction_percent,0)/100 * kle_fin.oec)) amount
    FROM   okc_k_lines_b cleb_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin
    WHERE  cleb_fin.dnz_chr_id = p_chr_id
    AND    cleb_fin.chr_id = p_chr_id
    AND    cleb_fin.sts_code = 'TERMINATED'
    AND    kle_fin.id = cleb_fin.id
    AND    lse_fin.id = cleb_fin.id
    AND    lse_fin.lty_code = 'FREE_FORM1';

    l_term_lines_down_pymt_amt NUMBER;
    i                          NUMBER := 0;
    l_chr_id                   OKC_K_HEADERS_B.id%TYPE;
    l_down_payment             NUMBER := 0;
    l_basis                    FND_LOOKUPS.lookup_code%TYPE;
    l_oec_total                NUMBER := 0;
    l_assoc_amount             NUMBER;
    l_assoc_total              NUMBER := 0;
    l_diff                     NUMBER;
    l_currency_code            OKC_K_HEADERS_B.currency_code%TYPE;
    l_asset_tbl                asset_tbl_type;
    l_down_payment_tbl         down_payment_tbl_type;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_chr_id := p_chr_id;
    If okl_context.get_okc_org_id  is null then
     	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    l_down_payment := p_down_payment;
    l_basis := p_basis;

    i := 0;
    IF p_mode = 'CREATE' THEN

      FOR l_asset IN c_new_assets LOOP
       i := i + 1;

       l_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
       l_asset_tbl(i).asset_number := l_asset.asset_number;
       l_asset_tbl(i).description  := l_asset.description;
       l_asset_tbl(i).oec := l_asset.oec;
       l_asset_tbl(i).capitalize_yn := l_asset.capitalize_yn;
       l_asset_tbl(i).receiver_code := l_asset.receiver_code;
      END LOOP;

    ELSIF p_mode = 'UPDATE' THEN

      FOR l_asset IN c_assets LOOP
       i := i + 1;

       l_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
       l_asset_tbl(i).asset_number := l_asset.asset_number;
       l_asset_tbl(i).description  := l_asset.description;
       l_asset_tbl(i).oec := l_asset.oec;
       l_asset_tbl(i).capitalize_yn := l_asset.capitalize_yn;
       l_asset_tbl(i).receiver_code := l_asset.receiver_code;
      END LOOP;

      -- Exclude Terminated line downpayment amounts from
      -- total amount available for allocation
      l_term_lines_down_pymt_amt := 0;
      OPEN c_term_fin_lines(p_chr_id => l_chr_id);
      FETCH c_term_fin_lines INTO l_term_lines_down_pymt_amt;
      CLOSE c_term_fin_lines;

      IF l_basis = 'FIXED' THEN
        l_down_payment := l_down_payment - NVL(l_term_lines_down_pymt_amt,0);

        IF l_down_payment < 0 THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                             ,p_msg_name     => 'OKL_LA_NEGATIVE_DOWNPYMT_AMT'
                             ,p_token1       => 'AMOUNT'
                             ,p_token1_value => TO_CHAR(NVL(l_term_lines_down_pymt_amt,0)));
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF;

    IF (l_asset_tbl.COUNT > 0) THEN

      ------------------------------------------------------------------
      -- 1. Loop through to get OEC total of all assets being associated
      ------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN
          l_oec_total := l_oec_total + l_asset_tbl(i).oec;
        END IF;

      END LOOP;

      SELECT currency_code
      INTO   l_currency_code
      FROM   okc_k_headers_b
      WHERE  id = l_chr_id;

      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts and round off the amounts
      ----------------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN

            IF l_asset_tbl.COUNT = 1 THEN

              l_assoc_amount := l_down_payment;

            ELSE

              IF l_basis = 'ASSET_COST' THEN
                 l_assoc_amount := l_down_payment;

              ELSIF l_basis = 'FIXED' THEN
                l_assoc_amount := l_down_payment * l_asset_tbl(i).oec / l_oec_total;

                l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                                   p_currency_code => l_currency_code);
              END IF;
            END IF;

          l_assoc_total := l_assoc_total + l_assoc_amount;

          l_down_payment_tbl(i).cleb_fin_id    := l_asset_tbl(i).fin_asset_id;
          l_down_payment_tbl(i).dnz_chr_id     := l_chr_id;
          l_down_payment_tbl(i).asset_number   := l_asset_tbl(i).asset_number;
          l_down_payment_tbl(i).asset_cost     := l_asset_tbl(i).oec;
          l_down_payment_tbl(i).description    := l_asset_tbl(i).description;
          l_down_payment_tbl(i).basis          := l_basis;
          l_down_payment_tbl(i).down_payment   := l_assoc_amount;
          l_down_payment_tbl(i).down_payment_receiver_code := l_asset_tbl(i).receiver_code;
          l_down_payment_tbl(i).capitalize_down_payment_yn := l_asset_tbl(i).capitalize_yn;
        END IF;

      END LOOP;

      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_basis = 'FIXED' THEN
        IF l_assoc_total <> l_down_payment THEN

          l_diff := l_down_payment - l_assoc_total;

          l_down_payment_tbl(l_down_payment_tbl.FIRST).down_payment :=  l_down_payment_tbl(l_down_payment_tbl.FIRST).down_payment + l_diff;

        END IF;
      END IF;

    END IF;

    x_down_payment_tbl := l_down_payment_tbl;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END allocate_amount_down_payment;

  FUNCTION get_subsidy_amount(
            p_khr_id         IN  NUMBER,
            p_subsidy_id IN  NUMBER)
  RETURN VARCHAR2
  IS
  CURSOR c_subsidy_amount(p_khr_id NUMBER, p_subsidy_id NUMBER) IS
  SELECT OKL_ACCOUNTING_UTIL.format_amount(SUM(NVL(kle_sub.subsidy_override_amount,kle_sub.amount)), cleb_sub.currency_code) subsidy_amount
  FROM  okl_k_lines   kle_sub,
        okc_k_lines_b cleb_sub
  WHERE kle_sub.subsidy_id = p_subsidy_id
  AND   cleb_sub.dnz_chr_id = p_khr_id
  AND   cleb_sub.id = kle_sub.id
  AND   cleb_sub.sts_code <> 'ABANDONED'
  GROUP BY cleb_sub.currency_code;

  l_subsidy_fmt_amount VARCHAR2(100);
  BEGIN
       OPEN c_subsidy_amount(p_khr_id, p_subsidy_id);
       FETCH c_subsidy_amount into l_subsidy_fmt_amount;
       CLOSE c_subsidy_amount;

       return l_subsidy_fmt_amount;

  END get_subsidy_amount;

  FUNCTION get_down_payment_amount(
            p_khr_id         IN  NUMBER)
  RETURN VARCHAR2
  IS
  CURSOR c_down_payment_amount(p_khr_id NUMBER) IS
  SELECT OKL_ACCOUNTING_UTIL.format_amount(SUM( NVL(kle_fin.capital_reduction,0) + (NVL(kle_fin.capital_reduction_percent,0)/100 * kle_fin.oec) ), cleb_fin.currency_code) down_payment_amount
  FROM  okl_k_lines   kle_fin,
        okc_k_lines_b cleb_fin
  WHERE cleb_fin.chr_id = p_khr_id
  AND   cleb_fin.dnz_chr_id = p_khr_id
  AND   kle_fin.id = cleb_fin.id
  AND   (kle_fin.capital_reduction_percent IS NOT NULL OR
      kle_fin.capital_reduction IS NOT NULL)
  GROUP BY cleb_fin.currency_code;

  l_down_payment_amount VARCHAR2(100);
  BEGIN
       OPEN c_down_payment_amount(p_khr_id);
       FETCH c_down_payment_amount into l_down_payment_amount;
       CLOSE c_down_payment_amount;

       return l_down_payment_amount;

  END get_down_payment_amount;

End OKL_DEAL_ASSET_PVT;

/

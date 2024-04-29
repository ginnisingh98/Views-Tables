--------------------------------------------------------
--  DDL for Package Body OKL_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VERSION_PVT" as
/* $Header: OKLRVERB.pls 120.6 2006/11/13 07:24:44 dpsingh noship $ */
----------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
----------------------------------------------------------------------------------------
  G_INVALID_VALUE        CONSTANT  VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_REQUIRED_VALUE       CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_NO_MATCHING_RECORD   CONSTANT  VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_LINE_RECORD          CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
  G_ITEM_RECORD          CONSTANT  VARCHAR2(200) := 'OKL_LLA_ITEM_RECORD';
  G_UNEXPECTED_ERROR     CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_CREATE_VER_ERROR     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATE_VER_ERROR';
  G_RESTORE_VER_ERROR    CONSTANT  VARCHAR2(200) := 'OKL_LLA_RESTORE_VER_ERROR';
  G_DELETE_VER_ERROR     CONSTANT  VARCHAR2(200) := 'OKL_LLA_DELETE_VER_ERROR ';
  G_DELETE_BASE_ERROR    CONSTANT  VARCHAR2(200) := 'OKL_LLA_DELETE_BASE_ERROR';
  G_STATUS               CONSTANT  VARCHAR2(200) := 'OKL_LLA_STATUS';
  G_FIN_LINE_LTY_CODE    CONSTANT  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_MODEL_LINE_LTY_CODE  CONSTANT  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_ADDON_LINE_LTY_CODE  CONSTANT  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE     CONSTANT  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE   CONSTANT  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE     CONSTANT  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_ID2                  CONSTANT  VARCHAR2(200) := '#';
  G_TRY_TYPE             CONSTANT  OKL_TRX_TYPES_V.TRY_TYPE%TYPE   := 'TIE';
  G_TLS_TYPE             CONSTANT  OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE             CONSTANT  OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';
  G_LEASE_SCS_CODE       CONSTANT  OKC_K_HEADERS_V.SCS_CODE%TYPE   := 'LEASE';
  G_LOAN_SCS_CODE        CONSTANT  OKC_K_HEADERS_V.SCS_CODE%TYPE   := 'LOAN';
----------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
----------------------------------------------------------------------------------------
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
----------------------------------------------------------------------------------------
--Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

-- Start of comments
-- Procedure Name  : Create_fa_version
-- Description     : creates Records FA in
--                   OKL_CONTRACT_ASSET_H
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE Create_fa_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_major_version  IN  NUMBER) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'OKL_VERSION_CREATE_FA';
    l_vfav_rec       OKL_VERSION_FA_PUB.vfav_rec_type;
    lx_vfav_rec      OKL_VERSION_FA_PUB.vfav_rec_type;

    CURSOR c_get_fa_line_id(p_dnz_chr_id   OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id,
           cle.dnz_chr_id,
           cim.object1_id1,
           cim.object1_id2
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_v cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND lse1.id = cle.lse_id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_asset_info(p_object1_id1 OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
                        p_object1_id2 OKC_K_ITEMS_V.OBJECT1_ID2%TYPE)
    IS
    SELECT *
    FROM OKX_ASSETS_V
    WHERE id1 = p_object1_id1
    AND id2 = p_object1_id2;

    r_asset_info        c_asset_info%ROWTYPE;
    r_get_fa_line_id    c_get_fa_line_id%ROWTYPE;

    --Bug# 2981308 : cursor to fetch asset key ccid
    cursor l_fab_csr(p_asset_id in number) is
    select fab.asset_key_ccid
    from   fa_additions_b fab
    where  fab.asset_id = p_asset_id;

    l_asset_key_id   fa_additions_b.asset_key_ccid%TYPE;
    --Bug# 2981308
   --Added by dpsingh for LE uptake
   l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
   l_legal_entity_id          NUMBER;

  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;
    --version FA Details
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
    FOR r_get_fa_line_id IN c_get_fa_line_id(p_chr_id) LOOP
      IF c_get_fa_line_id%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Fixed Asset Line id');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To get the Info all the fixed asset lines
      -- And the build the VFAV record
      OPEN  c_asset_info(r_get_fa_line_id.object1_id1,
                         r_get_fa_line_id.object1_id2);
      IF c_asset_info%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKX_ASSETS_V.OBJECT1_ID1');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      FETCH c_asset_info INTO r_asset_info;
      CLOSE c_asset_info;
      l_vfav_rec.major_version          := p_major_version;
      l_vfav_rec.fa_cle_id              := r_get_fa_line_id.id;
      l_vfav_rec.dnz_chr_id             := r_get_fa_line_id.dnz_chr_id;
      l_vfav_rec.asset_number           := r_asset_info.asset_number;
      l_vfav_rec.name                   := r_asset_info.name;
      l_vfav_rec.description            := r_asset_info.description;
      l_vfav_rec.asset_id               := r_asset_info.asset_id;
      l_vfav_rec.corporate_book         := r_asset_info.corporate_book;
      l_vfav_rec.life_in_months         := r_asset_info.life_in_months;
      l_vfav_rec.original_cost          := r_asset_info.original_cost;
      l_vfav_rec.cost                   := r_asset_info.cost;
      l_vfav_rec.adjusted_cost          := r_asset_info.adjusted_cost;
      l_vfav_rec.current_units          := r_asset_info.current_units;
      l_vfav_rec.new_used               := r_asset_info.new_used;
      l_vfav_rec.in_service_date        := r_asset_info.in_service_date;
      l_vfav_rec.model_number           := r_asset_info.model_number;
      l_vfav_rec.asset_type             := r_asset_info.asset_type;
      l_vfav_rec.salvage_value          := r_asset_info.salvage_value;
      l_vfav_rec.percent_salvage_value  := r_asset_info.percent_salvage_value;
      l_vfav_rec.depreciation_category  := r_asset_info.depreciation_category;
      l_vfav_rec.deprn_method_code      := r_asset_info.deprn_method_code;
      l_vfav_rec.deprn_start_date       := r_asset_info.deprn_start_date;
      l_vfav_rec.rate_adjustment_factor := r_asset_info.rate_adjustment_factor;
      l_vfav_rec.basic_rate             := r_asset_info.basic_rate;
      l_vfav_rec.adjusted_rate          := r_asset_info.adjusted_rate;
      l_vfav_rec.start_date_active      := r_asset_info.start_date_active;
      l_vfav_rec.end_date_active        := r_asset_info.end_date_active;
      l_vfav_rec.status                 := ltrim(rtrim(r_asset_info.status));
      l_vfav_rec.primary_uom_code       := r_asset_info.primary_uom_code;

      --------------------------------------
      --Bug# 2981308 : fetch asset key ccid
      --------------------------------------
      open l_fab_csr(p_asset_id => r_asset_info.asset_id);
      fetch l_fab_csr into l_asset_key_id;
      if l_fab_csr%NOTFOUND then
          null;
      end if;
      close l_fab_csr;

      l_vfav_rec.asset_key_id         := l_asset_key_id;
      -------------------------------------
      --bug# 2981308 : fetch asset key ccid
      ------------------------------------
     --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_vfav_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

      -- Now we are going to install into OKL_CONTRACT_ASSET_H table
      OKL_VERSION_FA_PUB.create_version_fa(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_vfav_rec      => l_vfav_rec,
                         x_vfav_rec      => lx_vfav_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
   END LOOP;
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --Bug# 2981308
      if l_fab_csr%ISOPEN then
          close l_fab_csr;
      end if;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --Bug# 2981308
      if l_fab_csr%ISOPEN then
          close l_fab_csr;
      end if;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      --Bug# 2981308
      if l_fab_csr%ISOPEN then
          close l_fab_csr;
      end if;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END Create_fa_version;
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : Create_ib_version
-- Description     : creates Records IB in
--                   OKL_CONTRACT_IB_H tables
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE Create_ib_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_major_version  IN  NUMBER) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'OKL_VERSION_CREATE_IB';
    l_vibv_rec       OKL_VERSION_IB_PUB.vibv_rec_type;
    lx_vibv_rec      OKL_VERSION_IB_PUB.vibv_rec_type;

    CURSOR c_get_ib_line_id(p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id,
           cle.dnz_chr_id,
           cim.object1_id1,
           cim.object1_id2
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse3,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_b cle
    WHERE cle.lse_id = lse1.id
    AND cle.id = cim.cle_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND lse1.lty_code = G_IB_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_INST_LINE_LTY_CODE
    AND lse2.lse_parent_id = lse3.id
    AND lse3.lty_code = G_FIN_LINE_LTY_CODE
    AND lse3.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.cle_id in (SELECT cle.id
                       FROM okc_subclass_top_line stl,
                            okc_line_styles_b lse2,
                            okc_line_styles_b lse1,
                            okc_k_lines_b cle
                       WHERE cle.dnz_chr_id = p_dnz_chr_id
                       AND cle.lse_id = lse1.id
                       AND lse1.lty_code = G_INST_LINE_LTY_CODE
                       AND lse1.lse_parent_id = lse2.id
                       AND lse2.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2.id = stl.lse_id
                       AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));


    CURSOR c_ib_info(p_object1_id1 OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
                     p_object1_id2 OKC_K_ITEMS_V.OBJECT1_ID2%TYPE) IS
    SELECT *
    FROM OKX_INSTALL_ITEMS_V
    WHERE id1 = p_object1_id1
    AND id2  = p_object1_id2;

    r_ib_info           c_ib_info%ROWTYPE;
    r_get_ib_line_id    c_get_ib_line_id%ROWTYPE;

    --Added by dpsingh for LE uptake
    l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_legal_entity_id          NUMBER;

  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;
    --version IB Details
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
    FOR r_get_ib_line_id IN c_get_ib_line_id(p_chr_id) LOOP
      IF c_get_ib_line_id%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Install Base line id');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To get the Info all the fixed asset lines
      -- And the build the VFAV record
      OPEN  c_ib_info(r_get_ib_line_id.object1_id1,
                      r_get_ib_line_id.object1_id2);
      IF c_ib_info%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKX_INSTALL_ITEMS_V.OBJECT1_ID1');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      FETCH c_ib_info INTO r_ib_info;
      CLOSE c_ib_info;
      l_vibv_rec.major_version         := p_major_version;
      l_vibv_rec.ib_cle_id             := r_get_ib_line_id.id;
      l_vibv_rec.dnz_chr_id            := r_get_ib_line_id.dnz_chr_id;
      l_vibv_rec.name                  := r_ib_info.name;
      l_vibv_rec.description           := r_ib_info.description;
      l_vibv_rec.inventory_item_id     := r_ib_info.inventory_item_id;
      l_vibv_rec.current_serial_number := r_ib_info.serial_number;
      l_vibv_rec.install_site_use_id   := r_ib_info.install_location_id;
      l_vibv_rec.quantity              := r_ib_info.quantity;

      --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_vibv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      -- Now we are going to install into OKL_CONTRACT_IB_H table
      OKL_VERSION_IB_PUB.create_version_ib(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_vibv_rec      => l_vibv_rec,
                         x_vibv_rec      => lx_vibv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
   END LOOP;
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
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
  END Create_ib_version;
---------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : version_contract
-- Description     : creates new version of a contract (OKL part)
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE version_contract_extra(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_major_version  IN  NUMBER) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'OKL_VERSION_CREATE';

  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;
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
    --version contract header
    x_return_status:=OKL_KHR_PVT.Create_Version(p_chr_id,
                                                p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_HEADERS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_HEADERS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --version contract lines
    x_return_status:=OKL_KLE_PVT.Create_Version(p_chr_id,
                                                p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --version Supplier Invoice Details
    x_return_status:=OKL_SID_PVT.Create_Version(p_chr_id,
                                                p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_SUPP_INVOICE_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_SUPP_INVOICE_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Version Party Payment Hdr, fmiao
    x_return_status:=OKL_LDB_PVT.Create_Version(p_chr_id,
                                                p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_HDR_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_HDR_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------
    --Bug# 3143522
    ---------------
    --version party payment details
    x_return_status:=OKL_PYD_PVT.Create_Version(p_chr_id,
                                                p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------
    --End Bug# 3143522
    ---------------
    --------------
    --Bug# 4558486
    --------------
    --Version Okl_K_Party_Roles
    x_return_status:=OKL_KPL_PVT.Create_Version(p_chr_id,
                                                p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_PARTY_ROLES_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_PARTY_ROLES_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------
    --End Bug# 4558486
    --------------
    --------------
    --Bug# 3379716:
    ---------------
    --version streams
    OKL_STREAMS_PVT.version_stream(
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_khr_id            => p_chr_id,
      p_major_version     => p_major_version);

    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_STREAMS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_STREAMS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------
    --End Bug# 3379716:
    ---------------

    -- Versioning the Fixed asset Information
    Create_fa_version(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_major_version => p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_CONTRACT_ASSET_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_CONTRACT_ASSET_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  -- Versioning the Install Base information
    Create_ib_version(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_major_version => p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_CONTRACT_IB_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_CONTRACT_IB_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
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
  END version_contract_extra;
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : restore_version_extra
-- Description     : restores saved version of a contract for change request (OKL part)
-- Business Rules  : the number of the change request version is -1
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE restore_version_extra(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count	     OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_major_version  IN  NUMBER) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'OKL_RESTORE_VERSION';
  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;
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
    --version contract header
    x_return_status:=OKL_KHR_PVT.Restore_Version(p_chr_id,
                                                 p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_HEADERS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_HEADERS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --version contract lines
    x_return_status:=OKL_KLE_PVT.Restore_Version(p_chr_id,
                                                 p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status:=OKL_SID_PVT.Restore_Version(p_chr_id,
                                                 p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_SUPP_INVOICE_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_SUPP_INVOICE_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -------------
    --version party payment hdr,fmiao
    -------------
    x_return_status:=OKL_LDB_PVT.Restore_Version(p_chr_id,
                                                 p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_HDR_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_HDR_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -------------
    --Bug# 3143522
    -------------
    x_return_status:=OKL_PYD_PVT.Restore_Version(p_chr_id,
                                                 p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_PARTY_PAYMENT_DTLS_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -------------
    --End Bug# 3143522
    -------------

    -------------
    --Bug# 4558486
    -------------
    --Version Okl_K_Party_Roles
    x_return_status:=OKL_KPL_PVT.Restore_Version(p_chr_id,
                                                 p_major_version);
    --- If any errors happen abort API
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_PARTY_ROLES_H');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_RESTORE_VER_ERROR,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_K_PARTY_ROLES_H');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -------------
    --End Bug# 4558486
    -------------


--  More thought for Restore of OKL_CONTRACT_ASSET_H and
--  OKL_CONTRACT_IB_H tables is to be give so untill then we
--  not code for restore of these tables
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );

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
  END restore_version_extra;
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : delete_base
-- Description     : removes data from the base tables (OKL part)
-- Business Rules  : required prior to restoring data from a version
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_base(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'OKL_DELETE_BASE';
  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;
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
    -- Deleting the Header
    DELETE FROM OKL_K_HEADERS
    WHERE id = p_chr_id;
    -- Deleting the Lines
    DELETE FROM OKL_K_LINES
    WHERE id IN (SELECT id
                 FROM OKC_K_LINES_B
                 WHERE dnz_chr_id = p_chr_id);
    -- Deleting the supplier Invoice Details
    DELETE FROM OKL_SUPP_INVOICE_DTLS_H
    WHERE cle_id in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id);
    -- Deleting the FA Version
    DELETE FROM OKL_CONTRACT_ASSET_H
    WHERE DNZ_CHR_ID = p_chr_id;
    -- Deleting the IB VERSION
    DELETE FROM OKL_CONTRACT_IB_H
    WHERE DNZ_CHR_ID = p_chr_id;
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_DELETE_BASE_ERROR);
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_DELETE_BASE_ERROR);
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END delete_base;
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : delete_version
-- Description     : removes data from the history tables (OKL part)
-- Business Rules  : required after the version is created
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_version (
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN NUMBER,
            p_major_version  IN NUMBER,
	    p_minor_version  IN NUMBER,
	    p_called_from    IN VARCHAR2) IS
    l_major_version           NUMBER := p_major_version;
    l_minor_version           NUMBER := p_minor_version;
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'OKL_DELETE_VERSION';
  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;
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
    -- Deleting the Header
    DELETE FROM OKL_K_HEADERS_H
    WHERE id= p_chr_id
    AND ((MAJOR_VERSION = -1
    AND p_called_from = 'ERASE_SAVED_VERSION') OR
        (p_called_from = 'RESTORE_VERSION'
        AND (major_version >= l_major_version OR
        major_version = -1)));
    -- Deleting the Lines
    DELETE FROM OKL_K_LINES_H
    WHERE ID in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id)
    AND ((MAJOR_VERSION = -1
        AND p_called_from = 'ERASE_SAVED_VERSION') OR
        (p_called_from = 'RESTORE_VERSION'
        AND (major_version >= l_major_version OR
        major_version = -1)));
    -- Deleting the supplier Invoice Details
    DELETE FROM OKL_SUPP_INVOICE_DTLS_H
    WHERE cle_id in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id)
    AND ((MAJOR_VERSION = -1
        AND p_called_from = 'ERASE_SAVED_VERSION') OR
        (p_called_from = 'RESTORE_VERSION'
        AND (major_version >= l_major_version OR
        major_version = -1)));
    -- Deleting the FA Version
    DELETE FROM OKL_CONTRACT_ASSET_H
    WHERE DNZ_CHR_ID = p_chr_id
    AND ((MAJOR_VERSION = -1
        AND p_called_from = 'ERASE_SAVED_VERSION') OR
        (p_called_from = 'RESTORE_VERSION'
        AND (major_version >= l_major_version OR
        major_version = -1)));
    -- Deleting the IB VERSION
    DELETE FROM OKL_CONTRACT_IB_H
    WHERE DNZ_CHR_ID = p_chr_id
    AND ((MAJOR_VERSION = -1
        AND p_called_from = 'ERASE_SAVED_VERSION') OR
        (p_called_from = 'RESTORE_VERSION'
        AND (major_version >= l_major_version OR
        major_version = -1)));
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    OKL_API.set_message(p_app_name => G_APP_NAME,
                        p_msg_name => G_DELETE_VER_ERROR);
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
    OKL_API.set_message(p_app_name => G_APP_NAME,
                        p_msg_name => G_DELETE_VER_ERROR);
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END delete_version;
----------------------------------------------------------------------------------------
--------------------------------- Version Creation -------------------------------------
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : version_contract
-- Description     : creates new version of a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE version_contract(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cvmv_rec       IN  cvmv_rec_type,
            x_cvmv_rec       OUT NOCOPY cvmv_rec_type,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'VERSION_CONTRACT';
    l_chr_id                  NUMBER;
    l_major_version           NUMBER;
    lv_sts_code               OKC_K_HEADERS_V.STS_CODE%TYPE;
    CURSOR c_get_sts_code(p_chr_id OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT st.ste_code
    FROM OKC_K_HEADERS_V chr,
         okc_statuses_b st
    WHERE chr.id = p_chr_id
    and st.code = chr.sts_code;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Get the sts code since we can version only active contract
    OPEN  c_get_sts_code(p_cvmv_rec.chr_id);
    IF c_get_sts_code%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_HEADERS_V.STS_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_get_sts_code INTO lv_sts_code;
    CLOSE c_get_sts_code;
    IF lv_sts_code = 'ACTIVE' THEN
      -- Create the version of the OKC part
      OKL_OKC_MIGRATION_PVT.version_contract(
                      p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_cvmv_rec       => p_cvmv_rec,
                      p_commit         => OKL_API.G_FALSE,
                      x_cvmv_rec       => x_cvmv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Create the version of the OKL part
      l_chr_id         :=x_cvmv_rec.chr_id;
      l_major_version  :=x_cvmv_rec.major_version;
      version_contract_extra(p_api_version    => p_api_version,
                             p_init_msg_list  => OKL_API.G_FALSE,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_chr_id         => l_chr_id,
                             p_major_version  => l_major_version);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_STATUS,
                          p_token1       => 'STATUS',
                          p_token1_value => lv_sts_code);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
--    IF (p_commit = OKL_API.G_TRUE) THEN
--       COMMIT;
--    END IF;
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
  END Version_Contract;
----------------------------------------------------------------------------------------
----------------------------------- Save Version ---------------------------------------
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : save_version
-- Description     : save new version of a contract for change request
-- Business Rules  : the number of the change request version is -1
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE save_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE) IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'SAVE_VERSION';
    l_major_version  CONSTANT NUMBER := -1;
    l_chr_id                  NUMBER := p_chr_id;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_version(p_api_version   => l_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_chr_id        => p_chr_id,
		   p_major_version => -1,
		   p_minor_version => null,
		   p_called_from   => 'ERASE_SAVED_VERSION');

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_VERSION_PUB.save_version(
                     p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_chr_id         => p_chr_id,
                     p_commit         => OKL_API.G_FALSE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    version_contract_extra(p_api_version    => p_api_version,
                           p_init_msg_list  => OKL_API.G_FALSE,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_chr_id         => l_chr_id,
                           p_major_version  => l_major_version);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
--    IF (p_commit = OKL_API.G_TRUE) THEN
--       COMMIT;
--    END IF;
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
  END Save_Version;
----------------------------------------------------------------------------------------
------------------------------- Erase Saved Version ------------------------------------
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : erase_saved_version
-- Description     : erases the saved version of a contract for change request
-- Business Rules  : the number of the change request version is -1
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE erase_saved_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ERASE_SAVED_VERSION';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_version(p_api_version    => l_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_chr_id         => p_chr_id,
		   p_major_version  => -1,
		   p_minor_version  => null,
		   p_called_from    => 'ERASE_SAVED_VERSION');
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_VERSION_PUB.erase_saved_version(
                    p_chr_id        => p_chr_id,
                    p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    p_commit        => OKL_API.G_FALSE,
                    x_msg_data      => x_msg_data);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
--    IF (p_commit = OKL_API.G_TRUE) THEN
--       COMMIT;
--    END IF;
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
  END erase_saved_version;
----------------------------------------------------------------------------------------
---------------------------------- Restore Version -------------------------------------
----------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : restore_version
-- Description     : restores saved version of a contract for change request
-- Business Rules  : the number of the change request version is -1
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE restore_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE)  IS
    l_api_version    CONSTANT NUMBER := 1;
    l_api_name       CONSTANT VARCHAR2(30) := 'RESTORE_VERSION';
    l_chr_id                  NUMBER;
    l_major_version           NUMBER;
    l_minor_version           NUMBER;
    l_minus_version           NUMBER;
    cursor v_csr is
    SELECT object_version_number,
           minor_version
    FROM okc_k_vers_numbers_h
    WHERE chr_id= p_chr_id
    AND MAJOR_VERSION = -1;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OPEN v_csr;
    FETCH v_csr into l_major_version,
                     l_minor_version;
    CLOSE v_csr;
    delete_base(p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_chr_id        => p_chr_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_VERSION_PUB.restore_version(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_chr_id         => p_chr_id,
		    p_commit         => OKL_API.G_FALSE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_chr_id        := p_chr_id;
    l_minus_version := -1;
    restore_version_extra(p_api_version    => p_api_version,
                          p_init_msg_list  => OKL_API.G_FALSE,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_chr_id         => l_chr_id,
                          p_major_version  => l_minus_version);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_version(p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_chr_id        => p_chr_id,
		   p_major_version => l_major_version,
		   p_minor_version => l_minor_version,
		   p_called_from   => 'RESTORE_VERSION');
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
--    IF (p_commit = OKL_API.G_TRUE) THEN
--       COMMIT;
--    END IF;
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
  END restore_version;
END okl_version_pvt;

/

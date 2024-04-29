--------------------------------------------------------
--  DDL for Package Body OKL_ASSET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASSET_DETAILS_PVT" AS
/* $Header: OKLRADSB.pls 115.5 2002/12/18 14:43:01 spillaip noship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_ASSET_DETAILS_PUB';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  subtype klev_rec_type is OKL_CREATE_KLE_PVT.klev_rec_type;
  subtype klev_tbl_type is OKL_CREATE_KLE_PVT.klev_tbl_type;
  subtype clev_rec_type is OKL_CREATE_KLE_PVT.clev_rec_type;
  subtype clev_tbl_type is OKL_CREATE_KLE_PVT.clev_tbl_type;
  subtype cimv_rec_type is OKL_CREATE_KLE_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKL_CREATE_KLE_PVT.cimv_tbl_type;
  subtype cplv_rec_type is OKL_CREATE_KLE_PVT.cplv_rec_type;
  subtype trxv_rec_type is OKL_CREATE_KLE_PVT.trxv_rec_type;
  subtype talv_rec_type is OKL_CREATE_KLE_PVT.talv_rec_type;
  subtype itiv_rec_type is OKL_CREATE_KLE_PVT.itiv_rec_type;
  subtype itiv_tbl_type is OKL_CREATE_KLE_PVT.itiv_tbl_type;


  PROCEDURE Update_year(
                      p_api_version            IN  NUMBER,
                      p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status          OUT NOCOPY VARCHAR2,
                      x_msg_count              OUT NOCOPY NUMBER,
                      x_msg_data               OUT NOCOPY VARCHAR2,
                      p_dnz_chr_id             IN  NUMBER,
                      p_parent_line_id         IN  NUMBER,
                      p_year                   IN  VARCHAR2,
                      x_year                   OUT NOCOPY VARCHAR2)  IS

   subtype klev_rec_type is okl_CONTRACT_PVT.klev_rec_type;

    l_klev_rec       klev_rec_type;
    l_clev_rec       okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec      klev_rec_type;
    lx_clev_rec      okl_okc_migration_pvt.clev_rec_type;

    l_api_name            CONSTANT VARCHAR2(30)  := 'UPDATE_YEAR';


 BEGIN
   x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_klev_rec.id                   := p_parent_line_id;
    l_klev_rec.year_built           := p_year;

    l_clev_rec.id                   := p_parent_line_id;

    OKL_CONTRACT_PUB.update_contract_line(
                                          p_api_version        => p_api_version,
                                          p_init_msg_list      => p_init_msg_list,
                                          x_return_status      => x_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data,
                                          p_clev_rec           => l_clev_rec,
                                          p_klev_rec           => l_klev_rec,
                                          x_clev_rec           => lx_clev_rec,
                                          x_klev_rec           => lx_klev_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_year   := lx_klev_rec.year_built;

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
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');

 END Update_year;

 PROCEDURE update_tax(p_api_version            IN  NUMBER,
                     p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status          OUT NOCOPY VARCHAR2,
                     x_msg_count              OUT NOCOPY NUMBER,
                     x_msg_data               OUT NOCOPY VARCHAR2,
                     p_rule_id                IN  NUMBER,
                     p_rule_grp_id            IN  NUMBER,
                     p_dnz_chr_id             IN  NUMBER,
                     p_rule_information1      IN  VARCHAR2,
                     p_rule_information2      IN  VARCHAR2,
                     p_rule_information3      IN  VARCHAR2,
                     p_rule_information4      IN  VARCHAR2,
                     x_rule_information1      OUT  NOCOPY VARCHAR2,
                     x_rule_information2      OUT  NOCOPY VARCHAR2,
                     x_rule_information3      OUT  NOCOPY VARCHAR2,
                     x_rule_information4      OUT  NOCOPY VARCHAR2) IS

 SUBTYPE  rule_rec_type IS OKL_RULE_PUB.rulv_rec_type;

 l_rule_rec      rule_rec_type;
 lx_rule_rec     rule_rec_type;
 l_api_name            CONSTANT VARCHAR2(30)  := 'UPDATE_TAX';

 BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_rule_rec.id                := p_rule_id;
    l_rule_rec.rgp_id            := p_rule_grp_id;
    l_rule_rec.rule_information1 := p_rule_information1;
    l_rule_rec.rule_information2 := p_rule_information2;
    l_rule_rec.rule_information3 := p_rule_information3;
    l_rule_rec.rule_information4 := p_rule_information4;



    OKL_RULE_PUB.update_rule(
                      p_api_version          => p_api_version,
                      p_init_msg_list        => p_init_msg_list,
                      x_return_status        => x_return_status,
                      x_msg_count            => x_msg_count,
                      x_msg_data             => x_msg_data,
                      p_rulv_rec             => l_rule_rec,
                      x_rulv_rec             => lx_rule_rec);



    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_rule_information1   := lx_rule_rec.rule_information1;
    x_rule_information2   := lx_rule_rec.rule_information2;
    x_rule_information3   := lx_rule_rec.rule_information3;
    x_rule_information4   := lx_rule_rec.rule_information4;

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
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');


  END update_tax;

  PROCEDURE update_asset(p_api_version            IN     NUMBER,
                         p_init_msg_list          IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status          OUT    NOCOPY VARCHAR2,
                         x_msg_count              OUT    NOCOPY NUMBER,
                         x_msg_data               OUT    NOCOPY VARCHAR2,
                         p_asset_id               IN     NUMBER,
                         p_asset_number           IN     VARCHAR2,
-- SPILLAIP - 2689257 - Start
                         px_asset_desc            IN OUT NOCOPY VARCHAR2,
                         px_model_no              IN OUT NOCOPY VARCHAR2,
                         px_manufacturer          IN OUT NOCOPY VARCHAR2) IS
-- SPILLAIP - 2689257 - End

  l_trans_rec            FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec        FA_API_TYPES.asset_hdr_rec_type;
  l_asset_desc_rec       FA_API_TYPES.asset_desc_rec_type;
  l_asset_type_rec       FA_API_TYPES.asset_type_rec_type;
  l_asset_cat_rec        FA_API_TYPES.asset_cat_rec_type;

  l_commit_flag         VARCHAR2(5)   := FND_API.G_FALSE;
  l_validation_level    VARCHAR2(5)   := FND_API.G_VALID_LEVEL_FULL;
  l_calling_fn          VARCHAR2(50)  := 'Update Asset Desc Wrapper';

  l_api_name            CONSTANT VARCHAR2(30)  := 'UPDATE_ASSET';

  BEGIN
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PUB'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_asset_hdr_rec.asset_id            := p_asset_id;

    l_asset_desc_rec.model_number       := px_model_no;
    l_asset_desc_rec.manufacturer_name  := px_manufacturer;

    If px_asset_desc is not null AND px_asset_desc <> OKL_API.G_MISS_CHAR THEN
        l_asset_desc_rec.description    := px_asset_desc;
    end if;

	--One parameter has been commented becasue the FA APi has been changed.
	--change done by rvaduri

    fa_asset_desc_pub.update_desc(
                                  p_api_version         => p_api_version,
                                  p_commit              => l_commit_flag,
                                  p_validation_level    => l_validation_level,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
                                  p_calling_fn          => l_calling_fn,
                                  px_trans_rec          => l_trans_rec,
                                  px_asset_hdr_rec      => l_asset_hdr_rec,
                                  px_asset_desc_rec_new => l_asset_desc_rec,
                      --            px_asset_type_rec_new => l_asset_type_rec,
                                  px_asset_cat_rec_new  => l_asset_cat_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    px_model_no         :=  l_asset_desc_rec.model_number;
    px_manufacturer     :=  l_asset_desc_rec.manufacturer_name;

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
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');


  END update_asset;

END   okl_asset_details_pvt;

/

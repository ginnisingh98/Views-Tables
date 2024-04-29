--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_PARTIES_PVT" as
/* $Header: OKLRDPRB.pls 120.3 2007/06/21 18:43:09 asahoo noship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_INVALID_CRITERIA            CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
  G_FND_APP                     CONSTANT  VARCHAR2(200) :=  OKL_API.G_FND_APP;
  G_INVALID_VALUE               CONSTANT  VARCHAR2(200) :=  OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
-------------------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
-------------------------------------------------------------------------------------------------
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_LLA_AST_SERIAL              CONSTANT  VARCHAR2(200) := 'OKL_LLA_AST_SERIAL';
  G_MISSING_CONTRACT            CONSTANT  VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_FOUND';
  G_CONTRACT_ID_TOKEN           CONSTANT  VARCHAR2(30)  := 'CONTRACT_ID';
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
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_DEAL_PARTIES_PVT';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
-------------------------------------------------------------------------------------------------

PROCEDURE process_label_holder(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  party_role_rec_type,
    x_rgpv_rec                     OUT NOCOPY party_role_rec_type) IS

  l_api_name         VARCHAR2(30) := 'process_label_holder';
  l_api_version      CONSTANT NUMBER    := 1.0;

  CURSOR c_get_rrd_id(p_chr_id NUMBER, p_rle_code VARCHAR2, p_rgd_code VARCHAR2) IS
  SELECT rgrdfs.id
  FROM okc_k_headers_b chr,
       okc_subclass_roles sre,
       okc_role_sources rse,
       okc_subclass_rg_defs rgdfs,
       okc_rg_role_defs rgrdfs
  WHERE chr.id = p_chr_id
  AND sre.scs_code = chr.scs_code
  AND sre.rle_code = rse.rle_code
  AND rse.rle_code = p_rle_code
  AND rse.buy_or_sell = chr.buy_or_sell
  AND rgdfs.scs_code = chr.scs_code
  AND rgdfs.rgd_code = p_rgd_code
  AND rgrdfs.srd_id = rgdfs.id
  AND rgrdfs.sre_id = sre.id;

  CURSOR c_label_holder(p_chr_id NUMBER, p_rle_code VARCHAR2) IS
  SELECT 'Y'
  FROM OKC_K_PARTY_ROLES_B
  WHERE dnz_chr_id = p_chr_id
  AND chr_id = p_chr_id
  AND rle_code = p_rle_code;

  l_party_found VARCHAR2(1);
  l_rrd_id NUMBER;

  lp_lalabl_rgpv_rec  OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
  lx_lalabl_rgpv_rec  OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

  lp_lalogo_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lalogo_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
  lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

  lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
  lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

  lp_rmpv_rec  OKL_OKC_MIGRATION_PVT.rmpv_rec_type;
  lx_rmpv_rec  OKL_OKC_MIGRATION_PVT.rmpv_rec_type;

  l_msg_data VARCHAR2(4000);
  l_msg_index_out number;

BEGIN
    x_rgpv_rec := p_rgpv_rec;
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

       OPEN c_label_holder(p_chr_id   => p_rgpv_rec.chr_id,
                           p_rle_code => 'PRIVATE_LABEL');
       FETCH c_label_holder INTO l_party_found;
       CLOSE c_label_holder;

       IF (l_party_found = 'Y') THEN
           OKL_API.set_message(
                  p_app_name      => G_APP_NAME,
                  p_msg_name      => 'OKL_LLA_PVT_LBL');
        RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       lp_cplv_rec.id                 := p_rgpv_rec.party_role_id;
       lp_cplv_rec.object1_id1        := p_rgpv_rec.party_id;
       lp_cplv_rec.object1_id2        := '#';
       lp_cplv_rec.jtot_object1_code  := 'OKX_PARTY';
       lp_cplv_rec.rle_code           := 'PRIVATE_LABEL';
       lp_cplv_rec.dnz_chr_id         := p_rgpv_rec.chr_id;
       lp_cplv_rec.chr_id             := p_rgpv_rec.chr_id;
       lp_kplv_rec.attribute_category := p_rgpv_rec.attribute_category;
       lp_kplv_rec.attribute1         := p_rgpv_rec.attribute1;
       lp_kplv_rec.attribute2         := p_rgpv_rec.attribute2;
       lp_kplv_rec.attribute3         := p_rgpv_rec.attribute3;
       lp_kplv_rec.attribute4         := p_rgpv_rec.attribute4;
       lp_kplv_rec.attribute5         := p_rgpv_rec.attribute5;
       lp_kplv_rec.attribute6         := p_rgpv_rec.attribute6;
       lp_kplv_rec.attribute7         := p_rgpv_rec.attribute7;
       lp_kplv_rec.attribute8         := p_rgpv_rec.attribute8;
       lp_kplv_rec.attribute9         := p_rgpv_rec.attribute9;
       lp_kplv_rec.attribute10        := p_rgpv_rec.attribute10;
       lp_kplv_rec.attribute11        := p_rgpv_rec.attribute11;
       lp_kplv_rec.attribute12        := p_rgpv_rec.attribute12;
       lp_kplv_rec.attribute13        := p_rgpv_rec.attribute13;
       lp_kplv_rec.attribute14        := p_rgpv_rec.attribute14;
       lp_kplv_rec.attribute15        := p_rgpv_rec.attribute15;
       lp_kplv_rec.validate_dff_yn    := 'Y';

    IF (p_rgpv_rec.party_role_id IS NULL) THEN
       OKL_K_PARTY_ROLES_PVT.create_k_party_role(
         p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         p_cplv_rec         => lp_cplv_rec,
         x_cplv_rec         => lx_cplv_rec,
         p_kplv_rec         => lp_kplv_rec,
         x_kplv_rec         => lx_kplv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
    ELSE

       OKL_K_PARTY_ROLES_PVT.update_k_party_role(
         p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         p_cplv_rec         => lp_cplv_rec,
         x_cplv_rec         => lx_cplv_rec,
         p_kplv_rec         => lp_kplv_rec,
         x_kplv_rec         => lx_kplv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    END IF;

    IF (p_rgpv_rec.rgp_id IS NULL) THEN
    -- Create LALABL rule group
       lp_lalabl_rgpv_rec.id := NULL;
       lp_lalabl_rgpv_rec.rgd_code := 'LALABL';
       lp_lalabl_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
       lp_lalabl_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
       lp_lalabl_rgpv_rec.rgp_type := 'KRG';

       OKL_RULE_PUB.create_rule_group(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_rgpv_rec       => lp_lalabl_rgpv_rec,
           x_rgpv_rec       => lx_lalabl_rgpv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         x_rgpv_rec.rgp_id := lx_lalabl_rgpv_rec.id;

    ELSE

    -- Update LALABL rule group
       lp_lalabl_rgpv_rec.id := p_rgpv_rec.rgp_id;
       lp_lalabl_rgpv_rec.rgd_code := 'LALABL';
       lp_lalabl_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
       lp_lalabl_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
       lp_lalabl_rgpv_rec.rgp_type := 'KRG';

       OKL_RULE_PUB.update_rule_group(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_rgpv_rec       => lp_lalabl_rgpv_rec,
           x_rgpv_rec       => lx_lalabl_rgpv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

         x_rgpv_rec.rgp_id := lx_lalabl_rgpv_rec.id;

    END IF;

    IF (p_rgpv_rec.rul_lalogo_id IS NULL) THEN
      -- Create LALOGO rule
      lp_lalogo_rulv_rec.id := NULL;
      lp_lalogo_rulv_rec.rgp_id := lx_lalabl_rgpv_rec.id;
      lp_lalogo_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lalogo_rulv_rec.rule_information_category := 'LALOGO';
      lp_lalogo_rulv_rec.rule_information1 := p_rgpv_rec.lalogo_rule_information1;
      lp_lalogo_rulv_rec.WARN_YN := 'N';
      lp_lalogo_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lalogo_rulv_rec,
        x_rulv_rec       => lx_lalogo_rulv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lalogo_id := lx_lalogo_rulv_rec.id;

    ELSE

      -- Update LALOGO rule
      lp_lalogo_rulv_rec.id := p_rgpv_rec.rul_lalogo_id;
      lp_lalogo_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_lalogo_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lalogo_rulv_rec.rule_information_category := 'LALOGO';
      lp_lalogo_rulv_rec.rule_information1 := p_rgpv_rec.lalogo_rule_information1;
      lp_lalogo_rulv_rec.WARN_YN := 'N';
      lp_lalogo_rulv_rec.STD_TEMPLATE_YN := 'N';

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lalogo_rulv_rec,
        x_rulv_rec       => lx_lalogo_rulv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lalogo_id := lx_lalogo_rulv_rec.id;

    END IF;


    IF (p_rgpv_rec.rgp_id IS NULL) THEN
        OPEN c_get_rrd_id(p_rgpv_rec.chr_id, 'PRIVATE_LABEL', 'LALABL');
        FETCH c_get_rrd_id INTO l_rrd_id;
        CLOSE c_get_rrd_id;

        lp_rmpv_rec.rgp_id     := x_rgpv_rec.rgp_id;
        --lp_rmpv_rec.cpl_id     := p_rgpv_rec.party_id;
        lp_rmpv_rec.cpl_id := lx_cplv_rec.id;
        lp_rmpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
        lp_rmpv_rec.rrd_id     := l_rrd_id;

        OKL_RULE_PUB.create_rg_mode_pty_role(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rmpv_rec       => lp_rmpv_rec,
          x_rmpv_rec       => lx_rmpv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

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
END process_label_holder;


PROCEDURE load_guarantor(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      p_party_id                   IN  NUMBER,
      x_party_role_rec             OUT NOCOPY party_role_rec_type) IS

  l_api_name         VARCHAR2(30)     := 'load_guarantor';
  l_api_version      CONSTANT NUMBER  := 1.0;

  CURSOR c_rule(p_chr_id NUMBER, p_rgd_code VARCHAR2, p_rule_info_cat VARCHAR2, p_rgp_id NUMBER) IS
  SELECT rul.rgp_id,rgp.rgd_code,rul.ID,rul.object1_id1,rul.object1_id2,rul.jtot_object1_code,
         rul.rule_information_category,rul.rule_information1,rul.rule_information2,rul.rule_information3,
         rul.rule_information4
  FROM  okc_rules_b rul,
        okc_rule_groups_b rgp
  WHERE rgp.chr_id = p_chr_id
  AND   rgp.id = p_rgp_id
  AND   rgp.dnz_chr_id = p_chr_id
  AND   rgp.rgd_code = p_rgd_code
  AND   rgp.id = rul.rgp_id
  AND   rgp.dnz_chr_id = rul.dnz_chr_id
  AND   rul.rule_information_category = p_rule_info_cat;

  l_rule c_rule%ROWTYPE;

  CURSOR c_party_role_info(p_chr_id NUMBER, p_rle_code VARCHAR2, p_party_id NUMBER) IS
  SELECT okc_party_roles.id,object1_id1,object1_id2,jtot_object1_code,okl_party_roles.attribute_category,
         okl_party_roles.attribute1,okl_party_roles.attribute2,okl_party_roles.attribute3,okl_party_roles.attribute4,
         okl_party_roles.attribute5,okl_party_roles.attribute6,okl_party_roles.attribute7,okl_party_roles.attribute8,
	 okl_party_roles.attribute9,okl_party_roles.attribute10,okl_party_roles.attribute11,okl_party_roles.attribute12,
	 okl_party_roles.attribute13,okl_party_roles.attribute14,okl_party_roles.attribute15
  FROM okc_k_party_roles_b okc_party_roles,
       okl_k_party_roles okl_party_roles
  WHERE okc_party_roles.dnz_chr_id = p_chr_id
  AND okc_party_roles.cle_id is null
  AND okc_party_roles.rle_code = p_rle_code
  AND okc_party_roles.id = okl_party_roles.id
  AND okc_party_roles.object1_id1 = p_party_id;

  l_party_role_info c_party_role_info%ROWTYPE;

  CURSOR c_party_site(p_party_site_id NUMBER) IS
  SELECT party_site_number
  FROM hz_party_sites
  WHERE party_site_id = p_party_site_id;

  CURSOR c_party_name(p_party_id NUMBER) IS
  SELECT party_name
  FROM hz_parties
  WHERE party_id = p_party_id;

  CURSOR c_get_rrd_id(p_chr_id NUMBER, p_rle_code VARCHAR2, p_rgd_code VARCHAR2) IS
  SELECT rgrdfs.id
  FROM okc_k_headers_b chr,
       okc_subclass_roles sre,
       okc_role_sources rse,
       okc_subclass_rg_defs rgdfs,
       okc_rg_role_defs rgrdfs
  WHERE chr.id = p_chr_id
  AND sre.scs_code = chr.scs_code
  AND sre.rle_code = rse.rle_code
  AND rse.rle_code = p_rle_code
  AND rse.buy_or_sell = chr.buy_or_sell
  AND rgdfs.scs_code = chr.scs_code
  AND rgdfs.rgd_code = p_rgd_code
  AND rgrdfs.srd_id = rgdfs.id
  AND rgrdfs.sre_id = sre.id;

  CURSOR c_rgp_id(p_rrd_id NUMBER, p_dnz_chr_id NUMBER, p_cpl_id NUMBER) IS
  SELECT rgp_id
  FROM okc_rg_party_roles
  WHERE rrd_id = p_rrd_id
  AND dnz_chr_id = p_dnz_chr_id
  AND cpl_id = p_cpl_id;

  l_rrd_id NUMBER;
  l_rgp_id NUMBER;

  l_msg_data VARCHAR2(4000);
  l_msg_index_out number;
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

    x_party_role_rec.chr_id     := p_chr_id;
    x_party_role_rec.party_role := OKL_LLA_UTIL_PVT.GET_LOOKUP_MEANING('OKC_ROLE','GUARANTOR');

    --Open the Cursor to get party_role_id
    OPEN c_party_role_info(p_chr_id, 'GUARANTOR', p_party_id);
    FETCH c_party_role_info INTO l_party_role_info;
    x_party_role_rec.party_role_id      := l_party_role_info.id;
    x_party_role_rec.party_id           := l_party_role_info.object1_id1;
    x_party_role_rec.attribute_category := l_party_role_info.attribute_category;
    x_party_role_rec.attribute1         := l_party_role_info.attribute1;
    x_party_role_rec.attribute2         := l_party_role_info.attribute2;
    x_party_role_rec.attribute3         := l_party_role_info.attribute3;
    x_party_role_rec.attribute4         := l_party_role_info.attribute4;
    x_party_role_rec.attribute5         := l_party_role_info.attribute5;
    x_party_role_rec.attribute6         := l_party_role_info.attribute6;
    x_party_role_rec.attribute7         := l_party_role_info.attribute7;
    x_party_role_rec.attribute8         := l_party_role_info.attribute8;
    x_party_role_rec.attribute9         := l_party_role_info.attribute9;
    x_party_role_rec.attribute10        := l_party_role_info.attribute10;
    x_party_role_rec.attribute11        := l_party_role_info.attribute11;
    x_party_role_rec.attribute12        := l_party_role_info.attribute12;
    x_party_role_rec.attribute13        := l_party_role_info.attribute13;
    x_party_role_rec.attribute14        := l_party_role_info.attribute14;
    x_party_role_rec.attribute15        := l_party_role_info.attribute15;
    CLOSE c_party_role_info;

    --Open the Cursor to get rrd_id
    OPEN c_get_rrd_id(p_chr_id, 'GUARANTOR', 'LAGRDT');
    FETCH c_get_rrd_id INTO l_rrd_id;
    CLOSE c_get_rrd_id;

    --Open the Cursor to get rgp_id
    OPEN c_rgp_id(p_rrd_id     => l_rrd_id,
                  p_dnz_chr_id => p_chr_id,
                  p_cpl_id     => x_party_role_rec.party_role_id);
    FETCH c_rgp_id INTO l_rgp_id;
    CLOSE c_rgp_id;

    OPEN c_rule(p_chr_id, 'LAGRDT', 'LAGRNP', l_rgp_id);
    FETCH c_rule INTO l_rule;
    x_party_role_rec.rgp_id                   := l_rule.rgp_id;
    x_party_role_rec.rgp_lagrdt_lagrnp_id     := l_rule.rgp_id;
    x_party_role_rec.rgp_lagrdt_lagrnt_id     := l_rule.rgp_id;
    x_party_role_rec.rul_lagrnp_id            := l_rule.id;
    x_party_role_rec.rul_lagrnp_object1_id1   := l_rule.object1_id1;
    x_party_role_rec.rul_lagrnp_object1_id2   := l_rule.object1_id2;
    x_party_role_rec.lagrnp_rule_info_cat     := l_rule.rule_information_category;
    x_party_role_rec.lagrnp_rule_information1 := l_rule.rule_information1;
    CLOSE c_rule;

    OPEN c_rule(p_chr_id, 'LAGRDT', 'LAGRNT',l_rgp_id);
    FETCH c_rule INTO l_rule;
    x_party_role_rec.rul_lagrnt_id            := l_rule.id;
    x_party_role_rec.lagrnt_rule_info_cat     := l_rule.rule_information_category;
    x_party_role_rec.lagrnt_rule_information1 := l_rule.rule_information1;
    x_party_role_rec.lagrnt_rule_information2 := l_rule.rule_information2;
    x_party_role_rec.lagrnt_rule_information3 := l_rule.rule_information3;
    x_party_role_rec.lagrnt_rule_information4 := l_rule.rule_information4;
    CLOSE c_rule;


    OPEN c_party_site(x_party_role_rec.rul_lagrnp_object1_id1);
    FETCH c_party_site INTO x_party_role_rec.party_site_number;
    CLOSE c_party_site;

    OPEN c_party_name(x_party_role_rec.party_id);
    FETCH c_party_name INTO x_party_role_rec.party_name;
    CLOSE c_party_name;

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

END load_guarantor;

PROCEDURE process_guarantor(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_rgpv_rec                   IN  party_role_rec_type,
      x_rgpv_rec                   OUT NOCOPY party_role_rec_type) IS

  l_api_name         VARCHAR2(30) := 'process_gurantor';
  l_api_version      CONSTANT NUMBER    := 1.0;

  lp_lagrdt_rgpv_rec  OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
  lx_lagrdt_rgpv_rec  OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

  lp_lagrnp_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lagrnp_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_lagrnt_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lagrnt_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
  lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

  lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
  lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

  lp_rmpv_rec  OKL_OKC_MIGRATION_PVT.rmpv_rec_type;
  lx_rmpv_rec  OKL_OKC_MIGRATION_PVT.rmpv_rec_type;

  CURSOR c_get_rrd_id(p_chr_id NUMBER, p_rle_code VARCHAR2, p_rgd_code VARCHAR2) IS
  SELECT rgrdfs.id
  FROM okc_k_headers_b chr,
       okc_subclass_roles sre,
       okc_role_sources rse,
       okc_subclass_rg_defs rgdfs,
       okc_rg_role_defs rgrdfs
  WHERE chr.id = p_chr_id
  AND sre.scs_code = chr.scs_code
  AND sre.rle_code = rse.rle_code
  AND rse.rle_code = p_rle_code
  AND rse.buy_or_sell = chr.buy_or_sell
  AND rgdfs.scs_code = chr.scs_code
  AND rgdfs.rgd_code = p_rgd_code
  AND rgrdfs.srd_id = rgdfs.id
  AND rgrdfs.sre_id = sre.id;

  l_rrd_id NUMBER;

  l_msg_data VARCHAR2(4000);
  l_msg_index_out number;
BEGIN
    x_rgpv_rec := p_rgpv_rec;
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
    -- Create LAGRDT rule group
       lp_lagrdt_rgpv_rec.id := NULL;
       lp_lagrdt_rgpv_rec.rgd_code := 'LAGRDT';
       lp_lagrdt_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
       lp_lagrdt_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
       lp_lagrdt_rgpv_rec.rgp_type := 'KRG';

       OKL_RULE_PUB.create_rule_group(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_rgpv_rec       => lp_lagrdt_rgpv_rec,
           x_rgpv_rec       => lx_lagrdt_rgpv_rec);

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         x_rgpv_rec.rgp_id := lx_lagrdt_rgpv_rec.id;

    ELSE

    -- Update LAGRDT rule group
       lp_lagrdt_rgpv_rec.id := p_rgpv_rec.rgp_id;
       lp_lagrdt_rgpv_rec.rgd_code := 'LAGRDT';
       lp_lagrdt_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
       lp_lagrdt_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
       lp_lagrdt_rgpv_rec.rgp_type := 'KRG';

       OKL_RULE_PUB.update_rule_group(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_rgpv_rec       => lp_lagrdt_rgpv_rec,
           x_rgpv_rec       => lx_lagrdt_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

         x_rgpv_rec.rgp_id := lx_lagrdt_rgpv_rec.id;

    END IF;

    IF (p_rgpv_rec.rul_lagrnp_id IS NULL) THEN
      -- Create LAGRNP rule
      lp_lagrnp_rulv_rec.id := NULL;
      lp_lagrnp_rulv_rec.rgp_id := lx_lagrdt_rgpv_rec.id;
      lp_lagrnp_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lagrnp_rulv_rec.rule_information_category := 'LAGRNP';
      lp_lagrnp_rulv_rec.rule_information1 := p_rgpv_rec.lagrnp_rule_information1;
      lp_lagrnp_rulv_rec.WARN_YN := 'N';
      lp_lagrnp_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lagrnp_object1_id1 IS NOT NULL) AND ( p_rgpv_rec.rul_lagrnp_object1_id2 IS NOT NULL)) THEN
         lp_lagrnp_rulv_rec.object1_id1 := p_rgpv_rec.rul_lagrnp_object1_id1;
         lp_lagrnp_rulv_rec.object1_id2 := '#';
         lp_lagrnp_rulv_rec.jtot_object1_code := 'OKL_PARTYSITE';
      END IF;

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lagrnp_rulv_rec,
        x_rulv_rec       => lx_lagrnp_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lagrnp_id := lx_lagrnp_rulv_rec.id;

    ELSE

      -- Update LAGRNP rule
      lp_lagrnp_rulv_rec.id := p_rgpv_rec.rul_lagrnp_id;
      lp_lagrnp_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_lagrnp_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lagrnp_rulv_rec.rule_information_category := 'LAGRNP';
      lp_lagrnp_rulv_rec.rule_information1 := p_rgpv_rec.lagrnp_rule_information1;
      lp_lagrnp_rulv_rec.WARN_YN := 'N';
      lp_lagrnp_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lagrnp_object1_id1 IS NOT NULL) AND ( p_rgpv_rec.rul_lagrnp_object1_id2 IS NOT NULL)) THEN
         lp_lagrnp_rulv_rec.object1_id1 := p_rgpv_rec.rul_lagrnp_object1_id1;
         lp_lagrnp_rulv_rec.object1_id2 := '#';
         lp_lagrnp_rulv_rec.jtot_object1_code := 'OKL_PARTYSITE';
      END IF;

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lagrnp_rulv_rec,
        x_rulv_rec       => lx_lagrnp_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lagrnp_id := lx_lagrnp_rulv_rec.id;


    END IF;

    IF (p_rgpv_rec.rul_lagrnt_id IS NULL) THEN
      -- Create LAGRNT rule
      lp_lagrnt_rulv_rec.id := NULL;
      lp_lagrnt_rulv_rec.rgp_id := lx_lagrdt_rgpv_rec.id;
      lp_lagrnt_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lagrnt_rulv_rec.rule_information_category := 'LAGRNT';
      lp_lagrnt_rulv_rec.rule_information1 := p_rgpv_rec.lagrnt_rule_information1;
      lp_lagrnt_rulv_rec.rule_information2 := p_rgpv_rec.lagrnt_rule_information2;
      lp_lagrnt_rulv_rec.rule_information3 := p_rgpv_rec.lagrnt_rule_information3;
      lp_lagrnt_rulv_rec.rule_information4 := p_rgpv_rec.lagrnt_rule_information4;
      lp_lagrnt_rulv_rec.WARN_YN := 'N';
      lp_lagrnt_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lagrnt_rulv_rec,
        x_rulv_rec       => lx_lagrnt_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lagrnt_id := lx_lagrnt_rulv_rec.id;

    ELSE

      -- Update LAGRNT rule
      lp_lagrnt_rulv_rec.id := p_rgpv_rec.rul_lagrnt_id;
      lp_lagrnt_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_lagrnt_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lagrnt_rulv_rec.rule_information_category := 'LAGRNT';
      lp_lagrnt_rulv_rec.rule_information1 := p_rgpv_rec.lagrnt_rule_information1;
      lp_lagrnt_rulv_rec.rule_information2 := p_rgpv_rec.lagrnt_rule_information2;
      lp_lagrnt_rulv_rec.rule_information3 := p_rgpv_rec.lagrnt_rule_information3;
      lp_lagrnt_rulv_rec.rule_information4 := p_rgpv_rec.lagrnt_rule_information4;
      lp_lagrnt_rulv_rec.WARN_YN := 'N';
      lp_lagrnt_rulv_rec.STD_TEMPLATE_YN := 'N';

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lagrnt_rulv_rec,
        x_rulv_rec       => lx_lagrnt_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lagrnt_id := lx_lagrnt_rulv_rec.id;
    END IF;

       lp_cplv_rec.id := p_rgpv_rec.party_role_id;
       lp_cplv_rec.object1_id1 := p_rgpv_rec.party_id;
       lp_cplv_rec.object1_id2 := '#';
       lp_cplv_rec.jtot_object1_code := 'OKX_PARTY';
       lp_cplv_rec.rle_code := 'GUARANTOR';
       lp_cplv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
       lp_cplv_rec.chr_id := p_rgpv_rec.chr_id;
       lp_kplv_rec.attribute_category := p_rgpv_rec.attribute_category;
       lp_kplv_rec.attribute1  := p_rgpv_rec.attribute1;
       lp_kplv_rec.attribute2  := p_rgpv_rec.attribute2;
       lp_kplv_rec.attribute3  := p_rgpv_rec.attribute3;
       lp_kplv_rec.attribute4  := p_rgpv_rec.attribute4;
       lp_kplv_rec.attribute5  := p_rgpv_rec.attribute5;
       lp_kplv_rec.attribute6  := p_rgpv_rec.attribute6;
       lp_kplv_rec.attribute7  := p_rgpv_rec.attribute7;
       lp_kplv_rec.attribute8  := p_rgpv_rec.attribute8;
       lp_kplv_rec.attribute9  := p_rgpv_rec.attribute9;
       lp_kplv_rec.attribute10 := p_rgpv_rec.attribute10;
       lp_kplv_rec.attribute11 := p_rgpv_rec.attribute11;
       lp_kplv_rec.attribute12 := p_rgpv_rec.attribute12;
       lp_kplv_rec.attribute13 := p_rgpv_rec.attribute13;
       lp_kplv_rec.attribute14 := p_rgpv_rec.attribute14;
       lp_kplv_rec.attribute15 := p_rgpv_rec.attribute15;
       lp_kplv_rec.validate_dff_yn := 'Y';

    IF (p_rgpv_rec.rgp_id IS NULL) THEN
       OKL_K_PARTY_ROLES_PVT.create_k_party_role(
         p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         p_cplv_rec         => lp_cplv_rec,
         x_cplv_rec         => lx_cplv_rec,
         p_kplv_rec         => lp_kplv_rec,
         x_kplv_rec         => lx_kplv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
    ELSE

       OKL_K_PARTY_ROLES_PVT.update_k_party_role(
         p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         p_cplv_rec         => lp_cplv_rec,
         x_cplv_rec         => lx_cplv_rec,
         p_kplv_rec         => lp_kplv_rec,
         x_kplv_rec         => lx_kplv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    END IF;

    IF (p_rgpv_rec.rgp_id IS NULL) THEN
        OPEN c_get_rrd_id(p_rgpv_rec.chr_id, 'GUARANTOR', 'LAGRDT');
        FETCH c_get_rrd_id INTO l_rrd_id;
        CLOSE c_get_rrd_id;

        lp_rmpv_rec.rgp_id     := x_rgpv_rec.rgp_id;
        lp_rmpv_rec.cpl_id := lx_cplv_rec.id;
        lp_rmpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
        lp_rmpv_rec.rrd_id     := l_rrd_id;

        OKL_RULE_PUB.create_rg_mode_pty_role(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rmpv_rec       => lp_rmpv_rec,
          x_rmpv_rec       => lx_rmpv_rec);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
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
END process_guarantor;


End OKL_DEAL_PARTIES_PVT;

/

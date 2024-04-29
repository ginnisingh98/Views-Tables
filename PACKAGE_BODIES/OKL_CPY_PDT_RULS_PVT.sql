--------------------------------------------------------
--  DDL for Package Body OKL_CPY_PDT_RULS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CPY_PDT_RULS_PVT" AS
/* $Header: OKLRPCOB.pls 120.3 2006/09/25 13:24:19 dkagrawa noship $ */
--------------------------------------------------------------------------------
--Function to get rule template record
--------------------------------------------------------------------------------
FUNCTION get_rulv_rec (
    p_rul_id  IN NUMBER,
    x_no_data_found OUT NOCOPY BOOLEAN
  ) RETURN OKC_RULE_PUB.rulv_rec_type IS
    CURSOR okc_rulv_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            OBJECT1_ID1,
            OBJECT2_ID1,
            OBJECT3_ID1,
            OBJECT1_ID2,
            OBJECT2_ID2,
            OBJECT3_ID2,
            JTOT_OBJECT1_CODE,
            JTOT_OBJECT2_CODE,
            JTOT_OBJECT3_CODE,
            DNZ_CHR_ID,
            RGP_ID,
            PRIORITY,
            STD_TEMPLATE_YN,
            COMMENTS,
            WARN_YN,
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
            LAST_UPDATE_LOGIN,
            TEXT,
            RULE_INFORMATION_CATEGORY,
            RULE_INFORMATION1,
            RULE_INFORMATION2,
            RULE_INFORMATION3,
            RULE_INFORMATION4,
            RULE_INFORMATION5,
            RULE_INFORMATION6,
            RULE_INFORMATION7,
            RULE_INFORMATION8,
            RULE_INFORMATION9,
            RULE_INFORMATION10,
            RULE_INFORMATION11,
            RULE_INFORMATION12,
            RULE_INFORMATION13,
            RULE_INFORMATION14,
            RULE_INFORMATION15,
            TEMPLATE_YN,
            ans_set_jtot_object_code,
            ans_set_jtot_object_id1,
            ans_set_jtot_object_id2,
            DISPLAY_SEQUENCE
      FROM Okc_Rules_V
     WHERE okc_rules_v.id       = p_id;

    l_rulv_rec                     OKC_RULE_PUB.rulv_rec_type;
   --
   l_proc varchar2(72) := g_pkg_name||'get_rec';
   --
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rulv_csr (p_rul_id);
    FETCH okc_rulv_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              l_rulv_rec.TEXT,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ans_set_jtot_object_code,
              l_rulv_rec.ans_set_jtot_object_id1,
              l_rulv_rec.ans_set_jtot_object_id2,
              l_rulv_rec.DISPLAY_SEQUENCE ;
    x_no_data_found := okc_rulv_csr%NOTFOUND;
    CLOSE okc_rulv_csr;
    RETURN(l_rulv_rec);
END get_rulv_rec;
--------------------------------------------------------------------------------
--local procedure to create selected option values
--------------------------------------------------------------------------------
Procedure create_slctd_popv(p_api_version        IN  NUMBER,
                            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status      OUT NOCOPY VARCHAR2,
	                        x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2,
                            p_khr_id             IN  NUMBER,
                            p_pov_id             IN  NUMBER
                           ) IS
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_SLCTD_POPV';
    l_api_version	    CONSTANT NUMBER	:= 1.0;

    l_cspv_rec          OKL_CONTRACT_PROD_OPTNS_PUB.cspv_rec_type;
    l_cspv_rec_out      OKL_CONTRACT_PROD_OPTNS_PUB.cspv_rec_type;
Begin
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --call selected options create api
     l_cspv_rec.khr_id := p_khr_id;
     l_cspv_rec.pov_id := p_pov_id;

     OKL_CONTRACT_PROD_OPTNS_PUB.create_contract_option(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_cspv_rec       => l_cspv_rec,
             x_cspv_rec       => l_cspv_rec_out);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Bug# 3477560
     --cascade edit status on to lines
     okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_khr_id);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
       raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END create_slctd_popv;
--------------------------------------------------------------------------------
--local api to copy the rule to contract header
--------------------------------------------------------------------------------
procedure chk_and_cpy_rul_hdr(p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
	                          x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_khr_id             IN  NUMBER,
                              p_rulv_rec           IN  OKC_RULE_PUB.rulv_rec_type,
                              p_rgd_code           IN  OKL_OPT_RULES.rgr_rgd_code%TYPE,
                              p_rdf_code           IN  OKL_OPT_RULES.rgr_rdf_code%TYPE,
                              p_copy_or_enter_flag IN  OKL_OPV_RULES.copy_or_enter_flag%TYPE) IS

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'CHK_AND_CPY_RUL_HDR';
  l_api_version	      CONSTANT NUMBER	:= 1.0;

  --cursor to ceck if rule group is already attched at the k hdr level
  CURSOR chk_rgp_csr  (p_khr_id   IN NUMBER,
                       p_rgd_code IN VARCHAR2) IS
  select rgp.id
  from   okc_rule_groups_b rgp
  where  rgp.rgd_code = p_rgd_code
  and    rgp.chr_id   = p_khr_id;

  l_rgp_id   OKC_RULE_GROUPS_B.ID%TYPE default Null;

  --cursor to check if rule exists at the k_hdr level
   CURSOR chk_rul_csr  (p_khr_id   IN NUMBER,
                        p_rgp_id   IN NUMBER,
                        p_rdf_code IN VARCHAR2) IS
   select rul.id
   from   okc_rules_b rul
   where  rul.rgp_id      = p_rgp_id
   and    rul.dnz_chr_id  = p_khr_id
   and    rul.rule_information_category = p_rdf_code;

   l_rul_id       OKC_RULES_B.ID%TYPE default Null;

   l_rgpv_rec     OKC_RULE_PUB.rgpv_rec_type;
   l_rgpv_rec_out OKC_RULE_PUB.rgpv_rec_type;
   l_rulv_rec     OKC_RULE_PUB.rulv_rec_type;
   l_rulv_rec_out OKC_RULE_PUB.rulv_rec_type;

Begin
    --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --check if rule group is already there on contract header
     l_rgp_id := Null;
     Open chk_rgp_csr (p_khr_id    => p_khr_id,
                       p_rgd_code  => p_rgd_code);
     Fetch chk_rgp_csr into l_rgp_id;
     If chk_rgp_csr%NOTFOUND THEN
         --create rgp
         --initialize rgpv_rec
         l_rgpv_rec.rgd_code := p_rgd_code;
         l_rgpv_rec.chr_id   := p_khr_id;
         l_rgpv_rec.dnz_chr_id := p_khr_id;
         l_rgpv_rec.rgp_type := 'KRG';
         okc_rule_pub.create_rule_group(
                      p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_count,
                      p_rgpv_rec       => l_rgpv_rec,
                      x_rgpv_rec       => l_rgpv_rec_out);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --create rule
         l_rulv_rec                 := p_rulv_rec;

         l_rulv_rec.id              := OKL_API.G_MISS_NUM; -- so that new id could be generated
         l_rulv_rec.rgp_id          := l_rgpv_rec_out.id;
         l_rulv_rec.template_yn     := Null; --this rule will no longer be template
         l_rulv_rec.dnz_chr_id      := p_khr_id;
         l_rulv_rec.std_template_yn := 'N';
         okc_rule_pub.create_rule(
                      p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_rulv_rec       => l_rulv_rec,
                      x_rulv_rec       => l_rulv_rec_out);

         --dbms_output.put_line('rule created'||to_char(l_rulv_rec_out.id));

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

     Else
         --do not copy the rule group
         --check if rule exists
         l_rul_id := Null;
         Open chk_rul_csr ( p_khr_id    => p_khr_id,
                            p_rgp_id    => l_rgp_id,
                            p_rdf_code  => p_rdf_code);
         Fetch chk_rul_csr into l_rul_id;
         If chk_rul_csr%NOTFOUND Then
            --create rule record
            --create rule
            l_rulv_rec                 := p_rulv_rec;

            l_rulv_rec.id              := OKL_API.G_MISS_NUM; -- so that new id could be generated
            l_rulv_rec.rgp_id          := l_rgp_id;
            l_rulv_rec.template_yn     := Null; --this rule will no longer be template
            l_rulv_rec.dnz_chr_id      := p_khr_id;
            l_rulv_rec.std_template_yn := 'N';

            okc_rule_pub.create_rule(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_rec       => l_rulv_rec,
                         x_rulv_rec       => l_rulv_rec_out);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		    RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

         Else
            --rule record exists
            -- do not create rule record
            null;
         End If;
         Close chk_rul_csr;
     End If;
     close chk_rgp_csr;

    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End chk_and_cpy_rul_hdr;
--------------------------------------------------------------------------------
--local api to copy the rule to contract line
--------------------------------------------------------------------------------
procedure chk_and_cpy_rul_line(p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
	                          x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_khr_id             IN  NUMBER,
                              p_rulv_rec           IN  OKC_RULE_PUB.rulv_rec_type,
                              p_rgd_code           IN  OKL_OPT_RULES.rgr_rgd_code%TYPE,
                              p_rdf_code           IN  OKL_OPT_RULES.rgr_rdf_code%TYPE,
                              p_lse_id             IN  OKL_OPT_RULES.lrg_lse_id%TYPE,
                              p_copy_or_enter_flag IN  OKL_OPV_RULES.copy_or_enter_flag%TYPE) IS

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'CHK_AND_CPY_RUL_LINE';
  l_api_version	      CONSTANT NUMBER	:= 1.0;

  --cursor to check if there is a lse_id line for k
  CURSOR chk_lse_csr (p_khr_id IN NUMBER,
                      p_lse_id IN NUMBER) IS
  select cle.id
  from   okc_k_lines_b  cle,
         okc_statuses_b sts
  where  cle.dnz_chr_id = p_khr_id
  and    cle.lse_id     = p_lse_id
  and    cle.sts_code   = sts.code
  and    sts.code not in ('ACTIVE','HOLD','EXPIRED','TERMINATED','CANCELED')
  and    nvl(cle.end_date,sysdate+1) > sysdate;

  l_kle_id    OKC_K_LINES_B.ID%TYPE;

  --cursor to ceck if rule group is already attached at the k line level
  CURSOR chk_rgp_csr  (p_khr_id   IN NUMBER,
                       p_kle_id   IN NUMBER,
                       p_rgd_code IN VARCHAR2) IS
  select rgp.id
  from   okc_rule_groups_b rgp
  where  rgp.rgd_code    = p_rgd_code
  and    rgp.dnz_chr_id   = p_khr_id
  and    rgp.cle_id      = p_kle_id;

  l_rgp_id   OKC_RULE_GROUPS_B.ID%TYPE default Null;

  --cursor to check if rule exists at the k_line level
   CURSOR chk_rul_csr  (p_khr_id   IN NUMBER,
                        p_rgp_id   IN NUMBER,
                        p_rdf_code IN VARCHAR2) IS
   select rul.id
   from   okc_rules_b rul
   where  rul.rgp_id      = p_rgp_id
   and    rul.dnz_chr_id  = p_khr_id
   and    rul.rule_information_category = p_rdf_code;

   l_rul_id       OKC_RULES_B.ID%TYPE default Null;

   l_rgpv_rec     OKC_RULE_PUB.rgpv_rec_type;
   l_rgpv_rec_out OKC_RULE_PUB.rgpv_rec_type;

   l_rulv_rec     OKC_RULE_PUB.rulv_rec_type;
   l_rulv_rec_out OKC_RULE_PUB.rulv_rec_type;

Begin
    --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --check if eligble to modify line of lse lse_id exists on k hdt
     l_kle_id := Null;
     Open chk_lse_csr (p_khr_id  => p_khr_id,
                       p_lse_id  => p_lse_id);
     Fetch chk_lse_csr into l_kle_id;
     If chk_lse_csr%NOTFOUND Then
         --line of lse type does not exist on contract do nothing
         Null;
     Else
         --check if rule group is already there on contract header
         l_rgp_id := Null;
         Open chk_rgp_csr (p_khr_id    => p_khr_id,
                           p_kle_id    => l_kle_id,
                           p_rgd_code  => p_rgd_code);
         Fetch chk_rgp_csr into l_rgp_id;
         If chk_rgp_csr%NOTFOUND THEN
             --create rgp
             --initialize rgpv_rec
             l_rgpv_rec.rgd_code := p_rgd_code;
             l_rgpv_rec.cle_id   := l_kle_id;
             l_rgpv_rec.dnz_chr_id := p_khr_id;
             l_rgpv_rec.rgp_type := 'KRG';

             okc_rule_pub.create_rule_group(
                          p_api_version    => p_api_version,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_count,
                          p_rgpv_rec       => l_rgpv_rec,
                          x_rgpv_rec       => l_rgpv_rec_out);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		     RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

            --create rule
            l_rulv_rec                 := p_rulv_rec;

            l_rulv_rec.id              := OKL_API.G_MISS_NUM; -- so that new id could be generated
            l_rulv_rec.rgp_id          := l_rgpv_rec_out.id;
            l_rulv_rec.template_yn     := Null; --this rule will no longer be template
            l_rulv_rec.dnz_chr_id      := p_khr_id;
            l_rulv_rec.std_template_yn := 'N';

            okc_rule_pub.create_rule(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_rec       => l_rulv_rec,
                         x_rulv_rec       => l_rulv_rec_out);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		    RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

         Else
             --do not copy the rule group
             --check if rule exists
             l_rul_id := Null;
             Open chk_rul_csr ( p_khr_id    => p_khr_id,
                                p_rgp_id    => l_rgp_id,
                                p_rdf_code  => p_rdf_code);
             Fetch chk_rul_csr into l_rul_id;
             If chk_rul_csr%NOTFOUND Then
                --create rule record
                --create rule
                l_rulv_rec                 := p_rulv_rec;

                l_rulv_rec.id              := OKL_API.G_MISS_NUM; -- so that new id could be generated
                l_rulv_rec.rgp_id          := l_rgp_id;
                l_rulv_rec.template_yn     := Null; --this rule will no longer be template
                l_rulv_rec.dnz_chr_id      := p_khr_id;
                l_rulv_rec.std_template_yn := 'N';

                okc_rule_pub.create_rule(
                             p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_rulv_rec       => l_rulv_rec,
                             x_rulv_rec       => l_rulv_rec_out);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

             Else
                --rule record exists
                -- do not create rule record
                null;
             End If;
             Close chk_rul_csr;
         End If;
         close chk_rgp_csr;
     End If;
     Close chk_lse_csr;
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End chk_and_cpy_rul_line;
--------------------------------------------------------------------------------
Procedure Copy_Product_Rules(p_api_version     IN  NUMBER,
	                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                         x_return_status   OUT NOCOPY VARCHAR2,
	                         x_msg_count       OUT NOCOPY NUMBER,
                             x_msg_data        OUT NOCOPY VARCHAR2,
                             p_khr_id          IN  NUMBER,
                             p_pov_id          IN  NUMBER) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'COPY_PRODUCT_RULES';
  l_api_version	      CONSTANT NUMBER	:= 1.0;

--cursor to fetch values required from contract header
CURSOR l_khr_csr(p_khr_id IN NUMBER) is
SELECT chr.scs_code,
       chr.authoring_org_id,
       chr.buy_or_sell,
       chr.inv_organization_id,
       chr.start_date,
       chr.end_date,
       chr.sts_code,
       khr.pdt_id
FROM   OKL_K_HEADERS khr,
       OKC_K_HEADERS_B chr
WHERE  khr.id = chr.id
AND    chr.id = p_khr_id;

l_khr_rec l_khr_csr%ROWTYPE;

--cursor to get selected product options
CURSOR l_slctd_opt_csr (p_khr_id IN NUMBER, p_pov_id IN NUMBER) is
SELECT ID,
       POV_ID, --required
       KHR_ID  -- fk to okc_k_headers_b.id
FROM   OKL_SLCTD_OPTNS
WHERE  KHR_ID = p_khr_id
and    POV_ID = p_pov_id;

l_slctd_opt_rec l_slctd_opt_csr%ROWTYPE;

--cursor to get product option values
CURSOR l_pdt_opt_vals_csr (p_pov_id IN NUMBER) is
SELECT pov.OVE_ID, --required fk to okl_opt_values (okl_opv_rules_v.ove_id)
       pov.ID,
       pov.PON_ID,
       pon.opt_id  --product option id fk okl_pdt_opts
FROM   OKL_PDT_OPT_VALS pov,
       OKL_PDT_OPTS     pon
WHERE  pov.ID = p_pov_id    --(p_pov id will be pov id fetched in last csr)
AND    nvl(pov.FROM_DATE,sysdate) <= sysdate
AND    nvl(pov.TO_DATE,sysdate+1) > sysdate
AND    pon.id = pov.pon_id
AND    nvl(pon.FROM_DATE,sysdate) <= sysdate
AND    nvl(pon.TO_DATE,sysdate+1) > sysdate;


l_pdt_opt_vals_rec l_pdt_opt_vals_csr%ROWTYPE;


--cursor to fetch option value rules
CURSOR l_opv_ruls_csr (p_ove_id IN NUMBER) is
SELECT ovd.OVE_ID, -- fk to okl_opt_values (okl_opv_rules_v.ove_id)
       ovd.ID,
       ovd.ORL_ID,  --required fk to okl_opt_ruls
       ovd.CONTEXT_INTENT, --should be same as khr intent
       ovd.COPY_OR_ENTER_FLAG, --if it 'CPY' copy to k and do not allow modfn, else sllow mdfn
       ovd.CONTEXT_INV_ORG, --should be same as khr inv org
       ovd.CONTEXT_ORG, --should be same as contract org_id
       ovd.CONTEXT_ASSET_BOOK, --what chk on this??
       ovd.INDIVIDUAL_INSTRUCTIONS
FROM   OKL_OPV_RULES ovd,
       OKL_OPT_VALUES ove
WHERE  ovd.ove_id = ove.id
AND    nvl(ove.FROM_DATE,sysdate) <= sysdate
AND    nvl(ove.TO_DATE,sysdate+1) > sysdate
AND    ove.ID = p_ove_id;    --(p_ove id will be ove id fetched in last csr)

l_opv_ruls_rec  l_opv_ruls_csr%ROWTYPE;

--cursor to get rule id from option value rule templates (okl_ovd_rul_tmls)
CURSOR  l_ovd_rul_tmls_csr (p_ovd_id IN NUMBER) is
SELECT  RUL_ID,    --required fk to okc_rules_v.id
        OVD_ID    --fk to okl_opv_rules.id
FROM    OKL_OVD_RUL_TMLS
WHERE   OVD_ID = p_ovd_id; --(p_ovd_id will be id fetched in the last cursor)

l_ovd_rul_tmls_rec l_ovd_rul_tmls_csr%ROWTYPE;

--cursor to see if the option value rule is meant for 'LEASE' subclass
-- line styles and rgd-rdf codes

--1.--effectivity check for header level rules
CURSOR  l_opt_ruls_khr_csr(p_opt_id    IN  NUMBER,
                           p_rdf_code  IN  VARCHAR2,
                           p_scs_code  IN  VARCHAR2) is
SELECT  orl.SRD_ID_FOR,
        orl.LRG_SRD_ID,
        orl.LRG_LSE_ID,
        orl.RGR_RGD_CODE,
        orl.RGR_RDF_CODE
FROM    OKL_OPT_RULES orl,
        OKC_SUBCLASS_RG_DEFS srd
WHERE   srd.id       = orl.SRD_ID_FOR
AND     srd.rgd_code = orl.rgr_rgd_code
AND     srd.scs_code = p_scs_code
AND     nvl(srd.start_date,sysdate) <= sysdate
AND     nvl(srd.end_date,sysdate+1) > sysdate
AND     orl.rgr_rdf_code = p_rdf_code
AND     orl.lrg_srd_id is null
AND     orl.lrg_lse_id is null
AND     orl.opt_id = p_opt_id; --(p_orl_id is ovd.ORL_ID fetched in l_opv_ruls_csr)


l_opt_ruls_khr_rec l_opt_ruls_khr_csr%ROWTYPE;

--2.--effecitivity check for lse level rules
CURSOR  l_opt_ruls_kle_csr(p_opt_id    IN  NUMBER,
                           p_rdf_code  IN  VARCHAR2,
                           p_scs_code  IN  VARCHAR2) is
SELECT  orl.SRD_ID_FOR,
        orl.LRG_SRD_ID,
        orl.LRG_LSE_ID,
        orl.RGR_RGD_CODE,
        orl.RGR_RDF_CODE
FROM    OKL_OPT_RULES orl,
        OKC_SUBCLASS_RG_DEFS srd,
        OKC_LSE_RULE_GROUPS  lrg
WHERE   srd.id       = lrg.SRD_ID
AND     srd.rgd_code = orl.rgr_rgd_code
AND     srd.scs_code = p_scs_code
AND     nvl(srd.start_date,sysdate) <= sysdate
AND     nvl(srd.end_date,sysdate+1) > sysdate
AND     lrg.lse_id = orl.lrg_lse_id
AND     lrg.srd_id = orl.lrg_srd_id
AND     orl.rgr_rdf_code = p_rdf_code
AND     orl.srd_id_for is null
AND     orl.opt_id = p_opt_id; --(p_orl_id is ovd.ORL_ID fetched in l_opv_ruls_csr)


l_opt_ruls_kle_rec l_opt_ruls_kle_csr%ROWTYPE;

l_rulv_rec         OKC_RULE_PUB.rulv_rec_type;
l_no_data_found    Boolean Default TRUE;

BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     Open l_khr_csr(p_khr_id => p_khr_id);
     Fetch l_khr_csr into l_khr_rec;
     If l_khr_csr%NOTFOUND Then
         --contract not found
         Null;
     Else
         --check fo sts code
         --if not booked and in any of te terminated stages get selected options

         Open l_slctd_opt_csr(p_khr_id => p_khr_id, p_pov_id => p_pov_id);
         Fetch l_slctd_opt_csr into l_slctd_opt_rec;
         If l_slctd_opt_csr%NOTFOUND Then
             --create the selected option value
             create_slctd_popv(p_api_version      => p_api_version,
                        p_init_msg_list    => p_init_msg_list,
                        x_return_status    => x_return_status,
	                    x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        p_khr_id           => p_khr_id,
                        p_pov_id           => p_pov_id
                        );
             --dbms_output.put_line('After creating the selected product option :'||x_return_status);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		     RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          End If;
          Close l_slctd_opt_csr;

             --get product option values
             OPEN l_pdt_opt_vals_csr (p_pov_id => p_pov_id);
             Loop
                 Fetch l_pdt_opt_vals_csr into l_pdt_opt_vals_rec;
                 Exit when l_pdt_opt_vals_csr%NOTFOUND;
                 --get option value rules
                 OPEN l_opv_ruls_csr (p_ove_id => l_pdt_opt_vals_rec.ove_id);
                 Loop
                    Fetch l_opv_ruls_csr into l_opv_ruls_rec;
                    Exit when l_opv_ruls_csr%NOTFOUND;
                    If nvl(l_opv_ruls_rec.context_intent,'XX') <> nvl(l_khr_rec.buy_or_sell,'ZZ') OR
                       nvl(l_opv_ruls_rec.context_org,-9999) <> nvl(l_khr_rec.authoring_org_id,-6666) OR
                       nvl(l_opv_ruls_rec.context_inv_org,-9999) <> nvl(l_khr_rec.inv_organization_id,-6666) Then
                          --dbms_output.put_line('Intent :'||l_opv_ruls_rec.context_intent);
                          --dbms_output.put_line('Org :'||to_char(l_opv_ruls_rec.context_org));
                          --dbms_output.put_line('Org :'||to_char(l_opv_ruls_rec.context_inv_org));
                          --dbms_output.put_line('Not copying because unable to match context');
                          --Exit;
                          NULL;
                    Else
                          --open the rule templates csr
                           --dbms_output.put_line('copying matched context');
                           --dbms_output.put_line('Intent :'||l_opv_ruls_rec.context_intent);
                           --dbms_output.put_line('Org :'||to_char(l_opv_ruls_rec.context_org));
                           --dbms_output.put_line('Org :'||to_char(l_opv_ruls_rec.context_inv_org));
                           OPEN l_ovd_rul_tmls_csr(p_ovd_id => l_opv_ruls_rec.ID);
                           Loop
                                Fetch l_ovd_rul_tmls_csr into l_ovd_rul_tmls_rec;
                                Exit when l_ovd_rul_tmls_csr%NOTFOUND;
                                l_rulv_rec := get_rulv_rec(p_rul_id        => l_ovd_rul_tmls_rec.rul_id,
                                                           x_no_data_found => l_no_data_found);

                                IF l_no_data_found Then
                                    --no rule template found to copy
                                    null;
                                    --dbms_output.put_line('No Template Found');
                                    --should we raise an error here
                                ELSE
                                --check for effecitvity at header level
                                 --dbms_output.put_line('product option value '||to_char(l_pdt_opt_vals_rec.opt_id));
                                 --dbms_output.put_line('product rule code '||l_rulv_rec.rule_information_category);
                                 --dbms_output.put_line('product scs code '||l_khr_rec.scs_code);
                                 Open l_opt_ruls_khr_csr(p_opt_id   => l_pdt_opt_vals_rec.opt_id,
                                                         p_rdf_code => l_rulv_rec.rule_information_category,
                                                         p_scs_code => l_khr_rec.scs_code);
                                 Loop
                                      Fetch l_opt_ruls_khr_csr into l_opt_ruls_khr_rec;
                                      --check for applicability of the rule
                                      Exit when l_opt_ruls_khr_csr%NOTFOUND;
                                      --Else
                                          --copy the rule group and rule at header level
                                          --do not copy if the rule group exists
                                          --do not copy if the rule group exists for the rule group
                                          --dbms_output.put_line('rgd code '||l_opt_ruls_khr_rec.rgr_rgd_code);
                                          --dbms_output.put_line('rdf code '||l_opt_ruls_khr_rec.rgr_rdf_code);
                                          chk_and_cpy_rul_hdr(p_api_version        => p_api_version,
                                                              p_init_msg_list      => p_init_msg_list,
                                                              x_return_status      => x_return_status,
	                                                          x_msg_count          => x_msg_count,
                                                              x_msg_data           => x_msg_data,
                                                              p_khr_id             => p_khr_id,
                                                              p_rulv_rec           => l_rulv_rec,
                                                              p_rgd_code           => l_opt_ruls_khr_rec.rgr_rgd_code,
                                                              p_rdf_code           => l_opt_ruls_khr_rec.rgr_rdf_code,
                                                              p_copy_or_enter_flag => l_opv_ruls_rec.Copy_or_enter_flag);
                                          --dbms_output.put_line('after trying to copy rules'||x_return_status);
                                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	                                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                              RAISE OKL_API.G_EXCEPTION_ERROR;
                                          END IF;
                                        --End If;
                                      End Loop;
                                  --dbms_output.put_line('Exiting out of l_opt_ruls_khr_csr');
                                  Close l_opt_ruls_khr_csr;

                                  --check for applicability at line level

                                 Open l_opt_ruls_kle_csr(p_opt_id   => l_pdt_opt_vals_rec.opt_id,
                                                         p_rdf_code => l_rulv_rec.rule_information_category,
                                                         p_scs_code => l_khr_rec.scs_code);
                                 Loop
                                     Fetch l_opt_ruls_kle_csr into l_opt_ruls_kle_rec;
                                     --check for applicability of the rule
                                      Exit when l_opt_ruls_kle_csr%NOTFOUND;
                                      --Else
                                          --copy the rule group and rule at line level
                                          --do not copy if the rule group exists
                                          --do not copy if the rule group exists for the rule group
                                          chk_and_cpy_rul_line(p_api_version    => p_api_version,
                                                               p_init_msg_list  => p_init_msg_list,
                                                               x_return_status  => x_return_status,
	                                                           x_msg_count      => x_msg_count,
                                                               x_msg_data       => x_msg_data,
                                                               p_khr_id         => p_khr_id,
                                                               p_rulv_rec       => l_rulv_rec,
                                                               p_rgd_code       => l_opt_ruls_kle_rec.rgr_rgd_code,
                                                               p_rdf_code       => l_opt_ruls_kle_rec.rgr_rdf_code,
                                                               p_lse_id         => l_opt_ruls_kle_rec.lrg_lse_id,
                                                               p_copy_or_enter_flag => l_opv_ruls_rec.Copy_or_enter_flag);

                                          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		                                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                               RAISE OKL_API.G_EXCEPTION_ERROR;
                                          END IF;
                                        --End If;
                                  End Loop;
                                  --dbms_output.put_line('Exiting out of l_opt_ruls_kle_csr');
                                  Close l_opt_ruls_kle_csr;
                                  END IF; -- rule template record not found in okc_rule_v
                            End Loop;
                            --dbms_output.put_line('Exiting out of l_ovd_rul_tmls_csr');
                            CLOSE l_ovd_rul_tmls_csr;
                      End If;
                 End Loop;
                 --dbms_output.put_line('Exiting out of l_opv_ruls_csr');
                 CLOSE l_opv_ruls_csr;
                 End Loop;
                 --dbms_output.put_line('Exiting out of l_pdt_opt_vals_csr');
                 CLOSE l_pdt_opt_vals_csr;
             --End Loop;
             --dbms_output.put_line('Exiting out of l_slctd_opt_csr');
             --Close l_slctd_opt_csr;
          End If;
          --dbms_output.put_line('Exiting out of l_khr_csr');
          Close l_khr_csr;

           --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End Copy_Product_Rules;
END OKL_CPY_PDT_RULS_PVT;

/

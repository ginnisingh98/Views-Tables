--------------------------------------------------------
--  DDL for Package Body OKL_MLA_CREATE_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MLA_CREATE_UPDATE_PUB" AS
/* $Header: OKLPMCUB.pls 120.0 2006/11/22 12:14:06 zrehman noship $ */

  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
  G_IS_DEBUG_STATEMENT_ON BOOLEAN;
  G_API_TYPE	VARCHAR2(3) := 'PUB';

   G_RLE_CODE  VARCHAR2(10) := 'LESSEE';
   G_STS_CODE  VARCHAR2(10) := 'NEW';
   G_LEASE_VENDOR  VARCHAR2(10) := 'OKL_VENDOR';

   SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
   SUBTYPE khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;

   G_WF_EVT_KHR_CREATED CONSTANT VARCHAR2(41) := 'oracle.apps.okl.la.lease_contract.created';
   G_WF_EVT_KHR_UPDATED CONSTANT VARCHAR2(41) := 'oracle.apps.okl.la.lease_contract.updated';

   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(11) := 'CONTRACT_ID';




  FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
  RETURN VARCHAR2 IS

  	CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	    select a.attribute_label_long
	 from ak_region_items ri, ak_regions r, ak_attributes_vl a
	 where ri.region_code = r.region_code
	 and ri.region_application_id = r.region_application_id
	 and ri.attribute_code = a.attribute_code
	 and ri.attribute_application_id = a.attribute_application_id
	 and ri.region_code  =  p_ak_region
	 and ri.attribute_code = p_ak_attribute
	;

  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	RETURN(l_ak_prompt);
  END;

PROCEDURE create_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                 IN  party_rec_type,
      x_kpl_rec                 OUT NOCOPY party_rec_type
      ) AS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'create_party';
l_api_version          CONSTANT NUMBER := 1.0;

lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

Begin
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

    lp_cplv_rec.id := p_kpl_rec.id;
    lp_cplv_rec.object1_id1 := p_kpl_rec.object1_id1;
    lp_cplv_rec.object1_id2 := p_kpl_rec.object1_id2;
    lp_cplv_rec.jtot_object1_code := p_kpl_rec.jtot_object1_code;
    lp_cplv_rec.rle_code := p_kpl_rec.rle_code;
    lp_cplv_rec.dnz_chr_id := p_kpl_rec.dnz_chr_id;
    lp_cplv_rec.chr_id := p_kpl_rec.chr_id;
    lp_kplv_rec.attribute_category := p_kpl_rec.attribute_category;
    lp_kplv_rec.attribute1 := p_kpl_rec.attribute1;
    lp_kplv_rec.attribute2 := p_kpl_rec.attribute2;
    lp_kplv_rec.attribute3 := p_kpl_rec.attribute3;
    lp_kplv_rec.attribute4 := p_kpl_rec.attribute4;
    lp_kplv_rec.attribute5 := p_kpl_rec.attribute5;
    lp_kplv_rec.attribute6 := p_kpl_rec.attribute6;
    lp_kplv_rec.attribute7 := p_kpl_rec.attribute7;
    lp_kplv_rec.attribute8 := p_kpl_rec.attribute8;
    lp_kplv_rec.attribute9 := p_kpl_rec.attribute9;
    lp_kplv_rec.attribute10 := p_kpl_rec.attribute10;
    lp_kplv_rec.attribute11 := p_kpl_rec.attribute11;
    lp_kplv_rec.attribute12 := p_kpl_rec.attribute12;
    lp_kplv_rec.attribute13 := p_kpl_rec.attribute13;
    lp_kplv_rec.attribute14 := p_kpl_rec.attribute14;
    lp_kplv_rec.attribute15 := p_kpl_rec.attribute15;

    IF(p_kpl_rec.rle_code IS NOT NULL AND
    	NOT (p_kpl_rec.rle_code = 'LESSEE' OR p_kpl_rec.rle_code = 'LESSOR')) THEN
     lp_kplv_rec.validate_dff_yn := 'Y';
    END IF;

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

    x_kpl_rec.id := lx_cplv_rec.id;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
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

end;


PROCEDURE create_from_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY  NUMBER) AS

    l_end_date           OKL_K_HEADERS_FULL_V.END_DATE%TYPE DEFAULT NULL;
    l_start_date         OKL_K_HEADERS_FULL_V.START_DATE%TYPE DEFAULT NULL;
    l_term_duration      OKL_K_HEADERS_FULL_V.TERM_DURATION%TYPE DEFAULT NULL;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    CURSOR get_k_start_date_and_term_csr(l_chr_id NUMBER) IS
    	SELECT chr.start_date, khr.term_duration
	FROM okl_k_headers khr,
         okc_k_headers_b chr
    WHERE khr.id = chr.id
	AND chr.id = l_chr_id;
    l_scs_code                     VARCHAR2(30);

    Cursor l_scs_csr  is
    Select scs_code
    From   okc_k_headers_b
    where  id = p_source_chr_id;

  BEGIN

    OPEN l_scs_csr;
    FETCH l_scs_csr into l_scs_code;
    CLOSE l_scs_csr;

    IF (l_scs_code  IS NOT NULL) AND (l_scs_code  = 'MASTER_LEASE')  Then
       OKL_COPY_CONTRACT_PUB.copy_lease_contract(
          p_api_version              => p_api_version,
          p_init_msg_list            => p_init_msg_list,
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data,
          p_chr_id                   => p_source_chr_id,
          p_contract_number          => p_contract_number,
          p_contract_number_modifier => null,
          p_renew_ref_yn             => OKC_API.G_FALSE,
          p_trans_type               => 'CFA',
          x_chr_id                   => x_chr_id);
    ELSE
      OKL_COPY_CONTRACT_PUB.copy_lease_contract_new(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_chr_id                   => p_source_chr_id,
      p_contract_number          => p_contract_number,
      p_contract_number_modifier => NULL,
      p_renew_ref_yn             => OKC_API.G_FALSE,
      p_trans_type               => 'CFA',
      x_chr_id                   => x_chr_id);
    END IF;

	  FOR get_k_start_date_and_term_rec IN get_k_start_date_and_term_csr(x_chr_id)
	  LOOP
	    l_end_date := OKL_LLA_UTIL_PVT.calculate_end_date(get_k_start_date_and_term_rec.start_date,get_k_start_date_and_term_rec.term_duration);
	  END LOOP;
      lp_chrv_rec.id := x_chr_id;
      lp_khrv_rec.id := x_chr_id;
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_CONTRACT;
      lp_chrv_rec.end_date := l_end_date;


      IF l_end_date IS NOT NULL THEN
      	      OKL_CONTRACT_PUB.update_contract_header(
	         p_api_version    => p_api_version,
	         p_init_msg_list  => p_init_msg_list,
	         x_return_status  => x_return_status,
	         x_msg_count      => x_msg_count,
	         x_msg_data       => x_msg_data,
	         p_chrv_rec       => lp_chrv_rec,
	         p_khrv_rec       => lp_khrv_rec,
	         x_chrv_rec       => lx_chrv_rec,
	         x_khrv_rec       => lx_khrv_rec);
      END IF;

  END;


-- Start of comments
--
-- Procedure Name  : create_from_contract
-- Description     : creates a deal from a template
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_from_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER) AS


    l_scs_code                     VARCHAR2(30);

    Cursor l_scs_csr  is
    Select scs_code
    From   okc_k_headers_b
    where  id = p_source_chr_id;
  BEGIN

  --Call the old api in case of MASTER_LEASE agreement
    OPEN l_scs_csr;
    FETCH l_scs_csr into l_scs_code;
    CLOSE l_scs_csr;

    IF (l_scs_code  IS NOT NULL) AND (l_scs_code  = 'MASTER_LEASE')  Then
       OKL_COPY_CONTRACT_PUB.copy_lease_contract(
          p_api_version              => p_api_version,
          p_init_msg_list            => p_init_msg_list,
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data,
          p_chr_id                   => p_source_chr_id,
          p_contract_number          => p_contract_number,
          p_contract_number_modifier => null,
          p_renew_ref_yn             => OKC_API.G_FALSE,
          p_trans_type               => 'CFA',
          x_chr_id                   => x_chr_id);
    ELSE
      OKL_COPY_CONTRACT_PUB.copy_lease_contract_new(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_chr_id                   => p_source_chr_id,
      p_contract_number          => p_contract_number,
      p_contract_number_modifier => NULL,
      p_renew_ref_yn             => OKC_API.G_FALSE,
      p_trans_type               => 'CFA',
      x_chr_id                   => x_chr_id);
    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  END;


PROCEDURE create_new_deal(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN  OUT NOCOPY VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_template_yn                  IN  VARCHAR2,
    p_template_type                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_program_name                 IN  VARCHAR2,
    p_program_id                   IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER,
    p_legal_entity_id              IN  NUMBER) AS

    SUBTYPE l_cplv_tbl_type is OKL_OKC_MIGRATION_PVT.cplv_tbl_type;
    SUBTYPE l_kplv_tbl_type is okl_kpl_pvt.kplv_tbl_type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    l_cplv_tbl l_cplv_tbl_type;
    l_kplv_tbl l_kplv_tbl_type;
    lx_cplv_tbl l_cplv_tbl_type;
    lx_kplv_tbl l_kplv_tbl_type;

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'CREATE_NEW_DEAL';

    row_count         NUMBER DEFAULT 0;

    CURSOR check_party_csr(p_chr_id NUMBER) IS
	SELECT COUNT(1)
	    FROM okc_k_party_roles_B
	    WHERE dnz_chr_id = p_chr_id
	    AND chr_id = p_chr_id
	    AND rle_code = G_RLE_CODE
	    AND object1_id1 = p_customer_id1
	    AND object1_id2 = p_customer_id2
	;

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

    lp_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

    l_vp_cpl_id okc_k_party_roles_v.id%TYPE := NULL;
    x_cpl_id   okc_k_party_roles_v.id%TYPE := NULL;
    l_chr_id   okc_k_headers_b.id%type := NULL;

    CURSOR c_vp_cpl_csr(p_source_id NUMBER) IS
     SELECT id, object_version_number, sfwt_flag,
            cpl_id, chr_id, cle_id,
            rle_code, dnz_chr_id, object1_id1,
            object1_id2, jtot_object1_code, cognomen,
            code, facility, minority_group_lookup_code,
            small_business_flag, women_owned_flag, alias,
            attribute_category, attribute1, attribute2,
            attribute3, attribute4, attribute5,
            attribute6, attribute7, attribute8,
            attribute9, attribute10, attribute11,
            attribute12, attribute13, attribute14,
            attribute15, created_by, creation_date,
            last_updated_by, last_update_date, last_update_login,
            cust_acct_id, bill_to_site_use_id
     FROM okc_k_party_roles_v cplv
     WHERE cplv.rle_code = G_LEASE_VENDOR
     AND cplv.chr_id = p_source_id; -- vendor program id


  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.sfwt_flag := 'N';
    lp_chrv_rec.object_version_number := 1.0;
    lp_chrv_rec.sts_code := G_STS_CODE; -- 'ENTERED';
    lp_chrv_rec.scs_code := p_scs_code;
    lp_chrv_rec.contract_number := p_contract_number;
    lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
    lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;
    lp_chrv_rec.currency_code := OKL_ACCOUNTING_UTIL.get_func_curr_code;
    lp_chrv_rec.currency_code_renewed := NULL;
    lp_chrv_rec.template_yn := 'N';
    lp_chrv_rec.chr_type := 'CYA';
    lp_chrv_rec.archived_yn := 'N';
    lp_chrv_rec.deleted_yn := 'N';
    lp_chrv_rec.buy_or_sell := 'S';
    lp_chrv_rec.issue_or_receive := 'I';
    lp_chrv_rec.start_date := p_effective_from;
    lp_khrv_rec.object_version_number := 1.0;

    IF ( p_program_name IS NOT NULL ) THEN
      lp_khrv_rec.khr_id := p_program_id;
    END IF;

    IF ( p_template_type IS NOT NULL ) THEN
      lp_khrv_rec.template_type_code := p_template_type;
      lp_chrv_rec.template_yn := 'Y';
    END IF;
    lp_khrv_rec.legal_entity_id := p_legal_entity_id;
    OKL_CONTRACT_PUB.create_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_chr_id := lx_chrv_rec.id;

    IF ( p_program_name IS NOT NULL ) THEN

       -- copy vp party lease vendor to lease contract
       l_vp_cpl_id := NULL;

       OPEN c_vp_cpl_csr(p_program_id);
       FETCH c_vp_cpl_csr BULK COLLECT INTO l_cplv_tbl;
       CLOSE c_vp_cpl_csr;

       IF( l_cplv_tbl.COUNT > 0 ) THEN

        FOR i IN l_cplv_tbl.FIRST..l_cplv_tbl.LAST
        LOOP
          l_cplv_tbl(i).ID := null;
          IF (l_cplv_tbl(i).CHR_ID IS NOT NULL) THEN
            l_cplv_tbl(i).CHR_ID := x_chr_id;
          END IF;
          IF (l_cplv_tbl(i).DNZ_CHR_ID IS NOT NULL) THEN
            l_cplv_tbl(i).DNZ_CHR_ID := x_chr_id;
          END IF;
          l_kplv_tbl(i).attribute_category := null;
        END LOOP;

  	IF okl_context.get_okc_org_id  IS NULL THEN
   	  l_chr_id := x_chr_id;
	  okl_context.set_okc_org_context(p_chr_id => l_chr_id );
        END IF;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cplv_tbl.count=' || l_cplv_tbl.count);
         END IF;
         okl_k_party_roles_pvt.create_k_party_role(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_cplv_tbl         => l_cplv_tbl,
           x_cplv_tbl         => lx_cplv_tbl,
           p_kplv_tbl         => l_kplv_tbl,
           x_kplv_tbl         => lx_kplv_tbl);

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

       END IF;

    END IF;
    IF ( p_customer_name IS NOT NULL ) THEN

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := x_chr_id;
    lp_cplv_rec.chr_id := x_chr_id;
    lp_cplv_rec.cle_id := NULL;
    lp_cplv_rec.object1_id1 := p_customer_id1;
    lp_cplv_rec.object1_id2 := p_customer_id2;
    lp_cplv_rec.jtot_object1_code := p_customer_code;
    lp_cplv_rec.rle_code := G_RLE_CODE;

    OPEN check_party_csr(x_chr_id);
    FETCH check_party_csr INTO row_count;
    CLOSE check_party_csr;
    IF row_count = 1 THEN
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_already_exists');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

      END IF;

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

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
  END;

-- Start of comments
--
-- Procedure Name  : create_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_template_type                IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_program_name                 IN  VARCHAR2,
    p_program_id                   IN  NUMBER,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN OUT NOCOPY  NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    p_legal_entity_id              IN  NUMBER) AS

    l_api_name	        VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_program_id	NUMBER;

    -- cursor when only customer is selected
    CURSOR l_source_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       , okc_k_party_roles_b prl
       WHERE prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND NVL(chr.template_yn,'N') = p_temp_yn
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number;

     -- cursor when only customer and program is selected
    CURSOR l_source_chr_prog_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2, l_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR,
            okl_k_headers khr
          , okc_k_party_roles_b prl
       WHERE chr.id = khr.id
       AND prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND NVL(CHR.template_yn,'N') = p_temp_yn
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number
       AND exists( select 1 from okl_vp_associations vpaso
                   where vpaso.chr_id = l_prog_id);

    -- cursor when only program is selected
    CURSOR l_source_prog_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, l_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR,
            okl_k_headers khr
       WHERE chr.id = khr.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND NVL(CHR.template_yn,'N') = p_temp_yn
       AND CHR.contract_number = p_source_contract_number
       AND exists( select 1 from okl_vp_associations vpaso
                   where vpaso.chr_id = l_prog_id);

    CURSOR l_src_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       WHERE CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND CHR.template_yn = p_temp_yn
       AND CHR.contract_number = p_source_contract_number;


    CURSOR l_program_csr IS
       SELECT chr.id
       FROM okl_k_headers_full_v chr
       WHERE chr.scs_code = 'PROGRAM'
       AND nvl(chr.template_yn, 'N') = 'N'
       AND chr.sts_code = 'ACTIVE'
       AND chr.authoring_org_id = p_org_id
       AND NVL(chr.start_date,p_effective_from) <= p_effective_from
       AND NVL(chr.end_date,p_effective_from) >= p_effective_from
       AND chr.contract_number = p_program_name;


    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_object_code        VARCHAR2(30) DEFAULT NULL;
    l_chr_id             OKC_K_HEADERS_B.ID%TYPE;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    	PROCEDURE raise_business_event(
    	p_chr_id IN NUMBER
	   ,x_return_status OUT NOCOPY VARCHAR2
    )
	IS
	  l_check VARCHAR2(1);
      l_parameter_list           wf_parameter_list_t;
	BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	  IF (p_source_code = 'new') THEN
  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_CREATED,
								 p_parameters     => l_parameter_list);

	  END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_customer_name IS NULL) THEN
     IF p_scs_code = 'MASTER_LEASE' THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
    END IF;

    IF(p_program_name IS NOT NULL AND p_scs_code <> 'MASTER_LEASE' ) THEN
         l_program_id := null;
         open l_program_csr;
         fetch l_program_csr into l_program_id;
         close l_program_csr;

         IF( l_program_id IS NULL ) THEN

	   x_return_status := OKC_API.g_ret_sts_error;
           l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_PROGRAM');
           OKC_API.SET_MESSAGE(   p_app_name => g_app_name
				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	   RAISE OKC_API.G_EXCEPTION_ERROR;

	 END IF;
    END IF;

    IF(p_source_code <> 'new' AND p_source_contract_number IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   IF(p_customer_name IS NOT NULL) THEN

    okl_la_validation_util_pvt.Get_Party_Jtot_data (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_scs_code       => p_scs_code,
      p_buy_or_sell    => 'S',
      p_rle_code       => G_RLE_CODE,
      p_id1            => p_customer_id1,
      p_id2            => p_customer_id2,
      p_name           => p_customer_name,
      p_object_code    => l_object_code,
      p_ak_region      => 'OKL_LA_DEAL_CREAT',
      p_ak_attribute   => 'OKL_CUSTOMER_NAME'
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

   IF(p_source_code <> 'new' AND p_source_contract_number IS NOT NULL) THEN

    IF(p_customer_name IS NULL AND p_program_name IS NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_src_chr_id_crs(p_scs_code,'Y');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
      ELSE
       OPEN l_src_chr_id_crs(p_scs_code,'N');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
      END IF;

    ELSIF( p_customer_name IS NOT NULL AND p_program_name IS NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_source_chr_id_crs(p_scs_code,'Y',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
      ELSE
       OPEN l_source_chr_id_crs(p_scs_code,'N',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
      END IF;

    ELSIF( p_customer_name IS NOT NULL AND p_program_name IS NOT NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_source_chr_prog_id_crs(p_scs_code,'Y',p_customer_id1,p_customer_id2,l_object_code, l_program_id);
       FETCH l_source_chr_prog_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_prog_id_crs;
      ELSE
       OPEN l_source_chr_prog_id_crs(p_scs_code,'N',p_customer_id1,p_customer_id2,l_object_code, l_program_id);
       FETCH l_source_chr_prog_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_prog_id_crs;
      END IF;

    ELSIF( p_customer_name IS NULL AND p_program_name IS NOT NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_source_prog_crs(p_scs_code,'Y',l_program_id);
       FETCH l_source_prog_crs INTO p_source_chr_id;
       CLOSE l_source_prog_crs;
      ELSE
       OPEN l_source_prog_crs(p_scs_code,'N',l_program_id);
       FETCH l_source_prog_crs INTO p_source_chr_id;
       CLOSE l_source_prog_crs;
      END IF;

    END IF;

    IF(p_source_chr_id IS NULL) THEN
   	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
 				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
 				, p_token1 => 'COL_NAME'
 				, p_token1_value => l_ak_prompt
 			   );
 	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    END IF;

    IF (p_source_code = 'new') THEN

        create_new_deal(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_contract_number => p_contract_number,
         p_scs_code        => p_scs_code,
         p_customer_id1    => p_customer_id1,
         p_customer_id2    => p_customer_id2,
         p_customer_code   => l_object_code,
         p_customer_name   => p_customer_name,
         p_template_yn     => l_template_yn,
         p_template_type   => p_template_type,
         p_effective_from  => p_effective_from,
         p_program_name    => p_program_name,
         p_program_id      => p_program_id,
         x_chr_id          => x_chr_id,
         p_legal_entity_id => p_legal_entity_id);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       l_chr_id := x_chr_id;

       IF okl_context.get_okc_org_id  IS NULL THEN
		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
       END IF;


       IF ( p_scs_code = 'LEASE') THEN

       OKL_LA_PROPERTY_TAX_PVT.create_est_prop_tax_rules(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => l_chr_id);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       END IF;

        -- copy from template
    ELSIF (p_source_code = 'template') THEN

          create_from_template(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    ELSIF (p_source_code = 'copy' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   -- update contract header for template_yn
   IF ( p_template_type IS NOT NULL AND ( p_source_code = 'copy' OR p_source_code = 'template')) THEN

    lp_chrv_rec.id := x_chr_id;
    lp_khrv_rec.id := x_chr_id;

    IF(p_template_type = OKL_TEMP_TYPE_PROGRAM) THEN
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_PROGRAM;
      lp_chrv_rec.template_yn := 'Y';
    ELSIF(p_template_type = OKL_TEMP_TYPE_CONTRACT) THEN
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_CONTRACT;
      lp_chrv_rec.template_yn := 'Y';
    ELSIF(p_template_type = OKL_TEMP_TYPE_LEASEAPP) THEN
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_LEASEAPP;
      lp_chrv_rec.template_yn := 'Y';
    ELSE
      lp_khrv_rec.template_type_code := NULL;
    END IF;

    IF(p_effective_from IS NOT NULL) THEN

      lp_chrv_rec.start_date := p_effective_from;

    END IF;

    IF(l_program_id IS NOT NULL) THEN

      lp_khrv_rec.khr_id := l_program_id;

    END IF;

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   ELSIF ( p_template_type IS NULL AND ( p_source_code = 'copy' OR p_source_code = 'template')) THEN

    lp_chrv_rec.id := x_chr_id;
    lp_khrv_rec.id := x_chr_id;
    lp_chrv_rec.template_yn := 'N';
    lp_khrv_rec.template_type_code := NULL;

    IF(p_effective_from IS NOT NULL) THEN

      lp_chrv_rec.start_date := p_effective_from;

    END IF;

    IF(l_program_id IS NOT NULL) THEN

      lp_khrv_rec.khr_id := l_program_id;

    END IF;

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

	raise_business_event(p_chr_id        => x_chr_id
	                    ,x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
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
  END;


PROCEDURE update_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_rec                     IN  upd_deal_rec_type,
      x_durv_rec                     OUT NOCOPY upd_deal_rec_type
    ) AS

    l_api_name	       VARCHAR2(30) := 'update_deal';
    l_api_version      CONSTANT NUMBER	  := 1.0;

    l_template_yn      OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_id	       NUMBER;
    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    PROCEDURE raise_business_event(
    	p_chr_id IN NUMBER
	,x_return_status OUT NOCOPY VARCHAR2
    )
	IS
	  l_check VARCHAR2(1);
          l_parameter_list           wf_parameter_list_t;
	BEGIN
          x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	  -- Raise the event if it is a new Contract
	  l_check := Okl_Lla_Util_Pvt.check_new_contract(p_chr_id);
          IF (l_check= OKL_API.G_TRUE) THEN
  		wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
				 x_return_status  => x_return_status,
				 x_msg_count      => x_msg_count,
				 x_msg_data       => x_msg_data,
				 p_event_name     => G_WF_EVT_KHR_UPDATED,
				 p_parameters     => l_parameter_list);

	  END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;

BEGIN
  IF okl_context.get_okc_org_id  IS NULL THEN
	l_chr_id := p_durv_rec.chr_id;
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  END IF;

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.id := p_durv_rec.chr_id;
    lp_khrv_rec.id := p_durv_rec.chr_id;
    lp_chrv_rec.contract_number :=  p_durv_rec.chr_contract_number;
    lp_chrv_rec.description :=  p_durv_rec.chr_description;
    lp_chrv_rec.short_description :=  p_durv_rec.chr_description;
    lp_chrv_rec.start_date :=  p_durv_rec.chr_start_date;
    lp_chrv_rec.end_date :=  p_durv_rec.chr_end_date;
    lp_khrv_rec.CONVERTED_ACCOUNT_YN :=  p_durv_rec.khr_CONVERTED_ACCOUNT_YN;
    lp_chrv_rec.TEMPLATE_YN :=  p_durv_rec.chr_TEMPLATE_YN;
    lp_chrv_rec.DATE_SIGNED :=  p_durv_rec.chr_DATE_SIGNED;
    lp_chrv_rec.currency_code :=  x_durv_rec.chr_currency_code;
    lp_khrv_rec.legal_entity_id :=p_durv_rec.legal_entity_id;

    OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
	raise_business_event(p_chr_id        => p_durv_rec.chr_id
	                    ,x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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
  END;
END Okl_Mla_Create_Update_Pub;

/

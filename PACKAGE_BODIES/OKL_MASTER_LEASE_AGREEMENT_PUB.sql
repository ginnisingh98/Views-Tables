--------------------------------------------------------
--  DDL for Package Body OKL_MASTER_LEASE_AGREEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MASTER_LEASE_AGREEMENT_PUB" AS
/*$Header: OKLPMAGB.pls 120.5 2006/11/17 10:30:57 zrehman noship $*/
/*
*  Following is the generic program flow
*  -------------------------------------
*  Create Master Lease Agreement Header - First Step
*  Create Party Role - Second Step
*  Create Terms and Conditions - Third Step
*  Create Articles - Fourth Step
*/


/*
* Procedure: CREATE_MASTER_LEASE_AGREEMENT
*/
PROCEDURE create_master_lease_agreement(
		          p_api_version     	 IN NUMBER,
                          p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	                  p_header_rec           IN  HEADER_REC,
                          p_article_tbl          IN article_tbl,
                          x_return_status        OUT NOCOPY VARCHAR2,
                          x_msg_count            OUT NOCOPY NUMBER,
                          x_msg_data             OUT NOCOPY VARCHAR2)
AS

  l_api_name    VARCHAR2(35) := 'CREATE_MASTER_LEASE';
  l_chr_id      NUMBER := NULL;
  l_line_id     NUMBER := NULL;
  l_cpl_id      NUMBER := NULL;
  l_rrd_id      NUMBER := NULL;
  l_credit_id   NUMBER := NULL;

  l_chrv_rec    chrv_rec_type;
  l_khrv_rec    khrv_rec_type;
  lx_chrv_rec   chrv_rec_type;
  lx_khrv_rec   khrv_rec_type;

  l_cplv_tbl    cplv_tbl_type;
  lx_cplv_tbl   cplv_tbl_type;
  l_rgr_tbl     rgr_tbl_type;

  l_catv_tbl    catv_tbl_type;
  lx_catv_tbl   catv_tbl_type;

  l_gvev_rec    gvev_rec_type;
  lx_gvev_rec   gvev_rec_type;

  j NUMBER 	    := NULL;
  counter VARCHAR2(1) := 'F';

  l_msg_index_out number;

-- Get Article ID and Release
l_sae_id NUMBER := NULL;

CURSOR get_article (p_name IN VARCHAR2, p_version IN VARCHAR2) IS
	select sar.id
	from   okc_std_articles_v sar,
	       okc_std_art_versions_v svr
	where  sar.id = svr.sae_id
	and    sar.name = p_name
	and    svr.sav_release = p_version;


CURSOR get_credit_line_id (p_credit_line IN VARCHAR2) IS
	SELECT id
	FROM   okc_k_headers_v
	WHERE  contract_number = p_credit_line;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                            ,p_init_msg_list => p_init_msg_list
                                            ,p_api_type      => '_PUB'
                                            ,x_return_status => x_return_status
                                            );
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;



/* Agreement Header */
l_chrv_rec.contract_number := p_header_rec.AGREEMENT_NUMBER;
l_chrv_rec.short_description := p_header_rec.DESCRIPTION;
l_chrv_rec.description := p_header_rec.DESCRIPTION;
l_chrv_rec.INV_ORGANIZATION_ID := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);
l_chrv_rec.AUTHORING_ORG_ID := mo_global.get_current_org_id();
l_chrv_rec.scs_code := 'MASTER_LEASE';
l_chrv_rec.sts_code := 'NEW';
l_chrv_rec.ARCHIVED_YN := 'N';
l_chrv_rec.DELETED_YN := 'N';
l_chrv_rec.BUY_OR_SELL := 'S';
l_chrv_rec.ISSUE_OR_RECEIVE := 'I';
l_chrv_rec.DATE_SIGNED := p_header_rec.DATE_SIGNED;
l_chrv_rec.START_DATE  := p_header_rec.START_DATE;
l_chrv_rec.END_DATE  := p_header_rec.END_DATE;
l_chrv_rec.CURRENCY_CODE  := p_header_rec.CURRENCY_CODE;
l_chrv_rec.TEMPLATE_YN := p_header_rec.TEMPLATE_YN;
l_khrv_rec.CONVERTED_ACCOUNT_YN := p_header_rec.CONVERTED_ACCOUNT_YN;
l_chrv_rec.ORIG_SYSTEM_REFERENCE1 := p_header_rec.CONVERTED_LEGACY_NO;
-- added by zrehman for LE Uptake project on 17-NOV-2006
l_chrv_rec.LEGAL_ENTITY_ID := p_header_rec.LEGAL_ENTITY_ID;

OKL_CONTRACT_PUB.create_contract_header(
    p_api_version		=> p_api_version,
    p_init_msg_list     => p_init_msg_list,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_chrv_rec          => l_chrv_rec,
    p_khrv_rec          => l_khrv_rec,
    x_chrv_rec          => lx_chrv_rec,
    x_khrv_rec          => lx_khrv_rec);

IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

-- Credit Line

IF (p_header_rec.CREDIT_LINE_NUMBER IS NOT NULL) THEN
	l_credit_id := NULL;

	OPEN get_credit_line_id (p_header_rec.CREDIT_LINE_NUMBER);
	FETCH get_credit_line_id INTO l_credit_id;
	CLOSE get_credit_line_id;

	l_gvev_rec.chr_id_referred := l_credit_id;
	l_gvev_rec.chr_id := lx_chrv_rec.id;
	l_gvev_rec.dnz_chr_id := lx_chrv_rec.id;
	l_gvev_rec.COPIED_ONLY_YN := 'N';

	IF (l_credit_id IS NOT NULL) THEN

		OKL_OKC_MIGRATION_PVT.create_governance(
    			p_api_version     => p_api_version,
    			p_init_msg_list   => p_init_msg_list,
    			x_return_status   => x_return_status,
    			x_msg_count       => x_msg_count,
    			x_msg_data        => x_msg_data,
    			p_gvev_rec        => l_gvev_rec,
    			x_gvev_rec        => lx_gvev_rec);

		IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		  RAISE OKC_API.G_EXCEPTION_ERROR;
		END IF;

	END IF;

END IF;



/* Party Role */


-- Lessor
l_cplv_tbl(1).chr_id      := lx_chrv_rec.id;
l_cplv_tbl(1).dnz_chr_id  := lx_chrv_rec.id;
l_cplv_tbl(1).rle_code    := 'LESSOR';
l_cplv_tbl(1).object1_id1 := mo_global.get_current_org_id();
l_cplv_tbl(1).object1_id2 := '#';
l_cplv_tbl(1).JTOT_OBJECT1_CODE := 'OKX_OPERUNIT';

-- Customer
l_cplv_tbl(2).chr_id      := lx_chrv_rec.id;
l_cplv_tbl(2).dnz_chr_id  := lx_chrv_rec.id;
l_cplv_tbl(2).rle_code    := 'LESSEE';
l_cplv_tbl(2).object1_id1 := p_header_rec.customer_id;
l_cplv_tbl(2).object1_id2 := '#';
l_cplv_tbl(2).JTOT_OBJECT1_CODE := 'OKX_PARTY';

OKL_OKC_MIGRATION_PVT.create_k_party_role(
			  p_api_version	=> p_api_version,
                    p_init_msg_list	=> p_init_msg_list,
                    x_return_status	=> x_return_status,
                    x_msg_count	=> x_msg_count,
                    x_msg_data	=> x_msg_data,
                    p_cplv_tbl	=> l_cplv_tbl,
                    x_cplv_tbl	=> lx_cplv_tbl);

IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

l_chr_id := lx_chrv_rec.id;

/* Terms and Conditions */

-- End Term
j := 1;
counter := 'F';
IF (p_header_rec.TC_TPO_END_TERM_OPTION IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LATROP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAEOTR';
    	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_TPO_END_TERM_OPTION;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;
IF (p_header_rec.TC_TPO_END_TERM_AMT IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LATROP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAEOTR';
	l_rgr_tbl(j).rule_information2 := p_header_rec.TC_TPO_END_TERM_AMT;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;

-- Mid Term
IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;
IF (p_header_rec.TC_TPO_MID_TERM_OPTION IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LATROP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAMITR';
    	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_TPO_MID_TERM_OPTION;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;
IF (p_header_rec.TC_TPO_MID_TERM_OPTION IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LATROP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAMITR';
	l_rgr_tbl(j).rule_information2 := p_header_rec.TC_TPO_MID_TERM_AMT;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;

-- Tax
IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;
IF (p_header_rec.TC_TAX_WITHHOLD_YN IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LAUKTX';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAUKTX';
    	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_TAX_WITHHOLD_YN;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;
IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;
IF (p_header_rec.TC_TAX_FORMULA IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LAUKTX';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAFORM';
	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_TAX_FORMULA;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;

-- Insurance
IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;

IF (p_header_rec.TC_INS_BLANKET_YN IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'INSRUL';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'INCUST';
	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_INS_BLANKET_YN;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;
IF (p_header_rec.TC_INS_INSURABLE_YN IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'INSRUL';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'INCUST';
	l_rgr_tbl(j).rule_information2 := p_header_rec.TC_INS_INSURABLE_YN;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;

IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;
IF (p_header_rec.TC_INS_CANCEL_YN IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'INSRUL';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'INNCAN';
    	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_INS_CANCEL_YN;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;

-- Renewals
IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;
IF (p_header_rec.TC_RO_RENEW_OPTION IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LARNOP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LARNEW';
	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_RO_RENEW_OPTION;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;
IF (p_header_rec.TC_RO_RENEW_AMT IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LARNOP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LARNEW';
	l_rgr_tbl(j).rule_information2 := p_header_rec.TC_RO_RENEW_AMT;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;

IF (counter = 'T') THEN
	j := j + 1;
	counter := 'F';
END IF;

IF (p_header_rec.TC_RO_RENEW_NOTICE_DAYS IS NOT NULL) THEN
	l_rgr_tbl(j).rgd_code	:= 'LARNOP';
	l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAREND';
    	l_rgr_tbl(j).rule_information1 := p_header_rec.TC_RO_RENEW_NOTICE_DAYS;
	l_rgr_tbl(j).std_template_yn := 'N';
	l_rgr_tbl(j).warn_yn := 'N';
	l_rgr_tbl(j).template_yn := 'N';
	counter := 'T';
END IF;


OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules(
      p_api_version	=> p_api_version,
      p_init_msg_list   => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chr_id          => l_chr_id,
      p_line_id         => l_line_id,
      p_cpl_id          => l_cpl_id,
      p_rrd_id          => l_rrd_id,
      p_rgr_tbl         => l_rgr_tbl);

IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

/* Article */
IF (p_article_tbl.count > 0) THEN

	FOR i IN p_article_tbl.FIRST..p_article_tbl.LAST
	LOOP
		l_catv_tbl(i).cat_type := 'STA';
		l_catv_tbl(i).fulltext_yn := 'Y';

		OPEN get_article (p_article_tbl(i).article_name, p_article_tbl(i).version);
		FETCH get_article INTO l_sae_id;
		CLOSE get_article;

		l_catv_tbl(i).SAV_SAE_ID := l_sae_id;
 		l_catv_tbl(i).SAV_SAV_RELEASE := p_article_tbl(i).version;
		l_catv_tbl(i).chr_id := lx_chrv_rec.id;
		l_catv_tbl(i).dnz_chr_id := lx_chrv_rec.id;
		l_catv_tbl(i).name := p_article_tbl(i).article_name;

	END LOOP;

	OKL_VP_K_ARTICLE_PUB.create_k_article(
				   p_api_version		=> p_api_version,
                           p_init_msg_list	=> p_init_msg_list,
                           x_return_status	=> x_return_status,
                           x_msg_count		=> x_msg_count,
                           x_msg_data		=> x_msg_data,
                           p_catv_tbl		=> l_catv_tbl,
                           x_catv_tbl		=> lx_catv_tbl);


	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	  RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

END IF;

OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data );

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

END create_master_lease_agreement;

END;

/

--------------------------------------------------------
--  DDL for Package Body OKL_VENDOR_AGREEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDOR_AGREEMENT_PUB" AS
/*$Header: OKLPVAGB.pls 120.3.12010000.2 2009/06/08 23:19:22 sechawla ship $*/
/*
*  Following is the generic program flow
*  -------------------------------------
*  Create Vendor Agreement Header - First Step
*  Create Party Role - Second Step
*  Create Contact Role - Third Step
*  Create Rule Group - Fourth Step
*  Create Terms and Conditions - Fifth Step
*  Create Articles - Sixth Step
*/


PROCEDURE create_vendor_agreement (
				          p_api_version     	    IN NUMBER,
                          p_init_msg_list           IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          p_hdr_rec                 IN program_header_rec,
                          p_parent_agreement_number IN VARCHAR2 DEFAULT NULL,
                          p_party_role_contact_tbl  IN party_role_contact_tbl,
			              p_vendor_billing_rec	    IN VENDOR_BILLING_REC,
                          p_terms_n_conditions_tbl  IN TERMS_AND_CONDITIONS_TBL,
                          p_article_tbl	          IN article_tbl,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count               OUT NOCOPY NUMBER,
                          x_msg_data                OUT NOCOPY VARCHAR2
					)
AS

  l_api_name    	VARCHAR2(35)    := 'CREATE_VENDOR_AGREEMENT';
  lx_header_rec	chrv_rec_type;
  lx_k_header_rec khrv_rec_type;
  l_chr_id      	NUMBER := NULL;
  l_line_id     	NUMBER := NULL;
  l_cpl_id      	NUMBER := NULL;
  l_rrd_id      	NUMBER := NULL;
  l_cplv_tbl    	cplv_tbl_type;
  lx_cplv_tbl   	cplv_tbl_type;
  l_cplv_rec    	cplv_rec_type;
  lx_cplv_rec    	cplv_rec_type;
  l_ctcv_tbl    	ctcv_tbl_type;
  lx_ctcv_tbl   	ctcv_tbl_type;
  l_jtot_object1_code OKC_K_PARTY_ROLES_V.jtot_object1_code%TYPE;
  l_jtot_object1_code_contact OKC_CONTACTS_V.jtot_object1_code%TYPE;
  l_rgpv_tbl    	rgpv_tbl_type;
  lx_rgpv_tbl   	rgpv_tbl_type;
  l_rgr_tbl     	rgr_tbl_type;
  l_catv_tbl    	catv_tbl_type;
  lx_catv_tbl    	catv_tbl_type;

  j NUMBER := 0;
  k NUMBER := 0;

  l_msg_index_out number;
  l_dummy NUMBER;

-- Get Party  Type
CURSOR get_party_role_jtot (p_rle_code IN VARCHAR2, p_category IN VARCHAR2) IS
	SELECT rso.jtot_object_code
      FROM   okc_subclass_roles sre,
             okc_role_sources rso
      WHERE  sre.scs_code = p_category
      AND    rso.rle_code = sre.rle_code
      AND    rso.rle_code = p_rle_code
      AND    rso.buy_or_sell = 'S';

-- Get Contact Type
CURSOR get_contact_role_jtot (p_party_role_code IN VARCHAR2,
                              p_contact_role_code IN VARCHAR2) IS
	SELECT jtot_object_code
	FROM   okc_contact_sources
	WHERE  rle_code = p_party_role_code
	AND    buy_or_sell = 'S'
	AND    CRO_CODE = p_contact_role_code;

-- Get CPL ID
CURSOR get_party_role_id (p_party_role_code IN VARCHAR2,
				  p_party_role_id IN NUMBER,
				  p_chr_id IN NUMBER) IS
	SELECT id
	FROM   OKC_K_PARTY_ROLES_B
	WHERE  chr_id = p_chr_id
	AND    object1_id1 = p_party_role_id
	AND    rle_code = p_party_role_code;

-- Get RRD ID for Vendor Billing association
CURSOR get_rrd_id IS
    select id
    from okc_rg_role_defs
    where sre_id = (select id
                    from okc_subclass_roles
                    where scs_code = 'PROGRAM' and rle_code = 'OKL_VENDOR')
    and srd_id = (  select id
                    from okc_subclass_rg_defs
                    where scs_code = 'PROGRAM' and rgd_code = 'LAVENB');

-- Get Article ID and Release
l_sae_id NUMBER := NULL;

CURSOR get_article (p_name IN VARCHAR2, p_version IN VARCHAR2) IS
	select sar.id
	from   okc_std_articles_v sar,
	       okc_std_art_versions_v svr
	where  sar.id = svr.sae_id
	and    sar.name = p_name
	and    svr.sav_release = p_version;

--27-May-2009 sechawla 6826580 : added
CURSOR l_invoice_formats(cp_inv_fmt_name IN VARCHAR2) IS
   SELECT ID
   FROM   okl_invoice_formats_v
   WHERE  name = cp_inv_fmt_name;

   l_inv_fmt_id  NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                            ,p_init_msg_list => p_init_msg_list
                                            ,p_api_type      => '_PUB'
                                            ,x_return_status => x_return_status);
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  /* Agreement Header */
  OKL_VENDOR_PROGRAM_PUB.create_program (p_api_version 			=> p_api_version,
                                         p_init_msg_list 		=> p_init_msg_list,
                                         x_return_status 		=> x_return_status,
                                         x_msg_count			=> x_msg_count,
                                         x_msg_data             => x_msg_data,
                                         p_hdr_rec             	=> p_hdr_rec,
                                         p_parent_agreement_number 	=> p_parent_agreement_number,
                                         x_header_rec			=> lx_header_rec,
                                         x_k_header_rec         => lx_k_header_rec);
  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  /* Party Role */
  IF (p_party_role_contact_tbl.count > 0) THEN
	k := 1;
	FOR i IN p_party_role_contact_tbl.FIRST..p_party_role_contact_tbl.LAST
	LOOP
      -- Following check avoids calling party API because lease vendor is
      -- created as part of header in the previous step, but creates additional
      -- parties.
      IF (p_party_role_contact_tbl(i).party_role_code = 'OKL_VENDOR' AND
	      p_party_role_contact_tbl(i).contact_role_code IS NOT NULL AND
	      p_party_role_contact_tbl(i).contact_role_id IS NOT NULL) THEN
		  NULL;
	  ELSE
        -- Following check avoids same party being created twice,
        -- but allows for more contacts for the same party in the
        -- next step for 'party contact' creation
        l_dummy := 0;
        FOR z IN 1..k-1
        LOOP
          IF (l_cplv_tbl(z).rle_code = p_party_role_contact_tbl(i).party_role_code AND
              l_cplv_tbl(z).object1_id1 = p_party_role_contact_tbl(i).party_role_id) THEN
              l_dummy := 1;
          END IF;
        END LOOP;

        IF (l_dummy = 0) THEN
            l_cplv_tbl(k).chr_id      := lx_header_rec.id;
            l_cplv_tbl(k).dnz_chr_id  := lx_header_rec.id;
      	    l_cplv_tbl(k).rle_code    := p_party_role_contact_tbl(i).party_role_code;
            l_cplv_tbl(k).object1_id1 := p_party_role_contact_tbl(i).party_role_id;
  	        l_cplv_tbl(k).object1_id2 := '#';
       	    -- Get Party Type 'OKX_PARTY', 'OKX_VENDOR' etc.
   	        OPEN  get_party_role_jtot ( p_party_role_contact_tbl(i).party_role_code,
                                       lx_header_rec.scs_code);
   	        FETCH get_party_role_jtot INTO l_jtot_object1_code;
   	        CLOSE get_party_role_jtot;

            l_cplv_tbl(k).jtot_object1_code   := l_jtot_object1_code;
   			k := k+1;
        END IF;
      END IF;
    END LOOP;
	OKL_CONTRACT_PARTY_PUB.create_k_party_role(p_api_version	=> p_api_version,
                                               p_init_msg_list	=> p_init_msg_list,
                                               x_return_status	=> x_return_status,
                                               x_msg_count	=> x_msg_count,
                                               x_msg_data	=> x_msg_data,
                                               p_cplv_tbl	=> l_cplv_tbl,
                                               x_cplv_tbl	=> lx_cplv_tbl);
	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	  RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
  END IF;

  /* Party Contact */
  IF(p_party_role_contact_tbl.count > 0) THEN
    k := 0;
    FOR i IN p_party_role_contact_tbl.FIRST..p_party_role_contact_tbl.LAST
    LOOP
      -- rabhupat BUG#4574673/#4593854 start
      -- populate the contact table only when the contact information is provided
      IF(p_party_role_contact_tbl(i).contact_role_code IS NOT NULL AND p_party_role_contact_tbl(i).contact_role_code <> OKL_API.G_MISS_CHAR AND
         p_party_role_contact_tbl(i).contact_role_id IS NOT NULL AND p_party_role_contact_tbl(i).contact_role_id <> OKL_API.G_MISS_NUM) THEN
      -- rabhupat BUG#4574673/#4593854 end
         -- Get Party Role ID
         OPEN get_party_role_id (p_party_role_contact_tbl(i).party_role_code,
                                 p_party_role_contact_tbl(i).party_role_id,
                                 lx_header_rec.id);
         FETCH get_party_role_id INTO l_cpl_id;
         CLOSE get_party_role_id;
         -- Get Contact Type 'OKX_SALEPERS' etc.
         OPEN get_contact_role_jtot (p_party_role_contact_tbl(i).party_role_code,
                                     p_party_role_contact_tbl(i).contact_role_code);
         FETCH get_contact_role_jtot INTO l_jtot_object1_code_contact;
         CLOSE get_contact_role_jtot;
         k := k+1;
         l_ctcv_tbl(k).dnz_chr_id := lx_header_rec.id;
         l_ctcv_tbl(k).cpl_id := l_cpl_id;
         l_ctcv_tbl(k).cro_code := p_party_role_contact_tbl(i).contact_role_code;
         l_ctcv_tbl(k).object1_id1 := p_party_role_contact_tbl(i).contact_role_id;
         l_ctcv_tbl(k).object1_id2 := '#';
         l_ctcv_tbl(k).jtot_object1_code := l_jtot_object1_code_contact;
       END IF;
    END LOOP;
    OKL_CONTRACT_PARTY_PUB.create_contact(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_ctcv_tbl      => l_ctcv_tbl,
                                          x_ctcv_tbl      => lx_ctcv_tbl);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
 	  RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
  END IF;
  /* Terms and Conditions */
  IF (p_terms_n_conditions_tbl.count > 0) THEN
    FOR i IN p_terms_n_conditions_tbl.FIRST..p_terms_n_conditions_tbl.LAST
    LOOP
      l_rgr_tbl(i).rgd_code	:= p_terms_n_conditions_tbl(i).rule_group_code;
      l_rgr_tbl(i).RULE_INFORMATION_CATEGORY  := p_terms_n_conditions_tbl(i).rule_code;
      l_rgr_tbl(i).object1_id1:= p_terms_n_conditions_tbl(i).object1_id1;
      l_rgr_tbl(i).object2_id1:= p_terms_n_conditions_tbl(i).object2_id1;
      l_rgr_tbl(i).object3_id1:= p_terms_n_conditions_tbl(i).object3_id1;
      l_rgr_tbl(i).object1_id2:= p_terms_n_conditions_tbl(i).object1_id2;
      l_rgr_tbl(i).object2_id2:= p_terms_n_conditions_tbl(i).object2_id2;
      l_rgr_tbl(i).object3_id2:= p_terms_n_conditions_tbl(i).object3_id2;
      l_rgr_tbl(i).jtot_object1_code:= p_terms_n_conditions_tbl(i).jtot_object1_code;
      l_rgr_tbl(i).jtot_object2_code:= p_terms_n_conditions_tbl(i).jtot_object2_code;
      l_rgr_tbl(i).jtot_object3_code:= p_terms_n_conditions_tbl(i).jtot_object3_code;
      l_rgr_tbl(i).std_template_yn := 'N';
      l_rgr_tbl(i).warn_yn := 'N';
      l_rgr_tbl(i).rule_information1 := p_terms_n_conditions_tbl(i).rule_information1;
      l_rgr_tbl(i).rule_information2 := p_terms_n_conditions_tbl(i).rule_information2;
      l_rgr_tbl(i).rule_information3 := p_terms_n_conditions_tbl(i).rule_information3;
      l_rgr_tbl(i).rule_information4 := p_terms_n_conditions_tbl(i).rule_information4;
      l_rgr_tbl(i).rule_information5 := p_terms_n_conditions_tbl(i).rule_information5;
      l_rgr_tbl(i).rule_information6 := p_terms_n_conditions_tbl(i).rule_information6;
      l_rgr_tbl(i).rule_information7 := p_terms_n_conditions_tbl(i).rule_information7;
      l_rgr_tbl(i).rule_information8 := p_terms_n_conditions_tbl(i).rule_information8;
      l_rgr_tbl(i).rule_information9 := p_terms_n_conditions_tbl(i).rule_information9;
      l_rgr_tbl(i).rule_information10 := p_terms_n_conditions_tbl(i).rule_information10;
      l_rgr_tbl(i).rule_information11 := p_terms_n_conditions_tbl(i).rule_information11;
      l_rgr_tbl(i).rule_information12 := p_terms_n_conditions_tbl(i).rule_information12;
      l_rgr_tbl(i).rule_information13 := p_terms_n_conditions_tbl(i).rule_information13;
      l_rgr_tbl(i).rule_information14 := p_terms_n_conditions_tbl(i).rule_information14;
      l_rgr_tbl(i).rule_information15 := p_terms_n_conditions_tbl(i).rule_information15;
      l_rgr_tbl(i).template_yn := 'N';
    END LOOP;
    l_line_id := NULL;
    l_cpl_id:= NULL;
    l_rrd_id:= NULL;

    OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules(p_api_version	=> p_api_version,
                                                        p_init_msg_list   => p_init_msg_list,
                                                        x_return_status   => x_return_status,
                                                        x_msg_count       => x_msg_count,
                                                        x_msg_data        => x_msg_data,
                                                        p_chr_id          => lx_header_rec.id,
                                                        p_line_id         => l_line_id,
                                                        p_cpl_id          => l_cpl_id,
                                                        p_rrd_id          => l_rrd_id,
                                                        p_rgr_tbl         => l_rgr_tbl);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

  /* Vendor Billing */
  -- rabhupat bug#4520143/#4530455 added G_MISS check
  IF (p_vendor_billing_rec.customer_id IS NOT NULL AND p_vendor_billing_rec.customer_id <> OKL_API.G_MISS_NUM AND
      p_vendor_billing_rec.cust_acct_id IS NOT NULL AND p_vendor_billing_rec.cust_acct_id <> OKL_API.G_MISS_NUM AND
      p_vendor_billing_rec.bill_to_site_use_id IS NOT NULL AND p_vendor_billing_rec.bill_to_site_use_id <> OKL_API.G_MISS_NUM) THEN

      l_cplv_rec.cust_acct_id        := p_vendor_billing_rec.cust_acct_id;
      l_cplv_rec.bill_to_site_use_id := p_vendor_billing_rec.bill_to_site_use_id;
      -- Get Party Role Record ID
      OPEN  get_party_role_id('OKL_VENDOR', to_number(p_hdr_rec.P_OBJECT1_ID1),lx_header_rec.id );
      FETCH get_party_role_id INTO l_cpl_id;
      CLOSE get_party_role_id;
      l_cplv_rec.id := l_cpl_id;
      OKL_CONTRACT_PARTY_PUB.update_k_party_role(
                    p_api_version	=> p_api_version,
                    p_init_msg_list	=> p_init_msg_list,
                    x_return_status	=> x_return_status,
                    x_msg_count	=> x_msg_count,
                    x_msg_data	=> x_msg_data,
                    p_cplv_rec	=> l_cplv_rec,
                    x_cplv_rec	=> lx_cplv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_rgr_tbl.DELETE;
      -- Process Customer ID
      -- rabhupat bug#4520143 removed the redundent condition
      j := 1;
      l_rgr_tbl(j).rgd_code	:= 'LAVENB';
      l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAVENC';
      l_rgr_tbl(j).object1_id1:= to_char(p_vendor_billing_rec.customer_id);
      l_rgr_tbl(j).object1_id2:= NULL;
      l_rgr_tbl(j).jtot_object1_code:= 'OKX_PARTY';
      l_rgr_tbl(j).std_template_yn := 'N';
      l_rgr_tbl(j).warn_yn := 'N';
      l_rgr_tbl(j).rule_information1 := NULL;
      l_rgr_tbl(j).rule_information2 := NULL;
      l_rgr_tbl(j).rule_information3 := NULL;
      l_rgr_tbl(j).rule_information4 := NULL;
      l_rgr_tbl(j).template_yn := 'N';
      -- Get RRD ID
      OPEN get_rrd_id ;
      FETCH get_rrd_id INTO l_rrd_id;
      CLOSE get_rrd_id ;
      -- Line ID is NULL
      l_line_id := NULL;
      -- Process Payment Method
      j := j+1;
      l_rgr_tbl(j).rgd_code	:= 'LAVENB';
      l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAPMTH';
      -- rabhupat BUG#4574673 start
      -- populate the information if payment method is passed
      IF(p_vendor_billing_rec.PAYMENT_METHOD IS NOT NULL AND p_vendor_billing_rec.PAYMENT_METHOD <> OKL_API.G_MISS_NUM) THEN
         l_rgr_tbl(j).object1_id1:= p_vendor_billing_rec.PAYMENT_METHOD;
         l_rgr_tbl(j).object1_id2:= '#';
         l_rgr_tbl(j).jtot_object1_code:= 'OKX_RCPTMTH';
      END IF;
      l_rgr_tbl(j).std_template_yn := 'N';
      l_rgr_tbl(j).warn_yn := 'N';
      l_rgr_tbl(j).template_yn := 'N';
      -- Process Bank Account
      j := j+1;
      l_rgr_tbl(j).rgd_code	:= 'LAVENB';
      l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LABACC';
      -- rabhupat BUG#4574673 start
      -- populate the information if bank account is passed
      IF(p_vendor_billing_rec.bank_account IS NOT NULL AND p_vendor_billing_rec.bank_account <> OKL_API.G_MISS_NUM) THEN
        l_rgr_tbl(j).object1_id1:= p_vendor_billing_rec.bank_account;
        l_rgr_tbl(j).object1_id2:= '#';
        l_rgr_tbl(j).jtot_object1_code:= 'OKX_CUSTBKAC';
      END IF;
      l_rgr_tbl(j).std_template_yn := 'N';
      l_rgr_tbl(j).warn_yn := 'N';
      l_rgr_tbl(j).template_yn := 'N';
      -- Process Invoice Format
      j := j+1;
      l_rgr_tbl(j).rgd_code	:= 'LAVENB';
      l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAINVD';
      l_rgr_tbl(j).object1_id1:= NULL;
      l_rgr_tbl(j).object1_id2:= NULL;
      l_rgr_tbl(j).jtot_object1_code:= NULL;
      l_rgr_tbl(j).std_template_yn := 'N';
      l_rgr_tbl(j).warn_yn := 'N';

      --27-May-2009 sechawla 6826580 : added
      OPEN   l_invoice_formats(p_vendor_billing_rec.invoice_format);
      FETCH  l_invoice_formats INTO l_inv_fmt_id;
      CLOSE  l_invoice_formats;

      --27-May-2009 sechawla 6826580 : store ID instead of Name
      l_rgr_tbl(j).rule_information1 := to_char(l_inv_fmt_id); --p_vendor_billing_rec.invoice_format;

      l_rgr_tbl(j).template_yn := 'N';
      -- Process Review Invoice flag
      -- rabhupat BUG#4574673 start
      -- if review invoice falg is not checked passing 'N'
      IF(p_vendor_billing_rec.review_invoice IS NOT NULL AND p_vendor_billing_rec.review_invoice <> OKL_API.G_MISS_CHAR) THEN
        l_rgr_tbl(j).rule_information4 := p_vendor_billing_rec.review_invoice;
      ELSE
        l_rgr_tbl(j).rule_information4 := 'N';
      END IF;
      -- Process Review Invoice reason
      j := j+1;
      l_rgr_tbl(j).rgd_code	:= 'LAVENB';
      l_rgr_tbl(j).RULE_INFORMATION_CATEGORY := 'LAINPR';
      l_rgr_tbl(j).object1_id1:= NULL;
      l_rgr_tbl(j).object1_id2:= NULL;
      l_rgr_tbl(j).jtot_object1_code:= NULL;
      l_rgr_tbl(j).std_template_yn := 'N';
      l_rgr_tbl(j).warn_yn := 'N';
      l_rgr_tbl(j).rule_information1 := p_vendor_billing_rec.review_reason;
      l_rgr_tbl(j).template_yn := 'N';
      -- Process Review Invoice Date
      -- rabhupat BUG#4574673 start
      -- populate the information if review until date is passed
      IF(p_vendor_billing_rec.review_until_date IS NOT NULL AND p_vendor_billing_rec.review_until_date <> OKL_API.G_MISS_DATE) THEN
        l_rgr_tbl(j).rule_information2 := p_vendor_billing_rec.review_until_date;
      END IF;
      -- Process Rule Groups and Rules for vendor billing
      -- and associate it with the vendor party role
      OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules(
	      p_api_version	=> p_api_version,
	      p_init_msg_list   => p_init_msg_list,
	      x_return_status   => x_return_status,
	      x_msg_count       => x_msg_count,
	      x_msg_data        => x_msg_data,
	      p_chr_id          => lx_header_rec.id,
	      p_line_id         => l_line_id,
	      p_cpl_id          => l_cpl_id,
	      p_rrd_id          => l_rrd_id,
	      p_rgr_tbl         => l_rgr_tbl);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
      l_catv_tbl(i).chr_id := lx_header_rec.id;
      l_catv_tbl(i).dnz_chr_id := lx_header_rec.id;
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

     --27-May-2009 sechawla 6826580
     IF l_invoice_formats%ISOPEN THEN
        CLOSE l_invoice_formats;
     END IF;

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

     --27-May-2009 sechawla 6826580
     IF l_invoice_formats%ISOPEN THEN
        CLOSE l_invoice_formats;
     END IF;

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN

     --27-May-2009 sechawla 6826580
     IF l_invoice_formats%ISOPEN THEN
        CLOSE l_invoice_formats;
     END IF;

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

END create_vendor_agreement;

END;

/

--------------------------------------------------------
--  DDL for Package Body OKL_VENDOR_PROGRAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDOR_PROGRAM_PVT" AS
/* $Header: OKLRPRMB.pls 120.16 2008/02/15 11:05:10 abhsaxen noship $ */


/*NEW CODE BEGIN MARCH 20*/
--SUBTYPE chrv_rec_type    IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
--SUBTYPE khrv_rec_type    IS OKL_CONTRACT_PUB.khrv_rec_type;
SUBTYPE govern_rec_type   IS OKC_CONTRACT_PUB.gvev_rec_type;
SUBTYPE process_rec_type  IS OKC_CONTRACT_PUB.cpsv_rec_type;
SUBTYPE gvev_rec_type  IS OKC_CONTRACT_PUB.gvev_rec_type;

G_SQLCODE_TOKEN CONSTANT VARCHAR2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN CONSTANT VARCHAR(200) := 'ERROR_MESSAGE';

G_BUY_OR_SELL VARCHAR2(20) DEFAULT 'S';
G_LESSOR_RLE_CODE VARCHAR(100) DEFAULT 'LESSOR';
G_VENDOR_RLE_CODE VARCHAR(100) DEFAULT 'OKL_VENDOR';

G_VENDOR_RES_SHARE_RG CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'VGLRS';
G_VENDOR_RES_PECENT_RL CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'VGLRSP';

CURSOR l_chr_csr2(contract_no VARCHAR2,contract_no_modifier VARCHAR2) IS
  SELECT 'x'
  FROM okc_k_headers_b
  WHERE contract_number = contract_no
  AND   contract_number_modifier = contract_no_modifier;

--Murthy Added Cursors for JTOT OBJECT CODE and check for CONTRACT ID
CURSOR cur_jtot_object_code(p_rle_code IN VARCHAR2, p_scs_code IN VARCHAR2, p_buy_or_sell IN VARCHAR2) IS
  SELECT jtot_object_code
  FROM okc_role_sources rs, okc_subclass_roles sr
  WHERE rs.rle_code = sr.rle_code AND SYSDATE BETWEEN rs.start_date AND NVL(rs.end_date,SYSDATE)
  AND SYSDATE BETWEEN sr.start_date AND NVL(sr.end_date,SYSDATE)
  AND rs.rle_code = p_rle_code
  AND rs.buy_or_sell = p_buy_or_sell AND sr.scs_code = p_scs_code;

--Murthy
CURSOR cur_k_party_roles(contract_id NUMBER) IS
SELECT id FROM okc_k_party_roles_b
WHERE chr_id = contract_id AND rle_code = g_vendor_rle_code;

CURSOR cur_parent_object_id(contract_id NUMBER) IS
SELECT object1_id1,object1_id2 FROM okc_k_party_roles_b
WHERE chr_id = contract_id AND rle_code = g_vendor_rle_code;

CURSOR  cur_k_header(parent_agreement_number VARCHAR2) IS
  SELECT v.id
  FROM okc_k_headers_v v
  WHERE v.contract_number = parent_agreement_number;

/*---------------------------------------------------------------------------+
|                                                                            |
|  PROCEDURE:  CREATE_HEADER                                                 |
|  DESC   : Contract Header Record Creation                                  |
|  HISTORY: 20 March 2002 Created by Murthy                                  |
*-------------------------------------------------------------------------- */
PROCEDURE create_header(
         p_api_version             IN  NUMBER,
         p_init_msg_list           IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
         x_return_status           OUT NOCOPY VARCHAR2,
         x_msg_count               OUT NOCOPY NUMBER,
         x_msg_data                OUT NOCOPY VARCHAR2,
         p_hdr_rec                 IN  program_header_rec_type,
         p_parent_agreement_number IN  okl_k_headers_full_v.contract_number%TYPE DEFAULT NULL,
         p_chrv_rec                IN  chrv_rec_type,
         p_khrv_rec                IN  khrv_rec_type,
         x_chrv_rec                OUT NOCOPY chrv_rec_type,
         x_khrv_rec                OUT NOCOPY  khrv_rec_type) IS

  l_header_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  x_header_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  l_k_header_rec OKL_CONTRACT_PUB.khrv_rec_type;
  x_k_header_rec OKL_CONTRACT_PUB.khrv_rec_type;
  -- sjalasut, added local pl/sql table for vendor residual share enhancement
  lv_rgr_tbl OKL_RGRP_RULES_PROCESS_PVT.rgr_tbl_type;

  cpsv_rec_type1 process_rec_type;
  cpsv_rec_type2 process_rec_type;
  gvev_rec_type1 govern_rec_type;
  gvev_rec_type2 govern_rec_type;

  --Murthy
  l_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
  x_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
  l_jtot_object_code VARCHAR(200);
  l_object1_id1 VARCHAR(200);
  l_object1_id2 VARCHAR(200);
  l_agreement_id NUMBER;

  l_copy_rec okl_vp_copy_contract_pub.copy_header_rec_type;
  l_update_rec OKL_VENDOR_PROGRAM_PUB.program_header_rec_type;

  l_contract_id  NUMBER;
  l_parent_id NUMBER;

  l_new_contract_id NUMBER;
  x_new_contract_id NUMBER;

  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l1_return_status VARCHAR2(3);
  l2_return_status VARCHAR2(3);
  l3_return_status VARCHAR2(3);

  l_api_version  NUMBER := 1.0;

  l_api_name  CONSTANT VARCHAR2(30) := 'create_header';

  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_dummy VARCHAR2(1);
  l_found BOOLEAN;

/*  --Murthy Added Cursors for JTOT OBJECT CODE and check for CONTRACT ID
  CURSOR cur_jtot_object_code(p_rle_code IN VARCHAR2, p_scs_code IN VARCHAR2, p_buy_or_sell IN VARCHAR2) IS
    SELECT jtot_object_code
    FROM okc_role_sources rs, okc_subclass_roles sr
    WHERE rs.rle_code = sr.rle_code AND SYSDATE BETWEEN rs.start_date AND NVL(rs.end_date,SYSDATE)
    AND SYSDATE BETWEEN sr.start_date AND NVL(sr.end_date,SYSDATE)
    AND rs.rle_code = p_rle_code
    AND rs.buy_or_sell = p_buy_or_sell AND sr.scs_code = p_scs_code;
*/
  CURSOR cur_object_id(khr_id NUMBER) IS
    SELECT jtot_object1_code, object1_id1, object1_id2
    FROM okc_k_party_roles_b
    WHERE dnz_chr_id = khr_id
    AND rle_code = g_vendor_rle_code;

  --TYPE cur_contract_id_type IS REF CURSOR;
  --cur_contract_id cur_contract_id_type;

  -- begin of block
  -- chr_type is hard coded.
  -- to be removed as and when things are clarified.

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    Select  access_level
    from    OKC_ROLE_SOURCES
    where rle_code = p_rle_code
    and     buy_or_sell = 'S';

    --Manu : 14-Jun-2005
    -- Cursor to get the QA Process ID for Operating/Program Agreement
    CURSOR qa_csr(p_qa_name VARCHAR2) IS
    SELECT id FROM OKC_QA_CHECK_LISTS_V WHERE name = p_qa_name;

    l_qa_id OKC_QA_CHECK_LISTS_V .id%TYPE := NULL;

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

BEGIN

/*  l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                            ,p_init_msg_list => p_init_msg_list
                                            ,p_api_type      => '_PVT'
                                            ,x_return_status => x_return_status
                                            );
  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
*/
  -- setting the authoring org id and inv organization id

  OKL_CONTEXT.SET_OKC_ORG_CONTEXT;
  l_header_rec.inv_organization_id := OKC_CONTEXT.Get_OKC_Organization_Id;
  l_header_rec.authoring_org_id := OKC_CONTEXT.get_okc_org_id;

  l_header_rec.sts_code := 'NEW';
  l_header_rec.qcl_id := p_hdr_rec.p_qcl_id;
  l_header_rec.scs_code := p_hdr_rec.p_contract_category;
  l_header_rec.contract_number := p_hdr_rec.p_agreement_number;
  l_header_rec.archived_yn := 'N';
  l_header_rec.deleted_yn := 'N';
  l_header_rec.template_yn := p_hdr_rec.p_template_yn;
  -- Fix Bug 3388759 --
  -- l_header_rec.currency_code := 'USD';
  l_header_rec.currency_code := okl_accounting_util.get_func_curr_code();
  l_header_rec.chr_type := 'SELL';
  l_header_rec.CONTRACT_NUMBER_MODIFIER := '1.0';

  l_header_rec.short_description := p_hdr_rec.p_short_description;
  l_header_rec.description := p_hdr_rec.p_description;
  l_header_rec.comments := p_hdr_rec.p_comments;

  l_header_rec.start_date := p_hdr_rec.p_start_date;
  l_header_rec.end_date := p_hdr_rec.p_end_date;

  -- abindal start --
  l_k_header_rec.attribute_category := p_hdr_rec.p_attribute_category;
  l_k_header_rec.attribute1  := p_hdr_rec.p_attribute1;
  l_k_header_rec.attribute2  := p_hdr_rec.p_attribute2;
  l_k_header_rec.attribute3  := p_hdr_rec.p_attribute3;
  l_k_header_rec.attribute4  := p_hdr_rec.p_attribute4;
  l_k_header_rec.attribute5  := p_hdr_rec.p_attribute5;
  l_k_header_rec.attribute6  := p_hdr_rec.p_attribute6;
  l_k_header_rec.attribute7  := p_hdr_rec.p_attribute7;
  l_k_header_rec.attribute8  := p_hdr_rec.p_attribute8;
  l_k_header_rec.attribute9  := p_hdr_rec.p_attribute9;
  l_k_header_rec.attribute10 := p_hdr_rec.p_attribute10;
  l_k_header_rec.attribute11 := p_hdr_rec.p_attribute11;
  l_k_header_rec.attribute12 := p_hdr_rec.p_attribute12;
  l_k_header_rec.attribute13 := p_hdr_rec.p_attribute13;
  l_k_header_rec.attribute14 := p_hdr_rec.p_attribute14;
  l_k_header_rec.attribute15 := p_hdr_rec.p_attribute15;
  /* sosharma ,31 oct 2006
     Build:R12
     Assigning Legal entity value to l_k_header_rec
     Start Changes*/
    l_k_header_rec.legal_entity_id := p_hdr_rec.p_legal_entity_id;
  /* End Changes*/
  -- abindal end --


  --Murthy
  l_header_rec.buy_or_sell := g_buy_or_sell;

  --fmiao added issue_or_receive defaulting qcl_id (qa checker)--
  l_header_rec.issue_or_receive := 'I';

  -- Manu : 14-Jun-2005
  -- Default the QA Check process for Program/Operating Agreement.
  IF (l_header_rec.scs_code = 'OPERATING') THEN
    OPEN qa_csr(p_qa_name => 'OKL OA QA CHECK LIST');
       FETCH qa_csr INTO l_qa_id;
    CLOSE qa_csr;
    l_header_rec.qcl_id := l_qa_id;
  ELSIF (l_header_rec.scs_code = 'PROGRAM') THEN
    OPEN qa_csr(p_qa_name => 'OKL PA QA CHECK LIST');
       FETCH qa_csr INTO l_qa_id;
    CLOSE qa_csr;
    l_header_rec.qcl_id := l_qa_id;
  END IF;

  IF (l_header_rec.qcl_id IS NULL) THEN
    l_header_rec.qcl_id := 1;
  END IF;

  -- setting for okl_contract_pub for creation of referred program template
  --fmiao--l_k_header_rec.khr_id := p_hdr_rec.p_referred_id;

  --  call the create_contract_header
  OKL_CONTRACT_PUB.create_contract_header(
  p_api_version 	=> l_api_version,
  x_return_status	=> l_return_status,
  p_init_msg_list       => OKL_API.G_TRUE,
  x_msg_count		=> l_msg_count,
  x_msg_data		=> l_msg_data,
  p_chrv_rec		=> l_header_rec,
  p_khrv_rec		=> l_k_header_rec,
  x_chrv_rec		=> x_header_rec,
  x_khrv_rec		=> x_k_header_rec);
  x_chrv_rec := x_header_rec;
  x_khrv_rec := x_k_header_rec;
  -- if the insert in the okc_k_headers_v is successful,then insert a record into okc_k_processes_v

  IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

    IF (((p_hdr_rec.p_workflow_process) <> OKL_API.G_MISS_NUM) AND ((p_hdr_rec.p_workflow_process) IS NOT NULL))THEN

      l_contract_id :=x_header_rec.id;
      cpsv_rec_type1.chr_id :=l_contract_id;
      cpsv_rec_type1.pdf_id :=p_hdr_rec.p_workflow_process;

      okc_contract_pub.create_contract_process(
      p_api_version      =>  l_api_version,
      p_init_msg_list    => OKL_API.G_FALSE,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_cpsv_rec         => cpsv_rec_type1,
      x_cpsv_rec         => cpsv_rec_type2);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        NULL;
      ELSE
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;

  ELSE
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  END IF;

  -- Begin Creating Lessor
  OPEN cur_jtot_object_code(g_lessor_rle_code,p_hdr_rec.p_contract_category,g_buy_or_sell);
  FETCH cur_jtot_object_code INTO l_jtot_object_code;
  IF(cur_jtot_object_code%found) THEN
    NULL;
    CLOSE cur_jtot_object_code;
  ELSE
    CLOSE cur_jtot_object_code;
  -- Murthy Set message to be registered
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_JTOT_CODE_NOT_FOUND');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_agreement_id := x_header_rec.id;
  l_cplv_rec.chr_id := l_agreement_id;
  l_cplv_rec.dnz_chr_id := l_agreement_id;
  l_cplv_rec.jtot_object1_code := l_jtot_object_code;
  l_cplv_rec.rle_code := g_lessor_rle_code;
  l_cplv_rec.object1_id1 := OKC_CONTEXT.get_okc_org_id;
  l_cplv_rec.object1_id2 := '#';
  l_cplv_rec.cpl_id:= NULL;
  l_cplv_rec.cle_id:= NULL;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(l_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

       okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => l_cplv_rec.jtot_object1_code,
                                                          p_id1            => l_cplv_rec.object1_id1,
                                                          p_id2            => l_cplv_rec.object1_id2);

	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

     END IF;

----  Changes End


  OKC_CONTRACT_PARTY_PUB.create_k_party_role(p_api_version => p_api_version,
                                         p_init_msg_list => OKL_API.G_FALSE,
                                         x_return_status => l_return_status,
                                         x_msg_count => x_msg_count,
                                         x_msg_data => x_msg_data,
                                         p_cplv_rec => l_cplv_rec,
                                         x_cplv_rec => x_cplv_rec
                                        );

  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  -- End Creating Lessor

  -- sjalasut, added creation of a rule group and rule for Lessor Residual Share percent. START
  -- first determine the Party Role Id for this Rule Group
  -- Manu 19-Oct-2005 Restricting the Residual Share to PROGRAM.
  IF(x_cplv_rec.id IS NOT NULL AND p_hdr_rec.p_contract_category = 'PROGRAM')THEN
    lv_rgr_tbl(1).rgd_code := G_VENDOR_RES_SHARE_RG;
    lv_rgr_tbl(1).dnz_chr_id := x_header_rec.id;
    lv_rgr_tbl(1).rule_information_category := G_VENDOR_RES_PECENT_RL;
    lv_rgr_tbl(1).rule_information1 := x_cplv_rec.id;
    -- this is to indicate that the default share of 100% goes to the Lessor
    lv_rgr_tbl(1).rule_information2 := 100;
    lv_rgr_tbl(1).std_template_yn := 'N';
    lv_rgr_tbl(1).warn_yn := 'N';

    /*
    lv_rgr_tbl(2).rgd_code := G_VENDOR_RES_SHARE_RG;
    lv_rgr_tbl(2).dnz_chr_id := x_header_rec.id;
    lv_rgr_tbl(2).rule_information_category := 'VGLRSF';
    lv_rgr_tbl(2).rule_information1 := 'VENDOR_RESIDUAL_SHARE';
    lv_rgr_tbl(2).std_template_yn := 'N';
    lv_rgr_tbl(2).warn_yn := 'N';
    */

    okl_rgrp_rules_process_pub.process_rule_group_rules(p_api_version   => p_api_version
                                                       ,p_init_msg_list => OKL_API.G_FALSE
                                                       ,x_return_status => x_return_status
                                                       ,x_msg_count     => x_msg_count
                                                       ,x_msg_data      => x_msg_data
                                                       ,p_chr_id        => x_header_rec.id
                                                       ,p_line_id       => NULL
                                                       ,p_cpl_id        => NULL
                                                       ,p_rrd_id        => NULL
                                                       ,p_rgr_tbl       => lv_rgr_tbl
                                                       );
    IF(x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

  -- sjalasut, added creation of a rule group and rule for Lessor Residual Share percent. END

/*  OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      );
*/
EXCEPTION

WHEN OKL_API.G_EXCEPTION_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
  /*x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );*/

WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
/*  x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           l_api_name
                           ,g_pkg_name
                           ,'OKL_API.G_RET_STS_ERROR'
                           ,x_msg_count
                           ,x_msg_data
                           ,'_PVT'
                           );*/

WHEN OTHERS THEN
x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
/*  x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           l_api_name
                           ,g_pkg_name
                           ,'OTHERS'
                           ,x_msg_count
                           ,x_msg_data
                           ,'_PVT'
                           );*/
END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION :  VALIDATE_ATTRIBUTES                                           |
|  DESC   : Validation of Attributes                                         |
|  HISTORY: 20 March 2002 Created by Murthy                                  |
*-------------------------------------------------------------------------- */
FUNCTION validate_attributes(p_hdr_rec program_header_rec_type,
                             p_parent_agreement_number IN okl_k_headers_full_v.contract_number%TYPE DEFAULT NULL) RETURN VARCHAR2 IS
l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_dummy VARCHAR2(1);
l_found BOOLEAN;
BEGIN

  IF ((p_hdr_rec.p_agreement_number = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_agreement_number IS NULL)) THEN
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_AGREEMENT_NO_REQUIRED');
    l_return_status :=okl_api.g_ret_sts_error;
    return OKL_API.G_RET_STS_ERROR;
  END IF;

  -- check whether the contract already exists before calling the api.

  OPEN l_chr_csr2(p_hdr_rec.p_agreement_number,'1.0');
  FETCH l_chr_csr2 into l_dummy;
  l_found := l_chr_csr2%FOUND;
  CLOSE l_chr_csr2;

  IF (l_found) THEN
    OKL_API.SET_MESSAGE(p_app_name		=> g_app_name,
                        p_msg_name  	=> 'OKL_VP_CONTRACT_EXISTS',
                        p_token1    	=> 'NUMBER',
                        p_token1_value	=> p_hdr_rec.p_agreement_number
                        );
    return OKL_API.G_RET_STS_ERROR;
  END IF;

  IF ((p_hdr_rec.p_contract_category = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_contract_category IS NULL)) THEN
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_CATEGORY_REQUIRED');
    l_return_status :=okl_api.g_ret_sts_error;
    return OKL_API.G_RET_STS_ERROR;
  END IF;



  -- Category is OPERATING
  IF (p_hdr_rec.p_contract_category = 'OPERATING') THEN

    IF (p_hdr_rec.p_template_yn = 'Y') THEN
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_OP_AGMT_NOT_SET_TMPL');
      return OKL_API.G_RET_STS_ERROR;
    END IF;

    IF(p_parent_agreement_number IS NOT NULL  AND p_parent_agreement_number <> OKL_API.G_MISS_CHAR) THEN
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_OP_AGMT_NOT_HAVE_PRNT');
      return OKL_API.G_RET_STS_ERROR;
    END IF;
/*--fmiao--
    IF (p_hdr_rec.p_referred_id IS NOT NULL AND p_hdr_rec.p_referred_id <> OKL_API.G_MISS_NUM ) THEN
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_OP_AGMT_NOT_BE_REFRD');
        return OKL_API.G_RET_STS_ERROR;
    END IF; --fmiao*/
/*    IF (p_hdr_rec.p_object1_id1 <> OKL_API.G_MISS_CHAR AND p_hdr_rec.p_object1_id1 IS NOT NULL AND
      p_hdr_rec.p_object1_id2 <> OKL_API.G_MISS_CHAR AND p_hdr_rec.p_object1_id2 IS NOT NULL) OR
     ( p_hdr_rec.p_template_yn <> 'N' AND p_hdr_rec.p_template_yn <> OKL_API.G_MISS_CHAR ) THEN
      NULL;
    ELSE
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_VENDOR_REQUIRED');
      return OKL_API.G_RET_STS_ERROR;
    END IF;
*/
    IF ((p_hdr_rec.p_object1_id1 = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_object1_id1 IS NULL) OR
      (p_hdr_rec.p_object1_id2 = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_object1_id2 IS NULL)) AND
      (p_hdr_rec.p_template_yn = 'N' OR p_hdr_rec.p_template_yn = OKL_API.G_MISS_CHAR ) THEN
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_VENDOR_REQUIRED');
      return OKL_API.G_RET_STS_ERROR;
    END IF;
  -- Category is PROGRAM
  ELSIF (p_hdr_rec.p_contract_category = 'PROGRAM') THEN

  --  IF(p_hdr_rec.p_template_yn = 'N') THEN
  /*--fmiao--
    IF (p_parent_agreement_number IS NOT NULL  AND p_parent_agreement_number <> OKL_API.G_MISS_CHAR AND
         p_hdr_rec.p_referred_id IS NOT NULL AND p_hdr_rec.p_referred_id <> OKL_API.G_MISS_NUM ) THEN
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_PRG_NOT_HAVE_BOTH_OP_PRG');
      return OKL_API.G_RET_STS_ERROR;
    ELSIF ( (p_parent_agreement_number IS NULL OR p_parent_agreement_number = OKL_API.G_MISS_CHAR) AND
          (p_hdr_rec.p_referred_id IS NULL OR p_hdr_rec.p_referred_id = OKL_API.G_MISS_NUM) ) THEN
      IF(p_hdr_rec.p_template_yn = 'Y') THEN
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_EITHER_PRNT_OR_REF');
        return OKL_API.G_RET_STS_ERROR;
      END IF;
    END IF; --fmiao--*/
    IF ((p_hdr_rec.p_object1_id1 = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_object1_id1 IS NULL) OR
      (p_hdr_rec.p_object1_id2 = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_object1_id2 IS NULL)) AND
      (p_hdr_rec.p_template_yn = 'N' OR p_hdr_rec.p_template_yn = OKL_API.G_MISS_CHAR ) THEN
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_VENDOR_REQUIRED');
      return OKL_API.G_RET_STS_ERROR;
    END IF;
  END IF;

-- Start and End Date Validations
  IF ((p_hdr_rec.p_start_date  = OKL_API.G_MISS_DATE) OR (p_hdr_rec.p_start_date IS NULL)) THEN
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_START_DATE_REQUIRED');
    l_return_status :=okl_api.g_ret_sts_error;
    return OKL_API.G_RET_STS_ERROR;
  END IF;

  IF ((p_hdr_rec.p_end_date  = OKL_API.G_MISS_DATE) OR (p_hdr_rec.p_end_date IS NULL)) THEN
    NULL;
  ELSIF (p_hdr_rec.p_end_date < p_hdr_rec.p_start_date)THEN
    OKL_API.SET_MESSAGE(p_app_name  => G_APP_NAME,
                      p_msg_name  => 'OKL_INVALID_TO_DATE');
    return OKL_API.G_RET_STS_ERROR;
  -- sjalasut, added trunc on both sides
  ELSIF (TRUNC(p_hdr_rec.p_end_date) < TRUNC(SYSDATE)) THEN
    OKL_API.SET_MESSAGE(p_app_name  => G_APP_NAME,
                      p_msg_name  => 'OKL_INVALID_EFF_TO_DATE');
    return OKL_API.G_RET_STS_ERROR;
  END IF;

--bug#2460595
-- QA Check List Validation
/* --fmiao qa chechlist not needed for the new oa page --
  IF ((p_hdr_rec.p_qcl_id = OKL_API.G_MISS_NUM) OR (p_hdr_rec.p_qcl_id IS NULL)) THEN
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_QACHECK_REQUIRED');
    l_return_status :=okl_api.g_ret_sts_error;
    return OKL_API.G_RET_STS_ERROR;
  END IF;
*/
return l_return_status;
EXCEPTION
WHEN OTHERS THEN
 /* OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                      p_msg_name => g_unexpected_error,
                      p_token1   => g_sqlcode_token,
                      p_token1_value => sqlcode,
                      p_token2      => g_sqlerrm_token,
                      p_token2_value => sqlerrm
                      );*/
  l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  return l_return_status;
END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  PROCEDURE:  CREATE_PROGRAM                                                |
|  DESC   : Program Creation                                                 |
|  HISTORY: 20 March 2002 Created by Murthy                                  |
*-------------------------------------------------------------------------- */
PROCEDURE create_program(p_api_version             IN               NUMBER,
                         p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status           OUT              NOCOPY VARCHAR2,
                         x_msg_count               OUT              NOCOPY NUMBER,
                         x_msg_data                OUT              NOCOPY VARCHAR2,
                         p_hdr_rec                 IN               program_header_rec_type,
                         p_parent_agreement_number IN               okl_k_headers_full_v.contract_number%TYPE DEFAULT NULL,
                         x_header_rec              OUT NOCOPY              chrv_rec_type,
                         x_k_header_rec            OUT NOCOPY              khrv_rec_type)
IS
l_api_version  NUMBER := 1.0;
l_api_name  CONSTANT VARCHAR2(30) := 'create_program';
l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
parent_is_not_null BOOLEAN;
--fmiao--referred_is_not_null BOOLEAN;
l_jtot_object_code VARCHAR(200);
l_object1_id1 VARCHAR(200);
l_object1_id2 VARCHAR(200);
l_prnt_object1_id1 VARCHAR(200);
l_prnt_object1_id2 VARCHAR(200);
--l_vendor_name VARCHAR2(200);
--Bug# 2706328 (utf8 compliance)
l_vendor_name VARCHAR2(240);
l_agreement_id NUMBER;
l_parent_id NUMBER;
l_header_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
--x_header_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
l_k_header_rec OKL_CONTRACT_PUB.khrv_rec_type;
--x_k_header_rec OKL_CONTRACT_PUB.khrv_rec_type;
l_gvev_rec gvev_rec_type;
x_gvev_rec gvev_rec_type;
l_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
x_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

l_hdr_rec program_header_rec_type;

/*CURSOR  cur_k_header(parent_agreement_number varchar2) is
  SELECT v.id
  FROM okc_k_headers_v v
  WHERE v.contract_number = parent_agreement_number;
*/

CURSOR cur_object_id(khr_id NUMBER) IS
  SELECT jtot_object1_code, object1_id1, object1_id2
  FROM okc_k_party_roles_b
  WHERE dnz_chr_id = khr_id
  AND rle_code = g_vendor_rle_code;

--Changed the cursor query to use base tables than uv --dkagrawa
CURSOR cur_vendor_name(chr_id NUMBER) IS
  SELECT pov.vendor_name vendor_name
  FROM okc_k_headers_b chrb,
       okc_k_party_roles_b kpr,
       po_vendors pov
  WHERE chrb.id = kpr.dnz_chr_id
  AND kpr.rle_code = 'OKL_VENDOR'
  AND kpr.object1_id1 = pov.vendor_id
  AND chrb.id = chr_id;



l_new_contract_id NUMBER;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

CURSOR role_csr(p_rle_code VARCHAR2)  IS
Select  access_level
from    OKC_ROLE_SOURCES
where rle_code = p_rle_code
and     buy_or_sell = 'S';

l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

--Added by abhsxen for bug 6487870
 l_kplv_rec  okl_kpl_pvt.kplv_rec_type;
 x_kplv_rec  okl_kpl_pvt.kplv_rec_type;
 --end abhsxen
BEGIN
    x_return_status          := OKC_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  parent_is_not_null := p_parent_agreement_number IS NOT NULL  AND p_parent_agreement_number <> OKL_API.G_MISS_CHAR;
  --fmiao--referred_is_not_null := p_hdr_rec.p_referred_id IS NOT NULL  AND p_hdr_rec.p_referred_id <> OKL_API.G_MISS_NUM;

  l_return_status := validate_attributes(p_hdr_rec => p_hdr_rec,
                      p_parent_agreement_number =>p_parent_agreement_number);

  l_hdr_rec := p_hdr_rec;

  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  /* fmiao --
  --The following call is not needed. If creating template, template_yn = 'Y'--
  IF (p_hdr_rec.p_template_yn = 'Y') THEN
    create_header(p_api_version 	=> l_api_version,
                  x_return_status	=> l_return_status,
                  p_init_msg_list       => OKL_API.G_TRUE,
                  x_msg_count		=> l_msg_count,
                  x_msg_data		=> l_msg_data,
                  p_hdr_rec             => p_hdr_rec,
                  p_parent_agreement_number => p_parent_agreement_number,
                  p_chrv_rec		=> l_header_rec,
                  p_khrv_rec		=> l_k_header_rec,
                  x_chrv_rec		=> x_header_rec,
                  x_khrv_rec		=> x_k_header_rec);
    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
      NULL;
    ELSE
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF (parent_is_not_null) THEN
      OPEN cur_k_header(p_parent_agreement_number);
      FETCH cur_k_header INTO l_parent_id;
      IF(cur_k_header%found) THEN
        CLOSE cur_k_header;
      ELSE
        CLOSE cur_k_header;
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_INVALID_PARENT_AGRMNT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_new_contract_id := x_header_rec.id;
      l_agreement_id := x_header_rec.id;
      l_gvev_rec.chr_id := l_new_contract_id;
      l_gvev_rec.dnz_chr_id := l_new_contract_id;
      --fmiao--l_gvev_rec.chr_id_referred := l_parent_id;
      l_gvev_rec.copied_only_yn := 'N';
      OKC_CONTRACT_PUB.create_governance( p_api_version => l_api_version,
                                          p_init_msg_list => OKL_API.G_TRUE,
                                          x_return_status => l_return_status,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data,
                                          p_gvev_rec => l_gvev_rec,
                                          x_gvev_rec => x_gvev_rec );
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        NULL;
      ELSE
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- Setting jtot stuff and party info.
      -- call for insert into vendor party role
      OPEN cur_jtot_object_code(g_vendor_rle_code, p_hdr_rec.p_contract_category,g_buy_or_sell);
      FETCH cur_jtot_object_code INTO l_jtot_object_code;
      IF(cur_jtot_object_code%found) THEN
        CLOSE cur_jtot_object_code;
      ELSE
        CLOSE cur_jtot_object_code;
      -- Murthy Set message to be registered
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_JTOT_CODE_NOT_FOUND');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --  set jtot stuff
      OPEN cur_object_id(l_parent_id);
      FETCH cur_object_id INTO l_jtot_object_code, l_object1_id1, l_object1_id2;
      IF(cur_object_id%found) THEN
        CLOSE cur_object_id;
      ELSE
        CLOSE cur_object_id;
        -- Murthy Set message to be registered
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_JTOT_CODE_NOT_FOUND');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Setting jtot stuff and party info.
      l_agreement_id := x_header_rec.id;
      l_cplv_rec.chr_id := l_agreement_id;
      l_cplv_rec.dnz_chr_id := l_agreement_id;
      l_cplv_rec.rle_code := g_vendor_rle_code;
      l_cplv_rec.jtot_object1_code := l_jtot_object_code;
      l_cplv_rec.object1_id1 := l_object1_id1;
      l_cplv_rec.object1_id2 := l_object1_id2;

    END IF; */
/*--fmiao--
    IF (referred_is_not_null) THEN
    --  set jtot stuff
      OPEN cur_object_id(p_hdr_rec.p_referred_id);
      FETCH cur_object_id INTO l_jtot_object_code, l_object1_id1, l_object1_id2;
      IF(cur_object_id%found) THEN
        CLOSE cur_object_id;
      ELSE
        CLOSE cur_object_id;
        -- Murthy Set message to be registered
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_JTOT_CODE_NOT_FOUND');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Setting jtot stuff and party info.
      l_agreement_id := x_header_rec.id;
      l_cplv_rec.chr_id := l_agreement_id;
      l_cplv_rec.dnz_chr_id := l_agreement_id;
      l_cplv_rec.rle_code := g_vendor_rle_code;
      l_cplv_rec.jtot_object1_code := l_jtot_object_code;
      l_cplv_rec.object1_id1 := l_object1_id1;
      l_cplv_rec.object1_id2 := l_object1_id2;
    END IF; --fmiao--*/
  --ELSIF (p_hdr_rec.p_template_yn = 'N') THEN
    IF (l_hdr_rec.p_template_yn IS NULL) THEN
	  l_hdr_rec.p_template_yn := 'N';
	END IF;
    create_header(p_api_version 	=> l_api_version,
                  x_return_status	=> l_return_status,
                  p_init_msg_list       => OKL_API.G_TRUE,
                  x_msg_count		=> l_msg_count,
                  x_msg_data		=> l_msg_data,
                  p_hdr_rec         => l_hdr_rec,
                  p_parent_agreement_number => p_parent_agreement_number,
                  p_chrv_rec		=> l_header_rec,
                  p_khrv_rec		=> l_k_header_rec,
                  x_chrv_rec		=> x_header_rec,
                  x_khrv_rec		=> x_k_header_rec);
    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
      NULL;
    ELSE
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Setting jtot stuff and party info.
    -- call for insert into vendor party role
    OPEN cur_jtot_object_code(g_vendor_rle_code, p_hdr_rec.p_contract_category,g_buy_or_sell);
    FETCH cur_jtot_object_code INTO l_jtot_object_code;
    IF(cur_jtot_object_code%found) THEN
      CLOSE cur_jtot_object_code;
    ELSE
      CLOSE cur_jtot_object_code;
    -- Murthy Set message to be registered
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_JTOT_CODE_NOT_FOUND');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_agreement_id := x_header_rec.id;
    l_cplv_rec.chr_id := l_agreement_id;
    l_cplv_rec.dnz_chr_id := l_agreement_id;
    l_cplv_rec.rle_code := g_vendor_rle_code;
    l_cplv_rec.jtot_object1_code := l_jtot_object_code;
    l_cplv_rec.object1_id1 := p_hdr_rec.p_object1_id1;
    l_cplv_rec.object1_id2 := p_hdr_rec.p_object1_id2;
    IF (parent_is_not_null) THEN
      OPEN cur_k_header(p_parent_agreement_number);
      FETCH cur_k_header INTO l_parent_id;
      IF(cur_k_header%found) THEN
        CLOSE cur_k_header;
      ELSE
        CLOSE cur_k_header;
        OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_INVALID_PARENT_AGRMNT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_agreement_id := x_header_rec.id;
      l_gvev_rec.chr_id := l_agreement_id;
      l_gvev_rec.dnz_chr_id := l_agreement_id;
      l_gvev_rec.chr_id_referred := l_parent_id;
      l_gvev_rec.copied_only_yn := 'N';
      OKC_CONTRACT_PUB.create_governance( p_api_version => l_api_version,
                                        p_init_msg_list => OKL_API.G_TRUE,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        p_gvev_rec => l_gvev_rec,
                                        x_gvev_rec => x_gvev_rec );
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        NULL;
      ELSE
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF;
/*--fmiao--
    IF (l_jtot_object_code IS NOT NULL) THEN
      IF (parent_is_not_null  AND p_hdr_rec.p_template_yn = 'N') THEN
        --OPEN cur_vendor_name(l_cplv_rec.dnz_chr_id);
        OPEN cur_vendor_name(l_parent_id);
        FETCH cur_vendor_name INTO l_vendor_name;
        IF(cur_vendor_name%found) THEN
          CLOSE cur_vendor_name;
        ELSE
          CLOSE cur_vendor_name;
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                      p_msg_name => 'OKL_PRNT_AGMT_MATCH_VENDOR',
                      p_token1    	=> 'token1',
                      p_token1_value	=> l_vendor_name
                      );
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        OPEN cur_parent_object_id(l_parent_id);
        FETCH cur_parent_object_id INTO l_prnt_object1_id1, l_prnt_object1_id2;
        IF(cur_parent_object_id%found) THEN
          CLOSE cur_parent_object_id;
        ELSE
          CLOSE cur_parent_object_id;
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                      p_msg_name => 'OKL_PRNT_AGMT_MATCH_VENDOR',
                      p_token1    	=> 'token1',
                      p_token1_value	=> l_vendor_name
                      );
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (l_prnt_object1_id1 <> p_hdr_rec.p_object1_id1 OR l_prnt_object1_id2 <>
            p_hdr_rec.p_object1_id2) THEN
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                      p_msg_name => 'OKL_PRNT_AGMT_MATCH_VENDOR',
                      p_token1    	=> 'token1',
                      p_token1_value	=> l_vendor_name
                      );
          RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;
      END IF;
    END IF; --fmiao--*/

  --END IF;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(l_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S')  THEN
        okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                       p_init_msg_list  => OKC_API.G_FALSE,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count	   => x_msg_count,
                                                       x_msg_data	   => x_msg_data,
                                                       p_object_name    => l_cplv_rec.jtot_object1_code,
                                                       p_id1            => l_cplv_rec.object1_id1,
                                                       p_id2            => l_cplv_rec.object1_id2);
	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

     END IF;


----  Changes End


  OKC_CONTRACT_PARTY_PUB.create_k_party_role(p_api_version => l_api_version,
                  p_init_msg_list => OKL_API.G_TRUE,
                  x_return_status => l_return_status,
                  x_msg_count     => l_msg_count,
                  x_msg_data      => l_msg_data,
                  p_cplv_rec => l_cplv_rec,
                  x_cplv_rec => x_cplv_rec );
  IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
    NULL;
  ELSE
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

--Added by abhsxen for bug 6487870
l_kplv_rec.ID := x_cplv_rec.ID;

OKL_KPL_PVT.Insert_Row(
	p_api_version     => p_api_version,
	p_init_msg_list   => p_init_msg_list,
	x_return_status   => x_return_status,
	x_msg_count       => x_msg_count,
	x_msg_data        => x_msg_data,
	p_kplv_rec        => l_kplv_rec,
	x_kplv_rec        => x_kplv_rec);

IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
--end abhsxen

    -- Call end_activity
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );

EXCEPTION

WHEN OKL_API.G_EXCEPTION_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
/*
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
                     (p_api_name  => l_api_name
                      ,p_pkg_name  => G_PKG_NAME
                      ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                      ,x_msg_count => x_msg_count
                      ,x_msg_data  => x_msg_data
                      ,p_api_type  => '_PVT'
                      );

*/
WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
/*  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                     ,g_pkg_name
                     ,'OKL_API.G_RET_STS_ERROR'
                     ,x_msg_count
                     ,x_msg_data
                     ,'_PVT'
                     );

*/
WHEN OTHERS THEN
x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
/*  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                     ,g_pkg_name
                     ,'OTHERS'
                     ,x_msg_count
                     ,x_msg_data
                     ,'_PVT'
                     );
*/
END;



/*NEW CODE END*/

PROCEDURE update_program(p_api_version             IN               NUMBER,
                         p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status           OUT              NOCOPY VARCHAR2,
                         x_msg_count               OUT              NOCOPY NUMBER,
                         x_msg_data                OUT              NOCOPY VARCHAR2,
                         p_hdr_rec                 IN               program_header_rec_type,
                         p_program_id              IN               okl_k_headers_full_v.id%TYPE,
                         p_parent_agreement_id     IN               okc_k_headers_v.ID%TYPE DEFAULT NULL)
IS

-- check for whether update is allowed for this contract
-- check for whether workflow process is active for this contract
-- depending on these,call the update_contract_header
-- not clear on p_restrict_update parameter in the update_contract_header api ?????????
-- templates are not updateable

l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'update_program';

--l_return_status VARCHAR2(3);

l1_header_rec  chrv_rec_type;
l2_header_rec  chrv_rec_type;
l_k_header_rec khrv_rec_type;
x_k_header_rec khrv_rec_type;

--Murthy
l1_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
l2_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

cpsv_rec_type3 process_rec_type;
cpsv_rec_type4 process_rec_type;

CURSOR l_chr_csr1(contract_id NUMBER, contract_no VARCHAR2,contract_no_modifier VARCHAR2) IS
  SELECT 'x'
  FROM okc_k_headers_b
  WHERE contract_number = contract_no
  AND   contract_number_modifier = contract_no_modifier
  AND id <> NVL(contract_id,-99999);

CURSOR  cur_k_header(program_id number) IS
SELECT v.contract_number   FROM okc_k_headers_b v
WHERE v.id =program_id;

CURSOR cur_k_process_id(program_id number) IS
SELECT p.id
FROM okc_k_processes_v p
WHERE p.chr_id=program_id;

l_party_id NUMBER;

l_contract_id VARCHAR2(50);
l_process_id NUMBER;
l_dummy VARCHAR2(1);
l_found BOOLEAN;

l_return_value	VARCHAR2(1) := 'N';

CURSOR role_csr(p_rle_code VARCHAR2)  IS
Select  access_level
from    OKC_ROLE_SOURCES
where rle_code = p_rle_code
and     buy_or_sell = 'S';

l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

  /* Manu Bug #4671978 27-Oct-2005 Begin */
  CURSOR cl_get_gov_id(p_program_id          OKC_K_HEADERS_V.ID%TYPE) IS
     SELECT ID FROM OKC_GOVERNANCES WHERE DNZ_CHR_ID = p_program_id;

  l_gov_id           OKC_GOVERNANCES.ID%TYPE;
  parent_is_not_null BOOLEAN;
  l_gvev_rec gvev_rec_type;
  x_gvev_rec gvev_rec_type;
  /* Manu Bug #4671978 27-Oct-2005 End */

	--Added by abhsxen for bug 6487870
	 l_kplv_rec  okl_kpl_pvt.kplv_rec_type;
	 x_kplv_rec  okl_kpl_pvt.kplv_rec_type;
	 --end abhsxen
BEGIN

l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                             ,p_init_msg_list => p_init_msg_list
                                             ,p_api_type      => '_PVT'
                                             ,x_return_status => x_return_status
                                             );

IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;

IF ((p_hdr_rec.p_agreement_number = OKL_API.G_MISS_CHAR) OR (p_hdr_rec.p_agreement_number IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_AGREEMENT_NO_REQUIRED');
         RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- check whether the contract already exists before calling the api.

OPEN l_chr_csr1(p_program_id, p_hdr_rec.p_agreement_number,'1.0');
FETCH l_chr_csr1 into l_dummy;
l_found := l_chr_csr1%FOUND;
CLOSE l_chr_csr1;

IF (l_found) THEN
  OKL_API.SET_MESSAGE(p_app_name        => g_app_name,
                      p_msg_name  	=> 'OKL_VP_CONTRACT_EXISTS',
                      p_token1    	=> 'NUMBER',
                      p_token1_value	=> p_hdr_rec.p_agreement_number
                      );
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF ((p_hdr_rec.p_start_date  = OKL_API.G_MISS_DATE) OR (p_hdr_rec.p_start_date IS NULL)) THEN
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_START_DATE_REQUIRED');
         RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF ((p_hdr_rec.p_end_date  = OKL_API.G_MISS_DATE) OR (p_hdr_rec.p_end_date IS NULL)) THEN
  NULL;
ELSIF (trunc(p_hdr_rec.p_end_date) < trunc(p_hdr_rec.p_start_date))THEN
  OKL_API.SET_MESSAGE(p_app_name  => G_APP_NAME,
                    p_msg_name  => 'OKL_INVALID_TO_DATE');
  RAISE OKL_API.G_EXCEPTION_ERROR;
ELSIF (trunc(p_hdr_rec.p_end_date) < trunc(sysdate)) THEN
  OKL_API.SET_MESSAGE(p_app_name  => G_APP_NAME,
                    p_msg_name  => 'OKL_INVALID_EFF_TO_DATE');
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF ((p_program_id = OKL_API.G_MISS_NUM) OR (p_program_id IS NULL)) THEN
        OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- to get the contract_number for the given program_id

OPEN cur_k_header(p_program_id);
FETCH cur_k_header INTO l_contract_id;
CLOSE cur_k_header;

l1_header_rec.id              := p_program_id;
l1_header_rec.contract_number := p_hdr_rec.p_agreement_number;
l1_header_rec.qcl_id          := p_hdr_rec.p_qcl_id;

l1_header_rec.short_description := p_hdr_rec.p_short_description;
l1_header_rec.description       := p_hdr_rec.p_description;
l1_header_rec.comments          := p_hdr_rec.p_comments;


l1_header_rec.start_date := p_hdr_rec.p_start_date;
l1_header_rec.end_date   := p_hdr_rec.p_end_date;

-- abindal start --
l_k_header_rec.attribute_category := p_hdr_rec.p_attribute_category;
l_k_header_rec.attribute1  := p_hdr_rec.p_attribute1;
l_k_header_rec.attribute2  := p_hdr_rec.p_attribute2;
l_k_header_rec.attribute3  := p_hdr_rec.p_attribute3;
l_k_header_rec.attribute4  := p_hdr_rec.p_attribute4;
l_k_header_rec.attribute5  := p_hdr_rec.p_attribute5;
l_k_header_rec.attribute6  := p_hdr_rec.p_attribute6;
l_k_header_rec.attribute7  := p_hdr_rec.p_attribute7;
l_k_header_rec.attribute8  := p_hdr_rec.p_attribute8;
l_k_header_rec.attribute9  := p_hdr_rec.p_attribute9;
l_k_header_rec.attribute10 := p_hdr_rec.p_attribute10;
l_k_header_rec.attribute11 := p_hdr_rec.p_attribute11;
l_k_header_rec.attribute12 := p_hdr_rec.p_attribute12;
l_k_header_rec.attribute13 := p_hdr_rec.p_attribute13;
l_k_header_rec.attribute14 := p_hdr_rec.p_attribute14;
l_k_header_rec.attribute15 := p_hdr_rec.p_attribute15;
 /* sosharma ,31 oct 2006
     Build:R12
     Assigning Legal entity value to l_k_header_rec
     Start Changes*/
l_k_header_rec.legal_entity_id := p_hdr_rec.p_legal_entity_id;
/*   End changes */
-- abindal end --


--Murthy
--Added so that when a agreement with parent is created, the new agreement
--must have category of PROGRAM only. Setting intent to BUY_OR_SELL
l1_header_rec.buy_or_sell := g_buy_or_sell;
l1_header_rec.scs_code := p_hdr_rec.p_contract_category;
IF (OKC_CONTRACT_PUB.Update_Allowed(p_program_id) <> 'Y') THEN
  l_return_status :=OKL_API.G_RET_STS_ERROR;
  OKL_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_VP_UPDATE_NOT_ALLOWED'
                      );
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF (is_process_active(p_program_id) <> 'N') THEN
  l_return_status :=OKL_API.G_RET_STS_ERROR;
  OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                      p_msg_name     => 'OKL_VP_APPROVAL_PROCESS_ACTV'
                     );
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

OKL_CONTRACT_PUB.update_contract_header(
    p_api_version	=> l_api_version,
    x_return_status	=> l_return_status,
    p_init_msg_list     => OKL_API.G_TRUE,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> l_msg_data,
    p_restricted_update	=> OKL_API.G_FALSE,
    p_chrv_rec		=> l1_header_rec,
    p_khrv_rec		=> l_k_header_rec,
    x_chrv_rec		=> l2_header_rec,
    x_khrv_rec		=> x_k_header_rec);


IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
  /* Manu 29-Jun-2005 Begin */
  passed_to_incomplete(p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_return_status => x_return_status
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_program_id        => p_program_id
                        );
  /****
  IF (l2_header_rec.STS_CODE = 'PASSED') THEN

      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => l_incomplete_status_code
                                                    ,p_chr_id        => p_program_id
                                                     );
  END IF;
  ****/
  /* Manu 29-Jun-2005 End */

  /* Manu Bug #4671978 27-Oct-2005 Begin */
    parent_is_not_null := p_parent_agreement_id IS NOT NULL  AND p_parent_agreement_id <> OKL_API.G_MISS_NUM;

    OPEN cl_get_gov_id(p_program_id);
    FETCH cl_get_gov_id INTO l_gov_id;
    CLOSE cl_get_gov_id;

    IF (parent_is_not_null) THEN
      IF (l_gov_id is not null) THEN
      -- Governances record exists update with the new parent agreement.
        l_gvev_rec.id              := l_gov_id;
        l_gvev_rec.chr_id          := p_program_id;
        l_gvev_rec.dnz_chr_id      := p_program_id;
        l_gvev_rec.chr_id_referred := p_parent_agreement_id;
        l_gvev_rec.copied_only_yn  := 'N';
        OKC_CONTRACT_PUB.update_governance( p_api_version => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        p_gvev_rec => l_gvev_rec,
                                        x_gvev_rec => x_gvev_rec );
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          NULL;
        ELSE
          IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      ELSE
      -- Parent Agreement does not already exists create a new record.
        l_gvev_rec.chr_id          := p_program_id;
        l_gvev_rec.dnz_chr_id      := p_program_id;
        l_gvev_rec.chr_id_referred := p_parent_agreement_id;
        l_gvev_rec.copied_only_yn  := 'N';
        OKC_CONTRACT_PUB.create_governance( p_api_version => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        p_gvev_rec => l_gvev_rec,
                                        x_gvev_rec => x_gvev_rec );
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          NULL;
        ELSE
          IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;
    ELSE
      IF (l_gov_id is not null) THEN
      -- Governances exists and since the Parent Agreement is NULL
      -- delete the governances record for this agreement.
        l_gvev_rec.id              := l_gov_id;
        OKC_CONTRACT_PUB.delete_governance( p_api_version => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        p_gvev_rec => l_gvev_rec);
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          NULL;
        ELSE
          IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;
    END IF;
  /* Manu Bug #4671978 27-Oct-2005 End */


  IF (((p_hdr_rec.p_workflow_process) <> OKL_API.G_MISS_NUM) AND ((p_hdr_rec.p_workflow_process) IS NOT NULL)) THEN

    -- update the okc_processes_v with the new values
    OPEN cur_k_process_id(p_program_id);
    FETCH cur_k_process_id INTO l_process_id;

    IF(cur_k_process_id%FOUND) THEN
      cpsv_rec_type3.id :=l_process_id;
      close cur_k_process_id;
      cpsv_rec_type3.chr_id  :=p_program_id;
      cpsv_rec_type3.pdf_id  :=p_hdr_rec.p_workflow_process;

      okc_contract_pub.update_contract_process(
      p_api_version     	=> l_api_version,
      x_return_status	=> l_return_status,
      p_init_msg_list     => OKL_API.G_FALSE,
      x_msg_count		=> l_msg_count,
      x_msg_data		=> l_msg_data,
      p_cpsv_rec          => cpsv_rec_type3,
      x_cpsv_rec          => cpsv_rec_type4);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        NULL;
      ELSE
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    ELSE

      -- create a record in the okc_k_process
      cpsv_rec_type3.chr_id  :=p_program_id;
      cpsv_rec_type3.pdf_id  :=p_hdr_rec.p_workflow_process;

      okc_contract_pub.create_contract_process(
      p_api_version     =>  l_api_version,
      p_init_msg_list   => OKL_API.G_FALSE,
      x_return_status   => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_cpsv_rec         => cpsv_rec_type3,
      x_cpsv_rec        => cpsv_rec_type4);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        NULL;
      ELSE
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF;    -- cursor cur_k_process end if

  ELSE  -- this else for workflow process null checking
    NULL;
  END IF;

ELSE

  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

END IF;

-- Murthy
OPEN cur_k_party_roles(p_program_id);
FETCH cur_k_party_roles INTO l_party_id;
IF (cur_k_party_roles%NOTFOUND) THEN
  CLOSE cur_k_party_roles;
  -- Murthy Set message to be registered
  OKL_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_JTOT_CODE_NOT_FOUND'
                      );
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
CLOSE cur_k_party_roles;

l1_cplv_rec.id := l_party_id;
IF (p_hdr_rec.p_object1_id1 IS NULL OR p_hdr_rec.p_object1_id1 = OKL_API.G_MISS_CHAR) OR
     (p_hdr_rec.p_object1_id2 IS NULL OR p_hdr_rec.p_object1_id2 = OKL_API.G_MISS_CHAR) THEN
  NULL;
ELSE
  l1_cplv_rec.object1_id1 := p_hdr_rec.p_object1_id1;
  l1_cplv_rec.object1_id2 := p_hdr_rec.p_object1_id2;
END IF;
l1_cplv_rec.cognomen:= null;
l1_cplv_rec.alias:= null;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2


     OPEN role_csr(l1_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S')  THEN

        okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                       p_init_msg_list  => OKC_API.G_FALSE,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count	   => x_msg_count,
                                                       x_msg_data	   => x_msg_data,
                                                       p_object_name    => l1_cplv_rec.jtot_object1_code,
                                                       p_id1            => l1_cplv_rec.object1_id1,
                                                       p_id2            => l1_cplv_rec.object1_id2);
	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

    END IF;


----  Changes End


OKC_CONTRACT_PARTY_PUB.update_k_party_role(p_api_version => p_api_version,
                                           p_init_msg_list => OKL_API.G_FALSE,
                                           x_return_status => l_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => x_msg_data,
                                           p_cplv_rec => l1_cplv_rec,
                                           x_cplv_rec => l2_cplv_rec
                                          );

IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

--Added by abhsxen for bug 6487870
   l_kplv_rec.ID := l2_cplv_rec.ID;

   OKL_KPL_PVT.update_row(
       p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_kplv_rec        => l_kplv_rec,
       x_kplv_rec        => x_kplv_rec);

   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
 --end abhsxen

OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    );

EXCEPTION

WHEN OKL_API.G_EXCEPTION_ERROR THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS
                     (p_api_name  => l_api_name
                      ,p_pkg_name  => G_PKG_NAME
                      ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                      ,x_msg_count => x_msg_count
                      ,x_msg_data  => x_msg_data
                      ,p_api_type  => '_PVT'
                      );

WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                     ,g_pkg_name
                     ,'OKL_API.G_RET_STS_ERROR'
                     ,x_msg_count
                     ,x_msg_data
                     ,'_PVT'
                     );

WHEN OTHERS THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                     ,g_pkg_name
                     ,'OTHERS'
                     ,x_msg_count
                     ,x_msg_data
                     ,'_PVT'
                     );

-- end of update_agreement
END;


-- Function to check if a workflow is active for a contract
-- Function Name: Is_Process_Active
-- An item is considered active if its end_date is NULL

FUNCTION Is_Process_Active(p_chr_id IN okl_k_headers_full_v.id%TYPE) RETURN VARCHAR2 IS

l_wf_name       OKC_PROCESS_DEFS_B.WF_NAME%TYPE;
l_item_key	OKC_K_PROCESSES.PROCESS_ID%TYPE;
l_return_code	VARCHAR2(1) := 'N';
l_end_date	DATE;

-- cursor for item type and item key
CURSOR l_pdfv_csr Is
SELECT pdfv.wf_name, cpsv.process_id
FROM okc_process_defs_b pdfv,
okc_k_processes cpsv
WHERE pdfv.id = cpsv.pdf_id
AND cpsv.chr_id = p_chr_id;

-- cursor to check active process
Cursor l_wfitems_csr IS
SELECT end_date
FROM wf_items
WHERE item_type = l_wf_name
AND item_key = l_item_key;

BEGIN

-- get item type and item key
OPEN l_pdfv_csr;
FETCH l_pdfv_csr into l_wf_name, l_item_key;
IF (l_pdfv_csr%NOTFOUND OR l_wf_name IS NULL OR l_item_key IS NULL) THEN
  CLOSE l_pdfv_csr;
  RETURN l_return_code;
END IF;
CLOSE l_pdfv_csr;

-- check whether process is active or not
OPEN l_wfitems_csr;
FETCH l_wfitems_csr into l_end_date;
IF (l_wfitems_csr%NOTFOUND or l_end_date IS NOT NULL) THEN
  l_return_code := 'N';
ELSE
  l_return_code := 'Y';
END IF;
CLOSE l_wfitems_csr;

RETURN l_return_code;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN (l_return_code);

END Is_Process_Active;


-- Procedure to change the status of the a given agreement
-- from the status PASSED to INCOMPLETE.
-- Procedure Name: passed_to_incomplete
-- Date Created  : 29-June-2005
-- Ignores if the status of the given agreement(contract) is in any other statys
-- other than status PASSED.

PROCEDURE passed_to_incomplete(p_api_version             IN               NUMBER,
                               p_init_msg_list           IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                               x_return_status           OUT              NOCOPY VARCHAR2,
                               x_msg_count               OUT              NOCOPY NUMBER,
                               x_msg_data                OUT              NOCOPY VARCHAR2,
                               p_program_id              IN               OKC_K_HEADERS_V.ID%TYPE) IS

l_sts_code       OKC_K_HEADERS_V.STS_CODE%TYPE := NULL;
l_cr_id          OKL_VP_CHANGE_REQUESTS.ID%TYPE := NULL;
l_cr_ret_sts_code okl_vp_change_requests.status_code%TYPE := NULL;
l_cr_status_code okl_vp_change_requests.status_code%TYPE := NULL;
l_cr_type        okl_vp_change_requests.change_type_code%TYPE := NULL;
l_incomplete_status_code OKC_K_HEADERS_V.STS_CODE%TYPE := 'INCOMPLETE';

l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'passed_to_incomplete';

-- cursor to get contract status
CURSOR l_sts_code_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) is
SELECT sts_code
FROM okc_k_headers_v
WHERE id = p_chr_id;

-- cursor to get the corresponding Change Request record
CURSOR l_cr_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) is
SELECT id, status_code, change_type_code
FROM OKL_VP_CHANGE_REQUESTS
WHERE id = (SELECT crs_id FROM okl_k_headers WHERE id = p_chr_id);

BEGIN

l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                             ,p_init_msg_list => p_init_msg_list
                                             ,p_api_type      => '_PVT'
                                             ,x_return_status => x_return_status
                                             );

IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;

--
IF (p_program_id <> OKL_API.G_MISS_NUM OR p_program_id IS NOT NULL) THEN
  -- Get the agreement Status
  OPEN l_sts_code_csr(p_chr_id => p_program_id);
  FETCH l_sts_code_csr INTO l_sts_code;
--  IF (l_sts_code_csr%NOTFOUND OR l_sts_code IS NULL) THEN
--    CLOSE l_sts_code_csr;
--  END IF;
  CLOSE l_sts_code_csr;

  -- Check if the given Change Request is of Association type of CR
  OPEN l_cr_csr(p_chr_id => p_program_id);
  FETCH l_cr_csr INTO l_cr_id, l_cr_status_code, l_cr_type;
  CLOSE l_cr_csr;

END IF;

IF (l_sts_code = 'PASSED') THEN
      okl_contract_status_pub.update_contract_status(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_khr_status    => l_incomplete_status_code
                                                    ,p_chr_id        => p_program_id
                                                     );
  IF (l_cr_type = 'AGREEMENT' AND l_cr_id IS NOT NULL) THEN
    -- If the Change Request is of type AGREEMENT.
    okl_vp_change_request_pvt.cascade_request_status_edit(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_vp_crq_id     => l_cr_id
                                                    ,x_status_code   => l_cr_ret_sts_code
                                                     );
  END IF;
ELSIF (l_sts_code = 'ACTIVE') THEN
  -- If the Change Request is of type ASSOCIATION.
  IF (l_cr_type = 'ASSOCIATION' AND l_cr_status_code = 'PASSED'
      AND l_cr_id IS NOT NULL) THEN
    okl_vp_change_request_pvt.cascade_request_status_edit(p_api_version   => p_api_version
                                                    ,p_init_msg_list => p_init_msg_list
                                                    ,x_return_status => x_return_status
                                                    ,x_msg_count     => x_msg_count
                                                    ,x_msg_data      => x_msg_data
                                                    ,p_vp_crq_id     => l_cr_id
                                                    ,x_status_code   => l_cr_ret_sts_code
                                                     );
  END IF;
END IF;

IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

    -- Call end_activity
    OKC_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );


EXCEPTION

WHEN OKL_API.G_EXCEPTION_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
                             );

WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           l_api_name
                           ,g_pkg_name
                           ,'OKL_API.G_RET_STS_ERROR'
                           ,x_msg_count
                           ,x_msg_data
                           ,'_PVT'
                           );

WHEN OTHERS THEN
x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           l_api_name
                           ,g_pkg_name
                           ,'OTHERS'
                           ,x_msg_count
                           ,x_msg_data
                           ,'_PVT'
                           );

END passed_to_incomplete;


END;

/

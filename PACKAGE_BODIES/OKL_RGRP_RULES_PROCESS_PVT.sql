--------------------------------------------------------
--  DDL for Package Body OKL_RGRP_RULES_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RGRP_RULES_PROCESS_PVT" as
/* $Header: OKLRRGRB.pls 120.14.12010000.4 2009/08/25 18:41:43 sechawla ship $ */

--G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
--G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_PROCESSING    exception;
G_EXCEPTION_STOP_VALIDATION    exception;


G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_RGRP_RULES_PROCESS_PVT';
G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';

/*
 * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
 */
G_WF_EVT_CONTRACT_TERM_UPDATED CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.asset_filing_terms_updated';
G_WF_EVT_ASSET_FILING_UPDATED  CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.asset_filing_updated';
G_WF_EVT_ASSET_PROPTAX_UPDATED CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.asset_property_tax_updated';
G_WF_EVT_SERV_PASS_UPDATED     CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.service_fee_passthrough_updated';
G_WF_EVT_FEE_PASS_UPDATED      CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.fee_passthrough_updated';
G_WF_EVT_SERV_FEXP_UPDATED     CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.service_fee_expense_updated';
G_WF_EVT_FEE_EXP_UPDATED       CONSTANT VARCHAR2(70):= 'oracle.apps.okl.la.lease_contract.fee_expense_updated';

G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)        := 'CONTRACT_ID';
G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30)           := 'ASSET_ID';
G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)   := 'CONTRACT_PROCESS';
G_WF_ITM_TERMS_ID CONSTANT VARCHAR2(30)           := 'TERMS_ID';
G_WF_ITM_SERV_LINE_ID CONSTANT VARCHAR2(30)       := 'SERVICE_LINE_ID';
G_WF_ITM_SERV_CHR_ID  CONSTANT VARCHAR2(30)       := 'SERVICE_CONTRACT_ID';
G_WF_ITM_SERV_CLE_ID  CONSTANT VARCHAR2(30)       := 'SERVICE_CONTRACT_LINE_ID';
G_WF_ITM_FEE_LINE_ID  CONSTANT VARCHAR2(30)       := 'FEE_LINE_ID';
/*
 * sjalasut: aug 18, 04 added constants used in raising business event. END
 */
-------------------------------------------------------------------------------
-- PROCEDURE raise_business_event
-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : This procedure is a wrapper that raises a business event
--                 : when ever
--                   a. Asset Tax, Property Tax is created, updated
--                   b. Filing for Liens,Tile and Registration is created
--                      or updated at terms and conditions level
--                   c. Service Expense and Passthrough are created, updated.
-- Business Rules  :
-- Parameters      : p_chr_id,p_asset_id, p_event_name along with other api params
-- Version         : 1.0
-- History         : 30-AUG-2004 SJALASUT created
-- End of comments

PROCEDURE raise_business_event(p_api_version IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2,
                               p_event_name IN VARCHAR2,
                               p_event_param_list IN WF_PARAMETER_LIST_T
                               ) IS
  l_contract_process VARCHAR2(20);
  l_event_param_list WF_PARAMETER_LIST_T := p_event_param_list;
BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- wrapper API to get contract process. this API determines in which status the
  -- contract in question is.
  l_contract_process := okl_lla_util_pvt.get_contract_process(
                                          p_chr_id => wf_event.GetValueForParameter(G_WF_ITM_CONTRACT_ID, l_event_param_list)
                                         );
  -- add the contract status to the event parameter list
  wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS, l_contract_process, l_event_param_list);

  OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_event_name     => p_event_name,
                         p_parameters     => l_event_param_list);
EXCEPTION
  WHEN OTHERS THEN
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END raise_business_event;


PROCEDURE migrate_rec(
       p_rgr_rec                      IN  rgr_rec_type,
       x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS
BEGIN
    x_rulv_rec.id           := p_rgr_rec.rule_id;
    x_rulv_rec.object_version_number := p_rgr_rec.object_version_number;
    x_rulv_rec.sfwt_flag        := p_rgr_rec.sfwt_flag;
    x_rulv_rec.object1_id1      := p_rgr_rec.object1_id1;
    x_rulv_rec.object2_id1      := p_rgr_rec.object2_id1;
    x_rulv_rec.object3_id1      := p_rgr_rec.object3_id1;
    x_rulv_rec.object1_id2      := p_rgr_rec.object1_id2;
    x_rulv_rec.object2_id2      := p_rgr_rec.object2_id2;
    x_rulv_rec.object3_id2      := p_rgr_rec.object3_id2;
    x_rulv_rec.jtot_object1_code    := p_rgr_rec.jtot_object1_code;
    x_rulv_rec.jtot_object2_code    := p_rgr_rec.jtot_object2_code;
    x_rulv_rec.jtot_object3_code    := p_rgr_rec.jtot_object3_code;
    x_rulv_rec.dnz_chr_id       := p_rgr_rec.dnz_chr_id;
    x_rulv_rec.rgp_id           := p_rgr_rec.rgp_id;
    x_rulv_rec.priority         := p_rgr_rec.priority;
    x_rulv_rec.std_template_yn  := p_rgr_rec.std_template_yn;
    x_rulv_rec.comments         := p_rgr_rec.comments;
    x_rulv_rec.warn_yn          := p_rgr_rec.warn_yn;
    x_rulv_rec.attribute_category   := p_rgr_rec.attribute_category;
    x_rulv_rec.attribute1       := p_rgr_rec.attribute1;
    x_rulv_rec.attribute2       := p_rgr_rec.attribute2;
    x_rulv_rec.attribute3       := p_rgr_rec.attribute3;
    x_rulv_rec.attribute4       := p_rgr_rec.attribute4;
    x_rulv_rec.attribute5       := p_rgr_rec.attribute5;
    x_rulv_rec.attribute6       := p_rgr_rec.attribute6;
    x_rulv_rec.attribute7       := p_rgr_rec.attribute7;
    x_rulv_rec.attribute8       := p_rgr_rec.attribute8;
    x_rulv_rec.attribute9       := p_rgr_rec.attribute9;
    x_rulv_rec.attribute10      := p_rgr_rec.attribute10;
    x_rulv_rec.attribute11      := p_rgr_rec.attribute11;
    x_rulv_rec.attribute12      := p_rgr_rec.attribute12;
    x_rulv_rec.attribute13      := p_rgr_rec.attribute13;
    x_rulv_rec.attribute14      := p_rgr_rec.attribute14;
    x_rulv_rec.attribute15      := p_rgr_rec.attribute15;
--text                           OKC_RULES_V.TEXT%TYPE := NULL,
    x_rulv_rec.created_by       := p_rgr_rec.created_by;
    x_rulv_rec.creation_date    := p_rgr_rec.creation_date;
    x_rulv_rec.last_updated_by      := p_rgr_rec.last_updated_by;
    x_rulv_rec.last_update_date     := p_rgr_rec.last_update_date;
    x_rulv_rec.last_update_login    := p_rgr_rec.last_update_login;
    x_rulv_rec.rule_information_category := p_rgr_rec.rule_information_category;
    x_rulv_rec.rule_information1    := p_rgr_rec.rule_information1;
    x_rulv_rec.rule_information2    := p_rgr_rec.rule_information2;
    x_rulv_rec.rule_information3    := p_rgr_rec.rule_information3;
    x_rulv_rec.rule_information4    := p_rgr_rec.rule_information4;
    x_rulv_rec.rule_information5    := p_rgr_rec.rule_information5;
    x_rulv_rec.rule_information6    := p_rgr_rec.rule_information6;
    x_rulv_rec.rule_information7    := p_rgr_rec.rule_information7;
    x_rulv_rec.rule_information8    := p_rgr_rec.rule_information8;
    x_rulv_rec.rule_information9    := p_rgr_rec.rule_information9;
    x_rulv_rec.rule_information10   := p_rgr_rec.rule_information10;
    x_rulv_rec.rule_information11   := p_rgr_rec.rule_information11;
    x_rulv_rec.rule_information12   := p_rgr_rec.rule_information12;
    x_rulv_rec.rule_information13   := p_rgr_rec.rule_information13;
    x_rulv_rec.rule_information14   := p_rgr_rec.rule_information14;
    x_rulv_rec.rule_information15   := p_rgr_rec.rule_information15;
    x_rulv_rec.template_yn               := NVL(p_rgr_rec.template_yn,'N');
    x_rulv_rec.ans_set_jtot_object_code  := NVL(p_rgr_rec.ans_set_jtot_object_code,'');
    x_rulv_rec.ans_set_jtot_object_id1   := NVL(p_rgr_rec.ans_set_jtot_object_id1,'');
    x_rulv_rec.ans_set_jtot_object_id2   := NVL(p_rgr_rec.ans_set_jtot_object_id2,'');
    x_rulv_rec.display_sequence          := NVL(p_rgr_rec.display_sequence,'');
end migrate_rec;
PROCEDURE update_rule_rec(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_rgr_rec                      IN  rgr_rec_type) IS
l_rgr_rec   rgr_rec_type := p_rgr_rec;
l_rulv_rec  rulv_rec_type;
lx_rulv_rec rulv_rec_type;

--l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS_PVT';
l_proc_name   VARCHAR2(35)    := 'UPDATE_RULE_REC';
l_api_version CONSTANT VARCHAR2(30) := p_api_version;

BEGIN
     migrate_rec(p_rgr_rec    => p_rgr_rec,
                 x_rulv_rec   => l_rulv_rec);

     OKL_RULE_PUB.update_rule(
          p_api_version     => l_api_version,
          p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_rulv_rec            => l_rulv_rec,
          x_rulv_rec            => lx_rulv_rec);

IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      /*
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);
                           */

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END update_rule_rec;

FUNCTION get_header_rule_group_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgr_rec                      IN  rgr_rec_type)
    RETURN OKC_RULE_GROUPS_B.ID%TYPE IS
    i NUMBER := 0;
    j NUMBER;
    rule_group_id NUMBER := null;
    l_rgr_rec   rgr_rec_type := p_rgr_rec;
    cursor RULE_GROUP_CSR(P_CHR_ID IN NUMBER, P_RGD_CODE IN VARCHAR2) is
    SELECT ID FROM OKC_RULE_GROUPS_B
    WHERE  CHR_ID     = P_CHR_ID AND
           DNZ_CHR_ID = P_CHR_ID AND
           CLE_ID     IS NULL    AND
           RGD_CODE   = P_RGD_CODE;
    BEGIN
        open  RULE_GROUP_CSR(p_chr_id,p_rgr_rec.rgd_code);
        fetch RULE_GROUP_CSR into rule_group_id;
        if(RULE_GROUP_CSR%NOTFOUND) then
            close RULE_GROUP_CSR;
            x_return_status := OKC_API.G_RET_STS_ERROR;
            -- halt further validation of this column
        else
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
    end if;
    return rule_group_id;
END get_header_rule_group_id;
FUNCTION get_header_rule_group_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgd_code                     IN  VARCHAR2)
    RETURN OKC_RULE_GROUPS_B.ID%TYPE IS
    rule_group_id NUMBER := null;
    cursor RULE_GROUP_CSR(P_CHR_ID IN NUMBER, P_RGD_CODE IN VARCHAR2) is
    SELECT ID FROM OKC_RULE_GROUPS_B
    WHERE  CHR_ID     = P_CHR_ID AND
           DNZ_CHR_ID = P_CHR_ID AND
           CLE_ID     IS NULL    AND
           RGD_CODE   = P_RGD_CODE;
    BEGIN
        open  RULE_GROUP_CSR(p_chr_id,p_rgd_code);
        fetch RULE_GROUP_CSR into rule_group_id;
        if(RULE_GROUP_CSR%NOTFOUND) then
            close RULE_GROUP_CSR;
--          x_return_status := OKC_API.G_RET_STS_ERROR;
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            -- halt further validation of this column
        else
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
    end if;
    return rule_group_id;
END get_header_rule_group_id;
FUNCTION get_line_rule_group_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_rgr_rec                      IN  rgr_rec_type)
    RETURN OKC_RULE_GROUPS_B.ID%TYPE IS
    i NUMBER := 0;
    j NUMBER;
    rule_group_id NUMBER := null;
    l_rgr_rec   rgr_rec_type := p_rgr_rec;
    cursor RULE_GROUP_CSR(P_CHR_ID IN NUMBER, P_LINE_ID IN NUMBER,
                          P_RGD_CODE IN VARCHAR2) is
    SELECT ID FROM OKC_RULE_GROUPS_B
    WHERE  CHR_ID     IS NULL     AND
           DNZ_CHR_ID = P_CHR_ID  AND
           CLE_ID     = P_LINE_ID AND
           RGD_CODE   = P_RGD_CODE;
    BEGIN
        open RULE_GROUP_CSR(p_chr_id,p_line_id,p_rgr_rec.rgd_code);
        fetch RULE_GROUP_CSR into rule_group_id;
        if(RULE_GROUP_CSR%NOTFOUND) then
            close RULE_GROUP_CSR;
--          x_return_status := OKC_API.G_RET_STS_ERROR;
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
        else
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
        end if;
    return rule_group_id;
END get_line_rule_group_id;
FUNCTION get_rule_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgr_rec                      IN  rgr_rec_type)
    RETURN OKC_RULES_V.ID%TYPE IS
    i NUMBER := 0;
    j NUMBER;
    rule_id NUMBER := null;
    l_rgr_rec   rgr_rec_type := p_rgr_rec;
    cursor RULE_CSR(P_CHR_ID IN NUMBER, P_RGP_ID IN NUMBER,
                    P_RULE_CODE IN VARCHAR2) is
    SELECT ID FROM OKC_RULES_V
    WHERE  DNZ_CHR_ID = P_CHR_ID AND
           RGP_ID     = P_RGP_ID AND
           RULE_INFORMATION_CATEGORY   = P_RULE_CODE;
    BEGIN
        open  RULE_CSR(p_chr_id, p_rgr_rec.rgp_id,
                       p_rgr_rec.rule_information_category);
        fetch RULE_CSR into rule_id;
        if(RULE_CSR%NOTFOUND) then
            close RULE_CSR;
--          x_return_status := OKC_API.G_RET_STS_ERROR;
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            -- halt further validation of this column
        else
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
    end if;
    return rule_id;
END get_rule_id;
PROCEDURE create_hdr_rule_group_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rule_group_id                IN NUMBER,
    px_rgr_rec                     IN OUT NOCOPY  rgr_rec_type) IS
    i NUMBER := 0;
    j NUMBER;
--    rule_group_id NUMBER := null;
--    rgs_code      VARCHAR(30);
    l_rgr_rec   rgr_rec_type := px_rgr_rec;
    l_rgpv_rec   rgpv_rec_type;
    lx_rgpv_rec  rgpv_rec_type;
    l_rulv_rec  rulv_rec_type;
    lx_rulv_rec  rulv_rec_type;

    --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS_PVT';
    l_proc_name   VARCHAR2(35)    := 'CREATE_HDR_RULE_GROUP_RULES';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;

--avsingh
    Cursor l_lock_hdr_csr(ChrId IN NUMBER) is
    Select chr.id,
           chr.last_update_date
    from   okc_k_headers_b chr
    where  chr.id = ChrId
    for    update of chr.last_update_date nowait;

    l_chr_id number;
    l_update_date date;
--avsingh


    BEGIN

        --l_rgr_rec   := px_rgr_rec;
    if(p_rule_group_id is null or p_rule_group_id = OKC_API.G_MISS_NUM) then
       l_rgpv_rec.rgd_code      :=  l_rgr_rec.rgd_code;
       l_rgpv_rec.chr_id        :=  p_chr_id;
       l_rgpv_rec.dnz_chr_id    :=  p_chr_id;
       l_rgpv_rec.cle_id        :=  null;
       l_rgpv_rec.dnz_chr_id    :=  p_chr_id;
       l_rgpv_rec.object_version_number :=  l_rgr_rec.object_version_number;
--     l_rgpv_rec.object_version_number :=  1;
       l_rgpv_rec.rgp_type      :=  'KRG';
--     l_rgpv_rec.created_by    :=  l_rgr_rec.created_by;
--     l_rgpv_rec.creation_date :=  l_rgr_rec.creation_date;
--     l_rgpv_rec.last_updated_by   :=  l_rgr_rec.last_updated_by;
--     l_rgpv_rec.last_update_date  :=  l_rgr_rec.last_update_date;
--     l_rgpv_rec.last_update_login :=  l_rgr_rec.last_update_login;


    Open l_lock_hdr_csr(p_chr_id);
    Fetch l_lock_hdr_csr into l_chr_id, l_update_date;


       OKL_RULE_PUB.create_rule_group(
       p_api_version                =>  p_api_version,
       p_init_msg_list              =>  p_init_msg_list,
       x_return_status              =>  x_return_status,
       x_msg_count                  =>  x_msg_count,
       x_msg_data                   =>  x_msg_data,
       p_rgpv_rec                   =>  l_rgpv_rec,
       x_rgpv_rec                   =>  lx_rgpv_rec);
       px_rgr_rec.rgp_id    := lx_rgpv_rec.id;
       px_rgr_rec.dnz_chr_id := p_chr_id;


        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


       /*
       px_rgr_rec.id         := get_rule_id(
                                p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_chr_id         => p_chr_id,
                                p_rgr_rec        => px_rgr_rec);
                                */
           -- create all rules under this rule group
        l_rulv_rec.object_version_number := l_rgr_rec.object_version_number;
        l_rulv_rec.sfwt_flag         := l_rgr_rec.sfwt_flag;
        l_rulv_rec.dnz_chr_id        := p_chr_id;
        l_rulv_rec.rgp_id        := lx_rgpv_rec.id;
        l_rulv_rec.std_template_yn   := l_rgr_rec.std_template_yn;
        l_rulv_rec.warn_yn       := l_rgr_rec.warn_yn;
        l_rulv_rec.template_yn   := l_rgr_rec.template_yn;
--      l_rulv_rec.created_by        := 0;
--      l_rulv_rec.created_by        := l_rgr_rec.created_by;      --req
--      l_rulv_rec.creation_date     := l_rgr_rec.creation_date;
--      l_rulv_rec.last_updated_by   := l_rgr_rec.last_updated_by;
--      l_rulv_rec.last_update_date  := l_rgr_rec.last_update_date;
--      l_rulv_rec.last_update_login     := l_rgr_rec.last_update_login;
        l_rulv_rec.rule_information_category := l_rgr_rec.rule_information_category;



        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    close l_lock_hdr_csr;
    else
      px_rgr_rec.rgp_id     := p_rule_group_id;
    end if;
--    px_rgr_rec.dnz_chr_id := p_chr_id;
      px_rgr_rec.rule_id         :=     get_rule_id(
                                   p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_chr_id         => p_chr_id,
                                   p_rgr_rec        => px_rgr_rec);
       if(px_rgr_rec.rule_id is null or px_rgr_rec.rule_id = OKC_API.G_MISS_NUM) then
        l_rulv_rec.object_version_number := l_rgr_rec.object_version_number;
        l_rulv_rec.sfwt_flag         := l_rgr_rec.sfwt_flag;
        l_rulv_rec.dnz_chr_id        := p_chr_id;
        l_rulv_rec.rgp_id        := px_rgr_rec.rgp_id;
        l_rulv_rec.std_template_yn   := l_rgr_rec.std_template_yn;
        l_rulv_rec.warn_yn       := l_rgr_rec.warn_yn;
        l_rulv_rec.template_yn   := l_rgr_rec.template_yn;
--      l_rulv_rec.created_by        := 0;
--      l_rulv_rec.created_by        := l_rgr_rec.created_by;      --req
--      l_rulv_rec.creation_date     := l_rgr_rec.creation_date;
--      l_rulv_rec.last_updated_by   := l_rgr_rec.last_updated_by;
--      l_rulv_rec.last_update_date  := l_rgr_rec.last_update_date;
--      l_rulv_rec.last_update_login     := l_rgr_rec.last_update_login;
        l_rulv_rec.rule_information_category := l_rgr_rec.rule_information_category;
        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

       px_rgr_rec.rule_id := lx_rulv_rec.id;

    end if;


  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
        If l_lock_hdr_csr%ISOPEN then
            close l_lock_hdr_csr;
        End If;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
        If l_lock_hdr_csr%ISOPEN then
            close l_lock_hdr_csr;
        End If;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
        If l_lock_hdr_csr%ISOPEN then
            close l_lock_hdr_csr;
        End If;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END create_hdr_rule_group_rules;

PROCEDURE create_line_rule_group_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_rule_group_id                IN  NUMBER,
    px_rgr_rec                     IN OUT NOCOPY  rgr_rec_type) IS
    i NUMBER := 0;
    j NUMBER;
--    rule_group_id NUMBER := null;
--    rgs_code      VARCHAR(30);
    l_rgr_rec   rgr_rec_type := px_rgr_rec;
    l_rgpv_rec   rgpv_rec_type;
    lx_rgpv_rec  rgpv_rec_type;
    l_rulv_rec  rulv_rec_type;
    lx_rulv_rec  rulv_rec_type;

    --avsingh
    Cursor l_lock_cle_csr(CleId IN NUMBER) is
    Select cle.id,
           cle.last_update_date
    from   okc_k_lines_b cle
    where  cle.id = CleId
    for    update of cle.last_update_date nowait;

    l_cle_id number;
    l_update_date date;
    --avsingh

    BEGIN
        --l_rgr_rec   := px_rgr_rec;
    if(p_rule_group_id is null or p_rule_group_id = OKC_API.G_MISS_NUM) then
       l_rgpv_rec.rgd_code      :=  l_rgr_rec.rgd_code;
       l_rgpv_rec.chr_id        :=  null;
       l_rgpv_rec.dnz_chr_id    :=  p_chr_id;
       l_rgpv_rec.cle_id        :=  p_line_id;
       l_rgpv_rec.dnz_chr_id    :=  p_chr_id;
       l_rgpv_rec.object_version_number :=  l_rgr_rec.object_version_number;
--     l_rgpv_rec.object_version_number :=  1;
       l_rgpv_rec.rgp_type      :=  'KRG';
--     l_rgpv_rec.created_by    :=  l_rgr_rec.created_by;
--     l_rgpv_rec.creation_date :=  l_rgr_rec.creation_date;
--     l_rgpv_rec.last_updated_by   :=  l_rgr_rec.last_updated_by;
--     l_rgpv_rec.last_update_date  :=  l_rgr_rec.last_update_date;
--     l_rgpv_rec.last_update_login :=  l_rgr_rec.last_update_login;

    Open l_lock_cle_csr(p_line_id);
    Fetch l_lock_cle_csr into l_cle_id, l_update_date;

       OKL_RULE_PUB.create_rule_group(
       p_api_version                =>  p_api_version,
       p_init_msg_list              =>  p_init_msg_list,
       x_return_status              =>  x_return_status,
       x_msg_count                  =>  x_msg_count,
       x_msg_data                   =>  x_msg_data,
       p_rgpv_rec                   =>  l_rgpv_rec,
       x_rgpv_rec                   =>  lx_rgpv_rec);


      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

       px_rgr_rec.rgp_id    := lx_rgpv_rec.id;
       px_rgr_rec.dnz_chr_id := p_chr_id;
       /*
       px_rgr_rec.id         := get_rule_id(
                                p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_chr_id         => p_chr_id,
                                p_rgr_rec        => px_rgr_rec);
                                */
           -- create all rules under this rule group
        l_rulv_rec.object_version_number := l_rgr_rec.object_version_number;
        l_rulv_rec.sfwt_flag         := l_rgr_rec.sfwt_flag;
        l_rulv_rec.dnz_chr_id        := p_chr_id;
        l_rulv_rec.rgp_id        := lx_rgpv_rec.id;
        l_rulv_rec.std_template_yn   := l_rgr_rec.std_template_yn;
        l_rulv_rec.warn_yn       := l_rgr_rec.warn_yn;
        l_rulv_rec.template_yn   := l_rgr_rec.template_yn;
--      l_rulv_rec.created_by        := 0;
--      l_rulv_rec.created_by        := l_rgr_rec.created_by;      --req
--      l_rulv_rec.creation_date     := l_rgr_rec.creation_date;
--      l_rulv_rec.last_updated_by   := l_rgr_rec.last_updated_by;
--      l_rulv_rec.last_update_date  := l_rgr_rec.last_update_date;
--      l_rulv_rec.last_update_login     := l_rgr_rec.last_update_login;
        l_rulv_rec.rule_information_category := l_rgr_rec.rule_information_category;
        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    close l_lock_cle_csr;
    else
      px_rgr_rec.rgp_id     := p_rule_group_id;
    end if;
--    px_rgr_rec.dnz_chr_id := p_chr_id;
      px_rgr_rec.rule_id         :=     get_rule_id(
                                   p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_chr_id         => p_chr_id,
                                   p_rgr_rec        => px_rgr_rec);
       if(px_rgr_rec.rule_id is null or px_rgr_rec.rule_id = OKC_API.G_MISS_NUM) then
        l_rulv_rec.object_version_number := l_rgr_rec.object_version_number;
        l_rulv_rec.sfwt_flag         := l_rgr_rec.sfwt_flag;
        l_rulv_rec.dnz_chr_id        := p_chr_id;
        l_rulv_rec.rgp_id        := px_rgr_rec.rgp_id;
        l_rulv_rec.std_template_yn   := l_rgr_rec.std_template_yn;
        l_rulv_rec.warn_yn       := l_rgr_rec.warn_yn;
        l_rulv_rec.template_yn   := l_rgr_rec.template_yn;
--      l_rulv_rec.created_by        := 0;
--      l_rulv_rec.created_by        := l_rgr_rec.created_by;      --req
--      l_rulv_rec.creation_date     := l_rgr_rec.creation_date;
--      l_rulv_rec.last_updated_by   := l_rgr_rec.last_updated_by;
--      l_rulv_rec.last_update_date  := l_rgr_rec.last_update_date;
--      l_rulv_rec.last_update_login     := l_rgr_rec.last_update_login;
        l_rulv_rec.rule_information_category := l_rgr_rec.rule_information_category;
        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      px_rgr_rec.rule_id := lx_rulv_rec.id;

    end if;

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
        If l_lock_cle_csr%ISOPEN then
            close l_lock_cle_csr;
        End If;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
       If l_lock_cle_csr%ISOPEN then
            close l_lock_cle_csr;
        End If;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
       If l_lock_cle_csr%ISOPEN then
            close l_lock_cle_csr;
        End If;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END create_line_rule_group_rules;

PROCEDURE process_hdr_rule_group_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgr_rec                      IN  rgr_rec_type) IS
    lx_rgr_rec   rgr_rec_type := p_rgr_rec;
    rule_group_id NUMBER := null;
    l_return_status VARCHAR2(1);

    CURSOR l_bill_to_csr IS
    SELECT term.printing_lead_days printing_lead_days,
           khr.cust_acct_id,
           khr.bill_to_site_use_id
    FROM   okc_k_headers_b khr
           ,hz_customer_profiles cp
           ,ra_terms term
    WHERE  khr.id = p_chr_id
    AND    khr.bill_to_site_use_id = cp.site_use_id
    AND    cp.standard_terms = term.term_id;

    l_bill_to_rec l_bill_to_csr%ROWTYPE;

    BEGIN

        if(lx_rgr_rec.rule_id is null or lx_rgr_rec.rule_id = OKC_API.G_MISS_NUM) then
                rule_group_id := get_header_rule_group_id(
                    p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    p_chr_id        => p_chr_id,
                    p_rgr_rec       => lx_rgr_rec);

                create_hdr_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => p_chr_id,
                     p_rule_group_id     => rule_group_id,
                     px_rgr_rec          => lx_rgr_rec);
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
        end if;

        --Bug#4542290
        IF (lx_rgr_rec.rgd_code = 'LABILL' AND lx_rgr_rec.RULE_INFORMATION_CATEGORY = 'LAINVD') THEN
          IF (lx_rgr_rec.RULE_INFORMATION3 IS NULL OR lx_rgr_rec.RULE_INFORMATION3 = OKC_API.G_MISS_CHAR) THEN
            --FETCH print lead days and update record.
            OPEN l_bill_to_csr;
            FETCH l_bill_to_csr INTO l_bill_to_rec;
            CLOSE l_bill_to_csr;
            lx_rgr_rec.RULE_INFORMATION3 := l_bill_to_rec.printing_lead_days;
          END IF;
        END IF;

        l_return_status := 'S';
        IF (lx_rgr_rec.rgd_code = 'LAHDTX' AND lx_rgr_rec.RULE_INFORMATION_CATEGORY = 'LASTCL') THEN
          okl_la_sales_tax_pvt.sync_contract_sales_tax(
                                         p_api_version => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => l_return_status,
                                         x_msg_count => x_msg_count,
                                         x_msg_data => x_msg_data,
                                         p_chr_id  => p_chr_id);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        update_rule_rec(
                  p_api_version       => p_api_version,
                  p_init_msg_list     => p_init_msg_list,
                  x_return_status     => x_return_status,
                  x_msg_count         => x_msg_count,
                  x_msg_data          => x_msg_data,
                  p_rgr_rec           => lx_rgr_rec);
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END process_hdr_rule_group_rules;
PROCEDURE process_line_rule_group_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_rgr_rec                      IN  rgr_rec_type) IS
    lx_rgr_rec   rgr_rec_type := p_rgr_rec;
    rule_group_id NUMBER := null;
    l_return_status VARCHAR2(1);
    BEGIN
        if(lx_rgr_rec.rule_id is null or lx_rgr_rec.rule_id = OKC_API.G_MISS_NUM) then
                rule_group_id := get_line_rule_group_id(
                    p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    p_chr_id        => p_chr_id,
                    p_line_id       => p_line_id,
                    p_rgr_rec       => lx_rgr_rec);
                create_line_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => p_chr_id,
                     p_line_id           => p_line_id,
                     p_rule_group_id     => rule_group_id,
                     px_rgr_rec          => lx_rgr_rec);

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

        end if;

        --Bug#4658944 ramurt
        IF (lx_rgr_rec.rgd_code = 'LAASTX' AND lx_rgr_rec.RULE_INFORMATION_CATEGORY = 'LAASTX') THEN
          OKL_LA_SALES_TAX_PVT.check_sales_tax_asset_rules(
                       p_api_version       => p_api_version,
                       p_init_msg_list     => p_init_msg_list,
                       x_return_status     => l_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data,
                       p_chr_id            => p_chr_id,
                       p_line_id           => p_line_id,
                       p_rule_group_id     => rule_group_id,
                       p_rgr_rec           => lx_rgr_rec);
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        update_rule_rec(
              p_api_version       => p_api_version,
              p_init_msg_list     => p_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_rgr_rec           => lx_rgr_rec);

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END process_line_rule_group_rules;

FUNCTION get_rg_party_roles_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_rgp_id                       IN  NUMBER,
    p_cpl_id                       IN  NUMBER,
    p_rrd_id                       IN  NUMBER)
    RETURN OKC_RG_PARTY_ROLES.ID%TYPE IS
--    rule_group_id NUMBER := null;
    rmp_id NUMBER := null;
--    l_rgr_rec   rgr_rec_type := p_rgr_rec;
    cursor RMP_CSR( P_CHR_ID IN NUMBER,P_RGP_ID IN NUMBER, P_CPL_ID IN NUMBER, P_RRD_ID IN NUMBER) is
    SELECT ID FROM OKC_RG_PARTY_ROLES
    WHERE  DNZ_CHR_ID = P_CHR_ID AND
           RGP_ID     = P_RGP_ID AND
           CPL_ID     = P_CPL_ID AND
           RRD_ID     = P_RRD_ID;
    BEGIN
        open  RMP_CSR(p_chr_id,p_rgp_id,p_cpl_id,p_rrd_id);
        fetch RMP_CSR into rmp_id;
        if(RMP_CSR%NOTFOUND) then
            close RMP_CSR;
--          x_return_status := OKC_API.G_RET_STS_ERROR;
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            -- halt further validation of this column
        else
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
    end if;
    return rmp_id;
END get_rg_party_roles_id;
FUNCTION get_rg_party_roles_rgp_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_cpl_id                       IN  NUMBER,
    p_rrd_id                       IN  NUMBER)
    RETURN OKC_RULE_GROUPS_V.ID%TYPE IS
--    rule_group_id NUMBER := null;
    rgp_id NUMBER := null;
--    l_rgr_rec   rgr_rec_type := p_rgr_rec;
    cursor RMP_CSR( P_CHR_ID IN NUMBER, P_CPL_ID IN NUMBER, P_RRD_ID IN NUMBER) is
    SELECT RGP_ID FROM OKC_RG_PARTY_ROLES
    WHERE  DNZ_CHR_ID = P_CHR_ID AND
           CPL_ID     = P_CPL_ID AND
           RRD_ID     = P_RRD_ID;
    BEGIN
        open  RMP_CSR(p_chr_id,p_cpl_id,p_rrd_id);
        fetch RMP_CSR into rgp_id;
        if(RMP_CSR%NOTFOUND) then
            close RMP_CSR;
--          x_return_status := OKC_API.G_RET_STS_ERROR;
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            -- halt further validation of this column
        else
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
    end if;
    return rgp_id;
END get_rg_party_roles_rgp_id;
PROCEDURE process_party_rule_group_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_cpl_id                       IN  NUMBER,
    p_rrd_id                       IN  NUMBER,
    p_rgr_rec                      IN  rgr_rec_type) IS
    lx_rgr_rec   rgr_rec_type := p_rgr_rec;
    l_rmpv_rec   rmpv_rec_type;
    lx_rmpv_rec  rmpv_rec_type;
    rmp_id OKC_RG_PARTY_ROLES.ID%TYPE := null;
    rule_group_id NUMBER := null;
    BEGIN
          rule_group_id := get_rg_party_roles_rgp_id(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_chr_id        => p_chr_id,
          p_line_id       => p_line_id,
          p_cpl_id        => p_cpl_id,
          p_rrd_id        => p_rrd_id);
          if(rule_group_id is null or rule_group_id = OKC_API.G_MISS_NUM) then
            create_hdr_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => p_chr_id,
                             p_rule_group_id     => null,
                         px_rgr_rec          => lx_rgr_rec);

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

        l_rmpv_rec.rgp_id     := lx_rgr_rec.rgp_id;
        l_rmpv_rec.rrd_id     := p_rrd_id;
        l_rmpv_rec.cpl_id     := p_cpl_id;
        l_rmpv_rec.dnz_chr_id := p_chr_id;
        OKL_RULE_PUB.create_rg_mode_pty_role(
              p_api_version     => p_api_version,
              p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rmpv_rec            => l_rmpv_rec,
              x_rmpv_rec            => lx_rmpv_rec);

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


    elsif(lx_rgr_rec.rule_id is null or lx_rgr_rec.rule_id = OKC_API.G_MISS_NUM) then
        rule_group_id := get_rg_party_roles_rgp_id(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                    p_chr_id        => p_chr_id,
                    p_line_id       => p_line_id,
                            p_cpl_id        => p_cpl_id,
                            p_rrd_id        => p_rrd_id);
                create_hdr_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => p_chr_id,
                         p_rule_group_id     => rule_group_id,
                 px_rgr_rec          => lx_rgr_rec);
                IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
        end if;
        update_rule_rec(
                  p_api_version       => p_api_version,
                  p_init_msg_list     => p_init_msg_list,
                  x_return_status     => x_return_status,
                  x_msg_count         => x_msg_count,
                  x_msg_data          => x_msg_data,
                  p_rgr_rec           => lx_rgr_rec);

                  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;
  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END process_party_rule_group_rules;

PROCEDURE process_template_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgr_rec                      IN  rgr_rec_type,
    px_rgr_rec             OUT NOCOPY rgr_out_rec_type) IS
    l_rgr_rec    rgr_rec_type := p_rgr_rec;
    l_rulv_rec   rulv_rec_type := null;
    lx_rulv_rec  rulv_rec_type := null;
    BEGIN
    if(l_rgr_rec.rule_id is null or l_rgr_rec.rule_id = OKC_API.G_MISS_NUM or l_rgr_rec.rule_id = '') then
         migrate_rec(p_rgr_rec    => p_rgr_rec,
                     x_rulv_rec   => l_rulv_rec);
         l_rulv_rec.dnz_chr_id  := null;
         l_rulv_rec.rgp_id      := null;
         l_rulv_rec.std_template_yn := 'Y';
         l_rulv_rec.template_yn := 'Y';
    OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

    px_rgr_rec.new_yn := 'Y';
    else
     --l_rgr_rec.dnz_chr_id  := null;
         --l_rgr_rec.rgp_id      := null;
         l_rgr_rec.template_yn := 'Y';
    l_rgr_rec.std_template_yn := 'Y';
         migrate_rec(p_rgr_rec    => p_rgr_rec,
                     x_rulv_rec   => l_rulv_rec);
    OKL_RULE_PUB.update_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

    px_rgr_rec.new_yn := 'N';
        end if;
        px_rgr_rec.id   := lx_rulv_rec.id;
        px_rgr_rec.rule_code := lx_rulv_rec.rule_information_category;
        px_rgr_rec.rgd_code := p_rgr_rec.rgd_code;


  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END process_template_rule;

PROCEDURE process_rule_group_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_cpl_id                       IN  NUMBER,
    p_rrd_id                       IN  NUMBER,
    p_rgr_tbl                      IN  rgr_tbl_type) IS
    l_rgr_tbl   rgr_tbl_type := p_rgr_tbl;
    i NUMBER := 0;
    process_type VARCHAR2(10) := null;
    l_chr_id  NUMBER := p_chr_id;
    l_line_id NUMBER := p_line_id;
    l_cpl_id  NUMBER := p_cpl_id;
    l_rrd_id  NUMBER := p_rrd_id;

    --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
    l_proc_name   VARCHAR2(35)    := 'PROCESS_RULE_GROUP_RULES';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;

    x_rulv_tbl APPS.OKL_RULE_PUB.RULV_TBL_TYPE;

    -- sjalasut: aug 30, 04 added variables to support business events. BEGIN

    l_raise_business_event VARCHAR2(1);
    l_business_event_name wf_events.name%TYPE;
    l_terms_id okc_rule_groups_b.id%TYPE;
    l_parameter_list WF_PARAMETER_LIST_T;
    -- cursor to get the rule group id from the header.
    -- if the Lien Terms and Conditions are updated at the contract level, then the cle_id is null
    CURSOR get_header_terms_id (p_chr_id okc_k_headers_b.id%TYPE, p_rgd_code VARCHAR2) IS
    SELECT id
      FROM okc_rule_groups_b
     WHERE dnz_chr_id = p_chr_id  AND
           rgd_code   = p_rgd_code AND
           cle_id IS NULL ;

    CURSOR get_line_style (p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT lty_code
      FROM okc_k_lines_b line,
           okc_line_styles_b style
     WHERE line.lse_id = style.id
       AND line.id = p_line_id;

    l_line_style okc_line_styles_b.lty_code%TYPE;

    CURSOR get_serv_chr_from_serv(p_chr_id okc_k_headers_b.id%TYPE,
                                  p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT rlobj.object1_id1
      FROM okc_k_rel_objs_v rlobj
     WHERE rlobj.chr_id = p_chr_id
       AND rlobj.cle_id = p_line_id
       AND rlobj.rty_code = 'OKLSRV'
       AND rlobj.jtot_object1_code = 'OKL_SERVICE_LINE';

    l_service_top_line_id okc_k_lines_b.id%TYPE;

    CURSOR get_serv_cle_from_serv (p_serv_top_line_id okc_k_lines_b.id%TYPE) IS
    SELECT dnz_chr_id
      FROM okc_k_lines_b
     WHERE id = p_serv_top_line_id;

    l_serv_contract_id okc_k_headers_b.id%TYPE;

    -- sjalasut: aug 30, 04 added variables to support business events. END

    --sechawla 4-jun-09 6826580
    cursor l_inv_frmt_csr(cp_inv_frmt_code in varchar2) IS
    select id
    from   okl_invoice_formats_v
    where  name = cp_inv_frmt_code;
    l_inv_frmt_id number;

    --Bug# 8652738
    CURSOR l_chk_rbk_csr(p_chr_id IN NUMBER) IS
    SELECT orig_system_source_code
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    l_chk_rbk_rec l_chk_rbk_csr%ROWTYPE;

    BEGIN
    /* sosharma  18-Apr-07 ,
    added code to set org context based on the chr_id for VPA, Contracts and IA.
    Thsi fix has been provided to support OA pages which are dynamic in nature and AMImpl is not passing the
    org context to the API.The fix doesnot have any other impact on functionality.
    Start changes
    */
    if (p_chr_id is not null and p_chr_id <> OKC_API.G_MISS_NUM) then
      OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_chr_id => p_chr_id);
    end if;
    /* sosharma end changes */

        if(l_chr_id is null or l_chr_id = OKC_API.G_MISS_NUM) then
            l_chr_id := -1;
        end if;
        if(l_line_id is null or l_line_id = OKC_API.G_MISS_NUM) then
            l_line_id := -1;
        end if;
        if(l_cpl_id is null or l_cpl_id = OKC_API.G_MISS_NUM) then
            l_cpl_id := -1;
        end if;
        if(l_chr_id = -1 and l_cpl_id = -1 and l_line_id = -1) then
            process_type := 'TEMPLATE';
        elsif(l_cpl_id = -1 and l_line_id = -1) then
            process_type := 'HEADER';
        elsif(l_cpl_id = -1 and l_line_id <> -1) then
            process_type := 'LINE';
    elsif(l_cpl_id <> -1) then
            process_type := 'PARTY';
    end if;


      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 4959361
      IF (l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAPSTH' and process_type = 'LINE') OR
         (l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAFEXP' and process_type = 'LINE') THEN

        OPEN get_line_style(p_line_id);
        FETCH get_line_style INTO l_line_style;
        CLOSE get_line_style;

        IF(l_line_style IS NOT NULL AND l_line_style = 'FEE') THEN
          OKL_LLA_UTIL_PVT.check_line_update_allowed
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_cle_id          => p_line_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;
      --Bug# 4959361

    loop
        i := i + 1;
        if(process_type = 'HEADER') then

            okl_am_qa_data_integrity_pvt.check_am_rule_format (
                                             x_return_status => x_return_status,
                                             p_chr_id => l_chr_id,
                                             p_rgr_rec => l_rgr_tbl(i));

             IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                -- RAISE OKC_API.G_EXCEPTION_ERROR;
                 RAISE G_EXCEPTION_STOP_VALIDATION;
                --return;
             END IF;
        end if;
     exit when (i >= l_rgr_tbl.last);
     end loop;

    i := 0;
    loop
        i := i + 1;
        /*
            if(process_type = 'TEMPLATE') then
                process_template_rule(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_rgr_rec           => l_rgr_tbl(i));
                     */
            if(process_type = 'HEADER') then

                process_hdr_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => l_chr_id,
                     p_rgr_rec           => l_rgr_tbl(i));

            elsif(process_type = 'LINE') then

                --2009-08-25 sechawla  Bug 8657968 : begin
                open   l_inv_frmt_csr(l_rgr_tbl(i).rule_information1);
 				fetch  l_inv_frmt_csr into l_inv_frmt_id;
      			close  l_inv_frmt_csr;
				if l_inv_frmt_id is not null then
                   l_rgr_tbl(i).rule_information1 := to_char(l_inv_frmt_id);
                end if;
				--2009-08-25 sechawla  Bug 8657968 : end
                process_line_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => l_chr_id,
                     p_line_id           => l_line_id,
                     p_rgr_rec           => l_rgr_tbl(i));

            elsif(process_type = 'PARTY') then

                --sechawla 4-jun-09 6826580 : begin
				open   l_inv_frmt_csr(l_rgr_tbl(i).rule_information1);
 				fetch  l_inv_frmt_csr into l_inv_frmt_id;
      			close  l_inv_frmt_csr;
				l_rgr_tbl(i).rule_information1 := to_char(l_inv_frmt_id);
				--sechawla 4-jun-09 6826580 : end

                process_party_rule_group_rules(
                     p_api_version       => p_api_version,
                     p_init_msg_list     => p_init_msg_list,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_chr_id            => l_chr_id,
                     p_line_id           => l_line_id,
                     p_cpl_id            => l_cpl_id,
                     p_rrd_id            => l_rrd_id,
                     p_rgr_rec           => l_rgr_tbl(i));
        end if;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    exit when (i >= l_rgr_tbl.last);
    end loop;
    IF (l_rgr_tbl.count > 0) THEN
        if(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAIIND') then

             OKL_LA_PAYMENTS_PVT.process_payment(
                        p_api_version      =>    p_api_version,
                        p_init_msg_list    =>    p_init_msg_list,
                        x_return_status    =>    x_return_status,
                        x_msg_count        =>    x_msg_count,
                        x_msg_data         =>    x_msg_data,
                        p_chr_id           =>    l_chr_id,
                        p_service_fee_id   =>    null,
                        p_asset_id         =>    null,
                        p_payment_id       =>    null,
                        p_update_type      =>    'VIR_PAYMENT',
                        x_rulv_tbl         =>    x_rulv_tbl);

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
                  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
                  raise OKC_API.G_EXCEPTION_ERROR;
              END IF;
       end if;

       --Bug# 8652738
       -- Do not sync property tax contract header values to contract lines
       -- for a rebook contract, as we do not support update of
       -- Property tax rules during rebook

       l_chk_rbk_rec := NULL;
       OPEN l_chk_rbk_csr(p_chr_id => l_chr_id);
       FETCH l_chk_rbk_csr INTO l_chk_rbk_rec;
       CLOSE l_chk_rbk_csr;

       IF ( NVL(l_chk_rbk_rec.orig_system_source_code, OKL_API.G_MISS_CHAR) <> 'OKL_REBOOK' ) THEN

         if(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAHDTX') then
              OKL_LA_PROPERTY_TAX_PVT.sync_contract_property_tax(
                        p_api_version      =>    p_api_version,
                        p_init_msg_list    =>    p_init_msg_list,
                        x_return_status    =>    x_return_status,
                        x_msg_count        =>    x_msg_count,
                        x_msg_data         =>    x_msg_data,
                        p_chr_id           =>    l_chr_id);

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
                  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
                  raise OKC_API.G_EXCEPTION_ERROR;
              END IF;
         end if;

       END IF;
       --Bug# 8652738

       --
       -- sjalasut. added logic to raise business events when a rule group is created
       --
       -- initialize the global variables for the business events
       l_raise_business_event := OKL_API.G_FALSE;
       l_business_event_name := NULL;
       l_terms_id := NULL;
       IF(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAAFLG' AND process_type = 'HEADER')THEN
         -- raise business event for the Liens and Title for Terms and Conditions for the Contract
         -- set raise business event flag to true
         l_raise_business_event := OKL_API.G_TRUE;
         -- set the event name to be raised. this event name will vary for each rule group
         l_business_event_name := G_WF_EVT_CONTRACT_TERM_UPDATED;
         OPEN get_header_terms_id(p_chr_id, l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code);
         FETCH get_header_terms_id INTO l_terms_id;
         CLOSE get_header_terms_id;
         IF(l_terms_id IS NOT NULL)THEN
           wf_event.AddParameterToList(G_WF_ITM_TERMS_ID, l_terms_id, l_parameter_list);
         END IF;
       ELSIF(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAAFLG' AND process_type = 'LINE')THEN
         -- raise business event for Liens Title and Registration for the Assets
         -- set raise business event flag to true
         l_raise_business_event := OKL_API.G_TRUE;
         -- set the event name to be raised. this event name will vary for each rule group
         l_business_event_name := G_WF_EVT_ASSET_FILING_UPDATED;
         wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, p_line_id, l_parameter_list);
       ELSIF(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAASTX' AND process_type = 'LINE')THEN
         -- raise business event for tax, property tax updated.
         l_raise_business_event := OKL_API.G_TRUE;
         l_business_event_name := G_WF_EVT_ASSET_PROPTAX_UPDATED;
         wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, p_line_id, l_parameter_list);
       ELSIF(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAPSTH' and process_type = 'LINE')THEN
         OPEN get_line_style(p_line_id);
         FETCH get_line_style INTO l_line_style;
         CLOSE get_line_style;
         -- raise business event for service line update passthru
         IF(l_line_style IS NOT NULL AND l_line_style = 'SOLD_SERVICE')THEN
           l_raise_business_event := OKL_API.G_TRUE;
           l_business_event_name := G_WF_EVT_SERV_PASS_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_SERV_LINE_ID, p_line_id, l_parameter_list);
           -- check if the service line in context has a service contract associated with it
           -- if so, pass the service contract id and service contract line id as parameters
           OPEN get_serv_chr_from_serv(p_chr_id, p_line_id);
           FETCH get_serv_chr_from_serv INTO l_service_top_line_id;
           CLOSE get_serv_chr_from_serv;
           IF(l_service_top_line_id IS NOT NULL)THEN
             OPEN get_serv_cle_from_serv(l_service_top_line_id);
             FETCH get_serv_cle_from_serv INTO l_serv_contract_id;
             CLOSE get_serv_cle_from_serv;
             wf_event.AddParameterToList(G_WF_ITM_SERV_CHR_ID, l_serv_contract_id, l_parameter_list);
             wf_event.AddParameterToList(G_WF_ITM_SERV_CLE_ID, l_service_top_line_id, l_parameter_list);
           END IF;
         -- raise the business event for update passthrough for Fee Line
         ELSIF(l_line_style IS NOT NULL AND l_line_style = 'FEE')THEN
           l_raise_business_event := OKL_API.G_TRUE;
           l_business_event_name := G_WF_EVT_FEE_PASS_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID, p_line_id, l_parameter_list);
         END IF;
       ELSIF(l_rgr_tbl(l_rgr_tbl.FIRST).rgd_code = 'LAFEXP' and process_type = 'LINE')THEN
         OPEN get_line_style(p_line_id);
         FETCH get_line_style INTO l_line_style;
         CLOSE get_line_style;
         -- raise business event for service line update expense
         IF(l_line_style IS NOT NULL AND l_line_style = 'SOLD_SERVICE')THEN
           l_raise_business_event := OKL_API.G_TRUE;
           l_business_event_name := G_WF_EVT_SERV_FEXP_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_SERV_LINE_ID, p_line_id, l_parameter_list);
           -- check if the service line in context has a service contract associated with it
           -- if so, pass the service contract id and service contract line id as parameters
           OPEN get_serv_chr_from_serv(p_chr_id, p_line_id);
           FETCH get_serv_chr_from_serv INTO l_service_top_line_id;
           CLOSE get_serv_chr_from_serv;
           IF(l_service_top_line_id IS NOT NULL)THEN
             OPEN get_serv_cle_from_serv(l_service_top_line_id);
             FETCH get_serv_cle_from_serv INTO l_serv_contract_id;
             CLOSE get_serv_cle_from_serv;
             wf_event.AddParameterToList(G_WF_ITM_SERV_CHR_ID, l_serv_contract_id, l_parameter_list);
             wf_event.AddParameterToList(G_WF_ITM_SERV_CLE_ID, l_service_top_line_id, l_parameter_list);
           END IF;
         ELSIF(l_line_style IS NOT NULL AND l_line_style = 'FEE')THEN
           l_raise_business_event := OKL_API.G_TRUE;
           l_business_event_name := G_WF_EVT_FEE_EXP_UPDATED;
           wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID, p_line_id, l_parameter_list);
         END IF;
       END IF;
    END IF;

    -- check if the business event needs to be raised
    IF(l_raise_business_event = OKL_API.G_TRUE AND l_business_event_name IS NOT NULL AND
       OKL_LLA_UTIL_PVT.is_lease_contract(p_chr_id)= OKL_API.G_TRUE)THEN
      -- since contract id is called as 'CONTRACT_ID'  for all the above events, it is being
      -- added to the parameter list here, than duplicating it in all the above if conditions

      wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, p_chr_id, l_parameter_list);
      raise_business_event(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_event_name      => l_business_event_name,
                           p_event_param_list => l_parameter_list
                          );
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);


  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then

         --sechawla 4-jun-09 6826580 : begin
		 IF l_inv_frmt_csr%ISOPEN THEN
		    CLOSE l_inv_frmt_csr;
		 END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

    when G_EXCEPTION_STOP_VALIDATION then
           --sechawla 4-jun-09 6826580 : begin
		 IF l_inv_frmt_csr%ISOPEN THEN
		    CLOSE l_inv_frmt_csr;
		 END IF;
         null;

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then

        --sechawla 4-jun-09 6826580 : begin
		 IF l_inv_frmt_csr%ISOPEN THEN
		    CLOSE l_inv_frmt_csr;
		 END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then

         --sechawla 4-jun-09 6826580 : begin
		 IF l_inv_frmt_csr%ISOPEN THEN
		    CLOSE l_inv_frmt_csr;
		 END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);
end process_rule_group_rules;

PROCEDURE process_template_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                       IN  NUMBER,
    p_rgr_tbl                      IN  rgr_tbl_type,
    x_rgr_tbl              OUT NOCOPY rgr_out_tbl_type) IS
    l_rgr_tbl   rgr_tbl_type := p_rgr_tbl;
    lx_rgr_tbl  rgr_out_tbl_type := x_rgr_tbl;
    i NUMBER := 0;
    l_id    NUMBER := p_id;

    --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
    l_proc_name   VARCHAR2(35)    := 'PROCESS_TEMPLATE_RULES';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;

    BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

        loop
        i := i + 1;
            process_template_rule(
                 p_api_version       => p_api_version,
                 p_init_msg_list     => p_init_msg_list,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_rgr_rec           => l_rgr_tbl(i),
                 px_rgr_rec          => lx_rgr_tbl(i));

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    exit when (i >= l_rgr_tbl.last);
    end loop;
    x_rgr_tbl := lx_rgr_tbl;


    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

end process_template_rules;

END OKL_RGRP_RULES_PROCESS_PVT;

/

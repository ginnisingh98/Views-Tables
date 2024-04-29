--------------------------------------------------------
--  DDL for Package Body OKS_SETUP_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_SETUP_UTIL_PUB" AS
/* $Header: OKSSETUB.pls 120.22.12010000.3 2008/11/07 10:06:14 serukull ship $ */


l_conc_program VARCHAR2(200) := 'Y';

-------------------------------------------------------------------------------
-- Procedure:          Get_Error_Stack
-- Purpose:            This procedure will copy the message stack to the debug
--                     log file.
-----------------------------------------------------------------------------
PROCEDURE Get_Error_Stack IS
    l_msg_index NUMBER;
    l_msg_data  VARCHAR2(32000);
    Begin
            l_msg_index := 1;
            For i in 1..fnd_msg_pub.count_msg
            loop
                            fnd_msg_pub.get
                            (
                            p_msg_index => i,
                            p_encoded   => 'F',
                            p_data      => l_msg_data,
                            p_msg_index_out  => l_msg_index
                            );
                OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>l_msg_data);

            End loop;

End Get_Error_Stack;

FUNCTION chk_party_Exists(p_chr_id IN NUMBER) return BOOLEAN IS

CURSOR l_party_csr(p_chr_id NUMBER) IS
   SELECT count(*)
   FROM okc_k_party_roles_b
   WHERE dnz_chr_id =p_chr_id
   AND rle_code in ('CUSTOMER','SUBSCRIBER')
   AND cle_id is null;
   --AND chr_id is null;

l_party_count  NUMBER:=0;

BEGIN

    OPEN l_party_csr(p_chr_id);
    FETCH l_party_csr INTO l_party_count;
    close l_party_csr;
    IF l_party_count>0 then
    return True;
    ELSE
    return False;
    END IF;
  END ;




-------------------------------------------------------------------------------
-- Procedure:          check_ccr_rule
-- Purpose:            this procedure updates the bank account id and auth
--                     code
-- In Parameters:       p_chr_id            the contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------
Procedure check_CCR_rule
                       (p_chr_id         IN  Number,
                        x_return_status  OUT NOCOPY Varchar2)
IS
 l_return_status              Varchar2(1);
 l_msg_count                  Number;
 l_msg_data                   Varchar2(2000);
 l_api_version                Number := 1;
 l_init_msg_list              Varchar2(1) := 'F';

Cursor get_ccr(p_chr_id IN NUMBER) is
  select
   id
  ,chr_id
  ,cc_no
  ,cc_expiry_date
  ,cc_bank_acct_id
  ,cc_auth_code
  ,object_version_number
  from oks_k_headers_b
  where chr_id=p_chr_id;

get_ccr_rec    get_ccr%rowtype;
l_khrv_tbl     OKS_KHR_PVT.khrv_tbl_type;
x_khrv_tbl     OKS_KHR_PVT.khrv_tbl_type;
l_error_tbl    OKC_API.ERROR_TBL_TYPE;

Begin
l_return_status := OKC_API.G_RET_STS_SUCCESS;

For get_ccr_rec In get_ccr(p_chr_id)
Loop

 IF get_ccr_rec.cc_bank_acct_id is not null then

   l_khrv_tbl.delete;

 l_khrv_tbl(1).ID                    :=get_ccr_rec.id;
 l_khrv_tbl(1).chr_id                :=get_ccr_rec.chr_id;
 l_khrv_tbl(1).CC_BANK_ACCT_ID       :=NULL;
 l_khrv_tbl(1).CC_AUTH_CODE	     :=NULL;
 l_khrv_tbl(1).OBJECT_VERSION_NUMBER :=get_ccr_rec.OBJECT_VERSION_NUMBER;
 l_khrv_tbl(1).CREATED_BY            :=OKC_API.G_MISS_NUM;
 l_khrv_tbl(1).CREATION_DATE         :=OKC_API.G_MISS_DATE;
 l_khrv_tbl(1).LAST_UPDATED_BY       :=OKC_API.G_MISS_NUM;
 l_khrv_tbl(1).LAST_UPDATE_DATE      :=OKC_API.G_MISS_DATE;
 l_khrv_tbl(1).LAST_UPDATE_LOGIN     :=OKC_API.G_MISS_NUM;

        OKS_CONTRACT_HDR_PUB.update_header (
         p_api_version                  => l_api_version,
         p_init_msg_list                => OKC_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => l_msg_count,
         x_msg_data                     => l_msg_data,
         p_khrv_tbl                     => l_khrv_tbl,
         x_khrv_tbl                     => x_khrv_tbl,
         p_validate_yn                   => 'N');

 END IF;

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

End Loop; --For get_line_id_rec In get_line_id_csr

    x_return_status := l_return_status;

 EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );


End check_CCR_rule;

-------------------------------------------------------------------------------
-- Procedure:          check_ccr_rule_line
-- Purpose:            this procedure updates the bank account id and auth
--                     code
-- In Parameters:       p_chr_id            the contract id
-- In Parameters:       p_cle_id            the lineid
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------
Procedure check_CCR_rule_line
                       (p_chr_id         IN  Number,
                        p_cle_id         IN  Number,
                        x_return_status  OUT NOCOPY Varchar2)
IS
 l_return_status              Varchar2(1);
 l_msg_count                  Number;
 l_msg_data                   Varchar2(2000);
 l_api_version                Number := 1;
 l_init_msg_list              Varchar2(1) := 'F';

Cursor get_ccr(p_chr_id IN NUMBER,p_cle_id IN NUMBER) is
  select
   id
  ,cle_id
  ,dnz_chr_id
  ,cc_no
  ,cc_expiry_date
  ,cc_bank_acct_id
  ,cc_auth_code
  ,object_version_number
  from oks_k_lines_b
  where dnz_chr_id=p_chr_id
  and cle_id =p_cle_id;

get_ccr_rec    get_ccr%rowtype;
l_klnv_tbl     oks_kln_pvt.klnv_tbl_type;
x_klnv_tbl     oks_kln_pvt.klnv_tbl_type;
l_error_tbl    OKC_API.ERROR_TBL_TYPE;

Begin
l_return_status := OKC_API.G_RET_STS_SUCCESS;

For get_ccr_rec In get_ccr(p_chr_id,p_cle_id)
Loop
 IF get_ccr_rec.cc_bank_acct_id is not null then
   l_klnv_tbl(1).id := get_ccr_rec.id;
   l_klnv_tbl(1).dnz_chr_id := get_ccr_rec.dnz_chr_id;
   l_klnv_tbl(1).CC_BANK_ACCT_ID   :=NULL;
   l_klnv_tbl(1).CC_AUTH_CODE	    :=NULL;
   l_klnv_tbl(1).object_version_number := get_ccr_rec.object_version_number;
   l_klnv_tbl(1).CREATED_BY            :=OKC_API.G_MISS_NUM;
   l_klnv_tbl(1).CREATION_DATE         :=OKC_API.G_MISS_DATE;
   l_klnv_tbl(1).LAST_UPDATED_BY       :=OKC_API.G_MISS_NUM;
   l_klnv_tbl(1).LAST_UPDATE_DATE      :=OKC_API.G_MISS_DATE;
   l_klnv_tbl(1).LAST_UPDATE_LOGIN     :=OKC_API.G_MISS_NUM;

          OKS_CONTRACT_LINE_PUB.update_line (
            p_api_version     => l_api_version,
            p_init_msg_list   => OKC_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data,
            p_klnv_tbl        => l_klnv_tbl,
            x_klnv_tbl        => x_klnv_tbl,
            p_validate_yn     => 'N');
   END IF;

  IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

     End Loop; --For get_line_id_rec In get_line_id_csr

    x_return_status := l_return_status;

  EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );

End check_CCR_rule_line;

FUNCTION chk_coverage_Exists(p_cle_id IN NUMBER) return BOOLEAN IS

CURSOR l_coverage_csr(p_cle_id NUMBER) IS
    SELECT id from okc_k_lines_b
    WHERE cle_id = p_cle_id
    and lse_id in (2,20);

CURSOR check_oks_csr(p_line_id number) is
    select count(*) from oks_k_lines_b
    where cle_id=p_line_id;

l_coverage_count  NUMBER;
l_line_id         NUMBER;

BEGIN
    OPEN l_coverage_csr(p_cle_id);
    FETCH l_coverage_csr INTO l_line_id;
    close l_coverage_csr;
    OPEN check_oks_csr(l_line_id);
    FETCH check_oks_csr into l_coverage_count;
    IF check_oks_csr%NOTFOUND THEN
      CLOSE check_oks_csr;

    ELSE
      CLOSE check_oks_csr;


    END IF;
    IF l_coverage_count>0 then
    return True;
    else
    return False;
    END IF;
  END ;
-------------------------------------------------------------------------------
-- Procedure:          copy_hdr_attr
-- Purpose:            This procedure copies header attributes from the old cont--                     ract and creates a row in the OKS_K_HEADERS_B table
-- In Parameters:       p_chr_id            the contract id
--                      p_new_chr_id        new contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure copy_hdr_attr
                     (p_chr_id         IN  NUMBER,
                      p_new_chr_id     IN  NUMBER,
                      p_duration_match IN VARCHAR2,
                      p_renew_ref_YN   IN VARCHAR2 DEFAULT 'N',
                      x_return_status  OUT NOCOPY VARCHAR2)
IS
ctr 			NUMBER :=1;
l_return_status         Varchar2(1);
l_msg_count             Number;
l_msg_data              Varchar2(2000);
l_api_version           Number := 1;
l_init_msg_list         Varchar2(1) := 'F';
l_khrv_tbl              OKS_KHR_PVT.khrv_tbl_type;
x_khrv_tbl              OKS_KHR_PVT.khrv_tbl_type;

CURSOR get_hdr_attr_csr (p_chr_id NUMBER) IS
       SELECT *
       FROM oks_k_headers_b
       WHERE chr_id = p_chr_id;

  l_api_name        CONSTANT VARCHAR2(30) := 'copy_hdr_attr';
  l_module_name     VARCHAR2(256) := G_APP_NAME ||'.plsql.' || G_PKG_NAME || '.' || l_api_name;

-- 8/5/2005 hkamdar R12 Partial Period Project
-- Added new cursor to fetch the org id for the contract
CURSOR get_org_id_csr (p_new_chr_id NUMBER) IS
       SELECT org_id
       FROM okc_k_headers_b
       WHERE id = p_new_chr_id;

l_period_type    varchar2(30):=null;
l_period_start   varchar2(30):=null;
l_price_uom     varchar2(30):=null;
l_org_id			number;
-- End hkamdar R12


BEGIN
l_return_status := OKC_API.G_RET_STS_SUCCESS;
              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_procedure
                        ,'OKS.plsql.OKS_COPY_CONTRACT_PVT.'||l_module_name||'.Begin'
                        ,'Entered OKS_SETUP_UTIL_PUB.copy_hdr_attr'
			||', p_chr_id ='||p_chr_id
			||', p_new_chr_id='||p_new_chr_id
			||', p_renew_ref_YN='||p_renew_ref_YN
                         );
              END IF;

 l_khrv_tbl.DELETE;
 x_khrv_tbl.DELETE;

-- 8/5/2005 hkamdar R12 Partial Period Project
-- get GCD values
open get_org_id_csr(p_new_chr_id);
fetch get_org_id_csr into l_org_id;
close get_org_id_csr;

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement
                        ,'OKS.plsql.OKS_COPY_CONTRACT_PVT.'||l_module_name
                        ,'Before call to OKS_RENEW_UTIL_PUB.get_period_defaults'
          			    ||', l_org_id ='||l_org_id
                         );
              END IF;

OKS_RENEW_UTIL_PUB.get_period_defaults
		(p_hdr_id   =>  NULL,-- passing NULL to fetch values from GCD
  	  	 p_org_id   =>  l_org_id,
  		 x_period_type => l_period_type,
  		 x_period_start => l_period_start,
  		 x_price_uom => l_price_uom,
  		 x_return_status => l_return_status);

      --Updating Global Variables with GCD Defaults
      G_GCD_PERIOD_START := l_period_start;
      G_GCD_PERIOD_TYPE  := l_period_type;
      G_GCD_PRICE_UOM    := l_price_uom;

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement
                        ,'OKS.plsql.OKS_COPY_CONTRACT_PVT.'||l_module_name
                       ,'after call to OKS_RENEW_UTIL_PUB.get_period_defaults'
          			    ||', l_period_type ='||l_period_type
          			    ||', l_period_start ='||l_period_start
          			    ||', l_price_uom ='||l_price_uom
                         );
              END IF;

-- End hkamdar R12 Partial Period Project

	 --get header record and copy
   FOR get_hdr_attr_rec IN get_hdr_attr_csr (p_chr_id)
    LOOP
    l_khrv_tbl(ctr).ID                          :=OKC_API.G_MISS_NUM;
    l_khrv_tbl(ctr).CHR_ID                      :=p_new_chr_id;
    l_khrv_tbl(ctr).ACCT_RULE_ID                :=get_hdr_attr_rec.ACCT_RULE_ID;
    l_khrv_tbl(ctr).PAYMENT_TYPE                :=get_hdr_attr_rec.PAYMENT_TYPE;
    l_khrv_tbl(ctr).CC_NO                       :=get_hdr_attr_rec.CC_NO;
    l_khrv_tbl(ctr).CC_EXPIRY_DATE              :=get_hdr_attr_rec.CC_EXPIRY_DATE;
    l_khrv_tbl(ctr).CC_BANK_ACCT_ID             :=get_hdr_attr_rec.CC_BANK_ACCT_ID;
    l_khrv_tbl(ctr).CC_AUTH_CODE                :=get_hdr_attr_rec.CC_AUTH_CODE ;
    l_khrv_tbl(ctr).COMMITMENT_ID               :=get_hdr_attr_rec.COMMITMENT_ID;
    l_khrv_tbl(ctr).GRACE_DURATION              :=get_hdr_attr_rec.GRACE_DURATION;
    l_khrv_tbl(ctr).GRACE_PERIOD                :=get_hdr_attr_rec.GRACE_PERIOD;
    l_khrv_tbl(ctr).EST_REV_PERCENT             :=get_hdr_attr_rec.EST_REV_PERCENT;
    l_khrv_tbl(ctr).EST_REV_DATE                :=get_hdr_attr_rec.EST_REV_DATE;
    l_khrv_tbl(ctr).TAX_AMOUNT                  :=get_hdr_attr_rec.TAX_AMOUNT;
    l_khrv_tbl(ctr).TAX_STATUS                  :=get_hdr_attr_rec.TAX_STATUS;
    l_khrv_tbl(ctr).TAX_CODE                    :=get_hdr_attr_rec.TAX_CODE ;
    l_khrv_tbl(ctr).TAX_EXEMPTION_ID            :=get_hdr_attr_rec.TAX_EXEMPTION_ID;
    l_khrv_tbl(ctr).BILLING_PROFILE_ID          :=get_hdr_attr_rec.BILLING_PROFILE_ID;
    -------- This field should only be updated by workflow. --------------------
    --- This interim renewal status will be used to defer the workflow. Finally it will be stamped as 'DRAFT'
    IF p_renew_ref_YN = 'Y' THEN
      l_khrv_tbl(ctr).RENEWAL_STATUS              := 'PREDRAFT'; --- get_hdr_attr_rec.RENEWAL_STATUS;
    ELSE
      l_khrv_tbl(ctr).RENEWAL_STATUS              := 'DRAFT'; --- get_hdr_attr_rec.RENEWAL_STATUS;
    END IF;
    ----------------------------------------------------------------------------
    l_khrv_tbl(ctr).ELECTRONIC_RENEWAL_FLAG     :=get_hdr_attr_rec.ELECTRONIC_RENEWAL_FLAG;

    l_khrv_tbl(ctr).QUOTE_TO_CONTACT_ID         :=get_hdr_attr_rec.QUOTE_TO_CONTACT_ID;
    l_khrv_tbl(ctr).QUOTE_TO_SITE_ID            :=get_hdr_attr_rec.QUOTE_TO_SITE_ID;
    l_khrv_tbl(ctr).QUOTE_TO_EMAIL_ID           :=get_hdr_attr_rec.QUOTE_TO_EMAIL_ID;
    l_khrv_tbl(ctr).QUOTE_TO_PHONE_ID           :=get_hdr_attr_rec.QUOTE_TO_PHONE_ID;
    l_khrv_tbl(ctr).QUOTE_TO_FAX_ID             :=get_hdr_attr_rec.QUOTE_TO_FAX_ID;

    l_khrv_tbl(ctr).RENEWAL_PO_REQUIRED         :=get_hdr_attr_rec.RENEWAL_PO_REQUIRED;
    l_khrv_tbl(ctr).RENEWAL_PO_NUMBER           :=get_hdr_attr_rec.RENEWAL_PO_NUMBER;
    l_khrv_tbl(ctr).RENEWAL_PRICE_LIST          :=get_hdr_attr_rec.RENEWAL_PRICE_LIST;
    l_khrv_tbl(ctr).RENEWAL_PRICING_TYPE        :=get_hdr_attr_rec.RENEWAL_PRICING_TYPE;
    l_khrv_tbl(ctr).RENEWAL_MARKUP_PERCENT      :=get_hdr_attr_rec.RENEWAL_MARKUP_PERCENT;
    l_khrv_tbl(ctr).RENEWAL_GRACE_DURATION      :=get_hdr_attr_rec.RENEWAL_GRACE_DURATION ;
    l_khrv_tbl(ctr).RENEWAL_GRACE_PERIOD        :=get_hdr_attr_rec.RENEWAL_GRACE_PERIOD;
    l_khrv_tbl(ctr).RENEWAL_EST_REV_PERCENT     :=get_hdr_attr_rec.RENEWAL_EST_REV_PERCENT;
    l_khrv_tbl(ctr).RENEWAL_EST_REV_DURATION    :=get_hdr_attr_rec.RENEWAL_EST_REV_DURATION;
    l_khrv_tbl(ctr).RENEWAL_EST_REV_PERIOD      :=get_hdr_attr_rec.RENEWAL_EST_REV_PERIOD;


   -- Renewal Rules used details will be copied only in the case of Renewal
   -- it won't be copied in copy contract
   -- This code is commented out for bug 3566235   as now renewal api is
  -- now updating renew rules used
/*
     IF p_duration_match='F' THen
    l_khrv_tbl(ctr).RENEWAL_PRICE_LIST_USED     :=get_hdr_attr_rec.RENEWAL_PRICE_LIST_USED;
    l_khrv_tbl(ctr).RENEWAL_TYPE_USED           :=get_hdr_attr_rec.RENEWAL_TYPE_USED;
    l_khrv_tbl(ctr).RENEWAL_NOTIFICATION_TO     :=get_hdr_attr_rec.RENEWAL_NOTIFICATION_TO;
    l_khrv_tbl(ctr).RENEWAL_PO_USED             :=get_hdr_attr_rec.RENEWAL_PO_USED ;
    l_khrv_tbl(ctr).RENEWAL_PRICING_TYPE_USED   :=get_hdr_attr_rec.RENEWAL_PRICING_TYPE_USED;
    l_khrv_tbl(ctr).RENEWAL_MARKUP_PERCENT_USED :=get_hdr_attr_rec.RENEWAL_MARKUP_PERCENT_USED;
    l_khrv_tbl(ctr).REV_EST_PERCENT_USED        :=get_hdr_attr_rec.REV_EST_PERCENT_USED;
    l_khrv_tbl(ctr).REV_EST_DURATION_USED       :=get_hdr_attr_rec.REV_EST_DURATION_USED;
    l_khrv_tbl(ctr).REV_EST_PERIOD_USED         :=get_hdr_attr_rec.REV_EST_PERIOD_USED;
    l_khrv_tbl(ctr).BILLING_PROFILE_USED        :=get_hdr_attr_rec.BILLING_PROFILE_USED;
    l_khrv_tbl(ctr).ERN_FLAG_USED_YN            :=get_hdr_attr_rec.ERN_FLAG_USED_YN;
    l_khrv_tbl(ctr).EVN_THRESHOLD_AMT           :=get_hdr_attr_rec.EVN_THRESHOLD_AMT;
    l_khrv_tbl(ctr).EVN_THRESHOLD_CUR           :=get_hdr_attr_rec.EVN_THRESHOLD_CUR;
    l_khrv_tbl(ctr).ERN_THRESHOLD_AMT           :=get_hdr_attr_rec.ERN_THRESHOLD_AMT ;
    l_khrv_tbl(ctr).ERN_THRESHOLD_CUR           :=get_hdr_attr_rec.ERN_THRESHOLD_CUR;
    l_khrv_tbl(ctr).RENEWAL_GRACE_DURATION_USED :=get_hdr_attr_rec.RENEWAL_GRACE_DURATION_USED;
    l_khrv_tbl(ctr).RENEWAL_GRACE_PERIOD_USED   :=get_hdr_attr_rec.RENEWAL_GRACE_PERIOD_USED;
    ELSE*/
     l_khrv_tbl(ctr).RENEWAL_PRICE_LIST_USED     :=null;
    l_khrv_tbl(ctr).RENEWAL_TYPE_USED           :=null;
    l_khrv_tbl(ctr).RENEWAL_NOTIFICATION_TO     :=null;
    l_khrv_tbl(ctr).RENEWAL_PO_USED             :=null;
    l_khrv_tbl(ctr).RENEWAL_PRICING_TYPE_USED   :=null;
    l_khrv_tbl(ctr).RENEWAL_MARKUP_PERCENT_USED :=null;
    l_khrv_tbl(ctr).REV_EST_PERCENT_USED        :=null;
    l_khrv_tbl(ctr).REV_EST_DURATION_USED       :=null;
    l_khrv_tbl(ctr).REV_EST_PERIOD_USED         :=null;
    l_khrv_tbl(ctr).BILLING_PROFILE_USED        :=null;
    l_khrv_tbl(ctr).ERN_FLAG_USED_YN            :=null;
    l_khrv_tbl(ctr).EVN_THRESHOLD_AMT           :=null;
    l_khrv_tbl(ctr).EVN_THRESHOLD_CUR           :=null;
    l_khrv_tbl(ctr).ERN_THRESHOLD_AMT           :=null;
    l_khrv_tbl(ctr).ERN_THRESHOLD_CUR           :=null;
    l_khrv_tbl(ctr).RENEWAL_GRACE_DURATION_USED :=null;
    l_khrv_tbl(ctr).RENEWAL_GRACE_PERIOD_USED   :=null;
    --END IF;
    l_khrv_tbl(ctr).INV_TRX_TYPE                :=get_hdr_attr_rec.INV_TRX_TYPE;
    l_khrv_tbl(ctr).INV_PRINT_PROFILE           :=get_hdr_attr_rec.INV_PRINT_PROFILE;

    --R12 Renewal Requirement--
    IF (p_renew_ref_YN = 'Y') THEN --RENEW case
     If (get_hdr_attr_rec.AR_INTERFACE_YN = 'R') then
      l_khrv_tbl(ctr).AR_INTERFACE_YN := 'Y';
     Else
      l_khrv_tbl(ctr).AR_INTERFACE_YN := get_hdr_attr_rec.AR_INTERFACE_YN;
     End If;
    ELSIF (p_renew_ref_YN = 'N') THEN --COPY case
      l_khrv_tbl(ctr).AR_INTERFACE_YN := get_hdr_attr_rec.AR_INTERFACE_YN;
    END IF;

    l_khrv_tbl(ctr).HOLD_BILLING                :=get_hdr_attr_rec.HOLD_BILLING;
    l_khrv_tbl(ctr).SUMMARY_TRX_YN              :=get_hdr_attr_rec.SUMMARY_TRX_YN;
    l_khrv_tbl(ctr).SERVICE_PO_NUMBER           :=get_hdr_attr_rec.SERVICE_PO_NUMBER;
    l_khrv_tbl(ctr).SERVICE_PO_REQUIRED         :=get_hdr_attr_rec.SERVICE_PO_REQUIRED;
    l_khrv_tbl(ctr).BILLING_SCHEDULE_TYPE       :=get_hdr_attr_rec.BILLING_SCHEDULE_TYPE;
    l_khrv_tbl(ctr).OBJECT_VERSION_NUMBER       :=OKC_API.G_MISS_NUM;
    l_khrv_tbl(ctr).SECURITY_GROUP_ID           :=get_hdr_attr_rec.SECURITY_GROUP_ID;
    l_khrv_tbl(ctr).REQUEST_ID                  :=get_hdr_attr_rec.REQUEST_ID;
    l_khrv_tbl(ctr).CREATED_BY                  :=OKC_API.G_MISS_NUM;
    l_khrv_tbl(ctr).CREATION_DATE               :=OKC_API.G_MISS_DATE;
    l_khrv_tbl(ctr).LAST_UPDATED_BY             :=OKC_API.G_MISS_NUM;
    l_khrv_tbl(ctr).LAST_UPDATE_DATE            :=OKC_API.G_MISS_DATE;
    l_khrv_tbl(ctr).LAST_UPDATE_LOGIN           :=OKC_API.G_MISS_NUM;

    ----New columns added in R12-------
    l_khrv_tbl(ctr).CC_NO:= get_hdr_attr_rec.CC_NO;
    l_khrv_tbl(ctr).CC_EXPIRY_DATE:= get_hdr_attr_rec.CC_EXPIRY_DATE;
    l_khrv_tbl(ctr).CC_BANK_ACCT_ID:= get_hdr_attr_rec.CC_BANK_ACCT_ID;
    l_khrv_tbl(ctr).CC_AUTH_CODE:= get_hdr_attr_rec.CC_AUTH_CODE;
    l_khrv_tbl(ctr).ELECTRONIC_RENEWAL_FLAG:= get_hdr_attr_rec.ELECTRONIC_RENEWAL_FLAG;

   --Changed the logic for GCD defaults to only use the defaulting mechanism if the corresponding values
   --in the source contract are null

    If (get_hdr_attr_rec.period_type IS NOT NULL) then
     l_khrv_tbl(ctr).period_type                  := get_hdr_attr_rec.period_type;
    Else
     l_khrv_tbl(ctr).period_type                  := l_period_type;
    End If;

    If (get_hdr_attr_rec.period_start IS NOT NULL) then
     l_khrv_tbl(ctr).period_start                 := get_hdr_attr_rec.period_start;
    Else
     l_khrv_tbl(ctr).period_start                 := l_period_start;
    End If;

    If (get_hdr_attr_rec.price_uom IS NOT NULL) then
     l_khrv_tbl(ctr).price_uom                    := get_hdr_attr_rec.price_uom;
    Else
     l_khrv_tbl(ctr).price_uom			  := l_price_uom;
    End If;

/*
-- 8/5/2005 hkamdar R12 Partial Period Project
-- Storing GCD defaults in l_khrv_tbl table to be used to create the Header.
    l_khrv_tbl(ctr).Period_Type := l_period_type;
    l_khrv_tbl(ctr).Period_Start := l_period_start;
    l_khrv_tbl(ctr).Price_uom := l_price_uom;
-- End hkamdar R12 Partial Period Project
*/

    l_khrv_tbl(ctr).trxn_extension_id            := get_hdr_attr_rec.trxn_extension_id;
    l_khrv_tbl(ctr).person_party_id              := get_hdr_attr_rec.person_party_id;
    l_khrv_tbl(ctr).tax_classification_code      := get_hdr_attr_rec.tax_classification_code;
    l_khrv_tbl(ctr).exempt_certificate_number    := get_hdr_attr_rec.exempt_certificate_number;
    l_khrv_tbl(ctr).exempt_reason_code           := get_hdr_attr_rec.exempt_reason_code;

    IF (p_renew_ref_YN = 'Y') THEN --RENEW case
          l_khrv_tbl(ctr).renewal_comment := OKC_API.G_MISS_CHAR;
    ELSE
          l_khrv_tbl(ctr).renewal_comment := get_hdr_attr_rec.renewal_comment;
    END IF;

           ctr := ctr+1;
   END LOOP;
              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement
                        ,l_module_name
                        ,'After get_hdr_attr_csr LOOP'
			||'l_khrv_tbl.COUNT = '||l_khrv_tbl.COUNT
                         );
              END IF;

	   IF l_khrv_tbl.COUNT >0 THEN

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement
                        ,l_module_name||'.OKS_CONTRACT_HDR_PUB.create_header'
                        ,'Before call to OKS_CONTRACT_HDR_PUB.create_header'
                         );
              END IF;

		OKS_CONTRACT_HDR_PUB.create_header (
                       p_api_version       => l_api_version,
                       p_init_msg_list     => OKC_API.G_FALSE,
                       x_return_status     => l_return_status,
                       x_msg_count         => l_msg_count,
                       x_msg_data          => l_msg_data,
                       p_khrv_tbl          => l_khrv_tbl,
                       x_khrv_tbl          => x_khrv_tbl,
                       p_validate_yn       => 'N');

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement
                        ,l_module_name||'.OKS_CONTRACT_HDR_PUB.create_header'
                        ,'After call to OKS_CONTRACT_HDR_PUB.create_header'
		        ||', x_return_status='||l_return_status
                         );
              END IF;

           END IF;

   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
         RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

    x_return_status := l_return_status;

  EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );


END copy_hdr_attr;

-------------------------------------------------------------------------------
-- Procedure:          copy_lines_attr
-- Purpose:            This procedure copies old line attributes and creates
--                     respective new rows in the OKS_K_LINES_B table.This proc
--                     also checks for the date_terminated. If this is not null
--                     then termination related fields are not copied.
-- In Parameters:       p_new_chr_id            the contract id
--                      p_new_cle_id            new line id passed
--                      p_cle_id                old line id passed
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure copy_lines_attr
                      (p_cle_id         IN  NUMBER,
                       p_new_cle_id     IN  NUMBER,
                       p_new_chr_id     IN  NUMBER,
                       p_do_copy        IN Boolean,
                       x_return_status  OUT NOCOPY VARCHAR2)
 IS
ctr 	                   NUMBER :=1;
l_return_status            Varchar2(1);
l_msg_count                Number;
l_msg_data                 Varchar2(2000);
l_api_version              Number := 1;
l_init_msg_list            Varchar2(1) := 'F';

l_klnv_tbl           oks_kln_pvt.klnv_tbl_type;
x_klnv_tbl           oks_kln_pvt.klnv_tbl_type;

CURSOR get_lines_attr_csr (p_cle_id NUMBER) IS
       SELECT *
       FROM oks_k_lines_v
       WHERE cle_id = p_cle_id;

CURSOR get_lines_details_csr (p_cle_id NUMBER) IS
       SELECT date_terminated, price_list_id
       FROM okc_k_lines_b
       WHERE id = p_cle_id;
-- Added for price lock
cursor get_contract_number(l_chr_id number) is
select contract_number
from okc_k_headers_b
where id = l_chr_id;

l_contract_number   VARCHAR2(120);
l_old_price_list_id number;
l_new_price_list_id number;
l_locked_price_list_id  number;
l_locked_price_list_line_id number;
--- End added for price lock
l_date_terminated Date;

BEGIN
l_return_status := OKC_API.G_RET_STS_SUCCESS;
 l_klnv_tbl.DELETE;
 x_klnv_tbl.DELETE;

 FOR get_lines_attr_rec IN get_lines_attr_csr (p_cle_id)
 LOOP
  OPEN get_lines_details_csr(P_CLE_ID);
 FETCH get_lines_details_csr INTO l_date_terminated, l_old_price_list_id;
 CLOSE get_lines_details_csr;

l_klnv_tbl(ctr).ID                  :=OKC_API.G_MISS_NUM;
l_klnv_tbl(ctr).CLE_ID              :=p_new_cle_id;
l_klnv_tbl(ctr).DNZ_CHR_ID          :=p_new_chr_id;
l_klnv_tbl(ctr).DISCOUNT_LIST       :=get_lines_attr_rec.DISCOUNT_LIST ;
l_klnv_tbl(ctr).ACCT_RULE_ID        :=get_lines_attr_rec.ACCT_RULE_ID;
l_klnv_tbl(ctr).PAYMENT_TYPE        :=get_lines_attr_rec.PAYMENT_TYPE;
l_klnv_tbl(ctr).CC_NO               :=get_lines_attr_rec.CC_NO;
l_klnv_tbl(ctr).CC_EXPIRY_DATE      :=get_lines_attr_rec.CC_EXPIRY_DATE;
l_klnv_tbl(ctr).CC_BANK_ACCT_ID     :=get_lines_attr_rec.CC_BANK_ACCT_ID;
l_klnv_tbl(ctr).CC_AUTH_CODE        :=get_lines_attr_rec.CC_AUTH_CODE;
l_klnv_tbl(ctr).COMMITMENT_ID       :=get_lines_attr_rec.COMMITMENT_ID;
-- Nulled for bug # 3845954
l_klnv_tbl(ctr).LOCKED_PRICE_LIST_ID:= null; --get_lines_attr_rec.LOCKED_PRICE_LIST_ID;
-- Added for bug # 3625365
l_klnv_tbl(ctr).LOCKED_PRICE_LIST_LINE_ID := null; --get_lines_attr_rec.LOCKED_PRICE_LIST_LINE_ID;
l_klnv_tbl(ctr).prorate := get_lines_attr_rec.prorate; -- prorate needs to be there bug # 3880955
l_klnv_tbl(ctr).break_uom := null;
----------------------------------
-- Copies the lock in case of copy
If p_do_copy and get_lines_attr_rec.LOCKED_PRICE_LIST_ID is not null Then
 OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'do copy is true');
        Open get_contract_number(p_new_chr_id);
        Fetch get_contract_number into l_contract_number;
        Close get_contract_number;
 OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'get_lines_attr_rec.LOCKED_PRICE_LIST_LINE_ID: ' ||  get_lines_attr_rec.LOCKED_PRICE_LIST_LINE_ID);

-- MKS Commented out.. Need to put back in once QP patch is ready.
/*
        QP_LOCK_PRICELIST_GRP.Lock_Price(p_source_list_line_id	  => get_lines_attr_rec.LOCKED_PRICE_LIST_LINE_ID,
                                        p_list_source_code        => 'OKS',
                                        p_orig_system_header_ref     => l_contract_number,
                                        x_locked_price_list_id       => l_locked_price_list_id,
                                        x_locked_list_line_id        => l_locked_price_list_line_id,
                                        x_return_status              => l_return_status,
 		                                x_msg_count                  => l_msg_count,
		                                x_msg_data                   => l_msg_data);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                 RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
*/
        l_klnv_tbl(ctr).LOCKED_PRICE_LIST_ID:= l_locked_price_list_id;
        l_klnv_tbl(ctr).LOCKED_PRICE_LIST_LINE_ID := l_locked_price_list_line_id;
        l_klnv_tbl(ctr).break_uom := get_lines_attr_rec.break_uom;

End If;
------------------------
l_klnv_tbl(ctr).USAGE_EST_YN        :=get_lines_attr_rec.USAGE_EST_YN;
l_klnv_tbl(ctr).USAGE_EST_METHOD    :=get_lines_attr_rec.USAGE_EST_METHOD;
l_klnv_tbl(ctr).USAGE_EST_START_DATE:=get_lines_attr_rec.USAGE_EST_START_DATE;
l_klnv_tbl(ctr).TERMN_METHOD        :=get_lines_attr_rec.TERMN_METHOD;
/*
l_klnv_tbl(ctr).UBT_AMOUNT          :=get_lines_attr_rec.UBT_AMOUNT;
l_klnv_tbl(ctr).CREDIT_AMOUNT       :=get_lines_attr_rec.CREDIT_AMOUNT;
l_klnv_tbl(ctr).SUPPRESSED_CREDIT   :=get_lines_attr_rec.SUPPRESSED_CREDIT;
l_klnv_tbl(ctr).OVERRIDE_AMOUNT     :=get_lines_attr_rec.OVERRIDE_AMOUNT;
*/
l_klnv_tbl(ctr).CUST_PO_NUMBER_REQ_YN  :=get_lines_attr_rec.CUST_PO_NUMBER_REQ_YN;
l_klnv_tbl(ctr).CUST_PO_NUMBER      :=get_lines_attr_rec.CUST_PO_NUMBER;
l_klnv_tbl(ctr).GRACE_DURATION      :=get_lines_attr_rec.GRACE_DURATION;
l_klnv_tbl(ctr).GRACE_PERIOD        :=get_lines_attr_rec.GRACE_PERIOD;
l_klnv_tbl(ctr).INV_PRINT_FLAG      :=get_lines_attr_rec.INV_PRINT_FLAG;
l_klnv_tbl(ctr).PRICE_UOM           :=get_lines_attr_rec.PRICE_UOM;
l_klnv_tbl(ctr).TAX_AMOUNT          :=get_lines_attr_rec.TAX_AMOUNT;
l_klnv_tbl(ctr).TAX_INCLUSIVE_YN    :=get_lines_attr_rec.TAX_INCLUSIVE_YN;
l_klnv_tbl(ctr).TAX_STATUS          :=get_lines_attr_rec.TAX_STATUS;
l_klnv_tbl(ctr).TAX_CODE            :=get_lines_attr_rec.TAX_CODE;
l_klnv_tbl(ctr).TAX_EXEMPTION_ID    :=get_lines_attr_rec.TAX_EXEMPTION_ID;
l_klnv_tbl(ctr).IB_TRANS_TYPE       :=get_lines_attr_rec.IB_TRANS_TYPE;
l_klnv_tbl(ctr).IB_TRANS_DATE       :=get_lines_attr_rec.IB_TRANS_DATE;
l_klnv_tbl(ctr).PROD_PRICE          :=get_lines_attr_rec.PROD_PRICE;
l_klnv_tbl(ctr).SERVICE_PRICE       :=get_lines_attr_rec.SERVICE_PRICE;
l_klnv_tbl(ctr).CLVL_LIST_PRICE     :=get_lines_attr_rec.CLVL_LIST_PRICE;
l_klnv_tbl(ctr).CLVL_QUANTITY       :=get_lines_attr_rec.CLVL_QUANTITY;
l_klnv_tbl(ctr).CLVL_EXTENDED_AMT   :=get_lines_attr_rec.CLVL_EXTENDED_AMT;
l_klnv_tbl(ctr).CLVL_UOM_CODE       :=get_lines_attr_rec.CLVL_UOM_CODE;
l_klnv_tbl(ctr).TOPLVL_OPERAND_CODE :=get_lines_attr_rec.TOPLVL_OPERAND_CODE;
l_klnv_tbl(ctr).TOPLVL_OPERAND_VAL  :=get_lines_attr_rec.TOPLVL_OPERAND_VAL;
l_klnv_tbl(ctr).TOPLVL_QUANTITY     :=get_lines_attr_rec.TOPLVL_QUANTITY;
l_klnv_tbl(ctr).TOPLVL_UOM_CODE     :=get_lines_attr_rec.TOPLVL_UOM_CODE;
l_klnv_tbl(ctr).TOPLVL_ADJ_PRICE    :=get_lines_attr_rec.TOPLVL_ADJ_PRICE;
l_klnv_tbl(ctr).TOPLVL_PRICE_QTY    :=get_lines_attr_rec.TOPLVL_PRICE_QTY;
l_klnv_tbl(ctr).AVERAGING_INTERVAL     :=get_lines_attr_rec.AVERAGING_INTERVAL ;
l_klnv_tbl(ctr).SETTLEMENT_INTERVAL  :=get_lines_attr_rec.SETTLEMENT_INTERVAL;
l_klnv_tbl(ctr).MINIMUM_QUANTITY    :=get_lines_attr_rec.MINIMUM_QUANTITY ;
l_klnv_tbl(ctr).DEFAULT_QUANTITY    :=get_lines_attr_rec.DEFAULT_QUANTITY;
l_klnv_tbl(ctr).AMCV_FLAG           :=get_lines_attr_rec.AMCV_FLAG;
l_klnv_tbl(ctr).FIXED_QUANTITY      :=get_lines_attr_rec.FIXED_QUANTITY;
l_klnv_tbl(ctr).USAGE_DURATION      :=get_lines_attr_rec.USAGE_DURATION;
l_klnv_tbl(ctr).USAGE_PERIOD        :=get_lines_attr_rec.USAGE_PERIOD;
l_klnv_tbl(ctr).LEVEL_YN            :=get_lines_attr_rec.LEVEL_YN;
l_klnv_tbl(ctr).USAGE_TYPE          :=get_lines_attr_rec.USAGE_TYPE;
l_klnv_tbl(ctr).UOM_QUANTIFIED      :=get_lines_attr_rec.UOM_QUANTIFIED;
l_klnv_tbl(ctr).BASE_READING        :=get_lines_attr_rec.BASE_READING;
l_klnv_tbl(ctr).BILLING_SCHEDULE_TYPE :=get_lines_attr_rec.BILLING_SCHEDULE_TYPE;
l_klnv_tbl(ctr).COVERAGE_TYPE       :=get_lines_attr_rec.COVERAGE_TYPE;
l_klnv_tbl(ctr).EXCEPTION_COV_ID    :=get_lines_attr_rec.EXCEPTION_COV_ID;
l_klnv_tbl(ctr).LIMIT_UOM_QUANTIFIED:=get_lines_attr_rec.LIMIT_UOM_QUANTIFIED;
l_klnv_tbl(ctr).DISCOUNT_AMOUNT     :=get_lines_attr_rec.DISCOUNT_AMOUNT;
l_klnv_tbl(ctr).DISCOUNT_PERCENT    :=get_lines_attr_rec.DISCOUNT_PERCENT;
l_klnv_tbl(ctr).OFFSET_DURATION     :=get_lines_attr_rec.OFFSET_DURATION;
l_klnv_tbl(ctr).OFFSET_PERIOD       :=get_lines_attr_rec.OFFSET_PERIOD;
l_klnv_tbl(ctr).INCIDENT_SEVERITY_ID:=get_lines_attr_rec.INCIDENT_SEVERITY_ID;
l_klnv_tbl(ctr).PDF_ID              :=get_lines_attr_rec.PDF_ID;
l_klnv_tbl(ctr).WORK_THRU_YN        :=get_lines_attr_rec.WORK_THRU_YN;
l_klnv_tbl(ctr).REACT_ACTIVE_YN     :=get_lines_attr_rec.REACT_ACTIVE_YN;
l_klnv_tbl(ctr).TRANSFER_OPTION         :=get_lines_attr_rec.TRANSFER_OPTION;
l_klnv_tbl(ctr).PROD_UPGRADE_YN     :=get_lines_attr_rec.PROD_UPGRADE_YN;
l_klnv_tbl(ctr).INHERITANCE_TYPE    :=get_lines_attr_rec.INHERITANCE_TYPE;
l_klnv_tbl(ctr).PM_PROGRAM_ID       :=get_lines_attr_rec.PM_PROGRAM_ID;
l_klnv_tbl(ctr).PM_CONF_REQ_YN      :=get_lines_attr_rec.PM_CONF_REQ_YN;
l_klnv_tbl(ctr).PM_SCH_EXISTS_YN    :=get_lines_attr_rec.PM_SCH_EXISTS_YN;
l_klnv_tbl(ctr).ALLOW_BT_DISCOUNT   :=get_lines_attr_rec.ALLOW_BT_DISCOUNT;
l_klnv_tbl(ctr).APPLY_DEFAULT_TIMEZONE:=get_lines_attr_rec.APPLY_DEFAULT_TIMEZONE;
l_klnv_tbl(ctr).sync_date_install     :=get_lines_attr_rec.sync_date_install ;
l_klnv_tbl(ctr).sfwt_flag             :=get_lines_attr_rec.sfwt_flag ;
l_klnv_tbl(ctr).invoice_text          :=get_lines_attr_rec.invoice_text;
l_klnv_tbl(ctr).ib_trx_details        :=get_lines_attr_rec.ib_trx_details ;
l_klnv_tbl(ctr).status_text           :=get_lines_attr_rec.status_text ;
l_klnv_tbl(ctr).react_time_name       :=get_lines_attr_rec.react_time_name;
l_klnv_tbl(ctr).OBJECT_VERSION_NUMBER:=get_lines_attr_rec.OBJECT_VERSION_NUMBER;
l_klnv_tbl(ctr).SECURITY_GROUP_ID   :=get_lines_attr_rec.SECURITY_GROUP_ID;
l_klnv_tbl(ctr).REQUEST_ID          :=get_lines_attr_rec.REQUEST_ID;
l_klnv_tbl(ctr).CREATED_BY          :=get_lines_attr_rec.CREATED_BY;
l_klnv_tbl(ctr).CREATION_DATE       :=get_lines_attr_rec.CREATION_DATE;
l_klnv_tbl(ctr).LAST_UPDATED_BY     :=get_lines_attr_rec.LAST_UPDATED_BY;
l_klnv_tbl(ctr).LAST_UPDATE_DATE    :=get_lines_attr_rec.LAST_UPDATE_DATE;
l_klnv_tbl(ctr).LAST_UPDATE_LOGIN   :=get_lines_attr_rec.LAST_UPDATE_LOGIN;

--Bug 4722452: R12 columns added.
l_klnv_tbl(ctr).TRXN_EXTENSION_ID := get_lines_attr_rec.TRXN_EXTENSION_ID;
l_klnv_tbl(ctr).TAX_CLASSIFICATION_CODE := get_lines_attr_rec.TAX_CLASSIFICATION_CODE;
l_klnv_tbl(ctr).EXEMPT_CERTIFICATE_NUMBER := get_lines_attr_rec.EXEMPT_CERTIFICATE_NUMBER;
l_klnv_tbl(ctr).EXEMPT_REASON_CODE := get_lines_attr_rec.EXEMPT_REASON_CODE;
--End of Fix for bug 4722452

    l_klnv_tbl(ctr).UBT_AMOUNT          := null; --get_lines_attr_rec.UBT_AMOUNT;
    l_klnv_tbl(ctr).CREDIT_AMOUNT       := null; -- get_lines_attr_rec.CREDIT_AMOUNT;
    l_klnv_tbl(ctr).SUPPRESSED_CREDIT   := null; -- get_lines_attr_rec.SUPPRESSED_CREDIT;

  IF l_Date_terminated is NULL Then
    l_klnv_tbl(ctr).OVERRIDE_AMOUNT     :=get_lines_attr_rec.OVERRIDE_AMOUNT;
    l_klnv_tbl(ctr).FULL_CREDIT         :=get_lines_attr_rec.FULL_CREDIT;
  ELSE
    l_klnv_tbl(ctr).OVERRIDE_AMOUNT     :=NULL;
    l_klnv_tbl(ctr).FULL_CREDIT         :=NULL;
  END IF;

   ctr := ctr+1;
  END LOOP;
   IF l_klnv_tbl.COUNT >0  THEN
    oks_contract_line_pub.create_line
    (
     p_api_version   => l_api_version,
     p_init_msg_list => l_init_msg_list,
     x_return_status => l_return_status,
     x_msg_count     => l_msg_count,
     x_msg_data      => l_msg_data,
     p_klnv_tbl      => l_klnv_tbl,
     x_klnv_tbl      => x_klnv_tbl,
     p_validate_yn   => 'N' );

   END IF; --IF l_rev_tbl.COUNT >0

     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

     x_return_status := l_return_status;

  EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );


END copy_lines_attr;

-------------------------------------------------------------------------------
-- Procedure:          Update_hdr_amount
-- Purpose:            This procedure updates the header amount
--                      used to pass to OC APIs
-- In Parameters:       p_chr_id            the contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure Update_Hdr_Amount
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_chr_id              IN   Number,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2
 )
 IS

   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'Update_Hdr_Amount';
   l_api_version        Number := 1.0;

--Contract Header
  	l_chrv_tbl_in   	okc_contract_pub.chrv_tbl_type;
  	l_chrv_tbl_out         	okc_contract_pub.chrv_tbl_type;


   Cursor l_line_csr Is Select Sum(Nvl(PRICE_NEGOTIATED,0))
                        From OKC_K_LINES_B
                        Where dnz_chr_id = p_chr_id And
                        lse_id in (7,8,9,10,11,35,25);

   l_hdr_amount Number;

  BEGIN

       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

      Open  l_line_csr;
      Fetch l_line_csr into l_hdr_amount;
      Close l_line_csr;


	l_chrv_tbl_in(1).id		      := p_chr_id;
	l_chrv_tbl_in(1).estimated_amount	:= l_hdr_amount;

    	okc_contract_pub.update_contract_header
    	(
    		p_api_version	=> l_api_version,
    		p_init_msg_list	=> p_init_msg_list,
    		x_return_status	=> x_return_status,
    		x_msg_count	=> x_msg_count,
    		x_msg_data	=> x_msg_data,
    		p_chrv_tbl	=> l_chrv_tbl_in,
    		x_chrv_tbl	=> l_chrv_tbl_out
      );

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

       x_return_status := l_return_status;

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

  END Update_Hdr_Amount;

-------------------------------------------------------------------------------
-- Procedure:          Copy_Hdr_Bill_Sch
-- Purpose:            This procedure copies the header billing schedule from
--                     old contract to new contract
-- In Parameters:       p_chr_id            the contract id
--                      p_new_chr_id        new contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure Copy_Hdr_Bill_Sch( p_chr_id         IN Number,
                             p_new_chr_id     IN NUMBER,
                             x_return_status  OUT NOCOPY Varchar2)
IS

l_return_status            Varchar2(1);
l_msg_count                Number;
l_msg_data                 Varchar2(2000);
l_api_version              Number := 1;
l_init_msg_list            Varchar2(1) := 'F';
l_tbl_ctr                  Number;
l_rgp_id                   Number;
l_start_date               Date;
l_time_value               Number;
l_adv_arr		   VARCHAR2(40);
l_invoice_rule_id	   NUMBER;
l_rule_slh_id              NUMBER;
l_sll_exist                boolean := false;
l_slh_exist                boolean := false;
l_strlvl_tbl               OKS_SLL_PVT.sllv_tbl_type;
x_strlvl_tbl               OKS_SLL_PVT.sllv_tbl_type;
l_error_tbl                OKC_API.ERROR_TBL_TYPE;

CURSOR strlvl_csr (p_chr_id NUMBER) IS
       SELECT   ID
                ,CHR_ID
                ,CLE_ID
                ,DNZ_CHR_ID
                ,SEQUENCE_NO
                ,UOM_CODE
                ,START_DATE
                ,LEVEL_PERIODS
                ,UOM_PER_PERIOD
                ,ADVANCE_PERIODS
                ,LEVEL_AMOUNT
                ,INVOICE_OFFSET_DAYS
                ,INTERFACE_OFFSET_DAYS
                ,COMMENTS
                ,DUE_ARR_YN
                ,AMOUNT
                ,LINES_DETAILED_YN
       FROM     oks_stream_levels_b
       WHERE    chr_id=p_chr_id
       ORDER BY SEQUENCE_NO;/*BUG 7450286 */


strlvl_rec  strlvl_csr%ROWTYPE;

cursor hdr_csr (p_chr_id Number) Is
    SELECT start_date
    FROM   okc_k_headers_b
    WHERE  id =  p_chr_id;


Begin
   x_return_status := OKC_API.G_RET_STS_SUCCESS;
   l_tbl_ctr := 0;
   Open  hdr_csr(p_chr_id);
   Fetch hdr_csr into l_start_date;
   Close hdr_csr;


 l_strlvl_tbl.delete;

    For strlvl_rec in strlvl_csr (p_chr_id)
      Loop
      l_tbl_ctr := l_tbl_ctr + 1;
      l_strlvl_tbl(l_tbl_ctr).ID          :=OKC_API.G_MISS_NUM;
      l_strlvl_tbl(l_tbl_ctr).CHR_ID	  :=p_new_chr_id;
      l_strlvl_tbl(l_tbl_ctr).CLE_ID	  :=NULL;
      l_strlvl_tbl(l_tbl_ctr).DNZ_CHR_ID  :=p_new_chr_id;
      l_strlvl_tbl(l_tbl_ctr).SEQUENCE_NO :=strlvl_rec.SEQUENCE_NO;
      l_strlvl_tbl(l_tbl_ctr).UOM_CODE	  :=strlvl_rec.UOM_CODE;
      l_strlvl_tbl(l_tbl_ctr).START_DATE  :=strlvl_rec.START_DATE;
      l_strlvl_tbl(l_tbl_ctr).LEVEL_PERIODS:=strlvl_rec.LEVEL_PERIODS;
      l_strlvl_tbl(l_tbl_ctr).UOM_PER_PERIOD:=strlvl_rec.UOM_PER_PERIOD;
      l_strlvl_tbl(l_tbl_ctr).ADVANCE_PERIODS:=strlvl_rec.ADVANCE_PERIODS;
      l_strlvl_tbl(l_tbl_ctr).LEVEL_AMOUNT	:=strlvl_rec.LEVEL_AMOUNT;
      l_strlvl_tbl(l_tbl_ctr).INVOICE_OFFSET_DAYS:=strlvl_rec.INVOICE_OFFSET_DAYS;
      l_strlvl_tbl(l_tbl_ctr).INTERFACE_OFFSET_DAYS:=strlvl_rec.INTERFACE_OFFSET_DAYS;
      l_strlvl_tbl(l_tbl_ctr).COMMENTS	  :=strlvl_rec.COMMENTS;
      l_strlvl_tbl(l_tbl_ctr).DUE_ARR_YN  :=strlvl_rec.DUE_ARR_YN;
      l_strlvl_tbl(l_tbl_ctr).AMOUNT	  :=strlvl_rec.AMOUNT;
      l_strlvl_tbl(l_tbl_ctr).LINES_DETAILED_YN:=strlvl_rec.LINES_DETAILED_YN;
        l_sll_exist := true;
      End Loop;

  If l_strlvl_tbl.count > 0 Then

        oks_contract_sll_pub.create_sll (
        p_api_version                  => l_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => l_msg_count,
        x_msg_data                     => l_msg_data,
        p_sllv_tbl                     => l_strlvl_tbl,
        x_sllv_tbl                     => x_strlvl_tbl,
        p_validate_yn                   => 'N');

            x_return_status := l_return_status;

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;


        OKS_BILL_SCH.Create_hdr_schedule(
           p_contract_id         => p_new_chr_id,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data          => l_msg_data);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

           x_return_status := l_return_status;


  End if;


  Exception
   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
                x_return_status := l_return_status;
                Null;

        WHEN  OTHERS THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                OKC_API.set_message
                              (G_APP_NAME,
                               G_UNEXPECTED_ERROR,
                               G_SQLCODE_TOKEN,
                               SQLCODE,
                               G_SQLERRM_TOKEN,
                               SQLERRM);

End Copy_Hdr_Bill_Sch;


-------------------------------------------------------------------------------
-- Procedure:          copy_revenue_distb
-- Purpose:            This procedure copies revenue distribution details from
--                     old contract to new contract
-- In Parameters:       p_cle_id            the line id
--                      p_new_cle_id        new line id
--                      p_new_chr_id        new contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure copy_revenue_distb
                           (p_cle_id         IN  NUMBER,
                            p_new_cle_id     IN  NUMBER,
                            p_new_chr_id     IN  NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2)
IS

ctr 	    		NUMBER :=1;
l_rev_tbl  		OKS_REV_DISTR_PUB.rdsv_tbl_type;
x_rev_tbl  		OKS_REV_DISTR_PUB.rdsv_tbl_type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_api_version           NUMBER := 1;
l_init_msg_list         VARCHAR2(1) := 'F';
l_id                    NUMBER;

CURSOR get_revenue_dist_rule_csr (p_cle_id NUMBER)
IS
      SELECT account_class,code_combination_id,percent,object_version_number
             security_group_id
      FROM   oks_rev_distributions
      WHERE  cle_id = p_cle_id;

CURSOR rev_exist(cleId number, chrId number) is
      SELECT id
      FROM oks_rev_distributions
      WHERE cle_id = cleId and chr_id = chrId;

BEGIN
l_return_status := OKC_API.G_RET_STS_SUCCESS;
l_rev_tbl.DELETE;
	 --get revenue distribution record and copy
	   FOR get_revenue_dist_rule_rec IN get_revenue_dist_rule_csr (p_cle_id)
	   LOOP
	    l_rev_tbl(ctr).chr_id              := p_new_chr_id;
	    l_rev_tbl(ctr).cle_id              := p_new_cle_id;
	    l_rev_tbl(ctr).account_class       := get_revenue_dist_rule_rec.account_class;
	    l_rev_tbl(ctr).code_combination_id := get_revenue_dist_rule_rec.code_combination_id;
	    l_rev_tbl(ctr).percent             := get_revenue_dist_rule_rec.percent;
	    l_rev_tbl(ctr).object_version_number := OKC_API.G_MISS_NUM;
	    l_rev_tbl(ctr).created_by          := OKC_API.G_MISS_NUM;
	    l_rev_tbl(ctr).creation_date       := OKC_API.G_MISS_DATE;
	    l_rev_tbl(ctr).last_updated_by     := OKC_API.G_MISS_NUM;
	    l_rev_tbl(ctr).last_update_date    := OKC_API.G_MISS_DATE;
	    l_rev_tbl(ctr).last_update_login   := OKC_API.G_MISS_NUM;

	    ctr := ctr+1;
	   END LOOP;

	   IF l_rev_tbl.COUNT >0
	   THEN
          ctr := 1;
          for rev_exist_rec in rev_exist(p_new_cle_id, p_new_chr_id)
          Loop
	           l_rev_tbl(ctr).id := rev_exist_rec.id;
                ctr:= ctr + 1;
          End Loop;
          /*
          If ctr > 1 then
            -- Delete the revenue accounting code if it already exists
            OKS_REV_DISTR_PUB.delete_Revenue_Distr(
                                 p_api_version   => l_api_version,
			     x_return_status => l_return_status,
			     x_msg_count     => l_msg_count,
			     x_msg_data      => l_msg_data,
			     p_rdsv_tbl      => l_rev_tbl);
          End If;
          */
          -- if ctr = 1 then this line didn't have a revenue distribution code.
          -- if ctr > 1
          If ctr = 1 then
		       OKS_REV_DISTR_PUB.insert_Revenue_Distr(
			     p_api_version   => l_api_version,
			     x_return_status => l_return_status,
			     x_msg_count     => l_msg_count,
			     x_msg_data      => l_msg_data,
			     p_rdsv_tbl      => l_rev_tbl,
			     x_rdsv_tbl      => x_rev_tbl);
          End If;
     END IF; --IF l_rev_tbl.COUNT >0

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

       x_return_status := l_return_status;

  EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );

END copy_revenue_distb;

-------------------------------------------------------------------------------
-- Procedure:           copy_hdr_sales_credits
-- Purpose:             This procedure copies the header salescredit details
--                      from old contract to new contract
-- In Parameters:       p_chr_id            the contract id
--                      p_new_chr_id        new  contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure copy_hdr_sales_credits
                               (p_chr_id         IN  NUMBER,
                                p_new_chr_id     IN  NUMBER,
                                x_return_status  OUT NOCOPY VARCHAR2)
IS
ctr 	    		   NUMBER :=1;
l_scrv_tbl                 OKS_SALES_CREDIT_PUB.scrv_tbl_type;
x_scrv_tbl                 OKS_SALES_CREDIT_PUB.scrv_tbl_type;
l_return_status            Varchar2(1);
l_msg_count                Number;
l_msg_data                 Varchar2(2000);
l_api_version              Number := 1;
l_init_msg_list            Varchar2(1) := 'F';

CURSOR get_sales_credits_csr (p_chr_id NUMBER) IS
	   SELECT
		    percent,
                    chr_id,
                    ctc_id,
                    sales_group_id,
                    sales_credit_type_id1,
		    sales_credit_type_id2
	   FROM oks_k_sales_credits
	   WHERE chr_id = p_chr_id
	   AND   cle_id IS NULL;

BEGIN
l_return_status := OKC_API.G_RET_STS_SUCCESS;
 l_scrv_tbl.DELETE;
 x_scrv_tbl.DELETE;

	 --get sale credits record and copy
	   FOR get_sales_credits_rec IN get_sales_credits_csr (p_chr_id)
	   LOOP
            l_scrv_tbl(ctr).id                    := OKC_API.G_MISS_NUM;
	       l_scrv_tbl(ctr).chr_id                := p_new_chr_id;
	       l_scrv_tbl(ctr).cle_id                := OKC_API.G_MISS_NUM;
	       l_scrv_tbl(ctr).percent               := get_sales_credits_rec.percent;
	       l_scrv_tbl(ctr).ctc_id                := get_sales_credits_rec.ctc_id;
	  l_scrv_tbl(ctr).sales_group_id := get_sales_credits_rec.sales_group_id;
	  l_scrv_tbl(ctr).sales_credit_type_id1 := get_sales_credits_rec.sales_credit_type_id1;
	  l_scrv_tbl(ctr).sales_credit_type_id2 := get_sales_credits_rec.sales_credit_type_id2;
		  l_scrv_tbl(ctr).object_version_number := OKC_API.G_MISS_NUM;
		  l_scrv_tbl(ctr).created_by            := OKC_API.G_MISS_NUM;
		  l_scrv_tbl(ctr).creation_date         := OKC_API.G_MISS_DATE;
		  l_scrv_tbl(ctr).last_updated_by       := OKC_API.G_MISS_NUM;
		  l_scrv_tbl(ctr).last_update_date      := OKC_API.G_MISS_DATE;
		    ctr := ctr+1;
	   END LOOP;

	   IF l_scrv_tbl.COUNT >0
	   THEN
		  OKS_SALES_CREDIT_PUB.insert_Sales_credit(
			          p_api_version   => l_api_version,
				  x_return_status => l_return_status,
				  x_msg_count     => l_msg_count,
			          x_msg_data      => l_msg_data,
			          p_scrv_tbl      => l_scrv_tbl,
			          x_scrv_tbl      => x_scrv_tbl);

     END IF; --IF l_rev_tbl.COUNT >0

     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

                      x_return_status := l_return_status;

  EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );


END copy_hdr_sales_credits;

-------------------------------------------------------------------------------
-- Procedure:          copy_line_sales_credits
-- Purpose:            This procedure copies lines sales credit from old
--                     contract to new contract
--
-- In Parameters:       p_cle_id            the line id
--                      p_new_cle_id        new line id
--                      p_new_chr_id        new contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

Procedure copy_line_sales_credits
                         (p_cle_id         IN  NUMBER,
                          p_new_cle_id     IN  NUMBER,
                          p_new_chr_id     IN  NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2)
IS
ctr 	                   NUMBER :=1;
l_scrv_tbl                 OKS_SALES_CREDIT_PUB.scrv_tbl_type;
x_scrv_tbl                 OKS_SALES_CREDIT_PUB.scrv_tbl_type;
l_return_status            Varchar2(1);
l_msg_count                Number;
l_msg_data                 Varchar2(2000);
l_api_version              Number := 1;
l_init_msg_list            Varchar2(1) := 'F';

CURSOR get_sales_credits_csr (p_cle_id NUMBER) IS
	   SELECT
		    percent,
                    chr_id,
                    ctc_id,
                    sales_group_id,
                    sales_credit_type_id1,
		    sales_credit_type_id2
	   FROM oks_k_sales_credits
	   WHERE cle_id = p_cle_id;

-- Added for dup sales credit bug
l_exist number;

       CURSOR sales_credit_exist_csr (p_new_cle_id NUMBER) IS
	   SELECT percent
	   FROM oks_k_sales_credits
	   WHERE cle_id = p_new_cle_id;
-------

BEGIN
l_return_status := OKC_API.G_RET_STS_SUCCESS;
 l_scrv_tbl.DELETE;
 x_scrv_tbl.DELETE;

	 --get sales credits record and copy
	FOR get_sales_credits_rec IN get_sales_credits_csr (p_cle_id)
	LOOP
         -- Don't add sales credit to a line that already has one.
        Open sales_credit_exist_csr(p_new_cle_id);
        Fetch sales_credit_exist_csr into l_exist;
        If sales_credit_exist_csr%NOTFOUND Then
         l_scrv_tbl(ctr).id                    := OKC_API.G_MISS_NUM;
	 l_scrv_tbl(ctr).chr_id                := p_new_chr_id;
	 l_scrv_tbl(ctr).cle_id                := p_new_cle_id;
	 l_scrv_tbl(ctr).percent               := get_sales_credits_rec.percent;
	 l_scrv_tbl(ctr).ctc_id                := get_sales_credits_rec.ctc_id;
	 l_scrv_tbl(ctr).sales_group_id := get_sales_credits_rec.sales_group_id;
	 l_scrv_tbl(ctr).sales_credit_type_id1 := get_sales_credits_rec.sales_credit_type_id1;
	 l_scrv_tbl(ctr).sales_credit_type_id2 := get_sales_credits_rec.sales_credit_type_id2;
	 l_scrv_tbl(ctr).object_version_number := OKC_API.G_MISS_NUM;
	 l_scrv_tbl(ctr).created_by            := OKC_API.G_MISS_NUM;
	 l_scrv_tbl(ctr).creation_date         := OKC_API.G_MISS_DATE;
	 l_scrv_tbl(ctr).last_updated_by       := OKC_API.G_MISS_NUM;
	 l_scrv_tbl(ctr).last_update_date      := OKC_API.G_MISS_DATE;
		    ctr := ctr+1;
        End If;
        Close sales_credit_exist_csr;

	END LOOP;


	   IF l_scrv_tbl.COUNT >0 	   THEN

		  OKS_SALES_CREDIT_PUB.insert_Sales_credit(
				p_api_version   => l_api_version,
	        	     x_return_status => l_return_status,
			     x_msg_count     => l_msg_count,
			          x_msg_data      => l_msg_data,
			          p_scrv_tbl      => l_scrv_tbl,
			          x_scrv_tbl      => x_scrv_tbl);

     END IF; --IF l_rev_tbl.COUNT >0

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

                      x_return_status := l_return_status;

  EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );


END copy_line_sales_credits;

/*
 * This procedure will copy the old item instance and it will instantiate a new
 * subscription template for each subscription line.
 *
*/
Procedure copy_subscr_inst(p_new_chr_id IN NUMBER,
                           p_cle_id	     IN NUMBER,
                           p_intent     IN VARCHAR2 DEFAULT NULL,
                           x_return_status OUT NOCOPY VARCHAR2) IS

l_api_version   NUMBER := 1.0;
l_init_msg_list	VARCHAR2(3)  :=OKC_API.G_FALSE;
l_return_status VARCHAR2(1) := 'S';
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_intent        VARCHAR2(90);
l_temp          number;
l_old_chr_id    number;
l_new_inst_id   number;
l_old_inst_id   number;
l_cimv_rec	OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
x_cimv_rec	OKC_CONTRACT_ITEM_PUB.cimv_rec_type;

Cursor get_subscr_toplines(p_new_chr_id IN NUMBER,
             p_cle_id IN NUMBER) IS
    SELECT id, NVL(orig_system_id1, cle_id_renewed) old_line_id
    FROM okc_k_lines_b
    WHERE dnz_chr_id = p_new_chr_id and lse_id = 46
    AND id=p_cle_id;

Cursor get_subscr_toplines_C(p_new_chr_id IN NUMBER
           ) IS
    SELECT id, NVL(orig_system_id1, cle_id_renewed) old_line_id
    FROM okc_k_lines_b
    WHERE dnz_chr_id = p_new_chr_id and lse_id = 46;



-- get original chr_id
Cursor get_old_chr_id IS
    SELECT orig_system_id1
    FROM okc_k_headers_b
    WHERE id = p_new_chr_id;

-- If the new_chrId is from a renewed contract this cursor will return a record.
-- It will not return any records if new_chrId is from a copied contract.
Cursor got_renewed(new_chrId number) IS
    SELECT subject_chr_id new_chr_id
    FROM okc_operation_lines
    WHERE subject_chr_id =new_chrId;

-- gets old and new item instance
Cursor get_item_instance(chrId number, cleId number) IS
    SELECT  b.instance_id
    FROM oks_subscr_header_b b
    WHERE b.dnz_chr_id = chrId and b.cle_id = cleId;

-- Gets the new covered lines that are covering the old item instance.
Cursor get_new_cps(oldItemInst number) IS
    SELECT b.id
    FROM okc_k_lines_b a, okc_k_items b
    WHERE b.cle_id = a.id and a.lse_id = 9 and b.object1_id1 = oldItemInst
    AND a.dnz_chr_id = p_new_chr_id;

Begin
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_intent := p_intent; --'RENEW' or NULL
    -- Renewed contracts have a record in okc_operation_lines
    If p_intent is null then
        open got_renewed(p_new_chr_id);
        Fetch got_renewed into l_temp;
        If got_renewed%NOTFOUND Then
          l_intent := 'COPY';
        End If;
        Close got_renewed;
     End If;
    -- First get all the new subscription top lines
    If l_intent is not null then
    IF P_cle_id is null then
    For new_topline_rec in get_subscr_toplines_c(p_new_chr_id) Loop
            -- The item instance will get copied
            -- a new subscription template will get instanciated.
            OKS_SUBSCRIPTION_PUB.copy_subscription(
                l_api_version,
                l_init_msg_list,
                l_return_status,
                l_msg_count,
                l_msg_data,
                new_topline_rec.old_line_id,
                new_topline_rec.id,
                l_intent
                );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            If l_intent = 'COPY' then
                Open get_old_chr_id;
                Fetch get_old_chr_id into l_old_chr_id;
                Close get_old_chr_id;
                Open get_item_instance(l_old_chr_id, new_topline_rec.old_line_id);
                Fetch get_item_instance into l_old_inst_id;
                Close get_item_instance;
                Open get_item_instance(p_new_chr_id, new_topline_rec.id);
                Fetch get_item_instance into l_new_inst_id;
                Close get_item_instance;
                If l_old_inst_id <> l_new_inst_id Then
                    For new_cp_rec in get_new_cps(l_old_inst_id) Loop
                        -- update the item instance in object1_id1 to l_new_item_ins
                        l_cimv_rec.id := new_cp_rec.id;
                        l_cimv_rec.object1_id1 := l_new_inst_id;
                        OKC_CONTRACT_ITEM_PUB.update_contract_item(l_api_version,
                              l_init_msg_list,
                              l_return_status,
                              l_msg_count,
                              l_msg_data,
                              l_cimv_rec,
                              x_cimv_rec);
                        if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        end if;
                    End Loop;

                End If; -- l_old_inst_id <> l_new_inst_id

            End if; -- l_intent = 'COPY'
          END Loop;

          ELSE
        For new_topline_rec in get_subscr_toplines(p_new_chr_id,p_cle_id) Loop
            -- The item instance will get copied
            -- a new subscription template will get instanciated.
            OKS_SUBSCRIPTION_PUB.copy_subscription(
                l_api_version,
                l_init_msg_list,
                l_return_status,
                l_msg_count,
                l_msg_data,
                new_topline_rec.old_line_id,
                new_topline_rec.id,
                l_intent
                );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            If l_intent = 'COPY' then
                Open get_old_chr_id;
                Fetch get_old_chr_id into l_old_chr_id;
                Close get_old_chr_id;
                Open get_item_instance(l_old_chr_id, new_topline_rec.old_line_id);
                Fetch get_item_instance into l_old_inst_id;
                Close get_item_instance;
                Open get_item_instance(p_new_chr_id, new_topline_rec.id);
                Fetch get_item_instance into l_new_inst_id;
                Close get_item_instance;
                If l_old_inst_id <> l_new_inst_id Then
                    For new_cp_rec in get_new_cps(l_old_inst_id) Loop
                        -- update the item instance in object1_id1 to l_new_item_ins
                        l_cimv_rec.id := new_cp_rec.id;
                        l_cimv_rec.object1_id1 := l_new_inst_id;
                        OKC_CONTRACT_ITEM_PUB.update_contract_item(l_api_version,
                              l_init_msg_list,
                              l_return_status,
                              l_msg_count,
                              l_msg_data,
                              l_cimv_rec,
                              x_cimv_rec);
                        if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        end if;
                    End Loop;

                End If; -- l_old_inst_id <> l_new_inst_id

            End if; -- l_intent = 'COPY'
          END Loop;
          END IF;
       End If;
    x_return_status := l_return_status;

    EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION	THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );

End;

-------------------------------------------------------------------------------
-- Procedure:           get_billing_attr
-- Purpose:             This procedure gets the billing schedule type
-- In Parameters:       p_chr_id           the contract id
--                      p_cle_id           line_id
--Out Parameters        x_billing_schedule_type   billing_sch_type
--                      x_inv_rule_id      Invoice Rule id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

PROCEDURE get_billing_attr
                 (p_chr_id                IN NUMBER,
                  p_cle_id	          IN NUMBER,
                  x_billing_schedule_type OUT NOCOPY VARCHAR2,
                  x_inv_rule_id           OUT NOCOPY VARCHAR2,
                  x_return_status         OUT NOCOPY VARCHAR2
                  )
IS
Cursor get_billing_info is
   SELECT okc.inv_rule_id,
          oks.billing_schedule_type
   FROM okc_k_lines_b okc,
        oks_k_lines_b oks
   WHERE okc.id=p_cle_id
   AND okc.id=oks.cle_id;

l_tbl_ctr	      NUMBER;
l_return_status       VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
l_msg_count           Number;
l_msg_data            Varchar2(2000);
l_api_version         Number := 1;
l_init_msg_list       Varchar2(1) := 'F';
l_billing_schedule_type	 VARCHAR2(30);
l_inv_rule_id         VARCHAR2(30);
Begin

    OPEN get_billing_info;
    FETCH get_billing_info INTO l_inv_rule_id,l_billing_schedule_type;
    CLOSE get_billing_info;

   x_billing_schedule_type:=l_billing_schedule_type;
   x_inv_rule_id:=l_inv_rule_id;
   x_return_status:='S';

END get_billing_attr;

FUNCTION set_flag(p_old_cle_id      IN NUMBER,
                  p_new_cle_id      IN NUMBER
                  )  RETURN VARCHAR2
                   IS

       l_flag varchar2(30);

       CURSOR get_orig_line_amount(l_orig_line_id number) is
       SELECT TRUNC(date_terminated) line_term_dt,
                       (nvl(line.price_negotiated,0) +nvl(dtl.ubt_amount,0) +
                       nvl(dtl.credit_amount,0) + nvl(dtl.suppressed_credit,0) ) line_amt
               FROM okc_k_lines_b line, oks_k_lines_b dtl
               WHERE  line.id = dtl.cle_id AND line.Id = l_orig_line_id;

       l_orig_line_rec      get_orig_line_amount%ROWTYPE;

       CURSOR get_price(l_new_line_id number) is
       select price_negotiated
       from okc_k_lines_b
       where id = l_new_line_id;

       l_new_price number;


Begin
    Open get_orig_line_amount(p_old_cle_id);
    Fetch get_orig_line_amount into l_orig_line_rec;
    Close get_orig_line_amount;


        Open get_price(p_new_cle_id);
        Fetch get_price into l_new_price;
        Close get_price;
        If NVL(l_new_price, 0) <> NVL(l_orig_line_rec.line_amt, 0) Then
            l_flag := '99';
        Else
            l_flag := null;
        End If;


    return l_flag;

End set_flag;
-------------------------------------------------------------------------------
-- Procedure:           get_strlvls
-- Purpose:             Build several records/tables that hold information to be
--                      used to pass to OC APIs
-- In Parameters:       p_chr_id            the contract id
--                      p_cle_id            line id
--                      x_strlvl_tbl        stream levels
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

PROCEDURE get_strlvls
                 (p_chr_id      IN NUMBER,
                  p_cle_id      IN NUMBER,
                  p_billsch_type IN VARCHAR2,
                  x_strlvl_tbl	OUT NOCOPY OKS_BILL_SCH.StreamLvl_tbl,
                  x_return_status   OUT NOCOPY VARCHAR2
                  )
IS


l_tbl_ctr             NUMBER;
l_return_status	      VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
l_msg_count           Number;
l_msg_data            Varchar2(2000);
l_api_version         Number := 1;
l_init_msg_list       Varchar2(1) := 'F';


l_bil_sch_out_tbl    OKS_BILL_SCH.ItemBillSch_tbl;
l_strlvl_tbl         OKS_BILL_SCH.StreamLvl_tbl;
l_klnv_tbl           oks_kln_pvt.klnv_tbl_type;
x_klnv_tbl           oks_kln_pvt.klnv_tbl_type;

CURSOR old_cle_csr(p_cle_id NUMBER) IS
       SELECT orig_system_id1
       FROM okc_k_lines_b
       WHERE id=p_cle_id;

CURSOR was_line_terminated(p_old_cle_id number) is
select date_terminated
from okc_k_lines_b
where id = p_old_cle_id ;

CURSOR strlvl_csr (p_cle_id NUMBER) IS
       SELECT   ID
                ,CHR_ID
                ,CLE_ID
                ,DNZ_CHR_ID
                ,SEQUENCE_NO
                ,UOM_CODE
                ,START_DATE
                ,END_DATE
                ,LEVEL_PERIODS
                ,UOM_PER_PERIOD
                ,ADVANCE_PERIODS
                ,LEVEL_AMOUNT
                ,INVOICE_OFFSET_DAYS
                ,INTERFACE_OFFSET_DAYS
                ,COMMENTS
                ,DUE_ARR_YN
                ,AMOUNT
                ,LINES_DETAILED_YN
       FROM     oks_stream_levels_b
       WHERE    cle_id=p_cle_id
       ORDER BY SEQUENCE_NO;/*BUG 7450286 */
       strlvl_rec  strlvl_csr%ROWTYPE;

     Cursor get_ccr(p_cle_id IN NUMBER) is
     SELECT
          id
          ,dnz_chr_id
          ,cc_no
          ,cc_expiry_date
          ,cc_bank_acct_id
          ,cc_auth_code
          ,object_version_number
     FROM oks_k_lines_b
     WHERE cle_id=p_cle_id;

     l_old_cle_id number;
     l_date_terminated date;

BEGIN

              OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
               p_perf_msg =>'Inside get_strlvls procedure ');

           l_return_status := OKC_API.G_RET_STS_SUCCESS;

               l_tbl_ctr := 0;
               l_strlvl_tbl.delete;
               l_bil_sch_out_tbl.delete;

                strlvl_rec.ID	                   :=NULL;
                strlvl_rec.CHR_ID	           :=NULL;
                strlvl_rec.CLE_ID	           :=NULL;
                strlvl_rec.DNZ_CHR_ID	           :=NULL;
                strlvl_rec.SEQUENCE_NO	           :=NULL;
                strlvl_rec.UOM_CODE	           :=NULL;
                strlvl_rec.START_DATE	           :=NULL;
                strlvl_rec.END_DATE	           :=NULL;
                strlvl_rec.LEVEL_PERIODS           :=NULL;
                strlvl_rec.UOM_PER_PERIOD          :=NULL;
                strlvl_rec.ADVANCE_PERIODS         :=NULL;
                strlvl_rec.LEVEL_AMOUNT	           :=NULL;
                strlvl_rec.INVOICE_OFFSET_DAYS	   :=NULL;
                strlvl_rec.INTERFACE_OFFSET_DAYS   :=NULL;
                strlvl_rec.COMMENTS	           :=NULL;
                strlvl_rec.DUE_ARR_YN	           :=NULL;
                strlvl_rec.AMOUNT	           :=NULL;
                strlvl_rec.LINES_DETAILED_YN	   :=NULL;

  OPEN old_cle_csr(p_cle_id);
  FETCH old_cle_csr INTO l_old_cle_id;
  CLOSE old_cle_csr;

 FOR strlvl_rec IN strlvl_csr (l_old_cle_id)
  LOOP
   l_tbl_ctr := l_tbl_ctr + 1;

   l_strlvl_tbl(l_tbl_ctr).id	              :=OKC_API.G_MISS_NUM;
   l_strlvl_tbl(l_tbl_ctr).CHR_ID	      :=OKC_API.G_MISS_NUM;
   l_strlvl_tbl(l_tbl_ctr).CLE_ID	      :=p_cle_id;
   l_strlvl_tbl(l_tbl_ctr).DNZ_CHR_ID	      :=P_CHR_ID;
   l_strlvl_tbl(l_tbl_ctr).SEQUENCE_NO	      :=strlvl_rec.SEQUENCE_NO;
   l_strlvl_tbl(l_tbl_ctr).UOM_CODE	      :=strlvl_rec.UOM_CODE;
   l_strlvl_tbl(l_tbl_ctr).START_DATE	      :=strlvl_rec.START_DATE;
   l_strlvl_tbl(l_tbl_ctr).END_DATE	      :=strlvl_rec.END_DATE;
   l_strlvl_tbl(l_tbl_ctr).LEVEL_PERIODS      :=strlvl_rec.LEVEL_PERIODS;
   l_strlvl_tbl(l_tbl_ctr).UOM_PER_PERIOD      :=strlvl_rec.UOM_PER_PERIOD;
   l_strlvl_tbl(l_tbl_ctr).ADVANCE_PERIODS    :=strlvl_rec.ADVANCE_PERIODS;
   l_strlvl_tbl(l_tbl_ctr).LEVEL_AMOUNT	      :=strlvl_rec.LEVEL_AMOUNT;
   l_strlvl_tbl(l_tbl_ctr).INVOICE_OFFSET_DAYS :=strlvl_rec.INVOICE_OFFSET_DAYS;
   l_strlvl_tbl(l_tbl_ctr).INTERFACE_OFFSET_DAYS :=strlvl_rec.INTERFACE_OFFSET_DAYS;
   l_strlvl_tbl(l_tbl_ctr).COMMENTS	      :=strlvl_rec.COMMENTS;
   l_strlvl_tbl(l_tbl_ctr).DUE_ARR_YN	      :=strlvl_rec.DUE_ARR_YN;
   l_strlvl_tbl(l_tbl_ctr).AMOUNT	      :=strlvl_rec.AMOUNT;
   l_strlvl_tbl(l_tbl_ctr).LINES_DETAILED_YN  :=strlvl_rec.LINES_DETAILED_YN;
   -------- Added for bug
   If p_billsch_type in ('E', 'P') Then
            l_strlvl_tbl(l_tbl_ctr).comments := set_flag(l_old_cle_id, p_cle_id);
   End If;
   -------------

 END LOOP;

  x_strlvl_tbl  := l_strlvl_tbl;

         OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
               p_perf_msg =>'Building Stream Levels Successful ');

   For get_ccr_rec In get_ccr(p_cle_id)
    Loop
   IF get_ccr_rec.cc_bank_acct_id is not null then
   l_klnv_tbl(1).id := get_ccr_rec.id;
   l_klnv_tbl(1).dnz_chr_id := get_ccr_rec.dnz_chr_id;
   l_klnv_tbl(1).CC_BANK_ACCT_ID   :=NULL;
   l_klnv_tbl(1).CC_AUTH_CODE	    :=NULL;
   l_klnv_tbl(1).object_version_number := get_ccr_rec.object_version_number;
   l_klnv_tbl(1).CREATED_BY            :=OKC_API.G_MISS_NUM;
   l_klnv_tbl(1).CREATION_DATE         :=OKC_API.G_MISS_DATE;
   l_klnv_tbl(1).LAST_UPDATED_BY       :=OKC_API.G_MISS_NUM;
   l_klnv_tbl(1).LAST_UPDATE_DATE      :=OKC_API.G_MISS_DATE;
   l_klnv_tbl(1).LAST_UPDATE_LOGIN     :=OKC_API.G_MISS_NUM;

          OKS_CONTRACT_LINE_PUB.update_line (
            p_api_version     => l_api_version,
            p_init_msg_list   => OKC_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data,
            p_klnv_tbl        => l_klnv_tbl,
            x_klnv_tbl        => x_klnv_tbl,
            p_validate_yn     => 'N');
   END IF;
     End Loop; --For get_line_id_rec In get_line_id_csr

        OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
               p_perf_msg =>'After Update CCR Rule ');

     x_return_status := l_return_status;

END get_strlvls;

-------------------------------------------------------------------------------
-- Procedure:           sub_copy
-- Purpose:             This procedure creates the sublines for the toplines
--                      copied,copies the subline revenue distribution
--                      creates the billing schedule for the top lines which
--                      in turn creates the billing schedule for the sublines
--                      also
-- In Parameters:       p_chr_id            the contract id
-- In Parameters:       p_cle_id            line id
-- In Parameters:       p_start_date        start Date
-- In Parameters:       p_upd_line_flag     flag to check where the call is m
--                      made from renew or copy
-- In Parameters:       p_billing_schedule_type line billing schedule type
-- In Parameters:       p_duration_match     flag to check copied/renewed
--                      contract duration
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

PROCEDURE sub_copy
                 (
                 p_chr_id          IN	NUMBER,
                 p_cle_id          IN	NUMBER,
                 p_start_date	   IN	DATE,
                 p_upd_line_flag   IN   Varchar2,
                 p_billing_schedule_type IN VARCHAR2,
                 p_duration_match         IN   Varchar2,
                 p_bill_profile_flag IN   Varchar2,
                 p_do_copy          IN boolean,
                 x_return_status	OUT	NOCOPY VARCHAR2
                 )
IS

l_msg_count                Number;
l_msg_data                 Varchar2(2000);
l_api_version              Number := 1;
l_init_msg_list            Varchar2(1) := 'F';
l_return_status		   VARCHAR2(1);
l_adv_arr		   VARCHAR2(40);
l_invoice_rule_id	   NUMBER;
l_tbl_ctr		   NUMBER;
l_time_value		   NUMBER;
l_billing_type             VARCHAR2(3);

--tbl type

l_SLL_tbl_type      OKS_BILL_SCH.StreamLvl_tbl;
l_bil_sch_out_tbl   OKS_BILL_SCH.ItemBillSch_tbl;
l_strlvl_tbl        OKS_BILL_SCH.StreamLvl_tbl;

--Sub Lines information

CURSOR sub_line_grp_csr (p_chr_id NUMBER,p_cle_id NUMBER) IS
       SELECT
		lines.id,
        lines.start_date,lines.dnz_chr_id,lines.orig_system_id1
       FROM 	okc_k_lines_b lines
       WHERE	lines.dnz_chr_id = p_chr_id
       AND	lines.cle_id = p_cle_id
       AND	lines.lse_id in (7,8,9,10,11,13,18,25,35);

CURSOR get_adv_arr_csr (p_cle_id NUMBER) IS
       SELECT inv_rule_id,cle_id
       FROM  okc_k_lines_b
       WHERE id=p_cle_id;

CURSOR Subline_Billsch_type(p_cle_id  NUMBER) IS
       SELECT Billing_schedule_type
       FROM oks_k_lines_b
       WHERE cle_id =p_cle_id;

l_subline_billsch_type Varchar2(30);
l_price_negotiated NUMBER;
BEGIN

   l_invoice_rule_id := NULL;
   l_time_value      :=NULL;

       l_return_status := OKC_API.G_RET_STS_SUCCESS;

       FOR get_adv_arr_rec IN get_adv_arr_csr (p_cle_id)
       LOOP
           l_invoice_rule_id := get_adv_arr_rec.inv_rule_id;
         --   l_adv_arr:=-2;
             --commented out for the reason when billing_sch is not there
             -- inv_rule_is is null in okc_k_lines table
       END LOOP;


        FOR sub_line_grp_rec IN sub_line_grp_csr (p_chr_id,p_cle_id)
        LOOP
         --IF (p_upd_line_flag IS NULL) THEN

              copy_lines_attr
               (p_cle_id         => sub_line_grp_rec.orig_system_id1,
                p_new_cle_id      => sub_line_grp_rec.id,
                p_new_chr_id      => sub_line_grp_rec.dnz_chr_id,
                p_do_copy         => p_do_copy,
                x_return_status => l_return_status);

               OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'SubLine copy_lines_attr Status '||l_return_status);

           IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
           copy_revenue_distb
            (p_cle_id        => sub_line_grp_rec.orig_system_id1,
    	     p_new_cle_id    => sub_line_grp_rec.id,
             p_new_chr_id    => sub_line_grp_rec.dnz_chr_id,
             x_return_status => l_return_status);

            END IF;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'SubLine copy_revenue_distb Status'||l_return_status);
             x_return_status := l_return_status;


       OPEN  Subline_Billsch_type(sub_line_grp_rec.id);
       FETCH Subline_Billsch_type INTO l_subline_billsch_type;
       CLOSE Subline_Billsch_type;

    IF l_subline_billsch_type ='P' THEN
     l_return_status := OKC_API.G_RET_STS_SUCCESS;
     If p_duration_match = 'T' and p_bill_profile_flag is null Then

       get_strlvls
           (p_chr_id        => p_chr_id,
           p_cle_id         => sub_line_grp_rec.id,
           p_billsch_type => l_subline_billsch_type,
           x_strlvl_tbl     => l_strlvl_tbl,
           x_return_status  => l_return_status
          );

     IF l_return_status = 'S' and l_strlvl_tbl.count > 0 THEN

                           -- Call bill API
        oks_bill_sch.create_bill_sch_rules
          (
           p_billing_type    => l_subline_billsch_type,
           p_sll_tbl         => l_strlvl_tbl,
           p_invoice_rule_id => l_invoice_rule_id,
           x_bil_sch_out_tbl => l_bil_sch_out_tbl,
           x_return_status   =>l_return_status);



            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'P SubLine Billing Schedule Creation Status '||l_return_status);

     END IF; --l_return_status = 'S'
    END IF;
    END IF; -- IF sub_line_grp_rec.billing_schedule_type = 'P'



   END LOOP; --FOR sub_line_grp_rec IN sub_line_grp_csr (p_chr_id,p_cle_id)


    IF p_upd_line_flag IS NULL and p_chr_id is not null THEN
     UPDATE okc_k_lines_b set
     price_negotiated = (SELECT sum(price_negotiated) FROM okc_k_lines_b
                        WHERE dnz_chr_id = p_chr_id AND chr_id is null
                        AND cle_id = p_cle_id)
      WHERE lse_id in (1, 19, 12) -- added 12 in the IN clause for bug # 3534513
      AND chr_id = p_chr_id and id = p_cle_id;
    END IF;

  If p_duration_match = 'T' and p_bill_profile_flag is null Then
   -- fix for bug # 3387603
   If l_subline_billsch_type is null Then
       OPEN  Subline_Billsch_type(p_cle_id);
       FETCH Subline_Billsch_type INTO l_subline_billsch_type;
       CLOSE Subline_Billsch_type;
   End If;
   --------------
   get_strlvls
               (p_chr_id        => p_chr_id,
                p_cle_id        => p_cle_id,
                p_billsch_type => l_subline_billsch_type,
                x_strlvl_tbl    => l_strlvl_tbl,
                x_return_status => l_return_status
                );


        --Calls API for level element creation
	   --This take care covered level of 'E' and 'T as well

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY',
               p_perf_msg =>'Before Creating Billing Schedule');


     ---  IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN

       IF l_strlvl_tbl.COUNT > 0   THEN

               -- Call bill API
                   oks_bill_sch.create_bill_sch_rules
                   (
                    p_billing_type    => p_billing_schedule_type,
                    p_sll_tbl         => l_strlvl_tbl,
                    p_invoice_rule_id => l_invoice_rule_id,
                    x_bil_sch_out_tbl => l_bil_sch_out_tbl,
                    x_return_status   => l_return_status);
      END IF;--l_SLL_tbl_type.COUNT > 0

  --    END IF;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Billing Schedule Creation Status '||l_return_status);

        END IF;

END sub_copy;

-------------------------------------------------------------------------------
-- Procedure:           chk_Sll_Exists
-- Purpose:             This function call checks if Stream Levels exist for
--                      the line id passed or not
-- In Parameters:       p_cle_id           the line id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

FUNCTION chk_Sll_Exists(p_cle_id IN NUMBER) return number IS

CURSOR l_sll_csr(p_cle_id NUMBER) IS
       SELECT count(*)
       FROM oks_stream_levels_b
       WHERE cle_ID = p_cle_id;

l_sll_rec    l_sll_csr%ROWTYPE;
l_sll_count  NUMBER;

BEGIN

    OPEN l_sll_csr(p_cle_id);
    FETCH l_sll_csr INTO l_sll_count;

    IF l_sll_csr%NOTFOUND THEN
      CLOSE l_sll_csr;
      l_sll_count:=0;
      return(l_sll_count);
    ELSE
      CLOSE l_sll_csr;
      return(l_sll_count);
    END IF;
  END ;

-------------------------------------------------------------------------------
-- Function :           chk_topline_Exists
-- Purpose:             This function checks if the topline already exist in
--                      oks table to avoid the duplicacy
-- In Parameters:       p_cle_id           the line id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

FUNCTION chk_topline_Exists(p_cle_id IN NUMBER) return number IS

CURSOR l_topline_csr(p_cle_id NUMBER) IS
    SELECT count(*)  from oks_k_lines_b
    WHERE cle_id = p_cle_id;

l_topline_count  NUMBER;

BEGIN

    OPEN l_topline_csr(p_cle_id);
    FETCH l_topline_csr INTO l_topline_count;

    IF l_topline_csr%NOTFOUND THEN
      CLOSE l_topline_csr;
      return(null);
    ELSE
      CLOSE l_topline_csr;
      return(l_topline_count);
    END IF;
  END ;

-------------------------------------------------------------------------------
-- Procedure:           chk_hdr_effectivity
-- Purpose:             This procedure checks the effectivity dates of old
--                      contract and the new copied contract
-- In Parameters:       p_new_chr_id        new contract id
-- Out Parameters:      x_return_status     standard return status
--                      x_flag              yes no flag
-----------------------------------------------------------------------------

PROCEDURE chk_hdr_effectivity
(
p_new_chr_id 	      IN NUMBER,
x_flag                OUT NOCOPY VARCHAR2,
x_return_status       OUT NOCOPY VARCHAR2
)
IS

CURSOR l_chr_renew_csr (l_new_chr_id NUMBER) IS
       SELECT start_date,end_date,orig_system_id1
       FROM   okc_k_headers_b
       WHERE  id = l_new_chr_id;

l_chr_renew_rec    l_chr_renew_csr%ROWTYPE;

CURSOR l_chr_old_csr (l_old_chr_id NUMBER) IS
       SELECT start_date,end_date
       FROM   okc_k_headers_b
       WHERE  id = l_old_chr_id;


l_chr_old_rec    l_chr_old_csr%ROWTYPE;
l_old_chr_id               NUMBER;
l_old_duration		   NUMBER := 0;
l_old_time  	 	   VARCHAR2(450) ;
l_renew_duration	   NUMBER := 0;
l_renew_time  	 	   VARCHAR2(450) ;
l_return_status 	   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
                    x_flag   := 'T';
                    OPEN l_chr_renew_csr (p_new_chr_id);
                    FETCH l_chr_renew_csr INTO l_chr_renew_rec;
                    CLOSE l_chr_renew_csr;

                    l_old_chr_id := l_chr_renew_rec.orig_system_id1;
                    -- Added for bug # 4066428
                    If l_old_chr_id is null Then
                        x_return_status := l_return_status;
                        oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',
                        p_perf_msg   => 'Exiting chk_hdr_effectivity because orig_system_id1 was null');
                        return;
                    End If;
                    -- End of add for bug # 4066428
                    oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',
                    p_perf_msg   => 'l_old_chr_id ' || l_old_chr_id);


                    OPEN l_chr_old_csr(l_old_chr_id);
                    FETCH l_chr_old_csr INTO l_chr_old_rec;
                    CLOSE l_chr_old_csr;

                  oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'old start date  ' || l_chr_old_rec.start_date);
                  oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'old end date  ' || l_chr_old_rec.end_date);
                    OKC_TIME_UTIL_PUB.get_duration(
                                  l_chr_old_rec.start_date
                                  ,l_chr_old_rec.end_date
                                  ,l_old_duration
                                  ,l_old_time
                                  ,l_return_status
			        );
           oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'l_old_duration ' || l_old_duration);
           oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'l_old_time ' || l_old_time);
           oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'l_return_status ' || l_return_status);
                    IF l_return_status = 'S' Then
                   oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'new start date  ' || l_chr_renew_rec.start_date);
                  oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'new end date  ' || l_chr_renew_rec.end_date);

                         OKC_TIME_UTIL_PUB.get_duration(
                                  l_chr_renew_rec.start_date
                                  ,l_chr_renew_rec.end_date
                                  ,l_renew_duration
                                  ,l_renew_time
                                  ,l_return_status
			              );
           oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'l_new_duration ' || l_renew_duration);
           oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'l_renew_time ' || l_renew_time);
           oks_renew_pvt.Debug_Log(p_program_name => 'OKSCOPY',p_perf_msg   => 'l_return_status ' || l_return_status);

                          IF l_return_status = 'S'
                          THEN
                               IF ((l_old_duration <> l_renew_duration) OR
                                   (l_old_time <> l_renew_time))
                               THEN
                                    x_flag := 'F';
                                ELSE
                                    x_flag := 'T';
                               END IF; -- IF ((l_old_duration <> l_renew_duration) OR
                          END IF;
                    END IF;
                    x_return_status := l_return_status;
    Exception
        WHEN  Others  THEN
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  OKC_API.set_message(
                                    G_APP_NAME,
                                    G_UNEXPECTED_ERROR,
                                    G_SQLCODE_TOKEN,
                                    SQLCODE,
			            G_SQLERRM_TOKEN,
                                    SQLERRM
                                    );

END chk_hdr_effectivity;



Procedure Party_cleanup
                       (p_chr_id         IN  Number,
                        x_return_status  OUT NOCOPY Varchar2)
IS
 l_return_status              Varchar2(1);
 l_msg_count                  Number;
 l_msg_data                   Varchar2(2000);
 l_api_version                Number := 1;
 l_init_msg_list              Varchar2(1) := 'F';

Cursor get_qto(p_chr_id IN NUMBER) is
  select
   id
  ,chr_id
  ,quote_to_contact_id
  ,quote_to_site_id
  ,quote_to_email_id
  ,quote_to_phone_id
  ,quote_to_fax_id
  ,object_version_number
  from oks_k_headers_b
  where chr_id=p_chr_id;

CURSOR get_toplines(p_chr_id number) IS
       SELECT id,object_version_number
       FROM OKC_K_LINES_B
       WHERE chr_id = p_chr_id
       AND lse_id IN (1,12,19,46);

CURSOR get_okstoplines(p_cle_id NUMBER) IS
  SELECT id,object_version_number
  FROM OKS_k_LINES_B
  WHERE cle_id = p_cle_id;

CURSOR get_cpl(p_chr_id number) IS
       SELECT id
       FROM okc_k_party_roles_b
       WHERE dnz_chr_id = p_chr_id
       AND cle_id is not null
       AND rle_code in ('CUSTOMER','SUBSCRIBER');

Cursor get_contacts(p_cpl_id number)IS
       SELECT  id
       FROM    Okc_contacts
       WHERE   cpl_id = p_cpl_id;

get_topline_rec  get_toplines%Rowtype;
--get_qto_rec    get_qto%rowtype;
get_cpl_rec      get_cpl%rowtype;
l_khrv_tbl       oks_khr_pvt.khrv_tbl_type;
x_khrv_tbl       oks_khr_pvt.khrv_tbl_type;
l_error_tbl      okc_api.error_tbl_type;
l_chrv_tbl_in    okc_contract_pub.chrv_tbl_type;
l_chrv_tbl_out   okc_contract_pub.chrv_tbl_type;
l_clev_rec_in    okc_contract_pub.clev_rec_type;
l_clev_rec_out   okc_contract_pub.clev_rec_type;
l_ctcv_tbl_in    okc_contract_party_pub.ctcv_tbl_type;
l_ctcv_tbl_out   okc_contract_party_pub.ctcv_tbl_type;
l_kln_rec_in     oks_contract_line_pub.klnv_rec_type;
l_kln_rec_out    oks_contract_line_pub.klnv_rec_type;
l_cpl_id         NUMBER;
l_contact_id     NUMBER;

Begin
l_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_chrv_tbl_in(1).id		                := p_chr_id;
    l_chrv_tbl_in(1).cust_acct_id	        := NULL;
    l_chrv_tbl_in(1).Bill_to_site_use_id	:= NULL;
    l_chrv_tbl_in(1).ship_to_site_use_id	:= NULL;
    l_chrv_tbl_in(1).cust_po_number     	:= NULL;
    l_chrv_tbl_in(1).cust_po_number_req_yn     	:= NULL;

    	okc_contract_pub.update_contract_header
    	(
    		p_api_version	=> l_api_version,
    		p_init_msg_list	=> l_init_msg_list,
    		x_return_status	=> l_return_status,
    		x_msg_count	=> l_msg_count,
    		x_msg_data	=> l_msg_data,
    		p_chrv_tbl	=> l_chrv_tbl_in,
    		x_chrv_tbl	=> l_chrv_tbl_out
      );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


For get_qto_rec In get_qto(p_chr_id)
Loop


 l_khrv_tbl.delete;

 l_khrv_tbl(1).id                    :=get_qto_rec.id;
 l_khrv_tbl(1).chr_id                :=get_qto_rec.chr_id;
 l_khrv_tbl(1).quote_to_contact_id   :=NULL;
 l_khrv_tbl(1).quote_to_site_id      :=NULL;
 l_khrv_tbl(1).quote_to_email_id     :=NULL;
 l_khrv_tbl(1).quote_to_phone_id     :=NULL;
 l_khrv_tbl(1).quote_to_fax_id       :=NULL;
 l_khrv_tbl(1).commitment_id         :=NULL;
 l_khrv_tbl(1).payment_type          :=NULL;
 l_khrv_tbl(1).service_po_number     :=NULL;
 l_khrv_tbl(1).service_po_required   :=NULL;
 l_khrv_tbl(1).renewal_po_number     :=NULL;
 l_khrv_tbl(1).renewal_po_required   :=NULL;
 l_khrv_tbl(1).renewal_po_used       :=NULL;
 l_khrv_tbl(1).OBJECT_VERSION_NUMBER :=get_qto_rec.OBJECT_VERSION_NUMBER;
 l_khrv_tbl(1).CREATED_BY            :=OKC_API.G_MISS_NUM;
 l_khrv_tbl(1).CREATION_DATE         :=OKC_API.G_MISS_DATE;
 l_khrv_tbl(1).LAST_UPDATED_BY       :=OKC_API.G_MISS_NUM;
 l_khrv_tbl(1).LAST_UPDATE_DATE      :=OKC_API.G_MISS_DATE;
 l_khrv_tbl(1).LAST_UPDATE_LOGIN     :=OKC_API.G_MISS_NUM;

        OKS_CONTRACT_HDR_PUB.update_header (
         p_api_version                  => l_api_version,
         p_init_msg_list                => OKC_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => l_msg_count,
         x_msg_data                     => l_msg_data,
         p_khrv_tbl                     => l_khrv_tbl,
         x_khrv_tbl                     => x_khrv_tbl,
         p_validate_yn                   => 'N');

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

End Loop; --For get_qto

    x_return_status := l_return_status;

    For get_TOPLINEs_rec In get_toplines(p_chr_id)
     LOOP
     l_clev_rec_in.id                   := get_toplines_rec.id;
     l_clev_rec_in.object_version_number:= get_toplines_rec.object_version_number;
     l_clev_rec_in.cust_acct_id	        := NULL;
     l_clev_rec_in.Bill_to_site_use_id	:= NULL;
     l_clev_rec_in.ship_to_site_use_id	:= NULL;

   OKC_CONTRACT_PUB.UPDATE_CONTRACT_LINE (
                            p_api_version        => l_api_version,
                            p_init_msg_list      => l_init_msg_list,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_clev_rec           => l_clev_rec_in,
                            x_clev_rec           => l_clev_rec_out
                       );
     For get_okstoplines_rec In get_okstoplines(get_toplines_rec.id)

     Loop
    --  errorout('oks_line id ='|| get_okstoplines_rec.id);
      l_kln_rec_in.id                   := get_okstoplines_rec.id;
      l_kln_rec_in.object_version_number:= get_okstoplines_rec.object_version_number;
      l_kln_rec_in.commitment_id        := NULL;
      l_kln_rec_in.cust_po_number       := NULL;
      l_kln_rec_in.cust_po_number_req_yn:= NULL;
      l_kln_rec_in.payment_type         := NULL;

      OKS_CONTRACT_LINE_PUB.UPDATE_LINE(
                               p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => x_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_klnv_rec        => l_kln_rec_in,
                               x_klnv_rec        => l_kln_rec_out,
                               p_validate_yn     => 'N'
                           );
   --  errorout('COPY update line status='||x_return_status);
     END LOOP;

     END LOOP;

     OPEN get_cpl(p_chr_id);
     FETCH get_cpl INTO l_cpl_id;
     CLOSE get_cpl;
           OPEN get_contacts(l_cpl_id);
           FETCH get_contacts into l_contact_id;

           IF get_contacts%found Then
           ClOSE get_contacts;

             l_ctcv_tbl_in(1).id            := l_contact_id;

               Okc_contract_party_pub.delete_contact
                                    (
                          p_api_version          => 1,
                          p_init_msg_list        => 'F',
                       	  x_return_status      => l_return_status,
                       	  x_msg_count          => l_msg_count,
                      	  x_msg_data           => l_msg_data,
                       	  p_ctcv_tbl           => l_ctcv_tbl_in
                                    );
          END IF;

 EXCEPTION
         WHEN  G_EXCEPTION_HALT_VALIDATION      THEN
              x_return_status := l_return_status;
         WHEN  Others  THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );


End Party_cleanup;
-------------------------------------------------------------------------------
-- Procedure:          okscopy
-- Purpose:            copy procedure to be called from renew and copy forms
--                     and this copies header, topline and subline details
--                     It also updates the line numbers for the sublines copied
--                     It instantiates the coverage and subcription also
-- In Parameters:       p_chr_id           contract id
--                      p_cle_id           ine id
--                      p_upd_line_flag    upd_line_flag
--                      p_bill_profile_flag the line id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------


Procedure Okscopy
             ( p_chr_id NUMBER,
               p_cle_id NUMBER,
               x_return_status OUT NOCOPY VARCHAR2,
               p_upd_line_flag VARCHAR2,
               p_bill_profile_flag IN VARCHAR2 DEFAULT NULL
              ) IS

l_return_status     VARCHAR2(1) :=OKC_API.G_RET_STS_SUCCESS;
l_api_version       CONSTANT	NUMBER     := 1.0;
l_init_msg_list     CONSTANT	VARCHAR2(1):= 'F';
l_msg_count	    NUMBER;
l_msg_data	    VARCHAR2(2000):=null;
l_old_cle_id        NUMBER;
l_count             NUMBER;
l_SLL_tbl_type      OKS_BILL_SCH.StreamLvl_tbl;
l_bil_sch_out_tbl   OKS_BILL_SCH.ItemBillSch_tbl;
l_strlvl_tbl        OKS_BILL_SCH.StreamLvl_tbl;
l_ste_code	    VARCHAR2(30);
l_old_chr_id number;


CURSOR csr_top_lines(p_chr_id number) IS
       SELECT ID FROM OKC_K_LINES_B
       WHERE CHR_ID = P_CHR_ID AND LSE_ID IN (1,12,19,46);

CURSOR hdr_top_line_grp_csr (p_chr_id NUMBER) IS
       SELECT
	    lines.id,
            lines.start_date,
            lines.orig_system_id1,
            lines.dnz_chr_id,
            lines.lse_id
       FROM  okc_k_lines_b lines
       WHERE lines.dnz_chr_id = p_chr_id
       AND   lines.cle_id IS NULL
       AND   lines.lse_id IN (1,12,19, 46)
       ORDER BY lines.id;

CURSOR check_top_line_exist_csr (p_chr_id NUMBER) IS
       SELECT
	    lines.id,
            lines.start_date,
            lines.orig_system_id1,
            lines.dnz_chr_id,
            lines.lse_id,
            price_list_id
       FROM  okc_k_lines_b lines
       WHERE lines.dnz_chr_id = p_chr_id
       AND	lines.cle_id IS NULL
       AND	lines.lse_id IN (1,12,19, 46)
       ORDER BY lines.id;

CURSOR cle_grp_csr (p_chr_id NUMBER,p_cle_id NUMBER) IS
       SELECT
                lines.id,
                lines.start_date,
                lines.orig_system_id1,
                lines.dnz_chr_id,
                lines.lse_id
       FROM     okc_k_lines_b lines
       WHERE    lines.dnz_chr_id = p_chr_id
       AND      lines.id = p_cle_id
       AND      lines.lse_id IN (1,12,19, 46,7,8,9,10,11,35,13,18,25)
       ORDER BY lines.id;
/*
CURSOR Hdr_Billsch_type(p_chr_id  NUMBER) IS
       SELECT billing_schedule_type
       FROM oks_k_headers_b
       where chr_id =p_chr_id;
*/
-- Added for price lock project.
CURSOR get_lines_attr_csr (p_cle_id NUMBER) IS
       SELECT *
       FROM oks_k_lines_b
       WHERE cle_id = p_cle_id
       and (LOCKED_PRICE_LIST_ID is not null or
       LOCKED_PRICE_LIST_LINE_ID is not null);

cursor get_price_list(l_cle_id number) is
select PRICE_LIST_ID
from okc_k_lines_b
where id = l_cle_id;

CURSOR get_all_lines_csr (p_chr_id NUMBER) IS
       SELECT
                lines.id,
                lines.start_date,
                lines.orig_system_id1,
                lines.dnz_chr_id,
                lines.lse_id,
                lines.price_list_id
       FROM     okc_k_lines_b lines
       WHERE    lines.dnz_chr_id = p_chr_id
       AND      lines.lse_id IN (12,13);

cursor get_contract_number(l_chr_id number) is
select contract_number
from okc_k_headers_b
where id = l_chr_id;

-- End added for price lock project

CURSOR line_Billsch_type(p_cle_id  NUMBER) IS
       SELECT Billing_schedule_type
       FROM oks_k_lines_b
       WHERE cle_id =p_cle_id;


CURSOR get_item_csr (p_cle_id NUMBER) IS
       SELECT COUNT(id) cnt
       FROM   okc_k_items
       WHERE  cle_id = p_cle_id;
get_item_rec   get_item_csr%ROWTYPE;

/*
CURSOR get_old_chr_id_csr (p_chr_id NUMBER) IS
      SELECT   orig_system_id1
      FROM     okc_k_headers_b
      WHERE    id = p_chr_id;
*/
CURSOR get_status_csr (l_chr_id NUMBER) IS
      SELECT   b.ste_code, orig_system_id1
      FROM     okc_k_headers_b a, okc_statuses_b b
      WHERE    a.id = l_chr_id
      and a.sts_code = b.code;


-- Get all top lines
/*
CURSOR get_top_lines(P_CHR_ID IN NUMBER) IS
     SELECT id
     FROM okc_k_lines_b
     WHERE chr_id = p_chr_id
     AND cle_id is null;
*/

--get_old_chr_id_rec   get_old_chr_id_csr%ROWTYPE;

Cursor got_renewed(l_new_chr_id number) IS
    SELECT object_chr_id old_chr_id
    FROM okc_operation_lines
    WHERE subject_chr_id =l_new_chr_id and object_chr_id is not null;

Cursor is_terminated(l_old_chr_id number) IS
select line_number
from okc_k_lines_b
where dnz_chr_id = l_old_chr_id
and date_terminated is not null;

cursor cur_pradj (p_chr_id NUMBEr) is
select chr_id,cle_id
from okc_price_adjustments
where chr_id =p_chr_id
and cle_id is not null;

cursor is_line_copy(l_new_chr_id number, l_old_chr_id number) is
select id from okc_k_lines_b
where dnz_chr_id = l_new_chr_id and
orig_system_id1 not in (select id from okc_k_lines_b where dnz_chr_id = l_old_chr_id);

l_oldchr_id                   NUMBER;
l_duration_match              VARCHAR2(1) := 'F';
l_billing_schedule_type       VARCHAR2(30);
l_inv_rule_id                 NUMBER;
l_hdr_billsch_type            VARCHAR2(30);
l_line_billsch_type           VARCHAR2(30);
l_sll_count                   NUMBER;
l_topline_count               NUMBER;

l_do_copy boolean;
l_second_call boolean := false;
l_line_num  number;
l_update_top_line boolean;
l_okc_hdr_tbl                   OKC_CONTRACT_PUB.chrv_tbl_type;
x_okc_hdr_tbl                   OKC_CONTRACT_PUB.chrv_tbl_type;
l_line_id   number;
-- Added for price lock project
l_contract_number   VARCHAR2(120);
l_old_price_list_id number;
l_locked_price_list_id number;
l_locked_price_list_line_id number;
l_line_attr_rec  get_lines_attr_csr%ROWTYPE;
l_oks_line_id number;
-- End price lock project
--This proc call for chr copy


-- 05-Aug-2005 hkamdar Added for R12 Partial Period Project
-- This cursor fetches the Contract Id belonging to Original contract
CURSOR get_old_id_csr (p_new_chr_id NUMBER) IS
SELECT orig_system_id1
FROM   okc_k_headers_b
WHERE  id = p_new_chr_id;

-- New Variables
l_new_period_type  OKS_K_HEADERS_B.period_type%TYPE;
l_new_period_start OKS_K_HEADERS_B.period_start%TYPE;
l_old_period_type  OKS_K_HEADERS_B.period_type%TYPE;
l_old_period_start OKS_K_HEADERS_B.period_start%TYPE;
l_price_uom        OKS_K_HEADERS_B.price_uom%TYPE;
l_period_start_equal VARCHAR2(1) := 'Y';

-- End for partial periods --

--begin Okscopy procedure
BEGIN

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'OKSCOPY: start time= '||to_char(sysdate,'HH:MI:SS'));
   -- initialize return status
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   -- mk start
   -- The reason for this logic is that okscopy gets called twice for renew
   -- the first time, the new start date/end date of the contract header is
   -- not updated; therefore, we can't check to see if the contract duration is
   -- the same as original.
   l_do_copy := true;
   IF p_chr_id IS NOT NULL Then
        If p_upd_line_flag is null then
            -- If old chr id  found it means the contract is getting renewed.
            Open got_renewed(p_chr_id);
            Fetch got_renewed into l_oldchr_id;
            If got_renewed%NOTFOUND Then
                l_duration_match := 'T'; -- The contract is being copied therefore the duration matches.
                l_do_copy := true;
                 OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'copy is true= '||to_char(sysdate,'HH:MI:SS'));
            Else
                -- Check if any line belongs to another contract then it's
                -- a line copy function on a renewed contract
                Open is_line_copy(p_chr_id, l_oldchr_id);
                Fetch is_line_copy into l_line_id;
                If is_line_copy%FOUND Then
                    l_duration_match := 'T'; -- The contract is being copied therefore the duration matches.
                    l_do_copy := true;
                    OKS_RENEW_PVT.Debug_Log
                (p_program_name => 'OKSCOPY'
                ,p_perf_msg =>'copy is true2= '||to_char(sysdate,'HH:MI:SS'));
                Else
                    l_duration_match := 'F';
                    l_do_copy := false;
                   OKS_RENEW_PVT.Debug_Log
                    (p_program_name => 'OKSCOPY'
                    ,p_perf_msg =>'copy is false 1= '||to_char(sysdate,'HH:MI:SS'));
                End If;
                Close is_line_copy;
            End If;
            Close got_renewed;
        Else
            l_do_copy := false;
            l_second_call := true;
               OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'copy is false2 = '||to_char(sysdate,'HH:MI:SS'));
            chk_hdr_effectivity(
                       p_chr_id,
                       l_duration_match,
                       l_return_status
                      );

            IF l_return_status <> 'S' Then
                        OKC_API.set_message
                                        (G_APP_NAME,
                                         G_UNEXPECTED_ERROR,
                                         G_SQLCODE_TOKEN,
                                         SQLCODE,
                                         G_SQLERRM_TOKEN,
                                         'Check Header Effectivity ERROR');

                         RAISE G_EXCEPTION_HALT_VALIDATION;
            End If;
        End If;

    -- 05-Aug-2005 hkamdar new logic for R12 Partial Periods --
 	IF l_duration_match = 'T' THEN

	   OKS_RENEW_UTIL_PUB.get_period_defaults
	      	 		(p_hdr_id   =>  p_chr_id,
			  	 p_org_id   =>  NULL,
	     	 		 x_period_type => l_new_period_type,
	    	 		 x_period_start => l_new_period_start,
	   	 		 x_price_uom => l_price_uom,
    	     		         x_return_status => l_return_status);

           If l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

              RAISE G_EXCEPTION_HALT_VALIDATION;

           End If;

	  Open get_old_id_csr(p_chr_id);
          Fetch get_old_id_csr into l_oldchr_id;
          close get_old_id_csr;

          OKS_RENEW_UTIL_PUB.get_period_defaults
	      			(p_hdr_id   =>  l_oldchr_id,
		 		 p_org_id   =>  NULL,
	        		 x_period_type => l_old_period_start,
	    	 		 x_period_start => l_old_period_type,
		    		 x_price_uom => l_price_uom,
    	   	 		 x_return_status => l_return_status);

           If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then

              RAISE G_EXCEPTION_HALT_VALIDATION;

           End If;

          --If period starts of original and renewed contract is
          --same or both are null then set the l_period_start_equal
          -- to 'Y'. At the time of creation of billing schedule
          -- verify whether l_period_start_equal flag is 'Y' or not.

-- Added this portion as per Partial Periods Change Request 001.
          IF NVL(l_new_period_start,'SERVICE')= NVl(l_old_period_start,'SERVICE')
          THEN
    		  	l_Period_start_equal := 'Y';
    	   ELSE
    	    	l_Period_start_equal := 'X';
    	   END IF; -- End for l_new_period_start is Not Null
	END IF;	-- l_duration
       -- End new logic for R12 Partial Periods --

         -- Added so that Terminated and Active contracts go into QA hold during copy.
        Open get_status_csr(p_chr_id);
        Fetch get_status_csr into l_ste_code, l_old_chr_id;
        Close get_status_csr;

        If l_ste_code in ('ACTIVE', 'TERMINATED')  Then
                okc_version_pub.save_version
                (p_chr_id         => p_chr_id,
                 p_api_version    => 1.0,
                 p_init_msg_list  => 'T',
                 x_return_status  => l_return_status,
                 x_msg_count      => l_msg_count,
                 x_msg_data       => l_msg_data,
                 p_commit         => 'F'
                );
                IF l_return_status <> 'S' Then
                    OKC_API.set_message
                              (G_APP_NAME,
                               G_UNEXPECTED_ERROR,
                               G_SQLCODE_TOKEN,
                               SQLCODE,
                               G_SQLERRM_TOKEN,
                               'Error in save version');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                End If;
                oks_contract_hdr_pub.save_version
                              ( p_api_version   => 1.0,
                                p_init_msg_list => 'T',
                                x_return_status => l_return_status,
                                x_msg_count     => l_msg_count,
                                x_msg_data      => l_msg_data,
                                p_chr_id        => p_chr_id);
                IF l_return_status <> 'S' Then
                    OKC_API.set_message
                              (G_APP_NAME,
                               G_UNEXPECTED_ERROR,
                               G_SQLCODE_TOKEN,
                               SQLCODE,
                               G_SQLERRM_TOKEN,
                               'Error in OKS save version');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                End If;
                -- Go into QA hold.
                l_okc_hdr_tbl(1).id := p_chr_id;
                l_okc_hdr_tbl(1).sts_code := 'QA_HOLD';
                OKC_CONTRACT_PUB.update_contract_header(
                    p_api_version         => 1.0,
                    p_init_msg_list       => OKC_API.G_FALSE,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data,
                    p_restricted_update   => 'N',
                    p_chrv_tbl            => l_okc_hdr_tbl,
                    x_chrv_tbl            => x_okc_hdr_tbl
                    );
                IF l_return_status <> 'S' Then
                    OKC_API.set_message
                              (G_APP_NAME,
                               G_UNEXPECTED_ERROR,
                               G_SQLCODE_TOKEN,
                               SQLCODE,
                               G_SQLERRM_TOKEN,
                               'Error in update_contract_header');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                End If;
                OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Went into QA hold: start time= '||to_char(sysdate,'HH:MI:SS'));
         End If;


   End If;        -- If p_chr_id IS NOT NULL


--1. copy on header level

   IF (p_chr_id IS NOT NULL AND (p_cle_id IS NULL
         OR p_cle_id = OKC_API.G_MISS_NUM))    THEN

     For cur_pradj_rec in cur_pradj(p_chr_id)
     LOOP
     update okc_price_adjustments
     set chr_id = null
     where chr_id =cur_pradj_rec.chr_id
     and cle_id =cur_pradj_rec.cle_id;
     END LOOP;
         --Copy header attributes

         IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
         copy_hdr_attr
         (p_chr_id        => l_old_chr_id,
          p_new_chr_id    => p_chr_id,
          p_duration_match => l_duration_match,
         x_return_status => l_return_status);
         END IF;

         --Added as part of fix for 5002535
         IF (l_return_status = 'E') then
             RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;


         OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy Header Attribute status '||l_return_status);

         x_return_status := l_return_status;

        --- Enhancement done on 12/04/2003 asked by Siti
        -- Header notes should be created during copy and renew.
        If  (l_return_status = 'S' AND p_upd_line_flag IS NULL) Then

            OKS_COVERAGES_PVT.COPY_K_HDR_NOTES(
                        p_api_version	        => l_api_version,
                        p_init_msg_list         => l_init_msg_list,
                        p_chr_id                => p_chr_id,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'COPY_K_HDR_NOTES '||l_return_status);

            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                -- Empties the message stack and puts the error in the log file.
                Get_Error_Stack;
                -- We don't want an error in copy notes to stop everything.
                l_return_status := OKC_API.G_RET_STS_SUCCESS;
            End If;
        End If;



      --Calls procedure copy_hdr_sales_credits

         IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
               copy_hdr_sales_credits
               (p_chr_id        => l_old_chr_id,
		p_new_chr_id    => p_chr_id,
                x_return_status => l_return_status);

                x_return_status := l_return_status;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'copy Hedader salescredit Status '||l_return_status);

         END IF; --l_return_status = 'S'

       --Copy Header billing schedules

       IF l_duration_match = 'T' and p_bill_profile_flag is null Then
          IF (l_return_status = 'S' ) THEN

          --AND p_upd_line_flag IS NULL) THEN commented out because not copying
          --header billing schedule in the case of renewal and okscopy is called          --from renewal to copy billing schedule

            Copy_Hdr_Bill_Sch( p_chr_id => l_old_chr_id,
                       p_new_chr_id => p_chr_id,
                       x_return_status => l_return_status);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'copy Hedader Billing Schedule Status '||l_return_status);
          END IF;
       END IF;
     l_return_status := 'S';---tO BE REMOVED LATER ON FOR TESTING PURPOSE ONLY



    FOR check_top_line_exist_rec IN check_top_line_exist_csr (p_chr_id)
    LOOP
       l_old_cle_id :=	check_top_line_exist_rec.orig_system_id1;

       --check if the topline is already created in the oks table
       -- this check is mandatory because okscopy is called twice in case
       -- of line copy to the same contract and that will duplicate the line

       l_topline_count:=chk_topline_exists(check_top_line_exist_rec.id);

    IF l_topline_count>0 Then

     FOR top_lines_rec IN csr_top_lines(p_chr_id)
     LOOP
      UPDATE okc_k_lines_b set
      price_negotiated = (SELECT sum(price_negotiated) FROM okc_k_lines_b
                        WHERE dnz_chr_id = p_chr_id AND chr_id is null
                        AND cle_id = top_lines_rec.id)
      WHERE lse_id in (1, 19, 12) -- added lse id 12 for bug # 3534513
      AND chr_id = p_chr_id AND id = top_lines_rec.id;

     l_sll_count:=chk_sll_exists(top_lines_rec.id);
-- 8/5/05 hkamdar R12 added check for period start equal as per Partial Periods Change Request 001.

     IF l_duration_match = 'T' and p_bill_profile_flag is null AND nvl(l_Period_start_equal,'Y') = 'Y' Then
      IF l_sll_count=0 THEN

      get_billing_attr
                 (p_chr_id    => p_chr_id,
                  p_cle_id	   => top_lines_rec.id,
                  x_billing_schedule_type => l_billing_schedule_type,
                  x_inv_rule_id  => l_inv_rule_id,
                  x_return_status  => l_return_status
                  );

      get_strlvls
               (p_chr_id        => p_chr_id,
                p_cle_id        => top_lines_rec.id,
                p_billsch_type  => l_billing_schedule_type,
                x_strlvl_tbl    => l_strlvl_tbl,
                x_return_status => l_return_status
                );

      oks_bill_sch.create_bill_sch_rules
                   (
                    p_billing_type    => l_billing_schedule_type,
                    p_sll_tbl         => l_strlvl_tbl,
                    p_invoice_rule_id => l_inv_rule_id,
                    x_bil_sch_out_tbl => l_bil_sch_out_tbl,
                    x_return_status   => l_return_status);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'copy Lines  Billing Schedule Status '||l_return_status);
    END IF; --l_sll_count=0
   END IF;  --l_duration_match = 'T'
  End loop;
       -- The check to see if this is a copy or it's being called the second time
       -- in renew was added because this API should only get called once and it should
       -- have the new contract dates.
       --IF (check_top_line_exist_rec.lse_id in (1,19) AND l_second_call) Then
       IF check_top_line_exist_rec.lse_id in (1,19) AND (l_second_call or l_do_copy) Then
       if not chk_coverage_exists( check_top_line_exist_rec.id) then

         OKS_COVERAGES_PVT.Copy_Coverage
         (p_api_version       => 1.0    ,
          p_init_msg_list     => OKC_API.G_FALSE   ,
          x_return_status     => l_return_status  ,
          x_msg_count         => l_msg_count      ,
          x_msg_data          => l_msg_data        ,
          p_contract_line_id  => check_top_line_exist_rec.id   );

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy Coverage Status '||l_return_status);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             Raise G_EXCEPTION_HALT_VALIDATION;
        End If;
      END IF;
     END IF;


 END IF;  --l_topline_count>0



   IF l_topline_count=0 then


    l_return_status := 'S';--assigning this for case of subscription subline
    --copy, the l_return_status becomes U ,because there is no subscription subline
    --and calls directly subcopy

      IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
              copy_lines_attr
               (p_cle_id         => check_top_line_exist_rec.orig_system_id1,
                p_new_cle_id      => check_top_line_exist_rec.id,
                p_new_chr_id      => check_top_line_exist_rec.dnz_chr_id,
                p_do_copy         => l_do_copy,
                x_return_status => l_return_status);

      END IF;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'copy Lines Attr  Status '||l_return_status);

     --check item exists
     OPEN get_item_csr(check_top_line_exist_rec.id);
     FETCH get_item_csr INTO get_item_rec;

     IF get_item_rec.cnt >0 THEN
     OPEN line_Billsch_type(check_top_line_exist_rec.id);
     FETCH line_Billsch_type INTO l_line_billsch_type;
     CLOSE line_Billsch_type;

      --Calls sub_copy proc
       sub_copy
       (
        p_chr_id        => p_chr_id,
        p_cle_id        => check_top_line_exist_rec.id,
        p_start_date    => check_top_line_exist_rec.start_date,
        p_upd_line_flag => p_upd_line_flag,
        p_billing_schedule_type => l_line_billsch_type,
        p_duration_match      => l_duration_match,
        p_bill_profile_flag=>p_bill_profile_flag,
        p_do_copy   => l_do_copy,
        x_return_status => l_return_status
       );
-- Commented on 03/20/2002 as OKC has fixed the problem of sequencing -Anupama
-- Uncommented on 11/03/2002 as OKC has changed its code. Bug#2462154 --mkhayer
       --Added as part of fix for bug 5002535
       IF (l_return_status = 'E') then
            RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;



      --Calls procedure for updating credit card values

         IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
             check_CCR_rule_line(p_chr_id        => p_chr_id,
                            p_cle_id        => check_top_line_exist_rec.id,
                            x_return_status => l_return_status);
             x_return_status := l_return_status;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'check CCR Rule  Status '||l_return_status);

         END IF; --l_return_status = 'S'

      --Calls procedure copy_revenue_distb

         IF  p_upd_line_flag IS NULL THEN
              copy_revenue_distb
               (p_cle_id        => check_top_line_exist_rec.orig_system_id1,
       		p_new_cle_id    => check_top_line_exist_rec.id,
        	p_new_chr_id    => check_top_line_exist_rec.dnz_chr_id,
                x_return_status => l_return_status);
             x_return_status := l_return_status;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy Lines revenue dist Status '||l_return_status);
         END IF; --l_return_status = 'S'

      --Calls procedure copy_line_sales_credits

         IF  p_upd_line_flag IS NULL  THEN
          copy_line_sales_credits
          (p_cle_id        => check_top_line_exist_rec.orig_system_id1,
           p_new_cle_id    => check_top_line_exist_rec.id,
     	   p_new_chr_id    => check_top_line_exist_rec.dnz_chr_id,
           x_return_status => l_return_status);

             x_return_status := l_return_status;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy Line Sales Credit Status '||l_return_status);

       END IF; --l_return_status = 'S'

       -- The check to see if this is a copy or it's being called the second time
       -- in renew was added because this API should only get called once and it should
       -- have the new contract dates.
       IF (check_top_line_exist_rec.lse_id in (1,19) AND l_do_copy ) Then

         OKS_COVERAGES_PVT.Copy_Coverage
         (p_api_version       => 1.0    ,
          p_init_msg_list     => OKC_API.G_FALSE   ,
          x_return_status     => l_return_status  ,
          x_msg_count         => l_msg_count      ,
          x_msg_data          => l_msg_data        ,
          p_contract_line_id  => check_top_line_exist_rec.id   );

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy Coverage Status '||l_return_status);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

     END IF;


         IF (p_upd_line_flag is NULL and check_top_line_exist_rec.lse_id = 46) THEN
           copy_subscr_inst(check_top_line_exist_rec.dnz_chr_id
                 ,check_top_line_exist_rec.id
                 ,null
                 ,l_return_status);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy subscr_inst Status '||l_return_status);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

        END IF;

     ELSE

       --Calls delete line proc
       oks_coverages_pub.undo_line(
                        p_api_version	        => l_api_version,
                        p_init_msg_list         => l_init_msg_list,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
                        p_Line_Id               => check_top_line_exist_rec.id);

       x_return_status := l_return_status;

     END IF; --l_get_item_rec.cnt >0
    CLOSE get_item_csr;
  END IF;
  END LOOP;  --for check_top_line_exist_csr

--2. copy on top line level

ELSIF (p_chr_id IS NOT NULL  AND p_cle_id IS NOT NULL
              AND p_cle_id <> OKC_API.G_MISS_NUM)     THEN

    FOR cle_grp_rec IN cle_grp_csr (p_chr_id,p_cle_id)
    LOOP
      IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
              copy_lines_attr
               (p_cle_id         => cle_grp_rec.orig_system_id1,
                p_new_cle_id      => cle_grp_rec.id,
                p_new_chr_id      => cle_grp_rec.dnz_chr_id,
                x_return_status => l_return_status);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Line Copy line_attr Status'||l_return_status);

     END IF;

     OPEN get_item_csr(p_cle_id);
     FETCH get_item_csr INTO get_item_rec;

     IF get_item_rec.cnt >0   THEN
     OPEN line_Billsch_type(p_cle_id);
     FETCH line_Billsch_type INTO l_line_billsch_type;
     CLOSE line_Billsch_type;

-- Commented on 03/20/2002 as OKC has fixed the problem of sequencing -Anupama
-- Uncommented on 11/03/2002 as OKC has changed its code. Bug#2462154 --mkhayer

 --Calls procedure copy_revenue_distb

         IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
             copy_revenue_distb
             (p_cle_id        => cle_grp_rec.orig_system_id1,
              p_new_cle_id    => cle_grp_rec.id,
              p_new_chr_id    => cle_grp_rec.dnz_chr_id,
              x_return_status => l_return_status);

              x_return_status := l_return_status;
            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Line Copy line_revenue_dist Status'||l_return_status);
         END IF; --l_return_status = 'S'

 --Calls procedure copy_line_sales_credits

         IF (l_return_status = 'S' AND p_upd_line_flag IS NULL)  THEN
              copy_line_sales_credits
              (p_cle_id        => cle_grp_rec.orig_system_id1,
	       p_new_cle_id    => cle_grp_rec.id,
	       p_new_chr_id    => cle_grp_rec.dnz_chr_id,
               x_return_status => l_return_status);

             x_return_status := l_return_status;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Line Copy line_sales_credit Status'||l_return_status);

         END IF; --l_return_status = 'S'

   IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
             check_CCR_rule_line(p_chr_id        => p_chr_id,
                            p_cle_id        => cle_grp_rec.id,
                            x_return_status => l_return_status);
             x_return_status := l_return_status;

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'check CCR Rule  Status'||l_return_status);

   END IF; --l_return_status = 'S'

     IF (p_upd_line_flag is null and cle_grp_rec.lse_id = 46) THEN
           copy_subscr_inst(cle_grp_rec.dnz_chr_id
                 ,cle_grp_rec.id
                 ,null
                 ,l_return_status);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Line Copy line_subscr_inst Status'||l_return_status);
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

    END IF;--IF

  /*
      If (cle_grp_rec.lse_id in (1,19) AND p_upd_line_flag IS NULL) Then

         OKS_COVERAGES_PVT.Copy_Coverage
         (p_api_version       => 1.0    ,
          p_init_msg_list     => OKC_API.G_FALSE   ,
          x_return_status     => l_return_status  ,
          x_msg_count         => l_msg_count      ,
          x_msg_data          => l_msg_data        ,
          p_contract_line_id  => cle_grp_rec.id   );

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Copy Coverage Status'||l_return_status);

     IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             Raise G_EXCEPTION_HALT_VALIDATION;
     End If;
    END IF;
*/
     ELSE

       --Calls delete line proc
       oks_coverages_pub.undo_line(
                        p_api_version           => l_api_version,
                        p_init_msg_list         => l_init_msg_list,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data,
                        p_Line_Id               => p_cle_id);
       x_return_status := l_return_status;

     END IF; --l_get_item_rec.cnt >0
    CLOSE get_item_csr;

    END LOOP; --FOR cle_grp_rec IN cle_grp_csr

--3. if no parameter passed

    ELSIF (p_chr_id IS NULL  AND p_cle_id IS NULL)    THEN
          l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;

 END IF;-- IF (p_chr_id IS NOT NULL AND p_cle_id IS NULL)






 IF (l_return_status = 'S' AND p_upd_line_flag IS NULL) THEN
   IF not chk_party_exists(p_chr_id) then
   Party_cleanup(p_chr_id,l_return_status);

  END IF;
 END IF;





    -- Added for updating top line price_negotiated for copy
    IF p_upd_line_flag IS NULL and p_chr_id is not null THEN

        -- Get the sum of all the top lines.
        update okc_k_headers_b set
            estimated_amount =
            (select sum(price_negotiated) from okc_k_lines_b
            where dnz_chr_id = p_chr_id and cle_id is null)
        where id = p_chr_id;
    End If;


 IF p_upd_line_flag IS NULL THEN
    l_update_top_line := false;
    -- means it's being called in renew
    If l_duration_match = 'F' Then
        Open is_terminated (l_oldchr_id);
        Fetch is_terminated into l_line_num;
        If is_terminated%FOUND Then
            l_update_top_line := true;
        End If;
        Close is_terminated ;
    End If;
       update_line_numbers (p_chr_id        => p_chr_id
                            ,p_update_top_line => l_update_top_line
                            ,x_return_status => l_return_status);

            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'Update Line Number Status'||l_return_status);

            x_return_status := l_return_status;
 END IF;

-- Check if original contract has a price lock and if so check if price list is
-- the same as the original contract. Price lock should get removed if
-- the price list is not the same.
If  p_chr_id IS NOT NULL and p_upd_line_flag is not null then
    For get_lines_rec in get_all_lines_csr(p_chr_id) Loop
        l_old_cle_id :=	get_lines_rec.orig_system_id1;
        For get_oks_line_attr in get_lines_attr_csr(l_old_cle_id) Loop
            If get_oks_line_attr.LOCKED_PRICE_LIST_ID is not null Then
                Open get_price_list(l_old_cle_id);
                Fetch get_price_list into l_old_price_list_id;
                Close get_price_list;
                -- For renewal the price lock doesnt get copied in the first
                -- okscopy call. It gets copied in the second call only
                -- if the price list ids are the same.
                OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'old price list id: ' || l_old_price_list_id);
                OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'new price list id: ' || get_lines_rec.price_list_id);
                OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'new contract lse id: ' || get_lines_rec.lse_id);
                If nvl(l_old_price_list_id, -99) =  nvl(get_lines_rec.price_list_id, -99) Then
                    Open get_contract_number(p_chr_id);
                    Fetch get_contract_number into l_contract_number;
                    Close get_contract_number;
                    OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'Calling QP API');
OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>' get_oks_line_attr.LOCKED_PRICE_LIST_LINE_ID: ' ||  get_oks_line_attr.LOCKED_PRICE_LIST_LINE_ID);
-- MKS Commented out.. Need to put back in once QP patch is ready.
/*
                    QP_LOCK_PRICELIST_GRP.Lock_Price(p_source_list_line_id	  => get_oks_line_attr.LOCKED_PRICE_LIST_LINE_ID,
                                        p_list_source_code        => 'OKS',
                                        p_orig_system_header_ref     => l_contract_number,
                                        x_locked_price_list_id       => l_locked_price_list_id,
                                        x_locked_list_line_id        => l_locked_price_list_line_id,
                                        x_return_status              => l_return_status,
 		                                x_msg_count                  => l_msg_count,
		                                x_msg_data                   => l_msg_data);

                    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                        OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'QP failed.');
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
*/
                    select id
                    into l_oks_line_id
                    from oks_k_lines_b where cle_id = get_lines_rec.id;

                    OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'After cursor call');
                    Update oks_k_lines_b set
                        LOCKED_PRICE_LIST_ID = l_locked_price_list_id,
                        LOCKED_PRICE_LIST_LINE_ID = l_locked_price_list_line_id,
                        break_uom = get_oks_line_attr.break_uom
                    where id = l_oks_line_id;
                    OKS_RENEW_PVT.Debug_Log(p_program_name => 'OKSCOPY',
                                        p_perf_msg =>'After update');

                End If;    -- if price list ids are different
            End If;     -- if original contract has a price list id
     End Loop; -- loop through original contract OKS attributes
   End Loop; -- loop through new contracts
End If; -- if being called in renew the second time


            OKS_RENEW_PVT.Debug_Log
               (p_program_name => 'OKSCOPY'
               ,p_perf_msg =>'OKSCOPY: end  time= '||to_char(sysdate,'HH:MI:SS'));

   x_return_status := l_return_status;
EXCEPTION
        WHEN  G_EXCEPTION_HALT_VALIDATION THEN
                x_return_status := l_return_status;

        WHEN  OTHERS THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                OKC_API.set_message
                              (G_APP_NAME,
                               G_UNEXPECTED_ERROR,
                               G_SQLCODE_TOKEN,
                               SQLCODE,
                               G_SQLERRM_TOKEN,
                               SQLERRM);


END Okscopy;


-------------------------------------------------------------------------------
-- Procedure:          Update_line_numbers
-- Purpose:             This procedure updates the line numbers for the subline
--                      copied
-- In Parameters:       p_chr_id        contract id
-- In Parameters:       p_cle_id        line id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------


/** Update_line_number procedure overloaded
-- aiyengar
-- 10/10/2001
**/

PROCEDURE Update_Line_Numbers
(
 p_chr_id                 IN NUMBER,
 p_cle_id                 IN NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_return_status		  VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
-- will select all covered levels for  given cle_id

CURSOR l_csr_okc_k_lines IS
SELECT id
FROM   OKC_K_LINES_B
where  dnz_chr_id = p_chr_id
and    cle_id = p_cle_id
and    lse_id IN (7,8,9,10,11,35,13,18,25);

l_subline_id     NUMBER;
l_line_seq_no    NUMBER;

yes_flag                VARCHAR2(1);

BEGIN
   l_return_status := OKC_API.G_RET_STS_SUCCESS;
-- This code has been modified to add p_cle_id as input parameter

               l_line_seq_no := 0;

               OPEN l_csr_okc_k_lines;
               LOOP
               FETCH l_csr_okc_k_lines INTO l_subline_id;
               IF l_csr_okc_k_lines%FOUND THEN

                        l_line_seq_no := l_line_seq_no + 1;
                        UPDATE okc_k_lines_b
                        SET line_number = l_line_seq_no
                        WHERE id = l_subline_id;

               ELSE
                   EXIT;
               END IF; -- End if subline not found

               END LOOP;  -- End of inner loop
               CLOSE l_csr_okc_k_lines;
    x_return_status := l_return_status;
END ;

-------------------------------------------------------------------------------
-- Procedure:          update_line_numbers
-- Purpose:            This procedure updates the line_numbers of the contract
--                      id passed
-- In Parameters:       p_chr_id        new contract id
--                      p_update_top_line   flag that is asking us to update line number
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

PROCEDURE Update_Line_Numbers
(
 p_chr_id                 IN NUMBER,
 p_update_top_line        IN BOOLEAN,
 x_return_status          OUT NOCOPY VARCHAR2
)
IS

l_return_status		  VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

Cursor l_csr_header IS
SELECT id from okc_k_headers_b
WHERE scs_code in ('SERVICE','WARRANTY')
AND id =p_chr_id;

Cursor l_csr_top_line(p_chr_id NUMBER) IS
SELECT id
FROM   OKC_K_LINES_B
Where  dnz_chr_id = p_chr_id
and    lse_id IN (1,12,14,19, 46)
order by line_number;


CURSOR l_csr_okc_k_lines(p_top_line_id NUMBER) IS
SELECT id
FROM   OKC_K_LINES_B
where  cle_id =  p_top_line_id
and    lse_id IN (7,8,9,10,11,35,13,18,25);


--CURSOR l_csr_process_control IS
--SELECT processflag
--FROM   oks_process_control
--WHERE  RTRIM(LTRIM(UPPER(filename))) = 'OKSLNMIG';


l_topline_id     NUMBER;
l_subline_id     NUMBER;
l_old_topline    NUMBER;
l_line_seq_no    NUMBER;
l_topline_seq    NUMBER;
l_contract_count NUMBER;
l_chr_id         NUMBER;
l_old_chr_id     NUMBER;
l_process_flag   VARCHAR2(1);
tot_contracts    NUMBER;

yes_flag                VARCHAR2(1);

BEGIN

   l_return_status := OKC_API.G_RET_STS_SUCCESS;
l_contract_count :=0;


--   l_contract_count := l_contract_count + 1;
   l_topline_seq  := 0;
   OPEN l_csr_top_line(p_chr_id);
   LOOP
   FETCH l_csr_top_line INTO  l_topline_id;
   IF l_csr_top_line%NOTFOUND THEN
      EXIT;
   ELSE
       l_topline_seq := l_topline_seq + 1;

       If p_update_top_line Then
            UPDATE OKC_K_LINES_B
            SET    line_number = l_topline_seq
            WHERE  id          = l_topline_id;
       End If;


         l_line_seq_no := 0;
         OPEN l_csr_okc_k_lines(l_topline_id);
          LOOP
          FETCH l_csr_okc_k_lines INTO l_subline_id;
          IF l_csr_okc_k_lines%FOUND THEN

          l_line_seq_no := l_line_seq_no + 1;
           UPDATE okc_k_lines_b
           SET line_number = l_line_seq_no
           WHERE id = l_subline_id;


          ELSE
           EXIT;
         END IF; -- End if subline not found

       END LOOP;  -- End of inner loop
     CLOSE l_csr_okc_k_lines;
    END IF; ---End if l_csr_topline not found

    END LOOP;  --- End of topline loop
    CLOSE l_csr_top_line;



    x_return_status := l_return_status;


EXCEPTION
       WHEN OTHERS THEN
                x_return_status := 'E';

END Update_Line_Numbers;





-------------------------------------------------------------------------------
-- Procedure:           get_qto_details
-- Purpose:             Build several records/tables that hold information to be
--                      used to pass to OC APIs
-- In Parameters:       p_new_chr_id        new contract id
-- Out Parameters:      x_return_status     standard return status
--                      x_flag              yes no flag
-----------------------------------------------------------------------------



PROCEDURE Get_QTO_Details
(
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  P_commit              IN   Varchar2,
  p_chr_id              IN   Number,
  p_type                IN   Varchar2,
  x_contact_dtl_rec     OUT  NOCOPY contact_dtl_rec,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2
)
Is

  Cursor hdr_qto_csr is
  SELECT
     QUOTE_TO_CONTACT_ID
    ,QUOTE_TO_SITE_ID
    ,QUOTE_TO_EMAIL_ID
    ,QUOTE_TO_PHONE_ID
    ,QUOTE_TO_FAX_ID
  FROM OKS_K_HEADERS_B
  WHERE chr_id = p_chr_id;

   Cursor get_org_values IS
     SELECT inv_organization_id,
            authoring_org_id
     FROM okc_k_headers_b
     WHERE id=p_chr_id;

    Cursor l_hdr_svc_csr Is
     SELECT ctc.object1_id1 ,
            pt.name contact_name,
            pt.party_id,
            hz.party_name party_name
     FROM   okc_contacts_v ctc,
            okx_party_contacts_v pt,
            hz_parties hz
     WHERE  ctc.cro_code = 'SVC_ADMIN'
     AND    ctc.dnz_chr_id = p_chr_id
     AND    pt.id1 = ctc.object1_id1
     AND    pt.id2 = ctc.object1_id2
     AND    pt.party_id = hz.party_id;
     --And    pt.party_id2 = hz.id2;

    Cursor email_csr(p_email_id IN  Number) is
    SELECT lower(email_address)
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = p_email_id;

    Cursor phone_csr(p_phone_id IN Number) is
    SELECT DECODE(PHONE_AREA_CODE,NULL,NULL,PHONE_AREA_CODE||'-')
            ||PHONE_NUMBER phone_number
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = p_phone_id;

    Cursor fax_csr(p_fax_id IN  Number)  is
    SELECT DECODE(PHONE_AREA_CODE, NULL,NULL,PHONE_AREA_CODE||'-')
           ||PHONE_NUMBER phone_number
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = p_fax_id;

    Cursor party_csr(p_contact_id IN  Number) is
    SELECT b.party_name
    FROM okx_cust_contacts_v a, hz_parties b
    WHERE a.id1=p_contact_id
    AND a.party_id=b.party_id;

    Cursor contact_name_csr(p_contact_id IN  Number) is
    SELECT ltrim(rtrim(substr(pt.name,instr(pt.name,',')+1)))||' '||
    ltrim(rtrim(substr(pt.name,1,instr(pt.name,',')-1))) contact_name
  ,InitCap(ltrim(rtrim(SUBSTR(pt.name,INSTR(pt.name,',')+1)))) contact_first_name
    FROM   okx_cust_contacts_v pt
    WHERE    pt.id1 = p_contact_id;

   cursor l_qtoadd_csr (l_site_id in Number) Is
   SELECT
   loc.ADDRESS1||''||loc.ADDRESS2||''||loc.ADDRESS3||''||loc.ADDRESS4 Address
   ,loc.CITY||' '||loc.state||' '||loc.postal_code city
   ,loc.country
   FROM okx_cust_sites_v loc
   WHERE id1 = l_site_id ;

  l_hdr_svc_rec        l_hdr_svc_csr%ROWTYPE;
  hdr_qto_rec        hdr_qto_csr%ROWTYPE;
  l_site_use_id        number;
  l_site_id        number;
  l_contact_id    number;
  l_email_id      number;
  l_phone_id      number;
  l_fax_id        number;
  l_inv_org_id    number;
  l_auth_org_id   number;

    ---l_site_use_id Number;
Begin

  Open  hdr_qto_csr;
  Fetch hdr_qto_csr Into hdr_qto_rec;
  Close hdr_qto_csr;

  OPEN get_org_values;
  FETCH get_org_values INTO l_inv_org_id, l_auth_org_id ;
  CLOSE get_org_values;

  okc_context.set_okc_org_context(l_auth_org_id,l_inv_org_id);

        x_contact_dtl_rec.contact_id   := hdr_qto_rec.QUOTE_TO_CONTACT_ID;
      ---  x_contact_dtl_rec.quote_site_id   := hdr_qto_rec.object2_id1;

   l_contact_id  :=  hdr_qto_rec.QUOTE_TO_CONTACT_ID;
   l_email_id    :=  hdr_qto_rec.QUOTE_TO_EMAIL_ID;
   l_phone_id    :=  hdr_qto_rec.QUOTE_TO_PHONE_ID;
   l_fax_id      :=  hdr_qto_rec.QUOTE_TO_FAX_ID;
   l_site_id     :=  hdr_qto_rec.QUOTE_TO_SITE_ID;

    Open party_csr(l_contact_id);
    Fetch party_csr into x_contact_dtl_rec.party_name;
    Close party_csr;

    Open contact_name_csr(l_contact_id);
    Fetch contact_name_csr
    INTO  x_contact_dtl_rec.contact_name
          ,x_contact_dtl_rec.contact_first_name ;
    Close contact_name_csr;

    -- Get the contact's primary email address (if any)
    Open email_csr(l_email_id);
    Fetch email_csr into x_contact_dtl_rec.email;
    Close email_csr;

    -- Get the contact's primary telephone number (if any)
    Open phone_csr(l_phone_id);
    Fetch phone_csr into x_contact_dtl_rec.phone;
    Close phone_csr;

    -- Get the contact's fax number (if any)
    Open fax_csr(l_fax_id);
    Fetch fax_csr into x_contact_dtl_rec.fax;
    Close fax_csr;

   Open   l_qtoadd_csr ( l_site_id);
   Fetch  l_qtoadd_csr Into
            x_contact_dtl_rec.quote_address,
            x_contact_dtl_rec.quote_city,
            x_contact_dtl_rec.quote_country;
           -- x_contact_dtl_rec.quote_site_id;

   Close  l_qtoadd_csr;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message
          (G_APP_NAME,
           G_UNEXPECTED_ERROR,
           G_SQLCODE_TOKEN,
           SQLCODE,
           G_SQLERRM_TOKEN,
           SQLERRM);
END;



-- This Procedure creates a new QTO rule for a contract header. --
-- Default QTO address, email, phone and fax are selected for   --
-- the customer contact specified. The OKC organization context --
-- must be set before calling this procedure.                   --
-- Procedure Author - Jacob K.                                  --
-- Created - 10/29/2001                                         --

PROCEDURE Create_Qto_Rule(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          p_chr_id IN NUMBER,
                          p_contact_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2) IS
  -- Contact address
  cursor address_cur_new is
    select a.id1
    from okx_cust_sites_v a,
         okx_cust_contacts_v b
    where b.id1 = p_contact_id
      and a.id1 = b.cust_acct_site_id;

  -- Primary e-mail address
  cursor email_cur_new is
    select contact_point_id
   -- from okx_contact_points_v
   from hz_contact_points
    where contact_point_type = 'EMAIL'
    and primary_flag = 'Y'
    and owner_table_id = p_contact_id;

  -- Primary telephone number
  cursor phone_cur_new is
    select contact_point_id
    from hz_contact_points
    where contact_point_type = 'PHONE'
      and NVL(phone_line_type,'GEN') = 'GEN'
      and primary_flag = 'Y'
      and owner_table_id = p_contact_id;

  -- Any one fax number
  cursor fax_cur_new is
    select contact_point_id
    from hz_contact_points
    where contact_point_type = 'PHONE'
      and phone_line_type = 'FAX'
      and owner_table_id = p_contact_id;

 l_return_status              Varchar2(1);
 l_msg_count                  Number;
 l_msg_data                   Varchar2(2000);
 l_api_version                Number := 1;
 l_init_msg_list              Varchar2(1) := 'F';
 l_QUOTE_TO_CONTACT_ID	      NUMBER;
 l_QUOTE_TO_SITE_ID	          NUMBER;
 l_QUOTE_TO_EMAIL_ID	      NUMBER;
 l_QUOTE_TO_PHONE_ID	      NUMBER;
 l_QUOTE_TO_FAX_ID	          NUMBER;

  l_khrv_tbl     OKS_KHR_PVT.khrv_tbl_type;
  x_khrv_tbl     OKS_KHR_PVT.khrv_tbl_type;

BEGIN
  x_return_status := 'E';
  If p_contact_id is not null Then
    --
    -- Get the default contact points and address
    --

    -- Get the contact site address (if any)
    Open address_cur_new;
    Fetch address_cur_new into l_QUOTE_TO_site_id;
    Close address_cur_new;

    -- Get the contact's primary email address (if any)
    Open email_cur_new;
    Fetch email_cur_new into l_QUOTE_TO_email_id;
    Close email_cur_new;

    -- Get the contact's primary telephone number (if any)
    Open phone_cur_new;
    Fetch phone_cur_new into l_QUOTE_TO_phone_id;
    Close phone_cur_new;

    -- Get the contact's fax number (if any)
    Open fax_cur_new;
    Fetch fax_cur_new into l_QUOTE_TO_fax_id;
    Close fax_cur_new;

 l_khrv_tbl(1).chr_id             := p_chr_id;
 l_khrv_tbl(1).QUOTE_TO_CONTACT_ID:=l_QUOTE_TO_CONTACT_ID;
 l_khrv_tbl(1).QUOTE_TO_SITE_ID	  :=l_QUOTE_TO_SITE_ID;
 l_khrv_tbl(1).QUOTE_TO_EMAIL_ID  :=l_QUOTE_TO_EMAIL_ID;
 l_khrv_tbl(1).QUOTE_TO_PHONE_ID  :=l_QUOTE_TO_PHONE_ID;
 l_khrv_tbl(1).QUOTE_TO_FAX_ID	  :=l_QUOTE_TO_FAX_ID;


       OKS_CONTRACT_HDR_PUB.update_header (
           p_api_version                  => l_api_version,
           p_init_msg_list                => OKC_API.G_FALSE,
           x_return_status                => l_return_status,
           x_msg_count                    => l_msg_count,
           x_msg_data                     => l_msg_data,
           p_khrv_tbl                     => l_khrv_tbl,
           x_khrv_tbl                     => x_khrv_tbl,
          p_validate_yn                   => 'Y');

  End If; -- p_contact_id is not null
EXCEPTION
  When Others Then
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message (G_APP_NAME,
                         G_UNEXPECTED_ERROR,
                         G_SQLCODE_TOKEN,
                         SQLCODE,
                         G_SQLERRM_TOKEN,
                         SQLERRM);
END Create_Qto_Rule;


FUNCTION Resp_Org_id RETURN NUMBER IS
Begin
 If fnd_profile.value('OKC_VIEW_K_BY_ORG') = 'Y' then
    return fnd_profile.value('ORG_ID');
 Else
    return null;
 End If;
End Resp_Org_id;


-- *************************************************************************************************
PROCEDURE UNDO_COUNTERS(P_Kline_Id 	IN 	NUMBER,
			x_Return_Status	OUT NOCOPY	VARCHAR2,
			x_msg_data	OUT NOCOPY	VARCHAR2)  IS

CURSOR Cur_Cgp (P_KLine_Id IN NUMBER) IS
SELECT Counter_Group_id FROM OKX_Counter_Groups_V WHERE Source_Object_Id=P_KLine_Id

				and Source_Object_Code='CONTRACT_LINE';

CURSOR Cur_OVN (P_CtrGrp_Id IN NUMBER) IS
SELECT Object_Version_Number FROM Cs_Counter_Groups
WHERE Counter_group_Id=P_CtrGrp_Id;

TYPE t_IdTable IS TABLE OF NUMBER(35)
INDEX BY BINARY_Integer;
l_cgp_tbl		t_IdTable;
c_Cgp		Number:=1;
l_Ctr_grp_id          NUMBER;
x_Object_Version_Number     NUMBER;
l_Object_Version_Number     NUMBER;
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'UNDO COUNTERS';
  l_Commit          Varchar2(3) ;
  l_Ctr_Grp_Rec		CS_Counters_Pub.CtrGrp_Rec_Type;
  l_cascade_upd_to_instances Varchar2(1);
BEGIN
l_return_status := OKC_API.G_RET_STS_SUCCESS;
FOR Cgp_Rec IN Cur_Cgp(P_KLine_Id)
LOOP
    l_cgp_tbl(c_Cgp):=Cgp_Rec.counter_group_Id;
	c_Cgp:=c_Cgp+1;
	FOR i in 1 .. l_Cgp_tbl.COUNT
	LOOP
		l_Ctr_grp_Id:=l_Cgp_tbl(i);
		l_Ctr_Grp_Rec.end_date_active:=sysdate;
		OPEN Cur_OVN(l_ctr_Grp_Id);
		FETCH  Cur_OVN INTO l_Object_version_Number;
		CLOSE Cur_OVN;
		CS_Counters_PUB.Update_Ctr_Grp(
	       p_api_version		=>l_api_version,
	       p_init_msg_list		=>l_init_msg_list,
	       p_commit			=>l_commit,
	       x_return_status		=>l_return_status,
	       x_msg_count			=>l_msg_count,
	       x_msg_data			=>l_msg_data,
	       p_ctr_grp_id	      =>l_ctr_grp_id,
 	       p_object_version_number	=>	l_object_version_number,
	       p_ctr_grp_rec			=>l_ctr_grp_rec,
	       p_cascade_upd_to_instances	=>l_cascade_upd_to_instances,
	       x_object_version_number	=>	x_object_version_number
        );
        if l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error in update counter.'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
       end if;

	END LOOP;
END LOOP;
x_Return_Status:=l_return_status;

EXCEPTION
    When G_EXCEPTION_HALT_VALIDATION Then
        x_Return_Status:=l_Return_status;
    WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message
          (G_APP_NAME,
           G_UNEXPECTED_ERROR,
           G_SQLCODE_TOKEN,
           SQLCODE,
           G_SQLERRM_TOKEN,
           SQLERRM);
END Undo_Counters;

-------------------------------------------------------------------------------
-- Procedure:          Delete_OKS_Line
-- Purpose:            This procedure takes the okc line id and deletes all
--                     lines related to this line in oks_k_lines_b.
--
-- In Parameters:       p_cle_id            contract line id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------
PROCEDURE Delete_OKS_Line(
                          p_cle_id	        IN NUMBER,
                          x_return_status     OUT NOCOPY VARCHAR2
                          ) IS

l_return_status	VARCHAR2(1);
l_api_version		CONSTANT	NUMBER     := 1.0;
l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000):=null;
l_klnv_rec oks_contract_line_pub.klnv_rec_type;
l_cle_id number;
l_counter number := 1;
l_temp_counter number := 1;

cursor get_child(l_cle_id number) is
select id from okc_k_lines_b where cle_id = l_cle_id;

Type t_number_tbl is table of number Index by BINARY_INTEGER;


l_cle_tbl t_number_tbl;
l_temp_tbl t_number_tbl;
l_first_index BINARY_INTEGER;

cursor get_oks_line(l_cle_id number) is
select id from oks_k_lines_b where cle_id = l_cle_id;

Begin
l_return_status := OKC_API.G_RET_STS_SUCCESS;

l_temp_tbl(l_temp_counter) := p_cle_id;
l_temp_counter := l_temp_counter + 1;

While (l_temp_tbl.count > 0) Loop
    l_first_index := l_temp_tbl.first;
    l_cle_tbl(l_counter) := l_temp_tbl(l_first_index);
    l_cle_id := l_temp_tbl(l_first_index);
    l_counter := l_counter + 1;
    l_temp_tbl.delete(l_first_index);
    For get_child_rec in get_child(l_cle_id)  loop
        l_temp_tbl(l_temp_counter) := get_child_rec.id;
        l_temp_counter := l_temp_counter + 1;
    End Loop;
End Loop;

While (l_cle_tbl.count > 0) Loop
    l_temp_counter := l_cle_tbl.first;
    Open get_oks_line(l_cle_tbl(l_temp_counter));
    Fetch get_oks_line into l_klnv_rec.id;
    Close get_oks_line;

    oks_contract_line_pub.delete_line(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            p_klnv_rec                     => l_klnv_rec);

    If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error while deleting OKS Line'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
    End if;

    l_cle_tbl.delete(l_temp_counter);

End loop;

x_return_status := l_return_status;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status := l_return_status;
  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message
          (G_APP_NAME,
           G_UNEXPECTED_ERROR,
           G_SQLCODE_TOKEN,
           SQLCODE,
           G_SQLERRM_TOKEN,
           SQLERRM);

End Delete_OKS_Line;

PROCEDURE Delete_Contract (
    p_api_version	    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chr_id    	    IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2) IS

-- Get all lines
CURSOR Cur_Line (P_Chr_Id IN NUMBER) IS
SELECT ID FROM OKC_K_Lines_b
WHERE chr_ID=p_chr_Id;

CURSOR Cur_gov (P_chr_Id IN NUMBER) IS
SELECT ID FROM OKC_GOVERNANCES
WHERE dnz_chr_ID=p_chr_Id
And   cle_id Is Null;

CURSOR get_oks_hdr(p_chr_id number) IS
select id from oks_k_headers_b where chr_id = p_chr_id;

cursor topline_csr(p_chr_id number) is
  select a.id, a.lse_id
  from   okc_k_lines_b a
  where  a.dnz_chr_id = p_chr_id and  a.cle_id IS NULL;


l_khrv_rec oks_contract_hdr_pub.khrv_rec_type;
l_klnv_rec oks_contract_line_pub.klnv_rec_type;

  l_chrv_rec         okc_contract_pub.chrv_rec_type;
  l_Line_Id              NUMBER;
  --
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_msg_index_out       Number;
  l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Contract';
   --
  l_gvev_tbl_in     okc_contract_pub.gvev_tbl_type;
  e_error               Exception;
  n     NUMBER;
  m     NUMBER;
  v_Index   NUMBER;
TYPE line_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_Line_tbl line_tbl_Type;
BEGIN

l_return_status := OKC_API.G_RET_STS_SUCCESS;

-- Input Validation
IF p_chr_id IS NULL THEN
       OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Header id passed to Delete_Contract is Null'
                            );
     l_return_status := OKC_API.G_RET_STS_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;
---------- Get all lines -------------
n:=1;
FOR Line_Rec IN Cur_Line(p_chr_id)
LOOP
l_line_tbl(n):=Line_Rec.Id;
n:=n+1;
END LOOP;

FOR topline_rec IN topline_csr(p_chr_id) LOOP
    -- will delete all the existing SLH, SLL and level elements for top line and its sub lines
    OKS_BILL_SCH.Del_Rul_Elements(p_top_line_id   => topline_rec.id,
                                  x_return_status => l_return_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data);

    Delete_OKS_Line(
                        p_cle_id	      => topline_rec.id,
                        x_return_status   => l_return_status);

        If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error from Delete_OKS_Line'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End if;

    -- We only delete coverages for the top lines.
    -- Each top line has only one coverage
    If topline_rec.lse_id in (1, 14, 19) Then
         -- Deletes coverages and PM schedules and coverage lines
        OKS_COVERAGES_PVT.Undo_Line(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            p_validate_status              => 'Y',
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            P_Line_Id                      => topline_rec.id);
        If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error in deleting coverage lines.'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End if;
    End If;


End Loop;
---------- Get all Governances ---------
n:=1;
FOR Gov_Rec IN Cur_gov(p_chr_id)
LOOP
l_gvev_tbl_in(n).Id:=Gov_Rec.Id;
n:=n+1;
END LOOP;

---------- Delete Governance  --------------
IF NOT l_gvev_tbl_In.COUNT=0
THEN
  okc_Contract_pub.delete_governance(
   	p_api_version			=> l_api_version,
  	p_init_msg_list			=> l_init_msg_list,
     	x_return_status			=> l_return_status,
        x_msg_count			=> l_msg_count,
        x_msg_data			=> l_msg_data,
        p_gvev_tbl			=> l_gvev_tbl_in);
  If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
       OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error while deleting governance'
                            );
        RAISE G_EXCEPTION_HALT_VALIDATION;
  End if;
END IF;


--------------Undo counters --------------
IF NOT l_line_tbl.COUNT=0 THEN
    --v_Index:=l_line_tbl.COUNT;
    FOR v_Index IN l_line_tbl.FIRST .. l_line_tbl.LAST
    LOOP
        l_Line_Id:=l_line_tbl(v_Index);
        Undo_Counters( P_KLine_Id            => l_Line_Id,
     	               x_return_status	     => l_return_status,
                       x_msg_data		     => l_msg_data);
        If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error while deleting Counters'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End if;
    END LOOP;
END IF;

---------------- Delete OKS header and line -----------------------
Open get_oks_hdr(p_chr_id);
Fetch get_oks_hdr into l_khrv_rec.id;
Close get_oks_hdr;
oks_contract_hdr_pub.delete_header(
    p_api_version                  => l_api_version,
    p_init_msg_list                => l_init_msg_list,
    x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data,
    p_khrv_rec                     => l_khrv_rec);
If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error while deleting OKS Header'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
End if;

oks_contract_hdr_pub.delete_history(
	p_api_version 		=>l_api_version,
	p_init_msg_list 	=>l_init_msg_list,
	x_return_status	    =>l_return_status,
	x_msg_count		    =>l_msg_count,
	x_msg_data		    =>l_msg_data,
    p_chr_id            => p_chr_id);
If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error while deleting OKS History'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
End if;

---------- Delete Contract from OKC (Header and Line) ----------
l_chrv_rec.id := p_chr_id;
OKC_DELETE_CONTRACT_PUB.delete_contract(
	p_api_version 		=>l_api_version,
	p_init_msg_list 	=>l_init_msg_list,
	x_return_status	    =>l_return_status,
	x_msg_count		    =>l_msg_count,
	x_msg_data		    =>l_msg_data,
    p_chrv_rec         =>l_chrv_rec);
If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error while deleting Contract'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;

End if;


x_return_status:=l_return_status;
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status:=l_return_status;
    WHEN OTHERS THEN
    OKC_API.set_message
          (G_APP_NAME,
           G_UNEXPECTED_ERROR,
           G_SQLCODE_TOKEN,
           SQLCODE,
           G_SQLERRM_TOKEN,
           SQLERRM);
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End Delete_Contract;


PROCEDURE Delete_Contract_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_line_id           IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2) IS

l_return_status	VARCHAR2(1);
l_lse_id number;
l_parent_id number;
l_api_version		CONSTANT	NUMBER     := 1.0;
l_init_msg_list	CONSTANT	VARCHAR2(1):= 'T';
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000):=null;

cursor get_line_type(l_line_id number) is
select lse_id, cle_id
from okc_k_lines_b
where id = l_line_id;


l_klnv_rec oks_contract_line_pub.klnv_rec_type;

TYPE line_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_line_tbl  line_Tbl_Type;

n               number;
l_cov_line_id   number;
v_Index         number;
l_clev_rec      OKC_CLE_PVT.clev_rec_type;

Begin
l_return_status := OKC_API.G_RET_STS_SUCCESS;

Open get_line_type(p_line_id);
Fetch get_line_type into l_lse_id, l_parent_id;
Close get_line_type;

-- We only delete coverages for the top lines.
-- Each top line has only one coverage
If l_lse_id in (1, 14, 19) Then
         -- Deletes coverages and PM schedules and coverage lines
        OKS_COVERAGES_PUB.DELETE_COVERAGE(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            P_service_Line_Id              => p_line_id);

        If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error in deleting coverage lines.'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End if;
End If;

-- Fix for deleting billing schedules for lines that do have billing schedules.
If l_lse_id in (1,3, 8, 9, 10, 11, 12, 13, 14, 18, 19, 25, 35, 46) Then
        ----------- Delete OKS billing schedule ----------------------------
        If l_parent_id is null Then

            -- will delete all the existing SLH, SLL and level elements for top line and its sub lines
            OKS_BILL_SCH.Del_Rul_Elements(p_top_line_id   => p_line_id,
                                  x_return_status => l_return_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data);
            If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
                OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error in deleting billing schedule (OKS_BILL_SCH.Del_Rul_Elements)'
                            );
                RAISE G_EXCEPTION_HALT_VALIDATION;
            End if;

        Else
            OKS_BILL_SCH.Del_subline_lvl_rule(p_top_line_id        => l_parent_id,
                                      p_sub_line_id        => p_line_id,
                                      x_return_status      => l_return_status,
                                      x_msg_count          => l_msg_count,
                                      x_msg_data           => l_msg_data
                                      );
            If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
                OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error in deleting billing schedule (OKS_BILL_SCH.Del_subline_lvl_rule)'
                            );
                RAISE G_EXCEPTION_HALT_VALIDATION;
            End if;
        End If;

End If;


---------------- Delete OKS line -----------------------
Delete_OKS_Line(
                p_cle_id	      => p_line_id,
                x_return_status   => l_return_status);

If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error from Delete_OKS_Line'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
End if;

--l_clev_rec.id := p_line_id;
OKC_CONTRACT_PVT.delete_contract_line(
            p_api_version                  => l_api_version,
            p_init_msg_list                => l_init_msg_list,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data,
            --p_clev_rec                     => l_clev_rec);
            p_line_id                      => p_line_id);
If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
            OKC_API.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            'Error in deleting contract lines.'
                            );
            RAISE G_EXCEPTION_HALT_VALIDATION;
End if;



x_return_status := l_return_status;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status := l_return_status;
  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message
          (G_APP_NAME,
           G_UNEXPECTED_ERROR,
           G_SQLCODE_TOKEN,
           SQLCODE,
           G_SQLERRM_TOKEN,
           SQLERRM);
End Delete_Contract_Line;

-- Line Cancellation --
-- New procedure added to find if a contract thats going to be deleted
-- has lines or covered levels that has been renewed on another contract
PROCEDURE Delete_Transfer_Contract(
    p_api_version	IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chr_id            IN NUMBER,
    p_cle_id            IN NUMBER  DEFAULT NULL,
    p_intent            IN VARCHAR2, -- new
    x_contract_number   OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2) IS

    CURSOR cur_has_lines_been_renewed_h IS	-- header
    SELECT 1
    FROM okc_operation_lines a, okc_operation_instances b, okc_class_operations  c
    where a.object_chr_id= p_chr_id and
          c.id=b.cop_id and
	  c.opn_code in('RENEWAL', 'REN_CON') and
	  a.oie_id=b.id and
	  a.active_yn='Y';


    CURSOR cur_has_lines_been_renewed_l IS	 -- topline
    SELECT subject_cle_id
    FROM okc_operation_lines a,
         okc_operation_instances b,
         okc_class_operations  c,
         okc_k_lines_b  d
    where a.object_cle_id = d.id and
      d.cle_id = p_cle_id and  -- should be a top line id
      a.object_chr_id = p_chr_id and
	  c.id=b.cop_id and
	  c.opn_code in('RENEWAL', 'REN_CON') and
	  a.oie_id=b.id and
	  a.active_yn='Y' and
	  a.object_chr_id = d.dnz_chr_id;


    CURSOR cur_has_lines_been_renewed_s IS -- Subline
    SELECT subject_chr_id
    FROM okc_operation_lines a, okc_operation_instances b, okc_class_operations  c
    where a.object_cle_id=  p_cle_id and -- subline id
	  c.id=b.cop_id and
	  c.opn_code in('RENEWAL', 'REN_CON') and
	  a.oie_id=b.id and
	  a.active_yn='Y' and
	  a.object_chr_id = p_chr_id;



    Cursor cur_get_contract_number(p_subject_chr_id number) IS
    SELECT contract_number , contract_number_modifier
    From   okc_k_headers_b b
    where  id = p_subject_chr_id;

    l_result NUMBER;
    l_sub_cle_id               okc_operation_lines.subject_cle_id%TYPE;
    l_sub_chr_id		okc_operation_lines.subject_chr_id%TYPE;
    l_contract_number           OKC_K_HEADERS_B.contract_number%type;
    l_contract_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%type;

BEGIN
  IF p_chr_id IS NOT NULL AND p_cle_id IS NULL
  THEN
    Open cur_has_lines_been_renewed_h;
    fetch cur_has_lines_been_renewed_h into l_result;
    IF cur_has_lines_been_renewed_h%NOTFOUND
    THEN
	x_return_status:='S';
    ELSE
	x_return_status:='W';
    END IF;
    Close cur_has_lines_been_renewed_h;
  ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NOT NULL
  THEN
   -- Called from Topline
   IF nvl(p_intent, 'X') =  'T' -- Topline
   THEN
	Open cur_has_lines_been_renewed_l;
	Fetch cur_has_lines_been_renewed_l into l_sub_cle_id;
	IF cur_has_lines_been_renewed_l%NOTFOUND
	THEN
	   x_return_status :='S';
	ELSE
	   x_return_status :='W';
        END IF;
        Close cur_has_lines_been_renewed_l;
   ELSIF   nvl(p_intent, 'X') =  'S'  --Subline
   THEN
	Open cur_has_lines_been_renewed_s;
	Fetch cur_has_lines_been_renewed_s into l_sub_chr_id;
	IF cur_has_lines_been_renewed_s%NOTFOUND
	THEN
	   x_return_status :='S';
	ELSE

	   open cur_get_contract_number(l_sub_chr_id);
	   fetch cur_get_contract_number Into l_contract_number,l_contract_modifier;
           close cur_get_contract_number;

	   IF l_contract_modifier is NOT NULL
           THEN
	      x_contract_number:=l_contract_number || '-' || l_contract_modifier;
           ELSE
              x_contract_number:=l_contract_number;
           END IF;

	   x_return_status :='W';
        END IF;

        Close cur_has_lines_been_renewed_s;

   END IF; -- IF nvl(p_intent, 'X') =  'T'
  END IF;
EXCEPTION
WHEN OTHERS THEN
 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message
          (G_APP_NAME,
           G_UNEXPECTED_ERROR,
           G_SQLCODE_TOKEN,
           SQLCODE,
           G_SQLERRM_TOKEN,
           SQLERRM);
END Delete_Transfer_Contract;
-- Line Cancellation --

    /*
    New procedure to delete toplines an sublines for OKS. This builds on
    OKS_SETUP_UTIL_PUB.Delete_Contract_Line and adds stuff that authoring does and some other
    stuff that nobody seems to be doing

    Parameters
        p_line_id   :   id of the top line/subline from OKC_K_LINES_B table
    */

    PROCEDURE DELETE_TOP_SUB_LINE
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_line_id IN NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2
    )
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'DELETE_TOP_SUB_LINE';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    CURSOR c_chk_transfer(cp_line_id IN NUMBER) IS
        SELECT id
        FROM okc_k_lines_b a
        WHERE (a.id = cp_line_id OR a.cle_id = cp_line_id)
        AND lse_id IN (1,12,14,19,46, 7,8,9,10,11,35, 13, 18, 25)
        AND nvl(term_cancel_source, 'X') IN ('IBTRANSFER', 'IBTERMINATE', 'IBRETURN');

    CURSOR c_get_line_type(cp_line_id IN NUMBER) IS
        SELECT a.lse_id, a.cle_id, a.cust_acct_id, a.bill_to_site_use_id,
        b.locked_price_list_line_id, b.trxn_extension_id
        FROM okc_k_lines_b a, oks_k_lines_b b
        WHERE a.id = cp_line_id
        AND b.cle_id = a.id;

    CURSOR c_usage_sub_lines(cp_line_id IN NUMBER) IS
        SELECT b.locked_price_list_line_id
        FROM okc_k_lines_b a, oks_k_lines_b b
        WHERE a.cle_id = cp_line_id
        AND b.cle_id = a.id;

    CURSOR c_get_child_lines(cp_line_id IN NUMBER) IS
        SELECT id
        FROM okc_k_lines_b
        CONNECT BY PRIOR id = cle_id
        START WITH id = cp_line_id;

    CURSOR c_party_from_billto(cp_bill_to_site_use_id IN NUMBER) IS
        SELECT cas.cust_account_id cust_account_id, ca.party_id party_id
        FROM hz_cust_site_uses_all csu, hz_cust_acct_sites_all cas, hz_cust_accounts_all ca
        WHERE csu.site_use_id = cp_bill_to_site_use_id
        AND cas.cust_acct_site_id = csu.cust_acct_site_id
        AND ca.cust_account_id = cas.cust_account_id;

    CURSOR c_party_from_cust(cp_cust_acct_id IN NUMBER) IS
        SELECT ca.party_id party_id
        FROM hz_cust_accounts_all ca
        WHERE ca.cust_account_id = cp_cust_acct_id;

    CURSOR c_get_notes(cp_source_object_id IN NUMBER) IS
          SELECT jtf_note_id
          FROM JTF_NOTES_VL
          WHERE source_object_id = cp_source_object_id
          AND   source_object_code = 'OKS_COV_NOTE';

    l_lse_id                NUMBER;
    l_parent_id             NUMBER;
    l_lock_pl_line_id       NUMBER;
    l_trxn_extension_id     NUMBER;
    l_cust_account_id       NUMBER;
    l_bill_to_site_use_id   NUMBER;

    l_transfer_id           NUMBER;
    l_id_tbl                num_tbl_type;
    l_lock_pl_line_id_tbl   num_tbl_type;
    l_jtf_note_id_tbl       num_tbl_type;

    l_payer                 IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_response              IBY_FNDCPT_COMMON_PUB.result_rec_type;
    l_party_id              NUMBER;
    l_del_trxn              BOOLEAN;

    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_api_version=' || p_api_version ||' ,p_commit='|| p_commit ||' ,p_line_id='|| p_line_id);
            END IF;
        END IF;

        --standard api initilization and checks
        SAVEPOINT delete_top_sub_line_PUB;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_get_line_type(p_line_id);
        FETCH c_get_line_type INTO l_lse_id, l_parent_id, l_cust_account_id, l_bill_to_site_use_id,
        l_lock_pl_line_id, l_trxn_extension_id;
        CLOSE c_get_line_type;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.line_dtls', 'l_lse_id='||l_lse_id||' ,l_parent_id='||l_parent_id||' ,l_cust_account_id='||l_cust_account_id||' ,l_bill_to_site_use_id='||l_bill_to_site_use_id||
            ' ,l_lock_pl_line_id='||l_lock_pl_line_id||' ,l_trxn_extension_id='||l_trxn_extension_id);
        END IF;


        IF (l_lse_id IS NULL) THEN
            --nothing to delete!!, also serves as a check for p_line_id invalid or null
            RETURN;
        END IF;

        --these are valid top line and sub line lse ids
        IF (l_lse_id NOT IN (1,12,14,19,46, 7,8,9,10,11,35, 13, 18, 25)) THEN
            --we will not delete any other line types
            RETURN;
        END IF;

        --check if the line or any of it's sublines have been transfered/terminated/returned
        OPEN c_chk_transfer(p_line_id);
        FETCH c_chk_transfer INTO l_transfer_id;
        CLOSE c_chk_transfer;

        IF (l_transfer_id IS NOT NULL) THEN
            FND_MESSAGE.set_NAME(G_OKS_APP_NAME, 'OKS_TRANSFER_LINE_NO_DELETE');
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.transfer_check', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;


        --first delete the trxn_extension_id (credit card) if present
        IF l_trxn_extension_id IS NOT NULL THEN

            l_del_trxn := TRUE;

            --get the payer information from cust_acct or bill_to_site
            IF (l_cust_account_id IS NOT NULL) THEN
                OPEN c_party_from_cust(l_cust_account_id);
                FETCH c_party_from_cust INTO l_party_id;
                CLOSE c_party_from_cust;
            ELSIF (l_bill_to_site_use_id IS NOT NULL) THEN
                OPEN c_party_from_billto(l_bill_to_site_use_id);
                FETCH c_party_from_billto INTO l_cust_account_id, l_party_id;
                CLOSE c_party_from_billto;
            ELSE
                --cannot delete the trxn_extn without payer info
                l_del_trxn := FALSE;
            END IF;

            IF (l_del_trxn) THEN

                l_payer.payment_function := IBY_FNDCPT_COMMON_PUB.G_PMT_FUNCTION_CUST_PMT; --CUSTOMER_PAYMENT
                l_payer.party_id := l_party_id;
                l_payer.cust_account_id := l_cust_account_id;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.del_trxn_extn', 'calling IBY_FNDCPT_TRXN_PUB.delete_transaction_extension, p_payer.party_id='||l_party_id||' ,p_payer.cust_account_id='||l_cust_account_id||
                    ' ,p_entity_id='||l_trxn_extension_id);
                END IF;

                IBY_FNDCPT_TRXN_PUB.delete_transaction_extension(
                    p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_commit =>  FND_API.G_FALSE,
                    x_return_status => x_return_status,
                    x_msg_count   => x_msg_count,
                    x_msg_data    => x_msg_data,
                    p_payer       => l_payer,
                    --p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD, -- UPWARD
                    p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL, -- FULL, bug 5439978
                    p_entity_id         => l_trxn_extension_id,
                    x_response         => l_response);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.del_trxn_extn', 'after call to IBY_FNDCPT_TRXN_PUB.delete_transaction_extension, x_return_status='||x_return_status||
                    ' ,result_code='||l_response.result_code||' ,result_category='||l_response.result_category||' ,result_message='||l_response.result_message);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

                --also check the pmt api result code
                IF (l_response.result_code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
                    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_response.result_message||'('||l_response.result_code||':'||l_response.result_category||')');
                    RAISE FND_API.g_exc_error;
                END IF;

            END IF;
        END IF;

        --we only delete coverages for the top lines.
        IF l_lse_id IN (1, 14, 19) THEN
             -- Deletes coverages and coverage entities
            OKS_COVERAGES_PUB.delete_coverage(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_service_line_id => p_line_id);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_coverage', 'after call to OKS_COVERAGES_PUB.delete_coverage, x_return_status='||x_return_status);
            END IF;

            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

            --delete coverage notes if any
            OPEN c_get_notes(p_line_id);
            LOOP
                FETCH c_get_notes BULK COLLECT INTO l_jtf_note_id_tbl LIMIT G_BULK_FETCH_LIMIT;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_get_notes_bulk_fetch', 'l_jtf_note_id_tbl.count=,'||l_jtf_note_id_tbl.count);
                END IF;

                EXIT WHEN (l_jtf_note_id_tbl.count = 0);

                -- Call API to delete coverage notes, if exists **/
                FOR i in l_jtf_note_id_tbl.first..l_jtf_note_id_tbl.last LOOP

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_cov_notes', 'calling JTF_NOTES_PUB.secure_delete_note, p_jtf_note_id='||l_jtf_note_id_tbl(i));
                    END IF;

                    JTF_NOTES_PUB.secure_delete_note(
                        p_api_version           => 1.0,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_commit                => FND_API.G_FALSE,
                        p_validation_level     => 100,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data ,
                        p_jtf_note_id          => l_jtf_note_id_tbl(i),
                        p_use_AOL_security     => FND_API.G_FALSE);


                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_cov_notes', 'after call to JTF_NOTES_PUB.secure_delete_note, x_return_status='||x_return_status);
                    END IF;

                    IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;

                END LOOP; --of FOR i in l_jtf_note_id_tbl.first..

            END LOOP; --c_get_notes bulk fetch loop
            CLOSE c_get_notes;


            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_cov_notes', 'calling OKS_PM_PROGRAMS_PVT.undo_pm_line, p_cle_id='||p_line_id);
            END IF;

            --delete PM schedules
            OKS_PM_PROGRAMS_PVT.undo_pm_line(
                p_api_version                   => 1.0,
                p_init_msg_list                 => FND_API.G_FALSE,
                x_return_status                 => x_return_status,
                x_msg_count                     => x_msg_count,
                x_msg_data                      => x_msg_data,
                p_cle_id                        => p_line_id);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_cov_notes', 'after call to OKS_PM_PROGRAMS_PVT.undo_pm_line, x_return_status='||x_return_status);
            END IF;

            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

        END IF; --of IF l_lse_id IN (1, 14, 19) THEN

        --delete usage price breaks
        IF l_lse_id IN (12, 13) THEN

            -- Call API to delete locked price breaks, if exists **/
            IF l_lock_pl_line_id IS NOT NULL THEN
                OKS_QP_PKG.delete_locked_pricebreaks(
                    p_api_version => 1.0,
                    p_list_line_id => l_lock_pl_line_id,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status  => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_locked_pricebreaks', 'after call to OKS_QP_PKG.delete_locked_pricebreaks, x_return_status='||x_return_status);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;
            END IF;

            --if usage top line, then delete price breaks for all usage sublines also
            IF (l_lse_id = 12) THEN

                OPEN c_usage_sub_lines(p_line_id);
                LOOP
                    FETCH c_usage_sub_lines BULK COLLECT INTO l_lock_pl_line_id_tbl LIMIT G_BULK_FETCH_LIMIT;

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_usage_sub_lines_bulk_fetch', 'l_lock_pl_line_id_tbl.count=,'||l_lock_pl_line_id_tbl.count);
                    END IF;

                    EXIT WHEN (l_lock_pl_line_id_tbl.count = 0);

                    -- Call API to delete locked price breaks, if exists **/
                    FOR i in l_lock_pl_line_id_tbl.first..l_lock_pl_line_id_tbl.last LOOP
                        IF (l_lock_pl_line_id_tbl(i) IS NOT NULL) THEN
                            OKS_QP_PKG.delete_locked_pricebreaks(
                                p_api_version => 1.0,
                                p_list_line_id => l_lock_pl_line_id_tbl(i),
                                p_init_msg_list => FND_API.G_FALSE,
                                x_return_status  => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);

                            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_locked_pricebreaks_sub', 'after call to OKS_QP_PKG.delete_locked_pricebreaks, x_return_status='||x_return_status);
                            END IF;

                            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                                RAISE FND_API.g_exc_unexpected_error;
                            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                                RAISE FND_API.g_exc_error;
                            END IF;

                        END IF; --of IF (l_lock_pl_line_id IS NOT NULL) THEN

                    END LOOP; --of FOR i in l_lock_pl_line_id_tbl.first..

                END LOOP; --usage subline bulk fetch loop
                CLOSE c_usage_sub_lines;

            END IF; --of IF (l_lse_id = 12) THEN

        END IF; --of IF l_lse_id IN (12, 13) THEN

        --delete subscription information
        IF (l_lse_id = 46) THEN
            OKS_SUBSCRIPTION_PUB.undo_subscription(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_cle_id => p_line_id);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.Undo_Subscription', 'after call to OKS_SUBSCRIPTION_PUB.Undo_Subscription, x_return_status='||x_return_status);
            END IF;

            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

        END IF;

        -- Fix for deleting billing schedules for lines that do have billing schedules.
        IF l_lse_id IN (1, 7, 8, 9, 10, 11, 12, 13, 14, 18, 19, 25, 35, 46) THEN
            --delete OKS billing schedule
            IF l_parent_id IS NULL THEN

                -- will delete all the existing SLH, SLL and level elements for top line and its sub lines
                OKS_BILL_SCH.del_rul_elements(
                    p_top_line_id => p_line_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.del_rul_elements', 'after call to OKS_BILL_SCH.del_rul_elements, x_return_status='||x_return_status);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

            ELSE

                OKS_BILL_SCH.del_subline_lvl_rule(
                    p_top_line_id => l_parent_id,
                    p_sub_line_id => p_line_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.del_subline_lvl_rule', 'after call to OKS_BILL_SCH.del_subline_lvl_rule, x_return_status='||x_return_status);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

            END IF; --of IF l_parent_id IS NULL THEN
        END IF; --of IF l_lse_id IN (1, 7, 8, 9, 10, 11, 12, 13, 14, 18, 19, 25, 35, 46) THEN


        --delete all oks lines and it's entities
        --child OKS lines (b and tl tables), child entities such as OKS sales credits,
        --rev distributions, qaulifiers
        OPEN c_get_child_lines(p_line_id);
        LOOP
            FETCH c_get_child_lines BULK COLLECT INTO l_id_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_get_child_lines_bulk_fetch', 'l_id_tbl.count='||l_id_tbl.count);
                END IF;
            END IF;
            EXIT WHEN (l_id_tbl.count = 0);

            --delete all OKS_K_LINES_TL records
            FORALL i IN l_id_tbl.first..l_id_tbl.last
                DELETE FROM oks_k_lines_tl WHERE id IN
                    (SELECT id FROM oks_k_lines_b WHERE cle_id = l_id_tbl(i));

            --delete all OKS_K_LINES_B records
            FORALL i IN l_id_tbl.first..l_id_tbl.last
                DELETE FROM oks_k_lines_b WHERE cle_id  = l_id_tbl(i);

            --delete all OKS_K_SALES_CREDITS records
            FORALL i IN l_id_tbl.first..l_id_tbl.last
                DELETE FROM oks_k_sales_credits WHERE cle_id = l_id_tbl(i);

            --delete all OKS_REV_DISTRIBUTIONS records
            FORALL i IN l_id_tbl.first..l_id_tbl.last
                DELETE FROM oks_rev_distributions WHERE cle_id = l_id_tbl(i);

            --delete all OKS_QUALIFIERS records
            FORALL i IN l_id_tbl.first..l_id_tbl.last
                DELETE FROM OKS_QUALIFIERS WHERE list_line_id = l_id_tbl(i);

        END LOOP;
        CLOSE  c_get_child_lines;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_oks_entities', 'done');
            END IF;
        END IF;

        --call OKC API to delete all OKC lines and entities. This deletes all OKC entities and
        --the OKC sublines
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_okc_entities', 'calling  OKC_CONTRACT_PVT.delete_contract_line, p_line_id='||p_line_id);
        END IF;
        OKC_CONTRACT_PVT.delete_contract_line(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_line_id => p_line_id);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_okc_entities', 'after call to OKC_CONTRACT_PVT.delete_contract_line, x_return_status='||x_return_status);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;


        --standard check of p_commit
	    IF FND_API.to_boolean( p_commit ) THEN
		    COMMIT;
	    END IF;
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', ' x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO delete_top_sub_line_PUB;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_get_line_type%isopen) THEN
                CLOSE c_get_line_type;
            END IF;
            IF (c_get_child_lines%isopen) THEN
                CLOSE c_get_child_lines;
            END IF;
            IF (c_usage_sub_lines%isopen) THEN
                CLOSE c_usage_sub_lines;
            END IF;
            IF (c_chk_transfer%isopen) THEN
                CLOSE c_chk_transfer;
            END IF;
            IF (c_party_from_cust%isopen) THEN
                CLOSE c_party_from_cust;
            END IF;
            IF (c_party_from_billto%isopen) THEN
                CLOSE c_party_from_billto;
            END IF;
            IF (c_get_notes%isopen) THEN
                CLOSE c_get_notes;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO delete_top_sub_line_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_get_line_type%isopen) THEN
                CLOSE c_get_line_type;
            END IF;
            IF (c_get_child_lines%isopen) THEN
                CLOSE c_get_child_lines;
            END IF;
            IF (c_usage_sub_lines%isopen) THEN
                CLOSE c_usage_sub_lines;
            END IF;
            IF (c_chk_transfer%isopen) THEN
                CLOSE c_chk_transfer;
            END IF;
            IF (c_party_from_cust%isopen) THEN
                CLOSE c_party_from_cust;
            END IF;
            IF (c_party_from_billto%isopen) THEN
                CLOSE c_party_from_billto;
            END IF;
            IF (c_get_notes%isopen) THEN
                CLOSE c_get_notes;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO delete_top_sub_line_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_get_line_type%isopen) THEN
                CLOSE c_get_line_type;
            END IF;
            IF (c_get_child_lines%isopen) THEN
                CLOSE c_get_child_lines;
            END IF;
            IF (c_usage_sub_lines%isopen) THEN
                CLOSE c_usage_sub_lines;
            END IF;
            IF (c_chk_transfer%isopen) THEN
                CLOSE c_chk_transfer;
            END IF;
            IF (c_party_from_cust%isopen) THEN
                CLOSE c_party_from_cust;
            END IF;
            IF (c_party_from_billto%isopen) THEN
                CLOSE c_party_from_billto;
            END IF;
            IF (c_get_notes%isopen) THEN
                CLOSE c_get_notes;
            END IF;

    END DELETE_TOP_SUB_LINE;

--Npalepu added on 30-nov-2005 for bug # 4768227.
--New Function Get_Annualized_Factor is added to calculate the Annualized_Factor provided start_date,end_date and lse_id.
FUNCTION Get_Annualized_Factor(p_start_date   IN DATE,
                               p_end_date     IN DATE,
                               p_lse_id       IN NUMBER)
RETURN NUMBER
AS
l_annualized_factor     NUMBER;

CURSOR Cal_Annualized_Factor_csr(v_start_date IN DATE,v_end_date IN DATE,v_lse_id IN NUMBER) IS
SELECT (ADD_MONTHS(v_start_date, (nyears+1)*12) - v_start_date -
        DECODE(ADD_MONTHS(v_end_date, -12),( v_end_date-366), 0,
        DECODE(ADD_MONTHS(v_start_date, (nyears+1)*12) - ADD_MONTHS(v_start_date, nyears*12), 366, 1, 0)))
        / (nyears+1) /(v_end_date-v_start_date+1)
FROM  (SELECT trunc(MONTHS_BETWEEN(v_end_date, v_start_date)/12) nyears FROM dual)  dual ;

BEGIN

    IF p_lse_id in (1,12,14,19,46,7,8,9,10,11,13,18,25,35) THEN
          OPEN Cal_Annualized_Factor_csr(p_start_date,p_end_date,p_lse_id);
          FETCH Cal_Annualized_Factor_csr into l_annualized_factor;
          CLOSE Cal_Annualized_Factor_csr;
    ELSE
          l_annualized_factor := 0;
    END IF;

    RETURN l_annualized_factor;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
          l_annualized_factor := 0;
          RETURN l_annualized_factor;
    WHEN OTHERS THEN
          l_annualized_factor := 0;
          RETURN l_annualized_factor;

END Get_Annualized_Factor;
--end bug # 4768227

--npalepu added on 15-dec-2005 for bug # 4886786
PROCEDURE Update_Annualized_Factor_BMGR(X_errbuf     out NOCOPY varchar2,
                                        X_retcode    out NOCOPY varchar2,
                                        P_batch_size  in number,
                                        P_Num_Workers in number)
IS
BEGIN
--
-- Manager processing for OKC_K_LINES_B table
--
        fnd_file.put_line(FND_FILE.LOG, 'Start of Update_Annualized_Factor_BMGR ');
        fnd_file.put_line(FND_FILE.LOG, '  P_batch_size : '||P_batch_size);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'starting okc_k_lines_b update worker ');

        AD_CONC_UTILS_PKG.submit_subrequests(X_errbuf,
                                             X_retcode,
                                             'OKS',
                                             'OKSUBAFWKR',
                                             P_batch_size,
                                             P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'X_errbuf  : '||X_errbuf);
        fnd_file.put_line(FND_FILE.LOG, 'X_retcode : '||X_retcode);

END Update_Annualized_Factor_BMGR;

PROCEDURE Update_Annualized_Factor_HMGR(X_errbuf     out NOCOPY varchar2,
                                        X_retcode    out NOCOPY varchar2,
                                        P_batch_size  in number,
                                        P_Num_Workers in number)
IS
BEGIN
--
-- Manager processing for OKC_K_LINES_BH table
--
        fnd_file.put_line(FND_FILE.LOG, 'Start of Update_Annualized_Factor_HMGR ');
        fnd_file.put_line(FND_FILE.LOG, '  P_batch_size : '||P_batch_size);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'starting okc_k_lines_bh update worker ');

        AD_CONC_UTILS_PKG.submit_subrequests(X_errbuf,
                                             X_retcode,
                                             'OKS',
                                             'OKSUHAFWKR',
                                             P_batch_size,
                                             P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'X_errbuf  : '||X_errbuf);
        fnd_file.put_line(FND_FILE.LOG, 'X_retcode : '||X_retcode);

END Update_Annualized_Factor_HMGR;

PROCEDURE Update_Annualized_Factor_BWKR(X_errbuf     out NOCOPY varchar2,
                                        X_retcode    out NOCOPY varchar2,
                                        P_batch_size  in number,
                                        P_Worker_Id   in number,
                                        P_Num_Workers in number)
IS
l_worker_id             number;
l_product               varchar2(30) := 'OKC';
l_table_name            varchar2(30) := 'OKC_K_HEADERS_ALL_B';
l_update_name           varchar2(30) := 'OKCLNUPG_CP';
l_status                varchar2(30);
l_industry              varchar2(30);
l_retstatus             boolean;
l_table_owner           varchar2(30);
l_any_rows_to_process   boolean;
l_start_rowid           rowid;
l_end_rowid             rowid;
l_rows_processed        number;
BEGIN
--
-- get schema name of the table for ROWID range processing
--
        l_retstatus := fnd_installation.get_app_info(l_product,
                                                     l_status,
                                                     l_industry,
                                                     l_table_owner);
        if ((l_retstatus = FALSE)  OR (l_table_owner is null))
        then
                raise_application_error(-20001,'Cannot get schema name for product : '||l_product);
        end if;

        fnd_file.put_line(FND_FILE.LOG, 'Start of upgrade script for OKC_K_LINES_B table ');
        fnd_file.put_line(FND_FILE.LOG, '  P_Worker_Id : '||P_Worker_Id);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

--
-- Worker processing
--
        BEGIN
                ad_parallel_updates_pkg.initialize_rowid_range(ad_parallel_updates_pkg.ROWID_RANGE,
                                                               l_table_owner,
                                                               l_table_name,
                                                               l_update_name,
                                                               P_worker_id,
                                                               P_num_workers,
                                                               P_batch_size,
                                                               0);
                ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                                         l_end_rowid,
                                                         l_any_rows_to_process,
                                                         P_batch_size,
                                                         TRUE);
                while (l_any_rows_to_process = TRUE)
                loop

                        UPDATE (Select /*+ rowid(hdr) leading(hdr) use_nl_with_index(cle)  */
                                   cle.payment_instruction_type,
                                   cle.annualized_factor,
                                   hdr.payment_instruction_type hdr_payment_instruction_type,
                                   case
                                   when cle.lse_id in (1, 12, 14, 19, 46, 7, 8, 9, 10, 11, 13, 18, 25, 35)
                                   then (add_months (cle.start_date, (trunc (months_between
                                        (cle.end_date, cle.start_date) / 12) + 1) * 12) -
                                         cle.start_date - decode (add_months (cle.end_date, -12),
                                        (cle.end_date-366), 0, decode ( add_months(cle.start_date,
                                        (trunc(months_between(cle.end_date, cle.start_date)
                                        / 12) + 1) * 12) - add_months(cle.start_date,
                                        trunc(months_between(cle.end_date, cle.start_date) / 12)
                                        * 12), 366, 1, 0)))
                                       / (trunc (months_between (cle.end_date, cle.start_date) / 12) + 1)
                                       / (cle.end_date - cle.start_date + 1)
                                   ELSE cle.annualized_factor
                                   end new_annualized_factor
                                from okc_k_headers_all_b hdr,
                                     okc_k_lines_b cle
                                where hdr.rowid between l_start_rowid and l_end_rowid
                                and hdr.id = cle.dnz_chr_id
                                and hdr.scs_code in ('SERVICE', 'WARRANTY', 'SUBSCRIPTION'))
                        set  payment_instruction_type = hdr_payment_instruction_type,
                             annualized_factor = new_annualized_factor;

                        l_rows_processed := SQL%ROWCOUNT;
                        ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,
                                                                      l_end_rowid);
                        commit;
                        ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
                                                                l_end_rowid,
                                                                l_any_rows_to_process,
                                                                P_batch_size,
                                                                FALSE);
                end loop;
                fnd_file.put_line(FND_FILE.LOG,'Upgrade for OKC_K_LINES_B table completed successfully');
                X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
                X_errbuf  := ' ';
        EXCEPTION
        WHEN OTHERS THEN
                X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
                X_errbuf  := SQLERRM;
                fnd_file.put_line(FND_FILE.LOG,'X_errbuf : '||X_errbuf);
                fnd_file.put_line(FND_FILE.LOG,'  ');
                raise;
        END;
END  Update_Annualized_Factor_BWKR;

PROCEDURE Update_Annualized_Factor_HWKR(X_errbuf     out NOCOPY varchar2,
                                        X_retcode    out NOCOPY varchar2,
                                        P_batch_size  in number,
                                        P_Worker_Id   in number,
                                        P_Num_Workers in number)
IS
l_worker_id             number;
l_product               varchar2(30) := 'OKC';
l_table_name            varchar2(30) := 'OKC_K_HEADERS_ALL_BH';
l_update_name           varchar2(30) := 'OKCLNUPH_CP';
l_status                varchar2(30);
l_industry              varchar2(30);
l_retstatus             boolean;
l_table_owner           varchar2(30);
l_any_rows_to_process   boolean;
l_start_rowid           rowid;
l_end_rowid             rowid;
l_rows_processed        number;
BEGIN
--
-- get schema name of the table for ROWID range processing
--
        l_retstatus := fnd_installation.get_app_info(l_product,
                                                     l_status,
                                                     l_industry,
                                                     l_table_owner);
        if ((l_retstatus = FALSE)  OR (l_table_owner is null))
        then
                raise_application_error(-20001,'Cannot get schema name for product : '||l_product);
        end if;

        fnd_file.put_line(FND_FILE.LOG, 'Start of upgrade script for OKC_K_LINES_BH table ');
        fnd_file.put_line(FND_FILE.LOG, '  P_Worker_Id : '||P_Worker_Id);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

--
-- Worker processing
--
        BEGIN
                ad_parallel_updates_pkg.initialize_rowid_range(ad_parallel_updates_pkg.ROWID_RANGE,
                                                               l_table_owner,
                                                               l_table_name,
                                                               l_update_name,
                                                               P_worker_id,
                                                               P_num_workers,
                                                               P_batch_size,
                                                               0);
                ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                                         l_end_rowid,
                                                         l_any_rows_to_process,
                                                         P_batch_size,
                                                         TRUE);
                while (l_any_rows_to_process = TRUE)
                loop
                        UPDATE (Select /*+ rowid(hdr) leading(hdr) use_nl_with_index(cle)  */
                                   cle.payment_instruction_type,
                                   cle.annualized_factor,
                                   hdr.payment_instruction_type hdr_payment_instruction_type,
                                   case
                                   when cle.lse_id in (1, 12, 14, 19, 46, 7, 8, 9, 10, 11, 13, 18, 25, 35)
                                   then (add_months (cle.start_date, (trunc (months_between
                                        (cle.end_date, cle.start_date) / 12) + 1) * 12) -
                                         cle.start_date - decode (add_months (cle.end_date, -12),
                                        (cle.end_date-366), 0, decode ( add_months(cle.start_date,
                                        (trunc(months_between(cle.end_date, cle.start_date)
                                        / 12) + 1) * 12) - add_months(cle.start_date,
                                        trunc(months_between(cle.end_date, cle.start_date) / 12)
                                        * 12), 366, 1, 0)))
                                       / (trunc (months_between (cle.end_date, cle.start_date) / 12) + 1)
                                       / (cle.end_date - cle.start_date + 1)
                                   ELSE cle.annualized_factor
                                   end new_annualized_factor
                                from okc_k_headers_all_bh hdr,
                                     okc_k_lines_bh cle
                                where hdr.rowid between l_start_rowid and l_end_rowid
                                and hdr.id = cle.dnz_chr_id
                                and hdr.major_version = cle.major_version
                                and hdr.scs_code in ('SERVICE', 'WARRANTY', 'SUBSCRIPTION'))
                        set  payment_instruction_type = hdr_payment_instruction_type,
                             annualized_factor = new_annualized_factor;

                        l_rows_processed := SQL%ROWCOUNT;
                        ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,
                                                                      l_end_rowid);
                        commit;
                        ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
                                                                l_end_rowid,
                                                                l_any_rows_to_process,
                                                                P_batch_size,
                                                                FALSE);
                end loop;
                fnd_file.put_line(FND_FILE.LOG,'Upgrade for OKC_K_LINES_BH table completed successfully');
                X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
                X_errbuf  := ' ';
        EXCEPTION
        WHEN OTHERS THEN
                X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
                X_errbuf  := SQLERRM;
                fnd_file.put_line(FND_FILE.LOG,'X_errbuf : '||X_errbuf);
                fnd_file.put_line(FND_FILE.LOG,'  ');
                raise;
        END;
END  Update_Annualized_Factor_HWKR;
--end npalepu


END OKS_SETUP_UTIL_PUB;

/

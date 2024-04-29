--------------------------------------------------------
--  DDL for Package Body OKL_CS_LEASE_RENEWAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_LEASE_RENEWAL_PVT" AS
/* $Header: OKLRKLRB.pls 120.4 2008/04/22 14:07:35 nikshah ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN           CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD            CONSTANT  VARCHAR2(200) := 'NO_PARENT_RECORD';
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'REQUIRED_VALUE';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

-----------------------------------------------------------------------------------
 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_CS_LEASE_RENEWAL';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

   subtype khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
   subtype chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  TYPE kle_rec_type IS RECORD (
    ID          OKL_K_LINES_V.ID%TYPE
  );

  TYPE kle_tbl_type IS TABLE OF kle_rec_type INDEX BY BINARY_INTEGER;



----------------------------------------------------------------
----------------------------------------------------------------


  FUNCTION get_status
   (p_request_id	IN	NUMBER)
   RETURN VARCHAR2

  AS

    CURSOR c_cs_status_csr (a_id IN NUMBER)
	IS
    SELECT request_status_code,
	   object1_id1,
	   jtot_object1_code
    FROM okl_trx_requests
    where id=a_id;

    CURSOR c_supertrump_csr (a_id IN NUMBER)
	IS
    SELECT sis_code
    FROM   okl_stream_interfaces
    WHERE  ID=a_id;

	l_status_code	VARCHAR2(80);
	l_object1_id1	VARCHAR2(40);
	l_object1_code	VARCHAR2(30);
	l_sis_code	VARCHAR2(80);

  BEGIN

	OPEN c_cs_Status_csr(p_request_id);
	FETCH c_cs_Status_csr INTO l_status_code,l_object1_id1,l_object1_code;
	CLOSE c_cs_Status_csr;

	IF l_status_code='SUBMITTED_CALCULATION' THEN
		--Still not processed, Check for the status in Streams table.
		IF l_object1_code = 'OKL_STREAM_INTERFACES' THEN
			open c_supertrump_csr(l_object1_id1);
			FETCH c_supertrump_csr INTO l_sis_code;
			CLOSE c_supertrump_csr;
		END IF;
		l_status_code :=l_sis_code;
	END IF;
	RETURN l_status_code;

  END get_status;



  FUNCTION get_current_lease_values
  (p_khr_id		IN	NUMBER)
   RETURN lease_details_tbl_type

   AS

 -- streams filtered on purpose 'RENT' and amounts summed up
 -- for user defined streams enhancements, bug 3924303
     CURSOR c_rent_csr(a_khr_id IN  NUMBER)
     IS
     select c.amount
     from
     okl_streams a,
     okl_strm_type_b b,
     okl_strm_elements c
     where
     a.sty_id=b.id
     and b.stream_type_purpose ='RENT'
     and nvl(b.start_date,sysdate) <= sysdate
     and nvl(b.end_date,sysdate) >= sysdate
     and c.stm_id=a.id
     and a.say_code='CURR'
     and a.active_yn = 'Y'
      --multigaap changes
      AND a.PURPOSE_CODE IS NULL
     --end multigaap changes
     and to_char(c.stream_element_date,'MM-YYYY')=to_char(sysdate,'MM-YYYY')
     and khr_id = a_khr_id;

     CURSOR c_okc_k_hdr_csr(a_khr_id IN NUMBER)
     IS
     SELECT start_Date,end_date
     FROM
     okc_k_headers_b
     where id = a_khr_id;

     cursor c_okl_k_hdr_csr(a_khr_id IN NUMBER)
     IS
     SELECT term_Duration,after_tax_yield
     FROM
     okl_k_headers
     where id = a_khr_id;

     l_lease_details_tbl	lease_details_tbl_type;

     BEGIN

       -- Get current database values
       OPEN c_rent_csr (p_khr_id);
       FETCH c_rent_csr INTO l_lease_details_tbl(1).rent;
       CLOSE c_rent_csr;

       OPEN c_okc_k_hdr_csr (p_khr_id);
       FETCH c_okc_k_hdr_csr INTO l_lease_details_tbl(1).start_date,
       			     l_lease_details_tbl(1).end_date;

       CLOSE c_okc_k_hdr_csr;

       OPEN c_okl_k_hdr_csr (p_khr_id);
       FETCH c_okl_k_hdr_csr INTO l_lease_details_tbl(1).term_duration,
       			     l_lease_details_tbl(1).yield;

       CLOSE c_okl_k_hdr_csr;
       RETURN(l_lease_details_tbl);
    END get_current_lease_values;


------------------------------------------------------------------
--Functions to Fetch Data from Tables.
-----------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- FUNCTION get_chrv_rec for: OKC_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_chrv_rec (p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                         x_return_status OUT NOCOPY VARCHAR2)
  RETURN chrv_rec_type IS
    CURSOR okc_chrv_pk_csr(p_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           CHR_ID_RESPONSE,
           CHR_ID_AWARD,
           INV_ORGANIZATION_ID,
           STS_CODE,
           QCL_ID,
           SCS_CODE,
           CONTRACT_NUMBER,
           CURRENCY_CODE,
           CONTRACT_NUMBER_MODIFIER,
           ARCHIVED_YN,
           DELETED_YN,
           CUST_PO_NUMBER_REQ_YN,
           PRE_PAY_REQ_YN,
           CUST_PO_NUMBER,
           SHORT_DESCRIPTION,
           COMMENTS,
           DESCRIPTION,
           DPAS_RATING,
           COGNOMEN,
           TEMPLATE_YN,
           TEMPLATE_USED,
           DATE_APPROVED,
           DATETIME_CANCELLED,
           AUTO_RENEW_DAYS,
           DATE_ISSUED,
           DATETIME_RESPONDED,
           NON_RESPONSE_REASON,
           NON_RESPONSE_EXPLAIN,
           RFP_TYPE,
           CHR_TYPE,
           KEEP_ON_MAIL_LIST,
           SET_ASIDE_REASON,
           SET_ASIDE_PERCENT,
           RESPONSE_COPIES_REQ,
           DATE_CLOSE_PROJECTED,
           DATETIME_PROPOSED,
           DATE_SIGNED,
           DATE_TERMINATED,
           DATE_RENEWED,
           TRN_CODE,
           START_DATE,
           END_DATE,
           AUTHORING_ORG_ID,
           BUY_OR_SELL,
           ISSUE_OR_RECEIVE,
           ESTIMATED_AMOUNT,
           ESTIMATED_AMOUNT_RENEWED,
           CURRENCY_CODE_RENEWED,
           UPG_ORIG_SYSTEM_REF,
           UPG_ORIG_SYSTEM_REF_ID,
           APPLICATION_ID,
           ORIG_SYSTEM_SOURCE_CODE,
           ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_REFERENCE1,
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
           LAST_UPDATE_LOGIN
     FROM okc_k_headers_v chrv
     WHERE chrv.id = p_id;
     x_chrv_rec chrv_rec_type;
  BEGIN
    OPEN okc_chrv_pk_csr (p_chr_id);
    FETCH okc_chrv_pk_csr INTO
          x_chrv_rec.ID,
          x_chrv_rec.OBJECT_VERSION_NUMBER,
          x_chrv_rec.SFWT_FLAG,
          x_chrv_rec.CHR_ID_RESPONSE,
          x_chrv_rec.CHR_ID_AWARD,
          x_chrv_rec.INV_ORGANIZATION_ID,
          x_chrv_rec.STS_CODE,
          x_chrv_rec.QCL_ID,
          x_chrv_rec.SCS_CODE,
          x_chrv_rec.CONTRACT_NUMBER,
          x_chrv_rec.CURRENCY_CODE,
          x_chrv_rec.CONTRACT_NUMBER_MODIFIER,
          x_chrv_rec.ARCHIVED_YN,
          x_chrv_rec.DELETED_YN,
          x_chrv_rec.CUST_PO_NUMBER_REQ_YN,
          x_chrv_rec.PRE_PAY_REQ_YN,
          x_chrv_rec.CUST_PO_NUMBER,
          x_chrv_rec.SHORT_DESCRIPTION,
          x_chrv_rec.COMMENTS,
          x_chrv_rec.DESCRIPTION,
          x_chrv_rec.DPAS_RATING,
          x_chrv_rec.COGNOMEN,
          x_chrv_rec.TEMPLATE_YN,
          x_chrv_rec.TEMPLATE_USED,
          x_chrv_rec.DATE_APPROVED,
          x_chrv_rec.DATETIME_CANCELLED,
          x_chrv_rec.AUTO_RENEW_DAYS,
          x_chrv_rec.DATE_ISSUED,
          x_chrv_rec.DATETIME_RESPONDED,
          x_chrv_rec.NON_RESPONSE_REASON,
          x_chrv_rec.NON_RESPONSE_EXPLAIN,
          x_chrv_rec.RFP_TYPE,
          x_chrv_rec.CHR_TYPE,
          x_chrv_rec.KEEP_ON_MAIL_LIST,
          x_chrv_rec.SET_ASIDE_REASON,
          x_chrv_rec.SET_ASIDE_PERCENT,
          x_chrv_rec.RESPONSE_COPIES_REQ,
          x_chrv_rec.DATE_CLOSE_PROJECTED,
          x_chrv_rec.DATETIME_PROPOSED,
          x_chrv_rec.DATE_SIGNED,
          x_chrv_rec.DATE_TERMINATED,
          x_chrv_rec.DATE_RENEWED,
          x_chrv_rec.TRN_CODE,
          x_chrv_rec.START_DATE,
          x_chrv_rec.END_DATE,
          x_chrv_rec.AUTHORING_ORG_ID,
          x_chrv_rec.BUY_OR_SELL,
          x_chrv_rec.ISSUE_OR_RECEIVE,
          x_chrv_rec.ESTIMATED_AMOUNT,
          x_chrv_rec.ESTIMATED_AMOUNT_RENEWED,
          x_chrv_rec.CURRENCY_CODE_RENEWED,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF_ID,
          x_chrv_rec.APPLICATION_ID,
          x_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
          x_chrv_rec.ORIG_SYSTEM_ID1,
          x_chrv_rec.ORIG_SYSTEM_REFERENCE1,
          x_chrv_rec.ATTRIBUTE_CATEGORY,
          x_chrv_rec.ATTRIBUTE1,
          x_chrv_rec.ATTRIBUTE2,
          x_chrv_rec.ATTRIBUTE3,
          x_chrv_rec.ATTRIBUTE4,
          x_chrv_rec.ATTRIBUTE5,
          x_chrv_rec.ATTRIBUTE6,
          x_chrv_rec.ATTRIBUTE7,
          x_chrv_rec.ATTRIBUTE8,
          x_chrv_rec.ATTRIBUTE9,
          x_chrv_rec.ATTRIBUTE10,
          x_chrv_rec.ATTRIBUTE11,
          x_chrv_rec.ATTRIBUTE12,
          x_chrv_rec.ATTRIBUTE13,
          x_chrv_rec.ATTRIBUTE14,
          x_chrv_rec.ATTRIBUTE15,
          x_chrv_rec.CREATED_BY,
          x_chrv_rec.CREATION_DATE,
          x_chrv_rec.LAST_UPDATED_BY,
          x_chrv_rec.LAST_UPDATE_DATE,
          x_chrv_rec.LAST_UPDATE_LOGIN;
    IF okc_chrv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_chrv_pk_csr;
    RETURN(x_chrv_rec);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              'SQLcode',
              SQLCODE,
              'SQLerrm',
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- if the cursor is open
      IF okc_chrv_pk_csr%ISOPEN THEN
         CLOSE okc_chrv_pk_csr;
      END IF;

  END get_chrv_rec;

  ---------------------------------------------------------------------------
  -- FUNCTION get_khrv_rec for: OKL_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_khrv_rec (
    p_khr_id                       IN  OKL_K_HEADERS_V.ID%TYPE,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN khrv_rec_type IS
    CURSOR okl_k_headers_v_pk_csr (p_id IN OKL_K_HEADERS_V.ID%TYPE) IS
      SELECT
        ID,
        OBJECT_VERSION_NUMBER,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        AMD_CODE,
        DATE_FIRST_ACTIVITY,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        DATE_REFINANCED,
        CREDIT_ACT_YN,
        TERM_DURATION,
        CONVERTED_ACCOUNT_YN,
        DATE_CONVERSION_EFFECTIVE,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_DEAL_TRANSFERRED,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN
      FROM OKL_K_HEADERS_V
      WHERE OKL_K_HEADERS_V.id     = p_id;
      l_okl_k_headers_v_pk     okl_k_headers_v_pk_csr%ROWTYPE;
      l_khrv_rec               khrv_rec_type;
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Get current database values
    OPEN okl_k_headers_v_pk_csr (p_khr_id);
    FETCH okl_k_headers_v_pk_csr INTO
       l_khrv_rec.ID,
        l_khrv_rec.OBJECT_VERSION_NUMBER,
        l_khrv_rec.ISG_ID,
        l_khrv_rec.KHR_ID,
        l_khrv_rec.PDT_ID,
        l_khrv_rec.AMD_CODE,
        l_khrv_rec.DATE_FIRST_ACTIVITY,
        l_khrv_rec.GENERATE_ACCRUAL_YN,
        l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_khrv_rec.DATE_REFINANCED,
        l_khrv_rec.CREDIT_ACT_YN,
        l_khrv_rec.TERM_DURATION,
        l_khrv_rec.CONVERTED_ACCOUNT_YN,
        l_khrv_rec.DATE_CONVERSION_EFFECTIVE,
        l_khrv_rec.SYNDICATABLE_YN,
        l_khrv_rec.SALESTYPE_YN,
        l_khrv_rec.DATE_DEAL_TRANSFERRED,
        l_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_khrv_rec.DATE_PROPOSAL_ACCEPTED,
        l_khrv_rec.ATTRIBUTE_CATEGORY,
        l_khrv_rec.ATTRIBUTE1,
        l_khrv_rec.ATTRIBUTE2,
        l_khrv_rec.ATTRIBUTE3,
        l_khrv_rec.ATTRIBUTE4,
        l_khrv_rec.ATTRIBUTE5,
        l_khrv_rec.ATTRIBUTE6,
        l_khrv_rec.ATTRIBUTE7,
        l_khrv_rec.ATTRIBUTE8,
        l_khrv_rec.ATTRIBUTE9,
        l_khrv_rec.ATTRIBUTE10,
        l_khrv_rec.ATTRIBUTE11,
        l_khrv_rec.ATTRIBUTE12,
        l_khrv_rec.ATTRIBUTE13,
        l_khrv_rec.ATTRIBUTE14,
        l_khrv_rec.ATTRIBUTE15,
        l_khrv_rec.CREATED_BY,
        l_khrv_rec.CREATION_DATE,
        l_khrv_rec.LAST_UPDATED_BY,
        l_khrv_rec.LAST_UPDATE_DATE,
        l_khrv_rec.LAST_UPDATE_LOGIN,
        l_khrv_rec.PRE_TAX_YIELD,
        l_khrv_rec.AFTER_TAX_YIELD,
        l_khrv_rec.IMPLICIT_INTEREST_RATE,
        l_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_khrv_rec.TARGET_PRE_TAX_YIELD,
        l_khrv_rec.TARGET_AFTER_TAX_YIELD,
        l_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_khrv_rec.DEAL_TYPE,
        l_khrv_rec.PRE_TAX_IRR,
        l_khrv_rec.AFTER_TAX_IRR,
        l_khrv_rec.EXPECTED_DELIVERY_DATE,
        l_khrv_rec.ACCEPTED_DATE,
        l_khrv_rec.PREFUNDING_ELIGIBLE_YN,
        l_khrv_rec.REVOLVING_CREDIT_YN
        ;
    IF okl_k_headers_v_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_k_headers_v_pk_csr;
    RETURN(l_khrv_rec);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              'SQLcode',
              SQLCODE,
              'SQLerrm',
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      -- if the cursor is open
      IF okl_k_headers_v_pk_csr%ISOPEN THEN
         CLOSE okl_k_headers_v_pk_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_khrv_rec;

 PROCEDURE create_working_copy(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
		p_commit		IN	VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER)
  AS
        l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_WORKING_COPY';
	l_seq_no	    NUMBER;
	l_orig_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
	l_new_contract_number  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
	l_khrv_rec             khrv_rec_type;
	x_khrv_rec             khrv_rec_type;
	l_chrv_rec             chrv_rec_type;
	x_chrv_rec             chrv_rec_type;



  CURSOR orig_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT contract_number
  FROM   okc_k_headers_v
  WHERE  id = p_chr_id;


   BEGIN

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	--Create the working copy here....

      -- Get Sequence Number to generate Contract Number
      SELECT okl_rbk_seq.nextval
      INTO   l_seq_no
      FROM   DUAL;

      -- Get Contract Number from Original Contract
      OPEN orig_csr(p_chr_id);
      FETCH orig_csr INTO l_orig_contract_number;

      IF orig_csr%NOTFOUND THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      CLOSE orig_csr;
      l_new_contract_number :=  l_orig_contract_number||'-LR'||l_seq_no;

      okl_copy_contract_pub.copy_lease_contract(
                                                 p_api_version              => 1.0,
                                                 p_init_msg_list            => OKC_API.G_FALSE,
                                                 x_return_status            => x_return_status,
                                                 x_msg_count                => x_msg_count,
                                                 x_msg_data                 => x_msg_data,
                                                 p_chr_id                   => p_chr_id,
                                                 p_contract_number          => l_new_contract_number,
                                                 p_contract_number_modifier => NULL,
                                                 p_renew_ref_yn             => 'N',
                                                 p_trans_type               => 'CRB',
                                                 x_chr_id                   => x_chr_id
                                                );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --
      -- Update Rebook Contract Status to 'NEW'
      -- and source to 'OKL_REBOOK'
      --
      l_khrv_rec.id                      := x_chr_id;
      l_chrv_rec.id                      := x_chr_id;
      l_chrv_rec.sts_code                := 'NEW';

      okl_contract_pub.update_contract_header(
                                              p_api_version         => 1.0,
                                              p_init_msg_list       => p_init_msg_list,
                                              x_return_status       => x_return_status,
                                              x_msg_count           => x_msg_count,
                                              x_msg_data            => x_msg_data,
                                              p_restricted_update   => OKC_API.G_FALSE,
                                              p_chrv_rec            => l_chrv_rec,
                                              p_khrv_rec            => l_khrv_rec,
                                              x_chrv_rec            => x_chrv_rec,
                                              x_khrv_rec            => x_khrv_rec
                                             );


      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

--**********************************************************
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);
if p_commit= OKC_API.G_TRUE then
	commit;
end if;

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => '_PVT');

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => '_PVT');

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                          p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => '_PVT');

  END create_working_copy;

-----------------------------------------------------------------
--API to update the HDR info about the Start date, term and End date for the working copy...
----------------------------------------------------------------

 PROCEDURE update_hdr_info(
			       x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               p_working_copy_chr_id 	IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_start_date     IN  OKL_K_HEADERS_FULL_V.START_DATE%TYPE,
                               p_end_date       IN  OKL_K_HEADERS_FULL_V.END_DATE%TYPE,
                               p_term_duration  IN  OKL_K_HEADERS_FULL_V.TERM_DURATION%TYPE
                              )
 IS

  l_khrv_rec    khrv_rec_type;
  l_chrv_rec    chrv_rec_type;
  x_khrv_rec    khrv_rec_type;
  x_chrv_rec    chrv_rec_type;

  update_failed		EXCEPTION;
 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     l_khrv_rec := get_khrv_rec(
                                p_khr_id        => p_working_copy_chr_id,
                                x_return_status => x_return_status
                               );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE update_failed;
     END IF;

     l_chrv_rec := get_chrv_rec(
                                p_chr_id        => p_working_copy_chr_id,
                                x_return_status => x_return_status
                               );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE update_failed;
     END IF;


	l_khrv_rec.term_duration := p_term_duration;

        l_chrv_rec.start_date    := p_start_date;
        l_chrv_rec.end_date      := p_end_date;

        okl_contract_pub.update_contract_header(
                                                p_api_version        => 1.0,
                                                p_init_msg_list      => OKC_API.G_FALSE,
                                                x_return_status      => x_return_status,
                                                x_msg_count          => x_msg_count,
                                                x_msg_data           => x_msg_data,
                                                p_restricted_update  => OKC_API.G_FALSE,
                                                p_chrv_rec           => l_chrv_rec,
                                                p_khrv_rec           => l_khrv_rec,
                                                x_chrv_rec           => x_chrv_rec,
                                                x_khrv_rec           => x_khrv_rec
                                               );
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            x_return_status := Okc_Api.G_RET_STS_ERROR;
            RAISE update_failed;
        END IF;

     --END LOOP;

     --RETURN;

  EXCEPTION
    WHEN update_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END update_hdr_info;

-------------------------------------------------------------
--API to update the residual values for all the assets by a %
------------------------------------------------------------
  PROCEDURE update_residual_value(
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2,
				  p_chr_id		IN NUMBER,
                                  p_reduce_residual_ptg_by     IN  NUMBER
                                 ) IS
  l_api_name    VARCHAR2(35)    := 'update_residual_value';
  l_api_version NUMBER          := 1.0;

  CURSOR rv_csr (p_top_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT residual_value
  FROM   okl_k_lines_full_v
  WHERE  id = p_top_line_id;

  CURSOR kle_id_csr(c_chr_id	NUMBER) IS
  SELECT line.id
  FROM   okl_k_lines_full_v line,
       okc_line_styles_v  style
  WHERE dnz_chr_id = c_chr_id
  AND   style.lty_code = 'FREE_FORM1'
  AND   line.lse_id = style.id;

  l_old_rv          NUMBER;
  l_new_rv          NUMBER;
  l_reduce_by	    NUMBER;
  l_residual_ptg NUMBER;
  l_klev_tbl     klev_tbl_type;
  l_clev_tbl     clev_tbl_type;

  x_klev_tbl     klev_tbl_type;
  x_clev_tbl     clev_tbl_type;

  p_kle_tbl      kle_tbl_type;
  l_line_count	 NUMBER:=0;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

--Should i calculate the new Residual Percentage?

    FOR kle_rec in kle_id_csr(p_chr_id)
    LOOP

	l_line_count := l_line_count + 1;
	p_kle_tbl(l_line_count).id := kle_rec.id;
    END LOOP;

--Before this populate the kle_tble based on the chr_id passed in.

    FOR i IN 1..p_kle_tbl.COUNT


    LOOP
       l_klev_tbl(i).id := p_kle_tbl(i).id;
       l_clev_tbl(i).id := p_kle_tbl(i).id;

	l_old_rv := 0;
       OPEN rv_csr (p_kle_tbl(i).id);
       FETCH rv_csr INTO l_old_rv;
       CLOSE rv_csr;
       IF (l_old_rv <> 0) THEN

	   l_reduce_by := p_reduce_residual_ptg_by * l_old_rv/100;
	   l_new_rv    := l_old_rv - l_reduce_by;

       END IF;

       l_klev_tbl(i).residual_value      := l_new_rv;

    END LOOP;

    okl_contract_pub.update_contract_line(
                                          p_api_version     => 1.0,
                                          p_init_msg_list   => OKC_API.G_FALSE,
                                          x_return_status   => x_return_status,
                                          x_msg_count       => x_msg_count,
                                          x_msg_data        => x_msg_data,
                                          p_clev_tbl        => l_clev_tbl,
                                          p_klev_tbl        => l_klev_tbl,
                                          x_clev_tbl        => x_clev_tbl,
                                          x_klev_tbl        => x_klev_tbl
                                         );


    RETURN; -- handle error, if any, at calling block

  END update_residual_value;





--*****************************************************88

--Call the extraction API to extract info for the working copy.
-- Populate the parameters, i.e Tweak with the output params....

--*****************************************************88
   PROCEDURE calculate(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_trqv_tbl              IN okl_trx_requests_pub.trqv_tbl_type,
                x_trqv_tbl              OUT NOCOPY okl_trx_requests_pub.trqv_tbl_type)
  AS
	l_api_name          CONSTANT VARCHAR2(30) := 'CALCULATE';
	p_chr_id	    NUMBER;
	l_trans_id	    NUMBER;
	l_trans_status	    VARCHAR2(100);
	l_trqv_tbl          okl_trx_requests_pub.trqv_tbl_type;
	l_upd_trqv_tbl          okl_trx_requests_pub.trqv_tbl_type;

     l_csm_lease_header          Okl_Create_Streams_Pub.csm_lease_rec_type;
     l_csm_one_off_fee_tbl       Okl_Create_Streams_Pub.csm_one_off_fee_tbl_type;
     l_csm_periodic_expenses_tbl Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
     l_csm_yields_tbl            Okl_Create_Streams_Pub.csm_yields_tbl_type;
     l_csm_stream_types_tbl      Okl_Create_Streams_Pub.csm_stream_types_tbl_type;
     l_req_stream_types_tbl      Okl_Create_Streams_Pub.csm_stream_types_tbl_type;
     l_csm_line_details_tbl      Okl_Create_Streams_Pub.csm_line_details_tbl_type;
     l_rents_tbl                 Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
     l_reduce_residual_ptg_by    NUMBER;
	l_current_term             NUMBER;
      l_new_term                 NUMBER;
      l_current_lease_attribs    lease_details_tbl_type;

      l_object_version_number NUMBER;
      l_request_status_code OKL_TRX_REQUESTS.REQUEST_STATUS_CODE%TYPE;

      CURSOR c_get_req_details(p_req_id NUMBER) IS
      SELECT OBJECT_VERSION_NUMBER, REQUEST_STATUS_CODE
      FROM OKL_TRX_REQUESTS
      WHERE ID = p_req_id;

   BEGIN
        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
	IF p_trqv_tbl(1).id IS NULL THEN
		-- Call the public API for insertion here.
		  okl_trx_requests_pub.insert_trx_requests(
                                     	      	p_api_version  	      => p_api_version,
	       		                      	p_init_msg_list       =>p_init_msg_list,
                 		              	x_return_status       => x_return_status,
                                		x_msg_count           => x_msg_count,
                                		x_msg_data            => x_msg_data,
                                		p_trqv_tbl            => p_trqv_tbl,
                                		x_trqv_tbl            => x_trqv_tbl);


	          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            		RAISE OKL_API.G_EXCEPTION_ERROR;
          	  END IF;
	ELSE
		l_upd_trqv_tbl	:=	p_trqv_tbl;

		--Reset the params before calling the API
		l_upd_trqv_tbl(1).amount := NULL;
		l_upd_trqv_tbl(1).request_status_code := 'ENTERED';

		--Call update here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_upd_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);

	          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	             RAISE OKL_API.G_EXCEPTION_ERROR;
	          END IF;
	END IF;

		p_chr_id := p_trqv_tbl(1).dnz_khr_id;
	l_current_lease_attribs := get_current_lease_values(p_trqv_tbl(1).parent_khr_id);

     	l_new_term := l_current_lease_attribs(1).term_duration + p_trqv_tbl(1).term_duration;
	-- Update the Hdr info
 		update_hdr_info( x_return_status  => x_return_status,
               		   	 x_msg_count      => x_msg_count,
                 		 x_msg_data       => x_msg_data,
                 		 p_working_copy_chr_id   => p_chr_id,
                 		 p_start_date     => l_current_lease_attribs(1).start_date,
                 		 p_end_date       => p_trqv_tbl(1).end_date,
                 		 p_term_duration  => l_new_term );

--This needs to be changed.
		l_reduce_residual_ptg_by := p_trqv_tbl(1).residual;
	--Update the Residual Values
		update_residual_value(
                                  x_return_status   => x_return_status,
                                  x_msg_count        => x_msg_count,
                                  x_msg_data         => x_msg_data,
                                  p_chr_id	     => p_chr_id,
                                  p_reduce_residual_ptg_by => l_reduce_residual_ptg_by
                                 );

	-- CAll Extraction API
    		OKL_LA_STREAM_PUB.EXTRACT_PARAMS_LEASE(
					p_api_version               => p_api_version,
	                                p_init_msg_list             => p_init_msg_list,
                                        p_chr_id                    => p_chr_id,
					x_return_status             => x_return_status,
					x_msg_count                 => x_msg_count,
                                	x_msg_data                  => x_msg_data,
					x_csm_lease_header          => l_csm_lease_header,
					x_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
					x_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
					x_csm_yields_tbl            => l_csm_yields_tbl,
					x_req_stream_types_tbl      => l_req_stream_types_tbl,
					x_csm_line_details_tbl      => l_csm_line_details_tbl,
					x_rents_tbl                 => l_rents_tbl);

	          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            		RAISE OKL_API.G_EXCEPTION_ERROR;
          	  END IF;
	--Fine tune the params
	--x_csm_lease_header
	l_csm_lease_header.jtot_object1_code := 'OKL_TRX_REQUESTS';
	l_csm_lease_header.object1_id1 :=  x_trqv_tbl(1).id;
	l_csm_lease_header.orp_code := OKL_CREATE_STREAMS_PUB.G_ORP_CODE_RENEWAL;

	--Check the following with Susan.
	l_csm_lease_header.adjust := 'Rent';
	l_csm_lease_header.adjustment_method := 'Proportional';



	--x_csm_yields_tbl
	l_csm_yields_tbl(3).target_value := p_trqv_tbl(1).yield;

	--x_rents_tbl
	--Delete the values that are already in the rents table and
	--repopulate the values.

		l_rents_tbl.delete;
        	l_rents_tbl(1).description := 'RENT';
	        l_rents_tbl(1).number_of_periods := l_current_lease_attribs(1).term_duration;
		l_rents_tbl(1).amount := NVL(l_current_lease_attribs(1).rent,0);
		l_rents_tbl(1).lock_level_step := OKL_CREATE_STREAMS_PUB.G_LOCK_AMOUNT;

		--Check the following with Susan
		l_rents_tbl(1).period := 'M';
	        l_rents_tbl(1).level_index_number := 1;
	        l_rents_tbl(1).level_type         := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
		l_rents_tbl(1).advance_or_arrears := OKL_CREATE_STREAMS_PUB.G_ADVANCE;
		l_rents_tbl(1).income_or_expense := OKL_CREATE_STREAMS_PUB.G_INCOME;
		l_rents_tbl(1).date_start := l_current_lease_attribs(1).start_date;

        --Level 2 for new amount:
	        l_rents_tbl(2).description := 'RENT';
       		l_rents_tbl(2).number_of_periods := p_trqv_tbl(1).term_duration;
		l_rents_tbl(2).amount := 0;
		l_rents_tbl(2).lock_level_step := NULL; --OKL_CREATE_STREAMS_PUB.G_LOCK_AMOUNT;
		l_rents_tbl(2).query_level_yn := 'Y';

		--Check the following with Susan
		l_rents_tbl(2).period := 'M';
	        l_rents_tbl(2).level_index_number := 2;
	        l_rents_tbl(2).level_type         := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
		l_rents_tbl(2).advance_or_arrears := OKL_CREATE_STREAMS_PUB.G_ADVANCE;  -- IS this hard coding Okay.. Check with Susan.
		l_rents_tbl(2).income_or_expense := OKL_CREATE_STREAMS_PUB.G_INCOME;
		l_rents_tbl(2).date_start := p_trqv_tbl(1).start_date;



	--Call Supertrump API to submit request.
    	Okl_Create_Streams_Pub.CREATE_STREAMS_LEASE_RESTR(
				p_api_version               => p_api_version,
	                        p_init_msg_list             => p_init_msg_list,
				x_return_status             => x_return_status,
				x_msg_count                 => x_msg_count,
                                x_msg_data                  => x_msg_data,
				p_csm_lease_header          => l_csm_lease_header,
				p_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
				p_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
				p_csm_yields_tbl            => l_csm_yields_tbl,
				p_csm_stream_types_tbl      => l_csm_stream_types_tbl,
				p_csm_line_details_tbl      => l_csm_line_details_tbl,
				p_rents_tbl                 => l_rents_tbl,
				x_trans_id	   	   => l_trans_id,
				x_trans_status	   	   => l_trans_status);

                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

        OPEN c_get_req_details(x_trqv_tbl(1).id);
        FETCH c_get_req_details INTO l_object_version_number, l_request_status_code;
        CLOSE c_get_req_details;

	--Now update the Status and the Transaction id in the CS Request Table.
	IF l_request_status_code <> 'COMPLETE' THEN
	   l_trqv_tbl(1).request_status_code := 'PRICING';
	END IF;

        l_trqv_tbl(1).id := x_trqv_tbl(1).id;
	l_trqv_tbl(1).object_version_number := l_object_version_number;
	l_trqv_tbl(1).jtot_object1_code := 'OKL_STREAM_INTERFACES';
	l_trqv_tbl(1).object1_id1 := l_trans_id;

                --Call update here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

    --Bug # 6595451 ssdeshpa start
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count
                        ,x_msg_data  => x_msg_data);
    --Bug # 6595451 ssdeshpa End

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


 END calculate;

PROCEDURE update_lrnw_request(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_trqv_rec              IN  okl_trx_requests_pub.trqv_rec_type
    ,x_trqv_rec              OUT  NOCOPY okl_trx_requests_pub.trqv_rec_type)
 AS

        l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_LRNW_REQUEST';
    	l_trqv_rec          okl_trx_requests_pub.trqv_rec_type := p_trqv_rec;

	CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;

   BEGIN

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	OPEN c_obj_vers_csr(l_trqv_rec.id);
	FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	CLOSE c_obj_vers_csr;

	--Check the Status that is being passed in and decode that status before callin
	-- the update API.
	--The status should be present in the FND_LOOKUP.


		IF (l_trqv_rec.request_status_code = 'PROCESS_COMPLETE' ) THEN
			l_trqv_rec.request_status_code := 'COMPLETE';
		ELSIF (l_trqv_rec.request_status_code = 'PROCESS_COMPLETE_ERROR' ) THEN
			l_trqv_rec.request_status_code := 'INCOMPLETE';
		END IF;


                -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);


                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

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


 END update_lrnw_request;


END OKL_CS_LEASE_RENEWAL_PVT;

/

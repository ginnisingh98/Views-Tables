--------------------------------------------------------
--  DDL for Package Body OKL_AUTO_INSURANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AUTO_INSURANCE_PVT" AS
/* $Header: OKLRICXB.pls 120.18 2007/10/10 11:21:06 zrehman noship $ */
  ---------------------------------------------------------------------------

FUNCTION get_trx_type
	(p_name		VARCHAR2,
	p_language	VARCHAR2)
	RETURN		NUMBER IS

	CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
		SELECT	id
		FROM	okl_trx_types_tl
		WHERE	name		= cp_name
		AND	LANGUAGE	= cp_language;-- Fix for 3637102
                                                      -- Source_lang replaced
                                                      -- with LANGUAGE

	l_trx_type	okl_trx_types_v.id%TYPE;

  BEGIN

	l_trx_type := NULL;

	OPEN	c_trx_type (p_name, p_language);
	FETCH	c_trx_type INTO l_trx_type;
	CLOSE	c_trx_type;

	RETURN	l_trx_type;

  END get_trx_type;

  ------------------------------------------------------------------
  -- Procedure pay_ins_payments to pay insurance premium
  ------------------------------------------------------------------

       PROCEDURE PAY_INS_PAYMENTS
	(
	 errbuf           OUT NOCOPY VARCHAR2,
	 retcode          OUT NOCOPY NUMBER
	,p_from_bill_date	IN  VARCHAR2
	,p_to_bill_date		IN  VARCHAR2)IS

	------------------------------------------------------------
	-- Extract all streams to be paid
	------------------------------------------------------------

	-- Org Stripped OKC_K_HEADERS_B JOIN for ORG
        -- cursor select changed to select streams based on purpose and that come from stream generation template
        --   of the contract, implemented for insurance user defined streams, Bug 3924300

	CURSOR c_streams_rec_csr(l_from_bill_date DATE,l_to_bill_date DATE ) IS
              SELECT        stm.khr_id                      khr_id,
                        TRUNC ( ste.stream_element_date) due_date,
                        stm.kle_id                      kle_id,
                        ste.id                          stream_ele_id,
                        stm.sty_id                      sty_id,
                        ste.amount                      amount,
                        chr.contract_number             contract_number
               FROM    okl_strm_elements                ste,
                        okl_streams                     stm,
                        OKC_K_HEADERS_B                 chr, -- Added for Org,
                        okl_k_headers                   oklchr,
                        OKL_STRM_TMPT_LINES_UV          stl

               WHERE   ste.stream_element_date    >= NVL (l_from_bill_date,  ste.stream_element_date)
                AND     ste.stream_element_date   <= NVL (l_to_bill_date,    SYSDATE)
                AND     stm.id                          = ste.stm_id
                AND     ste.date_billed                   IS NULL
                AND     stm.active_yn                   = 'Y'
                AND     stm.say_code                    = 'CURR'
                AND     stl.primary_yn                  = 'Y'
                AND     stl.pdt_id                      = oklchr.pdt_id
                AND    (stl.start_date <= chr.start_date)
		AND    (stl.end_date >= chr.start_date  OR stl.end_date IS NULL)
		AND	stl.primary_sty_purpose =   'INSURANCE_PAYABLE'
		AND     stl.primary_sty_id                          = stm.sty_id
                AND    chr.ID =  stm.khr_id
                AND    chr.id = oklchr.id;


        c_streams_rec	c_streams_rec_csr%ROWTYPE;
	------------------------------------------------------------
	-- Initialise constants
	------------------------------------------------------------

	l_trx_type_name	CONSTANT VARCHAR2(30)	:= 'Disbursement';
	l_trx_type_lang	CONSTANT VARCHAR2(30)	:= 'US';
	l_date_entered	CONSTANT DATE		:= SYSDATE;

	------------------------------------------------------------
	-- Declare local variables used in the program
	------------------------------------------------------------
  	l_trx_type_id  NUMBER	;
        l_from_bill_date  DATE ;
        l_to_bill_date   DATE;
        l_contract_number okc_k_headers_b.contract_number%type ;
        l_token_val VARCHAR2(80);


	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'pay_ins_payments';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
        l_msg_data       VARCHAR2(2000);
        l_msg_count   NUMBER := 0 ;

  	l_selv_rec	Okl_Streams_Pub.selv_rec_type;
	x_selv_rec	Okl_Streams_Pub.selv_rec_type;

    CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
      SELECT  id
      FROM    okl_trx_types_tl
      WHERE   name      = cp_name
      AND     language  = cp_language;

    CURSOR c_trx_lkup IS
    SELECT Meaning
    FROM fnd_lookups
    WHERE lookup_type = 'OKL_TRANSACTION_TYPE_CLASS'
      and lookup_code ='DISBURSEMENT';

  BEGIN


   IF p_from_bill_date IS NOT NULL THEN
    l_from_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_bill_date);
    END IF;

    IF p_to_bill_date IS NOT NULL THEN
    l_to_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_bill_date);
    END IF;
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	------------------------------------------------------------
	-- Process every stream to be billed
	------------------------------------------------------------

    -- get transaction id
             OPEN c_trx_type ('Disbursement', 'US');
               FETCH c_trx_type INTO l_trx_type_ID;
               IF(c_trx_type%NOTFOUND) THEN
                         -- 3927315 Fix for hard coded tokens
                         OPEN c_trx_lkup;
                         FETCH c_trx_lkup INTO l_token_val;
                         CLOSE c_trx_lkup;
                         --  3927315 Fix for hard coded tokens
                         Okc_Api.set_message(G_APP_NAME, 'OKL_AM_NO_TRX_TYPE_FOUND','TRY_NAME',l_token_val); -- 3745151 Fix for Invalid error messages.
                         CLOSE c_trx_type ;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
               END if ;
               CLOSE c_trx_type ;

    OPEN c_streams_rec_csr(l_from_bill_date,l_to_bill_date )	;
	 LOOP
     FETCH c_streams_rec_csr INTO c_streams_rec;
   	   EXIT WHEN c_streams_rec_csr%NOTFOUND;
       savepoint pay_ins_payments ;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing: Contract Number=> '||c_streams_rec.contract_number||
	' ,for date=> '||c_streams_rec.due_date||' and Amount=> '||c_streams_rec.amount);

         -- call ap_request

    OKL_INSURANCE_POLICIES_PUB.insert_ap_request(
          p_api_version         =>l_api_version,
          p_init_msg_list       => Okc_Api.G_TRUE,
          x_return_status       =>l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            =>l_msg_data,
          p_tap_id          => NULL,
          p_credit_amount   =>c_streams_rec.amount,
          p_credit_sty_id   =>c_streams_rec.STY_ID,
          p_khr_id         => c_streams_rec.khr_id,
          p_kle_id         =>c_streams_rec.kle_id,
          p_invoice_date   =>c_streams_rec.due_date,
          p_trx_id         => l_trx_type_id);

		   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN --<4
				    FOR i IN 1..l_msg_count  LOOP
				 	     JTF_PLSQL_API.get_messages(i,l_msg_data);
                         Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
    				END LOOP;
				  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF(l_return_status = OKC_API.G_RET_STS_ERROR) THEN --<4

                           FOR i IN 1..l_msg_count  LOOP
				 	         JTF_PLSQL_API.get_messages(i,l_msg_data);
                             Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				           END LOOP;
                    ROLLBACK TO pay_ins_payments;
            ELSE
    	    	l_selv_rec.id				:= c_streams_rec.stream_ele_id;
	    	l_selv_rec.date_billed		:= sysdate;

    		Okl_Streams_Pub.update_stream_elements
	    		(l_api_version
		    	,Okc_Api.G_TRUE
			    ,l_return_status
			    ,l_msg_count
			    ,l_msg_data
			    ,l_selv_rec
			    ,x_selv_rec);

				   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN --<4
				    FOR i IN 1..l_msg_count  LOOP
				 	     JTF_PLSQL_API.get_messages(i,l_msg_data);
                         Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
    				END LOOP;
					  ROLLBACK TO pay_ins_payments;
				  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF(l_return_status = OKC_API.G_RET_STS_ERROR) THEN --<4

                           FOR i IN 1..l_msg_count  LOOP
				 	         JTF_PLSQL_API.get_messages(i,l_msg_data);
                             Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				           END LOOP;
			     ROLLBACK TO pay_ins_payments;
            END IF;
          END IF;
		    commit;
	END LOOP;
    close c_streams_rec_csr ;

  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);

  END pay_ins_payments;


---------------------------------------------------------------------------

   FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------------------------------
 -- Return 'Y' if there are some active subscription for the given event
 -- Otherwise it returns 'N'
 -----------------------------------------------------------------------
 IS
  CURSOR cu0 IS
   SELECT 'Y'
     FROM wf_event_subscriptions a,
          wf_events b
    WHERE a.event_filter_guid = b.guid
      AND a.status = 'ENABLED'
      AND b.name   = p_event_name
      AND rownum   = 1;
  l_yn  VARCHAR2(1);
 BEGIN
  OPEN cu0;
   FETCH cu0 INTO l_yn;
   IF cu0%NOTFOUND THEN
      l_yn := 'N';
   END IF;
  CLOSE cu0;
  RETURN l_yn;
 END;


   PROCEDURE create_third_party_task_event
( p_contract_id   IN NUMBER,
  p_org_id        IN NUMBER,
  x_retrun_status OUT NOCOPY VARCHAR2)
IS
 l_parameter_list wf_parameter_list_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.okl.in.gthirdprtinsurance';
 l_seq NUMBER ;

BEGIN

 SAVEPOINT create_third_party_task_event;

x_retrun_status := OKC_API.G_RET_STS_SUCCESS ;
 -- Test if there are any active subscritions
 -- if it is the case then execute the subscriptions
 l_yn := exist_subscription(l_event_name);

 IF l_yn = 'Y' THEN

   --Get the item key
  select okl_wf_item_s.nextval INTO l_seq FROM DUAL ;
   l_key := l_event_name ||l_seq ;

   --Set Parameters
   wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_parameter_list);
 -- Call it again if you have more than one parameter
-- Keep data type (text) only
  --added by akrangan
  wf_event.AddParameterToList('ORG_ID',p_org_id ,l_parameter_list);
   -- Raise Event
   -- It is overloaded function so use according to requirement
   wf_event.raise(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_parameter_list);
   l_parameter_list.DELETE;

ELSE
  FND_MESSAGE.SET_NAME('OKL', 'OKL_NO_EVENT');
  FND_MSG_PUB.ADD;
  x_retrun_status :=   OKC_API.G_RET_STS_ERROR ;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_third_party_task_event;
 x_retrun_status :=   OKC_API.G_RET_STS_UNEXP_ERROR ;

END create_third_party_task_event;


-------------------------------------------------------------------------------

  PROCEDURE  pol_exp_notification(
       errbuf           OUT NOCOPY VARCHAR2,
       retcode          OUT NOCOPY NUMBER ,
             p_template_id      IN NUMBER     )
          IS
        l_chr_id  number ;
        lx_email varchar2(240);
        l_init_msg_list              VARCHAR2(1) := Okc_Api.G_FALSE ;
     l_msg_count                   NUMBER ;
     l_msg_data                      VARCHAR2(2000);
     l_api_version                 CONSTANT NUMBER := 1;
        l_return_status                VARCHAR2(1) :=
Okc_Api.G_RET_STS_SUCCESS;
        ls_to_email varchar2(240);
        ls_contract_number VARCHAR2(80);
        l_bind_var            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
        l_bind_val            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
        l_bind_var_type   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
        l_content_id      NUMBER;
        l_agent_id        NUMBER;
        l_subject        VARCHAR2(80);
        l_email           VARCHAR2(80);
        lx_request_id   NUMBER ;
        ls_policy_number  VARCHAR2(80);
        ls_reminder_yn     VARCHAR2(3);
        ls_reminder_days    VARCHAR2(80) ;
        ls_remder_num_days     NUMBER ;
        l_pol_id               NUMBER ;
        l_cust_acct_id         NUMBER; --Bug 4177206

    --PAGARG 27-Jan-2005 Bug 4095801 Org Stripping and correction of some joining conditions
    CURSOR okl_eli_3rdpolicies_csr IS
      SELECT IPYB.KHR_ID
            ,OCHR.CONTRACT_NUMBER
            ,IPYB.ID
            ,OCHR.CUST_ACCT_ID --Bug 4177206
      FROM OKL_INS_POLICIES_B IPYB
          ,OKC_K_HEADERS_B OCHR
      WHERE (IPYB.IPY_TYPE = 'THIRD_PARTY_POLICY' OR
            (IPYB.IPY_TYPE = 'LEASE_POLICY' AND
            IPYB.ISS_CODE = 'ACTIVE')) AND
            trunc(IPYB.DATE_TO) = trunc(SYSDATE) + ls_remder_num_days
             AND  OCHR.ID = IPYB.KHR_ID;

-- Added by Skgautam for bug 4177206
-- Cursor to get Email Id
CURSOR get_email (p_cust_acct_id NUMBER) IS
SELECT hcp_email.email_address
FROM  hz_cust_account_roles hcar ,
      hz_contact_points hcp_email
WHERE hcar.cust_account_id = p_cust_acct_id
AND hcar.cust_acct_site_id IS NULL
AND hcar.status = 'A'
AND hcar.role_type = 'CONTACT'
AND hcp_email.contact_point_type = 'EMAIL'
AND hcp_email.owner_table_id  = hcar.party_id
AND hcp_email.owner_table_name  = 'HZ_PARTIES'
AND hcp_email.primary_flag  = 'Y';
-- Added by Skgautam for bug 4177206
--Cursor to query user profile option name for given profile option name
    CURSOR l_profile_name_csr(p_profile_code IN VARCHAR2) IS
    SELECT USER_PROFILE_OPTION_NAME
    FROM FND_PROFILE_OPTIONS_VL
    WHERE PROFILE_OPTION_NAME = p_profile_code;

    l_profile_name FND_PROFILE_OPTIONS_TL.USER_PROFILE_OPTION_NAME%TYPE;

        BEGIN
          fnd_profile.get('OKLINNTCINSEXPREQ',ls_reminder_yn);
          fnd_profile.get('OKLINNTCINSEXP',ls_reminder_days);

          ls_remder_num_days := TO_NUMBER(ls_reminder_days);

          IF ls_reminder_yn = 'Y' THEN   --Bug: 4177206
             l_content_id := p_template_id ;
             IF l_content_id = Okc_Api.G_MISS_NUM OR l_content_id IS NULL THEN  --Bug: 4177206
             Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'No Document is selected');
             END IF;
    -- Added by Skgautam for bug 4177206
     --Obtain user profile option name for given profile option name
   	 OPEN l_profile_name_csr('OKL_EMAIL_IDENTITY');
   	 FETCH l_profile_name_csr INTO l_profile_name;
    	 CLOSE l_profile_name_csr;

         OPEN okl_eli_3rdpolicies_csr;
         LOOP
            FETCH okl_eli_3rdpolicies_csr INTO l_chr_id,
                  ls_contract_number,l_pol_id ,l_cust_acct_id; --Bug 4177206
             EXIT WHEN okl_eli_3rdpolicies_csr%NOTFOUND;

          IF l_pol_id IS NOT NULL THEN

            l_bind_var(1) := 'p_policy_id';
            l_bind_val(1) := l_pol_id ;
            l_bind_var_type(1) := 'NUMBER' ;

     okl_cs_transactions_pub.get_pvt_label_email(
     p_khr_id => l_chr_id,
     x_email         => lx_email,
     x_return_status => l_return_status,
     x_msg_count     => l_msg_data,
     x_msg_data      => l_msg_count);

          IF l_return_status = 'S' AND lx_email <> -1 THEN  --Bug: 4177206
            ls_to_email := lx_email;
          ELSE
            ls_to_email :=  fnd_profile.value('OKL_EMAIL_IDENTITY');
    -- Check for NULL values and return if either of these is null
               IF ls_to_email  = Okc_Api.G_MISS_CHAR OR ls_to_email IS NULL  THEN
                 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'System profile value for ' || l_profile_name || ' is not defined');
                 RETURN;
               END IF;
          END IF;
-- Added by Skgautam to get email id for bug 4177206
       OPEN get_email(l_cust_acct_id);
       FETCH get_email INTO l_email;
       CLOSE get_email;

        l_agent_id             := FND_PROFILE.VALUE('USER_ID');
        l_subject              := 'Third party Insurance Reminder for Contract: '||ls_contract_number ;

        OKL_FULFILLMENT_PUB.create_fulfillment (
                                  p_api_version      => l_api_version,
                                  p_init_msg_list    => l_init_msg_list,

                                  p_agent_id         => l_agent_id,
                                  p_content_id       => l_content_id,
                                  p_from             => ls_to_email,
                                  p_subject          => l_subject,
                                  p_email            => l_email,
                                  p_bind_var         => l_bind_var,
                                  p_bind_val         => l_bind_val,
                                  p_bind_var_type    => l_bind_var_type,

                                  x_request_id       => lx_request_id,
                                  x_return_status    => l_return_status,

                                  x_msg_count        => l_msg_count,
                                  x_msg_data         => l_msg_data);
            IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'No Document is selected');
            ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Unexpected Exception');
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

        END IF;

          end loop;
          CLOSE okl_eli_3rdpolicies_csr ;
       END IF;

          EXCEPTION

        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          --ROLLBACK TO create_fulfillment;
          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          --ROLLBACK TO create_fulfillment;
          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
          --ROLLBACK TO create_fulfillment;
          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        end pol_exp_notification ;

/* $Header: OKLRICXB.pls 120.18 2007/10/10 11:21:06 zrehman noship $ */
  ---------------------------------------------------------------------------
-- Start of comments
--
-- Function Name	: get_contract_status
-- Description		:It get Contract status based on contract id.
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
 /*FUNCTION get_contract_status (
          p_khr_id IN  NUMBER,
          x_contract_status OUT NOCOPY VARCHAR2
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          CURSOR okc_k_status_csr(p_khr_id  IN NUMBER) IS
	        SELECT STE_CODE
	        FROM  OKC_K_HEADERS_V KHR , OKC_STATUSES_B OST
           WHERE  KHR.ID =  p_khr_id
            AND KHR.STS_CODE = OST.CODE;

        BEGIN
          OPEN  okc_k_status_csr(p_khr_id);
         FETCH okc_k_status_csr INTO x_contract_status ;
         IF(okc_k_status_csr%NOTFOUND) THEN
            -- store SQL error message on message stack for caller
               OKL_API.set_message(G_APP_NAME,
               			   'OKL_INVALID_CONTRACT_STATUS'
                            );
               CLOSE okc_k_status_csr ;
               l_return_status := OKC_API.G_RET_STS_ERROR;
               -- Change it to
               RETURN(l_return_status);
         END IF;
         CLOSE okc_k_status_csr ;
         RETURN(l_return_status);
         EXCEPTION
           WHEN OTHERS THEN
               -- store SQL error message on message stack for caller
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      		  -- notify caller of an UNEXPECTED error
      		  l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      		-- verify that cursor was closed
    		IF okc_k_status_csr%ISOPEN THEN
	    	   CLOSE okc_k_status_csr;
		    END IF;
          	RETURN(l_return_status);
      END get_contract_status;
*/
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ipyv_rec                     IN ipyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ipyv_rec_type IS
    CURSOR okl_ipyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ADJUSTMENT,
            CALCULATED_PREMIUM,
            OBJECT_VERSION_NUMBER,
            AGENCY_NUMBER,
            SFWT_FLAG,
            IPF_CODE,
            INT_ID,
            KHR_ID,
            ISU_ID,
            IPT_ID,
            IPY_ID,
            IPE_CODE,
            CRX_CODE,
            AGENCY_SITE_ID,
            ISS_CODE,
            KLE_ID,
            AGENT_SITE_ID,
            IPY_TYPE,
            POLICY_NUMBER,
            QUOTE_YN,
            ENDORSEMENT,
            INSURANCE_FACTOR,
            COVERED_AMOUNT,
            ADJUSTED_BY_ID,
            FACTOR_VALUE,
            DATE_QUOTED,
            SALES_REP_ID,
            DATE_PROOF_REQUIRED,
            DATE_QUOTE_EXPIRY,
            DEDUCTIBLE,
            PAYMENT_FREQUENCY,
            DATE_PROOF_PROVIDED,
            DATE_FROM,
            NAME_OF_INSURED,
            DATE_TO,
            DESCRIPTION,
            ON_FILE_YN,
            PREMIUM,
            COMMENTS,
            ACTIVATION_DATE,
            PRIVATE_LABEL_YN,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            CANCELLATION_DATE,
            CANCELLATION_COMMENT,
            AGENT_YN,
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
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ins_Policies_V
     WHERE okl_ins_policies_v.id = p_id;
    l_okl_ipyv_pk                  okl_ipyv_pk_csr%ROWTYPE;
    l_ipyv_rec                     ipyv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ipyv_pk_csr (p_ipyv_rec.id);
    FETCH okl_ipyv_pk_csr INTO
              l_ipyv_rec.ID,
              l_ipyv_rec.ADJUSTMENT,
              l_ipyv_rec.CALCULATED_PREMIUM,
              l_ipyv_rec.OBJECT_VERSION_NUMBER,
              l_ipyv_rec.AGENCY_NUMBER,
              l_ipyv_rec.SFWT_FLAG,
              l_ipyv_rec.IPF_CODE,
              l_ipyv_rec.INT_ID,
              l_ipyv_rec.KHR_ID,
              l_ipyv_rec.ISU_ID,
              l_ipyv_rec.IPT_ID,
              l_ipyv_rec.IPY_ID,
              l_ipyv_rec.IPE_CODE,
              l_ipyv_rec.CRX_CODE,
              l_ipyv_rec.AGENCY_SITE_ID,
              l_ipyv_rec.ISS_CODE,
              l_ipyv_rec.KLE_ID,
              l_ipyv_rec.AGENT_SITE_ID,
              l_ipyv_rec.IPY_TYPE,
              l_ipyv_rec.POLICY_NUMBER,
              l_ipyv_rec.QUOTE_YN,
              l_ipyv_rec.ENDORSEMENT,
              l_ipyv_rec.INSURANCE_FACTOR,
              l_ipyv_rec.COVERED_AMOUNT,
              l_ipyv_rec.ADJUSTED_BY_ID,
              l_ipyv_rec.FACTOR_VALUE,
              l_ipyv_rec.DATE_QUOTED,
              l_ipyv_rec.SALES_REP_ID,
              l_ipyv_rec.DATE_PROOF_REQUIRED,
              l_ipyv_rec.DATE_QUOTE_EXPIRY,
              l_ipyv_rec.DEDUCTIBLE,
              l_ipyv_rec.PAYMENT_FREQUENCY,
              l_ipyv_rec.DATE_PROOF_PROVIDED,
              l_ipyv_rec.DATE_FROM,
              l_ipyv_rec.NAME_OF_INSURED,
              l_ipyv_rec.DATE_TO,
              l_ipyv_rec.DESCRIPTION,
              l_ipyv_rec.ON_FILE_YN,
              l_ipyv_rec.PREMIUM,
              l_ipyv_rec.COMMENTS,
              l_ipyv_rec.ACTIVATION_DATE,
              l_ipyv_rec.PRIVATE_LABEL_YN,
              l_ipyv_rec.LESSOR_INSURED_YN,
              l_ipyv_rec.LESSOR_PAYEE_YN,
              l_ipyv_rec.CANCELLATION_DATE,
              l_ipyv_rec.CANCELLATION_COMMENT,
              l_ipyv_rec.AGENT_YN,
              l_ipyv_rec.ATTRIBUTE_CATEGORY,
              l_ipyv_rec.ATTRIBUTE1,
              l_ipyv_rec.ATTRIBUTE2,
              l_ipyv_rec.ATTRIBUTE3,
              l_ipyv_rec.ATTRIBUTE4,
              l_ipyv_rec.ATTRIBUTE5,
              l_ipyv_rec.ATTRIBUTE6,
              l_ipyv_rec.ATTRIBUTE7,
              l_ipyv_rec.ATTRIBUTE8,
              l_ipyv_rec.ATTRIBUTE9,
              l_ipyv_rec.ATTRIBUTE10,
              l_ipyv_rec.ATTRIBUTE11,
              l_ipyv_rec.ATTRIBUTE12,
              l_ipyv_rec.ATTRIBUTE13,
              l_ipyv_rec.ATTRIBUTE14,
              l_ipyv_rec.ATTRIBUTE15,
              l_ipyv_rec.ORG_ID,
              l_ipyv_rec.REQUEST_ID,
              l_ipyv_rec.PROGRAM_APPLICATION_ID,
              l_ipyv_rec.PROGRAM_ID,
              l_ipyv_rec.PROGRAM_UPDATE_DATE,
              l_ipyv_rec.CREATED_BY,
              l_ipyv_rec.CREATION_DATE,
              l_ipyv_rec.LAST_UPDATED_BY,
              l_ipyv_rec.LAST_UPDATE_DATE,
              l_ipyv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ipyv_pk_csr%NOTFOUND;
    CLOSE okl_ipyv_pk_csr;
    RETURN(l_ipyv_rec);
  END get_rec;
  FUNCTION get_rec (
    p_ipyv_rec       IN ipyv_rec_type
  ) RETURN ipyv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ipyv_rec, l_row_notfound));
  END get_rec;


  PROCEDURE  third_party_ins_followup(
		 errbuf           OUT NOCOPY VARCHAR2,
		 retcode          OUT NOCOPY NUMBER,
         p_template_id      IN NUMBER
             )
      IS
      l_chr_id  number ;

    --PAGARG 27-Jan-2005 Bug 4095801 Org Stripping and correction of some joining conditions
    CURSOR okl_eli_3rdpolicies_csr(l_no_of_days IN NUMBER ) IS
      SELECT IPYB.KHR_ID
            ,OCHR.CONTRACT_NUMBER
            ,OCHR.CUST_ACCT_ID -- Bug 4177206
      FROM OKL_INS_POLICIES_B IPYB
          ,OKC_K_HEADERS_B OCHR
      WHERE IPYB.IPY_TYPE = 'THIRD_PARTY_POLICY' AND
            IPYB.DATE_PROOF_REQUIRED < SYSDATE AND
            IPYB.DATE_PROOF_REQUIRED >= SYSDATE - l_no_of_days AND
            IPYB.DATE_PROOF_PROVIDED  IS NULL
             AND OCHR.ID = IPYB.KHR_ID;

      -- Added by Skgautam for bug 4177206
-- Cursor to get Email Id
CURSOR get_email (p_cust_acct_id NUMBER) IS
SELECT hcp_email.email_address
FROM  hz_cust_account_roles hcar ,
      hz_contact_points hcp_email
WHERE hcar.cust_account_id = p_cust_acct_id
AND hcar.cust_acct_site_id IS NULL
AND hcar.status = 'A'
AND hcar.role_type = 'CONTACT'
AND hcp_email.contact_point_type = 'EMAIL'
AND hcp_email.owner_table_id  = hcar.party_id
AND hcp_email.owner_table_name  = 'HZ_PARTIES'
AND hcp_email.primary_flag  = 'Y';

-- Added by Skgautam for bug 4177206
--Cursor to query user profile option name for given profile option name
    CURSOR l_profile_name_csr(p_profile_code IN VARCHAR2) IS
    SELECT USER_PROFILE_OPTION_NAME
    FROM FND_PROFILE_OPTIONS_VL
    WHERE PROFILE_OPTION_NAME = p_profile_code;

    l_profile_name FND_PROFILE_OPTIONS_TL.USER_PROFILE_OPTION_NAME%TYPE;

      lx_email varchar2(240);
      l_init_msg_list              VARCHAR2(1) := Okc_Api.G_FALSE ;
      l_msg_count                   NUMBER ;
      l_msg_data                      VARCHAR2(2000);
      l_api_version                 CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    ls_to_email varchar2(240);
    ls_contract_number VARCHAR2(80);
    l_bind_var            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_val            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_var_type   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
    l_content_id      NUMBER;
    l_agent_id        NUMBER;
    l_subject        VARCHAR2(80);
    l_email           VARCHAR2(80);
    lx_request_id   NUMBER ;
    l_cust_acct_id  NUMBER; -- Bug 4177206

      BEGIN

       l_content_id := p_template_id ;
       IF l_content_id = Okc_Api.G_MISS_NUM OR l_content_id IS NULL THEN  --Bug: 4177206
       Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'No Document is Selected');
       END IF;
       -- Added by Skgautam for bug 4177206
     --Obtain user profile option name for given profile option name
         OPEN l_profile_name_csr('OKL_EMAIL_IDENTITY');
         FETCH l_profile_name_csr INTO l_profile_name;
         CLOSE l_profile_name_csr;

        OPEN okl_eli_3rdpolicies_csr (10)	;
	    LOOP
              FETCH okl_eli_3rdpolicies_csr INTO l_chr_id, ls_contract_number,l_cust_acct_id ;  --Bug: 4177206
              EXIT WHEN okl_eli_3rdpolicies_csr%NOTFOUND;

        l_bind_var(1) := 'p_contract_id';
        l_bind_val(1) := l_chr_id ;
        l_bind_var_type(1) := 'NUMBER' ;

           okl_cs_transactions_pub.get_pvt_label_email(p_khr_id        => l_chr_id,
                                                  x_email         => lx_email,
                                                  x_return_status => l_return_status,
                                                  x_msg_count     => l_msg_data,
                                                  x_msg_data      => l_msg_count);

      IF l_return_status = 'S' AND lx_email <> -1 THEN  --Bug: 4177206
        ls_to_email := lx_email;
      ELSE
        ls_to_email :=  fnd_profile.value('OKL_EMAIL_IDENTITY');
        -- Check for NULL values and return if either of these is null
               IF ls_to_email  = Okc_Api.G_MISS_CHAR OR ls_to_email IS NULL  THEN --Bug: 4177206
                 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'System profile value for ' || l_profile_name || ' is not defined');
                 RETURN;
               END IF;
      END IF;

      -- Added by Skgautam to get email id for bug 4177206
       OPEN get_email(l_cust_acct_id);
       FETCH get_email INTO l_email;
       CLOSE get_email;
    l_agent_id             := FND_PROFILE.VALUE('USER_ID');
    l_subject              := 'Insurance Proof for Contract: '||ls_contract_number ;

    OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version      => l_api_version,
                              p_init_msg_list    => l_init_msg_list,
                              p_agent_id         => l_agent_id,
                              p_content_id       => l_content_id,
                              p_from             => ls_to_email,
                              p_subject          => l_subject,
                              p_email            => l_email,
                              p_bind_var         => l_bind_var,
                              p_bind_val         => l_bind_val,
                              p_bind_var_type    => l_bind_var_type,
                              x_request_id       => lx_request_id,
                              x_return_status    => l_return_status,
                              x_msg_count        => l_msg_count,
                              x_msg_data         => l_msg_data);
        IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          		  FOR i IN 1..l_msg_count  LOOP
	    			 	 JTF_PLSQL_API.get_messages(i,l_msg_data);
                         Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
		    	  END LOOP;
        ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          		  FOR i IN 1..l_msg_count  LOOP
	    			 	 JTF_PLSQL_API.get_messages(i,l_msg_data);
                         Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
		    		  END LOOP;
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;



      end loop;
      CLOSE okl_eli_3rdpolicies_csr ;

      EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    end third_party_ins_followup ;

-- Start of comments
  -- API name 	: auto_ins_establishment
  -- Pre-reqs	: None
  -- Function	: Invoked as Part of Automatic Insurance Concurrent Program
  -- Parameters	:
     --OUT :errbuf   OUT VARCHAR2	Required
       --  :retcode	 OUT VARCHAR2   Required
  --SSDESHPA Bug 6318957:DIT:F - AUTOMATIC INSURANCE DOESNOT CREATE INSURANCE
-- End of comments
PROCEDURE auto_ins_establishment(
		 errbuf           OUT NOCOPY VARCHAR2,
		 retcode          OUT NOCOPY NUMBER
      )
IS
     --04-Jan-2004 PAGARG Bug# 3941338
     --Modified the query to fix the conditions and improve performance
     --Org stripped the query to pick contracts in current org
     CURSOR okl_eli_policies_csr(l_no_of_days IN NUMBER ) IS
     SELECT OKHB.ID
           ,OKHB.STS_CODE
           ,OKHB.START_DATE
           ,OKHB.END_DATE
           ,OKHB.CONTRACT_NUMBER
           --Bug # 6318957 SSDESHPA Changes Start
	   ,OKHB.ORG_ID
           --Bug # 6318957 SSDESHPA Changes End
     FROM OKC_K_HEADERS_B OKHB
         ,OKL_K_HEADERS OKLH
         ,OKC_STATUSES_B OKSB
     WHERE OKSB.STE_CODE = 'ACTIVE' AND
           OKHB.STS_CODE = OKSB.CODE AND
           OKHB.SCS_CODE = 'LEASE' AND
           OKHB.END_DATE > SYSDATE AND
           OKLH.ID = OKHB.ID AND
           (OKHB.START_DATE + l_no_of_days ) <= SYSDATE
            AND OKHB.ID NOT IN
           (SELECT IPYB.KHR_ID
            FROM OKL_INS_POLICIES_B IPYB
            WHERE IPYB.IPY_TYPE = 'LEASE_POLICY' AND
                  IPYB.QUOTE_YN = 'N' AND
                  IPYB.ISS_CODE = 'ACTIVE' AND
                  (SYSDATE - l_no_of_days ) BETWEEN IPYB.DATE_FROM AND IPYB.DATE_TO AND
                  IPYB.KHR_ID = OKHB.ID
            UNION
            SELECT IPYB.KHR_ID
            FROM OKL_INS_POLICIES_B IPYB
            WHERE IPYB.IPY_TYPE = 'THIRD_PARTY_POLICY' AND
                  (IPYB.DATE_PROOF_PROVIDED IS NOT NULL OR
                   (IPYB.DATE_PROOF_PROVIDED IS NULL AND
                    IPYB.DATE_PROOF_REQUIRED >= SYSDATE)) AND
                  IPYB.KHR_ID = OKHB.ID
           )
     ORDER BY OKHB.CONTRACT_NUMBER;
	l_okl_eli_policies_csr	okl_eli_policies_csr%ROWTYPE;

	CURSOR okl_provider_csr(ls_country_code IN VARCHAR2,  l_factor IN NUMBER) IS
	SELECT OIR.RANKING_SEQ, OIR.ISU_ID
	FROM OKL_INSURER_RANKINGS OIR,OKL_INS_PRODUCTS_B IPTB
	WHERE  OIR.ISU_ID =  IPTB.ISU_ID
   		   AND OIR.IC_CODE = ls_country_code
   		   AND IPT_TYPE = 'LEASE_PRODUCT'
  		   AND l_factor BETWEEN FACTOR_MIN AND FACTOR_MAX
	         AND SYSDATE BETWEEN  oir.DATE_FROM AND DECODE(oir.DATE_TO,NULL,SYSDATE,oir.DATE_TO)
		ORDER BY RANKING_SEQ ;


	l_okl_provider_csr okl_provider_csr%ROWTYPE;

				   -- Effective From Date
	CURSOR okl_last_ins_to_csr(l_khr_id IN NUMBER ) IS
	 SELECT IPYB.DATE_TO
	 FROM  OKL_INS_POLICIES_B  IPYB
	 WHERE   IPYB.IPY_TYPE = 'THIRD_PARTY_POLICY'
	 AND IPYB.QUOTE_YN = 'N'
	 AND IPYB.DATE_PROOF_PROVIDED IS NOT NULL
	 AND  IPYB.KHR_ID = l_khr_id
	UNION
	 SELECT IPYB.DATE_TO
	 FROM  OKL_INS_POLICIES_B  IPYB
	 WHERE   IPYB.IPY_TYPE = 'LEASE_POLICY'
	 AND   IPYB.QUOTE_YN = 'N'
	 AND   IPYB.ISS_CODE IN ('ACTIVE','EXPIRED','CANCELLED', 'PENDING')
	 AND  IPYB.KHR_ID = l_khr_id
	ORDER BY 1 DESC;

 	l_okl_last_ins_to_csr	okl_last_ins_to_csr%ROWTYPE;

	  CURSOR okl_k_capital_amt_csr (p_khr_id       NUMBER) IS
	 SELECT SUM(KLE.CAPITAL_AMOUNT) --,SUM(KLE.OEC)
		FROM OKC_K_LINES_B CLEB,OKL_K_LINES KLE
	       WHERE CLEB.ID = KLE.ID
                AND   CLEB.DNZ_CHR_ID = p_khr_id
                AND CLEB.CLE_ID IS NULL
	     GROUP BY  CLEB.DNZ_CHR_ID ;

         --smoduga added  for bug 3551010
         -- Fix for getting location based on install_base
         -- install_location_type
         CURSOR okl_financial_line_csr (p_khr_id NUMBER) IS
         select cle.id
         FROM OKC_K_LINES_B CLE ,
              OKC_LINE_STYLES_B LST,
              OKL_K_LINES kle
         where cle.dnz_chr_id = p_khr_id
               AND lst.lty_code ='FREE_FORM1'
               AND lst.id = cle.lse_id
               AND KLE.id = cle.id ;


   cursor c_rulecust_value (p_khr_id NUMBER) IS
  SELECT RUL.RULE_INFORMATION1,RUL.RULE_INFORMATION2
  FROM OKC_RULES_V RUL, OKC_RULE_GROUPS_V GRUL
  WHERE GRUL.RGD_CODE = 'INSRUL'
   AND RUL.RGP_ID = GRUL.ID
   AND RUL.rule_information_category = 'INCUST'
   AND GRUL.CHR_ID = p_khr_id ;

   cursor c_rulelessor_value (p_khr_id NUMBER)IS
  SELECT RUL.RULE_INFORMATION1
  FROM OKC_RULES_V RUL, OKC_RULE_GROUPS_V GRUL
  WHERE GRUL.RGD_CODE = 'INVRUL'
   AND RUL.RGP_ID = GRUL.ID
   AND RUL.rule_information_category = 'INVNIN'
   AND GRUL.CHR_ID = p_khr_id ;

  workflow_tbl_type OKL_AUTO_INSURANCE_PVT.policy_tbl_type ;
  policy_tbl_type  OKL_AUTO_INSURANCE_PVT.policy_tbl_type;
  noins_tbl_type OKL_AUTO_INSURANCE_PVT.policy_tbl_type;
  error_tbl_type OKL_AUTO_INSURANCE_PVT.policy_tbl_type;
	l_okl_provider_id	NUMBER;
	l_blanket_ins_yn     VARCHAR2(3) ;
	l_insurable_yn     VARCHAR2(3) ;
	l_prm_lessor_sell  VARCHAR2(3) ;
	l_khr_id       NUMBER ;
	ls_country     VARCHAR2(2);
	l_start_date   DATE ;
	l_deal_amoun   NUMBER ;
	ls_payment_freq VARCHAR2(30);
	l_deal_amount   NUMBER;
	l_end_date     DATE;
	lb_provider    BOOLEAN := FALSE ;
	l_afterlease_criteria   NUMBER ;
	x_message     VARCHAR2(100) ;
        l_init_msg_list              VARCHAR2(1) := Okc_Api.G_FALSE ;
	l_msg_count                   NUMBER ;
	l_msg_data                      VARCHAR2(2000);
	l_api_version                 CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	px_ipyv_rec                     ipyv_rec_type;
    l_api_name                     CONSTANT VARCHAR2(30) := 'AUTO_INS_ESTABLISHMENT';
	x_iasset_tbl                   Okl_Ins_Quote_Pvt.iasset_tbl_type ;
	l_policy_id					   NUMBER ;
	l_counter                     NUMBER :=  0;
    I  NUMBER  := 0;
    j  NUMBER  := 0;
    k NUMBER  := 0;
    L  NUMBER := 0;
    l_khr_number VARCHAR2(120) ;
    l_khr_start DATE ;
    ls_fin_line NUMBER;
    --Bug # 6318957 Changes Start
    l_khr_org_id NUMBER;
    --Bug # 6318957 Changes End

    --04-Jan-2004 PAGARG Bug# 3941338
    --Cursor to query user profile option name for given profile option name
    CURSOR l_profile_name_csr(p_profile_code IN VARCHAR2) IS
    SELECT USER_PROFILE_OPTION_NAME
    FROM FND_PROFILE_OPTIONS_VL
    WHERE PROFILE_OPTION_NAME = p_profile_code;
    l_profile_name FND_PROFILE_OPTIONS_TL.USER_PROFILE_OPTION_NAME%TYPE;

	BEGIN

Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---Automatic Insurance Start---');
Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
	-- Get values from system profile for Number of days
	l_afterlease_criteria := fnd_profile.value('OKLINDAYSFORAUTOINS');

    --04-Jan-2004 PAGARG Bug# 3941338
    --Obtain user profile option name for given profile option name
    OPEN l_profile_name_csr('OKLINDAYSFORAUTOINS');
    FETCH l_profile_name_csr INTO l_profile_name;
    CLOSE l_profile_name_csr;

	-- Check for NULL values and return if either of these is null
     IF l_afterlease_criteria = Okc_Api.G_MISS_NUM OR l_afterlease_criteria IS NULL    THEN
		 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'System profile value for ' || l_profile_name || ' is not defined');
	     RETURN;
      END IF;

	-- Get all mandatory data
    ls_payment_freq := fnd_profile.value('OKLINPAYMENTFREQUENCY');

    --04-Jan-2004 PAGARG Bug# 3941338
    --Obtain user profile option name for given profile option name
    OPEN l_profile_name_csr('OKLINPAYMENTFREQUENCY');
    FETCH l_profile_name_csr INTO l_profile_name;
    CLOSE l_profile_name_csr;

	-- Check for NULL values and return if any of these is null
	    IF ls_payment_freq = Okc_Api.G_MISS_CHAR OR     ls_payment_freq IS NULL    THEN
        	Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'System profile value for ' || l_profile_name || ' is not defined');
            RETURN;
        END IF;

	BEGIN

	  OPEN okl_eli_policies_csr (l_afterlease_criteria)	;
--        new_contract;
	    LOOP
             FETCH okl_eli_policies_csr INTO l_okl_eli_policies_csr;
   	            EXIT WHEN okl_eli_policies_csr%NOTFOUND;

                l_khr_id  := l_okl_eli_policies_csr.ID ;
                l_khr_number := l_okl_eli_policies_csr.CONTRACT_NUMBER;
                l_khr_start := l_okl_eli_policies_csr.start_date;
                --Bug # 6318957 Changes Start
                l_khr_org_id := l_okl_eli_policies_csr.org_id;
                --Bug # 6318957 Changes End
   mo_global.set_policy_context('S', l_khr_org_id); --added by zrehman for Bug#6363652 10-Oct-2007
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'--For Contract Number--'|| l_khr_number );
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');


   		 OPEN c_rulecust_value(l_khr_id);
         FETCH c_rulecust_value INTO l_blanket_ins_yn, l_insurable_yn ;
         IF (c_rulecust_value%NOTFOUND) THEN
           l_blanket_ins_yn := 'N';
           l_insurable_yn := 'Y' ;
         END IF;
         close c_rulecust_value ;


         OPEN c_rulelessor_value(l_khr_id);
         FETCH c_rulelessor_value INTO l_prm_lessor_sell ;
         IF (c_rulelessor_value%NOTFOUND) THEN
           l_prm_lessor_sell := 'Y';
         END IF;
         close c_rulelessor_value ;


   		  IF (l_blanket_ins_yn = 'Y' ) THEN -- <1
            Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Contract Number'|| l_khr_number ||'has blanket insurance ');
            I := I + 1;
            noins_tbl_type(I).CONTRACT_NUMBER := l_khr_number ;
            noins_tbl_type(I).start_date := l_khr_start ;

          ELSIF(l_insurable_yn = 'N') THEN -- <1
            Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Customer not insurable (Master Lease) for Contract Number '||l_khr_number);
            -- Initiate Workflow
            create_third_party_task_event
            ( p_contract_id   => l_khr_id,
	      p_org_id        => l_khr_org_id,
              x_retrun_status => l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
                     J:= J+ 1 ;
                workflow_tbl_type(j).CONTRACT_NUMBER := l_khr_number ;
                workflow_tbl_type(j).start_date := l_khr_start ;
            ELSE
                Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Error in raising business event for Contract Number '||l_khr_number );
                K := k + 1 ;
                error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                error_tbl_type(k).start_date := l_khr_start ;
               -- Need to check
                lb_provider := true;
            END IF;


          ELSIF(l_prm_lessor_sell = 'N' ) THEN                           -- 1
              Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Vendor Program does not allow insurance for Contract Number '||l_khr_number );
              -- Initiate Workflow
              create_third_party_task_event
            ( p_contract_id   => l_khr_id,
	      p_org_id        => l_khr_org_id,
              x_retrun_status => l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
                     J:= J+ 1 ;
                workflow_tbl_type(j).CONTRACT_NUMBER := l_khr_number ;
                workflow_tbl_type(j).start_date := l_khr_start ;
            ELSE
                Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Error in raising business event for Contract Number '||l_khr_number );
                K := k + 1 ;
                error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                error_tbl_type(k).start_date := l_khr_start ;
               -- Need to check
                lb_provider := true;
            END IF;

          ELSE         --<1
            -- SMODUGA
           -- Added as part of fix for Canon bug 3551010
           --Get Financial Line
              OPEN okl_financial_line_csr(l_khr_id);
              FETCH okl_financial_line_csr INTO ls_fin_line;
              IF(okl_financial_line_csr%NOTFOUND) THEN
               CLOSE okl_financial_line_csr;
                K := k+1;
                error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                error_tbl_type(k).start_date := l_khr_start ;
                lb_provider := true;
               Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Financial Line not setup for Contract Number '|| l_khr_number);
              ELSIF (ls_fin_line = Okc_Api.G_MISS_NUM AND ls_fin_line IS NULL )   THEN      -- <2
                  CLOSE okl_financial_line_csr;
                  K := k + 1 ;
                  lb_provider := true;
                  error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                  error_tbl_type(k).start_date := l_khr_start ;
               Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Financial Line not setup for Contract Number '|| l_khr_number);
              ELSE   -- <2
                 CLOSE okl_financial_line_csr;
              END IF;
            -- GET COUNTRY
               ls_country := OKL_UTIL.get_active_line_inst_country(ls_fin_line);
            IF (ls_country = Okc_Api.G_MISS_CHAR AND ls_country IS NULL )   THEN      -- <2
                  K := k + 1 ;
                  lb_provider := true;
                  error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                  error_tbl_type(k).start_date := l_khr_start ;
            	  Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Location is missing for Contract Number'||l_khr_number );
            ELSE
            -- Added as part of fix for Canon bug 3551010
            --SMODUGA


				 OPEN okl_k_capital_amt_csr(l_khr_id);
				 FETCH okl_k_capital_amt_csr INTO l_deal_amount ;
				 IF( okl_k_capital_amt_csr%NOTFOUND) THEN --< 3
                    CLOSE okl_k_capital_amt_csr;
                    K := k + 1 ;
                  error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                  error_tbl_type(k).start_date := l_khr_start ;
                    lb_provider := true;
	       	 	    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Capital Amount is missing for Contract Number '||l_khr_number);
                 ELSE -- < 3
    				 CLOSE okl_k_capital_amt_csr;

                    OPEN okl_last_ins_to_csr (l_khr_id); -- changed by zrehman as part of Bug#6363652 09-Oct-2007
		    -- Loop for FROM DATE
	    	       FETCH okl_last_ins_to_csr INTO l_okl_last_ins_to_csr;
	                IF (okl_last_ins_to_csr%NOTFOUND) THEN
			             l_start_date := l_okl_eli_policies_csr.START_DATE ;
			        ELSE
			             l_start_date := l_okl_last_ins_to_csr.DATE_TO;
    			   END IF ;
	    		  CLOSE okl_last_ins_to_csr ;
			     -- Get End Date
		    	 l_end_date := l_okl_eli_policies_csr.END_DATE ;
	             OPEN okl_provider_csr (ls_country, l_deal_amount )	;
               LOOP
                  IF(lb_provider = true) then
                   exit;
                  END IF;
		          FETCH okl_provider_csr INTO l_okl_provider_csr;
                  EXIT WHEN okl_provider_csr%NOTFOUND;

			     px_ipyv_rec.KHR_ID  := l_khr_id ;
                 px_ipyv_rec.IPY_TYPE  := 'LEASE_POLICY' ;
		         px_ipyv_rec.DATE_FROM  := l_start_date ;
		         px_ipyv_rec.DATE_TO  := l_end_date ;
		         px_ipyv_rec.IPF_CODE := ls_payment_freq ;
		         px_ipyv_rec.ISU_ID   := l_okl_provider_csr.isu_id ;
    			 px_ipyv_rec.territory_code := ls_country;
			     px_ipyv_rec.lessor_insured_yn := 'Y' ;
    			 px_ipyv_rec.lessor_payee_yn := 'Y' ;
                 px_ipyv_rec.DATE_QUOTED         := SYSDATE - 10 ;
                 px_ipyv_rec.DATE_QUOTE_EXPIRY  := SYSDATE + 20 ;
                 px_ipyv_rec.OBJECT_VERSION_NUMBER := 1;
                 --Bug # 6318957 Changes Start
                 px_ipyv_rec.org_id := l_khr_org_id;
                 --Bug # 6318957 Changes End

			     Okl_Ins_Quote_Pub.calc_lease_premium(
			       p_api_version                  => l_api_version ,
         		   p_init_msg_list                => Okc_Api.G_TRUE,
	          	   x_return_status                => l_return_status,
	          	   x_msg_count                    => l_msg_count,
	          	   x_msg_data                     => l_msg_data,
         		   px_ipyv_rec                    => px_ipyv_rec,
	     		   x_message                      =>x_message,
         		   x_iasset_tbl                  => x_iasset_tbl  );

			    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN --<4
				    FOR i IN 1..l_msg_count  LOOP
				 	     JTF_PLSQL_API.get_messages(i,l_msg_data);
                         Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
    				END LOOP;
				  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF(l_return_status = OKC_API.G_RET_STS_ERROR) THEN --<4
                   IF(x_message = OKL_INS_QUOTE_PVT.G_NO_INS ) THEN --<5
                           lb_provider := false;
                           FOR i IN 1..l_msg_count  LOOP
				 	         JTF_PLSQL_API.get_messages(i,l_msg_data);
                             Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				           END LOOP;
                           EXIT;
                   ELSIF(x_message = OKL_INS_QUOTE_PVT.G_NOT_ABLE ) THEN--<5
                      --Get Next Provider

                        NULL;
                   ELSE      --<5

   		 		       FOR i IN 1..l_msg_count  LOOP
				 	      JTF_PLSQL_API.get_messages(i,l_msg_data);
                          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				       END LOOP;
                       K := k + 1 ;
                    error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                    error_tbl_type(k).start_date := l_khr_start ;

                       EXIT;
                  END IF; -->5
               ELSE  --<4
                SAVEPOINT auto_insurance;
                lb_provider := TRUE ;
                px_ipyv_rec.ADJUSTMENT := 0 ;
			    Okl_Ins_Quote_Pub.save_accept_quote(
			        p_api_version                  => l_api_version ,
         		   p_init_msg_list                => Okc_Api.G_TRUE,
	          	   x_return_status                => l_return_status,
	          	   x_msg_count                    => l_msg_count,
	          	   x_msg_data                     => l_msg_data,
         		   p_ipyv_rec                    => px_ipyv_rec,
	     		   x_message                      =>x_message
				   );
			 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                ROLLBACK TO auto_insurance;
   				 FOR i IN 1..l_msg_count  LOOP
				 	 JTF_PLSQL_API.get_messages(i,l_msg_data);
                     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				  END LOOP;
				  EXIT;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              ROLLBACK TO auto_insurance;
   				 FOR i IN 1..l_msg_count  LOOP
				 	 JTF_PLSQL_API.get_messages(i,l_msg_data);
                     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				  END LOOP;
				  EXIT;
             END IF;
             SELECT IPY_ID
             INTO l_policy_id
             FROM OKL_INS_POLICIES_B
             WHERE ID =x_message ;

       IF (l_policy_id IS NULL) THEN
        lb_provider := FALSE ;
       ELSE   ---< 5
              L := L + 1 ;
                  policy_tbl_type(l).CONTRACT_NUMBER := l_khr_number ;
                  policy_tbl_type(l).start_date := l_khr_start ;

              COMMIT ;
              SAVEPOINT ACTIVATE ;
		  	  Okl_Ins_Quote_Pub.activate_ins_policy(
			       p_api_version                  => l_api_version ,
         		       p_init_msg_list                => Okc_Api.G_TRUE,
	          	       x_return_status                => l_return_status,
	          	       x_msg_count                    => l_msg_count,
	          	       x_msg_data                     => l_msg_data,
         		       p_ins_policy_id                => l_policy_id  	);

			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              ROLLBACK TO ACTIVATE ;
			    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Activate Policy for Contract' ||l_khr_number );
   				 FOR i IN 1..l_msg_count  LOOP
				 	 JTF_PLSQL_API.get_messages(i,l_msg_data);
                     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				  END LOOP;
				  EXIT;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              ROLLBACK TO ACTIVATE ;
   			    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Activate Policy for Contract' ||l_khr_number );
				 FOR i IN 1..l_msg_count  LOOP
				 	 JTF_PLSQL_API.get_messages(i,l_msg_data);
                     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,l_msg_data );
				  END LOOP;
				  EXIT;
            END IF;
            COMMIT  ;
         END IF ;--- 5>
        END IF ; ---4>
		END LOOP;
        CLOSE okl_provider_csr;
        END IF ; ---3>
        END IF ;---2>
        END IF ; ---1>
		  -- Loop for provider
		 IF(lb_provider <> TRUE ) THEN
                   -- Initiate Workflow

           create_third_party_task_event
            ( p_contract_id   => l_khr_id,
	      p_org_id        => l_khr_org_id,
              x_retrun_status => l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
                     J:= J+ 1 ;
                workflow_tbl_type(j).CONTRACT_NUMBER := l_khr_number ;
                workflow_tbl_type(j).start_date := l_khr_start ;
            ELSE
                Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Error in raising business event for Contract Number '||l_khr_number );
                K := k + 1 ;
                error_tbl_type(k).CONTRACT_NUMBER := l_khr_number ;
                error_tbl_type(k).start_date := l_khr_start ;
               -- Need to check
                lb_provider := true;
            END IF;
		   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'No Provider to provide insurance for Contract Number ' ||l_khr_number );		  -- Initiate Workflow
		 END IF ;
         lb_provider := FALSE;
	END LOOP ;
    CLOSE okl_eli_policies_csr ;
   mo_global.init('M'); --added by zrehman for Bug#6363652 10-Oct-2007
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---------------------- Summary -----------------------------');
    IF (policy_tbl_type.COUNT > 0) THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Policy Created For Contracts');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'Contract Number     Start Date ' );
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'--------------------------------' );
      FOR i IN policy_tbl_type.first..policy_tbl_type.last LOOP
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||policy_tbl_type(i).CONTRACT_NUMBER  ||'  ' ||TO_CHAR(policy_tbl_type(i).start_date) );
      END LOOP;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Total    = ' || policy_tbl_type.COUNT);
    END IF;


    IF (workflow_tbl_type.COUNT > 0) THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Third Party Workflow Initiated for Contracts');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'Contract Number     Start Date ' );
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'--------------------------------' );
      FOR n IN workflow_tbl_type.first..workflow_tbl_type.last LOOP
       Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||workflow_tbl_type(n).CONTRACT_NUMBER  ||'  ' ||TO_CHAR(workflow_tbl_type(n).start_date) );
      END LOOP;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Total   = ' || workflow_tbl_type.COUNT);
    END IF;

    IF (noins_tbl_type.COUNT > 0) THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'No Insurance Required for Contracts');
       Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'Contract Number     Start Date ' );
       Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'--------------------------------' );
      FOR n IN noins_tbl_type.first..noins_tbl_type.last LOOP
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||noins_tbl_type(n).CONTRACT_NUMBER  ||'  ' ||TO_CHAR(noins_tbl_type(n).start_date) );
      END LOOP;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Total   = ' || noins_tbl_type.COUNT);
    END IF;

      IF ( error_tbl_type.COUNT > 0) THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'There are errors in Contracts');
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'Contract Number     Start Date ' );
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||'--------------------------------' );
      FOR n IN  error_tbl_type.first.. error_tbl_type.last LOOP
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'                            '||error_tbl_type(n).CONTRACT_NUMBER  ||'  ' ||TO_CHAR(error_tbl_type(n).start_date) );
      END LOOP;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'Total   = ' || error_tbl_type.COUNT);

    END IF;
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'---Automatic Insurance End---');
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,'-------------------------------------------------------------');

		EXCEPTION
          		WHEN OTHERS THEN
		IF l_profile_name_csr%ISOPEN THEN
  	      	      CLOSE l_profile_name_csr;
  	    END IF;
		IF okl_eli_policies_csr%ISOPEN THEN
  	      	      CLOSE okl_eli_policies_csr;
  	    END IF;
  	          l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR ;
		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
 END;
END  auto_ins_establishment ;
END OKL_AUTO_INSURANCE_PVT;

/

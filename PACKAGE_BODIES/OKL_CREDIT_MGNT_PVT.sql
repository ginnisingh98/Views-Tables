--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MGNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MGNT_PVT" AS
/* $Header: OKLRCMTB.pls 120.3 2005/10/30 04:32:20 appldev noship $ */

  ------------------------
  -- submit_credit_request
  ------------------------
  PROCEDURE submit_credit_request
                    (p_api_version                  IN  NUMBER
                    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status                OUT NOCOPY VARCHAR2
                    ,x_msg_count                    OUT NOCOPY NUMBER
                    ,x_msg_data                     OUT NOCOPY VARCHAR2
                    ,p_contract_id                  IN  NUMBER
                    ,p_review_type                  IN  VARCHAR2
                    ,p_credit_classification        IN  VARCHAR2
                    ,p_requested_amount             IN  NUMBER
                    ,p_contact_party_id             IN  NUMBER
                    ,p_notes                        IN  VARCHAR2
                    ,p_chr_rec                      IN  l_chr_rec) IS

    l_cm_installed           BOOLEAN;
    l_request_status         VARCHAR2(30);
    l_application_number     VARCHAR2(30);
    l_k_start_date           DATE;
    l_currency               VARCHAR2(15);
    l_org_id                 NUMBER;
    l_party_id               NUMBER;
    l_term                   NUMBER;
    l_credit_classification  VARCHAR2(30);
    lx_credit_request_id     NUMBER;
    l_resource_id            NUMBER;
    l_return_status          VARCHAR2(1);

    l_interaction_rec        jtf_ih_pub.interaction_rec_type;
    l_activity_rec           jtf_ih_pub.activity_rec_type;
    lx_interaction_id        NUMBER;
    lx_activity_id           NUMBER;

    l_crqv_rec               okl_crq_pvt.crqv_rec_type;
    lx_crqv_rec              okl_crq_pvt.crqv_rec_type;

    CURSOR c_check_submitted IS
      SELECT credit_req_number,
             status
      FROM   okl_credit_requests
      WHERE  quote_id = p_contract_id
      AND    status IN ('SUBMITTED' , 'APPROVED');

    CURSOR c_credit_class IS
      SELECT CREDIT_CLASSIFICATION_CODE
      FROM   hz_cust_accounts
      WHERE  cust_account_id = p_chr_rec.cust_acct_id;

  BEGIN

    l_cm_installed := AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed;

    IF NOT l_cm_installed THEN

      OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_CM_NOTINSTALLED');

      RAISE G_EXCEPTION_ERROR;

    END IF;

    OPEN  c_check_submitted;
    FETCH c_check_submitted INTO l_application_number, l_request_status;
    CLOSE c_check_submitted;

    IF l_application_number IS NOT NULL THEN

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CR_SUBMITTED',
                          p_token1       => 'REQ_ID',
                          p_token1_value => l_application_number,
                          p_token2       => 'REQ_STATUS',
                          p_token2_value => l_request_status );

      RAISE G_EXCEPTION_ERROR;

    END IF;

    IF p_requested_amount <= 0 THEN

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CR_AMT_ZERO');

      RAISE G_EXCEPTION_ERROR;

    END IF;

    SELECT  chr.start_date,
            chr.currency_code,
            chr.authoring_org_id,
            cpl.object1_id1,
            khr.term_duration
    INTO    l_k_start_date,
            l_currency,
            l_org_id,
            l_party_id,
            l_term
    FROM    okc_k_headers_b chr,
            okl_k_headers khr,
            okc_k_party_roles_b cpl
    WHERE   chr.id = p_contract_id
    AND     chr.id = khr.id
    AND     chr.id = cpl.dnz_chr_id
    AND     cpl.rle_code = 'LESSEE';

    SELECT AR_CMGT_APPLICATION_NUM_S.NEXTVAL
    INTO   l_application_number
    FROM   DUAL;

    OPEN  c_credit_class;
    FETCH c_credit_class INTO l_credit_classification;
    CLOSE c_credit_class;

    ar_cmgt_credit_request_api.create_credit_request
             ( p_api_version           => G_API_VERSION
              ,p_init_msg_list         => OKL_API.G_FALSE
              ,p_commit                => 'Y'
              ,p_validation_level      => ''
              ,x_return_status         => l_return_status
              ,x_msg_count             => x_msg_count
              ,x_msg_data              => x_msg_data
              ,p_application_number    => l_application_number
              ,p_application_date      => TRUNC(SYSDATE)
              ,p_requestor_type        => NULL
              ,p_requestor_id          => fnd_global.employee_id
              ,p_review_type           => 'NEW_CREDIT_LIMIT'
              ,p_credit_classification => l_credit_classification
              ,p_requested_amount      => p_requested_amount
              ,p_requested_currency    => l_currency
              ,p_trx_amount            => NULL
              ,p_trx_currency          => NULL
              ,p_credit_type           => 'TERM'
              ,p_term_length           => l_term
              ,p_credit_check_rule_id  => NULL
              ,p_credit_request_status => 'SUBMIT'
              ,p_party_id              => l_party_id
              ,p_cust_account_id       => p_chr_rec.cust_acct_id
              ,p_cust_acct_site_id     => NULL
              ,p_site_use_id           => NULL
              ,p_contact_party_id      => p_contact_party_id
              ,p_notes                 => p_notes
              ,p_source_org_id         => l_org_id
              ,p_source_user_id        => fnd_global.USER_ID
              ,p_source_resp_id        => fnd_global.RESP_ID
              ,p_source_appln_id       => 540
              ,p_source_security_group_id => fnd_global.SECURITY_GROUP_ID
              ,p_source_name           => 'OKL'
              ,p_source_column1        => ''
              ,p_source_column2        => ''
              ,p_source_column3        => ''
              ,p_credit_request_id     => lx_credit_request_id
              ,p_review_cycle          => '');

    IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_crqv_rec.quote_id           := p_contract_id;
    l_crqv_rec.credit_req_number  := l_application_number;
    l_crqv_rec.credit_req_id      := lx_credit_request_id;
    l_crqv_rec.credit_amount      := p_requested_amount;
    l_crqv_rec.requested_by       := fnd_global.EMPLOYEE_ID;
    l_crqv_rec.requested_date     := sysdate;
    l_crqv_rec.approved_by        := NULL;
    l_crqv_rec.approved_date      := NULL;
    l_crqv_rec.status             := 'SUBMITTED';
    l_crqv_rec.credit_khr_id      := NULL;
    l_crqv_rec.currency_code      := l_currency;
    l_crqv_rec.org_id             := l_org_id;

    okl_credit_request_pub.insert_credit_request(
             p_api_version                  => G_API_VERSION
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data
            ,p_crqv_rec                     => l_crqv_rec
            ,x_crqv_rec                     => lx_crqv_rec);

    IF l_return_status = G_RET_STS_ERROR THEN
       RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_return_status := okl_cs_lc_contract_pvt.get_resource_id(l_resource_id);

    IF l_return_status = G_RET_STS_ERROR THEN
       RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_interaction_rec.start_date_time  := SYSDATE;
    l_interaction_rec.handler_id       := 540;
    l_interaction_rec.resource_id      := l_resource_id;
    l_interaction_rec.outcome_id       := 10;
    l_interaction_rec.party_id         := l_party_id;

    jtf_ih_pub.open_interaction(
            p_api_version     => G_API_VERSION,
            p_init_msg_list   => OKL_API.G_FALSE,
            p_commit          => OKL_API.G_TRUE,
            p_user_id         => fnd_global.USER_ID,
            p_login_id        => fnd_global.LOGIN_ID,
            x_return_status   => l_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_interaction_rec => l_interaction_rec,
            x_interaction_id  => lx_interaction_id);

    IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_activity_rec.cust_account_id  := p_chr_rec.cust_acct_id;
    l_activity_rec.cust_org_id      := l_org_id;
    l_activity_rec.start_date_time  := SYSDATE;
    l_activity_rec.action_item_id   := 87;
    l_activity_rec.interaction_id   := lx_interaction_id;
    l_activity_rec.outcome_id       := 10;
    l_activity_rec.action_id        := 1;

    jtf_ih_pub.add_activity(
            p_api_version     => G_API_VERSION,
            p_init_msg_list   => OKL_API.G_FALSE,
            p_commit          => OKL_API.G_TRUE,
            p_user_id         => fnd_global.USER_ID,
            p_login_id        => fnd_global.LOGIN_ID,
            x_return_status   => l_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_activity_rec    => l_activity_rec,
            x_activity_id     => lx_activity_id);

    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    jtf_ih_pub.CLOSE_INTERACTION (
            p_api_version     => G_API_VERSION,
            p_init_msg_list   => OKL_API.G_FALSE,
            p_commit          => OKL_API.G_TRUE,
            P_RESP_APPL_ID    => 540,
            P_RESP_ID         => fnd_global.RESP_ID,
            p_user_id         => fnd_global.USER_ID,
            p_login_id        => fnd_global.LOGIN_ID,
            x_return_status   => l_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            P_INTERACTION_ID  => lx_interaction_id);

    IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

      OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_CR_SUBMIT',
                          p_token1       => 'REQ_NUM',
                          p_token1_value => l_application_number);
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := G_RET_STS_ERROR;

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE(p_app_name   => G_APP_NAME,
                          p_msg_name  => G_UNEXPECTED_ERROR,
                          p_token1 => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2 => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END submit_credit_request;


  -------------------------
  -- compile_credit_request
  -------------------------
  PROCEDURE compile_credit_request
                    (p_api_version                  IN  NUMBER
                    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status                OUT NOCOPY VARCHAR2
                    ,x_msg_count                    OUT NOCOPY NUMBER
                    ,x_msg_data                     OUT NOCOPY VARCHAR2
                    ,p_contract_id                  IN  NUMBER
                    ,x_chr_rec                      OUT NOCOPY l_chr_rec
                    ) IS

    l_return_status       VARCHAR2(1);
    l_application_number  VARCHAR2(30);
    l_request_status      VARCHAR2(30);
    l_cm_installed        BOOLEAN;
    l_ctrct_financed_amt  NUMBER;

    CURSOR c_check_submitted IS
      SELECT credit_req_number,
             status
      FROM   okl_credit_requests
      WHERE  quote_id = p_contract_id
      AND    status IN ('SUBMITTED' , 'APPROVED');

  BEGIN

    l_cm_installed := AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed;

    IF NOT l_cm_installed THEN

      OKL_API.set_message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_CM_NOTINSTALLED');

      RAISE G_EXCEPTION_ERROR;

    END IF;

    OPEN  c_check_submitted;
    FETCH c_check_submitted INTO l_application_number, l_request_status;
    CLOSE c_check_submitted;

    IF l_application_number IS NOT NULL THEN

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CR_SUBMITTED',
                          p_token1       => 'REQ_ID',
                          p_token1_value => l_application_number,
                          p_token2       => 'REQ_STATUS',
                          p_token2_value => l_request_status );

      RAISE G_EXCEPTION_ERROR;

    END IF;

    okl_execute_formula_pub.execute(p_api_version   => G_API_VERSION,
                                    p_init_msg_list => OKL_API.G_FALSE,
                                    x_return_status => l_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id   => p_contract_id,
                                    p_line_id       => null,
                                    x_value         => l_ctrct_financed_amt);

    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    SELECT  chr.id,
            chr.contract_number,
            chr.cust_acct_id,
            chr.currency_code,
            chr.authoring_org_id,
            cpl.object1_id1,
            khr.term_duration
    INTO    x_chr_rec.contract_id,
            x_chr_rec.contract_number,
            x_chr_rec.cust_acct_id,
            x_chr_rec.currency,
            x_chr_rec.org_id,
            x_chr_rec.party_id,
            x_chr_rec.term
    FROM    okc_k_headers_b chr,
            okl_k_headers khr,
            okc_k_party_roles_b cpl
    WHERE   chr.id = p_contract_id
    AND     chr.id = khr.id
    AND     chr.id = cpl.dnz_chr_id
    AND     cpl.rle_code = 'LESSEE';

    x_chr_rec.requested_amount := l_ctrct_financed_amt;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := G_RET_STS_ERROR;

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE(p_app_name   => G_APP_NAME,
                          p_msg_name  => G_UNEXPECTED_ERROR,
                          p_token1 => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2 => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END compile_credit_request;

END OKL_CREDIT_MGNT_PVT;

/

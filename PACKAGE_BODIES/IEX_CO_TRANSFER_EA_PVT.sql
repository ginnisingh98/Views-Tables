--------------------------------------------------------
--  DDL for Package Body IEX_CO_TRANSFER_EA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CO_TRANSFER_EA_PVT" AS
/* $Header: IEXRTEAB.pls 120.1 2004/03/17 18:03:52 jsanju ship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_code_meaning
  ---------------------------------------------------------------------------
  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

FUNCTION get_code_meaning(p_lookup_type IN VARCHAR2
                           ,p_lookup_code IN VARCHAR2) RETURN VARCHAR2 AS
  l_meaning FND_LOOKUPS.MEANING%TYPE := NULL;
  BEGIN
    SELECT meaning INTO l_meaning
    FROM FND_LOOKUPS
    WHERE lookup_type = p_lookup_type
    AND   lookup_code = p_lookup_code;

    RETURN(l_meaning);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(l_meaning);
  END get_code_meaning;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_case_details
  ---------------------------------------------------------------------------
  PROCEDURE get_case_details (
     p_cas_id                   IN NUMBER,
     x_case_rec                 OUT NOCOPY case_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_case_rec                 case_rec_type;

     l_party_rec                okl_opi_pvt.party_rec_type;
     l_owner_resource_id        NUMBER;
     l_resource_phone           VARCHAR2(100);
     l_resource_email           VARCHAR2(1995);
     l_address                  VARCHAR2(1995);
     l_date                     DATE;
     l_ext_agncy_name           VARCHAR2(80);

     CURSOR l_case_csr(cp_cas_id IN NUMBER) IS SELECT ic.status_code
     , ic.case_number
     , ico.object_id
     FROM iex_cases_all_b ic
     , iex_case_objects ico
     WHERE ic.cas_id = cp_cas_id
     AND ic.cas_id = ico.cas_id
     AND rownum = 1;
  BEGIN
    l_case_rec.cas_id := p_cas_id;

    --get case owner
    okl_opi_pvt.get_case_owner(p_cas_id => l_case_rec.cas_id
                              ,x_owner_resource_id => l_owner_resource_id
                              ,x_resource_name => l_case_rec.case_owner
                              ,x_resource_phone => l_resource_phone
                              ,x_resource_email => l_resource_email
                              ,x_return_status => l_return_status);

    FOR cur IN l_case_csr(l_case_rec.cas_id) LOOP
      l_case_rec.case_number := cur.case_number;
      l_case_rec.case_status := get_code_meaning('OKL_CASE_STATUS', cur.status_code);

      --get case customer
      okl_opi_pvt.get_party(p_contract_id => cur.object_id
                         ,x_party_rec => l_party_rec
                         ,x_return_status => l_return_status);

      l_case_rec.party_name := l_party_rec.party_name;
      l_case_rec.party_type := initcap(l_party_rec.party_type);

      l_address := rtrim(l_party_rec.ADDRESS1);
      IF(rtrim(l_party_rec.ADDRESS2) IS NOT NULL) THEN
        l_address := l_address || fnd_global.local_chr(10) || rtrim(l_party_rec.ADDRESS2);
      END IF;

      IF(rtrim(l_party_rec.ADDRESS3) IS NOT NULL) THEN
        l_address := l_address || fnd_global.local_chr(10) ||  rtrim(l_party_rec.ADDRESS3);
      END IF;

      IF(rtrim(l_party_rec.ADDRESS4) IS NOT NULL) THEN
        l_address := l_address || fnd_global.local_chr(10) ||  rtrim(l_party_rec.ADDRESS4);
      END IF;

      IF(rtrim(l_party_rec.street) IS NOT NULL) THEN
        l_address := l_address || fnd_global.local_chr(10) || l_party_rec.house_number || ' ' || l_party_rec.street || ' ' || l_party_rec.apartment_number;
      END IF;
      l_address := l_address || fnd_global.local_chr(10) || l_party_rec.city || ' ' || l_party_rec.state || ' ' || l_party_rec.postal_code || ' ' || l_party_rec.country;
      l_case_rec.party_address := l_address;
    END LOOP;

    BEGIN
    SELECT external_agency_transfer_date
    INTO l_date
    FROM OKL_OPEN_INT
    WHERE cas_id = p_cas_id
    AND external_agency_transfer_date IS NOT NULL
    AND rownum = 1;

    l_case_rec.last_transfer_date := l_date;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    END;

    BEGIN
    l_date := null;
    SELECT trunc(b.review_date)
    INTO l_date
    FROM OKL_OPEN_INT a,
    IEX_OPEN_INT_HST b
    WHERE a.cas_id = p_cas_id
    AND a.khr_id = to_number(b.object1_id1)
    AND b.action = 'TRANSFER_EXT_AGNCY'
    AND (b.status = 'PROCESSED' OR b.status = 'NOTIFIED')
    AND rownum = 1;

    l_case_rec.case_review_date := l_date;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    END;

    BEGIN
    SELECT c.external_agency_name
    INTO l_ext_agncy_name
    FROM OKL_OPEN_INT a,
    IEX_OPEN_INT_HST b,
    IEX_EXT_AGNCY_B c
    WHERE a.cas_id = p_cas_id
    AND a.khr_id = to_number(b.object1_id1)
    AND b.action = 'TRANSFER_EXT_AGNCY'
    AND (b.status = 'PROCESSED' OR b.status = 'NOTIFIED')
    AND b.ext_agncy_id IS NOT NULL
    AND (b.ext_agncy_id = c.external_agency_id)
    AND rownum = 1;

    l_case_rec.ext_agncy_name := l_ext_agncy_name;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    END;

    x_case_rec := l_case_rec;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_case_details;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_contract_details
  ---------------------------------------------------------------------------
  PROCEDURE get_contract_details (
     p_khr_id                   IN NUMBER,
     x_form_contract_rec        OUT NOCOPY form_contract_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     lp_contract_rec            okl_opi_pvt.contract_rec_type;
     lx_contract_rec            okl_opi_pvt.contract_rec_type;
     l_form_contract_rec        form_contract_rec_type;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    okl_opi_pvt.get_contract(p_contract_id => p_khr_id
                 ,x_contract_rec => lx_contract_rec
                 ,x_return_status => l_return_status);

    l_form_contract_rec.contract_number := lx_contract_rec.contract_number;
    l_form_contract_rec.contract_type := initcap(lx_contract_rec.contract_type);
    l_form_contract_rec.contract_status := get_code_meaning('OKC_STATUS_TYPE', lx_contract_rec.contract_status);


    l_form_contract_rec.original_amount := lx_contract_rec.original_amount;
    l_form_contract_rec.start_date := lx_contract_rec.start_date;
    l_form_contract_rec.close_date := lx_contract_rec.close_date;
    l_form_contract_rec.term_duration := lx_contract_rec.term_duration;

    lp_contract_rec := lx_contract_rec;

    okl_opi_pvt.get_contract_payment_info(p_contract_rec => lp_contract_rec
                ,x_contract_rec => lx_contract_rec
                ,x_return_status => l_return_status);

    l_form_contract_rec.monthly_payment_amount := lx_contract_rec.monthly_payment_amount;
    l_form_contract_rec.last_payment_date := lx_contract_rec.last_payment_date;
    l_form_contract_rec.delinquency_occurance_date := lx_contract_rec.delinquency_occurance_date;
    l_form_contract_rec.past_due_amount := lx_contract_rec.past_due_amount;
    l_form_contract_rec.outstanding_receivable := lx_contract_rec.remaining_amount;

    x_form_contract_rec := l_form_contract_rec;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_contract_details;

END IEX_CO_TRANSFER_EA_PVT;

/

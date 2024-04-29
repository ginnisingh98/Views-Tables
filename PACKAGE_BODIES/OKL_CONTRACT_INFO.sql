--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_INFO" AS
/* $Header: OKLRCONB.pls 120.6 2007/10/26 10:23:12 dkagrawa ship $ */

  ---------------------------------------------------------------------------
  -- FUNCTION get_customer
  ---------------------------------------------------------------------------
  FUNCTION get_customer(
     p_contract_id	IN NUMBER,
     x_customer		OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_api_version       NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_init_msg_list     VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_party_tab         OKL_JTOT_EXTRACT.party_tab_type;
  BEGIN

    -- Procedure to call to get Party or Customer ID
    OKL_JTOT_EXTRACT.Get_Party (
          l_api_version,
          l_init_msg_list,
          l_return_status,
          l_msg_count,
          l_msg_data,
          p_contract_id,
          null,
          'LESSEE',
          'S',
          l_party_tab
          );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    IF l_party_tab.FIRST IS NOT NULL
    THEN --fetch from table only if some data is retrieved
      FOR i in 1..l_party_tab.LAST
      LOOP
        x_customer := l_party_tab(i).id1;
      END LOOP;
    ELSE
      x_customer := NULL;
    END IF;

    RETURN l_return_status;
    EXCEPTION
      WHEN okl_api.G_EXCEPTION_ERROR THEN
        OKC_API.SET_MESSAGE( p_app_name   => G_APP_NAME
                          ,p_msg_name     => G_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

      WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        OKC_API.SET_MESSAGE( p_app_name   => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE( p_app_name   => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_customer;

  ---------------------------------------------------------------------------
  -- FUNCTION get_vendor_program
  ---------------------------------------------------------------------------
  FUNCTION get_vendor_program(
     p_contract_id	IN NUMBER,
     x_vendor_program	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    -- Get the vendor Program description
    CURSOR vendor_program_csr(p_contract_id NUMBER) IS
      SELECT SUBSTR(description,1,240) FROM okc_k_headers_tl
      WHERE  ID =
        ( SELECT khr_id
          FROM   okl_k_headers
          WHERE  id = p_contract_id);

    l_vendor_program		    VARCHAR2(240);
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN

    OPEN  vendor_program_csr(p_contract_id);
    FETCH vendor_program_csr INTO l_vendor_program;
    CLOSE vendor_program_csr;

    x_vendor_program := l_vendor_program;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_vendor_program;

  ---------------------------------------------------------------------------
  -- FUNCTION get_bill_to_address
  ---------------------------------------------------------------------------
  FUNCTION get_bill_to_address(
     p_contract_id		IN NUMBER,
     x_bill_to_address_id     OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    -- Code segment for Customer Account/bill to address
    -- as mentioned in OKC Rules Migration HLD
    CURSOR BillToAddress_csr(p_contract_id NUMBER) IS
      SELECT bill_to_site_use_id
      FROM   okc_k_headers_b
      WHERE  id =p_contract_id;

    l_bill_to_address_id    VARCHAR2(240);
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN

    OPEN  BillToAddress_csr(p_contract_id);
    FETCH BillToAddress_csr INTO l_bill_to_address_id;
    CLOSE BillToAddress_csr;

    x_bill_to_address_id := l_bill_to_address_id;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_bill_to_address;

  ---------------------------------------------------------------------------
  -- FUNCTION get_private_label
  ---------------------------------------------------------------------------
  FUNCTION get_private_label(
     p_contract_id		IN NUMBER,
     x_private_label          OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_api_version           NUMBER := 1.0;
    l_init_msg_list         VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_party_tab             OKL_JTOT_EXTRACT.party_tab_type;
  BEGIN

    -- Procedure to call to get Private Label ID, nothing but
    -- a Role
    OKL_JTOT_EXTRACT.Get_Party (
          l_api_version,
          l_init_msg_list,
          l_return_status,
          l_msg_count,
          l_msg_data,
          p_contract_id,
          null,
          'PRIVATE_LABEL',
          'S',
          l_party_tab
          );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    IF l_party_tab.FIRST IS NOT NULL
    THEN --fetch from table only if some data is retrieved
      FOR i in 1..l_party_tab.LAST
      LOOP
        x_private_label := l_party_tab(i).id1;
      END LOOP;
    ELSE
      x_private_label := NULL;
    END IF;

    RETURN l_return_status;
    EXCEPTION
      WHEN okl_api.G_EXCEPTION_ERROR THEN
        OKC_API.SET_MESSAGE( p_app_name   => G_APP_NAME
                          ,p_msg_name     => G_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

      WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        OKC_API.SET_MESSAGE( p_app_name   => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE( p_app_name   => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_private_label;

  ---------------------------------------------------------------------------
  -- FUNCTION get_non_notify_flag
  ---------------------------------------------------------------------------
  FUNCTION get_non_notify_flag(
     p_contract_id		IN NUMBER,
     x_non_notify_flag        OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_non_notify_flag 	    VARCHAR2(200);
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_id1            Varchar2(40);
    l_id2            Varchar2(200);

    -- Following cursor introduced for bug: 3838403
    CURSOR get_non_notify_flag (p_contract_id IN NUMBER) IS
      SELECT RULE_INFORMATION1
      FROM   okc_rule_groups_b rgp, okc_rules_b rul
      WHERE  rgp.id = rul.rgp_id
      AND    rgp.dnz_chr_id = p_contract_id
      AND    rgp.rgd_code = 'LANNTF'
      AND    rul.rule_information_category = 'LANNTF';

  BEGIN

  /*  l_return_status := get_rule_value(
                           p_contract_id     => p_contract_id
                          ,p_rule_group_code => 'LANNTF'
                          ,p_rule_code       => 'LANNTF'
                          ,p_rule_name       => 'Non-Notification'
                          ,x_id1             => l_id1
                          ,x_id2             => l_id2
                          ,x_value           => l_non_notify_flag);
*/

    OPEN get_non_notify_flag (p_contract_id);
    FETCH get_non_notify_flag INTO l_non_notify_flag;
    CLOSE get_non_notify_flag;

    x_non_notify_flag := l_non_notify_flag;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_non_notify_flag;

  ---------------------------------------------------------------------------
  -- FUNCTION get_currency
  ---------------------------------------------------------------------------
  FUNCTION get_currency(
     p_contract_id	IN NUMBER,
     x_currency		OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR currency_csr(p_contract_id NUMBER) IS
      SELECT currency_code
      FROM   okc_k_headers_b
      WHERE  id = p_contract_id;

    l_currency			    VARCHAR2(240);
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN

    OPEN  currency_csr(p_contract_id);
    FETCH currency_csr INTO l_currency;
    CLOSE currency_csr;

    x_currency := l_currency;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_currency;

  ---------------------------------------------------------------------------
  -- FUNCTION get_syndicate_flag
  ---------------------------------------------------------------------------
  FUNCTION get_syndicate_flag(
     p_contract_id	IN NUMBER,
     x_syndicate_flag	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    -- A complex query to find out if a contract has syndication
    CURSOR syndicate_flag_csr(p_contract_id NUMBER) IS
      SELECT 'Y'  FROM okc_k_headers_b chr
      WHERE id = p_contract_id
      AND EXISTS
          (
           SELECT 'x' FROM okc_k_items cim
           WHERE  cim.object1_id1 = to_char(chr.id)
           AND    EXISTS
                  (
                   SELECT 'x' FROM okc_k_lines_b cle, okc_line_styles_b lse
                   WHERE  cle.lse_id = lse.id
                   AND    lse.lty_code = 'SHARED'
                   AND    cle.id = cim.cle_id
                  )
           AND    EXISTS
                  (
                   SELECT 'x' FROM okc_k_headers_b chr2
                   WHERE  chr2.id = cim.dnz_chr_id
                   AND    chr2.scs_code = 'SYNDICATION'
                   AND    chr2.sts_code not in ('TERMINATED','ABANDONED')
                  )
          )
      AND chr.scs_code in ('LEASE','LOAN');

    l_syndicate_flag	VARCHAR2(1) := 'N';
    l_api_version       NUMBER;
    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

  BEGIN

    OPEN  syndicate_flag_csr(p_contract_id);
    FETCH syndicate_flag_csr INTO l_syndicate_flag;
    CLOSE syndicate_flag_csr;

    x_syndicate_flag := l_syndicate_flag;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_syndicate_flag;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_ORG_ID
  ---------------------------------------------------------------------------
  FUNCTION GET_ORG_ID(
     p_contract_id	IN NUMBER,
     x_org_id		OUT NOCOPY NUMBER )
  RETURN VARCHAR2 AS

  -- get org_id for contract
    CURSOR get_org_id_csr (p_contract_id IN VARCHAR2) IS
      SELECT authoring_org_id
      FROM   okc_k_headers_b
      WHERE  id = p_contract_id;

    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN

    OPEN get_org_id_csr(p_contract_id);
    FETCH get_org_id_csr INTO x_org_id;
    CLOSE get_org_id_csr;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END GET_ORG_ID;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_REMAINING_PAYMENTS
  ---------------------------------------------------------------------------
  FUNCTION get_remaining_payments(
     p_contract_id		IN NUMBER,
     x_remaining_payments	OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

  -- Get the remaining number of payments for a contract



  CURSOR remaining_payments_csr(p_contract_id IN NUMBER) IS
    SELECT  count(stm.khr_id) remaining_payments
    FROM    okl_strm_elements	ste
           ,okl_streams		stm
           ,okl_strm_type_b	sty
           ,okc_k_headers_b	khr
    WHERE  stm.id			= ste.stm_id
    AND    ste.date_billed	IS NULL
    AND    stm.active_yn	= 'Y'
    AND    stm.say_code		= 'CURR'
    AND    sty.id			= stm.sty_id
    AND    sty.billable_yn	= 'Y'
    AND    khr.id			= stm.khr_id
    AND    khr.scs_code		IN ('LEASE', 'LOAN')
    AND    khr.id	            = p_contract_id;

    l_remaining_payments NUMBER := 0;
    l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    OPEN  remaining_payments_csr(p_contract_id);
    FETCH remaining_payments_csr INTO l_remaining_payments;
    CLOSE remaining_payments_csr;

    x_remaining_payments := l_remaining_payments;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_remaining_payments;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_RULE_VALUE (accepts prompt as a parameter)
  ---------------------------------------------------------------------------
  FUNCTION get_rule_value(
      p_contract_id	IN NUMBER
     ,p_rule_group_code IN VARCHAR2
     ,p_rule_code		IN VARCHAR2
     ,p_rule_name		IN VARCHAR2
     ,x_id1             OUT NOCOPY VARCHAR2
     ,x_id2             OUT NOCOPY VARCHAR2
     ,x_value           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_return_status  Varchar2(1);
    l_msg_count      Number;
    l_msg_data       varchar2(2000);
    l_cle_id         Number;
    l_id1            Varchar2(40);
    l_id2            Varchar2(200);
    l_description    Varchar2(2000);
    l_status         Varchar2(1);
    l_start_date     date;
    l_end_date       date;
    l_org_id         Number;
    l_inv_org_id     Number;
    l_book_type_code Varchar2(15);
    l_select         Varchar2(2000);
    l_msg_index_out  Number;

  BEGIN

    -- Procedure call to get Rule Value
    OKL_RULE_APIS_PUB.Get_rule_Segment_Value
               ( p_api_version     => 1.0
                ,p_init_msg_list   => OKL_API.G_FALSE
                ,x_return_status   => l_return_status
                ,x_msg_count       => l_msg_count
                ,x_msg_data        => l_msg_data
                ,p_chr_id          => p_contract_id
                ,p_cle_id          => null
                ,p_rgd_code        => p_rule_group_code
                ,p_rdf_code        => p_rule_code
                ,p_rdf_name        => p_rule_name
                ,x_id1             => x_id1
                ,x_id2             => x_id2
                ,x_name            => x_value
                ,x_description     => l_description
                ,x_status          => l_status
                ,x_start_date      => l_start_date
                ,x_end_date        => l_end_date
                ,x_org_id          => l_org_id
                ,x_inv_org_id      => l_inv_org_id
                ,x_book_type_code  => l_book_type_code
                ,x_select          => l_select );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_rule_value;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_RULE_VALUE (accepts segment number as a parameter)
  ---------------------------------------------------------------------------
  FUNCTION get_rule_value(
      p_contract_id	IN NUMBER
     ,p_rule_group_code IN VARCHAR2
     ,p_rule_code		IN VARCHAR2
     ,p_segment_number  IN  NUMBER
     ,x_id1             OUT NOCOPY VARCHAR2
     ,x_id2             OUT NOCOPY VARCHAR2
     ,x_value           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_return_status  Varchar2(1);
    l_msg_count      Number;
    l_msg_data       varchar2(2000);
    l_cle_id         Number;
    l_id1            Varchar2(40);
    l_id2            Varchar2(200);
    l_description    Varchar2(2000);
    l_status         Varchar2(1);
    l_start_date     date;
    l_end_date       date;
    l_org_id         Number;
    l_inv_org_id     Number;
    l_book_type_code Varchar2(15);
    l_select         Varchar2(2000);
    l_msg_index_out  Number;

  BEGIN

    -- Procedure call to get Rule Value
    OKL_RULE_APIS_PUB.Get_rule_Segment_Value
               ( p_api_version     => 1.0
                ,p_init_msg_list   => OKL_API.G_FALSE
                ,x_return_status   => l_return_status
                ,x_msg_count       => l_msg_count
                ,x_msg_data        => l_msg_data
                ,p_chr_id          => p_contract_id
                ,p_cle_id          => null
                ,p_rgd_code        => p_rule_group_code
                ,p_rdf_code        => p_rule_code
                ,p_segment_number  => p_segment_number
                ,x_id1             => x_id1
                ,x_id2             => x_id2
                ,x_name            => x_value
                ,x_description     => l_description
                ,x_status          => l_status
                ,x_start_date      => l_start_date
                ,x_end_date        => l_end_date
                ,x_org_id          => l_org_id
                ,x_inv_org_id      => l_inv_org_id
                ,x_book_type_code  => l_book_type_code
                ,x_select          => l_select );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_rule_value;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_DAYS_PAST_DUE
  ---------------------------------------------------------------------------
  FUNCTION get_days_past_due(
     p_contract_id		IN NUMBER,
     x_days_past_due	     	OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS


-- ASHIM CHANGE - START



  -- Get days past due for a contract for invoices
  /*CURSOR days_past_due_csr(p_contract_id IN NUMBER) IS
    SELECT min(aps.due_date)
    FROM   okl_cnsld_ar_strms_b ocas
           ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class = 'INV'
    AND    aps.due_date < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0; */

  CURSOR days_past_due_csr(p_contract_id IN NUMBER) IS
    SELECT min(aps.due_date)
    FROM   okl_bpd_tld_ar_lines_v ocas
           ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class = 'INV'
    AND    aps.due_date < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0;

-- ASHIM CHANGE - END


    l_due_date   	    DATE;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    OPEN  days_past_due_csr(p_contract_id);
    FETCH days_past_due_csr INTO l_due_date;
    CLOSE days_past_due_csr;

    IF l_due_date IS NULL
    THEN
      l_due_date := TRUNC(SYSDATE);
    END IF;

    x_days_past_due := TRUNC(SYSDATE) - l_due_date;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_days_past_due;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_AMOUNT_PAST_DUE
  ---------------------------------------------------------------------------
  FUNCTION get_amount_past_due(
     p_contract_id		IN NUMBER,
     x_amount_past_due	     	OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS


-- ASHIM CHANGE - START


  -- Get AMount past due for a contract
  /*CURSOR amount_past_due_csr(p_contract_id IN NUMBER, p_sty_id IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
           ,ar_payment_schedules aps
           ,okl_strm_type_v strm
    WHERE  ocas.khr_id = p_contract_id
    AND ocas.receivables_invoice_id = aps.customer_trx_id
    AND aps.class ='INV'
    AND aps.due_date < sysdate
    and strm.id=ocas.sty_id
    and strm.id <> p_sty_id; */
    --and strm.name <>'CURE';

  CURSOR amount_past_due_csr(p_contract_id IN NUMBER, p_sty_id IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
           ,ar_payment_schedules aps
           ,okl_strm_type_v strm
    WHERE  ocas.khr_id = p_contract_id
    AND ocas.customer_trx_id = aps.customer_trx_id
    AND aps.class ='INV'
    AND aps.due_date < sysdate
    and strm.id=ocas.sty_id
    and strm.id <> p_sty_id;
    --and strm.name <>'CURE';


-- ASHIM CHANGE - END


    l_amount_past_due   	NUMBER;
    l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_primary_sty_id    NUMBER;

  BEGIN

    OKL_STREAMS_UTIL.get_primary_stream_type(
        			p_khr_id => p_contract_id,
        			p_primary_sty_purpose => 'CURE',
        			x_return_status => l_return_status,
        			x_primary_sty_id => x_primary_sty_id
        			);

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS or x_primary_sty_id is null)  THEN

	OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> G_REQUIRED_VALUE,
				p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Sty Id');
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN  amount_past_due_csr(p_contract_id, x_primary_sty_id);
    FETCH amount_past_due_csr INTO l_amount_past_due;
    CLOSE amount_past_due_csr;

    x_amount_past_due := l_amount_past_due;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_amount_past_due;

  ---------------------------------------------------------------------------
  -- FUNCTION get_Next due amount, dates
  ---------------------------------------------------------------------------
  FUNCTION get_next_due(
     p_contract_id     IN  NUMBER,
     x_next_due_amt    OUT NOCOPY NUMBER,
     x_next_due_date   OUT NOCOPY DATE )
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);


-- ASHIM CHANGE - START


   -- Get Next due date and amount
   /*CURSOR next_due_csr IS
         SELECT amt,due_date
         FROM (SELECT  (SYSDATE-due_date) days
                      ,aps.due_date due_date
                      ,SUM(aps.amount_due_original) amt
                      ,lsm.khr_id khr_id
               FROM    OKL_CNSLD_AR_STRMS_B LSM
                      ,AR_PAYMENT_SCHEDULES APS
               WHERE  lsm.receivables_invoice_id = aps.customer_trx_id
               GROUP  BY khr_id, due_date ) amount_date
         WHERE amount_date.days=(SELECT MIN(next_due.days)
                                 FROM   (SELECT  (SYSDATE-due_date) days
                                                ,aps.due_date due_date
                                                ,SUM(aps.amount_due_original) amt
                                                ,lsm.khr_id khr_id
                                         FROM   OKL_CNSLD_AR_STRMS_B LSM
                                                ,AR_PAYMENT_SCHEDULES APS
                                         WHERE lsm.receivables_invoice_id = aps.customer_trx_id
                                         GROUP BY khr_id, due_date) next_due
                		         WHERE khr_id = p_contract_id
                                 AND   SIGN(next_due.days) = -1); */
/*
   CURSOR next_due_csr IS
         SELECT amt,due_date
         FROM (SELECT  (SYSDATE-due_date) days
                      ,aps.due_date due_date
                      ,SUM(aps.amount_due_original) amt
                      ,lsm.khr_id khr_id
               FROM    OKL_BPD_TLD_AR_LINES_V LSM
                      ,AR_PAYMENT_SCHEDULES APS
               WHERE  lsm.customer_trx_id = aps.customer_trx_id
               GROUP  BY khr_id, due_date ) amount_date
         WHERE amount_date.days=(SELECT MIN(next_due.days)
                                 FROM   (SELECT  (SYSDATE-due_date) days
                                                ,aps.due_date due_date
                                                ,SUM(aps.amount_due_original) amt
                                                ,lsm.khr_id khr_id
                                         FROM   OKL_BPD_TLD_AR_LINES_V LSM
                                                ,AR_PAYMENT_SCHEDULES APS
                                         WHERE lsm.customer_trx_id = aps.customer_trx_id
                                         GROUP BY khr_id, due_date) next_due
                		         WHERE khr_id = p_contract_id
                                 AND   SIGN(next_due.days) = -1); */

-- ASHIM CHANGE - END

--dkagrawa changed the cursor as follows for bug#6324572
          CURSOR next_due_csr IS
          SELECT  SUM(aps.amount_due_original) amt,
               aps.due_date due_date
               FROM    okl_bpd_tld_ar_lines_v LSM
                      ,AR_PAYMENT_SCHEDULES APS
               WHERE  lsm.customer_trx_id = aps.customer_trx_id
               AND    lsm.khr_id = p_contract_id
               AND due_date>SYSDATE
               GROUP  BY aps.due_date  , lsm.khr_id
               ORDER BY  (due_date-SYSDATE) desc ;

   BEGIN
    OPEN next_due_csr;
    FETCH next_due_csr into  x_next_due_amt,x_next_due_date;
    CLOSE next_due_csr;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END;

  ---------------------------------------------------------------------------
  -- FUNCTION get last due amount,dates
  ---------------------------------------------------------------------------
  FUNCTION get_last_due(
     p_contract_id     IN  NUMBER,
     x_last_due_amt    OUT NOCOPY NUMBER,
     x_last_due_date   OUT NOCOPY DATE )
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);


-- ASHIM CHANGE - START


    -- Get last due amount and date
    /*CURSOR last_due_csr IS
         SELECT amt,due_date
         FROM (SELECT  (SYSDATE-due_date) days
                      ,aps.due_date due_date
                      ,SUM(aps.amount_due_original) amt
                      ,lsm.khr_id khr_id
               FROM    OKL_CNSLD_AR_STRMS_B LSM
                      ,AR_PAYMENT_SCHEDULES APS
               WHERE  lsm.receivables_invoice_id = aps.customer_trx_id
               GROUP  BY khr_id, due_date ) amount_date
         WHERE amount_date.days=(SELECT MIN(next_due.days)
                                 FROM   (SELECT  (SYSDATE-due_date) days
                                                ,aps.due_date due_date
                                                ,SUM(aps.amount_due_original) amt
                                                ,lsm.khr_id khr_id
                                         FROM   OKL_CNSLD_AR_STRMS_B LSM
                                                ,AR_PAYMENT_SCHEDULES APS
                                         WHERE lsm.receivables_invoice_id = aps.customer_trx_id
                                         GROUP BY khr_id, due_date) next_due
                		         WHERE khr_id = p_contract_id
                                 AND   SIGN(next_due.days) = 1); */

  /*  CURSOR last_due_csr IS
         SELECT amt,due_date
         FROM (SELECT  (SYSDATE-due_date) days
                      ,aps.due_date due_date
                      ,SUM(aps.amount_due_original) amt
                      ,lsm.khr_id khr_id
               FROM    okl_bpd_tld_ar_lines_v LSM
                      ,AR_PAYMENT_SCHEDULES APS
               WHERE  lsm.customer_trx_id = aps.customer_trx_id
               GROUP  BY khr_id, due_date ) amount_date
         WHERE amount_date.days=(SELECT MIN(next_due.days)
                                 FROM   (SELECT  (SYSDATE-due_date) days
                                                ,aps.due_date due_date
                                                ,SUM(aps.amount_due_original) amt
                                                ,lsm.khr_id khr_id
                                         FROM   okl_bpd_tld_ar_lines_v LSM
                                                ,AR_PAYMENT_SCHEDULES APS
                                         WHERE lsm.customer_trx_id = aps.customer_trx_id
                                         GROUP BY khr_id, due_date) next_due
                		         WHERE khr_id = p_contract_id
                                 AND   SIGN(next_due.days) = 1); */

-- ASHIM CHANGE - END
--dkagrawa changed the cursor as follows for bug#6324572
          CURSOR last_due_csr IS
          SELECT  SUM(aps.amount_due_original) amt,
               aps.due_date due_date
               FROM    okl_bpd_tld_ar_lines_v LSM
                      ,AR_PAYMENT_SCHEDULES APS
               WHERE  lsm.customer_trx_id = aps.customer_trx_id
               AND    lsm.khr_id = p_contract_id
               AND due_date<=SYSDATE
               GROUP  BY aps.due_date  , lsm.khr_id
               ORDER BY  (SYSDATE-due_date) asc;

  BEGIN
    OPEN last_due_csr;
    FETCH last_due_csr into  x_last_due_amt,x_last_due_date;
    CLOSE last_due_csr;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION Total asset cost for contract
  ---------------------------------------------------------------------------
  FUNCTION get_total_asset_cost(
     p_contract_id     IN  NUMBER,
     x_asset_cost     OUT NOCOPY NUMBER )
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    -- Get total Asset Cost
    CURSOR asset_cost_csr IS
           SELECT SUM(fab.cost)
           FROM fa_additions_b faa,fa_books fab,okc_k_lines_b cle,
   	            okc_k_headers_b chr,okc_line_styles_b lse,
  	            okc_k_items  cim
           WHERE faa.asset_id = fab.asset_id
             AND cim.object1_id2 = '#'
             AND cim.object1_id1 = faa.asset_id
             AND cim.jtot_object1_code = 'OKX_ASSET'
             AND cle.id = cim.cle_id
             AND lse.lty_code = 'FIXED_ASSET'
             AND cle.lse_id = lse.id
             AND cle.dnz_chr_id = chr.id
             AND chr.id = p_contract_id
           GROUP BY chr.id ;
  BEGIN
    OPEN asset_cost_csr;
    FETCH asset_cost_csr into  x_asset_cost;
    CLOSE asset_cost_csr;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION Total out standing receivables for contract
  ---------------------------------------------------------------------------
  FUNCTION get_outstanding_rcvble (
     p_contract_id     IN  NUMBER,
     x_rcvble_amt     OUT NOCOPY NUMBER)
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

   -- Get amount outstanding
    /*CURSOR outstanding_rcvble_csr IS
      SELECT SUM(NVL(amount_due_remaining, 0))
      FROM   okl_bpd_leasing_payment_trx_v
      WHERE  contract_id = p_contract_id;
     */


-- ASHIM CHANGE - START


     /*  CURSOR outstanding_rcvble_csr(p_sty_id number) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
           ,ar_payment_schedules aps
           ,okl_strm_type_v strm
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class ='INV'
    --AND    aps.due_date < sysdate
    and strm.id=ocas.sty_id
    and strm.id <> p_sty_id;
    --and strm.name <>'CURE'; */

       CURSOR outstanding_rcvble_csr(p_sty_id number) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
           ,ar_payment_schedules aps
           ,okl_strm_type_v strm
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class ='INV'
    --AND    aps.due_date < sysdate
    and strm.id=ocas.sty_id
    and strm.id <> p_sty_id;
    --and strm.name <>'CURE';


-- ASHIM CHANGE - END



    x_primary_sty_id    NUMBER;

  BEGIN

      OKL_STREAMS_UTIL.get_primary_stream_type(
          			p_khr_id => p_contract_id,
          			p_primary_sty_purpose => 'CURE',
          			x_return_status => l_return_status,
          			x_primary_sty_id => x_primary_sty_id
          			);

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS or x_primary_sty_id is null)  THEN

	OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> G_REQUIRED_VALUE,
				p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Sty Id');
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN outstanding_rcvble_csr(x_primary_sty_id);
    FETCH outstanding_rcvble_csr into  x_rcvble_amt;
    CLOSE outstanding_rcvble_csr;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION Term of contract in months,start date ,end date
  ---------------------------------------------------------------------------
  FUNCTION get_contract_term(
     p_contract_id     IN  NUMBER,
     x_start_date      OUT NOCOPY DATE,
     x_end_date        OUT NOCOPY DATE,
     x_term_duration   OUT NOCOPY NUMBER)
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

   -- Get contract term duration and dates
   CURSOR contract_dates_csr IS
          SELECT khr.start_date,khr.end_date,okhr.term_duration
          FROM OKL_K_HEADERS okhr ,okc_k_headers_v khr
          WHERE okhr.id = khr.id
            AND khr.id = p_contract_id;
  BEGIN
    OPEN contract_dates_csr;
    FETCH contract_dates_csr into  x_start_date,x_end_date,x_term_duration;
    CLOSE contract_dates_csr ;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION Net investment for contract
  ---------------------------------------------------------------------------
  FUNCTION get_net_investment (
     p_contract_id     IN  NUMBER,
     x_net_investment  OUT NOCOPY NUMBER)
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_rent       NUMBER;
    l_return_residual   NUMBER;
    l_return_unearned   NUMBER;

  -- get residual value
  CURSOR residual_csr IS
         SELECT NVL(SUM(cs.amount),0)
         FROM okl_streams_v asv,okl_strm_type_v bs,okl_strm_elements_v cs
         WHERE cs.stm_id = asv.id AND bs.id = asv.sty_id
         AND bs.name = 'Residual Value'
         AND cs.stream_element_date >= SYSDATE
         AND asv.khr_id =  p_contract_id;

  -- get rent value
  CURSOR rent_csr IS
         SELECT NVL(SUM(cs.amount),0)
         FROM okl_streams_v asv,okl_strm_type_v bs,okl_strm_elements_v cs
         WHERE cs.stm_id = asv.id AND bs.id = asv.sty_id
         AND bs.name = 'Rent'
         AND cs.stream_element_date >= SYSDATE
         AND asv.khr_id =  p_contract_id ;
  -- get unearned amount
  CURSOR unearned_csr IS
         SELECT NVL(SUM(cs.amount),0)
         FROM okl_streams_v asv,okl_strm_type_v bs,okl_strm_elements_v cs
         WHERE cs.stm_id = asv.id AND bs.id = asv.sty_id
         AND bs.name = 'Unearned Income'
         AND cs.stream_element_date >= SYSDATE
         AND asv.khr_id =  p_contract_id  	 ;
  BEGIN
    OPEN residual_csr;
    FETCH residual_csr into  l_return_residual;
    CLOSE residual_csr ;
    OPEN rent_csr;
    FETCH rent_csr into  l_return_rent;
    CLOSE rent_csr;
    OPEN unearned_csr;
    FETCH unearned_csr into  l_return_unearned;
    CLOSE unearned_csr;
    x_net_investment := l_return_rent + l_return_residual - l_return_unearned;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION Advance rent,Security deposit,interest type for contract
  ---------------------------------------------------------------------------
  FUNCTIOn get_rent_security_interest(
     p_contract_id      IN  NUMBER,
     x_advance_rent     OUT NOCOPY NUMBER,
     x_security_deposit OUT NOCOPY NUMBER,
     x_interest_type    OUT NOCOPY NUMBER)
  RETURN VARCHAR2 IS
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  -- get advanced rent
  CURSOR advance_rent_csr IS
      SELECT SUM(nvl(orv1.rule_information6,0))
      FROM okc_rules_v orv1, okc_rule_groups_b org1
      WHERE  org1.dnz_chr_id = p_contract_id
        AND org1.id = orv1.rgp_id
      AND orv1.rule_information_category = 'SLL'
      AND EXISTS
       ( SELECT 1 FROM okc_k_headers_v okhdr,okc_rules_v  orv,OKL_STRMTYP_SOURCE_V stm
            WHERE okhdr.id = org1.dnz_chr_id AND org1.rgd_code = 'LAEVEL'
           AND org1.id = orv.rgp_id  AND orv.rule_information_category ='SLH'
           AND jtot_object1_code ='OKL_STRMTYP' AND object1_id1 = stm.id1
           AND object1_id2 = stm.id2 AND stm.name ='RENT');

  -- get security deposit
  CURSOR security_deposit_csr IS
      SELECT SUM(nvl(orv1.rule_information6,0))
      FROM okc_rules_v orv1, okc_rule_groups_b org1
      WHERE  org1.dnz_chr_id = p_contract_id
        AND org1.id = orv1.rgp_id
      AND orv1.rule_information_category = 'SLL'
      AND EXISTS
       ( SELECT 1 FROM okc_k_headers_v okhdr,okc_rules_v  orv,OKL_STRMTYP_SOURCE_V stm
            WHERE okhdr.id = org1.dnz_chr_id AND org1.rgd_code = 'LAEVEL'
           AND org1.id = orv.rgp_id  AND orv.rule_information_category ='SLH'
           AND jtot_object1_code ='OKL_STRMTYP' AND object1_id1 = stm.id1
           AND object1_id2 = stm.id2 AND stm.name ='SECURITY DEPOSIT');

  -- get interest type
  CURSOR Interest_type_csr IS
      SELECT SUM(nvl(orv1.rule_information6,0))
      FROM okc_rules_v orv1, okc_rule_groups_b org1
      WHERE  org1.dnz_chr_id = p_contract_id
        AND org1.id = orv1.rgp_id
      AND orv1.rule_information_category = 'SLL'
      AND EXISTS
       ( SELECT 1 FROM okc_k_headers_v okhdr,okc_rules_v  orv,OKL_STRMTYP_SOURCE_V stm
            WHERE okhdr.id = org1.dnz_chr_id AND org1.rgd_code = 'LAEVEL'
           AND org1.id = orv.rgp_id  AND orv.rule_information_category ='SLH'
           AND jtot_object1_code ='OKL_STRMTYP' AND object1_id1 = stm.id1
           AND object1_id2 = stm.id2 AND stm.name ='SECURITY DEPOSIT');

  BEGIN
    OPEN advance_rent_csr;
    FETCH advance_rent_csr into x_advance_rent;
    CLOSE advance_rent_csr ;
    OPEN security_deposit_csr;
    FETCH security_deposit_csr into x_security_deposit;
    CLOSE security_deposit_csr;
    OPEN Interest_type_csr;
    FETCH Interest_type_csr into x_advance_rent;
    CLOSE Interest_type_csr;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION get_insurance_lapse
  ---------------------------------------------------------------------------
  FUNCTION get_insurance_lapse(
     p_contract_id		IN NUMBER,
     x_insurance_lapse_yn	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    -- Get If insurance has lapsed for a contract
    CURSOR insurance_date_to_csr(p_contract_id NUMBER) IS
      SELECT 'N'
      FROM   OKL_INS_POLICIES_B  IPYB
      WHERE  IPYB.KHR_ID = p_contract_id
      AND    IPYB.IPY_TYPE <> 'OPTIONAL_POLICY'
      AND    IPYB.QUOTE_YN = 'N'
      AND    IPYB.ISS_CODE = 'ACTIVE'
      AND    SYSDATE  BETWEEN IPYB.DATE_FROM AND IPYB.DATE_TO;

    l_insurance_lapse_yn VARCHAR2(1) := 'Y';
    l_api_version      NUMBER;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

  BEGIN

    OPEN  insurance_date_to_csr(p_contract_id);
    FETCH insurance_date_to_csr INTO l_insurance_lapse_yn;
    CLOSE insurance_date_to_csr;

    x_insurance_lapse_yn := l_insurance_lapse_yn;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_insurance_lapse;


  ---------------------------------------------------------------------------
  -- FUNCTION get_unrefunded_cures
  ---------------------------------------------------------------------------
/*  FUNCTION get_unrefunded_cures(
     p_contract_id		IN NUMBER,
     x_unrefunded_cures	      OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

    -- Get unrefunded cures for a contract
    CURSOR unrefunded_cures_csr(p_contract_id NUMBER) IS
      SELECT SUM(amount)
      FROM   iex_cure_payment_lines
      WHERE  chr_id = p_contract_id
      AND    status = 'CURES_IN_POSSESSION';

    l_unrefunded_cures NUMBER := 0;
    l_api_version      NUMBER;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

  BEGIN

    --OPEN  unrefunded_cures_csr(p_contract_id);
    --FETCH unrefunded_cures_csr INTO l_unrefunded_cures;
    --CLOSE unrefunded_cures_csr;

    x_unrefunded_cures := l_unrefunded_cures;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_unrefunded_cures;*/

  ---------------------------------------------------------------------------
  -- FUNCTION get_fair_market_value
  ---------------------------------------------------------------------------
  FUNCTION get_fair_market_value(
     p_contract_id	   IN NUMBER,
     x_fair_market_value   OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

    l_fair_market_value NUMBER;
    l_api_version       NUMBER;
    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

  BEGIN
    l_fair_market_value := 0;

    x_fair_market_value := l_fair_market_value;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_fair_market_value;

  ---------------------------------------------------------------------------
  -- FUNCTION get_net_book_value
  ---------------------------------------------------------------------------
  FUNCTION get_net_book_value(
     p_contract_id	IN NUMBER,
     x_net_book_value   OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

    l_net_book_value  NUMBER :=0;
    l_api_version     NUMBER;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);


    CURSOR deal_type(p_contract_id IN NUMBER) IS
      SELECT khr.deal_type
      FROM okl_k_headers_v khr ,fnd_lookups fnd
      WHERE fnd.lookup_type = 'OKL_BOOK_CLASS'
      AND fnd.lookup_code = khr.deal_type
      AND id = p_contract_id;

   l_deal_type   VARCHAR2(30);
   l_formula_name VARCHAR2(100);

  BEGIN

         OPEN deal_type(p_contract_id);
         FETCH deal_type INTO l_deal_type;
         CLOSE deal_type;

         IF l_deal_type IN ('LEASEDF','LEASEST') THEN
            l_formula_name := 'CONTRACT_NET_INVESTMENT_DF';
         ELSIF l_deal_type IN ('LOAN','LOAN-REVOLVING') THEN
            l_formula_name := 'CONTRACT_NET_INVESTMENT_LOAN';
         ELSIF l_deal_type IN ('LEASEOP') THEN
           l_formula_name := 'CONTRACT_NET_INVESTMENT_OP';
         END IF;

         Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1
                                         ,p_init_msg_list       =>'T'
                                        ,x_return_status        =>l_return_status
                                        ,x_msg_count            =>l_msg_count
                                        ,x_msg_data             =>l_msg_data
                                        ,p_formula_name         =>l_formula_name
                                        ,p_contract_id          =>p_contract_id
                                        ,x_value               =>l_net_book_value
                                     );



    x_net_book_value :=nvl(l_net_book_value,0);
    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
    CLOSE deal_type;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      x_net_book_value :=0;
      RETURN(l_return_status);

  END get_net_book_value;

  ---------------------------------------------------------------------------
  -- FUNCTION get_interest
  ---------------------------------------------------------------------------
  FUNCTION get_interest(
     p_contract_id	IN NUMBER,
     x_interest   	OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

    l_interest  	    NUMBER;
    l_api_version     NUMBER;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);

  BEGIN
    /* Obtain the interest using Formula */

    l_interest := 1;

    x_interest := l_interest;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_interest;

  ---------------------------------------------------------------------------
  -- FUNCTION get_immediate_purchase_yn
  ---------------------------------------------------------------------------
  -- Get Rule value for 'Request Immediate Repurchase' Retruns Y/N
  FUNCTION get_immediate_repurchase_yn(
     p_contract_id	IN NUMBER,
     x_value   	      OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS

    l_value  	    VARCHAR2(1);
    l_api_version     NUMBER;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);

  BEGIN
    -- implement the function once rules are seeded

    l_value := 'N';

    x_value := l_value;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_immediate_repurchase_yn;

  ---------------------------------------------------------------------------
  -- FUNCTION get_asset_value
  ---------------------------------------------------------------------------
  FUNCTION get_asset_value(
          p_asset_id              IN NUMBER,
          p_asset_valuation_type  IN VARCHAR2
                          )
  RETURN NUMBER
  IS

    l_asset_value     NUMBER;
    l_api_version     NUMBER;

  BEGIN
    /* Obtain the asset Value, perhaps a formula */

    l_asset_value := 0;

    IF (p_asset_valuation_type = 'FMV') THEN
      NULL;
    END IF;

    IF (p_asset_valuation_type = 'FLV') THEN
      NULL;
    END IF;

    IF (p_asset_valuation_type = 'OLV') THEN
      NULL;
    END IF;

    RETURN l_asset_value;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      RETURN(-1);

  END get_asset_value;

  ---------------------------------------------------------------------------
  -- FUNCTION get_notice_of_assignment_yn
  ---------------------------------------------------------------------------
  -- Get Rule value for 'Notice of Assignment Needed' Returns Y/N
  FUNCTION get_notice_of_assignment_yn(
     p_contract_id	IN NUMBER,
     x_assignment_yn   	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS

    l_assignment_yn   VARCHAR2(1);
    l_api_version     NUMBER;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);

  BEGIN
    -- implement the function once rules are seeded

    l_assignment_yn := 'N';

    x_assignment_yn := l_assignment_yn;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_notice_of_assignment_yn;

END OKL_CONTRACT_INFO;

/

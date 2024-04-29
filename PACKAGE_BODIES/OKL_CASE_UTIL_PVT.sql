--------------------------------------------------------
--  DDL for Package Body OKL_CASE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASE_UTIL_PVT" AS
/* $Header: OKLRCUTB.pls 120.2 2006/07/07 10:08:15 adagur noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE CREATE_CASE
  ---------------------------------------------------------------------------
  PROCEDURE CREATE_CASE(
     p_api_version      IN NUMBER,
     p_init_msg_list    IN VARCHAR2,
     p_contract_id	IN NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                    CONSTANT VARCHAR2(30) := 'OKL_CASE_UTIL_PVT';
  l_return_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_currency                    iex_case_definitions.column_value%TYPE;
  l_customer                    iex_case_definitions.column_value%TYPE;
  l_vendor_program              iex_case_definitions.column_value%TYPE;
  l_bill_to_address_id          iex_case_definitions.column_value%TYPE;
  l_private_label               iex_case_definitions.column_value%TYPE;
  l_non_notify_flag             iex_case_definitions.column_value%TYPE;
  l_syndicate_flag              iex_case_definitions.column_value%TYPE;

  l_rule_group_code             VARCHAR2(30) := 'LACAN';
  l_rule_code                   VARCHAR2(30) := 'CAN';
  l_rule_name                   VARCHAR2(80) := 'Customer Account';
  l_segment_number              NUMBER := 16;
  l_id2                         VARCHAR2(200);
  l_value                       VARCHAR2(200);
  l_customer_account            iex_case_definitions.column_value%TYPE;

  l_case_definition_tbl 	  IEX_CASE_UTL_PUB.CASE_DEFINITION_TBL_TYPE;
  l_cas_rec 			  IEX_CASE_UTL_PUB.CAS_REC_TYPE;
  l_case_object_id 		  iex_case_objects.case_object_id%TYPE;
  l_cas_id                      iex_cases_all_b.cas_id%TYPE;
  l_case_number                 iex_cases_all_b.case_number%TYPE;
  l_case_comments               iex_cases_tl.comments%TYPE;

  l_count                       NUMBER := 1;
  l_reassign_case               BOOLEAN := FALSE;

  -- Code segment for Customer Account/bill to address
  -- as mentioned in OKC Rules Migration HLD
  -- Start

  CURSOR cust_acct_csr (p_contract_id IN NUMBER) IS
    SELECT cust_acct_id
    FROM   okc_k_headers_b
    WHERE  id = p_contract_id;

  CURSOR bill_to_csr (p_contract_id IN NUMBER) IS
    SELECT bill_to_site_use_id
    FROM   okc_k_headers_b
    WHERE  id = p_contract_id;


  -- Code segment for Customer Account/bill to address
  -- as mentioned in OKC Rules Migration HLD
  -- End



  BEGIN

    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_CASE_UTIL',
                                              x_return_status);

    /*    Processing Starts     */
    -- get customer/party ID
    l_return_status := OKL_CONTRACT_INFO.get_customer(p_contract_id, l_customer);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get vendor program
    l_return_status := OKL_CONTRACT_INFO.get_vendor_program(p_contract_id, l_vendor_program);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get bill to address
    /*l_return_status := OKL_CONTRACT_INFO.get_bill_to_address(p_contract_id,l_bill_to_address_id);*/
    /*IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;*/
    -- New code for bill to address
    OPEN bill_to_csr (p_contract_id);
    FETCH bill_to_csr INTO l_bill_to_address_id;
    CLOSE bill_to_csr;

    IF trunc(l_bill_to_address_id) IS NULL THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get private label
    l_return_status := OKL_CONTRACT_INFO.get_private_label(p_contract_id, l_private_label);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get non notification flag

    l_return_status := OKL_CONTRACT_INFO.get_non_notify_flag(p_contract_id, l_non_notify_flag);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get syndication flag
    l_return_status := OKL_CONTRACT_INFO.get_syndicate_flag(p_contract_id, l_syndicate_flag);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get currency
    l_return_status := OKL_CONTRACT_INFO.get_currency(p_contract_id, l_currency);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get customer account
    /*l_return_status := OKL_CONTRACT_INFO.get_rule_value(
                          p_contract_id      => p_contract_id
                         ,p_rule_group_code  => l_rule_group_code
                         ,p_rule_code        => l_rule_code
                         ,p_segment_number   => l_segment_number
                         ,x_id1              => l_customer_account
                         ,x_id2              => l_id2
                         ,x_value            => l_value);


    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF; */

    -- New code for customer account
    OPEN cust_acct_csr (p_contract_id);
    FETCH cust_acct_csr INTO l_customer_account;
    CLOSE cust_acct_csr;

    IF trunc(l_customer_account) IS NULL THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

   -- Populate the pl/sql table for case definition

   IF (l_customer_account IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'CUSTOMER_ACCOUNT';
     l_case_definition_tbl(l_count).column_value := l_customer_account;
     l_count := l_count + 1;
   END IF;

   IF (l_bill_to_address_id IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'BILL_TO_ADDRESS_ID';
     l_case_definition_tbl(l_count).column_value := l_bill_to_address_id;
     l_count := l_count + 1;
   END IF;

   IF (l_currency IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'CURRENCY_CODE';
     l_case_definition_tbl(l_count).column_value := l_currency;
     l_count := l_count + 1;
   END IF;

   IF (l_vendor_program IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'VENDOR_PROGRAM';
     l_case_definition_tbl(l_count).column_value := l_vendor_program;
     l_count := l_count + 1;
   END IF;

   IF (l_private_label IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'PRIVATE_LABEL';
     l_case_definition_tbl(l_count).column_value := l_private_label;
     l_count := l_count + 1;
   END IF;

   IF (l_syndicate_flag IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'SYNDICATED_FLAG';
     l_case_definition_tbl(l_count).column_value := l_syndicate_flag;
     l_count := l_count + 1;
   END IF;

   IF (l_non_notify_flag IS NOT NULL) THEN
     l_case_definition_tbl(l_count).column_name := 'NON_NOTIFICATION_FLAG';
     l_case_definition_tbl(l_count).column_value := l_non_notify_flag;
     l_count := l_count + 1;
   END IF;

   -- Check if it is a reassignment
  l_reassign_case  := IEX_CASE_UTL_PUB.checkContract(p_contract_id);

   IF ( l_reassign_case ) THEN
     IEX_CASE_UTL_PUB.reassignCaseObjects
       (P_Api_Version_Number     => 2.0,
        P_Init_Msg_List          => FND_API.G_FALSE,
        P_Commit                 => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        p_case_definition_tbl    => l_case_definition_tbl,
        p_cas_id                 => FND_API.G_MISS_NUM,
        p_case_number            => FND_API.G_MISS_CHAR,
        p_case_comments          => FND_API.G_MISS_CHAR,
        p_case_established_date  => SYSDATE,
        p_org_id                 => mo_global.get_current_org_id(),
        p_object_code            => 'CONTRACTS',
        p_party_id               => l_customer,
        P_object_id              => p_contract_id,
        p_cas_rec                => IEX_CASE_UTL_PUB.G_MISS_CAS_REC,
        x_case_object_id         => l_case_object_id,
        x_return_status          => l_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data);

   ELSE
     IEX_CASE_UTL_PUB.CreateCaseObjects
       (P_Api_Version_Number     => 2.0,
        P_Init_Msg_List          => FND_API.G_FALSE,
        P_Commit                 => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        p_case_definition_tbl    => l_case_definition_tbl,
        p_cas_id                 => FND_API.G_MISS_NUM,
        p_case_number            => FND_API.G_MISS_CHAR,
        p_case_comments          => FND_API.G_MISS_CHAR,
        p_case_established_date  => SYSDATE,
        p_org_id                 => mo_global.get_current_org_id(),
        p_object_code            => 'CONTRACTS',
        p_party_id               => l_customer,
        P_object_id              => p_contract_id,
        p_cas_rec                => IEX_CASE_UTL_PUB.G_MISS_CAS_REC,
        x_case_object_id         => l_case_object_id,
        x_return_status          => l_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data);
   END IF;

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    /*    Processing Ends       */

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
      WHEN okl_api.G_EXCEPTION_ERROR THEN
          x_return_status := okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'okl_api.G_RET_STS_ERROR',
            x_msg_count,
            x_msg_data,
            '_CASE_UTIL'
          );

      WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'okl_api.G_RET_STS_UNEXP_ERROR',
            x_msg_count,
            x_msg_data,
            '_CASE_UTIL'
          );

      WHEN OTHERS THEN
          x_return_status :=okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_CASE_UTIL'
          );
  END CREATE_CASE;

END OKL_CASE_UTIL_PVT;


/

--------------------------------------------------------
--  DDL for Package Body OKL_SERVICE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SERVICE_INTEGRATION_PVT" AS
/* $Header: OKLRSRIB.pls 120.9 2006/08/11 10:39:26 gboomina noship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_SERVICE_INTEGRATION_PVT';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
   G_LINK        CONSTANT VARCHAR2(10)   := 'LINKED';
   G_DELINK      CONSTANT VARCHAR2(10)   := 'DELINKED';
   G_IB_TXN_TYPE_NOT_FOUND     Constant Varchar2(200) := 'OKL_LLA_IB_TXN_TYPE_NOT_FOUND';
   G_TXN_TYPE_TOKEN            Constant Varchar2(30)  := 'TXN_TYPE';
   G_LLA_SRV_PROD_INST         CONSTANT VARCHAR2(35)  := 'OKL_LLA_SRV_PROD_INST';
   G_LLA_SRV_LOC_TYPE          CONSTANT VARCHAR2(35)  := 'OKL_LLA_SRV_LOC_TYPE';

   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
    */
   G_WF_EVT_KHR_SERV_CREATED CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.service_created_from_contract';
   G_WF_EVT_KHR_SERV_DELETED CONSTANT VARCHAR2(65)   := 'oracle.apps.okl.la.lease_contract.remove_service_fee';
   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30)        := 'CONTRACT_ID';
   G_WF_ITM_CONTRACT_LINE_ID CONSTANT VARCHAR2(30)   := 'SERVICE_LINE_ID';
   G_WF_ITM_S_CONTRACT_ID CONSTANT VARCHAR2(30)      := 'SERVICE_CONTRACT_ID';
   G_WF_ITM_S_CONTRACT_LINE_ID CONSTANT VARCHAR2(30) := 'SERVICE_CONTRACT_LINE_ID';
   G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)   := 'CONTRACT_PROCESS';
   /*
    * sjalasut: aug 18, 04 added constants used in raising business event. END
    */


   SUBTYPE crjv_rec_type IS OKC_K_REL_OBJS_PUB.crjv_rec_type;
   SUBTYPE crjv_tbl_type IS OKC_K_REL_OBJS_PUB.crjv_tbl_type;
   --SUBTYPE clev_rec_type IS OKL_CREATE_KLE_PUB.clev_rec_type;
   --SUBTYPE clev_tbl_type IS OKL_CREATE_KLE_PUB.clev_tbl_type;
   --SUBTYPE klev_rec_type IS OKL_CREATE_KLE_PUB.klev_rec_type;
   SUBTYPE cimv_rec_type IS OKL_CREATE_KLE_PUB.cimv_rec_type;
   SUBTYPE cplv_rec_type IS OKL_OKC_MIGRATION_PVT.cplv_rec_type;
   SUBTYPE tcnv_rec_type IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

   G_STY_ID OKL_K_LINES.STY_ID%TYPE; -- populate from create_service_from_oks() only -- Bug 4011710

------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );

    FOR i in 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

    END LOOP;
    return;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;

 /*
  * sjalasut: aug 18, 04 added procedure to call private wrapper that raises the business event. BEGIN
  */
 -------------------------------------------------------------------------------
 -- PROCEDURE raise_business_event
 -------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : raise_business_event
 -- Description     : This procedure is a wrapper that raises a business event
 --                 : when ever service line is created or deleted. this api also
 --                 : gets optional service contract parameters if the service line
 --                 : is created from a service contract.
 -- Business Rules  :
 -- Parameters      : p_chr_id,p_asset_id, p_event_name along with other api params
 --                 : p_oks_chr_id, p_oks_service_line_id
 -- Version         : 1.0
 -- History         : 30-AUG-2004 SJALASUT created
 -- End of comments
 PROCEDURE raise_business_event(p_api_version IN NUMBER,
                                p_init_msg_list IN VARCHAR2,
                                p_chr_id IN okc_k_headers_b.id%TYPE,
                                p_oks_chr_id IN okc_k_headers_b.id%TYPE,
                                p_okl_service_line_id IN okc_k_lines_b.id%TYPE,
                                p_oks_service_line_id IN okc_k_lines_b.id%TYPE,
                                p_event_name IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2
                                ) IS
   l_parameter_list wf_parameter_list_t;
   l_contract_process VARCHAR2(20);
 BEGIN
   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   -- wrapper API to get contract process. this API determines in which status the
   -- contract in question is.
   l_contract_process := okl_lla_util_pvt.get_contract_process(p_chr_id => p_chr_id);
   wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, p_chr_id, l_parameter_list);
   wf_event.AddParameterToList(G_WF_ITM_CONTRACT_LINE_ID, p_okl_service_line_id, l_parameter_list);
   -- pass the service contract and service contract line only if they are present.
   -- since service can be created even without a service contract, these parameters
   -- are null when not created from a service contract. therefore these parameters can be
   -- ignored in such a case.
   IF(p_oks_chr_id IS NOT NULL AND p_oks_service_line_id IS NOT NULL)THEN
     wf_event.AddParameterToList(G_WF_ITM_S_CONTRACT_ID, p_oks_chr_id, l_parameter_list);
     wf_event.AddParameterToList(G_WF_ITM_S_CONTRACT_LINE_ID, p_oks_service_line_id, l_parameter_list);
   END IF;
   wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS, l_contract_process, l_parameter_list);

   OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_event_name     => p_event_name,
                          p_parameters     => l_parameter_list);

 EXCEPTION
   WHEN OTHERS THEN
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END raise_business_event;

 /*
  * sjalasut: aug 18, 04 added procedure to call private wrapper that raises the business event. END
  */


------------------------------------------------------------------------------
-- PROCEDURE create_link_service_line
--
--  This procedure creates and links service line under a given contract in OKL. The
--  service line information comes from OKS service contract number provided as
--  an input parameter.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_link_service_line(
                                         p_api_version         IN  NUMBER,
                                         p_init_msg_list       IN  VARCHAR2,
                                         x_return_status       OUT NOCOPY VARCHAR2,
                                         x_msg_count           OUT NOCOPY NUMBER,
                                         x_msg_data            OUT NOCOPY VARCHAR2,
                                         p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                         p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                         p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                         p_supplier_id         IN  NUMBER,                  -- OKL_VENDOR
                                         x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE    -- Returns Lease Contract Service TOP Line ID
                               )IS

   l_api_name    VARCHAR2(35)    := 'create_link_service_line';
   l_proc_name   VARCHAR2(35)    := 'CREATE_LINK_SERVICE_LINE';
   l_api_version CONSTANT NUMBER := 1;

   l_okl_service_line_id OKC_K_HEADERS_V.ID%TYPE;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      create_service_line(
                          p_api_version         => 1.0,
                          p_init_msg_list       => OKL_API.G_FALSE,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_okl_chr_id          => p_okl_chr_id,
                          p_oks_chr_id          => p_oks_chr_id,
                          p_oks_service_line_id => p_oks_service_line_id,
                          p_supplier_id         => p_supplier_id,
                          x_okl_service_line_id => l_okl_service_line_id
                         );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      link_service_line(
                        p_api_version         => 1.0,
                        p_init_msg_list       => OKL_API.G_FALSE,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data,
                        p_okl_chr_id          => p_okl_chr_id,
                        p_oks_chr_id          => p_oks_chr_id,
                        p_okl_service_line_id => l_okl_service_line_id,
                        p_oks_service_line_id => p_oks_service_line_id
                       );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_okl_service_line_id := l_okl_service_line_id;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      /*
       * sjalasut: aug 18, 04 added code to enable business event. BEGIN
       * raise business event only if the context contract is a LEASE contract
       */
      IF(OKL_LLA_UTIL_PVT.is_lease_contract(p_okl_chr_id)= OKL_API.G_TRUE)THEN
        raise_business_event(p_api_version         => p_api_version,
                             p_init_msg_list       => p_init_msg_list,
                             p_chr_id              => p_okl_chr_id,
                             p_oks_chr_id          => p_oks_chr_id,
                             p_okl_service_line_id => l_okl_service_line_id,
                             p_oks_service_line_id => p_oks_service_line_id,
                             p_event_name          => G_WF_EVT_KHR_SERV_CREATED,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data
                            );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      /*
       * sjalasut: aug 18, 04 added code to enable business event. END
       */


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

   END create_link_service_line;


------------------------------------------------------------------------------
-- PROCEDURE get_bill_to
--
--  This procedure returns bill to id from contract header
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_bill_to(
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_chr_id         IN  OKC_K_HEADERS_B.ID%TYPE,
                         x_bill_to_id     OUT NOCOPY OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE
                        ) IS

   l_proc_name   VARCHAR2(35) := 'GET_BILL_TO';

   CURSOR bill_to_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT bill_to_site_use_id
   FROM   okc_k_headers_b
   WHERE  id = p_chr_id;

   bill_to_failed EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     x_bill_to_id := NULL;
     OPEN bill_to_csr (p_chr_id);
     FETCH bill_to_csr INTO x_bill_to_id;
     IF bill_to_csr%NOTFOUND THEN
        RAISE bill_to_failed;
     END IF;
     CLOSE bill_to_csr;

     IF (x_bill_to_id IS NULL) THEN
        RAISE bill_to_failed;
     END IF;

     RETURN;

   EXCEPTION

     WHEN bill_to_failed THEN
        IF bill_to_csr%ISOPEN THEN
           CLOSE bill_to_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;

        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );

     WHEN OTHERS THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
       okl_api.set_message(
                    G_APP_NAME,
                    G_UNEXPECTED_ERROR,
                    'OKL_SQLCODE',
                    SQLCODE,
                    'OKL_SQLERRM',
                    SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                   );
   END get_bill_to;

------------------------------------------------------------------------------
-- PROCEDURE validate_integration
--
--  This procedure validates currency, bill_to and customer of lease and
--  service contract.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE validate_integration(
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_okl_chr_id    IN OKC_K_HEADERS_V.ID%TYPE,
                        p_oks_chr_id    IN OKC_K_HEADERS_V.ID%TYPE
                       ) IS


   -- Check for 11.5.9 or 11.5.10 OKS version
   CURSOR check_oks_ver IS
   SELECT 1
   FROM   okc_class_operations
   WHERE  cls_code = 'SERVICE'
   AND    opn_code = 'CHECK_RULE';

   l_dummy NUMBER;
   l_oks_ver VARCHAR2(3);

   CURSOR oks_info_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT contract_number,
          currency_code,
          customer_id,
          bill_to_id
   FROM   okl_la_link_service_uv
   WHERE  chr_id = p_chr_id;

   CURSOR oks_info_csr9 (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT contract_number,
          currency_code,
          customer_id,
          bill_to_id
   FROM   okl_la_link_service_uv9
   WHERE  chr_id = p_chr_id;

   CURSOR okl_curr_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT contract_number,
          currency_code
   FROM   okc_k_headers_v
   WHERE  id = p_chr_id;

   CURSOR okl_cust_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT role.object1_id1
   FROM   okc_k_party_roles_v role
   WHERE  role.chr_id = p_chr_id
   AND    role.rle_code = 'LESSEE';

   CURSOR okl_bill_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT rule.object1_id1
   FROM   okc_rule_groups_v rgp,
          okc_rules_v rule
   WHERE  rgp.chr_id = p_chr_id
   AND    rgp.id = rule.rgp_id
   AND    rgp.rgd_code = 'LABILL'
   AND    rule.rule_information_category = 'BTO';

   CURSOR prev_link_csr (p_okl_chr_id OKC_K_HEADERS_B.ID%TYPE,
                         p_oks_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT chr_id
   FROM   okc_k_rel_objs_v
   WHERE  chr_id      <> p_okl_chr_id
   AND    object1_id1 = p_oks_chr_id
   AND    rty_code    = 'OKLSRV';

   l_proc_name   VARCHAR2(35)    := 'VALIDATE_INTEGRATION';

   l_okl_currency OKC_K_HEADERS_V.CURRENCY_CODE%TYPE;
   l_oks_currency OKC_K_HEADERS_V.CURRENCY_CODE%TYPE;

   l_okl_customer_id   OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE;
   l_oks_customer_id   OKL_LA_LINK_SERVICE_UV.CUSTOMER_ID%TYPE;

   l_okl_bill_to_id    OKC_RULES_V.OBJECT1_ID1%TYPE;
   l_oks_bill_to_id    OKL_LA_LINK_SERVICE_UV.BILL_TO_ID%TYPE;

   l_oks_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
   l_okl_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;

   validation_failed   EXCEPTION;
   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     l_oks_ver := '?';
     OPEN check_oks_ver;
     FETCH check_oks_ver INTO l_dummy;
     IF check_oks_ver%NOTFOUND THEN
        l_oks_ver := '9';
     ELSE
        l_oks_ver := '10';
     END IF;
     CLOSE check_oks_ver;

     IF (l_oks_ver = '10') THEN

        FOR oks_rec IN oks_info_csr (p_oks_chr_id)
        LOOP
           l_oks_currency        := oks_rec.currency_code;
           l_oks_contract_number := oks_rec.contract_number;
           l_oks_customer_id     := oks_rec.customer_id;
           l_oks_bill_to_id      := oks_rec.bill_to_id;
        END LOOP;

     ELSE -- oks_ver = 9
        FOR oks_rec IN oks_info_csr9 (p_oks_chr_id)
        LOOP
           l_oks_currency        := oks_rec.currency_code;
           l_oks_contract_number := oks_rec.contract_number;
           l_oks_customer_id     := oks_rec.customer_id;
           l_oks_bill_to_id      := TO_NUMBER(oks_rec.bill_to_id);
        END LOOP;

     END IF; -- l_oks_ver

     FOR okl_curr_rec IN okl_curr_csr (p_okl_chr_id)
     LOOP
        l_okl_contract_number := okl_curr_rec.contract_number;
        l_okl_currency        := okl_curr_rec.currency_code;
     END LOOP;

     IF (l_okl_currency <> l_oks_currency) THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_LLA_CURR_MISMATCH
                          );
       RAISE validation_failed;
     END IF;

     FOR okl_cust_rec IN okl_cust_csr (p_okl_chr_id)
     LOOP
        l_okl_customer_id := okl_cust_rec.object1_id1;
     END LOOP;

     IF (l_okl_customer_id <> l_oks_customer_id) THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_LLA_CUST_MISMATCH
                          );
       RAISE validation_failed;
     END IF;

     get_bill_to(
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_chr_id        => p_okl_chr_id,
                  x_bill_to_id    => l_okl_bill_to_id
                 );

     IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE validation_failed;
     END IF;
/* BTO rule migration
     FOR okl_bill_rec IN okl_bill_csr (p_okl_chr_id)
     LOOP
        l_okl_bill_to_id := okl_bill_rec.object1_id1;
     END LOOP;
*/
     IF (l_okl_bill_to_id <> l_oks_bill_to_id) THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_LLA_BILL_TO_MISMATCH
                          );
       RAISE validation_failed;
     END IF;

     FOR prev_link_rec IN prev_link_csr (p_okl_chr_id,
                                         p_oks_chr_id)
     LOOP

       l_okl_contract_number := NULL;
       l_okl_currency        := NULL;

       OPEN okl_curr_csr (prev_link_rec.chr_id);
       FETCH okl_curr_csr INTO l_okl_contract_number,
                               l_okl_currency;
       CLOSE okl_curr_csr;

       okl_api.set_message(
                           G_APP_NAME,
                           G_SERVICE_LINK_EXIST,
                           'OKL_CONTRACT',
                           l_okl_contract_number
                          );
       RAISE validation_failed;
     END LOOP;

   EXCEPTION
     WHEN validation_failed THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
   END validate_integration;

------------------------------------------------------------------------------
-- PROCEDURE create_service_line
--
--  This procedure creates a service line under a given contract in OKL. The
--  service line information comes from OKS service contract number provided as
--  an input parameter.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                x_okl_service_line_id OUT NOCOPY  OKC_K_LINES_V.ID%TYPE    -- Returns Lease Contract Service TOP Line ID
                               )IS
   l_api_name    VARCHAR2(35)    := 'create_service_line';
   l_proc_name   VARCHAR2(35)    := 'CREATE_SERVICE_LINE';
   l_api_version CONSTANT NUMBER := 1;

   CURSOR line_style_csr (p_style okc_line_styles_v.lty_code%TYPE) IS
   SELECT id
   FROM   okc_line_styles_v
   WHERE  lty_code = p_style;

   CURSOR currency_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT currency_code
   FROM   okc_k_headers_v
   WHERE  id = p_chr_id;

   TYPE srv_okl_rec_type IS RECORD (
      item_id          mtl_system_items.inventory_item_id%type,
      item_name        mtl_system_items.description%type,
      price_negotiated okc_k_lines_v.price_negotiated%type,
      fin_line_id      okc_k_lines_v.id%type,
      asset_number     okc_k_lines_v.name%type,
      okl_no_of_item   number,
      srv_no_of_item   number
   );

   TYPE srv_okl_tbl_type IS TABLE OF srv_okl_rec_type
        INDEX BY BINARY_INTEGER;

   l_srv_okl_tbl srv_okl_tbl_type;

/*
   CURSOR srv_okl_csr (p_chr_id      OKC_K_HEADERS_V.ID%TYPE,
                       p_srv_line_id OKC_K_LINES_V.ID%TYPE) IS
   SELECT srv_prod.inventory_item_id item_id,
          srv_prod.name item_name,
	  srv_line.price_negotiated,
          okl_fin_line.id fin_line_id,
	  okl_fin_line.name asset_number,
	  okl_item.number_of_items okl_no_of_item,
	  srv_item.number_of_items srv_no_of_item
   FROM   okc_k_lines_b srv_line,
          okc_line_styles_b srv_style,
          okc_k_items srv_item,
          okx_customer_products_v srv_prod,
          okc_k_items okl_item,
          mtl_system_items_b okl_mtl,
          okc_k_lines_b okl_item_line,
	  okc_k_lines_v okl_fin_line,
          okc_line_styles_b okl_style
   WHERE  srv_line.lse_id            = srv_style.id
   AND    srv_line.id                = srv_item.cle_id
   AND    srv_item.object1_id1       = srv_prod.id1
   AND    srv_prod.inventory_item_id = okl_mtl.inventory_item_id
   AND    srv_prod.organization_id   = okl_mtl.organization_id
   AND    okl_item.object1_id1       = okl_mtl.inventory_item_id
   AND    okl_item.object1_id2       = TO_CHAR(okl_mtl.organization_id) -- Bug# 2887948
   AND    okl_item.cle_id            = okl_item_line.id
   AND    okl_item_line.lse_id       = okl_style.id
   AND    okl_item_line.cle_id       = okl_fin_line.id
   AND    okl_style.id               = okl_item_line.lse_id
   AND    okl_style.lty_code         = 'ITEM'
   AND    okl_item_line.dnz_chr_id   = p_chr_id
   AND    srv_style.lty_code         = 'COVER_PROD'
   AND    srv_line.sts_code          = 'ACTIVE'
   AND    srv_line.cle_id            = p_srv_line_id;
*/


   CURSOR srv_amt_csr (p_chr_id      OKC_K_HEADERS_V.ID%TYPE,
                       p_srv_line_id OKC_K_LINES_V.ID%TYPE) IS
   SELECT nvl(sum(l.price_negotiated),0) tot_amount
   FROM   okc_k_lines_v l,
          okc_line_styles_v s,
          okc_k_items_v item,
          okx_install_items_v prod
   WHERE  l.lse_id         = s.id
   AND    l.id             = item.cle_id
   AND    item.object1_id1 = prod.id1
   AND    EXISTS (
             SELECT 'Y'
             FROM   okc_k_items_v item,
                    okx_system_items_v mtl,
                    okc_k_lines_v line,
                    okc_line_styles_v style
             WHERE  item.object1_id1 = mtl.id1
             AND    item.object1_id2 = TO_CHAR(mtl.id2) -- Bug# 2887948
             AND    item.cle_id      = line.id
             AND    line.lse_id      = style.id
             AND    line.dnz_chr_id  = p_chr_id
             AND    mtl.id1          = prod.inventory_item_id
             AND    style.lty_code   = 'ITEM'
          )
   AND    s.lty_code = 'COVER_PROD'
   AND    l.sts_code = 'ACTIVE'
   --Bug# :
   --AND    l.cle_id   = p_srv_line_id;
   AND    l.cle_id   = nvl(p_srv_line_id,l.cle_id);
   --AND    prod.organization_id = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');


   CURSOR srv_line_csr (p_line_id OKC_K_LINES_V.ID%TYPE) IS
   SELECT start_date,
          end_date
   FROM   okc_k_lines_v
   WHERE  id = p_line_id;

   CURSOR lease_con_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT start_date,
          end_date,
          sts_code
   FROM   okc_k_headers_v
   WHERE  id = p_chr_id;


   CURSOR item_csr (p_cle_id OKC_K_LINES_V.ID%TYPE) IS
   SELECT object1_id1,
          object1_id2,
          uom_code
   FROM   okc_k_items_v
   WHERE  cle_id = p_cle_id
   AND    jtot_object1_code = 'OKX_SERVICE';

   l_lse_id        OKC_K_LINES_V.LSE_ID%TYPE;
   l_currency_code OKC_K_HEADERS_V.CURRENCY_CODE%TYPE;
   l_srv_amount    NUMBER;
   x_cle_id        OKC_K_LINES_V.ID%TYPE;

   l_srv_st_date     OKC_K_LINES_V.START_DATE%TYPE;
   l_srv_end_date    OKC_K_LINES_V.START_DATE%TYPE;
   l_lease_st_date   OKC_K_LINES_V.START_DATE%TYPE;
   l_lease_end_date  OKC_K_LINES_V.START_DATE%TYPE;

   l_inv_item_id   NUMBER;
   l_inv_org_id    NUMBER;

   l_uom_code      OKC_K_ITEMS_V.UOM_CODE%TYPE;

   l_start_date    DATE;
   l_end_date      DATE;

   p_klev_rec      klev_rec_type;
   p_clev_rec      clev_rec_type;
   x_klev_rec      klev_rec_type;
   x_clev_rec      clev_rec_type;

   p_cimv_rec      okl_okc_migration_pvt.cimv_rec_type;
   x_cimv_rec      okl_okc_migration_pvt.cimv_rec_type;

   p_cplv_rec      cplv_rec_type;
   x_cplv_rec      cplv_rec_type;

   i               NUMBER := 0;
   l_lease_sts_code OKC_K_HEADERS_V.STS_CODE%TYPE;

   --Bug# 4558486
   l_kplv_rec      OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
   x_kplv_rec      OKL_K_PARTY_ROLES_PVT.kplv_rec_type;

   BEGIN -- main process begins here
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      validate_integration(
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_okl_chr_id    => p_okl_chr_id,
                           p_oks_chr_id    => p_oks_chr_id
                          );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get Line Style ID for SOLD_SERVICE
      OPEN line_style_csr ('SOLD_SERVICE');
      FETCH line_style_csr INTO l_lse_id;
      CLOSE line_style_csr;

      -- Get contract currency
      OPEN currency_csr (p_okl_chr_id);
      FETCH currency_csr INTO l_currency_code;
      CLOSE currency_csr;

      -- Get COVERED_PRODUCT detail, subline of OKS service top line
      l_srv_amount := 0;
      i            := 1;
/*
      FOR srv_okl_rec IN srv_okl_csr(p_okl_chr_id,
                                     p_oks_service_line_id)
      LOOP
        l_srv_okl_tbl(i).item_id           := srv_okl_rec.item_id;
        l_srv_okl_tbl(i).item_name         := srv_okl_rec.item_name;
        l_srv_okl_tbl(i).price_negotiated  := srv_okl_rec.price_negotiated;
        l_srv_okl_tbl(i).fin_line_id       := srv_okl_rec.fin_line_id;
        l_srv_okl_tbl(i).asset_number      := srv_okl_rec.asset_number;
        l_srv_okl_tbl(i).okl_no_of_item    := srv_okl_rec.okl_no_of_item;
        l_srv_okl_tbl(i).srv_no_of_item    := srv_okl_rec.srv_no_of_item;

        l_srv_amount                       := l_srv_amount + srv_okl_rec.price_negotiated;

        IF (srv_okl_rec.okl_no_of_item <> srv_okl_rec.srv_no_of_item) THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_OKL_ITEM_QTY_MISMATCH
                              );
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

         i := i + 1;
      END LOOP;
*/

      FOR srv_amt_rec IN srv_amt_csr (p_okl_chr_id,
                                      p_oks_service_line_id)
      LOOP
         l_srv_amount := srv_amt_rec.tot_amount;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount: '||l_srv_amount);
      END IF;
      IF (l_srv_amount = 0 ) THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_ITEM_MISMATCH
                           );
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get line start and end Date
      OPEN srv_line_csr (p_oks_service_line_id);
      FETCH srv_line_csr INTO l_srv_st_date,
                              l_srv_end_date;
      CLOSE srv_line_csr;

      -- Get lease contract start, end date
      OPEN lease_con_csr (p_okl_chr_id);
      FETCH lease_con_csr INTO l_lease_st_date,
                               l_lease_end_date,
                               l_lease_sts_code;
      CLOSE lease_con_csr;

      IF (l_lease_st_date > l_srv_end_date) THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_LINK_CON_ERROR
                           );
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_lease_end_date < l_srv_st_date) THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_LINK_CON_ERROR
                           );
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_lease_st_date < l_srv_st_date) THEN
          l_start_date := l_srv_st_date;
      ELSE
          l_start_date := l_lease_st_date;
      END IF;

      IF (l_lease_end_date < l_srv_end_date) THEN
          l_end_date := l_lease_end_date;
      ELSE
          l_end_date := l_srv_end_date;
      END IF;

      -- Create OKL Service TOP line
      p_clev_rec.chr_id      := p_okl_chr_id;
      p_clev_rec.dnz_chr_id  := p_okl_chr_id;
      p_clev_rec.lse_id      := l_lse_id;
      p_clev_rec.line_number := 1;
      p_clev_rec.sts_code    := l_lease_sts_code;
      --p_clev_rec.sts_code    := 'NEW';
      p_clev_rec.exception_yn := 'N';
      p_clev_rec.display_sequence := 1;
      p_clev_rec.currency_code    := l_currency_code;
      p_klev_rec.amount           := l_srv_amount;

      p_clev_rec.start_date := l_start_date;
      p_clev_rec.end_date   := l_end_date;

      p_klev_rec.sty_id     := G_STY_ID; -- Bug 4011710

      okl_contract_pub.create_contract_line(
                                               p_api_version   => 1.0,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_clev_rec      => p_clev_rec,
                                               p_klev_rec      => p_klev_rec,
                                               x_clev_rec      => x_clev_rec,
                                               x_klev_rec      => x_klev_rec
                                              );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_cle_id := x_clev_rec.id;

      -- create item line to link TOP line, created above, to MTL_SYSTEM_ITEMS

      OPEN item_csr (p_oks_service_line_id);
      FETCH item_csr INTO l_inv_item_id,
                          l_inv_org_id,
                          l_uom_code;
      CLOSE item_csr;

      -- Create Item link to service top line
      p_cimv_rec                   := NULL;
      p_cimv_rec.cle_id            := x_cle_id;
      --p_cimv_rec.chr_id            := p_okl_chr_id;
      p_cimv_rec.dnz_chr_id        := p_okl_chr_id;

      p_cimv_rec.object1_id1       := l_inv_item_id; --???
      p_cimv_rec.object1_id2       := l_inv_org_id;  --???
      p_cimv_rec.uom_code          := 'EA'; --l_uom_code;
      --p_cimv_rec.number_of_items   := l_no_of_items;
      p_cimv_rec.jtot_object1_code := 'OKX_SERVICE';
      p_cimv_rec.exception_yn      := 'N';

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Item: '||l_inv_item_id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Org : '||l_inv_org_id);
      END IF;

      OKL_OKC_MIGRATION_PVT.create_contract_item(
                                                 p_api_version   => 1.0,
                                                 p_init_msg_list => OKL_API.G_FALSE,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data	 => x_msg_data,
                                                 p_cimv_rec	 => p_cimv_rec,
                                                 x_cimv_rec	 => x_cimv_rec
                                                );
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_okl_service_line_id := x_cle_id;

      p_cplv_rec.chr_id            := NULL;
      p_cplv_rec.dnz_chr_id        := p_okl_chr_id;
      p_cplv_rec.cle_id            := x_cle_id;

      p_cplv_rec.object1_id1       := p_supplier_id;
      p_cplv_rec.object1_id2       := '#';
      p_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
      p_cplv_rec.rle_code          := 'OKL_VENDOR';

      --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
      --              to create records in tables
      --              okc_k_party_roles_b and okl_k_party_roles
      /*
      OKL_OKC_MIGRATION_PVT.create_k_party_role(
                                  p_api_version   => 1.0,
                                  p_init_msg_list => OKL_API.G_FALSE,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_cplv_rec      => p_cplv_rec,
                                  x_cplv_rec      => x_cplv_rec
                                 );
      */

      OKL_K_PARTY_ROLES_PVT.create_k_party_role(
                                  p_api_version   => 1.0,
                                  p_init_msg_list => OKL_API.G_FALSE,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_cplv_rec      => p_cplv_rec,
                                  x_cplv_rec      => x_cplv_rec,
                                  p_kplv_rec      => l_kplv_rec,
                                  x_kplv_rec      => x_kplv_rec
                                 );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

/* Don't create covered asset line automatically

      -- Create Covered Asset line, service sub line(s)

      -- Get Line Style ID for SOLD_SERVICE
      OPEN line_style_csr ('LINK_SERV_ASSET');
      FETCH line_style_csr INTO l_lse_id;
      CLOSE line_style_csr;

      FOR i IN 1..l_srv_okl_tbl.COUNT
      LOOP
         p_clev_rec                  := NULL;
         p_clev_rec.cle_id           := x_cle_id; -- service top line id
         p_clev_rec.chr_id           := NULL;
         p_clev_rec.dnz_chr_id       := p_okl_chr_id;
         p_clev_rec.lse_id           := l_lse_id;
         p_clev_rec.line_number      := 1;
         p_clev_rec.name             := l_srv_okl_tbl(i).asset_number;
         p_clev_rec.sts_code         := 'NEW';
         p_clev_rec.exception_yn     := 'N';
         p_clev_rec.display_sequence := 1;

         p_clev_rec.start_date       := l_start_date;
         p_clev_rec.end_date         := l_end_date;

         p_klev_rec.capital_amount   := l_srv_okl_tbl(i).price_negotiated;

         okl_contract_pub.create_contract_line(
                                               p_api_version   => 1.0,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_clev_rec      => p_clev_rec,
                                               p_klev_rec      => p_klev_rec,
                                               x_clev_rec      => x_clev_rec,
                                               x_klev_rec      => x_klev_rec
                                              );

         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         -- Create item link for covered asset line
         p_cimv_rec                   := NULL;
         p_cimv_rec.cle_id            := x_clev_rec.id;
         p_cimv_rec.chr_id            := p_okl_chr_id;
         p_cimv_rec.dnz_chr_id        := p_okl_chr_id;
         p_cimv_rec.object1_id1       := l_srv_okl_tbl(i).fin_line_id;
         p_cimv_rec.object1_id2       := '#';
         p_cimv_rec.jtot_object1_code := 'OKX_COVASST';
         p_cimv_rec.exception_yn      := 'N';

         okl_okc_migration_pvt.create_contract_item(
                                                    p_api_version   => 1.0,
                                                    p_init_msg_list => OKL_API.G_FALSE,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data	 => x_msg_data,
                                                    p_cimv_rec	 => p_cimv_rec,
                                                    x_cimv_rec	 => x_cimv_rec
                                                   );
         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END LOOP;
*/

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

   END create_service_line;

------------------------------------------------------------------------------
-- PROCEDURE link_service_line
--
--  This procedure links
--     1. Lease and Service Contract Header
--     2. Lease Contract Service Line and Service Contract service line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE link_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_okl_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Lease Service Top Line ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE    -- Service Contract - Service TOP Line ID
                               ) IS

   l_api_name    VARCHAR2(35)    := 'link_service_line';
   l_proc_name   VARCHAR2(35)    := 'LINK_SERVICE_LINE';
   l_api_version CONSTANT NUMBER := 1;

   l_crjv_rec          crjv_rec_type;
   x_crjv_rec          crjv_rec_type;

   l_service_contract_id OKC_K_HEADERS_V.ID%TYPE;
   l_oks_service_line_id OKC_K_LINES_V.ID%TYPE;

   BEGIN -- main process begins here
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      --
      -- Check for any existing link
      --
      check_service_link(
                          p_api_version             => 1.0,
                          p_init_msg_list           => OKL_API.G_FALSE,
                          x_return_status           => x_return_status,
                          x_msg_count               => x_msg_count,
                          x_msg_data                => x_msg_data,
                          p_lease_contract_id       => p_okl_chr_id,
                          x_service_contract_id     => l_service_contract_id
                        );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_service_contract_id IS NOT NULL
          AND
          l_service_contract_id <> p_oks_chr_id
         ) THEN
         okl_api.set_message(
                            G_APP_NAME,
                            G_OKL_MULTI_LINK_ERROR
                           );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before creating link');
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL :'||p_okl_chr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKS :'||p_oks_chr_id);
      END IF;
      --
      -- Link OKL and OKS Contract at Header level
      --
      --
      -- Check for an existing service line link
      --
      check_service_line_link(
                          p_api_version             => 1.0,
                          p_init_msg_list           => OKL_API.G_FALSE,
                          x_return_status           => x_return_status,
                          x_msg_count               => x_msg_count,
                          x_msg_data                => x_msg_data,
                          p_lease_contract_id       => p_okl_chr_id,
                          p_oks_service_line_id     => p_oks_service_line_id,
                          x_service_contract_id     => l_service_contract_id
                        );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKS Line: '||l_oks_service_line_id);
      END IF;

      IF (l_service_contract_id IS NULL) THEN -- create a new header link
         l_crjv_rec := NULL;
         l_crjv_rec.chr_id            := p_okl_chr_id;
         l_crjv_rec.rty_code          := 'OKLSRV';
         l_crjv_rec.object1_id1       := to_char(p_oks_chr_id);
         l_crjv_rec.object1_id2       := '#';
         l_crjv_rec.jtot_object1_code := 'OKL_SERVICE_CONNECTOR'; -- Fix Bug# 2872267

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling 1'||':'||x_return_status);
         END IF;
         OKC_K_REL_OBJS_PUB.create_row (
                                        p_api_version => 1.0,
                                        p_init_msg_list => OKC_API.G_FALSE,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_crjv_rec      => l_crjv_rec,
                                        x_crjv_rec      => x_crjv_rec
                                       );

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling 1'||':'||x_return_status);
         END IF;
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
      END IF; -- l_service_contract is NULL

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After creating header link');
      END IF;
      --
      -- Link OKL and OKS Contract at Line level
      --
      l_crjv_rec.chr_id            := p_okl_chr_id;
      l_crjv_rec.cle_id            := p_okl_service_line_id;
      l_crjv_rec.rty_code          := 'OKLSRV'; -- Need to be seeded ???
      l_crjv_rec.object1_id1       := to_char(p_oks_service_line_id);
      l_crjv_rec.object1_id2       := '#';
      l_crjv_rec.jtot_object1_code := 'OKL_SERVICE_LINE';

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL Line ID: '|| p_okl_service_line_id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKS Line ID: '|| p_oks_service_line_id);
      END IF;

      OKC_K_REL_OBJS_PUB.create_row (
                                     p_api_version => 1.0,
                                     p_init_msg_list => OKC_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_crjv_rec      => l_crjv_rec,
                                     x_crjv_rec      => x_crjv_rec
                                    );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After line link creation');
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END link_service_line;

------------------------------------------------------------------------------
-- PROCEDURE delete_service_line
--
--  This procedure deletes service line. It also checks for any existing links
--  with OKS Service contract, if so, it deltes the link too.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE delete_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_clev_rec            IN  clev_rec_type,
                                p_klev_rec            IN  klev_rec_type
                               ) IS
  l_api_name    VARCHAR2(35)    := 'delete_service_link';
  l_proc_name   VARCHAR2(35)    := 'DELETE_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR line_link_csr (p_okl_service_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT id
  FROM   okc_k_rel_objs_v
  WHERE  cle_id            = p_okl_service_line_id
  AND    rty_code          = 'OKLSRV' -- ???
  AND    jtot_object1_code = 'OKL_SERVICE_LINE';

  CURSOR any_more_link_csr(p_okl_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM okc_k_rel_objs_v t1
  WHERE chr_id = p_okl_chr_id
  AND cle_id   IS NULL
  AND NOT EXISTS (SELECT 'Y'
                  FROM  okc_k_rel_objs t2
                  WHERE t2.cle_id            IS NOT NULL
		  AND   t2.chr_id            = t1.chr_id
		  AND   t2.rty_code          = 'OKLSRV'
		  AND   t2.jtot_object1_code = 'OKL_SERVICE_LINE'
                 );
  /*
   * sjalsut:  aug 18, 04 added cursors to fetch the service contract id and
   *           service line id from the context contract and contract top line. BEGIN.
                 IF (G_DEBUG_ENABLED = 'Y') THEN
                   G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
                 END IF;
   */

  CURSOR get_service_top_line IS
  SELECT rlobj.object1_id1
    FROM okc_k_rel_objs_v rlobj
   WHERE rlobj.chr_id = p_clev_rec.dnz_chr_id
     AND rlobj.cle_id = p_clev_rec.id
     AND rlobj.rty_code = 'OKLSRV'
     AND rlobj.jtot_object1_code = 'OKL_SERVICE_LINE';


  CURSOR get_service_header_id(p_oks_service_line_id okc_k_lines_b.id%TYPE) IS
  SELECT dnz_chr_id
    FROM okc_k_lines_b
   WHERE id = p_oks_service_line_id;
  /*
   * sjalsut:  aug 18, 04 added cursors to fetch the service contract id and
   *           service line id from the context contract and contract top line. END.
   */


  l_crjv_rec          crjv_rec_type;
  l_header_rel_id     okc_k_rel_objs_v.id%type;
  l_line_rel_id       okc_k_rel_objs_v.id%type;

  /*
   * sjalsut:  aug 18, 04 added variables to hold service contract header id and
   *           service contract line id. BEGIN.
   */
  l_serv_contract_hdr_id okc_k_headers_b.id%TYPE;
  l_serv_contract_line_id okc_k_lines_b.id%TYPE;

  /*
   * sjalsut:  aug 18, 04 added variables to hold service contract header id and
   *           service contract line id. BEGIN.
   */


  BEGIN -- main process begins here

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'DELETE 1');
      END IF;
      -- First delete the link
      l_line_rel_id := NULL;
      OPEN line_link_csr(p_clev_rec.id); -- Service top line ID
      FETCH line_link_csr INTO l_line_rel_id;
      CLOSE line_link_csr;

      IF (l_line_rel_id IS NOT NULL) THEN -- Link exists, delete it
         l_crjv_rec.id := l_line_rel_id;
         OKC_K_REL_OBJS_PUB.delete_row (
                                        p_api_version   => p_api_version,
                                        p_init_msg_list => OKL_API.G_FALSE,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_crjv_rec      => l_crjv_rec
                                       );

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;


         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'DELETE 2');
         END IF;
         --
         -- Check for any more link left, if not, delete header link
         --
         l_header_rel_id := NULL;
         OPEN any_more_link_csr (p_clev_rec.dnz_chr_id);
         FETCH any_more_link_csr INTO l_header_rel_id;
         IF any_more_link_csr%NOTFOUND THEN
            l_header_rel_id := NULL;
         END IF;
         CLOSE any_more_link_csr;

         IF (l_header_rel_id IS NOT NULL) THEN
            l_crjv_rec.id := l_header_rel_id;
            OKC_K_REL_OBJS_PUB.delete_row (
                                           p_api_version   => p_api_version,
                                           p_init_msg_list => OKL_API.G_FALSE,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_crjv_rec      => l_crjv_rec
                                          );

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
               raise OKC_API.G_EXCEPTION_ERROR;
            END IF;

         END IF;

      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'DELETE 3');
      END IF;
      --
      -- delete service line
      --
      okl_contract_pub.delete_contract_line(
                                            p_api_version       => p_api_version,
                                            p_init_msg_list     => OKL_API.G_FALSE,
                                            x_return_status     => x_return_status,
                                            x_msg_count         => x_msg_count,
                                            x_msg_data          => x_msg_data,
                                            p_clev_rec          => p_clev_rec,
                                            p_klev_rec          => p_klev_rec,
                                            p_delete_cascade_yn => 'Y'
                                           );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'DELETE 4');
      END IF;
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      /*
       * sjalasut: aug 18, 04 added code to enable business event. BEGIN
       */
      OPEN get_service_top_line;
      FETCH get_service_top_line INTO l_serv_contract_line_id;
      CLOSE get_service_top_line;
      -- fetch the service contract header details only if the service line is not
      -- null.
      IF(l_serv_contract_line_id IS NOT NULL)THEN
        OPEN get_service_header_id(l_serv_contract_line_id);
        FETCH get_service_header_id INTO l_serv_contract_hdr_id;
        CLOSE get_service_header_id;
      END IF;

      IF(OKL_LLA_UTIL_PVT.is_lease_contract(p_clev_rec.dnz_chr_id)= OKL_API.G_TRUE)THEN
        raise_business_event(p_api_version         => p_api_version,
                             p_init_msg_list       => p_init_msg_list,
                             p_chr_id              => p_clev_rec.dnz_chr_id,
                             p_oks_chr_id          => l_serv_contract_hdr_id,
                             p_okl_service_line_id => p_clev_rec.id,
                             p_oks_service_line_id => l_serv_contract_line_id,
                             p_event_name          => G_WF_EVT_KHR_SERV_DELETED,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data
                            );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      /*
       * sjalasut: aug 18, 04 added code to enable business event. END
       */


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

  END delete_service_line;

------------------------------------------------------------------------------
-- PROCEDURE update_service_line
--
--  This procedure updates existing service line link. It deletes existing
--  OKL Service line and recreate the same from OKS service line. It re-establish
--  the link at the end.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
 PROCEDURE update_service_line(
                                p_api_version         IN  NUMBER,
                                p_init_msg_list       IN  VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                p_oks_service_line_id IN  OKC_K_LINES_V.ID%TYPE,   -- Service Contract Service Top Line ID
                                p_supplier_id         IN  NUMBER,
                                p_clev_rec            IN  clev_rec_type,
                                p_klev_rec            IN  klev_rec_type,
                                x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                              ) IS
  l_api_name    VARCHAR2(35)    := 'update_service_link';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      --
      -- delete existing service line and link
      --
      okl_service_integration_pvt.delete_service_line(
                             p_api_version         => p_api_version,
                             p_init_msg_list       => OKL_API.G_TRUE,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_clev_rec            => p_clev_rec,
                             p_klev_rec            => p_klev_rec
                            );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --
      -- create service line and link
      --
      okl_service_integration_pvt.create_link_service_line(
                             p_api_version         => p_api_version,
                             p_init_msg_list       => OKL_API.G_TRUE,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_okl_chr_id          => p_okl_chr_id,
                             p_oks_chr_id          => p_oks_chr_id,
                             p_oks_service_line_id => p_oks_service_line_id,
                             p_supplier_id         => p_supplier_id,
                             x_okl_service_line_id => x_okl_service_line_id
                            );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END update_service_line;


------------------------------------------------------------------------------
-- PROCEDURE check_service_line_link
--
--  This procedure checks whether a service contract is linked to the lease
--  contract. It also looks for line level link.
--  If a link exists, the service contract information along with OKS service
--  line is returned back.
--  If no link exists, it returns NULL to service contract out variables.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_service_line_link (
                                p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                p_oks_service_line_id     IN  OKC_K_LINES_V.ID%TYPE,
                                x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS
  l_api_name    VARCHAR2(35)    := 'check_service_line_link';
  l_proc_name   VARCHAR2(35)    := 'CHECK_SERVICE_LINE_LINK';
  l_api_version CONSTANT NUMBER := 1;


  CURSOR link_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT object1_id1
  FROM   okc_k_rel_objs_v
  WHERE  chr_id   = p_chr_id
  AND    cle_id   IS NULL
  AND    rty_code = 'OKLSRV'; -- ???

  CURSOR line_link_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                       p_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT 'Y' answer
  FROM   okc_k_rel_objs_v
  WHERE  chr_id = p_chr_id
  AND    object1_id1 = p_line_id
  AND    jtot_object1_code = 'OKL_SERVICE_LINE';

  l_ret_val VARCHAR2(1) := '?';

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Cursor');
      END IF;
      x_service_contract_id := NULL;

      FOR link_rec IN link_csr(p_lease_contract_id)
      LOOP
        x_service_contract_id := link_rec.object1_id1;
      END LOOP;

      l_ret_val := '?';
      FOR line_link_rec IN line_link_csr(p_lease_contract_id,
                                         p_oks_service_line_id)
      LOOP
        l_ret_val := line_link_rec.answer;
      END LOOP;

      IF (l_ret_val = 'Y') THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_SERV_LINE_LINK_ERROR
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Cursor');
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END check_service_line_link;

------------------------------------------------------------------------------
-- PROCEDURE update_jtf_code
--
--  This procedure updates JTF code for header link on K_REL_OBJS
--  to OKL_SERVICE from OKL_SERVICE_CONNECTOR.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE update_jtf_code (
                              p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2,
                              p_okl_chr_id              IN  OKC_K_HEADERS_B.ID%TYPE,
                              p_oks_chr_id              IN  OKC_K_HEADERS_B.ID%TYPE,
                              p_jtf_code                IN  VARCHAR2
                            ) IS

  l_api_name    VARCHAR2(35)    := 'update_jtf_code';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_JTF_CODE';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR k_rel_csr (p_okl_chr_id OKC_K_HEADERS_B.ID%TYPE,
                    p_oks_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT id
  FROM   okc_k_rel_objs_v
  WHERE  chr_id            = p_okl_chr_id
  AND    object1_id1       = p_oks_chr_id
  AND    rty_code          = 'OKLSRV'
  AND    jtot_object1_code = 'OKL_SERVICE_CONNECTOR';

  l_rel_id OKC_K_REL_OBJS_V.ID%TYPE;

  l_crjv_rec crjv_rec_type;
  x_crjv_rec crjv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      l_rel_id := NULL;
      OPEN k_rel_csr (p_okl_chr_id,
                      p_oks_chr_id);
      FETCH k_rel_csr INTO l_rel_id;
      CLOSE k_rel_csr;

      IF (l_rel_id IS NOT NULL) THEN

         l_crjv_rec := NULL;
         l_crjv_rec.id                := l_rel_id;
         --l_crjv_rec.jtot_object1_code := p_jtf_code;

         OKC_K_REL_OBJS_PUB.DELETE_ROW(
                                    p_api_version    => p_api_version,
                                    p_init_msg_list  => OKL_API.G_FALSE,
                                    x_return_status  => x_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_crjv_rec       => l_crjv_rec
                                   );

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

         l_crjv_rec := NULL;
         l_crjv_rec.chr_id            := p_okl_chr_id;
         l_crjv_rec.rty_code          := 'OKLSRV';
         l_crjv_rec.object1_id1       := p_oks_chr_id;
         l_crjv_rec.object1_id2       := '#';
         l_crjv_rec.jtot_object1_code := 'OKL_SERVICE';


         OKC_K_REL_OBJS_PUB.create_row (
                                     p_api_version   => p_api_version,
                                     p_init_msg_list => OKC_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_crjv_rec      => l_crjv_rec,
                                     x_crjv_rec      => x_crjv_rec
                                    );

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

   END update_jtf_code;

------------------------------------------------------------------------------
-- PROCEDURE check_service_link
--
--  This procedure checks whether a service contract is linked to the lease
--  contract.
--  If a link exists, the service contract information is returned back.
--  If no link exists, it returns NULL to service contract out variables.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_service_link (
                                p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS
  l_api_name    VARCHAR2(35)    := 'check_service_link';
  l_proc_name   VARCHAR2(35)    := 'CHECK_SERVICE_LINK';
  l_api_version CONSTANT NUMBER := 1;


  CURSOR link_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT object1_id1
  FROM   okc_k_rel_objs_v
  WHERE  chr_id   = p_chr_id
  AND    cle_id   IS NULL
  AND    rty_code = 'OKLSRV'; -- ???

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Cursor');
      END IF;
      FOR link_rec IN link_csr(p_lease_contract_id)
      LOOP
        x_service_contract_id := link_rec.object1_id1;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Cursor');
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END check_service_link;

------------------------------------------------------------------------------
-- PROCEDURE get_service_link_line
--
--  This procedure returns linked lease and service contract top lines ID.
--  It also returns linked OKS service contract header id
--  Note: Service contract id will be NULL in case lease contract is not
--        linked to a service contract.
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE get_service_link_line (
                                   p_api_version             IN  NUMBER,
                                   p_init_msg_list           IN  VARCHAR2,
                                   x_return_status           OUT NOCOPY VARCHAR2,
                                   x_msg_count               OUT NOCOPY NUMBER,
                                   x_msg_data                OUT NOCOPY VARCHAR2,
                                   p_lease_contract_id       IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_link_line_tbl           OUT NOCOPY LINK_LINE_TBL_TYPE,
                                   x_service_contract_id     OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS
  l_api_name    VARCHAR2(35)    := 'get_service_link_line';
  l_proc_name   VARCHAR2(35)    := 'GET_SREVICE_LINK_LINE';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR link_csr (p_okl_chr_id OKC_K_HEADERS_V.ID%TYPE) IS

  SELECT cle_id,
         object1_id1
  FROM   okc_k_rel_objs_v
  WHERE  chr_id = p_okl_chr_id
  AND    cle_id IS NOT NULL
  AND    rty_code = 'OKLSRV'
  AND    jtot_object1_code = 'OKL_COV_PROD';

  link_count            NUMBER := 0;
  l_service_contract_id OKC_K_HEADERS_V.ID%TYPE;

  BEGIN

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

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      check_service_link (
                          p_api_version             => 1.0,
                          p_init_msg_list           => OKL_API.G_FALSE,
                          x_return_status           => x_return_status,
                          x_msg_count               => x_msg_count,
                          x_msg_data                => x_msg_data,
                          p_lease_contract_id       => p_lease_contract_id,
                          x_service_contract_id     => l_service_contract_id
                         );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_service_contract_id := l_service_contract_id;

      IF (x_service_contract_id IS NOT NULL) THEN

         link_count := 0;
         FOR link_rec IN link_csr (p_lease_contract_id)
         LOOP
            link_count := link_count + 1;
            x_link_line_tbl(link_count).okl_service_line_id := link_rec.cle_id;
            x_link_line_tbl(link_count).oks_service_line_id := link_rec.object1_id1;
         END LOOP;

      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END get_service_link_line;

------------------------------------------------------------------------------
-- PROCEDURE check_prod_instance
--
--  This procedure checks OKS Covered product install site and
--  raises error if the location is not defined as INSTALL_AT
--  Bug 3569441
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_prod_instance(
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                p_cov_prod      IN  VARCHAR2,
                                p_instance_id   IN  NUMBER
                               ) IS

  CURSOR csi_csr (p_instance_id NUMBER) IS
  SELECT install_location_id location_id,
         install_location_type_code location_type_code
  FROM   csi_item_instances
  WHERE  instance_id = p_instance_id;

  CURSOR hz_loc_csr (p_instance_id NUMBER) IS -- for location type = 'HZ_LOCATIONS'
  SELECT csi.install_location_id
  FROM   csi_item_instances csi,
         hz_locations hl
  WHERE  install_location_type_code   = 'HZ_LOCATIONS'
  AND    csi.owner_party_source_table = 'HZ_PARTIES'
  AND    hl.location_id = csi.install_location_id
  AND    NOT EXISTS (SELECT 1
                     FROM  hz_party_sites hps,
                           hz_party_site_uses hpsu
                     WHERE hps.location_id     = hl.location_id
                     AND   hps.party_id        = csi.owner_party_id
                     AND   hpsu.party_site_id  = hps.party_site_id
                     AND   hpsu.site_use_type  = 'INSTALL_AT'
                     AND   NVL(hpsu.status,'X') = 'A'
                     )
  AND    csi.instance_id = p_instance_id;

  CURSOR hz_party_site_csr (p_instance_id NUMBER) IS -- for location type = 'HZ_PARTY_SITES'
  SELECT hps.location_id
  FROM   csi_item_instances csi,
         hz_party_sites     hps
  WHERE  install_location_type_code   = 'HZ_PARTY_SITES'
  AND    csi.owner_party_source_table = 'HZ_PARTIES'
  AND    csi.install_location_id      =  hps.party_site_id
  AND    csi.owner_party_id           =  hps.party_id
  AND    NOT EXISTS (SELECT 1
                     FROM   hz_party_site_uses hpsu
                     WHERE  hpsu.party_site_id  = hps.party_site_id
                     AND    hpsu.site_use_type  = 'INSTALL_AT'
                     AND    NVL(hpsu.status, 'X') = 'A'
                     )
  AND    csi.instance_id = p_instance_id;

  CURSOR loc_detail_csr (p_location_id NUMBER) IS
  SELECT
     substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3,
     hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,null,
     null,null,null,null,null,null,'n','n',80,1,1),1,80) loc_address
  FROM   hz_locations hl
  WHERE  hl.location_id = p_location_id;

  l_api_name  VARCHAR2(35) := 'check_prod_instance';
  l_proc_name VARCHAR2(35) := 'CHECK_PROD_INSTANCE';

  l_location_id        CSI_ITEM_INSTANCES.LOCATION_ID%TYPE;
  l_location_type_code CSI_ITEM_INSTANCES.LOCATION_TYPE_CODE%TYPE;
  l_hz_Loc_id          HZ_LOCATIONS.location_id%TYPE;

  instance_failed      EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    OPEN csi_csr (p_instance_id);
    FETCH csi_csr INTO l_location_id,
                       l_location_type_code;
    IF csi_csr%NOTFOUND THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    CLOSE csi_csr;

    IF (l_location_type_code = 'HZ_LOCATIONS') THEN
       OPEN hz_loc_csr (p_instance_id);
       FETCH hz_loc_csr INTO l_hz_loc_id;
       IF hz_loc_csr%FOUND THEN
          -- Raise Error
          x_return_status := OKL_API.G_RET_STS_ERROR;

          FOR loc_addr_rec IN loc_detail_csr (l_hz_loc_id)
          LOOP
            okl_api.set_message(
                                G_APP_NAME,
                                G_LLA_SRV_PROD_INST,
                                'COV_PROD',
                                p_cov_prod,
                                'LOC_ADDR',
                                loc_addr_rec.loc_address
                               );

          END LOOP;
          RAISE instance_failed;
       END IF;
       CLOSE hz_loc_csr;
    ELSIF (l_location_type_code = 'HZ_PARTY_SITES') THEN
       OPEN hz_party_site_csr (p_instance_id);
       FETCH hz_party_site_csr INTO l_hz_loc_id;
       IF hz_party_site_csr%FOUND THEN
          -- Raise Error
          x_return_status := OKL_API.G_RET_STS_ERROR;
          FOR loc_addr_rec IN loc_detail_csr (l_hz_loc_id)
          LOOP
            okl_api.set_message(
                                G_APP_NAME,
                                G_LLA_SRV_PROD_INST,
                                'COV_PROD',
                                p_cov_prod,
                                'LOC_ADDR',
                                loc_addr_rec.loc_address
                               );

          END LOOP;
          RAISE instance_failed;
       END IF;
       CLOSE hz_party_site_csr;
    ELSE
       -- Invalid location type error
       x_return_status := OKL_API.G_RET_STS_ERROR;
       okl_api.set_message(
                           G_APP_NAME,
                           G_LLA_SRV_LOC_TYPE,
                           'COV_PROD',
                           p_cov_prod,
                           'LOC_TYPE',
                           l_location_type_code
                          );

       RAISE instance_failed;
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN instance_failed THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

      IF csi_csr%ISOPEN THEN
        CLOSE csi_csr;
      END IF;

      IF hz_loc_csr%ISOPEN THEN
        CLOSE hz_loc_csr;
      END IF;

      IF hz_party_site_csr%ISOPEN THEN
        CLOSE hz_party_site_csr;
      END IF;

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

  END check_prod_instance;

------------------------------------------------------------------------------
-- PROCEDURE create_cov_line_link
--
--  This procedure creates link between OKL service sub-line and OKS covered
--  product line.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_cov_line_link(
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_okl_chr_id      IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_okl_cov_line_id IN  OKC_K_LINES_V.ID%TYPE,
                                 p_oks_cov_line_id IN  OKC_K_LINES_V.ID%TYPE
                                ) IS

  l_proc_name   VARCHAR2(35)    := 'CREATE_COV_LINE_LINK';

  CURSOR cov_link_csr (p_okl_line_id OKC_K_LINES_V.ID%TYPE,
                     p_oks_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT ID
  FROM   okc_k_rel_objs_v
  WHERE  cle_id = p_okl_line_id
  AND    object1_id1 = p_oks_line_id
  AND    jtot_object1_code = 'OKL_COV_PROD'
  AND    rty_code = 'OKLSRV';

  l_link_id OKC_K_REL_OBJS_V.ID%TYPE;
  l_crjv_rec crjv_rec_type;
  x_crjv_rec crjv_rec_type;
  cov_link_error EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    OPEN cov_link_csr (p_okl_cov_line_id,
                       p_oks_cov_line_id);
    FETCH cov_link_csr INTO l_link_id;
    IF cov_link_csr%NOTFOUND THEN
       -- Create a link
       l_crjv_rec := NULL;
       l_crjv_rec.chr_id            := p_okl_chr_id;
       l_crjv_rec.cle_id            := p_okl_cov_line_id;
       l_crjv_rec.rty_code          := 'OKLSRV';
       l_crjv_rec.object1_id1       := p_oks_cov_line_id;
       l_crjv_rec.object1_id2       := '#';
       l_crjv_rec.jtot_object1_code := 'OKL_COV_PROD';

       OKC_K_REL_OBJS_PUB.create_row (
                                      p_api_version => 1.0,
                                      p_init_msg_list => OKC_API.G_FALSE,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_crjv_rec      => l_crjv_rec,
                                      x_crjv_rec      => x_crjv_rec
                                     );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE cov_link_error;
       END IF;
    ELSE
       -- update the link, i.e. delete and create the link
       l_crjv_rec.id := l_link_id;
       OKC_K_REL_OBJS_PUB.delete_row (
                                      p_api_version   => 1.0,
                                      p_init_msg_list => OKL_API.G_FALSE,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_crjv_rec      => l_crjv_rec
                                     );
       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE cov_link_error;
       END IF;

       l_crjv_rec := NULL;
       l_crjv_rec.chr_id            := p_okl_chr_id;
       l_crjv_rec.cle_id            := p_okl_cov_line_id;
       l_crjv_rec.rty_code          := 'OKLSRV';
       l_crjv_rec.object1_id1       := p_oks_cov_line_id;
       l_crjv_rec.object1_id2       := '#';
       l_crjv_rec.jtot_object1_code := 'OKL_COV_PROD';

       OKC_K_REL_OBJS_PUB.create_row (
                                      p_api_version => 1.0,
                                      p_init_msg_list => OKC_API.G_FALSE,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_crjv_rec      => l_crjv_rec,
                                      x_crjv_rec      => x_crjv_rec
                                     );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE cov_link_error;
       END IF;
    END IF;

  EXCEPTION
    WHEN cov_link_error THEN
      RETURN; -- handle error in calling block
  END create_cov_line_link;

------------------------------------------------------------------------------
-- PROCEDURE create_cov_asset_line
--
--  This procedure validates covered asset and creates covered asset line
--  under OKL service top line.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
 PROCEDURE create_cov_asset_line(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_tbl       IN  clev_tbl_type,
                                 p_klev_tbl       IN  klev_tbl_type,
                                 p_cimv_tbl       IN  cimv_tbl_type,
                                 p_cov_tbl        IN  srv_cov_tbl_type,
                                 x_clev_tbl       OUT NOCOPY clev_tbl_type,
                                 x_klev_tbl       OUT NOCOPY klev_tbl_type,
                                 x_cimv_tbl       OUT NOCOPY cimv_tbl_type
                                ) IS
  l_api_name    VARCHAR2(35)    := 'create_cov_asset_line';
  l_proc_name   VARCHAR2(35)    := 'CREATE_COV_ASSET_LINE';
  l_api_version CONSTANT NUMBER := 1;


  CURSOR cov_csr (p_chr_id     OKC_K_HEADERS_V.ID%TYPE,
                  p_srv_top_id OKC_K_LINES_V.ID%TYPE,
                  p_asset      OKL_LA_COV_ASSET_UV.NAME%TYPE) IS
  SELECT 'Y',
         item_description,
         srv_prod_instance_id
  FROM   okl_la_cov_asset_uv
  WHERE  chr_id           = p_chr_id
  AND    serv_top_line_id = p_srv_top_id
  AND    name             = p_asset;

  l_ok               VARCHAR2(1);
  l_instance_id      OKL_LA_COV_ASSET_UV.srv_prod_instance_id%TYPE;
  l_item_description OKL_LA_COV_ASSET_UV.item_description%TYPE;

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      FOR i IN 1..p_clev_tbl.COUNT
      LOOP
         l_ok := '?';
         OPEN cov_csr (p_clev_tbl(i).dnz_chr_id,
                       p_clev_tbl(i).cle_id,
                       p_clev_tbl(i).name);

         FETCH cov_csr INTO l_ok,
                            l_item_description,
                            l_instance_id;
         CLOSE cov_csr;

         IF (l_ok <> 'Y') THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_LLA_COV_ASSET_ERROR,
                                'ASSET_NUMBER',
                                p_clev_tbl(i).name
                               );
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         --
         -- Check OKS Covered product Install site, for linked like only
         -- raise error if it is not defined as INSTALL_AT
         -- Bug 3569441
         --
         IF (l_instance_id IS NOT NULL) THEN -- it is a linked service line
            check_prod_instance(
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_cov_prod      => l_item_description,
                                p_instance_id   => l_instance_id
                               );

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;

      END LOOP;

      -- Create Covered Asset Line
      OKL_CONTRACT_LINE_ITEM_PUB.CREATE_CONTRACT_LINE_ITEM (
                              p_api_version    => p_api_version,
                              p_init_msg_list  => OKL_API.G_FALSE,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_clev_tbl       => p_clev_tbl,
                              p_klev_tbl       => p_klev_tbl,
                              p_cimv_tbl       => p_cimv_tbl,
                              x_clev_tbl       => x_clev_tbl,
                              x_klev_tbl       => x_klev_tbl,
                              x_cimv_tbl       => x_cimv_tbl
                             );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --
      -- Create Covered Line Link
      --
      FOR i IN 1..p_cov_tbl.COUNT
      LOOP

        IF (p_cov_tbl(i).oks_cov_prod_line_id IS NOT NULL) THEN
           create_cov_line_link(
                                x_return_status   => x_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_okl_chr_id      => x_clev_tbl(i).dnz_chr_id,
                                p_okl_cov_line_id => x_clev_tbl(i).id,
                                p_oks_cov_line_id => p_cov_tbl(i).oks_cov_prod_line_id
                               );

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
               raise OKC_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;
      END LOOP;


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

  END create_cov_asset_line;

------------------------------------------------------------------------------
-- PROCEDURE update_cov_asset_line
--
--  This procedure validates covered asset and updates covered asset line
--  under OKL service top line.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
 PROCEDURE update_cov_asset_line(
                                 p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_tbl       IN  clev_tbl_type,
                                 p_klev_tbl       IN  klev_tbl_type,
                                 p_cimv_tbl       IN  cimv_tbl_type,
                                 p_cov_tbl        IN  srv_cov_tbl_type,
                                 x_clev_tbl       OUT NOCOPY clev_tbl_type,
                                 x_klev_tbl       OUT NOCOPY klev_tbl_type,
                                 x_cimv_tbl       OUT NOCOPY cimv_tbl_type
                                ) IS
  l_api_name    VARCHAR2(35)    := 'update_cov_asset_line';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_COV_ASSET_LINE';
  l_api_version CONSTANT NUMBER := 1;


  CURSOR cov_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                  p_srv_top_id OKC_K_LINES_V.ID%TYPE,
                  p_asset      OKL_LA_COV_ASSET_UV.NAME%TYPE) IS
  SELECT 'Y'
  FROM   okl_la_cov_asset_uv
  WHERE  chr_id           = p_chr_id
  AND    serv_top_line_id = p_srv_top_id
  AND    name             = p_asset;

  l_ok   VARCHAR2(1);

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
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

      FOR i IN 1..p_clev_tbl.COUNT
      LOOP
         l_ok := '?';
         OPEN cov_csr (p_clev_tbl(i).dnz_chr_id,
                       p_clev_tbl(i).cle_id,
                       p_clev_tbl(i).name);

         FETCH cov_csr INTO l_ok;
         CLOSE cov_csr;

         IF (l_ok <> 'Y') THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_LLA_COV_ASSET_ERROR,
                                'ASSET_NUMBER',
                                p_clev_tbl(i).name
                               );
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END LOOP;

      -- Create Covered Asset Line
      OKL_CONTRACT_LINE_ITEM_PUB.UPDATE_CONTRACT_LINE_ITEM (
                              p_api_version    => p_api_version,
                              p_init_msg_list  => OKL_API.G_FALSE,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_clev_tbl       => p_clev_tbl,
                              p_klev_tbl       => p_klev_tbl,
                              p_cimv_tbl       => p_cimv_tbl,
                              x_clev_tbl       => x_clev_tbl,
                              x_klev_tbl       => x_klev_tbl,
                              x_cimv_tbl       => x_cimv_tbl
                             );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --
      -- Update Covered Line Link
      --
      FOR i IN 1..p_cov_tbl.COUNT
      LOOP
        IF (p_cov_tbl(i).oks_cov_prod_line_id IS NOT NULL) THEN
           create_cov_line_link(
                                x_return_status   => x_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_okl_chr_id      => x_clev_tbl(i).dnz_chr_id,
                                p_okl_cov_line_id => x_clev_tbl(i).id,
                                p_oks_cov_line_id => p_cov_tbl(i).oks_cov_prod_line_id
                               );

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
               raise OKC_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
      END LOOP;

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

  END update_cov_asset_line;

------------------------------------------------------------------------------
-- PROCEDURE update_oks_ar_intf
--
--  This procedure updates OKS AR Interface flag.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE update_oks_ar_intf(
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_oks_chr_id    IN  OKC_K_HEADERS_B.ID%TYPE,
                               p_ar_intf_val   IN  VARCHAR2
                              )IS

  l_api_name    VARCHAR2(35)    := 'update_oks_arintf';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_OKS_ARINTF';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR arintf_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT rule.id
  FROM   okc_rules_v rule,
         okc_rule_groups_v rg
  WHERE  rule.rgp_id = rg.id
  AND    rule.rule_information_category = 'SBG'
  AND    rule.jtot_object1_code = 'OKS_TRXTYPE'
  AND    rg.chr_id = p_chr_id;

  p_rulv_rec OKC_RULE_PUB.RULV_REC_TYPE;
  x_rulv_rec OKC_RULE_PUB.RULV_REC_TYPE;

  l_arintf_rule_id OKC_RULES_V.ID%TYPE;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN arintf_csr(p_oks_chr_id);
    FETCH arintf_csr INTO l_arintf_rule_id;
    CLOSE arintf_csr;

    --dbms_output.put_line('Rule id: '||l_arintf_rule_id);

    IF (l_arintf_rule_id IS NOT NULL) THEN

       p_rulv_rec.id                 := l_arintf_rule_id;
       p_rulv_rec.rule_information11 := p_ar_intf_val;

       okc_rule_pub.update_rule(
                                p_api_version      => 1.0,
                                p_init_msg_list    => OKL_API.G_TRUE,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_rulv_rec         => p_rulv_rec,
                                x_rulv_rec         => x_rulv_rec
                               );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;

    END IF;

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;

  END update_oks_ar_intf;


------------------------------------------------------------------------------
-- PROCEDURE initiate_service_booking
--
--  This procedure is being called from activate API. It checks for service
--  link and associates IB instances from OKS service line with
--  corresponding IB line instances at lease contract.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE initiate_service_booking(
                                    p_api_version    IN  NUMBER,
                                    p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id     IN  OKC_K_HEADERS_B.ID%TYPE
                                ) IS
  l_api_name    VARCHAR2(35)    := 'initiate_service_booking';
  l_proc_name   VARCHAR2(35)    := 'INITIATE_SERVICE_BOOKING';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR ib_csr (p_okl_chr_id      OKC_K_HEADERS_B.ID%TYPE,
                 p_okl_cov_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT ib_line.id,
         ib_item.id,
         ib_item.object1_id1,
         ib_item.object1_id2
  FROM   okc_k_lines_b ib_line,
         okc_line_styles_b ib_style,
         okc_k_items ib_item,
         okc_k_lines_b cov_line,
         okc_k_items cov_item,
         okc_k_lines_b inst_line,
         okc_line_styles_b inst_style,
         okc_k_rel_objs rel
  WHERE  rel.cle_id = cov_line.id
  AND    rel.chr_id = cov_line.dnz_chr_id
  AND    cov_line.id = cov_item.cle_id
  AND    cov_line.dnz_chr_id = rel.chr_id
  AND    cov_item.object1_id1 = inst_line.cle_id
  AND    cov_item.jtot_object1_code = 'OKX_COVASST'
  AND    inst_style.lty_code = 'FREE_FORM2'
  AND    inst_line.lse_id = inst_style.id
  AND    inst_line.id = ib_line.cle_id
  AND    inst_line.dnz_chr_id = ib_line.dnz_chr_id
  AND    ib_line.lse_id = ib_style.id
  AND    ib_style.lty_code = 'INST_ITEM'
  AND    ib_line.id = ib_item.cle_id
  AND    ib_item.dnz_chr_id = ib_line.dnz_chr_id
  AND    ib_item.jtot_object1_code = 'OKX_IB_ITEM'
  AND    rel.cle_id = p_okl_cov_line_id
  AND    rel.chr_id = p_okl_chr_id
  AND    ib_item.object1_id1 IS NULL
  AND    ROWNUM < 2; -- to ensure first line with null instance_id

  CURSOR oks_ib_csr (p_oks_chr_id OKC_K_HEADERS_B.ID%TYPE,
                     p_oks_cov_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT object1_id1,
         object1_id2
  FROM   okc_k_items
  WHERE  cle_id     = p_oks_cov_line_id
  AND    dnz_chr_id = p_oks_chr_id;
  --AND    chr_id = p_oks_chr_id;
  -- don't use chr_id, use dnz_chr_id instead Bug# 2739831

  CURSOR inst_csr (p_chr_id NUMBER) IS
  SELECT
        csi.instance_id,
        csi.inventory_item_id,
        csi.inv_master_organization_id,
        csi.install_location_id location_id,
        csi.install_location_type_code location_type_code,
        csi.instance_number
  FROM  okc_k_rel_objs krel,
        okc_k_items kitem,
        csi_item_instances csi,
        okc_k_lines_b line,
        okc_line_styles_b style,
        OKC_STATUSES_B sts
  WHERE krel.rty_code               = 'OKLSRV'
  AND   krel.jtot_object1_code      = 'OKL_COV_PROD'
  AND   kitem.cle_id                = krel.object1_id1
  AND   kitem.jtot_object1_code     = 'OKX_CUSTPROD'
  AND   csi.instance_id             = kitem.object1_id1
  AND   krel.cle_id                 = line.id
  AND   line.lse_id                 = style.id
  AND   style.lty_code              = 'LINK_SERV_ASSET'
  AND   line.dnz_chr_id             = p_chr_id
  AND   sts.code                    = line.sts_code
  AND   sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  CURSOR mtl_csr (p_inv_id NUMBER,
                  p_org_id NUMBER) IS
  SELECT description
  FROM   mtl_system_items
  WHERE  inventory_item_id = p_inv_id
  AND    organization_id   = p_org_id;

  l_oks_chr_id     OKC_K_HEADERS_B.ID%TYPE;
  l_link_line_tbl  OKL_SERVICE_INTEGRATION_PUB.link_line_tbl_type;
  l_cimv_rec       okc_contract_item_pub.cimv_rec_type;
  x_cimv_rec       okc_contract_item_pub.cimv_rec_type;
  l_ib_line_id     OKC_K_LINES_B.ID%TYPE;
  l_ib_item_id     OKC_K_ITEMS_V.ID%TYPE;
  l_ib_object1_id1 OKC_K_ITEMS_V.OBJECT1_ID1%TYPE;
  l_ib_object1_id2 OKC_K_ITEMS_V.OBJECT1_ID2%TYPE;

  l_oks_object1_id1 OKC_K_ITEMS_V.OBJECT1_ID1%TYPE;
  l_oks_object1_id2 OKC_K_ITEMS_V.OBJECT1_ID2%TYPE;

  l_item_desc       OKL_LA_COV_ASSET_UV.item_description%TYPE;

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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
      --************************************************
      check_service_link(
                         p_api_version             => 1.0,
                         p_init_msg_list           => OKL_API.G_FALSE,
                         x_return_status           => x_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data,
                         p_lease_contract_id       => p_okl_chr_id,
                         x_service_contract_id     => l_oks_chr_id
                        );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Service contract ID: '||l_oks_chr_id);
      END IF;

      IF (l_oks_chr_id IS NOT NULL) THEN -- Service line is linked to OKS Contract

         --
         -- Check OKS Covered product Install site,
         -- raise error if it is not defined as INSTALL_AT
         -- Bug 3569441
         --
         FOR inst_rec IN inst_csr (p_okl_chr_id)
         LOOP
            OPEN mtl_csr (inst_rec.inventory_item_id,
                          inst_rec.inv_master_organization_id);
            FETCH mtl_csr INTO l_item_desc;
            CLOSE mtl_csr;

            check_prod_instance(
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_cov_prod       => l_item_desc,
                                p_instance_id    => inst_rec.instance_id
                               );

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
               raise OKC_API.G_EXCEPTION_ERROR;
            END IF;

         END LOOP;

           --
           -- Update JTOT_OBJECT1_CODE to 'OKL_SERVICE'
           -- Fix Bug# 2872267
           --
           update_jtf_code(
                           p_api_version   => 1.0,
                           p_init_msg_list => OKL_API.G_FALSE,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_okl_chr_id    => p_okl_chr_id,
                           p_oks_chr_id    => l_oks_chr_id,
                           p_jtf_code      => 'OKL_SERVICE'
                          );

           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;

           --
           -- set AR Interface flag to 'N' to stop billing
           -- Bug# 2776123
           --
/* Removed as this flag must remain as Y for OKS billing process to run
 * DEDEY - 02/15/2003

           update_oks_ar_intf(
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_oks_chr_id    => l_oks_chr_id,
                              p_ar_intf_val   => 'N'
                             );

           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
*/

           get_service_link_line (
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => OKL_API.G_FALSE,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_lease_contract_id       => p_okl_chr_id,
                                  x_link_line_tbl           => l_link_line_tbl,
                                  x_service_contract_id     => l_oks_chr_id
                                 );

         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         --dbms_output.put_line('Line Link count: '||l_link_line_tbl.COUNT);

         --
         -- Expire IB instance(s)
         --
         expire_lease_instance(
                               p_api_version             => 1.0,
                               p_init_msg_list           => OKL_API.G_FALSE,
                               x_return_status           => x_return_status,
                               x_msg_count               => x_msg_count,
                               x_msg_data                => x_msg_data,
                               p_okl_chr_id              => p_okl_chr_id
                              );

         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         FOR i IN 1..l_link_line_tbl.COUNT
         LOOP
           OPEN ib_csr (p_okl_chr_id,
                        l_link_line_tbl(i).okl_service_line_id);
           FETCH ib_csr INTO l_ib_line_id,
                             l_ib_item_id,
                             l_ib_object1_id1,
                             l_ib_object1_id2;
           CLOSE ib_csr;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'IB: '||l_ib_line_id||', '||l_ib_item_id||', '||l_ib_object1_id1);
           END IF;

           IF (l_ib_line_id IS NOT NULL
               AND
               l_ib_object1_id1 IS NULL) THEN
              OPEN oks_ib_csr (l_oks_chr_id,
                               l_link_line_tbl(i).oks_service_line_id);
              FETCH oks_ib_csr INTO l_oks_object1_id1,
                                    l_oks_object1_id2;
              CLOSE oks_ib_csr;

              --dbms_output.put_line('Instance : '||l_link_line_tbl(i).oks_service_line_id||' : '||l_oks_object1_id1);
              -- Update IB line
              l_cimv_rec.id          := l_ib_item_id;
              l_cimv_rec.object1_id1 := l_oks_object1_id1;  -- copy instance ID from OKS to IB line in OKL
              l_cimv_rec.object1_id2 := l_oks_object1_id2;


----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

          okl_la_validation_util_pvt.VALIDATE_STYLE_JTOT (p_api_version    => l_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => l_cimv_rec.jtot_object1_code,
                                                          p_id1            => l_cimv_rec.object1_id1,
                                                          p_id2            => l_cimv_rec.object1_id2);
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

----  Changes End


              okc_contract_item_pub.update_contract_item(
                                                         p_api_version	  => 1.0,
                                                         p_init_msg_list  => OKL_API.G_FALSE,
                                                         x_return_status  => x_return_status,
                                                         x_msg_count      => x_msg_count,
                                                         x_msg_data       => x_msg_data,
                                                         p_cimv_rec       => l_cimv_rec,
                                                         x_cimv_rec       => x_cimv_rec
                                                        );

              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;

           END IF;

         END LOOP;

      END IF;

      --************************************************

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

  END initiate_service_booking;

------------------------------------------------------------------------------
-- PROCEDURE process_serial_item
--
--  This procedure is used to create and attach service sub-line
--  for serialized inventory item. One service line in OKL might
--  be linked to multiple covered product line(s) in case of
--  serialized items attached to an asset/product.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE process_serial_item (
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_okl_chr_id      IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_free_form1_id   IN  OKC_K_LINES_V.ID%TYPE,
                                 p_okl_srv_line_id IN  OKC_K_LINES_V.ID%TYPE
                                ) IS

  l_proc_name VARCHAR2(35) := 'process_serial_item';

  CURSOR serial_csr (p_srv_line_id OKC_K_LINES_B.ID%TYPE,
                     p_asset_id    OKC_K_LINES_B.ID%TYPE) IS
  SELECT *
  FROM   okl_la_cov_asset_uv
  WHERE  serv_top_line_id = p_srv_line_id
  AND    id1 = p_asset_id
  AND    serial_number_control_code <> 1;

  TYPE cov_prod_rec IS RECORD (
     oks_cov_line_id  OKC_K_LINES_B.ID%TYPE,
     serv_top_line_id OKC_K_LINES_B.ID%TYPE
  );
  TYPE cov_prod_tbl IS TABLE OF cov_prod_rec
        INDEX BY BINARY_INTEGER;

  l_cov_prod_tbl cov_prod_tbl;
  l_srv_qty   NUMBER;
  l_lease_qty NUMBER;
  l_price_negotiated NUMBER;
  l_asset_number VARCHAR2(35);
  i NUMBER;
  j NUMBER;

  l_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  x_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_srv_qty   := 0;
    l_lease_qty := 0;
    i := 0;
    l_cov_prod_tbl.DELETE;
    l_price_negotiated := 0;
    FOR serial_rec IN serial_csr (p_okl_srv_line_id,
                                  p_free_form1_id)
    LOOP
       i := serial_csr%ROWCOUNT;
       l_srv_qty                          := l_srv_qty + serial_rec.service_item_qty;
       l_price_negotiated                 := l_price_negotiated + serial_rec.price_negotiated;
       l_cov_prod_tbl(i).oks_cov_line_id  := serial_rec.oks_cov_line_id;
       l_cov_prod_tbl(i).serv_top_line_id := serial_rec.serv_top_line_id;
       l_lease_qty                        := serial_rec.lease_item_qty;
       l_asset_number                     := serial_rec.name;
    END LOOP;

    j := 0;
    IF (l_lease_qty = l_srv_qty
        AND
        l_lease_qty <> 0
        AND
        l_srv_qty <> 0) THEN

        j := j + 1;
        l_line_item_tbl(1).chr_id            := p_okl_chr_id;
        l_line_item_tbl(1).parent_cle_id     := p_okl_srv_line_id;
        l_line_item_tbl(1).name              := l_asset_number;
        l_line_item_tbl(1).capital_amount    := l_price_negotiated;
        l_line_item_tbl(1).serv_cov_prd_id   := l_cov_prod_tbl(1).oks_cov_line_id;
        l_line_item_tbl(1).item_object1_code := 'OKX_COVASST';
        l_line_item_tbl(1).item_id1          := p_free_form1_id;
	l_line_item_tbl(1).item_id2          := '#';

        -- Call linked asset line creation api
        okl_contract_line_item_pub.create_contract_line_item(
                                                             p_api_version    => 1.0,
                                                             p_init_msg_list  => OKL_API.G_FALSE,
                                                             x_return_status  => x_return_status,
                                                             x_msg_count      => x_msg_count,
                                                             x_msg_data       => x_msg_data,
                                                             p_line_item_tbl  => l_line_item_tbl,
                                                             x_line_item_tbl  => x_line_item_tbl
                                                            );
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>After calling okl_contract_line_item_pub.create_contract_line_item');
        END IF;
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    -- 1st covered prod is being linked in previous call
    -- now link rest of the covered prod lines
    -- many-to-one relation between okl linked service line and
    -- oks covered prod line for serialized item
    FOR k IN 2..l_cov_prod_tbl.COUNT
    LOOP
      -- Link coverd product

      create_cov_line_link(
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_okl_chr_id      => p_okl_chr_id,
                           p_okl_cov_line_id => x_line_item_tbl(1).cle_id,
                           p_oks_cov_line_id => l_cov_prod_tbl(k).oks_cov_line_id
                          );

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END LOOP;

  END process_serial_item;

------------------------------------------------------------------------------
-- PROCEDURE create_service_from_oks
--
--  This procedure is used to create service link(s) and associate
--  assets on one go. Only input is OKS and OKL contract ID. This
--  process will look into OKS contract and create service line in OKL. It
--  also creates associations of assets in OKL.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_service_from_oks(
                                    p_api_version         IN  NUMBER,
                                    p_init_msg_list       IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                    p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                    p_supplier_id         IN  NUMBER,                  -- OKL_VENDOR
                                    p_sty_id              IN  OKL_K_LINES.STY_ID%TYPE DEFAULT NULL, -- Bug 4011710
                                    x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'create_service_from_oks';
  l_proc_name   VARCHAR2(35)    := 'CREATE_SERVICE_FROM_OKS';
  l_api_version CONSTANT NUMBER := 1;

  -- Check for 11.5.9 or 11.5.10 OKS version
  CURSOR check_oks_ver IS
  SELECT 1
  FROM   okc_class_operations
  WHERE  cls_code = 'SERVICE'
  AND    opn_code = 'CHECK_RULE';

  l_dummy NUMBER;
  l_oks_ver VARCHAR2(3);

  CURSOR oks_serv_csr (p_oks_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT DISTINCT cle_id
  FROM   okl_la_link_service_uv
  WHERE  chr_id = p_oks_chr_id;

  CURSOR oks_serv_csr9 (p_oks_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT DISTINCT cle_id
  FROM   okl_la_link_service_uv9
  WHERE  chr_id = p_oks_chr_id;

  CURSOR oks_cov_csr(p_oks_serv_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT line.id,
         line.price_negotiated
  FROM   okc_k_lines_b line,
         okc_line_styles_v style
  WHERE  line.lse_id = style.id
  AND    cle_id = p_oks_serv_id
  AND    lty_code = 'COVER_PROD'
  AND    NOT EXISTS (SELECT 'Y'
                     FROM   okc_k_rel_objs rel
                     WHERE  TO_CHAR(line.id)  = rel.object1_id1
                     AND    jtot_object1_code = 'OKL_COV_PROD'
                     AND    rty_code          = 'OKLSRV');     -- to pickup only non-linked lines

  CURSOR okl_asset_csr (p_oks_cov_line_id   OKC_K_LINES_V.ID%TYPE,
                        p_okl_serv_line_id  OKC_K_LINES_V.ID%TYPE) IS
  SELECT name,
         id1,
         id2 --,
         --lease_item_qty,
         --service_item_qty
  FROM   okl_la_cov_asset_uv cov_asset
  WHERE  oks_cov_line_id  = p_oks_cov_line_id
  AND    serv_top_line_id = p_okl_serv_line_id
  -- bug 4889070. START
  AND    lease_item_qty = service_item_qty
  -- bug 4889070. END
  AND    NOT EXISTS (SELECT 'Y'
                     FROM   okc_k_items cov_item,
                            okc_k_lines_b line
                     WHERE  cov_item.object1_id1       = cov_asset.id1
                     AND    cov_item.jtot_object1_code = 'OKX_COVASST'
                     AND    line.id = cov_item.cle_id
                     AND    line.id = cov_asset.serv_top_line_id
                     AND    line.sts_code <> 'ABANDONED');

  CURSOR check_serial_csr (p_okl_service_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT distinct id1
  FROM   okl_la_cov_asset_uv
  WHERE  serv_top_line_id = p_okl_service_id
  AND    serial_number_control_code <> 1; -- serial item

  l_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  x_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  i NUMBER := 0;
  l_asset_number okl_la_cov_asset_uv.name%TYPE;
  l_id1 okl_la_cov_asset_uv.id1%TYPE;
  l_id2 okl_la_cov_asset_uv.id2%TYPE;

  -- bug 4889070 commented local vars as they are no longer reqd
  -- l_lease_item_qty   NUMBER;
  -- l_service_item_qty NUMBER;

  x_tcnv_rec tcnv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      -- populate stream id to global stream id
      G_STY_ID := p_sty_id; -- Bug 4011710

      l_oks_ver := '?';
      OPEN check_oks_ver;
      FETCH check_oks_ver INTO l_dummy;
      IF check_oks_ver%NOTFOUND THEN
         l_oks_ver := '9';
      ELSE
         l_oks_ver := '10';
      END IF;
      CLOSE check_oks_ver;

      IF (l_oks_ver = '10') THEN -- 11.5.10 OKS code

      FOR oks_serv_rec IN oks_serv_csr(p_oks_chr_id)
      LOOP
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>Before calling create_link_service_line');
         END IF;
         create_link_service_line(
                                  p_api_version         => 1.0,
                                  p_init_msg_list       => OKL_API.G_FALSE,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
                                  p_okl_chr_id          => p_okl_chr_id,
                                  p_oks_chr_id          => p_oks_chr_id,
                                  p_oks_service_line_id => oks_serv_rec.cle_id,
                                  p_supplier_id         => p_supplier_id,
                                  x_okl_service_line_id => x_okl_service_line_id
                                 );
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>After calling create_link_service_line');
         END IF;

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

         --
         -- Create LINK transaction
         --
         okl_transaction_pvt.create_service_transaction(
                                                        p_api_version        => 1.0,
                                                        p_init_msg_list      => OKL_API.G_FALSE,
                                                        x_return_status      => x_return_status,
                                                        x_msg_count          => x_msg_count,
                                                        x_msg_data           => x_msg_data,
                                                        p_lease_id           => p_okl_chr_id,
                                                        p_service_id         => p_oks_chr_id,
                                                        p_description        => 'Link Service Contract',
                                                        p_trx_date           => SYSDATE,
                                                        p_status             => G_LINK,
                                                        x_tcnv_rec           => x_tcnv_rec
                                                       );


         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

         --
         -- Start Serial processing
         FOR check_serial_rec IN check_serial_csr (x_okl_service_line_id)
         LOOP
            process_serial_item (
                                 x_return_status   => x_return_status,
                                 x_msg_count       => x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 p_okl_chr_id      => p_okl_chr_id,
                                 p_free_form1_id   => check_serial_rec.id1,
                                 p_okl_srv_line_id => x_okl_service_line_id
                                );

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
               raise OKC_API.G_EXCEPTION_ERROR;
            END IF;

         END LOOP;
         -- End Serial processing

         i := 0;
         l_line_item_tbl.delete;
         FOR oks_cov_rec IN oks_cov_csr(oks_serv_rec.cle_id)
         LOOP

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKS COV LINE: '||oks_cov_rec.id);
           END IF;

           OPEN okl_asset_csr(oks_cov_rec.id,
                              x_okl_service_line_id
                             );
           FETCH okl_asset_csr INTO l_asset_number,
                                    l_id1,
                                    l_id2;
                                    -- l_lease_item_qty,
                                    -- l_service_item_qty;
           IF ( okl_asset_csr%NOTFOUND ) THEN
                -- bug 4889070 commented this quantity mismatch condn as it is included in the cursor
                -- OR l_lease_item_qty <> l_service_item_qty) THEN
              okl_api.set_message(
                                G_APP_NAME,
                                G_SRV_NO_ASSET_MATCH
                               );
              x_return_status := OKL_API.G_RET_STS_ERROR;
              raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

           CLOSE okl_asset_csr;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>Asset number: '||l_asset_number);
           END IF;

           i := i + 1;
           l_line_item_tbl(i).chr_id          := p_okl_chr_id;
           l_line_item_tbl(i).parent_cle_id   := x_okl_service_line_id;
           l_line_item_tbl(i).name            := l_asset_number;
           l_line_item_tbl(i).capital_amount  := oks_cov_rec.price_negotiated;
           l_line_item_tbl(i).serv_cov_prd_id := oks_cov_rec.id;
           l_line_item_tbl(i).item_object1_code := 'OKX_COVASST';
           l_line_item_tbl(i).item_id1          := l_id1;
	   l_line_item_tbl(i).item_id2          := l_id2;

         END LOOP;

         IF (i > 0) THEN -- Covered line found
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>Before calling okl_contract_line_item_pub.create_contract_line_item');
           END IF;
           okl_contract_line_item_pub.create_contract_line_item(
                                                                p_api_version    => 1.0,
                                                                p_init_msg_list  => OKL_API.G_FALSE,
                                                                x_return_status  => x_return_status,
                                                                x_msg_count      => x_msg_count,
                                                                x_msg_data       => x_msg_data,
                                                                p_line_item_tbl  => l_line_item_tbl,
                                                                x_line_item_tbl  => x_line_item_tbl
                                                               );
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>After calling okl_contract_line_item_pub.create_contract_line_item');
           END IF;
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
              raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
              raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

         END IF;

      END LOOP;  --oks_serv_csr 11.5.10

      ELSE -- 11.5.9 code

      FOR oks_serv_rec IN oks_serv_csr9(p_oks_chr_id)
      LOOP
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>Before calling create_link_service_line');
         END IF;
         create_link_service_line(
                                  p_api_version         => 1.0,
                                  p_init_msg_list       => OKL_API.G_FALSE,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
                                  p_okl_chr_id          => p_okl_chr_id,
                                  p_oks_chr_id          => p_oks_chr_id,
                                  p_oks_service_line_id => oks_serv_rec.cle_id,
                                  p_supplier_id         => p_supplier_id,
                                  x_okl_service_line_id => x_okl_service_line_id
                                 );
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>After calling create_link_service_line');
         END IF;

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

         --
         -- Create LINK transaction
         --
         okl_transaction_pvt.create_service_transaction(
                                                        p_api_version        => 1.0,
                                                        p_init_msg_list      => OKL_API.G_FALSE,
                                                        x_return_status      => x_return_status,
                                                        x_msg_count          => x_msg_count,
                                                        x_msg_data           => x_msg_data,
                                                        p_lease_id           => p_okl_chr_id,
                                                        p_service_id         => p_oks_chr_id,
                                                        p_description        => 'Link Service Contract',
                                                        p_trx_date           => SYSDATE,
                                                        p_status             => G_LINK,
                                                        x_tcnv_rec           => x_tcnv_rec
                                                       );


         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

         --
         -- Start Serial processing
         FOR check_serial_rec IN check_serial_csr (x_okl_service_line_id)
         LOOP
            process_serial_item (
                                 x_return_status   => x_return_status,
                                 x_msg_count       => x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 p_okl_chr_id      => p_okl_chr_id,
                                 p_free_form1_id   => check_serial_rec.id1,
                                 p_okl_srv_line_id => x_okl_service_line_id
                                );

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
               raise OKC_API.G_EXCEPTION_ERROR;
            END IF;

         END LOOP;
         -- End Serial processing

         i := 0;
         l_line_item_tbl.delete;
         FOR oks_cov_rec IN oks_cov_csr(oks_serv_rec.cle_id)
         LOOP

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKS COV LINE: '||oks_cov_rec.id);
           END IF;

           OPEN okl_asset_csr(oks_cov_rec.id,
                              x_okl_service_line_id
                             );
           FETCH okl_asset_csr INTO l_asset_number,
                                    l_id1,
                                    l_id2;
                                    --l_lease_item_qty,
                                    --l_service_item_qty;
           IF ( okl_asset_csr%NOTFOUND) THEN
                -- bug 4889070 commented this quantity mismatch condn as it is included in the cursor
                -- OR l_lease_item_qty <> l_service_item_qty) THEN

              okl_api.set_message(
                                G_APP_NAME,
                                G_SRV_NO_ASSET_MATCH
                               );
              x_return_status := OKL_API.G_RET_STS_ERROR;
              raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

           CLOSE okl_asset_csr;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>Asset number: '||l_asset_number);
           END IF;

           i := i + 1;
           l_line_item_tbl(i).chr_id          := p_okl_chr_id;
           l_line_item_tbl(i).parent_cle_id   := x_okl_service_line_id;
           l_line_item_tbl(i).name            := l_asset_number;
           l_line_item_tbl(i).capital_amount  := oks_cov_rec.price_negotiated;
           l_line_item_tbl(i).serv_cov_prd_id := oks_cov_rec.id;
           l_line_item_tbl(i).item_object1_code := 'OKX_COVASST';
           l_line_item_tbl(i).item_id1          := l_id1;
	   l_line_item_tbl(i).item_id2          := l_id2;

         END LOOP;

         IF (i > 0) THEN -- Covered line found
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>Before calling okl_contract_line_item_pub.create_contract_line_item');
           END IF;
           okl_contract_line_item_pub.create_contract_line_item(
                                                                p_api_version    => 1.0,
                                                                p_init_msg_list  => OKL_API.G_FALSE,
                                                                x_return_status  => x_return_status,
                                                                x_msg_count      => x_msg_count,
                                                                x_msg_data       => x_msg_data,
                                                                p_line_item_tbl  => l_line_item_tbl,
                                                                x_line_item_tbl  => x_line_item_tbl
                                                               );
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===>After calling okl_contract_line_item_pub.create_contract_line_item');
           END IF;
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
              raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
              raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

         END IF;

      END LOOP;  --oks_serv_csr 11.5.9
      END IF; -- l_oks_ver
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION

      when OKC_API.G_EXCEPTION_ERROR then
         IF (okl_asset_csr%ISOPEN) THEN
            CLOSE okl_asset_csr;
         END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         IF (okl_asset_csr%ISOPEN) THEN
            CLOSE okl_asset_csr;
         END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         IF (okl_asset_csr%ISOPEN) THEN
            CLOSE okl_asset_csr;
         END IF;

         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_service_from_oks;

------------------------------------------------------------------------------
-- PROCEDURE delink_service_contract
--
--  This procedure delinks service contract from lease. It also updates
--  de-linked service line status to ABANDONED in lease
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE delink_service_contract(
                                    p_api_version         IN  NUMBER,
                                    p_init_msg_list       IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE
                                   ) IS
  l_api_name    VARCHAR2(35)    := 'delink_service_contract';
  l_proc_name   VARCHAR2(35)    := 'DELINK_SERVICE_CONTRACT';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR rel_link_csr(p_okl_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id,
         object1_id1,
         cle_id
  FROM   okc_k_rel_objs_v
  WHERE  chr_id   = p_okl_chr_id
  AND    rty_code = 'OKLSRV';

  l_service_contract_id OKC_K_HEADERS_V.ID%TYPE;
  l_crjv_tbl            crjv_tbl_type;
  i                     NUMBER;
  j                     NUMBER;

  l_clev_tbl clev_tbl_type;
  x_clev_tbl clev_tbl_type;
  l_klev_tbl klev_tbl_type;
  x_klev_tbl klev_tbl_type;

  l_oks_chr_id OKC_K_HEADERS_V.ID%TYPE;
  x_tcnv_rec tcnv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      i := 0;
      j := 0;
      l_clev_tbl.DELETE;
      l_klev_tbl.DELETE;

      FOR rel_rec IN rel_link_csr (p_okl_chr_id)
      LOOP
         i := rel_link_csr%ROWCOUNT;
         l_crjv_tbl(i).id := rel_rec.id;

         IF (rel_rec.cle_id IS NOT NULL) THEN
            j := j + 1;
            l_clev_tbl(j).id := rel_rec.cle_id;
            l_klev_tbl(j).id := rel_rec.cle_id;
            l_clev_tbl(j).sts_code := 'ABANDONED';
         ELSE
            l_oks_chr_id := TO_NUMBER(rel_rec.object1_id1);
         END IF;

      END LOOP;

      IF (i = 0) THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'No Serviec contract is linked to the lease contract');
         END IF;
         RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSE

         --
         -- Create DE-LINK transaction
         --
         okl_transaction_pvt.create_service_transaction(
                                                        p_api_version        => 1.0,
                                                        p_init_msg_list      => OKL_API.G_FALSE,
                                                        x_return_status      => x_return_status,
                                                        x_msg_count          => x_msg_count,
                                                        x_msg_data           => x_msg_data,
                                                        p_lease_id           => p_okl_chr_id,
                                                        p_service_id         => l_oks_chr_id,
                                                        p_description        => 'De-Link Service Contract',
                                                        p_trx_date           => SYSDATE,
                                                        p_status             => G_DELINK,
                                                        x_tcnv_rec           => x_tcnv_rec
                                                       );


         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END IF;

      OKC_K_REL_OBJS_PUB.delete_row (
                                     p_api_version   => p_api_version,
                                     p_init_msg_list => OKL_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_crjv_tbl      => l_crjv_tbl
                                    );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'De-linked...');
      END IF;
      --
      -- ABANDON the de-linked service line in OKL
      --
      okl_contract_pub.update_contract_line(
                                            p_api_version   => p_api_version,
                                            p_init_msg_list => OKL_API.G_FALSE,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_clev_tbl      => l_clev_tbl,
                                            p_klev_tbl      => l_klev_tbl,
                                            x_clev_tbl      => x_clev_tbl,
                                            x_klev_tbl      => x_klev_tbl
                                           );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error: '||x_msg_data);
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Abandoned...');
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END delink_service_contract;

------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_trx_rec
  --Purpose               : Gets source transaction record for IB interface
  --Modification History  :
  --15-Jun-2001    ashish.singh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_trx_rec
    (p_api_version                  IN  NUMBER,
	 p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status                OUT NOCOPY VARCHAR2,
	 x_msg_count                    OUT NOCOPY NUMBER,
	 x_msg_data                     OUT NOCOPY VARCHAR2,
     p_cle_id                       IN  NUMBER,
     p_transaction_type             IN  VARCHAR2,
     x_trx_rec                      OUT NOCOPY CSI_DATASTRUCTURES_PUB.transaction_rec) is

     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_TRX_REC';
     l_api_version	     CONSTANT NUMBER	:= 1.0;

--Following cursor assumes that a transaction type called
--'OKL_BOOK'  will be seeded in IB
     Cursor okl_trx_type_csr(p_transaction_type IN VARCHAR2)is
            select transaction_type_id
            from   CSI_TXN_TYPES
            where  source_transaction_type = p_transaction_type;
     l_trx_type_id NUMBER;
 Begin
     open okl_trx_type_csr(p_transaction_type);
        Fetch okl_trx_type_csr
        into  l_trx_type_id;
        If okl_trx_type_csr%NotFound Then
           --OKL LINE ACTIVATION not seeded as a source transaction in IB
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_IB_TXN_TYPE_NOT_FOUND,
				               p_token1       => G_TXN_TYPE_TOKEN,
				               p_token1_value => p_transaction_type
				            );
           Raise OKL_API.G_EXCEPTION_ERROR;
        End If;
     close okl_trx_type_csr;
     --Assign transaction Type id to seeded value in cs_lookups
     x_trx_rec.transaction_type_id := l_trx_type_id;
     --Assign Source Line Ref id to contract line id of IB instance line
     x_trx_rec.source_line_ref_id := p_cle_id;
     x_trx_rec.transaction_date := sysdate;
     --confirm whether this has to be sysdate or creation date on line
     x_trx_rec.source_transaction_date := sysdate;
    Exception
    When OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_trx_rec;

------------------------------------------------------------------------------
-- PROCEDURE expire_lease_instance
--
--  This procedure expires IB instances from lease contract. This procedure is
--  called during activation of lease contract having a linked service contract.
--
--  This procedure sets IB instance(s) to NULL on lease contract, which is later
--  being assigned with corresponding OKS IB instance(s).
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE expire_lease_instance(
                                    p_api_version         IN  NUMBER,
                                    p_init_msg_list       IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE
                                   ) IS
  l_api_name    VARCHAR2(35)    := 'expire_lease_instance';
  l_proc_name   VARCHAR2(35)    := 'EXPIRE_LEASE_INSTANCE';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR link_asset_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT kitem.object1_id1
  FROM   okc_k_rel_objs rel,
         okc_k_items kitem
  WHERE  rel.cle_id              = kitem.cle_id
  AND    rel.rty_code            = 'OKLSRV'
  AND    rel.jtot_object1_code   = 'OKL_COV_PROD'
  AND    kitem.jtot_object1_code = 'OKX_COVASST'
  AND    rel.chr_id              = p_chr_id;

  CURSOR inst_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                   p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT kitem.id,
         kitem.object1_id1,
         kitem.cle_id
  FROM   okc_k_lines_b form2,
         okc_line_styles_b f2_style,
         okc_k_lines_b inst,
         okc_line_styles_b inst_style,
         okc_k_items_v kitem
  WHERE  form2.lse_id            = f2_style.id
  AND    f2_style.lty_code       = 'FREE_FORM2'
  AND    inst.lse_id             = inst_style.id
  AND    inst_style.lty_code     = 'INST_ITEM'
  AND    inst.id                 = kitem.cle_id
  AND    kitem.jtot_object1_code = 'OKX_IB_ITEM'
  AND    form2.id                = inst.cle_id
  AND    form2.dnz_chr_id        = p_chr_id
  AND    form2.cle_id            = p_cle_id;

  CURSOR oks_ib_csr (p_instance_id OKC_K_ITEMS.OBJECT1_ID1%TYPE) IS
  SELECT DECODE(count(1),0,'N','Y') ib_exists
  FROM   okc_k_items
  WHERE  object1_id1       = p_instance_id
  AND    jtot_object1_code = 'OKX_CUSTPROD';

  l_ib_used      VARCHAR2(1) := 'N';
  l_instance_rec csi_datastructures_pub.instance_rec;
  l_txn_rec      csi_datastructures_pub.transaction_rec;
  x_inst_tbl     csi_datastructures_pub.id_tbl;

  l_cimv_rec     cimv_rec_type;
  x_cimv_rec     cimv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      FOR link_asset_rec IN link_asset_csr(p_okl_chr_id)
      LOOP
         FOR okl_inst_rec IN inst_csr (p_okl_chr_id,
                                       TO_NUMBER(link_asset_rec.object1_id1))
         LOOP
            IF (okl_inst_rec.object1_id1 IS NOT NULL) THEN -- If IB instance exists then

               --
               -- Check whether IB instance is being used
               -- by any Service contract
               -- If so, don't expire that instance
               --
               l_ib_used := 'N';
               OPEN oks_ib_csr (okl_inst_rec.object1_id1);
               FETCH oks_ib_csr INTO l_ib_used;
               IF (oks_ib_csr%NOTFOUND) THEN
                  l_ib_used := 'N';
               END IF;
               CLOSE oks_ib_csr;

               IF (l_ib_used = 'N') THEN -- expire IB instance now

                  l_instance_rec.instance_id           := TO_NUMBER(okl_inst_rec.object1_id1);
                  l_instance_rec.object_version_number := 1;
                  l_instance_rec.instance_status_id    := NULL;

                  get_trx_rec(
                              p_api_version      => p_api_version,
                              p_init_msg_list    => p_init_msg_list,
                              x_return_status    => x_return_status,
                              x_msg_count        => x_msg_count,
                              x_msg_data         => x_msg_data,
                              p_cle_id           => okl_inst_rec.cle_id,
                              p_transaction_type => 'OKL_OTHER',
                              x_trx_rec          => l_txn_rec
                             );

                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
                     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
                     raise OKC_API.G_EXCEPTION_ERROR;
                  END IF;

                  csi_item_instance_pub.expire_item_instance(
                                                              p_api_version         => p_api_version,
                                                              p_commit              => 'F',
                                                              p_init_msg_list       => p_init_msg_list,
                                                              p_validation_level    => fnd_api.g_valid_level_full,
                                                              p_instance_rec        => l_instance_rec,
                                                              p_expire_children     => OKL_API.G_FALSE,
                                                              p_txn_rec             => l_txn_rec,
                                                              x_instance_id_lst     => x_inst_tbl,
                                                              x_return_status       => x_return_status,
                                                              x_msg_count           => x_msg_count,
                                                              x_msg_data            => x_msg_data
                                                            );

                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
                     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
                     raise OKC_API.G_EXCEPTION_ERROR;
                  END IF;

               END IF; -- if l_ib_used

               l_cimv_rec.id          := okl_inst_rec.id;
               l_cimv_rec.object1_id1 := NULL;    -- Update with IB instance from OKS contract later

               okl_okc_migration_pvt.update_contract_item(
	                                                  p_api_version	=> p_api_version,
	                                                  p_init_msg_list	=> p_init_msg_list,
	                                                  x_return_status 	=> x_return_status,
	                                                  x_msg_count     	=> x_msg_count,
	                                                  x_msg_data      	=> x_msg_data,
	                                                  p_cimv_rec	=> l_cimv_rec,
	                                                  x_cimv_rec	=> x_cimv_rec
                                                         );

               IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
                  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
                  raise OKC_API.G_EXCEPTION_ERROR;
               END IF;

            END IF; -- If IB exists

         END LOOP; -- okl_inst_csr

      END LOOP; -- link_asset_csr

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END expire_lease_instance;

------------------------------------------------------------------------------
-- PROCEDURE relink_service_contract
--
--  This procedure is used to link service contract to a BOOKED lease
--  contract.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE relink_service_contract(
                                    p_api_version         IN  NUMBER,
                                    p_init_msg_list       IN  VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2,
                                    p_okl_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Lease Contract Header ID
                                    p_oks_chr_id          IN  OKC_K_HEADERS_V.ID%TYPE, -- Service Contract Header ID
                                    p_supplier_id         IN  NUMBER,                  -- OKL_VENDOR
                                    p_sty_id              IN  OKL_K_LINES.STY_ID%TYPE DEFAULT NULL, -- Bug 4011710
                                    x_okl_service_line_id OUT NOCOPY OKC_K_LINES_V.ID%TYPE
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'relink_service_contract';
  l_proc_name   VARCHAR2(35)    := 'RELINK_SERVICE_CONTRACT';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      okl_service_integration_pvt.create_service_from_oks(
                                    p_api_version         => p_api_version,
                                    p_init_msg_list       => p_init_msg_list,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data,
                                    p_okl_chr_id          => p_okl_chr_id,
                                    p_oks_chr_id          => p_oks_chr_id,
                                    p_supplier_id         => p_supplier_id,
                                    p_sty_id              => p_sty_id, -- Bug 4011710
                                    x_okl_service_line_id => x_okl_service_line_id
                                   );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      okl_service_integration_pvt.initiate_service_booking(
                                    p_api_version         => p_api_version,
                                    p_init_msg_list       => p_init_msg_list,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data,
                                    p_okl_chr_id          => p_okl_chr_id
                                   );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END relink_service_contract;

END OKL_SERVICE_INTEGRATION_PVT;

/

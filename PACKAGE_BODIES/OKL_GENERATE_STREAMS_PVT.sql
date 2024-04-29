--------------------------------------------------------
--  DDL for Package Body OKL_GENERATE_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GENERATE_STREAMS_PVT" AS
/* $Header: OKLRGSMB.pls 120.5 2005/10/30 04:34:16 appldev noship $ */

--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -Start                  |
 G_WF_EVT_KHR_GEN_STRMS CONSTANT VARCHAR2(61) := 'oracle.apps.okl.la.lease_contract.stream_generation_requested';
 G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(15) := 'CONTRACT_ID';
 G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(20) := 'CONTRACT_PROCESS';
--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -End                  |

------------------------------------------------------------------------------
-- Procedure GENERATE_STREAMS
------------------------------------------------------------------------------
PROCEDURE GENERATE_STREAMS(p_api_version          IN         NUMBER
                           ,p_init_msg_list       IN         VARCHAR2
                           ,p_khr_id              IN         NUMBER
                           ,p_generation_ctx_code IN         VARCHAR2
                           ,x_trx_number          OUT NOCOPY NUMBER
                           ,x_trx_status          OUT NOCOPY VARCHAR2
                           ,x_return_status       OUT NOCOPY VARCHAR2
                           ,x_msg_count           OUT NOCOPY NUMBER
                           ,x_msg_data            OUT NOCOPY VARCHAR2)
IS

l_api_name VARCHAR2(31) := 'GENERATE_STREAMS';
l_return_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
l_trx_status   VARCHAR2(30);
l_skip_engine   VARCHAR2(1) := G_FALSE;

--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -Start                  |

PROCEDURE raise_business_event(x_return_status OUT NOCOPY VARCHAR2) IS
      l_process VARCHAR2(20);
      l_parameter_list           wf_parameter_list_t;

  BEGIN

	 l_process := Okl_Lla_Util_Pvt.get_contract_process(p_khr_id);

  	 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_khr_id,l_parameter_list);
  	 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_GEN_STRMS,
								 p_parameters     => l_parameter_list);



     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END raise_business_event;

 --|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -End                  |

BEGIN

  /*------------------------------------------------------------------------------------
  NOTE: p_generation_ctx_code holds the LookUp Code for LookUp Type OKL_CONTRACT_PROCESS
  -------------------------------------------------------------------------------------*/

  IF(p_generation_ctx_code = G_ORP_CODE_AUTH) THEN
    okl_la_stream_pub.generate_streams(p_api_version          => p_api_version
                                       ,p_init_msg_list       => p_init_msg_list
                                       ,p_chr_id              => p_khr_id
                                       ,p_generation_context  => p_generation_ctx_code
                                       ,p_skip_prc_engine     => l_skip_engine
                                       ,x_request_id          => x_trx_number
				                       ,x_trans_status        => l_trx_status
                                       ,x_return_status       => l_return_status
                                       ,x_msg_count           => x_msg_count
                                       ,x_msg_data            => x_msg_data);
  ELSIF(p_generation_ctx_code = G_ORP_CODE_QUOT) THEN
    NULL;
  ELSIF(p_generation_ctx_code = G_ORP_CODE_RBOK) THEN
    NULL;
  ELSIF(p_generation_ctx_code = G_ORP_CODE_TERM) THEN
    NULL;
  END IF;



 /* For Testing Purposes only
  OKL_CREATE_STREAMS_TEST.INVOKE_TEST_SCRIPT(
                p_khr_id        => p_khr_id,
                x_return_status => l_return_status,
                x_trans_id      => x_trx_number,
                x_trans_status  => x_trx_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
*/

  IF (l_return_status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

 x_return_status := l_return_status;
  x_trx_status := OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING('OKL_SIF_STATUS', l_trx_status);

--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -Start                  |

  raise_business_event(x_return_status => x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -End                  |
  EXCEPTION

    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
    WHEN OTHERS THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );

END GENERATE_STREAMS;


------------------------------------------------------------------------------
-- Procedure POPULATE_HEADER_DATA
------------------------------------------------------------------------------
PROCEDURE POPULATE_HEADER_DATA(p_api_version          IN         NUMBER
                               ,p_init_msg_list       IN         VARCHAR2
                               ,p_khr_id              IN         NUMBER
                               ,p_generation_ctx_code IN         VARCHAR2
                               ,x_trx_number          OUT NOCOPY NUMBER
                               ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2)
IS

l_api_name VARCHAR2(31) := 'POPULATE_HEADER_DATA';
l_return_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
l_skip_engine   VARCHAR2(1) := G_TRUE;
l_trx_status VARCHAR2(30);

BEGIN

  /*------------------------------------------------------------------------------------
  NOTE: p_generation_ctx_code holds the LookUp Code for LookUp Type OKL_CONTRACT_PROCESS
  -------------------------------------------------------------------------------------*/
--dbms_output.put_line('inside  gen stream pvt' || l_return_status);
  IF(p_generation_ctx_code = G_ORP_CODE_AUTH) THEN
--dbms_output.put_line('calling la strm pub' || l_return_status);
    okl_la_stream_pub.generate_streams(p_api_version          => p_api_version
                                       ,p_init_msg_list       => p_init_msg_list
                                       ,p_chr_id              => p_khr_id
                                       ,p_generation_context  => p_generation_ctx_code
                                       ,p_skip_prc_engine     => l_skip_engine
                                       ,x_request_id          => x_trx_number
				       ,x_trans_status        => l_trx_status
                                       ,x_return_status       => l_return_status
                                       ,x_msg_count           => x_msg_count
                                       ,x_msg_data            => x_msg_data);
--dbms_output.put_line('back from  la strm pub' || l_return_status);
    NULL;
  ELSIF(p_generation_ctx_code = G_ORP_CODE_QUOT) THEN
    NULL;
  ELSIF(p_generation_ctx_code = G_ORP_CODE_RBOK) THEN
    NULL;
  ELSIF(p_generation_ctx_code = G_ORP_CODE_TERM) THEN
    NULL;
  END IF;

  IF (l_return_status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_return_status := l_return_status;

  EXCEPTION

    WHEN G_EXCEPTION_ERROR THEN
--dbms_output.put_line('gen stream pvt error' || sqlcode || sqlerrm);
      x_return_status := G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
--dbms_output.put_line('gen stream pvt UU' || sqlcode || sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
    WHEN OTHERS THEN
--dbms_output.put_line('gen stream pvt OO' || sqlcode || sqlerrm);
     x_return_status := G_RET_STS_UNEXP_ERROR;
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
END POPULATE_HEADER_DATA;


------------------------------------------------------------------------------
-- Procedure INVOKE_PRICING_ENGINE
------------------------------------------------------------------------------
PROCEDURE INVOKE_PRICING_ENGINE(p_api_version          IN         NUMBER
                                ,p_init_msg_list       IN         VARCHAR2
                                ,p_trx_number          IN NUMBER
                                ,x_trx_number          OUT NOCOPY NUMBER
                                ,x_trx_status          OUT NOCOPY VARCHAR2
                                ,x_return_status       OUT NOCOPY VARCHAR2
                                ,x_msg_count           OUT NOCOPY NUMBER
                                ,x_msg_data            OUT NOCOPY VARCHAR2)
IS

-- mvasudev, 04/24/2002
CURSOR sif_csr(l_transaction_number NUMBER) IS
SELECT id, orp_code, deal_type, stream_interface_attribute04
FROM OKL_STREAM_INTERFACES
WHERE OKL_STREAM_INTERFACES.transaction_number = l_transaction_number;

--l_transaction_status_csr transaction_status_csr;
l_api_name VARCHAR2(31) := 'GENERATE_STREAMS';
l_return_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
lx_sif_vrec sifv_rec_type;
l_sif_vrec sifv_rec_type;

BEGIN

  /*------------------------------------------------------------------------------------
  NOTE: p_generation_ctx_code holds the LookUp Code for LookUp Type OKL_CONTRACT_PROCESS
  -------------------------------------------------------------------------------------*/
 FOR l_sif_csr IN sif_csr(p_trx_number)
 LOOP
   l_sif_vrec.id := l_sif_csr.id;
   l_sif_vrec.orp_code := l_sif_csr.orp_code;
   l_sif_vrec.deal_type := l_sif_csr.deal_type;

   -- mvasudev, 04/24/2002
   l_sif_vrec.stream_interface_attribute04 := l_sif_csr.stream_interface_attribute04;

 END LOOP;
 OKL_CREATE_STREAMS_PUB.INVOKE_PRICING_ENGINE(p_api_version    => p_api_version
                                             ,p_init_msg_list => p_init_msg_list
                                             ,p_sifv_rec      => l_sif_vrec
                                             ,x_sifv_rec      => lx_sif_vrec
                                             ,x_return_status => l_return_status
                                             ,x_msg_count     => x_msg_count
                                             ,x_msg_data      => x_msg_data);

  IF (l_return_status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;
  x_trx_number := lx_sif_vrec.transaction_number;
  x_trx_status := lx_sif_vrec.sis_code;
  x_return_status := l_return_status;
  EXCEPTION

    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
    WHEN OTHERS THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );

END INVOKE_PRICING_ENGINE;

END Okl_Generate_Streams_Pvt;

/

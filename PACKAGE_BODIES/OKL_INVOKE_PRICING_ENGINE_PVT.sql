--------------------------------------------------------
--  DDL for Package Body OKL_INVOKE_PRICING_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVOKE_PRICING_ENGINE_PVT" AS
/* $Header: OKLRSSMB.pls 120.5 2006/03/24 01:12:05 cijang noship $ */

  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_invoke_pricing_engine_pvt.generate_streams_st';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_EXCEPTION_ON BOOLEAN;
  G_IS_DEBUG_ERROR_ON BOOLEAN;
  G_IS_DEBUG_PROCEDURE_ON BOOLEAN;

  PROCEDURE generate_streams_st(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_xmlg_trx_type                IN  VARCHAR2,
         p_xmlg_trx_sub_type            IN  VARCHAR2,
         p_sifv_rec                      IN  OKL_SIF_PVT.SIFV_REC_TYPE)

  IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN

	x_return_status := G_RET_STS_SUCCESS;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE, p_sifv_rec.transaction_number ||': Begin generate_streams_st');
    END IF;

    COMMIT;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE, p_sifv_rec.transaction_number ||': Commited');
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE, p_sifv_rec.transaction_number ||': Calling OKL_ESG_TRANSPORT_PVT.process_esg');
    END IF;

    OKL_ESG_TRANSPORT_PVT.process_esg(p_sifv_rec.transaction_number, l_return_status);

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE, p_sifv_rec.transaction_number ||': End OKL_ESG_TRANSPORT_PVT.process_esg: l_return_status = '||l_return_status);
    END IF;

    IF l_return_status <> G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE, p_sifv_rec.transaction_number ||': generate_streams_st');
    END IF;

  EXCEPTION
  	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;

	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, G_MODULE , p_sifv_rec.transaction_number ||': '||SQLERRM(SQLCODE));
	  END IF;

	  -- store SQL error message on message stack
	  OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
						  p_msg_name	=>	G_UNEXPECTED_ERROR,
						  p_token1	=>	G_SQLCODE_TOKEN,
						  p_token1_value	=>	sqlcode,
						  p_token2	=>	G_SQLERRM_TOKEN,
						  p_token2_value	=>	sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

   END GENERATE_STREAMS_ST;

END  OKL_INVOKE_PRICING_ENGINE_PVT;

/

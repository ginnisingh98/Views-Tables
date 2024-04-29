--------------------------------------------------------
--  DDL for Package Body OKL_VP_COPY_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_COPY_CONTRACT_PUB" AS
/*$Header: OKLPCPXB.pls 120.2 2005/06/17 23:52:53 fmiao noship $*/

  ---------------------------------------------------------------------------
  -- PROCEDURE COPY_contract
  -- Public wrapper for COPY  contract process api
  ---------------------------------------------------------------------------
  PROCEDURE copy_contract(p_api_version          IN               NUMBER,
                          p_init_msg_list        IN               VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status        OUT              NOCOPY VARCHAR2,
                          x_msg_count            OUT              NOCOPY NUMBER,
                          x_msg_data             OUT              NOCOPY VARCHAR2,
                          p_copy_rec             IN               copy_header_rec_type,
                          x_new_contract_id      OUT NOCOPY              NUMBER) IS


    l_copy_rec                        copy_header_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'copy_contract';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_contract_id                     NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_copy_rec := p_copy_rec;



	-- call process api to extend contract

    OKL_VP_COPY_CONTRACT_PVT.copy_contract(p_api_version     => p_api_version,
                                           p_init_msg_list   => p_init_msg_list,
              			           x_return_status   => l_return_status,
               			           x_msg_count       => x_msg_count,
                              	           x_msg_data        => x_msg_data,
                              	           p_copy_rec        => l_copy_rec,
                                           x_new_contract_id => l_contract_id);


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

		 --fmiao add for copy vendor programs--
		 x_new_contract_id := l_contract_id;
		 --end fmiao copy--



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	                        p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  		        p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_VP_COPY_CONTRACT_PUB','copy_contract');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END copy_contract;

END OKL_VP_COPY_CONTRACT_PUB;

/

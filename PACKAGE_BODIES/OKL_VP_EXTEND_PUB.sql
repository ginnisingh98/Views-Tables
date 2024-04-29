--------------------------------------------------------
--  DDL for Package Body OKL_VP_EXTEND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_EXTEND_PUB" AS
/*$Header: OKLPEXTB.pls 115.7 2004/04/13 10:44:58 rnaik noship $*/

  ---------------------------------------------------------------------------
  -- PROCEDURE extend_contract
  -- Public wrapper for extend contract process api
  ---------------------------------------------------------------------------
  PROCEDURE extend_contract(p_api_version          IN             NUMBER,
                            p_init_msg_list        IN             VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status        OUT            NOCOPY VARCHAR2,
                            x_msg_count            OUT            NOCOPY NUMBER,
                            x_msg_data             OUT            NOCOPY VARCHAR2,
                            p_ext_header_rec       IN             extension_header_rec_type) IS
    l_ext_header_rec                  extension_header_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'extend_contract';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- SAVEPOINT extend_contract;
    l_ext_header_rec := p_ext_header_rec;



  -- call process api to extend contract

  okl_vp_extend_pvt.extend_contract(p_api_version     => p_api_version,
                                    p_init_msg_list   => p_init_msg_list,
              			    x_return_status   => l_return_status,
               			    x_msg_count       => x_msg_count,
                              	    x_msg_data        => x_msg_data,
                              	    p_ext_header_rec  => l_ext_header_rec);


  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;




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
  FND_MSG_PUB.ADD_EXC_MSG('OKL_VP_EXTEND_PUB','extend_contract');
  -- store SQL error message on message stack for caller
  FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
END extend_contract;

END OKL_VP_EXTEND_PUB;

/

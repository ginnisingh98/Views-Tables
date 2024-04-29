--------------------------------------------------------
--  DDL for Package Body OKL_FORMULAEVALUATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FORMULAEVALUATE_PUB" AS
  /* $Header: OKLPEVAB.pls 115.4 2004/04/13 10:44:46 rnaik noship $ */

  PROCEDURE EVA_GetParameterValues(p_api_version   IN  NUMBER
                   ,p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status OUT NOCOPY VARCHAR2
                   ,x_msg_count     OUT NOCOPY NUMBER
                   ,x_msg_data      OUT NOCOPY VARCHAR2
                   ,p_fma_id  IN  okl_formulae_v.id%TYPE
                   ,p_contract_id   IN  okl_k_headers_v.id%TYPE
                   ,x_ctx_parameter_tbl         OUT NOCOPY ctxparameter_tbl
                   ,p_line_id       IN  okl_k_lines_v.id%TYPE DEFAULT NULL)
  IS
    l_count                  NUMBER;
    l_data                   VARCHAR2(100);
    l_api_name               CONSTANT VARCHAR2(30) := 'eva_getparametervalues';
    l_return_status          VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT getparametervalues;




    okl_formulaevaluate_pvt.EVA_GetParameterValues(
 				    p_api_version     => p_api_version
                                   ,p_init_msg_list   => p_init_msg_list
                                   ,x_return_status   => l_return_status
                                   ,x_msg_count       => x_msg_count
                                   ,x_msg_data        => x_msg_data
                                   ,p_fma_id    => p_fma_id
                                   ,p_contract_id     => p_contract_id
				   ,x_ctx_parameter_tbl => x_ctx_parameter_tbl
                                   ,p_line_id         => p_line_id );


    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;





  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getparametervalues;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getparametervalues;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, l_api_name);
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END EVA_GetParameterValues;

  PROCEDURE EVA_GetFunctionValue(p_api_version      IN  NUMBER
                   ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status    OUT NOCOPY VARCHAR2
                   ,x_msg_count        OUT NOCOPY NUMBER
                   ,x_msg_data         OUT NOCOPY VARCHAR2
                   ,p_fma_id     IN  okl_formulae_v.id%TYPE
                   ,p_contract_id      IN  okl_k_headers_v.id%TYPE
                   ,p_line_id          IN  okl_k_lines_v.id%TYPE
                   ,p_ctx_parameter_tbl  IN ctxparameter_tbl
                   ,x_function_tbl            OUT NOCOPY function_tbl
                   ) IS
    l_count                  NUMBER;
    l_data                   VARCHAR2(100);
    l_api_name               CONSTANT VARCHAR2(30) := 'eva_getfunctionvalue';
    l_return_status          VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT getfunctionvalue;
    okl_formulaevaluate_pvt.EVA_GetFunctionValue(p_api_version     => p_api_version
                                   ,p_init_msg_list   => p_init_msg_list
                                   ,x_return_status   => l_return_status
                                   ,x_msg_count       => x_msg_count
                                   ,x_msg_data        => x_msg_data
                                   ,p_fma_id    => p_fma_id
                                   ,p_contract_id     => p_contract_id
                                   ,p_line_id         => p_line_id
                                   ,p_ctx_parameter_tbl => p_ctx_parameter_tbl
                                   ,x_function_tbl           => x_function_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getfunctionvalue;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getfunctionvalue;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END EVA_GetFunctionValue;

END OKL_FORMULAEVALUATE_PUB;

/

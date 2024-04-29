--------------------------------------------------------
--  DDL for Package Body OKL_FORMULAVALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FORMULAVALIDATE_PUB" AS
  /* $Header: OKLPVALB.pls 115.4 2004/04/13 11:26:23 rnaik noship $ */

  PROCEDURE VAL_ValidateFormula(p_api_version   IN  NUMBER
                   ,p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status OUT NOCOPY VARCHAR2
                   ,x_msg_count     OUT NOCOPY NUMBER
                   ,x_msg_data      OUT NOCOPY VARCHAR2
                   ,x_validate_status OUT NOCOPY VARCHAR2
                   ,p_fma_id  IN  okl_formulae_v.id%TYPE
                   ,p_cgr_id  IN  okl_context_groups_v.id%TYPE )
  IS
    l_count                  NUMBER;
    l_data                   VARCHAR2(100);
    l_api_name               CONSTANT VARCHAR2(30) := 'validateformula';
    l_return_status          VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT validateformula;






    okl_formulavalidate_pvt.VAL_ValidateFormula(
				p_api_version     => p_api_version
                                   ,p_init_msg_list   => p_init_msg_list
                                   ,x_return_status   => l_return_status
                                   ,x_msg_count       => x_msg_count
                                   ,x_msg_data        => x_msg_data
                                   ,x_validate_status   => x_validate_status
                                   ,p_fma_id    => p_fma_id
                                   ,p_cgr_id    => p_cgr_id);


    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validateformula;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validateformula;
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
  END VAL_ValidateFormula;


END OKL_FORMULAVALIDATE_PUB;

/

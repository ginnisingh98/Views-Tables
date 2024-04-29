--------------------------------------------------------
--  DDL for Package Body OKL_COPY_TEMPLATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_TEMPLATE_PUB" AS
/* $Header: OKLPTLCB.pls 115.3 2002/12/18 12:43:07 kjinger noship $ */


PROCEDURE COPY_TEMPLATES(p_api_version                IN         NUMBER,
                         p_init_msg_list              IN         VARCHAR2,
                         x_return_status              OUT        NOCOPY VARCHAR2,
                         x_msg_count                  OUT        NOCOPY NUMBER,
                         x_msg_data                   OUT        NOCOPY VARCHAR2,
						 p_aes_id_from                IN         NUMBER,
						 p_aes_id_to                  IN         NUMBER)
IS


l_api_version NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'COPY_TEMPLATES';

l_aes_id_from        NUMBER := p_aes_id_from;
l_aes_id_to          NUMBER := p_aes_id_to;

l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN

  SAVEPOINT COPY_TEMPLATES;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


   OKL_COPY_TEMPLATE_PVT.COPY_TEMPLATES(p_api_version      => l_api_version,
                                        p_init_msg_list    => p_init_msg_list,
                                        x_return_status    => x_return_status,
                                        x_msg_count        => x_msg_count,
                                        x_msg_data         => x_msg_data,
                                        p_aes_id_from      => l_aes_id_from,
                                        p_aes_id_to        => l_aes_id_to);



  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO COPY_TEMPLATES;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO COPY_TEMPLATES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_COPY_TEMPLATE_PUB','COPY_TEMPLATES');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END COPY_TEMPLATES;



END OKL_COPY_TEMPLATE_PUB;

/

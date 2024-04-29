--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_IMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_IMP_PUB" AS
/* $Header: OKLPITFB.pls 115.3 2002/12/18 12:22:46 kjinger noship $ */



PROCEDURE INT_RATE_IMPORT(p_api_version                 IN   NUMBER,
                          p_init_msg_list               IN   VARCHAR2,
                          x_return_status               OUT  NOCOPY VARCHAR2,
                          x_msg_count                   OUT  NOCOPY NUMBER,
                          x_msg_data                    OUT  NOCOPY VARCHAR2)
AS

l_api_version   NUMBER := 1.0;

l_api_name          CONSTANT VARCHAR2(30)  := 'INT_RATE_IMPORT';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;



BEGIN


  SAVEPOINT INT_RATE_IMPORT;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


    OKL_INTEREST_IMP_PVT.INT_RATE_IMPORT(p_api_version        => l_api_version,
                                         p_init_msg_list      => p_init_msg_list,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INT_RATE_IMPORT;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INT_RATE_IMPORT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_IMP_PUB','INT_RATE_IMPORT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END INT_RATE_IMPORT;


END OKL_INTEREST_IMP_PUB;


/

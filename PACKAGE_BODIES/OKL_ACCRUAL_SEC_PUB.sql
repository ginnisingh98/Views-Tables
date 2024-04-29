--------------------------------------------------------
--  DDL for Package Body OKL_ACCRUAL_SEC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCRUAL_SEC_PUB" AS
/* $Header: OKLPASCB.pls 115.0 2003/03/06 22:12:47 sgiyer noship $ */


  PROCEDURE CREATE_STREAMS(p_api_version    IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
                           p_khr_id          IN NUMBER) IS


  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_khr_id                       => p_khr_id);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCRUAL_SEC_PUB','CREATE_STREAMS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END CREATE_STREAMS;

  -- procedure to cancel accrual securitization streams for LEASE contracts.
  PROCEDURE CANCEL_STREAMS(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
					       p_khr_id          IN NUMBER,
                           p_cancel_date     IN DATE) IS



  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_ACCRUAL_SEC_PVT.CANCEL_STREAMS(
        p_api_version                  => p_api_version,
        p_init_msg_list                => p_init_msg_list,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_khr_id                       => p_khr_id,
        p_cancel_date                  => p_cancel_date);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCRUAL_SEC_PUB','CANCEL_STREAMS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END CANCEL_STREAMS;

END OKL_ACCRUAL_SEC_PUB;

/

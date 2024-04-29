--------------------------------------------------------
--  DDL for Package Body OKL_MULTI_GAAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MULTI_GAAP_PUB" AS
/* $Header: OKLPGAPB.pls 115.0 2002/12/17 20:00:55 sgiyer noship $ */

  FUNCTION SUBMIT_MULTI_GAAP(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_date_from IN DATE,
    p_date_to IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER IS

    l_api_version       NUMBER := 1.0;
    l_api_name          CONSTANT VARCHAR2(2000)  := 'SUBMIT_MULTI_GAAP';
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_request_id        NUMBER;

  BEGIN

  SAVEPOINT SUBMIT_MULTI_GAAP;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- Execute the Main Procedure

  x_request_id := OKL_MULTI_GAAP_PVT.SUBMIT_MULTI_GAAP(
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_api_version => l_api_version,
                                p_date_from => p_date_from,
                                p_date_to => p_date_to,
                                p_batch_name => p_batch_name);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  RETURN x_request_id;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_DEPR_ADJUSTMENT;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_DEPR_ADJUSTMENT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO SUBMIT_DEPR_ADJUSTMENT;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCRUAL_DEPRN_ADJ_PUB','SUBMIT_MULTI_GAAP');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END SUBMIT_MULTI_GAAP;

END OKL_MULTI_GAAP_PUB;

/

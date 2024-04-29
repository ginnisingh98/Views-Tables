--------------------------------------------------------
--  DDL for Package Body OKL_INTEREST_CALC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTEREST_CALC_PUB" AS
/* $Header: OKLPITUB.pls 115.9 2003/01/28 12:54:27 rabhupat noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.INTEREST';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

PROCEDURE CALC_INTEREST_ACTIVATE(p_api_version        IN    NUMBER,
                                 p_init_msg_list      IN    VARCHAR2,
                                 x_return_status      OUT   NOCOPY VARCHAR2,
                                 x_msg_count          OUT   NOCOPY NUMBER,
                                 x_msg_data           OUT   NOCOPY VARCHAR2,
                                 p_contract_number    IN    VARCHAR2,
                                 p_Activation_date    IN    DATE,
                                 x_amount             OUT NOCOPY   NUMBER,
                                 x_source_id          OUT NOCOPY   NUMBER)
AS
  l_api_version   NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'CALC_INTEREST_ACTIVATE';
  l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
  l_contract_number   VARCHAR2(256) := p_contract_number;
  l_activation_date   DATE   := p_activation_date;
  l_amount            NUMBER;
  l_source_id         NUMBER;

BEGIN
  SAVEPOINT CALC_INTEREST_ACTIVATE;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  -- customer pre-processing
-- Execute the Main Procedure
-- Start of wraper code generated automatically by Debug code generator for OKL_INTEREST_CALC_PVT.CALC_INTEREST_ACTIVATE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPITUB.pls call OKL_INTEREST_CALC_PVT.CALC_INTEREST_ACTIVATE ');
    END;
  END IF;
      OKL_INTEREST_CALC_PVT.CALC_INTEREST_ACTIVATE(p_api_version      => l_api_version,
                                                   p_init_msg_list    => p_init_msg_list,
                                                   x_return_status    => x_return_status,
                                                   x_msg_count        => x_msg_count,
                                                   x_msg_data         => x_msg_data,
                                                   p_contract_number  => l_contract_number,
                                                   p_activation_date  => l_activation_date,
                                                   x_amount           => x_amount,
                                                   x_source_id        => x_source_id);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPITUB.pls call OKL_INTEREST_CALC_PVT.CALC_INTEREST_ACTIVATE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_INTEREST_CALC_PVT.CALC_INTEREST_ACTIVATE

  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_amount    := x_amount;
  l_source_id := x_source_id;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CALC_INTEREST_ACTIVATE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CALC_INTEREST_ACTIVATE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_CALC_PUB','CALC_INTEREST_ACTIVATE');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CALC_INTEREST_ACTIVATE;


FUNCTION SUBMIT_CALCULATE_INTEREST(p_api_version       IN NUMBER,
                                   p_init_msg_list     IN VARCHAR2,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_msg_count         OUT NOCOPY NUMBER,
                                   x_msg_data          OUT NOCOPY VARCHAR2,
                                   p_period_name       IN VARCHAR2 )

RETURN NUMBER IS

    l_api_version          CONSTANT NUMBER := 1;
    l_api_name             CONSTANT VARCHAR2(50) := 'SUBMIT_CALCULATE_INTEREST';
    l_return_status        VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_request_id           NUMBER;
    l_period_name          VARCHAR2(30) := p_period_name;

BEGIN

   SAVEPOINT SUBMIT_CALCULATE_INTEREST;
   l_return_status    := FND_API.G_RET_STS_SUCCESS;
    -- customer pre-processing

-- Execute the Main Procedure
-- Start of wraper code generated automatically by Debug code generator for l_request_id := OKL_INTEREST_CALC_PVT.SUBMIT_CALCULATE_INTEREST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPITUB.pls call l_request_id := OKL_INTEREST_CALC_PVT.SUBMIT_CALCULATE_INTEREST ');
    END;
  END IF;
   l_request_id := OKL_INTEREST_CALC_PVT.SUBMIT_CALCULATE_INTEREST(
             p_api_version       => l_api_version,
             p_init_msg_list     => p_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_period_name       => l_period_name);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPITUB.pls call l_request_id := OKL_INTEREST_CALC_PVT.SUBMIT_CALCULATE_INTEREST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for l_request_id := OKL_INTEREST_CALC_PVT.SUBMIT_CALCULATE_INTEREST

  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  RETURN l_request_id;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_CALCULATE_INTEREST;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_request_id;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_CALCULATE_INTEREST;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_request_id;
  WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INTEREST_CALC_PUB','CALC_INTEREST_ACTIVATE');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_request_id;
  END SUBMIT_CALCULATE_INTEREST;
END OKL_INTEREST_CALC_PUB;

/

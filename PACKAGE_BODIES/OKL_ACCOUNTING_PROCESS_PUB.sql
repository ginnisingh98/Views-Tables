--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_PROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_PROCESS_PUB" AS
/* $Header: OKLPAECB.pls 115.8 2003/01/28 12:50:46 rabhupat noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.PROCESS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator


PROCEDURE DO_ACCOUNTING_CON(p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            p_start_date          IN   DATE,
                            p_end_date            IN   DATE,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            x_request_id          OUT NOCOPY  NUMBER)

IS


  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'DO_ACCOUNTING_CON';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_start_date        DATE := p_start_date;
  l_end_date          DATE := p_end_date;
  l_request_id        NUMBER;




BEGIN

  SAVEPOINT DO_ACCOUNTING_CON;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNTING_PROCESS_PVT.DO_ACCOUNTING_CON
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPAECB.pls call OKL_ACCOUNTING_PROCESS_PVT.DO_ACCOUNTING_CON ');
    END;
  END IF;
  OKL_ACCOUNTING_PROCESS_PVT.DO_ACCOUNTING_CON(p_api_version      => l_api_version,
                                                  p_init_msg_list    => p_init_msg_list,
                                                  p_start_date       => l_start_date,
                                                  p_end_date         => l_end_date,
                                                  x_return_status    => x_return_status,
                                                  x_msg_count        => x_msg_count,
                                                  x_msg_data         => x_msg_data,
                                                  x_request_id       => x_request_id);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPAECB.pls call OKL_ACCOUNTING_PROCESS_PVT.DO_ACCOUNTING_CON ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNTING_PROCESS_PVT.DO_ACCOUNTING_CON


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  l_request_id := x_request_id;






EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DO_ACCOUNTING_CON;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DO_ACCOUNTING_CON;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNTING_PROCESS_PUB','DO_ACCOUNTING_CON');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END DO_ACCOUNTING_CON;

END OKL_ACCOUNTING_PROCESS_PUB;

/

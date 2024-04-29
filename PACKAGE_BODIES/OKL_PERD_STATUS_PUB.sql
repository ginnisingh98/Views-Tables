--------------------------------------------------------
--  DDL for Package Body OKL_PERD_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PERD_STATUS_PUB" AS
/* $Header: OKLPPSMB.pls 115.7 2003/01/28 12:56:13 rabhupat noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.PERIOD';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator


PROCEDURE SEARCH_PERIOD_STATUS(p_api_version      IN       NUMBER,
                               p_init_msg_list    IN       VARCHAR2,
                               x_return_status    OUT      NOCOPY VARCHAR2,
                               x_msg_count        OUT      NOCOPY NUMBER,
                               x_msg_data         OUT      NOCOPY VARCHAR2,
                               p_period_rec       IN       PERIOD_REC_TYPE,
                               x_period_tbl       OUT      NOCOPY PERIOD_TBL_TYPE )
IS


l_api_version NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'SEARCH_PERIOD_STATUS';

l_period_rec         period_rec_type := p_period_rec;
l_period_tbl         period_tbl_type;

l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN

  SAVEPOINT SEARCH_PERIOD_STATUS;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


-- Start of wraper code generated automatically by Debug code generator for OKL_PERD_STATUS_PVT.SEARCH_PERIOD_STATUS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPPSMB.pls call OKL_PERD_STATUS_PVT.SEARCH_PERIOD_STATUS ');
    END;
  END IF;
   OKL_PERD_STATUS_PVT.SEARCH_PERIOD_STATUS(p_api_version      => l_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
                                            p_period_rec       => p_period_rec,
                                            x_period_tbl       => x_period_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPPSMB.pls call OKL_PERD_STATUS_PVT.SEARCH_PERIOD_STATUS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PERD_STATUS_PVT.SEARCH_PERIOD_STATUS



  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_period_tbl  := x_period_tbl;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SEARCH_PERIOD_STATUS;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SEARCH_PERIOD_STATUS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PERD_STATUS_PUB','SEARCH_PERIOD_STATUS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END SEARCH_PERIOD_STATUS;




PROCEDURE UPDATE_PERIOD_STATUS(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_period_tbl         IN       PERIOD_TBL_TYPE)
IS


l_api_version NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'UPDATE_PERIOD_STATUS';

l_period_tbl          period_tbl_type := p_period_tbl;

l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


BEGIN

  SAVEPOINT UPDATE_PERIOD_STATUS;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure

-- Start of wraper code generated automatically by Debug code generator for OKL_PERD_STATUS_PVT.UPDATE_PERIOD_STATUS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPPSMB.pls call OKL_PERD_STATUS_PVT.UPDATE_PERIOD_STATUS ');
    END;
  END IF;
  OKL_PERD_STATUS_PVT.UPDATE_PERIOD_STATUS(p_api_version        => l_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_period_tbl         => p_period_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPPSMB.pls call OKL_PERD_STATUS_PVT.UPDATE_PERIOD_STATUS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PERD_STATUS_PVT.UPDATE_PERIOD_STATUS


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_PERIOD_STATUS;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_PERIOD_STATUS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_PERD_STATUS_PUB','UPDATE_PERIOD_STATUS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;




END UPDATE_PERIOD_STATUS;


END OKL_PERD_STATUS_PUB ;

/

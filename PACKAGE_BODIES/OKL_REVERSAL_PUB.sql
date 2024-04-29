--------------------------------------------------------
--  DDL for Package Body OKL_REVERSAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REVERSAL_PUB" AS
/* $Header: OKLPREVB.pls 115.8 2003/01/28 13:08:49 rabhupat noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.REVERSAL';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator



PROCEDURE SUBMIT_PERIOD_REVERSAL(p_api_version                IN         NUMBER,
                                 p_init_msg_list              IN         VARCHAR2,
                                 x_return_status              OUT        NOCOPY VARCHAR2,
                                 x_msg_count                  OUT        NOCOPY NUMBER,
                                 x_msg_data                   OUT        NOCOPY VARCHAR2,
                                 p_period                     IN         VARCHAR2,
                                 x_request_id                 OUT NOCOPY        NUMBER)

AS

   l_api_version    NUMBER := 1.0;
   l_api_name       VARCHAR2(30) := 'SUBMIT_PERIOD_REVERSAL';

   l_period         VARCHAR2(30) := p_period;
   l_return_status  VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
   l_request_id     NUMBER := 0;

BEGIN

  SAVEPOINT SUBMIT_PERIOD_REVERSAL;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


-- Start of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PVT.SUBMIT_PERIOD_REVERSAL
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPREVB.pls call OKL_REVERSAL_PVT.SUBMIT_PERIOD_REVERSAL ');
    END;
  END IF;
   OKL_REVERSAL_PVT.SUBMIT_PERIOD_REVERSAL(p_api_version                => l_api_version,
                                           p_init_msg_list              => p_init_msg_list,
                                           x_return_status              => x_return_status,
                                           x_msg_count                  => x_msg_count,
                                           x_msg_data                   => x_msg_data,
                                           p_period                     => l_period,
                                           x_request_id                 => x_request_id);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPREVB.pls call OKL_REVERSAL_PVT.SUBMIT_PERIOD_REVERSAL ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PVT.SUBMIT_PERIOD_REVERSAL


   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_request_id  := x_request_id;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_PERIOD_REVERSAL;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_PERIOD_REVERSAL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_REVERSAL_PUB','SUBMIT_PERIOD_REVERSAL');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END SUBMIT_PERIOD_REVERSAL;




PROCEDURE REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                          p_init_msg_list              IN         VARCHAR2,
                          x_return_status              OUT        NOCOPY VARCHAR2,
                          x_msg_count                  OUT        NOCOPY NUMBER,
                          x_msg_data                   OUT        NOCOPY VARCHAR2,
                          p_source_id                  IN         NUMBER,
			  p_source_table               IN         VARCHAR2,
			  p_acct_date                  IN         DATE)
AS

l_api_version    NUMBER := 1.0;
l_api_name       VARCHAR2(30) := 'REVERSE_ENTRIES';

l_return_status    VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
l_source_id        NUMBER         := p_source_id;
l_source_table     VARCHAR2(30)   := p_source_table;
l_acct_date        DATE           := p_acct_date;


BEGIN

  SAVEPOINT REVERSE_ENTRIES;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure

-- Start of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PVT.REVERSE_ENTRIES
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPREVB.pls call OKL_REVERSAL_PVT.REVERSE_ENTRIES ');
    END;
  END IF;
   OKL_REVERSAL_PVT.REVERSE_ENTRIES(p_api_version                => l_api_version,
                                    p_init_msg_list              => p_init_msg_list,
                                    x_return_status              => x_return_status,
                                    x_msg_count                  => x_msg_count,
                                    x_msg_data                   => x_msg_data,
                                    p_source_id                  => l_source_id,
           						    p_source_table               => l_source_table,
				                    p_acct_date                  => l_acct_date);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPREVB.pls call OKL_REVERSAL_PVT.REVERSE_ENTRIES ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PVT.REVERSE_ENTRIES


   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO REVERSE_ENTRIES;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO REVERSE_ENTRIES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_REVERSAL_PUB','REVERSE_ENTRIES');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END REVERSE_ENTRIES;



PROCEDURE REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                          p_init_msg_list              IN         VARCHAR2,
                          x_return_status              OUT        NOCOPY VARCHAR2,
                          x_msg_count                  OUT        NOCOPY NUMBER,
                          x_msg_data                   OUT        NOCOPY VARCHAR2,
                          p_source_table               IN         VARCHAR2,
						  p_acct_date                  IN         DATE,
						  p_source_id_tbl              IN         SOURCE_ID_TBL_TYPE)
AS


l_api_version    NUMBER := 1.0;
l_api_name       VARCHAR2(30) := 'REVERSE_ENTRIES';

l_return_status    VARCHAR2(1)        := OKL_API.G_RET_STS_SUCCESS;


l_source_table     VARCHAR2(30)         := p_source_table;
l_acct_date        DATE                 := p_acct_date;
l_source_id_tbl    source_id_tbl_type   := p_source_id_tbl;



BEGIN

  SAVEPOINT REVERSE_ENTRIES;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing





-- Start of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PVT.REVERSE_ENTRIES
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPREVB.pls call OKL_REVERSAL_PVT.REVERSE_ENTRIES ');
    END;
  END IF;
  OKL_REVERSAL_PVT.REVERSE_ENTRIES(p_api_version              => l_api_version,
                                   p_init_msg_list            => p_init_msg_list,
                                   x_return_status            => x_return_status,
                                   x_msg_count                => x_msg_count,
                                   x_msg_data                 => x_msg_data,
                                   p_source_table             => p_source_table,
	 		                       p_acct_date                => p_acct_date,
						           p_source_id_tbl            => p_source_id_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPREVB.pls call OKL_REVERSAL_PVT.REVERSE_ENTRIES ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_REVERSAL_PVT.REVERSE_ENTRIES


   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO REVERSE_ENTRIES;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO REVERSE_ENTRIES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_REVERSAL_PUB','REVERSE_ENTRIES');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END REVERSE_ENTRIES;


END OKL_REVERSAL_PUB;

/

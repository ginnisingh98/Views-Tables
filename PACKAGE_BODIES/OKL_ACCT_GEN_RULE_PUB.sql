--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_GEN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_GEN_RULE_PUB" AS
/* $Header: OKLPACGB.pls 115.7 2002/12/18 12:07:49 kjinger noship $ */


PROCEDURE GET_RULE_LINES_COUNT(p_api_version        IN     NUMBER,
                               p_init_msg_list      IN     VARCHAR2,
                               x_return_status      OUT    NOCOPY VARCHAR2,
                               x_msg_count          OUT    NOCOPY NUMBER,
                               x_msg_data           OUT    NOCOPY VARCHAR2,
		               p_ae_line_type       IN     VARCHAR2,
                               x_line_count         OUT NOCOPY    NUMBER) IS


l_api_version NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'GET_RULE_LINES_COUNT';

l_ae_line_type        VARCHAR2(30) := p_ae_line_type;
l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_line_count          NUMBER := 0;

BEGIN

  SAVEPOINT GET_RULE_LINES_COUNT;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure

  OKL_ACCT_GEN_RULE_PVT.GET_RULE_LINES_COUNT(p_api_version       => l_api_version,
                                             p_init_msg_list     => p_init_msg_list,
                                             x_return_status     => x_return_status,
                                             x_msg_count         => x_msg_count,
                                             x_msg_data          => x_msg_data,
	        		             p_ae_line_type      => l_ae_line_type,
					     x_line_count        => x_line_count);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

  l_line_count := x_line_count;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_RULE_LINES_COUNT;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_RULE_LINES_COUNT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_GEN_RULE_PUB','GET_RULE_LINES_COUNT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END GET_RULE_LINES_COUNT;



PROCEDURE GET_RULE_LINES(p_api_version        IN     NUMBER,
                         p_init_msg_list      IN     VARCHAR2,
                         x_return_status      OUT    NOCOPY VARCHAR2,
                         x_msg_count          OUT    NOCOPY NUMBER,
                         x_msg_data           OUT    NOCOPY VARCHAR2,
		                 p_ae_line_type       IN     VARCHAR2,
                         x_acc_lines          OUT NOCOPY    ACCT_TBL_TYPE) IS


l_api_version NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'GET_RULE_LINES';

l_ae_line_type        VARCHAR2(30) := p_ae_line_type;
l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_acc_lines           ACCT_TBL_TYPE;
l_line_count          NUMBER := 0;

BEGIN

  SAVEPOINT GET_RULE_LINES;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure

  OKL_ACCT_GEN_RULE_PVT.GET_RULE_LINES(p_api_version       => l_api_version,
                                       p_init_msg_list     => p_init_msg_list,
                                       x_return_status     => x_return_status,
                                       x_msg_count         => x_msg_count,
                                       x_msg_data          => x_msg_data,
	        		                   p_ae_line_type      => l_ae_line_type,
					                   x_acc_lines         => x_acc_lines);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

  l_acc_lines := x_acc_lines;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_RULE_LINES;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_RULE_LINES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_GEN_RULE_PUB','GET_RULE_LINES');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END GET_RULE_LINES;




PROCEDURE UPDT_RULE_LINES(p_api_version       IN     NUMBER,
                          p_init_msg_list     IN     VARCHAR2,
                          x_return_status     OUT    NOCOPY VARCHAR2,
                          x_msg_count         OUT    NOCOPY NUMBER,
                          x_msg_data          OUT    NOCOPY VARCHAR2,
                          p_acc_lines         IN     ACCT_TBL_TYPE,
			  x_acc_lines         OUT NOCOPY    ACCT_TBL_TYPE)
IS

l_api_version NUMBER := 1.0;

l_api_name            VARCHAR2(30) := 'UPDT_RULE_LINES';
l_acc_lines_in        ACCT_TBL_TYPE := p_acc_lines;
l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_acc_lines           ACCT_TBL_TYPE;


BEGIN

  SAVEPOINT UPDT_RULE_LINES;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


      OKL_ACCT_GEN_RULE_PVT.UPDT_RULE_LINES(p_api_version       => l_api_version,
                                            p_init_msg_list     => p_init_msg_list,
                                            x_return_status     => x_return_status,
                                            x_msg_count         => x_msg_count,
                                            x_msg_data          => x_msg_data,
                                            p_acc_lines         => l_acc_lines_in,
                                            x_acc_lines         => x_acc_lines);



  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  l_acc_lines := x_acc_lines;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDT_RULE_LINES;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDT_RULE_LINES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_GEN_RULE_PUB','UPDT_RULE_LINES');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END UPDT_RULE_LINES;



END OKL_ACCT_GEN_RULE_PUB;


/

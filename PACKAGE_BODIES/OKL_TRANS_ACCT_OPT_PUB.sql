--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_ACCT_OPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_ACCT_OPT_PUB" AS
/* $Header: OKLPTACB.pls 115.3 2002/12/18 12:41:47 kjinger noship $ */



PROCEDURE GET_TRX_ACCT_OPT(p_api_version      IN     NUMBER,
                           p_init_msg_list    IN     VARCHAR2,
                           x_return_status    OUT    NOCOPY VARCHAR2,
                           x_msg_count        OUT    NOCOPY NUMBER,
                           x_msg_data         OUT    NOCOPY VARCHAR2,
                           p_taov_rec         IN     taov_rec_type,
                           x_taov_rec         OUT    NOCOPY taov_rec_type)
IS


  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'GET_TRX_ACCT_OPT';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_taov_rec          taov_rec_type := p_taov_rec;



BEGIN

  SAVEPOINT GET_TRX_ACCT_OPT;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


  OKL_TRANS_ACCT_OPT_PVT.GET_TRX_ACCT_OPT(p_api_version    => l_api_version,
                                          p_init_msg_list  => p_init_msg_list,
                                          x_return_status  => x_return_status,
                                          x_msg_count      => x_msg_count,
                                          x_msg_data       => x_msg_data,
                                          p_taov_rec       => l_taov_rec,
                                          x_taov_rec       => x_taov_rec);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_TRX_ACCT_OPT;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_TRX_ACCT_OPT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRANS_ACCT_OPT_PUB','GET_TRX_ACCT_OPT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END GET_TRX_ACCT_OPT;





PROCEDURE UPDT_TRX_ACCT_OPT(p_api_version     IN         NUMBER,
                            p_init_msg_list   IN         VARCHAR2,
                            x_return_status   OUT        NOCOPY VARCHAR2,
                            x_msg_count       OUT        NOCOPY NUMBER,
                            x_msg_data        OUT        NOCOPY VARCHAR2,
                            p_taov_rec        IN         taov_rec_type,
                            x_taov_rec        OUT        NOCOPY taov_rec_type)
IS


  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'UPDT_TRX_ACCT_OPT';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_taov_rec          taov_rec_type := p_taov_rec;



BEGIN

  SAVEPOINT UPDT_TRX_ACCT_OPT;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure



     OKL_TRANS_ACCT_OPT_PVT.UPDT_TRX_ACCT_OPT(p_api_version    => l_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                              p_taov_rec       => l_taov_rec,
                                              x_taov_rec       => x_taov_rec);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDT_TRX_ACCT_OPT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDT_TRX_ACCT_OPT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRANS_ACCT_OPT_PUB','UPDT_TRX_ACCT_OPT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END UPDT_TRX_ACCT_OPT;


END OKL_TRANS_ACCT_OPT_PUB;


/

--------------------------------------------------------
--  DDL for Package Body OKL_SYSTEM_ACCT_OPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYSTEM_ACCT_OPT_PUB" AS
/* $Header: OKLPSYOB.pls 115.4 2002/12/18 12:41:34 kjinger noship $ */


PROCEDURE GET_SYSTEM_ACCT_OPT(p_api_version      IN    NUMBER,
                              p_init_msg_list    IN    VARCHAR2,
                              x_return_status    OUT   NOCOPY VARCHAR2,
                              x_msg_count        OUT   NOCOPY NUMBER,
                              x_msg_data         OUT   NOCOPY VARCHAR2,
                              p_set_of_books_id  IN    NUMBER,
                              x_saov_rec         OUT   NOCOPY saov_rec_type)

IS

  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'GET_SYSTEM_ACCT_OPT';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_set_of_books_id   NUMBER := p_set_of_books_id;



BEGIN


  SAVEPOINT GET_SYSTEM_ACCT_OPT1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


  OKL_SYSTEM_ACCT_OPT_PVT.GET_SYSTEM_ACCT_OPT(p_api_version      => l_api_version,
                                              p_init_msg_list    => p_init_msg_list,
                                              x_return_status    => x_return_status,
                                              x_msg_count        => x_msg_count,
                                              x_msg_data         => x_msg_data,
                                              p_set_of_books_id  => l_set_of_books_id,
                                              x_saov_rec         => x_saov_rec);


  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_SYSTEM_ACCT_OPT1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_SYSTEM_ACCT_OPT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO GET_SYSTEM_ACCT_OPT1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_ACCT_OPT_PUB','GET_SYSTEM_ACCT_OPT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END GET_SYSTEM_ACCT_OPT;




PROCEDURE UPDT_SYSTEM_ACCT_OPT(p_api_version    IN          NUMBER,
                               p_init_msg_list  IN          VARCHAR2,
                               x_return_status  OUT         NOCOPY VARCHAR2,
                               x_msg_count      OUT         NOCOPY NUMBER,
                               x_msg_data       OUT         NOCOPY VARCHAR2,
                               p_saov_rec       IN          saov_rec_type,
                               x_saov_rec       OUT         NOCOPY saov_rec_type)
IS


  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'UPDT_SYSTEM_ACCT_OPT';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_saov_rec          saov_rec_type := p_saov_rec;




BEGIN


  SAVEPOINT UPDT_SYSTEM_ACCT_OPT1;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure

     OKL_SYSTEM_ACCT_OPT_PVT.UPDT_SYSTEM_ACCT_OPT(p_api_version      => l_api_version,
                                                  p_init_msg_list    => p_init_msg_list,
                                                  x_return_status    => x_return_status,
                                                  x_msg_count        => x_msg_count,
                                                  x_msg_data         => x_msg_data,
                                                  p_saov_rec         => l_saov_rec,
                                                  x_saov_rec         => x_saov_rec);


  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN

      RAISE FND_API.G_EXC_ERROR;

  END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDT_SYSTEM_ACCT_OPT1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDT_SYSTEM_ACCT_OPT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO UPDT_SYSTEM_ACCT_OPT1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SYSTEM_ACCT_OPT_PUB','UPDT_SYSTEM_ACCT_OPT');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END UPDT_SYSTEM_ACCT_OPT;

END OKL_SYSTEM_ACCT_OPT_PUB;


/

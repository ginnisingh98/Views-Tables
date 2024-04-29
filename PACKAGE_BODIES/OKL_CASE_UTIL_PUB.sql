--------------------------------------------------------
--  DDL for Package Body OKL_CASE_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASE_UTIL_PUB" AS
/* $Header: OKLPCUTB.pls 115.5 2004/04/13 10:43:23 rnaik noship $ */

  ----------------------------------------------------------------------
  -- PROCEDURE CREATE_CASE
  ----------------------------------------------------------------------
  PROCEDURE CREATE_CASE(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id			IN NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  )
  IS

  l_api_version     NUMBER ;
  l_init_msg_list   VARCHAR2(1) ;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER ;
  l_msg_data        VARCHAR2(2000);
  l_contract_id     NUMBER;

  BEGIN

    SAVEPOINT CREATE_CASE;

    l_api_version    := p_api_version ;
    l_init_msg_list  := p_init_msg_list ;
    l_return_status  := x_return_status ;
    l_msg_count      := x_msg_count ;
    l_msg_data       := x_msg_data ;

    l_contract_id    := p_contract_id;



    -- Private API Call start
    OKL_CASE_UTIL_PVT.CREATE_CASE(
               p_api_version         => l_api_version,
               p_init_msg_list       => l_init_msg_list,
               p_contract_id		 => l_contract_id,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data
  		   );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Public API Call end



    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        SAVEPOINT CREATE_CASE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_CASE_UTIL_PUB','CREATE_CASE');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
				           ,p_data    => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        SAVEPOINT CREATE_CASE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_CASE_UTIL_PUB','CREATE_CASE');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
                                   ,p_data    => x_msg_data);

      WHEN OTHERS THEN
        SAVEPOINT CREATE_CASE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_CASE_UTIL_PUB','CREATE_CASE');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
                                   ,p_data    => x_msg_data);

  END CREATE_CASE;

END OKL_CASE_UTIL_PUB;

/

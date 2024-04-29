--------------------------------------------------------
--  DDL for Package Body OKL_AM_RV_WRITEDOWN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RV_WRITEDOWN_PUB" AS
/* $Header: OKLPRVWB.pls 115.7 2004/04/13 11:04:07 rnaik noship $ */

   PROCEDURE create_residual_value_trx( p_api_version           IN   NUMBER,
                                  p_init_msg_list          IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status          OUT    NOCOPY VARCHAR2,
                                  x_msg_count              OUT    NOCOPY NUMBER,
                                  x_msg_data               OUT    NOCOPY VARCHAR2,
                                  p_assets_tbl             IN     assets_tbl_type,
                                  x_residual_value_status  OUT    NOCOPY  VARCHAR2) IS -- this flag is redundant,
                                                                                  -- we are keeping it for the time
                                                                                  -- being to avoid
                                                                                  -- rosetta regeneration

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

    lp_assets_tbl  assets_tbl_type;



BEGIN
SAVEPOINT trx_create_residual_value_trx;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;

lp_assets_tbl := p_assets_tbl;

l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;





-- call the insert of pvt

	OKL_AM_RV_WRITEDOWN_PVT.create_residual_value_trx(   p_api_version          => l_api_version,
                                                        p_init_msg_list         => l_init_msg_list,
                                                        x_return_status         => l_return_status ,
                                                        x_msg_count             => l_msg_count,
                                                        x_msg_data              => l_msg_data,
                                                        p_assets_tbl            => lp_assets_tbl,
                                                        x_residual_value_status  => x_residual_value_status);



IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
  	 RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_residual_value_trx;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_residual_value_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_residual_value_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_RV_WRITEDOWN_PUB','create_residual_value_trx');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_residual_value_trx;




END OKL_AM_RV_WRITEDOWN_PUB;

/

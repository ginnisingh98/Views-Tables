--------------------------------------------------------
--  DDL for Package Body OKL_AM_LOAD_CAT_BK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LOAD_CAT_BK_PUB" AS
/* $Header: OKLPLCBB.pls 120.3 2005/10/30 04:25:33 appldev noship $ */

   PROCEDURE create_hold_setup_trx( p_api_version           IN   NUMBER,
                                  p_init_msg_list         IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  p_book_type_code        IN   fa_book_controls.book_type_code%TYPE,
                                  x_return_status         OUT  NOCOPY VARCHAR2,
                                  x_msg_count             OUT  NOCOPY NUMBER,
                                  x_msg_data              OUT  NOCOPY VARCHAR2,
                                  x_amhv_tbl              OUT  NOCOPY amhv_tbl_type
                                  ) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lx_amhv_tbl    amhv_tbl_type;
    l_book_type_code fa_book_controls.book_type_code%TYPE;

BEGIN
SAVEPOINT trx_create_hold_setup_trx;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_book_type_code := p_book_type_code;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lx_amhv_tbl :=  x_amhv_tbl;



-- call the insert of pvt

	OKL_AM_LOAD_CAT_BK_PVT.create_hold_setup_trx(   p_api_version          => l_api_version,
                                                        p_init_msg_list        => l_init_msg_list,
                                                        p_book_type_code       => l_book_type_code,
                                                        x_return_status        => l_return_status ,
                                                        x_msg_count            => l_msg_count,
                                                        x_msg_data             => l_msg_data,
                                                        x_amhv_tbl             => lx_amhv_tbl
                                                        );



IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
  	 RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_amhv_tbl := lx_amhv_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_hold_setup_trx;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_hold_setup_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_hold_setup_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_LOAD_CAT_BK_PUB','create_hold_setup_trx');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_hold_setup_trx;




END OKL_AM_LOAD_CAT_BK_PUB;

/

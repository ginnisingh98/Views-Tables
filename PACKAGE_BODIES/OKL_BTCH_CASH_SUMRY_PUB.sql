--------------------------------------------------------
--  DDL for Package Body OKL_BTCH_CASH_SUMRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BTCH_CASH_SUMRY_PUB" AS
/* $Header: OKLPBASB.pls 115.4 2004/04/21 19:15:28 bvaghela noship $ */
PROCEDURE okl_batch_sumry (  p_api_version	   IN	NUMBER
				            ,p_init_msg_list   IN   VARCHAR2
				            ,x_return_status   OUT  NOCOPY VARCHAR2
				            ,x_msg_count	   OUT  NOCOPY NUMBER
				            ,x_msg_data	       OUT  NOCOPY VARCHAR2
                            ,p_btch_tbl        IN   okl_btch_sumry_tbl_type
					      ) IS

l_api_version 			NUMBER := 1;
l_init_msg_list 		VARCHAR2(1) ;
l_return_status 		VARCHAR2(1);
l_msg_count 			NUMBER := 0;
l_msg_data 				VARCHAR2(2000);

lp_btch_tbl             okl_btch_sumry_tbl_type;
lx_btch_tbl         		okl_btch_sumry_tbl_type;

BEGIN

    SAVEPOINT okl_batch_sumry;


    l_api_version 			  := p_api_version ;
    l_init_msg_list 		  := p_init_msg_list ;
    l_return_status 		  := x_return_status ;
    l_msg_count 			  := x_msg_count ;
    l_msg_data 				  := x_msg_data ;

    lp_btch_tbl       		  := p_btch_tbl;

    Okl_Btch_Cash_sumry_pvt.handle_batch_sumry( l_api_version
				                               ,l_init_msg_list
				                               ,l_return_status
				                               ,l_msg_count
				                               ,l_msg_data
                                               ,lp_btch_tbl
                                               );

    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO okl_batch_sumry;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      ROLLBACK TO okl_batch_sumry;
      x_return_status :=  Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

    WHEN OTHERS THEN
      ROLLBACK TO okl_batch_sumry;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_BTCH_CASH_SUMRY_PUB','unknown exception');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


 END okl_batch_sumry;

END OKL_BTCH_CASH_SUMRY_PUB;

/

--------------------------------------------------------
--  DDL for Package Body OKL_BTCH_CASH_APPLIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BTCH_CASH_APPLIC_PUB" AS
/* $Header: OKLPBAPB.pls 115.7 2004/04/13 10:32:29 rnaik noship $ */

PROCEDURE okl_batch_cash_applic (  p_api_version	   IN	NUMBER
				                  ,p_init_msg_list     IN	VARCHAR2
				                  ,x_return_status     OUT  NOCOPY VARCHAR2
				                  ,x_msg_count	       OUT  NOCOPY NUMBER
				                  ,x_msg_data	       OUT  NOCOPY VARCHAR2
                                  ,p_btch_tbl          IN   okl_btch_dtls_tbl_type
                                  ,x_btch_tbl          OUT  NOCOPY okl_btch_dtls_tbl_type
							     ) IS

l_api_version 			NUMBER := 1;
l_init_msg_list 		VARCHAR2(1) ;
l_return_status 		VARCHAR2(1);
l_msg_count 			NUMBER := 0;
l_msg_data 				VARCHAR2(2000);

lp_btch_tbl             okl_btch_dtls_tbl_type;

lx_btch_tbl         		okl_btch_dtls_tbl_type;

BEGIN


SAVEPOINT cash_appl_rules;


l_api_version 			  := p_api_version ;
l_init_msg_list 		  := p_init_msg_list ;
l_return_status 		  := x_return_status ;
l_msg_count 			  := x_msg_count ;
l_msg_data 				  := x_msg_data ;

lp_btch_tbl       		  := p_btch_tbl;





    Okl_Btch_Cash_Applic.handle_batch_pay  ( l_api_version
				                            ,l_init_msg_list
				                            ,l_return_status
				                            ,l_msg_count
				                            ,l_msg_data
                                            ,lp_btch_tbl
                                            ,lx_btch_tbl
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
      ROLLBACK TO cash_appl_rules;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
--      Fnd_Msg_Pub.count_and_get(
--             p_count   => x_msg_count
--            ,p_data    => x_msg_data);

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      ROLLBACK TO cash_appl_rules;
      x_return_status :=  Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
--      Fnd_Msg_Pub.count_and_get(
--             p_count   => x_msg_count
--            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO cash_appl_rules;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_BTCH_CASH_APPLIC_PUB','unknown exception');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


 END okl_batch_cash_applic;

END OKL_BTCH_CASH_APPLIC_PUB;

/

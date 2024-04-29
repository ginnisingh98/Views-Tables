--------------------------------------------------------
--  DDL for Package Body OKL_CASH_RULES_SUMRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_RULES_SUMRY_PUB" AS
/* $Header: OKLPCSYB.pls 115.0 2002/12/10 18:04:27 stmathew noship $ */

PROCEDURE okl_cash_rl_sumry ( p_api_version	   IN	NUMBER
				             ,p_init_msg_list  IN   VARCHAR2
				             ,x_return_status  OUT  NOCOPY VARCHAR2
				             ,x_msg_count	   OUT  NOCOPY NUMBER
				             ,x_msg_data	   OUT  NOCOPY VARCHAR2
                             ,p_cash_rl_tbl    IN   okl_cash_rl_sumry_tbl_type
					        ) IS

l_api_version 			NUMBER := 1;
l_init_msg_list 		VARCHAR2(1);
l_return_status 		VARCHAR2(1);
l_msg_count 			NUMBER := 0;
l_msg_data 				VARCHAR2(2000);

lp_cash_rl_tbl          okl_cash_rl_sumry_tbl_type;
lx_cash_rl_tbl          okl_cash_rl_sumry_tbl_type;

BEGIN

    SAVEPOINT okl_cash_rl_sumry;

    l_api_version 			  := p_api_version ;
    l_init_msg_list 		  := p_init_msg_list ;
    l_return_status 		  := x_return_status ;
    l_msg_count 			  := x_msg_count ;
    l_msg_data 				  := x_msg_data ;

    lp_cash_rl_tbl    		  := p_cash_rl_tbl;

    Okl_cash_rules_sumry_pvt.handle_cash_rl_sumry( l_api_version
				                                  ,l_init_msg_list
				                                  ,l_return_status
				                                  ,l_msg_count
				                                  ,l_msg_data
                                                  ,lp_cash_rl_tbl
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
      ROLLBACK TO okl_cash_rl_sumry;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
--      Fnd_Msg_Pub.count_and_get(
--             p_count   => x_msg_count
--            ,p_data    => x_msg_data);

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      ROLLBACK TO okl_cash_rl_sumry;
      x_return_status :=  Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
--      Fnd_Msg_Pub.count_and_get(
--             p_count   => x_msg_count
--            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO okl_cash_rl_sumry;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CASH_RULES_SUMRY_PUB','unknown exception');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


 END okl_cash_rl_sumry;

END OKL_CASH_RULES_SUMRY_PUB;

/

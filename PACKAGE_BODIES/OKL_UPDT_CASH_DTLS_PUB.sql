--------------------------------------------------------
--  DDL for Package Body OKL_UPDT_CASH_DTLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UPDT_CASH_DTLS_PUB" AS
/* $Header: OKLPCUPB.pls 115.8 2004/04/13 10:43:10 rnaik noship $ */

PROCEDURE updt_cash_dtls_pub  ( p_api_version	   IN  NUMBER
		                       ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status    OUT NOCOPY VARCHAR2
				               ,x_msg_count	       OUT NOCOPY NUMBER
				               ,x_msg_data	       OUT NOCOPY VARCHAR2
                               ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                               ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
       					       )IS

l_api_version 			NUMBER ;
l_init_msg_list 		VARCHAR2(1) ;
l_return_status 		VARCHAR2(1);
l_msg_count 			NUMBER ;
l_msg_data 				VARCHAR2(2000);

lp_strm_tbl             okl_cash_dtls_tbl_type;

lx_strm_tbl             okl_cash_dtls_tbl_type;

BEGIN

SAVEPOINT updt_cash_dtls_pub;


l_api_version 			  := p_api_version ;
l_init_msg_list 		  := p_init_msg_list ;
l_return_status 		  := x_return_status ;
l_msg_count 			  := x_msg_count ;
l_msg_data 				  := x_msg_data ;

lp_strm_tbl               := p_strm_tbl;





Okl_Updt_Cash_Dtls.update_cash_details  ( p_api_version
				                         ,p_init_msg_list
				                         ,x_return_status
				                         ,x_msg_count
				                         ,x_msg_data
                                         ,lp_strm_tbl
                                         ,lx_strm_tbl
 						  	  		    );



    IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
		RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO updt_cash_dtls_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO updt_cash_dtls_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO updt_cash_dtls_pub;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CASH_UPDT_CASH_DTLS_PUB','unexpected error');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

 END updt_cash_dtls_pub;

END Okl_Updt_Cash_Dtls_Pub;

/

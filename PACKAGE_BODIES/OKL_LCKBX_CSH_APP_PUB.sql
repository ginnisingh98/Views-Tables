--------------------------------------------------------
--  DDL for Package Body OKL_LCKBX_CSH_APP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LCKBX_CSH_APP_PUB" AS
/* $Header: OKLPLBXB.pls 115.3 2002/12/18 12:23:26 kjinger noship $ */

--Object type procedure for insert
PROCEDURE handle_auto_pay   ( p_api_version	     IN	 NUMBER
  				             ,p_init_msg_list    IN	 VARCHAR2 DEFAULT Okc_Api.G_FALSE
                             ,x_return_status    OUT NOCOPY VARCHAR2
                             ,x_msg_count	     OUT NOCOPY NUMBER
                             ,x_msg_data	     OUT NOCOPY VARCHAR2
                             ,p_trans_req_id     IN  AR_PAYMENTS_INTERFACE.TRANSMISSION_REQUEST_ID%TYPE
                             ) IS

   l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_api_version			 NUMBER := 1;
   l_init_msg_list			 VARCHAR2(1);
   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   lp_trans_req_id           AR_PAYMENTS_INTERFACE.TRANSMISSION_REQUEST_ID%TYPE;
   lx_trans_req_id           AR_PAYMENTS_INTERFACE.TRANSMISSION_REQUEST_ID%TYPE;

BEGIN

   SAVEPOINT save_Insert_row;

   l_api_version      := p_api_version;
   l_init_msg_list    := p_init_msg_list;
   lp_trans_req_id    := p_trans_req_id;

   -- customer pre-processing



   OKL_LCKBX_CSH_APP_PVT.handle_auto_pay   ( p_api_version
                                            ,p_init_msg_list
                                            ,x_return_status
			                                ,x_msg_count
                                            ,x_msg_data
                                            ,lp_trans_req_id
                                            );


    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   	END IF;

--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_LCKBX_CSH_APP_PUB','insert_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END ;

END OKL_LCKBX_CSH_APP_PUB;

/

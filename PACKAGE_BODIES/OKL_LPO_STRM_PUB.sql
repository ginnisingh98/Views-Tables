--------------------------------------------------------
--  DDL for Package Body OKL_LPO_STRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LPO_STRM_PUB" AS
/* $Header: OKLPLSXB.pls 115.6 2004/04/13 11:42:27 rnaik noship $ */

  PROCEDURE create_lpo_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_lpo_id						IN  NUMBER)
IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

BEGIN





  OKL_LPO_STRM_Pvt.create_lpo_streams(
     p_api_version
	,p_init_msg_list
    ,x_return_status
    ,x_msg_count
    ,x_msg_data
    ,p_lpo_id
	);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION
    WHEN OTHERS THEN
--      ROLLBACK TO cnsld_ar_hdrs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_LPO_STRM_PUB','internal_to_external');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_lpo_streams;

END OKL_LPO_STRM_PUB;

/

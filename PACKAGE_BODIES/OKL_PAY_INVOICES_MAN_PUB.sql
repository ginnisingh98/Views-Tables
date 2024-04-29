--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_MAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_MAN_PUB" AS
/* $Header: OKLPPIMB.pls 115.5 2004/04/13 10:56:45 rnaik noship $ */
PROCEDURE manual_entry(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_man_inv_rec      IN  man_inv_rec_type
    ,x_man_inv_rec      OUT NOCOPY  man_inv_rec_type)
IS
l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(2000);
l_man_inv_rec   man_inv_rec_type;

BEGIN

SAVEPOINT manual_entry;

	okl_pay_invoices_man_pvt.manual_entry(
    p_api_version		=> l_api_version
	,p_init_msg_list	=> p_init_msg_list
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		    => x_msg_data
    ,p_man_inv_rec      => p_man_inv_rec
    ,x_man_inv_rec      => x_man_inv_rec);

IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO manual_entry;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO manual_entry;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO manual_entry;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_INVOICES_MAN_PUB','MANUAL_ENTRY');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END;

PROCEDURE manual_entry(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_man_inv_tbl      IN  man_inv_tbl_type
    ,x_man_inv_tbl      OUT NOCOPY  man_inv_tbl_type)
IS
l_api_version NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_man_inv_rec  man_inv_rec_type;
l_man_inv_tbl  man_inv_tbl_type;

BEGIN

SAVEPOINT manual_entry;





	okl_pay_invoices_man_pvt.manual_entry(
    p_api_version		=> l_api_version
	,p_init_msg_list	=> l_init_msg_list
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		    => x_msg_data
    ,p_man_inv_tbl      => p_man_inv_tbl
    ,x_man_inv_tbl      => x_man_inv_tbl);

IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO manual_entry;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO manual_entry;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO manual_entry;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_INVOICES_MAN_PUB','MANUAL_ENTRY');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END;


END;

/

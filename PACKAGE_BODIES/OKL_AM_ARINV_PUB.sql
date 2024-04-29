--------------------------------------------------------
--  DDL for Package Body OKL_AM_ARINV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ARINV_PUB" AS
/* $Header: OKLPARVB.pls 115.6 2004/04/13 10:31:30 rnaik noship $ */

PROCEDURE create_asset_repair_invoice
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ariv_tbl                     IN  ariv_tbl_type) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

    lp_ariv_tbl  ariv_tbl_type;

BEGIN
SAVEPOINT create_asset_repair_invoice;

l_api_version   := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count     := x_msg_count ;
l_msg_data      := x_msg_data ;
lp_ariv_tbl     := p_ariv_tbl;



-- call the insert of pvt

	OKL_AM_ARINV_PVT.create_asset_repair_invoice (
                                                p_api_version   => l_api_version
	                                           ,p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data      => l_msg_data
	                                           ,x_msg_count     => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ariv_tbl      => lp_ariv_tbl) ;


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
      ROLLBACK TO create_asset_repair_invoice;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_asset_repair_invoice;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_asset_repair_invoice;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ARINV_PUB','create_asset_repair_invoice');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_asset_repair_invoice;




PROCEDURE Approve_Asset_Repair (
	p_api_version  	IN  NUMBER,
	p_init_msg_list	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count   	OUT NOCOPY NUMBER,
	x_msg_data    	OUT NOCOPY VARCHAR2,
	p_ariv_tbl	    IN  ariv_tbl_type,
	x_ariv_tbl	    OUT NOCOPY ariv_tbl_type) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

    lp_ariv_tbl  ariv_tbl_type;
    lx_ariv_tbl  ariv_tbl_type;

BEGIN

SAVEPOINT Trx_Approve_Asset_Repair;

l_api_version   := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count     := x_msg_count ;
l_msg_data      := x_msg_data ;
lp_ariv_tbl     := p_ariv_tbl;
lx_ariv_tbl     := p_ariv_tbl;



-- call the insert of pvt

	OKL_AM_ARINV_PVT.Approve_Asset_Repair (
                                                p_api_version   => l_api_version
	                                           ,p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data      => l_msg_data
	                                           ,x_msg_count     => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ariv_tbl      => lp_ariv_tbl
	                                           ,x_ariv_tbl      => lx_ariv_tbl) ;


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


  lp_ariv_tbl := lx_ariv_tbl;




--Assign value to OUT variables
x_ariv_tbl := lx_ariv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_Approve_Asset_Repair;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_Approve_Asset_Repair;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_Approve_Asset_Repair;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ARINV_PUB','Approve_Asset_Repair');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END Approve_Asset_Repair;

END OKL_AM_ARINV_PUB;

/

--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RETURN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RETURN_PUB" AS
/* $Header: OKLPARRB.pls 120.3 2005/10/30 04:21:33 appldev noship $ */

  -- Start of comments
  -- Procedure Name	  : create_asset_return
  -- Description	  : This procedure calculates the pvt procedure to create
  --                  : asset return.
  -- Business Rules   :
  -- Parameters		  : p_artv_rec - Asset Return record,
  --                  : p_quote_id - Terminatin quote id
  -- Version		  : 1.0
  -- History          : 29 Oct 2004 PAGARG Bug# 3925453
  --                  :             Additional Input parameter quote id
  -- End of comments
PROCEDURE create_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_rec					   	IN artv_rec_type,
    x_artv_rec					    OUT NOCOPY artv_rec_type,
    p_quote_id                      IN NUMBER DEFAULT NULL) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_artv_rec  artv_rec_type;
    lx_artv_rec  artv_rec_type;
    lp_quote_id NUMBER;
BEGIN
SAVEPOINT trx_create_asset_return;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_artv_rec :=  p_artv_rec;
lx_artv_rec :=  x_artv_rec;
lp_quote_id := p_quote_id;

-- call the insert of pvt

	OKL_AM_ASSET_RETURN_PVT.create_asset_return(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_artv_rec => lp_artv_rec
	                                              ,x_artv_rec => lx_artv_rec
                                                  ,p_quote_id => lp_quote_id) ;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_artv_rec := lx_artv_rec;



--Assign value to OUT variables
x_artv_rec  := lx_artv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_asset_return;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RETURN_PUB','create_asset_return');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_asset_return;


PROCEDURE update_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_rec					   	IN artv_rec_type,
    x_artv_rec					    OUT NOCOPY artv_rec_type) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_artv_rec  artv_rec_type;
    lx_artv_rec  artv_rec_type;

BEGIN
SAVEPOINT trx_update_asset_return;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_artv_rec :=  p_artv_rec;
lx_artv_rec :=  x_artv_rec;

-- call the update of pvt

	OKL_AM_ASSET_RETURN_PVT.update_asset_return(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_artv_rec => lp_artv_rec
	                                              ,x_artv_rec => lx_artv_rec) ;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_artv_rec := lx_artv_rec;



--Assign value to OUT variables
x_artv_rec  := lx_artv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RETURN_PUB','update_asset_return');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END update_asset_return;

  -- Start of comments
  -- Procedure Name	  : create_asset_return
  -- Description	  : This procedure calculates the pvt procedure to create
  --                  : asset return.
  -- Business Rules   :
  -- Parameters		  : p_artv_tbl - Asset Return table of records,
  --                  : p_quote_id - Terminatin quote id
  -- Version		  : 1.0
  -- History          : 29 Oct 2004 PAGARG Bug# 3925453
  --                  :             Additional Input parameter quote id
  -- End of comments
  PROCEDURE create_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_tbl					   	IN artv_tbl_type,
    x_artv_tbl					   	OUT NOCOPY artv_tbl_type,
    p_quote_id                      IN NUMBER DEFAULT NULL) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_artv_tbl  artv_tbl_type;
    lx_artv_tbl  artv_tbl_type;
    lp_quote_id  NUMBER;
BEGIN
SAVEPOINT trx_update_asset_return;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_artv_tbl :=  p_artv_tbl;
lx_artv_tbl :=  x_artv_tbl;
lp_quote_id := p_quote_id;

-- call the update of pvt

	OKL_AM_ASSET_RETURN_PVT.create_asset_return(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_artv_tbl => lp_artv_tbl
	                                              ,x_artv_tbl => lx_artv_tbl
                                                  ,p_quote_id => lp_quote_id) ;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_artv_tbl := lx_artv_tbl;



--Assign value to OUT variables
x_artv_tbl  := lx_artv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RETURN_PUB','create_asset_return');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END create_asset_return;

  PROCEDURE update_asset_return(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_artv_tbl					   	IN artv_tbl_type,
    x_artv_tbl					   	OUT NOCOPY artv_tbl_type) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_artv_tbl  artv_tbl_type;
    lx_artv_tbl  artv_tbl_type;

BEGIN
SAVEPOINT trx_update_asset_return;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_artv_tbl :=  p_artv_tbl;
lx_artv_tbl :=  x_artv_tbl;




-- call the update of pvt

	OKL_AM_ASSET_RETURN_PVT.update_asset_return(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_artv_tbl => lp_artv_tbl
	                                              ,x_artv_tbl => lx_artv_tbl) ;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_artv_tbl := lx_artv_tbl;



--Assign value to OUT variables
x_artv_tbl  := lx_artv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_asset_return;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RETURN_PUB','update_asset_return');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END update_asset_return;



END OKL_AM_ASSET_RETURN_PUB;

/

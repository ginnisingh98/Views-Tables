--------------------------------------------------------
--  DDL for Package Body OKL_AM_REPURCHASE_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_REPURCHASE_ASSET_PUB" AS
/* $Header: OKLPRQUB.pls 115.4 2004/04/13 11:02:58 rnaik noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE Relocate_Installed_Asset
  ---------------------------------------------------------------------------

  PROCEDURE create_repurchase_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_qtev_rec                      IN qtev_rec_type,
    p_tqlv_tbl					   	IN tqlv_tbl_type,
    x_qtev_rec                      OUT NOCOPY qtev_rec_type,
    x_tqlv_tbl					   	OUT NOCOPY tqlv_tbl_type) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

  BEGIN
    SAVEPOINT create_repurchase_quote;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
	l_msg_count := x_msg_count ;
	l_msg_data := x_msg_data ;




	-- call the insert of pvt

	OKL_AM_REPURCHASE_ASSET_PVT.create_repurchase_quote(
                                                p_api_version            => l_api_version,
	                                            p_init_msg_list          => l_init_msg_list ,
                                                x_return_status          => l_return_status,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data,
											    p_qtev_rec               => p_qtev_rec,
											    p_tqlv_tbl               => p_tqlv_tbl,
											    x_qtev_rec               => x_qtev_rec,
											    x_tqlv_tbl               => x_tqlv_tbl);


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
	      ROLLBACK TO create_repurchase_quote;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO create_repurchase_quote;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN OTHERS THEN
	      ROLLBACK TO create_repurchase_quote;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_REPURCHASE_ASSET_PUB','create_repurchase_quote');
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END create_repurchase_quote;


  PROCEDURE update_repurchase_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_qtev_rec                      IN qtev_rec_type,
    p_tqlv_tbl					   	IN tqlv_tbl_type,
    x_qtev_rec                      OUT NOCOPY qtev_rec_type,
    x_tqlv_tbl					   	OUT NOCOPY tqlv_tbl_type) IS


    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);


  BEGIN
    SAVEPOINT update_repurchase_quote;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
	l_msg_count := x_msg_count ;
	l_msg_data := x_msg_data ;




	-- call the insert of pvt

	OKL_AM_REPURCHASE_ASSET_PVT.update_repurchase_quote(
                                                p_api_version            => l_api_version,
	                                            p_init_msg_list          => l_init_msg_list ,
                                                x_return_status          => l_return_status,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data,
											    p_qtev_rec               => p_qtev_rec,
											    p_tqlv_tbl               => p_tqlv_tbl,
											    x_qtev_rec               => x_qtev_rec,
											    x_tqlv_tbl               => x_tqlv_tbl);


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
	      ROLLBACK TO update_repurchase_quote;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO update_repurchase_quote;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN OTHERS THEN
	      ROLLBACK TO update_repurchase_quote;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_REPURCHASE_ASSET_PUB','update_repurchase_quote');
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END update_repurchase_quote;

END OKL_AM_REPURCHASE_ASSET_PUB;

/

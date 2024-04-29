--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RELOCATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RELOCATION_PUB" AS
/* $Header: OKLPAREB.pls 115.8 2004/04/13 10:30:54 rnaik noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE Relocate_Installed_Asset
  ---------------------------------------------------------------------------

  PROCEDURE Relocate_Installed_Item
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ialo_tbl                     IN  ialo_tbl_type) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_ialo_tbl   ialo_tbl_type;

  BEGIN
    SAVEPOINT relocate_installed_item;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
	l_msg_count := x_msg_count ;
	l_msg_data := x_msg_data ;

    lp_ialo_tbl := p_ialo_tbl;



	-- call the insert of pvt

	OKL_AM_ASSET_RELOCATION_PVT.Relocate_Installed_Item(
                                                p_api_version            => l_api_version,
	                                            p_init_msg_list          => l_init_msg_list ,
                                                x_return_status          => l_return_status,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data,
											    p_ialo_tbl               => lp_ialo_tbl);


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
	      ROLLBACK TO relocate_installed_item;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO relocate_installed_item;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN OTHERS THEN
	      ROLLBACK TO relocate_installed_item;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RELOCATION_PUB','Relocate_Installed_Item');
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END Relocate_Installed_Item;

  ---------------------------------------------------------------------------
  -- PROCEDURE Relocate_Fixed_Asset
  ---------------------------------------------------------------------------

  PROCEDURE Relocate_Fixed_Asset
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_falo_tbl                     IN  falo_tbl_type) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_falo_tbl   falo_tbl_type;
  BEGIN
    SAVEPOINT relocate_fixed_asset;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
	l_msg_count := x_msg_count ;
	l_msg_data := x_msg_data ;


    lp_falo_tbl := p_falo_tbl ;


	-- call the insert of pvt

	OKL_AM_ASSET_RELOCATION_PVT.Relocate_Fixed_Asset(
                                                p_api_version            => l_api_version,
	                                            p_init_msg_list          => l_init_msg_list ,
                                                x_return_status          => l_return_status,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data,
											    p_falo_tbl               => lp_falo_tbl);


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
	      ROLLBACK TO relocate_fixed_asset;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO relocate_fixed_asset;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN OTHERS THEN
	      ROLLBACK TO relocate_fixed_asset;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RELOCATION_PUB','Relocate_Fixed_Asset');
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END Relocate_Fixed_Asset;

  ---------------------------------------------------------------------------
  -- PROCEDURE Change_FA_Location
  ---------------------------------------------------------------------------

  PROCEDURE Change_FA_Location (
                                p_api_version           IN  	NUMBER,
           			            p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
           		 	            x_return_status         OUT 	NOCOPY VARCHAR2,
           			            x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
                                p_assets_tbl            IN      falo_tbl_type )    IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_assets_tbl   falo_tbl_type;
  BEGIN
    SAVEPOINT trx_relocate_asset;


    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
	l_msg_count := x_msg_count ;
	l_msg_data := x_msg_data ;
    lp_assets_tbl := p_assets_tbl ;




	-- call the insert of pvt

	OKL_AM_ASSET_RELOCATION_PVT.Change_FA_Location (
												p_api_version          => l_api_version,
                                                p_init_msg_list        => l_init_msg_list,
                                                x_return_status        => l_return_status ,
                                                x_msg_count            => l_msg_count,
                                                x_msg_data             => l_msg_data,
                                                p_assets_tbl           => lp_assets_tbl);


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
	      ROLLBACK TO trx_relocate_asset;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO trx_relocate_asset;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN OTHERS THEN
	      ROLLBACK TO trx_relocate_asset;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RELOCATION_PUB','Change_FA_Location ');
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END Change_FA_Location ;

  ---------------------------------------------------------------------------
  -- PROCEDURE Change_Item_Location
  ---------------------------------------------------------------------------

  PROCEDURE Change_Item_Location (
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
		x_msg_count				OUT NOCOPY NUMBER,
		x_msg_data				OUT NOCOPY VARCHAR2,
		x_return_status			OUT NOCOPY VARCHAR2,
		p_instance_id			IN NUMBER,
		p_location_id			IN NUMBER,
		p_install_location_id	IN NUMBER DEFAULT NULL) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

    lp_instance_id  NUMBER;
    lp_location_id  NUMBER;
    lp_install_location_id  NUMBER;

  BEGIN
    SAVEPOINT change_item_location;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
	l_msg_count := x_msg_count ;
	l_msg_data := x_msg_data ;

    lp_instance_id := p_instance_id ;
    lp_location_id := p_location_id;
    lp_install_location_id  := p_install_location_id;



	-- call the insert of pvt

	OKL_AM_ASSET_RELOCATION_PVT.Change_Item_Location(
                                                p_api_version            => l_api_version,
	                                            p_init_msg_list          => l_init_msg_list ,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data,
                                                x_return_status          => l_return_status,
												p_instance_id			 => lp_instance_id,
												p_location_id			 => lp_location_id,
												p_install_location_id	 => lp_install_location_id);


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
	      ROLLBACK TO change_item_location;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO change_item_location;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	    WHEN OTHERS THEN
	      ROLLBACK TO change_item_location;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      x_msg_count := l_msg_count ;
	      x_msg_data := l_msg_data ;
	      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_RELOCATION_PUB','Change_Item_Location');
	      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END Change_Item_Location;

END OKL_AM_ASSET_RELOCATION_PUB;

/

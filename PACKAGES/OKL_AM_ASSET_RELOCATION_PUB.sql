--------------------------------------------------------
--  DDL for Package OKL_AM_ASSET_RELOCATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ASSET_RELOCATION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPARES.pls 115.4 2002/04/16 19:33:08 pkm ship        $ */

SUBTYPE falo_tbl_type  IS OKL_AM_ASSET_RELOCATION_PVT.falo_tbl_type;
SUBTYPE ialo_tbl_type  IS OKL_AM_ASSET_RELOCATION_PVT.ialo_tbl_type;

---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_ASSET_RELOCATE_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

   G_EXCEPTION_HALT_PROCESS          EXCEPTION;

  PROCEDURE Relocate_Installed_Item
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ialo_tbl                     IN  ialo_tbl_type
    ) ;

  PROCEDURE Relocate_Fixed_Asset
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_falo_tbl                     IN  falo_tbl_type
    ) ;

  -- Change location of installed base item instance
  PROCEDURE Change_Item_Location
    ( p_api_version		            IN  NUMBER
    , p_init_msg_list		        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_msg_count		            OUT NOCOPY NUMBER
    , x_msg_data		            OUT NOCOPY VARCHAR2
    , x_return_status	            OUT NOCOPY VARCHAR2
    , p_instance_id		            IN NUMBER
    , p_location_id		            IN NUMBER
    , p_install_location_id	        IN NUMBER DEFAULT NULL
    );

  PROCEDURE Change_FA_Location
    ( p_api_version                 IN	NUMBER
    , p_init_msg_list               IN	VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status               OUT NOCOPY VARCHAR2
    , x_msg_count                   OUT	NOCOPY NUMBER
    , x_msg_data                    OUT	NOCOPY VARCHAR2
    , p_assets_tbl                  IN  falo_tbl_type
    );

END OKL_AM_ASSET_RELOCATION_PUB;

 

/

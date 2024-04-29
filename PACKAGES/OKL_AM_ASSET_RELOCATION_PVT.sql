--------------------------------------------------------
--  DDL for Package OKL_AM_ASSET_RELOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ASSET_RELOCATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRARES.pls 115.4 2002/04/16 19:34:07 pkm ship        $ */

  TYPE falo_rec_type is RECORD( p_cle_id                NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_asset_id              NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_asset_number          VARCHAR2(15),
                                p_corporate_book        VARCHAR2(15),
                                p_current_units         NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_distribution_id       NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_units_assigned        NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_assigned_to           NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_code_combination_id   NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_old_location_id       NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_new_location_id       NUMBER DEFAULT OKC_API.G_MISS_NUM);

  TYPE falo_tbl_type IS TABLE OF falo_rec_type INDEX BY BINARY_INTEGER;




  TYPE ialo_rec_type IS RECORD( p_instance_id              NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_location_id              NUMBER DEFAULT OKC_API.G_MISS_NUM,
                                p_install_location_id      NUMBER DEFAULT OKC_API.G_MISS_NUM );

  TYPE ialo_tbl_type IS TABLE OF ialo_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_AM_ASSET_RELOCATION_PVT';
  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_API_VERSION		     CONSTANT   NUMBER		:= 1;
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) := okc_api.G_INVALID_VALUE;
  G_REQUIRED_VALUE       CONSTANT   VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
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

END OKL_AM_ASSET_RELOCATION_PVT;

 

/

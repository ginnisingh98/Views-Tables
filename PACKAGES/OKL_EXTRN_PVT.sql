--------------------------------------------------------
--  DDL for Package OKL_EXTRN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXTRN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCXCRS.pls 115.1 2002/03/18 08:28:49 pkm ship        $ */

 SUBTYPE xcrv_rec_type IS Okl_Xcr_Pvt.xcrv_rec_type;
 SUBTYPE xcrv_tbl_type IS Okl_Xcr_Pvt.xcrv_tbl_type;

 SUBTYPE xcav_rec_type IS Okl_Xca_Pvt.xcav_rec_type;
 SUBTYPE xcav_tbl_type IS Okl_Xca_Pvt.xcav_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_Extrn_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'Okl_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE ADD_LANGUAGE;

 --Object type procedure for insert
 PROCEDURE create_ext_csh_txns(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_xcrv_rec                     IN xcrv_rec_type
    ,p_xcav_tbl                     IN xcav_tbl_type
    ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
    ,x_xcav_tbl                     OUT NOCOPY xcav_tbl_type
    );

 --Object type procedure for update
 PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,p_xcav_tbl                     IN xcav_tbl_type
   ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
   ,x_xcav_tbl                     OUT NOCOPY xcav_tbl_type
    );

  --Object type procedure for update
 PROCEDURE delete_ext_csh_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,p_xcav_tbl                     IN xcav_tbl_type
   ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
   ,x_xcav_tbl                     OUT NOCOPY xcav_tbl_type
    );

 --Object type procedure for validate
 PROCEDURE validate_ext_csh_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,p_xcav_tbl                     IN xcav_tbl_type
    );

 PROCEDURE create_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type,
    x_xcrv_tbl                     OUT NOCOPY xcrv_tbl_type);

 PROCEDURE create_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type,
    x_xcrv_rec                     OUT NOCOPY xcrv_rec_type);

 PROCEDURE lock_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type);

 PROCEDURE lock_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type);

 PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type,
    x_xcrv_tbl                     OUT NOCOPY xcrv_tbl_type);

 PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type,
    x_xcrv_rec                     OUT NOCOPY xcrv_rec_type);

 PROCEDURE delete_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type);

 PROCEDURE delete_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type);

  PROCEDURE validate_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type);

 PROCEDURE validate_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type);


 PROCEDURE create_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_tbl                     IN xcav_tbl_type,
    x_xcav_tbl                     OUT NOCOPY xcav_tbl_type);

 PROCEDURE create_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_rec                     IN xcav_rec_type,
    x_xcav_rec                     OUT NOCOPY xcav_rec_type);

 PROCEDURE lock_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_tbl                     IN xcav_tbl_type);

 PROCEDURE lock_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_rec                     IN xcav_rec_type);

 PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_tbl                     IN xcav_tbl_type,
    x_xcav_tbl                     OUT NOCOPY xcav_tbl_type);

 PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_rec                     IN xcav_rec_type,
    x_xcav_rec                     OUT NOCOPY xcav_rec_type);

 PROCEDURE delete_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_tbl                     IN xcav_tbl_type);

 PROCEDURE delete_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_rec                     IN xcav_rec_type);

  PROCEDURE validate_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_tbl                     IN xcav_tbl_type);

 PROCEDURE validate_ext_csh_txns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcav_rec                     IN xcav_rec_type);

END Okl_Extrn_Pvt;

 

/

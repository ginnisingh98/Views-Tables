--------------------------------------------------------
--  DDL for Package OKL_XCR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XCR_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPXCRS.pls 115.6 2002/04/02 16:41:36 pkm ship        $ */

 SUBTYPE xcrv_rec_type IS Okl_Extrn_Pvt.xcrv_rec_type;
 SUBTYPE xcrv_tbl_type IS Okl_Extrn_Pvt.xcrv_tbl_type;

 SUBTYPE xcav_rec_type IS Okl_Extrn_Pvt.xcav_rec_type;
 SUBTYPE xcav_tbl_type IS Okl_Extrn_Pvt.xcav_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_EXTRN_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE ADD_LANGUAGE;

 --Object type procedure for insert
 PROCEDURE create_ext_ar_txns(
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
 PROCEDURE update_ext_ar_txns(
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

 PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
    );

 --Object type procedure for update
 PROCEDURE delete_ext_ar_txns(
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
 PROCEDURE validate_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,p_xcav_tbl                     IN xcav_tbl_type
    );

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
    );

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_tbl                     IN xcrv_tbl_type
    );

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcav_rec                     IN xcav_rec_type
    );

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcav_tbl                     IN xcav_tbl_type
    );

END Okl_Xcr_Pub;

 

/

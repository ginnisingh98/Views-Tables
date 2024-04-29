--------------------------------------------------------
--  DDL for Package OKL_RCT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RCT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRCTS.pls 115.3 2002/02/05 12:08:39 pkm ship       $ */

 SUBTYPE rctv_rec_type IS Okl_Rct_Pvt.rctv_rec_type;
 SUBTYPE rctv_tbl_type IS Okl_Rct_Pvt.rctv_tbl_type;

 SUBTYPE rcav_rec_type IS Okl_Rca_Pvt.rcav_rec_type;
 SUBTYPE rcav_tbl_type IS Okl_Rca_Pvt.rcav_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ARTRX_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 PROCEDURE create_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
    ,p_rcav_tbl                     IN rcav_tbl_type
    ,x_rctv_rec                     OUT NOCOPY rctv_rec_type
    ,x_rcav_tbl                     OUT NOCOPY rcav_tbl_type
    );

 --Object type procedure for update
 PROCEDURE update_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
   ,p_rcav_tbl                     IN rcav_tbl_type
   ,x_rctv_rec                     OUT NOCOPY rctv_rec_type
   ,x_rcav_tbl                     OUT NOCOPY rcav_tbl_type
    );

	 --Object type procedure for update
 PROCEDURE delete_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
   ,p_rcav_tbl                     IN rcav_tbl_type
   ,x_rctv_rec                     OUT NOCOPY rctv_rec_type
   ,x_rcav_tbl                     OUT NOCOPY rcav_tbl_type
    );

 --Object type procedure for validate
 PROCEDURE validate_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
   ,p_rcav_tbl                     IN rcav_tbl_type
    );

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
    );

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_tbl                     IN rctv_tbl_type
    );

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rcav_rec                     IN rcav_rec_type
    );

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rcav_tbl                     IN rcav_tbl_type
    );

END Okl_Rct_Pub;

 

/
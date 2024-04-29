--------------------------------------------------------
--  DDL for Package OKL_ACC_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACC_GROUP_PVT" AUTHID CURRENT_USER as
/* $Header: OKLCAGCS.pls 115.1 2002/02/05 11:48:41 pkm ship       $ */

 subtype agcv_rec_type is okl_agc_pvt.agcv_rec_type;
 subtype agcv_tbl_type is okl_agc_pvt.agcv_tbl_type;

 subtype agbv_rec_type is okl_agb_pvt.agbv_rec_type;
 subtype agbv_tbl_type is okl_agb_pvt.agbv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ACC_GROUP_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 --Object type procedure for insert
 PROCEDURE create_acc_group(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agcv_rec                     IN agcv_rec_type
   ,p_agbv_tbl                     IN agbv_tbl_type
   ,x_agcv_rec                     OUT NOCOPY agcv_rec_type
   ,x_agbv_tbl                     OUT NOCOPY agbv_tbl_type
    );

 --Object type procedure for update
 PROCEDURE update_acc_group(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agcv_rec                     IN agcv_rec_type
   ,p_agbv_tbl                     IN agbv_tbl_type
   ,x_agcv_rec                     OUT NOCOPY agcv_rec_type
   ,x_agbv_tbl                     OUT NOCOPY agbv_tbl_type );

 --Object type procedure for validate
 PROCEDURE validate_acc_group(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agcv_rec                     IN agcv_rec_type
   ,p_agbv_tbl                     IN agbv_tbl_type
    );

 PROCEDURE create_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type,
    x_agcv_tbl                     OUT NOCOPY agcv_tbl_type);

 PROCEDURE create_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type,
    x_agcv_rec                     OUT NOCOPY agcv_rec_type);

 PROCEDURE lock_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type);

 PROCEDURE lock_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type);

 PROCEDURE update_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type,
    x_agcv_tbl                     OUT NOCOPY agcv_tbl_type);

 PROCEDURE update_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type,
    x_agcv_rec                     OUT NOCOPY agcv_rec_type);

 PROCEDURE delete_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type);

 PROCEDURE delete_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type);

  PROCEDURE validate_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type);

 PROCEDURE validate_acc_ccid(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type);


 PROCEDURE create_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type,
    x_agbv_tbl                     OUT NOCOPY agbv_tbl_type);

 PROCEDURE create_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type,
    x_agbv_rec                     OUT NOCOPY agbv_rec_type);

 PROCEDURE lock_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type);

 PROCEDURE lock_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type);

 PROCEDURE update_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type,
    x_agbv_tbl                     OUT NOCOPY agbv_tbl_type);

 PROCEDURE update_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type,
    x_agbv_rec                     OUT NOCOPY agbv_rec_type);

 PROCEDURE delete_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type);

 PROCEDURE delete_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type);

  PROCEDURE validate_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_tbl                     IN agbv_tbl_type);

 PROCEDURE validate_acc_bal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agbv_rec                     IN agbv_rec_type);

END OKL_ACC_GROUP_PVT;


 

/

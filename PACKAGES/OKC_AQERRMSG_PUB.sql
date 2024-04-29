--------------------------------------------------------
--  DDL for Package OKC_AQERRMSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AQERRMSG_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPAQES.pls 120.0 2005/05/30 04:13:38 appldev noship $ */

 subtype aqev_rec_type is okc_aqe_pvt.aqev_rec_type;
 subtype aqev_tbl_type is okc_aqe_pvt.aqev_tbl_type;
 subtype aqmv_rec_type is okc_aqm_pvt.aqmv_rec_type;
 subtype aqmv_tbl_type is okc_aqm_pvt.aqmv_tbl_type;

 ----------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_AQERRMSG_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

 g_aqev_rec	        okc_aqe_pvt.aqev_rec_type;
 g_aqev_tbl             okc_aqe_pvt.aqev_tbl_type;
 g_aqmv_rec             okc_aqm_pvt.aqmv_rec_type;
 g_aqmv_tbl             okc_aqm_pvt.aqmv_tbl_type;
 ----------------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------

 --Object type procedure for insert
 PROCEDURE create_err_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    p_aqmv_tbl                     IN aqmv_tbl_type,
    x_aqev_rec                     OUT NOCOPY aqev_rec_type,
    x_aqmv_tbl                     OUT NOCOPY aqmv_tbl_type);

 --Object type procedure for update
 PROCEDURE update_err_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    p_aqmv_tbl                     IN aqmv_tbl_type,
    x_aqev_rec                     OUT NOCOPY aqev_rec_type,
    x_aqmv_tbl                     OUT NOCOPY aqmv_tbl_type);

 --Object type procedure for validate
 PROCEDURE validate_err_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    p_aqmv_tbl                     IN aqmv_tbl_type);

 --Procedures for Errors
 PROCEDURE create_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type,
    x_aqev_tbl                     OUT NOCOPY aqev_tbl_type);

 PROCEDURE create_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    x_aqev_rec                     OUT NOCOPY aqev_rec_type);

 PROCEDURE lock_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type);

 PROCEDURE lock_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type);

 PROCEDURE update_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type,
    x_aqev_tbl                     OUT NOCOPY aqev_tbl_type);

 PROCEDURE update_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    x_aqev_rec                     OUT NOCOPY aqev_rec_type);

 PROCEDURE delete_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type);

 PROCEDURE delete_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type);

  PROCEDURE validate_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type);

 PROCEDURE validate_err(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type);

 --Procedures for Messages
 PROCEDURE create_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_tbl                     IN aqmv_tbl_type,
    x_aqmv_tbl                     OUT NOCOPY aqmv_tbl_type);

 PROCEDURE create_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_rec                     IN aqmv_rec_type,
    x_aqmv_rec                     OUT NOCOPY aqmv_rec_type);

 PROCEDURE lock_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_tbl                     IN aqmv_tbl_type);

 PROCEDURE lock_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_rec                     IN aqmv_rec_type);

 PROCEDURE update_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_tbl                     IN aqmv_tbl_type,
    x_aqmv_tbl                     OUT NOCOPY aqmv_tbl_type);

 PROCEDURE update_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_rec                     IN aqmv_rec_type,
    x_aqmv_rec                     OUT NOCOPY aqmv_rec_type);

 PROCEDURE delete_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_rec                     IN aqmv_rec_type);

 PROCEDURE delete_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_tbl                     IN aqmv_tbl_type);

 PROCEDURE validate_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_tbl                     IN aqmv_tbl_type);

 PROCEDURE validate_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqmv_rec                     IN aqmv_rec_type);

END okc_aqerrmsg_pub;

 

/

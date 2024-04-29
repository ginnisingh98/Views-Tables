--------------------------------------------------------
--  DDL for Package OKC_OUTCOME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OUTCOME_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPOCES.pls 120.0 2005/05/26 09:56:15 appldev noship $ */

 subtype ocev_rec_type is okc_outcome_pvt.ocev_rec_type;
 subtype ocev_tbl_type is okc_outcome_pvt.ocev_tbl_type;
 subtype oatv_rec_type is okc_outcome_pvt.oatv_rec_type;
 subtype oatv_tbl_type is okc_outcome_pvt.oatv_tbl_type;

 ----------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_OUTCOME_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

 g_ocev_rec	        okc_outcome_pvt.ocev_rec_type;
 g_ocev_tbl             okc_outcome_pvt.ocev_tbl_type;
 g_oatv_rec             okc_outcome_pvt.oatv_rec_type;
 g_oatv_tbl             okc_outcome_pvt.oatv_tbl_type;
 ----------------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------

 PROCEDURE ADD_LANGUAGE;

 --Object type procedure for insert
 PROCEDURE create_outcomes_args(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    p_oatv_tbl                     IN oatv_tbl_type,
    x_ocev_rec                     OUT NOCOPY ocev_rec_type,
    x_oatv_tbl                     OUT NOCOPY oatv_tbl_type);

 --Object type procedure for update
 PROCEDURE update_outcomes_args(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    p_oatv_tbl                     IN oatv_tbl_type,
    x_ocev_rec                     OUT NOCOPY ocev_rec_type,
    x_oatv_tbl                     OUT NOCOPY oatv_tbl_type);

 --Object type procedure for validate
 PROCEDURE validate_outcomes_args(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    p_oatv_tbl                     IN oatv_tbl_type);

 --Procedures for Outcomes
 PROCEDURE create_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type,
    x_ocev_tbl                     OUT NOCOPY ocev_tbl_type);

 PROCEDURE create_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    x_ocev_rec                     OUT NOCOPY ocev_rec_type);

 PROCEDURE lock_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type);

 PROCEDURE lock_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type);

 PROCEDURE update_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type,
    x_ocev_tbl                     OUT NOCOPY ocev_tbl_type);

 PROCEDURE update_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type,
    x_ocev_rec                     OUT NOCOPY ocev_rec_type);

 PROCEDURE delete_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type);

 PROCEDURE delete_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type);

  PROCEDURE validate_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_tbl                     IN ocev_tbl_type);

 PROCEDURE validate_outcome(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ocev_rec                     IN ocev_rec_type);

 --Procedures for Outcome arguments
 PROCEDURE create_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type,
    x_oatv_tbl                     OUT NOCOPY oatv_tbl_type);

 PROCEDURE create_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type,
    x_oatv_rec                     OUT NOCOPY oatv_rec_type);

 PROCEDURE lock_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type);

 PROCEDURE lock_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type);

 PROCEDURE update_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type,
    x_oatv_tbl                     OUT NOCOPY oatv_tbl_type);

 PROCEDURE update_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type,
    x_oatv_rec                     OUT NOCOPY oatv_rec_type);

 PROCEDURE delete_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type);

 PROCEDURE delete_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type);

 PROCEDURE validate_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type);

 PROCEDURE validate_out_arg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type);

END okc_outcome_pub;

 

/

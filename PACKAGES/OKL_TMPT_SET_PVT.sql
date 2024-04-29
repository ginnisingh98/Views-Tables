--------------------------------------------------------
--  DDL for Package OKL_TMPT_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TMPT_SET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCAESS.pls 115.2 2002/02/05 11:48:34 pkm ship       $ */

 SUBTYPE aesv_rec_type IS okl_aes_pvt.aesv_rec_type;
 SUBTYPE aesv_tbl_type IS okl_aes_pvt.aesv_tbl_type;

 SUBTYPE avlv_rec_type IS okl_avl_pvt.avlv_rec_type;
 SUBTYPE avlv_tbl_type IS okl_avl_pvt.avlv_tbl_type;

 SUBTYPE atlv_rec_type IS okl_atl_pvt.atlv_rec_type;
 SUBTYPE atlv_tbl_type IS okl_atl_pvt.atlv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'okl_template';
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
 PROCEDURE create_tmpt_set(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aesv_rec                     IN aesv_rec_type
    ,p_avlv_tbl                     IN avlv_tbl_type
    ,p_atlv_tbl                     IN atlv_tbl_type
    ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
    ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
    ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type
    );

 --Object type procedure for update
 PROCEDURE update_tmpt_set(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aesv_rec                     IN aesv_rec_type
   ,p_avlv_tbl                     IN avlv_tbl_type
   ,p_atlv_tbl                     IN atlv_tbl_type
   ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
   ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
   ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type
    );

 --Object type procedure for validate
 PROCEDURE validate_tmpt_set(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aesv_rec                     IN aesv_rec_type
   ,p_avlv_tbl                     IN avlv_tbl_type
   ,p_atlv_tbl                     IN atlv_tbl_type
    );


 PROCEDURE create_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type,
    x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);

 PROCEDURE create_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type,
    x_aesv_rec                     OUT NOCOPY aesv_rec_type);

 PROCEDURE lock_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type);

 PROCEDURE lock_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type);

 PROCEDURE update_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type,
    x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);

 PROCEDURE update_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type,
    x_aesv_rec                     OUT NOCOPY aesv_rec_type);

 PROCEDURE delete_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type);

 PROCEDURE delete_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type);

  PROCEDURE validate_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_tbl                     IN aesv_tbl_type);

 PROCEDURE validate_tmpt_set(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aesv_rec                     IN aesv_rec_type);


 PROCEDURE create_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type,
    x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);

 PROCEDURE create_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type,
    x_avlv_rec                     OUT NOCOPY avlv_rec_type);

 PROCEDURE lock_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type);

 PROCEDURE lock_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type);

 PROCEDURE update_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type,
    x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);

 PROCEDURE update_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type,
    x_avlv_rec                     OUT NOCOPY avlv_rec_type);

 PROCEDURE delete_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type);

 PROCEDURE delete_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type);

  PROCEDURE validate_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_tbl                     IN avlv_tbl_type);

 PROCEDURE validate_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_avlv_rec                     IN avlv_rec_type);


 PROCEDURE create_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type,
    x_atlv_tbl                     OUT NOCOPY atlv_tbl_type);

 PROCEDURE create_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type,
    x_atlv_rec                     OUT NOCOPY atlv_rec_type);

 PROCEDURE lock_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type);

 PROCEDURE lock_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type);

 PROCEDURE update_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type,
    x_atlv_tbl                     OUT NOCOPY atlv_tbl_type);

 PROCEDURE update_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type,
    x_atlv_rec                     OUT NOCOPY atlv_rec_type);

 PROCEDURE delete_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type);

 PROCEDURE delete_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type);

  PROCEDURE validate_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_tbl                     IN atlv_tbl_type);

 PROCEDURE validate_tmpt_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atlv_rec                     IN atlv_rec_type);

END okl_tmpt_set_pvt;

 

/

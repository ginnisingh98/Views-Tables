--------------------------------------------------------
--  DDL for Package OKL_PROCESS_TMPT_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_TMPT_SET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTMSS.pls 120.3 2005/10/30 04:39:11 appldev noship $ */
  -- Global Variables
    G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200)  := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
    G_DATES_MISMATCH		CONSTANT VARCHAR2(200)  := 'OKL_DATES_MISMATCH';
    G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200)  := 'OKL_SQLERRM';
    G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200)  := 'OKL_SQLCODE';
    G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(100)  := OKL_API.G_PARENT_TABLE_TOKEN;
    G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(100)  := OKL_API.G_CHILD_TABLE_TOKEN;
    G_APP_NAME			CONSTANT VARCHAR2(3)    :=  OKL_API.G_APP_NAME;
    G_PKG_NAME                  CONSTANT VARCHAR2(30)   := 'OKL_SETUP_PRICEPARMS_PVT';
    G_MISS_NUM			CONSTANT NUMBER         := OKL_API.G_MISS_NUM;
    G_MISS_CHAR			CONSTANT VARCHAR2(1) 	:= OKL_API.G_MISS_CHAR;
    G_MISS_DATE			CONSTANT DATE 		:= OKL_API.G_MISS_DATE;
    G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
    G_RET_STS_UNEXP_ERROR	CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
    G_RET_STS_ERROR		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
    G_EXC_NAME_RET_STS_ERR		CONSTANT VARCHAR(25) := 'OKL_API.G_RET_STS_ERROR';
    G_EXC_NAME_RET_STS_UNEXP_ERR	CONSTANT VARCHAR(30) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
    G_EXC_NAME_OTHERS			CONSTANT VARCHAR2(6) := 'OTHERS';
    G_API_TYPE				CONSTANT VARCHAR(4) 	:= '_PVT';
    G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
    G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
    G_END_DATE				  CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
    G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;
    G_REQUIRED_VALUE           CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;

    G_EXCEPTION_HALT_PROCESSING 	EXCEPTION;
    G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;
    G_EXCEPTION_ERROR			EXCEPTION;

    G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
    G_TRUE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
    G_FALSE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

    SUBTYPE aesv_rec_type IS okl_tmpt_set_pub.aesv_rec_type;
    SUBTYPE aesv_tbl_type IS okl_tmpt_set_pub.aesv_tbl_type;
    SUBTYPE avlv_rec_type IS okl_tmpt_set_pub.avlv_rec_type;
    SUBTYPE avlv_tbl_type IS okl_tmpt_set_pub.avlv_tbl_type;
    SUBTYPE atlv_rec_type IS okl_tmpt_set_pub.atlv_rec_type;
    SUBTYPE atlv_tbl_type IS okl_tmpt_set_pub.atlv_tbl_type;


  PROCEDURE create_tmpt_set(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_aesv_rec                     IN  aesv_rec_type
    ,p_avlv_tbl                     IN  avlv_tbl_type
    ,p_atlv_tbl			    IN atlv_tbl_type
    ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
    ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
    ,x_atlv_tbl			    OUT NOCOPY atlv_tbl_type );

  --Object type procedure for update
  PROCEDURE update_tmpt_set(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_aesv_rec                     IN  aesv_rec_type
    ,p_avlv_tbl                     IN  avlv_tbl_type
    ,p_atlv_tbl			    IN atlv_tbl_type
    ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
    ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
    ,x_atlv_tbl			    OUT NOCOPY atlv_tbl_type );

 PROCEDURE create_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_tbl                     IN  aesv_tbl_type,
     x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);

  PROCEDURE create_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_rec                     IN  aesv_rec_type,
     x_aesv_rec                     OUT NOCOPY aesv_rec_type,
     p_aes_source_id	            IN  OKL_AE_TMPT_SETS.id%TYPE DEFAULT NULL);

  PROCEDURE update_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_tbl                     IN  aesv_tbl_type,
     x_aesv_tbl                     OUT NOCOPY aesv_tbl_type);

  PROCEDURE update_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_rec                     IN  aesv_rec_type,
     x_aesv_rec                     OUT NOCOPY aesv_rec_type);

  PROCEDURE delete_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_tbl                     IN  aesv_tbl_type);

  PROCEDURE delete_tmpt_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aesv_rec                     IN aesv_rec_type);

 PROCEDURE create_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type,
     x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);

PROCEDURE create_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_rec                     IN  avlv_rec_type,
     x_avlv_rec                     OUT NOCOPY avlv_rec_type);

  PROCEDURE update_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type,
     x_avlv_tbl                     OUT NOCOPY avlv_tbl_type);

  PROCEDURE update_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_rec                     IN  avlv_rec_type,
     x_avlv_rec                     OUT NOCOPY avlv_rec_type);

  PROCEDURE delete_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_tbl                     IN  avlv_tbl_type);

  PROCEDURE delete_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_rec                     IN  avlv_rec_type);

PROCEDURE create_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_tbl                     IN  atlv_tbl_type,
     x_atlv_tbl                     OUT NOCOPY atlv_tbl_type);

  PROCEDURE create_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_rec                     IN  atlv_rec_type,
     x_atlv_rec                     OUT NOCOPY atlv_rec_type);

  PROCEDURE update_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_tbl                     IN  atlv_tbl_type,
     x_atlv_tbl                     OUT NOCOPY atlv_tbl_type);

  PROCEDURE update_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_rec                     IN  atlv_rec_type,
     x_atlv_rec                     OUT NOCOPY atlv_rec_type);

  PROCEDURE delete_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_tbl                     IN  atlv_tbl_type);

  PROCEDURE delete_tmpt_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_atlv_rec                     IN  atlv_rec_type);

   -- mvasudev -- 02/13/2002
  PROCEDURE copy_tmpl_set(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_aes_id_from                  IN  NUMBER,
     p_aes_id_to                    IN  NUMBER);


  PROCEDURE copy_template(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_avlv_rec                     IN  avlv_rec_type,
     p_source_tmpl_id               IN  NUMBER,
     x_avlv_rec                     OUT NOCOPY avlv_rec_type);
  --end,  mvasudev -- 02/13/2002

--kmotepal ER# 3944429
  PROCEDURE validate_gts_id (p_gts_id         IN  NUMBER
                             ,x_return_status OUT NOCOPY  VARCHAR2);

END OKL_PROCESS_TMPT_SET_PVT;

 

/

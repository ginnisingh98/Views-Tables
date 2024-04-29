--------------------------------------------------------
--  DDL for Package OKL_PROCESS_PROVISIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_PROVISIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPRVS.pls 115.2 2002/02/11 19:40:50 pkm ship      $ */

  SUBTYPE pvnv_rec_type IS OKL_PROVISIONS_PUB.pvnv_rec_type;
  SUBTYPE pvnv_tbl_type IS OKL_PROVISIONS_PUB.pvnv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		  CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH			  CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  		  CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE				  CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE				  CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		  CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_PARENT_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		  CONSTANT VARCHAR2(100) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_COL_NAME_TOKEN			  CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_PROCESS_PROVISIONS_PVT';

  G_INIT_VERSION			  CONSTANT NUMBER := 1.0;
  G_VERSION_MAJOR_INCREMENT	  CONSTANT NUMBER := 1.0;
  G_VERSION_MINOR_INCREMENT	  CONSTANT NUMBER := 0.1;
  G_VERSION_FORMAT			  CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_FORMULA_TYPE			  CONSTANT VARCHAR2(10) := 'GRNC';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;
  G_MISS_NUM	CONSTANT NUMBER := OKL_API.G_MISS_NUM;
  G_MISS_CHAR	CONSTANT VARCHAR2(1) := OKL_API.G_MISS_CHAR;
  G_MISS_DATE	CONSTANT DATE := OKL_API.G_MISS_DATE;

  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);


  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type);

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type);


END OKL_PROCESS_PROVISIONS_PVT;

 

/

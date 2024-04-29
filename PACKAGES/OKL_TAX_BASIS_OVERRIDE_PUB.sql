--------------------------------------------------------
--  DDL for Package OKL_TAX_BASIS_OVERRIDE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAX_BASIS_OVERRIDE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTBOS.pls 120.0 2005/08/26 19:44:56 sechawla noship $ */



 SUBTYPE tbov_rec_type IS okl_tbo_pvt.tbov_rec_type;
 SUBTYPE tbov_tbl_type IS okl_tbo_pvt.tbov_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TAX_BASIS_OVERRIDE_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


   PROCEDURE insert_TAX_BASIS_OVERRIDE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN  tbov_rec_type,
    x_tbov_rec                     OUT NOCOPY tbov_rec_type);


  PROCEDURE insert_TAX_BASIS_OVERRIDE(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                     IN  tbov_tbl_type,
    x_tbov_tbl                     OUT NOCOPY tbov_tbl_type);

  PROCEDURE lock_TAX_BASIS_OVERRIDE(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN tbov_rec_type);


  PROCEDURE lock_TAX_BASIS_OVERRIDE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                     IN tbov_tbl_type);

  PROCEDURE update_TAX_BASIS_OVERRIDE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN tbov_rec_type,
    x_tbov_rec                     OUT NOCOPY tbov_rec_type);


  PROCEDURE update_TAX_BASIS_OVERRIDE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                     IN tbov_tbl_type,
    x_tbov_tbl                     OUT NOCOPY tbov_tbl_type);

  PROCEDURE delete_TAX_BASIS_OVERRIDE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN tbov_rec_type);


  PROCEDURE delete_TAX_BASIS_OVERRIDE(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                     IN tbov_tbl_type);

  PROCEDURE validate_TAX_BASIS_OVERRIDE(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_rec                     IN tbov_rec_type);


  PROCEDURE validate_TAX_BASIS_OVERRIDE(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tbov_tbl                     IN  tbov_tbl_type);

END OKL_TAX_BASIS_OVERRIDE_PUB;

 

/

--------------------------------------------------------
--  DDL for Package OKL_PROCESS_TRX_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_TRX_TYPES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTXTS.pls 115.2 2002/02/18 20:12:19 pkm ship       $ */

  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_TRX_TYPES_PUB';


  SUBTYPE tryv_rec_type IS OKL_PROCESS_TRX_TYPES_PVT.tryv_rec_type;
  SUBTYPE tryv_tbl_type IS OKL_PROCESS_TRX_TYPES_PVT.tryv_tbl_type;


  PROCEDURE insert_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type);


  PROCEDURE insert_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type);


  PROCEDURE update_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type);

  PROCEDURE update_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type);

  PROCEDURE delete_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type);


  PROCEDURE delete_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type);

END OKL_PROCESS_TRX_TYPES_PUB;

 

/

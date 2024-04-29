--------------------------------------------------------
--  DDL for Package OKL_TRANS_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANS_CONTRACTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTCTS.pls 115.3 2002/03/21 17:02:41 pkm ship       $ */


  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pub.tcnv_rec_type;

  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pub.tcnv_tbl_type;



  SUBTYPE tclv_rec_type IS okl_trx_contracts_pub.tclv_rec_type;

  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pub.tclv_tbl_type;


 PROCEDURE create_trx_contracts(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_tcnv_rec                     IN  tcnv_rec_type

    ,p_tclv_tbl                     IN  tclv_tbl_type

    ,x_tcnv_rec                     OUT NOCOPY tcnv_rec_type

    ,x_tclv_tbl                     OUT NOCOPY tclv_tbl_type

     );


  PROCEDURE create_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN  tcnv_rec_type,

     x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);



  PROCEDURE create_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type,

     x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);



  PROCEDURE create_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type,

     x_tclv_rec                     OUT NOCOPY tclv_rec_type);



  PROCEDURE create_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type,

     x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);



  PROCEDURE update_trx_contracts(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_tcnv_rec                     IN  tcnv_rec_type

    ,p_tclv_tbl                     IN  tclv_tbl_type

    ,x_tcnv_rec                     OUT NOCOPY tcnv_rec_type

    ,x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);


  PROCEDURE update_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN  tcnv_rec_type,

     x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);



  PROCEDURE update_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type,

     x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);


  PROCEDURE update_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type,

     x_tclv_rec                     OUT NOCOPY tclv_rec_type);



  PROCEDURE update_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type,

     x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);


  PROCEDURE delete_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN tcnv_rec_type);



  PROCEDURE delete_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type);


  PROCEDURE delete_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type);


  PROCEDURE delete_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type);


G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_TRANS_CONTRACTS_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKL_API.G_APP_NAME;
G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

END OKL_TRANS_CONTRACTS_PVT;

 

/

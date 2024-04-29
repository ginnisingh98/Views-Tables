--------------------------------------------------------
--  DDL for Package OKL_TRX_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRX_CONTRACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTCNS.pls 115.4 2002/02/18 22:40:30 pkm ship        $ */



  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;

  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pvt.tcnv_tbl_type;



  SUBTYPE tclv_rec_type IS okl_trx_contracts_pvt.tclv_rec_type;

  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pvt.tclv_tbl_type;



  -- GLOBAL MESSAGE CONSTANTS

  ---------------------------------------------------------------------------------

  G_FND_APP                    CONSTANT VARCHAR2(200) :=  OKC_API.G_FND_APP;

  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;

  G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_DELETED;

  G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_CHANGED;

  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) :=  OKC_API.G_RECORD_LOGICALLY_DELETED;

  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;

  G_INVALID_VALUE              CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;

  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;

  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) :=  OKC_API.G_PARENT_TABLE_TOKEN;

  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;

  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';

  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';

  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';

  G_UPPERCASE_REQUIRED         CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';

  ---------------------------------------------------------------------------------



  -- GLOBAL EXCEPTION

  ---------------------------------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------------



  -- GLOBAL VARIABLES

  ---------------------------------------------------------------------------------

  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TRX_CONTRACTS_PUB';

  G_APP_NAME                     CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------------



  g_tcnv_rec                   tcnv_rec_type;

  g_tclv_rec                   tclv_rec_type;



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



  --Object type procedure for update

  PROCEDURE update_trx_contracts(

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



  --Object type procedure for validate

  PROCEDURE validate_trx_contracts(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_tcnv_rec                     IN  tcnv_rec_type

    ,p_tclv_tbl                     IN  tclv_tbl_type

     );







  PROCEDURE create_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type,

     x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);



  PROCEDURE create_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN  tcnv_rec_type,

     x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);



  PROCEDURE lock_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type);



  PROCEDURE lock_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN  tcnv_rec_type);



  PROCEDURE update_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type,

     x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);



  PROCEDURE update_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN  tcnv_rec_type,

     x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);



  PROCEDURE delete_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type);



  PROCEDURE delete_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN tcnv_rec_type);



   PROCEDURE validate_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_tbl                     IN  tcnv_tbl_type);



  PROCEDURE validate_trx_contracts(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tcnv_rec                     IN  tcnv_rec_type);





  PROCEDURE create_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type,

     x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);



  PROCEDURE create_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type,

     x_tclv_rec                     OUT NOCOPY tclv_rec_type);



  PROCEDURE lock_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type);



  PROCEDURE lock_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type);



  PROCEDURE update_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type,

     x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);



  PROCEDURE update_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type,

     x_tclv_rec                     OUT NOCOPY tclv_rec_type);



  PROCEDURE delete_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type);



  PROCEDURE delete_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type);



   PROCEDURE validate_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_tbl                     IN  tclv_tbl_type);



  PROCEDURE validate_trx_cntrct_lines(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_tclv_rec                     IN  tclv_rec_type);



END OKL_TRX_CONTRACTS_PUB;


 

/

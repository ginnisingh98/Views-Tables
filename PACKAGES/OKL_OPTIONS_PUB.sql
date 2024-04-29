--------------------------------------------------------
--  DDL for Package OKL_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPOPTS.pls 115.4 2002/02/18 20:15:34 pkm ship       $ */



  SUBTYPE optv_rec_type IS okl_options_pvt.optv_rec_type;

  SUBTYPE optv_tbl_type IS okl_options_pvt.optv_tbl_type;



  SUBTYPE ovev_rec_type IS okl_options_pvt.ovev_rec_type;

  SUBTYPE ovev_tbl_type IS okl_options_pvt.ovev_tbl_type;



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

  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_OPTIONS_PUB';

  G_APP_NAME                     CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------------



  g_optv_rec                   optv_rec_type;

  g_ovev_rec                   ovev_rec_type;



 PROCEDURE create_options(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_optv_rec                     IN  optv_rec_type

    ,p_ovev_tbl                     IN  ovev_tbl_type

    ,x_optv_rec                     OUT NOCOPY optv_rec_type

    ,x_ovev_tbl                     OUT NOCOPY ovev_tbl_type

     );



  --Object type procedure for update

  PROCEDURE update_options(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_optv_rec                     IN  optv_rec_type

    ,p_ovev_tbl                     IN  ovev_tbl_type

    ,x_optv_rec                     OUT NOCOPY optv_rec_type

    ,x_ovev_tbl                     OUT NOCOPY ovev_tbl_type

     );



  --Object type procedure for validate

  PROCEDURE validate_options(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_optv_rec                     IN  optv_rec_type

    ,p_ovev_tbl                     IN  ovev_tbl_type

     );







  PROCEDURE create_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_tbl                     IN  optv_tbl_type,

     x_optv_tbl                     OUT NOCOPY optv_tbl_type);



  PROCEDURE create_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_rec                     IN  optv_rec_type,

     x_optv_rec                     OUT NOCOPY optv_rec_type);



  PROCEDURE lock_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_tbl                     IN  optv_tbl_type);



  PROCEDURE lock_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_rec                     IN  optv_rec_type);



  PROCEDURE update_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_tbl                     IN  optv_tbl_type,

     x_optv_tbl                     OUT NOCOPY optv_tbl_type);



  PROCEDURE update_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_rec                     IN  optv_rec_type,

     x_optv_rec                     OUT NOCOPY optv_rec_type);



  PROCEDURE delete_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_tbl                     IN  optv_tbl_type);



  PROCEDURE delete_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_rec                     IN optv_rec_type);



   PROCEDURE validate_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_tbl                     IN  optv_tbl_type);



  PROCEDURE validate_options(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_optv_rec                     IN  optv_rec_type);





  PROCEDURE create_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_tbl                     IN  ovev_tbl_type,

     x_ovev_tbl                     OUT NOCOPY ovev_tbl_type);



  PROCEDURE create_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_rec                     IN  ovev_rec_type,

     x_ovev_rec                     OUT NOCOPY ovev_rec_type);



  PROCEDURE lock_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_tbl                     IN  ovev_tbl_type);



  PROCEDURE lock_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_rec                     IN  ovev_rec_type);



  PROCEDURE update_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_tbl                     IN  ovev_tbl_type,

     x_ovev_tbl                     OUT NOCOPY ovev_tbl_type);



  PROCEDURE update_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_rec                     IN  ovev_rec_type,

     x_ovev_rec                     OUT NOCOPY ovev_rec_type);



  PROCEDURE delete_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_tbl                     IN  ovev_tbl_type);



  PROCEDURE delete_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_rec                     IN  ovev_rec_type);



   PROCEDURE validate_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_tbl                     IN  ovev_tbl_type);



  PROCEDURE validate_option_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ovev_rec                     IN  ovev_rec_type);



END OKL_OPTIONS_PUB;


 

/

--------------------------------------------------------
--  DDL for Package OKL_INDICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INDICES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIDXS.pls 115.4 2002/02/18 22:40:23 pkm ship        $ */



  SUBTYPE idxv_rec_type IS okl_indices_pvt.idxv_rec_type;

  SUBTYPE idxv_tbl_type IS okl_indices_pvt.idxv_tbl_type;



  SUBTYPE ivev_rec_type IS okl_indices_pvt.ivev_rec_type;

  SUBTYPE ivev_tbl_type IS okl_indices_pvt.ivev_tbl_type;



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

  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_INDICES_PUB';

  G_APP_NAME                     CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------------



  g_idxv_rec                   idxv_rec_type;

  g_ivev_rec                   ivev_rec_type;



 PROCEDURE create_indices(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_idxv_rec                     IN  idxv_rec_type

    ,p_ivev_tbl                     IN  ivev_tbl_type

    ,x_idxv_rec                     OUT NOCOPY idxv_rec_type

    ,x_ivev_tbl                     OUT NOCOPY ivev_tbl_type

     );



  --Object type procedure for update

  PROCEDURE update_indices(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_idxv_rec                     IN  idxv_rec_type

    ,p_ivev_tbl                     IN  ivev_tbl_type

    ,x_idxv_rec                     OUT NOCOPY idxv_rec_type

    ,x_ivev_tbl                     OUT NOCOPY ivev_tbl_type

     );



  --Object type procedure for validate

  PROCEDURE validate_indices(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_idxv_rec                     IN  idxv_rec_type

    ,p_ivev_tbl                     IN  ivev_tbl_type

     );







  PROCEDURE create_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_tbl                     IN  idxv_tbl_type,

     x_idxv_tbl                     OUT NOCOPY idxv_tbl_type);



  PROCEDURE create_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_rec                     IN  idxv_rec_type,

     x_idxv_rec                     OUT NOCOPY idxv_rec_type);



  PROCEDURE lock_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_tbl                     IN  idxv_tbl_type);



  PROCEDURE lock_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_rec                     IN  idxv_rec_type);



  PROCEDURE update_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_tbl                     IN  idxv_tbl_type,

     x_idxv_tbl                     OUT NOCOPY idxv_tbl_type);



  PROCEDURE update_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_rec                     IN  idxv_rec_type,

     x_idxv_rec                     OUT NOCOPY idxv_rec_type);



  PROCEDURE delete_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_tbl                     IN  idxv_tbl_type);



  PROCEDURE delete_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_rec                     IN idxv_rec_type);



   PROCEDURE validate_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_tbl                     IN  idxv_tbl_type);



  PROCEDURE validate_indices(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_idxv_rec                     IN  idxv_rec_type);





  PROCEDURE create_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_tbl                     IN  ivev_tbl_type,

     x_ivev_tbl                     OUT NOCOPY ivev_tbl_type);



  PROCEDURE create_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_rec                     IN  ivev_rec_type,

     x_ivev_rec                     OUT NOCOPY ivev_rec_type);



  PROCEDURE lock_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_tbl                     IN  ivev_tbl_type);



  PROCEDURE lock_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_rec                     IN  ivev_rec_type);



  PROCEDURE update_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_tbl                     IN  ivev_tbl_type,

     x_ivev_tbl                     OUT NOCOPY ivev_tbl_type);



  PROCEDURE update_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_rec                     IN  ivev_rec_type,

     x_ivev_rec                     OUT NOCOPY ivev_rec_type);



  PROCEDURE delete_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_tbl                     IN  ivev_tbl_type);



  PROCEDURE delete_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_rec                     IN  ivev_rec_type);



   PROCEDURE validate_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_tbl                     IN  ivev_tbl_type);



  PROCEDURE validate_index_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ivev_rec                     IN  ivev_rec_type);



END OKL_INDICES_PUB;


 

/

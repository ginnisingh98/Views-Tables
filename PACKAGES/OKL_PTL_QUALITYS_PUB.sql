--------------------------------------------------------
--  DDL for Package OKL_PTL_QUALITYS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PTL_QUALITYS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPTQS.pls 115.4 2002/02/18 20:15:49 pkm ship       $ */



  SUBTYPE ptqv_rec_type IS okl_ptl_qualitys_pvt.ptqv_rec_type;

  SUBTYPE ptqv_tbl_type IS okl_ptl_qualitys_pvt.ptqv_tbl_type;



  SUBTYPE ptvv_rec_type IS okl_ptl_qualitys_pvt.ptvv_rec_type;

  SUBTYPE ptvv_tbl_type IS okl_ptl_qualitys_pvt.ptvv_tbl_type;



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

  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PTL_QUALITYS_PUB';

  G_APP_NAME                     CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------------



  g_ptqv_rec                   ptqv_rec_type;

  g_ptvv_rec                   ptvv_rec_type;



 PROCEDURE create_ptl_qualitys(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_ptqv_rec                     IN  ptqv_rec_type

    ,p_ptvv_tbl                     IN  ptvv_tbl_type

    ,x_ptqv_rec                     OUT NOCOPY ptqv_rec_type

    ,x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type

     );



  --Object type procedure for update

  PROCEDURE update_ptl_qualitys(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_ptqv_rec                     IN  ptqv_rec_type

    ,p_ptvv_tbl                     IN  ptvv_tbl_type

    ,x_ptqv_rec                     OUT NOCOPY ptqv_rec_type

    ,x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type

     );



  --Object type procedure for validate

  PROCEDURE validate_ptl_qualitys(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_ptqv_rec                     IN  ptqv_rec_type

    ,p_ptvv_tbl                     IN  ptvv_tbl_type

     );







  PROCEDURE create_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_tbl                     IN  ptqv_tbl_type,

     x_ptqv_tbl                     OUT NOCOPY ptqv_tbl_type);



  PROCEDURE create_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_rec                     IN  ptqv_rec_type,

     x_ptqv_rec                     OUT NOCOPY ptqv_rec_type);



  PROCEDURE lock_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_tbl                     IN  ptqv_tbl_type);



  PROCEDURE lock_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_rec                     IN  ptqv_rec_type);



  PROCEDURE update_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_tbl                     IN  ptqv_tbl_type,

     x_ptqv_tbl                     OUT NOCOPY ptqv_tbl_type);



  PROCEDURE update_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_rec                     IN  ptqv_rec_type,

     x_ptqv_rec                     OUT NOCOPY ptqv_rec_type);



  PROCEDURE delete_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_tbl                     IN  ptqv_tbl_type);



  PROCEDURE delete_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_rec                     IN ptqv_rec_type);



   PROCEDURE validate_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_tbl                     IN  ptqv_tbl_type);



  PROCEDURE validate_ptl_qualitys(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptqv_rec                     IN  ptqv_rec_type);





  PROCEDURE create_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_tbl                     IN  ptvv_tbl_type,

     x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type);



  PROCEDURE create_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_rec                     IN  ptvv_rec_type,

     x_ptvv_rec                     OUT NOCOPY ptvv_rec_type);



  PROCEDURE lock_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_tbl                     IN  ptvv_tbl_type);



  PROCEDURE lock_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_rec                     IN  ptvv_rec_type);



  PROCEDURE update_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_tbl                     IN  ptvv_tbl_type,

     x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type);



  PROCEDURE update_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_rec                     IN  ptvv_rec_type,

     x_ptvv_rec                     OUT NOCOPY ptvv_rec_type);



  PROCEDURE delete_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_tbl                     IN  ptvv_tbl_type);



  PROCEDURE delete_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_rec                     IN  ptvv_rec_type);



   PROCEDURE validate_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_tbl                     IN  ptvv_tbl_type);



  PROCEDURE validate_ptl_qlty_values(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_ptvv_rec                     IN  ptvv_rec_type);



END OKL_PTL_QUALITYS_PUB;


 

/

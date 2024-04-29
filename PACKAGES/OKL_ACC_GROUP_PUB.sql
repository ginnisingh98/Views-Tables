--------------------------------------------------------
--  DDL for Package OKL_ACC_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACC_GROUP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPAGCS.pls 115.2 2002/02/18 22:40:15 pkm ship        $ */



  SUBTYPE agcv_rec_type IS okl_acc_group_pvt.agcv_rec_type;

  SUBTYPE agcv_tbl_type IS okl_acc_group_pvt.agcv_tbl_type;



  SUBTYPE agbv_rec_type IS okl_acc_group_pvt.agbv_rec_type;

  SUBTYPE agbv_tbl_type IS okl_acc_group_pvt.agbv_tbl_type;



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

  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_ACC_GROUP_PUB';

  G_APP_NAME                     CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------------



  g_agcv_rec                   agcv_rec_type;

  g_agbv_rec                   agbv_rec_type;



 PROCEDURE create_acc_group(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_agcv_rec                     IN  agcv_rec_type

    ,p_agbv_tbl                     IN  agbv_tbl_type

    ,x_agcv_rec                     OUT NOCOPY agcv_rec_type

    ,x_agbv_tbl                     OUT NOCOPY agbv_tbl_type

     );



  --Object type procedure for update

  PROCEDURE update_acc_group(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_agcv_rec                     IN  agcv_rec_type

    ,p_agbv_tbl                     IN  agbv_tbl_type

    ,x_agcv_rec                     OUT NOCOPY agcv_rec_type

    ,x_agbv_tbl                     OUT NOCOPY agbv_tbl_type

     );



  --Object type procedure for validate

  PROCEDURE validate_acc_group(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_agcv_rec                     IN  agcv_rec_type

    ,p_agbv_tbl                     IN  agbv_tbl_type

     );






  PROCEDURE create_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_tbl                     IN  agcv_tbl_type,

     x_agcv_tbl                     OUT NOCOPY agcv_tbl_type);



  PROCEDURE create_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_rec                     IN  agcv_rec_type,

     x_agcv_rec                     OUT NOCOPY agcv_rec_type);



  PROCEDURE lock_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_tbl                     IN  agcv_tbl_type);



  PROCEDURE lock_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_rec                     IN  agcv_rec_type);



  PROCEDURE update_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_tbl                     IN  agcv_tbl_type,

     x_agcv_tbl                     OUT NOCOPY agcv_tbl_type);



  PROCEDURE update_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_rec                     IN  agcv_rec_type,

     x_agcv_rec                     OUT NOCOPY agcv_rec_type);



  PROCEDURE delete_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_tbl                     IN  agcv_tbl_type);



  PROCEDURE delete_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_rec                     IN agcv_rec_type);



   PROCEDURE validate_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_tbl                     IN  agcv_tbl_type);



  PROCEDURE validate_acc_ccid(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agcv_rec                     IN  agcv_rec_type);





  PROCEDURE create_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_tbl                     IN  agbv_tbl_type,

     x_agbv_tbl                     OUT NOCOPY agbv_tbl_type);



  PROCEDURE create_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_rec                     IN  agbv_rec_type,

     x_agbv_rec                     OUT NOCOPY agbv_rec_type);



  PROCEDURE lock_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_tbl                     IN  agbv_tbl_type);



  PROCEDURE lock_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_rec                     IN  agbv_rec_type);



  PROCEDURE update_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_tbl                     IN  agbv_tbl_type,

     x_agbv_tbl                     OUT NOCOPY agbv_tbl_type);



  PROCEDURE update_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_rec                     IN  agbv_rec_type,

     x_agbv_rec                     OUT NOCOPY agbv_rec_type);



  PROCEDURE delete_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_tbl                     IN  agbv_tbl_type);



  PROCEDURE delete_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_rec                     IN  agbv_rec_type);



   PROCEDURE validate_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_tbl                     IN  agbv_tbl_type);



  PROCEDURE validate_acc_bal(

     p_api_version                  IN  NUMBER,

     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,

     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,

     p_agbv_rec                     IN  agbv_rec_type);



END OKL_ACC_GROUP_PUB;


 

/

--------------------------------------------------------
--  DDL for Package OKL_ACC_GEN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACC_GEN_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCAGRS.pls 115.5 2002/02/18 20:10:26 pkm ship        $ */

 SUBTYPE agrv_rec_type IS okl_agr_pvt.agrv_rec_type;
 SUBTYPE agrv_tbl_type IS okl_agr_pvt.agrv_tbl_type;

 SUBTYPE aulv_rec_type IS okl_aul_pvt.aulv_rec_type;
 SUBTYPE aulv_tbl_type IS okl_aul_pvt.aulv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'okl_acc_gen_rule_pvt';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 --Object type procedure for insert
 PROCEDURE create_acc_gen_rule(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agrv_rec                     IN agrv_rec_type
    ,p_aulv_tbl                     IN aulv_tbl_type
    ,x_agrv_rec                     OUT NOCOPY agrv_rec_type
    ,x_aulv_tbl                     OUT NOCOPY aulv_tbl_type
    );

 --Object type procedure for update
 PROCEDURE update_acc_gen_rule(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agrv_rec                     IN agrv_rec_type
   ,p_aulv_tbl                     IN aulv_tbl_type
   ,x_agrv_rec                     OUT NOCOPY agrv_rec_type
   ,x_aulv_tbl                     OUT NOCOPY aulv_tbl_type
    );

 --Object type procedure for validate
 PROCEDURE validate_acc_gen_rule(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agrv_rec                     IN agrv_rec_type
   ,p_aulv_tbl                     IN aulv_tbl_type
    );


 PROCEDURE create_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_tbl                     IN agrv_tbl_type,
    x_agrv_tbl                     OUT NOCOPY agrv_tbl_type);

 PROCEDURE create_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_rec                     IN agrv_rec_type,
    x_agrv_rec                     OUT NOCOPY agrv_rec_type);

 PROCEDURE lock_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_tbl                     IN agrv_tbl_type);

 PROCEDURE lock_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_rec                     IN agrv_rec_type);

 PROCEDURE update_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_tbl                     IN agrv_tbl_type,
    x_agrv_tbl                     OUT NOCOPY agrv_tbl_type);

 PROCEDURE update_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_rec                     IN agrv_rec_type,
    x_agrv_rec                     OUT NOCOPY agrv_rec_type);

 PROCEDURE delete_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_tbl                     IN agrv_tbl_type);

 PROCEDURE delete_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_rec                     IN agrv_rec_type);

  PROCEDURE validate_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_tbl                     IN agrv_tbl_type);

 PROCEDURE validate_acc_gen_rule(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agrv_rec                     IN agrv_rec_type);


 PROCEDURE create_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type,
    x_aulv_tbl                     OUT NOCOPY aulv_tbl_type);

 PROCEDURE create_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type,
    x_aulv_rec                     OUT NOCOPY aulv_rec_type);

 PROCEDURE lock_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type);

 PROCEDURE lock_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type);

 PROCEDURE update_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type,
    x_aulv_tbl                     OUT NOCOPY aulv_tbl_type);

 PROCEDURE update_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type,
    x_aulv_rec                     OUT NOCOPY aulv_rec_type);

 PROCEDURE delete_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type);

 PROCEDURE delete_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type);

  PROCEDURE validate_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type);

 PROCEDURE validate_acc_gen_rule_lns(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type);

END okl_acc_gen_rule_pvt;

 

/

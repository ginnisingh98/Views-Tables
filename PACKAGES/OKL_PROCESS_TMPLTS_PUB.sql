--------------------------------------------------------
--  DDL for Package OKL_PROCESS_TMPLTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_TMPLTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPTMS.pls 115.6 2002/07/18 18:39:24 rvaduri noship $ */

 subtype PTMv_rec_type is okl_PTM_pvt.PTMv_rec_type;
 subtype PTMv_tbl_type is okl_PTM_pvt.PTMv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PROCESS_TMPLTS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_tbl                     IN  PTMv_tbl_type
    ,x_PTMv_tbl                     OUT  NOCOPY PTMv_tbl_type);

 PROCEDURE insert_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_rec                     IN  PTMv_rec_type
    ,x_PTMv_rec                     OUT  NOCOPY PTMv_rec_type);

 PROCEDURE lock_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_tbl                     IN  PTMv_tbl_type);

 PROCEDURE lock_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_rec                     IN  PTMv_rec_type);

 PROCEDURE update_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_tbl                     IN  PTMv_tbl_type
    ,x_PTMv_tbl                     OUT  NOCOPY PTMv_tbl_type);

 PROCEDURE update_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_rec                     IN  PTMv_rec_type
    ,x_PTMv_rec                     OUT  NOCOPY PTMv_rec_type);

 PROCEDURE delete_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_tbl                     IN  PTMv_tbl_type);

 PROCEDURE delete_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_rec                     IN  PTMv_rec_type);

  PROCEDURE validate_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_tbl                     IN  PTMv_tbl_type);

 PROCEDURE validate_PROCESS_TMPLTS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_PTMv_rec                     IN  PTMv_rec_type);

END okl_process_tmplts_pub;


 

/

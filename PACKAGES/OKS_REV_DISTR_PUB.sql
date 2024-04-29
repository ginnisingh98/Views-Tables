--------------------------------------------------------
--  DDL for Package OKS_REV_DISTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_REV_DISTR_PUB" AUTHID CURRENT_USER as
/* $Header: OKSPRDSS.pls 120.1 2005/10/03 07:51:52 upillai noship $ */

  subtype rdsv_rec_type is oks_rev_distr_pvt.rdsv_rec_type;
  subtype rdsv_tbl_type is oks_rev_distr_pvt.rdsv_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE insert_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type,
    x_rdsv_rec                     OUT NOCOPY rdsv_rec_type);

  PROCEDURE insert_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type,
    x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type);

  PROCEDURE lock_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type);

  PROCEDURE lock_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type);

  PROCEDURE update_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type,
    x_rdsv_rec                     OUT NOCOPY rdsv_rec_type);

  PROCEDURE update_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type,
    x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type);

  PROCEDURE delete_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type);

  PROCEDURE delete_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type);

  PROCEDURE validate_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type);

  PROCEDURE validate_Revenue_Distr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type);

  FUNCTION GET_GL_CODE_COMBINATION ( P_Id            IN  Varchar2,
                                     P_Org_Id        IN  Number,
                                     x_return_status OUT NOCOPY Varchar2 ) RETURN Varchar2;


END OKS_REV_DISTR_PUB ;

 

/

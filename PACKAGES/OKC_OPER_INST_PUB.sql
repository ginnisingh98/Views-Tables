--------------------------------------------------------
--  DDL for Package OKC_OPER_INST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OPER_INST_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPCOPS.pls 120.0 2005/05/25 19:09:36 appldev noship $ */

  subtype copv_rec_type is OKC_OPER_INST_PVT.copv_rec_type;
  subtype copv_tbl_type is OKC_OPER_INST_PVT.copv_tbl_type;
  subtype oiev_rec_type is OKC_OPER_INST_PVT.oiev_rec_type;
  subtype oiev_tbl_type is OKC_OPER_INST_PVT.oiev_tbl_type;
  subtype olev_rec_type is OKC_OPER_INST_PVT.olev_rec_type;
  subtype olev_tbl_type is OKC_OPER_INST_PVT.olev_tbl_type;
  subtype mrdv_rec_type is OKC_OPER_INST_PVT.mrdv_rec_type;
  subtype mrdv_tbl_type is OKC_OPER_INST_PVT.mrdv_tbl_type;

  -- Global variables for user hooks
  g_pkg_name		CONSTANT	VARCHAR2(200)	:= 'OKC_OPER_INST_PUB';
  g_app_name		CONSTANT	VARCHAR2(3)	:= OKC_API.G_APP_NAME;

  g_copv_rec		copv_rec_type;
  g_copv_tbl		copv_tbl_type;
  g_oiev_rec		oiev_rec_type;
  g_oiev_tbl		oiev_tbl_type;
  g_olev_rec		olev_rec_type;
  g_olev_tbl		olev_tbl_type;
  g_mrdv_rec            mrdv_rec_type;
  g_mrdv_tbl            mrdv_tbl_type;

  PROCEDURE Create_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN  copv_rec_type,
    x_copv_rec                     OUT NOCOPY  copv_rec_type);

  PROCEDURE Create_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY copv_tbl_type);

  PROCEDURE Update_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type,
    x_copv_rec                     OUT NOCOPY copv_rec_type);

  PROCEDURE Update_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY copv_tbl_type);

  PROCEDURE Delete_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type);

  PROCEDURE Delete_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type);

  PROCEDURE Lock_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type);

  PROCEDURE Lock_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type);

  PROCEDURE Validate_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type);

  PROCEDURE Validate_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type);

  PROCEDURE Create_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN  oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY  oiev_rec_type);

  PROCEDURE Create_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY oiev_tbl_type);

  PROCEDURE Update_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY oiev_rec_type);

  PROCEDURE Update_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY oiev_tbl_type);

  PROCEDURE Delete_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type);

  PROCEDURE Delete_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type);

  PROCEDURE Lock_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type);

  PROCEDURE Lock_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type);

  PROCEDURE Validate_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type);

  PROCEDURE Validate_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type);

  PROCEDURE Create_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN  olev_rec_type,
    x_olev_rec                     OUT NOCOPY  olev_rec_type);

  PROCEDURE Create_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY olev_tbl_type);

  PROCEDURE Update_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type,
    x_olev_rec                     OUT NOCOPY olev_rec_type);

  PROCEDURE Update_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY olev_tbl_type);

  PROCEDURE Delete_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type);

  PROCEDURE Delete_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type);

  PROCEDURE Lock_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type);

  PROCEDURE Lock_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type);

  PROCEDURE Validate_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type);

  PROCEDURE Validate_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type);

  PROCEDURE Create_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN  mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY  mrdv_rec_type);

  PROCEDURE Create_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY mrdv_tbl_type);

  PROCEDURE Update_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY mrdv_rec_type);

  PROCEDURE Update_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY mrdv_tbl_type);

  PROCEDURE Delete_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type);

  PROCEDURE Delete_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type);

  PROCEDURE Lock_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type);

  PROCEDURE Lock_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type);

  PROCEDURE Validate_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type);

  PROCEDURE Validate_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type);

END OKC_OPER_INST_PUB;

 

/

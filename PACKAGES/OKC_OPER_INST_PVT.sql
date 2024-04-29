--------------------------------------------------------
--  DDL for Package OKC_OPER_INST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OPER_INST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCCOPS.pls 120.0 2005/05/25 19:10:15 appldev noship $ */

  subtype copv_rec_type is OKC_COP_PVT.copv_rec_type;
  subtype copv_tbl_type is OKC_COP_PVT.copv_tbl_type;
  subtype oiev_rec_type is OKC_OIE_PVT.oiev_rec_type;
  subtype oiev_tbl_type is OKC_OIE_PVT.oiev_tbl_type;
  subtype olev_rec_type is OKC_OLE_PVT.olev_rec_type;
  subtype olev_tbl_type is OKC_OLE_PVT.olev_tbl_type;
  subtype mrdv_rec_type is OKC_MRD_PVT.mrdv_rec_type;
  subtype mrdv_tbl_type is OKC_MRD_PVT.mrdv_tbl_type;


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_OPER_INST_PVT';
  ---------------------------------------------------------------------------

  PROCEDURE Create_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN  OKC_COP_PVT.copv_rec_type,
    x_copv_rec                     OUT NOCOPY  OKC_COP_PVT.copv_rec_type);

  PROCEDURE Create_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY OKC_COP_PVT.copv_tbl_type);

  PROCEDURE Update_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type,
    x_copv_rec                     OUT NOCOPY OKC_COP_PVT.copv_rec_type);

  PROCEDURE Update_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY OKC_COP_PVT.copv_tbl_type);

  PROCEDURE Delete_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type);

  PROCEDURE Delete_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type);

  PROCEDURE Lock_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type);

  PROCEDURE Lock_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type);

  PROCEDURE Validate_Class_Operation (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN OKC_COP_PVT.copv_rec_type);

  PROCEDURE Validate_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN OKC_COP_PVT.copv_tbl_type);

  PROCEDURE Create_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN  OKC_OIE_PVT.oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY  OKC_OIE_PVT.oiev_rec_type);

  PROCEDURE Create_Operation_Instance (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY OKC_OIE_PVT.oiev_tbl_type);

  PROCEDURE Update_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY OKC_OIE_PVT.oiev_rec_type);

  PROCEDURE Update_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY OKC_OIE_PVT.oiev_tbl_type);

  PROCEDURE Delete_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type);

  PROCEDURE Delete_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type);

  PROCEDURE Lock_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type);

  PROCEDURE Lock_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type);

  PROCEDURE Validate_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN OKC_OIE_PVT.oiev_rec_type);

  PROCEDURE Validate_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN OKC_OIE_PVT.oiev_tbl_type);

  PROCEDURE Create_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN  OKC_OLE_PVT.olev_rec_type,
    x_olev_rec                     OUT NOCOPY  OKC_OLE_PVT.olev_rec_type);

  PROCEDURE Create_Operation_Line (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY OKC_OLE_PVT.olev_tbl_type);

  PROCEDURE Update_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type,
    x_olev_rec                     OUT NOCOPY OKC_OLE_PVT.olev_rec_type);

  PROCEDURE Update_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY OKC_OLE_PVT.olev_tbl_type);

  PROCEDURE Delete_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type);

  PROCEDURE Delete_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type);

  PROCEDURE Lock_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type);

  PROCEDURE Lock_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type);

  PROCEDURE Validate_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN OKC_OLE_PVT.olev_rec_type);

  PROCEDURE Validate_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN OKC_OLE_PVT.olev_tbl_type);

 PROCEDURE Create_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN  OKC_MRD_PVT.mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY  OKC_MRD_PVT.mrdv_rec_type);

  PROCEDURE Create_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY OKC_MRD_PVT.mrdv_tbl_type);

  PROCEDURE Update_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY OKC_MRD_PVT.mrdv_rec_type);

  PROCEDURE Update_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY OKC_MRD_PVT.mrdv_tbl_type);

  PROCEDURE Delete_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type);

  PROCEDURE Delete_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type);

  PROCEDURE Lock_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type);

  PROCEDURE Lock_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type);

  PROCEDURE Validate_Masschange_Dtls (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN OKC_MRD_PVT.mrdv_rec_type);

  PROCEDURE Validate_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN OKC_MRD_PVT.mrdv_tbl_type);
END OKC_OPER_INST_PVT;

 

/

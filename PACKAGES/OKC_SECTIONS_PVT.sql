--------------------------------------------------------
--  DDL for Package OKC_SECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SECTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCSCNS.pls 120.0 2005/05/26 09:45:34 appldev noship $ */

  subtype scnv_rec_type is okc_scn_pvt.scnv_rec_type;
  subtype scnv_tbl_type is okc_scn_pvt.scnv_tbl_type;
  subtype sccv_rec_type is okc_scc_pvt.sccv_rec_type;
  subtype sccv_tbl_type is okc_scc_pvt.sccv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_SECTIONS_PVT';
  ---------------------------------------------------------------------------

  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN  OKC_SCN_PVT.scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY  OKC_SCN_PVT.scnv_rec_type);

  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY OKC_SCN_PVT.scnv_tbl_type);

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY OKC_SCN_PVT.scnv_rec_type);

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY OKC_SCN_PVT.scnv_tbl_type);

  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type);

  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type);

  PROCEDURE lock_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type);

  PROCEDURE lock_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type);

  PROCEDURE validate_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type);

  PROCEDURE validate_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type);

  PROCEDURE create_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN  OKC_SCC_PVT.sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY  OKC_SCC_PVT.sccv_rec_type);

  PROCEDURE create_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY OKC_SCC_PVT.sccv_tbl_type);

  PROCEDURE update_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY OKC_SCC_PVT.sccv_rec_type);

  PROCEDURE update_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY OKC_SCC_PVT.sccv_tbl_type);

  PROCEDURE delete_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type);

  PROCEDURE delete_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type);

  PROCEDURE lock_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type);

  PROCEDURE lock_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type);

  PROCEDURE validate_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type);

  PROCEDURE validate_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type);

  PROCEDURE add_language;

END OKC_SECTIONS_PVT;

 

/

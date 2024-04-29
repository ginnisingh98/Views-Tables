--------------------------------------------------------
--  DDL for Package OKS_DEFAULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_DEFAULTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPCDTS.pls 120.0 2005/05/25 18:31:58 appldev noship $ */

  subtype cdtv_rec_type is oks_defaults_pvt.cdtv_rec_type;
  subtype cdtv_tbl_type is oks_defaults_pvt.cdtv_tbl_type;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

--  PROCEDURE add_language;

  PROCEDURE insert_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type,
    x_cdtv_rec                     OUT NOCOPY cdtv_rec_type);

  PROCEDURE insert_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type,
    x_cdtv_tbl                     OUT NOCOPY cdtv_tbl_type);

  PROCEDURE lock_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type);

  PROCEDURE lock_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type);

  PROCEDURE update_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type,
    x_cdtv_rec                     OUT NOCOPY cdtv_rec_type);

  PROCEDURE update_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type,
    x_cdtv_tbl                     OUT NOCOPY cdtv_tbl_type);

  PROCEDURE delete_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type);

  PROCEDURE delete_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type);

  PROCEDURE validate_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type);

  PROCEDURE validate_defaults(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type);

END OKS_defaults_PUB;

 

/

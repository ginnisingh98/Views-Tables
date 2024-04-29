--------------------------------------------------------
--  DDL for Package OKC_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCCACNS.pls 120.0 2005/05/30 04:11:44 appldev noship $ */

/***********************  HAND-CODED  ***************************************/

  SUBTYPE acnv_rec_type IS okc_acn_pvt.acnv_rec_type;
  SUBTYPE acnv_tbl_type IS okc_acn_pvt.acnv_tbl_type;
  SUBTYPE aaev_rec_type IS okc_aae_pvt.aaev_rec_type;
  SUBTYPE aaev_tbl_type IS okc_aae_pvt.aaev_tbl_type;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKC_ACTIONS_PVT';
  G_APP_NAME	               CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLcode';
  ---------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------

  -- Public procedure declarations

  -- This procedure calls each of the simple API add_languauge
  -- in order - Action , Action Attributes

  PROCEDURE add_language;

  -- Object type procedure for Create
  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  -- It first calls create_actions(record version), then calls create_act_atts
  -- (table version)

  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  -- It first calls create_actions(table version), then calls create_act_atts
  -- (table version)


  -- Object type procedure for Update
  PROCEDURE update_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  -- It first calls update_actions(record version), then calls update_act_atts
  -- (table version)

  -- Object type procedure for Validate
  PROCEDURE validate_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    p_aaev_tbl                     IN aaev_tbl_type);

  -- It first calls validate_actions(record version), then calls
  -- validate_act_atts (table version)

  -- Routines to manage Actions

  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type);

  -- It calls OKC_ACN_PVT.insert_row

  PROCEDURE create_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type);

  -- It calls OKC_ACN_PVT.insert_row

  PROCEDURE lock_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type);

  -- It calls OKC_ACN_PVT.lock_row

  PROCEDURE lock_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type);

  -- It calls OKC_ACN_PVT.lock_row

  PROCEDURE update_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type);

  -- It calls OKC_ACN_PVT.update_row

  PROCEDURE update_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type);

  -- It calls OKC_ACN_PVT.update_row

  PROCEDURE delete_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type);

  -- Calls the record version due to business rule enforcement

  PROCEDURE delete_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type);

  -- It calls OKC_ACN_PVT.delete_row

  PROCEDURE validate_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type);

  -- It calls OKC_ACN_PVT.validate_row

  PROCEDURE validate_actions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type);

  -- It calls OKC_ACN_PVT.validate_row

  -- Routines to manage Action Attributes

  PROCEDURE create_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  -- It calls the next routine, the record version, because of business
  -- rule enforcement

  PROCEDURE create_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type);

  -- It calls the OKC_AAE_PVT.insert_row

  PROCEDURE lock_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type);

  -- It calls the OKC_AAE_PVT.lock_row

  PROCEDURE lock_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type);

  -- It calls the OKC_AAE_PVT.lock_row

  PROCEDURE update_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  -- It calls the OKC_AAE_PVT.update_row

  PROCEDURE update_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type);

  -- It calls the OKC_AAE_PVT.update_row

  PROCEDURE delete_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type);

  -- It calls the OKC_AAE_PVT.delete_row

  PROCEDURE delete_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type);

  -- It calls the OKC_AAE_PVT.delete_row

  PROCEDURE validate_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type);

  -- It calls the OKC_AAE_PVT.validate_row

  PROCEDURE validate_act_atts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type);

  -- It calls the OKC_AAE_PVT.validate_row

END OKC_ACTIONS_PVT;

 

/

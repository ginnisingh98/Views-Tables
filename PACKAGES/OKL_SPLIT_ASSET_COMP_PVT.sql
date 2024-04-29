--------------------------------------------------------
--  DDL for Package OKL_SPLIT_ASSET_COMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPLIT_ASSET_COMP_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRSACS.pls 115.1 2002/07/29 18:37:13 cklee noship $ */

  subtype advv_rec_type is okl_asd_pvt.asdv_rec_type;
  subtype advv_tbl_type is okl_asd_pvt.asdv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS , VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SPLIT_ASSET_COMP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := 'COL_NAME';
  G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';

 ----------------------------------------------------------------------------------
  --Global Exception
 ----------------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------------
  --Public Procedures and Functions
 ----------------------------------------------------------------------------------
--  PROCEDURE add_language;

  PROCEDURE create_split_asset_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN  advv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY advv_tbl_type);

  PROCEDURE update_split_asset_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN advv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY advv_tbl_type);

  PROCEDURE delete_split_asset_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN advv_tbl_type);

  PROCEDURE process_split_asset_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tal_id                       IN NUMBER);


END OKL_SPLIT_ASSET_COMP_PVT;

 

/

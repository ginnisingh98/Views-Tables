--------------------------------------------------------
--  DDL for Package IEX_REPOSSESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_REPOSSESS_PVT" AUTHID CURRENT_USER AS
/* $Header: iexrreps.pls 120.0 2004/01/24 03:20:38 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Sub type records
  subtype repv_rec_type is iex_rep_pvt.repv_rec_type;
  subtype repv_tbl_type is iex_rep_pvt.repv_tbl_type;


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                     CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'IEX_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'IEX_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'IEX_SQLCODE';
  G_RET_REQ_ERROR            CONSTANT VARCHAR2(200) := 'IEX_AM_RETURN_REQ_CREAT_ERROR';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'IEX_REPOSSESS_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  'IEX';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_INVALID_PARAMETERS          EXCEPTION;

  ---------------------------------------------------------------------------
  -- CONSTANTS
  ---------------------------------------------------------------------------
  G_ART_CODE                   CONSTANT VARCHAR2(30) := 'REPOS_REQUEST';
  G_ARS_CODE                   CONSTANT VARCHAR2(30) := 'SCHEDULED';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE create_repossess_request(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT NULL,
     p_repv_rec                 IN repv_rec_type,
     p_date_repossession_required IN DATE,
     p_date_hold_until          IN DATE,
     p_relocate_asset_yn        IN VARCHAR2,
     x_repv_rec                 OUT NOCOPY repv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE create_repossess_request(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT NULL,
     p_repv_tbl                 IN repv_tbl_type,
     p_date_repossession_required IN DATE,
     p_date_hold_until          IN DATE,
     p_relocate_asset_yn        IN VARCHAR2,
     x_repv_tbl                 OUT NOCOPY repv_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

END IEX_REPOSSESS_PVT;

 

/

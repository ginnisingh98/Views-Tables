--------------------------------------------------------
--  DDL for Package OKL_INS_CLAIM_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_CLAIM_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCLAS.pls 120.2 2005/10/30 03:38:51 appldev noship $ */
 subtype acdv_tbl_type is okl_acd_pvt.acdv_tbl_type;
 subtype acnv_tbl_type is okl_acn_pvt.acnv_tbl_type;
 subtype clmv_tbl_type is okl_clm_pvt.clmv_tbl_type;

  TYPE stmid_rec_type IS RECORD (
    ID NUMBER := OKL_API.G_MISS_NUM,
    STATUS  VARCHAR2(30) := OKL_API.G_MISS_CHAR
    );

  TYPE stmid_rec_type_tbl_type IS TABLE OF stmid_rec_type INDEX BY BINARY_INTEGER;

 G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
 G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
 G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
 G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN; --3745151
 G_VIEW		 CONSTANT	VARCHAR2(200) := 'OKL_K_LINES_V';

 G_HALT_EXCEPTION   EXCEPTION;

 G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_INS_CLAIM_ASSETCNDNLNS_PVT';
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE   create_lease_claim(
         p_api_version                  IN NUMBER,
	     p_init_msg_list            IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         px_clmv_tbl                    IN OUT NOCOPY clmv_tbl_type,
         px_acdv_tbl			IN OUT NOCOPY acdv_tbl_type,
         px_acnv_tbl			IN OUT NOCOPY acnv_tbl_type
     );

 PROCEDURE hold_streams(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsm_id                       IN stmid_rec_type_tbl_type
);

END OKL_INS_CLAIM_ASSET_PVT;

 

/

--------------------------------------------------------
--  DDL for Package OKL_INS_CLAIM_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_CLAIM_ASSET_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCLAS.pls 120.1 2005/07/18 06:20:54 asawanka noship $ */
  subtype acdv_tbl_type is okl_acd_pvt.acdv_tbl_type;
  subtype acnv_tbl_type is okl_acn_pvt.acnv_tbl_type;
  subtype clmv_tbl_type is okl_clm_pvt.clmv_tbl_type;
  subtype stmid_rec_type_tbl_type is OKL_INS_CLAIM_ASSET_PVT.stmid_rec_type_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_INS_CLAIM_ASSET_PUB';
  G_API_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_INS_CLAIM_ASSET';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE   create_lease_claim(
         p_api_version                   IN NUMBER,
	 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
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
END OKL_INS_CLAIM_ASSET_PUB;

 

/

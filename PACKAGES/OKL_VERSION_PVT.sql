--------------------------------------------------------
--  DDL for Package OKL_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VERSION_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRVERS.pls 115.4 2002/04/28 14:34:22 pkm ship        $ */

  subtype cvmv_rec_type is OKL_OKC_MIGRATION_PVT.CVMV_REC_TYPE;
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT   VARCHAR2(200) := 'OKL_VERSION_PVT';
  G_APP_NAME                    CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_SQLERRM_TOKEN               CONSTANT   VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT   VARCHAR2(200) := 'SQLcode';
  ---------------------------------------------------------------------------

  --Procedures pertaining to versioning a contract

  PROCEDURE version_contract(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cvmv_rec       IN  cvmv_rec_type,
            x_cvmv_rec       OUT NOCOPY cvmv_rec_type,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE);

  PROCEDURE save_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE);

  PROCEDURE erase_saved_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE);

  PROCEDURE restore_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE);

END OKL_VERSION_PVT;

 

/

--------------------------------------------------------
--  DDL for Package OKL_VERSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VERSION_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPVERS.pls 115.3 2002/05/13 11:11:37 pkm ship        $ */

  subtype cvmv_rec_type is OKL_OKC_MIGRATION_PVT.CVMV_REC_TYPE;
  subtype cvmv_tbl_type is OKL_OKC_MIGRATION_PVT.CVMV_TBL_TYPE;
  g_chr_id                 OKC_K_LINES_V.CHR_ID%TYPE;
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

  PROCEDURE version_contract(
            p_api_version    IN NUMBER,
            p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count	     OUT NOCOPY NUMBER,
            x_msg_data	     OUT NOCOPY VARCHAR2,
            p_cvmv_tbl       IN cvmv_tbl_type,
            p_commit         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_cvmv_tbl       OUT NOCOPY cvmv_tbl_type);

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


END okl_version_pub;

 

/

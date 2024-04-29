--------------------------------------------------------
--  DDL for Package OKL_SERVICE_LINE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SERVICE_LINE_PROCESS_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRSLPS.pls 120.2 2005/10/30 04:38:00 appldev noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_SERVICE_LINE_PROCESS_PVT';

  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_FALSE                CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;

  -----------------------------------------------------------------------------
  -- DATA STRUCTURES
  -----------------------------------------------------------------------------
  SUBTYPE klev_rec_type IS okl_kle_pvt.klev_rec_type;
  SUBTYPE klev_tbl_type IS okl_kle_pvt.klev_tbl_type;
  SUBTYPE clev_rec_type IS okl_okc_migration_pvt.clev_rec_type;
  SUBTYPE clev_tbl_type IS okl_okc_migration_pvt.clev_tbl_type;
  SUBTYPE cimv_rec_type IS okl_okc_migration_pvt.cimv_rec_type;
  SUBTYPE cimv_tbl_type IS okl_okc_migration_pvt.cimv_tbl_type;
  SUBTYPE cplv_rec_type IS okl_okc_migration_pvt.cplv_rec_type;
  SUBTYPE cplv_tbl_type IS okl_okc_migration_pvt.cplv_tbl_type;

  -----------------------------------------------------------------------------
  -- PROGRAM UNITS
  -----------------------------------------------------------------------------

  PROCEDURE create_service_line(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_cplv_rec       IN  cplv_rec_type,
                                x_clev_rec       OUT NOCOPY clev_rec_type,
                                x_klev_rec       OUT NOCOPY klev_rec_type,
                                x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                x_cplv_rec       OUT NOCOPY cplv_rec_type);

  PROCEDURE create_service_asset(p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_clev_rec       IN  clev_rec_type,
                                 p_klev_rec       IN  klev_rec_type,
                                 p_cimv_rec       IN  cimv_rec_type,
                                 p_cplv_rec       IN  cplv_rec_type,
                                 p_sub_clev_rec   IN  clev_rec_type,
                                 p_sub_klev_rec   IN  klev_rec_type,
                                 p_sub_cimv_rec   IN  cimv_rec_type,
                                 x_clev_rec       OUT NOCOPY clev_rec_type,
                                 x_klev_rec       OUT NOCOPY klev_rec_type,
                                 x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                 x_cplv_rec       OUT NOCOPY cplv_rec_type,
                                 x_sub_clev_rec   OUT NOCOPY clev_rec_type,
                                 x_sub_klev_rec   OUT NOCOPY klev_rec_type,
                                 x_sub_cimv_rec   OUT NOCOPY cimv_rec_type);

  PROCEDURE update_service_line(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_cplv_rec       IN  cplv_rec_type,
                                x_clev_rec       OUT NOCOPY clev_rec_type,
                                x_klev_rec       OUT NOCOPY klev_rec_type,
                                x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                x_cplv_rec       OUT NOCOPY cplv_rec_type);

  PROCEDURE delete_service_line(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_cplv_rec       IN  cplv_rec_type);

END OKL_SERVICE_LINE_PROCESS_PVT;

 

/

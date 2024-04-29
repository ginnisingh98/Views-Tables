--------------------------------------------------------
--  DDL for Package OKL_MISC_TRANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MISC_TRANS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPMSCS.pls 120.3 2005/10/30 04:26:08 appldev noship $ */


SUBTYPE tclv_rec_type IS OKL_MISC_TRANS_PVT.tclv_rec_type;



PROCEDURE CREATE_MISC_DSTR_LINE(p_api_version        IN     NUMBER,
                                p_init_msg_list      IN     VARCHAR2,
                                x_return_status      OUT    NOCOPY VARCHAR2,
                                x_msg_count          OUT    NOCOPY NUMBER,
                                x_msg_data           OUT    NOCOPY VARCHAR2,
                                p_tclv_rec           IN     tclv_rec_type,
                                x_tclv_rec           OUT    NOCOPY tclv_rec_type);

G_PKG_NAME CONSTANT VARCHAR2(200)       := 'OKL_MISC_TRANS_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)         :=  OKL_API.G_APP_NAME;


  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------
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
  -----------------------------------------------------------------------------
  -- PROGRAM UNITS
  -----------------------------------------------------------------------------
  PROCEDURE create_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     OKL_MISC_TRANS_PVT.jrnl_line_tbl_type,
                                    x_jrnl_hdr_rec       OUT    NOCOPY OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type);

  PROCEDURE update_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     OKL_MISC_TRANS_PVT.jrnl_line_tbl_type);



END OKL_MISC_TRANS_PUB;

 

/

--------------------------------------------------------
--  DDL for Package OKL_MULTIGAAP_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MULTIGAAP_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRMGES.pls 120.0.12010000.3 2008/12/10 01:49:12 sgiyer noship $ */

subtype tcnv_rec_type is OKL_TCN_PVT.tcnv_rec_type;
subtype tcnv_tbl_type is OKL_TCN_PVT.tcnv_tbl_type;

subtype tclv_rec_type is OKL_TCL_PVT.tclv_rec_type;
subtype tclv_tbl_type is OKL_TCL_PVT.tclv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_MULTIGAAP_ENGINE_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
 G_INVALID_VALUE	CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 G_GL_DATE   DATE;
 G_STREAM_NAME_TOKEN CONSTANT VARCHAR2(200) := 'STREAM_NAME';

 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

PROCEDURE CREATE_SEC_REP_TRX (
          P_API_VERSION                  IN NUMBER,
          P_INIT_MSG_LIST                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY NUMBER,
          X_MSG_DATA                     OUT NOCOPY VARCHAR2,
          P_TCNV_REC                     OKL_TCN_PVT.TCNV_REC_TYPE,
          P_TCLV_TBL                     OKL_TCL_PVT.TCLV_TBL_TYPE,
          p_ctxt_val_tbl                 Okl_Account_Dist_Pvt.CTXT_TBL_TYPE,
          p_acc_gen_primary_key_tbl      OKL_ACCOUNT_DIST_PVT.acc_gen_primary_key
);

PROCEDURE REVERSE_SEC_REP_TRX (
          P_API_VERSION                  IN NUMBER,
          P_INIT_MSG_LIST                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY NUMBER,
          X_MSG_DATA                     OUT NOCOPY VARCHAR2,
          P_TCNV_REC                     OKL_TCN_PVT.TCNV_REC_TYPE
);

PROCEDURE REVERSE_SEC_REP_TRX (
          P_API_VERSION                  IN NUMBER,
          P_INIT_MSG_LIST                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY NUMBER,
          X_MSG_DATA                     OUT NOCOPY VARCHAR2,
          P_TCNV_TBL                     tcnv_tbl_type
);

END OKL_MULTIGAAP_ENGINE_PVT;

/

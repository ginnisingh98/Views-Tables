--------------------------------------------------------
--  DDL for Package OKL_AM_LOAN_TRMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LOAN_TRMNT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLOTS.pls 115.8 2002/09/20 17:34:16 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_LOAN_TRMNT_PVT';
  G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	   CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION     EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE term_rec_type      IS  OKL_AM_LEASE_TRMNT_PVT.term_rec_type;
  SUBTYPE tcnv_rec_type      IS  OKL_AM_LEASE_TRMNT_PVT.tcnv_rec_type;
  SUBTYPE stmv_tbl_type      IS  OKL_AM_LEASE_TRMNT_PVT.stmv_tbl_type;
  SUBTYPE adjv_rec_type      IS  OKL_AM_LEASE_TRMNT_PVT.adjv_rec_type;
  SUBTYPE ajlv_tbl_type      IS  OKL_AM_LEASE_TRMNT_PVT.ajlv_tbl_type;
  SUBTYPE chrv_rec_type      IS  OKL_AM_LEASE_TRMNT_PVT.chrv_rec_type;
  SUBTYPE clev_tbl_type      IS  OKL_AM_LEASE_TRMNT_PVT.clev_tbl_type;
  SUBTYPE klev_tbl_type      IS  OKL_AM_LEASE_TRMNT_PVT.klev_tbl_type;


  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------
  PROCEDURE validate_loan(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type);

  PROCEDURE loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type);

END OKL_AM_LOAN_TRMNT_PVT;

 

/

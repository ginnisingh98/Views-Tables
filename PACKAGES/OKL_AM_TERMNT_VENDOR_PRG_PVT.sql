--------------------------------------------------------
--  DDL for Package OKL_AM_TERMNT_VENDOR_PRG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMNT_VENDOR_PRG_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTVPS.pls 120.1 2005/10/30 04:58:01 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Rec Type to store IA Details
  TYPE va_rec_type IS RECORD (
           id                NUMBER,
           va_number         OKC_K_HEADERS_B.contract_number%TYPE,
           start_date        DATE,
           end_date          DATE,
           sts_code          OKC_K_HEADERS_B.sts_code%TYPE,
           date_terminated   DATE,
           scs_code          OKC_K_HEADERS_B.scs_code%TYPE);

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- This Procedure is used to terminate investor agreement
  PROCEDURE terminate_vendor_prog(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_va_rec         IN   va_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL);

  -- This procedure is called by concurrent manager to terminate end dated Vendor Program agreements.
  PROCEDURE concurrent_expire_vend_prg(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_va_id          IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL);

END OKL_AM_TERMNT_VENDOR_PRG_PVT;

 

/

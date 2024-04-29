--------------------------------------------------------
--  DDL for Package OKL_AM_BAL_WRITEOFF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_BAL_WRITEOFF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBWRS.pls 120.2 2005/09/15 22:03:08 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Rec Type to store contract Details
  TYPE khr_rec_type IS RECORD (
           id                NUMBER,
           contract_number   OKC_K_HEADERS_B.contract_number%TYPE,
           start_date        DATE,
           end_date          DATE,
           sts_code          OKC_K_HEADERS_B.sts_code%TYPE,
           date_terminated   DATE,
           scs_code          OKC_K_HEADERS_B.scs_code%TYPE);

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- This procedure is called by concurrent manager to write off balances for terminated contracts
  PROCEDURE concurrent_bal_writeoff_prg(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_khr_id         IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL);

END OKL_AM_BAL_WRITEOFF_PVT;

 

/

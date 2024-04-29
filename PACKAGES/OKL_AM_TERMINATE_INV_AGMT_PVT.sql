--------------------------------------------------------
--  DDL for Package OKL_AM_TERMINATE_INV_AGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMINATE_INV_AGMT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTIAS.pls 115.3 2004/01/26 20:53:57 sechawla noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_INVALID_VALUE	 CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	 CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_TERMINATE_INV_AGMT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1          CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR       CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_API_VERSION         CONSTANT NUMBER        := 1;
  G_MISS_CHAR           CONSTANT VARCHAR2(1)   := OKL_API.G_MISS_CHAR;
  G_MISS_NUM            CONSTANT NUMBER        := OKL_API.G_MISS_NUM;
  G_MISS_DATE           CONSTANT DATE          := OKL_API.G_MISS_DATE;
  G_TRUE                CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_FALSE               CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_YES                 CONSTANT VARCHAR2(1)   := 'Y';
  G_NO                  CONSTANT VARCHAR2(1)   := 'N';
  G_FIRST               CONSTANT NUMBER        := FND_MSG_PUB.G_FIRST;
  G_NEXT                CONSTANT NUMBER        := FND_MSG_PUB.G_NEXT;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
  G_EXCEPTION_ERROR EXCEPTION;
  G_EXCEPTION_HALT  EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  -- Rec Type to Store IA Line Details
  TYPE ialn_rec_type IS RECORD (
           id       NUMBER,
           name     VARCHAR2(2000));

  -- Table Type for Recs of IA Lines
  TYPE ialn_tbl_type IS TABLE OF ialn_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to Store Messages

  -- SECHAWLA 26-JAN-04 3377730: Added id field to msg_rec_type
  TYPE msg_rec_type IS RECORD (
           id       NUMBER,  -- Added
           msg      VARCHAR2(2000));

  -- Table Type to Messages Rec
  TYPE msg_tbl_type IS TABLE OF msg_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to Store Message details with IA details
  TYPE message_rec_type  IS RECORD (
           id               NUMBER,
           contract_number  VARCHAR2(300),
           start_date       DATE,
           end_date         DATE,
           status           VARCHAR2(300) );

-- SECHAWLA 26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions of
--  db/Pl Sql  Removed  msg_tbl from message_rec_type.
--         msg_tbl          msg_tbl_type);

  -- Table Type to Store Recs of Message details with IA details
  TYPE message_tbl_type IS TABLE OF message_rec_type INDEX BY BINARY_INTEGER;


  -- Rec Type to Store Lease K Details
  TYPE ia_k_rec_type IS RECORD (
           id                NUMBER,
           contract_number   OKC_K_HEADERS_B.contract_number%TYPE,
           start_date        DATE,
           end_date          DATE,
           sts_code          OKC_K_HEADERS_B.sts_code%TYPE,
           date_terminated   DATE);

  -- Table Type to store Recs of IA Details
  TYPE ia_k_tbl_type IS TABLE OF ia_k_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to store IA Details
  TYPE ia_rec_type IS RECORD (
           id                NUMBER,
           contract_number   OKC_K_HEADERS_B.contract_number%TYPE,
           start_date        DATE,
           end_date          DATE,
           sts_code          OKC_K_HEADERS_B.sts_code%TYPE,
           date_terminated   DATE,
           scs_code          OKC_K_HEADERS_B.scs_code%TYPE,
           pdt_id            NUMBER,
           pool_id           NUMBER,
           pool_number       OKL_POOLS.pool_number%TYPE);

  -- SUBTYPE the transaction Rec Type
  SUBTYPE tcnv_rec_type IS OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;

  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- This Procedure is used to terminate investor agreement
  PROCEDURE terminate_investor_agreement(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_ia_rec         IN   ia_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL);

  -- This procedure is called by concurrent manager to terminate ended investor agreements.
  PROCEDURE concurrent_expire_inv_agrmt(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                    p_ia_id          IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL);

END OKL_AM_TERMINATE_INV_AGMT_PVT;

 

/

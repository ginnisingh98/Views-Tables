--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_BOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_BOOK_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRBKGS.pls 120.5 2007/05/14 18:30:47 rpillay ship $ */

-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_BOOK_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  SUCCESS_MESSAGE EXCEPTION;

   Cursor  old_csr( chrId NUMBER) IS
    Select chr.ORIG_SYSTEM_SOURCE_CODE,
           chr.ORIG_SYSTEM_ID1,
           chr.ORIG_SYSTEM_REFERENCE1,
           khr.deal_type
    from okc_k_headers_v chr,
         okl_k_headers    khr
    where khr.id = chr.id
         and chr.id = chrId;

  Cursor rbk_csr( origId Number, rbkId NUMBER) IS
  SELECT DATE_TRANSACTION_OCCURRED
  FROM    okl_trx_contracts trx,
          okl_trx_types_tl trx_type
  WHERE trx.khr_id_old = origId
      AND trx.khr_id_new = rbkId
      AND trx.tsu_code = 'ENTERED'
      AND trx.tcn_type = 'TRBK'
      AND trx.rbr_code IS NOT NULL
      AND trx_type.NAME = 'Rebook'
      AND trx_type.LANGUAGE = 'US'
      AND trx.try_id = trx_type.id;


  Procedure execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_call_mode                    IN  VARCHAR2 DEFAULT 'ACTUAL',
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type);

  Procedure generate_streams(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_chr_id             IN  VARCHAR2,
            p_generation_context IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_trx_number         OUT NOCOPY NUMBER,
            x_trx_status         OUT NOCOPY VARCHAR2);

  PROCEDURE generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okc_Api.G_TRUE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);


  Procedure submit_for_approval(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);

  -------------------------------------------------
  --Bug# 2566822 : Approval WF/AME integration
  -- This api will be called by the WF/AME to
  -- do post approval tasks after the contract has
  -- been approved
  --------------------------------------------------
  Procedure post_approval_process(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2,
            p_call_mode       IN  VARCHAR2 DEFAULT NULL);

  -------------------------------------------------
  --Bug# 2566822 : Approval WF/AME integration
  -- This api will be called by mass rebook and k import
  -- to approve the contract directly irrecpective
  -- of the profile option value for contract approval
  -- path
  --------------------------------------------------
  Procedure Approve_Contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);


  Procedure activate_contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);

 ----------------------------------------------------------------
 --Bug# 3556674 : validate contract api to be called as an api to
 --               run qa check list
 -----------------------------------------------------------------
 Procedure validate_contract(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_call_mode                    IN  VARCHAR2 DEFAULT 'ACTUAL',
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type);

 ----------------------------------------------------------------
 --Bug# 3556674 : generate_draft_accounting to be called  as an api to
 --               generate draft 'Booking' accounting entries
 -----------------------------------------------------------------
 Procedure generate_draft_accounting(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER);

-----------------------------------------------------------------------------
-- PROCEDURE calculate_upfront_tax
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : calculate_upfront_tax
-- Description     : Procedure will be called to calculate upfront tax during
--                   online and batch contract activation.
-- Business Rules  :
-- Parameters      : p_chr_id
-- Version         : 1.0
-- History         : 24-Apr-2007 rpillay Created
-- End of comments

  PROCEDURE calculate_upfront_tax(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2,
            x_process_status  OUT NOCOPY VARCHAR2);


 -----------------------------------------------------------------------------
 -- PROCEDURE approve_activate_contract
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : approve_activate_contract
 -- Description     : Procedure will be called from Submit button on Contract Booking UI and
 --                   from OKL_CONTRACT_BOOK_PVT.post_approval_process and Batch booking.
 --                   This procedure will submit the contract for approval.
 --                   If the contract has been approved, this will process contract activation
 -- Business Rules  :
 -- Parameters      : p_chr_id
 -- Version         : 1.0
 -- History         : 24-Apr-2007 rpillay Created
 -- End of comments

  PROCEDURE approve_activate_contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2,
            x_process_status  OUT NOCOPY VARCHAR2);

End okl_contract_book_PVT;


/

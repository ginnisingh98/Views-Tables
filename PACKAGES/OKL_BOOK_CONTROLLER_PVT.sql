--------------------------------------------------------
--  DDL for Package OKL_BOOK_CONTROLLER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BOOK_CONTROLLER_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBCTS.pls 120.3.12010000.2 2009/08/28 04:38:17 rpillay ship $ */

-- Global variables for user hooks
G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_BOOK_CONTROLLER_PVT';
G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

-- Global variables for Tasks and Process Status
G_VALIDATE_CONTRACT CONSTANT VARCHAR2(10) := 'OKLBCTQA';
G_CALC_UPFRONT_TAX  CONSTANT VARCHAR2(10) := 'OKLBCTUT';
G_PRICE_CONTRACT    CONSTANT VARCHAR2(10) := 'OKLBCTST';
G_SUBMIT_CONTRACT   CONSTANT VARCHAR2(10) := 'OKLBCTBK';

G_PROG_STS_PENDING  CONSTANT VARCHAR2(10) := 'PENDING';
G_PROG_STS_RUNNING  CONSTANT VARCHAR2(10) := 'RUNNING';
G_PROG_STS_COMPLETE CONSTANT VARCHAR2(10) := 'COMPLETE';
G_PROG_STS_ERROR    CONSTANT VARCHAR2(10) := 'ERROR';

SUBTYPE bct_rec_type IS okl_bct_pvt.okl_bct_rec;
SUBTYPE bct_tbl_type IS okl_bct_pvt.okl_bct_tbl;

-----------------------------------------------------------------------------
-- PROCEDURE calculate_upfront_tax
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : calculate_upfront_tax
-- Description     : Procedure called from exec_controller_prg1
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE calculate_upfront_tax(
     p_errbuf      OUT NOCOPY VARCHAR2,
     p_retcode     OUT NOCOPY NUMBER,
     p_khr_id      IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE calc_upfronttax_nxtbtn
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : calc_upfronttax_nxtbtn
-- Description     : Procedure to do validation when next button in Upfront
--                   tax page is clicked.
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE calc_upfronttax_nxtbtn(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE validate_contract_nxtbtn
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_contract_nxtbtn
-- Description     : Procedure to do validation when next button in validate
--                   contrtact page is clicked.
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE validate_contract_nxtbtn(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE init_book_controller_trx
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : init_book_controller_trx
-- Description     : Procedure to insert 4 records into OKL_BOOK_CONTROLLER_TRX
--                   Called from OKL_CONTRACT_BOOK_PVT.execute_qa_check_list
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE init_book_controller_trx(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     x_batch_number        OUT NOCOPY NUMBER);

-----------------------------------------------------------------------------
-- PROCEDURE update_book_controller_trx
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_book_controller_trx
-- Description     : Procedure to update status of records in OKL_BOOK_CONTROLLER_TRX table
--                   Called from OKL_CONTRACT_BOOK_PVT.execute_qa_check_list
-- Business Rules  :
-- Parameters      : p_khr_id p_prog_short_name p_progress_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE update_book_controller_trx(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     p_prog_short_name     IN  okl_book_controller_trx.prog_short_name%TYPE,
     p_conc_req_id         IN  okl_book_controller_trx.conc_req_id%TYPE DEFAULT OKL_API.G_MISS_NUM,
     p_progress_status     IN  okl_book_controller_trx.progress_status%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE cancel_contract_activation
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : cancel_contract_activation
-- Description     : Procedure to update status of contract header, line and records in okl_book_controller_trx table
--                   Called from Authoring UI
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX asahoo Created
-- End of comments

PROCEDURE cancel_contract_activation(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE submit_controller_prg1
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : submit_controller_prg1
-- Description     : Procedure to submit request for controller program 1
-- Business Rules  :
-- Parameters      : p_khr_id,p_cont_stage,p_draft_journal_entry
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE submit_controller_prg1(
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN okc_k_headers_b.id%TYPE,
     p_cont_stage          IN VARCHAR2,
     p_draft_journal_entry IN VARCHAR2);

-----------------------------------------------------------------------------
-- PROCEDURE submit_controller_prg2
-----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : submit_controller_prg2
-- Description     : Procedure to submit request for controller program 2.
--                   Called from Approval workflow
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE submit_controller_prg2(
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE exec_controller_prg1
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : exec_controller_prg1
-- Description     : Procedure called from concurrent request Controller
--                   Program 1 to execute contract booking.
-- Business Rules  :
-- Parameters      : p_khr_id,p_cont_stage,p_draft_journal_entry
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE exec_controller_prg1(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE,
     p_cont_stage          IN  VARCHAR2,
     p_draft_journal_entry IN  VARCHAR2 DEFAULT 'NO',
     p_called_from         IN  VARCHAR2 DEFAULT 'FORM');

-----------------------------------------------------------------------------
-- PROCEDURE exec_controller_prg2
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : exec_controller_prg2
-- Description     : Procedure called from concurrent request Controller
--                   Program 2 to execute contract booking activation
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE exec_controller_prg2(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE execute_qa_check_list
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : execute_qa_check_list
-- Description     : Procedure called from QA Validation concurrent request
--                   to execute QA Checklist
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE execute_qa_check_list(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE generate_streams
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : generate_streams
-- Description     : Procedure called from Stream Generation concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE generate_streams(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE generate_journal_entries
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : generate_journal_entries
-- Description     : Procedure called from Draft Journal Entry concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE generate_journal_entries(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE submit_for_approval
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : submit_for_approval
-- Description     : Procedure called from Approval concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE submit_for_approval(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

-----------------------------------------------------------------------------
-- PROCEDURE activate_contract
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : activate_contract
-- Description     : Procedure called from Activation concurrent request
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments
PROCEDURE activate_contract(
     p_errbuf              OUT NOCOPY VARCHAR2,
     p_retcode             OUT NOCOPY NUMBER,
     p_khr_id              IN  okc_k_headers_b.id%TYPE);

--Bug# 8798934
-----------------------------------------------------------------------------
-- FUNCTION is_prb_upgrade_required
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : is_prb_upgrade_required
-- Description     : Function called from Contract Activation Train -
--                   Price and Submit UI
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX rpillay Created
-- End of comments
FUNCTION is_prb_upgrade_required(
     p_khr_id              IN  NUMBER) RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- PROCEDURE submit_prb_upgrade
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : submit_prb_upgrade
-- Description     : Procedure called from Upgrade button on
--                   Contract Activation Train - Price and Submit UI
-- Business Rules  :
-- Parameters      : p_khr_id
-- Version         : 1.0
-- History         : XX-XXX-XXXX rpillay Created
-- End of comments
PROCEDURE submit_prb_upgrade(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_khr_id              IN  NUMBER,
     x_request_numbers     OUT NOCOPY VARCHAR2);

--Bug# 8798934

END OKL_BOOK_CONTROLLER_PVT;

/

--------------------------------------------------------
--  DDL for Package OKL_SEC_AGREMNT_BOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_AGREMNT_BOOK_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRSZBS.pls 120.3 2007/12/21 14:10:23 kthiruva ship $ */

-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_SEC_AGREMNT_BOOK_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  SUCCESS_MESSAGE EXCEPTION;

  Cursor pool_csr ( chrId NUMBER ) IS
  Select pools.id
  from OKL_POOLS pools
  where pools.khr_id = chrId;

  Procedure execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type);

  Procedure activate_contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);

  Procedure check_reconciled(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);

  Procedure check_event(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_event           IN  VARCHAR2,
            p_chr_id          IN  VARCHAR2);

  --Added by kthiruva on 18-Dec-2007
  -- New method to validate an add request on an active investor agreement
  --Bug 6691554 - Start of Changes
  Procedure validate_add_request(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  NUMBER);
  -- Bug 6691554 - End of Changes

End OKL_SEC_AGREMNT_BOOK_PVT;


/

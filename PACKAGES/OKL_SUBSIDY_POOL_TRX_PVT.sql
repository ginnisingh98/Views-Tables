--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_TRX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSIXS.pls 120.1 2005/07/08 23:55:08 cklee noship $ */

  subtype sixv_rec_type is OKL_SIX_PVT.sixv_rec_type;
  subtype sixv_tbl_type is OKL_SIX_PVT.sixv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SUBSIDY_POOL_TRX_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                     CONSTANT VARCHAR2(30)  := '_PVT';
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

  ------------------------------------------------------------------------------
  -- PROCEDURE create_pool_transaction
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pool_transaction
  -- Description     : This procedure is a wrapper that creates transaction
  --                   records for subsidy pool. Note that this procedure will
  --                   not report any error if the subsidy is not attached with
  --                   a pool
  --
  -- Business Rules  : this procedure is used to add to pool balance or reduce
  --                   from pool balance. the trx_type_code determines this
  --                   action. This procedure inserts records into the
  --                   OKL_TRX_SUBSIDY_POOLS table irrespective of trx_type_code
  --                   . records can never be updated or deleted from this table
  --                   .
  --
  --                   The following rules will be validated before create a
  --                   transaction:
  --
  --                   1. The subsidy pool is active.
  --
  --                   2. The subisdy pool is not expired -- the effectve to
  --                      date of the pool must equal or greater than the
  --                      current date.
  --                      System will by pass the expiration check if
  --                      TRX_TYPE_CODE = 'ADDITION', since this action will
  --                      not reduce the pool balance, but it can be used for
  --                      reporting purpose.
  --
  --                   3. The pool balance must not less than zero after the
  --                      reduction of the transaction.
  --
  --                   4. The asset subsidy transaction date must within the
  --                      subsidy dates as well as subisdy pool dates.
  --
  --                   5. Validate if the ADDITION operation on the subsidy pool
  --                      to reduce the balance that less than zero.
  --                      Logical speaking, caller should pass the original
  --                      REDUCTION subsidy pool amount, this check will avoid
  --                      un-normal operation of the pool transaction.
  --
  --                   6. Valiadte if conversion rate is available when system
  --                      convert from the ransaction currency to the pool
  --                      curreny.
  --
  --                   7. System will use OKL standard API:
  --                      okl_accounting_util.cross_currency_round_amount
  --                      to round subisdy amount.
  --
  -- Parameters      : required parameters are below:
  --                   1) TRX_TYPE_CODE: Subsidy Pool tansaction type
  --                     'ADDITION'  - add the subsidy amount to the pool
  --                     'REDUCTION' - reduce the subsidy amount from the pool
  --                      Note: refer from fnd lookups type:
  --                      OKL_SUB_POOL_LINE_TYPE
  --
  --                   2) SOURCE_TYPE_CODE: Source entity type
  --                     'LEASE_CONTRACT'    - Contract
  --                     'SALES_QUOTE'       - Quote
  --                     'LEASE_APPLICATION' - Lease Application
  --                      Note: refer from fnd lookups type:
  --                      OKL_SUB_POOL_TRX_SOURCE_TYPE
  --
  --                   3) SOURCE_OBJECT_ID: Source entity PK
  --
  --                   4) DNZ_ASSET_NUMBER: OKL asset number/Fixed asset number
  --                      Note: This asset number may not exists in fixed asset
  --                      for Sales Quote, Lease App, or contract before book.
  --
  --                   5) VENDOR_ID: Vendor PK
  --                      Note: refer from PO_VENDORS.vendor_id
  --
  --                   6) SOURCE_TRX_DATE: Source instance transaction date
  --                       For Sales Quote and Lease Application: Asset expected
  --                       start date
  --                       For Lease contract:
  --                          Activates a contract -- Asset start date
  --                          Rebooks a contarct   -- Rebook transaction date
  --                          Splits a contract    -- Split date
  --                          Reverse a contarct   -- Reversal date
  --                       Note: Validate if the source transaction date is
  --                         between the effective dates of subsidy and the
  --                         subsidy pool in that order.
  --
  --                   7) SUBSIDY_ID: Subsidy entity PK
  --                      Note: 1. refer from OKL_SUBSIDIES_B.ID.
  --                            2. Subsidy may or may not associate with a
  --                               subsidy pool. Subisdy can associate with a
  --                               pool at a time.
  --
  --                   8) TRX_REASON_CODE: Subsidy pool transaction reason.
  --                       'ACCEPTE_QUOTE'        -  Accepted Sales Quote
  --                       'ACCEPT_LEASE_APP'     -  Accepted Lease Application
  --                       'ACTIVATE_CONTRACT'    -  Activate Lease Contract
  --                       'APPROVE_LEASE_APP'    -  Approve Lease Application
  --                       'APPROVE_QUOTE'        -  Approve Sales Quote
  --                       'CANCEL_LEASE_OPP'     -  Cancel Lease Opportunity
  --                       'CANCEL_QUOTE'         -  Cancel Sales Quote
  --                       'REBOOK_CONTRACT'      -  Rebook Lease Contract
  --                       'REVERSE_CONTRACT'     -  Reverse Lease Contract
  --                       'SPLIT_CONTRACT'       -  Split Lease Contract
  --                       'UPDATE_APPROVED_QUOTE'-  Update Approved Sales Quote
  --                       'UPDATE_LEASE_APP'     -  Update Lease Application
  --                       'WITHDRAW_LEASE_APP'   -  Withdraw Lease Application
  --                      Note: refer from fnd lookups type:
  --                        OKL_SUB_POOL_TRX_REASON_TYPE
  --
  --                   9) TRX_CURRENCY_CODE: Asset subisdy currency
  --                      Note: refer from gl_currencies
  --
  --                   10) TRX_AMOUNT: Asset subisdy amount
  --
  --                   11) SUBSIDY_POOL_AMOUNT: Converted subsidy amount based
  --                       on the corresponding subisdy pool currency and
  --                       conversion type.
  --                       If TRX_TYPE_CODE = 'ADDITION', then this column is
  --                       required.
  --                       For example, there is a subisdy pool amount USD $501
  --                       when Quote XYZ approved. User cancel the lease
  --                       opportunity, Hence, we need to get the original
  --                       converted subsidy pool amount when add back to the
  --                       pool. This will avoid the converson or rounding issue
  --                       by the different time frames when revese the original
  --                       amount to the pool.
  --
  --                   12) CONVERSION_RATE: Conversion rate from the transaction
  --                       currency to the pool currency.
  --                       API caller responsible to get the conversion rate
  --                       from the original transaction when add back the
  --                       subsidy amount to the pool.
  --                       Please see 11) for the example.
  --
  --                   13) SUBSIDY_POOL_CURRENCY_CODE: pool currency.
  --                       API caller responsible to get the pool currency
  --                       from the original transaction when add back the
  --                       subsidy amount to the pool.
  --                       Please see 11) for the example.
  --
  -- Version         : 1.0
  -- History         : 01-FEB-2005 SJALASUT created
  --                   07-July-2005 cklee Added more details information for
  --                   the API
  -- End of comments
  PROCEDURE create_pool_transaction(p_api_version   IN 	NUMBER,
                                    p_init_msg_list IN  VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_sixv_rec      IN  sixv_rec_type,
                                    x_sixv_rec      OUT NOCOPY sixv_rec_type);

  PROCEDURE create_pool_transaction(p_api_version   IN 	NUMBER,
                                    p_init_msg_list IN  VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_sixv_tbl      IN  sixv_tbl_type,
                                    x_sixv_tbl      OUT NOCOPY sixv_tbl_type);

END okl_subsidy_pool_trx_pvt;

 

/

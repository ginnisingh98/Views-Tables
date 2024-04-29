--------------------------------------------------------
--  DDL for Package OKL_LEASE_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_APP_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRLAPS.pls 120.17 2006/04/12 09:48:16 pagarg noship $ */

  SUBTYPE lapv_rec_type IS OKL_LAP_PVT.LAPV_REC_TYPE;
  SUBTYPE lsqv_rec_type IS OKL_LSQ_PVT.LSQV_REC_TYPE;

  TYPE name_val_rec_type IS RECORD(
    itm_name           VARCHAR2(100)
   ,itm_value          VARCHAR2(100)
  );

  TYPE name_val_tbl_type IS TABLE OF name_val_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION     EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKL_LEASE_APP_PVT';
  G_APP_NAME                      CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                      CONSTANT VARCHAR2(30)  := '_PVT';
  G_INIT_VERSION                  CONSTANT NUMBER        := 1.0;
  G_INIT_APPL_STATUS              CONSTANT VARCHAR2(100) := 'INCOMPLETE';
  G_TEMPLATE_NUMBER               CONSTANT VARCHAR2(30)  := 'TEMPLATE_NUMBER';
  G_UNEXPECTED_ERROR		      CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                 CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_SQLERRM_TOKEN                 CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_cre
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_cre
  -- Description     : This procedure is a wrapper that creates records for
  --                 : lease application.
  -- Business Rules  : This procedure inserts records into the
  --                   OKL_LEASE_APPLICATIONS_B and _TL table
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_cre(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_upd
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_upd
  -- Description     : This procedure is a wrapper that updates records for
  --                 : lease application.
  -- Business Rules  : This procedure updates records into the
  --                   OKL_LEASE_APPLICATIONS_B and _TL table
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_upd(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_val
  -- Description     : This procedure validates lease application.
  -- Business Rules  : This procedure validates lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_accept
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_accept
  -- Description     : This procedure accepts lease application.
  -- Business Rules  : This procedure accepts lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_accept(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_withdraw
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_withdraw
  -- Description     : This procedure withdraws lease application.
  -- Business Rules  : This procedure withdraws lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_withdraw(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_dup
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_dup
  -- Description     : This procedure duplicates lease application.
  -- Business Rules  : This procedure duplicates lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_dup(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lap_id      IN  NUMBER,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type,
            p_origin             IN  VARCHAR2);

  ------------------------------------------------------------------------------
  -- PROCEDURE submit_for_pricing
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_for_pricing
  -- Description     : This procedure submits lease application for pricing.
  -- Business Rules  : This procedure submits lease application for pricing.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE submit_for_pricing(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE submit_for_credit
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_for_credit
  -- Description     : This procedure submits lease application for Credit Approval.
  -- Business Rules  : This procedure submits lease application for Credit Approval.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE submit_for_credit(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type);

  ------------------------------------------------------------------------------
  -- FUNCTION is_valid_program_agreement
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_valid_program_agreement
  -- Description     : This function returns whether Program Agreement fulfills
  --                   all eligibility criteria on Lease Application
  -- Business Rules  : This function returns whether Program Agreement fulfills
  --                   all eligibility criteria on Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 08-JUNE-2005 PAGARG created
  --
  -- End of comments
  FUNCTION is_valid_program_agreement(
           p_pgm_agr_id          IN NUMBER,
           p_lap_id              IN NUMBER,
           p_eff_from            IN DATE)
    RETURN VARCHAR2;

  ------------------------------------------------------------------------------
  -- FUNCTION is_valid_leaseapp_template
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_valid_leaseapp_template
  -- Description     : This function returns whether Lease Application Template
  --                   fulfills all eligibility criteria on Lease Application
  -- Business Rules  : This function returns whether Program Agreement fulfills
  --                   all eligibility criteria on Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 08-JUNE-2005 PAGARG created
  --
  -- End of comments
  FUNCTION is_valid_leaseapp_template(
           p_lat_id              IN NUMBER,
           p_lap_id              IN NUMBER,
           p_eff_from            IN DATE)
    RETURN VARCHAR2;

  ------------------------------------------------------------------------------
  -- FUNCTION get_credit_classfication
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_credit_classfication
  -- Description     : This function returns credit classification for given
  --                   party, customer account or customer account site use.
  -- Business Rules  : This function returns credit classification for given
  --                   party, customer account or customer account site use.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-JUNE-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_credit_classfication(
           p_party_id            IN NUMBER,
           p_cust_acct_id        IN NUMBER,
           p_site_use_id         IN NUMBER)
    RETURN VARCHAR2;

  ------------------------------------------------------------------------------
  -- PROCEDURE accept_counter_offer
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : accept_counter_offer
  -- Description     : This procedure accepts counter offers for Lease Application.
  -- Business Rules  : This procedure accepts counter offers for Lease Application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE accept_counter_offer(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  NUMBER,
            p_cntr_offr          IN  NUMBER,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type);

  -------------------------------------------------------------------------------
  -- PROCEDURE revert_leaseapp
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : revert_leaseapp
  -- Description     : This procedure reverts the status from CONV-K to CR-APPROVED
  --                 : This procedure is called when Contract created from
  --                 : Lease Application is cancelled
  -- Business Rules  : This procedure reverts the status from CONV-K to CR-APPROVED
  --                 : This procedure is called when Contract created from
  --                 : Lease Application is cancelled
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 14-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE revert_leaseapp (
            p_api_version        IN  NUMBER
           ,p_init_msg_list      IN  VARCHAR2
           ,p_leaseapp_id        IN  NUMBER
           ,x_return_status      OUT NOCOPY VARCHAR2
           ,x_msg_count          OUT NOCOPY NUMBER
           ,x_msg_data           OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE validate_credit_results
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_credit_results
  -- Description     : This procedure validates credit results
  -- Business Rules  : This procedure validates credit results
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 22-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE validate_credit_results (
            p_api_version        IN  NUMBER
           ,p_init_msg_list      IN  VARCHAR2
           ,p_leaseapp_id        IN NUMBER
           ,x_return_status      OUT NOCOPY VARCHAR2
           ,x_msg_count          OUT NOCOPY NUMBER
           ,x_msg_data           OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_cancel
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_cancel
  -- Description     : This procedure cancels the lease application.
  -- Business Rules  : This procedure cancels the lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_cancel(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lease_app_id       IN  NUMBER,
            x_lapv_rec		     OUT NOCOPY lapv_rec_type);

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_resubmit
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_resubmit
  -- Description     : This procedure resubmits the lease application.
  -- Business Rules  : This procedure resubmits the lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_resubmit(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lap_id      IN  NUMBER,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type);

  -------------------------------------------------------------------------------
  -- PROCEDURE lease_app_appeal
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_appeal
  -- Description     : This procedure appeals the lease application.
  -- Business Rules  : This procedure appeals the lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-SEP-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_appeal(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lap_id      IN  NUMBER,
            p_lapv_rec           IN  lapv_rec_type,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type);

  -------------------------------------------------------------------------------
  -- PROCEDURE checklist_inst_cre
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : checklist_inst_cre
  -- Description     : This procedure is a wrapper that creates checklist instance
  -- Business Rules  : This procedure creates checklist instance
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 24-JUNE-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE checklist_inst_cre(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  NUMBER,
            p_chklst_tmpl_id     IN  NUMBER);

  -------------------------------------------------------------------------------
  -- PROCEDURE check_eligibility
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_eligibility
  -- Description     : This procedure checks whether lease app is eligible for
  --                   given action or not.
  -- Business Rules  : This procedure checks whether lease app is eligible for
  --                   given action or not.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 06-OCT-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE check_eligibility(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  NUMBER,
            p_action             IN  VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE populate_lease_app
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_lease_app
  -- Description     : This procedure populates lapv_rec and lsqv_rec with the
  --                 : database values for a given lease application.
  -- Business Rules  : This procedure populates lapv_rec and lsqv_rec with the
  --                 : database values for a given lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 30-MAY-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE populate_lease_app(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_lapv_rec           OUT NOCOPY lapv_rec_type,
            x_lsqv_rec           OUT NOCOPY lsqv_rec_type);

  -------------------------------------------------------------------------------
  -- FUNCTION get_financed_amount
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_financed_amount
  -- Description     : This function returns the financed amount for given
  --                   Lease Quote
  -- Business Rules  : This function returns the financed amount for given
  --                   Lease Quote
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 23-SEP-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_financed_amount(
           p_lease_qte_id       IN NUMBER)
    RETURN NUMBER;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_qa_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_qa_val
  -- Description     : This procedure calls qa validation for lease application.
  -- Business Rules  : This procedure calls qa validation for lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-Oct-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_qa_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
			x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_qa_result          OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_price
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_price
  -- Description     : This procedure calls api to price lease application.
  -- Business Rules  : This procedure calls api to price lease application.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-Oct-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE lease_app_price(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- PROCEDURE set_lease_app_status
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_lease_app_status
  -- Description     : This procedure sets the required lease application status.
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure sets the required lease application status.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-Nov-2005 PAGARG created
  --
  -- End of comments
  PROCEDURE set_lease_app_status(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_lap_status         IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

--BEGIN -VARANGAN for bug#4747179
 ------------------------------------------------------------------------------
  -- PROCEDURE set_lease_app_expdays
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_lease_app_expdays
  -- Description     : This procedure sets the required lease application status.
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure sets the required lease application Credit expiration status.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 18-Nov-2005 VARANGAN created
  --
  -- End of comments
  PROCEDURE set_lease_app_expdays(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_lap_expdays        IN  NUMBER,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);
--END--VARANGAN for bug#4747179

--Bug 4872214 PAGARG Added two functions: one to return
--Start
  -------------------------------------------------------------------------------
  -- FUNCTION get_credit_decision
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_credit_decision
  -- Description     : This function returns the Credit Decision on the given
  --                   Lease Application
  -- Business Rules  : This function returns the Credit Decision on the given
  --                   Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 14-Dec-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_credit_decision(
           p_lease_app_id       IN NUMBER)
    RETURN VARCHAR2;

  -------------------------------------------------------------------------------
  -- FUNCTION get_approval_exp_date
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_approval_exp_date
  -- Description     : This function returns the Credit Approval Expiration Date
  --                   for the given Lease Application
  -- Business Rules  : This function returns the Credit Approval Expiration Date
  --                   for the given Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 14-Dec-2005 PAGARG created
  --
  -- End of comments
  FUNCTION get_approval_exp_date(
           p_lease_app_id       IN NUMBER)
    RETURN DATE;
--Bug 4872214 PAGARG End

  ------------------------------------------------------------------------------
  -- FUNCTION is_curr_conv_valid
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : is_curr_conv_valid
  -- Description     : This function validates Currency Conversion values and
  --                   returns Success or Error
  -- Business Rules  : This function validates Currency Conversion values and
  --                   returns Success or Error
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 02-Feb-2006 PAGARG created Bug 4932155
  --
  -- End of comments
  FUNCTION is_curr_conv_valid(
           p_curr_code           IN VARCHAR2,
           p_curr_type           IN VARCHAR2,
           p_curr_rate           IN NUMBER,
           p_curr_date           IN DATE)
    RETURN VARCHAR2;

  ------------------------------------------------------------------------------
  -- PROCEDURE lease_app_unaccept
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lease_app_unaccept
  -- Description     : This procedure unaccepts lease application.
  -- Business Rules  : This procedure unaccepts lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 07-Feb-2006 PAGARG created created Bug 4905274
  --
  -- End of comments
  PROCEDURE lease_app_unaccept(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE check_lease_quote_defaults
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_lease_quote_defaults
  -- Description     : This procedure checks the values defaulted in lease
  --                 : application from lease quote.
  -- Business Rules  : If default values from lease quote are not changed then
  --                 : return status as Success else Error
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-Feb-2006 PAGARG exposed in spec
  -- End of comments
  PROCEDURE check_lease_quote_defaults(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_source_lsq_id      IN  OKL_LEASE_QUOTES_B.ID%TYPE,
            p_lapv_rec           IN  lapv_rec_type,
            p_lsqv_rec           IN  lsqv_rec_type);

  ------------------------------------------------------------------------------
  -- PROCEDURE create_contract
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_contract
  -- Description     : This procedure calls api to create contract from lease app.
  -- Business Rules  : This procedure calls api to create contract from lease app.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 15-Feb-2006 PAGARG created
  --
  -- End of comments
  PROCEDURE create_contract(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_chr_id             OUT NOCOPY NUMBER,
            x_chr_number         OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- PROCEDURE revert_to_orig_status
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : revert_to_orig_status
  -- Description     : This procedure updates the status of parent lease
  --                   application with the status stored in orig_status
  --                   THIS PROCEDURE IS ONLY FOR OKL INTERNAL DEVELOPMENT PURPOSE
  -- Business Rules  : This procedure updates the status of parent lease
  --                   application with the status stored in orig_status. It will
  --                   then clear the value in orig_status
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Feb-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE revert_to_orig_status(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

  --Bug 4872271 PAGARG Added function to return Credit Decision Appeal Flag
  -------------------------------------------------------------------------------
  -- FUNCTION get_cr_dec_appeal_flag
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_cr_dec_appeal_flag
  -- Description     : This function returns the appeal flag for Credit Decision
  --                   on the given Lease Application
  -- Business Rules  : This function returns the appeal flag for Credit Decision
  --                   on the given Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Mar-2006 PAGARG created
  --
  -- End of comments
  FUNCTION get_cr_dec_appeal_flag(
           p_lease_app_id       IN NUMBER)
    RETURN VARCHAR2;

  --Bug 4872271 PAGARG Added function to return Expiration Date Appeal Flag
  -------------------------------------------------------------------------------
  -- FUNCTION get_exp_date_appeal_flag
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_exp_date_appeal_flag
  -- Description     : This function returns the appeal flag for Credit Approval
  --                   Expiration Date for the given Lease Application
  -- Business Rules  : This function returns the appeal flag for Credit Approval
  --                   Expiration Date for the given Lease Application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Mar-2006 PAGARG created
  --
  -- End of comments
  FUNCTION get_exp_date_appeal_flag(
           p_lease_app_id       IN NUMBER)
    RETURN VARCHAR2;

  --Bug 4872271 PAGARG Added function to set Appeal Flag for recommendations
  ------------------------------------------------------------------------------
  -- PROCEDURE appeal_recommendations
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : appeal_recommendations
  -- Description     : This procedure sets the appeal flag for credit recommendations
  --                   of parent lease app of given lease application
  -- Business Rules  : This procedure sets the appeal flag for credit recommendations
  --                   of parent lease app of given lease application
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 28-Mar-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE appeal_recommendations(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            p_cr_dec_apl_flag    IN  VARCHAR2,
            p_exp_date_apl_flag  IN  VARCHAR2,
            p_cr_conds           IN  name_val_tbl_type,
            p_addl_rcmnds        IN  name_val_tbl_type,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- PROCEDURE create_contract_val
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_contract_val
  -- Description     : This procedure validates the contract creation from given
  --                   lease app.
  -- Business Rules  : This procedure validates the contract creation from given
  --                   lease app.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 06-Apr-2006 PAGARG created
  --
  -- End of comments
  PROCEDURE create_contract_val(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_lap_id             IN  OKL_LEASE_APPLICATIONS_B.ID%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

END OKL_LEASE_APP_PVT;

/

--------------------------------------------------------
--  DDL for Package OKL_VARIABLE_INT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VARIABLE_INT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVIUS.pls 120.2 2005/09/29 21:28:32 pjgomes noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE invoice_info_rec_type IS RECORD (
    remaining_amount               NUMBER,
    invoice_date                   DATE,
    lsm_id                         NUMBER,
    tld_id                         NUMBER,
    receivables_invoice_id         NUMBER);

  TYPE invoice_info_tbl_type IS TABLE OF invoice_info_rec_type
    INDEX BY BINARY_INTEGER;

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200)  := 'OKL_VARIABLE_INT_UTIL_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)    :=  OKL_API.G_APP_NAME;
  G_API_TYPE             CONSTANT VARCHAR2(4)    := '_PVT';
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200)  := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200)  := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200)  := 'SQLCODE';
  G_INVALID_VALUE        CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

  --returns interest due for a date range
  FUNCTION get_interest_due(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  --returns interest billed for a date range
  FUNCTION get_interest_billed(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  --returns interest paid for a date range
  FUNCTION get_interest_paid(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  --returns principal balance on a contract for a loan as of a given date
  FUNCTION get_principal_bal(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_kle_id         IN NUMBER,
     p_date           IN DATE) RETURN NUMBER;

  --Returns an indicator Y/N if the interest rate has changed
  FUNCTION get_interest_rate_change_flag(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER) RETURN VARCHAR2;

  --Returns effective interest rate as of a given date
  FUNCTION get_effective_int_rate(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_effective_date IN DATE) RETURN NUMBER;

  --Returns Interest due but not billed as of a given date for a Loan
  FUNCTION get_interest_due_unbilled(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER,
     p_effective_date   IN DATE) RETURN NUMBER;

  --Returns Principal Billed for a loan contract
  FUNCTION get_principal_billed(
      x_return_status  OUT NOCOPY VARCHAR2,
      p_khr_id         IN NUMBER,
      p_kle_id         IN NUMBER,
      p_from_date      IN DATE,
      p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  --Returns principal paid for a loan contract for a date range
  FUNCTION get_principal_paid(
      x_return_status  OUT NOCOPY VARCHAR2,
      p_khr_id         IN NUMBER,
      p_kle_id         IN NUMBER,
      p_from_date      IN DATE,
      p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  --Returns Float Factor Billing Amount for a float factor contract as of a given date
  FUNCTION get_float_factor_billed(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER,
      p_effective_date   IN DATE) RETURN NUMBER;

  --Returns Loan Payment Billed for a loan contract with a revenue recognition method of Actual
  FUNCTION get_loan_payment_billed(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER,
      p_effective_date   IN DATE) RETURN NUMBER;

  --Returns Loan Payment Received  for a loan contract with a revenue recognition method of Actual
  FUNCTION get_loan_payment_paid(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER,
      p_effective_date   IN DATE) RETURN NUMBER;

  --Returns Excess Loan Payment Received  for a loan contract with a revenue recognition method of Actual
  FUNCTION get_excess_loan_payment(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER) RETURN NUMBER;

  --Returns the date last interim interest calculated for variable rate contract
  FUNCTION get_last_interim_int_calc_date(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER) RETURN DATE;

  --Returns the last scheduled interest calculation date prior to the Termination Date
  FUNCTION get_last_sch_int_calc_date(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER,
      p_effective_date   IN DATE) RETURN DATE;

  --Returns invoice information table
  PROCEDURE get_open_invoices(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER,
      x_invoice_tbl      OUT NOCOPY invoice_info_tbl_type);


END OKL_VARIABLE_INT_UTIL_PVT;

 

/

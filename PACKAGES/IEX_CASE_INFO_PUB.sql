--------------------------------------------------------
--  DDL for Package IEX_CASE_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASE_INFO_PUB" AUTHID CURRENT_USER AS
/* $Header: iexcsins.pls 120.2 2004/11/01 16:34:04 jsanju ship $ */



  ---------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------
  G_REQUIRED_VALUE CONSTANT VARCHAR2(200) := 'IEX_REQUIRED_VALUE';
  G_ERROR        CONSTANT VARCHAR2(200) := 'IEX_ERROR';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'IEX_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'IEX_SQLERRM';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'IEX_SQLCODE';
  ---------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------
  G_PKG_NAME  CONSTANT VARCHAR2(200) := 'IEX_CASE_INFO_PUB';
  G_APP_NAME  CONSTANT VARCHAR2(3)   := 'IEX';

   --------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------



  /* begin raverma 06202003 add procedure to get overdue amount */
  FUNCTION get_Amount_Overdue (p_case_id IN NUMBER) return NUMBER;

  -- Returns Total Receivable Amount for a Case
  PROCEDURE get_total_rcvble_for_case (
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);
  PROCEDURE get_total_net_book_value (
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);
  PROCEDURE get_contract_oec(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_tradein(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_capital_reduction(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_fees_capitalized(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);
  PROCEDURE get_total_capital_amount(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2);

  FUNCTION get_total_rcvble_for_case_fn (p_case_id IN NUMBER) return NUMBER;


END IEX_CASE_INFO_PUB;

 

/

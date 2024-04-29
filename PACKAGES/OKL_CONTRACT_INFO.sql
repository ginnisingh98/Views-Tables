--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_INFO" AUTHID CURRENT_USER AS
/* $Header: OKLRCONS.pls 115.13 2003/09/04 02:35:37 pdevaraj noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_ERROR		            CONSTANT VARCHAR2(200) := 'OKL_ERROR';
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_INFO';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- Returns customer ID or party ID
  FUNCTION get_customer(
     p_contract_id			IN NUMBER,
     x_customer			     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns Vendor Program ID
  FUNCTION get_vendor_program(
     p_contract_id			IN NUMBER,
     x_vendor_program		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns Bill to Address ID
  FUNCTION get_bill_to_address(
     p_contract_id			IN NUMBER,
     x_bill_to_address_id     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns Private Label as a String namely URL
  FUNCTION get_private_label(
     p_contract_id			IN NUMBER,
     x_private_label          	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns non notification flag as "Y" or "N"
  FUNCTION get_non_notify_flag(
     p_contract_id			IN NUMBER,
     x_non_notify_flag          	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns Currency Code
  FUNCTION get_currency(
     p_contract_id			IN NUMBER,
     x_currency			     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns existance of syndication for contract as "Y" or "N"
  FUNCTION get_syndicate_flag(
     p_contract_id			IN NUMBER,
     x_syndicate_flag		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns org ID for a contract
  FUNCTION GET_ORG_ID(
	p_contract_id	IN NUMBER,
	x_org_id		OUT NOCOPY NUMBER )
  RETURN VARCHAR2;

  -- Returns REMAINING no. of PAYMENTS
  FUNCTION get_remaining_payments(
     p_contract_id		IN NUMBER,
     x_remaining_payments	OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns RULE VALUE (accepts prompt as a parameter)
  FUNCTION get_rule_value(
      p_contract_id	IN NUMBER
     ,p_rule_group_code IN VARCHAR2
     ,p_rule_code		IN VARCHAR2
     ,p_rule_name		IN VARCHAR2
     ,x_id1             OUT NOCOPY VARCHAR2
     ,x_id2             OUT NOCOPY VARCHAR2
     ,x_value           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;


  -- Returns RULE VALUE  (accepts segment number as a parameter)
  FUNCTION get_rule_value(
      p_contract_id	IN NUMBER
     ,p_rule_group_code IN VARCHAR2
     ,p_rule_code	IN VARCHAR2
     ,p_segment_number  IN  NUMBER
     ,x_id1             OUT NOCOPY VARCHAR2
     ,x_id2             OUT NOCOPY VARCHAR2
     ,x_value           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns DAYS PAST DUE
  FUNCTION get_days_past_due(
     p_contract_id	IN NUMBER,
     x_days_past_due	OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns AMOUNT PAST DUE
  FUNCTION get_amount_past_due(
     p_contract_id	IN NUMBER,
     x_amount_past_due	OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns next due date and amount for a contract
  FUNCTION get_next_due (
     p_contract_id     IN  NUMBER,
     x_next_due_amt    OUT NOCOPY NUMBER,
     x_next_due_date   OUT NOCOPY DATE )
  RETURN VARCHAR2 ;

  -- Returns last due date and amount for a contract
  FUNCTION get_last_due(
     p_contract_id     IN  NUMBER,
     x_last_due_amt    OUT NOCOPY NUMBER,
     x_last_due_date   OUT NOCOPY DATE )
  RETURN VARCHAR2;

  -- Returns total asset cost
  FUNCTION get_total_asset_cost (
     p_contract_id     IN  NUMBER,
     x_asset_cost     OUT NOCOPY NUMBER )
  RETURN VARCHAR2;

  -- Retunrs Amount outstanding for a contract
  FUNCTION get_outstanding_rcvble (
     p_contract_id     IN  NUMBER,
     x_rcvble_amt     OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns term duration of a contract with start and end date
  FUNCTION get_contract_term (
     p_contract_id     IN  NUMBER,
     x_start_date      OUT NOCOPY DATE,
     x_end_date        OUT NOCOPY DATE,
     x_term_duration   OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns the net investment for a contract
  FUNCTION get_net_investment (
     p_contract_id     IN  NUMBER,
     x_net_investment  OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns advance rent, Security Deposit and Interest Type for a
  FUNCTION get_rent_security_interest (
     p_contract_id      IN  NUMBER,
     x_advance_rent     OUT NOCOPY NUMBER,
     x_security_deposit OUT NOCOPY NUMBER,
     x_interest_type    OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns Insurance Lapsed Y/N
  FUNCTION get_insurance_lapse(
     p_contract_id		IN NUMBER,
     x_insurance_lapse_yn	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns Unrefunded Cures
  /*FUNCTION get_unrefunded_cures(
     p_contract_id		IN NUMBER,
     x_unrefunded_cures	      OUT NOCOPY NUMBER)
  RETURN VARCHAR2;*/

  -- Returns Fair market Value
  FUNCTION get_fair_market_value(
     p_contract_id	   IN NUMBER,
     x_fair_market_value   OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  -- Returns net book Value
  FUNCTION get_net_book_value(
     p_contract_id	IN NUMBER,
     x_net_book_value   OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  /* Returns contractual interest
     Need to implement interest calculation as a Formula at
     contract level */
  FUNCTION get_interest(
     p_contract_id	IN NUMBER,
     x_interest   	OUT NOCOPY NUMBER)
  RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  -- FUNCTION get_immediate_repurchase_yn
  ---------------------------------------------------------------------------
  -- Get Rule value for 'Request Immediate Repurchase' Returns Y/N
  FUNCTION get_immediate_repurchase_yn(
     p_contract_id	IN NUMBER,
     x_value   	      OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  -- FUNCTION get_asset_value
  -- Returns Asset value for a given asset ID and valuation type
  -- The valid valuation type are,
  -- FMV - Fair Market Value
  -- FLV - Forced Liquidation Value
  -- OLV - Orderly Liquidation Value
  ---------------------------------------------------------------------------
  FUNCTION get_asset_value(
     p_asset_id	           IN NUMBER,
     p_asset_valuation_type  IN VARCHAR2
                          )
  RETURN NUMBER;

  ---------------------------------------------------------------------------
  -- FUNCTION get_notice_of_assignment_yn
  ---------------------------------------------------------------------------
  FUNCTION get_notice_of_assignment_yn(
     p_contract_id	IN NUMBER,
     x_assignment_yn   	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

END OKL_CONTRACT_INFO;

 

/

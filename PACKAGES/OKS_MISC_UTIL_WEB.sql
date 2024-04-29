--------------------------------------------------------
--  DDL for Package OKS_MISC_UTIL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_MISC_UTIL_WEB" AUTHID CURRENT_USER AS
/* $Header: OKSJMUTS.pls 120.13 2006/08/17 21:01:09 hmnair noship $ */

  -- GLOBAL VARIABLES
  --------------------------------------------------------------------------
  g_pkg_name             CONSTANT VARCHAR2(200) := 'OKS_MISC_UTIL_WEB';
  g_app_name_oks	 CONSTANT VARCHAR2(3)   := 'OKS';
  g_app_name_okc	 CONSTANT VARCHAR2(3)   := 'OKC';
  G_MODULE           CONSTANT VARCHAR2(250) := 'oks.plsql.'||g_pkg_name||'.';
  --------------------------------------------------------------------------

  -- GLOBAL MESSAGE CONSTANTS
  -----------------------------------------------------------------------------------
  g_true                CONSTANT VARCHAR2(1)   := OKC_API.G_TRUE;
  g_false               CONSTANT VARCHAR2(1)   := OKC_API.G_FALSE;
  g_ret_sts_success	CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  g_ret_sts_error	CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_ERROR;
  g_ret_sts_unexp_error CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_UNEXP_ERROR;
  g_required_value      CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  g_invlaid_value       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  g_col_name_token      CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  g_parent_table_token  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  g_child_table_token   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  g_no_parent_record    CONSTANT VARCHAR2(200) := 'OKS_NO_PARENT_RECORD';
  g_unexpected_error    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token       CONSTANT VARCHAR2(200) := 'SQLerrm';
  g_sqlcode_token       CONSTANT VARCHAR2(200) := 'SQLcode';
  g_uppercase_required  CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  -----------------------------------------------------------------------------------

  -- RECORD TYPES  TABLE TYPES
  -- =======================================================================================

  /*
  ||==========================================================================
  || PROCEDURE: duration_period
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve duration unit in between 2 dates.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_start_date -- start date of duration
  ||     p_end_date   -- end date of duration
  ||
  || Return:
  ||        Time unit as a string.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION duration_period(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  ) RETURN NUMBER;

  /*
  ||==========================================================================
  || PROCEDURE: duration_unit
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve duration period in between 2 dates.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_start_date -- start date of duration
  ||     p_end_date   -- end date of duration
  ||
  || Return:
  ||        Time period as a number.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION duration_unit(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  ) RETURN VARCHAR2;

  /*
  ||==========================================================================
  || PROCEDURE: adjusted_discount
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve the adjusted discount in an invoice.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id -- Contract ID of the contract
  ||     p_line_id     -- Line ID of the line
  ||
  || Return:
  ||        Adjusted discount for the line.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION adjusted_discount(
    p_contract_id IN  NUMBER,
    p_line_id     IN  NUMBER
  ) RETURN Number;

  /*
  ||==========================================================================
  || PROCEDURE: adjusted_surcharge
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve the adjusted discount in an invoice.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id -- Contract ID of the contract
  ||     p_line_id     -- Line ID of the line
  ||
  || Return:
  ||        Adjusted surcharge for the line.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION adjusted_surcharge(
    p_contract_id IN  NUMBER,
    p_line_id     IN  NUMBER
  ) RETURN Number;

  /*
  ||==========================================================================
  || PROCEDURE: adjusted_total
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve the adjusted total in an invoice.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id -- Contract ID of the contract
  ||     p_line_id     -- Line ID of the line
  ||
  || Return:
  ||        Adjusted total for the line.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION adjusted_total(
    p_contract_id IN  NUMBER,
    p_line_id     IN  NUMBER
  ) RETURN Number;


    FUNCTION get_terminated_amount(p_level   IN VARCHAR2,
                                   p_id      IN NUMBER
   ) RETURN NUMBER;

    FUNCTION get_adjustment_amount(p_chr_id   IN NUMBER DEFAULT NULL,
                                   p_cle_id      IN NUMBER DEFAULT NULL
   ) RETURN NUMBER;

     FUNCTION get_total_amount(p_chr_id   IN NUMBER
  ) RETURN NUMBER;


  /**
   * Addded function to retrieve Line Billed Amount for HTML Inquiry Line Billing Details Page
   * @param p_line_id Line or Sub Line Id
   * @param p_line_level line level character "L" for Line, "SL" for Sub Line
   * @return total billed amount
   */
  FUNCTION get_line_billed_amount
  (p_line_id   IN NUMBER,
   p_line_level IN VARCHAR2
  ) RETURN NUMBER;

  /**
   * Addded function to retrieve Line Billed Amount for HTML Inquiry Line Billing Details Page
   * @param p_line_id Line or Sub Line Id
   * @param p_line_level line level character "L" for Line, "SL" for Sub Line
   * @return pending invoice amount
   */
  FUNCTION get_line_unbilled_amount
  (p_line_id   			   IN NUMBER,
   p_line_level IN VARCHAR2
  ) RETURN NUMBER;



   -- Function to retrieve unbilled amount for a contract
   -- Parameters: p_chr_id (Identifier of the contract)

   FUNCTION get_header_unbilled_amount (p_chr_id  IN NUMBER )
   RETURN NUMBER;


  -- Function to retrieve billed amount for a contract (Header level)
  -- Parameters: p_chr_id (Identifier of the contract)

  FUNCTION get_header_billed_amount (p_chr_id  IN NUMBER)
  RETURN NUMBER;


  -- Function to get Duration and Period for a given Strat Date and End Date ( ex: 1 Year)
  FUNCTION get_duration_period (p_start_date DATE,
                                p_end_date   DATE)
                                RETURN VARCHAR2;

 -- Function to get the covered level name.
 FUNCTION get_covlvl_name (p_jtot_object1_code VARCHAR2,
                           p_object1_id1       VARCHAR2,
                           p_object1_id2       VARCHAR2)
 RETURN VARCHAR2;

 -- Get Service or Covd Level Name
 FUNCTION get_name (p_line_id IN NUMBER,
                    p_lse_id  IN NUMBER)
                    RETURN VARCHAR2;

 -- Function to get the commiment number.
 -- Parameters: p_commitment_id - Commitment ID
 FUNCTION get_commiment_number(p_commitment_id NUMBER,
                               p_org_id        NUMBER)
                               RETURN NUMBER;

 -- Function to validate whether the covered level is a standard item or a component.
 -- Parameter: p_line_id - Sub line ID.
 FUNCTION validate_component_yn(p_line_id   IN NUMBER)
                                RETURN VARCHAR2;

END OKS_MISC_UTIL_WEB;

 

/

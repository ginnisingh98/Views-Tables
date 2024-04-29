--------------------------------------------------------
--  DDL for Package OKL_CS_LC_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_LC_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLCRS.pls 120.10 2008/02/19 05:26:53 asawanka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_INFO_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL DECLARATION
  ---------------------------------------------------------------------------
 SUBTYPE  deal_tbl_type IS okl_deal_create_pub.deal_tab_type;

  PROCEDURE next_due(p_contract_id     IN  NUMBER,
                     o_next_due_amt    OUT NOCOPY NUMBER,
                     o_next_due_date   OUT NOCOPY DATE);
  PROCEDURE last_due(p_customer_id     IN  NUMBER,
                     p_contract_id     IN NUMBER,
                     o_last_due_amt    OUT NOCOPY NUMBER,
                     o_last_due_date   OUT NOCOPY DATE);
  PROCEDURE total_asset_cost(p_contract_id     IN  NUMBER,
                             o_asset_cost     OUT NOCOPY NUMBER);
  PROCEDURE total_subsidy_cost(p_contract_id     IN  NUMBER,
                               o_subsidy_cost     OUT NOCOPY NUMBER);
  PROCEDURE out_standing_rcvble(p_contract_id     IN  NUMBER,
                                o_rcvble_amt     OUT NOCOPY NUMBER);
 --varangan added for bug#5036582 start
  PROCEDURE outstanding_billed_amt(p_contract_id     IN  NUMBER,
                                   o_billed_amt      OUT NOCOPY NUMBER);
  PROCEDURE outstanding_unbilled_amt(p_contract_id     IN  NUMBER,
                                     o_unbilled_amt    OUT NOCOPY NUMBER);
  --bug#5036582 end
  PROCEDURE contract_dates(p_contract_id     IN  NUMBER,
                           o_start_date      OUT NOCOPY DATE,
                           o_end_date        OUT NOCOPY DATE,
                           o_term_duration   OUT NOCOPY NUMBER);
  PROCEDURE     rent_security_interest(p_contract_id      IN  NUMBER,
                           o_advance_rent     OUT NOCOPY NUMBER,
                           o_security_deposit OUT NOCOPY NUMBER,
                           o_interest_type    OUT NOCOPY VARCHAR2);
 PROCEDURE notes(p_contract_id     IN  NUMBER,
                 o_notes           OUT NOCOPY VARCHAR2
        		    );
  FUNCTION get_vendor_program(
     p_contract_id			IN NUMBER,
     x_vendor_program		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;
  -- Returns Private Label as a String namely URL
  FUNCTION get_private_label(
     p_contract_id			IN NUMBER,
     x_private_label          	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;
  -- Returns Currency Code
  FUNCTION get_currency(
     p_contract_id			IN NUMBER,
     x_currency			     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns "Y" or "N"
  FUNCTION get_syndicate_flag(
     p_contract_id			IN NUMBER,
     x_syndicate_flag		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  -- Returns org ID
  FUNCTION GET_ORG_ID(
			     p_contract_id	IN NUMBER,
			     x_org_id		OUT NOCOPY NUMBER
			   )
  RETURN VARCHAR2;

  FUNCTION GET_resource_ID(
			     x_res_id		OUT NOCOPY NUMBER
			   )
  RETURN VARCHAR2;

  FUNCTION get_warning_message(
     p_contract_id			IN NUMBER,
     x_delinquent_flag		     	OUT NOCOPY VARCHAR2,
     x_bankrupt_flag		     	OUT NOCOPY VARCHAR2,
     x_syndicate_flag		     	OUT NOCOPY VARCHAR2,
     x_special_handling_flag	     	OUT NOCOPY VARCHAR2
                                )
  RETURN VARCHAR2;

FUNCTION Get_K_Access_Level(p_chr_id IN NUMBER,
                            p_scs_code IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

PROCEDURE note_context_info (
	p_sql_statement IN VARCHAR2,
 -- SPILLAIP -2689257 - Start
	p_object_info IN OUT NOCOPY VARCHAR2,
 -- SPILLAIP -2689257 - End
	p_object_id IN NUMBER);

FUNCTION note_context_info (
	p_select_id VARCHAR2,
	p_select_name VARCHAR2,
	p_select_details VARCHAR2,
	p_from_table VARCHAR2,
	p_where_clause VARCHAR2,
	p_object_id NUMBER)
RETURN VARCHAR2;

FUNCTION party_type_info (
	p_object_id NUMBER)
RETURN VARCHAR2;

FUNCTION read_clob (
	p_clob CLOB)
RETURN VARCHAR2;

FUNCTION read_clob (
	p_note_id NUMBER)
RETURN VARCHAR2;

  FUNCTION get_contract_status(
     p_contract_id			IN NUMBER,
	 p_working_mode         IN VARCHAR2 DEFAULT 'QUERY',
	 p_contract_status      OUT NOCOPY VARCHAR2,
     x_allowed		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;
  FUNCTION contract_cust_accounts(	p_cust_acct_id	IN NUMBER,
    				                x_no_contracts	OUT NOCOPY NUMBER
			                      )  RETURN VARCHAR2;
  PROCEDURE EXECUTE(p_api_version           IN  NUMBER
                   ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                   ,x_return_status         OUT NOCOPY VARCHAR2
                   ,x_msg_count             OUT NOCOPY NUMBER
                   ,x_msg_data              OUT NOCOPY VARCHAR2
                   ,p_formula_name          IN  VARCHAR2
                   ,p_contract_id           IN  NUMBER
                   ,x_value                 OUT NOCOPY NUMBER
                   );

  PROCEDURE update_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_tbl                     IN  deal_tbl_type,
      x_durv_tbl                     OUT NOCOPY  deal_tbl_type
      );

 PROCEDURE commit_update;

 PROCEDURE contract_securitized(
                    p_contract_id           IN  NUMBER
                    ,x_value                OUT NOCOPY VARCHAR2
                   );

-- Added by rkuttiya for OKL.H
 FUNCTION Get_Total_Tax_Amount(p_trx_id IN NUMBER) RETURN NUMBER;

-- Added by rkuttiya in 11i OKL.H for Rebook Enhancements
 FUNCTION Get_Total_Stream_Amount(p_khr_id  IN NUMBER,
                                  p_kle_id  IN NUMBER,
                                  p_sty_id  IN NUMBER)
 RETURN NUMBER;

--dkagrawa added the function for bug # 4723838
FUNCTION get_asset_number(p_kle_id IN NUMBER)
RETURN VARCHAR2;
--dkagrawa added following function for okl12b to get the tax amount per line
FUNCTION get_ap_line_tax(p_invoice_id IN NUMBER, p_line_number IN NUMBER)
RETURN NUMBER;
--asawanka added for ebtax project
 FUNCTION get_tax_sch_Req_flag(
     p_contract_id			IN NUMBER)
  RETURN VARCHAR2;

-- zrehman added for Forward Port Bug#5759229
  FUNCTION get_cov_asset_id(p_kle_id IN NUMBER)
  RETURN NUMBER;

FUNCTION get_payment_remaining(p_khr_id  IN NUMBER) RETURN VARCHAR2;
FUNCTION get_term_remaining(p_khr_id  IN NUMBER) RETURN NUMBER;

FUNCTION get_total_billed(p_khr_id  IN NUMBER) RETURN NUMBER;
FUNCTION get_total_paid_credited(p_khr_id  IN NUMBER) RETURN NUMBER;
FUNCTION get_total_remaining(p_khr_id  IN NUMBER) RETURN NUMBER;


END Okl_Cs_Lc_Contract_Pvt;

/

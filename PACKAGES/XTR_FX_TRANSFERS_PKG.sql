--------------------------------------------------------
--  DDL for Package XTR_FX_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FX_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrimfxs.pls 120.4 2005/06/29 09:26:11 badiredd ship $*/

procedure TRANSFER_FX_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN);

procedure TRANSFER_FX_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN,
                            deal_num           OUT NOCOPY NUMBER);

/* Moved to xtrimddb.pls
procedure CHECK_USER_AUTH( p_external_deal_id IN VARCHAR2,
			   p_deal_type        IN  VARCHAR2,
			   p_company_code     IN VARCHAR2,
                           error              OUT NOCOPY BOOLEAN);
*/

procedure CHECK_MANDATORY_FIELDS(ARec_Interface         IN XTR_DEALS_INTERFACE%ROWTYPE,
                                 error          OUT NOCOPY BOOLEAN);

procedure VALIDATE_DEALS(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                         error OUT NOCOPY BOOLEAN);

procedure CALC_RATES(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                      error OUT NOCOPY boolean);

procedure CHECK_VALIDITY(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                         error OUT NOCOPY BOOLEAN) ;

function val_deal_date (p_date_a        IN date) return BOOLEAN;

function val_value_date (p_date_a        IN date,
                        p_date_b        IN date) return BOOLEAN;

function val_client_code(p_client_code  IN varchar2) return BOOLEAN;

function val_portfolio_code(p_company_code      IN varchar2,
                             p_cparty_code      IN varchar2,
                             p_portfolio_code   IN varchar2) return BOOLEAN;

function val_limit_code(    p_company_code      IN varchar2,
                             p_cparty_code      IN varchar2,
                             p_limit_code       IN varchar2) return BOOLEAN;

function val_buy_sell_curr_comb( p_buy_currency	IN varchar2,
			     p_sell_currency	IN varchar2) return BOOLEAN ;

function val_currencies( p_currency	IN varchar2) return BOOLEAN;

function val_comp_acct_no(p_company_code 	IN varchar2,
			  p_currency		IN varchar2,
			  p_account_no		IN varchar2) return BOOLEAN;

function val_cparty_ref(    p_cparty_account_no IN varchar2,
                             p_cparty_ref       IN varchar2,
                             p_cparty_code      IN varchar2,
                             p_currency_b       IN varchar2) return BOOLEAN;

function val_deal_linking_code( p_deal_linking_code     IN varchar2) return BOOLEAN;

function val_brokerage_code( p_brokerage_code   IN varchar2) return BOOLEAN;

function val_dealer_code(p_dealer_code        IN VARCHAR2) return BOOLEAN;

function val_cparty_code(p_company_code       IN VARCHAR2,
                           p_cparty_code        IN VARCHAR2) return BOOLEAN;

function val_deal_subtype(p_deal_subtype       IN VARCHAR2,
                           p_deal_type          IN VARCHAR2) return BOOLEAN;

function val_product_type(p_product_type        IN VARCHAR2,
			   p_deal_subtype       IN VARCHAR2,
                           p_deal_type          IN VARCHAR2) return BOOLEAN;

function val_pricing_model(p_pricing_model        IN VARCHAR2) return BOOLEAN ;

function val_market_data_set(p_market_data_set        IN VARCHAR2) return BOOLEAN ;

function val_brokerage_currency(p_brokerage_currency    IN VARCHAR2,
				p_deal_type		IN VARCHAR2,
				p_currency_a		IN VARCHAR2,
				p_currency_b		IN VARCHAR2,
				p_brokerage_code	IN VARCHAR2) return BOOLEAN ;

/* Moved to xtrimdds.pls
function val_desc_flex( p_Interface_Rec    IN XTR_DEALS_INTERFACE%ROWTYPE,
			p_error_segment	   IN OUT NOCOPY VARCHAR2) return BOOLEAN;
*/

Procedure copy_from_interface_to_fx(ARec_Interface IN xtr_deals_interface%rowtype );

procedure calc_hce_amounts (p_user_deal_type IN VARCHAR2, p_error OUT NOCOPY boolean);

procedure calc_brokerage_amt(p_user_deal_type IN VARCHAR2, p_bkr_amt_type IN varchar2, p_error OUT NOCOPY boolean);

procedure validate_buy_sell_amount (p_user_deal_type IN VARCHAR2, p_error OUT NOCOPY boolean);

procedure chk_buy_sell_amount(p_user_deal_type  IN VARCHAR2,
                              p_currency_first  IN varchar2,
			      p_error	    IN OUT NOCOPY boolean);

procedure create_fx_deal(ARec_Fx   IN xtr_deals%rowtype,
			 p_deal_no IN number);

procedure check_for_error(p_user_deal_type IN VARCHAR2, l_err_code IN NUMBER, l_level IN VARCHAR2 );


g_fx_main_rec         	xtr_deals%rowtype;
g_currency_first      	varchar2(30);
g_currency_second     	varchar2(30);
G_User_Id     		Number Default 0;
G_Curr_Date 		Date;
G_Fx_Deal_Type		Xtr_Deals.Deal_Type%Type Default 'FX';
G_Pricing_model         Xtr_Deals.pricing_model%Type;

END  XTR_FX_TRANSFERS_PKG;

 

/

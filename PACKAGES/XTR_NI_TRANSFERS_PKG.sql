--------------------------------------------------------
--  DDL for Package XTR_NI_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_NI_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrimnis.pls 120.2 2005/06/29 10:21:01 csutaria noship $*/

procedure TRANSFER_NI_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN);

procedure TRANSFER_NI_DEALS(ARec_Interface     IN  XTR_DEALS_INTERFACE%ROWTYPE,
                            user_error         OUT NOCOPY BOOLEAN,
                            mandatory_error    OUT NOCOPY BOOLEAN,
                            validation_error   OUT NOCOPY BOOLEAN,
                            limit_error        OUT NOCOPY BOOLEAN,
                            deal_num           OUT NOCOPY NUMBER);

procedure CHECK_MANDATORY_FIELDS(ARec_Interface         IN XTR_DEALS_INTERFACE%ROWTYPE,
                                 error          OUT NOCOPY BOOLEAN);

procedure VALIDATE_DEALS(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                         error OUT NOCOPY BOOLEAN);

procedure CALC_RATES(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                      error OUT NOCOPY boolean);

procedure CHECK_VALIDITY(ARec_Interface    IN XTR_DEALS_INTERFACE%ROWTYPE,
                         error OUT NOCOPY BOOLEAN) ;

FUNCTION val_deal_date (p_date_a        IN date) return BOOLEAN;

FUNCTION val_start_date (p_date_a        IN date,
                         p_date_b        IN date) return BOOLEAN;

FUNCTION val_maturity_date (p_date_a        IN date,
                            p_date_b        IN date) return BOOLEAN;

FUNCTION val_client_code(p_client_code         IN varchar2) return BOOLEAN;

FUNCTION val_portfolio_code(p_company_code   IN varchar2,
                            p_cparty_code    IN varchar2,
                            p_portfolio_code IN varchar2) return BOOLEAN;

FUNCTION val_currencies ( p_currency        IN varchar2) return BOOLEAN;

FUNCTION val_comp_acct_no(p_company_code         IN varchar2,
                          p_currency                IN varchar2,
                          p_account_no                IN varchar2) return BOOLEAN;

FUNCTION val_cparty_ref(     p_cparty_account_no  IN varchar2,
                             p_cparty_ref         IN varchar2,
                             p_cparty_code        IN varchar2,
                             p_currency           IN varchar2) return BOOLEAN;

FUNCTION val_deal_linking_code( p_deal_linking_code IN varchar2) return BOOLEAN;

FUNCTION val_brokerage_code ( p_brokerage_code        IN varchar2) return BOOLEAN;

FUNCTION val_dealer_code(p_dealer_code        IN VARCHAR2) return BOOLEAN;

FUNCTION val_cparty_code(p_company_code         IN VARCHAR2,
                         p_cparty_code          IN VARCHAR2) return BOOLEAN;

FUNCTION val_deal_subtype(p_user_deal_subtype IN VARCHAR2) return BOOLEAN;

FUNCTION val_product_type(p_product_type   IN VARCHAR2,
                          p_deal_subtype   IN VARCHAR2) return BOOLEAN;

FUNCTION val_pricing_model(p_pricing_model        IN VARCHAR2) return BOOLEAN;

FUNCTION val_market_data_set(p_market_data_set        IN VARCHAR2) return BOOLEAN;

FUNCTION val_risk_party_code(p_party_code        IN VARCHAR2) return BOOLEAN;

FUNCTION val_limit_code(p_limit_code        IN VARCHAR2,
                        p_company_code      IN VARCHAR2,
                        p_acceptor_code     IN VARCHAR2,
                        p_endorser_code     IN VARCHAR2,
                        p_drawer_code       IN VARCHAR2) return BOOLEAN;

FUNCTION val_rounding_type(p_rounding_type        IN VARCHAR2) return BOOLEAN;

FUNCTION val_day_count_type(p_day_count_type        IN VARCHAR2) return BOOLEAN;

FUNCTION val_year_calc_type(p_year_calc_type        IN VARCHAR2) return BOOLEAN;

FUNCTION val_year_calc_day_count_combo(p_year_calc_type IN VARCHAR2,
                                       p_day_count_type IN VARCHAR2) return BOOLEAN;

FUNCTION val_basis_type(p_basis_type        IN VARCHAR2) return BOOLEAN;

FUNCTION val_trans_rate(p_trans_rate        IN VARCHAR2,
                        p_currency            IN VARCHAR2) return BOOLEAN;

FUNCTION val_client_settle(p_client_settle        IN VARCHAR2) return BOOLEAN;

FUNCTION val_principal_tax_code(p_tax_code        IN VARCHAR2) return BOOLEAN;

FUNCTION val_interest_tax_code(p_tax_code        IN VARCHAR2) return BOOLEAN;

FUNCTION val_interest  (p_company_code      IN varchar2,
                        p_cparty_code       IN varchar2,
                        p_deal_type         IN varchar2,
                        p_currency_code     IN varchar2,
                        p_int_amount        IN number,
                        p_original_amount   IN number) RETURN boolean;

FUNCTION val_consideration(p_face_value        IN VARCHAR2,
                           p_consideration     IN VARCHAR2,
                           p_basis_type               IN VARCHAR2) return BOOLEAN;

FUNCTION val_serial_number(p_serial_number        IN VARCHAR2,
                           p_parcel_count         IN NUMBER) return BOOLEAN;

PROCEDURE CHECK_ACCRUAL_REVAL(ARec_interface IN xtr_deals_interface%ROWTYPE);

PROCEDURE copy_from_interface_to_ni(ARec_Interface IN xtr_deals_interface%rowtype );

PROCEDURE CALC_TOTAL_SPLITS(p_user_deal_type  in VARCHAR2,p_error OUT NOCOPY boolean);

PROCEDURE CALC_HCE_AMOUNTS (p_user_deal_type IN VARCHAR2, p_error OUT NOCOPY BOOLEAN);

PROCEDURE CALC_BROKERAGE_AMT(p_user_deal_type IN  VARCHAR2,
                             p_bkr_amt_type   IN  VARCHAR2,
                             p_error          OUT NOCOPY BOOLEAN);

PROCEDURE CREATE_NI_DEAL;


type g_ni_parcel_rec_type is table of xtr_parcel_splits%rowtype index by binary_integer;
type g_ni_trans_flex_type is table of xtr_transactions_interface%rowtype index by binary_integer;

type NUMBER_TABLE_TYPE is table of number index by binary_integer;

g_ni_main_rec                 xtr_deals%rowtype;
g_ni_parcel_rec               g_ni_parcel_rec_type;
g_user_id                     Number Default 0;
g_num_parcels                 Number Default 0;
g_curr_date                   Date;
g_ni_deal_type                Xtr_Deals.Deal_Type%Type Default 'NI';
g_ni_deal_subtype             Xtr_Deals.Deal_Subtype%Type;
g_no_of_days                  Xtr_Deals.No_Of_Days%Type;
g_year_basis                  Xtr_Deals.Year_Basis%Type;
g_ni_trans_flex               g_ni_trans_flex_type;
g_prn_tax_settle_method       xtr_tax_brokerage_setup_v.tax_settle_method%type;
g_prn_tax_calc_type           xtr_tax_brokerage_setup_v.calc_type%type;
g_int_tax_settle_method       xtr_tax_brokerage_setup_v.tax_settle_method%type;
g_int_tax_calc_type           xtr_tax_brokerage_setup_v.calc_type%type;

G_FV_AMT_HCE                  NUMBER_TABLE_TYPE;
G_INTEREST_HCE                NUMBER_TABLE_TYPE;
G_PRN_TAX_AMOUNT              NUMBER_TABLE_TYPE;
G_INT_TAX_AMOUNT              NUMBER_TABLE_TYPE;
G_DO_TAX_DEFAULTING           BOOLEAN;

END  XTR_NI_TRANSFERS_PKG;

 

/

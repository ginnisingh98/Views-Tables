--------------------------------------------------------
--  DDL for Package XTR_IG_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_IG_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrimigs.pls 120.9 2005/06/29 09:45:33 csutaria ship $ */
--------------------------------------------------------------------------

  Procedure Log_IG_Errors(p_Ext_Deal_Id   In Varchar2,
                          p_Deal_Type     In Varchar2,
                          p_Error_Column  In Varchar2,
                          p_Error_Code    In Varchar2,
                          p_Field_Name    In Varchar2 DEFAULT NULL);

  function VALID_CPARTY_CODE(p_comp   IN VARCHAR2,
                             p_cparty IN VARCHAR2) return boolean;

  function VALID_TRANSFER_DATE(p_transfer_date IN DATE) return boolean;

  function VALID_CURRENCY(p_curr IN VARCHAR2) return boolean;

  function VALID_COMP_ACCT(p_comp      IN VARCHAR2,
                           p_comp_acct IN VARCHAR2,
                           p_curr      IN VARCHAR2) return boolean;

  function VALID_PARTY_ACCT(p_party      IN VARCHAR2,
                            p_party_acct IN VARCHAR2,
                            p_curr       IN VARCHAR2) return boolean;

  function VALID_ACTION(p_action IN VARCHAR2) return boolean;

  function VALID_PRODUCT(p_product IN VARCHAR2) return boolean;

  function VALID_PORTFOLIO(p_comp      IN VARCHAR2,
                           p_cparty    IN VARCHAR2,
                           p_portfolio IN VARCHAR2) return boolean;

  function VALID_LIMIT_CODE(p_comp       IN VARCHAR2,
                            p_cparty     IN VARCHAR2,
                            p_limit      IN VARCHAR2,
                            p_limit_type IN VARCHAR2) return boolean;
                         -- p_balance IN NUMBER) return boolean;

  function VALID_PRINCIPAL_ADJUST(p_value IN NUMBER) return boolean;

-- Bug 2994712
  function VALID_DEAL_LINKING_CODE(p_deal_linking_code IN varchar2) return boolean;

-- Bug 2684411
  function VALID_DEALER_CODE(p_dealer_code IN varchar2) return boolean;

  function VALID_COMP_REPORTING_CCY (p_comp IN VARCHAR2) return boolean;


  procedure VALID_IG_ACCT(p_comp          IN VARCHAR2,
                          p_cparty        IN VARCHAR2,
                          p_curr          IN VARCHAR2,
                          p_transfer_date IN DATE,
                          p_ext_deal_no   IN VARCHAR2,
                          p_deal_type     IN VARCHAR2,
                          p_error         IN OUT NOCOPY BOOLEAN);

  procedure COPY_FROM_INTERFACE_TO_IG(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype );

  procedure CALC_DETAILS;

  procedure CALC_HCE_AMTS;

  procedure CALCULATE_VALUES (ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_err_limit OUT NOCOPY VARCHAR2);

  procedure CHECK_MANDATORY_FIELDS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_error OUT NOCOPY BOOLEAN);

  procedure VALIDATE_DEALS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_error OUT NOCOPY BOOLEAN);

  procedure GET_DEAL_TRAN_NUMBERS(p_comp     IN VARCHAR2,
                                  p_cparty   IN VARCHAR2,
                                  p_curr     IN VARCHAR2,
                                  p_deal_no  IN OUT NOCOPY NUMBER,
                                  p_tran_no  IN OUT NOCOPY NUMBER,
                                  p_new_deal IN VARCHAR2 DEFAULT 'Y');

  procedure CREATE_IG_DEAL(ARec_IG  IN  XTR_INTERGROUP_TRANSFERS%rowtype );

  procedure SETTLE_DDA (p_settle_flag   IN  VARCHAR2,
                        p_actual_settle IN  DATE,
                        p_settle        OUT NOCOPY VARCHAR2,
                        p_settle_no     OUT NOCOPY NUMBER,
                        p_settle_auth   OUT NOCOPY VARCHAR2,
                        p_settle_date   OUT NOCOPY DATE,
                        p_trans_mts     OUT NOCOPY VARCHAR2,
                        p_audit_indic   OUT NOCOPY VARCHAR2);


  procedure INS_DEAL_DATE_AMTS;

  function IS_MIRROR_DEAL(p_comp IN VARCHAR2,
                          p_cparty   IN VARCHAR2,
                          p_curr     IN VARCHAR2) return boolean;

  function IS_COMPANY(p_comp   IN VARCHAR2) return boolean;

  procedure CASCADE_RECALC(p_company_code  IN  VARCHAR2,
                           p_party_code    IN  VARCHAR2,
                           p_currency      IN  VARCHAR2,
                           p_transfer_date IN  DATE,
                           p_fund_limit    IN  VARCHAR2,
                           p_invest_limit  IN  VARCHAR2,
                           p_update        IN  VARCHAR2,
			   p_rounding_type IN  VARCHAR2 default NULL,  --* Add for Interest Project
			   p_day_count_type IN VARCHAR2 default NULL,  --* Add for Interest Project
			   p_types_update   IN VARCHAR2 default NULL); --* Add for Interest Project
                        -- p_error         OUT VARCHAR2);

  procedure TRANSFER_IG_DEALS( ARec_Interface     IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN);

  procedure TRANSFER_IG_DEALS( ARec_Interface     IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN,
                               deal_num           OUT NOCOPY NUMBER);

  -- 3800146 new signature --------------------------------------------------------
  procedure TRANSFER_IG_DEALS( ARec_Interface     IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN,
                               deal_num           OUT NOCOPY NUMBER,
                               tran_num           OUT NOCOPY NUMBER,
                               mirror_deal_num    OUT NOCOPY NUMBER,
                               mirror_tran_num    OUT NOCOPY NUMBER);
 ----------------------------------------------------------------------------------

  procedure MIRROR_INIT(p_mirror_deal      IN  VARCHAR2 DEFAULT NULL,
                        p_mirror_deal_no   IN  NUMBER   DEFAULT NULL,
                        p_mirror_trans_no  IN  NUMBER   DEFAULT NULL,
		      	p_rounding_type	   IN  VARCHAR2 DEFAULT NULL,    --* Added for Interest Override
		      	p_day_count_type   IN  VARCHAR2 DEFAULT NULL);  --* Added for Interest Override

  procedure UPDATE_PRICING_MODEL(p_company_code VARCHAR2,
                                 p_party_code VARCHAR2,
                                 p_currency VARCHAR2,
                                 p_pricing_model VARCHAR2);

  procedure DEFAULT_PRICING_MODEL(p_company_code IN VARCHAR2,
                                  p_party_code IN VARCHAR2,
                                  p_currency IN VARCHAR2,
                                  p_product_type IN VARCHAR2,
                                  p_pricing_model OUT NOCOPY VARCHAR2);


   --* Public Variables
   G_Ig_curr_date       DATE;
   G_Ig_SysDate		DATE;
   G_Ig_user_id	        NUMBER;
   G_Ig_user            xtr_dealer_codes.dealer_code%TYPE;
   G_Ig_bal_out	        NUMBER;
   G_Ig_action          XTR_AMOUNT_ACTIONS.ACTION_CODE%type;
   G_Ig_year_calc_type  XTR_MASTER_CURRENCIES_V.IG_YEAR_BASIS%type;
   G_Ig_Main_Rec        XTR_INTERGROUP_TRANSFERS%rowtype;
   G_Ig_Mirror_Rec      XTR_INTERGROUP_TRANSFERS%rowtype;

   /*------------------ Rvallams: Bug# 2229236 -------------------------*/

   G_Ig_Source          VARCHAR2(10);
   G_Ig_Mirror_Deal     VARCHAR2(1);
   G_Ig_Orig_Deal_No    NUMBER;
   G_Ig_Orig_Trans_No   NUMBER;

   /*----------------- Added for Interest Project ----------------------*/
   G_Ig_Rounding_Type	VARCHAR2(1);
   G_Ig_Day_Count_Type  VARCHAR2(1);
   G_Ig_Original_Amount NUMBER;

   /*-----------------  3800146  Added for IG/IAC Redesign  ----------------------*/
   G_Ig_External_Source VARCHAR2(30);
   G_Ig_Settlement_Flag VARCHAR2(1);
   G_Main_log_id        NUMBER;
   G_Mirror_log_id      NUMBER;

   /*-----------------  3800146  Added for IG/IAC Redesign  ----------------------*/
   C_ZBA            constant VARCHAR2(3)  := 'ZBA';
   C_CL             constant VARCHAR2(3)  := 'CL';


END;

 

/

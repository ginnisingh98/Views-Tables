--------------------------------------------------------
--  DDL for Package XTR_EXP_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_EXP_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrimexs.pls 120.6 2005/06/29 09:20:34 badiredd ship $ */
--------------------------------------------------------------------------

procedure LOG_ERRORS(p_Ext_Deal_Id   In Varchar2,
                          p_Deal_Type     In Varchar2,
                          p_Error_Column  In Varchar2,
                          p_Error_Code    In Varchar2,
                          p_Field_Name    In Varchar2 DEFAULT NULL);

function VALID_COMPANY_CODE(p_comp   IN VARCHAR2) return boolean;

function VALID_STATUS_CODE(p_status_code IN VARCHAR2) return boolean;

function VALID_EXPOSURE_TYPE(p_comp   IN VARCHAR2,
				p_exposure_type IN VARCHAR2) return boolean;

function VALID_DEAL_SUBTYPE(p_deal_type   IN VARCHAR2,
				p_deal_subtype IN VARCHAR2) return boolean;

function VALID_PORTFOLIO(p_comp      IN VARCHAR2,
                           p_portfolio IN VARCHAR2) return boolean;

function VALID_ACTION(p_action IN VARCHAR2,
			p_deal_type IN VARCHAR2) return boolean;

function VALID_CURRENCY(p_curr IN VARCHAR2) return boolean;

function VALID_COMP_ACCT(p_comp      IN VARCHAR2,
                           p_comp_acct IN VARCHAR2,
                           p_curr      IN VARCHAR2) return boolean;

function VALID_SETTLE_ACTION(p_settle_action      IN VARCHAR2,
                           p_deal_subtype IN VARCHAR2,
                           p_act_amount IN NUMBER,
			   p_act_date IN DATE,
			   p_cparty_code IN VARCHAR2) return boolean;

function VALID_CPARTY_CODE(p_comp   IN VARCHAR2,
                             p_cparty IN VARCHAR2) return boolean;

function VALID_CPARTY_REF(  p_cparty_account_no IN VARCHAR2,
                            p_cparty_ref IN VARCHAR2,
                            p_cparty IN VARCHAR2,
			    p_curr IN VARCHAR2) return boolean;

function VALID_DEALER_CODE(p_dealer_code IN VARCHAR2) return boolean;

procedure COPY_FROM_INTERFACE_TO_EXP
	(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype,
	 p_error OUT NOCOPY BOOLEAN);

PROCEDURE INS_DEAL_DATE_AMOUNTS (ARec_Exp IN XTR_EXPOSURE_TRANSACTIONS%rowtype);

procedure CHECK_MANDATORY_FIELDS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_error OUT NOCOPY BOOLEAN);

procedure VALIDATE_DEALS(ARec_Interface IN XTR_DEALS_INTERFACE%rowtype, p_error OUT NOCOPY BOOLEAN);

function GET_TRANSACTION_NUMBER return number;

function GET_CPARTY_ACCOUNT(p_cparty_code IN VARCHAR2,
			p_curr IN VARCHAR2,
			p_cparty_ref IN VARCHAR2) return varchar2;

procedure CREATE_EXP_DEAL(ARec_EXP IN XTR_EXPOSURE_TRANSACTIONS%rowtype);

procedure TRANSFER_EXP_DEALS( ARec_Interface IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN);

procedure TRANSFER_EXP_DEALS( ARec_Interface IN  XTR_DEALS_INTERFACE%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN,
                               deal_num           OUT NOCOPY NUMBER);

procedure TRANSFER_EXP_DEALS(
			ARec IN OUT NOCOPY XTR_EXPOSURE_TRANSACTIONS%rowtype,
                               p_source           IN  VARCHAR2,
                               user_error         OUT NOCOPY BOOLEAN,
                               mandatory_error    OUT NOCOPY BOOLEAN,
                               validation_error   OUT NOCOPY BOOLEAN,
                               limit_error        OUT NOCOPY BOOLEAN);

   --* Public Variables
   G_curr_date       DATE;
   G_user_id	     NUMBER;
   G_user            xtr_dealer_codes.dealer_code%TYPE;
   G_Main_Rec        XTR_EXPOSURE_TRANSACTIONS%rowtype;
   G_Source       VARCHAR2(10);
   G_cparty_account VARCHAR2(20);

END;

 

/

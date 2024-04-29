--------------------------------------------------------
--  DDL for Package XTR_MISC_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_MISC_P" AUTHID CURRENT_USER AS
/* $Header: xtrprc3s.pls 120.1.12010000.2 2008/08/06 10:44:20 srsampat ship $ */
--
-- Stored procedures/functions
--
PROCEDURE FPS_AUDIT(p_audit_requested_by IN VARCHAR2,
                    p_event_name         IN VARCHAR2,
                    p_date_from          IN VARCHAR2,
                    p_date_to            IN VARCHAR2);

PROCEDURE MAINTAIN_LANGUAGE(l_form     IN VARCHAR2,
                            l_item     IN VARCHAR2,
                            l_old_val  IN VARCHAR2,
                            l_new_val  IN VARCHAR2,
                            l_option   IN VARCHAR2,
                            l_language IN VARCHAR2,
                            l_original_text IN VARCHAR2);       -- 3424625 Added new parameter

PROCEDURE DEAL_ACTIONS(p_deal_type          IN VARCHAR2,
                       p_deal_number        IN NUMBER,
                       p_transaction_number IN NUMBER,
                       p_action_type        IN VARCHAR2,
                       p_cparty_code        IN VARCHAR2,
                       p_client_code        IN VARCHAR2,
                       p_date_created       IN DATE,
                       p_company_code       IN VARCHAR2,
                       p_status_code        IN VARCHAR2,
                       p_file_name          IN VARCHAR2,
                       p_deal_subtype       IN VARCHAR2,
                       p_currency           IN VARCHAR2,
                       p_cparty_advice      IN VARCHAR2,
                       p_client_advice      IN VARCHAR2,
                       p_amount             IN NUMBER,
                       p_org_flag           IN VARCHAR2);

PROCEDURE INS_ACTUALS(
     			p_company_code	  	IN varchar2,
			p_currency	  	IN varchar2,
			p_portfolio_code  	IN varchar2,
			p_from_date	  	IN date,
			p_to_date	  	IN date,
			p_fund_invest	  	IN varchar2,
        		p_amount_unit	  	IN number,
			p_inc_ig		IN varchar2,
        		p_unique_ref_number     IN number,
			p_company_name	        IN varchar2,
			p_port_name		IN varchar2,
			p_floating_less	        IN varchar2);

PROCEDURE VALIDATE_DEALS( p_deal_no      IN NUMBER,
                          p_trans_no	 IN NUMBER,
                          p_deal_type    IN VARCHAR2,
                          p_action_type  IN VARCHAR2,
                          p_validated_by IN VARCHAR2);

PROCEDURE MAINT_PROJECTED_BALANCES;

PROCEDURE CHK_PRO_AUTH(
   			p_event  	IN VARCHAR2,
   			p_company_code  IN VARCHAR2,
   			p_user		IN VARCHAR2,
   			p_deal_type	IN VARCHAR2,
   			p_action	IN VARCHAR2);
PROCEDURE SETOFF;


END XTR_MISC_P;

/

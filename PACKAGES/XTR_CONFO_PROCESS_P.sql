--------------------------------------------------------
--  DDL for Package XTR_CONFO_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CONFO_PROCESS_P" AUTHID CURRENT_USER as
/* $Header: xtrconfs.pls 120.1 2005/06/29 06:12:36 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE POST_CONFIRMATION_DETAILS(p_deal_no IN NUMBER,
                                                      p_trans_no IN NUMBER,
                                                      p_action IN VARCHAR2,
                                                      p_cparty IN VARCHAR2,
                                                      p_client IN VARCHAR2,
                                                      p_company_code IN VARCHAR2,
                                                      p_confo_party_code IN VARCHAR2,
                                                      p_deal_type IN VARCHAR2,
                                                      p_deal_subtype IN VARCHAR2,
                                                      p_currency IN VARCHAR2,
                                                      p_amount IN NUMBER,
                                                      p_deal_status IN VARCHAR2);
--
PROCEDURE CANCEL_CONFO(p_deal_no IN NUMBER,
                       p_trans_no IN NUMBER);
--
PROCEDURE CALL_XTRLTCFM (P_TEMPLATE_TYPE    IN VARCHAR2,
                         P_TEMPLATE_NAME    IN VARCHAR2,
                         P_CREATED_ON       IN DATE,
                         P_EFFECTIVE_DATE   IN DATE,
                         P_DEAL_NO          IN NUMBER,
                         P_PRODUCT_TYPE     IN VARCHAR2,
                         P_PAYMENT_SCHEDULE IN VARCHAR2,
                         P_TOTAL            OUT NOCOPY  NUMBER,
                         P_SUCCESS          OUT NOCOPY NUMBER);
--
----------------------------------------------------------------------------------------------------------------
end XTR_CONFO_PROCESS_P;

 

/

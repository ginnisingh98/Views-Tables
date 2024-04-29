--------------------------------------------------------
--  DDL for Package AR_CONFIRMATION_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CONFIRMATION_ACTION" AUTHID CURRENT_USER AS
/*$Header: ARCOATNS.pls 115.1 2002/09/26 00:48:10 tkoshio noship $ */

procedure SUCCESSFUL_TRANSMISSION(      P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure DUPL_INV_NUM_IN_IMPORT(       P_STATUS in VARCHAR2,
					P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure DUPLICATE_INVOICE_NUMBER(     P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure DUPLICATE_LINE_NUMBER(        P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INCONSISTENT_CURR(            P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INCONSISTENT_PO_SUPPLIER(     P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_LINE_AMOUNT(          P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_INVOICE_AMOUNT(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_PO_INFO(              P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_PO_NUM(               P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_PO_RELEASE_INFO(      P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_PO_RELEASE_NUM(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_PO_SHIPMENT_NUM(      P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_PRICE_QUANTITY(       P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_QUANTITY(             P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_SUPPLIER(             P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);


procedure INVALID_SUPPLIER_SITE(        P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure INVALID_UNIT_PRICE(           P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure NO_PO_LINE_NUM(               P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure NO_SUPPLIER(                  P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);

procedure RELEASE_MISSNG(               P_STATUS in VARCHAR2,
                                        P_ID in VARCHAR2,
                                        P_REASON_CODE in VARCHAR2,
                                        P_DESCRIPTION in VARCHAR2,
                                        P_MSGID in VARCHAR2);
end;

 

/

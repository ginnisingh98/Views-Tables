--------------------------------------------------------
--  DDL for Package AP_CREDIT_CARD_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CREDIT_CARD_INVOICE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwcciis.pls 120.5 2005/06/16 07:46:43 nammishr ship $ */
PROCEDURE createCreditCardInvoice(
	errbuf		OUT NOCOPY	VARCHAR2,
	retcode		OUT NOCOPY	NUMBER,
	p_cardProgramID	IN		NUMBER,
	p_startDate 	IN 		DATE DEFAULT NULL,
	p_endDate 	IN 		DATE DEFAULT NULL,
	p_invoiceId	OUT NOCOPY	NUMBER);

/*
Purpose:
  To reverse expense credit card receitps that are prepaid by company. Specifically, this
  procedure does:
  1. Create negative lines in the ap_invoice_distributions tables for prepaid
     business credit card lines
  2. Update the amout and base_amount of the corresponding invoice in AP_INVOICES.
Input:
  p_invoiceId         : invoice id
  p_expReportHeaderId : expense report header id
  p_glDate            : GL date
  p_periodName        : period name
Output:
  None
Input Output:
  None
Date:
  3/28/00
*/
PROCEDURE createCCardReversals(p_invoiceId          IN NUMBER,
                               p_expReportHeaderId  IN NUMBER,
                               p_glDate             IN DATE,
                               p_periodName         IN VARCHAR2);

FUNCTION  createCreditCardReversals(p_invoiceId          IN NUMBER,
                                    p_expReportHeaderId  IN NUMBER,
                                    p_gl_date            IN DATE,
                                    p_invoiceTotal             IN NUMBER) RETURN NUMBER;

END AP_CREDIT_CARD_INVOICE_PKG;

 

/

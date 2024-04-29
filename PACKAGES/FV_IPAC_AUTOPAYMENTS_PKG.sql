--------------------------------------------------------
--  DDL for Package FV_IPAC_AUTOPAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_IPAC_AUTOPAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: FVIPAPMS.pls 120.2 2006/02/24 03:55:46 bnarang noship $*/

PROCEDURE Main( x_errbuf         OUT NOCOPY VARCHAR2,
                x_retcode        OUT NOCOPY NUMBER,
                p_batch_name                VARCHAR2,
                p_payment_bank_acct_id IN  NUMBER,
                p_payment_profile_id        IN  NUMBER,
                p_payment_document_id       IN  NUMBER,
                p_org_id                    IN NUMBER,
                p_set_of_books_id           IN  NUMBER
                --p_document_id             IN  NUMBER
                );

PROCEDURE Get_Required_Parameters;

PROCEDURE Validate_Invoices;

PROCEDURE Call_Approval_Api(p_invoice_id NUMBER,
			    p_invoice_num VARCHAR2,
			    p_invoice_date DATE,
                            p_payment_method VARCHAR2,
			    p_invoice_flag VARCHAR2,
			    p_validate_flag VARCHAR2);

PROCEDURE Insert_IA_Txns(p_invoice_id   NUMBER,
                            p_invoice_num  VARCHAR2,
			    x_paygroup	OUT NOCOPY VARCHAR2);

PROCEDURE Update_WfStatus(p_invoice_id NUMBER);

PROCEDURE Create_Output_Messages;

PROCEDURE Log_Mesg(p_debug_flag VARCHAR2,
                   p_message    VARCHAR2);

END Fv_Ipac_AutoPayments_Pkg;

 

/

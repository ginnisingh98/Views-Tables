--------------------------------------------------------
--  DDL for Package AP_ETAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ETAX_PKG" AUTHID CURRENT_USER AS
/* $Header: apetaxps.pls 120.4 2006/10/12 19:05:19 schitlap noship $ */

  FUNCTION Calling_eTax(
             P_Invoice_id              IN  NUMBER,
             P_Line_Number             IN  NUMBER 			DEFAULT NULL,
             P_Calling_Mode            IN  VARCHAR2,
             P_Override_Status         IN  VARCHAR2 			DEFAULT NULL,
             P_Line_Number_To_Delete   IN  NUMBER 			DEFAULT NULL,
             P_Interface_Invoice_Id    IN  NUMBER 			DEFAULT NULL,
	     P_Event_Id		       IN  NUMBER			DEFAULT NULL,
             P_All_Error_Messages      IN  VARCHAR2,
             P_error_code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN  VARCHAR2) RETURN BOOLEAN;

  FUNCTION Calculate_Quote(
             P_Calling_Mode            IN  VARCHAR2,
             P_All_Error_Messages      IN  VARCHAR2,
             P_Invoice_Header_Rec      IN  ap_invoices_all%ROWTYPE	DEFAULT NULL,
             P_Invoice_Lines_Rec       IN  ap_invoice_lines_all%ROWTYPE DEFAULT NULL,
	     P_Tax_Amount	       OUT NOCOPY NUMBER,
	     P_Tax_Amt_Included        OUT NOCOPY VARCHAR2,
             P_error_code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN  VARCHAR2) RETURN BOOLEAN;

  -- this is a wrapper of calling_etax() used by JDBC call
  FUNCTION callETax(
             x_Invoice_id              IN  NUMBER,
             x_Line_Number             IN  NUMBER                       DEFAULT NULL,
             x_Calling_Mode            IN  VARCHAR2,
             x_Override_Status         IN  VARCHAR2                     DEFAULT NULL,
             x_Line_Number_To_Delete   IN  NUMBER                       DEFAULT NULL,
             x_Interface_Invoice_Id    IN  NUMBER                       DEFAULT NULL,
             x_Event_Id                IN  NUMBER                       DEFAULT NULL,
             x_All_Error_Messages      IN  VARCHAR2,
             x_error_code              OUT NOCOPY VARCHAR2,
             x_Calling_Sequence        IN  VARCHAR2) RETURN NUMBER;

AP_APPLICATION_ID
   CONSTANT NUMBER
   := 200;

AP_ENTITY_CODE
   CONSTANT VARCHAR2(30)
   := 'AP_INVOICES';

AP_INV_EVENT_CLASS_CODE
   CONSTANT VARCHAR2(30)
   := 'STANDARD INVOICES';

AP_PP_EVENT_CLASS_CODE
   CONSTANT VARCHAR2(30)
   := 'PREPAYMENT INVOICES';

AP_ER_EVENT_CLASS_CODE
   CONSTANT VARCHAR2(30)
   := 'EXPENSE REPORTS';

G_BATCH_LIMIT
   CONSTANT NUMBER
   := 1000;

TYPE g_inv_id_type   IS TABLE OF AP_INVOICES_ALL.INVOICE_ID%TYPE INDEX BY PLS_INTEGER;
TYPE g_evnt_cls_type IS TABLE OF ZX_TRX_HEADERS_GT.EVENT_CLASS_CODE%TYPE INDEX BY PLS_INTEGER;

g_inv_id_list	g_inv_id_type;
g_evnt_cls_list	g_evnt_cls_type;


END AP_ETAX_PKG;


 

/

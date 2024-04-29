--------------------------------------------------------
--  DDL for Package AP_INVOICE_LINES_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICE_LINES_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: apilnuts.pls 120.13.12010000.2 2008/08/08 03:17:42 sparames ship $ */

FUNCTION get_encumbered_flag(
             p_invoice_id  IN  NUMBER,
             p_line_number IN  NUMBER ) RETURN VARCHAR2;

FUNCTION get_posting_status(
             p_invoice_id   IN NUMBER,
             p_line_number  IN NUMBER ) RETURN VARCHAR2;

FUNCTION get_approval_status(
             p_invoice_id   IN NUMBER,
             p_line_number  IN NUMBER) RETURN VARCHAR2;

FUNCTION Is_Line_Discardable(
             P_line_rec          IN  ap_invoice_lines%ROWTYPE,
             P_error_code            OUT NOCOPY VARCHAR2,
             P_calling_sequence  IN             VARCHAR2) RETURN BOOLEAN;

FUNCTION Allocation_Exists (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;
FUNCTION Inv_Reversed_Via_Qc (p_Invoice_Id       Number,
                              p_Calling_Sequence Varchar2) RETURN BOOLEAN;

FUNCTION Is_Line_Dists_Trans_FA (p_Invoice_Id   Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;
FUNCTION Line_Dists_Acct_Event_Created (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;

FUNCTION Line_Referred_By_Corr (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;

FUNCTION Line_Dists_Referred_By_Other(p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;

FUNCTION Outstanding_Alloc_Exists (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;

FUNCTION Line_Dists_Trans_Pa (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) RETURN BOOLEAN;

FUNCTION Can_Line_Be_Deleted (p_line_rec    IN ap_invoice_lines%ROWTYPE,
                              p_error_code  OUT NOCOPY Varchar2,
                              p_Calling_Sequence  Varchar2) RETURN BOOLEAN;

FUNCTION Get_Packet_Id (p_invoice_id In Number,
                        p_Line_Number In Number)    RETURN NUMBER;

FUNCTION Is_Line_Fully_Distributed(
           P_Invoice_Id           IN NUMBER,
           P_Line_Number          IN NUMBER,
           P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Is_PO_RCV_Amount_Exceeded(
           P_Invoice_Id           IN NUMBER,
           P_Line_Number          IN NUMBER,
           P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Is_Invoice_Fully_Distributed (
          P_invoice_id IN NUMBER) RETURN BOOLEAN;

--Invoice Lines: Distributions
FUNCTION Pending_Alloc_Exists_Chrg_Line
                           (p_Invoice_Id        Number,
                            p_Line_Number       Number,
                            p_Calling_Sequence  Varchar2) Return BOOLEAN ;

--ETAX: Invwkb
FUNCTION Is_Line_a_Correction(
		P_Invoice_Id           IN NUMBER,
           	P_Line_Number          IN NUMBER,
	        P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Line_Referred_By_Adjustment(
		P_Invoice_Id           IN NUMBER,
	        P_Line_Number          IN NUMBER,
	        P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Is_Line_a_Adjustment(
		P_Invoice_Id           IN NUMBER,
		P_Line_Number          IN NUMBER,
		P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Is_Line_a_Prepay(
		P_Invoice_Id           IN NUMBER,
		P_Line_Number          IN NUMBER,
		P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

Function Get_Retained_Amount
		(p_line_location_id IN NUMBER,
		 p_match_amount	    IN NUMBER) RETURN NUMBER;

-- Bug 6917289
PROCEDURE Manual_Withhold_Tax(p_invoice_id IN number
                             ,p_manual_withhold_amount IN number);

-- Bug 6917289
FUNCTION get_awt_flag(
             p_invoice_id  IN  NUMBER,
             p_line_number IN  NUMBER ) RETURN VARCHAR2;

END  AP_INVOICE_LINES_UTILITY_PKG;


/

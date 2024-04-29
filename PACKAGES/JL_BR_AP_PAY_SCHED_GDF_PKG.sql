--------------------------------------------------------
--  DDL for Package JL_BR_AP_PAY_SCHED_GDF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AP_PAY_SCHED_GDF_PKG" AUTHID CURRENT_USER AS
/* $Header: jlbrpgps.pls 120.6 2006/05/25 19:22:58 dbetanco ship $ */

Procedure VALIDATE_DATE
            (
             p_date date,
             p_city varchar2,
             p_new_date IN OUT NOCOPY date,
             p_status IN OUT NOCOPY number);

Procedure APXWKB_BR_VALIDATE_DATE_LOCAL
            (
             p_in_date Date,
             p_vendor_site_id Number,
             new_date_val IN OUT NOCOPY Varchar2);

Procedure APXINWKB_BR_DEF_PS_SEGMENTS
            (
             P_Invoice_ID Number,
             p_vendor_site_id Number);

PROCEDURE APXINWKB_BR_VALIDATE_PAY_SCHED
            (
             P_Invoice_ID Number,
             p_invoice_type_lookup_code Varchar2,
             p_colldoc_assoc Varchar2,
             P_Vendor_Site_Id Number);

PROCEDURE Suppl_Def_Pay_Sched_GDF
            (
             P_Invoice_Id  ap_invoices_all.invoice_id%TYPE);

Procedure VALIDATE_DATE
            (
             p_date date,
             p_city varchar2,
             p_new_date IN OUT NOCOPY date,
             p_status IN OUT NOCOPY number,
             p_state varchar2); --Bug # 2319552

/* ***************************************************************
   Function : GET_BORDERO_BANK_REF
   Return   : jl_br_ap_collection_docs.OUR_NUMBER
   Type     : Varchar2
   Objective: Return Bank references stored in 'our_number'
              to ipayments extract. This field is display in
              Bordero as Bank Reference.
   *************************************************************** */
FUNCTION Get_Bordero_Bank_Ref
           (P_Doc_Payable_ID  IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_RETURN_STATUS   OUT NOCOPY     Varchar2)
            RETURN Varchar2;

/* ***************************************************************
   Function : GET_BORDERO_INT_AMT
   Return   : Invoice Interest Amount
   Type     : Number
   Objective: Return Invoice Interest Amount
   *************************************************************** */
FUNCTION Get_Bordero_Int_Amt
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_Process_Type      IN  VARCHAR2,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
            RETURN Number;

/* ***************************************************************
   Function : GET_BORDERO_ABATEMENT
   Return   : Invoice Interest Amount
   Type     : Number
   Objective: Return Invoice Abatement Amount
   *************************************************************** */
FUNCTION Get_Bordero_Abatement
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_Process_Type      IN  VARCHAR2,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
            RETURN Number;

/* ***************************************************************
   Function : Check_Brazil
   Return   : Checking if country is brazil
   Type     : Number
   Objective: Verify if invoice country is brazil
   *************************************************************** */
Function Check_Brazil
           (P_Doc_Payable_ID    IN  IBY_Docs_Payable_All.document_payable_id%TYPE,
            P_RETURN_STATUS     OUT NOCOPY  Varchar2)
RETURN Number;

END JL_BR_AP_PAY_SCHED_GDF_PKG; -- Package

 

/

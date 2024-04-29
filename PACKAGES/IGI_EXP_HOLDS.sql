--------------------------------------------------------
--  DDL for Package IGI_EXP_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_HOLDS" AUTHID CURRENT_USER AS
--  $Header: igiexprs.pls 120.5.12000000.1 2007/09/13 04:24:29 mbremkum ship $

   PROCEDURE Place_Release_Hold ( p_invoice_id       IN NUMBER
                                  -- Bug 2469158
                                , p_invoice_amt      IN NUMBER
                                , p_source           IN VARCHAR2
                                , p_cancelled_date   IN DATE
                , p_place_release    IN VARCHAR2
                                , p_hold_lookup_code IN VARCHAR2
                                , p_calling_sequence IN VARCHAR2
                                -- Bug 3595853
                                , p_temp_cancelled_amount IN NUMBER default NULL);

   PROCEDURE Igi_Exp_Ap_Holds_T2(p_calling_sequence IN VARCHAR2);

   -- Bug 2438858
   PROCEDURE Igi_Exp_Ap_Inv_Dist_T2(p_calling_sequence IN VARCHAR2);

   -- Bug 5905190
   PROCEDURE Igi_Exp_Ap_Inv_Line_T2(p_calling_sequence IN VARCHAR2);

   -- Variables to be used from triggers on AP_HOLDS_ALL table
   TYPE InvoiceTabType IS TABLE OF NUMBER(15)
   INDEX BY BINARY_INTEGER;

   l_TableRow        NUMBER(15) := 0;
   l_InvoiceIdTable  InvoiceTabType;
   l_UpdatedByTable  InvoiceTabType;

   -- Bug 2438858
   -- Variables to be used from triggers on AP_INVOICE_DISTRIBUTIONS_ALL table
   l_DistTableRow        NUMBER(15) := 0;
   l_InvoiceIdDistTable  InvoiceTabType;
   l_UpdatedByDistTable  InvoiceTabType;


   -- Bug 5905190
   -- Variables to be used from triggers on AP_INVOICE_LINES_ALL table
   l_LineTableRow        NUMBER(15) := 0;
   l_InvoiceIdLineTable  InvoiceTabType;
   l_UpdatedByLineTable  InvoiceTabType;

END igi_exp_holds;

 

/

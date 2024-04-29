--------------------------------------------------------
--  DDL for Package PA_PWP_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PWP_SUMM_PKG" AUTHID CURRENT_USER AS
--  $Header: PAPWPSMS.pls 120.0.12010000.2 2009/01/17 06:07:06 jjgeorge noship $

-- This procedure populates data in PA_PWP_CUSTOMER_SUMM_ALL table.
-- The data populated in PA_PWP_CUSTOMER_SUMM_ALL table is used in subcontractor
--(supplier) workbench.
Procedure Populate_summary(P_Project_Id    IN Number);


--The function gets the AR invoice number of a Project's Draft invoice.
FUNCTION GET_RAINVOICE_NUM
    (
      P_PROJECT_ID        IN NUMBER ,
      P_DRAFT_INVOICE_NUM IN NUMBER )  RETURN VARCHAR2;


--The function gets the Invoice Date of a Project's Draft invoice.
FUNCTION GET_LAST_INVOICE_DATE
    (
      P_PROJECT_ID        IN NUMBER ,
      P_DRAFT_INVOICE_NUM IN NUMBER )
    RETURN DATE;

END PA_PWP_SUMM_PKG;


/

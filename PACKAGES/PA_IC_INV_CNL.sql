--------------------------------------------------------
--  DDL for Package PA_IC_INV_CNL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IC_INV_CNL" AUTHID CURRENT_USER as
/* $Header: PAICCNLS.pls 115.1 2002/01/10 12:07:36 pkm ship      $ */
--
-- This procedure will delete the unreleased and error draft invoices
-- for a project
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
-- P_DRAFT_INV_NUM     NUMBER      Yes      Identifier of the Invoice
PROCEDURE cancel_invoice
	   (P_PROJECT_ID   IN  NUMBER,
            P_DRAFT_INV_NUM IN NUMBER);

end PA_IC_INV_CNL;

 

/

--------------------------------------------------------
--  DDL for Package PA_IC_INV_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IC_INV_DEL" AUTHID CURRENT_USER as
/* $Header: PAICDELS.pls 120.0.12010000.5 2008/10/22 11:08:27 dlella noship $ */
--
-- This procedure will delete the unreleased and error draft invoices
-- for a project
-- Input parameters
-- Parameter           Type       Required Description
-- P_PROJECT_ID        NUMBER      Yes      Identifier of the Project
--
PROCEDURE delete_invoices
	   	   (P_PROJECT_ID   IN  NUMBER,
	    p_mass_delete  IN varchar2  DEFAULT 'N',
	    p_unapproved_inv_only IN varchar2 DEFAULT 'N'); /*For Bug 7013590*//*p_unapproved_inv_only for bug 7172117 */


 /*For Bug 7026205*/
 PROCEDURE insert_dist_warnings
           (P_PROJECT_ID IN NUMBER,
	    P_DRAFT_INVOICE_NUM IN NUMBER);


end PA_IC_INV_DEL;

/

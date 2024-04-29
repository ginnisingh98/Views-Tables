--------------------------------------------------------
--  DDL for Package PA_MC_INVOICE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_INVOICE_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: PAMCIDTS.pls 115.1 99/10/28 14:12:51 porting ship    $ */

-- Global Set of Reporting Books
--
G_Reporting_SOB     PA_PLSQL_DATATYPES.IdTabTyp;
G_Reporting_Curr    PA_PLSQL_DATATYPES.Char15TabTyp;
G_No_of_SOB         NUMBER;
--
-- Functional Currency;
--
G_FUNC_CURR         VARCHAR2(16);
--
-- Functional Set of Books Id
--
G_SOB               NUMBER;
--
--
-- Current Org Id
--
G_ORG_ID            NUMBER;
--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_MC_DRAFT_INV_DETAILS in
--                        array processing.
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records

PROCEDURE insert_rows
           ( P_inv_rec_tab             IN   PA_INVOICE_DETAIL_PKG.inv_rec_tab);

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_MC_DRAFT_INV_DETAILS in
--                        array processing. This overloaded function
--                        is called from MRC upgrade.
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records
--                        P_trx_date    - Table of Transaction Date

PROCEDURE insert_rows
           ( P_inv_rec_tab             IN   PA_INVOICE_DETAIL_PKG.inv_rec_tab,
             P_trx_date                IN   PA_PLSQL_DATATYPES.DateTabTyp);

-- Procedure            : Delete_rows
-- Purpose              : Delete Rows from PA_MC_DRAFT_INV_DETAILS in
--                        array .
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records

PROCEDURE Delete_rows
           ( P_inv_rec_tab             IN   PA_INVOICE_DETAIL_PKG.inv_rec_tab);

-- Procedure            : Update_rows
-- Purpose              : Update Rows from PA_MC_DRAFT_INV_DETAILS in
--                        array .
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records

PROCEDURE Update_rows
           ( P_inv_rec_tab         IN PA_INVOICE_DETAIL_PKG.inv_rec_tab,
             P_mrc_reqd_flag       IN PA_PLSQL_DATATYPES.Char1TabTyp);

END PA_MC_INVOICE_DETAIL_PKG;

 

/

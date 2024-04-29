--------------------------------------------------------
--  DDL for Package PA_INVOICE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: PAICIDTS.pls 115.3 2002/11/23 12:26:16 prajaram ship $*/

TYPE INV_REC_TAB IS TABLE OF pa_draft_invoice_details%rowtype
                    INDEX BY BINARY_INTEGER;

/* Global Variable */
G_REQUEST_ID           NUMBER;
G_LAST_UPDATE_DATE     DATE;
G_LAST_UPDATED_BY      NUMBER;
G_CREATION_DATE        DATE;
G_CREATED_BY           NUMBER;
G_LAST_UPDATE_LOGIN    NUMBER;

--Global Counter
G_Ins_count     Number;
G_Del_count     Number;
G_Upd_count     Number;


-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_DRAFT_INVOICE_DETAILS in
--                        array processing.
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records

PROCEDURE insert_rows
           ( P_inv_rec_tab                IN OUT NOCOPY  inv_rec_tab);

-- Procedure            : Delete_rows
-- Purpose              : Delete Rows from PA_DRAFT_INVOICE_DETAILS in
--                        array .
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records

PROCEDURE Delete_rows
           ( P_inv_rec_tab      IN OUT NOCOPY  inv_rec_tab);

-- Procedure            : Update_rows
-- Purpose              : Update Rows from PA_DRAFT_INVOICE_DETAILS in
--                        array .
-- Parameters           :
--                        P_inv_rec_tab - Table of Invoice details Records

PROCEDURE Update_rows
           ( P_inv_rec_tab      IN OUT NOCOPY  inv_rec_tab,
             p_mrc_reqd_flag        IN   PA_PLSQL_DATATYPES.Char1tabtyp);

END PA_INVOICE_DETAIL_PKG;

 

/

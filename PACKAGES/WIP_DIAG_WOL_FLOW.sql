--------------------------------------------------------
--  DDL for Package WIP_DIAG_WOL_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DIAG_WOL_FLOW" AUTHID CURRENT_USER AS
/* $Header: WIPDWOLS.pls 120.0.12000000.1 2007/07/10 11:07:28 mraman noship $ */

PROCEDURE Uncosted_mat_txn_wol(inputs IN JTF_DIAG_INPUTTBL,
                               report OUT NOCOPY JTF_DIAG_REPORT,
                               reportClob OUT NOCOPY CLOB);
PROCEDURE Pending_res_txn_wol(inputs IN JTF_DIAG_INPUTTBL,
                              report OUT NOCOPY JTF_DIAG_REPORT,
                              reportClob OUT NOCOPY CLOB);
PROCEDURE Invalid_txn_mti_wol(inputs IN JTF_DIAG_INPUTTBL,
                              report OUT NOCOPY JTF_DIAG_REPORT,
                              reportClob OUT NOCOPY CLOB);
PROCEDURE Dup_mat_txn_mti(inputs IN JTF_DIAG_INPUTTBL,
                          report OUT NOCOPY JTF_DIAG_REPORT,
                          reportClob OUT NOCOPY CLOB);
END;

 

/

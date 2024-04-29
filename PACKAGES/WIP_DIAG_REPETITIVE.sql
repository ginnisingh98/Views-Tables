--------------------------------------------------------
--  DDL for Package WIP_DIAG_REPETITIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DIAG_REPETITIVE" AUTHID CURRENT_USER AS
/* $Header: WIPDREPS.pls 120.0.12000000.1 2007/07/10 10:32:29 mraman noship $ */

PROCEDURE Uncosted_mat_txn_rep(inputs IN JTF_DIAG_INPUTTBL,
                               report OUT NOCOPY JTF_DIAG_REPORT,
                               reportClob OUT NOCOPY CLOB);
END;

 

/

--------------------------------------------------------
--  DDL for Package WIP_DIAG_DISCRETE_LOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DIAG_DISCRETE_LOT" AUTHID CURRENT_USER AS
/* $Header: WIPDJOBS.pls 120.0.12000000.1 2007/07/10 10:07:00 mraman noship $ */


sqltxt  varchar2(15000);
where_clause varchar2(100) ;
dummy_num       number;
reportStr   LONG;           -- REPORT
statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
errStr      VARCHAR2(4000); -- error message
fixInfo     VARCHAR2(4000); -- fix tip
isFatal     VARCHAR2(50);   -- TRUE or FALSE
apps_ver    VARCHAR2(20);



PROCEDURE Uncosted_mat_txn_wdj ( p_org_id IN  NUMBER,
                               report OUT NOCOPY JTF_DIAG_REPORT,
                               reportClob OUT NOCOPY CLOB
                               ) ;
PROCEDURE corrupt_osp_txn_wdj (p_org_id IN NUMBER,
                               report OUT NOCOPY JTF_DIAG_REPORT,
                               reportClob OUT NOCOPY CLOB
                               ) ;
PROCEDURE dup_mat_txn_wdj      (p_org_id IN NUMBER ,
                               report OUT NOCOPY JTF_DIAG_REPORT,
                               reportClob OUT NOCOPY CLOB
                               ) ;

END;

 

/

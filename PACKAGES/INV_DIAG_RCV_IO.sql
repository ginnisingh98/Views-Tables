--------------------------------------------------------
--  DDL for Package INV_DIAG_RCV_IO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_RCV_IO" AUTHID CURRENT_USER AS
/* $Header: INVDR03S.pls 120.0.12000000.1 2007/08/09 06:51:11 ssadasiv noship $ */

  test_out  VARCHAR2(200);

   PROCEDURE init;
   PROCEDURE cleanup;
   PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                     report OUT NOCOPY JTF_DIAG_REPORT,
                     reportClob OUT NOCOPY CLOB);
   PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2);
   PROCEDURE getTestName(str OUT NOCOPY VARCHAR2);
   PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);
   PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
   FUNCTION  getTestMode return NUMBER;
END inv_diag_rcv_io;

 

/

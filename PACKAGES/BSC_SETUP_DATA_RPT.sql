--------------------------------------------------------
--  DDL for Package BSC_SETUP_DATA_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SETUP_DATA_RPT" AUTHID CURRENT_USER AS
/* $Header: BSCSTPAS.pls 120.1.12000000.1 2007/08/09 09:54:32 appldev noship $ */
g_patch_level_sql CONSTANT VARCHAR2(200):= 'SELECT patch_level FROM fnd_product_installations WHERE patch_level LIKE ''%BSC%'''||
                                          ' OR  patch_level LIKE ''%BIS%''';
PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
report OUT NOCOPY JTF_DIAG_REPORT,
reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
FUNCTION getTestMode RETURN INTEGER;
END;

 

/

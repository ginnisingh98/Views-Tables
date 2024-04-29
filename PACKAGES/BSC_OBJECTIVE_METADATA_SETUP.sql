--------------------------------------------------------
--  DDL for Package BSC_OBJECTIVE_METADATA_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_OBJECTIVE_METADATA_SETUP" AUTHID CURRENT_USER AS
/* $Header: BSCOBMDS.pls 120.1.12000000.2 2007/08/09 12:34:49 akoduri noship $ */
/*=======================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |                      BSCOBMDS.pls                                     |
 |                                                                       |
 | Creation Date:                                                        |
 |                      August 07, 2007                                  |
 |                                                                       |
 | Creator:                                                              |
 |                      Ajitha Koduri                                    |
 |                                                                       |
 | Description:                                                          |
 |          Public version.                                              |
 |          This package contains all the APIs related to diagnostics  of|
 |          objective report                                             |
 |                                                                       |
 | History:                                                              |
 |          07-AUG-2007 akoduri Bug 6083208 Diagnostics for Objectives   |
 *=======================================================================*/


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

FUNCTION get_message_name(message_name VARCHAR2) RETURN VARCHAR2;

END BSC_OBJECTIVE_METADATA_SETUP;

 

/

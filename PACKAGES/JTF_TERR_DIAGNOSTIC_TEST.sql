--------------------------------------------------------
--  DDL for Package JTF_TERR_DIAGNOSTIC_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_DIAGNOSTIC_TEST" AUTHID CURRENT_USER AS
/* $Header: jtftrdts.pls 120.2 2005/07/02 01:32:16 appldev ship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavstgs.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is for general territory testing                     |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 26-Sept-2002   arpatel          Created.                              |
 +======================================================================*/
  PROCEDURE init;
  PROCEDURE cleanup;
  PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                    report OUT NOCOPY JTF_DIAG_REPORT,
                    reportClob OUT NOCOPY CLOB);
  PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
  PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
  PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);

END JTF_TERR_DIAGNOSTIC_TEST;


/

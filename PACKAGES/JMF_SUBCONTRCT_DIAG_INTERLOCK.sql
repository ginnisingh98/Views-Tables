--------------------------------------------------------
--  DDL for Package JMF_SUBCONTRCT_DIAG_INTERLOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SUBCONTRCT_DIAG_INTERLOCK" AUTHID CURRENT_USER AS
/* $Header: JMFDSUBS.pls 120.0.12010000.2 2010/06/28 06:27:21 abhissri ship $ */

--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFDSUBS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Subcontracting Diagnostics Test                    |
--|                        Package Specification                              |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    20-DEC-2007          kdevadas  Created.                                |
--+===========================================================================+


PROCEDURE init;

PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);

PROCEDURE cleanup;

PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);


END JMF_SUBCONTRCT_DIAG_INTERLOCK;


/

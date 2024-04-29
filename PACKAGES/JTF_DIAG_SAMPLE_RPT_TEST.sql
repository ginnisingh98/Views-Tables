--------------------------------------------------------
--  DDL for Package JTF_DIAG_SAMPLE_RPT_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAG_SAMPLE_RPT_TEST" AUTHID CURRENT_USER AS
/* $Header: JTF_DIAG_SAMPLE_RPT_TEST_S.pls 120.0 2007/10/30 11:29:14 sramados noship $*/
    PROCEDURE runtest(EXEC_OBJ IN out JTF_DIAG_EXECUTION_OBJ, result out nocopy varchar2);
    PROCEDURE getTestName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);
    PROCEDURE getError(str OUT NOCOPY VARCHAR2);
    PROCEDURE getFixInfo(str OUT NOCOPY VARCHAR2);
    PROCEDURE isWarning(str OUT NOCOPY VARCHAR2);
    PROCEDURE isFatal(str OUT NOCOPY VARCHAR2);
END;

/

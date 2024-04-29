--------------------------------------------------------
--  DDL for Package PJI_AUDIT_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_AUDIT_RPT" AUTHID CURRENT_USER AS
  /* $Header: PJIUT05S.pls 115.5 2003/12/12 22:31:13 svermett noship $ */

TYPE   V_TYPE_TAB    IS   TABLE OF VARCHAR2(240);

PROCEDURE CHK_BIS_SET_UP;

PROCEDURE CHK_PJI_SET_UP;

PROCEDURE CHK_ORG_TIME_CAL_DIM;

PROCEDURE CHK_PJI_ORG_HRCHY;

PROCEDURE CHK_SECURITY_SET_UP
(
	p_username	IN VARCHAR2
);

PROCEDURE REPORT_PJI_PARAM_SETUP
(
	errbuff        OUT NOCOPY VARCHAR2,
        retcode        OUT NOCOPY VARCHAR2
);

PROCEDURE REPORT_PJI_SECURITY_SETUP
(
	p_user_name    IN         VARCHAR2,
	errbuff        OUT NOCOPY VARCHAR2,
        retcode        OUT NOCOPY VARCHAR2
);

END PJI_AUDIT_RPT;

 

/

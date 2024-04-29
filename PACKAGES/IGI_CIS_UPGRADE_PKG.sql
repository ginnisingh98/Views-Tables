--------------------------------------------------------
--  DDL for Package IGI_CIS_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_UPGRADE_PKG" AUTHID CURRENT_USER AS
-- $Header: igipupgs.pls 120.0.12000000.1 2007/07/10 13:01:40 vensubra noship $

	Procedure MIGRATE_DATA(p_errbuff OUT NOCOPY VARCHAR2,p_retcode OUT NOCOPY NUMBER);
	Function IGI_CIS_VALIDATE_NI_NUMBER(P_NINO IN VARCHAR2) return Boolean;
	Function IGI_CIS_VALIDATE_UTR (P_UTR IN VARCHAR2) return Boolean;
	PROCEDURE WRITE_REPORT(P_MSG_NAME IN VARCHAR2);

END IGI_CIS_UPGRADE_PKG;


 

/

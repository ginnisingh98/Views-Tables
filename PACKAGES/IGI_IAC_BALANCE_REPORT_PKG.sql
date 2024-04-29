--------------------------------------------------------
--  DDL for Package IGI_IAC_BALANCE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_BALANCE_REPORT_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiabrs.pls 120.5 2007/08/01 10:46:39 npandya ship $
--
/*==========================================================================*/
Function IGI_IAC_CHECK_ACCOUNTS ( p_sql VARCHAR2 , p_accval OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


--END IGI_IAC_CHECK_ACCOUNTS;
END;

/

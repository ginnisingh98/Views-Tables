--------------------------------------------------------
--  DDL for Package IGC_CC_REVALUE_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_REVALUE_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCREPS.pls 120.4.12000000.4 2007/10/18 12:16:37 bmaddine ship $ */

PROCEDURE revalue_main( ERRBUF          OUT NOCOPY VARCHAR2,
			RETCODE         OUT NOCOPY VARCHAR2,
			p_process_phase IN VARCHAR2,
			p_currency_code IN VARCHAR2,
			p_rate_type     IN VARCHAR2,
			p_rate_date     IN VARCHAR2,
			p_rate          IN VARCHAR2,
			p_cc_header_id  IN NUMBER);
END IGC_CC_REVALUE_PROCESS_PKG;

 

/

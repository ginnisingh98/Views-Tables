--------------------------------------------------------
--  DDL for Package IGC_CC_REVAL_FIX_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_REVAL_FIX_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCREFS.pls 120.3.12000000.6 2007/10/18 12:14:16 bmaddine ship $ */

PROCEDURE revalue_fix_main( ERRBUF               OUT NOCOPY VARCHAR2,
			    RETCODE              OUT NOCOPY VARCHAR2,
/*Bug No : 6341012. MOAC Uptake. SOB_ID,ORG_ID are retrieved from Packages rather than from Profile values*/
	--		    p_sob_id             IN  NUMBER,
	--		    p_org_id             IN  NUMBER,
			    p_cc_header_id       IN  NUMBER,
                            p_revalue_fix_date   IN  VARCHAR2);

FUNCTION revalue_fix( p_cc_header_id       IN NUMBER) RETURN BOOLEAN;
END IGC_CC_REVAL_FIX_PROCESS_PKG;

 

/

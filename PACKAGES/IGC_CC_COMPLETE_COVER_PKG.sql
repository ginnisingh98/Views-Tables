--------------------------------------------------------
--  DDL for Package IGC_CC_COMPLETE_COVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_COMPLETE_COVER_PKG" AUTHID CURRENT_USER AS
-- $Header: IGCCCOVS.pls 120.3.12000000.5 2007/10/12 11:12:02 bmaddine ship $
   Procedure complete_cover (  errbuf               OUT NOCOPY VARCHAR2
                             , retcode 	            OUT NOCOPY NUMBER
                             , p_cc_header_id       IN  IGC_CC_HEADERS.CC_HEADER_ID%TYPE
	/*Bug No : 6341012. MOAC uptake SOB_ID,ORG_ID are retrieved from Packages rather than from Profile values */
	--                  , p_set_of_books_id    IN  IGC_CC_HEADERS.SET_OF_BOOKS_ID%TYPE
        --                  , p_org_id             IN  IGC_CC_HEADERS.ORG_ID%TYPE
                             , p_comp_unmatched_rel IN  VARCHAR2
                             , p_comp_cover         IN  VARCHAR2  );
END IGC_CC_COMPLETE_COVER_PKG;

 

/

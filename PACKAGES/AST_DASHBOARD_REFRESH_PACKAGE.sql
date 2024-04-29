--------------------------------------------------------
--  DDL for Package AST_DASHBOARD_REFRESH_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_DASHBOARD_REFRESH_PACKAGE" AUTHID CURRENT_USER AS
/* $Header: astdbrss.pls 120.0.12010000.2 2009/09/17 11:34:51 sariff ship $ */
-- Start of Comments
-- Package name     : ast_dashboard_refresh_package
-- Purpose          : Wrapper package to call the CSC package/procedure to refresh dashboard data to avoid install errors if their package is changed/becomes invalid.
-- History          :
-- NOTE             : Temporary workaround till the CSC package is made public(enh bug#2599015)
-- End of Comments
-- p_psite_id added for bug 8869234

procedure run_refresh_engine (
		      p_errbuf	  OUT NOCOPY VARCHAR2,
    		      p_retcode  OUT NOCOPY NUMBER,
		      p_party_id IN  NUMBER,
   		      p_acct_id  IN  NUMBER,
		      p_psite_id IN  NUMBER DEFAULT NULL,
		      p_group_id IN  NUMBER );
END ast_dashboard_refresh_package;

/

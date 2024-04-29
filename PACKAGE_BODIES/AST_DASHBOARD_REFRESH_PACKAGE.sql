--------------------------------------------------------
--  DDL for Package Body AST_DASHBOARD_REFRESH_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_DASHBOARD_REFRESH_PACKAGE" AS
/* $Header: astdbrsb.pls 120.0.12010000.2 2009/09/17 11:35:32 sariff ship $ */
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
		      p_group_id IN  NUMBER ) is

plsql_block VARCHAR2(1000);

begin

plsql_block := 'BEGIN CSC_PROFILE_ENGINE_PKG.RUN_ENGINE(:p_errbuf,:p_retcode,:p_party_id,:p_acct_id,:p_psite_id,:p_group_id);END;';

EXECUTE IMMEDIATE plsql_block USING OUT p_errbuf, OUT p_retcode, IN p_party_id, IN p_acct_id, IN p_psite_id, IN p_group_id;

exception
	when others then
		if (nvl(p_retcode,-1) <> 2) then
			p_retcode := 2;
		end if;
		if (p_errbuf IS NULL) then
			--p_errbuf := sqlcode || ' ' || sqlerrm;
			p_errbuf := sqlerrm;
			fnd_file.put_line(fnd_file.log , 'ast_dashboard_refresh_package Reported Error In Call To CSC_PROFILE_ENGINE_PKG.RUN_ENGINE: '||p_errbuf);
		end if;

end run_refresh_engine;

END ast_dashboard_refresh_package;

/

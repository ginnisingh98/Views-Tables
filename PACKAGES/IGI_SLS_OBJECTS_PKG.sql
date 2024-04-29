--------------------------------------------------------
--  DDL for Package IGI_SLS_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_OBJECTS_PKG" AUTHID CURRENT_USER AS
-- $Header: igislsos.pls 120.6.12010000.2 2008/08/04 13:08:14 sasukuma ship $

PROCEDURE write_to_log(p_level IN NUMBER,p_path IN VARCHAR2, p_mesg IN VARCHAR2);

PROCEDURE create_sls_tab(sls_tab 	IN VARCHAR2,
                        schema_name     IN VARCHAR2,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER);

PROCEDURE create_sls_inx(sls_tab 	IN VARCHAR2,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER);

PROCEDURE create_sls_apps_syn(sls_tab 		IN VARCHAR2,
                              schema_name       IN VARCHAR2,
			      errbuf 		OUT NOCOPY VARCHAR2,
			      retcode 		OUT NOCOPY NUMBER);

PROCEDURE create_sls_mls_syn(sls_tab 		IN VARCHAR2,
			     mls_schemaname 	IN VARCHAR2,
			     errbuf 		OUT NOCOPY VARCHAR2,
			     retcode 		OUT NOCOPY NUMBER);

PROCEDURE create_sls_mrc_syn(sls_tab 		IN VARCHAR2,
			     mrc_schemaname 	IN VARCHAR2,
			     errbuf 		OUT NOCOPY VARCHAR2,
			     retcode 		OUT NOCOPY NUMBER);


PROCEDURE drop_sls_tab	(sls_tab 	IN VARCHAR2,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY  NUMBER);

PROCEDURE drop_sls_apps_syn(sls_tab 		IN VARCHAR2,
                              schema_name       IN VARCHAR2,
			      errbuf 		OUT NOCOPY VARCHAR2,
			      retcode 		OUT NOCOPY NUMBER);

PROCEDURE drop_sls_mls_syn(sls_tab 		IN VARCHAR2,
			     mls_schemaname 	IN VARCHAR2,
			     errbuf 		OUT NOCOPY VARCHAR2,
			     retcode 		OUT NOCOPY NUMBER);

PROCEDURE drop_sls_mrc_syn(sls_tab 		IN VARCHAR2,
			     mrc_schemaname 	IN VARCHAR2,
			     errbuf 		OUT NOCOPY VARCHAR2,
			     retcode 		OUT NOCOPY NUMBER);

PROCEDURE create_sls_trg(sls_tab 	IN VARCHAR2,
			sec_tab 	IN VARCHAR2,
			errbuf		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY  NUMBER);

PROCEDURE drop_sls_trg	(sls_tab 	IN VARCHAR2,
			 errbuf 	OUT NOCOPY VARCHAR2,
			 retcode 	OUT NOCOPY  NUMBER);


PROCEDURE cre_pol_function(sec_tab 	IN VARCHAR2,
			   sls_tab 	IN VARCHAR2,
			   errbuf    	OUT NOCOPY VARCHAR2,
			   retcode  	OUT NOCOPY NUMBER);


PROCEDURE drop_pol_function(sls_tab 	IN VARCHAR2,
			    errbuf     	OUT NOCOPY VARCHAR2,
			    retcode   	OUT NOCOPY NUMBER);

PROCEDURE sls_add_pol(object_schema 	IN VARCHAR2,
		     table_name    	IN VARCHAR2,
		     policy_name   	IN VARCHAR2,
		     function_owner	IN VARCHAR2,
		     policy_function    IN VARCHAR2,
		     statement_types 	IN VARCHAR2,
		     errbuf 		OUT NOCOPY VARCHAR2,
		     retcode 		OUT NOCOPY NUMBER);

PROCEDURE sls_drop_pol(object_schema 	IN VARCHAR2,
			table_name    	IN VARCHAR2,
			policy_name   	IN VARCHAR2,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER);

PROCEDURE sls_refresh_pol(object_schema IN VARCHAR2,
			 table_name    	IN VARCHAR2,
			 policy_name   	IN VARCHAR2,
			 errbuf 	OUT NOCOPY VARCHAR2,
			 retcode 	OUT NOCOPY NUMBER);

PROCEDURE sls_enable_pol(object_schema 	IN VARCHAR2,
			table_name    	IN VARCHAR2,
			policy_name   	IN VARCHAR2,
			enable		IN BOOLEAN,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER);


PROCEDURE sls_disable_pol(object_schema IN VARCHAR2,
			  table_name    IN VARCHAR2,
			  policy_name   IN VARCHAR2,
			  enable	IN BOOLEAN,
			  errbuf 	OUT NOCOPY VARCHAR2,
			  retcode 	OUT NOCOPY NUMBER);

PROCEDURE create_sls_col (sec_tab       IN  VARCHAR,
                          schema_name   IN  VARCHAR2,
			  errbuf 	OUT NOCOPY VARCHAR2,
			  retcode 	OUT NOCOPY NUMBER);

PROCEDURE create_sls_core_inx
                       (sec_tab 	IN  VARCHAR2,
                        sls_tab         IN  VARCHAR2,
                        schema_name     IN  VARCHAR2,
			errbuf 		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY NUMBER);

PROCEDURE drop_sls_col (sec_tab         IN  VARCHAR,
                        schema_name     IN  VARCHAR2,
	                errbuf 	        OUT NOCOPY VARCHAR2,
		        retcode 	OUT NOCOPY NUMBER);

PROCEDURE create_sls_col_trg
                        (sls_tab 	IN VARCHAR2,
			sec_tab 	IN VARCHAR2,
			errbuf		OUT NOCOPY VARCHAR2,
			retcode 	OUT NOCOPY  NUMBER);


PROCEDURE cre_ext_col_pol_func(sec_tab 	IN VARCHAR2,
			   sls_tab 	IN VARCHAR2,
			   errbuf    	OUT NOCOPY VARCHAR2,
			   retcode  	OUT NOCOPY NUMBER);

END igi_sls_objects_pkg ;

/

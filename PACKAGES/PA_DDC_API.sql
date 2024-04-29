--------------------------------------------------------
--  DDL for Package PA_DDC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DDC_API" AUTHID CURRENT_USER AS
/* $Header: PAXDDC0S.pls 120.1 2005/08/19 17:13:21 mwasowic noship $ */



FUNCTION check_alias (x_alias IN VARCHAR2
			, x_folder_code IN VARCHAR2) RETURN VARCHAR2;
pragma RESTRICT_REFERENCES  (check_alias, WNDS, WNPS );

PROCEDURE create_psi_generic_views
		(x_view_name	IN VARCHAR2
		 , x_err_stage	IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
		 , x_err_code	IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895



END PA_DDC_API;

 

/

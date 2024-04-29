--------------------------------------------------------
--  DDL for Package PA_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_LOOKUPS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXSLKPS.pls 115.0 99/07/16 15:32:35 porting ship $   */
------------------------------------------------------------------------------
PROCEDURE check_unique (x_return_status 	IN OUT NUMBER
			, x_lookup_type		IN     VARCHAR2
			, x_lookup_code		IN     VARCHAR2
			, x_meaning		IN     VARCHAR2);

PROCEDURE check_references (x_return_status	IN OUT NUMBER
				, x_stage	IN OUT NUMBER
				, x_lookup_code	IN 	VARCHAR2);

--===========================================================================
END pa_lookups_pkg;

 

/

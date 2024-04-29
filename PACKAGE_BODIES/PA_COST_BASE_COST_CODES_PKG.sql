--------------------------------------------------------
--  DDL for Package Body PA_COST_BASE_COST_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_BASE_COST_CODES_PKG" as
-- $Header: PAXCICIB.pls 120.1 2005/08/23 19:19:43 spunathi noship $

-- constant
NO_DATA_FOUND_ERR constant number := 100;

------------------------------------------------------------------------------
procedure check_unique(cp_structure  IN     varchar2,
		       c_base        IN     varchar2,
		       c_base_type   IN     varchar2,
		       icc 	     IN     varchar2,
		       status 	     IN OUT NOCOPY number)
is
dummy number;
begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_base_cost_codes
       WHERE      cost_base = c_base
              AND cost_base_type = c_base_type
	      AND cost_plus_structure = cp_structure
	      AND ind_cost_code = icc);

exception

   when NO_DATA_FOUND then
	status := NO_DATA_FOUND_ERR;

   when OTHERS then
	status := SQLCODE;

end check_unique;


end PA_COST_BASE_COST_CODES_PKG ;

/

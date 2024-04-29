--------------------------------------------------------
--  DDL for Package Body PA_COST_BASE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_BASE_VIEW_PKG" as
-- $Header: PAXCICVB.pls 120.1 2005/08/23 19:19:53 spunathi noship $

-- constant
NO_DATA_FOUND_ERR constant number := 100;

------------------------------------------------------------------------------
procedure check_unique(cp_structure IN     varchar2,
		       c_base       IN     varchar2,
		       c_base_type  IN     varchar2,
		       status 	    IN OUT NOCOPY number)
is
dummy number;
begin

   status := 0;

   /*
    * Performance related changes:
    * the view pa_cost_base_v does not get merged.
    * The query looks into the base tables instead of the view.
    */
   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_base_cost_codes cbv
       WHERE      cbv.cost_base = c_base
              AND cbv.cost_base_type = c_base_type
	      AND cbv.cost_plus_structure = cp_structure)
       AND NOT EXISTS
      (SELECT 1 FROM pa_cost_base_exp_types cbv
       WHERE      cbv.cost_base = c_base
              AND cbv.cost_base_type = c_base_type
	      AND cbv.cost_plus_structure = cp_structure);

exception

   when NO_DATA_FOUND then
	status := NO_DATA_FOUND_ERR;

   when OTHERS then
	status := SQLCODE;

end check_unique;

------------------------------------------------------------------------------
procedure check_rev_compiled(cp_structure IN     varchar2,
		             status       IN OUT NOCOPY number)
is
dummy number;
begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1
       FROM   pa_ind_rate_sch_revisions
       WHERE  cost_plus_structure = cp_structure
       AND    compiled_date IS NOT NULL);

exception

   when NO_DATA_FOUND then
	status := NO_DATA_FOUND_ERR;

   when OTHERS then
	status := SQLCODE;

end check_rev_compiled;


------------------------------------------------------------------------------
procedure check_references(cp_structure IN     varchar2,
			   c_base       IN     varchar2,
		           c_base_type  IN     varchar2,
			   status       IN OUT NOCOPY number)
is

-- local variables
dummy	     number;

begin

   status := 0;

   -- check pa_cost_base_cost_codes table
   -- check pa_cost_base_exp_types table
   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_base_cost_codes cbicc,
		     pa_cost_base_exp_types cbet
       WHERE    (    (cbicc.cost_plus_structure = cp_structure)
	          and (cbicc.cost_base = c_base)
	          and (cbicc.cost_base_type = c_base_type))
	     or (    (cbet.cost_plus_structure = cp_structure)
	          and (cbet.cost_base = c_base)
	          and (cbet.cost_base_type = c_base_type)));

exception

   when NO_DATA_FOUND then
      -- there are at least one foreign key in details table
        status := NO_DATA_FOUND_ERR;

   when OTHERS then
	status := SQLCODE;

end check_references;

------------------------------------------------------------------------------
procedure cascade_delete(cp_structure IN     varchar2,
		         c_base       IN     varchar2,
		         c_base_type  IN     varchar2,
			 status       IN OUT NOCOPY number)
is
begin
    DELETE pa_cost_base_cost_codes
    WHERE  cost_plus_structure = cp_structure
    AND	   cost_base = c_base
    AND    cost_base_type = c_base_type;

    DELETE pa_cost_base_exp_types
    WHERE  cost_plus_structure = cp_structure
    AND	   cost_base = c_base
    AND    cost_base_type = c_base_type;

    COMMIT;

exception

   when OTHERS then
        status := SQLCODE;

end cascade_delete;


end PA_COST_BASE_VIEW_PKG ;

/

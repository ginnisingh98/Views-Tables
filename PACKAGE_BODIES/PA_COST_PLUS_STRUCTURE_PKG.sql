--------------------------------------------------------
--  DDL for Package Body PA_COST_PLUS_STRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_PLUS_STRUCTURE_PKG" as
-- $Header: PAXCISTB.pls 120.1 2005/08/23 19:20:17 spunathi noship $

-- constants
NO_DATA_FOUND_ERR  CONSTANT number  := 100;

procedure check_unique(cp_structure IN     varchar2,
		       status	    IN OUT NOCOPY number) is
-- local variable
dummy number;
begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_plus_structures
       WHERE     cost_plus_structure = cp_structure);

exception
  when OTHERS then
       status := SQLCODE;

end check_unique;


procedure check_references(cp_structure IN     varchar2,
			   status 	IN OUT NOCOPY number) is

-- local variables
dummy	     number;

begin

   status := 0;

   -- check pa_cost_base_cost_codes table
   -- check pa_cost_base_exp_types table

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_base_cost_codes cbicc,
      		     pa_cost_base_exp_types cbet
       WHERE    cbicc.cost_plus_structure = cp_structure
             OR cbet.cost_plus_structure = cp_structure);

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_references;


procedure check_revision(cp_structure IN     varchar2,
			 status       IN OUT NOCOPY number) is

-- local variables
dummy	     number;

begin

   status := 0;

   -- check pa_ind_rate_sch_revisions table

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_ind_rate_sch_revisions irsr
       WHERE    irsr.cost_plus_structure = cp_structure);

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_revision;


procedure check_schedule(cp_structure IN varchar2,
			 status IN OUT NOCOPY number) is

-- local variables
dummy        number;

begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1
       FROM   pa_ind_rate_schedules
       WHERE  cost_plus_structure = cp_structure);

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_schedule;


procedure check_bcc(cp_structure IN varchar2,
			 status IN OUT NOCOPY number) is

-- local variables
dummy        number;

begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1
       FROM   pa_cost_base_cost_codes
       WHERE  cost_plus_structure = cp_structure);

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_bcc;


procedure check_default(status IN OUT NOCOPY number) is

-- local variables
dummy	     number;

begin

   status := 0;

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1
       FROM   pa_cost_plus_structures
       WHERE  default_for_override_sch_flag = 'Y');

exception

   when OTHERS then
      -- there are at least one foreign key in details table
      status := SQLCODE;

end check_default;



/*
procedure check_default(start_date  IN     date,
			end_date    IN     date,
			status      IN OUT number) is

-- local variables
dummy        number;

begin

   status := 0;

   -- check pa_cost_plus_structures table
   -- there are six cases
   --                 A
   --        |--------------------|
   --    B      C      D      E      F
   --  |----| |----| |----| |----| |----|
   --		    Default
   --           |--------------|
   -- Cases A, C, D, and E violate that only one default structure can exist
   -- any point of time.
   -- Case B and F are acceptable.

   SELECT 1 INTO dummy FROM sys.dual WHERE NOT EXISTS
      (SELECT 1 FROM pa_cost_plus_structures cps
       WHERE    cps.default_for_override_sch_flag = 'Y'
       AND      (  -- case A
		    (    (TRUNC(cps.start_date_active)
				BETWEEN
				TRUNC(start_date) AND
			        TRUNC(NVL(end_date, cps.start_date_active)))
		     and (   end_date IS NULL
			  or (TRUNC(NVL(cps.end_date_active, end_date))
				BETWEEN
				TRUNC(start_date) AND
			        TRUNC(end_date)))
	            )
		   -- case C
		 or (    (TRUNC(cps.start_date_active)
				BETWEEN
				TRUNC(start_date) AND
			        TRUNC(NVL(end_date, cps.start_date_active)))
		     and (TRUNC(end_date)
				BETWEEN
				TRUNC(cps.start_date_active) AND
			        TRUNC(NVL(cps.end_date_active, end_date)))
	            )
		   -- case D
		 or (    (TRUNC(start_date)
				BETWEEN
				TRUNC(cps.start_date_active) AND
			        TRUNC(NVL(cps.end_date_active, end_date)))
		     and (TRUNC(end_date)
				BETWEEN
				TRUNC(cps.start_date_active) AND
			        TRUNC(NVL(cps.end_date_active, end_date)))
	            )
		   -- case E
		 or (    (TRUNC(start_date)
				BETWEEN
				TRUNC(cps.start_date_active) AND
			        TRUNC(NVL(cps.end_date_active, start_date)))
		     and (   cps.end_date_active IS NULL
			  or TRUNC(cps.end_date_active)
				BETWEEN
				TRUNC(start_date) AND
			        TRUNC(NVL(end_date, cps.end_date_active)))
	            )
		)
      );

exception

   when OTHERS then
      -- there is a default structure already
      status := SQLCODE;

end check_default;
*/


procedure clear_default(cp_structure IN     varchar2,
                        status       IN OUT NOCOPY number) is

begin

   status := 0;

   UPDATE pa_cost_plus_structures SET default_for_override_sch_flag = 'N'
      WHERE cost_plus_structure = cp_structure;

   COMMIT;

exception

   when OTHERS then
      -- there is a default structure already
      status := SQLCODE;

end clear_default;

procedure update_precedence(cp_structure IN     varchar2,
                            status       IN OUT NOCOPY number) is

begin

   status := 0;

   UPDATE pa_cost_base_cost_codes
   SET precedence = 1
   WHERE cost_plus_structure = cp_structure;

   COMMIT;

exception

   when OTHERS then
      -- there is a default structure already
      status := SQLCODE;

end update_precedence;

procedure cascade_delete(cp_structure IN     varchar2)
is
begin

    DELETE pa_cost_base_cost_codes
    WHERE  cost_plus_structure = cp_structure;

    DELETE pa_cost_base_exp_types
    WHERE  cost_plus_structure = cp_structure;

    COMMIT;

end cascade_delete;

procedure cascade_update(old_cp_structure IN  varchar2,
			 new_cp_structure IN  varchar2)

is
begin

    UPDATE pa_cost_base_cost_codes
    SET	   cost_plus_structure = new_cp_structure
    WHERE  cost_plus_structure = old_cp_structure;

    UPDATE pa_cost_base_exp_types
    SET	   cost_plus_structure = new_cp_structure
    WHERE  cost_plus_structure = old_cp_structure;

    COMMIT;

end cascade_update;




end PA_COST_PLUS_STRUCTURE_PKG ;

/

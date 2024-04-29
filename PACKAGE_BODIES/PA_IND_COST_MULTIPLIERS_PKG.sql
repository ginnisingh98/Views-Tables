--------------------------------------------------------
--  DDL for Package Body PA_IND_COST_MULTIPLIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IND_COST_MULTIPLIERS_PKG" as
-- $Header: PAXCMULB.pls 120.1.12010000.2 2009/05/08 07:27:45 sgottimu ship $
-----------------------------------------------------------------------------
procedure copy_multipliers (x_return_status     	IN OUT NOCOPY number,
			    x_stage			IN OUT NOCOPY number,
			    x_ind_rate_sch_rev_id_from 	IN number,
			    x_ind_rate_sch_rev_id_to   	IN number,
			    x_calling_module IN varchar2) -- added for bug 7391889
is
x_last_updated_by number;
x_created_by number;
x_last_update_login number;

begin
  x_return_status := 0;
  x_stage := 0;

-- start copying the multipliers from the FROM revision to the TO revision

  begin
    x_last_updated_by := FND_GLOBAL.USER_ID;
    x_created_by := FND_GLOBAL.USER_ID;
    x_last_update_login := FND_GLOBAL.LOGIN_ID;

    /* For Bug 3087964, inserting ready_to_compile_flag with value of 'Y' as default.
       otherwise the schedule will not get compiled.
       Inserting only those multipliers with ready_to_compile_flag <> 'X'.
       Also added the statement to delete multipliers with ready_to_compile_flag as 'X'
       prior to insertion. */

	delete from pa_ind_cost_multipliers
 	 where
	 ind_rate_sch_revision_id = x_ind_rate_sch_rev_id_to
	 and ready_to_compile_flag = 'X';

		 /* Changes for 7391889 start here */
	 IF x_calling_module = 'CAP_INT' THEN
	 insert into pa_ind_cost_multipliers (ind_rate_sch_revision_id,
       				         organization_id,
				         ind_cost_code,
				         multiplier,
				         last_update_date,
				         last_updated_by,
				         created_by,
				         creation_date,
				         last_update_login,
					 ready_to_compile_flag)
    select x_ind_rate_sch_rev_id_to,
	   m.organization_id,
	   m.ind_cost_code,
	   m.multiplier,
	   SYSDATE,
	   x_last_updated_by,
	   x_created_by,
	   SYSDATE,
	   x_last_update_login,
	   'Y'
    from   pa_ind_cost_multipliers m
    where  m.ind_rate_sch_revision_id = x_ind_rate_sch_rev_id_from
    and    nvl(m.ready_to_compile_flag, 'N') <> 'X';

	 ELSE  /* Changes for 7391889 end here */

    insert into pa_ind_cost_multipliers (ind_rate_sch_revision_id,
       				         organization_id,
				         ind_cost_code,
				         multiplier,
				         last_update_date,
				         last_updated_by,
				         created_by,
				         creation_date,
				         last_update_login,
					 ready_to_compile_flag)
    select x_ind_rate_sch_rev_id_to,
	   m.organization_id,
	   m.ind_cost_code,
	   m.multiplier,
	   SYSDATE,
	   x_last_updated_by,
	   x_created_by,
	   SYSDATE,
	   x_last_update_login,
	   'Y'
    from   pa_ind_cost_multipliers m
    where  m.ind_rate_sch_revision_id = x_ind_rate_sch_rev_id_from
    and    nvl(m.ready_to_compile_flag, 'N') <> 'X';

    END IF; /* Added for 7391889 */

    COMMIT;

    x_return_status := 0;

    EXCEPTION
      WHEN NO_DATA_FOUND then
      x_return_status := 1;
      x_stage := 1;
      return;

      WHEN OTHERS then
      x_return_status := SQLCODE;
  end;

end copy_multipliers;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
procedure check_references (x_return_status             IN OUT NOCOPY number,
                            x_stage                     IN OUT NOCOPY number,
                            x_ind_rate_sch_revision_id  IN     number)
is
x_dummy number;

begin
 x_return_status := 0;
 x_stage := 0;

  /* For Bug 3087964, added the condition ready_to_compile_flag <> 'X' in the exists clause */
  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_ind_cost_multipliers m
                     where  m.ind_rate_sch_revision_id  =
                                         x_ind_rate_sch_revision_id
			    and nvl(m.ready_to_compile_flag,'N') <> 'X');

   x_return_status := 0;    -- ie. value does not exist is child table
                            -- delete allowed.

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
                            -- delete NOT allowed.
      x_return_status := 1; -- since it is part of the exception
      x_stage := 1;

    when OTHERS then
      x_return_status := SQLCODE;

  end;

end check_references;
----------------------------------------------------------------------------

end PA_IND_COST_MULTIPLIERS_PKG;

/

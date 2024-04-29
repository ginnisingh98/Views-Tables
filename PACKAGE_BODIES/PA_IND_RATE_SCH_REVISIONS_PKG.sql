--------------------------------------------------------
--  DDL for Package Body PA_IND_RATE_SCH_REVISIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IND_RATE_SCH_REVISIONS_PKG" as
-- $Header: PAXCIRRB.pls 120.2.12000000.12 2007/08/31 07:37:01 prabsing ship $
-----------------------------------------------------------------------------
procedure start_to_gl(x_return_status         IN OUT NOCOPY number,
                      x_stage                 IN OUT NOCOPY number,
                      x_start_date_active     IN     date)
is
  x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  -- check that start date is equal to a GL period start date.
  begin
    select 1
    into   x_dummy
    from   gl_period_statuses gp,
	   pa_implementations imp
    where  gp.start_date = x_start_date_active
      and  gp.application_id = Pa_Period_Process_Pkg.Application_Id
      and  gp.set_of_books_id = imp.set_of_books_id
      and  gp.adjustment_period_flag = 'N';

   x_return_status := 0;    -- ie. value exists is referenced table

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value does not exist in ref table
    x_return_status := 1;
    x_stage := 1;

    when OTHERS then
    x_return_status := SQLCODE;
  end;

end start_to_gl;
-----------------------------------------------------------------------------
procedure end_to_gl(x_return_status         IN OUT NOCOPY number,
                    x_stage                 IN OUT NOCOPY number,
                    x_end_date_active       IN     date)
is
  x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  -- check that end date is equal to a GL period end date.
  begin
    select 1
    into   x_dummy
    from   gl_period_statuses gp,
	   pa_implementations imp
    where  gp.end_date = x_end_date_active
      and  gp.application_id = Pa_Period_Process_Pkg.Application_Id
      and  gp.set_of_books_id = imp.set_of_books_id
      and  gp.adjustment_period_flag = 'N';

    x_return_status := 0;    -- ie. value exists is referenced table

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value does not exist in ref table
    x_return_status := 1;
    x_stage := 1;

    when OTHERS then
    x_return_status := SQLCODE;
  end;

end end_to_gl;
----------------------------------------------------------------------------
procedure check_dates(x_return_status 	      IN OUT NOCOPY number,
                      x_stage                 IN OUT NOCOPY number,
                      x_ind_rate_sch_id       IN     number,
                      x_start_date_active     IN     date,
                      x_end_date_active       IN     date,
                      x_max_revision_id       IN OUT NOCOPY number,
                      x_max_end_date_active   IN OUT NOCOPY date)
is

  x_max_start_date_active pa_ind_rate_sch_revisions.start_date_active%TYPE;
  x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  -- get the newest revision details from the database.
  begin
    select ind_rate_sch_revision_id,
           start_date_active,
           end_date_active
    into   x_max_revision_id,
           x_max_start_date_active,
           x_max_end_date_active
    from   pa_ind_rate_sch_revisions
    where  ind_rate_sch_id = x_ind_rate_sch_id
    and    start_date_active in
			(select max(start_date_active)
                         from   pa_ind_rate_sch_revisions
			 where ind_rate_sch_id = x_ind_rate_sch_id);

    x_return_status := 0;

  EXCEPTION
    when TOO_MANY_ROWS then
    x_return_status := 1;
    x_stage := 1;
    return;
  end;

  -- validation of the current revision against the last one in the
  -- database.
  begin
    if (x_max_end_date_active is NULL) then
      begin
        if (x_start_date_active > x_max_start_date_active) then
          begin
            x_max_end_date_active := x_start_date_active - 1;
            x_return_status := 0;
          end;
        else
          begin
            x_return_status := 1;
            x_stage := 2;
            return;
          end;
        end if;
      end;
    else
      begin
        if (x_start_date_active = x_max_end_date_active + 1) then
          x_return_status := 0;
        else
          x_return_status := 1;
          x_stage := 3;
          return;
        end if;
      end;
    end if;
  end;

EXCEPTION
  when OTHERS then
  x_return_status := SQLCODE;

end check_dates;
-----------------------------------------------------------------------------
procedure check_references(x_return_status            IN OUT NOCOPY number,
                           x_stage                    IN OUT NOCOPY number,
                           x_ind_rate_sch_revision_id IN     number)
is
-- Begin bug 1718170
  l_dummy0 number := 0; /* Bug : 5877935 */
  l_dummy1 number := 0;
  l_dummy2 number := 0;
  l_dummy3 number := 0;
  l_dummy4 number := 0;
--  l_gms_installed varchar2(1) :=  'N'; /*Start  Bug : 5877935 */ /* commented for 6334295 */
  l_ind_compile_set_id number := 0;  /*  Added for Bug 6312921  */

  /*   Commenting code below for Bug 6312921  */
 -- cursor c0 is
 -- select 1
 -- from pa_ind_compiled_sets ics
 -- where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
 -- and exists (select null
 --                 from pa_expenditure_items ei
 --                 where tp_ind_compiled_set_id = ics.ind_compiled_set_id);
 -- cursor c1 is
 -- select 1
 -- from pa_ind_compiled_sets ics
 -- where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
 -- /*and not exists (select null -- Changed the not exists to exists */
 -- and exists (select /*+ index(ei PA_EXPENDITURE_ITEMS_N11) */ null  --added hint for bug 5845101
 --                 from pa_expenditure_items ei
 --                 where cost_ind_compiled_set_id = ics.ind_compiled_set_id);
 --
 -- cursor c2 is
 -- select 1
 -- from pa_ind_compiled_sets ics
 -- where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
 -- /*and not exists (select null -- Changed the not exists to exists */
 -- and exists (select null
 --                 from pa_expenditure_items
 --                 where rev_ind_compiled_set_id = ics.ind_compiled_set_id);
 --
 -- cursor c3 is
 -- select 1
 -- from pa_ind_compiled_sets ics
 --where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
 -- /*and not exists (select null -- Changed the not exists to exists */
 -- and exists (select null
 --                 from pa_expenditure_items
 --                 where inv_ind_compiled_set_id = ics.ind_compiled_set_id);
 --
/*   Commenting code for Bug 6312921  ends here   */
/* Code  added for Bug 6312921 :- starts  */
Cursor cind is
select ics.ind_compiled_set_id
  from pa_ind_compiled_sets ics
  where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id ;

cursor c0 (l_ind_compile_set_id number) is
  select 1
  from dual
  where exists (select null
/*                  from pa_expenditure_items ei */       /* for bug 6334295 */
                  from pa_expenditure_items_all ei
                  where tp_ind_compiled_set_id = l_ind_compile_set_id  );

  cursor c1 (l_ind_compile_set_id number) is
  select 1
  from dual
  where exists (select /*+ index(ei PA_EXPENDITURE_ITEMS_N11) */ null  --added hint for bug 5845101
/*                  from pa_expenditure_items ei */       /* for bug 6334295 */
                  from pa_expenditure_items_all ei
                  where cost_ind_compiled_set_id = l_ind_compile_set_id);

  cursor c2 (l_ind_compile_set_id number  ) is
   select 1
  from dual
  where exists (select null
/*                  from pa_expenditure_items */       /* for bug 6334295 */
                  from pa_expenditure_items_all
                  where rev_ind_compiled_set_id = l_ind_compile_set_id);

  cursor c3 (l_ind_compile_set_id number ) is
  select 1
  from dual
  where exists  (select null
/*                  from pa_expenditure_items */       /* for bug 6334295 */
                  from pa_expenditure_items_all
                  where inv_ind_compiled_set_id = l_ind_compile_set_id);

/* Code  added for Bug 6312921 :- ends */

-- End bug 1718170
/*c_cint cursor is added for Bug 3041364 added for Capital Interest */
 cursor c_cint is
   select 1
     from   sys.dual
    where exists (select 1
                  from pa_alloc_txn_details
                  where ind_rate_sch_revision_id = x_ind_rate_sch_revision_id);

		   /*Start ---- Added this cursor for 5877935 */
/* Code  commented  for Bug 6312921 - */
  /*cursor c4 is
  select 1 from dual where exists (
                     select 1 from pa_ind_compiled_sets ICS
                     WHERE ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id and
		     (exists
                       (SELECT NULL FROM pa_cost_distribution_lines_all CDL
                         WHERE ICS.ind_compiled_set_id = CDL.ind_compiled_set_id
                       )
                     OR (l_gms_installed = 'Y' and EXISTS
                          (SELECT NULL FROM gms_award_distributions adl
                           WHERE ICS.ind_compiled_set_id = adL.ind_compiled_set_id
                          )
		         )
                     OR (l_gms_installed = 'Y' and EXISTS
                          (SELECT NULL FROM gms_encumbrance_items gei
                           WHERE ICS.ind_compiled_set_id = gei.ind_compiled_set_id
                          )
		         ))
		      ); */
/* Code added  for Bug 6312921 :- starts  */

cursor c4 (l_ind_compile_set_id number ) is
  select 1 from dual where exists

                       (SELECT NULL FROM pa_cost_distribution_lines_all CDL
                         WHERE  CDL.ind_compiled_set_id = l_ind_compile_set_id
                       )
/*                     OR (l_gms_installed = 'Y' and EXISTS*/        /* for bug 6334295 */
                       OR EXISTS
                          (SELECT NULL FROM gms_award_distributions adl
                           WHERE adL.ind_compiled_set_id = l_ind_compile_set_id)

		       OR EXISTS
/*                     OR (l_gms_installed = 'Y' and EXISTS*/       /* for bug 6334295 */
/*                          (SELECT NULL FROM gms_encumbrance_items gei */       /* for bug 6334295 */
                          (SELECT NULL FROM gms_encumbrance_items_all gei
                           WHERE  gei.ind_compiled_set_id = l_ind_compile_set_id
		                );

/* Code added  for Bug 6312921 :- ends  */
begin

    /* Bug :5877935 ...condt */
/*     IF gms_install.enabled THEN
    l_gms_installed := 'Y' ;
  END IF ; /* Bug :5877935 */   /* /* commented for bug 6334295 */

   x_return_status := 0;
  x_stage := 0;

-- check against expenditure items

/* This select does a full table scan on pa_expenditure_item
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
           (select 1
           from   pa_expenditure_items ei,
		  pa_ind_compiled_sets ics
           where  ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
	   and    (   (ei.cost_ind_compiled_set_id = ics.ind_compiled_set_id)
	           or (ei.rev_ind_compiled_set_id = ics.ind_compiled_set_id)
	           or (ei.inv_ind_compiled_set_id = ics.ind_compiled_set_id)));
*/

/* Code  commented  for Bug 6312921  */
-- open c0;
-- fetch c0 into l_dummy0;
-- close c0;

-- IF l_dummy0 = 1 Then
--	x_return_status := 1;
--	x_stage := 1;
-- Else
-- Begin bug 1718170
--    open c1;
--    fetch c1 into l_dummy1;
--    close c1;

--    If l_dummy1 = 1 Then

--	x_return_status := 1;
--	x_stage := 1;

--    Else

--	open c2;
--        fetch c2 into l_dummy2;
--	close c2;

--	If l_dummy2 = 1 Then
--		x_return_status := 1;
--		x_stage := 1;
--        Else

--		open c3;
--		fetch c3 into l_dummy3;
--		close c3;

--		If l_dummy3 = 1 then
--			x_return_status := 1;
--			x_stage := 1;
--              else /* Added this for bug 5870999 */
--		        open c4;
--		        fetch c4 into l_dummy4;
--		        close c4;

--			If l_dummy4 = 1 then
--			   x_return_status := 1;
--			   x_stage := 2;
--			end if;
--		End If;

--	End If;

--    End If;
-- End If;
/* Code  commented  for Bug 6312921  ends here*/

/*   Code added  for Bug 6312921 - starts Code commented above re-written here inside loop */
for cindrec in cind loop
 open c0(cindrec.ind_compiled_set_id);
 fetch c0 into l_dummy0;
 close c0;

 IF l_dummy0 = 1 Then
	x_return_status := 1;
	x_stage := 1;
	exit;
 Else  /* Bug :5877935 */


-- Begin bug 1718170
    open c1(cindrec.ind_compiled_set_id);
    fetch c1 into l_dummy1;
    close c1;

    If l_dummy1 = 1 Then

	x_return_status := 1;
	x_stage := 1;
	exit;

    Else

	open c2(cindrec.ind_compiled_set_id);
        fetch c2 into l_dummy2;
	close c2;

	If l_dummy2 = 1 Then
		x_return_status := 1;
		x_stage := 1;
		exit;
        Else

		open c3(cindrec.ind_compiled_set_id);
		fetch c3 into l_dummy3;
		close c3;

		If l_dummy3 = 1 then

			x_return_status := 1;
			x_stage := 1;
			exit;
			 else /* Added this for bug 5877935 */
		        open c4(cindrec.ind_compiled_set_id);
		        fetch c4 into l_dummy4;
		        close c4;

			If l_dummy4 = 1 then
			   x_return_status := 1;
			   -- x_stage := 2;     Bug 6377913
                           x_stage := 1;
			  exit;
			end if;
		End If;

	End If;

    End If;
    End If;
end loop;
    l_dummy4 :=0; /* since the same dummy is used in the above, initializing it back to 0  bug:5877935*/

-- End bug 1718170
/*Bug 3041364 added for Capital Interest */
open c_cint;
fetch c_cint into l_dummy4;
close c_cint;
If l_dummy4 = 1 then
	x_return_status := 1;
	x_stage := 1;
End If;
/*End of changes for Bug 3041364 added for Capital Interest */
  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in ref table
      x_return_status := 1;
      x_stage := 1;

    when OTHERS then
      x_return_status := SQLCODE;

end check_references;
-----------------------------------------------------------------------------

procedure check_end_date_limit(x_return_status     IN OUT NOCOPY number,
                               x_end_date_active   IN date,
                               x_ind_rate_sch_revision_id IN number)
is


  l_dummy0 number := 0;
  l_dummy1 number := 0;
  l_dummy2 number := 0;
  l_dummy3 number := 0;
  l_dummy4 number := 0;

-- l_gms_installed varchar2(1) :=  'N';/* Bug6081362 */     /* commented for bug 6334295 */


  cursor c0 is
  select 1
  from pa_ind_compiled_sets ics
  where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
  and exists (select null
                  from pa_expenditure_items ei
                  where tp_ind_compiled_set_id = ics.ind_compiled_set_id and expenditure_item_date > x_end_date_active);


cursor c1 is
  select 1
  from pa_ind_compiled_sets ics
  where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
  /*and not exists (select null -- Changed the not exists to exists */
  and exists (select null
                  from pa_expenditure_items_all ei
                  where cost_ind_compiled_set_id = ics.ind_compiled_set_id and expenditure_item_date > x_end_date_active);

cursor c2 is
  select 1
  from pa_ind_compiled_sets ics
  where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
  /*and not exists (select null -- Changed the not exists to exists */
  and exists (select null
                  from pa_expenditure_items_all
                  where rev_ind_compiled_set_id = ics.ind_compiled_set_id and expenditure_item_date > x_end_date_active);

  cursor c3 is
  select 1
  from pa_ind_compiled_sets ics
  where ics.ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
  /*and not exists (select null -- Changed the not exists to exists */
  and exists (select null
                  from pa_expenditure_items_all
                  where inv_ind_compiled_set_id = ics.ind_compiled_set_id and expenditure_item_date > x_end_date_active);

/* Bug6081362 */
 cursor c4 is
  select 1 from dual where exists (select 1 from pa_ind_compiled_sets ICS
                     WHERE ics.ind_rate_sch_revision_id =x_ind_rate_sch_revision_id and
			exists (SELECT NULL FROM gms_encumbrance_items_all gei
                           WHERE ICS.ind_compiled_set_id = gei.ind_compiled_set_id
                             and ENCUMBRANCE_ITEM_DATE > x_end_date_active
/*                             and l_gms_installed = 'Y'*/      /* commented for bug 6334295 */
                          ));


begin

/*  IF gms_install.enabled THEN
    l_gms_installed := 'Y' ;
  END IF ; */ /* commented for bug 6334295 */


x_return_status := 0;

open c0;
fetch c0 into l_dummy0;
close c0;

 IF l_dummy0 = 1 Then
    x_return_status := 1;

  ELSE

open c1;
fetch c1 into l_dummy1;
close c1;

   IF l_dummy1 = 1 Then
      x_return_status := 1;

   ELSE

 open c2;
 fetch c2 into l_dummy2;
 close c2;

      IF l_dummy2 = 1 Then
       x_return_status := 1;

   ELSE

 open c3;
 fetch c3 into l_dummy3;
 close c3;

           IF l_dummy3 = 1 Then
	    x_return_status := 1;

  ELSE

/*Bug6081362 */
 open c4;
 fetch c4 into l_dummy4;
 close c4;

           IF l_dummy4 = 1 Then
            x_return_status := 1;

         END IF;
	END IF;
     END IF;
    END IF;
  END IF;

    EXCEPTION
    when NO_DATA_FOUND then
      x_return_status := 1;

    when OTHERS then
      x_return_status := SQLCODE;

end check_end_date_limit;
-----------------------------------------------------------------------------

procedure check_start_date(x_return_status            IN OUT NOCOPY number,
                           x_stage                    IN OUT NOCOPY number,
                           x_prev_end_date_active     IN OUT NOCOPY date,
                           x_prev_revision_id         IN OUT NOCOPY number,
                           x_ind_rate_sch_revision_id IN     number,
                           x_ind_rate_sch_id          IN     number,
                           x_start_date_active        IN     date)
is
  x_end_date_active date;
  x_prev_start_date_active date;

begin
  x_return_status := 0;
  x_stage := 0;

  begin
    select end_date_active
    into   x_end_date_active
    from   pa_ind_rate_sch_revisions
    where  ind_rate_sch_revision_id = x_ind_rate_sch_revision_id;

    if (x_end_date_active is null) then
      begin
        select end_date_active,
               start_date_active,
               ind_rate_sch_revision_id
        into   x_prev_end_date_active,
               x_prev_start_date_active,
               x_prev_revision_id
        from   pa_ind_rate_sch_revisions
        where  ind_rate_sch_id = x_ind_rate_sch_id
        and    end_date_active in
                              (select max(end_date_active)
                               from   pa_ind_rate_sch_revisions
                               where ind_rate_sch_id = x_ind_rate_sch_id);
      end;
    else
      begin
        select end_date_active,
               start_date_active,
               ind_rate_sch_revision_id
        into   x_prev_end_date_active,
               x_prev_start_date_active,
               x_prev_revision_id
        from   pa_ind_rate_sch_revisions
        where  ind_rate_sch_id = x_ind_rate_sch_id
        and    end_date_active < x_end_date_active
        and    end_date_active in
                              (select max(end_date_active)
                               from   pa_ind_rate_sch_revisions
                               where ind_rate_sch_id = x_ind_rate_sch_id
                               and    end_date_active < x_end_date_active);
      end;
    end if;

    x_return_status := 0;

    EXCEPTION
    when NO_DATA_FOUND then
    x_return_status := 0; -- Since this is the first and only record for
                          -- this revision.

    when TOO_MANY_ROWS then
    x_return_status := 1;
    x_stage := 1;
    return;

    when OTHERS then
    x_return_status := SQLCODE;
  end;

  begin
  -- Check that the previous revision that is to be changed is
  -- not referenced in expenditure items. If it is , then the
  -- change is not allowed.
  pa_ind_rate_sch_revisions_pkg.check_references(x_return_status,
                                                 x_stage,
                                                 x_prev_revision_id);
  if (x_return_status > 0) then
    begin
      x_stage := 5;
      return;
    end;
  elsif (x_return_status < 0) then
    return;
  end if;
  end;

  if ((x_start_date_active - 1) < x_prev_start_date_active) then
    x_return_status := 1;
    x_stage := 2;
    return;
  else
    x_prev_end_date_active := x_start_date_active - 1;
  end if;

end check_start_date;
-----------------------------------------------------------------------------
procedure check_end_date(x_return_status            IN OUT NOCOPY number,
                         x_stage                    IN OUT NOCOPY number,
                         x_next_start_date_active   IN OUT NOCOPY date,
                         x_next_revision_id         IN OUT NOCOPY number,
                         x_ind_rate_sch_revision_id IN     number,
                         x_ind_rate_sch_id          IN     number,
                         x_end_date_active          IN     date)
is
  x_start_date_active date;
  x_next_end_date_active date;

begin
  x_return_status := 0;
  x_stage := 0;

  begin
    select start_date_active
    into   x_start_date_active
    from   pa_ind_rate_sch_revisions
    where  ind_rate_sch_revision_id = x_ind_rate_sch_revision_id;

    select start_date_active,
           end_date_active,
           ind_rate_sch_revision_id
    into   x_next_start_date_active,
           x_next_end_date_active,
           x_next_revision_id
    from   pa_ind_rate_sch_revisions
    where  ind_rate_sch_id = x_ind_rate_sch_id
    and    start_date_active > x_start_date_active
    and    start_date_active in
                            (select min(start_date_active)
                             from   pa_ind_rate_sch_revisions
                             where  ind_rate_sch_id = x_ind_rate_sch_id
                             and    start_date_active > x_start_date_active);

    x_return_status := 0;

    EXCEPTION
    when NO_DATA_FOUND then
    x_return_status := 0; -- Since this is the first and only record for
                          -- this revision.

    when TOO_MANY_ROWS then
    x_return_status := 1;
    x_stage := 1;
    return;

    when OTHERS then
    x_return_status := SQLCODE;
  end;

  begin
  -- Check that the next revision that is to be changed is
  -- not referenced in expenditure items. If it is , then the
  -- change is not allowed.
    pa_ind_rate_sch_revisions_pkg.check_references(x_return_status,
                                                   x_stage,
                                                   x_next_revision_id);
    if (x_return_status > 0) then
      begin
        x_stage := 5;
        return;
      end;
    elsif (x_return_status < 0) then
      return;
    end if;
  end;

  if (x_next_end_date_active is NULL) then
    begin
      x_next_start_date_active := x_end_date_active + 1;
    end;
  else
    begin
      if ((x_end_date_active + 1) > x_next_end_date_active) then
        x_return_status := 1;
        x_stage := 2;
        return;
      else
        x_next_start_date_active := x_end_date_active + 1;
      end if;
    end;
  end if;

end check_end_date;

-----------------------------------------------------------------------------
procedure check_multipliers(x_ind_rate_sch_revision_id IN     number,
                            x_return_status            IN OUT NOCOPY number,
                            x_stage                    IN OUT NOCOPY number)
is

dummy  integer;
begin

   x_stage := 100;
   x_return_status := 0;

   SELECT 1 INTO dummy
   FROM sys.dual
   WHERE EXISTS
     (SELECT 1
      FROM   pa_ind_cost_multipliers
      WHERE  ind_rate_sch_revision_id = x_ind_rate_sch_revision_id);

exception
   when OTHERS then
     x_return_status := SQLCODE;

end check_multipliers;

-----------------------------------------------------------------------------
/***2933915:Added parameter x_ready_to_compile and another select in check_ready_compile()
to check if the multiplier has changed in pa_ind_cost_multipliers.This will form the
additional criteria for deciding if a revision can be compiled or not ***/

procedure check_ready_compile(x_ind_rate_sch_revision_id IN     number,
			      x_ready_compile_flag	 IN OUT NOCOPY varchar2,
                              x_ready_for_compile        IN OUT NOCOPY varchar2,      /*2933915*/
			      x_compiled_flag	         IN OUT NOCOPY varchar2,
                              x_return_status            IN OUT NOCOPY number,
                              x_stage                    IN OUT NOCOPY number)
is
begin

   x_stage := 100;
   x_return_status := 0;

    SELECT ready_to_compile_flag, compiled_flag
     INTO   x_ready_compile_flag, x_compiled_flag
    FROM   pa_ind_rate_sch_revisions
    WHERE  ind_rate_sch_revision_id = x_ind_rate_sch_revision_id;

/***2933915 :This is to check if ready to compile multipliers are existing i.e if multipliers have changed*/
  Begin
   SELECT 'Y'
   INTO   x_ready_for_compile
   FROM   dual
   WHERE  exists (select 1
                   from pa_ind_cost_multipliers
                   WHERE  ind_rate_sch_revision_id = x_ind_rate_sch_revision_id
		   AND     nvl(ready_to_compile_flag,'N') in ('Y','X'));
  exception
  When NO_DATA_FOUND then      /*2933915*/
   x_ready_for_compile :='N';
  End;
/*End of changes for bug# 2933915*/
 exception
   when OTHERS then
     x_return_status := SQLCODE;

end check_ready_compile;
-----------------------------------------------------------------------------

end PA_IND_RATE_SCH_REVISIONS_PKG;

/

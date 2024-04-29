--------------------------------------------------------
--  DDL for Package Body PA_COST_BASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_BASES_PKG" as
---  $Header: PAXCCBAB.pls 120.1 2005/08/23 19:19:00 spunathi noship $
--- ---------------------------------------------------------------------------
---  this procedure will check that the PK value being input is Unique.

procedure check_unique (x_return_status  IN OUT NOCOPY number,
                        x_rowid          IN     varchar2,
                        x_cost_base      IN     varchar2,
                        x_cost_base_type IN     varchar2)
is
x_dummy number;

begin
  x_return_status := 0;

  select 1
  into   x_dummy
  from   sys.dual
  where  not exists
                  (select 1
                   from   pa_cost_bases c
                   where  c.cost_base = x_cost_base
                   and    c.cost_base_type = x_cost_base_type
                   and    ((x_rowid is NULL) or (rowid <> x_rowid)));

  x_return_status := 0;

EXCEPTION
  WHEN NO_DATA_FOUND then
  x_return_status := 1;

  WHEN OTHERS then
  x_return_status := SQLCODE;

end check_unique;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- This procedure checks if just the cost base has been used in CBICC or
-- Expenditure types
procedure check_ref_cost_base(x_return_status  IN OUT NOCOPY number,
                              x_stage          IN OUT NOCOPY number,
                              x_cost_base      IN     varchar2)
is
x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_cost_base_cost_codes cbicc
                     where  cbicc.cost_base = x_cost_base);

   x_return_status := 0;    -- ie. value does not exist is child table
                            -- delete allowed.

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
                            -- delete NOT allowed.
    x_return_status := 1;
    x_stage := 1;
    return;

  end;

-- check against the Cost base exp types table.

  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_cost_base_exp_types p
                     where  p.cost_base = x_cost_base);

    x_return_status := 0;

  EXCEPTION
    when NO_DATA_FOUND then
    x_return_status := 1;
    x_stage := 5;
    return;

  end;

EXCEPTION
  when OTHERS then
  x_return_status := SQLCODE;


end check_ref_cost_base;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- this procedure will do a referential integrity check. Cost base appears
-- as a FK in 3 tables, PA_COMPILED_MULTIPLIERS, PA_COST_BASE_COST_CODES
-- and PA_COST_BASE_EXP_TYPES. However we may not check these tables in
-- all cases as it may not be logically relevant. So we will check against
-- the following. We will check against PA_COST_BASE_EXP_TYPES and
-- PA_COST_BASE_COST_CODES.
-- Also if data exists in PA_COST_BASE_COST_CODES, we will check further
-- to see if the exp item has been costed.

procedure check_references(x_return_status  IN OUT NOCOPY  number,
                           x_stage          IN OUT NOCOPY  number,
                           x_cost_base      IN     varchar2,
                           x_cost_base_type IN     varchar2)
is
x_dummy number;

begin
  x_return_status := 0;
  x_stage := 0;

  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_cost_base_cost_codes cbicc
                     where  cbicc.cost_base = x_cost_base
                     and    cbicc.cost_base_type = x_cost_base_type);

   x_return_status := 0;    -- ie. value does not exist is child table
                            -- delete allowed.

  EXCEPTION
    when NO_DATA_FOUND then -- ie. value exists in child table
                            -- delete NOT allowed.
                            -- start checking further upto exp item level.
    begin
      x_return_status := 1; -- since it is part of the exception
      x_stage := 1;
                            -- if this select returns data, it means
                            -- that exp items have been costed
                            -- However, if no data is found, exp items
                            -- have not been costed, the cost bases
                            -- exist in cbicc.
      select 1
      into   x_dummy
      from   pa_cost_base_cost_codes cbicc,
             pa_ind_cost_multipliers mul,
	     pa_ind_compiled_sets ics,
             pa_expenditure_items ei
      where  cbicc.cost_base = x_cost_base
      and    cbicc.cost_base_type = x_cost_base_type
      and    cbicc.ind_cost_code = mul.ind_cost_code
      and    mul.ind_rate_sch_revision_id = ics.ind_rate_sch_revision_id
      and    ((ics.ind_compiled_set_id =
                              ei.cost_ind_compiled_set_id)
      or      (ics.ind_compiled_set_id =
                              ei.rev_ind_compiled_set_id)
      or      (ics.ind_compiled_set_id =
                              ei.inv_ind_compiled_set_id));

      x_stage := 2;         -- if exp items have been costed, ie data was
                            -- found.

      EXCEPTION
        when NO_DATA_FOUND then
          x_return_status := 2;
          return;

        when TOO_MANY_ROWS then
          x_return_status := 1;
          x_stage := 2;     -- as data is found, even tho' it is an exception.
          return;
    end;
  end;

-- check against the Cost base exp types table.

  begin
    select 1
    into   x_dummy
    from   sys.dual
    where  not exists
                    (select 1
                     from   pa_cost_base_exp_types p
                     where  p.cost_base = x_cost_base
                     and    p.cost_base_type = x_cost_base_type);

    x_return_status := 0;

  EXCEPTION
    when NO_DATA_FOUND then
    x_return_status := 1;
    x_stage := 5;
    return;

  end;

EXCEPTION
  when OTHERS then
  x_return_status := SQLCODE;



end check_references;
----------------------------------------------------------------------------
end PA_COST_BASES_PKG;

/

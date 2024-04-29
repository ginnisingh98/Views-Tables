--------------------------------------------------------
--  DDL for Package Body PA_COST_BASE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_BASE_TYPE_PKG" as
/* $Header: PAXLOUPB.pls 120.2 2005/08/08 12:40:44 sbharath noship $ */
---------------------------------------------------------------------------
procedure check_unique (x_return_status  IN OUT NOCOPY number,
                        x_rowid          IN     varchar2,
                        x_lookup_code    IN     varchar2)
is
x_dummy number;

begin
 x_return_status := 0;

  select 1
  into   x_dummy
  from   sys.dual
  where  not exists
                  (select 1
                   from   pa_lookups p
                   where  p.lookup_type like 'COST BASE TYPE'
                   and    ((x_rowid is NULL) or (rowid <> x_rowid))
                   and    p.lookup_code = x_lookup_code);

  x_return_status := 0;

EXCEPTION
  WHEN NO_DATA_FOUND then
  x_return_status := 1;

  WHEN OTHERS then
  x_return_status := SQLCODE;

end check_unique;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
procedure check_references (x_return_status  IN OUT NOCOPY number,
                            x_stage          IN OUT NOCOPY number,
                            x_lookup_code    IN     varchar2)
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
                     from   pa_cost_bases cb
                     where  cb.cost_base_type  = x_lookup_code);

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
end PA_COST_BASE_TYPE_PKG;

/

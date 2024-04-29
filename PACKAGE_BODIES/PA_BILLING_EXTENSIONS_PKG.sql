--------------------------------------------------------
--  DDL for Package Body PA_BILLING_EXTENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_EXTENSIONS_PKG" as
/* $Header: PAXIBEXB.pls 120.3 2005/08/19 17:13:49 mwasowic noship $ */
-----------------------------------------------------------------------------
-- this procedure will check for unique existence of name
-- ( billing extension name )
-----------------------------------------------------------------------------
procedure check_unique_name (x_return_status  IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                             x_rowid          IN     varchar2,
                             x_name           IN     varchar2 )
is
x_dummy number;
--
begin
--
  select 1
  into   x_dummy
  from   sys.dual
  where  not exists
                  (select 1
                   from   pa_billing_extensions
                   where  name = x_name
                   and    ((x_rowid is NULL) or (rowid <> x_rowid)));
--
  x_return_status := 0;
--
EXCEPTION
  WHEN NO_DATA_FOUND then
  x_return_status := 1;
  WHEN OTHERS then
  x_return_status := SQLCODE;
end check_unique_name;

------------------------------------------------------------------

procedure check_unique_order (x_return_status  IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                              x_rowid          IN     varchar2,
                              x_order          IN     number)
is
x_dummy number;
--
begin
--
  select 1
  into   x_dummy
  from   sys.dual
  where  not exists
                  (select 1
                   from   pa_billing_extensions
                   where  processing_order = x_order
                   and    ((x_rowid is NULL) or (rowid <> x_rowid)));
--
  x_return_status := 0;
--
EXCEPTION
  WHEN NO_DATA_FOUND then
  x_return_status := 1;
  WHEN OTHERS then
  x_return_status := SQLCODE;
end check_unique_order;
------------------------------------------------------------------
--
procedure check_references( x_return_status      IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                            x_rowid              IN     varchar2,
                            x_bill_extension_id  IN     number )
is
--
x_dummy             number;
stage               number;
begin
--
    stage := 1;
--
    select 1
    into x_dummy
    from sys.dual
    where not exists
          ( select 1
            from pa_billing_assignments
            where billing_extension_id = x_bill_extension_id );
--
    x_return_status := 0;
--
EXCEPTION
  WHEN NO_DATA_FOUND then
     if stage = 1 then
        x_return_status := 1;
     end if;
  WHEN OTHERS then
     x_return_status := SQLCODE;
--
end check_references;

procedure check_events( x_return_status       IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                        x_rowid               IN     varchar2,
                        x_bill_extension_id   IN     number )
is
--
x_dummy             number;
stage               number;
begin
--
    stage := 1;
--
    select 1 into x_dummy
     from sys.dual
     where not exists ( select 1
                         from pa_billing_assignments
                         where billing_extension_id = x_bill_extension_id
                           and billing_assignment_id in
                              ( select billing_assignment_id
                               from pa_events ));
--
    x_return_status := 0;
--
EXCEPTION
  WHEN NO_DATA_FOUND then
     x_return_status := 1;
  WHEN OTHERS then
     x_return_status := SQLCODE;
--
end check_events;

--------------------------------------------------------------------

procedure get_nextval( x_return_status IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                       x_nextval IN OUT NOCOPY number ) --File.Sql.39 bug 4440895
is
--
begin
--
   select pa_billing_extensions_s.nextval into x_nextval
   from sys.dual;
--
   x_return_status := 0;
--
EXCEPTION
  WHEN NO_DATA_FOUND then
     x_return_status := 1;
  WHEN OTHERS then
     x_return_status := SQLCODE;
--
end get_nextval;
--
END pa_billing_extensions_pkg;

/

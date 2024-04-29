--------------------------------------------------------
--  DDL for Package Body IBY_PMTDATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PMTDATES_PKG" as
/*$Header: ibyschdb.pls 115.3 2002/11/19 21:17:02 jleybovi ship $*/
/*
** This package is a wrapper kind of package to support the
** Holidays. Each BEP need to define a package with its name prefixed to
** "_pkg". That package should provide a s`procedure in it
** which should be named as "getDates" and Parameters, int, and 4 date
** parameters.
** int parameter is the leadtime of the BEP.
** first date parameter is the settlement date requested by user.
** second date parameter is the current date, the date on which the payment
**       was requested.
** next two dates are the ouput dates. First output date corresponds to the
** schedule date of the payment and next out param is the earliest
** settlement date possible.
*/
procedure getPmtDates( i_bepid in iby_bepinfo.bepid%type,
                    i_settlement_date in date,
                    i_current_date in date,
                    io_schedule_date in out nocopy date,
                    io_earliest_sched_date in out nocopy date)
as
l_bepname iby_bepinfo.name%type;
l_leadtime iby_bepinfo.leadtime%type;
l_holidayfile iby_bepinfo.holidayfile%type;
l_blockstr varchar2(1000);
l_cursorId integer;
l_dummy integer;
/*
** Cursor to get the BEP name and leadtime.
*/
cursor bepinfo ( ci_bepid iby_bepinfo.bepid%type) is
select name, leadtime, upper(holidayfile)
from iby_bepinfo
where bepid = ci_bepid;
begin
    if ( bepinfo%isopen ) then
        close bepinfo;
    end if;
    open bepinfo(i_bepid);
/*
** fetch the bep name and leadtime.
*/
    fetch bepinfo into l_bepname, l_leadtime, l_holidayfile;
    if ( bepinfo%notfound ) then
        close bepinfo;
       	raise_application_error(-20000, 'IBY_20521#', FALSE);
        --raise_application_error(-20521, 'No BEP Objects matches', FALSE);
    end if;
    if ( l_holidayfile = 'Y' ) then
/*
** Construct a dynamic PL/SQL call for calling the BEP's package.
*/
        l_cursorId := DBMS_SQL.OPEN_CURSOR;
        l_blockstr := 'BEGIN
                iby_' || l_bepname || '_pkg.getPmtDates( :leadtime, :reqsetdate, :curdate, :expschdate, :earliestschdate);
               END; ';
/*
** Bind parameters to the BEP call.
*/
        DBMS_SQL.PARSE(l_CursorId, l_blockstr, DBMS_SQL.V7);
        DBMS_SQL.BIND_VARIABLE(l_cursorID, ':leadtime', l_leadtime);
        DBMS_SQL.BIND_VARIABLE(l_cursorID, ':reqsetdate', i_settlement_date);
        DBMS_SQL.BIND_VARIABLE(l_cursorID, ':curdate', i_current_date);
        DBMS_SQL.BIND_VARIABLE(l_cursorID, ':expschdate', io_schedule_date);
        DBMS_SQL.BIND_VARIABLE(l_cursorID, ':earliestschdate', io_earliest_sched_date);
/*
** Execute the Dynamic plsql.
*/
        l_dummy := dbms_sql.execute(l_cursorid);
/*
** Extract the values from the plsql procedure.
*/
        DBMS_SQL.VARIABLE_VALUE(l_cursorID, ':leadtime', l_leadtime);
        DBMS_SQL.VARIABLE_VALUE(l_cursorID, ':expschdate', io_schedule_date);
        DBMS_SQL.VARIABLE_VALUE(l_cursorID, ':earliestschdate', io_earliest_sched_date);
        if ( io_earliest_sched_date is null ) then
            io_earliest_sched_date := i_settlement_date;
        end if;
        dbms_sql.close_cursor(l_cursorid);
    else
        io_schedule_date := i_settlement_date - l_leadtime;
        if ( trunc(io_schedule_date) < trunc(i_current_date) ) then
            io_earliest_sched_date := i_current_date + l_leadtime;
            io_schedule_date := i_current_date;
        else
            io_earliest_sched_date := i_settlement_date;
        end if;
    end if;
end getPmtDates;
end iby_pmtdates_pkg;

/

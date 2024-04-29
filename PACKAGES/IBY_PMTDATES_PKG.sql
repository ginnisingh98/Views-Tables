--------------------------------------------------------
--  DDL for Package IBY_PMTDATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PMTDATES_PKG" AUTHID CURRENT_USER as
/*$Header: ibyschds.pls 115.2 2002/11/19 21:16:54 jleybovi ship $*/
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
/*
** Name : GetDates
** Purpose: To call Dynamically the BEP procedure which handles
**          the BEP holiday support.
** Parameters:
**    In:    i_bepid , id of the BEP.
**           i_settlementdate, date on which requested for settlement.
**           i_current_date, date on which payment was received.
**    Out:
**           o_schedule_date, date on which payment is going to be scheduled.
**           o_earliest_sched_date, date on which payment at the earliest can be
**           settled.
*/
procedure getPmtDates( i_bepid in iby_bepinfo.bepid%type,
                    i_settlement_date in date,
                    i_current_date in date,
                    io_schedule_date in out nocopy date,
                    io_earliest_sched_date in out nocopy date);
end iby_pmtdates_pkg;

 

/

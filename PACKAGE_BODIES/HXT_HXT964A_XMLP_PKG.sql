--------------------------------------------------------
--  DDL for Package Body HXT_HXT964A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT964A_XMLP_PKG" AS
/* $Header: HXT964AB.pls 120.0 2007/12/03 11:47:15 amakrish noship $ */

function CF_PeriodFormula return VARCHAR2 is
 payroll  VARCHAR2(240);
 start_d  date;
 end_d    date;

begin
 select  payroll_name || '   ' || to_char(ptp.start_date, 'YYYY/MM/DD') || '  -  ' || to_char(ptp.end_date, 'YYYY/MM/DD')
 into    payroll
from per_time_periods ptp, pay_payrolls_f pay
where ptp.time_period_id = P_TIME_PERIOD_ID
and (sysdate between pay.effective_start_date
    and pay.effective_end_date)
and  (ptp.payroll_id = pay.payroll_id);

-- return (payroll||'   '||to_char(start_d,'YYYY/MM/DD')||'   '||to_char(end_d,'YYYY/MM/DD'));
return (payroll);

end;

function BeforeReport return boolean is
begin

  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT964A_XMLP_PKG ;

/

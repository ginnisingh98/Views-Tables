--------------------------------------------------------
--  DDL for Package Body PAY_PAYHKCTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYHKCTL_XMLP_PKG" AS
/* $Header: PAYHKCTLB.pls 120.0 2007/12/13 12:17:00 amakrish noship $ */

function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;

select
SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3))
into
LP_ARCHIVE_ACTION_ID,
LP_ARCHIVE_OR_MAGTAPE,
LP_BUSINESS_GROUP_ID
from FND_CONCURRENT_REQUESTS
where request_id = FND_GLOBAL.conc_request_id;

LCF_business_group := CF_business_groupFormula;
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function CF_business_groupFormula return VARCHAR2 is
  v_business_group  hr_all_organization_units.name%type;

begin
  v_business_group := hr_reports.get_business_group(lp_business_group_id);
  return v_business_group;
end;

function cf_balance_calculationformula(ctr in number, X_HK_IR56_A_ASG_LE_YTD in varchar2, X_HK_IR56_B_ASG_LE_YTD in varchar2, X_HK_IR56_C_ASG_LE_YTD in varchar2, X_HK_IR56_D_ASG_LE_YTD in varchar2,
X_HK_IR56_E_ASG_LE_YTD in varchar2, X_HK_IR56_F_ASG_LE_YTD in varchar2, X_HK_IR56_G_ASG_LE_YTD in varchar2, X_HK_IR56_H_ASG_LE_YTD in varchar2, X_HK_IR56_I_ASG_LE_YTD in varchar2, X_HK_IR56_J_ASG_LE_YTD in varchar2, X_HK_IR56_K1_ASG_LE_YTD in varchar2,
X_HK_IR56_K2_ASG_LE_YTD in varchar2, X_HK_IR56_K3_ASG_LE_YTD in varchar2, X_HK_IR56_L_ASG_LE_YTD in varchar2) return number is
  l_sum number :=0;
begin
  if (ctr = 1 ) then
  l_sum :=
   trunc(to_number(X_HK_IR56_A_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_B_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_C_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_D_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_E_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_F_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_G_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_H_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_I_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_J_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_K1_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_K2_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_K3_ASG_LE_YTD ))
  +trunc(to_number(X_HK_IR56_L_ASG_LE_YTD ));
  end if;

   RETURN l_sum;

end;

--Functions to refer Oracle report placeholders--

END PAY_PAYHKCTL_XMLP_PKG ;

/

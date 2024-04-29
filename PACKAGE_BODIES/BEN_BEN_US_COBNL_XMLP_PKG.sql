--------------------------------------------------------
--  DDL for Package Body BEN_BEN_US_COBNL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BEN_US_COBNL_XMLP_PKG" AS
/* $Header: BEN_US_COBNLB.pls 120.1.12010000.2 2009/01/30 14:09:09 sagnanas ship $ */

function cf_1formula(admin_name in varchar2, loc_addr1 in varchar2, loc_Addr2 in varchar2,loc_Addr3 in varchar2, loc_city in varchar2, loc_state in varchar2, loc_zip in varchar2, loc_phone in varchar2,per_cm_prvdd_id in number) return varchar2 is
 mvar varchar2(3500) ;
begin
  begin
   select   admin_name || ', ' || loc_addr1 ||', ' ||
            loc_Addr2 || decode(loc_addr2, null,'',', ') ||
            loc_Addr3 || decode(loc_addr3, null,'',', ') ||
            loc_city || ', ' || loc_state || ', ' ||
            loc_zip || decode( loc_phone , null,'',', Phone : ')||loc_phone ||'.'
    into  mvar
     from dual ;

        update_pcd_sent_dt(p_per_cm_prvdd_id  => per_cm_prvdd_id
               ,p_effective_Date   => p_effective_Date );
        cp_effective_Date := p_effective_Date ;



    return mvar  ;
  exception
    when others then
    return null ;
  end ;

end;

procedure update_pcd_sent_dt(p_per_cm_prvdd_id in number
                             ,p_effective_date in date ) is

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   update ben_per_cm_prvdd_f
     set sent_Dt = p_effective_Date
      where per_cm_prvdd_id = p_per_cm_prvdd_id
        and  sent_dt is null
        and   p_effective_Date between
              effective_Start_date and
              effective_end_Date  ;
  commit;
 END;

function AfterReport return boolean is
begin
    return (TRUE);
end;

function BeforeReport return boolean is
begin
    return (TRUE);
end;

function CF_STANDARD_HEADERFormula return Number is
begin


  return 1;
end;

function cf_cmcd_acty_rep_prdformula(cmcd_acty_ref_perd_cd in varchar2) return char is
  cursor c1 is
   select meaning from
   hr_lookups hr
   where hr.lookup_code = cmcd_acty_ref_perd_cd
     and hr.lookup_type = 'BEN_ENRT_INFO_RT_FREQ' ;
  l_return varchar2(80) ;

begin
  if cmcd_acty_ref_perd_cd is not null then
      open c1 ;
      fetch c1 into l_return ;
      close c1 ;
  end if ;

  return l_return ;


end;

--Functions to refer Oracle report placeholders--

 Function cp_effective_date_p return date is
	Begin
	 return cp_effective_date;
	 END;
 Function CP_ler_text_p(ler_type in varchar2,ler_name in varchar2,pcm_ocrd_dt in date) return varchar2 is
	Begin
	          if ler_type = 'SCHEDDU' or ler_type  is null then
        cp_ler_text := 'one of the following event,

[  ] End of employment
[  ] Reduction in hours of employment
[  ] Death of employee
[  ] Divorce or legal separation
[  ] Entitlement to Medicare
[  ] Loss of dependent child status ' ;
     else
        cp_ler_text := 'the qualifying event '|| ler_name ||
         ' that occurred on '|| to_char(pcm_ocrd_dt,'DD fmMonth RRRR') ||'.';
     end if ;

	 return CP_ler_text;
	 END;
END BEN_BEN_US_COBNL_XMLP_PKG ;

/

--------------------------------------------------------
--  DDL for Package Body OTA_OTARPBUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OTARPBUD_XMLP_PKG" AS
/* $Header: OTARPBUDB.pls 120.1 2007/12/07 05:59:35 amakrish noship $ */
function BeforeReport return boolean is

cursor c_activity is
select name
from ota_activity_definitions_tl
where activity_id = p_activity_id
and   language = userenv('LANG') ;

cursor c_activity_version is
select version_name
from ota_activity_versions_tl
where activity_version_id = p_activity_version_id
and   language = userenv('LANG') ;

cursor c_event(l_event_id number) is
select title
from ota_events_tl
where event_id = l_event_id
and   language = userenv('LANG') ;



cursor c_res_booking_status(l_lookup_code varchar2) is
select meaning
from hr_lookups
where lookup_code = l_lookup_code
and lookup_type = 'RESOURCE_BOOKING_STATUS';

cursor c_transfer_status(l_lookup_code varchar2) is
select meaning
from hr_lookups
where lookup_code = l_lookup_code
and lookup_type = 'GL_TRANSFER_STATUS';



begin
  --hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

 if p_activity_id is not null then
 	open c_activity;
 	fetch c_activity into c_activity_name;
 	close c_activity;
 end if;

 if p_activity_version_id is not null then
 	open c_activity_version;
 	fetch c_activity_version into c_activity_version_name;
 	close c_activity_version;
 end if;

 if p_event_id is not null then
 	open c_event(p_event_id);
 	fetch c_event into c_event_title;
 	close c_event;
 end if;

 if p_activity_id is not null then
 	open c_event(p_program_id);
 	fetch c_event into c_program_name;
 	close c_event;
 end if;


 if p_transfer_status is not null then
        open c_transfer_status(p_transfer_status);
        fetch c_transfer_status into cp_transfer_status;
        close c_transfer_status;
 end if;

 if p_resource_booking_status is not null then
        open c_res_booking_status(p_resource_booking_status);
        fetch c_res_booking_status into cp_resource_booking_status;
        close c_res_booking_status;
 end if;

LP_SESSION_DATE	:=	P_SESSION_DATE;
return (TRUE);
end;

function CF_eff_dateFormula return Date is
 temp date;
begin

   select effective_date
   into temp
   from fnd_sessions
   where session_id=userenv('SESSIONID');

   return temp;

  RETURN NULL;

  RETURN NULL; exception
   when others then
     temp:=sysdate;
/*srw.message(20,to_char(temp));*/null;

  return temp;
end;

function cf_conv_amountformula(event_id in number, currency_code1 in varchar2, money_amount in number, cf_eff_date in date, cf_currency_type in varchar2) return number is
  result number;
begin
  if (cp_prev_event is NULL or cp_prev_event <> event_id)
  then
      cp_rev_curr:=0;
      cp_prev_event:=event_id;
  end if;


 if currency_code1=p_delegate_display_currency or currency_code1 is null or p_delegate_display_currency is null
  then
     cp_conv:= money_amount;
  else
    result:=hr_currency_pkg.convert_amount_sql(currency_code1,
					p_delegate_display_currency,
					cf_eff_date,
					money_amount,
					cf_currency_type);
    if result =-1 or result=-2 then
       cp_rev_curr:=cp_rev_curr+1;
    else
       cp_conv:= result;
    end if;
  end if;
return 0;
end;

function cf_conv1formula(event_id in number, currency_code3 in varchar2, money_amount2 in number, cf_eff_date in date, cf_currency_type in varchar2) return number is
    result number;
begin
  if (cp_prev_event2 is NULL or cp_prev_event2 <> event_id)
  then
      cp_cost_curr:=0;
      cp_prev_event2:=event_id;
  end if;
  if currency_code3=p_delegate_display_currency
  then
     cp_conv1:= money_amount2;
  else
    result:=hr_currency_pkg.convert_amount_sql(currency_code3,
					nvl(p_delegate_display_currency,currency_code3),
					cf_eff_date,
					money_amount2,
					cf_currency_type);
    if result =-1 or result=-2 then
       cp_cost_curr:=cp_cost_curr+1;
    else
       cp_conv1:= result;
    end if;
  end if;
return 0;
end;

function cf_currency_typeformula(cf_eff_date in date) return varchar2 is
begin
  return hr_currency_pkg.get_rate_type(
	p_business_group_id,
	cf_eff_date,
	'R');

 exception
	when others then
		/*srw.message(10,'get_currency_type procedure failed' );*/null;

 return NULL;

end;

function cf_venueformula
  (event_id in number) return char
is
cursor c_venue(pevent_id number) is
   select replace(name,fnd_global.local_chr(10),fnd_global.local_chr(46))
   from hr_all_organization_units org,
        ota_events_vl evt
   where evt.event_id = pevent_id
      and evt.training_center_id = org.organization_id;

begin


   cp_venue := 'None listed';
   open c_venue(event_id);
   fetch c_venue into cp_venue;
   close c_venue;
   return(to_char(null));

            end;

function AfterPForm return boolean is
begin

  if (p_activity_version_id is not null or p_activity_id is not null or p_event_id is not null or p_program_id is not null) then
null;
else
     /*srw.message(10,' One of the below Parameters Must be entered ');*/null;

     /*srw.message(10,' Activity Type, Activity, Event Title, Program ');*/null;

     raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;



  return (TRUE);
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_rev_curr_p return number is
	Begin
	 return CP_rev_curr;
	 END;
 Function CP_cost_curr_p return number is
	Begin
	 return CP_cost_curr;
	 END;
 Function CP_Venue_p return varchar2 is
	Begin
	 return CP_Venue;
	 END;
 Function CP_prev_event_p return number is
	Begin
	 return CP_prev_event;
	 END;
 Function CP_conv_p return number is
	Begin
	 return CP_conv;
	 END;
 Function CP_prev_event2_p return number is
	Begin
	 return CP_prev_event2;
	 END;
 Function CP_conv1_p return number is
	Begin
	 return CP_conv1;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_ACTIVITY_NAME_p return varchar2 is
	Begin
	 return C_ACTIVITY_NAME;
	 END;
 Function C_ACTIVITY_VERSION_NAME_p return varchar2 is
	Begin
	 return C_ACTIVITY_VERSION_NAME;
	 END;
 Function C_EVENT_TITLE_p return varchar2 is
	Begin
	 return C_EVENT_TITLE;
	 END;
 Function C_PROGRAM_NAME_p return varchar2 is
	Begin
	 return C_PROGRAM_NAME;
	 END;
 Function CP_transfer_status_p return varchar2 is
	Begin
	 return CP_transfer_status;
	 END;
 Function CP_resource_booking_status_p return varchar2 is
	Begin
	 return CP_resource_booking_status;
	 END;
END OTA_OTARPBUD_XMLP_PKG ;

/

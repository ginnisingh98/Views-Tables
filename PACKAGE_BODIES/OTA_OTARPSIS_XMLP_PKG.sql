--------------------------------------------------------
--  DDL for Package Body OTA_OTARPSIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OTARPSIS_XMLP_PKG" AS
/* $Header: OTARPSISB.pls 120.2 2008/06/04 14:30:24 amakrish noship $ */
function BeforeReport return boolean is
begin

--hr_standard.event('BEFORE REPORT') ;

  return (TRUE);
end;

function CF_OPTIONAL_COLUMNFormula return Char is
begin

IF P_OPTIONAL_COLUMN = NULL THEN
    return ('');
ELSE
    return (P_OPTIONAL_COLUMN);
END IF;

end;

FUNCTION AfterPForm
  RETURN BOOLEAN
IS
Cursor c_event(p_event_id number) is
Select title
from ota_events_tl
where event_id = p_event_id
and   language = userenv('LANG') ;

Cursor c_training_center(center_id number) is
Select name
from hr_all_organization_units org
where ORG.ORGANIZATION_ID = center_id;

BEGIN


IF p_event_id IS NULL and p_training_center_id IS NULL and p_course_start_date IS NULL
   and p_course_end_date IS NULL and p_booking_id IS NULL and P_BOOKING_ID IS NULL THEN

   /*SRW.message(100,'This report cannot be run without at least one parameter entered.');*/null;

   RAISE_application_error(-20101,null);/*SRW.program_abort;*/null;

   RETURN(FALSE);

END IF;

IF p_course_start_date > p_course_end_date THEN

   /*SRW.message(200,'The course start start cannot be later than the course end date.');*/null;

   RAISE_application_error(-20101,null);/*SRW.program_abort;*/null;

   RETURN(FALSE);

END IF;

p_and := TO_CHAR(NULL);
p_trainer_and := ' ';

IF p_event_id IS NOT NULL THEN
   p_and := p_and ||' AND evt.event_id = :p_event_id';
   p_trainer_and := p_trainer_and || ' AND rb.event_id = :p_event_id';
END IF;

IF (p_course_start_date IS NOT NULL AND p_course_end_date IS NOT NULL) THEN
    p_and := p_and || ' AND evt.course_start_date = fnd_date.canonical_to_date(:p_course_start_date)
                                AND evt.course_end_date = fnd_date.canonical_to_date(:p_course_end_date)';
END IF;

IF (p_course_start_date IS NOT NULL AND p_course_end_date IS NULL) THEN
    p_and := p_and || ' AND evt.course_start_date = fnd_date.canonical_to_date(:p_course_start_date)';
END IF;

IF (p_course_start_date IS NULL AND p_course_end_date IS NOT NULL) THEN
    p_and := p_and || ' AND evt.course_end_date = fnd_date.canonical_to_date(:p_course_end_date)';
END IF;

IF p_training_center_id IS NOT NULL THEN
   p_and := p_and || ' AND evt.training_center_id = :p_training_center_id';
END IF;

IF p_booking_id IS NOT NULL THEN
   p_and := p_and || ' AND db.booking_id = :p_booking_id';
END IF;




open c_event(p_event_id );
fetch c_event into p_event_name ;
close c_event;


open c_training_center(p_training_center_id );
fetch c_training_center into p_training_center_name ;
close c_training_center;





RETURN(TRUE);

END;

function cf_venueformula
  (event_id in number) return char
is
begin

   select replace(name,fnd_global.local_chr(10),fnd_global.local_chr(46))
   into cp_venue
   from ota_suppliable_resources_tl sr,
        ota_resource_bookings rb
   where rb.event_id = cf_venueformula.event_id
      and rb.primary_venue_flag = 'Y'
      and sr.supplied_resource_id = rb.supplied_resource_id
      and sr.language = userenv('LANG') ;

   return(to_char(null));

exception
    when no_data_found then
        cp_venue := null;
        return(to_char(null));
end;

function CF_course_end_dateFormula return Char is
begin
  select fnd_date.date_to_displaydate(to_date(substr((p_course_end_date),1,10),'yyyy/mm/dd'))
  into cp_course_end_date
  from dual;

  return(to_char(null));
end;

function CF_course_start_dateFormula return Char is
begin
  select fnd_date.date_to_displaydate(to_date(substr((p_course_start_date),1,10),'yyyy/mm/dd'))
  into cp_course_start_date
  from dual;

  return(to_char(null));
end;

function cf_event_durationformula(course_end in date, course_start in date) return number is
begin
return (course_end-course_start) +1;

end;

function cf_sign4formula(CF_event_duration in number) return char is
begin

if (CF_event_duration < '5')  then
  return(P_OPTIONAL_COLUMN);
else
  return('Signature');
end if;

end;

function cf_sign3formula(CF_event_duration in number) return char is
begin
if (CF_event_duration < '4')  then
  return(P_OPTIONAL_COLUMN);
else
  return('Signature');
end if;


end;

function cf_sign2formula(CF_event_duration in number) return char is
begin
if (CF_event_duration < '3')  then
  return(P_OPTIONAL_COLUMN);
else
  return('Signature');
end if;


end;

function cf_sign1formula(CF_event_duration in number) return char is
begin
if (CF_event_duration < '2')  then
  return(P_OPTIONAL_COLUMN);
else
  return('Signature');
end if;


end;

function CF_BG_NAMEFormula return Char is
begin
c_business_group_name := hr_reports.get_business_group(p_business_group_id);
return(to_char(null));

end;

function AfterReport return boolean is
begin
    --hr_standard.event('AFTER REPORT') ;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_venue_p return varchar2 is
	Begin
	 return CP_venue;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_EVENT_TITLE_p return varchar2 is
	Begin
	 return C_EVENT_TITLE;
	 END;
 Function CP_course_start_date_p return varchar2 is
	Begin
	 return CP_course_start_date;
	 END;
 Function CP_course_end_date_p return varchar2 is
	Begin
	 return CP_course_end_date;
	 END;
END OTA_OTARPSIS_XMLP_PKG ;

/

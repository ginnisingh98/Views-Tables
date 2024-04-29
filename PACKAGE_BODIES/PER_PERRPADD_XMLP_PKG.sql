--------------------------------------------------------
--  DDL for Package Body PER_PERRPADD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPADD_XMLP_PKG" AS
/* $Header: PERRPADDB.pls 120.1 2007/12/06 11:27:40 amakrish noship $ */

function cf_addr_chkformula(gre_name in varchar2, person_id in number, CS_no_of_addr in number, address_id in number, add_date_to in date, effective_start_date in date, effective_end_date in date,
date_from in date, address_line1 in varchar2, location_address in varchar2, town_or_city in varchar2, address_line2 in varchar2, address_line3 in varchar2) return number is
begin
    if (CP_prev_gre_name <> gre_name) then
      CP_print_gre := 0;
  end if;

    if (CP_prev_person_id <> person_id
       or CP_prev_person_id is NULL) then
      CP_prev_person_id := NULL;
      CP_prev_date_to   := NULL;
      CP_keep_count   := 0;
      CP_missing_flag := 0;
      CP_reason := NULL;
      CP_reason1 := NULL;
      CP_addr_count := CS_no_of_addr;
  end if;
          if CP_addr_count = 0 then
    CP_prev_date_to := NULL;
    CP_addr_count := CS_no_of_addr;
    CP_keep_count := 0;
    CP_missing_flag := 0;
  end if;

  if address_id IS NOT NULL then
    CP_keep_count := CP_keep_count + 1;
  end if;

  CP_missing_st   := NULL;
  CP_missing_st1  := NULL;
  CP_missing_end  := NULL;
  CP_missing_end1 := NULL;


  if address_id = cp_old_address_id then
    cp_keep_count := 1;
    CP_addr_count := CP_addr_count -1 ;
    CP_prev_date_to := add_date_to;
    return (null);
  end if;


  if nvl(CS_no_of_addr, 0) = 0 then
    CP_missing_st   := effective_start_date;
    if effective_start_date <  input_start_date then
       CP_missing_st := input_start_date;
    end if;
    CP_missing_end  := effective_end_date;
    if effective_end_date >  input_end_date then
       CP_missing_end := input_end_date;
    end if;
    CP_missing_flag := 1;
    fnd_message.set_name('PER','PER_INV_ADD_NO_ADDRESS');
    CP_reason :=  fnd_message.get();
  end if;


   if CS_no_of_addr = 1 then

     if (date_from > effective_start_date) and
        (date_from > input_start_date)
     then
	  CP_missing_st := effective_start_date;
          if effective_start_date <  input_start_date then
             CP_missing_st := input_start_date;
          end if;
	  CP_missing_end := date_from - 1;
          if (date_from - 1) >  input_end_date then
             CP_missing_end := input_end_date;
          end if;
          CP_missing_flag := 1;
          fnd_message.set_name('PER','PER_INV_ADD_NO_WHOLE_PERIOD');
          CP_reason :=  fnd_message.get();

     end if;


     if (add_date_to < effective_end_date) and
        (add_date_to < input_end_date)
     then
	  CP_missing_st1 := add_date_to + 1;
          if (add_date_to + 1) <  input_start_date then
             CP_missing_st1 := input_start_date;
          end if;
	  CP_missing_end1 := effective_end_date;
          if effective_end_date >  input_end_date then
             CP_missing_end1 := input_end_date;
          end if;
          CP_missing_flag := 1;
          fnd_message.set_name('PER','PER_INV_ADD_NO_WHOLE_PERIOD');
          CP_reason1 :=  fnd_message.get();
     end if;
   end if;


    if CS_no_of_addr > 1 then

      if (CP_prev_date_to IS NULL) then
         if (date_from > effective_start_date) and
            (date_from > input_start_date) then
	     CP_missing_st := effective_start_date;
             if effective_start_date <  input_start_date then
                CP_missing_st := input_start_date;
             end if;
	     CP_missing_end := date_from - 1;
             if (date_from - 1) >  input_end_date then
                CP_missing_end := input_end_date;
             end if;
             CP_missing_flag := 1;
             fnd_message.set_name('PER','PER_INV_ADD_NO_WHOLE_PERIOD');
             CP_reason :=  fnd_message.get();
	 end if;

         if additional_verification = 'MMREF' then
           if (length(address_line1) > 22 OR
             length(location_address) > 22 OR
             length(town_or_city) > 22) then
             if CP_missing_st is NULL then
               if input_start_date > date_from then
                 CP_missing_st := input_start_date;
               else
                 CP_missing_st := date_from;
               end if;
               if input_end_date < add_date_to then
                 CP_missing_end := input_end_date;
               else
                 CP_missing_end := add_date_to;
               end if;
               fnd_message.set_name('PER','PER_INV_ADD_NON_MMREF');
               CP_reason :=  fnd_message.get();
             else
               if input_start_date > date_from then
                 CP_missing_st1 := input_start_date;
               else
                 CP_missing_st1 := date_from;
               end if;
               if input_end_date < add_date_to then
                 CP_missing_end1 := input_end_date;
               else
                 CP_missing_end1 := add_date_to;
               end if;
               fnd_message.set_name('PER','PER_INV_ADD_NON_MMREF');
               CP_reason1 :=  fnd_message.get();
             end if;
             CP_missing_flag := 1;
           end if;
         end if;



         if additional_verification = 'LENGTH' and line_length is not NULL then
           if (length(address_line1) > line_length or
               length(address_line2) > line_length or
               length(address_line3) > line_length) then
             if input_start_date > date_from then
               CP_missing_st := input_start_date;
             else
               CP_missing_st := date_from;
             end if;
             if input_end_date < add_date_to then
               CP_missing_end := input_end_date;
             else
               CP_missing_end := add_date_to;
             end if;
             CP_missing_flag := 1;
             fnd_message.set_name('PER','PER_INV_ADD_TOO_LONG');
             CP_reason :=  fnd_message.get();
           end if;
         end if;



      else

	  if (CP_prev_date_to >= date_from) then
	     CP_missing_st := date_from;
             if date_from <  input_start_date then
                CP_missing_st := input_start_date;
             end if;
	     CP_missing_end := CP_prev_date_to;
             if CP_prev_date_to >  input_end_date then
                CP_missing_end := input_end_date;
             end if;
             CP_missing_flag := 1;
             fnd_message.set_name('PER','PER_INV_ADD_OVERLAP');
             CP_reason :=  fnd_message.get();
	  else

	    if (CP_prev_date_to < date_from - 1) then
		CP_missing_st := CP_prev_date_to + 1;
                if (CP_prev_date_to + 1) <  input_start_date then
                   CP_missing_st := input_start_date;
                end if;
		CP_missing_end := date_from - 1;
                if (date_from - 1) >  input_end_date then
                   CP_missing_end := input_end_date;
                end if;
                CP_missing_flag := 1;
                fnd_message.set_name('PER','PER_INV_ADD_GAP_EXIST');
                CP_reason :=  fnd_message.get();
	    end if;
	  end if;

          if (CP_keep_count = CS_no_of_addr)    and
	     (add_date_to < effective_end_date) and
             (add_date_to < input_end_date)    then
	       CP_missing_st1 := add_date_to + 1;
               if (add_date_to + 1 ) <  input_start_date then
                  CP_missing_st1 := input_start_date;
               end if;
	       CP_missing_end1 := effective_end_date;
               if effective_end_date >  input_end_date then
                  CP_missing_end1 := input_end_date;
               end if;
               CP_missing_flag := 1;
               fnd_message.set_name('PER','PER_INV_ADD_NO_WHOLE_PERIOD');
               CP_reason1 :=  fnd_message.get();
          end if;
	end if;

    end if;



    if CP_missing_st is NULL then
     if additional_verification = 'MMREF' then
       if (length(address_line1) > 22 OR
           length(location_address) > 22 OR
           length(town_or_city) > 22) then
          if input_start_date > date_from then
             CP_missing_st := input_start_date;
          else
             CP_missing_st := date_from;
          end if;
          if input_end_date < add_date_to then
             CP_missing_end := input_end_date;
          else
             CP_missing_end := add_date_to;
          end if;
          CP_missing_flag := 1;
          fnd_message.set_name('PER','PER_INV_ADD_NON_MMREF');
          CP_reason :=  fnd_message.get();
       end if;
     end if;
    end if;




    if CP_missing_st is NULL then
     if additional_verification = 'LENGTH' and line_length is not NULL then
       if (length(address_line1) > line_length or
               length(address_line2) > line_length or
               length(address_line3) > line_length) then
          if input_start_date > date_from then
             CP_missing_st := input_start_date;
          else
             CP_missing_st := date_from;
          end if;
          if input_end_date < add_date_to then
             CP_missing_end := input_end_date;
          else
             CP_missing_end := add_date_to;
          end if;
          CP_missing_flag := 1;
          fnd_message.set_name('PER','PER_INV_ADD_TOO_LONG');
          CP_reason :=  fnd_message.get();
       end if;
     end if;
    end if;

    CP_prev_date_to := add_date_to;
    if cp_missing_flag = 1 and cp_print_gre = 0 then
       cp_print_gre := 1;
    end if;

    if cp_missing_flag = 1 and cp_print_gre is null then
       cp_print_gre := 1;
    end if;

    if cp_missing_flag <> 1 and cp_print_gre is null then
       cp_print_gre := 0;
    end if;

    CP_prev_person_id := person_id;
    CP_prev_gre_name  := gre_name;
    cp_old_address_id := address_id;
    CP_addr_count := CP_addr_count - 1;

    return(null);

end;

function INPUT_END_DATEValidTrigger return boolean is
begin
  if ((input_end_date IS NULL)
       OR (input_start_date > input_end_date) )
  then
     /*srw.message('101', 'Start Date cannot be greater than End Date');*/null;

     return (FALSE);
  else
     return (TRUE);
  end if;
RETURN NULL; end;

function INPUT_START_DATEValidTrigger return boolean is
begin
 if ((input_start_date IS NULL)
     or (input_start_date > input_end_date)) then

    /*srw.message('100', 'Start Date Cannot be greater than End Date');*/null;

    return(FALSE);
  else
    return (TRUE);
  end if;
RETURN NULL; end;

function AfterPForm return boolean
is



begin






  return (TRUE);
end;

function CF_gre_nameFormula return VARCHAR2
is

  cursor c_gre_name is
   select name
   from hr_organization_units
   where organization_id = gre_id;

 lv_gre_name hr_all_organization_units.name%TYPE;

begin

if gre_id IS not NULL then
   open c_gre_name;
   fetch c_gre_name into lv_gre_name;
   close c_gre_name;

else
   lv_gre_name := ' ';
end if;

   return(lv_gre_name);

end;

function CF_bus_grpFormula return VARCHAR2
is

 Cursor c_business_group is
  select name
  from per_business_groups
  where business_group_id = business_id;

 lv_business_group hr_all_organization_units.name%TYPE;

begin
if business_id IS NOT NULL then
   open c_business_group;
   fetch c_business_group into lv_business_group;
   close c_business_group;
else
   lv_business_group := ' ';
end if;

 return (lv_business_group);

end;

function BeforeReport return boolean is
begin
  LP_INPUT_START_DATE :=INPUT_START_DATE;
  LP_INPUT_END_DATE:=INPUT_END_DATE;
  --hr_standard.event('BEFORE REPORT');

  return (TRUE);
end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

function CF_header_notesFormula return Char is
begin
    if additional_verification = 'MMREF' then
    return (
   'Employees with an error "The address does not comply with MMREF-1 address length stndards and will be truncated" will not cause the file to be rejected by the SSA.' ||
   'This is a warning message that the employee''s address will be truncated to fit the layout standards.');
    else
      return(' ');
    end if;

end;

function ADDITIONAL_VERIFICATIONValidTr return boolean is
begin
    return (TRUE);
end;

function LINE_LENGTHValidTrigger return boolean is
begin
   return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_print_gre_p return number is
	Begin
	 return CP_print_gre;
	 END;
 Function CP_missing_flag_p return number is
	Begin
	 return CP_missing_flag;
	 END;
 Function CP_old_address_id_p return number is
	Begin
	 return CP_old_address_id;
	 END;
 Function CP_prev_person_id_p return number is
	Begin
	 return CP_prev_person_id;
	 END;
 Function CP_prev_name_p return varchar2 is
	Begin
	 return CP_prev_name;
	 END;
 Function CP_temp_id_p return number is
	Begin
	 return CP_temp_id;
	 END;
 Function CP_prev_gre_name_p return varchar2 is
	Begin
	 return CP_prev_gre_name;
	 END;
 Function CP_addr_count_p return number is
	Begin
	 return CP_addr_count;
	 END;
 Function CP_missing_st_p return date is
	Begin
	 return CP_missing_st;
	 END;
 Function CP_missing_end_p return date is
	Begin
	 return CP_missing_end;
	 END;
 Function CP_reason_p return varchar2 is
	Begin
	 return CP_reason;
	 END;
 Function CP_reason1_p return varchar2 is
	Begin
	 return CP_reason1;
	 END;
 Function CP_missing_st1_p return date is
	Begin
	 return CP_missing_st1;
	 END;
 Function CP_missing_end1_p return date is
	Begin
	 return CP_missing_end1;
	 END;
 Function CP_keep_count_p return number is
	Begin
	 return CP_keep_count;
	 END;
 Function CP_prev_date_to_p return date is
	Begin
	 return CP_prev_date_to;
	 END;
END PER_PERRPADD_XMLP_PKG ;

/

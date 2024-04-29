--------------------------------------------------------
--  DDL for Package Body PAY_PAYSGI21_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYSGI21_XMLP_PKG" AS
/* $Header: PAYSGI21B.pls 120.1 2008/04/02 10:04:30 vjaganat noship $ */

function CF_business_group_nameFormula return Char is
  v_business_group  hr_all_organization_units.name%type;
begin
  v_business_group := hr_reports.get_business_group(lp_business_group_id);
  return v_business_group;
end;

function cf_ir21a_total_basisformula(CS_ir21a_furniture_basis in number, CS_ir21a_furniture_basis_sub in number, CS_ir21a_hotel_basis in number, CS_ir21a_others_basis in number) return number is
begin
    return(CP_taxable_residence_basis +
         CS_ir21a_furniture_basis +
	 CS_ir21a_furniture_basis_sub +
         CS_ir21a_hotel_basis +
         CS_ir21a_others_basis);
end;

function cf_ir21a_total_basis_1formula(CS_ir21a_furniture_basis_1 in number, CS_ir21a_furniture_basis_sub1 in number, CS_ir21a_hotel_basis_1 in number, CS_ir21a_others_basis_1 in number) return number is
begin
    return(CP_taxable_residence_basis_1 +
         CS_ir21a_furniture_basis_1 +
	 CS_ir21a_furniture_basis_sub1 +
         CS_ir21a_hotel_basis_1 +
         CS_ir21a_others_basis_1);

end;

function cf_taxable_value_residenceform(CS_ir21_income_basis in number, CS_ir21_others_basis in number, CS_ir21a_furniture_basis in number, CS_ir21a_others_basis in number,
CS_a8a_moa_501_basis in number, CS_a8a_moa_502_basis in number, CS_ir21_income_basis_1 in number, CS_ir21_others_basis_1 in number, CS_ir21a_furniture_basis_1 in number,
CS_ir21a_others_basis_1 in number, CS_a8a_moa_501_basis_1 in number, CS_a8a_moa_502_basis_1 in number) return number is
begin


  cp_taxable_residence_basis :=
    greatest(least(0.1 * (CS_ir21_income_basis +
                          CS_ir21_others_basis +                                 CS_ir21a_furniture_basis +                             CS_ir21a_others_basis),                         CS_a8a_moa_501_basis
                   )
             - CS_a8a_moa_502_basis
             , 0);

  cp_taxable_residence_basis_1 :=
    greatest(least(0.1 * (CS_ir21_income_basis_1 +
                          CS_ir21_others_basis_1 +                                 CS_ir21a_furniture_basis_1 +                             CS_ir21a_others_basis_1),                         CS_a8a_moa_501_basis_1
                   )
             - CS_a8a_moa_502_basis_1
             , 0);



  return(0);
end;

function cf_ir21_subtotal_basisformula(CS_ir21_others_basis in number, CF_ir21a_total_basis in number) return number is
begin
  return(CS_ir21_others_basis + CP_CR_YEAR_AMOUNT + CF_ir21a_total_basis);
end;

function cf_ir21_subtotal_basis_1formul(CS_ir21_others_basis_1 in number, CF_ir21a_total_basis_1 in number) return number is
begin
  return(CS_ir21_others_basis_1 + CP_PR_YEAR_AMOUNT + CF_ir21a_total_basis_1);
end;

function cf_ir21_total_basisformula(CS_ir21_income_basis in number, CS_ir21_others_basis in number, CF_ir21a_total_basis in number) return number is
begin
  return(CS_ir21_income_basis +
         CS_ir21_others_basis +
	 CP_CR_YEAR_AMOUNT +
         CF_ir21a_total_basis);
end;

function cf_ir21_total_basis_1formula(CS_ir21_income_basis_1 in number, CS_ir21_others_basis_1 in number, CF_ir21a_total_basis_1 in number) return number is
begin
  return(CS_ir21_income_basis_1 +
         CS_ir21_others_basis_1 +
	 CP_PR_YEAR_AMOUNT +
         CF_ir21a_total_basis_1);
end;

function cf_ir21_cessation_datesformula(date_start in date, actual_termination_date in date) return number is
begin

  	cp_ir21_cessation_from := to_date('01-01-'||to_char(lp_basis_year),'dd-mm-yyyy');
	cp_ir21_cessation_from_1 := to_date('01-01-'||to_char(lp_basis_year-1),'dd-mm-yyyy');
	cp_ir21_cessation_from_2 := to_date('01-01-'||to_char(lp_basis_year-2),'dd-mm-yyyy');

	cp_ir21_cessation_to := to_date('31-12-'||to_char(lp_basis_year),'dd-mm-yyyy');
	cp_ir21_cessation_to_1 := to_date('31-12-'||to_char(lp_basis_year-1),'dd-mm-yyyy');
	cp_ir21_cessation_to_2 := to_date('31-12-'||to_char(lp_basis_year-2),'dd-mm-yyyy');

/*srw.message('1',1);*/null;

      if date_start >= to_date('01-01-'||to_char(lp_basis_year),'dd-mm-yyyy') AND
     date_start <= to_date('31-12-'||to_char(lp_basis_year),'dd-mm-yyyy')
  then
  	cp_ir21a_employ_from := date_start;
  else
 	cp_ir21a_employ_from := to_date('01-01-'||to_char(lp_basis_year),'dd-mm-yyyy');
  end if;
/*srw.message('2',2);*/null;

  if actual_termination_date >= to_date('01-01-'||to_char(lp_basis_year),'dd-mm-yyyy') AND
     actual_termination_date <= to_date('31-12-'||to_char(lp_basis_year),'dd-mm-yyyy')
  then
  	cp_ir21a_employ_to := actual_termination_date;
  else
  	cp_ir21a_employ_to := to_date('31-12-'||to_char(lp_basis_year),'dd-mm-yyyy');
  end if;

/*srw.message('3',3);*/null;

        if date_start >= to_date('01-01-'||to_char(lp_basis_year-1),'dd-mm-yyyy') AND
     date_start <= to_date('31-12-'||to_char(lp_basis_year-1),'dd-mm-yyyy')
  then
  	cp_ir21a_employ_from_1 := date_start;
  else
  	cp_ir21a_employ_from_1 := to_date('01-01-'||to_char(lp_basis_year-1),'dd-mm-yyyy');
  end if;

/*srw.message('4',4);*/null;

  if actual_termination_date >= to_date('01-01-'||to_char(lp_basis_year-1),'dd-mm-yyyy') AND
     actual_termination_date <= to_date('31-12-'||to_char(lp_basis_year-1),'dd-mm-yyyy')
  then
  	cp_ir21a_employ_to_1 := actual_termination_date;
  else
  	cp_ir21a_employ_to_1 := to_date('31-12-'||to_char(lp_basis_year-1),'dd-mm-yyyy');
  end if;

/*srw.message('5',5);*/null;

  if date_start >= to_date('01-01-'||to_char(lp_basis_year-2),'dd-mm-yyyy') AND
     date_start <= to_date('31-12-'||to_char(lp_basis_year-2),'dd-mm-yyyy')
  then
  	cp_ir21a_employ_from_2 := date_start;
  else
  	cp_ir21a_employ_from_2 := to_date('01-01-'||to_char(lp_basis_year-2),'dd-mm-yyyy');
  end if;

/*srw.message('6',6);*/null;

  if actual_termination_date >= to_date('01-01-'||to_char(lp_basis_year-2),'dd-mm-yyyy') AND
     actual_termination_date <= to_date('31-12-'||to_char(lp_basis_year-2),'dd-mm-yyyy')
  then
  	cp_ir21a_employ_to_2 := actual_termination_date;
  else
  	cp_ir21a_employ_to_2 := to_date('31-12-'||to_char(lp_basis_year-2),'dd-mm-yyyy');
  end if;

  return (0);
end;

function CF_ir21_dateFormula return Date is
  v_ir21_date        date;
begin
	  select max(to_date(pei_information1,'yyyy/mm/dd hh24:mi:ss'))
  into v_ir21_date
  from per_people_extra_info
  --where person_id = p_person_id
  where person_id = lp_person_id
  and   information_type = 'HR_IR21_PROCESSING_DATES_SG';

  return(v_ir21_date);
end;

function CF_child_seqFormula return Number is
begin

  if (CP_child_seq is null) then
  	CP_child_seq := 0;
  end if;

  CP_child_seq := CP_child_seq + 1;
  return(0);
end;

function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;
--raise_application_error(-20001,'lp_basis_year : '||lp_basis_year);
--insert into log_sam values ('sampath','paysgi21i','lp_basis_year',lp_basis_year);
select SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3)),
SUBSTR(argument4,INSTR(argument4,'=',1)+1,LENGTH(argument4)),
SUBSTR(argument5,INSTR(argument5,'=',1)+1,LENGTH(argument5)),
SUBSTR(argument6,INSTR(argument6,'=',1)+1,LENGTH(argument6)),
SUBSTR(argument7,INSTR(argument7,'=',1)+1,LENGTH(argument7)),
SUBSTR(argument8,INSTR(argument8,'=',1)+1,LENGTH(argument8))
into
LP_BUSINESS_GROUP_ID,
Lp_basis_year,
LP_PERSON_ID,
LP_IR21_MODE,
LP_CR_YEAR_AMOUNT,
LP_PR_YEAR_AMOUNT,
t_run,
DebugFlag
from FND_CONCURRENT_REQUESTS
where request_id = FND_GLOBAL.conc_request_id;

  return (TRUE);
end;

function AfterReport return boolean IS
 l number;

begin

  /*srw.user_exit('FND SRWEXIT');*/null;




set_ir21_date;



  return (TRUE);
end;

function cf_end_of_reportformula(cs_no_data_exists in number) return char is
begin
  If cs_no_data_exists > 0 then
  	--return '***** End Of Report *****';
  	return ' End of Report ';
  end if;

	--return '***** No Data Found *****';
	return 'No Data Found';
end;

function cf_ir21_totalformula(CF_ir21_total_basis in number, CF_ir21_total_basis_1 in number) return number is
begin
  return(CF_ir21_total_basis +
         CF_ir21_total_basis_1);

end;

--function cf_pay_basisformula(organization_id in varchar2, person_id in number, actual_termination_date in date) return char is
function cf_pay_basisformula(organization_id_v in varchar2, person_id in number, actual_termination_date in date) return char is
  v_pay_basis   hr_lookups.meaning%TYPE;

    cursor c_pay_basis is
  select hl.meaning pay_basis
  from hr_organization_units hou,
       hr_soft_coding_keyflex hsc,
       per_assignments_f paaf,
       per_pay_bases ppb,
       hr_lookups hl
  where to_char(hou.organization_id) = hsc.segment1
  and   hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
  and   paaf.pay_basis_id = ppb.pay_basis_id
  and   ppb.pay_basis = hl.lookup_code
  and   hl.lookup_type = 'PAY_BASIS'
  --and   hou.organization_id = organization_id
  and   hou.organization_id = organization_id_V
  and   paaf.person_id = person_id
  and   actual_termination_date between paaf.effective_start_date and paaf.effective_end_date
  and   paaf.primary_flag = 'Y';
begin
  open c_pay_basis;
  fetch c_pay_basis into v_pay_basis;

  if c_pay_basis%NOTFOUND then
  	v_pay_basis := 'Monthly Salary';     end if;

  close c_pay_basis;

  return(v_pay_basis);
end;

function cf_employer_premiseformula(person_id in number) return number is

  cursor c_employer_premise is
  select decode(sign(fnd_date.canonical_to_date(ppeo.pei_information1) -
                     to_date('1/1/'||to_char(yrtbl.yr),'dd/mm/yyyy')),
                -1, to_date('1/1/'||to_char(yrtbl.yr),'dd/mm/yyyy'),
                fnd_date.canonical_to_date(ppeo.pei_information1)) from_date,
         decode(sign(fnd_date.canonical_to_date(ppeo.pei_information2) -
                     to_date('31/12/'||to_char(yrtbl.yr),'dd/mm/yyyy')),
                -1, fnd_date.canonical_to_date(ppeo.pei_information2),
                to_date('31/12/'||to_char(yrtbl.yr),'dd/mm/yyyy')) to_date,
         ppeo.pei_information3 no_days,
         ppeo.pei_information4 no_employees,
         yrtbl.yr yr
  from per_people_extra_info ppeo,
       (select (lp_basis_year) yr from dual union
        select (lp_basis_year - 1) yr from dual union
        select (lp_basis_year - 2) yr from dual) yrtbl
  where ppeo.person_id = person_id
  and   ppeo.information_type = 'HR_IR21A_CESSATION_INFO_SG'
  and   fnd_date.canonical_to_date(ppeo.pei_information1) =
          (select max(fnd_date.canonical_to_date(ppeo2.pei_information1))
           from per_people_extra_info ppeo2
           where ppeo.person_id = ppeo2.person_id
           and   ppeo2.information_type = 'HR_IR21A_CESSATION_INFO_SG'
           and   fnd_date.canonical_to_date(ppeo2.pei_information1) <=
                 to_date('31-12-'||to_char(yrtbl.yr),'dd-mm-yyyy')
           and   nvl(fnd_date.canonical_to_date(ppeo2.pei_information2),to_date('31/12/4712','dd/mm/yyyy')) >=
                  to_date('1-01-'||to_char(yrtbl.yr),'dd-mm-yyyy')
          );
begin

  for c_rec in c_employer_premise loop
    if c_rec.yr = lp_basis_year then

      cp_date_premise_from := c_rec.from_date;
      cp_date_premise_to := c_rec.to_date;
      cp_days_occupying_premise := c_rec.no_days;
      cp_emps_sharing_premise := c_rec.no_employees;

    elsif c_rec.yr = lp_basis_year - 1 then

      cp_date_premise_from_1 := c_rec.from_date;
      cp_date_premise_to_1 := c_rec.to_date;
      cp_days_occupying_premise_1 := c_rec.no_days;
      cp_emps_sharing_premise_1 := c_rec.no_employees;

    elsif c_rec.yr = lp_basis_year - 2 then

      cp_date_premise_from_2 := c_rec.from_date;
      cp_date_premise_to_2 := c_rec.to_date;
      cp_days_occupying_premise_2 := c_rec.no_days;
      cp_emps_sharing_premise_2 := c_rec.no_employees;

    end if;

  end loop;

  return(0);
end;

PROCEDURE set_ir21_date IS

  v_ir21_date_exists    boolean := FALSE;

  cursor c_ir21_dates is
  select fnd_date.canonical_to_date(pei_information1) ir21_date
  from per_people_extra_info ppeo
  --where ppeo.person_id = lp_person_id
  where ppeo.person_id = lp_person_id
  and   information_type = 'HR_IR21_PROCESSING_DATES_SG'
  and   fnd_date.canonical_to_date(pei_information1) = trunc(sysdate);

BEGIN

  for c_rec in c_ir21_dates loop
    v_ir21_date_exists := TRUE;
    exit;
  end loop;

  if v_ir21_date_exists = FALSE then
    insert into per_people_extra_info (
      person_extra_info_id,
      person_id,
      information_type,
      pei_information_category,
      pei_information1,
      object_version_number,
      last_update_date,
      creation_date
    )
    values (
      per_people_extra_info_s.nextval,
      --p_person_id,
      lp_person_id,
      'HR_IR21_PROCESSING_DATES_SG',
      'HR_IR21_PROCESSING_DATES_SG',
      fnd_date.date_to_canonical(trunc(sysdate)),
      1,
      sysdate,
      sysdate
    );

    commit;
  end if;

END set_ir21_date;

function CF_stock_outstandingFormula (date_start in date,actual_termination_date in date,organization_id in varchar2)return Number is

v_granted   per_people_extra_info.pei_information4%type;
v_exercised per_people_extra_info.pei_information6%type;

cursor c_granted is
select
sum(pei2.pei_information4)
from  per_people_extra_info pei2
--where pei2.person_id = lp_person_id
where pei2.person_id = lp_person_id
and   pei2.information_type = 'HR_STOCK_GRANT_SG'
and   to_date(pei2.pei_information3,'YYYY/MM/DD HH24:MI:SS')< to_date('01/01/2003','DD/MM/YYYY')
group by pei2.person_id;

cursor c_exercised is
select sum(pei.pei_information6)
from per_people_extra_info pei,
     per_people_extra_info pei2
--where pei.person_id = p_person_id
where pei.person_id = lp_person_id
and   pei.person_id = pei2.person_id
and   pei.information_type = 'HR_STOCK_EXERCISE_SG'
and   pei2.information_type = 'HR_STOCK_GRANT_SG'
and   pei2.person_extra_info_id = pei.pei_information2
and   to_date(pei2.pei_information3,'YYYY/MM/DD HH24:MI:SS')< to_date('01/01/2003','DD/MM/YYYY')
group by pei.person_id;

begin

  cp_outstanding_yes := ' ';
  cp_outstanding_no  := 'X';
  cp_cr_year_amount := 0;
  cp_pr_year_amount := 0;

--  if latest_le(organization_id,date_start,actual_termination_date) hen
  if latest_le(organization_id,date_start,actual_termination_date) Then
     open c_granted;
     fetch c_granted into v_granted;

     if c_granted%FOUND then
        open c_exercised;
        fetch c_exercised into v_exercised;

        if c_exercised%FOUND then
           if v_granted - v_exercised > 0 then
   	      cp_outstanding_yes := 'X';
	      cp_outstanding_no  := ' ';
           end if;
        else
           cp_outstanding_yes := 'X';
           cp_outstanding_no  := ' ';
        end if;

        close c_exercised;
     end if;
     close c_granted;

     cp_cr_year_amount := nvl(lp_cr_year_amount,0);
     cp_pr_year_amount := nvl(lp_pr_year_amount,0);

  end if;

  return(0);

end;


function latest_le(organization_id in varchar2, date_start in date, actual_termination_date in date) return boolean is

v_dummy number(1);
--cursor latest_le(organization_id,date_start,actual_termination_date) s
cursor latest_le(organization_id  varchar2,date_start   date,actual_termination_date  date) is
    select 1
    from   per_assignments_f paf,
           hr_soft_coding_keyflex hsc
    --where  paf.person_id = p_person_id
    where  paf.person_id = lp_person_id
    and    paf.business_group_id = lp_business_group_id
    and    paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    and    hsc.segment1 = organization_id
    and    paf.primary_flag = 'Y'
    and    paf.effective_start_date =
         (select max(paf1.effective_start_date)
          from   per_assignments_f paf1,
                 per_assignment_status_types past
          where  paf1.person_id = paf.person_id
          and    paf1.assignment_status_type_id = past.assignment_status_type_id
          and    past.per_system_status = 'ACTIVE_ASSIGN'
          and    paf1.assignment_type = 'E'
          and    paf1.effective_start_date <= to_date('31/12/'||lp_basis_year,'DD/MM/YYYY')
          and    paf1.effective_end_date >= to_date('01/01/'||lp_basis_year,'DD/MM/YYYY')
          and    paf1.primary_flag='Y')
    and    paf.effective_start_date <= to_date('31/12/'||lp_basis_year,'DD/MM/YYYY')
    and    paf.effective_end_date >= to_date('01/01/'||lp_basis_year,'DD/MM/YYYY')
    and     paf.effective_start_date between date_start and actual_termination_date;
BEGIN

   --open latest_le(organization_id,date_start,actual_termination_date)
   open latest_le(organization_id,date_start,actual_termination_date);
   --fetch latest_le(organization_id,date_start,actual_termination_date) nto v_dummy;
   fetch latest_le INTO v_dummy;

   if latest_LE%found then
     --close latest_le(organization_id,date_start,actual_termination_date)
     close latest_le;
     return TRUE;
   else
     --close latest_le(organization_id,date_start,actual_termination_date)
     close latest_le;
     return FALSE;

   end if;

END;

function P_CR_YEAR_AMOUNTValidTrigger return boolean is
begin

  return (TRUE);
end;

function P_PR_YEAR_AMOUNTValidTrigger return boolean is
begin

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_outstanding_stocks_p return number is
	Begin
	 return CP_outstanding_stocks;
	 END;
 Function CP_outstanding_no_p return varchar2 is
	Begin
	 return CP_outstanding_no;
	 END;
 Function CP_outstanding_yes_p return varchar2 is
	Begin
	 return CP_outstanding_yes;
	 END;
 Function CP_cr_year_amount_p return number is
	Begin
	 return CP_cr_year_amount;
	 END;
 Function CP_pr_year_amount_p return number is
	Begin
	 return CP_pr_year_amount;
	 END;
 Function CP_taxable_residence_basis_p return number is
	Begin
	 return CP_taxable_residence_basis;
	 END;
 Function CP_taxable_residence_basis_1_p return number is
	Begin
	 return CP_taxable_residence_basis_1;
	 END;
 Function CP_taxable_residence_basis_2_p return number is
	Begin
	 return CP_taxable_residence_basis_2;
	 END;
 Function CP_ir21_cessation_from_p return date is
	Begin
	 return CP_ir21_cessation_from;
	 END;
 Function CP_ir21_cessation_to_p return date is
	Begin
	 return CP_ir21_cessation_to;
	 END;
 Function CP_ir21_cessation_from_1_p return date is
	Begin
	 return CP_ir21_cessation_from_1;
	 END;
 Function CP_ir21_cessation_to_1_p return date is
	Begin
	 return CP_ir21_cessation_to_1;
	 END;
 Function CP_ir21_cessation_from_2_p return date is
	Begin
	 return CP_ir21_cessation_from_2;
	 END;
 Function CP_ir21_cessation_to_2_p return date is
	Begin
	 return CP_ir21_cessation_to_2;
	 END;
 Function CP_ir21a_employ_from_p return date is
	Begin
	 return CP_ir21a_employ_from;
	 END;
 Function CP_ir21a_employ_to_p return date is
	Begin
	 return CP_ir21a_employ_to;
	 END;
 Function CP_ir21a_employ_from_1_p return date is
	Begin
	 return CP_ir21a_employ_from_1;
	 END;
 Function CP_ir21a_employ_to_1_p return date is
	Begin
	 return CP_ir21a_employ_to_1;
	 END;
 Function CP_ir21a_employ_from_2_p return date is
	Begin
	 return CP_ir21a_employ_from_2;
	 END;
 Function CP_ir21a_employ_to_2_p return date is
	Begin
	 return CP_ir21a_employ_to_2;
	 END;
 Function CP_date_premise_from_p return date is
	Begin
	 return CP_date_premise_from;
	 END;
 Function CP_date_premise_from_1_p return date is
	Begin
	 return CP_date_premise_from_1;
	 END;
 Function CP_date_premise_from_2_p return date is
	Begin
	 return CP_date_premise_from_2;
	 END;
 Function CP_date_premise_to_p return date is
	Begin
	 return CP_date_premise_to;
	 END;
 Function CP_date_premise_to_1_p return date is
	Begin
	 return CP_date_premise_to_1;
	 END;
 Function CP_date_premise_to_2_p return date is
	Begin
	 return CP_date_premise_to_2;
	 END;
 Function CP_days_occupying_premise_p return varchar2 is
	Begin
	 return CP_days_occupying_premise;
	 END;
 Function CP_days_occupying_premise_1_p return varchar2 is
	Begin
	 return CP_days_occupying_premise_1;
	 END;
 Function CP_days_occupying_premise_2_p return varchar2 is
	Begin
	 return CP_days_occupying_premise_2;
	 END;
 Function CP_emps_sharing_premise_p return varchar2 is
	Begin
	 return CP_emps_sharing_premise;
	 END;
 Function CP_emps_sharing_premise_1_p return varchar2 is
	Begin
	 return CP_emps_sharing_premise_1;
	 END;
 Function CP_emps_sharing_premise_2_p return varchar2 is
	Begin
	 return CP_emps_sharing_premise_2;
	 END;
 Function CP_child_seq_p return number is
	Begin
	 return CP_child_seq;
	 END;
END PAY_PAYSGI21_XMLP_PKG ;

/

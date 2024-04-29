--------------------------------------------------------
--  DDL for Package Body HR_PL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PL_UTILITY" as
/* $Header: peplutil.pkb 120.7.12010000.4 2009/12/18 10:56:25 bkeshary ship $ */
--------------------------------------------------------------------------------
-- FUNCTION per_pl_full_name
--------------------------------------------------------------------------------
FUNCTION per_pl_full_name(
                p_first_name        IN VARCHAR2
               ,p_middle_names      IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2)
    RETURN VARCHAR2 IS
        --
        l_full_name  VARCHAR2(240);
        --
    BEGIN
        --
        SELECT SUBSTR(LTRIM(RTRIM(
              DECODE(p_last_name, NULL, '',p_last_name)
              ||DECODE(p_first_name,NULL, '',' ' || p_first_name)
              ||DECODE(p_middle_names,NULL, '', ' ' || p_middle_names)
              ||DECODE(p_title,NULL, '', ' ' || p_title)
              )), 1, 240)
        INTO   l_full_name
        FROM   dual;
RETURN(l_full_name);
        --
END per_pl_full_name;
--------------------------------------------------------------------------------
-- FUNCTION per_pl_order_name
--------------------------------------------------------------------------------
FUNCTION per_pl_order_name(
                p_first_name        IN VARCHAR2
               ,p_middle_names      IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2)
    RETURN VARCHAR2 IS
        --
        l_order_name  VARCHAR2(240);
        --
    BEGIN
        --
         SELECT SUBSTR(LTRIM(RTRIM(
              DECODE(p_last_name, NULL, '',p_last_name)
              ||DECODE(p_first_name,NULL, '',' ' || p_first_name)
              ||DECODE(p_middle_names,NULL, '', ' ' || p_middle_names)
              ||DECODE(p_title,NULL, '', ' ' || p_title)
              )), 1, 240)
        INTO   l_order_name
        FROM   dual;
RETURN(l_order_name);
        --
END per_pl_order_name;

--------------------------------------------------------------------------------
-- FUNCTION per_pl_chk_valid_date
--------------------------------------------------------------------------------

 FUNCTION per_pl_chk_valid_date (p_date IN VARCHAR2) RETURN VARCHAR2 IS

   l_century number;
   l_month number;
   l_birth_date number;
   l_birth_year number;
   l_birth_month number;
   l_birth_day varchar2(20);

 BEGIN

      l_month := to_number(substr(p_date,3,2));

         if l_month>=1 AND l_month<=12 then
            l_century:=1900;
         end if;
         if l_month>=81 AND l_month<=92 then
             l_century:=1800;
             l_month:=l_month-80;
         end if;
         if l_month>=21 AND l_month<=32 then
             l_century:=2000;
             l_month:=l_month-20;
         end if;
         if l_month>=41 AND l_month<=52 then
             l_century:=2100;
             l_month:=l_month-40;
         end if;
         if l_month>=61 AND l_month<=72 then
             l_century:=2200 ;
       	     l_month:=l_month-60;
         end if;

          l_birth_year:=to_number(substr(p_date,1,2));
	  l_birth_year:=l_century+l_birth_year;
  	  l_birth_month:=l_month;
	  l_birth_date:=to_number(substr(p_date,5,2));
	  l_birth_day:=to_char(to_date(lpad(l_birth_date,2,0)||lpad(l_birth_month,2,0)||l_birth_year,'DDMMRRRR'),'DD-MON-RRRR');

	return l_birth_day;

 exception
 	when others then
	return '0';
 end per_pl_chk_valid_date;
--------------------------------------------------------------------------------
--Procedure per_pl_nip_validate
--------------------------------------------------------------------------------
procedure per_pl_nip_validate (
   p_nip_number          in   varchar2,
   p_person_id           in   number,
   p_business_group_id   in   number,
   p_legal_employer      in   varchar2,
   p_nationality         in   varchar2,
   p_citizenship         in   varchar2
) is
   nip_sum          number;

   type v_nip is table of number
      index by binary_integer;

   nip_number       v_nip;
   nip_number_dup   per_all_people_f.per_information1%type;

   cursor nip is
      select per_information1
        from per_all_people_f ppf
       where ppf.business_group_id = p_business_group_id
         and ppf.person_id <> nvl (p_person_id, 0)
         and ppf.per_information1 = p_nip_number
         and ppf.per_information7 = p_legal_employer
         and ppf.nationality      = 'PQH_PL'
         and ppf.per_information8 = 'PL' ;
begin
   nip_sum := 0;
  /* Introduced an Additional check to ensure the NIP is not NULL*/
  IF p_nip_number IS NOT NULL THEN

   if p_nationality = 'PQH_PL' and p_citizenship = 'PL' then
      begin
         if length (p_nip_number) > 10 then
            fnd_message.set_name ('PER', 'HR_NIP_INVALID_NUMBER_PL');
            fnd_message.raise_error;
         end if;

         if to_number (p_nip_number) = 0 then
            fnd_message.set_name ('PER', 'HR_NIP_INVALID_NUMBER_PL');
            fnd_message.raise_error;
         end if;

         nip_number (1) := 6 * (to_number (substr (p_nip_number, 1, 1)));
         nip_number (2) := 5 * (to_number (substr (p_nip_number, 2, 1)));
         nip_number (3) := 7 * (to_number (substr (p_nip_number, 3, 1)));
         nip_number (4) := 2 * (to_number (substr (p_nip_number, 4, 1)));
         nip_number (5) := 3 * (to_number (substr (p_nip_number, 5, 1)));
         nip_number (6) := 4 * (to_number (substr (p_nip_number, 6, 1)));
         nip_number (7) := 5 * (to_number (substr (p_nip_number, 7, 1)));
         nip_number (8) := 6 * (to_number (substr (p_nip_number, 8, 1)));
         nip_number (9) := 7 * (to_number (substr (p_nip_number, 9, 1)));
         nip_number (10) := to_number (substr (p_nip_number, 10, 1));
         nip_sum := mod (
                       (nip_number (1) + nip_number (2) + nip_number (3)
                        + nip_number (4) + nip_number (5) + nip_number (6)
                        + nip_number (7) + nip_number (8) + nip_number (9)
                       ),
                       11
                    );

         if nip_sum = 10 then
            if nip_number (10) <> 0 then
               fnd_message.set_name ('PER', 'HR_NIP_INVALID_NUMBER_PL');
               fnd_message.raise_error;
            end if;
         elsif nip_sum <> nip_number (10) then
            fnd_message.set_name ('PER', 'HR_NIP_INVALID_NUMBER_PL');
            fnd_message.raise_error;
         end if;

         -- Uniqueness Check at legal employer level for Polish Persons
         if p_nip_number is not null and p_business_group_id is not null then
            open nip;
            fetch nip into nip_number_dup;

            if nip_number_dup = p_nip_number then
               fnd_message.set_name ('PER', 'HR_NIP_UNIQUE_NUMBER_PL');
               fnd_message.raise_error;
            end if;

            close nip;
         end if;
      exception
         when value_error then
            fnd_message.set_name ('PER', 'HR_NIP_INVALID_NUMBER_PL');
            fnd_message.raise_error;
      end;
   elsif nvl (p_nationality, '-1') <> 'PQH_PL' or nvl (p_citizenship, '-1') <>
                                                                          'PL' then
      begin
         if length (p_nip_number) <> 10 then
            hr_utility.set_message (800, 'HR_375890_NIP_NON_POLISH_PL');
            hr_utility.set_warning;
         end if;

         if to_number (p_nip_number) = 0 then
            hr_utility.set_message (800, 'HR_375890_NIP_NON_POLISH_PL');
            hr_utility.set_warning;
         end if;

         nip_number (1) := 6 * (to_number (substr (p_nip_number, 1, 1)));
         nip_number (2) := 5 * (to_number (substr (p_nip_number, 2, 1)));
         nip_number (3) := 7 * (to_number (substr (p_nip_number, 3, 1)));
         nip_number (4) := 2 * (to_number (substr (p_nip_number, 4, 1)));
         nip_number (5) := 3 * (to_number (substr (p_nip_number, 5, 1)));
         nip_number (6) := 4 * (to_number (substr (p_nip_number, 6, 1)));
         nip_number (7) := 5 * (to_number (substr (p_nip_number, 7, 1)));
         nip_number (8) := 6 * (to_number (substr (p_nip_number, 8, 1)));
         nip_number (9) := 7 * (to_number (substr (p_nip_number, 9, 1)));
         nip_number (10) := to_number (substr (p_nip_number, 10, 1));
         nip_sum := mod (
                       (nip_number (1) + nip_number (2) + nip_number (3)
                        + nip_number (4) + nip_number (5) + nip_number (6)
                        + nip_number (7) + nip_number (8) + nip_number (9)
                       ),
                       11
                    );

         if nip_sum = 10 then
            if nip_number (10) <> 0 then
               hr_utility.set_message (800, 'HR_375890_NIP_NON_POLISH_PL');
               hr_utility.set_warning;
            end if;
         elsif nip_sum <> nip_number (10) then
            hr_utility.set_message (800, 'HR_375890_NIP_NON_POLISH_PL');
            hr_utility.set_warning;
         end if;

         if length (p_nip_number) > 30 then
            fnd_message.set_name ('PER', 'HR_375887_NIP_LENGTH_PL');
            fnd_message.raise_error;
         end if; -- End if of NIP Length Check
      exception
         when value_error then
            hr_utility.set_message (800, 'HR_375890_NIP_NON_POLISH_PL');
            hr_utility.set_warning;
      end;
   end if; -- End if of Nationality and Citizenship Check
 End IF; -- End If for not null check
end per_pl_nip_validate;


PROCEDURE per_pl_chk_gender(nat_id varchar2,gender IN OUT NOCOPY varchar2) is
    l_gender varchar2(20);
    l_var number;
    begin
     l_gender:=substr(nat_id,10,1);
     l_var:=mod(l_gender,2);
 	if(gender is null or gender ='U') then
	     if(l_var=0) then
		gender:='F';
	      elsif(l_var=1) then
		gender:='M';
	     end if;
	else
      	   if(l_var=0 and gender='F') or (l_var=1 and gender='M') then
	      null;
	   else
	      gender:='0';
	   end if;
	end if;
end per_pl_chk_gender;

Procedure per_pl_validate(pesel varchar2) is

   Y1 number;
   Y2 number;
   M3 number;
   M4 number;
   D5 number;
   D6 number;
   A7 number;
   A8 number;
   A9 number;
   S10 number;
   C11 number;
   V1 number;
   V2 number;
   V3 number;
 BEGIN

 if (hr_ni_chk_pkg.chk_nat_id_format(pesel,'DDDDDDDDDDD') = 0) then
     fnd_message.set_name('PER','HR_PL_INVALID_NATIONAL_ID');
     fnd_message.raise_error;
 else
Y1:=to_number(substr(pesel,1,1));
Y2:=to_number(substr(pesel,2,1));
M3:=to_number(substr(pesel,3,1));
M4:=to_number(substr(pesel,4,1));
D5:=to_number(substr(pesel,5,1));
D6:=to_number(substr(pesel,6,1));
A7:=to_number(substr(pesel,7,1));
A8:=to_number(substr(pesel,8,1));
A9:=to_number(substr(pesel,9,1));
S10:=to_number(substr(pesel,10,1));
C11:=to_number(substr(pesel,11,1));

V1:=((1*Y1)+(3*Y2)+(7*M3)+(9*M4)+(1*D5)+(3*D6)+(7*A7)+(9*A8)+(1*A9)+(3*S10));

V2:=MOD(V1,10);

    if V2 = 0 then
       V3:=0;
    else
       V3:=10-V2;
     end if;

     if C11 <> V3 then
        fnd_message.set_name('PER','HR_PL_INVALID_NATIONAL_ID');
        fnd_message.raise_error;
     end if;
end if;

end per_pl_validate;

FUNCTION validate_bank_id(p_bank_id varchar2) RETURN NUMBER IS
B3 number;
B4 number;
B5 number;
B6 number;
B7 number;
B8 number;
B9 number;
B10 number;
CB10 number;
l_var1 number;

BEGIN
B3:=substr(p_bank_id,1,1);
B4:=substr(p_bank_id,2,1);
B5:=substr(p_bank_id,3,1);
B6:=substr(p_bank_id,4,1);
B7:=substr(p_bank_id,5,1);
B8:=substr(p_bank_id,6,1);
B9:=substr(p_bank_id,7,1);
B10:=substr(p_bank_id,8,1);

 IF  hr_ni_chk_pkg.chk_nat_id_format(p_bank_id,'DDDDDDDD')= '0' THEN
       --Invalid Format
       return 0;
 end if;

l_var1:=(3*B3)+(9*B4)+(7*B5)+(1*B6)+(3*B7)+(9*B8)+(7*B9);
l_var1:=mod(l_var1,10);

if l_var1=0 then
 CB10:=0;
else
 CB10:=10-l_var1;
end if;

if B10 <> CB10 then  -- validation of Bank ID (entered b10 with the calculated check digit b10)
 return 0;
end if;

return 1;

end validate_bank_id;


FUNCTION validate_account_no(p_check_digit VARCHAR2
                            ,p_bank_id      VARCHAR2
                            ,p_account_number   VARCHAR2
                            )RETURN NUMBER IS
acc_no varchar2(100);
C1 number;
C2 number;
B3 number;
B4 number;
B5 number;
B6 number;
B7 number;
B8 number;
B9 number;
B10 number;
A11 number;
A12 number;
A13 number;
A14 number;
A15 number;
A16 number;
A17 number;
A18 number;
A19 number;
A20 number;
A21 number;
A22 number;
A23 number;
A24 number;
A25 number;
A26 number;
CB10 number;
CC number;
l_var1 number;


begin

C1:=substr(p_check_digit,1,1);
C2:=substr(p_check_digit,2,1);
B3:=substr(p_bank_id,1,1);
B4:=substr(p_bank_id,2,1);
B5:=substr(p_bank_id,3,1);
B6:=substr(p_bank_id,4,1);
B7:=substr(p_bank_id,5,1);
B8:=substr(p_bank_id,6,1);
B9:=substr(p_bank_id,7,1);
B10:=substr(p_bank_id,8,1);
A11:=substr(p_account_number,1,1);
A12:=substr(p_account_number,2,1);
A13:=substr(p_account_number,3,1);
A14:=substr(p_account_number,4,1);
A15:=substr(p_account_number,5,1);
A16:=substr(p_account_number,6,1);
A17:=substr(p_account_number,7,1);
A18:=substr(p_account_number,8,1);
A19:=substr(p_account_number,9,1);
A20:=substr(p_account_number,10,1);
A21:=substr(p_account_number,11,1);
A22:=substr(p_account_number,12,1);
A23:=substr(p_account_number,13,1);
A24:=substr(p_account_number,14,1);
A25:=substr(p_account_number,15,1);
A26:=substr(p_account_number,16,1);

acc_no:=p_check_digit||p_bank_id||p_account_number;


 IF  hr_ni_chk_pkg.chk_nat_id_format(acc_no,'DDDDDDDDDDDDDDDDDDDDDDDDDD')= '0' THEN
       --Invalid Format
       return 0;
 end if;

l_var1:=(57*B3)+(93*B4)+(19*B5)+(31*B6)+(71*B7)+(75*B8)+(56*B9)+(25*B10)+(51*A11)+(73*A12)+(17*A13)+(89*A14)+(38*A15)+(62*A16)+(45*A17)+(53*A18)+(15*A19)+(50*A20)+(5*A21)+(49*A22)+(34*A23)+(81*A24)+(76*A25)+(27*A26)+(90*2)+(9*5)+(30*2)+(3*1);
l_var1:=98-mod(l_var1,97);

CC:=C1*10+C2;

if l_var1 <> CC then  --validation of Full Bank Acc Number(entered C1C2 eith calculated C1C1)
 return 0;
end if;

return 1;

end validate_account_no;

----
-- Function added for IBAN Validation
----
FUNCTION validate_iban_acc(p_account_no VARCHAR2)RETURN NUMBER IS
BEGIN
     IF IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) = 1 then
     RETURN 1;
     else
     RETURN 0;
     END IF;
END validate_iban_acc;

----
-- This function will get called from the bank keyflex field segments
----
FUNCTION validate_account_entered
(p_acc_no        			IN VARCHAR2,
 p_is_iban_acc   			IN varchar2,
 p_bank_chk_dig     	IN varchar2 DEFAULT NULL,
 p_bank_id            IN Varchar2 DEFAULT NULL) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
--   hr_utility.trace_on(null,'ACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_account_number ' || p_acc_no,1);

  IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') then
    l_ret := validate_account_no(p_bank_chk_dig, p_bank_id, p_acc_no);
    hr_utility.set_location('l_ret ' || l_ret,1);
    RETURN l_ret;
  ELSIF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'Y') then
    l_ret := validate_iban_acc(p_acc_no);
    hr_utility.set_location('l_ret ' || l_ret,3);
    RETURN l_ret;
  ELSIF (p_acc_no IS NULL AND p_is_iban_acc IS NULL) then
    hr_utility.set_location('Both Account Nos Null',4);
    RETURN 1;
  ELSE
    hr_utility.set_location('l_ret: 3 ' ,5);
    RETURN 3;
  END if;
End validate_account_entered;


--------------------------------------------------------------------------------
--                  Procedure per_pl_calc_periods                             --
--------------------------------------------------------------------------------
PROCEDURE per_pl_calc_periods(p_start_date IN DATE,
					  p_end_date IN DATE,
					  p_days IN OUT NOCOPY NUMBER,
			          p_months IN OUT NOCOPY NUMBER,
   	  		          p_years IN OUT NOCOPY NUMBER)
                              IS
  dStartdate Date;
  dEnddate Date;
  dDays number;
  dMonths number;
  nStartdate Date;
  nEnddate Date;
  dYear number:=0;
BEGIN
  dStartdate:=p_start_date;
  dEnddate:=p_end_date;

  if last_day(dStartdate -1) = (dStartdate - 1) and last_day(dEnddate) = dEnddate then
     dMonths:= months_between(dEnddate,dStartdate-1);
     dDays:=0;
  elsif last_day(dStartdate -1) = (dStartdate - 1) then
      nStartdate:=dStartdate -1;
      nEnddate:=trunc(dEnddate,'MM')-1;
      dMonths:= months_between(nEnddate,nStartdate);
      dDays:=to_number(to_char(dEnddate,'dd'));
  elsif last_day(dEnddate) = dEnddate then
      nStartdate:=last_day(dStartdate);
      nEnddate:=dEnddate;
      dMonths:= months_between(nEnddate,nStartdate);
      dDays:=to_number(to_char(last_day(dStartdate),'dd'))-to_number(to_char(dStartdate-1,'dd'));
  elsif to_char(dStartdate,'Mon') = to_char(dEnddate,'Mon') Then
      dMonths:= months_between(dEnddate,dStartdate);
      if to_char(dStartdate,'dd') <= to_char(dEnddate,'dd') Then
        dDays:= to_number(to_char(dEnddate,'dd')) - to_number(to_char(dStartdate,'dd'))+1;
      else
        dDays:=to_number(to_char(last_day(dStartdate),'dd'))-to_number(to_char(dStartdate-1,'dd'))
              +to_number(to_char(dEnddate,'dd'));
      end if;
  else
      nStartdate:=last_day(dStartdate);
      nEnddate:=trunc(dEnddate,'MM')-1;
      dMonths:= months_between(nEnddate,nStartdate);
      dDays:=to_number(to_char(last_day(dStartdate),'dd'))-to_number(to_char(dStartdate-1,'dd'))
         +to_number(to_char(dEnddate,'dd'));
  end if;
  dMonths:= trunc(dMonths);
  If dDays >= 30 then
    dMonths:=dMonths+trunc(dDays/30);
    dDays :=mod(dDays,30);
  End If;

  If dMonths >= 12 then
    dYear := trunc(dMonths/12);
    dMonths:= mod(dMonths,12);
  end if;
   p_years:= dYear;
   p_months := dMonths;
   p_days := dDays;

END per_pl_calc_periods;
-- End of per_pl_calc_periods



/************************************************************************************************/
/*
   This function returns either 0 or 1. If it returns 0, then an incorrect value of
   description for the lookup Employee Category has been specified. This is called thru the formual function
                                                                                               */

/**********************************************************************************************/
/*

Inputs : 1) Person id from per_all_people_f
         2) Code of the type of Service. This code can be picked up from lookup EMPLOYEE_CATG

Outputs : 1) Number of Years
          2) Number of Months
          3) Number of days
          4) Message (This message will be null if correct code has been passed else an appropriate error message
             is thrown


Return : This function return 1 if successful else 0
*/
/********************************************************************************************/

function GET_LENGTH_OF_SERVICE(P_PERSON_ID       IN NUMBER,
                               P_TYPE_OF_SERVICE IN VARCHAR2, -- This is the code of the Category
			           l_years           OUT NOCOPY NUMBER,
			           l_months          OUT NOCOPY NUMBER,
			           l_days            OUT NOCOPY NUMBER,
			           l_message         OUT NOCOPY VARCHAR2)
			       RETURN number IS



lookup_type_val      fnd_common_lookups.lookup_type%TYPE;
lookup_descr_val1    fnd_common_lookups.description%TYPE;
lookup_descr_val2    fnd_common_lookups.description%TYPE;

cursor csr_service_period_dts is
  select   ppj.start_date, ppj.end_date,
           ppj.period_years, ppj.period_months,
           ppj.period_days
     from  per_previous_jobs ppj, per_previous_employers ppe
     where ppe.person_id            = P_PERSON_ID
	 and   ppe.previous_employer_id = ppj.previous_employer_id
	 and   ppj.PJO_INFORMATION1  = P_TYPE_OF_SERVICE    -- Replaced with PJO_INFORMATION1
     and   ppj.start_date IS NOT NULL
     AND   ppj.end_date IS NOT NULL
     order by ppj.start_date, ppj.end_date;

cursor csr_service_period_ymd is
  select   ppj.start_date, ppj.end_date,
           ppj.period_years, ppj.period_months,
           ppj.period_days
     from  per_previous_jobs ppj, per_previous_employers ppe
     where ppe.person_id            = P_PERSON_ID
	 and   ppe.previous_employer_id = ppj.previous_employer_id
	 and   ppj.PJO_INFORMATION1  = P_TYPE_OF_SERVICE    -- Replaced with PJO_INFORMATION1
     and   ppj.start_date IS NULL
     AND   ppj.end_date IS NULL ;

cursor csr_type_of_service is
    select description
    from   hr_lookups       -- Replaced with hr_lookups
    where  lookup_type = lookup_type_val
    and    lookup_code = P_TYPE_OF_SERVICE
    and    description in (lookup_descr_val1, lookup_descr_val2);

idx number := 0;
ind number := 0;
idx1 number := 0;
ind1 number := 0;

TYPE service_rec IS RECORD (
  sdate  date,
  edate  date,
  years  NUMBER,
  months NUMBER,
  days   NUMBER);

TYPE service_table IS TABLE OF service_rec INDEX BY BINARY_INTEGER;

g_user_service_table_dts    service_table;
g_user_service_table_ymd    service_table;

total_service_years  per_previous_jobs.period_years%TYPE;
total_service_months per_previous_jobs.period_months%TYPE;
total_service_days   per_previous_jobs.period_days%TYPE;
service_type         fnd_common_lookups.description%TYPE;

temp_days        number := 0 ;
temp_months      number := 0 ;
temp_years       number := 0 ;

message varchar2(2400);
l_number number;
flag varchar2(1);
message_cat VARCHAR2(3);
message_name fnd_new_messages.message_name%TYPE;

cursor csr_error_message is
   select fnd_message.get_string(message_cat,message_name)
   from dual;

BEGIN
lookup_type_val   := 'PL_TYPE_OF_SERVICE';
lookup_descr_val1 := '01';
lookup_descr_val2 := '02';
l_number          :=  1;  /* Default of 1(one) means success */
flag              := 'N';
message           :=  NULL;
message_cat       := 'PER';
message_name      := 'HR_INVALID_ALGO_JOBTYPE_PL';


--
-- Check if a valid algorithm has been specified for the type of service
--
   open  csr_type_of_service;
   fetch csr_type_of_service    into   service_type;

   if  csr_type_of_service%NOTFOUND then
       total_service_years   := 0;
       total_service_months  := 0;
       total_service_days    := 0;

       open csr_error_message;
          fetch csr_error_message into message;
       close csr_error_message;

       l_years  := total_service_years;
       l_months := total_service_months;
       l_days   := total_service_days;
       l_message := message;
       l_number := 0;
       return l_number;
   end if;
   close csr_type_of_service;

--
-- Initialise the result variables
--
   total_service_years  := 0;
   total_service_months := 0;
   total_service_days   := 0;
   idx := 0;

   IF service_type = '02' THEN --- for connected periods
      FOR svcrec in csr_service_period_dts LOOP
         -- First Record
         IF idx = 0 THEN
            idx := idx + 1;
            g_user_service_table_dts(idx).sdate := svcrec.start_date;
            g_user_service_table_dts(idx).edate  := svcrec.end_date;
            g_user_service_table_dts(idx).years  := nvl(svcrec.period_years,0);
            g_user_service_table_dts(idx).months := nvl(svcrec.period_months,0);
            g_user_service_table_dts(idx).days   := nvl(svcrec.period_days,0);

         -- Complete Range already covered
         ELSIF ( svcrec.start_date BETWEEN g_user_service_table_dts(idx).sdate
                  AND g_user_service_table_dts(idx).edate  ) AND
            ( svcrec.end_date BETWEEN g_user_service_table_dts(idx).sdate
                  AND g_user_service_table_dts(idx).edate  )
         THEN
            null;

         -- Partial Range Covered
         ELSIF ( svcrec.start_date BETWEEN g_user_service_table_dts(idx).sdate
                  AND g_user_service_table_dts(idx).edate  ) AND
            ( svcrec.end_date > g_user_service_table_dts(idx).edate  )
         THEN
            g_user_service_table_dts(idx).edate  := svcrec.end_date;

         -- Range Not Covered
         ELSIF ( svcrec.start_date > g_user_service_table_dts(idx).edate  ) AND
            ( svcrec.end_date   > g_user_service_table_dts(idx).edate  )
         THEN
            -- Is this range contigous
            IF ( svcrec.start_Date = g_user_service_table_dts(idx).edate +1 ) THEN
                g_user_service_table_dts(idx).edate  := svcrec.end_date;
            ELSE -- not contigous
                idx := idx + 1;
                g_user_service_table_dts(idx).sdate := svcrec.start_date;
                g_user_service_table_dts(idx).edate  := svcrec.end_date;
                g_user_service_table_dts(idx).years  := nvl(svcrec.period_years,0);
                g_user_service_table_dts(idx).months := nvl(svcrec.period_months,0);
                g_user_service_table_dts(idx).days   := nvl(svcrec.period_days,0);
            END IF;
         END IF;

      END LOOP;

   ELSE   --- else for service_type , now for separated periods

      FOR svcrec in csr_service_period_dts LOOP
         -- First Record
         IF idx = 0 THEN
            idx := idx + 1;
            g_user_service_table_dts(idx).sdate := svcrec.start_date;
            g_user_service_table_dts(idx).edate  := svcrec.end_date;
            g_user_service_table_dts(idx).years  := nvl(svcrec.period_years,0);
            g_user_service_table_dts(idx).months := nvl(svcrec.period_months,0);
            g_user_service_table_dts(idx).days   := nvl(svcrec.period_days,0);

         -- Complete Range already covered
         ELSIF ( svcrec.start_date BETWEEN g_user_service_table_dts(idx).sdate
                  AND g_user_service_table_dts(idx).edate  ) AND
            ( svcrec.end_date BETWEEN g_user_service_table_dts(idx).sdate
                  AND g_user_service_table_dts(idx).edate  )
         THEN
            null;

         -- Partial Range Covered
         ELSIF ( svcrec.start_date BETWEEN g_user_service_table_dts(idx).sdate
                  AND g_user_service_table_dts(idx).edate  ) AND
            ( svcrec.end_date > g_user_service_table_dts(idx).edate  )
         THEN
            idx := idx + 1;
            g_user_service_table_dts(idx).sdate := g_user_service_table_dts(idx-1).edate +1 ;
            g_user_service_table_dts(idx).edate  := svcrec.end_date;

         -- Range Not Covered
         ELSIF ( svcrec.start_date > g_user_service_table_dts(idx).edate  ) AND
            ( svcrec.end_date   > g_user_service_table_dts(idx).edate  )
         THEN
            -- Is this range contigous
            IF ( svcrec.start_Date = g_user_service_table_dts(idx).edate +1 ) THEN
                idx := idx + 1;
                g_user_service_table_dts(idx).sdate := svcrec.start_date;
                g_user_service_table_dts(idx).edate  := svcrec.end_date;
            ELSE -- not contigous
                idx := idx + 1;
                g_user_service_table_dts(idx).sdate := svcrec.start_date;
                g_user_service_table_dts(idx).edate  := svcrec.end_date;
                g_user_service_table_dts(idx).years  := nvl(svcrec.period_years,0);
                g_user_service_table_dts(idx).months := nvl(svcrec.period_months,0);
                g_user_service_table_dts(idx).days   := nvl(svcrec.period_days,0);
            END IF;
         END IF;
      END LOOP;

   END IF; -- for service_type

   ind := 0 ;
   FOR ymdrec in csr_service_period_ymd LOOP
       ind := ind + 1;
       g_user_service_table_ymd(ind).sdate := ymdrec.start_date;
       g_user_service_table_ymd(ind).edate  := ymdrec.end_date;
       g_user_service_table_ymd(ind).years  := nvl(ymdrec.period_years,0);
       g_user_service_table_ymd(ind).months := nvl(ymdrec.period_months,0);
       g_user_service_table_ymd(ind).days   := nvl(ymdrec.period_days,0);
   END LOOP;


--
-- Get the YMD from the dates , status = Automatic
--
   IF idx > 0 THEN
       FOR i in g_user_service_table_dts.FIRST .. g_user_service_table_dts.LAST LOOP
           idx1 := idx1 + 1;
           hr_pl_utility.per_pl_calc_periods ( g_user_service_table_dts(idx1).sdate,
                                               g_user_service_table_dts(idx1).edate,
                                               temp_days,
                                               temp_months,
                                               temp_years ) ;

           total_service_years  := total_service_years  + temp_years ;
           total_service_months := total_service_months + temp_months;
           total_service_days   := total_service_days   + temp_days;
       END LOOP;
   END IF;

--
-- Get the YMD from the ymd , status = Manual
--
   IF ind > 0 THEN
       FOR i in g_user_service_table_ymd.FIRST .. g_user_service_table_ymd.LAST LOOP
           ind1 := ind1 + 1;
           total_service_years  := total_service_years  + g_user_service_table_ymd(ind1).years;
           total_service_months := total_service_months + g_user_service_table_ymd(ind1).months;
           total_service_days   := total_service_days   + g_user_service_table_ymd(ind1).days;
       END LOOP;
   END IF;



   IF total_service_days > 29 THEN
          total_service_months := total_service_months + trunc(total_service_days /30);
          total_service_days := mod (total_service_days  ,30);
   END IF;
   IF total_service_months > 11 THEN
          total_service_years := total_service_years + trunc(total_service_months /12);
          total_service_months := mod (total_service_months  ,12);
   END IF;

   l_years  := total_service_years;
   l_months := total_service_months;
   l_days   := total_service_days;

   return l_number;

END GET_LENGTH_OF_SERVICE;

FUNCTION CHECK_CONTRIBUTION_TYPE(P_ENTRY_VALUE VARCHAR2) return NUMBER is
l_out number:=0;
cursor csr_lookup_code is
select  lookup_code
          from   hr_lookups
          where LOOKUP_TYPE='PL_CONTRIBUTION_TYPE'
          and   lookup_code=P_ENTRY_VALUE;
l_value hr_lookups.lookup_code%TYPE;
begin
l_value := NULL;
open csr_lookup_code;
 fetch csr_lookup_code into l_value;
close csr_lookup_code;
if l_value is not null then
l_out := 1;
end if;

return l_out;

end CHECK_CONTRIBUTION_TYPE;

FUNCTION GET_VEHICLE_MILEAGE(p_date_earned 				IN DATE,
					 p_vehicle_allocation_id 	IN NUMBER,
					 p_monthly_mileage_limit 	OUT NOCOPY NUMBER,
					 p_engine_capacity_in_cc 	OUT NOCOPY NUMBER,
					 p_vehicle_type				OUT NOCOPY VARCHAR2) RETURN NUMBER is

  Cursor csr_vehicle is select
	puci.value,
	pvrf.engine_capacity_in_cc,
	pvrf.vehicle_type,
	pvaf.val_information3
from
	 pqp_vehicle_allocations_f pvaf,
	 pay_user_column_instances_f puci,
	 pqp_vehicle_repository_f pvrf
where
    pvaf.val_information2 = puci.user_column_instance_id and
    pvaf.vehicle_repository_id = pvrf.vehicle_repository_id and
    pvaf.vehicle_allocation_id = p_vehicle_allocation_id and
    p_date_earned between pvaf.effective_start_date and pvaf.effective_end_date and
    p_date_earned between pvrf.effective_start_date and pvrf.effective_end_date and
    p_date_earned between puci.effective_start_date and puci.effective_end_date;

 l_val_information3 number;

BEGIN

    open csr_vehicle;
	fetch csr_vehicle into p_monthly_mileage_limit,p_engine_capacity_in_cc,p_vehicle_type,l_val_information3;
    close csr_vehicle;

   If p_monthly_mileage_limit is null then
   	return 0;
   else
      return l_val_information3;
 -- returning the value Monthly mileage limit by emp for bug 4576456
   end if;

END GET_VEHICLE_MILEAGE;

/*Start of function GET_TOTAL_PERIOD_OF_SERVICE*/
FUNCTION GET_TOTAL_PERIOD_OF_SERVICE
                      (p_assignment_id  in number,
                       p_date           in date,
                       p_years          OUT NOCOPY NUMBER,
                       p_months         OUT NOCOPY NUMBER,
                       p_days            OUT NOCOPY NUMBER) return number is

cursor csr_person_id is
select person_id
from   per_all_assignments_f
where  assignment_id=p_assignment_id;

cursor csr_per_periods_of_service(r_person_id per_all_people_f.person_id%type) is
select date_start start_date,nvl(ACTUAL_TERMINATION_DATE ,p_date) end_date
from per_periods_of_service
where person_id=r_person_id;

cursor csr_pemp_without_start_date(r_person_id per_all_people_f.person_id%type) is
 select nvl(period_months,0) months,nvl(period_days,0) days,nvl(period_years,0) years
 from   PER_PREVIOUS_EMPLOYERS
 where  person_id=r_person_id
 and    employer_type='PREVIOUS'
 and    start_date is  null;

cursor csr_prev_emp_with_start_date(r_person_id per_all_people_f.person_id%type) is
 select start_date ,end_date,period_months,period_days,period_years,employer_type
 from   PER_PREVIOUS_EMPLOYERS
 where  person_id=r_person_id
 and employer_type in ('PREVIOUS','PARALLEL')
 and start_date is not null
 and start_date<p_date;

TYPE prev_emp_rec IS RECORD (
  start_date date,
  end_date   date,
  years      NUMBER,
  months     NUMBER,
  days       NUMBER,
  active     boolean
);
TYPE prev_emp_table IS TABLE OF prev_emp_rec INDEX BY BINARY_INTEGER;


l_prev_emp_table    prev_emp_table;
l_key number ;
idx number := 0;
l_end_date    date;
l_person_id   per_all_people_f.person_id%type;

l_temp_period_years  number;
l_temp_period_months number;
l_temp_period_days   number;

l_total_period_years  number:=0;
l_total_period_months number:=0;
l_total_period_days  number:=0;

l_proc varchar2(41);

begin

l_proc:='HR_PL_UTILITY.GET_TOTAL_PERIOD_OF_SERVICE';
hr_utility.set_location(l_proc,10);
open  csr_person_id;
fetch csr_person_id into l_person_id;
close csr_person_id;


/*start of calculation for per_periods_of_service*/

for i in csr_per_periods_of_service(l_person_id) loop
hr_pl_utility.per_pl_calc_periods
                     (i.start_date ,
                      i.end_date  ,
                      l_temp_period_days  ,
                      l_temp_period_months ,
                      l_temp_period_years  );

if idx=0 then
idx:=idx+1;
    l_prev_emp_table(idx).start_date:=i.start_date;
    l_prev_emp_table(idx).end_date  :=i.end_date;
    l_prev_emp_table(idx).active    :=true;
    l_prev_emp_table(idx).years     :=l_temp_period_years;
    l_prev_emp_table(idx).months    :=l_temp_period_months;
    l_prev_emp_table(idx).days      :=l_temp_period_days;
else
 for j in l_prev_emp_table.FIRST..l_prev_emp_table.LAST loop
    if      (     i.start_date between  l_prev_emp_table(j).start_date and l_prev_emp_table(j).end_date
             and  i.end_date   between  l_prev_emp_table(j).start_date and l_prev_emp_table(j).end_date
             and  l_prev_emp_table(j).active
             )then

           l_key:=1;
           exit;
   elsif   (      i.start_date <   l_prev_emp_table(j).start_date
             and  i.end_date   >   l_prev_emp_table(j).end_date
             and  l_prev_emp_table(j).active
            ) then

           l_prev_emp_table(j).active:=false;

   elsif    (     i.start_date <   l_prev_emp_table(j).start_date
              and i.end_date   >=  l_prev_emp_table(j).start_date
              and l_prev_emp_table(j).active
            ) then

           l_prev_emp_table(j).start_date:=i.end_date+1;

   elsif   (      i.start_date <=  l_prev_emp_table(j).end_date
             and  i.end_date   >   l_prev_emp_table(j).end_date
             and  l_prev_emp_table(j).active
           ) then

           l_prev_emp_table(j).end_date:=i.start_date-1;
   end if;

    if l_prev_emp_table(j).start_date > l_prev_emp_table(j).end_date then
       l_prev_emp_table(j).active:=false;
    end if;
  end loop;
   if l_key<>1 then
    idx:=idx+1;
    l_prev_emp_table(idx).start_date:=i.start_date;
    l_prev_emp_table(idx).end_date  :=i.end_date;
    l_prev_emp_table(idx).active    :=true;
    l_prev_emp_table(idx).years     :=l_temp_period_years;
    l_prev_emp_table(idx).months    :=l_temp_period_months;
    l_prev_emp_table(idx).days      :=l_temp_period_days;
   end if;
end if;
end loop;
hr_utility.set_location(l_proc,20);
/*End of calculation for records in per_periods_of_service*/


/*Calculation start for per_previous_employers*/

/*It involves calculation for 1) (Employer Type :Parallel
                                or Employer Type :Previous )
                            and start_date is not null
                            and start_date> p_date
                            2)Employer_type='PREVIOUS' and start_date is null
*/
hr_utility.set_location(l_proc,30);
for i in csr_prev_emp_with_start_date(l_person_id) loop

if i.employer_type='PARALLEL' then
l_end_date:=p_date;
else
l_end_date:= i.end_date ;
end if;

hr_pl_utility.per_pl_calc_periods
                     (i.start_date ,
          		  l_end_date  ,
          		  l_temp_period_days  ,
                      l_temp_period_months ,
                      l_temp_period_years  );
if i.employer_type='PREVIOUS' then
      l_temp_period_days   :=i.period_days   ;
      l_temp_period_months :=i.period_months ;
      l_temp_period_years  :=i.period_years  ;
end if;--employer_type='PREVIOUS'?

l_key:=0;

   for j in l_prev_emp_table.FIRST..l_prev_emp_table.LAST loop
    if    (     i.start_date between  l_prev_emp_table(j).start_date and l_prev_emp_table(j).end_date
             and  l_end_date   between  l_prev_emp_table(j).start_date and l_prev_emp_table(j).end_date
             and  l_prev_emp_table(j).active
          )then
           l_key:=1;
           exit;
   elsif   (      i.start_date <   l_prev_emp_table(j).start_date
             and  l_end_date   >   l_prev_emp_table(j).end_date
             and  l_prev_emp_table(j).active
            ) then

           l_prev_emp_table(j).active:=false;

   elsif    (     i.start_date <   l_prev_emp_table(j).start_date
              and l_end_date   >=  l_prev_emp_table(j).start_date
              and l_prev_emp_table(j).active
            ) then

           l_prev_emp_table(j).start_date:=l_end_date+1;

   elsif   (      i.start_date <=  l_prev_emp_table(j).end_date
             and  l_end_date   >   l_prev_emp_table(j).end_date
             and  l_prev_emp_table(j).active
           ) then

           l_prev_emp_table(j).end_date:=i.start_date-1;
   end if;

    if l_prev_emp_table(j).start_date > l_prev_emp_table(j).end_date then
       l_prev_emp_table(j).active:=false;
    end if;
  end loop;
   if l_key<>1 then
    idx:=idx+1;
    l_prev_emp_table(idx).start_date:=i.start_date;
    l_prev_emp_table(idx).end_date  :=l_end_date;
    l_prev_emp_table(idx).active    :=true;
    l_prev_emp_table(idx).years     :=l_temp_period_years;
    l_prev_emp_table(idx).months    :=l_temp_period_months;
    l_prev_emp_table(idx).days      :=l_temp_period_days;
   end if;
end loop;
hr_utility.set_location(l_proc,40);
for kk in l_prev_emp_table.FIRST..l_prev_emp_table.LAST loop
if l_prev_emp_table(kk).active then
l_total_period_years  :=l_total_period_years  + l_prev_emp_table(kk).years;
l_total_period_months :=l_total_period_months + l_prev_emp_table(kk).months;
l_total_period_days   :=l_total_period_days   + l_prev_emp_table(kk).days;
end if;
end loop;

hr_utility.set_location(l_proc,50);
for i in csr_pemp_without_start_date(l_person_id) loop
l_total_period_years  :=l_total_period_years  + i.years;
l_total_period_months :=l_total_period_months + i.months;
l_total_period_days   :=l_total_period_days   + i.days;
end loop;


if l_total_period_days>29 then
l_total_period_months:=l_total_period_months+ trunc(l_total_period_days/30);
l_total_period_days:= mod(l_total_period_days,30);
end if;

if l_total_period_months>11 then
l_total_period_years:=l_total_period_years+trunc(l_total_period_months/12);
l_total_period_months:=mod(l_total_period_months,12);
end if;

p_years  := l_total_period_years;
p_months := l_total_period_months;
p_days   := l_total_period_days;
hr_utility.set_location(l_proc,60);
return 1;
exception
when others then
hr_utility.set_location(l_proc,99);
hr_utility.raise_error;
end GET_TOTAL_PERIOD_OF_SERVICE;

PROCEDURE PER_PL_CHECK_NI_UNIQUE
         ( p_national_identifier     VARCHAR2,
           p_person_id               NUMBER,
           p_business_group_id       NUMBER,
           p_legal_employer          VARCHAR2)is
  l_status            VARCHAR2(1);
  l_nat_lbl           VARCHAR2(2000);
  local_warning       exception;
  l_prof_val          varchar2(30);
  begin
     SELECT 'Y'
     INTO   l_status
     FROM   sys.dual
     WHERE  exists(SELECT '1'
		    FROM   per_all_people_f pp
		    WHERE (p_person_id IS NULL
		       OR  p_person_id <> pp.person_id)
		    AND    p_national_identifier = pp.national_identifier
		    AND    pp.business_group_id   +0 = p_business_group_id
            AND    pp.per_information7 = p_legal_employer);
     l_prof_val := fnd_profile.value('PL_PER_NI_UNIQUE_ERROR_WARN');
     fnd_message.set_name('PER','HR_NATIONAL_ID_NUMBER_PL');
     l_nat_lbl := fnd_message.get;
     l_nat_lbl := rtrim(l_nat_lbl);
     if l_nat_lbl = 'HR_NATIONAL_ID_NUMBER_PL' then
        fnd_message.set_name('PER','HR_NATIONAL_IDENTIFIER_NUMBER');
        l_nat_lbl := fnd_message.get;
        l_nat_lbl := rtrim(l_nat_lbl);
     end if;
     if l_prof_val = 'ERROR' then
        hr_utility.set_message(801,'HR_NI_UNIQUE_ERROR');
        hr_utility.set_message_token('NI_NUMBER',l_nat_lbl);
        hr_utility.raise_error;
     elsif l_prof_val = 'WARNING' then
            hr_utility.set_message(801,'HR_NI_UNIQUE_WARNING');
            hr_utility.set_message_token('NI_NUMBER',l_nat_lbl);
            raise local_warning;
     end if;
  exception
   when no_data_found then null;
   when local_warning then
     hr_utility.set_warning;
end per_pl_check_ni_unique;

END hr_pl_utility;

/

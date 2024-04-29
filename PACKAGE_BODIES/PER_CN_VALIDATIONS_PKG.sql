--------------------------------------------------------
--  DDL for Package Body PER_CN_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_VALIDATIONS_PKG" as
/* $Header: percnval.pkb 115.1 2002/11/20 07:21:18 mkandasa noship $ */
--------------------------------------------------------------------------------

/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	National Identifier card number validations.
Purpose
	To validate the National Identifier entered in people form.
History
	23-OCT-02       mkandasa        Created
*/

-------------------------------------------------------------------------------
--This function will calculate the weight for the position p_pos.
--The weight will be calculated using the formula Wi=2pow(i-1) (Mod 11);

function weight(p_pos number)
return number is
l_counter number;
l_weight  number :=1;
begin
    for l_counter in 1 .. p_pos - 1
    loop
     l_weight := mod (l_weight * 2,11);
    end loop;
    return l_weight;
end;

-- This function used to calucate the check digit for the given
-- National Identifier number
-- The formual used to calculate the check digit is given below
-- Checkdigit = 12 - Sigma i=2 to 18 ( Ai X Wi ) MOD 11

function calculate_check_digit(p_national_identifier varchar2)
return char is
l_pos       number   :=0;
l_digit     number   :=0;
l_weight    number   :=0;
l_sum       number   :=0;
l_chk_dgt   number   :=0;
begin
    hr_utility.set_location('PER_CN_VALIDATIONS_PKG.calculate_check_digit',1);
    for l_pos in 2 .. 18
    loop
       l_digit      := to_number(substr(p_national_identifier,19 - l_pos,1)) ;
       l_weight     := weight(l_pos);
       l_sum        := MOD(l_sum + l_digit * l_weight,11 );
    -- hr_utility.trace('taking the digit'||l_digit||'at pos '||l_pos||' and weight is'||l_weight||'and sum'||l_sum);
    end loop;

    l_chk_dgt    := MOD(12 - l_sum,11);
    hr_utility.trace('The check digit is  '||l_chk_dgt);
    if (l_chk_dgt < 10 ) then
        return to_char(l_chk_dgt);
    else
        return 'X';
    end if;
    hr_utility.set_location('PER_CN_VALIDATIONS_PKG.calculate_check_digit',2);
end calculate_check_digit;


--This function used to validate the national Identifier number entered
-- for china legislation.

function validate_national_identifier(
p_national_identifier in  varchar2,
p_dob                 in  date,
p_gender              in  varchar2
)
return number
is
l_gender            number;
l_status            number;
l_ni_dob            varchar2(8);
l_entered_dob       varchar2(8);
l_cal_chk_dgt       char;
l_ni_chk_dgt        char;


Begin
    hr_utility.set_location('PER_CN_VALIDATIONS_PKG.validate_national_identifier',1);
    l_status := 0;
    if ( length(p_national_identifier) = 18 ) then
    begin
        l_gender            :=mod( to_number(substr(p_national_identifier,17,1)),2);
        l_ni_dob            :=substr(p_national_identifier,7,8);
        l_entered_dob       :=to_char(p_dob,'YYYYMMDD');
        l_ni_chk_dgt        :=substr(p_national_identifier,18,1);
        l_cal_chk_dgt       :=calculate_check_digit(p_national_identifier);
    end;
    elsif (length(p_national_identifier) = 15 ) then
    begin
        l_gender            :=mod( to_number(substr(p_national_identifier,15,1)),2);
        l_ni_dob            :=substr(p_national_identifier,7,6);
        l_entered_dob       :=to_char(p_dob,'YYMMDD');
        l_ni_chk_dgt        :=null;
        l_cal_chk_dgt       :=null;
    end;
    end if;

    hr_utility.trace('NI'||l_gender||'dob'||l_ni_dob||'chk'||l_ni_chk_dgt);
    hr_utility.trace('EN'||p_gender||'dob'||l_entered_dob||'chk'||l_cal_chk_dgt);
--  Check for mismatch between gender entered and gender given in NI no.
    if ( ( l_gender = 0 AND p_gender = 'M' ) OR ( l_gender = 1 AND p_gender = 'F' )) then
       l_status := -1;
--  Check for mismatch between dob entered and dob given in NI no.
    elsif ( to_char(p_dob,'DD/MM/YYYY') <> '01/01/0001') AND
          ( l_ni_dob <> l_entered_dob ) then
        l_status := -2;
--  Check for mismatch between dob entered and dob given in NI no.
    elsif ( nvl(l_ni_chk_dgt,'#') <> nvl( l_cal_chk_dgt, '#' )) then
        l_status := -3;
    end if;

    hr_utility.set_location('PER_CN_VALIDATIONS_PKG.validate_national_identifier',1);
-- If there is an error then l_stauts will be less than zero else it will be zero.
    return l_status;

End validate_national_identifier;

End PER_CN_VALIDATIONS_PKG;

/

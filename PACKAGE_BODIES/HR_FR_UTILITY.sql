--------------------------------------------------------
--  DDL for Package Body HR_FR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_UTILITY" AS
/* $Header: hrfrutl1.pkb 120.0.12010000.4 2009/12/23 09:55:08 dchindar ship $ */
--
FUNCTION per_fr_full_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
	  ,p_per_information30 in VARCHAR2
			 )
			  RETURN VARCHAR2 IS
--
l_full_name per_all_people_f.full_name%type;
--
BEGIN
   --
   -- l_full_name := p_title || ' ' || p_last_name || ' ' || p_first_name;
   if p_title is null then
     l_full_name := substr(p_last_name || ', ' || p_first_name,1,240);
   else
     l_full_name := substr(p_last_name || ', ' || hr_general.decode_lookup('TITLE',p_title) || ' ' || p_first_name,1,240);
   end if;
   return (rtrim(l_full_name));
   --
END;
--
--
FUNCTION per_fr_order_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
	  ,p_per_information30 in VARCHAR2
			  )
			   RETURN VARCHAR2 IS
--
l_order_name per_all_people_f.order_name%type;
--
BEGIN
   --
   l_order_name := substr(p_last_name || ' ' || p_first_name,1,240);
   return (rtrim(l_order_name));
   --
END;
--
--

----
-- Function for Account Number Validation
----

FUNCTION validate_account_number
 (p_account_number IN VARCHAR2,
  p_bank_code IN VARCHAR2,
  p_branch_code  IN VARCHAR2) RETURN NUMBER IS
 	l_ret NUMBER ;
 BEGIN

 select decode(
       decode(substr(translate(p_account_number,'0123456789','9999999999'),12,3), '-99',1,0) +
       decode(length(p_account_number),14,1,0) +
       decode(translate  (substr(p_account_number,1,11),
           'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789','AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'),
           'AAAAAAAAAAA',1,0) +
       mod(to_number(translate(translate(translate(translate(translate
                    (translate(translate(translate(translate(
                     substr(rpad(p_bank_code,5,0) ||
                     rpad(p_branch_code,5,0) ||
                     rpad(substr(replace(p_account_number, '-'),1,11),11,0)||
                     rpad(substr( Replace(p_account_number, '-' ) ,12,2),2,0),1,23),
                    'AJ','11'), 'BKS','222'), 'CLT','333'), 'DMU','444'), 'ENV','555'),
                    'FOW','666'), 'GPX','777'), 'HQY','888'), 'IRZ','999')),97),3, 1, 0)
 INTO l_ret
 FROM dual ;

return  l_ret;
END validate_account_number;




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
FUNCTION validate_account_entered (p_bank_code        VARCHAR2 default null
                            ,p_branch_code      VARCHAR2 default null
                            ,p_account_number   VARCHAR2 default null
                            ,p_acc_type         varchar2
                            ,p_iban_acc         varchar2 default null) return number IS

   l_ret NUMBER ;
 BEGIN
 -- hr_utility.trace_on(null,'ACCVAL');
  l_ret :=0;

  hr_utility.set_location('p_account_number ' || p_account_number,1);
  hr_utility.set_location('p_acc_type    ' || p_acc_type,1);
  hr_utility.set_location('p_iban_acc       ' || p_iban_acc,1);
  hr_utility.set_location('p_bank_code    ' || p_bank_code,1);
  hr_utility.set_location('p_branch_code       ' || p_branch_code,1);

--------------------------------------------------------------------------------
-- If account type is normal (N) call the validate_account_number
--------------------------------------------------------------------------------
   if p_acc_type = 'N' then
     if p_account_number is null then
        l_ret := 2;
        return l_ret;
     end if;
     if ( p_bank_code is not null and p_branch_code is not null and
         p_account_number is not null) then

        l_ret := validate_account_number (
                   p_account_number  => p_account_number
                  ,p_bank_code       => p_bank_code
                  ,p_branch_code     => p_branch_code
                   );
--   l_ret will have 1 if validation paased.
     end if;
   return l_ret;
   end if;

--------------------------------------------------------------------------------
-- If account type is IBAN (Y) call the validate_iban_acc
--------------------------------------------------------------------------------
   if p_acc_type = 'Y' then
      if p_iban_acc is null then
         l_ret :=2;
      else
         l_ret := validate_iban_acc
                 ( p_account_no  => p_iban_acc
                 );
      end if;
      return l_ret;
   end if;

--------------------------------------------------------------------------------
-- If account type is Combine (C) check if at least one account is not null
--------------------------------------------------------------------------------

   IF p_acc_type = 'C' and (p_account_number is not null
                        or p_iban_acc is not null) then
      hr_utility.set_location(' inside first if',1);
      return  l_ret;
   end if;
   l_ret := 3;
   return l_ret;

END validate_account_entered;


END HR_FR_UTILITY;

/

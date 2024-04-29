--------------------------------------------------------
--  DDL for Package Body HR_DE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_UTILITY" AS
 /* $Header: hrdeutil.pkb 120.0.12010000.3 2009/12/16 10:50:18 bkeshary ship $ */
 --
 --
 -- Formats the full name for the German legislation.
 --
 FUNCTION per_de_full_name
 (p_first_name        IN VARCHAR2
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
 ,p_per_information30 in VARCHAR2) RETURN VARCHAR2 IS
   --
   --
   -- Local variables
   --
   l_full_name varchar2(2000);
 BEGIN
   --
   --
   -- Construct the full name which has the following format:
   --
   -- <Last>, <First> <Prefix>
   --
   SELECT SUBSTR(LTRIM(RTRIM(p_last_name
                          || DECODE(p_first_name
                                   ,null, ' '
                                   ,', ' || p_first_name || ' ')
                          || DECODE(p_per_information10
                                   ,null, ''
                                   ,hr_general.decode_lookup('DE_PREFIX', p_per_information10))
                            )), 1, 240)
   INTO   l_full_name
   FROM   dual;
   --
   --
   -- Return the full name.
   --
   RETURN (l_full_name);
 END;
 --
 --
 -- Formats the order name for the German legislation.
 --
 FUNCTION per_de_order_name
 (p_first_name       IN VARCHAR2
 ,p_middle_names     IN VARCHAR2
 ,p_last_name        IN VARCHAR2
 ,p_known_as         IN VARCHAR2
 ,p_title            IN VARCHAR2
 ,p_suffix           IN VARCHAR2
 ,p_pre_name_adjunct IN VARCHAR2
 ,p_per_information1 IN VARCHAR2
 ,p_per_information2 IN VARCHAR2
 ,p_per_information3 IN VARCHAR2
 ,p_per_information4 IN VARCHAR2
 ,p_per_information5 IN VARCHAR2
 ,p_per_information6 IN VARCHAR2
 ,p_per_information7 IN VARCHAR2
 ,p_per_information8 IN VARCHAR2
 ,p_per_information9 IN VARCHAR2
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
 ,p_per_information30 IN VARCHAR2) RETURN VARCHAR2 IS
   --
   --
   -- Local variables
   --
   l_order_name varchar2(2000) := NULL;
 BEGIN
   --
   --
   -- Return the order name.
   --
   RETURN (l_order_name);
 END;

 ----
-- Function added for IBAN Validation
----
FUNCTION validate_iban_acc(p_account_no VARCHAR2)RETURN NUMBER IS

 l_iban_ret_val NUMBER;
BEGIN
     l_iban_ret_val := IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no);
     hr_utility.set_location('IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) ' || l_iban_ret_val,99);
 /*  IF IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) = 1 then
     RETURN 1;
     else
     RETURN 0;
     END IF;
*/
    return l_iban_ret_val;
END validate_iban_acc;

----
-- This function will get called from the bank keyflex field segments
----
FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ,
 p_iban_acc      in varchar2 default null) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
 -- hr_utility.trace_on(null,'DEACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_account_number ' || p_acc_no,1);
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_iban_acc       ' || p_iban_acc,1);
  -- hr_utility.set_location('p_bank_code      ' || p_bank_code,1);

/* checking if either of the two account number are present , then return true*/

 IF p_is_iban_acc = 'C' and (p_acc_no is not null or p_iban_acc is not null) then
    hr_utility.set_location(' inside first if',1);
    return  0;
 end if;

 IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') then
       l_ret:= 0;
        hr_utility.set_location('l_ret      ' || l_ret,2);

    RETURN l_ret;

   ELSIF (p_iban_acc IS NOT NULL AND p_is_iban_acc = 'Y') then
    l_ret := validate_iban_acc(p_iban_acc);
    hr_utility.set_location('l_ret     ' || l_ret,4);
     RETURN l_ret;

  ELSIF (p_acc_no IS NULL AND p_is_iban_acc IS NULL) then
    hr_utility.set_location('Both Account Nos Null',5);
    RETURN 1;

  ELSE
    hr_utility.set_location('l_ret: 3 ' ,6);
    RETURN 3;
  END if;
End validate_account_entered;

--
END hr_de_utility;

/

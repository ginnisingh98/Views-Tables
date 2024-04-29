--------------------------------------------------------
--  DDL for Package Body HR_IE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IE_UTILITY" AS
 /* $Header: hrieutil.pkb 120.0.12010000.2 2009/12/23 09:35:51 dchindar noship $ */
 --

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
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN VARCHAR2 ,
 p_iban_acc      in VARCHAR2 DEFAULT NULL
 ) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 BEGIN
 -- hr_utility.trace_on(null,'ACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_account_number ' || p_acc_no,1);
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_iban_acc       ' || p_iban_acc,1);


 IF p_is_iban_acc = 'C' AND (p_acc_no IS NOT NULL OR p_iban_acc IS NOT NULL) THEN
    hr_utility.set_location(' inside first if',1);
    RETURN  0;
 END IF;

 IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') THEN
      l_ret:= 0;
    hr_utility.set_location('l_ret     ' || l_ret,2);
    RETURN l_ret;
 ELSIF (p_iban_acc IS NOT NULL AND p_is_iban_acc = 'Y') THEN
    l_ret := validate_iban_acc(p_iban_acc);
    hr_utility.set_location('l_ret     ' || l_ret,3);
     RETURN l_ret;
  ELSIF (p_acc_no IS NULL AND p_is_iban_acc IS NULL) THEN
    hr_utility.set_location('Both Account Nos Null',4);
     RETURN 1;
  ELSE
    hr_utility.set_location('l_ret: 3 ' ,5);
     RETURN 3;
  END IF;
END validate_account_entered;

--
/* Bug# 9235816 fix start */
FUNCTION per_ie_full_name(
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
       ,p_per_information30 in varchar2
			 )
			  RETURN VARCHAR2 IS
l_full_name per_all_people_f.full_name%TYPE;
BEGIN

  SELECT rtrim(substrb(DECODE(p_pre_name_adjunct,'','',p_pre_name_adjunct||' ')||
                      p_last_name||','||DECODE(p_title,'','',
                      ' '||p_title)||DECODE(p_first_name,'','',
                      ' '||p_first_name)||DECODE(p_middle_names,'','',
                      ' '||p_middle_names)||
                      DECODE(p_suffix,'','',' '||p_suffix)||
                      DECODE(p_known_as,'','',
                      ' '||p_known_as),1,240))
		INTO  l_full_name
  FROM sys.dual ;

  return l_full_name;
END per_ie_full_name;
/* Bug# 9235816 fix end */

END hr_ie_utility;

/

--------------------------------------------------------
--  DDL for Package Body HR_HU_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HU_UTILITY" as
/* $Header: pehuutil.pkb 120.0.12010000.2 2009/12/02 11:36:00 dchindar ship $ */

---
FUNCTION validate_account_no(p_acc_no  VARCHAR2) RETURN NUMBER IS
    --
    X1                  NUMBER;
    X2                  NUMBER;
    X3                  NUMBER;
    X4                  NUMBER;
    X5                  NUMBER;
    X6                  NUMBER;
    X7                  NUMBER;
    X8                  NUMBER;
    X9                  NUMBER;
    X10                  NUMBER;
    X11                 NUMBER;
    X12                 NUMBER;
    X13                 NUMBER;
    X14                 NUMBER;
    X15                 NUMBER;
    X16                 NUMBER;
    --
    l_len               NUMBER;
    check_digit         NUMBER;

    --
BEGIN
    --
    l_len := length(p_acc_no);
    IF  l_len < 17 OR l_len > 26 THEN
        RETURN 0;
    END IF;
    IF  l_len > 17 AND l_len <> 26 THEN
        RETURN 0;
    END IF;
    --
    IF l_len = 17 THEN
     -- Modify to bug no. 3335549
        IF p_acc_no = '00000000-00000000' THEN
            RETURN 0;
        END IF;
        IF instr(p_acc_no,'-',1,1) <> 9 then
            RETURN 0;
        END IF;

        -- Check format
        IF  hr_ni_chk_pkg.chk_nat_id_format(p_acc_no,'DDDDDDDD-DDDDDDDD') = '0' THEN
            -- Incorrect format
            RETURN 0;
        END IF;
        --
        X1 := substr(p_acc_no,1,1);
        X2 := substr(p_acc_no,2,1);
        X3 := substr(p_acc_no,3,1);
        X4 := substr(p_acc_no,4,1);
        X5 := substr(p_acc_no,5,1);
        X6 := substr(p_acc_no,6,1);
        X7 := substr(p_acc_no,7,1);
        X8 := substr(p_acc_no,8,1);
        --
        --
        check_digit := (X1*9) + (X2*7) + (X3*3) + (X4*1)
                     + (X5*9) + (X6*7) + (X7*3);
    --
        check_digit := 10 - mod(check_digit,10);
        --
        IF  check_digit = 10 THEN
            check_digit := 0;
        END IF;

        IF  check_digit <> X8 THEN
            RETURN 0;
        END IF;
        --
        X1  := substr(p_acc_no,10,1);
        X2  := substr(p_acc_no,11,1);
        X3  := substr(p_acc_no,12,1);
        X4  := substr(p_acc_no,13,1);
        X5  := substr(p_acc_no,14,1);
        X6  := substr(p_acc_no,15,1);
        X7  := substr(p_acc_no,16,1);
        X8  := substr(p_acc_no,17,1);

        check_digit := (X1*9) + (X2*7)  + (X3*3) + (X4*1)
                     + (X5*9) + (X6*7)  + (X7*3);

        --
        check_digit := 10 - mod(check_digit,10);
        --
        IF  check_digit = 10 THEN
            check_digit := 0;
        END IF;
        --
        IF  check_digit <> X8 THEN
            RETURN 0;
        END IF;
        --
    ELSE
        -- Modify to bug no. 3335549
        IF p_acc_no = '00000000-00000000-00000000' THEN
            RETURN 0;
        END IF;

        IF (instr(p_acc_no,'-',1,1) <> 9 OR instr(p_acc_no,'-',1,2) <> 18) THEN
            RETURN 0;
        END IF;

        IF  hr_ni_chk_pkg.chk_nat_id_format(p_acc_no,'DDDDDDDD-DDDDDDDD-DDDDDDDD')= '0' THEN
            -- Incorrect format
            RETURN 0;
        END IF;

        -- check for branch code
        X1 := substr(p_acc_no,1,1);
        X2 := substr(p_acc_no,2,1);
        X3 := substr(p_acc_no,3,1);
        X4 := substr(p_acc_no,4,1);
        X5 := substr(p_acc_no,5,1);
        X6 := substr(p_acc_no,6,1);
        X7 := substr(p_acc_no,7,1);
        X8 := substr(p_acc_no,8,1);
        --
        --
        check_digit := (X1*9) + (X2*7) + (X3*3) + (X4*1)
                     + (X5*9) + (X6*7) + (X7*3);
    --
        check_digit := 10 - mod(check_digit,10);
        --
        IF  check_digit = 10 THEN
            check_digit := 0;
        END IF;

        IF  check_digit <> X8 THEN
            RETURN 0;
        END IF;

        -- Check for account no 1 and account no 2
        X1  := substr(p_acc_no,10,1);
        X2  := substr(p_acc_no,11,1);
        X3  := substr(p_acc_no,12,1);
        X4  := substr(p_acc_no,13,1);
        X5  := substr(p_acc_no,14,1);
        X6  := substr(p_acc_no,15,1);
        X7  := substr(p_acc_no,16,1);
        X8  := substr(p_acc_no,17,1);
        X9  := substr(p_acc_no,19,1);
        X10  := substr(p_acc_no,20,1);
        X11 := substr(p_acc_no,21,1);
        X12  := substr(p_acc_no,22,1);
        X13  := substr(p_acc_no,23,1);
        X14 := substr(p_acc_no,24,1);
        X15 := substr(p_acc_no,25,1);
        X16 := substr(p_acc_no,26,1);
        --
        check_digit := (X1*9) + (X2*7)  + (X3*3) + (X4*1)
                     + (X5*9) + (X6*7)  + (X7*3) + (X8*1)
                     + (X9*9) + (X10*7)  + (X11*3) + (X12*1)
                     + (X13*9) + (X14*7)  + (X15*3) ;

        --

        check_digit := 10 - mod(check_digit,10);
        --
        IF  check_digit = 10 THEN
            check_digit := 0;
        END IF;
        --
        IF  check_digit <> X16 THEN
            RETURN 0;
        END IF;


    END IF;
    --
    --
    RETURN 1;
    --
END validate_account_no;



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
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
--   hr_utility.trace_on(null,'ACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_account_number ' || p_acc_no,1);

  IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') then
    l_ret := validate_account_no(p_acc_no);
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


--
FUNCTION check_tax_identification_no(p_tax_id_no VARCHAR2) RETURN NUMBER IS

    X1              NUMBER;
    X2              NUMBER;
    X3              NUMBER;
    X4              NUMBER;
    X5              NUMBER;
    X6              NUMBER;
    X7              NUMBER;
    X8              NUMBER;
    X9              NUMBER;
    X10             NUMBER;

    check_digit     NUMBER;

BEGIN
    --
     IF p_tax_id_no = '0000000000' THEN
        RETURN 0;
    END IF;

    IF  hr_ni_chk_pkg.chk_nat_id_format(substr(p_tax_id_no,1,30),'DDDDDDDDDD') = '0' THEN
        -- Incorrect format
        RETURN 0;
    END IF;
    --
    X1 := substr(p_tax_id_no,1,1);
    X2 := substr(p_tax_id_no,2,1);
    X3 := substr(p_tax_id_no,3,1);
    X4 := substr(p_tax_id_no,4,1);
    X5 := substr(p_tax_id_no,5,1);
    X6 := substr(p_tax_id_no,6,1);
    X7 := substr(p_tax_id_no,7,1);
    X8 := substr(p_tax_id_no,8,1);
    X9 := substr(p_tax_id_no,9,1);
    X10 := substr(p_tax_id_no,10,1);
    --
    IF X1 <> 8 then
        RETURN 0;
    END IF;
    --
    check_digit := (X1*1)+(X2*2)+(X3*3)+(X4*4)+(X5*5)+(X6*6)+(X7*7)+(X8*8)+(X9*9);
    check_digit := mod(check_digit,11);
    --
    IF check_digit <> X10 then
        RETURN 0;
    END IF;
    --
    RETURN 1;
    --
END check_tax_identification_no;
---
FUNCTION per_hu_full_name(
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
               ,p_per_information30 IN VARCHAR2
               ) RETURN VARCHAR2 is
--
l_full_name  VARCHAR2(240);
--
BEGIN
--
SELECT SUBSTR(LTRIM(RTRIM(
       DECODE(p_pre_name_adjunct  , NULL,'',' ' || p_pre_name_adjunct)
     ||DECODE(p_last_name, NULL, '', ' ' || p_last_name)
     ||DECODE(p_first_name,NULL, '', ' ' || p_first_name)
     ||DECODE(p_middle_names,NULL, '', ' ' || p_middle_names)
     )), 1, 240)
    INTO   l_full_name
    FROM   dual;

RETURN l_full_name;
        --
END per_hu_full_name;

---
FUNCTION per_hu_order_name(
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
SELECT SUBSTR(TRIM(NVL(p_pre_name_adjunct,p_last_name)), 1, 240)
INTO   l_order_name
FROM   dual;

RETURN(l_order_name);
        --
END per_hu_order_name;
--
----------------------------------------------------------------
PROCEDURE validate_ss_no(p_org_info VARCHAR2) is
l_ss_no     VARCHAR2(10);
BEGIN
    l_ss_no := hr_ni_chk_pkg.chk_nat_id_format(p_org_info,'DDDDDDD-A');
    IF l_ss_no ='0' THEN
        hr_utility.set_message(800, 'HR_HU_INVALID_SS_NO');
        hr_utility.raise_error;
    END IF;
END validate_ss_no;
---------------------------------------------------------------
PROCEDURE validate_tax_no(p_org_info VARCHAR2) is
l_tax_no        VARCHAR2(15);
BEGIN
    IF p_org_info = '00000000-0-00' THEN
        hr_utility.set_message(800, 'HR_HU_INVALID_TAX_NO');
        hr_utility.raise_error;
    END IF;

    IF (instr(p_org_info,'-',1,1) <> 9 OR instr(p_org_info,'-',1,2) <> 11) THEN
        hr_utility.set_message(800, 'HR_HU_INVALID_TAX_NO');
        hr_utility.raise_error;
    END IF;

    l_tax_no := hr_ni_chk_pkg.chk_nat_id_format(p_org_info,'DDDDDDDD-D-DD');
    IF l_tax_no ='0' THEN
        hr_utility.set_message(800, 'HR_HU_INVALID_TAX_NO');
        hr_utility.raise_error;
    END IF;
END validate_tax_no;
---------------------------------------------------------------
PROCEDURE validate_cs_no(p_org_info4    VARCHAR2
                        ,p_org_info5    VARCHAR2) is

l_cs_no        VARCHAR2(8);
BEGIN
    l_cs_no := substr(p_org_info4,1,8);
    IF l_cs_no <> p_org_info5 THEN
        hr_utility.set_message(800, 'HR_HU_INVALID_CS_NO');
        hr_utility.raise_error;
    END IF;
END validate_cs_no;
-----------------------------------------------------------------

PROCEDURE check_tax_identifier_unique
( p_identifier              VARCHAR2,
  p_person_id               NUMBER,
  p_business_group_id       NUMBER)
  is
--
  l_status            VARCHAR2(1);
  l_legislation_code  VARCHAR2(30);
  l_nat_lbl           VARCHAR2(2000);
  local_warning       EXCEPTION;

BEGIN
   --
  BEGIN
     SELECT 'Y'
     INTO   l_status
     FROM   sys.dual
     WHERE  exists(SELECT '1'
		    FROM   per_all_people_f pp
		    WHERE (p_person_id IS NULL
		       OR  p_person_id <> pp.person_id)
		       AND p_identifier = pp.per_information2
		       AND pp.business_group_id  = p_business_group_id);
     --
     IF l_status = 'Y' THEN
	    hr_utility.set_message(800, 'HR_HU_NI_UNIQUE_WARNING');
	    hr_utility.set_message_token('NI_NUMBER',hr_general.decode_lookup('HU_FORM_LABELS','TAX_ID_NO'));
        hr_utility.raise_error;
     END IF;
   --
  EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;
END check_tax_identifier_unique;


-----------------------------------------------------------------
END hr_hu_utility;

/

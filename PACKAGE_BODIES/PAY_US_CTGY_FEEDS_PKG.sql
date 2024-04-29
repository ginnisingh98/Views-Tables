--------------------------------------------------------
--  DDL for Package Body PAY_US_CTGY_FEEDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_CTGY_FEEDS_PKG" as
/* $Header: pyusctgf.pkb 115.2 1999/11/03 17:54:41 pkm ship     $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyusctgf.pkb
--
   DESCRIPTION
     API to set needed US balance feeds acc. to element classn and category
--
  MODIFIED (DD-MON-YYYY)
  S Panwar   6-FEB-1995      Created
  S Panwar  17-APR-1995      Fixed problem with not dealing with multiple
                              datetracked entries for same element type
  S Panwar   4-MAY-1995      Removed default on p_date to avoid poss. problems
  S Panwar  13-JUL-1995      Added support for Dependent Care
  D Jeng    25-JUN-1995      Added sections for County, City, School
  dscully    3-NOV-1999      Added EIC balance feed for Dep Care, Section 125, and 401k dedn's
*/
--
-------------------------------------------------------------------------------
--
--
--
--
-------------------------------------------------------------------------------
PROCEDURE create_category_feeds (p_element_type_id    NUMBER,
                                 p_date   DATE) IS
--
-- For each index, these three tables specify which classification + category
-- must be fed to which balance, which must be seeded.
--
l_classn   text_table;
l_catgry   text_table;
l_balance  text_table;
l_num_entries  number;
l_payval_id    number;
l_bal_type_id  number;
l_bg_id        number;
l_feed_exists  number;
l_ele_date     date;
l_ele_classn   varchar2(80);
l_ele_catgry   varchar2(80);
--
BEGIN
--
--  The classn/categories to be fed are hard coded here.
--  Need to feed all necessary tax type variations
--
l_classn(1) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(1) :=  'H';
  l_balance(1) := 'SECTION 125';
l_classn(2) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(2) :=  'H';
  l_balance(2) := 'SECTION 125 FOR FIT';
l_classn(3) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(3) :=  'H';
  l_balance(3) := 'SECTION 125 FOR FUTA';
l_classn(4) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(4) :=  'H';
  l_balance(4) := 'SECTION 125 FOR MEDICARE';
l_classn(5) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(5) :=  'H';
  l_balance(5) := 'SECTION 125 FOR SDI';
l_classn(6) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(6) :=  'H';
  l_balance(6) := 'SECTION 125 FOR SIT';
l_classn(7) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(7) :=  'H';
  l_balance(7) := 'SECTION 125 FOR SS';
l_classn(8) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(8) :=  'H';
  l_balance(8) := 'SECTION 125 FOR SUI';
-- bug 1059450 - dscully 11/3/99
l_classn(43) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(43) :=  'H';
  l_balance(43) := 'SECTION 125 FOR EIC';
--
l_classn(9) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(9) :=  'D';
  l_balance(9) := 'DEF COMP 401K';
l_classn(10) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(10) :=  'D';
  l_balance(10) := 'DEF COMP 401K FOR FIT';
l_classn(11) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(11) :=  'D';
  l_balance(11) := 'DEF COMP 401K FOR FUTA';
l_classn(12) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(12) :=  'D';
  l_balance(12) := 'DEF COMP 401K FOR MEDICARE';
l_classn(13) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(13) :=  'D';
  l_balance(13) := 'DEF COMP 401K FOR SDI';
l_classn(14) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(14) :=  'D';
  l_balance(14) := 'DEF COMP 401K FOR SIT';
l_classn(15) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(15) :=  'D';
  l_balance(15) := 'DEF COMP 401K FOR SS';
l_classn(16) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(16) :=  'D';
  l_balance(16) := 'DEF COMP 401K FOR SUI';
-- bug 1059450 dscully 11/3/99
l_classn(44) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(44) :=  'D';
  l_balance(44) := 'DEF COMP 401K FOR EIC';
--
l_classn(17) :=    'SUPPLEMENTAL EARNINGS';
  l_catgry(17) :=  'CM';
  l_balance(17) := 'COMMISSIONS';
l_classn(18) :=    'SUPPLEMENTAL EARNINGS';
  l_catgry(18) :=  'CM';
  l_balance(18) := 'COMMISSIONS FOR SIT';
l_classn(19) :=    'SUPPLEMENTAL EARNINGS';
  l_catgry(19) :=  'CM';
  l_balance(19) := 'COMMISSIONS FOR NWSIT';
--
l_classn(20) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(20) :=  'S';
  l_balance(20) := 'DEPENDENT CARE';
l_classn(21) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(21) :=  'S';
  l_balance(21) := 'DEPENDENT CARE FOR FIT';
l_classn(22) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(22) :=  'S';
  l_balance(22) := 'DEPENDENT CARE FOR FUTA';
l_classn(23) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(23) :=  'S';
  l_balance(23) := 'DEPENDENT CARE FOR MEDICARE';
l_classn(24) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(24) :=  'S';
  l_balance(24) := 'DEPENDENT CARE FOR SDI';
l_classn(25) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(25) :=  'S';
  l_balance(25) := 'DEPENDENT CARE FOR SIT';
l_classn(26) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(26) :=  'S';
  l_balance(26) := 'DEPENDENT CARE FOR SS';
l_classn(27) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(27) :=  'S';
  l_balance(27) := 'DEPENDENT CARE FOR SUI';
-- bug 1059450 dscully 11/3/99
l_classn(45) :=    'PRE-TAX DEDUCTIONS';
  l_catgry(45) :=  'S';
  l_balance(45) := 'DEPENDENT CARE FOR EIC';
--==================
--  added by dj
--==================

-- CITY
l_classn(28) := 'SUPPLEMENTAL EARNINGS';
  l_catgry(28) := 'CM';
  l_balance(28) := 'COMMISSIONS FOR CITY';
l_classn(29) := 'SUPPLEMENTAL EARNINGS';
  l_catgry(29) := 'CM';
  l_balance(29) := 'COMMISSIONS FOR NWCITY';
l_classn(30) := 'PRE-TAX DEDUCTIONS';
  l_catgry(30) := 'D';
  l_balance(30) := 'DEF COMP 401K FOR CITY';
l_classn(31) := 'PRE-TAX DEDUCTIONS';
  l_catgry(31) := 'H';
  l_balance(31) := 'SECTION 125 FOR CITY';
l_classn(32) := 'PRE-TAX DEDUCTIONS';
  l_catgry(32) := 'S';
  l_balance(32) := 'DEPENDENT CARE FOR CITY';

--COUNTY

l_classn(33) := 'SUPPLEMENTAL EARNINGS';
  l_catgry(33) := 'CM';
  l_balance(33) := 'COMMISSIONS FOR COUNTY';
l_classn(34) := 'SUPPLEMENTAL EARNINGS';
  l_catgry(34) := 'CM';
  l_balance(34) := 'COMMISSIONS FOR NWCOUNTY';
l_classn(35) := 'PRE-TAX DEDUCTIONS';
  l_catgry(35) := 'D';
  l_balance(35) := 'DEF COMP 401K FOR COUNTY';
l_classn(36) := 'PRE-TAX DEDUCTIONS';
  l_catgry(36) := 'H';
  l_balance(36) := 'SECTION 125 FOR COUNTY';
l_classn(37) := 'PRE-TAX DEDUCTIONS';
  l_catgry(37) := 'S';
  l_balance(37) := 'DEPENDENT CARE FOR COUNTY';

--SCHOOL

l_classn(38) := 'SUPPLEMENTAL EARNINGS';
  l_catgry(38) := 'CM';
  l_balance(38) := 'COMMISSIONS FOR SCHOOL';
l_classn(39) := 'SUPPLEMENTAL EARNINGS';
  l_catgry(39) := 'CM';
  l_balance(39) := 'COMMISSIONS FOR NWSCHOOL';
l_classn(40) := 'PRE-TAX DEDUCTIONS';
  l_catgry(40) := 'D';
  l_balance(40) := 'DEF COMP 401K FOR SCHOOL';
l_classn(41) := 'PRE-TAX DEDUCTIONS';
  l_catgry(41) := 'H';
  l_balance(41) := 'SECTION 125 FOR SCHOOL';
l_classn(42) := 'PRE-TAX DEDUCTIONS';
  l_catgry(42) := 'S';
  l_balance(42) := 'DEPENDENT CARE FOR SCHOOL';

l_num_entries := 45;
--
--
-- Get business group id and element start date for the element,
-- as well as element classification and category
--
SELECT  et.business_group_id, et.effective_start_date,
        UPPER(ec.classification_name), et.element_information1
INTO    l_bg_id, l_ele_date, l_ele_classn, l_ele_catgry
FROM    pay_element_types_f et,
        pay_element_classifications ec
WHERE   et.element_type_id = p_element_type_id
AND     p_date between et.effective_start_date
                   and et.effective_end_date
AND     et.classification_id = ec.classification_id;
--
FOR i IN 1..l_num_entries LOOP
--
--  Check if match, if so then create feed.
--
  hr_utility.set_location('pyusctgf.create_category_feeds',10);
  IF (l_ele_classn = l_classn(i)) and (l_ele_catgry = l_catgry(i)) THEN
--
-- Get pay value input value for the element
--
    hr_utility.set_location('pyusctgf.create_category_feeds',100);
    SELECT  inp.input_value_id
    INTO    l_payval_id
    FROM    pay_input_values_f inp,
            hr_lookups hl
    WHERE   inp.element_type_id = p_element_type_id
    AND     inp.name            = hl.meaning
    AND     hl.lookup_code      = 'PAY VALUE'
    AND     hl.lookup_type      = 'NAME_TRANSLATIONS';
--
--
-- Find balance type id of appropriate balance and feed with input value.
-- If balance not found, then continue.
--
    BEGIN

      hr_utility.set_location('pyusctgf.create_category_feeds',200);
      SELECT	BT.balance_type_id
      INTO	l_bal_type_id
      FROM	pay_balance_types	BT
      WHERE	UPPER(BT.balance_name) 	= l_balance(i)
      AND       BT.business_group_id	IS NULL
      AND       BT.legislation_code	= 'US';
--
      SELECT    count(0)
      INTO      l_feed_exists
      FROM      pay_balance_feeds_f bf
      WHERE     l_ele_date between effective_start_date and
                                   effective_end_date
      AND       balance_type_id = l_bal_type_id
      AND       input_value_id = l_payval_id;
--
      IF l_feed_exists = 0 THEN    -- skip if feed already exists
--
-- dbms_output.put_line('insert balance feed..'||to_char(p_element_type_id));
        hr_utility.set_location('pyusctgf.create_category_feeds',300);
        hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => l_payval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => l_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => l_ele_date,
                p_business_group                => l_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');
      END IF;
    --  dbms_output.put_line('balance feed already exists ' || to_char(p_element_type_id));
--
    EXCEPTION WHEN NO_DATA_FOUND THEN
      hr_utility.trace('pyusctgf:  Failed to find balance type:  ' || l_balance(i) || ' --> Skipped.');
--
    END;
--
  END IF;
  --  dbms_output.put_line('no match..');
--
END LOOP;
--
END create_category_feeds;
--
end pay_us_ctgy_feeds_pkg;

/

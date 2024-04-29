--------------------------------------------------------
--  DDL for Package Body PAY_ASSOC_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASSOC_BAL" as
/* $Header: pyascbal.pkb 120.0.12010000.2 2009/02/12 15:05:30 tclewis ship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
NAME
    pyascbal.pkb  - procedures for associating STU balances with STU element
		    types.
--
MODIFED
27-OCT-94	HPARICHA	Created.
28-NOV-94	HPARICHA	Primary balances for Tax Deductions are
				the same as Withheld balances - we'll do
				away with the Withheld Balance DDF seg.
30-NOV-94	HPARICHA	Added "City HT Withheld" as Primary balance
				for CITY_HT_WK and "City SC Withheld" as
				Primary bal for CITY_SC_WK.
05-DEC-94	HPARICHA	Associated primary balance for 'Workers
				Compensation' STU ele.
07-DEC-94	HPARICHA	Added "Not Taken" assoc bals for STU garns.
				Added "Subject and Withholdable" assoc bals
				for STU tax dedns.
19-JAN-95	HPARICHA	Added "Hours" associated balances (G1565).
30-JUN-95	HPARICHA	Changed "..ER Withheld" bal names to
				"..ER Liability".
28-Jun-01       VMEHTA          Changed Primary hours balance for
                                Regular Salary and Regular Wages to
                                Regular Salary Hours and Regular Wages
                                Hours respectively from Regular Hours Worked.
10-Dec-04       Fusman          Added retro_element Procedure to update
                                all the seeded US earnings with the default
                                event group.
29-Apr-05       rdhingra        Added procedure map_time_definition to stamp
                                PAY_US_TIME_DEFINITIONS value set id onto
                                the information element.
10-may-05       djoshi    115.6 Modified sql to get the event group.
                                for 'Entry Changes' event we need to
                                look if Core event Group exist
                                and for Regular Earnings' we
                                need to make sure we have US
                                event. Added legislation_code = null
                                and Business Group id = NUll for
                                core and Added legislation = 'US'
                                for  Regular Earnings' event.
12-FEB-2009    tclewis    115.7 Added SDI1 EE Wthiheld and Taxable

--
DESCRIPTION

This is a post install step to be run when the installation of startup
elements and balances has occurred.
Select installed balance and element type ids BY NAME; associate balances
with elements as approp.
*/
---
PROCEDURE map_time_definition (
   p_element_name          IN   VARCHAR2,
   p_input_value_name      IN   VARCHAR2,
   p_flex_value_set_name   IN   VARCHAR2
) IS
-- Get element_template_id
   CURSOR get_element_type_id (l_element_name VARCHAR2) IS
      SELECT element_type_id
        FROM pay_element_types_f
       WHERE UPPER (element_name) = UPPER (l_element_name)
         AND business_group_id IS NULL
         AND legislation_code = 'US';

-- Get input_value_id
   CURSOR get_input_value_id (
      l_input_value_name   VARCHAR2,
      l_element_type_id    NUMBER
   ) IS
      SELECT input_value_id
        FROM pay_input_values_f
       WHERE element_type_id = l_element_type_id
         AND UPPER (NAME) = UPPER (l_input_value_name)
         AND business_group_id IS NULL
         AND legislation_code = 'US';

-- Get flex_value_set_id
   CURSOR get_flex_value_set_id (l_flex_value_set_name VARCHAR2) IS
      SELECT flex_value_set_id
        FROM fnd_flex_value_sets
       WHERE validation_type = 'F'
         AND UPPER (flex_value_set_name) = UPPER (l_flex_value_set_name);

   l_eletype_id          NUMBER;
   l_input_value_id      NUMBER;
   l_flex_value_set_id   NUMBER;
BEGIN
   l_eletype_id := NULL;
   l_input_value_id := NULL;
   l_flex_value_set_id := NULL;

   -- Get Element type id
   OPEN get_element_type_id (p_element_name);

   FETCH get_element_type_id
    INTO l_eletype_id;

   IF (get_element_type_id%FOUND) AND (l_eletype_id IS NOT NULL) THEN

      -- Get Input value id
      OPEN get_input_value_id (p_input_value_name, l_eletype_id);

      FETCH get_input_value_id
       INTO l_input_value_id;

      IF (get_input_value_id%FOUND) AND (l_input_value_id IS NOT NULL) THEN

         -- Get value set id
	 OPEN get_flex_value_set_id (p_flex_value_set_name);

         FETCH get_flex_value_set_id
          INTO l_flex_value_set_id;

         IF  (get_flex_value_set_id%FOUND)
         AND (l_flex_value_set_id IS NOT NULL) THEN

	    -- Stamp value set in input value of FLSA Time Definition element
	    UPDATE pay_input_values_f
               SET value_set_id = l_flex_value_set_id
             WHERE input_value_id = l_input_value_id
               AND business_group_id IS NULL
               AND legislation_code = 'US';

         ELSE
            NULL;
         END IF;

         CLOSE get_flex_value_set_id;
      ELSE
         NULL;
      END IF;

      CLOSE get_input_value_id;
--
   ELSE
--    hr_utility.trace(p_element_name ||' element does not exist');
      NULL;
   END IF;

   CLOSE get_element_type_id;

END map_time_definition;

---
PROCEDURE      retro_element(p_element_name in varchar2,
                             p_event_group_id in number) IS

l_eletype_id    NUMBER(9);

Begin

begin
 SELECT  element_type_id
 INTO    l_eletype_id
 FROM    pay_element_types_f
 WHERE   UPPER(element_name) = UPPER(p_element_name)
 AND     business_group_id IS NULL
 AND     legislation_code = 'US';

 exception
  when no_data_found then
    hr_utility.set_location('No Element Found',99);

end;

update pay_element_types_f
  set RECALC_EVENT_GROUP_ID = p_event_group_id
  where element_type_id = l_eletype_id
  and business_group_id is null
  and legislation_code = 'US';

EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
  hr_utility.set_location('Assoc Primary Bal - NO DATA FOUND',99);
  --
  WHEN TOO_MANY_ROWS THEN
  hr_utility.set_location('Assoc Primary Bal - TOO MANY ROWS',99);
  --

end;
--
PROCEDURE	assoc_bal(	p_element_name	in varchar2,
				p_balance_name	in varchar2,
				p_association	in varchar2) IS
--
-- Associates primary balances into ELEMENT_INFORMATION10 on eletype.
--
v_baltype_id	NUMBER(9);
v_eletype_id	NUMBER(9);
v_ddf_column	VARCHAR2(20);

BEGIN

hr_utility.set_location('pay_assoc_bal.assoc_bal',1);
hr_utility.set_location('Element : '||p_element_name,3);
hr_utility.set_location('Primary Balance : '||p_balance_name,5);
begin
 SELECT	element_type_id
 INTO	v_eletype_id
 FROM	pay_element_types_f
 WHERE 	UPPER(element_name) = UPPER(p_element_name)
 AND	business_group_id IS NULL
 AND	legislation_code = 'US';

 hr_utility.set_location('pay_assoc_bal.assoc_bal',7);
  SELECT	balance_type_id
  INTO		v_baltype_id
  FROM		pay_balance_types
  WHERE 	UPPER(balance_name) = UPPER(p_balance_name)
  AND		business_group_id IS NULL
  AND		legislation_code = 'US';

exception
  when no_data_found then
    v_baltype_id := NULL;

end;

IF UPPER(p_association) = 'PRIMARY BALANCE' THEN

  hr_utility.set_location('pay_assoc_bal.assoc_bal',9);
  update pay_element_types_f
  set ELEMENT_INFORMATION10 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';

ELSIF UPPER(p_association) IN ('ACCRUED BALANCE', 'GROSS BALANCE') THEN

  hr_utility.set_location('pay_assoc_bal.assoc_bal',11);
  update pay_element_types_f
  set ELEMENT_INFORMATION11 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';

ELSIF UPPER(p_association) IN ('ARREARS BALANCE', 'SUBJECT BALANCE', 'HOURS BALANCE') THEN

  hr_utility.set_location('pay_assoc_bal.assoc_bal',13);
  update pay_element_types_f
  set ELEMENT_INFORMATION12 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) IN ('NOT TAKEN BALANCE', 'PRETAX BALANCE') THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',15);
  update pay_element_types_f
  set ELEMENT_INFORMATION13 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) IN ('TOWARD BOND PURCHASE', 'SUBJECT WHABLE') THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',17);
  update pay_element_types_f
  set ELEMENT_INFORMATION14 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) IN ('ABLE BALANCE', 'SUBJECT NOT WHABLE') THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',19);
  update pay_element_types_f
  set ELEMENT_INFORMATION15 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) = 'EXCESS BALANCE' THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',21);
  update pay_element_types_f
  set ELEMENT_INFORMATION16 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) = 'TAXABLE BALANCE' THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',23);
  update pay_element_types_f
  set ELEMENT_INFORMATION17 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) = 'EXEMPT BALANCE' THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',25);
  update pay_element_types_f
  set ELEMENT_INFORMATION18 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) = 'EE OR ER CONTR BALANCE' THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',27);
  update pay_element_types_f
  set ELEMENT_INFORMATION19 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
ELSIF UPPER(p_association) = 'WITHHELD BALANCE' THEN
  --
  hr_utility.set_location('pay_assoc_bal.assoc_bal',29);
  update pay_element_types_f
  set ELEMENT_INFORMATION20 = v_baltype_id
  where element_type_id = v_eletype_id
  and business_group_id is null
  and legislation_code = 'US';
  --
END IF;
--
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
  hr_utility.set_location('Assoc Primary Bal - NO DATA FOUND',99);
  --
  WHEN TOO_MANY_ROWS THEN
  hr_utility.set_location('Assoc Primary Bal - TOO MANY ROWS',99);
  --
END assoc_bal;

--
-- MAIN
--
procedure create_associated_balances is
--
l_entry_change_evnt_grp_id Number(15);
l_reg_ear_evnt_grp_id Number(15);

BEGIN
--
  assoc_bal(	p_element_name	=>	'Child Support',
		p_balance_name	=>	'Child Support',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Company Car',
		p_balance_name	=>	'Company Car',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Creditor Garnishment',
		p_balance_name	=>	'Creditor Garnishment',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Federal Tax Levies',
		p_balance_name	=>	'Federal Tax Levies',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'GTL EE Contribution',
		p_balance_name	=>	'GTL EE Contribution',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'GTL Imputed Income',
		p_balance_name	=>	'GTL Imputed Income',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Labor Recording',
		p_balance_name	=>	'Labor Recording',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Local Tax Levies',
		p_balance_name	=>	'Local Tax Levies',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Overtime',
		p_balance_name	=>	'Overtime',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Regular Salary',
		p_balance_name	=>	'Regular Salary',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Regular Wages',
		p_balance_name	=>	'Regular Wages',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Shift Pay',
		p_balance_name	=>	'Shift Pay',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'State Tax Levies',
		p_balance_name	=>	'State Tax Levies',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Straight Time Overtime',
		p_balance_name	=>	'Straight Time Overtime',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Time Entry Wages',
		p_balance_name	=>	'Time Entry Wages',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Workers Compensation',
		p_balance_name	=>	'Workers Compensation',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Vacation Pay',
		p_balance_name	=>	'Vacation Pay',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Sick Pay',
		p_balance_name	=>	'Sick Pay',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Regular Salary',
		p_balance_name	=>	'Regular Salary Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Regular Wages',
		p_balance_name	=>	'Regular Wages Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Vacation Pay',
		p_balance_name	=>	'Vacation Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Sick Pay',
		p_balance_name	=>	'Sick Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Overtime',
		p_balance_name	=>	'Overtime Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Shift Pay',
		p_balance_name	=>	'Shift Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Time Entry Wages',
		p_balance_name	=>	'Time Entry Hours',
		p_association	=> 	'HOURS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Child Support',
		p_balance_name	=>	'Child Support Arrears',
		p_association	=> 	'ARREARS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Creditor Garnishment',
		p_balance_name	=>	'Creditor Garnishment Arrears',
		p_association	=> 	'ARREARS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Federal Tax Levies',
		p_balance_name	=>	'Federal Tax Levies Arrears',
		p_association	=> 	'ARREARS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Local Tax Levies',
		p_balance_name	=>	'Local Tax Levies Arrears',
		p_association	=> 	'ARREARS BALANCE');
--
  assoc_bal(	p_element_name	=>	'State Tax Levies',
		p_balance_name	=>	'State Tax Levies Arrears',
		p_association	=> 	'ARREARS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Child Support',
		p_balance_name	=>	'Child Support Not Taken',
		p_association	=> 	'NOT TAKEN BALANCE');
--
  assoc_bal(	p_element_name	=>	'Creditor Garnishment',
		p_balance_name	=>	'Creditor Garnishment Not Taken',
		p_association	=> 	'NOT TAKEN BALANCE');
--
  assoc_bal(	p_element_name	=>	'Federal Tax Levies',
		p_balance_name	=>	'Federal Tax Levies Not Taken',
		p_association	=> 	'NOT TAKEN BALANCE');
--
  assoc_bal(	p_element_name	=>	'Local Tax Levies',
		p_balance_name	=>	'Local Tax Levies Not Taken',
		p_association	=> 	'NOT TAKEN BALANCE');
--
  assoc_bal(	p_element_name	=>	'State Tax Levies',
		p_balance_name	=>	'State Tax Levies Not Taken',
		p_association	=> 	'NOT TAKEN BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_RS',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_RS',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_WK',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_WK',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'Gross Earnings',
		p_association	=> 	'GROSS BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'City Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_RS',
		p_balance_name	=>	'City Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_RS',
		p_balance_name	=>	'City Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'City Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_WK',
		p_balance_name	=>	'City Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_WK',
		p_balance_name	=>	'City Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'County Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'County Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'EIC Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'FIT Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'SIT Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'SIT Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI Subject',
		p_association	=> 	'SUBJECT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'City Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_WK',
		p_balance_name	=>	'City Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_WK',
		p_balance_name	=>	'City Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'City Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_RS',
		p_balance_name	=>	'City Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_RS',
		p_balance_name	=>	'City Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'County Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'County Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'FIT Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'SIT Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'SIT Pretax Reductions',
		p_association	=> 	'PRETAX BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'City Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'City Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'County Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'County Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'FIT Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'FIT_Supp',
		p_balance_name	=>	'FIT Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare EE Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'SIT Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'SIT Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SIT_SUPP_RS',
		p_balance_name	=>	'SIT Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SIT_SUPP_WK',
		p_balance_name	=>	'SIT Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS EE Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI EE Subject and Withholdable',
		p_association	=> 	'SUBJECT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'CITY SUBJECT NOT WITHHELD',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_HT_RS',
		p_balance_name	=>	'CITY SUBJECT NOT WITHHELD',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_SC_RS',
		p_balance_name	=>	'CITY SUBJECT NOT WITHHELD',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'CITY SUBJECT NOT WITHHELD',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_HT_WK',
		p_balance_name	=>	'CITY SUBJECT NOT WITHHELD',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'City_SC_WK',
		p_balance_name	=>	'CITY SUBJECT NOT WITHHELD',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'County Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'County Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'EIC Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'FIT Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Subject Not Withholdable',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'SIT Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'SIT Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI Subject Not Withheld',
		p_association	=> 	'SUBJECT NOT WHABLE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'EIC Excess',
		p_association	=> 	'EXCESS BALANCE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Excess',
		p_association	=> 	'EXCESS BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare EE Excess',
		p_association	=> 	'EXCESS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI EE Excess',
		p_association	=> 	'EXCESS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS EE Excess',
		p_association	=> 	'EXCESS BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI EE Excess',
		p_association	=> 	'EXCESS BALANCE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'EIC Taxable',
		p_association	=> 	'TAXABLE BALANCE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Taxable',
		p_association	=> 	'TAXABLE BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare EE Taxable',
		p_association	=> 	'TAXABLE BALANCE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI EE Taxable',
		p_association	=> 	'TAXABLE BALANCE');
--
  assoc_bal(    p_element_name  =>      'SDI1_EE',
                p_balance_name  =>      'SDI1 EE Taxable',
                p_association   =>      'TAXABLE BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS EE Taxable',
		p_association	=> 	'TAXABLE BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI EE Taxable',
		p_association	=> 	'TAXABLE BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'City Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_RS',
		p_balance_name	=>	'City Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_RS',
		p_balance_name	=>	'City Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'City Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_WK',
		p_balance_name	=>	'City Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_WK',
		p_balance_name	=>	'City Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'County Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'County Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'EIC Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'FIT Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare EE Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI EE Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'SIT Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'SIT Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS EE Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI EE Exempt',
		p_association	=> 	'EXEMPT BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare ER Liability',
		p_association	=> 	'EE OR ER CONTR BALANCE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI ER Liability',
		p_association	=> 	'EE OR ER CONTR BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS ER Liability',
		p_association	=> 	'EE OR ER CONTR BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI ER Liability',
		p_association	=> 	'EE OR ER CONTR BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_RS',
		p_balance_name	=>	'City Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_RS',
		p_balance_name	=>	'City HT Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_RS',
		p_balance_name	=>	'City SC Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_WK',
		p_balance_name	=>	'City Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_HT_WK',
		p_balance_name	=>	'City HT Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'City_SC_WK',
		p_balance_name	=>	'City SC Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_WK',
		p_balance_name	=>	'County Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'County_RS',
		p_balance_name	=>	'County Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'EIC',
		p_balance_name	=>	'EIC Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'FIT',
		p_balance_name	=>	'FIT Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'FIT_SUPP',
		p_balance_name	=>	'FIT Supp Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'FUTA',
		p_balance_name	=>	'FUTA Liability',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'Medicare_EE',
		p_balance_name	=>	'Medicare EE Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'SDI_EE',
		p_balance_name	=>	'SDI EE Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(    p_element_name  =>      'SDI1_EE',
                p_balance_name  =>      'SDI1 EE Withheld',
                p_association   =>      'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_WK',
		p_balance_name	=>	'SIT Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'SIT_RS',
		p_balance_name	=>	'SIT Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'SS_EE',
		p_balance_name	=>	'SS EE Withheld',
		p_association	=> 	'PRIMARY BALANCE');
--
  assoc_bal(	p_element_name	=>	'SUI_EE',
		p_balance_name	=>	'SUI EE Withheld',
		p_association	=> 	'PRIMARY BALANCE');

--
begin

  SELECT EVENT_GROUP_ID
  INTO   l_entry_change_evnt_grp_id
  FROM   pay_event_groups
  WHERE  event_group_name = 'Entry Changes'
  AND    business_group_id is NULL
  AND    legislation_Code is NULL ;

  SELECT EVENT_GROUP_ID
  INTO   l_reg_ear_evnt_grp_id
  FROM   pay_event_groups
  WHERE  event_group_name ='Regular Earnings'
  AND    legislation_Code = 'US';


 exception
  when no_data_found then
    hr_utility.set_location('No Event Group found.',99);

end;

  retro_element( p_element_name  =>     'Company Car',
                 p_event_group_id =>    l_entry_change_evnt_grp_id);

  retro_element( p_element_name  =>     'GTL Imputed Income',
                 p_event_group_id =>    l_entry_change_evnt_grp_id);

  retro_element( p_element_name  =>     'Regular Salary',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);

  retro_element( p_element_name  =>     'Overtime',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);

  retro_element( p_element_name  =>     'Regular Wages',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);

  retro_element( p_element_name  =>     'Shift Pay',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);

  retro_element( p_element_name  =>     'Sick Pay',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);

  retro_element( p_element_name  =>     'Time Entry Wages',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);

  retro_element( p_element_name  =>     'Vacation Pay',
                 p_event_group_id =>    l_reg_ear_evnt_grp_id);


--
  map_time_definition (
   p_element_name        =>'FLSA Time Definition',
   p_input_value_name    =>'Time Definition',
   p_flex_value_set_name =>'PAY_US_TIME_DEFINITIONS'
 );
--
end create_associated_balances;

END pay_assoc_bal;

/

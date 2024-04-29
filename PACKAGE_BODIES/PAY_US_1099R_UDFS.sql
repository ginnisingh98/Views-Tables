--------------------------------------------------------
--  DDL for Package Body PAY_US_1099R_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_1099R_UDFS" AS
/* $Header: py99udfs.pkb 120.0.12010000.2 2009/03/13 09:23:34 svannian ship $ */
/*
+======================================================================+
|                Copyright (c) 1996 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : pay_us_1099R_udfs
    Filename    : py99udfs.pkb
    Change List
    -----------
    Date        Name          Vers   Bug No  Description
    ----        ----          ----   ------  -----------
    3/16/97     HEKIM         40.0           Created.
   23/05/97     MFENDER       40.2           Removed show_errors call.
   10/14/98     AHANDA        40.3           Changed function : state_1099R_specs
   11/19/98     AHANDA        40.4/          Changed function : state_1099R_specs
                              110.2          to put data in 3 fields - Special Entry,
                                             SIT and LIT
   20/04/99     scgrant       115.1          Multi-radix changes.
   13/11/02     djoshi        115.7          Added the New Function get_1099R_values
   13/11/02     djoshi        115.7          Changed to add all the values for K rec
   02/12/02     djoshi        119.10         Added changes to have value assignmed
   12/20/02     djoshi        115.11         Added new function ny_local
   10/30/03     jgoswami      115.12         Added function GET_1099R_ITEM_DATA,
                                             format_pub1220_address
   11/06/03     jgoswami      115.13         Added Distribution code to get_1099R_values
                                             added procedure format_1099r_wv_address
   13-NOV-2003  jgoswami      115.14 3241256 Added GET_1099R_TRANSMITTER_VALUE
   17-NOV-2003  sodhingr      115.15         removed the to_char from hr_utility.trace
   09-DEC-2003  jgoswami      115.16 3308537 modified format_1099r_wv_address package
   13-DEC-2003  jgoswami      115.17 3317434 modified GET_1099R_TRANSMITTER_VALU E to
                                             return '0' for other states and federal
                                             except 'CT'.
   16-DEC-2003  jgoswami      115.18 3323062 Modified the lpad to rpad for State Abbrev
                                             for WV address function.

  */

-------------------------------------------------------------------------
--Name: init_global_1099R_tables
--Purpose: Initializes pay_us_1099R_udfs global tables for K-record totals
-------------------------------------------------------------------------
  FUNCTION init_global_1099R_tables(p_dummy in VARCHAR2) RETURN VARCHAR2 IS
    l_size number:= 55;
  BEGIN
     FOR l_count IN 1..l_size LOOP
	pay_us_1099R_udfs.gt_combined_filer_state_payees(l_count) := 0;
	pay_us_1099R_udfs.gt_CFS_control_total_1(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_2(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_3(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_4(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_5(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_6(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_8(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_control_total_9(l_count)  := 0;
        pay_us_1099R_udfs.gt_CFS_SIT_total(l_count)   := 0;
        pay_us_1099R_udfs.gt_CFS_LIT_total(l_count)   := 0;
     END LOOP;
     return 1;
  END init_global_1099R_tables;

-------------------------------------------------------------------------
--Name: state_1099R_specs
--Purpose: updates global tables , and returns formula output
--            as specified by state
-------------------------------------------------------------------------
FUNCTION state_1099R_specs(  p_state    in VARCHAR2,
                             p_amount_1 in NUMBER,
                             p_amount_2 in NUMBER,
                             p_amount_3 in NUMBER,
                             p_amount_4 in NUMBER,
                             p_amount_5 in NUMBER,
                             p_amount_6 in NUMBER,
                             p_amount_8 in NUMBER,
                             p_amount_9 in NUMBER,
			     p_SIT      in NUMBER,
			     p_LIT      in NUMBER,
			     p_SEIN     in VARCHAR2,
		             p_state_taxable in NUMBER ) RETURN VARCHAR2 IS
--
l_index number;
l_f34   VARCHAR2(84) :=lpad(' ',84);
l_SIT   VARCHAR2(20) ;
l_LIT   VARCHAR2(20) ;
l_SEIN   VARCHAR2(20) ;
hyphen_position number;
--
BEGIN
  l_SIT := to_char(p_SIT);
  l_LIT := to_char(p_LIT);

  hr_utility.trace('SIT : ' || l_sit);
  hr_utility.trace('LIT : ' || l_lit);

  --
  ----------------------------------------------------------------
  --increment table
  ----------------------------------------------------------------
  l_index := fnd_number.canonical_to_number(pay_us_1099R_udfs.get_1099R_state_code(p_state));
  pay_us_1099R_udfs.gt_combined_filer_state_payees(l_index) :=
      pay_us_1099R_udfs.gt_combined_filer_state_payees(l_index) + 1;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_1(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_1(l_index) + p_amount_1;
  --

  pay_us_1099R_udfs.gt_CFS_control_total_2(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_2 (l_index)+ p_amount_2;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_3(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_3 (l_index)+ p_amount_3;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_4(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_4 (l_index)+ p_amount_4;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_5(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_5 (l_index)+ p_amount_5;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_6(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_6 (l_index)+ p_amount_6;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_8(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_8 (l_index)+ p_amount_8;
  --
  pay_us_1099R_udfs.gt_CFS_control_total_9(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_control_total_9 (l_index)+ p_amount_9;
  --
  --
  pay_us_1099R_udfs.gt_CFS_SIT_total(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_SIT_total (l_index)+ p_SIT;
  --
  pay_us_1099R_udfs.gt_CFS_LIT_total(l_index)  :=
      pay_us_1099R_udfs.gt_CFS_LIT_total(l_index) + p_LIT;

  --------------------------------------------------------------------------
  --specify field
  --------------------------------------------------------------------------
  -- Pos:663  Len: 60  Desc: Special data entries
  -- Pos:723  Len: 12  Desc: State Income Tax Withheld
  -- Pos:735  Len: 12  Desc: Local Income Tax Withheld
  --
  --CA,MN,WI,AR ------------------------------------------------------------
  IF p_state IN ('MN','WI','CA','AR') THEN
    l_f34 := lpad(' ',60)                    ||
             lpad(substr(l_SIT,1,12),12,'0') ||
             lpad('0', 12, '0');

  --MAINE------------------------------------------------------------------
  ELSIF p_state = 'ME' THEN
        /* Special data entries  = 9 bytes State Taxable Income */
	l_f34 :=  lpad(lpad(substr(to_char(p_state_taxable),1,9), 9, '0'),60) ||
        	  lpad(substr(l_SIT,1,12),12,'0')                 ||
        	  lpad('0', 12, '0');

  --IDAHO------------------------------------------------------------------
  ELSIF p_state = 'ID' THEN
        /* Special data entries  =
          10 bytes  Idaho Withholding Account number: strip number before hyphen*/

     hyphen_position := instr( p_SEIN,'-');
     if (hyphen_position <> 0) then
        l_SEIN := lpad(replace(substr(p_SEIN, 1,
			hyphen_position - 1),' '), 10,'0');
     else
        l_SEIN := lpad(substr(p_SEIN,1,10),10,'0');
     end if;
     l_f34 :=  lpad(l_SEIN, 60)                ||
               lpad(substr(l_SIT,1,12),12,'0') ||
               lpad('0',12,'0');

  -------------------------------------------------------------------------
  --Following Federal specs exactly:  AZ,IN,KS,MS,MO,ND,MT,IA,NJ,SC
  ELSE
    l_f34 := lpad(' ',60)                    ||
             lpad(substr(l_SIT,1,12),12,'0') ||
             lpad(substr(l_LIT,1,12),12,'0') ;
  END IF;
  --
  hr_utility.trace('Value of l34 is ' || l_f34);
  return l_f34;
  --
END state_1099R_specs;
--
-------------------------------------------------------------------------
--Name: get_1099R_state_payee_count
--Purpose: returns the number of payees processed currently for that state
-------------------------------------------------------------------------
FUNCTION get_1099R_state_payee_count(p_state in VARCHAR2)
						RETURN NUMBER IS
 l_index number;
BEGIN
   l_index :=  pay_us_1099R_udfs.get_1099R_state_code(p_state);
   IF l_index IS NULL THEN
    return 0;
   ELSE return pay_us_1099R_udfs.gt_combined_filer_state_payees(l_index);
   END IF;
END get_1099R_state_payee_count;
--
-------------------------------------------------------------------------
--Name:  get_1099R_state_total
--Purpose: returns total amounts from global tables according to p_type
-------------------------------------------------------------------------
FUNCTION get_1099R_state_total(p_state in VARCHAR2,
                               p_type in VARCHAR2 ) RETURN VARCHAR2 IS

 l_index number;  -- index into global tables
BEGIN
   l_index :=  pay_us_1099R_udfs.get_1099R_state_code(p_state);
   IF l_index IS NULL THEN
    return 0;
   END IF;
   IF p_type = 'amount_1' THEN
	return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_1(l_index));
   ELSIF p_type = 'amount_2' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_2(l_index));
   ELSIF p_type = 'amount_3' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_3(l_index));
   ELSIF p_type = 'amount_4' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_4(l_index));
   ELSIF p_type = 'amount_5' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_5(l_index));
   ELSIF p_type = 'amount_6' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_6(l_index));
   ELSIF p_type = 'amount_8' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_8(l_index));
   ELSIF p_type = 'amount_9' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_control_total_9(l_index));
   ELSIF p_type = 'SIT' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_SIT_total(l_index));
   ELSIF p_type = 'LIT' THEN
        return fnd_number.number_to_canonical(pay_us_1099R_udfs.gt_CFS_LIT_total(l_index));
   END IF;

END get_1099R_state_total;
--
-------------------------------------------------------------------------
--Name: get_1099R_name_control
--Purpose: Returns first four alphanumeric characters of p_name
-------------------------------------------------------------------------
  FUNCTION get_1099R_name_control (p_name in VARCHAR2)
                                   RETURN VARCHAR2 IS
  l_ascii varchar2(80);
  l_name_code varchar2(10) := NULL;
  l_index NUMBER := 0;
  l_num NUMBER := 0;
  BEGIN

  WHILE (length(p_name)>l_index and l_num< 4) LOOP
      l_index := l_index + 1;
      l_ascii := ASCII(substr(p_name,l_index,1));
      IF (l_ascii >= ASCII('A') and l_ascii <= ASCII('Z')) or
      (l_ascii >= ASCII('0') and l_ascii <= ASCII('9')) or
      (l_ascii = ASCII('-')) or (l_ascii = ASCII('&')) THEN
          l_name_code := l_name_code || substr(p_name,l_index,1);
          l_num := l_num + 1;
      end  if;
  end loop;
 return l_name_code;

  END get_1099R_name_control;
--
-------------------------------------------------------------------------
--Name: get_1099R_NE_SEIN
--Purpose: Returns Nebraska SEIN, Right justified, zero filled
--         without any blanks, hypens, alpha characters,all 9's or 0's
-------------------------------------------------------------------------
  FUNCTION get_1099R_NE_SEIN (p_SEIN in VARCHAR2)
                                   RETURN VARCHAR2 IS
  l_ascii varchar2(80);
  l_NE_SEIN varchar2(80) := NULL;
  l_result varchar2(7) := NULL;
  l_index NUMBER := 0;
  l_num NUMBER := 0;
  l_nine NUMBER:=0;
  l_char CHAR;

  BEGIN
  l_NE_SEIN := upper(p_SEIN);
  WHILE (length(l_NE_SEIN)>l_index and l_num< 7) LOOP
      l_index := l_index + 1;
      l_char := substr(l_NE_SEIN,l_index,1);
      l_ascii := ASCII(l_char);

      --
      IF (l_ascii >= ASCII('A') and l_ascii <= ASCII('Z')) or
      (l_ascii = ASCII('-')) or (l_ascii = ASCII(' ')) THEN
           hr_utility.trace ('Removing ' ||  l_char ||
				'from NE-SEIN.');
      ELSE
        l_result := l_result ||  l_char;
        l_num := l_num + 1;
        if l_char = '9' then
           l_nine := l_nine + 1;
        end if;
      --
      END IF;
  end loop;

 --right justify and zero fill
 --
 if l_nine = l_num then  --all nines
    l_result := '0';
 end if;
 --
 l_result := rpad(l_result, 7,'0');
 return l_result;
--
END get_1099R_NE_SEIN;
-------------------------------------------------------------------------
--Name: combined_filer_1099R_state
--Purpose: returns 'Y' if p_state participates in combined filing,
--         otherwise 'N'
-------------------------------------------------------------------------
  FUNCTION combined_filer_1099R_state (p_state in VARCHAR2) RETURN VARCHAR2 IS
  l_flag VARCHAR(2);
  BEGIN
  SELECT 'Y' into l_flag from hr_lookups
  where lookup_type = '1099R_US_COMBINED_FILER_STATES'
  and lookup_code = p_state;
  return l_flag;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 'N';
        --
  END  combined_filer_1099R_state;
--
-------------------------------------------------------------------------
--Name: get_1099R_state_code
--Purpose: Returns the corresponding combined filer code for p_state
-------------------------------------------------------------------------
  FUNCTION get_1099R_state_code (p_state in VARCHAR2) RETURN VARCHAR2 IS
  l_code VARCHAR(80):=NULL;
  --
  BEGIN
  SELECT MEANING into l_code  from hr_lookups
  where lookup_type = '1099R_US_COMBINED_FILER_STATES'
  and lookup_code = p_state;
  return l_code;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return l_code;
        --
  END get_1099R_state_code;


/* Function Name : Get_Territory_Values
   Purpose       :  Purpose of this function is to fetch the balances as well
                    as the data related to territory.  */

FUNCTION GET_1099R_VALUE(
                   p_assignment_action_id     number, -- context
                   p_tax_unit_id              number,-- context
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2)
RETURN VARCHAR2 IS

  l_entity_id ff_database_items.user_entity_id%type;
  l_archived_value ff_archive_items.value%type;
  l_message varchar2(1000);
  l_main_return varchar2(100);

  TYPE dbi_columns IS RECORD(
     p_user_name ff_database_items.user_name%type,
     p_archived_value ff_archive_items.value%type);

  dbi_rec dbi_columns;

  TYPE dbi_infm IS TABLE OF dbi_rec%TYPE
  INDEX BY BINARY_INTEGER;

  dbi_table dbi_infm;

  CURSOR get_user_entity_id
       (c_user_name ff_database_items.user_name%type) IS
    SELECT fdi.user_entity_id
      FROM   ff_database_items fdi,
             ff_user_entities  fue
      WHERE  fue.legislation_code = 'US'
      AND    fue.user_entity_id = fdi.user_entity_id
      AND    fdi.user_name = c_user_name;

  CURSOR get_archived_values(
          c_user_entity_id ff_database_items.user_entity_id%type,
          c_assignment_action_id pay_assignment_actions.assignment_action_id%type,
          c_tax_unit_id hr_organization_units.organization_id%type)
  IS
    SELECT target.value
    FROM   ff_archive_item_contexts con2,
           ff_contexts fc2,
           ff_archive_items target
    WHERE  target.user_entity_id = c_user_entity_id
    AND    target.context1 = to_char(c_assignment_action_id)
           /* context assignment action id */
    AND    fc2.context_name = 'TAX_UNIT_ID'
    and    con2.archive_item_id = target.archive_item_id
    and    con2.context_id = fc2.context_id
    and    ltrim(rtrim(con2.context)) = to_char(c_tax_unit_id);
           /*context of tax_unit_id */

 CURSOR get_archived_values_assignment(
          c_user_entity_id ff_database_items.user_entity_id%type,
          c_assignment_action_id pay_assignment_actions.assignment_action_id%type
          )
  IS
    SELECT target.value
    FROM
           ff_archive_items target
    WHERE  target.user_entity_id = c_user_entity_id
    AND    target.context1 = to_char(c_assignment_action_id);
           /* context assignment action id */


BEGIN
--  hr_utility.trace_on(NULL,'oracle');
   /* call to funciton to get the value of 1099R Balanaces */
   hr_utility.trace('Calling for 1099R balnaces for following value');

   hr_utility.trace('Assignment_action_id = '||to_char(p_assignment_action_id));
   hr_utility.trace('Tax_unit_id = '||to_char(p_tax_unit_id));

   dbi_table(1).p_user_name := 'A_CAPITAL_GAIN_PER_GRE_YTD';
   dbi_table(2).p_user_name := 'A_OTHER_EE_ANNUITY_CONTRACT_AMT_PER_GRE_YTD';
   dbi_table(3).p_user_name := 'A_TOTAL_EE_CONTRIBUTIONS_PER_GRE_YTD';
   dbi_table(4).p_user_name := 'A_UNREALIZED_NET_ER_SEC_APPREC_PER_GRE_YTD';
   dbi_table(5).p_user_name := 'A_EE_CONTRIBUTIONS_OR_PREMIUMS_PER_GRE_YTD';

   dbi_table(6).p_user_name := 'A_TAXABLE_AMOUNT_UNKNOWN';
   dbi_table(7).p_user_name := 'A_TOTAL_DISTRIBUTIONS';
   dbi_table(8).p_user_name := 'A_EMPLOYEE_DISTRIBUTION_PERCENT';
   dbi_table(9).p_user_name := 'A_TOTAL_DISTRIBUTION_PERCENT';
   dbi_table(10).p_user_name := 'A_DISTRIBUTION_CODE_FOR_1099R';

   hr_utility.trace('Getting the user_entity id');

   FOR i in dbi_table.first .. dbi_table.last loop

       OPEN get_user_entity_id(dbi_table(i).p_user_name);
       FETCH get_user_entity_id INTO l_entity_id;

       IF get_user_entity_id%NOTFOUND THEN

          l_message:='Error:  User_Entity_Id not found for user name '
                            ||dbi_table(i).p_user_name;

          dbi_table(i).p_archived_value:='0';

       ELSE

          hr_utility.trace('get_user_entity_id = '||to_char(l_entity_id));
          hr_utility.trace('p_assignment_action_id = '||to_char(p_assignment_action_id));
          hr_utility.trace('p_tax_unit_id  = '||to_char(p_tax_unit_id));

          IF substr(dbi_table(i).p_user_name,-11) = 'PER_GRE_YTD' THEN

             OPEN get_archived_values(l_entity_id,
                                      p_assignment_action_id,
                                      p_tax_unit_id);
             FETCH get_archived_values INTO l_archived_value;

             IF get_archived_values%NOTFOUND THEN
                   dbi_table(i).p_archived_value:='0';
                   hr_utility.trace('Archived_values not found for user name ' ||dbi_table(i).p_user_name);
             ELSIF get_archived_values%FOUND THEN
             dbi_table(i).p_archived_value := l_archived_value;
             hr_utility.trace('Archived_values found for user name ' ||dbi_table(i).p_user_name);
             hr_utility.trace('Archived_value before neg check= '||l_archived_value);

             END IF;
             CLOSE get_archived_values;
          ELSE
                  /* To get value of non Per gre YTD */

             OPEN get_archived_values_assignment(l_entity_id,
                                      p_assignment_action_id);
             FETCH get_archived_values_assignment INTO l_archived_value;

             IF get_archived_values_assignment%NOTFOUND THEN
                   dbi_table(i).p_archived_value:='0';
                   hr_utility.trace('Archived_values not found for user name ' ||dbi_table(i).p_user_name);
             ELSE
               dbi_table(i).p_archived_value := l_archived_value;
               hr_utility.trace('Archived_values found for user name ' ||dbi_table(i).p_user_name);
               hr_utility.trace('Archived_value before neg check= '||l_archived_value);
             END IF; /* get_archive_value_assignment not_found */
             CLOSE get_archived_values_assignment;
          END IF; /* PER_GRE_YTD */
        END IF; /* USER_ENTITY_FOUND */

        CLOSE get_user_entity_id;

   end loop;

   sp_out_1 :=nvl(dbi_table(1).p_archived_value,'0');
   sp_out_2 :=nvl(dbi_table(2).p_archived_value,'0');
   sp_out_3 :=nvl(dbi_table(3).p_archived_value,'0');
   sp_out_4 :=nvl(dbi_table(4).p_archived_value,'0');
   sp_out_5 :=nvl(dbi_table(5).p_archived_value,'0');

   IF dbi_table(6).p_archived_value = 'Y'
   THEN
      sp_out_6 :='1';
   ELSE
      sp_out_6 :=' ';
   END IF;
   IF dbi_table(7).p_archived_value = 'Y'
   THEN
      sp_out_7 :='1';
   ELSE
      sp_out_7 :=' ';
   END IF;

   IF dbi_table(8).p_archived_value = '100' THEN
       sp_out_8 :=  '  ';
   ELSIF nvl(dbi_table(8).p_archived_value,'-0') = '-0' THEN
       sp_out_8 := '  ';
   ELSE
       sp_out_8 := lpad(dbi_table(8).p_archived_value,2,'0');
   END IF;
   sp_out_9 := nvl(dbi_table(9).p_archived_value,'0');
   sp_out_10 := nvl(dbi_table(10).p_archived_value,'7');
   --sp_out_10:= ' ';
          hr_utility.trace('sp_out_10  = '||sp_out_10);

   l_main_return := ' ';
   return l_main_return;

END Get_1099R_value;

FUNCTION GET_1099R_NY_VALUE(
                   p_assignment_action_id     number, -- context
                   p_tax_unit_id              number,-- context
                   p_state               in   varchar2)
RETURN VARCHAR2 IS
CURSOR c_sum_of_city_withheld(c_assignment_action_id number,c_tax_unit_id number) IS
select nvl(sum(target.value),0)
from
        ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target,
        ff_database_items fdi
  where     fdi.user_name  =  'A_CITY_WITHHELD_PER_JD_GRE_YTD'
        and target.user_entity_id = fdi.user_entity_id
        and target.context1 = to_char(c_assignment_action_id)
		/* context assignment action id */
        and fc2.context_name = 'TAX_UNIT_ID'
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and ltrim(rtrim(con2.context)) = to_char(c_tax_unit_id)
		/* 2nd context of tax_unit_id */
        and fc3.context_name = 'JURISDICTION_CODE'
        and con3.archive_item_id = target.archive_item_id
        and con3.context_id = fc3.context_id
        and ltrim(rtrim(con3.context)) in
                       ( '33-005-2010', '33-047-2010',
                         '33-061-2010' ,'33-081-2010' ,
                         '33-085-2010', '33-119-3230');
l_city_withheld number;

BEGIN

   IF p_state = 'NY' THEN
       open c_sum_of_city_withheld(p_assignment_action_id,p_tax_unit_id);
       fetch c_sum_of_city_withheld into l_city_withheld;
       close c_sum_of_city_withheld;

    return to_char(l_city_withheld);

   ELSE
      return '0';

END IF; /* IF p_state = 'NY' */

END get_1099R_ny_value;

--
-- Function to Get Payee Latest Address
--
/*
    Parameters :
               p_effective_date -
                           This parameter indicates the year for the function.
               p_item_name   -  'EE_ADDRESS'
                                identifies Employee Address required for
                                Employee record.
               p_report_type - This parameter will have the type of the report.
                               eg: '1099R'
               p_format -    This parameter will have the format to be printed
                             on 1099R. eg:'PUB1220','MMREF'
                             ( Will be used when we move the formatting from formula to function)
               p_record_name - This parameter will have the particular
                               record name. eg: B for PUB1220
               p_validate - This parameter will check whether it wants to
                            validate the error condition or override the
                            checking.
                                'N'- Override
                                'Y'- Check
               p_exclude_from_output -
                           This parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.
              p_input_2 - Application Session Date this would be used to
                          fetch the address
              sp_out_1 -  This out parameter returns Employee Location Address
              sp_out_2 -  This out parameter returns Employee Deliver Address
              sp_out_3 -  This out parameter returns Employee City
              sp_out_4 -  This out parameter returns State
              sp_out_5 -  This out parameter returns Zip Code
              sp_out_6 -  This out parameter returns Zip Code Extension
              sp_out_7 -  This out parameter returns Foreign State/Province
              sp_out_8 -  This out parameter returns Foreign Postal Code
              sp_out_9 -  This out parameter returns Foreign Country Code
              sp_out_10 - This parameter is returns  Employee Number
*/

FUNCTION GET_1099R_ITEM_DATA(
                   p_assignment_id        IN  number,
                   p_date_earned          IN  date,
                   p_tax_unit_id          IN  number,
                   p_effective_date       IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                                   ) RETURN VARCHAR2 IS

-- Local Variable Declaration
--

c_item_name           varchar2(40);
c_tax_unit_id         hr_all_organization_units.organization_id%TYPE;
l_organization_name   hr_organization_units.name%TYPE;
l_person_id           number(10);
l_locality_company_id varchar2(50);
lr_employee_addr      pay_us_get_item_data_pkg.person_name_address;
l_country             varchar2(40);
l_effective_date      date;
l_input_2             varchar2(200);

cursor get_person_id (c_assignment_id number , c_effective_date date  ) /* 8219772 */
is
select distinct paa.person_id
from per_all_assignments_f paa
where paa.assignment_id = c_assignment_id
and c_effective_date between paa.effective_start_date and paa.effective_end_date ;

BEGIN
   hr_utility.trace('In function GET_1099R_ITEM_DATA');
   c_item_name:='EE_ADDRESS';
   l_input_2 := ltrim(rtrim(p_input_2));
   if l_input_2 is not null then
      l_effective_date := fnd_date.canonical_TO_DATE(l_input_2);
   else
      l_effective_date := p_effective_date;
   end if;

    /* 8219772 */
   open get_person_id( p_assignment_id ,p_effective_date );
   fetch get_person_id into l_person_id ;
   close get_person_id ;

   hr_utility.trace('In function GET_MMREF_EMPLOYEE_ADDRESS');
   lr_employee_addr :=
      pay_us_get_item_data_pkg.GET_PERSON_NAME_ADDRESS(
                            p_report_type,
                            l_person_id,
                            p_assignment_id,
                            l_effective_date,
                            p_date_earned,
                            p_validate,
                            p_record_name);
   hr_utility.trace('Employee '||lr_employee_addr.full_name ||' Info found ');
   hr_utility.trace('Formatting Employee Address for '||p_report_type
                               ||' Reporting ');

/*
     l_country := lr_employee_addr.country;

      sp_out_1 := lr_employee_addr.addr_line_1
                ||' '||lr_employee_addr.addr_line_2
                ||' '||lr_employee_addr.addr_line_3;
      sp_out_2 := sp_out_1;

      if l_country = 'US' then

        sp_out_3 := lr_employee_addr.city;
        sp_out_4 := lr_employee_addr.province_state;
        sp_out_5 := lr_employee_addr.postal_code;
        sp_out_6 := '';
        sp_out_7 := '';
        sp_out_8 := '';
        sp_out_9 := '';
        sp_out_10 := '';

      else

        sp_out_3 := substr(lr_employee_addr.city,1,35);
        sp_out_4 := '';
        sp_out_5 := '';
        sp_out_6 := '';
        sp_out_7 := lr_employee_addr.province_state;
        sp_out_8 := lr_employee_addr.postal_code;
        --sp_out_9 := lr_employee_addr.country;
        sp_out_9 := lr_employee_addr.country_name;
        sp_out_10 := '';
      end if;
*/

   IF p_format = 'PUB1220' then
--
-- Format Employee Address for 1099R (PUB1220 format)

     pay_us_1099R_udfs.format_pub1220_address(
                   lr_employee_addr.full_name,
                   l_locality_company_id,
                   lr_employee_addr.employee_number,
                   lr_employee_addr.addr_line_1,
                   lr_employee_addr.addr_line_2,
                   lr_employee_addr.addr_line_3,
                   lr_employee_addr.city,
                   lr_employee_addr.province_state,
                   lr_employee_addr.postal_code,
                   lr_employee_addr.country,
                   lr_employee_addr.country_name,
                   lr_employee_addr.region_1,
                   lr_employee_addr.region_2,
                   lr_employee_addr.valid_address,
                   p_item_name,
                   p_report_type,
                   p_record_name,
                   p_validate,
                   p_input_1,
                   p_exclude_from_output,
                   sp_out_1,
                   sp_out_2,
                   sp_out_3,
                   sp_out_4,
                   sp_out_5,
                   sp_out_6,
                   sp_out_7,
                   sp_out_8,
                   sp_out_9,
                   sp_out_10
                   );
   ELSIF p_format = '1099R_WV' then
-- Format Employee Address for 1099R (PUB1220 format)

     pay_us_1099R_udfs.format_1099r_wv_address(
                   lr_employee_addr.full_name,
                   l_locality_company_id,
                   lr_employee_addr.employee_number,
                   lr_employee_addr.addr_line_1,
                   lr_employee_addr.addr_line_2,
                   lr_employee_addr.addr_line_3,
                   lr_employee_addr.city,
                   lr_employee_addr.province_state,
                   lr_employee_addr.postal_code,
                   lr_employee_addr.country,
                   lr_employee_addr.country_name,
                   lr_employee_addr.region_1,
                   lr_employee_addr.region_2,
                   lr_employee_addr.valid_address,
                   p_item_name,
                   p_report_type,
                   p_record_name,
                   p_validate,
                   p_input_1,
                   p_exclude_from_output,
                   sp_out_1,
                   sp_out_2,
                   sp_out_3,
                   sp_out_4,
                   sp_out_5,
                   sp_out_6,
                   sp_out_7,
                   sp_out_8,
                   sp_out_9,
                   sp_out_10
                   );

   END IF;

   if p_report_qualifier = 'FED' and p_format = 'PUB1220' /* 8219772 */
   then
   sp_out_10 := to_char(l_person_id);
   end if ;

   RETURN sp_out_1;
END GET_1099R_ITEM_DATA;


--
-- Procedure to Format Employee Address
-- This procedure is being called from function GET_1099R_ITEM_DATA
--
PROCEDURE  format_pub1220_address(
                   p_name                 IN  varchar2,
                   p_locality_company_id  IN  varchar2,
                   p_emp_number           IN  varchar2,
                   p_address_line_1       IN  varchar2,
                   p_address_line_2       IN  varchar2,
                   p_address_line_3       IN  varchar2,
                   p_town_or_city         IN  varchar2,
                   p_state                IN  varchar2,
                   p_postal_code          IN  varchar2,
                   p_country              IN  varchar2,
                   p_country_name         IN  varchar2,
                   p_region_1             IN  varchar2,
                   p_region_2             IN  varchar2,
                   p_valid_address        IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_local_code           IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2 ) IS
--
TYPE message_columns IS RECORD(
     p_mesg_description varchar2(100),
     p_mesg_value varchar2(100),
     p_output_value varchar2(100));
message_parameter_rec message_columns;
TYPE message_parameter_record IS TABLE OF message_parameter_rec%TYPE
INDEX BY BINARY_INTEGER;
message_record message_parameter_record;

l_level           varchar2(1);
l_mesg_name       varchar2(50);
l_name_or_number  varchar2(50);
l_err             boolean := FALSE;
l_hyphen_position number(10);
c_item_name       varchar2(100);
l_name            varchar2(100);
l_location_addr   varchar2(100);
l_delivery_addr   varchar2(100);
l_State           varchar2(100);
l_city            varchar2(100);

BEGIN
   c_item_name     := p_item_name;
   l_name          := rpad(upper(substr(nvl(p_name,lpad(' ',80)),1,80)),80);
   l_location_addr := nvl(rpad(replace(replace(upper(substr(ltrim
                   (p_address_line_2 ||' '||p_address_line_3), 1, 40))
                    ,',','_'),''''),40) ,lpad(' ',40));
   l_delivery_addr := nvl(rpad(replace(replace(upper(substr(ltrim(
                      p_address_line_1||' '||p_address_line_2 ||' '||
                      p_address_line_3),1,40)),',','_'),''''),40),lpad(' ',40));
   l_State         := upper(rpad(substr(p_state,1,2),2));
   l_city          := nvl(upper(rpad(substr(p_town_or_city, 1, 40), 40)),
                      lpad(' ',40));
-- Format for Valid Address
   IF p_valid_address = 'Y' THEN
--{
      hr_utility.trace('Valid Address found  ');
      hr_utility.trace('Location address '||l_location_addr);
      hr_utility.trace('Delivery address '||l_delivery_addr);
      hr_utility.trace('town_or_city     '||l_city);
      hr_utility.trace('postal_code      '||p_postal_code);
      hr_utility.trace('State            '||l_state);
      hr_utility.trace('p_country        '||p_country);

      IF c_item_name = 'EE_ADDRESS' THEN
         l_level := 'A';
         l_mesg_name := 'PAY_INVALID_EE_FORMAT';
         l_name_or_number := p_emp_number;
      ELSIF c_item_name = 'ER_ADDRESS' THEN
         l_level := 'P';
         l_mesg_name := 'PAY_INVALID_ER_FORMAT';
         l_name_or_number := substr(p_name,1,50);
      END IF;

      message_record(1).p_mesg_description:='Invalid address.Address Line1 is null';
      message_record(2).p_mesg_description:='Invalid address.City is null';
      message_record(3).p_mesg_description:='Invalid address.State is null';
      message_record(4).p_mesg_description:='Invalid address.Zip is null';
      message_record(1).p_mesg_value:= l_delivery_addr;
      message_record(2).p_mesg_value:= l_city;
      message_record(3).p_mesg_value:= l_state;
      message_record(4).p_mesg_value:= p_postal_code;

      FOR i in 1..4 LOOP
         IF message_record(i).p_mesg_value IS NULL THEN
            pay_core_utils.push_message(801,l_mesg_name,l_level);
            pay_core_utils.push_token('record_name', p_record_name);
            pay_core_utils.push_token('name_or_number', l_name_or_number);
            pay_core_utils.push_token('description',
                                    message_record(i).p_mesg_description);
            l_err:=TRUE;
          END IF;
      END LOOP;

      sp_out_1 := l_location_addr;
      sp_out_2 := l_delivery_addr;
      sp_out_3 := l_city;

      IF (p_country = 'US' OR p_country IS NULL )THEN
         --sp_out_9:= lpad(' ',2);
         sp_out_9:= lpad(substr(p_country,1,2),2);
         IF p_region_2 IS NOT NULL THEN
            sp_out_4 := l_state;   --State abbreviation
            sp_out_7 := lpad(' ',2); --foreign state/province
         ELSE  --The region is null.
            sp_out_4 := lpad(' ',2);
            sp_out_7 := lpad(' ',2);
         END IF;
      ELSE  -- country is not US
         sp_out_4 := lpad(' ',2);
                                    -- Bug:2133985 foreign state/province
         sp_out_7 := upper(rpad(substr(nvl(p_region_1,' '),1,2),2));
         sp_out_9:= upper(rpad(substr(p_country_name,1,6),6));
      END IF;

--       See if the zip code has a zip code extension ie. contains a hyphen

      IF p_postal_code IS NOT NULL THEN
--{
         l_hyphen_position := instr(p_postal_code, '-');

         -- sp_out_5: zip code             Len: 5
         --sp_out_6: zip code extension   Len: 4
         --sp_out_8: foreign postal_code  Len: 9

         IF ( (p_country = 'US') OR ( p_country IS NULL ) ) THEN
            IF l_hyphen_position = 0 THEN
               sp_out_5:= upper(rpad(substr(p_postal_code,1,5),5));
               sp_out_6 := lpad(' ', 4);
            ELSE
               sp_out_5:= upper(rpad(substr(substr
                               (p_postal_code,1,l_hyphen_position-1),1,5),5));
               sp_out_6 := upper(rpad(substr(
                                 p_postal_code,l_hyphen_position+1,4),4));
            END IF;
            sp_out_8:= lpad(' ',9);
         ELSE -- ( (l_country = 'US') OR ( l_country IS NULL ) ) --
            sp_out_5:= lpad(' ',5);                  --zip
            sp_out_6:= lpad(' ', 4);                 --extension
            sp_out_8:= upper(rpad(substr(p_postal_code,1,9),9)); --foreign zip
         END IF;
--}
      ELSE --  l_postal_code IS NULL.--
--{
         sp_out_5:= lpad(' ',5);                                   --zip
         sp_out_8:= lpad(' ',9);                                  -- foreign zip
         sp_out_6:= lpad(' ', 4);                                  --extension
         hr_utility.trace('Zip or Postal Code is null');
--}
      END IF;
      IF (p_item_name = 'ER_ADDRESS')  THEN
         sp_out_10:= p_name;
         hr_utility.trace('Organization Name = '||p_name);
      ELSIF p_item_name = 'EE_ADDRESS' THEN
         sp_out_10:= pay_us_reporting_utils_pkg.Character_check(p_emp_number);
      END IF;
--}
--
-- when address is Invalid
--
   ELSE
--{
      IF p_item_name IN ('EE_ADDRESS',
                         'ER_ADDRESS'
                         ) THEN
         sp_out_1:=lpad(' ',40);
         sp_out_2:=lpad(' ',40);
         sp_out_3:=lpad(' ',40);
         sp_out_4:=lpad(' ',2);
         sp_out_5:=lpad(' ',5);
         sp_out_6:=lpad(' ',9);
         sp_out_7:=lpad(' ',2);
         sp_out_8:=lpad(' ',9);
         sp_out_9:=lpad(' ',2);
         sp_out_10:=lpad(' ',80);
      END IF;
      IF ( (p_item_name = 'ER_ADDRESS')OR
           (p_item_name = 'EE_ADDRESS')
         ) THEN
         l_err :=TRUE;
      END IF;
--}
   END IF;  --p_valid_address
   hr_utility.trace('location address       '||sp_out_1);
   hr_utility.trace('delivery address       '||sp_out_2);
   hr_utility.trace('City                   '||sp_out_3);
   hr_utility.trace('State                  '||sp_out_4);
   hr_utility.trace('Zip                    '||sp_out_5);
   hr_utility.trace('Zip Code Extension     '||sp_out_6);
   hr_utility.trace('Foreign State/Province '||sp_out_7);
   hr_utility.trace('Foreign Zip            '||sp_out_8);
   hr_utility.trace('Country                '||sp_out_9);
   IF (p_item_name = 'ER_ADDRESS') THEN
      hr_utility.trace('Organization Name   '||sp_out_10);
   ELSE
      hr_utility.trace('Employee Number     '||sp_out_10);
   END IF;
--
-- Check to include or exclude record on the basis of validity of address
--
   IF p_validate = 'Y' THEN
      IF l_err THEN
         p_exclude_from_output := 'Y';
         hr_utility.trace('p_validate is Y .error '||p_exclude_from_output);
      END IF;
   END IF;
   IF p_exclude_from_output IS NULL THEN
      p_exclude_from_output := 'N';
   END IF;
END format_pub1220_address;  --End of Procedure Validate_address

--
-- Procedure to Format Employee Address
-- This procedure is being called from function GET_1099R_ITEM_DATA
--
PROCEDURE  format_1099r_wv_address(
                   p_name                 IN  varchar2,
                   p_locality_company_id  IN  varchar2,
                   p_emp_number           IN  varchar2,
                   p_address_line_1       IN  varchar2,
                   p_address_line_2       IN  varchar2,
                   p_address_line_3       IN  varchar2,
                   p_town_or_city         IN  varchar2,
                   p_state                IN  varchar2,
                   p_postal_code          IN  varchar2,
                   p_country              IN  varchar2,
                   p_country_name         IN  varchar2,
                   p_region_1             IN  varchar2,
                   p_region_2             IN  varchar2,
                   p_valid_address        IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_local_code           IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2 ) IS
--
TYPE message_columns IS RECORD(
     p_mesg_description varchar2(100),
     p_mesg_value varchar2(100),
     p_output_value varchar2(100));
message_parameter_rec message_columns;
TYPE message_parameter_record IS TABLE OF message_parameter_rec%TYPE
INDEX BY BINARY_INTEGER;
message_record message_parameter_record;

l_level           varchar2(1);
l_mesg_name       varchar2(50);
l_name_or_number  varchar2(50);
l_err             boolean := FALSE;
l_hyphen_position number(10);
c_item_name       varchar2(100);
l_name            varchar2(100);
l_location_addr   varchar2(100);
l_delivery_addr   varchar2(100);
l_State           varchar2(100);
l_city            varchar2(100);

BEGIN
   c_item_name     := p_item_name;
   l_name          := rpad(upper(substr(nvl(p_name,lpad(' ',80)),1,80)),80);
   l_location_addr := nvl(rpad(replace(replace(upper(substr(ltrim
                   (p_address_line_2 ||' '||p_address_line_3), 1, 40))
                    ,',','_'),''''),40) ,lpad(' ',40));
   l_delivery_addr := nvl(rpad(replace(replace(upper(substr(ltrim(
                      p_address_line_1||' '||p_address_line_2 ||' '||
                      p_address_line_3),1,40)),',','_'),''''),40),lpad(' ',40));
   l_State         := upper(rpad(substr(p_state,1,2),2));
   l_city          := nvl(upper(rpad(substr(p_town_or_city, 1, 25), 25)),
                      lpad(' ',25));
-- Format for Valid Address
   IF p_valid_address = 'Y' THEN
--{
      hr_utility.trace('Valid Address found  ');
      hr_utility.trace('Location address '||l_location_addr);
      hr_utility.trace('Delivery address '||l_delivery_addr);
      hr_utility.trace('town_or_city     '||l_city);
      hr_utility.trace('postal_code      '||p_postal_code);
      hr_utility.trace('State            '||l_state);
      hr_utility.trace('p_country        '||p_country);

      IF c_item_name = 'EE_ADDRESS' THEN
         l_level := 'A';
         l_mesg_name := 'PAY_INVALID_EE_FORMAT';
         l_name_or_number := p_emp_number;
      ELSIF c_item_name = 'ER_ADDRESS' THEN
         l_level := 'P';
         l_mesg_name := 'PAY_INVALID_ER_FORMAT';
         l_name_or_number := substr(p_name,1,50);
      END IF;

      message_record(1).p_mesg_description:='Invalid address.Address Line1 is null';
      message_record(2).p_mesg_description:='Invalid address.City is null';
      message_record(3).p_mesg_description:='Invalid address.State is null';
      message_record(4).p_mesg_description:='Invalid address.Zip is null';
      message_record(1).p_mesg_value:= l_delivery_addr;
      message_record(2).p_mesg_value:= l_city;
      message_record(3).p_mesg_value:= l_state;
      message_record(4).p_mesg_value:= p_postal_code;

      FOR i in 1..4 LOOP
         IF message_record(i).p_mesg_value IS NULL THEN
            pay_core_utils.push_message(801,l_mesg_name,l_level);
            pay_core_utils.push_token('record_name', p_record_name);
            pay_core_utils.push_token('name_or_number', l_name_or_number);
            pay_core_utils.push_token('description',
                                    message_record(i).p_mesg_description);
            l_err:=TRUE;
          END IF;
      END LOOP;

      sp_out_1 := l_location_addr;
      sp_out_2 := l_delivery_addr;

      IF (p_country = 'US' OR p_country IS NULL )THEN
         sp_out_3 := l_city;
         sp_out_9:= lpad(substr(p_country,1,2),2);
         IF p_region_2 IS NOT NULL THEN
            --sp_out_4 := l_state;   --State abbreviation
            sp_out_4 := rpad(substr(l_state,1,2),10);   --State abbreviation
            sp_out_7 := lpad(' ',2); --foreign state/province
         ELSE  --The region is null.
            sp_out_4 := lpad(' ',10);
            sp_out_7 := lpad(' ',2);
         END IF;
      ELSE  -- country is not US
         sp_out_3 := upper(rpad(substr(l_city,1,15),15));
         sp_out_4 := lpad(' ',10);
                                    -- Bug:2133985 foreign state/province
         sp_out_7 := upper(rpad(substr(nvl(p_region_1,' '),1,2),2));
         sp_out_9:= upper(rpad(substr(p_country_name,1,6),6));
      END IF;

--       See if the zip code has a zip code extension ie. contains a hyphen

      IF p_postal_code IS NOT NULL THEN
--{
         l_hyphen_position := instr(p_postal_code, '-');

         -- sp_out_5: zip code             Len: 5
         --sp_out_6: zip code extension   Len: 5
         --sp_out_8: foreign postal_code  Len: 5

         IF ( (p_country = 'US') OR ( p_country IS NULL ) ) THEN
            IF l_hyphen_position = 0 THEN
               sp_out_5:= upper(rpad(substr(p_postal_code,1,5),5));
               sp_out_6 := lpad(' ', 5);
            ELSE
               sp_out_5:= upper(rpad(substr(substr
                               (p_postal_code,1,l_hyphen_position-1),1,5),5));
               sp_out_6 := upper(rpad(substr(
                                 p_postal_code,l_hyphen_position+1,4),5));
            END IF;
            sp_out_8:= lpad(' ',5);
         ELSE -- ( (l_country = 'US') OR ( l_country IS NULL ) ) --
            sp_out_5:= lpad(' ',5);                  --zip
            sp_out_6:= lpad(' ', 5);                 --extension
            sp_out_8:= upper(rpad(substr(p_postal_code,1,5),5)); --foreign zip
         END IF;
--}
      ELSE --  l_postal_code IS NULL.--
--{
         sp_out_5:= lpad(' ',5);                                   --zip
         sp_out_8:= lpad(' ',5);                                  -- foreign zip
         sp_out_6:= lpad(' ', 5);                                  --extension
         hr_utility.trace('Zip or Postal Code is null');
--}
      END IF;
      IF (p_item_name = 'ER_ADDRESS')  THEN
         sp_out_10:= p_name;
         hr_utility.trace('Organization Name = '||p_name);
      ELSIF p_item_name = 'EE_ADDRESS' THEN
         sp_out_10:= pay_us_reporting_utils_pkg.Character_check(p_emp_number);
      END IF;
--}
--
-- when address is Invalid
--
   ELSE
--{
      IF p_item_name IN ('EE_ADDRESS',
                         'ER_ADDRESS'
                         ) THEN
         sp_out_1:=lpad(' ',40);
         sp_out_2:=lpad(' ',40);
         sp_out_3:=lpad(' ',15);
         sp_out_4:=lpad(' ',10);
         sp_out_5:=lpad(' ',5);
         sp_out_6:=lpad(' ',4);
         sp_out_7:=lpad(' ',2);
         sp_out_8:=lpad(' ',5);
         sp_out_9:=lpad(' ',2);
         sp_out_10:=lpad(' ',80);
      END IF;
      IF ( (p_item_name = 'ER_ADDRESS')OR
           (p_item_name = 'EE_ADDRESS')
         ) THEN
         l_err :=TRUE;
      END IF;
--}
   END IF;  --p_valid_address
   hr_utility.trace('location address       '||sp_out_1);
   hr_utility.trace('delivery address       '||sp_out_2);
   hr_utility.trace('City                   '||sp_out_3);
   hr_utility.trace('State                  '||sp_out_4);
   hr_utility.trace('Zip                    '||sp_out_5);
   hr_utility.trace('Zip Code Extension     '||sp_out_6);
   hr_utility.trace('Foreign State/Province '||sp_out_7);
   hr_utility.trace('Foreign Zip            '||sp_out_8);
   hr_utility.trace('Country                '||sp_out_9);


   hr_utility.trace('location address       '||replace(sp_out_1,' ','*'));
   hr_utility.trace('delivery address       '||replace(sp_out_2,' ','*'));
   hr_utility.trace('City                   '||replace(sp_out_3,' ','*'));
   hr_utility.trace('State                  '||replace(sp_out_4,' ','*'));
   hr_utility.trace('Zip                    '||replace(sp_out_5,' ','*'));
   hr_utility.trace('Zip Code Extension     '||replace(sp_out_6,' ','*'));
   hr_utility.trace('Foreign State/Province '||replace(sp_out_7,' ','*'));
   hr_utility.trace('Foreign Zip            '||replace(sp_out_8,' ','*'));
   hr_utility.trace('Country                '||replace(sp_out_9,' ','*'));


   IF (p_item_name = 'ER_ADDRESS') THEN
      hr_utility.trace('Organization Name   '||sp_out_10);
   ELSE
      hr_utility.trace('Employee Number     '||sp_out_10);
   END IF;
--
-- Check to include or exclude record on the basis of validity of address
--
   IF p_validate = 'Y' THEN
      IF l_err THEN
         p_exclude_from_output := 'Y';
         hr_utility.trace('p_validate is Y .error '||p_exclude_from_output);
      END IF;
   END IF;
   IF p_exclude_from_output IS NULL THEN
      p_exclude_from_output := 'N';
   END IF;
END format_1099r_wv_address;  --End of Procedure Validate_address


--
FUNCTION Get_1099R_Transmitter_Value(
                   p_payroll_action_id     in varchar2,
                   p_state                 in varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2)
RETURN VARCHAR2 IS

  l_entity_id ff_database_items.user_entity_id%type;
  l_archived_value ff_archive_items.value%type;
  l_message varchar2(1000);
  l_main_return varchar2(100);
  l_payee_count  number;
  lv_payee_count  varchar2(30);

  CURSOR get_payee_count
       (pact_id varchar2) IS
    SELECT count(paa.assignment_Action_id)
      FROM    pay_assignment_actions paa
      WHERE   paa.payroll_action_id = to_number(pact_id);

BEGIN
--  hr_utility.trace_on(NULL,'oracle');
   /* call to funciton to get the value of 1099R Transmitter */
   hr_utility.trace('Payroll_action_id = '||p_payroll_action_id);
          hr_utility.trace('p_state  = '||p_state);

       OPEN get_payee_count(p_payroll_action_id);
       FETCH get_payee_count INTO l_payee_count;

       IF get_payee_count%NOTFOUND THEN

          l_message:='Error:  No Payee found for Transmitter';

          l_payee_count := 0;

          hr_utility.trace('Payee Count = '||to_char(l_payee_count));
       ELSE

          hr_utility.trace('Payroll_action_id = '||p_payroll_action_id);
          hr_utility.trace('Payee Count = '||to_char(l_payee_count));

        END IF; /* get_payee_count */

        CLOSE get_payee_count;

   lv_payee_count := to_char(l_payee_count);

   if p_state = 'CT' then
      sp_out_1 :=lpad(substr(nvl(lv_payee_count,'0'),1,8),8,'0');
   else
      lv_payee_count := '0';
      sp_out_1 :=lpad(substr(lv_payee_count,1,8),8,'0');
   end if;

   sp_out_2 :=' ';
   sp_out_3 :=' ';
   sp_out_4 :=' ';
   sp_out_5 :=' ';
   sp_out_6 :=' ';
   sp_out_7 :=' ';
   sp_out_8 :=' ';
   sp_out_9 :=' ';
   sp_out_10 :=' ';

          hr_utility.trace('sp_out_1  = '||sp_out_1);

   l_main_return := ' ';
   return l_main_return;

END Get_1099R_Transmitter_Value;
--
-------------------------------------------------------------------------
END  pay_us_1099R_udfs;


/

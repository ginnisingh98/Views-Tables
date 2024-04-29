--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_BALANCE_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_BALANCE_PERF" as
/* $Header: pyustxpl.pkb 120.0 2005/05/29 10:02:24 appldev noship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyustxpl.pkb
--
   DESCRIPTION
      API to get US tax balance figures performance version.
--
  MODIFIED (DD-MON-YYYY)
  N Bristow  21-MAY-1996     Changed package name to comply with standards.
  N Bristow  30-APR-1996     Created from a copy of pay_us_tax_bals_pkg,
                             altered package for chequewriter performance
                             reasons.
  19-mar-98 McVeagh          Change create or replace 'as' not 'is'
  08-apr-99 djoshi           Verfied and converted for Canonical
                             Complience of Date
  14-Sep-1999 skutteti 115.4 Pre-tax enhancements
  15-SEP-2000 skutteti 115.5 Currently there is no balance for FIT gross,
                             instead 'Gross Earnings' is used. Changed code
                             to subtract Alien earnings from FIT Gross.
  23-NOV-2000 skutteti 115.6 Pre tax for Alien expat earnings has to be
                             reported in 1042s. Added code to subtract the
                             Alien portion of Pre-tax for SIT/FIT purposes.
  15-AUG-2000 tmehra   115.7 Reverted the above changes for SIT Redns as
                             it is now directly being reduced by feeds.

*/
-- Global declarations
type char_array is table of varchar(81) index by binary_integer;
type num_array  is table of number(16) index by binary_integer;
--
g_defbal_tbl_id num_array;
g_defbal_tbl_name char_array;
g_nxt_free_defbal number;
-------------------------------------------------------------------------------
--
--  Quick procedure to raise an error
--
-------------------------------------------------------------------------------
PROCEDURE local_error(p_procedure varchar2,
                      p_step      number) IS
BEGIN
--
  hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE',
                               'pay_us_tax_balance_perf.'||p_procedure);
  hr_utility.set_message_token('STEP',p_step);
  hr_utility.raise_error;
--
END local_error;
-------------------------------------------------------------------------------
--
--  Wrapper around the core bal user exit
--
-------------------------------------------------------------------------------
FUNCTION call_balance_user_exit
                         (p_balance_name          varchar2,
                          p_dimension_suffix      varchar2,
                          p_assignment_action_id  number,
                          p_business_group_id     number)
RETURN number IS
--
l_defined_balance_id  number;
l_balance_type_id     number;
l_dimension_id        number;
l_defbal_name         char(81);
l_count               number;
l_found               boolean;
--
BEGIN
 --
 -- Search for the defined balance in the Cache.
 --
 l_defbal_name := p_balance_name||p_dimension_suffix||p_business_group_id;
 l_count := 1;
 l_found := FALSE;
 while (l_count < g_nxt_free_defbal and l_found = FALSE) loop
    if (l_defbal_name = g_defbal_tbl_name(l_count)) then
       l_defined_balance_id := g_defbal_tbl_id(l_count);
       l_found := TRUE;
    end if;
    l_count := l_count + 1;
 end loop;
--
 --
 -- If the balance is not in the Cache get it from the database.
 --
 if (l_found = FALSE) then
    BEGIN
--
       hr_utility.trace('Looking for def_bal:  ' || p_balance_name ||
                        '  :  ' || p_dimension_suffix);
--
       SELECT  creator_id
         INTO  l_defined_balance_id
         FROM  ff_user_entities
        WHERE  user_entity_name like
                  translate(p_balance_name||'_'||p_dimension_suffix,' ','_');
--
       --
       -- Place the defined balance in cache.
       --
       g_defbal_tbl_name(g_nxt_free_defbal) := l_defbal_name;
       g_defbal_tbl_id(g_nxt_free_defbal) := l_defined_balance_id;
       g_nxt_free_defbal := g_nxt_free_defbal + 1;
       hr_utility.trace('Calling core balance user exit');
--
    EXCEPTION WHEN no_data_found THEN
       hr_utility.trace('Error:  Failure to find defined balance');
       local_error('call_balance_user_exit',1);
--
    END;
--
  end if;
--
  return pay_balance_pkg.get_value (l_defined_balance_id,
                                      p_assignment_action_id);
--
END call_balance_user_exit;
-------------------------------------------------------------------------------
--
--
--
--
-------------------------------------------------------------------------------
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_business_group_id     in number)
RETURN number IS
--
l_return_value   number;
l_test           number;
l_tax_balance_category  varchar2(30);
l_tax_type       varchar2(15);
l_ee_or_er       varchar2(5);
l_dimension_string  varchar2(80);
l_jd_dimension_string varchar2(80);
l_assignment_id  number;
l_assignment_action_id number;
l_asg_exists     number;
l_max_date       date;
l_bal_start_date date;
l_virtual_date   date;
l_valid          number;
l_non_w2_cat     varchar2(60);
--
BEGIN
--
-- Check that inputs based on lookups are valid
--
SELECT count(*)
INTO   l_valid
FROM   hr_lookups
WHERE  lookup_type = 'US_TAX_BALANCE_CATEGORY'
AND    lookup_code = p_tax_balance_category;
--
IF l_valid = 0 THEN
   hr_utility.trace('Error:  Invalid tax balance category');
   local_error('us_tax_balance',1);
END IF;
--
SELECT count(*)
INTO   l_valid
FROM   hr_lookups
WHERE  lookup_type = 'US_TAX_TYPE'
AND    lookup_code = p_tax_type;
--
IF l_valid = 0 THEN
   hr_utility.trace('Error:  Invalid tax type');
   local_error('us_tax_balance',2);
END IF;
--
SELECT count(*)
INTO   l_valid
FROM   dual
WHERE  p_asg_type in ('ASG','PER','GRE');
--
IF l_valid = 0 THEN
   hr_utility.trace('Error:  Invalid asg_type parameter');
   local_error('us_tax_balance',3);
END IF;
--
SELECT count(*)
INTO   l_valid
FROM   dual
WHERE  p_time_type in ('RUN','PTD','MONTH','QTD','YTD', 'PAYMENTS', 'PYDATE');
--
IF l_valid = 0 THEN
   hr_utility.trace('Error:  Invalid time_type parameter');
   local_error('us_tax_balance',4);
END IF;
--
-- Set the contexts used in the bal user exit.  Same throughout, so set
-- them up front
--
 hr_utility.set_location('pay_tax_bals_pkg',30);
--
IF p_jd_context IS NOT NULL THEN
  IF (p_tax_type = 'SCHOOL' and length(p_jd_context) > 11) THEN
    pay_balance_pkg.set_context('JURISDICTION_CODE',substr(p_jd_context,1,2)||
                                              '-'||substr(p_jd_context,13,5));
  ELSE
    pay_balance_pkg.set_context('JURISDICTION_CODE',p_jd_context);
  END IF;
END IF;
--
 hr_utility.set_location('pay_tax_bals_pkg',40);
--
l_assignment_id := p_assignment_id;
l_assignment_action_id := p_assignment_action_id;
l_tax_type := p_tax_type;
l_tax_balance_category := p_tax_balance_category;
l_virtual_date := p_virtual_date;
--
-- Check if assignment exists at l_virtual_date, if using date mode
--
 hr_utility.set_location('pay_tax_bals_pkg',50);
--
--
-- Convert "WITHHELD" to proper balance categories;
--
 hr_utility.set_location('pay_tax_bals_pkg',80);
--
IF l_tax_balance_category = 'WITHHELD' THEN
  IF p_ee_or_er = 'ER' or l_tax_type = 'FUTA' or l_tax_type = 'HT' THEN
    l_tax_balance_category := 'LIABILITY';
  ELSIF l_tax_type = 'EIC' THEN
    l_tax_balance_category := 'ADVANCE';
  END IF;
END IF;
IF l_tax_balance_category = 'ADVANCED' THEN
    l_tax_balance_category := 'ADVANCE';
END IF;
--
--  Check if illegal tax combo (FIT and TAXABLE, FUTA and SUBJ_NWHABLE, etc.)
--
 hr_utility.set_location('pay_tax_bals_pkg',90);
--
IF (l_tax_type = 'FIT' or l_tax_type = 'SIT' or l_tax_type = 'COUNTY' or
    l_tax_type = 'CITY' or l_tax_type = 'EIC' or l_tax_type = 'HT' or
    l_tax_type = 'SCHOOL') THEN    -- income tax
  IF (l_tax_balance_category = 'TAXABLE' or
      l_tax_balance_category = 'EXCESS')  THEN
     hr_utility.trace('Error:  Illegal tax category for tax type');
     local_error('us_tax_balance',5);
  END IF;
--
-- return 0 for currently unsupported EIC balances.
-- skutteti added 403,457 and Pre tax REDNS
--
  IF l_tax_type = 'EIC' and (l_tax_balance_category = 'SUBJ_NWHABLE'   or
                             l_tax_balance_category = '401_REDNS'      or
                             l_tax_balance_category = '125_REDNS'      or
                             l_tax_balance_category = 'DEP_CARE_REDNS' or
                             l_tax_balance_category = '403_REDNS'      or
                             l_tax_balance_category = '457_REDNS'      or
                             l_tax_balance_category = 'PRE_TAX_REDNS'  ) THEN
    return 0;
  END IF;
ELSE       -- limit tax
  IF l_tax_balance_category = 'SUBJ_NWHABLE' THEN
    return 0;
  END IF;
END IF;
--
 hr_utility.set_location('pay_tax_bals_pkg',100);
--
l_ee_or_er := ltrim(rtrim(p_ee_or_er));
--
--------------- Some Error Checking -------------
--
--
if (l_tax_type = 'FIT' or l_tax_type = 'SIT' or l_tax_type = 'CITY' or
    l_tax_type = 'COUNTY' or l_tax_type = 'EIC' or l_tax_type = 'SCHOOL') THEN
  if l_ee_or_er = 'ER' THEN
     hr_utility.trace('Error:  ER not allowed for tax type');
     local_error('us_tax_balance',6);
  else
    l_ee_or_er := NULL;
  end if;
elsif (l_tax_type = 'FUTA' or l_tax_type = 'HT') THEN
  if l_ee_or_er = 'EE' THEN
     hr_utility.trace('Error:  EE not allowed for tax type');
     local_error('us_tax_balance',7);
  else
    l_ee_or_er := NULL;
  end if;
elsif (l_tax_type = 'SS' or l_tax_type = 'MEDICARE' or l_tax_type = 'SDI' or
       l_tax_type = 'SUI') THEN
  if (l_ee_or_er <> 'EE' and l_ee_or_er <> 'ER') THEN
     hr_utility.trace('Error:  EE or ER required for tax type');
     local_error('us_tax_balance',8);
  end if;
end if;
--
 hr_utility.set_location('pay_tax_bals_pkg',110);
--
-- Force space at end of this parameter if necessary
--
 hr_utility.set_location('pay_tax_bals_pkg',120);
--
IF l_ee_or_er IS NOT NULL THEN
  l_ee_or_er := rtrim(l_ee_or_er)||' ';
END IF;
--
--  Set up dimension strings
--
IF p_asg_type <> 'GRE' THEN
  l_dimension_string := p_asg_type||'_GRE_'||p_time_type;
  l_jd_dimension_string := p_asg_type||'_JD_GRE_'||p_time_type;
ELSE
--
  l_dimension_string := 'GRE_'||p_time_type;
  l_jd_dimension_string := 'GRE_JD_'||p_time_type;
--
  l_assignment_id := p_assignment_id;
--
END IF;

IF p_time_type = 'PAYMENTS' THEN
--
-- 333594 payments_jd dimension is defunct
-- removed following line
--  l_jd_dimension_string := p_time_type||'_JD';
--
  l_dimension_string := p_time_type;
  l_jd_dimension_string := p_time_type;

END IF;
--
--
--  Check if the tax is federal or not.
--
SELECT count(*)
INTO   l_test
FROM   sys.dual
WHERE  l_tax_type in ('FIT','FUTA','MEDICARE','SS','EIC');
--
IF l_test <> 0 THEN   -- yes, the tax is federal
--
  IF l_tax_balance_category = 'GROSS' THEN
    l_return_value := call_balance_user_exit ('GROSS_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
    --
    -- The if condition was added by subbu on 15-sep-2000
    --
    IF l_tax_type = 'FIT' AND l_return_value > 0 THEN
       l_return_value := l_return_value -
                     call_balance_user_exit ('ALIEN_EXPAT_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
    END IF;
--
  ELSIF l_tax_balance_category = 'SUBJ_WHABLE' THEN
    l_return_value := call_balance_user_exit ('REGULAR_EARNINGS',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id)
                   + call_balance_user_exit (
                                   'SUPPLEMENTAL_EARNINGS_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
--
  ELSIF l_tax_balance_category = 'SUBJ_NWHABLE' THEN
    l_return_value := call_balance_user_exit (
                                'SUPPLEMENTAL_EARNINGS_FOR_NW'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
--
  ELSIF l_tax_balance_category = '401_REDNS' THEN
  l_return_value :=   call_balance_user_exit ('DEF_COMP_401K',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                    - call_balance_user_exit ('DEF_COMP_401K_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                              ('FIT_NON_W2_DEF_COMP_401',
                                               l_dimension_string,
                                               l_assignment_action_id,
                                               p_business_group_id);
         END IF;
	END IF;
--
  ELSIF l_tax_balance_category = '125_REDNS' THEN
    l_return_value := call_balance_user_exit ('SECTION_125',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                    - call_balance_user_exit ('SECTION_125_FOR_'||l_tax_type,
                                            'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                              ('FIT_NON_W2_SECTION_125',
                                               l_dimension_string,
                                               l_assignment_action_id,
                                               p_business_group_id);
         END IF;
	END IF;
--
  ELSIF l_tax_balance_category = 'DEP_CARE_REDNS' THEN
    l_return_value := call_balance_user_exit ('DEPENDENT_CARE',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
               - call_balance_user_exit ('DEPENDENT_CARE_FOR_'||l_tax_type,
                                      'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                              ('FIT_NON_W2_DEPENDENT_CARE',
                                               l_dimension_string,
                                               l_assignment_action_id,
                                               p_business_group_id);
         END IF;
	END IF;
  -------------------------------------------------------------------------------
  -- skutteti added the following: 403,457 and PRE_TAX as part of the pre-tax
  -- enhancements
  -------------------------------------------------------------------------------
  ELSIF l_tax_balance_category = 'PRE_TAX_REDNS' THEN
        l_return_value :=   call_balance_user_exit ('PRE_TAX_DEDUCTIONS',
                                                    l_dimension_string,
                                                    l_assignment_action_id,
                                                    p_business_group_id);
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value - call_balance_user_exit (
                                              'PRE_TAX_DEDUCTIONS_FOR_'||l_tax_type,
                                              'SUBJECT_TO_TAX_'||l_dimension_string,
                                              l_assignment_action_id,
                                              p_business_group_id);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                              ('FIT_NON_W2_PRE_TAX_DEDNS',
                                               l_dimension_string,
                                               l_assignment_action_id,
                                               p_business_group_id);
         END IF;
     --
     END IF;
     --
  ELSIF l_tax_balance_category = '403_REDNS' THEN
     l_return_value :=   call_balance_user_exit ('DEF_COMP_403B',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
	IF ( l_return_value <> 0 ) THEN
	   l_return_value := l_return_value - call_balance_user_exit (
                                             'DEF_COMP_403B_FOR_'||l_tax_type,
                                             'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                              ('FIT_NON_W2_DEF_COMP_403',
                                               l_dimension_string,
                                               l_assignment_action_id,
                                               p_business_group_id);
         END IF;
	END IF;
	--
  ELSIF l_tax_balance_category = '457_REDNS' THEN
     l_return_value :=   call_balance_user_exit ('DEF_COMP_457',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
	IF ( l_return_value <> 0 ) THEN
	   l_return_value := l_return_value - call_balance_user_exit (
                                             'DEF_COMP_457_FOR_'||l_tax_type,
                                             'SUBJECT_TO_TAX_'||l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
         --
         -- added by skutteti in Nov 2000, to remove the Non W2 portion
         --
         IF l_tax_type = 'FIT' THEN
            l_return_value := l_return_value - call_balance_user_exit
                                              ('FIT_NON_W2_DEF_COMP_457',
                                               l_dimension_string,
                                               l_assignment_action_id,
                                               p_business_group_id);
         END IF;
	END IF;
	--
  ELSIF l_tax_balance_category = 'TAXABLE' THEN
    l_return_value := call_balance_user_exit (l_tax_type||'_'||
                                              l_ee_or_er||'TAXABLE',
                                             l_dimension_string,
                                             l_assignment_action_id,
                                             p_business_group_id);
--
  ELSIF (l_tax_balance_category = 'WITHHELD' or
         l_tax_balance_category = 'LIABILITY' or
         l_tax_balance_category = 'ADVANCE') THEN
    l_return_value := call_balance_user_exit (
                           l_tax_type||'_'||l_ee_or_er||l_tax_balance_category,
                                           l_dimension_string,
                                           l_assignment_action_id,
                                           p_business_group_id);
  END IF;
ELSE   -- the tax is non-federal
--
-- if the tax balance is not derived, get it here.
  IF (l_tax_balance_category <> 'SUBJECT' and
      l_tax_balance_category <> 'EXEMPT' and
      l_tax_balance_category <> 'EXCESS' and
      l_tax_balance_category <> 'REDUCED_SUBJ_WHABLE') THEN
--
-- Use the CITY balances for HT if we don't want to see LIABILITY
--
    IF (l_tax_type = 'HT') THEN
      IF (l_tax_balance_category <> 'LIABILITY') THEN
        l_tax_type := 'CITY';
      ELSE
        l_tax_type := 'HEAD TAX';
      END IF;
    END IF;
--
    l_return_value := call_balance_user_exit (
                    l_tax_type||'_'||l_ee_or_er||l_tax_balance_category,
                                           l_jd_dimension_string,
                                           l_assignment_action_id,
                                           p_business_group_id);
/*  The following code was commented by tmehra as SIT Redns is now
    directly being reduced by the feeds.
    --
    -- added by skutteti to remove the non w2 portion for pre tax REDNS
    --
    IF (l_return_value <> 0                   AND
       l_tax_type      = 'SIT'                AND
       l_tax_balance_category like '%REDNS' ) THEN
       IF l_tax_balance_category = 'PRE_TAX_REDNS' THEN
          l_non_w2_cat := 'NON_W2_PRE_TAX_DEDNS';
       ELSIF l_tax_balance_category = '401_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEF_COMP_401';
       ELSIF l_tax_balance_category = '403_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEF_COMP_403';
       ELSIF l_tax_balance_category = '457_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEF_COMP_457';
       ELSIF l_tax_balance_category = '125_REDNS' THEN
          l_non_w2_cat := 'NON_W2_SECTION_125';
       ELSIF l_tax_balance_category = 'DEP_CARE_REDNS' THEN
          l_non_w2_cat := 'NON_W2_DEPENDENT_CARE';
       END IF;
       l_return_value := l_return_value - call_balance_user_exit (
                                           'SIT_'||l_non_w2_cat,
                                           l_jd_dimension_string,
                                           l_assignment_action_id,
                                           p_business_group_id);
    END IF;

*/

  END IF;
END IF;
--
IF l_tax_balance_category = 'SUBJECT' THEN
  l_return_value := us_tax_balance('SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id)
                 + us_tax_balance('SUBJ_NWHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
--
ELSIF l_tax_balance_category = 'EXEMPT' THEN
  l_return_value := us_tax_balance('GROSS',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                 - us_tax_balance('SUBJECT',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
	END IF;
--
ELSIF l_tax_balance_category = 'REDUCED_SUBJ_WHABLE' THEN
  l_return_value := us_tax_balance('SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
        /***************************************************************
         * skutteti commented all the individual pre-tax categories and
         * replaced it by PRE_TAX_REDNS
         ***************************************************************/
         -- l_return_value := l_return_value
         --        - us_tax_balance('401_REDNS',
         --                         l_tax_type,
         --                         p_ee_or_er,
         --                         p_time_type,
         --                         p_asg_type,
         --                         p_gre_id_context,
         --                         p_jd_context,
         --                         l_assignment_action_id,
         --                         l_assignment_id,
         --                         l_virtual_date,
         --                         p_business_group_id)
         --        - us_tax_balance('125_REDNS',
         --                         l_tax_type,
         --                         p_ee_or_er,
         --                         p_time_type,
         --                         p_asg_type,
         --                         p_gre_id_context,
         --                         p_jd_context,
         --                         l_assignment_action_id,
         --                         l_assignment_id,
         --                         l_virtual_date,
         --                         p_business_group_id)
         --        - us_tax_balance('DEP_CARE_REDNS',
         --                         l_tax_type,
         --                         p_ee_or_er,
         --                         p_time_type,
         --                         p_asg_type,
         --                         p_gre_id_context,
         --                         p_jd_context,
         --                         l_assignment_action_id,
         --                         l_assignment_id,
         --                         l_virtual_date,
         --                         p_business_group_id);
         /**********************************************************
          *            skutteti added the following part
          **********************************************************/
         l_return_value := l_return_value - us_tax_balance(
                                  'PRE_TAX_REDNS',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
	END IF;
--
ELSIF l_tax_balance_category = 'EXCESS' THEN
  l_return_value := us_tax_balance('REDUCED_SUBJ_WHABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
	--
	-- 337641
	-- check if balance 0 therefore no need to
	-- subtract subsequent balance
	--
	IF ( l_return_value <> 0 )
	THEN
	l_return_value := l_return_value
                 - us_tax_balance('TAXABLE',
                                  l_tax_type,
                                  p_ee_or_er,
                                  p_time_type,
                                  p_asg_type,
                                  p_gre_id_context,
                                  p_jd_context,
                                  l_assignment_action_id,
                                  l_assignment_id,
                                  l_virtual_date,
                                  p_business_group_id);
	END IF;
END IF;
--
hr_utility.trace('Returning : ' || l_return_value);
--
return l_return_value;
--
END us_tax_balance;
--
BEGIN
   g_nxt_free_defbal := 1;
END pay_us_tax_balance_perf;

/

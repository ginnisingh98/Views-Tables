--------------------------------------------------------
--  DDL for Package Body PAY_PRETAX_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRETAX_UDFS" AS
/* $Header: pyptxudf.pkb 115.3 99/07/17 06:26:52 porting ship  $ */
FUNCTION pretax_period_type (	p_date_earned	in date,
				p_eletype_id	in number) return varchar2 IS

l_ptx_period_type	varchar2(150);

BEGIN

SELECT	nvl(etype.element_information4, 'NOT ENTERED')
INTO	l_ptx_period_type
FROM	pay_element_types_f            	ETYPE
WHERE  	ETYPE.element_information20	= p_eletype_id
AND	p_date_earned BETWEEN ETYPE.effective_start_date
		          AND ETYPE.effective_end_date;

RETURN l_ptx_period_type;

EXCEPTION when no_data_found THEN

  l_ptx_period_type := 'NOT ENTERED';
  RETURN l_ptx_period_type;

END pretax_period_type;

FUNCTION pretax_row_type (	p_date_earned	in date,
				p_eletype_id	in number) return varchar2 IS

l_ptx_row_type	varchar2(150);

BEGIN

SELECT	NVL(etype.element_information7, 'NOT ENTERED')
INTO	l_ptx_row_type
FROM	pay_element_types_f            	ETYPE
WHERE  	ETYPE.element_information20	= p_eletype_id
AND	p_date_earned BETWEEN ETYPE.effective_start_date
		          AND ETYPE.effective_end_date;

RETURN l_ptx_row_type;

EXCEPTION when no_data_found THEN

  l_ptx_row_type := 'NOT ENTERED';
  RETURN l_ptx_row_type;

END pretax_row_type;


FUNCTION pretax_payroll_table (	p_date_earned	in date,
				p_eletype_id	in number) return varchar2 IS

l_ptx_paytab	varchar2(150);

BEGIN

SELECT	NVL(etype.element_information6, 'NOT ENTERED')
INTO	l_ptx_paytab
FROM	pay_element_types_f            	ETYPE
WHERE  	ETYPE.element_information20	= p_eletype_id
AND	p_date_earned BETWEEN ETYPE.effective_start_date
		          AND ETYPE.effective_end_date;

RETURN l_ptx_paytab;

EXCEPTION when no_data_found THEN

  l_ptx_paytab := 'NOT ENTERED';
  RETURN l_ptx_paytab;

END pretax_payroll_table;


FUNCTION pretax_ben_ee_contr (	p_date_earned	in date,
				p_eletype_id	in number,
				p_coverage	in varchar2) return number is

l_ee_contr	number;

BEGIN

SELECT fnd_number.canonical_to_number(BCONTR.employee_contribution)
INTO   l_ee_contr
FROM   pay_element_types_f PET,
       ben_benefit_contributions_f BCONTR
WHERE  PET.element_information20 = p_eletype_id
AND    BCONTR.element_type_id = PET.element_type_id
AND    BCONTR.coverage_type = p_coverage
AND    p_date_earned BETWEEN BCONTR.effective_start_date
                         AND BCONTR.effective_end_date;

RETURN l_ee_contr;

exception when NO_DATA_FOUND then

  l_ee_contr := 0;
  RETURN l_ee_contr;

END pretax_ben_ee_contr;


FUNCTION pretax_ben_er_contr (	p_date_earned	in date,
				p_eletype_id	in number,
				p_coverage	in varchar2) return number is

l_er_contr	number;

BEGIN

SELECT fnd_number.canonical_to_number(BCONTR.employer_contribution)
INTO   l_er_contr
FROM   pay_element_types_f PET,
       ben_benefit_contributions_f BCONTR
WHERE  PET.element_information20 = p_eletype_id
AND    BCONTR.element_type_id = PET.element_type_id
AND    BCONTR.coverage_type = p_coverage
AND    p_date_earned BETWEEN BCONTR.effective_start_date
                         AND BCONTR.effective_end_date;

RETURN l_er_contr;

exception when NO_DATA_FOUND THEN

  l_er_contr := 0;
  RETURN l_er_contr;

END pretax_ben_er_contr;


END pay_pretax_udfs;

/

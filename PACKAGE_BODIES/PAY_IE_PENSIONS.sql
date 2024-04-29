--------------------------------------------------------
--  DDL for Package Body PAY_IE_PENSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PENSIONS" as
/* $Header: pyiepenf.pkb 120.1 2005/07/05 02:44:40 rrajaman noship $ */
FUNCTION IE_GET_MAX_PENSION_PERCENT(
      p_assgt_id NUMBER,
	  p_date_earned DATE,
      prsa2 NUMBER)
      RETURN NUMBER
IS
   l_age number;
   l_percent number;
   BEGIN
   SELECT DISTINCT floor(months_between(p_date_earned,p.date_of_birth)/12) into l_age
   FROM per_all_people_f p, per_all_assignments_f a
   WHERE a.person_id=p.person_id AND a.assignment_id=p_assgt_id;
   IF prsa2 = 0 THEN
     SELECT i.value INTO l_percent
	 FROM pay_user_tables t, pay_user_columns c, pay_user_rows_f r, pay_user_column_instances_f i
	 WHERE t.user_table_name = 'IE PRSA Certificate Rates'
	 AND t.user_table_id=c.user_table_id
	 AND t.user_table_id=r.user_table_id
	 AND i.user_column_id=c.user_column_id
	 AND i.user_row_id=r.user_row_id
     AND c.user_column_name = 'PRSA1'
	 AND l_age BETWEEN r.row_low_range_or_name AND r.row_high_range
	 AND p_date_earned BETWEEN r.effective_start_date AND r.effective_end_date
 	 AND p_date_earned BETWEEN i.effective_start_date AND i.effective_end_date;
   ELSE
    SELECT i.value INTO l_percent
	FROM pay_user_tables t, pay_user_columns c, pay_user_rows_f r, pay_user_column_instances_f i
	WHERE t.user_table_name = 'IE PRSA Certificate Rates'
	AND t.user_table_id=c.user_table_id
	AND t.user_table_id=r.user_table_id
	AND i.user_column_id=c.user_column_id
	AND i.user_row_id=r.user_row_id
    AND c.user_column_name = 'PRSA2'
	AND l_age BETWEEN r.row_low_range_or_name AND r.row_high_range
	AND p_date_earned BETWEEN r.effective_start_date AND r.effective_end_date
    AND p_date_earned BETWEEN i.effective_start_date AND i.effective_end_date;
   END IF;
   RETURN l_percent;
END IE_GET_MAX_PENSION_PERCENT;

FUNCTION GET_EARNINGS_CAP
( p_date_earned DATE)
RETURN NUMBER
IS
l_amount number;
BEGIN
  SELECT global_value INTO l_amount
  FROM ff_globals_f g
  WHERE g.global_name = 'IE_PENSIONS_EARNINGS_CAP'
  AND p_date_earned BETWEEN g.effective_start_date AND g.effective_end_date;
  RETURN l_amount;
END GET_EARNINGS_CAP;

FUNCTION GET_PENSION_CONTRIBUTION
   (p_date_earned DATE,
    p_contribution_type VARCHAR2,
    p_pension_type_id NUMBER,
	p_pensionable_pay NUMBER)
RETURN NUMBER IS
l_amount number;
l_percent number;
BEGIN
l_amount := 0;
l_percent := 0;
IF p_contribution_type='EE' THEN
   SELECT ee_contribution_percent, ee_annual_contribution
   INTO l_percent, l_amount
   FROM pqp_pension_types_f
   WHERE pension_type_id = p_pension_type_id
   AND p_date_earned BETWEEN effective_start_date AND effective_end_date;
   IF l_amount = 0 or l_amount is null THEN
     l_amount := p_pensionable_pay*nvl(l_percent,0)/100;
   END IF;
ELSE
   SELECT er_contribution_percent, er_annual_contribution
   INTO l_percent, l_amount
   FROM pqp_pension_types_f
   WHERE pension_type_id = p_pension_type_id
   AND p_date_earned BETWEEN effective_start_date AND effective_end_date;
   IF l_amount = 0 or l_amount is null THEN
     l_amount := p_pensionable_pay*nvl(l_percent,0)/100;
   END IF;
END IF;
RETURN l_amount;
END GET_PENSION_CONTRIBUTION;

END pay_ie_pensions;

/

--------------------------------------------------------
--  DDL for Package Body PAY_CA_WAT_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_WAT_UDFS" AS
/* $Header: pycagudf.pkb 120.0 2005/05/29 03:33:42 appldev noship $ */
FUNCTION ca_garn_subpriority (p_bus_grp_id		in NUMBER,
			      p_assignment_id		in NUMBER,
			      p_element_entry_id 	in NUMBER,
		   	      p_earned_date		in DATE)
                             RETURN NUMBER IS

CURSOR garn_priority_cursor is
SELECT peef.element_entry_id,
       decode(peef.entry_information1
             ,'P1',1000
             ,'P2',2000
             ,'P3',3000,9000) garn_priority
FROM pay_element_entries_f peef
    ,pay_element_classifications pec
    ,pay_element_types_f petf
    ,pay_element_links_f pelf
WHERE  peef.assignment_id = p_assignment_id
AND    trunc(p_earned_date) between trunc(peef.effective_start_date)
and
          trunc(peef.effective_end_date)
AND    peef.element_link_id = pelf.element_link_id
AND    trunc(p_earned_date) between trunc(pelf.effective_start_date)
and
          trunc(pelf.effective_end_date)
AND    pelf.element_type_id = petf.element_type_id
AND    trunc(p_earned_date) between trunc(petf.effective_start_date)
and
          trunc(petf.effective_end_date)
AND    petf.classification_id = pec.classification_id
AND    pec.classification_name like 'Involuntary Deductions'
ORDER BY decode(peef.entry_information1
               ,'P1',1000
               ,'P2',2000
               ,'P3',3000,9000),
         decode(peef.entry_information3
               ,'ORDER',1
               ,'EQUAL',2
               ,'PROPORTION',2,9),
         peef.entry_information4;

return_priority		NUMBER(4);
counter			NUMBER(4);
v_entry_id		NUMBER(15);
v_garn_priority		NUMBER(4);

BEGIN
	return_priority := 9999;
	counter := 10;
	OPEN garn_priority_cursor;
	LOOP
		FETCH 	garn_priority_cursor
                INTO    v_entry_id, v_garn_priority;
		IF v_entry_id = p_element_entry_id THEN
			return_priority := counter + v_garn_priority;
		END IF;
	EXIT WHEN garn_priority_cursor %NOTFOUND;
	counter := counter + 10;
	END LOOP;
	CLOSE garn_priority_cursor;
	RETURN return_priority;
END;
--
-- ************************************
--
FUNCTION ca_garn_bc_exempt(     p_bus_grp_id                    in NUMBER,
                                p_element_entry_id              in NUMBER,
                                p_pay_periods_per_year          in NUMBER,
                                p_protected_basis               in VARCHAR2,
                                p_gross_di_subject              in NUMBER)
RETURN NUMBER IS

TYPE number_tabtype is TABLE OF NUMBER(15,2) INDEX BY BINARY_INTEGER;

bc_band                 number_tabtype;
bc_break                number_tabtype;
di_subject_exemption    NUMBER(15,2);

BEGIN
--
-- Set Legislation Defined Exemption Percentages
--
        di_subject_exemption := 0;
        IF p_protected_basis = 'BC_MS_PRE' THEN
                bc_band(1) := 65;
                bc_band(2) := 50;
                bc_band(3) := 45;
        ELSIF p_protected_basis = 'BC_MS_POST' THEN
                bc_band(1) := 75;
                bc_band(2) := 60;
                bc_band(3) := 55;
        ELSE
                RETURN di_subject_exemption;
        END IF;
--
-- Set Legislation Defined Exemption Breakpoints for
-- specific payroll frequency
--
        IF p_pay_periods_per_year = 52 THEN
                bc_break(1) := 150;
                bc_break(2) := 520;
                bc_break(3) := 1155;
        ELSIF p_pay_periods_per_year = 26 THEN
                bc_break(1) := 300;
                bc_break(2) := 1040;
                bc_break(3) := 2310;
        ELSIF p_pay_periods_per_year = 24 THEN
                bc_break(1) := 325;
                bc_break(2) := 1125;
                bc_break(3) := 2500;
        ELSIF p_pay_periods_per_year = 12 THEN
                bc_break(1) := 650;
                bc_break(2) := 2250;
                bc_break(3) := 5000;
        ELSE
                RETURN di_subject_exemption;
        END IF;
--
-- Calculate di_subject_exemption
--
        di_subject_exemption := least(bc_break(1),p_gross_di_subject);
        IF p_gross_di_subject > bc_break(1) THEN
                di_subject_exemption := di_subject_exemption+
                ((greatest(least(bc_break(2),p_gross_di_subject),bc_break(1))-bc_break(1))*bc_band(1)/100);
        END IF;
        IF p_gross_di_subject > bc_break(2) THEN
                di_subject_exemption := di_subject_exemption+
                ((greatest(least(bc_break(3),p_gross_di_subject),bc_break(2))-bc_break(2))*bc_band(2)/100);
        END IF;
        IF p_gross_di_subject > bc_break(3) THEN
                di_subject_exemption := di_subject_exemption+
                ((greatest(bc_break(3),p_gross_di_subject)-bc_break(3))*bc_band(3)/100);
        END IF;
        RETURN di_subject_exemption;
END;
END;

/

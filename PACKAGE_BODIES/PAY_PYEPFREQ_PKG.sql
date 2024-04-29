--------------------------------------------------------
--  DDL for Package Body PAY_PYEPFREQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYEPFREQ_PKG" AS
/* $Header: pyepf01t.pkb 120.2 2005/06/15 06:36:21 susivasu noship $ */
--
PROCEDURE hr_ele_pay_freq_rules (
				p_context	IN VARCHAR2,
				p_eletype_id	IN NUMBER,
				p_payroll_id	IN NUMBER,
				p_period_type	IN VARCHAR2,
				p_bg_id		IN NUMBER,
				p_period_1	IN OUT NOCOPY VARCHAR2,
				p_period_2	IN OUT NOCOPY VARCHAR2,
				p_period_3	IN OUT NOCOPY VARCHAR2,
				p_period_4	IN OUT NOCOPY VARCHAR2,
				p_period_5	IN OUT NOCOPY VARCHAR2,
				p_period_6	IN OUT NOCOPY VARCHAR2,
				p_eff_date	IN DATE	    DEFAULT NULL,
                                p_rule_date_code IN VARCHAR2 DEFAULT NULL,
                                p_leg_code      IN VARCHAR2 DEFAULT NULL) IS
-- local constants
c_months_per_fiscal_yr	NUMBER(3) := 12;
c_max_freq_periods	NUMBER(3) := 5;
-- local vars
v_ele_pay_freq_rule_id	NUMBER(9);
v_freq_rule_period_id	NUMBER(9);
v_freq_rule_start_date	DATE	:= TO_DATE('01-01-1900', 'DD-MM-YYYY');
v_reset_periods		NUMBER(3)	:= 1;
v_reset_period_type	VARCHAR2(30);
v_number_per_fy		NUMBER(3);
v_eff_start_date	DATE;
--
-- Local procedure
--
  PROCEDURE ins_freq_rule_period(
			p_ele_freqrule_id 		IN NUMBER,
			p_period_no_in_reset_period 	IN NUMBER,
			p_bus_grp_id			IN NUMBER,
			p_eff_start_date		IN DATE) IS
-- local proc local vars
  v_freq_rule_pd_id	NUMBER(9);

  BEGIN
--
    SELECT 	pay_freq_rule_periods_s.nextval
    INTO	v_freq_rule_pd_id
    FROM	sys.dual;
--
    INSERT INTO	pay_freq_rule_periods (
	freq_rule_period_id,
	ele_payroll_freq_rule_id,
	business_group_id,
	period_no_in_reset_period,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login)
    VALUES (
	v_freq_rule_pd_id,
	p_ele_freqrule_id,
	p_bus_grp_id,
	p_period_no_in_reset_period,
	p_eff_start_date,
	-1,
	NULL,
	NULL,
	NULL);
--
  END ins_freq_rule_period;
--
-- Local Function
--
  FUNCTION chk_freq_rule_exists (	p_ele_id IN NUMBER,
					p_pay_id IN NUMBER,
					p_bus_grp_id IN NUMBER,
					p_period_num IN NUMBER)
				RETURN VARCHAR2 IS
-- local fn vars
  v_freq_rule_exists VARCHAR2(1);
--
  BEGIN
--
    v_freq_rule_exists := 'N';
    begin
--
    SELECT	'Y'
    INTO	v_freq_rule_exists
    FROM	pay_ele_payroll_freq_rules	EPF,
		pay_freq_rule_periods 		FRP
    WHERE	FRP.period_no_in_reset_period	= p_period_num
    AND		FRP.ele_payroll_freq_rule_id	= EPF.ele_payroll_freq_rule_id
    AND 	EPF.business_group_id + 0		= p_bus_grp_id
    AND		EPF.payroll_id			= p_pay_id
    AND		EPF.element_type_id		= p_ele_id;
--
    RETURN v_freq_rule_exists;
--
    exception
      WHEN NO_DATA_FOUND THEN
        RETURN v_freq_rule_exists;
    end;
--
  END chk_freq_rule_exists;
--
  BEGIN	-- main procedure, hr_ele_freq_rules
--
IF UPPER(p_context) = 'ON-UPDATE' THEN
  v_eff_start_date := nvl(p_eff_date, sysdate);
--
-- Clear the cache.
--
  remove_freq_rule_period(p_ele_type_id => p_eletype_id
                         ,p_payroll_id  => p_payroll_id);
--
--
-- Delete existing frequency rules:
--
begin

  hr_utility.set_location('pay_pyepfreq_pkg', 10);

  SELECT 	ele_payroll_freq_rule_id
  INTO		v_ele_pay_freq_rule_id
  FROM		pay_ele_payroll_freq_rules
  WHERE		element_type_id 	= p_eletype_id
  AND		payroll_id		= p_payroll_id
  AND		business_group_id + 0	= p_bg_id;
--
  hr_utility.set_location('pay_pyepfreq_pkg', 20);
  DELETE FROM 	pay_ele_payroll_freq_rules
  WHERE 	ele_payroll_freq_rule_id = v_ele_pay_freq_rule_id;
--
  hr_utility.set_location('pay_pyepfreq_pkg', 30);
  DELETE FROM 	pay_freq_rule_periods
  WHERE 	ele_payroll_freq_rule_id = v_ele_pay_freq_rule_id;
--
-- If either of the above fail, then it's ok, we're just cleaning up
-- before insertion of "new" rule.
--
exception
  WHEN NO_DATA_FOUND THEN NULL;
end;
--
-- Insert new frequency rules:
--
-- set reset period type: if pay period is <= Month, then reset period = Month;
--			  if pay pd > Month then reset period = Year;
-- Note, if pay pd = Month, then freq rules defined by Deductions form do not
-- really make sense; would need a new interface to define a deduction freq
-- of, say, every other month or every third month.
--
begin

  hr_utility.set_location('pay_pyepfreq_pkg', 40);
  SELECT 	number_per_fiscal_year
  INTO		v_number_per_fy
  FROM 		per_time_period_types
  WHERE		period_type 	= p_period_type;
--
  IF v_number_per_fy >= c_months_per_fiscal_yr THEN
    v_reset_period_type := 'Calendar Month';
  ELSE
    v_reset_period_type := 'Year';
  END IF;
--
exception
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_message('PAY', 'HR_COULD_NOT_FIND_PERIOD_TYPE');
    hr_utility.raise_error;
end;
--
-- Now, insertion:
--
if (UPPER(p_period_1) = 'Y' or
    UPPER(p_period_2) = 'Y' or
    UPPER(p_period_3) = 'Y' or
    UPPER(p_period_4) = 'Y' or
    UPPER(p_period_5) = 'Y' )
then
  hr_utility.set_location('pay_pyepfreq_pkg', 50);
  SELECT 	pay_ele_payroll_freq_rules_s.nextval
  INTO		v_ele_pay_freq_rule_id
  FROM		sys.dual;
--
  hr_utility.set_location('pay_pyepfreq_pkg', 60);
  INSERT INTO pay_ele_payroll_freq_rules (
  	  ele_payroll_freq_rule_id,
	  element_type_id,
	  payroll_id,
	  business_group_id,
	  start_date,
	  reset_no_of_periods,
	  reset_period_type,
          rule_date_code,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login)
  VALUES (
	  v_ele_pay_freq_rule_id,
	  p_eletype_id,
	  p_payroll_id,
	  p_bg_id,
	  v_freq_rule_start_date,
	  v_reset_periods,
	  v_reset_period_type,
          p_rule_date_code,
	  v_eff_start_date,
	  -1,
	  NULL,
	  NULL,
	  NULL
         );
end if;
--
-- insert freq rule period where period_n = 'Y'
--
  IF UPPER(p_period_1) = 'Y' THEN
    hr_utility.set_location('pay_pyepfreq_pkg', 70);
    ins_freq_rule_period(	v_ele_pay_freq_rule_id,
				1,
				p_bg_id,
				v_eff_start_date);
  END IF;
  IF UPPER(p_period_2) = 'Y' THEN
    hr_utility.set_location('pay_pyepfreq_pkg', 80);
    ins_freq_rule_period(	v_ele_pay_freq_rule_id,
				2,
				p_bg_id,
				v_eff_start_date);
  END IF;
  IF UPPER(p_period_3) = 'Y' THEN
    hr_utility.set_location('pay_pyepfreq_pkg', 90);
    ins_freq_rule_period(	v_ele_pay_freq_rule_id,
				3,
				p_bg_id,
				v_eff_start_date);
  END IF;
  IF UPPER(p_period_4) = 'Y' THEN
    hr_utility.set_location('pay_pyepfreq_pkg', 100);
    ins_freq_rule_period(	v_ele_pay_freq_rule_id,
				4,
				p_bg_id,
				v_eff_start_date);
  END IF;
  IF UPPER(p_period_5) = 'Y' THEN
    hr_utility.set_location('pay_pyepfreq_pkg', 110);
    ins_freq_rule_period(	v_ele_pay_freq_rule_id,
				5,
				p_bg_id,
				v_eff_start_date);
  END IF;
  IF UPPER(p_period_6) = 'Y' THEN
    hr_utility.set_location('pay_pyepfreq_pkg', 120);
    ins_freq_rule_period(       v_ele_pay_freq_rule_id,
                                6,
                                p_bg_id,
                                v_eff_start_date);
  END IF;

--
ELSIF upper(p_context) = 'POST-QUERY' THEN
-- We need to populate the 5 period params and pass them back.
  p_period_1 := get_freq_rule_period(	p_eletype_id,
				 	p_payroll_id,
					p_bg_id,
					1);

  p_period_2 := get_freq_rule_period(	p_eletype_id,
				 	p_payroll_id,
					p_bg_id,
					2);

  p_period_3 := get_freq_rule_period(	p_eletype_id,
				 	p_payroll_id,
					p_bg_id,
					3);

  p_period_4 := get_freq_rule_period(	p_eletype_id,
				 	p_payroll_id,
					p_bg_id,
					4);

  p_period_5 := get_freq_rule_period(	p_eletype_id,
				 	p_payroll_id,
					p_bg_id,
					5);

  p_period_6 := get_freq_rule_period(   p_eletype_id,
                                        p_payroll_id,
                                        p_bg_id,
                                        6);

--
END IF; -- context
--
END hr_ele_pay_freq_rules;
--

/*
  Name      : get_freq_rule_period
  Purpose   : This function will populate the frequency rule data for all
              periods in the first call and stores in  plsql table.
  Arguments : p_ele_type_id, p_payroll_id, p_bus_grp_id, p_period_num.
  Notes     :
 */

FUNCTION get_freq_rule_period(	p_ele_type_id IN NUMBER,
                                p_payroll_id IN NUMBER,
                                p_bus_grp_id IN NUMBER,
                                p_period_num IN NUMBER)
RETURN VARCHAR2 IS

   ln_rec_index NUMBER;

  -- local procedure
   FUNCTION populate_freq_rule_table(p_element_type_id NUMBER,
                                     p_payroll_id NUMBER,
                                     p_bg_id NUMBER)
     RETURN NUMBER IS

     CURSOR c_get_freq_rule_period(cp_ele_type_id number,
                                cp_payroll_id number,
                                cp_bg_id number,
                                cp_period_num number)
     IS
     SELECT  'Y', EPF.rule_date_code
     FROM     pay_ele_payroll_freq_rules      EPF,
              pay_freq_rule_periods           FRP
     WHERE    FRP.period_no_in_reset_period   = cp_period_num
     AND      FRP.ele_payroll_freq_rule_id    = EPF.ele_payroll_freq_rule_id
     AND      EPF.business_group_id + 0       = cp_bg_id
     AND      EPF.payroll_id                  = cp_payroll_id
     AND      EPF.element_type_id             = cp_ele_type_id;

   -- local populate_freq_rule_table procedure vars

      lv_freq_rule_exists VARCHAR2(1);
      lv_rule_date_code VARCHAR2(1);
      ln_index2 number;
      lv_record_found VARCHAR2(1);

   -- start of populate_freq_rule_table procedure
   BEGIN
       lv_record_found := 'N';
       hr_utility.trace('start of populate_freq_rule_table ');
       hr_utility.trace('table rec ln_index2 = '||to_char(ln_index2));
       hr_utility.trace('element_type_id = '||to_char(p_element_type_id));
       hr_utility.trace('payroll_id = '||to_char(p_payroll_id));
       hr_utility.trace('business_group_id = '||to_char(p_bg_id));

       if pay_pyepfreq_pkg.g_freq_rule_table.count > 0 then
          hr_utility.trace('g_freq_rule_table.count > 0 satisfied ');
          for i in g_freq_rule_table.first..g_freq_rule_table.last
          loop
                hr_utility.trace('record i = '||to_char(i));
             if g_freq_rule_table(i).element_type_id = p_ele_type_id and
                g_freq_rule_table(i).payroll_id = p_payroll_id then

                hr_utility.trace('record found in g_freq_rule_table ');
                lv_record_found := 'Y';
                ln_index2 := i;
                exit;

             end if;

          end loop; -- g_freq_rule_table.first..g_freq_rule_table.last
       end if; --pay_pyepfreq_pkg.g_freq_rule_table.count > 0

       if lv_record_found = 'N' then
          ln_index2 := pay_pyepfreq_pkg.g_freq_rule_table.count;
          pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).element_type_id :=
                                                            p_element_type_id;
          pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).payroll_id :=
                                                            p_payroll_id;
          pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).business_group_id :=
                                                            p_bg_id;

          for i in 1..6 loop
              lv_freq_rule_exists := null;
              hr_utility.trace('for loop to get all period values i = '||
                                to_char(i));
              open c_get_freq_rule_period(p_element_type_id, p_payroll_id,
                                          p_bg_id, i);
              fetch c_get_freq_rule_period into lv_freq_rule_exists,
                                                lv_rule_date_code;
              close c_get_freq_rule_period;

              hr_utility.trace('period i value = '||lv_freq_rule_exists);
              if lv_freq_rule_exists is null then
                 hr_utility.trace('period i values is null satisfied ');
                 lv_freq_rule_exists := 'N';
              end if;

              if i = 1 then
                hr_utility.trace('period 1 = '||lv_freq_rule_exists);
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).period_1 :=
                                                  lv_freq_rule_exists;
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).rule_date_code :=
                                                   lv_rule_date_code;
              elsif i = 2 then
                hr_utility.trace('period 2 = '||lv_freq_rule_exists);
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).period_2 :=
                                                   lv_freq_rule_exists;
              elsif i = 3 then
                hr_utility.trace('period 3 = '||lv_freq_rule_exists);
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).period_3 :=
                                                   lv_freq_rule_exists;
              elsif i = 4 then
                hr_utility.trace('period 4 = '||lv_freq_rule_exists);
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).period_4 :=
                                                   lv_freq_rule_exists;
              elsif i = 5 then
                hr_utility.trace('period 5 = '||lv_freq_rule_exists);
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).period_5 :=
                                                   lv_freq_rule_exists;
              elsif i = 6 then
                hr_utility.trace('period 6 = '||lv_freq_rule_exists);
                pay_pyepfreq_pkg.g_freq_rule_table(ln_index2).period_6 :=
                                                   lv_freq_rule_exists;
              end if;

          end loop;
          hr_utility.trace('End of populate_freq_rule_table function');

       end if; -- lv_record_found = 'N'

        return ln_index2;
    END populate_freq_rule_table;
   -- end of populate_freq_rule_table procedure

--  start of get_freq_rule_period function
  BEGIN
         hr_utility.trace('Start of get_freq_rule_period function');
         hr_utility.trace('Element type id: '||to_char(p_ele_type_id));
         hr_utility.trace('Payroll id: '||to_char(p_payroll_id));
         hr_utility.trace('Business Group id: '||to_char(p_bus_grp_id));
         hr_utility.trace('Period Number: '||to_char(p_period_num));

         ln_rec_index := populate_freq_rule_table(p_ele_type_id,
                                                  p_payroll_id,
                                                  p_bus_grp_id);
         if p_period_num = 1 then
            return g_freq_rule_table(ln_rec_index).period_1;
         elsif p_period_num = 2 then
            return g_freq_rule_table(ln_rec_index).period_2;
         elsif p_period_num = 3 then
            return g_freq_rule_table(ln_rec_index).period_3;
         elsif p_period_num = 4 then
            return g_freq_rule_table(ln_rec_index).period_4;
         elsif p_period_num = 5 then
            return g_freq_rule_table(ln_rec_index).period_5;
         elsif p_period_num = 6 then
            return g_freq_rule_table(ln_rec_index).period_6;
         elsif p_period_num = 0 then
            return g_freq_rule_table(ln_rec_index).rule_date_code;
         end if;

         hr_utility.trace('End of get_freq_rule_period function');

  END get_freq_rule_period;
--
PROCEDURE remove_freq_rule_period(p_ele_type_id IN NUMBER,
                                  p_payroll_id IN NUMBER) is

begin
   if pay_pyepfreq_pkg.g_freq_rule_table.count > 0 then
      for i in g_freq_rule_table.first..g_freq_rule_table.last
      loop
         if (g_freq_rule_table(i).element_type_id = p_ele_type_id
             and g_freq_rule_table(i).payroll_id = p_payroll_id) then
                --
                g_freq_rule_table(i).element_type_id := NULL;
                g_freq_rule_table(i).payroll_id := NULL;
                exit;
                --
         end if;
      end loop;
   end if;
end remove_freq_rule_period;
--

/*
  Name      : initialise_freqrule_table
  Purpose   : This procedure will delete the plsql tables used for
              frequency rule data.
  Arguments :
  Notes     :
 */

  procedure initialise_freqrule_table is

  BEGIN

    hr_utility.trace('deleting g_freq_rule_table plsql table');

    pay_pyepfreq_pkg.g_freq_rule_table.delete;

  END initialise_freqrule_table;

END pay_pyepfreq_pkg;

/

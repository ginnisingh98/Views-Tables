--------------------------------------------------------
--  DDL for Package Body PQH_FR_PROGRESSION_POINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_PROGRESSION_POINT_PKG" as
/* $Header: pqfrpspp.pkb 120.0.12000000.2 2007/02/27 13:31:56 spendhar noship $ */

PROCEDURE update_sal_rate_for_point(p_spinal_point_id in number,
                                    p_parent_spine_id in number,
                                    p_information_category in varchar2,
                                    p_information1    in varchar2,
                                    p_information1_o  in varchar2,
                                    p_information2    in varchar2,
                                    p_information2_o  in varchar2) IS

CURSOR csr_scale_type IS
 SELECT information_category,information1
 FROM   per_parent_spines
 WHERE  parent_spine_id = p_parent_spine_id;

 CURSOR csr_rate_ovn(p_grd_rule_id NUMBER) IS
   SELECT object_version_number
   FROM   pay_grade_rules_f
   WHERE  grade_rule_id = p_grd_rule_id
   AND    TRUNC(SYSDATE) between effective_start_date and effective_end_date;

l_scale_type varchar2(30);
l_scale_info_catg varchar2(30);
l_hr_rate_id number(15);
l_acty_base_rt_id number(15);
l_opt_id number(15);
l_dt_upd_mode Varchar2(30);
l_new_rate  number(22,5);
l_esd DATE;
l_eed DATE;
l_ovn NUMBER(9);
l_gross_index NUMBER(15);
l_sal_rate    NUMBER(22,5);
l_gross_index_o NUMBER(15);
l_sal_rate_o    NUMBER(22,5);

BEGIN
 --
 /* Added for GSI Bug 5472781 */
 IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
    hr_utility.set_location('Leaving : pqh_fr_progression_point_pkg.update_sal_rate_for_point' , 10);
    return;
 END IF;
 --
 OPEN csr_scale_type;
 FETCH csr_scale_type INTO l_scale_info_catg,l_scale_type;
 CLOSE csr_scale_type;
 IF NVL(l_scale_info_catg,'X') = 'FR_PQH' AND NVL(p_information_category,'X') = 'FR_PQH' THEN
   l_gross_index := p_information1;
   l_sal_rate    := p_information2;
   l_gross_index_o := p_information1_o;
   l_sal_rate_o    := p_information2_o;

	 IF (NVL(l_gross_index,-1) <> NVL(l_gross_index_o, -1)) OR (NVL(l_sal_rate,-1) <> NVL(l_sal_rate_o,-1)) THEN
	   l_opt_id := pqh_gsp_hr_to_stage.get_opt_for_point(p_point_id => p_spinal_point_id,
							     p_effective_date => TRUNC(SYSDATE));
	   IF l_opt_id IS NULL THEN
	      RETURN;
	   END IF;
	   l_acty_base_rt_id := pqh_gsp_hr_to_stage.get_co_std_rate(p_opt_id => l_opt_id,
								    p_effective_date => TRUNC(SYSDATE),
								    p_pay_rule_id => l_hr_rate_id);
	   IF l_hr_rate_id IS NULL THEN
	     RETURN;
	   END IF;

           OPEN csr_rate_ovn(l_hr_rate_id);
           FETCH csr_rate_ovn INTO l_ovn;
           IF csr_rate_ovn%NOTFOUND THEN
              CLOSE csr_rate_ovn;
             RETURN;
           END IF;
           CLOSE csr_rate_ovn;

	   IF l_scale_type = 'L' THEN
	     l_new_rate := pqh_corps_utility.get_salary_rate(p_gross_index => l_gross_index,
	                                                     p_effective_date => TRUNC(SYSDATE));
	   ELSIF l_scale_type = 'E' THEN
	     l_new_rate := l_sal_rate;
	   ELSE
	      RETURN;
	   END IF;
	   pqh_fr_utility.get_datetrack_mode(p_effective_date  => trunc(sysdate),
					     p_base_table_name => 'PAY_GRADE_RULES_F',
					     p_base_key_column => 'GRADE_RULE_ID',
					     p_base_key_value  => l_hr_rate_id,
					     p_datetrack_mode  => l_dt_upd_mode);

	   hr_rate_values_api.update_rate_value(p_grade_rule_id => l_hr_rate_id,
	                                        p_datetrack_mode => l_dt_upd_mode,
	                                        p_effective_date => TRUNC(SYSDATE),
	                                        p_value => l_new_rate,
	                                        p_object_version_number => l_ovn,
	                                        p_effective_start_date => l_esd,
	                                        p_effective_end_date => l_eed);

	 END IF;-- If gross index/sal. rate changed
 END IF;	 -- if FR_PQH info. catg,
END update_sal_rate_for_point;

END pqh_fr_progression_point_pkg;

/

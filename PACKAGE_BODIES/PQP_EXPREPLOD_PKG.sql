--------------------------------------------------------
--  DDL for Package Body PQP_EXPREPLOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXPREPLOD_PKG" AS
/* $Header: pqexrpld.pkb 120.4.12010000.5 2010/01/27 12:09:25 mdubasi ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
--

--
*/
------------------------------------- Global Varaibles ---------------------------
l_start_date               pay_payroll_actions.start_date%TYPE                  ;
l_end_date                 pay_payroll_actions.effective_date%TYPE              ;
l_business_group_id        pay_payroll_actions.business_group_id%TYPE           ;
l_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE           ;
l_effective_date           pay_payroll_actions.effective_date%TYPE              ;
l_action_type              pay_payroll_actions.action_type%TYPE                 ;
l_assignment_action_id     pay_assignment_actions.assignment_action_id%TYPE     ;
l_assignment_id            pay_assignment_actions.assignment_id%TYPE            ;
l_tax_unit_id              hr_organization_units.organization_id%TYPE           ;
l_gre_name                 hr_organization_units.name%TYPE                      ;
l_organization_id          hr_organization_units.organization_id%TYPE           ;
l_org_name                 hr_organization_units.name%TYPE                      ;
l_location_id              hr_locations.location_id%TYPE                        ;
l_location_code            hr_locations.location_code%TYPE                      ;
l_ppp_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE     ;
l_leg_param                pay_payroll_actions.legislative_parameters%TYPE      ;
l_leg_start_date           DATE                                                 ;
l_leg_end_date             DATE                                                 ;
t_payroll_id               NUMBER(15)                                           ;
t_consolidation_set_id     NUMBER(15)                                           ;
g_gre_id                   NUMBER(15)                                           ;
g_jd_code                  VARCHAR2(16)                                         ;
g_component_code           NUMBER(15)						;
t_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE           ;
l_row_count                NUMBER :=0                                           ;
l_national_id              per_people_v.national_identifier%TYPE                ;
l_last_name                per_all_people_f.last_name%TYPE                      ;
l_first_name		   per_all_people_f.first_name%TYPE                     ;
l_middle_name		   per_all_people_f.middle_names%TYPE                   ;
l_full_name		   per_all_people_f.full_name%TYPE                      ;
l_assignment_number        per_assignments_f.assignment_number%TYPE             ;
l_dob                      per_all_people_f.date_of_birth%TYPE                  ;
--l_payroll_id               per_assignments_f.payroll_id%TYPE                  ;
l_legislation_code per_business_groups.legislation_code%TYPE                    ;
l_business_group_id_ct     pay_payroll_actions.business_group_id%TYPE :=NULL    ;
l_param_count              NUMBER(2):=0                                         ;
l_ppa_finder               VARCHAR2(20)                                         ;
l_date                     VARCHAR2(15)                                         ;
l_report_id                NUMBER                                               ;
l_group_id                 VARCHAR2(60)                                         ;
l_vartype                  VARCHAR2(1)                                          ;
l_varvalue                 pqp_exception_reports.variance_value%TYPE            ;
g_proc_name  Varchar2(200) :='PQP_EXPREPLOD_PKG.';

TYPE r_date_detail IS RECORD (
                           exception_report_id   pqp_exception_reports.exception_report_id%TYPE,
                           defined_balance_id    pay_defined_balances.defined_balance_id%TYPE,
                           payroll_id            per_assignments_f.payroll_id%TYPE,
                           pay_date              DATE
                            );
TYPE t_date_detail is Table OF r_date_detail
                   INDEX BY binary_integer                                          ;
l_date_detail t_date_detail                                                         ;

TYPE r_rep_detail IS RECORD (
                       exception_report_id    pqp_exception_reports.exception_report_id%TYPE,
                       balance_type_id        pqp_exception_reports.balance_type_id%TYPE,
                       dimension_type_id      pqp_exception_reports.balance_dimension_id%TYPE,
                       variance_type          pqp_exception_reports.variance_type%TYPE,
                       variance_value         pqp_exception_reports.variance_value%TYPE,
                       variance_operator      pqp_exception_reports.variance_operator%TYPE,
                       comparison_type        pqp_exception_reports.comparison_type%TYPE,
                       comparison_value       pqp_exception_reports.comparison_value%TYPE,
                       defined_balance_id     pay_defined_balances.defined_balance_id%TYPE
                         );

TYPE t_rep_detail  IS TABLE OF r_rep_detail
                   INDEX BY binary_integer    ;
l_rep_detail  t_rep_detail;


TYPE r_ret_value IS RECORD (
                       exception_report_id    pqp_exception_reports.exception_report_id%TYPE,
                       balance_type_id        pqp_exception_reports.balance_type_id%TYPE,
                       curent_balance         NUMBER,
                       previous_balance       NUMBER,
                       ret_val                VARCHAR2(1)
                        );
TYPE t_ret_value  IS TABLE OF r_ret_value
                   INDEX BY binary_integer    ;
----------------------------------------------------------------------------------

PROCEDURE load_balances(p_assignment         IN  NUMBER    ,
                        p_effective_date     IN  DATE      ,
                        p_balance_type_id    IN  NUMBER    ,
                        p_cur_balance        IN  NUMBER    ,
                        p_prev_balance       IN  NUMBER    ,
                        p_report_id          IN  NUMBER    ,
                        p_group_name         IN  VARCHAR2  ,
                        p_payroll_id         IN  NUMBER    ,
                        p_ppa_finder         IN  VARCHAR2  ,
                        p_business_group_id  IN  NUMBER
                        )


 IS


 BEGIN

/*Inserts final calculated values into temp table*/

  hr_utility.trace('Entering load_data ...' ||SQLERRM);



  INSERT INTO pay_us_rpt_totals
   (business_group_id      ,
    tax_unit_id            ,
    organization_id        ,
    value1                 ,
    value2                 ,
    attribute1             ,
    attribute2             ,
    attribute3             ,
    attribute4             ,
    attribute5             ,
    attribute6             ,
    attribute7             ,
    attribute8             ,
    attribute9             ,
    attribute10            ,
    attribute11            ,
    attribute12            ,
    attribute13            ,
    attribute14
   )
  VALUES
  (p_business_group_id    ,
   l_payroll_action_id    ,
   p_ppa_finder           ,
   p_cur_balance          ,
   p_prev_balance         ,
   p_balance_type_id      ,
   p_report_id            ,
   p_group_name             ,
   t_consolidation_set_id ,
   p_payroll_id           ,
   p_assignment           ,
   l_last_name            ,
   l_first_name           ,
   l_national_id          ,
   l_middle_name          ,
   p_effective_date       ,
   p_ppa_finder           ,
   l_assignment_number    ,
   l_full_name
  );



 EXCEPTION
 ---------
 WHEN OTHERS THEN

 hr_utility.trace('Error occurred load balances...' ||SQLERRM);

 END load_balances;

FUNCTION get_legislation_code (p_business_group_id IN NUMBER)

 RETURN VARCHAR2

 IS

 l_legislation_code_l  per_business_groups.legislation_code%TYPE;
 BEGIN
 hr_utility.trace('Enter Legislation code');
  SELECT legislation_code
    INTO l_legislation_code_l
   FROM per_business_groups
   WHERE business_group_id      =p_business_group_id;

   RETURN (l_legislation_code_l);
 hr_utility.trace('Leaving Legislation code' );

 EXCEPTION
 ---------
 WHEN OTHERS THEN
 RETURN(NULL);

 END;

/*Gets balance for different legislations,balance
  calls for other legislation must be included here*/
FUNCTION get_value (p_assignment_id       IN NUMBER,
                    p_defined_balance_id  IN NUMBER,
                    p_paydate             IN DATE,
                    p_legislation_code    IN VARCHAR2,
                    p_comp_type           IN VARCHAR2 default null ,
                    p_errmsg              OUT NOCOPY VARCHAR2)

 RETURN NUMBER

 IS
 l_ret_value NUMBER;
 l_orgname   hr_organization_units.name%TYPE;
 CURSOR c_get_bal_dim IS
 SELECT INSTR(DATABASE_ITEM_SUFFIX,'_GRE_'),
        INSTR(DATABASE_ITEM_SUFFIX,'_LE_') ,
	INSTR(DATABASE_ITEM_SUFFIX,'_COMP_')
  FROM pay_balance_dimensions where balance_dimension_id =
 (SELECT balance_dimension_id
    FROM pay_defined_balances
    WHERE defined_balance_id =p_defined_balance_id
     );
 CURSOR c_grename IS
 SELECT hou.name
 FROM hr_organization_units hou
 WHERE organization_id=(SELECT segment1
                          FROM hr_soft_coding_keyflex
                          WHERE soft_coding_keyflex_id =
                          (SELECT soft_coding_keyflex_id
                           FROM per_all_assignments_f
                           WHERE assignment_id=p_assignment_id
                           AND p_paydate  BETWEEN effective_start_date
                           AND effective_end_date));

 CURSOR c_get_in_comp_name IS
 SELECT r.row_low_range_or_name
 FROM  pay_user_rows_f r
 WHERE r.user_row_id = g_component_code;

 l_instr_count      NUMBER :=0;
 l_instr_count1     NUMBER :=0;
 l_instr_count2     NUMBER :=0;
 l_component_name   VARCHAR2(80);

 BEGIN
 --Lookup:PQP_COMPARISON_TYPE
 --IC,MC,PADP,PADT,PANP,PANT,PC,PP,QC,YC
  IF p_legislation_code='GB' AND ( p_comp_type='IC' OR p_comp_type='MC'
                                 OR p_comp_type='PADP' OR p_comp_type='PADT'
                                 OR p_comp_type= 'PANP' OR p_comp_type= 'PANT'
                                 OR p_comp_type= 'PC' OR p_comp_type= 'PP'
                                 OR p_comp_type= 'QC' OR p_comp_type= 'YC') THEN
   hr_utility.trace('Enter GB Legislation');
   --l_ret_value:=hr_gbbal.calc_all_balances (p_paydate, p_assignment_id,p_defined_balance_id);
   l_ret_value:=pay_balance_pkg.get_value(p_defined_balance_id,p_assignment_id,p_paydate );
  --Commented out as we are using a wrapper after the bug was fixed for PTD dim.
  -- l_ret_value:=hr_dirbal.get_balance(p_assignment_id,p_defined_balance_id,p_paydate );
   hr_utility.trace('Leaving GB Legislation');
   p_errmsg:='NOERROR' ;
  --MAN,MP,QAN,QP,YP
  ELSIF p_legislation_code='GB' AND ( p_comp_type='MAN' OR p_comp_type= 'MP'
                                     OR p_comp_type= 'QAN' OR p_comp_type= 'QP'
                                      OR p_comp_type= 'YP') THEN
   l_ret_value:=hr_gbbal.calc_all_balances (p_paydate, p_assignment_id,p_defined_balance_id);

  ELSIF p_legislation_code='US' OR p_legislation_code='CA' OR p_legislation_code='AU' OR p_legislation_code='IN' THEN

   OPEN c_get_bal_dim;
   FETCH c_get_bal_dim INTO l_instr_count,l_instr_count1,l_instr_count2;
   CLOSE c_get_bal_dim;

   OPEN c_get_in_comp_name;
   FETCH c_get_in_comp_name INTO l_component_name;
   CLOSE c_get_in_comp_name;

   /* OPEN c_grename;
    LOOP
    FETCH c_grename INTO l_orgname;
    EXIT WHEN c_grename%NOTFOUND;
    END LOOP;
    CLOSE c_grename;*/

   IF l_instr_count2 > 0 and p_legislation_code = 'IN' THEN
   pay_balance_pkg.set_context ('SOURCE_TEXT2',l_component_name);
   END IF;

  --If the balance dimension has GRE in it then set the context to gre.
   IF  l_instr_count > 0 OR l_instr_count1 > 0 THEN
    pay_balance_pkg.set_context ('TAX_UNIT_ID',NVL(g_gre_id,l_organization_id));
   END IF;
   IF g_jd_code IS NOT NULL  THEN
    pay_balance_pkg.set_context('JURISDICTION_CODE',g_jd_code);
   END IF;
   hr_utility.trace('Entering US OR CA Legislation');
   l_ret_value:=pay_balance_pkg.get_value(p_defined_balance_id,p_assignment_id,p_paydate );
   hr_utility.trace('Leaving US OR CA Legislation');
   p_errmsg:='NOERROR' ;
  ELSE
   -- Call the core get_balance pkg
   hr_utility.trace('Entering General Legislation');
   l_ret_value:=pay_balance_pkg.get_value(p_defined_balance_id,p_assignment_id,p_paydate );
   hr_utility.trace('Leaving General Legislation');
   p_errmsg:='NOERROR' ;
  END IF;

  RETURN(l_ret_value);

  EXCEPTION
  ---------
  WHEN OTHERS THEN
   p_errmsg:='ERROR' ;
   RETURN(0);
 END;


PROCEDURE get_balances(        pactid              IN  NUMBER,
                               p_assignment_id     IN  NUMBER,
                               p_business_group_id IN  NUMBER,
                               p_payroll_id        IN  NUMBER ,
                               p_report_id         IN  NUMBER,
                               p_group_id          IN  VARCHAR2,
                               p_vartype           IN  VARCHAR2,
                               p_varvalue          IN  NUMBER,
                               p_effective_date    IN  DATE,
                               p_ret_value         OUT NOCOPY t_ret_value)
 IS
CURSOR c_maxdate
 IS
 SELECT MAX(greatest(ptp.end_date,ptp.regular_payment_date)) pay_date,
        MAX (ptp.end_date)
   FROM per_time_periods ptp
  WHERE ptp.payroll_id=p_payroll_id
    AND ptp.end_date <= p_effective_date;

 CURSOR c_prev_per(maxdate DATE)
 IS
 SELECT MAX(greatest(ptp.end_date,ptp.regular_payment_date)) prev_pay_period
   FROM per_time_periods ptp
  WHERE ptp.payroll_id =p_payroll_id
    AND ptp.end_date < maxdate;

 CURSOR c_avg_per_days(maxdate DATE,no_days NUMBER)
 IS
 SELECT greatest(ptp.end_date,ptp.regular_payment_date) pay_date
   FROM per_time_periods ptp
  WHERE ptp.payroll_id =p_payroll_id
    AND ptp.end_date >= maxdate-no_days
    AND ptp.end_date < maxdate
    ORDER BY end_date desc;

 CURSOR c_avg_per (maxdate DATE,no_period NUMBER)
 IS
 SELECT greatest(ptp.end_date,ptp.regular_payment_date) pay_date
   FROM per_time_periods ptp
  WHERE ptp.payroll_id = p_payroll_id
    AND no_period >=(Select count(*)
             FROM per_time_periods ptp1
             WHERE ptp1.payroll_id =p_payroll_id
             AND ptp1.end_date < maxdate
             AND ptp.end_date <=ptp1.end_date)
    AND ptp.end_date < maxdate
    ORDER BY end_date desc;

 CURSOR c_rep_name (p_legislation_code VARCHAR2)
 IS
 SELECT exception_report_id,
        balance_type_id,
        balance_dimension_id ,
        NVL(p_vartype,variance_type),
        NVL(p_varvalue,variance_value),
        variance_operator,
        comparison_type,
        comparison_value
  FROM pqp_exception_reports
  WHERE exception_report_id=p_report_id
    AND (business_group_id =p_business_group_id
     OR business_group_id IS NULL)
    AND (legislation_code=p_legislation_code
     OR legislation_code IS NULL);

 CURSOR c_group_name(p_legislation_code VARCHAR2)
 IS
 SELECT per.exception_report_id,
        per.balance_type_id,
        per.balance_dimension_id ,
        per.variance_type,
        per.variance_value,
        per.variance_operator,
        per.comparison_type,
        per.comparison_value
  FROM  pqp_exception_report_groups perg,
        pqp_exception_reports per
 WHERE  exception_group_name=(SELECT exception_group_name from
                              pqp_exception_report_groups
                               where exception_group_id=to_number(p_group_id))
   AND ( perg.business_group_id =p_business_group_id
    OR  perg.business_group_id IS NULL)
   AND ( per.business_group_id =p_business_group_id
    OR  per.business_group_id IS NULL)
   AND  per.exception_report_id=perg.exception_report_id
    AND (perg.legislation_code=p_legislation_code
     OR perg.legislation_code IS NULL)
    AND (per.legislation_code=p_legislation_code
     OR per.legislation_code IS NULL);

 CURSOR  c_def_bal (bal_type_id NUMBER,
                    dim_type_id NUMBER)
 IS
 SELECT  defined_balance_id
   FROM  pay_defined_balances
  WHERE  balance_type_id=bal_type_id
    AND  balance_dimension_id=dim_type_id;
 l_count                                             NUMBER      ;
 l_count1                                            NUMBER      ;
 l_maxdate                                           DATE        ;
 l_maxdate1                                          DATE        ;
 l_prev_pay_period                                   DATE        ;
 l_def_bal_id                                        NUMBER      ;
 l_exp_rep_id pqp_exception_reports.exception_report_id%TYPE     ;
 l_comp_type      pqp_exception_reports.comparison_type%TYPE     ;
 l_comp_value    pqp_exception_reports.comparison_value%TYPE     ;
 l_balance_type                                      NUMBER      ;
 l_variance_type    pqp_exception_reports.variance_type%TYPE     ;
 l_variance_value  pqp_exception_reports.variance_value%TYPE     ;
 l_variance_operator  pqp_exception_reports.variance_operator%TYPE;
 l_rowcount                                          NUMBER      ;
 l_prev_balance                                      NUMBER:=0   ;
 l_prev_balance1                                     NUMBER:=0   ;
 l_pay_count                                         NUMBER:=0   ;
 l_tot_count                                         NUMBER:=0   ;
 l_max_balance                                       NUMBER :=0  ;
 l_total_balance                                     NUMBER:=0   ;
 l_return_value                                      VARCHAR2(1) ;
 l_errmsg                                            VARCHAR2(15);
 l_retvalue_count                                    NUMBER      ;
 temp_date                                           DATE        ;
 l_loop_count                                        NUMBER:=0;
-- Nocopy changes
 l_ret_value_nc                                      t_ret_value ;
 l_temp_date                                         Date;
 l_tax_year_start_date                               Date;

BEGIN
 hr_utility.trace('Enter Get balances');
 hr_utility.trace('Enter legislation code');

 -- Nocopy changes
 l_ret_value_nc := p_ret_value;


 IF l_business_group_id_ct IS NULL OR
    l_business_group_id_ct<>p_business_group_id
 OR l_legislation_code IS NULL  THEN
    l_business_group_id_ct:=p_business_group_id;
    l_legislation_code:=get_legislation_code(p_business_group_id);
 END IF;

 hr_utility.trace('Exit legislation code');
/*Check Report or Group id is entered by user*/
 IF l_rep_detail.count=0 THEN
  IF p_report_id IS NOT NULL THEN
   hr_utility.trace('Enter Report id loop');
/*Get report detail*/
   OPEN c_rep_name (l_legislation_code);
    LOOP
     FETCH c_rep_name INTO l_rep_detail(1).exception_report_id ,
                           l_rep_detail(1).balance_type_id  ,
                           l_rep_detail(1).dimension_type_id,
                           l_rep_detail(1).variance_type,
                           l_rep_detail(1).variance_value,
                           l_rep_detail(1).variance_operator,
                           l_rep_detail(1).comparison_type,
                           l_rep_detail(1).comparison_value;
     EXIT WHEN c_rep_name%NOTFOUND;
     OPEN c_def_bal(l_rep_detail(1).balance_type_id,
                    l_rep_detail(1).dimension_type_id);
      LOOP
       FETCH c_def_bal INTO l_rep_detail(1).defined_balance_id;
       EXIT WHEN c_def_bal%NOTFOUND;
      END LOOP;
     CLOSE c_def_bal;
    END LOOP;
   CLOSE c_rep_name;
   hr_utility.trace('Leaving Report id loop');
  ELSIF p_group_id IS NOT NULL  AND p_report_id IS NULL THEN
   hr_utility.trace('Enter Group loop');
   l_count:=0;
/*Get Group detail*/
   OPEN c_group_name (l_legislation_code) ;
    LOOP
     FETCH c_group_name INTO l_rep_detail(l_count+1).exception_report_id ,
                            l_rep_detail(l_count+1).balance_type_id  ,
                            l_rep_detail(l_count+1).dimension_type_id,
                            l_rep_detail(l_count+1).variance_type,
                            l_rep_detail(l_count+1).variance_value,
                            l_rep_detail(l_count+1).variance_operator,
                            l_rep_detail(l_count+1).comparison_type,
                            l_rep_detail(l_count+1).comparison_value;

     EXIT WHEN c_group_name%NOTFOUND;
      OPEN c_def_bal(l_rep_detail(l_count+1).balance_type_id,
                    l_rep_detail(l_count+1).dimension_type_id);
       LOOP
        FETCH c_def_bal INTO l_rep_detail(l_count+1).defined_balance_id;
        EXIT WHEN c_def_bal%NOTFOUND;
       END LOOP;
      CLOSE c_def_bal;
      l_count:=l_count+1;
     END LOOP;
    CLOSE c_group_name;
  END IF;
 END IF;
 IF l_date_detail.count<>0 AND
    l_date_detail(1).payroll_id  <> p_payroll_id THEN
    l_date_detail.DELETE;

 END IF;
/*Calculation based on comparison type*/
 hr_utility.trace('Enter date calc loop');
 IF l_date_detail.count=0  THEN
  OPEN c_maxdate;
   LOOP
    FETCH c_maxdate INTO l_maxdate,l_maxdate1;
    EXIT WHEN c_maxdate%NOTFOUND;
    FOR i in 1..l_rep_detail.count
     LOOP
      l_def_bal_id := l_rep_detail(i).defined_balance_id;
      l_comp_type  := l_rep_detail(i).comparison_type;
      l_comp_value := l_rep_detail(i).comparison_value;

       hr_utility.trace('Enter conditions loop');

       --Added by Gattu for tax year change
       --Getting the financial tax year
       l_tax_year_start_date := Get_Tax_Start_Date(l_legislation_code
                                  ,l_maxdate
		      	          ,l_rep_detail(i).dimension_type_id);


      IF l_comp_type='PP' THEN	--Previous Period
       OPEN  c_prev_per(l_maxdate1);
        LOOP
        FETCH c_prev_per INTO l_prev_pay_period;
        EXIT WHEN c_prev_per%NOTFOUND;
         IF l_date_detail.count>=1 THEN
          l_count1:=l_date_detail.count;
         ELSE
          l_count1:=0;
         END IF;
         l_date_detail(l_count1+1).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+1).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+1).pay_date          :=l_maxdate;
         l_date_detail(l_count1+2).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+2).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+2).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+2).pay_date          :=l_prev_pay_period;

        END LOOP;--for c_prev_per
       CLOSE c_prev_per;
       --Current Period  or Current year etc
        ELSIF l_comp_type='PC' OR l_comp_type='YC'
             OR  l_comp_type='QC'  OR l_comp_type='MC'
	     OR l_comp_type='IC' THEN
         IF l_date_detail.count>=1 THEN
          l_count1:=l_date_detail.count;
         ELSE
          l_count1:=0;
         END IF;
         l_date_detail(l_count1+1).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+1).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+1).pay_date          :=l_maxdate;

        ELSIF l_comp_type='YP' THEN  --Previous Year
         IF l_date_detail.count>=1 THEN
          l_count1:=l_date_detail.count;
         ELSE
          l_count1:=0;
         END IF;
	 --Added by Gattu for tax year change
         --Check the Tax year is null or not
         --If not null then call this function to get last day of previous tax year
	 IF l_tax_year_start_date IS NOT NULL THEN
            l_temp_date :=Get_Previous_Year_Tax_Date(l_tax_year_start_date,l_maxdate);
	 ELSE
	     Select LAST_DAY(ADD_MONTHS(l_maxdate,(12-to_char(l_maxdate,'MM')-12)))
	       INTO l_temp_date
	       FROM dual;
	 END IF;

         l_date_detail(l_count1+1).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+1).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+1).pay_date          :=l_maxdate;
         l_date_detail(l_count1+2).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+2).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+2).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+2).pay_date          :=l_temp_date;--LAST_DAY(ADD_MONTHS(l_maxdate,(12-to_char(l_maxdate,'MM')-12)));

        ELSIF l_comp_type='QP' OR l_comp_type='QAN'  THEN  --Previous Quarter
         IF l_date_detail.count>=1 THEN
          l_count1:=l_date_detail.count;
         ELSE
          l_count1:=0;
         END IF;

         l_date_detail(l_count1+1).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+1).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+1).pay_date          :=l_maxdate;
         l_count1:=l_count1+1;
         FOR j in 1..nvl(l_comp_value,1)
          LOOP
           l_date_detail(l_count1+j).exception_report_id
                                          :=l_rep_detail(i).exception_report_id;
           l_date_detail(l_count1+j).defined_balance_id
                                          :=l_rep_detail(i).defined_balance_id;
           l_date_detail(l_count1+j).payroll_id
                                          :=p_payroll_id;

  	 --Added by Gattu for tax year change
         --Check the Tax year is null or not
         --If not null then call this function to get last day of previous tax year
	 IF l_tax_year_start_date IS NOT NULL THEN
            l_temp_date :=Get_Previous_Quarter_Tax_Date(l_tax_year_start_date,l_maxdate,j);
	 ELSE
             SELECT LAST_DAY(ADD_MONTHS(l_maxdate,(DECODE(MOD(to_char(l_maxdate,'MM'),3),0,0,1,2,2,1)+
                    (j*-3))))
             INTO l_temp_date
             FROM dual;
	 END IF;

           /*Adds 3 months to iterate quarter*/
	   --Commented for financial tax year change
           /*SELECT LAST_DAY(ADD_MONTHS(l_maxdate,
                          (DECODE(MOD(to_char(l_maxdate,'MM'),3),0,0,1,2,2,1)+
                          (j*-3))))
             INTO temp_date
             FROM dual;  */
           l_date_detail(l_count1+j).pay_date          :=l_temp_date;--temp_date--LAST_DAY(ADD_MONTHS(l_maxdate,
          --                                            (3-MOD(to_char(l_maxdate,'MM'),3)+(j*-3))));
          END LOOP ;--end for loop
	  --Previous Month or Average In Months
        ELSIF l_comp_type='MP' OR l_comp_type='MAN'  THEN
         IF l_date_detail.count>=1 THEN
          l_count1:=l_date_detail.count;
         ELSE
          l_count1:=0;
         END IF;
         l_date_detail(l_count1+1).exception_report_id:=l_rep_detail(i).exception_report_id;
         l_date_detail(l_count1+1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
         l_date_detail(l_count1+1).payroll_id        :=p_payroll_id;
         l_date_detail(l_count1+1).pay_date          :=l_maxdate;
         l_count1:=l_count1+1;
        FOR j in 1..nvl(l_comp_value,1)
         LOOP
          l_date_detail(l_count1+j).exception_report_id:=l_rep_detail(i).exception_report_id;
          l_date_detail(l_count1+j).defined_balance_id:=l_rep_detail(i).defined_balance_id;
          l_date_detail(l_count1+j).payroll_id        :=p_payroll_id;
          /*Adds  months to iterate Months*/
          l_date_detail(l_count1+j).pay_date          :=LAST_DAY(ADD_MONTHS(l_maxdate,-j));
         END LOOP ;--end for loop
	 --Average Of Paid Periods In Days
       ELSIF l_comp_type='PADP' OR l_comp_type='PADT'
         OR l_comp_type='PANT' OR l_comp_type='PANP'  THEN
        IF l_date_detail.count>=1 THEN
         l_count1:=l_date_detail.count;
        ELSE
          l_count1:=0;
        END IF;
        l_date_detail(l_count1+1).exception_report_id:=l_rep_detail(i).exception_report_id;
        l_date_detail(l_count1+1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
        l_date_detail(l_count1+1).payroll_id        :=p_payroll_id;
        l_date_detail(l_count1+1).pay_date          :=l_maxdate;
        l_count1:=l_count1+1;
        IF l_comp_type ='PADP' OR l_comp_type='PADT' THEN
         OPEN c_avg_per_days(l_maxdate1 , l_comp_value);
          LOOP
           FETCH c_avg_per_days INTO l_prev_pay_period;
           EXIT WHEN c_avg_per_days%NOTFOUND;
           l_count1:=l_count1+1;
           l_date_detail(l_count1).exception_report_id:=l_rep_detail(i).exception_report_id;
           l_date_detail(l_count1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
           l_date_detail(l_count1).payroll_id        :=p_payroll_id;
           l_date_detail(l_count1).pay_date          :=l_prev_pay_period;
          END LOOP;--endloop for c_avg_per_days
         CLOSE c_avg_per_days;
	 --Average Of Previous Periods
        ELSIF l_comp_type='PANT' OR l_comp_type='PANP'  THEN
         OPEN c_avg_per(l_maxdate1 , l_comp_value);
          LOOP
           FETCH c_avg_per INTO l_prev_pay_period;
           EXIT WHEN c_avg_per%NOTFOUND;
           l_count1:=l_count1+1;
           l_date_detail(l_count1).exception_report_id:=l_rep_detail(i).exception_report_id;
           l_date_detail(l_count1).defined_balance_id:=l_rep_detail(i).defined_balance_id;
           l_date_detail(l_count1).payroll_id        :=p_payroll_id;
           l_date_detail(l_count1).pay_date          :=l_prev_pay_period;
          END LOOP;--endloop for c_avg_per
         CLOSE c_avg_per;
        END IF;
       END IF; --end if for comparison type
      END LOOP;--endloop for l_repdetail_table
     END LOOP;
    CLOSE c_maxdate;
    hr_utility.trace('Leaving conditions loop');
    hr_utility.trace('Complete Populating table');
   END IF;
   hr_utility.trace('Enter Balance and calc loop');
   l_loop_count:=0;
   l_rowcount:=1;
  FOR i IN 1..l_rep_detail.count
   LOOP
   --l_rowcount:=0;
   l_exp_rep_id  :=l_rep_detail(i).exception_report_id;
   l_balance_type:=l_rep_detail(i).balance_type_id;
   l_variance_type:=l_rep_detail(i).variance_type;
   l_variance_value:=l_rep_detail(i).variance_value;
   l_variance_operator:=l_rep_detail(i).variance_operator;
   l_comp_type:=l_rep_detail(i).comparison_type;
   l_def_bal_id:=l_rep_detail(i).defined_balance_id ;
   l_prev_balance:=0;
   l_pay_count:=0 ;
   l_tot_count:=0 ;
   --l_rowcount:=l_rowcount+l_loop_count+1;
   l_loop_count:=0;
  FOR j in l_rowcount..l_date_detail.count
   LOOP
   IF l_def_bal_id=l_date_detail(j).defined_balance_id
      AND l_exp_rep_id=l_date_detail(j).exception_report_id THEN
    hr_utility.trace('Enter Balance call');
    IF l_loop_count=0  THEN
     l_max_balance:= get_value (p_assignment_id ,
                                l_def_bal_id,
                                l_date_detail(j).pay_date,
                                l_legislation_code,
                                l_comp_type,
                                l_errmsg);
     l_loop_count:=l_loop_count+1;
    ELSE
     l_prev_balance1:= get_value (p_assignment_id ,
                                  l_def_bal_id,
                                  l_date_detail(j).pay_date,
                                  l_legislation_code,
                                  l_comp_type,
                                  l_errmsg);

     l_loop_count:=l_loop_count+1;
     l_prev_balance:=l_prev_balance+l_prev_balance1;

     IF l_errmsg='NOERROR' THEN
      l_tot_count:=l_tot_count+1;
     END IF;
     hr_utility.trace('Leaving Balance call');
     IF l_prev_balance1<>0   THEN
      l_pay_count:=l_pay_count+1;
     END IF;
    END IF;
   ELSE
    --l_rowcount:=j-1;
    l_rowcount:=j;
    EXIT;
   END IF;--end if for def balance comparison
    hr_utility.trace('Enter final calc loop');
   END LOOP;--endloop for l_date_detail forloop
   IF l_comp_type ='PADT'OR l_comp_type ='PANT'
   OR l_comp_type='QP'OR l_comp_type='QAN'
   OR l_comp_type='MP'OR l_comp_type='MAN'   THEN
    IF l_prev_balance<>0 AND l_tot_count<>0 THEN
     l_prev_balance:=l_prev_balance/l_tot_count;
    END IF;
   ELSIF l_comp_type='PADP'OR l_comp_type ='PANP' THEN
    IF l_prev_balance<>0 AND l_pay_count<>0 THEN
     l_prev_balance:=l_prev_balance/l_pay_count;
    END IF;
   END IF; --end if for comp_type
   --
   -- If the comp_type is Current period.
   --
   IF l_comp_type ='PC' OR l_comp_type ='YC'
      OR  l_comp_type='QC'  OR l_comp_type='MC' THEN
    l_total_balance:=l_max_balance;
    IF l_rep_detail(i).variance_operator = '=' THEN
     IF l_total_balance=l_rep_detail(i).variance_value THEN
      l_return_value:='Y';
     ELSE
      l_return_value:='N' ;
     END IF;
    ELSIF l_rep_detail(i).variance_operator = '>=' THEN
     IF l_total_balance >= l_rep_detail(i).variance_value THEN
      l_return_value:='Y';
     ELSE
      l_return_value:='N' ;
     END IF;
    ELSIF l_rep_detail(i).variance_operator = '<=' THEN
     IF (l_total_balance) <=  l_rep_detail(i).variance_value THEN
      l_return_value:='Y';
     ELSE
      l_return_value:='N' ;
     END IF;
    ELSIF l_rep_detail(i).variance_operator = '<' THEN
     IF (l_total_balance) < l_rep_detail(i).variance_value THEN
      l_return_value:='Y';
     ELSE
      l_return_value:='N' ;
     END IF;
    ELSIF l_rep_detail(i).variance_operator = '>' THEN
     IF l_total_balance > l_rep_detail(i).variance_value THEN
      l_return_value:='Y';
     ELSE
      l_return_value:='N';
     END IF;
    ELSIF l_rep_detail(i).variance_operator = '+/-' THEN
     IF ABS(l_total_balance) >= l_rep_detail(i).variance_value THEN
      l_return_value:='Y';
     ELSE
      l_return_value:='N' ;
     END IF;
    END IF;
    --
    -- For all other comp_types
    --
   ELSE
    l_total_balance:=l_max_balance-l_prev_balance;
    --
    -- If the var_type is Percent
    --
    IF l_variance_type ='P' THEN
     IF l_prev_balance<>0 THEN --Check to Avoid exception for zero divide
      l_total_balance:=100*l_total_balance/l_prev_balance;
     ELSE
      l_total_balance:=l_total_balance;
     END IF;
      hr_utility.trace('Leaving final calc loop');
    END IF;
     -- Code for variance operator
     IF l_rep_detail(i).variance_operator = '=' THEN
     --Fix for Bug 8361529
     --IF (l_total_balance)=l_rep_detail(i).variance_value THEN
       IF ABS(l_total_balance)=l_rep_detail(i).variance_value THEN
       l_return_value:='Y';
      ELSE
       l_return_value:='N' ;
      END IF;
     ELSIF l_rep_detail(i).variance_operator = '>=' THEN
      IF l_total_balance >= l_rep_detail(i).variance_value THEN
       l_return_value:='Y';
      ELSE
       l_return_value:='N' ;
      END IF;
     ELSIF l_rep_detail(i).variance_operator = '<=' THEN
     --Fix for Bug 8242944
     --IF (l_total_balance) >=  l_rep_detail(i).variance_value AND l_total_balance <= 0 THEN
       IF (l_total_balance * -1) >=  l_rep_detail(i).variance_value AND l_total_balance <= 0 THEN
       l_return_value:='Y';
      ELSE
       l_return_value:='N' ;
      END IF;
     ELSIF l_rep_detail(i).variance_operator = '<' THEN
      --Fix for Bug 8242944
      --IF (l_total_balance) > l_rep_detail(i).variance_value AND l_total_balance < 0 THEN
      IF (l_total_balance * -1) > l_rep_detail(i).variance_value AND l_total_balance < 0 THEN
       l_return_value:='Y';
      ELSE
       l_return_value:='N' ;
      END IF;
     ELSIF l_rep_detail(i).variance_operator = '>' THEN
      IF l_total_balance > l_rep_detail(i).variance_value THEN
       l_return_value:='Y';
      ELSE
       l_return_value:='N';
      END IF;
     ELSIF l_rep_detail(i).variance_operator = '+/-' THEN
      IF ABS(l_total_balance) >= l_rep_detail(i).variance_value THEN
       l_return_value:='Y';
      ELSE
       l_return_value:='N' ;
      END IF;
     END IF;
    END IF;
 --
    l_retvalue_count:=p_ret_value.count+1;
    p_ret_value(l_retvalue_count).exception_report_id:=l_exp_rep_id;
    p_ret_value(l_retvalue_count).balance_type_id:=l_balance_type;
    p_ret_value(l_retvalue_count).curent_balance:=l_max_balance;
    p_ret_value(l_retvalue_count).previous_balance:=l_prev_balance;
    p_ret_value(l_retvalue_count).ret_val:=l_return_value;
  END LOOP; --end loop for repdetail for loop
  hr_utility.trace('Leaving Balance and calc loop');
  hr_utility.trace('Leaving Get Balances');

-- Added by tmehra for nocopy changes - Feb03
 EXCEPTION
 ---------
  WHEN OTHERS THEN
   hr_utility.trace('Error occurred' ||SQLERRM);
   p_ret_value := l_ret_value_nc;
   RAISE;

 END;


PROCEDURE upd_payroll_actions (pactid in number,
                               p_payroll_id IN NUMBER ,
                               p_consolidation_set_id IN NUMBER,
                               p_effective_date IN DATE)
 IS


 CURSOR c_set_paydate
 IS
 SELECT MAX(pay_date)maxdate,
        MIN(pay_st_date) mindate
   FROM (SELECT MAX(ptp.start_date) pay_st_date,MAX(ptp.end_date) pay_date
           FROM per_time_periods ptp
          WHERE ptp.payroll_id IN (SELECT payroll_id
                                     FROM pay_payroll_actions ppa
                                     WHERE ppa.consolidation_set_id=p_consolidation_set_id
                                       AND (payroll_id =p_payroll_id
                                        OR p_payroll_id IS NULL)
                                       AND ppa.date_earned <= p_effective_date)
   AND ptp.end_date <= p_effective_date
   GROUP BY ptp.payroll_id);
 l_mindate                                        DATE ;
 l_maxdate                                        DATE ;
 l_payroll_id                                   NUMBER ;
 l_cutoff_date                                    DATE ;
 l_temp_date                                      DATE ;
 l_temp_date1                                     DATE ;
 l_count                                        NUMBER ;
 BEGIN
  hr_utility.trace('Enter update payroll action');
  OPEN c_set_paydate ;
   LOOP
    FETCH c_set_paydate INTO l_maxdate,l_mindate;
    EXIT WHEN c_set_paydate%NOTFOUND;
   END LOOP;
  CLOSE c_set_paydate;

  UPDATE pay_payroll_actions
     SET Start_date= NVL(l_mindate,p_effective_date)
       , effective_date=NVL(l_maxdate,p_effective_date)
   WHERE payroll_action_id=pactid;

  hr_utility.trace('Leaving Update payroll action') ;

 END;

PROCEDURE load_details (p_assignment IN NUMBER)
 IS
 msg1 varchar2(2000);
 CURSOR per_det is
 SELECT                  ppv.last_name,
                         ppv.first_name,
                         ppv.middle_names,
			 ppv.full_name,
                         ppv.date_of_birth,
                         ppv.national_identifier,
                         paf.assignment_number
FROM
                         per_all_people_f ppv,
                         per_assignments_f paf
                   WHERE paf.assignment_id=p_assignment
                     AND paf.person_id=ppv.person_id
                     AND l_effective_date BETWEEN ppv.effective_start_date
                                              AND ppv.effective_end_date
                     AND l_effective_date BETWEEN paf.effective_start_date
                                              AND paf.effective_end_date;

                     --ORDER BY ppv.last_update_date;


BEGIN
hr_utility.trace('Enter Load details');
l_last_name:='';
l_first_name:='';
l_middle_name:='';
l_full_name := '';
l_dob:='';
l_assignment_number:='';
l_national_id:='';



 OPEN per_det;
  LOOP

   FETCH per_det into l_last_name,
                      l_first_name,
                      l_middle_name,
		      l_full_name,
                      l_dob,
                      l_national_id,
                      l_assignment_number;
   EXIT when per_det%NOTFOUND;



  END LOOP;
 CLOSE per_det;

hr_utility.trace('Leaving Load details');

 EXCEPTION
 --------
 WHEN OTHERS THEN
 msg1:=SQLERRM;
        hr_utility.trace('Error occurred load_er_liab ...' ||SQLERRM);
 END load_details;






PROCEDURE load_data
(
   actid                   IN     NUMBER,
   p_effective_date       IN     DATE
       ) IS
CURSOR c_filterasg (p_payroll_id NUMBER)
 IS
 SELECT MAX(ptp.start_date),MAX(ptp.end_date) pay_date
   FROM per_time_periods ptp
  WHERE ptp.payroll_id=p_payroll_id
    AND ptp.end_date <= p_effective_date;

CURSOR sel_aaid (l_pactid number
                 )
IS
SELECT
        distinct paa1.assignment_id           assignment_id,
        ppa_arch.start_date          start_date,
        ppa_arch.effective_date      end_date,
        ppa_arch.business_group_id   business_group_id,
        ppa_arch.payroll_action_id   payroll_action_id,
        ppa.effective_date           effective_date,
        ppa.action_type              action_type,
        paa1.tax_unit_id             tax_unit_id,
        paf.payroll_id               payroll_id,
        paf.organization_id          organization_id,
        hou1.name                    organization_name,
        paf.location_id              location_id,
         paa.chunk_number            chnkno,
          paa.payroll_action_id      pactid
FROM
        hr_organization_units        hou1,
        per_assignments_f            paf,
        pay_payroll_actions          ppa,
        pay_assignment_actions       paa1,
        pay_action_interlocks        pai,
        pay_assignment_actions       paa,
        pay_payroll_actions          ppa_arch
  WHERE paa.assignment_action_id   = l_pactid
    AND paa.payroll_action_id      = ppa_arch.payroll_action_id
    AND pai.locking_action_id      = paa.assignment_action_id
    AND paa1.assignment_action_id  = pai.locked_action_id
    AND ppa.payroll_action_id      = paa1.payroll_action_id
    AND paf.assignment_id          =   paa1.assignment_id
    AND ppa.effective_date between   paf.effective_start_date
                               AND   paf.effective_end_date
    AND hou1.organization_id       = paf.organization_id;

 l_payroll_id                      NUMBER ;
 l_cur_balance                     NUMBER ;
 l_prev_balance                    NUMBER ;
 l_return_value                    VARCHAR2(1);
 l_balancetype_id                  NUMBER ;
 l_exp_rep_id                      NUMBER ;
 pactid                            NUMBER;
 chnkno                            NUMBER;
 l_ret_value                       t_ret_value;
 --a number;
 l_sdate                           DATE;
 l_edate                           DATE;
 l_act_date                        DATE;
 l_offset_date                     NUMBER;

 BEGIN
  hr_utility.trace('ACTID = '||actid);
  hr_utility.trace('Enter Load data');
  OPEN sel_aaid (actid);
   LOOP
   FETCH sel_aaid INTO  l_assignment_id,
                        l_start_date,
                        l_end_date,
                        l_business_group_id,
                        l_payroll_action_id,
                        l_effective_date,
                        l_action_type,
                        l_tax_unit_id,
                        l_payroll_id,
                        l_organization_id,
                        l_org_name,
                        l_location_id,
                        chnkno,
                        pactid
                        ;

   EXIT when sel_aaid%notfound;
   IF l_param_count<>1 THEN
    BEGIN
     l_param_count:=1;
     SELECT ppa.legislative_parameters,
            ppa.business_group_id,
            ppa.start_date,
            ppa.effective_date,
            pqp_exppreproc_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_REPORT',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_GROUP',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_PPA_FINDER',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_DATE',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_VARTYPE',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_VARVALUE',ppa.legislative_parameters),
            pqp_exppreproc_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters) ,
            pqp_exppreproc_pkg.get_parameter('TRANSFER_JD',ppa.legislative_parameters) ,
            ppa.payroll_action_id,
	    pqp_exppreproc_pkg.get_parameter('TRANSFER_COMP',ppa.legislative_parameters)
       INTO l_leg_param,
            l_business_group_id,
            l_leg_start_date,
            l_leg_end_date,
            t_consolidation_set_id,
            t_payroll_id,
            l_report_id ,
            l_group_id,
            l_ppa_finder,
            l_date,
            l_vartype,
            l_varvalue,
            g_gre_id,
            g_jd_code,
            t_payroll_action_id,
	    g_component_code
       FROM pay_payroll_actions ppa
      WHERE ppa.payroll_action_id = pactid;

    EXCEPTION
    ---------
    WHEN NO_DATA_FOUND THEN
     hr_utility.trace('Legislative Details not found...');
     RAISE;
    END;
   END IF;
    hr_utility.trace('Number of Records fetched = '||to_char(sel_aaid%ROWCOUNT));
    hr_utility.trace('Payroll Action ID = '||to_char(l_payroll_action_id));
    hr_utility.trace('Effective Date    = '||to_char(l_effective_date));
    hr_utility.trace('Action Type       = '||l_action_type);
    hr_utility.trace('Asg Act ID        = '||to_char(l_assignment_action_id));
    hr_utility.trace('Asg ID            = '||to_char(l_assignment_id));
    IF l_group_id IS NOT NULL THEN
     l_vartype:=NULL;
     l_varvalue:=NULL;
    END IF;
    OPEN c_filterasg(l_payroll_id);
     LOOP
      FETCH c_filterasg into l_sdate,l_edate;
      EXIT WHEN c_filterasg%NOTFOUND;
     END LOOP;
    CLOSE c_filterasg;
    --Added by Gattu to fix Tar#3837327.999
    l_offset_date := get_offset_date
                     (l_payroll_id
                     ,t_consolidation_set_id
                     ,l_effective_date );
    IF l_offset_date <> 0 THEN
     l_act_date :=l_edate;
    ELSE
     l_act_date :=  l_effective_date;
    END IF;
    IF l_act_date BETWEEN l_sdate AND l_edate THEN
        --IF l_effective_date BETWEEN l_sdate AND l_edate THEN
     load_details(l_assignment_id);
     get_balances(        pactid  ,
                          l_assignment_id ,
                          l_business_group_id ,
                          l_payroll_id ,
                          l_report_id ,
                          l_group_id  ,
                          l_vartype,
                          l_varvalue,
                          l_edate,
                          l_ret_value      );

     FOR i in 1..l_ret_value.count
      LOOP
      IF l_ret_value(i).ret_val='Y' THEN
       load_balances(l_assignment_id  ,
                     l_effective_date ,
                     l_ret_value(i).balance_type_id,
                     l_ret_value(i).curent_balance       ,
                     l_ret_value(i).previous_balance,
                     l_ret_value(i).exception_report_id,
                     l_group_id,
                     l_payroll_id ,
                     l_ppa_finder,
                     l_business_group_id )     ;
      END IF;
      END LOOP;
    END IF;
   END LOOP;
    hr_utility.trace('End of LOAD DATA');
  CLOSE sel_aaid;
  hr_utility.trace('Leaving Load data');
 EXCEPTION
 ---------
  WHEN OTHERS THEN
   hr_utility.trace('Error occurred load_data ...' ||SQLERRM);
   RAISE;
END load_data;

--This function determines if there are any offset date.
FUNCTION get_offset_date (
           p_payroll_id         IN NUMBER
          ,p_consolidation_id   IN NUMBER
          ,p_effective_date     IN  DATE   )
 RETURN NUMBER
 IS
 CURSOR c_get_value
 IS
 SELECT  ppf.pay_date_offset pod
   FROM  pay_payrolls_f ppf
   WHERE ppf.payroll_id= p_payroll_id
    AND  ppf.consolidation_set_id=p_consolidation_id
    AND  p_effective_date BETWEEN ppf.effective_start_date
                             AND ppf.effective_end_date;
 l_get_value c_get_value%ROWTYPE;
 BEGIN
  OPEN c_get_value;
   FETCH c_get_value into l_get_value ;
   CLOSE c_get_value;
  RETURN NVL(l_get_value.pod,0);

 EXCEPTION
 ---------
 WHEn OTHERS THEN
 RETURN(0);
 END;


PROCEDURE run_preprocess ( actid            IN NUMBER,
                           p_effective_date IN DATE  )
IS
ppa_finder     NUMBER;
l_param        NUMBER;
l_trace        VARCHAR2(30):=0;
v_cursor       NUMBER;
v_alter_string VARCHAR2(100);
v_numrows      NUMBER;
BEGIN

 hr_utility.trace('Enter run preprocess');
--  ppa_finder             := pqp_ustiaa_pkg.get_parameter('TRANSFER_PPA_FINDER',l_param);

 load_data(actid,
           p_effective_date );
 hr_utility.trace('Leaving run preprocess');
 EXCEPTION
 ---------
  WHEN no_data_found THEN
  RAISE;

END;

-- =============================================================================
-- Get_Tax_Start_Date
-- =============================================================================
FUNCTION Get_Tax_Start_Date
         (p_legislation_code     IN  VARCHAR2
         ,p_effective_date       IN  Date
	 ,p_dimension_type_id    IN  pay_balance_dimensions.balance_dimension_id%TYPE
          ) RETURN date IS

CURSOR c_tax_start_date(c_dimension_type_id IN NUMBER
                       ,c_legislation_code  IN VARCHAR2) IS
 SELECT pers.year_begin_date
   FROM pqp_exception_report_suffix pers
  WHERE pers.database_item_suffix =(
   SELECT database_item_suffix
     FROM pay_balance_dimensions
    WHERE balance_dimension_id =c_dimension_type_id
      AND legislation_code=c_legislation_code)
   AND pers.legislation_code=c_legislation_code;


l_tax_year_start        pqp_exception_report_suffix.year_begin_date%TYPE;
l_tax_year_start_dt     Date;
l_proc_name             Varchar2(150) := g_proc_name ||'Get_Tax_Start_Date';

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   Hr_Utility.set_location('p_legislation_code   '||p_legislation_code, 5);
   Hr_Utility.set_location('p_effective_date     '||p_effective_date, 5);
   Hr_Utility.set_location('p_dimension_type_id  '||p_dimension_type_id, 5);


   OPEN c_tax_start_date(p_dimension_type_id,p_legislation_code);
   FETCH c_tax_start_date INTO l_tax_year_start;
   CLOSE c_tax_start_date;

   Hr_Utility.set_location('l_tax_year_start   '||l_tax_year_start, 5);


   IF l_tax_year_start IS NOT NULL THEN
        SELECT fnd_date.canonical_to_date(to_char(p_effective_date,'YYYY') ||
        substr(fnd_date.date_to_canonical(l_tax_year_start), 6, 5))
	INTO l_tax_year_start_dt from dual;

      --SELECT to_date(to_char(l_tax_year_start,'DD-MON-')|| to_char(p_effective_date,'YYYY'),'DD-MON-YYYY')
      --INTO l_tax_year_start_dt from dual;
   END IF;
   Hr_Utility.set_location('l_tax_year_start_dt   '||l_tax_year_start_dt, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN  l_tax_year_start_dt;

EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN null;
END Get_Tax_Start_Date;

-- =============================================================================
-- Get_Previous_Year_Tax_Date
-- =============================================================================
FUNCTION Get_Previous_Year_Tax_Date
         (p_tax_year_start_date  IN  Date
         ,p_effective_date       IN  Date ) RETURN date IS


l_previous_year_tax_dt  Date;
l_proc_name             Varchar2(150) := g_proc_name ||'Get_Previous_Year_Tax_Date';

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   Hr_Utility.set_location('p_effective_date:   '||p_effective_date, 5);
   Hr_Utility.set_location('p_tax_year_start_date:'||p_tax_year_start_date, 5);

   IF p_tax_year_start_date IS NOT NULL THEN
      IF p_tax_year_start_date > p_effective_date THEN
	  l_previous_year_tax_dt := ADD_MONTHS(p_tax_year_start_date ,-12)-1;
      ELSE
      	  l_previous_year_tax_dt := p_tax_year_start_date-1;
      END IF;
   END IF;
   Hr_Utility.set_location('l_previous_year_tax_dt   '||l_previous_year_tax_dt, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_previous_year_tax_dt;

EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN null;
END Get_Previous_Year_Tax_Date;


-- =============================================================================
-- Get_Previous_Quarter_Tax_Date
-- =============================================================================
FUNCTION Get_Previous_Quarter_Tax_Date
         (p_tax_year_start_date  IN  Date
         ,p_effective_date       IN  Date
	 ,p_count                IN  NUMBER) RETURN DATE IS


l_previous_quater_tax_dt  Date;
l_proc_name               Varchar2(150) := g_proc_name ||'Get_Previous_Quarter_Tax_Date';
l_tax_year_start_date     Date;
l_sign number;
BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   Hr_Utility.set_location('p_tax_year_start_date:'||p_tax_year_start_date, 5);
   Hr_Utility.set_location('p_effective_date:     '||p_effective_date, 5);
   Hr_Utility.set_location('p_count:              '||p_count, 5);

   IF p_tax_year_start_date IS NOT NULL THEN
      IF p_tax_year_start_date > p_effective_date THEN
	 l_tax_year_start_date := ADD_MONTHS(p_tax_year_start_date ,-12);
      ELSE
         l_tax_year_start_date := p_tax_year_start_date;
      END IF;

         SELECT  SIGN ( ADD_MONTHS(l_tax_year_start_date,3 )-p_effective_date)
            INTO l_sign
          FROM dual;

         IF l_sign = 1 or l_sign =0 THEN
            l_previous_quater_tax_dt:=l_tax_year_start_date-1;
         ELSE
             SELECT  SIGN ( ADD_MONTHS(l_tax_year_start_date,6 )-p_effective_date)
              INTO l_sign
             FROM dual;
            IF l_sign = 1 or l_sign =0 THEN
               l_previous_quater_tax_dt:=add_months ((l_tax_year_start_date-1),3);
            ELSE
               SELECT  SIGN ( ADD_MONTHS(l_tax_year_start_date,9 )-p_effective_date)
                 INTO l_sign
                FROM dual;
                IF l_sign = 1 or l_sign =0 THEN
                   l_previous_quater_tax_dt:=add_months ((l_tax_year_start_date-1),6);
                ELSE
                   SELECT  SIGN ( ADD_MONTHS(l_tax_year_start_date,12 )-p_effective_date)
                     INTO l_sign
                   FROM dual;
                  IF l_sign = 1 or l_sign =0 THEN
                     l_previous_quater_tax_dt:=add_months ((l_tax_year_start_date-1),9);
                  END IF;
                END IF;
            END IF;
         END IF;
       IF p_count > 1 THEN
          l_previous_quater_tax_dt:= ADD_MONTHS(l_previous_quater_tax_dt,((p_count-1)*-3));
       END IF;
    END IF;

   Hr_Utility.set_location('l_previous_quater_tax_dt   '||l_previous_quater_tax_dt, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_previous_quater_tax_dt;

EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN null;
END Get_Previous_Quarter_Tax_Date;
------------------------------ end load data -------------------------------
END ;

/

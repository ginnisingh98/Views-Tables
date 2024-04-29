--------------------------------------------------------
--  DDL for Package Body PAY_IN_24Q_ER_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_24Q_ER_RETURNS" AS
/* $Header: pyineqit.pkb 120.10.12010000.6 2010/01/06 06:48:36 mdubasi ship $ */
   g_debug       BOOLEAN ;
   g_package     CONSTANT VARCHAR2(100) := 'pay_in_24q_er_returns.';


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHALLAN_REC_COUNT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Challan Details of the Magtape               --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION challan_rec_count (p_gre_org_id  IN VARCHAR2
                           ,p_assess_period IN VARCHAR2
			   ,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT  DECODE(COUNT(DISTINCT action_information1),0,'1',
                COUNT(DISTINCT action_information1))
  FROM   pay_action_information pai
 WHERE   action_information_category = 'IN_24Q_CHALLAN'
   AND   action_context_type = 'PA'
   AND   action_information3 = p_gre_org_id
   AND   action_information2 = p_assess_period
   AND   pai.action_context_id= p_max_action_id
   AND  fnd_date.canonical_to_date(pai.action_information5)<=fnd_date.CHARDATE_TO_DATE(SYSDATE);

l_count NUMBER;
l_procedure varchar2(100);

BEGIN
 g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'challan_rec_count';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_assess_period',p_assess_period);
	pay_in_utils.trace('p_max_action_id',p_max_action_id);
	pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN c_count;
  FETCH c_count INTO l_count;
  IF c_count%NOTFOUND THEN
     CLOSE c_count;
     RETURN '1';
  END IF;
  CLOSE c_count;


 IF g_debug THEN
     pay_in_utils.trace('l_count',TO_CHAR(l_count));
 END IF;
 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN TO_CHAR(l_count);

END challan_rec_count;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PRODUCT_RELEASE                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the name of the  software     --
--                  used for preparing the e-TDS statement in File      --
--                  Header                                              --
--------------------------------------------------------------------------

FUNCTION get_product_release
RETURN VARCHAR2 IS
l_product_release VARCHAR2(50);
BEGIN
SELECT substr(p.product_version,1,2) INTO l_product_release
FROM fnd_application a, fnd_application_tl t, fnd_product_installations p
WHERE a.application_id = p.application_id
AND a.application_id = t.application_id
AND t.language = Userenv ('LANG')
AND Substr (a.application_short_name, 1, 5) = 'PAY';
RETURN l_product_release;
END get_product_release;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DEDUCTEE_REC_COUNT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Deductee Details of the Magtape              --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--                  p_challan             VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION deductee_rec_count (p_gre_org_id  IN VARCHAR2
			    ,p_max_action_id IN VARCHAR2
			    ,p_challan   IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM  pay_action_information pai
  WHERE  action_information_category = 'IN_24Q_DEDUCTEE'
    AND  action_context_type = 'AAP'
    AND  action_information3 =  p_gre_org_id
    AND  EXISTS (SELECT 1 FROM pay_assignment_actions paa
                 WHERE paa.payroll_action_id = p_max_action_id
                 AND paa.assignment_action_id = pai.action_context_id)
   AND pai.action_information1 = p_challan
   AND  pay_in_24q_er_returns.get_format_value(NVL(pai.action_information5,'0')) <> '0.00'
--   AND  fnd_date.canonical_to_date(pai.action_information4)<=fnd_date.CHARDATE_TO_DATE(SYSDATE)
   ORDER BY action_information1, action_information2 ASC;

l_count NUMBER;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'deductee_rec_count';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_max_action_id',p_max_action_id);
	pay_in_utils.trace('p_challan',p_challan);
	pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN c_count;
  FETCH c_count INTO l_count;
  IF c_count%NOTFOUND THEN
     CLOSE c_count;
     RETURN '0';
  END IF;
  CLOSE c_count;



  IF g_debug THEN
     pay_in_utils.trace('l_count',TO_CHAR(l_count));
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN TO_CHAR(l_count);

END deductee_rec_count;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GROSS_TOT_TDS_CHALLAN                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Gross Total of TDS        --
--                  deducted as per Challan details annexure            --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION gross_tot_tds_challan(p_gre_org_id  IN VARCHAR2
			      ,p_assess_period IN VARCHAR2
			      ,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_challan_tax_tot IS
SELECT  SUM (TDS)
      , SUM (SUR)
      , SUM (EC)
      , SUM (INTR)
      , SUM (OTH)
 FROM ( SELECT DISTINCT  pai.action_information1
                       , NVL(pai.action_information6,0)  TDS
                       , NVL(pai.action_information7,0)  SUR
                       , NVL(pai.action_information8,0)  EC
                       , NVL(pai.action_information9,0)  INTR
                       , NVL(pai.action_information10,0) OTH
         FROM pay_action_information pai
        WHERE action_information_category = 'IN_24Q_CHALLAN'
          AND action_context_type = 'PA'
          AND action_information3 = p_gre_org_id
          AND action_information2 = p_assess_period
          AND pai.action_context_id= p_max_action_id
          AND fnd_date.canonical_to_date(pai.action_information5)<=fnd_date.CHARDATE_TO_DATE(SYSDATE));

l_tot   NUMBER:= 0;
l_tds   NUMBER:= 0;
l_sur   NUMBER:= 0;
l_ec    NUMBER:= 0;
l_intr  NUMBER:= 0;
l_oth   NUMBER:= 0;
l_total VARCHAR2(20);
l_procedure varchar2(100);

BEGIN
 g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'gross_tot_tds_challan';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_assess_period',p_assess_period);
	pay_in_utils.trace('p_max_action_id',p_max_action_id);
	pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN c_challan_tax_tot;
  FETCH c_challan_tax_tot INTO l_tds,l_sur,l_ec,l_intr,l_oth;
  CLOSE c_challan_tax_tot;

  l_tot := l_tds + l_sur + l_ec + l_intr + l_oth;

  l_tot :=ROUND(l_tot,0);
  l_total :=TO_CHAR(NVL(l_tot,0))||'.00';



  IF g_debug THEN
     pay_in_utils.trace('l_total',SUBSTR(l_total,1,15));
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN SUBSTR(l_total,1,15);

END gross_tot_tds_challan;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FORMAT_VALUE                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns value with precision          --
--                  of two decimal place                                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_value              VARCHAR2                       --
--------------------------------------------------------------------------
FUNCTION get_format_value(p_value IN VARCHAR2)
RETURN VARCHAR2 IS

l_value      VARCHAR2(20);
l_value_temp VARCHAR2(20);
l_procedure varchar2(100);

BEGIN
 g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'get_format_value';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
 IF g_debug THEN
	pay_in_utils.trace('p_value',p_value);
 END IF;

 l_value_temp := fnd_number.canonical_to_number(p_value);

 IF(NVL(l_value_temp,0)=0) THEN
       RETURN '0.00';
 END IF;

 l_value := (l_value_temp*100);

l_value := SUBSTR(l_value,1,length(l_value)-2)||'.'||SUBSTR(l_value,length(l_value)-1,length(l_value));


IF g_debug THEN
     pay_in_utils.trace('l_value',l_value);
END IF;

pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN l_value;

END get_format_value;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_24Q_TAX_VALUES                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Gross Total of TDS        --
--                  deducted as per Deductee details annexure           --
-- Parameters     :                                                     --
--             IN : p_challan_number       VARCHAR2                     --
--                  p_gre_org_id          VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_24Q_tax_values(
                            p_challan_number IN VARCHAR2
			   ,p_gre_org_id IN VARCHAR2
			   ,p_max_action_id IN VARCHAR2
			    )
RETURN VARCHAR2 IS

CURSOR c_form24Q_tax_values IS
  SELECT  SUM(NVL(pai.action_information9,0))    -----total tax paid
         ,SUM(NVL(pai.action_information6,0))
	 ,SUM(NVL(pai.action_information7,0))
	 ,SUM(NVL(pai.action_information8,0))
   FROM  pay_action_information pai
  WHERE  action_information_category ='IN_24Q_DEDUCTEE'
    AND  action_context_type = 'AAP'
    AND  action_information3 =p_gre_org_id
    AND  action_information1=p_challan_number
    AND  EXISTS ( SELECT 1
                  FROM pay_assignment_actions paa
                  WHERE paa.payroll_action_id = p_max_action_id
                  AND paa.assignment_action_id = pai.action_context_id)
--    AND  fnd_date.canonical_to_date(pai.action_information4)<=fnd_date.CHARDATE_TO_DATE(SYSDATE)
    ORDER BY action_information1, action_information2 ASC;


    l_value29 VARCHAR2(20);
    l_value30 VARCHAR2(20);
    l_value31 VARCHAR2(20);
    l_value32 VARCHAR2(20);
    l_value33 VARCHAR2(20);
    l_total_tax_values VARCHAR2(100);
    l_procedure varchar2(100);

BEGIN
 g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'gross_tot_tds_challan';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_challan_number',p_challan_number);
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_max_action_id',p_max_action_id);
	pay_in_utils.trace('**************************************************','********************');
 END IF;


    l_value29 :=0;
    l_value30 :=0;
    l_value31 :=0;
    l_value32 :=0;
    l_value33 :=0;

   OPEN c_form24Q_tax_values;
   FETCH c_form24Q_tax_values INTO l_value29,l_value30,l_value31,l_value32;
   CLOSE c_form24Q_tax_values;

     l_value33 :=l_value30+l_value31+l_value32;

     l_value29 :=get_format_value(l_value29);
     l_value30 :=get_format_value(l_value30);
     l_value31 :=get_format_value(l_value31);
     l_value32 :=get_format_value(l_value32);
     l_value33 :=get_format_value(l_value33);

     l_total_tax_values := l_value29||'^'||l_value30||'^'||l_value31||'^'||l_value32||'^'||l_value33||'^';


     IF g_debug THEN
         pay_in_utils.trace('l_total_tax_values',l_total_tax_values);
     END IF;

     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

    RETURN l_total_tax_values;

END    get_24Q_tax_values;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHAPTER_VIA_REC_COUNT                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Chapter-VIA Details of the Magtape           --
-- Parameters     :                                                     --
--             IN : p_action_context_id          VARCHAR2               --
--                  p_source_id                  VARCHAR2               --
--------------------------------------------------------------------------
FUNCTION chapter_VIA_rec_count (p_action_context_id  IN VARCHAR2
                               ,p_source_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
SELECT COUNT(*)
 FROM  pay_action_information
WHERE  action_information_category = 'IN_24Q_VIA'
  AND  action_context_type = 'AAP'
  AND  action_context_id =   p_action_context_id
  AND  source_id =p_source_id;

l_count NUMBER;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'chapter_VIA_rec_count';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_action_context_id',p_action_context_id);
	pay_in_utils.trace('p_source_id',p_source_id);
	pay_in_utils.trace('**************************************************','********************');
END IF;

 OPEN c_count;
  FETCH c_count INTO l_count;
  IF c_count%NOTFOUND THEN
     CLOSE c_count;
     RETURN '0';
  END IF;
 CLOSE c_count;


 IF g_debug THEN
     pay_in_utils.trace('l_count',TO_CHAR(l_count));
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN TO_CHAR(l_count);

END chapter_VIA_rec_count;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : SALARY_REC_COUNT                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Salary Details of the Magtape                --
-- Parameters     :                                                     --
--             IN : p_gre_org_id            VARCHAR2                    --
--                  p_assess_period         VARCHAR2                    --
--------------------------------------------------------------------------
FUNCTION salary_rec_count (p_gre_org_id  IN VARCHAR2
                          ,p_assess_period IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM  pay_action_information
  WHERE  action_information_category = 'IN_24Q_PERSON'
    AND  action_context_type = 'AAP'
    AND  action_information2 =  p_assess_period
    AND  action_information3 =  p_gre_org_id
    AND  action_context_id  IN (SELECT MAX(pai.action_context_id)
                                 FROM  pay_action_information pai
                                      ,pay_assignment_actions paa
                                      ,per_assignments_f asg
                                WHERE  pai.action_information_category = 'IN_24Q_PERSON'
                                  AND  pai.action_context_type = 'AAP'
                                  AND  pai.action_information1 = asg.person_id
                                  AND  pai.assignment_id       = asg.assignment_id
                                  AND  asg.business_group_id   = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                  AND  pai.action_information2 = p_assess_period
                                  AND  pai.action_information3 = p_gre_org_id
                                  AND  pai.source_id = paa.assignment_action_id
                              GROUP BY pai.assignment_id,pai.action_information1,pai.action_information9
                              );


l_count NUMBER;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'salary_rec_count';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_assess_period',p_assess_period);
	pay_in_utils.trace('**************************************************','********************');
END IF;
 OPEN c_count;
  FETCH c_count INTO l_count;
  IF c_count%NOTFOUND THEN
     CLOSE c_count;
     RETURN '0';
  END IF;
 CLOSE c_count;


 IF g_debug THEN
     pay_in_utils.trace('l_count',TO_CHAR(l_count));
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN TO_CHAR(l_count);

END salary_rec_count;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : DEDUCTEE_SALARY_COUNT                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of Salary    --
--                  Details records of a particular employee            --
-- Parameters     :                                                     --
--             IN : p_gre_org_id            VARCHAR2                    --
--                  p_assess_period         VARCHAR2                    --
--                  p_assignment_id         VARCHAR2                    --
--------------------------------------------------------------------------
FUNCTION deductee_salary_count (p_gre_org_id  IN VARCHAR2
                               ,p_assess_year IN VARCHAR2
			       ,p_assignment_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM  pay_action_information
  WHERE  action_information_category = 'IN_24Q_PERSON'
    AND  action_context_type = 'AAP'
    AND  SUBSTR(action_information2,1,9) = p_assess_year
    AND  action_information3 =  p_gre_org_id
    AND  assignment_id = p_assignment_id
    AND  action_context_id  IN ( SELECT  MAX(action_context_id)
                                 FROM  pay_action_information pai
                                      ,pay_assignment_actions paa
                                      ,per_assignments_f asg
                                WHERE  action_information_category = 'IN_24Q_PERSON'
                                  AND  action_context_type         = 'AAP'
                                  AND  pai.action_information1     = asg.person_id
                                  AND  SUBSTR(pai.action_information2,1,9) = p_assess_year
                                  AND  pai.action_information3     = p_gre_org_id
                                  AND  asg.business_group_id       = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                                  AND  pai.source_id               = paa.assignment_action_id
                                  AND  pai.assignment_id           = asg.assignment_id
                                  GROUP BY  pai.assignment_id,action_information1,action_information9
                               );


l_count NUMBER;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'deductee_salary_count';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_assess_year',p_assess_year);
	pay_in_utils.trace('p_assignment_id',p_assignment_id);
	pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN c_count;
  FETCH c_count INTO l_count;
  IF c_count%NOTFOUND THEN
     CLOSE c_count;
     RETURN '0';
  END IF;
  CLOSE c_count;



  IF g_debug THEN
     pay_in_utils.trace('l_count',TO_CHAR(l_count));
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN TO_CHAR(l_count);

END deductee_salary_count;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_24Q_VALUES                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the values corresponding to   --
--                  the F16 Balances                                    --
-- Parameters     :                                                     --
--             IN : p_category          VARCHAR2                        --
--                  p_component_name    VARCHAR2                        --
--                  p_context_id        NUMBER                          --
--                  p_source_id         NUMBER                          --
--                  p_segment_num       NUMBER                          --
--------------------------------------------------------------------------
FUNCTION get_24Q_values (p_category       IN VARCHAR2
                        ,p_component_name IN VARCHAR2
			,p_context_id     IN NUMBER
			,p_source_id      IN NUMBER
			,p_segment_num    IN NUMBER )
RETURN VARCHAR2 IS

CURSOR c_form24Q_values IS
  SELECT  NVL(fnd_number.canonical_to_number(action_information2),0)
         ,NVL(fnd_number.canonical_to_number(action_information3),0)
    FROM  pay_action_information
   WHERE  action_information_category = p_category
     AND  action_information1 = p_component_name
     AND  action_context_id = p_context_id
     AND  source_id = p_source_id;

l_value1 VARCHAR2(20);
l_value2  VARCHAR2(20);
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'get_24Q_values';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_category',p_category);
	pay_in_utils.trace('p_component_name',p_component_name);
	pay_in_utils.trace('p_context_id',TO_CHAR(p_context_id));
	pay_in_utils.trace('p_source_id',TO_CHAR(p_source_id));
	pay_in_utils.trace('p_segment_num',TO_CHAR(p_segment_num));
	pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN c_form24Q_values;
  FETCH c_form24Q_values INTO l_value1,l_value2;
  IF c_form24Q_values%NOTFOUND THEN
    CLOSE c_form24Q_values;
    RETURN '0.00';
  END IF;
  CLOSE c_form24Q_values;

  l_value2 := get_format_value(l_value2+l_value1);
  l_value1 := get_format_value(l_value1);


  pay_in_utils.set_location(g_debug,'l_value1 = : '||l_value1,20);
  pay_in_utils.set_location(g_debug,'l_value2 = : '||l_value2,30);

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,40);

  IF(p_segment_num=1) THEN
       RETURN l_value1;
  ELSIF(p_segment_num=2) THEN
       RETURN l_value2;
  END IF;


END get_24Q_values;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EMPLOYER_CLASS                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the employer classfication    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_emplr_class (p_gre_org_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_employer IS
 SELECT org_information6
   FROM hr_organization_information
  WHERE org_information_context = 'PER_IN_INCOME_TAX_DF'
    AND organization_id = p_gre_org_id;

 l_emplr_class VARCHAR2(150);
 l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'get_emplr_class';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
 END IF;

  OPEN c_employer;
  FETCH c_employer INTO l_emplr_class;
  IF c_employer%NOTFOUND THEN
    CLOSE c_employer;
    RETURN 'XYZ';
  END IF;
  CLOSE c_employer;


  IF g_debug THEN
	     pay_in_utils.trace('l_emplr_class',l_emplr_class);
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN l_emplr_class;

END get_emplr_class;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : TOTAL_GROSS_TOT_INCOME                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the total of Gross Total      --
--                  Income as per salary details annexure               --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION total_gross_tot_income (p_gre_org_id IN VARCHAR2
                                ,p_assess_period IN VARCHAR2
				)
RETURN VARCHAR2 IS

CURSOR csr_income_details(p_balance VARCHAR2,p_action_context_id NUMBER,p_source_id IN NUMBER)
IS
 SELECT NVL(SUM(fnd_number.canonical_to_number(action_information2)),0)
   FROM pay_action_information
  WHERE action_information_category = 'IN_24Q_SALARY'
    AND action_context_type = 'AAP'
    AND action_information1 = p_balance
    AND action_context_id = p_action_context_id
    AND source_id = p_source_id;

CURSOR csr_get_max_cont_id IS
    SELECT MAX(pai.action_context_id) action_cont_id
          ,source_id sour_id
      FROM pay_action_information      pai
          ,pay_assignment_actions      paa
          ,per_assignments_f           asg
      WHERE pai.action_information_category = 'IN_24Q_PERSON'
        AND pai.action_information3         = p_gre_org_id
        AND pai.action_information2         = p_assess_period
        AND pai.action_information1         = asg.person_id
        AND asg.business_group_id           = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
        AND asg.assignment_id               = pai.assignment_id
        AND pai.action_context_type         = 'AAP'
        AND pai.source_id                   = paa.assignment_action_id
   GROUP BY pai.action_information1,pai.action_information9,source_id;


l_total_gross    NUMBER:=0;
l_value  NUMBER:=0;
l_total_value VARCHAR2(20);
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'total_gross_tot_income';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
	pay_in_utils.trace('p_assess_period',p_assess_period);
	pay_in_utils.trace('**************************************************','********************');
 END IF;
  FOR i IN  csr_get_max_cont_id
  LOOP
      OPEN csr_income_details('F16 Gross Total Income',i.action_cont_id,i.sour_id);
      FETCH csr_income_details INTO l_value;
      CLOSE csr_income_details;
      l_total_gross:= l_total_gross + l_value;
   END LOOP;

  l_total_value :=get_format_value(l_total_gross);

  IF g_debug THEN
       pay_in_utils.trace('l_total_value',SUBSTR(l_total_value,1,15));
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN SUBSTR(l_total_value,1,15);

END total_gross_tot_income;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LOCATION_DETAILS                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                             --
-- Description    : This function gets the gre location details        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id         hr_locations.location_id      --
--                : p_concatenate         VARCHAR2                      --
--                  p_field               VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_location_details ( p_location_id  IN   hr_locations.location_id%TYPE
                               ,p_rep_email_id IN   VARCHAR2
			       ,p_rep_phone    IN   VARCHAR2
                               ,p_segment_num  IN   NUMBER
			       ,p_person_type  IN   VARCHAR2)
RETURN VARCHAR2
IS

   CURSOR csr_add IS
      SELECT    address_line_1,
                address_line_2,
                address_line_3,
	        loc_information14,
                loc_information15,
            NVL(hr_general.decode_lookup('IN_STATE_CODES',loc_information16),'^'),
            NVL(postal_code,'^'),
	    NVL(LOC_INFORMATION17,'^'),
	    NVL(TELEPHONE_NUMBER_1,'^')
        FROM hr_locations
       WHERE location_id = p_location_id;

   l_add_1    hr_locations.address_line_1%TYPE;
   l_add_2    hr_locations.address_line_2%TYPE;
   l_add_3    hr_locations.address_line_3%TYPE;
   l_add_4    hr_locations.loc_information14%TYPE;
   l_add_5    hr_locations.loc_information15%TYPE;
   l_email    hr_locations.loc_information17%TYPE;
   l_phone    hr_locations.telephone_number_1%TYPE;
   l_state    hr_lookups.meaning%TYPE;
   l_pin      hr_locations.postal_code%TYPE;
   l_std     hr_locations.TELEPHONE_NUMBER_1%TYPE;
   l_telph   hr_locations.TELEPHONE_NUMBER_1%TYPE;
   l_remark  VARCHAR2(75);
   p_address1  VARCHAR2(60);
   p_address2  VARCHAR2(60);
   p_address3  VARCHAR2(60);
   p_address4  VARCHAR2(80);
   p_address5  VARCHAR2(60);
   l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'get_location_details';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_location_id ',p_location_id );
	pay_in_utils.trace('p_rep_email_id',p_rep_email_id);
	pay_in_utils.trace('p_rep_phone   ',p_rep_phone   );
	pay_in_utils.trace('p_segment_num ',to_char(p_segment_num) );
	pay_in_utils.trace('p_person_type ',p_person_type );
	pay_in_utils.trace('**************************************************','********************');
 END IF;


   OPEN csr_add;
   FETCH csr_add INTO l_add_1, l_add_2, l_add_3, l_add_4, l_add_5, l_state, l_pin, l_email, l_phone;
   IF csr_add%NOTFOUND THEN
      CLOSE csr_add;
      IF(p_segment_num=5 AND p_person_type='REP') THEN

	IF g_debug THEN
	   pay_in_utils.trace('3',RPAD('^',3,'^'));
	END IF;

       pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

       RETURN RPAD('^',3,'^');
      ELSE
	IF g_debug THEN
	   pay_in_utils.trace('2',RPAD('^',2,'^'));
	END IF;
	pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,30);
        RETURN RPAD('^',2,'^');
      END IF;
   END IF;
   CLOSE csr_add;

   l_std :='^';
   l_telph :='^';
   l_remark:='^';

-----------Address1-------------

   IF LENGTH(l_add_1)<=25 THEN
     p_address1 := p_address1||l_add_1;
   ELSE
     p_address1 :=p_address1||SUBSTR(l_add_1,1,25);
     l_add_2 := SUBSTR(l_add_1,26)||', '||l_add_2;
   END IF;
   p_address1 := p_address1||'^';

   IF l_add_2 IS NOT NULL THEN
          IF LENGTH(l_add_2) <=25 THEN
	         p_address1 := p_address1||l_add_2||'^';
	  ELSE
	         p_address1 := p_address1||SUBSTR(l_add_2,1,25)||'^';
                 l_add_3 := SUBSTR(l_add_2,26)||', '||l_add_3;
	  END IF ;
   ELSE
           p_address1 := p_address1||'^';
   END IF;

   IF (p_segment_num=1) THEN
   	IF g_debug THEN
	   pay_in_utils.trace('p_address1',p_address1);
	END IF;

	pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,40);

       RETURN p_address1;
   END IF;

---------Address2-------------------------

   IF l_add_3 IS NOT NULL THEN
          IF LENGTH(l_add_3) <=25 THEN
	      p_address2 := p_address2||l_add_3||'^';
	   ELSE
	      p_address2 := p_address2||SUBSTR(l_add_3,1,25)||'^';
              l_add_4 := SUBSTR(l_add_3,26)||', '||l_add_4;
	   END IF ;
   ELSE
           p_address2 := p_address2||'^';
   END IF;


   IF l_add_4 IS NOT NULL THEN
           IF LENGTH(l_add_4) <=25 THEN
	       p_address2 := p_address2||l_add_4||'^';
	   ELSE
	       p_address2 := p_address2||SUBSTR(l_add_4,1,25)||'^';
               l_add_5 := SUBSTR(l_add_4,26)||', '||l_add_5;
	   END IF ;
     ELSE
           p_address2 := p_address2||'^';
   END IF;

   IF (p_segment_num=2) THEN
   	IF g_debug THEN
	   pay_in_utils.trace('p_address2',p_address2);
	END IF;
	pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,50);
	RETURN p_address2;
   END IF ;

---------Address3-------------------------

   IF LENGTH(l_add_5) <=25 THEN
	     p_address3 := p_address3||l_add_5;
   ELSE
	     p_address3 := p_address3||SUBSTR(l_add_5,1,25);
   END IF ;
   p_address3 := p_address3||'^';

   IF(l_state<>'^' ) THEN
        l_state:=l_state||'^';
   END IF ;

   IF(l_pin <>'^' ) THEN
       l_pin:=l_pin||'^';
   END IF;
   p_address3 :=p_address3||l_state||l_pin;

   IF (p_segment_num=3) THEN
   	IF g_debug THEN
	    pay_in_utils.trace('p_address3',p_address3);
	END IF;

	pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,60);

        RETURN p_address3;
   END IF ;

---------Address4-------------------------

   IF(p_person_type='REP') THEN
       l_email :=NVL(p_rep_email_id,'^');
       l_phone :=NVL(p_rep_phone,'^');
   END IF;

   IF (l_email<>'^') THEN
       l_email :=SUBSTR (l_email,1,74)||'^';
   END IF ;
   p_address4 :=l_email;

   IF (p_segment_num=4) THEN
   	IF g_debug THEN
	   pay_in_utils.trace('p_address4',p_address4);
	END IF;
	pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,70);
        RETURN p_address4;
   END IF ;

---------Address5-------------------------

   IF (l_phone <>'^') THEN
       SELECT  SUBSTR (l_phone,INSTR(l_phone,'-',1,1)+1,INSTR(l_phone,'-',1,2)-INSTR (l_phone,'-',1,1)-1) STD
              ,SUBSTR (l_phone,INSTR(l_phone,'-',1,2)+1) TELPH
         INTO  l_std,l_telph
         FROM  dual;
       l_std :=SUBSTR(l_std,1,5)||'^';
       l_telph := SUBSTR(l_telph,1,10)||'^';
   END IF;


   IF(p_person_type='EMP') THEN
           p_address5:=l_std||l_telph;
   ELSE
           p_address5:=l_remark||l_std||l_telph;
   END IF;

   IF (p_segment_num=5) THEN
      	IF g_debug THEN
	   pay_in_utils.trace('p_address5',p_address5);
	END IF;
	pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,80);
      RETURN p_address5;
   END IF;


END get_location_details;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EMP_CATEGORY                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function gets the employee category            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id           VARCHAR2                      --
--                :                                                     --
--        Returns : l_emp_category                                      --
--------------------------------------------------------------------------
FUNCTION get_emp_category(p_person_id IN VARCHAR2)
RETURN VARCHAR2 IS
CURSOR csr_person_category
IS
   SELECT sex
         ,TO_CHAR(MONTHS_BETWEEN(SYSDATE, date_of_birth)) l_age
    FROM per_all_people_f
   WHERE person_id = p_person_id
     AND SYSDATE BETWEEN effective_start_date AND effective_end_date;

 l_procedure    VARCHAR2(100);
 l_sex          VARCHAR2(500);
 l_age          VARCHAR2(100);
 l_emp_category VARCHAR2(100);

BEGIN
 g_debug     := hr_utility.debug_enabled;
 l_procedure := g_package ||'get_emp_category';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_person_id ',p_person_id );
        pay_in_utils.trace('**************************************************','********************');
 END IF;

   OPEN csr_person_category;
   FETCH csr_person_category INTO l_sex, l_age;
   CLOSE csr_person_category;

   IF (l_sex = 'F') THEN
      l_emp_category := 'W';
   ELSIF (l_sex = 'M' AND l_age >= 780) THEN
      l_emp_category := 'S';
   ELSE
      l_emp_category := 'G';
   END IF;

   pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

   RETURN l_emp_category;

   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_emp_category ',l_emp_category );
        pay_in_utils.trace('**************************************************','********************');
   END IF;

END get_emp_category;

END pay_in_24q_er_returns;

/

--------------------------------------------------------
--  DDL for Package Body PAY_IN_EOY_ER_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_EOY_ER_RETURNS" AS
/* $Header: pyinerit.pkb 120.4 2006/05/19 08:53:37 abhjain noship $ */
   g_debug BOOLEAN;
   g_package CONSTANT VARCHAR2(100) := 'pay_in_eoy_er_returns.' ;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHALLAN_REC_COUNT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Challan Details of the Magtape              --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_year         VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION challan_rec_count (p_gre_org_id  IN VARCHAR2
                           ,p_assess_year IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM  hr_organization_information ch_b
       , hr_organization_information it_ch
  WHERE  it_ch.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
    AND  ch_b.org_information_context = 'PER_IN_CHALLAN_BANK'
    AND  it_ch.organization_id = p_gre_org_id
    AND  it_ch.org_information1 = TO_CHAR((TO_NUMBER(SUBSTR(p_assess_year,1,4)) - 1)||'-'||SUBSTR(p_assess_year,1,4))
    AND  it_ch.organization_id = ch_b.organization_id
    AND  TO_NUMBER(it_ch.org_information5) = ch_b.org_information_id;

   l_count NUMBER;
   l_procedure varchar2(100);

BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'challan_rec_count';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
       pay_in_utils.trace('p_assess_year',p_assess_year);
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

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  RETURN TO_CHAR(l_count);

END challan_rec_count;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DEDUCTEE_REC_COUNT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Deductee Details of the Magtape              --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_year         VARCHAR2                      --
--------------------------------------------------------------------------

FUNCTION deductee_rec_count (p_gre_org_id  IN VARCHAR2
                            ,p_assess_year IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM   pay_action_information
  WHERE  action_information_category = 'IN_EOY_PERSON'
    AND  action_context_type = 'AAP'
    AND  action_information2 =  p_assess_year
    AND  action_information3 =  p_gre_org_id
    AND  action_context_id  IN ( SELECT  MAX(pai.action_context_id)
                                 FROM  pay_action_information pai
                                      ,pay_assignment_actions paa
                                      ,per_assignments_f asg
                                WHERE  pai.action_information_category = 'IN_EOY_PERSON'
                                  AND  pai.action_context_type = 'AAP'
                                  AND  pai.assignment_id = asg.assignment_id
                                  AND  paa.assignment_id = asg.assignment_id
                                  AND  asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                  AND  pai.action_information2 = p_assess_year
                                  AND  pai.action_information3 = p_gre_org_id
                                  AND  pai.source_id = paa.assignment_action_id
                             GROUP BY  pai.action_information1,pai.action_information17 );

l_count NUMBER;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'deductee_rec_count';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
       pay_in_utils.trace('p_assess_year',p_assess_year);
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
-- Name           : PERQ_REC_COUNT                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Perquisite Details of the Magtape            --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_year         VARCHAR2                      --
--------------------------------------------------------------------------

FUNCTION perq_rec_count (p_gre_org_id  IN VARCHAR2
                        ,p_assess_year IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM  pay_action_information
  WHERE  action_information_category = 'IN_EOY_PERSON'
    AND  action_context_type = 'AAP'
    AND  action_information2 =  p_assess_year
    AND  action_information3 =  p_gre_org_id
    AND  action_context_id  IN ( SELECT  MAX(pai.action_context_id)
                                 FROM  pay_action_information pai
                                      ,pay_assignment_actions paa
                                      ,per_assignments_f asg
                                WHERE  pai.action_information_category = 'IN_EOY_PERSON'
                                  AND  pai.action_context_type = 'AAP'
                                  AND  pai.assignment_id = asg.assignment_id
                                  AND  paa.assignment_id = asg.assignment_id
                                  AND  asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                  AND  pai.action_information2 = p_assess_year
                                  AND  pai.action_information3 = p_gre_org_id
                                  AND  pai.source_id = paa.assignment_action_id
                             GROUP BY  pai.action_information1,pai.action_information17 );


l_count NUMBER;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'perq_rec_count';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
       pay_in_utils.trace('p_assess_year',p_assess_year);
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

END perq_rec_count;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GROSS_TOT_TDS_CHALLAN                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Gross Total of TDS        --
--                  deducted as per Challan details annexure            --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_year         VARCHAR2                      --
--------------------------------------------------------------------------

FUNCTION gross_tot_tds_challan(p_gre_org_id  IN VARCHAR2
			      ,p_assess_year IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_challan_tax_tot IS
SELECT  SUM(NVL(it_ch.org_information4,0))  TDS
      , SUM(NVL(it_ch.org_information7,0))  SUR
      , SUM(NVL(it_ch.org_information8,0))  EC
      , SUM(NVL(it_ch.org_information9,0))  INTR
      , SUM(NVL(it_ch.org_information10,0)) OTH
 FROM   hr_organization_information ch_b
      , hr_organization_information it_ch
 WHERE  it_ch.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
   AND  ch_b.org_information_context = 'PER_IN_CHALLAN_BANK'
   AND  it_ch.organization_id = p_gre_org_id
   AND  it_ch.org_information1 = TO_CHAR((TO_NUMBER(SUBSTR(p_assess_year,1,4)) - 1)||'-'||SUBSTR(p_assess_year,1,4))
   AND  it_ch.organization_id = ch_b.organization_id
   AND  TO_NUMBER(it_ch.org_information5) = ch_b.org_information_id;

l_tot   NUMBER:= 0;
l_tds   NUMBER:= 0;
l_sur   NUMBER:= 0;
l_ec    NUMBER:= 0;
l_intr  NUMBER:= 0;
l_oth   NUMBER:= 0;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'gross_tot_tds_challan';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
       pay_in_utils.trace('p_assess_year',p_assess_year);
       pay_in_utils.trace('**************************************************','********************');
  END IF;

  OPEN c_challan_tax_tot;
  FETCH c_challan_tax_tot INTO l_tds,l_sur,l_ec,l_intr,l_oth;
  IF c_challan_tax_tot%NOTFOUND THEN
     CLOSE c_challan_tax_tot;
     RETURN '0';
  END IF;
  CLOSE c_challan_tax_tot;

  l_tot := l_tds + l_sur + l_ec + l_intr + l_oth;
  l_tot := NVL(l_tot,0) * 100;


  IF g_debug THEN
       pay_in_utils.trace('l_tot',TO_CHAR(l_tot));
  END IF;
  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN TO_CHAR(l_tot);


END gross_tot_tds_challan;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GROSS_TOT_TDS_DEDUCTEE                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Gross Total of TDS        --
--                  deducted as per Deductee details annexure           --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_year         VARCHAR2                      --
--------------------------------------------------------------------------

FUNCTION gross_tot_tds_deductee (p_gre_org_id IN VARCHAR2
                                ,p_assess_year IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR csr_tax_details(p_balance VARCHAR2,p_action_context_id NUMBER,p_source_id IN NUMBER)
IS
 SELECT NVL(SUM(action_information2),0)
   FROM pay_action_information
  WHERE action_information_category = 'IN_EOY_ASG_SAL'
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
       WHERE pai.action_information_category = 'IN_EOY_PERSON'
         AND pai.assignment_id = asg.assignment_id
         AND paa.assignment_id = asg.assignment_id
         AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND pai.action_information3         = p_gre_org_id
         AND pai.action_information2         = p_assess_year
         AND pai.action_context_type         = 'AAP'
         AND pai.source_id                   = paa.assignment_action_id
    GROUP BY pai.action_information1,pai.action_information17,source_id;

l_tds    NUMBER:=0;
l_it_td  NUMBER;
l_sc_td  NUMBER;
l_ec_td  NUMBER;
l_value  NUMBER:=0;
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'gross_tot_tds_deductee';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
       pay_in_utils.trace('p_assess_year',p_assess_year);
       pay_in_utils.trace('**************************************************','********************');
  END IF;

  FOR i IN  csr_get_max_cont_id
  LOOP
      OPEN csr_tax_details('Income Tax Deduction',i.action_cont_id,i.sour_id);
      FETCH csr_tax_details INTO l_value;
      CLOSE csr_tax_details;

      l_tds := l_tds + l_value;
   END LOOP;

  l_tds := l_tds * 100;

  IF g_debug THEN
     pay_in_utils.trace('l_tds',TO_CHAR(l_tds));
  END IF;
  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
  RETURN TO_CHAR(l_tds);

END gross_tot_tds_deductee;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EOY_VALUES                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the values corresponding to   --
--                  the F16 Balances                                    --
-- Parameters     :                                                     --
--             IN : p_category          VARCHAR2                        --
--                  p_component_name    VARCHAR2                        --
--                  p_context_id        NUMBER                          --
--                  p_segment_num       NUMBER                          --
--------------------------------------------------------------------------

FUNCTION get_eoy_values (p_category       IN VARCHAR2
                        ,p_component_name IN VARCHAR2
			,p_context_id     IN NUMBER
			,p_source_id      IN NUMBER
			,p_segment_num    IN NUMBER)
RETURN VARCHAR2 IS

CURSOR c_form24_values IS
  SELECT  NVL(action_information2,'0')
         ,NVL(action_information3,'0')
	 ,NVL(action_information4,'0')
	 ,NVL(action_information5,'0')
    FROM  pay_action_information
   WHERE  action_information_category = p_category
     AND  action_information1 = p_component_name
     AND  action_context_id = p_context_id
     AND  source_id = p_source_id;

l_ai2 VARCHAR2(240);
l_ai3 VARCHAR2(240);
l_ai4 VARCHAR2(240);
l_ai5 VARCHAR2(240);
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'get_eoy_values';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_category',p_category);
       pay_in_utils.trace('p_component_name',p_component_name);
       pay_in_utils.trace('p_context_id',to_char(p_context_id));
       pay_in_utils.trace('p_source_id',to_char(p_source_id));
       pay_in_utils.trace('p_segment_num',to_char(p_segment_num));
       pay_in_utils.trace('**************************************************','********************');

  END IF;

  OPEN c_form24_values;
  FETCH c_form24_values INTO l_ai2,l_ai3,l_ai4,l_ai5;
  IF c_form24_values%NOTFOUND THEN
    CLOSE c_form24_values;
    RETURN '0';
  END IF;
  CLOSE c_form24_values;

  l_ai2 := TO_CHAR(TO_NUMBER(l_ai2) * 100);
  l_ai3 := TO_CHAR(TO_NUMBER(l_ai3) * 100);
  l_ai4 := TO_CHAR(TO_NUMBER(l_ai4) * 100);
  l_ai5 := TO_CHAR(TO_NUMBER(l_ai5) * 100);

  pay_in_utils.set_location (g_debug,'l_ai2'||l_ai2,20);
  pay_in_utils.set_location (g_debug,'l_ai3'||l_ai3,30);
  pay_in_utils.set_location (g_debug,'l_ai4'||l_ai4,40);
  pay_in_utils.set_location (g_debug,'l_ai5'||l_ai5,50);


  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,60);

  IF p_segment_num = 2 THEN
    RETURN l_ai2;
  ELSIF p_segment_num = 3 THEN
    RETURN l_ai3;
  ELSIF p_segment_num = 4 THEN
    RETURN l_ai4;
  ELSIF p_segment_num = 5 THEN
    RETURN l_ai5;
  END IF;

END get_eoy_values;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TDE_REMARKS                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the remarks entered at the    --
--                  assignment extra Information                        --
-- Parameters     :                                                     --
--             IN : p_person_id          VARCHAR2                       --
--                  p_assess_year        VARCHAR2                       --
--------------------------------------------------------------------------

FUNCTION get_tde_remarks (p_person_id   IN VARCHAR2
                         ,p_assess_year IN VARCHAR2
			 ,p_date        IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_remarks IS
 SELECT  paei.aei_information2
   FROM  per_assignment_extra_info paei
        ,per_all_assignments_f paa
  WHERE  paei.information_type = 'PER_IN_TAX_EXEMPTION_DF'
    AND  paei.aei_information_category = 'PER_IN_TAX_EXEMPTION_DF'
    AND  paei.assignment_id = paa.assignment_id
    AND  paa.person_id = TO_NUMBER(p_person_id)
    AND  paei.aei_information1 = TO_CHAR((TO_NUMBER(SUBSTR(p_assess_year,1,4)) - 1)||'-'||SUBSTR(p_assess_year,1,4))
    AND  fnd_date.CHARDATE_TO_DATE(p_date) BETWEEN paa.effective_start_date AND paa.effective_end_date
    AND  ROWNUM = 1;


l_remarks VARCHAR2(150);
 l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'get_tde_remarks';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_person_id',p_person_id);
       pay_in_utils.trace('p_assess_year',p_assess_year);
       pay_in_utils.trace('p_date',p_date);
       pay_in_utils.trace('**************************************************','********************');
  END IF;

  OPEN c_remarks;
  FETCH c_remarks INTO l_remarks;
  IF c_remarks%NOTFOUND THEN
    CLOSE c_remarks;
    RETURN ' ';
  END IF;
  CLOSE c_remarks;

  IF g_debug THEN
     pay_in_utils.trace('l_remarks',l_remarks);
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN l_remarks;

END get_tde_remarks;

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
 SELECT org_information3
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
FUNCTION get_location_details ( p_location_id  IN   hr_locations.location_id%TYPE)
RETURN VARCHAR2
IS

   CURSOR csr_add IS
      SELECT address_line_1,
             NVL(address_line_2,' '),
             NVL(address_line_3,' '),
	     NVL(loc_information14,' '),
             loc_information15,
             NVL(hr_general.decode_lookup('IN_STATE_CODES',loc_information16),' '),
             NVL(postal_code,' ')
        FROM hr_locations
       WHERE location_id = p_location_id;

   l_add_1    hr_locations.address_line_1%TYPE;
   l_add_2    hr_locations.address_line_2%TYPE;
   l_add_3    hr_locations.address_line_3%TYPE;
   l_add_4    hr_locations.loc_information14%TYPE;
   l_add_5    hr_locations.loc_information15%TYPE;
   l_state    hr_lookups.meaning%TYPE;
   l_pin      hr_locations.postal_code%TYPE;
   p_address  VARCHAR2(200);
  --
   l_procedure varchar2(100);

   BEGIN
   g_debug          := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_location_details';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
       pay_in_utils.trace('p_location_id',p_location_id);
   END IF;

   OPEN csr_add;
   FETCH csr_add INTO l_add_1, l_add_2, l_add_3, l_add_4, l_add_5, l_state, l_pin;
   IF csr_add%NOTFOUND THEN
      CLOSE csr_add;
      RETURN RPAD(' ',133,' ');
   END IF;
   CLOSE csr_add;

   p_address := '';

   IF LENGTH(l_add_1) <=25 THEN
      p_address := p_address||RPAD(l_add_1,25,' ');
   ELSE
      p_address := p_address||SUBSTR(l_add_1,1,25);
      l_add_2 := SUBSTR(l_add_1,26)||', '||l_add_2;
   END IF;

   IF LENGTH(l_add_2) <=25 THEN
      p_address := p_address||RPAD(l_add_2,25,' ');
   ELSE
      p_address := p_address||SUBSTR(l_add_2,1,25);
      l_add_3 := SUBSTR(l_add_2,26)||', '||l_add_3;
   END IF;

   IF LENGTH(l_add_3) <=25 THEN
      p_address := p_address||RPAD(l_add_3,25,' ');
   ELSE
      p_address := p_address||SUBSTR(l_add_3,1,25);
      l_add_4 := SUBSTR(l_add_3,26)||', '||l_add_4;
   END IF;

   IF LENGTH(l_add_4) <=25 THEN
      p_address := p_address||RPAD(l_add_4,25,' ');
   ELSE
      p_address := p_address||SUBSTR(l_add_4,1,25);
      l_add_5 := SUBSTR(l_add_4,26)||', '||l_add_5;
   END IF;

   IF LENGTH(l_add_5) <=25 THEN
      p_address := p_address||RPAD(l_add_5,25,' ');
   ELSE
      p_address := p_address||SUBSTR(l_add_5,1,25);
   END IF;

   p_address := p_address||l_state||l_pin;


  IF g_debug THEN
     pay_in_utils.trace('p_address',p_address);
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);


  RETURN p_address;


END get_location_details;

END pay_in_eoy_er_returns;

/

--------------------------------------------------------
--  DDL for Package Body PAY_IN_24QC_ER_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_24QC_ER_RETURNS" AS
/* $Header: pyin24cr.pkb 120.3.12010000.1 2008/07/27 22:52:05 appldev ship $ */

  g_debug    BOOLEAN;
  g_package  CONSTANT VARCHAR2(40) := 'pay_in_24qc_er_returns.';

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FILE_SEQ_NO                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the file sequence no of the   --
--                  Correction Report                                   --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_quarter             VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_file_seq_no (p_gre_org_id  IN VARCHAR2
                         ,p_assess_year IN VARCHAR2
                         ,p_quarter     IN VARCHAR2
                         )
RETURN VARCHAR2 IS

CURSOR csr_file_seq_no(p_gre_org_id  VARCHAR2
                      ,p_assess_year VARCHAR2
                      ,p_quarter     VARCHAR2)
IS
 SELECT TO_CHAR(COUNT(*) + 1)
   FROM hr_organization_information
  WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
    AND org_information1 = p_assess_year
    AND org_information2 = p_quarter
    AND org_information6 = 'C'
    AND organization_id  = p_gre_org_id;

 l_file_seq_no VARCHAR2(10);
 l_proc        VARCHAR2(100);
 l_message     VARCHAR2(240);
BEGIN

      l_proc := g_package||'get_file_seq_no';
      g_debug := hr_utility.debug_enabled;
      pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
         pay_in_utils.trace('p_assess_year',p_assess_year);
         pay_in_utils.trace('p_quarter',p_quarter);
         pay_in_utils.trace('**************************************************','********************');
      END IF;

      OPEN csr_file_seq_no(p_gre_org_id,p_assess_year,p_quarter);
      FETCH csr_file_seq_no INTO l_file_seq_no;
      CLOSE csr_file_seq_no;

      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('l_file_seq_no',l_file_seq_no);
         pay_in_utils.trace('**************************************************','********************');
      END IF;

      pay_in_utils.set_location(g_debug, 'Leaving: ' || l_proc, 10);

  RETURN l_file_seq_no;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END get_file_seq_no;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHALLAN_REC_COUNT_24QC                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of challan   --
--                  records for a particular correction type            --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--                  p_correction_type     VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION challan_rec_count_24qc  (p_gre_org_id      IN VARCHAR2
                                 ,p_assess_period   IN VARCHAR2
                                 ,p_max_action_id   IN VARCHAR2
                                 ,p_correction_type IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT  COUNT(DISTINCT action_information1)
  FROM   pay_action_information pai
 WHERE   action_information_category = 'IN_24QC_CHALLAN'
   AND   action_context_type = 'PA'
   AND   action_information3 = p_gre_org_id
   AND   action_information2 = p_assess_period
   AND   pai.action_context_id= p_max_action_id
   AND   fnd_date.canonical_to_date(pai.action_information5) <= fnd_date.CHARDATE_TO_DATE(SYSDATE)
   AND   action_information29 LIKE  '%' || p_correction_type || '%';

 l_count    NUMBER;
 l_proc     VARCHAR2(100);
 l_message  VARCHAR2(240);

BEGIN

  l_proc := g_package||'challan_rec_count_24qc';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);
  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
     pay_in_utils.trace('p_assess_period',p_assess_period);
     pay_in_utils.trace('p_max_action_id',p_max_action_id);
     pay_in_utils.trace('p_correction_type',p_correction_type);
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
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_count',l_count);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  RETURN TO_CHAR(l_count);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END challan_rec_count_24qc;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_RRR_NO                                          --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Original/Last             --
--                  24Q Receipt Number                                  --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_quarter             VARCHAR2                      --
--                  p_correction_type     VARCHAR2                      --
--                  p_receipt             VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_rrr_no (p_gre_org_id      IN VARCHAR2
                    ,p_assess_year     IN VARCHAR2
                    ,p_quarter         IN VARCHAR2
                    ,p_receipt         IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR csr_orig_rrr_no(p_gre_org_id      IN VARCHAR2
                      ,p_assess_year     IN VARCHAR2
                      ,p_quarter         IN VARCHAR2)
IS
 SELECT org_information4
       ,org_information3
   FROM hr_organization_information
  WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
    AND org_information1 = p_assess_year
    AND org_information2 = p_quarter
    AND org_information6 ='O'
    AND organization_id = p_gre_org_id
    ORDER BY org_information3 ASC;

CURSOR csr_prev_rrr_no(p_gre_org_id      IN VARCHAR2
                      ,p_assess_year     IN VARCHAR2
                      ,p_quarter         IN VARCHAR2)
IS
 SELECT org_information4
       ,org_information3
   FROM hr_organization_information
  WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
    AND org_information1 = p_assess_year
    AND org_information2 = p_quarter
    AND organization_id = p_gre_org_id
    ORDER BY org_information3 DESC;

 l_rrr_no VARCHAR2(15);
 l_dummy  VARCHAR2(15);
 l_proc   VARCHAR2(100);
 l_message VARCHAR2(240);

BEGIN

  l_proc := g_package||'get_rrr_no';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
     pay_in_utils.trace('p_assess_year',p_assess_year);
     pay_in_utils.trace('p_quarter',p_quarter);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  IF p_receipt = 'Original' THEN
      OPEN csr_orig_rrr_no(p_gre_org_id,p_assess_year,p_quarter);
      FETCH csr_orig_rrr_no INTO l_rrr_no, l_dummy;
      CLOSE csr_orig_rrr_no;
  END IF;

  IF p_receipt = 'Previous' THEN
      OPEN csr_prev_rrr_no(p_gre_org_id,p_assess_year,p_quarter);
      FETCH csr_prev_rrr_no INTO l_rrr_no, l_dummy;
      CLOSE csr_prev_rrr_no;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_rrr_no',l_rrr_no);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
  RETURN NVL(l_rrr_no,'Not Found');

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END get_rrr_no;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GROSS_TOT_TDS_CHALLAN_24Q                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Gross Total of TDS        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--                  p_correction_type     VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION gross_tot_tds_challan_24q(p_gre_org_id      IN VARCHAR2
                                  ,p_assess_period   IN VARCHAR2
                                  ,p_max_action_id   IN VARCHAR2
                                  ,p_correction_type IN VARCHAR2)
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
        WHERE action_information_category = 'IN_24QC_CHALLAN'
          AND action_context_type   = 'PA'
          AND action_information3   = p_gre_org_id
          AND action_information2   = p_assess_period
          AND pai.action_context_id = p_max_action_id
          AND NVL(pai.action_information18, 'NC') <> 'NC'
          AND pai.action_information29 like  '%'||p_correction_type||'%'
          AND fnd_date.canonical_to_date(pai.action_information5) <= fnd_date.CHARDATE_TO_DATE(SYSDATE)
          );

l_tds      NUMBER := 0;
l_sur      NUMBER := 0;
l_ec       NUMBER := 0;
l_intr     NUMBER := 0;
l_oth      NUMBER := 0;
l_total    VARCHAR2(20);
l_proc     VARCHAR2(100);
l_message  VARCHAR2(240);

BEGIN

  l_proc := g_package||'gross_tot_tds_challan_24q';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
     pay_in_utils.trace('p_assess_period',p_assess_period);
     pay_in_utils.trace('p_max_action_id',p_max_action_id);
     pay_in_utils.trace('p_correction_type',p_correction_type);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  OPEN c_challan_tax_tot;
  FETCH c_challan_tax_tot INTO l_tds, l_sur, l_ec, l_intr, l_oth;
  CLOSE c_challan_tax_tot;

  l_total := TO_CHAR(NVL(ROUND((l_tds + l_sur + l_ec + l_intr + l_oth), 0), 0))||'.00';

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_total',l_total);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  RETURN SUBSTR(l_total,1,15);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END gross_tot_tds_challan_24q;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PREV_NIL_CHALLAN_IND                            --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the last NIL Challan Indicator--
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_assess_period       VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--                  p_nil_challan         VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_prev_nil_challan_ind  (p_gre_org_id    IN VARCHAR2
                                   ,p_assess_period IN VARCHAR2
                                   ,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_nil_challan
IS
 SELECT  action_information25
  FROM   pay_action_information pai
 WHERE   action_information_category = 'IN_24QC_ORG'
   AND   action_context_type = 'PA'
   AND   pai.action_information1 = p_gre_org_id
   AND   pai.action_information3 = p_assess_period
   AND   pai.action_context_id   = p_max_action_id;

l_nil_challan_ind VARCHAR2(10);
l_proc            VARCHAR2(100);
l_message         VARCHAR2(240);

BEGIN

  l_proc := g_package||'get_prev_nil_challan_ind';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
     pay_in_utils.trace('p_assess_period',p_assess_period);
     pay_in_utils.trace('p_max_action_id',p_max_action_id);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  OPEN c_nil_challan;
  FETCH c_nil_challan INTO l_nil_challan_ind;
  CLOSE c_nil_challan;

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_nil_challan_ind',l_nil_challan_ind);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  RETURN l_nil_challan_ind;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END get_prev_nil_challan_ind;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DEDUCTEE_REC_COUNT_24Q                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the count of deductee records --
--                  for a challan in a correction archival              --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--                  p_challan             VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION deductee_rec_count_24q (p_gre_org_id    IN VARCHAR2
                                ,p_max_action_id IN VARCHAR2
                                ,p_challan       IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(DISTINCT source_id)
   FROM  pay_action_information pai
  WHERE  action_information_category = 'IN_24QC_DEDUCTEE'
    AND  action_context_type = 'AAP'
    AND  action_information3 =  p_gre_org_id
    AND  EXISTS (SELECT 1
                 FROM   pay_assignment_actions paa
                 WHERE  paa.payroll_action_id = p_max_action_id
                 AND    paa.assignment_action_id = pai.action_context_id)
   AND pai.action_information1 = p_challan;

l_count        NUMBER;
l_proc         VARCHAR2(100);
l_message      VARCHAR2(240);

BEGIN

  l_proc := g_package||'deductee_rec_count_24q';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

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
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_count',l_count);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  RETURN TO_CHAR(l_count);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END deductee_rec_count_24q;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_24QC_TAX_VALUES                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Tax Values String         --
-- Parameters     :                                                     --
--             IN : p_challan_number       VARCHAR2                     --
--                  p_gre_org_id          VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_24QC_tax_values(
                            p_challan_number IN VARCHAR2
                           ,p_gre_org_id     IN VARCHAR2
                           ,p_max_action_id  IN VARCHAR2
                            )
RETURN VARCHAR2 IS

CURSOR c_form24QC_tax_values IS
  SELECT   SUM(DECODE(action_information15, 'D', -1 * NVL(action_information16, 0)
                                               , NVL(action_information16, 0)))
         - SUM(DECODE(action_information15, 'U', NVL(action_information24, 0)
                                               , 0))            tax_deposited
          ,SUM(DECODE(action_information15, 'D', -1 * NVL(action_information6, 0)
                                               , NVL(action_information6, 0)))
         - SUM(DECODE(action_information15, 'U', NVL(action_information21, 0)
                                               , 0))             tds
          ,SUM(DECODE(action_information15, 'D', -1 * NVL(action_information7, 0)
                                               , NVL(action_information7, 0)))
         - SUM(DECODE(action_information15, 'U', NVL(action_information22, 0)
                                               , 0))             surcharge
          ,SUM(DECODE(action_information15, 'D', -1 * NVL(action_information8, 0)
                                               , NVL(action_information8, 0)))
         - SUM(DECODE(action_information15, 'U', NVL(action_information23, 0)
                                               , 0))             cess
   FROM (
          SELECT DISTINCT source_id
                ,pay_in_24qc_er_returns.remove_curr_format(action_information15) action_information15
                ,pay_in_24qc_er_returns.remove_curr_format(action_information16) action_information16
                ,pay_in_24qc_er_returns.remove_curr_format(action_information24) action_information24
                ,pay_in_24qc_er_returns.remove_curr_format(action_information6)  action_information6
                ,pay_in_24qc_er_returns.remove_curr_format(action_information21) action_information21
                ,pay_in_24qc_er_returns.remove_curr_format(action_information7)  action_information7
                ,pay_in_24qc_er_returns.remove_curr_format(action_information22) action_information22
                ,pay_in_24qc_er_returns.remove_curr_format(action_information8)  action_information8
                ,pay_in_24qc_er_returns.remove_curr_format(action_information23) action_information23
           FROM  pay_action_information
          WHERE  action_information_category ='IN_24QC_DEDUCTEE'
            AND  action_context_type  = 'AAP'
            AND  action_information3  = p_gre_org_id
            AND  action_information1  = p_challan_number
            AND  INSTR(NVL(action_information19,'0'),'C5') = 0
            AND  EXISTS ( SELECT 1
                          FROM   pay_assignment_actions paa
                          WHERE  paa.payroll_action_id = p_max_action_id
                          AND    paa.assignment_action_id = action_context_id));

    l_proc    VARCHAR2(100);
    l_message VARCHAR2(240);
    l_value29 VARCHAR2(20);
    l_value30 VARCHAR2(20);
    l_value31 VARCHAR2(20);
    l_value32 VARCHAR2(20);
    l_value33 VARCHAR2(20);
    l_total_tax_values VARCHAR2(100);

BEGIN

  l_proc := g_package||'get_24qc_tax_values';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
     pay_in_utils.trace('p_max_action_id',p_max_action_id);
     pay_in_utils.trace('p_challan',p_challan_number);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

    l_value29 := 0;
    l_value30 := 0;
    l_value31 := 0;
    l_value32 := 0;
    l_value33 := 0;

   OPEN c_form24QC_tax_values;
   FETCH c_form24QC_tax_values INTO l_value29, l_value30, l_value31, l_value32;
   CLOSE c_form24QC_tax_values;

     l_value33 := TO_NUMBER(l_value30) + TO_NUMBER(l_value31) + TO_NUMBER(l_value32);

     l_value29 := pay_in_24q_er_returns.get_format_value(l_value29);
     l_value30 := pay_in_24q_er_returns.get_format_value(l_value30);
     l_value31 := pay_in_24q_er_returns.get_format_value(l_value31);
     l_value32 := pay_in_24q_er_returns.get_format_value(l_value32);
     l_value33 := pay_in_24q_er_returns.get_format_value(l_value33);

     l_total_tax_values := l_value29||'^'||l_value30||'^'||l_value31||'^'||l_value32||'^'||l_value33||'^';

     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_total_tax_values',l_total_tax_values);
        pay_in_utils.trace('**************************************************','********************');
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

     RETURN l_total_tax_values;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END get_24qc_tax_values;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ARCHIVE_PAY_ACTION                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the latest archival payroll   --
--                  action id for a period                              --
-- Parameters     :                                                     --
--             IN : p_gre_org_id          VARCHAR2                      --
--                  p_period              VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_archive_pay_action (p_gre_org_id    IN VARCHAR2
                                ,p_period        IN VARCHAR2)
RETURN NUMBER IS

CURSOR csr_arch_action_id
IS
SELECT MAX(action_context_id)
  FROM pay_action_information
 WHERE action_information1 = p_gre_org_id
   AND action_information3 = p_period
   AND action_context_type = 'PA'
   AND action_information_category = 'IN_24QC_ORG';

l_arch_action_id NUMBER;
l_proc           VARCHAR2(100);
l_message        VARCHAR2(240);

BEGIN

  l_proc := g_package||'get_archive_pay_action';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_gre_org_id',p_gre_org_id);
     pay_in_utils.trace('p_period',p_period);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  OPEN csr_arch_action_id;
  FETCH csr_arch_action_id INTO l_arch_action_id;
  IF csr_arch_action_id%NOTFOUND THEN
     CLOSE csr_arch_action_id;
     RETURN 0;
  END IF;
  CLOSE csr_arch_action_id;

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_arch_action_id',l_arch_action_id);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  RETURN l_arch_action_id;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END get_archive_pay_action;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : REMOVE_CURR_FORMAT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the latest archival payroll   --
--                  action id for a period                              --
-- Parameters     :                                                     --
--             IN : p_value               VARCHAR2                      --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION remove_curr_format (p_value    IN VARCHAR2)
RETURN VARCHAR2 IS
l_return_value VARCHAR2(240);
l_proc         VARCHAR2(100);
l_message      VARCHAR2(240);
BEGIN

  l_proc := g_package||'remove_curr_format';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_proc, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_value',p_value);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  l_return_value := REPLACE(REPLACE(NVL(p_value,'0'), ',', ''), '+', '');

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_return_value',l_return_value);
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 30);

  RETURN l_return_value;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);

END remove_curr_format;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : TOTAL_GROSS_TOT_INCOME                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the total of Gross Total      --
--                  Income as per salary details annexure               --
-- Parameters     :                                                     --
--             IN : p_gre_org_id            VARCHAR2                    --
--                  p_assess_period         VARCHAR2                    --
--                  p_correction_type       VARCHAR2                    --
--                  p_max_action_id         VARCHAR2                    --
--------------------------------------------------------------------------
FUNCTION total_gross_tot_income (p_gre_org_id IN VARCHAR2
                                ,p_assess_period IN VARCHAR2
                                ,p_correction_type IN VARCHAR2
				,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR csr_income_details(p_balance VARCHAR2,p_action_context_id NUMBER,p_source_id IN NUMBER)
IS
 SELECT NVL(SUM(action_information2),0)
   FROM pay_action_information
  WHERE action_information_category = 'IN_24QC_SALARY'
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
        WHERE paa.payroll_action_id = p_max_action_id
        AND  pai.action_context_id = paa.assignment_action_id
        AND  pai.action_information_category = 'IN_24QC_PERSON'
	AND pai.action_information3         = p_gre_org_id
        AND pai.action_information2         = p_assess_period
        AND pai.action_information1         = asg.person_id
        AND asg.business_group_id           = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
        AND asg.assignment_id               = pai.assignment_id
        AND pai.action_context_type         = 'AAP'
        AND pai.action_information11 = 'C4'
   GROUP BY pai.action_information1,pai.action_information9,source_id;


l_total_gross    NUMBER:=0;
l_value1  NUMBER:=0;
l_value2  NUMBER:=0;
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
	pay_in_utils.trace('p_correction_type',p_correction_type);
	pay_in_utils.trace('p_max_action_id',p_max_action_id);
	pay_in_utils.trace('**************************************************','********************');
 END IF;

 IF (p_correction_type <> 'C4') THEN
     IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('l_total_gross','^');
         pay_in_utils.trace('**************************************************','********************');
     END IF;
     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
     RETURN '^';
 ELSE

  FOR i IN  csr_get_max_cont_id
  LOOP
      OPEN csr_income_details('F16 Gross Total Income',i.action_cont_id,i.sour_id);
      FETCH csr_income_details INTO l_value1;
      CLOSE csr_income_details;

      OPEN csr_income_details('Prev F16 Gross Total Income',i.action_cont_id,i.sour_id);
      FETCH csr_income_details INTO l_value2;
      CLOSE csr_income_details;

      l_total_gross:= l_total_gross + l_value1+l_value2;
   END LOOP;

  l_total_value :=pay_in_24q_er_returns.get_format_value(l_total_gross);
 END IF;

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('l_total_value',SUBSTR(l_total_value,1,15)||'^');
       pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

  RETURN SUBSTR(l_total_value,1,15)||'^';

END total_gross_tot_income;


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
--                  p_correction_type       VARCHAR2                    --
--                  p_max_action_id         VARCHAR2                    --
--------------------------------------------------------------------------
FUNCTION salary_rec_count (p_gre_org_id  IN VARCHAR2
                          ,p_assess_period IN VARCHAR2
                          ,p_correction_type IN VARCHAR2
			  ,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_count
IS
 SELECT COUNT(*)
   FROM  pay_action_information
  WHERE  action_information_category = 'IN_24QC_PERSON'
    AND  action_context_type = 'AAP'
    AND  action_information2 =  p_assess_period
    AND  action_information3 =  p_gre_org_id
    AND  action_information11 = p_correction_type
    AND  action_context_id  IN (SELECT MAX(pai.action_context_id)
                                 FROM  pay_action_information pai
                                      ,pay_assignment_actions paa
                                      ,per_assignments_f asg
                                 WHERE paa.payroll_action_id = p_max_action_id
                                  AND  pai.action_context_id = paa.assignment_action_id
                                  AND  pai.action_information_category = 'IN_24QC_PERSON'
				  AND  pai.action_context_type = 'AAP'
                                  AND  pai.action_information1 = asg.person_id
                                  AND  pai.assignment_id       = asg.assignment_id
                                  AND  asg.business_group_id   = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                  AND  pai.action_information2 = p_assess_period
                                  AND  pai.action_information3 = p_gre_org_id
                                  AND  pai.action_information11 = p_correction_type
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
	pay_in_utils.trace('p_correction_type',p_correction_type);
	pay_in_utils.trace('p_max_action_id',p_max_action_id);
	pay_in_utils.trace('**************************************************','********************');
END IF;

IF(p_correction_type NOT IN ('C4','C5'))THEN
     IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('l_count','^');
         pay_in_utils.trace('**************************************************','********************');
     END IF;
     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
     RETURN '^';
ELSE
 OPEN c_count;
  FETCH c_count INTO l_count;
  IF c_count%NOTFOUND THEN
     CLOSE c_count;
     IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('l_count','0^');
         pay_in_utils.trace('**************************************************','********************');
     END IF;
     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
     RETURN '0^';
  END IF;
 CLOSE c_count;


 IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_count',TO_CHAR(l_count)||'^');
     pay_in_utils.trace('**************************************************','********************');
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN TO_CHAR(l_count)||'^';
END IF;

END salary_rec_count;


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
WHERE  action_information_category = 'IN_24QC_VIA'
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
     IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('l_count','0');
         pay_in_utils.trace('**************************************************','********************');
     END IF;
     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
     RETURN '0';
  END IF;
 CLOSE c_count;


 IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('l_count',TO_CHAR(l_count));
         pay_in_utils.trace('**************************************************','********************');
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN TO_CHAR(l_count);

END chapter_VIA_rec_count;


END pay_in_24qc_er_returns;

/

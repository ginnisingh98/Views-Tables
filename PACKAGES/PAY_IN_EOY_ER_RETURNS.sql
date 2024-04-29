--------------------------------------------------------
--  DDL for Package PAY_IN_EOY_ER_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_EOY_ER_RETURNS" AUTHID CURRENT_USER AS
/* $Header: pyinerit.pkh 120.3 2006/04/17 04:01 vgsriniv noship $ */


level_cnt NUMBER;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
FUNCTION gross_tot_tds_challan (p_gre_org_id  IN VARCHAR2
			       ,p_assess_year IN VARCHAR2)
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
FUNCTION get_location_details (p_location_id  IN   hr_locations.location_id%TYPE)
RETURN VARCHAR2;


/*  FILE HEADER RECORD */
CURSOR  c_f24_file_header IS
SELECT  DISTINCT 'UPLOAD_TYPE=P'
       , pay_magtape_generic.get_parameter_value('UPLOAD_TYPE_PARAM')
       ,'TAN_OF_DED=P'
       , LPAD(NVL(pai.action_information4, ' '),10,' ')
       , 'MAX_ACTION_CONTEXT_ID=P'
       , pai.action_context_id
       , 'SUBMIT_DATE=P'
       ,  TO_CHAR (SYSDATE,'DDMMYYYY')
  FROM   pay_action_information pai
       , pay_payroll_actions ppa
 WHERE   pai.action_information_category = 'IN_EOY_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
   AND   pai.action_information3 = pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
   AND   ppa.action_type='X'
   AND   ppa.action_status = 'C'
   AND   ppa.report_type='IN_EOY_ARCHIVE'
   AND   ppa.report_qualifier = 'IN'
   AND   ppa.payroll_action_id = pai.action_context_id
   AND   pai.action_context_id = ( SELECT MAX(action_context_id)
                                     FROM pay_action_information
				    WHERE action_information1 = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
				      AND action_information3 = pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
				      AND action_context_type = 'PA'
				      AND action_information_category = 'IN_EOY_ORG');

/*BATCH HEADER RECORD*/
CURSOR c_f24_batch_header IS
SELECT   'TOT_CHALLAN_REC=P'
      ,  pay_in_eoy_er_returns.challan_rec_count(pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM'),pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'))
      ,  'TOT_DEDUCTEE_REC=P'
      ,  pay_in_eoy_er_returns.deductee_rec_count(pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM'),pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'))
      ,  'TOT_PERQ_REC=P'
      ,  pay_in_eoy_er_returns.perq_rec_count(pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM'),pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'))
      ,  'TAN_OF_DED=P'
      ,  LPAD(NVL(pai.action_information4,' '),10, ' ')
      , 'PAN_OF_TAN=P'
      ,  LPAD(NVL(pai.action_information2,' '),10,' ')
      , 'ASSESS_YEAR=P'
      , SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),1,4)||SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),8,2)
      , 'FIN_YEAR=P'
      , SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),1,4)-1||LPAD (SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),8,2)-1,2,'0')
      , 'LEGAL_NAME=P'
      ,  NVL(pai.action_information8,' ')
      , 'EMPLOYER_CLASS=P'
      ,  pay_in_eoy_er_returns.get_emplr_class(pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM'))
      , 'EMPLOYER_ADD1=P'
      , SUBSTR(pay_in_eoy_er_returns.get_location_details(pai.action_information7),1,75)
      , 'EMPLOYER_ADD2=P'
      , SUBSTR(pay_in_eoy_er_returns.get_location_details(pai.action_information7),76)
      , 'EMP_ADD_CHG=P'
      , pay_magtape_generic.get_parameter_value('EMP_ADD_CHG')
      , 'REP_NAME=P'
      , NVL(pai.action_information11,' ')
      , 'REP_DESIG=P'
      , NVL(pai.action_information13,' ')
      , 'REP_ADD1=P'
      , SUBSTR(pay_in_eoy_er_returns.get_location_details(pai.action_information16),1,75)
      , 'REP_ADD2=P'
      , SUBSTR(pay_in_eoy_er_returns.get_location_details(pai.action_information16),76)
      , 'REP_ADD_CHG=P'
      , pay_magtape_generic.get_parameter_value('REP_ADD_CHG')
      , 'GROSS_TDS_CHALLAN=P'
      ,  pay_in_eoy_er_returns.gross_tot_tds_challan(pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM'),pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'))
      , 'GROSS_TDS_DED=P'
      ,  pay_in_eoy_er_returns.gross_tot_tds_deductee(pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM'),pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'))
      , 'TAN_ACK_NUM=P'
      ,  NVL(pai.action_information5,'00000000000000')
      , 'PRN=P'
      ,  pay_magtape_generic.get_parameter_value('PRN')
  FROM   pay_action_information pai
 WHERE   pai.action_information_category = 'IN_EOY_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
   AND   pai.action_information3 = pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
   AND   pai.action_context_id = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
   AND   ROWNUM = 1;


/* CHALLAN DETAIL RECORD */
CURSOR c_f24_challan_det_rec IS
SELECT   'TDS_DEP=P'
      ,   (NVL(it_ch.org_information4,'0')||'00')
      ,  'SURCHARGE=P'
      ,   (NVL(it_ch.org_information7,'0')||'00')
      ,  'EDU_CESS=P'
      ,   (NVL(it_ch.org_information8,'0')||'00')
      ,  'INTEREST=P'
      ,   (NVL(it_ch.org_information9,'0')||'00')
      ,  'OTHERS=P'
      ,   (NVL(it_ch.org_information10,'0')||'00')
      ,  'CHQ_DD_NUM=P'
      ,   it_ch.org_information11
      ,  'BOOK_ENTRY=P'
      ,   it_ch.org_information12
      ,  'CHALLAN_NUM=P'
      ,  it_ch.org_information3
      ,  'CHALLAN_DATE=P'
      ,  TO_CHAR(fnd_date.canonical_to_date(it_ch.org_information2),'DDMMYYYY')
      ,  'BANK_BRANCH_CODE=P'
      ,  hr_general.decode_lookup('IN_BANK_BRANCH_CODES',ch_b.org_information4)
      ,  fnd_date.canonical_to_date(it_ch.org_information2)
  FROM   hr_organization_information ch_b
       , hr_organization_information it_ch
 WHERE   it_ch.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
   AND   ch_b.org_information_context = 'PER_IN_CHALLAN_BANK'
   AND   it_ch.organization_id = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
   AND   it_ch.org_information1 = TO_CHAR((TO_NUMBER(SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),1,4)) - 1)||'-'||SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),1,4))
   AND   it_ch.organization_id = ch_b.organization_id
   AND   TO_NUMBER(it_ch.org_information5) = ch_b.org_information_id
UNION
SELECT 'TDS_DEP=P'
      ,  '0'
      ,  'SURCHARGE=P'
      ,  '0'
      ,  'EDU_CESS=P'
      ,  '0'
      ,  'INTEREST=P'
      ,  '0'
      ,  'OTHERS=P'
      ,  '0'
      ,  'CHQ_DD_NUM=P'
      ,  '0'
      ,  'BOOK_ENTRY=P'
      ,  ' '
      ,  'CHALLAN_NUM=P'
      ,  ' '
      ,  'CHALLAN_DATE=P'
      ,  '00011900'
      ,  'BANK_BRANCH_CODE=P'
      ,  ' '
      , SYSDATE
 FROM DUAL
WHERE NOT EXISTS (
                     SELECT  'EXISTS'
                       FROM  hr_organization_information ch_b
       			    ,hr_organization_information it_ch
 		      WHERE  it_ch.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
   			AND  ch_b.org_information_context = 'PER_IN_CHALLAN_BANK'
   			AND  it_ch.organization_id = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
   			AND  it_ch.org_information1 = TO_CHAR((TO_NUMBER(SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),1,4)) - 1)||'-'||SUBSTR(pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),1,4))
   			AND  it_ch.organization_id = ch_b.organization_id
   			AND  TO_NUMBER(it_ch.org_information5) = ch_b.org_information_id
                   )
   ORDER BY 21;


  /* DEDUCTEE DETAIL RECORD */

CURSOR c_f24_ded_det_rec IS
SELECT  'EMP_PERSON_ID=P'
      , action_information13
      , 'EMP_PAN=P'
      , NVL(DECODE (action_information4,'Y','APPLIEDFOR','N',' ',action_information4),' ')
      , 'EMP_FULL_NAME=P'
      , SUBSTR(action_information6||action_information5,1,80)
      , 'EMP_START_DATE=P'
      , TO_CHAR(fnd_date.CHARDATE_TO_DATE(action_information17),'DDMMYYYY')
      , 'EMP_END_DATE=P'
      , TO_CHAR(fnd_date.CHARDATE_TO_DATE(action_information18),'DDMMYYYY')
      , 'F16_SEC17_SAL=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Salary Under Section 17',action_context_id,source_id,2)
      , 'F16_PROFIT_LIEU=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Profit in lieu of Salary',action_context_id,source_id,2)
      , 'EXCESS_INTEREST=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','Excess Interest Amount',action_context_id,source_id,2)
      , 'EXCESS_PF=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','Excess PF Amount',action_context_id,source_id,2)
      , 'F16_ALW_EXEM=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Allowances Exempt',action_context_id,source_id,2)
      , 'F16_DEC_SEC16=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Deductions under Sec 16',action_context_id,source_id,2)
      , 'F16_INC_HEAD_SAL=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Income Chargeable Under head Salaries',action_context_id,source_id,2)
      , 'F16_OTHER_INC=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Other Income',action_context_id,source_id,2)
      , 'F16_GROSS_TOT_INC=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Gross Total Income',action_context_id,source_id,2)
      , 'F16_TOT_INC=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Total Income',action_context_id,source_id,2)
      , 'F16_TAX_ON_TOT_INC=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Tax on Total Income',action_context_id,source_id,2)
      , 'F16_TOTAL_TAX_PAY=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Total Tax payable',action_context_id,source_id,2)
      , 'F16_RELIEF_89=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Relief under Sec 89',action_context_id,source_id,2)
      , 'F16_IT_TD=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Income Tax till Date',action_context_id,source_id,2)
      , 'F16_SUR_TD=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Surcharge till Date',action_context_id,source_id,2)
      , 'F16_EDUCESS_TD=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Education Cess till Date',action_context_id,source_id,2)
      , 'F16_SURCHARGE=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Surcharge',action_context_id,source_id,2)
      , 'F16_EDU_CESS=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Education Cess',action_context_id,source_id,2)
      , 'F16_BALANCE_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Balance Tax',action_context_id,source_id,2)
      , 'F16_TAX_REFUND=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','F16 Tax Refundable',action_context_id,source_id,2)
      , 'F16_DED_SEC_80G=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_VIA','F16 Deductions Sec 80G',action_context_id,source_id,2)
      , 'F16_DED_SEC_80GG=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_VIA','F16 Deductions Sec 80GG',action_context_id,source_id,2)
      , 'F16_TOT_CHAP_VIA=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_VIA','F16 Total Chapter VI A Deductions',action_context_id,source_id,2)
      , 'TAXABLE_ALW=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ALLOW','Taxable Allowances',action_context_id,source_id,2)
      , 'TAXABLE_PERQ=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Taxable Perquisites',action_context_id,source_id,2)
      , 'REMARKS=P'
      , pay_in_eoy_er_returns.get_tde_remarks(action_information13,pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM'),action_information18)
      , 'TAXABLE_HRA=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ALLOW','House Rent Allowance',action_context_id,source_id,5)
 FROM   pay_action_information
WHERE  action_information_category = 'IN_EOY_PERSON'
  AND  action_context_type = 'AAP'
  AND  action_information2 =  pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
  AND  action_information3 =  pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
  AND  action_context_id  IN ( SELECT  MAX(action_context_id)
                                 FROM  pay_action_information
				      ,pay_assignment_actions
                                WHERE  action_information_category = 'IN_EOY_PERSON'
				  AND  action_context_type = 'AAP'
                                  AND  action_information2 = pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
                                  AND  action_information3 = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
				  AND  source_id = assignment_action_id
                             GROUP BY  action_information1,action_information17 )
  ORDER BY LENGTH(action_information1),action_information1,source_id;



/* PERQUISITE DETAIL RECORD  */

CURSOR c_f24_perq_det_rec IS
SELECT  'EMP_FULL_NAME=P'
      , SUBSTR(action_information6||action_information5,1,80)
      , 'EMP_PERSON_ID=P'
      , action_information13
      , 'COMP_ACC_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Company Accommodation',action_context_id,source_id,2)
      , 'COMP_ACC_EMP=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Company Accommodation',action_context_id,source_id,3)
      , 'COST_RENT_FUR=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Cost and Rent of Furniture',action_context_id,source_id,2)
      , 'FUR_PERQ=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Furniture Perquisite',action_context_id,source_id,2)
      , 'MONTHLY_FUR_CP=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Monthly Furniture Cost',action_context_id,source_id,2)
      , 'MEDICAL_PERQ=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Medical',action_context_id,source_id,2)
      , 'DOMESTIC_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Domestic Servant',action_context_id,source_id,2)
      , 'GWE_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Gas / Water / Electricity',action_context_id,source_id,2)
      , 'EDU_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Free Education',action_context_id,source_id,2)
      , 'LTC_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Leave Travel Concession',action_context_id,source_id,2)
      , 'SHARE_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Shares',action_context_id,source_id,2)
      , 'LCR_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Loan at Concessional Rate',action_context_id,source_id,2)
      , 'MOV_ASSET_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Company Movable Assets',action_context_id,source_id,2)
      , 'TRAN_ASSET_TAX=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Transfer of Company Assets',action_context_id,source_id,2)
      , 'TOT_TAXABLE_PERQ=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_PERQ','Taxable Perquisites',action_context_id,source_id,2)
      , 'PF_EXCESS_AMT=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','Excess PF Amount',action_context_id,source_id,2)
      , 'PF_EXCESS_INT=P'
      , pay_in_eoy_er_returns.get_eoy_values('IN_EOY_ASG_SAL','Excess Interest Amount',action_context_id,source_id,2)
FROM   pay_action_information
WHERE  action_information_category = 'IN_EOY_PERSON'
  AND  action_context_type = 'AAP'
  AND  action_information2 =  pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
  AND  action_information3 =  pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
  AND  action_context_id  IN ( SELECT  MAX(action_context_id)
                                 FROM  pay_action_information
				      ,pay_assignment_actions
                                WHERE  action_information_category = 'IN_EOY_PERSON'
				  AND  action_context_type = 'AAP'
                                  AND  action_information2 = pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM')
                                  AND  action_information3 = pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM')
				  AND  source_id = assignment_action_id
                             GROUP BY  action_information1,action_information17 )
  ORDER BY LENGTH(action_information1),action_information1,source_id;




END pay_in_eoy_er_returns;

 

/

--------------------------------------------------------
--  DDL for Package PAY_IN_24Q_ER_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_24Q_ER_RETURNS" AUTHID CURRENT_USER AS
/* $Header: pyineqit.pkh 120.18.12010000.6 2009/09/23 09:45:40 mdubasi ship $ */

level_cnt NUMBER;


g_gre_org_id VARCHAR2(15):=pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM');
g_assess_year VARCHAR2(15) :=pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM');
g_quarter VARCHAR2(5):=pay_magtape_generic.get_parameter_value('QUARTER_PARAM');


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHALLAN_REC_COUNT                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Total number of records   --
--                  in the Challan Details of the Magtape               --
-- Parameters     :                                                     --
--             IN : p_gre_org_id            VARCHAR2                    --
--                  p_assess_period         VARCHAR2                    --
--                  p_max_action_id         VARCHAR2                    --
--------------------------------------------------------------------------
FUNCTION challan_rec_count (p_gre_org_id  IN VARCHAR2
                           ,p_assess_period IN VARCHAR2
			   ,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
--                  p_assess_period       VARCHAR2                      --
--                  p_max_action_id       VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION gross_tot_tds_challan (p_gre_org_id  IN VARCHAR2
			       ,p_assess_period IN VARCHAR2
			       ,p_max_action_id IN VARCHAR2)
RETURN VARCHAR2;


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
                                ,p_assess_period IN VARCHAR2)
RETURN VARCHAR2;

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
			,p_segment_num    IN NUMBER
			)
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_24Q_TAX_VALUES                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the Gross Total of TDS        --
--                  deducted as per Deductee details annexure           --
-- Parameters     :                                                     --
--             IN :p_callan_number       VARCHAR2                       --
--                  p_gre_org_id         VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_24Q_tax_values(
                            p_challan_number IN VARCHAR2
			   ,p_gre_org_id IN VARCHAR2
			   ,p_max_action_id IN VARCHAR2
			    )
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
--                  p_challan             VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION deductee_rec_count (p_gre_org_id  IN VARCHAR2
			    ,p_max_action_id IN  VARCHAR2
			    ,p_challan       IN VARCHAR2)
RETURN VARCHAR2;


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
RETURN VARCHAR2;

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
FUNCTION get_location_details ( p_location_id  IN   hr_locations.location_id%TYPE
                               ,p_rep_email_id IN   VARCHAR2
			       ,p_rep_phone        IN   VARCHAR2
                               ,p_segment_num  IN   NUMBER
			       ,p_person_type  IN   VARCHAR2)
RETURN VARCHAR2;


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
RETURN VARCHAR2;


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
RETURN VARCHAR2;


/*  FILE HEADER RECORD */

CURSOR  c_f24q_file_header IS
SELECT  'TAN_OF_DED=P'
       , pai.action_information2
       , 'MAX_ACTION_CONTEXT_ID=P'
       , pai.action_context_id
       , 'SUBMIT_DATE=P'
       ,  TO_CHAR (SYSDATE,'DDMMYYYY')
       , 'NAME_OF_UTILITY=P'
       ,  pay_in_24q_er_returns.get_product_release
  FROM   pay_action_information pai
       , pay_payroll_actions ppa
 WHERE   pai.action_information_category = 'IN_24Q_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = g_gre_org_id
   AND   pai.action_information3 =g_assess_year||g_quarter
   AND   ppa.action_type='X'
   AND   ppa.action_status = 'C'
   AND   ppa.report_type='IN_24Q_ARCHIVE'
   AND   ppa.report_qualifier = 'IN'
   AND   ppa.payroll_action_id = pai.action_context_id
   AND   pai.action_context_id = ( SELECT MAX(action_context_id)
                                     FROM pay_action_information
				    WHERE action_information1 = g_gre_org_id
				      AND action_information3 = g_assess_year||g_quarter
				      AND action_context_type = 'PA'
				      AND action_information_category = 'IN_24Q_ORG')
   AND ROWNUM=1;



 /* BATCH HEADER RECORD*/

CURSOR c_f24q_batch_header IS
SELECT  'TOT_CHALLAN_REC=P'
      ,  pay_in_24q_er_returns.challan_rec_count( g_gre_org_id,
         (g_assess_year||g_quarter),
	  pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      ,  'TAN_OF_DED=P'
      ,  pai.action_information2
      , 'PAN_OF_TAN=P'
      ,  pai.action_information4||'^'
      ,  'ASSESS_YEAR=P'
      ,  SUBSTR(g_assess_year,1,4)||SUBSTR(g_assess_year,8,2)
      ,  'FIN_YEAR=P'
      ,  SUBSTR(g_assess_year,1,4)-1||LPAD(SUBSTR(g_assess_year,8,2)-1,2,'0')
      ,  'PERIOD=P'
      ,  g_quarter
      ,  'LEGAL_NAME=P'
      ,  SUBSTR(pai.action_information5,1,75)
      ,  'EMPLOYER_DIV=P'
      ,  SUBSTR(pai.action_information8,1,75)||'^'
      ,  'EMPLOYER_ADD1=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,1,'EMP')
      ,  'EMPLOYER_ADD2=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,2,'EMP')
      ,  'EMPLOYER_ADD3=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,3,'EMP')
      ,  'EMPLOYER_ADD4=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,4,'EMP')
      ,  'EMPLOYER_ADD5=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,5,'EMP')
      ,  'EMP_ADD_CHG=P'
      ,  pay_magtape_generic.get_parameter_value('EMP_ADD_CHG')
      ,  'EMPLOYER_TYPE=P'
      ,  pay_in_24q_er_returns.get_emplr_class(g_gre_org_id )
      ,  'REP_NAME=P'
      ,  SUBSTR(pai.action_information9,1,75)
      ,  'REP_DESIG=P'
      ,  SUBSTR(pai.action_information11,1,75)||'^'
      ,  'REP_ADD1=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,1,'REP')
      ,  'REP_ADD2=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,2,'REP')
      ,  'REP_ADD3=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,3,'REP')
      ,  'REP_ADD4=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,4,'REP')
      ,  'REP_ADD5=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,5,'REP')
      ,  'REP_ADD_CHG=P'
      ,  pay_magtape_generic.get_parameter_value('REP_ADD_CHG')
      ,  'GROSS_TDS_CHALLAN=P'
      ,  pay_in_24q_er_returns.gross_tot_tds_challan
         (g_gre_org_id ,
	 (g_assess_year
	 ||g_quarter),
	 pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      ,  'COUNT_SALARY=P'
      ,  pay_in_24q_er_returns.salary_rec_count(g_gre_org_id ,(g_assess_year||g_quarter))
      ,  'GROSS_TOT_TOTAL=P'
      ,  pay_in_24q_er_returns.total_gross_tot_income(g_gre_org_id,(g_assess_year||g_quarter))
      ,  'SAL_DET=P'
      ,  pay_magtape_generic.get_parameter_value('SAL_DETAILS')
      ,  'STATE_NAME=P'
      ,  hr_general.decode_lookup('IN_STATE_CODES',pai.action_information14)
      ,   'PAO_CODE=P'
      ,   pai.action_information15
      ,   'DDO_CODE=P'
      ,   pai.action_information16
      ,   'MINISTRY_NAME=P'
      ,   pai.action_information17
      ,   'OTHER_MINISTRY_NAME=P'
      ,   pai.action_information18
      ,   'PAO_REG_CODE=P'
      ,   pai.action_information19
      ,    'DDO_REG_CODE=P'
      ,   pai.action_information20
  FROM   pay_action_information pai
 WHERE   pai.action_information_category = 'IN_24Q_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = g_gre_org_id
   AND   pai.action_information3 = g_assess_year||g_quarter
   AND   pai.action_context_id   = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
   AND   ROWNUM = 1;



   /* CHALLAN DETAIL RECORD */
CURSOR c_f24q_challan_det_rec IS
SELECT DISTINCT 'TOT_DEDUCTEE_REC=P'
      ,  pay_in_24q_er_returns.deductee_rec_count(g_gre_org_id
	 ,pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
	 ,pai.action_information1)
      ,  'NIL_CHALLAN_IND=P'
      ,  'N'
      ,  'QUARTER_LAST_DATE=P'
      ,  DECODE(g_quarter,'Q1','3006','Q2','3009','Q3','3112','Q4','3103')
         ||DECODE(g_quarter,'Q4',
                  SUBSTR(g_assess_year,1,4)
	          ,SUBSTR(g_assess_year,1,4)-1)
      ,  'BANK_CHALLAN_NO=P'
      ,  pai.action_information1
      ,  'BANK_BRANCH_CODE=P'
      ,  SUBSTR(pai.action_information4,1,7)||'^'
      ,  'CHALLAN_DATE=P'
      ,  TO_CHAR(fnd_date.canonical_to_date(pai.action_information5),'DDMMYYYY')
      ,  'TDS_DEP=P'
      ,  NVL(pai.action_information6,'0')||'.00'
      ,  'SURCHARGE=P'
      ,  NVL(pai.action_information7,'0')||'.00'
      ,  'EDU_CESS=P'
      ,  NVL(pai.action_information8,'0')||'.00'
      ,  'INTEREST=P'
      ,  NVL(pai.action_information9,'0')||'.00'
      ,  'OTHERS=P'
      ,  NVL(pai.action_information10,'0')||'.00'
      ,  'TAX_VALUES=P'
      ,  pay_in_24q_er_returns.get_24Q_tax_values
         (pai.action_information1,g_gre_org_id
	 ,pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      ,  'CHQ_DD_NUM=P'
      ,  SUBSTR(pai.action_information11,1,15)||'^'
      ,  'BOOK_ENTRY=P'
      ,  pai.action_information12
      ,  'REMARKS=P'
      ,  SUBSTR(pai.action_information13,1,14)||'^'
      ,  'CHALLAN_REC_INDEX=P'
      ,  pai.action_information25
  FROM   pay_action_information pai
 WHERE   action_information_category = 'IN_24Q_CHALLAN'
   AND   action_context_type = 'PA'
   AND   action_information3 = g_gre_org_id
   AND   action_information2 = g_assess_year||g_quarter
   AND   pai.action_context_id= pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
  AND    fnd_date.canonical_to_date(pai.action_information5)<=fnd_date.CHARDATE_TO_DATE(SYSDATE)
UNION
  SELECT
        'TOT_DEDUCTEE_REC=P'
      , '0'
      , 'NIL_CHALLAN_IND=P'
      , 'Y'
      ,  'QUARTER_LAST_DATE=P'
      ,  DECODE(g_quarter,'Q1','3006','Q2','3009','Q3','3112','Q4','3103')
         ||DECODE(g_quarter,'Q4',
                  SUBSTR(g_assess_year,1,4)
	          ,SUBSTR(g_assess_year,1,4)-1)
      ,  'BANK_CHALLAN_NO=P'
      ,  ''
      ,  'BANK_BRANCH_CODE=P'
      ,  '^'
      ,  'CHALLAN_DATE=P'
      ,  ''
      ,  'TDS_DEP=P'
      ,  '0.00'
      ,  'SURCHARGE=P'
      ,  '0.00'
      ,  'EDU_CESS=P'
      ,  '0.00'
      ,  'INTEREST=P'
      ,  '0.00'
      ,  'OTHERS=P'
      ,  '0.00'
      ,  'TAX_VALUES=P'
      ,  '0.00^0.00^0.00^0.00^0.00^'
      ,  'CHQ_DD_NUM=P'
      ,  '^'
      ,  'BOOK_ENTRY=P'
      ,  ''
      ,  'REMARKS=P'
      ,  '^'
      ,  'CHALLAN_REC_INDEX=P'
      ,  '1'
FROM dual
WHERE NOT EXISTS ( SELECT 'EXISTS'
                   FROM   pay_action_information pai
                   WHERE   action_information_category = 'IN_24Q_CHALLAN'
                    AND   action_context_type = 'PA'
                    AND   action_information3 = g_gre_org_id
                    AND   action_information2 = g_assess_year||g_quarter
                    AND   pai.action_context_id= pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                    AND   fnd_date.canonical_to_date(pai.action_information5)<=fnd_date.CHARDATE_TO_DATE(SYSDATE)
  )
ORDER BY 32;


   /* DEDUCTEE DETAILS RECORDS */

  CURSOR c_f24q_ded_det_rec IS
  SELECT   'PERSON_ID=P'
	 ,  pai.action_information2||'^'
	 , 'DEDUCTEE_PAN=P'
	 ,  pai.action_information10||'^'
	 , 'PAN_REF_NO=P'
	 ,  pai.action_information11||'^'
	 , 'EMPLOYEE_NAME=P'
	 ,  SUBSTR(pai.action_information12,1,75)
	 , 'INCOME_TAX_D=P'
	 , pay_in_24q_er_returns.get_format_value(NVL(pai.action_information6,'0'))
	 , 'SURCHARGE_D=P'
	 , pay_in_24q_er_returns.get_format_value(NVL(pai.action_information7,'0'))
	 , 'EDU_CESS_D=P'
	 , pay_in_24q_er_returns.get_format_value(NVL(pai.action_information8,'0'))
	 , 'TOTAL_TAX_DEPOSITED=P'
         , pay_in_24q_er_returns.get_format_value(NVL(pai.action_information9,'0'))
	 , 'AMOUNT_PAYMENT=P'
	 , pay_in_24q_er_returns.get_format_value(NVL(pai.action_information5,'0'))
	 , 'PAYMENT_DATE=P'
	 , TO_CHAR(fnd_date.canonical_to_date( pai.action_information4),'DDMMYYYY')
	 , 'TAX_RATE=P'
	 , NVL(pai.action_information13,'0')
	 , 'DED_REC_INDEX=P'
	 , action_information25
   FROM  pay_action_information pai
  WHERE  action_information_category ='IN_24Q_DEDUCTEE'
    AND  action_context_type = 'AAP'
    AND  action_information3 =g_gre_org_id
    AND  action_information1 = pay_magtape_generic.get_parameter_value('BANK_CHALLAN_NO')
    AND  pay_in_24q_er_returns.get_format_value(NVL(pai.action_information5,'0')) <> '0.00'
    AND  EXISTS (SELECT 1
                  FROM pay_assignment_actions paa
                 WHERE paa.payroll_action_id = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                   AND paa.assignment_action_id = pai.action_context_id)
  ORDER BY pai.action_information2, TO_NUMBER(action_information25) ASC;



/*SALARY DETAIL RECORDS*/

CURSOR c_f24q_salary_det_rec IS
SELECT   'ACTION_CONTEXT_ID=P'
        , action_context_id
	, 'SOURCE_ID=P'
	, source_id
	, 'EMP_PERSON_ID=P'
	, action_information1
	, 'SAL_REC_INDEX=P'
	, action_information11
        , 'EMP_PAN=P'
        , action_information4
        , 'EMP_PAN_REF=P'
        , action_information5||'^'
        , 'EMP_FULL_NAME=P'
        , SUBSTR(action_information6,1,75)
	, 'EMP_DESIGNATION=P'
	, SUBSTR (action_information8,1,15)||'^'
        , 'EMP_START_DATE=P'
        , TO_CHAR(fnd_date.canonical_to_date(action_information9),'DDMMYYYY')
        , 'EMP_END_DATE=P'
        , TO_CHAR(fnd_date.canonical_to_date(action_information10),'DDMMYYYY')
	, 'CHAPTER_VIA_COUNT=P'
	, pay_in_24q_er_returns.chapter_VIA_rec_count(action_context_id,source_id)
        , 'F16_SEC17_SAL=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Salary Under Section 17',action_context_id,source_id,1)
        , 'F16_PROFIT_LIEU=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Profit in lieu of Salary',action_context_id,source_id,1)
        , 'EXCESS_INTEREST=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','Excess Interest Amount',action_context_id,source_id,1)
        , 'EXCESS_PF=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','Excess PF Amount',action_context_id,source_id,1)
        , 'ALLOWANCE_AMOUNT=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','Allowance Amount',action_context_id,source_id,1)
        , 'F16_ALW_EXEM=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Allowances Exempt',action_context_id,source_id,1)
	, 'F16_PERQ_VALUE=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Value of Perquisites',action_context_id,source_id,1)
        , 'F16_GROSS_LESS_ALW=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Gross Salary less Allowances',action_context_id,source_id,1)
        , 'F16_DEC_SEC16=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Deductions under Sec 16',action_context_id,source_id,1)
        , 'F16_INC_HEAD_SAL=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Income Chargeable Under head Salaries',action_context_id,source_id,1)
        , 'F16_OTHER_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Other Income',action_context_id,source_id,1)
        , 'F16_GROSS_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Gross Total Income',action_context_id,source_id,1)
        , 'F16_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Total Income',action_context_id,source_id,1)
        , 'F16_TAX_ON_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Tax on Total Income',action_context_id,source_id,1)
        , 'F16_TOTAL_TAX_PAY=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Total Tax payable',action_context_id,source_id,1)
        , 'F16_RELIEF_89=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Relief under Sec 89',action_context_id,source_id,1)
        , 'F16_MARGINAL_RELIEF=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Marginal Relief',action_context_id,source_id,1)
        , 'F16_TOT_CHAP_VIA=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Total Chapter VI A Deductions',action_context_id,source_id,1)
        , 'ENT_ALW=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Entertainment Allowance',action_context_id,source_id,1)
        , 'EMPLOYMENT_TAX=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Employment Tax',action_context_id,source_id,1)
        , 'COMP_ACC_EMP_CONTRI=P'
	, pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Employee Contribution for Company Accommodation',action_context_id,source_id,2)
        , 'COST_RENT_FUR=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Cost and Rent of Furniture',action_context_id,source_id,2)
        , 'COMP_ACC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Company Accommodation',action_context_id,source_id,2)
	, 'FUR_PERQ=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Furniture Perquisite',action_context_id,source_id,2)
	, 'MONTH_FUR_COST=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Monthly Furniture Cost',action_context_id,source_id,2)
        , 'DOMESTIC_PERSONAL_PERQ=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Domestic and Personal Services Perquisite',action_context_id,source_id,2)
	, 'CAR=P'
	, pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Motor Car Perquisite',action_context_id,source_id,2)
	, 'LTC=P'
	, pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Leave Travel Concession',action_context_id,source_id,2)
        , 'OTHER_PERQ=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_PERQ','Other Perquisites',action_context_id,source_id,2)
        , 'PERIOD=P'
        , g_quarter
        , 'EMP_CATEGORY=P'
        , pay_in_24q_er_returns.get_emp_category(action_information1)||'^'
        , 'L_SUR=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Surcharge',action_context_id,source_id,1)
        , 'L_CESS=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 Education Cess',action_context_id,source_id,1)
        , 'L_TOT_TDS=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24Q_SALARY','F16 TDS',action_context_id,source_id,1)
FROM   pay_action_information
WHERE  action_information_category = 'IN_24Q_PERSON'
  AND  action_context_type = 'AAP'
  AND  action_information2 =  g_assess_year||g_quarter
  AND  action_information3 = g_gre_org_id
  AND  action_context_id  IN (SELECT MAX(pai.action_context_id)
                               FROM  pay_action_information pai
                                    ,pay_assignment_actions paa
                                    ,per_assignments_f asg
                              WHERE  pai.action_information_category = 'IN_24Q_PERSON'
                                AND  pai.action_context_type = 'AAP'
                                AND  pai.action_information1 = asg.person_id
                                AND  pai.action_information2 = g_assess_year||g_quarter
                                AND  pai.action_information3 = g_gre_org_id
                                AND  pai.source_id = paa.assignment_action_id
                                AND  pai.assignment_id = asg.assignment_id
                                AND  asg.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                                GROUP BY  pai.assignment_id,pai.action_information1,pai.action_information9
                             )
ORDER BY fnd_number.canonical_to_number(action_information11) ASC;


/*CHAPTER_VIA DETAIL RECORDS*/

CURSOR c_f24q_chapter_VIA_rec IS
SELECT  'VIA_SECTION_ID=P'
        ,action_information1
	,'GROSS_AMOUNT=P'
	,pay_in_24q_er_returns.get_format_value(action_information3)
	,'QUALIFY_AMOUNT=P'
	,pay_in_24q_er_returns.get_format_value(action_information2)
        ,'PERIOD=P'
        ,g_quarter
 FROM   pay_action_information
WHERE  action_information_category = 'IN_24Q_VIA'
  AND  action_context_type = 'AAP'
  AND  action_context_id =   pay_magtape_generic.get_parameter_value('ACTION_CONTEXT_ID')
  AND  source_id =pay_magtape_generic.get_parameter_value('SOURCE_ID')
  AND  action_information1 IS NOT NULL
ORDER BY LENGTH(action_information1),source_id;


END pay_in_24q_er_returns;

/

--------------------------------------------------------
--  DDL for Package PAY_IN_24QC_ER_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_24QC_ER_RETURNS" AUTHID CURRENT_USER AS
/* $Header: pyin24cr.pkh 120.2.12010000.3 2009/11/06 12:24:51 mdubasi ship $ */

level_cnt NUMBER;


g_gre_org_id  VARCHAR2(15) := pay_magtape_generic.get_parameter_value('GRE_ORGANIZATION_PARAM');
g_assess_year VARCHAR2(15) := pay_magtape_generic.get_parameter_value('ASSESSMENT_YEAR_PARAM');
g_quarter     VARCHAR2(15) := pay_magtape_generic.get_parameter_value('QUARTER_PARAM');
g_action_id   VARCHAR2(15) := pay_magtape_generic.get_parameter_value('REF_PARAM');
g_salary_detail VARCHAR2(5):= pay_magtape_generic.get_parameter_value('SAL_DET_PARAM');
g_regular_file_date VARCHAR2(15) := pay_magtape_generic.get_parameter_value('REGULAR_DATE_PARAM');

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
--                  p_receipt             VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_rrr_no (p_gre_org_id      IN VARCHAR2
                    ,p_assess_year     IN VARCHAR2
                    ,p_quarter         IN VARCHAR2
                    ,p_receipt         IN VARCHAR2)
RETURN VARCHAR2;


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
--                  p_correction_type       VARCHAR2                    --
--                  p_max_action_id         VARCHAR2                    --
--------------------------------------------------------------------------
FUNCTION salary_rec_count (p_gre_org_id  IN VARCHAR2
                          ,p_assess_period IN VARCHAR2
                          ,p_correction_type IN VARCHAR2
			  ,p_max_action_id IN VARCHAR2)
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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2 ;

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
FUNCTION get_24QC_tax_values(p_challan_number IN VARCHAR2
                            ,p_gre_org_id     IN VARCHAR2
                            ,p_max_action_id  IN VARCHAR2
                            )
RETURN VARCHAR2;

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
RETURN NUMBER;

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
RETURN VARCHAR2;

/*  FILE HEADER RECORD */

CURSOR  c_f24qc_file_header IS
SELECT  'TAN_OF_DED=P'
       , pai.action_information2
       ,'MAX_ACTION_CONTEXT_ID=P'
       , pai.action_context_id
       ,'SUBMIT_DATE=P'
       , TO_CHAR (SYSDATE,'DDMMYYYY')
       ,'FILE_SEQ_NO=P'
       , pay_in_24qc_er_returns.get_file_seq_no(g_gre_org_id, g_assess_year, g_quarter)
       , 'CHECK_C4=P'
       , NVL(pai.action_information29,'N')
       ,'TOTAL_BATCH_NO=P'
       , DECODE(LENGTH(pai.action_information29), 1, 1, 2, 1, 5, 2, 8, 3, 11, 4, 14, 5, 17,6,1)
       , 'NAME_OF_UTILITY=P'
       ,  pay_in_24q_er_returns.get_product_release
       , 'REGULAR_FILE_DATE=P'
       ,  g_regular_file_date
  FROM   pay_action_information pai
       , pay_payroll_actions ppa
 WHERE   pai.action_information_category = 'IN_24QC_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = g_gre_org_id
   AND   pai.action_information3 = g_assess_year||g_quarter
   AND   ppa.action_type = 'X'
   AND   ppa.action_status = 'C'
   AND   ppa.report_type = 'IN_24QC_ARCHIVE'
   AND   ppa.report_qualifier = 'IN'
   AND   ppa.payroll_action_id = pai.action_context_id
   AND   pai.action_context_id = NVL(g_action_id,
                                     pay_in_24qc_er_returns.get_archive_pay_action(g_gre_org_id
                                                                                , (g_assess_year||g_quarter)))
   AND ROWNUM = 1;



 /* BATCH HEADER RECORD*/
CURSOR c_f24qc_batch_header IS
SELECT  DISTINCT 'TOT_CHALLAN_REC=P'
      ,  pay_in_24qc_er_returns.challan_rec_count_24qc
                                                       (g_gre_org_id
                                                      ,(g_assess_year||g_quarter)
                                                      , pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                                                      , hll.lookup_code)
      , 'TAN_OF_DED=P'
      ,  pai.action_information2
      , 'SAL_DET=P'
      ,  g_salary_detail
      , 'PAN_OF_TAN=P'
      ,  pai.action_information4
      , 'ASSESS_YEAR=P'
      ,  SUBSTR(g_assess_year,1,4)||SUBSTR(g_assess_year,8,2)
      , 'FIN_YEAR=P'
      ,  SUBSTR(g_assess_year,1,4)-1||LPAD(SUBSTR(g_assess_year,8,2)-1,2,'0')
      , 'PERIOD=P'
      ,  g_quarter
      , 'LEGAL_NAME=P'
      ,  SUBSTR(pai.action_information5,1,75)
      , 'LAST_LEGAL_NAME=P'
      ,  SUBSTR(pai.action_information16,1,75)
      , 'EMPLOYER_DIV=P'
      ,  SUBSTR(pai.action_information8,1,75)||'^'
      , 'EMPLOYER_ADD1=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,1,'EMP')
      , 'EMPLOYER_ADD2=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,2,'EMP')
      , 'EMPLOYER_ADD3=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,3,'EMP')
      , 'EMPLOYER_ADD4=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,4,'EMP')
      , 'EMPLOYER_ADD5=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information6,pai.action_information10,pai.action_information13,5,'EMP')
      , 'EMP_ADD_CHG=P'
      ,  pai.action_information18
      , 'REP_ADD_CHG=P'
      ,  pai.action_information19
      , 'EMPLOYER_TYPE=P'
      ,  action_information7
      , 'LAST_EMPLOYER_TYPE=P'
      ,  action_information17
      , 'REP_NAME=P'
      ,  SUBSTR(pai.action_information9,1,75)
      , 'REP_DESIG=P'
      ,  SUBSTR(pai.action_information11,1,75)||'^'
      , 'REP_ADD1=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,1,'REP')
      , 'REP_ADD2=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,2,'REP')
      , 'REP_ADD3=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,3,'REP')
      , 'REP_ADD4=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,4,'REP')
      , 'REP_ADD5=P'
      ,  pay_in_24q_er_returns.get_location_details(pai.action_information12,pai.action_information10,pai.action_information13,5,'REP')
      , 'ORIG_RRR=P'
      ,  pay_in_24qc_er_returns.get_rrr_no(g_gre_org_id, g_assess_year, g_quarter, 'Original')
      , 'PREV_RRR=P'
      ,  pay_in_24qc_er_returns.get_rrr_no(g_gre_org_id, g_assess_year, g_quarter, 'Previous')
      , 'BATCH_UPD_IND=P'
      ,  pai.action_information15
      , 'CORRECTION_TYPE=P'
      ,  hll.lookup_code
      , 'GROSS_TDS_CHALLAN=P'
      ,  pay_in_24qc_er_returns.gross_tot_tds_challan_24q
                                                         (g_gre_org_id
                                                       , (g_assess_year||g_quarter)
                                                       ,  pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                                                       ,  hll.lookup_code)
       ,  'COUNT_SALARY=P'
      ,  pay_in_24qc_er_returns.salary_rec_count(g_gre_org_id
                                                 ,g_assess_year||g_quarter
                                                 , hll.lookup_code
						 ,pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      , 'GROSS_TOTAL_INCOME=P'
      ,  pay_in_24qc_er_returns.total_gross_tot_income(g_gre_org_id
                                                         , g_assess_year||g_quarter
                                                         , hll.lookup_code
							 ,pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      ,  'STATE_NAME=P'
      ,  hr_general.decode_lookup('IN_STATE_CODES',pai.action_information20)
      ,  'PAO_CODE=P'
      ,   pai.action_information21
      ,  'DDO_CODE=P'
      ,   pai.action_information22
      ,  'MINISTRY_NAME=P'
      ,   pai.action_information23
      ,  'OTHER_MINISTRY_NAME=P'
      ,   pai.action_information24
      ,  'PAO_REG_CODE=P'
      ,   pai.action_information27
      ,   'DDO_REG_CODE=P'
      ,   pai.action_information28
      ,  'REGULAR_FILE_DATE=P'
      ,  g_regular_file_date
  FROM   pay_action_information pai
        ,hr_leg_lookups hll
 WHERE   pai.action_information_category = 'IN_24QC_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = g_gre_org_id
   AND   pai.action_information3 = g_assess_year||g_quarter
   AND   pai.action_context_id   = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
   and   hll.lookup_type = 'IN_FORM_24Q_CORRECTION_TYPES'
   and   INSTR(pai.action_information29,hll.lookup_code) <> 0;



   /* CHALLAN DETAIL RECORD */
CURSOR c_f24qc_challan_det_rec IS
SELECT DISTINCT 'TOT_DEDUCTEE_REC=P'
      ,  pay_in_24qc_er_returns.deductee_rec_count_24q(g_gre_org_id
                                                      ,pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                                                      ,pai.action_information1)
      , 'NIL_CHALLAN_IND=P'
      ,  pay_in_24qc_er_returns.get_prev_nil_challan_ind(g_gre_org_id
                                                      , (g_assess_year||g_quarter)
                                                      ,  pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      , 'QUARTER_LAST_DATE=P'
      ,  DECODE(g_quarter,'Q1','3006','Q2','3009','Q3','3112','Q4','3103')
         ||DECODE(g_quarter,'Q4',
                  SUBSTR(g_assess_year,1,4)
                 ,SUBSTR(g_assess_year,1,4)-1)
      , 'BANK_CHALLAN_NO=P'
      ,  pai.action_information1
      , 'LAST_BANK_CHALLAN_NO=P'
      ,  pai.action_information12
      , 'BANK_BRANCH_CODE=P'
      ,  SUBSTR(pai.action_information4,1,7)||'^'
      , 'LAST_BANK_BRANCH_CODE=P'
      ,  SUBSTR(pai.action_information13,1,7)||'^'
      , 'CHALLAN_DATE=P'
      ,  TO_CHAR(fnd_date.canonical_to_date(pai.action_information5),'DDMMYYYY')
      , 'LAST_CHALLAN_DATE=P'
      ,  TO_CHAR(fnd_date.canonical_to_date(pai.action_information14),'DDMMYYYY')
      , 'TDS_DEP=P'
      ,  NVL(pai.action_information6,'0')||'.00'
      , 'SURCHARGE=P'
      ,  NVL(pai.action_information7,'0')||'.00'
      , 'EDU_CESS=P'
      ,  NVL(pai.action_information8,'0')||'.00'
      , 'INTEREST=P'
      ,  NVL(pai.action_information9,'0')||'.00'
      , 'OTHERS=P'
      ,  NVL(pai.action_information10,'0')||'.00'
      , 'LAST_TOTAL_AMOUNT_DEPO=P'
      ,  NVL(pai.action_information19,'0.00')
      , 'TAX_VALUES=P'
      ,  pay_in_24qc_er_returns.get_24qc_tax_values(pai.action_information1,g_gre_org_id
                                                   ,pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID'))
      , 'CHQ_DD_NUM=P'
      ,  SUBSTR(pai.action_information11,1,15)||'^'
      , 'BOOK_ENTRY=P'
      ,  pai.action_information16
      , 'CHALLAN_UPD_IND=P'
      ,  DECODE(pai.action_information18, 'U', '1', '0')
      , 'CHALLAN_REC_INDEX=P'
      ,  pai.action_information25
      ,  'REGULAR_FILE_DATE=P'
      ,  g_regular_file_date
  FROM   pay_action_information pai
 WHERE   action_information_category = 'IN_24QC_CHALLAN'
   AND   action_context_type = 'PA'
   AND   action_information3 = g_gre_org_id
   AND   action_information2 = g_assess_year||g_quarter
   AND   pai.action_context_id = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
   AND   pai.action_information29 like '%'|| pay_magtape_generic.get_parameter_value('CORRECTION_TYPE')||'%'
   AND   fnd_date.canonical_to_date(pai.action_information5)<=fnd_date.CHARDATE_TO_DATE(SYSDATE)
ORDER BY 40;



   /* DEDUCTEE DETAILS RECORDS */

  CURSOR c_f24qc_ded_det_rec IS
  SELECT   DISTINCT 'PERSON_ID=P'
         ,  pai.action_information12
	 , 'LAST_DEDUCTEE_PAN=P'
         ,  pai.action_information13
         , 'DEDUCTEE_PAN=P'
         ,  pai.action_information9
         , 'LAST_PAN_REF_NO=P'
         ,  pai.action_information14
         , 'PAN_REF_NO=P'
         ,  pai.action_information11
         , 'EMPLOYEE_NAME=P'
         ,  SUBSTR(pai.action_information10,1,75)
         , 'INCOME_TAX_D=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information6),'0'))
         , 'SURCHARGE_D=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information7),'0'))
         , 'EDU_CESS_D=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information8),'0'))
         , 'LAST_TOTAL_TDS=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information17),'0'))
         , 'LAST_TOTAL_TAX_DEPOSITED=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information24),'0'))
         , 'TOTAL_TAX_DEPOSITED=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information16),'0'))
         , 'AMOUNT_PAYMENT=P'
         ,  pay_in_24q_er_returns.get_format_value(NVL(pay_in_24qc_er_returns.remove_curr_format(pai.action_information5),'0'))
         , 'PAYMENT_DATE=P'
         ,  TO_CHAR(fnd_date.canonical_to_date( pai.action_information4),'DDMMYYYY')
         , 'TAX_RATE=P'
         ,  DECODE(pai.action_information18,'L', 'A^', 'N', 'B^', '^')
         , 'DED_REC_INDEX=P'
         ,  pai.action_information25
         , 'UPD_MODE=P'
         ,  pai.action_information15
   FROM  pay_action_information pai
  WHERE  action_information_category ='IN_24QC_DEDUCTEE'
    AND  action_context_type = 'AAP'
    AND  action_information3 = g_gre_org_id
    AND  action_information1 = pay_magtape_generic.get_parameter_value('BANK_CHALLAN_NO')
    AND  ((pay_magtape_generic.get_parameter_value('CORRECTION_TYPE') = 'C5'
               AND INSTR(pai.action_information19, 'C5') <> 0)
         OR
          pay_magtape_generic.get_parameter_value('CORRECTION_TYPE') <> 'C5'
      )
    AND ((pay_magtape_generic.get_parameter_value('CORRECTION_TYPE') = 'C3'
      and(( INSTR(pai.action_information19, 'C3') <> 0) or action_information19 is null)
         OR
          pay_magtape_generic.get_parameter_value('CORRECTION_TYPE') <> 'C3'
      ))
  AND  EXISTS (SELECT 1
                 FROM   pay_assignment_actions paa
                 WHERE  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                 AND    paa.assignment_action_id = pai.action_context_id)
  ORDER BY pai.action_information12, TO_NUMBER(action_information25) ASC;



CURSOR c_f24qc_salary_det_rec IS
SELECT   DISTINCT 'ASSIGNMENT_ID=P'
        , assignment_id
        ,'ACTION_CONTEXT_ID=P'
        , action_context_id
        , 'SOURCE_ID=P'
        , source_id
        , 'EMP_PERSON_ID=P'
        , action_information1
        , 'MODE_TYPE=P'   --added
        ,  action_information10
        , 'SAL_REC_INDEX=P' --added
        , action_information12
        , 'EMP_PAN=P'
        , action_information4
        , 'EMP_PAN_REF=P'
        , action_information5||'^'
        , 'EMP_FULL_NAME=P'
        , SUBSTR(action_information6,1,75)
        , 'EMP_CATEGORY=P'
        , action_information7
        , 'EMP_START_DATE=P'
        , TO_CHAR(fnd_date.canonical_to_date(action_information8),'DDMMYYYY')
        , 'EMP_END_DATE=P'
        , TO_CHAR(fnd_date.canonical_to_date(action_information9),'DDMMYYYY')
	, 'CHAPTER_VIA_COUNT=P'
	, pay_in_24qc_er_returns.chapter_VIA_rec_count(action_context_id,source_id)
        , 'F16_SEC17_SAL=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Salary Under Section 17',action_context_id,source_id,1)
        , 'F16_PROFIT_LIEU=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Profit in lieu of Salary',action_context_id,source_id,1)
        , 'F16_OTHER_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Other Income',action_context_id,source_id,1)
        , 'F16_GROSS_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Gross Total Income',action_context_id,source_id,1)
        , 'PREV_F16_GROSS_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','Prev F16 Gross Total Income',action_context_id,source_id,1) --added
        , 'F16_GROSS_TOT_INC_24Q=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','Form24Q F16 Gross Total Income',action_context_id,source_id,1) --added
        , 'F16_TOT_CHAP_VIA=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Total Chapter VI A Deductions',action_context_id,source_id,1)
        , 'L_SUR=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Surcharge',action_context_id,source_id,1)
        , 'L_CESS=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Education Cess',action_context_id,source_id,1)
        , 'L_TOT_TDS=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 TDS',action_context_id,source_id,1)
        , 'F16_TOTAL_TAX_PAY=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Total Tax payable',action_context_id,source_id,1)
        , 'F16_RELIEF_89=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Relief under Sec 89',action_context_id,source_id,1)
        , 'F16_MARGINAL_RELIEF=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Marginal Relief',action_context_id,source_id,1)
        , 'ENT_ALW=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Entertainment Allowance',action_context_id,source_id,1)
        , 'EMPLOYMENT_TAX=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Employment Tax',action_context_id,source_id,1)
        , 'F16_DEC_SEC16=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Deductions under Sec 16',action_context_id,source_id,1)
        , 'F16_INC_HEAD_SAL=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Income Chargeable Under head Salaries',action_context_id,source_id,1)
        , 'F16_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Total Income',action_context_id,source_id,1)
        , 'F16_TAX_ON_TOT_INC=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Tax on Total Income',action_context_id,source_id,1)
        ,'F16_ALW_EXEM=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Allowances Exempt',action_context_id,source_id,1)
        , 'F16_PERQ_VALUE=P'
        , pay_in_24q_er_returns.get_24Q_values('IN_24QC_SALARY','F16 Value of Perquisites',action_context_id,source_id,1)
        , 'PERIOD=P'
        , g_quarter
FROM   pay_action_information
WHERE  action_information_category = 'IN_24QC_PERSON'
  AND  action_context_type = 'AAP'
  AND  action_information2 =  g_assess_year||g_quarter
  AND  action_information3 = g_gre_org_id
  AND  action_information11=pay_magtape_generic.get_parameter_value('CORRECTION_TYPE')
  AND  action_context_id  IN (SELECT MAX(pai.action_context_id)
                               FROM  pay_action_information pai
                                    ,pay_assignment_actions paa
                                    ,per_assignments_f asg
                              WHERE  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('MAX_ACTION_CONTEXT_ID')
                                AND  pai.action_context_id = paa.assignment_action_id
                                AND  pai.action_information_category = 'IN_24QC_PERSON'
                                AND  pai.action_context_type = 'AAP'
                                AND  pai.action_information1 = asg.person_id
                                AND  pai.action_information2 = g_assess_year||g_quarter
                                AND  pai.action_information3 = g_gre_org_id
                                AND  pai.assignment_id = asg.assignment_id
                                AND  asg.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                                AND  pai.action_information11=pay_magtape_generic.get_parameter_value('CORRECTION_TYPE')
                                GROUP BY  pai.assignment_id,pai.action_information1,pai.action_information9
                                   )
ORDER BY fnd_number.canonical_to_number(action_information1),assignment_id,fnd_number.canonical_to_number(action_information12) ASC;


/*CHAPTER_VIA DETAIL RECORDS*/

CURSOR c_f24qc_chapter_VIA_rec IS
SELECT  DISTINCT 'SOURCE_ID=P'
         ,source_id
        ,'VIA_SECTION_ID=P'
        ,action_information1
	,'QUALIFY_AMOUNT=P'
	,pay_in_24q_er_returns.get_format_value(action_information2)
 FROM  pay_action_information
WHERE  action_information_category = 'IN_24QC_VIA'
  AND  action_context_type = 'AAP'
  AND  action_context_id =   pay_magtape_generic.get_parameter_value('ACTION_CONTEXT_ID')
  AND  source_id =pay_magtape_generic.get_parameter_value('SOURCE_ID')
  AND  action_information1 IS NOT NULL
ORDER BY LENGTH(action_information1),source_id;


END pay_in_24qc_er_returns;

/

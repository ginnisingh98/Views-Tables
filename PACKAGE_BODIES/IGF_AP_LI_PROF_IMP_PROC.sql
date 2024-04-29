--------------------------------------------------------
--  DDL for Package Body IGF_AP_LI_PROF_IMP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LI_PROF_IMP_PROC" AS
/* $Header: IGFAP35B.pls 120.4 2006/04/12 08:53:01 museshad noship $ */
CURSOR c_int_data (p_batch_id NUMBER)
IS
  SELECT
    A.ROWID              ROW_ID              ,
    A.PERSON_NUMBER                          ,
    A.CSSINT_ID                              ,
    A.COLLEGE_CD                             ,
    A.ACADEMIC_YEAR_TXT                      ,
    A.STU_RECORD_TYPE                        ,
    A.CSS_ID_NUMBER_TXT                      ,
    A.REGISTRATION_RECEIPT_DATE              ,
    A.REGISTRATION_TYPE                      ,
    A.APPLICATION_RECEIPT_DATE               ,
    A.APPLICATION_TYPE                       ,
    A.ORIGINAL_FNAR_COMPUTE_TXT              ,
    A.REVISION_FNAR_COMPUTE_DATE             ,
    A.ELECTRONIC_EXTRACT_DATE                ,
    A.INSTIT_REPORTING_TYPE                  ,
    A.ASR_RECEIPT_DATE                       ,
    A.LAST_NAME                              ,
    A.FIRST_NAME                             ,
    A.MIDDLE_INITIAL_TXT                     ,
    A.ADDRESS_NUMBER_AND_STREET_TXT          ,
    A.CITY_TXT                               ,
    A.STATE_MAILING_TXT                      ,
    A.ZIP_CD                                 ,
    A.S_TELEPHONE_NUMBER_TXT                 ,
    A.S_TITLE_TYPE                           ,
    A.BIRTH_DATE                             ,
    A.SOCIAL_SECURITY_NUM                    ,
    A.STATE_LEGAL_RESIDENCE_TXT              ,
    A.FOREIGN_ADDRESS_FLAG                   ,
    A.FOREIGN_POSTAL_CD                      ,
    A.COUNTRY_CD                             ,
    A.FINANCIAL_AID_STATUS_TYPE              ,
    A.YEAR_IN_COLLEGE_TYPE                   ,
    A.MARITAL_STATUS_FLAG                    ,
    A.WARD_COURT_FLAG                        ,
    A.LEGAL_DEPENDENTS_OTHER_FLAG            ,
    A.HOUSEHOLD_SIZE_NUM                     ,
    A.NUMBER_IN_COLLEGE_NUM                  ,
    A.CITIZENSHIP_STATUS_TYPE                ,
    A.CITIZENSHIP_COUNTRY_CD                 ,
    A.VISA_CLASSIFICATION_TYPE               ,
    A.TAX_FIGURES_TYPE                       ,
    A.NUMBER_EXEMPTIONS_TXT                  ,
    A.ADJUSTED_GROSS_AMT                     ,
    A.US_TAX_PAID_AMT                        ,
    A.ITEMIZED_DEDUCTIONS_AMT                ,
    A.STU_INCOME_WORK_AMT                    ,
    A.SPOUSE_INCOME_WORK_AMT                 ,
    A.DIVID_INT_INCOME_AMT                   ,
    A.SOC_SEC_BENEFITS_AMT                   ,
    A.WELFARE_TANF_AMT                       ,
    A.CHILD_SUPP_RCVD_AMT                    ,
    A.EARNED_INCOME_CREDIT_AMT               ,
    A.OTHER_UNTAX_INCOME_AMT                 ,
    A.TAX_STU_AID_AMT                        ,
    A.CASH_SAV_CHECK_AMT                     ,
    A.IRA_KEOGH_AMT                          ,
    A.INVEST_VALUE_AMT                       ,
    A.INVEST_DEBT_AMT                        ,
    A.HOME_VALUE_AMT                         ,
    A.HOME_DEBT_AMT                          ,
    A.OTH_REAL_VALUE_AMT                     ,
    A.OTH_REAL_DEBT_AMT                      ,
    A.BUS_FARM_VALUE_AMT                     ,
    A.BUS_FARM_DEBT_AMT                      ,
    A.LIVE_ON_FARM_FLAG                      ,
    A.HOME_PURCH_PRICE_AMT                   ,
    A.HOPE_LL_CREDIT_AMT                     ,
    A.HOME_PURCH_YEAR_TXT                    ,
    A.TRUST_AMOUNT_TXT                       ,
    A.TRUST_AVAIL_FLAG                       ,
    A.TRUST_ESTAB_FLAG                       ,
    A.CHILD_SUPPORT_PAID_TXT                 ,
    A.MED_DENT_EXPENSES_TXT                  ,
    A.VET_US_FLAG                            ,
    A.VET_BEN_AMT                            ,
    A.VET_BEN_MONTHS_NUM                     ,
    A.STU_SUMMER_WAGES_AMT                   ,
    A.STU_SCHOOL_YR_WAGES_AMT                ,
    A.SPOUSE_SUMMER_WAGES_AMT                ,
    A.SPOUSE_SCHOOL_YR_WAGES_AMT             ,
    A.SUMMER_OTHER_TAX_INC_AMT               ,
    A.SCHOOL_YR_OTHER_TAX_INC_AMT            ,
    A.SUMMER_UNTAX_INC_AMT                   ,
    A.SCHOOL_YR_UNTAX_INC_AMT                ,
    A.GRANTS_SCHOL_ETC_AMT                   ,
    A.TUIT_BENEFITS_AMT                      ,
    A.CONT_PARENTS_AMT                       ,
    A.CONT_RELATIVES_AMT                     ,
    A.P_SIBLINGS_PRE_TUIT_AMT                ,
    A.P_STUDENT_PRE_TUIT_AMT                 ,
    A.P_HOUSEHOLD_SIZE_NUM                   ,
    A.P_IN_COLLEGE_NUM                       ,
    A.P_PARENTS_IN_COLLEGE_NUM               ,
    A.P_MARITAL_STATUS_TYPE                  ,
    A.P_STATE_LEGAL_RESIDENCE_CD             ,
    A.P_NATURAL_PAR_STATUS_FLAG              ,
    A.P_CHILD_SUPP_PAID_AMT                  ,
    A.P_REPAY_ED_LOANS_AMT                   ,
    A.P_MED_DENT_EXPENSES_AMT                ,
    A.P_TUIT_PAID_AMT                        ,
    A.P_TUIT_PAID_NUM                        ,
    A.P_EXP_CHILD_SUPP_PAID_AMT              ,
    A.P_EXP_REPAY_ED_LOANS_AMT               ,
    A.P_EXP_MED_DENT_EXPENSES_AMT            ,
    A.P_EXP_TUIT_PD_AMT                      ,
    A.P_EXP_TUIT_PD_NUM                      ,
    A.P_CASH_SAV_CHECK_AMT                   ,
    A.P_MONTH_MORTGAGE_PAY_AMT               ,
    A.P_INVEST_VALUE_AMT                     ,
    A.P_INVEST_DEBT_AMT                      ,
    A.P_HOME_VALUE_AMT                       ,
    A.P_HOME_DEBT_AMT                        ,
    A.P_HOME_PURCH_PRICE_AMT                 ,
    A.P_OWN_BUSINESS_FARM_FLAG               ,
    A.P_BUSINESS_VALUE_AMT                   ,
    A.P_BUSINESS_DEBT_AMT                    ,
    A.P_FARM_VALUE_AMT                       ,
    A.P_FARM_DEBT_AMT                        ,
    A.P_LIVE_ON_FARM_NUM                     ,
    A.P_OTH_REAL_ESTATE_VALUE_AMT            ,
    A.P_OTH_REAL_ESTATE_DEBT_AMT             ,
    A.P_OTH_REAL_PURCH_PRICE_AMT             ,
    A.P_SIBLINGS_ASSETS_AMT                  ,
    A.P_HOME_PURCH_YEAR_TXT                  ,
    A.P_OTH_REAL_PURCH_YEAR_TXT              ,
    A.P_PRIOR_AGI_AMT                        ,
    A.P_PRIOR_US_TAX_PAID_AMT                ,
    A.P_PRIOR_ITEM_DEDUCTIONS_AMT            ,
    A.P_PRIOR_OTHER_UNTAX_INC_AMT            ,
    A.P_TAX_FIGURES_NUM                      ,
    A.P_NUMBER_EXEMPTIONS_NUM                ,
    A.P_ADJUSTED_GROSS_INC_AMT               ,
    A.P_WAGES_SAL_TIPS_AMT                   ,
    A.P_INTEREST_INCOME_AMT                  ,
    A.P_DIVIDEND_INCOME_AMT                  ,
    A.P_NET_INC_BUS_FARM_AMT                 ,
    A.P_OTHER_TAXABLE_INCOME_AMT             ,
    A.P_ADJ_TO_INCOME_AMT                    ,
    A.P_US_TAX_PAID_AMT                      ,
    A.P_ITEMIZED_DEDUCTIONS_AMT              ,
    A.P_FATHER_INCOME_WORK_AMT               ,
    A.P_MOTHER_INCOME_WORK_AMT               ,
    A.P_SOC_SEC_BEN_AMT                      ,
    A.P_WELFARE_TANF_AMT                     ,
    A.P_CHILD_SUPP_RCVD_AMT                  ,
    A.P_DED_IRA_KEOGH_AMT                    ,
    A.P_TAX_DEFER_PENS_SAVS_AMT              ,
    A.P_DEP_CARE_MED_SPENDING_AMT            ,
    A.P_EARNED_INCOME_CREDIT_AMT             ,
    A.P_LIVING_ALLOW_AMT                     ,
    A.P_TAX_EXMPT_INT_AMT                    ,
    A.P_FOREIGN_INC_EXCL_AMT                 ,
    A.P_OTHER_UNTAX_INC_AMT                  ,
    A.P_HOPE_LL_CREDIT_AMT                   ,
    A.P_YR_SEPARATION_AMT                    ,
    A.P_YR_DIVORCE_AMT                       ,
    A.P_EXP_FATHER_INC_AMT                   ,
    A.P_EXP_MOTHER_INC_AMT                   ,
    A.P_EXP_OTHER_TAX_INC_AMT                ,
    A.P_EXP_OTHER_UNTAX_INC_AMT              ,
    A.LINE_2_RELATION_TYPE                   ,
    A.LINE_2_ATTEND_COLLEGE_TYPE             ,
    A.LINE_3_RELATION_TYPE                   ,
    A.LINE_3_ATTEND_COLLEGE_TYPE             ,
    A.LINE_4_RELATION_TYPE                   ,
    A.LINE_4_ATTEND_COLLEGE_TYPE             ,
    A.LINE_5_RELATION_TYPE                   ,
    A.LINE_5_ATTEND_COLLEGE_TYPE             ,
    A.LINE_6_RELATION_TYPE                   ,
    A.LINE_6_ATTEND_COLLEGE_TYPE             ,
    A.LINE_7_RELATION_TYPE                   ,
    A.LINE_7_ATTEND_COLLEGE_TYPE             ,
    A.LINE_8_RELATION_TYPE                   ,
    A.LINE_8_ATTEND_COLLEGE_TYPE             ,
    A.P_AGE_FATHER_NUM                       ,
    A.P_AGE_MOTHER_NUM                       ,
    A.P_DIV_SEP_FLAG                         ,
    A.B_CONT_NON_CUSTODIAL_PAR_TXT           ,
    A.COLLEGE_2_TYPE                         ,
    A.COLLEGE_3_TYPE                         ,
    A.COLLEGE_4_TYPE                         ,
    A.COLLEGE_5_TYPE                         ,
    A.COLLEGE_6_TYPE                         ,
    A.COLLEGE_7_TYPE                         ,
    A.COLLEGE_8_TYPE                         ,
    A.SCHOOL_1_CD                            ,
    A.HOUSING_1_TYPE                         ,
    A.SCHOOL_2_CD                            ,
    A.HOUSING_2_TYPE                         ,
    A.SCHOOL_3_CD                            ,
    A.HOUSING_3_TYPE                         ,
    A.SCHOOL_4_CD                            ,
    A.HOUSING_4_TYPE                         ,
    A.SCHOOL_5_CD                            ,
    A.HOUSING_5_TYPE                         ,
    A.SCHOOL_6_CD                            ,
    A.HOUSING_6_TYPE                         ,
    A.SCHOOL_7_CD                            ,
    A.HOUSING_7_TYPE                         ,
    A.SCHOOL_8_CD                            ,
    A.HOUSING_8_TYPE                         ,
    A.SCHOOL_9_CD                            ,
    A.HOUSING_9_TYPE                         ,
    A.SCHOOL_10_CD                           ,
    A.HOUSING_10_TYPE                        ,
    A.ADDITIONAL_SCHOOL_1_CD                 ,
    A.ADDITIONAL_SCHOOL_2_CD                 ,
    A.ADDITIONAL_SCHOOL_3_CD                 ,
    A.ADDITIONAL_SCHOOL_4_CD                 ,
    A.ADDITIONAL_SCHOOL_5_CD                 ,
    A.ADDITIONAL_SCHOOL_6_CD                 ,
    A.ADDITIONAL_SCHOOL_7_CD                 ,
    A.ADDITIONAL_SCHOOL_8_CD                 ,
    A.ADDITIONAL_SCHOOL_9_CD                 ,
    A.ADDITIONAL_SCHOOL_10_CD                ,
    A.EXPLANATION_SPEC_CIRCUM_FLAG           ,
    A.SIGNATURE_STUDENT_FLAG                 ,
    A.SIGNATURE_SPOUSE_FLAG                  ,
    A.SIGNATURE_FATHER_FLAG                  ,
    A.SIGNATURE_MOTHER_FLAG                  ,
    A.MONTH_DAY_COMPLETED                    ,
    A.YEAR_COMPLETED_FLAG                    ,
    A.AGE_LINE_2_NUM                         ,
    A.AGE_LINE_3_NUM                         ,
    A.AGE_LINE_4_NUM                         ,
    A.AGE_LINE_5_NUM                         ,
    A.AGE_LINE_6_NUM                         ,
    A.AGE_LINE_7_NUM                         ,
    A.AGE_LINE_8_NUM                         ,
    A.A_ONLINE_SIGNATURE_FLAG                ,
    A.QUESTION_1_NUMBER_TXT                  ,
    A.QUESTION_1_SIZE_NUM                    ,
    A.QUESTION_1_ANSWER_TXT                  ,
    A.QUESTION_2_NUMBER_TXT                  ,
    A.QUESTION_2_SIZE_NUM                    ,
    A.QUESTION_2_ANSWER_TXT                  ,
    A.QUESTION_3_NUMBER_TXT                  ,
    A.QUESTION_3_SIZE_NUM                    ,
    A.QUESTION_3_ANSWER_TXT                  ,
    A.QUESTION_4_NUMBER_TXT                  ,
    A.QUESTION_4_SIZE_NUM                    ,
    A.QUESTION_4_ANSWER_TXT                  ,
    A.QUESTION_5_NUMBER_TXT                  ,
    A.QUESTION_5_SIZE_NUM                    ,
    A.QUESTION_5_ANSWER_TXT                  ,
    A.QUESTION_6_NUMBER_TXT                  ,
    A.QUESTION_6_SIZE_NUM                    ,
    A.QUESTION_6_ANSWER_TXT                  ,
    A.QUESTION_7_NUMBER_TXT                  ,
    A.QUESTION_7_SIZE_NUM                    ,
    A.QUESTION_7_ANSWER_TXT                  ,
    A.QUESTION_8_NUMBER_TXT                  ,
    A.QUESTION_8_SIZE_NUM                    ,
    A.QUESTION_8_ANSWER_TXT                  ,
    A.QUESTION_9_NUMBER_TXT                  ,
    A.QUESTION_9_SIZE_NUM                    ,
    A.QUESTION_9_ANSWER_TXT                  ,
    A.QUESTION_10_NUMBER_TXT                 ,
    A.QUESTION_10_SIZE_NUM                   ,
    A.QUESTION_10_ANSWER_TXT                 ,
    A.QUESTION_11_NUMBER_TXT                 ,
    A.QUESTION_11_SIZE_NUM                   ,
    A.QUESTION_11_ANSWER_TXT                 ,
    A.QUESTION_12_NUMBER_TXT                 ,
    A.QUESTION_12_SIZE_NUM                   ,
    A.QUESTION_12_ANSWER_TXT                 ,
    A.QUESTION_13_NUMBER_TXT                 ,
    A.QUESTION_13_SIZE_NUM                   ,
    A.QUESTION_13_ANSWER_TXT                 ,
    A.QUESTION_14_NUMBER_TXT                 ,
    A.QUESTION_14_SIZE_NUM                   ,
    A.QUESTION_14_ANSWER_TXT                 ,
    A.QUESTION_15_NUMBER_TXT                 ,
    A.QUESTION_15_SIZE_NUM                   ,
    A.QUESTION_15_ANSWER_TXT                 ,
    A.QUESTION_16_NUMBER_TXT                 ,
    A.QUESTION_16_SIZE_NUM                   ,
    A.QUESTION_16_ANSWER_TXT                 ,
    A.QUESTION_17_NUMBER_TXT                 ,
    A.QUESTION_17_SIZE_NUM                   ,
    A.QUESTION_17_ANSWER_TXT                 ,
    A.QUESTION_18_NUMBER_TXT                 ,
    A.QUESTION_18_SIZE_NUM                   ,
    A.QUESTION_18_ANSWER_TXT                 ,
    A.QUESTION_19_NUMBER_TXT                 ,
    A.QUESTION_19_SIZE_NUM                   ,
    A.QUESTION_19_ANSWER_TXT                 ,
    A.QUESTION_20_NUMBER_TXT                 ,
    A.QUESTION_20_SIZE_NUM                   ,
    A.QUESTION_20_ANSWER_TXT                 ,
    A.QUESTION_21_NUMBER_TXT                 ,
    A.QUESTION_21_SIZE_NUM                   ,
    A.QUESTION_21_ANSWER_TXT                 ,
    A.QUESTION_22_NUMBER_TXT                 ,
    A.QUESTION_22_SIZE_NUM                   ,
    A.QUESTION_22_ANSWER_TXT                 ,
    A.QUESTION_23_NUMBER_TXT                 ,
    A.QUESTION_23_SIZE_NUM                   ,
    A.QUESTION_23_ANSWER_TXT                 ,
    A.QUESTION_24_NUMBER_TXT                 ,
    A.QUESTION_24_SIZE_NUM                   ,
    A.QUESTION_24_ANSWER_TXT                 ,
    A.QUESTION_25_NUMBER_TXT                 ,
    A.QUESTION_25_SIZE_NUM                   ,
    A.QUESTION_25_ANSWER_TXT                 ,
    A.QUESTION_26_NUMBER_TXT                 ,
    A.QUESTION_26_SIZE_NUM                   ,
    A.QUESTION_26_ANSWER_TXT                 ,
    A.QUESTION_27_NUMBER_TXT                 ,
    A.QUESTION_27_SIZE_NUM                   ,
    A.QUESTION_27_ANSWER_TXT                 ,
    A.QUESTION_28_NUMBER_TXT                 ,
    A.QUESTION_28_SIZE_NUM                   ,
    A.QUESTION_28_ANSWER_TXT                 ,
    A.QUESTION_29_NUMBER_TXT                 ,
    A.QUESTION_29_SIZE_NUM                   ,
    A.QUESTION_29_ANSWER_TXT                 ,
    A.QUESTION_30_NUMBER_TXT                 ,
    A.QUESTIONS_30_SIZE_NUM                  ,
    A.QUESTION_30_ANSWER_TXT                 ,
    A.R_S_EMAIL_ADDRESS_TXT                  ,
    A.EPS_CD                                 ,
    A.COMP_CSS_DEPENDCY_STATUS_TYPE          ,
    A.STU_AGE_NUM                            ,
    A.ASSUMED_STU_YR_IN_COLL_TYPE            ,
    A.COMP_STU_MARITAL_STATUS_TYPE           ,
    A.STU_FAMILY_MEMBERS_NUM                 ,
    A.STU_FAM_MEMBERS_IN_COLLEGE_NUM         ,
    A.PAR_MARITAL_STATUS_TYPE                ,
    A.PAR_FAMILY_MEMBERS_NUM                 ,
    A.PAR_TOTAL_IN_COLLEGE_NUM               ,
    A.PAR_PAR_IN_COLLEGE_NUM                 ,
    A.PAR_OTHERS_IN_COLLEGE_NUM              ,
    A.PAR_AESA_NUM                           ,
    A.PAR_CESA_NUM                           ,
    A.STU_AESA_NUM                           ,
    A.STU_CESA_NUM                           ,
    A.IM_P_BAS_AGI_TAXABLE_AMT               ,
    A.IM_P_BAS_UNTX_INC_AND_BEN_AMT          ,
    A.IM_P_BAS_INC_ADJ_AMT                   ,
    A.IM_P_BAS_TOTAL_INCOME_AMT              ,
    A.IM_P_BAS_US_INCOME_TAX_AMT             ,
    A.IM_P_BAS_ST_AND_OTHER_TAX_AMT          ,
    A.IM_P_BAS_FICA_TAX_AMT                  ,
    A.IM_P_BAS_MED_DENTAL_AMT                ,
    A.IM_P_BAS_EMPLOYMENT_ALLOW_AMT          ,
    A.IM_P_BAS_ANNUAL_ED_SAVINGS_AMT         ,
    A.IM_P_BAS_INC_PROT_ALLOW_M_AMT          ,
    A.IM_P_BAS_TOTAL_INC_ALLOW_AMT           ,
    A.IM_P_BAS_CAL_AVAIL_INC_AMT             ,
    A.IM_P_BAS_AVAIL_INCOME_AMT              ,
    A.IM_P_BAS_TOTAL_CONT_INC_AMT            ,
    A.IM_P_BAS_CASH_BANK_ACCOUNT_AMT         ,
    A.IM_P_BAS_HOME_EQUITY_AMT               ,
    A.IM_P_BAS_OT_RL_EST_INV_EQ_AMT          ,
    A.IM_P_BAS_ADJ_BUS_FARM_WRTH_AMT         ,
    A.IM_P_BAS_ASS_SIBS_PRE_TUI_AMT          ,
    A.IM_P_BAS_NET_WORTH_AMT                 ,
    A.IM_P_BAS_EMERG_RES_ALLOW_AMT           ,
    A.IM_P_BAS_CUM_ED_SAVINGS_AMT            ,
    A.IM_P_BAS_LOW_INC_ALLOW_AMT             ,
    A.IM_P_BAS_TOTAL_ASSET_ALLOW_AMT         ,
    A.IM_P_BAS_DISC_NET_WORTH_AMT            ,
    A.IM_P_BAS_TOTAL_CONT_ASSET_AMT          ,
    A.IM_P_BAS_TOTAL_CONT_AMT                ,
    A.IM_P_BAS_NUM_IN_COLL_ADJ_AMT           ,
    A.IM_P_BAS_CONT_FOR_STU_AMT              ,
    A.IM_P_BAS_CONT_FROM_INCOME_AMT          ,
    A.IM_P_BAS_CONT_FROM_ASSETS_AMT          ,
    A.IM_P_OPT_AGI_TAX_INCOME_AMT            ,
    A.IM_P_OPT_UNTX_INC_BEN_AMT              ,
    A.IM_P_OPT_INC_ADJ_AMT                   ,
    A.IM_P_OPT_TOTAL_INCOME_AMT              ,
    A.IM_P_OPT_US_INCOME_TAX_AMT             ,
    A.IM_P_OPT_ST_AND_OTHER_TAX_AMT          ,
    A.IM_P_OPT_FICA_TAX_AMT                  ,
    A.IM_P_OPT_MED_DENTAL_AMT                ,
    A.IM_P_OPT_ELEM_SEC_TUIT_AMT             ,
    A.IM_P_OPT_EMPLOYMENT_ALLOW_AMT          ,
    A.IM_P_OPT_ANNUAL_ED_SAVING_AMT          ,
    A.IM_P_OPT_INC_PROT_ALLOW_M_AMT          ,
    A.IM_P_OPT_TOTAL_INC_ALLOW_AMT           ,
    A.IM_P_OPT_CAL_AVAIL_INC_AMT             ,
    A.IM_P_OPT_AVAIL_INCOME_AMT              ,
    A.IM_P_OPT_TOTAL_CONT_INC_AMT            ,
    A.IM_P_OPT_CASH_BANK_ACCNT_AMT           ,
    A.IM_P_OPT_HOME_EQUITY_AMT               ,
    A.IM_P_OPT_OT_RL_EST_INV_EQ_AMT          ,
    A.IM_P_OPT_ADJ_FARM_WORTH_AMT            ,
    A.IM_P_OPT_ASS_SIBS_PRE_T_AMT            ,
    A.IM_P_OPT_NET_WORTH_AMT                 ,
    A.IM_P_OPT_EMERG_RES_ALLOW_AMT           ,
    A.IM_P_OPT_CUM_ED_SAVINGS_AMT            ,
    A.IM_P_OPT_LOW_INC_ALLOW_AMT             ,
    A.IM_P_OPT_TOTAL_ASSET_ALLOW_AMT         ,
    A.IM_P_OPT_DISC_NET_WORTH_AMT            ,
    A.IM_P_OPT_TOTAL_CONT_ASSET_AMT          ,
    A.IM_P_OPT_TOTAL_CONT_AMT                ,
    A.IM_P_OPT_NUM_IN_COLL_ADJ_AMT           ,
    A.IM_P_OPT_CONT_FOR_STU_AMT              ,
    A.IM_P_OPT_CONT_FROM_INCOME_AMT          ,
    A.IM_P_OPT_CONT_FROM_ASSETS_AMT          ,
    A.FM_P_ANALYSIS_TYPE                     ,
    A.FM_P_AGI_TAXABLE_INCOME_AMT            ,
    A.FM_P_UNTX_INC_AND_BEN_AMT              ,
    A.FM_P_INC_ADJ_AMT                       ,
    A.FM_P_TOTAL_INCOME_AMT                  ,
    A.FM_P_US_INCOME_TAX_AMT                 ,
    A.FM_P_STATE_AND_OTHER_TAX_AMT           ,
    A.FM_P_FICA_TAX_AMT                      ,
    A.FM_P_EMPLOYMENT_ALLOW_AMT              ,
    A.FM_P_INCOME_PROT_ALLOW_AMT             ,
    A.FM_P_TOTAL_ALLOW_AMT                   ,
    A.FM_P_AVAIL_INCOME_AMT                  ,
    A.FM_P_CASH_BANK_ACCOUNTS_AMT            ,
    A.FM_P_OT_RL_EST_INV_EQ_AMT              ,
    A.FM_P_ADJ_FARM_NET_WORTH_AMT            ,
    A.FM_P_NET_WORTH_AMT                     ,
    A.FM_P_ASSET_PROT_ALLOW_AMT              ,
    A.FM_P_DISC_NET_WORTH_AMT                ,
    A.FM_P_TOTAL_CONTRIBUTION_AMT            ,
    A.FM_P_NUM_IN_COLL_NUM                   ,
    A.FM_P_CONT_FOR_STU_AMT                  ,
    A.FM_P_CONT_FROM_INCOME_AMT              ,
    A.FM_P_CONT_FROM_ASSETS_AMT              ,
    A.IM_S_BAS_AGI_TAX_INCOME_AMT            ,
    A.IM_S_BAS_UNTX_INC_AND_BEN_AMT          ,
    A.IM_S_BAS_INC_ADJ_AMT                   ,
    A.IM_S_BAS_TOTAL_INCOME_AMT              ,
    A.IM_S_BAS_US_INCOME_TAX_AMT             ,
    A.IM_S_BAS_ST_AND_OTH_TAX_AMT            ,
    A.IM_S_BAS_FICA_TAX_AMT                  ,
    A.IM_S_BAS_MED_DENTAL_AMT                ,
    A.IM_S_BAS_EMPLOYMENT_ALLOW_AMT          ,
    A.IM_S_BAS_ANNUAL_ED_SAVINGS_AMT         ,
    A.IM_S_BAS_INC_PROT_ALLOW_M_AMT          ,
    A.IM_S_BAS_TOTAL_INC_ALLOW_AMT           ,
    A.IM_S_BAS_CAL_AVAIL_INCOME_AMT          ,
    A.IM_S_BAS_AVAIL_INCOME_AMT              ,
    A.IM_S_BAS_TOTAL_CONT_INC_AMT            ,
    A.IM_S_BAS_CASH_BANK_ACCOUNT_AMT         ,
    A.IM_S_BAS_HOME_EQUITY_AMT               ,
    A.IM_S_BAS_OT_RL_EST_INV_EQ_AMT          ,
    A.IM_S_BAS_ADJ_FARM_WORTH_AMT            ,
    A.IM_S_BAS_TRUSTS_AMT                    ,
    A.IM_S_BAS_NET_WORTH_AMT                 ,
    A.IM_S_BAS_EMERG_RES_ALLOW_AMT           ,
    A.IM_S_BAS_CUM_ED_SAVINGS_AMT            ,
    A.IM_S_BAS_TOTAL_ASSET_ALLOW_AMT         ,
    A.IM_S_BAS_DISC_NET_WORTH_AMT            ,
    A.IM_S_BAS_TOTAL_CONT_ASSET_AMT          ,
    A.IM_S_BAS_TOTAL_CONT_AMT                ,
    A.IM_S_BAS_NUM_IN_COLL_ADJ_AMT           ,
    A.IM_S_BAS_CONT_FOR_STU_AMT              ,
    A.IM_S_BAS_CONT_FROM_INCOME_AMT          ,
    A.IM_S_BAS_CONT_FROM_ASSETS_AMT          ,
    A.IM_S_EST_AGI_TAX_INCOME_AMT            ,
    A.IM_S_EST_UNTX_INC_AND_BEN_AMT          ,
    A.IM_S_EST_INC_ADJ_AMT                   ,
    A.IM_S_EST_TOTAL_INCOME_AMT              ,
    A.IM_S_EST_US_INCOME_TAX_AMT             ,
    A.IM_S_EST_ST_AND_OTH_TAX_AMT            ,
    A.IM_S_EST_FICA_TAX_AMT                  ,
    A.IM_S_EST_MED_DENTAL_AMT                ,
    A.IM_S_EST_EMPLOYMENT_ALLOW_AMT          ,
    A.IM_S_EST_ANNUAL_ED_SAVINGS_AMT         ,
    A.IM_S_EST_INC_PROT_ALLOW_M_AMT          ,
    A.IM_S_EST_TOTAL_INC_ALLOW_AMT           ,
    A.IM_S_EST_CAL_AVAIL_INCOME_AMT          ,
    A.IM_S_EST_AVAIL_INCOME_AMT              ,
    A.IM_S_EST_TOTAL_CONT_INC_AMT            ,
    A.IM_S_EST_CASH_BANK_ACCOUNT_AMT         ,
    A.IM_S_EST_HOME_EQUITY_AMT               ,
    A.IM_S_EST_OT_RL_EST_INV_EQU_AMT         ,
    A.IM_S_EST_ADJ_FARM_WORTH_AMT            ,
    A.IM_S_EST_EST_TRUSTS_AMT                ,
    A.IM_S_EST_NET_WORTH_AMT                 ,
    A.IM_S_EST_EMERG_RES_ALLOW_AMT           ,
    A.IM_S_EST_CUM_ED_SAVINGS_AMT            ,
    A.IM_S_EST_TOTAL_ASSET_ALLOW_AMT         ,
    A.IM_S_EST_DISC_NET_WORTH_AMT            ,
    A.IM_S_EST_TOTAL_CONT_ASSET_AMT          ,
    A.IM_S_EST_TOTAL_CONT_AMT                ,
    A.IM_S_EST_NUM_IN_COLL_ADJ_AMT           ,
    A.IM_S_EST_CONT_FOR_STU_AMT              ,
    A.IM_S_EST_CONT_FROM_INCOME_AMT          ,
    A.IM_S_EST_CONT_FROM_ASSETS_AMT          ,
    A.IM_S_OPT_AGI_TAX_INCOME_AMT            ,
    A.IM_S_OPT_UNTX_INC_AND_BEN_AMT          ,
    A.IM_S_OPT_INC_ADJ_AMT                   ,
    A.IM_S_OPT_TOTAL_INCOME_AMT              ,
    A.IM_S_OPT_US_INCOME_TAX_AMT             ,
    A.IM_S_OPT_STATE_OTH_TAXES_AMT           ,
    A.IM_S_OPT_FICA_TAX_AMT                  ,
    A.IM_S_OPT_MED_DENTAL_AMT                ,
    A.IM_S_OPT_EMPLOYMENT_ALLOW_AMT          ,
    A.IM_S_OPT_ANNUAL_ED_SAVINGS_AMT         ,
    A.IM_S_OPT_INC_PROT_ALLOW_M_AMT          ,
    A.IM_S_OPT_TOTAL_INC_ALLOW_AMT           ,
    A.IM_S_OPT_CAL_AVAIL_INCOME_AMT          ,
    A.IM_S_OPT_AVAIL_INCOME_AMT              ,
    A.IM_S_OPT_TOTAL_CONT_INC_AMT            ,
    A.IM_S_OPT_CASH_BANK_ACCOUNT_AMT         ,
    A.IM_S_OPT_IRA_KEOGH_ACCOUNT_AMT         ,
    A.IM_S_OPT_HOME_EQUITY_AMT               ,
    A.IM_S_OPT_OT_RL_EST_INV_EQ_AMT          ,
    A.IM_S_OPT_ADJ_BUS_FRM_WORTH_AMT         ,
    A.IM_S_OPT_TRUSTS_AMT                    ,
    A.IM_S_OPT_NET_WORTH_AMT                 ,
    A.IM_S_OPT_EMERG_RES_ALLOW_AMT           ,
    A.IM_S_OPT_CUM_ED_SAVINGS_AMT            ,
    A.IM_S_OPT_TOTAL_ASSET_ALLOW_AMT         ,
    A.IM_S_OPT_DISC_NET_WORTH_AMT            ,
    A.IM_S_OPT_TOTAL_CONT_ASSET_AMT          ,
    A.IM_S_OPT_TOTAL_CONT_AMT                ,
    A.IM_S_OPT_NUM_IN_COLL_ADJ_AMT           ,
    A.IM_S_OPT_CONT_FOR_STU_AMT              ,
    A.IM_S_OPT_CONT_FROM_INCOME_AMT          ,
    A.IM_S_OPT_CONT_FROM_ASSETS_AMT          ,
    A.FM_S_ANALYSIS_TYPE                     ,
    A.FM_S_AGI_TAXABLE_INCOME_AMT            ,
    A.FM_S_UNTX_INC_AND_BEN_AMT              ,
    A.FM_S_INC_ADJ_AMT                       ,
    A.FM_S_TOTAL_INCOME_AMT                  ,
    A.FM_S_US_INCOME_TAX_AMT                 ,
    A.FM_S_STATE_AND_OTH_TAXES_AMT           ,
    A.FM_S_FICA_TAX_AMT                      ,
    A.FM_S_EMPLOYMENT_ALLOW_AMT              ,
    A.FM_S_INCOME_PROT_ALLOW_AMT             ,
    A.FM_S_TOTAL_ALLOW_AMT                   ,
    A.FM_S_CAL_AVAIL_INCOME_AMT              ,
    A.FM_S_AVAIL_INCOME_AMT                  ,
    A.FM_S_CASH_BANK_ACCOUNTS_AMT            ,
    A.FM_S_OT_RL_EST_INV_EQUITY_AMT          ,
    A.FM_S_ADJ_BUS_FARM_WORTH_AMT            ,
    A.FM_S_TRUSTS_AMT                        ,
    A.FM_S_NET_WORTH_AMT                     ,
    A.FM_S_ASSET_PROT_ALLOW_AMT              ,
    A.FM_S_DISC_NET_WORTH_AMT                ,
    A.FM_S_TOTAL_CONT_AMT                    ,
    A.FM_S_NUM_IN_COLL_NUM                   ,
    A.FM_S_CONT_FOR_STU_AMT                  ,
    A.FM_S_CONT_FROM_INCOME_AMT              ,
    A.FM_S_CONT_FROM_ASSETS_AMT              ,
    A.IM_INST_RESIDENT_FLAG                  ,
    A.INSTITUTIONAL_1_BUDGET_NAME            ,
    A.IM_INST_1_BUDGET_DURATION_NUM          ,
    A.IM_INST_1_TUITION_FEES_AMT             ,
    A.IM_INST_1_BOOKS_SUPPLIES_AMT           ,
    A.IM_INST_1_LIVING_EXPENSES_AMT          ,
    A.IM_INST_1_TOT_EXPENSES_AMT             ,
    A.IM_INST_1_TOT_STU_CONT_AMT ,
    A.IM_INST_1_TOT_PAR_CONT_AMT             ,
    A.IM_INST_1_TOT_FAMILY_CONT_AMT          ,
    A.IM_INST_1_VA_BENEFITS_AMT              ,
    A.IM_INST_1_OT_CONT_AMT                  ,
    A.IM_INST_1_EST_FINAN_NEED_AMT           ,
    A.INSTITUTIONAL_2_BUDGET_TXT             ,
    A.IM_INST_2_BUDGET_DURATION_NUM          ,
    A.IM_INST_2_TUITION_FEES_AMT             ,
    A.IM_INST_2_BOOKS_SUPPLIES_AMT           ,
    A.IM_INST_2_LIVING_EXPENSES_AMT          ,
    A.IM_INST_2_TOT_EXPENSES_AMT             ,
    A.IM_INST_2_TOT_STU_CONT_AMT             ,
    A.IM_INST_2_TOT_PAR_CONT_AMT             ,
    A.IM_INST_2_TOT_FAMILY_CONT_AMT          ,
    A.IM_INST_2_VA_BENEFITS_AMT              ,
    A.IM_INST_2_EST_FINAN_NEED_AMT           ,
    A.INSTITUTIONAL_3_BUDGET_TXT             ,
    A.IM_INST_3_BUDGET_DURATION_NUM          ,
    A.IM_INST_3_TUITION_FEES_AMT             ,
    A.IM_INST_3_BOOKS_SUPPLIES_AMT           ,
    A.IM_INST_3_LIVING_EXPENSES_AMT          ,
    A.IM_INST_3_TOT_EXPENSES_AMT             ,
    A.IM_INST_3_TOT_STU_CONT_AMT,
    A.IM_INST_3_TOT_PAR_CONT_AMT ,
    A.IM_INST_3_TOT_FAMILY_CONT_AMT          ,
    A.IM_INST_3_VA_BENEFITS_AMT              ,
    A.IM_INST_3_EST_FINAN_NEED_AMT           ,
    A.FM_INST_1_FEDERAL_EFC_TXT              ,
    A.FM_INST_1_VA_BENEFITS_TXT              ,
    A.FM_INST_1_FED_ELIGIBILITY_TXT          ,
    A.FM_INST_1_PELL_TXT                     ,
    A.OPTION_PAR_LOSS_ALLOW_FLAG             ,
    A.OPTION_PAR_TUITION_FLAG                ,
    A.OPTION_PAR_HOME_TYPE                   ,
    A.OPTION_PAR_HOME_VALUE_TXT              ,
    A.OPTION_PAR_HOME_DEBT_TXT               ,
    A.OPTION_STU_IRA_KEOGH_FLAG              ,
    A.OPTION_STU_HOME_TYPE                   ,
    A.OPTION_STU_HOME_VALUE_TXT              ,
    A.OPTION_STU_HOME_DEBT_TXT               ,
    A.OPTION_STU_SUM_AY_INC_FLAG             ,
    A.OPTION_PAR_HOPE_LL_CREDIT_FLAG         ,
    A.OPTION_STU_HOPE_LL_CREDIT_FLAG         ,
    A.IM_PARENT_1_8_MONTHS_BAS_TXT           ,
    A.IM_P_MORE_THAN_9_MTH_BA_TXT            ,
    A.IM_PARENT_1_8_MONTHS_OPT_TXT           ,
    A.IM_P_MORE_THAN_9_MTH_OP_TXT            ,
    A.FNAR_MESSAGE_1_FLAG                    ,
    A.FNAR_MESSAGE_2_FLAG                    ,
    A.FNAR_MESSAGE_3_FLAG                    ,
    A.FNAR_MESSAGE_4_FLAG                    ,
    A.FNAR_MESSAGE_5_FLAG                    ,
    A.FNAR_MESSAGE_6_FLAG                    ,
    A.FNAR_MESSAGE_7_FLAG                    ,
    A.FNAR_MESSAGE_8_FLAG                    ,
    A.FNAR_MESSAGE_9_FLAG                    ,
    A.FNAR_MESSAGE_10_FLAG                   ,
    A.FNAR_MESSAGE_11_FLAG                   ,
    A.FNAR_MESSAGE_12_FLAG                   ,
    A.FNAR_MESSAGE_13_FLAG                   ,
    A.FNAR_MESSAGE_20_FLAG                   ,
    A.FNAR_MESSAGE_21_FLAG                   ,
    A.FNAR_MESSAGE_22_FLAG                   ,
    A.FNAR_MESSAGE_23_FLAG                   ,
    A.FNAR_MESSAGE_24_FLAG                   ,
    A.FNAR_MESSAGE_25_FLAG                   ,
    A.FNAR_MESSAGE_26_FLAG                   ,
    A.FNAR_MESSAGE_27_FLAG                   ,
    A.FNAR_MESSAGE_30_FLAG                   ,
    A.FNAR_MESSAGE_31_FLAG                   ,
    A.FNAR_MESSAGE_32_FLAG                   ,
    A.FNAR_MESSAGE_33_FLAG                   ,
    A.FNAR_MESSAGE_34_FLAG                   ,
    A.FNAR_MESSAGE_35_FLAG                   ,
    A.FNAR_MESSAGE_36_FLAG                   ,
    A.FNAR_MESSAGE_37_FLAG                   ,
    A.FNAR_MESSAGE_38_FLAG                   ,
    A.FNAR_MESSAGE_39_FLAG                   ,
    A.FNAR_MESSAGE_45_FLAG                   ,
    A.FNAR_MESSAGE_46_FLAG                   ,
    A.FNAR_MESSAGE_47_FLAG                   ,
    A.FNAR_MESSAGE_48_FLAG                   ,
    A.FNAR_MESSAGE_50_FLAG                   ,
    A.FNAR_MESSAGE_51_FLAG                   ,
    A.FNAR_MESSAGE_52_FLAG                   ,
    A.FNAR_MESSAGE_53_FLAG                   ,
    A.FNAR_MESSAGE_56_FLAG                   ,
    A.FNAR_MESSAGE_57_FLAG                   ,
    A.FNAR_MESSAGE_58_FLAG                   ,
    A.FNAR_MESSAGE_59_FLAG                   ,
    A.FNAR_MESSAGE_60_FLAG                   ,
    A.FNAR_MESSAGE_61_FLAG                   ,
    A.FNAR_MESSAGE_62_FLAG                   ,
    A.FNAR_MESSAGE_63_FLAG                   ,
    A.FNAR_MESSAGE_64_FLAG                   ,
    A.FNAR_MESSAGE_65_FLAG                   ,
    A.FNAR_MESSAGE_71_FLAG                   ,
    A.FNAR_MESSAGE_72_FLAG                   ,
    A.FNAR_MESSAGE_73_FLAG                   ,
    A.FNAR_MESSAGE_74_FLAG                   ,
    A.FNAR_MESSAGE_75_FLAG                   ,
    A.FNAR_MESSAGE_76_FLAG                   ,
    A.FNAR_MESSAGE_77_FLAG                   ,
    A.FNAR_MESSAGE_78_FLAG                   ,
    A.FNAR_MESG_10_STU_FAM_MEM_NUM           ,
    A.FNAR_MESG_11_STU_NO_IN_COL_NUM         ,
    A.FNAR_MESG_24_STU_AVAIL_INC_AMT         ,
    A.FNAR_MESG_26_STU_TAXES_AMT             ,
    A.FNAR_MESG_33_STU_HOME_VAL_AMT          ,
    A.FNAR_MESG_34_STU_HOME_VAL_AMT          ,
    A.FNAR_MESG_34_STU_HOME_EQU_AMT          ,
    A.FNAR_MESG_35_STU_HOME_VAL_AMT          ,
    A.FNAR_MESG_35_STU_HOME_EQU_AMT          ,
    A.FNAR_MESG_36_STU_HOME_EQU_AMT          ,
    A.FNAR_MESG_48_PAR_FAM_MEM_NUM           ,
    A.FNAR_MESG_49_PAR_NO_IN_COL_NUM         ,
    A.FNAR_MESG_56_PAR_AGI_AMT               ,
    A.FNAR_MESG_62_PAR_TAXES_AMT             ,
    A.FNAR_MESG_73_PAR_HOME_VAL_AMT          ,
    A.FNAR_MESG_74_PAR_HOME_VAL_AMT          ,
    A.FNAR_MESG_74_PAR_HOME_EQU_AMT          ,
    A.FNAR_MESG_75_PAR_HOME_VAL_AMT          ,
    A.FNAR_MESG_75_PAR_HOME_EQU_AMT          ,
    A.FNAR_MESG_76_PAR_HOME_EQU_AMT          ,
    A.ASSUMPTION_MESSAGE_1_FLAG              ,
    A.ASSUMPTION_MESSAGE_2_FLAG              ,
    A.ASSUMPTION_MESSAGE_3_FLAG              ,
    A.ASSUMPTION_MESSAGE_4_FLAG              ,
    A.ASSUMPTION_MESSAGE_5_FLAG              ,
    A.ASSUMPTION_MESSAGE_6_FLAG              ,
    A.FNAR_MESSAGE_49_FLAG                   ,
    A.FNAR_MESSAGE_55_FLAG                   ,
    A.OPTION_PAR_COLA_ADJ_FLAG,
    A.OPTION_PAR_STU_FA_ASSETS_FLAG,
    A.OPTION_PAR_IPT_ASSETS_FLAG,
    A.OPTION_STU_IPT_ASSETS_FLAG,
    A.OPTION_PAR_COLA_ADJ_VALUE,
    A.P_SOC_SEC_BEN_STUDENT_AMT,
    A.P_TUIT_FEE_DEDUCT_AMT,
    A.OPTION_IND_STU_IPT_ASSETS_FLAG,
    A.stu_lives_with_num,
    A.stu_most_support_from_num,
    A.location_computer_num,
    A.cust_parent_cont_adj_num,
    A.custodial_parent_num,
    A.cust_par_base_prcnt_inc_amt,
    A.cust_par_base_cont_inc_amt,
    A.cust_par_base_cont_ast_amt,
    A.cust_par_base_tot_cont_amt,
    A.cust_par_opt_prcnt_inc_amt,
    A.cust_par_opt_cont_inc_amt,
    A.cust_par_opt_cont_ast_amt,
    A.cust_par_opt_tot_cont_amt,
    A.parents_email_txt,
    A.parent_1_birth_date,
    A.parent_2_birth_date
  FROM
   IGF_AP_LI_CSS_INTS A
  WHERE
    A.BATCH_NUM =  p_batch_id  AND
    A.IMPORT_STATUS_TYPE IN ('U','R')  ;

    CURSOR c_css_int_data(p_award_year  NUMBER )IS
    SELECT
      ROWID row_id, A.*
    FROM IGF_AP_CSS_INTERFACE_ALL A
   WHERE A.RECORD_STATUS = 'LEGACY' AND
         TO_NUMBER(A.ACADEMIC_YEAR) = p_award_year;

        l_css_int_data_rec c_css_int_data%ROWTYPE;
        c_int_data_rec     c_int_data%ROWTYPE;
        l_css_log VARCHAR2(1);
        l_debug_str                    VARCHAR2(2000) := NULL;

        g_sys_award_year                 igf_ap_batch_aw_map.sys_award_year%TYPE ;
  PROCEDURE p_convert_rec
  IS
    /*
    ||  Created By : rasahoo
    ||  Created On :
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_field_debug NUMBER;
  BEGIN
    l_field_debug := 0 ;
    l_field_debug := l_field_debug + 1 ;

    c_int_data_rec.ROW_ID                                     := l_css_int_data_rec.ROW_ID;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PERSON_NUMBER                              := NULL;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CSSINT_ID                                  := l_css_int_data_rec.CSS_ID  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_CD                                 := l_css_int_data_rec.COLLEGE_CODE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ACADEMIC_YEAR_TXT                          := l_css_int_data_rec.ACADEMIC_YEAR  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_RECORD_TYPE                            := l_css_int_data_rec.STU_RECORD_TYPE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CSS_ID_NUMBER_TXT                          := l_css_int_data_rec.CSS_ID_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.REGISTRATION_RECEIPT_DATE                  := TO_DATE(l_css_int_data_rec.REGISTRATION_RECEIPT_DATE,'MMDDYYYY')  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.REGISTRATION_TYPE                          := l_css_int_data_rec.REGISTRATION_TYPE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.APPLICATION_RECEIPT_DATE                   := TO_DATE(l_css_int_data_rec.APPLICATION_RECEIPT_DATE,'MMDDYYYY')  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.APPLICATION_TYPE                           := l_css_int_data_rec.APPLICATION_TYPE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ORIGINAL_FNAR_COMPUTE_TXT                  := l_css_int_data_rec.ORIGINAL_FNAR_COMPUTE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.REVISION_FNAR_COMPUTE_DATE                 := TO_DATE(l_css_int_data_rec.REVISION_FNAR_COMPUTE_DATE,'MMDDYYYY')  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ELECTRONIC_EXTRACT_DATE                    := TO_DATE(l_css_int_data_rec.ELECTRONIC_EXTRACT_DATE,'MMDDYYYY')  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.INSTIT_REPORTING_TYPE                      := l_css_int_data_rec.INSTITUTIONAL_REPORTING_TYPE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASR_RECEIPT_DATE                           :=  TO_DATE(l_css_int_data_rec.ASR_RECEIPT_DATE,'MMDDYYYY')    ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LAST_NAME                                  := l_css_int_data_rec.LAST_NAME  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FIRST_NAME                                 := l_css_int_data_rec.FIRST_NAME  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.MIDDLE_INITIAL_TXT                         := l_css_int_data_rec.MIDDLE_INITIAL  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDRESS_NUMBER_AND_STREET_TXT              := l_css_int_data_rec.ADDRESS_NUMBER_AND_STREET  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CITY_TXT                                   := l_css_int_data_rec.CITY  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STATE_MAILING_TXT                          := l_css_int_data_rec.STATE_MAILING  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ZIP_CD                                     := l_css_int_data_rec.ZIP_CODE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.S_TELEPHONE_NUMBER_TXT                     := l_css_int_data_rec.S_TELEPHONE_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.S_TITLE_TYPE                               := l_css_int_data_rec.S_TITLE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.BIRTH_DATE                                 := TO_DATE(l_css_int_data_rec.DATE_OF_BIRTH,'MMDDYYYY')  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SOCIAL_SECURITY_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SOCIAL_SECURITY_NUMBER )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STATE_LEGAL_RESIDENCE_TXT                  := l_css_int_data_rec.STATE_LEGAL_RESIDENCE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FOREIGN_ADDRESS_FLAG                       := l_css_int_data_rec.FOREIGN_ADDRESS_INDICATOR  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FOREIGN_POSTAL_CD                          := l_css_int_data_rec.FOREIGN_POSTAL_CODE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COUNTRY_CD                                 := l_css_int_data_rec.COUNTRY  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FINANCIAL_AID_STATUS_TYPE                  := l_css_int_data_rec.FINANCIAL_AID_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.YEAR_IN_COLLEGE_TYPE                       := l_css_int_data_rec.YEAR_IN_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.MARITAL_STATUS_FLAG                        := l_css_int_data_rec.MARITAL_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.WARD_COURT_FLAG                            := l_css_int_data_rec.WARD_COURT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LEGAL_DEPENDENTS_OTHER_FLAG                := l_css_int_data_rec.LEGAL_DEPENDENTS_OTHER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSEHOLD_SIZE_NUM                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.HOUSEHOLD_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.NUMBER_IN_COLLEGE_NUM                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.NUMBER_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CITIZENSHIP_STATUS_TYPE                    := l_css_int_data_rec.CITIZENSHIP_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CITIZENSHIP_COUNTRY_CD                     := l_css_int_data_rec.CITIZENSHIP_COUNTRY  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.VISA_CLASSIFICATION_TYPE                   := l_css_int_data_rec.VISA_CLASSIFICATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.TAX_FIGURES_TYPE                           := l_css_int_data_rec.TAX_FIGURES  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.NUMBER_EXEMPTIONS_TXT                      := l_css_int_data_rec.NUMBER_EXEMPTIONS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADJUSTED_GROSS_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.ADJUSTED_GROSS_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.US_TAX_PAID_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.US_TAX_PAID )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ITEMIZED_DEDUCTIONS_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.ITEMIZED_DEDUCTIONS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_INCOME_WORK_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_INCOME_WORK )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SPOUSE_INCOME_WORK_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SPOUSE_INCOME_WORK )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.DIVID_INT_INCOME_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.DIVID_INT_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SOC_SEC_BENEFITS_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SOC_SEC_BENEFITS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.WELFARE_TANF_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.WELFARE_TANF )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CHILD_SUPP_RCVD_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.CHILD_SUPP_RCVD )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.EARNED_INCOME_CREDIT_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.EARNED_INCOME_CREDIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OTHER_UNTAX_INCOME_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.OTHER_UNTAX_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.TAX_STU_AID_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.TAX_STU_AID )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CASH_SAV_CHECK_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.CASH_SAV_CHECK )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IRA_KEOGH_AMT                              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IRA_KEOGH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.INVEST_VALUE_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.INVEST_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.INVEST_DEBT_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.INVEST_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOME_VALUE_AMT                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOME_DEBT_AMT                              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.HOME_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OTH_REAL_VALUE_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.OTH_REAL_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OTH_REAL_DEBT_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.OTH_REAL_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.BUS_FARM_VALUE_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.BUS_FARM_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.BUS_FARM_DEBT_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.BUS_FARM_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LIVE_ON_FARM_FLAG                          := l_css_int_data_rec.LIVE_ON_FARM  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOME_PURCH_PRICE_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.HOME_PURCH_PRICE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOPE_LL_CREDIT_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.HOPE_LL_CREDIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOME_PURCH_YEAR_TXT                        := l_css_int_data_rec.HOME_PURCH_YEAR  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.TRUST_AMOUNT_TXT                           := l_css_int_data_rec.TRUST_AMOUNT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.TRUST_AVAIL_FLAG                           := l_css_int_data_rec.TRUST_AVAIL  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.TRUST_ESTAB_FLAG                           := l_css_int_data_rec.TRUST_ESTAB  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CHILD_SUPPORT_PAID_TXT                     := l_css_int_data_rec.CHILD_SUPPORT_PAID  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.MED_DENT_EXPENSES_TXT                      := l_css_int_data_rec.MED_DENT_EXPENSES  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.VET_US_FLAG                                := l_css_int_data_rec.VET_US  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.VET_BEN_AMT                                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.VET_BEN_AMOUNT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.VET_BEN_MONTHS_NUM                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.VET_BEN_MONTHS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_SUMMER_WAGES_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_SUMMER_WAGES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_SCHOOL_YR_WAGES_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_SCHOOL_YR_WAGES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SPOUSE_SUMMER_WAGES_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SPOUSE_SUMMER_WAGES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SPOUSE_SCHOOL_YR_WAGES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SPOUSE_SCHOOL_YR_WAGES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SUMMER_OTHER_TAX_INC_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SUMMER_OTHER_TAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_YR_OTHER_TAX_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SCHOOL_YR_OTHER_TAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SUMMER_UNTAX_INC_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SUMMER_UNTAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_YR_UNTAX_INC_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.SCHOOL_YR_UNTAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.GRANTS_SCHOL_ETC_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.GRANTS_SCHOL_ETC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.TUIT_BENEFITS_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.TUIT_BENEFITS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CONT_PARENTS_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.CONT_PARENTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.CONT_RELATIVES_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.CONT_RELATIVES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_SIBLINGS_PRE_TUIT_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_SIBLINGS_PRE_TUIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_STUDENT_PRE_TUIT_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_STUDENT_PRE_TUIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_HOUSEHOLD_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_HOUSEHOLD_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_IN_COLLEGE_NUM                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_NUMBER_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_PARENTS_IN_COLLEGE_NUM                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_PARENTS_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_MARITAL_STATUS_TYPE                      := l_css_int_data_rec.P_MARITAL_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_STATE_LEGAL_RESIDENCE_CD                 := l_css_int_data_rec.P_STATE_LEGAL_RESIDENCE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_NATURAL_PAR_STATUS_FLAG                  := l_css_int_data_rec.P_NATURAL_PAR_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_CHILD_SUPP_PAID_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_CHILD_SUPP_PAID )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_REPAY_ED_LOANS_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_REPAY_ED_LOANS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_MED_DENT_EXPENSES_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_MED_DENT_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_TUIT_PAID_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_TUIT_PAID_AMOUNT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_TUIT_PAID_NUM                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_TUIT_PAID_NUMBER )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_CHILD_SUPP_PAID_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_CHILD_SUPP_PAID )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_REPAY_ED_LOANS_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_REPAY_ED_LOANS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_MED_DENT_EXPENSES_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_MED_DENT_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_TUIT_PD_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_TUIT_PD_AMOUNT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_TUIT_PD_NUM                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_TUIT_PD_NUMBER )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_CASH_SAV_CHECK_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_CASH_SAV_CHECK )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_MONTH_MORTGAGE_PAY_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_MONTH_MORTGAGE_PAY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_INVEST_VALUE_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_INVEST_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_INVEST_DEBT_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_INVEST_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_HOME_VALUE_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_HOME_DEBT_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_HOME_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_HOME_PURCH_PRICE_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_HOME_PURCH_PRICE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OWN_BUSINESS_FARM_FLAG                   := l_css_int_data_rec.P_OWN_BUSINESS_FARM  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_BUSINESS_VALUE_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_BUSINESS_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_BUSINESS_DEBT_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_BUSINESS_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_FARM_VALUE_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_FARM_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_FARM_DEBT_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_FARM_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_LIVE_ON_FARM_NUM                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_LIVE_ON_FARM )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OTH_REAL_ESTATE_VALUE_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_OTH_REAL_ESTATE_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OTH_REAL_ESTATE_DEBT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_OTH_REAL_ESTATE_DEBT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OTH_REAL_PURCH_PRICE_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_OTH_REAL_PURCH_PRICE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_SIBLINGS_ASSETS_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_SIBLINGS_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_HOME_PURCH_YEAR_TXT                      := l_css_int_data_rec.P_HOME_PURCH_YEAR  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OTH_REAL_PURCH_YEAR_TXT                  := l_css_int_data_rec.P_OTH_REAL_PURCH_YEAR  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_PRIOR_AGI_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_PRIOR_AGI )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_PRIOR_US_TAX_PAID_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_PRIOR_US_TAX_PAID )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_PRIOR_ITEM_DEDUCTIONS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_PRIOR_ITEM_DEDUCTIONS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_PRIOR_OTHER_UNTAX_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_PRIOR_OTHER_UNTAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_TAX_FIGURES_NUM                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_TAX_FIGURES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_NUMBER_EXEMPTIONS_NUM                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_NUMBER_EXEMPTIONS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_ADJUSTED_GROSS_INC_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_ADJUSTED_GROSS_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_WAGES_SAL_TIPS_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_WAGES_SAL_TIPS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_INTEREST_INCOME_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_INTEREST_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_DIVIDEND_INCOME_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_DIVIDEND_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_NET_INC_BUS_FARM_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_NET_INC_BUS_FARM )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OTHER_TAXABLE_INCOME_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_OTHER_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_ADJ_TO_INCOME_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_ADJ_TO_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_US_TAX_PAID_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_US_TAX_PAID )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_ITEMIZED_DEDUCTIONS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_ITEMIZED_DEDUCTIONS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_FATHER_INCOME_WORK_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_FATHER_INCOME_WORK )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_MOTHER_INCOME_WORK_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_MOTHER_INCOME_WORK )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_SOC_SEC_BEN_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_SOC_SEC_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_WELFARE_TANF_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_WELFARE_TANF )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_CHILD_SUPP_RCVD_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_CHILD_SUPP_RCVD )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_DED_IRA_KEOGH_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_DED_IRA_KEOGH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_TAX_DEFER_PENS_SAVS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_TAX_DEFER_PENS_SAVS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_DEP_CARE_MED_SPENDING_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_DEP_CARE_MED_SPENDING )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EARNED_INCOME_CREDIT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EARNED_INCOME_CREDIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_LIVING_ALLOW_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_LIVING_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_TAX_EXMPT_INT_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_TAX_EXMPT_INT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_FOREIGN_INC_EXCL_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_FOREIGN_INC_EXCL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_OTHER_UNTAX_INC_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_OTHER_UNTAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_HOPE_LL_CREDIT_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_HOPE_LL_CREDIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_YR_SEPARATION_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_YR_SEPARATION )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_YR_DIVORCE_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_YR_DIVORCE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_FATHER_INC_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_FATHER_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_MOTHER_INC_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_MOTHER_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_OTHER_TAX_INC_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_OTHER_TAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_EXP_OTHER_UNTAX_INC_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_EXP_OTHER_UNTAX_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_2_RELATION_TYPE                       := l_css_int_data_rec.LINE_2_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_2_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_2_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_3_RELATION_TYPE                       := l_css_int_data_rec.LINE_3_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_3_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_3_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_4_RELATION_TYPE                       := l_css_int_data_rec.LINE_4_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_4_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_4_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_5_RELATION_TYPE                       := l_css_int_data_rec.LINE_5_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_5_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_5_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_6_RELATION_TYPE                       := l_css_int_data_rec.LINE_6_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_6_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_6_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_7_RELATION_TYPE                       := l_css_int_data_rec.LINE_7_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_7_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_7_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_8_RELATION_TYPE                       := l_css_int_data_rec.LINE_8_RELATION  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.LINE_8_ATTEND_COLLEGE_TYPE                 := l_css_int_data_rec.LINE_8_ATTEND_COLLEGE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_AGE_FATHER_NUM                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_AGE_FATHER )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_AGE_MOTHER_NUM                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.P_AGE_MOTHER )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.P_DIV_SEP_FLAG                             := l_css_int_data_rec.P_DIV_SEP_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.B_CONT_NON_CUSTODIAL_PAR_TXT               := l_css_int_data_rec.B_CONT_NON_CUSTODIAL_PAR  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_2_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_2  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_3_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_3  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_4_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_4  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_5_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_5  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_6_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_6  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_7_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_7  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COLLEGE_8_TYPE                             := l_css_int_data_rec.COLLEGE_TYPE_8  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_1_CD                                := l_css_int_data_rec.SCHOOL_CODE_1  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_1_TYPE                             := l_css_int_data_rec.HOUSING_CODE_1  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_2_CD                                := l_css_int_data_rec.SCHOOL_CODE_2  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_2_TYPE                             := l_css_int_data_rec.HOUSING_CODE_2  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_3_CD                                := l_css_int_data_rec.SCHOOL_CODE_3  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_3_TYPE                             := l_css_int_data_rec.HOUSING_CODE_3  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_4_CD                                := l_css_int_data_rec.SCHOOL_CODE_4  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_4_TYPE                             := l_css_int_data_rec.HOUSING_CODE_4  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_5_CD                                := l_css_int_data_rec.SCHOOL_CODE_5  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_5_TYPE                             := l_css_int_data_rec.HOUSING_CODE_5  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_6_CD                                := l_css_int_data_rec.SCHOOL_CODE_6  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_6_TYPE                             := l_css_int_data_rec.HOUSING_CODE_6  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_7_CD                                := l_css_int_data_rec.SCHOOL_CODE_7  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_7_TYPE                             := l_css_int_data_rec.HOUSING_CODE_7  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_8_CD                                := l_css_int_data_rec.SCHOOL_CODE_8  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_8_TYPE                             := l_css_int_data_rec.HOUSING_CODE_8  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_9_CD                                := l_css_int_data_rec.SCHOOL_CODE_9  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_9_TYPE                             := l_css_int_data_rec.HOUSING_CODE_9  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SCHOOL_10_CD                               := l_css_int_data_rec.SCHOOL_CODE_10  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.HOUSING_10_TYPE                            := l_css_int_data_rec.HOUSING_CODE_10  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_1_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_1  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_2_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_2  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_3_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_3  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_4_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_4  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_5_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_5  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_6_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_6  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_7_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_7  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_8_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_8  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_9_CD                     := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_9  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ADDITIONAL_SCHOOL_10_CD                    := l_css_int_data_rec.ADDITIONAL_SCHOOL_CODE_10  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.EXPLANATION_SPEC_CIRCUM_FLAG               := l_css_int_data_rec.EXPLANATION_SPEC_CIRCUM  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SIGNATURE_STUDENT_FLAG                     := l_css_int_data_rec.SIGNATURE_STUDENT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SIGNATURE_SPOUSE_FLAG                      := l_css_int_data_rec.SIGNATURE_SPOUSE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SIGNATURE_FATHER_FLAG                      := l_css_int_data_rec.SIGNATURE_FATHER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.SIGNATURE_MOTHER_FLAG                      := l_css_int_data_rec.SIGNATURE_MOTHER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.MONTH_DAY_COMPLETED                        := l_css_int_data_rec.MONTH_DAY_COMPLETED  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.YEAR_COMPLETED_FLAG                        := l_css_int_data_rec.YEAR_COMPLETED  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_2_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_2 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_3_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_3 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_4_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_4 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_5_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_5 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_6_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_6 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_7_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_7 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.AGE_LINE_8_NUM                             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.AGE_LINE_8 )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.A_ONLINE_SIGNATURE_FLAG                    := l_css_int_data_rec.A_ONLINE_SIGNATURE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_1_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_1_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_1_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_1_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_1_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_1_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_2_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_2_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_2_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_2_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_2_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_2_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_3_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_3_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_3_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_3_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_3_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_3_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_4_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_4_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_4_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_4_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_4_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_4_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_5_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_5_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_5_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_5_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_5_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_5_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_6_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_6_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_6_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_6_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_6_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_6_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_7_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_7_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_7_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_7_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_7_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_7_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_8_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_8_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_8_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_8_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_8_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_8_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_9_NUMBER_TXT                      := l_css_int_data_rec.QUESTION_9_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_9_SIZE_NUM                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_9_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_9_ANSWER_TXT                      := l_css_int_data_rec.QUESTION_9_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_10_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_10_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_10_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_10_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_10_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_10_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_11_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_11_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_11_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_11_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_11_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_11_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_12_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_12_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_12_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_12_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_12_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_12_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_13_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_13_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_13_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_13_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_13_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_13_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_14_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_14_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_14_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_14_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_14_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_14_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_15_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_15_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_15_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_15_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_15_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_15_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_16_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_16_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_16_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_16_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_16_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_16_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_17_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_17_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_17_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_17_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_17_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_17_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_18_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_18_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_18_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_18_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_18_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_18_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_19_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_19_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_19_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_19_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_19_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_19_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_20_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_20_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_20_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_20_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_20_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_20_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_21_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_21_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_21_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_21_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_21_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_21_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_22_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_22_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_22_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_22_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_22_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_22_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_23_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_23_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_23_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_23_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_23_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_23_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_24_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_24_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_24_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_24_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_24_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_24_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_25_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_25_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_25_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_25_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_25_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_25_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_26_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_26_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_26_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_26_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_26_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_26_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_27_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_27_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_27_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_27_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_27_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_27_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_28_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_28_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_28_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_28_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_28_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_28_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_29_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_29_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_29_SIZE_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTION_29_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_29_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_29_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_30_NUMBER_TXT                     := l_css_int_data_rec.QUESTION_30_NUMBER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTIONS_30_SIZE_NUM                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.QUESTIONS_30_SIZE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.QUESTION_30_ANSWER_TXT                     := l_css_int_data_rec.QUESTION_30_ANSWER  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.R_S_EMAIL_ADDRESS_TXT                      := l_css_int_data_rec.R_S_EMAIL_ADDRESS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.EPS_CD                                     := l_css_int_data_rec.EPS_CODE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COMP_CSS_DEPENDCY_STATUS_TYPE              := l_css_int_data_rec.COMP_CSS_DEPENDENCY_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_AGE_NUM                                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_AGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMED_STU_YR_IN_COLL_TYPE                := l_css_int_data_rec.ASSUMED_STU_YR_IN_COLL  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.COMP_STU_MARITAL_STATUS_TYPE               := l_css_int_data_rec.COMP_STU_MARITAL_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_FAMILY_MEMBERS_NUM                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_FAMILY_MEMBERS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_FAM_MEMBERS_IN_COLLEGE_NUM             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_FAM_MEMBERS_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_MARITAL_STATUS_TYPE                    := l_css_int_data_rec.PAR_MARITAL_STATUS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_FAMILY_MEMBERS_NUM                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.PAR_FAMILY_MEMBERS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_TOTAL_IN_COLLEGE_NUM                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.PAR_TOTAL_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_PAR_IN_COLLEGE_NUM                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.PAR_PAR_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_OTHERS_IN_COLLEGE_NUM                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.PAR_OTHERS_IN_COLLEGE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_AESA_NUM                               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.PAR_AESA )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.PAR_CESA_NUM                               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.PAR_CESA )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_AESA_NUM                               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_AESA )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.STU_CESA_NUM                               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.STU_CESA )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_AGI_TAXABLE_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_UNTX_INC_AND_BEN_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_INC_ADJ_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_TOTAL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_US_INCOME_TAX_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_ST_AND_OTHER_TAX_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_ST_AND_OTHER_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_FICA_TAX_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_MED_DENTAL_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_MED_DENTAL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_EMPLOYMENT_ALLOW_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_ANNUAL_ED_SAVINGS_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_ANNUAL_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_INC_PROT_ALLOW_M_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_INC_PROT_ALLOW_M )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_TOTAL_INC_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_TOTAL_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_CAL_AVAIL_INC_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_CAL_AVAIL_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_AVAIL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_TOTAL_CONT_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_TOTAL_CONT_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_CASH_BANK_ACCOUNT_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_HOME_EQUITY_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_OT_RL_EST_INV_EQ_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_OT_RL_EST_INV_EQ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_ADJ_BUS_FARM_WRTH_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_ADJ_BUS_FARM_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_ASS_SIBS_PRE_TUI_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_ASS_SIBS_PRE_TUI )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_NET_WORTH_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_EMERG_RES_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_EMERG_RES_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_CUM_ED_SAVINGS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_CUM_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_LOW_INC_ALLOW_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_LOW_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_TOTAL_ASSET_ALLOW_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_TOTAL_ASSET_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_DISC_NET_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_TOTAL_CONT_ASSET_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_TOTAL_CONT_ASSET )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_TOTAL_CONT_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_TOTAL_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_NUM_IN_COLL_ADJ_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_NUM_IN_COLL_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_CONT_FOR_STU_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_CONT_FROM_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_BAS_CONT_FROM_ASSETS_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_BAS_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_AGI_TAX_INCOME_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_UNTX_INC_BEN_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_INC_ADJ_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_TOTAL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_US_INCOME_TAX_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_ST_AND_OTHER_TAX_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_ST_AND_OTHER_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_FICA_TAX_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_MED_DENTAL_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_MED_DENTAL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_ELEM_SEC_TUIT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_ELEM_SEC_TUIT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_EMPLOYMENT_ALLOW_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_ANNUAL_ED_SAVING_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_ANNUAL_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_INC_PROT_ALLOW_M_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_INC_PROT_ALLOW_M )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_TOTAL_INC_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_TOTAL_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_CAL_AVAIL_INC_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_CAL_AVAIL_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_AVAIL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_TOTAL_CONT_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_TOTAL_CONT_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_CASH_BANK_ACCNT_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_HOME_EQUITY_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_OT_RL_EST_INV_EQ_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_OT_RL_EST_INV_EQ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_ADJ_FARM_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_ADJ_BUS_FARM_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_ASS_SIBS_PRE_T_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_ASS_SIBS_PRE_T )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_NET_WORTH_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_EMERG_RES_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_EMERG_RES_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_CUM_ED_SAVINGS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_CUM_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_LOW_INC_ALLOW_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_LOW_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_TOTAL_ASSET_ALLOW_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_TOTAL_ASSET_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_DISC_NET_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_TOTAL_CONT_ASSET_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_TOTAL_CONT_ASSET )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_TOTAL_CONT_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_TOTAL_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_NUM_IN_COLL_ADJ_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_NUM_IN_COLL_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_CONT_FOR_STU_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_CONT_FROM_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_OPT_CONT_FROM_ASSETS_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_P_OPT_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_ANALYSIS_TYPE                         := l_css_int_data_rec.FM_P_ANALYSIS_TYPE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_AGI_TAXABLE_INCOME_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_UNTX_INC_AND_BEN_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_INC_ADJ_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_TOTAL_INCOME_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_US_INCOME_TAX_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_STATE_AND_OTHER_TAX_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_STATE_AND_OTHER_TAXES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_FICA_TAX_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_EMPLOYMENT_ALLOW_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_INCOME_PROT_ALLOW_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_INCOME_PROT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_TOTAL_ALLOW_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_TOTAL_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_AVAIL_INCOME_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_CASH_BANK_ACCOUNTS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_OT_RL_EST_INV_EQ_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_OT_RL_EST_INV_EQ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_ADJ_FARM_NET_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_ADJ_BUS_FARM_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_NET_WORTH_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_ASSET_PROT_ALLOW_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_ASSET_PROT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_DISC_NET_WORTH_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_TOTAL_CONTRIBUTION_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_TOTAL_CONTRIBUTION )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_NUM_IN_COLL_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_NUM_IN_COLL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_CONT_FOR_STU_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_CONT_FROM_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_P_CONT_FROM_ASSETS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_P_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_AGI_TAX_INCOME_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_UNTX_INC_AND_BEN_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_INC_ADJ_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TOTAL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_US_INCOME_TAX_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_ST_AND_OTH_TAX_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_ST_AND_OTH_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_FICA_TAX_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_MED_DENTAL_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_MED_DENTAL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_EMPLOYMENT_ALLOW_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_ANNUAL_ED_SAVINGS_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_ANNUAL_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_INC_PROT_ALLOW_M_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_INC_PROT_ALLOW_M )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TOTAL_INC_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TOTAL_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_CAL_AVAIL_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_CAL_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_AVAIL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TOTAL_CONT_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TOTAL_CONT_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_CASH_BANK_ACCOUNT_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_HOME_EQUITY_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_OT_RL_EST_INV_EQ_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_OT_RL_EST_INV_EQ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_ADJ_FARM_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_ADJ_BUS_FARM_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TRUSTS_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TRUSTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_NET_WORTH_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_EMERG_RES_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_EMERG_RES_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_CUM_ED_SAVINGS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_CUM_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TOTAL_ASSET_ALLOW_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TOTAL_ASSET_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_DISC_NET_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TOTAL_CONT_ASSET_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TOTAL_CONT_ASSET )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_TOTAL_CONT_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_TOTAL_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_NUM_IN_COLL_ADJ_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_NUM_IN_COLL_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_CONT_FOR_STU_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_CONT_FROM_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_BAS_CONT_FROM_ASSETS_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_BAS_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_AGI_TAX_INCOME_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_UNTX_INC_AND_BEN_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_INC_ADJ_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_TOTAL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_US_INCOME_TAX_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_ST_AND_OTH_TAX_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_ST_AND_OTH_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_FICA_TAX_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_MED_DENTAL_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_MED_DENTAL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_EMPLOYMENT_ALLOW_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_ANNUAL_ED_SAVINGS_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_ANNUAL_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_INC_PROT_ALLOW_M_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_INC_PROT_ALLOW_M )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_TOTAL_INC_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_TOTAL_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_CAL_AVAIL_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_CAL_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_AVAIL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_TOTAL_CONT_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_TOTAL_CONT_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_CASH_BANK_ACCOUNT_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_HOME_EQUITY_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_OT_RL_EST_INV_EQU_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_OT_RL_EST_INV_EQU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_ADJ_FARM_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_ADJ_BUS_FARM_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_EST_TRUSTS_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_EST_TRUSTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_NET_WORTH_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_EMERG_RES_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_EMERG_RES_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_CUM_ED_SAVINGS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_CUM_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_TOTAL_ASSET_ALLOW_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_TOTAL_ASSET_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_DISC_NET_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_TOTAL_CONT_ASSET_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_TOTAL_CONT_ASSET )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_TOTAL_CONT_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_TOTAL_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_NUM_IN_COLL_ADJ_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_NUM_IN_COLL_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_CONT_FOR_STU_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_CONT_FROM_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_EST_CONT_FROM_ASSETS_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_EST_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_AGI_TAX_INCOME_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_UNTX_INC_AND_BEN_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_INC_ADJ_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TOTAL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_US_INCOME_TAX_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_STATE_OTH_TAXES_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_STATE_AND_OTH_TAXES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_FICA_TAX_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_MED_DENTAL_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_MED_DENTAL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_EMPLOYMENT_ALLOW_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_ANNUAL_ED_SAVINGS_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_ANNUAL_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_INC_PROT_ALLOW_M_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_INC_PROT_ALLOW_M )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TOTAL_INC_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TOTAL_INC_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_CAL_AVAIL_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_CAL_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_AVAIL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TOTAL_CONT_INC_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TOTAL_CONT_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_CASH_BANK_ACCOUNT_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_IRA_KEOGH_ACCOUNT_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_IRA_KEOGH_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_HOME_EQUITY_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_OT_RL_EST_INV_EQ_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_OT_RL_EST_INV_EQ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_ADJ_BUS_FRM_WORTH_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_ADJ_BUS_FARM_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TRUSTS_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TRUSTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_NET_WORTH_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_EMERG_RES_ALLOW_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_EMERG_RES_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_CUM_ED_SAVINGS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_CUM_ED_SAVINGS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TOTAL_ASSET_ALLOW_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TOTAL_ASSET_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_DISC_NET_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TOTAL_CONT_ASSET_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TOTAL_CONT_ASSET )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_TOTAL_CONT_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_TOTAL_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_NUM_IN_COLL_ADJ_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_NUM_IN_COLL_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_CONT_FOR_STU_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_CONT_FROM_INCOME_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_S_OPT_CONT_FROM_ASSETS_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_S_OPT_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_ANALYSIS_TYPE                         := l_css_int_data_rec.FM_S_ANALYSIS_TYPE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_AGI_TAXABLE_INCOME_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_AGI_TAXABLE_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_UNTX_INC_AND_BEN_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_UNTX_INC_AND_BEN )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_INC_ADJ_AMT                           := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_INC_ADJ )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_TOTAL_INCOME_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_TOTAL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_US_INCOME_TAX_AMT                     := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_US_INCOME_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_STATE_AND_OTH_TAXES_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_STATE_AND_OTH_TAXES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_FICA_TAX_AMT                          := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_FICA_TAX )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_EMPLOYMENT_ALLOW_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_EMPLOYMENT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_INCOME_PROT_ALLOW_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_INCOME_PROT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_TOTAL_ALLOW_AMT                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_TOTAL_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_CAL_AVAIL_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_CAL_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_AVAIL_INCOME_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_AVAIL_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_CASH_BANK_ACCOUNTS_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_CASH_BANK_ACCOUNTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_OT_RL_EST_INV_EQUITY_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_OT_RL_EST_INV_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_ADJ_BUS_FARM_WORTH_AMT                := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_ADJ_BUS_FARM_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_TRUSTS_AMT                            := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_TRUSTS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_NET_WORTH_AMT                         := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_ASSET_PROT_ALLOW_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_ASSET_PROT_ALLOW )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_DISC_NET_WORTH_AMT                    := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_DISC_NET_WORTH )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_TOTAL_CONT_AMT                        := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_TOTAL_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_NUM_IN_COLL_NUM                       := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_NUM_IN_COLL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_CONT_FOR_STU_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_CONT_FOR_STU )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_CONT_FROM_INCOME_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_CONT_FROM_INCOME )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_S_CONT_FROM_ASSETS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FM_S_CONT_FROM_ASSETS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_RESIDENT_FLAG                      := l_css_int_data_rec.IM_INST_RESIDENT_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.INSTITUTIONAL_1_BUDGET_NAME                := l_css_int_data_rec.INSTITUTIONAL_1_BUDGET_NAME  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_BUDGET_DURATION_NUM              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_BUDGET_DURATION )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_TUITION_FEES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_TUITION_FEES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_BOOKS_SUPPLIES_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_BOOKS_SUPPLIES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_LIVING_EXPENSES_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_LIVING_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_TOT_EXPENSES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_TOT_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_TOT_STU_CONT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_TOT_STU_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_TOT_PAR_CONT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_TOT_PAR_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_TOT_FAMILY_CONT_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_TOT_FAMILY_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_VA_BENEFITS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_VA_BENEFITS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_OT_CONT_AMT                      := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_OT_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_1_EST_FINAN_NEED_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_1_EST_FINANCIAL_NEED )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.INSTITUTIONAL_2_BUDGET_TXT                 := l_css_int_data_rec.INSTITUTIONAL_2_BUDGET_NAME  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_BUDGET_DURATION_NUM              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_BUDGET_DURATION )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_TUITION_FEES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_TUITION_FEES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_BOOKS_SUPPLIES_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_BOOKS_SUPPLIES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_LIVING_EXPENSES_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_LIVING_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_TOT_EXPENSES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_TOT_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_TOT_STU_CONT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_TOT_STU_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_TOT_PAR_CONT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_TOT_PAR_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_TOT_FAMILY_CONT_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_TOT_FAMILY_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_VA_BENEFITS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_VA_BENEFITS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_2_EST_FINAN_NEED_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_2_EST_FINANCIAL_NEED )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.INSTITUTIONAL_3_BUDGET_TXT                 := l_css_int_data_rec.INSTITUTIONAL_3_BUDGET_NAME  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_BUDGET_DURATION_NUM              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_BUDGET_DURATION )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_TUITION_FEES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_TUITION_FEES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_BOOKS_SUPPLIES_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_BOOKS_SUPPLIES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_LIVING_EXPENSES_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_LIVING_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_TOT_EXPENSES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_TOT_EXPENSES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_TOT_STU_CONT_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_TOT_STU_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_TOT_FAMILY_CONT_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_TOT_FAMILY_CONT )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_VA_BENEFITS_AMT                  := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_VA_BENEFITS )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_INST_3_EST_FINAN_NEED_AMT               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.IM_INST_3_EST_FINANCIAL_NEED )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_INST_1_FEDERAL_EFC_TXT                  := l_css_int_data_rec.FM_INST_1_FEDERAL_EFC  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_INST_1_VA_BENEFITS_TXT                  := l_css_int_data_rec.FM_INST_1_VA_BENEFITS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_INST_1_FED_ELIGIBILITY_TXT              := l_css_int_data_rec.FM_INST_1_FED_ELIGIBILITY  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FM_INST_1_PELL_TXT                         := l_css_int_data_rec.FM_INST_1_PELL  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_LOSS_ALLOW_FLAG                 := l_css_int_data_rec.OPTION_PAR_LOSS_ALLOW_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_TUITION_FLAG                    := l_css_int_data_rec.OPTION_PAR_TUITION_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_HOME_TYPE                       := l_css_int_data_rec.OPTION_PAR_HOME_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_HOME_VALUE_TXT                  := l_css_int_data_rec.OPTION_PAR_HOME_VALUE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_HOME_DEBT_TXT                   := l_css_int_data_rec.OPTION_PAR_HOME_DEBT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_IRA_KEOGH_FLAG                  := l_css_int_data_rec.OPTION_STU_IRA_KEOGH_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_HOME_TYPE                       := l_css_int_data_rec.OPTION_STU_HOME_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_HOME_VALUE_TXT                  := l_css_int_data_rec.OPTION_STU_HOME_VALUE  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_HOME_DEBT_TXT                   := l_css_int_data_rec.OPTION_STU_HOME_DEBT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_SUM_AY_INC_FLAG                 := l_css_int_data_rec.OPTION_STU_SUM_AY_INC_IND  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_HOPE_LL_CREDIT_FLAG             := l_css_int_data_rec.OPTION_PAR_HOPE_LL_CREDIT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_HOPE_LL_CREDIT_FLAG             := l_css_int_data_rec.OPTION_STU_HOPE_LL_CREDIT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_PARENT_1_8_MONTHS_BAS_TXT               := l_css_int_data_rec.IM_PARENT_1_8_MONTHS_BAS  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_MORE_THAN_9_MTH_BA_TXT                := l_css_int_data_rec.IM_P_MORE_THAN_9_MTH_BA  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_PARENT_1_8_MONTHS_OPT_TXT               := l_css_int_data_rec.IM_PARENT_1_8_MONTHS_OPT  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.IM_P_MORE_THAN_9_MTH_OP_TXT                := l_css_int_data_rec.IM_P_MORE_THAN_9_MTH_OP  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_1_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_1  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_2_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_2  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_3_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_3  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_4_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_4  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_5_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_5  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_6_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_6  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_7_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_7  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_8_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_8  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_9_FLAG                        := l_css_int_data_rec.FNAR_MESSAGE_9  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_10_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_10  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_11_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_11  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_12_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_12  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_20_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_20  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_21_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_21  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_22_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_22  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_23_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_23  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_24_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_24  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_25_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_25  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_26_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_26  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_27_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_27  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_30_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_30  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_31_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_31  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_32_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_32  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_33_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_33  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_34_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_34  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_35_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_35  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_36_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_36  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_37_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_37  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_38_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_38  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_39_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_39  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_45_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_45  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_46_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_46  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_47_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_47  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_48_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_48  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_50_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_50  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_51_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_51  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_52_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_52  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_53_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_53  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_56_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_56  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_57_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_57  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_58_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_58  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_59_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_59  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_60_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_60  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_61_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_61  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_62_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_62  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_63_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_63  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_64_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_64  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_65_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_65  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_71_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_71  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_72_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_72  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_73_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_73  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_74_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_74  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_75_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_75  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_76_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_76  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_77_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_77  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_78_FLAG                       := l_css_int_data_rec.FNAR_MESSAGE_78  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_10_STU_FAM_MEM_NUM               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_10_STU_FAM_MEM )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_11_STU_NO_IN_COL_NUM             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_11_STU_NO_IN_COLL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_24_STU_AVAIL_INC_AMT             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_24_STU_AVAIL_INC )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_26_STU_TAXES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_26_STU_TAXES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_33_STU_HOME_VAL_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_33_STU_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_34_STU_HOME_VAL_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_34_STU_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_34_STU_HOME_EQU_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_34_STU_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_35_STU_HOME_VAL_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_35_STU_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_35_STU_HOME_EQU_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_35_STU_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_36_STU_HOME_EQU_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_36_STU_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_48_PAR_FAM_MEM_NUM               := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_48_PAR_FAM_MEM )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_49_PAR_NO_IN_COL_NUM             := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_49_PAR_NO_IN_COLL )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_56_PAR_AGI_AMT                   := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_56_PAR_AGI )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_62_PAR_TAXES_AMT                 := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_62_PAR_TAXES )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_73_PAR_HOME_VAL_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_73_PAR_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_74_PAR_HOME_VAL_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_74_PAR_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_74_PAR_HOME_EQU_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_74_PAR_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_75_PAR_HOME_VAL_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_75_PAR_HOME_VALUE )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_75_PAR_HOME_EQU_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_75_PAR_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESG_76_PAR_HOME_EQU_AMT              := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.FNAR_MESG_76_PAR_HOME_EQUITY )   ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMPTION_MESSAGE_1_FLAG                  := l_css_int_data_rec.ASSUMPTION_MESSAGE_1  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMPTION_MESSAGE_2_FLAG                  := l_css_int_data_rec.ASSUMPTION_MESSAGE_2  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMPTION_MESSAGE_3_FLAG                  := l_css_int_data_rec.ASSUMPTION_MESSAGE_3  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMPTION_MESSAGE_4_FLAG                  := l_css_int_data_rec.ASSUMPTION_MESSAGE_4  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMPTION_MESSAGE_5_FLAG                  := l_css_int_data_rec.ASSUMPTION_MESSAGE_5  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.ASSUMPTION_MESSAGE_6_FLAG                  := l_css_int_data_rec.ASSUMPTION_MESSAGE_6  ;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_49_FLAG := l_css_int_data_rec.FNAR_MESSAGE_49;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.FNAR_MESSAGE_55_FLAG := l_css_int_data_rec.FNAR_MESSAGE_55;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_COLA_ADJ_FLAG := l_css_int_data_rec.OPTION_PAR_COLA_ADJ_IND;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_STU_FA_ASSETS_FLAG := l_css_int_data_rec.OPTION_PAR_STU_FA_ASSETS_IND;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_IPT_ASSETS_FLAG := l_css_int_data_rec.OPTION_PAR_IPT_ASSETS_IND;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_STU_IPT_ASSETS_FLAG := l_css_int_data_rec.OPTION_STU_IPT_ASSETS_IND;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.OPTION_PAR_COLA_ADJ_VALUE := l_css_int_data_rec.OPTION_PAR_COLA_ADJ_VALUE;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.option_ind_stu_ipt_assets_flag := l_css_int_data_rec.option_ind_stu_ipt_assets_flag;
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.p_soc_sec_ben_student_amt := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.p_soc_sec_ben_student_amt);
    l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.p_tuit_fee_deduct_amt := IGF_AP_MATCHING_PROCESS_PKG.convert_to_number(l_css_int_data_rec.p_tuit_fee_deduct_amt);
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.stu_lives_with_num := l_css_int_data_rec.stu_lives_with_num;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.stu_most_support_from_num := l_css_int_data_rec.stu_most_support_from_num;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.location_computer_num := l_css_int_data_rec.location_computer_num;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_parent_cont_adj_num := l_css_int_data_rec.cust_parent_cont_adj_num;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.custodial_parent_num := l_css_int_data_rec.custodial_parent_num;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_base_prcnt_inc_amt := l_css_int_data_rec.cust_par_base_prcnt_inc_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_base_cont_inc_amt := l_css_int_data_rec.cust_par_base_cont_inc_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_base_cont_ast_amt := l_css_int_data_rec.cust_par_base_cont_ast_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_base_tot_cont_amt := l_css_int_data_rec.cust_par_base_tot_cont_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_opt_prcnt_inc_amt := l_css_int_data_rec.cust_par_opt_prcnt_inc_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_opt_cont_inc_amt := l_css_int_data_rec.cust_par_opt_cont_inc_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_opt_cont_ast_amt := l_css_int_data_rec.cust_par_opt_cont_ast_amt;
        l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.cust_par_opt_tot_cont_amt := l_css_int_data_rec.cust_par_opt_tot_cont_amt;
            l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.parents_email_txt := l_css_int_data_rec.parents_email_txt;
            l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.parent_1_birth_date := l_css_int_data_rec.parent_1_birth_date;
            l_field_debug := l_field_debug + 1 ;
    c_int_data_rec.parent_2_birth_date := l_css_int_data_rec.parent_2_birth_date;

  EXCEPTION WHEN OTHERS THEN
    l_debug_str := l_debug_str || ' Error while Swapping fields in p_convert_rec - Value of l_field_debug >' || TO_CHAR(l_field_debug) || ' ' ;
    RETURN ;
  END p_convert_rec;

  FUNCTION convert_to_number( pv_org_number IN VARCHAR2 )
  RETURN NUMBER
  IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :        Converts the valid number to into the NUMBER format else RETURN NULL.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */
  ld_number NUMBER;
  BEGIN
      ld_number := TO_NUMBER( pv_org_number);
      RETURN ld_number;
  EXCEPTION
      WHEN others THEN
        RETURN NULL;
  END convert_to_number;

  PROCEDURE css_insert_row( c_int_data_rec     IN c_int_data%ROWTYPE,
                          p_base_id            IN  NUMBER,
                          p_cssp_id            OUT NOCOPY NUMBER) AS
     /*
     ||  Created By : rasahoo
     ||  Created On : 03-June-2003
     ||  Purpose : insert into the isir matched table
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who             When            What
     ||  (reverse chronological order - newest change first)
     */

       l_rowid   VARCHAR2(30);
       l_cssp_id NUMBER;

  BEGIN
    l_rowid:= NULL;
    l_cssp_id := NULL;

    igf_ap_css_profile_pkg.insert_row(
      x_mode                              => 'R',
      x_rowid                             => l_rowid,
      x_cssp_id                           => l_cssp_id,
      x_base_id                           => p_base_id,
      x_system_record_type                => 'ORIGINAL',
      x_active_profile                    => 'N',
      x_college_code                      =>c_int_data_rec.college_cd                             ,
      x_academic_year                     =>c_int_data_rec.academic_year_txt                      ,
      x_stu_record_type                   =>c_int_data_rec.stu_record_type                        ,
      x_css_id_number                     =>c_int_data_rec.css_id_number_txt                      ,
      x_registration_receipt_date         =>TO_CHAR(c_int_data_rec.registration_receipt_date,'MMDDYYYY')              , -- NULL, --
      x_registration_type                 =>c_int_data_rec.registration_type                      , --NULL, --
      x_application_receipt_date          =>TO_CHAR(c_int_data_rec.application_receipt_date,'MMDDYYYY')               , --NULL
      x_application_type                  =>c_int_data_rec.application_type                       ,
      x_original_fnar_compute             =>c_int_data_rec.original_fnar_compute_txt              ,
      x_revision_fnar_compute_date        =>TO_CHAR(c_int_data_rec.revision_fnar_compute_date,'MMDDYYYY')             , --NULL, --
      x_electronic_extract_date           =>TO_CHAR(c_int_data_rec.electronic_extract_date,'MMDDYYYY')                , --NULL, --
      x_institutional_reporting_type      =>c_int_data_rec.instit_reporting_type                  ,
      x_asr_receipt_date                  =>TO_CHAR(c_int_data_rec.asr_receipt_date,'MMDDYYYY')  ,
      x_last_name                         =>c_int_data_rec.last_name                              ,
      x_first_name                        =>c_int_data_rec.first_name                             ,
      x_middle_initial                    =>c_int_data_rec.middle_initial_txt                     ,
      x_address_number_and_street         =>c_int_data_rec.address_number_and_street_txt          ,
      x_city                              =>c_int_data_rec.city_txt                               ,
      x_state_mailing                     =>c_int_data_rec.state_mailing_txt                      ,
      x_zip_code                          =>c_int_data_rec.zip_cd                                 ,
      x_s_telephone_number                =>c_int_data_rec.s_telephone_number_txt                 ,
      x_s_title                           =>c_int_data_rec.s_title_type                           ,
      x_date_of_birth                     =>c_int_data_rec.birth_date                             ,
      x_social_security_number            =>convert_to_number(c_int_data_rec.social_security_num)                    ,
      x_state_legal_residence             =>c_int_data_rec.state_legal_residence_txt              ,
      x_foreign_address_indicator         =>c_int_data_rec.foreign_address_flag                   ,
      x_foreign_postal_code               =>c_int_data_rec.foreign_postal_cd                      ,
      x_country                           =>c_int_data_rec.country_cd                             ,
      x_financial_aid_status              =>c_int_data_rec.financial_aid_status_type              ,
      x_year_in_college                   =>c_int_data_rec.year_in_college_type                   ,
      x_marital_status                    =>c_int_data_rec.marital_status_flag                    ,
      x_ward_court                        =>c_int_data_rec.ward_court_flag                        ,
      x_legal_dependents_other            =>c_int_data_rec.legal_dependents_other_flag            ,
      x_household_size                    =>c_int_data_rec.household_size_num                     ,
      x_number_in_college                 =>c_int_data_rec.number_in_college_num                  ,
      x_citizenship_status                =>c_int_data_rec.citizenship_status_type                ,
      x_citizenship_country               =>c_int_data_rec.citizenship_country_cd                 ,
      x_visa_classification               =>c_int_data_rec.visa_classification_type               ,
      x_tax_figures                       =>c_int_data_rec.tax_figures_type                       ,
      x_number_exemptions                 =>convert_to_number(c_int_data_rec.number_exemptions_txt)                  ,
      x_adjusted_gross_inc                =>c_int_data_rec.adjusted_gross_amt                     ,
      x_us_tax_paid                       =>c_int_data_rec.us_tax_paid_amt                        ,
      x_itemized_deductions               =>c_int_data_rec.itemized_deductions_amt                ,
      x_stu_income_work                   =>c_int_data_rec.stu_income_work_amt                    ,
      x_spouse_income_work                =>c_int_data_rec.spouse_income_work_amt                 ,
      x_divid_int_inc                     =>c_int_data_rec.divid_int_income_amt                   ,
      x_soc_sec_benefits                  =>c_int_data_rec.soc_sec_benefits_amt                   ,
      x_welfare_tanf                      =>c_int_data_rec.welfare_tanf_amt                       ,
      x_child_supp_rcvd                   =>c_int_data_rec.child_supp_rcvd_amt                    ,
      x_earned_income_credit              =>c_int_data_rec.earned_income_credit_amt               ,
      x_other_untax_income                =>c_int_data_rec.other_untax_income_amt                 ,
      x_tax_stu_aid                       =>c_int_data_rec.tax_stu_aid_amt                        ,
      x_cash_sav_check                    =>c_int_data_rec.cash_sav_check_amt                     ,
      x_ira_keogh                         =>c_int_data_rec.ira_keogh_amt                          ,
      x_invest_value                      =>c_int_data_rec.invest_value_amt                       ,
      x_invest_debt                       =>c_int_data_rec.invest_debt_amt                        ,
      x_home_value                        =>c_int_data_rec.home_value_amt                         ,
      x_home_debt                         =>c_int_data_rec.home_debt_amt                          ,
      x_oth_real_value                    =>c_int_data_rec.oth_real_value_amt                     ,
      x_oth_real_debt                     =>c_int_data_rec.oth_real_debt_amt                      ,
      x_bus_farm_value                    =>c_int_data_rec.bus_farm_value_amt                     ,
      x_bus_farm_debt                     =>c_int_data_rec.bus_farm_debt_amt                      ,
      x_live_on_farm                      =>c_int_data_rec.live_on_farm_flag                      ,
      x_home_purch_price                  =>c_int_data_rec.home_purch_price_amt                   ,
      x_hope_ll_credit                    =>c_int_data_rec.hope_ll_credit_amt                     ,
      x_home_purch_year                   =>c_int_data_rec.home_purch_year_txt                    ,
      x_trust_amount                      =>convert_to_number(c_int_data_rec.trust_amount_txt)                       ,
      x_trust_avail                       =>c_int_data_rec.trust_avail_flag                       ,
      x_trust_estab                       =>c_int_data_rec.trust_estab_flag                       ,
      x_child_support_paid                =>convert_to_number(c_int_data_rec.child_support_paid_txt)                 ,
      x_med_dent_expenses                 =>convert_to_number(c_int_data_rec.med_dent_expenses_txt)                  ,
      x_vet_us                            =>c_int_data_rec.vet_us_flag                            ,
      x_vet_ben_amount                    =>c_int_data_rec.vet_ben_amt                            ,
      x_vet_ben_months                    =>c_int_data_rec.vet_ben_months_num                     ,
      x_stu_summer_wages                  =>c_int_data_rec.stu_summer_wages_amt                   ,
      x_stu_school_yr_wages               =>c_int_data_rec.stu_school_yr_wages_amt                ,
      x_spouse_summer_wages               =>c_int_data_rec.spouse_summer_wages_amt                ,
      x_spouse_school_yr_wages            =>c_int_data_rec.spouse_school_yr_wages_amt             ,
      x_summer_other_tax_inc              =>c_int_data_rec.summer_other_tax_inc_amt               ,
      x_school_yr_other_tax_inc           =>c_int_data_rec.school_yr_other_tax_inc_amt            ,
      x_summer_untax_inc                  =>c_int_data_rec.summer_untax_inc_amt                   ,
      x_school_yr_untax_inc               =>c_int_data_rec.school_yr_untax_inc_amt                ,
      x_grants_schol_etc                  =>c_int_data_rec.grants_schol_etc_amt                   ,
      x_tuit_benefits                     =>c_int_data_rec.tuit_benefits_amt                      ,
      x_cont_parents                      =>c_int_data_rec.cont_parents_amt                       ,
      x_cont_relatives                    =>c_int_data_rec.cont_relatives_amt                     ,
      x_p_siblings_pre_tuit               =>c_int_data_rec.p_siblings_pre_tuit_amt                ,
      x_p_student_pre_tuit                =>c_int_data_rec.p_student_pre_tuit_amt                 ,
      x_p_household_size                  =>c_int_data_rec.p_household_size_num                   ,
      x_p_number_in_college               =>c_int_data_rec.p_in_college_num                       ,
      x_p_parents_in_college              =>c_int_data_rec.p_parents_in_college_num               ,
      x_p_marital_status                  =>c_int_data_rec.p_marital_status_type                  ,
      x_p_state_legal_residence           =>c_int_data_rec.p_state_legal_residence_cd             ,
      x_p_natural_par_status              =>c_int_data_rec.p_natural_par_status_flag              ,
      x_p_child_supp_paid                 =>c_int_data_rec.p_child_supp_paid_amt                  ,
      x_p_repay_ed_loans                  =>c_int_data_rec.p_repay_ed_loans_amt                   ,
      x_p_med_dent_expenses               =>c_int_data_rec.p_med_dent_expenses_amt                ,
      x_p_tuit_paid_amount                =>c_int_data_rec.p_tuit_paid_amt                        ,
      x_p_tuit_paid_number                =>c_int_data_rec.p_tuit_paid_num                        ,
      x_p_exp_child_supp_paid             =>c_int_data_rec.p_exp_child_supp_paid_amt              ,
      x_p_exp_repay_ed_loans              =>c_int_data_rec.p_exp_repay_ed_loans_amt               ,
      x_p_exp_med_dent_expenses           =>c_int_data_rec.p_exp_med_dent_expenses_amt            ,
      x_p_exp_tuit_pd_amount              =>c_int_data_rec.p_exp_tuit_pd_amt                      ,
      x_p_exp_tuit_pd_number              =>c_int_data_rec.p_exp_tuit_pd_num                      ,
      x_p_cash_sav_check                  =>c_int_data_rec.p_cash_sav_check_amt                   ,
      x_p_month_mortgage_pay              =>c_int_data_rec.p_month_mortgage_pay_amt               ,
      x_p_invest_value                    =>c_int_data_rec.p_invest_value_amt                     ,
      x_p_invest_debt                     =>c_int_data_rec.p_invest_debt_amt                      ,
      x_p_home_value                      =>c_int_data_rec.p_home_value_amt                       ,
      x_p_home_debt                       =>c_int_data_rec.p_home_debt_amt                        ,
      x_p_home_purch_price                =>c_int_data_rec.p_home_purch_price_amt                 ,
      x_p_own_business_farm               =>c_int_data_rec.p_own_business_farm_flag               ,
      x_p_business_value                  =>c_int_data_rec.p_business_value_amt                   ,
      x_p_business_debt                   =>c_int_data_rec.p_business_debt_amt                    ,
      x_p_farm_value                      =>c_int_data_rec.p_farm_value_amt                       ,
      x_p_farm_debt                       =>c_int_data_rec.p_farm_debt_amt                        ,
      x_p_live_on_farm                    =>c_int_data_rec.p_live_on_farm_num                     ,
      x_p_oth_real_estate_value           =>c_int_data_rec.p_oth_real_estate_value_amt            ,
      x_p_oth_real_estate_debt            =>c_int_data_rec.p_oth_real_estate_debt_amt             ,
      x_p_oth_real_purch_price            =>c_int_data_rec.p_oth_real_purch_price_amt             ,
      x_p_siblings_assets                 =>c_int_data_rec.p_siblings_assets_amt                  ,
      x_p_home_purch_year                 =>c_int_data_rec.p_home_purch_year_txt                  ,
      x_p_oth_real_purch_year             =>c_int_data_rec.p_oth_real_purch_year_txt              ,
      x_p_prior_agi                       =>c_int_data_rec.p_prior_agi_amt                        ,
      x_p_prior_us_tax_paid               =>c_int_data_rec.p_prior_us_tax_paid_amt                ,
      x_p_prior_item_deductions           =>c_int_data_rec.p_prior_item_deductions_amt            ,
      x_p_prior_other_untax_inc           =>c_int_data_rec.p_prior_other_untax_inc_amt            ,
      x_p_tax_figures                     =>c_int_data_rec.p_tax_figures_num                      ,
      x_p_number_exemptions               =>c_int_data_rec.p_number_exemptions_num                ,
      x_p_adjusted_gross_inc              =>c_int_data_rec.p_adjusted_gross_inc_amt               ,
      x_p_wages_sal_tips                  =>c_int_data_rec.p_wages_sal_tips_amt                   ,
      x_p_interest_income                 =>c_int_data_rec.p_interest_income_amt                  ,
      x_p_dividend_income                 =>c_int_data_rec.p_dividend_income_amt                  ,
      x_p_net_inc_bus_farm                =>c_int_data_rec.p_net_inc_bus_farm_amt                 ,
      x_p_other_taxable_income            =>c_int_data_rec.p_other_taxable_income_amt             ,
      x_p_adj_to_income                   =>c_int_data_rec.p_adj_to_income_amt                    ,
      x_p_us_tax_paid                     =>c_int_data_rec.p_us_tax_paid_amt                      ,
      x_p_itemized_deductions             =>c_int_data_rec.p_itemized_deductions_amt              ,
      x_p_father_income_work              =>c_int_data_rec.p_father_income_work_amt               ,
      x_p_mother_income_work              =>c_int_data_rec.p_mother_income_work_amt               ,
      x_p_soc_sec_ben                     =>c_int_data_rec.p_soc_sec_ben_amt                      ,
      x_p_welfare_tanf                    =>c_int_data_rec.p_welfare_tanf_amt                     ,
      x_p_child_supp_rcvd                 =>c_int_data_rec.p_child_supp_rcvd_amt                  ,
      x_p_ded_ira_keogh                   =>c_int_data_rec.p_ded_ira_keogh_amt                    ,
      x_p_tax_defer_pens_savs             =>c_int_data_rec.p_tax_defer_pens_savs_amt              ,
      x_p_dep_care_med_spending           =>c_int_data_rec.p_dep_care_med_spending_amt            ,
      x_p_earned_income_credit            =>c_int_data_rec.p_earned_income_credit_amt             ,
      x_p_living_allow                    =>c_int_data_rec.p_living_allow_amt                     ,
      x_p_tax_exmpt_int                   =>c_int_data_rec.p_tax_exmpt_int_amt                    ,
      x_p_foreign_inc_excl                =>c_int_data_rec.p_foreign_inc_excl_amt                 ,
      x_p_other_untax_inc                 =>c_int_data_rec.p_other_untax_inc_amt                  ,
      x_p_hope_ll_credit                  =>c_int_data_rec.p_hope_ll_credit_amt                   ,
      x_p_yr_separation                   =>c_int_data_rec.p_yr_separation_amt                    ,
      x_p_yr_divorce                      =>c_int_data_rec.p_yr_divorce_amt                       ,
      x_p_exp_father_inc                  =>c_int_data_rec.p_exp_father_inc_amt                   ,
      x_p_exp_mother_inc                  =>c_int_data_rec.p_exp_mother_inc_amt                   ,
      x_p_exp_other_tax_inc               =>c_int_data_rec.p_exp_other_tax_inc_amt                ,
      x_p_exp_other_untax_inc             =>c_int_data_rec.p_exp_other_untax_inc_amt              ,
      x_line_2_relation                   =>c_int_data_rec.line_2_relation_type                   ,
      x_line_2_attend_college             =>c_int_data_rec.line_2_attend_college_type             ,
      x_line_3_relation                   =>c_int_data_rec.line_3_relation_type                   ,
      x_line_3_attend_college             =>c_int_data_rec.line_3_attend_college_type             ,
      x_line_4_relation                   =>c_int_data_rec.line_4_relation_type                   ,
      x_line_4_attend_college             =>c_int_data_rec.line_4_attend_college_type             ,
      x_line_5_relation                   =>c_int_data_rec.line_5_relation_type                   ,
      x_line_5_attend_college             =>c_int_data_rec.line_5_attend_college_type             ,
      x_line_6_relation                   =>c_int_data_rec.line_6_relation_type                   ,
      x_line_6_attend_college             =>c_int_data_rec.line_6_attend_college_type             ,
      x_line_7_relation                   =>c_int_data_rec.line_7_relation_type                   ,
      x_line_7_attend_college             =>c_int_data_rec.line_7_attend_college_type             ,
      x_line_8_relation                   =>c_int_data_rec.line_8_relation_type                   ,
      x_line_8_attend_college             =>c_int_data_rec.line_8_attend_college_type             ,
      x_p_age_father                      =>convert_to_number(c_int_data_rec.p_age_father_num)                       ,
      x_p_age_mother                      =>convert_to_number(c_int_data_rec.p_age_mother_num)                       ,
      x_p_div_sep_ind                     =>c_int_data_rec.p_div_sep_flag                         ,
      x_b_cont_non_custodial_par          =>c_int_data_rec.b_cont_non_custodial_par_txt           ,
      x_college_type_2                    =>c_int_data_rec.college_2_type                         ,
      x_college_type_3                    =>c_int_data_rec.college_3_type                         ,
      x_college_type_4                    =>c_int_data_rec.college_4_type                         ,
      x_college_type_5                    =>c_int_data_rec.college_5_type                         ,
      x_college_type_6                    =>c_int_data_rec.college_6_type                         ,
      x_college_type_7                    =>c_int_data_rec.college_7_type                         ,
      x_college_type_8                    =>c_int_data_rec.college_8_type                         ,
      x_school_code_1                     =>c_int_data_rec.school_1_cd                            ,
      x_housing_code_1                    =>c_int_data_rec.housing_1_type                         ,
      x_school_code_2                     =>c_int_data_rec.school_2_cd                            ,
      x_housing_code_2                    =>c_int_data_rec.housing_2_type                         ,
      x_school_code_3                     =>c_int_data_rec.school_3_cd                            ,
      x_housing_code_3                    =>c_int_data_rec.housing_3_type                         ,
      x_school_code_4                     =>c_int_data_rec.school_4_cd                            ,
      x_housing_code_4                    =>c_int_data_rec.housing_4_type                         ,
      x_school_code_5                     =>c_int_data_rec.school_5_cd                            ,
      x_housing_code_5                    =>c_int_data_rec.housing_5_type                         ,
      x_school_code_6                     =>c_int_data_rec.school_6_cd                            ,
      x_housing_code_6                    =>c_int_data_rec.housing_6_type                         ,
      x_school_code_7                     =>c_int_data_rec.school_7_cd                            ,
      x_housing_code_7                    =>c_int_data_rec.housing_7_type                         ,
      x_school_code_8                     =>c_int_data_rec.school_8_cd                            ,
      x_housing_code_8                    =>c_int_data_rec.housing_8_type                         ,
      x_school_code_9                     =>c_int_data_rec.school_9_cd                            ,
      x_housing_code_9                    =>c_int_data_rec.housing_9_type                         ,
      x_school_code_10                    =>c_int_data_rec.school_10_cd                           ,
      x_housing_code_10                   =>c_int_data_rec.housing_10_type                        ,
      x_additional_school_code_1          =>c_int_data_rec.additional_school_1_cd                 ,
      x_additional_school_code_2          =>c_int_data_rec.additional_school_2_cd                 ,
      x_additional_school_code_3          =>c_int_data_rec.additional_school_3_cd                 ,
      x_additional_school_code_4          =>c_int_data_rec.additional_school_4_cd                 ,
      x_additional_school_code_5          =>c_int_data_rec.additional_school_5_cd                 ,
      x_additional_school_code_6          =>c_int_data_rec.additional_school_6_cd                 ,
      x_additional_school_code_7          =>c_int_data_rec.additional_school_7_cd                 ,
      x_additional_school_code_8          =>c_int_data_rec.additional_school_8_cd                 ,
      x_additional_school_code_9          =>c_int_data_rec.additional_school_9_cd                 ,
      x_additional_school_code_10         =>c_int_data_rec.additional_school_10_cd                ,
      x_explanation_spec_circum           =>c_int_data_rec.explanation_spec_circum_flag           ,
      x_signature_student                 =>c_int_data_rec.signature_student_flag                 ,
      x_signature_spouse                  =>c_int_data_rec.signature_spouse_flag                  ,
      x_signature_father                  =>c_int_data_rec.signature_father_flag                  ,
      x_signature_mother                  =>c_int_data_rec.signature_mother_flag                  ,
      x_month_day_completed               =>c_int_data_rec.month_day_completed                    ,
      x_year_completed                    =>c_int_data_rec.year_completed_flag                    ,
      x_age_line_2                        =>c_int_data_rec.age_line_2_num                         ,
      x_age_line_3                        =>c_int_data_rec.age_line_3_num                         ,
      x_age_line_4                        =>c_int_data_rec.age_line_4_num                         ,
      x_age_line_5                        =>c_int_data_rec.age_line_5_num                         ,
      x_age_line_6                        =>c_int_data_rec.age_line_6_num                         ,
      x_age_line_7                        =>c_int_data_rec.age_line_7_num                         ,
      x_age_line_8                        =>c_int_data_rec.age_line_8_num                         ,
      x_a_online_signature                =>c_int_data_rec.a_online_signature_flag                ,
      x_question_1_number                 =>c_int_data_rec.question_1_number_txt                  ,
      x_question_1_size                   =>c_int_data_rec.question_1_size_num                    ,
      x_question_1_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_1_answer_txt)                  ,
      x_question_2_number                 =>c_int_data_rec.question_2_number_txt                  ,
      x_question_2_size                   =>c_int_data_rec.question_2_size_num                    ,
      x_question_2_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_2_answer_txt)                  ,
      x_question_3_number                 =>c_int_data_rec.question_3_number_txt                  ,
      x_question_3_size                   =>c_int_data_rec.question_3_size_num                    ,
      x_question_3_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_3_answer_txt)                  ,
      x_question_4_number                 =>c_int_data_rec.question_4_number_txt                  ,
      x_question_4_size                   =>c_int_data_rec.question_4_size_num                    ,
      x_question_4_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_4_answer_txt)                  ,
      x_question_5_number                 =>c_int_data_rec.question_5_number_txt                  ,
      x_question_5_size                   =>c_int_data_rec.question_5_size_num                    ,
      x_question_5_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_5_answer_txt)                  ,
      x_question_6_number                 =>c_int_data_rec.question_6_number_txt                  ,
      x_question_6_size                   =>c_int_data_rec.question_6_size_num                    ,
      x_question_6_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_6_answer_txt)                  ,
      x_question_7_number                 =>c_int_data_rec.question_7_number_txt                  ,
      x_question_7_size                   =>c_int_data_rec.question_7_size_num                    ,
      x_question_7_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_7_answer_txt)                  ,
      x_question_8_number                 =>c_int_data_rec.question_8_number_txt                  ,
      x_question_8_size                   =>c_int_data_rec.question_8_size_num                    ,
      x_question_8_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_8_answer_txt)                  ,
      x_question_9_number                 =>c_int_data_rec.question_9_number_txt                  ,
      x_question_9_size                   =>c_int_data_rec.question_9_size_num                    ,
      x_question_9_answer                 =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_9_answer_txt)                  ,
      x_question_10_number                =>c_int_data_rec.question_10_number_txt                 ,
      x_question_10_size                  =>c_int_data_rec.question_10_size_num                   ,
      x_question_10_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_10_answer_txt)                 ,
      x_question_11_number                =>c_int_data_rec.question_11_number_txt                 ,
      x_question_11_size                  =>c_int_data_rec.question_11_size_num                   ,
      x_question_11_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_11_answer_txt)                 ,
      x_question_12_number                =>c_int_data_rec.question_12_number_txt                 ,
      x_question_12_size                  =>c_int_data_rec.question_12_size_num                   ,
      x_question_12_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_12_answer_txt)                 ,
      x_question_13_number                =>c_int_data_rec.question_13_number_txt                 ,
      x_question_13_size                  =>c_int_data_rec.question_13_size_num                   ,
      x_question_13_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_13_answer_txt)                 ,
      x_question_14_number                =>c_int_data_rec.question_14_number_txt                 ,
      x_question_14_size                  =>c_int_data_rec.question_14_size_num                   ,
      x_question_14_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_14_answer_txt)                 ,
      x_question_15_number                =>c_int_data_rec.question_15_number_txt                 ,
      x_question_15_size                  =>c_int_data_rec.question_15_size_num                   ,
      x_question_15_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_15_answer_txt)                 ,
      x_question_16_number                =>c_int_data_rec.question_16_number_txt                 ,
      x_question_16_size                  =>c_int_data_rec.question_16_size_num                   ,
      x_question_16_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_16_answer_txt)                 ,
      x_question_17_number                =>c_int_data_rec.question_17_number_txt                 ,
      x_question_17_size                  =>c_int_data_rec.question_17_size_num                   ,
      x_question_17_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_17_answer_txt)                 ,
      x_question_18_number                =>c_int_data_rec.question_18_number_txt                 ,
      x_question_18_size                  =>c_int_data_rec.question_18_size_num                   ,
      x_question_18_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_18_answer_txt)                 ,
      x_question_19_number                =>c_int_data_rec.question_19_number_txt                 ,
      x_question_19_size                  =>c_int_data_rec.question_19_size_num                   ,
      x_question_19_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_19_answer_txt)                 ,
      x_question_20_number                =>c_int_data_rec.question_20_number_txt                 ,
      x_question_20_size                  =>c_int_data_rec.question_20_size_num                   ,
      x_question_20_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_20_answer_txt)                 ,
      x_question_21_number                =>c_int_data_rec.question_21_number_txt                 ,
      x_question_21_size                  =>c_int_data_rec.question_21_size_num                   ,
      x_question_21_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_21_answer_txt)                 ,
      x_question_22_number                =>c_int_data_rec.question_22_number_txt                 ,
      x_question_22_size                  =>c_int_data_rec.question_22_size_num                   ,
      x_question_22_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_22_answer_txt)                 ,
      x_question_23_number                =>c_int_data_rec.question_23_number_txt                 ,
      x_question_23_size                  =>c_int_data_rec.question_23_size_num                   ,
      x_question_23_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_23_answer_txt)                 ,
      x_question_24_number                =>c_int_data_rec.question_24_number_txt                 ,
      x_question_24_size                  =>c_int_data_rec.question_24_size_num                   ,
      x_question_24_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_24_answer_txt)                 ,
      x_question_25_number                =>c_int_data_rec.question_25_number_txt                 ,
      x_question_25_size                  =>c_int_data_rec.question_25_size_num                   ,
      x_question_25_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_25_answer_txt)                 ,
      x_question_26_number                =>c_int_data_rec.question_26_number_txt                 ,
      x_question_26_size                  =>c_int_data_rec.question_26_size_num                   ,
      x_question_26_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_26_answer_txt)                 ,
      x_question_27_number                =>c_int_data_rec.question_27_number_txt                 ,
      x_question_27_size                  =>c_int_data_rec.question_27_size_num                   ,
      x_question_27_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_27_answer_txt)                 ,
      x_question_28_number                =>c_int_data_rec.question_28_number_txt                 ,
      x_question_28_size                  =>c_int_data_rec.question_28_size_num                   ,
      x_question_28_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_28_answer_txt)                 ,
      x_question_29_number                =>c_int_data_rec.question_29_number_txt                 ,
      x_question_29_size                  =>c_int_data_rec.question_29_size_num                   ,
      x_question_29_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_29_answer_txt)                 ,
      x_question_30_number                =>c_int_data_rec.question_30_number_txt                 ,
      x_questions_30_size                 =>c_int_data_rec.questions_30_size_num                  ,
      x_question_30_answer                =>igf_ap_profile_matching_pkg.convert_int(c_int_data_rec.question_30_answer_txt)                 ,
      x_legacy_record_flag                => 'Y',
      x_coa_duration_efc_amt              => NULL,
      x_coa_duration_num                  => NULL,
      x_p_soc_sec_ben_student_amt         => c_int_data_rec.p_soc_sec_ben_student_amt,
      x_p_tuit_fee_deduct_amt             => c_int_data_rec.p_tuit_fee_deduct_amt,
      x_stu_lives_with_num                => c_int_data_rec.stu_lives_with_num,
      x_stu_most_support_from_num         => c_int_data_rec.stu_most_support_from_num,
      x_location_computer_num             => c_int_data_rec.location_computer_num
      );
    p_cssp_id := l_cssp_id;
  END  css_insert_row;

  PROCEDURE fnar_insert_row(c_int_data_rec    IN c_int_data%ROWTYPE,
                            p_cssp_id         IN  NUMBER)AS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : Insert  NSLDS data
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    l_rowid        VARCHAR2(30);
    ln_fnar_id     NUMBER;
   BEGIN
     l_rowid := NULL;
     ln_fnar_id := NULL;
     igf_ap_css_fnar_pkg.insert_row (
     x_mode                              => 'R',
     x_rowid                             => l_rowid,
     x_fnar_id                           => ln_fnar_id,
     x_cssp_id                           => p_cssp_id,
     x_r_s_email_address                 =>c_int_data_rec.r_s_email_address_txt                  ,
     x_eps_code                          =>c_int_data_rec.eps_cd                                 ,
     x_comp_css_dependency_status        =>c_int_data_rec.comp_css_dependcy_status_type          ,
     x_stu_age                           =>c_int_data_rec.stu_age_num                            ,
     x_assumed_stu_yr_in_coll            =>c_int_data_rec.assumed_stu_yr_in_coll_type            ,
     x_comp_stu_marital_status           =>c_int_data_rec.comp_stu_marital_status_type           ,
     x_stu_family_members                =>c_int_data_rec.stu_family_members_num                 ,
     x_stu_fam_members_in_college        =>c_int_data_rec.stu_fam_members_in_college_num         ,
     x_par_marital_status                =>c_int_data_rec.par_marital_status_type                ,
     x_par_family_members                =>c_int_data_rec.par_family_members_num                 ,
     x_par_total_in_college              =>c_int_data_rec.par_total_in_college_num               ,
     x_par_par_in_college                =>c_int_data_rec.par_par_in_college_num                 ,
     x_par_others_in_college             =>c_int_data_rec.par_others_in_college_num              ,
     x_par_aesa                          =>c_int_data_rec.par_aesa_num                           ,
     x_par_cesa                          =>c_int_data_rec.par_cesa_num                           ,
     x_stu_aesa                          =>c_int_data_rec.stu_aesa_num                           ,
     x_stu_cesa                          =>c_int_data_rec.stu_cesa_num                           ,
     x_im_p_bas_agi_taxable_income       =>c_int_data_rec.im_p_bas_agi_taxable_amt               ,
     x_im_p_bas_untx_inc_and_ben         =>c_int_data_rec.im_p_bas_untx_inc_and_ben_amt          ,
     x_im_p_bas_inc_adj                  =>c_int_data_rec.im_p_bas_inc_adj_amt                   ,
     x_im_p_bas_total_income             =>c_int_data_rec.im_p_bas_total_income_amt              ,
     x_im_p_bas_us_income_tax            =>c_int_data_rec.im_p_bas_us_income_tax_amt             ,
     x_im_p_bas_st_and_other_tax         =>c_int_data_rec.im_p_bas_st_and_other_tax_amt          ,
     x_im_p_bas_fica_tax                 =>c_int_data_rec.im_p_bas_fica_tax_amt                  ,
     x_im_p_bas_med_dental               =>c_int_data_rec.im_p_bas_med_dental_amt                ,
     x_im_p_bas_employment_allow         =>c_int_data_rec.im_p_bas_employment_allow_amt          ,
     x_im_p_bas_annual_ed_savings        =>c_int_data_rec.im_p_bas_annual_ed_savings_amt         ,
     x_im_p_bas_inc_prot_allow_m         =>c_int_data_rec.im_p_bas_inc_prot_allow_m_amt          ,
     x_im_p_bas_total_inc_allow          =>c_int_data_rec.im_p_bas_total_inc_allow_amt           ,
     x_im_p_bas_cal_avail_inc            =>c_int_data_rec.im_p_bas_cal_avail_inc_amt             ,
     x_im_p_bas_avail_income             =>c_int_data_rec.im_p_bas_avail_income_amt              ,
     x_im_p_bas_total_cont_inc           =>c_int_data_rec.im_p_bas_total_cont_inc_amt            ,
     x_im_p_bas_cash_bank_accounts       =>c_int_data_rec.im_p_bas_cash_bank_account_amt         ,
     x_im_p_bas_home_equity              =>c_int_data_rec.im_p_bas_home_equity_amt               ,
     x_im_p_bas_ot_rl_est_inv_eq         =>c_int_data_rec.im_p_bas_ot_rl_est_inv_eq_amt          ,
     x_im_p_bas_adj_bus_farm_worth       =>c_int_data_rec.im_p_bas_adj_bus_farm_wrth_amt         ,
     x_im_p_bas_ass_sibs_pre_tui         =>c_int_data_rec.im_p_bas_ass_sibs_pre_tui_amt          ,
     x_im_p_bas_net_worth                =>c_int_data_rec.im_p_bas_net_worth_amt                 ,
     x_im_p_bas_emerg_res_allow          =>c_int_data_rec.im_p_bas_emerg_res_allow_amt           ,
     x_im_p_bas_cum_ed_savings           =>c_int_data_rec.im_p_bas_cum_ed_savings_amt            ,
     x_im_p_bas_low_inc_allow            =>c_int_data_rec.im_p_bas_low_inc_allow_amt             ,
     x_im_p_bas_total_asset_allow        =>c_int_data_rec.im_p_bas_total_asset_allow_amt         ,
     x_im_p_bas_disc_net_worth           =>c_int_data_rec.im_p_bas_disc_net_worth_amt            ,
     x_im_p_bas_total_cont_asset         =>c_int_data_rec.im_p_bas_total_cont_asset_amt          ,
     x_im_p_bas_total_cont               =>c_int_data_rec.im_p_bas_total_cont_amt                ,
     x_im_p_bas_num_in_coll_adj          =>c_int_data_rec.im_p_bas_num_in_coll_adj_amt           ,
     x_im_p_bas_cont_for_stu             =>c_int_data_rec.im_p_bas_cont_for_stu_amt              ,
     x_im_p_bas_cont_from_income         =>c_int_data_rec.im_p_bas_cont_from_income_amt          ,
     x_im_p_bas_cont_from_assets         =>c_int_data_rec.im_p_bas_cont_from_assets_amt          ,
     x_im_p_opt_agi_taxable_income       =>c_int_data_rec.im_p_opt_agi_tax_income_amt            ,
     x_im_p_opt_untx_inc_and_ben         =>c_int_data_rec.im_p_opt_untx_inc_ben_amt              ,
     x_im_p_opt_inc_adj                  =>c_int_data_rec.im_p_opt_inc_adj_amt                   ,
     x_im_p_opt_total_income             =>c_int_data_rec.im_p_opt_total_income_amt              ,
     x_im_p_opt_us_income_tax            =>c_int_data_rec.im_p_opt_us_income_tax_amt             ,
     x_im_p_opt_st_and_other_tax         =>c_int_data_rec.im_p_opt_st_and_other_tax_amt          ,
     x_im_p_opt_fica_tax                 =>c_int_data_rec.im_p_opt_fica_tax_amt                  ,
     x_im_p_opt_med_dental               =>c_int_data_rec.im_p_opt_med_dental_amt                ,
     x_im_p_opt_elem_sec_tuit            =>c_int_data_rec.im_p_opt_elem_sec_tuit_amt             ,
     x_im_p_opt_employment_allow         =>c_int_data_rec.im_p_opt_employment_allow_amt          ,
     x_im_p_opt_annual_ed_savings        =>c_int_data_rec.im_p_opt_annual_ed_saving_amt          ,
     x_im_p_opt_inc_prot_allow_m         =>c_int_data_rec.im_p_opt_inc_prot_allow_m_amt          ,
     x_im_p_opt_total_inc_allow          =>c_int_data_rec.im_p_opt_total_inc_allow_amt           ,
     x_im_p_opt_cal_avail_inc            =>c_int_data_rec.im_p_opt_cal_avail_inc_amt             ,
     x_im_p_opt_avail_income             =>c_int_data_rec.im_p_opt_avail_income_amt              ,
     x_im_p_opt_total_cont_inc           =>c_int_data_rec.im_p_opt_total_cont_inc_amt            ,
     x_im_p_opt_cash_bank_accounts       =>c_int_data_rec.im_p_opt_cash_bank_accnt_amt           ,
     x_im_p_opt_home_equity              =>c_int_data_rec.im_p_opt_home_equity_amt               ,
     x_im_p_opt_ot_rl_est_inv_eq         =>c_int_data_rec.im_p_opt_ot_rl_est_inv_eq_amt          ,
     x_im_p_opt_adj_bus_farm_worth       =>c_int_data_rec.im_p_opt_adj_farm_worth_amt            ,
     x_im_p_opt_ass_sibs_pre_tui         =>c_int_data_rec.im_p_opt_ass_sibs_pre_t_amt            ,
     x_im_p_opt_net_worth                =>c_int_data_rec.im_p_opt_net_worth_amt                 ,
     x_im_p_opt_emerg_res_allow          =>c_int_data_rec.im_p_opt_emerg_res_allow_amt           ,
     x_im_p_opt_cum_ed_savings           =>c_int_data_rec.im_p_opt_cum_ed_savings_amt            ,
     x_im_p_opt_low_inc_allow            =>c_int_data_rec.im_p_opt_low_inc_allow_amt             ,
     x_im_p_opt_total_asset_allow        =>c_int_data_rec.im_p_opt_total_asset_allow_amt         ,
     x_im_p_opt_disc_net_worth           =>c_int_data_rec.im_p_opt_disc_net_worth_amt            ,
     x_im_p_opt_total_cont_asset         =>c_int_data_rec.im_p_opt_total_cont_asset_amt          ,
     x_im_p_opt_total_cont               =>c_int_data_rec.im_p_opt_total_cont_amt                ,
     x_im_p_opt_num_in_coll_adj          =>c_int_data_rec.im_p_opt_num_in_coll_adj_amt           ,
     x_im_p_opt_cont_for_stu             =>c_int_data_rec.im_p_opt_cont_for_stu_amt              ,
     x_im_p_opt_cont_from_income         =>c_int_data_rec.im_p_opt_cont_from_income_amt          ,
     x_im_p_opt_cont_from_assets         =>c_int_data_rec.im_p_opt_cont_from_assets_amt          ,
     x_fm_p_analysis_type                =>c_int_data_rec.fm_p_analysis_type                     ,
     x_fm_p_agi_taxable_income           =>c_int_data_rec.fm_p_agi_taxable_income_amt            ,
     x_fm_p_untx_inc_and_ben             =>c_int_data_rec.fm_p_untx_inc_and_ben_amt              ,
     x_fm_p_inc_adj                      =>c_int_data_rec.fm_p_inc_adj_amt                       ,
     x_fm_p_total_income                 =>c_int_data_rec.fm_p_total_income_amt                  ,
     x_fm_p_us_income_tax                =>c_int_data_rec.fm_p_us_income_tax_amt                 ,
     x_fm_p_state_and_other_taxes        =>c_int_data_rec.fm_p_state_and_other_tax_amt           ,
     x_fm_p_fica_tax                     =>c_int_data_rec.fm_p_fica_tax_amt                      ,
     x_fm_p_employment_allow             =>c_int_data_rec.fm_p_employment_allow_amt              ,
     x_fm_p_income_prot_allow            =>c_int_data_rec.fm_p_income_prot_allow_amt             ,
     x_fm_p_total_allow                  =>c_int_data_rec.fm_p_total_allow_amt                   ,
     x_fm_p_avail_income                 =>c_int_data_rec.fm_p_avail_income_amt                  ,
     x_fm_p_cash_bank_accounts           =>c_int_data_rec.fm_p_cash_bank_accounts_amt            ,
     x_fm_p_ot_rl_est_inv_equity         =>c_int_data_rec.fm_p_ot_rl_est_inv_eq_amt              ,
     x_fm_p_adj_bus_farm_net_worth       =>c_int_data_rec.fm_p_adj_farm_net_worth_amt            ,
     x_fm_p_net_worth                    =>c_int_data_rec.fm_p_net_worth_amt                     ,
     x_fm_p_asset_prot_allow             =>c_int_data_rec.fm_p_asset_prot_allow_amt              ,
     x_fm_p_disc_net_worth               =>c_int_data_rec.fm_p_disc_net_worth_amt                ,
     x_fm_p_total_contribution           =>c_int_data_rec.fm_p_total_contribution_amt            ,
     x_fm_p_num_in_coll                  =>c_int_data_rec.fm_p_num_in_coll_num                   ,
     x_fm_p_cont_for_stu                 =>c_int_data_rec.fm_p_cont_for_stu_amt                  ,
     x_fm_p_cont_from_income             =>c_int_data_rec.fm_p_cont_from_income_amt              ,
     x_fm_p_cont_from_assets             =>c_int_data_rec.fm_p_cont_from_assets_amt              ,
     x_im_s_bas_agi_taxable_income       =>c_int_data_rec.im_s_bas_agi_tax_income_amt            ,
     x_im_s_bas_untx_inc_and_ben         =>c_int_data_rec.im_s_bas_untx_inc_and_ben_amt          ,
     x_im_s_bas_inc_adj                  =>c_int_data_rec.im_s_bas_inc_adj_amt                   ,
     x_im_s_bas_total_income             =>c_int_data_rec.im_s_bas_total_income_amt              ,
     x_im_s_bas_us_income_tax            =>c_int_data_rec.im_s_bas_us_income_tax_amt             ,
     x_im_s_bas_state_and_oth_taxes      =>c_int_data_rec.im_s_bas_st_and_oth_tax_amt            ,
     x_im_s_bas_fica_tax                 =>c_int_data_rec.im_s_bas_fica_tax_amt                  ,
     x_im_s_bas_med_dental               =>c_int_data_rec.im_s_bas_med_dental_amt                ,
     x_im_s_bas_employment_allow         =>c_int_data_rec.im_s_bas_employment_allow_amt          ,
     x_im_s_bas_annual_ed_savings        =>c_int_data_rec.im_s_bas_annual_ed_savings_amt         ,
     x_im_s_bas_inc_prot_allow_m         =>c_int_data_rec.im_s_bas_inc_prot_allow_m_amt          ,
     x_im_s_bas_total_inc_allow          =>c_int_data_rec.im_s_bas_total_inc_allow_amt           ,
     x_im_s_bas_cal_avail_income         =>c_int_data_rec.im_s_bas_cal_avail_income_amt          ,
     x_im_s_bas_avail_income             =>c_int_data_rec.im_s_bas_avail_income_amt              ,
     x_im_s_bas_total_cont_inc           =>c_int_data_rec.im_s_bas_total_cont_inc_amt            ,
     x_im_s_bas_cash_bank_accounts       =>c_int_data_rec.im_s_bas_cash_bank_account_amt         ,
     x_im_s_bas_home_equity              =>c_int_data_rec.im_s_bas_home_equity_amt               ,
     x_im_s_bas_ot_rl_est_inv_eq         =>c_int_data_rec.im_s_bas_ot_rl_est_inv_eq_amt          ,
     x_im_s_bas_adj_busfarm_worth        =>c_int_data_rec.im_s_bas_adj_farm_worth_amt            ,
     x_im_s_bas_trusts                   =>c_int_data_rec.im_s_bas_trusts_amt                    ,
     x_im_s_bas_net_worth                =>c_int_data_rec.im_s_bas_net_worth_amt                 ,
     x_im_s_bas_emerg_res_allow          =>c_int_data_rec.im_s_bas_emerg_res_allow_amt           ,
     x_im_s_bas_cum_ed_savings           =>c_int_data_rec.im_s_bas_cum_ed_savings_amt            ,
     x_im_s_bas_total_asset_allow        =>c_int_data_rec.im_s_bas_total_asset_allow_amt         ,
     x_im_s_bas_disc_net_worth           =>c_int_data_rec.im_s_bas_disc_net_worth_amt            ,
     x_im_s_bas_total_cont_asset         =>c_int_data_rec.im_s_bas_total_cont_asset_amt          ,
     x_im_s_bas_total_cont               =>c_int_data_rec.im_s_bas_total_cont_amt                ,
     x_im_s_bas_num_in_coll_adj          =>c_int_data_rec.im_s_bas_num_in_coll_adj_amt           ,
     x_im_s_bas_cont_for_stu             =>c_int_data_rec.im_s_bas_cont_for_stu_amt              ,
     x_im_s_bas_cont_from_income         =>c_int_data_rec.im_s_bas_cont_from_income_amt          ,
     x_im_s_bas_cont_from_assets         =>c_int_data_rec.im_s_bas_cont_from_assets_amt          ,
     x_im_s_est_agitaxable_income        =>c_int_data_rec.im_s_est_agi_tax_income_amt            ,
     x_im_s_est_untx_inc_and_ben         =>c_int_data_rec.im_s_est_untx_inc_and_ben_amt          ,
     x_im_s_est_inc_adj                  =>c_int_data_rec.im_s_est_inc_adj_amt                   ,
     x_im_s_est_total_income             =>c_int_data_rec.im_s_est_total_income_amt              ,
     x_im_s_est_us_income_tax            =>c_int_data_rec.im_s_est_us_income_tax_amt             ,
     x_im_s_est_state_and_oth_taxes      =>c_int_data_rec.im_s_est_st_and_oth_tax_amt            ,
     x_im_s_est_fica_tax                 =>c_int_data_rec.im_s_est_fica_tax_amt                  ,
     x_im_s_est_med_dental               =>c_int_data_rec.im_s_est_med_dental_amt                ,
     x_im_s_est_employment_allow         =>c_int_data_rec.im_s_est_employment_allow_amt          ,
     x_im_s_est_annual_ed_savings        =>c_int_data_rec.im_s_est_annual_ed_savings_amt         ,
     x_im_s_est_inc_prot_allow_m         =>c_int_data_rec.im_s_est_inc_prot_allow_m_amt          ,
     x_im_s_est_total_inc_allow          =>c_int_data_rec.im_s_est_total_inc_allow_amt           ,
     x_im_s_est_cal_avail_income         =>c_int_data_rec.im_s_est_cal_avail_income_amt          ,
     x_im_s_est_avail_income             =>c_int_data_rec.im_s_est_avail_income_amt              ,
     x_im_s_est_total_cont_inc           =>c_int_data_rec.im_s_est_total_cont_inc_amt            ,
     x_im_s_est_cash_bank_accounts       =>c_int_data_rec.im_s_est_cash_bank_account_amt         ,
     x_im_s_est_home_equity              =>c_int_data_rec.im_s_est_home_equity_amt               ,
     x_im_s_est_ot_rl_est_inv_eq         =>c_int_data_rec.im_s_est_ot_rl_est_inv_equ_amt         ,
     x_im_s_est_adj_bus_farm_worth       =>c_int_data_rec.im_s_est_adj_farm_worth_amt            ,
     x_im_s_est_est_trusts               =>c_int_data_rec.im_s_est_est_trusts_amt                ,
     x_im_s_est_net_worth                =>c_int_data_rec.im_s_est_net_worth_amt                 ,
     x_im_s_est_emerg_res_allow          =>c_int_data_rec.im_s_est_emerg_res_allow_amt           ,
     x_im_s_est_cum_ed_savings           =>c_int_data_rec.im_s_est_cum_ed_savings_amt            ,
     x_im_s_est_total_asset_allow        =>c_int_data_rec.im_s_est_total_asset_allow_amt         ,
     x_im_s_est_disc_net_worth           =>c_int_data_rec.im_s_est_disc_net_worth_amt            ,
     x_im_s_est_total_cont_asset         =>c_int_data_rec.im_s_est_total_cont_asset_amt          ,
     x_im_s_est_total_cont               =>c_int_data_rec.im_s_est_total_cont_amt                ,
     x_im_s_est_num_in_coll_adj          =>c_int_data_rec.im_s_est_num_in_coll_adj_amt           ,
     x_im_s_est_cont_for_stu             =>c_int_data_rec.im_s_est_cont_for_stu_amt              ,
     x_im_s_est_cont_from_income         =>c_int_data_rec.im_s_est_cont_from_income_amt          ,
     x_im_s_est_cont_from_assets         =>c_int_data_rec.im_s_est_cont_from_assets_amt          ,
     x_im_s_opt_agi_taxable_income       =>c_int_data_rec.im_s_opt_agi_tax_income_amt            ,
     x_im_s_opt_untx_inc_and_ben         =>c_int_data_rec.im_s_opt_untx_inc_and_ben_amt          ,
     x_im_s_opt_inc_adj                  =>c_int_data_rec.im_s_opt_inc_adj_amt                   ,
     x_im_s_opt_total_income             =>c_int_data_rec.im_s_opt_total_income_amt              ,
     x_im_s_opt_us_income_tax            =>c_int_data_rec.im_s_opt_us_income_tax_amt             ,
     x_im_s_opt_state_and_oth_taxes      =>c_int_data_rec.im_s_opt_state_oth_taxes_amt           ,
     x_im_s_opt_fica_tax                 =>c_int_data_rec.im_s_opt_fica_tax_amt                  ,
     x_im_s_opt_med_dental               =>c_int_data_rec.im_s_opt_med_dental_amt                ,
     x_im_s_opt_employment_allow         =>c_int_data_rec.im_s_opt_employment_allow_amt          ,
     x_im_s_opt_annual_ed_savings        =>c_int_data_rec.im_s_opt_annual_ed_savings_amt         ,
     x_im_s_opt_inc_prot_allow_m         =>c_int_data_rec.im_s_opt_inc_prot_allow_m_amt          ,
     x_im_s_opt_total_inc_allow          =>c_int_data_rec.im_s_opt_total_inc_allow_amt           ,
     x_im_s_opt_cal_avail_income         =>c_int_data_rec.im_s_opt_cal_avail_income_amt          ,
     x_im_s_opt_avail_income             =>c_int_data_rec.im_s_opt_avail_income_amt              ,
     x_im_s_opt_total_cont_inc           =>c_int_data_rec.im_s_opt_total_cont_inc_amt            ,
     x_im_s_opt_cash_bank_accounts       =>c_int_data_rec.im_s_opt_cash_bank_account_amt         ,
     x_im_s_opt_ira_keogh_accounts       =>c_int_data_rec.im_s_opt_ira_keogh_account_amt         ,
     x_im_s_opt_home_equity              =>c_int_data_rec.im_s_opt_home_equity_amt               ,
     x_im_s_opt_ot_rl_est_inv_eq         =>c_int_data_rec.im_s_opt_ot_rl_est_inv_eq_amt          ,
     x_im_s_opt_adj_bus_farm_worth       =>c_int_data_rec.im_s_opt_adj_bus_frm_worth_amt         ,
     x_im_s_opt_trusts                   =>c_int_data_rec.im_s_opt_trusts_amt                    ,
     x_im_s_opt_net_worth                =>c_int_data_rec.im_s_opt_net_worth_amt                 ,
     x_im_s_opt_emerg_res_allow          =>c_int_data_rec.im_s_opt_emerg_res_allow_amt           ,
     x_im_s_opt_cum_ed_savings           =>c_int_data_rec.im_s_opt_cum_ed_savings_amt            ,
     x_im_s_opt_total_asset_allow        =>c_int_data_rec.im_s_opt_total_asset_allow_amt         ,
     x_im_s_opt_disc_net_worth           =>c_int_data_rec.im_s_opt_disc_net_worth_amt            ,
     x_im_s_opt_total_cont_asset         =>c_int_data_rec.im_s_opt_total_cont_asset_amt          ,
     x_im_s_opt_total_cont               =>c_int_data_rec.im_s_opt_total_cont_amt                ,
     x_im_s_opt_num_in_coll_adj          =>c_int_data_rec.im_s_opt_num_in_coll_adj_amt           ,
     x_im_s_opt_cont_for_stu             =>c_int_data_rec.im_s_opt_cont_for_stu_amt              ,
     x_im_s_opt_cont_from_income         =>c_int_data_rec.im_s_opt_cont_from_income_amt          ,
     x_im_s_opt_cont_from_assets         =>c_int_data_rec.im_s_opt_cont_from_assets_amt          ,
     x_fm_s_analysis_type                =>c_int_data_rec.fm_s_analysis_type                     ,
     x_fm_s_agi_taxable_income           =>c_int_data_rec.fm_s_agi_taxable_income_amt            ,
     x_fm_s_untx_inc_and_ben             =>c_int_data_rec.fm_s_untx_inc_and_ben_amt              ,
     x_fm_s_inc_adj                      =>c_int_data_rec.fm_s_inc_adj_amt                       ,
     x_fm_s_total_income                 =>c_int_data_rec.fm_s_total_income_amt                  ,
     x_fm_s_us_income_tax                =>c_int_data_rec.fm_s_us_income_tax_amt                 ,
     x_fm_s_state_and_oth_taxes          =>c_int_data_rec.fm_s_state_and_oth_taxes_amt           ,
     x_fm_s_fica_tax                     =>c_int_data_rec.fm_s_fica_tax_amt                      ,
     x_fm_s_employment_allow             =>c_int_data_rec.fm_s_employment_allow_amt              ,
     x_fm_s_income_prot_allow            =>c_int_data_rec.fm_s_income_prot_allow_amt             ,
     x_fm_s_total_allow                  =>c_int_data_rec.fm_s_total_allow_amt                   ,
     x_fm_s_cal_avail_income             =>c_int_data_rec.fm_s_cal_avail_income_amt              ,
     x_fm_s_avail_income                 =>c_int_data_rec.fm_s_avail_income_amt                  ,
     x_fm_s_cash_bank_accounts           =>c_int_data_rec.fm_s_cash_bank_accounts_amt            ,
     x_fm_s_ot_rl_est_inv_equity         =>c_int_data_rec.fm_s_ot_rl_est_inv_equity_amt          ,
     x_fm_s_adj_bus_farm_worth           =>c_int_data_rec.fm_s_adj_bus_farm_worth_amt            ,
     x_fm_s_trusts                       =>c_int_data_rec.fm_s_trusts_amt                        ,
     x_fm_s_net_worth                    =>c_int_data_rec.fm_s_net_worth_amt                     ,
     x_fm_s_asset_prot_allow             =>c_int_data_rec.fm_s_asset_prot_allow_amt              ,
     x_fm_s_disc_net_worth               =>c_int_data_rec.fm_s_disc_net_worth_amt                ,
     x_fm_s_total_cont                   =>c_int_data_rec.fm_s_total_cont_amt                    ,
     x_fm_s_num_in_coll                  =>c_int_data_rec.fm_s_num_in_coll_num                   ,
     x_fm_s_cont_for_stu                 =>c_int_data_rec.fm_s_cont_for_stu_amt                  ,
     x_fm_s_cont_from_income             =>c_int_data_rec.fm_s_cont_from_income_amt              ,
     x_fm_s_cont_from_assets             =>c_int_data_rec.fm_s_cont_from_assets_amt              ,
     x_im_inst_resident_ind              =>c_int_data_rec.im_inst_resident_flag                  ,
     x_institutional_1_budget_name       =>c_int_data_rec.institutional_1_budget_name            ,
     x_im_inst_1_budget_duration         =>c_int_data_rec.im_inst_1_budget_duration_num          ,
     x_im_inst_1_tuition_fees            =>c_int_data_rec.im_inst_1_tuition_fees_amt             ,
     x_im_inst_1_books_supplies          =>c_int_data_rec.im_inst_1_books_supplies_amt           ,
     x_im_inst_1_living_expenses         =>c_int_data_rec.im_inst_1_living_expenses_amt          ,
     x_im_inst_1_tot_expenses            =>c_int_data_rec.im_inst_1_tot_expenses_amt             ,
     x_im_inst_1_tot_stu_cont            =>c_int_data_rec.im_inst_1_tot_stu_cont_amt ,
     x_im_inst_1_tot_par_cont            =>c_int_data_rec.im_inst_1_tot_par_cont_amt             ,
     x_im_inst_1_tot_family_cont         =>c_int_data_rec.im_inst_1_tot_family_cont_amt          ,
     x_im_inst_1_va_benefits             =>c_int_data_rec.im_inst_1_va_benefits_amt              ,
     x_im_inst_1_ot_cont                 =>c_int_data_rec.im_inst_1_ot_cont_amt                  ,
     x_im_inst_1_est_financial_need      =>c_int_data_rec.im_inst_1_est_finan_need_amt           ,
     x_institutional_2_budget_name       =>c_int_data_rec.institutional_2_budget_txt             ,
     x_im_inst_2_budget_duration         =>c_int_data_rec.im_inst_2_budget_duration_num          ,
     x_im_inst_2_tuition_fees            =>c_int_data_rec.im_inst_2_tuition_fees_amt             ,
     x_im_inst_2_books_supplies          =>c_int_data_rec.im_inst_2_books_supplies_amt           ,
     x_im_inst_2_living_expenses         =>c_int_data_rec.im_inst_2_living_expenses_amt          ,
     x_im_inst_2_tot_expenses            =>c_int_data_rec.im_inst_2_tot_expenses_amt             ,
     x_im_inst_2_tot_stu_cont            =>c_int_data_rec.im_inst_2_tot_stu_cont_amt             ,
     x_im_inst_2_tot_par_cont            =>c_int_data_rec.im_inst_2_tot_par_cont_amt             ,
     x_im_inst_2_tot_family_cont         =>c_int_data_rec.im_inst_2_tot_family_cont_amt          ,
     x_im_inst_2_va_benefits             =>c_int_data_rec.im_inst_2_va_benefits_amt              ,
     x_im_inst_2_est_financial_need      =>c_int_data_rec.im_inst_2_est_finan_need_amt           ,
     x_institutional_3_budget_name       =>c_int_data_rec.institutional_3_budget_txt             ,
     x_im_inst_3_budget_duration         =>c_int_data_rec.im_inst_3_budget_duration_num          ,
     x_im_inst_3_tuition_fees            =>c_int_data_rec.im_inst_3_tuition_fees_amt             ,
     x_im_inst_3_books_supplies          =>c_int_data_rec.im_inst_3_books_supplies_amt           ,
     x_im_inst_3_living_expenses         =>c_int_data_rec.im_inst_3_living_expenses_amt          ,
     x_im_inst_3_tot_expenses            =>c_int_data_rec.im_inst_3_tot_expenses_amt             ,
     x_im_inst_3_tot_stu_cont            =>c_int_data_rec.im_inst_3_tot_stu_cont_amt,
     x_im_inst_3_tot_par_cont            =>c_int_data_rec.im_inst_3_tot_par_cont_amt ,
     x_im_inst_3_tot_family_cont         =>c_int_data_rec.im_inst_3_tot_family_cont_amt          ,
     x_im_inst_3_va_benefits             =>c_int_data_rec.im_inst_3_va_benefits_amt              ,
     x_im_inst_3_est_financial_need      =>c_int_data_rec.im_inst_3_est_finan_need_amt           ,
     x_fm_inst_1_federal_efc             =>c_int_data_rec.fm_inst_1_federal_efc_txt              ,
     x_fm_inst_1_va_benefits             =>c_int_data_rec.fm_inst_1_va_benefits_txt              ,
     x_fm_inst_1_fed_eligibility         =>c_int_data_rec.fm_inst_1_fed_eligibility_txt          ,
     x_fm_inst_1_pell                    =>c_int_data_rec.fm_inst_1_pell_txt                     ,
     x_option_par_loss_allow_ind         =>c_int_data_rec.option_par_loss_allow_flag             ,
     x_option_par_tuition_ind            =>c_int_data_rec.option_par_tuition_flag                ,
     x_option_par_home_ind               =>c_int_data_rec.option_par_home_type                   ,
     x_option_par_home_value             =>c_int_data_rec.option_par_home_value_txt              ,
     x_option_par_home_debt              =>c_int_data_rec.option_par_home_debt_txt               ,
     x_option_stu_ira_keogh_ind          =>c_int_data_rec.option_stu_ira_keogh_flag              ,
     x_option_stu_home_ind               =>c_int_data_rec.option_stu_home_type                   ,
     x_option_stu_home_value             =>c_int_data_rec.option_stu_home_value_txt              ,
     x_option_stu_home_debt              =>c_int_data_rec.option_stu_home_debt_txt               ,
     x_option_stu_sum_ay_inc_ind         =>c_int_data_rec.option_stu_sum_ay_inc_flag             ,
     x_option_par_hope_ll_credit         =>c_int_data_rec.option_par_hope_ll_credit_flag         ,
     x_option_stu_hope_ll_credit         =>c_int_data_rec.option_stu_hope_ll_credit_flag         ,
     x_im_parent_1_8_months_bas          =>c_int_data_rec.im_parent_1_8_months_bas_txt           ,
     x_im_p_more_than_9_mth_ba           =>c_int_data_rec.im_p_more_than_9_mth_ba_txt            ,
     x_im_parent_1_8_months_opt          =>c_int_data_rec.im_parent_1_8_months_opt_txt           ,
     x_im_p_more_than_9_mth_op           =>c_int_data_rec.im_p_more_than_9_mth_op_txt            ,
     x_fnar_message_1                    =>c_int_data_rec.fnar_message_1_flag                    ,
     x_fnar_message_2                    =>c_int_data_rec.fnar_message_2_flag                    ,
     x_fnar_message_3                    =>c_int_data_rec.fnar_message_3_flag                    ,
     x_fnar_message_4                    =>c_int_data_rec.fnar_message_4_flag                    ,
     x_fnar_message_5                    =>c_int_data_rec.fnar_message_5_flag                    ,
     x_fnar_message_6                    =>c_int_data_rec.fnar_message_6_flag                    ,
     x_fnar_message_7                    =>c_int_data_rec.fnar_message_7_flag                    ,
     x_fnar_message_8                    =>c_int_data_rec.fnar_message_8_flag                    ,
     x_fnar_message_9                    =>c_int_data_rec.fnar_message_9_flag                    ,
     x_fnar_message_10                   =>c_int_data_rec.fnar_message_10_flag                   ,
     x_fnar_message_11                   =>c_int_data_rec.fnar_message_11_flag                   ,
     x_fnar_message_12                   =>c_int_data_rec.fnar_message_12_flag ,
     x_fnar_message_13                   =>c_int_data_rec.fnar_message_13_flag,
     x_fnar_message_20                   =>c_int_data_rec.fnar_message_20_flag                   ,
     x_fnar_message_21                   =>c_int_data_rec.fnar_message_21_flag                   ,
     x_fnar_message_22                   =>c_int_data_rec.fnar_message_22_flag                   ,
     x_fnar_message_23                   =>c_int_data_rec.fnar_message_23_flag                   ,
     x_fnar_message_24                   =>c_int_data_rec.fnar_message_24_flag                   ,
     x_fnar_message_25                   =>c_int_data_rec.fnar_message_25_flag                   ,
     x_fnar_message_26                   =>c_int_data_rec.fnar_message_26_flag                   ,
     x_fnar_message_27                   =>c_int_data_rec.fnar_message_27_flag                   ,
     x_fnar_message_30                   =>c_int_data_rec.fnar_message_30_flag                   ,
     x_fnar_message_31                   =>c_int_data_rec.fnar_message_31_flag                   ,
     x_fnar_message_32                   =>c_int_data_rec.fnar_message_32_flag                   ,
     x_fnar_message_33                   =>c_int_data_rec.fnar_message_33_flag                   ,
     x_fnar_message_34                   =>c_int_data_rec.fnar_message_34_flag                   ,
     x_fnar_message_35                   =>c_int_data_rec.fnar_message_35_flag                   ,
     x_fnar_message_36                   =>c_int_data_rec.fnar_message_36_flag                   ,
     x_fnar_message_37                   =>c_int_data_rec.fnar_message_37_flag                   ,
     x_fnar_message_38                   =>c_int_data_rec.fnar_message_38_flag                   ,
     x_fnar_message_39                   =>c_int_data_rec.fnar_message_39_flag                   ,
     x_fnar_message_45                   =>c_int_data_rec.fnar_message_45_flag                   ,
     x_fnar_message_46                   =>c_int_data_rec.fnar_message_46_flag                   ,
     x_fnar_message_47                   =>c_int_data_rec.fnar_message_47_flag                   ,
     x_fnar_message_48                   =>c_int_data_rec.fnar_message_48_flag                   ,
     x_fnar_message_50                   =>c_int_data_rec.fnar_message_50_flag                   ,
     x_fnar_message_51                   =>c_int_data_rec.fnar_message_51_flag                   ,
     x_fnar_message_52                   =>c_int_data_rec.fnar_message_52_flag                   ,
     x_fnar_message_53                   =>NULL                                                  ,
     x_fnar_message_56                   =>c_int_data_rec.fnar_message_56_flag                   ,
     x_fnar_message_57                   =>c_int_data_rec.fnar_message_57_flag                   ,
     x_fnar_message_58                   =>c_int_data_rec.fnar_message_58_flag                   ,
     x_fnar_message_59                   =>c_int_data_rec.fnar_message_59_flag                   ,
     x_fnar_message_60                   =>c_int_data_rec.fnar_message_60_flag                   ,
     x_fnar_message_61                   =>c_int_data_rec.fnar_message_61_flag                   ,
     x_fnar_message_62                   =>c_int_data_rec.fnar_message_62_flag                   ,
     x_fnar_message_63                   =>c_int_data_rec.fnar_message_63_flag                   ,
     x_fnar_message_64                   =>c_int_data_rec.fnar_message_64_flag                   ,
     x_fnar_message_65                   =>c_int_data_rec.fnar_message_65_flag                   ,
     x_fnar_message_71                   =>c_int_data_rec.fnar_message_71_flag                   ,
     x_fnar_message_72                   =>c_int_data_rec.fnar_message_72_flag                   ,
     x_fnar_message_73                   =>c_int_data_rec.fnar_message_73_flag                   ,
     x_fnar_message_74                   =>c_int_data_rec.fnar_message_74_flag                   ,
     x_fnar_message_75                   =>c_int_data_rec.fnar_message_75_flag                   ,
     x_fnar_message_76                   =>c_int_data_rec.fnar_message_76_flag                   ,
     x_fnar_message_77                   =>c_int_data_rec.fnar_message_77_flag                   ,
     x_fnar_message_78                   =>c_int_data_rec.fnar_message_78_flag                   ,
     x_fnar_mesg_10_stu_fam_mem          =>c_int_data_rec.fnar_mesg_10_stu_fam_mem_num           ,
     x_fnar_mesg_11_stu_no_in_coll       =>c_int_data_rec.fnar_mesg_11_stu_no_in_col_num         ,
     x_fnar_mesg_24_stu_avail_inc        =>c_int_data_rec.fnar_mesg_24_stu_avail_inc_amt         ,
     x_fnar_mesg_26_stu_taxes            =>c_int_data_rec.fnar_mesg_26_stu_taxes_amt             ,
     x_fnar_mesg_33_stu_home_value       =>c_int_data_rec.fnar_mesg_33_stu_home_val_amt          ,
     x_fnar_mesg_34_stu_home_value       =>c_int_data_rec.fnar_mesg_34_stu_home_val_amt          ,
     x_fnar_mesg_34_stu_home_equity      =>c_int_data_rec.fnar_mesg_34_stu_home_equ_amt          ,
     x_fnar_mesg_35_stu_home_value       =>c_int_data_rec.fnar_mesg_35_stu_home_val_amt          ,
     x_fnar_mesg_35_stu_home_equity      =>c_int_data_rec.fnar_mesg_35_stu_home_equ_amt          ,
     x_fnar_mesg_36_stu_home_equity      =>c_int_data_rec.fnar_mesg_36_stu_home_equ_amt          ,
     x_fnar_mesg_48_par_fam_mem          =>c_int_data_rec.fnar_mesg_48_par_fam_mem_num           ,
     x_fnar_mesg_49_par_no_in_coll       =>c_int_data_rec.fnar_mesg_49_par_no_in_col_num         ,
     x_fnar_mesg_56_par_agi              =>c_int_data_rec.fnar_mesg_56_par_agi_amt               ,
     x_fnar_mesg_62_par_taxes            =>c_int_data_rec.fnar_mesg_62_par_taxes_amt             ,
     x_fnar_mesg_73_par_home_value       =>c_int_data_rec.fnar_mesg_73_par_home_val_amt          ,
     x_fnar_mesg_74_par_home_value       =>c_int_data_rec.fnar_mesg_74_par_home_val_amt          ,
     x_fnar_mesg_74_par_home_equity      =>c_int_data_rec.fnar_mesg_74_par_home_equ_amt          ,
     x_fnar_mesg_75_par_home_value       =>c_int_data_rec.fnar_mesg_75_par_home_val_amt          ,
     x_fnar_mesg_75_par_home_equity      =>c_int_data_rec.fnar_mesg_75_par_home_equ_amt          ,
     x_fnar_mesg_76_par_home_equity      =>c_int_data_rec.fnar_mesg_76_par_home_equ_amt          ,
     x_assumption_message_1              =>c_int_data_rec.assumption_message_1_flag              ,
     x_assumption_message_2              =>c_int_data_rec.assumption_message_2_flag              ,
     x_assumption_message_3              =>c_int_data_rec.assumption_message_3_flag              ,
     x_assumption_message_4              =>c_int_data_rec.assumption_message_4_flag              ,
     x_assumption_message_5              =>c_int_data_rec.assumption_message_5_flag              ,
     x_assumption_message_6              =>c_int_data_rec.assumption_message_6_flag              ,
     x_record_mark                       => NULL                                                 ,
     x_fnar_message_55                   => c_int_data_rec.fnar_message_55_flag                  ,
     x_fnar_message_49                   => c_int_data_rec.fnar_message_49_flag                  ,
     x_opt_par_cola_adj_ind              => c_int_data_rec.option_par_cola_adj_flag              ,
     x_opt_par_stu_fa_assets_ind         => c_int_data_rec.option_par_stu_fa_assets_flag         ,
     x_opt_par_ipt_assets_ind            => c_int_data_rec.option_par_ipt_assets_flag            ,
     x_opt_stu_ipt_assets_ind            => c_int_data_rec.option_stu_ipt_assets_flag            ,
     x_opt_par_cola_adj_value            => c_int_data_rec.option_par_cola_adj_value,
     x_opt_ind_stu_ipt_assets_flag       => c_int_data_rec.option_ind_stu_ipt_assets_flag,
     x_cust_parent_cont_adj_num          => c_int_data_rec.cust_parent_cont_adj_num,
     x_custodial_parent_num              => c_int_data_rec.custodial_parent_num,
     x_cust_par_base_prcnt_inc_amt       => c_int_data_rec.cust_par_base_prcnt_inc_amt,
     x_cust_par_base_cont_inc_amt        => c_int_data_rec.cust_par_base_cont_inc_amt,
     x_cust_par_base_cont_ast_amt        => c_int_data_rec.cust_par_base_cont_ast_amt,
     x_cust_par_base_tot_cont_amt        => c_int_data_rec.cust_par_base_tot_cont_amt,
     x_cust_par_opt_prcnt_inc_amt        => c_int_data_rec.cust_par_opt_prcnt_inc_amt,
     x_cust_par_opt_cont_inc_amt         => c_int_data_rec.cust_par_opt_cont_inc_amt,
     x_cust_par_opt_cont_ast_amt         => c_int_data_rec.cust_par_opt_cont_ast_amt,
     x_cust_par_opt_tot_cont_amt         => c_int_data_rec.cust_par_opt_cont_ast_amt,
     x_parents_email_txt                 => c_int_data_rec.parents_email_txt,
     x_parent_1_birth_date               => c_int_data_rec.parent_1_birth_date,
     x_parent_2_birth_date               => c_int_data_rec.parent_2_birth_date
   );
END fnar_insert_row;


PROCEDURE log_input_params( p_batch_num         IN  NUMBER,
                              p_alternate_code    IN  igs_ca_inst.alternate_code%TYPE   ,
                              p_delete_flag       IN  VARCHAR2 )  IS
/*
||  Created By : masehgal
||  Created On : 28-May-2003
||  Purpose    : Logs all the Input Parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  -- cursor to get batch desc for the batch id from igf_ap_li_bat_ints
  CURSOR c_batch_desc(cp_batch_num     igf_aw_li_coa_ints.batch_num%TYPE ) IS
     SELECT batch_desc, batch_type
       FROM igf_ap_li_bat_ints
      WHERE batch_num = cp_batch_num ;

  -- CURSOR FOR GETTING THE MESSAGE FROM FND_NEW_MESSAGES
  CURSOR c_get_message(cp_message_name VARCHAR2) IS
     SELECT message_text
       FROM fnd_new_messages
      WHERE message_name = cp_message_name;

  l_delete_flag_prmpt fnd_new_messages.message_text%TYPE;

  l_lkup_type            VARCHAR2(60) ;
  l_lkup_code            VARCHAR2(60) ;
  l_batch_desc           igf_ap_li_bat_ints.batch_desc%TYPE ;
  l_batch_type           igf_ap_li_bat_ints.batch_type%TYPE ;
  l_batch_id             igf_ap_li_bat_ints.batch_type%TYPE ;
  l_yes_no               igf_lookups_view.meaning%TYPE ;
  l_award_year_pmpt      igf_lookups_view.meaning%TYPE ;
  l_params_pass_prmpt    igf_lookups_view.meaning%TYPE ;
  l_person_number_prmpt  igf_lookups_view.meaning%TYPE ;
  l_batch_num_prmpt      igf_lookups_view.meaning%TYPE ;
  l_error                igf_lookups_view.meaning%TYPE ;

  BEGIN -- begin log parameters

     -- get the batch description
     OPEN  c_batch_desc( p_batch_num) ;
     FETCH c_batch_desc INTO l_batch_desc, l_batch_type ;
     CLOSE c_batch_desc ;

    OPEN  c_get_message('IGS_GE_ASK_DEL_REC');
    FETCH c_get_message INTO l_delete_flag_prmpt;
    CLOSE c_get_message;

    l_error               := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_person_number_prmpt := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_num_prmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_year_pmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no              := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag);
    l_params_pass_prmpt   := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_params_pass_prmpt) ; --Parameters Passed
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_award_year_pmpt, 40)    || ' : '|| p_alternate_code ) ;

    IF l_css_log = 'N' THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_batch_num_prmpt, 40)     || ' : '|| p_batch_num || '-' || l_batch_desc ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_delete_flag_prmpt, 40)   || ' : '|| l_yes_no ) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    END IF;
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

  END log_input_params ;



  FUNCTION  is_lookup_code_exist(p_lookup_code IN VARCHAR2,
                                 p_lookup_type IN VARCHAR2)
              RETURN BOOLEAN AS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : Takes look up code and lookup type and generate hash code  and checks whether the hash value (for a lookup code) exists or not
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
  l_hash_value  NUMBER;
  l_lookup_type igf_aw_lookups_view.lookup_type%TYPE;
  BEGIN


               l_hash_value := DBMS_UTILITY.get_hash_value(
                                        RTRIM(LTRIM(p_lookup_type))||'@*?'|| RTRIM(LTRIM(p_lookup_code)),
                                       1000,
                                       25000);



               IF lookup_hash_table.EXISTS(l_hash_value) THEN

                    RETURN TRUE;
               ELSE

                    RETURN FALSE;

               END IF;

  END is_lookup_code_exist;

  PROCEDURE put_hash_values(list         IN VARCHAR2,
                            p_award_year IN VARCHAR2)


  IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Takes a list of lookup types separated by comma and store those in a pl/sql table.
  ||            Generate hash values with corresponding look up code and store in another pl/sql table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
        tablen           BINARY_INTEGER      ;
        lookups_table    DBMS_UTILITY.uncl_array;
        l_hash_value     NUMBER;


        -- Get the details of
        CURSOR c_lookup_values(p_lookup_type VARCHAR2,
                               p_award_year  VARCHAR2 )
                   IS

             SELECT   LOOKUP_CODE
             FROM     IGF_AW_LOOKUPS_VIEW
             WHERE    LOOKUP_TYPE = p_lookup_type
             AND SYS_AWARD_YEAR =p_award_year
             AND enabled_flag = 'Y' ;

             l_lookup_values c_lookup_values%ROWTYPE;

      BEGIN
       DBMS_UTILITY.comma_to_table(list,tablen,lookups_table);

       FOR i IN lookups_table.FIRST .. lookups_table.LAST
       LOOP


          FOR rec IN c_lookup_values(lookups_table(i),p_award_year)
          LOOP
           l_hash_value := DBMS_UTILITY.get_hash_value(
                                     RTRIM(LTRIM(lookups_table(i)))||'@*?'||rec.lookup_code,
                                     1000,
                                     25000);

           lookup_hash_table(l_hash_value):=l_hash_value;



          END LOOP;



       END LOOP;


  END put_hash_values ;

  PROCEDURE put_meaning(list IN VARCHAR2)
         AS
           lookups_table    DBMS_UTILITY.uncl_array;
           -- Get the details of
           CURSOR c_meaning(p_lookup_code VARCHAR2,
                      p_lookup_type VARCHAR2)
           IS
           SELECT meaning
           FROM igf_lookups_view
           WHERE lookup_code=p_lookup_code
           AND lookup_type = p_lookup_type
           AND enabled_flag = 'Y' ;

           c_meaning_rec c_meaning%ROWTYPE;
           l_hash_value  NUMBER;
           tablen NUMBER;
         BEGIN
           DBMS_UTILITY.comma_to_table(list,tablen,lookups_table);
           FOR i IN lookups_table.FIRST .. lookups_table.LAST
           LOOP
             c_meaning_rec := NULL;
             OPEN c_meaning(lookups_table(i),'IGF_AW_LOOKUPS_MSG');
             FETCH c_meaning INTO c_meaning_rec;
             CLOSE c_meaning;
             l_hash_value := DBMS_UTILITY.get_hash_value(
                                           lookups_table(i),
                                           1000,
                                           25000);
             lookup_meaning_table(l_hash_value).field_name:=lookups_table(i);
             lookup_meaning_table(l_hash_value).msg_text:=c_meaning_rec.meaning;
          END LOOP;
  END put_meaning;

  PROCEDURE print_message(p_igf_ap_message_table IN igf_ap_message_table) AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 03-June-2003
        ||  Purpose : Print the error messages stored in PL/SQL message table.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */
  CURSOR c_lkup_values(p_lookup_code  VARCHAR2 )IS
    SELECT meaning
      FROM igf_lookups_view
     WHERE lookup_type ='IGF_AW_LOOKUPS_MSG'
       AND lookup_code =p_lookup_code
       AND enabled_flag = 'Y' ;

    c_lkup_values_err_rec  c_lkup_values%ROWTYPE;
    indx NUMBER;
  BEGIN
    OPEN  c_lkup_values('ERROR');
    FETCH c_lkup_values INTO c_lkup_values_err_rec;
    CLOSE c_lkup_values;

    IF p_igf_ap_message_table.COUNT<>0 THEN
      FOR indx IN p_igf_ap_message_table.FIRST..p_igf_ap_message_table.LAST LOOP
        fnd_file.put(fnd_file.log, c_lkup_values_err_rec.meaning ||'       ');
        fnd_file.put_line(fnd_file.log,p_igf_ap_message_table(indx).field_name||'  '||p_igf_ap_message_table(indx).msg_text);
      END LOOP;
    END IF;
  END print_message;


  FUNCTION remove_spl_chr(pv_ssn        IN igf_ap_isir_intrface_all.CURRENT_SSN%TYPE)
  RETURN VARCHAR2
  IS
   /*
   ||  Created By : rasingh
   ||  Created On : 19-Apr-2002
   ||  Purpose :        Strips the special charactes from SSN and returns just the number
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who              When              What
   ||  (reverse chronological order - newest change first)
   */
   ln_ssn VARCHAR2(20);

 BEGIN
   SELECT TRANSLATE (pv_ssn,'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890')
   INTO   ln_ssn
   FROM   dual;
   RETURN ln_ssn;
 EXCEPTION
   WHEN        others THEN
   RETURN '-1';
 END remove_spl_chr;


 FUNCTION p_l_to_i_col( p_in_col_name IN VARCHAR2)
 RETURN VARCHAR2
  /***************************************************************
     Created By :       rasahoo
     Date Created By  : 03-June-2003
     Purpose    : Returns col name to print based on type of import being run
     Known Limitations,Enhancements or Remarks
     Change History :
     Who      When    What
   ***************************************************************/
 IS
  p_out_col_name VARCHAR2(200);
 BEGIN
   IF l_css_log = 'N' THEN
     RETURN p_in_col_name ;
   END IF;

    IF p_in_col_name = 'CSSINT_ID' THEN
       p_out_col_name := 'CSS_ID' ;
    ELSIF p_in_col_name = 'COLLEGE_CD' THEN
       p_out_col_name := 'COLLEGE_CODE' ;
    ELSIF p_in_col_name = 'ACADEMIC_YEAR_TXT' THEN
       p_out_col_name := 'ACADEMIC_YEAR' ;
    ELSIF p_in_col_name = 'STU_RECORD_TYPE' THEN
       p_out_col_name := 'STU_RECORD_TYPE' ;
    ELSIF p_in_col_name = 'CSS_ID_NUMBER_TXT' THEN
       p_out_col_name := 'CSS_ID_NUMBER' ;
    ELSIF p_in_col_name = 'REGISTRATION_RECEIPT_DATE' THEN
       p_out_col_name := 'REGISTRATION_RECEIPT_DATE' ;
    ELSIF p_in_col_name = 'REGISTRATION_TYPE' THEN
       p_out_col_name := 'REGISTRATION_TYPE' ;
    ELSIF p_in_col_name = 'APPLICATION_RECEIPT_DATE' THEN
       p_out_col_name := 'APPLICATION_RECEIPT_DATE' ;
    ELSIF p_in_col_name = 'APPLICATION_TYPE' THEN
       p_out_col_name := 'APPLICATION_TYPE' ;
    ELSIF p_in_col_name = 'ORIGINAL_FNAR_COMPUTE_TXT' THEN
       p_out_col_name := 'ORIGINAL_FNAR_COMPUTE' ;
    ELSIF p_in_col_name = 'REVISION_FNAR_COMPUTE_DATE' THEN
       p_out_col_name := 'REVISION_FNAR_COMPUTE_DATE' ;
    ELSIF p_in_col_name = 'ELECTRONIC_EXTRACT_DATE' THEN
       p_out_col_name := 'ELECTRONIC_EXTRACT_DATE' ;
    ELSIF p_in_col_name = 'INSTIT_REPORTING_TYPE' THEN
       p_out_col_name := 'INSTITUTIONAL_REPORTING_TYPE' ;
    ELSIF p_in_col_name = 'ASR_RECEIPT_DATE' THEN
       p_out_col_name := 'ASR_RECEIPT_DATE' ;
    ELSIF p_in_col_name = 'LAST_NAME' THEN
       p_out_col_name := 'LAST_NAME' ;
    ELSIF p_in_col_name = 'FIRST_NAME' THEN
       p_out_col_name := 'FIRST_NAME' ;
    ELSIF p_in_col_name = 'MIDDLE_INITIAL_TXT' THEN
       p_out_col_name := 'MIDDLE_INITIAL' ;
    ELSIF p_in_col_name = 'ADDRESS_NUMBER_AND_STREET_TXT' THEN
       p_out_col_name := 'ADDRESS_NUMBER_AND_STREET' ;
    ELSIF p_in_col_name = 'CITY_TXT' THEN
       p_out_col_name := 'CITY' ;
    ELSIF p_in_col_name = 'STATE_MAILING_TXT' THEN
       p_out_col_name := 'STATE_MAILING' ;
    ELSIF p_in_col_name = 'ZIP_CD' THEN
       p_out_col_name := 'ZIP_CODE' ;
    ELSIF p_in_col_name = 'S_TELEPHONE_NUMBER_TXT' THEN
       p_out_col_name := 'S_TELEPHONE_NUMBER' ;
    ELSIF p_in_col_name = 'S_TITLE_TYPE' THEN
       p_out_col_name := 'S_TITLE' ;
    ELSIF p_in_col_name = 'BIRTH_DATE' THEN
       p_out_col_name := 'DATE_OF_BIRTH' ;
    ELSIF p_in_col_name = 'SOCIAL_SECURITY_NUM' THEN
       p_out_col_name := 'SOCIAL_SECURITY_NUMBER' ;
    ELSIF p_in_col_name = 'STATE_LEGAL_RESIDENCE_TXT' THEN
       p_out_col_name := 'STATE_LEGAL_RESIDENCE' ;
    ELSIF p_in_col_name = 'FOREIGN_ADDRESS_FLAG' THEN
       p_out_col_name := 'FOREIGN_ADDRESS_INDICATOR' ;
    ELSIF p_in_col_name = 'FOREIGN_POSTAL_CD' THEN
       p_out_col_name := 'FOREIGN_POSTAL_CODE' ;
    ELSIF p_in_col_name = 'COUNTRY_CD' THEN
       p_out_col_name := 'COUNTRY' ;
    ELSIF p_in_col_name = 'FINANCIAL_AID_STATUS_TYPE' THEN
       p_out_col_name := 'FINANCIAL_AID_STATUS' ;
    ELSIF p_in_col_name = 'YEAR_IN_COLLEGE_TYPE' THEN
       p_out_col_name := 'YEAR_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'MARITAL_STATUS_FLAG' THEN
       p_out_col_name := 'MARITAL_STATUS' ;
    ELSIF p_in_col_name = 'WARD_COURT_FLAG' THEN
       p_out_col_name := 'WARD_COURT' ;
    ELSIF p_in_col_name = 'LEGAL_DEPENDENTS_OTHER_FLAG' THEN
       p_out_col_name := 'LEGAL_DEPENDENTS_OTHER' ;
    ELSIF p_in_col_name = 'HOUSEHOLD_SIZE_NUM' THEN
       p_out_col_name := 'HOUSEHOLD_SIZE' ;
    ELSIF p_in_col_name = 'NUMBER_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'NUMBER_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'CITIZENSHIP_STATUS_TYPE' THEN
       p_out_col_name := 'CITIZENSHIP_STATUS' ;
    ELSIF p_in_col_name = 'CITIZENSHIP_COUNTRY_CD' THEN
       p_out_col_name := 'CITIZENSHIP_COUNTRY' ;
    ELSIF p_in_col_name = 'VISA_CLASSIFICATION_TYPE' THEN
       p_out_col_name := 'VISA_CLASSIFICATION' ;
    ELSIF p_in_col_name = 'TAX_FIGURES_TYPE' THEN
       p_out_col_name := 'TAX_FIGURES' ;
    ELSIF p_in_col_name = 'NUMBER_EXEMPTIONS_TXT' THEN
       p_out_col_name := 'NUMBER_EXEMPTIONS' ;
    ELSIF p_in_col_name = 'ADJUSTED_GROSS_AMT' THEN
       p_out_col_name := 'ADJUSTED_GROSS_INC' ;
    ELSIF p_in_col_name = 'US_TAX_PAID_AMT' THEN
       p_out_col_name := 'US_TAX_PAID' ;
    ELSIF p_in_col_name = 'ITEMIZED_DEDUCTIONS_AMT' THEN
       p_out_col_name := 'ITEMIZED_DEDUCTIONS' ;
    ELSIF p_in_col_name = 'STU_INCOME_WORK_AMT' THEN
       p_out_col_name := 'STU_INCOME_WORK' ;
    ELSIF p_in_col_name = 'SPOUSE_INCOME_WORK_AMT' THEN
       p_out_col_name := 'SPOUSE_INCOME_WORK' ;
    ELSIF p_in_col_name = 'DIVID_INT_INCOME_AMT' THEN
       p_out_col_name := 'DIVID_INT_INC' ;
    ELSIF p_in_col_name = 'SOC_SEC_BENEFITS_AMT' THEN
       p_out_col_name := 'SOC_SEC_BENEFITS' ;
    ELSIF p_in_col_name = 'WELFARE_TANF_AMT' THEN
       p_out_col_name := 'WELFARE_TANF' ;
    ELSIF p_in_col_name = 'CHILD_SUPP_RCVD_AMT' THEN
       p_out_col_name := 'CHILD_SUPP_RCVD' ;
    ELSIF p_in_col_name = 'EARNED_INCOME_CREDIT_AMT' THEN
       p_out_col_name := 'EARNED_INCOME_CREDIT' ;
    ELSIF p_in_col_name = 'OTHER_UNTAX_INCOME_AMT' THEN
       p_out_col_name := 'OTHER_UNTAX_INCOME' ;
    ELSIF p_in_col_name = 'TAX_STU_AID_AMT' THEN
       p_out_col_name := 'TAX_STU_AID' ;
    ELSIF p_in_col_name = 'CASH_SAV_CHECK_AMT' THEN
       p_out_col_name := 'CASH_SAV_CHECK' ;
    ELSIF p_in_col_name = 'IRA_KEOGH_AMT' THEN
       p_out_col_name := 'IRA_KEOGH' ;
    ELSIF p_in_col_name = 'INVEST_VALUE_AMT' THEN
       p_out_col_name := 'INVEST_VALUE' ;
    ELSIF p_in_col_name = 'INVEST_DEBT_AMT' THEN
       p_out_col_name := 'INVEST_DEBT' ;
    ELSIF p_in_col_name = 'HOME_VALUE_AMT' THEN
       p_out_col_name := 'HOME_VALUE' ;
    ELSIF p_in_col_name = 'HOME_DEBT_AMT' THEN
       p_out_col_name := 'HOME_DEBT' ;
    ELSIF p_in_col_name = 'OTH_REAL_VALUE_AMT' THEN
       p_out_col_name := 'OTH_REAL_VALUE' ;
    ELSIF p_in_col_name = 'OTH_REAL_DEBT_AMT' THEN
       p_out_col_name := 'OTH_REAL_DEBT' ;
    ELSIF p_in_col_name = 'BUS_FARM_VALUE_AMT' THEN
       p_out_col_name := 'BUS_FARM_VALUE' ;
    ELSIF p_in_col_name = 'BUS_FARM_DEBT_AMT' THEN
       p_out_col_name := 'BUS_FARM_DEBT' ;
    ELSIF p_in_col_name = 'LIVE_ON_FARM_FLAG' THEN
       p_out_col_name := 'LIVE_ON_FARM' ;
    ELSIF p_in_col_name = 'HOME_PURCH_PRICE_AMT' THEN
       p_out_col_name := 'HOME_PURCH_PRICE' ;
    ELSIF p_in_col_name = 'HOPE_LL_CREDIT_AMT' THEN
       p_out_col_name := 'HOPE_LL_CREDIT' ;
    ELSIF p_in_col_name = 'HOME_PURCH_YEAR_TXT' THEN
       p_out_col_name := 'HOME_PURCH_YEAR' ;
    ELSIF p_in_col_name = 'TRUST_AMOUNT_TXT' THEN
       p_out_col_name := 'TRUST_AMOUNT' ;
    ELSIF p_in_col_name = 'TRUST_AVAIL_FLAG' THEN
       p_out_col_name := 'TRUST_AVAIL' ;
    ELSIF p_in_col_name = 'TRUST_ESTAB_FLAG' THEN
       p_out_col_name := 'TRUST_ESTAB' ;
    ELSIF p_in_col_name = 'CHILD_SUPPORT_PAID_TXT' THEN
       p_out_col_name := 'CHILD_SUPPORT_PAID' ;
    ELSIF p_in_col_name = 'MED_DENT_EXPENSES_TXT' THEN
       p_out_col_name := 'MED_DENT_EXPENSES' ;
    ELSIF p_in_col_name = 'VET_US_FLAG' THEN
       p_out_col_name := 'VET_US' ;
    ELSIF p_in_col_name = 'VET_BEN_AMT' THEN
       p_out_col_name := 'VET_BEN_AMOUNT' ;
    ELSIF p_in_col_name = 'VET_BEN_MONTHS_NUM' THEN
       p_out_col_name := 'VET_BEN_MONTHS' ;
    ELSIF p_in_col_name = 'STU_SUMMER_WAGES_AMT' THEN
       p_out_col_name := 'STU_SUMMER_WAGES' ;
    ELSIF p_in_col_name = 'STU_SCHOOL_YR_WAGES_AMT' THEN
       p_out_col_name := 'STU_SCHOOL_YR_WAGES' ;
    ELSIF p_in_col_name = 'SPOUSE_SUMMER_WAGES_AMT' THEN
       p_out_col_name := 'SPOUSE_SUMMER_WAGES' ;
    ELSIF p_in_col_name = 'SPOUSE_SCHOOL_YR_WAGES_AMT' THEN
       p_out_col_name := 'SPOUSE_SCHOOL_YR_WAGES' ;
    ELSIF p_in_col_name = 'SUMMER_OTHER_TAX_INC_AMT' THEN
       p_out_col_name := 'SUMMER_OTHER_TAX_INC' ;
    ELSIF p_in_col_name = 'SCHOOL_YR_OTHER_TAX_INC_AMT' THEN
       p_out_col_name := 'SCHOOL_YR_OTHER_TAX_INC' ;
    ELSIF p_in_col_name = 'SUMMER_UNTAX_INC_AMT' THEN
       p_out_col_name := 'SUMMER_UNTAX_INC' ;
    ELSIF p_in_col_name = 'SCHOOL_YR_UNTAX_INC_AMT' THEN
       p_out_col_name := 'SCHOOL_YR_UNTAX_INC' ;
    ELSIF p_in_col_name = 'GRANTS_SCHOL_ETC_AMT' THEN
       p_out_col_name := 'GRANTS_SCHOL_ETC' ;
    ELSIF p_in_col_name = 'TUIT_BENEFITS_AMT' THEN
       p_out_col_name := 'TUIT_BENEFITS' ;
    ELSIF p_in_col_name = 'CONT_PARENTS_AMT' THEN
       p_out_col_name := 'CONT_PARENTS' ;
    ELSIF p_in_col_name = 'CONT_RELATIVES_AMT' THEN
       p_out_col_name := 'CONT_RELATIVES' ;
    ELSIF p_in_col_name = 'P_SIBLINGS_PRE_TUIT_AMT' THEN
       p_out_col_name := 'P_SIBLINGS_PRE_TUIT' ;
    ELSIF p_in_col_name = 'P_STUDENT_PRE_TUIT_AMT' THEN
       p_out_col_name := 'P_STUDENT_PRE_TUIT' ;
    ELSIF p_in_col_name = 'P_HOUSEHOLD_SIZE_NUM' THEN
       p_out_col_name := 'P_HOUSEHOLD_SIZE' ;
    ELSIF p_in_col_name = 'P_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'P_NUMBER_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'P_PARENTS_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'P_PARENTS_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'P_MARITAL_STATUS_TYPE' THEN
       p_out_col_name := 'P_MARITAL_STATUS' ;
    ELSIF p_in_col_name = 'P_STATE_LEGAL_RESIDENCE_CD' THEN
       p_out_col_name := 'P_STATE_LEGAL_RESIDENCE' ;
    ELSIF p_in_col_name = 'P_NATURAL_PAR_STATUS_FLAG' THEN
       p_out_col_name := 'P_NATURAL_PAR_STATUS' ;
    ELSIF p_in_col_name = 'P_CHILD_SUPP_PAID_AMT' THEN
       p_out_col_name := 'P_CHILD_SUPP_PAID' ;
    ELSIF p_in_col_name = 'P_REPAY_ED_LOANS_AMT' THEN
       p_out_col_name := 'P_REPAY_ED_LOANS' ;
    ELSIF p_in_col_name = 'P_MED_DENT_EXPENSES_AMT' THEN
       p_out_col_name := 'P_MED_DENT_EXPENSES' ;
    ELSIF p_in_col_name = 'P_TUIT_PAID_AMT' THEN
       p_out_col_name := 'P_TUIT_PAID_AMOUNT' ;
    ELSIF p_in_col_name = 'P_TUIT_PAID_NUM' THEN
       p_out_col_name := 'P_TUIT_PAID_NUMBER' ;
    ELSIF p_in_col_name = 'P_EXP_CHILD_SUPP_PAID_AMT' THEN
       p_out_col_name := 'P_EXP_CHILD_SUPP_PAID' ;
    ELSIF p_in_col_name = 'P_EXP_REPAY_ED_LOANS_AMT' THEN
       p_out_col_name := 'P_EXP_REPAY_ED_LOANS' ;
    ELSIF p_in_col_name = 'P_EXP_MED_DENT_EXPENSES_AMT' THEN
       p_out_col_name := 'P_EXP_MED_DENT_EXPENSES' ;
    ELSIF p_in_col_name = 'P_EXP_TUIT_PD_AMT' THEN
       p_out_col_name := 'P_EXP_TUIT_PD_AMOUNT' ;
    ELSIF p_in_col_name = 'P_EXP_TUIT_PD_NUM' THEN
       p_out_col_name := 'P_EXP_TUIT_PD_NUMBER' ;
    ELSIF p_in_col_name = 'P_CASH_SAV_CHECK_AMT' THEN
       p_out_col_name := 'P_CASH_SAV_CHECK' ;
    ELSIF p_in_col_name = 'P_MONTH_MORTGAGE_PAY_AMT' THEN
       p_out_col_name := 'P_MONTH_MORTGAGE_PAY' ;
    ELSIF p_in_col_name = 'P_INVEST_VALUE_AMT' THEN
       p_out_col_name := 'P_INVEST_VALUE' ;
    ELSIF p_in_col_name = 'P_INVEST_DEBT_AMT' THEN
       p_out_col_name := 'P_INVEST_DEBT' ;
    ELSIF p_in_col_name = 'P_HOME_VALUE_AMT' THEN
       p_out_col_name := 'P_HOME_VALUE' ;
    ELSIF p_in_col_name = 'P_HOME_DEBT_AMT' THEN
       p_out_col_name := 'P_HOME_DEBT' ;
    ELSIF p_in_col_name = 'P_HOME_PURCH_PRICE_AMT' THEN
       p_out_col_name := 'P_HOME_PURCH_PRICE' ;
    ELSIF p_in_col_name = 'P_OWN_BUSINESS_FARM_FLAG' THEN
       p_out_col_name := 'P_OWN_BUSINESS_FARM' ;
    ELSIF p_in_col_name = 'P_BUSINESS_VALUE_AMT' THEN
       p_out_col_name := 'P_BUSINESS_VALUE' ;
    ELSIF p_in_col_name = 'P_BUSINESS_DEBT_AMT' THEN
       p_out_col_name := 'P_BUSINESS_DEBT' ;
    ELSIF p_in_col_name = 'P_FARM_VALUE_AMT' THEN
       p_out_col_name := 'P_FARM_VALUE' ;
    ELSIF p_in_col_name = 'P_FARM_DEBT_AMT' THEN
       p_out_col_name := 'P_FARM_DEBT' ;
    ELSIF p_in_col_name = 'P_LIVE_ON_FARM_NUM' THEN
       p_out_col_name := 'P_LIVE_ON_FARM' ;
    ELSIF p_in_col_name = 'P_OTH_REAL_ESTATE_VALUE_AMT' THEN
       p_out_col_name := 'P_OTH_REAL_ESTATE_VALUE' ;
    ELSIF p_in_col_name = 'P_OTH_REAL_ESTATE_DEBT_AMT' THEN
       p_out_col_name := 'P_OTH_REAL_ESTATE_DEBT' ;
    ELSIF p_in_col_name = 'P_OTH_REAL_PURCH_PRICE_AMT' THEN
       p_out_col_name := 'P_OTH_REAL_PURCH_PRICE' ;
    ELSIF p_in_col_name = 'P_SIBLINGS_ASSETS_AMT' THEN
       p_out_col_name := 'P_SIBLINGS_ASSETS' ;
    ELSIF p_in_col_name = 'P_HOME_PURCH_YEAR_TXT' THEN
       p_out_col_name := 'P_HOME_PURCH_YEAR' ;
    ELSIF p_in_col_name = 'P_OTH_REAL_PURCH_YEAR_TXT' THEN
       p_out_col_name := 'P_OTH_REAL_PURCH_YEAR' ;
    ELSIF p_in_col_name = 'P_PRIOR_AGI_AMT' THEN
       p_out_col_name := 'P_PRIOR_AGI' ;
    ELSIF p_in_col_name = 'P_PRIOR_US_TAX_PAID_AMT' THEN
       p_out_col_name := 'P_PRIOR_US_TAX_PAID' ;
    ELSIF p_in_col_name = 'P_PRIOR_ITEM_DEDUCTIONS_AMT' THEN
       p_out_col_name := 'P_PRIOR_ITEM_DEDUCTIONS' ;
    ELSIF p_in_col_name = 'P_PRIOR_OTHER_UNTAX_INC_AMT' THEN
       p_out_col_name := 'P_PRIOR_OTHER_UNTAX_INC' ;
    ELSIF p_in_col_name = 'P_TAX_FIGURES_NUM' THEN
       p_out_col_name := 'P_TAX_FIGURES' ;
    ELSIF p_in_col_name = 'P_NUMBER_EXEMPTIONS_NUM' THEN
       p_out_col_name := 'P_NUMBER_EXEMPTIONS' ;
    ELSIF p_in_col_name = 'P_ADJUSTED_GROSS_INC_AMT' THEN
       p_out_col_name := 'P_ADJUSTED_GROSS_INC' ;
    ELSIF p_in_col_name = 'P_WAGES_SAL_TIPS_AMT' THEN
       p_out_col_name := 'P_WAGES_SAL_TIPS' ;
    ELSIF p_in_col_name = 'P_INTEREST_INCOME_AMT' THEN
       p_out_col_name := 'P_INTEREST_INCOME' ;
    ELSIF p_in_col_name = 'P_DIVIDEND_INCOME_AMT' THEN
       p_out_col_name := 'P_DIVIDEND_INCOME' ;
    ELSIF p_in_col_name = 'P_NET_INC_BUS_FARM_AMT' THEN
       p_out_col_name := 'P_NET_INC_BUS_FARM' ;
    ELSIF p_in_col_name = 'P_OTHER_TAXABLE_INCOME_AMT' THEN
       p_out_col_name := 'P_OTHER_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'P_ADJ_TO_INCOME_AMT' THEN
       p_out_col_name := 'P_ADJ_TO_INCOME' ;
    ELSIF p_in_col_name = 'P_US_TAX_PAID_AMT' THEN
       p_out_col_name := 'P_US_TAX_PAID' ;
    ELSIF p_in_col_name = 'P_ITEMIZED_DEDUCTIONS_AMT' THEN
       p_out_col_name := 'P_ITEMIZED_DEDUCTIONS' ;
    ELSIF p_in_col_name = 'P_FATHER_INCOME_WORK_AMT' THEN
       p_out_col_name := 'P_FATHER_INCOME_WORK' ;
    ELSIF p_in_col_name = 'P_MOTHER_INCOME_WORK_AMT' THEN
       p_out_col_name := 'P_MOTHER_INCOME_WORK' ;
    ELSIF p_in_col_name = 'P_SOC_SEC_BEN_AMT' THEN
       p_out_col_name := 'P_SOC_SEC_BEN' ;
    ELSIF p_in_col_name = 'P_WELFARE_TANF_AMT' THEN
       p_out_col_name := 'P_WELFARE_TANF' ;
    ELSIF p_in_col_name = 'P_CHILD_SUPP_RCVD_AMT' THEN
       p_out_col_name := 'P_CHILD_SUPP_RCVD' ;
    ELSIF p_in_col_name = 'P_DED_IRA_KEOGH_AMT' THEN
       p_out_col_name := 'P_DED_IRA_KEOGH' ;
    ELSIF p_in_col_name = 'P_TAX_DEFER_PENS_SAVS_AMT' THEN
       p_out_col_name := 'P_TAX_DEFER_PENS_SAVS' ;
    ELSIF p_in_col_name = 'P_DEP_CARE_MED_SPENDING_AMT' THEN
       p_out_col_name := 'P_DEP_CARE_MED_SPENDING' ;
    ELSIF p_in_col_name = 'P_EARNED_INCOME_CREDIT_AMT' THEN
       p_out_col_name := 'P_EARNED_INCOME_CREDIT' ;
    ELSIF p_in_col_name = 'P_LIVING_ALLOW_AMT' THEN
       p_out_col_name := 'P_LIVING_ALLOW' ;
    ELSIF p_in_col_name = 'P_TAX_EXMPT_INT_AMT' THEN
       p_out_col_name := 'P_TAX_EXMPT_INT' ;
    ELSIF p_in_col_name = 'P_FOREIGN_INC_EXCL_AMT' THEN
       p_out_col_name := 'P_FOREIGN_INC_EXCL' ;
    ELSIF p_in_col_name = 'P_OTHER_UNTAX_INC_AMT' THEN
       p_out_col_name := 'P_OTHER_UNTAX_INC' ;
    ELSIF p_in_col_name = 'P_HOPE_LL_CREDIT_AMT' THEN
       p_out_col_name := 'P_HOPE_LL_CREDIT' ;
    ELSIF p_in_col_name = 'P_YR_SEPARATION_AMT' THEN
       p_out_col_name := 'P_YR_SEPARATION' ;
    ELSIF p_in_col_name = 'P_YR_DIVORCE_AMT' THEN
       p_out_col_name := 'P_YR_DIVORCE' ;
    ELSIF p_in_col_name = 'P_EXP_FATHER_INC_AMT' THEN
       p_out_col_name := 'P_EXP_FATHER_INC' ;
    ELSIF p_in_col_name = 'P_EXP_MOTHER_INC_AMT' THEN
       p_out_col_name := 'P_EXP_MOTHER_INC' ;
    ELSIF p_in_col_name = 'P_EXP_OTHER_TAX_INC_AMT' THEN
       p_out_col_name := 'P_EXP_OTHER_TAX_INC' ;
    ELSIF p_in_col_name = 'P_EXP_OTHER_UNTAX_INC_AMT' THEN
       p_out_col_name := 'P_EXP_OTHER_UNTAX_INC' ;
    ELSIF p_in_col_name = 'LINE_2_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_2_RELATION' ;
    ELSIF p_in_col_name = 'LINE_2_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_2_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'LINE_3_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_3_RELATION' ;
    ELSIF p_in_col_name = 'LINE_3_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_3_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'LINE_4_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_4_RELATION' ;
    ELSIF p_in_col_name = 'LINE_4_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_4_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'LINE_5_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_5_RELATION' ;
    ELSIF p_in_col_name = 'LINE_5_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_5_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'LINE_6_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_6_RELATION' ;
    ELSIF p_in_col_name = 'LINE_6_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_6_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'LINE_7_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_7_RELATION' ;
    ELSIF p_in_col_name = 'LINE_7_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_7_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'LINE_8_RELATION_TYPE' THEN
       p_out_col_name := 'LINE_8_RELATION' ;
    ELSIF p_in_col_name = 'LINE_8_ATTEND_COLLEGE_TYPE' THEN
       p_out_col_name := 'LINE_8_ATTEND_COLLEGE' ;
    ELSIF p_in_col_name = 'P_AGE_FATHER_NUM' THEN
       p_out_col_name := 'P_AGE_FATHER' ;
    ELSIF p_in_col_name = 'P_AGE_MOTHER_NUM' THEN
       p_out_col_name := 'P_AGE_MOTHER' ;
    ELSIF p_in_col_name = 'P_DIV_SEP_FLAG' THEN
       p_out_col_name := 'P_DIV_SEP_IND' ;
    ELSIF p_in_col_name = 'B_CONT_NON_CUSTODIAL_PAR_TXT' THEN
       p_out_col_name := 'B_CONT_NON_CUSTODIAL_PAR' ;
    ELSIF p_in_col_name = 'COLLEGE_2_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_2' ;
    ELSIF p_in_col_name = 'COLLEGE_3_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_3' ;
    ELSIF p_in_col_name = 'COLLEGE_4_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_4' ;
    ELSIF p_in_col_name = 'COLLEGE_5_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_5' ;
    ELSIF p_in_col_name = 'COLLEGE_6_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_6' ;
    ELSIF p_in_col_name = 'COLLEGE_7_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_7' ;
    ELSIF p_in_col_name = 'COLLEGE_8_TYPE' THEN
       p_out_col_name := 'COLLEGE_TYPE_8' ;
    ELSIF p_in_col_name = 'SCHOOL_1_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_1' ;
    ELSIF p_in_col_name = 'HOUSING_1_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_1' ;
    ELSIF p_in_col_name = 'SCHOOL_2_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_2' ;
    ELSIF p_in_col_name = 'HOUSING_2_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_2' ;
    ELSIF p_in_col_name = 'SCHOOL_3_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_3' ;
    ELSIF p_in_col_name = 'HOUSING_3_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_3' ;
    ELSIF p_in_col_name = 'SCHOOL_4_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_4' ;
    ELSIF p_in_col_name = 'HOUSING_4_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_4' ;
    ELSIF p_in_col_name = 'SCHOOL_5_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_5' ;
    ELSIF p_in_col_name = 'HOUSING_5_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_5' ;
    ELSIF p_in_col_name = 'SCHOOL_6_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_6' ;
    ELSIF p_in_col_name = 'HOUSING_6_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_6' ;
    ELSIF p_in_col_name = 'SCHOOL_7_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_7' ;
    ELSIF p_in_col_name = 'HOUSING_7_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_7' ;
    ELSIF p_in_col_name = 'SCHOOL_8_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_8' ;
    ELSIF p_in_col_name = 'HOUSING_8_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_8' ;
    ELSIF p_in_col_name = 'SCHOOL_9_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_9' ;
    ELSIF p_in_col_name = 'HOUSING_9_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_9' ;
    ELSIF p_in_col_name = 'SCHOOL_10_CD' THEN
       p_out_col_name := 'SCHOOL_CODE_10' ;
    ELSIF p_in_col_name = 'HOUSING_10_TYPE' THEN
       p_out_col_name := 'HOUSING_CODE_10' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_1_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_1' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_2_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_2' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_3_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_3' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_4_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_4' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_5_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_5' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_6_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_6' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_7_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_7' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_8_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_8' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_9_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_9' ;
    ELSIF p_in_col_name = 'ADDITIONAL_SCHOOL_10_CD' THEN
       p_out_col_name := 'ADDITIONAL_SCHOOL_CODE_10' ;
    ELSIF p_in_col_name = 'EXPLANATION_SPEC_CIRCUM_FLAG' THEN
       p_out_col_name := 'EXPLANATION_SPEC_CIRCUM' ;
    ELSIF p_in_col_name = 'SIGNATURE_STUDENT_FLAG' THEN
       p_out_col_name := 'SIGNATURE_STUDENT' ;
    ELSIF p_in_col_name = 'SIGNATURE_SPOUSE_FLAG' THEN
       p_out_col_name := 'SIGNATURE_SPOUSE' ;
    ELSIF p_in_col_name = 'SIGNATURE_FATHER_FLAG' THEN
       p_out_col_name := 'SIGNATURE_FATHER' ;
    ELSIF p_in_col_name = 'SIGNATURE_MOTHER_FLAG' THEN
       p_out_col_name := 'SIGNATURE_MOTHER' ;
    ELSIF p_in_col_name = 'MONTH_DAY_COMPLETED' THEN
       p_out_col_name := 'MONTH_DAY_COMPLETED' ;
    ELSIF p_in_col_name = 'YEAR_COMPLETED_FLAG' THEN
       p_out_col_name := 'YEAR_COMPLETED' ;
    ELSIF p_in_col_name = 'AGE_LINE_2_NUM' THEN
       p_out_col_name := 'AGE_LINE_2' ;
    ELSIF p_in_col_name = 'AGE_LINE_3_NUM' THEN
       p_out_col_name := 'AGE_LINE_3' ;
    ELSIF p_in_col_name = 'AGE_LINE_4_NUM' THEN
       p_out_col_name := 'AGE_LINE_4' ;
    ELSIF p_in_col_name = 'AGE_LINE_5_NUM' THEN
       p_out_col_name := 'AGE_LINE_5' ;
    ELSIF p_in_col_name = 'AGE_LINE_6_NUM' THEN
       p_out_col_name := 'AGE_LINE_6' ;
    ELSIF p_in_col_name = 'AGE_LINE_7_NUM' THEN
       p_out_col_name := 'AGE_LINE_7' ;
    ELSIF p_in_col_name = 'AGE_LINE_8_NUM' THEN
       p_out_col_name := 'AGE_LINE_8' ;
    ELSIF p_in_col_name = 'A_ONLINE_SIGNATURE_FLAG' THEN
       p_out_col_name := 'A_ONLINE_SIGNATURE' ;
    ELSIF p_in_col_name = 'QUESTION_1_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_1_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_1_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_1_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_1_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_1_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_2_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_2_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_2_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_2_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_2_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_2_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_3_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_3_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_3_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_3_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_3_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_3_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_4_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_4_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_4_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_4_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_4_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_4_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_5_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_5_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_5_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_5_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_5_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_5_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_6_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_6_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_6_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_6_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_6_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_6_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_7_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_7_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_7_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_7_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_7_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_7_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_8_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_8_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_8_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_8_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_8_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_8_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_9_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_9_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_9_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_9_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_9_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_9_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_10_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_10_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_10_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_10_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_10_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_10_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_11_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_11_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_11_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_11_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_11_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_11_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_12_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_12_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_12_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_12_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_12_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_12_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_13_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_13_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_13_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_13_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_13_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_13_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_14_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_14_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_14_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_14_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_14_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_14_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_15_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_15_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_15_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_15_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_15_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_15_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_16_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_16_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_16_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_16_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_16_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_16_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_17_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_17_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_17_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_17_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_17_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_17_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_18_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_18_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_18_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_18_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_18_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_18_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_19_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_19_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_19_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_19_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_19_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_19_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_20_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_20_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_20_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_20_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_20_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_20_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_21_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_21_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_21_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_21_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_21_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_21_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_22_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_22_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_22_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_22_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_22_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_22_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_23_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_23_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_23_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_23_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_23_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_23_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_24_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_24_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_24_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_24_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_24_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_24_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_25_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_25_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_25_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_25_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_25_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_25_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_26_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_26_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_26_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_26_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_26_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_26_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_27_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_27_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_27_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_27_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_27_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_27_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_28_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_28_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_28_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_28_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_28_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_28_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_29_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_29_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTION_29_SIZE_NUM' THEN
       p_out_col_name := 'QUESTION_29_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_29_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_29_ANSWER' ;
    ELSIF p_in_col_name = 'QUESTION_30_NUMBER_TXT' THEN
       p_out_col_name := 'QUESTION_30_NUMBER' ;
    ELSIF p_in_col_name = 'QUESTIONS_30_SIZE_NUM' THEN
       p_out_col_name := 'QUESTIONS_30_SIZE' ;
    ELSIF p_in_col_name = 'QUESTION_30_ANSWER_TXT' THEN
       p_out_col_name := 'QUESTION_30_ANSWER' ;
    ELSIF p_in_col_name = 'R_S_EMAIL_ADDRESS_TXT' THEN
       p_out_col_name := 'R_S_EMAIL_ADDRESS' ;
    ELSIF p_in_col_name = 'EPS_CD' THEN
       p_out_col_name := 'EPS_CODE' ;
    ELSIF p_in_col_name = 'COMP_CSS_DEPENDCY_STATUS_TYPE' THEN
       p_out_col_name := 'COMP_CSS_DEPENDENCY_STATUS' ;
    ELSIF p_in_col_name = 'STU_AGE_NUM' THEN
       p_out_col_name := 'STU_AGE' ;
    ELSIF p_in_col_name = 'ASSUMED_STU_YR_IN_COLL_TYPE' THEN
       p_out_col_name := 'ASSUMED_STU_YR_IN_COLL' ;
    ELSIF p_in_col_name = 'COMP_STU_MARITAL_STATUS_TYPE' THEN
       p_out_col_name := 'COMP_STU_MARITAL_STATUS' ;
    ELSIF p_in_col_name = 'STU_FAMILY_MEMBERS_NUM' THEN
       p_out_col_name := 'STU_FAMILY_MEMBERS' ;
    ELSIF p_in_col_name = 'STU_FAM_MEMBERS_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'STU_FAM_MEMBERS_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'PAR_MARITAL_STATUS_TYPE' THEN
       p_out_col_name := 'PAR_MARITAL_STATUS' ;
    ELSIF p_in_col_name = 'PAR_FAMILY_MEMBERS_NUM' THEN
       p_out_col_name := 'PAR_FAMILY_MEMBERS' ;
    ELSIF p_in_col_name = 'PAR_TOTAL_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'PAR_TOTAL_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'PAR_PAR_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'PAR_PAR_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'PAR_OTHERS_IN_COLLEGE_NUM' THEN
       p_out_col_name := 'PAR_OTHERS_IN_COLLEGE' ;
    ELSIF p_in_col_name = 'PAR_AESA_NUM' THEN
       p_out_col_name := 'PAR_AESA' ;
    ELSIF p_in_col_name = 'PAR_CESA_NUM' THEN
       p_out_col_name := 'PAR_CESA' ;
    ELSIF p_in_col_name = 'STU_AESA_NUM' THEN
       p_out_col_name := 'STU_AESA' ;
    ELSIF p_in_col_name = 'STU_CESA_NUM' THEN
       p_out_col_name := 'STU_CESA' ;
    ELSIF p_in_col_name = 'IM_P_BAS_AGI_TAXABLE_AMT' THEN
       p_out_col_name := 'IM_P_BAS_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_BAS_UNTX_INC_AND_BEN_AMT' THEN
       p_out_col_name := 'IM_P_BAS_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'IM_P_BAS_INC_ADJ_AMT' THEN
       p_out_col_name := 'IM_P_BAS_INC_ADJ' ;
    ELSIF p_in_col_name = 'IM_P_BAS_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_BAS_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_BAS_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'IM_P_BAS_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'IM_P_BAS_ST_AND_OTHER_TAX_AMT' THEN
       p_out_col_name := 'IM_P_BAS_ST_AND_OTHER_TAX' ;
    ELSIF p_in_col_name = 'IM_P_BAS_FICA_TAX_AMT' THEN
       p_out_col_name := 'IM_P_BAS_FICA_TAX' ;
    ELSIF p_in_col_name = 'IM_P_BAS_MED_DENTAL_AMT' THEN
       p_out_col_name := 'IM_P_BAS_MED_DENTAL' ;
    ELSIF p_in_col_name = 'IM_P_BAS_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_BAS_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_BAS_ANNUAL_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_P_BAS_ANNUAL_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_P_BAS_INC_PROT_ALLOW_M_AMT' THEN
       p_out_col_name := 'IM_P_BAS_INC_PROT_ALLOW_M' ;
    ELSIF p_in_col_name = 'IM_P_BAS_TOTAL_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_BAS_TOTAL_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_BAS_CAL_AVAIL_INC_AMT' THEN
       p_out_col_name := 'IM_P_BAS_CAL_AVAIL_INC' ;
    ELSIF p_in_col_name = 'IM_P_BAS_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_BAS_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_BAS_TOTAL_CONT_INC_AMT' THEN
       p_out_col_name := 'IM_P_BAS_TOTAL_CONT_INC' ;
    ELSIF p_in_col_name = 'IM_P_BAS_CASH_BANK_ACCOUNT_AMT' THEN
       p_out_col_name := 'IM_P_BAS_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'IM_P_BAS_HOME_EQUITY_AMT' THEN
       p_out_col_name := 'IM_P_BAS_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'IM_P_BAS_OT_RL_EST_INV_EQ_AMT' THEN
       p_out_col_name := 'IM_P_BAS_OT_RL_EST_INV_EQ' ;
    ELSIF p_in_col_name = 'IM_P_BAS_ADJ_BUS_FARM_WRTH_AMT' THEN
       p_out_col_name := 'IM_P_BAS_ADJ_BUS_FARM_WORTH' ;
    ELSIF p_in_col_name = 'IM_P_BAS_ASS_SIBS_PRE_TUI_AMT' THEN
       p_out_col_name := 'IM_P_BAS_ASS_SIBS_PRE_TUI' ;
    ELSIF p_in_col_name = 'IM_P_BAS_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_P_BAS_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_P_BAS_EMERG_RES_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_BAS_EMERG_RES_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_BAS_CUM_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_P_BAS_CUM_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_P_BAS_LOW_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_BAS_LOW_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_BAS_TOTAL_ASSET_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_BAS_TOTAL_ASSET_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_BAS_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_P_BAS_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_P_BAS_TOTAL_CONT_ASSET_AMT' THEN
       p_out_col_name := 'IM_P_BAS_TOTAL_CONT_ASSET' ;
    ELSIF p_in_col_name = 'IM_P_BAS_TOTAL_CONT_AMT' THEN
       p_out_col_name := 'IM_P_BAS_TOTAL_CONT' ;
    ELSIF p_in_col_name = 'IM_P_BAS_NUM_IN_COLL_ADJ_AMT' THEN
       p_out_col_name := 'IM_P_BAS_NUM_IN_COLL_ADJ' ;
    ELSIF p_in_col_name = 'IM_P_BAS_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'IM_P_BAS_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'IM_P_BAS_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_BAS_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_BAS_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'IM_P_BAS_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'IM_P_OPT_AGI_TAX_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_OPT_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_OPT_UNTX_INC_BEN_AMT' THEN
       p_out_col_name := 'IM_P_OPT_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'IM_P_OPT_INC_ADJ_AMT' THEN
       p_out_col_name := 'IM_P_OPT_INC_ADJ' ;
    ELSIF p_in_col_name = 'IM_P_OPT_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_OPT_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_OPT_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'IM_P_OPT_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'IM_P_OPT_ST_AND_OTHER_TAX_AMT' THEN
       p_out_col_name := 'IM_P_OPT_ST_AND_OTHER_TAX' ;
    ELSIF p_in_col_name = 'IM_P_OPT_FICA_TAX_AMT' THEN
       p_out_col_name := 'IM_P_OPT_FICA_TAX' ;
    ELSIF p_in_col_name = 'IM_P_OPT_MED_DENTAL_AMT' THEN
       p_out_col_name := 'IM_P_OPT_MED_DENTAL' ;
    ELSIF p_in_col_name = 'IM_P_OPT_ELEM_SEC_TUIT_AMT' THEN
       p_out_col_name := 'IM_P_OPT_ELEM_SEC_TUIT' ;
    ELSIF p_in_col_name = 'IM_P_OPT_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_OPT_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_OPT_ANNUAL_ED_SAVING_AMT' THEN
       p_out_col_name := 'IM_P_OPT_ANNUAL_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_P_OPT_INC_PROT_ALLOW_M_AMT' THEN
       p_out_col_name := 'IM_P_OPT_INC_PROT_ALLOW_M' ;
    ELSIF p_in_col_name = 'IM_P_OPT_TOTAL_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_OPT_TOTAL_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_OPT_CAL_AVAIL_INC_AMT' THEN
       p_out_col_name := 'IM_P_OPT_CAL_AVAIL_INC' ;
    ELSIF p_in_col_name = 'IM_P_OPT_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_OPT_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_OPT_TOTAL_CONT_INC_AMT' THEN
       p_out_col_name := 'IM_P_OPT_TOTAL_CONT_INC' ;
    ELSIF p_in_col_name = 'IM_P_OPT_CASH_BANK_ACCNT_AMT' THEN
       p_out_col_name := 'IM_P_OPT_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'IM_P_OPT_HOME_EQUITY_AMT' THEN
       p_out_col_name := 'IM_P_OPT_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'IM_P_OPT_OT_RL_EST_INV_EQ_AMT' THEN
       p_out_col_name := 'IM_P_OPT_OT_RL_EST_INV_EQ' ;
    ELSIF p_in_col_name = 'IM_P_OPT_ADJ_FARM_WORTH_AMT' THEN
       p_out_col_name := 'IM_P_OPT_ADJ_BUS_FARM_WORTH' ;
    ELSIF p_in_col_name = 'IM_P_OPT_ASS_SIBS_PRE_T_AMT' THEN
       p_out_col_name := 'IM_P_OPT_ASS_SIBS_PRE_T' ;
    ELSIF p_in_col_name = 'IM_P_OPT_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_P_OPT_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_P_OPT_EMERG_RES_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_OPT_EMERG_RES_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_OPT_CUM_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_P_OPT_CUM_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_P_OPT_LOW_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_OPT_LOW_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_OPT_TOTAL_ASSET_ALLOW_AMT' THEN
       p_out_col_name := 'IM_P_OPT_TOTAL_ASSET_ALLOW' ;
    ELSIF p_in_col_name = 'IM_P_OPT_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_P_OPT_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_P_OPT_TOTAL_CONT_ASSET_AMT' THEN
       p_out_col_name := 'IM_P_OPT_TOTAL_CONT_ASSET' ;
    ELSIF p_in_col_name = 'IM_P_OPT_TOTAL_CONT_AMT' THEN
       p_out_col_name := 'IM_P_OPT_TOTAL_CONT' ;
    ELSIF p_in_col_name = 'IM_P_OPT_NUM_IN_COLL_ADJ_AMT' THEN
       p_out_col_name := 'IM_P_OPT_NUM_IN_COLL_ADJ' ;
    ELSIF p_in_col_name = 'IM_P_OPT_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'IM_P_OPT_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'IM_P_OPT_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'IM_P_OPT_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'IM_P_OPT_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'IM_P_OPT_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'FM_P_ANALYSIS_TYPE' THEN
       p_out_col_name := 'FM_P_ANALYSIS_TYPE' ;
    ELSIF p_in_col_name = 'FM_P_AGI_TAXABLE_INCOME_AMT' THEN
       p_out_col_name := 'FM_P_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'FM_P_UNTX_INC_AND_BEN_AMT' THEN
       p_out_col_name := 'FM_P_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'FM_P_INC_ADJ_AMT' THEN
       p_out_col_name := 'FM_P_INC_ADJ' ;
    ELSIF p_in_col_name = 'FM_P_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'FM_P_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'FM_P_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'FM_P_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'FM_P_STATE_AND_OTHER_TAX_AMT' THEN
       p_out_col_name := 'FM_P_STATE_AND_OTHER_TAXES' ;
    ELSIF p_in_col_name = 'FM_P_FICA_TAX_AMT' THEN
       p_out_col_name := 'FM_P_FICA_TAX' ;
    ELSIF p_in_col_name = 'FM_P_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'FM_P_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'FM_P_INCOME_PROT_ALLOW_AMT' THEN
       p_out_col_name := 'FM_P_INCOME_PROT_ALLOW' ;
    ELSIF p_in_col_name = 'FM_P_TOTAL_ALLOW_AMT' THEN
       p_out_col_name := 'FM_P_TOTAL_ALLOW' ;
    ELSIF p_in_col_name = 'FM_P_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'FM_P_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'FM_P_CASH_BANK_ACCOUNTS_AMT' THEN
       p_out_col_name := 'FM_P_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'FM_P_OT_RL_EST_INV_EQ_AMT' THEN
       p_out_col_name := 'FM_P_OT_RL_EST_INV_EQ' ;
    ELSIF p_in_col_name = 'FM_P_ADJ_FARM_NET_WORTH_AMT' THEN
       p_out_col_name := 'FM_P_ADJ_BUS_FARM_NET_WORTH' ;
    ELSIF p_in_col_name = 'FM_P_NET_WORTH_AMT' THEN
       p_out_col_name := 'FM_P_NET_WORTH' ;
    ELSIF p_in_col_name = 'FM_P_ASSET_PROT_ALLOW_AMT' THEN
       p_out_col_name := 'FM_P_ASSET_PROT_ALLOW' ;
    ELSIF p_in_col_name = 'FM_P_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'FM_P_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'FM_P_TOTAL_CONTRIBUTION_AMT' THEN
       p_out_col_name := 'FM_P_TOTAL_CONTRIBUTION' ;
    ELSIF p_in_col_name = 'FM_P_NUM_IN_COLL_NUM' THEN
       p_out_col_name := 'FM_P_NUM_IN_COLL' ;
    ELSIF p_in_col_name = 'FM_P_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'FM_P_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'FM_P_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'FM_P_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'FM_P_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'FM_P_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'IM_S_BAS_AGI_TAX_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_BAS_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_BAS_UNTX_INC_AND_BEN_AMT' THEN
       p_out_col_name := 'IM_S_BAS_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'IM_S_BAS_INC_ADJ_AMT' THEN
       p_out_col_name := 'IM_S_BAS_INC_ADJ' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_BAS_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'IM_S_BAS_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'IM_S_BAS_ST_AND_OTH_TAX_AMT' THEN
       p_out_col_name := 'IM_S_BAS_ST_AND_OTH_TAX' ;
    ELSIF p_in_col_name = 'IM_S_BAS_FICA_TAX_AMT' THEN
       p_out_col_name := 'IM_S_BAS_FICA_TAX' ;
    ELSIF p_in_col_name = 'IM_S_BAS_MED_DENTAL_AMT' THEN
       p_out_col_name := 'IM_S_BAS_MED_DENTAL' ;
    ELSIF p_in_col_name = 'IM_S_BAS_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_BAS_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_BAS_ANNUAL_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_S_BAS_ANNUAL_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_S_BAS_INC_PROT_ALLOW_M_AMT' THEN
       p_out_col_name := 'IM_S_BAS_INC_PROT_ALLOW_M' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TOTAL_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TOTAL_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_BAS_CAL_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_BAS_CAL_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_BAS_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_BAS_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TOTAL_CONT_INC_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TOTAL_CONT_INC' ;
    ELSIF p_in_col_name = 'IM_S_BAS_CASH_BANK_ACCOUNT_AMT' THEN
       p_out_col_name := 'IM_S_BAS_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'IM_S_BAS_HOME_EQUITY_AMT' THEN
       p_out_col_name := 'IM_S_BAS_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'IM_S_BAS_OT_RL_EST_INV_EQ_AMT' THEN
       p_out_col_name := 'IM_S_BAS_OT_RL_EST_INV_EQ' ;
    ELSIF p_in_col_name = 'IM_S_BAS_ADJ_FARM_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_BAS_ADJ_BUS_FARM_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TRUSTS_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TRUSTS' ;
    ELSIF p_in_col_name = 'IM_S_BAS_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_BAS_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_BAS_EMERG_RES_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_BAS_EMERG_RES_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_BAS_CUM_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_S_BAS_CUM_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TOTAL_ASSET_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TOTAL_ASSET_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_BAS_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_BAS_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TOTAL_CONT_ASSET_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TOTAL_CONT_ASSET' ;
    ELSIF p_in_col_name = 'IM_S_BAS_TOTAL_CONT_AMT' THEN
       p_out_col_name := 'IM_S_BAS_TOTAL_CONT' ;
    ELSIF p_in_col_name = 'IM_S_BAS_NUM_IN_COLL_ADJ_AMT' THEN
       p_out_col_name := 'IM_S_BAS_NUM_IN_COLL_ADJ' ;
    ELSIF p_in_col_name = 'IM_S_BAS_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'IM_S_BAS_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'IM_S_BAS_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_BAS_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_BAS_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'IM_S_BAS_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'IM_S_EST_AGI_TAX_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_EST_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_EST_UNTX_INC_AND_BEN_AMT' THEN
       p_out_col_name := 'IM_S_EST_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'IM_S_EST_INC_ADJ_AMT' THEN
       p_out_col_name := 'IM_S_EST_INC_ADJ' ;
    ELSIF p_in_col_name = 'IM_S_EST_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_EST_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_EST_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'IM_S_EST_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'IM_S_EST_ST_AND_OTH_TAX_AMT' THEN
       p_out_col_name := 'IM_S_EST_ST_AND_OTH_TAX' ;
    ELSIF p_in_col_name = 'IM_S_EST_FICA_TAX_AMT' THEN
       p_out_col_name := 'IM_S_EST_FICA_TAX' ;
    ELSIF p_in_col_name = 'IM_S_EST_MED_DENTAL_AMT' THEN
       p_out_col_name := 'IM_S_EST_MED_DENTAL' ;
    ELSIF p_in_col_name = 'IM_S_EST_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_EST_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_EST_ANNUAL_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_S_EST_ANNUAL_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_S_EST_INC_PROT_ALLOW_M_AMT' THEN
       p_out_col_name := 'IM_S_EST_INC_PROT_ALLOW_M' ;
    ELSIF p_in_col_name = 'IM_S_EST_TOTAL_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_EST_TOTAL_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_EST_CAL_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_EST_CAL_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_EST_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_EST_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_EST_TOTAL_CONT_INC_AMT' THEN
       p_out_col_name := 'IM_S_EST_TOTAL_CONT_INC' ;
    ELSIF p_in_col_name = 'IM_S_EST_CASH_BANK_ACCOUNT_AMT' THEN
       p_out_col_name := 'IM_S_EST_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'IM_S_EST_HOME_EQUITY_AMT' THEN
       p_out_col_name := 'IM_S_EST_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'IM_S_EST_OT_RL_EST_INV_EQU_AMT' THEN
       p_out_col_name := 'IM_S_EST_OT_RL_EST_INV_EQU' ;
    ELSIF p_in_col_name = 'IM_S_EST_ADJ_FARM_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_EST_ADJ_BUS_FARM_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_EST_EST_TRUSTS_AMT' THEN
       p_out_col_name := 'IM_S_EST_EST_TRUSTS' ;
    ELSIF p_in_col_name = 'IM_S_EST_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_EST_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_EST_EMERG_RES_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_EST_EMERG_RES_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_EST_CUM_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_S_EST_CUM_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_S_EST_TOTAL_ASSET_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_EST_TOTAL_ASSET_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_EST_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_EST_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_EST_TOTAL_CONT_ASSET_AMT' THEN
       p_out_col_name := 'IM_S_EST_TOTAL_CONT_ASSET' ;
    ELSIF p_in_col_name = 'IM_S_EST_TOTAL_CONT_AMT' THEN
       p_out_col_name := 'IM_S_EST_TOTAL_CONT' ;
    ELSIF p_in_col_name = 'IM_S_EST_NUM_IN_COLL_ADJ_AMT' THEN
       p_out_col_name := 'IM_S_EST_NUM_IN_COLL_ADJ' ;
    ELSIF p_in_col_name = 'IM_S_EST_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'IM_S_EST_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'IM_S_EST_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_EST_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_EST_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'IM_S_EST_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'IM_S_OPT_AGI_TAX_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_OPT_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_OPT_UNTX_INC_AND_BEN_AMT' THEN
       p_out_col_name := 'IM_S_OPT_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'IM_S_OPT_INC_ADJ_AMT' THEN
       p_out_col_name := 'IM_S_OPT_INC_ADJ' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_OPT_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'IM_S_OPT_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'IM_S_OPT_STATE_OTH_TAXES_AMT' THEN
       p_out_col_name := 'IM_S_OPT_STATE_AND_OTH_TAXES' ;
    ELSIF p_in_col_name = 'IM_S_OPT_FICA_TAX_AMT' THEN
       p_out_col_name := 'IM_S_OPT_FICA_TAX' ;
    ELSIF p_in_col_name = 'IM_S_OPT_MED_DENTAL_AMT' THEN
       p_out_col_name := 'IM_S_OPT_MED_DENTAL' ;
    ELSIF p_in_col_name = 'IM_S_OPT_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_OPT_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_OPT_ANNUAL_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_S_OPT_ANNUAL_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_S_OPT_INC_PROT_ALLOW_M_AMT' THEN
       p_out_col_name := 'IM_S_OPT_INC_PROT_ALLOW_M' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TOTAL_INC_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TOTAL_INC_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_OPT_CAL_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_OPT_CAL_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_OPT_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_OPT_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TOTAL_CONT_INC_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TOTAL_CONT_INC' ;
    ELSIF p_in_col_name = 'IM_S_OPT_CASH_BANK_ACCOUNT_AMT' THEN
       p_out_col_name := 'IM_S_OPT_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'IM_S_OPT_IRA_KEOGH_ACCOUNT_AMT' THEN
       p_out_col_name := 'IM_S_OPT_IRA_KEOGH_ACCOUNTS' ;
    ELSIF p_in_col_name = 'IM_S_OPT_HOME_EQUITY_AMT' THEN
       p_out_col_name := 'IM_S_OPT_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'IM_S_OPT_OT_RL_EST_INV_EQ_AMT' THEN
       p_out_col_name := 'IM_S_OPT_OT_RL_EST_INV_EQ' ;
    ELSIF p_in_col_name = 'IM_S_OPT_ADJ_BUS_FRM_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_OPT_ADJ_BUS_FARM_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TRUSTS_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TRUSTS' ;
    ELSIF p_in_col_name = 'IM_S_OPT_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_OPT_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_OPT_EMERG_RES_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_OPT_EMERG_RES_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_OPT_CUM_ED_SAVINGS_AMT' THEN
       p_out_col_name := 'IM_S_OPT_CUM_ED_SAVINGS' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TOTAL_ASSET_ALLOW_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TOTAL_ASSET_ALLOW' ;
    ELSIF p_in_col_name = 'IM_S_OPT_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'IM_S_OPT_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TOTAL_CONT_ASSET_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TOTAL_CONT_ASSET' ;
    ELSIF p_in_col_name = 'IM_S_OPT_TOTAL_CONT_AMT' THEN
       p_out_col_name := 'IM_S_OPT_TOTAL_CONT' ;
    ELSIF p_in_col_name = 'IM_S_OPT_NUM_IN_COLL_ADJ_AMT' THEN
       p_out_col_name := 'IM_S_OPT_NUM_IN_COLL_ADJ' ;
    ELSIF p_in_col_name = 'IM_S_OPT_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'IM_S_OPT_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'IM_S_OPT_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'IM_S_OPT_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'IM_S_OPT_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'IM_S_OPT_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'FM_S_ANALYSIS_TYPE' THEN
       p_out_col_name := 'FM_S_ANALYSIS_TYPE' ;
    ELSIF p_in_col_name = 'FM_S_AGI_TAXABLE_INCOME_AMT' THEN
       p_out_col_name := 'FM_S_AGI_TAXABLE_INCOME' ;
    ELSIF p_in_col_name = 'FM_S_UNTX_INC_AND_BEN_AMT' THEN
       p_out_col_name := 'FM_S_UNTX_INC_AND_BEN' ;
    ELSIF p_in_col_name = 'FM_S_INC_ADJ_AMT' THEN
       p_out_col_name := 'FM_S_INC_ADJ' ;
    ELSIF p_in_col_name = 'FM_S_TOTAL_INCOME_AMT' THEN
       p_out_col_name := 'FM_S_TOTAL_INCOME' ;
    ELSIF p_in_col_name = 'FM_S_US_INCOME_TAX_AMT' THEN
       p_out_col_name := 'FM_S_US_INCOME_TAX' ;
    ELSIF p_in_col_name = 'FM_S_STATE_AND_OTH_TAXES_AMT' THEN
       p_out_col_name := 'FM_S_STATE_AND_OTH_TAXES' ;
    ELSIF p_in_col_name = 'FM_S_FICA_TAX_AMT' THEN
       p_out_col_name := 'FM_S_FICA_TAX' ;
    ELSIF p_in_col_name = 'FM_S_EMPLOYMENT_ALLOW_AMT' THEN
       p_out_col_name := 'FM_S_EMPLOYMENT_ALLOW' ;
    ELSIF p_in_col_name = 'FM_S_INCOME_PROT_ALLOW_AMT' THEN
       p_out_col_name := 'FM_S_INCOME_PROT_ALLOW' ;
    ELSIF p_in_col_name = 'FM_S_TOTAL_ALLOW_AMT' THEN
       p_out_col_name := 'FM_S_TOTAL_ALLOW' ;
    ELSIF p_in_col_name = 'FM_S_CAL_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'FM_S_CAL_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'FM_S_AVAIL_INCOME_AMT' THEN
       p_out_col_name := 'FM_S_AVAIL_INCOME' ;
    ELSIF p_in_col_name = 'FM_S_CASH_BANK_ACCOUNTS_AMT' THEN
       p_out_col_name := 'FM_S_CASH_BANK_ACCOUNTS' ;
    ELSIF p_in_col_name = 'FM_S_OT_RL_EST_INV_EQUITY_AMT' THEN
       p_out_col_name := 'FM_S_OT_RL_EST_INV_EQUITY' ;
    ELSIF p_in_col_name = 'FM_S_ADJ_BUS_FARM_WORTH_AMT' THEN
       p_out_col_name := 'FM_S_ADJ_BUS_FARM_WORTH' ;
    ELSIF p_in_col_name = 'FM_S_TRUSTS_AMT' THEN
       p_out_col_name := 'FM_S_TRUSTS' ;
    ELSIF p_in_col_name = 'FM_S_NET_WORTH_AMT' THEN
       p_out_col_name := 'FM_S_NET_WORTH' ;
    ELSIF p_in_col_name = 'FM_S_ASSET_PROT_ALLOW_AMT' THEN
       p_out_col_name := 'FM_S_ASSET_PROT_ALLOW' ;
    ELSIF p_in_col_name = 'FM_S_DISC_NET_WORTH_AMT' THEN
       p_out_col_name := 'FM_S_DISC_NET_WORTH' ;
    ELSIF p_in_col_name = 'FM_S_TOTAL_CONT_AMT' THEN
       p_out_col_name := 'FM_S_TOTAL_CONT' ;
    ELSIF p_in_col_name = 'FM_S_NUM_IN_COLL_NUM' THEN
       p_out_col_name := 'FM_S_NUM_IN_COLL' ;
    ELSIF p_in_col_name = 'FM_S_CONT_FOR_STU_AMT' THEN
       p_out_col_name := 'FM_S_CONT_FOR_STU' ;
    ELSIF p_in_col_name = 'FM_S_CONT_FROM_INCOME_AMT' THEN
       p_out_col_name := 'FM_S_CONT_FROM_INCOME' ;
    ELSIF p_in_col_name = 'FM_S_CONT_FROM_ASSETS_AMT' THEN
       p_out_col_name := 'FM_S_CONT_FROM_ASSETS' ;
    ELSIF p_in_col_name = 'IM_INST_RESIDENT_FLAG' THEN
       p_out_col_name := 'IM_INST_RESIDENT_IND' ;
    ELSIF p_in_col_name = 'INSTITUTIONAL_1_BUDGET_NAME' THEN
       p_out_col_name := 'INSTITUTIONAL_1_BUDGET_NAME' ;
    ELSIF p_in_col_name = 'IM_INST_1_BUDGET_DURATION_NUM' THEN
       p_out_col_name := 'IM_INST_1_BUDGET_DURATION' ;
    ELSIF p_in_col_name = 'IM_INST_1_TUITION_FEES_AMT' THEN
       p_out_col_name := 'IM_INST_1_TUITION_FEES' ;
    ELSIF p_in_col_name = 'IM_INST_1_BOOKS_SUPPLIES_AMT' THEN
       p_out_col_name := 'IM_INST_1_BOOKS_SUPPLIES' ;
    ELSIF p_in_col_name = 'IM_INST_1_LIVING_EXPENSES_AMT' THEN
       p_out_col_name := 'IM_INST_1_LIVING_EXPENSES' ;
    ELSIF p_in_col_name = 'IM_INST_1_TOT_EXPENSES_AMT' THEN
       p_out_col_name := 'IM_INST_1_TOT_EXPENSES' ;
    ELSIF p_in_col_name = 'IM_INST_1_TOT_STU_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_1_TOT_STU_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_1_TOT_PAR_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_1_TOT_PAR_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_1_TOT_FAMILY_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_1_TOT_FAMILY_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_1_VA_BENEFITS_AMT' THEN
       p_out_col_name := 'IM_INST_1_VA_BENEFITS' ;
    ELSIF p_in_col_name = 'IM_INST_1_OT_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_1_OT_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_1_EST_FINAN_NEED_AMT' THEN
       p_out_col_name := 'IM_INST_1_EST_FINANCIAL_NEED' ;
    ELSIF p_in_col_name = 'INSTITUTIONAL_2_BUDGET_TXT' THEN
       p_out_col_name := 'INSTITUTIONAL_2_BUDGET_NAME' ;
    ELSIF p_in_col_name = 'IM_INST_2_BUDGET_DURATION_NUM' THEN
       p_out_col_name := 'IM_INST_2_BUDGET_DURATION' ;
    ELSIF p_in_col_name = 'IM_INST_2_TUITION_FEES_AMT' THEN
       p_out_col_name := 'IM_INST_2_TUITION_FEES' ;
    ELSIF p_in_col_name = 'IM_INST_2_BOOKS_SUPPLIES_AMT' THEN
       p_out_col_name := 'IM_INST_2_BOOKS_SUPPLIES' ;
    ELSIF p_in_col_name = 'IM_INST_2_LIVING_EXPENSES_AMT' THEN
       p_out_col_name := 'IM_INST_2_LIVING_EXPENSES' ;
    ELSIF p_in_col_name = 'IM_INST_2_TOT_EXPENSES_AMT' THEN
       p_out_col_name := 'IM_INST_2_TOT_EXPENSES' ;
    ELSIF p_in_col_name = 'IM_INST_2_TOT_STU_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_2_TOT_STU_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_2_TOT_PAR_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_2_TOT_PAR_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_3_TOT_PAR_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_2_TOT_FAMILY_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_2_TOT_FAMILY_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_2_VA_BENEFITS' ;
    ELSIF p_in_col_name = 'IM_INST_2_VA_BENEFITS_AMT' THEN
       p_out_col_name := 'IM_INST_2_EST_FINANCIAL_NEED' ;
    ELSIF p_in_col_name = 'IM_INST_2_EST_FINAN_NEED_AMT' THEN
       p_out_col_name := 'INSTITUTIONAL_3_BUDGET_NAME' ;
    ELSIF p_in_col_name = 'INSTITUTIONAL_3_BUDGET_TXT' THEN
       p_out_col_name := 'IM_INST_3_BUDGET_DURATION' ;
    ELSIF p_in_col_name = 'IM_INST_3_BUDGET_DURATION_NUM' THEN
       p_out_col_name := 'IM_INST_3_TUITION_FEES' ;
    ELSIF p_in_col_name = 'IM_INST_3_TUITION_FEES_AMT' THEN
       p_out_col_name := 'IM_INST_3_BOOKS_SUPPLIES' ;
    ELSIF p_in_col_name = 'IM_INST_3_BOOKS_SUPPLIES_AMT' THEN
       p_out_col_name := 'IM_INST_3_LIVING_EXPENSES' ;
    ELSIF p_in_col_name = 'IM_INST_3_LIVING_EXPENSES_AMT' THEN
       p_out_col_name := 'IM_INST_3_TOT_EXPENSES' ;
    ELSIF p_in_col_name = 'IM_INST_3_TOT_EXPENSES_AMT' THEN
       p_out_col_name := 'IM_INST_3_TOT_STU_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_3_TOT_STU_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_3_TOT_PAR_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_3_TOT_FAMILY_CONT_AMT' THEN
       p_out_col_name := 'IM_INST_3_TOT_FAMILY_CONT' ;
    ELSIF p_in_col_name = 'IM_INST_3_VA_BENEFITS_AMT' THEN
       p_out_col_name := 'IM_INST_3_VA_BENEFITS' ;
    ELSIF p_in_col_name = 'IM_INST_3_EST_FINAN_NEED_AMT' THEN
       p_out_col_name := 'IM_INST_3_EST_FINANCIAL_NEED' ;
    ELSIF p_in_col_name = 'FM_INST_1_FEDERAL_EFC_TXT' THEN
       p_out_col_name := 'FM_INST_1_FEDERAL_EFC' ;
    ELSIF p_in_col_name = 'FM_INST_1_VA_BENEFITS_TXT' THEN
       p_out_col_name := 'FM_INST_1_VA_BENEFITS' ;
    ELSIF p_in_col_name = 'FM_INST_1_FED_ELIGIBILITY_TXT' THEN
       p_out_col_name := 'FM_INST_1_FED_ELIGIBILITY' ;
    ELSIF p_in_col_name = 'FM_INST_1_PELL_TXT' THEN
       p_out_col_name := 'FM_INST_1_PELL' ;
    ELSIF p_in_col_name = 'OPTION_PAR_LOSS_ALLOW_FLAG' THEN
       p_out_col_name := 'OPTION_PAR_LOSS_ALLOW_IND' ;
    ELSIF p_in_col_name = 'OPTION_PAR_TUITION_FLAG' THEN
       p_out_col_name := 'OPTION_PAR_TUITION_IND' ;
    ELSIF p_in_col_name = 'OPTION_PAR_HOME_TYPE' THEN
       p_out_col_name := 'OPTION_PAR_HOME_IND' ;
    ELSIF p_in_col_name = 'OPTION_PAR_HOME_VALUE_TXT' THEN
       p_out_col_name := 'OPTION_PAR_HOME_VALUE' ;
    ELSIF p_in_col_name = 'OPTION_PAR_HOME_DEBT_TXT' THEN
       p_out_col_name := 'OPTION_PAR_HOME_DEBT' ;
    ELSIF p_in_col_name = 'OPTION_STU_IRA_KEOGH_FLAG' THEN
       p_out_col_name := 'OPTION_STU_IRA_KEOGH_IND' ;
    ELSIF p_in_col_name = 'OPTION_STU_HOME_TYPE' THEN
       p_out_col_name := 'OPTION_STU_HOME_IND' ;
    ELSIF p_in_col_name = 'OPTION_STU_HOME_VALUE_TXT' THEN
       p_out_col_name := 'OPTION_STU_HOME_VALUE' ;
    ELSIF p_in_col_name = 'OPTION_STU_HOME_DEBT_TXT' THEN
       p_out_col_name := 'OPTION_STU_HOME_DEBT' ;
    ELSIF p_in_col_name = 'OPTION_STU_SUM_AY_INC_FLAG' THEN
       p_out_col_name := 'OPTION_STU_SUM_AY_INC_IND' ;
    ELSIF p_in_col_name = 'OPTION_PAR_HOPE_LL_CREDIT_FLAG' THEN
       p_out_col_name := 'OPTION_PAR_HOPE_LL_CREDIT' ;
    ELSIF p_in_col_name = 'OPTION_STU_HOPE_LL_CREDIT_FLAG' THEN
       p_out_col_name := 'OPTION_STU_HOPE_LL_CREDIT' ;
    ELSIF p_in_col_name = 'IM_PARENT_1_8_MONTHS_BAS_TXT' THEN
       p_out_col_name := 'IM_PARENT_1_8_MONTHS_BAS' ;
    ELSIF p_in_col_name = 'IM_P_MORE_THAN_9_MTH_BA_TXT' THEN
       p_out_col_name := 'IM_P_MORE_THAN_9_MTH_BA' ;
    ELSIF p_in_col_name = 'IM_PARENT_1_8_MONTHS_OPT_TXT' THEN
       p_out_col_name := 'IM_PARENT_1_8_MONTHS_OPT' ;
    ELSIF p_in_col_name = 'IM_P_MORE_THAN_9_MTH_OP_TXT' THEN
       p_out_col_name := 'IM_P_MORE_THAN_9_MTH_OP' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_1_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_1' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_2_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_2' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_3_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_3' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_4_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_4' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_5_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_5' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_6_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_6' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_7_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_7' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_8_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_8' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_9_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_9' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_10_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_10' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_11_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_11' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_12_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_12' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_13_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_13' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_20_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_20' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_21_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_21' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_22_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_22' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_23_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_23' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_24_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_24' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_25_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_25' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_26_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_26' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_27_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_27' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_30_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_30' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_31_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_31' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_32_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_32' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_33_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_33' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_34_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_34' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_35_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_35' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_36_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_36' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_37_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_37' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_38_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_38' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_39_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_39' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_45_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_45' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_46_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_46' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_47_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_47' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_48_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_48' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_50_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_50' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_51_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_51' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_52_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_52' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_53_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_53' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_56_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_56' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_57_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_57' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_58_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_58' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_59_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_59' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_60_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_60' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_61_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_61' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_62_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_62' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_63_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_63' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_64_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_64' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_65_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_65' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_71_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_71' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_72_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_72' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_73_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_73' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_74_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_74' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_75_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_75' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_76_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_76' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_77_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_77' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_78_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_78' ;
    ELSIF p_in_col_name = 'FNAR_MESG_10_STU_FAM_MEM_NUM' THEN
       p_out_col_name := 'FNAR_MESG_10_STU_FAM_MEM' ;
    ELSIF p_in_col_name = 'FNAR_MESG_11_STU_NO_IN_COL_NUM' THEN
       p_out_col_name := 'FNAR_MESG_11_STU_NO_IN_COLL' ;
    ELSIF p_in_col_name = 'FNAR_MESG_24_STU_AVAIL_INC_AMT' THEN
       p_out_col_name := 'FNAR_MESG_24_STU_AVAIL_INC' ;
    ELSIF p_in_col_name = 'FNAR_MESG_26_STU_TAXES_AMT' THEN
       p_out_col_name := 'FNAR_MESG_26_STU_TAXES' ;
    ELSIF p_in_col_name = 'FNAR_MESG_33_STU_HOME_VAL_AMT' THEN
       p_out_col_name := 'FNAR_MESG_33_STU_HOME_VALUE' ;
    ELSIF p_in_col_name = 'FNAR_MESG_34_STU_HOME_VAL_AMT' THEN
       p_out_col_name := 'FNAR_MESG_34_STU_HOME_VALUE' ;
    ELSIF p_in_col_name = 'FNAR_MESG_34_STU_HOME_EQU_AMT' THEN
       p_out_col_name := 'FNAR_MESG_34_STU_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'FNAR_MESG_35_STU_HOME_VAL_AMT' THEN
       p_out_col_name := 'FNAR_MESG_35_STU_HOME_VALUE' ;
    ELSIF p_in_col_name = 'FNAR_MESG_35_STU_HOME_EQU_AMT' THEN
       p_out_col_name := 'FNAR_MESG_35_STU_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'FNAR_MESG_36_STU_HOME_EQU_AMT' THEN
       p_out_col_name := 'FNAR_MESG_36_STU_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'FNAR_MESG_48_PAR_FAM_MEM_NUM' THEN
       p_out_col_name := 'FNAR_MESG_48_PAR_FAM_MEM' ;
    ELSIF p_in_col_name = 'FNAR_MESG_49_PAR_NO_IN_COL_NUM' THEN
       p_out_col_name := 'FNAR_MESG_49_PAR_NO_IN_COLL' ;
    ELSIF p_in_col_name = 'FNAR_MESG_56_PAR_AGI_AMT' THEN
       p_out_col_name := 'FNAR_MESG_56_PAR_AGI' ;
    ELSIF p_in_col_name = 'FNAR_MESG_62_PAR_TAXES_AMT' THEN
       p_out_col_name := 'FNAR_MESG_62_PAR_TAXES' ;
    ELSIF p_in_col_name = 'FNAR_MESG_73_PAR_HOME_VAL_AMT' THEN
       p_out_col_name := 'FNAR_MESG_73_PAR_HOME_VALUE' ;
    ELSIF p_in_col_name = 'FNAR_MESG_74_PAR_HOME_VAL_AMT' THEN
       p_out_col_name := 'FNAR_MESG_74_PAR_HOME_VALUE' ;
    ELSIF p_in_col_name = 'FNAR_MESG_74_PAR_HOME_EQU_AMT' THEN
       p_out_col_name := 'FNAR_MESG_74_PAR_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'FNAR_MESG_75_PAR_HOME_VAL_AMT' THEN
       p_out_col_name := 'FNAR_MESG_75_PAR_HOME_VALUE' ;
    ELSIF p_in_col_name = 'FNAR_MESG_75_PAR_HOME_EQU_AMT' THEN
       p_out_col_name := 'FNAR_MESG_75_PAR_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'FNAR_MESG_76_PAR_HOME_EQU_AMT' THEN
       p_out_col_name := 'FNAR_MESG_76_PAR_HOME_EQUITY' ;
    ELSIF p_in_col_name = 'ASSUMPTION_MESSAGE_1_FLAG' THEN
       p_out_col_name := 'ASSUMPTION_MESSAGE_1' ;
    ELSIF p_in_col_name = 'ASSUMPTION_MESSAGE_2_FLAG' THEN
       p_out_col_name := 'ASSUMPTION_MESSAGE_2' ;
    ELSIF p_in_col_name = 'ASSUMPTION_MESSAGE_3_FLAG' THEN
       p_out_col_name := 'ASSUMPTION_MESSAGE_3' ;
    ELSIF p_in_col_name = 'ASSUMPTION_MESSAGE_4_FLAG' THEN
       p_out_col_name := 'ASSUMPTION_MESSAGE_4' ;
    ELSIF p_in_col_name = 'ASSUMPTION_MESSAGE_5_FLAG' THEN
       p_out_col_name := 'ASSUMPTION_MESSAGE_5' ;
    ELSIF p_in_col_name = 'ASSUMPTION_MESSAGE_6_FLAG' THEN
       p_out_col_name := 'ASSUMPTION_MESSAGE_6' ;
    ELSIF p_in_col_name = 'FNAR_MESSAGE_55_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_55';
    ELSIF p_in_col_name = 'FNAR_MESSAGE_49_FLAG' THEN
       p_out_col_name := 'FNAR_MESSAGE_49';
    ELSIF p_in_col_name = 'OPTION_PAR_COLA_ADJ_FLAG' THEN
       p_out_col_name := 'OPTION_PAR_COLA_ADJ_IND';
    ELSIF p_in_col_name = 'OPTION_PAR_STU_FA_ASSETS_FLAG' THEN
      p_out_col_name := 'OPTION_PAR_STU_FA_ASSETS_IND';
    ELSIF p_in_col_name = 'OPTION_PAR_IPT_ASSETS_FLAG' THEN
      p_out_col_name := 'OPTION_PAR_IPT_ASSETS_IND';
    ELSIF p_in_col_name = 'OPTION_STU_IPT_ASSETS_FLAG' THEN
      p_out_col_name := 'OPTION_STU_IPT_ASSETS_IND';
    ELSIF p_in_col_name = 'OPTION_PAR_COLA_ADJ_VALUE' THEN
      p_out_col_name := 'OPTION_PAR_COLA_ADJ_VALUE';
    ELSIF p_in_col_name = 'STU_LIVES_WITH_NUM' THEN
      p_out_col_name := 'STU_LIVES_WITH_NUM';
    ELSIF p_in_col_name = 'STU_MOST_SUPPORT_FROM_NUM' THEN
      p_out_col_name := 'STU_MOST_SUPPORT_FROM_NUM';
    ELSIF p_in_col_name = 'LOCATION_COMPUTER_NUM' THEN
      p_out_col_name := 'LOCATION_COMPUTER_NUM';
    ELSIF p_in_col_name = 'CUST_PARENT_CONT_ADJ_NUM' THEN
      p_out_col_name := 'CUST_PARENT_CONT_ADJ_NUM';
    ELSIF p_in_col_name = 'CUST_PAR_BASE_PRCNT_INC_AMT' THEN
      p_out_col_name := 'CUST_PAR_BASE_PRCNT_INC_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_BASE_CONT_INC_AMT' THEN
      p_out_col_name := 'CUST_PAR_BASE_CONT_INC_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_BASE_CONT_AST_AMT' THEN
      p_out_col_name := 'CUST_PAR_BASE_CONT_AST_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_BASE_TOT_CONT_AMT' THEN
      p_out_col_name := 'CUST_PAR_BASE_TOT_CONT_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_OPT_PRCNT_INC_AMT' THEN
      p_out_col_name := 'CUST_PAR_OPT_PRCNT_INC_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_OPT_CONT_INC_AMT' THEN
      p_out_col_name := 'CUST_PAR_OPT_CONT_INC_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_OPT_CONT_AST_AMT' THEN
      p_out_col_name := 'CUST_PAR_OPT_CONT_AST_AMT';
    ELSIF p_in_col_name = 'CUST_PAR_OPT_TOT_CONT_AMT' THEN
      p_out_col_name := 'CUST_PAR_OPT_TOT_CONT_AMT';
    END IF;
    RETURN p_out_col_name ;
 END p_l_to_i_col;

   PROCEDURE validate_profile_rec(      p_profile_rec            c_int_data%ROWTYPE,
                                       p_status                 OUT NOCOPY BOOLEAN,
                                       p_igf_ap_message_table   OUT NOCOPY igf_ap_message_table)
  AS

  /***************************************************************
     Created By :       rasahoo
     Date Created By  : 03-June-2003
     Purpose    : To Validate legacy Profile record
     Known Limitations,Enhancements or Remarks
     Change History :
     Who      When    What
   ***************************************************************/



       indx NUMBER ;
       l_ret_val BOOLEAN;
       l_hash_value NUMBER;

  BEGIN
    indx  :=0 ;


    put_meaning('ATTENDS_COLLEGE,COLLEGE_TYPE,FINANCIAL_AID_STATUS,IGF_AP_STATE_CODES,IGF_AP_YES_NO,IGF_CITIZENSHIP_TYPE,IGF_ONE_DIGIT,IGF_ST_MARITAL_STAT_TYPE,' ||
    'IGF_TAX_FIGURES,IGF_TAX_FIGURES_0405,IGF_VISA_CLASS,IGF_VISA_CLASS_0405,PARENTS_IN_COLLEGE,SCHOOL_HOUSE_CODES,STUDENT_RELATION,IGF_AP_CSS_DEP_STATUS');


    p_status:=TRUE;

    IF p_profile_rec.LINE_2_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_2_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_2_ATTEND_COLLEGE_TYPE');


      END IF;

   END IF;


   IF p_profile_rec.LINE_3_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_3_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_3_ATTEND_COLLEGE_TYPE');


      END IF;

   END IF;


 IF p_profile_rec.LINE_4_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_4_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_4_ATTEND_COLLEGE_TYPE');

         --   fnd_file.put_line(fnd_file.log,' validation : 6' );
      END IF;

   END IF;


    IF p_profile_rec.LINE_5_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_5_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_5_ATTEND_COLLEGE_TYPE');

         --   fnd_file.put_line(fnd_file.log,' validation : 8' );
      END IF;

   END IF;


    IF p_profile_rec.LINE_6_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_6_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_6_ATTEND_COLLEGE_TYPE');

            -- fnd_file.put_line(fnd_file.log,' validation : 10' );
      END IF;

   END IF;


IF p_profile_rec.LINE_7_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_7_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              -- fnd_file.put_line(fnd_file.log,'l_hash_value :'||l_hash_value );
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_7_ATTEND_COLLEGE_TYPE');


      END IF;

   END IF;


    IF p_profile_rec.LINE_8_ATTEND_COLLEGE_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_8_ATTEND_COLLEGE_TYPE,'ATTENDS_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('ATTENDS_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_8_ATTEND_COLLEGE_TYPE');


      END IF;

   END IF;


    IF p_profile_rec.COLLEGE_2_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_2_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_2_TYPE');


      END IF;

   END IF;


      IF p_profile_rec.COLLEGE_3_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_3_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_3_TYPE');


      END IF;

   END IF;


   IF p_profile_rec.COLLEGE_4_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_4_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_4_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.COLLEGE_5_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_5_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_5_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.COLLEGE_6_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_6_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_6_TYPE');


      END IF;

   END IF;


   IF p_profile_rec.COLLEGE_7_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_7_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_7_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.COLLEGE_8_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.COLLEGE_8_TYPE,'COLLEGE_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('COLLEGE_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COLLEGE_8_TYPE');


      END IF;

   END IF;

  IF p_profile_rec.FINANCIAL_AID_STATUS_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.FINANCIAL_AID_STATUS_TYPE,'FINANCIAL_AID_STATUS');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('FINANCIAL_AID_STATUS',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('FINANCIAL_AID_STATUS_TYPE');


      END IF;

   END IF;

     IF p_profile_rec.STATE_MAILING_TXT IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.STATE_MAILING_TXT,'IGF_AP_STATE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_STATE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('STATE_MAILING_TXT');


      END IF;

   END IF;

   IF p_profile_rec.STATE_LEGAL_RESIDENCE_TXT IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.STATE_LEGAL_RESIDENCE_TXT,'IGF_AP_STATE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_STATE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('STATE_LEGAL_RESIDENCE_TXT');


      END IF;

   END IF;

   IF p_profile_rec.P_STATE_LEGAL_RESIDENCE_CD IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.P_STATE_LEGAL_RESIDENCE_CD,'IGF_AP_STATE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_STATE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_STATE_LEGAL_RESIDENCE_CD');


      END IF;

   END IF;

   IF p_profile_rec.WARD_COURT_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.WARD_COURT_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('WARD_COURT_FLAG');


      END IF;

   END IF;

   IF p_profile_rec.LEGAL_DEPENDENTS_OTHER_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LEGAL_DEPENDENTS_OTHER_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LEGAL_DEPENDENTS_OTHER_FLAG');


      END IF;

   END IF;

    IF p_profile_rec.LIVE_ON_FARM_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LIVE_ON_FARM_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LIVE_ON_FARM_FLAG');


      END IF;

   END IF;

    IF p_profile_rec.TRUST_AVAIL_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.TRUST_AVAIL_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('TRUST_AVAIL_FLAG');


      END IF;

   END IF;

    IF p_profile_rec.VET_US_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.VET_US_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('VET_US_FLAG');


      END IF;

   END IF;

    IF p_profile_rec.P_NATURAL_PAR_STATUS_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.P_NATURAL_PAR_STATUS_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_NATURAL_PAR_STATUS_FLAG');


      END IF;

   END IF;



    IF p_profile_rec.P_OWN_BUSINESS_FARM_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.P_OWN_BUSINESS_FARM_FLAG,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_OWN_BUSINESS_FARM_FLAG');


      END IF;

   END IF;

    IF p_profile_rec.P_LIVE_ON_FARM_NUM IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.P_LIVE_ON_FARM_NUM,'IGF_AP_NUM_YES_NO');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_YES_NO',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_LIVE_ON_FARM_NUM');


      END IF;

   END IF;

    IF p_profile_rec.CITIZENSHIP_STATUS_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.CITIZENSHIP_STATUS_TYPE,'IGF_CITIZENSHIP_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_CITIZENSHIP_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('CITIZENSHIP_STATUS_TYPE');


      END IF;

   END IF;

     IF p_profile_rec.NUMBER_IN_COLLEGE_NUM IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.NUMBER_IN_COLLEGE_NUM,'IGF_ONE_DIGIT');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_ONE_DIGIT',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('NUMBER_IN_COLLEGE_NUM');


      END IF;

   END IF;

     IF p_profile_rec.MARITAL_STATUS_FLAG IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.MARITAL_STATUS_FLAG,'IGF_ST_MARITAL_STAT_TYPE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_ST_MARITAL_STAT_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('MARITAL_STATUS_FLAG');


      END IF;

   END IF;

    IF p_profile_rec.P_MARITAL_STATUS_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.P_MARITAL_STATUS_TYPE,'IGF_AP_PAR_MARITAL_STATUS');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_ST_MARITAL_STAT_TYPE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_MARITAL_STATUS_TYPE');


      END IF;

   END IF;
   -- Tax Figure Type for Parent and Student and Visa Classification changed for Fa130
   IF p_profile_rec.TAX_FIGURES_TYPE IS NOT NULL THEN
     IF g_sys_award_year IN ('0405','0506') THEN
       l_ret_val:=is_lookup_code_exist(p_profile_rec.TAX_FIGURES_TYPE,'IGF_TAX_FIGURES_0405');
       IF NOT l_ret_val   THEN
         p_status:=FALSE;
         indx:= indx+1;
         l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_TAX_FIGURES',1000,25000);
         p_igf_ap_message_table(indx).field_name:='';
         p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('TAX_FIGURES_TYPE');
       END IF;
     ELSE
       l_ret_val:=is_lookup_code_exist(p_profile_rec.TAX_FIGURES_TYPE,'IGF_TAX_FIGURES');
       IF NOT l_ret_val   THEN
         p_status:=FALSE;
         indx:= indx+1;
         l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_TAX_FIGURES',1000,25000);
         p_igf_ap_message_table(indx).field_name:='';
         p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('TAX_FIGURES_TYPE');
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.P_TAX_FIGURES_NUM IS NOT NULL THEN
     IF g_sys_award_year IN ('0405','0506') THEN
       l_ret_val := is_lookup_code_exist(p_profile_rec.p_tax_figures_num,'IGF_TAX_FIGURES_0405');
       IF NOT l_ret_val THEN
         p_status := FALSE;
         indx := indx + 1;
         l_hash_value := DBMS_UTILITY.get_hash_value('IGF_TAX_FIGURES',1000,25000);
         p_igf_ap_message_table(indx).field_name := '';
         p_igf_ap_message_table(indx).msg_text := lookup_meaning_table(l_hash_value).msg_text || ' ' || p_l_to_i_col('P_TAX_FIGURES_NUM');
       END IF;
     ELSE
       l_ret_val := is_lookup_code_exist(p_profile_rec.p_tax_figures_num,'IGF_TAX_FIGURES');
       IF NOT l_ret_val THEN
         p_status := FALSE;
         indx := indx + 1;
         l_hash_value := DBMS_UTILITY.get_hash_value('IGF_TAX_FIGURES',1000,25000);
         p_igf_ap_message_table(indx).field_name := '';
         p_igf_ap_message_table(indx).msg_text := lookup_meaning_table(l_hash_value).msg_text || ' ' || p_l_to_i_col('P_TAX_FIGURES_NUM');
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.VISA_CLASSIFICATION_TYPE IS NOT NULL THEN
     IF(g_sys_award_year IN ('0405','0506'))THEN
       l_ret_val:=is_lookup_code_exist(p_profile_rec.VISA_CLASSIFICATION_TYPE,'IGF_VISA_CLASS_0405');
       IF NOT l_ret_val   THEN
         p_status:=FALSE;
         indx:= indx+1;
         l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_VISA_CLASS',1000,25000);
         p_igf_ap_message_table(indx).field_name:='';
         p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('VISA_CLASSIFICATION_TYPE');
       END IF;
     ELSE
       l_ret_val:=is_lookup_code_exist(p_profile_rec.VISA_CLASSIFICATION_TYPE,'IGF_VISA_CLASS');
       IF NOT l_ret_val   THEN
         p_status:=FALSE;
         indx:= indx+1;
         l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_VISA_CLASS',1000,25000);
         p_igf_ap_message_table(indx).field_name:='';
         p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('VISA_CLASSIFICATION_TYPE');
       END IF;
     END IF;
   END IF;


     IF p_profile_rec.P_PARENTS_IN_COLLEGE_NUM IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.P_PARENTS_IN_COLLEGE_NUM,'PARENTS_IN_COLLEGE');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('PARENTS_IN_COLLEGE',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_PARENTS_IN_COLLEGE_NUM');


      END IF;

   END IF;

     IF p_profile_rec.HOUSING_1_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_1_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_1_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_2_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_2_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_2_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_3_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_3_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_3_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_4_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_4_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_4_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_5_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_5_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_5_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_6_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_6_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_6_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_7_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_7_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_7_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_8_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_8_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_8_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_9_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_9_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_9_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.HOUSING_10_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.HOUSING_10_TYPE,'SCHOOL_HOUSE_CODES');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('SCHOOL_HOUSE_CODES',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('HOUSING_10_TYPE');


      END IF;

   END IF;

    IF p_profile_rec.LINE_2_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_2_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_2_RELATION_TYPE');


      END IF;

   END IF;

  IF p_profile_rec.LINE_3_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_3_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_3_RELATION_TYPE');


      END IF;

   END IF;
   IF p_profile_rec.LINE_4_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_4_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_4_RELATION_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.LINE_5_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_5_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_5_RELATION_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.LINE_6_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_6_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_6_RELATION_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.LINE_7_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_7_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_7_RELATION_TYPE');


      END IF;

   END IF;

  IF p_profile_rec.LINE_8_RELATION_TYPE IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_profile_rec.LINE_8_RELATION_TYPE,'STUDENT_RELATION');

      IF  NOT l_ret_val   THEN
              p_status:=FALSE;
              indx:= indx+1;
              l_hash_value:=DBMS_UTILITY.get_hash_value('STUDENT_RELATION',
                                             1000,
                                             25000);
              p_igf_ap_message_table(indx).field_name:='';
              p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('LINE_8_RELATION_TYPE');


      END IF;

   END IF;

   IF p_profile_rec.COMP_CSS_DEPENDCY_STATUS_TYPE IS NOT NULL THEN
     l_ret_val:=is_lookup_code_exist(p_profile_rec.COMP_CSS_DEPENDCY_STATUS_TYPE,'IGF_AP_CSS_DEP_STATUS');
     IF NOT l_ret_val THEN
       p_status:=FALSE;
       indx:= indx+1;
       l_hash_value:=DBMS_UTILITY.get_hash_value('IGF_AP_CSS_DEP_STATUS',1000,25000);
       p_igf_ap_message_table(indx).field_name:='';
       p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('COMP_CSS_DEPENDCY_STATUS_TYPE');
     END IF;
   END IF;

   IF p_profile_rec.stu_lives_with_num IS NOT NULL THEN
     l_ret_val := is_lookup_code_exist(p_profile_rec.stu_lives_with_num,'IGF_AP_STUD_LIVES_WITH');
     IF NOT l_ret_val THEN
       p_status:=FALSE;
       indx:= indx+1;
       p_igf_ap_message_table(indx).field_name:='';
       fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
       fnd_message.set_token('FIELD', p_l_to_i_col('STU_LIVES_WITH_NUM'));
       p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

   IF p_profile_rec.stu_most_support_from_num IS NOT NULL THEN
     l_ret_val := is_lookup_code_exist(p_profile_rec.stu_most_support_from_num,'IGF_AP_STUD_REC_SUPP');
     IF NOT l_ret_val THEN
       p_status:=FALSE;
       indx:= indx+1;
       p_igf_ap_message_table(indx).field_name:='';
       fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
       fnd_message.set_token('FIELD', p_l_to_i_col('STU_MOST_SUPPORT_FROM_NUM'));
       p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

   IF p_profile_rec.location_computer_num IS NOT NULL THEN
     l_ret_val := is_lookup_code_exist(p_profile_rec.location_computer_num,'IGF_COMPUTER_LOCATION');
     IF NOT l_ret_val THEN
       p_status:=FALSE;
       indx:= indx+1;
       p_igf_ap_message_table(indx).field_name:='';
       fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
       fnd_message.set_token('FIELD', p_l_to_i_col('LOCATION_COMPUTER_NUM'));
       p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

   IF p_profile_rec.cust_parent_cont_adj_num IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_parent_cont_adj_num <> 1 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PARENT_CONT_ADJ_NUM'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_base_prcnt_inc_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_base_prcnt_inc_amt < 0 OR p_profile_rec.cust_par_base_prcnt_inc_amt > 1 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_BASE_PRCNT_INC_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_base_cont_inc_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_base_cont_inc_amt < 0 OR p_profile_rec.cust_par_base_cont_inc_amt > 99999 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_BASE_CONT_INC_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_base_cont_ast_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_base_cont_ast_amt < 0 OR p_profile_rec.cust_par_base_cont_ast_amt > 99999 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_BASE_CONT_AST_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_base_tot_cont_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_base_tot_cont_amt < 0 OR p_profile_rec.cust_par_base_tot_cont_amt > 99999 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_BASE_TOT_CONT_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_opt_prcnt_inc_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_opt_prcnt_inc_amt < 0 OR p_profile_rec.cust_par_opt_prcnt_inc_amt > 1 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_OPT_PRCNT_INC_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_opt_cont_inc_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_opt_cont_inc_amt < 0 OR p_profile_rec.cust_par_opt_cont_inc_amt > 99999 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_OPT_CONT_INC_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_opt_cont_ast_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_opt_cont_ast_amt < 0 OR p_profile_rec.cust_par_opt_cont_ast_amt > 99999 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_OPT_CONT_AST_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.cust_par_opt_tot_cont_amt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.cust_par_opt_tot_cont_amt < 0 OR p_profile_rec.cust_par_opt_tot_cont_amt > 99999 THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CUST_PAR_OPT_TOT_CONT_AMT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.application_type IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF p_profile_rec.application_type NOT IN ('1','2','3') THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('APPLICATION_TYPE'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.css_id_number_txt IS NOT NULL THEN
     IF g_sys_award_year IN ('0506') THEN
       IF SUBSTR(p_profile_rec.css_id_number_txt,1,1) <> '7' THEN
         p_status:=FALSE;
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:='';
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('CSS_ID_NUMBER_TXT'));
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
   END IF;

   IF p_profile_rec.custodial_parent_num IS NOT NULL THEN
     l_ret_val := is_lookup_code_exist(p_profile_rec.custodial_parent_num,'IGF_AP_STUD_REC_SUPP');
     IF NOT l_ret_val THEN
       p_status:=FALSE;
       indx:= indx+1;
       p_igf_ap_message_table(indx).field_name:='';
       fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
       fnd_message.set_token('FIELD', p_l_to_i_col('CUSTODIAL_PARENT_NUM'));
       p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
 END validate_profile_rec;



 PROCEDURE main ( errbuf        IN OUT  NOCOPY VARCHAR2,
                 retcode        IN OUT  NOCOPY NUMBER,
                 p_award_year   IN VARCHAR2,
                 p_batch_id     IN NUMBER,
                 p_del_int      IN VARCHAR2,
                 p_css_import   IN VARCHAR2 DEFAULT NULL)
  /*******************************************************************************
    Change History
    Who           When            What
    (reverse chronological order - newest change first)

    museshad      11-Apr-2006     Bug 5151294. Fixed issue in closing the cursors-
                                  c_css_int_data, c_int_data
  *******************************************************************************/
 AS

  -- cursor to get alternate code for award year
  CURSOR c_alternate_code( cp_ci_cal_type         igs_ca_inst.cal_type%TYPE ,
                           cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE ) IS
    SELECT alternate_code
      FROM igs_ca_inst
     WHERE cal_type        = cp_ci_cal_type
       AND sequence_number = cp_ci_sequence_number ;

  -- cursor to get sys award year and award year status
  CURSOR c_get_stat(  p_ci_cal_type VARCHAR2,p_ci_sequence_number NUMBER)IS
  SELECT award_year_status_code, sys_award_year
    FROM igf_ap_batch_aw_map   map
   WHERE map.ci_cal_type         = p_ci_cal_type
     AND map.ci_sequence_number  = p_ci_sequence_number ;

  CURSOR c_lkup_values(p_lookup_code  VARCHAR2 )IS
  SELECT meaning
    FROM igf_aw_lookups_view
   WHERE lookup_type ='IGF_AW_LOOKUPS_MSG'
     AND lookup_code =p_lookup_code
     AND enabled_flag = 'Y' ;

  CURSOR c_award_det(p_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                     p_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT BATCH_YEAR   batch_year ,
           AWARD_YEAR_STATUS_CODE ,
           CSS_ACADEMIC_YEAR,
           SYS_AWARD_YEAR
      FROM IGF_AP_BATCH_AW_MAP
     WHERE CI_CAL_TYPE = p_ci_cal_type
       AND CI_SEQUENCE_NUMBER = p_ci_sequence_number;

   -- Bug #3039724 Added p_stu_record_type
   CURSOR c_transaction_num(p_base_id         NUMBER,
                            p_css_id_number   VARCHAR2,
                            p_stu_record_type  VARCHAR2)IS
   SELECT im.css_id_number  transaction_num
     FROM igf_ap_css_profile im
    WHERE im.base_id = p_base_id
      AND im.css_id_number = p_css_id_number
      AND im.stu_record_type = p_stu_record_type
      AND rownum = 1 ;

   -- Get the details of
   CURSOR c_get_person_id(lv_ssn VARCHAR2) IS
   SELECT 'SSN' rec_type,
          api.pe_person_id person_id
     FROM igs_pe_alt_pers_id api,
          igs_pe_person_id_typ pit
    WHERE api.person_id_type        = pit.person_id_type
      AND pit.s_person_id_type = 'SSN'
      AND sysdate between api.start_dt AND NVL(api.end_dt,sysdate)
      AND api.api_person_id_uf = lv_ssn ;

   c_transaction_num_rec   c_transaction_num%ROWTYPE;
      counter                          NUMBER;
      indx                             NUMBER;
      l_alternate_code                 igs_ca_inst.alternate_code%TYPE ;
      l_ci_cal_type                    VARCHAR2(10);
      l_ci_sequence_number             NUMBER;
      l_ret_profile                    VARCHAR2(2);
      l_award_year_status              igf_ap_batch_aw_map.award_year_status_code%TYPE ;
      c_lkup_values_err_rec            c_lkup_values%ROWTYPE;
      c_lkup_values_pn_rec             c_lkup_values%ROWTYPE;
      c_lkup_values_bi_rec             c_lkup_values%ROWTYPE;
      l_batch_valid                    VARCHAR2(1) ;
      c_award_det_rec                  c_award_det%ROWTYPE;
      l_valid_for_dml                  VARCHAR2(2);
      l_dup_tran_num_exists            VARCHAR2(2);
      l_update                         VARCHAR2(2);
      l_new_base_created               VARCHAR2(2);
      lv_person_number                 c_int_data_rec.person_number%TYPE;
      lv_person_id                     NUMBER;
      lv_fa_base_id                    NUMBER;
      l_base_id                        NUMBER :=NULL;
      p_cssp_id                        NUMBER;
      l_num_recrd_passed               NUMBER:=0;
      l_num_recrd_processed            NUMBER:=0;
      TYPE message_rec IS RECORD
                  (msg_text      VARCHAR2(4000));
      TYPE l_message_table IS TABLE OF message_rec
                           INDEX BY BINARY_INTEGER;
      g_message_table                l_message_table;
      p_validation_status            BOOLEAN := TRUE;
      l_igf_ap_message_table         igf_ap_message_table;
      l_num_recrd_failed             NUMBER;
      l_error                        VARCHAR2(10);
      l_ret_val                      NUMBER;
      l_css_academic_year            NUMBER;
      lv_ssn                         VARCHAR2(30);
      c_get_person_id_rec            c_get_person_id%ROWTYPE;
      l_value                        BOOLEAN;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    IF NVL(p_css_import,'N') = 'Y' THEN
      l_css_log := 'Y' ;
     ELSE
      l_css_log := 'N' ;
    END IF;

    l_ci_cal_type          := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_ci_sequence_number   := TO_NUMBER(SUBSTR(p_award_year,11));
    l_alternate_code := NULL;

    OPEN  c_alternate_code( l_ci_cal_type, l_ci_sequence_number ) ;
    FETCH c_alternate_code INTO l_alternate_code ;
    CLOSE c_alternate_code ;

    -- Log input params
    log_input_params( p_batch_id, l_alternate_code , p_del_int);

    l_ret_profile:=igf_ap_gen.check_profile;
    IF l_ret_profile <> 'Y' THEN
    -- check if country code is not'US' AND does not participate in financial aidprogram  THEN
    -- write into the log file and exit process
      fnd_file.put(fnd_file.log,c_lkup_values_err_rec.meaning ||'       ');
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;

    OPEN c_award_det(l_ci_cal_type,l_ci_sequence_number);
    FETCH c_award_det INTO c_award_det_rec;
    CLOSE c_award_det;

    put_hash_values('ATTENDS_COLLEGE,COLLEGE_TYPE,FINANCIAL_AID_STATUS,IGF_AP_STATE_CODES,IGF_AP_NUM_YES_NO,IGF_CITIZENSHIP_TYPE,IGF_ONE_DIGIT,IGF_ST_MARITAL_STAT_TYPE,' ||
       'IGF_AP_PAR_MARITAL_STATUS,IGF_TAX_FIGURES,IGF_TAX_FIGURES_0405,IGF_VISA_CLASS,IGF_VISA_CLASS_0405,PARENTS_IN_COLLEGE,SCHOOL_HOUSE_CODES,STUDENT_RELATION,IGF_AP_CSS_DEP_STATUS,IGF_AP_STUD_LIVES_WITH,'||
       'IGF_AP_STUD_REC_SUPP,IGF_COMPUTER_LOCATION',c_award_det_rec.sys_award_year);

    OPEN  c_lkup_values('ERROR');
    FETCH c_lkup_values INTO c_lkup_values_err_rec;
    CLOSE c_lkup_values;
    l_error := c_lkup_values_err_rec.meaning;

    IF NVL(P_CSS_IMPORT,'N') = 'Y' THEN
      OPEN  c_lkup_values('SSN');
    ELSE
      OPEN  c_lkup_values('PERSON_NUMBER');
    END IF;

    FETCH c_lkup_values INTO c_lkup_values_pn_rec;
    CLOSE c_lkup_values;

    OPEN  c_lkup_values('BATCH_ID');
    FETCH c_lkup_values INTO c_lkup_values_bi_rec;
    CLOSE c_lkup_values;

    OPEN  c_get_stat( l_ci_cal_type,l_ci_sequence_number) ;
    FETCH c_get_stat INTO l_award_year_status, g_sys_award_year ;
    -- check validity of award year
    IF c_get_stat%NOTFOUND THEN
    -- Award Year setup tampered .... Log a message
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_YR_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('P_AWARD_YEAR', l_alternate_code);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    -- g_terminate_process := TRUE ;
      RETURN;
    ELSE -- Award year exists but is it Open/Legacy Details .... check
      IF l_award_year_status NOT IN ('O','LD') THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_LG_INVALID_STAT');
        FND_MESSAGE.SET_TOKEN('AWARD_STATUS', l_award_year_status);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        --g_terminate_process := TRUE ;
        RETURN;
      END IF ;  -- awd ye open or legacy detail chk
    END IF ; -- award year invalid check
    CLOSE c_get_stat ;
    -- check validity of batch
    l_batch_valid := igf_ap_gen.check_batch ( p_batch_id, 'PROFILE') ;

    IF p_css_import <> 'Y' THEN
      IF NVL(l_batch_valid,'N') <> 'Y' THEN
        fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RETURN;
      END IF;
    END IF;
    c_award_det_rec := NULL;
    OPEN c_award_det(l_ci_cal_type,l_ci_sequence_number);
    FETCH c_award_det INTO c_award_det_rec;
    CLOSE c_award_det;

    IF p_css_import = 'Y' THEN
      BEGIN
        l_css_academic_year := TO_NUMBER(c_award_det_rec.css_academic_year);
      EXCEPTION WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_AP_AW_CSS_NOT_EXISTS');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RETURN;
      END;
      OPEN c_css_int_data(l_css_academic_year);
    ELSE
      OPEN c_int_data (p_batch_id);
    END IF;

    LOOP
      BEGIN
        SAVEPOINT next_record;
        -- Initializing variables
        l_valid_for_dml := 'Y' ;
        l_dup_tran_num_exists := 'N' ;
        l_update :=  NULL;
        l_new_base_created := 'N' ;
        counter := 0;
        l_debug_str := NULL;
        IF p_css_import = 'Y' THEN
          FETCH c_css_int_data INTO l_css_int_data_rec;
          IF c_css_int_data%NOTFOUND THEN
            EXIT;
          END IF;
          p_convert_rec;
          l_num_recrd_processed := l_num_recrd_processed +1;
        ELSE
          LOOP
            FETCH c_int_data INTO c_int_data_rec;
            IF c_int_data%NOTFOUND THEN
              EXIT;
            END IF;
            -- Check if the BATCH_YEAR is equal to the Batch Year in the C_AWARD_DET subset.
            IF c_award_det_rec.css_academic_year=c_int_data_rec.academic_year_txt THEN
              EXIT;
            END IF;
            -- message IGF_AP_AW_BATCH_NOT_EXISTS
            fnd_file.put_line(fnd_file.log,c_lkup_values_pn_rec.meaning||'     '|| c_int_data_rec.person_number);
            fnd_file.put(fnd_file.log,c_lkup_values_err_rec.meaning ||'       ');
            fnd_message.set_name('IGF','IGF_AP_AW_BATCH_NOT_EXISTS');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------');
          END LOOP;
          IF c_int_data%NOTFOUND THEN
            EXIT;
          END IF;
          l_num_recrd_processed := l_num_recrd_processed +1;
        END IF;
        --check for the  person id
        lv_person_id  := NULL;
        l_value       := NULL;
        IF NVL(p_css_import,'N') <> 'Y' THEN
          lv_person_number:=c_int_data_rec.person_number;
          igf_ap_gen.check_person ( lv_person_number,l_ci_cal_type,l_ci_sequence_number,lv_person_id,lv_fa_base_id );
        ELSE
          lv_ssn   :=  remove_spl_chr(c_int_data_rec.social_security_num) ;
          IF lv_ssn is NOT NULL THEN
            OPEN c_get_person_id(lv_ssn);
            FETCH c_get_person_id INTO c_get_person_id_rec;
            CLOSE c_get_person_id;

            lv_person_id := c_get_person_id_rec.person_id;
            l_value := igf_ap_profile_matching_pkg.is_fa_base_record_present(lv_person_id,l_ci_cal_type,l_ci_sequence_number,lv_fa_base_id);
          END IF;
        END IF;
        IF lv_person_id IS NULL THEN
          l_valid_for_dml := 'N' ;
          IF p_css_import ='Y' THEN
          --Log a message in the logging table that Person does not exist in OSS (IGF_AP_PE_SSN_NOT_EXIST)
          --Update the Legacy Interface Table column IMPORT_STATUS_FLAG to "E" implying Error.
            fnd_message.set_name('IGF','IGF_AP_PE_SSN_NOT_EXIST');
            fnd_message.set_token('P_SSN',c_int_data_rec.social_security_num);
            counter := counter+1;
            g_message_table(counter).msg_text:=fnd_message.get;
            l_debug_str := l_debug_str || lv_person_number || 'person idoes not exist';
          ELSE
          -- Log a message in the logging table that Person does not exist in OSS (IGF_AP_PE_NOT_EXIST)
          --Update the Legacy Interface Table column IMPORT_STATUS_FLAG to "E" implying Error.
            fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
          -- fnd_file.put_line(fnd_file.log, fnd_message.get);
            counter := counter+1;
            g_message_table(counter).msg_text:=fnd_message.get;
            l_debug_str := l_debug_str || lv_person_number || 'person idoes not exist';

            UPDATE igf_ap_li_css_ints
            SET    IMPORT_STATUS_TYPE='E'
            WHERE  ROWID = c_int_data_rec.ROW_ID ;
          END IF;
        END IF;
        IF l_valid_for_dml = 'Y' THEN
          IF lv_fa_base_id IS NULL THEN
           --Base record does not exist so create base record.
            igf_ap_li_isir_imp_proc.create_base_rec(l_ci_cal_type,lv_person_id,l_ci_sequence_number,NULL,lv_fa_base_id,'1');
            l_new_base_created := 'Y' ;
            l_debug_str := l_debug_str || lv_person_number || ' base record created';
          END IF;
        END IF;
        IF ( l_new_base_created <> 'Y'  AND l_valid_for_dml = 'Y' ) THEN
        -- Implies that no new base ID was created so the person might have transactions
        -- Bug 3039724 Added the STU_RECORD_TYPE
          c_transaction_num_rec := NULL;
          OPEN c_transaction_num(lv_fa_base_id,c_int_data_rec.css_id_number_txt,c_int_data_rec.stu_record_type);
          FETCH c_transaction_num INTO c_transaction_num_rec;
          CLOSE c_transaction_num;
          IF c_transaction_num_rec.transaction_num IS NOT NULL THEN
            l_debug_str := l_debug_str || lv_person_number || ' duplication transaction number exist';
            l_dup_tran_num_exists := 'Y' ;
            l_valid_for_dml := 'N';
            fnd_message.set_name('IGF','IGF_AP_TRAN_NUM_EXISTS');
            fnd_message.set_token('TRAN_NUM',c_transaction_num_rec.transaction_num);
            counter := counter+1;
            g_message_table(counter).msg_text:=fnd_message.get;
          END IF;
        END IF;

        -- validate the profile record
        validate_profile_rec(c_int_data_rec,p_validation_status,l_igf_ap_message_table );

        IF NOT p_validation_status THEN
          l_valid_for_dml := 'N';
        END IF;

        IF l_valid_for_dml = 'Y' AND l_dup_tran_num_exists <> 'Y' THEN
          css_insert_row( c_int_data_rec,lv_fa_base_id,p_cssp_id);
          fnar_insert_row(c_int_data_rec ,p_cssp_id);
          IF NVL(p_css_import,'N') <> 'Y' THEN
            UPDATE igf_ap_li_css_ints
            SET    import_status_type='I'
            WHERE  ROWID = c_int_data_rec.row_id ;
          ELSE
            UPDATE igf_ap_css_interface
            SET    RECORD_STATUS = 'MATCHED'
            WHERE  ROWID = c_int_data_rec.row_id ;
          END IF;
          l_debug_str := l_debug_str || lv_person_number || ' PROFILE Record updated ';
          l_num_recrd_passed := l_num_recrd_passed +1;
        END IF;
        IF l_valid_for_dml <> 'Y'  AND  NVL(p_css_import,'N') <> 'Y'THEN
          UPDATE igf_ap_li_css_ints
          SET    import_status_type='E'
          WHERE  ROWID = c_int_data_rec.row_id ;
        END IF;
        --Print Error Messages
        IF l_valid_for_dml <> 'Y' THEN
          IF p_css_import = 'Y' THEN
            fnd_file.put_line(fnd_file.log,c_lkup_values_pn_rec.meaning||'       '|| c_int_data_rec.social_security_num);
          ELSE
            fnd_file.put_line(fnd_file.log,c_lkup_values_pn_rec.meaning||'       '|| c_int_data_rec.person_number);
          END IF;
          FOR indx_1 IN 1 .. counter LOOP
            fnd_file.put(fnd_file.log,c_lkup_values_err_rec.meaning ||'       ');
            fnd_file.put_line(fnd_file.log,g_message_table(indx_1).msg_text);
          END LOOP;

          IF NOT p_validation_status THEN
            print_message(l_igf_ap_message_table );
          END IF;
          fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------');
        END IF;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_prof_imp_proc.main.debug',l_debug_str);
          END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_li_prof_imp_proc.main.exception',l_debug_str || ' ' || SQLERRM);
          END IF;
          fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','IGF_AP_LI_ISIR_IMP_PROC.MAIN'|| SQLERRM);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          ROLLBACK TO next_record;
      END;
    COMMIT;
  END LOOP;

  -- Close cursors
  IF (c_css_int_data%ISOPEN) THEN
    CLOSE c_css_int_data;
  END IF;
  IF (c_int_data%ISOPEN) THEN
    CLOSE c_int_data;
  END IF;

  fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
  fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' ||l_num_recrd_processed);
  fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
  fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' ||l_num_recrd_passed);
  fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
  l_num_recrd_failed := l_num_recrd_processed - l_num_recrd_passed;
  fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_num_recrd_failed);
 END MAIN;

 PROCEDURE  css_import( errbuf         IN OUT  NOCOPY VARCHAR2,
                        retcode        IN OUT  NOCOPY NUMBER,
                        p_award_year   IN VARCHAR2)
  AS
   /***************************************************************
       Created By :       rasahoo
       Date Created By  : 03-June-2003
       Purpose    : To Import legscy  CSS PROFILE record
       Known Limitations,Enhancements or Remarks
       Change History :
       Who				When			What
	   tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
     ***************************************************************/
  BEGIN
	   igf_aw_gen.set_org_id(NULL);
      -- Make a call to the Legacy Profile Import Process
       main(errbuf,retcode,p_award_year,NULL,'N','Y');
  END css_import;


END igf_ap_li_prof_imp_proc;

/

--------------------------------------------------------
--  DDL for Package BEN_CWB_WS_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WS_IMPORT_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbwsim.pkh 120.4.12010000.4 2009/05/11 09:35:19 sgnanama ship $ */

default_string VARCHAR2(50) := '!!DEFAULTSTRING!!';
default_number NUMBER := -0.0000000000000001;
default_date   DATE   := to_date('01-01--4712', 'DD-MM-SYYYY');
--
---------------------------handle_row-----------------------------
--
PROCEDURE HANDLE_ROW
(
     P_EMP_NAME                      IN     VARCHAR2
   ,P_MGR_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_RANK                          IN     NUMBER      DEFAULT NULL
   ,P_YEARS_EMPLOYED                IN     NUMBER      DEFAULT NULL
   ,P_BASE_SALARY                   IN     NUMBER      DEFAULT NULL
   ,P_PL_NAME                       IN     VARCHAR2    DEFAULT NULL
   ,P_PL_XCHG_RATE                  IN     NUMBER      DEFAULT NULL
   ,P_PL_STAT_SAL_VAL               IN     NUMBER      DEFAULT default_number
   ,P_PL_ELIG_SAL_VAL               IN     NUMBER      DEFAULT NULL
   ,P_PL_TOT_COMP_VAL               IN     NUMBER      DEFAULT default_number
   ,P_PL_OTH_COMP_VAL               IN     NUMBER      DEFAULT default_number
   ,P_PL_WS_VAL                     IN     NUMBER      DEFAULT NULL
   ,P_PL_WS_MIN_VAL                 IN     NUMBER      DEFAULT NULL
   ,P_PL_WS_MAX_VAL                 IN     NUMBER      DEFAULT NULL
   ,P_PL_WS_INCR_VAL                IN     NUMBER      DEFAULT NULL
   ,P_PL_REC_VAL                    IN     NUMBER      DEFAULT NULL
   ,P_PL_REC_MIN_VAL                IN     NUMBER      DEFAULT NULL
   ,P_PL_REC_MAX_VAL                IN     NUMBER      DEFAULT NULL
   ,P_PL_MISC1_VAL                  IN     NUMBER      DEFAULT default_number
   ,P_PL_MISC2_VAL                  IN     NUMBER      DEFAULT default_number
   ,P_PL_MISC3_VAL                  IN     NUMBER      DEFAULT default_number
   ,P_PL_WS_LAST_UPD_DATE           IN     DATE	       DEFAULT NULL
   ,P_PL_WS_LAST_UPD_NAME           IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT1_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT1_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT1_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT1_OTH_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT1_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT1_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT1_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT1_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT1_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT1_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT1_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT1_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT1_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT1_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT1_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT1_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT2_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT2_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT2_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT2_OTH_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT2_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT2_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT2_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT2_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT2_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT2_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT2_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT2_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT2_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT2_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT2_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT2_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT3_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT3_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT3_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT3_OTH_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT3_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT3_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT3_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT3_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT3_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT3_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT3_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT3_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT3_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT3_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT3_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT3_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT4_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT4_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT4_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT4_OTH_COMP_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT4_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT4_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT4_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT4_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT4_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT4_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT4_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT4_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_EMPLOYEE_NUMBER               IN     VARCHAR2    DEFAULT NULL
   ,P_EMP_CATEGORY                  IN     VARCHAR2    DEFAULT NULL
   ,P_ASSIGNMENT_STATUS             IN     VARCHAR2    DEFAULT NULL
   ,P_PEOPLE_GROUP_NAME             IN     VARCHAR2    DEFAULT NULL
   ,P_EMAIL_ADDR                    IN     VARCHAR2    DEFAULT NULL
   ,P_START_DATE                    IN     DATE	       DEFAULT NULL
   ,P_ORIGINAL_START_DATE           IN     DATE	       DEFAULT NULL
   ,P_NORMAL_HOURS                  IN     NUMBER      DEFAULT NULL
   ,P_PAYROLL_NAME                  IN     VARCHAR2    DEFAULT NULL
   ,P_BUSINESS_GROUP_NAME           IN     VARCHAR2    DEFAULT NULL
   ,P_ORG_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_LOC_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_JOB_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_POS_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_GRD_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_COUNTRY                       IN     VARCHAR2    DEFAULT NULL
   ,P_YEARS_IN_JOB                  IN     NUMBER      DEFAULT NULL
   ,P_YEARS_IN_POSITION             IN     NUMBER      DEFAULT NULL
   ,P_YEARS_IN_GRADE                IN     NUMBER      DEFAULT NULL
   ,P_GRADE_RANGE                   IN     VARCHAR2    DEFAULT NULL
   ,P_GRADE_MID_POINT               IN     NUMBER      DEFAULT NULL
   ,P_GRD_QUARTILE                  IN     VARCHAR2    DEFAULT NULL
   ,P_GRD_COMPARATIO                IN     NUMBER      DEFAULT NULL
   ,P_PERFORMANCE_RATING            IN     VARCHAR2    DEFAULT NULL
   ,P_PERFORMANCE_RATING_TYPE       IN     VARCHAR2    DEFAULT NULL
   ,P_PERFORMANCE_RATING_DATE       IN     DATE	       DEFAULT NULL
   ,P_LAST_RANK                     IN     NUMBER      DEFAULT NULL
   ,P_LAST_MGR_NAME                 IN     VARCHAR2    DEFAULT NULL
   ,P_RANK_QUARTILE                 IN     NUMBER      DEFAULT NULL
   ,P_TOTAL_RANK                    IN     NUMBER      DEFAULT NULL
   ,P_CHANGE_REASON                 IN     VARCHAR2    DEFAULT default_string
   ,P_BASE_SALARY_CHANGE_DATE       IN     DATE	       DEFAULT NULL
   ,P_LF_EVT_OCRD_DT                IN     DATE	       DEFAULT NULL
   ,P_MGR_LER_ID                    IN     NUMBER      DEFAULT NULL
   ,P_PL_PERSON_RATE_ID             IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT1_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT2_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT3_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT4_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_LVL_NUM		            IN     NUMBER      DEFAULT NULL
   ,P_CUSTOM_SEGMENT1	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT2	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT3	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT4	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT5	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT6	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT7	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT8	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT9	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT10	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT11	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT12	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT13	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT14	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT15	            IN     NUMBER      DEFAULT default_number
   ,P_PROPOSED_PERFORMANCE_RATING   IN     VARCHAR2    DEFAULT NULL
   ,P_PROPOSED_JOB	            IN     VARCHAR2    DEFAULT default_string
   ,P_PLAN_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_USER_ID                       IN     VARCHAR2    DEFAULT NULL
   ,P_PROPOSED_GRADE                IN     VARCHAR2    DEFAULT default_string
   ,P_PROPOSED_POSITION             IN     VARCHAR2    DEFAULT default_string
   ,P_PROPOSED_GROUP                IN     VARCHAR2    DEFAULT NULL
   ,P_TASK_ID                       IN     VARCHAR2    DEFAULT NULL
   ,P_SEC_MGR_LER_ID		    IN     VARCHAR2    DEFAULT NULL
   ,P_ACTING_PERSON_ID		    IN     VARCHAR2    DEFAULT NULL
   ,P_DOWNLOAD_SWITCH               IN     VARCHAR2    DEFAULT NULL
   ,P_CPI_ATTRIBUTE_CATEGORY        IN     VARCHAR2    DEFAULT NULL
   ,P_CPI_ATTRIBUTE1                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE2                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE3                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE4                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE5                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE6                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE7                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE8                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE9                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE10               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE11               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE12               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE13               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE14               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE15               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE16               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE17               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE18               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE19               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE20               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE21               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE22               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE23               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE24               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE25               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE26               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE27               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE28               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE29               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE30               IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT16	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT17	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT18	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT19	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT20	            IN     NUMBER      DEFAULT default_number
   ,P_PL_CURRENCY                   IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_PL_RT_START_DATE              IN     DATE        DEFAULT default_date
   ,P_OPT1_RT_START_DATE            IN     DATE        DEFAULT default_date
   ,P_OPT2_RT_START_DATE            IN     DATE        DEFAULT default_date
   ,P_OPT3_RT_START_DATE            IN     DATE        DEFAULT default_date
   ,P_OPT4_RT_START_DATE            IN     DATE        DEFAULT default_date
);


procedure insert_new_rank
          (p_assignment_id            in number
          ,p_rank                     in number
          ,p_rank_by_person_id        in number
          ,p_level_number             in number
          ,p_assignment_extra_info_id out NOCOPY number
          ,p_object_version_number    out NOCOPY number);

function check_varchar_col_avble(old_val varchar2, new_val varchar2)
return varchar2;

function check_number_col_avble(old_val number, new_val number)
return NUMBER;

END BEN_CWB_WS_IMPORT_PKG;

/

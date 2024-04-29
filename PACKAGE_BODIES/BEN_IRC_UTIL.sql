--------------------------------------------------------
--  DDL for Package Body BEN_IRC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_IRC_UTIL" as
/* $Header: beircutl.pkb 120.4 2008/02/18 08:06:32 rtagarra noship $ */
--
g_package   varchar2(80) := 'ben_irc_util';

/**
pay_proposal_rec_change function compares the two structures.
returns true if there is any change
returns false, otherwise
**/
function pay_proposal_rec_change(p_pay_proposal_rec_old in per_pay_proposals%ROWTYPE,
                                 p_pay_proposal_rec_new in per_pay_proposals%ROWTYPE) return boolean is
   begin
  -- dbms_output.put_line('Entering pay');

   if
  nvl(p_pay_proposal_rec_old.PAY_PROPOSAL_ID ,hr_api.g_number   )       <>      nvl(p_pay_proposal_rec_new.PAY_PROPOSAL_ID,hr_api.g_number       )
OR nvl(p_pay_proposal_rec_old.PROPOSED_SALARY_N ,hr_api.g_number )	 <>	nvl(p_pay_proposal_rec_new.PROPOSED_SALARY_N ,hr_api.g_number)
OR nvl(p_pay_proposal_rec_old.ASSIGNMENT_ID ,hr_api.g_number     )       <>   nvl(p_pay_proposal_rec_new.ASSIGNMENT_ID,hr_api.g_number         )
OR nvl(p_pay_proposal_rec_old.EVENT_ID,hr_api.g_number           )       <>   nvl(p_pay_proposal_rec_new.EVENT_ID  ,hr_api.g_number            )
OR nvl(p_pay_proposal_rec_old.BUSINESS_GROUP_ID ,hr_api.g_number )       <>   nvl(p_pay_proposal_rec_new.BUSINESS_GROUP_ID,hr_api.g_number     )
OR nvl(p_pay_proposal_rec_old.FORCED_RANKING,hr_api.g_number     )       <>   nvl(p_pay_proposal_rec_new.FORCED_RANKING,hr_api.g_number        )
OR nvl(p_pay_proposal_rec_old.PERFORMANCE_REVIEW_ID,hr_api.g_number )	 <>   nvl(p_pay_proposal_rec_new.PERFORMANCE_REVIEW_ID,hr_api.g_number )
OR nvl(p_pay_proposal_rec_old.APPROVED,hr_api.g_varchar2            )    <>   nvl(p_pay_proposal_rec_new.APPROVED,hr_api.g_varchar2              )
OR nvl(p_pay_proposal_rec_old.MULTIPLE_COMPONENTS,hr_api.g_varchar2 )    <>   nvl(p_pay_proposal_rec_new.MULTIPLE_COMPONENTS,hr_api.g_varchar2   )
OR nvl(p_pay_proposal_rec_old.CHANGE_DATE,hr_api.g_date           )      <>   nvl(p_pay_proposal_rec_new.CHANGE_DATE ,hr_api.g_date          )
OR nvl(p_pay_proposal_rec_old.LAST_CHANGE_DATE ,hr_api.g_date     )      <>   nvl(p_pay_proposal_rec_new.LAST_CHANGE_DATE ,hr_api.g_date     )
OR nvl(p_pay_proposal_rec_old.NEXT_PERF_REVIEW_DATE ,hr_api.g_date )     <>   nvl(p_pay_proposal_rec_new.NEXT_PERF_REVIEW_DATE,hr_api.g_date )
OR nvl(p_pay_proposal_rec_old.NEXT_SAL_REVIEW_DATE,hr_api.g_date  )      <>   nvl(p_pay_proposal_rec_new.NEXT_SAL_REVIEW_DATE,hr_api.g_date  )
OR nvl(p_pay_proposal_rec_old.PERFORMANCE_RATING,hr_api.g_varchar2  )    <>   nvl(p_pay_proposal_rec_new.PERFORMANCE_RATING,hr_api.g_varchar2    )
OR nvl(p_pay_proposal_rec_old.PROPOSAL_REASON,hr_api.g_varchar2     )    <>   nvl(p_pay_proposal_rec_new.PROPOSAL_REASON,hr_api.g_varchar2       )
OR nvl(p_pay_proposal_rec_old.PROPOSED_SALARY ,hr_api.g_varchar2    )    <>   nvl(p_pay_proposal_rec_new.PROPOSED_SALARY,hr_api.g_varchar2       )
OR nvl(p_pay_proposal_rec_old.REVIEW_DATE ,hr_api.g_date            )    <>   nvl(p_pay_proposal_rec_new.REVIEW_DATE,hr_api.g_date           )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE_CATEGORY,hr_api.g_varchar2  )    <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE_CATEGORY,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE1,hr_api.g_varchar2  )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE1,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE2 ,hr_api.g_varchar2 )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE2,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE3 ,hr_api.g_varchar2 )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE3,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE4,hr_api.g_varchar2  )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE4,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE5 ,hr_api.g_varchar2 )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE5,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE6,hr_api.g_varchar2  )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE6 ,hr_api.g_varchar2 )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE7 ,hr_api.g_varchar2 )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE7,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE8 ,hr_api.g_varchar2 )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE8,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE9 ,hr_api.g_varchar2 )       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE9,hr_api.g_varchar2  )
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE10 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE10 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE11 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE11 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE12 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE12 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE13 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE13 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE14 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE14 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE15 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE15 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE16 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE16 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE17 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE17 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE18 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE18 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE19 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE19 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.ATTRIBUTE20 ,hr_api.g_varchar2)       <>   nvl(p_pay_proposal_rec_new.ATTRIBUTE20 ,hr_api.g_varchar2)
OR nvl(p_pay_proposal_rec_old.OBJECT_VERSION_NUMBER ,hr_api.g_number) <>   nvl(p_pay_proposal_rec_new.OBJECT_VERSION_NUMBER,hr_api.g_number )
 then
     return true;
   else
     return false;
   end if;
end pay_proposal_rec_change;

/**
offer_assignment_rec_change function compares the two structures.
returns true if there is any change
returns false, otherwise
**/
 function offer_assignment_rec_change(p_offer_assignment_rec_old in per_all_assignments_f%rowtype,
                                      p_offer_assignment_rec_new in per_all_assignments_f%rowtype)
				      return boolean is

begin
--dbms_output.put_line('Entering offer');

   if
 nvl(p_offer_assignment_rec_old.RECRUITER_ID,hr_api.g_number)                      <>   nvl(p_offer_assignment_rec_new.RECRUITER_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.GRADE_ID,hr_api.g_number)                       <>   nvl(p_offer_assignment_rec_new.GRADE_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.POSITION_ID,hr_api.g_number)                    <>   nvl(p_offer_assignment_rec_new.POSITION_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.JOB_ID,hr_api.g_number)                         <>   nvl(p_offer_assignment_rec_new.JOB_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.ASSIGNMENT_STATUS_TYPE_ID,hr_api.g_number)      <>   nvl(p_offer_assignment_rec_new.ASSIGNMENT_STATUS_TYPE_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PAYROLL_ID,hr_api.g_number)                     <>   nvl(p_offer_assignment_rec_new.PAYROLL_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.LOCATION_ID,hr_api.g_number)                    <>   nvl(p_offer_assignment_rec_new.LOCATION_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PERSON_REFERRED_BY_ID,hr_api.g_number)          <>   nvl(p_offer_assignment_rec_new.PERSON_REFERRED_BY_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SUPERVISOR_ID,hr_api.g_number)                  <>   nvl(p_offer_assignment_rec_new.SUPERVISOR_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SPECIAL_CEILING_STEP_ID,hr_api.g_number)        <>   nvl(p_offer_assignment_rec_new.SPECIAL_CEILING_STEP_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PERSON_ID,hr_api.g_number)                      <>   nvl(p_offer_assignment_rec_new.PERSON_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.RECRUITMENT_ACTIVITY_ID,hr_api.g_number)        <>   nvl(p_offer_assignment_rec_new.RECRUITMENT_ACTIVITY_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SOURCE_ORGANIZATION_ID,hr_api.g_number)         <>   nvl(p_offer_assignment_rec_new.SOURCE_ORGANIZATION_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.ORGANIZATION_ID,hr_api.g_number)                <>   nvl(p_offer_assignment_rec_new.ORGANIZATION_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PEOPLE_GROUP_ID,hr_api.g_number)                <>   nvl(p_offer_assignment_rec_new.PEOPLE_GROUP_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SOFT_CODING_KEYFLEX_ID,hr_api.g_number)         <>   nvl(p_offer_assignment_rec_new.SOFT_CODING_KEYFLEX_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.VACANCY_ID,hr_api.g_number)                     <>   nvl(p_offer_assignment_rec_new.VACANCY_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PAY_BASIS_ID,hr_api.g_number)                   <>   nvl(p_offer_assignment_rec_new.PAY_BASIS_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.ASSIGNMENT_SEQUENCE,hr_api.g_number)	   <>   nvl(p_offer_assignment_rec_new.ASSIGNMENT_SEQUENCE,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.APPLICATION_ID,hr_api.g_number)                 <>   nvl(p_offer_assignment_rec_new.APPLICATION_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.ASSIGNMENT_NUMBER ,hr_api.g_varchar2)           <>   nvl(p_offer_assignment_rec_new.ASSIGNMENT_NUMBER ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.CHANGE_REASON ,hr_api.g_varchar2)               <>   nvl(p_offer_assignment_rec_new.CHANGE_REASON ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.COMMENT_ID,hr_api.g_number)                     <>   nvl(p_offer_assignment_rec_new.COMMENT_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.DATE_PROBATION_END,hr_api.g_date)               <>   nvl(p_offer_assignment_rec_new.DATE_PROBATION_END,hr_api.g_date)
 OR nvl(p_offer_assignment_rec_old.DEFAULT_CODE_COMB_ID,hr_api.g_number)           <>   nvl(p_offer_assignment_rec_new.DEFAULT_CODE_COMB_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.EMPLOYMENT_CATEGORY ,hr_api.g_varchar2)         <>   nvl(p_offer_assignment_rec_new.EMPLOYMENT_CATEGORY,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.FREQUENCY ,hr_api.g_varchar2)                   <>   nvl(p_offer_assignment_rec_new.FREQUENCY ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.INTERNAL_ADDRESS_LINE,hr_api.g_varchar2)        <>   nvl(p_offer_assignment_rec_new.INTERNAL_ADDRESS_LINE,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.MANAGER_FLAG,hr_api.g_varchar2)                 <>   nvl(p_offer_assignment_rec_new.MANAGER_FLAG,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.NORMAL_HOURS ,hr_api.g_number)                <>   nvl(p_offer_assignment_rec_new.NORMAL_HOURS ,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PERF_REVIEW_PERIOD ,hr_api.g_number)          <>   nvl(p_offer_assignment_rec_new.PERF_REVIEW_PERIOD ,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PERF_REVIEW_PERIOD_FREQUENCY,hr_api.g_varchar2) <>   nvl(p_offer_assignment_rec_new.PERF_REVIEW_PERIOD_FREQUENCY ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.PERIOD_OF_SERVICE_ID,hr_api.g_number)           <>   nvl(p_offer_assignment_rec_new.PERIOD_OF_SERVICE_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PROBATION_PERIOD,hr_api.g_number)             <>   nvl(p_offer_assignment_rec_new.PROBATION_PERIOD,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PROBATION_UNIT ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.PROBATION_UNIT,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.SAL_REVIEW_PERIOD ,hr_api.g_number)           <>   nvl(p_offer_assignment_rec_new.SAL_REVIEW_PERIOD,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SAL_REVIEW_PERIOD_FREQUENCY ,hr_api.g_varchar2) <>   nvl(p_offer_assignment_rec_new.SAL_REVIEW_PERIOD_FREQUENCY ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.SET_OF_BOOKS_ID,hr_api.g_number)                <>   nvl(p_offer_assignment_rec_new.SET_OF_BOOKS_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SOURCE_TYPE ,hr_api.g_varchar2)                 <>   nvl(p_offer_assignment_rec_new.SOURCE_TYPE,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.TIME_NORMAL_FINISH,hr_api.g_varchar2)           <>   nvl(p_offer_assignment_rec_new.TIME_NORMAL_FINISH ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.TIME_NORMAL_START ,hr_api.g_varchar2)           <>   nvl(p_offer_assignment_rec_new.TIME_NORMAL_START,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.REQUEST_ID,hr_api.g_number)                     <>   nvl(p_offer_assignment_rec_new.REQUEST_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PROGRAM_APPLICATION_ID,hr_api.g_number)         <>   nvl(p_offer_assignment_rec_new.PROGRAM_APPLICATION_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PROGRAM_ID,hr_api.g_number)                     <>   nvl(p_offer_assignment_rec_new.PROGRAM_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PROGRAM_UPDATE_DATE,hr_api.g_date)              <>   nvl(p_offer_assignment_rec_new.PROGRAM_UPDATE_DATE,hr_api.g_date)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE_CATEGORY ,hr_api.g_varchar2)      <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE_CATEGORY ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE1 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE1,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE2 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE2 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE3 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE3  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE4 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE4 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE5 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE5 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE6 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE6,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE7 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE7 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE8 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE8 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE9 ,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE9 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE10,hr_api.g_varchar2)              <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE10,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE11 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE11,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE12 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE12 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE13 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE13 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE14 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE14 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE15 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE15 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE16 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE16 ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE17 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE17  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE18 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE18  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE19 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE19  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE20 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE20  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE21 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE21  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE22 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE22  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE23 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE23  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE24 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE24  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE25 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE25  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE26 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE26  ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE27 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE27   ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE28 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE28   ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE29 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE29   ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.ASS_ATTRIBUTE30 ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.ASS_ATTRIBUTE30   ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.TITLE ,hr_api.g_varchar2)                       <>   nvl(p_offer_assignment_rec_new.TITLE ,hr_api.g_varchar2)
 OR nvl(p_offer_assignment_rec_old.OBJECT_VERSION_NUMBER ,hr_api.g_number)       <>   nvl(p_offer_assignment_rec_new.OBJECT_VERSION_NUMBER,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.BARGAINING_UNIT_CODE ,hr_api.g_varchar2)        <>   nvl(p_offer_assignment_rec_new.BARGAINING_UNIT_CODE ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.LABOUR_UNION_MEMBER_FLAG,hr_api.g_varchar2)     <>   nvl(p_offer_assignment_rec_new.LABOUR_UNION_MEMBER_FLAG  ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.HOURLY_SALARIED_CODE ,hr_api.g_varchar2)        <>   nvl(p_offer_assignment_rec_new.HOURLY_SALARIED_CODE ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.CONTRACT_ID,hr_api.g_number)                    <>   nvl(p_offer_assignment_rec_new.CONTRACT_ID,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.COLLECTIVE_AGREEMENT_ID,hr_api.g_number)        <>   nvl(p_offer_assignment_rec_new.COLLECTIVE_AGREEMENT_ID,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.CAGR_ID_FLEX_NUM ,hr_api.g_number)            <>   nvl(p_offer_assignment_rec_new.CAGR_ID_FLEX_NUM ,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.CAGR_GRADE_DEF_ID,hr_api.g_number)              <>   nvl(p_offer_assignment_rec_new.CAGR_GRADE_DEF_ID,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.ESTABLISHMENT_ID,hr_api.g_number)               <>   nvl(p_offer_assignment_rec_new.ESTABLISHMENT_ID,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.NOTICE_PERIOD ,hr_api.g_number)               <>   nvl(p_offer_assignment_rec_new.NOTICE_PERIOD ,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.NOTICE_PERIOD_UOM ,hr_api.g_varchar2)           <>   nvl(p_offer_assignment_rec_new.NOTICE_PERIOD_UOM ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.EMPLOYEE_CATEGORY ,hr_api.g_varchar2)           <>   nvl(p_offer_assignment_rec_new.EMPLOYEE_CATEGORY ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.WORK_AT_HOME ,hr_api.g_varchar2)                <>   nvl(p_offer_assignment_rec_new.WORK_AT_HOME ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.JOB_POST_SOURCE_NAME ,hr_api.g_varchar2)        <>   nvl(p_offer_assignment_rec_new.JOB_POST_SOURCE_NAME ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.POSTING_CONTENT_ID,hr_api.g_number)             <>   nvl(p_offer_assignment_rec_new.POSTING_CONTENT_ID,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.PERIOD_OF_PLACEMENT_DATE_START,hr_api.g_date)   <>   nvl(p_offer_assignment_rec_new.PERIOD_OF_PLACEMENT_DATE_START,hr_api.g_date)
  OR nvl(p_offer_assignment_rec_old.VENDOR_ID,hr_api.g_number)                      <>   nvl(p_offer_assignment_rec_new.VENDOR_ID,hr_api.g_number)
  OR nvl(p_offer_assignment_rec_old.VENDOR_EMPLOYEE_NUMBER ,hr_api.g_varchar2)      <>   nvl(p_offer_assignment_rec_new.VENDOR_EMPLOYEE_NUMBER ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.VENDOR_ASSIGNMENT_NUMBER ,hr_api.g_varchar2)    <>   nvl(p_offer_assignment_rec_new.VENDOR_ASSIGNMENT_NUMBER  ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.ASSIGNMENT_CATEGORY  ,hr_api.g_varchar2)        <>   nvl(p_offer_assignment_rec_new.ASSIGNMENT_CATEGORY ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.PROJECT_TITLE   ,hr_api.g_varchar2)             <>   nvl(p_offer_assignment_rec_new.PROJECT_TITLE   ,hr_api.g_varchar2)
  OR nvl(p_offer_assignment_rec_old.APPLICANT_RANK   ,hr_api.g_number)            <>   nvl(p_offer_assignment_rec_new.APPLICANT_RANK  ,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.GRADE_LADDER_PGM_ID,hr_api.g_number)            <>   nvl(p_offer_assignment_rec_new.GRADE_LADDER_PGM_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.SUPERVISOR_ASSIGNMENT_ID,hr_api.g_number)       <>   nvl(p_offer_assignment_rec_new.SUPERVISOR_ASSIGNMENT_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.VENDOR_SITE_ID,hr_api.g_number)                 <>   nvl(p_offer_assignment_rec_new.VENDOR_SITE_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PO_HEADER_ID,hr_api.g_number)                   <>   nvl(p_offer_assignment_rec_new.PO_HEADER_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PO_LINE_ID,hr_api.g_number)                     <>   nvl(p_offer_assignment_rec_new.PO_LINE_ID,hr_api.g_number)
 OR nvl(p_offer_assignment_rec_old.PROJECTED_ASSIGNMENT_END,hr_api.g_date)         <>   nvl(p_offer_assignment_rec_new.PROJECTED_ASSIGNMENT_END,hr_api.g_date)
 OR nvl(p_offer_assignment_rec_old.BUSINESS_GROUP_ID,hr_api.g_number)              <>   nvl(p_offer_assignment_rec_new.BUSINESS_GROUP_ID,hr_api.g_number)

 then
     return true;
 else
     return false;
 end if;
end offer_assignment_rec_change;

/**
is_benmngle_for_irec_reqd function chks whether benmngle should re-run for irec.
returns Y if re-run has to happen
returns N, otherwise
**/
function is_benmngle_for_irec_reqd( p_person_id          in number,
                                p_assignment_id          in number,
				p_business_group_id      in number,
                                p_effective_date         in date,
				p_pay_proposal_rec_old   in per_pay_proposals%ROWTYPE,
				p_pay_proposal_rec_new   in per_pay_proposals%ROWTYPE,
                                p_offer_assignment_rec_old in per_all_assignments_f%rowtype,
				p_offer_assignment_rec_new in per_all_assignments_f%rowtype
				) return varchar2 is

 --
  l_proc   varchar2(80) := 'benutils.run_irc_benmngle_flag';
  l_per_last_upd_date  date;
  l_pil_last_upd_date  date;

  l_run_benmngle varchar2(30) := 'N';

  cursor c_per_last_upd_date(p_pil_last_upd_date date) is
  select max(last_update_date)
    from (select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_addresses
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_all_assignments_f
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_all_people_f
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_contact_relationships
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(psl.last_update_date,p_pil_last_upd_date)) last_update_date
            from per_pay_proposals psl, per_all_assignments_f asn
           where psl.assignment_id = asn.assignment_id
             and asn.person_id = p_person_id
             and asn.business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_periods_of_service
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_qualifications
           where person_id = p_person_id
             and business_group_id = p_business_group_id
           union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_absence_attendances
           where person_id = p_person_id
             and business_group_id = p_business_group_id
          union
          select max(nvl(last_update_date,p_pil_last_upd_date)) last_update_date
            from per_person_type_usages_f
           where person_id = p_person_id
         );


 cursor c_pil_last_upd_date is
  select  pil.last_update_date last_update_date
    from ben_per_in_ler pil , ben_ler_f ler
   where pil.person_id = p_person_id
     and pil.business_group_id = p_business_group_id
     and pil.assignment_id = p_assignment_id
     and pil.per_in_ler_stat_cd = 'STRTD'
     and ler.ler_id = pil.ler_id
     and ler.typ_cd = 'IREC'
     and p_effective_date between ler.effective_start_date and ler.effective_end_date;

 --
 begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
 -- dbms_output.put_line('Entering');
  --
  -- Get the last updated date from pil record for IREC LE run
  --
  open c_pil_last_upd_date;
  fetch c_pil_last_upd_date  into l_pil_last_upd_date;
    if c_pil_last_upd_date%NOTFOUND then
    --
    -- If IREC life event was never run yet, we need to run it for first time
    --
       l_run_benmngle := 'Y' ;
       return l_run_benmngle;

    elsif l_pil_last_upd_date is not null
    then
      -- means irec has already been run , Then chk for following:
      -- 1. if per_pay_proposals structure for Offer has chnged
      -- 2. if per_all_assignment  structure for Offer has chnged
      -- 3. if any HR info abt the person has chnged.
      --dbms_output.put_line('IREC for more than one time');
        if pay_proposal_rec_change(p_pay_proposal_rec_old,p_pay_proposal_rec_new) then
              l_run_benmngle := 'Y' ;
	      return l_run_benmngle;

	elsif offer_assignment_rec_change(p_offer_assignment_rec_old,p_offer_assignment_rec_new) then
	      l_run_benmngle := 'Y' ;
	      return l_run_benmngle;
	else
	    --
	    --dbms_output.put_line('No change in record');
           open c_per_last_upd_date(l_pil_last_upd_date);
           fetch c_per_last_upd_date into l_per_last_upd_date;
           close c_per_last_upd_date;
           --
           hr_utility.set_location('l_per_last_upd_date is '||l_per_last_upd_date, 999);
           hr_utility.set_location('l_pil_last_upd_date is '||l_pil_last_upd_date, 999);
           --
	   if (nvl(l_per_last_upd_date,l_pil_last_upd_date) > l_pil_last_upd_date) then
                  l_run_benmngle := 'Y' ;
                  return l_run_benmngle;
	   end if;
	end if; --pay_proposal_rec_change

    end if; --c_pil_last_upd_date%NOTFOUND

   return l_run_benmngle; -- returning 'N'

  end is_benmngle_for_irec_reqd;
 --
 /*** Updating the present electable choices with approval staus code .
 1.Once we get new set of electable choices,look back at the last electables voided, if any.
 2.find out which electable choices were Approved.
 3. Find out if person is still eligible for last approved electable choices.
   1.If yes , mark the new ones as 'Approved'
   2. Otherwise do nothing.
 4. Find out if there are any 'enter value at enrollment' rates corresponding to Last EPE Approved .
   1. find out if there are any 'enter value at enrollment' rates for present electable choices.
     1. If yes, update present rate record with old rate record.
     2. Otherwise do nothing.
 ***/
 PROCEDURE post_irec_process_update (
   p_person_id           IN   NUMBER,
   p_business_group_id   IN   NUMBER,
   p_assignment_id       IN   NUMBER,
   p_effective_date      IN   DATE
)
IS
-- get the latest pil which has been voided.
   CURSOR c_last_pil
   IS
      SELECT   per_in_ler_id
          FROM ben_per_in_ler pil, ben_ler_f ler
         WHERE pil.person_id = p_person_id
           AND pil.business_group_id = p_business_group_id
           AND pil.assignment_id = p_assignment_id
           AND pil.per_in_ler_stat_cd = 'BCKDT'   -- 5068367
           AND ler.ler_id = pil.ler_id
           AND ler.typ_cd = 'IREC'
           AND p_effective_date BETWEEN ler.effective_start_date
                                    AND ler.effective_end_date
      ORDER BY pil.last_update_date DESC;

   l_last_pil                NUMBER;

-- get present pil which is in started state
   CURSOR c_present_pil
   IS
      SELECT per_in_ler_id
        FROM ben_per_in_ler pil, ben_ler_f ler
       WHERE pil.person_id = p_person_id
         AND pil.business_group_id = p_business_group_id
         AND pil.assignment_id = p_assignment_id
         AND pil.per_in_ler_stat_cd = 'STRTD'
         AND ler.ler_id = pil.ler_id
         AND ler.typ_cd = 'IREC'
         AND p_effective_date BETWEEN ler.effective_start_date
                                  AND ler.effective_end_date;

   l_present_pil             NUMBER;

-- Get the all old epe's which is  approved and has common eligible comp objects
---    between old and new epe.
   CURSOR c_last_epe (p_past_pil NUMBER, p_present_pil NUMBER)
   IS
      SELECT oipl_id, pl_id, elig_per_elctbl_chc_id,comments
        FROM ben_elig_per_elctbl_chc past_epe
       WHERE past_epe.per_in_ler_id = p_past_pil
         AND past_epe.business_group_id = p_business_group_id
         AND past_epe.elctbl_flag = 'Y'
         AND past_epe.approval_status_cd = 'IRC_BEN_A'
         AND EXISTS (
                SELECT NULL
                  FROM ben_elig_per_elctbl_chc present_epe
                 WHERE present_epe.per_in_ler_id = p_present_pil
                   AND present_epe.elctbl_flag = 'Y'
                   AND present_epe.elig_flag = 'Y'
                   AND present_epe.pl_id = past_epe.pl_id
                   AND NVL (present_epe.oipl_id, present_epe.pl_id) =
                                        NVL (past_epe.oipl_id, past_epe.pl_id));

-- get the new epe id for commomn comp object
   CURSOR c_present_epe (p_present_pil NUMBER, p_pl_id NUMBER, p_oipl_id NUMBER)
   IS
      SELECT elig_per_elctbl_chc_id,object_version_number
        FROM ben_elig_per_elctbl_chc present_pil
       WHERE present_pil.per_in_ler_id = p_present_pil
         AND present_pil.elctbl_flag = 'Y'
         AND present_pil.elig_flag = 'Y'
         AND present_pil.pl_id = p_pl_id
         AND NVL (present_pil.oipl_id, present_pil.pl_id) =
                                                      NVL (p_oipl_id, p_pl_id)
         AND present_pil.business_group_id = p_business_group_id;

   l_present_epe_id          NUMBER;
   l_present_epe_ovn         NUMBER;
   l_comments                ben_elig_per_elctbl_chc.comments%TYPE;

-- Get the ecr correspoding to past epe
   CURSOR c_past_ecr (p_past_epe NUMBER)
   IS
      SELECT enrt_rt_id, val, cmcd_val, ann_val
        FROM ben_enrt_rt
       WHERE elig_per_elctbl_chc_id = p_past_epe
         AND entr_val_at_enrt_flag = 'Y'
         AND p_business_group_id = p_business_group_id;

   l_past_ecr                c_past_ecr%ROWTYPE;

--  Get the ecr correspoding to present epe
   CURSOR c_present_ecr (p_present_epe NUMBER)
   IS
      SELECT enrt_rt_id, mx_elcn_val max_val, mn_elcn_val min_val
        FROM ben_enrt_rt
       WHERE elig_per_elctbl_chc_id = p_present_epe
         AND entr_val_at_enrt_flag = 'Y'
         AND p_business_group_id = p_business_group_id;

   l_present_ecr             c_present_ecr%ROWTYPE;
--
   l_object_version_number   NUMBER;
--
BEGIN
   OPEN c_last_pil;

   FETCH c_last_pil INTO l_last_pil;

   CLOSE c_last_pil;
-- if there was any last run of benmngle.
   IF l_last_pil IS NOT NULL
   THEN
      OPEN c_present_pil;

      FETCH c_present_pil INTO l_present_pil;

      CLOSE c_present_pil;
-- Get the present epe to be marked corresponding to past epe marked 'approved'
      FOR l_last_epe IN c_last_epe (l_last_pil, l_present_pil)
      LOOP
       --
         OPEN c_present_epe (l_present_pil,
                             l_last_epe.pl_id,
                             l_last_epe.oipl_id
                            );

         FETCH c_present_epe INTO l_present_epe_id,l_present_epe_ovn;

         CLOSE c_present_epe;
         ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
                          (p_elig_per_elctbl_chc_id      => l_present_epe_id,
                           p_effective_date              => p_effective_date,
                           p_object_version_number       => l_present_epe_ovn,
                           p_approval_status_cd          => 'IRC_BEN_A',
			   p_comments			 => l_last_epe.comments
                          );
-- get the present ecr corresponding to past ecr and update the present ecr with past ecr data.
         OPEN c_past_ecr (l_last_epe.elig_per_elctbl_chc_id);

         FETCH c_past_ecr INTO l_past_ecr;

         IF c_past_ecr%FOUND
         THEN
            OPEN c_present_ecr (l_present_epe_id);

            FETCH c_present_ecr INTO l_present_ecr;

            IF c_present_ecr%FOUND
            THEN
               IF l_past_ecr.val BETWEEN l_present_ecr.min_val
                                     AND l_present_ecr.max_val
               THEN
                  ben_enrollment_rate_api.update_enrollment_rate
                          (p_enrt_rt_id                 => l_present_ecr.enrt_rt_id,
                           p_val                        => l_past_ecr.val,
                           p_cmcd_val                   => l_past_ecr.cmcd_val,
                           p_ann_val                    => l_past_ecr.ann_val,
                           p_effective_date             => p_effective_date,
                           p_object_version_number      => l_object_version_number
                          );
               END IF;
            END IF;                --c_present_ecr

            CLOSE c_present_ecr;
         END IF;                   --c_past_ecr

         CLOSE c_past_ecr;
      END LOOP;
   END IF;                         -- last_pil not null
END post_irec_process_update;
--

/***
1.Firstly,this proc VOIDs ( read as DELETE) the pil,ppl,pel
corresponding to a Deleted Transaction of IREC
2.Secondly, it restores back the latest Backed out pil,pel
 to STARTED state.
***/

PROCEDURE void_or_restore_life_event (
   p_person_id               IN   NUMBER,
   p_assignment_id           IN   NUMBER,
   p_offer_assignment_id     IN   NUMBER DEFAULT NULL,
   p_void_per_in_ler_id      IN   NUMBER DEFAULT NULL,
   p_restore_per_in_ler_id   IN   NUMBER DEFAULT NULL,
   p_status_cd               IN   VARCHAR2 DEFAULT NULL,
   p_effective_date          IN   DATE
)
IS
   CURSOR c_ptnl (c_ptnl_ler_for_per_id IN NUMBER)
   IS
      SELECT ptnl.*
        FROM ben_ptnl_ler_for_per ptnl
       WHERE ptnl.ptnl_ler_for_per_id = c_ptnl_ler_for_per_id;

   CURSOR c_pil (c_per_in_ler_id IN NUMBER)
   IS
      SELECT pil.*
        FROM ben_per_in_ler pil
       WHERE pil.per_in_ler_id = c_per_in_ler_id
         AND pil.assignment_id = p_assignment_id
         AND pil.person_id = p_person_id;

   CURSOR c_pil_elctbl_chc_popl (p_per_in_ler_id NUMBER)
   IS
      SELECT pel.pil_elctbl_chc_popl_id, pel.object_version_number
        FROM ben_pil_elctbl_chc_popl pel
       WHERE pel.per_in_ler_id = p_per_in_ler_id;

   CURSOR c_latest_ler
   IS
      SELECT   pil.per_in_ler_id
          FROM ben_per_in_ler pil, ben_ler_f ler
         WHERE pil.person_id = p_person_id
           AND pil.assignment_id = p_assignment_id
           AND pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
           AND pil.ler_id = ler.ler_id
           AND ler.typ_cd = 'IREC'
           AND p_effective_date BETWEEN ler.effective_start_date
                                    AND ler.effective_end_date
      ORDER BY pil.per_in_ler_id DESC;

   CURSOR c_latest_bckdt_ler
   IS
      SELECT   pil.per_in_ler_id
          FROM ben_per_in_ler pil, ben_ler_f ler
         WHERE pil.person_id = p_person_id
           AND pil.assignment_id = p_assignment_id
           AND pil.per_in_ler_stat_cd = 'BCKDT'
           AND pil.ler_id = ler.ler_id
           AND ler.typ_cd = 'IREC'
           AND p_effective_date BETWEEN ler.effective_start_date
                                    AND ler.effective_end_date
      ORDER BY pil.per_in_ler_id DESC;

   CURSOR c_pil_strt
   IS
      SELECT NULL
        FROM ben_per_in_ler pil
       WHERE pil.per_in_ler_id <> p_restore_per_in_ler_id
         AND pil.per_in_ler_stat_cd IN ('STRTD', 'PROCD')
         AND pil.assignment_id = p_assignment_id
         AND pil.person_id = p_person_id;

   CURSOR c_get_pil
   IS
      SELECT *
        FROM ben_per_in_ler
       WHERE assignment_id = p_assignment_id
         AND per_in_ler_stat_cd NOT IN ('VOIDD', 'PROCD')
         AND per_in_ler_id >
                (SELECT NVL (MAX (per_in_ler_id), -1)
                   FROM ben_pil_assignment
                  WHERE offer_assignment_id IS NOT NULL
                    AND applicant_assignment_id = p_assignment_id);

--

   l_pil                         c_pil%ROWTYPE;
   l_latest_ler                  c_latest_ler%ROWTYPE;
   l_ptnl                        c_ptnl%ROWTYPE;
   l_pil_strt                    c_pil_strt%ROWTYPE;
   l_get_pil                     c_get_pil%ROWTYPE;
   l_procd_dt                    DATE;
   l_strtd_dt                    DATE;
   l_voidd_dt                    DATE;
   l_pel_object_version_number   NUMBER;
   l_pel_pk_id                   NUMBER;
--
BEGIN
   /*** Voiding
       1.Dont void if pil is in PROCESSED state ,throw error
       2.Dont Void if it is not the latest one ,throw error
       3.Update person_life_event (PIL)
       4.update potential Life event (PPL)
       5.update pil_electbl_choice_popl (PEL)
   ***/
   hr_utility.set_location (' Entering ben_irc_util.void_or_restore_life_event ',
                            10
                           );
/***
p_void_per_in_ler_id As null
***/
   IF p_void_per_in_ler_id IS NULL
   THEN
      hr_utility.set_location ('p_void_per_in_ler_id is NULL ', 888);
      OPEN c_get_pil;

      LOOP
         FETCH c_get_pil INTO l_get_pil;
         EXIT WHEN c_get_pil%NOTFOUND;
         /*** Update PIl,PEL,PPL
         ***/
         hr_utility.set_location ('Voiding starts ', 999);
         hr_utility.set_location ('Before update_person_life_event ', 9901);
         ben_person_life_event_api.update_person_life_event (p_per_in_ler_id              => l_get_pil.per_in_ler_id,
                                                             p_bckt_per_in_ler_id         => NULL,
                                                             p_per_in_ler_stat_cd         => 'VOIDD',
                                                             p_prvs_stat_cd               => l_get_pil.per_in_ler_stat_cd,
                                                             p_object_version_number      => l_get_pil.object_version_number,
                                                             p_effective_date             => p_effective_date,
                                                             p_procd_dt                   => l_procd_dt,
                                                             p_strtd_dt                   => l_strtd_dt,
                                                             p_voidd_dt                   => l_voidd_dt
                                                            );
         OPEN c_ptnl (l_get_pil.ptnl_ler_for_per_id);
         FETCH c_ptnl INTO l_ptnl;
         CLOSE c_ptnl;
         hr_utility.set_location ('Before update_ptnl_ler_for_per_perf ',
                                  9902);
         ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf (p_validate                      => FALSE,
                                                                p_ptnl_ler_for_per_id           => l_ptnl.ptnl_ler_for_per_id,
                                                                p_ptnl_ler_for_per_stat_cd      => 'VOIDD',
                                                                p_person_id                     => l_ptnl.person_id,
                                                                p_business_group_id             => l_ptnl.business_group_id,
                                                                p_object_version_number         => l_ptnl.object_version_number,
                                                                p_effective_date                => p_effective_date,
                                                                p_program_application_id        => fnd_global.prog_appl_id,
                                                                p_program_id                    => fnd_global.conc_program_id,
                                                                p_request_id                    => fnd_global.conc_request_id,
                                                                p_program_update_date           => SYSDATE,
                                                                p_voidd_dt                      => p_effective_date
                                                               );
         OPEN c_pil_elctbl_chc_popl (l_get_pil.per_in_ler_id);
         hr_utility.set_location ('Before update_pil_elctbl_chc_popl ', 9903);

         LOOP
            FETCH c_pil_elctbl_chc_popl INTO l_pel_pk_id,
             l_pel_object_version_number;
            EXIT WHEN c_pil_elctbl_chc_popl%NOTFOUND;
            --
            ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl (p_validate                     => FALSE,
                                                                    p_pil_elctbl_chc_popl_id       => l_pel_pk_id,
                                                                    p_pil_elctbl_popl_stat_cd      => 'BCKDT',
                                                                    p_object_version_number        => l_pel_object_version_number,
                                                                    p_effective_date               => p_effective_date
                                                                   );
         END LOOP;

         hr_utility.set_location ('After update_pil_elctbl_chc_popl ', 9904);
         CLOSE c_pil_elctbl_chc_popl;
      END LOOP;

      CLOSE c_get_pil;
   END IF; -- p_void_per_in_ler_id IS NULL

/***
p_void_per_in_ler_id not null
***/
   IF p_void_per_in_ler_id IS NOT NULL
   THEN
      -- Step 1
      hr_utility.set_location ('p_void_per_in_ler_id is NOT NULL ', 888);
      OPEN c_pil (p_void_per_in_ler_id);
      FETCH c_pil INTO l_pil;
      CLOSE c_pil;

      IF l_pil.per_in_ler_stat_cd = 'PROCD'
      THEN
         fnd_message.set_name ('BEN', 'BEN_94597_IRC_OFFER_PROCESSED');
         fnd_message.raise_error;
      END IF;

-- Step 2
      OPEN c_latest_ler;
      FETCH c_latest_ler INTO l_latest_ler;

      IF c_latest_ler%FOUND
      THEN
         IF l_latest_ler.per_in_ler_id <> p_void_per_in_ler_id
         THEN
            CLOSE c_latest_ler;
            fnd_message.set_name ('BEN', 'BEN_92216_NOT_LATST_PER_IN_LER');
            fnd_message.raise_error;
         END IF;
      END IF;

      CLOSE c_latest_ler;

      IF l_pil.per_in_ler_stat_cd <> 'VOIDD'
      THEN
         --step 3
         hr_utility.set_location ('Voiding starts ', 222);
         hr_utility.set_location ('Before update_person_life_event ', 111);
         ben_person_life_event_api.update_person_life_event (p_per_in_ler_id              => p_void_per_in_ler_id,
                                                             p_bckt_per_in_ler_id         => NULL,
                                                             p_per_in_ler_stat_cd         => 'VOIDD',
                                                             p_prvs_stat_cd               => l_pil.per_in_ler_stat_cd,
                                                             p_object_version_number      => l_pil.object_version_number,
                                                             p_effective_date             => p_effective_date,
                                                             p_procd_dt                   => l_procd_dt,
                                                             p_strtd_dt                   => l_strtd_dt,
                                                             p_voidd_dt                   => l_voidd_dt
                                                            );
         hr_utility.set_location ('After update_person_life_event ', 111);
         -- step 4
         OPEN c_ptnl (l_pil.ptnl_ler_for_per_id);
         FETCH c_ptnl INTO l_ptnl;
         CLOSE c_ptnl;
         hr_utility.set_location ('Before update_ptnl_ler_for_per_perf ', 111);
         ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf (p_validate                      => FALSE,
                                                                p_ptnl_ler_for_per_id           => l_ptnl.ptnl_ler_for_per_id,
                                                                p_ptnl_ler_for_per_stat_cd      => 'VOIDD',
                                                                p_person_id                     => l_ptnl.person_id,
                                                                p_business_group_id             => l_ptnl.business_group_id,
                                                                p_object_version_number         => l_ptnl.object_version_number,
                                                                p_effective_date                => p_effective_date,
                                                                p_program_application_id        => fnd_global.prog_appl_id,
                                                                p_program_id                    => fnd_global.conc_program_id,
                                                                p_request_id                    => fnd_global.conc_request_id,
                                                                p_program_update_date           => SYSDATE,
                                                                p_voidd_dt                      => p_effective_date
                                                               );
         hr_utility.set_location ('After update_ptnl_ler_for_per_perf ', 111);
         -- step 5
         OPEN c_pil_elctbl_chc_popl (p_void_per_in_ler_id);
         hr_utility.set_location ('Before update_pil_elctbl_chc_popl ', 111);

         LOOP
            FETCH c_pil_elctbl_chc_popl INTO l_pel_pk_id,
             l_pel_object_version_number;
            EXIT WHEN c_pil_elctbl_chc_popl%NOTFOUND;
            --
            ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl (p_validate                     => FALSE,
                                                                    p_pil_elctbl_chc_popl_id       => l_pel_pk_id,
                                                                    p_pil_elctbl_popl_stat_cd      => 'BCKDT',
                                                                    p_object_version_number        => l_pel_object_version_number,
                                                                    p_effective_date               => p_effective_date
                                                                   );
         END LOOP;

         hr_utility.set_location ('After update_pil_elctbl_chc_popl ', 111);
         CLOSE c_pil_elctbl_chc_popl;
      END IF; --l_pil.per_in_ler_stat_cd <> 'VOIDD'
   END IF; --p_void_per_in_ler_id IS NOT NULL

/*** Restoring
     1.Dont restore (/ STRTED ) if pil is in PROCESSED state ,throw error
     2.Dont restore ( / STRTED ) if there is already one in STARTED ,throw error
     3.Dont restore if its not the latest backed out pil
     3.Update person_life_event (PIL)
     4.update potential Life event (PPL)
     5.update pil_electbl_choice_popl (PEL)
 ***/
  -- Step 1
   IF p_restore_per_in_ler_id IS NOT NULL
   THEN
      OPEN c_pil (p_restore_per_in_ler_id);
      FETCH c_pil INTO l_pil;
      CLOSE c_pil;

      IF l_pil.per_in_ler_stat_cd = 'PROCD'
      THEN
         fnd_message.set_name ('BEN', 'BEN_94597_IRC_OFFER_PROCESSED');
         fnd_message.raise_error;
      END IF;

-- Step 2
      OPEN c_latest_bckdt_ler;
      FETCH c_latest_bckdt_ler INTO l_latest_ler;

      IF c_latest_bckdt_ler%FOUND
      THEN
         IF l_latest_ler.per_in_ler_id <> p_restore_per_in_ler_id
         THEN
            CLOSE c_latest_bckdt_ler;
            fnd_message.set_name ('BEN', 'BEN_94599_NOT_LATST_BCKDT');
            fnd_message.raise_error;
         END IF;
      END IF;

      CLOSE c_latest_bckdt_ler;
      -- step 3
      OPEN c_pil_strt;
      FETCH c_pil_strt INTO l_pil_strt;

      IF c_pil_strt%FOUND
      THEN
         CLOSE c_pil_strt;
         fnd_message.set_name ('BEN', 'BEN_94598_ALREADY_ACTIVE');
         fnd_message.raise_error;
      END IF;

      CLOSE c_pil_strt;

      IF l_pil.per_in_ler_stat_cd NOT IN ('STRTD', 'VOIDD')
      THEN
         -- Step 4
         hr_utility.set_location ('Restoring starts ', 222);
         hr_utility.set_location ('Before update_person_life_event ', 222);
         ben_person_life_event_api.update_person_life_event (p_per_in_ler_id              => p_restore_per_in_ler_id,
                                                             p_bckt_per_in_ler_id         => NULL,
                                                             p_per_in_ler_stat_cd         => 'STRTD',
                                                             p_prvs_stat_cd               => l_pil.per_in_ler_stat_cd,
                                                             p_object_version_number      => l_pil.object_version_number,
                                                             p_effective_date             => p_effective_date,
                                                             p_procd_dt                   => l_procd_dt,
                                                             p_strtd_dt                   => l_strtd_dt,
                                                             p_voidd_dt                   => l_voidd_dt
                                                            );
         hr_utility.set_location ('After update_person_life_event ', 222);
         -- step 5
         OPEN c_ptnl (l_pil.ptnl_ler_for_per_id);
         FETCH c_ptnl INTO l_ptnl;
         CLOSE c_ptnl;
         hr_utility.set_location ('Before update_ptnl_ler_for_per_perf ', 222);
         ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf (p_validate                      => FALSE,
                                                                p_ptnl_ler_for_per_id           => l_ptnl.ptnl_ler_for_per_id,
                                                                p_ptnl_ler_for_per_stat_cd      => 'PROCD',
                                                                p_lf_evt_ocrd_dt                => l_pil.lf_evt_ocrd_dt,
                                                                p_procd_dt                      => l_pil.lf_evt_ocrd_dt,
                                                                p_person_id                     => l_ptnl.person_id,
                                                                p_business_group_id             => l_ptnl.business_group_id,
                                                                p_object_version_number         => l_ptnl.object_version_number,
                                                                p_effective_date                => p_effective_date,
                                                                p_program_application_id        => fnd_global.prog_appl_id,
                                                                p_program_id                    => fnd_global.conc_program_id,
                                                                p_request_id                    => fnd_global.conc_request_id,
                                                                p_program_update_date           => SYSDATE
                                                               );
         hr_utility.set_location ('After update_ptnl_ler_for_per_perf ', 222);
         -- step 6
         OPEN c_pil_elctbl_chc_popl (l_pil.per_in_ler_id);
         hr_utility.set_location ('Before update_pil_elctbl_chc_popl ', 222);

         LOOP
            FETCH c_pil_elctbl_chc_popl INTO l_pel_pk_id,
             l_pel_object_version_number;
            EXIT WHEN c_pil_elctbl_chc_popl%NOTFOUND;
            ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl (p_validate                     => FALSE,
                                                                    p_pil_elctbl_chc_popl_id       => l_pel_pk_id,
                                                                    p_pil_elctbl_popl_stat_cd      => 'STRTD',
                                                                    p_object_version_number        => l_pel_object_version_number,
                                                                    p_effective_date               => p_effective_date
                                                                   );
         END LOOP;

         hr_utility.set_location ('After update_pil_elctbl_chc_popl ', 222);
         CLOSE c_pil_elctbl_chc_popl;
      END IF;
   END IF; --IF     p_restore_per_in_ler_id IS NOT NULL

   hr_utility.set_location ('Leaving ben_irc_util.void_or_restore_life_event',
                            20
                           );
END void_or_restore_life_event;

end ben_irc_util;

/

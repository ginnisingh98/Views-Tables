--------------------------------------------------------
--  DDL for Package HR_MEE_VIEWS_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MEE_VIEWS_GEN" AUTHID CURRENT_USER AS
/* $Header: hrmegviw.pkh 120.6.12010000.2 2009/07/17 08:22:24 gpurohit ship $ */

TYPE gtt_segment IS RECORD (
  value        VARCHAR2(240)
);

g_hours_per_day NUMBER:=8;

--bug 5890210
function getCostCenter(
      p_assignment_id NUMBER
    ) return varchar2;
--bug 5890210

FUNCTION getCompRatio(
    p_from_currency IN VARCHAR2
   ,p_to_currency IN VARCHAR2
   ,p_annual_salary IN NUMBER
   ,p_annual_grade_mid_value IN NUMBER
   ,p_eff_date IN DATE) RETURN NUMBER;

Function getCompRatio(
    p_from_currency IN VARCHAR2
   ,p_to_currency IN VARCHAR2
   ,p_assignment_id in number
   ,P_Effective_Date  in date
   ,p_proposed_salary IN NUMBER
   ,p_pay_annual_factor IN number
   ,p_pay_basis in varchar2
   ,p_grade_annual_factor  in number
   ,p_grade_basis  in varchar2
   ,p_grade_mid_value  in number
   ) return number;

FUNCTION convertAmount(
    p_from_currency IN VARCHAR2
   ,p_to_currency IN VARCHAR2
   ,p_amount IN NUMBER
   ,p_eff_Date IN DATE DEFAULT NULL
   ) RETURN NUMBER;

FUNCTION get_grade_details(
    p_assignment_id IN number,
    p_mode in varchar2
   ) RETURN NUMBER;

function get_step_details(
    p_step_id in number,
    p_eff_date in date,
    p_mode in varchar2
    ) return varchar2;

function get_step_num(
    p_step_id in number,
    p_eff_date in date
    ) return number;

FUNCTION convertDuration(
    p_from_duration_units IN VARCHAR2
   ,p_to_duration_units IN VARCHAR2
   ,p_from_duration IN NUMBER) RETURN NUMBER;

FUNCTION amtInLoginPrsnCurrency(
    p_from_currency IN VARCHAR2
   ,p_amount IN NUMBER
   ,p_eff_date IN DATE) RETURN NUMBER;

FUNCTION getEffDate RETURN DATE;

FUNCTION getAvgClassesPerYear(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getTrngDays(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getTrngDaysYTD(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getTrngHrs(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getTrngCost(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getTrngCostYTD(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION get_training_center (p_training_center_id in number) RETURN VARCHAR2;

FUNCTION getTrngPrctOnPayroll(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getLoginPrsnCurrencyCode RETURN VARCHAR2;

FUNCTION getClassesTaken(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE Default getEffDate) RETURN NUMBER;

FUNCTION getFutureClasses(
    p_person_id IN NUMBER
   ,p_eff_date IN DATE Default getEffDate) RETURN NUMBER;

FUNCTION getReqClasses(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getReqClassesYTD(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getReqClassesCompleted(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getReqClassesCompletedYTD(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getReqClassesEnrolled(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getYOSDenominator(p_person_id IN NUMBER) RETURN NUMBER;

FUNCTION getYOS(
	p_person_id IN NUMBER
       ,p_eff_date IN DATE Default getEffDate) RETURN NUMBER;

TYPE segmentsTable IS TABLE OF gtt_segment INDEX BY BINARY_INTEGER;

FUNCTION getAsgGradeRule(p_pay_proposal_id IN NUMBER) RETURN ROWID;

PRAGMA RESTRICT_REFERENCES (getAsgGradeRule, WNDS);

FUNCTION getAsgProposalId(p_assignment_id IN NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getAsgProposalId, WNDS);

FUNCTION getPrsnApplicationId(p_person_id IN NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getPrsnApplicationId, WNDS);

FUNCTION getPrsnPerformanceId(p_person_id IN NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getPrsnPerformanceId, WNDS);

FUNCTION get_total_absences(p_person_id IN NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES
  (get_total_absences, WNDS);

FUNCTION get_total_absence_hours(p_person_id IN NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES
  (get_total_absence_hours, WNDS);

FUNCTION get_total_absence_days(p_person_id IN NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES
  (get_total_absence_days, WNDS);

FUNCTION get_years_of_service(p_person_id IN NUMBER)
RETURN NUMBER;

FUNCTION getAYOS(p_person_id IN NUMBER,p_eff_date IN DATE Default getEffDate)
RETURN NUMBER;

FUNCTION get_last_application_date(p_person_id IN NUMBER)
RETURN DATE;

PRAGMA RESTRICT_REFERENCES
  (get_last_application_date, WNDS);

FUNCTION get_past_classes(p_person_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_future_classes(p_person_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_other_classes(p_person_id IN NUMBER)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES
  (get_other_classes, WNDS);

FUNCTION get_currency(p_assignment_id IN per_assignments_f.assignment_id%TYPE
                     ,p_change_date   IN DATE)

RETURN pay_element_types_f.input_currency_code%TYPE;

PRAGMA RESTRICT_REFERENCES
  (get_currency, WNDS);

FUNCTION get_annual_salary(
           p_assignment_id IN per_assignments_f.assignment_id%TYPE,
           p_change_date   IN DATE
         )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES
  (get_annual_salary, WNDS);

FUNCTION get_job(p_job_id IN per_assignments_f.job_id%TYPE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES
  (get_job, WNDS);

FUNCTION get_grade(p_grade_id IN per_assignments_f.grade_id%TYPE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES
  (get_grade, WNDS);

FUNCTION get_position(p_position_id IN per_assignments_f.position_id%TYPE
				 ,p_effective_date IN DATE DEFAULT TRUNC(SYSDATE))
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES
  (get_position, WNDS);

PROCEDURE get_segment_value(
             p_flex_code         IN VARCHAR2
            ,p_flex_num          IN VARCHAR2
            ,p_segment_name1     IN VARCHAR2 DEFAULT NULL
            ,p_segment_name2     IN VARCHAR2 DEFAULT NULL
            ,p_segment           hr_mee_views_gen.segmentsTable
            ,p_result           OUT nocopy VARCHAR2
          );

PRAGMA RESTRICT_REFERENCES
  (get_segment_value, WNDS);

FUNCTION get_currency_format(
           p_curcode        pay_element_types_f.input_currency_code%TYPE,
           p_effective_date DATE
         )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES
  (get_currency_format, WNDS);

FUNCTION GET_CONTACTS_TYPE_LIST(
                     p_person_id      IN per_contact_relationships.person_id%TYPE
                    ,p_contact_id     IN per_contact_relationships.contact_person_id%TYPE
				    ,p_effective_date IN DATE DEFAULT TRUNC(SYSDATE))
RETURN VARCHAR2;

FUNCTION is_emergency_contact(
                     p_person_id      IN per_contact_relationships.person_id%TYPE
                    ,p_contact_id     IN per_contact_relationships.contact_person_id%TYPE
				    ,p_effective_date IN DATE DEFAULT TRUNC(SYSDATE))
RETURN NUMBER;

-- ------------------------------------------------------------------------
--|---------------------< get_display_job_name>----------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--  This function calls a procedure get_job_info by passing it the job_id
--  and returns the job name which is one of the out parameters of
--  the procedure get_job_info.
--  The function is to be called in a select query where procedure cannot
--  be called. This function is to be called inplace of the function
--  get_job, which does not separate the concatenated segment's values by
--  the segment seperator fetched from the profile.
--
--  If the HR Views responsibilty profiles HR_JOB_KEYFLEX_SEGMENT1 and
--  HR_JOB_KEYFLEX_SEGMENT2 are set and enabled then these values will
--  be returned with an intermediate separator.  Otherwise the
--  per_jobs.name value will be returned.
--
-- Pre Conditions:
-- In Arguments:
-- Name                    Reqd   Type        Description
-- p_job_id                YES    NUMBER      job ID of a job whose
--                                            name is to be shown.
-- Post Success:
--
--  Returns the job name corresponding job_id.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--
-- -----------------------------------------------------------------------------
FUNCTION get_display_job_name(
			p_job_id      IN per_assignments_f.job_id%TYPE)
RETURN VARCHAR2;

FUNCTION getTrngScore(
           p_person_id IN NUMBER,
           p_event_id IN NUMBER)
RETURN NUMBER;

-- Bug 4513393 Begin
FUNCTION getTrngEndDate(
           p_person_id IN NUMBER,
           p_event_id IN NUMBER)
RETURN DATE;
-- Bug 4513393 Ends

END hr_mee_views_gen;

/

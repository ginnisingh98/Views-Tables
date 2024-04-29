--------------------------------------------------------
--  DDL for Package GHR_PA_REQUESTS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PA_REQUESTS_PKG2" AUTHID CURRENT_USER AS
/* $Header: ghparqs2.pkh 120.4 2005/08/25 11:30:10 vravikan noship $ */

  -- This function checks if there are any pending PA Request actions for a given person (not including the
  -- given PA Request)
  -- And returns a list of thoses that are pending.
  -- The definition of pending is its current routing status is not 'CANCELED' or 'UPDATE_HR_COMPLETE'
  -- To prevent listing those that got put in the 'black hole' (i.e. were saved but not routed) make sure
  -- the routing history has a date notification sent (except for 'FUTURE_ACTIONS' as they may not have
  -- been routed but are still pending)
  FUNCTION check_pending_pars (p_person_id     IN NUMBER
                              ,p_pa_request_id IN NUMBER)
  RETURN VARCHAR2;
  --
  -- This function checks if there are any processed or approved PA Requests for the given person
  -- at the given date. The definition of 'Processed' is the lasting Routing history record is 'UPDATE_HR_COMPLETE'
  -- and the definition of 'Approved' is the lasting Routing history record is 'FUTURE_ACTION'
  FUNCTION check_proc_future_pars (p_person_id      IN NUMBER
                                  ,p_effective_date IN DATE)
  RETURN VARCHAR2;
  --
  PROCEDURE refresh_par_extra_info (p_pa_request_id  IN NUMBER
                                   ,p_first_noa_id   IN NUMBER
                                   ,p_second_noa_id  IN NUMBER
                                   ,p_person_id      IN NUMBER
                                   ,p_assignment_id  IN NUMBER
                                   ,p_position_id    IN NUMBER
                                   ,p_effective_date IN DATE);
  --
  -- This function is passed an altered Pa request id to check that it is not a request id that
  -- is also a correction.
  -- Returns TRUE if the pa request id passed is not a correction
  --
  FUNCTION check_first_correction (p_altered_pa_request_id IN NUMBER)
    RETURN BOOLEAN;
  --
  -- this function takes in a pa request id and gives back the 'Agency code Transfer from'
  -- that is in the PAR EI (should only be called for Appointment transfers, since all these NOACs
  -- are with APP PM family we will actually call it in the form for ALL NOAC's in the APP family)
  -- it should then be used to go into field #14
  FUNCTION get_agency_code_from (p_pa_request_id IN NUMBER
                                ,p_noa_id        IN NUMBER)
    RETURN VARCHAR2;
  --
  -- this function takes in a pa request id and gives back the 'Agency code Transfer to'
  -- that is in the PAR EI (should only be called for NOA 352)
  -- it should then be used to go into field #22
  FUNCTION get_agency_code_to (p_pa_request_id IN NUMBER
                              ,p_noa_id        IN NUMBER)
    RETURN VARCHAR2;
  --
  FUNCTION get_poi (p_position_id IN NUMBER,p_effective_date IN DATE )
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_poi, WNDS, WNPS);
  --
  --
  --
  --
  FUNCTION get_position_nfc_agency_code (p_position_id IN NUMBER,
            p_effective_date IN DATE)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_position_nfc_agency_code, WNDS, WNPS);
  --
  --
  FUNCTION get_poi_eit (p_position_id IN NUMBER,p_effective_date in date,
                        p_bg_id in number)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_poi_eit, WNDS, WNPS);
  --
  --
  --
  FUNCTION get_nfc_agency_eit (p_position_id IN NUMBER,
           p_effective_date in date,
                        p_bg_id in number)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_nfc_agency_eit, WNDS, WNPS);
  --
  --
  FUNCTION get_pay_plan_grade (p_position_id IN NUMBER,p_effective_date IN DATE)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_pay_plan_grade, WNDS, WNPS);
  --
  --
  FUNCTION get_pay_plan_grade_eit (p_position_id IN NUMBER,
          p_effective_date in date,
                        p_bg_id in number)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_pay_plan_grade_eit, WNDS, WNPS);
  --
  --
  FUNCTION get_pay_plan (p_position_id IN NUMBER)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_pay_plan, WNDS, WNPS);
  --
  FUNCTION get_grade_or_level (p_position_id IN NUMBER)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_grade_or_level, WNDS, WNPS);
  --
  FUNCTION get_pos_title_segment (p_business_group_id IN NUMBER)
    RETURN VARCHAR2;
  --
  FUNCTION chk_position_obligated(p_position_id in number
                                ,p_date        in date)
  RETURN BOOLEAN;
  --
  FUNCTION opm_mandated_duty_stations
        (p_duty_station_code  in ghr_duty_stations_f.duty_station_code%TYPE)
  RETURN BOOLEAN;

  FUNCTION get_corr_cop (p_altered_pa_request_id
                           IN ghr_pa_requests.altered_pa_request_id%type)
  RETURN NUMBER;

  FUNCTION get_cop ( p_assignment_id  IN per_assignments_f.assignment_id%type
                  ,p_effective_date IN date)

  RETURN NUMBER;

  PROCEDURE duty_station_warn (p_first_noa_id   IN NUMBER
                              ,p_second_noa_id  IN NUMBER
                              ,p_person_id      IN NUMBER
                              ,p_form_ds_code   IN ghr_duty_stations_f.duty_station_code%TYPE
                              ,p_effective_date IN DATE
                              ,p_message_set    OUT NOCOPY BOOLEAN);

  PROCEDURE chk_position_end_date (p_position_id IN NUMBER
                              ,p_business_group_id IN NUMBER
                              ,p_effective_date  IN DATE
                              ,p_message_set     OUT NOCOPY BOOLEAN);

  PROCEDURE chk_position_hire_status (p_position_id IN NUMBER
                              ,p_business_group_id IN NUMBER
                              ,p_effective_date  IN DATE
                              ,p_message_set     OUT NOCOPY BOOLEAN);
  --
  -- This function is to display a warning message while processing 850 action
  -- whenever the sum of individual components versus the total value of mddds pay is
  -- having difference.
  --
  FUNCTION check_mddds_pay (p_pa_request_id IN NUMBER)
    RETURN BOOLEAN;
  --
  --
  --
END ghr_pa_requests_pkg2;
--

 

/

--------------------------------------------------------
--  DDL for Package GHR_CPDF_DYNRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_DYNRPT" AUTHID CURRENT_USER AS
/* $Header: ghrcpdfd.pkh 120.2.12010000.1 2008/07/28 10:38:09 appldev ship $ */

  -- Bug#2789704 declared the following exception
  CPDF_DYNRPT_ERROR EXCEPTION;

  PROCEDURE cleanup_table;

  FUNCTION exclude_agency (p_agency_code IN VARCHAR2)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(exclude_agency,WNDS,WNPS);

  FUNCTION exclude_noac (p_first_noac       IN VARCHAR2
                        ,p_second_noac      IN VARCHAR2
                        ,p_noa_family_code  IN VARCHAR2)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(exclude_noac,WNDS,WNPS);

  FUNCTION  non_us_citizen_and_foreign_ds (p_citizenship       IN VARCHAR2
                                          ,p_duty_station_code IN VARCHAR2)
    RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(non_us_citizen_and_foreign_ds,WNDS,WNPS);

  FUNCTION exclude_position (p_position_id    IN NUMBER
                            ,p_effective_date IN DATE)
    RETURN BOOLEAN;
  -- Bug#3231946 Added parameter p_duty_station_code.
  FUNCTION get_loc_pay_area_code(p_duty_station_id IN ghr_duty_stations_f.duty_station_id%TYPE default NULL,
               p_duty_station_code IN ghr_duty_stations_f.duty_station_code%TYPE default NULL,
               p_effective_date  IN DATE)
  RETURN VARCHAR2;

  FUNCTION get_equivalent_pay_plan(p_pay_plan IN ghr_pay_plans.pay_plan%TYPE)
  RETURN VARCHAR2;

  FUNCTION format_ni(p_ni IN VARCHAR2)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(format_ni,WNDS,WNPS);

  FUNCTION format_noac(p_noac IN VARCHAR2)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(format_noac,WNDS,WNPS);

  FUNCTION format_basic_pay(p_basic_pay IN NUMBER
                           ,p_pay_basis IN VARCHAR2
                           ,p_size      IN NUMBER)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(format_basic_pay,WNDS,WNPS);

  FUNCTION format_amount(p_amount IN NUMBER
                        ,p_size   IN NUMBER)
    RETURN VARCHAR2;

  -- This function is added as per Bug 5417021
  FUNCTION format_award_perc(p_amount IN NUMBER
                            ,p_size   IN NUMBER)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(format_amount,WNDS,WNPS);

  PROCEDURE get_per_sit_perf_appraisal(p_person_id                IN  NUMBER
                                      ,p_effective_date           IN  DATE
                                      ,p_rating_of_record_level   OUT NOCOPY VARCHAR2
                                      ,p_rating_of_record_pattern OUT NOCOPY VARCHAR2
                                      ,p_rating_of_record_period  OUT NOCOPY DATE);

  PROCEDURE get_suffix_lname(p_last_name   IN  VARCHAR2,
                             p_report_date IN  DATE,
                             p_suffix      OUT NOCOPY VARCHAR2,
                             p_lname       OUT NOCOPY VARCHAR2);

  PROCEDURE populate_ghr_cpdf_temp(p_agency     IN VARCHAR2
                                  ,p_start_date IN DATE
                                  ,p_end_date   IN DATE
                                  ,p_count_only IN BOOLEAN DEFAULT FALSE);

  --
END ghr_cpdf_dynrpt;

/

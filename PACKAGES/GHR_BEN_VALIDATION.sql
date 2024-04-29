--------------------------------------------------------
--  DDL for Package GHR_BEN_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_BEN_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: ghbenval.pkh 120.3.12010000.1 2008/07/28 10:22:06 appldev ship $ */
--
PROCEDURE validate_create_element(
  p_effective_date               in date
  ,p_assignment_id                in number     default null
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_element_link_id              in number    default null
  ,p_element_type_id              in number	   default null
  );

  PROCEDURE validate_update_element(
  p_effective_date               in date
  ,P_ASSIGNMENT_ID_O                in number     default null
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,P_ELEMENT_LINK_ID_O              in number    default null
  ,P_ELEMENT_TYPE_ID_O              in number	   default null
  );

PROCEDURE validate_benefits(
    p_effective_date               in date
  , p_which_eit                    in varchar2
  , p_pa_request_id                in number default null
  , p_first_noa_code               in varchar2 default null
  , p_noa_family_code              in varchar2 default null
  , p_passed_element               in varchar2 default null
  , p_health_plan                  in varchar2 default null
  , p_enrollment_option            in varchar2 default null
  , p_date_fehb_elig               in date default null
  , p_date_temp_elig               in date default null
  , p_temps_total_cost             in varchar2 default null
  , p_pre_tax_waiver               in varchar2 default null
  , p_tsp_scd                      in varchar2 default null
  , p_tsp_amount                   in number default null
  , p_tsp_rate                     in number default null
  , p_tsp_status                   in varchar2 default null
  , p_tsp_status_date              in date default null
  , p_agency_contrib_date          in date default null
  , p_emp_contrib_date             in date default null
  , p_tenure                       in varchar2 default null
  , p_retirement_plan              in varchar2 default null
  , p_fegli_elig_exp_date          in date default null
  , p_fers_elig_exp_date           in date default null
  , p_annuitant_indicator          in varchar2 default null
  , p_assignment_id                in number default null);

	PROCEDURE validate_create_personei(
	p_person_extra_info_id number,
	p_information_type in varchar2,
	p_person_id in number
	);

  END GHR_BEN_VALIDATION;

/

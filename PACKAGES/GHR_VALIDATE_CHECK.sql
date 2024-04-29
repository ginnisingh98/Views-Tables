--------------------------------------------------------
--  DDL for Package GHR_VALIDATE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_VALIDATE_CHECK" AUTHID CURRENT_USER AS
/* $Header: ghrvalid.pkh 120.2.12010000.1 2008/07/28 10:39:24 appldev ship $ */

procedure Validate_CHECK(p_pa_request_rec             IN ghr_pa_requests%ROWTYPE
                            ,p_per_group1             IN ghr_api.per_group1_type
                            ,p_per_retained_grade     IN ghr_api.per_retained_grade_type
                            ,p_per_sep_retire         in ghr_api.per_sep_retire_type
                            ,p_per_conversions	      in ghr_api.per_conversions_type
                            ,p_per_uniformed_services in ghr_api.per_uniformed_services_type
                            ,p_pos_grp1               in ghr_api.pos_grp1_type
                            ,p_pos_valid_grade        in ghr_api.pos_valid_grade_type
                            ,p_loc_info               in ghr_api.loc_info_type
                            ,p_sf52_from_data         in ghr_api.prior_sf52_data_type
                            ,p_personal_info		in ghr_api.personal_info_type
                            ,p_agency_code            in varchar2
				            ,p_gov_awards_type        in ghr_api.government_awards_type
 				            ,p_perf_appraisal_type    in ghr_api.performance_appraisal_type
 				            ,p_health_plan            in varchar2
                            ,p_asg_non_sf52           in ghr_api.asg_non_sf52_type
                            --Pradeep
 			                ,p_premium_pay            in ghr_api.premium_pay_type
                            --Bug#5036370
                            ,p_per_service_oblig      in ghr_api.per_service_oblig_type
                            ,p_within_grade_incr      in ghr_api.within_grade_increase_type --Bug 5527363
                            );

PROCEDURE get_element_details_future (p_element_name         IN     VARCHAR2
                              ,p_input_value_name     IN     VARCHAR2
                              ,p_assignment_id        IN     NUMBER
                              ,p_effective_date       IN     DATE
                              ,p_value                IN OUT NOCOPY VARCHAR2
                              ,p_effective_start_date IN OUT NOCOPY DATE);

end GHR_Validate_CHECK;

/

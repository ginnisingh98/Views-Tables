--------------------------------------------------------
--  DDL for Package GHR_PER_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PER_SUM" AUTHID CURRENT_USER AS
/* $Header: ghpersum.pkh 120.1.12010000.2 2008/08/05 15:10:02 ubhat ship $ */
--
PROCEDURE fetch_peopleei(
    p_person_id         IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT NOCOPY VARCHAR2
   ,p_information2      IN OUT NOCOPY VARCHAR2
   ,p_information3      IN OUT NOCOPY VARCHAR2
   ,p_information4      IN OUT NOCOPY VARCHAR2
   ,p_information5      IN OUT NOCOPY VARCHAR2
   ,p_information6      IN OUT NOCOPY VARCHAR2
   ,p_information7      IN OUT NOCOPY VARCHAR2
   ,p_information8      IN OUT NOCOPY VARCHAR2
   ,p_information9      IN OUT NOCOPY VARCHAR2
   ,p_information10     IN OUT NOCOPY VARCHAR2
   ,p_information11     IN OUT NOCOPY VARCHAR2
   ,p_information12     IN OUT NOCOPY VARCHAR2
   ,p_information13     IN OUT NOCOPY VARCHAR2
   ,p_information14     IN OUT NOCOPY VARCHAR2
   ,p_information15     IN OUT NOCOPY VARCHAR2
   ,p_information16     IN OUT NOCOPY VARCHAR2
   ,p_information17     IN OUT NOCOPY VARCHAR2
   ,p_information18     IN OUT NOCOPY VARCHAR2
   ,p_information19     IN OUT NOCOPY VARCHAR2
   ,p_information20     IN OUT NOCOPY VARCHAR2
   ,p_information21     IN OUT NOCOPY VARCHAR2
   ,p_information22     IN OUT NOCOPY VARCHAR2
   ,p_information23     IN OUT NOCOPY VARCHAR2
   ,p_information24     IN OUT NOCOPY VARCHAR2
   ,p_information25     IN OUT NOCOPY VARCHAR2
   ,p_information26     IN OUT NOCOPY VARCHAR2
   ,p_information27     IN OUT NOCOPY VARCHAR2
   ,p_information28     IN OUT NOCOPY VARCHAR2
   ,p_information29     IN OUT NOCOPY VARCHAR2
   ,p_information30     IN OUT NOCOPY VARCHAR2);

PROCEDURE fetch_asgei(
    p_assignment_id     IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT NOCOPY VARCHAR2
   ,p_information2      IN OUT NOCOPY VARCHAR2
   ,p_information3      IN OUT NOCOPY VARCHAR2
   ,p_information4      IN OUT NOCOPY VARCHAR2
   ,p_information5      IN OUT NOCOPY VARCHAR2
   ,p_information6      IN OUT NOCOPY VARCHAR2
   ,p_information7      IN OUT NOCOPY VARCHAR2
   ,p_information8      IN OUT NOCOPY VARCHAR2
   ,p_information9      IN OUT NOCOPY VARCHAR2
   ,p_information10     IN OUT NOCOPY VARCHAR2
   ,p_information11     IN OUT NOCOPY VARCHAR2
   ,p_information12     IN OUT NOCOPY VARCHAR2
   ,p_information13     IN OUT NOCOPY VARCHAR2
   ,p_information14     IN OUT NOCOPY VARCHAR2
   ,p_information15     IN OUT NOCOPY VARCHAR2
   ,p_information16     IN OUT NOCOPY VARCHAR2
   ,p_information17     IN OUT NOCOPY VARCHAR2
   ,p_information18     IN OUT NOCOPY VARCHAR2
   ,p_information19     IN OUT NOCOPY VARCHAR2
   ,p_information20     IN OUT NOCOPY VARCHAR2
   ,p_information21     IN OUT NOCOPY VARCHAR2
   ,p_information22     IN OUT NOCOPY VARCHAR2
   ,p_information23     IN OUT NOCOPY VARCHAR2
   ,p_information24     IN OUT NOCOPY VARCHAR2
   ,p_information25     IN OUT NOCOPY VARCHAR2
   ,p_information26     IN OUT NOCOPY VARCHAR2
   ,p_information27     IN OUT NOCOPY VARCHAR2
   ,p_information28     IN OUT NOCOPY VARCHAR2
   ,p_information29     IN OUT NOCOPY VARCHAR2
   ,p_information30     IN OUT NOCOPY VARCHAR2);

PROCEDURE fetch_positionei(
    p_position_id       IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT NOCOPY VARCHAR2
   ,p_information2      IN OUT NOCOPY VARCHAR2
   ,p_information3      IN OUT NOCOPY VARCHAR2
   ,p_information4      IN OUT NOCOPY VARCHAR2
   ,p_information5      IN OUT NOCOPY VARCHAR2
   ,p_information6      IN OUT NOCOPY VARCHAR2
   ,p_information7      IN OUT NOCOPY VARCHAR2
   ,p_information8      IN OUT NOCOPY VARCHAR2
   ,p_information9      IN OUT NOCOPY VARCHAR2
   ,p_information10     IN OUT NOCOPY VARCHAR2
   ,p_information11     IN OUT NOCOPY VARCHAR2
   ,p_information12     IN OUT NOCOPY VARCHAR2
   ,p_information13     IN OUT NOCOPY VARCHAR2
   ,p_information14     IN OUT NOCOPY VARCHAR2
   ,p_information15     IN OUT NOCOPY VARCHAR2
   ,p_information16     IN OUT NOCOPY VARCHAR2
   ,p_information17     IN OUT NOCOPY VARCHAR2
   ,p_information18     IN OUT NOCOPY VARCHAR2
   ,p_information19     IN OUT NOCOPY VARCHAR2
   ,p_information20     IN OUT NOCOPY VARCHAR2
   ,p_information21     IN OUT NOCOPY VARCHAR2
   ,p_information22     IN OUT NOCOPY VARCHAR2
   ,p_information23     IN OUT NOCOPY VARCHAR2
   ,p_information24     IN OUT NOCOPY VARCHAR2
   ,p_information25     IN OUT NOCOPY VARCHAR2
   ,p_information26     IN OUT NOCOPY VARCHAR2
   ,p_information27     IN OUT NOCOPY VARCHAR2
   ,p_information28     IN OUT NOCOPY VARCHAR2
   ,p_information29     IN OUT NOCOPY VARCHAR2
   ,p_information30     IN OUT NOCOPY VARCHAR2);
--
PROCEDURE return_special_information(
    p_person_id         IN     NUMBER
   ,p_structure_name    IN     VARCHAR2
   ,p_effective_date    IN     DATE
   ,p_segment1          IN OUT NOCOPY VARCHAR2
   ,p_segment2          IN OUT NOCOPY VARCHAR2
   ,p_segment3          IN OUT NOCOPY VARCHAR2
   ,p_segment4          IN OUT NOCOPY VARCHAR2
   ,p_segment5          IN OUT NOCOPY VARCHAR2
   ,p_segment6          IN OUT NOCOPY VARCHAR2
   ,p_segment7          IN OUT NOCOPY VARCHAR2
   ,p_segment8          IN OUT NOCOPY VARCHAR2
   ,p_segment9          IN OUT NOCOPY VARCHAR2
   ,p_segment10         IN OUT NOCOPY VARCHAR2
   ,p_segment11         IN OUT NOCOPY VARCHAR2
   ,p_segment12         IN OUT NOCOPY VARCHAR2
   ,p_segment13         IN OUT NOCOPY VARCHAR2
   ,p_segment14         IN OUT NOCOPY VARCHAR2
   ,p_segment15         IN OUT NOCOPY VARCHAR2
   ,p_segment16         IN OUT NOCOPY VARCHAR2
   ,p_segment17         IN OUT NOCOPY VARCHAR2
   ,p_segment18         IN OUT NOCOPY VARCHAR2
   ,p_segment19         IN OUT NOCOPY VARCHAR2
   ,p_segment20         IN OUT NOCOPY VARCHAR2
   ,p_segment21         IN OUT NOCOPY VARCHAR2
   ,p_segment22         IN OUT NOCOPY VARCHAR2
   ,p_segment23         IN OUT NOCOPY VARCHAR2
   ,p_segment24         IN OUT NOCOPY VARCHAR2
   ,p_segment25         IN OUT NOCOPY VARCHAR2
   ,p_segment26         IN OUT NOCOPY VARCHAR2
   ,p_segment27         IN OUT NOCOPY VARCHAR2
   ,p_segment28         IN OUT NOCOPY VARCHAR2
   ,p_segment29         IN OUT NOCOPY VARCHAR2
   ,p_segment30         IN OUT NOCOPY VARCHAR2
   ,p_person_analysis_id    IN OUT NOCOPY NUMBER
   ,p_object_version_number IN OUT NOCOPY NUMBER);

PROCEDURE get_grade_details (p_grade_id       IN     NUMBER
                            ,p_grade_name     IN OUT NOCOPY VARCHAR2
                            ,p_pay_plan       IN OUT NOCOPY VARCHAR2
                            ,p_grade_or_level IN OUT NOCOPY VARCHAR2);


PROCEDURE get_retained_grade_details (p_person_id            IN     NUMBER
                                     ,p_effective_date       IN     DATE
                                     ,p_person_extra_info_id IN OUT NOCOPY NUMBER
                                     ,p_date_from            IN OUT NOCOPY DATE
                                     ,p_date_to              IN OUT NOCOPY DATE
                                     ,p_grade_or_level       IN OUT NOCOPY VARCHAR2
                                     ,p_step_or_rate         IN OUT NOCOPY VARCHAR2
                                     ,p_pay_plan             IN OUT NOCOPY VARCHAR2
                                     ,p_pay_table_id         IN OUT NOCOPY VARCHAR2
                                     ,p_pay_basis            IN OUT NOCOPY VARCHAR2
                                     ,p_temp_step            IN OUT NOCOPY VARCHAR2
                                      );

-- Returns TRUE if there are any other reatined grade details for the person other than the one
-- given
FUNCTION further_retained_details_exist(p_person_id            IN NUMBER
                                       ,p_person_extra_info_id IN NUMBER)
  RETURN BOOLEAN;

FUNCTION get_poi_desc (p_personnel_office_id IN NUMBER)
  RETURN VARCHAR2;
--
PROCEDURE get_duty_station_details (p_location_id                  IN     NUMBER
                                   ,p_effective_date               IN     DATE
                                   ,p_duty_sation_code             IN OUT NOCOPY VARCHAR2
                                   ,p_duty_station_desc            IN OUT NOCOPY VARCHAR2
                                   ,p_locality_pay_area            IN OUT NOCOPY VARCHAR2
                                   ,p_locality_pay_area_percentage IN OUT NOCOPY NUMBER
                                    );
--
PROCEDURE get_org_details (p_org_id    IN     NUMBER
                          ,p_org_name  IN OUT NOCOPY VARCHAR2
                          ,p_org_line1 IN OUT NOCOPY VARCHAR2
                          ,p_org_line2 IN OUT NOCOPY VARCHAR2
                          ,p_org_line3 IN OUT NOCOPY VARCHAR2
                          ,p_org_line4 IN OUT NOCOPY VARCHAR2
                          ,p_org_line5 IN OUT NOCOPY VARCHAR2
                          ,p_org_line6 IN OUT NOCOPY VARCHAR2);
--
-- Could not use ghr_api.retrieve_element_entry_value because that does not return
-- effective_start_date
PROCEDURE get_element_details (p_element_name         IN     VARCHAR2
                              ,p_input_value_name     IN     VARCHAR2
                              ,p_assignment_id        IN     NUMBER
                              ,p_effective_date       IN     DATE
                              ,p_value                IN OUT NOCOPY VARCHAR2
                              ,p_effective_start_date IN OUT NOCOPY DATE
			      ,p_business_group_id    IN     NUMBER);                -- Bug 4016362
--
PROCEDURE get_status_code     (p_status         IN   VARCHAR2
                              ,p_status_code    OUT NOCOPY  VARCHAR2);
--
PROCEDURE get_element_entry_values (p_element_entry_id     IN     NUMBER
                                   ,p_input_value_name     IN     VARCHAR2
                                   ,p_effective_date       IN     DATE
                                   ,p_value                IN OUT NOCOPY VARCHAR2
                                   ,p_effective_start_date IN OUT NOCOPY DATE);

--
FUNCTION info_type_is_valid (p_application_id       IN NUMBER
                            ,p_responsibility_id    IN NUMBER
                            ,p_info_type_table_name IN VARCHAR2
                            ,p_information_type     IN VARCHAR2)
  RETURN BOOLEAN;
--
FUNCTION get_workflow_id(p_workflow_name IN VARCHAR2)
  RETURN NUMBER;
--
PROCEDURE get_noa_code        (p_pa_request_id  IN   NUMBER
                              ,p_noa_code       OUT NOCOPY  VARCHAR2);
--
--Begin Bug# 6850492
PROCEDURE get_second_noa_code (p_pa_request_id  IN   NUMBER
                              ,p_second_noa_code       OUT NOCOPY  VARCHAR2);
--End Bug# 6850492
PROCEDURE get_dob_asgstat (p_assignment_id    IN     NUMBER
                           ,p_effective_date  IN     DATE
                           ,p_dob             OUT NOCOPY    DATE
                           ,p_system_status   OUT NOCOPY    VARCHAR2);
--
PROCEDURE get_current_emp_flag (p_effective_date     IN         DATE
                               ,p_person_id          IN         NUMBER
                               ,p_current_emp_flag   OUT NOCOPY VARCHAR2);
--
PROCEDURE get_assignment_id (p_effective_date     IN         DATE
                            ,p_person_id          IN         NUMBER
                            ,p_assignment_id      OUT NOCOPY NUMBER);
--
FUNCTION get_payroll_period_start_date (p_assignment_id IN NUMBER
                                       ,p_effective_date IN DATE)
  RETURN DATE;
--


END ghr_per_sum;

/

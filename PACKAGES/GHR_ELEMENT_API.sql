--------------------------------------------------------
--  DDL for Package GHR_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_ELEMENT_API" AUTHID CURRENT_USER AS
/* $Header: ghelepkg.pkh 120.1 2005/10/02 01:57:49 aroussel $ */
/*#
 * This API processes Federal HR elements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Request for Personnel Action Element
*/
--
g_package       constant varchar2(33) := '  ghr_element_api.';

-- ---------------------------------------------------------------------------
-- |----------------------< retrieve_element_info >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve element info
--
-- Prerequisites:
--
-- In Parameters:
--   p_element_name
--   p_input_value_name
--   p_assignment_id
--   p_effective_date
--   p_processing_type
--
-- Out Parameters:
--   p_element_link_id
--   p_input_value_id
--   p_element_entry_id
--   p_value
--   p_object_version_number
--   p_multiple_error_flag
--
-- Post Success:
--   Processing nulls.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
procedure retrieve_element_info
        (p_element_name      in     pay_element_types_f.element_name%type
        ,p_input_value_name  in     pay_input_values_f.name%type
        ,p_assignment_id     in     pay_element_entries_f.assignment_id%type
        ,p_effective_date    in     date
        ,p_processing_type   in     pay_element_types_f.processing_type%type
        ,p_element_link_id      out nocopy pay_element_links_f.element_link_id%type
        ,p_input_value_id       out nocopy pay_input_values_f.input_value_id%type
        ,p_element_entry_id     out nocopy pay_element_entries_f.element_entry_id%type
        ,p_value                out nocopy pay_element_entry_values_f.screen_entry_value%type
        ,p_object_version_number
                         out nocopy pay_element_entries_f.object_version_number%type
        ,p_multiple_error_flag  out nocopy varchar2
        );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< process_sf52_element >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API processes Federal HR elements.
 *
 * This is a wrapper API used to create and update Federal HR elements by
 * calling Core Payroll element APIs.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Assignment ID and the Input value Name and Value are passed
 *
 * <p><b>Post Success</b><br>
 * This API creates a new element or updates an existing element.
 *
 * <p><b>Post Failure</b><br>
 * An application error is raised and processing is terminated
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_element_name {@rep:casecolumn PAY_ELEMENT_TYPES_F.ELEMENT_NAME}
 * @param p_input_value_name1 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value1 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name2 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value2 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name3 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value3 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name4 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value4 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name5 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value5 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name6 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value6 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name7 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value7 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name8 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value8 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name9 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value9 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name10 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value10 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name11 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value11 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name12 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value12 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name13 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value13 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name14 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value14 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_input_value_name15 {@rep:casecolumn PAY_INPUT_VALUES_F.NAME}
 * @param p_value15 {@rep:casecolumn
 * PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_process_warning Process warning
 * @rep:displayname Process Request for Personnel Action Element
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure process_sf52_element
        (p_assignment_id        in     per_assignments_f.assignment_id%type
        ,p_element_name         in     pay_element_types_f.element_name%type
        ,p_input_value_name1    in     pay_input_values_f.name%type
                                                        default null
        ,p_value1               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name2    in     pay_input_values_f.name%type
                                                        default null
        ,p_value2               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name3    in     pay_input_values_f.name%type
                                                        default null
        ,p_value3               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name4    in     pay_input_values_f.name%type
                                                        default null
        ,p_value4               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name5    in     pay_input_values_f.name%type
                                                        default null
        ,p_value5               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name6    in     pay_input_values_f.name%type
                                                        default null
        ,p_value6               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name7    in     pay_input_values_f.name%type
                                                        default null
        ,p_value7               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name8    in     pay_input_values_f.name%type
                                                        default null
        ,p_value8               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name9    in     pay_input_values_f.name%type
                                                        default null
        ,p_value9               in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name10   in     pay_input_values_f.name%type
                                                        default null
        ,p_value10              in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name11   in     pay_input_values_f.name%type
                                                        default null
        ,p_value11              in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name12   in     pay_input_values_f.name%type
                                                        default null
        ,p_value12              in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name13   in     pay_input_values_f.name%type
                                                        default null
        ,p_value13              in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name14   in     pay_input_values_f.name%type
                                                        default null
        ,p_value14              in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_input_value_name15   in     pay_input_values_f.name%type
                                                        default null
        ,p_value15              in     pay_element_entry_values_f.screen_entry_value%type
                                                        default null
        ,p_effective_date       in     date             default null
        ,p_process_warning         out nocopy boolean
        );
--
end ghr_element_api;

 

/

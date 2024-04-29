--------------------------------------------------------
--  DDL for Package PAY_BALANCE_ADJUSTMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_ADJUSTMENT_API" AUTHID CURRENT_USER as
/* $Header: pybadapi.pkh 120.1 2005/10/02 02:29:26 aroussel $ */
/*#
 * This package contains the Balance Adjustment API.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Balance Adjustment
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_adjustment >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API performs a balance adjustment.
 *
 * This API creates a balance adjustment payroll action, assignment action,
 * element entry and run results.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * Relevant element type and link should be defined.
 *
 * <p><b>Post Success</b><br>
 * Balance adjustment action and run results will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The assignment action of payroll action will have been set to an error
 * status , and messages created.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_consolidation_set_id consolidation set identifier for this balance
 * adjustment
 * @param p_element_link_id Element Link identifier for of entry to be created
 * @param p_input_value_id1 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id2 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id3 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id4 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id5 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id6 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id7 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id8 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id9 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id10 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id11 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id12 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id13 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id14 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_input_value_id15 Identifier of Input value for the element for this
 * balance adjustment
 * @param p_entry_value1 Value of element entry for this balance adjustment
 * @param p_entry_value2 Value of element entry for this balance adjustment
 * @param p_entry_value3 Value of element entry for this balance adjustment
 * @param p_entry_value4 Value of element entry for this balance adjustment
 * @param p_entry_value5 Value of element entry for this balance adjustment
 * @param p_entry_value6 Value of element entry for this balance adjustment
 * @param p_entry_value7 Value of element entry for this balance adjustment
 * @param p_entry_value8 Value of element entry for this balance adjustment
 * @param p_entry_value9 Value of element entry for this balance adjustment
 * @param p_entry_value10 Value of element entry for this balance adjustment
 * @param p_entry_value11 Value of element entry for this balance adjustment
 * @param p_entry_value12 Value of element entry for this balance adjustment
 * @param p_entry_value13 Value of element entry for this balance adjustment
 * @param p_entry_value14 Value of element entry for this balance adjustment
 * @param p_entry_value15 Value of element entry for this balance adjustment
 * @param p_prepay_flag Flag to indicate if values should be used for
 * prepayments
 * @param p_balance_adj_cost_flag Indicate whether this balance adjustment
 * should be costed.
 * @param p_cost_allocation_keyflex_id Costing key flexfield identifier to be
 * stamped on the element entry created.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_element_entry_id Element entry identifier for element entry created
 * by balance adjustment.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the related element entry. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created element entry . If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element entry. If p_validate is true, then the
 * value will be null.
 * @param p_create_warning Value returned if element entry creation created a
 * warning
 * @param p_run_type_id Run type identifier to be stamped on payroll action
 * @param p_original_entry_id New parameter, available on the latest version of
 * this API.
 * @rep:displayname Create Adjustment
 * @rep:category BUSINESS_ENTITY PAY_BALANCE_ADJUSTMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_adjustment
(
   p_validate                   in     boolean  default false,
   p_effective_date             in     date,
   p_assignment_id              in     number,
   p_consolidation_set_id       in     number,
   p_element_link_id            in     number,
   p_input_value_id1            in     number   default null,
   p_input_value_id2            in     number   default null,
   p_input_value_id3            in     number   default null,
   p_input_value_id4            in     number   default null,
   p_input_value_id5            in     number   default null,
   p_input_value_id6            in     number   default null,
   p_input_value_id7            in     number   default null,
   p_input_value_id8            in     number   default null,
   p_input_value_id9            in     number   default null,
   p_input_value_id10           in     number   default null,
   p_input_value_id11           in     number   default null,
   p_input_value_id12           in     number   default null,
   p_input_value_id13           in     number   default null,
   p_input_value_id14           in     number   default null,
   p_input_value_id15           in     number   default null,
   p_entry_value1               in     varchar2 default null,
   p_entry_value2               in     varchar2 default null,
   p_entry_value3               in     varchar2 default null,
   p_entry_value4               in     varchar2 default null,
   p_entry_value5               in     varchar2 default null,
   p_entry_value6               in     varchar2 default null,
   p_entry_value7               in     varchar2 default null,
   p_entry_value8               in     varchar2 default null,
   p_entry_value9               in     varchar2 default null,
   p_entry_value10              in     varchar2 default null,
   p_entry_value11              in     varchar2 default null,
   p_entry_value12              in     varchar2 default null,
   p_entry_value13              in     varchar2 default null,
   p_entry_value14              in     varchar2 default null,
   p_entry_value15              in     varchar2 default null,
   p_prepay_flag                in     varchar2 default null,

   -- Costing information.
   p_balance_adj_cost_flag      in     varchar2 default null,
   p_cost_allocation_keyflex_id in     number   default null,
   p_attribute_category         in     varchar2 default null,
   p_attribute1                 in     varchar2 default null,
   p_attribute2                 in     varchar2 default null,
   p_attribute3                 in     varchar2 default null,
   p_attribute4                 in     varchar2 default null,
   p_attribute5                 in     varchar2 default null,
   p_attribute6                 in     varchar2 default null,
   p_attribute7                 in     varchar2 default null,
   p_attribute8                 in     varchar2 default null,
   p_attribute9                 in     varchar2 default null,
   p_attribute10                in     varchar2 default null,
   p_attribute11                in     varchar2 default null,
   p_attribute12                in     varchar2 default null,
   p_attribute13                in     varchar2 default null,
   p_attribute14                in     varchar2 default null,
   p_attribute15                in     varchar2 default null,
   p_attribute16                in     varchar2 default null,
   p_attribute17                in     varchar2 default null,
   p_attribute18                in     varchar2 default null,
   p_attribute19                in     varchar2 default null,
   p_attribute20                in     varchar2 default null,

   p_run_type_id                in     number   default null,
   p_original_entry_id          in     number   default null,

   -- Element entry information.
   p_element_entry_id              out nocopy number,
   p_effective_start_date          out nocopy date,
   p_effective_end_date            out nocopy date,
   p_object_version_number         out nocopy number,
   p_create_warning                out nocopy boolean
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_adjustment >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API performs a balance adjustment.
 *
 * Removes the results created by the payroll action.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * Balance adjustment must be valid for deletion.
 *
 * <p><b>Post Success</b><br>
 * Action will have been removed from database.
 *
 * <p><b>Post Failure</b><br>
 * An error will be raised and the adjustment will not be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_entry_id Element entry identifier associated with balance
 * adjustment that is to be deleted
 * @rep:displayname Delete Adjustment
 * @rep:category BUSINESS_ENTITY PAY_BALANCE_ADJUSTMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_adjustment
(
   p_validate         in boolean default false,
   p_effective_date   in date,
   p_element_entry_id in number
);

end pay_balance_adjustment_api;

 

/

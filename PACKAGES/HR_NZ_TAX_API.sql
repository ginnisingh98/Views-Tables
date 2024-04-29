--------------------------------------------------------
--  DDL for Package HR_NZ_TAX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_TAX_API" AUTHID CURRENT_USER AS
/* $Header: hrnzwrtx.pkh 120.4 2005/10/31 03:19:48 rpalli noship $ */
/*#
 * This package contains tax related APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Tax for New Zealand
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< maintain_tax_info >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API maintains the Tax information for an employee.
 *
 * The API updates the tax element details by using the core
 * update_element_entry.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element "PAYE Information" and the corresponding links should be active
 * as of the date.
 *
 * <p><b>Post Success</b><br>
 * The API successfully updates the tax element entry with the details.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the entry and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which you update the
 * tax info.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_mode Indicates which DateTrack mode to use when updating the
 * record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_business_group_id Indicates the Business group in New Zealand where
 * the employee is present.
 * @param p_cost_allocation_keyflex_id Indicates the Code combination id of the
 * segment combination which is used in the costing of element entry.
 * @param p_updating_action_id Updating action id.
 * @param p_updating_action_type Updating action type.
 * @param p_original_entry_id Original entry id.
 * @param p_creator_type Source of element entry, eg.Form, MIX process etc.
 * @param p_comment_id Comment identifier.
 * @param p_creator_id Creator id.
 * @param p_reason Reason attached to element entry. Validated via lookup
 * @param p_subpriority Subpriority used to process the element entry.
 * @param p_date_earned Date earned.
 * @param p_personal_payment_method_id Personal payment type attached to the
 * element entry, eg. Cash.
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
 * @param p_tax_code Indicates the Special Tax Code.
 * @param p_special_tax_code Indicates the Special Tax Rate for the employee.
 * @param p_paye_special_rate Indicates the Paye Special Tax Rate.
 * @param p_acc_special_rate Indicates the Acc Special Tax Rate input of the
 * element.
 * @param p_student_loan_rate Indicates the loan rate of the Student.
 * @param p_all_extra_emol_at_high_rate Indicates the All Extra Emol At High
 * Rate.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated tax information element row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated tax information row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_update_warning Always set to delete warning if applicable.
 * @rep:displayname Maintain Tax Information for New Zealand
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE maintain_tax_info
  	(p_validate			IN    BOOLEAN
	,p_assignment_id        	IN    NUMBER
	,p_effective_date         	IN    DATE
	,p_mode                 	IN    VARCHAR2
	,p_business_group_id		IN    NUMBER
	,p_cost_allocation_keyflex_id	IN    NUMBER 	DEFAULT hr_api.g_number
	,p_updating_action_id           IN    NUMBER    DEFAULT hr_api.g_number
	,p_updating_action_type         IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_original_entry_id            IN    NUMBER    DEFAULT hr_api.g_number
	,p_creator_type                 IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_comment_id			IN    NUMBER 	DEFAULT hr_api.g_number
	,p_creator_id                   IN    NUMBER    DEFAULT hr_api.g_number
	,p_reason			IN    VARCHAR2	DEFAULT hr_api.g_varchar2
	,p_subpriority                  IN    NUMBER    DEFAULT hr_api.g_number
	,p_date_earned                  IN    DATE      DEFAULT hr_api.g_date
	,p_personal_payment_method_id   IN    NUMBER    DEFAULT hr_api.g_number
	,p_attribute_category         	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute1                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute2                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute3                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute4                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute5                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute6                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute7                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute8                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute9                 	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute10                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute11                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute12                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute13                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute14                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute15                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute16                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute17                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute18                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_attribute19                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
  	,p_attribute20                	IN    VARCHAR2  DEFAULT hr_api.g_varchar2
	,p_tax_code			IN    VARCHAR2	DEFAULT 'ND'
	,p_special_tax_code	  	IN    VARCHAR2	DEFAULT 'N'
	,p_paye_special_rate	  	IN    NUMBER	DEFAULT hr_api.g_number
	,p_acc_special_rate	  	IN    NUMBER	DEFAULT hr_api.g_number
	,p_student_loan_rate    	IN    NUMBER	DEFAULT hr_api.g_number
	,p_all_extra_emol_at_high_rate	IN    VARCHAR2	DEFAULT 'N'
	,p_effective_start_date 	OUT NOCOPY  DATE
	,p_effective_end_date   	OUT NOCOPY  DATE
	,p_update_warning		OUT NOCOPY  BOOLEAN
	);

  END hr_nz_tax_api;

 

/
